//! SQLite DDL for the 21 ported tables and the incremental migration runner.
//!
//! Dossier reference: `02_BASE_DE_DONNEES.md` §1-4 (table shapes, relations,
//! cascades), `08_ARCHITECTURE.md` §"code en anglais" and its i18n paragraph
//! (dedicated "Complement" marker, language-independent).
//!
//! **CORRECTIF (24/07/2026) — table/column names are French, unchanged from
//! the original WinDev schema.** An earlier version of this file translated
//! them to English; Fabrice caught and reverted that: the backup JSON format
//! (06_FORMATS_SAUVEGARDE_IMPORT_EXPORT.md §1) serializes rows keyed by the
//! *exact* original field names (`IDCompte`, `Libelle`, `ReportPointe`, ...),
//! so the database schema must keep those names verbatim for a Windows
//! backup to map onto it directly — this is not optional, it's how the
//! strategic import requirement (Phase 1 §1.3) works at all. The "all code
//! in English" rule (08_ARCHITECTURE.md) governs Rust/TS source identifiers;
//! it was never meant to reach into the database schema itself. `domain.rs`
//! keeps English field names on its Rust structs (that's source code), but
//! every SQL string in this module uses the real French table/column names.
//!
//! Design choices that are NOT naming (still apply, restated against the
//! French names):
//! - **Monetary amounts are stored as `INTEGER` micro-units** (value *
//!   1_000_000), not `REAL`, to preserve the original schema's NUMERIC(24,6)
//!   precision exactly and avoid floating-point rounding drift on money.
//! - **Dates are stored as ISO-8601 `TEXT`** (`AAAA-MM-JJ`), sorts correctly
//!   and converts trivially to/from the backup format's `AAAAMMJJ`.
//! - **Booleans are stored as `INTEGER` 0/1**.
//! - **`Operation.EstComplement`**: a dedicated marker column implementing
//!   the "Complement" sub-operation as a flag rather than by matching the
//!   label text, per 08_ARCHITECTURE.md's i18n paragraph — the one genuinely
//!   new column added beyond the original schema. Named in French like every
//!   other column here, following the existing `EstParent` naming pattern.
//!   Restoring a Windows backup recognizes the legacy "Complément" label and
//!   sets this flag instead of keeping the label as the identification
//!   mechanism.
//! - **The schema is an exact mirror of `base.sql`** — the WinDev-generated
//!   DDL of the original analysis. Every one of its 22 tables is here, with
//!   every column, in the same declaration order. Nothing is dropped, ever:
//!   the author designed that database and it is not this port's place to
//!   decide that a table or a field is superfluous (ruling of 25/07/2026,
//!   after an earlier version of this file had left out `TypeCategorie`,
//!   `ParamSecurite`, `Categorie.IDTypeCategorie` and
//!   `CalOpPeriodique.IDOperation` on the strength of remarks in the dossier).
//!   Only two things are *added*, both explicitly asked for: the
//!   `Preferences` table (2.0.0's own, 02_BASE_DE_DONNEES.md §3.13) and
//!   `Operation.EstComplement` (PLAN_ACTION.md 1.1). `schema_mirrors_base_sql`
//!   below guards this.
//! - **Soft nomenclature links are not declared as SQL `FOREIGN KEY`
//!   constraints.** Every optional "n──1" link that uses the original
//!   `0 = Non précisé` sentinel convention (02_BASE_DE_DONNEES.md §7 rule 2:
//!   `IDModeOperation`, `IDCategorie`, `IDAffectation`, `IDTiers`,
//!   `IDProjets`, `IDCheque` on `Operation`; `IDPosteBudget` on `Categorie`;
//!   the same set on `CalOpPeriodique`/`ModeleOperation`; and
//!   `IDTypeCompte`/`IDBanques` on `Compte`) is stored as a plain indexed
//!   integer, not a `REFERENCES` column. `0` never corresponds to a real row
//!   — HFSQL never enforced these as hard engine-level constraints either,
//!   and 02_BASE_DE_DONNEES.md §7 rule 5 already makes reassignment-to-0 on
//!   deletion an *application*-level responsibility, not a database one.
//!   Declaring them as SQLite `FOREIGN KEY`s under `PRAGMA foreign_keys = ON`
//!   would reject the sentinel value outright, the opposite of the original
//!   behaviour. The five relationships PLAN_ACTION.md 1.1 actually asks for
//!   cascades on (`Compte`->`Operation`, `Operation`->`Commentaire`,
//!   `Operation`->`PiecesJointes`, `Chequier`->`Cheque`, `PosteBudget`->`Budget`)
//!   plus the mandatory-and-never-zero links (`Operation.IDStatutOperation`,
//!   `Cheque.IDStatutCheque`, `Cheque.IDChequier`) remain real `FOREIGN KEY`s.
//! - **Two version numbers, two different things** (ruling by the author,
//!   25/07/2026). `VerSoftMajeur`/`VerSoftMineur`/`VerSoftDebug` is the
//!   *software* version — 2/0/0 for Radinus 2.0.0. `Parametres.VerDataBase`
//!   is the *database* version, and it is a single continuous number line
//!   that Radinus 1.x already walked from 0 to 9: the schema created below
//!   IS that version 9, ported to SQLite, not a new numbering starting at 1.
//!   A 1.9.3 backup therefore carries `VerDataBase: 9` and restores into a
//!   2.0.0 database that is already at 9 — nothing to convert, no conflict.
//!   The next time a phase genuinely changes the shape of the schema, the
//!   number becomes 10. `PRAGMA user_version` mirrors it internally as the
//!   migration runner's bootstrap check (SQLite engine metadata, invisible
//!   to the backup format).

use rusqlite::{Connection, Result};

/// Database schema version implemented by this build (stored in
/// `Parametres.VerDataBase`). 9 était la version qu'avait atteinte Radinus
/// 1.9.x et que ce portage reproduisait à l'identique ; **10 est la première
/// version propre à la 2.0.0** — `Parametres.UtiliseLangue` y devient un
/// entier, le numéro « nation » du WLangage (décision de Fabrice, 01/08/2026).
/// Une base 1.9.3 restaurée passe donc de 9 à 10 en s'ouvrant. Chaîner une
/// étape de plus dans [`migrate`] à chaque changement de forme du schéma.
///
/// **11 — la vérification** (Fabrice, 03/10/2026). `Operation.IDVerification`
/// et sa table `Verification` : ce que l'utilisateur pense d'une écriture,
/// à côté de ce que la banque en dit. Aucune étape écrite à la main : la
/// colonne porte une valeur par défaut — 2, « Vérifiée » — donc
/// `ensure_the_tables` l'ajoute seule à une base 10, et toutes les opérations
/// déjà là sont vérifiées. La table manquante est créée, puis garnie par
/// `FROZEN`.
pub const CURRENT_SCHEMA_VERSION: i64 = 11;

/// Brings `conn`'s schema up to [`CURRENT_SCHEMA_VERSION`], applying
/// incremental migrations in order. Safe to call on every database open
/// (idempotent): a database already at the current version does nothing.
///
/// Whether the schema exists is decided by looking for the `Parametres` table
/// rather than by trusting `PRAGMA user_version`, so that a database written
/// by an earlier build with a different version number is renumbered instead
/// of having `CREATE TABLE` run over it a second time.
pub fn migrate(conn: &Connection) -> Result<SchemaReport> {
    conn.execute_batch("PRAGMA foreign_keys = ON;")?;

    let schema_exists: bool = conn.query_row(
        "SELECT EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'Parametres')",
        [],
        |row| row.get(0),
    )?;
    let report = if schema_exists {
        // Une base qui existe deja : on remet ce qui manque, et on le raconte.
        ensure_the_tables(conn)?
    } else {
        // Une base qui nait : tout est cree d'un coup, `Parametres` comprise,
        // et il n'y a rien a raconter — un schema qui nait n'est pas un schema
        // repare. Le garnissage des nomenclatures n'a pas lieu ici non plus :
        // `seed::seed_initial_data` le fait juste apres, et le faire deux fois
        // ferait collision sur les cles primaires.
        create_baseline_schema(conn)?;
        SchemaReport::default()
    };

    let version: i64 = conn.query_row("PRAGMA user_version", [], |row| row.get(0))?;

    // **`restore_the_mirror` is gone** (05/08/2026). It held two hand-written
    // `ALTER TABLE … ADD COLUMN`, gated on the version number, for the two
    // columns an earlier build had dropped. `ensure_the_tables` now adds every
    // declared column that is missing, on every open and without looking at any
    // version number — so those two steps had become a slower, narrower copy of
    // what happens above.

    // Les migrations s'enchaînent ici, un `if` par étape.
    //
    // Celle-ci est appelée **sans condition de version**, et ce n'est pas un
    // oubli : sa première écriture était fausse et a laissé des bases déjà
    // numérotées 10 avec une colonne encore déclarée `TEXT` (01/08/2026, voir
    // sa documentation). Se fier au numéro de version les aurait abandonnées.
    // Elle regarde la base plutôt que son numéro, et ne fait rien quand il n'y
    // a rien à faire.
    language_becomes_a_number(conn)?;

    if version != CURRENT_SCHEMA_VERSION {
        conn.execute_batch(&format!(
            "PRAGMA user_version = {CURRENT_SCHEMA_VERSION};"
        ))?;
        // Mirror into the real field. No-op on a database being created (the
        // row doesn't exist until `seed`), which is why the value is also set
        // directly by `seed::seed_initial_data`.
        conn.execute(
            "UPDATE Parametres SET VerDataBase = ?1 WHERE IDParametres = 1",
            [CURRENT_SCHEMA_VERSION],
        )?;
    }

    Ok(report)
}

