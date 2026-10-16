//! The operations of an account — the sixteen columns of F02
//! (04_SPECIFICATIONS_FENETRES.md), read between two dates.
//!
//! **The list is a tree, and that is the trap.** An operation carrying
//! sub-operations shows a « + »; unfolding it inserts its children under it,
//! before the next top-level operation (Fabrice, 25/07/2026). What is read
//! here is therefore never a flat run of rows: it is parents, each with the
//! children that belong to it, and the window flattens that as it draws,
//! according to what is unfolded.
//!
//! Two things follow, and they are the reason this module exists rather than
//! one big SQL query in the controller. A child has **no balance of its own**:
//! `SoldePointe` is stamped on top-level operations only (`balances`, phase 2),
//! because it is the running balance of the account and a ventilation does not
//! move the account. And a child is never read alone: it comes with its
//! parent or not at all, so sorting and filtering can only ever apply to
//! parents — a child follows its mother.

use crate::domain::{NamedItem, NaiveDate};
use crate::sub_operations::Direction;
use rusqlite::{Connection, Result};

/// One line of the table, parent or child alike. What the window shows and
/// nothing more: the names are resolved here, since the table shows names and
/// the names live in six other tables.
#[derive(Debug, Clone, PartialEq)]
pub struct OperationRow {
    pub id: i64,
    pub label: String,
    pub date: Option<NaiveDate>,
    pub clearing_date: Option<NaiveDate>,
    pub amount: i64,
    pub category: String,
    pub assignment: String,
    pub payment_mode: String,
    pub payee: String,
    pub project: String,
    pub category_id: i64,
    pub assignment_id: i64,
    pub payment_mode_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
    pub status_id: i64,
    /// `Verification` — 1 à vérifier, 2 vérifiée, 3 douteuse, 4 contestée.
    pub verification_id: i64,
    /// The running balance after this operation. Top-level operations only.
    pub pointed_balance: i64,
    /// The comment itself, empty when there is none. The list shows a tick in
    /// its column and the text on hover, so it needs the words and not just
    /// their existence.
    pub comment: String,
    pub has_attachment: bool,
    pub check_number: String,
    /// A sub-operation Radinus maintains itself (`sub_operations`): it is a
    /// child like any other on screen, but the user does not write it.
    pub is_complement: bool,
}

/// A top-level operation and the children that belong to it. The children are
/// already in the order they must appear under their mother.
#[derive(Debug, Clone, PartialEq)]
pub struct OperationTree {
    pub parent: OperationRow,
    pub children: Vec<OperationRow>,
}

impl OperationRow {
    /// Whether the Commentaires column shows its tick.
    pub fn has_comment(&self) -> bool {
        !self.comment.trim().is_empty()
    }
}

impl OperationTree {
    /// Whether this operation shows a « + ».
    pub fn has_children(&self) -> bool {
        !self.children.is_empty()
    }
}

/// What the foot of the window adds up, for the period on screen.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct Totals {
    pub debit: i64,
    pub credit: i64,
    /// `debit + credit` — the two are signed, so the total is their sum.
    pub total: i64,
}

pub(crate) const SELECT_ROW: &str = "
    SELECT o.IDOperation, o.Libelle, o.Date, o.DatePointage, o.Montant,
           o.IDCategorie, o.IDAffectation, o.IDModeOperation, o.IDTiers,
           o.IDProjets, o.IDStatutOperation, o.SoldePointe, o.IDOperationParent,
           o.EstComplement,
           COALESCE(cat.Libelle, ''), COALESCE(aff.Libelle, ''),
           COALESCE(mod.Libelle, ''), COALESCE(tie.Libelle, ''),
           COALESCE(pro.Libelle, ''),
           COALESCE(chq.NumChq, 0),
           COALESCE((SELECT c.CommentaireTxt FROM Commentaire c
                     WHERE c.IDOperation = o.IDOperation), ''),
           (SELECT COUNT(*) FROM PiecesJointes p WHERE p.IDOperation = o.IDOperation),
           o.IDVerification
    FROM Operation o
    LEFT JOIN Categorie cat ON cat.IDCategorie = o.IDCategorie
    LEFT JOIN Affectation aff ON aff.IDAffectation = o.IDAffectation
    LEFT JOIN ModeOperation mod ON mod.IDModeOperation = o.IDModeOperation
    LEFT JOIN Tiers tie ON tie.IDTiers = o.IDTiers
    LEFT JOIN Projets pro ON pro.IDProjets = o.IDProjets
    LEFT JOIN Cheque chq ON chq.IDCheque = o.IDCheque
";

pub(crate) fn read_row(row: &rusqlite::Row<'_>) -> rusqlite::Result<(OperationRow, i64)> {
    let date = |index: usize| -> rusqlite::Result<Option<NaiveDate>> {
        Ok(row
            .get::<_, Option<String>>(index)?
            .and_then(|text| NaiveDate::parse_from_str(&text, "%Y-%m-%d").ok()))
    };
    let parent_id: i64 = row.get(12)?;
    Ok((
        OperationRow {
            id: row.get(0)?,
            label: row.get(1)?,
            date: date(2)?,
            clearing_date: date(3)?,
            amount: row.get(4)?,
            category_id: row.get(5)?,
            assignment_id: row.get(6)?,
            payment_mode_id: row.get(7)?,
            payee_id: row.get(8)?,
            project_id: row.get(9)?,
            status_id: row.get(10)?,
            verification_id: row.get(22)?,
            pointed_balance: row.get(11)?,
            is_complement: row.get::<_, i64>(13)? != 0,
            category: row.get(14)?,
            assignment: row.get(15)?,
            payment_mode: row.get(16)?,
            payee: row.get(17)?,
            project: row.get(18)?,
            // Groupé par trois — « 9 506 038 » — comme la capture de F02
            // l'écrit. Le nombre est en base, l'écriture est ici.
            check_number: crate::cheques::formatted_number(row.get::<_, i64>(19)?),
            comment: row.get(20)?,
            has_attachment: row.get::<_, i64>(21)? > 0,
        },
        parent_id,
    ))
}

/// Every operation of `account` whose date falls between `from` and `to`,
/// bounds included, as a tree.
///
/// **The bounds apply to the mothers.** A child has the date of its mother
/// (`sub_operations::sync_from_parent`), but it is fetched by its mother's key
/// rather than by its own date: a ventilation must never fall outside the
/// period its operation is in, whatever the state of its own `Date` column in
/// a database restored from an old backup.
///
/// The order is the one the window shows: by date, then by key, so that two
/// operations of the same day never swap places from one reading to the next.
pub fn list_for_account(
    conn: &Connection,
    account_id: i64,
    from: NaiveDate,
    to: NaiveDate,
    status: Option<i64>,
    verification: Option<i64>,
) -> Result<Vec<OperationTree>> {
    // The status filter applies to the **mothers**, like the period bounds: a
    // child has its mother's status (`sub_operations::sync_from_parent`), and
    // showing a ventilation without the operation it ventilates would show a
    // sum belonging to nothing.
    //
    // **Le filtre de vérification, de même** (Fabrice, 05/10/2026 : « on
    // pourra combiner, choisir opérations pointées et filtre À vérifier »).
    // Une fille porte la vérification de sa mère ; les deux filtres
    // s'additionnent, et l'absence de l'un veut dire « tous ».
    //
    // Une vérification hors de la liste — une base abîmée — est tenue pour
    // « À vérifier », comme dans la statistique par vérifications : une
    // écriture que personne n'a jugée est une écriture à regarder, et elle ne
    // doit pas échapper au filtre qui sert justement à la retrouver.
    let mut statement = conn.prepare(&format!(
        "{SELECT_ROW}
         WHERE o.IDCompte = ?1 AND o.IDOperationParent = 0
           AND o.Date IS NOT NULL AND o.Date >= ?2 AND o.Date <= ?3
           AND (?4 IS NULL OR o.IDStatutOperation = ?4)
           AND (?5 IS NULL OR ?5 = CASE
                 WHEN o.IDVerification IN (SELECT v.IDVerification FROM Verification v)
                 THEN o.IDVerification ELSE {TO_VERIFY} END)
         ORDER BY o.Date, o.IDOperation"
    ))?;
    let from = from.format("%Y-%m-%d").to_string();
    let to = to.format("%Y-%m-%d").to_string();
    let read = |row: &rusqlite::Row<'_>| read_row(row).map(|(operation, _)| operation);
    let parents: Vec<OperationRow> = statement
        .query_map(
            rusqlite::params![account_id, from, to, status, verification],
            read,
        )?
        .collect::<Result<_>>()?;

    // The children of the whole period in one read, then handed to their
    // mothers. One query per operation would be two thousand queries on the
    // author's own account.
    let mut children = conn.prepare(&format!(
        "{SELECT_ROW}
         WHERE o.IDCompte = ?1 AND o.IDOperationParent <> 0
         ORDER BY o.EstComplement, o.IDOperation"
    ))?;
    let mut by_parent: std::collections::HashMap<i64, Vec<OperationRow>> =
        std::collections::HashMap::new();
    for entry in children.query_map([account_id], read_row)? {
        let (operation, parent_id) = entry?;
        by_parent.entry(parent_id).or_default().push(operation);
    }

    Ok(parents
        .into_iter()
        .map(|parent| OperationTree {
            children: by_parent.remove(&parent.id).unwrap_or_default(),
            parent,
        })
        .collect())
}

