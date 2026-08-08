//! The three account balances, and the per-operation running balance.
//!
//! Dossier reference: `02_BASE_DE_DONNEES.md` §8-9, `PLAN_ACTION.md` Phase 2.1.
//! **Ported from the author's own WinDev source** (`POINT 26
//! Maj_SoldeBanque(LOCAL IDCompte.txt`: `Maj_SoldeBanque`, `Maj_SoldeReel`,
//! `Maj_SoldeFinal`), which is the authority here — the three functions below
//! reproduce it statement by statement, including the parts the dossier's
//! prose glosses over:
//!
//! - **`SoldePointe` is written on every top-level operation of the account,
//!   whatever its status.** The running total only moves on status 1
//!   (*pointée*), but the value is stamped on each row regardless: in the
//!   original, the assignment sits outside the status test and inside the
//!   "no parent" test.
//! - **`Maj_SoldeFinal` filters on no status at all** — every top-level
//!   operation counts, which is what makes it the *final* balance.
//! - **Sub-operations never count**, in any of the three. The original tests
//!   `Operation.IDOperationParent = Null`; this port stores `0` for "no
//!   parent" (02_BASE_DE_DONNEES.md §7 rule 2), so the test becomes `= 0`.
//! - Only `Maj_SoldeBanque` writes `SoldePointe`; the other two touch nothing
//!   but the account's own total.
//! - The three are always run in this order after a change, and that order is
//!   [`update_all`].
//!
//! **Row order and its one known limit.** The original walks the operations
//! through the `DatePointage` index, so the running balance follows clearing
//! date. Where several operations share a clearing date, HFSQL falls back on
//! the physical record order inside its own file, which no longer exists once
//! the data is in SQLite; ties are settled by `IDOperation` here. Measured on
//! the author's real database: the four account totals come out **exactly**
//! right (1 549,81 / 23 422,81 / 8 228,30 / 11 348,89 €), and 2 474 of the
//! 2 502 `SoldePointe` values match Windows to the cent. The 28 that differ
//! are all inside a same-date tie — a different order through the same set of
//! amounts, reaching the same total. `tests/balances.rs` asserts exactly that,
//! rather than tolerating a magic number.
//!
//! Amounts are `i64` micro-units (see `database::schema`), so the additions
//! here are exact integer arithmetic: no floating-point drift can creep into a
//! balance, whatever the number of operations.

use rusqlite::Connection;

/// `IDStatutOperation` of a *pointée* operation (02_BASE_DE_DONNEES.md §5.2).
const STATUS_POINTED: i64 = 1;
/// `IDStatutOperation` of an *engagée* operation.
const STATUS_COMMITTED: i64 = 2;

/// The three balances of an account, in micro-units.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Balances {
    pub bank: i64,
    pub real: i64,
    /// `final` is a Rust keyword, hence the trailing underscore.
    pub final_: i64,
}

/// `Maj_SoldeBanque`: the bank balance — carried-over pointed amount plus
/// every *pointée* top-level operation — and, along the way, the running
/// balance stamped on each top-level operation (`Operation.SoldePointe`).
pub fn update_bank_balance(conn: &Connection, account_id: i64) -> rusqlite::Result<i64> {
    // The original returns Faux when the account does not exist.
    let Some(mut running) = carried_over(conn, account_id, &["ReportPointe"])? else {
        return Ok(0);
    };

    // Same walk as the original: the DatePointage index, sub-operations
    // excluded. NULL clearing dates sort first, as they do in HFSQL.
    let mut operations = Vec::new();
    {
        let mut stmt = conn.prepare(
            "SELECT IDOperation, Montant, IDStatutOperation
             FROM Operation
             WHERE IDCompte = ?1 AND IDOperationParent = 0
             ORDER BY DatePointage, IDOperation",
        )?;
        let mapped = stmt.query_map([account_id], |row| {
            Ok((
                row.get::<_, i64>(0)?,
                row.get::<_, i64>(1)?,
                row.get::<_, i64>(2)?,
            ))
        })?;
        for row in mapped {
            operations.push(row?);
        }
    }

    {
        let mut update =
            conn.prepare("UPDATE Operation SET SoldePointe = ?1 WHERE IDOperation = ?2")?;
        for (operation_id, amount, status) in operations {
            if status == STATUS_POINTED {
                running += amount;
            }
            // Stamped on every top-level operation, pointed or not.
            update.execute([running, operation_id])?;
        }
    }

    conn.execute(
        "UPDATE Compte SET SoldeBanque = ?1 WHERE IDCompte = ?2",
        [running, account_id],
    )?;
    Ok(running)
}