/// Version 10 — `Parametres.UtiliseLangue` passe de `'fr'`/`'en'` au numéro
/// « nation » du WLangage (5, 3, 7…).
///
/// **La première écriture de cette migration était fausse, et voici pourquoi**
/// — c'est la faute que Fabrice a vue le 01/08/2026, « impossible de changer
/// de langue, ça reste en français ». J'avais écrit que SQLite n'a pas besoin
/// qu'on change le type d'une colonne parce que ses types sont portés par la
/// valeur. C'est vrai des colonnes sans affinité ; c'est **faux d'une colonne
/// déclarée `TEXT`**, dont l'affinité convertit tout nombre écrit en texte.
/// Écrire 7 dans l'ancienne colonne y rangeait donc `'7'`, et la lecture, qui
/// demande un entier, échouait et retombait sur le français. Le clic
/// fonctionnait, l'écriture aussi ; c'est la relecture qui rendait toujours la
/// même réponse — une panne muette, la pire sorte.
///
/// La table est donc **refaite**, ce que j'avais refusé de faire par prudence
/// mal placée. Elle ne porte qu'une seule ligne et aucune clé étrangère ne la
/// vise : la reconstruire coûte moins cher que de la laisser mentir.
///
/// Idempotente, et fondée sur ce que la base **est** et non sur son numéro de
/// version : une base déjà passée par la version fautive est réparée au
/// prochain lancement.
fn language_becomes_a_number(conn: &Connection) -> Result<()> {
    let declared: Option<String> = conn
        .query_row(
            "SELECT type FROM pragma_table_info('Parametres') WHERE name = 'UtiliseLangue'",
            [],
            |row| row.get(0),
        )
        .ok();
    let Some(declared) = declared else {
        return Ok(()); // pas de table Parametres : rien à migrer.
    };

    // La valeur, lue en texte : c'est la seule lecture qui marche aussi bien
    // sur un entier que sur une chaîne.
    let stored: Option<String> = conn
        .query_row(
            "SELECT CAST(UtiliseLangue AS TEXT) FROM Parametres WHERE IDParametres = 1",
            [],
            |row| row.get(0),
        )
        .ok();
    let code = code_of(stored.as_deref().unwrap_or("5"));

    if declared.eq_ignore_ascii_case("INTEGER") {
        // La colonne est déjà du bon type ; reste à s'assurer que la valeur
        // l'est aussi (une base réparée deux fois ne doit rien casser).
        if stored.is_some() {
            conn.execute(
                "UPDATE Parametres SET UtiliseLangue = ?1 WHERE IDParametres = 1",
                [code],
            )?;
        }
        return Ok(());
    }

    // ------------------------------------------------------------------
    // Colonne encore déclarée TEXT : on refait la table.
    //
    // **Tout ce qui suit tient en une seule transaction**, et ce n'est pas une
    // précaution de principe (audit du 03/08/2026, §4). Sans elle, chacune des
    // trois écritures se validait toute seule, et il existait un instant — entre
    // le `DROP` et le `RENAME` — où la base n'avait plus de table `Parametres`
    // et pas encore la nouvelle. Une clé USB retirée là, une machine éteinte,
    // un disque plein, et `open_existing_database` répondait « ce fichier n'est
    // pas une base Radinus » sur une base dont les comptes, les opérations et
    // les pièces jointes étaient parfaitement intacts. Il n'existait aucun
    // moyen de la récupérer.
    //
    // C'est le seul couple `DROP`/`RENAME` du fichier : tout le reste de
    // `migrate` est rejouable tel quel.
    // ------------------------------------------------------------------
    let migration = conn.unchecked_transaction()?;

    // **Et l'on nettoie d'abord.** Une base abîmée par une tentative
    // interrompue portait déjà `Parametres_migration` ; le `CREATE` échouait
    // alors sur « table already exists » et la base restait inouvrable pour
    // toujours. Cette table est un échafaudage : s'il en traîne un, il n'a
    // servi à rien et ne demande qu'à être jeté.
    migration.execute_batch("DROP TABLE IF EXISTS Parametres_migration;")?;

    migration.execute_batch(
        "CREATE TABLE Parametres_migration (
            IDParametres   INTEGER PRIMARY KEY CHECK (IDParametres = 1),
            RunOnce        INTEGER NOT NULL DEFAULT 0,
            InitValDefaut  INTEGER NOT NULL DEFAULT 0,
            VerSoftMajeur  INTEGER NOT NULL DEFAULT 2,
            VerSoftMineur  INTEGER NOT NULL DEFAULT 0,
            VerSoftDebug   INTEGER NOT NULL DEFAULT 0,
            VerDataBase    INTEGER NOT NULL DEFAULT 9,
            UtiliseLangue  INTEGER NOT NULL DEFAULT 5
        );",
    )?;
    migration.execute(
        "INSERT INTO Parametres_migration
            (IDParametres, RunOnce, InitValDefaut, VerSoftMajeur, VerSoftMineur,
             VerSoftDebug, VerDataBase, UtiliseLangue)
         SELECT IDParametres, RunOnce, InitValDefaut, VerSoftMajeur, VerSoftMineur,
                VerSoftDebug, VerDataBase, ?1
           FROM Parametres WHERE IDParametres = 1",
        [code],
    )?;
    migration.execute_batch(
        "DROP TABLE Parametres;
         ALTER TABLE Parametres_migration RENAME TO Parametres;",
    )?;
    migration.commit()?;
    Ok(())
}

/// Le numéro d'une langue, à partir de ce que la colonne portait — un nombre
/// déjà, ou l'ancienne étiquette de texte. Ce qu'on ne reconnaît pas devient
/// 5 : mieux vaut le français que rien du tout.
fn code_of(stored: &str) -> i64 {
    let stored = stored.trim();
    if let Ok(number) = stored.parse::<i64>() {
        return number;
    }
    match stored.to_ascii_lowercase().as_str() {
        "en" => 3,
        "es" => 7,
        "pt" => 14,
        "it" => 11,
        "de" => 1,
        "ru" => 16,
        "pl" => 34,
        "uk" => 100,
        "nl" => 12,
        "sv" => 17,
        // `nb` (bokmål) et `no` (le norvégien sans plus de précision)
        // désignent la même nation chez WinDev : une base venue de Windows
        // peut porter l'une ou l'autre.
        "nb" | "no" => 13,
        "ro" => 35,
        "fi" => 8,
        "is" => 10,
        // `iw` est l'ancien code de l'hébreu, abandonné en 1989 mais encore
        // écrit par de vieux systèmes : les deux valent 28.
        "he" | "iw" => 28,
        "ar" => 19,
        "el" => 27,
        _ => 5,
    }
}


/// Ce que la procédure d'assurance du schéma a eu à faire.
///
/// Vide veut dire « la base était complète » — c'est le cas ordinaire, et
/// c'est celui dont on ne parle pas.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct SchemaReport {
    /// Les tables qui manquaient et que la procédure vient de recréer. Elles
    /// reviennent **vides** : recréer une table ne rend pas ce qu'elle
    /// contenait. C'est la contrepartie assumée du dispositif (décision de
    /// Fabrice, 03/08/2026) — mieux vaut un logiciel qui tourne avec un trou
    /// qu'un logiciel qui refuse de s'ouvrir.
    pub created: Vec<String>,
    /// Les nomenclatures figées trouvées vides et regarnies de leurs valeurs
    /// d'origine.
    pub reseeded: Vec<String>,
    /// Columns that a declared table was missing and that have just been
    /// added, written `Table.Column`. They arrive holding their default value
    /// on every existing row — which is why every added column must have one.
    pub columns: Vec<String>,
}

impl SchemaReport {
    /// Rien n'a manqué, rien n'a été regarni.
    pub fn is_empty(&self) -> bool {
        self.created.is_empty() && self.reseeded.is_empty() && self.columns.is_empty()
    }
}

/// One table of the schema: its name, the statement that creates it when it is
/// missing, and the statements that create its indexes.
///
/// **The table and its indexes are separate on purpose** (05/08/2026). They
/// used to be one block of text run in one go, which worked as long as columns
/// never appeared after creation. They do now: [`ensure_the_tables`] adds
/// missing columns between the two, and an index declared on a brand-new column
/// would otherwise be created before the column existed — and fail.
struct TableDeclaration {
    name: &'static str,
    table: &'static str,
    indexes: &'static [&'static str],
}

