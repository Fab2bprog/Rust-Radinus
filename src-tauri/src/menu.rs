//! Native macOS menu bar for Radinus.
//!
//! Phase 0 only needs the seven menus and their entries to *exist*, in the
//! right structure and order — see 01_CAHIER_DES_CHARGES.md §6 for the exact
//! entry list and its accelerators (Ctrl -> Cmd on macOS). Les entrées sont
//! branchées une à une au fil des phases ; celles dont la fenêtre n'existe
//! pas encore restent grisées.
//!
//! **Toute étiquette vient de Fluent** (règle de l'auteur, 25/07/2026). La
//! barre est bâtie au démarrage dans la langue que déclare la base ouverte,
//! et **refaite entière** quand l'utilisateur change de langue : une entrée de
//! menu ne se renomme pas, elle se refait.
//!
//! **La langue ne se choisit plus ici** (Fabrice, 03/08/2026 : « elle fait
//! doublon avec les préférences ») : elle se règle en F39, feuille « Langue »,
//! qui appelle `switch_language` ci-dessous. Un seul chemin.
//!
//! **The Nomenclatures menu is live**: its seven first entries each open
//! their own list (F11). They share one page, told which nomenclature it is
//! working on — see `windows.rs`. The eighth, "Modèles d'opérations", stays
//! inert: its window belongs to phase 10.

use radinus_core::i18n::{self, Language};
use radinus_core::nomenclatures::{Nomenclature, ALL};
use radinus_core::statistics::{Axis, AXES};
use tauri::menu::{Menu, MenuItem, PredefinedMenuItem, Submenu};
use tauri::{AppHandle, Emitter, Manager, Runtime};

/// Menu id of a nomenclature entry: its key, prefixed so nothing else can
/// collide with it.
fn item_id(kind: Nomenclature) -> String {
    format!("nomenclature:{}", kind.key())
}

/// The two entries of the Comptes menu whose window exists (phase 4).
pub const ACCOUNTS_ITEM_ID: &str = "accounts-manage";
pub const BALANCES_ITEM_ID: &str = "accounts-balances";
/// « Préférences… » (F39, phase 17 ter) — **la seule entrée de ce menu qui
/// règle quelque chose**.
///
/// « Choix de la langue » y était encore le matin même ; Fabrice l'a retirée
/// le 03/08/2026, « elle fait doublon avec les préférences ». Son sous-menu à
/// cases, son préfixe d'identifiant et la branche d'écoute qui le décodait
/// sont partis avec elle : ils n'existaient que pour lui.
pub const PREFERENCES_ITEM_ID: &str = "settings-preferences";

/// Les quatre entrées du menu Divers (03/08/2026). Elles annonçaient toutes
/// quelque chose et ne faisaient rien ; elles font désormais ce qu'elles
/// disent. **La calculatrice n'existe pas sous Linux** — voir
/// `system::open_calculator`, elle y est masquée et non grisée.
#[cfg(any(target_os = "macos", target_os = "windows"))]
pub const CALCULATOR_ITEM_ID: &str = "misc-calculator";
pub const WEBSITE_ITEM_ID: &str = "misc-website";

/// « À propos de l'auteur » (menu Paramètres, 03/08/2026). Les deux autres
/// entrées de ce menu — l'historique et « À propos de Radinus » — restent
/// inertes : Fabrice a demandé qu'on s'en tienne là pour l'instant.
/// « Afficher la fenêtre principale » (menu Paramètres, 03/08/2026).
///
/// La fenêtre d'accueil n'est jamais détruite ni cachée par Radinus — mais
/// elle se réduit, et elle s'enterre sous les autres. Cette entrée la ramène
/// devant : montrée, désréduite, au premier plan. Les trois gestes, parce que
/// deux ne suffisent pas — une fenêtre réduite que l'on « montre » reste dans
/// le Dock.
/// « Se déconnecter de la base en cours » (Fabrice, 05/08/2026).
///
/// Elle referme la base et ramène le sélecteur, **sans quitter Radinus**. Elle
/// vit dans le menu Fichier, juste au-dessus de Quitter : ce sont deux gestes
/// de la même famille — on s'en va —, et celui-ci est le plus doux des deux.
///
/// Elle n'est vivante que si une base est ouverte, et elle ne demande **pas**
/// qu'il y ait un compte : une base vide dont on veut ressortir est exactement
/// le cas où l'on en a besoin.
pub const DISCONNECT_ITEM_ID: &str = "file-disconnect";

pub const SHOW_MAIN_ITEM_ID: &str = "settings-show-main";

pub const ABOUT_AUTHOR_ITEM_ID: &str = "settings-about-author";
/// « À propos de Radinus » (menu Paramètres, 03/08/2026). Seul l'historique
/// des versions reste inerte dans ce menu.
pub const ABOUT_RADINUS_ITEM_ID: &str = "settings-about-radinus";

