//! Reading a Radinus 1.9.3 backup archive and restoring it into a 2.0.0
//! SQLite database.
//!
//! Dossier reference: `06_FORMATS_SAUVEGARDE_IMPORT_EXPORT.md` §1,
//! `PLAN_ACTION.md` Phase 1 §1.3 — **strategic requirement**: importing the
//! archives produced by Radinus 1.9.3 as-is is the migration path for the
//! existing user base, and is explicitly non-negotiable.
//!
//! Decisions taken with the author on 25/07/2026, before writing this
//! module:
//! - **A restore wipes the target database.** The database is first reset to
//!   the blank prefilled state (`database::seed::reset_to_blank`), then every
//!   table the archive carries is emptied again and refilled from the
//!   archive. Nothing of the previous content survives. The prefilled rows
//!   therefore only survive for the two tables the archive does *not* carry
//!   (`StatutOperation`, `TypeCompte`), which is exactly why 1.9.3 does not
//!   back them up: the code recreates them.
//! - **"Complément" is recognized on the way in**: a sub-operation (non-zero
//!   parent) whose label is exactly `Complément` sets the dedicated
//!   `EstComplement` marker. The reverse direction (marker -> label) belongs
//!   to the archive *writer*, delivery 2.
//! - **Attachments are deferred.** The format puts the GUID-named files loose
//!   at the root of the zip, next to the JSON. Nothing here writes or reads
//!   them yet: the author asked to postpone that until he can exercise
//!   attachments through the interface (Phase 5). Non-JSON entries are
//!   ignored rather than treated as an error, so an archive that has them
//!   still restores its tables.
//! - **The software version is this build's, not the archive's.** A 1.9.3
//!   archive carries `VerSoftMajeur/Mineur/Debug = 1/9/0`; storing that in a
//!   2.0.0 database would be a lie about which program is running. Only
//!   `RunOnce`, `InitValDefaut` and the language come from the archive.
//!   `VerDataBase` is the *database* version, a single continuous number line
//!   (see `database::schema`): the archive says 9, this build is at 9, there
//!   is nothing to convert.
//!
//! The tables an archive never carries — `StatutOperation`, `TypeCompte`,
//! `TypeCategorie`, `ParamSecurite` — keep whatever the database already
//! holds; 1.9.3 does not back them up because the code recreates them, and
//! `ParamSecurite` deliberately never travels (the password is never
//! exported, 06 §1.2). Any *field* an archive carries that the schema does
//! not know is dropped without a word (author's ruling, 25/07/2026).

pub mod records;
pub mod writer;

use crate::database::{schema, seed};
use crate::domain::{
    Account, Attachment, Budget, Category, Check, Checkbook, Comment, NamedItem, Operation,
    OperationTemplate, RecurringOperationRule,
};
use rusqlite::Connection;
use serde::de::DeserializeOwned;
use std::collections::BTreeMap;
use std::io::Read;
use std::path::Path;

/// Prefix and suffix of the per-table entries inside the archive
/// (`radinus_sauve_operations.json`, ...). Anything else at the root — the
/// empty `_` entry, and the GUID-named attachment files — is not a table.
const TABLE_ENTRY_PREFIX: &str = "radinus_sauve_";
const TABLE_ENTRY_SUFFIX: &str = ".json";

/// **Ce qu'on accepte de réserver sur la seule parole d'une archive.**
///
/// `entry.size()` est la taille **déclarée** dans l'en-tête du zip. Personne
/// ne la vérifie, et une archive tronquée ou abîmée peut annoncer n'importe
/// quoi. `Vec::with_capacity` demandait alors des exaoctets à l'allocateur —
/// et un échec d'allocation, en Rust, n'est pas une panique qu'on rattrape :
/// c'est un `abort`. La fenêtre disparaissait, sans journal, sans une phrase
/// (audit du 03/08/2026, §7b).
///
/// Le module est justement écrit pour bien traiter « une archive tronquée, un
/// disque plein à mi-chemin ». C'était cette ligne qui l'annulait.
///
/// **Ce plafond ne limite pas ce qu'on lit**, seulement ce qu'on réserve
/// d'avance : `read_to_end` fait grandir le tampon tout seul au-delà, à la
/// mesure des octets qui arrivent vraiment. Une pièce jointe de 200 Mio se
/// restaure comme avant ; une archive qui en annonce 200 Pio ne fait plus
/// tomber Radinus.
const MOST_RESERVED_AHEAD: u64 = 16 * 1024 * 1024;

/// Everything that can go wrong reading or restoring an archive.
#[derive(Debug)]
pub enum BackupError {
    Io(std::io::Error),
    Zip(zip::result::ZipError),
    Sqlite(rusqlite::Error),
    /// A `radinus_sauve_*.json` entry is not valid JSON, or does not have the
    /// shape the format prescribes. `entry` names the file inside the zip so
    /// the message points at the actual culprit.
    MalformedJson {
        entry: String,
        source: serde_json::Error,
    },
    /// The root object of a table file is not keyed by the expected table
    /// name (the format is `{ "Operation": [ ... ] }`).
    UnexpectedRootKey { entry: String, expected: String },
    /// The file opens as a zip but carries none of the expected table
    /// entries: it is not a Radinus backup at all.
    NotARadinusBackup,
}

impl std::fmt::Display for BackupError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            BackupError::Io(e) => write!(f, "I/O error: {e}"),
            BackupError::Zip(e) => write!(f, "cannot read the backup archive: {e}"),
            BackupError::Sqlite(e) => write!(f, "database error during restore: {e}"),
            BackupError::MalformedJson { entry, source } => {
                write!(f, "{entry} is not a valid Radinus backup table: {source}")
            }
            BackupError::UnexpectedRootKey { entry, expected } => write!(
                f,
                "{entry} does not contain the expected \"{expected}\" table"
            ),
            BackupError::NotARadinusBackup => write!(
                f,
                "this archive contains no radinus_sauve_*.json file: it is not a Radinus backup"
            ),
        }
    }
}

impl std::error::Error for BackupError {}

impl From<std::io::Error> for BackupError {
    fn from(e: std::io::Error) -> Self {
        BackupError::Io(e)
    }
}
impl From<zip::result::ZipError> for BackupError {
    fn from(e: zip::result::ZipError) -> Self {
        BackupError::Zip(e)
    }
}
impl From<rusqlite::Error> for BackupError {
    fn from(e: rusqlite::Error) -> Self {
        BackupError::Sqlite(e)
    }
}

/// Ce qu'une table pesait dans l'archive lue.
///
/// **`present` est l'information qui manquait.** Jusqu'ici, une table absente
/// de l'archive et une table présente mais vide donnaient le même résultat :
/// un vecteur vide. Le journal de 1.9.3 distingue les deux — « fichier
/// inexistant » d'un côté, « Compte(0) SUCCES » de l'autre — et il a raison :
/// la première est une archive abîmée, la seconde une base sans comptes.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct TableRead {
    pub table: &'static str,
    pub stem: &'static str,
    /// Le fichier `radinus_sauve_<stem>.json` était-il dans l'archive ?
    pub present: bool,
    /// Le nombre d'enregistrements analysés. Zéro quand le fichier est absent.
    pub rows: usize,
    /// Le poids du JSON lu, en octets.
    pub bytes: usize,
}

/// The tables an archive carries, already parsed. Absent tables are empty
/// vectors: 1.9.3 always writes all nineteen files, but an archive missing
/// one restores the rest rather than failing.
#[derive(Debug, Default)]
pub struct Archive {
    pub affectations: Vec<records::AffectationRow>,
    pub banques: Vec<records::BankRow>,
    pub budget: Vec<records::BudgetRow>,
    pub cal_op_periodique: Vec<records::CalOpPeriodiqueRow>,
    pub categories: Vec<records::CategorieRow>,
    pub cheques: Vec<records::ChequeRow>,
    pub chequiers: Vec<records::ChequierRow>,
    pub commentaires: Vec<records::CommentaireRow>,
    pub comptes: Vec<records::CompteRow>,
    pub modeles_operation: Vec<records::ModeleOperationRow>,
    pub modes_operation: Vec<records::ModeOperationRow>,
    pub operations: Vec<records::OperationRow>,
    pub parametres: Vec<records::ParametresRow>,
    pub pieces_jointes: Vec<records::PiecesJointesRow>,
    pub postes_budget: Vec<records::PosteBudgetRow>,
    pub projets: Vec<records::ProjetsRow>,
    pub statuts_cheque: Vec<records::StatutChequeRow>,
    pub tiers: Vec<records::TiersRow>,
    /// The settings a database carries — one row per setting, its value written
    /// as JSON. Today there is exactly one, the currency.
    ///
    /// **Restored since 05/08/2026.** It used to be read as raw JSON and thrown
    /// away, on a July ruling made when this table held nothing worth keeping.
    /// It has held the currency since 04/08, and the ruling had not been
    /// revisited: an archive carried the right value, and the restore emptied
    /// the table without ever putting it back. Fabrice asked the question, and
    /// the loss was reproduced before being fixed.
    pub preferences: Vec<records::PreferencesRow>,
    /// Ce que l'archive portait, table par table, dans l'ordre d'écriture —
    /// de quoi journaliser la lecture comme 1.9.3 le fait.
    pub read: Vec<TableRead>,
}

