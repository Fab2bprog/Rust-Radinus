//! Writing a backup archive in the exact Radinus 1.9.3 format
//! (06_FORMATS_SAUVEGARDE_IMPORT_EXPORT.md §1, PLAN_ACTION.md Phase 1 §1.3,
//! delivery 2).
//!
//! The target is not "valid JSON" but **the same bytes** 1.9.3 produces, so a
//! 1.9.3 install can read what 2.0.0 writes and the round-trip test
//! (delivery 3) can compare files byte for byte, as the author asked. Serde
//! cannot express that layout, so the JSON is emitted by hand here. Every
//! rule below was measured on the author's real archive, not guessed:
//!
//! - a table file is `{ "Table":[ { "F":v, "F":v }, { … } ] }`, all on one
//!   line, with no trailing newline; an empty table is `{ "Table":[  ] }`
//!   (two spaces);
//! - fields appear in the declaration order of `base.sql`, which is also the
//!   order of `database::schema`;
//! - non-ASCII characters are escaped `é`, so a file is pure ASCII;
//! - amounts are plain decimals in their shortest form (`1500`, `-7.5`,
//!   `5972.54` — never `1500.0` nor `-7.50`);
//! - dates are `AAAAMMJJ`, the empty string when absent;
//! - booleans are `true`/`false`.
//!
//! **Row order** matters for a byte-identical result, and 1.9.3 browses each
//! table through one of its indexes. Measured on the real archive:
//! `Affectation`, `Categorie` and `Tiers` come out sorted by label, under a
//! French collation that ignores accents, case and punctuation (which is why
//! `Ebay` precedes `E. Leclerc`); `Commentaire` comes out by operation;
//! `Operation` by clearing date; everything else by primary key.
//! [`TABLES`] reproduces that. One limit is worth stating plainly: where
//! several rows share the same key — 600 of the author's 932 distinct
//! clearing dates — 1.9.3 falls back on the physical record order inside its
//! own file, which no longer exists once the data is in SQLite. Those ties
//! are broken by primary key here, which is deterministic and stable for our
//! own archives, but cannot always reproduce the original file's exact row
//! order for `Operation`.
//!
//! The `Complément` sub-operation is written back under its legacy label so
//! that 1.9.3 recognizes it, exactly reversing what the reader does.

use super::BackupError;
use rusqlite::Connection;
use std::io::Write;
use std::path::{Path, PathBuf};

/// How a column's stored value is rendered in the archive.
#[derive(Clone, Copy)]
enum Kind {
    /// Plain integer.
    Int,
    /// Micro-units in SQLite, shortest decimal in the archive.
    Amount,
    /// Quoted, ASCII-escaped string.
    Text,
    /// SQLite 0/1, `true`/`false` in the archive.
    Bool,
    /// ISO-8601 text (or NULL) in SQLite, `AAAAMMJJ` (or `""`) in the archive.
    Date,
}

/// Row order, per table, reproducing the index 1.9.3 browses.
enum Ordering {
    /// `ORDER BY` these columns, in SQL.
    Columns(&'static str),
    /// Sorted on a label under the French collation described in the module
    /// doc comment, ties broken by primary key.
    Label(&'static str),
}

struct TableSpec {
    /// Name inside the JSON, and of the SQL table.
    table: &'static str,
    /// `radinus_sauve_<stem>.json`.
    stem: &'static str,
    columns: &'static [(&'static str, Kind)],
    ordering: Ordering,
}

use Kind::*;