/// « Licence d'utilisation » (menu Paramètres, 08/08/2026). It sits with the
/// two « À propos » entries because it answers the same kind of question —
/// what is this software — and not with the folders and the web site.
pub const LICENCE_ITEM_ID: &str = "settings-licence";
pub const DATABASE_FOLDER_ITEM_ID: &str = "misc-database-folder";
pub const APPLICATION_FOLDER_ITEM_ID: &str = "misc-application-folder";

/// Le site de Radinus, celui du document 01 §6.
const WEBSITE: &str = "https://www.radinus.fr";
/// « Gérer les opérations d'un compte » — it asks which account first, through
/// the accounts list in its choosing mode (F06).
pub const OPERATIONS_ITEM_ID: &str = "accounts-operations";
/// « Classification rapide des opérations » (F05) — elle aussi demande
/// **un** compte d'abord, et un seul (règle de Fabrice, 27/07/2026). Elle
/// emprunte donc la même porte que la liste des opérations ; ce qui les
/// distingue voyage avec la question, sous le nom `target`.
pub const QUICK_CLASSIFY_ITEM_ID: &str = "accounts-quick-classify";
/// « Importation de relevés bancaires » (F17) — elle aussi demande **un**
/// compte d'abord : on importe toujours dans un compte, jamais « quelque part ».
pub const IMPORT_ITEM_ID: &str = "file-import-statements";
/// « Importation de fichier Excel » (F34/F35, phase 13) — elle aussi passe par
/// le choix d'**un** compte : on importe toujours dans un compte. C'est la
/// première étape de la marche à suivre que Fabrice a dictée le 29/07/2026.
pub const IMPORT_EXCEL_ITEM_ID: &str = "file-import-excel";
/// Les six statistiques. Chacune demande d'abord sur quels comptes la
/// calculer, par la liste des comptes dans son usage multi-comptes ; l'axe
/// voyage avec la question, et c'est le choix des comptes qui ouvrira la bonne.
///
/// L'identifiant de l'entrée porte la clef de l'axe, si bien qu'ajouter une
/// statistique un jour ne demandera pas d'ajouter une branche de plus ici.
/// « Gestion des chéquiers » (F13, ⌘F7) — **elle ne demande pas de compte**,
/// contrairement aux trois précédentes : ses colonnes NomCompte et Num Compte
/// ne serviraient à rien sur un seul compte (arbitrage de Fabrice, 28/07/2026).
pub const CHEQUEBOOKS_ITEM_ID: &str = "accounts-checkbooks";
/// « Gestion des opérations périodiques » (F38, ⌘F5) — **elle ne demande pas
/// de compte** : chaque règle porte le sien.
pub const RECURRING_ITEM_ID: &str = "accounts-recurring";
/// « Modèles d'opérations » — la huitième entrée du menu Nomenclatures, vivante
/// depuis la phase 10.
pub const TEMPLATES_ITEM_ID: &str = "nomenclatures-templates";
/// Les deux portes du budget — **deux entrées distinctes**, et non deux onglets
/// d'une même fenêtre (règle de Fabrice, 29/07/2026).
/// « Transférer un montant entre deux comptes » (F09, ⌘F6).
pub const TRANSFER_ITEM_ID: &str = "accounts-transfer";

// **Ce qui documentait le sous-menu « Base de données » s'arrête ici**, et
// les constantes qui allaient avec ont disparu avec lui le 04/08/2026 :
// sauvegarder, restaurer, réparer et consulter le journal sont passés au menu
// « Outils » de la fenêtre de gestion des bases, où ils portent sur la base
// *sélectionnée* et non plus sur la base ouverte ; « Gestion de base de
// données… » était devenue un doublon de la procédure de démarrage ; et
// « Tout supprimer ! » avait été retirée la veille — le sélecteur sait
// supprimer une base en l'envoyant à la corbeille, avec ses pièces jointes.
// Le raisonnement complet est en P-30 de `docs/Decisions.md` ; ces deux
// paragraphes ne décrivaient plus rien.

/// F32 — l'édition et l'impression du relevé d'identité bancaire (phase 15).
/// Comme les autres fenêtres portant sur un compte unique, elle passe par la
/// liste des comptes en mode choix.
pub const BANK_DETAILS_ITEM_ID: &str = "accounts-bank-details";
pub const BUDGET_ENTRY_ITEM_ID: &str = "budget-entry";
pub const BUDGET_CONTROL_ITEM_ID: &str = "budget-control";
pub const DASHBOARD_ITEM_ID: &str = "statistics-dashboard";
pub const CURVES_ITEM_ID: &str = "statistics-curves";

fn statistics_item_id(axis: Axis) -> String {
    format!("statistics-by:{}", axis.key())
}

