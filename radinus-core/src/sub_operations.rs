//! Sub-operations (the ventilation of one operation into several) and the
//! "Complément" that always closes the ventilation.
//!
//! Dossier reference: `02_BASE_DE_DONNEES.md` §9, `PLAN_ACTION.md` Phase 2.2.
//! **Ported from the author's own WinDev source** — `Complement sous
//! operations.txt` (`Maj_Complement`, `Maj_ProprieteSousOp`) and `Procedure
//! sous operations.txt` (`Enreg_Ajouter`, `Enreg_Modifier`) — which is the
//! authority here, statement by statement:
//!
//! - the complement is **always** a sub-operation, and is worth the parent's
//!   amount minus the sum of its siblings (itself excluded);
//! - it is deleted the moment it falls to zero, or the moment the last real
//!   sibling disappears — a null complement has no reason to exist;
//! - at creation it inherits the parent's date, clearing date, category,
//!   assignment, payee, project and recurring-rule GUID, and is never itself
//!   a parent;
//! - status, payment mode and both dates are then pushed from the parent onto
//!   *every* sub-operation by [`sync_from_parent`] (`Maj_ProprieteSousOp`),
//!   which is why the original only sets provisional values at insert time
//!   ("valeurs par défaut qui seront écrasées");
//! - a sub-operation's amount carries the sign of the Débit/Crédit choice,
//!   applied to the absolute value entered — see [`Direction`];
//! - after any change: complement, then parent-to-children sync, then the
//!   three balances, in that order.
//!
//! **Recognizing the complement.** The original identifies it by its label,
//! `Libelle = "Complément"`. This port uses the dedicated `EstComplement`
//! marker instead (08_ARCHITECTURE.md's i18n paragraph), so the mechanism
//! does not break the day the interface speaks English. The label is still
//! written as `Complément`, exactly as the original does, so that the row
//! looks identical in the database and in an exported archive — but nothing
//! here ever *reads* the label to make a decision.
//!
//! A consequence of that choice, and the author's ruling of 26/07/2026: since
//! renaming no longer declassifies anything on its own, **a complement whose
//! label or amount is taken has its marker cleared explicitly** — see
//! [`update`]. Classifying it, commenting it, or saving it untouched leave it
//! a complement: none of that enters the computation of the remainder.
//!
//! **Two points the author's source does not cover**, deduced and flagged
//! rather than silently invented: deleting a sub-operation (the original's
//! `Enreg_Supprimer` was not part of the code supplied), and clearing the
//! parent's `EstParent` flag once its last sub-operation is gone. Both are
//! implemented here the only way that keeps the data coherent, and are called
//! out in `PLAN_ACTION.md` for the author to confirm.

use crate::balances;
use crate::database::keygen;
use rusqlite::{Connection, Result};

/// The label the original gives the complement, and which this port keeps
/// writing so that the row is indistinguishable from a 1.9.3 one.
pub const COMPLEMENT_LABEL: &str = "Complément";

/// Débit or Crédit, the choice the sub-operation form offers. The original
/// stores `-1`/`1` in the combo and multiplies the absolute value entered by
/// it (`Operation.Montant = -1 * Abs(...)` / `Abs(...)`).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Direction {
    Debit,
    Credit,
}

impl Direction {
    /// Applies the direction to an amount entered as a magnitude, exactly as
    /// the original does — the sign of what was typed is irrelevant.
    pub fn apply(self, amount: i64) -> i64 {
        match self {
            Direction::Debit => -amount.abs(),
            Direction::Credit => amount.abs(),
        }
    }
}

/// What the sub-operation form supplies. Status, payment mode and dates are
/// deliberately absent: they always come from the parent (`sync_from_parent`).
#[derive(Debug, Clone)]
pub struct SubOperationInput {
    pub label: String,
    pub direction: Direction,
    /// Magnitude; the sign comes from `direction`.
    pub amount: i64,
    pub category_id: i64,
    pub assignment_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
    /// `None` leaves any existing comment alone; `Some("")` removes it, which
    /// is what the original does when the field is emptied.
    pub comment: Option<String>,
}

/// The parent fields a sub-operation and the complement inherit.
struct ParentSnapshot {
    account_id: i64,
    amount: i64,
    date: Option<String>,
    clearing_date: Option<String>,
    status_id: i64,
    payment_mode_id: i64,
    category_id: i64,
    assignment_id: i64,
    payee_id: i64,
    project_id: i64,
    recurring_rule_guid: String,
}

fn read_parent(conn: &Connection, parent_id: i64) -> Result<Option<ParentSnapshot>> {
    let mut stmt = conn.prepare(
        "SELECT IDCompte, Montant, Date, DatePointage, IDStatutOperation, IDModeOperation,
                IDCategorie, IDAffectation, IDTiers, IDProjets, GUIDCalOpPeriode
         FROM Operation WHERE IDOperation = ?1",
    )?;
    let mut rows = stmt.query([parent_id])?;
    let Some(row) = rows.next()? else {
        return Ok(None);
    };
    Ok(Some(ParentSnapshot {
        account_id: row.get(0)?,
        amount: row.get(1)?,
        date: row.get(2)?,
        clearing_date: row.get(3)?,
        status_id: row.get(4)?,
        payment_mode_id: row.get(5)?,
        category_id: row.get(6)?,
        assignment_id: row.get(7)?,
        payee_id: row.get(8)?,
        project_id: row.get(9)?,
        recurring_rule_guid: row.get(10)?,
    }))
}