/// The nineteen tables an archive carries, **in the order 1.9.3 writes them
/// into the zip** (measured on the real archive — it is neither alphabetical
/// nor the schema's order).
const TABLES: &[TableSpec] = &[
    TableSpec {
        table: "Categorie",
        stem: "categories",
        columns: &[
            ("IDCategorie", Int),
            ("Libelle", Text),
            ("IDTypeCategorie", Int),
            ("IDPosteBudget", Int),
        ],
        ordering: Ordering::Label("Libelle"),
    },
    TableSpec {
        table: "Affectation",
        stem: "affectations",
        columns: &[("IDAffectation", Int), ("Libelle", Text)],
        ordering: Ordering::Label("Libelle"),
    },
    TableSpec {
        table: "Compte",
        stem: "comptes",
        columns: &[
            ("IDCompte", Int),
            ("ReportPointe", Amount),
            ("ReportEngage", Amount),
            ("ReportPrevu", Amount),
            ("Libelle", Text),
            ("IDTypeCompte", Int),
            ("IDBanques", Int),
            ("SoldeBanque", Amount),
            ("SoldeReel", Amount),
            ("SoldeFinal", Amount),
            ("NomTitulaire", Text),
            ("AdresseTitulaire", Text),
            ("COBCodeBanque", Text),
            ("COBCodeGuichet", Text),
            ("COBNumCompte", Text),
            ("COBClefRIB", Text),
            ("COBIBAN", Text),
            ("DateOuverture", Date),
            ("DateCloture", Date),
            ("AdresseAgenceBank", Text),
            ("COBBIC", Text),
            ("NumProchCheque", Int),
            ("CompteCloture", Bool),
            ("Devise", Text),
        ],
        ordering: Ordering::Columns("IDCompte"),
    },
    TableSpec {
        table: "Banques",
        stem: "banques",
        columns: &[("IDBanques", Int), ("NomBanque", Text)],
        ordering: Ordering::Columns("IDBanques"),
    },
    TableSpec {
        table: "ModeOperation",
        stem: "modeoperation",
        columns: &[("IDModeOperation", Int), ("Libelle", Text)],
        ordering: Ordering::Columns("IDModeOperation"),
    },
    TableSpec {
        table: "Operation",
        stem: "operations",
        columns: &[
            ("IDOperation", Int),
            ("Libelle", Text),
            ("Date", Date),
            ("Montant", Amount),
            ("IDModeOperation", Int),
            ("IDCategorie", Int),
            ("IDAffectation", Int),
            ("IDCompte", Int),
            ("DatePointage", Date),
            ("FitID", Text),
            ("ReferencePaiement", Text),
            ("NumRelevBanque", Text),
            ("IDStatutOperation", Int),
            ("IDOperationParent", Int),
            ("SoldePointe", Amount),
            ("EstParent", Bool),
            ("GUIDCalOpPeriode", Text),
            ("IDCheque", Int),
            ("IDTiers", Int),
            ("IDProjets", Int),
            // Base 11. En dernier : une 1.9.3 qui relirait l'archive trouve
            // ses vingt champs là où elle les attend.
            ("IDVerification", Int),
        ],
        ordering: Ordering::Columns("DatePointage, IDOperation"),
    },
    TableSpec {
        table: "Commentaire",
        stem: "commentaires",
        columns: &[
            ("IDCommentaire", Int),
            ("CommentaireTxt", Text),
            ("IDOperation", Int),
        ],
        ordering: Ordering::Columns("IDOperation, IDCommentaire"),
    },
    TableSpec {
        table: "PosteBudget",
        stem: "postesbudget",
        columns: &[("IDPosteBudget", Int), ("Libelle", Text)],
        ordering: Ordering::Columns("IDPosteBudget"),
    },
    TableSpec {
        table: "Budget",
        stem: "budget",
        columns: &[
            ("IDBudget", Int),
            ("Annee", Int),
            ("Mois", Int),
            ("IDPosteBudget", Int),
            ("Montant", Amount),
        ],
        ordering: Ordering::Columns("IDBudget"),
    },
    TableSpec {
        table: "CalOpPeriodique",
        stem: "calopperiodique",
        columns: &[
            ("GUIDCalOpPeriode", Text),
            ("Libelle", Text),
            ("IDModeOperation", Int),
            ("IDCategorie", Int),
            ("IDAffectation", Int),
            ("IDCompte", Int),
            ("IDStatutOperation", Int),
            ("Montant", Amount),
            ("DateFin", Date),
            ("Periode", Int),
            ("PeriodeNbrRepete", Int),
            ("PeriodeFreq", Int),
            ("ModeFinInsertion", Int),
            ("DateDernOpGen", Date),
            ("NbrOpInsert", Int),
            ("NbrOpAnterieur", Int),
            ("IDOperation", Int),
            ("DateProchOp", Date),
            ("MontantInsert", Amount),
            ("IDTiers", Int),
            ("IDProjets", Int),
        ],
        ordering: Ordering::Columns("GUIDCalOpPeriode"),
    },
    TableSpec {
        table: "Parametres",
        stem: "parametres",
        columns: &[
            ("IDParametres", Int),
            ("RunOnce", Bool),
            ("InitValDefaut", Bool),
            ("VerSoftMajeur", Int),
            ("VerSoftMineur", Int),
            ("VerSoftDebug", Int),
            ("VerDataBase", Int),
            // Le numéro « nation » du WLangage, écrit tel qu'il est stocké :
            // depuis le 01/08/2026 la base porte ce nombre, il n'y a donc plus
            // rien à traduire dans un sens ni dans l'autre.
            ("UtiliseLangue", Int),
        ],
        ordering: Ordering::Columns("IDParametres"),
    },
    TableSpec {
        table: "Chequier",
        stem: "chequier",
        columns: &[
            ("IDChequier", Int),
            ("DateRecep", Date),
            ("NumPremierChq", Int),
            ("NumDernChq", Int),
            ("QteChq", Int),
            ("IDReferenceChq", Text),
            ("FormatNumChq", Int),
            ("Commentaires", Text),
            ("IDCompte", Int),
        ],
        ordering: Ordering::Columns("IDChequier"),
    },
    TableSpec {
        table: "Cheque",
        stem: "cheque",
        columns: &[
            ("IDCheque", Int),
            ("NumChq", Int),
            ("IDChequier", Int),
            ("DateEmission", Date),
            ("Beneficiaire", Text),
            ("Montant", Amount),
            ("Commentaires", Text),
            ("LieuEmission", Text),
            ("IDStatutCheque", Int),
        ],
        ordering: Ordering::Columns("IDCheque"),
    },
    TableSpec {
        table: "StatutCheque",
        stem: "statutcheque",
        columns: &[
            ("IDStatutCheque", Int),
            ("Libelle", Text),
            ("Description", Text),
        ],
        ordering: Ordering::Columns("IDStatutCheque"),
    },
    TableSpec {
        table: "Tiers",
        stem: "tiers",
        columns: &[("IDTiers", Int), ("Libelle", Text)],
        ordering: Ordering::Label("Libelle"),
    },
    TableSpec {
        table: "Projets",
        stem: "projets",
        columns: &[("IDProjets", Int), ("Libelle", Text)],
        ordering: Ordering::Label("Libelle"),
    },
    TableSpec {
        table: "ModeleOperation",
        stem: "modeleoperation",
        columns: &[
            ("IDModeleOperation", Int),
            ("Libelle", Text),
            ("Montant", Amount),
            ("IDModeOperation", Int),
            ("IDCategorie", Int),
            ("IDAffectation", Int),
            ("IDStatutOperation", Int),
            ("IDTiers", Int),
            ("IDProjets", Int),
        ],
        ordering: Ordering::Columns("IDModeleOperation"),
    },
    TableSpec {
        table: "PiecesJointes",
        stem: "piecesjointes",
        columns: &[
            ("IDOperation", Int),
            ("IDPiecesJointes", Int),
            ("NomFichier", Text),
            ("NomFichierGUID", Text),
            ("PathRelFichier", Text),
            ("TailleFich", Int),
            ("MiMeType", Text),
            ("DateAjout", Date),
            ("CheckSumInfo", Text),
            ("NoteInfo", Text),
        ],
        ordering: Ordering::Columns("IDPiecesJointes"),
    },
    TableSpec {
        table: "Preferences",
        stem: "preferences",
        columns: &[
            ("IDPreferences", Int),
            ("Cle", Text),
            ("ValeurJSON", Text),
        ],
        ordering: Ordering::Columns("IDPreferences"),
    },
];