/// How many rows each table contributed to a restore. Returned so a caller
/// (and the strategic acceptance test) can check the counts against the
/// source without re-querying every table.
#[derive(Debug, Default, PartialEq, Eq)]
pub struct RestoreReport {
    pub accounts: usize,
    pub operations: usize,
    pub checkbooks: usize,
    pub checks: usize,
    pub comments: usize,
    pub attachments: usize,
    pub payees: usize,
    pub categories: usize,
    pub banks: usize,
    pub assignments: usize,
    pub payment_modes: usize,
    pub budget_lines: usize,
    pub projects: usize,
    pub check_statuses: usize,
    pub budgets: usize,
    pub operation_templates: usize,
    pub recurring_rules: usize,
}

/// Reads and parses every table file in the archive at `path`. Does not touch
/// any database — see [`restore_into`] for that, or [`restore_file_into`] for
/// both at once.
pub fn read_archive(path: &Path) -> Result<Archive, BackupError> {
    let file = std::fs::File::open(path)?;
    let mut zip = zip::ZipArchive::new(file)?;

    // Entry name -> raw bytes, for the table files only. Read eagerly because
    // `ZipArchive` hands out one reader at a time and the parsing below needs
    // to jump between tables.
    let mut table_files: BTreeMap<String, Vec<u8>> = BTreeMap::new();
    for i in 0..zip.len() {
        let mut entry = zip.by_index(i)?;
        if !entry.is_file() {
            continue;
        }
        let name = entry.name().rsplit('/').next().unwrap_or("").to_string();
        if !(name.starts_with(TABLE_ENTRY_PREFIX) && name.ends_with(TABLE_ENTRY_SUFFIX)) {
            // The empty `_` entry, and the loose GUID-named attachment files.
            continue;
        }
        let mut bytes = Vec::with_capacity(entry.size().min(MOST_RESERVED_AHEAD) as usize);
        entry.read_to_end(&mut bytes)?;
        table_files.insert(name, bytes);
    }

    if table_files.is_empty() {
        return Err(BackupError::NotARadinusBackup);
    }

    // Ce que l'archive portait vraiment, table par table, avant de parler du
    // contenu : c'est la seule façon de distinguer « ce fichier n'était pas
    // là » de « cette table était vide ».
    let read = crate::backup::writer::table_names()
        .into_iter()
        .map(|(name, stem)| {
            let entry = format!("{TABLE_ENTRY_PREFIX}{stem}{TABLE_ENTRY_SUFFIX}");
            match table_files.get(&entry) {
                Some(bytes) => TableRead {
                    table: name,
                    stem,
                    present: true,
                    rows: rows_in(bytes, name),
                    bytes: bytes.len(),
                },
                None => TableRead {
                    table: name,
                    stem,
                    present: false,
                    rows: 0,
                    bytes: 0,
                },
            }
        })
        .collect();

    Ok(Archive {
        read,
        affectations: table(&table_files, "affectations", "Affectation")?,
        banques: table(&table_files, "banques", "Banques")?,
        budget: table(&table_files, "budget", "Budget")?,
        cal_op_periodique: table(&table_files, "calopperiodique", "CalOpPeriodique")?,
        categories: table(&table_files, "categories", "Categorie")?,
        cheques: table(&table_files, "cheque", "Cheque")?,
        chequiers: table(&table_files, "chequier", "Chequier")?,
        commentaires: table(&table_files, "commentaires", "Commentaire")?,
        comptes: table(&table_files, "comptes", "Compte")?,
        modeles_operation: table(&table_files, "modeleoperation", "ModeleOperation")?,
        modes_operation: table(&table_files, "modeoperation", "ModeOperation")?,
        operations: table(&table_files, "operations", "Operation")?,
        parametres: table(&table_files, "parametres", "Parametres")?,
        pieces_jointes: table(&table_files, "piecesjointes", "PiecesJointes")?,
        postes_budget: table(&table_files, "postesbudget", "PosteBudget")?,
        projets: table(&table_files, "projets", "Projets")?,
        statuts_cheque: table(&table_files, "statutcheque", "StatutCheque")?,
        tiers: table(&table_files, "tiers", "Tiers")?,
        preferences: table(&table_files, "preferences", "Preferences")?,
    })
}

/// Sort les **fichiers des pièces jointes** de l'archive et les pose dans
/// `folder`.
///
/// Tout ce qui n'est pas un fichier de table et pas l'entrée vide est une
/// pièce jointe : c'est ainsi que 1.9.3 les range, à la racine, sous leur nom
/// GUID. Rend le nom et le poids de chacun, pour le journal.
///
/// **Ne touche pas à la base** : les lignes viennent d'être restaurées par
/// `restore_into`, et ce sont elles qui désignent ces fichiers.
pub fn restore_attachments(
    archive: &Path,
    folder: &Path,
) -> Result<Vec<(String, usize)>, BackupError> {
    let file = std::fs::File::open(archive)?;
    let mut zip = zip::ZipArchive::new(file)?;
    let mut restored = Vec::new();
    for index in 0..zip.len() {
        let mut entry = zip.by_index(index)?;
        if !entry.is_file() {
            continue;
        }
        let name = entry.name().rsplit('/').next().unwrap_or("").to_string();
        let is_table = name.starts_with(TABLE_ENTRY_PREFIX) && name.ends_with(TABLE_ENTRY_SUFFIX);
        if is_table || name.is_empty() || name == crate::backup::writer::EMPTY_ENTRY {
            continue;
        }
        let mut bytes = Vec::with_capacity(entry.size().min(MOST_RESERVED_AHEAD) as usize);
        entry.read_to_end(&mut bytes)?;
        crate::attachments::restore_file(folder, &name, &bytes)?;
        restored.push((name, bytes.len()));
    }
    Ok(restored)
}

/// **Relit l'archive qu'on vient d'écrire, et dit ce qu'on y retrouve.**
///
/// C'est le contrôle que 1.9.3 ne pouvait pas faire, et il répond à la seule
/// question qui compte après une sauvegarde : est-elle utilisable ? Une
/// archive tronquée, un disque plein à mi-chemin, un fichier verrouillé par
/// un antivirus — rien de tout cela ne se voit à l'écriture, et tout se voit à
/// la relecture. On la fait donc tout de suite, pendant que l'utilisateur
/// regarde, plutôt que le jour où il en aura besoin.
///
/// L'archive est rouverte depuis le disque, comme le ferait une restauration :
/// c'est le même chemin de lecture, donc le contrôle porte vraiment sur ce
/// qu'une restauration trouverait.
pub fn verify_archive(path: &Path) -> Result<Vec<TableRead>, BackupError> {
    read_archive(path).map(|archive| archive.read)
}

/// Combien de lignes porte un fichier de table, sans le désérialiser dans son
/// type.
///
/// La lecture typée a lieu juste après ; ce comptage-ci sert au **journal**,
/// et il doit survivre à un fichier que le type refuserait. Un JSON illisible
/// donne zéro plutôt qu'une erreur : le journal dira que le fichier était là,
/// et la lecture typée dira, elle, pourquoi il n'a pas pu être repris.
fn rows_in(bytes: &[u8], table_name: &str) -> usize {
    serde_json::from_slice::<BTreeMap<String, Vec<serde_json::Value>>>(bytes)
        .ok()
        .and_then(|mut root| root.remove(table_name))
        .map(|rows| rows.len())
        .unwrap_or(0)
}

