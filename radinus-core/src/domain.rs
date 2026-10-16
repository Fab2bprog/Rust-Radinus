//! Entities mirroring the tables created in `database::schema` (02_BASE_DE_DONNEES.md §3).
//!
//! **Struct/field names here are English (source code, per the "all code in
//! English" rule, 08_ARCHITECTURE.md) — this is independent of the actual
//! SQL schema, which uses the original French table/column names verbatim
//! (`Compte`, `IDCompte`, `Libelle`, ...; see `database::schema`'s doc
//! comment for why).** Every struct maps conceptually onto its table's
//! columns; the actual French column names live in the SQL strings that
//! read/write these structs (`backup` module, and future query code), not
//! here. Amounts are `i64` micro-units (value * 1_000_000, see
//! `database::schema`).
//!
//! Dates are [`NaiveDate`] values from **`time_compute`**, Fabrice's own
//! crate (PLAN_ACTION.md rule 6: his crates are used in priority where they
//! apply; authorized 25/07/2026). They were plain `String`s until then, only
//! because no date crate had been authorized yet. A real date type means the
//! calendar arithmetic later phases need — Phase 2's DatePointage walk and
//! above all Phase 14's recurring schedules ("+1 month from 31 January" must
//! land on the last day of February, not overflow) — is done by a tested
//! library instead of by hand on strings. Dates carry no time-of-day, hence
//! `NaiveDate` rather than `NaiveDateTime`: the original schema stores
//! calendar days (WinDev `AAAAMMJJ`), never timestamps. Serde renders them as
//! ISO-8601 `YYYY-MM-DD`, unchanged from the previous string form; the WinDev
//! `AAAAMMJJ` conversion belongs to the `backup` module, not here.
//!
//! `0` means "unspecified" for every optional nomenclature foreign key,
//! matching the original convention (02_BASE_DE_DONNEES.md §7 rule 2).

use serde::{Deserialize, Serialize};
pub use time_compute::NaiveDate;

/// `StatutOperation` — CLOSED list, 02_BASE_DE_DONNEES.md §5.2. Never
/// user-editable; represented as a real enum (not a nomenclature row lookup)
/// so illegal statuses are unrepresentable in Rust code, even though the
/// `StatutOperation` table still exists in SQL for foreign-key integrity.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum OperationStatus {
    Pointed = 1,
    Committed = 2,
    Planned = 3,
}

impl OperationStatus {
    pub fn from_id(id: i64) -> Option<Self> {
        match id {
            1 => Some(Self::Pointed),
            2 => Some(Self::Committed),
            3 => Some(Self::Planned),
            _ => None,
        }
    }

    pub fn id(self) -> i64 {
        self as i64
    }
}

/// `Periode` unit for recurring rules — CONFIRMED coding in
/// `Date_EcheanceSuivante` (02_BASE_DE_DONNEES.md §3.7).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum RecurrencePeriodUnit {
    Day = 1,
    Week = 2,
    Month = 3,
    Quarter = 4,
    Year = 5,
}

impl RecurrencePeriodUnit {
    pub fn from_id(id: i64) -> Option<Self> {
        match id {
            1 => Some(Self::Day),
            2 => Some(Self::Week),
            3 => Some(Self::Month),
            4 => Some(Self::Quarter),
            5 => Some(Self::Year),
            _ => None,
        }
    }

    pub fn id(self) -> i64 {
        self as i64
    }
}

/// `ModeFinInsertion` for recurring rules — CONFIRMED coding in
/// `Existe_EcheanceSuivante` (02_BASE_DE_DONNEES.md §3.7).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum RecurrenceEndMode {
    NoLimit = 1,
    EndDate = 2,
    RepeatCount = 3,
}

impl RecurrenceEndMode {
    pub fn from_id(id: i64) -> Option<Self> {
        match id {
            1 => Some(Self::NoLimit),
            2 => Some(Self::EndDate),
            3 => Some(Self::RepeatCount),
            _ => None,
        }
    }

    pub fn id(self) -> i64 {
        self as i64
    }
}

/// `Compte` (02_BASE_DE_DONNEES.md §3.1).
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Account {
    pub id: i64,
    pub label: String,
    pub account_type_id: i64,
    pub bank_id: i64,
    pub opening_balance_pointed: i64,
    pub opening_balance_committed: i64,
    pub opening_balance_planned: i64,
    pub balance_bank: i64,
    pub balance_real: i64,
    pub balance_final: i64,
    pub holder_name: String,
    pub holder_address: String,
    pub rib_bank_code: String,
    pub rib_branch_code: String,
    pub rib_account_number: String,
    pub rib_key: String,
    pub iban: String,
    pub bic: String,
    pub branch_address: String,
    pub opening_date: Option<NaiveDate>,
    pub closing_date: Option<NaiveDate>,
    pub next_check_number: i64,
    pub is_closed: bool,
    pub currency: String,
}

