//! Opening the application's windows.
//!
//! macOS gets independent system windows rather than a MDI area — the
//! author's decision, recorded in 03_CHARTE_GRAPHIQUE.md §3.1. Each one is a
//! separate HTML page under `ui/windows/`, so a window carries only its own
//! markup and script.
//!
//! Reopening a window that is already there brings it to the front instead of
//! creating a second copy, which is how the original behaves.
//!
//! **The seven nomenclatures share one pair of pages.** 04_SPECIFICATIONS
//! _FENETRES.md says it outright — "gabarit identique pour les fiches
//! Affectation, Mode, Tiers, Projet, Poste budgétaire, Banque — sans le champ
//! Poste budgétaire", and the same for the lists. The category windows were
//! built first, hammered by Fabrice until they were right, and are now that
//! template: F10 and F11 are one page each, told which nomenclature they are
//! working on. Seven copies of this code would have meant seven copies of
//! every fault we spent a day removing.

use radinus_core::i18n::{self, Language};
use radinus_core::nomenclatures::Nomenclature;
use radinus_core::statistics::Axis;
use tauri::{AppHandle, Emitter, EventTarget, Manager, Runtime, WebviewUrl, WebviewWindowBuilder};

/// A window this build knows how to open.
///
/// `Clone` parce que sous Windows la construction part sur un fil séparé et
/// que la spécification doit l'y suivre — voir [`open`].
#[derive(Clone)]
pub struct WindowSpec {
    pub label: String,
    pub url: String,
    pub title: String,
    pub width: f64,
    pub height: f64,
    /// Whether the system's own close button is enabled. **It never is**
    /// (author's decision, 25/07/2026): a Radinus window is left through its
    /// door, the way every window of the original is, and that leaves a
    /// single way out to guard instead of two — no unsaved work can slip
    /// away through a second exit. macOS greys the red dot out and Windows
    /// greys the cross; on Linux GTK "will do its best to convince the window
    /// manager", so the button may survive on some desktops — the door works
    /// everywhere regardless.
    pub closable: bool,
    /// Whether the window can be zoomed and minimized. A form is a fixed set
    /// of fields: nothing is gained by blowing it up or sending it to the
    /// Dock (author's decision, same day).
    pub resizable_chrome: bool,
    /// Label of the window this one belongs to, if any. A child window stays
    /// above its parent on all three systems and goes away with it — a form
    /// can no longer be lost behind its list, nor left orphaned when the list
    /// is gone (author's decision, 25/07/2026).
    ///
    /// The relation is one-way: closing the form leaves the list open, so
    /// records can be worked through one after another without reopening
    /// anything.
    pub parent: Option<String>,
}

/// F11 — the list of a nomenclature. The original window is very tall
/// (1240x1570); it opens resizable at a workable size instead (author's
/// decision, 25/07/2026).
pub fn list_window(kind: Nomenclature, language: Language) -> WindowSpec {
    WindowSpec {
        label: format!("{}-list", kind.key()),
        url: format!("ui/windows/nomenclature-list.html?kind={}", kind.key()),
        title: i18n::about(language, "window-list-title", kind.key()),
        width: 900.0,
        height: 700.0,
        closable: false,
        // A list is worth enlarging: it is a table, and a long one.
        resizable_chrome: true,
        parent: None,
    }
}

/// F10 — the fiche of a nomenclature.
pub fn form_window(kind: Nomenclature, language: Language) -> WindowSpec {
    WindowSpec {
        label: format!("{}-form", kind.key()),
        url: format!("ui/windows/nomenclature-form.html?kind={}", kind.key()),
        title: i18n::about(language, "window-form-title", kind.key()),
        width: 1000.0,
        // The category fiche has one field more than the others.
        height: if kind.has_budget_line() { 420.0 } else { 360.0 },
        closable: false,
        resizable_chrome: false,
        parent: Some(format!("{}-list", kind.key())),
    }
}

/// Ce que l'on vient faire dans la liste des comptes. **Une page, trois
/// fenêtres** — le même principe que les sept nomenclatures, et il tient tant
/// que les différences restent des paramètres plutôt que des copies.
///
/// Le troisième usage a été confirmé par Fabrice le 26/07/2026 : une
/// statistique se calcule sur plusieurs comptes, alors que gérer les
/// opérations n'en regarde qu'un.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AccountsPurpose {
    /// F04 — gérer : créer, modifier, supprimer, consulter. Sélection
    /// multiple, puisqu'on supprime plusieurs comptes d'un coup.
    Manage,
    /// F06, premier usage — choisir **un** compte pour ouvrir ses opérations.
    /// Sélection unique : la liste des opérations ne montre jamais deux
    /// comptes à la fois.
    OneAccount,
    /// F06, second usage — choisir **plusieurs** comptes pour une statistique,
    /// dont la matrice fait leur synthèse.
    ManyAccounts,
}

impl AccountsPurpose {
    /// Ce que la page lit dans son adresse.
    pub fn key(self) -> &'static str {
        match self {
            Self::Manage => "CRUD",
            Self::OneAccount => "SEL",
            Self::ManyAccounts => "STATS",
        }
    }

    /// L'étiquette de la fenêtre. **Trois étiquettes distinctes** : laisser la
    /// gestion ouverte pendant qu'une statistique demande sur quels comptes
    /// travailler est parfaitement raisonnable, et une seule étiquette les
    /// ferait se réutiliser l'une l'autre.
    pub fn label(self) -> &'static str {
        match self {
            Self::Manage => "accounts-list",
            Self::OneAccount => "accounts-select",
            Self::ManyAccounts => "accounts-stats",
        }
    }

    fn title_key(self) -> &'static str {
        match self {
            Self::Manage => "window-accounts-title",
            Self::OneAccount | Self::ManyAccounts => "window-accounts-select-title",
        }
    }

    /// Reconnaît un usage envoyé par une fenêtre. Inconnu : la gestion, qui
    /// est le seul usage où l'on ne peut rien perdre par erreur.
    pub fn from_key(key: &str) -> Self {
        match key {
            "SEL" => Self::OneAccount,
            "STATS" => Self::ManyAccounts,
            _ => Self::Manage,
        }
    }
}

/// F04 — « Gestion des comptes bancaires », et F06, la même page dans ses deux
/// modes de choix : les boutons de gestion s'effacent et une question est
/// posée au-dessus du tableau (04_SPECIFICATIONS_FENETRES.md).
pub fn accounts_list_window(language: Language, purpose: AccountsPurpose) -> WindowSpec {
    WindowSpec {
        label: purpose.label().to_string(),
        url: format!("ui/windows/accounts-list.html?mode={}", purpose.key()),
        title: i18n::text(language, purpose.title_key()),
        width: 1100.0,
        height: 700.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

/// F20-F24 — les six statistiques, **une page et six fenêtres**.
///
/// Les catégories ont servi de modèle et Fabrice les a validées le
/// 26/07/2026 ; les cinq autres en sont sorties le jour même. Comme les sept
/// nomenclatures, elles partagent une seule page et l'axe arrive dans
/// l'adresse — mais chacune a **son étiquette à elle**, donc sa propre
/// fenêtre : on veut pouvoir regarder les catégories et les tiers côte à côte,
/// et non l'un chasser l'autre.
/// **L'axe est dans l'adresse, et c'est ce qui manquait** (faute signalée par
/// Fabrice le 26/07/2026 : « je vais dans n'importe quelle statistique, je
/// retrouve celles par catégorie »). L'étiquette portait bien l'axe, la page
/// non — et la page, faute de le trouver, retombait sur les catégories. Six
/// fenêtres différentes qui montraient toutes la même chose : des chiffres
/// justes sous un titre faux, la même sorte de faute que les comptes de la
/// veille.
pub fn statistics_window(language: Language, axis: Axis) -> WindowSpec {
    WindowSpec {
        label: format!("statistics-{}", axis.key()),
        url: format!("ui/windows/statistics.html?axis={}", axis.key()),
        title: i18n::about(language, "window-statistics-title", axis.key()),
        width: 1600.0,
        height: 900.0,
        closable: false,
        // Une matrice de treize colonnes et soixante lignes : c'est une
        // fenêtre que l'on agrandit.
        resizable_chrome: true,
        parent: None,
    }
}

/// F39 — « Bilan croisé » : les catégories en lignes, les affectations en
/// colonnes, sur un mois (demande de Fabrice, 25/08/2026).
///
/// Comme les statistiques, il se calcule sur plusieurs comptes et passe donc
/// par le choix des comptes avant de s'ouvrir. Une seule fenêtre, sans axe à
/// nommer : ses deux axes sont fixés par ce qu'elle est.
pub fn crossed_balance_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "crossed-balance".to_string(),
        url: "ui/windows/crossed-balance.html".to_string(),
        title: i18n::text(language, "window-crossed-balance-title"),
        width: 1600.0,
        height: 900.0,
        closable: false,
        // Autant de colonnes que d'affectations, autant de lignes que de
        // catégories : c'est une fenêtre que l'on agrandit.
        resizable_chrome: true,
        parent: None,
    }
}