/// `Maj_SoldeReel`: the real balance — the pointed and committed carry-overs,
/// plus every top-level operation that is *pointée* or *engagée*.
pub fn update_real_balance(conn: &Connection, account_id: i64) -> rusqlite::Result<i64> {
    let Some(carried) = carried_over(conn, account_id, &["ReportPointe", "ReportEngage"])? else {
        return Ok(0);
    };

    let total: i64 = conn.query_row(
        "SELECT COALESCE(SUM(Montant), 0)
         FROM Operation
         WHERE IDCompte = ?1 AND IDOperationParent = 0
           AND IDStatutOperation IN (?2, ?3)",
        [account_id, STATUS_POINTED, STATUS_COMMITTED],
        |row| row.get(0),
    )?;

    let balance = carried + total;
    conn.execute(
        "UPDATE Compte SET SoldeReel = ?1 WHERE IDCompte = ?2",
        [balance, account_id],
    )?;
    Ok(balance)
}

/// `Maj_SoldeFinal`: the final balance — the three carry-overs plus every
/// top-level operation, with **no status filter whatsoever**.
pub fn update_final_balance(conn: &Connection, account_id: i64) -> rusqlite::Result<i64> {
    let Some(carried) = carried_over(
        conn,
        account_id,
        &["ReportPointe", "ReportEngage", "ReportPrevu"],
    )?
    else {
        return Ok(0);
    };

    let total: i64 = conn.query_row(
        "SELECT COALESCE(SUM(Montant), 0)
         FROM Operation
         WHERE IDCompte = ?1 AND IDOperationParent = 0",
        [account_id],
        |row| row.get(0),
    )?;

    let balance = carried + total;
    conn.execute(
        "UPDATE Compte SET SoldeFinal = ?1 WHERE IDCompte = ?2",
        [balance, account_id],
    )?;
    Ok(balance)
}

/// The three balances of one account, recomputed in the order the original
/// always calls them in (`Maj_SoldeBanque`, then `Maj_SoldeReel`, then
/// `Maj_SoldeFinal`). This is what every operation-changing action calls.
pub fn update_all(conn: &Connection, account_id: i64) -> rusqlite::Result<Balances> {
    Ok(Balances {
        bank: update_bank_balance(conn, account_id)?,
        real: update_real_balance(conn, account_id)?,
        final_: update_final_balance(conn, account_id)?,
    })
}

