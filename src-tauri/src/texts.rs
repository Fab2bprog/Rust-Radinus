//! The whole vocabulary of a window, in the language the database runs in.
//!
//! The interface holds no sentence of its own (author's ruling, 25/07/2026):
//! everything it shows comes from `radinus-core`'s Fluent resources, French
//! and English alike. A window asks for its vocabulary once, as it loads, and
//! shows what it is given.
//!
//! Handing over the whole dictionary in one call rather than resolving each
//! sentence on demand is deliberate: a window that has its words before it
//! draws anything cannot flash the wrong language, and there is no round trip
//! in the middle of a keystroke.

use radinus_core::i18n::{self, Language};
use std::collections::BTreeMap;

/// Every key a window may ask for that takes no argument. Listed rather than
/// scraped from the resource: a window asking for a key that does not exist
/// must fail here, in one place, not silently show nothing.
const PLAIN_KEYS: &[&str] = &[
    "ui-loading",
    "ui-editing",
    "ui-viewing",
    "ui-modified-suffix",
    "ui-label-required",
    "ui-discard-question",
    "ui-yes",
    "ui-ok",
    "ui-no",
    "ui-select-record",
    "ui-multiselect-help",
    "ui-no-match",
    "ui-filter-placeholder",
    "ui-column-label",
    "ui-identifier",
    "ui-field-label",
    "ui-field-budget-line",
    // Les deux noms de niveau des anneaux qui se creusent. **Partagés par
    // l'accueil et F19** depuis le 04/08/2026, d'où le préfixe `ui-` : ce sont
    // les mêmes mots, et deux clefs auraient fini par ne plus dire pareil.
    "ui-legend-budget-lines",
    "ui-legend-categories",
    "ui-deletion-abandoned",
    "ui-title-filter",
    "ui-title-create",
    "ui-title-update",
    "ui-title-delete",
    "ui-title-read",
    "ui-title-close",
    "ui-title-save",
    "ui-title-add",
    "ui-title-modify",
    // These end with their colon: the message they carry is appended by the
    // window. A sentence with a hole in the middle would need the value at
    // the moment it is resolved, and these are resolved before anything has
    // gone wrong.
    "ui-load-failed",
    "ui-save-failed",
    "ui-read-failed",
    "ui-delete-failed",
    "ui-open-failed",
    "ui-close-failed",
    "ui-unknown-nomenclature",
    // The two characters a money field filters and formats with. They come
    // from the core so the interface invents no format of its own.
    "ui-thousands-separator",
    "ui-decimal-separator",
    // L'étiquette de langue du document — « fr », « en », « es ». Elle commande
    // la coupure des mots et ce qu'annonce un lecteur d'écran.
    "ui-language-tag",
];

/// Everything the welcome window says (F01, phase 17 bis).
///
/// **Only the whole sentences.** `welcome-spending`, `welcome-earning`,
/// `welcome-accounts-count` and `welcome-month` are not here and must not be:
/// they carry a hole, and a dictionary hands out finished sentences. Those
/// four are written by the `welcome` command, which holds the month and the
/// count Fluent needs to fill them.
const WELCOME_KEYS: &[&str] = &[
    "welcome-banner-title",
    "welcome-mascot-alt",
    "welcome-slogan-one",
    "welcome-slogan-two",
    "welcome-total-bank",
    "welcome-total-real",
    "welcome-total-final",
    "welcome-total-real-detail",
    "welcome-total-final-detail",
    "welcome-accounts",
    "welcome-tile-bank",
    "welcome-tile-real",
    "welcome-tile-final",
    "welcome-nothing",
    "welcome-open-account",
    "welcome-no-account",
    "welcome-no-account-create",
    "welcome-previous-month",
    "welcome-next-month",
    "welcome-refresh",
];

/// Ce que dit « À propos de l'auteur ».
const ABOUT_AUTHOR_KEYS: &[&str] = &[
    "about-author-name",
    "about-author-place",
    "about-author-flag-alt",
];

/// Ce que dit « Gestion des pièces jointes » (08/08/2026).
///
/// Les cinq états d'une pièce, la question du retrait et la phrase du bas n'y
/// sont pas : ce sont des phrases composées par le contrôleur — un état est
/// choisi parmi cinq, un total porte deux trous —, et le dictionnaire ne sert
/// que des phrases entières.
const ATTACHMENTS_MANAGER_KEYS: &[&str] = &[
    "window-attachments-manager-title",
    "attachments-column-document",
    "attachments-column-size",
    "attachments-column-added",
    "attachments-column-state",
    "attachments-manager-help",
    "attachments-show-operation",
    "attachments-reveal",
];

/// Ce que dit « Licence d'utilisation » (08/08/2026).
const LICENCE_KEYS: &[&str] = &[
    "licence-heading",
    "licence-logo-alt",
    "licence-name",
    "licence-intro",
    "licence-freedoms-title",
    "licence-freedom-use",
    "licence-freedom-study",
    "licence-freedom-share",
    "licence-freedom-improve",
    "licence-read",
    "licence-copyright",
    "licence-no-warranty",
    "licence-info",
];

/// Ce que dit « À propos de Radinus ». `about-radinus-version` n'y est pas :
/// elle porte un trou, et le dictionnaire ne sert que des phrases entières.
const ABOUT_RADINUS_KEYS: &[&str] = &[
    "about-radinus-name",
    "about-radinus-rust-alt",
    "about-radinus-tauri-alt",
    "about-radinus-built",
    "about-radinus-licence",
];

/// Ce que dit la fenêtre des préférences (F39, phase 17 ter).
const PREFERENCES_KEYS: &[&str] = &[
    "preferences-branch-display",
    "preferences-leaf-language",
    "preferences-leaf-currency",
    "preferences-leaf-zoom",
    "preferences-branch-import",
    "preferences-leaf-verification",
    "preferences-field-verification",
    "preferences-verification-hint",
    "preferences-field-zoom",
    "preferences-zoom-reset",
    "preferences-zoom-hint",
    "preferences-field-language",
    "preferences-field-currency",
    "preferences-field-custom",
    "preferences-currency-system",
    "preferences-currency-euro",
    "preferences-currency-dollar",
    "preferences-currency-canadian",
    "preferences-currency-cfa",
    "preferences-currency-cfp",
    "preferences-currency-swiss",
    "preferences-currency-none",
    "preferences-currency-custom",
    "preferences-currency-system-is",
    "preferences-currency-system-silent",
    "preferences-custom-required",
    "preferences-sign-too-long",
    "preferences-sign-not-a-number",
    "preferences-saved",
    "preferences-help",
];