/// Les opérations nommées, **par identifiant**, mères et filles confondues.
///
/// L'impression a besoin de ce que la fenêtre montre, dans l'ordre où elle le
/// montre : la fenêtre envoie ses clefs, et l'appelant relit la table dans cet
/// ordre-là. Le résultat est donc une table de correspondance et non une liste
/// — c'est l'appelant qui décide de l'ordre, pas le SQL.
///
/// La valeur porte, en second, la clef de la mère : zéro pour une opération de
/// premier niveau, la clef de l'opération ventilée pour une fille.
pub fn read_by_ids(
    conn: &Connection,
    ids: &[i64],
) -> Result<std::collections::HashMap<i64, (OperationRow, i64)>> {
    let mut found = std::collections::HashMap::with_capacity(ids.len());
    if ids.is_empty() {
        return Ok(found);
    }
    let mut statement = conn.prepare(&format!(
        "{SELECT_ROW}
         WHERE o.IDOperation = ?1"
    ))?;
    for id in ids {
        // Une clef inconnue n'est pas une faute : la fenêtre a pu être
        // rafraîchie entre le clic et la lecture. On saute.
        if let Some(entry) = statement
            .query_map([id], read_row)?
            .next()
            .transpose()?
        {
            found.insert(entry.0.id, entry);
        }
    }
    Ok(found)
}

/// What the foot of the window shows for the period: the debits, the credits,
/// and their sum.
///
/// **Top-level operations only.** A ventilation splits an amount that is
/// already counted; adding the children in would count the money twice.
pub fn totals(trees: &[OperationTree]) -> Totals {
    let mut totals = Totals::default();
    for tree in trees {
        if tree.parent.amount < 0 {
            totals.debit += tree.parent.amount;
        } else {
            totals.credit += tree.parent.amount;
        }
    }
    totals.total = totals.debit + totals.credit;
    totals
}

/// Deletes the operations of `ids` **and every child they carry** (author's
/// ruling, 25/07/2026: the mother takes her daughters). A child named in
/// `ids` whose mother is also named is not deleted twice.
///
/// Returns how many rows went, children included, so the window can say it.
pub fn delete(conn: &mut Connection, ids: &[i64]) -> Result<usize> {
    // Which mothers keep living while losing a child: their Complément will
    // have to be redone. Read before anything is deleted.
    let mut mothers: Vec<i64> = Vec::new();
    for id in ids {
        if let Ok(parent) = conn.query_row(
            "SELECT IDOperationParent FROM Operation WHERE IDOperation = ?1",
            [id],
            |row| row.get::<_, i64>(0),
        ) {
            if parent != 0 && !ids.contains(&parent) && !mothers.contains(&parent) {
                mothers.push(parent);
            }
        }
    }

    let transaction = conn.transaction()?;
    let mut gone = 0;

    // Mothers first: what they take with them must not be looked for again.
    let mut deleted: std::collections::HashSet<i64> = std::collections::HashSet::new();
    for id in ids {
        if deleted.contains(id) {
            continue;
        }
        let children: Vec<i64> = transaction
            .prepare("SELECT IDOperation FROM Operation WHERE IDOperationParent = ?1")?
            .query_map([id], |row| row.get(0))?
            .collect::<Result<_>>()?;
        for child in &children {
            deleted.insert(*child);
        }
        let count = transaction.execute(
            "DELETE FROM Operation WHERE IDOperation = ?1 OR IDOperationParent = ?1",
            [id],
        )?;
        if count > 0 {
            deleted.insert(*id);
            gone += count;
        }
    }

    transaction.commit()?;

    // A mother that lost a child but not her life has a Complément to redo,
    // and three balances to recompute with it. The mothers are collected
    // before the deletion, since afterwards there is nothing left to ask.
    for mother in mothers {
        if let Some(account) = account_of(conn, mother)? {
            crate::sub_operations::after_change(conn, mother, account)?;
        }
    }
    Ok(gone)
}

/// The account an operation belongs to, or `None` when it no longer exists.
pub fn account_of(conn: &Connection, id: i64) -> Result<Option<i64>> {
    match conn.query_row(
        "SELECT IDCompte FROM Operation WHERE IDOperation = ?1",
        [id],
        |row| row.get(0),
    ) {
        Ok(account) => Ok(Some(account)),
        Err(rusqlite::Error::QueryReturnedNoRows) => Ok(None),
        Err(other) => Err(other),
    }
}

/// Changes one nomenclature of one operation — what the combos of the list
/// write when the user picks a value (04_SPECIFICATIONS_FENETRES.md, F02:
/// « éditable en ligne »).
///
/// Returns `false` when the operation no longer exists.
///
/// A mother's own change is passed down the chain (`sync_from_parent`), which
/// carries her status, her payment mode and her dates — **and deliberately
/// not her classification**. The Complément inherits a category, an
/// assignment, a payee and a project once, when it is created, and keeps them
/// afterwards: the user may classify a Complément freely and it stays a
/// Complément, since none of that enters the computation of the remainder
/// (Fabrice, 26/07/2026). A mother re-classified later would otherwise wipe
/// out what he chose.
///
/// A child changes alone — that is the whole point of a ventilation.
pub fn set_nomenclature(
    conn: &Connection,
    id: i64,
    kind: crate::nomenclatures::Nomenclature,
    value: i64,
) -> Result<bool> {
    use crate::nomenclatures::Nomenclature;
    let column = match kind {
        Nomenclature::Category => "IDCategorie",
        Nomenclature::Assignment => "IDAffectation",
        Nomenclature::PaymentMode => "IDModeOperation",
        Nomenclature::Payee => "IDTiers",
        Nomenclature::Project => "IDProjets",
        // A budget line and a bank are not carried by an operation.
        Nomenclature::BudgetLine | Nomenclature::Bank => return Ok(false),
    };
    let changed = conn.execute(
        &format!("UPDATE Operation SET {column} = ?1 WHERE IDOperation = ?2"),
        [value, id],
    )?;
    if changed == 0 {
        return Ok(false);
    }

    let parent_id: i64 = conn.query_row(
        "SELECT IDOperationParent FROM Operation WHERE IDOperation = ?1",
        [id],
        |row| row.get(0),
    )?;
    if parent_id == 0 {
        // A mother: her Complément follows her classification.
        crate::sub_operations::sync_from_parent(conn, id)?;
    }
    Ok(true)
}

// --- The fiche opération (F03) ------------------------------------------
//
// What the fiche reads and what it writes, and nothing between the two: no
// flag, no remembered state. The window reads a record by its key, copies it
// into its reserve, and shows it; on the way out it compares the fields with
// the reserve, member by member. This module's part of that bargain is to
// hand over exactly what the record holds and to write back exactly what is
// given (author's method, 25/07/2026).

/// One of the three statuses an operation can be in — pointed, committed,
/// planned (02_BASE_DE_DONNEES.md §5.2). A closed list prefilled by the code:
/// read as it is, never added to.
pub fn statuses(conn: &Connection) -> Result<Vec<NamedItem>> {
    let mut statement =
        conn.prepare("SELECT IDStatutOperation, Libelle FROM StatutOperation ORDER BY IDStatutOperation")?;
    let items = statement
        .query_map([], |row| {
            Ok(NamedItem {
                id: row.get(0)?,
                label: row.get(1)?,
            })
        })?
        .collect();
    items
}

/// **Le même statut à plusieurs opérations d'un coup** — le menu du clic droit
/// de F02 (Fabrice, 03/10/2026).
///
/// Le geste et les règles sont ceux de [`set_verification_many`], et la date
/// de pointage suit celles de [`set_status`] : passer à pointé pose la date de
/// l'opération là où le champ est vide, et une date déjà là n'est jamais
/// touchée, dans aucun sens. Une fille sélectionnée vaut pour sa mère, chaque
/// mère n'est traitée qu'une fois, et tout part dans une seule transaction.
///
/// Rend le nombre d'opérations de premier niveau qui ont réellement changé.
/// Un statut inconnu ne change rien et rend zéro.
pub fn set_status_many(conn: &mut Connection, ids: &[i64], status_id: i64) -> Result<usize> {
    let transaction = conn.transaction()?;
    let mut mothers: Vec<i64> = Vec::new();
    for id in ids {
        let parent_id: Option<i64> = transaction
            .query_row(
                "SELECT IDOperationParent FROM Operation WHERE IDOperation = ?1",
                [id],
                |row| row.get(0),
            )
            .ok();
        let Some(parent_id) = parent_id else { continue };
        let mother = if parent_id == 0 { *id } else { parent_id };
        if !mothers.contains(&mother) {
            mothers.push(mother);
        }
    }
    let mut changed = 0;
    for mother in mothers {
        if set_status(&transaction, mother, status_id)? {
            changed += 1;
        }
    }
    transaction.commit()?;
    Ok(changed)
}

/// The four verifications — to verify, verified, doubtful, disputed. A closed
/// list like the statuses, read as it is.
pub fn verifications(conn: &Connection) -> Result<Vec<NamedItem>> {
    let mut statement =
        conn.prepare("SELECT IDVerification, Libelle FROM Verification ORDER BY IDVerification")?;
    let items = statement
        .query_map([], |row| {
            Ok(NamedItem {
                id: row.get(0)?,
                label: row.get(1)?,
            })
        })?
        .collect();
    items
}

/// Rend `wanted` s'il nomme une ligne de `Verification`, et `None` sinon.
fn known_verification(conn: &Connection, wanted: Option<i64>) -> Result<Option<i64>> {
    let Some(wanted) = wanted else {
        return Ok(None);
    };
    let known: bool = conn.query_row(
        "SELECT EXISTS(SELECT 1 FROM Verification WHERE IDVerification = ?1)",
        [wanted],
        |row| row.get(0),
    )?;
    Ok(known.then_some(wanted))
}

