//! Per-table JSON row shapes for the Radinus 1.9.3 backup format, and their
//! conversion to/from `domain` structs.
//!
//! **Field names here are French, matching the original WinDev schema
//! exactly** (`IDCompte`, `Libelle`, `ReportPointe`, ...) — this is the one
//! deliberate exception to the "all code in English" rule (08_ARCHITECTURE.md):
//! these structs describe an **external file format** that must be
//! reproduced byte-for-byte compatible with Radinus 1.9.3
//! (06_FORMATS_SAUVEGARDE_IMPORT_EXPORT.md §1, "format constaté, à
//! reproduire à l'identique"), the same way `account.iban`/`account.bic`
//! keep their real-world field names. Internal table/column names stay
//! English (see `database::schema`) — only this translation layer speaks the
//! legacy dialect, and only in the two directions of this module.
//!
//! Conventions reproduced from 06_FORMATS_SAUVEGARDE_IMPORT_EXPORT.md §1.3:
//! - dates: `AAAAMMJJ` string, empty string if null;
//! - booleans: JSON `true`/`false`;
//! - amounts: plain decimal numbers (not micro-units — that's an internal
//!   storage choice, see `database::schema`'s doc comment);
//! - every field always present, even when null/zero/empty, including the
//!   row's own `IDxxx` primary key (WinDev never used engine auto-increment,
//!   see 02_BASE_DE_DONNEES.md §7 rule 1 — the key generator produces it
//!   before insertion, so it's always present in the backup too).

use crate::domain::{
    Account, Attachment, Budget, Category, Check, Checkbook, Comment, NamedItem, Operation,
    OperationTemplate, RecurringOperationRule, Settings,
};
use serde::{Deserialize, Serialize};
use time_compute::{Datelike, NaiveDate};

/// Reading a legacy archive **field by field, without ever refusing one**.
///
/// The format says every field is always present, even when null or zero
/// (see this module's header). Real archives disagree. Two users lost a whole
/// restore on 10/08/2026 — `invalid type: null, expected i64` — because a
/// column added to their database years after it was created had been left
/// `null` on every row written before that day. One field of one row sank
/// nineteen tables, since serde stops at the first one it cannot read.
///
/// So every field of every table now reads through this module. A `null`
/// gives the neutral value; a field the archive does not carry at all gives
/// the same, which is the second face of the same problem — an older archive
/// simply has no such column. Neither is a reason to lose a history.
///
/// **Nothing is silently swallowed**: each substitution is counted, and the
/// restore reports the total. Zero for an identifier means "no project, no
/// payee, no check", which is exactly what the empty field meant. Zero for an
/// amount is a heavier claim, and the count is what lets the user go and look.
///
/// The counter is per thread because that is the scope of one archive read:
/// `read_archive` clears it before parsing and reads it after, and no two
/// archives are read on the same thread at once.
pub mod lenient {
    use serde::{Deserialize, Deserializer};
    use std::cell::Cell;

    thread_local! {
        static EMPTIED: Cell<u64> = const { Cell::new(0) };
    }

    /// Forgets what was counted — called before reading an archive.
    pub fn forget() {
        EMPTIED.with(|count| count.set(0));
    }

    /// How many fields were read as their neutral value since [`forget`].
    pub fn emptied() -> u64 {
        EMPTIED.with(|count| count.get())
    }

    fn note() {
        EMPTIED.with(|count| count.set(count.get() + 1));
    }

    pub fn missing_integer() -> i64 {
        note();
        0
    }

    pub fn missing_decimal() -> f64 {
        note();
        0.0
    }

    pub fn missing_text() -> String {
        note();
        String::new()
    }

    pub fn missing_flag() -> bool {
        note();
        false
    }

    pub fn integer<'de, D: Deserializer<'de>>(source: D) -> Result<i64, D::Error> {
        Ok(Option::<i64>::deserialize(source)?.unwrap_or_else(missing_integer))
    }

    pub fn decimal<'de, D: Deserializer<'de>>(source: D) -> Result<f64, D::Error> {
        Ok(Option::<f64>::deserialize(source)?.unwrap_or_else(missing_decimal))
    }

    pub fn text<'de, D: Deserializer<'de>>(source: D) -> Result<String, D::Error> {
        Ok(Option::<String>::deserialize(source)?.unwrap_or_else(missing_text))
    }

    pub fn flag<'de, D: Deserializer<'de>>(source: D) -> Result<bool, D::Error> {
        Ok(Option::<bool>::deserialize(source)?.unwrap_or_else(missing_flag))
    }
}

/// Parses a WinDev `AAAAMMJJ` date string. Empty string (WinDev's "no date")
/// and malformed values both give `None`: a single damaged field in a legacy
/// archive must not sink an otherwise good restore. Callers that need the
/// date to exist (only `Operation.Date`) report the error themselves.
pub fn windev_date(s: &str) -> Option<NaiveDate> {
    if s.len() != 8 || !s.bytes().all(|b| b.is_ascii_digit()) {
        return None;
    }
    let year: i32 = s[0..4].parse().ok()?;
    let month: u32 = s[4..6].parse().ok()?;
    let day: u32 = s[6..8].parse().ok()?;
    NaiveDate::from_ymd_opt(year, month, day)
}

