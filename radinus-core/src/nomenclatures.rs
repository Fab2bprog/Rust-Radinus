//! The seven user-editable nomenclatures, and the two rules that govern them.
//!
//! Dossier reference: `02_BASE_DE_DONNEES.md` §7 rules 2, 5 and 6,
//! `PLAN_ACTION.md` Phase 2.3. **Ported from the author's own WinDev source**
//! (`Code liste categorie.txt`, procedure `Enreg_Supprimer`), which is the
//! authority for the deletion rule:
//!
//! 1. read the element's label, and give up if it no longer exists;
//! 2. **ask the user once**, and only if operations actually reference it —
//!    the question is the author's own wording, reproduced word for word in
//!    `i18n::nomenclature_delete_confirmation`;
//! 3. on "no", abandon completely: nothing is modified at all;
//! 4. on "yes", reset the reference to `0` (« Non précisé ») everywhere, then
//!    delete the element itself.
//!
//! The core cannot ask a question, so the decision is split in two: the
//! caller reads [`usage`] to know whether to ask and what to ask, and calls
//! [`delete_and_reassign`] once it has the answer. That keeps the business
//! rule here and the dialog in the interface, where it belongs
//! (08_ARCHITECTURE.md).
//!
//! **One deliberate addition, and it is the dossier's own proposal, not
//! mine**: 02_BASE_DE_DONNEES.md §7 rule 5 suggests extending the reset to
//! the `CalOpPeriodique` rules, which the original leaves untouched. It is
//! applied here — a recurring rule pointing at a deleted category would
//! otherwise keep generating operations with a dangling reference, which is
//! worse than "Non précisé". The dossier marks it "proposée", so it is
//! flagged in `PLAN_ACTION.md` for the author to confirm or refuse.
//!
//! Sorting (§7 rule 6) uses the collation measured on the author's archive —
//! see [`crate::text::french_sort_key`].

use crate::domain::{Category, NamedItem};
use crate::text::{french_sort_key, same_name_key};
use rusqlite::{Connection, Result};

/// The `0` every optional nomenclature link uses for "Non précisé"
/// (02_BASE_DE_DONNEES.md §7 rule 2). Never a real row.
pub const UNSPECIFIED: i64 = 0;

/// A user-editable nomenclature (PLAN_ACTION.md Phase 3.2 lists the seven).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Nomenclature {
    Category,
    Assignment,
    PaymentMode,
    Payee,
    Project,
    BudgetLine,
    Bank,
}

/// Every nomenclature, in the order the Nomenclatures menu lists them.
pub const ALL: [Nomenclature; 7] = [
    Nomenclature::Bank,
    Nomenclature::Assignment,
    Nomenclature::Category,
    Nomenclature::PaymentMode,
    Nomenclature::Project,
    Nomenclature::Payee,
    Nomenclature::BudgetLine,
];