/// La clef Fluent de l'entrée de menu d'un axe.
fn statistics_menu_key(axis: Axis) -> &'static str {
    match axis {
        Axis::Category => "menu-statistics-by-category",
        Axis::Assignment => "menu-statistics-by-assignment",
        Axis::BudgetLine => "menu-statistics-by-budget-line",
        Axis::PaymentMode => "menu-statistics-by-payment-mode",
        Axis::Payee => "menu-statistics-by-payee",
        Axis::Project => "menu-statistics-by-project",
    }
}

/// La langue dans laquelle le menu se bâtit — la même que partout ailleurs.
///
/// Elle demandait à la base ouverte, et à la configuration seulement si aucune
/// base ne l'était. Il n'y a plus qu'une source depuis le 03/08/2026 : le menu
/// et les fenêtres ne peuvent donc plus se contredire, ce qu'ils faisaient à
/// chaque ouverture de base.
fn menu_language<R: Runtime>(_app: &AppHandle<R>) -> Language {
    i18n::in_use()
}

/// Change la langue du logiciel, **tout de suite** (décision de Fabrice,
/// 01/08/2026).
///
/// Trois choses bougent, et dans cet ordre, parce qu'il compte :
///
/// 1. **la base**, parce que la langue est une donnée d'elle et non un réglage
///    d'interface rangé à côté : elle voyage avec la base et avec sa
///    sauvegarde. Le verrou est rendu aussitôt — la reconstruction du menu le
///    reprendra, et un verrou tenu deux fois est le figeage du 30/07/2026 ;
/// 2. **le dictionnaire de la nouvelle langue**, préparé avant que quoi que
///    ce soit ne le demande, pour que la barre de menus ne se reconstruise pas
///    en attendant l'analyse d'un fichier de soixante-dix-huit mille
///    caractères ;
/// 3. **la barre de menus, puis les fenêtres ouvertes**. La barre est
///    reconstruite entière : une entrée de menu ne se renomme pas, elle se
///    refait. Les fenêtres, elles, sont bâties une fois et jamais détruites —
///    on ne peut donc pas les reconstruire, on leur dit de se rhabiller, et
///    chacune redemande son vocabulaire et le repose sur ses étiquettes.
pub fn switch_language<R: Runtime>(app: &AppHandle<R>, code: i64) -> Result<(), String> {
    let language = Language::from_id(code);

    {
        let state = app
            .try_state::<crate::state::AppState>()
            .ok_or_else(|| "état non disponible".to_string())?;

        // **La langue s'écrit dans `settings/radinus_config.json`, et là
        // seulement** (décision de Fabrice, 03/08/2026). Elle appartient au
        // logiciel et non aux données : changer de base ou remonter une
        // sauvegarde ne doit pas changer la langue de quelqu'un.
        //
        // Cette écriture ne demande **aucune base ouverte**, et c'est une
        // réparation au passage : jusqu'ici elle passait par la base, si bien
        // que changer la langue depuis les Préférences avant d'avoir ouvert
        // une base échouait.
        let root = state.data_root.clone();
        let mut config =
            radinus_core::location::read_config(&root).map_err(|error| error.to_string())?;
        config.language = Some(language.tag().to_string());
        radinus_core::location::write_config(&root, &config).map_err(|error| error.to_string())?;

        // Et si une base est ouverte, on lui recopie la nouvelle langue —
        // une copie pour Radinus 1.9.3, que rien ici ne relira. L'échec est
        // toléré : la langue de l'utilisateur est déjà écrite là où elle
        // compte, et une base en lecture seule ne doit pas l'en empêcher.
        //
        // **Le résultat est nommé avant d'être ouvert**, et ce n'est pas une
        // coquetterie : écrit `if let Ok(conn) = state.database()`, le Result
        // temporaire vit jusqu'à la fin du bloc, donc plus longtemps que
        // `state` dont il emprunte la connexion, et le compilateur refuse.
        // Nommé, il se range avec les autres variables et s'efface avant lui.
        let held = state.database();
        if let Ok(conn) = &held {
            let _ = i18n::store_language(conn, language);
        }
        drop(held);
    } // le verrou repart ici, avant tout le reste.

    i18n::prepare(language);

    let menu = build(app).map_err(|error| error.to_string())?;
    app.set_menu(menu).map_err(|error| error.to_string())?;

    // Chaque fenêtre ouverte se rhabille d'elle-même. On ne nomme personne :
    // une fenêtre ajoutée demain sera prévenue sans qu'on y pense.
    app.emit(LANGUAGE_CHANGED_EVENT, language.tag())
        .map_err(|error| error.to_string())?;
    Ok(())
}

/// L'événement que reçoit toute fenêtre ouverte quand la langue change :
/// « redemande ton vocabulaire et repose-le ». Sa charge utile est
/// l'étiquette de la nouvelle langue, pour qu'une fenêtre puisse s'en servir
/// sans redemander.
pub const LANGUAGE_CHANGED_EVENT: &str = "language-changed";