/// Renders a date back in WinDev's `AAAAMMJJ` form. `None` becomes the empty
/// string, which is exactly how the format writes a null date.
pub fn date_to_windev(d: &Option<NaiveDate>) -> String {
    match d {
        Some(d) => date_to_windev_required(*d),
        None => String::new(),
    }
}

/// Same as [`date_to_windev`] for a date that is always present.
pub fn date_to_windev_required(d: NaiveDate) -> String {
    format!("{:04}{:02}{:02}", d.year(), d.month(), d.day())
}

/// Converts a backup JSON amount (plain decimal, e.g. `5972.54`) to our
/// internal micro-unit integer (value * 1_000_000). `f64` has 52 bits of
/// mantissa (~15-17 significant decimal digits); realistic personal-finance
/// amounts (well under a billion units, 6 decimal places) round-trip exactly
/// through this conversion.
pub fn amount_from_json(value: f64) -> i64 {
    (value * 1_000_000.0).round() as i64
}

/// Converts an internal micro-unit amount back to a plain decimal `f64` for
/// JSON output.
pub fn amount_to_json(micros: i64) -> f64 {
    micros as f64 / 1_000_000.0
}

/// The exact legacy label Radinus 1.9.3 used to identify a "Complement"
/// sub-operation (08_ARCHITECTURE.md i18n paragraph: label-based recognition
/// only survives at restore time, translated into the `is_complement`
/// marker from then on).
pub const LEGACY_COMPLEMENT_LABEL: &str = "Complément";

// --------------------------------------------------------------------
// Simple `IDxxx` + `Libelle` nomenclatures: Affectation, ModeOperation,
// PosteBudget, Projets, Tiers. Each table's id column has its own name in
// the legacy schema, so each gets its own tiny struct (serde's `rename`
// needs a compile-time-fixed string per field — a single generic struct
// can't carry five different JSON key names).
// --------------------------------------------------------------------

macro_rules! named_item_row {
    ($name:ident, $id_field:literal) => {
        #[derive(Debug, Clone, Default, Serialize, Deserialize)]
        #[serde(default)]
        pub struct $name {
            #[serde(
                rename = $id_field,
                default = "lenient::missing_integer",
                deserialize_with = "lenient::integer"
            )]
            pub id: i64,
            #[serde(
                rename = "Libelle",
                default = "lenient::missing_text",
                deserialize_with = "lenient::text"
            )]
            pub libelle: String,
        }

        impl $name {
            pub fn to_domain(&self) -> NamedItem {
                NamedItem {
                    id: self.id,
                    label: self.libelle.clone(),
                }
            }
            pub fn from_domain(item: &NamedItem) -> Self {
                Self {
                    id: item.id,
                    libelle: item.label.clone(),
                }
            }
        }
    };
}

named_item_row!(AffectationRow, "IDAffectation");
named_item_row!(ModeOperationRow, "IDModeOperation");
named_item_row!(PosteBudgetRow, "IDPosteBudget");
named_item_row!(ProjetsRow, "IDProjets");
named_item_row!(TiersRow, "IDTiers");

/// `Banques` uses `NomBanque` instead of `Libelle` (02_BASE_DE_DONNEES.md §3.10).
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default)]
pub struct BankRow {
    #[serde(
        rename = "IDBanques",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_banques: i64,
    #[serde(
        rename = "NomBanque",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub nom_banque: String,
}

impl BankRow {
    pub fn to_domain(&self) -> NamedItem {
        NamedItem {
            id: self.id_banques,
            label: self.nom_banque.clone(),
        }
    }
    pub fn from_domain(item: &NamedItem) -> Self {
        Self {
            id_banques: item.id,
            nom_banque: item.label.clone(),
        }
    }
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default)]
pub struct StatutChequeRow {
    #[serde(
        rename = "IDStatutCheque",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_statut_cheque: i64,
    #[serde(
        rename = "Libelle",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub libelle: String,
    #[serde(
        rename = "Description",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub description: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default)]
pub struct CategorieRow {
    #[serde(
        rename = "IDCategorie",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_categorie: i64,
    #[serde(
        rename = "Libelle",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub libelle: String,
    #[serde(
        rename = "IDTypeCategorie",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_type_categorie: i64,
    #[serde(
        rename = "IDPosteBudget",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_poste_budget: i64,
}

impl CategorieRow {
    pub fn to_domain(&self) -> Category {
        Category {
            id: self.id_categorie,
            label: self.libelle.clone(),
            category_type_id: self.id_type_categorie,
            budget_line_id: self.id_poste_budget,
        }
    }
    pub fn from_domain(c: &Category) -> Self {
        Self {
            id_categorie: c.id,
            libelle: c.label.clone(),
            id_type_categorie: c.category_type_id,
            id_poste_budget: c.budget_line_id,
        }
    }
}

/// One row of the `Preferences` table: a setting's name, and its value written
/// as JSON.
///
/// **Read leniently, on purpose.** 1.9.3 used this table freely and
/// 02_BASE_DE_DONNEES.md §3.13 frees it from any compatibility, so an old
/// archive may carry rows shaped in a way we know nothing about. Every field
/// defaults, so such a row yields an empty `cle` instead of an error, and
/// `insert_preferences` skips it. A restore is never refused for something it
/// does not understand (author's rule, 25/07/2026).
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default)]
pub struct PreferencesRow {
    #[serde(
        rename = "IDPreferences",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_preferences: i64,
    #[serde(
        rename = "Cle",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub cle: String,
    #[serde(
        rename = "ValeurJSON",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub valeur_json: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default)]
