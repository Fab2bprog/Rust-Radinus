//! SQLite persistence: connection helpers, schema/migrations, prefilled
//! reference data, and the max+1 key generator.
//!
//! Dossier reference: `02_BASE_DE_DONNEES.md` (schema, §5 prefilled values,
//! §7 id rule), `PLAN_ACTION.md` Phase 1 §1.1/§1.2/§1.2 bis.

use std::path::Path;

/// Re-exported so the controller crate can hold an open database in its
/// state without depending on `rusqlite` itself — only this crate links the
/// bundled SQLite engine (08_ARCHITECTURE.md §2.2: the controller carries no
/// persistence knowledge of its own).
pub use rusqlite::Connection;

pub mod keygen;
pub mod lock;
pub mod schema;
pub mod seed;

/// Opens (creating if absent) a SQLite database at `path`, using the bundled
/// SQLite engine (no system dependency — see the dependency registry in
/// 08_ARCHITECTURE.md). Returns the open connection so callers can run
/// further setup without reopening. Does not touch schema or data — see
/// [`create_new_database`] and [`open_existing_database`] for the two actual
/// call sites used by the rest of the app.
pub fn open_or_create(path: &Path) -> rusqlite::Result<Connection> {
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent).map_err(|e| {
            rusqlite::Error::SqliteFailure(
                rusqlite::ffi::Error::new(rusqlite::ffi::SQLITE_CANTOPEN),
                Some(e.to_string()),
            )
        })?;
    }
    Connection::open(path)
}

/// Error returned when a path does not point at a valid, ported Radinus
/// database — used by [`open_existing_database`] (PLAN_ACTION.md 1.2 bis,
/// "validation qu'il s'agit d'une base Radinus + version").
#[derive(Debug)]
pub enum OpenError {
    Sqlite(rusqlite::Error),
    /// The file opens as SQLite but has no `Parametres` table (or no row
    /// with IDParametres=1): not a Radinus database at all.
    NotARadinusDatabase,
    /// A recognized Radinus database, but from a future schema version this
    /// build doesn't know how to read. Never returned for an *older* schema
    /// version — that case is handled transparently by `schema::migrate`.
    UnsupportedSchemaVersion { found: i64, supported: i64 },
    /// **Le fichier résiste : il faut un mot de passe, ou celui donné n'est
    /// pas le bon** (décision de Fabrice, 05/08/2026).
    ///
    /// Les deux cas n'en font qu'un, et ce n'est pas une approximation : sans
    /// la bonne clé, une base chiffrée ne laisse rien voir du tout, pas même
    /// de quoi dire si elle est chiffrée ou abîmée. Radinus demande le mot de
    /// passe, et si ce mot de passe ne marche pas, il le redemande.
    Locked,
}

impl std::fmt::Display for OpenError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            OpenError::Sqlite(e) => write!(f, "SQLite error: {e}"),
            OpenError::NotARadinusDatabase => {
                write!(f, "This file is not a Radinus database (no Parametres table found)")
            }
            OpenError::UnsupportedSchemaVersion { found, supported } => write!(
                f,
                "This Radinus database uses schema version {found}, which is newer than \
                 the version this build supports ({supported}). Please update Radinus."
            ),
            OpenError::Locked => {
                write!(f, "This database is protected by a password")
            }
        }
    }
}

impl std::error::Error for OpenError {}

impl From<rusqlite::Error> for OpenError {
    fn from(e: rusqlite::Error) -> Self {
        OpenError::Sqlite(e)
    }
}

/// Creates a brand-new, fully prefilled Radinus database at `path` (which
/// must not already exist as a non-empty file — callers are expected to have
/// already picked a fresh path, e.g. via `location::create_next_database_slot`).
/// Applies the schema, then seeds the reference nomenclatures and the single
/// `Parametres` row. This is the only place [`seed::seed_initial_data`] is
/// called for a new database — see that function's doc comment for why it's
/// never called again on ordinary opens.
pub fn create_new_database(path: &Path) -> Result<Connection, OpenError> {
    let conn = open_or_create(path)?;
    schema::migrate(&conn)?;
    seed::seed_initial_data(&conn)?;
    Ok(conn)
}