/// **Le schéma est une déclaration, pas un historique** (décision de Fabrice,
/// 03/08/2026).
///
/// Chaque table porte son propre ordre `CREATE TABLE IF NOT EXISTS`, au lieu
/// du bloc unique que ce fichier exécutait jusqu'ici. Ce n'est pas un
/// rangement : c'est ce qui permet à [`ensure_the_tables`] de tourner à
/// **chaque ouverture** d'une base, de rétablir une table effacée par
/// accident, et de faire apparaître dans les bases existantes une table
/// qu'une version future ajouterait — sans que personne ait à écrire une
/// étape de migration pour elle.
///
/// L'ordre de la liste est celui du schéma d'origine, et il compte : une
/// table qui en référence une autre vient après elle.
///
/// `Parametres` n'est pas dans cette liste, et c'est délibéré — voir
/// [`PARAMETRES`].
const TABLES: &[TableDeclaration] = &[
    // ---------------------------------------------------------------
    // Nomenclatures simples, 02_BASE_DE_DONNEES §3.10
    // ---------------------------------------------------------------
    TableDeclaration {
        name: "TypeCompte",
        table: r#"
        CREATE TABLE IF NOT EXISTS TypeCompte (
            IDTypeCompte INTEGER PRIMARY KEY,
            Libelle      TEXT NOT NULL
        );
        "#,
        indexes: &[
            r#"CREATE INDEX IF NOT EXISTS idx_typecompte_libelle ON TypeCompte(Libelle);"#,
        ],
    },
    TableDeclaration {
        name: "TypeCategorie",
        table: r#"
        CREATE TABLE IF NOT EXISTS TypeCategorie (
            IDTypeCategorie INTEGER PRIMARY KEY,
            Libelle         TEXT NOT NULL
        );
        "#,
        indexes: &[],
    },
    // Le mot de passe n'est jamais exporte dans une sauvegarde (06 §1.2) :
    // cette table existe pour que le schema soit le miroir exact de
    // base.sql, elle n'est ni sauvegardee ni restauree.
    TableDeclaration {
        name: "ParamSecurite",
        table: r#"
        CREATE TABLE IF NOT EXISTS ParamSecurite (
            IDParametres      INTEGER PRIMARY KEY,
            Password          TEXT NOT NULL DEFAULT '',
            DateCrea          TEXT,
            HeureCrea         TEXT,
            IndicePwd         TEXT NOT NULL DEFAULT '',
            DateDernierAcces  TEXT,
            HeureDernierAcces TEXT
        );
        "#,
        indexes: &[],
    },
    TableDeclaration {
        name: "Banques",
        table: r#"
        CREATE TABLE IF NOT EXISTS Banques (
            IDBanques INTEGER PRIMARY KEY,
            NomBanque TEXT NOT NULL
        );
        "#,
        indexes: &[
            r#"CREATE INDEX IF NOT EXISTS idx_banques_nombanque ON Banques(NomBanque);"#,
        ],
    },
    TableDeclaration {
        name: "ModeOperation",
        table: r#"
        CREATE TABLE IF NOT EXISTS ModeOperation (
            IDModeOperation INTEGER PRIMARY KEY,
            Libelle         TEXT NOT NULL
        );
        "#,
        indexes: &[
            r#"CREATE INDEX IF NOT EXISTS idx_modeoperation_libelle ON ModeOperation(Libelle);"#,
        ],
    },
    TableDeclaration {
        name: "Affectation",
        table: r#"
        CREATE TABLE IF NOT EXISTS Affectation (
            IDAffectation INTEGER PRIMARY KEY,
            Libelle       TEXT NOT NULL
        );
        "#,
        indexes: &[
            r#"CREATE INDEX IF NOT EXISTS idx_affectation_libelle ON Affectation(Libelle);"#,
        ],
    },
    TableDeclaration {
        name: "PosteBudget",
        table: r#"
        CREATE TABLE IF NOT EXISTS PosteBudget (
            IDPosteBudget INTEGER PRIMARY KEY,
            Libelle       TEXT NOT NULL
        );
        "#,
        indexes: &[
            r#"CREATE INDEX IF NOT EXISTS idx_postebudget_libelle ON PosteBudget(Libelle);"#,
        ],
    },
    TableDeclaration {
        name: "Tiers",
        table: r#"
        CREATE TABLE IF NOT EXISTS Tiers (
            IDTiers INTEGER PRIMARY KEY,
            Libelle TEXT NOT NULL
        );
        "#,
        indexes: &[
            r#"CREATE INDEX IF NOT EXISTS idx_tiers_libelle ON Tiers(Libelle);"#,
        ],
    },
    TableDeclaration {
        name: "Projets",
        table: r#"
        CREATE TABLE IF NOT EXISTS Projets (
            IDProjets INTEGER PRIMARY KEY,
            Libelle   TEXT NOT NULL
        );
        "#,
        indexes: &[
            r#"CREATE INDEX IF NOT EXISTS idx_projets_libelle ON Projets(Libelle);"#,
        ],
    },
    // Liste FERMEE, 02_BASE_DE_DONNEES §5.2 : exactement 1=Pointe,
    // 2=Engage, 3=Prevu, recree a l'identique par seed::seed_initial_data,
    // jamais modifiable par l'utilisateur.
    TableDeclaration {
        name: "StatutOperation",
        table: r#"
        CREATE TABLE IF NOT EXISTS StatutOperation (
            IDStatutOperation INTEGER PRIMARY KEY,
            Libelle           TEXT NOT NULL
        );
        "#,
        indexes: &[],
    },
    // Liste FERMEE, comme StatutOperation : 1=A verifier, 2=Verifiee,
    // 3=Douteuse, 4=Contestee (Fabrice, 03/10/2026). Le libelle n'est qu'un
    // secours : l'interface traduit par la clef.
    TableDeclaration {
        name: "Verification",
        table: r#"
        CREATE TABLE IF NOT EXISTS Verification (
            IDVerification INTEGER PRIMARY KEY,
            Libelle        TEXT NOT NULL
        );
        "#,
        indexes: &[],
    },
    TableDeclaration {
        name: "StatutCheque",
        table: r#"
        CREATE TABLE IF NOT EXISTS StatutCheque (
            IDStatutCheque INTEGER PRIMARY KEY,
            Libelle        TEXT NOT NULL,
            Description    TEXT NOT NULL DEFAULT ''
        );
        "#,
        indexes: &[
            r#"CREATE INDEX IF NOT EXISTS idx_statutcheque_libelle ON StatutCheque(Libelle);"#,
        ],
    },
    // IDPosteBudget : lien souple, 0 = "non rattachee" (voir commentaire de module).
    TableDeclaration {
        name: "Categorie",
        table: r#"
        CREATE TABLE IF NOT EXISTS Categorie (
            IDCategorie     INTEGER PRIMARY KEY,
            Libelle         TEXT NOT NULL,
            IDTypeCategorie INTEGER NOT NULL DEFAULT 0,
            IDPosteBudget   INTEGER NOT NULL DEFAULT 0
        );
        "#,
        indexes: &[
            r#"CREATE INDEX IF NOT EXISTS idx_categorie_libelle ON Categorie(Libelle);"#,
            r#"CREATE INDEX IF NOT EXISTS idx_categorie_postebudget ON Categorie(IDPosteBudget);"#,
        ],
    },
    // ---------------------------------------------------------------
    // Comptes, 02_BASE_DE_DONNEES §3.1
    // ---------------------------------------------------------------
    // IDTypeCompte, IDBanques : liens souples, 0 = non precise (voir commentaire de module).
    TableDeclaration {
        name: "Compte",
        table: r#"
        CREATE TABLE IF NOT EXISTS Compte (
            IDCompte          INTEGER PRIMARY KEY,
            ReportPointe      INTEGER NOT NULL DEFAULT 0,
            ReportEngage      INTEGER NOT NULL DEFAULT 0,
            ReportPrevu       INTEGER NOT NULL DEFAULT 0,
            Libelle           TEXT NOT NULL,
            IDTypeCompte      INTEGER NOT NULL DEFAULT 0,
            IDBanques         INTEGER NOT NULL DEFAULT 0,
            SoldeBanque       INTEGER NOT NULL DEFAULT 0,
            SoldeReel         INTEGER NOT NULL DEFAULT 0,
            SoldeFinal        INTEGER NOT NULL DEFAULT 0,
            NomTitulaire      TEXT NOT NULL DEFAULT '',
            AdresseTitulaire  TEXT NOT NULL DEFAULT '',
            COBCodeBanque     TEXT NOT NULL DEFAULT '',
            COBCodeGuichet    TEXT NOT NULL DEFAULT '',
            COBNumCompte      TEXT NOT NULL DEFAULT '',
            COBClefRIB        TEXT NOT NULL DEFAULT '',
            COBIBAN           TEXT NOT NULL DEFAULT '',
            DateOuverture     TEXT,
            DateCloture       TEXT,
            AdresseAgenceBank TEXT NOT NULL DEFAULT '',
            COBBIC            TEXT NOT NULL DEFAULT '',
            NumProchCheque    INTEGER NOT NULL DEFAULT 0,
            CompteCloture     INTEGER NOT NULL DEFAULT 0,
            Devise            TEXT NOT NULL DEFAULT 'EUR'
        );
        "#,
        indexes: &[
            r#"CREATE INDEX IF NOT EXISTS idx_compte_typecompte ON Compte(IDTypeCompte);"#,
            r#"CREATE INDEX IF NOT EXISTS idx_compte_banques ON Compte(IDBanques);"#,
        ],
    },
    // ---------------------------------------------------------------
    // Chequiers et cheques, 02_BASE_DE_DONNEES §3.5-3.6
    // ---------------------------------------------------------------
    // IDCompte : lien souple (voir commentaire de module).
    TableDeclaration {
        name: "Chequier",
        table: r#"
        CREATE TABLE IF NOT EXISTS Chequier (
            IDChequier     INTEGER PRIMARY KEY,
            DateRecep      TEXT,
            NumPremierChq  INTEGER NOT NULL DEFAULT 0,
            NumDernChq     INTEGER NOT NULL DEFAULT 0,
            QteChq         INTEGER NOT NULL DEFAULT 0,
            IDReferenceChq TEXT NOT NULL UNIQUE,
            FormatNumChq   INTEGER NOT NULL DEFAULT 0,
            Commentaires   TEXT NOT NULL DEFAULT '',
            IDCompte       INTEGER NOT NULL DEFAULT 0
        );
        "#,
        indexes: &[
            r#"CREATE INDEX IF NOT EXISTS idx_chequier_compte ON Chequier(IDCompte);"#,
        ],
    },
    TableDeclaration {
        name: "Cheque",
        table: r#"
        CREATE TABLE IF NOT EXISTS Cheque (
            IDCheque       INTEGER PRIMARY KEY,
            NumChq         INTEGER NOT NULL,
            IDChequier     INTEGER NOT NULL REFERENCES Chequier(IDChequier) ON DELETE CASCADE,
            DateEmission   TEXT,
            Beneficiaire   TEXT NOT NULL DEFAULT '',
            Montant        INTEGER NOT NULL DEFAULT 0,
            Commentaires   TEXT NOT NULL DEFAULT '',
            LieuEmission   TEXT NOT NULL DEFAULT '',
            IDStatutCheque INTEGER NOT NULL REFERENCES StatutCheque(IDStatutCheque)
        );
        "#,
        indexes: &[
            r#"CREATE UNIQUE INDEX IF NOT EXISTS idx_cheque_chequier_id ON Cheque(IDChequier, IDCheque);"#,
            r#"CREATE UNIQUE INDEX IF NOT EXISTS idx_cheque_chequier_num ON Cheque(IDChequier, NumChq);"#,
        ],
    },
    // ---------------------------------------------------------------
    // Operations et satellites, 02_BASE_DE_DONNEES §3.2-3.4
    // ---------------------------------------------------------------
    // IDModeOperation, IDCategorie, IDAffectation, IDCheque, IDTiers,
    // IDProjets : liens souples (voir commentaire de module).
    // Nullable comme DatePointage : une sauvegarde ancienne peut ne pas
    // porter ce champ, et une restauration ne doit jamais etre refusee
    // pour un champ absent (regle de l'auteur, 25/07/2026).
    // Marqueur dedie "Complement" (voir commentaire de module) —
    // remplace la reconnaissance par libelle, independant de la langue.
    TableDeclaration {
        name: "Operation",
        table: r#"
        CREATE TABLE IF NOT EXISTS Operation (
            IDOperation       INTEGER PRIMARY KEY,
            Libelle           TEXT NOT NULL,
            Date              TEXT,
            Montant           INTEGER NOT NULL,
            IDModeOperation   INTEGER NOT NULL DEFAULT 0,
            IDCategorie       INTEGER NOT NULL DEFAULT 0,
            IDAffectation     INTEGER NOT NULL DEFAULT 0,
            IDCompte          INTEGER NOT NULL REFERENCES Compte(IDCompte) ON DELETE CASCADE,
            DatePointage      TEXT,
            FitID             TEXT NOT NULL DEFAULT '',
            ReferencePaiement TEXT NOT NULL DEFAULT '',
            NumRelevBanque    TEXT NOT NULL DEFAULT '',
            IDStatutOperation INTEGER NOT NULL REFERENCES StatutOperation(IDStatutOperation),
            IDOperationParent INTEGER NOT NULL DEFAULT 0,
            SoldePointe       INTEGER NOT NULL DEFAULT 0,
            EstParent         INTEGER NOT NULL DEFAULT 0,
            GUIDCalOpPeriode  TEXT NOT NULL DEFAULT '',
            IDCheque          INTEGER NOT NULL DEFAULT 0,
            IDTiers           INTEGER NOT NULL DEFAULT 0,
            IDProjets         INTEGER NOT NULL DEFAULT 0,
            EstComplement     INTEGER NOT NULL DEFAULT 0,
            IDVerification    INTEGER NOT NULL DEFAULT 2
        );
        "#,
        indexes: &[
            r#"CREATE INDEX IF NOT EXISTS idx_operation_compte ON Operation(IDCompte);"#,
            r#"CREATE INDEX IF NOT EXISTS idx_operation_categorie ON Operation(IDCategorie);"#,
            r#"CREATE INDEX IF NOT EXISTS idx_operation_modeoperation ON Operation(IDModeOperation);"#,
            r#"CREATE INDEX IF NOT EXISTS idx_operation_affectation ON Operation(IDAffectation);"#,
            r#"CREATE INDEX IF NOT EXISTS idx_operation_statutoperation ON Operation(IDStatutOperation);"#,
            r#"CREATE INDEX IF NOT EXISTS idx_operation_verification ON Operation(IDVerification);"#,
            r#"CREATE INDEX IF NOT EXISTS idx_operation_tiers ON Operation(IDTiers);"#,
            r#"CREATE INDEX IF NOT EXISTS idx_operation_projets ON Operation(IDProjets);"#,
            r#"CREATE INDEX IF NOT EXISTS idx_operation_cheque ON Operation(IDCheque);"#,
            r#"CREATE INDEX IF NOT EXISTS idx_operation_libelle ON Operation(Libelle);"#,
            r#"CREATE INDEX IF NOT EXISTS idx_operation_date ON Operation(Date);"#,
            r#"CREATE INDEX IF NOT EXISTS idx_operation_datepointage ON Operation(DatePointage);"#,
            r#"CREATE INDEX IF NOT EXISTS idx_operation_fitid ON Operation(FitID);"#,
            r#"CREATE INDEX IF NOT EXISTS idx_operation_referencepaiement ON Operation(ReferencePaiement);"#,
            r#"CREATE INDEX IF NOT EXISTS idx_operation_parent ON Operation(IDOperationParent);"#,
            r#"CREATE INDEX IF NOT EXISTS idx_operation_calopperiode ON Operation(GUIDCalOpPeriode);"#,
        ],
    },
    TableDeclaration {
        name: "Commentaire",
        table: r#"
        CREATE TABLE IF NOT EXISTS Commentaire (
            IDCommentaire INTEGER PRIMARY KEY,
            CommentaireTxt TEXT NOT NULL DEFAULT '',
            IDOperation   INTEGER NOT NULL UNIQUE REFERENCES Operation(IDOperation) ON DELETE CASCADE
        );
        "#,
        indexes: &[],
    },
    TableDeclaration {
        name: "PiecesJointes",
        table: r#"
        CREATE TABLE IF NOT EXISTS PiecesJointes (
            IDOperation      INTEGER NOT NULL REFERENCES Operation(IDOperation) ON DELETE CASCADE,
            IDPiecesJointes  INTEGER PRIMARY KEY,
            NomFichier       TEXT NOT NULL,
            NomFichierGUID   TEXT NOT NULL,
            PathRelFichier   TEXT NOT NULL,
            TailleFich       INTEGER NOT NULL DEFAULT 0,
            MiMeType         TEXT NOT NULL DEFAULT '',
            DateAjout        TEXT,
            CheckSumInfo     TEXT NOT NULL DEFAULT '',
            NoteInfo         TEXT NOT NULL DEFAULT ''
        );
        "#,
        indexes: &[
            r#"CREATE INDEX IF NOT EXISTS idx_piecesjointes_operation ON PiecesJointes(IDOperation);"#,
            r#"CREATE INDEX IF NOT EXISTS idx_piecesjointes_guid ON PiecesJointes(NomFichierGUID);"#,
        ],
    },
    // ---------------------------------------------------------------
    // Regles periodiques et modeles, 02_BASE_DE_DONNEES §3.7-3.8
    // ---------------------------------------------------------------
    // Liens de nomenclature souples (voir commentaire de module).
    // 1=Jour, 2=Semaine, 3=Mois, 4=Trimestre, 5=Annee (Date_EcheanceSuivante, CONFIRME)
    // 1=Sans limite, 2=Date de fin, 3=Nombre de repetitions (Existe_EcheanceSuivante, CONFIRME)
    TableDeclaration {
        name: "CalOpPeriodique",
        table: r#"
        CREATE TABLE IF NOT EXISTS CalOpPeriodique (
            GUIDCalOpPeriode  TEXT PRIMARY KEY,
            Libelle           TEXT NOT NULL,
            IDModeOperation   INTEGER NOT NULL DEFAULT 0,
            IDCategorie       INTEGER NOT NULL DEFAULT 0,
            IDAffectation     INTEGER NOT NULL DEFAULT 0,
            IDCompte          INTEGER NOT NULL DEFAULT 0,
            IDStatutOperation INTEGER NOT NULL DEFAULT 0,
            Montant           INTEGER NOT NULL DEFAULT 0,
            DateFin           TEXT,
            Periode           INTEGER NOT NULL DEFAULT 3,
            PeriodeNbrRepete  INTEGER NOT NULL DEFAULT 0,
            PeriodeFreq       INTEGER NOT NULL DEFAULT 1,
            ModeFinInsertion  INTEGER NOT NULL DEFAULT 1,
            DateDernOpGen     TEXT,
            NbrOpInsert       INTEGER NOT NULL DEFAULT 0,
            NbrOpAnterieur    INTEGER NOT NULL DEFAULT 0,
            IDOperation       INTEGER NOT NULL DEFAULT 0,
            DateProchOp       TEXT,
            MontantInsert     INTEGER NOT NULL DEFAULT 0,
            IDTiers           INTEGER NOT NULL DEFAULT 0,
            IDProjets         INTEGER NOT NULL DEFAULT 0
        );
        "#,
        indexes: &[
            r#"CREATE INDEX IF NOT EXISTS idx_calopperiodique_compte ON CalOpPeriodique(IDCompte);"#,
        ],
    },
    TableDeclaration {
        name: "ModeleOperation",
        table: r#"
        CREATE TABLE IF NOT EXISTS ModeleOperation (
            IDModeleOperation INTEGER PRIMARY KEY,
            Libelle           TEXT NOT NULL,
            Montant           INTEGER NOT NULL DEFAULT 0,
            IDModeOperation   INTEGER NOT NULL DEFAULT 0,
            IDCategorie       INTEGER NOT NULL DEFAULT 0,
            IDAffectation     INTEGER NOT NULL DEFAULT 0,
            IDStatutOperation INTEGER NOT NULL DEFAULT 0,
            IDTiers           INTEGER NOT NULL DEFAULT 0,
            IDProjets         INTEGER NOT NULL DEFAULT 0
        );
        "#,
        indexes: &[],
    },
    // ---------------------------------------------------------------
    // Budget, 02_BASE_DE_DONNEES §3.9
    // ---------------------------------------------------------------
    TableDeclaration {
        name: "Budget",
        table: r#"
        CREATE TABLE IF NOT EXISTS Budget (
            IDBudget      INTEGER PRIMARY KEY,
            Annee         INTEGER NOT NULL,
            Mois          INTEGER NOT NULL,
            IDPosteBudget INTEGER NOT NULL REFERENCES PosteBudget(IDPosteBudget) ON DELETE CASCADE,
            Montant       INTEGER NOT NULL DEFAULT 0
        );
        "#,
        indexes: &[
            r#"CREATE INDEX IF NOT EXISTS idx_budget_annee_mois_poste ON Budget(Annee, Mois, IDPosteBudget);"#,
        ],
    },
    // ---------------------------------------------------------------
    // Preferences, 02_BASE_DE_DONNEES §3.13
    // ---------------------------------------------------------------
    TableDeclaration {
        name: "Preferences",
        table: r#"
        CREATE TABLE IF NOT EXISTS Preferences (
            IDPreferences INTEGER PRIMARY KEY,
            Cle           TEXT NOT NULL UNIQUE,
            ValeurJSON    TEXT NOT NULL DEFAULT '{}'
        );
        "#,
        indexes: &[],
    },
];