/// **Change la vérification d'une opération depuis la liste** — la colonne
/// « Vérification » de F02 (Fabrice, 03/10/2026).
///
/// Le statut dit ce que la banque a fait de l'écriture ; la vérification dit
/// ce que l'utilisateur en pense. Les deux ne se touchent pas : rien ici ne
/// lit ni n'écrit le statut, la date de pointage ou un solde.
///
/// **Une sous-opération n'a pas de vérification à elle** : c'est l'écriture
/// de la banque que l'on juge, et une ventilation n'en est pas une. Elle porte
/// celle de sa mère, que `sync_from_parent` lui recopie ; on la refuse donc
/// ici, comme la liste refuse de l'offrir.
///
/// Rend `false` quand rien n'a changé : opération introuvable, sous-opération,
/// valeur inconnue, ou valeur déjà en place.
pub fn set_verification(conn: &Connection, id: i64, verification_id: i64) -> Result<bool> {
    let Some(wanted) = known_verification(conn, Some(verification_id))? else {
        return Ok(false);
    };
    let changed = conn.execute(
        "UPDATE Operation SET IDVerification = ?1
          WHERE IDOperation = ?2 AND IDOperationParent = 0 AND IDVerification <> ?1",
        [wanted, id],
    )?;
    if changed == 0 {
        return Ok(false);
    }
    // Ses filles la suivent. Les soldes, eux, n'ont rien à recalculer.
    crate::sub_operations::sync_from_parent(conn, id)?;
    Ok(true)
}

/// **La même vérification à plusieurs opérations d'un coup** — le menu du clic
/// droit de F02 (Fabrice, 03/10/2026 : « le but est de pouvoir modifier le
/// statut de plusieurs lignes en leur affectant un statut de vérification
/// identique »).
///
/// Les règles sont celles du bouton Pointer, parce que le geste est le même —
/// une sélection, une valeur. **Une fille sélectionnée vaut pour sa mère** :
/// c'est l'écriture de la banque que l'on juge, et la mère rend ensuite sa
/// vérification à toutes ses filles. Chaque mère n'est traitée qu'une fois,
/// quel que soit le nombre de ses lignes prises dans la sélection.
///
/// Tout part dans une seule transaction : une sélection à moitié changée ne
/// se verrait pas à l'écran, et c'est justement ce qui la rendrait grave.
///
/// Rend le nombre d'opérations de premier niveau qui ont réellement changé —
/// celles qui portaient déjà la valeur ne comptent pas. Une valeur hors de la
/// liste ne change rien et rend zéro.
pub fn set_verification_many(
    conn: &mut Connection,
    ids: &[i64],
    verification_id: i64,
) -> Result<usize> {
    if known_verification(conn, Some(verification_id))?.is_none() {
        return Ok(0);
    }
    let transaction = conn.transaction()?;
    let mut mothers: Vec<i64> = Vec::new();
    for id in ids {
        let parent_id: Option<i64> = transaction
            .query_row(
                "SELECT IDOperationParent FROM Operation WHERE IDOperation = ?1",
                [id],
                |row| row.get(0),
            )
            .ok();
        let Some(parent_id) = parent_id else { continue };
        let mother = if parent_id == 0 { *id } else { parent_id };
        if !mothers.contains(&mother) {
            mothers.push(mother);
        }
    }
    let mut changed = 0;
    for mother in mothers {
        if set_verification(&transaction, mother, verification_id)? {
            changed += 1;
        }
    }
    transaction.commit()?;
    Ok(changed)
}

/// An operation as its fiche shows it. The amount travels **signed**, as it
/// is stored; the fiche splits it into a direction and a magnitude, since
/// that is what the original's two controls hold.
#[derive(Debug, Clone, PartialEq)]
pub struct OperationDetail {
    pub id: i64,
    pub account_id: i64,
    pub label: String,
    pub payment_reference: String,
    pub date: Option<NaiveDate>,
    pub clearing_date: Option<NaiveDate>,
    pub amount: i64,
    pub status_id: i64,
    pub category_id: i64,
    pub assignment_id: i64,
    pub payment_mode_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
    /// The number of the cheque this operation is tied to, or an empty string
    /// when it is tied to none. Read-only in the fiche: tying and untying is
    /// phase 9's business.
    pub check_number: String,
    pub comment: String,
    pub attachment_count: i64,
    /// `0` for a top-level operation, its mother's key for a sub-operation.
    pub parent_id: i64,
    pub child_count: i64,
    pub is_complement: bool,
    /// `Verification` — 1 à vérifier, 2 vérifiée, 3 douteuse, 4 contestée.
    pub verification_id: i64,
}

/// « À vérifier » : l'utilisateur n'a pas encore contrôlé l'écriture.
pub const TO_VERIFY: i64 = 1;
/// « Vérifiée » : la valeur d'une opération qui naît, et celle de toutes
/// celles qui existaient avant la base 11.
pub const VERIFIED: i64 = 2;

/// What the fiche sends back. The amount is a **magnitude**: the sign comes
/// from `direction`, exactly as in the original, where the Débit/Crédit combo
/// holds `-1`/`1` and multiplies the absolute value entered.
#[derive(Debug, Clone)]
pub struct OperationInput {
    pub label: String,
    pub payment_reference: String,
    pub date: Option<NaiveDate>,
    pub clearing_date: Option<NaiveDate>,
    pub direction: Direction,
    pub amount: i64,
    pub status_id: i64,
    pub category_id: i64,
    pub assignment_id: i64,
    pub payment_mode_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
    /// `None` laisse la vérification telle qu'elle est — et une opération qui
    /// naît est alors « Vérifiée », la valeur par défaut de la colonne. Seuls
    /// la fiche et les imports la nomment.
    pub verification_id: Option<i64>,
    /// `None` leaves any existing comment alone; `Some("")` removes it.
    pub comment: Option<String>,
}

fn iso(date: Option<NaiveDate>) -> Option<String> {
    date.map(|day| day.format("%Y-%m-%d").to_string())
}

/// Reads one operation for its fiche, or `None` when it no longer exists.
///
/// **This is the first step of the fiche and it cannot be skipped**: the
/// record is read by the key the list handed over, the reserve is filled from
/// what was read, and only then are the fields shown (author's rule,
/// 25/07/2026).
pub fn get(conn: &Connection, id: i64) -> Result<Option<OperationDetail>> {
    let mut statement = conn.prepare(
        "SELECT o.IDOperation, o.IDCompte, o.Libelle, o.ReferencePaiement, o.Date,
                o.DatePointage, o.Montant, o.IDStatutOperation, o.IDCategorie,
                o.IDAffectation, o.IDModeOperation, o.IDTiers, o.IDProjets,
                o.IDOperationParent, o.EstComplement,
                COALESCE(chq.NumChq, 0),
                COALESCE((SELECT c.CommentaireTxt FROM Commentaire c
                          WHERE c.IDOperation = o.IDOperation), ''),
                (SELECT COUNT(*) FROM PiecesJointes p WHERE p.IDOperation = o.IDOperation),
                (SELECT COUNT(*) FROM Operation f WHERE f.IDOperationParent = o.IDOperation),
                o.IDVerification
         FROM Operation o
         LEFT JOIN Cheque chq ON chq.IDCheque = o.IDCheque
         WHERE o.IDOperation = ?1",
    )?;
    let day = |text: Option<String>| {
        text.and_then(|text| NaiveDate::parse_from_str(&text, "%Y-%m-%d").ok())
    };
    let mut rows = statement.query([id])?;
    let Some(row) = rows.next()? else {
        return Ok(None);
    };
    Ok(Some(OperationDetail {
        id: row.get(0)?,
        account_id: row.get(1)?,
        label: row.get(2)?,
        payment_reference: row.get(3)?,
        date: day(row.get(4)?),
        clearing_date: day(row.get(5)?),
        amount: row.get(6)?,
        status_id: row.get(7)?,
        category_id: row.get(8)?,
        assignment_id: row.get(9)?,
        payment_mode_id: row.get(10)?,
        payee_id: row.get(11)?,
        project_id: row.get(12)?,
        parent_id: row.get(13)?,
        is_complement: row.get::<_, i64>(14)? != 0,
        check_number: crate::cheques::formatted_number(row.get::<_, i64>(15)?),
        comment: row.get(16)?,
        attachment_count: row.get(17)?,
        child_count: row.get(18)?,
        verification_id: row.get(19)?,
    }))
}

/// Writes a new operation on `account_id` and returns its key.
///
/// The three balances of the account are recomputed straight away: an
/// operation that exists but is not in the balances is a lie shown in six
/// windows.
pub fn create(conn: &Connection, account_id: i64, input: &OperationInput) -> Result<i64> {
    let id = create_within(conn, account_id, input)?;
    crate::balances::update_all(conn, account_id)?;
    Ok(id)
}

/// La même écriture, **sans le recalcul des soldes** — pour les appelants qui
/// écrivent plusieurs opérations dans une seule transaction et recalculent
/// après coup.
///
/// C'est ce dont le virement a besoin (voir [`crate::transfers`]) : ses deux
/// écritures doivent partir ensemble ou pas du tout, et recalculer un solde au
/// milieu d'une transaction qui peut encore être annulée n'aurait pas de sens.
pub fn create_within(
    conn: &Connection,
    account_id: i64,
    input: &OperationInput,
) -> Result<i64> {
    let id = crate::database::keygen::next_id(conn, "Operation", "IDOperation")?;
    conn.execute(
        "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDModeOperation,
            IDCategorie, IDAffectation, IDCompte, DatePointage, FitID, ReferencePaiement,
            NumRelevBanque, IDStatutOperation, IDOperationParent, SoldePointe, EstParent,
            GUIDCalOpPeriode, IDCheque, IDTiers, IDProjets, EstComplement, IDVerification)
         VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, '', ?10, '', ?11, 0, 0, 0, '', 0,
                 ?12, ?13, 0, ?14)",
        rusqlite::params![
            id,
            input.label,
            iso(input.date),
            input.direction.apply(input.amount),
            input.payment_mode_id,
            input.category_id,
            input.assignment_id,
            account_id,
            iso(input.clearing_date),
            input.payment_reference,
            input.status_id,
            input.payee_id,
            input.project_id,
            known_verification(conn, input.verification_id)?.unwrap_or(VERIFIED),
        ],
    )?;
    crate::sub_operations::set_comment(conn, id, input.comment.as_deref())?;
    Ok(id)
}