/// F19 — « Tableau de bord ».
///
/// Comme les statistiques, il se calcule sur plusieurs comptes et passe donc
/// par le choix des comptes avant de s'ouvrir (décision de Fabrice,
/// 26/07/2026).
pub fn dashboard_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "dashboard".to_string(),
        url: "ui/windows/dashboard.html".to_string(),
        title: i18n::text(language, "window-dashboard-title"),
        width: 1400.0,
        height: 950.0,
        closable: false,
        // Cinq cartes qui gagnent à respirer.
        resizable_chrome: true,
        parent: None,
    }
}

/// F25 — « Evolution du solde ».
pub fn balance_curves_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "balance-curves".to_string(),
        url: "ui/windows/balance-curves.html".to_string(),
        title: i18n::text(language, "window-curve-title"),
        width: 1500.0,
        height: 900.0,
        closable: false,
        // Un graphique gagne toujours à être agrandi.
        resizable_chrome: true,
        parent: None,
    }
}

/// F40 — « Analyse Évolution du solde » (Fabrice, 05/10/2026) : le graphique
/// de F25, et sous lui le tableau des opérations de la zone qu'on y trace.
/// Une fenêtre à elle, distincte de F25 — « Graphique, on se concentre sur le
/// solde ; Analyse, c'est une vision plus approfondie ».
pub fn balance_analysis_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "balance-analysis".to_string(),
        url: "ui/windows/balance-analysis.html".to_string(),
        title: i18n::text(language, "window-analysis-title"),
        width: 1500.0,
        height: 950.0,
        closable: false,
        // Un graphique et un tableau : les deux gagnent à être agrandis.
        resizable_chrome: true,
        parent: None,
    }
}

/// F41 — « Simulation de crédit » (Fabrice, 08/10/2026), menu Divers, sous la
/// calculatrice. Deux onglets — « Le crédit » et « Puis-je le rembourser ? » —
/// sous les curseurs, des graphiques et un tableau : elle gagne à être
/// agrandie.
pub fn loan_simulation_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "loan-simulation".to_string(),
        url: "ui/windows/loan-simulation.html".to_string(),
        title: i18n::text(language, "window-loan-title"),
        width: 1320.0,
        height: 940.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

/// F42 — « Consommation d'un appareil électrique » (Fabrice, 09/10/2026),
/// menu Outils, sous la simulation de crédit. Une page sans onglet : l'appareil
/// et le contrat en haut, le résultat dessous.
pub fn appliance_cost_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "appliance-cost".to_string(),
        url: "ui/windows/appliance-cost.html".to_string(),
        title: i18n::text(language, "window-appliance-title"),
        width: 1180.0,
        height: 860.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

/// F43 — « Mon matelas de sécurité » (Fabrice, 09/10/2026), menu Outils,
/// sous la consommation d'un appareil électrique.
pub fn safety_cushion_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "safety-cushion".to_string(),
        url: "ui/windows/safety-cushion.html".to_string(),
        title: i18n::text(language, "window-cushion-title"),
        width: 1260.0,
        height: 900.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

/// F44 — « Objectif Épargne » (Fabrice, 10/10/2026), menu Outils, sous le
/// matelas de sécurité.
pub fn savings_goal_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "savings-goal".to_string(),
        url: "ui/windows/savings-goal.html".to_string(),
        title: i18n::text(language, "window-goal-title"),
        width: 1280.0,
        height: 920.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

/// F45 — « Et si je réduisais… ? » (Fabrice, 10/10/2026), menu Outils, sous
/// l'objectif d'épargne.
pub fn spending_cut_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "spending-cut".to_string(),
        url: "ui/windows/spending-cut.html".to_string(),
        title: i18n::text(language, "window-cut-title"),
        width: 1320.0,
        height: 940.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

/// F46 — « Préparer mes vacances » (Fabrice, 10/10/2026), menu Outils, sous
/// « Et si je réduisais… ? ».
pub fn holiday_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "holiday".to_string(),
        url: "ui/windows/holiday.html".to_string(),
        title: i18n::text(language, "window-holiday-title"),
        width: 1340.0,
        height: 940.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

/// F47 — « Carnet de ma voiture » (Fabrice, 10/10/2026), menu Outils, sous
/// « Préparer mes vacances ».
pub fn car_logbook_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "car-logbook".to_string(),
        url: "ui/windows/car-logbook.html".to_string(),
        title: i18n::text(language, "window-car-title"),
        width: 1380.0,
        height: 960.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

/// F48 — « Partager une dépense » (Fabrice, 11/10/2026, P-71), menu Outils,
/// sous « Carnet de ma voiture ». La seule fenêtre d'outil qui s'ouvre sans
/// base : elle n'en lit rien.
pub fn sharing_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "sharing".to_string(),
        url: "ui/windows/sharing.html".to_string(),
        title: i18n::text(language, "window-sharing-title"),
        width: 1440.0,
        height: 960.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

/// F08 — « Fiche compte ». The tallest fiche of the application: five framed
/// groups, and the blue control line under them.
pub fn account_form_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "account-form".to_string(),
        url: "ui/windows/account-form.html".to_string(),
        title: i18n::text(language, "window-account-title"),
        width: 1000.0,
        height: 860.0,
        closable: false,
        resizable_chrome: false,
        parent: Some("accounts-list".to_string()),
    }
}

/// « À propos de Radinus » (menu Paramètres, 03/08/2026).
pub fn about_radinus_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "about-radinus".to_string(),
        url: "ui/windows/about-radinus.html".to_string(),
        title: i18n::text(language, "window-about-radinus-title"),
        width: 520.0,
        height: 560.0,
        closable: false,
        resizable_chrome: false,
        parent: None,
    }
}

/// « À propos de l'auteur » (menu Paramètres, 03/08/2026).
///
/// Petite et fixe : elle n'a rien à montrer qu'on puisse vouloir agrandir.
pub fn about_author_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "about-author".to_string(),
        url: "ui/windows/about-author.html".to_string(),
        title: i18n::text(language, "window-about-author-title"),
        width: 520.0,
        height: 480.0,
        closable: false,
        resizable_chrome: false,
        parent: None,
    }
}

/// « Gestion des pièces jointes » (menu Paramètres, 08/08/2026).
///
/// Large et redimensionnable, contrairement aux trois petites fenêtres de la
/// famille « À propos » : elle porte sept colonnes et autant de lignes qu'il y
/// a de documents joints dans toute la base.
pub fn attachments_manager_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "attachments-manager".to_string(),
        url: "ui/windows/attachments-manager.html".to_string(),
        title: i18n::text(language, "window-attachments-manager-title"),
        width: 1040.0,
        height: 560.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