/// The three balances of every account. For a wholesale change — a repair, or
/// an import that touched several accounts at once.
pub fn update_all_accounts(conn: &Connection) -> rusqlite::Result<()> {
    let mut ids = Vec::new();
    {
        let mut stmt = conn.prepare("SELECT IDCompte FROM Compte ORDER BY IDCompte")?;
        let mapped = stmt.query_map([], |row| row.get::<_, i64>(0))?;
        for id in mapped {
            ids.push(id?);
        }
    }
    // **Une transaction pour tous les comptes** (dossier de portage du
    // 05/08/2026, §4.2). `update_all` pose trois `UPDATE` par compte ; hors
    // transaction, chacun est validé seul et paie son écriture disque. Six
    // comptes faisaient dix-huit validations pour la suppression d'une seule
    // opération. Elles n'en font plus qu'une.
    //
    // `unchecked_transaction` parce que cette fonction reçoit `&Connection` et
    // non `&mut` : elle ne peut pas ouvrir une transaction ordinaire. Le
    // schéma emploie déjà la même porte, pour la même raison.
    //
    // ⚠ **Et rien ne le vérifie à la compilation.** Le dossier Windows
    // affirmait qu'aucun appelant n'ouvrait de transaction ; c'était vrai de
    // la 2.0.0, et faux ici — `repair::run` en ouvre une et appelle ceci
    // dedans. SQLite l'a dit tout net : « cannot start a transaction within a
    // transaction », huit tests de réparation d'un coup.
    //
    // D'où la question posée au lieu d'être supposée. `is_autocommit` rend
    // faux dès qu'une transaction est ouverte sur cette connexion : dans ce
    // cas on écrit dans celle de l'appelant, qui la validera, et le
    // groupement est acquis quand même. **Une transaction imbriquée n'a pas
    // d'intérêt ici** — ce qu'on cherche est une seule validation, et
    // l'appelant en promet déjà une.
    let own = if conn.is_autocommit() {
        Some(conn.unchecked_transaction()?)
    } else {
        None
    };
    for id in ids {
        update_all(conn, id)?;
    }
    if let Some(transaction) = own {
        transaction.commit()?;
    }
    Ok(())
}