/// Everything the four account windows say. Always in the dictionary: they
/// belong to no nomenclature, and a handful of extra strings costs less than
/// a second command to fetch them.
const ACCOUNT_KEYS: &[&str] = &[
    "accounts-none",
    "accounts-nothing-to-show",
    "accounts-gone",
    "accounts-fresh",
    "accounts-created",
    "accounts-updated",
    "accounts-multiselect-help",
    "accounts-select-question",
    "accounts-column-label",
    "accounts-column-bank",
    "accounts-column-type",
    "accounts-column-number",
    "accounts-column-account",
    "accounts-column-bank-balance",
    "accounts-column-real-balance",
    "accounts-column-final-balance",
    "accounts-total",
    "account-group-bank",
    "account-group-holder",
    "account-group-rib",
    "account-group-activity",
    "account-group-balances",
    "account-field-label",
    "account-field-bank",
    "account-field-type",
    "account-field-branch-address",
    "account-field-holder-name",
    "account-field-holder-address",
    "account-field-rib-bank",
    "account-field-rib-branch",
    "account-field-rib-number",
    "account-field-rib-key",
    "account-field-bic",
    "account-field-iban",
    "account-field-opening-date",
    "account-field-closing-date",
    "account-field-closed",
    "account-field-opening-pointed",
    "account-field-opening-committed",
    "account-field-opening-planned",
    // Le menu « Outils » de la fiche (F08). Seuls ses quatre intitulés sont
    // ici : ses questions et ses réponses sont écrites par le noyau, qui seul
    // sait y glisser un montant, et arrivent toutes faites.
    "account-tools",
    "account-tools-initial-balance",
    "account-tools-statistics",
    "account-tools-delete-operations",
    "accounts-choose-question",
    "ui-title-select",
    // F02 — the middle of the application.
    "operations-none",
    "operations-from",
    "operations-to",
    "operations-column-date",
    "operations-column-clearing-date",
    "operations-column-status",
    "operations-column-verification",
    "operations-column-label",
    "operations-column-category",
    "operations-column-assignment",
    "operations-column-payment-mode",
    "operations-column-payee",
    "operations-column-project",
    "operations-column-month",
    "operations-column-debit",
    "operations-column-credit",
    "operations-column-balance",
    "operations-column-comments",
    "operations-column-attachments",
    "operations-column-check",
    "operations-foot-debit",
    "operations-foot-credit",
    "operations-foot-total",
    "operations-foot-bank",
    "operations-foot-real",
    "operations-foot-final",
    "operations-menu-export",
    "operations-menu-print",
    // Phase 15 — la seule entrée du menu Impression pour l'instant, et ce
    // que la fenêtre dit quand il n'y a rien sous les yeux.
    "print-menu-operations-pdf",
    "print-menu-operations-printer",
    "print-nothing",
    // Le sélecteur d'imprimante, partagé par F02 et F32.
    "print-choose-printer",
    "print-do-print",
    "print-printers-unknown",
    // La fenêtre du journal (⌘H).
    "journal-column-step",
    "journal-column-file",
    "journal-column-table",
    "journal-column-status",
    "journal-column-error",
    "journal-column-comments",
    "journal-empty",
    "journal-help",
    "window-journal-title",
    "window-balances-title",
    // F28 — les pièces jointes.
    "window-attachments-title",
    "attachment-none",
    "attachment-title-add",
    "attachment-title-replace",
    "attachment-title-open",
    "attachment-title-remove",
    "attachment-save-first",
    "ui-cancel",
    // F32 — l'édition et l'impression du relevé d'identité bancaire.
    "rib-group-bank",
    "rib-group-holder",
    "rib-group-details",
    "rib-conditions",
    "rib-field-bank",
    "rib-field-domiciliation",
    "rib-field-holder",
    "rib-field-address",
    "rib-field-establishment",
    "rib-field-branch",
    "rib-field-number",
    "rib-field-key",
    "rib-field-bic",
    "rib-field-iban",
    "rib-declaration",
    "rib-declaration-first",
    "rib-declaration-second",
    "rib-declaration-required",
    "rib-help",
    "rib-account-gone",
    "rib-fields-read-only",
    "rib-title-print",
    "rib-title-pdf",
    "operations-menu-filter",
    "operations-menu-period",
    "operations-menu-misc",
    "operations-title-point",
    "operations-title-sub",
    "operations-title-duplicate",
    "operations-not-yet",
    // The nine entries of the Période menu, and the twelve months its two
    // year entries open on (the month names are already in the dictionary,
    // the Mois column uses them).
    "period-all",
    "period-last-year",
    "period-this-year",
    "period-whole-year",
    "period-last-month",
    "period-this-month",
    "period-last-week",
    "period-this-week",
    "period-yesterday",
    "period-today",
    // The four entries of the Filtre menu.
    "filter-all",
    "filter-pointed",
    "filter-committed",
    "filter-planned",
    "filter-by-status",
    "filter-by-verification",
    "filter-show-all",
    "month-january",
    "month-february",
    "month-march",
    "month-april",
    "month-may",
    "month-june",
    "month-july",
    "month-august",
    "month-september",
    "month-october",
    "month-november",
    "month-december",
    // F03 — the fiche opération.
    "operation-menu-identification",
    // Le menu Options de F03 (Fabrice, 04/08/2026) : l'identifiant que la
    // banque donne à une écriture, et qui empêche de l'intégrer deux fois.
    "operation-menu-options",
    "operation-fitid-edit",
    "operation-fitid-delete",
    "operation-fitid-question",
    "operation-fitid-delete-question",
    "operation-fitid-written",
    "operation-fitid-removed",
    "operation-group-identification",
    "operation-group-amount",
    "operation-group-status",
    "operation-group-classification",
    "operation-group-check",
    "operation-group-comment",
    "operation-field-label",
    "operation-field-reference",
    "operation-field-date",
    "operation-field-direction",
    "operation-field-amount",
    "operation-field-status",
    "operation-field-verification",
    "operation-field-clearing-date",
    "operation-field-category",
    "operation-field-assignment",
    "operation-field-payment-mode",
    "operation-field-payee",
    "operation-field-project",
    "operation-field-check",
    "operation-direction-debit",
    "operation-direction-credit",
    "operation-check-info",
    "operation-check-link",
    "operation-check-unlink",
    "operation-fresh",
    "operation-created",
    "operation-updated",
    "operation-gone",
    "operation-nothing-to-show",
    "operation-label-required",
    "operation-date-required",
    "operation-clearing-date-invalid",
    "operation-clearing-date-required",
    "operation-is-a-sub",
    "operation-title-comment",
    "operation-title-sub",
    "operation-title-template",
    "operation-title-attachment",
    // F04 — la fiche sous-opération.
    "sub-operation-group-amount",
    "sub-operation-field-label",
    "sub-operation-fresh",
    "sub-operation-created",
    "sub-operation-updated",
    "sub-operation-gone",
    "sub-operation-nothing-to-show",
    "sub-operation-label-required",
    "sub-operation-parent-gone",
    "sub-operation-is-the-complement",
    "operations-select-one",
    "operation-copy",
    "operations-show-children",
    "operations-hide-children",
    "operations-recurring-from",
    // F20-F24 — les six statistiques. Ce qui change d'un axe à l'autre est
    // dans ABOUT_KEYS, décliné par la clef de l'axe.
    "statistics-total",
    "statistics-sum",
    "statistics-cumulative",
    "statistics-no-account",
    "statistics-no-data",
    "statistics-detail-empty",
    "statistics-detail-none",
    "statistics-year-next",
    "statistics-year-choose",
    "statistics-year-previous",
    "statistics-column-date",
    "statistics-column-clearing-date",
    "statistics-column-label",
    "statistics-column-amount",
    "statistics-column-comments",
    "accounts-stats-multiselect-help",
    // F39 — le bilan croisé. Il emprunte tout le reste de son vocabulaire aux
    // statistiques ci-dessus : une phrase déjà écrite ne se réécrit pas.
    "crossed-balance-window-name",
    "crossed-balance-column",
    "crossed-balance-no-data",
    "crossed-balance-month-choose",
    "crossed-balance-next",
    "crossed-balance-previous",
    // L'export par clic droit, que tous les tableaux partagent.
    "export-to-excel",
    "export-to-ods",
    "export-to-csv",
    "export-to-xml",
    "export-to-json",
    "export-menu",
    "export-to",
    "copy-cell",
    "copy-rows",
    "copy-failed",
    "columns-reset",
    "columns-show-hide",
    "columns-colour",
    "columns-colour-none",
    "columns-colour-red",
    "columns-colour-orange",
    "columns-colour-pink",
    "columns-colour-pastel-green",
    "columns-colour-green",
    "columns-colour-pastel-blue",
    "columns-colour-blue",
    "columns-colour-pastel-yellow",
    "columns-colour-yellow",
    "preferences-leaf-columns",
    "preferences-columns-reset",
    "preferences-columns-reset-all",
    "preferences-columns-done",
    "preferences-columns-hint",
    "welcome-tile-counted",
    "preferences-branch-reset",
    "preferences-leaf-comfort",
    "preferences-comfort-reset",
    "preferences-comfort-hint",
    "preferences-branch-tools",
    "preferences-leaf-electricity",
    "preferences-electricity-blue",
    "preferences-electricity-hint",
    "preferences-leaf-qif",
    "preferences-field-qif-order",
    "preferences-qif-order-ask",
    "preferences-qif-order-day-month",
    "preferences-qif-order-month-day",
    "preferences-qif-order-help",
    "preferences-field-qif-label",
    "preferences-qif-label-both",
    "preferences-qif-label-payee",
    "preferences-qif-label-memo",
    "preferences-qif-label-help",
    "preferences-qif-hint",
    "preferences-comfort-question",
    "preferences-comfort-done",
    "export-all-years-excel",
    "export-all-years-ods",
    "export-all-months-excel",
    "export-all-months-ods",
    "export-no-year",
    // F19 — le tableau de bord.
    "dashboard-menu-period",
    "dashboard-menu-misc",
    "dashboard-from",
    "dashboard-to",
    "dashboard-switch-pointed",
    "dashboard-switch-committed",
    "dashboard-switch-planned",
    "dashboard-spending",
    "dashboard-earning",
    "dashboard-debits",
    "dashboard-credits",
    "dashboard-balance",
    "dashboard-unclassified",
    "dashboard-nothing",
    "dashboard-no-account",
    "dashboard-enlarge",
    // F25 — l'évolution du solde.
    "curve-heading",
    "curve-menu-period",
    "curve-total",
    "curve-from",
    "curve-to",
    "curve-axis-balance",
    "curve-nothing",
    "curve-empty",
    "analysis-heading",
    "analysis-hint",
    "analysis-zone",
    "analysis-opening",
    "analysis-closing",
    "analysis-variation",
    "analysis-detail-name",
    "analysis-detail-none",
    // F05 — la classification rapide. Les phrases qui comptent quelque chose
    // (« 34 lignes classées ») n'y sont pas : elles ont besoin du nombre, et
    // c'est Fluent qui sait si ce nombre change la phrase.
    "quick-dates-title",
    "quick-from",
    "quick-to",
    "quick-menu-period",
    "quick-change-title",
    "quick-check-category",
    "quick-check-assignment",
    "quick-check-payment-mode",
    "quick-check-payee",
    "quick-check-project",
    "quick-check-status",
    "quick-check-verification",
    "quick-column-date",
    "quick-column-label",
    "quick-column-amount",
    "quick-column-category",
    "quick-column-assignment",
    "quick-column-payment-mode",
    "quick-column-payee",
    "quick-column-project",
    "quick-column-status",
    "quick-column-verification",
    "quick-multiselect-help",
    "quick-none",
    "quick-select-lines",
    "quick-nothing-to-save",
    "quick-leave-question",
    "quick-leave-save",
    "quick-leave-discard",
    "quick-leave-stay",
    "quick-title-apply",
    "quick-title-save",
    // F17/F18 — l'importation d'un relevé bancaire. Les phrases qui comptent
    // quelque chose n'y sont pas : elles ont besoin du nombre.
    "statement-menu-filter",
    "statement-filter-all",
    "statement-filter-pending",
    "statement-filter-known",
    "statement-column-id",
    "statement-column-reconciled",
    "statement-column-fitid",
    "statement-column-date",
    "statement-column-label",
    "statement-column-debit",
    "statement-column-credit",
    "statement-account",
    "statement-file",
    "statement-difference",
    "statement-none",
    "statement-empty",
    "statement-no-match",
    "statement-help",
    "statement-choose-account",
    "statement-select-line",
    "statement-title-open",
    "statement-title-info",
    "statement-title-integrate",
    "statement-title-validate",
    "statement-duplicate",
    "statement-no-fitid",
    "statement-already-reconciled",
    "statement-mass-question",
    "statement-yes",
    "statement-no",
    "statement-cancel",
    "statement-group-identification",
    "statement-group-amount",
    "statement-group-classification",
    "statement-group-status",
    "statement-field-date",
    "statement-field-label",
    "statement-field-type",
    "statement-field-amount",
    "statement-field-mode",
    "statement-field-category",
    "statement-field-assignment",
    "statement-field-payee",
    "statement-field-project",
    "statement-field-status",
    "statement-field-clearing",
    // La fenêtre de découpage d'un relevé CSV.
    "csv-preview-title",
    "csv-settings-title",
    "csv-extraction-title",
    "csv-column-line",
    "csv-column-content",
    "csv-header-lines",
    "csv-separator",
    "csv-date-at",
    "csv-label-at",
    "csv-debit-at",
    "csv-credit-at",
    "csv-test",
    "csv-separator-semicolon",
    "csv-separator-comma",
    "csv-separator-tab",
    "csv-separator-pipe",
    "csv-separator-space",
    "csv-help",
    "csv-none",
    "csv-not-tested",
    "csv-title-validate",
    "export-nothing",
    "statistics-detail-name",
];