/// `Operation` (02_BASE_DE_DONNEES.md §3.2). `is_complement` is the dedicated
/// marker replacing label-based "Complement" recognition (see
/// `database::schema` module doc and 08_ARCHITECTURE.md's i18n paragraph).
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Operation {
    pub id: i64,
    pub label: String,
    pub date: Option<NaiveDate>,
    pub amount: i64,
    pub payment_mode_id: i64,
    pub category_id: i64,
    pub assignment_id: i64,
    pub account_id: i64,
    pub operation_status_id: i64,
    pub clearing_date: Option<NaiveDate>,
    pub pointed_balance: i64,
    pub fit_id: String,
    pub payment_reference: String,
    pub bank_statement_number: String,
    pub parent_operation_id: i64,
    pub has_children: bool,
    pub recurring_rule_guid: String,
    pub check_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
    pub is_complement: bool,
    /// `Verification` — 1 à vérifier, 2 vérifiée, 3 douteuse, 4 contestée
    /// (base version 11). Ce que l'utilisateur pense de l'écriture, à côté du
    /// statut, qui dit ce que la banque en a fait.
    pub verification_id: i64,
}

/// `Commentaire` (02_BASE_DE_DONNEES.md §3.3).
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Comment {
    pub id: i64,
    pub text: String,
    pub operation_id: i64,
}

/// `PiecesJointes` (02_BASE_DE_DONNEES.md §3.4).
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Attachment {
    pub id: i64,
    pub operation_id: i64,
    pub original_filename: String,
    pub stored_filename_guid: String,
    pub relative_path: String,
    pub size_bytes: i64,
    pub mime_type: String,
    pub added_date: Option<NaiveDate>,
    pub checksum: String,
    pub note: String,
}

/// `Chequier` (02_BASE_DE_DONNEES.md §3.5).
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Checkbook {
    pub id: i64,
    pub reference: String,
    pub received_date: Option<NaiveDate>,
    pub first_check_number: i64,
    pub last_check_number: i64,
    pub check_count: i64,
    pub check_number_format: i64,
    pub comments: String,
    pub account_id: i64,
}

/// `Cheque` (02_BASE_DE_DONNEES.md §3.6).
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Check {
    pub id: i64,
    pub number: i64,
    pub checkbook_id: i64,
    pub issue_date: Option<NaiveDate>,
    pub payee_name: String,
    pub amount: i64,
    pub comments: String,
    pub issue_place: String,
    pub check_status_id: i64,
}

/// `CalOpPeriodique` (02_BASE_DE_DONNEES.md §3.7).
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct RecurringOperationRule {
    pub guid: String,
    pub label: String,
    pub account_id: i64,
    pub payment_mode_id: i64,
    pub category_id: i64,
    pub assignment_id: i64,
    pub operation_status_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
    pub amount: i64,
    pub next_date: Option<NaiveDate>,
    pub period_unit: i64,
    pub period_frequency: i64,
    pub repeat_count: i64,
    pub end_mode: i64,
    pub end_date: Option<NaiveDate>,
    pub last_generated_date: Option<NaiveDate>,
    pub inserted_count: i64,
    pub previous_count: i64,
    pub generated_amount_total: i64,
    pub operation_id: i64,
}

/// `ModeleOperation` (02_BASE_DE_DONNEES.md §3.8).
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct OperationTemplate {
    pub id: i64,
    pub label: String,
    pub amount: i64,
    pub payment_mode_id: i64,
    pub category_id: i64,
    pub assignment_id: i64,
    pub operation_status_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
}

/// `Budget` (02_BASE_DE_DONNEES.md §3.9).
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Budget {
    pub id: i64,
    pub year: i64,
    pub month: i64,
    pub budget_line_id: i64,
    pub amount: i64,
}

/// `Categorie` (02_BASE_DE_DONNEES.md §3.10).
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Category {
    pub id: i64,
    pub label: String,
    pub category_type_id: i64,
    pub budget_line_id: i64,
}

/// Simple `ID<Table> + Libelle` nomenclatures (02_BASE_DE_DONNEES.md §3.10):
/// `Affectation`, `ModeOperation`, `PosteBudget`, `Projets`, `Tiers`,
/// `TypeCompte`. `StatutOperation` uses [`OperationStatus`] instead (closed
/// list). One shared struct since the shape is identical.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct NamedItem {
    pub id: i64,
    pub label: String,
}