/// Refait la barre de menus telle qu'elle doit être maintenant.
///
/// **Le premier compte allume la moitié du logiciel** (Fabrice, 04/08/2026), et
/// le dernier compte effacé la rééteint. La barre est bâtie une fois par
/// ouverture de base ; sans ce rappel, elle resterait grise jusqu'au prochain
/// lancement, et l'utilisateur qui vient de créer son compte croirait que rien
/// ne s'est passé.
///
/// **À appeler le verrou rendu.** Elle relit la base pour savoir s'il y a un
/// compte, et un verrou tenu deux fois est le figeage du 30/07/2026.
///
/// Une barre qui ne se refait pas n'est pas une raison d'échouer sur ce qu'on
/// venait de faire : le compte est créé, on le dit, et la barre se remettra
/// d'aplomb au prochain geste qui la reconstruit.
pub fn refresh<R: Runtime>(app: &AppHandle<R>) {
    match build(app) {
        Ok(menu) => {
            let _ = app.set_menu(menu);
        }
        Err(error) => eprintln!("[radinus] Could not rebuild the menu bar: {error}"),
    }
}

pub fn build<R: Runtime>(app: &AppHandle<R>) -> tauri::Result<Menu<R>> {
    let language = menu_language(app);
    let t = |key: &str| i18n::text(language, key);

    // **Tant qu'aucune base n'est ouverte, presque tout est gris** (décision
    // de Fabrice, 04/08/2026). Radinus s'ouvre sur la liste des bases : avant
    // qu'on en ait désigné une, il n'y a ni compte, ni opération, ni budget —
    // et une entrée de menu qui s'allume sur rien est un piège, pas une
    // commodité.
    //
    // **Quatre choses restent vivantes**, et ce sont les seules qui ne
    // demandent pas de base : Quitter, « À propos de l'auteur », « À propos de
    // Radinus », et tout le menu Divers — la calculatrice, le site, les deux
    // dossiers.
    //
    // Les menus qui n'ont **que** des entrées à base sont éteints en entier :
    // Comptes, Statistiques, Budget, Nomenclatures. C'est plus franc qu'un
    // menu qui s'ouvre sur quatre lignes grises.
    //
    // **La barre se refait quand une base s'ouvre** — `connect_and_start` la
    // rebâtit déjà —, donc rien à réveiller ici : elle renaît allumée.
    let state = app.try_state::<crate::state::AppState>();
    let opened = state
        .as_ref()
        .map(|state| state.has_database())
        .unwrap_or(false);

    // **Une base sans compte bancaire n'ouvre presque rien non plus** (Fabrice,
    // 04/08/2026) : « le but est d'orienter l'utilisateur vers la création d'un
    // compte bancaire en priorité et qu'il ne se perde pas à explorer d'autres
    // options ». Sans compte il n'y a ni opération, ni solde, ni statistique,
    // ni budget — les fenêtres s'ouvriraient toutes sur du vide.
    //
    // Trois entrées de plus s'allument alors que la barre n'en avait que
    // quatre : **la gestion des comptes**, qui est la sortie, plus les
    // Préférences et l'affichage de la fenêtre principale, qui ne demandent
    // pas de compte.
    //
    // **Le verrou est pris ici et rendu tout de suite.** `switch_language` le
    // rend exprès avant de refaire la barre — « un verrou tenu deux fois est le
    // figeage du 30/07/2026 » —, et cette lecture-ci est celle qu'il avait
    // annoncée. Une base illisible répond « aucun compte » : la barre montre
    // alors la sortie plutôt que de tout allumer sur une base muette.
    let mut has_accounts = false;
    if opened {
        if let Some(state) = state.as_ref() {
            if let Ok(conn) = state.database() {
                has_accounts = radinus_core::accounts::any(&conn).unwrap_or(false);
            }
            // Le verrou repart ici, avant qu'une seule entrée ne soit bâtie.
        }
    }

    // Tout ce qui demande un compte : la base est ouverte **et** elle en porte
    // au moins un.
    let usable = opened && has_accounts;
    // --- Fichier ---
    //
    // **Le sous-menu « Base de données » n'existe plus** (Fabrice, 04/08/2026 :
    // « c'est devenu un doublon, je veux que l'on accède à la gestion de la
    // base de données que durant la procédure de démarrage »).
    //
    // Il ne portait plus qu'une entrée, celle qui ouvrait la fenêtre des bases
    // — et cette fenêtre s'ouvre déjà d'elle-même à chaque lancement : c'est
    // par elle qu'on entre dans Radinus, aucune base n'étant ouverte avant
    // qu'on l'ait désignée. L'entrée ne menait donc nulle part où l'on n'était
    // pas déjà passé.
    //
    // Ce qu'on y fait — sauvegarder, restaurer, réparer, lire le journal — s'y
    // fait maintenant **avant d'ouvrir une base**, dans son menu Outils.
    let file_menu = Submenu::with_items(
        app,
        t("menu-file"),
        true,
        &[
            &MenuItem::with_id(
                app,
                IMPORT_ITEM_ID,
                t("menu-file-import-statements"),
                usable,
                Some("Cmd+I"),
            )?,
            &MenuItem::with_id(
                app,
                IMPORT_EXCEL_ITEM_ID,
                t("menu-file-import-excel"),
                usable,
                None::<&str>,
            )?,
            // **Deux traits, et « Se déconnecter » seule entre les deux**
            // (Fabrice, 05/08/2026 : « ils sont trop proches »). Les deux
            // gestes se ressemblent — on s'en va — et se collent l'un à
            // l'autre ; le second trait est là pour qu'on ne clique pas sur
            // Quitter en voulant se déconnecter.
            //
            // Il y en avait eu trois d'affilée à un moment, cicatrices des
            // entrées parties le 04/08/2026, et cela se voyait sur un menu
            // aussi court. Deux qui séparent trois choses, c'est autre chose.
            &PredefinedMenuItem::separator(app)?,
            &MenuItem::with_id(
                app,
                DISCONNECT_ITEM_ID,
                t("menu-file-disconnect"),
                opened,
                None::<&str>,
            )?,
            &PredefinedMenuItem::separator(app)?,
            &PredefinedMenuItem::quit(app, Some(&t("menu-file-quit")))?,
        ],
    )?;

    // --- Comptes ---
    let accounts_menu = Submenu::with_items(
        app,
        t("menu-accounts"),
        opened,
        &[
            &MenuItem::with_id(
                app,
                ACCOUNTS_ITEM_ID,
                t("menu-accounts-manage"),
                // **La sortie.** Elle reste allumée dès qu'une base est
                // ouverte : c'est par elle qu'on crée le premier compte, et
                // l'éteindre enfermerait l'utilisateur dans une base où il ne
                // pourrait plus rien faire.
                opened,
                Some("Cmd+F1"),
            )?,
            &MenuItem::with_id(
                app,
                BALANCES_ITEM_ID,
                t("menu-accounts-balances"),
                usable,
                Some("Cmd+F2"),
            )?,
            &MenuItem::with_id(
                app,
                OPERATIONS_ITEM_ID,
                t("menu-accounts-operations"),
                usable,
                Some("Cmd+F3"),
            )?,
            &MenuItem::with_id(
                app,
                QUICK_CLASSIFY_ITEM_ID,
                t("menu-accounts-quick-classify"),
                usable,
                Some("Cmd+F4"),
            )?,
            &MenuItem::with_id(
                app,
                RECURRING_ITEM_ID,
                t("menu-accounts-recurring"),
                usable,
                Some("Cmd+F5"),
            )?,
            &MenuItem::with_id(
                app,
                TRANSFER_ITEM_ID,
                t("menu-accounts-transfer"),
                usable,
                Some("Cmd+F6"),
            )?,
            &MenuItem::with_id(
                app,
                CHEQUEBOOKS_ITEM_ID,
                t("menu-accounts-checkbooks"),
                usable,
                Some("Cmd+F7"),
            )?,
            &MenuItem::with_id(
                app,
                BANK_DETAILS_ITEM_ID,
                t("menu-accounts-bank-details"),
                usable,
                None::<&str>,
            )?,
        ],
    )?;

    // --- Statistiques ---
    //
    // Les six sont vivantes depuis que Fabrice a validé celle des catégories
    // (26/07/2026) et demandé d'en tirer les cinq autres. Leurs raccourcis
    // ⌘⇧1 à ⌘⇧6 suivent l'ordre de la liste, celui de l'original.
    let balance_chart = MenuItem::with_id(
        app,
        CURVES_ITEM_ID,
        t("menu-statistics-balance-chart"),
        true,
        Some("Cmd+G"),
    )?;
    let dashboard = MenuItem::with_id(
        app,
        DASHBOARD_ITEM_ID,
        t("menu-statistics-dashboard"),
        true,
        Some("Cmd+T"),
    )?;
    let by_axis: Vec<MenuItem<R>> = AXES
        .iter()
        .enumerate()
        .map(|(rank, axis)| {
            MenuItem::with_id(
                app,
                statistics_item_id(*axis),
                t(statistics_menu_key(*axis)),
                true,
                Some(format!("Cmd+Shift+{}", rank + 1).as_str()),
            )
        })
        .collect::<tauri::Result<Vec<_>>>()?;

    let mut statistics_entries: Vec<&dyn tauri::menu::IsMenuItem<R>> = vec![&balance_chart];
    for item in &by_axis {
        statistics_entries.push(item);
    }
    statistics_entries.push(&dashboard);
    let statistics_menu =
        Submenu::with_items(app, t("menu-statistics"), usable, &statistics_entries)?;

    // --- Budget ---
    let budget_menu = Submenu::with_items(
        app,
        t("menu-budget"),
        usable,
        &[
            &MenuItem::with_id(
                app,
                BUDGET_ENTRY_ITEM_ID,
                t("menu-budget-entry"),
                true,
                None::<&str>,
            )?,
            &MenuItem::with_id(
                app,
                BUDGET_CONTROL_ITEM_ID,
                t("menu-budget-control"),
                true,
                None::<&str>,
            )?,
        ],
    )?;

    // --- Nomenclatures ---
    // Seven live entries, in ALL's order, which is the author's; then
    // "Modèles d'opérations", whose window is phase 10 and stays inert.
    let mut nomenclature_items: Vec<MenuItem<R>> = Vec::with_capacity(8);
    for kind in ALL {
        nomenclature_items.push(MenuItem::with_id(
            app,
            item_id(kind),
            i18n::about(language, "menu-nomenclature", kind.key()),
            true,
            None::<&str>,
        )?);
    }
    nomenclature_items.push(MenuItem::with_id(
        app,
        TEMPLATES_ITEM_ID,
        t("menu-nomenclatures-templates"),
        true,
        None::<&str>,
    )?);
    // **Two rules, asked for by Fabrice on 05/08/2026.** They cut the submenu
    // into three groups that are three different things: the banks, which are
    // the one list a bank statement fills on its own; the six nomenclatures a
    // user writes; and the operation templates, which are not a nomenclature at
    // all — they are ready-made entries waiting to be used.
    //
    // The positions are read from the list rather than counted by hand: after
    // the first entry, and before the last. Adding a nomenclature to `ALL`
    // therefore leaves both rules where they belong.
    let after_banks = PredefinedMenuItem::separator(app)?;
    let before_templates = PredefinedMenuItem::separator(app)?;
    let mut nomenclature_entries: Vec<&dyn tauri::menu::IsMenuItem<R>> =
        Vec::with_capacity(nomenclature_items.len() + 2);
    for (rank, item) in nomenclature_items.iter().enumerate() {
        if rank + 1 == nomenclature_items.len() {
            nomenclature_entries.push(&before_templates);
        }
        nomenclature_entries.push(item);
        if rank == 0 {
            nomenclature_entries.push(&after_banks);
        }
    }
    let nomenclature_menu =
        Submenu::with_items(app, t("menu-nomenclatures"), usable, &nomenclature_entries)?;

    // --- Paramètres ---
    let settings_menu = Submenu::with_items(
        app,
        t("menu-settings"),
        true,
        &[
            &MenuItem::with_id(
                app,
                PREFERENCES_ITEM_ID,
                t("menu-settings-preferences"),
                opened,
                None::<&str>,
            )?,
            &MenuItem::with_id(
                app,
                SHOW_MAIN_ITEM_ID,
                t("menu-settings-show-main"),
                opened,
                None::<&str>,
            )?,
            &PredefinedMenuItem::separator(app)?,
            &MenuItem::with_id(
                app,
                ABOUT_AUTHOR_ITEM_ID,
                t("menu-settings-about-author"),
                true,
                None::<&str>,
            )?,
            &MenuItem::with_id(
                app,
                ABOUT_RADINUS_ITEM_ID,
                t("menu-settings-about-radinus"),
                true,
                None::<&str>,
            )?,
            &MenuItem::with_id(
                app,
                LICENCE_ITEM_ID,
                t("menu-settings-licence"),
                true,
                None::<&str>,
            )?,
        ],
    )?;

    // --- Divers ---
    // La calculatrice n'entre dans la liste que là où le système en a une :
    // masquée et non grisée, décision de Fabrice du 03/08/2026.
    let mut misc_items: Vec<MenuItem<R>> = Vec::new();
    #[cfg(any(target_os = "macos", target_os = "windows"))]
    misc_items.push(MenuItem::with_id(
        app,
        CALCULATOR_ITEM_ID,
        t("menu-misc-calculator"),
        true,
        None::<&str>,
    )?);
    for (id, key) in [
        (WEBSITE_ITEM_ID, "menu-misc-website"),
        (DATABASE_FOLDER_ITEM_ID, "menu-misc-database-folder"),
        (APPLICATION_FOLDER_ITEM_ID, "menu-misc-application-folder"),
    ] {
        misc_items.push(MenuItem::with_id(app, id, t(key), true, None::<&str>)?);
    }
    let misc_entries: Vec<&dyn tauri::menu::IsMenuItem<R>> = misc_items
        .iter()
        .map(|item| item as &dyn tauri::menu::IsMenuItem<R>)
        .collect();
    let misc_menu = Submenu::with_items(app, t("menu-misc"), true, &misc_entries)?;

    Menu::with_items(
        app,
        &[
            &file_menu,
            &accounts_menu,
            &statistics_menu,
            &budget_menu,
            &nomenclature_menu,
            &settings_menu,
            &misc_menu,
        ],
    )
}