pub struct CompteRow {
    #[serde(
        rename = "IDCompte",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_compte: i64,
    #[serde(
        rename = "Libelle",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub libelle: String,
    #[serde(
        rename = "IDTypeCompte",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_type_compte: i64,
    #[serde(
        rename = "IDBanques",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_banques: i64,
    #[serde(
        rename = "ReportPointe",
        default = "lenient::missing_decimal",
        deserialize_with = "lenient::decimal"
    )]
    pub report_pointe: f64,
    #[serde(
        rename = "ReportEngage",
        default = "lenient::missing_decimal",
        deserialize_with = "lenient::decimal"
    )]
    pub report_engage: f64,
    #[serde(
        rename = "ReportPrevu",
        default = "lenient::missing_decimal",
        deserialize_with = "lenient::decimal"
    )]
    pub report_prevu: f64,
    #[serde(
        rename = "SoldeBanque",
        default = "lenient::missing_decimal",
        deserialize_with = "lenient::decimal"
    )]
    pub solde_banque: f64,
    #[serde(
        rename = "SoldeReel",
        default = "lenient::missing_decimal",
        deserialize_with = "lenient::decimal"
    )]
    pub solde_reel: f64,
    #[serde(
        rename = "SoldeFinal",
        default = "lenient::missing_decimal",
        deserialize_with = "lenient::decimal"
    )]
    pub solde_final: f64,
    #[serde(
        rename = "NomTitulaire",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub nom_titulaire: String,
    #[serde(
        rename = "AdresseTitulaire",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub adresse_titulaire: String,
    #[serde(
        rename = "COBCodeBanque",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub cob_code_banque: String,
    #[serde(
        rename = "COBCodeGuichet",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub cob_code_guichet: String,
    #[serde(
        rename = "COBNumCompte",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub cob_num_compte: String,
    #[serde(
        rename = "COBClefRIB",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub cob_clef_rib: String,
    #[serde(
        rename = "COBIBAN",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub cob_iban: String,
    #[serde(
        rename = "COBBIC",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub cob_bic: String,
    #[serde(
        rename = "AdresseAgenceBank",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub adresse_agence_bank: String,
    #[serde(
        rename = "DateOuverture",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub date_ouverture: String,
    #[serde(
        rename = "DateCloture",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub date_cloture: String,
    #[serde(
        rename = "NumProchCheque",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub num_proch_cheque: i64,
    #[serde(
        rename = "CompteCloture",
        default = "lenient::missing_flag",
        deserialize_with = "lenient::flag"
    )]
    pub compte_cloture: bool,
    #[serde(
        rename = "Devise",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub devise: String,
}

impl CompteRow {
    pub fn to_domain(&self) -> Account {
        Account {
            id: self.id_compte,
            label: self.libelle.clone(),
            account_type_id: self.id_type_compte,
            bank_id: self.id_banques,
            opening_balance_pointed: amount_from_json(self.report_pointe),
            opening_balance_committed: amount_from_json(self.report_engage),
            opening_balance_planned: amount_from_json(self.report_prevu),
            balance_bank: amount_from_json(self.solde_banque),
            balance_real: amount_from_json(self.solde_reel),
            balance_final: amount_from_json(self.solde_final),
            holder_name: self.nom_titulaire.clone(),
            holder_address: self.adresse_titulaire.clone(),
            rib_bank_code: self.cob_code_banque.clone(),
            rib_branch_code: self.cob_code_guichet.clone(),
            rib_account_number: self.cob_num_compte.clone(),
            rib_key: self.cob_clef_rib.clone(),
            iban: self.cob_iban.clone(),
            bic: self.cob_bic.clone(),
            branch_address: self.adresse_agence_bank.clone(),
            opening_date: windev_date(&self.date_ouverture),
            closing_date: windev_date(&self.date_cloture),
            next_check_number: self.num_proch_cheque,
            is_closed: self.compte_cloture,
            currency: self.devise.clone(),
        }
    }