/// Tout ce que disent les cinq fenêtres des chéquiers et des chèques (phase 9).
/// Une liste à part, comme les comptes : elles n'appartiennent à aucune
/// nomenclature, et leur vocabulaire est cohérent — le carnet, le chèque,
/// l'association.
const CHEQUE_KEYS: &[&str] = &[
    // Les cinq titres : ils nomment aussi l'onglet du fichier exporté au clic
    // droit, et une fenêtre ne doit pas inventer son propre nom.
    "window-chequebooks-title",
    "window-chequebook-title",
    "window-cheques-title",
    "window-cheque-title",
    "window-cheque-operations-title",
    "chequebooks-column-reference",
    "chequebooks-column-date",
    "chequebooks-column-account",
    "chequebooks-column-account-number",
    "chequebooks-column-comments",
    "chequebooks-none",
    "chequebooks-nothing-to-show",
    "chequebooks-title-composition",
    "chequebooks-delete-question",
    "chequebooks-gone",
    "chequebooks-created",
    "chequebooks-updated",
    "chequebook-refusal-duplicate",
    "chequebook-refusal-reference-required",
    "chequebook-refusal-number-too-big",
    "chequebook-refusal-date",
    "chequebook-refusal-numbers-required",
    "chequebook-refusal-order",
    "chequebook-refusal-account",
    "chequebook-refusal-too-many",
    "chequebook-field-id",
    "chequebook-field-reference",
    "chequebook-field-received",
    "chequebook-field-first",
    "chequebook-field-last",
    "chequebook-field-quantity",
    "chequebook-field-account",
    "chequebook-field-comments",
    "chequebook-locked",
    "chequebook-account-missing",
    "cheques-column-number",
    "cheques-column-date",
    "cheques-column-place",
    "cheques-column-payee",
    "cheques-column-amount",
    "cheques-column-status",
    "cheques-column-comments",
    "cheques-column-operations",
    "cheques-none",
    "cheques-nothing-to-show",
    "cheques-help",
    "cheques-title-linked",
    "cheques-title-link",
    "cheques-status-changed",
    "cheque-field-id",
    "cheque-field-number",
    "cheque-field-issued",
    "cheque-field-place",
    "cheque-field-payee",
    "cheque-field-amount",
    "cheque-field-comments",
    "cheque-field-status",
    "cheque-gone",
    "cheque-updated",
    "cheque-operations-linked-title",
    "cheque-operations-choose-title",
    "cheque-operations-column-account",
    "cheque-operations-column-label",
    "cheque-operations-column-date",
    "cheque-operations-column-clearing",
    "cheque-operations-column-amount",
    "cheque-operations-column-cheque",
    "cheque-operations-none-linked",
    "cheque-operations-none",
    "cheque-operations-nothing-to-show",
    "cheque-operations-help",
    "cheque-operations-linked-help",
    "cheque-operations-linked",
    "cheque-operations-dissociated",
    "cheque-operations-menu-filter",
    "cheque-title-associate",
    "cheque-title-dissociate",
    // F36 / F37 — les modèles d'opération (phase 10).
    "window-operation-templates-title",
    "window-operation-template-title",
    "operation-templates-none",
    "operation-templates-nothing-to-show",
    "operation-templates-select-question",
    "operation-templates-delete-question",
    "operation-template-gone",
    "operation-template-fresh",
    "operation-template-created",
    "operation-template-updated",
    "operation-template-label-required",
    "operation-template-duplicate",
    "operation-template-field-id",
    "operation-template-group-name",
    "operation-template-field-label",
    "operation-template-group-amount",
    "operation-template-field-direction",
    "operation-template-field-amount",
    "operation-template-group-status",
    "operation-template-field-status",
    "operation-template-group-classification",
    "operation-template-field-category",
    "operation-template-field-assignment",
    "operation-template-field-mode",
    "operation-template-field-payee",
    "operation-template-field-project",
    "operation-template-question",
    "operation-template-apply",
    "operation-template-save-as",
    "operation-template-applied",
    "operation-template-saved-as",
    "operation-template-needs-label",
    // F26 / F39 — le budget (phase 11).
    "window-budget-entry-title",
    "window-budget-control-title",
    "budget-column-line",
    "budget-none",
    "budget-planned",
    "budget-actual",
    "budget-sum",
    "budget-cumulative",
    "budget-total",
    "budget-sign-warning",
    "budget-entry-help",
    "budget-saved",
    "budget-nothing-changed",
    "budget-discard-question",
    "budget-menu-display",
    "budget-display-money",
    "budget-display-percent",
    "budget-control-help",
    // F09 — le transfert entre deux comptes (phase 12).
    "window-transfer-title",
    // F41 — la simulation de crédit (08/10/2026).
    "window-loan-title",
    "loan-tab-credit",
    "loan-tab-afford",
    "loan-field-kind",
    "loan-field-amount",
    "loan-field-payment",
    "loan-field-months",
    "loan-field-rate",
    "loan-field-fees",
    "loan-field-insurance",
    "loan-unit-months",
    "loan-unit-percent",
    "loan-invalid-field",
    "loan-report-button",
    "loan-monthly-table",
    "loan-chart-cost",
    "loan-chart-capital",
    "loan-schedule-title",
    "loan-column-number",
    "loan-column-date",
    "loan-column-payment",
    "loan-column-interest",
    "loan-column-capital",
    "loan-column-insurance",
    "loan-column-remaining",
    "loan-history-label",
    "loan-accounts-title",
    "loan-column-account",
    "loan-column-bank",
    "loan-column-balance",
    "loan-running-title",
    "loan-running-column-label",
    "loan-running-column-monthly",
    "loan-running-column-end",
    "loan-verdict-title",
    "loan-chart-income",
    "loan-chart-history",
    "loan-chart-history-hint",
    "loan-chart-projection",
    "loan-disclaimer",
    "loan-tab-rules",
    "loan-unit-percent-year",
    "window-appliance-title",
    "appliance-device-title",
    "appliance-on-title",
    "appliance-standby-title",
    "appliance-field-on-watts",
    "appliance-field-on-hours",
    "appliance-field-days",
    "appliance-field-share",
    "appliance-field-standby-watts",
    "appliance-field-standby-hours",
    "appliance-unit-watts",
    "appliance-unit-hours",
    "appliance-unit-days",
    "appliance-unit-percent",
    "appliance-standby-hint",
    "appliance-contract-title",
    "appliance-field-option",
    "appliance-option-base",
    "appliance-option-off-peak",
    "appliance-field-base",
    "appliance-field-peak",
    "appliance-field-off-peak",
    "appliance-field-off-peak-hours",
    "appliance-contract-hint",
    "appliance-contract-reset",
    "appliance-detail-title",
    "appliance-column-part",
    "appliance-column-energy",
    "appliance-column-cost",
    "appliance-column-share",
    "appliance-chart-title",
    "appliance-note-plate",
    "appliance-note-subscription",
    // La phrase sur l'historique (Fabrice, 10/10/2026), commune au crédit, au
    // matelas, à l'objectif épargne et à la réduction.
    "analysis-history-hint",
    "window-cushion-title",
    "cushion-question",
    "cushion-accounts-title",
    "cushion-history-label",
    "cushion-column-account",
    "cushion-column-balance",
    "cushion-column-savings",
    "cushion-column-spending",
    "cushion-accounts-hint",
    "cushion-backup-label",
    "cushion-backup-hint",
    "cushion-categories-title",
    "cushion-categories-hint",
    "cushion-categories-empty",
    "cushion-verdict-title",
    "cushion-targets-title",
    "cushion-projection-title",
    "cushion-projection-hint",
    "cushion-note",
    "window-goal-title",
    "goal-accounts-title",
    "goal-column-account",
    "goal-column-balance",
    "goal-accounts-hint",
    "goal-period-label",
    "goal-period-range",
    "goal-range-from",
    "goal-range-to",
    "goal-question-title",
    "goal-question-when",
    "goal-question-amount",
    "goal-question-effort",
    "goal-field-target",
    "goal-field-date",
    "goal-field-rate",
    "goal-field-extra",
    "goal-options-hint",
    "goal-answer-title",
    "goal-chart-title",
    "goal-chart-hint",
    "goal-disclaimer",
    "window-cut-title",
    "cut-axis-label",
    "cut-axis-category",
    "cut-axis-payee",
    "cut-axis-budget-line",
    "cut-table-title",
    "cut-column-monthly",
    "cut-column-cut",
    "cut-column-after",
    "cut-column-yearly",
    "cut-horizon-label",
    "cut-settings-title",
    "cut-options-hint",
    "cut-report-button",
    "cut-file-filter",
    "cut-chart-title",
    "cut-chart-hint",
    "cut-donut-title",
    "window-holiday-title",
    "holiday-trip-title",
    "holiday-trip-stay",
    "holiday-trip-cruise",
    "holiday-field-adults",
    "holiday-field-children",
    "holiday-field-nights",
    "holiday-field-months",
    "holiday-field-stops",
    "holiday-saved-title",
    "holiday-saved-hint",
    "holiday-budget-title",
    "holiday-budget-hint",
    "holiday-optional-title",
    "holiday-result-title",
    "holiday-donut-title",
    "holiday-child-label",
    "holiday-count-label",
    "holiday-open",
    "holiday-save",
    "holiday-pdf",
    "holiday-excel",
    "holiday-file-filter",
    "car-battery-title",
    "car-column-amount",
    "car-column-changes",
    "car-column-consumption",
    "car-column-date",
    "car-column-detail",
    "car-column-energy",
    "car-column-garage",
    "car-column-km",
    "car-column-last",
    "car-column-life",
    "car-column-next",
    "car-column-note",
    "car-column-part",
    "car-column-per-km",
    "car-column-price",
    "car-column-quantity",
    "car-column-rubric",
    "car-deadlines-title",
    "car-delete-question",
    "car-disclaimer",
    "car-donut-title",
    "car-energy-title",
    "car-entry-add",
    "car-entry-cancel",
    "car-entry-delete",
    "car-entry-edit",
    "car-entry-new",
    "car-entry-update",
    "car-field-acquired",
    "car-field-acquired-km",
    "car-field-amount",
    "car-field-axle",
    "car-field-battery",
    "car-field-charge",
    "car-field-date",
    "car-field-energy",
    "car-field-engine",
    "car-field-first-hand",
    "car-field-garage",
    "car-field-km",
    "car-field-make",
    "car-field-model",
    "car-field-months",
    "car-field-note",
    "car-field-part",
    "car-field-part-name",
    "car-field-plate",
    "car-field-quantity",
    "car-field-registered",
    "car-field-rubric",
    "car-field-service",
    "car-field-service-or",
    "car-field-slot",
    "car-field-verdict",
    "car-file-filter",
    "car-filter-all",
    "car-from-operation",
    "car-history-empty",
    "car-history-hint",
    "car-history-title",
    "car-home-amount-hint",
    "car-open",
    "car-parts-title",
    "car-pick-account",
    "car-pick-none",
    "car-pick-operation",
    "car-pick-take",
    "car-pick-taken",
    "car-replace-question",
    "car-report-button",
    "car-save",
    "car-sheet-title",
    "car-tariff-hint",
    "car-tariff-reset",
    "car-tariff-title",
    "car-tyres-title",
    "car-unit-km",
    "car-unit-months-short",
    "car-years-title",
    // F48 — « Partager une dépense » (Fabrice, 11/10/2026, P-71).
    "sharing-add-item",
    "sharing-add-payment",
    "sharing-add-person",
    "sharing-balances-title",
    "sharing-column-alone",
    "sharing-column-amount",
    "sharing-column-balance",
    "sharing-column-cap",
    "sharing-column-constraint",
    "sharing-column-date",
    "sharing-column-due",
    "sharing-column-fixed",
    "sharing-column-floor",
    "sharing-column-gift",
    "sharing-column-household",
    "sharing-column-income",
    "sharing-column-item",
    "sharing-column-label",
    "sharing-column-members",
    "sharing-column-paid",
    "sharing-column-parts",
    "sharing-column-percent",
    "sharing-column-person",
    "sharing-column-rule",
    "sharing-column-share",
    "sharing-column-typed",
    "sharing-column-unit",
    "sharing-column-who",
    "sharing-common",
    "sharing-delete",
    "sharing-delete-person-question",
    "sharing-help-household",
    "sharing-help-income",
    "sharing-help-parts",
    "sharing-help-percent",
    "sharing-help-floor",
    "sharing-help-cap",
    "sharing-help-fixed",
    "sharing-help-alone",
    "sharing-help-gift",
    "sharing-help-items",
    "sharing-help-due",
    "sharing-help-share",
    "sharing-help-typed",
    "sharing-help-constraint",
    "sharing-help-item",
    "sharing-help-rule",
    "sharing-help-paid",
    "sharing-help-balance",
    "sharing-apply-advice",
    "sharing-help-apply-advice",
    "sharing-from-incomes",
    "sharing-help-from-incomes",
    "sharing-reset-percents",
    "sharing-help-reset-percents",
    "sharing-reset-percents-question",
    "sharing-disclaimer",
    "sharing-excel",
    "sharing-field-label",
    "sharing-field-rule",
    "sharing-field-total",
    "sharing-file-filter",
    "sharing-hide-incomes",
    "sharing-items-hint",
    "sharing-items-title",
    "sharing-label-hint",
    "sharing-mode-item",
    "sharing-mode-whole",
    "sharing-open",
    "sharing-payments-hint",
    "sharing-payments-title",
    "sharing-pdf-distribution",
    "sharing-pdf-payments",
    "sharing-pdf-statements",
    "sharing-people-hint",
    "sharing-people-title",
    "sharing-question",
    "sharing-replace-question",
    "sharing-result-title",
    "sharing-round-euro",
    "sharing-rule-equal",
    "sharing-rule-income",
    "sharing-rule-parts",
    "sharing-rule-percent",
    "sharing-save",
    "sharing-setup-title",
    "sharing-statements-everyone",
    "sharing-total-hint",
    "sharing-transfers-title",
    "window-sharing-title",
    "window-car-title",
    "holiday-replace-question",
    "holiday-who-all",
    "holiday-who-person",
    "holiday-who-adults",
    "holiday-column-line",
    "holiday-column-amount",
    "holiday-column-child",
    "holiday-column-who",
    "holiday-column-span",
    "holiday-column-cost",
    "holiday-disclaimer",
    "transfer-group-source",
    "transfer-group-target",
    "transfer-group-description",
    "transfer-group-nomenclature",
    "transfer-group-amount",
    "transfer-field-source",
    "transfer-field-target",
    "transfer-field-label",
    "transfer-field-reference",
    "transfer-field-date",
    "transfer-field-status",
    "transfer-field-clearing",
    "transfer-field-category",
    "transfer-field-mode",
    "transfer-field-assignment",
    "transfer-field-payee",
    "transfer-field-project",
    "transfer-field-amount",
    "transfer-help",
    "transfer-title-validate",
    "chequebooks-select-question",
    "cheques-select-question",
    "operation-check-save-first",
    "operation-check-none",
    // Phase 13 — l'importation d'une feuille Excel. Les phrases qui dépendent
    // de la nomenclature (les quatre politiques, le titre de colonne de la
    // fenêtre d'association) ne sont **pas** ici : elles se demandent avec leur
    // valeur, par les commandes qui la connaissent.
    "excel-backup-question",
    // **La sauvegarde de la base ouverte est branchée** (10/08/2026) : c'est
    // elle qui parle quand elle réussit, et cette clef-ci ne sert plus qu'au
    // cas où l'appel lui-même échoue — pas de base ouverte, racine
    // introuvable. `excel-backup-later`, le message qui disait que la
    // sauvegarde n'existait pas, a disparu avec le trou qu'il annonçait.
    "backup-not-started",
    "excel-group-file",
    "excel-pick",
    "excel-sheet",
    "excel-group-header",
    "excel-header-row",
    "excel-first-column",
    "excel-column-count",
    "excel-group-rows",
    "excel-first-data-row",
    "excel-last-data-row",
    "excel-group-shape",
    "excel-shape-single",
    "excel-shape-debit-credit",
    "excel-shape-note",
    "excel-group-test",
    "excel-test",
    "excel-test-note",
    "excel-help",
    "excel-no-file",
    "excel-not-tested",
    "excel-empty-capture",
    "excel-title-next",
    "excel-tab-links",
    "excel-tab-settings",
    "excel-column-excel",
    "excel-column-radinus",
    "excel-links-help",
    "excel-group-category",
    "excel-group-payment-mode",
    "excel-group-assignment",
    "excel-define-destination",
    "excel-fields-help",
    "excel-title-import",
    "excel-column-data",
    "excel-association-help",
    "excel-association-none",
    "excel-report-title",
    "excel-column-row",
    "excel-column-content",
    "excel-column-reason",
    "excel-nothing-refused",
    // Phase 14 — les huit sorties que le menu Export de F02 ajoute aux quatre
    // déjà en place.
    "export-to-word",
    "export-to-tsv",
    "export-to-ini",
    "export-to-toml",
    "export-to-yaml",
    "export-to-ofx",
    "export-to-qif",
    // Phase 16 — les opérations périodiques. Les phrases à trou (les comptes
    // rendus, la question de la corbeille) se demandent par commande.
    "recurring-column-label",
    "recurring-none",
    "recurring-help",
    "recurring-title-calendar",
    "recurring-gone",
    "recurring-delete-question",
    "recurring-group-identity",
    "recurring-group-nomenclature",
    "recurring-group-amount",
    "recurring-group-period",
    "recurring-group-ending",
    "recurring-group-produced",
    "recurring-field-id",
    "recurring-field-account",
    "recurring-field-label",
    "recurring-field-category",
    "recurring-field-mode",
    "recurring-field-assignment",
    "recurring-field-payee",
    "recurring-field-project",
    "recurring-field-direction",
    "recurring-field-amount",
    "recurring-field-next",
    "recurring-field-every",
    "recurring-field-end-date",
    "recurring-field-repeat",
    "recurring-field-guid",
    "recurring-field-produced-count",
    "recurring-field-produced-last",
    "recurring-field-produced-total",
    "recurring-unit-day",
    "recurring-unit-week",
    "recurring-unit-month",
    "recurring-unit-quarter",
    "recurring-unit-year",
    "recurring-ending-no-limit",
    "recurring-ending-until-date",
    "recurring-ending-repeat-count",
    "recurring-title-erase",
    "recurring-erase-none",
    "recurring-calendar-help",
    "recurring-calendar-none",
    "recurring-calendar-column-account",
    "recurring-calendar-column-date",
    "recurring-calendar-column-label",
    "recurring-calendar-column-amount",
    "recurring-calendar-column-category",
    "recurring-calendar-column-assignment",
    "recurring-calendar-column-mode",
    "recurring-calendar-column-payee",
    "recurring-calendar-column-project",
    "recurring-title-insert",
    "recurring-nothing",
    // Le sélecteur de base (02/08/2026). La fenêtre du choix de la langue n'a
    // rien ici : elle n'emploie aucune phrase, puisqu'au moment où elle
    // s'affiche il n'y a pas de langue dans laquelle en écrire une.
    "databases-column-label",
    "databases-column-comment",
    "databases-column-folder",
    "databases-column-created",
    "databases-none",
    "databases-help",
    "databases-select",
    // Le menu Outils de la fenêtre des bases (Fabrice, 04/08/2026). Ses quatre
    // entrées reprennent les intitulés du menu général qu'elles quittent : ce
    // sont les mêmes gestes, ils gardent leurs mots.
    "databases-tools",
    // Le menu Paramètres de la fenêtre des bases (04/08/2026). Ses deux mots
    // sont ceux du menu général et de F39 : c'est le même réglage, il porte le
    // même nom d'un bout à l'autre du logiciel.
    "menu-settings",
    "menu-settings-preferences",
    // `preferences-leaf-language` n'est pas répété ici : il est déjà servi par
    // la liste des préférences, et le dictionnaire est un dictionnaire — une
    // clef écrite deux fois n'y entre qu'une fois, et le compte ne tombait plus.
    // La fiche d'une base neuve (04/08/2026). Une seule clef à elle : son
    // titre. Les champs reprennent les mots que le sélecteur employait déjà, et
    // la devise ceux de F39 — deux fenêtres qui demandent la même chose la
    // demandent des mêmes mots.
    "window-database-form-title",
    "database-group-identity",
    "database-group-restore",
    "database-choose-backup",
    "database-no-backup",
    "menu-file-backup",
    "menu-file-restore",
    "menu-file-repair",
    "menu-file-log",
    "menu-tools-password",
    "menu-file-disconnect",
    "databases-title-open",
    "databases-title-delete",
    "database-quit-first",
    "database-field-label",
    "database-field-comment",
    // La protection par mot de passe (Fabrice, 05/08/2026). Le sélecteur a
    // besoin de deux mots — l'entrée de son menu contextuel et la question de
    // sa boîte de dialogue —, la fiche des six autres.
    "password-protect",
    "password-ask",
    "password-group-database",
    "password-group-password",
    "password-group-warning",
    "password-field-old",
    "password-field-new",
    "password-field-repeat",
    "password-hint",
    "password-lost-warning",
    "password-show",
    "password-remove-question",
    // Le titre de la fenêtre du calendrier sert aussi de nom au fichier
    // qu'elle exporte : la fenêtre le reçoit donc, comme un mot ordinaire, en
    // plus du titre que le noyau lui pose sur la barre.
    "window-recurring-calendar-title",
];