/// Aiguille un clic de menu. Un identifiant dont la fenêtre n'existe pas
/// encore est ignoré en silence.
pub fn on_event<R: Runtime>(app: &AppHandle<R>, event: tauri::menu::MenuEvent) {
    let language = menu_language(app);

    // **La langue n'est plus dans ce menu** (Fabrice, 03/08/2026 : « elle fait
    // doublon avec les préférences »). Elle se règle dans F39, feuille
    // « Langue », qui appelle la commande `set_language` — laquelle passe par
    // `switch_language` ci-dessus. Un seul chemin, une seule fonction.

    if event.id() == ACCOUNTS_ITEM_ID {
        let list = crate::windows::accounts_list_window(
            language,
            crate::windows::AccountsPurpose::Manage,
        );
        if let Err(error) = crate::windows::open(app, &list, None) {
            eprintln!("[radinus] Could not open the accounts window: {error}");
        }
        return;
    }
    // Les deux fenêtres qui travaillent sur **un** compte passent par la même
    // question. Ce qu'on vient y faire voyage avec elle : sans cela, choisir un
    // compte ouvrirait toujours la même chose, quelle que soit l'entrée de menu
    // cliquée — la faute exacte des six statistiques du 26/07/2026.
    for (id, target) in [
        (OPERATIONS_ITEM_ID, "operations"),
        (QUICK_CLASSIFY_ITEM_ID, "quick-classify"),
        (IMPORT_ITEM_ID, "statement-import"),
        (IMPORT_EXCEL_ITEM_ID, "excel-import"),
        (BANK_DETAILS_ITEM_ID, "bank-details"),
    ] {
        if event.id() == id {
            let list = crate::windows::accounts_list_window(
                language,
                crate::windows::AccountsPurpose::OneAccount,
            );
            if let Err(error) = crate::windows::open(app, &list, Some(&format!("target={target}")))
            {
                eprintln!("[radinus] Could not open the accounts chooser: {error}");
            }
            return;
        }
    }
    for (id, axis) in [(DASHBOARD_ITEM_ID, "dashboard"), (CURVES_ITEM_ID, "curves")] {
        if event.id() == id {
            // Comme les statistiques : on demande d'abord sur quels comptes.
            let list = crate::windows::accounts_list_window(
                language,
                crate::windows::AccountsPurpose::ManyAccounts,
            );
            if let Err(error) = crate::windows::open(app, &list, Some(&format!("axis={axis}"))) {
                eprintln!("[radinus] Could not open the accounts chooser: {error}");
            }
            return;
        }
    }
    for axis in AXES {
        if event.id() == statistics_item_id(axis) {
            // Une statistique se calcule sur plusieurs comptes : on demande
            // lesquels avant d'ouvrir quoi que ce soit. **L'axe voyage avec la
            // question** — le choix des comptes ouvrira la statistique
            // demandée, et non celle d'une fois précédente.
            let list = crate::windows::accounts_list_window(
                language,
                crate::windows::AccountsPurpose::ManyAccounts,
            );
            if let Err(error) =
                crate::windows::open(app, &list, Some(&format!("axis={}", axis.key())))
            {
                eprintln!("[radinus] Could not open the accounts chooser: {error}");
            }
            return;
        }
    }
    for (id, control) in [(BUDGET_ENTRY_ITEM_ID, false), (BUDGET_CONTROL_ITEM_ID, true)] {
        if event.id() == id {
            let window = crate::windows::budget_window(language, control);
            if let Err(error) = crate::windows::open(app, &window, None) {
                eprintln!("[radinus] Could not open the budget window: {error}");
            }
            return;
        }
    }
    if event.id() == TRANSFER_ITEM_ID {
        let window = crate::windows::transfer_window(language);
        if let Err(error) = crate::windows::open(app, &window, None) {
            eprintln!("[radinus] Could not open the transfer window: {error}");
        }
        return;
    }
    if event.id() == TEMPLATES_ITEM_ID {
        let window = crate::windows::operation_templates_window(language, false);
        if let Err(error) = crate::windows::open(app, &window, None) {
            eprintln!("[radinus] Could not open the templates window: {error}");
        }
        return;
    }
    if event.id() == CHEQUEBOOKS_ITEM_ID {
        // Tous les carnets, tous comptes confondus : pas de question à poser.
        let window = crate::windows::chequebooks_window(language);
        if let Err(error) = crate::windows::open(app, &window, None) {
            eprintln!("[radinus] Could not open the chequebooks window: {error}");
        }
        return;
    }
    if event.id() == RECURRING_ITEM_ID {
        // Chaque règle porte son compte : la liste s'ouvre directement, comme
        // celle des chéquiers.
        let window = crate::windows::recurring_list_window(language);
        if let Err(error) = crate::windows::open(app, &window, None) {
            eprintln!("[radinus] Could not open the recurring rules window: {error}");
        }
        return;
    }
    // --- Divers : chaque entrée fait ce qu'elle annonce ---------------------
    #[cfg(any(target_os = "macos", target_os = "windows"))]
    if event.id() == CALCULATOR_ITEM_ID {
        if let Err(error) = crate::system::open_calculator() {
            eprintln!("[radinus] Could not open the system calculator: {error}");
        }
        return;
    }
    if event.id() == WEBSITE_ITEM_ID {
        if let Err(error) = crate::system::open_link(WEBSITE) {
            eprintln!("[radinus] Could not open {WEBSITE}: {error}");
        }
        return;
    }
    if event.id() == DATABASE_FOLDER_ITEM_ID || event.id() == APPLICATION_FOLDER_ITEM_ID {
        let state = app.state::<crate::state::AppState>();
        let folder = if event.id() == APPLICATION_FOLDER_ITEM_ID {
            // **The folder the application sits in — what the label says.**
            //
            // It used to be the same as the data root, and this line read
            // `data_root` for that reason. The installed mode split the two on
            // 05/08/2026, and this entry silently started opening the data
            // folder instead. Reported by Fabrice the same day.
            state.application_root.clone()
        } else {
            // **Le dossier autonome de la base ouverte** (choix de Fabrice) :
            // il porte le `.sqlite` et son `attachments/`, si bien que le
            // copier emporte la base sans la séparer de ses pièces jointes.
            //
            // `attachments_dir` vaut `…/Radinus_NNNNN/attachments`, son père
            // est le dossier cherché. Sans base ouverte il est vide, et l'on
            // montre alors `databases/`, qui existe toujours — plutôt que de
            // ne rien faire sans rien dire.
            let attachments = state.attachments_dir();
            attachments
                .parent()
                .map(std::path::Path::to_path_buf)
                .filter(|slot| slot.is_dir())
                .unwrap_or_else(|| state.data_root.join("databases"))
        };
        if let Err(error) = crate::system::open_with_desktop(&folder) {
            eprintln!("[radinus] Could not open {}: {error}", folder.display());
        }
        return;
    }

    // **Se déconnecter : on referme, on ne quitte pas.**
    //
    // Les fenêtres sont **cachées et non détruites**, comme partout dans
    // Radinus : fermer pour de bon voudrait dire les rebâtir à la prochaine
    // ouverture, et sur deux systèmes sur trois la dernière fenêtre fermée
    // arrête le logiciel. Cacher fait tout ce qu'on veut ici.
    //
    // Le sélecteur est remontré **après** le détachement, et le menu refait
    // après lui : il se grise tout seul en constatant qu'aucune base n'est
    // ouverte, et la fenêtre des bases relit sa liste en reprenant le focus.
    if event.id() == DISCONNECT_ITEM_ID {
        for (label, window) in app.webview_windows() {
            if label != "database-selector" {
                let _ = window.hide();
            }
        }
        if let Some(state) = app.try_state::<crate::state::AppState>() {
            if let Err(error) = state.detach() {
                eprintln!("[radinus] Could not detach the database: {error}");
            }
        }
        let selector = crate::windows::database_selector_window(language);
        if let Err(error) = crate::windows::open(app, &selector, None) {
            eprintln!("[radinus] Could not reopen the database selector: {error}");
        }
        refresh(app);
        return;
    }

    if event.id() == SHOW_MAIN_ITEM_ID {
        if let Some(window) = app.get_webview_window("main") {
            let _ = window.unminimize();
            let _ = window.show();
            let _ = window.set_focus();
        }
        return;
    }
    if event.id() == ABOUT_RADINUS_ITEM_ID {
        let window = crate::windows::about_radinus_window(language);
        if let Err(error) = crate::windows::open(app, &window, None) {
            eprintln!("[radinus] Could not open the about-radinus window: {error}");
        }
        return;
    }
    if event.id() == LICENCE_ITEM_ID {
        let window = crate::windows::licence_window(language);
        if let Err(error) = crate::windows::open(app, &window, None) {
            eprintln!("[radinus] Could not open the licence window: {error}");
        }
        return;
    }
    if event.id() == ABOUT_AUTHOR_ITEM_ID {
        let window = crate::windows::about_author_window(language);
        if let Err(error) = crate::windows::open(app, &window, None) {
            eprintln!("[radinus] Could not open the about-author window: {error}");
        }
        return;
    }
    if event.id() == PREFERENCES_ITEM_ID {
        let window = crate::windows::preferences_window(language);
        if let Err(error) = crate::windows::open(app, &window, None) {
            eprintln!("[radinus] Could not open the preferences window: {error}");
        }
        return;
    }
    if event.id() == BALANCES_ITEM_ID {
        let window = crate::windows::balances_window(language);
        if let Err(error) = crate::windows::open(app, &window, None) {
            eprintln!("[radinus] Could not open the balances window: {error}");
        }
        return;
    }

    for kind in ALL {
        if event.id() == item_id(kind) {
            let list = crate::windows::list_window(kind, language);
            if let Err(error) = crate::windows::open(app, &list, None) {
                eprintln!("[radinus] Could not open the {} window: {error}", list.label);
            }
            return;
        }
    }
}