/// `Maj_Complement`: brings the complement of `parent_id` up to date —
/// creating it, adjusting it, or deleting it. Returns `true` when a complement
/// exists at the end, `false` when there is none to have (the original's
/// `RENVOYER Faux`, which it also returns when the parent cannot be found).
pub fn refresh_complement(conn: &Connection, parent_id: i64) -> Result<bool> {
    let Some(parent) = read_parent(conn, parent_id)? else {
        return Ok(false);
    };

    // Sum and count the *real* sub-operations: the complement never counts
    // towards the total it is meant to close.
    let (children_total, children_count): (i64, i64) = conn.query_row(
        "SELECT COALESCE(SUM(Montant), 0), COUNT(*)
         FROM Operation
         WHERE IDOperationParent = ?1 AND EstComplement = 0",
        [parent_id],
        |row| Ok((row.get(0)?, row.get(1)?)),
    )?;

    let complement = parent.amount - children_total;
    let unwanted = complement == 0 || children_count == 0;

    let existing: Option<i64> = conn
        .query_row(
            "SELECT IDOperation FROM Operation
             WHERE IDOperationParent = ?1 AND EstComplement = 1
             ORDER BY IDOperation LIMIT 1",
            [parent_id],
            |row| row.get(0),
        )
        .ok();

    if let Some(existing_id) = existing {
        if unwanted {
            conn.execute("DELETE FROM Operation WHERE IDOperation = ?1", [existing_id])?;
            return Ok(false);
        }
        conn.execute(
            "UPDATE Operation SET Montant = ?1 WHERE IDOperation = ?2",
            [complement, existing_id],
        )?;
        return Ok(true);
    }

    if unwanted {
        return Ok(false);
    }

    let id = keygen::next_id(conn, "Operation", "IDOperation")?;
    conn.execute(
        "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDModeOperation,
            IDCategorie, IDAffectation, IDCompte, DatePointage, FitID, ReferencePaiement,
            NumRelevBanque, IDStatutOperation, IDOperationParent, SoldePointe, EstParent,
            GUIDCalOpPeriode, IDCheque, IDTiers, IDProjets, EstComplement)
         VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, '', '', '', ?10, ?11, 0, 0, ?12, 0,
                 ?13, ?14, 1)",
        rusqlite::params![
            id,
            COMPLEMENT_LABEL,
            parent.date,
            complement,
            parent.payment_mode_id,
            parent.category_id,
            parent.assignment_id,
            parent.account_id,
            // The original sets DatePointage to the parent's *Date*; both are
            // overwritten a moment later by sync_from_parent anyway.
            parent.date,
            parent.status_id,
            parent_id,
            parent.recurring_rule_guid,
            parent.payee_id,
            parent.project_id,
        ],
    )?;
    Ok(true)
}

/// `Maj_ProprieteSousOp`: pushes the parent's status, payment mode, date,
/// clearing date, recurring-rule GUID **and verification** onto every one of
/// its sub-operations, complement included. The verification is 3.0.0's own
/// (base 11): what the user thinks of an entry is said of the bank's line, and
/// a ventilation is not one. Keeping a ventilation coherent with
/// what it ventilates is not optional — the original calls this after every
/// change.
pub fn sync_from_parent(conn: &Connection, parent_id: i64) -> Result<bool> {
    let Some(parent) = read_parent(conn, parent_id)? else {
        return Ok(false);
    };
    conn.execute(
        "UPDATE Operation
            SET IDStatutOperation = ?1, IDModeOperation = ?2, Date = ?3,
                DatePointage = ?4, GUIDCalOpPeriode = ?5,
                IDVerification = (SELECT m.IDVerification FROM Operation m
                                  WHERE m.IDOperation = ?6)
          WHERE IDOperationParent = ?6",
        rusqlite::params![
            parent.status_id,
            parent.payment_mode_id,
            parent.date,
            parent.clearing_date,
            parent.recurring_rule_guid,
            parent_id
        ],
    )?;
    Ok(true)
}