impl Nomenclature {
    /// Stable name this nomenclature travels under — in an IPC call, a window
    /// label, an event name, a page address. English like every other
    /// identifier of the port; the French names stay where they belong, in
    /// the database and on the screen.
    pub fn key(self) -> &'static str {
        match self {
            Nomenclature::Category => "category",
            Nomenclature::Assignment => "assignment",
            Nomenclature::PaymentMode => "payment-mode",
            Nomenclature::Payee => "payee",
            Nomenclature::Project => "project",
            Nomenclature::BudgetLine => "budget-line",
            Nomenclature::Bank => "bank",
        }
    }

    /// The nomenclature that goes by `key`, or `None` — a window may only ask
    /// for one that exists.
    pub fn from_key(key: &str) -> Option<Self> {
        ALL.into_iter().find(|kind| kind.key() == key)
    }

    /// Whether elements of this nomenclature carry a budget line of their own.
    /// `Categorie` is the only one (02_BASE_DE_DONNEES.md §3.10), and the only
    /// reason the shared fiche ever shows a second field.
    pub fn has_budget_line(self) -> bool {
        matches!(self, Nomenclature::Category)
    }

    /// SQL table holding this nomenclature.
    pub fn table(self) -> &'static str {
        match self {
            Nomenclature::Category => "Categorie",
            Nomenclature::Assignment => "Affectation",
            Nomenclature::PaymentMode => "ModeOperation",
            Nomenclature::Payee => "Tiers",
            Nomenclature::Project => "Projets",
            Nomenclature::BudgetLine => "PosteBudget",
            Nomenclature::Bank => "Banques",
        }
    }

    /// Primary-key column — each table has its own French name.
    pub fn id_column(self) -> &'static str {
        match self {
            Nomenclature::Category => "IDCategorie",
            Nomenclature::Assignment => "IDAffectation",
            Nomenclature::PaymentMode => "IDModeOperation",
            Nomenclature::Payee => "IDTiers",
            Nomenclature::Project => "IDProjets",
            Nomenclature::BudgetLine => "IDPosteBudget",
            Nomenclature::Bank => "IDBanques",
        }
    }

    /// Label column — `Banques` calls it `NomBanque`, everyone else `Libelle`.
    pub fn label_column(self) -> &'static str {
        match self {
            Nomenclature::Bank => "NomBanque",
            _ => "Libelle",
        }
    }

    /// Every place a row of this nomenclature can be referenced, as
    /// `(table, column)`. Resetting these to [`UNSPECIFIED`] is what deleting
    /// an element does.
    fn references(self) -> &'static [(&'static str, &'static str)] {
        match self {
            Nomenclature::Category => &[
                ("Operation", "IDCategorie"),
                ("ModeleOperation", "IDCategorie"),
                ("CalOpPeriodique", "IDCategorie"),
            ],
            Nomenclature::Assignment => &[
                ("Operation", "IDAffectation"),
                ("ModeleOperation", "IDAffectation"),
                ("CalOpPeriodique", "IDAffectation"),
            ],
            Nomenclature::PaymentMode => &[
                ("Operation", "IDModeOperation"),
                ("ModeleOperation", "IDModeOperation"),
                ("CalOpPeriodique", "IDModeOperation"),
            ],
            Nomenclature::Payee => &[
                ("Operation", "IDTiers"),
                ("ModeleOperation", "IDTiers"),
                ("CalOpPeriodique", "IDTiers"),
            ],
            Nomenclature::Project => &[
                ("Operation", "IDProjets"),
                ("ModeleOperation", "IDProjets"),
                ("CalOpPeriodique", "IDProjets"),
            ],
            // A budget line is not carried by operations: categories point at
            // it, and the Budget table hangs off it through a real cascade.
            Nomenclature::BudgetLine => &[("Categorie", "IDPosteBudget")],
            // A bank belongs to accounts, never to operations.
            Nomenclature::Bank => &[("Compte", "IDBanques")],
        }
    }
}

/// How many rows reference an element, table by table. `operations` is the
/// one that decides whether the user is asked at all — that is exactly what
/// the original tests.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct Usage {
    pub operations: i64,
    pub operation_templates: i64,
    pub recurring_rules: i64,
    pub categories: i64,
    pub accounts: i64,
}

impl Usage {
    /// Whether anything at all references the element.
    pub fn is_used(&self) -> bool {
        self.total() > 0
    }

    pub fn total(&self) -> i64 {
        self.operations
            + self.operation_templates
            + self.recurring_rules
            + self.categories
            + self.accounts
    }

    /// Whether the user must be asked before deleting: the original only
    /// raises the question when **operations** are involved.
    pub fn needs_confirmation(&self) -> bool {
        self.operations > 0
    }
}

/// The label of an element, or `None` if it no longer exists (the original's
/// first `RENVOYER Faux`).
pub fn label_of(conn: &Connection, kind: Nomenclature, id: i64) -> Result<Option<String>> {
    let sql = format!(
        "SELECT {} FROM {} WHERE {} = ?1",
        kind.label_column(),
        kind.table(),
        kind.id_column()
    );
    match conn.query_row(&sql, [id], |row| row.get::<_, String>(0)) {
        Ok(label) => Ok(Some(label)),
        Err(rusqlite::Error::QueryReturnedNoRows) => Ok(None),
        Err(other) => Err(other),
    }
}