/// Parses one `radinus_sauve_<file_stem>.json` entry. The root is a single
/// object keyed by the table's schema-cased name, whose value is the array of
/// rows (06 §1.3). A missing entry yields an empty vector.
fn table<T: DeserializeOwned>(
    files: &BTreeMap<String, Vec<u8>>,
    file_stem: &str,
    table_name: &str,
) -> Result<Vec<T>, BackupError> {
    let entry = format!("{TABLE_ENTRY_PREFIX}{file_stem}{TABLE_ENTRY_SUFFIX}");
    let Some(bytes) = files.get(&entry) else {
        return Ok(Vec::new());
    };

    let mut root: BTreeMap<String, Vec<T>> =
        serde_json::from_slice(bytes).map_err(|source| BackupError::MalformedJson {
            entry: entry.clone(),
            source,
        })?;

    root.remove(table_name)
        .ok_or_else(|| BackupError::UnexpectedRootKey {
            entry,
            expected: table_name.to_string(),
        })
}

/// Reads the archive at `zip_path` and restores it into `conn`, replacing
/// everything the database currently holds.
pub fn restore_file_into(
    conn: &mut Connection,
    zip_path: &Path,
) -> Result<RestoreReport, BackupError> {
    let archive = read_archive(zip_path)?;
    restore_into(conn, &archive)
}

/// Restores `archive` into `conn`, replacing the database's entire contents.
///
/// Runs inside a single transaction: a technical failure (unreadable file,
/// I/O error) leaves the database exactly as it was, rather than
/// half-migrated. Foreign keys stay switched off throughout, and nothing is
/// verified before the commit: **a restore takes back everything it can**
/// (author's ruling, 25/07/2026). An archive whose rows point at things that
/// no longer exist still restores; refusing it would leave the user with
/// nothing at all, which is the worse outcome.
pub fn restore_into(conn: &mut Connection, archive: &Archive) -> Result<RestoreReport, BackupError> {
    conn.execute_batch("PRAGMA foreign_keys = OFF;")?;
    let result = restore_in_transaction(conn, archive);
    conn.execute_batch("PRAGMA foreign_keys = ON;")?;
    result
}

fn restore_in_transaction(
    conn: &mut Connection,
    archive: &Archive,
) -> Result<RestoreReport, BackupError> {
    let tx = conn.transaction()?;

    // Step 1: back to the blank prefilled state (author's ruling).
    seed::reset_to_blank(&tx)?;

    // Step 2: every table the archive carries is emptied and refilled, in
    // dependency order.
    let report = RestoreReport {
        assignments: replace_named(
            &tx,
            "Affectation",
            "IDAffectation",
            "Libelle",
            &archive.affectations,
        )?,
        payment_modes: replace_named(
            &tx,
            "ModeOperation",
            "IDModeOperation",
            "Libelle",
            &archive.modes_operation,
        )?,
        budget_lines: replace_named(
            &tx,
            "PosteBudget",
            "IDPosteBudget",
            "Libelle",
            &archive.postes_budget,
        )?,
        projects: replace_named(&tx, "Projets", "IDProjets", "Libelle", &archive.projets)?,
        payees: replace_named(&tx, "Tiers", "IDTiers", "Libelle", &archive.tiers)?,
        banks: insert_banks(&tx, archive)?,
        check_statuses: insert_check_statuses(&tx, archive)?,
        categories: insert_categories(&tx, archive)?,
        accounts: insert_accounts(&tx, archive)?,
        checkbooks: insert_checkbooks(&tx, archive)?,
        checks: insert_checks(&tx, archive)?,
        operations: insert_operations(&tx, archive)?,
        comments: insert_comments(&tx, archive)?,
        attachments: insert_attachments(&tx, archive)?,
        recurring_rules: insert_recurring_rules(&tx, archive)?,
        operation_templates: insert_operation_templates(&tx, archive)?,
        budgets: insert_budgets(&tx, archive)?,
    };
    restore_settings(&tx, archive)?;
    insert_preferences(&tx, archive)?;

    // No consistency check of any kind before committing (author's ruling,
    // 25/07/2026): a restore takes back everything it possibly can. A damaged
    // or partial archive must land in the database as-is rather than be
    // refused — the user keeps what could be read, instead of nothing.
    tx.commit()?;
    Ok(report)
}

/// Empties a simple `IDxxx` + label nomenclature and refills it from the
/// archive's rows.
fn replace_named<R>(
    tx: &rusqlite::Transaction<'_>,
    table_name: &str,
    id_column: &str,
    label_column: &str,
    rows: &[R],
) -> Result<usize, BackupError>
where
    R: NamedRow,
{
    let items: Vec<NamedItem> = rows.iter().map(NamedRow::to_named_item).collect();
    insert_named(tx, table_name, id_column, label_column, &items)
}

fn insert_named(
    tx: &rusqlite::Transaction<'_>,
    table_name: &str,
    id_column: &str,
    label_column: &str,
    items: &[NamedItem],
) -> Result<usize, BackupError> {
    tx.execute(&format!("DELETE FROM {table_name}"), [])?;
    let mut stmt = tx.prepare(&format!(
        "INSERT INTO {table_name} ({id_column}, {label_column}) VALUES (?1, ?2)"
    ))?;
    for item in items {
        stmt.execute(rusqlite::params![item.id, item.label])?;
    }
    Ok(items.len())
}

/// Lets [`replace_named`] accept any of the five simple nomenclature row
/// types without a macro at the call site.
trait NamedRow {
    fn to_named_item(&self) -> NamedItem;
}

macro_rules! impl_named_row {
    ($($t:ty),+ $(,)?) => {
        $(impl NamedRow for $t {
            fn to_named_item(&self) -> NamedItem {
                self.to_domain()
            }
        })+
    };
}

impl_named_row!(
    records::AffectationRow,
    records::ModeOperationRow,
    records::PosteBudgetRow,
    records::ProjetsRow,
    records::TiersRow,
);

fn insert_banks(tx: &rusqlite::Transaction<'_>, archive: &Archive) -> Result<usize, BackupError> {
    let items: Vec<NamedItem> = archive.banques.iter().map(|r| r.to_domain()).collect();
    insert_named(tx, "Banques", "IDBanques", "NomBanque", &items)
}

fn insert_check_statuses(
    tx: &rusqlite::Transaction<'_>,
    archive: &Archive,
) -> Result<usize, BackupError> {
    tx.execute("DELETE FROM StatutCheque", [])?;
    let mut stmt = tx.prepare(
        "INSERT INTO StatutCheque (IDStatutCheque, Libelle, Description) VALUES (?1, ?2, ?3)",
    )?;
    for row in &archive.statuts_cheque {
        stmt.execute(rusqlite::params![
            row.id_statut_cheque,
            row.libelle,
            row.description
        ])?;
    }
    Ok(archive.statuts_cheque.len())
}

fn insert_categories(
    tx: &rusqlite::Transaction<'_>,
    archive: &Archive,
) -> Result<usize, BackupError> {
    tx.execute("DELETE FROM Categorie", [])?;
    let mut stmt = tx.prepare(
        "INSERT INTO Categorie (IDCategorie, Libelle, IDTypeCategorie, IDPosteBudget)
         VALUES (?1, ?2, ?3, ?4)",
    )?;
    for row in &archive.categories {
        let c: Category = row.to_domain();
        stmt.execute(rusqlite::params![
            c.id,
            c.label,
            c.category_type_id,
            c.budget_line_id
        ])?;
    }
    Ok(archive.categories.len())
}