/// The empty entry 1.9.3 puts in every archive. Its real name is a single dot
/// (the dossier writes it `_` because that is how some extractors rename it);
/// it is stored uncompressed and holds no bytes.
pub(crate) const EMPTY_ENTRY: &str = ".";

/// Position of [`EMPTY_ENTRY`] among the zip entries: 1.9.3 writes it just
/// before the last table file, which is `preferences`.
const EMPTY_ENTRY_BEFORE_LAST: usize = 1;

/// Builds the archive's file name from a timestamp:
/// `radinus_sauvegarde_<AAAAMMJJHHMMSSmmm>.zip` (06 §1.1).
pub fn archive_file_name(now: std::time::SystemTime) -> String {
    use time_compute::{Datelike, TimeZone, Timelike, Utc};

    let since_epoch = now
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default();
    let millis = since_epoch.subsec_millis();
    let local = Utc
        .timestamp_opt(since_epoch.as_secs() as i64, 0)
        .single()
        .unwrap_or_default();
    format!(
        "radinus_sauvegarde_{:04}{:02}{:02}{:02}{:02}{:02}{:03}.zip",
        local.year(),
        local.month(),
        local.day(),
        local.hour(),
        local.minute(),
        local.second(),
        millis
    )
}

/// Ce qu'une table a pesé dans l'archive.
///
/// **Rendu plutôt que journalisé ici.** Le noyau ne connaît ni la langue de
/// l'utilisateur au moment où il écrit, ni ce que le contrôleur voudra en
/// faire ; il rend des faits — un nom, un nombre, un poids — et le journal se
/// compose ailleurs, dans la langue de la base.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct TableWritten {
    pub table: &'static str,
    pub stem: &'static str,
    /// Le nombre d'enregistrements écrits.
    pub rows: usize,
    /// Le poids du JSON produit, avant compression, en octets.
    pub bytes: usize,
}