/// Sentences that depend on the nomenclature the window is working on.
const ABOUT_KEYS: &[&str] = &[
    // Les trois mots qui changent d'une statistique à l'autre : le titre de la
    // colonne de l'axe, la ligne des non classées, et le nom de la fenêtre —
    // qui sert aussi de nom d'onglet à l'export.
    "statistics-axis-column",
    "statistics-unclassified",
    "statistics-window-name",
    "nomenclature-identifier",
    "nomenclature-none",
    "nomenclature-nothing-to-show",
    "nomenclature-gone",
    "nomenclature-fresh",
    "nomenclature-created",
    "nomenclature-updated",
];

/// The dictionary a window gets. Ordered, so two runs give the same thing and
/// a test can compare it.
pub type Dictionary = BTreeMap<String, String>;

/// Builds the dictionary for `kind`, in `language`. The sentences that also
/// need a number or a label are not here: they are asked for one at a time,
/// with their value, by the command that knows it.
/// **The five sentences that name a keyboard key**, and which one it is.
///
/// Adding a row to a selection is `Ctrl` on Windows and Linux, and `⌘` on a
/// Mac — where `Ctrl` + click is a right click, so the hint was not merely
/// unhelpful, it was telling people to open a context menu.
///
/// Fabrice found it on Windows on 05/08/2026, and the fault ran both ways:
/// three of these sentences said `CTRL`, wrong on macOS, and two said `CMD`,
/// wrong on Windows — someone had fixed two windows by hand and left the rest.
const MODIFIER_KEYS: &[&str] = &[
    "ui-multiselect-help",
    "accounts-multiselect-help",
    "accounts-stats-multiselect-help",
    "quick-multiselect-help",
    "statement-help",
];