/// **La carte d'identité, et la seule table que l'ouverture ne recrée jamais**
/// (décision de Fabrice, 03/08/2026).
///
/// `open_existing_database` reconnaît une base Radinus à la présence de cette
/// table, et à rien d'autre. Si [`ensure_the_tables`] la créait comme les
/// vingt-deux autres, ce contrôle disparaîtrait de lui-même : n'importe quel
/// fichier `.sqlite` choisi par erreur dans le sélecteur deviendrait une base
/// Radinus, et le message « ce fichier n'est pas une base Radinus » ne
/// pourrait plus jamais s'afficher. Elle n'est donc écrite qu'ici, à la
/// création d'une base neuve.
///
/// La contrepartie est réelle et acceptée : une base dont on efface cette
/// table est perdue pour le logiciel, alors même que ses opérations sont
/// intactes à l'intérieur.
// Version de schema (voir commentaire de module) ; miroir de PRAGMA user_version.
// Le numero de la constante "nation" du WLangage : 5 = francais,
// 3 = anglais, 7 = espagnol. Decision de Fabrice du 01/08/2026,
// qui revise le 02_BASE_DE_DONNEES.md §3.11 : une sauvegarde
// 1.9.3 porte ce nombre, on le lui rend tel quel.
const PARAMETRES: &str = r#"
    CREATE TABLE IF NOT EXISTS Parametres (
        IDParametres   INTEGER PRIMARY KEY CHECK (IDParametres = 1),
        RunOnce        INTEGER NOT NULL DEFAULT 0,
        InitValDefaut  INTEGER NOT NULL DEFAULT 0,
        VerSoftMajeur  INTEGER NOT NULL DEFAULT 2,
        VerSoftMineur  INTEGER NOT NULL DEFAULT 0,
        VerSoftDebug   INTEGER NOT NULL DEFAULT 0,
        VerDataBase    INTEGER NOT NULL DEFAULT 9,
        UtiliseLangue  INTEGER NOT NULL DEFAULT 5
    );
