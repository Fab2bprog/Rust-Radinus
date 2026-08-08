//! Prefilled reference data (02_BASE_DE_DONNEES.md §5), inserted once when a
//! brand-new database is created, and again by [`reset_to_blank`] ("remise à
//! zéro", PLAN_ACTION.md 1.2).
//!
//! Table/column identifiers are French, unchanged from the original WinDev
//! schema (see `schema.rs`'s module doc comment — this was corrected
//! 24/07/2026 after an earlier English-named version broke backup
//! compatibility). The *label values* below are the original French
//! nomenclature data, copied verbatim from the dossier.

use rusqlite::{Connection, Result};

const TYPES_COMPTE: &[(i64, &str)] = &[
    (1, "Chèque"),
    (2, "Livret A"),
    (3, "Livret Épargne Populaire (LEP)"),
    (4, "Livret de Développement Durable et Solidaire"),
    (5, "Livret jeune"),
    (6, "Livret épargne"),
    (7, "Compte épargne logement (CEL)"),
    (8, "Plan épargne logement (PEL)"),
    (9, "Plan épargne retraite populaire (PERP)"),
    (10, "Compte à terme (CAT)"),
    (11, "Autres"),
];

/// Liste FERMEE (02_BASE_DE_DONNEES.md §5.2) — jamais modifiable par l'utilisateur.
const STATUTS_OPERATION: &[(i64, &str)] = &[(1, "Pointé"), (2, "Engagé"), (3, "Prévu")];

const AFFECTATIONS: &[(i64, &str)] = &[
    (1, "Monsieur"),
    (2, "Madame"),
    (3, "Enfants"),
    (4, "Famille"),
    (5, "Maison"),
    (6, "Voiture"),
    (7, "Animaux"),
];

const MODES_OPERATION: &[(i64, &str)] = &[
    (1, "Carte bancaire"),
    (2, "Chèque"),
    (3, "Espèces"),
    (4, "Prélèvement"),
    (5, "Remise"),
    (6, "Retrait espèces"),
    (7, "TIP"),
    (8, "Virement"),
];

const POSTES_BUDGET: &[(i64, &str)] = &[
    (1, "Vie de tout les jours"),
    (2, "Assurances"),
    (3, "Divers"),
    (4, "Véhicules"),
    (5, "Habitat"),
    (6, "Finances"),
    (7, "Taxes"),
    (8, "Loisirs"),
    (9, "Revenus"),
    (10, "Santé"),
];

const TIERS: &[(i64, &str)] = &[
    (1, "Aldi"),
    (2, "AliExpress"),
    (3, "Amazon"),
    (4, "Auchan"),
    (5, "Boulanger"),
    (6, "Brico Depot"),
    (7, "BricoMarché"),
    (8, "Carrefour"),
    (9, "Castorama"),
    (10, "Cdiscount"),
    (11, "Décathlon"),
    (12, "E. Leclerc"),
    (13, "Ebay"),
    (14, "Feu vert"),
    (15, "Fnac"),
    (16, "H&M"),
    (17, "IKEA"),
    (18, "Intermarché"),
    (19, "Kiabi"),
    (20, "La Redoute"),
    (21, "LDLC"),
    (22, "LeBonCoin"),
    (23, "Leroy Merlin"),
    (24, "Lidl"),
    (25, "ManoMano"),
    (26, "Materiel.net"),
    (27, "Mr Bricolage"),
    (28, "Netflix"),
    (29, "NordAuto"),
    (30, "Rue du Commerce"),
    (31, "Sarenza"),
    (32, "Shein"),
    (33, "Spartoo"),
    (34, "Speedy"),
    (35, "Système U"),
    (36, "Temu"),
    (37, "TopAchat"),
    (38, "Veepee"),
    (39, "Vinted"),
    (40, "Zalando"),
    (41, "Zara"),
];

const BANQUES: &[(i64, &str)] = &[
    (1, "American Express"),
    (2, "Banque Palatine"),
    (3, "Banque Populaire"),
    (4, "Barclays Banque"),
    (5, "BforBank"),
    (6, "BNP Paribas"),
    (7, "BNPBretagne"),
    (8, "Boursorama Banque"),
    (9, "Caisse Epargne"),
    (10, "CIC"),
    (11, "Credit Agricole"),
    (12, "Crédit Coopératif"),
    (13, "Crédit du Nord"),
    (14, "Crédit Maritime"),
    (15, "Crédit Mutuel"),
    (16, "Fortuneo"),
    (17, "Groupe BPCE"),
    (18, "Hello Bank"),
    (19, "HSBC France"),
    (20, "ING"),
    (21, "La Banque Postale"),
    (22, "LCL"),
    (23, "Milleis"),
    (24, "MonaBanq"),
    (25, "N26"),
    (26, "Orange bank"),
    (27, "Saxo Banque"),
    (28, "Société Générale"),
    (29, "Soon"),
    (30, "Tookam Direct"),
];