/// Counts everything that references `id`. Call this before offering to
/// delete: [`Usage::needs_confirmation`] says whether to ask the question,
/// and `label_of` gives the label to put in it.
pub fn usage(conn: &Connection, kind: Nomenclature, id: i64) -> Result<Usage> {
    let mut usage = Usage::default();
    for (table, column) in kind.references() {
        let count: i64 = conn.query_row(
            &format!("SELECT COUNT(*) FROM {table} WHERE {column} = ?1"),
            [id],
            |row| row.get(0),
        )?;
        match *table {
            "Operation" => usage.operations = count,
            "ModeleOperation" => usage.operation_templates = count,
            "CalOpPeriodique" => usage.recurring_rules = count,
            "Categorie" => usage.categories = count,
            "Compte" => usage.accounts = count,
            other => unreachable!("table de référence inattendue : {other}"),
        }
    }
    Ok(usage)
}

/// Deletes an element, resetting every reference to it to « Non précisé »
/// first — the original's `Enreg_Supprimer`, minus the question, which the
/// caller has already asked (see the module doc comment).
///
/// Returns `false` when the element does not exist. Everything happens in one
/// transaction: either the references are all reset and the element is gone,
/// or nothing changed at all.
pub fn delete_and_reassign(conn: &mut Connection, kind: Nomenclature, id: i64) -> Result<bool> {
    if id == UNSPECIFIED || label_of(conn, kind, id)?.is_none() {
        return Ok(false);
    }

    let tx = conn.transaction()?;
    for (table, column) in kind.references() {
        tx.execute(
            &format!("UPDATE {table} SET {column} = {UNSPECIFIED} WHERE {column} = ?1"),
            [id],
        )?;
    }
    tx.execute(
        &format!(
            "DELETE FROM {} WHERE {} = ?1",
            kind.table(),
            kind.id_column()
        ),
        [id],
    )?;
    tx.commit()?;
    Ok(true)
}

/// Reads one category, or `None` if it no longer exists.
///
/// `Categorie` is the only nomenclature with a field of its own beyond its
/// label — the budget line it belongs to (02_BASE_DE_DONNEES.md §3.10) —
/// hence its own three functions here rather than a shared one.
pub fn get_category(conn: &Connection, id: i64) -> Result<Option<Category>> {
    match conn.query_row(
        "SELECT IDCategorie, Libelle, IDTypeCategorie, IDPosteBudget
         FROM Categorie WHERE IDCategorie = ?1",
        [id],
        |row| {
            Ok(Category {
                id: row.get(0)?,
                label: row.get(1)?,
                category_type_id: row.get(2)?,
                budget_line_id: row.get(3)?,
            })
        },
    ) {
        Ok(category) => Ok(Some(category)),
        Err(rusqlite::Error::QueryReturnedNoRows) => Ok(None),
        Err(other) => Err(other),
    }
}

/// Adds a category (`Enreg_Ajouter` of the author's `Code Fiche
/// Categorie.txt`). The key comes from the max+1 generator, exactly as the
/// original's `Genere_Clef`. The label is trimmed; `IDTypeCategorie` keeps
/// its "Non précisé" value, the field being unused by the port.
pub fn create_category(conn: &Connection, label: &str, budget_line_id: i64) -> Result<i64> {
    let id = crate::database::keygen::next_id(conn, "Categorie", "IDCategorie")?;
    conn.execute(
        "INSERT INTO Categorie (IDCategorie, Libelle, IDTypeCategorie, IDPosteBudget)
         VALUES (?1, ?2, ?3, ?4)",
        rusqlite::params![id, label.trim(), UNSPECIFIED, budget_line_id],
    )?;
    Ok(id)
}