/// « Licence d'utilisation » (menu Paramètres, 08/08/2026).
///
/// Taller than its two sisters and for one reason: it carries a logo, a title,
/// a sentence and four lines under them. Fixed all the same — there is nothing
/// in it one could want to enlarge.
pub fn licence_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "licence".to_string(),
        url: "ui/windows/licence.html".to_string(),
        title: i18n::text(language, "window-licence-title"),
        width: 560.0,
        height: 620.0,
        closable: false,
        resizable_chrome: false,
        parent: None,
    }
}

/// F39 — « Préférences » (phase 17 ter).
///
/// Arbre à gauche, champs de l'option choisie au milieu, bande ardoise à
/// droite : le gabarit des fiches, dans le sens de toutes les autres fenêtres
/// de Radinus. Redimensionnable, parce que l'arbre grandira.
pub fn preferences_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "preferences".to_string(),
        url: "ui/windows/preferences.html".to_string(),
        title: i18n::text(language, "window-preferences-title"),
        width: 760.0,
        height: 480.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

/// F07 — « Soldes de vos comptes ». Nothing to do in it but read and leave.
pub fn balances_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "balances".to_string(),
        url: "ui/windows/balances.html".to_string(),
        title: i18n::text(language, "window-balances-title"),
        width: 820.0,
        height: 620.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

/// **Le choix de la langue au tout premier lancement** (décision de Fabrice,
/// 02/08/2026 : « si Radinus démarre sans base, on demande avant tout le
/// choix de la langue »).
///
/// Son titre est le nom du logiciel et rien d'autre, et c'est la seule
/// fenêtre dont ce soit vrai : à ce moment-là aucune langue n'est choisie,
/// donc aucune phrase ne peut être écrite. Cette fenêtre n'en a pas besoin —
/// une liste où chaque ligne est écrite dans sa propre langue se comprend
/// sans qu'on sache déjà laquelle l'utilisateur parle.
pub fn language_choice_window() -> WindowSpec {
    WindowSpec {
        label: "language-choice".to_string(),
        url: "ui/windows/language-choice.html".to_string(),
        title: "Radinus".to_string(),
        width: 540.0,
        height: 470.0,
        closable: false,
        resizable_chrome: false,
        parent: None,
    }
}

/// **Le sélecteur de base** (décision de Fabrice, 02/08/2026). Il montre ce
/// que `databases/` contient vraiment, et jamais une liste mémorisée :
/// l'utilisateur a le droit de renommer, copier et effacer ses dossiers hors
/// du logiciel, et ce qui est sur le disque fait foi.
pub fn database_selector_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "database-selector".to_string(),
        url: "ui/windows/database-selector.html".to_string(),
        title: i18n::text(language, "window-database-selector-title"),
        width: 960.0,
        height: 580.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

/// F02 — « Liste opérations du compte : <nom du compte> ». The middle of the
/// application, and the only window whose title carries data: the account it
/// is about.
pub fn operations_window(language: Language, account_label: &str) -> WindowSpec {
    WindowSpec {
        label: "operations".to_string(),
        url: "ui/windows/operations-list.html".to_string(),
        title: i18n::text_with(language, "window-operations-title", "account", account_label),
        width: 1500.0,
        height: 860.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

/// F05 — « Classification rapide des opérations ».
///
/// **Un compte, et un seul** (règle de Fabrice, 27/07/2026, la première qu'il
/// a donnée sur cette fenêtre) : on y entre par le choix d'un compte unique,
/// comme dans la liste des opérations, et non par celui de plusieurs comme les
/// statistiques. Son titre le nomme, pour la même raison que F02 : on n'y
/// travaille jamais que sur un compte, et il ne doit y avoir aucun doute sur
/// lequel.
///
/// Grande, et agrandissable : c'est un tableau qu'on parcourt en masse, et
/// tout l'intérêt de la fenêtre est d'y voir beaucoup de lignes à la fois.
pub fn quick_classification_window(language: Language, account_label: &str) -> WindowSpec {
    WindowSpec {
        label: "quick-classification".to_string(),
        url: "ui/windows/quick-classification.html".to_string(),
        title: i18n::text_with(
            language,
            "window-quick-classification-title",
            "account",
            account_label,
        ),
        width: 1600.0,
        height: 900.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

/// F17 — « Importation de relevés de comptes bancaires ».
///
/// **Un compte, et un seul**, comme F02 et F05 : on choisit le compte dans
/// lequel on importe avant que la fenêtre s'ouvre, et son nom est dans le
/// titre — on n'importe jamais « quelque part », on importe dans un compte.
pub fn statement_import_window(language: Language, account_label: &str) -> WindowSpec {
    WindowSpec {
        label: "statement-import".to_string(),
        url: "ui/windows/statement-import.html".to_string(),
        title: i18n::text_with(
            language,
            "window-statement-import-title",
            "account",
            account_label,
        ),
        width: 1320.0,
        height: 900.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

/// F18 — « Rapprocher une transaction ». La fiche d'une ligne du relevé, fille
/// de la fenêtre d'importation : elle est ouverte depuis elle et ne lui
/// survit pas.
pub fn statement_form_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "statement-form".to_string(),
        url: "ui/windows/statement-form.html".to_string(),
        title: i18n::text(language, "window-statement-form-title"),
        width: 1100.0,
        height: 720.0,
        closable: false,
        resizable_chrome: false,
        parent: Some("statement-import".to_string()),
    }
}

/// La fenêtre de découpage d'un relevé CSV.
///
/// Elle ne s'ouvre que si le fichier choisi n'est pas de l'OFX. Fille de la
/// fenêtre d'importation : elle en vient, et elle ne lui survit pas.
///
/// Haute et agrandissable : elle porte **deux** tableaux — le fichier tel qu'il
/// est, et ce que le découpage en tire — et c'est en les comparant qu'on règle.
pub fn csv_statement_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "csv-statement".to_string(),
        url: "ui/windows/csv-statement.html".to_string(),
        title: i18n::text(language, "window-csv-statement-title"),
        width: 1500.0,
        height: 960.0,
        closable: false,
        resizable_chrome: true,
        parent: Some("statement-import".to_string()),
    }
}

/// F38 — « Liste des operations periodiques ».
///
/// **Elle ne demande pas de compte** : chaque règle porte le sien, et une
/// liste par compte n'aurait pas de sens — le calendrier peut d'ailleurs mêler
/// les échéances de plusieurs comptes.
pub fn recurring_list_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "recurring".to_string(),
        url: "ui/windows/recurring-list.html".to_string(),
        title: i18n::text(language, "window-recurring-list-title"),
        width: 900.0,
        height: 700.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

/// F15 — « Fiche définissant la règle de génération d'opération periodique ».
///
/// **Redimensionnable, comme la fiche opération** (Fabrice, 04/08/2026), et
/// pour la même raison : elle doit tenir sur un MacBook Air 13 pouces, qui
/// n'offre que 903 points sous sa barre de menus et sa barre de titre — 833
/// seulement si le Dock est visible.
///
/// **En la mesurant, on a trouvé pire que prévu** : ses six sections font 1056
/// points, donc **1083 de fenêtre**. Elle était à 1000. Elle ne tenait donc
/// dans aucun écran, y compris le plus grand : elle montrait déjà un ascenseur
/// de 83 points, tous les jours, sans que le nombre 1000 signifie quoi que ce
/// soit. Une hauteur fixe qui ne suffit pas est le pire des deux mondes — elle
/// ne rend pas le service qu'elle promet et interdit qu'on la corrige.
///
/// **1085 demandés**, soit les 1083 mesurés et deux points d'air : pour la
/// première fois, le nombre écrit ici est celui dont la fenêtre a besoin. C'est
/// [`what_the_screen_allows`] qui le ramène à ce que l'écran peut montrer, et
/// non nous qui l'amputons d'avance pour un écran que l'utilisateur n'a
/// peut-être pas. Sur un grand écran, plus un seul ascenseur — il y en avait un
/// de 83 points tous les jours depuis que cette fenêtre existe.
///
/// Sur un Air, elle s'ouvre à la taille de l'écran et le contenu défile ; le
/// bouton vert de macOS l'ajuste d'un clic. Le geste ne se refait pas :
/// [`open`] ne repose pas la taille d'une fenêtre en la remontrant.
pub fn recurring_form_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "recurring-form".to_string(),
        url: "ui/windows/recurring-form.html".to_string(),
        title: i18n::text(language, "window-recurring-form-title"),
        width: 1000.0,
        height: 1085.0,
        closable: false,
        resizable_chrome: true,
        parent: Some("recurring".to_string()),
    }
}

