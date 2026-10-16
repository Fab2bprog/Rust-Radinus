//! radinus-core — the Model layer of Radinus 2.0.0.
//!
//! Independent Rust library holding all business rules, SQLite persistence,
//! import/export, backup, and repair logic. Depends on no UI framework and no
//! Tauri crate (see `08_ARCHITECTURE.md` §2.1 in the reverse-engineering
//! dossier). Compilable and testable in complete isolation with `cargo test`.
//!
//! Module layout mirrors the table in `08_ARCHITECTURE.md` §2.1. Module names
//! are in English per the project's coding convention; the dossier reference
//! column below maps each one back to its French-language specification.

/// First end-to-end IPC command used to validate the Vue -> Controller ->
/// Core chain (Phase 0, milestone 0). Returns a fixed string on purpose: this
/// function carries no business logic, it only proves the chain works.
pub fn ping() -> String {
    "pong".to_string()
}

/// Portable-folder detection and first-launch tree creation.
/// Dossier reference: 08_ARCHITECTURE.md §3bis, 01_CAHIER_DES_CHARGES.md §3.3 bis.
pub mod location;

/// SQLite persistence: connection helpers, the 21-table schema, migrations,
/// prefilled reference data, and the max+1 key generator (Phase 1 §1.1/§1.2).
/// Dossier reference: 08_ARCHITECTURE.md §2.1 ("persistance"), 02_BASE_DE_DONNEES.md.
pub mod dashboard;
pub mod database;

/// Core-side localization (Fluent). Empty French/English resources for now;
/// filled in progressively as user-facing core messages are written.
/// Dossier reference: 08_ARCHITECTURE.md §2.1 ("i18n").
pub mod i18n;

// --- Modules planned by the architecture but not yet implemented ---
// Each is declared empty on purpose, to fix the crate's shape ahead of the
// phase that fills it in (see PLAN_ACTION.md for phase numbers). Do not add
// logic to these before their phase starts.

/// Entities and closed lists (Account, Operation, Category, Check, Checkbook,
/// RecurringOperationRule, OperationTemplate, Budget, nomenclatures; statuses
/// 1/2/3, Debit/Credit) — implemented Phase 1 §1.1, mirroring `database::schema`.
/// Dossier reference: 02_BASE_DE_DONNEES.md §3, §5.
pub mod domain;

/// Text helpers shared by the modules that order French labels (the
/// collation measured on the author's archive) — Phase 2 §2.3.
pub mod text;

/// The seven user-editable nomenclatures: deletion with reassignment to
/// "Non précisé", and the alphabetical ordering of lists and combos —
/// implemented Phase 2 §2.3, ported from the author's `Enreg_Supprimer`.
/// Dossier reference: 02_BASE_DE_DONNEES.md §7 rules 2, 5, 6.
pub mod nomenclatures;

/// The three balance algorithms + SoldePointe — implemented Phase 2 §2.1,
/// ported from the author's WinDev source (`Maj_SoldeBanque`, `Maj_SoldeReel`,
/// `Maj_SoldeFinal`). Dossier reference: 02_BASE_DE_DONNEES.md §8.
/// Bank accounts: the `Compte` table and the four windows built on it.
pub mod accounts;

/// Writing and reading an amount, in the language of the interface.
pub mod money;

pub mod balance_curve;
pub mod balances;

/// The operations of an account, as the list window reads them — a tree, not
/// a flat run of rows.
pub mod operations;

/// The "Complement" sub-operation mechanism and parent/child sync (Phase 2).
/// Dossier reference: 02_BASE_DE_DONNEES.md §9.
pub mod sheets;
pub mod statistics;

/// **Le bilan croisé** (F39, demandé par Fabrice le 25/08/2026) : les
/// catégories en lignes, les affectations en colonnes, sur un mois. Les six
/// statistiques croisent une nomenclature avec le temps ; celle-ci croise deux
/// nomenclatures entre elles et fixe le temps.
pub mod crossed_balance;
pub mod sub_operations;

/// Le transfert d'un montant entre deux comptes (phase 12) : **deux écritures
/// qui partent ensemble ou pas du tout**, et les deux soldes recalculés.
/// Référence : 04_SPECIFICATIONS_FENETRES.md F09.
pub mod transfers;