/// Adds a sub-operation to `parent_id` (`Enreg_Ajouter`), then runs the whole
/// chain the original runs: complement, parent-to-children sync, the three
/// balances, and the parent's `EstParent` flag. Returns the new id, or `None`
/// when the parent does not exist.
pub fn create(conn: &Connection, parent_id: i64, input: &SubOperationInput) -> Result<Option<i64>> {
    let Some(parent) = read_parent(conn, parent_id)? else {
        return Ok(None);
    };

    let id = keygen::next_id(conn, "Operation", "IDOperation")?;
    conn.execute(
        "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDModeOperation,
            IDCategorie, IDAffectation, IDCompte, DatePointage, FitID, ReferencePaiement,
            NumRelevBanque, IDStatutOperation, IDOperationParent, SoldePointe, EstParent,
            GUIDCalOpPeriode, IDCheque, IDTiers, IDProjets, EstComplement)
         VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, '', '', '', ?10, ?11, 0, 0, '', 0,
                 ?12, ?13, 0)",
        rusqlite::params![
            id,
            input.label,
            // Provisional values, overwritten by sync_from_parent below —
            // exactly as the original notes ("valeurs par défaut qui seront
            // écrasées"): they only exist to satisfy the constraints at insert.
            parent.date,
            input.direction.apply(input.amount),
            parent.payment_mode_id,
            input.category_id,
            input.assignment_id,
            parent.account_id,
            parent.date,
            parent.status_id,
            parent_id,
            input.payee_id,
            input.project_id,
        ],
    )?;

    set_comment(conn, id, input.comment.as_deref())?;
    after_change(conn, parent_id, parent.account_id)?;
    Ok(Some(id))
}

/// Changes a sub-operation (`Enreg_Modifier`) and runs the same chain.
///
/// **A complement that is claimed stops being a complement** (Fabrice's
/// ruling, 26/07/2026). It is not a protected object, it is a *state*: the row
/// Radinus maintains while nothing else claims the remainder.
///
/// His own example says why, and it is ergonomics rather than bookkeeping: an
/// operation of 100 € ventilated by 30 € carries a complement of 70 €. To give
/// those 70 € a purpose, one does not create a second sub-operation and leave
/// a complement of nothing behind — one renames the complement, which by that
/// act stops being one. The sum still makes 100 €, so no complement is
/// recreated. Had the amount been brought down to 50 € as well, the check
/// would have raised a fresh complement of 20 €.
///
/// **What claims it, and what does not** (his refinement of the same day, and
/// the reason this is not simply "any change"):
///
///   * the **label** and the **amount** claim it. They are what the complement
///     *is* — the name says whose the money is, the amount is the remainder
///     itself. Touch either and the row has become somebody's sub-operation;
///   * the **classification** — category, assignment, payee, project — does
///     not. None of it enters the computation of the remainder, so a complement
///     may be classified freely and stay a complement. That is worth having:
///     a remainder one wants to see in a statistic is still a remainder;
///   * **saving without touching anything** does not either. Opening a fiche
///     to look at it must never change what is in it.
///
/// The comparison is made here rather than announced by the window: it is the
/// same idea as the window's reserve — what is stored, against what arrives, at
/// the moment of the decision — but held where the truth is, so that every
/// caller obeys it and none has to remember to say so.
///
/// The original reaches this by another road: it recognizes its complement by
/// the label `Complément`, so renaming it declassifies it on its own. This
/// port recognizes it by the `EstComplement` marker, so the mechanism survives
/// the interface speaking English — and the marker therefore has to be cleared
/// here, deliberately, or the row would be silently overwritten by the next
/// recomputation.
pub fn update(conn: &Connection, id: i64, input: &SubOperationInput) -> Result<bool> {
    let parent_id: Option<i64> = conn
        .query_row(
            "SELECT IDOperationParent FROM Operation WHERE IDOperation = ?1",
            [id],
            |row| row.get(0),
        )
        .ok();
    let Some(parent_id) = parent_id.filter(|p| *p != 0) else {
        return Ok(false);
    };
    let Some(parent) = read_parent(conn, parent_id)? else {
        return Ok(false);
    };

    // What the row holds before anything is written — the two members that
    // decide whether a complement has been claimed, and whether it was one.
    let (stored_label, stored_amount, was_complement): (String, i64, i64) = conn.query_row(
        "SELECT Libelle, Montant, EstComplement FROM Operation WHERE IDOperation = ?1",
        [id],
        |row| Ok((row.get(0)?, row.get(1)?, row.get(2)?)),
    )?;
    let amount = input.direction.apply(input.amount);
    let claimed = stored_label != input.label || stored_amount != amount;
    // A complement stays one until its name or its amount is taken: see the
    // note above. Anything else on this row is the user's, and always was.
    let still_a_complement = i64::from(was_complement != 0 && !claimed);

    conn.execute(
        "UPDATE Operation
            SET Libelle = ?1, Montant = ?2, IDCategorie = ?3, IDAffectation = ?4,
                IDTiers = ?5, IDProjets = ?6, EstParent = 0, EstComplement = ?7
          WHERE IDOperation = ?8",
        rusqlite::params![
            input.label,
            amount,
            input.category_id,
            input.assignment_id,
            input.payee_id,
            input.project_id,
            still_a_complement,
            id
        ],
    )?;

    set_comment(conn, id, input.comment.as_deref())?;
    after_change(conn, parent_id, parent.account_id)?;
    Ok(true)
}