/// The name of the key that adds to a selection on this machine.
///
/// **`⌘` in all eighteen languages** on a Mac: it is what is engraved on the
/// key, and an engraving is not translated. Everywhere else the name comes from
/// the language file — `CTRL` in most, `STRG` in German, and free for any
/// language whose keyboards say otherwise.
fn modifier_key(language: Language) -> String {
    if cfg!(target_os = "macos") {
        "⌘".to_string()
    } else {
        i18n::text(language, "ui-key-multiselect")
    }
}

/// `kind` est la clef stable d'une nomenclature ou d'un axe des statistiques
/// — une chaîne, et non une `Nomenclature` : le septième axe, la vérification,
/// n'en est pas une, et sa fenêtre a droit à son vocabulaire comme les autres.
pub fn dictionary(language: Language, kind: Option<&str>) -> Dictionary {
    let mut texts = Dictionary::new();
    for key in PLAIN_KEYS
        .iter()
        .chain(ACCOUNT_KEYS)
        .chain(CHEQUE_KEYS)
        .chain(WELCOME_KEYS)
        .chain(PREFERENCES_KEYS)
        .chain(ABOUT_AUTHOR_KEYS)
        .chain(ABOUT_RADINUS_KEYS)
        .chain(LICENCE_KEYS)
        .chain(ATTACHMENTS_MANAGER_KEYS)
    {
        texts.insert((*key).to_string(), i18n::text(language, key));
    }
    // **Filled here, so the window receives a finished sentence.** A view of
    // Radinus holds no sentence and composes none; a hole left open would make
    // it compose one, and the guard below refuses that outright.
    let modifier = modifier_key(language);
    for key in MODIFIER_KEYS {
        texts.insert(
            (*key).to_string(),
            i18n::text_with(language, key, "modifier", &modifier),
        );
    }
    if let Some(kind) = kind {
        for key in ABOUT_KEYS {
            texts.insert((*key).to_string(), i18n::about(language, key, kind));
        }
    }
    texts
}