/// F01 — ce que la fenêtre d'accueil montre : les trois totaux des comptes
/// ouverts et les deux anneaux du mois en cours (phase 17 bis). **Aucun calcul
/// propre** : il compose `accounts` et `dashboard`, pour que l'accueil ne
/// puisse pas contredire F07 ni F19.
/// Référence : 04_SPECIFICATIONS_FENETRES.md F01.
/// La table `Preferences` — le magasin clef/valeur JSON que la 1.x portait
/// sans jamais l'employer (phase 17 ter). **Rien n'y entre que ce que Fabrice
/// a demandé d'y mettre** ; une seule clef existe, `devise`.
/// Référence : 02_BASE_DE_DONNEES.md §3.13, 04_SPECIFICATIONS_FENETRES.md F39.
pub mod preferences;

pub mod welcome;

/// Le budget (phase 11) : la saisie par poste budgétaire (F26) et le contrôle
/// du budget contre le réalisé (F39). **Deux portes, deux questions** — et la
/// convention de signe des opérations, qui rend le prévu et le réalisé
/// directement comparables. Référence : 02_BASE_DE_DONNEES.md §3.9,
/// 04_SPECIFICATIONS_FENETRES.md F26 et F39.
pub mod budget;

/// Les modèles d'opération (phase 10) : une saisie toute faite, que l'on
/// applique à une fiche opération pour ne pas retaper. **Appliquer écrase
/// l'écran et n'écrit rien** — c'est la validation de la fiche qui écrit (règle
/// de Fabrice, 29/07/2026). Référence : 02_BASE_DE_DONNEES.md §3.8,
/// 04_SPECIFICATIONS_FENETRES.md F36 et F37.
pub mod operation_templates;

/// Les chéquiers (phase 9) : un carnet naît entier — ses N chèques sont créés
/// avec lui — et sa numérotation est figée dès qu'il existe. Portage de
/// `Code Fiche Chequier.txt` et `Code Liste Chequier.txt`. Référence :
/// 02_BASE_DE_DONNEES.md §3.5, 04_SPECIFICATIONS_FENETRES.md F13 et F31.
pub mod chequebooks;

/// Les chèques (phase 9) : la composition d'un carnet, la fiche d'un chèque,
/// et l'association chèque↔opération à deux visages. Portage de
/// `Code Fiche Cheque.txt`, `Code liste cheques.txt` et
/// `Code Liste Operation Cheques.txt`. Référence : 02_BASE_DE_DONNEES.md §3.6,
/// 04_SPECIFICATIONS_FENETRES.md F12 et F14.
pub mod cheques;

/// F05 — la classification rapide des opérations (phase 7). La structure en
/// RAM qui tient tout un compte, le motif de la réserve, et l'enregistrement
/// qui n'écrit que ce qui diffère. Référence : 04_SPECIFICATIONS_FENETRES.md
/// F05, et les règles dictées par Fabrice le 27/07/2026.
pub mod quick_classification;

/// Recurring-operation schedule generation (Phase 14). Dossier reference:
/// 02_BASE_DE_DONNEES.md §3.7. Uses the author's `time_compute` crate once
/// this module is implemented (see dependency registry, 08_ARCHITECTURE.md).
pub mod recurring_operations;

/// La lecture d'un fichier OFX (phase 8, module stratégique) — le portage de
/// la classe `Ofx_Import` de Fabrice et, surtout, de son esprit : on ne lit pas
/// du XML, on isole un conteneur, on nettoie, on découpe sur `<`, on reconnaît
/// par le préfixe, et l'on ignore tout le reste. Référence :
/// 06_FORMATS_SAUVEGARDE_IMPORT_EXPORT.md §2.1, `POINT 28 Ofx_Import est une
/// Classe.txt`. Le rapprochement et l'intégration ne sont pas ici.
pub mod ofx_import;

/// Le relevé bancaire au format CSV (phase 8) : la fenêtre de découpage, et
/// la bascule vers la fenêtre d'intégration « comme si c'était de l'OFX »
/// (demande de Fabrice, 27/07/2026). Référence : capture « Point 14 Import
/// CSV.png ». À ne pas confondre avec `csv_excel_import`, qui est l'import de
/// données de la phase 13.
pub mod csv_statement;