/// Removes a sub-operation and runs the same chain. **Deduced**: the supplied
/// WinDev source does not include `Enreg_Supprimer`; everything after the
/// deletion itself follows the original's own add/modify path.
pub fn delete(conn: &Connection, id: i64) -> Result<bool> {
    let row: Option<(i64, i64)> = conn
        .query_row(
            "SELECT IDOperationParent, IDCompte FROM Operation WHERE IDOperation = ?1",
            [id],
            |r| Ok((r.get(0)?, r.get(1)?)),
        )
        .ok();
    let Some((parent_id, account_id)) = row.filter(|(parent, _)| *parent != 0) else {
        return Ok(false);
    };

    // The comment goes with it, through the schema's cascade.
    conn.execute("DELETE FROM Operation WHERE IDOperation = ?1", [id])?;
    after_change(conn, parent_id, account_id)?;
    Ok(true)
}

/// Removes an operation together with its whole ventilation
/// (PLAN_ACTION.md 2.2, "suppression du parent = suppression des enfants").
/// The parent/child link is a soft one — no SQL cascade can do this — so the
/// children are deleted explicitly. Comments and attachments of each row go
/// with them, through the schema's real cascades.
pub fn delete_with_children(conn: &Connection, parent_id: i64) -> Result<bool> {
    let account_id: Option<i64> = conn
        .query_row(
            "SELECT IDCompte FROM Operation WHERE IDOperation = ?1",
            [parent_id],
            |row| row.get(0),
        )
        .ok();
    let Some(account_id) = account_id else {
        return Ok(false);
    };

    conn.execute(
        "DELETE FROM Operation WHERE IDOperationParent = ?1",
        [parent_id],
    )?;
    conn.execute("DELETE FROM Operation WHERE IDOperation = ?1", [parent_id])?;
    balances::update_all(conn, account_id)?;
    Ok(true)
}

/// The chain the original runs after touching a sub-operation: complement,
/// parent-to-children sync, then the three balances — in that order. The
/// parent's `EstParent` flag is set here too: raised by the original right
/// after an insert, and lowered again once the last sub-operation is gone
/// (**deduced** — the original never removes them all).
pub fn after_change(conn: &Connection, parent_id: i64, account_id: i64) -> Result<()> {
    refresh_complement(conn, parent_id)?;
    sync_from_parent(conn, parent_id)?;

    let remaining: i64 = conn.query_row(
        "SELECT COUNT(*) FROM Operation WHERE IDOperationParent = ?1",
        [parent_id],
        |row| row.get(0),
    )?;
    conn.execute(
        "UPDATE Operation SET EstParent = ?1 WHERE IDOperation = ?2",
        [i64::from(remaining > 0), parent_id],
    )?;

    balances::update_all(conn, account_id)?;
    Ok(())
}