/// Changes an operation. Returns `false` when it no longer exists.
///
/// **The whole ventilation chain runs afterwards** (`sub_operations::
/// after_change`), and that is not a precaution: changing a mother's amount
/// changes what her Complément is worth, and changing her status, her mode or
/// either of her dates has to be pushed onto every one of her children — the
/// original does exactly this after every write (`Maj_Complement`,
/// `Maj_ProprieteSousOp`). An operation carrying no children passes through
/// it untouched, and its balances are recomputed all the same.
///
/// A **sub-operation** is not written here: it has its own fiche (F04) and
/// its own rules — its date, status and mode belong to its mother.
pub fn update(conn: &Connection, id: i64, input: &OperationInput) -> Result<bool> {
    let found: Option<(i64, i64)> = conn
        .query_row(
            "SELECT IDCompte, IDOperationParent FROM Operation WHERE IDOperation = ?1",
            [id],
            |row| Ok((row.get(0)?, row.get(1)?)),
        )
        .ok();
    let Some((account_id, parent_id)) = found else {
        return Ok(false);
    };

    conn.execute(
        "UPDATE Operation
            SET Libelle = ?1, ReferencePaiement = ?2, Date = ?3, DatePointage = ?4,
                Montant = ?5, IDStatutOperation = ?6, IDCategorie = ?7,
                IDAffectation = ?8, IDModeOperation = ?9, IDTiers = ?10, IDProjets = ?11,
                IDVerification = COALESCE(?13, IDVerification)
          WHERE IDOperation = ?12",
        rusqlite::params![
            input.label,
            input.payment_reference,
            iso(input.date),
            iso(input.clearing_date),
            input.direction.apply(input.amount),
            input.status_id,
            input.category_id,
            input.assignment_id,
            input.payment_mode_id,
            input.payee_id,
            input.project_id,
            id,
            // `None`, ou une valeur hors de la liste : on ne touche à rien.
            known_verification(conn, input.verification_id)?,
        ],
    )?;
    crate::sub_operations::set_comment(conn, id, input.comment.as_deref())?;

    if parent_id == 0 {
        crate::sub_operations::after_change(conn, id, account_id)?;
    } else {
        crate::sub_operations::after_change(conn, parent_id, account_id)?;
    }
    Ok(true)
}

/// L'identifiant FITID d'une opération, ou `None` si elle n'existe pas.
///
/// **Il ne voyage pas avec `OperationInput`, et c'est délibéré.** Un FITID
/// vient de la banque : elle le donne à l'import, et c'est lui qui empêche une
/// opération d'être intégrée deux fois (`statements::already_here`). Le faire
/// passer par les champs de la fiche reviendrait à le réécrire à chaque
/// enregistrement — la fiche le reposerait tel qu'elle l'a lu, ce qui va bien
/// tant que rien ne se perd en chemin, et mal le jour où quelque chose s'y
/// perd. Il ne se touche donc **que quand on a demandé à le toucher**
/// (décision de Fabrice, 04/08/2026 : un menu Options dans F03).
pub fn fitid(conn: &Connection, id: i64) -> Result<Option<String>> {
    Ok(conn
        .query_row(
            "SELECT FitID FROM Operation WHERE IDOperation = ?1",
            [id],
            |row| row.get::<_, String>(0),
        )
        .ok())
}

/// Écrit l'identifiant FITID d'une opération, et rend `false` si elle n'existe
/// pas.
///
/// **Une chaîne vide l'efface** : la colonne est `NOT NULL DEFAULT ''`, et
/// c'est ainsi que « pas de FITID » s'écrit partout ailleurs — `statements`
/// relève les identifiants d'un compte par `WHERE FitID <> ''`. Supprimer
/// n'est donc pas un autre geste que réécrire, c'est le même avec rien.
///
/// **Rien n'est propagé aux filles** : une sous-opération naît avec un FITID
/// vide (`sub_operations`), parce que l'identifiant nomme l'écriture de la
/// banque et qu'une ventilation n'en est pas une. Ce qui vaut à la création
/// vaut ici.
pub fn set_fitid(conn: &Connection, id: i64, value: &str) -> Result<bool> {
    let touched = conn.execute(
        "UPDATE Operation SET FitID = ?1 WHERE IDOperation = ?2",
        rusqlite::params![value.trim(), id],
    )?;
    Ok(touched == 1)
}

/// Marks operations as pointed — the `Base_point` button of F02, which needs
/// no fiche (04_SPECIFICATIONS_FENETRES.md, « pointage rapide de la
/// sélection »).
///
/// **The clearing date written is the operation's own date** (Fabrice,
/// 26/07/2026). It is what his own records hold: on the capture of F03 the two
/// dates are the same day.
///
/// **On ne pointe que ce qui n'est pas pointé, et l'on ne touche jamais à une
/// date déjà là** (Fabrice, 25/08/2026).
///
/// Le bouton réécrivait `DatePointage = Date` sur toute la sélection, les
/// lignes déjà pointées comprises. Une opération du 28/07 que la banque a
/// passée le 02/08 perdait son 02/08 dès qu'on repointait le mois par
/// précaution — et repointer par précaution est justement ce qu'on fait. La
/// vraie date bancaire était détruite sans que rien ne le dise.
///
/// Deux règles, donc. Une opération déjà pointée est laissée telle quelle :
/// elle n'entre même pas dans le compte rendu. Et pour celles que l'on pointe,
/// la date de l'opération n'est posée **que là où le champ est vide** ; s'il
/// porte déjà quelque chose, cela reste — « c'est à l'utilisateur de prendre
/// ses responsabilités, s'il met n'importe quoi dans ses dates c'est son
/// problème ».
///
/// **A child is pointed through its mother.** A status does not belong to a
/// sub-operation — `sync_from_parent` pushes the mother's onto every one of
/// her children after each write — so pointing a selected child means pointing
/// the operation it ventilates, which then hands the status and the date back
/// down. Anything else would be undone at the next recomputation.
///
/// Returns how many top-level operations were pointed, each counted once
/// however many of its lines were selected.
pub fn point(conn: &Connection, ids: &[i64]) -> Result<usize> {
    const POINTED: i64 = 1;

    let mut mothers: Vec<i64> = Vec::new();
    for id in ids {
        let found: Option<(i64, i64)> = conn
            .query_row(
                "SELECT IDOperationParent, IDCompte FROM Operation WHERE IDOperation = ?1",
                [id],
                |row| Ok((row.get(0)?, row.get(1)?)),
            )
            .ok();
        let Some((parent_id, _)) = found else { continue };
        let mother = if parent_id == 0 { *id } else { parent_id };
        if !mothers.contains(&mother) {
            mothers.push(mother);
        }
    }

    let mut pointed = 0;
    for mother in mothers {
        // `IDStatutOperation <> 1` fait tout le travail : une opération déjà
        // pointée n'est pas touchée, et `changed == 0` la fait sortir du
        // compte rendu. La date, elle, n'est posée que si le champ est vide.
        let changed = conn.execute(
            "UPDATE Operation
                SET IDStatutOperation = ?1,
                    DatePointage = CASE
                        WHEN DatePointage IS NULL OR DatePointage = '' THEN Date
                        ELSE DatePointage
                    END
              WHERE IDOperation = ?2 AND IDStatutOperation <> ?1",
            [POINTED, mother],
        )?;
        if changed == 0 {
            continue;
        }
        pointed += 1;
        // Her children take her status and her dates, and the balances move:
        // what was planned or committed is now in the bank.
        if let Some(account) = account_of(conn, mother)? {
            crate::sub_operations::after_change(conn, mother, account)?;
        }
    }
    Ok(pointed)
}