/// `StatutCheque` (02_BASE_DE_DONNEES.md §5.7) — has a description in
/// addition to the label, so it isn't a [`NamedItem`].
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct CheckStatus {
    pub id: i64,
    pub label: String,
    pub description: String,
}

/// `Parametres` (02_BASE_DE_DONNEES.md §3.11). Always exactly one row, id=1.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Settings {
    pub run_once: bool,
    pub init_default_values: bool,
    pub software_version_major: i64,
    pub software_version_minor: i64,
    pub software_version_patch: i64,
    pub db_schema_version: i64,
    /// La langue de la base : **le numéro de la constante « nation » du
    /// WLangage** (5 = français, 3 = anglais, 7 = espagnol). Décision de
    /// Fabrice du 01/08/2026, qui révise le 02_BASE_DE_DONNEES.md §3.11 : une
    /// sauvegarde 1.9.3 porte ce nombre, et le stocker tel quel est la seule
    /// façon qu'un aller-retour ne perde pas la langue. Voir `i18n::Language`.
    pub language: i64,
}

/// `Preferences` (02_BASE_DE_DONNEES.md §3.13) — free-form key/JSON-value
/// store, structure intentionally left open (dossier: "structure libre, sans
/// besoin de compatibilité").
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Preference {
    pub id: i64,
    pub pref_key: String,
    pub value_json: String,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn operation_status_round_trips_through_its_id() {
        for status in [
            OperationStatus::Pointed,
            OperationStatus::Committed,
            OperationStatus::Planned,
        ] {
            assert_eq!(OperationStatus::from_id(status.id()), Some(status));
        }
    }

    #[test]
    fn operation_status_rejects_unknown_ids() {
        assert_eq!(OperationStatus::from_id(0), None);
        assert_eq!(OperationStatus::from_id(4), None);
    }

    #[test]
    fn recurrence_period_unit_round_trips_through_its_id() {
        for unit in [
            RecurrencePeriodUnit::Day,
            RecurrencePeriodUnit::Week,
            RecurrencePeriodUnit::Month,
            RecurrencePeriodUnit::Quarter,
            RecurrencePeriodUnit::Year,
        ] {
            assert_eq!(RecurrencePeriodUnit::from_id(unit.id()), Some(unit));
        }
    }

    /// Dates must still serialize as ISO-8601 `YYYY-MM-DD`, exactly as they
    /// did when they were plain `String`s: the move to `time_compute` is a
    /// type change, not a format change.
    #[test]
    fn dates_serialize_as_iso_8601() {
        let date = NaiveDate::from_ymd_opt(2026, 7, 25).unwrap();
        assert_eq!(serde_json::to_string(&date).unwrap(), "\"2026-07-25\"");

        let none: Option<NaiveDate> = None;
        assert_eq!(serde_json::to_string(&none).unwrap(), "null");

        let read_back: NaiveDate = serde_json::from_str("\"2026-07-25\"").unwrap();
        assert_eq!(read_back, date);
    }

    /// The reason for using a real date type rather than strings: month
    /// arithmetic must clamp to the end of a short month instead of
    /// overflowing. This is exactly what Phase 14's recurring schedules need
    /// ("le 31 de chaque mois"), and what string handling would get wrong.
    #[test]
    fn adding_a_month_to_the_31st_lands_on_the_end_of_the_short_month() {
        use time_compute::Months;

        let jan31 = NaiveDate::from_ymd_opt(2026, 1, 31).unwrap();
        assert_eq!(
            jan31.checked_add_months(Months::new(1)).unwrap(),
            NaiveDate::from_ymd_opt(2026, 2, 28).unwrap()
        );

        // ...and the leap year is handled too.
        let jan31_leap = NaiveDate::from_ymd_opt(2028, 1, 31).unwrap();
        assert_eq!(
            jan31_leap.checked_add_months(Months::new(1)).unwrap(),
            NaiveDate::from_ymd_opt(2028, 2, 29).unwrap()
        );
    }

    /// Dates must order chronologically, which is what Phase 2's balance walk
    /// along DatePointage relies on.
    #[test]
    fn dates_compare_chronologically() {
        let earlier = NaiveDate::from_ymd_opt(2026, 1, 5).unwrap();
        let later = NaiveDate::from_ymd_opt(2026, 12, 1).unwrap();
        assert!(earlier < later);
    }

    #[test]
    fn recurrence_end_mode_round_trips_through_its_id() {
        for mode in [
            RecurrenceEndMode::NoLimit,
            RecurrenceEndMode::EndDate,
            RecurrenceEndMode::RepeatCount,
        ] {
            assert_eq!(RecurrenceEndMode::from_id(mode.id()), Some(mode));
        }
    }
}
