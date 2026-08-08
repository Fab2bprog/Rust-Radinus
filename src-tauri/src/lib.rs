//! Radinus — Tauri controller.
//!
//! This crate is deliberately thin: it is the *only* layer allowed to know
//! about Tauri (see 08_ARCHITECTURE.md §2.2). Every command just translates
//! an IPC call into a `radinus_core` call and forwards the result — no
//! business logic lives here.

mod commands;
#[cfg(test)]
mod crossings;
mod texts;
mod menu;
mod state;
mod database_operations;
mod system;
mod windows;

use state::AppState;

/// **Ce que le démarrage a trouvé** (décisions de Fabrice, 02/08/2026).
///
/// Radinus ne crée plus de base sans rien demander, et **il n'en ouvre plus
/// aucune tout seul**. L'ordre est celui que Fabrice a fixé : la langue
/// d'abord, puisque sans elle on ne saurait pas dans quelle langue poser la
/// question suivante ; puis le sélecteur de base, **à chaque démarrage**, et
/// c'est l'utilisateur qui dit laquelle ouvrir.
///
/// D'où l'absence d'une variante « une base est ouverte » : à la fin du
/// démarrage, il n'y en a jamais.
enum Startup {
    /// Le tout premier lancement : la configuration ne porte pas de langue.
    /// C'est aussi le cas de l'exécutable donné à quelqu'un, tout seul, sans
    /// rien à côté.
    NeedsLanguage {
        root: std::path::PathBuf,
        beside: std::path::PathBuf,
    },
    /// Le cas de tous les autres lancements : la langue est connue, et le
    /// sélecteur de base s'ouvre.
    NeedsDatabase {
        root: std::path::PathBuf,
        beside: std::path::PathBuf,
        language: radinus_core::i18n::Language,
    },
    /// Radinus n'a pas pu se faire une place sur le disque. Celle-là est une
    /// panne, et elle se dit en toutes lettres sur la fenêtre d'accueil.
    Broken {
        root: std::path::PathBuf,
        beside: std::path::PathBuf,
        reason: String,
    },
}

/// Quelle fenêtre s'ouvre en premier.
#[derive(Clone, Copy, PartialEq, Eq)]
enum FirstScreen {
    /// La fenêtre d'accueil — elle ne paraît au démarrage que pour dire une
    /// panne. Autrement, elle attend qu'une base soit ouverte.
    Home,
    /// La liste des langues, chacune écrite dans la sienne.
    Language,
    /// Le sélecteur de base.
    Database,
}