/// Changes a category (`Enreg_Modifier`). Returns `false` if it no longer
/// exists.
pub fn update_category(
    conn: &Connection,
    id: i64,
    label: &str,
    budget_line_id: i64,
) -> Result<bool> {
    let changed = conn.execute(
        "UPDATE Categorie SET Libelle = ?1, IDPosteBudget = ?2 WHERE IDCategorie = ?3",
        rusqlite::params![label.trim(), budget_line_id, id],
    )?;
    Ok(changed > 0)
}

/// The element that already goes by `label`, if there is one — its own label,
/// as it is stored, so the message can show the user what is in the way.
///
/// `except` is the element being modified, which must not be found to be a
/// duplicate of itself.
///
/// Two elements of one nomenclature must not share a name (author's ruling,
/// 25/07/2026): classing an operation under one of two identical labels is a
/// coin toss, and every statistic built on them afterwards is wrong. What
/// counts as the same name is [`same_name_key`] — surrounding spaces dropped,
/// case and accents ignored, punctuation kept.
///
/// The comparison is done here rather than in SQL: SQLite's own `LIKE` knows
/// nothing of accents, and a `UNIQUE` index would refuse the row without ever
/// being able to say which one is in the way.
pub fn same_name_as(
    conn: &Connection,
    kind: Nomenclature,
    label: &str,
    except: Option<i64>,
) -> Result<Option<String>> {
    let wanted = same_name_key(label);
    if wanted.is_empty() {
        return Ok(None);
    }
    Ok(list(conn, kind)?
        .into_iter()
        .find(|item| Some(item.id) != except && same_name_key(&item.label) == wanted)
        .map(|item| item.label))
}

/// Reads one element of any nomenclature, or `None` if it no longer exists.
///
/// The six nomenclatures other than `Categorie` are a key and a label and
/// nothing else, so this one function serves them all. A category read this
/// way gives up its budget line: use [`get_category`] when it is needed.
pub fn get(conn: &Connection, kind: Nomenclature, id: i64) -> Result<Option<NamedItem>> {
    Ok(label_of(conn, kind, id)?.map(|label| NamedItem { id, label }))
}

/// Adds an element to any nomenclature. The key comes from the max+1
/// generator, exactly as the original's `Genere_Clef`; the label is trimmed.
///
/// A category needs its budget line as well — [`create_category`] is the one
/// to call for it, and this refuses rather than silently writing a category
/// with no budget line.
pub fn create(conn: &Connection, kind: Nomenclature, label: &str) -> Result<i64> {
    debug_assert!(
        !kind.has_budget_line(),
        "une catégorie s'ajoute par create_category : elle a un poste budgétaire"
    );
    let id = crate::database::keygen::next_id(conn, kind.table(), kind.id_column())?;
    conn.execute(
        &format!(
            "INSERT INTO {} ({}, {}) VALUES (?1, ?2)",
            kind.table(),
            kind.id_column(),
            kind.label_column()
        ),
        rusqlite::params![id, label.trim()],
    )?;
    Ok(id)
}

/// Changes the label of an element of any nomenclature. Returns `false` if it
/// no longer exists.
pub fn update(conn: &Connection, kind: Nomenclature, id: i64, label: &str) -> Result<bool> {
    let changed = conn.execute(
        &format!(
            "UPDATE {} SET {} = ?1 WHERE {} = ?2",
            kind.table(),
            kind.label_column(),
            kind.id_column()
        ),
        rusqlite::params![label.trim(), id],
    )?;
    Ok(changed > 0)
}

/// Every element of a nomenclature, sorted the way lists and combos must show
/// them (02_BASE_DE_DONNEES.md §7 rule 6).
pub fn list(conn: &Connection, kind: Nomenclature) -> Result<Vec<NamedItem>> {
    let sql = format!(
        "SELECT {}, {} FROM {}",
        kind.id_column(),
        kind.label_column(),
        kind.table()
    );
    let mut stmt = conn.prepare(&sql)?;
    let mut items: Vec<NamedItem> = stmt
        .query_map([], |row| {
            Ok(NamedItem {
                id: row.get(0)?,
                label: row.get(1)?,
            })
        })?
        .collect::<Result<_>>()?;
    items.sort_by(|a, b| {
        french_sort_key(&a.label)
            .cmp(&french_sort_key(&b.label))
            .then(a.id.cmp(&b.id))
    });
    Ok(items)
}