/// Le relevé bancaire au format QIF (15/10/2026) : la même fenêtre, les mêmes
/// boutons que l'OFX (demande de Fabrice), et un module à part pour que la
/// lecture OFX ne bouge pas d'une ligne. Rend le même `ofx_import::Statement`.
pub mod qif_import;

/// CSV and Excel import (Phase 13). Uses the author's `office-toolkit` crate
/// for the Excel side once this module is implemented (see dependency
/// registry, 08_ARCHITECTURE.md). Dossier reference:
/// 06_FORMATS_SAUVEGARDE_IMPORT_EXPORT.md §2.2-2.3.
pub mod csv_excel_import;

/// QIF/OFX/CSV/TSV/JSON/XML/INI/YAML/TOML/Excel export (Phase 13). Dossier
/// reference: 06_FORMATS_SAUVEGARDE_IMPORT_EXPORT.md §3.
pub mod exports;

/// Zip backup/restore, including Radinus 1.9.3 (Windows) archives — strategic,
/// non-negotiable requirement (Phase 1). Dossier reference:
/// 06_FORMATS_SAUVEGARDE_IMPORT_EXPORT.md §1.
pub mod backup;

/// Attachment file handling: GUID renaming, checksums (Phase 5). Dossier
/// reference: 06_FORMATS_SAUVEGARDE_IMPORT_EXPORT.md §1.5.
pub mod attachments;

/// Database repair: reindexing, balance recalculation, sub-operation
/// consistency check (Phase 15). Dossier reference:
/// 06_FORMATS_SAUVEGARDE_IMPORT_EXPORT.md §6.
pub mod repair;

/// PDF statement generation: transaction list, RIB (Phase 13). Dossier
/// reference: 06_FORMATS_SAUVEGARDE_IMPORT_EXPORT.md §4.
pub mod statements;

/// Les impressions et états : la liste des opérations d'un compte, le RIB, et
/// les états à venir. Composition par Typst, PDF fabriqué par le noyau —
/// phase 15. Dossier reference: 04_SPECIFICATIONS_FENETRES.md (menu Impression
/// de F02), 08_ARCHITECTURE.md §2.1.
pub mod printing;

/// Le journal des opérations techniques : sauvegarde, restauration,
/// réparation. Six colonnes, celles de son `Ajoute_Log`, et **la dernière
/// opération seulement** — phase 17. Dossier reference:
/// 06_FORMATS_SAUVEGARDE_IMPORT_EXPORT.md §5.
pub mod journal;

/// La simulation de crédit — F41 (Fabrice, 08/10/2026) : le calcul du prêt à
/// taux fixe, et ce que l'historique de la base dit de la capacité à le
/// rembourser. Ses graphiques et son rapport à côté.
pub mod loan;
pub mod loan_charts;
pub mod loan_report;

/// Ce que coûte un appareil électrique — F42 (Fabrice, 09/10/2026) : allumé et
/// en veille, en heures pleines et en heures creuses.
pub mod appliance;

/// Mon matelas de sécurité — F43 (Fabrice, 09/10/2026) : combien de mois
/// l'épargne tiendrait si les revenus s'arrêtaient.
pub mod cushion;

/// Objectif Épargne — F44 (Fabrice, 10/10/2026) : quand aurai-je ce montant,
/// combien aurai-je à cette date, combien épargner par mois.
pub mod savings_goal;

/// Et si je réduisais… ? — F45 (Fabrice, 10/10/2026) : réduire des postes de
/// dépense, et voir ce que ça change dans le temps.
pub mod cutback;

/// Préparer mes vacances — F46 (Fabrice, 10/10/2026) : ce que coûtera le
/// prochain voyage, séjour ou croisière.
pub mod holiday;
pub mod car;

/// Partager une dépense — F48 (Fabrice, 11/10/2026, P-71) : qui paie quoi,
/// avec des contraintes, et où en sont les règlements.
pub mod sharing;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn ping_returns_pong() {
        assert_eq!(ping(), "pong");
    }
}
