//! **L'exportation d'une base entière** (Fabrice, 19/10/2026, P-74) — le
//! socle que partagent tous les formats de l'assistant.
//!
//! « On peut imaginer, dans un futur très très lointain, que Radinus soit
//! abandonné, ou que l'utilisateur veuille quitter Radinus. Il faut lui donner
//! des moyens performants d'exporter la base vers d'autres formats. » Ce n'est
//! pas fait pour travailler dessus : c'est fait pour que **les données passent
//! dans un autre logiciel**, et que l'utilisateur ne perde rien.
//!
//! # Une copie fidèle, table par table
//!
//! Chaque table garde **son nom et les noms de ses champs**, tels qu'ils sont
//! dans la base ; chaque ligne garde ses identifiants, si bien qu'un autre
//! logiciel — Access, une base SQL, un tableur — peut refaire les liens tout
//! seul. Deux conversions seulement, parce qu'exportées telles quelles ces
//! valeurs seraient **fausses** ailleurs :
//!
//!   * **les montants**, rangés en millionièmes (`-57620000` pour −57,62),
//!     deviennent le vrai montant, dans la devise de la base ;
//!   * **les dates**, rangées en texte (`2026-07-20`), deviennent de vraies
//!     dates.
//!
//! Une date qu'on ne sait pas lire n'est pas jetée : elle part telle qu'elle
//! est écrite, et l'export le signale. Rien ne disparaît en silence.
//!
//! # Ce qui part, ce qui reste
//!
//! Tout ce qui sert à « compter, classer, filtrer, évaluer » l'argent part :
//! comptes, opérations et leurs ventilations, commentaires, chéquiers et
//! chèques, budget, opérations périodiques, modèles, et **toute** la
//! nomenclature — même ce qu'aucune opération n'utilise. Restent dans la base
//! les pièces jointes et le mot de passe (« je m'en fiche »), et les réglages
//! internes de Radinus. La liste est écrite **une seule fois**, ici ; un test
//! la confronte au schéma, et une table ou une colonne ajoutée un jour sans
//! être rangée d'un côté ou de l'autre le fait échouer. C'est la garantie que
//! l'utilisateur ne perdra rien, même dans dix ans.
//!
//! # Lecture seule
//!
//! La base est ouverte **en lecture seule** : l'export ne peut rien y écrire,
//! pas même la mise à jour de schéma que fait une ouverture ordinaire. Une base
//! d'une version plus ancienne n'est donc pas exportée telle quelle — on
//! l'ouvre d'abord une fois dans Radinus, qui la met à jour — et une base plus
//! récente non plus.

use crate::domain::NaiveDate;
use crate::money::UNIT;
use crate::sheets::{Sheet, SheetCell};
use std::path::{Path, PathBuf};
use rusqlite::types::ValueRef;
use rusqlite::{Connection, OpenFlags};

// --- Le catalogue -------------------------------------------------------------

/// La nature d'une colonne, pour l'export.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Kind {
    /// Un nombre entier : identifiant, numéro, case 0/1, compteur.
    Integer,
    Text,
    /// Un montant, rangé en millionièmes, exporté en vrai montant.
    Money,
    /// Une date, rangée en texte `AAAA-MM-JJ`, exportée en vraie date.
    Date,
}

/// Une colonne : son nom dans la base, et sa nature.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct ColumnSpec {
    pub name: &'static str,
    pub kind: Kind,
}

/// Une table exportée : son nom, et **toutes** ses colonnes, dans l'ordre de
/// la base.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct TableSpec {
    pub name: &'static str,
    pub columns: &'static [ColumnSpec],
}

const fn integer(name: &'static str) -> ColumnSpec {
    ColumnSpec { name, kind: Kind::Integer }
}
const fn text(name: &'static str) -> ColumnSpec {
    ColumnSpec { name, kind: Kind::Text }
}
const fn money(name: &'static str) -> ColumnSpec {
    ColumnSpec { name, kind: Kind::Money }
}
const fn date(name: &'static str) -> ColumnSpec {
    ColumnSpec { name, kind: Kind::Date }
}

/// **Les tables exportées**, dans un ordre qui met chaque nomenclature avant
/// ce qui la cite — l'ordre où un autre logiciel les recréerait.
pub const TABLES: &[TableSpec] = &[
    TableSpec { name: "TypeCompte", columns: &[integer("IDTypeCompte"), text("Libelle")] },
    TableSpec { name: "Banques", columns: &[integer("IDBanques"), text("NomBanque")] },
    TableSpec { name: "TypeCategorie", columns: &[integer("IDTypeCategorie"), text("Libelle")] },
    TableSpec { name: "PosteBudget", columns: &[integer("IDPosteBudget"), text("Libelle")] },
    TableSpec {
        name: "Categorie",
        columns: &[integer("IDCategorie"), text("Libelle"), integer("IDTypeCategorie"), integer("IDPosteBudget")],
    },
    TableSpec { name: "ModeOperation", columns: &[integer("IDModeOperation"), text("Libelle")] },
    TableSpec { name: "Affectation", columns: &[integer("IDAffectation"), text("Libelle")] },
    TableSpec { name: "Tiers", columns: &[integer("IDTiers"), text("Libelle")] },
    TableSpec { name: "Projets", columns: &[integer("IDProjets"), text("Libelle")] },
    TableSpec { name: "StatutOperation", columns: &[integer("IDStatutOperation"), text("Libelle")] },
    TableSpec { name: "Verification", columns: &[integer("IDVerification"), text("Libelle")] },
    TableSpec { name: "StatutCheque", columns: &[integer("IDStatutCheque"), text("Libelle"), text("Description")] },
    TableSpec {
        name: "Compte",
        columns: &[
            integer("IDCompte"),
            money("ReportPointe"),
            money("ReportEngage"),
            money("ReportPrevu"),
            text("Libelle"),
            integer("IDTypeCompte"),
            integer("IDBanques"),
            money("SoldeBanque"),
            money("SoldeReel"),
            money("SoldeFinal"),
            text("NomTitulaire"),
            text("AdresseTitulaire"),
            text("COBCodeBanque"),
            text("COBCodeGuichet"),
            text("COBNumCompte"),
            text("COBClefRIB"),
            text("COBIBAN"),
            date("DateOuverture"),
            date("DateCloture"),
            text("AdresseAgenceBank"),
            text("COBBIC"),
            integer("NumProchCheque"),
            integer("CompteCloture"),
            text("Devise"),
        ],
    },
    TableSpec {
        name: "Chequier",
        columns: &[
            integer("IDChequier"),
            date("DateRecep"),
            integer("NumPremierChq"),
            integer("NumDernChq"),
            integer("QteChq"),
            text("IDReferenceChq"),
            integer("FormatNumChq"),
            text("Commentaires"),
            integer("IDCompte"),
        ],
    },
    TableSpec {
        name: "Cheque",
        columns: &[
            integer("IDCheque"),
            integer("NumChq"),
            integer("IDChequier"),
            date("DateEmission"),
            text("Beneficiaire"),
            money("Montant"),
            text("Commentaires"),
            text("LieuEmission"),
            integer("IDStatutCheque"),
        ],
    },
    TableSpec {
        name: "Operation",
        columns: &[
            integer("IDOperation"),
            text("Libelle"),
            date("Date"),
            money("Montant"),
            integer("IDModeOperation"),
            integer("IDCategorie"),
            integer("IDAffectation"),
            integer("IDCompte"),
            date("DatePointage"),
            text("FitID"),
            text("ReferencePaiement"),
            text("NumRelevBanque"),
            integer("IDStatutOperation"),
            integer("IDOperationParent"),
            money("SoldePointe"),
            integer("EstParent"),
            text("GUIDCalOpPeriode"),
            integer("IDCheque"),
            integer("IDTiers"),
            integer("IDProjets"),
            integer("EstComplement"),
            integer("IDVerification"),
        ],
    },
    TableSpec { name: "Commentaire", columns: &[integer("IDCommentaire"), text("CommentaireTxt"), integer("IDOperation")] },
    TableSpec {
        name: "CalOpPeriodique",
        columns: &[
            text("GUIDCalOpPeriode"),
            text("Libelle"),
            integer("IDModeOperation"),
            integer("IDCategorie"),
            integer("IDAffectation"),
            integer("IDCompte"),
            integer("IDStatutOperation"),
            money("Montant"),
            date("DateFin"),
            integer("Periode"),
            integer("PeriodeNbrRepete"),
            integer("PeriodeFreq"),
            integer("ModeFinInsertion"),
            date("DateDernOpGen"),
            integer("NbrOpInsert"),
            integer("NbrOpAnterieur"),
            integer("IDOperation"),
            date("DateProchOp"),
            money("MontantInsert"),
            integer("IDTiers"),
            integer("IDProjets"),
        ],
    },
    TableSpec {
        name: "ModeleOperation",
        columns: &[
            integer("IDModeleOperation"),
            text("Libelle"),
            money("Montant"),
            integer("IDModeOperation"),
            integer("IDCategorie"),
            integer("IDAffectation"),
            integer("IDStatutOperation"),
            integer("IDTiers"),
            integer("IDProjets"),
        ],
    },
    TableSpec {
        name: "Budget",
        columns: &[integer("IDBudget"), integer("Annee"), integer("Mois"), integer("IDPosteBudget"), money("Montant")],
    },
];

/// **Les tables qui restent dans la base**, et pourquoi.
pub const LEFT_OUT: &[(&str, &str)] = &[
    ("ParamSecurite", "le mot de passe"),
    ("PiecesJointes", "les pièces jointes"),
    ("Preferences", "les réglages de l'affichage — la devise part dans la table Export"),
    ("Parametres", "les réglages internes de Radinus"),
];

/// Le nom de la petite table ajoutée en tête de chaque export : d'où il vient,
/// quand, et dans quelle devise sont ses montants.
pub const EXPORT_TABLE: &str = "Export";

// --- Ce qu'on lit -------------------------------------------------------------

/// Une valeur, telle que l'export l'écrira.
#[derive(Debug, Clone, PartialEq)]
pub enum Value {
    /// Rien : la cellule reste vide.
    Null,
    Integer(i64),
    /// Un nombre à virgule rangé tel quel par une vieille base : il part tel
    /// quel.
    Real(f64),
    Text(String),
    /// Un montant, **en millionièmes** : chaque format l'écrit en vrai montant
    /// sans jamais passer par un nombre approché (voir [`money_text`]).
    Money(i64),
    Date(NaiveDate),
}

/// Une table lue : son nom, ses colonnes, ses lignes.
#[derive(Debug, Clone, PartialEq)]
pub struct Table {
    pub name: String,
    pub columns: Vec<(String, Kind)>,
    pub rows: Vec<Vec<Value>>,
}

/// Ce qui n'a pas pu être converti, et qui part donc tel qu'il est écrit.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Anomaly {
    pub table: String,
    pub column: String,
    /// La valeur de la première colonne de la ligne — son identifiant.
    pub key: String,
    pub raw: String,
}

/// **L'extrait d'une base** : ce que tous les formats écrivent.
#[derive(Debug, Clone, PartialEq)]
pub struct Extract {
    /// `Export` d'abord, puis les tables de [`TABLES`], dans leur ordre.
    pub tables: Vec<Table>,
    pub anomalies: Vec<Anomaly>,
}

impl Extract {
    /// Combien de lignes de données, hors la table `Export`.
    pub fn row_count(&self) -> usize {
        self.tables.iter().filter(|table| table.name != EXPORT_TABLE).map(|table| table.rows.len()).sum()
    }

    /// Combien de tables de données, hors la table `Export`.
    pub fn table_count(&self) -> usize {
        self.tables.iter().filter(|table| table.name != EXPORT_TABLE).count()
    }
}

/// Ce que dit la table `Export`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Info {
    /// La version de Radinus qui a écrit l'export.
    pub version: String,
    /// Le nom de la base, tel que le sélecteur le montre.
    pub base: String,
    pub date: NaiveDate,
    /// La devise des montants : son code (`EUR`), ou le signe choisi.
    pub currency: String,
}

/// **La devise, écrite pour l'export** : le code ISO quand Radinus le connaît
/// (`EUR`, `XOF`…), le signe du système pour « devise système », le signe
/// tapé pour une devise personnalisée, rien pour « aucune ».
pub fn currency_label(currency: &crate::preferences::Currency, system_sign: &str) -> String {
    use crate::preferences::Currency;
    match currency {
        Currency::System => system_sign.trim().to_string(),
        Currency::NoSign => String::new(),
        Currency::Custom(sign) => sign.trim().to_string(),
        other => other.key().to_string(),
    }
}

/// **Un montant en millionièmes, écrit exactement** : `-57620000` donne
/// `-57.62`, `1500000000` donne `1500.00`, `1234567` donne `1.234567`.
///
/// Jamais de nombre approché : la division se fait en entiers, et l'on garde
/// au moins deux décimales, plus si la base en porte. Le point est le
/// séparateur ; un format qui veut une virgule la met lui-même.
pub fn money_text(micro: i64) -> String {
    let negative = micro < 0;
    let absolute = micro.unsigned_abs();
    let unit = UNIT as u64;
    let whole = absolute / unit;
    let mut fraction = format!("{:06}", absolute % unit);
    while fraction.len() > 2 && fraction.ends_with('0') {
        fraction.pop();
    }
    format!("{}{whole}.{fraction}", if negative { "-" } else { "" })
}

/// Une date de la base, si elle se lit : `2026-07-20`, ou `2026-07-20 10:15:00`
/// (on garde le jour). Vide : `None` sans anomalie.
///
/// **Une date d'avant le 1er mars 1900 ne passe pas pour une date** (étape F
/// de P-74, 19/10/2026) : Excel ne connaît pas les dates d'avant 1900, et
/// compte faux jusqu'au 28 février 1900 (il croit 1900 bissextile). Une telle
/// date, dans des comptes, est une saisie abîmée ; elle part donc telle
/// quelle, en texte, dans tous les formats, et la phrase de fin la compte
/// avec les valeurs illisibles.
fn date_of(text: &str) -> Option<NaiveDate> {
    let day = text.trim().get(..10)?;
    NaiveDate::parse_from_str(day, "%Y-%m-%d")
        .ok()
        .filter(|date| *date >= NaiveDate::from_ymd_opt(1900, 3, 1).expect("une date"))
}

// --- L'ouverture --------------------------------------------------------------