/// Writes the whole database as an archive inside `directory`, named after
/// the current time, and returns the path of the file created.
pub fn write_archive_into(conn: &Connection, directory: &Path) -> Result<PathBuf, BackupError> {
    let path = directory.join(archive_file_name(std::time::SystemTime::now()));
    write_archive(conn, &path)?;
    Ok(path)
}

/// Ce qu'une pièce jointe a pesé dans l'archive, ou pourquoi elle n'y est pas.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct AttachmentWritten {
    /// Le nom physique du fichier : GUID + extension.
    pub guid_name: String,
    pub bytes: usize,
    /// Faux quand la base désigne un fichier que le disque n'a plus.
    pub found: bool,
}

/// Writes the whole database as an archive at exactly `path`.
///
/// Rend le compte rendu table par table, dans l'ordre d'écriture : c'est ce
/// dont le journal a besoin pour dire, comme celui de 1.9.3, combien
/// d'enregistrements chaque table a versés et ce qu'ils pèsent.
pub fn write_archive(conn: &Connection, path: &Path) -> Result<Vec<TableWritten>, BackupError> {
    write_archive_with_attachments(conn, path, None).map(|(tables, _)| tables)
}

/// La même chose, en emportant les **fichiers des pièces jointes**.
///
/// Ils vont à la racine du zip, sous leur nom GUID, **à la place de l'entrée
/// vide `.`** — c'est exactement là que 1.9.3 les met : son
/// `zipAjouteRépertoire` ajoute le dossier des pièces jointes juste avant les
/// préférences, et cette entrée `.` que nous reproduisions sans la comprendre
/// n'était rien d'autre que ce dossier, vide.
///
/// Un fichier que la base désigne mais que le disque n'a plus **n'interrompt
/// pas la sauvegarde** : il est signalé dans le compte rendu, et le reste
/// part. Refuser de sauvegarder à cause d'une pièce jointe égarée priverait
/// l'utilisateur de tout le reste, ce qui serait une drôle de façon de
/// protéger ses données.
pub fn write_archive_with_attachments(
    conn: &Connection,
    path: &Path,
    attachments: Option<&Path>,
) -> Result<(Vec<TableWritten>, Vec<AttachmentWritten>), BackupError> {
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent)?;
    }
    let file = std::fs::File::create(path)?;
    let mut zip = zip::ZipWriter::new(file);

    let deflated: zip::write::FileOptions<'_, ()> =
        zip::write::FileOptions::default().compression_method(zip::CompressionMethod::Deflated);
    let stored: zip::write::FileOptions<'_, ()> =
        zip::write::FileOptions::default().compression_method(zip::CompressionMethod::Stored);

    // Les pièces jointes que la base désigne, lues avant d'ouvrir la boucle :
    // elles se glissent à la place de l'entrée vide.
    let files: Vec<String> = match attachments {
        Some(_) => crate::attachments::all_files(conn)?,
        None => Vec::new(),
    };
    let mut joined: Vec<AttachmentWritten> = Vec::with_capacity(files.len());

    let mut written = Vec::with_capacity(TABLES.len());
    for (index, spec) in TABLES.iter().enumerate() {
        if index == TABLES.len() - EMPTY_ENTRY_BEFORE_LAST {
            match attachments {
                // Le dossier vide de 1.9.3 : une seule entrée sans contenu.
                _ if files.is_empty() => zip.start_file(EMPTY_ENTRY, stored)?,
                Some(folder) => {
                    for guid_name in &files {
                        let source = crate::attachments::path_in(folder, guid_name);
                        match std::fs::read(&source) {
                            Ok(bytes) => {
                                // Déjà compressés pour la plupart — un PNG, un
                                // PDF, un .docx —, donc rangés tels quels :
                                // les recompresser coûterait du temps pour
                                // gagner des octets qui n'existent pas.
                                zip.start_file(guid_name.as_str(), stored)?;
                                zip.write_all(&bytes)?;
                                joined.push(AttachmentWritten {
                                    guid_name: guid_name.clone(),
                                    bytes: bytes.len(),
                                    found: true,
                                });
                            }
                            Err(_) => joined.push(AttachmentWritten {
                                guid_name: guid_name.clone(),
                                bytes: 0,
                                found: false,
                            }),
                        }
                    }
                }
                None => zip.start_file(EMPTY_ENTRY, stored)?,
            }
        }
        zip.start_file(format!("radinus_sauve_{}.json", spec.stem), deflated)?;
        let (json, rows) = table_json(conn, spec)?;
        zip.write_all(json.as_bytes())?;
        written.push(TableWritten {
            table: spec.table,
            stem: spec.stem,
            rows,
            bytes: json.len(),
        });
    }

    zip.finish()?;
    Ok((written, joined))
}