/// (IDCategorie, Libelle, IDPosteBudget)
const CATEGORIES: &[(i64, &str, i64)] = &[
    (1, "Alimentation", 1),
    (2, "Assurance", 2),
    (3, "Bricolage", 5),
    (4, "Cadeaux", 3),
    (5, "Coiffeur", 1),
    (6, "Connexion internet", 1),
    (7, "Dépenses personnelles", 3),
    (8, "Divers", 1),
    (9, "Dons", 3),
    (10, "Droguerie", 1),
    (11, "Eau", 5),
    (12, "Électricité ou Gaz", 5),
    (13, "Emprunts", 6),
    (14, "Entretien véhicule", 4),
    (15, "Épargne", 6),
    (16, "Essence", 4),
    (17, "Frais de justice", 3),
    (18, "Frais financiers", 6),
    (19, "Frais postaux", 1),
    (20, "Impôts", 7),
    (21, "Informatique", 3),
    (22, "Intérêts", 6),
    (23, "Jardinage", 5),
    (24, "Livres et journaux", 8),
    (25, "Location véhicule", 4),
    (26, "Logement", 5),
    (27, "Loisirs et spectacles", 8),
    (28, "Meubles", 5),
    (29, "Mutuelle santé", 10),
    (30, "Parking", 1),
    (31, "Péages", 1),
    (32, "Pension alimentaire", 3),
    (33, "Pension invalidité", 9),
    (34, "Pension retraite", 9),
    (35, "Restaurants", 1),
    (36, "Revenus fonciers", 9),
    (37, "Salaire", 9),
    (38, "Santé", 10),
    (39, "Sport", 8),
    (40, "Téléphone", 1),
    (41, "Timbre fiscal", 7),
    (42, "Transports", 1),
    (43, "Vacances", 8),
    (44, "Vétérinaire", 10),
    (45, "Vêtements", 1),
];

/// (IDStatutCheque, Libelle, Description) — descriptions copiees verbatim depuis
/// 02_BASE_DE_DONNEES.md §5.7, y compris leurs propres troncatures (la colonne
/// d'origine est VARCHAR(70)).
/// Copiées **caractère pour caractère** (apostrophes typographiques ’
/// incluses, troncatures à 70 caractères comprises) depuis le contenu réel
/// de `radinus_sauve_statutcheque.json` dans
/// `radinus_sauvegarde_20260723115455545.zip` (audit du 25/07/2026, demande
/// explicite de Fabrice : « toutes les infos doivent correspondre, même si
/// elles semblent superflues, c'est pour se synchroniser avec la
/// sauvegarde ») — et non recopiées depuis le paraphrasage non tronqué du
/// document 02 §5.7 (qui reste, lui, hors du périmètre que je peux modifier
/// sans autorisation).
const STATUTS_CHEQUE: &[(i64, &str, &str)] = &[
    (
        1,
        "Non encore utilisé",
        "Le chèque fait partie du carnet, mais n\u{2019}a pas encore été rempli ni sig",
    ),
    (
        2,
        "Émis",
        "Le chèque a été rédigé et signé, mais pas encore remis ni encaissé",
    ),
    (
        3,
        "Remis à l\u{2019}encaissement",
        "Le chèque a été déposé à la banque du bénéficiaire, en attente de trai",
    ),
    (
        4,
        "En cours d\u{2019}encaissement",
        "Le chèque est en transit entre les banques (délai interbancaire).",
    ),
    (
        5,
        "Payé / Compensé",
        "Le chèque a été effectivement débité du compte de l\u{2019}émetteur et crédit",
    ),
    (
        6,
        "Rejeté / Impayé",
        "Le chèque a été refusé par la banque (fonds insuffisants, compte clos,",
    ),
    (
        7,
        "Opposé",
        "L\u{2019}émetteur a fait opposition (perte, vol, utilisation frauduleuse, pro",
    ),
    (
        8,
        "Annulé / Détruit",
        "Le chèque a été annulé par l\u{2019}émetteur avant émission (par exemple, err",
    ),
    (
        9,
        "Prescrit",
        "Délai légal de présentation expiré (1 an + 8 jours en France). Le chèq",
    ),
    (
        10,
        "Perdu / Volé",
        "Le chèque a disparu avant encaissement, mais aucune opposition encore ",
    ),
    (
        11,
        "En litige",
        "Chèque faisant l\u{2019}objet d\u{2019}une contestation (montant, falsification, bén",
    ),
    (
        12,
        "Duplicata émis",
        "Un nouveau chèque a été émis pour remplacer l\u{2019}original perdu, annulé o",
    ),
    (
        13,
        "Restitué",
        "Le chèque a été rendu à l\u{2019}émetteur sans être encaissé.",
    ),
    (
        14,
        "Inconnu",
        "Le statut du chèque ne peut pas être déterminé (erreur de saisie, impo",
    ),
    (15, "Autre", "Voir éventuellement commentaires"),
];