    pub fn from_domain(a: &Account) -> Self {
        Self {
            id_compte: a.id,
            libelle: a.label.clone(),
            id_type_compte: a.account_type_id,
            id_banques: a.bank_id,
            report_pointe: amount_to_json(a.opening_balance_pointed),
            report_engage: amount_to_json(a.opening_balance_committed),
            report_prevu: amount_to_json(a.opening_balance_planned),
            solde_banque: amount_to_json(a.balance_bank),
            solde_reel: amount_to_json(a.balance_real),
            solde_final: amount_to_json(a.balance_final),
            nom_titulaire: a.holder_name.clone(),
            adresse_titulaire: a.holder_address.clone(),
            cob_code_banque: a.rib_bank_code.clone(),
            cob_code_guichet: a.rib_branch_code.clone(),
            cob_num_compte: a.rib_account_number.clone(),
            cob_clef_rib: a.rib_key.clone(),
            cob_iban: a.iban.clone(),
            cob_bic: a.bic.clone(),
            adresse_agence_bank: a.branch_address.clone(),
            date_ouverture: date_to_windev(&a.opening_date),
            date_cloture: date_to_windev(&a.closing_date),
            num_proch_cheque: a.next_check_number,
            compte_cloture: a.is_closed,
            devise: a.currency.clone(),
        }
    }
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default)]
pub struct ChequierRow {
    #[serde(
        rename = "IDChequier",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_chequier: i64,
    #[serde(
        rename = "IDReferenceChq",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub id_reference_chq: String,
    #[serde(
        rename = "DateRecep",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub date_recep: String,
    #[serde(
        rename = "NumPremierChq",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub num_premier_chq: i64,
    #[serde(
        rename = "NumDernChq",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub num_dern_chq: i64,
    #[serde(
        rename = "QteChq",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub qte_chq: i64,
    #[serde(
        rename = "FormatNumChq",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub format_num_chq: i64,
    #[serde(
        rename = "Commentaires",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub commentaires: String,
    #[serde(
        rename = "IDCompte",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_compte: i64,
}

impl ChequierRow {
    pub fn to_domain(&self) -> Checkbook {
        Checkbook {
            id: self.id_chequier,
            reference: self.id_reference_chq.clone(),
            received_date: windev_date(&self.date_recep),
            first_check_number: self.num_premier_chq,
            last_check_number: self.num_dern_chq,
            check_count: self.qte_chq,
            check_number_format: self.format_num_chq,
            comments: self.commentaires.clone(),
            account_id: self.id_compte,
        }
    }
    pub fn from_domain(c: &Checkbook) -> Self {
        Self {
            id_chequier: c.id,
            id_reference_chq: c.reference.clone(),
            date_recep: date_to_windev(&c.received_date),
            num_premier_chq: c.first_check_number,
            num_dern_chq: c.last_check_number,
            qte_chq: c.check_count,
            format_num_chq: c.check_number_format,
            commentaires: c.comments.clone(),
            id_compte: c.account_id,
        }
    }
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default)]
pub struct ChequeRow {
    #[serde(
        rename = "IDCheque",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_cheque: i64,
    #[serde(
        rename = "NumChq",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub num_chq: i64,
    #[serde(
        rename = "IDChequier",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_chequier: i64,
    #[serde(
        rename = "DateEmission",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub date_emission: String,
    #[serde(
        rename = "Beneficiaire",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub beneficiaire: String,
    #[serde(
        rename = "Montant",
        default = "lenient::missing_decimal",
        deserialize_with = "lenient::decimal"
    )]
    pub montant: f64,
    #[serde(
        rename = "Commentaires",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub commentaires: String,
    #[serde(
        rename = "LieuEmission",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub lieu_emission: String,
    #[serde(
        rename = "IDStatutCheque",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_statut_cheque: i64,
}

impl ChequeRow {
    pub fn to_domain(&self) -> Check {
        Check {
            id: self.id_cheque,
            number: self.num_chq,
            checkbook_id: self.id_chequier,
            issue_date: windev_date(&self.date_emission),
            payee_name: self.beneficiaire.clone(),
            amount: amount_from_json(self.montant),
            comments: self.commentaires.clone(),
            issue_place: self.lieu_emission.clone(),
            check_status_id: self.id_statut_cheque,
        }
    }
    pub fn from_domain(c: &Check) -> Self {
        Self {
            id_cheque: c.id,
            num_chq: c.number,
            id_chequier: c.checkbook_id,
            date_emission: date_to_windev(&c.issue_date),
            beneficiaire: c.payee_name.clone(),
            montant: amount_to_json(c.amount),
            commentaires: c.comments.clone(),
            lieu_emission: c.issue_place.clone(),
            id_statut_cheque: c.check_status_id,
        }
    }
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default)]
pub struct OperationRow {
    #[serde(
        rename = "IDOperation",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_operation: i64,
    #[serde(
        rename = "Libelle",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub libelle: String,
    #[serde(
        rename = "Date",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub date: String,
    #[serde(
        rename = "Montant",
        default = "lenient::missing_decimal",
        deserialize_with = "lenient::decimal"
    )]
    pub montant: f64,
    #[serde(
        rename = "IDModeOperation",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_mode_operation: i64,
    #[serde(
        rename = "IDCategorie",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_categorie: i64,
    #[serde(
        rename = "IDAffectation",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_affectation: i64,
    #[serde(
        rename = "IDCompte",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_compte: i64,
    #[serde(
        rename = "IDStatutOperation",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_statut_operation: i64,
    #[serde(
        rename = "DatePointage",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub date_pointage: String,
    #[serde(
        rename = "SoldePointe",
        default = "lenient::missing_decimal",
        deserialize_with = "lenient::decimal"
    )]
    pub solde_pointe: f64,
    #[serde(
        rename = "FitID",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub fit_id: String,
    #[serde(
        rename = "ReferencePaiement",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub reference_paiement: String,
    #[serde(
        rename = "NumRelevBanque",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub num_releve_banque: String,
    #[serde(
        rename = "IDOperationParent",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_operation_parent: i64,
    #[serde(
        rename = "EstParent",
        default = "lenient::missing_flag",
        deserialize_with = "lenient::flag"
    )]
    pub est_parent: bool,
    #[serde(
        rename = "GUIDCalOpPeriode",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub guid_cal_op_periode: String,
    #[serde(
        rename = "IDCheque",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_cheque: i64,
    #[serde(
        rename = "IDTiers",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_tiers: i64,
    #[serde(
        rename = "IDProjets",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_projets: i64,
    /// **Absent de toute sauvegarde antérieure à la base 11**, 1.9.3 comprise :
    /// il vaut alors 0, que [`OperationRow::to_domain`] lit comme « Vérifiée ».
    #[serde(
        rename = "IDVerification",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_verification: i64,
}

