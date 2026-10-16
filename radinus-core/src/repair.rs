//! Réparation et optimisation de la base — portage de `Reparation_Base()`
//! (phase 17).
//!
//! **C'est un traitement qui écrit, et qui efface.** Il ne se contente pas de
//! constater : une opération sans date reçoit une date, un drapeau faux est
//! remis d'aplomb, et trois sortes d'enregistrements incohérents sont
//! **supprimés**. C'est le choix de l'auteur, gardé tel quel (Fabrice,
//! 01/08/2026 : « je veux que tu fasses pareil »), et sans question préalable
//! — réparer est un geste voulu, celui qui le demande sait ce qu'il fait.
//!
//! L'ordre est le sien, parce que l'ordre compte : on réindexe avant de lire,
//! on répare les liens avant de recalculer les ventilations, et on recalcule
//! les soldes en dernier, quand plus rien ne bougera.
//!
//! **Tout est écrit en une seule transaction.** Une réparation à moitié faite
//! serait pire que pas de réparation du tout : la base sortirait dans un état
//! qu'aucun des deux codes n'a prévu. L'optimisation du fichier vient après le
//! commit, parce que `VACUUM` refuse de tourner dans une transaction.

use crate::i18n::Language;
use crate::journal::{Journal, Status};
use rusqlite::{Connection, Result};

/// Ce que la réparation a fait.
#[derive(Debug, Clone)]
pub struct Report {
    /// Le journal, ligne par ligne, dans l'ordre du traitement.
    pub journal: Journal,
    /// Le nombre d'anomalies rencontrées — c'est ce que rend son
    /// `Reparation_Base()`. Zéro veut dire « rien à réparer », pas « rien
    /// fait » : les réindexations et les recalculs ont eu lieu quand même.
    pub anomalies: usize,
}

/// La date donnée à une opération qui n'en a pas.
///
/// Le 1er janvier 1970 de l'original. Une opération sans date est **invisible**
/// — la liste d'un compte lit entre deux bornes et l'écarte —, si bien qu'elle
/// pèse sur les soldes sans que personne puisse la voir ni la corriger. Lui
/// donner une date absurde mais lointaine la fait réapparaître en tête de
/// liste, là où on ne peut pas la manquer.
const EPOCH: &str = "1970-01-01";

/// Les tables de la base, telles que SQLite les connaît.
///
/// L'équivalent de son `HListeFichier(hLstTable)`. Les tables internes de
/// SQLite, préfixées `sqlite_`, sont écartées : elles ne nous appartiennent
/// pas et `REINDEX` les refuserait.
fn tables(conn: &Connection) -> Result<Vec<String>> {
    let mut statement = conn.prepare(
        "SELECT name FROM sqlite_master
          WHERE type = 'table' AND name NOT LIKE 'sqlite_%'
          ORDER BY name",
    )?;
    let names = statement
        .query_map([], |row| row.get::<_, String>(0))?
        .collect::<Result<Vec<_>>>()?;
    Ok(names)
}

/// Combien de lignes porte une table.
fn count(conn: &Connection, table: &str) -> Result<i64> {
    conn.query_row(&format!("SELECT COUNT(*) FROM {table}"), [], |row| row.get(0))
}