/// F16 — « Proposition de calendrier des opérations à insérer dans vos comptes
/// bancaires ».
///
/// Haute et agrandissable : elle porte jusqu'à cent échéances par règle, et
/// c'est en les lisant qu'on décide lesquelles retirer.
pub fn recurring_calendar_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "recurring-calendar".to_string(),
        url: "ui/windows/recurring-calendar.html".to_string(),
        title: i18n::text(language, "window-recurring-calendar-title"),
        width: 1500.0,
        height: 900.0,
        closable: false,
        resizable_chrome: true,
        parent: Some("recurring".to_string()),
    }
}

/// F34 — « Importation de feuille excel [ Étape 1/3 ] : définition de la zone
/// de capture ».
///
/// Cinq groupes numérotés qu'on descend dans l'ordre — le cinquième, le rendu
/// test, est **obligatoire** avant de passer à l'étape 2 (décision de Fabrice,
/// 29/07/2026) : on ne quitte pas cette fenêtre sans avoir vu ce que la zone
/// attrape.
///
/// Haute et agrandissable : elle porte l'aperçu du tableau capturé, et c'est en
/// le regardant qu'on règle.
pub fn excel_import_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "excel-import".to_string(),
        url: "ui/windows/excel-import.html".to_string(),
        title: i18n::text(language, "window-excel-import-title"),
        width: 1500.0,
        height: 980.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

/// F35 — « Importation de feuille excel [ Étape 2/3 ] : association des
/// champs ». Deux onglets : les liens entre champs, et les politiques.
pub fn excel_fields_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "excel-fields".to_string(),
        url: "ui/windows/excel-fields.html".to_string(),
        title: i18n::text(language, "window-excel-fields-title"),
        width: 1300.0,
        height: 860.0,
        closable: false,
        resizable_chrome: true,
        parent: Some("excel-import".to_string()),
    }
}

/// « Importation de feuille excel : association des données » — la fenêtre du
/// bouton « Définir destination ».
///
/// **Une seule fenêtre pour les trois nomenclatures**, comme sa maquette
/// WinDev : elle porte trois colonnes de destination dont une seule est
/// montrée, selon le type demandé. Trois usages, un seul code.
pub fn excel_association_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "excel-association".to_string(),
        url: "ui/windows/excel-association.html".to_string(),
        title: i18n::text(language, "window-excel-association-title"),
        width: 1100.0,
        height: 800.0,
        closable: false,
        resizable_chrome: true,
        parent: Some("excel-fields".to_string()),
    }
}

/// F13 — « Liste des chequiers ».
///
/// **Tous les carnets, sans choisir de compte** (arbitrage de Fabrice,
/// 28/07/2026) : ses deux colonnes NomCompte et Num Compte ne serviraient à
/// rien si la fenêtre n'en montrait qu'un. Elle s'ouvre donc directement depuis
/// le menu Comptes (⌘F7), sans la question que posent F02, F05 et F17.
pub fn chequebooks_window(language: Language) -> WindowSpec {
    chequebooks_list(language, false)
}

/// La même page, dans son mode « choisir » — le `ModeListe = "SEL"` de son
/// `Code Liste Chequier.txt`. C'est par là que la fiche opération vient
/// chercher un chèque : on choisit d'abord un carnet, puis un chèque dedans.
/// **Son étiquette est distincte**, comme les trois usages de la liste des
/// comptes : parcourir ses carnets pendant qu'une fiche demande lequel est
/// parfaitement raisonnable, et une seule étiquette les ferait se réutiliser
/// l'une l'autre.
pub fn chequebooks_selection_window(language: Language) -> WindowSpec {
    chequebooks_list(language, true)
}

fn chequebooks_list(language: Language, selecting: bool) -> WindowSpec {
    WindowSpec {
        label: if selecting { "chequebooks-select" } else { "chequebooks" }.to_string(),
        url: if selecting {
            "ui/windows/chequebooks-list.html?mode=SEL"
        } else {
            "ui/windows/chequebooks-list.html"
        }
        .to_string(),
        title: i18n::text(language, "window-chequebooks-title"),
        width: 1100.0,
        height: 720.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

/// F31 — « Parametres chequier ». La fiche du carnet, fille de sa liste.
pub fn chequebook_form_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "chequebook-form".to_string(),
        url: "ui/windows/chequebook-form.html".to_string(),
        title: i18n::text(language, "window-chequebook-title"),
        width: 1000.0,
        height: 500.0,
        closable: false,
        resizable_chrome: false,
        parent: Some("chequebooks".to_string()),
    }
}

/// F14 — « Composition du chéquier : liste des chèques. » Quarante lignes, et
/// le statut se change dans la case : c'est un tableau qu'on agrandit.
pub fn cheques_window(language: Language) -> WindowSpec {
    cheques_list(language, false)
}

/// La composition, dans son mode « choisir » — le second temps de la pêche au
/// chèque depuis la fiche opération.
pub fn cheques_selection_window(language: Language) -> WindowSpec {
    cheques_list(language, true)
}

fn cheques_list(language: Language, selecting: bool) -> WindowSpec {
    WindowSpec {
        label: if selecting { "cheques-select" } else { "cheques" }.to_string(),
        url: if selecting {
            "ui/windows/cheques-list.html?mode=SEL"
        } else {
            "ui/windows/cheques-list.html"
        }
        .to_string(),
        title: i18n::text(language, "window-cheques-title"),
        width: 1400.0,
        height: 860.0,
        closable: false,
        resizable_chrome: true,
        parent: Some(if selecting { "chequebooks-select" } else { "chequebooks" }.to_string()),
    }
}

/// F12 — « Fiche chèques ». Fille de la composition, d'où elle est ouverte.
pub fn cheque_form_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "cheque-form".to_string(),
        url: "ui/windows/cheque-form.html".to_string(),
        title: i18n::text(language, "window-cheque-title"),
        width: 1060.0,
        height: 460.0,
        closable: false,
        resizable_chrome: false,
        parent: Some("cheques".to_string()),
    }
}

/// « Liste des opérations. » — **une page, deux visages**, comme la liste des
/// comptes en a trois. Le `gChequeAsso` de son original décide : à zéro on
/// choisit une opération à associer, non nul on regarde celles qui le sont
/// déjà. Une seule étiquette, parce qu'on ne fait jamais les deux à la fois sur
/// le même chèque, et que la seconde question chasse la première.
pub fn cheque_operations_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "cheque-operations".to_string(),
        url: "ui/windows/cheque-operations.html".to_string(),
        title: i18n::text(language, "window-cheque-operations-title"),
        width: 1400.0,
        height: 800.0,
        closable: false,
        resizable_chrome: true,
        parent: Some("cheques".to_string()),
    }
}