/// Pourquoi une base ne s'ouvre pas pour l'export.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum OpenError {
    /// Il faut un mot de passe, ou celui-ci n'est pas le bon.
    Locked,
    NotARadinusDatabase,
    /// Une base d'une version plus ancienne : l'ouvrir d'abord dans Radinus,
    /// qui la met à jour. L'export, lui, n'écrit jamais.
    TooOld { found: i64, current: i64 },
    /// Une base d'une version plus récente que ce Radinus.
    TooRecent { found: i64, supported: i64 },
    Sqlite(String),
}

impl From<rusqlite::Error> for OpenError {
    fn from(error: rusqlite::Error) -> Self {
        OpenError::Sqlite(error.to_string())
    }
}

/// **Ouvre une base en lecture seule**, pour l'exporter.
///
/// Le fichier est ouvert par SQLite en mode lecture seule : aucune écriture
/// n'est possible, ni de nous, ni d'une mise à jour de schéma. La clé, s'il y
/// en a une, est donnée avant toute lecture ; la base doit être exactement de
/// la version de ce Radinus.
pub fn open_read_only(path: &std::path::Path, password: Option<&str>) -> Result<Connection, OpenError> {
    let conn = Connection::open_with_flags(
        path,
        OpenFlags::SQLITE_OPEN_READ_ONLY | OpenFlags::SQLITE_OPEN_NO_MUTEX | OpenFlags::SQLITE_OPEN_URI,
    )?;
    if let Some(password) = password.filter(|password| !password.is_empty()) {
        crate::database::lock::unlock(&conn, password)?;
    }
    if !crate::database::lock::readable(&conn) {
        return Err(OpenError::Locked);
    }
    let _ = conn.execute_batch("PRAGMA busy_timeout = 5000;");
    let has_parametres: bool = conn.query_row(
        "SELECT EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'Parametres')",
        [],
        |row| row.get(0),
    )?;
    if !has_parametres {
        return Err(OpenError::NotARadinusDatabase);
    }
    let found: i64 = conn
        .query_row("SELECT VerDataBase FROM Parametres WHERE IDParametres = 1", [], |row| row.get(0))
        .map_err(|_| OpenError::NotARadinusDatabase)?;
    let current = crate::database::schema::CURRENT_SCHEMA_VERSION;
    if found > current {
        return Err(OpenError::TooRecent { found, supported: current });
    }
    if found < current {
        return Err(OpenError::TooOld { found, current });
    }
    Ok(conn)
}

// --- La lecture ---------------------------------------------------------------

/// **Lit toute la base** selon le catalogue, et la table `Export` en tête.
///
/// Les lignes sortent dans l'ordre de leur identifiant, pour qu'un même export
/// refait donne le même fichier. Ne lit que ce que le catalogue nomme : une
/// colonne ajoutée un jour sans y être rangée ne partirait pas — c'est le test
/// du catalogue qui l'empêche.
pub fn read(conn: &Connection, info: &Info) -> rusqlite::Result<Extract> {
    let mut tables = vec![export_table(info)];
    let mut anomalies = Vec::new();
    for spec in TABLES {
        let names: Vec<&str> = spec.columns.iter().map(|column| column.name).collect();
        let sql = format!(
            "SELECT {} FROM \"{}\" ORDER BY \"{}\"",
            names.iter().map(|name| format!("\"{name}\"")).collect::<Vec<_>>().join(", "),
            spec.name,
            spec.columns[0].name
        );
        let mut statement = conn.prepare(&sql)?;
        let mut rows = statement.query([])?;
        let mut read_rows = Vec::new();
        while let Some(row) = rows.next()? {
            let mut values = Vec::with_capacity(spec.columns.len());
            for (index, column) in spec.columns.iter().enumerate() {
                values.push(convert(row.get_ref(index)?, column.kind));
            }
            // Une date qu'on ne sait pas lire part telle quelle, et se signale.
            for (index, column) in spec.columns.iter().enumerate() {
                if column.kind == Kind::Date || column.kind == Kind::Money {
                    if let Value::Text(raw) = &values[index] {
                        anomalies.push(Anomaly {
                            table: spec.name.to_string(),
                            column: column.name.to_string(),
                            key: plain(&values[0]),
                            raw: raw.clone(),
                        });
                    }
                }
            }
            read_rows.push(values);
        }
        tables.push(Table {
            name: spec.name.to_string(),
            columns: spec.columns.iter().map(|column| (column.name.to_string(), column.kind)).collect(),
            rows: read_rows,
        });
    }
    Ok(Extract { tables, anomalies })
}

/// Une valeur de la base, convertie selon sa colonne.
fn convert(value: ValueRef<'_>, kind: Kind) -> Value {
    match (value, kind) {
        (ValueRef::Null, _) => Value::Null,
        (ValueRef::Integer(number), Kind::Money) => Value::Money(number),
        (ValueRef::Integer(number), _) => Value::Integer(number),
        (ValueRef::Real(number), _) => Value::Real(number),
        (ValueRef::Text(bytes), Kind::Date) => {
            let text = String::from_utf8_lossy(bytes).to_string();
            if text.trim().is_empty() {
                Value::Null
            } else {
                date_of(&text).map_or(Value::Text(text), Value::Date)
            }
        }
        (ValueRef::Text(bytes), _) => Value::Text(String::from_utf8_lossy(bytes).to_string()),
        (ValueRef::Blob(bytes), _) => {
            Value::Text(bytes.iter().map(|byte| format!("{byte:02x}")).collect::<String>())
        }
    }
}

/// Une valeur en texte simple, pour nommer une ligne dans un signalement.
pub fn plain(value: &Value) -> String {
    match value {
        Value::Null => String::new(),
        Value::Integer(number) => number.to_string(),
        Value::Real(number) => number.to_string(),
        Value::Text(text) => text.clone(),
        Value::Money(micro) => money_text(*micro),
        Value::Date(date) => date.format("%Y-%m-%d").to_string(),
    }
}

/// La table `Export` : une ligne, qui dit d'où vient l'export.
fn export_table(info: &Info) -> Table {
    let columns = ["Logiciel", "Version", "Base", "DateExport", "Devise", "VersionSchema"];
    Table {
        name: EXPORT_TABLE.to_string(),
        columns: columns
            .iter()
            .map(|name| {
                let kind = match *name {
                    "DateExport" => Kind::Date,
                    "VersionSchema" => Kind::Integer,
                    _ => Kind::Text,
                };
                (name.to_string(), kind)
            })
            .collect(),
        rows: vec![vec![
            Value::Text("Radinus".into()),
            Value::Text(info.version.clone()),
            Value::Text(info.base.clone()),
            Value::Date(info.date),
            Value::Text(info.currency.clone()),
            Value::Integer(crate::database::schema::CURRENT_SCHEMA_VERSION),
        ]],
    }
}

// --- Écrire sans jamais laisser un fichier à moitié -----------------------------

/// Le fichier provisoire d'un fichier : à côté de lui, même extension (le
/// tableur la lit pour choisir son format), caché par son point.
fn provisional(path: &Path) -> PathBuf {
    let name = path.file_name().map(|name| name.to_string_lossy().to_string()).unwrap_or_default();
    path.with_file_name(format!(".~{name}"))
}

/// **Écrit, puis remplace.** Le fichier est d'abord écrit à côté, puis mis à
/// sa place d'un seul geste : un disque plein ou une coupure en plein export
/// laisse l'ancien fichier, ou rien — jamais un fichier tronqué qu'on croirait
/// complet.
fn write_safely(path: &Path, write: impl FnOnce(&Path) -> std::io::Result<()>) -> std::io::Result<()> {
    let temporary = provisional(path);
    let written = write(&temporary).and_then(|()| std::fs::rename(&temporary, path));
    if written.is_err() {
        let _ = std::fs::remove_file(&temporary);
    }
    written
}

/// Écrit des octets **sans jamais laisser un fichier à moitié** : voir
/// [`write_safely`]. Pour les exports qui fabriquent leur texte eux-mêmes.
pub fn write_bytes(path: &Path, bytes: &[u8]) -> std::io::Result<()> {
    write_safely(path, |temporary| std::fs::write(temporary, bytes))
}

// --- Les tableurs : Excel et Calc --------------------------------------------

/// Un seul fichier (une table par onglet), ou un fichier par table.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Layout {
    OneFile,
    PerTable,
}

/// Une valeur, en cellule de tableur. **Un montant est un nombre**, sans
/// symbole — la devise est dans la table `Export` —, une date est une date.
fn cell_of(value: &Value) -> SheetCell {
    match value {
        Value::Null => SheetCell::empty(),
        Value::Integer(number) => SheetCell::number(*number as f64),
        Value::Real(number) => SheetCell::number(*number),
        Value::Text(text) => SheetCell::text(text.clone()),
        Value::Money(micro) => SheetCell::number(*micro as f64 / UNIT as f64),
        Value::Date(date) => SheetCell::date(*date),
    }
}

/// **Une table en feuille** : l'onglet porte le nom de la table, la première
/// ligne les noms des champs, les suivantes les données. Rien d'autre — pas de
/// ligne de contexte, qui décalerait les noms des champs.
pub fn sheet_of(table: &Table) -> Sheet {
    let mut sheet = Sheet::new(table.name.clone());
    sheet.header_rows = 1;
    sheet.rows.push(table.columns.iter().map(|(name, _)| SheetCell::text(name.clone())).collect());
    for row in &table.rows {
        sheet.rows.push(row.iter().map(cell_of).collect());
    }
    sheet.widths = table.columns.iter().map(|(name, _)| (name.chars().count() as f64 + 2.0).max(10.0)).collect();
    sheet
}

/// **Un seul classeur**, une table par onglet. `.xlsx` ou `.ods` selon
/// l'extension du nom.
pub fn write_workbook(extract: &Extract, path: &Path) -> std::io::Result<()> {
    let sheets: Vec<Sheet> = extract.tables.iter().map(sheet_of).collect();
    write_safely(path, |temporary| crate::sheets::write_book(&sheets, temporary))
}

/// **Un classeur par table**, dans `folder` : `Operation.xlsx`, `Compte.xlsx`…
/// Le nom du fichier est exactement celui de la table, comme l'onglet.
pub fn write_workbooks(extract: &Extract, folder: &Path, extension: &str) -> std::io::Result<Vec<PathBuf>> {
    std::fs::create_dir_all(folder)?;
    let mut written = Vec::new();
    for table in &extract.tables {
        let path = folder.join(format!("{}.{extension}", table.name));
        let sheet = sheet_of(table);
        write_safely(&path, |temporary| crate::sheets::write_book(std::slice::from_ref(&sheet), temporary))?;
        written.push(path);
    }
    Ok(written)
}

// --- Le CSV -------------------------------------------------------------------

/// Les deux réglages du CSV, choisis par l'utilisateur.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct CsvOptions {
    /// `-57,62` plutôt que `-57.62`.
    pub decimal_comma: bool,
    /// **Tous** les champs entre guillemets — ou **aucun**. Jamais un mélange :
    /// un logiciel qui intègre les données doit pouvoir compter sur une seule
    /// règle (Fabrice, 19/10/2026).
    pub quote_all: bool,
}

/// Ce que le CSV a dû changer dans les valeurs, pour le dire.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct Replacements {
    /// `;` devenus `!` — « je ne veux pas de point-virgule dans les valeurs ».
    pub semicolons: usize,
    /// Retours à la ligne devenus espaces : une ligne du fichier est une ligne
    /// de la table.
    pub line_breaks: usize,
    /// Sans guillemets seulement : `"` devenus `'`. Un guillemet en tête de
    /// valeur ferait croire à la plupart des lecteurs qu'un champ entre
    /// guillemets commence, et la ligne entière serait mal lue.
    pub quotes: usize,
}

impl Replacements {
    pub fn total(&self) -> usize {
        self.semicolons + self.line_breaks + self.quotes
    }

    fn add(&mut self, other: Replacements) {
        self.semicolons += other.semicolons;
        self.line_breaks += other.line_breaks;
        self.quotes += other.quotes;
    }
}

/// Un texte rendu sûr pour une cellule CSV, et ce qu'il a fallu y changer.
fn csv_text(text: &str, options: CsvOptions, replaced: &mut Replacements) -> String {
    let mut safe = String::with_capacity(text.len());
    let mut chars = text.chars().peekable();
    while let Some(c) = chars.next() {
        match c {
            ';' => {
                replaced.semicolons += 1;
                safe.push('!');
            }
            '\r' | '\n' => {
                // `\r\n` est un seul retour à la ligne.
                if c == '\r' && chars.peek() == Some(&'\n') {
                    chars.next();
                }
                replaced.line_breaks += 1;
                safe.push(' ');
            }
            '"' if !options.quote_all => {
                replaced.quotes += 1;
                safe.push('\'');
            }
            '"' => safe.push_str("\"\""),
            other => safe.push(other),
        }
    }
    if options.quote_all {
        format!("\"{safe}\"")
    } else {
        safe
    }
}

/// Un nombre décimal, au point ou à la virgule.
fn decimal(text: String, options: CsvOptions) -> String {
    if options.decimal_comma {
        text.replace('.', ",")
    } else {
        text
    }
}

/// Une valeur en champ CSV.
fn csv_field(value: &Value, options: CsvOptions, replaced: &mut Replacements) -> String {
    let bare = match value {
        Value::Null => String::new(),
        Value::Integer(number) => number.to_string(),
        Value::Real(number) => decimal(number.to_string(), options),
        Value::Money(micro) => decimal(money_text(*micro), options),
        Value::Date(date) => date.format("%Y-%m-%d").to_string(),
        Value::Text(text) => return csv_text(text, options, replaced),
    };
    if options.quote_all {
        format!("\"{bare}\"")
    } else {
        bare
    }
}

/// **Une table en CSV** : la première ligne porte les noms des champs, séparés
/// par des points-virgules ; chaque ligne suivante, un enregistrement. UTF-8
/// avec sa marque — sans elle, Excel lit « Café » en « CafÃ© » —, fins de
/// ligne `\r\n` comme le veut la norme du format.
pub fn csv_of(table: &Table, options: CsvOptions, replaced: &mut Replacements) -> String {
    let mut written = String::from("\u{feff}");
    let header: Vec<String> = table
        .columns
        .iter()
        .map(|(name, _)| csv_field(&Value::Text(name.clone()), options, replaced))
        .collect();
    written.push_str(&header.join(";"));
    written.push_str("\r\n");
    for row in &table.rows {
        let fields: Vec<String> = row.iter().map(|value| csv_field(value, options, replaced)).collect();
        written.push_str(&fields.join(";"));
        written.push_str("\r\n");
    }
    written
}