fn insert_accounts(
    tx: &rusqlite::Transaction<'_>,
    archive: &Archive,
) -> Result<usize, BackupError> {
    tx.execute("DELETE FROM Compte", [])?;
    let mut stmt = tx.prepare(
        "INSERT INTO Compte (
            IDCompte, Libelle, IDTypeCompte, IDBanques,
            ReportPointe, ReportEngage, ReportPrevu,
            SoldeBanque, SoldeReel, SoldeFinal,
            NomTitulaire, AdresseTitulaire,
            COBCodeBanque, COBCodeGuichet, COBNumCompte, COBClefRIB, COBIBAN, COBBIC,
            AdresseAgenceBank,
            DateOuverture, DateCloture, NumProchCheque, CompteCloture, Devise
         ) VALUES (
            ?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12,
            ?13, ?14, ?15, ?16, ?17, ?18, ?19, ?20, ?21, ?22, ?23, ?24
         )",
    )?;
    for row in &archive.comptes {
        let a: Account = row.to_domain();
        stmt.execute(rusqlite::params![
            a.id,
            a.label,
            a.account_type_id,
            a.bank_id,
            a.opening_balance_pointed,
            a.opening_balance_committed,
            a.opening_balance_planned,
            a.balance_bank,
            a.balance_real,
            a.balance_final,
            a.holder_name,
            a.holder_address,
            a.rib_bank_code,
            a.rib_branch_code,
            a.rib_account_number,
            a.rib_key,
            a.iban,
            a.bic,
            a.branch_address,
            iso(a.opening_date),
            iso(a.closing_date),
            a.next_check_number,
            a.is_closed,
            a.currency,
        ])?;
    }
    Ok(archive.comptes.len())
}

fn insert_checkbooks(
    tx: &rusqlite::Transaction<'_>,
    archive: &Archive,
) -> Result<usize, BackupError> {
    tx.execute("DELETE FROM Chequier", [])?;
    let mut stmt = tx.prepare(
        "INSERT INTO Chequier (
            IDChequier, IDReferenceChq, DateRecep, NumPremierChq, NumDernChq,
            QteChq, FormatNumChq, Commentaires, IDCompte
         ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9)",
    )?;
    for row in &archive.chequiers {
        let c: Checkbook = row.to_domain();
        stmt.execute(rusqlite::params![
            c.id,
            c.reference,
            iso(c.received_date),
            c.first_check_number,
            c.last_check_number,
            c.check_count,
            c.check_number_format,
            c.comments,
            c.account_id,
        ])?;
    }
    Ok(archive.chequiers.len())
}

fn insert_checks(tx: &rusqlite::Transaction<'_>, archive: &Archive) -> Result<usize, BackupError> {
    tx.execute("DELETE FROM Cheque", [])?;
    let mut stmt = tx.prepare(
        "INSERT INTO Cheque (
            IDCheque, NumChq, IDChequier, DateEmission, Beneficiaire,
            Montant, Commentaires, LieuEmission, IDStatutCheque
         ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9)",
    )?;
    for row in &archive.cheques {
        let c: Check = row.to_domain();
        stmt.execute(rusqlite::params![
            c.id,
            c.number,
            c.checkbook_id,
            iso(c.issue_date),
            c.payee_name,
            c.amount,
            c.comments,
            c.issue_place,
            c.check_status_id,
        ])?;
    }
    Ok(archive.cheques.len())
}

fn insert_operations(
    tx: &rusqlite::Transaction<'_>,
    archive: &Archive,
) -> Result<usize, BackupError> {
    tx.execute("DELETE FROM Operation", [])?;
    let mut stmt = tx.prepare(
        "INSERT INTO Operation (
            IDOperation, Libelle, Date, Montant, IDModeOperation, IDCategorie,
            IDAffectation, IDCompte, IDStatutOperation, DatePointage,
            SoldePointe, FitID, ReferencePaiement, NumRelevBanque,
            IDOperationParent, EstParent, GUIDCalOpPeriode, IDCheque,
            IDTiers, IDProjets, EstComplement
         ) VALUES (
            ?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10,
            ?11, ?12, ?13, ?14, ?15, ?16, ?17, ?18, ?19, ?20, ?21
         )",
    )?;
    for row in &archive.operations {
        let o: Operation = row.to_domain();
        stmt.execute(rusqlite::params![
            o.id,
            o.label,
            iso(o.date),
            o.amount,
            o.payment_mode_id,
            o.category_id,
            o.assignment_id,
            o.account_id,
            o.operation_status_id,
            iso(o.clearing_date),
            o.pointed_balance,
            o.fit_id,
            o.payment_reference,
            o.bank_statement_number,
            o.parent_operation_id,
            o.has_children,
            o.recurring_rule_guid,
            o.check_id,
            o.payee_id,
            o.project_id,
            o.is_complement,
        ])?;
    }
    Ok(archive.operations.len())
}

fn insert_comments(tx: &rusqlite::Transaction<'_>, archive: &Archive) -> Result<usize, BackupError> {
    tx.execute("DELETE FROM Commentaire", [])?;
    let mut stmt = tx.prepare(
        "INSERT INTO Commentaire (IDCommentaire, CommentaireTxt, IDOperation) VALUES (?1, ?2, ?3)",
    )?;
    for row in &archive.commentaires {
        let c: Comment = row.to_domain();
        stmt.execute(rusqlite::params![c.id, c.text, c.operation_id])?;
    }
    Ok(archive.commentaires.len())
}

fn insert_attachments(
    tx: &rusqlite::Transaction<'_>,
    archive: &Archive,
) -> Result<usize, BackupError> {
    tx.execute("DELETE FROM PiecesJointes", [])?;
    let mut stmt = tx.prepare(
        "INSERT INTO PiecesJointes (
            IDPiecesJointes, IDOperation, NomFichier, NomFichierGUID,
            PathRelFichier, TailleFich, MiMeType, DateAjout, CheckSumInfo, NoteInfo
         ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10)",
    )?;
    for row in &archive.pieces_jointes {
        let a: Attachment = row.to_domain();
        stmt.execute(rusqlite::params![
            a.id,
            a.operation_id,
            a.original_filename,
            a.stored_filename_guid,
            a.relative_path,
            a.size_bytes,
            a.mime_type,
            iso(a.added_date),
            a.checksum,
            a.note,
        ])?;
    }
    Ok(archive.pieces_jointes.len())
}

fn insert_recurring_rules(
    tx: &rusqlite::Transaction<'_>,
    archive: &Archive,
) -> Result<usize, BackupError> {
    tx.execute("DELETE FROM CalOpPeriodique", [])?;
    let mut stmt = tx.prepare(
        "INSERT INTO CalOpPeriodique (
            GUIDCalOpPeriode, Libelle, IDCompte, IDModeOperation, IDCategorie,
            IDAffectation, IDStatutOperation, IDTiers, IDProjets, Montant,
            DateProchOp, Periode, PeriodeFreq, PeriodeNbrRepete,
            ModeFinInsertion, DateFin, DateDernOpGen,
            NbrOpInsert, NbrOpAnterieur, MontantInsert, IDOperation
         ) VALUES (
            ?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10,
            ?11, ?12, ?13, ?14, ?15, ?16, ?17, ?18, ?19, ?20, ?21
         )",
    )?;
    for row in &archive.cal_op_periodique {
        let r: RecurringOperationRule = row.to_domain();
        stmt.execute(rusqlite::params![
            r.guid,
            r.label,
            r.account_id,
            r.payment_mode_id,
            r.category_id,
            r.assignment_id,
            r.operation_status_id,
            r.payee_id,
            r.project_id,
            r.amount,
            iso(r.next_date),
            r.period_unit,
            r.period_frequency,
            r.repeat_count,
            r.end_mode,
            iso(r.end_date),
            iso(r.last_generated_date),
            r.inserted_count,
            r.previous_count,
            r.generated_amount_total,
            r.operation_id,
        ])?;
    }
    Ok(archive.cal_op_periodique.len())
}

fn insert_operation_templates(
    tx: &rusqlite::Transaction<'_>,
    archive: &Archive,
) -> Result<usize, BackupError> {
    tx.execute("DELETE FROM ModeleOperation", [])?;
    let mut stmt = tx.prepare(
        "INSERT INTO ModeleOperation (
            IDModeleOperation, Libelle, Montant, IDModeOperation, IDCategorie,
            IDAffectation, IDStatutOperation, IDTiers, IDProjets
         ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9)",
    )?;
    for row in &archive.modeles_operation {
        let m: OperationTemplate = row.to_domain();
        stmt.execute(rusqlite::params![
            m.id,
            m.label,
            m.amount,
            m.payment_mode_id,
            m.category_id,
            m.assignment_id,
            m.operation_status_id,
            m.payee_id,
            m.project_id,
        ])?;
    }
    Ok(archive.modeles_operation.len())
}