impl OperationRow {
    /// Sets `is_complement` when the row is a sub-operation (non-zero
    /// parent) whose legacy label is exactly "Complément" — see
    /// [`LEGACY_COMPLEMENT_LABEL`] and 08_ARCHITECTURE.md's i18n paragraph.
    pub fn to_domain(&self) -> Operation {
        let is_complement =
            self.id_operation_parent != 0 && self.libelle == LEGACY_COMPLEMENT_LABEL;
        Operation {
            id: self.id_operation,
            label: self.libelle.clone(),
            date: windev_date(&self.date),
            amount: amount_from_json(self.montant),
            payment_mode_id: self.id_mode_operation,
            category_id: self.id_categorie,
            assignment_id: self.id_affectation,
            account_id: self.id_compte,
            operation_status_id: self.id_statut_operation,
            clearing_date: windev_date(&self.date_pointage),
            pointed_balance: amount_from_json(self.solde_pointe),
            fit_id: self.fit_id.clone(),
            payment_reference: self.reference_paiement.clone(),
            bank_statement_number: self.num_releve_banque.clone(),
            parent_operation_id: self.id_operation_parent,
            has_children: self.est_parent,
            recurring_rule_guid: self.guid_cal_op_periode.clone(),
            check_id: self.id_cheque,
            payee_id: self.id_tiers,
            project_id: self.id_projets,
            is_complement,
            // **Deux cas, et ce ne sont pas les mêmes** (Fabrice, 03/10/2026).
            //
            // Une sauvegarde ancienne ne porte pas ce champ — il vaut alors 0 :
            // l'opération date d'avant que la question ne se pose, elle est
            // tenue pour vérifiée, sinon dix ans d'historique demanderaient à
            // être contrôlés.
            //
            // Un champ qui est là mais dont la valeur ne veut rien dire, c'est
            // une anomalie : personne n'a jugé cette écriture, elle est donc
            // « À vérifier » — « s'il devait y avoir une ligne qui serait sans
            // vérification par erreur, elle devrait être à vérifier ». La
            // ranger sous « Vérifiée » cacherait justement celle qu'il faut
            // regarder.
            verification_id: match self.id_verification {
                0 => crate::operations::VERIFIED,
                known @ 1..=4 => known,
                _ => crate::operations::TO_VERIFY,
            },
        }
    }

    pub fn from_domain(o: &Operation) -> Self {
        Self {
            id_operation: o.id,
            libelle: o.label.clone(),
            date: date_to_windev(&o.date),
            montant: amount_to_json(o.amount),
            id_mode_operation: o.payment_mode_id,
            id_categorie: o.category_id,
            id_affectation: o.assignment_id,
            id_compte: o.account_id,
            id_statut_operation: o.operation_status_id,
            date_pointage: date_to_windev(&o.clearing_date),
            solde_pointe: amount_to_json(o.pointed_balance),
            fit_id: o.fit_id.clone(),
            reference_paiement: o.payment_reference.clone(),
            num_releve_banque: o.bank_statement_number.clone(),
            id_operation_parent: o.parent_operation_id,
            est_parent: o.has_children,
            guid_cal_op_periode: o.recurring_rule_guid.clone(),
            id_cheque: o.check_id,
            id_tiers: o.payee_id,
            id_projets: o.project_id,
            id_verification: o.verification_id,
            // `libelle` above already carries LEGACY_COMPLEMENT_LABEL for
            // rows where is_complement is set (the Complement mechanism, §9,
            // always names the sub-operation that way) — nothing extra to do
            // here to keep a re-exported archive readable by 1.9.3 tooling.
        }
    }
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default)]
pub struct CommentaireRow {
    #[serde(
        rename = "IDCommentaire",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_commentaire: i64,
    #[serde(
        rename = "CommentaireTxt",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub commentaire_txt: String,
    #[serde(
        rename = "IDOperation",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_operation: i64,
}

impl CommentaireRow {
    pub fn to_domain(&self) -> Comment {
        Comment {
            id: self.id_commentaire,
            text: self.commentaire_txt.clone(),
            operation_id: self.id_operation,
        }
    }
    pub fn from_domain(c: &Comment) -> Self {
        Self {
            id_commentaire: c.id,
            commentaire_txt: c.text.clone(),
            id_operation: c.operation_id,
        }
    }
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default)]
pub struct PiecesJointesRow {
    #[serde(
        rename = "IDPiecesJointes",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_pieces_jointes: i64,
    #[serde(
        rename = "IDOperation",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_operation: i64,
    #[serde(
        rename = "NomFichier",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub nom_fichier: String,
    #[serde(
        rename = "NomFichierGUID",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub nom_fichier_guid: String,
    #[serde(
        rename = "PathRelFichier",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub path_rel_fichier: String,
    #[serde(
        rename = "TailleFich",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub taille_fich: i64,
    #[serde(
        rename = "MiMeType",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub mime_type: String,
    #[serde(
        rename = "DateAjout",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub date_ajout: String,
    #[serde(
        rename = "CheckSumInfo",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub checksum_info: String,
    #[serde(
        rename = "NoteInfo",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub note_info: String,
}