/// **Un fichier CSV par table**, dans `folder` : `Operation.csv`… Rend les
/// fichiers écrits et ce qu'il a fallu changer dans les valeurs.
pub fn write_csv_files(
    extract: &Extract,
    folder: &Path,
    options: CsvOptions,
) -> std::io::Result<(Vec<PathBuf>, Replacements)> {
    std::fs::create_dir_all(folder)?;
    let mut written = Vec::new();
    let mut replaced = Replacements::default();
    for table in &extract.tables {
        let mut here = Replacements::default();
        let text = csv_of(table, options, &mut here);
        let path = folder.join(format!("{}.csv", table.name));
        write_safely(&path, |temporary| std::fs::write(temporary, text.as_bytes()))?;
        // Les noms des champs n'ont rien à remplacer : seules les valeurs
        // comptent, et c'est ce que `here` a vu.
        replaced.add(here);
        written.push(path);
    }
    Ok((written, replaced))
}

// --- JSON et XML ----------------------------------------------------------------
//
// L'en-tête dit d'où vient le fichier — logiciel, version, base, date, devise —,
// puis chaque table sous son nom, ses lignes, et les noms de champs de la
// base. **Un fichier par table garde exactement la même forme**, avec une seule
// table : un programme écrit pour lire l'un lit l'autre sans changement. La
// table `Export` n'y est pas répétée : l'en-tête la porte.

/// Les tables de données, sans `Export`.
fn data_tables(extract: &Extract) -> impl Iterator<Item = &Table> {
    extract.tables.iter().filter(|table| table.name != EXPORT_TABLE)
}

/// Une valeur en JSON. Un montant est un nombre écrit exactement (`-57.62`),
/// une date une chaîne `AAAA-MM-JJ`, un vide `null`.
fn json_value(value: &Value) -> String {
    let quoted = |text: &str| serde_json::to_string(text).unwrap_or_else(|_| "\"\"".to_string());
    match value {
        Value::Null => "null".to_string(),
        Value::Integer(number) => number.to_string(),
        Value::Real(number) if number.is_finite() => number.to_string(),
        Value::Real(_) => "null".to_string(),
        Value::Text(text) => quoted(text),
        Value::Money(micro) => money_text(*micro),
        Value::Date(date) => quoted(&date.format("%Y-%m-%d").to_string()),
    }
}

/// **Le JSON, écrit à la main** pour garder l'ordre des champs de la base —
/// `serde_json` trierait les clefs par ordre alphabétique. Il ne sert qu'à
/// échapper chaque chaîne, ce qu'il fait parfaitement.
pub fn json_of<'a>(info: &Info, tables: impl Iterator<Item = &'a Table>) -> String {
    let quoted = |text: &str| serde_json::to_string(text).unwrap_or_else(|_| "\"\"".to_string());
    let mut written = String::from("{\n");
    written.push_str("  \"logiciel\": \"Radinus\",\n");
    written.push_str(&format!("  \"version\": {},\n", quoted(&info.version)));
    written.push_str(&format!("  \"base\": {},\n", quoted(&info.base)));
    written.push_str(&format!("  \"export\": {},\n", quoted(&info.date.format("%Y-%m-%d").to_string())));
    written.push_str(&format!("  \"devise\": {},\n", quoted(&info.currency)));
    written.push_str("  \"tables\": {");
    let mut first_table = true;
    for table in tables {
        written.push_str(if first_table { "\n" } else { ",\n" });
        first_table = false;
        written.push_str(&format!("    {}: [", quoted(&table.name)));
        for (index, row) in table.rows.iter().enumerate() {
            written.push_str(if index == 0 { "\n" } else { ",\n" });
            let fields: Vec<String> = table
                .columns
                .iter()
                .zip(row)
                .map(|((name, _), value)| format!("{}: {}", quoted(name), json_value(value)))
                .collect();
            written.push_str(&format!("      {{ {} }}", fields.join(", ")));
        }
        written.push_str(if table.rows.is_empty() { "]" } else { "\n    ]" });
    }
    written.push_str(if first_table { "}\n" } else { "\n  }\n" });
    written.push_str("}\n");
    written
}

/// Un texte rendu sûr pour le XML : les cinq entités, et les caractères de
/// contrôle que le XML interdit — un seul suffirait à rendre le fichier
/// illisible d'un bout à l'autre. Ils deviennent « � » ; le saut de ligne et la
/// tabulation, permis, restent.
fn xml_char(c: char) -> char {
    if xml_forbids(c) {
        '\u{FFFD}'
    } else {
        c
    }
}

/// Les caractères que le XML 1.0 ne peut porter d'aucune façon, pas même
/// en référence `&#…;` — la règle des classeurs, qui sont du XML aussi.
fn xml_forbids(c: char) -> bool {
    crate::sheets::xml_forbids(c)
}

/// **Combien de caractères le XML devra remplacer** : la phrase de fin le dit,
/// comme elle dit les remplacements du CSV.
pub fn xml_replacements(extract: &Extract, info: &Info) -> usize {
    let count = |text: &str| text.chars().filter(|c| xml_forbids(*c)).count();
    count(&info.base)
        + data_tables(extract)
            .flat_map(|table| table.rows.iter().flatten())
            .map(|value| match value {
                Value::Text(text) => count(text),
                _ => 0,
            })
            .sum::<usize>()
}

fn xml_text(text: &str) -> String {
    let mut safe = String::with_capacity(text.len());
    for c in text.chars() {
        match c {
            '&' => safe.push_str("&amp;"),
            '<' => safe.push_str("&lt;"),
            '>' => safe.push_str("&gt;"),
            '"' => safe.push_str("&quot;"),
            '\'' => safe.push_str("&apos;"),
            '\t' | '\n' => safe.push(c),
            '\r' => safe.push_str("&#13;"),
            c => safe.push(xml_char(c)),
        }
    }
    safe
}

/// **Le XML** : `<radinus>` et son en-tête en attributs, une `<table
/// name="…">` par table, une `<row>` par ligne, une balise par champ — les noms
/// de champs de la base sont des noms de balises valides. Un champ vide (NULL)
/// n'est pas écrit ; un texte vide l'est, en balise vide.
pub fn xml_of<'a>(info: &Info, tables: impl Iterator<Item = &'a Table>) -> String {
    let mut written = String::from("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
    written.push_str(&format!(
        "<radinus logiciel=\"Radinus\" version=\"{}\" base=\"{}\" export=\"{}\" devise=\"{}\">\n",
        xml_text(&info.version),
        xml_text(&info.base),
        info.date.format("%Y-%m-%d"),
        xml_text(&info.currency)
    ));
    for table in tables {
        written.push_str(&format!("  <table name=\"{}\">\n", xml_text(&table.name)));
        for row in &table.rows {
            written.push_str("    <row>");
            for ((name, _), value) in table.columns.iter().zip(row) {
                let text = match value {
                    Value::Null => continue,
                    Value::Integer(number) => number.to_string(),
                    Value::Real(number) => number.to_string(),
                    Value::Text(text) => xml_text(text),
                    Value::Money(micro) => money_text(*micro),
                    Value::Date(date) => date.format("%Y-%m-%d").to_string(),
                };
                if text.is_empty() {
                    written.push_str(&format!("<{name}/>"));
                } else {
                    written.push_str(&format!("<{name}>{text}</{name}>"));
                }
            }
            written.push_str("</row>\n");
        }
        written.push_str("  </table>\n");
    }
    written.push_str("</radinus>\n");
    written
}

/// Le JSON ou le XML, selon l'extension.
fn document_of<'a>(info: &Info, tables: impl Iterator<Item = &'a Table>, extension: &str) -> String {
    if extension.eq_ignore_ascii_case("xml") {
        xml_of(info, tables)
    } else {
        json_of(info, tables)
    }
}

/// **Un seul fichier JSON ou XML**, toutes les tables dedans.
pub fn write_document(extract: &Extract, info: &Info, path: &Path) -> std::io::Result<()> {
    let extension = path.extension().and_then(|extension| extension.to_str()).unwrap_or_default();
    let text = document_of(info, data_tables(extract), extension);
    write_safely(path, |temporary| std::fs::write(temporary, text.as_bytes()))
}

/// **Un fichier JSON ou XML par table**, dans `folder`, de la même forme.
pub fn write_documents(
    extract: &Extract,
    info: &Info,
    folder: &Path,
    extension: &str,
) -> std::io::Result<Vec<PathBuf>> {
    std::fs::create_dir_all(folder)?;
    let mut written = Vec::new();
    for table in data_tables(extract) {
        let path = folder.join(format!("{}.{extension}", table.name));
        let text = document_of(info, std::iter::once(table), extension);
        write_safely(&path, |temporary| std::fs::write(temporary, text.as_bytes()))?;
        written.push(path);
    }
    Ok(written)
}

// --- Le script SQL --------------------------------------------------------------
//
// Un SQL simple, que SQLite, MySQL/MariaDB et PostgreSQL acceptent tel quel :
// noms sans guillemets (aucun n'est un mot réservé), types courants, une
// clef primaire par table, **pas de contraintes de liens** — une vieille base
// peut citer une catégorie disparue, et l'import ne doit pas échouer pour une
// ligne —, et le tout entre `BEGIN` et `COMMIT` : l'import réussit en entier
// ou pas du tout.

/// Le type SQL d'une colonne. Une clef primaire en texte prend `VARCHAR`, que
/// MySQL accepte en clef, là où il refuse `TEXT`.
fn sql_type(kind: Kind, primary: bool) -> &'static str {
    match (kind, primary) {
        (Kind::Integer, _) => "INTEGER",
        (Kind::Text, true) => "VARCHAR(255)",
        (Kind::Text, false) => "TEXT",
        (Kind::Money, _) => "DECIMAL(19,6)",
        (Kind::Date, _) => "DATE",
    }
}

/// Une valeur en littéral SQL.
fn sql_value(value: &Value) -> String {
    match value {
        Value::Null => "NULL".to_string(),
        Value::Integer(number) => number.to_string(),
        Value::Real(number) if number.is_finite() => number.to_string(),
        Value::Real(_) => "NULL".to_string(),
        Value::Text(text) => format!("'{}'", text.replace('\'', "''")),
        Value::Money(micro) => money_text(*micro),
        Value::Date(date) => format!("'{}'", date.format("%Y-%m-%d")),
    }
}

/// Les colonnes de date ou de montant qui portent une valeur illisible,
/// gardée en texte : déclarées `DATE`, elles feraient échouer tout l'import
/// dans PostgreSQL ou MySQL pour une seule vieille date. Elles sont donc
/// déclarées en texte, et le script le dit.
fn columns_kept_as_text(table: &Table) -> Vec<usize> {
    (0..table.columns.len())
        .filter(|&column| matches!(table.columns[column].1, Kind::Date | Kind::Money))
        .filter(|&column| table.rows.iter().any(|row| matches!(row[column], Value::Text(_))))
        .collect()
}

/// La création d'une table : ses colonnes, leurs types, sa clef primaire (la
/// première colonne, comme dans la base).
fn sql_create(table: &Table) -> String {
    let as_text = columns_kept_as_text(table);
    let mut written = String::new();
    for &column in &as_text {
        written.push_str(&format!(
            "-- {}.{} : des valeurs illisibles y sont gardées telles quelles ; la colonne est donc en texte.\n",
            table.name, table.columns[column].0
        ));
    }
    let columns: Vec<String> = table
        .columns
        .iter()
        .enumerate()
        .map(|(index, (name, kind))| {
            let primary = index == 0;
            let kind = if as_text.contains(&index) { Kind::Text } else { *kind };
            format!("  {name} {}{}", sql_type(kind, primary), if primary { " PRIMARY KEY" } else { "" })
        })
        .collect();
    written.push_str(&format!("CREATE TABLE {} (\n{}\n);\n", table.name, columns.join(",\n")));
    written
}

/// **Le script SQL** des tables données, `Export` comprise : une base SQL n'a
/// pas d'en-tête où la mettre.
pub fn sql_of<'a>(info: &Info, tables: impl Iterator<Item = &'a Table>) -> String {
    let mut written = format!(
        "-- Radinus {} — exportation de la base « {} » du {} — devise : {}\n\
         -- Montants en nombres décimaux, dates au format AAAA-MM-JJ.\n\
         -- MySQL/MariaDB : un texte peut contenir une barre oblique inverse ou une fin de\n\
         -- ligne Windows ; importer avec sql_mode = 'NO_BACKSLASH_ESCAPES' et, en ligne de\n\
         -- commande, « mysql --binary-mode » pour que tout reste tel quel.\n\n\
         BEGIN;\n\n",
        info.version.replace('\n', " "),
        info.base.replace('\n', " "),
        info.date.format("%Y-%m-%d"),
        info.currency.replace('\n', " ")
    );
    for table in tables {
        written.push_str(&sql_create(table));
        let names: Vec<&str> = table.columns.iter().map(|(name, _)| name.as_str()).collect();
        for row in &table.rows {
            let values: Vec<String> = row.iter().map(sql_value).collect();
            written.push_str(&format!(
                "INSERT INTO {} ({}) VALUES ({});\n",
                table.name,
                names.join(", "),
                values.join(", ")
            ));
        }
        written.push('\n');
    }
    written.push_str("COMMIT;\n");
    written
}

/// **Un seul script SQL**, toutes les tables.
pub fn write_sql(extract: &Extract, info: &Info, path: &Path) -> std::io::Result<()> {
    let text = sql_of(info, extract.tables.iter());
    write_safely(path, |temporary| std::fs::write(temporary, text.as_bytes()))
}

/// **Un script SQL par table**, dans `folder`, chacun complet.
pub fn write_sql_files(extract: &Extract, info: &Info, folder: &Path) -> std::io::Result<Vec<PathBuf>> {
    std::fs::create_dir_all(folder)?;
    let mut written = Vec::new();
    for table in &extract.tables {
        let path = folder.join(format!("{}.sql", table.name));
        let text = sql_of(info, std::iter::once(table));
        write_safely(&path, |temporary| std::fs::write(temporary, text.as_bytes()))?;
        written.push(path);
    }
    Ok(written)
}

// --- La base SQLite autonome ----------------------------------------------------