fn insert_budgets(tx: &rusqlite::Transaction<'_>, archive: &Archive) -> Result<usize, BackupError> {
    tx.execute("DELETE FROM Budget", [])?;
    let mut stmt = tx.prepare(
        "INSERT INTO Budget (IDBudget, Annee, Mois, IDPosteBudget, Montant)
         VALUES (?1, ?2, ?3, ?4, ?5)",
    )?;
    for row in &archive.budget {
        let b: Budget = row.to_domain();
        stmt.execute(rusqlite::params![
            b.id,
            b.year,
            b.month,
            b.budget_line_id,
            b.amount
        ])?;
    }
    Ok(archive.budget.len())
}

/// Updates the single `Parametres` row from the archive. Only the fields that
/// describe the *user's* setup travel (RunOnce, InitValDefaut, language); the
/// software version stays this build's, and the database version is already
/// on the same number line (see the module doc comment).
/// **Puts the settings back, which the wipe had removed.**
///
/// Written like every other table: empty, then refill from the archive. The one
/// difference is the guard on the key — a row whose name is empty comes from an
/// archive whose shape we do not know, and it is skipped rather than written or
/// refused.
///
/// An archive carrying no preferences at all leaves the table empty, and the
/// currency falls back to its default. That is the right answer for a 1.9.3
/// archive: it never knew about it.
fn insert_preferences(
    tx: &rusqlite::Transaction<'_>,
    archive: &Archive,
) -> Result<usize, BackupError> {
    tx.execute("DELETE FROM Preferences", [])?;
    let mut stmt = tx.prepare(
        "INSERT INTO Preferences (IDPreferences, Cle, ValeurJSON) VALUES (?1, ?2, ?3)",
    )?;
    let mut written = 0usize;
    for row in &archive.preferences {
        if row.cle.trim().is_empty() {
            continue;
        }
        stmt.execute(rusqlite::params![
            row.id_preferences,
            row.cle,
            row.valeur_json
        ])?;
        written += 1;
    }
    Ok(written)
}

fn restore_settings(
    tx: &rusqlite::Transaction<'_>,
    archive: &Archive,
) -> Result<(), BackupError> {
    let Some(row) = archive.parametres.first() else {
        return Ok(());
    };
    let settings = row.to_domain(schema::CURRENT_SCHEMA_VERSION);
    tx.execute(
        "UPDATE Parametres SET
            RunOnce = ?1, InitValDefaut = ?2,
            VerSoftMajeur = ?3, VerSoftMineur = ?4, VerSoftDebug = ?5,
            VerDataBase = ?6, UtiliseLangue = ?7
         WHERE IDParametres = 1",
        rusqlite::params![
            settings.run_once,
            settings.init_default_values,
            settings.software_version_major,
            settings.software_version_minor,
            settings.software_version_patch,
            settings.db_schema_version,
            settings.language,
        ],
    )?;
    Ok(())
}