#[cfg(test)]
mod tests {
    use super::*;
    use radinus_core::nomenclatures::Nomenclature;

    /// Nothing may come back empty: an empty string is a label that vanishes
    /// from the window without anyone noticing.
    ///
    /// Et rien ne doit revenir égal à sa propre clef : c'est ce que rend
    /// Fluent quand la clef manque dans ce fichier de langue-là. Une langue
    /// ajoutée avec un mot oublié afficherait « account-tools » sur son
    /// bouton — la faute du 02/08/2026, dans son autre moitié.
    ///
    /// **Toutes les langues du logiciel**, et non plus les deux premières :
    /// `Language::all()` en tient la liste, si bien qu'une langue de plus est
    /// vérifiée le jour même où elle est déclarée.
    #[test]
    fn every_word_of_every_window_exists_in_every_language() {
        for language in Language::all() {
            // Les nomenclatures, **et les axes des statistiques** : le
            // septième, la vérification, n'est pas une nomenclature, et sa
            // fenêtre demande son vocabulaire sous son propre nom.
            let kinds: std::collections::BTreeSet<&'static str> = radinus_core::nomenclatures::ALL
                .iter()
                .map(|kind| kind.key())
                .chain(radinus_core::statistics::AXES.iter().map(|axis| axis.key()))
                .collect();
            for kind in kinds {
                let texts = dictionary(language, Some(kind));
                assert_eq!(
                    texts.len(),
                    PLAIN_KEYS.len()
                        + ACCOUNT_KEYS.len()
                        + CHEQUE_KEYS.len()
                        + WELCOME_KEYS.len()
                        + PREFERENCES_KEYS.len()
                        + ABOUT_AUTHOR_KEYS.len()
                        + ABOUT_RADINUS_KEYS.len()
                        + LICENCE_KEYS.len()
                        + ATTACHMENTS_MANAGER_KEYS.len()
                        + ABOUT_KEYS.len()
                );
                for (key, value) in &texts {
                    assert!(
                        !value.is_empty(),
                        "{key} est vide pour {} en {}",
                        kind,
                        language.tag()
                    );
                    assert!(
                        value != key,
                        "{key} manque au fichier {} : la fenêtre afficherait \
                         la clef elle-même",
                        language.tag()
                    );
                }
            }
        }
    }