/// Creates, replaces or removes the single comment attached to an operation,
/// the way the original does: an empty text removes it, `None` leaves it
/// alone.
///
/// Shared with `operations`: the fiche opération carries the same post-it as
/// the fiche sous-opération, and a comment is a comment whichever window
/// wrote it.
pub(crate) fn set_comment(conn: &Connection, operation_id: i64, text: Option<&str>) -> Result<()> {
    let Some(text) = text else { return Ok(()) };

    if text.trim().is_empty() {
        conn.execute(
            "DELETE FROM Commentaire WHERE IDOperation = ?1",
            [operation_id],
        )?;
        return Ok(());
    }

    let existing: Option<i64> = conn
        .query_row(
            "SELECT IDCommentaire FROM Commentaire WHERE IDOperation = ?1",
            [operation_id],
            |row| row.get(0),
        )
        .ok();

    match existing {
        Some(id) => {
            conn.execute(
                "UPDATE Commentaire SET CommentaireTxt = ?1 WHERE IDCommentaire = ?2",
                rusqlite::params![text, id],
            )?;
        }
        None => {
            let id = keygen::next_id(conn, "Commentaire", "IDCommentaire")?;
            conn.execute(
                "INSERT INTO Commentaire (IDCommentaire, CommentaireTxt, IDOperation)
                 VALUES (?1, ?2, ?3)",
                rusqlite::params![id, text, operation_id],
            )?;
        }
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database::{schema, seed};

    const EURO: i64 = 1_000_000;

    fn database() -> Connection {
        let conn = Connection::open_in_memory().unwrap();
        schema::migrate(&conn).unwrap();
        seed::seed_initial_data(&conn).unwrap();
        conn.execute(
            "INSERT INTO Compte (IDCompte, ReportPointe, ReportEngage, ReportPrevu, Libelle,
                IDTypeCompte, IDBanques, SoldeBanque, SoldeReel, SoldeFinal, NomTitulaire,
                AdresseTitulaire, COBCodeBanque, COBCodeGuichet, COBNumCompte, COBClefRIB,
                COBIBAN, DateOuverture, DateCloture, AdresseAgenceBank, COBBIC,
                NumProchCheque, CompteCloture, Devise)
             VALUES (1, 0, 0, 0, 'CCP', 1, 1, 0, 0, 0, '', '', '', '', '', '', '',
                     NULL, NULL, '', '', 0, 0, 'EUR')",
            [],
        )
        .unwrap();
        conn
    }

    /// The author's own scenario: a 100 € withdrawal, about to be ventilated.
    fn withdrawal_of_100(conn: &Connection) -> i64 {
        conn.execute(
            "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDModeOperation,
                IDCategorie, IDAffectation, IDCompte, DatePointage, FitID, ReferencePaiement,
                NumRelevBanque, IDStatutOperation, IDOperationParent, SoldePointe, EstParent,
                GUIDCalOpPeriode, IDCheque, IDTiers, IDProjets, EstComplement)
             VALUES (1, 'RETRAIT', '2026-01-15', ?1, 6, 8, 1, 1, '2026-01-15', '', '', '',
                     1, 0, 0, 0, '', 0, 3, 0, 0)",
            [-100 * EURO],
        )
        .unwrap();
        1
    }

    fn input(label: &str, amount: i64) -> SubOperationInput {
        SubOperationInput {
            label: label.to_string(),
            direction: Direction::Debit,
            amount,
            category_id: 1,
            assignment_id: 2,
            payee_id: 0,
            project_id: 0,
            comment: None,
        }
    }

    fn complement_of(conn: &Connection, parent_id: i64) -> Option<i64> {
        conn.query_row(
            "SELECT Montant FROM Operation WHERE IDOperationParent = ?1 AND EstComplement = 1",
            [parent_id],
            |r| r.get(0),
        )
        .ok()
    }

    #[test]
    fn the_authors_scenario_a_100_withdrawal_split_by_30_leaves_70() {
        let conn = database();
        let parent = withdrawal_of_100(&conn);

        create(&conn, parent, &input("Courses", 30 * EURO)).unwrap();

        assert_eq!(complement_of(&conn, parent), Some(-70 * EURO));
        // The parent now says so, and its own amount has not moved.
        let (is_parent, amount): (i64, i64) = conn
            .query_row(
                "SELECT EstParent, Montant FROM Operation WHERE IDOperation = ?1",
                [parent],
                |r| Ok((r.get(0)?, r.get(1)?)),
            )
            .unwrap();
        assert_eq!((is_parent, amount), (1, -100 * EURO));
    }

    #[test]
    fn a_second_sub_operation_shrinks_the_complement() {
        let conn = database();
        let parent = withdrawal_of_100(&conn);
        create(&conn, parent, &input("Courses", 30 * EURO)).unwrap();
        create(&conn, parent, &input("Essence", 45 * EURO)).unwrap();
        assert_eq!(complement_of(&conn, parent), Some(-25 * EURO));
    }

    #[test]
    fn the_complement_disappears_once_the_ventilation_is_exact() {
        let conn = database();
        let parent = withdrawal_of_100(&conn);
        create(&conn, parent, &input("Courses", 30 * EURO)).unwrap();
        create(&conn, parent, &input("Essence", 70 * EURO)).unwrap();
        assert_eq!(complement_of(&conn, parent), None);
    }

    #[test]
    fn removing_the_last_sub_operation_removes_the_complement_and_the_parent_flag() {
        let conn = database();
        let parent = withdrawal_of_100(&conn);
        let child = create(&conn, parent, &input("Courses", 30 * EURO))
            .unwrap()
            .unwrap();
        assert!(complement_of(&conn, parent).is_some());

        delete(&conn, child).unwrap();

        assert_eq!(complement_of(&conn, parent), None);
        let is_parent: i64 = conn
            .query_row(
                "SELECT EstParent FROM Operation WHERE IDOperation = ?1",
                [parent],
                |r| r.get(0),
            )
            .unwrap();
        assert_eq!(is_parent, 0);
        let remaining: i64 = conn
            .query_row("SELECT COUNT(*) FROM Operation", [], |r| r.get(0))
            .unwrap();
        assert_eq!(remaining, 1, "il ne reste que l'opération principale");
    }

    #[test]
    fn changing_a_sub_operation_adjusts_the_complement() {
        let conn = database();
        let parent = withdrawal_of_100(&conn);
        let child = create(&conn, parent, &input("Courses", 30 * EURO))
            .unwrap()
            .unwrap();

        update(&conn, child, &input("Courses", 80 * EURO)).unwrap();
        assert_eq!(complement_of(&conn, parent), Some(-20 * EURO));
    }

    #[test]
    fn the_complement_inherits_the_parents_classification() {
        let conn = database();
        let parent = withdrawal_of_100(&conn);
        create(&conn, parent, &input("Courses", 30 * EURO)).unwrap();

        let (category, assignment, payee, label): (i64, i64, i64, String) = conn
            .query_row(
                "SELECT IDCategorie, IDAffectation, IDTiers, Libelle FROM Operation
                 WHERE IDOperationParent = ?1 AND EstComplement = 1",
                [parent],
                |r| Ok((r.get(0)?, r.get(1)?, r.get(2)?, r.get(3)?)),
            )
            .unwrap();
        // Straight from the withdrawal: category 8, assignment 1, payee 3.
        assert_eq!((category, assignment, payee), (8, 1, 3));
        assert_eq!(label, COMPLEMENT_LABEL);
    }

    #[test]
    fn the_parent_pushes_its_status_mode_and_dates_onto_every_child() {
        let conn = database();
        let parent = withdrawal_of_100(&conn);
        create(&conn, parent, &input("Courses", 30 * EURO)).unwrap();

        conn.execute(
            "UPDATE Operation SET IDStatutOperation = 2, IDModeOperation = 1,
                    Date = '2026-02-01', DatePointage = '2026-02-03'
             WHERE IDOperation = ?1",
            [parent],
        )
        .unwrap();
        sync_from_parent(&conn, parent).unwrap();

        let mut stmt = conn
            .prepare(
                "SELECT IDStatutOperation, IDModeOperation, Date, DatePointage
                 FROM Operation WHERE IDOperationParent = ?1",
            )
            .unwrap();
        let rows: Vec<(i64, i64, String, String)> = stmt
            .query_map([parent], |r| Ok((r.get(0)?, r.get(1)?, r.get(2)?, r.get(3)?)))
            .unwrap()
            .collect::<Result<_>>()
            .unwrap();
        assert_eq!(rows.len(), 2, "la sous-opération et son complément");
        for row in rows {
            assert_eq!(row, (2, 1, "2026-02-01".into(), "2026-02-03".into()));
        }
    }

    #[test]
    fn a_ventilation_never_double_counts_in_the_balances() {
        let conn = database();
        let parent = withdrawal_of_100(&conn);
        create(&conn, parent, &input("Courses", 30 * EURO)).unwrap();

        let bank: i64 = conn
            .query_row("SELECT SoldeBanque FROM Compte WHERE IDCompte = 1", [], |r| {
                r.get(0)
            })
            .unwrap();
        assert_eq!(bank, -100 * EURO);
    }

    #[test]
    fn deleting_the_parent_takes_the_whole_ventilation_with_it() {
        let conn = database();
        let parent = withdrawal_of_100(&conn);
        create(&conn, parent, &input("Courses", 30 * EURO)).unwrap();
        assert_eq!(
            conn.query_row("SELECT COUNT(*) FROM Operation", [], |r| r.get::<_, i64>(0))
                .unwrap(),
            3
        );

        delete_with_children(&conn, parent).unwrap();

        assert_eq!(
            conn.query_row("SELECT COUNT(*) FROM Operation", [], |r| r.get::<_, i64>(0))
                .unwrap(),
            0
        );
        let bank: i64 = conn
            .query_row("SELECT SoldeBanque FROM Compte WHERE IDCompte = 1", [], |r| {
                r.get(0)
            })
            .unwrap();
        assert_eq!(bank, 0);
    }

    #[test]
    fn the_direction_decides_the_sign_whatever_was_typed() {
        assert_eq!(Direction::Debit.apply(30 * EURO), -30 * EURO);
        assert_eq!(Direction::Debit.apply(-30 * EURO), -30 * EURO);
        assert_eq!(Direction::Credit.apply(-30 * EURO), 30 * EURO);
        assert_eq!(Direction::Credit.apply(30 * EURO), 30 * EURO);
    }

    #[test]
    fn a_credit_ventilated_works_the_same_way() {
        let conn = database();
        conn.execute(
            "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDModeOperation,
                IDCategorie, IDAffectation, IDCompte, DatePointage, FitID, ReferencePaiement,
                NumRelevBanque, IDStatutOperation, IDOperationParent, SoldePointe, EstParent,
                GUIDCalOpPeriode, IDCheque, IDTiers, IDProjets, EstComplement)
             VALUES (1, 'SALAIRE', '2026-01-15', ?1, 8, 37, 1, 1, '2026-01-15', '', '', '',
                     1, 0, 0, 0, '', 0, 0, 0, 0)",
            [2000 * EURO],
        )
        .unwrap();

        let mut credit = input("Prime", 500 * EURO);
        credit.direction = Direction::Credit;
        create(&conn, 1, &credit).unwrap();

        assert_eq!(complement_of(&conn, 1), Some(1500 * EURO));
    }

    #[test]
    fn a_comment_follows_its_sub_operation_and_can_be_removed() {
        let conn = database();
        let parent = withdrawal_of_100(&conn);
        let mut with_comment = input("Courses", 30 * EURO);
        with_comment.comment = Some("Marché du dimanche".to_string());
        let child = create(&conn, parent, &with_comment).unwrap().unwrap();

        let text: String = conn
            .query_row(
                "SELECT CommentaireTxt FROM Commentaire WHERE IDOperation = ?1",
                [child],
                |r| r.get(0),
            )
            .unwrap();
        assert_eq!(text, "Marché du dimanche");

        let mut emptied = input("Courses", 30 * EURO);
        emptied.comment = Some(String::new());
        update(&conn, child, &emptied).unwrap();
        assert_eq!(
            conn.query_row("SELECT COUNT(*) FROM Commentaire", [], |r| r.get::<_, i64>(0))
                .unwrap(),
            0
        );
    }

    /// **Fabrice's own scenario, 26/07/2026.** 100 € ventilated by 30 € leaves
    /// a complement of 70 €. Rather than create a second sub-operation and
    /// leave a complement of nothing, he renames the complement — which by
    /// that act stops being one. The sum still makes 100 €, so nothing is
    /// recreated.
    #[test]
    fn editing_the_complement_turns_it_into_an_ordinary_sub_operation() {
        let conn = database();
        let parent = withdrawal_of_100(&conn);
        create(&conn, parent, &input("Courses", 30 * EURO)).unwrap();

        let complement_id: i64 = conn
            .query_row(
                "SELECT IDOperation FROM Operation
                 WHERE IDOperationParent = ?1 AND EstComplement = 1",
                [parent],
                |r| r.get(0),
            )
            .unwrap();
        assert_eq!(complement_of(&conn, parent), Some(-70 * EURO));

        // He opens it and gives those 70 € a purpose.
        update(&conn, complement_id, &input("Essence", 70 * EURO)).unwrap();

        // It is no longer a complement, and none was recreated: 30 + 70 = 100.
        assert_eq!(complement_of(&conn, parent), None);
        let (label, marker): (String, i64) = conn
            .query_row(
                "SELECT Libelle, EstComplement FROM Operation WHERE IDOperation = ?1",
                [complement_id],
                |r| Ok((r.get(0)?, r.get(1)?)),
            )
            .unwrap();
        assert_eq!(label, "Essence");
        assert_eq!(marker, 0, "il n'est plus géré comme un complément");

        // And the ventilation still holds two lines, not three.
        let children: i64 = conn
            .query_row(
                "SELECT COUNT(*) FROM Operation WHERE IDOperationParent = ?1",
                [parent],
                |r| r.get(0),
            )
            .unwrap();
        assert_eq!(children, 2);
    }

    /// The other half of the same ruling: if what he writes no longer closes
    /// the ventilation, the check raises a fresh complement for the rest.
    #[test]
    fn a_complement_reused_for_less_than_it_held_raises_a_new_one() {
        let conn = database();
        let parent = withdrawal_of_100(&conn);
        create(&conn, parent, &input("Courses", 30 * EURO)).unwrap();
        let complement_id: i64 = conn
            .query_row(
                "SELECT IDOperation FROM Operation
                 WHERE IDOperationParent = ?1 AND EstComplement = 1",
                [parent],
                |r| r.get(0),
            )
            .unwrap();

        // He reuses the 70 € line for 50 € only.
        update(&conn, complement_id, &input("Essence", 50 * EURO)).unwrap();

        // 30 + 50 = 80: the remaining 20 € get a complement of their own.
        assert_eq!(complement_of(&conn, parent), Some(-20 * EURO));
        let children: i64 = conn
            .query_row(
                "SELECT COUNT(*) FROM Operation WHERE IDOperationParent = ?1",
                [parent],
                |r| r.get(0),
            )
            .unwrap();
        assert_eq!(children, 3, "les deux siennes et le nouveau complément");

        // And the new complement is a different row from the one he reused.
        let fresh: i64 = conn
            .query_row(
                "SELECT IDOperation FROM Operation
                 WHERE IDOperationParent = ?1 AND EstComplement = 1",
                [parent],
                |r| r.get(0),
            )
            .unwrap();
        assert_ne!(fresh, complement_id);
    }

    /// Le classement n'entre pas dans le calcul du reste, donc on peut le
    /// changer sur un complément sans qu'il cesse d'en être un (Fabrice,
    /// 26/07/2026). Un reste qu'on veut voir dans une statistique reste un
    /// reste.
    #[test]
    fn classifying_a_complement_leaves_it_a_complement() {
        let conn = database();
        let parent = withdrawal_of_100(&conn);
        create(&conn, parent, &input("Courses", 30 * EURO)).unwrap();
        let complement: i64 = conn
            .query_row(
                "SELECT IDOperation FROM Operation
                 WHERE IDOperationParent = ?1 AND EstComplement = 1",
                [parent],
                |r| r.get(0),
            )
            .unwrap();

        // Même nom, même montant : seul le classement change. `input` porte
        // la catégorie 1 et l'affectation 2, là où le complément avait hérité
        // la 8 et la 1 de sa mère.
        let mut classified = input(COMPLEMENT_LABEL, 70 * EURO);
        classified.payee_id = 9;
        assert!(update(&conn, complement, &classified).unwrap());

        let (marker, category, payee, amount): (i64, i64, i64, i64) = conn
            .query_row(
                "SELECT EstComplement, IDCategorie, IDTiers, Montant FROM Operation
                 WHERE IDOperation = ?1",
                [complement],
                |r| Ok((r.get(0)?, r.get(1)?, r.get(2)?, r.get(3)?)),
            )
            .unwrap();
        assert_eq!(marker, 1, "il reste un vrai complément");
        assert_eq!((category, payee), (1, 9), "et il porte le classement voulu");
        assert_eq!(amount, -70 * EURO, "son montant reste le reste");

        // Aucun second complément n'a été levé.
        let marked: i64 = conn
            .query_row(
                "SELECT COUNT(*) FROM Operation
                 WHERE IDOperationParent = ?1 AND EstComplement = 1",
                [parent],
                |r| r.get(0),
            )
            .unwrap();
        assert_eq!(marked, 1);
    }

    /// Ouvrir une fiche pour la regarder ne doit jamais changer ce qu'elle
    /// contient : enregistrer sans rien toucher laisse le complément intact.
    #[test]
    fn saving_a_complement_untouched_leaves_it_a_complement() {
        let conn = database();
        let parent = withdrawal_of_100(&conn);
        create(&conn, parent, &input("Courses", 30 * EURO)).unwrap();
        let (complement, category, assignment, payee): (i64, i64, i64, i64) = conn
            .query_row(
                "SELECT IDOperation, IDCategorie, IDAffectation, IDTiers FROM Operation
                 WHERE IDOperationParent = ?1 AND EstComplement = 1",
                [parent],
                |r| Ok((r.get(0)?, r.get(1)?, r.get(2)?, r.get(3)?)),
            )
            .unwrap();

        // Ce que la fiche renverrait sans que rien n'ait été modifié.
        let untouched = SubOperationInput {
            label: COMPLEMENT_LABEL.to_string(),
            direction: Direction::Debit,
            amount: 70 * EURO,
            category_id: category,
            assignment_id: assignment,
            payee_id: payee,
            project_id: 0,
            comment: None,
        };
        assert!(update(&conn, complement, &untouched).unwrap());

        let (marker, amount): (i64, i64) = conn
            .query_row(
                "SELECT EstComplement, Montant FROM Operation WHERE IDOperation = ?1",
                [complement],
                |r| Ok((r.get(0)?, r.get(1)?)),
            )
            .unwrap();
        assert_eq!((marker, amount), (1, -70 * EURO));
    }

    /// **Il n'y a qu'un seul vrai complément par lot de sous-opérations d'une
    /// même opération principale** (Fabrice, 26/07/2026). Ce n'est pas une
    /// précaution contre l'utilisateur, c'est la définition : le complément
    /// est ce qui reste, et il n'y a qu'un reste.
    ///
    /// Le code le tient par construction — on ne crée un complément que s'il
    /// n'en existe aucun, et modifier celui qui existe le déclasse avant que
    /// la vérification ne reprenne la main. Ce test promène une ventilation à
    /// travers tout ce qu'on peut lui faire subir et vérifie qu'à aucun
    /// moment il n'y en a deux.
    #[test]
    fn there_is_never_more_than_one_complement_under_one_parent() {
        let conn = database();
        let parent = withdrawal_of_100(&conn);
        let marked = |conn: &Connection| -> i64 {
            conn.query_row(
                "SELECT COUNT(*) FROM Operation
                 WHERE IDOperationParent = ?1 AND EstComplement = 1",
                [parent],
                |r| r.get(0),
            )
            .unwrap()
        };

        let first = create(&conn, parent, &input("Courses", 30 * EURO))
            .unwrap()
            .unwrap();
        assert!(marked(&conn) <= 1);

        // Une deuxième sous-opération : le complément rétrécit, il ne se
        // dédouble pas.
        let second = create(&conn, parent, &input("Essence", 20 * EURO))
            .unwrap()
            .unwrap();
        assert!(marked(&conn) <= 1);

        // On s'approprie le complément : il se déclasse, un autre est levé.
        let complement: i64 = conn
            .query_row(
                "SELECT IDOperation FROM Operation
                 WHERE IDOperationParent = ?1 AND EstComplement = 1",
                [parent],
                |r| r.get(0),
            )
            .unwrap();
        update(&conn, complement, &input("Loisirs", 10 * EURO)).unwrap();
        assert_eq!(marked(&conn), 1, "un seul, jamais deux");

        // On en supprime une, on en modifie une autre, on change le montant
        // de la mère : toujours un seul.
        delete(&conn, second).unwrap();
        assert!(marked(&conn) <= 1);
        update(&conn, first, &input("Courses", 95 * EURO)).unwrap();
        assert!(marked(&conn) <= 1);
        conn.execute(
            "UPDATE Operation SET Montant = ?1 WHERE IDOperation = ?2",
            [-200 * EURO, parent],
        )
        .unwrap();
        after_change(&conn, parent, 1).unwrap();
        assert_eq!(marked(&conn), 1);

        // Et la ventilation ferme exactement la mère, complément compris.
        let total: i64 = conn
            .query_row(
                "SELECT COALESCE(SUM(Montant), 0) FROM Operation WHERE IDOperationParent = ?1",
                [parent],
                |r| r.get(0),
            )
            .unwrap();
        assert_eq!(total, -200 * EURO);
    }

    #[test]
    fn an_unknown_parent_is_refused() {
        let conn = database();
        assert_eq!(create(&conn, 404, &input("X", EURO)).unwrap(), None);
        assert!(!refresh_complement(&conn, 404).unwrap());
        assert!(!sync_from_parent(&conn, 404).unwrap());
    }
}