/// Renders an optional date the way the SQLite columns store it (ISO-8601
/// text, NULL when absent — see `database::schema`).
fn iso(date: Option<time_compute::NaiveDate>) -> Option<String> {
    date.map(|d| d.to_string())
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::Write;
    use std::sync::atomic::{AtomicU32, Ordering};

    static COUNTER: AtomicU32 = AtomicU32::new(0);

    /// A scratch path guaranteed not to exist: leftovers from an earlier
    /// (possibly failed) run would otherwise be reopened by
    /// `create_new_database`, which expects a fresh path.
    fn scratch(label: &str, ext: &str) -> std::path::PathBuf {
        let n = COUNTER.fetch_add(1, Ordering::SeqCst);
        let path = std::env::temp_dir().join(format!("radinus_backup_test_{label}_{n}.{ext}"));
        std::fs::remove_file(&path).ok();
        path
    }

    /// Builds a miniature but structurally faithful archive: the empty `_`
    /// entry, one loose "attachment" file that must be ignored, and a handful
    /// of table files including a parent operation with its "Complément"
    /// sub-operation.
    fn write_sample_archive(path: &std::path::Path) {
        let file = std::fs::File::create(path).unwrap();
        let mut zip = zip::ZipWriter::new(file);
        let opts: zip::write::FileOptions<'_, ()> = zip::write::FileOptions::default();

        let entries: [(&str, &str); 8] = [
            ("_", ""),
            (
                "radinus_sauve_affectations.json",
                r#"{ "Affectation":[ { "IDAffectation":1, "Libelle":"Perso" } ] }"#,
            ),
            (
                "radinus_sauve_banques.json",
                r#"{ "Banques":[ { "IDBanques":21, "NomBanque":"La Banque Postale" } ] }"#,
            ),
            (
                "radinus_sauve_postesbudget.json",
                r#"{ "PosteBudget":[ { "IDPosteBudget":3, "Libelle":"Courses" } ] }"#,
            ),
            (
                "radinus_sauve_categories.json",
                r#"{ "Categorie":[ { "IDCategorie":15, "Libelle":"Alimentation", "IDTypeCategorie":2, "IDPosteBudget":3 } ] }"#,
            ),
            (
                "radinus_sauve_comptes.json",
                r#"{ "Compte":[ { "IDCompte":1, "Libelle":"CCP", "IDTypeCompte":1, "IDBanques":21, "ReportPointe":5972.54, "ReportEngage":0, "ReportPrevu":0, "SoldeBanque":1549.81, "SoldeReel":1549.81, "SoldeFinal":1549.81, "NomTitulaire":"", "AdresseTitulaire":"", "COBCodeBanque":"", "COBCodeGuichet":"", "COBNumCompte":"", "COBClefRIB":"", "COBIBAN":"", "COBBIC":"", "AdresseAgenceBank":"", "DateOuverture":"", "DateCloture":"", "NumProchCheque":0, "CompteCloture":false, "Devise":"EUR" } ] }"#,
            ),
            (
                "radinus_sauve_operations.json",
                r#"{ "Operation":[
                    { "IDOperation":1, "Libelle":"RETRAIT", "Date":"20260115", "Montant":-100, "IDModeOperation":0, "IDCategorie":15, "IDAffectation":1, "IDCompte":1, "IDStatutOperation":1, "DatePointage":"20260115", "SoldePointe":0, "FitID":"", "ReferencePaiement":"", "NumRelevBanque":"", "IDOperationParent":0, "EstParent":true, "GUIDCalOpPeriode":"", "IDCheque":0, "IDTiers":0, "IDProjets":0 },
                    { "IDOperation":2, "Libelle":"Courses", "Date":"20260115", "Montant":-30, "IDModeOperation":0, "IDCategorie":15, "IDAffectation":1, "IDCompte":1, "IDStatutOperation":1, "DatePointage":"", "SoldePointe":0, "FitID":"", "ReferencePaiement":"", "NumRelevBanque":"", "IDOperationParent":1, "EstParent":false, "GUIDCalOpPeriode":"", "IDCheque":0, "IDTiers":0, "IDProjets":0 },
                    { "IDOperation":3, "Libelle":"Complément", "Date":"20260115", "Montant":-70, "IDModeOperation":0, "IDCategorie":15, "IDAffectation":1, "IDCompte":1, "IDStatutOperation":1, "DatePointage":"", "SoldePointe":0, "FitID":"", "ReferencePaiement":"", "NumRelevBanque":"", "IDOperationParent":1, "EstParent":false, "GUIDCalOpPeriode":"", "IDCheque":0, "IDTiers":0, "IDProjets":0 }
                ] }"#,
            ),
            (
                "radinus_sauve_parametres.json",
                r#"{ "Parametres":[ { "IDParametres":1, "RunOnce":true, "InitValDefaut":true, "VerSoftMajeur":1, "VerSoftMineur":9, "VerSoftDebug":0, "VerDataBase":9, "UtiliseLangue":5 } ] }"#,
            ),
        ];

        for (name, body) in entries {
            zip.start_file(name, opts).unwrap();
            zip.write_all(body.as_bytes()).unwrap();
        }
        // A loose GUID-named file, as attachments appear: must be ignored.
        zip.start_file("a3f2c1d4-0000-4000-8000-000000000001.pdf", opts)
            .unwrap();
        zip.write_all(b"%PDF-1.4 not a real pdf").unwrap();

        zip.finish().unwrap();
    }

    fn restored_sample() -> (Connection, RestoreReport) {
        let archive_path = scratch("sample", "zip");
        write_sample_archive(&archive_path);

        let db_path = scratch("sample_db", "sqlite");
        let mut conn = crate::database::create_new_database(&db_path).unwrap();
        let report = restore_file_into(&mut conn, &archive_path).unwrap();

        std::fs::remove_file(&archive_path).ok();
        std::fs::remove_file(&db_path).ok();
        (conn, report)
    }

    /// **Un fichier absent n'est pas une table vide.** L'archive miniature ne
    /// porte que sept des dix-neuf fichiers ; le journal doit pouvoir dire
    /// lesquels manquaient, au lieu de laisser croire à douze tables vides.
    #[test]
    fn l_archive_dit_quels_fichiers_elle_portait() {
        let path = scratch("presence", "zip");
        write_sample_archive(&path);
        let archive = read_archive(&path).unwrap();
        std::fs::remove_file(&path).ok();

        assert_eq!(archive.read.len(), 19, "les dix-neuf tables sont décrites");
        let present: Vec<&str> = archive
            .read
            .iter()
            .filter(|table| table.present)
            .map(|table| table.table)
            .collect();
        assert_eq!(present.len(), 7, "sept fichiers dans l'archive miniature");
        assert!(present.contains(&"Compte"));
        assert!(present.contains(&"Operation"));

        let comptes = archive.read.iter().find(|t| t.table == "Compte").unwrap();
        assert_eq!(comptes.rows, 1);
        assert!(comptes.bytes > 0);

        let cheques = archive.read.iter().find(|t| t.table == "Cheque").unwrap();
        assert!(!cheques.present);
        assert_eq!(cheques.rows, 0);
        assert_eq!(cheques.bytes, 0);
    }

    /// **La relecture de ce qu'on vient d'écrire.** C'est le contrôle que
    /// 1.9.3 ne pouvait pas faire : une archive tronquée ne se voit pas à
    /// l'écriture, elle se voit à la lecture — et le jour où l'on en a besoin
    /// est le pire moment pour l'apprendre.
    #[test]
    fn une_archive_ecrite_se_relit_entierement() {
        let db_path = scratch("verify_db", "sqlite");
        let conn = crate::database::create_new_database(&db_path).unwrap();
        let archive_path = scratch("verify", "zip");
        let written = crate::backup::writer::write_archive(&conn, &archive_path).unwrap();

        let read = verify_archive(&archive_path).unwrap();
        std::fs::remove_file(&archive_path).ok();
        std::fs::remove_file(&db_path).ok();

        assert_eq!(read.len(), written.len());
        for table in &read {
            assert!(table.present, "{} manque à l'archive relue", table.table);
        }
        let written_rows: usize = written.iter().map(|t| t.rows).sum();
        let read_rows: usize = read.iter().map(|t| t.rows).sum();
        assert_eq!(read_rows, written_rows, "les comptes ne se retrouvent pas");
    }

    /// Une archive coupée en deux ne se relit pas, et le dit.
    #[test]
    fn une_archive_tronquee_est_refusee_a_la_relecture() {
        let db_path = scratch("truncated_db", "sqlite");
        let conn = crate::database::create_new_database(&db_path).unwrap();
        let archive_path = scratch("truncated", "zip");
        crate::backup::writer::write_archive(&conn, &archive_path).unwrap();

        let bytes = std::fs::read(&archive_path).unwrap();
        std::fs::write(&archive_path, &bytes[..bytes.len() / 2]).unwrap();

        let outcome = verify_archive(&archive_path);
        std::fs::remove_file(&archive_path).ok();
        std::fs::remove_file(&db_path).ok();
        assert!(outcome.is_err(), "une archive tronquée doit être refusée");
    }

    /// **Le voyage complet d'une pièce jointe** : jointe à une opération,
    /// emportée par la sauvegarde, ressortie par la restauration, et intacte
    /// à l'arrivée — la somme de contrôle le dit.
    #[test]
    fn une_piece_jointe_fait_l_aller_et_retour_par_l_archive() {
        let db_path = scratch("pj_db", "sqlite");
        let conn = crate::database::create_new_database(&db_path).unwrap();
        conn.execute("INSERT INTO Compte (IDCompte, Libelle) VALUES (1, 'CCP')", [])
            .unwrap();
        conn.execute(
            "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte, IDStatutOperation)
             VALUES (1, 'ACHAT', '2026-01-05', -1000000, 1, 1)",
            [],
        )
        .unwrap();

        // Le dossier des pièces jointes de cette base, et un fichier dedans.
        let folder = scratch("pj_folder", "dir");
        std::fs::create_dir_all(&folder).unwrap();
        let source = folder.join("source.txt");
        std::fs::write(&source, b"une facture, ou presque").unwrap();
        let joined = crate::attachments::add(
            &conn,
            1,
            &source,
            &folder,
            crate::domain::NaiveDate::from_ymd_opt(2026, 8, 1).unwrap(),
        )
        .unwrap();
        std::fs::remove_file(&source).unwrap();

        let archive_path = scratch("pj", "zip");
        let (_, files) =
            crate::backup::writer::write_archive_with_attachments(&conn, &archive_path, Some(&folder))
                .unwrap();
        assert_eq!(files.len(), 1);
        assert!(files[0].found);
        assert_eq!(files[0].guid_name, joined.guid_name);

        // On efface le fichier du disque, puis on restaure.
        std::fs::remove_file(crate::attachments::path_in(&folder, &joined.guid_name)).unwrap();
        let restored = restore_attachments(&archive_path, &folder).unwrap();
        assert_eq!(restored.len(), 1);

        let back = crate::attachments::path_in(&folder, &joined.guid_name);
        assert!(back.is_file(), "le fichier est revenu");
        assert_eq!(
            crate::attachments::is_intact(&back, &joined.checksum),
            Some(true),
            "et il est identique à ce qui avait été joint"
        );

        std::fs::remove_dir_all(&folder).ok();
        std::fs::remove_file(&archive_path).ok();
        std::fs::remove_file(&db_path).ok();
    }

    /// Sans pièce jointe, l'archive garde l'entrée vide de 1.9.3 : le format
    /// ne bouge pas pour les bases qui n'en ont pas.
    #[test]
    fn sans_piece_jointe_l_archive_garde_son_entree_vide() {
        let db_path = scratch("vide_db", "sqlite");
        let conn = crate::database::create_new_database(&db_path).unwrap();
        let folder = scratch("vide_folder", "dir");
        let archive_path = scratch("vide", "zip");
        let (_, files) =
            crate::backup::writer::write_archive_with_attachments(&conn, &archive_path, Some(&folder))
                .unwrap();
        assert!(files.is_empty());

        let file = std::fs::File::open(&archive_path).unwrap();
        let zip = zip::ZipArchive::new(file).unwrap();
        let names: Vec<String> = zip.file_names().map(str::to_string).collect();
        assert!(names.iter().any(|name| name == "."), "l'entrée vide est là");

        std::fs::remove_file(&archive_path).ok();
        std::fs::remove_file(&db_path).ok();
    }

    /// Un fichier que la base désigne mais que le disque n'a plus est
    /// **signalé**, pas fatal : refuser toute la sauvegarde pour une pièce
    /// égarée serait une drôle de façon de protéger les données.
    #[test]
    fn une_piece_jointe_egaree_ne_fait_pas_echouer_la_sauvegarde() {
        let db_path = scratch("egaree_db", "sqlite");
        let conn = crate::database::create_new_database(&db_path).unwrap();
        conn.execute("INSERT INTO Compte (IDCompte, Libelle) VALUES (1, 'CCP')", [])
            .unwrap();
        conn.execute(
            "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte, IDStatutOperation)
             VALUES (1, 'ACHAT', '2026-01-05', -1000000, 1, 1)",
            [],
        )
        .unwrap();
        conn.execute(
            "INSERT INTO PiecesJointes
             (IDPiecesJointes, IDOperation, NomFichier, NomFichierGUID, PathRelFichier,
              TailleFich, MiMeType, DateAjout, CheckSumInfo, NoteInfo)
             VALUES (1, 1, 'perdu.pdf', 'aaaa.pdf', '', 10, 'application/pdf', '2026-08-01', '', '')",
            [],
        )
        .unwrap();

        let folder = scratch("egaree_folder", "dir");
        let archive_path = scratch("egaree", "zip");
        let (tables, files) =
            crate::backup::writer::write_archive_with_attachments(&conn, &archive_path, Some(&folder))
                .unwrap();
        assert_eq!(tables.len(), 19, "toutes les tables sont là");
        assert_eq!(files.len(), 1);
        assert!(!files[0].found, "la pièce égarée est signalée");
        assert!(archive_path.is_file());

        std::fs::remove_file(&archive_path).ok();
        std::fs::remove_file(&db_path).ok();
    }

    #[test]
    fn reads_every_table_of_an_archive() {
        let path = scratch("read", "zip");
        write_sample_archive(&path);
        let archive = read_archive(&path).unwrap();

        assert_eq!(archive.comptes.len(), 1);
        assert_eq!(archive.operations.len(), 3);
        assert_eq!(archive.categories.len(), 1);
        assert_eq!(archive.parametres.len(), 1);
        // Tables the sample doesn't carry come back empty, not missing.
        assert!(archive.cheques.is_empty());
        std::fs::remove_file(&path).ok();
    }

    #[test]
    fn a_zip_without_table_files_is_rejected() {
        let path = scratch("foreign", "zip");
        {
            let file = std::fs::File::create(&path).unwrap();
            let mut zip = zip::ZipWriter::new(file);
            let opts: zip::write::FileOptions<'_, ()> = zip::write::FileOptions::default();
            zip.start_file("readme.txt", opts).unwrap();
            zip.write_all(b"not a Radinus backup").unwrap();
            zip.finish().unwrap();
        }
        assert!(matches!(
            read_archive(&path),
            Err(BackupError::NotARadinusBackup)
        ));
        std::fs::remove_file(&path).ok();
    }

    #[test]
    fn restore_reports_the_row_counts_it_wrote() {
        let (_conn, report) = restored_sample();
        assert_eq!(report.accounts, 1);
        assert_eq!(report.operations, 3);
        assert_eq!(report.categories, 1);
        assert_eq!(report.banks, 1);
    }

    #[test]
    fn restore_replaces_the_prefilled_nomenclatures() {
        let (conn, _) = restored_sample();
        // The blank database ships 30 banks and 45 categories; the archive
        // carries one of each, and the archive wins outright.
        let banks: i64 = conn
            .query_row("SELECT COUNT(*) FROM Banques", [], |r| r.get(0))
            .unwrap();
        let categories: i64 = conn
            .query_row("SELECT COUNT(*) FROM Categorie", [], |r| r.get(0))
            .unwrap();
        assert_eq!((banks, categories), (1, 1));
    }

    #[test]
    fn restore_keeps_the_tables_the_archive_does_not_carry() {
        let (conn, _) = restored_sample();
        // StatutOperation and TypeCompte are never backed up: the prefilled
        // rows must survive the restore.
        let statuses: i64 = conn
            .query_row("SELECT COUNT(*) FROM StatutOperation", [], |r| r.get(0))
            .unwrap();
        let account_types: i64 = conn
            .query_row("SELECT COUNT(*) FROM TypeCompte", [], |r| r.get(0))
            .unwrap();
        assert_eq!((statuses, account_types), (3, 11));
    }

    #[test]
    fn restore_sets_the_complement_marker_on_the_legacy_labelled_sub_operation() {
        let (conn, _) = restored_sample();
        let marked: Vec<i64> = conn
            .prepare("SELECT IDOperation FROM Operation WHERE EstComplement = 1")
            .unwrap()
            .query_map([], |r| r.get(0))
            .unwrap()
            .collect::<Result<_, _>>()
            .unwrap();
        assert_eq!(marked, vec![3]);
    }

    #[test]
    fn restore_converts_amounts_and_dates() {
        let (conn, _) = restored_sample();
        let (amount, date, clearing): (i64, String, Option<String>) = conn
            .query_row(
                "SELECT Montant, Date, DatePointage FROM Operation WHERE IDOperation = 1",
                [],
                |r| Ok((r.get(0)?, r.get(1)?, r.get(2)?)),
            )
            .unwrap();
        assert_eq!(amount, -100_000_000); // micro-units
        assert_eq!(date, "2026-01-15");
        assert_eq!(clearing.as_deref(), Some("2026-01-15"));

        // The empty-string date of operation 2 becomes a real NULL.
        let clearing2: Option<String> = conn
            .query_row(
                "SELECT DatePointage FROM Operation WHERE IDOperation = 2",
                [],
                |r| r.get(0),
            )
            .unwrap();
        assert_eq!(clearing2, None);

        // Account balances too (5972.54 -> micro-units).
        let report_pointe: i64 = conn
            .query_row("SELECT ReportPointe FROM Compte WHERE IDCompte = 1", [], |r| {
                r.get(0)
            })
            .unwrap();
        assert_eq!(report_pointe, 5_972_540_000);
    }

    #[test]
    fn restore_keeps_this_builds_software_version_and_takes_the_archives_language() {
        let (conn, _) = restored_sample();
        let (major, minor, patch, db_version, language): (i64, i64, i64, i64, i64) = conn
            .query_row(
                "SELECT VerSoftMajeur, VerSoftMineur, VerSoftDebug, VerDataBase, UtiliseLangue
                 FROM Parametres WHERE IDParametres = 1",
                [],
                |r| Ok((r.get(0)?, r.get(1)?, r.get(2)?, r.get(3)?, r.get(4)?)),
            )
            .unwrap();
        // The archive says 1.9.0; the running program is 2.0.0.
        assert_eq!((major, minor, patch), (2, 0, 0));
        assert_eq!(db_version, schema::CURRENT_SCHEMA_VERSION);
        // **Le numéro de l'archive est repris tel quel** : 5, le français de
        // WinDev. Il n'est plus traduit en « fr » à l'entrée puis retraduit en
        // 5 à la sortie — c'est cette double traduction qui faisait ouvrir en
        // anglais une sauvegarde étrangère (décision de Fabrice, 01/08/2026).
        assert_eq!(language, 5);
        assert_eq!(
            crate::i18n::stored_language(&conn),
            crate::i18n::Language::French
        );
    }

    /// **Une archive dans une langue que nous ne parlons pas garde son
    /// numéro.** Le portage ne sait pas toutes les langues, mais il ne doit
    /// rien détruire de ce qu'il ne comprend pas : le jour où le danois
    /// arrivera, les bases restaurées d'ici là le diront encore. En attendant,
    /// le logiciel s'affiche en français plutôt que dans le vide.
    ///
    /// **Ce test parlait allemand jusqu'au 03/08/2026.** Sa promesse a été
    /// tenue le jour même : l'allemand est arrivé, les archives qui portaient
    /// le 1 se sont ouvertes en allemand sans qu'on y touche, et le test a dû
    /// changer de langue pour continuer à dire ce qu'il dit. Un test qu'on
    /// déménage parce que la prophétie s'est réalisée est un bon test.
    #[test]
    fn une_langue_inconnue_est_conservee_et_saffiche_en_francais() {
        let path = scratch("langue-danoise", "zip");
        {
            let file = std::fs::File::create(&path).unwrap();
            let mut zip = zip::ZipWriter::new(file);
            let opts: zip::write::FileOptions<'_, ()> = zip::write::FileOptions::default();
            zip.start_file("radinus_sauve_parametres.json", opts).unwrap();
            // 6 = nationDanois dans la table du WLangage.
            zip.write_all(
                br#"{ "Parametres":[ { "IDParametres":1, "RunOnce":true, "InitValDefaut":true, "VerSoftMajeur":1, "VerSoftMineur":9, "VerSoftDebug":0, "VerDataBase":9, "UtiliseLangue":6 } ] }"#,
            )
            .unwrap();
            zip.finish().unwrap();
        }
        let db_path = scratch("langue-danoise-db", "sqlite");
        let mut conn = crate::database::create_new_database(&db_path).unwrap();
        restore_file_into(&mut conn, &path).unwrap();
        let stored: i64 = conn
            .query_row(
                "SELECT UtiliseLangue FROM Parametres WHERE IDParametres = 1",
                [],
                |r| r.get(0),
            )
            .unwrap();
        std::fs::remove_file(&db_path).ok();
        assert_eq!(stored, 6, "le numéro de l'archive n'est pas perdu");
        assert_eq!(
            crate::i18n::stored_language(&conn),
            crate::i18n::Language::French,
            "faute de savoir le danois, on parle français"
        );
        std::fs::remove_file(&path).ok();
    }

    /// A schema can only ever evolve if a newer build can still read an older
    /// archive, which by definition lacks the fields added since (author's
    /// ruling, 25/07/2026). Every missing field takes its empty value and the
    /// restore goes through — nothing is refused.
    #[test]
    fn an_archive_missing_fields_still_restores_completely() {
        let path = scratch("sparse", "zip");
        {
            let file = std::fs::File::create(&path).unwrap();
            let mut zip = zip::ZipWriter::new(file);
            let opts: zip::write::FileOptions<'_, ()> = zip::write::FileOptions::default();
            // An "old" archive: Compte has four of its twenty-four fields, and
            // an operation carries neither Date nor half its columns.
            zip.start_file("radinus_sauve_comptes.json", opts).unwrap();
            zip.write_all(
                br#"{ "Compte":[ { "IDCompte":1, "Libelle":"Vieux compte", "ReportPointe":12.5, "Devise":"EUR" } ] }"#,
            )
            .unwrap();
            zip.start_file("radinus_sauve_operations.json", opts).unwrap();
            zip.write_all(
                br#"{ "Operation":[ { "IDOperation":1, "Libelle":"Sans date", "Montant":-5, "IDCompte":1, "IDStatutOperation":1 } ] }"#,
            )
            .unwrap();
            zip.finish().unwrap();
        }

        let db_path = scratch("sparse_db", "sqlite");
        let mut conn = crate::database::create_new_database(&db_path).unwrap();
        let report = restore_file_into(&mut conn, &path).unwrap();
        assert_eq!((report.accounts, report.operations), (1, 1));

        let (label, balance, holder): (String, i64, String) = conn
            .query_row(
                "SELECT Libelle, ReportPointe, NomTitulaire FROM Compte WHERE IDCompte = 1",
                [],
                |r| Ok((r.get(0)?, r.get(1)?, r.get(2)?)),
            )
            .unwrap();
        assert_eq!(label, "Vieux compte");
        assert_eq!(balance, 12_500_000);
        assert_eq!(holder, "", "un champ absent prend sa valeur vide");

        // The absent date lands as a real absence, not an invented value.
        let date: Option<String> = conn
            .query_row("SELECT Date FROM Operation WHERE IDOperation = 1", [], |r| {
                r.get(0)
            })
            .unwrap();
        assert_eq!(date, None);

        std::fs::remove_file(&path).ok();
        std::fs::remove_file(&db_path).ok();
    }

    /// No consistency check either: rows pointing at things that do not exist
    /// still come back, because giving the user what could be read beats
    /// giving him nothing.
    #[test]
    fn restore_accepts_rows_pointing_at_missing_rows() {
        let path = scratch("dangling", "zip");
        {
            let file = std::fs::File::create(&path).unwrap();
            let mut zip = zip::ZipWriter::new(file);
            let opts: zip::write::FileOptions<'_, ()> = zip::write::FileOptions::default();
            // An operation on account 999, which the archive never defines.
            zip.start_file("radinus_sauve_operations.json", opts).unwrap();
            zip.write_all(
                br#"{ "Operation":[ { "IDOperation":1, "Libelle":"Compte disparu", "Date":"20260115", "Montant":-5, "IDCompte":999, "IDStatutOperation":1 } ] }"#,
            )
            .unwrap();
            zip.finish().unwrap();
        }

        let db_path = scratch("dangling_db", "sqlite");
        let mut conn = crate::database::create_new_database(&db_path).unwrap();
        let report = restore_file_into(&mut conn, &path).unwrap();
        assert_eq!(report.operations, 1);

        let account: i64 = conn
            .query_row("SELECT IDCompte FROM Operation WHERE IDOperation = 1", [], |r| {
                r.get(0)
            })
            .unwrap();
        assert_eq!(account, 999);

        std::fs::remove_file(&path).ok();
        std::fs::remove_file(&db_path).ok();
    }

    /// **La devise survit à une sauvegarde et à sa restauration.**
    ///
    /// Elle n'y survivait pas, et Fabrice a posé la question le 05/08/2026 :
    /// *« la devise n'est pas récupérée après sauvegarde ? »*. Elle ne l'était
    /// pas. La restauration vide la base, y compris la table des préférences,
    /// puis la remplissait de tout sauf d'elle — alors que l'archive portait la
    /// bonne valeur depuis le début.
    ///
    /// Rien ne le disait : la devise retombait simplement à son défaut, et l'on
    /// ne s'en apercevait qu'en regardant un montant.
    #[test]
    fn la_devise_survit_a_une_sauvegarde_et_a_sa_restauration() {
        use crate::preferences;
        let db = scratch("devise", "sqlite");
        let zip = scratch("devise", "zip");
        std::fs::remove_file(&db).ok();
        std::fs::remove_file(&zip).ok();

        {
            let conn = crate::database::create_new_database(&db).unwrap();
            preferences::write(&conn, preferences::CURRENCY_KEY, "CHF").unwrap();
            writer::write_archive(&conn, &zip).unwrap();
        }

        let mut conn = crate::database::open_existing_database(&db, None)
            .unwrap()
            .conn;
        restore_file_into(&mut conn, &zip).unwrap();

        assert_eq!(
            preferences::read(&conn, preferences::CURRENCY_KEY).unwrap(),
            Some("CHF".to_string()),
            "la devise a été perdue en passant par l'archive"
        );

        drop(conn);
        std::fs::remove_file(&db).ok();
        std::fs::remove_file(&zip).ok();
    }

    /// **Une ligne de préférence d'une forme inconnue ne fait pas échouer la
    /// restauration.**
    ///
    /// Le seul risque de la correction du 05/08/2026. Une archive de la 1.9.3
    /// peut porter dans cette table ce qu'elle veut — le dossier §3.13
    /// l'affranchit de toute compatibilité. Une telle ligne doit être écartée
    /// en silence, jamais refusée : une sauvegarde n'est pas rejetée pour ce
    /// qu'on ne comprend pas (règle de l'auteur, 25/07/2026).
    #[test]
    fn une_preference_inconnue_est_ecartee_sans_faire_echouer_la_restauration() {
        use crate::preferences;
        let db = scratch("devise_inconnue", "sqlite");
        std::fs::remove_file(&db).ok();

        let mut conn = crate::database::create_new_database(&db).unwrap();
        let archive = Archive {
            preferences: vec![
                // Ce que serde rend d'une ligne dont il ne reconnaît rien.
                records::PreferencesRow::default(),
                records::PreferencesRow {
                    id_preferences: 1,
                    cle: preferences::CURRENCY_KEY.to_string(),
                    valeur_json: "\"CHF\"".to_string(),
                },
            ],
            ..Archive::default()
        };
        restore_into(&mut conn, &archive).unwrap();

        assert_eq!(
            preferences::read(&conn, preferences::CURRENCY_KEY).unwrap(),
            Some("\"CHF\"".to_string()),
            "la ligne lisible n'a pas été écrite"
        );
        let lignes: i64 = conn
            .query_row("SELECT COUNT(*) FROM Preferences", [], |row| row.get(0))
            .unwrap();
        assert_eq!(lignes, 1, "la ligne inconnue aurait dû être écartée");

        drop(conn);
        std::fs::remove_file(&db).ok();
    }

    #[test]
    fn restore_wipes_whatever_the_database_held_before() {
        let archive_path = scratch("wipe", "zip");
        write_sample_archive(&archive_path);
        let db_path = scratch("wipe_db", "sqlite");
        let mut conn = crate::database::create_new_database(&db_path).unwrap();

        conn.execute(
            "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte, IDBanques,
                ReportPointe, ReportEngage, ReportPrevu, SoldeBanque, SoldeReel,
                SoldeFinal, NomTitulaire, AdresseTitulaire, COBCodeBanque, COBCodeGuichet,
                COBNumCompte, COBClefRIB, COBIBAN, COBBIC, AdresseAgenceBank, DateOuverture,
                DateCloture, NumProchCheque, CompteCloture, Devise)
             VALUES (77, 'A supprimer', 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '',
                     '', '', '', '', '', NULL, NULL, 0, 0, 'EUR')",
            [],
        )
        .unwrap();

        restore_file_into(&mut conn, &archive_path).unwrap();

        let survivors: i64 = conn
            .query_row("SELECT COUNT(*) FROM Compte WHERE IDCompte = 77", [], |r| {
                r.get(0)
            })
            .unwrap();
        assert_eq!(survivors, 0);

        std::fs::remove_file(&archive_path).ok();
        std::fs::remove_file(&db_path).ok();
    }
}