impl PiecesJointesRow {
    pub fn to_domain(&self) -> Attachment {
        Attachment {
            id: self.id_pieces_jointes,
            operation_id: self.id_operation,
            original_filename: self.nom_fichier.clone(),
            stored_filename_guid: self.nom_fichier_guid.clone(),
            relative_path: self.path_rel_fichier.clone(),
            size_bytes: self.taille_fich,
            mime_type: self.mime_type.clone(),
            added_date: windev_date(&self.date_ajout),
            checksum: self.checksum_info.clone(),
            note: self.note_info.clone(),
        }
    }
    pub fn from_domain(a: &Attachment) -> Self {
        Self {
            id_pieces_jointes: a.id,
            id_operation: a.operation_id,
            nom_fichier: a.original_filename.clone(),
            nom_fichier_guid: a.stored_filename_guid.clone(),
            path_rel_fichier: a.relative_path.clone(),
            taille_fich: a.size_bytes,
            mime_type: a.mime_type.clone(),
            date_ajout: date_to_windev(&a.added_date),
            checksum_info: a.checksum.clone(),
            note_info: a.note.clone(),
        }
    }
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default)]
pub struct BudgetRow {
    #[serde(
        rename = "IDBudget",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_budget: i64,
    #[serde(
        rename = "Annee",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub annee: i64,
    #[serde(
        rename = "Mois",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub mois: i64,
    #[serde(
        rename = "IDPosteBudget",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_poste_budget: i64,
    #[serde(
        rename = "Montant",
        default = "lenient::missing_decimal",
        deserialize_with = "lenient::decimal"
    )]
    pub montant: f64,
}

impl BudgetRow {
    pub fn to_domain(&self) -> Budget {
        Budget {
            id: self.id_budget,
            year: self.annee,
            month: self.mois,
            budget_line_id: self.id_poste_budget,
            amount: amount_from_json(self.montant),
        }
    }
    pub fn from_domain(b: &Budget) -> Self {
        Self {
            id_budget: b.id,
            annee: b.year,
            mois: b.month,
            id_poste_budget: b.budget_line_id,
            montant: amount_to_json(b.amount),
        }
    }
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default)]
pub struct ModeleOperationRow {
    #[serde(
        rename = "IDModeleOperation",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_modele_operation: i64,
    #[serde(
        rename = "Libelle",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub libelle: String,
    #[serde(
        rename = "Montant",
        default = "lenient::missing_decimal",
        deserialize_with = "lenient::decimal"
    )]
    pub montant: f64,
    #[serde(
        rename = "IDModeOperation",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_mode_operation: i64,
    #[serde(
        rename = "IDCategorie",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_categorie: i64,
    #[serde(
        rename = "IDAffectation",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_affectation: i64,
    #[serde(
        rename = "IDStatutOperation",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_statut_operation: i64,
    #[serde(
        rename = "IDTiers",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_tiers: i64,
    #[serde(
        rename = "IDProjets",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_projets: i64,
}

impl ModeleOperationRow {
    pub fn to_domain(&self) -> OperationTemplate {
        OperationTemplate {
            id: self.id_modele_operation,
            label: self.libelle.clone(),
            amount: amount_from_json(self.montant),
            payment_mode_id: self.id_mode_operation,
            category_id: self.id_categorie,
            assignment_id: self.id_affectation,
            operation_status_id: self.id_statut_operation,
            payee_id: self.id_tiers,
            project_id: self.id_projets,
        }
    }
    pub fn from_domain(m: &OperationTemplate) -> Self {
        Self {
            id_modele_operation: m.id,
            libelle: m.label.clone(),
            montant: amount_to_json(m.amount),
            id_mode_operation: m.payment_mode_id,
            id_categorie: m.category_id,
            id_affectation: m.assignment_id,
            id_statut_operation: m.operation_status_id,
            id_tiers: m.payee_id,
            id_projets: m.project_id,
        }
    }
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default)]
pub struct CalOpPeriodiqueRow {
    #[serde(
        rename = "GUIDCalOpPeriode",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub guid_cal_op_periode: String,
    #[serde(
        rename = "Libelle",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub libelle: String,
    #[serde(
        rename = "IDCompte",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_compte: i64,
    #[serde(
        rename = "IDModeOperation",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_mode_operation: i64,
    #[serde(
        rename = "IDCategorie",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_categorie: i64,
    #[serde(
        rename = "IDAffectation",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_affectation: i64,
    #[serde(
        rename = "IDStatutOperation",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_statut_operation: i64,
    #[serde(
        rename = "IDTiers",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_tiers: i64,
    #[serde(
        rename = "IDProjets",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_projets: i64,
    #[serde(
        rename = "Montant",
        default = "lenient::missing_decimal",
        deserialize_with = "lenient::decimal"
    )]
    pub montant: f64,
    #[serde(
        rename = "DateProchOp",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub date_proch_op: String,
    #[serde(
        rename = "Periode",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub periode: i64,
    #[serde(
        rename = "PeriodeFreq",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub periode_freq: i64,
    #[serde(
        rename = "PeriodeNbrRepete",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub periode_nbr_repete: i64,
    #[serde(
        rename = "ModeFinInsertion",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub mode_fin_insertion: i64,
    #[serde(
        rename = "DateFin",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub date_fin: String,
    #[serde(
        rename = "DateDernOpGen",
        default = "lenient::missing_text",
        deserialize_with = "lenient::text"
    )]
    pub date_dern_op_gen: String,
    #[serde(
        rename = "NbrOpInsert",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub nbr_op_insert: i64,
    #[serde(
        rename = "NbrOpAnterieur",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub nbr_op_anterieur: i64,
    #[serde(
        rename = "MontantInsert",
        default = "lenient::missing_decimal",
        deserialize_with = "lenient::decimal"
    )]
    pub montant_insert: f64,
    #[serde(
        rename = "IDOperation",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_operation: i64,
}