fn insert_pairs(
    conn: &Connection,
    table: &str,
    id_col: &str,
    label_col: &str,
    rows: &[(i64, &str)],
) -> Result<()> {
    let sql = format!("INSERT INTO {table} ({id_col}, {label_col}) VALUES (?1, ?2)");
    let mut stmt = conn.prepare(&sql)?;
    for (id, label) in rows {
        stmt.execute((id, label))?;
    }
    Ok(())
}

fn insert_categories(conn: &Connection) -> Result<()> {
    let mut stmt =
        conn.prepare("INSERT INTO Categorie (IDCategorie, Libelle, IDPosteBudget) VALUES (?1, ?2, ?3)")?;
    for (id, label, id_poste_budget) in CATEGORIES {
        stmt.execute((id, label, id_poste_budget))?;
    }
    Ok(())
}

/// Les onze types de compte.
///
/// Publique pour la même raison que les deux suivantes : c'est une liste
/// fermée, remplie par le code et jamais complétée par l'utilisateur
/// (`accounts::account_types`, 02_BASE_DE_DONNEES.md §3.1 `Init_TypeCompte`).
/// Vidée par accident, elle rend la fiche compte insaisissable — la procédure
/// d'ouverture (`schema::ensure_the_tables`) la rétablit.
pub fn seed_types_compte(conn: &Connection) -> Result<()> {
    insert_pairs(conn, "TypeCompte", "IDTypeCompte", "Libelle", TYPES_COMPTE)
}

/// Les trois statuts d'opération — Pointé, Engagé, Prévu — et rien d'autre.
///
/// Publique parce que la **réparation** (phase 17) doit pouvoir les rétablir :
/// une table de statuts vidée par accident rend toute saisie impossible, et
/// l'original en fait autant dans son `Reparation_Base`.
pub fn seed_statuts_operation(conn: &Connection) -> Result<()> {
    insert_pairs(
        conn,
        "StatutOperation",
        "IDStatutOperation",
        "Libelle",
        STATUTS_OPERATION,
    )
}

/// Les quinze statuts de chèque. Publique pour la même raison.
pub fn seed_statuts_cheque(conn: &Connection) -> Result<()> {
    insert_statuts_cheque(conn)
}

fn insert_statuts_cheque(conn: &Connection) -> Result<()> {
    let mut stmt = conn.prepare(
        "INSERT INTO StatutCheque (IDStatutCheque, Libelle, Description) VALUES (?1, ?2, ?3)",
    )?;
    for (id, label, description) in STATUTS_CHEQUE {
        stmt.execute((id, label, description))?;
    }
    Ok(())
}

/// Inserts every prefilled nomenclature row plus the single `Parametres`
/// row, into a database whose schema has already been created (via
/// `schema::migrate`) and which is currently empty. Called once at database
/// creation time — never on ordinary open, so it never collides with rows a
/// user has since edited or added (02_BASE_DE_DONNEES.md §2 "Contenu initial
/// au premier lancement").
pub fn seed_initial_data(conn: &Connection) -> Result<()> {
    seed_types_compte(conn)?;
    seed_statuts_operation(conn)?;
    insert_pairs(conn, "Affectation", "IDAffectation", "Libelle", AFFECTATIONS)?;
    insert_pairs(
        conn,
        "ModeOperation",
        "IDModeOperation",
        "Libelle",
        MODES_OPERATION,
    )?;
    insert_pairs(conn, "PosteBudget", "IDPosteBudget", "Libelle", POSTES_BUDGET)?;
    insert_pairs(conn, "Tiers", "IDTiers", "Libelle", TIERS)?;
    insert_pairs(conn, "Banques", "IDBanques", "NomBanque", BANQUES)?;
    insert_categories(conn)?;
    insert_statuts_cheque(conn)?;

    // The single Parametres row. The two version numbers mean different
    // things (author's ruling, 25/07/2026): VerSoftMajeur/Mineur/Debug =
    // 2/0/0 is the *software* version (Radinus 2.0.0), while VerDataBase is
    // the *database* version, continuing the same number line Radinus 1.x
    // walked from 0 to 9 — hence CURRENT_SCHEMA_VERSION, which is 9.
    conn.execute(
        "INSERT INTO Parametres \
         (IDParametres, RunOnce, InitValDefaut, VerSoftMajeur, \
          VerSoftMineur, VerSoftDebug, VerDataBase, UtiliseLangue) \
         VALUES (1, 1, 1, 2, 0, 0, ?1, 5)",
        [super::schema::CURRENT_SCHEMA_VERSION],
    )?;

    Ok(())
}