    /// **Le dictionnaire ne porte que des phrases entières.** Une phrase à
    /// trou — « Opérations pointées { $state } » — ne peut pas y être : la
    /// fenêtre la recevrait telle quelle et devrait remplir le trou
    /// elle-même, ce qu'aucune fenêtre ne doit faire. Seule Fluent sait où
    /// est le trou.
    ///
    /// La faute a été commise deux fois — le total de la sélection de F02,
    /// puis les cinq interrupteurs de F20, qui se sont tous appelés
    /// « statistics-switch-pointed » à l'écran (Fabrice, 26/07/2026). Ce test
    /// la rend impossible une troisième fois : une clef à argument glissée
    /// dans la liste échoue ici, au moment du `cargo test`, et non sur
    /// l'écran de l'utilisateur.
    /// **Aucune phrase ne grave le nom d'une touche en dur.**
    ///
    /// La faute que Fabrice a vue sous Windows le 05/08/2026 : cinq phrases
    /// nommaient une touche, trois disaient `CTRL` — faux sur un Mac, où c'est
    /// `⌘` et où `Ctrl` + clic est un clic droit — et deux disaient `CMD`, faux
    /// sur Windows. Quelqu'un en avait corrigé deux à la main et laissé les
    /// autres, ce qui est exactement la façon dont ce genre de faute se répand.
    ///
    /// Le nom de la touche se demande maintenant au système. Ce test refuse
    /// qu'on le regrave, dans n'importe laquelle des dix-huit langues.
    #[test]
    fn aucune_phrase_ne_grave_le_nom_dune_touche() {
        let root = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
            .parent()
            .expect("racine du projet")
            .join("radinus-core/i18n");

        let mut faulty: Vec<String> = Vec::new();
        for entry in std::fs::read_dir(&root).expect("le dossier des langues") {
            let path = entry.expect("une entrée").path();
            if path.extension().and_then(|e| e.to_str()) != Some("ftl") {
                continue;
            }
            let text = std::fs::read_to_string(&path).expect("lecture");
            for line in text.lines() {
                // La déclaration du nom de la touche est la seule qui ait le
                // droit de le porter : c'est elle qu'on remplit.
                if line.starts_with("ui-key-multiselect") {
                    continue;
                }
                for engraved in ["[CTRL]", "[CMD]", "[STRG]", "[⌘]"] {
                    if line.contains(engraved) {
                        faulty.push(format!(
                            "{} : {engraved}",
                            path.file_name().unwrap_or_default().to_string_lossy()
                        ));
                    }
                }
            }
        }

        assert!(
            faulty.is_empty(),
            "ces phrases gravent le nom d'une touche au lieu de le demander au \
             système : elles seront fausses sur l'autre moitié des machines. \
             Écrivez « [{{ $modifier }}] » et ajoutez la clef à MODIFIER_KEYS : {faulty:?}"
        );
    }