impl CalOpPeriodiqueRow {
    pub fn to_domain(&self) -> RecurringOperationRule {
        RecurringOperationRule {
            guid: self.guid_cal_op_periode.clone(),
            label: self.libelle.clone(),
            account_id: self.id_compte,
            payment_mode_id: self.id_mode_operation,
            category_id: self.id_categorie,
            assignment_id: self.id_affectation,
            operation_status_id: self.id_statut_operation,
            payee_id: self.id_tiers,
            project_id: self.id_projets,
            amount: amount_from_json(self.montant),
            next_date: windev_date(&self.date_proch_op),
            period_unit: self.periode,
            period_frequency: self.periode_freq,
            repeat_count: self.periode_nbr_repete,
            end_mode: self.mode_fin_insertion,
            end_date: windev_date(&self.date_fin),
            last_generated_date: windev_date(&self.date_dern_op_gen),
            inserted_count: self.nbr_op_insert,
            previous_count: self.nbr_op_anterieur,
            generated_amount_total: amount_from_json(self.montant_insert),
            operation_id: self.id_operation,
        }
    }
    pub fn from_domain(r: &RecurringOperationRule) -> Self {
        Self {
            guid_cal_op_periode: r.guid.clone(),
            libelle: r.label.clone(),
            id_compte: r.account_id,
            id_mode_operation: r.payment_mode_id,
            id_categorie: r.category_id,
            id_affectation: r.assignment_id,
            id_statut_operation: r.operation_status_id,
            id_tiers: r.payee_id,
            id_projets: r.project_id,
            montant: amount_to_json(r.amount),
            date_proch_op: date_to_windev(&r.next_date),
            periode: r.period_unit,
            periode_freq: r.period_frequency,
            periode_nbr_repete: r.repeat_count,
            mode_fin_insertion: r.end_mode,
            date_fin: date_to_windev(&r.end_date),
            date_dern_op_gen: date_to_windev(&r.last_generated_date),
            nbr_op_insert: r.inserted_count,
            nbr_op_anterieur: r.previous_count,
            montant_insert: amount_to_json(r.generated_amount_total),
            id_operation: r.operation_id,
        }
    }
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default)]
pub struct ParametresRow {
    #[serde(
        rename = "IDParametres",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub id_parametres: i64,
    #[serde(
        rename = "RunOnce",
        default = "lenient::missing_flag",
        deserialize_with = "lenient::flag"
    )]
    pub run_once: bool,
    #[serde(
        rename = "InitValDefaut",
        default = "lenient::missing_flag",
        deserialize_with = "lenient::flag"
    )]
    pub init_val_defaut: bool,
    #[serde(
        rename = "VerSoftMajeur",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub ver_soft_majeur: i64,
    #[serde(
        rename = "VerSoftMineur",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub ver_soft_mineur: i64,
    #[serde(
        rename = "VerSoftDebug",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub ver_soft_debug: i64,
    #[serde(
        rename = "VerDataBase",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub ver_data_base: i64,
    /// Le numéro de la constante « nation » du WLangage (1 = allemand,
    /// 5 = français, 3 = anglais, 7 = espagnol, 11 = italien, 14 = portugais).
    /// **Il ne se traduit plus** : depuis la décision de Fabrice du 01/08/2026
    /// la base stocke ce nombre-là, si bien que la restauration n'a rien à
    /// convertir — et qu'une archive étrangère ne s'ouvre plus en anglais,
    /// comme elle le faisait.
    #[serde(
        rename = "UtiliseLangue",
        default = "lenient::missing_integer",
        deserialize_with = "lenient::integer"
    )]
    pub utilise_langue: i64,
}