/// The same list as [`list`], with « Non précisé » (id [`UNSPECIFIED`]) put
/// first — what a data-entry combo shows (02_BASE_DE_DONNEES.md §7 rule 2).
/// The label is passed in rather than hard-coded, so the caller supplies it
/// in the user's language (`i18n::unspecified_label`).
pub fn list_for_combo(
    conn: &Connection,
    kind: Nomenclature,
    unspecified_label: &str,
) -> Result<Vec<NamedItem>> {
    let mut items = Vec::with_capacity(1);
    items.push(NamedItem {
        id: UNSPECIFIED,
        label: unspecified_label.to_string(),
    });
    items.extend(list(conn, kind)?);
    Ok(items)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database::{schema, seed};

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
             VALUES (1, 0, 0, 0, 'CCP', 1, 21, 0, 0, 0, '', '', '', '', '', '', '',
                     NULL, NULL, '', '', 0, 0, 'EUR')",
            [],
        )
        .unwrap();
        conn
    }

    fn add_operation(conn: &Connection, id: i64, category: i64, payee: i64) {
        conn.execute(
            "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDModeOperation,
                IDCategorie, IDAffectation, IDCompte, DatePointage, FitID, ReferencePaiement,
                NumRelevBanque, IDStatutOperation, IDOperationParent, SoldePointe, EstParent,
                GUIDCalOpPeriode, IDCheque, IDTiers, IDProjets, EstComplement)
             VALUES (?1, 'Op', '2026-01-15', -1000000, 0, ?2, 0, 1, '2026-01-15', '', '', '',
                     1, 0, 0, 0, '', 0, ?3, 0, 0)",
            [id, category, payee],
        )
        .unwrap();
    }

    fn add_template(conn: &Connection, id: i64, category: i64) {
        conn.execute(
            "INSERT INTO ModeleOperation (IDModeleOperation, Libelle, Montant,
                IDModeOperation, IDCategorie, IDAffectation, IDStatutOperation,
                IDTiers, IDProjets)
             VALUES (?1, 'Modele', 0, 0, ?2, 0, 1, 0, 0)",
            [id, category],
        )
        .unwrap();
    }

    fn add_recurring_rule(conn: &Connection, guid: &str, category: i64) {
        conn.execute(
            "INSERT INTO CalOpPeriodique (GUIDCalOpPeriode, Libelle, IDModeOperation,
                IDCategorie, IDAffectation, IDCompte, IDStatutOperation, Montant, DateFin,
                Periode, PeriodeNbrRepete, PeriodeFreq, ModeFinInsertion, DateDernOpGen,
                NbrOpInsert, NbrOpAnterieur, IDOperation, DateProchOp, MontantInsert,
                IDTiers, IDProjets)
             VALUES (?1, 'Regle', 0, ?2, 0, 1, 1, 0, NULL, 3, 0, 1, 1, NULL, 0, 0, 0,
                     NULL, 0, 0, 0)",
            rusqlite::params![guid, category],
        )
        .unwrap();
    }

    #[test]
    fn usage_counts_every_kind_of_reference() {
        let conn = database();
        add_operation(&conn, 1, 15, 0);
        add_operation(&conn, 2, 15, 0);
        add_template(&conn, 1, 15);
        add_recurring_rule(&conn, "guid-1", 15);

        let usage = usage(&conn, Nomenclature::Category, 15).unwrap();
        assert_eq!(usage.operations, 2);
        assert_eq!(usage.operation_templates, 1);
        assert_eq!(usage.recurring_rules, 1);
        assert!(usage.is_used());
        assert!(usage.needs_confirmation());
    }

    #[test]
    fn an_element_used_only_by_a_template_needs_no_question() {
        let conn = database();
        add_template(&conn, 1, 15);

        let usage = usage(&conn, Nomenclature::Category, 15).unwrap();
        assert!(usage.is_used());
        // The original only raises the question for operations.
        assert!(!usage.needs_confirmation());
    }

    #[test]
    fn deleting_resets_operations_templates_and_rules_to_unspecified() {
        let mut conn = database();
        add_operation(&conn, 1, 15, 0);
        add_template(&conn, 1, 15);
        add_recurring_rule(&conn, "guid-1", 15);

        assert!(delete_and_reassign(&mut conn, Nomenclature::Category, 15).unwrap());

        let reassigned = |table: &str, column: &str| -> i64 {
            conn.query_row(
                &format!("SELECT {column} FROM {table} LIMIT 1"),
                [],
                |r| r.get(0),
            )
            .unwrap()
        };
        assert_eq!(reassigned("Operation", "IDCategorie"), UNSPECIFIED);
        assert_eq!(reassigned("ModeleOperation", "IDCategorie"), UNSPECIFIED);
        assert_eq!(reassigned("CalOpPeriodique", "IDCategorie"), UNSPECIFIED);

        assert_eq!(label_of(&conn, Nomenclature::Category, 15).unwrap(), None);
    }

    #[test]
    fn only_the_deleted_element_is_reassigned() {
        let mut conn = database();
        add_operation(&conn, 1, 15, 0);
        add_operation(&conn, 2, 8, 0);

        delete_and_reassign(&mut conn, Nomenclature::Category, 15).unwrap();

        let untouched: i64 = conn
            .query_row(
                "SELECT IDCategorie FROM Operation WHERE IDOperation = 2",
                [],
                |r| r.get(0),
            )
            .unwrap();
        assert_eq!(untouched, 8);
    }

    #[test]
    fn deleting_a_payee_touches_the_payee_column_only() {
        let mut conn = database();
        add_operation(&conn, 1, 15, 3);

        delete_and_reassign(&mut conn, Nomenclature::Payee, 3).unwrap();

        let (category, payee): (i64, i64) = conn
            .query_row(
                "SELECT IDCategorie, IDTiers FROM Operation WHERE IDOperation = 1",
                [],
                |r| Ok((r.get(0)?, r.get(1)?)),
            )
            .unwrap();
        assert_eq!((category, payee), (15, UNSPECIFIED));
    }

    #[test]
    fn deleting_a_bank_releases_the_accounts_that_used_it() {
        let mut conn = database();
        assert_eq!(usage(&conn, Nomenclature::Bank, 21).unwrap().accounts, 1);

        delete_and_reassign(&mut conn, Nomenclature::Bank, 21).unwrap();

        let bank: i64 = conn
            .query_row("SELECT IDBanques FROM Compte WHERE IDCompte = 1", [], |r| {
                r.get(0)
            })
            .unwrap();
        assert_eq!(bank, UNSPECIFIED);
    }

    #[test]
    fn deleting_a_budget_line_releases_its_categories() {
        let mut conn = database();
        let before: i64 = conn
            .query_row(
                "SELECT COUNT(*) FROM Categorie WHERE IDPosteBudget = 1",
                [],
                |r| r.get(0),
            )
            .unwrap();
        assert!(before > 0);

        delete_and_reassign(&mut conn, Nomenclature::BudgetLine, 1).unwrap();

        let still_pointing: i64 = conn
            .query_row(
                "SELECT COUNT(*) FROM Categorie WHERE IDPosteBudget = 1",
                [],
                |r| r.get(0),
            )
            .unwrap();
        assert_eq!(still_pointing, 0);
    }

    #[test]
    fn an_unknown_element_and_the_unspecified_sentinel_are_both_refused() {
        let mut conn = database();
        assert!(!delete_and_reassign(&mut conn, Nomenclature::Category, 9999).unwrap());
        assert!(!delete_and_reassign(&mut conn, Nomenclature::Category, UNSPECIFIED).unwrap());
    }

    #[test]
    fn lists_come_out_alphabetically_under_the_french_collation() {
        let conn = database();
        let categories = list(&conn, Nomenclature::Category).unwrap();
        let labels: Vec<&str> = categories.iter().map(|c| c.label.as_str()).collect();

        let mut expected = labels.clone();
        expected.sort_by_key(|l| french_sort_key(l));
        assert_eq!(labels, expected);
        // "Épargne" must sit with the E's, not after Z.
        let epargne = labels.iter().position(|l| *l == "Épargne").unwrap();
        let essence = labels.iter().position(|l| *l == "Essence").unwrap();
        assert!(epargne < essence, "Épargne avant Essence");
    }

    #[test]
    fn a_combo_puts_unspecified_first() {
        let conn = database();
        let items = list_for_combo(&conn, Nomenclature::Assignment, "Non précisé").unwrap();
        assert_eq!(items[0].id, UNSPECIFIED);
        assert_eq!(items[0].label, "Non précisé");
        assert_eq!(items[1].label, "Animaux");
    }

    #[test]
    fn a_category_can_be_created_read_back_and_changed() {
        let conn = database();
        let id = create_category(&conn, "  Épargne Liquide  ", 6).unwrap();

        let created = get_category(&conn, id).unwrap().unwrap();
        assert_eq!(created.label, "Épargne Liquide", "le libellé est ébarbé");
        assert_eq!(created.budget_line_id, 6);
        // max + 1, as the original's Genere_Clef does.
        assert_eq!(id, 46);

        assert!(update_category(&conn, id, "Épargne", UNSPECIFIED).unwrap());
        let changed = get_category(&conn, id).unwrap().unwrap();
        assert_eq!(changed.label, "Épargne");
        assert_eq!(changed.budget_line_id, UNSPECIFIED);
    }

    #[test]
    fn changing_a_category_that_no_longer_exists_reports_it() {
        let conn = database();
        assert!(!update_category(&conn, 9999, "X", 0).unwrap());
        assert_eq!(get_category(&conn, 9999).unwrap(), None);
    }

    #[test]
    fn every_nomenclature_names_columns_that_exist() {
        let conn = database();
        for kind in [
            Nomenclature::Category,
            Nomenclature::Assignment,
            Nomenclature::PaymentMode,
            Nomenclature::Payee,
            Nomenclature::Project,
            Nomenclature::BudgetLine,
            Nomenclature::Bank,
        ] {
            list(&conn, kind).unwrap();
            usage(&conn, kind, 1).unwrap();
        }
    }
}