/// F09 — « Transférer un montant entre deux comptes ».
///
/// **Elle ne demande aucun compte d'avance** : les deux se choisissent dedans,
/// et c'est justement le geste de la fenêtre. Elle reste ouverte après un
/// virement, vidée pour le suivant (règle de Fabrice, 29/07/2026) — on n'en
/// fait presque jamais un seul.
/// F32 — « Impression de RIB ( Relevé d'Identité Bancaire ) ».
///
/// Elle s'ouvre depuis le menu général, Comptes › Editer un Relevé d'Identité
/// Bancaire, après le choix du compte (Fabrice, 01/08/2026). Fenêtre unique et
/// jamais détruite comme les autres : le compte suivant arrive par
/// `window-parameters:rib`.
/// F28 — les pièces jointes d'une opération (phase 17).
///
/// Ouverte par le trombone de la fiche opération, sur l'opération ouverte.
pub fn attachments_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "attachments".to_string(),
        url: "ui/windows/attachments.html".to_string(),
        title: i18n::text(language, "window-attachments-title"),
        width: 1100.0,
        height: 620.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

/// La fenêtre du journal (⌘H) — phase 17.
///
/// Elle ne montre que la dernière opération technique, et ne sert qu'à lire :
/// pas de panneau d'actions, seulement la porte.
pub fn journal_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "journal".to_string(),
        url: "ui/windows/journal.html".to_string(),
        title: i18n::text(language, "window-journal-title"),
        width: 1400.0,
        height: 760.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

pub fn rib_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "rib".to_string(),
        url: "ui/windows/rib.html".to_string(),
        title: i18n::text(language, "window-rib-title"),
        width: 1360.0,
        height: 840.0,
        closable: false,
        resizable_chrome: false,
        parent: None,
    }
}

pub fn transfer_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "transfer".to_string(),
        url: "ui/windows/transfer.html".to_string(),
        title: i18n::text(language, "window-transfer-title"),
        width: 980.0,
        height: 880.0,
        closable: false,
        resizable_chrome: false,
        parent: None,
    }
}

/// F26 — « Saisie du budget » et F39 — « Contrôle du budget ».
///
/// **Deux portes, deux fenêtres** (règle de Fabrice, 29/07/2026) : on saisit
/// son budget, ou on contrôle s'il a été tenu. Une page pour les deux, parce
/// que c'est le même tableau — postes budgétaires en lignes, douze mois en
/// colonnes, et la même navigation par année que les statistiques — mais deux
/// étiquettes, parce qu'on veut pouvoir corriger sa saisie en regardant son
/// contrôle.
pub fn budget_window(language: Language, control: bool) -> WindowSpec {
    WindowSpec {
        label: if control { "budget-control" } else { "budget-entry" }.to_string(),
        url: if control {
            "ui/windows/budget.html?mode=control"
        } else {
            "ui/windows/budget.html?mode=entry"
        }
        .to_string(),
        title: i18n::text(
            language,
            if control {
                "window-budget-control-title"
            } else {
                "window-budget-entry-title"
            },
        ),
        width: 1600.0,
        height: 860.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

/// F37 — « Liste des modeles d'operations ».
///
/// Strictement sur le gabarit des listes de nomenclature, et **deux usages**
/// comme les listes de chéquiers : la gestion par le menu Nomenclatures, et le
/// mode « choisir » d'où la fiche opération vient prendre un modèle à
/// appliquer. Deux étiquettes distinctes, pour que gérer ses modèles pendant
/// qu'une fiche en demande un ne soit pas un problème.
pub fn operation_templates_window(language: Language, selecting: bool) -> WindowSpec {
    WindowSpec {
        label: if selecting {
            "operation-templates-select"
        } else {
            "operation-templates"
        }
        .to_string(),
        url: if selecting {
            "ui/windows/operation-templates-list.html?mode=SEL"
        } else {
            "ui/windows/operation-templates-list.html"
        }
        .to_string(),
        title: i18n::text(language, "window-operation-templates-title"),
        width: 900.0,
        height: 700.0,
        closable: false,
        resizable_chrome: true,
        parent: None,
    }
}

/// F36 — « Fiche Modele Operation ». Ni compte ni date : les deux ne prennent
/// leur sens qu'au moment de la saisie, et un modèle sert justement à traverser
/// plusieurs saisies.
pub fn operation_template_form_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "operation-template-form".to_string(),
        url: "ui/windows/operation-template-form.html".to_string(),
        title: i18n::text(language, "window-operation-template-title"),
        width: 1020.0,
        height: 720.0,
        closable: false,
        resizable_chrome: false,
        parent: Some("operation-templates".to_string()),
    }
}

/// La fiche d'une base neuve (Fabrice, 04/08/2026).
///
/// Fille du sélecteur : elle se tient au-dessus de lui et s'en va avec lui.
/// Petite, parce qu'elle ne pose que trois questions — le nom, le commentaire,
/// la devise — et qu'une fiche qui laisse du vide donne à croire qu'elle en
/// attend davantage.
pub fn database_form_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "database-form".to_string(),
        url: "ui/windows/database-form.html".to_string(),
        title: i18n::text(language, "window-database-form-title"),
        width: 980.0,
        height: 540.0,
        closable: false,
        resizable_chrome: false,
        parent: Some("database-selector".to_string()),
    }
}

/// **La fiche du mot de passe d'une base** (décision de Fabrice, 05/08/2026).
///
/// Fille du sélecteur comme la fiche de création : elle porte sur une ligne de
/// son tableau, et n'a aucun sens sans lui. Trois champs et deux bandeaux
/// d'explication tiennent dans moins de place qu'une base neuve, d'où la
/// hauteur plus courte.
pub fn password_form_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "password-form".to_string(),
        url: "ui/windows/password-form.html".to_string(),
        title: i18n::text(language, "window-password-form-title"),
        width: 820.0,
        height: 560.0,
        closable: false,
        resizable_chrome: false,
        parent: Some("database-selector".to_string()),
    }
}

/// F03 — « Opération Compte : `<compte>` ». The fiche of one operation, child
/// of the list it was opened from, and titled with the account like the list
/// itself: a fiche belongs to one account and there is no doubt about which.
///
/// **Elle se redimensionne, et c'est la seule fiche de Radinus qui le fasse**
/// (décision de Fabrice, 04/08/2026). L'exception a une raison : c'est la
/// fenêtre la plus haute qu'on ouvre tous les jours, et il la veut utilisable
/// sur un MacBook Air 13 pouces.
///
/// Les mesures, prises au navigateur sur la page réelle, disent pourquoi le
/// choix était forcé. La fiche réclame **880 points** quand l'opération n'a
/// pas de commentaire — sa section est alors cachée — et **978** quand elle en
/// a un, la zone de quatre lignes ajoutant 98 d'un coup. Un Air 13 offre 903
/// points sous sa barre de menus et sa barre de titre, et **833 seulement si
/// le Dock est visible**, ce qui est le cas par défaut. Aucune hauteur fixe ne
/// pouvait donc convenir aux deux écrans à la fois.
///
/// **980 demandés, et c'est la hauteur qu'il lui faut** : 978 mesurés toutes
/// sections dépliées, plus deux points d'air. Elle avait été ramenée à 880 le
/// matin même pour tenir sur un Air ; ce n'est plus nécessaire depuis que
/// [`what_the_screen_allows`] ramène toute fenêtre à ce que l'écran peut
/// montrer. **Le nombre écrit ici redit donc ce dont la fiche a besoin, et non
/// ce que le plus petit écran supporte** — c'est l'écran qui rabote, pas nous.
///
/// Sur un grand écran : aucun ascenseur, jamais, commentaire compris. Sur un
/// Air : la fenêtre s'ouvre à la taille de l'écran et le contenu défile, ou
/// bien on l'agrandit — le bouton vert de macOS l'ajuste d'un clic, puisque
/// `resizable_chrome` allume aussi le zoom.
///
/// **Le geste ne se refait pas à chaque fois** : une fenêtre de Radinus est
/// bâtie une fois et jamais détruite, et [`open`] ne repose pas sa taille en la
/// remontrant. On l'agrandit une fois, elle le reste jusqu'à ce qu'on quitte.
pub fn operation_form_window(language: Language, account_label: &str) -> WindowSpec {
    WindowSpec {
        label: "operation-form".to_string(),
        url: "ui/windows/operation-form.html".to_string(),
        title: i18n::text_with(language, "window-operation-title", "account", account_label),
        width: 1020.0,
        height: 980.0,
        closable: false,
        resizable_chrome: true,
        parent: Some("operations".to_string()),
    }
}