"#;

/// Les nomenclatures **figées** : leur contenu ne vient pas de l'utilisateur,
/// il vient du logiciel, et lui seul peut le rétablir.
///
/// Vides, elles rendent la saisie impossible — on ne peut plus choisir un type
/// de compte, ni un statut d'opération, ni un statut de chèque. C'est
/// exactement ce que relève le `Reparation_Base()` de l'original, et la même
/// idée s'applique ici : une table de référence vide n'est pas une base neuve,
/// c'est une base blessée.
///
/// Les autres nomenclatures — banques, tiers, catégories, postes budgétaires —
/// n'y sont pas : celles-là appartiennent à l'utilisateur, qui a le droit de
/// les vider et n'aimerait pas les voir revenir.
type Refill = fn(&Connection) -> Result<()>;
const FROZEN: &[(&str, Refill)] = &[
    ("TypeCompte", super::seed::seed_types_compte),
    ("StatutOperation", super::seed::seed_statuts_operation),
    ("StatutCheque", super::seed::seed_statuts_cheque),
    ("Verification", super::seed::seed_verifications),
];

/// Est-ce que cette table existe dans la base ouverte ?
fn table_exists(conn: &Connection, name: &str) -> Result<bool> {
    conn.query_row(
        "SELECT EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?1)",
        [name],
        |row| row.get(0),
    )
}

/// Est-ce que cette table est vide ?
fn table_is_empty(conn: &Connection, table: &str) -> Result<bool> {
    let count: i64 = conn.query_row(&format!("SELECT COUNT(*) FROM {table}"), [], |row| {
        row.get(0)
    })?;
    Ok(count == 0)
}

/// A column as SQLite itself describes it — name, declared type, whether it is
/// mandatory, and its default value.
///
/// **Read from SQLite, never parsed from our own SQL.** `pragma_table_info`
/// hands back exactly these four facts for every column of a table, which means
/// nothing in this file has to understand SQL text. SQLite already parsed it;
/// asking it is both shorter and correct.
#[derive(Debug, Clone, PartialEq, Eq)]
struct ColumnShape {
    name: String,
    kind: String,
    mandatory: bool,
    default: Option<String>,
    primary_key: bool,
}

/// Can this column be added to a table that already holds rows?
///
/// SQLite says no in two cases, and both are final: a primary key, and a
/// mandatory column with no default — there would be nothing to write in the
/// rows already there. Declared at the table's birth they are perfectly fine;
/// it is only *adding* them afterwards that is impossible.
fn restorable(column: &ColumnShape) -> bool {
    !column.primary_key && (!column.mandatory || column.default.is_some())
}

/// The columns of `table`, as they exist in the database `conn` is connected
/// to. An empty list means the table itself is absent.
fn columns_of(conn: &Connection, table: &str) -> Result<Vec<ColumnShape>> {
    let mut statement =
        conn.prepare("SELECT name, type, \"notnull\", dflt_value, pk FROM pragma_table_info(?1)")?;
    let rows = statement
        .query_map([table], |row| {
            Ok(ColumnShape {
                name: row.get(0)?,
                kind: row.get(1)?,
                mandatory: row.get::<_, i64>(2)? != 0,
                default: row.get(3)?,
                primary_key: row.get::<_, i64>(4)? != 0,
            })
        })?
        .collect::<Result<Vec<_>>>()?;
    Ok(rows)
}

/// **The model: an empty, perfectly shaped database, built in memory.**
///
/// This is the heart of the whole mechanism (Fabrice, 05/08/2026). Rather than
/// shipping a blank `.sqlite` file inside the binary, or a hand-written
/// description of the schema, Radinus *builds* its model from the very
/// declarations it would use to create a real database — [`TABLES`] and
/// [`PARAMETRES`].
///
/// The point is that there is then **one source of truth instead of two**. A
/// shipped model file, or a separate description, drifts from the code the day
/// someone changes one without the other — and from then on the software
/// compares real databases against something false. A model built from the
/// declarations *is* the declarations, and cannot disagree with them.
///
/// It lives in RAM, never touches the disk, and disappears when the connection
/// is dropped. Building it costs a few milliseconds once per open.
fn model() -> Result<Connection> {
    let conn = Connection::open_in_memory()?;
    // Foreign keys stay off here: the model is never written to, and a table
    // that references one declared after it would otherwise have to be ordered
    // twice — once for real databases, once for this one.
    conn.execute_batch(PARAMETRES)?;
    for table in TABLES {
        conn.execute_batch(table.table)?;
    }
    Ok(conn)
}