#[cfg(test)]
mod generic_tests {
    use super::*;
    use crate::database::schema;

    fn database() -> Connection {
        let conn = Connection::open_in_memory().expect("base en mémoire");
        schema::migrate(&conn).expect("schéma");
        conn
    }

    /// The six label-only nomenclatures go through one and the same code.
    /// What is checked here is that each of them really does: its own table,
    /// its own key column, and — for `Banques` — its own label column, which
    /// is `NomBanque` and not `Libelle`.
    #[test]
    fn every_label_only_nomenclature_is_read_and_written_through_the_same_code() {
        let mut conn = database();
        for kind in ALL {
            if kind.has_budget_line() {
                continue;
            }
            let id = create(&conn, kind, "  Essai  ").expect("ajout");
            assert_eq!(
                get(&conn, kind, id).expect("lecture").map(|item| item.label),
                Some("Essai".to_string()),
                "{} : le libellé doit être enregistré sans ses espaces",
                kind.table()
            );

            assert!(update(&conn, kind, id, "Essai modifié").expect("modification"));
            assert_eq!(
                get(&conn, kind, id).expect("relecture").map(|item| item.label),
                Some("Essai modifié".to_string()),
                "{} : la modification doit être visible",
                kind.table()
            );

            assert!(delete_and_reassign(&mut conn, kind, id).expect("suppression"));
            assert!(
                get(&conn, kind, id).expect("après suppression").is_none(),
                "{} : l'élément doit avoir disparu",
                kind.table()
            );
            assert!(
                !update(&conn, kind, id, "Fantôme").expect("modification impossible"),
                "{} : modifier un élément supprimé doit répondre faux",
                kind.table()
            );
        }
    }