/// F04 — « Fiche Sous-Operation ». A reduced F03: it has no Mode, no Statut
/// and no Date, because a sub-operation holds its mother's
/// (`sub_operations::sync_from_parent`). Child of the list, like the fiche
/// opération: both are opened from it and neither outlives it.
pub fn sub_operation_form_window(language: Language) -> WindowSpec {
    WindowSpec {
        label: "sub-operation-form".to_string(),
        url: "ui/windows/sub-operation-form.html".to_string(),
        title: i18n::text(language, "window-sub-operation-title"),
        width: 840.0,
        height: 560.0,
        closable: false,
        resizable_chrome: false,
        parent: Some("operations".to_string()),
    }
}

/// Event a window already on screen receives when it is asked for again with
/// different parameters. Its payload is the query string that would otherwise
/// have gone into the URL.
///
/// **The name carries the window's label**, because addressing alone is not
/// enough: a listener declared from JavaScript registers itself for *any*
/// target, and Tauri delivers an `emit_to` to it all the same
/// (`match_any_or_filter`). Windows listening to one name therefore all
/// received every message — the parameters meant for the list reached the
/// form, which read them as "add a new record" and blanked itself, reserve
/// included, behind the user's back (Fabrice, 25/07/2026). With seven
/// nomenclatures sharing one page, this matters seven times more.
pub fn reopen_event(spec: &WindowSpec) -> String {
    format!("window-parameters:{}", spec.label)
}

/// Event telling a window to empty itself: it is being left behind, and what
/// it holds has been abandoned.
///
/// Hiding a window keeps everything in it — the fields **and** the reserve
/// they are compared to. Without this, work abandoned when the list was
/// closed came back to life the next time the form was asked for, and asked
/// its question all over again about something the user had given up on
/// minutes earlier (Fabrice, 25/07/2026).
pub fn reset_event(spec: &WindowSpec) -> String {
    format!("window-reset:{}", spec.label)
}

/// Event telling a list that its data moved and it should reload.
pub fn changed_event(spec: &WindowSpec) -> String {
    format!("data-changed:{}", spec.label)
}

/// The address of a page, with the parameters a request carries added to it.
///
/// Some pages already have a question mark of their own — a nomenclature page
/// is told which nomenclature it works on — and some have none. Joining with
/// the wrong character makes an address that matches no file at all, and the
/// development server then answers with the application's own start page: the
/// fiche compte opened showing the welcome window, titled "Fiche compte"
/// (reported by Fabrice, 25/07/2026). Nothing crashed, nothing was logged; it
/// just quietly served something else.
fn address(url: &str, query: Option<&str>) -> String {
    match query {
        None => url.to_string(),
        Some("") => url.to_string(),
        Some(query) if url.contains('?') => format!("{url}&{query}"),
        Some(query) => format!("{url}?{query}"),
    }
}

/// Opens `spec`, or **reuses** it when it already exists: the new parameters
/// are handed to it as [`reopen_event`], and it is shown and brought to the
/// front.
///
/// **A window is built once and never destroyed** — leaving it hides it, and
/// coming back shows it again. Destroying windows was the source of two
/// separate faults reported by Fabrice on 25/07/2026: rebuilding one under a
/// label that was still being torn down crashed the application outright, and
/// even after that was slowed down, a list asked for again a moment after
/// being closed came back as an empty grey panel — a window already dead but
/// not yet forgotten, faithfully "reused". Hiding removes the race instead of
/// racing better: there is no such thing as a half-destroyed window any more.
/// **Le zoom d'affichage, propriété unique du logiciel qui tourne.**
///
/// Il vit ici et non dans la base pour la raison qui a fait vivre le signe
/// monétaire dans `money` : `open` est appelée de partout, y compris depuis
/// des commandes qui tiennent déjà la connexion. Aller lire la base ici
/// verrouillerait deux fois le même mutex — l'interblocage exact du
/// 30/07/2026, celui qui fige le logiciel sans une erreur.
///
/// **Deux écrivains, les mêmes que pour le signe** : l'ouverture d'une base,
/// et l'enregistrement des préférences.
static ZOOM: std::sync::RwLock<f64> = std::sync::RwLock::new(1.0);

pub fn set_zoom_factor(factor: f64) {
    if let Ok(mut held) = ZOOM.write() {
        *held = factor;
    }
}

pub fn zoom_factor() -> f64 {
    ZOOM.read().map(|held| *held).unwrap_or(1.0)
}

/// Applique le zoom courant à toutes les fenêtres ouvertes.
///
/// Une fenêtre qui refuse le zoom n'est pas une raison d'arrêter les autres :
/// on passe à la suivante. Le pire cas est une fenêtre à sa taille d'origine,
/// pas un logiciel qui s'interrompt.
pub fn apply_zoom_everywhere<R: Runtime>(app: &AppHandle<R>) {
    let factor = zoom_factor();
    for (_, window) in app.webview_windows() {
        let _ = window.set_zoom(factor);
    }
}

/// La hauteur qu'une barre de titre prend sur macOS, en points.
///
/// La zone utile d'un écran, telle que le système la rend, retire déjà la barre
/// de menus et le Dock — mais pas ce que la fenêtre ajoute au-dessus de sa
/// page. C'est la seule des trois mesures qui doive être écrite à la main :
/// une fenêtre ne peut pas se mesurer avant d'exister, et c'est justement
/// avant qu'on a besoin du nombre.
const TITLE_BAR: f64 = 28.0;

/// Un plancher, pour qu'un écran qui répondrait n'importe quoi ne rende pas une
/// fenêtre minuscule. La plus petite du logiciel fait 420 × 380.
const SMALLEST: (f64, f64) = (420.0, 380.0);

/// La taille écrite dans le `WindowSpec`, ramenée à ce que l'écran peut montrer.
///
/// **Aucune fenêtre ne s'ouvre plus grande que l'écran** (décision de Fabrice,
/// 04/08/2026). Chaque fenêtre porte une taille écrite en dur, et Radinus
/// l'appliquait jusqu'ici **sans jamais regarder l'écran qu'il avait devant
/// lui**. Sur un MacBook Air 13 pouces, douze fenêtres sortaient du cadre —
/// dont deux qui ne se redimensionnaient pas, donc irrattrapables : elles
/// débordaient par le bas et rien ne permettait de les ramener.
///
/// **La règle est posée ici, et une seule fois**, au seul endroit par lequel
/// toutes les fenêtres passent pour s'ouvrir. Rapetisser les douze à la main
/// les aurait rapetissées **aussi sur les grands écrans**, pour rien, et aurait
/// laissé la treizième à écrire le jour où on l'ajouterait.
///
/// **Elle ne fait que réduire.** Sur un écran assez grand, chaque fenêtre garde
/// exactement la taille de son `WindowSpec`, au point près : rien ne change
/// pour qui a la place.
///
/// **Et elle ne bloque jamais rien.** Si le système ne rend pas d'écran — il en
/// a le droit, et il le fait pendant les tests —, ou s'il rend un facteur
/// d'échelle absurde, on ouvre comme avant. Une fenêtre trop grande se
/// rattrape ; une fenêtre qui ne s'ouvre pas, non.
fn what_the_screen_allows<R: Runtime>(app: &AppHandle<R>, spec: &WindowSpec) -> (f64, f64) {
    let Ok(Some(screen)) = app.primary_monitor() else {
        return (spec.width, spec.height);
    };
    let scale = screen.scale_factor();
    // `to_logical` **panique** sur un facteur nul, négatif ou dénormalisé. On ne
    // lui donne donc que ce qu'il accepte : le seul chemin qui pouvait arrêter
    // le logiciel dans cette fonction est fermé avant d'y entrer.
    if !scale.is_normal() || !scale.is_sign_positive() {
        return (spec.width, spec.height);
    }
    let usable = screen.work_area().size.to_logical::<f64>(scale);
    (
        spec.width.min(usable.width).max(SMALLEST.0),
        spec.height.min(usable.height - TITLE_BAR).max(SMALLEST.1),
    )
}

