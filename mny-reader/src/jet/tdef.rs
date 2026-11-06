//! Définitions de tables (TDEF) — spécification, document 02 §5.

use crate::bytes::{slice, u16_at, u32_at, u8_at, utf16le};
use crate::error::{Error, Result};
use crate::msisam::{Pages, PAGE_SIZE};
use crate::value::col_type;

const PAGE_TYPE_TDEF: u8 = 0x02;
const COLUMN_DESCRIPTOR_LEN: usize = 25;
const REAL_INDEX_PART1_LEN: usize = 12;

/// Description d'une colonne.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Column {
    /// Nom de la colonne.
    pub name: String,
    /// Code de type Jet (voir [`crate::value::col_type`]).
    pub col_type: u8,
    /// Numéro de colonne (`col_num`, descripteur +5) : indice dans le null-mask.
    pub number: u16,
    /// Indice dans la table des offsets variables (colonnes variables).
    pub var_index: u16,
    /// `true` : la valeur est dans la zone fixe de la ligne.
    pub fixed: bool,
    /// Position dans la zone fixe (colonnes fixes).
    pub fixed_offset: u16,
    /// Taille (type fixe) ou taille maximale (TEXT, BINARY).
    pub length: u16,
    /// Drapeaux bruts (descripteur +15).
    pub flags: u8,
}

impl Column {
    /// Nom lisible du type.
    pub fn type_name(&self) -> &'static str {
        col_type::name(self.col_type)
    }
}

/// Définition de table décodée.
#[derive(Debug, Clone)]
pub(crate) struct TableDef {
    pub page: u32,
    pub declared_row_count: u32,
    pub used_pages: u32,
    /// Colonnes triées par `number`.
    pub columns: Vec<Column>,
}

/// Concatène les pages d'une TDEF chaînée.
fn concat(pages: &Pages, first: u32) -> Result<Vec<u8>> {
    let p = pages.page(first)?;
    if p[0] != PAGE_TYPE_TDEF || p[1] != 0x01 {
        return Err(Error::corrupt(format!(
            "la page {first} n'est pas une définition de table"
        )));
    }
    let mut buf = p.to_vec();
    let mut next = u32_at(p, 4)?;
    let mut hops = 0u32;
    while next != 0 {
        hops += 1;
        if hops > pages.count() {
            return Err(Error::corrupt("chaîne de définition de table cyclique"));
        }
        let q = pages.page(next)?;
        if q[0] != PAGE_TYPE_TDEF {
            return Err(Error::corrupt(format!(
                "page de suite de TDEF {next} invalide"
            )));
        }
        buf.extend_from_slice(&q[8..PAGE_SIZE]);
        next = u32_at(q, 4)?;
    }
    Ok(buf)
}

pub(crate) fn read(pages: &Pages, page: u32) -> Result<TableDef> {
    let b = concat(pages, page)?;
    let declared_row_count = u32_at(&b, 0x10)?;
    let num_cols = u16_at(&b, 0x2D)? as usize;
    let num_real_idx = u32_at(&b, 0x33)? as usize;
    let used_pages = u32_at(&b, 0x37)?;

    let mut o = 0x3F + REAL_INDEX_PART1_LEN * num_real_idx;
    let mut columns = Vec::with_capacity(num_cols);
    for _ in 0..num_cols {
        let d = slice(&b, o, COLUMN_DESCRIPTOR_LEN)?;
        let flags = u8_at(d, 15)?;
        columns.push(Column {
            name: String::new(),
            col_type: u8_at(d, 0)?,
            number: u16_at(d, 5)?,
            var_index: u16_at(d, 7)?,
            fixed: flags & 0x01 != 0,
            fixed_offset: u16_at(d, 21)?,
            length: u16_at(d, 23)?,
            flags,
        });
        o += COLUMN_DESCRIPTOR_LEN;
    }
    for c in columns.iter_mut() {
        let len = u16_at(&b, o)? as usize;
        c.name = utf16le(slice(&b, o + 2, len)?);
        o += 2 + len;
    }
    columns.sort_by_key(|c| c.number);
    Ok(TableDef {
        page,
        declared_row_count,
        used_pages,
        columns,
    })
}