/// **Il lit, il décide, il crée** — dans cet ordre, et l'ordre compte.
///
/// `data_root` ne fait que lire : elle cherche `settings/start_mode.toml` à
/// côté de l'exécutable et rend, selon ce qu'elle y trouve, le dossier de
/// l'application ou celui du système. L'arborescence n'est créée qu'ensuite,
/// dans le dossier ainsi désigné — jamais avant de savoir lequel, sinon
/// Radinus laisserait un dossier vide à côté de lui avant de partir ailleurs.
///
/// **Il n'ouvre aucune base** : c'est le sélecteur qui le fera, avec l'accord
/// de l'utilisateur.
fn bootstrap_data_location() -> Startup {
    use radinus_core::i18n::Language;
    use radinus_core::location;

    let exe_path = std::env::current_exe().unwrap_or_default();

    // La translocation ne gêne plus que le mode portable — en mode installé,
    // les données sont dans le dossier du système et le chemin de
    // l'exécutable n'entre pas dans le calcul. Mais elle empêche justement de
    // *lire* le fichier de mode, donc une application translocalisée démarre
    // toujours en mode installé, quoi qu'on ait posé à côté d'elle.
    if location::is_app_translocated(&exe_path) {
        eprintln!(
            "[radinus] Warning: the app appears to be running from a macOS \
             App Translocation path. Move Radinus.app out of the location \
             it was downloaded to (e.g. onto the Desktop or into the folder \
             where you keep it) before launching it, otherwise Radinus cannot \
             read its start_mode.toml and will always start in installed mode."
        );
    }

    // **Deux dossiers, et depuis le 05/08/2026 ils ne sont plus le même.**
    // `beside` est celui qui porte l'application ; `root` celui qui porte les
    // données, qui lui est identique en mode portable et ailleurs en mode
    // installé.
    let beside = location::beside_the_application(&exe_path);
    let root = location::data_root(&exe_path);
    if let Err(error) = location::ensure_tree(&root) {
        return Startup::Broken {
            reason: format!(
                "Radinus n'a pas pu créer ses dossiers ({}) : {error}",
                root.display()
            ),
            root,
            beside,
        };
    }

    let config = location::read_config(&root).unwrap_or_default();

    // **La taille de l'affichage est posée avant la première fenêtre** (Fabrice,
    // 04/08/2026 : « ce sera un paramètre du logiciel »). Elle vivait dans la
    // base et n'était donc appliquée qu'à son ouverture — le sélecteur de base
    // et le choix de la langue s'affichaient toujours à 100 %, c'est-à-dire
    // trop petit pour qui avait justement réglé le contraire. Les deux
    // premières fenêtres qu'il voit sont maintenant à sa taille.
    crate::windows::set_zoom_factor(config.zoom_factor());

    match config.language.as_deref() {
        None => Startup::NeedsLanguage { root, beside },
        Some(tag) => Startup::NeedsDatabase {
            language: Language::from_tag(tag),
            root,
            beside,
        },
    }
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        // Le sélecteur de fichier du système, pour l'export des tableaux : le
        // vrai explorateur sous Windows, le Finder sous macOS, le portail sous
        // Linux. Seule la sauvegarde est permise, jamais la lecture (voir
        // `capabilities/default.json`).
        .plugin(tauri_plugin_dialog::init())
        .setup(|app| {
            // The state is registered whatever happens. A failed bootstrap
            // used to leave it unregistered, so every window opened, looked
            // perfectly normal, and broke on the first click with the
            // framework's own "state not managed" — a message that means
            // nothing to the user. Now the reason travels with the state and
            // every window can say it plainly.
            //
            // **Le dictionnaire de la langue en vigueur est préparé ici**
            // (demande de Fabrice, 01/08/2026). Analyser le fichier de langue
            // coûte quelques millisecondes ; les passer pendant le démarrage,
            // où l'on attend déjà, plutôt que devant la première fenêtre, où
            // l'on attend cette fenêtre-là.
            use radinus_core::i18n::Language;
            let mut chosen_language = Language::French;
            let (state, first) = match bootstrap_data_location() {
                Startup::NeedsLanguage { root, beside } => {
                    // Aucune langue choisie : le français garnit le menu, et
                    // la fenêtre qui s'ouvre n'emploie aucune phrase — ses
                    // trois lignes sont écrites chacune dans sa propre langue.
                    radinus_core::i18n::prepare(Language::French);
                    (AppState::pending(root, beside), FirstScreen::Language)
                }
                Startup::NeedsDatabase { root, beside, language } => {
                    chosen_language = language;
                    radinus_core::i18n::prepare(language);
                    (AppState::pending(root, beside), FirstScreen::Database)
                }
                Startup::Broken { root, beside, reason } => {
                    eprintln!("[radinus] Portable app bootstrap failed: {reason}");
                    radinus_core::i18n::prepare(Language::French);
                    (AppState::failed(reason, root, beside), FirstScreen::Home)
                }
            };
            tauri::Manager::manage(app, state);

            let menu = menu::build(app.handle())?;
            menu::install(app.handle(), menu)?;
            app.on_menu_event(menu::on_event);

            // **La fenêtre d'accueil s'efface tant qu'aucune base n'est
            // ouverte** : elle ne saurait rien montrer, et son menu agirait
            // sur une base qui n'existe pas.
            //
            // Elle est **bâtie visible puis cachée**, et non déclarée
            // invisible dans `tauri.conf.json` : une fenêtre créée invisible
            // se montrait blanche — cadre, titre, et rien dedans. C'est la
            // règle que Radinus suit partout ailleurs depuis le 25/07/2026,
            // et je l'avais enfreinte ici.
            let handle = app.handle();
            let main = tauri::Manager::get_webview_window(app, "main");
            match first {
                FirstScreen::Home => {
                    if let Some(main) = main {
                        let _ = main.set_focus();
                    }
                }
                FirstScreen::Language => {
                    windows::open(handle, &windows::language_choice_window(), None)?;
                    if let Some(main) = main {
                        let _ = main.hide();
                    }
                }
                FirstScreen::Database => {
                    windows::open(
                        handle,
                        &windows::database_selector_window(chosen_language),
                        None,
                    )?;
                    if let Some(main) = main {
                        let _ = main.hide();
                    }
                }
            }

            // **La croix de la fenêtre d'accueil, et elle ne peut pas faire la
            // même chose sur les trois systèmes.**
            //
            // Elle était la seule fenêtre de Radinus qu'on pouvait détruire :
            // toutes les autres sont bâties `closable: false` et se quittent
            // par leur porte, qui les masque. Celle-ci vient de
            // `tauri.conf.json`, où rien ne le disait — un clic sur la croix
            // l'effaçait pour de bon, et « Paramètres › Afficher la fenêtre
            // principale » n'avait plus rien à montrer (signalé le
            // 03/08/2026).
            //
            // **Sous macOS, elle range.** La barre de menus appartient à
            // l'application et non à la fenêtre : elle reste en haut de
            // l'écran quand la fenêtre disparaît, donc l'entrée de menu qui la
            // rappelle est toujours atteignable. C'est aussi la convention du
            // système — fermer la dernière fenêtre n'y quitte pas un logiciel.
            //
            // **Sous Windows et Linux, elle quitte.** La barre de menus y
            // appartient à la fenêtre : la cacher laisserait Radinus tourner
            // sans rien de visible, sans menu et sans moyen d'en rouvrir un —
            // les autres fenêtres étant masquées et non détruites, il ne se
            // fermerait pas non plus tout seul. Il aurait fallu le
            // gestionnaire des tâches. C'est également ce que fait Radinus
            // 1.9.3 : sa fenêtre principale fermée, le programme s'arrête.
            //
            // Deux comportements pour un même geste, chacun celui de son
            // système. La question est de Fabrice, le 03/08/2026, et elle a
            // évité le piège.
            if let Some(main) = tauri::Manager::get_webview_window(app, "main") {
                let handle = app.handle().clone();
                let hidden = main.clone();
                main.on_window_event(move |event| {
                    if let tauri::WindowEvent::CloseRequested { api, .. } = event {
                        if cfg!(target_os = "macos") {
                            api.prevent_close();
                            let _ = hidden.hide();
                        } else {
                            handle.exit(0);
                        }
                    }
                });
            }

            Ok(())
        })
        // `ping` n'est plus offerte au frontend. C'était la preuve de chaîne de
        // la phase 0, et son propre commentaire annonçait sa fin : « removed once
        // the first real window (F02, Phase 5) exists ». La fenêtre d'accueil de
        // la phase 17 bis a emporté son dernier appel, et le croisement l'a dit
        // aussitôt — une commande offerte que personne n'appelle est une porte
        // ouverte pour rien. La fonction et ses deux tests restent : ils prouvent
        // le même chemin Vue → Contrôleur → Core sans l'exposer. Une ligne à
        // remettre dans la liste si l'on veut garder le témoin jusqu'au jalon 0.
        //
        // ⚠ **Aucun commentaire ne va DANS la liste ci-dessous.** `crossings.rs`
        // la découpe sur les virgules et exige que chaque morceau commence par
        // `commands::` ; un commentaire — qui contient lui-même des virgules —
        // avale l'entrée qui le suit, et cette commande est alors déclarée
        // absente du pont alors qu'elle y est. Constaté le 03/08/2026 : c'est ce
        // commentaire-ci, écrit à l'intérieur, qui a fait porter le chapeau à
        // `welcome`.
        .invoke_handler(tauri::generate_handler![
            commands::welcome,
            commands::preferences_currency,
            commands::save_preferences_currency,
            commands::save_preferences_zoom,
            commands::app_version,
            commands::open_licence_page,
            commands::menu_shortcuts,
            commands::menu_shortcut,
            commands::close_preferences,
            commands::startup_error,
            commands::choose_language,
            commands::list_databases,
            commands::database_is_open,
            commands::open_database,
            commands::backup_database,
            commands::restore_database,
            commands::repair_database,
            commands::open_operations_journal,
            commands::create_database,
            commands::system_currency_sign,
            commands::open_database_form,
            commands::open_password_form,
            commands::set_database_password,
            commands::database_needs_password,
            commands::open_language_choice,
            commands::leave_language_choice,
            commands::open_preferences,
            commands::pick_backup_archive,
            commands::notify_databases_changed,
            commands::database_delete_question,
            commands::delete_database,
            commands::leave_database_selector,
            commands::ui_texts,
            commands::retitle,
            commands::current_language,
            commands::available_languages,
            commands::set_language,
            commands::account_initial_balance_question,
            commands::account_initial_balance,
            commands::account_statistics,
            commands::account_delete_operations_question,
            commands::delete_account_operations,
            commands::ui_deleted_text,
            commands::list_elements,
            commands::list_budget_lines,
            commands::get_element,
            commands::duplicate_name,
            commands::create_element,
            commands::update_element,
            commands::plan_deletion,
            commands::delete_elements,
            commands::open_nomenclature_list,
            commands::open_element_form,
            commands::notify_elements_changed,
            commands::list_has_unsaved_changes,
            commands::set_form_dirty,
            commands::set_form_record,
            commands::list_may_close,
            commands::list_accounts,
            commands::accounts_total,
            commands::list_banks,
            commands::list_account_types,
            commands::get_account,
            commands::account_refusal,
            commands::create_account,
            commands::update_account,
            commands::plan_account_deletion,
            commands::delete_accounts,
            commands::accounts_deleted_text,
            commands::open_accounts_list,
            commands::open_account_form,
            commands::open_balances_window,
            commands::notify_accounts_changed,
            commands::set_account_form_dirty,
            commands::set_account_form_record,
            commands::accounts_list_has_unsaved_changes,
            commands::accounts_list_may_close,
            commands::list_operations,
            commands::plan_operations_deletion,
            commands::delete_operations,
            commands::operations_deleted_text,
            commands::open_operations_list,
            commands::operations_selection_total,
            commands::list_operation_combos,
            commands::set_operation_nomenclature,
            commands::close_operations_list,
            commands::list_operation_statuses,
            commands::get_operation,
            commands::operation_fitid,
            commands::set_operation_fitid,
            commands::operation_attachments_text,
            commands::operation_refusal,
            commands::create_operation,
            commands::update_operation,
            commands::open_operation_form,
            commands::notify_operations_changed,
            commands::set_operation_form_dirty,
            commands::set_operation_form_record,
            commands::operations_list_has_unsaved_changes,
            commands::sub_operation_parent_line,
            commands::get_sub_operation,
            commands::sub_operation_refusal,
            commands::create_sub_operation,
            commands::update_sub_operation,
            commands::open_sub_operation_form,
            commands::point_operations,
            commands::axis_statistics,
            commands::statistics_switch_labels,
            commands::statistics_year_prompt,
            commands::statistics_year,
            commands::statistics_detail,
            commands::open_statistics,
            commands::open_form_for_operation,
            commands::export_sheet,
            commands::export_book,
            commands::export_context,
            commands::statistics_years,
            commands::dashboard,
            commands::open_dashboard,
            commands::close_dashboard,
            commands::balance_curves,
            commands::shift_period,
            commands::open_balance_curves,
            commands::close_balance_curves,
            commands::close_statistics,
            commands::quick_classification_load,
            commands::quick_classification_lines,
            commands::quick_classification_apply,
            commands::quick_classification_set,
            commands::quick_classification_question,
            commands::quick_classification_save,
            commands::open_quick_classification,
            commands::close_quick_classification,
            commands::statement_pick_file,
            commands::statement_load,
            commands::statement_lines,
            commands::statement_file_info,
            commands::statement_integrate_line,
            commands::statement_integration_report,
            commands::statement_amend,
            commands::statement_line,
            commands::statement_integrate,
            commands::open_statement_import,
            commands::close_statement_import,
            commands::open_statement_form,
            commands::close_statement_form,
            commands::csv_statement_source,
            commands::csv_statement_extract,
            commands::csv_statement_apply,
            commands::open_csv_statement,
            commands::list_chequebooks,
            commands::get_chequebook,
            commands::chequebook_refusal,
            commands::chequebook_creation_question,
            commands::create_chequebook,
            commands::update_chequebook,
            commands::plan_chequebook_deletion,
            commands::delete_chequebooks,
            commands::chequebooks_deleted_text,
            commands::list_cheques,
            commands::list_cheque_statuses,
            commands::get_cheque,
            commands::update_cheque,
            commands::set_cheque_status,
            commands::cheque_operations,
            commands::associate_cheque,
            commands::dissociate_cheque,
            commands::open_chequebook_form,
            commands::operation_cheque,
            commands::choose_cheque_for_operation,
            commands::choose_cheque_in_chequebook,
            commands::close_cheque_choice,
            commands::open_cheques,
            commands::open_cheque_form,
            commands::open_cheque_operations,
            commands::notify_cheques_changed,
            commands::close_cheque_window,
            commands::list_operation_templates,
            commands::get_operation_template,
            commands::operation_template_refusal,
            commands::create_operation_template,
            commands::update_operation_template,
            commands::delete_operation_templates,
            commands::operation_templates_deleted_text,
            commands::open_operation_templates,
            commands::open_operation_template_form,
            commands::apply_operation_template,
            commands::close_operation_template_window,
            commands::notify_operation_templates_changed,
            commands::budget_grid,
            commands::budget_save,
            commands::budget_control,
            commands::transfer_balances,
            commands::transfer_refusal,
            commands::perform_transfer,
            commands::close_csv_statement,
            commands::export_operations,
            commands::print_operations,
            commands::bank_details,
            commands::print_bank_details,
            commands::list_printers,
            commands::journal_entries,
            commands::close_journal_window,
            commands::list_attachments,
            commands::add_attachment,
            commands::replace_attachment,
            commands::open_attachment,
            commands::attachment_removal_question,
            commands::delete_attachment,
            commands::attachments_inventory,
            commands::attachments_summary,
            commands::attachment_disk_name,
            commands::open_orphan_attachment,
            commands::orphan_removal_question,
            commands::delete_orphan_attachment,
            commands::reveal_attachment,
            commands::open_attachments_window,
            commands::close_attachments_window,
            commands::open_bank_details,
            commands::close_rib_window,
            commands::list_recurring_rules,
            commands::get_recurring_rule,
            commands::recurring_refusal,
            commands::create_recurring_rule,
            commands::update_recurring_rule,
            commands::delete_recurring_rules,
            commands::recurring_erase_question,
            commands::erase_recurring_operations,
            commands::recurring_calendar,
            commands::recurring_removed_text,
            commands::recurring_insert_question,
            commands::insert_recurring,
            commands::open_recurring_form,
            commands::open_recurring_calendar,
            commands::close_recurring_window,
            commands::excel_pick_file,
            commands::excel_test,
            commands::excel_state,
            commands::excel_links,
            commands::excel_set_links,
            commands::excel_policies,
            commands::excel_set_policy,
            commands::excel_association,
            commands::excel_set_association,
            commands::excel_run_refusal,
            commands::excel_run,
            commands::open_excel_import,
            commands::open_excel_fields,
            commands::open_excel_association,
            commands::close_excel_window,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

// **Il n'y a plus de `ping` ici.** C'était la preuve de chaîne de la phase 0,
// retirée du pont le 03/08/2026 quand la fenêtre d'accueil a emporté son
// dernier appel — et laissée en place, ce qui a valu un avertissement
// `dead_code` à chaque compilation : un test sous `cfg(test)` n'est pas un
// appelant pour le compilateur.
//
// `radinus_core::ping` reste, avec son propre test. Le chemin
// Vue → Contrôleur → Core, lui, est prouvé deux cent vingt fois par jour par
// les commandes qui font vraiment quelque chose.