/// **Change le statut d'une opération depuis la liste** — la colonne « Statut
/// opération » de F02 (Fabrice, 01/10/2026).
///
/// Mêmes règles de date que le bouton Pointer, et pour la même raison : une
/// date de pointage déjà posée n'est jamais touchée.
///
/// * Passer à **pointé** pose la date de l'opération **si et seulement si** la
///   date de pointage est vide — une opération pointée doit en porter une.
/// * Passer à **engagé** ou **prévu** laisse la date telle qu'elle est ; elle
///   s'affiche alors en gris, comme toute date de pointage d'une opération
///   non pointée.
///
/// **Une sous-opération n'a pas de statut à elle** : elle porte celui de sa
/// mère, que `sync_from_parent` lui recopie après chaque écriture. Un statut
/// posé sur une fille serait défait au recalcul suivant, donc on le refuse
/// ici, comme la liste refuse déjà de l'offrir.
///
/// Rend `false` quand rien n'a changé : opération introuvable, sous-opération,
/// statut inconnu, ou statut déjà en place.
pub fn set_status(conn: &Connection, id: i64, status_id: i64) -> Result<bool> {
    const POINTED: i64 = 1;

    let known: bool = conn
        .query_row(
            "SELECT EXISTS(SELECT 1 FROM StatutOperation WHERE IDStatutOperation = ?1)",
            [status_id],
            |row| row.get(0),
        )?;
    if !known {
        return Ok(false);
    }
    let parent_id: Option<i64> = conn
        .query_row(
            "SELECT IDOperationParent FROM Operation WHERE IDOperation = ?1",
            [id],
            |row| row.get(0),
        )
        .ok();
    if parent_id != Some(0) {
        return Ok(false);
    }

    let changed = conn.execute(
        "UPDATE Operation
            SET IDStatutOperation = ?1,
                DatePointage = CASE
                    WHEN ?1 = ?3 AND (DatePointage IS NULL OR DatePointage = '') THEN Date
                    ELSE DatePointage
                END
          WHERE IDOperation = ?2 AND IDStatutOperation <> ?1",
        [status_id, id, POINTED],
    )?;
    if changed == 0 {
        return Ok(false);
    }
    // Ses filles prennent son statut, et les soldes bougent.
    if let Some(account) = account_of(conn, id)? {
        crate::sub_operations::after_change(conn, id, account)?;
    }
    Ok(true)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database::schema;

    fn database() -> Connection {
        let conn = Connection::open_in_memory().expect("base en mémoire");
        schema::migrate(&conn).expect("schéma");
        crate::database::seed::seed_initial_data(&conn).expect("valeurs initiales");
        conn.execute(
            "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte, IDBanques)
             VALUES (1, 'CCP', 1, 1)",
            [],
        )
        .expect("compte");
        conn
    }

    fn add(conn: &Connection, id: i64, label: &str, date: &str, amount: i64, parent: i64) {
        add_with_status(conn, id, label, date, amount, parent, 1);
    }

    fn add_with_status(
        conn: &Connection,
        id: i64,
        label: &str,
        date: &str,
        amount: i64,
        parent: i64,
        status: i64,
    ) {
        conn.execute(
            "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte,
                                    IDStatutOperation, IDOperationParent, IDCategorie)
             VALUES (?1, ?2, ?3, ?4, 1, ?6, ?5, 1)",
            rusqlite::params![id, label, date, amount, parent, status],
        )
        .expect("opération");
    }

    fn day(year: i32, month: u32, day: u32) -> NaiveDate {
        NaiveDate::from_ymd_opt(year, month, day).expect("date")
    }

    #[test]
    fn the_period_bounds_include_their_own_days() {
        let conn = database();
        add(&conn, 1, "Avant", "2025-12-31", -1_000_000, 0);
        add(&conn, 2, "Premier jour", "2026-01-01", -2_000_000, 0);
        add(&conn, 3, "Dernier jour", "2026-01-31", -3_000_000, 0);
        add(&conn, 4, "Après", "2026-02-01", -4_000_000, 0);

        let trees = list_for_account(&conn, 1, day(2026, 1, 1), day(2026, 1, 31), None, None)
            .expect("liste");
        let labels: Vec<&str> = trees.iter().map(|t| t.parent.label.as_str()).collect();
        assert_eq!(labels, vec!["Premier jour", "Dernier jour"]);
    }

    /// The trap the author warned about: children belong under their mother,
    /// they are not a second flat list.
    #[test]
    fn children_come_with_their_mother_and_only_with_her() {
        let conn = database();
        add(&conn, 1, "Courses", "2026-01-05", -100_000_000, 0);
        add(&conn, 2, "Alimentation", "2026-01-05", -60_000_000, 1);
        add(&conn, 3, "Ménager", "2026-01-05", -40_000_000, 1);
        add(&conn, 4, "Essence", "2026-01-06", -50_000_000, 0);

        let trees = list_for_account(&conn, 1, day(2026, 1, 1), day(2026, 1, 31), None, None)
            .expect("liste");
        assert_eq!(trees.len(), 2, "deux mères, pas quatre lignes");
        assert!(trees[0].has_children());
        assert_eq!(trees[0].children.len(), 2);
        assert!(!trees[1].has_children(), "pas de « + » sans enfant");

        // And the totals count the mothers alone: a ventilation splits an
        // amount that is already counted.
        let totals = totals(&trees);
        assert_eq!(totals.debit, -150_000_000);
        assert_eq!(totals.credit, 0);
        assert_eq!(totals.total, -150_000_000);
    }

    #[test]
    fn debits_and_credits_are_added_up_separately() {
        let conn = database();
        add(&conn, 1, "Salaire", "2026-01-28", 2_216_710_000, 0);
        add(&conn, 2, "Courses", "2026-01-05", -33_360_000, 0);
        let trees = list_for_account(&conn, 1, day(2026, 1, 1), day(2026, 1, 31), None, None)
            .expect("liste");
        let totals = totals(&trees);
        assert_eq!(totals.credit, 2_216_710_000);
        assert_eq!(totals.debit, -33_360_000);
        assert_eq!(totals.total, 2_183_350_000);
    }

    /// The author's ruling of 25/07/2026: the mother takes her daughters.
    #[test]
    fn deleting_a_mother_takes_her_daughters_and_counts_them_once() {
        let mut conn = database();
        add(&conn, 1, "Courses", "2026-01-05", -100_000_000, 0);
        add(&conn, 2, "Alimentation", "2026-01-05", -60_000_000, 1);
        add(&conn, 3, "Ménager", "2026-01-05", -40_000_000, 1);
        add(&conn, 4, "Essence", "2026-01-06", -50_000_000, 0);

        // The mother and one of her daughters, selected together.
        let gone = delete(&mut conn, &[1, 2]).expect("suppression");
        assert_eq!(gone, 3, "la mère et ses deux filles, comptées une fois");

        let left: i64 = conn
            .query_row("SELECT COUNT(*) FROM Operation", [], |row| row.get(0))
            .expect("reste");
        assert_eq!(left, 1);
    }

    /// The combos of the list write here. A mother hands her classification
    /// down to her Complément; a child changes alone.
    #[test]
    fn a_combo_of_the_list_changes_one_nomenclature_of_one_operation() {
        use crate::nomenclatures::Nomenclature;
        let conn = database();
        add(&conn, 1, "Courses", "2026-01-05", -100_000_000, 0);
        add(&conn, 2, "Alimentation", "2026-01-05", -60_000_000, 1);

        assert!(set_nomenclature(&conn, 2, Nomenclature::Category, 7).expect("changement"));
        let category: i64 = conn
            .query_row("SELECT IDCategorie FROM Operation WHERE IDOperation = 2", [], |r| r.get(0))
            .expect("relecture");
        assert_eq!(category, 7, "la fille change seule");

        let mother: i64 = conn
            .query_row("SELECT IDCategorie FROM Operation WHERE IDOperation = 1", [], |r| r.get(0))
            .expect("relecture");
        assert_eq!(mother, 1, "et sa mère n'a pas bougé");

        // A nomenclature an operation does not carry is refused rather than
        // written into a column that does not exist.
        assert!(!set_nomenclature(&conn, 1, Nomenclature::Bank, 3).expect("refus"));
        assert!(!set_nomenclature(&conn, 99, Nomenclature::Category, 3).expect("inexistante"));
    }

    /// The Filtre menu of F02: pointed, committed, planned — 1, 2 and 3
    /// (02_BASE_DE_DONNEES.md §5.2). It keeps mothers, and their children
    /// come with them.
    #[test]
    fn the_status_filter_keeps_the_mothers_it_is_asked_for_and_their_children() {
        let conn = database();
        add_with_status(&conn, 1, "Pointée", "2026-01-05", -10_000_000, 0, 1);
        add_with_status(&conn, 2, "Une fille", "2026-01-05", -4_000_000, 1, 1);
        add_with_status(&conn, 3, "Engagée", "2026-01-06", -20_000_000, 0, 2);
        add_with_status(&conn, 4, "Prévue", "2026-01-07", -30_000_000, 0, 3);

        let labels = |status: Option<i64>| -> Vec<String> {
            list_for_account(&conn, 1, day(2026, 1, 1), day(2026, 1, 31), status, None)
                .expect("liste")
                .into_iter()
                .map(|tree| tree.parent.label)
                .collect()
        };

        assert_eq!(labels(None), vec!["Pointée", "Engagée", "Prévue"]);
        assert_eq!(labels(Some(1)), vec!["Pointée"]);
        assert_eq!(labels(Some(2)), vec!["Engagée"]);
        assert_eq!(labels(Some(3)), vec!["Prévue"]);

        // A mother kept by the filter keeps her children.
        let trees = list_for_account(&conn, 1, day(2026, 1, 1), day(2026, 1, 31), Some(1), None)
            .expect("liste");
        assert_eq!(trees[0].children.len(), 1);

        // And the totals follow what is shown.
        assert_eq!(totals(&trees).debit, -10_000_000);
    }

    /// Fabrice, 05/10/2026 : « en dessous de Filtre Statut on va rajouter
    /// Filtre Vérification […] On pourra combiner, choisir opérations pointées
    /// et filtre À vérifier. » Les deux filtres s'additionnent, les mères
    /// gardées gardent leurs filles, et les totaux suivent.
    #[test]
    fn le_filtre_de_verification_se_combine_avec_celui_du_statut() {
        let conn = database();
        // Pointée et vérifiée (le défaut), avec une fille.
        add_with_status(&conn, 1, "Pointée vérifiée", "2026-01-05", -10_000_000, 0, 1);
        add_with_status(&conn, 2, "Une fille", "2026-01-05", -4_000_000, 1, 1);
        add_with_status(&conn, 3, "Pointée à vérifier", "2026-01-06", -20_000_000, 0, 1);
        add_with_status(&conn, 4, "Engagée à vérifier", "2026-01-07", -30_000_000, 0, 2);
        add_with_status(&conn, 5, "Prévue douteuse", "2026-01-08", -40_000_000, 0, 3);
        add_with_status(&conn, 6, "Engagée abîmée", "2026-01-09", -50_000_000, 0, 2);
        for (id, verification) in [(3, 1), (4, 1), (5, 3), (6, 99)] {
            conn.execute(
                "UPDATE Operation SET IDVerification = ?2 WHERE IDOperation = ?1",
                [id, verification],
            )
            .unwrap();
        }

        let labels = |status: Option<i64>, verification: Option<i64>| -> Vec<String> {
            list_for_account(&conn, 1, day(2026, 1, 1), day(2026, 1, 31), status, verification)
                .expect("liste")
                .into_iter()
                .map(|tree| tree.parent.label)
                .collect()
        };

        assert_eq!(labels(None, None).len(), 5);
        // La vérification seule. Une valeur hors de la liste est « à vérifier ».
        assert_eq!(
            labels(None, Some(1)),
            vec!["Pointée à vérifier", "Engagée à vérifier", "Engagée abîmée"]
        );
        assert_eq!(labels(None, Some(2)), vec!["Pointée vérifiée"]);
        assert_eq!(labels(None, Some(3)), vec!["Prévue douteuse"]);
        assert!(labels(None, Some(4)).is_empty());
        // Les deux ensemble : pointées **et** à vérifier.
        assert_eq!(labels(Some(1), Some(1)), vec!["Pointée à vérifier"]);
        assert_eq!(labels(Some(2), Some(1)), vec!["Engagée à vérifier", "Engagée abîmée"]);
        assert!(labels(Some(3), Some(1)).is_empty());
        // Le statut seul n'a pas changé.
        assert_eq!(labels(Some(1), None), vec!["Pointée vérifiée", "Pointée à vérifier"]);

        // Une mère gardée garde sa fille, et les totaux suivent ce qu'on voit.
        let trees =
            list_for_account(&conn, 1, day(2026, 1, 1), day(2026, 1, 31), Some(1), Some(2))
                .expect("liste");
        assert_eq!(trees.len(), 1);
        assert_eq!(trees[0].children.len(), 1);
        assert_eq!(totals(&trees).debit, -10_000_000);
    }

    #[test]
    fn an_operation_says_which_account_it_belongs_to() {
        let conn = database();
        add(&conn, 1, "Courses", "2026-01-05", -1_000_000, 0);
        assert_eq!(account_of(&conn, 1).expect("compte"), Some(1));
        assert_eq!(account_of(&conn, 99).expect("compte"), None);
    }

    // --- The fiche opération (F03) --------------------------------------

    const EURO: i64 = 1_000_000;

    fn typed(label: &str, amount: i64, direction: Direction) -> OperationInput {
        OperationInput {
            label: label.to_string(),
            payment_reference: String::new(),
            date: NaiveDate::from_ymd_opt(2026, 1, 21),
            clearing_date: NaiveDate::from_ymd_opt(2026, 1, 21),
            direction,
            amount,
            status_id: 1,
            category_id: 8,
            assignment_id: 1,
            payment_mode_id: 6,
            payee_id: 3,
            project_id: 0,
            verification_id: None,
            comment: None,
        }
    }

    /// The window's own list of statuses: pointed, committed, planned.
    #[test]
    fn the_fiche_offers_the_three_statuses_of_the_database() {
        let conn = database();
        let statuses = statuses(&conn).expect("statuts");
        assert_eq!(statuses.len(), 3);
        assert_eq!(statuses[0].id, 1);
        assert!(!statuses[0].label.is_empty());
    }

    /// The author's rule, held by the core rather than by the window: the
    /// amount is typed positive and the Débit/Crédit choice gives it its sign.
    #[test]
    fn the_amount_is_typed_positive_and_the_type_gives_it_its_sign() {
        let conn = database();
        let debit = create(&conn, 1, &typed("ACHAT", 9 * EURO, Direction::Debit)).expect("écriture");
        let credit =
            create(&conn, 1, &typed("VIREMENT", 9 * EURO, Direction::Credit)).expect("écriture");

        assert_eq!(get(&conn, debit).expect("relecture").unwrap().amount, -9 * EURO);
        assert_eq!(get(&conn, credit).expect("relecture").unwrap().amount, 9 * EURO);

        // And whatever sign the magnitude arrives with, what is written is
        // always the same thing: its absolute value, times −1 for a debit and
        // times 1 for a credit (Fabrice's rule, 26/07/2026). The window is
        // what keeps the type in step with a minus the user types; here there
        // is only ever one interpretation.
        let signed_credit = create(&conn, 1, &typed("ACHAT", -9 * EURO, Direction::Credit))
            .expect("écriture");
        assert_eq!(
            get(&conn, signed_credit).expect("relecture").unwrap().amount,
            9 * EURO
        );
        let signed_debit = create(&conn, 1, &typed("ACHAT", -9 * EURO, Direction::Debit))
            .expect("écriture");
        assert_eq!(
            get(&conn, signed_debit).expect("relecture").unwrap().amount,
            -9 * EURO
        );

        // The same rule on a change: a credit turned into a debit does not
        // keep a positive amount behind.
        assert!(update(&conn, credit, &typed("VIREMENT", 9 * EURO, Direction::Debit))
            .expect("modif"));
        assert_eq!(get(&conn, credit).expect("relecture").unwrap().amount, -9 * EURO);
    }

    /// What the fiche reads is the record, whole: the reserve is filled from
    /// this and from nothing else.
    #[test]
    fn the_fiche_reads_back_every_field_it_wrote() {
        let conn = database();
        let mut input = typed("VIREMENT DE COMPLEMENTAIRE SANTE", 9 * EURO, Direction::Credit);
        input.payment_reference = "REF-2026-01".to_string();
        input.comment = Some("Remboursement mutuelle".to_string());
        let id = create(&conn, 1, &input).expect("écriture");

        let read = get(&conn, id).expect("relecture").expect("l'opération");
        assert_eq!(read.label, "VIREMENT DE COMPLEMENTAIRE SANTE");
        assert_eq!(read.payment_reference, "REF-2026-01");
        assert_eq!(read.date, NaiveDate::from_ymd_opt(2026, 1, 21));
        assert_eq!(read.clearing_date, NaiveDate::from_ymd_opt(2026, 1, 21));
        assert_eq!(read.amount, 9 * EURO);
        assert_eq!(read.status_id, 1);
        assert_eq!(read.category_id, 8);
        assert_eq!(read.assignment_id, 1);
        assert_eq!(read.payment_mode_id, 6);
        assert_eq!(read.payee_id, 3);
        assert_eq!(read.project_id, 0);
        assert_eq!(read.comment, "Remboursement mutuelle");
        assert_eq!(read.account_id, 1);
        assert_eq!(read.parent_id, 0);
        assert_eq!(read.child_count, 0);
        assert_eq!(read.attachment_count, 0);
        assert_eq!(read.check_number, "");

        // An operation that is not there is not an error: it is a fiche with
        // nothing to show.
        assert_eq!(get(&conn, 404).expect("relecture"), None);
    }

    /// Writing an operation moves the account's balances at once.
    #[test]
    fn writing_an_operation_moves_the_balances_of_its_account() {
        let conn = database();
        let id = create(&conn, 1, &typed("ACHAT", 100 * EURO, Direction::Debit)).expect("écriture");
        let bank = |conn: &Connection| -> i64 {
            conn.query_row("SELECT SoldeBanque FROM Compte WHERE IDCompte = 1", [], |r| {
                r.get(0)
            })
            .expect("solde")
        };
        assert_eq!(bank(&conn), -100 * EURO);

        assert!(update(&conn, id, &typed("ACHAT", 30 * EURO, Direction::Debit)).expect("modif"));
        assert_eq!(bank(&conn), -30 * EURO);
    }

    /// The trap of the fiche: a mother whose amount changes has a Complément
    /// that no longer closes her ventilation.
    #[test]
    fn changing_a_mothers_amount_redoes_her_complement() {
        let conn = database();
        let mother =
            create(&conn, 1, &typed("RETRAIT", 100 * EURO, Direction::Debit)).expect("écriture");
        crate::sub_operations::create(
            &conn,
            mother,
            &crate::sub_operations::SubOperationInput {
                label: "Courses".to_string(),
                direction: Direction::Debit,
                amount: 30 * EURO,
                category_id: 1,
                assignment_id: 1,
                payee_id: 0,
                project_id: 0,
                comment: None,
            },
        )
        .expect("ventilation");

        let complement = |conn: &Connection| -> i64 {
            conn.query_row(
                "SELECT Montant FROM Operation WHERE IDOperationParent = ?1 AND EstComplement = 1",
                [mother],
                |r| r.get(0),
            )
            .expect("complément")
        };
        assert_eq!(complement(&conn), -70 * EURO);

        assert!(update(&conn, mother, &typed("RETRAIT", 120 * EURO, Direction::Debit))
            .expect("modif"));
        assert_eq!(complement(&conn), -90 * EURO, "le complément suit sa mère");
    }

    /// And her status, her mode and her two dates go down to her children —
    /// the original pushes them after every write.
    #[test]
    fn changing_a_mothers_status_pushes_it_onto_her_children() {
        let conn = database();
        let mother =
            create(&conn, 1, &typed("RETRAIT", 100 * EURO, Direction::Debit)).expect("écriture");
        crate::sub_operations::create(
            &conn,
            mother,
            &crate::sub_operations::SubOperationInput {
                label: "Courses".to_string(),
                direction: Direction::Debit,
                amount: 30 * EURO,
                category_id: 1,
                assignment_id: 1,
                payee_id: 0,
                project_id: 0,
                comment: None,
            },
        )
        .expect("ventilation");

        let mut planned = typed("RETRAIT", 100 * EURO, Direction::Debit);
        planned.status_id = 3;
        planned.date = NaiveDate::from_ymd_opt(2026, 2, 10);
        assert!(update(&conn, mother, &planned).expect("modif"));

        let mut statement = conn
            .prepare(
                "SELECT IDStatutOperation, Date FROM Operation WHERE IDOperationParent = ?1",
            )
            .expect("lecture");
        let rows: Vec<(i64, String)> = statement
            .query_map([mother], |r| Ok((r.get(0)?, r.get(1)?)))
            .expect("lecture")
            .collect::<Result<_>>()
            .expect("lecture");
        assert_eq!(rows.len(), 2, "la sous-opération et son complément");
        for row in rows {
            assert_eq!(row, (3, "2026-02-10".to_string()));
        }
    }

    /// A comment lives with its operation, and is removed by emptying it.
    #[test]
    fn the_post_it_of_the_fiche_writes_and_removes_the_comment() {
        let conn = database();
        let mut input = typed("ACHAT", 9 * EURO, Direction::Debit);
        input.comment = Some("Payé en deux fois".to_string());
        let id = create(&conn, 1, &input).expect("écriture");
        assert_eq!(get(&conn, id).unwrap().unwrap().comment, "Payé en deux fois");

        input.comment = Some(String::new());
        assert!(update(&conn, id, &input).expect("modif"));
        assert_eq!(get(&conn, id).unwrap().unwrap().comment, "");
    }

    /// The `Base_point` button: the status becomes « pointé » and the clearing
    /// date becomes the operation's own date (Fabrice, 26/07/2026).
    #[test]
    fn quick_pointing_stamps_the_operations_own_date() {
        let conn = database();
        let mut planned = typed("LOYER", 700 * EURO, Direction::Debit);
        planned.status_id = 3;
        planned.clearing_date = None;
        planned.date = NaiveDate::from_ymd_opt(2026, 2, 3);
        let id = create(&conn, 1, &planned).expect("écriture");

        assert_eq!(point(&conn, &[id]).expect("pointage"), 1);

        let read = get(&conn, id).expect("relecture").expect("l'opération");
        assert_eq!(read.status_id, 1);
        assert_eq!(read.clearing_date, NaiveDate::from_ymd_opt(2026, 2, 3));
        assert_eq!(read.date, read.clearing_date, "les deux mêmes jours");
    }

    /// A child has no status of its own: pointing it points its mother, and
    /// the mother hands it back down. Selecting both counts one operation.
    #[test]
    fn pointing_a_child_points_the_operation_it_ventilates() {
        let conn = database();
        let mut planned = typed("RETRAIT", 100 * EURO, Direction::Debit);
        planned.status_id = 3;
        let mother = create(&conn, 1, &planned).expect("écriture");
        let child = crate::sub_operations::create(
            &conn,
            mother,
            &crate::sub_operations::SubOperationInput {
                label: "Courses".to_string(),
                direction: Direction::Debit,
                amount: 30 * EURO,
                category_id: 1,
                assignment_id: 1,
                payee_id: 0,
                project_id: 0,
                comment: None,
            },
        )
        .expect("ventilation")
        .expect("la fille");

        // The mother and her child selected together: one operation pointed.
        assert_eq!(point(&conn, &[child, mother]).expect("pointage"), 1);

        assert_eq!(get(&conn, mother).unwrap().unwrap().status_id, 1);
        assert_eq!(get(&conn, child).unwrap().unwrap().status_id, 1);
        // The Complément too — it is a child like the others.
        let statuses: Vec<i64> = conn
            .prepare("SELECT IDStatutOperation FROM Operation WHERE IDOperationParent = ?1")
            .unwrap()
            .query_map([mother], |r| r.get(0))
            .unwrap()
            .collect::<Result<_>>()
            .unwrap();
        assert_eq!(statuses, vec![1, 1]);
    }

    #[test]
    fn pointing_something_that_is_not_there_points_nothing() {
        let conn = database();
        assert_eq!(point(&conn, &[404]).expect("pointage"), 0);
    }

    /// **Une opération déjà pointée n'est pas repointée** (Fabrice,
    /// 25/08/2026) : sa date de pointage est celle de la banque, et repointer
    /// un mois par précaution la détruisait.
    #[test]
    fn pointing_leaves_what_is_already_pointed_alone() {
        let conn = database();
        let mut passed = typed("SALAIRE", 2_000 * EURO, Direction::Credit);
        passed.status_id = 1;
        passed.date = NaiveDate::from_ymd_opt(2026, 7, 28);
        // La banque l'a passée cinq jours plus tard : c'est cette date-là qui
        // vaut, et c'est elle que le bouton écrasait.
        passed.clearing_date = NaiveDate::from_ymd_opt(2026, 8, 2);
        let id = create(&conn, 1, &passed).expect("écriture");

        assert_eq!(
            point(&conn, &[id]).expect("pointage"),
            0,
            "rien à pointer : elle l'est déjà"
        );

        let read = get(&conn, id).expect("relecture").expect("l'opération");
        assert_eq!(read.clearing_date, NaiveDate::from_ymd_opt(2026, 8, 2));
    }

    /// **Une date de pointage déjà là n'est jamais touchée** — même sur une
    /// opération que l'on pointe. « C'est à l'utilisateur de prendre ses
    /// responsabilités » (Fabrice, 25/08/2026).
    #[test]
    fn pointing_never_overwrites_a_clearing_date_that_is_there() {
        let conn = database();
        let mut planned = typed("ASSURANCE", 300 * EURO, Direction::Debit);
        planned.status_id = 3;
        planned.date = NaiveDate::from_ymd_opt(2026, 3, 15);
        planned.clearing_date = NaiveDate::from_ymd_opt(2026, 3, 18);
        let id = create(&conn, 1, &planned).expect("écriture");

        assert_eq!(point(&conn, &[id]).expect("pointage"), 1);

        let read = get(&conn, id).expect("relecture").expect("l'opération");
        assert_eq!(read.status_id, 1);
        assert_eq!(
            read.clearing_date,
            NaiveDate::from_ymd_opt(2026, 3, 18),
            "la date de l'utilisateur, pas celle de l'opération"
        );
    }

    #[test]
    fn passer_a_pointe_depuis_la_liste_pose_la_date_de_l_operation_si_vide() {
        let conn = database();
        let mut planned = typed("ASSURANCE", 300 * EURO, Direction::Debit);
        planned.status_id = 3;
        planned.date = NaiveDate::from_ymd_opt(2026, 3, 15);
        planned.clearing_date = None;
        let id = create(&conn, 1, &planned).expect("écriture");

        assert!(set_status(&conn, id, 1).expect("statut"));

        let read = get(&conn, id).expect("relecture").expect("l'opération");
        assert_eq!(read.status_id, 1);
        assert_eq!(read.clearing_date, NaiveDate::from_ymd_opt(2026, 3, 15));
    }

    #[test]
    fn le_statut_change_depuis_la_liste_ne_touche_jamais_une_date_deja_la() {
        let conn = database();
        let mut planned = typed("ASSURANCE", 300 * EURO, Direction::Debit);
        planned.status_id = 3;
        planned.date = NaiveDate::from_ymd_opt(2026, 3, 15);
        planned.clearing_date = NaiveDate::from_ymd_opt(2026, 3, 18);
        let id = create(&conn, 1, &planned).expect("écriture");

        assert!(set_status(&conn, id, 1).expect("pointé"));
        let read = get(&conn, id).expect("relecture").expect("l'opération");
        assert_eq!(read.clearing_date, NaiveDate::from_ymd_opt(2026, 3, 18));

        // Et dans l'autre sens : repasser à prévu ou engagé n'efface rien.
        assert!(set_status(&conn, id, 2).expect("engagé"));
        let read = get(&conn, id).expect("relecture").expect("l'opération");
        assert_eq!(read.status_id, 2);
        assert_eq!(read.clearing_date, NaiveDate::from_ymd_opt(2026, 3, 18));
    }

    #[test]
    fn le_statut_d_une_fille_ou_un_statut_inconnu_n_est_pas_ecrit() {
        let conn = database();
        add_with_status(&conn, 1, "COURSES", "2026-01-15", -100_000_000, 0, 3);
        add_with_status(&conn, 2, "Pain", "2026-01-15", -30_000_000, 1, 3);

        assert!(!set_status(&conn, 2, 1).expect("fille"), "une fille suit sa mère");
        assert!(!set_status(&conn, 1, 9).expect("inconnu"), "trois statuts, pas un de plus");
        assert!(!set_status(&conn, 1, 3).expect("même statut"), "rien à changer");
        assert!(!set_status(&conn, 404, 1).expect("absente"));
    }

    fn verification_of(conn: &Connection, id: i64) -> i64 {
        conn.query_row(
            "SELECT IDVerification FROM Operation WHERE IDOperation = ?1",
            [id],
            |row| row.get(0),
        )
        .expect("vérification")
    }

    #[test]
    fn une_operation_nait_verifiee() {
        let conn = database();
        let id = create(&conn, 1, &typed("COURSES", 30 * EURO, Direction::Debit)).expect("écriture");
        assert_eq!(verification_of(&conn, id), VERIFIED);
        assert_eq!(get(&conn, id).unwrap().unwrap().verification_id, VERIFIED);
        assert_eq!(verifications(&conn).unwrap().len(), 4);
    }

    #[test]
    fn la_fiche_ecrit_la_verification_et_ne_l_efface_pas_quand_elle_se_tait() {
        let conn = database();
        let mut doubtful = typed("PRELEVEMENT INCONNU", 12 * EURO, Direction::Debit);
        doubtful.verification_id = Some(3);
        let id = create(&conn, 1, &doubtful).expect("écriture");
        assert_eq!(verification_of(&conn, id), 3);

        // Un appelant qui ne parle pas de vérification — un virement, le
        // classement rapide — la laisse où elle est.
        assert!(update(&conn, id, &typed("PRELEVEMENT INCONNU", 12 * EURO, Direction::Debit)).unwrap());
        assert_eq!(verification_of(&conn, id), 3);

        // Une valeur hors de la liste n'est pas écrite.
        let mut absurd = typed("PRELEVEMENT INCONNU", 12 * EURO, Direction::Debit);
        absurd.verification_id = Some(42);
        assert!(update(&conn, id, &absurd).unwrap());
        assert_eq!(verification_of(&conn, id), 3);
    }

    #[test]
    fn la_verification_changee_depuis_la_liste_ne_touche_ni_statut_ni_date() {
        let conn = database();
        let mut planned = typed("ASSURANCE", 300 * EURO, Direction::Debit);
        planned.status_id = 3;
        planned.clearing_date = None;
        let id = create(&conn, 1, &planned).expect("écriture");

        assert!(set_verification(&conn, id, 4).expect("contestée"));
        let read = get(&conn, id).unwrap().unwrap();
        assert_eq!(read.verification_id, 4);
        assert_eq!(read.status_id, 3, "le statut appartient à la banque");
        assert_eq!(read.clearing_date, None);

        assert!(!set_verification(&conn, id, 4).expect("déjà là"), "rien à changer");
        assert!(!set_verification(&conn, id, 9).expect("inconnue"), "quatre valeurs, pas une de plus");
        assert!(!set_verification(&conn, 404, 1).expect("absente"));
    }

    /// Le menu du clic droit, pour le statut : une sélection, un statut, et
    /// les règles de date du bouton Pointer.
    #[test]
    fn une_selection_recoit_le_meme_statut_d_un_coup() {
        let mut conn = database();
        let planned = |label: &str, clearing: Option<NaiveDate>| {
            let mut input = typed(label, 50 * EURO, Direction::Debit);
            input.status_id = 3;
            input.date = NaiveDate::from_ymd_opt(2026, 3, 15);
            input.clearing_date = clearing;
            input
        };
        let empty = create(&conn, 1, &planned("SANS DATE", None)).unwrap();
        let dated =
            create(&conn, 1, &planned("AVEC DATE", NaiveDate::from_ymd_opt(2026, 3, 18))).unwrap();
        let mother = create(&conn, 1, &planned("VENTILEE", None)).unwrap();
        let child = crate::sub_operations::create(
            &conn,
            mother,
            &crate::sub_operations::SubOperationInput {
                label: "Part".to_string(),
                direction: Direction::Debit,
                amount: 20 * EURO,
                category_id: 8,
                assignment_id: 1,
                payee_id: 0,
                project_id: 0,
                comment: None,
            },
        )
        .unwrap()
        .expect("fille");
        let already = create(&conn, 1, &typed("DEJA POINTEE", 9 * EURO, Direction::Debit)).unwrap();
        let outside = create(&conn, 1, &planned("HORS SELECTION", None)).unwrap();

        // La fille vaut pour sa mère ; `already` est déjà pointée, 404 n'existe pas.
        let changed =
            set_status_many(&mut conn, &[empty, dated, child, already, 404], 1).unwrap();
        assert_eq!(changed, 3);

        let read = |conn: &Connection, id: i64| get(conn, id).unwrap().unwrap();
        assert_eq!(read(&conn, empty).status_id, 1);
        assert_eq!(
            read(&conn, empty).clearing_date,
            NaiveDate::from_ymd_opt(2026, 3, 15),
            "un champ vide reçoit la date de l'opération"
        );
        assert_eq!(
            read(&conn, dated).clearing_date,
            NaiveDate::from_ymd_opt(2026, 3, 18),
            "une date déjà là n'est pas touchée"
        );
        assert_eq!(read(&conn, mother).status_id, 1);
        assert_eq!(read(&conn, child).status_id, 1, "la fille suit sa mère");
        assert_eq!(read(&conn, outside).status_id, 3, "hors de la sélection");

        // Dans l'autre sens : le statut change, la date reste.
        assert_eq!(set_status_many(&mut conn, &[empty, dated], 2).unwrap(), 2);
        assert_eq!(read(&conn, empty).status_id, 2);
        assert_eq!(read(&conn, empty).clearing_date, NaiveDate::from_ymd_opt(2026, 3, 15));

        // Un statut inconnu ne change rien.
        assert_eq!(set_status_many(&mut conn, &[empty, outside], 9).unwrap(), 0);
        assert_eq!(read(&conn, outside).status_id, 3);
    }

    /// Le menu du clic droit : une sélection, une valeur. Une fille prise dans
    /// la sélection vaut pour sa mère, chaque mère compte une fois, et celle
    /// qui portait déjà la valeur ne compte pas.
    #[test]
    fn une_selection_recoit_la_meme_verification_d_un_coup() {
        let mut conn = database();
        let mother = create(&conn, 1, &typed("COURSES", 100 * EURO, Direction::Debit)).unwrap();
        let child = crate::sub_operations::create(
            &conn,
            mother,
            &crate::sub_operations::SubOperationInput {
                label: "Pain".to_string(),
                direction: Direction::Debit,
                amount: 30 * EURO,
                category_id: 8,
                assignment_id: 1,
                payee_id: 0,
                project_id: 0,
                comment: None,
            },
        )
        .unwrap()
        .expect("fille");
        let alone = create(&conn, 1, &typed("LOYER", 650 * EURO, Direction::Debit)).unwrap();
        let already = create(&conn, 1, &typed("EDF", 80 * EURO, Direction::Debit)).unwrap();
        let outside = create(&conn, 1, &typed("SALAIRE", 2000 * EURO, Direction::Credit)).unwrap();
        assert!(set_verification(&conn, already, 3).unwrap());
        let before: Vec<(i64, Option<String>)> = conn
            .prepare("SELECT IDStatutOperation, DatePointage FROM Operation ORDER BY IDOperation")
            .unwrap()
            .query_map([], |row| Ok((row.get(0)?, row.get(1)?)))
            .unwrap()
            .map(Result::unwrap)
            .collect();

        // La mère et sa fille sont toutes deux dans la sélection : une seule
        // opération. `already` porte déjà la valeur, 404 n'existe pas.
        let changed =
            set_verification_many(&mut conn, &[child, mother, alone, already, 404], 3).unwrap();
        assert_eq!(changed, 2);

        for id in [mother, child, alone, already] {
            assert_eq!(verification_of(&conn, id), 3, "opération {id}");
        }
        assert_eq!(verification_of(&conn, outside), VERIFIED, "hors de la sélection");

        // Une fille seule dans la sélection : c'est sa mère qui change.
        assert_eq!(set_verification_many(&mut conn, &[child], 4).unwrap(), 1);
        assert_eq!(verification_of(&conn, mother), 4);
        assert_eq!(verification_of(&conn, child), 4);

        // Une valeur hors de la liste ne change rien.
        assert_eq!(set_verification_many(&mut conn, &[alone, outside], 9).unwrap(), 0);
        assert_eq!(verification_of(&conn, alone), 3);

        let after: Vec<(i64, Option<String>)> = conn
            .prepare("SELECT IDStatutOperation, DatePointage FROM Operation ORDER BY IDOperation")
            .unwrap()
            .query_map([], |row| Ok((row.get(0)?, row.get(1)?)))
            .unwrap()
            .map(Result::unwrap)
            .collect();
        assert_eq!(before, after, "ni le statut ni la date de pointage n'ont bougé");
    }

    #[test]
    fn une_fille_suit_la_verification_de_sa_mere() {
        let conn = database();
        let mother = create(&conn, 1, &typed("COURSES", 100 * EURO, Direction::Debit)).unwrap();
        let child = crate::sub_operations::create(
            &conn,
            mother,
            &crate::sub_operations::SubOperationInput {
                label: "Pain".to_string(),
                direction: Direction::Debit,
                amount: 30 * EURO,
                category_id: 8,
                assignment_id: 1,
                payee_id: 0,
                project_id: 0,
                comment: None,
            },
        )
        .unwrap()
        .expect("fille");

        assert!(!set_verification(&conn, child, 3).unwrap(), "une fille n'a pas la sienne");
        assert!(set_verification(&conn, mother, 3).unwrap());
        let children: Vec<i64> = conn
            .prepare("SELECT IDVerification FROM Operation WHERE IDOperationParent = ?1")
            .unwrap()
            .query_map([mother], |row| row.get(0))
            .unwrap()
            .map(Result::unwrap)
            .collect();
        assert!(children.len() >= 2, "la fille et le Complément");
        assert!(children.iter().all(|value| *value == 3), "{children:?}");
    }

    #[test]
    fn an_operation_that_no_longer_exists_is_not_modified() {
        let conn = database();
        assert!(!update(&conn, 404, &typed("X", EURO, Direction::Debit)).expect("refus"));
    }

    #[test]
    fn un_fitid_se_lit_et_se_reecrit() {
        let conn = database();
        add(&conn, 1, "RETRAIT", "2026-01-15", -1_000_000, 0);
        assert_eq!(fitid(&conn, 1).expect("lecture"), Some(String::new()));

        assert!(set_fitid(&conn, 1, "P_GDYTLL29").expect("écriture"));
        assert_eq!(
            fitid(&conn, 1).expect("relecture"),
            Some("P_GDYTLL29".to_string())
        );
    }

    #[test]
    fn un_fitid_vide_efface_lidentifiant() {
        let conn = database();
        add(&conn, 1, "RETRAIT", "2026-01-15", -1_000_000, 0);
        set_fitid(&conn, 1, "P_GDYTLL29").expect("écriture");

        // Supprimer, c'est réécrire avec rien : c'est ainsi que « pas de
        // FITID » s'écrit partout ailleurs dans la base.
        assert!(set_fitid(&conn, 1, "").expect("effacement"));
        assert_eq!(fitid(&conn, 1).expect("relecture"), Some(String::new()));
    }

    #[test]
    fn un_fitid_perd_ses_espaces_de_bordure() {
        let conn = database();
        add(&conn, 1, "RETRAIT", "2026-01-15", -1_000_000, 0);

        // Un identifiant collé depuis un relevé traîne souvent une espace.
        // Elle ne se voit pas et suffirait à ce que le même FITID ne soit plus
        // reconnu au prochain import.
        set_fitid(&conn, 1, "  P_GDYTLL29 ").expect("écriture");
        assert_eq!(
            fitid(&conn, 1).expect("relecture"),
            Some("P_GDYTLL29".to_string())
        );
    }

    #[test]
    fn une_operation_absente_na_pas_de_fitid_et_ne_sen_laisse_pas_donner() {
        let conn = database();
        assert_eq!(fitid(&conn, 404).expect("lecture"), None);
        assert!(!set_fitid(&conn, 404, "PEU IMPORTE").expect("écriture"));
    }
}