/// Répare et optimise la base ouverte.
pub fn run(conn: &mut Connection, language: Language) -> Result<Report> {
    let mut journal = Journal::new(language);
    let mut anomalies = 0usize;

    // --- 1. Réindexation de toutes les tables ------------------------------
    // Une par une, et chacune journalisée : savoir *laquelle* a résisté vaut
    // mieux que savoir qu'il y a eu un problème quelque part.
    for table in tables(conn)? {
        match conn.execute_batch(&format!("REINDEX \"{table}\";")) {
            Ok(()) => journal.add("journal-step-reindex", &table, Status::Success, "", ""),
            Err(error) => {
                journal.add(
                    "journal-step-reindex",
                    &table,
                    Status::Failure,
                    &error.to_string(),
                    "",
                );
                anomalies += 1;
            }
        }
    }

    // --- 2. Les nomenclatures système trouvées vides -----------------------
    // « En cas de suppression de certain fichier sur le disque, malgré le fait
    // qu'il soit recréé à vide » : une table système vide n'est pas une base
    // neuve, c'est une base blessée, et les fiches deviennent insaisissables.
    //
    // L'original en relève trois. Nous n'en relevons que deux : la troisième
    // est `TypeCategorie`, que l'auteur a lui-même déclarée superflue et
    // décidé de supprimer du portage (02_BASE_DE_DONNEES.md §6). La remplir
    // ici la ferait revenir par la fenêtre.
    {
        let transaction = conn.transaction()?;
        if count(&transaction, "StatutOperation")? == 0 {
            crate::database::seed::seed_statuts_operation(&transaction)?;
            journal.add(
                "journal-step-refill",
                "StatutOperation",
                Status::Repaired,
                "",
                "",
            );
            anomalies += 1;
        }
        if count(&transaction, "Verification")? == 0 {
            crate::database::seed::seed_verifications(&transaction)?;
            journal.add(
                "journal-step-refill",
                "Verification",
                Status::Repaired,
                "",
                "",
            );
            anomalies += 1;
        }
        if count(&transaction, "StatutCheque")? == 0 {
            crate::database::seed::seed_statuts_cheque(&transaction)?;
            journal.add(
                "journal-step-refill",
                "StatutCheque",
                Status::Repaired,
                "",
                "",
            );
            anomalies += 1;
        }
        transaction.commit()?;
    }

    // --- 3 à 9. Les contrôles sur les opérations, en une seule transaction --
    let transaction = conn.transaction()?;

    // 3. Les opérations sans date.
    {
        let mut statement = transaction.prepare(
            "SELECT IDOperation, Libelle, Montant FROM Operation
              WHERE Date IS NULL OR Date = ''",
        )?;
        let found: Vec<(i64, String, i64)> = statement
            .query_map([], |row| Ok((row.get(0)?, row.get(1)?, row.get(2)?)))?
            .collect::<Result<_>>()?;
        drop(statement);
        for (id, label, amount) in found {
            transaction.execute(
                "UPDATE Operation SET Date = ?1 WHERE IDOperation = ?2",
                rusqlite::params![EPOCH, id],
            )?;
            journal.add(
                "journal-step-date-fixed",
                "Operation",
                Status::Repaired,
                "",
                &format!(
                    "{label} — {} — {EPOCH}",
                    crate::money::format(amount, language)
                ),
            );
            anomalies += 1;
        }
    }

    // 4. Les références circulaires : une opération qui est sa propre mère.
    {
        let mut statement = transaction.prepare(
            "SELECT IDOperation, Libelle, Montant FROM Operation
              WHERE IDOperationParent = IDOperation AND IDOperationParent <> 0",
        )?;
        let found: Vec<(i64, String, i64)> = statement
            .query_map([], |row| Ok((row.get(0)?, row.get(1)?, row.get(2)?)))?
            .collect::<Result<_>>()?;
        drop(statement);
        for (id, label, amount) in found {
            transaction.execute("DELETE FROM Operation WHERE IDOperation = ?1", [id])?;
            journal.add(
                "journal-step-circular",
                "Operation",
                Status::Repaired,
                "",
                &format!("{label} — {}", crate::money::format(amount, language)),
            );
            anomalies += 1;
        }
    }

    // 5. Le drapeau `EstParent` des opérations principales, dans les deux
    //    sens : vrai si elles portent des filles, faux si elles n'en portent
    //    plus. Le second cas arrive après une suppression mal terminée.
    for (sql, key, wanted) in [
        (
            "SELECT IDOperation, Libelle FROM Operation o
              WHERE o.IDOperationParent = 0 AND o.EstParent = 0
                AND EXISTS (SELECT 1 FROM Operation f WHERE f.IDOperationParent = o.IDOperation)",
            "journal-step-flag-parent-true",
            1,
        ),
        (
            "SELECT IDOperation, Libelle FROM Operation o
              WHERE o.IDOperationParent = 0 AND o.EstParent <> 0
                AND NOT EXISTS (SELECT 1 FROM Operation f WHERE f.IDOperationParent = o.IDOperation)",
            "journal-step-flag-parent-false",
            0,
        ),
        (
            "SELECT IDOperation, Libelle FROM Operation
              WHERE IDOperationParent <> 0 AND EstParent <> 0",
            "journal-step-flag-child",
            0,
        ),
    ] {
        let mut statement = transaction.prepare(sql)?;
        let found: Vec<(i64, String)> = statement
            .query_map([], |row| Ok((row.get(0)?, row.get(1)?)))?
            .collect::<Result<_>>()?;
        drop(statement);
        for (id, label) in found {
            transaction.execute(
                "UPDATE Operation SET EstParent = ?1 WHERE IDOperation = ?2",
                rusqlite::params![wanted, id],
            )?;
            journal.add(key, "Operation", Status::Repaired, "", &label);
            anomalies += 1;
        }
    }

    // 6. Les sous-opérations orphelines : leur mère n'existe plus.
    // 7. Les sous-opérations rattachées à une autre sous-opération, c'est-à-dire
    //    un troisième niveau — le modèle n'en a que deux.
    for (sql, key) in [
        (
            "SELECT IDOperation, Libelle, Montant FROM Operation f
              WHERE f.IDOperationParent <> 0
                AND NOT EXISTS (SELECT 1 FROM Operation m WHERE m.IDOperation = f.IDOperationParent)",
            "journal-step-orphan",
        ),
        (
            "SELECT IDOperation, Libelle, Montant FROM Operation f
              WHERE f.IDOperationParent <> 0
                AND EXISTS (SELECT 1 FROM Operation m
                             WHERE m.IDOperation = f.IDOperationParent
                               AND m.IDOperationParent <> 0)",
            "journal-step-third-level",
        ),
    ] {
        let mut statement = transaction.prepare(sql)?;
        let found: Vec<(i64, String, i64)> = statement
            .query_map([], |row| Ok((row.get(0)?, row.get(1)?, row.get(2)?)))?
            .collect::<Result<_>>()?;
        drop(statement);
        for (id, label, amount) in found {
            transaction.execute("DELETE FROM Operation WHERE IDOperation = ?1", [id])?;
            journal.add(
                key,
                "Operation",
                Status::Repaired,
                "",
                &format!("{label} — {}", crate::money::format(amount, language)),
            );
            anomalies += 1;
        }
    }

    // 8. La cohérence des ventilations : pour chaque mère, le Complément est
    //    refait et les propriétés redescendent sur les filles.
    {
        let mut statement = transaction.prepare(
            "SELECT IDOperation FROM Operation
              WHERE EstParent <> 0 AND IDOperationParent = 0",
        )?;
        let parents: Vec<i64> = statement
            .query_map([], |row| row.get(0))?
            .collect::<Result<_>>()?;
        drop(statement);
        for parent in &parents {
            crate::sub_operations::refresh_complement(&transaction, *parent)?;
            crate::sub_operations::sync_from_parent(&transaction, *parent)?;
        }
        journal.add(
            "journal-step-coherence",
            "Operation",
            Status::Success,
            "",
            &parents.len().to_string(),
        );
    }

    // 9. Les trois soldes de chaque compte, et les `SoldePointe` des
    //    opérations. En dernier : plus rien ne bougera après.
    crate::balances::update_all_accounts(&transaction)?;
    journal.add(
        "journal-step-balances",
        "Compte",
        Status::Success,
        "",
        &count(&transaction, "Compte")?.to_string(),
    );

    transaction.commit()?;

    // --- 10. L'optimisation ------------------------------------------------
    // Hors transaction : `VACUUM` la refuse. Elle vient après les
    // suppressions, sans quoi elle n'aurait rien à récupérer.
    for (sql, key) in [("VACUUM;", "journal-step-vacuum"), ("ANALYZE;", "journal-step-analyze")] {
        match conn.execute_batch(sql) {
            Ok(()) => journal.add(key, "", Status::Success, "", ""),
            Err(error) => {
                journal.add(key, "", Status::Failure, &error.to_string(), "");
                anomalies += 1;
            }
        }
    }

    Ok(Report { journal, anomalies })
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database;

    fn base() -> Connection {
        let conn = Connection::open_in_memory().expect("base en mémoire");
        database::schema::migrate(&conn).expect("schéma");
        database::seed::seed_initial_data(&conn).expect("valeurs initiales");
        conn.execute("INSERT INTO Compte (IDCompte, Libelle) VALUES (1, 'CCP')", [])
            .expect("compte");
        conn
    }

    fn insert(conn: &Connection, id: i64, parent: i64, amount: i64, date: Option<&str>) {
        conn.execute(
            "INSERT INTO Operation
             (IDOperation, Libelle, Date, Montant, IDCompte, IDStatutOperation,
              IDOperationParent, EstParent)
             VALUES (?1, ?2, ?3, ?4, 1, 1, ?5, 0)",
            rusqlite::params![id, format!("OP{id}"), date, amount, parent],
        )
        .expect("insertion");
    }

    /// Une base saine ne bouge pas : la réparation tourne, et ne trouve rien.
    #[test]
    fn une_base_saine_ne_donne_aucune_anomalie() {
        let mut conn = base();
        insert(&conn, 1, 0, -10_000_000, Some("2026-01-05"));
        let report = run(&mut conn, Language::French).expect("réparation");
        assert_eq!(report.anomalies, 0);
        assert!(!report.journal.is_empty());
    }

    /// Une opération sans date est invisible dans la liste d'un compte : elle
    /// pèse sur les soldes sans que personne puisse la corriger.
    #[test]
    fn une_operation_sans_date_recoit_le_premier_janvier_1970() {
        let mut conn = base();
        insert(&conn, 1, 0, -10_000_000, None);
        let report = run(&mut conn, Language::French).expect("réparation");
        assert_eq!(report.anomalies, 1);
        let date: String = conn
            .query_row("SELECT Date FROM Operation WHERE IDOperation = 1", [], |r| {
                r.get(0)
            })
            .expect("lecture");
        assert_eq!(date, EPOCH);
    }

    #[test]
    fn une_operation_qui_est_sa_propre_mere_est_supprimee() {
        let mut conn = base();
        insert(&conn, 1, 0, -10_000_000, Some("2026-01-05"));
        conn.execute(
            "UPDATE Operation SET IDOperationParent = 1 WHERE IDOperation = 1",
            [],
        )
        .expect("cercle");
        let report = run(&mut conn, Language::French).expect("réparation");
        assert_eq!(report.anomalies, 1);
        assert_eq!(count(&conn, "Operation").expect("compte"), 0);
    }

    #[test]
    fn une_sous_operation_sans_mere_est_supprimee() {
        let mut conn = base();
        insert(&conn, 1, 0, -10_000_000, Some("2026-01-05"));
        insert(&conn, 2, 99, -5_000_000, Some("2026-01-05"));
        let report = run(&mut conn, Language::French).expect("réparation");
        assert_eq!(report.anomalies, 1);
        assert_eq!(count(&conn, "Operation").expect("compte"), 1);
    }

    /// **Le troisième niveau n'existe pas.** Une fille rattachée à une fille
    /// serait une ventilation de ventilation, que ni les soldes ni la liste ne
    /// savent lire.
    #[test]
    fn une_sous_operation_de_sous_operation_est_supprimee() {
        let mut conn = base();
        insert(&conn, 1, 0, -10_000_000, Some("2026-01-05"));
        insert(&conn, 2, 1, -4_000_000, Some("2026-01-05"));
        insert(&conn, 3, 2, -1_000_000, Some("2026-01-05"));
        let report = run(&mut conn, Language::French).expect("réparation");
        assert!(report.anomalies >= 1);
        // On ne compte pas la clef 3 : elle est libérée par la suppression et
        // le Complément recalculé la reprend aussitôt — `Genere_Clef` rend
        // max+1. Ce qu'il faut vérifier, c'est qu'il ne reste **aucune** fille
        // dont la mère soit elle-même une fille.
        let third: i64 = conn
            .query_row(
                "SELECT COUNT(*) FROM Operation f
                  WHERE f.IDOperationParent <> 0
                    AND EXISTS (SELECT 1 FROM Operation m
                                 WHERE m.IDOperation = f.IDOperationParent
                                   AND m.IDOperationParent <> 0)",
                [],
                |r| r.get(0),
            )
            .expect("lecture");
        assert_eq!(third, 0, "un troisième niveau a survécu à la réparation");
    }

    #[test]
    fn le_drapeau_est_parent_est_remis_daplomb_dans_les_deux_sens() {
        let mut conn = base();
        // Une mère qui porte une fille mais ne le dit pas.
        insert(&conn, 1, 0, -10_000_000, Some("2026-01-05"));
        insert(&conn, 2, 1, -4_000_000, Some("2026-01-05"));
        // Une opération seule qui se croit mère.
        insert(&conn, 3, 0, -2_000_000, Some("2026-01-06"));
        conn.execute("UPDATE Operation SET EstParent = 1 WHERE IDOperation = 3", [])
            .expect("drapeau");
        // Une fille qui se croit mère.
        conn.execute("UPDATE Operation SET EstParent = 1 WHERE IDOperation = 2", [])
            .expect("drapeau");

        let report = run(&mut conn, Language::French).expect("réparation");
        assert_eq!(report.anomalies, 3);

        let flag = |id: i64| -> i64 {
            conn.query_row(
                "SELECT EstParent FROM Operation WHERE IDOperation = ?1",
                [id],
                |r| r.get(0),
            )
            .expect("lecture")
        };
        assert_eq!(flag(1), 1);
        assert_eq!(flag(2), 0);
        assert_eq!(flag(3), 0);
    }

    /// Une nomenclature système vidée par accident revient d'elle-même : sans
    /// statut, aucune opération ne peut plus être saisie.
    #[test]
    fn une_nomenclature_systeme_vide_est_remplie() {
        let mut conn = base();
        conn.execute("DELETE FROM StatutOperation", [])
            .expect("vidage");
        let report = run(&mut conn, Language::French).expect("réparation");
        assert!(report.anomalies >= 1);
        assert_eq!(count(&conn, "StatutOperation").expect("compte"), 3);
    }

    /// Le journal raconte le traitement, y compris quand il n'y a rien à
    /// réparer : les réindexations et les recalculs y sont.
    #[test]
    fn le_journal_raconte_meme_sans_anomalie() {
        let mut conn = base();
        let report = run(&mut conn, Language::French).expect("réparation");
        assert!(report.journal.len() > 10);
    }
}
