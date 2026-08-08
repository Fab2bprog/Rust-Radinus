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
            #[serde(rename = $id_field)]
            pub id: i64,
            #[serde(rename = "Libelle")]
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
    #[serde(rename = "IDBanques")]
    pub id_banques: i64,
    #[serde(rename = "NomBanque")]
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
    #[serde(rename = "IDStatutCheque")]
    pub id_statut_cheque: i64,
    #[serde(rename = "Libelle")]
    pub libelle: String,
    #[serde(rename = "Description")]
    pub description: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default)]
pub struct CategorieRow {
    #[serde(rename = "IDCategorie")]
    pub id_categorie: i64,
    #[serde(rename = "Libelle")]
    pub libelle: String,
    #[serde(rename = "IDTypeCategorie")]
    pub id_type_categorie: i64,
    #[serde(rename = "IDPosteBudget")]
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
    #[serde(rename = "IDPreferences")]
    pub id_preferences: i64,
    #[serde(rename = "Cle")]
    pub cle: String,
    #[serde(rename = "ValeurJSON")]
    pub valeur_json: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(default)]
pub struct CompteRow {
    #[serde(rename = "IDCompte")]
    pub id_compte: i64,
    #[serde(rename = "Libelle")]
    pub libelle: String,
    #[serde(rename = "IDTypeCompte")]
    pub id_type_compte: i64,
    #[serde(rename = "IDBanques")]
    pub id_banques: i64,
    #[serde(rename = "ReportPointe")]
    pub report_pointe: f64,
    #[serde(rename = "ReportEngage")]
    pub report_engage: f64,
    #[serde(rename = "ReportPrevu")]
    pub report_prevu: f64,
    #[serde(rename = "SoldeBanque")]
    pub solde_banque: f64,
    #[serde(rename = "SoldeReel")]
    pub solde_reel: f64,
    #[serde(rename = "SoldeFinal")]
    pub solde_final: f64,
    #[serde(rename = "NomTitulaire")]
    pub nom_titulaire: String,
    #[serde(rename = "AdresseTitulaire")]
    pub adresse_titulaire: String,
    #[serde(rename = "COBCodeBanque")]
    pub cob_code_banque: String,
    #[serde(rename = "COBCodeGuichet")]
    pub cob_code_guichet: String,
    #[serde(rename = "COBNumCompte")]
    pub cob_num_compte: String,
    #[serde(rename = "COBClefRIB")]
    pub cob_clef_rib: String,
    #[serde(rename = "COBIBAN")]
    pub cob_iban: String,
    #[serde(rename = "COBBIC")]
    pub cob_bic: String,
    #[serde(rename = "AdresseAgenceBank")]
    pub adresse_agence_bank: String,
    #[serde(rename = "DateOuverture")]
    pub date_ouverture: String,
    #[serde(rename = "DateCloture")]
    pub date_cloture: String,
    #[serde(rename = "NumProchCheque")]
    pub num_proch_cheque: i64,
    #[serde(rename = "CompteCloture")]
    pub compte_cloture: bool,
    #[serde(rename = "Devise")]
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
    #[serde(rename = "IDChequier")]
    pub id_chequier: i64,
    #[serde(rename = "IDReferenceChq")]
    pub id_reference_chq: String,
    #[serde(rename = "DateRecep")]
    pub date_recep: String,
    #[serde(rename = "NumPremierChq")]
    pub num_premier_chq: i64,
    #[serde(rename = "NumDernChq")]
    pub num_dern_chq: i64,
    #[serde(rename = "QteChq")]
    pub qte_chq: i64,
    #[serde(rename = "FormatNumChq")]
    pub format_num_chq: i64,
    #[serde(rename = "Commentaires")]
    pub commentaires: String,
    #[serde(rename = "IDCompte")]
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
    #[serde(rename = "IDCheque")]
    pub id_cheque: i64,
    #[serde(rename = "NumChq")]
    pub num_chq: i64,
    #[serde(rename = "IDChequier")]
    pub id_chequier: i64,
    #[serde(rename = "DateEmission")]
    pub date_emission: String,
    #[serde(rename = "Beneficiaire")]
    pub beneficiaire: String,
    #[serde(rename = "Montant")]
    pub montant: f64,
    #[serde(rename = "Commentaires")]
    pub commentaires: String,
    #[serde(rename = "LieuEmission")]
    pub lieu_emission: String,
    #[serde(rename = "IDStatutCheque")]
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
    #[serde(rename = "IDOperation")]
    pub id_operation: i64,
    #[serde(rename = "Libelle")]
    pub libelle: String,
    #[serde(rename = "Date")]
    pub date: String,
    #[serde(rename = "Montant")]
    pub montant: f64,
    #[serde(rename = "IDModeOperation")]
    pub id_mode_operation: i64,
    #[serde(rename = "IDCategorie")]
    pub id_categorie: i64,
    #[serde(rename = "IDAffectation")]
    pub id_affectation: i64,
    #[serde(rename = "IDCompte")]
    pub id_compte: i64,
    #[serde(rename = "IDStatutOperation")]
    pub id_statut_operation: i64,
    #[serde(rename = "DatePointage")]
    pub date_pointage: String,
    #[serde(rename = "SoldePointe")]
    pub solde_pointe: f64,
    #[serde(rename = "FitID")]
    pub fit_id: String,
    #[serde(rename = "ReferencePaiement")]
    pub reference_paiement: String,
    #[serde(rename = "NumRelevBanque")]
    pub num_releve_banque: String,
    #[serde(rename = "IDOperationParent")]
    pub id_operation_parent: i64,
    #[serde(rename = "EstParent")]
    pub est_parent: bool,
    #[serde(rename = "GUIDCalOpPeriode")]
    pub guid_cal_op_periode: String,
    #[serde(rename = "IDCheque")]
    pub id_cheque: i64,
    #[serde(rename = "IDTiers")]
    pub id_tiers: i64,
    #[serde(rename = "IDProjets")]
    pub id_projets: i64,
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
    #[serde(rename = "IDCommentaire")]
    pub id_commentaire: i64,
    #[serde(rename = "CommentaireTxt")]
    pub commentaire_txt: String,
    #[serde(rename = "IDOperation")]
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
    #[serde(rename = "IDPiecesJointes")]
    pub id_pieces_jointes: i64,
    #[serde(rename = "IDOperation")]
    pub id_operation: i64,
    #[serde(rename = "NomFichier")]
    pub nom_fichier: String,
    #[serde(rename = "NomFichierGUID")]
    pub nom_fichier_guid: String,
    #[serde(rename = "PathRelFichier")]
    pub path_rel_fichier: String,
    #[serde(rename = "TailleFich")]
    pub taille_fich: i64,
    #[serde(rename = "MiMeType")]
    pub mime_type: String,
    #[serde(rename = "DateAjout")]
    pub date_ajout: String,
    #[serde(rename = "CheckSumInfo")]
    pub checksum_info: String,
    #[serde(rename = "NoteInfo")]
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
    #[serde(rename = "IDBudget")]
    pub id_budget: i64,
    #[serde(rename = "Annee")]
    pub annee: i64,
    #[serde(rename = "Mois")]
    pub mois: i64,
    #[serde(rename = "IDPosteBudget")]
    pub id_poste_budget: i64,
    #[serde(rename = "Montant")]
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
    #[serde(rename = "IDModeleOperation")]
    pub id_modele_operation: i64,
    #[serde(rename = "Libelle")]
    pub libelle: String,
    #[serde(rename = "Montant")]
    pub montant: f64,
    #[serde(rename = "IDModeOperation")]
    pub id_mode_operation: i64,
    #[serde(rename = "IDCategorie")]
    pub id_categorie: i64,
    #[serde(rename = "IDAffectation")]
    pub id_affectation: i64,
    #[serde(rename = "IDStatutOperation")]
    pub id_statut_operation: i64,
    #[serde(rename = "IDTiers")]
    pub id_tiers: i64,
    #[serde(rename = "IDProjets")]
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
    #[serde(rename = "GUIDCalOpPeriode")]
    pub guid_cal_op_periode: String,
    #[serde(rename = "Libelle")]
    pub libelle: String,
    #[serde(rename = "IDCompte")]
    pub id_compte: i64,
    #[serde(rename = "IDModeOperation")]
    pub id_mode_operation: i64,
    #[serde(rename = "IDCategorie")]
    pub id_categorie: i64,
    #[serde(rename = "IDAffectation")]
    pub id_affectation: i64,
    #[serde(rename = "IDStatutOperation")]
    pub id_statut_operation: i64,
    #[serde(rename = "IDTiers")]
    pub id_tiers: i64,
    #[serde(rename = "IDProjets")]
    pub id_projets: i64,
    #[serde(rename = "Montant")]
    pub montant: f64,
    #[serde(rename = "DateProchOp")]
    pub date_proch_op: String,
    #[serde(rename = "Periode")]
    pub periode: i64,
    #[serde(rename = "PeriodeFreq")]
    pub periode_freq: i64,
    #[serde(rename = "PeriodeNbrRepete")]
    pub periode_nbr_repete: i64,
    #[serde(rename = "ModeFinInsertion")]
    pub mode_fin_insertion: i64,
    #[serde(rename = "DateFin")]
    pub date_fin: String,
    #[serde(rename = "DateDernOpGen")]
    pub date_dern_op_gen: String,
    #[serde(rename = "NbrOpInsert")]
    pub nbr_op_insert: i64,
    #[serde(rename = "NbrOpAnterieur")]
    pub nbr_op_anterieur: i64,
    #[serde(rename = "MontantInsert")]
    pub montant_insert: f64,
    #[serde(rename = "IDOperation")]
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
    #[serde(rename = "IDParametres", default)]
    pub id_parametres: i64,
    #[serde(rename = "RunOnce")]
    pub run_once: bool,
    #[serde(rename = "InitValDefaut")]
    pub init_val_defaut: bool,
    #[serde(rename = "VerSoftMajeur")]
    pub ver_soft_majeur: i64,
    #[serde(rename = "VerSoftMineur")]
    pub ver_soft_mineur: i64,
    #[serde(rename = "VerSoftDebug")]
    pub ver_soft_debug: i64,
    #[serde(rename = "VerDataBase")]
    pub ver_data_base: i64,
    /// Le numéro de la constante « nation » du WLangage (1 = allemand,
    /// 5 = français, 3 = anglais, 7 = espagnol, 11 = italien, 14 = portugais).
    /// **Il ne se traduit plus** : depuis la décision de Fabrice du 01/08/2026
    /// la base stocke ce nombre-là, si bien que la restauration n'a rien à
    /// convertir — et qu'une archive étrangère ne s'ouvre plus en anglais,
    /// comme elle le faisait.
    #[serde(rename = "UtiliseLangue")]
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
        }
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
        ] {
            assert!(obj.contains_key(key), "missing JSON field {key}");
        }
    }
}