pub fn open<R: Runtime>(
    app: &AppHandle<R>,
    spec: &WindowSpec,
    query: Option<&str>,
) -> tauri::Result<()> {
    if let Some(existing) = app.get_webview_window(&spec.label) {
        // Addressed to that one window *and* named after it — see
        // [`reopen_event`]: addressing alone does not keep the other windows
        // from hearing it.
        // **Le titre se repose, et c'est le bug du 03/08/2026.**
        //
        // Fabrice : « lorsque je clique sur un compte bancaire, il ouvre
        // toujours la liste du premier compte ». Les lignes étaient pourtant
        // les bonnes — la fenêtre recevait ses paramètres et se relisait. Seul
        // le titre restait celui du premier compte pour lequel elle avait
        // jamais été ouverte, puisqu'une fenêtre de Radinus est bâtie une fois
        // et jamais détruite, et que cette branche-ci la montrait sans jamais
        // la renommer.
        //
        // **Les bonnes opérations sous le mauvais nom** : c'est la même famille
        // de faute que celle du 26/07 sur les statistiques, où les chiffres
        // étaient justes sur le mauvais compte. Dans les deux cas rien ne se
        // voit, sinon l'étiquette.
        //
        // Le remède est ici et non dans chaque fenêtre : l'appelant vient de
        // calculer `spec.title` avec le bon nom, il suffit de l'appliquer. F02,
        // F05 et F17 portent toutes un nom de compte dans leur titre, et sont
        // toutes réparées d'un coup.
        let reused = existing.set_title(&spec.title).is_ok()
            && existing
                .emit_to(
                    EventTarget::webview_window(&spec.label),
                    &reopen_event(spec),
                    query.unwrap_or_default(),
                )
                .is_ok()
            && existing.show().is_ok()
            && existing.set_focus().is_ok();
        if reused {
            // Elle a pu être cachée avant un changement de zoom : on le repose.
            let _ = existing.set_zoom(zoom_factor());
            return Ok(());
        }
    }

    // **Sous Windows, bâtir une fenêtre ici figerait le logiciel** (dossier de
    // portage du 05/08/2026, §1).
    //
    // La documentation de Tauri est explicite : *« On Windows, this function
    // deadlocks when used in a synchronous command and event handlers. »* C'est
    // une contrainte de WebView2 — créer un webview réclame que la boucle de
    // messages tourne, et c'est précisément celle qu'occupe le gestionnaire en
    // cours. macOS n'a pas cette contrainte, d'où un code identique qui n'a
    // jamais bronché sur le Mac.
    //
    // Or `open` est appelée depuis les deux endroits interdits : les commandes,
    // dont la quasi-totalité sont synchrones, et `menu::on_event`, qui est un
    // gestionnaire d'événement. Le symptôme était net : Radinus démarrait, puis
    // **le premier clic demandant une fenêtre figeait tout**, sans un mot.
    //
    // Corriger ici plutôt que chez les quarante appelants répare tout d'un
    // coup, et laisse macOS exactement comme il était.
    //
    // **Le garde `BUILDING`** empêche qu'un double clic lance deux
    // constructions pour la même étiquette : la seconde arriverait avant que la
    // première n'ait posé sa fenêtre, et `get_webview_window` ci-dessus ne
    // l'aurait pas encore vue.
    //
    // *Ce que ça coûte* : `open` rend `Ok(())` avant que la fenêtre existe, et
    // une construction ratée se dit dans la console au lieu de remonter à
    // l'appelant. C'est le prix d'une fenêtre qui s'ouvre.
    #[cfg(target_os = "windows")]
    {
        use std::collections::HashSet;
        use std::sync::{Mutex, OnceLock};

        static BUILDING: OnceLock<Mutex<HashSet<String>>> = OnceLock::new();
        let building = BUILDING.get_or_init(|| Mutex::new(HashSet::new()));
        {
            let mut held = match building.lock() {
                Ok(held) => held,
                Err(poisoned) => poisoned.into_inner(),
            };
            if !held.insert(spec.label.clone()) {
                // Déjà en cours de construction : le second clic ne fait rien.
                return Ok(());
            }
        }

        let app = app.clone();
        let spec = spec.clone();
        let query = query.map(str::to_owned);
        std::thread::spawn(move || {
            if let Err(error) = build_the_window(&app, &spec, query.as_deref()) {
                eprintln!(
                    "[radinus] Could not build the {} window: {error}",
                    spec.label
                );
            }
            // **Retiré quoi qu'il arrive**, réussite comme échec : une
            // étiquette laissée dans le garde interdirait cette fenêtre pour le
            // reste de la session.
            if let Ok(mut held) = building.lock() {
                held.remove(&spec.label);
            }
        });
        return Ok(());
    }

    #[cfg(not(target_os = "windows"))]
    build_the_window(app, spec, query)
}

/// La construction proprement dite : tout ce que `open` faisait avant que
/// Windows n'oblige à la déporter sur un fil.
fn build_the_window<R: Runtime>(
    app: &AppHandle<R>,
    spec: &WindowSpec,
    query: Option<&str>,
) -> tauri::Result<()> {
    let url = address(&spec.url, query);

    let (width, height) = what_the_screen_allows(app, spec);

    let mut builder = WebviewWindowBuilder::new(app, &spec.label, WebviewUrl::App(url.into()))
        .title(&spec.title)
        .inner_size(width, height)
        .resizable(spec.resizable_chrome)
        .maximizable(spec.resizable_chrome)
        .minimizable(spec.resizable_chrome)
        .closable(spec.closable);

    if let Some(parent) = spec
        .parent
        .as_ref()
        .and_then(|label| app.get_webview_window(label))
    {
        builder = builder.parent(&parent)?;
    }

    let window = builder.build()?;
    // **Chaque fenêtre naît à 100 %.** Le zoom n'est pas une propriété de
    // l'application mais de chaque webview, donc une fenêtre ouverte après le
    // réglage l'ignorerait — c'est le point que j'avais annoncé à Fabrice comme
    // étant à vérifier, et c'est ici qu'il se règle.
    let _ = window.set_zoom(zoom_factor());
    Ok(())
}

#[cfg(test)]
pub mod tests {
    use super::*;
    use radinus_core::nomenclatures::ALL;

    /// Seven nomenclatures, fourteen windows, and never the same label twice
    /// — two windows sharing a label would be reused for one another.
    #[test]
    fn every_window_has_a_label_of_its_own() {
        let mut labels: Vec<String> = Vec::new();
        for kind in ALL {
            labels.push(list_window(kind, Language::French).label);
            labels.push(form_window(kind, Language::French).label);
        }
        let unique: std::collections::HashSet<&String> = labels.iter().collect();
        assert_eq!(unique.len(), labels.len(), "labels en double : {labels:?}");
    }