/// Une base qui vient d'être ouverte, et ce que son ouverture a eu à réparer.
///
/// Les deux voyagent ensemble parce qu'ils naissent ensemble : le compte rendu
/// n'existe qu'à l'instant de l'ouverture, et le perdre en route reviendrait à
/// réparer en silence — ce que la décision du 03/08/2026 refuse explicitement.
pub struct Opened {
    pub conn: Connection,
    /// Vide dans le cas ordinaire : la base était complète.
    pub report: schema::SchemaReport,
}

/// Opens an existing database at `path` and validates it is a genuine,
/// supported Radinus database (PLAN_ACTION.md 1.2 bis). Brings its schema up
/// to date in place if it was created by an older build (transparent
/// incremental migration, never destructive). Refuses to open a database
/// created by a *newer* build than this one, rather than silently
/// misinterpreting its schema.
///
/// **La table `Parametres` est cherchée avant toute chose, et jamais créée
/// ici** (décision de Fabrice, 03/08/2026). C'est elle qui distingue une base
/// Radinus d'un fichier SQLite quelconque ; la procédure qui rétablit les
/// tables manquantes s'arrête donc à sa porte, sinon n'importe quel fichier
/// choisi par erreur deviendrait une base Radinus.
///
/// **`password` vaut `None` tant qu'on n'en a pas** (décision de Fabrice,
/// 05/08/2026 : « il essaie, et demande si ça résiste »). Radinus tente
/// toujours l'ouverture sans rien d'abord ; le fichier qui refuse rend
/// [`OpenError::Locked`], et l'appelant redemande avec le mot de passe. Rien
/// n'est noté nulle part sur les bases protégées — une base copiée d'ailleurs
/// se comporte donc exactement pareil.
pub fn open_existing_database(path: &Path, password: Option<&str>) -> Result<Opened, OpenError> {
    let conn = Connection::open(path)?;

    // La clé, s'il y en a une, **avant toute lecture** : une requête faite
    // d'abord fixe l'état de la connexion et `PRAGMA key` n'a plus d'effet.
    if let Some(password) = password {
        lock::unlock(&conn, password)?;
    }
    // Et le premier regard dans le fichier, qui est aussi le seul contrôle du
    // mot de passe qui existe : ou bien on sait lire, ou bien on ne sait pas.
    if !lock::readable(&conn) {
        return Err(OpenError::Locked);
    }

    let has_parametres_table: bool = conn.query_row(
        "SELECT EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'Parametres')",
        [],
        |row| row.get(0),
    )?;
    if !has_parametres_table {
        return Err(OpenError::NotARadinusDatabase);
    }

    let stored_version: Option<i64> = conn
        .query_row(
            "SELECT VerDataBase FROM Parametres WHERE IDParametres = 1",
            [],
            |row| row.get(0),
        )
        .ok();
    let Some(stored_version) = stored_version else {
        return Err(OpenError::NotARadinusDatabase);
    };
    if stored_version > schema::CURRENT_SCHEMA_VERSION {
        return Err(OpenError::UnsupportedSchemaVersion {
            found: stored_version,
            supported: schema::CURRENT_SCHEMA_VERSION,
        });
    }

    let report = schema::migrate(&conn)?;
    Ok(Opened { conn, report })
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::atomic::{AtomicU32, Ordering};

    static COUNTER: AtomicU32 = AtomicU32::new(0);

    fn scratch_db_path(label: &str) -> std::path::PathBuf {
        let n = COUNTER.fetch_add(1, Ordering::SeqCst);
        std::env::temp_dir().join(format!("radinus_core_test_db_{label}_{n}.sqlite"))
    }

    #[test]
    fn open_or_create_makes_a_file_on_disk() {
        let path = scratch_db_path("create");
        {
            let conn = open_or_create(&path).unwrap();
            // A trivial round trip proves the connection is genuinely usable,
            // not just that a zero-byte file exists.
            conn.execute_batch("PRAGMA user_version = 0;").unwrap();
        }
        assert!(path.exists());
        std::fs::remove_file(&path).ok();
    }

    #[test]
    fn open_or_create_creates_parent_directories() {
        let n = COUNTER.fetch_add(1, Ordering::SeqCst);
        let dir = std::env::temp_dir().join(format!("radinus_core_test_db_nested_{n}"));
        let path = dir.join("databases/Radinus_00001/radinus.sqlite");
        open_or_create(&path).unwrap();
        assert!(path.exists());
        std::fs::remove_dir_all(&dir).ok();
    }

    #[test]
    fn create_new_database_is_fully_seeded() {
        let path = scratch_db_path("new");
        {
            let conn = create_new_database(&path).unwrap();
            let bank_count: i64 = conn
                .query_row("SELECT COUNT(*) FROM Banques", [], |r| r.get(0))
                .unwrap();
            assert_eq!(bank_count, 30);
        }
        std::fs::remove_file(&path).ok();
    }

    #[test]
    fn open_existing_database_accepts_a_freshly_created_one() {
        let path = scratch_db_path("reopen");
        create_new_database(&path).unwrap();
        let opened = open_existing_database(&path, None).unwrap();
        assert!(
            opened.report.is_empty(),
            "une base qui vient d'être créée n'a rien à réparer : {:?}",
            opened.report
        );
        let version: i64 = opened
            .conn
            .query_row(
                "SELECT VerDataBase FROM Parametres WHERE IDParametres = 1",
                [],
                |r| r.get(0),
            )
            .unwrap();
        assert_eq!(version, schema::CURRENT_SCHEMA_VERSION);
        std::fs::remove_file(&path).ok();
    }

    #[test]
    fn open_existing_database_rejects_a_non_radinus_sqlite_file() {
        let path = scratch_db_path("foreign");
        {
            let conn = Connection::open(&path).unwrap();
            conn.execute_batch("CREATE TABLE unrelated (id INTEGER);")
                .unwrap();
        }
        let result = open_existing_database(&path, None);
        assert!(matches!(result, Err(OpenError::NotARadinusDatabase)));
        std::fs::remove_file(&path).ok();
    }

    #[test]
    fn open_existing_database_rejects_a_future_schema_version() {
        let path = scratch_db_path("future");
        {
            let conn = create_new_database(&path).unwrap();
            conn.execute(
                "UPDATE Parametres SET VerDataBase = ?1 WHERE IDParametres = 1",
                [schema::CURRENT_SCHEMA_VERSION + 1],
            )
            .unwrap();
        }
        let result = open_existing_database(&path, None);
        assert!(matches!(
            result,
            Err(OpenError::UnsupportedSchemaVersion { .. })
        ));
        std::fs::remove_file(&path).ok();
    }

    /// **Une table effacée à la main revient à l'ouverture suivante**, et
    /// l'ouverture le dit (décision de Fabrice, 03/08/2026).
    ///
    /// Avant ce dispositif, effacer `Categorie` laissait Radinus s'ouvrir puis
    /// échouer à la première lecture sur « no such table », affiché comme
    /// « Lecture impossible ». Elle revient maintenant — **vide**, ce que le
    /// compte rendu ne cache pas.
    #[test]
    fn une_table_effacee_revient_a_l_ouverture_suivante() {
        let path = scratch_db_path("table_effacee");
        {
            let conn = create_new_database(&path).unwrap();
            conn.execute_batch("DROP TABLE Categorie; DROP TABLE ModeleOperation;")
                .unwrap();
        }

        let opened = open_existing_database(&path, None).unwrap();
        assert_eq!(opened.report.created, vec!["Categorie", "ModeleOperation"]);

        let rows: i64 = opened
            .conn
            .query_row("SELECT COUNT(*) FROM Categorie", [], |r| r.get(0))
            .unwrap();
        assert_eq!(rows, 0, "elle revient vide, et c'est ce qui est annoncé");

        // Deuxième ouverture : plus rien à faire, plus rien à dire.
        drop(opened);
        let again = open_existing_database(&path, None).unwrap();
        assert!(again.report.is_empty());
        drop(again);
        std::fs::remove_file(&path).ok();
    }

    /// **Une nomenclature figée vidée est regarnie, et l'ouverture le dit.**
    ///
    /// Les trois seules : types de compte, statuts d'opération, statuts de
    /// chèque. Une nomenclature qui appartient à l'utilisateur — les banques,
    /// ici — reste vide, parce que la vider peut être un choix.
    #[test]
    fn une_nomenclature_figee_videe_est_regarnie() {
        let path = scratch_db_path("nomenclature_videe");
        {
            let conn = create_new_database(&path).unwrap();
            conn.execute_batch(
                "DELETE FROM TypeCompte;
                 DELETE FROM StatutCheque;
                 DELETE FROM Banques;",
            )
            .unwrap();
        }

        let opened = open_existing_database(&path, None).unwrap();
        assert_eq!(opened.report.reseeded, vec!["TypeCompte", "StatutCheque"]);

        let compte: i64 = opened
            .conn
            .query_row("SELECT COUNT(*) FROM TypeCompte", [], |r| r.get(0))
            .unwrap();
        let cheque: i64 = opened
            .conn
            .query_row("SELECT COUNT(*) FROM StatutCheque", [], |r| r.get(0))
            .unwrap();
        let banques: i64 = opened
            .conn
            .query_row("SELECT COUNT(*) FROM Banques", [], |r| r.get(0))
            .unwrap();
        assert_eq!((compte, cheque, banques), (11, 15, 0));

        drop(opened);
        std::fs::remove_file(&path).ok();
    }

    /// **Une base protégée se refuse, et dit seulement qu'elle se refuse.**
    ///
    /// Le mauvais mot de passe et l'absence de mot de passe donnent la même
    /// réponse, et c'est la vérité du chiffrement : sans la clé, il n'y a
    /// rien à lire, donc rien à distinguer.
    #[test]
    fn une_base_protegee_repond_verrouillee() {
        let path = scratch_db_path("verrouillee");
        create_new_database(&path).unwrap();
        lock::change(&path, "", "sésame").unwrap();

        assert!(matches!(
            open_existing_database(&path, None),
            Err(OpenError::Locked)
        ));
        assert!(matches!(
            open_existing_database(&path, Some("pas celui-là")),
            Err(OpenError::Locked)
        ));
        assert!(open_existing_database(&path, Some("sésame")).is_ok());
        std::fs::remove_file(&path).ok();
    }

    /// **`Parametres` n'est jamais recréée à l'ouverture.**
    ///
    /// C'est la carte d'identité d'une base Radinus. Si la procédure la
    /// rétablissait comme les autres, n'importe quel fichier `.sqlite` choisi
    /// par erreur deviendrait une base Radinus et le refus n'existerait plus.
    /// Le prix est là aussi : la base ci-dessous est perdue pour le logiciel,
    /// et c'est voulu.
    #[test]
    fn la_carte_d_identite_n_est_jamais_recreee() {
        let path = scratch_db_path("sesame");
        {
            let conn = create_new_database(&path).unwrap();
            conn.execute_batch("DROP TABLE Parametres;").unwrap();
        }
        let result = open_existing_database(&path, None);
        assert!(matches!(result, Err(OpenError::NotARadinusDatabase)));

        // Et le fichier n'a pas été transformé au passage : la procédure ne
        // s'est pas lancée du tout.
        {
            let conn = Connection::open(&path).unwrap();
            let has: bool = conn
                .query_row(
                    "SELECT EXISTS (SELECT 1 FROM sqlite_master \
                     WHERE type = 'table' AND name = 'Parametres')",
                    [],
                    |r| r.get(0),
                )
                .unwrap();
            assert!(!has);
        }
        std::fs::remove_file(&path).ok();
    }
}