/// "Remise à zéro" (PLAN_ACTION.md 1.2): wipes every row from every table,
/// then reseeds the same prefilled state a fresh database starts with.
/// Equivalent to WinDev's "Tout supprimer !" function.
pub fn reset_to_blank(conn: &Connection) -> Result<()> {
    conn.execute_batch(
        r#"
        PRAGMA foreign_keys = OFF;
        DELETE FROM PiecesJointes;
        DELETE FROM Commentaire;
        DELETE FROM Operation;
        DELETE FROM Cheque;
        DELETE FROM Chequier;
        DELETE FROM CalOpPeriodique;
        DELETE FROM ModeleOperation;
        DELETE FROM Budget;
        DELETE FROM Compte;
        DELETE FROM Categorie;
        DELETE FROM StatutCheque;
        DELETE FROM Banques;
        DELETE FROM Tiers;
        DELETE FROM PosteBudget;
        DELETE FROM ModeOperation;
        DELETE FROM Affectation;
        DELETE FROM StatutOperation;
        DELETE FROM TypeCompte;
        DELETE FROM TypeCategorie;
        DELETE FROM ParamSecurite;
        DELETE FROM Projets;
        DELETE FROM Preferences;
        DELETE FROM Parametres;
        PRAGMA foreign_keys = ON;
        "#,
    )?;
    seed_initial_data(conn)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database::schema::migrate;

    fn seeded_conn() -> Connection {
        let conn = Connection::open_in_memory().unwrap();
        migrate(&conn).unwrap();
        seed_initial_data(&conn).unwrap();
        conn
    }

    fn count(conn: &Connection, table: &str) -> i64 {
        conn.query_row(&format!("SELECT COUNT(*) FROM {table}"), [], |r| r.get(0))
            .unwrap()
    }

    #[test]
    fn seeds_expected_row_counts() {
        let conn = seeded_conn();
        assert_eq!(count(&conn, "TypeCompte"), 11);
        assert_eq!(count(&conn, "StatutOperation"), 3);
        assert_eq!(count(&conn, "Affectation"), 7);
        assert_eq!(count(&conn, "ModeOperation"), 8);
        assert_eq!(count(&conn, "PosteBudget"), 10);
        assert_eq!(count(&conn, "Tiers"), 41);
        assert_eq!(count(&conn, "Banques"), 30);
        assert_eq!(count(&conn, "Categorie"), 45);
        assert_eq!(count(&conn, "StatutCheque"), 15);
        assert_eq!(count(&conn, "Parametres"), 1);
    }

    #[test]
    fn seed_categories_reference_valid_budget_lines() {
        let conn = seeded_conn();
        let orphaned: i64 = conn
            .query_row(
                "SELECT COUNT(*) FROM Categorie c \
                 WHERE c.IDPosteBudget != 0 \
                 AND NOT EXISTS (SELECT 1 FROM PosteBudget p WHERE p.IDPosteBudget = c.IDPosteBudget)",
                [],
                |r| r.get(0),
            )
            .unwrap();
        assert_eq!(orphaned, 0);
    }

    #[test]
    fn reset_to_blank_wipes_user_data_and_restores_nomenclatures() {
        let conn = seeded_conn();
        conn.execute("INSERT INTO Compte (IDCompte, Libelle) VALUES (1, 'CCP')", [])
            .unwrap();
        conn.execute(
            "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte, IDStatutOperation) \
             VALUES (1, 'Test', '2026-01-01', 1000000, 1, 1)",
            [],
        )
        .unwrap();

        reset_to_blank(&conn).unwrap();

        assert_eq!(count(&conn, "Compte"), 0);
        assert_eq!(count(&conn, "Operation"), 0);
        assert_eq!(count(&conn, "Banques"), 30);
        assert_eq!(count(&conn, "Categorie"), 45);
        assert_eq!(count(&conn, "Parametres"), 1);
    }

    #[test]
    fn parametres_row_reflects_current_schema_version() {
        let conn = seeded_conn();
        let version: i64 = conn
            .query_row(
                "SELECT VerDataBase FROM Parametres WHERE IDParametres = 1",
                [],
                |r| r.get(0),
            )
            .unwrap();
        assert_eq!(version, super::super::schema::CURRENT_SCHEMA_VERSION);
    }
}