/// Renders one table exactly as its `radinus_sauve_*.json` entry. Public so
/// the round-trip test can compare a single table without unzipping.
pub fn table_json_for(conn: &Connection, table: &str) -> Result<Option<String>, BackupError> {
    match TABLES.iter().find(|s| s.table == table) {
        Some(spec) => Ok(Some(table_json(conn, spec)?.0)),
        None => Ok(None),
    }
}

/// Les dix-neuf tables d'une archive : leur nom et le radical de leur fichier,
/// **dans l'ordre où elles sont écrites**.
///
/// Publique pour que le journal et la relecture parlent des mêmes tables que
/// l'écriture : une liste recopiée ailleurs finirait par diverger de
/// celle-ci, et le journal jurerait qu'un fichier manque alors qu'il n'a
/// jamais été prévu.
pub fn table_names() -> Vec<(&'static str, &'static str)> {
    TABLES.iter().map(|spec| (spec.table, spec.stem)).collect()
}

/// The columns this table carries **into an archive**, or `None` when the table
/// does not travel at all.
///
/// Public for the crossing below: the schema declares what a database holds,
/// this declares what a backup carries, and nothing but a test keeps the two in
/// step.
pub fn archived_columns(table: &str) -> Option<Vec<&'static str>> {
    TABLES
        .iter()
        .find(|spec| spec.table == table)
        .map(|spec| spec.columns.iter().map(|(name, _)| *name).collect())
}

fn table_json(conn: &Connection, spec: &TableSpec) -> Result<(String, usize), BackupError> {
    let column_list = spec
        .columns
        .iter()
        .map(|(name, _)| *name)
        .collect::<Vec<_>>()
        .join(", ");

    // `Operation` needs its marker to decide the label it is written under,
    // so it is selected alongside the exported columns.
    let is_operation = spec.table == "Operation";
    let select = if is_operation {
        format!(
            "SELECT {column_list}, EstComplement FROM {} ORDER BY {}",
            spec.table,
            match spec.ordering {
                Ordering::Columns(c) => c,
                Ordering::Label(_) => "rowid",
            }
        )
    } else {
        format!(
            "SELECT {column_list} FROM {} ORDER BY {}",
            spec.table,
            match spec.ordering {
                Ordering::Columns(c) => c,
                Ordering::Label(_) => "rowid",
            }
        )
    };

    let mut stmt = conn.prepare(&select)?;
    let mut rows = stmt.query([])?;

    // (collation key, primary key, rendered object)
    let mut rendered: Vec<(String, i64, String)> = Vec::new();
    while let Some(row) = rows.next()? {
        let is_complement: bool = if is_operation {
            row.get::<_, i64>(spec.columns.len())? != 0
        } else {
            false
        };

        let mut object = String::from("{ ");
        let mut collation_key = String::new();
        for (index, (name, kind)) in spec.columns.iter().enumerate() {
            if index > 0 {
                object.push_str(", ");
            }
            object.push('"');
            object.push_str(name);
            object.push_str("\":");

            // A sub-operation marked as the Complement is written back under
            // the legacy label 1.9.3 recognizes.
            let value = if is_operation && *name == "Libelle" && is_complement {
                render_text(super::records::LEGACY_COMPLEMENT_LABEL)
            } else {
                render(row, index, *kind)?
            };
            object.push_str(&value);

            if let Ordering::Label(label_column) = spec.ordering {
                if *name == label_column {
                    collation_key = crate::text::french_sort_key(&row.get::<_, String>(index)?);
                }
            }
        }
        object.push_str(" }");

        let primary_key: i64 = row.get(0).unwrap_or(0);
        rendered.push((collation_key, primary_key, object));
    }

    if matches!(spec.ordering, Ordering::Label(_)) {
        rendered.sort_by(|a, b| a.0.cmp(&b.0).then(a.1.cmp(&b.1)));
    }

    let mut out = String::with_capacity(64 + rendered.len() * 128);
    out.push_str("{ \"");
    out.push_str(spec.table);
    out.push_str("\":[");
    if rendered.is_empty() {
        // Measured: an empty table is `{ "Table":[  ] }`, two spaces.
        out.push_str("  ] }");
    } else {
        for (index, (_, _, object)) in rendered.iter().enumerate() {
            out.push_str(if index == 0 { " " } else { ", " });
            out.push_str(object);
        }
        out.push_str(" ] }");
    }
    Ok((out, rendered.len()))
}

