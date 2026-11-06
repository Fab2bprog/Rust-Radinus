//! # mny-reader
//!
//! Lecture des fichiers **Microsoft Money** (`.mny`), sans aucune dépendance Microsoft.
//!
//! Un fichier `.mny` est une base Jet 4 dont les pages 1 à 14 sont chiffrées en RC4.
//! Cette bibliothèque :
//! 1. déchiffre le fichier (avec ou sans mot de passe) — module [`msisam`] ;
//! 2. lit le catalogue, les définitions de tables et les lignes — module [`jet`] ;
//! 3. renvoie chaque cellule sous forme de [`Value`].
//!
//! ## Exemple
//!
//! ```no_run
//! use mny_reader::{MnyFile, Value};
//!
//! let mny = MnyFile::open("compte.mny", None)?;          // Some("motdepasse") si besoin
//! for info in mny.money_tables() {
//!     println!("{}", info.name);
//! }
//! let trn = mny.table("TRN")?;
//! let amt = trn.column_index("amt").expect("colonne amt");
//! for row in trn.rows()? {
//!     let row = row?;
//!     if let Value::Money(m) = &row[amt] {
//!         println!("{m}");
//!     }
//! }
//! # Ok::<(), mny_reader::Error>(())
//! ```
//!
//! ## Intégration
//!
//! - Seul point d'entrée : [`MnyFile`] (`open` ou `from_bytes`).
//! - Aucun état global, aucune entrée/sortie après l'ouverture : le fichier est chargé en mémoire.
//! - [`MnyFile`] est `Send + Sync` : on peut lire plusieurs tables en parallèle.
//! - Les noms de tables et de colonnes sont ceux du fichier (`TRN`, `htrn`, `amt`…).

#![forbid(unsafe_code)]

mod bytes;
mod error;
pub mod jet;
pub mod msisam;
mod rc4;
pub mod value;

use std::ops::Index;
use std::path::Path;

pub use error::{Error, Result};
pub use jet::Column;
pub use msisam::{EncryptionInfo, KeyScheme};
pub use value::{Guid, JetDateTime, Money, Value};

use jet::page::{self, ROW_DELETED, ROW_OVERFLOW};
use jet::tdef::{self, TableDef};
use msisam::Pages;

/// Page de la définition de la table système `MSysObjects`.
const CATALOG_PAGE: u32 = 2;
/// `ParentId` du conteneur racine, et `Id` du conteneur « Tables ».
const ROOT_PARENT_ID: i32 = 0x0F00_0000;
/// Type d'objet « table locale » dans `MSysObjects`.
const OBJECT_TYPE_TABLE: i16 = 1;

/// Un fichier Money ouvert et déchiffré.
#[derive(Debug, Clone)]
pub struct MnyFile {
    pages: Pages,
    encryption: EncryptionInfo,
    tables: Vec<TableInfo>,
}

/// Entrée du catalogue : une table du fichier.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct TableInfo {
    /// Nom de la table (`TRN`, `ACCT`…).
    pub name: String,
    /// Page de sa définition.
    pub tdef_page: u32,
    /// `true` pour les tables système Jet (`MSys*`).
    pub is_system: bool,
}

impl MnyFile {
    /// Ouvre un fichier `.mny`. `password` : `None` (ou `Some("")`) si le fichier n'en a pas.
    pub fn open(path: impl AsRef<Path>, password: Option<&str>) -> Result<Self> {
        Self::from_bytes(std::fs::read(path)?, password)
    }

    /// Ouvre un fichier `.mny` déjà chargé en mémoire.
    pub fn from_bytes(bytes: Vec<u8>, password: Option<&str>) -> Result<Self> {
        let (pages, encryption) = msisam::decrypt(bytes, password)?;
        let mut mny = MnyFile {
            pages,
            encryption,
            tables: Vec::new(),
        };
        mny.tables = mny.read_catalog()?;
        Ok(mny)
    }

    /// Informations de chiffrement (schéma, condensat, etc.).
    pub fn encryption(&self) -> &EncryptionInfo {
        &self.encryption
    }

    /// Nombre de pages du fichier.
    pub fn page_count(&self) -> u32 {
        self.pages.count()
    }

    /// Toutes les tables, y compris les tables système `MSys*`.
    pub fn tables(&self) -> &[TableInfo] {
        &self.tables
    }

    /// Tables Money uniquement (hors tables système `MSys*`).
    pub fn money_tables(&self) -> impl Iterator<Item = &TableInfo> {
        self.tables.iter().filter(|t| !t.is_system)
    }