    /// A nomenclature travels between the windows and Rust under its key.
    #[test]
    fn every_nomenclature_travels_under_its_own_key() {
        for kind in ALL {
            assert_eq!(
                Nomenclature::from_key(kind.key()),
                Some(kind),
                "{} : la clef doit désigner sa nomenclature",
                kind.table()
            );
        }
        assert_eq!(Nomenclature::from_key("inconnue"), None);
        assert!(Nomenclature::Category.has_budget_line());
        assert!(ALL
            .into_iter()
            .filter(|kind| kind.has_budget_line())
            .count()
            == 1);
    }
}

#[cfg(test)]
mod duplicate_tests {
    use super::*;
    use crate::database::schema;

    fn database() -> Connection {
        let conn = Connection::open_in_memory().expect("base en mémoire");
        schema::migrate(&conn).expect("schéma");
        conn
    }

    /// The rule the author asked for on 25/07/2026, first on categories and,
    /// once he had validated it, on the seven: two elements of one
    /// nomenclature may not share a name.
    #[test]
    fn a_category_name_already_taken_is_found_whatever_its_case_and_accents() {
        let conn = database();
        let id = create_category(&conn, "Alimentation", UNSPECIFIED).expect("ajout");

        for attempt in ["Alimentation", "alimentation", "ALIMENTATION", "  Alimentation "] {
            assert_eq!(
                same_name_as(&conn, Nomenclature::Category, attempt, None).expect("recherche"),
                Some("Alimentation".to_string()),
                "« {attempt} » doit être reconnu comme déjà pris"
            );
        }

        // Accents fold away too — « Marché » and « Marche » are one name.
        create_category(&conn, "Marché", UNSPECIFIED).expect("ajout");
        assert_eq!(
            same_name_as(&conn, Nomenclature::Category, "Marche", None).expect("recherche"),
            Some("Marché".to_string())
        );

        // Punctuation does not: the collation ignores it, this rule does not.
        create_category(&conn, "E. Leclerc", UNSPECIFIED).expect("ajout");
        assert_eq!(
            same_name_as(&conn, Nomenclature::Category, "ELeclerc", None).expect("recherche"),
            None,
            "« ELeclerc » et « E. Leclerc » sont deux noms différents"
        );

        // A free name is free.
        assert_eq!(
            same_name_as(&conn, Nomenclature::Category, "Carburant", None).expect("recherche"),
            None
        );

        // And an element is never a duplicate of itself: renaming
        // « Alimentation » into « alimentation » must stay possible.
        assert_eq!(
            same_name_as(&conn, Nomenclature::Category, "alimentation", Some(id))
                .expect("recherche"),
            None
        );
    }

    /// Each nomenclature is a list of its own. A category and a tiers may
    /// both be called « Carburant » — refusing that would be inventing a rule
    /// nobody asked for.
    #[test]
    fn a_name_is_only_taken_within_its_own_nomenclature() {
        let conn = database();
        create_category(&conn, "Carburant", UNSPECIFIED).expect("ajout");

        for kind in ALL {
            if kind.has_budget_line() {
                continue;
            }
            assert_eq!(
                same_name_as(&conn, kind, "Carburant", None).expect("recherche"),
                None,
                "{} : le nom d'une catégorie ne lui est pas opposable",
                kind.table()
            );
            create(&conn, kind, "Carburant").expect("ajout");
            assert_eq!(
                same_name_as(&conn, kind, "carburant", None).expect("recherche"),
                Some("Carburant".to_string()),
                "{} : chez elle, le nom est bien pris",
                kind.table()
            );
        }
    }
}