impl ParametresRow {
    /// Maps this legacy row onto our own [`Settings`], keeping our own
    /// `db_schema_version`/software version fields untouched (they describe
    /// *this* build, not the imported Windows source — see
    /// `database::schema` module doc, point 8).
    pub fn to_domain(&self, current_schema_version: i64) -> Settings {
        Settings {
            run_once: self.run_once,
            init_default_values: self.init_val_defaut,
            software_version_major: 2,
            software_version_minor: 0,
            software_version_patch: 0,
            db_schema_version: current_schema_version,
            language: self.utilise_langue,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn d(y: i32, m: u32, day: u32) -> NaiveDate {
        NaiveDate::from_ymd_opt(y, m, day).unwrap()
    }

    #[test]
    fn windev_date_round_trips() {
        assert_eq!(windev_date("20201024"), Some(d(2020, 10, 24)));
        assert_eq!(date_to_windev(&Some(d(2020, 10, 24))), "20201024");
        assert_eq!(date_to_windev_required(d(2020, 1, 2)), "20200102");
    }

    #[test]
    fn empty_windev_date_is_none() {
        assert_eq!(windev_date(""), None);
        assert_eq!(date_to_windev(&None), "");
    }

    #[test]
    fn malformed_windev_date_is_dropped_not_panicked() {
        assert_eq!(windev_date("not-a-date"), None);
        assert_eq!(windev_date("2020102"), None);
        // Well-formed digits, impossible calendar day.
        assert_eq!(windev_date("20210230"), None);
    }

    #[test]
    fn amount_round_trips_through_micros() {
        assert_eq!(amount_from_json(5972.54), 5_972_540_000);
        assert_eq!(amount_to_json(5_972_540_000), 5972.54);
    }

    fn sample_operation_row(parent: i64, libelle: &str) -> OperationRow {
        OperationRow {
            id_operation: 99,
            libelle: libelle.to_string(),
            date: "20260101".to_string(),
            montant: 10.0,
            id_mode_operation: 0,
            id_categorie: 0,
            id_affectation: 0,
            id_compte: 1,
            id_statut_operation: 1,
            date_pointage: String::new(),
            solde_pointe: 0.0,
            fit_id: String::new(),
            reference_paiement: String::new(),
            num_releve_banque: String::new(),
            id_operation_parent: parent,
            est_parent: false,
            guid_cal_op_periode: String::new(),
            id_cheque: 0,
            id_tiers: 0,
            id_projets: 0,
            id_verification: 0,
        }
    }

    /// Une sauvegarde d'avant la base 11 ne porte pas `IDVerification` : ses
    /// opérations sont vérifiées, comme elles l'étaient sans qu'on le dise.
    /// Une valeur présente mais absurde, elle, est une anomalie : à vérifier.
    #[test]
    fn une_operation_sans_verification_est_tenue_pour_verifiee() {
        let ancienne: OperationRow = serde_json::from_str(
            r#"{ "IDOperation":1, "Libelle":"RETRAIT", "Date":"20260115", "Montant":-100, "IDCompte":1, "IDStatutOperation":1 }"#,
        )
        .unwrap();
        assert_eq!(ancienne.to_domain().verification_id, 2);

        let douteuse: OperationRow = serde_json::from_str(
            r#"{ "IDOperation":1, "Libelle":"RETRAIT", "Date":"20260115", "Montant":-100, "IDCompte":1, "IDStatutOperation":1, "IDVerification":3 }"#,
        )
        .unwrap();
        assert_eq!(douteuse.to_domain().verification_id, 3);

        let absurde: OperationRow = serde_json::from_str(
            r#"{ "IDOperation":1, "Libelle":"RETRAIT", "Montant":-100, "IDCompte":1, "IDStatutOperation":1, "IDVerification":42 }"#,
        )
        .unwrap();
        assert_eq!(absurde.to_domain().verification_id, 1, "une anomalie se regarde");

        let nulle: OperationRow = serde_json::from_str(
            r#"{ "IDOperation":1, "Libelle":"RETRAIT", "Montant":-100, "IDCompte":1, "IDStatutOperation":1, "IDVerification":null }"#,
        )
        .unwrap();
        assert_eq!(nulle.to_domain().verification_id, 2, "un champ vide vaut un champ absent");
    }

    #[test]
    fn operation_row_recognizes_legacy_complement_label() {
        let op = sample_operation_row(42, "Complément").to_domain();
        assert!(op.is_complement);
    }

    #[test]
    fn operation_row_does_not_flag_a_top_level_operation_named_complement() {
        // Only sub-operations (parent != 0) can be the Complement.
        assert!(!sample_operation_row(0, "Complément").to_domain().is_complement);
    }

    #[test]
    fn operation_row_json_field_names_match_windev_schema() {
        let json = serde_json::to_value(sample_operation_row(0, "Test")).unwrap();
        let obj = json.as_object().unwrap();
        for key in [
            "IDOperation",
            "Libelle",
            "Date",
            "Montant",
            "IDModeOperation",
            "IDCategorie",
            "IDAffectation",
            "IDCompte",
            "IDStatutOperation",
            "DatePointage",
            "SoldePointe",
            "FitID",
            "ReferencePaiement",
            "NumRelevBanque",
            "IDOperationParent",
            "EstParent",
            "GUIDCalOpPeriode",
            "IDCheque",
            "IDTiers",
            "IDProjets",
            "IDVerification",
        ] {
            assert!(obj.contains_key(key), "missing JSON field {key}");
        }
    }
}