fn render(row: &rusqlite::Row<'_>, index: usize, kind: Kind) -> Result<String, BackupError> {
    Ok(match kind {
        Int => row.get::<_, i64>(index)?.to_string(),
        Amount => render_amount(row.get::<_, i64>(index)?),
        Bool => if row.get::<_, i64>(index)? != 0 {
            "true"
        } else {
            "false"
        }
        .to_string(),
        Text => render_text(&row.get::<_, String>(index)?),
        Date => {
            let iso: Option<String> = row.get(index)?;
            render_text(&match iso {
                Some(iso) if iso.len() == 10 => format!("{}{}{}", &iso[0..4], &iso[5..7], &iso[8..10]),
                _ => String::new(),
            })
        }
    })
}

/// Renders a micro-unit amount as the shortest decimal, the way 1.9.3 does:
/// `1_500_000_000` -> `1500`, `-7_500_000` -> `-7.5`, never a trailing zero.
fn render_amount(micros: i64) -> String {
    let negative = micros < 0;
    let magnitude = micros.unsigned_abs();
    let units = magnitude / 1_000_000;
    let fraction = magnitude % 1_000_000;

    let mut out = String::new();
    if negative && (units != 0 || fraction != 0) {
        out.push('-');
    }
    out.push_str(&units.to_string());
    if fraction != 0 {
        let mut decimals = format!("{fraction:06}");
        while decimals.ends_with('0') {
            decimals.pop();
        }
        out.push('.');
        out.push_str(&decimals);
    }
    out
}

/// Quotes and escapes a string the way the format does: JSON escapes, then
/// every non-ASCII character as `é`, so the file stays pure ASCII.
fn render_text(value: &str) -> String {
    let mut out = String::with_capacity(value.len() + 2);
    out.push('"');
    for c in value.chars() {
        match c {
            '"' => out.push_str("\\\""),
            '\\' => out.push_str("\\\\"),
            '\n' => out.push_str("\\n"),
            '\r' => out.push_str("\\r"),
            '\t' => out.push_str("\\t"),
            c if (c as u32) < 0x20 => out.push_str(&format!("\\u{:04x}", c as u32)),
            c if c.is_ascii() => out.push(c),
            c => {
                let mut buffer = [0u16; 2];
                for unit in c.encode_utf16(&mut buffer) {
                    out.push_str(&format!("\\u{unit:04x}"));
                }
            }
        }
    }
    out.push('"');
    out
}

/// Sanity check that the writer and the schema have not drifted apart: every
/// column this module claims to export must actually exist. Called by its own
/// test rather than at runtime.
#[cfg(test)]
fn every_exported_column_exists(conn: &Connection) -> Vec<String> {
    let mut missing = Vec::new();
    for spec in TABLES {
        for (column, _) in spec.columns {
            let count: i64 = conn
                .query_row(
                    &format!(
                        "SELECT COUNT(*) FROM pragma_table_info('{}') WHERE name = ?1",
                        spec.table
                    ),
                    [column],
                    |r| r.get(0),
                )
                .unwrap_or(0);
            if count != 1 {
                missing.push(format!("{}.{}", spec.table, column));
            }
        }
    }
    missing
}

#[cfg(test)]
mod tests {
    use super::*;

    fn blank_database() -> Connection {
        let conn = Connection::open_in_memory().unwrap();
        crate::database::schema::migrate(&conn).unwrap();
        crate::database::seed::seed_initial_data(&conn).unwrap();
        conn
    }