/// Sum of the requested carry-over columns of an account, or `None` when the
/// account does not exist (the original's `RENVOYER Faux` case).
fn carried_over(
    conn: &Connection,
    account_id: i64,
    columns: &[&str],
) -> rusqlite::Result<Option<i64>> {
    let sum = columns.join(" + ");
    match conn.query_row(
        &format!("SELECT {sum} FROM Compte WHERE IDCompte = ?1"),
        [account_id],
        |row| row.get(0),
    ) {
        Ok(value) => Ok(Some(value)),
        Err(rusqlite::Error::QueryReturnedNoRows) => Ok(None),
        Err(other) => Err(other),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database::{schema, seed};

    /// One euro, in the micro-units the schema stores.
    const EURO: i64 = 1_000_000;

    fn database() -> Connection {
        let conn = Connection::open_in_memory().unwrap();
        schema::migrate(&conn).unwrap();
        seed::seed_initial_data(&conn).unwrap();
        conn
    }

    fn add_account(conn: &Connection, id: i64, pointed: i64, committed: i64, planned: i64) {
        conn.execute(
            "INSERT INTO Compte (IDCompte, ReportPointe, ReportEngage, ReportPrevu, Libelle,
                IDTypeCompte, IDBanques, SoldeBanque, SoldeReel, SoldeFinal, NomTitulaire,
                AdresseTitulaire, COBCodeBanque, COBCodeGuichet, COBNumCompte, COBClefRIB,
                COBIBAN, DateOuverture, DateCloture, AdresseAgenceBank, COBBIC,
                NumProchCheque, CompteCloture, Devise)
             VALUES (?1, ?2, ?3, ?4, 'Compte test', 1, 1, 0, 0, 0, '', '', '', '', '', '',
                     '', NULL, NULL, '', '', 0, 0, 'EUR')",
            [id, pointed, committed, planned],
        )
        .unwrap();
    }

    fn add_operation(
        conn: &Connection,
        id: i64,
        account_id: i64,
        amount: i64,
        status: i64,
        clearing_date: &str,
        parent: i64,
    ) {
        conn.execute(
            "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDModeOperation,
                IDCategorie, IDAffectation, IDCompte, DatePointage, FitID, ReferencePaiement,
                NumRelevBanque, IDStatutOperation, IDOperationParent, SoldePointe, EstParent,
                GUIDCalOpPeriode, IDCheque, IDTiers, IDProjets, EstComplement)
             VALUES (?1, 'Op', '2026-01-01', ?2, 0, 0, 0, ?3, ?4, '', '', '', ?5, ?6, 0, 0,
                     '', 0, 0, 0, 0)",
            rusqlite::params![id, amount, account_id, clearing_date, status, parent],
        )
        .unwrap();
    }

    fn pointed_balance_of(conn: &Connection, operation_id: i64) -> i64 {
        conn.query_row(
            "SELECT SoldePointe FROM Operation WHERE IDOperation = ?1",
            [operation_id],
            |r| r.get(0),
        )
        .unwrap()
    }

    #[test]
    fn the_bank_balance_only_counts_pointed_operations() {
        let conn = database();
        add_account(&conn, 1, 100 * EURO, 0, 0);
        add_operation(&conn, 1, 1, 10 * EURO, 1, "2026-01-02", 0);
        add_operation(&conn, 2, 1, 50 * EURO, 2, "2026-01-03", 0); // engagée
        add_operation(&conn, 3, 1, 7 * EURO, 3, "2026-01-04", 0); // prévue

        assert_eq!(update_bank_balance(&conn, 1).unwrap(), 110 * EURO);
    }

    #[test]
    fn the_running_balance_is_stamped_on_every_operation_whatever_its_status() {
        let conn = database();
        add_account(&conn, 1, 100 * EURO, 0, 0);
        add_operation(&conn, 1, 1, 10 * EURO, 1, "2026-01-02", 0);
        add_operation(&conn, 2, 1, 50 * EURO, 2, "2026-01-03", 0);
        add_operation(&conn, 3, 1, 5 * EURO, 1, "2026-01-04", 0);
        update_bank_balance(&conn, 1).unwrap();

        assert_eq!(pointed_balance_of(&conn, 1), 110 * EURO);
        // The committed one does not move the total, but still carries it.
        assert_eq!(pointed_balance_of(&conn, 2), 110 * EURO);
        assert_eq!(pointed_balance_of(&conn, 3), 115 * EURO);
    }

    #[test]
    fn sub_operations_are_excluded_from_all_three_balances() {
        let conn = database();
        add_account(&conn, 1, 0, 0, 0);
        add_operation(&conn, 1, 1, -100 * EURO, 1, "2026-01-02", 0);
        // Ventilation of the operation above: must never be counted again.
        add_operation(&conn, 2, 1, -30 * EURO, 1, "2026-01-02", 1);
        add_operation(&conn, 3, 1, -70 * EURO, 1, "2026-01-02", 1);

        let balances = update_all(&conn, 1).unwrap();
        assert_eq!(balances.bank, -100 * EURO);
        assert_eq!(balances.real, -100 * EURO);
        assert_eq!(balances.final_, -100 * EURO);
        // And a sub-operation is never stamped either.
        assert_eq!(pointed_balance_of(&conn, 2), 0);
    }

    #[test]
    fn the_real_balance_adds_committed_operations_and_their_carry_over() {
        let conn = database();
        add_account(&conn, 1, 100 * EURO, 20 * EURO, 5 * EURO);
        add_operation(&conn, 1, 1, 10 * EURO, 1, "2026-01-02", 0);
        add_operation(&conn, 2, 1, 50 * EURO, 2, "2026-01-03", 0);
        add_operation(&conn, 3, 1, 7 * EURO, 3, "2026-01-04", 0);

        // 100 + 20 carried over, then the pointed and committed operations.
        assert_eq!(update_real_balance(&conn, 1).unwrap(), 180 * EURO);
    }

    #[test]
    fn the_final_balance_counts_every_status_and_every_carry_over() {
        let conn = database();
        add_account(&conn, 1, 100 * EURO, 20 * EURO, 5 * EURO);
        add_operation(&conn, 1, 1, 10 * EURO, 1, "2026-01-02", 0);
        add_operation(&conn, 2, 1, 50 * EURO, 2, "2026-01-03", 0);
        add_operation(&conn, 3, 1, 7 * EURO, 3, "2026-01-04", 0);

        // 100 + 20 + 5 carried over, then all three operations.
        assert_eq!(update_final_balance(&conn, 1).unwrap(), 192 * EURO);
    }

    #[test]
    fn other_accounts_are_left_alone() {
        let conn = database();
        add_account(&conn, 1, 0, 0, 0);
        add_account(&conn, 2, 500 * EURO, 0, 0);
        add_operation(&conn, 1, 1, 10 * EURO, 1, "2026-01-02", 0);
        add_operation(&conn, 2, 2, 999 * EURO, 1, "2026-01-02", 0);

        assert_eq!(update_bank_balance(&conn, 1).unwrap(), 10 * EURO);
        let untouched: i64 = conn
            .query_row("SELECT SoldeBanque FROM Compte WHERE IDCompte = 2", [], |r| {
                r.get(0)
            })
            .unwrap();
        assert_eq!(untouched, 0, "le compte 2 n'a pas encore ete recalcule");
    }

    #[test]
    fn the_running_balance_follows_the_clearing_date_not_the_identifier() {
        let conn = database();
        add_account(&conn, 1, 0, 0, 0);
        // Entered in one order, cleared in another.
        add_operation(&conn, 1, 1, 10 * EURO, 1, "2026-03-01", 0);
        add_operation(&conn, 2, 1, 100 * EURO, 1, "2026-01-01", 0);

        update_bank_balance(&conn, 1).unwrap();
        assert_eq!(pointed_balance_of(&conn, 2), 100 * EURO);
        assert_eq!(pointed_balance_of(&conn, 1), 110 * EURO);
    }

    #[test]
    fn the_three_balances_are_written_to_the_account() {
        let conn = database();
        add_account(&conn, 1, 100 * EURO, 20 * EURO, 5 * EURO);
        add_operation(&conn, 1, 1, 10 * EURO, 1, "2026-01-02", 0);
        add_operation(&conn, 2, 1, 50 * EURO, 2, "2026-01-03", 0);
        add_operation(&conn, 3, 1, 7 * EURO, 3, "2026-01-04", 0);

        let computed = update_all(&conn, 1).unwrap();
        let stored: (i64, i64, i64) = conn
            .query_row(
                "SELECT SoldeBanque, SoldeReel, SoldeFinal FROM Compte WHERE IDCompte = 1",
                [],
                |r| Ok((r.get(0)?, r.get(1)?, r.get(2)?)),
            )
            .unwrap();
        assert_eq!(stored, (computed.bank, computed.real, computed.final_));
    }

    #[test]
    fn recomputing_twice_changes_nothing() {
        let conn = database();
        add_account(&conn, 1, 100 * EURO, 0, 0);
        add_operation(&conn, 1, 1, 10 * EURO, 1, "2026-01-02", 0);

        let first = update_all(&conn, 1).unwrap();
        let second = update_all(&conn, 1).unwrap();
        assert_eq!(first, second);
    }

    #[test]
    fn an_unknown_account_is_refused_without_touching_anything() {
        let conn = database();
        assert_eq!(update_bank_balance(&conn, 404).unwrap(), 0);
        assert_eq!(update_real_balance(&conn, 404).unwrap(), 0);
        assert_eq!(update_final_balance(&conn, 404).unwrap(), 0);
    }

    #[test]
    fn every_account_can_be_recomputed_at_once() {
        let conn = database();
        add_account(&conn, 1, 100 * EURO, 0, 0);
        add_account(&conn, 2, 500 * EURO, 0, 0);
        add_operation(&conn, 1, 1, 10 * EURO, 1, "2026-01-02", 0);
        add_operation(&conn, 2, 2, 25 * EURO, 1, "2026-01-02", 0);

        update_all_accounts(&conn).unwrap();
        let totals: Vec<i64> = conn
            .prepare("SELECT SoldeBanque FROM Compte ORDER BY IDCompte")
            .unwrap()
            .query_map([], |r| r.get(0))
            .unwrap()
            .collect::<Result<_, _>>()
            .unwrap();
        assert_eq!(totals, vec![110 * EURO, 525 * EURO]);
    }
}