    #[test]
    fn the_dictionary_never_hands_out_a_sentence_with_a_hole_in_it() {
        for language in [Language::French, Language::English] {
            for (key, value) in dictionary(language, Some(Nomenclature::Category.key())) {
                assert!(
                    !value.contains('{'),
                    "{key} est une phrase à trou : elle se demande avec sa valeur, \
                     par une commande, et n'a rien à faire au dictionnaire — « {value} »"
                );
            }
        }
    }

    /// **Les six statistiques ne s'appellent pas toutes pareil.**
    ///
    /// Les trois mots qui changent d'un axe à l'autre — le titre de la colonne,
    /// la ligne des non classées, le nom de la fenêtre — doivent être six mots
    /// différents. Une déclinaison oubliée dans Fluent ne casse rien : elle
    /// retombe sur le cas par défaut, et les six fenêtres affichent
    /// « NomCategorie » sans que personne ne s'en aperçoive avant d'ouvrir la
    /// deuxième. C'est exactement ce qui est arrivé aux cinq interrupteurs le
    /// 26/07/2026, et c'est pour cela que ce test existe.
    #[test]
    fn each_statistic_is_named_after_its_own_axis() {
        use radinus_core::statistics::AXES;

        for language in [Language::French, Language::English] {
            for key in [
                "statistics-axis-column",
                "statistics-unclassified",
                "statistics-window-name",
            ] {
                let mut said: Vec<String> = AXES
                    .iter()
                    .map(|axis| i18n::about(language, key, axis.key()))
                    .collect();
                assert!(
                    said.iter().all(|word| !word.is_empty()),
                    "{key} est vide sur au moins un axe"
                );
                let count = said.len();
                said.sort();
                said.dedup();
                assert_eq!(
                    said.len(),
                    count,
                    "{key} ne distingue pas les six axes en {language:?} : {said:?}"
                );
            }

            // Et le titre de la fenêtre elle-même, qui vit dans windows.rs.
            let mut titles: Vec<String> = AXES
                .iter()
                .map(|axis| i18n::about(language, "window-statistics-title", axis.key()))
                .collect();
            let count = titles.len();
            titles.sort();
            titles.dedup();
            assert_eq!(titles.len(), count, "les six fenêtres portent le même titre");
        }
    }

    /// The two languages really are two languages.
    #[test]
    fn the_two_languages_do_not_say_the_same_thing() {
        let french = dictionary(Language::French, Some(Nomenclature::Payee.key()));
        let english = dictionary(Language::English, Some(Nomenclature::Payee.key()));
        assert_eq!(french["nomenclature-fresh"], "Nouveau tiers.");
        assert_eq!(english["nomenclature-fresh"], "New payee.");
        assert_eq!(french["ui-yes"], "Oui");
        assert_eq!(english["ui-yes"], "Yes");
    }
}