    /// Ouvre une table par son nom (sensible à la casse).
    pub fn table(&self, name: &str) -> Result<Table<'_>> {
        let info = self
            .tables
            .iter()
            .find(|t| t.name == name)
            .ok_or_else(|| Error::TableNotFound(name.to_string()))?;
        self.table_at(info.clone())
    }

    fn table_at(&self, info: TableInfo) -> Result<Table<'_>> {
        let def = tdef::read(&self.pages, info.tdef_page)?;
        Ok(Table {
            mny: self,
            info,
            def,
        })
    }

    fn read_catalog(&self) -> Result<Vec<TableInfo>> {
        let catalog = self.table_at(TableInfo {
            name: "MSysObjects".into(),
            tdef_page: CATALOG_PAGE,
            is_system: true,
        })?;
        let (ci, cp, cn, ct) = match (
            catalog.column_index("Id"),
            catalog.column_index("ParentId"),
            catalog.column_index("Name"),
            catalog.column_index("Type"),
        ) {
            (Some(a), Some(b), Some(c), Some(d)) => (a, b, c, d),
            _ => return Err(Error::corrupt("catalogue MSysObjects incomplet")),
        };
        let mut objects = Vec::new();
        for row in catalog.rows()? {
            let row = row?;
            let id = match row[ci] {
                Value::Int32(v) => v,
                _ => continue,
            };
            let parent = match row[cp] {
                Value::Int32(v) => v,
                _ => continue,
            };
            let name = match &row[cn] {
                Value::Text(s) => s.clone(),
                _ => continue,
            };
            let ty = match row[ct] {
                Value::Int16(v) => v,
                _ => continue,
            };
            objects.push((id, parent, name, ty));
        }
        let tables_id = objects
            .iter()
            .find(|(_, p, n, _)| *p == ROOT_PARENT_ID && n == "Tables")
            .map(|(id, ..)| *id)
            .ok_or_else(|| Error::corrupt("conteneur « Tables » absent du catalogue"))?;
        let mut tables: Vec<TableInfo> = objects
            .into_iter()
            .filter(|(_, p, _, ty)| *p == tables_id && *ty == OBJECT_TYPE_TABLE)
            .map(|(id, _, name, _)| TableInfo {
                is_system: name.starts_with("MSys"),
                tdef_page: (id as u32) & 0x00FF_FFFF,
                name,
            })
            .collect();
        tables.sort_by(|a, b| a.name.cmp(&b.name));
        Ok(tables)
    }
}

/// Une table ouverte.
#[derive(Debug, Clone)]
pub struct Table<'a> {
    mny: &'a MnyFile,
    info: TableInfo,
    def: TableDef,
}

impl<'a> Table<'a> {
    /// Nom de la table.
    pub fn name(&self) -> &str {
        &self.info.name
    }

    /// Colonnes, dans l'ordre logique (`col_num`).
    pub fn columns(&self) -> &[Column] {
        &self.def.columns
    }

    /// Position d'une colonne (pour indexer une [`Row`]).
    pub fn column_index(&self, name: &str) -> Option<usize> {
        self.def.columns.iter().position(|c| c.name == name)
    }

    /// Nombre de lignes annoncé par la définition de table. **Non fiable** : compter les lignes lues.
    pub fn declared_row_count(&self) -> u32 {
        self.def.declared_row_count
    }

    /// Itérateur sur les lignes, dans l'ordre physique.
    pub fn rows(&self) -> Result<Rows<'_>> {
        let pages = page::usage_map_pages(&self.mny.pages, self.def.used_pages)?;
        Ok(Rows {
            table: self,
            pages,
            page_idx: 0,
            row_idx: 0,
        })
    }
}

/// Une ligne : une [`Value`] par colonne, dans l'ordre de [`Table::columns`].
#[derive(Debug, Clone, PartialEq)]
pub struct Row {
    values: Vec<Value>,
}

impl Row {
    /// Valeurs de la ligne.
    pub fn values(&self) -> &[Value] {
        &self.values
    }

    /// Consomme la ligne et renvoie ses valeurs.
    pub fn into_values(self) -> Vec<Value> {
        self.values
    }
}

impl Index<usize> for Row {
    type Output = Value;
    fn index(&self, i: usize) -> &Value {
        &self.values[i]
    }
}

/// Itérateur des lignes d'une table.
pub struct Rows<'t> {
    table: &'t Table<'t>,
    pages: Vec<u32>,
    page_idx: usize,
    row_idx: u16,
}

impl Iterator for Rows<'_> {
    type Item = Result<Row>;

    fn next(&mut self) -> Option<Self::Item> {
        let pages = &self.table.mny.pages;
        loop {
            let page_no = *self.pages.get(self.page_idx)?;
            let pg = match pages.page(page_no) {
                Ok(p) => p,
                Err(e) => {
                    self.page_idx += 1;
                    return Some(Err(e));
                }
            };
            // Page étrangère à la table : ignorée.
            let owner = u32::from_le_bytes([pg[4], pg[5], pg[6], pg[7]]);
            let n = if pg[0] == page::PAGE_TYPE_DATA && owner == self.table.def.page {
                page::row_count(pg).unwrap_or(0)
            } else {
                0
            };
            if self.row_idx >= n {
                self.page_idx += 1;
                self.row_idx = 0;
                continue;
            }
            let row = self.row_idx;
            self.row_idx += 1;
            let raw = match page::row_entry(pg, row) {
                Ok(r) => r,
                Err(e) => return Some(Err(e)),
            };
            if raw & ROW_DELETED != 0 {
                continue;
            }
            return Some(self.read_row(page_no, row, raw));
        }
    }
}

impl Rows<'_> {
    fn read_row(&self, page_no: u32, row: u16, raw: u16) -> Result<Row> {
        let pages = &self.table.mny.pages;
        let (_, mut bytes) = page::row_bytes(pages, page_no, row)?;
        if raw & ROW_OVERFLOW != 0 {
            bytes = page::follow_overflow(pages, bytes)?;
        }
        let values = jet::row::decode_row(pages, &self.table.def.columns, bytes)?;
        Ok(Row { values })
    }
}

#[cfg(test)]
mod send_sync {
    fn assert_send_sync<T: Send + Sync>() {}
    #[test]
    fn mny_file_est_send_sync() {
        assert_send_sync::<super::MnyFile>();
    }
}