/// **Une base SQLite ordinaire**, sans mot de passe, avec les mêmes tables que
/// le script SQL et les mêmes conversions. Des dizaines d'outils l'ouvrent,
/// Access compris par un pilote ODBC.
pub fn write_sqlite(extract: &Extract, path: &Path) -> std::io::Result<()> {
    let failed = |error: rusqlite::Error| std::io::Error::other(error.to_string());
    write_safely(path, |temporary| {
        let _ = std::fs::remove_file(temporary);
        let mut conn = Connection::open(temporary).map_err(failed)?;
        let transaction = conn.transaction().map_err(failed)?;
        for table in &extract.tables {
            transaction.execute_batch(&sql_create(table)).map_err(failed)?;
            let marks = vec!["?"; table.columns.len()].join(", ");
            let names: Vec<&str> = table.columns.iter().map(|(name, _)| name.as_str()).collect();
            let mut insert = transaction
                .prepare(&format!("INSERT INTO {} ({}) VALUES ({marks})", table.name, names.join(", ")))
                .map_err(failed)?;
            for row in &table.rows {
                let values: Vec<rusqlite::types::Value> = row
                    .iter()
                    .map(|value| match value {
                        Value::Null => rusqlite::types::Value::Null,
                        Value::Integer(number) => rusqlite::types::Value::Integer(*number),
                        Value::Real(number) => rusqlite::types::Value::Real(*number),
                        Value::Text(text) => rusqlite::types::Value::Text(text.clone()),
                        Value::Money(micro) => rusqlite::types::Value::Real(*micro as f64 / UNIT as f64),
                        Value::Date(date) => rusqlite::types::Value::Text(date.format("%Y-%m-%d").to_string()),
                    })
                    .collect();
                insert.execute(rusqlite::params_from_iter(values)).map_err(failed)?;
            }
        }
        transaction.commit().map_err(failed)?;
        // Le fichier doit être complet avant d'être mis à sa place.
        conn.close().map_err(|(_, error)| failed(error))
    })
}

// --- L'assistant : un export complet ---------------------------------------------

/// Les formats de l'assistant.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Format {
    Xlsx,
    Ods,
    Csv,
    Json,
    Xml,
    Sql,
    Sqlite,
    Qif,
    Ofx,
}

impl Format {
    pub const ALL: [Format; 9] = [
        Format::Xlsx,
        Format::Ods,
        Format::Csv,
        Format::Json,
        Format::Xml,
        Format::Sql,
        Format::Sqlite,
        Format::Qif,
        Format::Ofx,
    ];

    pub fn key(self) -> &'static str {
        self.extension()
    }

    pub fn from_key(key: &str) -> Option<Format> {
        Format::ALL.into_iter().find(|format| format.key() == key)
    }

    pub fn extension(self) -> &'static str {
        match self {
            Format::Xlsx => "xlsx",
            Format::Ods => "ods",
            Format::Csv => "csv",
            Format::Json => "json",
            Format::Xml => "xml",
            Format::Sql => "sql",
            Format::Sqlite => "sqlite",
            Format::Qif => "qif",
            Format::Ofx => "ofx",
        }
    }

    /// Le format laisse-t-il choisir entre un fichier et un fichier par table ?
    pub fn has_layout_choice(self) -> bool {
        matches!(self, Format::Xlsx | Format::Ods | Format::Json | Format::Xml | Format::Sql)
    }

    /// Avec ce réglage, l'export va-t-il dans un dossier (plusieurs fichiers)
    /// ou dans un seul fichier ?
    pub fn writes_a_folder(self, layout: Layout) -> bool {
        match self {
            Format::Csv | Format::Qif | Format::Ofx => true,
            Format::Sqlite => false,
            _ => layout == Layout::PerTable,
        }
    }

    /// Un format pour passer dans un autre logiciel de comptes, qui ne garde
    /// pas tout.
    pub fn is_lossy(self) -> bool {
        matches!(self, Format::Qif | Format::Ofx)
    }
}

/// Ce que l'utilisateur a choisi dans l'assistant.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Request {
    pub format: Format,
    pub layout: Layout,
    pub csv: CsvOptions,
    pub qif_order: crate::qif_import::DateOrder,
}

/// Ce que l'export a écrit, pour le dire.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct Outcome {
    pub tables: usize,
    pub rows: usize,
    pub files: usize,
    pub replacements: Replacements,
    /// Les caractères de contrôle que le XML ne peut porter — `.xlsx`, `.ods`
    /// et `.xml` —, remplacés par « � ».
    pub controls: usize,
    /// Les textes coupés à 32 767 caractères, la limite d'Excel (`.xlsx`
    /// seulement : les autres formats les gardent entiers).
    pub excel_cut: usize,
    /// Les valeurs illisibles gardées telles quelles.
    pub anomalies: usize,
    /// Pour le QIF et l'OFX : comptes, opérations, laissées de côté, ajustées.
    pub accounts: Option<crate::account_export::Report>,
}

/// **Le nom d'un export** : « Comptes famille - export 2026-10-19 ». Le nom de
/// la base, débarrassé de ce que les systèmes refusent, et la date
/// année-mois-jour, pour que les exports se rangent dans l'ordre.
pub fn export_stem(base: &str, date: NaiveDate) -> String {
    format!("{} - export {}", crate::account_export::file_name(base, "Radinus"), date.format("%Y-%m-%d"))
}

/// **Fait l'export demandé**, dans `destination` — le fichier, ou le dossier à
/// créer selon le format.
pub fn export(extract: &Extract, info: &Info, request: Request, destination: &Path) -> std::io::Result<Outcome> {
    let mut outcome = Outcome {
        tables: extract.table_count(),
        rows: extract.row_count(),
        anomalies: extract.anomalies.len(),
        ..Outcome::default()
    };
    let folder = request.format.writes_a_folder(request.layout);
    let extension = request.format.extension();
    if matches!(request.format, Format::Xlsx | Format::Ods | Format::Xml) {
        outcome.controls = xml_replacements(extract, info);
    }
    if request.format == Format::Xlsx {
        outcome.excel_cut = extract
            .tables
            .iter()
            .flat_map(|table| table.rows.iter().flatten())
            .filter(|value| matches!(value, Value::Text(text) if crate::sheets::too_long_for_excel(text)))
            .count();
    }
    outcome.files = match (request.format, folder) {
        (Format::Xlsx | Format::Ods, false) => write_workbook(extract, destination).map(|()| 1)?,
        (Format::Xlsx | Format::Ods, true) => write_workbooks(extract, destination, extension)?.len(),
        (Format::Json | Format::Xml, false) => write_document(extract, info, destination).map(|()| 1)?,
        (Format::Json | Format::Xml, true) => write_documents(extract, info, destination, extension)?.len(),
        (Format::Sql, false) => write_sql(extract, info, destination).map(|()| 1)?,
        (Format::Sql, true) => write_sql_files(extract, info, destination)?.len(),
        (Format::Sqlite, _) => write_sqlite(extract, destination).map(|()| 1)?,
        (Format::Csv, _) => {
            let (files, replaced) = write_csv_files(extract, destination, request.csv)?;
            outcome.replacements = replaced;
            files.len()
        }
        (Format::Qif, _) => {
            let (files, report) =
                crate::account_export::write_qif_files(extract, destination, request.qif_order, info.date)?;
            outcome.accounts = Some(report);
            files.len()
        }
        (Format::Ofx, _) => {
            let (files, report) = crate::account_export::write_ofx_files(extract, destination, info.date)?;
            outcome.accounts = Some(report);
            files.len()
        }
    };
    Ok(outcome)
}