    #[test]
    fn the_writer_and_the_schema_agree_on_every_column() {
        let conn = blank_database();
        let missing = every_exported_column_exists(&conn);
        assert!(missing.is_empty(), "colonnes inconnues du schema : {missing:?}");
    }

    #[test]
    fn amounts_are_written_in_their_shortest_form() {
        assert_eq!(render_amount(1_500_000_000), "1500");
        assert_eq!(render_amount(60_710_000), "60.71");
        assert_eq!(render_amount(-7_500_000), "-7.5");
        assert_eq!(render_amount(5_972_540_000), "5972.54");
        assert_eq!(render_amount(0), "0");
        assert_eq!(render_amount(-30_500_000), "-30.5");
        assert_eq!(render_amount(1), "0.000001");
    }

    #[test]
    fn text_is_escaped_down_to_pure_ascii() {
        // The accented character must come out as its escape, not as itself.
        assert_eq!(render_text("Complément"), r#""Compl\u00e9ment""#);
        assert_eq!(render_text(""), r#""""#);
        assert_eq!(render_text("a\"b\\c"), r#""a\"b\\c""#);
        assert!(render_text("Émis").is_ascii());
    }

    #[test]
    fn the_french_collation_matches_the_observed_order() {
        // Exactly the case measured on the author's archive.
        assert!(crate::text::french_sort_key("Ebay") < crate::text::french_sort_key("E. Leclerc"));
        assert!(crate::text::french_sort_key("Cotisations syndicale") < crate::text::french_sort_key("Dépenses personnelles"));
        assert!(crate::text::french_sort_key("Dépenses personnelles") < crate::text::french_sort_key("Divers"));
        assert!(crate::text::french_sort_key("Brico Depot") < crate::text::french_sort_key("BricoMarché"));
        assert!(crate::text::french_sort_key("La Redoute") < crate::text::french_sort_key("LDLC"));
    }

    #[test]
    fn an_empty_table_is_written_with_its_two_spaces() {
        let conn = blank_database();
        let json = table_json_for(&conn, "Projets").unwrap().unwrap();
        assert_eq!(json, r#"{ "Projets":[  ] }"#);
    }

    #[test]
    fn a_filled_table_matches_the_measured_layout() {
        let conn = blank_database();
        let json = table_json_for(&conn, "Affectation").unwrap().unwrap();
        assert!(
            json.starts_with(r#"{ "Affectation":[ { "IDAffectation":7, "Libelle":"Animaux" }, "#),
            "obtenu : {}",
            &json[..80.min(json.len())]
        );
        assert!(json.ends_with(" ] }"));
        assert!(!json.ends_with('\n'));
    }

    #[test]
    fn the_archive_carries_the_twenty_expected_entries() {
        let conn = blank_database();
        let path = std::env::temp_dir().join("radinus_writer_test.zip");
        std::fs::remove_file(&path).ok();
        write_archive(&conn, &path).unwrap();

        let file = std::fs::File::open(&path).unwrap();
        let zip = zip::ZipArchive::new(file).unwrap();
        let names: Vec<String> = zip.file_names().map(str::to_string).collect();
        assert_eq!(names.len(), TABLES.len() + 1);
        assert!(names.iter().any(|n| n == EMPTY_ENTRY));
        assert!(names.iter().any(|n| n == "radinus_sauve_operations.json"));

        std::fs::remove_file(&path).ok();
    }

    /// **The crossing between what a database holds and what a backup carries.**
    ///
    /// Fabrice, 05/08/2026, on being told the two lists were written by hand in two
    /// files: *« 2 descriptions de bases […] je trouve que c'est minable comme
    /// approche »*. He is right, and this test does not pretend otherwise — it only
    /// makes the duplication **unable to lie**.
    ///
    /// The failure it exists to prevent is silent, which is why it is worth thirty
    /// lines. Add a column to `database::schema` and forget it here: the column
    /// exists in every database, the user fills it, the backup is written without
    /// it, and the restore brings it back holding its default value. Nothing warns
    /// anyone, at any point.
    ///
    /// Three things are checked, in both directions:
    ///
    /// 1. every declared table either travels or is named below as deliberately
    ///    left out;
    /// 2. every declared column of a travelling table is either exported or named
    ///    below;
    /// 3. every exported column exists in the schema — the reverse mistake, which
    ///    would make the archive fail on `SELECT` rather than silently.
    #[test]
    fn toute_colonne_de_la_base_est_sauvegardee_ou_ecartee_expres() {
        use crate::database::schema;

        /// Tables that never enter an archive, and why.
        ///
        /// `ParamSecurite` holds the password and must not leave the database
        /// (06_FORMATS_SAUVEGARDE_IMPORT_EXPORT.md §1.2). The others are the
        /// *frozen* nomenclatures: their content comes from the software, and
        /// `schema::ensure_the_tables` refills them when it finds them empty —
        /// carrying them would be copying what Radinus can rewrite.
        const NEVER_TRAVELS: &[&str] = &[
            "ParamSecurite",
            "StatutOperation",
            "TypeCategorie",
            "TypeCompte",
            "Verification",
        ];

        /// Columns deliberately left out of the archive, written `Table.Column`.
        ///
        /// `Operation.EstComplement` is the marker 2.0.0 added to recognise a
        /// "Complément" sub-operation without reading its label. The archive writes
        /// the legacy label instead, so that a 1.9.3 can still read what we produce.
        const NEVER_EXPORTED: &[&str] = &["Operation.EstComplement"];

        let mut silent: Vec<String> = Vec::new();
        let mut invented: Vec<String> = Vec::new();

        for table in schema::declared_tables() {
            let declared = schema::declared_columns(table);
            assert!(
                !declared.is_empty(),
                "{table} est déclarée sans colonne : le modèle n'a pas été lu"
            );

            let Some(exported) = archived_columns(table) else {
                assert!(
                    NEVER_TRAVELS.contains(&table),
                    "{table} est déclarée dans le schéma et n'entre dans aucune \
                     sauvegarde. Ajoutez-la à `backup::writer::TABLES`, ou à \
                     NEVER_TRAVELS en sachant que son contenu ne sera jamais sauvé."
                );
                continue;
            };
            assert!(
                !NEVER_TRAVELS.contains(&table),
                "{table} est annoncée comme ne voyageant jamais, et pourtant elle \
                 est exportée"
            );

            for column in &declared {
                let full = format!("{table}.{column}");
                if !exported.contains(&column.as_str()) && !NEVER_EXPORTED.contains(&full.as_str()) {
                    silent.push(full);
                }
            }
            for column in &exported {
                if !declared.iter().any(|had| had == column) {
                    invented.push(format!("{table}.{column}"));
                }
            }
        }

        assert!(
            silent.is_empty(),
            "ces colonnes existent dans la base et ne partent pas dans les \
             sauvegardes : on les remplit, on sauvegarde, on restaure, et elles \
             reviennent à leur valeur par défaut sans que rien ne le dise. \
             Exportez-les, ou nommez-les dans NEVER_EXPORTED : {silent:?}"
        );
        assert!(
            invented.is_empty(),
            "ces colonnes sont exportées et n'existent pas dans le schéma : \
             la sauvegarde échouera sur son propre SELECT : {invented:?}"
        );
    }

    /// **And the reader knows every field the writer writes.**
    ///
    /// The third description of the same database: `backup::records` declares the
    /// Rust shape of each archived row, and it is what turns a JSON file back into
    /// operations. A field written by the writer and unknown to the reader is
    /// written into every archive and dropped on the way back in — the same silent
    /// loss as above, one step further along.
    ///
    /// The field names appear verbatim in `records.rs` as `#[serde(rename = "…")]`,
    /// so reading that file is enough and no reflection is needed.
    #[test]
    fn tout_ce_qui_est_sauvegarde_est_relu() {
        use crate::database::schema;

        // **There is no exception left.** `Preferences` was one until
        // 05/08/2026: written into every archive and read back by nobody, which
        // silently lost the currency of a database at every restore. The list
        // that named it is gone with the fault, and every table written is now
        // a table read.

        let readers = include_str!("records.rs");
        let mut unread: Vec<String> = Vec::new();

        for table in schema::declared_tables() {
            let Some(exported) = archived_columns(table) else {
                continue;
            };
            for column in exported {
                if !readers.contains(&format!("rename = \"{column}\"")) {
                    unread.push(format!("{table}.{column}"));
                }
            }
        }

        assert!(
            unread.is_empty(),
            "ces colonnes sont écrites dans l'archive et `backup::records` ne les \
             connaît pas : elles seront perdues à la restauration : {unread:?}"
        );
    }

    #[test]
    fn the_archive_is_named_after_the_moment_it_was_written() {
        let name = archive_file_name(std::time::UNIX_EPOCH + std::time::Duration::from_millis(1));
        assert_eq!(name, "radinus_sauvegarde_19700101000000001.zip");
    }
}