/// Writes the `ALTER TABLE … ADD COLUMN …` that brings `column` into `table`.
///
/// Every part of it comes from the model — the name, the declared type, the
/// mandatory flag and the default — so the column added to an old database is
/// shaped exactly like the one a new database would get.
///
/// **SQLite refuses two things here, and both refusals are welcome.** A
/// mandatory column with no default cannot be added, which is precisely the
/// rule of 25/07/2026 (a restore must never be refused for a missing field) now
/// enforced by the engine itself. And a primary key cannot be added after the
/// fact — but a primary key is declared at birth and never goes missing.
fn add_column_statement(table: &str, column: &ColumnShape) -> String {
    let mut sql = format!(
        "ALTER TABLE {table} ADD COLUMN {} {}",
        column.name, column.kind
    );
    if column.mandatory {
        sql.push_str(" NOT NULL");
    }
    if let Some(default) = &column.default {
        sql.push_str(" DEFAULT ");
        sql.push_str(default);
    }
    sql.push(';');
    sql
}

/// **Brings every existing table up to the shape it is declared to have.**
///
/// For each declared table, ask the model what columns it should carry, ask the
/// real database what it does carry, and add the difference. Nothing is ever
/// removed, renamed or retyped — see the module documentation and
/// `docs/Schema_evolution.md` for why those three stay manual.
///
/// A column added this way lands at the end of its table rather than at its
/// declared position, because SQLite cannot insert one in the middle without
/// rebuilding the table. That is invisible everywhere it matters: every query
/// in this crate names its columns, and so does the archive format.
fn ensure_the_columns(
    conn: &Connection,
    model: &Connection,
    report: &mut SchemaReport,
) -> Result<()> {
    for table in TABLES {
        let present = columns_of(conn, table.name)?;
        if present.is_empty() {
            // The table itself was just created from the same declaration, so
            // it cannot be short of a column. An empty answer here means the
            // table does not exist at all, which is not this function's job.
            continue;
        }
        for wanted in columns_of(model, table.name)? {
            if present.iter().any(|had| had.name == wanted.name) {
                continue;
            }
            if !restorable(&wanted) {
                // **Some columns cannot be put back by anyone.** SQLite refuses
                // `ADD COLUMN` for a primary key, and for a mandatory column
                // with no default value — there would be nothing to write in
                // the rows that already exist. Attempting either would turn a
                // hole in one table into a database that refuses to open at
                // all, which is strictly worse.
                //
                // The list of columns concerned is fixed and named in
                // `toute_colonne_obligatoire_porte_une_valeur_par_defaut`,
                // which forbids adding a new one. See
                // `docs/Schema_evolution.md`.
                continue;
            }
            conn.execute_batch(&add_column_statement(table.name, &wanted))?;
            report
                .columns
                .push(format!("{}.{}", table.name, wanted.name));
        }
    }
    Ok(())
}

/// The columns a table is **declared** to carry, in declaration order.
///
/// Read from the in-memory model rather than from the declaration text, so the
/// answer is what SQLite understands and not what a reader of the file might
/// guess. `Parametres` is included, even though it lives apart from `TABLES`.
///
/// Public because the archive has to be checked against it: what a database
/// holds and what a backup carries are two lists written in two files, and
/// `backup::writer` owns the test that stops them drifting apart.
pub fn declared_columns(table: &str) -> Vec<String> {
    let Ok(model) = model() else {
        return Vec::new();
    };
    columns_of(&model, table)
        .map(|columns| columns.into_iter().map(|column| column.name).collect())
        .unwrap_or_default()
}

/// The names of every declared table, `Parametres` included.
pub fn declared_tables() -> Vec<&'static str> {
    let mut names: Vec<&'static str> = TABLES.iter().map(|table| table.name).collect();
    names.push("Parametres");
    names
}

/// **Restores whatever is missing, on every open of a database.**
///
/// Three passes, in this order, and the order is what makes it work:
///
/// 1. **The tables** — every declared table that is gone comes back, empty.
/// 2. **The columns** — every declared column missing from a table that exists
///    is added, with its type and its default value ([`ensure_the_columns`]).
/// 3. **The indexes** — created last, because one of them may be declared on a
///    column that pass 2 has only just added.
///
/// Then the frozen nomenclatures found empty are refilled.
///
/// Nothing is destroyed and nothing existing is modified: `CREATE TABLE IF NOT
/// EXISTS` leaves a present table alone whatever its shape, and pass 2 only
/// ever adds.
///
/// **What it will never do**, and must not be asked to: remove a column, rename
/// one, or change its type. Those three remain explicit, hand-written steps —
/// like `language_becomes_a_number`, which had to rebuild `Parametres`. They are
/// rare, they are dangerous, and they should cost an effort.
pub fn ensure_the_tables(conn: &Connection) -> Result<SchemaReport> {
    let mut report = SchemaReport::default();

    for table in TABLES {
        if !table_exists(conn, table.name)? {
            report.created.push(table.name.to_string());
        }
        conn.execute_batch(table.table)?;
    }

    ensure_the_columns(conn, &model()?, &mut report)?;

    for table in TABLES {
        for index in table.indexes {
            conn.execute_batch(index)?;
        }
    }

    for (name, refill) in FROZEN {
        if table_is_empty(conn, name)? {
            refill(conn)?;
            report.reseeded.push((*name).to_string());
        }
    }

    Ok(report)
}

/// Creates the whole schema of a brand-new database: `Parametres` first, then
/// the twenty-two other tables with their indexes and their cascades.
///
/// Initial values are not written here: `seed::seed_initial_data` does that,
/// and it alone — doing it in both places would collide on primary keys.
fn create_baseline_schema(conn: &Connection) -> Result<()> {
    conn.execute_batch(PARAMETRES)?;
    for table in TABLES {
        conn.execute_batch(table.table)?;
        for index in table.indexes {
            conn.execute_batch(index)?;
        }
    }
    Ok(())
}

#[cfg(test)]
mod migration_langue_tests {
    use super::*;

    /// Fabrique une base telle que la version fautive du 01/08/2026 la laissait :
    /// `PRAGMA user_version` déjà à 10, mais la colonne encore déclarée `TEXT`
    /// et portant `'7'` au lieu de 7.
    /// **Une migration interrompue ne condamne pas la base.**
    ///
    /// Le défaut relevé par l'audit du 03/08/2026 (§4) : les trois écritures
    /// de `language_becomes_a_number` se validaient chacune de leur côté, et
    /// une interruption entre le `DROP` et le `RENAME` laissait une base sans
    /// table `Parametres` — donc refusée à l'ouverture, définitivement, avec
    /// toutes ses opérations intactes à l'intérieur.
    ///
    /// Ce test rejoue la trace de cette panne : une base qui porte encore la
    /// colonne en texte **et** une table `Parametres_migration` abandonnée par
    /// une tentative précédente. Avant le correctif, le `CREATE TABLE`
    /// échouait sur « table already exists » et la base restait perdue. Elle
    /// doit maintenant s'ouvrir et parler la bonne langue.
    #[test]
    fn une_migration_interrompue_se_rejoue_au_lancement_suivant() {
        let conn = base_avec_la_colonne_texte("es");
        // L'échafaudage qu'une tentative interrompue a laissé sur place.
        conn.execute_batch(
            "CREATE TABLE Parametres_migration (
                IDParametres   INTEGER PRIMARY KEY CHECK (IDParametres = 1),
                RunOnce        INTEGER NOT NULL DEFAULT 0,
                InitValDefaut  INTEGER NOT NULL DEFAULT 0,
                VerSoftMajeur  INTEGER NOT NULL DEFAULT 2,
                VerSoftMineur  INTEGER NOT NULL DEFAULT 0,
                VerSoftDebug   INTEGER NOT NULL DEFAULT 0,
                VerDataBase    INTEGER NOT NULL DEFAULT 9,
                UtiliseLangue  INTEGER NOT NULL DEFAULT 5
            );",
        )
        .unwrap();

        migrate(&conn).expect("la migration doit se rejouer, pas échouer");

        let (valeur, sorte): (i64, String) = conn
            .query_row(
                "SELECT UtiliseLangue, typeof(UtiliseLangue) FROM Parametres WHERE IDParametres = 1",
                [],
                |row| Ok((row.get(0)?, row.get(1)?)),
            )
            .unwrap();
        assert_eq!((valeur, sorte.as_str()), (7, "integer"));