/// **La phrase de fin**, dans la langue de l'utilisateur : ce qui a été
/// exporté, puis tout ce qui a été laissé de côté ou changé — rien en
/// silence.
pub fn outcome_sentence(outcome: &Outcome, base: &str, language: crate::i18n::Language) -> String {
    use crate::i18n;
    let mut said = Vec::new();
    match &outcome.accounts {
        Some(report) => said.push(i18n::message_of(
            language,
            "base-export-done-accounts",
            &[("base", base)],
            &[("accounts", report.accounts as i64), ("operations", report.operations as i64)],
        )),
        None => said.push(i18n::message_of(
            language,
            "base-export-done",
            &[("base", base)],
            &[("tables", outcome.tables as i64), ("rows", outcome.rows as i64)],
        )),
    }
    let mut add = |key: &str, count: usize| {
        if count > 0 {
            said.push(i18n::message_of(language, key, &[], &[("count", count as i64)]));
        }
    };
    add("base-export-done-replacements", outcome.replacements.total());
    add("base-export-done-controls", outcome.controls);
    add("base-export-done-excel-cut", outcome.excel_cut);
    if outcome.accounts.is_none() {
        add("base-export-done-anomalies", outcome.anomalies);
    }
    if let Some(report) = outcome.accounts {
        add("base-export-done-planned", report.planned);
        add("base-export-done-undated", report.undated);
        add("base-export-done-adjusted", report.adjusted);
    }
    said.join(" ")
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::BTreeSet;
    use std::sync::atomic::{AtomicU32, Ordering};

    static COUNTER: AtomicU32 = AtomicU32::new(0);

    fn scratch(label: &str) -> std::path::PathBuf {
        let n = COUNTER.fetch_add(1, Ordering::SeqCst);
        let dir = std::env::temp_dir().join(format!("radinus_export_{label}_{}_{n}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        dir.join("radinus.sqlite")
    }

    fn info() -> Info {
        Info {
            version: "3.0.0".into(),
            base: "Comptes famille".into(),
            date: NaiveDate::from_ymd_opt(2026, 10, 19).unwrap(),
            currency: "EUR".into(),
        }
    }

    /// Une base neuve, avec un compte et quelques opérations choisies pour
    /// éprouver les conversions.
    fn sample(label: &str) -> std::path::PathBuf {
        let path = scratch(label);
        let conn = crate::database::create_new_database(&path).unwrap();
        conn.execute_batch(
            "INSERT INTO Compte (IDCompte, ReportPointe, ReportEngage, ReportPrevu, Libelle,
                IDTypeCompte, IDBanques, SoldeBanque, SoldeReel, SoldeFinal, NomTitulaire,
                AdresseTitulaire, COBCodeBanque, COBCodeGuichet, COBNumCompte, COBClefRIB,
                COBIBAN, DateOuverture, DateCloture, AdresseAgenceBank, COBBIC,
                NumProchCheque, CompteCloture, Devise)
             VALUES (1, 100000000, 0, 0, 'CCP', 1, 21, 1442380000, 0, 0, 'Léa', '', '', '', '', '', '',
                     '2020-01-15', '', '', '', 0, 0, 'EUR');
             INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDModeOperation, IDCategorie,
                IDAffectation, IDCompte, DatePointage, FitID, ReferencePaiement, NumRelevBanque,
                IDStatutOperation, IDOperationParent, SoldePointe, EstParent, GUIDCalOpPeriode,
                IDCheque, IDTiers, IDProjets, EstComplement, IDVerification)
             VALUES
                (1, 'Restaurant; vin \"compris\"', '2026-07-20', -57620000, 1, 14, 0, 1, '2026-07-21',
                 'P_A', '', '', 1, 0, 0, 0, '', 0, 0, 0, 0, 2),
                (2, 'Ligne 1
Ligne 2', NULL, 1500000000, 0, 0, 0, 1, '20/07/2026', '', '', '', 1, 0, 0, 0, '', 0, 0, 0, 0, 2),
                (3, 'Café ☕', '2026-07-22 10:15:00', 1234567, 0, 0, 0, 1, '', '', '', '', 1, 0, 0, 0, '', 0, 0, 0, 0, 2);",
        )
        .unwrap();
        path
    }

    fn table<'a>(extract: &'a Extract, name: &str) -> &'a Table {
        extract.tables.iter().find(|table| table.name == name).expect(name)
    }

    /// **Le catalogue colle au schéma, exactement.** Chaque table de la base
    /// est exportée ou écartée en le disant ; chaque table exportée a toutes
    /// ses colonnes, dans l'ordre, et pas une de plus. Une table ou une
    /// colonne ajoutée un jour sans être rangée fait échouer ce test — c'est
    /// ainsi que l'utilisateur ne perdra jamais rien.
    #[test]
    fn le_catalogue_colle_au_schema() {
        let path = scratch("catalogue");
        let conn = crate::database::create_new_database(&path).unwrap();
        let in_base: Vec<String> = conn
            .prepare("SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'")
            .unwrap()
            .query_map([], |row| row.get(0))
            .unwrap()
            .map(Result::unwrap)
            .collect();
        let exported: BTreeSet<&str> = TABLES.iter().map(|spec| spec.name).collect();
        let left_out: BTreeSet<&str> = LEFT_OUT.iter().map(|(name, _)| *name).collect();
        assert_eq!(exported.len(), TABLES.len(), "une table exportée deux fois");
        assert!(exported.is_disjoint(&left_out));
        for name in &in_base {
            assert!(
                exported.contains(name.as_str()) || left_out.contains(name.as_str()),
                "la table « {name} » n'est ni exportée ni écartée : rangez-la dans TABLES ou LEFT_OUT"
            );
        }
        for spec in TABLES {
            assert!(in_base.iter().any(|name| name == spec.name), "« {} » n'existe plus", spec.name);
            let columns: Vec<(String, String)> = conn
                .prepare(&format!("PRAGMA table_info(\"{}\")", spec.name))
                .unwrap()
                .query_map([], |row| Ok((row.get(1)?, row.get(2)?)))
                .unwrap()
                .map(Result::unwrap)
                .collect();
            let names: Vec<&str> = columns.iter().map(|(name, _)| name.as_str()).collect();
            // La première colonne est la clef primaire, et la seule : c'est
            // sur elle que les exports trient, et que le SQL pose sa clef.
            let keys: Vec<String> = conn
                .prepare(&format!("SELECT name FROM pragma_table_info('{}') WHERE pk > 0", spec.name))
                .unwrap()
                .query_map([], |row| row.get(0))
                .unwrap()
                .map(Result::unwrap)
                .collect();
            assert_eq!(keys, vec![spec.columns[0].name.to_string()], "la clef de « {} »", spec.name);
            let listed: Vec<&str> = spec.columns.iter().map(|column| column.name).collect();
            assert_eq!(listed, names, "les colonnes de « {} »", spec.name);
            // La nature suit la règle de `Data_models.md` : `Montant*`,
            // `Solde*`, `Report*` sont des montants, `Date*` des dates — et
            // leur type en base le confirme.
            for (column, (name, sql_type)) in spec.columns.iter().zip(&columns) {
                let looks_money = ["Montant", "Solde", "Report"].iter().any(|start| name.starts_with(start));
                let looks_date = name.starts_with("Date");
                assert_eq!(column.kind == Kind::Money, looks_money, "{}.{name}", spec.name);
                assert_eq!(column.kind == Kind::Date, looks_date, "{}.{name}", spec.name);
                let expected = match column.kind {
                    Kind::Integer | Kind::Money => "INTEGER",
                    Kind::Text | Kind::Date => "TEXT",
                };
                assert_eq!(sql_type, expected, "{}.{name}", spec.name);
            }
        }
    }

    #[test]
    fn les_montants_s_ecrivent_exactement() {
        assert_eq!(money_text(-57_620_000), "-57.62");
        assert_eq!(money_text(1_500_000_000), "1500.00");
        assert_eq!(money_text(1_234_567), "1.234567");
        assert_eq!(money_text(0), "0.00");
        assert_eq!(money_text(-5_000), "-0.005");
        assert_eq!(money_text(i64::MIN), "-9223372036854.775808");
    }

    #[test]
    fn la_base_se_lit_toute_et_juste() {
        let path = sample("lecture");
        let conn = open_read_only(&path, None).unwrap();
        let extract = read(&conn, &info()).unwrap();
        // `Export` en tête, puis toutes les tables du catalogue, même vides.
        let names: Vec<&str> = extract.tables.iter().map(|table| table.name.as_str()).collect();
        assert_eq!(names[0], EXPORT_TABLE);
        assert_eq!(names.len(), TABLES.len() + 1);
        assert_eq!(extract.table_count(), TABLES.len());
        let export = table(&extract, EXPORT_TABLE);
        assert_eq!(export.rows[0][2], Value::Text("Comptes famille".into()));
        assert_eq!(export.rows[0][4], Value::Text("EUR".into()));

        let operations = table(&extract, "Operation");
        assert_eq!(operations.rows.len(), 3);
        let first = &operations.rows[0];
        assert_eq!(first[1], Value::Text("Restaurant; vin \"compris\"".into()), "le texte part tel quel");
        assert_eq!(first[2], Value::Date(NaiveDate::from_ymd_opt(2026, 7, 20).unwrap()));
        assert_eq!(first[3], Value::Money(-57_620_000));
        assert_eq!(first[9], Value::Text("P_A".into()));
        let second = &operations.rows[1];
        assert_eq!(second[2], Value::Null, "une date absente reste vide");
        assert_eq!(second[1], Value::Text("Ligne 1\nLigne 2".into()));
        assert_eq!(second[8], Value::Text("20/07/2026".into()), "une date illisible part telle quelle");
        let third = &operations.rows[2];
        assert_eq!(third[2], Value::Date(NaiveDate::from_ymd_opt(2026, 7, 22).unwrap()), "l'heure est ôtée");
        assert_eq!(third[8], Value::Null, "une date vide reste vide");
        assert_eq!(
            extract.anomalies,
            vec![Anomaly {
                table: "Operation".into(),
                column: "DatePointage".into(),
                key: "2".into(),
                raw: "20/07/2026".into()
            }]
        );

        let accounts = table(&extract, "Compte");
        assert_eq!(accounts.rows[0][1], Value::Money(100_000_000));
        assert_eq!(accounts.rows[0][7], Value::Money(1_442_380_000));
        assert_eq!(accounts.rows[0][18], Value::Null, "DateCloture vide");
        // Toute la nomenclature part, même ce qu'aucune opération n'utilise.
        assert!(table(&extract, "Categorie").rows.len() >= 40);
        assert!(table(&extract, "Banques").rows.len() >= 30);
        assert!(extract.row_count() > 100);
    }

    /// **L'export ne touche jamais la base** : le fichier est le même, octet
    /// pour octet, et une écriture est refusée par SQLite lui-même.
    #[test]
    fn la_lecture_seule_ne_touche_a_rien() {
        let path = sample("seule");
        let before = std::fs::read(&path).unwrap();
        let conn = open_read_only(&path, None).unwrap();
        read(&conn, &info()).unwrap();
        assert!(conn.execute("DELETE FROM Operation", []).is_err(), "SQLite refuse d'écrire");
        drop(conn);
        assert_eq!(std::fs::read(&path).unwrap(), before);
    }

    #[test]
    fn une_base_protegee_demande_son_mot_de_passe() {
        let path = sample("protegee");
        crate::database::lock::change(&path, "", "sésame").unwrap();
        assert_eq!(open_read_only(&path, None).unwrap_err(), OpenError::Locked);
        assert_eq!(open_read_only(&path, Some("pas celui-là")).unwrap_err(), OpenError::Locked);
        let conn = open_read_only(&path, Some("sésame")).unwrap();
        assert_eq!(table(&read(&conn, &info()).unwrap(), "Operation").rows.len(), 3);
    }

    #[test]
    fn une_base_d_une_autre_version_n_est_pas_exportee_telle_quelle() {
        let current = crate::database::schema::CURRENT_SCHEMA_VERSION;
        for (version, expected) in [
            (current - 1, OpenError::TooOld { found: current - 1, current }),
            (current + 1, OpenError::TooRecent { found: current + 1, supported: current }),
        ] {
            let path = sample("version");
            Connection::open(&path)
                .unwrap()
                .execute("UPDATE Parametres SET VerDataBase = ?1 WHERE IDParametres = 1", [version])
                .unwrap();
            assert_eq!(open_read_only(&path, None).unwrap_err(), expected);
        }
        let path = scratch("pas-radinus");
        Connection::open(&path).unwrap().execute_batch("CREATE TABLE Autre (x INTEGER);").unwrap();
        assert_eq!(open_read_only(&path, None).unwrap_err(), OpenError::NotARadinusDatabase);
    }

    fn extract_of(label: &str) -> (std::path::PathBuf, Extract) {
        let path = sample(label);
        let conn = open_read_only(&path, None).unwrap();
        let extract = read(&conn, &info()).unwrap();
        (path, extract)
    }

    fn folder_of(path: &std::path::Path, name: &str) -> std::path::PathBuf {
        path.parent().unwrap().join(name)
    }

    /// Le numéro de série d'une date dans Excel : les jours depuis le
    /// 30/12/1899.
    fn serial(date: NaiveDate) -> f64 {
        use time_compute::Datelike;
        let day = chrono::NaiveDate::from_ymd_opt(date.year(), date.month(), date.day()).unwrap();
        (day - chrono::NaiveDate::from_ymd_opt(1899, 12, 30).unwrap()).num_days() as f64
    }

    /// **Relit un `.xlsx` et le compare à l'extrait, cellule par cellule** :
    /// noms des onglets, noms des champs, puis chaque valeur — un montant est
    /// le vrai montant, une date est une date.
    fn assert_xlsx_holds(file: &std::path::Path, tables: &[&Table]) {
        use office_toolkit::excel::{CellValue, Workbook};
        use office_toolkit::OpenFile;
        let book = Workbook::open_file(file).expect("relecture du .xlsx");
        assert_eq!(book.sheets.len(), tables.len());
        for (tab, table) in book.sheets.iter().zip(tables) {
            assert_eq!(tab.name, table.name);
            let cell = |row: usize, column: usize| {
                tab.rows.get(row).and_then(|line| line.cells.get(column)).cloned().unwrap_or_default()
            };
            for (column, (name, _)) in table.columns.iter().enumerate() {
                assert_eq!(cell(0, column).value, CellValue::Text(name.clone()), "{}.{name}", table.name);
            }
            assert_eq!(tab.rows.len(), table.rows.len() + 1, "{}", table.name);
            for (index, row) in table.rows.iter().enumerate() {
                for (column, value) in row.iter().enumerate() {
                    let found = cell(index + 1, column);
                    let expected = match value {
                        Value::Null => CellValue::Empty,
                        Value::Integer(number) => CellValue::Number(*number as f64),
                        Value::Real(number) => CellValue::Number(*number),
                        Value::Text(text) => CellValue::Text(crate::sheets::excel_text(text)),
                        Value::Money(micro) => CellValue::Number(*micro as f64 / UNIT as f64),
                        Value::Date(date) => {
                            let format = found.format.as_ref().and_then(|format| format.number_format.clone());
                            assert_eq!(format.as_deref(), Some("yyyy-mm-dd"), "{} : une date", table.name);
                            CellValue::Number(serial(*date))
                        }
                    };
                    assert_eq!(found.value, expected, "{} ligne {} colonne {}", table.name, index + 1, column);
                }
            }
        }
    }

    /// Le texte d'un paragraphe d'OpenDocument.
    fn paragraph_text(tag: &spreadsheet_ods::xmltree::XmlTag) -> String {
        use spreadsheet_ods::xmltree::XmlContent;
        tag.content()
            .iter()
            .map(|piece| match piece {
                XmlContent::Text(text) => text.clone(),
                XmlContent::Tag(inner) => paragraph_text(inner),
            })
            .collect()
    }

    /// La même relecture, pour un `.ods`.
    fn assert_ods_holds(file: &std::path::Path, tables: &[&Table]) {
        use spreadsheet_ods::Value as Ods;
        let book = spreadsheet_ods::read_ods(file).expect("relecture du .ods");
        assert_eq!(book.num_sheets(), tables.len());
        for (index, table) in tables.iter().enumerate() {
            let tab = book.sheet(index);
            assert_eq!(tab.name(), &table.name);
            for (column, (name, _)) in table.columns.iter().enumerate() {
                assert_eq!(tab.value(0, column as u32), &Ods::Text(name.clone()));
            }
            for (line, row) in table.rows.iter().enumerate() {
                for (column, value) in row.iter().enumerate() {
                    let found = tab.value(line as u32 + 1, column as u32);
                    let expected = match value {
                        Value::Null => Ods::Empty,
                        Value::Integer(number) => Ods::Number(*number as f64),
                        Value::Real(number) => Ods::Number(*number),
                        // Un tableur ne distingue pas un texte vide d'une
                        // cellule vide : Calc relit l'un comme l'autre.
                        Value::Text(text) if text.is_empty() => Ods::Empty,
                        // Les fins de ligne Windows deviennent les sauts de
                        // ligne d'OpenDocument : voir `sheets::ods_line_breaks`.
                        Value::Text(text) => Ods::Text(crate::sheets::xml_safe(&crate::sheets::ods_line_breaks(text))),
                        Value::Money(micro) => Ods::Number(*micro as f64 / UNIT as f64),
                        Value::Date(date) => {
                            use time_compute::Datelike;
                            Ods::from(chrono::NaiveDate::from_ymd_opt(date.year(), date.month(), date.day()).unwrap())
                        }
                    };
                    // Un texte de plusieurs lignes devient, en OpenDocument, un
                    // paragraphe par ligne : on le relit en rejoignant les
                    // paragraphes.
                    let found = match found {
                        Ods::TextXml(paragraphs) => Ods::Text(
                            paragraphs.iter().map(paragraph_text).collect::<Vec<_>>().join("\n"),
                        ),
                        other => other.clone(),
                    };
                    // **La bibliothèque de relecture perd un paragraphe vide
                    // final** — « livre\n » relu « livre ». Le fichier, lui,
                    // le porte (`<text:p></text:p>`, vérifié par
                    // `sheets::tests` et par LibreOffice lui-même) : seule la
                    // relecture de ce test est en cause, on compare donc sans
                    // les sauts de ligne finaux.
                    let trimmed = |value: Ods| match value {
                        Ods::Text(text) => Ods::Text(text.trim_end_matches('\n').to_string()),
                        other => other,
                    };
                    assert_eq!(trimmed(found), trimmed(expected), "{} ligne {} colonne {}", table.name, line + 1, column);
                }
            }
        }
    }

    #[test]
    fn un_seul_classeur_excel_ou_calc_contient_toute_la_base() {
        let (path, extract) = extract_of("classeur");
        let tables: Vec<&Table> = extract.tables.iter().collect();
        for extension in ["xlsx", "ods"] {
            let file = folder_of(&path, &format!("Comptes famille - export 2026-10-19.{extension}"));
            write_workbook(&extract, &file).unwrap();
            if extension == "xlsx" {
                assert_xlsx_holds(&file, &tables);
            } else {
                assert_ods_holds(&file, &tables);
            }
            // Rien de provisoire ne reste à côté.
            assert!(!provisional(&file).exists());
        }
    }

    #[test]
    fn un_classeur_par_table_porte_le_nom_de_la_table() {
        let (path, extract) = extract_of("classeurs");
        for extension in ["xlsx", "ods"] {
            let folder = folder_of(&path, &format!("Comptes famille - export 2026-10-19 {extension}"));
            let files = write_workbooks(&extract, &folder, extension).unwrap();
            assert_eq!(files.len(), TABLES.len() + 1);
            for (file, table) in files.iter().zip(&extract.tables) {
                assert_eq!(file.file_name().unwrap().to_string_lossy(), format!("{}.{extension}", table.name));
                if extension == "xlsx" {
                    assert_xlsx_holds(file, &[table]);
                } else {
                    assert_ods_holds(file, &[table]);
                }
            }
        }
    }

    fn operations(extract: &Extract) -> Table {
        table(extract, "Operation").clone()
    }

    #[test]
    fn le_csv_avec_guillemets_partout() {
        let (_, extract) = extract_of("csv-guillemets");
        let mut replaced = Replacements::default();
        let options = CsvOptions { decimal_comma: false, quote_all: true };
        let text = csv_of(&operations(&extract), options, &mut replaced);
        let lines: Vec<&str> = text.trim_start_matches('\u{feff}').split("\r\n").collect();
        assert!(text.starts_with('\u{feff}'), "la marque UTF-8 d'abord");
        assert!(lines[0].starts_with("\"IDOperation\";\"Libelle\";\"Date\";\"Montant\";"));
        assert!(
            lines[1].starts_with("\"1\";\"Restaurant! vin \"\"compris\"\"\";\"2026-07-20\";\"-57.62\";\"1\";"),
            "{}",
            lines[1]
        );
        assert!(lines[2].starts_with("\"2\";\"Ligne 1 Ligne 2\";\"\";\"1500.00\";"), "{}", lines[2]);
        assert!(lines[3].starts_with("\"3\";\"Café ☕\";\"2026-07-22\";\"1.234567\";"), "{}", lines[3]);
        assert_eq!(lines.len(), 5, "trois lignes, l'en-tête, et la fin");
        // Avec des guillemets, les guillemets intérieurs sont doublés : ce
        // n'est pas un remplacement, c'est la norme du format.
        assert_eq!(replaced, Replacements { semicolons: 1, line_breaks: 1, quotes: 0 });
        // Chaque ligne a exactement autant de champs que la table a de colonnes.
        let columns = operations(&extract).columns.len();
        for line in &lines[..4] {
            assert_eq!(line.matches("\";\"").count() + 1, columns, "{line}");
        }
    }

    #[test]
    fn le_csv_sans_guillemets_a_la_virgule() {
        let (_, extract) = extract_of("csv-nu");
        let mut replaced = Replacements::default();
        let options = CsvOptions { decimal_comma: true, quote_all: false };
        let text = csv_of(&operations(&extract), options, &mut replaced);
        let lines: Vec<&str> = text.trim_start_matches('\u{feff}').split("\r\n").collect();
        assert!(lines[0].starts_with("IDOperation;Libelle;Date;Montant;IDModeOperation;"));
        assert!(lines[1].starts_with("1;Restaurant! vin 'compris';2026-07-20;-57,62;1;14;"), "{}", lines[1]);
        assert!(lines[2].starts_with("2;Ligne 1 Ligne 2;;1500,00;"), "{}", lines[2]);
        assert_eq!(replaced, Replacements { semicolons: 1, line_breaks: 1, quotes: 2 });
        // **Aucune valeur ne porte de point-virgule** : chaque ligne a donc
        // exactement autant de champs que la table a de colonnes.
        let columns = operations(&extract).columns.len();
        for line in &lines[..4] {
            assert_eq!(line.split(';').count(), columns, "{line}");
            assert!(!line.contains('"'), "{line}");
        }
    }

    #[test]
    fn un_csv_par_table() {
        let (path, extract) = extract_of("csv-fichiers");
        let folder = folder_of(&path, "Comptes famille - export 2026-10-19 csv");
        let (files, replaced) = write_csv_files(&extract, &folder, CsvOptions::default()).unwrap();
        assert_eq!(files.len(), TABLES.len() + 1);
        assert!(files.iter().all(|file| file.extension().unwrap() == "csv"));
        let export = std::fs::read_to_string(folder.join("Export.csv")).unwrap();
        assert_eq!(
            export,
            "\u{feff}Logiciel;Version;Base;DateExport;Devise;VersionSchema\r\n\
             Radinus;3.0.0;Comptes famille;2026-10-19;EUR;11\r\n"
        );
        assert_eq!(replaced.semicolons, 1);
        // Chaque fichier relu a autant de lignes que sa table, plus l'en-tête.
        for table in &extract.tables {
            let text = std::fs::read_to_string(folder.join(format!("{}.csv", table.name))).unwrap();
            assert_eq!(text.matches("\r\n").count(), table.rows.len() + 1, "{}", table.name);
        }
    }

    /// **Relit une base SQL et la compare à l'extrait, valeur par valeur.**
    fn assert_sqlite_holds(conn: &Connection, tables: &[&Table]) {
        use rusqlite::types::Value as Sql;
        for table in tables {
            let mut statement =
                conn.prepare(&format!("SELECT * FROM {} ORDER BY 1", table.name)).expect(&table.name);
            let names: Vec<String> = statement.column_names().iter().map(|name| name.to_string()).collect();
            let expected_names: Vec<String> = table.columns.iter().map(|(name, _)| name.clone()).collect();
            assert_eq!(names, expected_names, "{}", table.name);
            let width = names.len();
            let rows: Vec<Vec<Sql>> = statement
                .query_map([], |row| (0..width).map(|index| row.get::<_, Sql>(index)).collect())
                .unwrap()
                .map(Result::unwrap)
                .collect();
            assert_eq!(rows.len(), table.rows.len(), "{}", table.name);
            for (index, (found, expected)) in rows.iter().zip(&table.rows).enumerate() {
                for (column, (got, value)) in found.iter().zip(expected).enumerate() {
                    let place = format!("{} ligne {} colonne {}", table.name, index + 1, column);
                    match (value, got) {
                        (Value::Null, Sql::Null) => {}
                        (Value::Integer(number), Sql::Integer(got)) => assert_eq!(got, number, "{place}"),
                        (Value::Text(text), Sql::Text(got)) => assert_eq!(got, text, "{place}"),
                        (Value::Date(date), Sql::Text(got)) => {
                            assert_eq!(got, &date.format("%Y-%m-%d").to_string(), "{place}")
                        }
                        (Value::Money(micro), Sql::Real(got)) => {
                            assert!((got - *micro as f64 / UNIT as f64).abs() < 1e-9, "{place} : {got}")
                        }
                        (Value::Money(micro), Sql::Integer(got)) => assert_eq!(*got * UNIT, *micro, "{place}"),
                        (value, got) => panic!("{place} : {value:?} relu {got:?}"),
                    }
                }
            }
        }
    }

    #[test]
    fn le_json_se_relit_comme_la_base() {
        let (path, extract) = extract_of("json");
        let file = folder_of(&path, "Comptes famille - export 2026-10-19.json");
        write_document(&extract, &info(), &file).unwrap();
        let text = std::fs::read_to_string(&file).unwrap();
        let read: serde_json::Value = serde_json::from_str(&text).expect("un JSON valide");
        assert_eq!(read["logiciel"], "Radinus");
        assert_eq!(read["base"], "Comptes famille");
        assert_eq!(read["export"], "2026-10-19");
        assert_eq!(read["devise"], "EUR");
        let tables = read["tables"].as_object().unwrap();
        assert_eq!(tables.len(), TABLES.len(), "toutes les tables, sans Export répétée");
        for table in data_tables(&extract) {
            let rows = tables[&table.name].as_array().expect(&table.name);
            assert_eq!(rows.len(), table.rows.len(), "{}", table.name);
            for (found, expected) in rows.iter().zip(&table.rows) {
                for ((name, _), value) in table.columns.iter().zip(expected) {
                    let got = &found[name];
                    match value {
                        Value::Null => assert!(got.is_null(), "{}.{name}", table.name),
                        Value::Integer(number) => assert_eq!(got.as_i64(), Some(*number)),
                        Value::Real(number) => assert_eq!(got.as_f64(), Some(*number)),
                        Value::Text(text) => assert_eq!(got.as_str(), Some(text.as_str())),
                        Value::Money(micro) => {
                            assert!((got.as_f64().unwrap() - *micro as f64 / UNIT as f64).abs() < 1e-9)
                        }
                        Value::Date(date) => assert_eq!(got.as_str(), Some(date.format("%Y-%m-%d").to_string().as_str())),
                    }
                }
            }
        }
        // Les champs gardent l'ordre de la base, et un montant s'écrit exactement.
        assert!(text.contains(
            "{ \"IDOperation\": 1, \"Libelle\": \"Restaurant; vin \\\"compris\\\"\", \"Date\": \"2026-07-20\", \"Montant\": -57.62,"
        ));
        assert!(text.contains("\"Montant\": 1.234567,"));
    }

    #[test]
    fn un_json_par_table_garde_la_meme_forme() {
        let (path, extract) = extract_of("jsons");
        let folder = folder_of(&path, "Comptes famille - export 2026-10-19 json");
        let files = write_documents(&extract, &info(), &folder, "json").unwrap();
        assert_eq!(files.len(), TABLES.len());
        for (file, table) in files.iter().zip(data_tables(&extract)) {
            assert_eq!(file.file_name().unwrap().to_string_lossy(), format!("{}.json", table.name));
            let read: serde_json::Value = serde_json::from_str(&std::fs::read_to_string(file).unwrap()).unwrap();
            assert_eq!(read["devise"], "EUR");
            let tables = read["tables"].as_object().unwrap();
            assert_eq!(tables.keys().collect::<Vec<_>>(), vec![&table.name], "le nom de la table, dedans aussi");
            assert_eq!(tables[&table.name].as_array().unwrap().len(), table.rows.len());
        }
    }

    /// Relit **notre** XML — une table, des lignes, une balise par champ — sans
    /// bibliothèque : de quoi comparer chaque valeur à la base.
    /// Une table relue du XML : son nom, et pour chaque ligne ses champs
    /// (nom, texte).
    type XmlTable = (String, Vec<Vec<(String, String)>>);

    fn read_our_xml(text: &str) -> Vec<XmlTable> {
        let unescape = |text: &str| {
            text.replace("&lt;", "<")
                .replace("&gt;", ">")
                .replace("&quot;", "\"")
                .replace("&apos;", "'")
                .replace("&#13;", "\r")
                .replace("&amp;", "&")
        };
        let mut tables = Vec::new();
        for block in text.split("<table name=\"").skip(1) {
            let (name, rest) = block.split_once("\">").unwrap();
            let body = rest.split("</table>").next().unwrap();
            let mut rows = Vec::new();
            for row in body.split("<row>").skip(1) {
                let row = row.split("</row>").next().unwrap();
                let mut fields = Vec::new();
                let mut rest = row;
                while let Some(start) = rest.find('<') {
                    let after = &rest[start + 1..];
                    let close = after.find('>').unwrap();
                    let tag = &after[..close];
                    if let Some(empty) = tag.strip_suffix('/') {
                        fields.push((empty.to_string(), String::new()));
                        rest = &after[close + 1..];
                    } else {
                        let end = format!("</{tag}>");
                        let content_and_more = &after[close + 1..];
                        let stop = content_and_more.find(&end).unwrap();
                        fields.push((tag.to_string(), unescape(&content_and_more[..stop])));
                        rest = &content_and_more[stop + end.len()..];
                    }
                }
                rows.push(fields);
            }
            tables.push((unescape(name), rows));
        }
        tables
    }

    #[test]
    fn le_xml_se_relit_comme_la_base() {
        let (path, extract) = extract_of("xml");
        let file = folder_of(&path, "Comptes famille - export 2026-10-19.xml");
        write_document(&extract, &info(), &file).unwrap();
        let text = std::fs::read_to_string(&file).unwrap();
        assert!(text.starts_with(
            "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<radinus logiciel=\"Radinus\" version=\"3.0.0\" \
             base=\"Comptes famille\" export=\"2026-10-19\" devise=\"EUR\">\n"
        ));
        assert!(text.contains(
            "<row><IDOperation>1</IDOperation><Libelle>Restaurant; vin &quot;compris&quot;</Libelle>\
             <Date>2026-07-20</Date><Montant>-57.62</Montant>"
        ));
        let read = read_our_xml(&text);
        let names: Vec<&str> = read.iter().map(|(name, _)| name.as_str()).collect();
        let expected: Vec<&str> = data_tables(&extract).map(|table| table.name.as_str()).collect();
        assert_eq!(names, expected);
        for ((_, rows), table) in read.iter().zip(data_tables(&extract)) {
            assert_eq!(rows.len(), table.rows.len(), "{}", table.name);
            for (fields, values) in rows.iter().zip(&table.rows) {
                let present: Vec<(String, String)> = table
                    .columns
                    .iter()
                    .zip(values)
                    .filter(|(_, value)| **value != Value::Null)
                    .map(|((name, _), value)| (name.clone(), plain(value)))
                    .collect();
                assert_eq!(fields, &present, "{}", table.name);
            }
        }
        // Un caractère de contrôle ne casse pas le fichier.
        assert_eq!(xml_text("a\u{1}b & <c>"), "a\u{FFFD}b &amp; &lt;c&gt;");
    }

    #[test]
    fn le_script_sql_recree_la_base() {
        let (path, extract) = extract_of("sql");
        let file = folder_of(&path, "Comptes famille - export 2026-10-19.sql");
        write_sql(&extract, &info(), &file).unwrap();
        let script = std::fs::read_to_string(&file).unwrap();
        assert!(script.contains("\nBEGIN;\n") && script.ends_with("COMMIT;\n"));
        assert!(!script.contains("REFERENCES"), "pas de contraintes de liens");
        assert!(script.contains("CREATE TABLE Operation (\n  IDOperation INTEGER PRIMARY KEY,\n  Libelle TEXT,\n  Date DATE,\n  Montant DECIMAL(19,6),"));
        assert!(script.contains("VALUES (1, 'Restaurant; vin \"compris\"', '2026-07-20', -57.62,"));
        assert!(script.contains("CREATE TABLE CalOpPeriodique (\n  GUIDCalOpPeriode VARCHAR(255) PRIMARY KEY,"));
        // La date illisible de l'exemple garde sa colonne en texte, et le dit :
        // l'import ne tombera pas pour elle.
        assert!(script.contains("-- Operation.DatePointage : des valeurs illisibles"));
        assert!(script.contains("  DatePointage TEXT,"));
        assert!(script.contains("  Date DATE,"));
        // **Rejoué dans une base vide, il redonne la base, valeur par valeur.**
        let replayed = Connection::open_in_memory().unwrap();
        replayed.execute_batch(&script).expect("le script s'exécute");
        let tables: Vec<&Table> = extract.tables.iter().collect();
        assert_sqlite_holds(&replayed, &tables);
    }

    #[test]
    fn un_script_sql_par_table() {
        let (path, extract) = extract_of("sqls");
        let folder = folder_of(&path, "Comptes famille - export 2026-10-19 sql");
        let files = write_sql_files(&extract, &info(), &folder).unwrap();
        assert_eq!(files.len(), TABLES.len() + 1);
        let replayed = Connection::open_in_memory().unwrap();
        for (file, table) in files.iter().zip(&extract.tables) {
            assert_eq!(file.file_name().unwrap().to_string_lossy(), format!("{}.sql", table.name));
            replayed.execute_batch(&std::fs::read_to_string(file).unwrap()).expect(&table.name);
        }
        let tables: Vec<&Table> = extract.tables.iter().collect();
        assert_sqlite_holds(&replayed, &tables);
    }

    #[test]
    fn la_base_sqlite_autonome_s_ouvre_sans_mot_de_passe() {
        let (path, extract) = extract_of("sqlite");
        crate::database::lock::change(&path, "", "sésame").unwrap();
        let file = folder_of(&path, "Comptes famille - export 2026-10-19.sqlite");
        write_sqlite(&extract, &file).unwrap();
        assert!(!provisional(&file).exists());
        // Une base ordinaire : elle s'ouvre sans clé, et dit tout.
        let opened = Connection::open(&file).unwrap();
        let tables: Vec<&Table> = extract.tables.iter().collect();
        assert_sqlite_holds(&opened, &tables);
        let names: Vec<String> = opened
            .prepare("SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY rowid")
            .unwrap()
            .query_map([], |row| row.get(0))
            .unwrap()
            .map(Result::unwrap)
            .collect();
        assert!(!names.iter().any(|name| name == "ParamSecurite" || name == "PiecesJointes"));
        drop(opened);
        // Refaite, elle remplace la précédente au lieu de s'y ajouter.
        write_sqlite(&extract, &file).unwrap();
        let again = Connection::open(&file).unwrap();
        let count: i64 = again.query_row("SELECT COUNT(*) FROM Operation", [], |row| row.get(0)).unwrap();
        assert_eq!(count, 3);
    }

    /// **Sur une vraie base** (étape F, 19/10/2026) : une sauvegarde de
    /// Fabrice est restaurée dans une base neuve, puis exportée dans **tous**
    /// les formats, et chaque fichier est relu et comparé à la base.
    ///
    /// Les sauvegardes ne sont pas dans le dépôt : ce sont de vrais comptes.
    ///
    ///     RADINUS_SAUVEGARDE=/chemin/a.zip:/chemin/b.zip \
    ///       cargo test -p radinus-core --lib vraie_base -- --ignored --nocapture
    #[test]
    #[ignore]
    fn vraie_base_exportee_dans_tous_les_formats() {
        let archives = std::env::var("RADINUS_SAUVEGARDE").expect("RADINUS_SAUVEGARDE");
        for archive in archives.split(':').filter(|path| !path.is_empty()) {
            check_real_backup(std::path::Path::new(archive));
        }
    }

    /// **La même vraie base, piégée** : les valeurs qu'aucun test ordinaire
    /// n'oserait — dates d'avant 1900 et de l'an 1, texte de 40 000
    /// caractères, barre oblique inverse, caractère de contrôle, écriture de
    /// droite à gauche, émoji, retour chariot seul, montants extrêmes.
    #[test]
    #[ignore]
    fn vraie_base_piegee_exportee_dans_tous_les_formats() {
        let archives = std::env::var("RADINUS_SAUVEGARDE").expect("RADINUS_SAUVEGARDE");
        let archive = archives.split(':').find(|path| !path.is_empty()).unwrap();
        check_backup(std::path::Path::new(archive), true);
    }

    fn check_real_backup(archive: &std::path::Path) {
        check_backup(archive, false);
    }

    fn check_backup(archive: &std::path::Path, traps: bool) {
        use rusqlite::types::Value as Sql;
        let path = scratch(if traps { "piegee" } else { "vraie" });
        {
            let mut conn = crate::database::create_new_database(&path).unwrap();
            crate::backup::restore_file_into(&mut conn, archive).expect("restauration");
            if traps {
                let long = "Très long commentaire. ".repeat(1800);
                conn.execute_batch(
                    "INSERT INTO Tiers (IDTiers, Libelle) VALUES
                        (90001, 'C:\\Users\\fab\\n''est pas un saut'),
                        (90002, 'L''Oréal \"Paris\"; ligne\rseule'),
                        (90003, 'تحويل بنكي — עברית — 👍🏽'),
                        (90004, '   '),
                        (90005, '=SOMME(A1:A2)'),
                        (90006, 'tab\tici');",
                )
                .unwrap();
                conn.execute("INSERT INTO Tiers (IDTiers, Libelle) VALUES (90007, ?1)", ["contrôle\u{1}ici"]).unwrap();
                let first_account: i64 = conn.query_row("SELECT MIN(IDCompte) FROM Compte", [], |row| row.get(0)).unwrap();
                for (id, date, amount) in [
                    (900001_i64, "1850-03-01", -1_i64),
                    (900002, "0001-01-01", 99_999_999_990_000),
                    (900003, "9999-12-31", -10_000),
                    (900004, "1900-02-28", 0),
                    (900005, "1900-03-01", 1),
                ] {
                    conn.execute(
                        "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDModeOperation, IDCategorie,
                            IDAffectation, IDCompte, DatePointage, FitID, ReferencePaiement, NumRelevBanque,
                            IDStatutOperation, IDOperationParent, SoldePointe, EstParent, GUIDCalOpPeriode,
                            IDCheque, IDTiers, IDProjets, EstComplement, IDVerification)
                         VALUES (?1, 'Piège', ?2, ?3, 0, 0, 0, ?4, '', '', '', '', 2, 0, 0, 0, '', 0, 90002, 0, 0, 2)",
                        rusqlite::params![id, date, amount, first_account],
                    )
                    .unwrap();
                }
                conn.execute(
                    "INSERT INTO Commentaire (IDCommentaire, CommentaireTxt, IDOperation) VALUES (90001, ?1, 900001)",
                    [long.as_str()],
                )
                .unwrap();
            }
        }
        let before = std::fs::read(&path).unwrap();
        let conn = open_read_only(&path, None).expect("la base restaurée s'ouvre");
        let started = std::time::Instant::now();
        let extract = read(&conn, &info()).unwrap();
        println!(
            "\n{} : {} tables, {} lignes, {} valeurs illisibles, lues en {:?}",
            archive.file_name().unwrap().to_string_lossy(),
            extract.table_count(),
            extract.row_count(),
            extract.anomalies.len(),
            started.elapsed()
        );
        for anomaly in &extract.anomalies {
            println!("  illisible : {}.{} [{}] = {:?}", anomaly.table, anomaly.column, anomaly.key, anomaly.raw);
        }

        // 1. L'extrait contre la base, relue autrement : chaque table, chaque
        //    ligne, chaque valeur brute.
        for spec in TABLES {
            let table = table(&extract, spec.name);
            let mut statement = conn.prepare(&format!("SELECT * FROM {} ORDER BY 1", spec.name)).unwrap();
            let width = statement.column_count();
            assert_eq!(width, spec.columns.len(), "{}", spec.name);
            let raws: Vec<Vec<Sql>> = statement
                .query_map([], |row| (0..width).map(|index| row.get::<_, Sql>(index)).collect())
                .unwrap()
                .map(Result::unwrap)
                .collect();
            assert_eq!(raws.len(), table.rows.len(), "{} : toutes les lignes", spec.name);
            for (raw, row) in raws.iter().zip(&table.rows) {
                for ((value, got), column) in raw.iter().zip(row).zip(spec.columns) {
                    let place = format!("{}.{}", spec.name, column.name);
                    match (value, got) {
                        (Sql::Null, Value::Null) => {}
                        (Sql::Integer(raw), Value::Money(micro)) => assert_eq!(raw, micro, "{place}"),
                        (Sql::Integer(raw), Value::Integer(number)) => assert_eq!(raw, number, "{place}"),
                        (Sql::Text(raw), Value::Text(text)) => assert_eq!(raw, text, "{place}"),
                        (Sql::Text(raw), Value::Date(date)) => {
                            assert!(raw.starts_with(&date.format("%Y-%m-%d").to_string()), "{place} : {raw}")
                        }
                        (Sql::Text(raw), Value::Null) => assert!(raw.trim().is_empty(), "{place} : {raw:?} perdu"),
                        (Sql::Real(raw), Value::Real(number)) => assert_eq!(raw, number, "{place}"),
                        (raw, got) => panic!("{place} : {raw:?} lu {got:?}"),
                    }
                }
            }
        }

        // 2. Chaque format, relu et comparé à l'extrait.
        let tables: Vec<&Table> = extract.tables.iter().collect();
        let all = |format: Format, layout: Layout, name: &str| -> (std::path::PathBuf, Outcome) {
            let destination = folder_of(&path, name);
            let request = Request {
                format,
                layout,
                csv: CsvOptions { decimal_comma: true, quote_all: true },
                qif_order: crate::qif_import::DateOrder::DayMonth,
            };
            let started = std::time::Instant::now();
            let outcome = export(&extract, &info(), request, &destination).unwrap();
            println!("  {name} : {} fichier(s) en {:?}", outcome.files, started.elapsed());
            (destination, outcome)
        };
        let (xlsx, _) = all(Format::Xlsx, Layout::OneFile, "tout.xlsx");
        assert_xlsx_holds(&xlsx, &tables);
        let (ods, _) = all(Format::Ods, Layout::OneFile, "tout.ods");
        assert_ods_holds(&ods, &tables);
        let (sqlite, _) = all(Format::Sqlite, Layout::OneFile, "tout.sqlite");
        assert_sqlite_holds(&Connection::open(&sqlite).unwrap(), &tables);
        let (sql, _) = all(Format::Sql, Layout::OneFile, "tout.sql");
        let replayed = Connection::open_in_memory().unwrap();
        replayed.execute_batch(&std::fs::read_to_string(&sql).unwrap()).expect("le script se rejoue");
        assert_sqlite_holds(&replayed, &tables);
        let (json, _) = all(Format::Json, Layout::OneFile, "tout.json");
        let read_json: serde_json::Value = serde_json::from_str(&std::fs::read_to_string(&json).unwrap()).unwrap();
        for table in data_tables(&extract) {
            assert_eq!(read_json["tables"][&table.name].as_array().unwrap().len(), table.rows.len(), "{}", table.name);
        }
        let (xml, _) = all(Format::Xml, Layout::OneFile, "tout.xml");
        let read_xml = read_our_xml(&std::fs::read_to_string(&xml).unwrap());
        for ((name, rows), table) in read_xml.iter().zip(data_tables(&extract)) {
            assert_eq!(name, &table.name);
            assert_eq!(rows.len(), table.rows.len(), "{name}");
            for (fields, values) in rows.iter().zip(&table.rows) {
                let present: Vec<(String, String)> = table
                    .columns
                    .iter()
                    .zip(values)
                    .filter(|(_, value)| **value != Value::Null)
                    // Un caractère de contrôle, que le XML ne peut pas porter,
                    // y devient « � » — compté et annoncé par la phrase de fin.
                    .map(|((name, _), value)| (name.clone(), plain(value).chars().map(xml_char).collect()))
                    .collect();
                assert_eq!(fields, &present, "{name}");
            }
        }
        let (csv, outcome) = all(Format::Csv, Layout::PerTable, "csv");
        println!("  csv : {:?}", outcome.replacements);
        for table in &extract.tables {
            let text = std::fs::read_to_string(csv.join(format!("{}.csv", table.name))).unwrap();
            let lines: Vec<&str> = text.trim_start_matches('\u{feff}').split("\r\n").filter(|l| !l.is_empty()).collect();
            assert_eq!(lines.len(), table.rows.len() + 1, "{}", table.name);
            for line in &lines {
                // Tout entre guillemets : chaque champ commence et finit par un
                // guillemet, et `";"` ne peut séparer que deux champs.
                assert_eq!(line.matches("\";\"").count() + 1, table.columns.len(), "{} : {line}", table.name);
            }
        }
        // Le second réglage du CSV, pour la relecture extérieure (LibreOffice,
        // le module csv de Python) : sans guillemets, au point.
        let bare = folder_of(&path, "csv-nu");
        write_csv_files(&extract, &bare, CsvOptions { decimal_comma: false, quote_all: false }).unwrap();
        for (name, format) in [("par-table-xlsx", Format::Xlsx), ("par-table-ods", Format::Ods)] {
            let (folder, outcome) = all(format, Layout::PerTable, name);
            assert_eq!(outcome.files, extract.tables.len());
            for table in &extract.tables {
                let file = folder.join(format!("{}.{}", table.name, format.extension()));
                if format == Format::Xlsx {
                    assert_xlsx_holds(&file, &[table]);
                } else {
                    assert_ods_holds(&file, &[table]);
                }
            }
        }

        // 3. Le QIF : chaque compte se relit, et tombe sur le solde de la base
        //    — reports, plus les opérations mères pointées ou engagées datées.
        let (qif, outcome) = all(Format::Qif, Layout::OneFile, "qif");
        let report = outcome.accounts.unwrap();
        println!("  qif : {report:?}");
        let mut files: Vec<std::path::PathBuf> = std::fs::read_dir(&qif).unwrap().map(|e| e.unwrap().path()).collect();
        files.sort();
        let accounts: Vec<(i64, String, i64)> = conn
            .prepare("SELECT IDCompte, Libelle, ReportPointe + ReportEngage FROM Compte ORDER BY IDCompte")
            .unwrap()
            .query_map([], |row| Ok((row.get(0)?, row.get(1)?, row.get(2)?)))
            .unwrap()
            .map(Result::unwrap)
            .collect();
        assert_eq!(files.len(), accounts.len());
        let today = NaiveDate::from_ymd_opt(2026, 10, 19).unwrap();
        let mut seen = 0;
        for (id, label, opening) in &accounts {
            let expected: i64 = conn
                .query_row(
                    "SELECT COALESCE(SUM(Montant), 0) FROM Operation WHERE IDCompte = ?1 AND IDOperationParent = 0
                       AND IDStatutOperation IN (1, 2) AND Date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]*'
                       AND Date >= '1900-03-01'",
                    [id],
                    |row| row.get(0),
                )
                .unwrap();
            let count: usize = conn
                .query_row(
                    "SELECT COUNT(*) FROM Operation WHERE IDCompte = ?1 AND IDOperationParent = 0
                       AND IDStatutOperation IN (1, 2) AND Date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]*'
                       AND Date >= '1900-03-01'",
                    [id],
                    |row| row.get::<_, i64>(0),
                )
                .unwrap() as usize;
            let file = files
                .iter()
                .find(|file| {
                    let name = file.file_stem().unwrap().to_string_lossy().to_string();
                    name == crate::account_export::file_name(label, "") || name.ends_with(&format!("({id})"))
                })
                .unwrap_or_else(|| panic!("le fichier du compte {label}"));
            let text = std::fs::read_to_string(file).unwrap();
            let options = crate::qif_import::Options {
                order: Some(crate::qif_import::DateOrder::DayMonth),
                label: crate::qif_import::LabelChoice::Both,
                today,
            };
            let read = crate::qif_import::read(&text, 0, "f", options).unwrap();
            if traps && !read.rejected.is_empty() {
                // Les dates d'avant 1900 du piège partent en texte, donc hors du
                // QIF, annoncées « sans date ». Reste l'an 9999, écrit tel quel :
                // c'est notre lecture QIF qui le refuse, et elle a raison.
                // Rien d'autre ne doit l'être.
                assert!(
                    read.rejected.iter().all(|r| matches!(r.reason, crate::qif_import::Reason::Date)),
                    "{label} : {:?}",
                    read.rejected
                );
                assert_eq!(read.rejected.len(), 1, "{label} : l'an 9999");
                assert_eq!(read.statement.transactions.len(), count - 1, "{label}");
                assert_eq!(read.opening.map(|o| o.amount), Some(*opening), "{label} : le solde initial");
                seen += count;
                println!("  qif {label} (piégé) : {} opérations relues, l'an 9999 refusé à la relecture", count - 1);
                continue;
            }
            assert!(read.rejected.is_empty(), "{label} : {:?}", read.rejected);
            assert_eq!(read.statement.transactions.len(), count, "{label} : toutes les opérations");
            let total: i64 = read.statement.transactions.iter().map(|t| t.amount).sum();
            let found = read.opening.map(|o| o.amount).unwrap_or(0);
            assert_eq!(found, *opening, "{label} : le solde initial");
            assert_eq!(found + total, opening + expected, "{label} : le solde");
            println!("  qif {label} : {count} opérations, solde {}", money_text(opening + expected));
            seen += count;
        }
        assert_eq!(seen, report.operations);

        // 4. L'OFX : chaque compte se relit, avec les mêmes opérations.
        let (ofx, outcome) = all(Format::Ofx, Layout::OneFile, "ofx");
        let report = outcome.accounts.unwrap();
        let mut ofx_seen = 0;
        for entry in std::fs::read_dir(&ofx).unwrap() {
            let text = std::fs::read_to_string(entry.unwrap().path()).unwrap();
            let numbers = crate::ofx_import::accounts_in(&text);
            assert_eq!(numbers.len(), 1);
            ofx_seen += crate::ofx_import::read(&text, &numbers[0]).unwrap().transactions.len();
        }
        assert_eq!(ofx_seen, report.operations);

        // 5. La base n'a pas bougé d'un octet.
        drop(conn);
        assert_eq!(std::fs::read(&path).unwrap(), before, "la base exportée est intacte");
    }

    /// **Zéro se dit zéro, dans toutes les langues.** En français (et en
    /// portugais), la règle de pluriel « one » couvre 0 aussi : une variante
    /// écrite « une ligne » aurait annoncé « une ligne » pour une base vide.
    /// La règle vérifiée : 0 et 2 ne se disent jamais comme 1 (l'arabe et
    /// l'hébreu ont leurs propres formes, en toutes lettres, et c'est juste),
    /// et un nombre plus grand s'écrit en chiffres. Aucune phrase ne manque :
    /// une clef absente reviendrait telle quelle.
    #[test]
    fn la_phrase_de_fin_dit_les_nombres_dans_toutes_les_langues() {
        use crate::i18n::{message_of, Language};
        let mut wrong = Vec::new();
        let said = |language: Language, key: &str, count: i64| match key {
            "base-export-done" => message_of(language, key, &[("base", "B")], &[("tables", count), ("rows", count)]),
            "base-export-done-accounts" => {
                message_of(language, key, &[("base", "B")], &[("accounts", count), ("operations", count)])
            }
            _ => message_of(language, key, &[], &[("count", count)]),
        };
        for language in Language::all() {
            for key in [
                "base-export-done",
                "base-export-done-accounts",
                "base-export-done-replacements",
                "base-export-done-controls",
                "base-export-done-excel-cut",
                "base-export-done-anomalies",
                "base-export-done-planned",
                "base-export-done-undated",
                "base-export-done-adjusted",
            ] {
                let one = said(language, key, 1);
                for count in [0_i64, 2, 5, 21, 1234] {
                    let text = said(language, key, count);
                    let digits = count.to_string();
                    let bad = text.contains("base-export")
                        || text == one
                        || (count > 2 && !text.contains(digits.as_str()));
                    if bad {
                        wrong.push(format!("{} {key} {count} : {text}", language.tag()));
                    }
                }
            }
        }
        assert!(wrong.is_empty(), "{}", wrong.join("\n"));
    }

    /// **Une base neuve, vide de toute opération**, s'exporte dans tous les
    /// formats : la nomenclature part, le QIF et l'OFX ne font aucun fichier,
    /// et la phrase dit « 0 compte, 0 opération ».
    #[test]
    fn une_base_vide_s_exporte_dans_tous_les_formats() {
        use crate::i18n::Language;
        let path = scratch("vide");
        drop(crate::database::create_new_database(&path).unwrap());
        let conn = open_read_only(&path, None).unwrap();
        let extract = read(&conn, &info()).unwrap();
        assert_eq!(table(&extract, "Operation").rows.len(), 0);
        for format in Format::ALL {
            let destination = folder_of(&path, &format!("vide.{}", format.extension()));
            let request = Request {
                format,
                layout: Layout::OneFile,
                csv: CsvOptions::default(),
                qif_order: crate::qif_import::DateOrder::DayMonth,
            };
            let outcome = export(&extract, &info(), request, &destination).unwrap();
            if format.is_lossy() {
                assert_eq!(outcome.files, 0, "{}", format.key());
                let said = outcome_sentence(&outcome, "Neuve", Language::French);
                assert!(said.contains("0 compte") && said.contains("0 opération"), "{said}");
            } else {
                assert!(outcome.files >= 1, "{}", format.key());
            }
        }
    }

    /// **Une base plus fournie** : combien de temps chaque format demande.
    /// Un millier d'opérations suffit (Fabrice, 19/10/2026) — c'est l'ordre
    /// de grandeur d'une vraie base, et la mesure ne demande aucune
    /// compilation particulière.
    ///
    ///     cargo test -p radinus-core --lib grosse_base -- --ignored --nocapture
    #[test]
    #[ignore]
    fn grosse_base_chronometree() {
        let count: i64 = std::env::var("RADINUS_GROSSE").ok().and_then(|n| n.parse().ok()).unwrap_or(1_000);
        let path = sample("grosse");
        {
            let mut conn = Connection::open(&path).unwrap();
            let batch = conn.transaction().unwrap();
            {
                let mut insert = batch
                    .prepare(
                        "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDModeOperation, IDCategorie,
                            IDAffectation, IDCompte, DatePointage, FitID, ReferencePaiement, NumRelevBanque,
                            IDStatutOperation, IDOperationParent, SoldePointe, EstParent, GUIDCalOpPeriode,
                            IDCheque, IDTiers, IDProjets, EstComplement, IDVerification)
                         VALUES (?1, ?2, ?3, ?4, 1, 14, 0, 1, ?3, '', '', '', 1, 0, 0, 0, '', 0, 0, 0, 0, 2)",
                    )
                    .unwrap();
                for n in 0..count {
                    let date = format!("{:04}-{:02}-{:02}", 2000 + n % 26, 1 + n % 12, 1 + n % 28);
                    insert
                        .execute(rusqlite::params![1000 + n, format!("Opération numéro {n}"), date, -(n % 50_000) * 10_000])
                        .unwrap();
                }
            }
            batch.commit().unwrap();
        }
        let started = std::time::Instant::now();
        let conn = open_read_only(&path, None).unwrap();
        let extract = read(&conn, &info()).unwrap();
        println!("\n{} lignes lues en {:?}", extract.row_count(), started.elapsed());
        for format in Format::ALL {
            let destination = folder_of(&path, &format!("grosse.{}", format.extension()));
            let request = Request {
                format,
                layout: Layout::OneFile,
                csv: CsvOptions::default(),
                qif_order: crate::qif_import::DateOrder::DayMonth,
            };
            let started = std::time::Instant::now();
            let outcome = export(&extract, &info(), request, &destination).unwrap();
            let size: u64 = if destination.is_dir() {
                std::fs::read_dir(&destination).unwrap().map(|e| e.unwrap().metadata().unwrap().len()).sum()
            } else {
                std::fs::metadata(&destination).unwrap().len()
            };
            println!("  {:6} : {:?}, {} fichier(s), {} Mo", format.key(), started.elapsed(), outcome.files, size / 1_000_000);
        }
    }

    #[test]
    fn une_date_d_avant_mars_1900_part_en_texte() {
        assert_eq!(date_of("1900-03-01"), NaiveDate::from_ymd_opt(1900, 3, 1));
        assert_eq!(date_of("1900-02-28"), None);
        assert_eq!(date_of("1850-03-01"), None);
        assert_eq!(date_of("0001-01-01"), None);
        assert_eq!(date_of("9999-12-31"), NaiveDate::from_ymd_opt(9999, 12, 31));
    }

    /// **Le nom d'un export** : celui de la base, débarrassé de ce que les
    /// systèmes refusent, puis la date année-mois-jour.
    #[test]
    fn le_nom_d_un_export_porte_la_base_et_la_date() {
        let date = NaiveDate::from_ymd_opt(2026, 10, 19).unwrap();
        assert_eq!(export_stem("Comptes famille", date), "Comptes famille - export 2026-10-19");
        let cleaned = export_stem("Perso: 2026/oct?", date);
        assert!(cleaned.ends_with(" - export 2026-10-19"), "{cleaned}");
        assert!(!cleaned.contains([':', '/', '?', '\\', '*', '"', '<', '>', '|']), "{cleaned}");
        assert!(cleaned.starts_with("Perso"), "{cleaned}");
        assert_eq!(export_stem("", date), "Radinus - export 2026-10-19");
    }

    #[test]
    fn chaque_format_dit_s_il_ecrit_un_fichier_ou_un_dossier() {
        for format in Format::ALL {
            assert_eq!(Format::from_key(format.key()), Some(format));
        }
        assert_eq!(Format::from_key("docx"), None);
        for format in [Format::Csv, Format::Qif, Format::Ofx] {
            assert!(format.writes_a_folder(Layout::OneFile) && format.writes_a_folder(Layout::PerTable));
            assert!(!format.has_layout_choice());
        }
        assert!(!Format::Sqlite.writes_a_folder(Layout::PerTable));
        for format in [Format::Xlsx, Format::Ods, Format::Json, Format::Xml, Format::Sql] {
            assert!(format.has_layout_choice());
            assert!(!format.writes_a_folder(Layout::OneFile));
            assert!(format.writes_a_folder(Layout::PerTable));
        }
        assert!(Format::Qif.is_lossy() && Format::Ofx.is_lossy() && !Format::Csv.is_lossy());
    }

    /// **L'assistant écrit chaque format là où il l'a annoncé** : un fichier
    /// quand c'est un fichier, un dossier rempli quand c'est un dossier, et
    /// autant de fichiers qu'il en compte.
    #[test]
    fn l_assistant_ecrit_chaque_format_la_ou_il_l_annonce() {
        let (path, extract) = extract_of("assistant");
        let csv = CsvOptions { decimal_comma: true, quote_all: false };
        let qif_order = crate::qif_import::DateOrder::DayMonth;
        for format in Format::ALL {
            for layout in [Layout::OneFile, Layout::PerTable] {
                if !format.has_layout_choice() && layout == Layout::PerTable {
                    continue;
                }
                let name = format!("{} {:?}", format.key(), layout);
                let destination = if format.writes_a_folder(layout) {
                    folder_of(&path, &name)
                } else {
                    folder_of(&path, &format!("{name}.{}", format.extension()))
                };
                let request = Request { format, layout, csv, qif_order };
                let outcome = export(&extract, &info(), request, &destination).unwrap();
                assert_eq!(outcome.tables, extract.table_count(), "{name}");
                assert_eq!(outcome.rows, extract.row_count(), "{name}");
                if format.writes_a_folder(layout) {
                    let written = std::fs::read_dir(&destination).unwrap().count();
                    assert_eq!(written, outcome.files, "{name}");
                    let expected = match format {
                        Format::Qif | Format::Ofx => 1,
                        // Le JSON et le XML n'ont pas de fichier Export : son
                        // contenu est dans l'en-tête de chaque fichier. Les
                        // autres ont le leur, en plus des tables de données.
                        Format::Json | Format::Xml => extract.table_count(),
                        _ => extract.table_count() + 1,
                    };
                    assert_eq!(outcome.files, expected, "{name}");
                } else {
                    assert!(destination.is_file(), "{name}");
                    assert_eq!(outcome.files, 1, "{name}");
                }
                assert_eq!(outcome.accounts.is_some(), format.is_lossy(), "{name}");
                if format == Format::Csv {
                    assert!(outcome.replacements.total() > 0, "le point-virgule et le retour à la ligne");
                }
            }
        }
    }

    /// **La phrase de fin dit tout** : ce qui est parti, et chaque chose
    /// laissée de côté ou changée — jamais en silence.
    #[test]
    fn la_phrase_de_fin_dit_ce_qui_est_parti_et_ce_qui_ne_l_est_pas() {
        use crate::i18n::Language;
        let (path, extract) = extract_of("phrase");
        let csv = CsvOptions { decimal_comma: false, quote_all: false };
        let order = crate::qif_import::DateOrder::DayMonth;
        let tables = export(
            &extract,
            &info(),
            Request { format: Format::Csv, layout: Layout::PerTable, csv, qif_order: order },
            &folder_of(&path, "csv"),
        )
        .unwrap();
        let said = outcome_sentence(&tables, "Comptes famille", Language::French);
        assert!(said.starts_with("La base « Comptes famille » a été exportée"), "{said}");
        assert!(said.contains(&format!("{} tables", tables.tables)), "{said}");
        assert!(said.contains("remplacé"), "{said}");
        assert!(!said.contains('{') && !said.contains("base-export"), "{said}");

        let accounts = export(
            &extract,
            &info(),
            Request { format: Format::Qif, layout: Layout::OneFile, csv, qif_order: order },
            &folder_of(&path, "qif"),
        )
        .unwrap();
        let report = accounts.accounts.unwrap();
        assert!(report.undated > 0, "l'opération sans date de l'échantillon");
        let said = outcome_sentence(&accounts, "Comptes famille", Language::French);
        assert!(said.contains("1 compte"), "{said}");
        assert!(said.contains("sans date"), "{said}");
        assert!(!said.contains("remplacé"), "{said}");
        let english = outcome_sentence(&accounts, "Family", Language::English);
        assert!(english.contains("“Family”") && english.contains("without a date"), "{english}");
    }

    #[test]
    fn la_devise_s_ecrit_par_son_code_ou_son_signe() {
        use crate::preferences::Currency;
        assert_eq!(currency_label(&Currency::Euro, "$"), "EUR");
        assert_eq!(currency_label(&Currency::Cfa, ""), "XOF");
        assert_eq!(currency_label(&Currency::System, " € "), "€");
        assert_eq!(currency_label(&Currency::Custom("GBP".into()), ""), "GBP");
        assert_eq!(currency_label(&Currency::NoSign, "€"), "");
    }
}