    /// The join that broke the fiche compte: a page with no question mark of
    /// its own gets one, a page that already has one gets an ampersand.
    #[test]
    fn parameters_are_joined_to_an_address_the_way_that_address_needs() {
        assert_eq!(
            address("ui/windows/account-form.html", Some("mode=M&id=1")),
            "ui/windows/account-form.html?mode=M&id=1"
        );
        assert_eq!(
            address("ui/windows/nomenclature-form.html?kind=category", Some("mode=M&id=1")),
            "ui/windows/nomenclature-form.html?kind=category&mode=M&id=1"
        );
        assert_eq!(
            address("ui/windows/balances.html", None),
            "ui/windows/balances.html"
        );
        assert_eq!(
            address("ui/windows/accounts-list.html?mode=CRUD", Some("")),
            "ui/windows/accounts-list.html?mode=CRUD"
        );
    }

    /// **Toutes les fenêtres que cette version sait ouvrir.** Une seule liste,
    /// pour que les vérifications ci-dessous ne puissent pas en oublier une —
    /// c'est ainsi que les cinq nouvelles statistiques sont passées entre les
    /// mailles le 26/07/2026.
    pub fn every_spec() -> Vec<WindowSpec> {
        let mut specs = vec![
            language_choice_window(),
            database_selector_window(Language::French),
            database_form_window(Language::French),
            accounts_list_window(Language::French, AccountsPurpose::Manage),
            accounts_list_window(Language::French, AccountsPurpose::OneAccount),
            accounts_list_window(Language::French, AccountsPurpose::ManyAccounts),
            account_form_window(Language::French),
            dashboard_window(Language::French),
            crossed_balance_window(Language::French),
            balance_curves_window(Language::French),
            balance_analysis_window(Language::French),
            loan_simulation_window(Language::French),
            appliance_cost_window(Language::French),
            safety_cushion_window(Language::French),
            savings_goal_window(Language::French),
            spending_cut_window(Language::French),
            holiday_window(Language::French),
            car_logbook_window(Language::French),
            sharing_window(Language::French),
            balances_window(Language::French),
            operations_window(Language::French, "CCP"),
            operation_form_window(Language::French, "CCP"),
            quick_classification_window(Language::French, "CCP"),
            statement_import_window(Language::French, "CCP"),
            statement_form_window(Language::French),
            csv_statement_window(Language::French),
            recurring_list_window(Language::French),
            recurring_form_window(Language::French),
            recurring_calendar_window(Language::French),
            excel_import_window(Language::French),
            excel_fields_window(Language::French),
            excel_association_window(Language::French),
            chequebooks_window(Language::French),
            budget_window(Language::French, false),
            transfer_window(Language::French),
            rib_window(Language::French),
            journal_window(Language::French),
            attachments_window(Language::French),
            budget_window(Language::French, true),
            operation_templates_window(Language::French, false),
            operation_templates_window(Language::French, true),
            operation_template_form_window(Language::French),
            chequebooks_selection_window(Language::French),
            cheques_selection_window(Language::French),
            chequebook_form_window(Language::French),
            cheques_window(Language::French),
            cheque_form_window(Language::French),
            cheque_operations_window(Language::French),
            sub_operation_form_window(Language::French),
        ];
        for axis in radinus_core::statistics::AXES {
            specs.push(statistics_window(Language::French, axis));
        }
        for kind in ALL {
            specs.push(list_window(kind, Language::French));
            specs.push(form_window(kind, Language::French));
        }
        specs
    }

    /// **Une fenêtre absente du fichier de permissions ne peut pas parler à
    /// Rust du tout** — pas même pour se fermer.
    ///
    /// Faute du 26/07/2026 : les six statistiques ont pris chacune leur
    /// étiquette, mais `capabilities/default.json` ne nommait que
    /// `statistics-category`. Les cinq autres s'ouvraient, s'affichaient, et
    /// rien n'y répondait — Fabrice l'a vu au bouton de sortie qui ne sortait
    /// pas. Rien dans le code ne pouvait le signaler : les permissions vivent
    /// dans un fichier que le compilateur ne lit pas. Ce test le lit.
    #[test]
    fn every_window_is_granted_its_permissions() {
        let file = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("capabilities/default.json");
        let text = std::fs::read_to_string(&file).expect("le fichier de permissions");
        let granted: Vec<String> = text
            .split("\"windows\"")
            .nth(1)
            .and_then(|rest| rest.split('[').nth(1))
            .and_then(|rest| rest.split(']').next())
            .expect("la liste des fenêtres")
            .split(',')
            .map(|entry| entry.trim().trim_matches('"').to_string())
            .filter(|entry| !entry.is_empty())
            .collect();
        assert!(!granted.is_empty(), "aucune fenêtre n'est autorisée");

        // Le motif de Tauri : une étoile, où qu'elle soit.
        let matches = |pattern: &str, label: &str| match pattern.split_once('*') {
            None => pattern == label,
            Some((before, after)) => {
                label.len() >= before.len() + after.len()
                    && label.starts_with(before)
                    && label.ends_with(after)
            }
        };

        for spec in every_spec() {
            assert!(
                granted.iter().any(|pattern| matches(pattern, &spec.label)),
                "la fenêtre « {} » n'est autorisée par aucun motif de \
                 capabilities/default.json : elle s'ouvrira muette",
                spec.label
            );
        }
    }

    /// **L'axe voyage dans l'adresse autant que dans l'étiquette.**
    ///
    /// Faute du 26/07/2026 : l'étiquette portait l'axe, la page non. Les six
    /// fenêtres s'ouvraient bien distinctes, et montraient toutes les
    /// catégories — la page, ne trouvant pas d'axe dans son adresse, retombait
    /// sur celui par défaut. Des chiffres justes sous un titre faux.
    #[test]
    fn a_statistics_window_carries_its_axis_in_its_address() {
        for axis in radinus_core::statistics::AXES {
            let spec = statistics_window(Language::French, axis);
            assert_eq!(spec.label, format!("statistics-{}", axis.key()));
            assert!(
                spec.url.contains(&format!("axis={}", axis.key())),
                "l'adresse de « {} » ne dit pas sur quel axe elle porte : {}",
                spec.label,
                spec.url
            );
            // Et les comptes viennent s'y ajouter sans écraser l'axe.
            assert_eq!(
                address(&spec.url, Some("accounts=1,2")),
                format!(
                    "ui/windows/statistics.html?axis={}&accounts=1,2",
                    axis.key()
                )
            );
        }
    }

    /// Every window this build can open must be reachable: an address that
    /// matches no page silently serves the start page instead.
    #[test]
    fn every_window_asks_for_a_page_that_exists() {
        let root = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
            .parent()
            .expect("racine du projet");
        for spec in every_spec() {
            let page = spec.url.split('?').next().expect("une adresse");
            assert!(
                root.join(page).exists(),
                "{} demande {page}, qui n'existe pas",
                spec.label
            );
        }
    }

    /// A window's title is translated; its label never is — the label is how
    /// Rust and the window find each other.
    #[test]
    fn a_window_is_titled_in_the_language_of_the_database_and_labelled_in_neither() {
        let french = list_window(Nomenclature::Payee, Language::French);
        let english = list_window(Nomenclature::Payee, Language::English);
        assert_eq!(french.label, english.label);
        assert_ne!(french.title, english.title);
        assert_eq!(french.title, "Liste des tiers et marchands");
        assert_eq!(english.title, "Payees and merchants");
    }

    /// A fiche belongs to its own list, never to another's.
    #[test]
    fn every_fiche_is_the_child_of_its_own_list() {
        for kind in ALL {
            assert_eq!(
                form_window(kind, Language::French).parent.as_deref(),
                Some(list_window(kind, Language::French).label.as_str())
            );
        }
    }
}