        // Et l'échafaudage a disparu : il ne doit rien rester en travers du
        // chemin pour la prochaine ouverture.
        let reste: i64 = conn
            .query_row(
                "SELECT COUNT(*) FROM sqlite_master
                  WHERE type = 'table' AND name = 'Parametres_migration'",
                [],
                |row| row.get(0),
            )
            .unwrap();
        assert_eq!(reste, 0, "la table de travail doit être partie");
    }

    fn base_avec_la_colonne_texte(langue: &str) -> Connection {
        let conn = Connection::open_in_memory().unwrap();
        conn.execute_batch(
            "CREATE TABLE Parametres (
                IDParametres   INTEGER PRIMARY KEY CHECK (IDParametres = 1),
                RunOnce        INTEGER NOT NULL DEFAULT 0,
                InitValDefaut  INTEGER NOT NULL DEFAULT 0,
                VerSoftMajeur  INTEGER NOT NULL DEFAULT 2,
                VerSoftMineur  INTEGER NOT NULL DEFAULT 0,
                VerSoftDebug   INTEGER NOT NULL DEFAULT 0,
                VerDataBase    INTEGER NOT NULL DEFAULT 9,
                UtiliseLangue  TEXT NOT NULL DEFAULT 'fr'
            );",
        )
        .unwrap();
        conn.execute(
            "INSERT INTO Parametres (IDParametres, RunOnce, InitValDefaut, VerDataBase, UtiliseLangue)
             VALUES (1, 1, 1, 10, ?1)",
            [langue],
        )
        .unwrap();
        conn.execute_batch("PRAGMA user_version = 10;").unwrap();
        conn
    }

    fn declaration(conn: &Connection) -> String {
        conn.query_row(
            "SELECT type FROM pragma_table_info('Parametres') WHERE name = 'UtiliseLangue'",
            [],
            |row| row.get(0),
        )
        .unwrap()
    }

    /// **La panne exacte que Fabrice a vue** : il choisit l'espagnol, la base
    /// reçoit bien 7, et le logiciel reste en français parce que la colonne
    /// `TEXT` a rangé `'7'` et que la lecture demandait un entier.
    #[test]
    fn une_base_laissee_en_texte_est_reparee_et_parle_enfin_sa_langue() {
        let conn = base_avec_la_colonne_texte("7");
        assert_eq!(declaration(&conn), "TEXT");

        migrate(&conn).unwrap();

        assert_eq!(declaration(&conn), "INTEGER", "la table n'a pas ete refaite");
        let (valeur, sorte): (i64, String) = conn
            .query_row(
                "SELECT UtiliseLangue, typeof(UtiliseLangue) FROM Parametres WHERE IDParametres = 1",
                [],
                |row| Ok((row.get(0)?, row.get(1)?)),
            )
            .unwrap();
        assert_eq!((valeur, sorte.as_str()), (7, "integer"));
        assert_eq!(
            crate::i18n::stored_language(&conn),
            crate::i18n::Language::Spanish,
            "elle doit enfin parler espagnol"
        );
    }

    /// Une base d'avant la décision, qui porte encore l'étiquette de texte.
    #[test]
    fn une_base_qui_porte_encore_une_etiquette_devient_un_numero() {
        for (etiquette, attendu) in [
            ("fr", 5),
            ("en", 3),
            ("es", 7),
            ("pt", 14),
            ("it", 11),
            ("de", 1),
            ("ru", 16),
            ("pl", 34),
            ("uk", 100),
            ("nl", 12),
            ("sv", 17),
            ("nb", 13),
            ("no", 13),
            ("ro", 35),
            ("fi", 8),
            ("is", 10),
            ("he", 28),
            ("iw", 28),
            ("ar", 19),
            ("el", 27),
        ] {
            let conn = base_avec_la_colonne_texte(etiquette);
            migrate(&conn).unwrap();
            let valeur: i64 = conn
                .query_row(
                    "SELECT UtiliseLangue FROM Parametres WHERE IDParametres = 1",
                    [],
                    |row| row.get(0),
                )
                .unwrap();
            assert_eq!(valeur, attendu, "« {etiquette} »");
        }
    }

    /// Réparer deux fois ne casse rien, et ne perd pas la langue.
    #[test]
    fn reparer_deux_fois_ne_change_rien() {
        let conn = base_avec_la_colonne_texte("3");
        migrate(&conn).unwrap();
        migrate(&conn).unwrap();
        assert_eq!(declaration(&conn), "INTEGER");
        assert_eq!(
            crate::i18n::stored_language(&conn),
            crate::i18n::Language::English
        );
    }

    /// La reconstruction ne doit rien perdre du reste de la ligne.
    #[test]
    fn la_reconstruction_garde_les_autres_champs() {
        let conn = base_avec_la_colonne_texte("7");
        conn.execute(
            "UPDATE Parametres SET VerSoftMajeur = 2, VerSoftMineur = 0, RunOnce = 1",
            [],
        )
        .unwrap();
        migrate(&conn).unwrap();
        let (run_once, majeur, db): (i64, i64, i64) = conn
            .query_row(
                "SELECT RunOnce, VerSoftMajeur, VerDataBase FROM Parametres WHERE IDParametres = 1",
                [],
                |row| Ok((row.get(0)?, row.get(1)?, row.get(2)?)),
            )
            .unwrap();
        assert_eq!((run_once, majeur, db), (1, 2, CURRENT_SCHEMA_VERSION));
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// The 22 tables of `base.sql`, plus `Preferences` (2.0.0's own), in
    /// alphabetical order. This list exists so that removing a table becomes
    /// a deliberate act that breaks a test, instead of a silent judgement
    /// call — see the module doc comment.
    const EXPECTED_TABLES: &[&str] = &[
        "Affectation",
        "Banques",
        "Budget",
        "CalOpPeriodique",
        "Categorie",
        "Cheque",
        "Chequier",
        "Commentaire",
        "Compte",
        "ModeOperation",
        "ModeleOperation",
        "Operation",
        "ParamSecurite",
        "Parametres",
        "PiecesJointes",
        "PosteBudget",
        "Preferences",
        "Projets",
        "StatutCheque",
        "StatutOperation",
        "Tiers",
        "TypeCategorie",
        "TypeCompte",
        "Verification",
    ];

    /// The indexes that use `column`, as SQLite lists them. Dropping a column
    /// is refused while an index still mentions it, so a test that wants to
    /// make a column disappear has to clear its indexes first.
    fn indexes_using(conn: &Connection, table: &str, column: &str) -> Vec<String> {
        let mut names: Vec<String> = Vec::new();
        let mut list = conn
            .prepare("SELECT name FROM pragma_index_list(?1)")
            .unwrap();
        let candidates: Vec<String> = list
            .query_map([table], |row| row.get(0))
            .unwrap()
            .collect::<Result<_>>()
            .unwrap();
        for index in candidates {
            let mut info = conn
                .prepare("SELECT name FROM pragma_index_info(?1)")
                .unwrap();
            let used: Vec<Option<String>> = info
                .query_map([&index], |row| row.get(0))
                .unwrap()
                .collect::<Result<_>>()
                .unwrap();
            if used.iter().flatten().any(|name| name == column) {
                names.push(index);
            }
        }
        names
    }

    /// **Every column of every table comes back when it is missing — and its
    /// indexes with it.**
    ///
    /// The guard that makes the mechanism trustworthy rather than merely
    /// plausible (Fabrice, 05/08/2026: he wanted to master it *absolutely*).
    /// It is not a sample: it removes **each column of each table, one at a
    /// time**, reopens, and checks the column is back with the same declared
    /// type, the same mandatory flag and the same default — then that the
    /// indexes which covered it are back too.
    ///
    /// **The indexes are dropped first**, because SQLite refuses to drop a
    /// column an index still mentions. That is what makes this test also cover
    /// the ordering the declarations were split for: a column added in pass 2,
    /// its indexes created in pass 3, never the other way round.
    ///
    /// Columns SQLite could never add back are left out — see [`restorable`].
    /// They are named one by one in
    /// `toute_colonne_obligatoire_porte_une_valeur_par_defaut`.
    #[test]
    fn aucune_colonne_ne_peut_manquer_sans_revenir() {
        let reference = Connection::open_in_memory().unwrap();
        migrate(&reference).unwrap();

        let mut checked = 0usize;
        for table in TABLES {
            for column in columns_of(&reference, table.name).unwrap() {
                if !restorable(&column) {
                    continue;
                }
                let conn = Connection::open_in_memory().unwrap();
                migrate(&conn).unwrap();

                let covering = indexes_using(&conn, table.name, &column.name);
                for index in &covering {
                    conn.execute_batch(&format!("DROP INDEX {index};")).unwrap();
                }
                conn.execute_batch(&format!(
                    "ALTER TABLE {} DROP COLUMN {};",
                    table.name, column.name
                ))
                .unwrap_or_else(|error| panic!("{}.{} : {error}", table.name, column.name));

                let report = migrate(&conn).unwrap();
                assert_eq!(
                    report.columns,
                    vec![format!("{}.{}", table.name, column.name)],
                    "la colonne effacée doit être annoncée, et elle seule"
                );

                let back = columns_of(&conn, table.name)
                    .unwrap()
                    .into_iter()
                    .find(|had| had.name == column.name)
                    .unwrap_or_else(|| {
                        panic!("{}.{} n'est pas revenue", table.name, column.name)
                    });
                assert_eq!(
                    (back.kind, back.mandatory, back.default),
                    (column.kind.clone(), column.mandatory, column.default.clone()),
                    "{}.{} est revenue, mais pas telle qu'elle est déclarée",
                    table.name,
                    column.name
                );

                for index in &covering {
                    let found: i64 = conn
                        .query_row(
                            "SELECT COUNT(*) FROM sqlite_master \
                             WHERE type = 'index' AND name = ?1",
                            [index],
                            |row| row.get(0),
                        )
                        .unwrap();
                    assert_eq!(
                        found, 1,
                        "{index} n'a pas été refait après le retour de {}.{}",
                        table.name, column.name
                    );
                }
                checked += 1;
            }
        }
        // Ninety-three on 05/08/2026: every column of the twenty-two tables,
        // less the primary keys and the thirty-one that can never be added
        // back. The floor only guards against the loop quietly emptying itself.
        assert!(
            checked >= 90,
            "trop peu de colonnes vérifiées ({checked}) : le test ne parcourt plus le schéma"
        );
    }

    /// **The columns that can never be restored, named one by one.**
    ///
    /// A mandatory column with no default cannot be added to a table that
    /// already holds rows — there would be nothing to write in them. SQLite
    /// refuses, and so does [`ensure_the_columns`], which skips them rather
    /// than turning a hole in one table into a database that will not open.
    ///
    /// The thirty-one below are the ones inherited from `base.sql`, where they
    /// were declared at their table's birth and are perfectly legitimate. They
    /// are listed here so that **adding a thirty-second breaks this test**: a
    /// new mandatory column without a default would appear in fresh databases
    /// and silently never in anyone else's. Give it a default, or add it here
    /// knowing it can never reach an existing database.
    ///
    /// This is the same shape of guard as `EXPECTED_TABLES`: a list that only
    /// changes on purpose.
    #[test]
    fn toute_colonne_obligatoire_porte_une_valeur_par_defaut() {
        const INHERITED: &[&str] = &[
            "Affectation.Libelle",
            "Banques.NomBanque",
            "Budget.Annee",
            "Budget.IDPosteBudget",
            "Budget.Mois",
            "CalOpPeriodique.Libelle",
            "Categorie.Libelle",
            "Cheque.IDChequier",
            "Cheque.IDStatutCheque",
            "Cheque.NumChq",
            "Chequier.IDReferenceChq",
            "Commentaire.IDOperation",
            "Compte.Libelle",
            "ModeOperation.Libelle",
            "ModeleOperation.Libelle",
            "Operation.IDCompte",
            "Operation.IDStatutOperation",
            "Operation.Libelle",
            "Operation.Montant",
            "PiecesJointes.IDOperation",
            "PiecesJointes.NomFichier",
            "PiecesJointes.NomFichierGUID",
            "PiecesJointes.PathRelFichier",
            "PosteBudget.Libelle",
            "Preferences.Cle",
            "Projets.Libelle",
            "StatutCheque.Libelle",
            "StatutOperation.Libelle",
            "Tiers.Libelle",
            "TypeCategorie.Libelle",
            "TypeCompte.Libelle",
            "Verification.Libelle",
        ];

        let conn = Connection::open_in_memory().unwrap();
        migrate(&conn).unwrap();

        let mut found: Vec<String> = Vec::new();
        for table in TABLES {
            for column in columns_of(&conn, table.name).unwrap() {
                if !column.primary_key && !restorable(&column) {
                    found.push(format!("{}.{}", table.name, column.name));
                }
            }
        }
        found.sort();

        let mut expected: Vec<String> = INHERITED.iter().map(|n| n.to_string()).collect();
        expected.sort();
        assert_eq!(
            found, expected,
            "une colonne obligatoire sans valeur par défaut a été ajoutée ou retirée : \
             elle ne pourra jamais rejoindre une base existante, et une sauvegarde à qui \
             elle manque serait refusée. Donnez-lui un défaut, ou ajoutez-la à cette liste \
             en sachant ce que cela coûte."
        );
    }

    /// The model built in memory is the very schema a real database gets —
    /// same tables, same columns. If the two could differ, every comparison
    /// made against the model would be worthless.
    #[test]
    fn le_modele_en_memoire_est_le_schema_reel() {
        let real = Connection::open_in_memory().unwrap();
        migrate(&real).unwrap();
        let model = model().unwrap();

        for table in TABLES {
            assert_eq!(
                columns_of(&model, table.name).unwrap(),
                columns_of(&real, table.name).unwrap(),
                "{} n'a pas la même forme dans le modèle et dans une vraie base",
                table.name
            );
        }
    }

    #[test]
    fn schema_mirrors_base_sql() {
        let conn = Connection::open_in_memory().unwrap();
        migrate(&conn).unwrap();

        let mut stmt = conn
            .prepare("SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name")
            .unwrap();
        let names: Vec<String> = stmt
            .query_map([], |r| r.get(0))
            .unwrap()
            .collect::<Result<_>>()
            .unwrap();
        let found: Vec<&str> = names
            .iter()
            .map(String::as_str)
            .filter(|n| !n.starts_with("sqlite_"))
            .collect();

        assert_eq!(found, EXPECTED_TABLES);
    }

    /// The two columns an earlier version of this file had dropped are back,
    /// and stay back.
    /// A database written by an earlier build — no TypeCategorie, no
    /// ParamSecurite, no IDTypeCategorie, no IDOperation, and the wrong
    /// version number — must come back to the current schema **with its data
    /// intact**, not be rebuilt from scratch.
    #[test]
    fn an_older_database_is_brought_back_to_the_mirror_without_losing_anything() {
        let conn = Connection::open_in_memory().unwrap();
        migrate(&conn).unwrap();

        // Undo today's additions, and put the old version number back.
        conn.execute_batch(
            "DROP TABLE TypeCategorie;
             DROP TABLE ParamSecurite;
             ALTER TABLE Categorie DROP COLUMN IDTypeCategorie;
             ALTER TABLE CalOpPeriodique DROP COLUMN IDOperation;
             INSERT INTO Categorie (IDCategorie, Libelle, IDPosteBudget)
                 VALUES (1, 'À conserver', 3);
             PRAGMA user_version = 1;",
        )
        .unwrap();

        migrate(&conn).unwrap();

        let version: i64 = conn
            .query_row("PRAGMA user_version", [], |r| r.get(0))
            .unwrap();
        assert_eq!(version, CURRENT_SCHEMA_VERSION);

        let (label, budget_line): (String, i64) = conn
            .query_row(
                "SELECT Libelle, IDPosteBudget FROM Categorie WHERE IDCategorie = 1",
                [],
                |r| Ok((r.get(0)?, r.get(1)?)),
            )
            .unwrap();
        assert_eq!((label.as_str(), budget_line), ("À conserver", 3));

        let mut stmt = conn
            .prepare("SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name")
            .unwrap();
        let names: Vec<String> = stmt
            .query_map([], |r| r.get(0))
            .unwrap()
            .collect::<Result<_>>()
            .unwrap();
        let found: Vec<&str> = names
            .iter()
            .map(String::as_str)
            .filter(|n| !n.starts_with("sqlite_"))
            .collect();
        assert_eq!(found, EXPECTED_TABLES);
    }

    /// **De la base 10 à la base 11** (Fabrice, 03/10/2026) : la colonne
    /// `IDVerification` et la table `Verification` arrivent seules, les
    /// opérations déjà là sont « Vérifiée », et rien d'autre n'a bougé.
    #[test]
    fn une_base_10_recoit_la_verification_et_ses_operations_sont_verifiees() {
        let conn = Connection::open_in_memory().unwrap();
        migrate(&conn).unwrap();
        crate::database::seed::seed_initial_data(&conn).unwrap();

        // On refait une base 10 : ni la colonne, ni la table, ni son index.
        conn.execute_batch(
            "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte, IDBanques)
                 VALUES (1, 'CCP', 1, 1);
             INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte,
                                    IDStatutOperation, DatePointage)
                 VALUES (7, 'LOYER', '2026-01-05', -650000000, 1, 1, '2026-01-06');
             DROP INDEX idx_operation_verification;
             ALTER TABLE Operation DROP COLUMN IDVerification;
             DROP TABLE Verification;
             UPDATE Parametres SET VerDataBase = 10 WHERE IDParametres = 1;
             PRAGMA user_version = 10;",
        )
        .unwrap();

        let report = migrate(&conn).unwrap();
        assert!(report.created.contains(&"Verification".to_string()), "{report:?}");
        assert!(report.reseeded.contains(&"Verification".to_string()), "{report:?}");

        let version: i64 = conn
            .query_row("SELECT VerDataBase FROM Parametres WHERE IDParametres = 1", [], |r| r.get(0))
            .unwrap();
        assert_eq!(version, 11);
        assert_eq!(CURRENT_SCHEMA_VERSION, 11);

        let (label, amount, status, clearing, verification): (String, i64, i64, String, i64) = conn
            .query_row(
                "SELECT Libelle, Montant, IDStatutOperation, DatePointage, IDVerification
                   FROM Operation WHERE IDOperation = 7",
                [],
                |r| Ok((r.get(0)?, r.get(1)?, r.get(2)?, r.get(3)?, r.get(4)?)),
            )
            .unwrap();
        assert_eq!(
            (label.as_str(), amount, status, clearing.as_str(), verification),
            ("LOYER", -650000000, 1, "2026-01-06", 2)
        );

        let labels: Vec<String> = conn
            .prepare("SELECT Libelle FROM Verification ORDER BY IDVerification")
            .unwrap()
            .query_map([], |r| r.get(0))
            .unwrap()
            .collect::<Result<_>>()
            .unwrap();
        assert_eq!(labels, ["À vérifier", "Vérifiée", "Douteuse", "Contestée"]);
    }

    #[test]
    fn the_columns_dropped_by_mistake_are_present() {
        let conn = Connection::open_in_memory().unwrap();
        migrate(&conn).unwrap();

        let has_column = |table: &str, column: &str| -> bool {
            let mut stmt = conn
                .prepare(&format!("SELECT COUNT(*) FROM pragma_table_info('{table}') WHERE name = ?1"))
                .unwrap();
            let n: i64 = stmt.query_row([column], |r| r.get(0)).unwrap();
            n == 1
        };

        assert!(has_column("Categorie", "IDTypeCategorie"));
        assert!(has_column("CalOpPeriodique", "IDOperation"));
        assert!(has_column("PiecesJointes", "CheckSumInfo"));
    }
}
