//! IPC commands. Every one of them is a thin translation of a JSON call into
//! a `radinus_core` call — no business rule lives in this crate
//! (08_ARCHITECTURE.md §2.2). Une commande ajoutée ici doit être enregistrée
//! dans `generate_handler!` et appelée par une fenêtre : la couture
//! `every_command_a_window_calls_is_a_command_rust_answers` tient les deux
//! bouts, et c'est elle qui a remplacé le `docs/IPC_CONTRACT.md` que ce
//! commentaire nommait — un document que rien n'obligeait à rester vrai.
//!
//! **Every command takes the nomenclature it works on.** The seven of them
//! share one list page and one fiche page (04_SPECIFICATIONS_FENETRES.md: the
//! same gabarit, minus the budget-line field), so they share these commands
//! too. `kind` is the nomenclature's key — `category`, `assignment`,
//! `payment-mode`, `payee`, `project`, `budget-line`, `bank` — and an unknown
//! one is refused rather than guessed.

use crate::state::{to_ipc_error, AppState};
use radinus_core::i18n::Language;
use radinus_core::nomenclatures::{self, Nomenclature};
use serde::Serialize;
use tauri::{AppHandle, Emitter, Manager, Runtime, State};

/// One row of a nomenclature list, and of the budget-line combo.
#[derive(Serialize)]
pub struct ItemDto {
    pub id: i64,
    pub label: String,
}

/// An element as the fiche shows it. `budget_line_id` is only meaningful for
/// a category — it is the one nomenclature with a field beyond its label —
/// and stays at « Non précisé » for all the others.
#[derive(Serialize)]
pub struct ElementDto {
    pub id: i64,
    pub label: String,
    pub budget_line_id: i64,
}

/// What deleting a selection would entail: whether it is refused outright,
/// whether to ask the question, and the question itself, already worded and
/// translated.
#[derive(Serialize)]
pub struct DeletionPlanDto {
    /// Set when the deletion cannot go ahead at all. `refusal` then says why,
    /// and no question is asked: there is nothing to confirm.
    pub refused: bool,
    pub refusal: String,
    pub needs_confirmation: bool,
    pub question: String,
    /// A second question, asked after the first has been answered yes, and
    /// which is only answered by **typing a word** — empty when one question
    /// is enough. Deleting a bank account takes its whole history with it,
    /// and a Yes/No is clicked without reading (Fabrice, 26/07/2026).
    pub second_question: String,
    /// The word that answers it, in the language of the interface.
    pub confirmation_word: String,
    pub operations: i64,
    pub operation_templates: i64,
    pub recurring_rules: i64,
}

/// La langue dans laquelle Radinus écrit.
///
/// **Elle ne prend plus de connexion, et c'est tout l'intérêt** (décision de
/// Fabrice, 03/08/2026 : « on ne tient compte que de ce qui est dans
/// `settings/radinus_config.json`, pas ailleurs »). Tant qu'elle en prenait
/// une, chacune des 95 commandes qui l'appellent lisait la langue de la base
/// ouverte — et la base disait autre chose que la configuration. Le
/// compilateur interdit maintenant ce qu'un commentaire aurait demandé
/// poliment : il n'y a plus de connexion à donner, donc plus de langue à lire
/// dans la base.
///
/// Elle ne prend aucun verrou non plus, ce qui règle au passage le danger que
/// l'ancienne version signalait : demander sa connexion à l'état alors qu'on
/// la tient déjà gelait l'application sur place.
fn ui_language() -> Language {
    radinus_core::i18n::in_use()
}

/// La langue d'une fenêtre — la même que partout ailleurs.
///
/// Elle avait deux cas jusqu'au 03/08/2026 : la base si une base était
/// ouverte, la configuration sinon. C'est exactement ce qui faisait le
/// sélecteur de base en anglais suivi de fenêtres en français. Il n'y a plus
/// qu'une source, donc plus qu'un cas.
///
/// Elle garde son nom et son paramètre pour que les 43 fenêtres qui l'appellent
/// n'aient pas à changer.
fn window_language(_state: &AppState) -> Language {
    ui_language()
}

/// The nomenclature a window says it is working on. An unknown key is an
/// error the user can read, not a silent fallback onto some default: a window
/// working on the wrong table would corrupt data without ever complaining.
fn nomenclature(kind: &str) -> Result<Nomenclature, String> {
    Nomenclature::from_key(kind).ok_or_else(|| format!("Nomenclature inconnue : « {kind} »"))
}

/// **Le « kind » sous lequel une fenêtre demande son vocabulaire** : une
/// nomenclature, ou un axe des statistiques.
///
/// Les deux listes se recouvraient exactement tant que les six statistiques
/// portaient chacune sur une nomenclature, et `ui_texts` ne reconnaissait donc
/// que les nomenclatures. La septième statistique, par vérification, n'en est
/// pas une : sa fenêtre demandait son vocabulaire, essuyait un refus, et
/// s'arrêtait avant d'avoir rien posé — ni mots, ni interrupteurs, ni comptes.
/// Fabrice l'a vue le 03/10/2026 : une fenêtre vide, des clefs à la place des
/// phrases, et « aucun compte » en rouge.
///
/// Rend la clef stable du genre, qui est ce que les phrases de Fluent
/// sélectionnent. Un genre inconnu reste refusé : un vocabulaire décliné sur
/// n'importe quoi retomberait sur la branche par défaut sans rien dire.
pub(crate) fn vocabulary_kind(kind: &str) -> Result<&'static str, String> {
    Nomenclature::from_key(kind)
        .map(Nomenclature::key)
        .or_else(|| radinus_core::statistics::Axis::from_key(kind).map(|axis| axis.key()))
        .ok_or_else(|| format!("Vocabulaire inconnu : « {kind} »"))
}

/// What went wrong at startup, if anything, so a window can say so instead of
/// looking empty and working. Returns `null` when the database opened
/// normally.
#[tauri::command]
pub fn startup_error(state: State<'_, AppState>) -> Option<String> {
    state.startup_error().map(str::to_string)
}

/// Everything a window has to say, in the language the database runs in.
///
/// Asked for once, as the window loads, before it draws anything: the
/// interface holds no sentence of its own (author's ruling, 25/07/2026).
/// `kind` may be absent for a window that belongs to no nomenclature.
#[tauri::command]
pub fn ui_texts(
    state: State<'_, AppState>,
    kind: Option<String>,
) -> Result<crate::texts::Dictionary, String> {
    let kind = match kind {
        Some(key) => Some(vocabulary_kind(&key)?),
        None => None,
    };
    // A database that would not open is not a reason to show nothing: the
    // window still has to be able to say *why* it is empty — et elle le dit
    // dans la langue de la configuration, qui est la seule à la connaître tant
    // qu'aucune base n'est ouverte.
    Ok(crate::texts::dictionary(window_language(&state), kind))
}

/// Le titre d'une fenêtre, reposé dans la langue courante.
///
/// **C'est la fenêtre qui le redemande, et non Rust qui le devine.** Un titre
/// n'est pas toujours une phrase toute faite : celui de la liste des
/// opérations porte le nom du compte, celui d'une statistique porte son axe.
/// Rust ne se souvient pas de ces valeurs — une fenêtre est bâtie une fois et
/// jamais détruite, et ce qu'elle montre a pu changer dix fois depuis. La
/// fenêtre, elle, les a sous la main : elle rend donc la clef et son argument,
/// et le noyau écrit la phrase.
///
/// Appelée par chaque fenêtre après qu'elle s'est rhabillée, à la fin du
/// changement de langue.
#[tauri::command]
pub fn retitle(
    window: tauri::Window,
    state: State<'_, AppState>,
    key: String,
    argument: Option<String>,
    argument_name: Option<String>,
) -> Result<(), String> {
    let language = window_language(&state);
    // Le **nom** de l'argument compte autant que sa valeur : « account » pour
    // la liste des opérations, « kind » pour les six statistiques et les sept
    // nomenclatures, qui sélectionnent dessus. Le donner par défaut mettrait
    // « par catégorie » sur les six fenêtres.
    let title = match argument {
        Some(value) => radinus_core::i18n::text_with(
            language,
            &key,
            argument_name.as_deref().unwrap_or("account"),
            &value,
        ),
        None => radinus_core::i18n::text(language, &key),
    };
    // Une clef inconnue rendrait un titre vide : mieux vaut garder celui qui
    // est en place que d'effacer le nom d'une fenêtre.
    if title.trim().is_empty() {
        return Ok(());
    }
    window.set_title(&title).map_err(|error| error.to_string())
}

/// La langue dans laquelle la base tourne — son numéro WinDev et son
/// étiquette. Une fenêtre s'en sert pour savoir dans quelle langue elle vient
/// de se rhabiller ; le sélecteur du premier lancement s'en servira pour
/// savoir quoi cocher.
#[tauri::command]
pub fn current_language(state: State<'_, AppState>) -> LanguageDto {
    let language = window_language(&state);
    LanguageDto {
        code: language.code(),
        tag: language.tag().to_string(),
        name: language.name(),
    }
}

/// Les langues que Radinus sait parler, dans l'ordre d'affichage, chacune
/// nommée dans sa propre langue.
#[tauri::command]
pub fn available_languages() -> Vec<LanguageDto> {
    Language::all()
        .into_iter()
        .map(|language| LanguageDto {
            code: language.code(),
            tag: language.tag().to_string(),
            name: language.name(),
        })
        .collect()
}

/// Change la langue du logiciel. Même chemin que l'entrée de menu — c'est la
/// même fonction, pour qu'il n'y ait qu'une façon de changer de langue.
#[tauri::command]
pub fn set_language(app: tauri::AppHandle, code: i64) -> Result<(), String> {
    crate::menu::switch_language(&app, code)
}

/// Une langue, telle qu'une fenêtre la reçoit.
#[derive(serde::Serialize)]
pub struct LanguageDto {
    /// Le numéro « nation » du WLangage — celui que la base stocke.
    pub code: i64,
    /// L'étiquette normalisée (`fr`, `en`, `es`).
    pub tag: String,
    /// Le nom de la langue, écrit dans cette langue.
    pub name: String,
}

// --- F08, menu « Outils » ------------------------------------------------
//
// Trois portages du WLangage de Fabrice (dossier « Information import export
// base piece jointe »), arbitrés avec lui le 02/08/2026. Le menu n'agit qu'en
// modification : à la création il n'y a rien à compter, en consultation la
// fiche ne fait que montrer.

/// Ce que la fiche pose sur la case du solde initial pointé, et sur sa ligne
/// bleue, après le calcul.
#[derive(serde::Serialize)]
pub struct InitialBalanceDto {
    /// Le montant tel qu'il s'écrit dans un champ de saisie — sans devise ni
    /// séparateur de milliers, comme tout champ monétaire de Radinus.
    pub amount: String,
    /// La ligne bleue refaite avec ce nouveau solde.
    pub control_line: String,
}

/// La question du calcul, avec le total des opérations pointées dedans.
///
/// Elle est rédigée par le noyau et non par la fenêtre : c'est une phrase, et
/// une phrase vit dans les fichiers de langue.
#[tauri::command]
pub fn account_initial_balance_question(
    state: State<'_, AppState>,
    account_id: i64,
) -> Result<String, String> {
    let conn = state.database()?;
    let language = ui_language();
    let total = radinus_core::accounts::pointed_total(&conn, account_id).map_err(to_ipc_error)?;
    Ok(radinus_core::i18n::text_with(
        language,
        "account-initial-balance-question",
        "total",
        &radinus_core::money::format(total, language),
    ))
}

/// Le calcul lui-même : `solde de la banque − total des opérations pointées`.
///
/// **Rien n'est écrit en base** (arbitrage de Fabrice, 02/08/2026, fidèle à
/// son code) : le résultat va dans la case de la fiche et dans sa ligne bleue,
/// et c'est l'enregistrement de la fiche qui écrit. Fermer par la porte annule
/// le calcul, et la fiche demandera d'abord s'il faut abandonner.
///
/// Le montant saisi passe par `money::parse`, qui refuse ce qui n'est pas un
/// montant plutôt que d'en faire zéro.
#[tauri::command]
pub fn account_initial_balance(
    state: State<'_, AppState>,
    account_id: i64,
    typed: String,
) -> Result<InitialBalanceDto, String> {
    let conn = state.database()?;
    let language = ui_language();
    // Le refus est celui de tous les champs monétaires du logiciel : ce qui
    // n'est pas un montant est refusé à voix haute, jamais transformé en zéro.
    let bank = radinus_core::money::parse(&typed).map_err(|_| {
        radinus_core::i18n::text_with(
            language,
            "amount-not-readable",
            "field",
            &radinus_core::i18n::text(language, "account-field-opening-pointed"),
        )
    })?;
    let total = radinus_core::accounts::pointed_total(&conn, account_id).map_err(to_ipc_error)?;

    let opening = bank - total;
    // La ligne bleue dit la même chose que partout ailleurs, avec le solde
    // que le calcul vient de poser : report + opérations = solde en banque.
    let control_line = radinus_core::i18n::message_of(
        language,
        "account-control-line",
        &[
            ("opening", &radinus_core::money::format(opening, language)),
            ("operations", &radinus_core::money::format(total, language)),
            (
                "balance",
                &radinus_core::money::format(total + opening, language),
            ),
        ],
        &[],
    );
    Ok(InitialBalanceDto {
        amount: radinus_core::money::format_plain(opening, language),
        control_line,
    })
}

/// Les statistiques du compte, en une phrase de quatorze lignes — celle de son
/// `Info()`. Un compte sans opération rend « Aucune transaction ».
#[tauri::command]
pub fn account_statistics(
    state: State<'_, AppState>,
    account_id: i64,
) -> Result<String, String> {
    let conn = state.database()?;
    let language = ui_language();
    let found = radinus_core::accounts::statistics(&conn, account_id).map_err(to_ipc_error)?;
    if found.operations == 0 {
        return Ok(radinus_core::i18n::text(language, "account-statistics-none"));
    }

    let money = |amount: i64| radinus_core::money::format(amount, language);
    let day = |date: Option<radinus_core::domain::NaiveDate>| match date {
        Some(date) => date.format("%d/%m/%Y").to_string(),
        // Toutes les opérations sans date : il n'y a pas de plus ancienne.
        None => "—".to_string(),
    };
    let difference = radinus_core::accounts::AccountStatistics::difference;

    Ok(radinus_core::i18n::message_of(
        language,
        "account-statistics",
        &[
            ("pointedDebits", &money(found.pointed_debits)),
            ("pointedCredits", &money(found.pointed_credits)),
            (
                "pointedDifference",
                &money(difference(found.pointed_credits, found.pointed_debits)),
            ),
            ("committedDebits", &money(found.committed_debits)),
            ("committedCredits", &money(found.committed_credits)),
            (
                "committedDifference",
                &money(difference(found.committed_credits, found.committed_debits)),
            ),
            ("plannedDebits", &money(found.planned_debits)),
            ("plannedCredits", &money(found.planned_credits)),
            (
                "plannedDifference",
                &money(difference(found.planned_credits, found.planned_debits)),
            ),
            ("first", &day(found.first)),
            ("last", &day(found.last)),
        ],
        &[
            ("count", found.operations),
            ("pointed", found.pointed),
            ("committed", found.committed),
            ("planned", found.planned),
        ],
    ))
}

/// La double barrière de la suppression : la question, et le mot à écrire.
#[derive(serde::Serialize)]
pub struct DeleteOperationsPromptDto {
    pub question: String,
    /// Le « oui » de la langue courante — OUI, YES, SÍ. Un hispanophone à qui
    /// l'on demanderait d'écrire OUI ne comprendrait pas (décision de Fabrice,
    /// 02/08/2026, écart assumé avec son original qui écrit OUI en dur).
    pub word: String,
}

#[tauri::command]
pub fn account_delete_operations_question(
    state: State<'_, AppState>,
) -> Result<DeleteOperationsPromptDto, String> {
    let _conn = state.database()?;
    let language = ui_language();
    let word = radinus_core::i18n::text(language, "ui-yes").to_uppercase();
    Ok(DeleteOperationsPromptDto {
        question: radinus_core::i18n::text_with(
            language,
            "account-delete-operations-question",
            "word",
            &word,
        ),
        word,
    })
}

/// Supprime toutes les transactions du compte et refait ses trois soldes.
///
/// **Elle n'attend pas la fiche** : si celle-ci porte des modifications non
/// enregistrées, elles restent à l'écran et les opérations partent quand même
/// — c'est ce que fait l'original, et Fabrice a tranché pour lui le
/// 02/08/2026.
#[tauri::command]
pub fn delete_account_operations<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    account_id: i64,
) -> Result<String, String> {
    let mut conn = state.database()?;
    let language = ui_language();
    let gone = radinus_core::accounts::delete_all_operations(&mut conn, account_id)
        .map_err(to_ipc_error)?;
    drop(conn);
    operations_changed(&app);
    Ok(radinus_core::i18n::message_of(
        language,
        "account-delete-operations-done",
        &[],
        &[("count", gone as i64)],
    ))
}

/// A sentence that counts something — how many elements were just deleted.
/// Kept out of the dictionary because it needs the number, and Fluent is what
/// knows whether that number changes the sentence.
#[tauri::command]
pub fn ui_deleted_text(
    state: State<'_, AppState>,
    kind: String,
    count: i64,
) -> Result<String, String> {
    let kind = nomenclature(&kind)?;
    let _conn = state.database()?;
    Ok(radinus_core::i18n::about_count(
        ui_language(),
        "nomenclature-deleted",
        kind.key(),
        count,
    ))
}

/// Every element of a nomenclature, in the order its list must show them.
#[tauri::command]
pub fn list_elements(state: State<'_, AppState>, kind: String) -> Result<Vec<ItemDto>, String> {
    let kind = nomenclature(&kind)?;
    let conn = state.database()?;
    Ok(nomenclatures::list(&conn, kind)
        .map_err(to_ipc_error)?
        .into_iter()
        .map(|item| ItemDto {
            id: item.id,
            label: item.label,
        })
        .collect())
}

/// The budget-line combo of the category fiche: « Non précisé » first, then
/// the lines in alphabetical order (02_BASE_DE_DONNEES.md §7 rules 2 and 6).
/// Only the category fiche ever asks for it.
#[tauri::command]
pub fn list_budget_lines(state: State<'_, AppState>) -> Result<Vec<ItemDto>, String> {
    let conn = state.database()?;
    let unspecified = radinus_core::i18n::unspecified_label(ui_language());
    let items = nomenclatures::list_for_combo(&conn, Nomenclature::BudgetLine, &unspecified)
        .map_err(to_ipc_error)?;
    Ok(items
        .into_iter()
        .map(|item| ItemDto {
            id: item.id,
            label: item.label,
        })
        .collect())
}

/// Reads one element by its key. A category comes with its budget line; the
/// other six have nothing beyond their label.
#[tauri::command]
pub fn get_element(
    state: State<'_, AppState>,
    kind: String,
    id: i64,
) -> Result<Option<ElementDto>, String> {
    let kind = nomenclature(&kind)?;
    let conn = state.database()?;

    if kind.has_budget_line() {
        return Ok(nomenclatures::get_category(&conn, id)
            .map_err(to_ipc_error)?
            .map(|category| ElementDto {
                id: category.id,
                label: category.label,
                budget_line_id: category.budget_line_id,
            }));
    }

    Ok(nomenclatures::get(&conn, kind, id)
        .map_err(to_ipc_error)?
        .map(|item| ElementDto {
            id: item.id,
            label: item.label,
            budget_line_id: nomenclatures::UNSPECIFIED,
        }))
}

/// Whether saving `label` would give this nomenclature two elements of the
/// same name, and the ready-made sentence saying so. `id` is the element
/// being modified, which is not a duplicate of itself; `null` when adding.
///
/// The fiche asks this before writing, and stops there if it gets an answer —
/// the same shape as `plan_deletion`, so a refusal is always the caller's to
/// show, never a failure thrown at it. Returns `null` when the name is free.
///
/// **All seven nomenclatures** (author's ruling, 25/07/2026, after validating
/// the rule on categories). Each refuses a name already taken *within itself*
/// and nowhere else: a category and a tiers may perfectly well both be called
/// « Carburant », they are not the same list.
#[tauri::command]
pub fn duplicate_name(
    state: State<'_, AppState>,
    kind: String,
    id: Option<i64>,
    label: String,
) -> Result<Option<String>, String> {
    let kind = nomenclature(&kind)?;
    let conn = state.database()?;
    Ok(
        nomenclatures::same_name_as(&conn, kind, &label, id)
            .map_err(to_ipc_error)?
            .map(|existing| {
                radinus_core::i18n::about_label(
                    ui_language(),
                    "nomenclature-duplicate-name",
                    kind.key(),
                    &existing,
                )
            }),
    )
}

/// Adds an element (`Enreg_Ajouter`): the key comes from the max+1 generator,
/// exactly as the original's `Genere_Clef`.
#[tauri::command]
pub fn create_element(
    state: State<'_, AppState>,
    kind: String,
    label: String,
    budget_line_id: i64,
) -> Result<i64, String> {
    let kind = nomenclature(&kind)?;
    let conn = state.database()?;
    if kind.has_budget_line() {
        return nomenclatures::create_category(&conn, &label, budget_line_id).map_err(to_ipc_error);
    }
    nomenclatures::create(&conn, kind, &label).map_err(to_ipc_error)
}

/// Changes an element (`Enreg_Modifier`). Returns `false` if it no longer
/// exists.
#[tauri::command]
pub fn update_element(
    state: State<'_, AppState>,
    kind: String,
    id: i64,
    label: String,
    budget_line_id: i64,
) -> Result<bool, String> {
    let kind = nomenclature(&kind)?;
    let conn = state.database()?;
    if kind.has_budget_line() {
        return nomenclatures::update_category(&conn, id, &label, budget_line_id)
            .map_err(to_ipc_error);
    }
    nomenclatures::update(&conn, kind, id, &label).map_err(to_ipc_error)
}

/// What deleting `ids` would entail. The user is asked **once for the whole
/// selection** (author's ruling, 25/07/2026), so the labels of the elements
/// concerned are gathered into that single question.
///
/// **A deletion is always confirmed** — Fabrice's decision of 25/07/2026, and
/// an assumed departure from his own code, which deletes an unused element
/// outright without a word. Which question is asked still depends on what is
/// at stake: when operations carry the element, it is his own wording,
/// warning that they are about to lose the attribute; otherwise it is the
/// plain "do you confirm".
#[tauri::command]
pub fn plan_deletion(
    state: State<'_, AppState>,
    kind: String,
    ids: Vec<i64>,
) -> Result<DeletionPlanDto, String> {
    let kind = nomenclature(&kind)?;
    let conn = state.database()?;

    let mut plan = DeletionPlanDto {
        refused: false,
        refusal: String::new(),
        needs_confirmation: false,
        question: String::new(),
        second_question: String::new(),
        confirmation_word: String::new(),
        operations: 0,
        operation_templates: 0,
        recurring_rules: 0,
    };

    // **Nothing is deleted from under its own open fiche** (author's ruling,
    // 25/07/2026). Deleting it and leaving the fiche on screen would show a
    // record that no longer exists, and saving it would fail for a reason the
    // user never asked for. The fiche is closed first — and the refusal names
    // the element, so it is clear which one is in the way.
    if let Some(open) = state.form_record(kind) {
        if ids.contains(&open) {
            if let Some(label) =
                nomenclatures::label_of(&conn, kind, open).map_err(to_ipc_error)?
            {
                plan.refused = true;
                plan.refusal =
                    radinus_core::i18n::nomenclature_delete_form_open(ui_language(), &label);
                return Ok(plan);
            }
        }
    }

    let mut labels = Vec::new();

    for id in ids {
        let usage = nomenclatures::usage(&conn, kind, id).map_err(to_ipc_error)?;
        plan.operations += usage.operations;
        plan.operation_templates += usage.operation_templates;
        plan.recurring_rules += usage.recurring_rules;

        if let Some(label) = nomenclatures::label_of(&conn, kind, id).map_err(to_ipc_error)? {
            labels.push(label);
        }
    }

    plan.needs_confirmation = !labels.is_empty();
    if plan.needs_confirmation {
        let labels = labels.join(", ");
        plan.question = if plan.operations > 0 {
            radinus_core::i18n::nomenclature_delete_confirmation(ui_language(), &labels)
        } else {
            radinus_core::i18n::nomenclature_delete_plain_confirmation(ui_language(), &labels)
        };
    }
    Ok(plan)
}

/// Deletes the selection, resetting every reference to « Non précisé » first
/// (`Enreg_Supprimer`). The caller has already asked the question, if there
/// was one to ask. Returns how many were actually deleted.
#[tauri::command]
pub fn delete_elements(
    state: State<'_, AppState>,
    kind: String,
    ids: Vec<i64>,
) -> Result<usize, String> {
    let kind = nomenclature(&kind)?;
    let mut conn = state.database()?;
    let mut deleted = 0;
    for id in ids {
        if nomenclatures::delete_and_reassign(&mut conn, kind, id).map_err(to_ipc_error)? {
            deleted += 1;
        }
    }
    Ok(deleted)
}

/// Opens the list of a nomenclature (F11).
#[tauri::command]
pub fn open_nomenclature_list<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    kind: String,
) -> Result<(), String> {
    let kind = nomenclature(&kind)?;
    let language = window_language(&state);
    crate::windows::open(&app, &crate::windows::list_window(kind, language), None)
        .map_err(to_ipc_error)
}

/// Opens the fiche of a nomenclature (F10). `mode` is the original's own
/// vocabulary: `"A"` add, `"M"` modify, `"L"` read-only consultation.
#[tauri::command]
pub fn open_element_form<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    kind: String,
    mode: String,
    id: Option<i64>,
) -> Result<(), String> {
    let kind = nomenclature(&kind)?;
    let query = match id {
        Some(id) => format!("mode={mode}&id={id}"),
        None => format!("mode={mode}"),
    };
    let language = window_language(&state);
    crate::windows::open(
        &app,
        &crate::windows::form_window(kind, language),
        Some(&query),
    )
    .map_err(to_ipc_error)
}

/// Tells a nomenclature's list that its data changed, so it reloads itself —
/// the equivalent of the original's `TableData_SyncFichier` after a fiche
/// closes. Emitted from Rust so the frontend needs no event-emitting
/// permission, and **addressed to that one list**, by an event named after
/// it: with seven lists sharing one page, a broadcast would have every
/// nomenclature reload on any change.
#[tauri::command]
pub fn notify_elements_changed<R: Runtime>(app: AppHandle<R>, kind: String) -> Result<(), String> {
    let kind = nomenclature(&kind)?;
    let list = crate::windows::list_window(kind, Language::French);
    app.emit_to(
        tauri::EventTarget::webview_window(&list.label),
        &crate::windows::changed_event(&list),
        (),
    )
    .map_err(to_ipc_error)?;

    // **Et toutes les autres fenêtres, qui tiennent ces mots dans leurs listes
    // déroulantes** (bug remonté par un utilisateur le 10/08/2026 : « il faut
    // fermer le programme pour qu'on puisse avoir ce nouveau libellé dans les
    // opérations »).
    //
    // Une fenêtre de Radinus est bâtie une fois et jamais détruite : elle
    // charge ses catégories, ses tiers et ses affectations à sa construction,
    // et les garde jusqu'au prochain démarrage. L'événement ci-dessus ne
    // s'adresse qu'à la liste de la nomenclature touchée — c'est voulu, sept
    // listes partagent une même page —, si bien que la fiche opération, la
    // classification rapide et les sept autres ne savaient rien.
    //
    // Celui-ci est diffusé à tout le monde et ne porte aucune cible : chaque
    // fenêtre qui tient de telles listes le reçoit et les relit. Le coût est
    // celui d'une relecture de nomenclature dans les fenêtres ouvertes, au
    // moment où l'utilisateur vient d'en modifier une.
    app.emit(NOMENCLATURES_CHANGED, kind.key())
        .map_err(to_ipc_error)
}

/// L'événement que toute fenêtre portant des listes déroulantes de
/// nomenclature doit écouter. Il porte la clef de la nomenclature touchée,
/// pour qui saurait n'en relire qu'une.
pub const NOMENCLATURES_CHANGED: &str = "nomenclatures-changed";

/// Whether leaving this list would take unsaved work down with it — the fiche
/// being its child, closing the list closes the fiche too.
///
/// The list asks this before its door does anything, and puts the question to
/// the user itself. An earlier version sent the fiche an event and waited for
/// it to answer; the event sometimes arrived before the fiche was listening,
/// and the question was then never asked at all.
#[tauri::command]
pub fn list_has_unsaved_changes(state: State<'_, AppState>, kind: String) -> Result<bool, String> {
    Ok(state.form_is_dirty(nomenclature(&kind)?))
}

/// Called by a fiche whenever what it holds becomes different from what is
/// stored — or becomes identical again.
#[tauri::command]
pub fn set_form_dirty(
    state: State<'_, AppState>,
    kind: String,
    dirty: bool,
) -> Result<(), String> {
    state.set_form_dirty(nomenclature(&kind)?, dirty)
}

/// Called by a fiche to say which element it is showing, and `null` when it
/// shows none — it has been left, emptied, or is adding a record that does
/// not exist yet. A list refuses to delete an element whose fiche is open.
#[tauri::command]
pub fn set_form_record(
    state: State<'_, AppState>,
    kind: String,
    id: Option<i64>,
) -> Result<(), String> {
    state.set_form_record(nomenclature(&kind)?, id)
}

/// Leaves a nomenclature's list, taking its fiche with it. Both windows go
/// away together — hidden, not destroyed (see `windows::open`). The caller
/// has already asked the question, if there was one to ask.
///
/// **The fiche is emptied before it is hidden.** A hidden window keeps
/// everything it held, fields and reserve alike; the work the user has just
/// agreed to abandon would otherwise be sitting there the next time the fiche
/// is opened, and would have it ask its question again about something given
/// up on long before (Fabrice, 25/07/2026). Emptied, the fiche has nothing
/// left to resurrect, and the declared state is cleared with it.
#[tauri::command]
pub fn list_may_close<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    kind: String,
) -> Result<(), String> {
    let kind = nomenclature(&kind)?;
    // Only the labels are used here, and a label is not translated.
    let form = crate::windows::form_window(kind, Language::French);
    let list = crate::windows::list_window(kind, Language::French);

    if let Some(window) = app.get_webview_window(&form.label) {
        window
            .emit_to(
                tauri::EventTarget::webview_window(&form.label),
                &crate::windows::reset_event(&form),
                (),
            )
            .map_err(to_ipc_error)?;
        window.hide().map_err(to_ipc_error)?;
    }
    if let Some(window) = app.get_webview_window(&list.label) {
        window.hide().map_err(to_ipc_error)?;
    }
    state.set_form_record(kind, None)?;
    state.set_form_dirty(kind, false)
}

// --- Bank accounts (Phase 4) --------------------------------------------

/// One row of the accounts list. The three balances travel both as numbers,
/// so the table can sort on them, and as text, because formatting an amount
/// is the core's business and not the window's.
#[derive(Serialize)]
pub struct AccountRowDto {
    pub id: i64,
    pub label: String,
    pub bank: String,
    pub account_type: String,
    pub account_number: String,
    pub balance_bank: i64,
    pub balance_real: i64,
    pub balance_final: i64,
    pub balance_bank_text: String,
    pub balance_real_text: String,
    pub balance_final_text: String,
    pub is_closed: bool,
}

/// An account as the fiche shows it. Amounts and dates come already written
/// in the language of the interface; they go back as text too, and the core
/// reads them.
#[derive(Serialize)]
pub struct AccountDto {
    pub id: i64,
    pub label: String,
    pub bank_id: i64,
    pub account_type_id: i64,
    pub branch_address: String,
    pub holder_name: String,
    pub holder_address: String,
    pub rib_bank_code: String,
    pub rib_branch_code: String,
    pub rib_account_number: String,
    pub rib_key: String,
    pub bic: String,
    pub iban: String,
    pub opening_date: String,
    pub closing_date: String,
    pub is_closed: bool,
    pub opening_pointed: String,
    pub opening_committed: String,
    pub opening_planned: String,
    /// The blue line at the bottom of the fiche, already worded.
    pub control_line: String,
}

/// What the fiche sends back. Everything is text: it is what the fields hold.
#[derive(serde::Deserialize)]
pub struct AccountInput {
    pub label: String,
    pub bank_id: i64,
    pub account_type_id: i64,
    pub branch_address: String,
    pub holder_name: String,
    pub holder_address: String,
    pub rib_bank_code: String,
    pub rib_branch_code: String,
    pub rib_account_number: String,
    pub rib_key: String,
    pub bic: String,
    pub iban: String,
    pub opening_date: String,
    pub closing_date: String,
    pub is_closed: bool,
    pub opening_pointed: String,
    pub opening_committed: String,
    pub opening_planned: String,
}

fn a_date(text: &str) -> Option<radinus_core::domain::NaiveDate> {
    radinus_core::domain::NaiveDate::parse_from_str(text.trim(), "%Y-%m-%d").ok()
}

/// The three balances of the fiche, read strictly.
///
/// **Never `unwrap_or(0)`.** An amount that cannot be read used to become
/// zero here, silently, which in a program that handles money falsifies every
/// balance of the account's life (Fabrice, 25/07/2026). An unreadable amount
/// now stops the write, and `account_refusal` says which field is at fault
/// before it ever gets this far.
fn opening_balances(input: &AccountInput) -> Result<(i64, i64, i64), String> {
    let read = |text: &str, key: &str| -> Result<i64, String> {
        radinus_core::money::parse_or_zero(text).map_err(|_| key.to_string())
    };
    Ok((
        read(&input.opening_pointed, "account-field-opening-pointed")?,
        read(&input.opening_committed, "account-field-opening-committed")?,
        read(&input.opening_planned, "account-field-opening-planned")?,
    ))
}

fn as_account(
    input: &AccountInput,
) -> Result<radinus_core::domain::Account, String> {
    let (pointed, committed, planned) = opening_balances(input)?;
    Ok(radinus_core::domain::Account {
        id: 0,
        label: input.label.clone(),
        account_type_id: input.account_type_id,
        bank_id: input.bank_id,
        opening_balance_pointed: pointed,
        opening_balance_committed: committed,
        opening_balance_planned: planned,
        balance_bank: 0,
        balance_real: 0,
        balance_final: 0,
        holder_name: input.holder_name.clone(),
        holder_address: input.holder_address.clone(),
        rib_bank_code: input.rib_bank_code.clone(),
        rib_branch_code: input.rib_branch_code.clone(),
        rib_account_number: input.rib_account_number.clone(),
        rib_key: input.rib_key.clone(),
        iban: input.iban.clone(),
        bic: input.bic.clone(),
        branch_address: input.branch_address.clone(),
        opening_date: a_date(&input.opening_date),
        closing_date: a_date(&input.closing_date),
        next_check_number: 0,
        is_closed: input.is_closed,
        currency: "EUR".to_string(),
    })
}

/// Every account, in the order the lists show them.
#[tauri::command]
pub fn list_accounts(state: State<'_, AppState>) -> Result<Vec<AccountRowDto>, String> {
    let conn = state.database()?;
    let language = ui_language();
    Ok(radinus_core::accounts::list(&conn)
        .map_err(to_ipc_error)?
        .into_iter()
        .map(|row| AccountRowDto {
            balance_bank_text: radinus_core::money::format(row.balance_bank, language),
            balance_real_text: radinus_core::money::format(row.balance_real, language),
            balance_final_text: radinus_core::money::format(row.balance_final, language),
            id: row.id,
            label: row.label,
            bank: row.bank,
            account_type: row.account_type,
            account_number: row.account_number,
            balance_bank: row.balance_bank,
            balance_real: row.balance_real,
            balance_final: row.balance_final,
            is_closed: row.is_closed,
        })
        .collect())
}

/// The TOTAL line of F07 — the three columns added up. Closed accounts are
/// left out of it, as they are left out of the window.
#[tauri::command]
pub fn accounts_total(state: State<'_, AppState>) -> Result<AccountRowDto, String> {
    let conn = state.database()?;
    let language = ui_language();
    let rows = radinus_core::accounts::list(&conn).map_err(to_ipc_error)?;
    let open = rows.iter().filter(|row| !row.is_closed);
    let bank: i64 = open.clone().map(|row| row.balance_bank).sum();
    let real: i64 = open.clone().map(|row| row.balance_real).sum();
    let final_: i64 = open.map(|row| row.balance_final).sum();
    Ok(AccountRowDto {
        id: 0,
        label: radinus_core::i18n::text(language, "accounts-total"),
        bank: String::new(),
        account_type: String::new(),
        account_number: String::new(),
        balance_bank: bank,
        balance_real: real,
        balance_final: final_,
        balance_bank_text: radinus_core::money::format(bank, language),
        balance_real_text: radinus_core::money::format(real, language),
        balance_final_text: radinus_core::money::format(final_, language),
        is_closed: false,
    })
}

/// The banks combo of the fiche: « Non précisé » first, then the banks.
#[tauri::command]
pub fn list_banks(state: State<'_, AppState>) -> Result<Vec<ItemDto>, String> {
    let conn = state.database()?;
    let unspecified = radinus_core::i18n::unspecified_label(ui_language());
    Ok(
        nomenclatures::list_for_combo(&conn, Nomenclature::Bank, &unspecified)
            .map_err(to_ipc_error)?
            .into_iter()
            .map(|item| ItemDto {
                id: item.id,
                label: item.label,
            })
            .collect(),
    )
}

/// The account types. A closed list, prefilled by the code
/// (02_BASE_DE_DONNEES.md §3.1): read as it is, never added to.
#[tauri::command]
pub fn list_account_types(state: State<'_, AppState>) -> Result<Vec<ItemDto>, String> {
    let conn = state.database()?;
    Ok(radinus_core::accounts::account_types(&conn)
        .map_err(to_ipc_error)?
        .into_iter()
        .map(|item| ItemDto {
            id: item.id,
            label: item.label,
        })
        .collect())
}

#[tauri::command]
pub fn get_account(state: State<'_, AppState>, id: i64) -> Result<Option<AccountDto>, String> {
    let conn = state.database()?;
    let language = ui_language();
    let Some(account) = radinus_core::accounts::get(&conn, id).map_err(to_ipc_error)? else {
        return Ok(None);
    };

    // The blue line: what was carried over, what the operations did to it,
    // and where the account stands now.
    let operations = account.balance_bank - account.opening_balance_pointed;
    let control_line = radinus_core::i18n::message_of(
        language,
        "account-control-line",
        &[
            (
                "opening",
                &radinus_core::money::format(account.opening_balance_pointed, language),
            ),
            (
                "operations",
                &radinus_core::money::format(operations, language),
            ),
            (
                "balance",
                &radinus_core::money::format(account.balance_bank, language),
            ),
        ],
        &[],
    );

    let date = |value: Option<radinus_core::domain::NaiveDate>| {
        value
            .map(|d| d.format("%Y-%m-%d").to_string())
            .unwrap_or_default()
    };

    Ok(Some(AccountDto {
        id: account.id,
        label: account.label,
        bank_id: account.bank_id,
        account_type_id: account.account_type_id,
        branch_address: account.branch_address,
        holder_name: account.holder_name,
        holder_address: account.holder_address,
        rib_bank_code: account.rib_bank_code,
        rib_branch_code: account.rib_branch_code,
        rib_account_number: account.rib_account_number,
        rib_key: account.rib_key,
        bic: account.bic,
        iban: radinus_core::accounts::formatted_iban(&account.iban),
        opening_date: date(account.opening_date),
        closing_date: date(account.closing_date),
        is_closed: account.is_closed,
        opening_pointed: radinus_core::money::format_plain(
            account.opening_balance_pointed,
            language,
        ),
        opening_committed: radinus_core::money::format_plain(
            account.opening_balance_committed,
            language,
        ),
        opening_planned: radinus_core::money::format_plain(
            account.opening_balance_planned,
            language,
        ),
        control_line,
    }))
}

/// What would stop this account being saved, already worded — `null` when
/// nothing does. The fiche asks before writing, exactly as it does for a
/// nomenclature: a refusal is the window's to show, never a failure thrown at
/// it.
#[tauri::command]
pub fn account_refusal(
    state: State<'_, AppState>,
    id: Option<i64>,
    label: String,
    iban: String,
    amounts: (String, String, String),
) -> Result<Option<String>, String> {
    let conn = state.database()?;
    let language = ui_language();

    if label.trim().is_empty() {
        return Ok(Some(radinus_core::i18n::text(
            language,
            "account-label-required",
        )));
    }
    for (text, key) in [
        (&amounts.0, "account-field-opening-pointed"),
        (&amounts.1, "account-field-opening-committed"),
        (&amounts.2, "account-field-opening-planned"),
    ] {
        if radinus_core::money::parse_or_zero(text).is_err() {
            return Ok(Some(unreadable_amount(key)));
        }
    }
    if !radinus_core::accounts::iban_is_valid(&iban) {
        return Ok(Some(radinus_core::i18n::text(
            language,
            "account-iban-invalid",
        )));
    }
    if let Some(existing) =
        radinus_core::accounts::same_name_as(&conn, &label, id).map_err(to_ipc_error)?
    {
        return Ok(Some(radinus_core::i18n::text_with(
            language,
            "accounts-duplicate-name",
            "label",
            &existing,
        )));
    }
    Ok(None)
}

#[tauri::command]
pub fn create_account<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    account: AccountInput,
) -> Result<i64, String> {
    let conn = state.database()?;
    let record = as_account(&account).map_err(|key| unreadable_amount(&key))?;
    let created = radinus_core::accounts::create(&conn, &record).map_err(to_ipc_error)?;
    // **Le premier compte allume la moitié du logiciel** : la barre de menus
    // était grise faute de compte, et elle ne se refait pas toute seule. Le
    // verrou est rendu avant, elle va relire la base.
    drop(conn);
    crate::menu::refresh(&app);
    Ok(created)
}

/// Le refus affiché quand un champ censé porter un montant n'en porte pas.
///
/// **Elle ne prend plus la connexion** (03/08/2026) : elle ne la prenait que
/// pour aller y chercher la langue, et la langue ne vient plus de la base.
/// Le paramètre est retiré plutôt que masqué en `_conn` — un paramètre qui ne
/// sert plus est une question posée à tous ceux qui liront cette fonction.
fn unreadable_amount(field_key: &str) -> String {
    let language = ui_language();
    radinus_core::i18n::text_with(
        language,
        "amount-not-readable",
        "field",
        &radinus_core::i18n::text(language, field_key),
    )
}

#[tauri::command]
pub fn update_account(
    state: State<'_, AppState>,
    id: i64,
    account: AccountInput,
) -> Result<bool, String> {
    let conn = state.database()?;
    let record = as_account(&account).map_err(|key| unreadable_amount(&key))?;
    radinus_core::accounts::update(&conn, id, &record).map_err(to_ipc_error)
}

/// What deleting the selected accounts would entail. **An account takes its
/// operations with it** — the only deletion in Radinus that destroys history,
/// so the question says how many are about to go.
#[tauri::command]
pub fn plan_account_deletion(
    state: State<'_, AppState>,
    ids: Vec<i64>,
) -> Result<DeletionPlanDto, String> {
    let conn = state.database()?;
    let language = ui_language();

    let mut plan = DeletionPlanDto {
        refused: false,
        refusal: String::new(),
        needs_confirmation: false,
        question: String::new(),
        second_question: String::new(),
        confirmation_word: String::new(),
        operations: 0,
        operation_templates: 0,
        recurring_rules: 0,
    };

    let mut labels = Vec::new();
    for id in &ids {
        let Some(account) = radinus_core::accounts::get(&conn, *id).map_err(to_ipc_error)? else {
            continue;
        };
        // Nothing is deleted from under its own open fiche.
        if state.account_form_record() == Some(*id) {
            plan.refused = true;
            plan.refusal = radinus_core::i18n::text_with(
                language,
                "accounts-delete-form-open",
                "label",
                &account.label,
            );
            return Ok(plan);
        }
        plan.operations +=
            radinus_core::accounts::operation_count(&conn, *id).map_err(to_ipc_error)?;
        labels.push(account.label);
    }

    plan.needs_confirmation = !labels.is_empty();
    if plan.needs_confirmation {
        // **La seconde barrière** (décision de Fabrice, 26/07/2026) : le mot à
        // écrire, et la phrase qui le demande. Supprimer un compte emporte tout
        // son historique — c'est la seule suppression de Radinus qui détruise
        // des données qu'aucune autre fenêtre ne peut redonner — et un Oui/Non
        // se clique sans lire. Le mot est celui du dictionnaire, donc « Oui »
        // en français et « Yes » en anglais : rien ici n'a à le savoir.
        plan.confirmation_word = radinus_core::i18n::text(language, "ui-yes");
        plan.second_question = radinus_core::i18n::text_with(
            language,
            "accounts-delete-second-question",
            "word",
            &plan.confirmation_word,
        );
        let labels = labels.join(", ");
        plan.question = if plan.operations > 0 {
            radinus_core::i18n::message_of(
                language,
                "accounts-delete-with-operations",
                &[("label", &labels)],
                &[("count", plan.operations)],
            )
        } else {
            radinus_core::i18n::text_with(language, "accounts-delete-plain", "label", &labels)
        };
    }
    Ok(plan)
}

#[tauri::command]
pub fn delete_accounts<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    ids: Vec<i64>,
) -> Result<usize, String> {
    let mut conn = state.database()?;
    let mut deleted = 0;
    for id in ids {
        if radinus_core::accounts::delete(&mut conn, id).map_err(to_ipc_error)? {
            deleted += 1;
        }
    }
    // Le dernier compte effacé rééteint ce que le premier avait allumé.
    drop(conn);
    crate::menu::refresh(&app);
    Ok(deleted)
}

/// The sentence that counts deleted accounts.
#[tauri::command]
pub fn accounts_deleted_text(state: State<'_, AppState>, count: i64) -> Result<String, String> {
    let _conn = state.database()?;
    Ok(radinus_core::i18n::message_of(
        ui_language(),
        "accounts-deleted",
        &[],
        &[("count", count)],
    ))
}

/// Ouvre la liste des comptes dans l'un de ses trois usages : gérer, choisir
/// un compte, choisir plusieurs comptes pour une statistique.
#[tauri::command]
pub fn open_accounts_list<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    purpose: Option<String>,
) -> Result<(), String> {
    let language = window_language(&state);
    let purpose = crate::windows::AccountsPurpose::from_key(purpose.as_deref().unwrap_or("CRUD"));
    crate::windows::open(
        &app,
        &crate::windows::accounts_list_window(language, purpose),
        None,
    )
    .map_err(to_ipc_error)
}

/// Opens the fiche compte (F08). `mode` is the original's own vocabulary.
#[tauri::command]
pub fn open_account_form<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    mode: String,
    id: Option<i64>,
) -> Result<(), String> {
    let query = match id {
        Some(id) => format!("mode={mode}&id={id}"),
        None => format!("mode={mode}"),
    };
    let language = window_language(&state);
    crate::windows::open(
        &app,
        &crate::windows::account_form_window(language),
        Some(&query),
    )
    .map_err(to_ipc_error)
}

/// Opens « Soldes de vos comptes » (F07).
#[tauri::command]
pub fn open_balances_window<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
) -> Result<(), String> {
    let language = window_language(&state);
    crate::windows::open(&app, &crate::windows::balances_window(language), None)
        .map_err(to_ipc_error)
}

/// Tells the accounts list its data changed.
#[tauri::command]
pub fn notify_accounts_changed<R: Runtime>(app: AppHandle<R>) -> Result<(), String> {
    let list = crate::windows::accounts_list_window(
        Language::French,
        crate::windows::AccountsPurpose::Manage,
    );
    app.emit_to(
        tauri::EventTarget::webview_window(&list.label),
        &crate::windows::changed_event(&list),
        (),
    )
    .map_err(to_ipc_error)
}

#[tauri::command]
pub fn set_account_form_dirty(state: State<'_, AppState>, dirty: bool) -> Result<(), String> {
    state.set_account_form_dirty(dirty)
}

#[tauri::command]
pub fn set_account_form_record(state: State<'_, AppState>, id: Option<i64>) -> Result<(), String> {
    state.set_account_form_record(id)
}

#[tauri::command]
pub fn accounts_list_has_unsaved_changes(state: State<'_, AppState>) -> bool {
    state.account_form_is_dirty()
}

/// Leaves the accounts list, taking its fiche with it — emptied first, so
/// nothing it held comes back to life on the next visit.
///
/// **`selecting` says which of the two windows is leaving.** The management
/// list (F04) and the chooser (F06) share one page but are two windows with
/// two labels; without being told, this hid the management list whatever the
/// caller was — so the chooser stayed on screen with a door that did nothing,
/// and no way out at all (reported by Fabrice, 26/07/2026).
///
/// The chooser has no fiche of its own: nothing is created or modified from
/// it, so there is nothing to empty and no unsaved work to guard.
#[tauri::command]
pub fn accounts_list_may_close<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    purpose: Option<String>,
) -> Result<(), String> {
    let purpose = crate::windows::AccountsPurpose::from_key(purpose.as_deref().unwrap_or("CRUD"));
    let list = crate::windows::accounts_list_window(Language::French, purpose);

    if purpose == crate::windows::AccountsPurpose::Manage {
        let form = crate::windows::account_form_window(Language::French);
        if let Some(window) = app.get_webview_window(&form.label) {
            window
                .emit_to(
                    tauri::EventTarget::webview_window(&form.label),
                    &crate::windows::reset_event(&form),
                    (),
                )
                .map_err(to_ipc_error)?;
            window.hide().map_err(to_ipc_error)?;
        }
    }
    if let Some(window) = app.get_webview_window(&list.label) {
        window.hide().map_err(to_ipc_error)?;
    }
    state.set_account_form_record(None)?;
    state.set_account_form_dirty(false)
}

// --- Operations of an account (Phase 5.1) -------------------------------

/// One line of F02, parent or child alike, already written for the screen.
#[derive(Serialize)]
pub struct OperationRowDto {
    pub id: i64,
    pub label: String,
    pub date: String,
    pub clearing_date: String,
    /// **Les deux dates en ISO, pour le tri, et rien d'autre.**
    ///
    /// La colonne montre « 15/01/2026 » et le tableau triait sur ce texte : il
    /// classait donc par quantième, puis par mois, puis par année — un tri
    /// alphabétique sur ce qui ressemblait à des dates (relevé par Fabrice le
    /// 04/08/2026). En ISO, l'ordre des caractères EST l'ordre du temps.
    ///
    /// **Deux champs pour une donnée, comme pour l'argent** : la colonne Débit
    /// montre « 1 549,81 € » et se trie sur `amount`. Un texte pour lire, une
    /// valeur pour ranger — c'est la même règle, et c'était déjà celle des
    /// listes de chèques.
    pub date_value: String,
    pub clearing_date_value: String,
    /// **L'opération est-elle pointée ?** — pour que la liste sache griser une
    /// date de pointage qui n'en est pas une (Fabrice, 21/08/2026).
    ///
    /// Un booléen, et non le numéro du statut : la vue ne compare pas des
    /// identifiants de la base, elle affiche ce que le contrôleur a décidé.
    pub is_pointed: bool,
    /// **Le statut lui-même**, pour la colonne « Statut opération » : la
    /// valeur de sa liste déroulante, et sa clef de tri — 1, 2, 3, l'ordre
    /// logique pointé, engagé, prévu, et non l'ordre alphabétique des mots.
    pub status_id: i64,
    /// **La vérification** — 1 à vérifier, 2 vérifiée, 3 douteuse, 4 contestée
    /// (Fabrice, 03/10/2026). La valeur de sa liste déroulante, sa clef de tri,
    /// et ce qui décide de sa couleur.
    pub verification_id: i64,
    pub month: String,
    pub category: String,
    pub assignment: String,
    pub payment_mode: String,
    pub payee: String,
    pub project: String,
    pub debit: String,
    pub credit: String,
    pub balance: String,
    /// Le solde courant en micro-unités, pour le tri de sa colonne. `0` sur une
    /// ligne fille, qui n'en porte pas.
    pub balance_value: i64,
    pub amount: i64,
    pub has_comment: bool,
    /// The comment itself, so the column can show it on hover.
    pub comment: String,
    pub has_attachment: bool,
    pub check_number: String,
    /// What the five combos of the list are set on.
    pub category_id: i64,
    pub assignment_id: i64,
    pub payment_mode_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
    /// `0` for a top-level operation, its mother's key for a child.
    pub parent_id: i64,
    pub child_count: usize,
    pub is_complement: bool,
}

/// Everything F02 needs in one call: the tree, the foot of the window and the
/// name of the account it is about.
#[derive(Serialize)]
pub struct OperationsDto {
    pub account_label: String,
    pub rows: Vec<OperationRowDto>,
    pub debit: String,
    pub credit: String,
    pub total: String,
    pub balance_bank: String,
    pub balance_real: String,
    pub balance_final: String,
}

/// The months, in the language of the interface. The column shows the month
/// of the operation's date in full letters, deduced and never stored.
/// Les douze noms de mois d'une langue, **demandés une fois** et rangés dans
/// l'ordre du calendrier : janvier à l'indice 0, décembre à l'indice 11.
///
/// Une liste d'opérations écrit le nom du mois sur chacune de ses lignes, et
/// elle peut en avoir deux mille quatre cents : les demander ligne par ligne,
/// c'est réclamer douze mots différents deux mille quatre cents fois. Le coût
/// de la colonne ne dépend plus du nombre de lignes affichées.
fn month_names(language: Language) -> [String; 12] {
    std::array::from_fn(|index| month_name(language, index as u32 + 1))
}

fn month_name(language: Language, month: u32) -> String {
    radinus_core::i18n::text(
        language,
        match month {
            1 => "month-january",
            2 => "month-february",
            3 => "month-march",
            4 => "month-april",
            5 => "month-may",
            6 => "month-june",
            7 => "month-july",
            8 => "month-august",
            9 => "month-september",
            10 => "month-october",
            11 => "month-november",
            _ => "month-december",
        },
    )
}

fn as_row(
    row: &radinus_core::operations::OperationRow,
    parent_id: i64,
    child_count: usize,
    language: Language,
    months: &[String; 12],
) -> OperationRowDto {
    let date = |value: Option<radinus_core::domain::NaiveDate>| {
        value
            .map(|d| d.format("%d/%m/%Y").to_string())
            .unwrap_or_default()
    };
    // La même date, en ISO : c'est celle sur laquelle la colonne se trie.
    // **Une date sans jour reste une chaîne vide** et se range donc en tête,
    // exactement là où le noyau la met déjà dans son propre ordre.
    let sortable = |value: Option<radinus_core::domain::NaiveDate>| {
        value.map(|d| d.to_string()).unwrap_or_default()
    };
    OperationRowDto {
        id: row.id,
        label: row.label.clone(),
        date: date(row.date),
        clearing_date: date(row.clearing_date),
        date_value: sortable(row.date),
        clearing_date_value: sortable(row.clearing_date),
        is_pointed: row.status_id == POINTED_STATUS,
        status_id: row.status_id,
        verification_id: row.verification_id,
        month: row
            .date
            .map(|d| months[time_compute::Datelike::month(&d) as usize - 1].clone())
            .unwrap_or_default(),
        category: row.category.clone(),
        assignment: row.assignment.clone(),
        payment_mode: row.payment_mode.clone(),
        payee: row.payee.clone(),
        project: row.project.clone(),
        // A debit and a credit never share a column: the original puts them
        // side by side, and the sign is what decides which one is written.
        debit: if row.amount < 0 {
            radinus_core::money::format(row.amount, language)
        } else {
            String::new()
        },
        credit: if row.amount > 0 {
            radinus_core::money::format(row.amount, language)
        } else {
            String::new()
        },
        // A child carries no balance: the running balance is the account's,
        // and a ventilation does not move the account.
        //
        // **Une ligne non pointée n'en porte pas non plus** (Fabrice,
        // 25/08/2026 : « plutôt que de mettre zéro il serait plus pertinent de
        // laisser à blanc la case »).
        //
        // La colonne est le solde **en banque**. Il n'avance que sur les
        // opérations pointées, mais il était recopié sur toutes les lignes, à
        // la valeur qu'il avait au moment où le parcours les rencontrait. Or
        // ce parcours suit la date de pointage, et une date vide passe en
        // tête : depuis que les échéances à venir n'en portent plus, elles
        // étaient rencontrées les premières et recevaient le report initial du
        // compte — souvent 0,00 €. Un utilisateur descendant sa liste voyait sa
        // progression, puis une colonne à zéro sur tout l'avenir, et pouvait la
        // lire comme « mon compte sera vide ».
        //
        // La case vide dit la seule chose vraie : la banque n'a rien passé,
        // donc il n'y a pas de solde en banque à montrer. C'est déjà le
        // langage des sous-opérations, une ligne plus haut.
        //
        // Rien n'est touché au calcul ni à ce qui est en base : le solde du
        // compte, les totaux du bas de la fenêtre et la courbe restent ce
        // qu'ils étaient.
        balance: if parent_id == 0 && row.status_id == POINTED_STATUS {
            radinus_core::money::format(row.pointed_balance, language)
        } else {
            String::new()
        },
        balance_value: if parent_id == 0 && row.status_id == POINTED_STATUS {
            row.pointed_balance
        } else {
            0
        },
        amount: row.amount,
        has_comment: row.has_comment(),
        comment: row.comment.clone(),
        has_attachment: row.has_attachment,
        check_number: row.check_number.clone(),
        category_id: row.category_id,
        assignment_id: row.assignment_id,
        payment_mode_id: row.payment_mode_id,
        payee_id: row.payee_id,
        project_id: row.project_id,
        parent_id,
        child_count,
        is_complement: row.is_complement,
    }
}

/// The operations of an account between two dates, as F02 shows them: the
/// mothers in order, each followed by her children, and the foot of the
/// window.
///
/// The children travel with the mothers rather than being fetched when one is
/// unfolded: they are already read, and a round trip per « + » would make the
/// window feel slow for nothing.
#[tauri::command]
pub fn list_operations(
    state: State<'_, AppState>,
    account_id: i64,
    from: String,
    to: String,
    status: Option<i64>,
    verification: Option<i64>,
) -> Result<OperationsDto, String> {
    let conn = state.database()?;
    let language = ui_language();

    let bounds = |text: &str| -> Result<radinus_core::domain::NaiveDate, String> {
        a_date(text).ok_or_else(|| radinus_core::i18n::text(language, "operations-bad-period"))
    };
    // `status` is the Filtre menu: 1 pointed, 2 committed, 3 planned, and
    // nothing at all for « toutes les opérations ». The totals are worked out
    // on what the filter kept, so the foot of the window always adds up what
    // the table shows.
    let trees = radinus_core::operations::list_for_account(
        &conn,
        account_id,
        bounds(&from)?,
        bounds(&to)?,
        status,
        // Le second filtre du menu : 1 à 4, ou rien pour « toutes ». Il
        // s'additionne au premier, et les totaux portent sur ce qui reste.
        verification,
    )
    .map_err(to_ipc_error)?;

    let totals = radinus_core::operations::totals(&trees);
    let account = radinus_core::accounts::get(&conn, account_id).map_err(to_ipc_error)?;

    let months = month_names(language);
    let mut rows = Vec::new();
    for tree in &trees {
        rows.push(as_row(&tree.parent, 0, tree.children.len(), language, &months));
        for child in &tree.children {
            rows.push(as_row(child, tree.parent.id, 0, language, &months));
        }
    }

    let money = |amount: i64| radinus_core::money::format(amount, language);
    Ok(OperationsDto {
        account_label: account.as_ref().map(|a| a.label.clone()).unwrap_or_default(),
        rows,
        debit: money(totals.debit),
        credit: money(totals.credit),
        total: money(totals.total),
        balance_bank: money(account.as_ref().map(|a| a.balance_bank).unwrap_or(0)),
        balance_real: money(account.as_ref().map(|a| a.balance_real).unwrap_or(0)),
        balance_final: money(account.map(|a| a.balance_final).unwrap_or(0)),
    })
}

/// What deleting the selected operations would entail. **A mother takes her
/// daughters** (author's ruling, 25/07/2026), so the question says how many
/// lines go in all, the unselected children included.
#[tauri::command]
pub fn plan_operations_deletion(
    state: State<'_, AppState>,
    ids: Vec<i64>,
) -> Result<DeletionPlanDto, String> {
    let conn = state.database()?;
    let language = ui_language();

    // Nothing is deleted from under its own open fiche (author's ruling,
    // 25/07/2026). Here it matters twice over: a mother takes her daughters,
    // so the fiche could be showing a line nobody selected.
    let held = state.operation_form_record();
    let mut going: std::collections::HashSet<i64> = ids.iter().copied().collect();
    for id in &ids {
        let children: Vec<i64> = conn
            .prepare("SELECT IDOperation FROM Operation WHERE IDOperationParent = ?1")
            .map_err(to_ipc_error)?
            .query_map([id], |row| row.get(0))
            .map_err(to_ipc_error)?
            .collect::<Result<_, _>>()
            .map_err(to_ipc_error)?;
        going.extend(children);
    }

    if let Some(held) = held.filter(|held| going.contains(held)) {
        let label = radinus_core::operations::get(&conn, held)
            .map_err(to_ipc_error)?
            .map(|operation| operation.label)
            .unwrap_or_default();
        return Ok(DeletionPlanDto {
            refused: true,
            refusal: radinus_core::i18n::text_with(
                language,
                "operation-delete-form-open",
                "label",
                &label,
            ),
            needs_confirmation: false,
            question: String::new(),
            second_question: String::new(),
            confirmation_word: String::new(),
            operations: 0,
            operation_templates: 0,
            recurring_rules: 0,
        });
    }

    Ok(DeletionPlanDto {
        refused: false,
        refusal: String::new(),
        needs_confirmation: !going.is_empty(),
        question: radinus_core::i18n::message_of(
            language,
            "operations-delete-confirm",
            &[],
            &[("count", going.len() as i64)],
        ),
        // Une opération se resaisit ; un compte ne se ressuscite pas. Une
        // seule question ici.
        second_question: String::new(),
        confirmation_word: String::new(),
        operations: going.len() as i64,
        operation_templates: 0,
        recurring_rules: 0,
    })
}

#[tauri::command]
pub fn delete_operations<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    ids: Vec<i64>,
) -> Result<usize, String> {
    let mut conn = state.database()?;
    let gone = radinus_core::operations::delete(&mut conn, &ids).map_err(to_ipc_error)?;
    radinus_core::balances::update_all_accounts(&conn).map_err(to_ipc_error)?;
    drop(conn);
    operations_changed(&app);
    Ok(gone)
}

#[tauri::command]
pub fn operations_deleted_text(state: State<'_, AppState>, count: i64) -> Result<String, String> {
    let _conn = state.database()?;
    Ok(radinus_core::i18n::message_of(
        ui_language(),
        "operations-deleted",
        &[],
        &[("count", count)],
    ))
}

/// Opens F02 for an account.
#[tauri::command]
pub fn open_operations_list<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    account_id: i64,
) -> Result<(), String> {
    let conn = state.database()?;
    let language = ui_language();
    let label = radinus_core::accounts::get(&conn, account_id)
        .map_err(to_ipc_error)?
        .map(|account| account.label)
        .unwrap_or_default();
    drop(conn);

    crate::windows::open(
        &app,
        &crate::windows::operations_window(language, &label),
        Some(&format!("account={account_id}")),
    )
    .map_err(to_ipc_error)
}

/// What the selection adds up to, as the status line says it — sentence and
/// amount together.
///
/// The window used to fetch the amount alone and drop it into the sentence
/// itself. That is exactly what a window must not do: the sentence lives in
/// Fluent, with its own hole in it, and only Fluent knows where the hole is.
/// It showed the raw key on screen, because a sentence with an unfilled hole
/// is no sentence at all.
#[tauri::command]
pub fn operations_selection_total(
    state: State<'_, AppState>,
    amount: i64,
) -> Result<String, String> {
    let _conn = state.database()?;
    let language = ui_language();
    Ok(radinus_core::i18n::text_with(
        language,
        "operations-selection-total",
        "amount",
        &radinus_core::money::format(amount, language),
    ))
}

/// Leaves F02, **taking its fiche with it** — emptied first, so nothing it
/// held comes back to life on the next visit. Hidden, never destroyed, like
/// every Radinus window.
#[tauri::command]
pub fn close_operations_list<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
) -> Result<(), String> {
    for form in [
        crate::windows::operation_form_window(Language::French, ""),
        crate::windows::sub_operation_form_window(Language::French),
    ] {
        if let Some(window) = app.get_webview_window(&form.label) {
            window
                .emit_to(
                    tauri::EventTarget::webview_window(&form.label),
                    &crate::windows::reset_event(&form),
                    (),
                )
                .map_err(to_ipc_error)?;
            window.hide().map_err(to_ipc_error)?;
        }
    }
    if let Some(window) = app.get_webview_window("operations") {
        window.hide().map_err(to_ipc_error)?;
    }
    state.set_operation_form_record(None)?;
    state.set_operation_form_dirty(false)
}

/// The five combos the operations list edits with, in one call: category,
/// assignment, payment mode, payee, project. Each begins with « Non précisé »
/// (02_BASE_DE_DONNEES.md §7 rule 2).
///
/// They are fetched once, when the window opens, and not per row: a list
/// showing forty rows would otherwise ask for the same five lists forty times.
#[derive(Serialize)]
pub struct CombosDto {
    pub category: Vec<ItemDto>,
    pub assignment: Vec<ItemDto>,
    pub payment_mode: Vec<ItemDto>,
    pub payee: Vec<ItemDto>,
    pub project: Vec<ItemDto>,
}

#[tauri::command]
pub fn list_operation_combos(state: State<'_, AppState>) -> Result<CombosDto, String> {
    let conn = state.database()?;
    let unspecified = radinus_core::i18n::unspecified_label(ui_language());
    let combo = |kind: Nomenclature| -> Result<Vec<ItemDto>, String> {
        Ok(
            nomenclatures::list_for_combo(&conn, kind, &unspecified)
                .map_err(to_ipc_error)?
                .into_iter()
                .map(|item| ItemDto {
                    id: item.id,
                    label: item.label,
                })
                .collect(),
        )
    };
    Ok(CombosDto {
        category: combo(Nomenclature::Category)?,
        assignment: combo(Nomenclature::Assignment)?,
        payment_mode: combo(Nomenclature::PaymentMode)?,
        payee: combo(Nomenclature::Payee)?,
        project: combo(Nomenclature::Project)?,
    })
}

// --- The fiche opération, F03 (Phase 5.2) -------------------------------

/// An operation as its fiche shows it. The amount is split the way the
/// original splits it: a **direction** and a magnitude typed positive, never
/// a signed number in a field.
#[derive(Serialize)]
pub struct OperationDto {
    pub id: i64,
    pub account_id: i64,
    pub label: String,
    pub payment_reference: String,
    pub date: String,
    pub clearing_date: String,
    /// `"D"` or `"C"` — what the Type Opération combo is set on.
    pub direction: String,
    /// The amount **with its sign**, written with the separators of the
    /// interface: a debit reads « -70,00 ». The field shows the sign and the
    /// combo says the same thing — someone who typed a negative number must
    /// see it (Fabrice, 26/07/2026).
    pub amount: String,
    pub status_id: i64,
    pub category_id: i64,
    pub assignment_id: i64,
    pub payment_mode_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
    pub check_number: String,
    pub comment: String,
    /// Already worded: « Aucune pièce jointe », or how many there are.
    pub attachments: String,
    pub parent_id: i64,
    pub child_count: i64,
    pub verification_id: i64,
}

/// What the fiche sends back. Everything is text: it is what the fields hold.
#[derive(serde::Deserialize)]
pub struct OperationInput {
    pub label: String,
    pub payment_reference: String,
    pub date: String,
    pub clearing_date: String,
    pub direction: String,
    pub amount: String,
    pub status_id: i64,
    pub category_id: i64,
    pub assignment_id: i64,
    pub payment_mode_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
    pub comment: String,
    /// Absente quand l'appelant n'en parle pas : la vérification reste alors
    /// ce qu'elle est, et une opération qui naît est « Vérifiée ».
    #[serde(default)]
    pub verification_id: Option<i64>,
}

/// Turns what the fields hold into a record.
///
/// **The rule for the amount, and there is only one** (Fabrice, 26/07/2026):
/// what is written is the *absolute value* of what was typed, multiplied by
/// −1 for a debit and by 1 for a credit. The field never decides a sign — the
/// Type Opération combo does, and the fiche keeps the two in step by flipping
/// the combo to Débit the moment a minus is typed. Applied by the core
/// (`sub_operations::Direction::apply`) so that every window that writes an
/// amount does it the same way.
fn as_operation(
    input: &OperationInput,
) -> Result<radinus_core::operations::OperationInput, String> {
    // **Never `unwrap_or(0)`.** An amount that cannot be read stops the write;
    // `operation_refusal` has already said which field is at fault, and this
    // is the second lock on the same door (Fabrice, 25/07/2026).
    let amount = radinus_core::money::parse_or_zero(&input.amount)
        .map_err(|_| "operation-field-amount".to_string())?;
    Ok(radinus_core::operations::OperationInput {
        label: input.label.trim().to_string(),
        payment_reference: input.payment_reference.trim().to_string(),
        date: a_date(&input.date),
        clearing_date: a_date(&input.clearing_date),
        direction: if input.direction == "C" {
            radinus_core::sub_operations::Direction::Credit
        } else {
            radinus_core::sub_operations::Direction::Debit
        },
        amount,
        status_id: input.status_id,
        category_id: input.category_id,
        assignment_id: input.assignment_id,
        payment_mode_id: input.payment_mode_id,
        payee_id: input.payee_id,
        project_id: input.project_id,
        verification_id: input.verification_id,
        comment: Some(input.comment.clone()),
    })
}

/// The three statuses of an operation — pointed, committed, planned. A closed
/// list prefilled by the code: read as it is, never added to.
///
/// **Les clefs viennent de la base, les mots de la traduction** (Fabrice,
/// 01/10/2026). Le libellé de `StatutOperation` est resté en français depuis
/// la création de la base ; il ne sert plus que de secours pour une clef que
/// la traduction ne connaîtrait pas.
#[tauri::command]
pub fn list_operation_statuses(state: State<'_, AppState>) -> Result<Vec<ItemDto>, String> {
    let conn = state.database()?;
    let language = ui_language();
    Ok(radinus_core::operations::statuses(&conn)
        .map_err(to_ipc_error)?
        .into_iter()
        .map(|item| ItemDto {
            id: item.id,
            label: radinus_core::i18n::status_label(language, item.id).unwrap_or(item.label),
        })
        .collect())
}

/// Les quatre vérifications — à vérifier, vérifiée, douteuse, contestée
/// (Fabrice, 03/10/2026). Comme les statuts : les clefs viennent de la base,
/// les mots de la traduction.
#[tauri::command]
pub fn list_operation_verifications(state: State<'_, AppState>) -> Result<Vec<ItemDto>, String> {
    let conn = state.database()?;
    let language = ui_language();
    Ok(radinus_core::operations::verifications(&conn)
        .map_err(to_ipc_error)?
        .into_iter()
        .map(|item| ItemDto {
            id: item.id,
            label: radinus_core::i18n::verification_label(language, item.id).unwrap_or(item.label),
        })
        .collect())
}

#[tauri::command]
pub fn get_operation(state: State<'_, AppState>, id: i64) -> Result<Option<OperationDto>, String> {
    let conn = state.database()?;
    let language = ui_language();
    let Some(operation) = radinus_core::operations::get(&conn, id).map_err(to_ipc_error)? else {
        return Ok(None);
    };
    let date = |value: Option<radinus_core::domain::NaiveDate>| {
        value
            .map(|day| day.format("%Y-%m-%d").to_string())
            .unwrap_or_default()
    };
    Ok(Some(OperationDto {
        id: operation.id,
        account_id: operation.account_id,
        label: operation.label,
        payment_reference: operation.payment_reference,
        date: date(operation.date),
        clearing_date: date(operation.clearing_date),
        // The two controls of the « Montant » zone, saying the same thing:
        // the sign is in the field *and* in the combo. Showing a debit as a
        // bare « 70,00 » would mean the fiche displays something other than
        // what the record holds.
        direction: if operation.amount < 0 { "D" } else { "C" }.to_string(),
        amount: radinus_core::money::format_plain(operation.amount, language),
        status_id: operation.status_id,
        category_id: operation.category_id,
        assignment_id: operation.assignment_id,
        payment_mode_id: operation.payment_mode_id,
        payee_id: operation.payee_id,
        project_id: operation.project_id,
        check_number: operation.check_number,
        comment: operation.comment,
        attachments: radinus_core::i18n::message_of(
            language,
            "operation-attachments",
            &[],
            &[("count", operation.attachment_count)],
        ),
        parent_id: operation.parent_id,
        child_count: operation.child_count,
        verification_id: operation.verification_id,
    }))
}

/// The status line of an empty fiche: no attachment, since there is no
/// operation to carry one.
#[tauri::command]
pub fn operation_attachments_text(
    state: State<'_, AppState>,
    count: i64,
) -> Result<String, String> {
    let _conn = state.database()?;
    Ok(radinus_core::i18n::message_of(
        ui_language(),
        "operation-attachments",
        &[],
        &[("count", count)],
    ))
}

/// What would stop this operation being saved, already worded — `null` when
/// nothing does. Asked before anything is written, exactly as the fiche
/// compte and the fiche nomenclature do: a refusal is the window's to show,
/// never a failure thrown at it.
///
/// **The date is required**, and that is not pedantry: the list reads a
/// period, and an operation with no date falls outside every period there is
/// — it would be written, and then never seen again.
#[tauri::command]
pub fn operation_refusal(
    state: State<'_, AppState>,
    label: String,
    amount: String,
    date: String,
    clearing_date: String,
    status_id: i64,
) -> Result<Option<String>, String> {
    let _conn = state.database()?;
    let language = ui_language();

    if label.trim().is_empty() {
        return Ok(Some(radinus_core::i18n::text(
            language,
            "operation-label-required",
        )));
    }
    if radinus_core::money::parse_or_zero(&amount).is_err() {
        return Ok(Some(unreadable_amount("operation-field-amount")));
    }
    if a_date(&date).is_none() {
        return Ok(Some(radinus_core::i18n::text(
            language,
            "operation-date-required",
        )));
    }
    if !clearing_date.trim().is_empty() && a_date(&clearing_date).is_none() {
        return Ok(Some(radinus_core::i18n::text(
            language,
            "operation-clearing-date-invalid",
        )));
    }
    // **Pointée veut dire que la banque l'a passée, un jour donné** (Fabrice,
    // 21/08/2026). Sans cette date, l'opération affirme une chose et refuse de
    // dire quand — et le solde progressif, qui parcourt les opérations dans
    // l'ordre des dates de pointage, la rangerait avant tout le reste : elle
    // compterait dans le solde en banque tout en faussant la colonne « Solde »
    // de toutes les lignes suivantes.
    if status_id == POINTED_STATUS && clearing_date.trim().is_empty() {
        return Ok(Some(radinus_core::i18n::text(
            language,
            "operation-clearing-date-required",
        )));
    }
    Ok(None)
}

/// Le statut « pointée ». Il vaut 1 depuis la 1.9.3, et le nombre nu ne dirait
/// rien au milieu d'une condition.
const POINTED_STATUS: i64 = 1;

/// **Le refus s'affiche dans un panneau, et il propose une issue** (Fabrice,
/// 25/08/2026 : « on ne le voie pas du tout si tu l'affiche comme cela, c'est
/// tres mauvais »).
///
/// La phrase de refus au bas de la fenêtre passait inaperçue. Elle est
/// désormais posée dans le panneau Oui/Non du logiciel, et une seconde ligne
/// propose la seule issue raisonnable : enregistrer avec la date de
/// l'opération. Oui enregistre, Non laisse la fiche ouverte, telle quelle.
///
/// La question se demande ici parce qu'elle porte une date : une fenêtre ne
/// compose pas de phrase, elle en reçoit. `date` est la date de l'opération,
/// telle que le champ la donne — elle a déjà été contrôlée par le refus, qui
/// exige une date lisible avant d'en arriver au pointage.
#[tauri::command]
pub fn clearing_date_question(date: String) -> String {
    let shown = match a_date(&date) {
        Some(day) => day.format("%d/%m/%Y").to_string(),
        None => date.trim().to_string(),
    };
    radinus_core::i18n::message_of(
        ui_language(),
        "operation-clearing-date-question",
        &[("date", shown.as_str())],
        &[],
    )
}

#[tauri::command]
pub fn create_operation<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    account_id: i64,
    operation: OperationInput,
) -> Result<i64, String> {
    let conn = state.database()?;
    let record = as_operation(&operation).map_err(|key| unreadable_amount(&key))?;
    let written = radinus_core::operations::create(&conn, account_id, &record).map_err(to_ipc_error)?;
    drop(conn);
    operations_changed(&app);
    Ok(written)
}

#[tauri::command]
pub fn update_operation<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    id: i64,
    operation: OperationInput,
) -> Result<bool, String> {
    let conn = state.database()?;
    let record = as_operation(&operation).map_err(|key| unreadable_amount(&key))?;
    let changed = radinus_core::operations::update(&conn, id, &record).map_err(to_ipc_error)?;
    drop(conn);
    operations_changed(&app);
    Ok(changed)
}

/// L'identifiant FITID d'une opération, tel qu'il est en base.
///
/// Rend la chaîne vide quand l'opération n'en porte pas — et **aussi quand
/// elle n'existe plus** : la fiche demande cet identifiant pour le montrer
/// dans une boîte, et une opération effacée sous son nez ne mérite pas une
/// erreur, elle mérite un champ vide et le refus au moment d'écrire.
#[tauri::command]
pub fn operation_fitid(state: State<'_, AppState>, id: i64) -> Result<String, String> {
    let conn = state.database()?;
    Ok(radinus_core::operations::fitid(&conn, id)
        .map_err(to_ipc_error)?
        .unwrap_or_default())
}

/// Écrit l'identifiant FITID d'une opération. La chaîne vide l'efface.
///
/// **Une seule commande pour les deux options du menu**, parce que c'est une
/// seule écriture : « supprimer » n'est pas un autre geste que « éditer », il
/// écrit rien. Deux commandes auraient laissé croire à deux chemins, donc à
/// deux occasions de diverger.
///
/// Rend `false` quand l'opération n'existe plus.
#[tauri::command]
pub fn set_operation_fitid<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    id: i64,
    value: String,
) -> Result<bool, String> {
    let conn = state.database()?;
    let changed = radinus_core::operations::set_fitid(&conn, id, &value).map_err(to_ipc_error)?;
    drop(conn);
    operations_changed(&app);
    Ok(changed)
}

/// Opens the fiche opération (F03). `mode` is the original's own vocabulary:
/// "A" adds, "M" modifies, "L" consults.
#[tauri::command]
pub fn open_operation_form<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    mode: String,
    account_id: i64,
    id: Option<i64>,
) -> Result<(), String> {
    let conn = state.database()?;
    let language = ui_language();
    let label = radinus_core::accounts::get(&conn, account_id)
        .map_err(to_ipc_error)?
        .map(|account| account.label)
        .unwrap_or_default();
    drop(conn);

    let query = match id {
        Some(id) => format!("mode={mode}&account={account_id}&id={id}"),
        None => format!("mode={mode}&account={account_id}"),
    };
    crate::windows::open(
        &app,
        &crate::windows::operation_form_window(language, &label),
        Some(&query),
    )
    .map_err(to_ipc_error)
}

/// Dit que les opérations ont bougé — **à toutes les fenêtres qui en vivent**.
///
/// F02 la première, mais la statistique aussi : modifier une opération depuis
/// le détail d'une case doit refaire la matrice, non seulement pour les
/// montants mais aussi pour les classements — un changement de catégorie fait
/// changer le montant de ligne (demande de Fabrice, 26/07/2026).
///
/// Chaque événement porte l'étiquette de sa fenêtre : un `listen()` déclaré
/// depuis JavaScript s'enregistre pour n'importe quelle cible, alors un nom
/// commun serait entendu par toutes.
/// **Une écriture d'opération prévient d'elle-même** (Fabrice, 25/08/2026).
///
/// Bug remonté : la liste des opérations d'un compte, laissée ouverte, restait
/// figée après une importation de relevé OFX ; il fallait la fermer et la
/// rouvrir. La cause n'était pas dans l'importation : c'était que **prévenir
/// était le travail de la fenêtre qui demandait l'écriture**, et que chaque
/// fenêtre devait y penser. La fiche opération y pensait, l'intégration en
/// masse non — et cinq autres chemins non plus.
///
/// Prévenir est donc devenu le travail du contrôleur, à l'endroit où
/// l'écriture a lieu. Une fenêtre n'a plus rien à savoir, et le chemin qu'on
/// écrira dans six mois préviendra sans que personne y pense : c'est toute la
/// classe de bug qui disparaît, pas seulement l'OFX.
///
/// **Deux fenêtres sont prévenues, pas une.** Écrire une opération déplace les
/// soldes du compte : la liste des comptes est aussi périmée que celle des
/// opérations. C'est ce que faisaient déjà le virement et les échéances ; ce
/// n'est plus une politesse de ces deux-là, c'est la règle.
///
/// L'échec de la diffusion est ignoré à dessein : une fenêtre qui n'écoute pas
/// — parce qu'elle n'est pas ouverte — n'est pas une erreur, et une écriture
/// réussie ne doit pas être rapportée comme un échec parce que personne ne
/// l'écoutait.
fn operations_changed<R: Runtime>(app: &AppHandle<R>) {
    for event in ["data-changed:operations", "data-changed:accounts-list"] {
        let _ = app.emit(event, ());
    }
}

#[tauri::command]
pub fn set_operation_form_dirty(state: State<'_, AppState>, dirty: bool) -> Result<(), String> {
    state.set_operation_form_dirty(dirty)
}

#[tauri::command]
pub fn set_operation_form_record(
    state: State<'_, AppState>,
    id: Option<i64>,
) -> Result<(), String> {
    state.set_operation_form_record(id)
}

#[tauri::command]
pub fn operations_list_has_unsaved_changes(state: State<'_, AppState>) -> bool {
    state.operation_form_is_dirty()
}

// --- The fiche sous-opération, F04 (Phase 5.3) ---------------------------

/// A sub-operation as its fiche shows it. Neither mode, status nor date: it
/// holds its mother's (`sub_operations::sync_from_parent`).
#[derive(Serialize)]
pub struct SubOperationDto {
    pub id: i64,
    pub parent_id: i64,
    pub label: String,
    pub direction: String,
    pub amount: String,
    pub category_id: i64,
    pub assignment_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
    pub comment: String,
    /// Whether this row is the Complement. Shown, not forbidden: it is a
    /// state, not a protected object (Fabrice, 26/07/2026).
    pub is_complement: bool,
    /// « Ventilation de « RETRAIT » (-100,00 €) », already worded.
    pub parent_line: String,
}

#[derive(serde::Deserialize)]
pub struct SubOperationInput {
    pub label: String,
    pub direction: String,
    pub amount: String,
    pub category_id: i64,
    pub assignment_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
    pub comment: String,
}

fn as_sub_operation(
    input: &SubOperationInput,
) -> Result<radinus_core::sub_operations::SubOperationInput, String> {
    let amount = radinus_core::money::parse_or_zero(&input.amount)
        .map_err(|_| "operation-field-amount".to_string())?;
    Ok(radinus_core::sub_operations::SubOperationInput {
        label: input.label.trim().to_string(),
        direction: if input.direction == "C" {
            radinus_core::sub_operations::Direction::Credit
        } else {
            radinus_core::sub_operations::Direction::Debit
        },
        amount,
        category_id: input.category_id,
        assignment_id: input.assignment_id,
        payee_id: input.payee_id,
        project_id: input.project_id,
        comment: Some(input.comment.clone()),
    })
}

/// The line naming what is being split, for the status bar of F04.
fn splitting_line(
    conn: &radinus_core::database::Connection,
    parent_id: i64,
) -> Result<Option<String>, String> {
    let language = ui_language();
    let Some(parent) = radinus_core::operations::get(conn, parent_id).map_err(to_ipc_error)? else {
        return Ok(None);
    };
    Ok(Some(radinus_core::i18n::message_of(
        language,
        "sub-operation-of",
        &[
            ("label", &parent.label),
            (
                "amount",
                &radinus_core::money::format(parent.amount, language),
            ),
        ],
        &[],
    )))
}

/// Names the operation about to be split, or `null` when it no longer exists.
#[tauri::command]
pub fn sub_operation_parent_line(
    state: State<'_, AppState>,
    parent_id: i64,
) -> Result<Option<String>, String> {
    let conn = state.database()?;
    splitting_line(&conn, parent_id)
}

#[tauri::command]
pub fn get_sub_operation(
    state: State<'_, AppState>,
    id: i64,
) -> Result<Option<SubOperationDto>, String> {
    let conn = state.database()?;
    let language = ui_language();
    let Some(sub) = radinus_core::operations::get(&conn, id).map_err(to_ipc_error)? else {
        return Ok(None);
    };
    // A top-level operation is not a ventilation: F03 is its fiche.
    if sub.parent_id == 0 {
        return Ok(None);
    }
    let parent_line = splitting_line(&conn, sub.parent_id)?.unwrap_or_default();
    Ok(Some(SubOperationDto {
        id: sub.id,
        parent_id: sub.parent_id,
        label: sub.label,
        direction: if sub.amount < 0 { "D" } else { "C" }.to_string(),
        amount: radinus_core::money::format_plain(sub.amount, language),
        category_id: sub.category_id,
        assignment_id: sub.assignment_id,
        payee_id: sub.payee_id,
        project_id: sub.project_id,
        comment: sub.comment,
        is_complement: sub.is_complement,
        parent_line,
    }))
}

#[tauri::command]
pub fn sub_operation_refusal(
    state: State<'_, AppState>,
    label: String,
    amount: String,
) -> Result<Option<String>, String> {
    let _conn = state.database()?;
    let language = ui_language();
    if label.trim().is_empty() {
        return Ok(Some(radinus_core::i18n::text(
            language,
            "sub-operation-label-required",
        )));
    }
    if radinus_core::money::parse_or_zero(&amount).is_err() {
        return Ok(Some(unreadable_amount("operation-field-amount")));
    }
    Ok(None)
}

/// Adds a sub-operation to an operation. `null` when the operation is gone.
#[tauri::command]
pub fn create_sub_operation<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    parent_id: i64,
    sub: SubOperationInput,
) -> Result<Option<i64>, String> {
    let conn = state.database()?;
    let record = as_sub_operation(&sub).map_err(|key| unreadable_amount(&key))?;
    let written =
        radinus_core::sub_operations::create(&conn, parent_id, &record).map_err(to_ipc_error)?;
    drop(conn);
    operations_changed(&app);
    Ok(written)
}

#[tauri::command]
pub fn update_sub_operation<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    id: i64,
    sub: SubOperationInput,
) -> Result<bool, String> {
    let conn = state.database()?;
    let record = as_sub_operation(&sub).map_err(|key| unreadable_amount(&key))?;
    let changed = radinus_core::sub_operations::update(&conn, id, &record).map_err(to_ipc_error);
    operations_changed(&app);
    changed
}

/// Opens F04, to add a ventilation to `parent_id` or to change one.
#[tauri::command]
pub fn open_sub_operation_form<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    mode: String,
    parent_id: i64,
    id: Option<i64>,
) -> Result<(), String> {
    let language = window_language(&state);
    let query = match id {
        Some(id) => format!("mode={mode}&parent={parent_id}&id={id}"),
        None => format!("mode={mode}&parent={parent_id}"),
    };
    crate::windows::open(
        &app,
        &crate::windows::sub_operation_form_window(language),
        Some(&query),
    )
    .map_err(to_ipc_error)
}

/// The `Base_point` button of F02: the selection becomes « pointé », and the
/// clearing date written is **the operation's own date** (Fabrice,
/// 26/07/2026). A child is pointed through its mother — a status does not
/// belong to a ventilation.
#[tauri::command]
pub fn point_operations<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    ids: Vec<i64>,
) -> Result<String, String> {
    let conn = state.database()?;
    let language = ui_language();
    let pointed = radinus_core::operations::point(&conn, &ids).map_err(to_ipc_error)?;
    drop(conn);
    operations_changed(&app);
    Ok(radinus_core::i18n::message_of(
        language,
        "operations-pointed",
        &[],
        &[("count", pointed as i64)],
    ))
}

// --- F20, la statistique par catégories (Phase 6) ------------------------

/// Les cinq interrupteurs, tels que la fenêtre les envoie.
#[derive(serde::Deserialize, Clone, Copy)]
pub struct SwitchesInput {
    pub pointed: bool,
    pub committed: bool,
    pub planned: bool,
    pub debits: bool,
    pub credits: bool,
}

impl From<SwitchesInput> for radinus_core::statistics::Switches {
    fn from(input: SwitchesInput) -> Self {
        Self {
            pointed: input.pointed,
            committed: input.committed,
            planned: input.planned,
            debits: input.debits,
            credits: input.credits,
        }
    }
}

/// Une ligne de la matrice, déjà écrite pour l'écran. Les montants voyagent
/// **en texte** — les écrire est l'affaire du noyau — et en nombre, pour que
/// la fenêtre sache de quelle couleur peindre la case sans relire le texte.
#[derive(Serialize)]
pub struct MatrixRowDto {
    pub id: i64,
    pub label: String,
    pub months: Vec<String>,
    pub month_values: Vec<i64>,
    pub filled: Vec<bool>,
    pub total: String,
    pub total_value: i64,
    pub total_filled: bool,
    pub is_empty: bool,
}

/// Tout ce que F20 dessine.
#[derive(Serialize)]
pub struct MatrixDto {
    pub rows: Vec<MatrixRowDto>,
    pub sum: Vec<String>,
    pub sum_values: Vec<i64>,
    pub sum_filled: Vec<bool>,
    pub sum_total: String,
    pub sum_total_value: i64,
    pub cumulative: Vec<String>,
    pub cumulative_values: Vec<i64>,
    pub has_data: bool,
    /// Les douze mois, en toutes lettres, dans la langue de l'interface.
    pub month_names: Vec<String>,
    /// « 3 comptes », déjà rédigé.
    pub accounts: String,
}

/// Un montant écrit, ou rien du tout : une case vide ne porte pas « 0,00 € ».
fn cell(amount: i64, filled: bool, language: Language) -> String {
    if filled {
        radinus_core::money::format(amount, language)
    } else {
        String::new()
    }
}

/// Ce qu'il faut pour demander une année : la question rédigée, et les bornes.
#[derive(Serialize)]
pub struct YearPromptDto {
    pub question: String,
    pub first: i32,
    pub last: i32,
}

/// La question du millésime, avec ses bornes dedans. Encore une phrase à trou :
/// c'est le noyau qui l'écrit, jamais la fenêtre.
#[tauri::command]
pub fn statistics_year_prompt(state: State<'_, AppState>) -> Result<YearPromptDto, String> {
    let _conn = state.database()?;
    let language = ui_language();
    let first = radinus_core::statistics::FIRST_YEAR;
    let last = radinus_core::statistics::LAST_YEAR;
    Ok(YearPromptDto {
        question: radinus_core::i18n::message_of(
            language,
            "statistics-year-question",
            &[("first", &first.to_string()), ("last", &last.to_string())],
            &[],
        ),
        first,
        last,
    })
}

/// Ramène une année dans les bornes de Radinus. **On impose, on ne rejette
/// pas** : quelqu'un qui tape 1800 voulait « le plus loin possible ».
///
/// La règle est au noyau et non dans la fenêtre, pour que les deux horloges du
/// panneau et la saisie au clavier obéissent exactement à la même.
#[tauri::command]
pub fn statistics_year(state: State<'_, AppState>, year: i32) -> Result<i32, String> {
    // La base n'est pas consultée, mais l'état l'est : une fenêtre qui a
    // démarré sans base ne doit pas croire qu'elle travaille.
    let _ = state.database()?;
    Ok(radinus_core::statistics::year_within_bounds(year))
}

/// Les cinq libellés du bandeau, **rédigés en entier**, dans l'ordre des
/// interrupteurs.
///
/// Ils ne sont pas dans le dictionnaire et ne peuvent pas y être : ce sont des
/// phrases à trou, et le dictionnaire ne porte que ce qui se résout sans
/// argument. La fenêtre les demande à chaque bascule — c'est un aller-retour
/// par clic, autant dire rien.
///
/// **C'est la deuxième fois que ce piège se referme.** La fenêtre remplissait
/// le trou elle-même, avec un `replace` sur le texte de la clef ; comme la
/// clef n'était pas au dictionnaire, elle s'affichait telle quelle et les cinq
/// interrupteurs s'appelaient tous « statistics-switch-pointed » (signalé par
/// Fabrice, 26/07/2026). Exactement la faute du total de la sélection de F02 :
/// seule Fluent sait où est le trou d'une phrase, et il n'y a qu'un endroit
/// où l'on écrit une phrase.
#[tauri::command]
pub fn statistics_switch_labels(
    state: State<'_, AppState>,
    switches: SwitchesInput,
) -> Result<Vec<String>, String> {
    let _conn = state.database()?;
    let language = ui_language();
    let on = radinus_core::i18n::text(language, "statistics-switch-on");
    let off = radinus_core::i18n::text(language, "statistics-switch-off");
    Ok([
        ("statistics-switch-pointed", switches.pointed),
        ("statistics-switch-committed", switches.committed),
        ("statistics-switch-planned", switches.planned),
        ("statistics-switch-debits", switches.debits),
        ("statistics-switch-credits", switches.credits),
    ]
    .iter()
    .map(|(key, lit)| {
        radinus_core::i18n::text_with(language, key, "state", if *lit { &on } else { &off })
    })
    .collect())
}

/// La matrice d'une statistique, pour un axe, une année et des comptes.
///
/// **Un seul chemin pour les six** (Fabrice, 26/07/2026) : l'axe est un
/// paramètre, pas une commande de plus. La ligne des non classées prend le nom
/// qui convient à l'axe — « Sans catégorie », « Sans tiers » — et c'est Fluent
/// qui le décline, pas cette fonction.
#[tauri::command]
pub fn axis_statistics(
    state: State<'_, AppState>,
    axis: String,
    account_ids: Vec<i64>,
    year: i32,
    switches: SwitchesInput,
) -> Result<MatrixDto, String> {
    let axis = statistics_axis(&axis)?;
    let conn = state.database()?;
    let language = ui_language();
    let unclassified =
        radinus_core::i18n::about(language, "statistics-unclassified", axis.key());
    let matrix = radinus_core::statistics::by_axis(
        &conn,
        &account_ids,
        year,
        switches.into(),
        axis,
        &unclassified,
    )
    .map_err(to_ipc_error)?;

    Ok(MatrixDto {
        rows: matrix
            .rows
            .iter()
            .map(|row| MatrixRowDto {
                id: row.id,
                // **Une vérification se nomme dans la langue en cours**, par
                // sa clef — comme dans la liste des opérations et dans la
                // fiche. Le libellé de la base n'est qu'un secours. Les six
                // nomenclatures, elles, portent le nom que l'utilisateur leur
                // a donné.
                label: if axis.has_unclassified_row() {
                    row.label.clone()
                } else {
                    radinus_core::i18n::verification_label(language, row.id)
                        .unwrap_or_else(|| row.label.clone())
                },
                months: (0..12)
                    .map(|m| cell(row.months[m], row.filled[m], language))
                    .collect(),
                month_values: row.months.to_vec(),
                filled: row.filled.to_vec(),
                total: cell(row.total, row.total_filled, language),
                total_value: row.total,
                total_filled: row.total_filled,
                is_empty: row.is_empty(),
            })
            .collect(),
        sum: (0..12)
            .map(|m| cell(matrix.sum[m], matrix.sum_filled[m], language))
            .collect(),
        sum_values: matrix.sum.to_vec(),
        sum_filled: matrix.sum_filled.to_vec(),
        sum_total: cell(matrix.sum_total, matrix.has_data, language),
        sum_total_value: matrix.sum_total,
        // Le cumul est reporté jusqu'à décembre : il s'écrit sur tous les mois
        // dès qu'il y a quelque chose à cumuler.
        cumulative: (0..12)
            .map(|m| cell(matrix.cumulative[m], matrix.has_data, language))
            .collect(),
        cumulative_values: matrix.cumulative.to_vec(),
        has_data: matrix.has_data,
        month_names: month_names(language).to_vec(),
        accounts: radinus_core::i18n::message_of(
            language,
            "statistics-accounts",
            &[],
            &[("count", account_ids.len() as i64)],
        ),
    })
}

/// La case que la fenêtre interroge : `kind` dit de quelle sorte elle est —
/// un croisement de la matrice, la ligne Somme ou la ligne Cumul.
#[derive(serde::Deserialize)]
pub struct CellInput {
    pub kind: String,
    /// La valeur de l'axe — une catégorie, un tiers, un poste budgétaire.
    pub value: Option<i64>,
    pub month: Option<u32>,
}

/// **Un mois impossible est un refus**, pour la même raison qu'un axe inconnu.
///
/// Le noyau, lui, ramène un mois hors bornes dans l'année : il rend une date,
/// toujours, et ne panique plus (audit du 03/08/2026, §3). Mais ramener 13 à
/// décembre en silence ferait afficher les opérations de décembre sous un
/// titre qui annonce autre chose — le repli discret que `statistics_axis`
/// refuse déjà juste en dessous.
///
/// Un mois hors de 1..=12 ne peut venir que d'un défaut de la fenêtre : un
/// décalage d'indice, une colonne « Total » comptée en treizième. Le dire tout
/// haut est la seule façon qu'il se corrige.
///
/// L'année, elle, n'a pas besoin de garde ici : elle vient d'un champ de
/// saisie, et la règle du logiciel est de l'imposer plutôt que de la rejeter
/// (Fabrice, 26/07/2026). `year_within_bounds` s'en charge dans le noyau.
fn a_real_cell(cell: CellInput) -> Result<CellInput, String> {
    match cell.month {
        Some(month) if !(1..=12).contains(&month) => Err(format!(
            "mois de statistique impossible : {month} (attendu entre 1 et 12)"
        )),
        _ => Ok(cell),
    }
}

/// L'axe qu'une fenêtre demande. **Un axe inconnu est un refus**, pas un
/// repli silencieux sur les catégories : une statistique qui montrerait autre
/// chose que ce qu'annonce son titre serait pire qu'une erreur.
fn statistics_axis(key: &str) -> Result<radinus_core::statistics::Axis, String> {
    radinus_core::statistics::Axis::from_key(key)
        .ok_or_else(|| format!("axe de statistique inconnu : {key}"))
}

/// Le détail derrière une case.
///
/// **La Somme et le Cumul d'un même mois sont deux cases différentes** et ne
/// comptent pas la même chose : la Somme de mai, ce sont les opérations de
/// mai ; le Cumul de mai, celles de janvier à mai (Fabrice, 26/07/2026). La
/// sorte de case fait donc partie de ce que la fenêtre envoie, et le sens de
/// chacune est tenu par le noyau.
#[tauri::command]
pub fn statistics_detail(
    state: State<'_, AppState>,
    axis: String,
    account_ids: Vec<i64>,
    year: i32,
    switches: SwitchesInput,
    cell: CellInput,
) -> Result<Vec<OperationRowDto>, String> {
    use radinus_core::statistics::Cell;
    let axis = statistics_axis(&axis)?;
    let cell = a_real_cell(cell)?;
    let asked = match cell.kind.as_str() {
        "sum" => Cell::Sum { month: cell.month },
        // Un cumul sans mois n'existe pas : la ligne Cumul n'a pas de colonne
        // Total, puisque son dernier mois *est* le total de l'année.
        "cumulative" => match cell.month {
            Some(month) => Cell::Cumulative { month },
            None => Cell::Sum { month: None },
        },
        _ => Cell::Axis {
            value: cell.value.unwrap_or(0),
            month: cell.month,
        },
    };

    let conn = state.database()?;
    let language = ui_language();
    let found = radinus_core::statistics::behind_the_cell(
        &conn,
        &account_ids,
        year,
        switches.into(),
        axis,
        asked,
    )
    .map_err(to_ipc_error)?;
    // Le détail est une liste d'opérations comme celle de F02 : la même
    // traduction, pour que les colonnes se lisent pareil d'une fenêtre à
    // l'autre.
    let months = month_names(language);
    Ok(found
        .iter()
        .map(|(row, parent_id)| as_row(row, *parent_id, 0, language, &months))
        .collect())
}

// --- F39, le bilan croisé (25/08/2026) -----------------------------------

/// Une colonne du bilan croisé : une affectation, ou « Sans affectation ».
#[derive(Serialize)]
pub struct CrossedColumnDto {
    pub id: i64,
    pub label: String,
}

/// Une ligne : une catégorie, ou « Sans catégorie ». Les montants voyagent
/// **en texte** — les écrire est l'affaire du noyau — et en nombre, pour que
/// la fenêtre sache de quelle couleur peindre la case sans relire le texte.
/// C'est la règle de la matrice des statistiques, et le bilan croisé la suit.
#[derive(Serialize)]
pub struct CrossedRowDto {
    pub id: i64,
    pub label: String,
    pub cells: Vec<String>,
    pub cell_values: Vec<i64>,
    pub filled: Vec<bool>,
    pub total: String,
    pub total_value: i64,
    pub total_filled: bool,
    pub is_empty: bool,
}

/// Tout ce que F39 dessine. **Pas de cumul** : les affectations n'ont pas
/// d'ordre et le tableau ne porte que sur un mois (Fabrice, 25/08/2026).
#[derive(Serialize)]
pub struct CrossedMatrixDto {
    pub columns: Vec<CrossedColumnDto>,
    pub rows: Vec<CrossedRowDto>,
    pub sum: Vec<String>,
    pub sum_values: Vec<i64>,
    pub sum_filled: Vec<bool>,
    pub sum_total: String,
    pub sum_total_value: i64,
    pub has_data: bool,
    /// « 09/2026 », tel que le bandeau bleu l'affiche.
    pub period: String,
    /// « 3 comptes », déjà rédigé.
    pub accounts: String,
}

/// **Le mois affiché, écrit une seule fois.** La fenêtre ne compose pas
/// « 09/2026 » elle-même : deux zéros à ajouter, une barre à placer, et c'est
/// une phrase de plus dans une fenêtre — ce que ce projet interdit.
fn period_of(year: i32, month: u32) -> String {
    format!("{month:02}/{year:04}")
}

/// **Un mois impossible est un refus.** La même règle que pour les cases des
/// statistiques : le noyau ramènerait 13 à décembre en silence, et le tableau
/// montrerait décembre sous un titre qui annonce autre chose.
fn a_real_stated_month(month: u32) -> Result<u32, String> {
    if (1..=12).contains(&month) {
        return Ok(month);
    }
    Err(format!(
        "mois de bilan croisé impossible : {month} (attendu entre 1 et 12)"
    ))
}

/// Le bilan croisé du mois demandé.
#[tauri::command]
pub fn crossed_balance(
    state: State<'_, AppState>,
    account_ids: Vec<i64>,
    year: i32,
    month: u32,
    switches: SwitchesInput,
) -> Result<CrossedMatrixDto, String> {
    let month = a_real_stated_month(month)?;
    let conn = state.database()?;
    let language = ui_language();
    // Les deux libellés « Sans … » sont ceux des statistiques du même axe :
    // une seule phrase par nomenclature dans tout le logiciel.
    let no_category = radinus_core::i18n::about(language, "statistics-unclassified", "category");
    let no_assignment =
        radinus_core::i18n::about(language, "statistics-unclassified", "assignment");
    let matrix = radinus_core::crossed_balance::crossed(
        &conn,
        &account_ids,
        year,
        month,
        switches.into(),
        &no_category,
        &no_assignment,
    )
    .map_err(to_ipc_error)?;

    Ok(CrossedMatrixDto {
        columns: matrix
            .columns
            .iter()
            .map(|column| CrossedColumnDto {
                id: column.id,
                label: column.label.clone(),
            })
            .collect(),
        rows: matrix
            .rows
            .iter()
            .map(|row| CrossedRowDto {
                id: row.id,
                label: row.label.clone(),
                cells: row
                    .cells
                    .iter()
                    .zip(row.filled.iter())
                    .map(|(amount, filled)| cell(*amount, *filled, language))
                    .collect(),
                cell_values: row.cells.clone(),
                filled: row.filled.clone(),
                total: cell(row.total, row.total_filled, language),
                total_value: row.total,
                total_filled: row.total_filled,
                is_empty: row.is_empty(),
            })
            .collect(),
        sum: matrix
            .sum
            .iter()
            .zip(matrix.sum_filled.iter())
            .map(|(amount, filled)| cell(*amount, *filled, language))
            .collect(),
        sum_values: matrix.sum.clone(),
        sum_filled: matrix.sum_filled.clone(),
        sum_total: cell(matrix.sum_total, matrix.has_data, language),
        sum_total_value: matrix.sum_total,
        has_data: matrix.has_data,
        period: period_of(radinus_core::statistics::year_within_bounds(year), month),
        accounts: radinus_core::i18n::message_of(
            language,
            "statistics-accounts",
            &[],
            &[("count", account_ids.len() as i64)],
        ),
    })
}

/// La case que la fenêtre interroge. `category` et `assignment` disent ce
/// qu'elle demande, et **l'absence veut dire « toutes »** : une case ordinaire
/// nomme les deux, la colonne Total ne nomme que la catégorie, la ligne Somme
/// ne nomme que l'affectation, le total général n'en nomme aucune.
#[derive(serde::Deserialize)]
pub struct CrossedCellInput {
    pub category: Option<i64>,
    pub assignment: Option<i64>,
}

/// Le détail derrière une case du bilan croisé.
#[tauri::command]
pub fn crossed_balance_detail(
    state: State<'_, AppState>,
    account_ids: Vec<i64>,
    year: i32,
    month: u32,
    switches: SwitchesInput,
    cell: CrossedCellInput,
) -> Result<Vec<OperationRowDto>, String> {
    let month = a_real_stated_month(month)?;
    let conn = state.database()?;
    let language = ui_language();
    let found = radinus_core::crossed_balance::behind_the_cell(
        &conn,
        &account_ids,
        year,
        month,
        switches.into(),
        cell.category,
        cell.assignment,
    )
    .map_err(to_ipc_error)?;
    // Le détail est une liste d'opérations comme celle de F02 : la même
    // traduction, pour que les colonnes se lisent pareil d'une fenêtre à
    // l'autre.
    let months = month_names(language);
    Ok(found
        .iter()
        .map(|(row, parent_id)| as_row(row, *parent_id, 0, language, &months))
        .collect())
}

/// **Le mois précédent ou le suivant**, l'année suivie.
///
/// Décembre bascule sur janvier de l'année d'après, et janvier sur décembre de
/// l'année d'avant : sans cela on serait bloqué au bout de chaque année. Les
/// bornes de Radinus s'appliquent ensuite, et la règle est **ici, une fois**,
/// pour que les deux horloges et la saisie au clavier lui obéissent également.
#[tauri::command]
pub fn crossed_balance_step(
    state: State<'_, AppState>,
    year: i32,
    month: u32,
    forward: bool,
) -> Result<(i32, u32), String> {
    let _ = state.database()?;
    let month = a_real_stated_month(month)?;
    let (year, month) = if forward {
        if month == 12 {
            (year + 1, 1)
        } else {
            (year, month + 1)
        }
    } else if month == 1 {
        (year - 1, 12)
    } else {
        (year, month - 1)
    };
    Ok((radinus_core::statistics::year_within_bounds(year), month))
}

/// La question posée quand on clique sur le mois du bandeau, et ses bornes.
#[tauri::command]
pub fn crossed_balance_month_prompt(
    state: State<'_, AppState>,
) -> Result<YearPromptDto, String> {
    let _conn = state.database()?;
    let language = ui_language();
    Ok(YearPromptDto {
        question: radinus_core::i18n::message_of(
            language,
            "crossed-balance-month-question",
            &[("first", "1"), ("last", "12")],
            &[],
        ),
        first: 1,
        last: 12,
    })
}

/// Ouvre F39 sur les comptes choisis.
#[tauri::command]
pub fn open_crossed_balance<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    account_ids: Vec<i64>,
) -> Result<(), String> {
    let language = window_language(&state);
    let accounts = account_ids
        .iter()
        .map(|id| id.to_string())
        .collect::<Vec<_>>()
        .join(",");
    crate::windows::open(
        &app,
        &crate::windows::crossed_balance_window(language),
        Some(&format!("accounts={accounts}")),
    )
    .map_err(to_ipc_error)
}

/// Quitte F39. Masquée, jamais détruite, comme toutes les fenêtres.
#[tauri::command]
pub fn close_crossed_balance<R: Runtime>(app: AppHandle<R>) -> Result<(), String> {
    if let Some(window) = app.get_webview_window("crossed-balance") {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(())
}

/// Ouvre **la fiche qui convient** à une opération : F03 si c'est une
/// opération, F04 si c'est une ventilation (demande de Fabrice, 26/07/2026).
///
/// La fenêtre n'envoie qu'une clef et ne décide de rien : c'est ici qu'on lit
/// l'enregistrement pour savoir de quoi il s'agit et à quel compte il
/// appartient. Le détail d'une statistique mélange les deux — c'est la règle
/// des feuilles — et il porte souvent des opérations de plusieurs comptes à la
/// fois, qu'aucune fenêtre n'a de raison de connaître.
#[tauri::command]
pub fn open_form_for_operation<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    id: i64,
) -> Result<(), String> {
    let conn = state.database()?;
    let language = ui_language();
    let Some(operation) = radinus_core::operations::get(&conn, id).map_err(to_ipc_error)? else {
        return Ok(());
    };
    let account_label = radinus_core::accounts::get(&conn, operation.account_id)
        .map_err(to_ipc_error)?
        .map(|account| account.label)
        .unwrap_or_default();
    drop(conn);

    if operation.parent_id != 0 {
        return crate::windows::open(
            &app,
            &crate::windows::sub_operation_form_window(language),
            Some(&format!(
                "mode=M&parent={}&id={id}",
                operation.parent_id
            )),
        )
        .map_err(to_ipc_error);
    }
    crate::windows::open(
        &app,
        &crate::windows::operation_form_window(language, &account_label),
        Some(&format!("mode=M&account={}&id={id}", operation.account_id)),
    )
    .map_err(to_ipc_error)
}

// --- L'export des tableaux (§3.1) ----------------------------------------

/// Une cellule, telle que la fenêtre la voit.
#[derive(serde::Deserialize)]
pub struct SheetCellInput {
    /// `"text"`, `"money"` ou `"empty"`.
    pub kind: String,
    /// Le texte, pour une cellule de texte.
    #[serde(default)]
    pub text: String,
    /// Le montant en micro-unités, pour une cellule monétaire.
    #[serde(default)]
    pub amount: i64,
    /// La couleur de fond, six chiffres hexadécimaux comme à l'écran.
    #[serde(default)]
    pub fill: Option<String>,
    #[serde(default)]
    pub bold: bool,
}

/// Ce qu'une fenêtre donne à exporter : ce qu'elle **affiche**, et rien qu'elle
/// aurait recalculé pour l'occasion.
#[derive(serde::Deserialize)]
pub struct SheetInput {
    pub name: String,
    #[serde(default)]
    pub context: String,
    #[serde(default)]
    pub header_rows: usize,
    pub rows: Vec<Vec<SheetCellInput>>,
    #[serde(default)]
    pub widths: Vec<f64>,
}

fn as_sheet(input: SheetInput) -> radinus_core::sheets::Sheet {
    use radinus_core::sheets::{Sheet, SheetCell};
    let mut sheet = Sheet::new(input.name);
    sheet.context = input.context;
    sheet.header_rows = input.header_rows;
    sheet.widths = input.widths;
    sheet.rows = input
        .rows
        .into_iter()
        .map(|line| {
            line.into_iter()
                .map(|cell| {
                    let built = match cell.kind.as_str() {
                        "money" => SheetCell::money(cell.amount),
                        "empty" => SheetCell::empty(),
                        _ => SheetCell::text(cell.text),
                    };
                    built.with_fill(cell.fill).with_bold(cell.bold)
                })
                .collect()
        })
        .collect();
    sheet
}

/// Écrit une feuille dans le fichier que l'utilisateur a choisi, et rend la
/// phrase qui le dit.
///
/// **Le format suit l'extension** du nom qu'il a donné dans le sélecteur du
/// système : `.csv` pour le texte, tout le reste en `.xlsx`.
#[tauri::command]
pub fn export_sheet(
    state: State<'_, AppState>,
    sheet: SheetInput,
    path: String,
) -> Result<String, String> {
    let conn = state.database()?;
    let language = ui_language();
    drop(conn);

    let file = std::path::PathBuf::from(&path);
    radinus_core::sheets::write(&as_sheet(sheet), &file).map_err(|error| {
        radinus_core::i18n::text_with(language, "export-failed", "reason", &error.to_string())
    })?;

    Ok(export_done(language, &file, &path))
}

/// Écrit **plusieurs feuilles dans un même classeur**, un onglet chacune.
///
/// C'est ce que demande « exporter toutes les années » : la fenêtre a calculé
/// une matrice par année et les envoie toutes ensemble, plutôt que d'écrire
/// douze fichiers que l'utilisateur devrait recoller.
#[tauri::command]
pub fn export_book(
    state: State<'_, AppState>,
    sheets: Vec<SheetInput>,
    path: String,
) -> Result<String, String> {
    let conn = state.database()?;
    let language = ui_language();
    drop(conn);

    let book: Vec<radinus_core::sheets::Sheet> = sheets.into_iter().map(as_sheet).collect();
    let tabs = book.len() as i64;
    let file = std::path::PathBuf::from(&path);
    radinus_core::sheets::write_book(&book, &file).map_err(|error| {
        radinus_core::i18n::text_with(language, "export-failed", "reason", &error.to_string())
    })?;

    // Un seul onglet, c'est un export ordinaire et la phrase ordinaire le dit.
    // Plusieurs, et elle en donne le compte : c'est la seule façon pour
    // l'utilisateur de savoir combien d'années portaient quelque chose.
    if tabs <= 1 {
        return Ok(export_done(language, &file, &path));
    }
    let shown = file
        .file_name()
        .and_then(|name| name.to_str())
        .unwrap_or(&path);
    Ok(radinus_core::i18n::message_of(
        language,
        "export-years-done",
        &[("file", shown)],
        &[("years", tabs)],
    ))
}

/// « Exporté vers « … » », rédigée par le noyau, avec le nom du fichier et non
/// son chemin entier : c'est ce que l'utilisateur vient de taper.
fn export_done(language: Language, file: &std::path::Path, path: &str) -> String {
    let shown = file
        .file_name()
        .and_then(|name| name.to_str())
        .unwrap_or(path);
    radinus_core::i18n::text_with(language, "export-done", "file", shown)
}

/// Les années qui portent quelque chose, pour les comptes choisis et **sous
/// les interrupteurs tels qu'ils sont posés** (choix de Fabrice, 26/07/2026).
#[tauri::command]
pub fn statistics_years(
    state: State<'_, AppState>,
    account_ids: Vec<i64>,
    switches: SwitchesInput,
) -> Result<Vec<i32>, String> {
    let conn = state.database()?;
    radinus_core::statistics::years_with_data(&conn, &account_ids, switches.into())
        .map_err(to_ipc_error)
}

/// La ligne de contexte d'un fichier exporté : d'où il vient.
#[tauri::command]
pub fn export_context(
    state: State<'_, AppState>,
    window: String,
    detail: String,
) -> Result<String, String> {
    let _conn = state.database()?;
    Ok(radinus_core::i18n::message_of(
        ui_language(),
        "export-context",
        &[("window", &window), ("detail", &detail)],
        &[],
    ))
}

/// Ouvre la statistique d'un axe sur les comptes choisis.
#[tauri::command]
pub fn open_statistics<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    axis: String,
    account_ids: Vec<i64>,
) -> Result<(), String> {
    let axis = statistics_axis(&axis)?;
    let language = window_language(&state);
    let accounts = account_ids
        .iter()
        .map(|id| id.to_string())
        .collect::<Vec<_>>()
        .join(",");
    crate::windows::open(
        &app,
        &crate::windows::statistics_window(language, axis),
        Some(&format!("accounts={accounts}")),
    )
    .map_err(to_ipc_error)
}

/// Quitte F20. Masquée, jamais détruite, comme toutes les fenêtres.
#[tauri::command]
pub fn close_statistics<R: Runtime>(app: AppHandle<R>, axis: String) -> Result<(), String> {
    let axis = statistics_axis(&axis)?;
    if let Some(window) = app.get_webview_window(&format!("statistics-{}", axis.key())) {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(())
}

/// What a combo of the list writes when the user picks a value. `kind` is the
/// nomenclature's key, as everywhere else.
#[tauri::command]
pub fn set_operation_nomenclature<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    id: i64,
    kind: String,
    value: i64,
) -> Result<bool, String> {
    let kind = nomenclature(&kind)?;
    let conn = state.database()?;
    let changed =
        radinus_core::operations::set_nomenclature(&conn, id, kind, value).map_err(to_ipc_error)?;
    drop(conn);
    operations_changed(&app);
    Ok(changed)
}

/// **La colonne « Statut opération » de F02** (Fabrice, 01/10/2026).
///
/// La règle de date est celle du noyau (`operations::set_status`) : pointé
/// pose la date de l'opération si la date de pointage est vide, et ne touche
/// jamais une date déjà là. Prévient les fenêtres, comme toute écriture
/// d'opération.
#[tauri::command]
pub fn set_operation_status<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    id: i64,
    status_id: i64,
) -> Result<bool, String> {
    let conn = state.database()?;
    let changed =
        radinus_core::operations::set_status(&conn, id, status_id).map_err(to_ipc_error)?;
    drop(conn);
    operations_changed(&app);
    Ok(changed)
}

/// **La colonne « Vérification » de F02** (Fabrice, 03/10/2026).
///
/// Ce que l'utilisateur pense de l'écriture, à côté du statut. Rien d'autre
/// n'est touché — ni statut, ni date, ni solde — mais les fenêtres sont
/// prévenues, comme pour toute écriture d'opération.
#[tauri::command]
pub fn set_operation_verification<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    id: i64,
    verification_id: i64,
) -> Result<bool, String> {
    let conn = state.database()?;
    let changed = radinus_core::operations::set_verification(&conn, id, verification_id)
        .map_err(to_ipc_error)?;
    drop(conn);
    operations_changed(&app);
    Ok(changed)
}

/// **Le menu du clic droit de F02** : le même statut à toute la sélection,
/// d'un coup (Fabrice, 03/10/2026). Les règles de date sont celles du noyau,
/// et aucune phrase n'est rendue — comme pour la vérification, juste en
/// dessous : le tableau relu est la confirmation.
#[tauri::command]
pub fn set_operations_status<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    ids: Vec<i64>,
    status_id: i64,
) -> Result<usize, String> {
    let mut conn = state.database()?;
    let changed = radinus_core::operations::set_status_many(&mut conn, &ids, status_id)
        .map_err(to_ipc_error)?;
    drop(conn);
    operations_changed(&app);
    Ok(changed)
}

/// **Le menu du clic droit de F02** : la même vérification à toute la
/// sélection, d'un coup (Fabrice, 03/10/2026).
///
/// Rend le nombre d'opérations qui ont changé. La fenêtre n'en fait pas une
/// phrase — « je ne pense pas qu'il soit nécessaire de faire une phrase » : le
/// tableau se relit et les couleurs changent sous les yeux, c'est la
/// confirmation.
#[tauri::command]
pub fn set_operations_verification<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    ids: Vec<i64>,
    verification_id: i64,
) -> Result<usize, String> {
    let mut conn = state.database()?;
    let changed = radinus_core::operations::set_verification_many(&mut conn, &ids, verification_id)
        .map_err(to_ipc_error)?;
    drop(conn);
    operations_changed(&app);
    Ok(changed)
}

// --- F19 — le tableau de bord --------------------------------------------

/// **Les trois interrupteurs du tableau de bord, et eux seuls.**
///
/// Il n'en a pas cinq : il sépare lui-même les débits des gains, donc les deux
/// interrupteurs de signe des statistiques n'ont aucun sens ici. La fenêtre
/// envoyait donc trois booléens à une structure qui en réclamait cinq, et
/// `serde` refusait l'appel avant même qu'il n'arrive — **le tableau de bord
/// s'ouvrait entièrement vide** (signalé par Fabrice, 26/07/2026). Un type qui
/// dit exactement ce que cette fenêtre a rend la faute impossible à refaire.
#[derive(serde::Deserialize)]
pub struct DashboardSwitchesInput {
    pub pointed: bool,
    pub committed: bool,
    pub planned: bool,
}

impl From<DashboardSwitchesInput> for radinus_core::statistics::Switches {
    fn from(input: DashboardSwitchesInput) -> Self {
        Self {
            pointed: input.pointed,
            committed: input.committed,
            planned: input.planned,
            // Le tableau de bord compte les deux sens : ce sont ses deux
            // anneaux qui les séparent, pas un interrupteur.
            debits: true,
            credits: true,
        }
    }
}

#[derive(Serialize)]
pub struct SliceDto {
    pub id: i64,
    pub label: String,
    pub amount: i64,
    pub text: String,
}

/// Un point de la courbe du cumul (troisième niveau de l'accueil et de F19).
#[derive(Serialize)]
pub struct PointDto {
    /// La date en ISO. La fenêtre la porte au survol ; **elle ne calcule
    /// aucune date et n'en tire aucun mot**.
    pub day: String,
    pub amount: i64,
    /// Le cumul tel qu'il s'écrit, avec ses séparateurs et sa devise.
    pub text: String,
    /// Ce qui s'écrit sous l'axe à ce point : un quantième — « 5 » — quand la
    /// courbe va de jour en jour, le nom du mois quand elle va de mois en mois.
    ///
    /// **Écrit ici et nulle part ailleurs.** Un nom de mois est une phrase, et
    /// une fenêtre de Radinus n'en contient aucune ; un quantième sans zéro de
    /// tête est une mise en forme, et la fenêtre n'en fait pas non plus. Le
    /// noyau dit lequel des deux par `whole_month`, le contrôleur l'écrit, la
    /// fenêtre le pose.
    pub label: String,
}

/// Un point de courbe prêt pour la fenêtre : son cumul écrit, et le mot de
/// l'axe.
///
/// **Partagé par l'accueil et le tableau de bord**, et c'est la raison d'être
/// de cette fonction : deux courbes qui écriraient leur axe par deux chemins
/// finiraient par ne plus l'écrire pareil, et la même catégorie sur le même
/// mois se lirait différemment d'une fenêtre à l'autre.
///
/// **Le quantième est lu, pas calculé** : deux caractères de la date ISO, sans
/// passer par un objet date. Le nom du mois, lui, vient du noyau, qui est le
/// seul endroit de Radinus où les douze mois sont nommés.
fn point(step: &radinus_core::dashboard::DayPoint, language: Language) -> PointDto {
    let label = if step.whole_month {
        radinus_core::domain::NaiveDate::parse_from_str(&step.day, "%Y-%m-%d")
            .map(|date| radinus_core::i18n::month_name(language, date))
            .unwrap_or_default()
    } else {
        step.day
            .get(8..10)
            .map(|two| two.trim_start_matches('0').to_string())
            .unwrap_or_default()
    };
    PointDto {
        day: step.day.clone(),
        amount: step.amount,
        text: radinus_core::money::format(step.amount, language),
        label,
    }
}

#[derive(Serialize)]
pub struct DashboardDto {
    pub spending: Vec<SliceDto>,
    pub earning: Vec<SliceDto>,
    /// L'en-tête de chaque carte : « Postes budgétaires », « Catégories », ou
    /// le nom de la catégorie à la courbe. **C'est lui qui dit à quel niveau on
    /// est**, depuis que les deux titres ont été raccourcis en « Dépenses » et
    /// « Gains » (Fabrice, 04/08/2026) — sans quoi une carte annoncerait des
    /// postes budgétaires en montrant des catégories.
    pub spending_legend: String,
    pub earning_legend: String,
    /// Le texte du lien qui remonte d'un niveau, ou `null` tout en haut. C'est
    /// le nom du niveau où l'on va, pas une phrase de plus.
    pub spending_back: Option<String>,
    pub earning_back: Option<String>,
    /// Où en est chaque carte dans sa descente. La fenêtre les renvoie tels
    /// quels au coup suivant : c'est ainsi qu'on **reste où l'on est** en
    /// changeant de période ou en éteignant un statut (décision de Fabrice,
    /// 04/08/2026).
    pub spending_line: Option<i64>,
    pub spending_category: Option<i64>,
    pub earning_line: Option<i64>,
    pub earning_category: Option<i64>,
    /// La courbe du cumul, au troisième niveau. Vide autrement.
    pub spending_curve: Vec<PointDto>,
    pub earning_curve: Vec<PointDto>,
    pub debits: String,
    pub credits: String,
    pub balance: String,
    /// La balance en micro-unités : la fenêtre n'a besoin que de son signe,
    /// pour peindre la carte en rouge foncé. Elle ne relit jamais un montant
    /// dans le texte qu'on lui a donné.
    pub balance_value: i64,
    pub accounts: String,
}

/// Le tableau de bord d'une période, pour les comptes choisis.
///
/// **Les deux anneaux se creusent, comme ceux de l'accueil** (Fabrice,
/// 04/08/2026) : un clic sur un poste budgétaire montre ses catégories, un clic
/// sur une catégorie laisse la place à la courbe de son cumul. Le niveau
/// regardé **arrive dans les paramètres et repart dans la réponse** — c'est
/// ainsi qu'on reste où l'on est en changeant de période ou en éteignant un
/// statut, et c'est ce que le noyau a réellement dessiné qui fait foi, pas ce
/// que la fenêtre croyait avoir demandé.
#[tauri::command]
#[allow(clippy::too_many_arguments)]
pub fn dashboard(
    state: State<'_, AppState>,
    account_ids: Vec<i64>,
    from: String,
    to: String,
    switches: DashboardSwitchesInput,
    spending_line: Option<i64>,
    spending_category: Option<i64>,
    earning_line: Option<i64>,
    earning_category: Option<i64>,
) -> Result<DashboardDto, String> {
    let conn = state.database()?;
    let language = ui_language();
    let unclassified = radinus_core::i18n::text(language, "dashboard-unclassified");
    let switches: radinus_core::statistics::Switches = switches.into();
    let shown = radinus_core::dashboard::dashboard(
        &conn,
        &account_ids,
        &from,
        &to,
        switches,
        &unclassified,
    )
    .map_err(to_ipc_error)?;

    // Les bornes en dates, pour la courbe. **Une borne illisible n'est pas une
    // erreur ici** : la fenêtre les tient de ses deux champs, elle vient de les
    // envoyer au noyau qui les a acceptées, et une carte sans courbe vaut mieux
    // qu'un tableau de bord en panne.
    let bound = |text: &str| radinus_core::domain::NaiveDate::parse_from_str(text, "%Y-%m-%d").ok();

    // Le creusement, exactement comme à l'accueil : la lecture d'ensemble est
    // faite dans tous les cas, et les deux descentes ne sont demandées que si
    // elles servent.
    let deeper = |line: Option<i64>| -> Result<Option<radinus_core::dashboard::Dashboard>, String> {
        match line {
            None => Ok(None),
            Some(line) => radinus_core::dashboard::inside_budget_line(
                &conn,
                &account_ids,
                &from,
                &to,
                switches,
                &unclassified,
                line,
            )
            .map(Some)
            .map_err(to_ipc_error),
        }
    };
    let spending_slices = match deeper(spending_line)? {
        Some(inside) => inside.spending,
        None => shown.spending,
    };
    let earning_slices = match deeper(earning_line)? {
        Some(inside) => inside.earning,
        None => shown.earning,
    };

    let curve = |category: Option<i64>, debits: bool| -> Result<Vec<PointDto>, String> {
        let (Some(category), Some(first), Some(last)) = (category, bound(&from), bound(&to)) else {
            return Ok(Vec::new());
        };
        let steps = radinus_core::dashboard::category_running_total(
            &conn,
            &account_ids,
            first,
            last,
            switches,
            category,
            debits,
        )
        .map_err(to_ipc_error)?;
        Ok(steps.iter().map(|step| point(step, language)).collect())
    };

    // Le nom de la catégorie regardée. Une catégorie supprimée depuis n'a plus
    // de nom : l'en-tête retombe alors sur celui de la part « sans », comme à
    // l'accueil.
    let named = |category: Option<i64>| -> Result<Option<String>, String> {
        let Some(category) = category else {
            return Ok(None);
        };
        let found = radinus_core::nomenclatures::list(
            &conn,
            radinus_core::nomenclatures::Nomenclature::Category,
        )
        .map_err(to_ipc_error)?
        .into_iter()
        .find(|element| element.id == category)
        .map(|element| element.label)
        .unwrap_or_else(|| unclassified.clone());
        Ok(Some(found))
    };

    let budget_lines = radinus_core::i18n::text(language, "ui-legend-budget-lines");
    let categories = radinus_core::i18n::text(language, "ui-legend-categories");
    let legend_of = |line: Option<i64>, category: Option<i64>, name: Option<&String>| {
        match (category, name) {
            (Some(_), Some(label)) => label.clone(),
            (Some(_), None) => categories.clone(),
            _ if line.is_some() => categories.clone(),
            _ => budget_lines.clone(),
        }
    };
    let back_of = |line: Option<i64>, category: Option<i64>| match (category, line) {
        (Some(_), _) => Some(categories.clone()),
        (None, Some(_)) => Some(budget_lines.clone()),
        _ => None,
    };
    let spending_name = named(spending_category)?;
    let earning_name = named(earning_category)?;

    let slice = |part: &radinus_core::dashboard::Slice| SliceDto {
        id: part.id,
        label: part.label.clone(),
        amount: part.amount,
        text: radinus_core::money::format(part.amount, language),
    };

    Ok(DashboardDto {
        spending: spending_slices.iter().map(slice).collect(),
        earning: earning_slices.iter().map(slice).collect(),
        spending_legend: legend_of(spending_line, spending_category, spending_name.as_ref()),
        earning_legend: legend_of(earning_line, earning_category, earning_name.as_ref()),
        spending_back: back_of(spending_line, spending_category),
        earning_back: back_of(earning_line, earning_category),
        spending_line,
        spending_category,
        earning_line,
        earning_category,
        spending_curve: curve(spending_category, true)?,
        earning_curve: curve(earning_category, false)?,
        debits: radinus_core::money::format(shown.debits, language),
        credits: radinus_core::money::format(shown.credits, language),
        balance: radinus_core::money::format(shown.balance, language),
        balance_value: shown.balance,
        accounts: radinus_core::i18n::message_of(
            language,
            "statistics-accounts",
            &[],
            &[("count", account_ids.len() as i64)],
        ),
    })
}

/// **Les quatre opérations techniques, visant une base de la liste.**
///
/// Elles étaient dans le menu général et ne pouvaient viser que la base
/// ouverte ; elles sont dans le menu Outils de la fenêtre des bases depuis le
/// 04/08/2026, et `path` désigne **la ligne sélectionnée**, ouverte ou non.
///
/// Chacune part sur son propre fil et rend la main aussitôt : elles ouvrent un
/// sélecteur de fichiers, posent des questions et écrivent des mégaoctets. Les
/// attendre figerait la fenêtre qui les a lancées.
/// **`password` est `None` neuf fois sur dix** : la base visée n'est pas
/// protégée, ou bien c'est celle qui est ouverte et sa connexion est déjà
/// déverrouillée. La fenêtre des bases demande [`database_needs_password`]
/// avant d'appeler, et ne réclame la clé que si le fichier résiste.
#[tauri::command]
pub fn backup_database<R: Runtime>(app: AppHandle<R>, path: String, password: Option<String>) {
    crate::database_operations::backup(app, path, password);
}

/// **Sauvegarder la base ouverte, et attendre qu'elle le soit.**
///
/// Celle du dessus vise une ligne de la fenêtre des bases et rend la main
/// aussitôt. Celle-ci vise la base en cours et **ne rend la main qu'une fois
/// l'archive écrite et relue** : elle est appelée par l'importation Excel, qui
/// propose le filet avant de sauter et n'a aucune raison de sauter avant qu'il
/// soit tendu.
///
/// L'attente a lieu sur un fil de travail : le sélecteur de fichiers et
/// l'écriture n'ont rien à faire sur le fil principal, et un dialogue ouvert
/// depuis celui-ci fige l'application sur macOS.
#[tauri::command]
pub async fn backup_open_database<R: Runtime>(app: AppHandle<R>) -> Result<(), String> {
    tauri::async_runtime::spawn_blocking(move || crate::database_operations::backup_open(&app))
        .await
        .map_err(|error| error.to_string())?
}

#[tauri::command]
pub fn restore_database<R: Runtime>(app: AppHandle<R>, path: String, password: Option<String>) {
    crate::database_operations::restore(app, path, password);
}

#[tauri::command]
pub fn repair_database<R: Runtime>(app: AppHandle<R>, path: String, password: Option<String>) {
    crate::database_operations::repair(app, path, password);
}

/// Le journal du dernier traitement technique.
///
/// **Il n'a pas de base pour cible, et c'est assumé** (Fabrice, 04/08/2026,
/// prévenu) : ce n'est pas l'historique d'une base mais le compte rendu de la
/// dernière sauvegarde, restauration ou réparation, gardé en mémoire vive. Il
/// est dans le menu Outils comme les trois autres ; il ne suit simplement pas
/// la ligne sélectionnée, parce qu'il ne suit aucune base.
#[tauri::command]
pub fn open_operations_journal<R: Runtime>(app: AppHandle<R>) {
    crate::database_operations::open_journal(&app);
}

/// Ouvre F19 sur les comptes choisis.
#[tauri::command]
pub fn open_dashboard<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    account_ids: Vec<i64>,
) -> Result<(), String> {
    let language = window_language(&state);
    let accounts = account_ids
        .iter()
        .map(|id| id.to_string())
        .collect::<Vec<_>>()
        .join(",");
    crate::windows::open(
        &app,
        &crate::windows::dashboard_window(language),
        Some(&format!("accounts={accounts}")),
    )
    .map_err(to_ipc_error)
}

/// Quitte F19. Masquée, jamais détruite, comme toutes les fenêtres.
#[tauri::command]
pub fn close_dashboard<R: Runtime>(app: AppHandle<R>) -> Result<(), String> {
    if let Some(window) = app.get_webview_window("dashboard") {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(())
}

// --- F25 — l'évolution du solde ------------------------------------------

#[derive(Serialize)]
pub struct StepDto {
    /// Le jour, en ISO : la fenêtre le place sur son axe et le remet en forme
    /// pour l'infobulle.
    pub date: String,
    pub value: i64,
    pub text: String,
}

#[derive(Serialize)]
pub struct CurveDto {
    pub account_id: i64,
    pub label: String,
    pub steps: Vec<StepDto>,
    pub is_total: bool,
}

#[derive(Serialize)]
pub struct CurvesDto {
    pub curves: Vec<CurveDto>,
    pub lowest: i64,
    pub highest: i64,
    /// Le millésime à afficher, **selon la norme ISO 8601** quand la période
    /// enjambe deux années : une semaine appartient à l'année de son jeudi
    /// (règle tranchée par Fabrice, 26/07/2026).
    pub year: i32,
}

/// Les courbes d'évolution du solde, pour une période et des comptes.
#[tauri::command]
pub fn balance_curves(
    state: State<'_, AppState>,
    account_ids: Vec<i64>,
    from: String,
    to: String,
) -> Result<CurvesDto, String> {
    let conn = state.database()?;
    let language = ui_language();
    let first = parse_day(&from)?;
    let last = parse_day(&to)?;

    let built = radinus_core::balance_curve::balance_curves(
        &conn,
        &account_ids,
        first,
        last,
        &radinus_core::i18n::text(language, "curve-total"),
    )
    .map_err(to_ipc_error)?;

    Ok(CurvesDto {
        curves: built
            .curves
            .iter()
            .map(|curve| CurveDto {
                account_id: curve.account_id,
                label: curve.label.clone(),
                steps: curve
                    .steps
                    .iter()
                    .map(|step| StepDto {
                        date: step.date.to_string(),
                        value: step.value,
                        text: radinus_core::money::format(step.value, language),
                    })
                    .collect(),
                is_total: curve.is_total,
            })
            .collect(),
        lowest: built.lowest,
        highest: built.highest,
        year: radinus_core::balance_curve::year_of(first, last),
    })
}

fn parse_day(text: &str) -> Result<radinus_core::domain::NaiveDate, String> {
    text.parse()
        .map_err(|_| format!("date illisible : {text}"))
}

/// Décale une période d'un an, ou la porte sur une autre année.
///
/// **Une semaine reste une semaine** (règle de Fabrice, 26/07/2026) : le
/// numéro de semaine ISO est conservé plutôt que d'ajouter douze mois aux deux
/// dates, ce qui ferait tomber un lundi sur un mardi. Et la semaine 53 d'une
/// année qui n'en a que 52 devient la 52 — on impose, on ne rejette pas.
#[tauri::command]
pub fn shift_period(
    state: State<'_, AppState>,
    from: String,
    to: String,
    by: i32,
    onto: Option<i32>,
) -> Result<PeriodDto, String> {
    let _ = state;
    let first = parse_day(&from)?;
    let last = parse_day(&to)?;
    let (moved_from, moved_to) = radinus_core::balance_curve::shift_period(first, last, by, onto);
    Ok(PeriodDto {
        from: moved_from.to_string(),
        to: moved_to.to_string(),
        year: radinus_core::balance_curve::year_of(moved_from, moved_to),
    })
}

#[derive(Serialize)]
pub struct PeriodDto {
    pub from: String,
    pub to: String,
    pub year: i32,
}

/// Ouvre F25 sur les comptes choisis.
#[tauri::command]
pub fn open_balance_curves<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    account_ids: Vec<i64>,
) -> Result<(), String> {
    let language = window_language(&state);
    let accounts = account_ids
        .iter()
        .map(|id| id.to_string())
        .collect::<Vec<_>>()
        .join(",");
    crate::windows::open(
        &app,
        &crate::windows::balance_curves_window(language),
        Some(&format!("accounts={accounts}")),
    )
    .map_err(to_ipc_error)
}

/// Quitte F25. Masquée, jamais détruite, comme toutes les fenêtres.
#[tauri::command]
pub fn close_balance_curves<R: Runtime>(app: AppHandle<R>) -> Result<(), String> {
    if let Some(window) = app.get_webview_window("balance-curves") {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(())
}

// --- F40, « Analyse Évolution du solde » ----------------------------------
//
// Le graphique de F25, sur lequel on trace une zone, et dessous les opérations
// de cette zone (Fabrice, 05/10/2026). Les courbes viennent de la commande de
// F25 — c'est le même calcul ; ce qui suit est ce que la fenêtre a en plus.

/// Une ligne du tableau de la zone : une opération, et le compte qui la porte.
/// La zone peut couvrir plusieurs comptes, et le tableau doit dire lequel.
#[derive(Serialize)]
pub struct ZoneRowDto {
    #[serde(flatten)]
    pub operation: OperationRowDto,
    pub account: String,
}

/// Ce que la fenêtre montre d'une zone : son résumé, déjà écrit en monnaie, et
/// ses opérations.
#[derive(Serialize)]
pub struct ZoneDto {
    pub opening: String,
    pub closing: String,
    pub variation: String,
    pub debit: String,
    pub credit: String,
    /// La variation en micro-unités : la fenêtre s'en sert pour la teinter,
    /// rouge quand le solde a baissé.
    pub variation_value: i64,
    pub rows: Vec<ZoneRowDto>,
}

/// **Ce qui s'est passé entre deux dates** sur les comptes choisis.
///
/// Le résumé et les lignes viennent du même calcul que la courbe : la
/// variation annoncée est la somme des opérations montrées.
#[tauri::command]
pub fn balance_zone(
    state: State<'_, AppState>,
    account_ids: Vec<i64>,
    from: String,
    to: String,
) -> Result<ZoneDto, String> {
    let conn = state.database()?;
    let language = ui_language();
    let found = radinus_core::balance_curve::zone(
        &conn,
        &account_ids,
        parse_day(&from)?,
        parse_day(&to)?,
    )
    .map_err(to_ipc_error)?;

    let months = month_names(language);
    let money = |amount: i64| radinus_core::money::format(amount, language);
    Ok(ZoneDto {
        opening: money(found.opening),
        closing: money(found.closing),
        variation: money(found.variation()),
        debit: money(found.debit),
        credit: money(found.credit),
        variation_value: found.variation(),
        rows: found
            .operations
            .iter()
            .map(|entry| ZoneRowDto {
                // Une mère, toujours : ni mère au-dessus d'elle, ni filles
                // montrées dessous.
                operation: as_row(&entry.operation, 0, 0, language, &months),
                account: entry.account_label.clone(),
            })
            .collect(),
    })
}

/// Ouvre F40 sur les comptes choisis.
#[tauri::command]
pub fn open_balance_analysis<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    account_ids: Vec<i64>,
) -> Result<(), String> {
    let language = window_language(&state);
    let accounts = account_ids
        .iter()
        .map(|id| id.to_string())
        .collect::<Vec<_>>()
        .join(",");
    crate::windows::open(
        &app,
        &crate::windows::balance_analysis_window(language),
        Some(&format!("accounts={accounts}")),
    )
    .map_err(to_ipc_error)
}

/// Quitte F40. Masquée, jamais détruite, comme toutes les fenêtres.
#[tauri::command]
pub fn close_balance_analysis<R: Runtime>(app: AppHandle<R>) -> Result<(), String> {
    if let Some(window) = app.get_webview_window("balance-analysis") {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(())
}

// --- F41, la simulation de crédit (Fabrice, 08/10/2026) --------------------
//
// Le noyau calcule et écrit tout (`loan`, `loan_report`, `loan_charts`) ; le
// contrôleur lit les champs tels que la fenêtre les a, et rend ce qu'elle
// montre. Rien n'est enregistré : « une calculette, rien d'enregistré ».

/// Ce que la fenêtre envoie : les champs **tels qu'ils sont tapés**, lus ici
/// dans la langue en cours — une virgule en français, un point en anglais.
#[derive(serde::Deserialize)]
pub struct LoanRequestDto {
    pub kind: String,
    pub amount: String,
    pub payment: String,
    pub months: String,
    pub rate: String,
    pub fees: String,
    pub insurance: String,
    /// `amount`, `payment`, `months`, ou autre chose.
    pub moved: String,
    pub accounts: Vec<i64>,
    /// `last-12`, une année, ou `range` — la plage d'années (10/10/2026),
    /// avec ses deux bornes.
    pub history: String,
    #[serde(default)]
    pub from: i32,
    #[serde(default)]
    pub to: i32,
    /// La méthode de jugement retenue : `optimistic`, `neutral`, `severe`.
    #[serde(default)]
    pub method: String,
    /// La hausse des dépenses par an de chacune des trois, telle que tapée.
    #[serde(default)]
    pub growth: Vec<String>,
}

/// Lit les champs. Rend le nom du premier qui ne se lit pas.
fn loan_request(asked: &LoanRequestDto) -> Result<radinus_core::loan_report::Request, &'static str> {
    use radinus_core::money::{parse, parse_or_zero};
    let kind = radinus_core::loan::Kind::from_key(&asked.kind);
    let amount = parse(&asked.amount).map_err(|_| "amount")?;
    let months: u32 = asked.months.trim().parse().map_err(|_| "months")?;
    let rate = parse(&asked.rate).map_err(|_| "rate")?;
    let fees = parse_or_zero(&asked.fees).map_err(|_| "fees")?;
    let insurance = parse_or_zero(&asked.insurance).map_err(|_| "insurance")?;
    let moved = radinus_core::loan::Moved::from_key(&asked.moved);
    // La mensualité ne compte que si c'est elle qui a bougé : ailleurs, elle
    // se recalcule et son champ n'est qu'un affichage.
    let wished_payment = if moved == radinus_core::loan::Moved::Payment {
        parse(&asked.payment).map_err(|_| "payment")?
    } else {
        0
    };
    if amount < 0 || rate < 0 || fees < 0 || insurance < 0 || wished_payment < 0 {
        return Err(match () {
            _ if amount < 0 => "amount",
            _ if rate < 0 => "rate",
            _ if fees < 0 => "fees",
            _ if insurance < 0 => "insurance",
            _ => "payment",
        });
    }
    // **La hausse des dépenses**, un entier de 0 à 99 par méthode (Fabrice,
    // 08/10/2026 : « un champ texte numérique, supérieur ou égal à 0 […] il
    // ira de 0 à 99 »). Un champ vide garde la valeur de départ.
    let mut judging = radinus_core::loan::Judging {
        chosen: radinus_core::loan::Method::from_key(&asked.method),
        ..Default::default()
    };
    for (rank, method) in radinus_core::loan::Method::ALL.iter().enumerate() {
        let Some(text) = asked.growth.get(rank) else { continue };
        let text = text.trim();
        if text.is_empty() {
            continue;
        }
        match text.parse::<u32>() {
            Ok(value) if value <= radinus_core::loan::GROWTH_LIMIT => judging.growth[rank] = value,
            _ => {
                return Err(match method {
                    radinus_core::loan::Method::Optimistic => "growth-optimistic",
                    radinus_core::loan::Method::Neutral => "growth-neutral",
                    radinus_core::loan::Method::Severe => "growth-severe",
                })
            }
        }
    }
    Ok(radinus_core::loan_report::Request {
        judging,
        terms: radinus_core::loan::Terms { kind, amount, rate, months, fees, insurance },
        wished_payment,
        moved,
        accounts: asked.accounts.clone(),
        history: radinus_core::loan::Period::from_keys(&asked.history, asked.from, asked.to),
    })
}

#[derive(Serialize, Default)]
pub struct LoanFigureDto {
    pub label: String,
    pub value: String,
    pub tone: String,
}

#[derive(Serialize, Default)]
pub struct LoanDueDto {
    pub number: u32,
    pub date: String,
    pub date_value: String,
    pub payment: String,
    pub interest: String,
    pub capital: String,
    pub insurance: String,
    pub remaining: String,
    pub payment_value: i64,
    pub interest_value: i64,
    pub capital_value: i64,
    pub insurance_value: i64,
    pub remaining_value: i64,
}

#[derive(Serialize, Default)]
pub struct LoanRunningDto {
    pub label: String,
    pub monthly: String,
    pub end: String,
}

/// Une colonne de l'onglet « Réglages du jugement ».
#[derive(Serialize, Default)]
pub struct LoanMethodDto {
    pub key: String,
    pub name: String,
    pub verdict: String,
    pub verdict_word: String,
    pub values: Vec<String>,
    pub growth: u32,
    pub explanation: String,
}

#[derive(Serialize, Default)]
pub struct LoanCheckDto {
    pub tone: String,
    pub text: String,
}

#[derive(Serialize, Default)]
pub struct LoanAnalysisDto {
    pub verdict: String,
    pub verdict_word: String,
    /// Les trois questions du voyant, chacune avec sa couleur (08/10/2026).
    pub checks: Vec<LoanCheckDto>,
    /// La clef de la méthode de jugement retenue.
    pub method_key: String,
    pub method_line: String,
    pub methods: Vec<LoanMethodDto>,
    pub rule_rows: Vec<String>,
    pub rules_intro: String,
    pub verdicts_line: String,
    pub warning: Option<String>,
    pub gauge: String,
    pub figures: Vec<LoanFigureDto>,
    pub income_donut: String,
    pub bars: String,
    pub projection: String,
    pub loans: Vec<LoanRunningDto>,
    pub loans_empty: String,
    pub period: String,
    pub transfers: String,
    pub method: String,
}

/// Tout ce que F41 montre, déjà écrit.
#[derive(Serialize, Default)]
pub struct LoanDto {
    /// Le champ qui ne se lit pas, s'il y en a un : la fenêtre le marque et
    /// garde ce qu'elle montrait. Tout le reste est alors vide.
    pub invalid: Option<String>,
    pub kind: String,
    pub amount_field: String,
    pub payment_field: String,
    pub rate_field: String,
    pub fees_field: String,
    pub insurance_field: String,
    pub months: u32,
    pub months_text: String,
    /// Les trois curseurs, en euros : leurs bornes, leur pas, leur position.
    pub amount_euros: f64,
    pub amount_min: f64,
    pub amount_max: f64,
    pub amount_step: f64,
    pub months_min: u32,
    pub months_max: u32,
    pub payment_euros: f64,
    pub payment_min: f64,
    pub payment_max: f64,
    pub notice: Option<String>,
    pub figures: Vec<LoanFigureDto>,
    pub dues: Vec<LoanDueDto>,
    pub cost_donut: String,
    pub capital_curve: String,
    pub analysis: Option<LoanAnalysisDto>,
    pub unavailable: Option<String>,
}

fn euros_of(micro: i64) -> f64 {
    micro as f64 / radinus_core::money::UNIT as f64
}

fn loan_dto(simulation: &radinus_core::loan_report::Simulation, language: Language) -> LoanDto {
    let written = radinus_core::loan_report::write(simulation, language);
    let terms = &simulation.settled.terms;
    let bounds = terms.kind.bounds();
    let (payment_min, payment_max) = radinus_core::loan::payment_range(terms);
    let figure = |figure: &radinus_core::loan_report::Figure| LoanFigureDto {
        label: figure.label.clone(),
        value: figure.value.clone(),
        tone: figure.tone.to_string(),
    };
    let (analysis, unavailable) = match written.analysis {
        Ok(analysis) => (
            Some(LoanAnalysisDto {
                verdict: analysis.verdict.to_string(),
                verdict_word: analysis.verdict_word,
                checks: analysis
                    .checks
                    .into_iter()
                    .map(|check| LoanCheckDto { tone: check.tone.to_string(), text: check.text })
                    .collect(),
                method_key: simulation
                    .analysis
                    .as_ref()
                    .map(|analysis| analysis.chosen.key().to_string())
                    .unwrap_or_default(),
                method_line: analysis.method_line,
                methods: analysis
                    .methods
                    .into_iter()
                    .map(|method| LoanMethodDto {
                        key: method.key.to_string(),
                        name: method.name,
                        verdict: method.verdict.to_string(),
                        verdict_word: method.verdict_word,
                        values: method.values,
                        growth: method.growth,
                        explanation: method.explanation,
                    })
                    .collect(),
                rule_rows: analysis.rule_rows,
                rules_intro: analysis.rules_intro,
                verdicts_line: analysis.verdicts_line,
                warning: analysis.warning,
                gauge: analysis.gauge,
                figures: analysis.figures.iter().map(figure).collect(),
                income_donut: analysis.income_donut,
                bars: analysis.bars,
                projection: analysis.projection,
                loans: analysis
                    .loans
                    .into_iter()
                    .map(|running| LoanRunningDto {
                        label: running.label,
                        monthly: running.monthly,
                        end: running.end,
                    })
                    .collect(),
                loans_empty: analysis.loans_empty,
                period: analysis.period,
                transfers: analysis.transfers,
                method: analysis.method,
            }),
            None,
        ),
        Err(reason) => (None, Some(reason)),
    };
    LoanDto {
        invalid: None,
        kind: terms.kind.key().to_string(),
        amount_field: written.amount_field,
        payment_field: written.payment_field,
        rate_field: written.rate_field,
        fees_field: written.fees_field,
        insurance_field: written.insurance_field,
        months: written.months,
        months_text: written.months_text,
        amount_euros: euros_of(terms.amount),
        amount_min: euros_of(bounds.amount_min),
        amount_max: euros_of(bounds.amount_max),
        amount_step: euros_of(bounds.amount_step),
        months_min: bounds.months_min,
        months_max: bounds.months_max,
        payment_euros: euros_of(simulation.settled.payment),
        payment_min: euros_of(payment_min).floor(),
        payment_max: euros_of(payment_max).ceil(),
        notice: written.notice,
        figures: written.figures.iter().map(figure).collect(),
        dues: written
            .dues
            .into_iter()
            .map(|due| LoanDueDto {
                number: due.number,
                date: due.date,
                date_value: due.date_value,
                payment: due.payment,
                interest: due.interest,
                capital: due.capital,
                insurance: due.insurance,
                remaining: due.remaining,
                payment_value: due.payment_value,
                interest_value: due.interest_value,
                capital_value: due.capital_value,
                insurance_value: due.insurance_value,
                remaining_value: due.remaining_value,
            })
            .collect(),
        cost_donut: written.cost_donut,
        capital_curve: written.capital_curve,
        analysis,
        unavailable,
    }
}

/// Un compte de la liste à cocher : son nom, sa banque, son solde réel —
/// **jamais son numéro**.
#[derive(Serialize)]
pub struct LoanAccountDto {
    pub id: i64,
    pub label: String,
    pub bank: String,
    pub balance: String,
    pub balance_value: i64,
}

#[derive(Serialize)]
pub struct LoanChoiceDto {
    pub key: String,
    pub label: String,
}

/// Ce que la fenêtre propose : les deux types de crédit et leurs valeurs de
/// départ, les périodes, les comptes ouverts, le signe de la monnaie.
#[derive(Serialize)]
pub struct LoanChoicesDto {
    pub kinds: Vec<LoanChoiceDto>,
    pub histories: Vec<LoanChoiceDto>,
    /// Les années qu'une plage peut prendre.
    pub years: Vec<i32>,
    pub accounts: Vec<LoanAccountDto>,
    pub sign: String,
}

#[tauri::command]
pub fn loan_choices(state: State<'_, AppState>) -> Result<LoanChoicesDto, String> {
    let conn = state.database()?;
    let language = ui_language();
    let today = time_compute::Local::now().date_naive();
    let accounts = radinus_core::accounts::list(&conn)
        .map_err(to_ipc_error)?
        .into_iter()
        .filter(|row| !row.is_closed)
        .map(|row| LoanAccountDto {
            id: row.id,
            label: row.label,
            bank: row.bank,
            balance: radinus_core::money::format(row.balance_real, language),
            balance_value: row.balance_real,
        })
        .collect();
    Ok(LoanChoicesDto {
        kinds: radinus_core::loan::Kind::ALL
            .iter()
            .map(|kind| LoanChoiceDto {
                key: kind.key().to_string(),
                label: radinus_core::i18n::text(language, &format!("loan-kind-{}", kind.key())),
            })
            .collect(),
        histories: radinus_core::loan::History::choices(today)
            .into_iter()
            .map(|history| LoanChoiceDto {
                key: history.key(),
                label: match history {
                    radinus_core::loan::History::LastTwelve => {
                        radinus_core::i18n::text(language, "loan-period-last-12")
                    }
                    radinus_core::loan::History::Year(year) => year.to_string(),
                },
            })
            .collect(),
        years: radinus_core::loan::Period::years(today),
        accounts,
        sign: radinus_core::money::sign(),
    })
}

/// Les valeurs de départ d'un type de crédit, écrites comme dans leurs
/// champs : changer de type y ramène.
#[derive(Serialize)]
pub struct LoanDefaultsDto {
    pub amount: String,
    pub months: String,
    pub rate: String,
    pub fees: String,
    pub insurance: String,
}

#[tauri::command]
pub fn loan_defaults(kind: String) -> LoanDefaultsDto {
    let language = ui_language();
    let terms = radinus_core::loan::Kind::from_key(&kind).defaults();
    LoanDefaultsDto {
        amount: radinus_core::money::format_plain(terms.amount, language),
        months: terms.months.to_string(),
        rate: radinus_core::loan_report::rate_field(terms.rate, language),
        fees: radinus_core::money::format_plain(terms.fees, language),
        insurance: radinus_core::money::format_plain(terms.insurance, language),
    }
}

/// **Le calcul**, à chaque mouvement d'un curseur ou d'un champ.
#[tauri::command]
pub fn loan_simulate(state: State<'_, AppState>, request: LoanRequestDto) -> Result<LoanDto, String> {
    let request = match loan_request(&request) {
        Ok(request) => request,
        Err(field) => {
            return Ok(LoanDto {
                invalid: Some(field.to_string()),
                ..LoanDto::default()
            })
        }
    };
    let conn = state.database()?;
    let today = time_compute::Local::now().date_naive();
    let simulation =
        radinus_core::loan_report::simulate(&conn, &request, today).map_err(to_ipc_error)?;
    Ok(loan_dto(&simulation, ui_language()))
}

/// **Le rapport PDF** : écrit dans le dossier temporaire, puis ouvert par la
/// visionneuse du système, comme tous les états de Radinus — elle offre
/// « Imprimer » et « Enregistrer sous ».
#[tauri::command]
pub fn print_loan_report(
    state: State<'_, AppState>,
    request: LoanRequestDto,
    monthly: bool,
) -> Result<String, String> {
    let language = ui_language();
    let failed = |reason: &str| {
        radinus_core::i18n::text_with(language, "print-failed", "reason", reason)
    };
    let request = loan_request(&request)
        .map_err(|_| radinus_core::i18n::text(language, "loan-invalid-field"))?;
    let conn = state.database()?;
    let today = time_compute::Local::now().date_naive();
    let simulation = radinus_core::loan_report::simulate(&conn, &request, today)
        .map_err(|error| failed(&error.to_string()))?;
    let bytes = radinus_core::loan_report::pdf(&conn, &simulation, language, monthly)
        .map_err(|error| failed(&error.to_string()))?;
    drop(conn);

    let name = format!(
        "{} {}.pdf",
        crate::system::safe_file_name(&radinus_core::i18n::text(language, "loan-report-title")),
        today.format("%Y-%m-%d")
    );
    let file = std::env::temp_dir().join(name);
    std::fs::write(&file, &bytes).map_err(|error| failed(&error.to_string()))?;
    let shown = file.to_string_lossy().to_string();
    match crate::system::open_with_desktop(&file) {
        Ok(()) => Ok(radinus_core::i18n::text_with(language, "print-done", "file", &shown)),
        Err(_) => Ok(radinus_core::i18n::text_with(language, "print-not-opened", "file", &shown)),
    }
}

/// Quitte F41. Masquée, jamais détruite : la simulation en cours est là au
/// retour, tant que Radinus tourne.
#[tauri::command]
pub fn close_loan_simulation<R: Runtime>(app: AppHandle<R>) -> Result<(), String> {
    if let Some(window) = app.get_webview_window("loan-simulation") {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(())
}

// --- F42, la consommation d'un appareil électrique (Fabrice, 09/10/2026) --
//
// « Un résultat honnête : qui tienne compte de la consommation allumée, ou en
// veille, mais aussi coût heure creuse ou heure pleine. » Le noyau lit les
// champs, calcule et écrit (`appliance`) ; le contrôleur passe. Le tarif est
// une préférence de la base, `tarif.electricite` ; les prix changés dans la
// fenêtre ne valent que pour le calcul en cours.

/// L'événement qui dit que le tarif enregistré a changé : la fenêtre de calcul
/// reprend les nouveaux prix.
pub const ELECTRICITY_TARIFF_CHANGED: &str = "electricity-tariff-changed";

/// Le tarif, écrit dans ses champs, et l'unité de ses prix.
#[derive(Serialize)]
pub struct ElectricityTariffDto {
    pub fields: radinus_core::appliance::TariffFields,
    pub price_unit: String,
}

fn electricity_tariff_dto(tariff: &radinus_core::appliance::Tariff) -> ElectricityTariffDto {
    let language = ui_language();
    ElectricityTariffDto {
        fields: radinus_core::appliance::tariff_fields(tariff, language),
        price_unit: radinus_core::i18n::message_of(
            language,
            "appliance-unit-price",
            &[("sign", &radinus_core::money::sign())],
            &[],
        ),
    }
}

/// **Le tarif enregistré**, ou le Tarif Bleu d'EDF tant que rien ne l'est —
/// ou qu'aucune base n'est ouverte : la feuille des préférences est alors
/// grise, mais la réponse ne doit pas échouer.
#[tauri::command]
pub fn electricity_tariff(state: State<'_, AppState>) -> Result<ElectricityTariffDto, String> {
    let tariff = match state.database() {
        Ok(conn) => radinus_core::preferences::electricity_tariff(&conn).map_err(to_ipc_error)?,
        Err(_) => radinus_core::appliance::BLUE_TARIFF,
    };
    Ok(electricity_tariff_dto(&tariff))
}

/// Le Tarif Bleu d'EDF, pour le bouton « Revenir au Tarif Bleu EDF ». Il ne
/// fait que remplir les champs : c'est la disquette qui enregistre.
#[tauri::command]
pub fn electricity_blue_tariff() -> ElectricityTariffDto {
    electricity_tariff_dto(&radinus_core::appliance::BLUE_TARIFF)
}

/// Enregistre le tarif. Un champ illisible est refusé avec sa phrase.
#[tauri::command]
pub fn save_preferences_electricity<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    tariff: radinus_core::appliance::TariffFields,
) -> Result<(), String> {
    let read = radinus_core::appliance::read_tariff(&tariff)
        .map_err(|refusal| refusal.message(ui_language()))?;
    let conn = state.database()?;
    if !radinus_core::preferences::set_electricity_tariff(&conn, &read).map_err(to_ipc_error)? {
        return Err(radinus_core::i18n::text(ui_language(), "appliance-invalid-price"));
    }
    drop(conn);
    let _ = app.emit(ELECTRICITY_TARIFF_CHANGED, ());
    Ok(())
}

/// Ce que la fenêtre envoie : les champs de l'appareil et ceux du contrat,
/// tels qu'ils sont tapés.
#[derive(serde::Deserialize)]
pub struct ApplianceRequestDto {
    pub usage: radinus_core::appliance::UsageFields,
    pub tariff: radinus_core::appliance::TariffFields,
}

/// Le résultat, ou le champ qui l'empêche et pourquoi.
#[derive(Serialize, Default)]
pub struct ApplianceDto {
    pub invalid: Option<String>,
    pub message: Option<String>,
    pub written: Option<radinus_core::appliance::Written>,
}

/// **Le calcul**, à chaque champ validé.
#[tauri::command]
pub fn appliance_compute(request: ApplianceRequestDto) -> ApplianceDto {
    use radinus_core::appliance;
    let language = ui_language();
    let refused = |refusal: appliance::Refusal| ApplianceDto {
        invalid: Some(refusal.field().to_string()),
        message: Some(refusal.message(language)),
        written: None,
    };
    let usage = match appliance::read_usage(&request.usage) {
        Ok(usage) => usage,
        Err(refusal) => return refused(refusal),
    };
    let tariff = match appliance::read_tariff(&request.tariff) {
        Ok(tariff) => tariff,
        Err(refusal) => return refused(refusal),
    };
    match appliance::compute(&usage, &tariff) {
        Ok(bill) => ApplianceDto {
            written: Some(appliance::write(&bill, &tariff, language)),
            ..ApplianceDto::default()
        },
        Err(refusal) => refused(refusal),
    }
}

/// Quitte F42. Masquée, jamais détruite : le calcul en cours est là au retour.
#[tauri::command]
pub fn close_appliance_cost<R: Runtime>(app: AppHandle<R>) -> Result<(), String> {
    if let Some(window) = app.get_webview_window("appliance-cost") {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(())
}

// --- F43, mon matelas de sécurité (Fabrice, 09/10/2026) -------------------
//
// « Si mes revenus s'arrêtaient demain, combien de mois tiendrais-je avec mon
// épargne ? » Le noyau calcule et écrit tout (`cushion`) ; rien n'est
// enregistré, et il n'y a pas de rapport PDF.

/// Un compte du tableau, avec ses deux cases cochées d'office.
#[derive(Serialize)]
pub struct CushionAccountDto {
    pub id: i64,
    pub label: String,
    pub bank: String,
    pub balance: String,
    pub savings: bool,
    pub spending: bool,
}

#[derive(Serialize)]
pub struct CushionChoicesDto {
    pub accounts: Vec<CushionAccountDto>,
    pub histories: Vec<LoanChoiceDto>,
    /// Les années qu'une plage peut prendre.
    pub years: Vec<i32>,
    pub sign: String,
}

/// Les comptes ouverts — nommés par leur libellé seul — et les périodes.
#[tauri::command]
pub fn cushion_choices(state: State<'_, AppState>) -> Result<CushionChoicesDto, String> {
    let conn = state.database()?;
    let language = ui_language();
    let today = time_compute::Local::now().date_naive();
    let mut accounts = Vec::new();
    for row in radinus_core::accounts::list(&conn).map_err(to_ipc_error)? {
        if row.is_closed {
            continue;
        }
        let kind = radinus_core::accounts::get(&conn, row.id)
            .map_err(to_ipc_error)?
            .map_or(0, |account| account.account_type_id);
        let (savings, spending) = radinus_core::cushion::suggested(kind);
        accounts.push(CushionAccountDto {
            id: row.id,
            label: row.label,
            bank: row.bank,
            balance: radinus_core::money::format(row.balance_real, language),
            savings,
            spending,
        });
    }
    Ok(CushionChoicesDto {
        accounts,
        histories: radinus_core::loan::History::choices(today)
            .into_iter()
            .map(|history| LoanChoiceDto {
                key: history.key(),
                label: match history {
                    radinus_core::loan::History::LastTwelve => {
                        radinus_core::i18n::text(language, "loan-period-last-12")
                    }
                    radinus_core::loan::History::Year(year) => year.to_string(),
                },
            })
            .collect(),
        years: radinus_core::loan::Period::years(today),
        sign: radinus_core::money::sign(),
    })
}

/// Ce que la fenêtre envoie : les cases, la période, les catégories
/// décochées, et le revenu de secours tel qu'il est tapé.
#[derive(serde::Deserialize)]
pub struct CushionRequestDto {
    pub savings: Vec<i64>,
    pub spending: Vec<i64>,
    pub history: String,
    #[serde(default)]
    pub from: i32,
    #[serde(default)]
    pub to: i32,
    pub excluded: Vec<i64>,
    pub backup: String,
}

#[derive(Serialize, Default)]
pub struct CushionDto {
    pub invalid: Option<String>,
    pub message: Option<String>,
    pub written: Option<radinus_core::cushion::Written>,
}

/// **Le calcul**, à chaque case cochée et à chaque champ validé.
#[tauri::command]
pub fn cushion_compute(state: State<'_, AppState>, request: CushionRequestDto) -> Result<CushionDto, String> {
    let language = ui_language();
    let Ok(backup) = radinus_core::money::parse_or_zero(&request.backup) else {
        return Ok(CushionDto {
            invalid: Some("backup".to_string()),
            message: Some(radinus_core::i18n::text(language, "cushion-invalid-backup")),
            written: None,
        });
    };
    let asked = radinus_core::cushion::Request {
        savings: request.savings,
        spending: request.spending,
        history: radinus_core::loan::Period::from_keys(&request.history, request.from, request.to),
        excluded: request.excluded,
        backup: backup.max(0),
    };
    let conn = state.database()?;
    let today = time_compute::Local::now().date_naive();
    let unclassified = radinus_core::i18n::about(language, "statistics-unclassified", "category");
    match radinus_core::cushion::analyse(&conn, &asked, today, &unclassified).map_err(to_ipc_error)? {
        Ok(cushion) => Ok(CushionDto {
            written: Some(radinus_core::cushion::write(&cushion, &asked, today, language)),
            ..CushionDto::default()
        }),
        Err(unavailable) => Ok(CushionDto {
            message: Some(radinus_core::i18n::text(language, unavailable.key())),
            ..CushionDto::default()
        }),
    }
}

/// Quitte F43. Masquée, jamais détruite.
#[tauri::command]
pub fn close_safety_cushion<R: Runtime>(app: AppHandle<R>) -> Result<(), String> {
    if let Some(window) = app.get_webview_window("safety-cushion") {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(())
}

// --- F44, Objectif Épargne (Fabrice, 10/10/2026) ---------------------------
//
// « Si je continue au rythme actuel, dans combien de temps aurai-je tel
// solde ? » Trois questions ; le noyau lit l'historique, projette et écrit
// (`savings_goal`). Rien n'est enregistré, pas de rapport PDF.

/// Un compte du tableau. Les livrets et comptes d'épargne partent cochés ;
/// s'il n'y en a aucun, tous les comptes le sont.
#[derive(Serialize)]
pub struct GoalAccountDto {
    pub id: i64,
    pub label: String,
    pub bank: String,
    pub balance: String,
    pub ticked: bool,
}

#[derive(Serialize)]
pub struct GoalChoicesDto {
    pub accounts: Vec<GoalAccountDto>,
    pub histories: Vec<LoanChoiceDto>,
    pub years: Vec<i32>,
    /// Les douze mois, dans la langue, pour la date visée.
    pub months: Vec<String>,
    /// La date visée proposée : dans un an.
    pub month: u32,
    pub year: i32,
    pub sign: String,
}

#[tauri::command]
pub fn goal_choices(state: State<'_, AppState>) -> Result<GoalChoicesDto, String> {
    use time_compute::Datelike;
    let conn = state.database()?;
    let language = ui_language();
    let today = time_compute::Local::now().date_naive();
    let mut accounts = Vec::new();
    for row in radinus_core::accounts::list(&conn).map_err(to_ipc_error)? {
        if row.is_closed {
            continue;
        }
        let kind = radinus_core::accounts::get(&conn, row.id)
            .map_err(to_ipc_error)?
            .map_or(0, |account| account.account_type_id);
        accounts.push(GoalAccountDto {
            id: row.id,
            label: row.label,
            bank: row.bank,
            balance: radinus_core::money::format(row.balance_real, language),
            ticked: radinus_core::cushion::suggested(kind).0,
        });
    }
    if !accounts.iter().any(|account| account.ticked) {
        for account in &mut accounts {
            account.ticked = true;
        }
    }
    let in_a_year = today.checked_add_months(time_compute::Months::new(12)).unwrap_or(today);
    Ok(GoalChoicesDto {
        accounts,
        histories: radinus_core::loan::History::choices(today)
            .into_iter()
            .map(|history| LoanChoiceDto {
                key: history.key(),
                label: match history {
                    radinus_core::loan::History::LastTwelve => {
                        radinus_core::i18n::text(language, "loan-period-last-12")
                    }
                    radinus_core::loan::History::Year(year) => year.to_string(),
                },
            })
            .collect(),
        years: radinus_core::savings_goal::Period::years(today),
        months: (1..=12)
            .filter_map(|month| time_compute::NaiveDate::from_ymd_opt(2026, month, 1))
            .map(|day| radinus_core::i18n::month_name(language, day))
            .collect(),
        month: in_a_year.month(),
        year: in_a_year.year(),
        sign: radinus_core::money::sign(),
    })
}

/// Ce que la fenêtre envoie, les champs tels qu'ils sont tapés.
#[derive(serde::Deserialize)]
pub struct GoalRequestDto {
    pub accounts: Vec<i64>,
    /// `last-12`, une année, ou `range`.
    pub period: String,
    #[serde(default)]
    pub from: i32,
    #[serde(default)]
    pub to: i32,
    /// `when`, `amount` ou `effort`.
    pub question: String,
    pub target: String,
    pub month: u32,
    pub year: String,
    pub rate: String,
    pub extra: String,
}

#[derive(Serialize, Default)]
pub struct GoalDto {
    pub invalid: Option<String>,
    pub message: Option<String>,
    pub written: Option<radinus_core::savings_goal::Written>,
}

/// Lit les champs. Rend le champ fautif et la clef de sa phrase.
fn goal_request(asked: &GoalRequestDto) -> Result<radinus_core::savings_goal::Request, (&'static str, &'static str)> {
    use radinus_core::savings_goal::{Period, Question, RATE_LIMIT};
    let target = || {
        radinus_core::money::parse(&asked.target).map_err(|_| ("target", "goal-invalid-target"))
    };
    let month = || {
        asked
            .year
            .trim()
            .parse::<i32>()
            .ok()
            .and_then(|year| time_compute::NaiveDate::from_ymd_opt(year, asked.month, 1))
            .ok_or(("year", "goal-invalid-date"))
    };
    let question = match asked.question.as_str() {
        "amount" => Question::Amount { month: month()? },
        "effort" => Question::Effort { target: target()?, month: month()? },
        _ => Question::When { target: target()? },
    };
    let rate = if asked.rate.trim().is_empty() {
        0.0
    } else {
        radinus_core::appliance::parse_number(&asked.rate)
            .filter(|rate| *rate <= RATE_LIMIT)
            .ok_or(("rate", "goal-invalid-rate"))?
    };
    let extra = radinus_core::money::parse_or_zero(&asked.extra).map_err(|_| ("extra", "goal-invalid-extra"))?;
    Ok(radinus_core::savings_goal::Request {
        accounts: asked.accounts.clone(),
        period: Period::from_keys(&asked.period, asked.from, asked.to),
        question,
        rate,
        extra,
    })
}

/// **Le calcul**, à chaque case cochée et à chaque champ validé.
#[tauri::command]
pub fn goal_compute(state: State<'_, AppState>, request: GoalRequestDto) -> Result<GoalDto, String> {
    use radinus_core::savings_goal::{self as goal, Unavailable};
    let language = ui_language();
    let refused = |field: &str, key: &str| GoalDto {
        invalid: Some(field.to_string()),
        message: Some(radinus_core::i18n::text(language, key)),
        written: None,
    };
    let asked = match goal_request(&request) {
        Ok(asked) => asked,
        Err((field, key)) => return Ok(refused(field, key)),
    };
    let conn = state.database()?;
    let today = time_compute::Local::now().date_naive();
    let flows = match goal::read(&conn, &asked.accounts, asked.period, today).map_err(to_ipc_error)? {
        Ok(flows) => flows,
        Err(unavailable) => {
            return Ok(GoalDto {
                message: Some(radinus_core::i18n::text(language, unavailable.key())),
                ..GoalDto::default()
            })
        }
    };
    drop(conn);
    match goal::answer(&flows, &asked, today) {
        Ok(answer) => Ok(GoalDto {
            written: Some(goal::write(&flows, &asked, &answer, today, language)),
            ..GoalDto::default()
        }),
        Err(Unavailable::BadDate) => Ok(refused("year", "goal-invalid-date")),
        Err(unavailable) => Ok(GoalDto {
            message: Some(radinus_core::i18n::text(language, unavailable.key())),
            ..GoalDto::default()
        }),
    }
}

/// Quitte F44. Masquée, jamais détruite.
#[tauri::command]
pub fn close_savings_goal<R: Runtime>(app: AppHandle<R>) -> Result<(), String> {
    if let Some(window) = app.get_webview_window("savings-goal") {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(())
}

// --- F45, Et si je réduisais… ? (Fabrice, 10/10/2026) ----------------------
//
// Réduire des postes de dépense, et voir ce que ça change dans le temps. Le
// noyau lit, projette, écrit et compose le rapport (`cutback`). Les
// réductions s'oublient à la fermeture de la fenêtre ; le rapport PDF les
// garde.

/// Un compte du tableau : tous partent cochés.
#[derive(Serialize)]
pub struct CutAccountDto {
    pub id: i64,
    pub label: String,
    pub bank: String,
    pub balance: String,
}

#[derive(Serialize)]
pub struct CutChoicesDto {
    pub accounts: Vec<CutAccountDto>,
    pub histories: Vec<LoanChoiceDto>,
    pub years: Vec<i32>,
    /// Les trois classements : catégories, tiers, postes budgétaires.
    pub axes: Vec<LoanChoiceDto>,
    pub sign: String,
    /// L'aide du tableau, qui nomme la monnaie en vigueur.
    pub hint: String,
}

#[tauri::command]
pub fn cut_choices(state: State<'_, AppState>) -> Result<CutChoicesDto, String> {
    let conn = state.database()?;
    let language = ui_language();
    let today = time_compute::Local::now().date_naive();
    let accounts = radinus_core::accounts::list(&conn)
        .map_err(to_ipc_error)?
        .into_iter()
        .filter(|row| !row.is_closed)
        .map(|row| CutAccountDto {
            id: row.id,
            label: row.label,
            bank: row.bank,
            balance: radinus_core::money::format(row.balance_real, language),
        })
        .collect();
    Ok(CutChoicesDto {
        accounts,
        histories: radinus_core::loan::History::choices(today)
            .into_iter()
            .map(|history| LoanChoiceDto {
                key: history.key(),
                label: match history {
                    radinus_core::loan::History::LastTwelve => {
                        radinus_core::i18n::text(language, "loan-period-last-12")
                    }
                    radinus_core::loan::History::Year(year) => year.to_string(),
                },
            })
            .collect(),
        years: radinus_core::loan::Period::years(today),
        axes: radinus_core::cutback::AXES
            .iter()
            .map(|axis| LoanChoiceDto {
                key: axis.key().to_string(),
                label: radinus_core::i18n::text(language, &format!("cut-axis-{}", axis.key())),
            })
            .collect(),
        sign: radinus_core::money::sign(),
        hint: radinus_core::i18n::message_of(
            language,
            "cut-table-hint",
            &[("sign", &radinus_core::money::sign())],
            &[],
        ),
    })
}

/// Une réduction telle que tapée : sa valeur, et son unité, `percent` ou
/// `amount`.
#[derive(serde::Deserialize)]
pub struct CutDto {
    pub id: i64,
    pub value: String,
    pub unit: String,
}

#[derive(serde::Deserialize)]
pub struct CutRequestDto {
    pub accounts: Vec<i64>,
    pub history: String,
    #[serde(default)]
    pub from: i32,
    #[serde(default)]
    pub to: i32,
    pub axis: String,
    pub cuts: Vec<CutDto>,
    pub years: u32,
    pub rate: String,
    pub target: String,
}

#[derive(Serialize, Default)]
pub struct CutResultDto {
    pub invalid: Option<String>,
    pub message: Option<String>,
    pub written: Option<radinus_core::cutback::Written>,
}

/// Lit les champs. Rend le champ fautif et la clef de sa phrase.
fn cut_request(asked: &CutRequestDto) -> Result<radinus_core::cutback::Request, (String, &'static str)> {
    use radinus_core::cutback::{axis_from_key, Cut, Request};
    let mut cuts = Vec::new();
    for cut in &asked.cuts {
        if cut.value.trim().is_empty() {
            continue;
        }
        let field = || (format!("cut-{}", cut.id), "cut-invalid-cut");
        let read = if cut.unit == "amount" {
            radinus_core::money::parse(&cut.value)
                .ok()
                .filter(|amount| *amount >= 0)
                .map(Cut::Amount)
        } else {
            radinus_core::appliance::parse_number(&cut.value)
                .filter(|percent| *percent <= 100.0)
                .map(Cut::Percent)
        };
        cuts.push((cut.id, read.ok_or_else(field)?));
    }
    let rate = if asked.rate.trim().is_empty() {
        0.0
    } else {
        radinus_core::appliance::parse_number(&asked.rate)
            .filter(|rate| *rate <= radinus_core::savings_goal::RATE_LIMIT)
            .ok_or(("rate".to_string(), "goal-invalid-rate"))?
    };
    let target = if asked.target.trim().is_empty() {
        None
    } else {
        Some(
            radinus_core::money::parse(&asked.target)
                .map_err(|_| ("target".to_string(), "goal-invalid-extra"))?,
        )
    };
    Ok(Request {
        accounts: asked.accounts.clone(),
        period: radinus_core::loan::Period::from_keys(&asked.history, asked.from, asked.to),
        axis: axis_from_key(&asked.axis),
        cuts,
        years: asked.years.clamp(1, radinus_core::cutback::YEARS_LIMIT),
        rate,
        target,
    })
}

/// Lit l'historique et projette ; rend la raison quand il n'y a rien à
/// montrer.
fn cut_read(
    state: &State<'_, AppState>,
    asked: &radinus_core::cutback::Request,
) -> Result<Result<(radinus_core::cutback::Reading, radinus_core::cutback::Outcome), String>, String> {
    let language = ui_language();
    let conn = state.database()?;
    let today = time_compute::Local::now().date_naive();
    let unclassified = radinus_core::i18n::about(language, "statistics-unclassified", asked.axis.key());
    match radinus_core::cutback::read(&conn, asked, today, &unclassified).map_err(to_ipc_error)? {
        Ok(reading) => {
            let outcome = radinus_core::cutback::outcome(&reading, asked, today);
            Ok(Ok((reading, outcome)))
        }
        Err(unavailable) => Ok(Err(radinus_core::i18n::text(language, unavailable.key()))),
    }
}

/// **Le calcul**, à chaque case, champ ou curseur.
#[tauri::command]
pub fn cut_compute(state: State<'_, AppState>, request: CutRequestDto) -> Result<CutResultDto, String> {
    let language = ui_language();
    let asked = match cut_request(&request) {
        Ok(asked) => asked,
        Err((field, key)) => {
            return Ok(CutResultDto {
                invalid: Some(field),
                message: Some(radinus_core::i18n::text(language, key)),
                written: None,
            })
        }
    };
    let today = time_compute::Local::now().date_naive();
    Ok(match cut_read(&state, &asked)? {
        Ok((reading, outcome)) => CutResultDto {
            written: Some(radinus_core::cutback::write(&reading, &asked, &outcome, today, language)),
            ..CutResultDto::default()
        },
        Err(message) => CutResultDto { message: Some(message), ..CutResultDto::default() },
    })
}

/// **Le rapport PDF** : écrit dans le dossier temporaire, puis ouvert par la
/// visionneuse du système, comme tous les états de Radinus.
#[tauri::command]
pub fn print_cut_report(state: State<'_, AppState>, request: CutRequestDto) -> Result<String, String> {
    let language = ui_language();
    let failed = |reason: &str| radinus_core::i18n::text_with(language, "print-failed", "reason", reason);
    let asked = cut_request(&request).map_err(|(_, key)| radinus_core::i18n::text(language, key))?;
    let (reading, outcome) = cut_read(&state, &asked)??;
    let today = time_compute::Local::now().date_naive();
    let conn = state.database()?;
    let bytes = radinus_core::cutback::pdf(&conn, &reading, &asked, &outcome, today, language)
        .map_err(|error| failed(&error.to_string()))?;
    drop(conn);
    let name = format!(
        "{} {}.pdf",
        crate::system::safe_file_name(&radinus_core::i18n::text(language, "window-cut-title")),
        today.format("%Y-%m-%d")
    );
    let file = std::env::temp_dir().join(name);
    std::fs::write(&file, &bytes).map_err(|error| failed(&error.to_string()))?;
    let shown = file.to_string_lossy().to_string();
    match crate::system::open_with_desktop(&file) {
        Ok(()) => Ok(radinus_core::i18n::text_with(language, "print-done", "file", &shown)),
        Err(_) => Ok(radinus_core::i18n::text_with(language, "print-not-opened", "file", &shown)),
    }
}

/// Les libellés des comptes suivis — jamais leur numéro.
fn cut_account_labels(state: &State<'_, AppState>, ids: &[i64]) -> Result<Vec<String>, String> {
    let conn = state.database()?;
    Ok(radinus_core::accounts::list(&conn)
        .map_err(to_ipc_error)?
        .into_iter()
        .filter(|row| ids.contains(&row.id))
        .map(|row| row.label)
        .collect())
}

/// **Le classeur Excel** (Fabrice, 10/10/2026), à l'endroit choisi :
/// « Postes » et « Résultat ».
#[tauri::command]
pub fn export_cut(state: State<'_, AppState>, request: CutRequestDto, path: String) -> Result<String, String> {
    let language = ui_language();
    let asked = cut_request(&request).map_err(|(_, key)| radinus_core::i18n::text(language, key))?;
    let (reading, outcome) = cut_read(&state, &asked)??;
    let names = cut_account_labels(&state, &asked.accounts)?;
    let today = time_compute::Local::now().date_naive();
    let book = radinus_core::cutback::book(&reading, &asked, &outcome, today, &names, language);
    let file = std::path::PathBuf::from(&path);
    radinus_core::sheets::write_book(&book, &file).map_err(|error| {
        radinus_core::i18n::text_with(language, "export-failed", "reason", &error.to_string())
    })?;
    Ok(export_done(language, &file, &path))
}

/// **Enregistre le projet** en JSON, à l'endroit choisi.
#[tauri::command]
pub fn save_cut_project(state: State<'_, AppState>, request: CutRequestDto, path: String) -> Result<String, String> {
    let language = ui_language();
    let asked = cut_request(&request).map_err(|(_, key)| radinus_core::i18n::text(language, key))?;
    let (reading, _) = cut_read(&state, &asked)??;
    let names = cut_account_labels(&state, &asked.accounts)?;
    std::fs::write(&path, radinus_core::cutback::to_file(&reading, &asked, &names)).map_err(|error| {
        radinus_core::i18n::text_with(language, "holiday-file-failed", "reason", &error.to_string())
    })?;
    Ok(radinus_core::i18n::text_with(language, "holiday-file-saved", "file", &file_name_of(&path)))
}

/// Un projet de réduction rouvert : les réglages et les réductions dans la
/// langue en cours, les comptes à recocher, et la phrase qui le dit.
#[derive(Serialize)]
pub struct CutProjectDto {
    #[serde(flatten)]
    pub opened: radinus_core::cutback::Opened,
    pub account_ids: Vec<i64>,
    pub message: String,
}

/// **Rouvre un projet de réduction.** Le sélecteur s'ouvre côté Rust, comme
/// pour les vacances : la fenêtre n'a le droit de lire aucun fichier. `None`
/// si l'utilisateur renonce.
#[tauri::command]
pub async fn load_cut_project<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
) -> Result<Option<CutProjectDto>, String> {
    use tauri_plugin_dialog::DialogExt;
    let language = ui_language();
    let (answered, answer) = std::sync::mpsc::channel();
    app.dialog()
        .file()
        .add_filter(radinus_core::i18n::text(language, "cut-file-filter"), &["json"])
        .pick_file(move |chosen| {
            let _ = answered.send(chosen);
        });
    let Ok(Some(chosen)) = answer.recv() else {
        return Ok(None);
    };
    let path = chosen.into_path().map_err(to_ipc_error)?;
    let text = std::fs::read_to_string(&path).map_err(|error| {
        radinus_core::i18n::text_with(language, "holiday-file-failed", "reason", &error.to_string())
    })?;
    let conn = state.database()?;
    let opened = radinus_core::cutback::from_file(&conn, &text, language)
        .map_err(|refusal| radinus_core::i18n::text(language, refusal.key()))?
        .map_err(to_ipc_error)?;
    let account_ids = radinus_core::accounts::list(&conn)
        .map_err(to_ipc_error)?
        .into_iter()
        .filter(|row| !row.is_closed && opened.accounts.contains(&row.label))
        .map(|row| row.id)
        .collect();
    let shown = file_name_of(&path.to_string_lossy());
    Ok(Some(CutProjectDto {
        opened,
        account_ids,
        message: radinus_core::i18n::text_with(language, "holiday-file-opened", "file", &shown),
    }))
}

/// Quitte F45. Masquée, jamais détruite — mais la fenêtre efface ses
/// réductions en partant (« on oublie les chiffres à la fermeture »).
#[tauri::command]
pub fn close_spending_cut<R: Runtime>(app: AppHandle<R>) -> Result<(), String> {
    if let Some(window) = app.get_webview_window("spending-cut") {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(())
}

// --- F46, Préparer mes vacances (Fabrice, 10/10/2026) ----------------------
//
// « Calculer combien vont me coûter mes prochaines vacances. » Le noyau lit,
// calcule, écrit, compose le PDF, le classeur et le projet en JSON
// (`holiday`). Rien n'entre dans la base ; la fenêtre oublie à la fermeture.

#[derive(Serialize)]
pub struct HolidayAccountDto {
    pub id: i64,
    pub label: String,
    pub bank: String,
    pub balance: String,
}

#[derive(Serialize)]
pub struct HolidayChoicesDto {
    pub accounts: Vec<HolidayAccountDto>,
    pub catalog: Vec<radinus_core::holiday::CatalogLine>,
    pub sign: String,
}

/// Les comptes ouverts, nommés par leur libellé seul, et le catalogue des
/// postes écrit dans la langue.
#[tauri::command]
pub fn holiday_choices(state: State<'_, AppState>) -> Result<HolidayChoicesDto, String> {
    let conn = state.database()?;
    let language = ui_language();
    let accounts = radinus_core::accounts::list(&conn)
        .map_err(to_ipc_error)?
        .into_iter()
        .filter(|row| !row.is_closed)
        .map(|row| HolidayAccountDto {
            id: row.id,
            label: row.label,
            bank: row.bank,
            balance: radinus_core::money::format(row.balance_real, language),
        })
        .collect();
    let sign = radinus_core::money::sign();
    Ok(HolidayChoicesDto {
        accounts,
        catalog: radinus_core::holiday::catalog(language, &sign),
        sign,
    })
}

#[derive(Serialize, Default)]
pub struct HolidayDto {
    pub invalid: Option<String>,
    pub message: Option<String>,
    pub written: Option<radinus_core::holiday::Written>,
}

/// Ce que `holiday_read` rend quand tout se lit.
type HolidayRead = (radinus_core::holiday::Plan, i64, Vec<String>);

/// Le voyage lu, ce que portent les comptes cochés, et leurs libellés — ou le
/// champ refusé, tel que la fenêtre le montre.
fn holiday_read(
    state: &State<'_, AppState>,
    input: &radinus_core::holiday::Input,
    accounts: &[i64],
) -> Result<Result<HolidayRead, HolidayDto>, String> {
    let language = ui_language();
    let plan = match radinus_core::holiday::read(input) {
        Ok(plan) => plan,
        Err(refusal) => {
            return Ok(Err(HolidayDto {
                invalid: Some(refusal.field),
                message: Some(radinus_core::i18n::text(language, refusal.key)),
                written: None,
            }))
        }
    };
    let conn = state.database()?;
    let mut saved = 0;
    let mut names = Vec::new();
    for row in radinus_core::accounts::list(&conn).map_err(to_ipc_error)? {
        if !row.is_closed && accounts.contains(&row.id) {
            saved += row.balance_real;
            names.push(row.label);
        }
    }
    Ok(Ok((plan, saved, names)))
}

/// **Le calcul**, à chaque champ, case ou curseur.
#[tauri::command]
pub fn holiday_compute(
    state: State<'_, AppState>,
    input: radinus_core::holiday::Input,
    accounts: Vec<i64>,
) -> Result<HolidayDto, String> {
    Ok(match holiday_read(&state, &input, &accounts)? {
        Ok((plan, saved, _)) => HolidayDto {
            written: Some(radinus_core::holiday::write(&plan, saved, ui_language())),
            ..HolidayDto::default()
        },
        Err(refused) => refused,
    })
}

/// Le message d'un champ refusé, pour les gestes qui écrivent un fichier.
fn holiday_refused(refused: HolidayDto) -> String {
    refused.message.unwrap_or_default()
}

/// **Le rapport PDF**, ouvert par la visionneuse du système.
#[tauri::command]
pub fn print_holiday_report(
    state: State<'_, AppState>,
    input: radinus_core::holiday::Input,
    accounts: Vec<i64>,
) -> Result<String, String> {
    let language = ui_language();
    let failed = |reason: &str| radinus_core::i18n::text_with(language, "print-failed", "reason", reason);
    let (plan, saved, names) = holiday_read(&state, &input, &accounts)?.map_err(holiday_refused)?;
    let bytes = radinus_core::holiday::pdf(&plan, saved, &names, language)
        .map_err(|error| failed(&error.to_string()))?;
    let today = time_compute::Local::now().date_naive();
    let name = format!(
        "{} {}.pdf",
        crate::system::safe_file_name(&radinus_core::i18n::text(language, "window-holiday-title")),
        today.format("%Y-%m-%d")
    );
    let file = std::env::temp_dir().join(name);
    std::fs::write(&file, &bytes).map_err(|error| failed(&error.to_string()))?;
    let shown = file.to_string_lossy().to_string();
    match crate::system::open_with_desktop(&file) {
        Ok(()) => Ok(radinus_core::i18n::text_with(language, "print-done", "file", &shown)),
        Err(_) => Ok(radinus_core::i18n::text_with(language, "print-not-opened", "file", &shown)),
    }
}

/// **Le classeur Excel**, à l'endroit choisi : « Budget » et « Résultat ».
#[tauri::command]
pub fn export_holiday(
    state: State<'_, AppState>,
    input: radinus_core::holiday::Input,
    accounts: Vec<i64>,
    path: String,
) -> Result<String, String> {
    let language = ui_language();
    let (plan, saved, names) = holiday_read(&state, &input, &accounts)?.map_err(holiday_refused)?;
    let book = radinus_core::holiday::book(&plan, saved, &names, language);
    let file = std::path::PathBuf::from(&path);
    radinus_core::sheets::write_book(&book, &file).map_err(|error| {
        radinus_core::i18n::text_with(language, "export-failed", "reason", &error.to_string())
    })?;
    Ok(export_done(language, &file, &path))
}

fn file_name_of(path: &str) -> String {
    std::path::Path::new(path)
        .file_name()
        .and_then(|name| name.to_str())
        .unwrap_or(path)
        .to_string()
}

/// **Enregistre le projet** en JSON, à l'endroit choisi.
#[tauri::command]
pub fn save_holiday_project(
    state: State<'_, AppState>,
    input: radinus_core::holiday::Input,
    accounts: Vec<i64>,
    path: String,
) -> Result<String, String> {
    let language = ui_language();
    let (plan, _, names) = holiday_read(&state, &input, &accounts)?.map_err(holiday_refused)?;
    std::fs::write(&path, radinus_core::holiday::to_file(&plan, &names)).map_err(|error| {
        radinus_core::i18n::text_with(language, "holiday-file-failed", "reason", &error.to_string())
    })?;
    Ok(radinus_core::i18n::text_with(language, "holiday-file-saved", "file", &file_name_of(&path)))
}

/// Un projet rouvert : les champs dans la langue en cours, les comptes à
/// recocher — ceux qu'on retrouve par leur libellé —, et la phrase qui le dit.
#[derive(Serialize)]
pub struct HolidayProjectDto {
    pub input: radinus_core::holiday::Input,
    pub accounts: Vec<i64>,
    pub message: String,
}

/// **Rouvre un projet.** Le sélecteur du système s'ouvre ici, côté Rust,
/// comme celui des pièces jointes : la fenêtre n'a le droit de lire aucun
/// fichier. `None` si l'utilisateur renonce. Un fichier illisible ou qui n'est
/// pas un projet est refusé avec sa phrase, et la fenêtre ne change pas.
#[tauri::command]
pub async fn load_holiday_project<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
) -> Result<Option<HolidayProjectDto>, String> {
    use tauri_plugin_dialog::DialogExt;
    let language = ui_language();
    let (answered, answer) = std::sync::mpsc::channel();
    app.dialog()
        .file()
        .add_filter(radinus_core::i18n::text(language, "holiday-file-filter"), &["json"])
        .pick_file(move |chosen| {
            let _ = answered.send(chosen);
        });
    let Ok(Some(chosen)) = answer.recv() else {
        return Ok(None);
    };
    let path = chosen.into_path().map_err(to_ipc_error)?;
    let text = std::fs::read_to_string(&path).map_err(|error| {
        radinus_core::i18n::text_with(language, "holiday-file-failed", "reason", &error.to_string())
    })?;
    let (input, labels) = radinus_core::holiday::from_file(&text, language)
        .map_err(|refusal| radinus_core::i18n::text(language, refusal.key()))?;
    let conn = state.database()?;
    let accounts = radinus_core::accounts::list(&conn)
        .map_err(to_ipc_error)?
        .into_iter()
        .filter(|row| !row.is_closed && labels.contains(&row.label))
        .map(|row| row.id)
        .collect();
    let shown = file_name_of(&path.to_string_lossy());
    Ok(Some(HolidayProjectDto {
        input,
        accounts,
        message: radinus_core::i18n::text_with(language, "holiday-file-opened", "file", &shown),
    }))
}

/// Quitte F46. Masquée, jamais détruite — mais la fenêtre efface tout en
/// partant (« on oublie les chiffres »).
#[tauri::command]
pub fn close_holiday<R: Runtime>(app: AppHandle<R>) -> Result<(), String> {
    if let Some(window) = app.get_webview_window("holiday") {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(())
}

// --- F47, Carnet de ma voiture (Fabrice, 10/10/2026) ------------------------
//
// « Quelque chose qui gère l'historique de la voiture. » Le carnet vit côté
// Rust, dans l'état de l'application (`AppState::with_car`) ; le noyau lit,
// compte, écrit, compose le PDF, le classeur et le fichier JSON (`car`). La
// fenêtre envoie ce qu'on tape et montre ce qu'on lui rend. Rien n'entre
// dans la base ni dans les préférences ; la porte oublie le carnet.

/// Le tarif d'électricité des préférences — celui qu'un nouveau carnet
/// reprend. Sans base, le Tarif Bleu.
fn car_preferred_tariff(state: &State<'_, AppState>) -> radinus_core::appliance::Tariff {
    state
        .database()
        .ok()
        .and_then(|conn| radinus_core::preferences::electricity_tariff(&conn).ok())
        .unwrap_or(radinus_core::appliance::BLUE_TARIFF)
}

fn car_today() -> radinus_core::domain::NaiveDate {
    time_compute::Local::now().date_naive()
}

fn with_car<T>(
    state: &State<'_, AppState>,
    act: impl FnOnce(&mut radinus_core::car::Logbook) -> T,
) -> Result<T, String> {
    // Le tarif se lit avant de prendre le carnet : on ne tient jamais les
    // deux verrous à la fois.
    let tariff = car_preferred_tariff(state);
    state.with_car(tariff, act)
}

fn car_written(book: &radinus_core::car::Logbook) -> radinus_core::car::View {
    radinus_core::car::view(book, car_today(), ui_language())
}

/// Ce que rend un geste : le carnet écrit, ou le champ fautif et sa phrase.
#[derive(Serialize)]
pub struct CarResultDto {
    pub invalid: Option<String>,
    pub message: Option<String>,
    pub view: radinus_core::car::View,
}

/// **Le carnet tel qu'il est.**
#[tauri::command]
pub fn car_view(state: State<'_, AppState>) -> Result<radinus_core::car::View, String> {
    with_car(&state, |book| car_written(book))
}

/// **La fiche**, à chaque champ changé.
#[tauri::command]
pub fn car_set_car(
    state: State<'_, AppState>,
    car: radinus_core::car::CarFields,
) -> Result<CarResultDto, String> {
    let language = ui_language();
    with_car(&state, |book| match radinus_core::car::read_car(&car, car_today()) {
        Ok(read) => {
            book.set_car(read);
            CarResultDto { invalid: None, message: None, view: car_written(book) }
        }
        Err(refusal) => CarResultDto {
            invalid: Some(refusal.field.to_string()),
            message: Some(radinus_core::i18n::text(language, refusal.key)),
            view: car_written(book),
        },
    })
}

/// **Ajoute une ligne**, ou remplace celle qu'on modifie.
#[tauri::command]
pub fn car_put_entry(
    state: State<'_, AppState>,
    id: Option<u32>,
    entry: radinus_core::car::EntryFields,
) -> Result<CarResultDto, String> {
    let language = ui_language();
    with_car(&state, |book| match radinus_core::car::read_entry(&entry, &book.car, car_today()) {
        Ok(read) => {
            book.put(id, read);
            CarResultDto { invalid: None, message: None, view: car_written(book) }
        }
        Err(refusal) => CarResultDto {
            invalid: Some(refusal.field.to_string()),
            message: Some(radinus_core::i18n::text(language, refusal.key)),
            view: car_written(book),
        },
    })
}

#[tauri::command]
pub fn car_delete_entry(state: State<'_, AppState>, id: u32) -> Result<radinus_core::car::View, String> {
    with_car(&state, |book| {
        book.remove(id);
        car_written(book)
    })
}

/// Reprend le tarif des préférences — sans y rien écrire.
#[tauri::command]
pub fn car_reset_tariff(state: State<'_, AppState>) -> Result<radinus_core::car::View, String> {
    let tariff = car_preferred_tariff(&state);
    with_car(&state, |book| {
        if book.car.tariff != tariff {
            book.car.tariff = tariff;
            book.unsaved = true;
        }
        car_written(book)
    })
}

/// **Les dépenses d'un compte**, pour remplir une ligne (« oui mais
/// facultatif »).
#[tauri::command]
pub fn car_expenses(state: State<'_, AppState>, account: i64) -> Result<Vec<radinus_core::car::Taken>, String> {
    let conn = state.database()?;
    radinus_core::car::expenses(&conn, account, car_today(), ui_language()).map_err(to_ipc_error)
}

/// **Le dossier PDF** : écrit dans le dossier temporaire, puis ouvert par la
/// visionneuse du système.
#[tauri::command]
pub fn print_car_report(state: State<'_, AppState>) -> Result<String, String> {
    let language = ui_language();
    let failed = |reason: &str| radinus_core::i18n::text_with(language, "print-failed", "reason", reason);
    let (bytes, title) = with_car(&state, |book| {
        (radinus_core::car::pdf(book, car_today(), language), radinus_core::car::title(&book.car, language))
    })?;
    let bytes = bytes.map_err(|error| failed(&error.to_string()))?;
    let name = format!(
        "{} - {} {}.pdf",
        crate::system::safe_file_name(&radinus_core::i18n::text(language, "window-car-title")),
        crate::system::safe_file_name(&title),
        car_today().format("%Y-%m-%d")
    );
    let file = std::env::temp_dir().join(name);
    std::fs::write(&file, &bytes).map_err(|error| failed(&error.to_string()))?;
    let shown = file.to_string_lossy().to_string();
    match crate::system::open_with_desktop(&file) {
        Ok(()) => Ok(radinus_core::i18n::text_with(language, "print-done", "file", &shown)),
        Err(_) => Ok(radinus_core::i18n::text_with(language, "print-not-opened", "file", &shown)),
    }
}

/// **Le classeur Excel**, à l'endroit choisi.
#[tauri::command]
pub fn export_car(state: State<'_, AppState>, path: String) -> Result<String, String> {
    let language = ui_language();
    let book = with_car(&state, |book| radinus_core::car::book(book, car_today(), language))?;
    let file = std::path::PathBuf::from(&path);
    radinus_core::sheets::write_book(&book, &file).map_err(|error| {
        radinus_core::i18n::text_with(language, "export-failed", "reason", &error.to_string())
    })?;
    Ok(export_done(language, &file, &path))
}

/// **Enregistre le carnet** en JSON, à l'endroit choisi.
#[tauri::command]
pub fn save_car_logbook(state: State<'_, AppState>, path: String) -> Result<String, String> {
    let language = ui_language();
    let text = with_car(&state, |book| radinus_core::car::to_file(book))?;
    std::fs::write(&path, text).map_err(|error| {
        radinus_core::i18n::text_with(language, "holiday-file-failed", "reason", &error.to_string())
    })?;
    with_car(&state, |book| book.unsaved = false)?;
    Ok(radinus_core::i18n::text_with(language, "car-file-saved", "file", &file_name_of(&path)))
}

#[derive(Serialize)]
pub struct CarOpenedDto {
    pub view: radinus_core::car::View,
    pub message: String,
}

/// **Rouvre un carnet.** Le sélecteur s'ouvre côté Rust : la fenêtre n'a le
/// droit de lire aucun fichier. `None` si l'on renonce ; un fichier qui
/// n'est pas un carnet est refusé, et le carnet ouvert ne change pas.
#[tauri::command]
pub async fn load_car_logbook<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
) -> Result<Option<CarOpenedDto>, String> {
    use tauri_plugin_dialog::DialogExt;
    let language = ui_language();
    let (answered, answer) = std::sync::mpsc::channel();
    app.dialog()
        .file()
        .add_filter(radinus_core::i18n::text(language, "car-file-filter"), &["json"])
        .pick_file(move |chosen| {
            let _ = answered.send(chosen);
        });
    let Ok(Some(chosen)) = answer.recv() else {
        return Ok(None);
    };
    let path = chosen.into_path().map_err(to_ipc_error)?;
    let text = std::fs::read_to_string(&path).map_err(|error| {
        radinus_core::i18n::text_with(language, "holiday-file-failed", "reason", &error.to_string())
    })?;
    let book = radinus_core::car::from_file(&text).map_err(|refusal| radinus_core::i18n::text(language, refusal.key()))?;
    let view = car_written(&book);
    state.set_car(Some(book))?;
    let shown = file_name_of(&path.to_string_lossy());
    Ok(Some(CarOpenedDto {
        view,
        message: radinus_core::i18n::text_with(language, "car-file-opened", "file", &shown),
    }))
}

/// Quitte F47. Masquée, jamais détruite — et le carnet est oublié : la
/// fenêtre se rouvrira vierge.
#[tauri::command]
pub fn close_car_logbook<R: Runtime>(app: AppHandle<R>, state: State<'_, AppState>) -> Result<(), String> {
    state.set_car(None)?;
    if let Some(window) = app.get_webview_window("car-logbook") {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(())
}

// --- F48, Partager une dépense (Fabrice, 11/10/2026, P-71) -------------------
//
// « Partager une somme avec des contraintes. » Le noyau lit, partage, écrit,
// compose les trois rapports, le classeur et le projet en JSON (`sharing`).
// **Rien ne touche la base** : aucune de ces commandes ne demande l'état, si
// bien que l'outil marche sans base ouverte.

/// Ce que la fenêtre reçoit à chaque calcul : le champ refusé et sa phrase, ou
/// le résultat écrit ; le nom d'une personne qu'on ajouterait ; et les
/// conseils, donnés même quand le partage est refusé (P-72).
#[derive(Serialize, Default)]
pub struct SharingDto {
    pub invalid: Option<String>,
    pub message: Option<String>,
    pub written: Option<radinus_core::sharing::Written>,
    pub next_name: String,
    pub advice: radinus_core::sharing::Advice,
}

/// Lit et partage, ou rend la phrase du refus.
fn sharing_of(input: &radinus_core::sharing::Input) -> Result<radinus_core::sharing::Computed, radinus_core::sharing::Refusal> {
    let language = ui_language();
    let plan = radinus_core::sharing::read(input, language)?;
    radinus_core::sharing::compute(&plan, language)
}

/// **Le calcul**, à chaque champ, case ou ligne.
#[tauri::command]
pub fn sharing_compute(input: radinus_core::sharing::Input) -> SharingDto {
    let language = ui_language();
    let next_name = radinus_core::sharing::next_name(&input, language);
    let advice = radinus_core::sharing::advise(&input, language);
    // Le partage lu garde les cadeaux tels que tapés ; le résultat en fait des
    // montants fixes. Il faut les deux pour écrire le pourcentage tapé.
    let read = radinus_core::sharing::read(&input, language)
        .and_then(|plan| radinus_core::sharing::compute(&plan, language).map(|computed| (plan, computed)));
    match read {
        Ok((plan, computed)) => SharingDto {
            written: Some(radinus_core::sharing::write(&computed, &plan, language)),
            next_name,
            advice,
            ..SharingDto::default()
        },
        Err(refusal) => SharingDto {
            invalid: (!refusal.field.is_empty()).then_some(refusal.field),
            message: Some(refusal.message),
            written: None,
            next_name,
            advice,
        },
    }
}

fn sharing_today() -> radinus_core::domain::NaiveDate {
    time_compute::Local::now().date_naive()
}

/// **Un rapport PDF** — la répartition générale, ou l'état des paiements —,
/// ouvert par la visionneuse du système.
#[tauri::command]
pub fn print_sharing_report(input: radinus_core::sharing::Input, kind: String) -> Result<String, String> {
    let language = ui_language();
    let failed = |reason: &str| radinus_core::i18n::text_with(language, "print-failed", "reason", reason);
    let computed = sharing_of(&input).map_err(|refusal| refusal.message)?;
    let (bytes, title_key) = if kind == "payments" {
        (radinus_core::sharing::payments_pdf(&computed, sharing_today(), language), "sharing-report-payments")
    } else {
        (radinus_core::sharing::distribution_pdf(&computed, language), "sharing-report-distribution")
    };
    let bytes = bytes.map_err(|error| failed(&error.to_string()))?;
    let name = format!(
        "{} - {} {}.pdf",
        crate::system::safe_file_name(&radinus_core::sharing::title_of(&computed.plan, language)),
        crate::system::safe_file_name(&radinus_core::i18n::text(language, title_key)),
        sharing_today().format("%Y-%m-%d")
    );
    let file = std::env::temp_dir().join(name);
    std::fs::write(&file, &bytes).map_err(|error| failed(&error.to_string()))?;
    let shown = file.to_string_lossy().to_string();
    match crate::system::open_with_desktop(&file) {
        Ok(()) => Ok(radinus_core::i18n::text_with(language, "print-done", "file", &shown)),
        Err(_) => Ok(radinus_core::i18n::text_with(language, "print-not-opened", "file", &shown)),
    }
}

/// Les relevés à écrire : le rang du foyer et le nom de son fichier —
/// « <libellé> - <nom>.pdf », un numéro ajouté si deux noms nettoyés se
/// confondent. `unit` vide : tout le monde.
fn sharing_statement_files(
    computed: &radinus_core::sharing::Computed,
    unit: Option<&str>,
    language: Language,
) -> Vec<(usize, String)> {
    let title = crate::system::safe_file_name(&radinus_core::sharing::title_of(&computed.plan, language));
    let mut taken: Vec<String> = Vec::new();
    let mut out = Vec::new();
    for (index, one) in computed.units.iter().enumerate() {
        if unit.is_some_and(|key| key != one.key) {
            continue;
        }
        let base = format!("{title} - {}", crate::system::safe_file_name(&one.name));
        let mut name = format!("{base}.pdf");
        let mut number = 2;
        while taken.contains(&name.to_lowercase()) {
            name = format!("{base} ({number}).pdf");
            number += 1;
        }
        taken.push(name.to_lowercase());
        out.push((index, name));
    }
    out
}

/// Le dossier choisi pour les relevés, et la question à poser si des relevés
/// y existent déjà — une seule fois pour tous.
#[derive(Serialize)]
pub struct SharingFolderDto {
    pub folder: String,
    pub question: Option<String>,
}

/// **Choisit le dossier des relevés.** Le sélecteur s'ouvre ici, côté Rust :
/// la fenêtre n'a le droit de lire aucun fichier. `None` si l'on renonce.
#[tauri::command]
pub async fn pick_sharing_folder<R: Runtime>(
    app: AppHandle<R>,
    input: radinus_core::sharing::Input,
    unit: Option<String>,
) -> Result<Option<SharingFolderDto>, String> {
    use tauri_plugin_dialog::DialogExt;
    let language = ui_language();
    let computed = sharing_of(&input).map_err(|refusal| refusal.message)?;
    let (answered, answer) = std::sync::mpsc::channel();
    app.dialog().file().pick_folder(move |chosen| {
        let _ = answered.send(chosen);
    });
    let Ok(Some(chosen)) = answer.recv() else {
        return Ok(None);
    };
    let folder = chosen.into_path().map_err(to_ipc_error)?;
    let existing = sharing_statement_files(&computed, unit.as_deref().filter(|key| !key.is_empty()), language)
        .iter()
        .filter(|(_, name)| folder.join(name).exists())
        .count();
    Ok(Some(SharingFolderDto {
        folder: folder.to_string_lossy().to_string(),
        question: (existing > 0).then(|| {
            radinus_core::i18n::message_of(language, "sharing-statements-replace-question", &[], &[("count", existing as i64)])
        }),
    }))
}

/// **Écrit les relevés** — un fichier par foyer, ou celui d'un seul — dans le
/// dossier choisi, puis l'ouvre.
#[tauri::command]
pub fn write_sharing_statements(
    input: radinus_core::sharing::Input,
    folder: String,
    unit: Option<String>,
) -> Result<String, String> {
    let language = ui_language();
    let failed = |reason: &str| radinus_core::i18n::text_with(language, "print-failed", "reason", reason);
    let computed = sharing_of(&input).map_err(|refusal| refusal.message)?;
    let directory = std::path::PathBuf::from(&folder);
    let files = sharing_statement_files(&computed, unit.as_deref().filter(|key| !key.is_empty()), language);
    let today = sharing_today();
    for (index, name) in &files {
        let bytes = radinus_core::sharing::statement_pdf(&computed, *index, today, language)
            .map_err(|error| failed(&error.to_string()))?;
        std::fs::write(directory.join(name), bytes).map_err(|error| failed(&error.to_string()))?;
    }
    let _ = crate::system::open_with_desktop(&directory);
    Ok(radinus_core::i18n::message_of(
        language,
        "sharing-statements-written",
        &[("folder", &file_name_of(&folder))],
        &[("count", files.len() as i64)],
    ))
}

/// **Le classeur Excel**, à l'endroit choisi.
#[tauri::command]
pub fn export_sharing(input: radinus_core::sharing::Input, path: String) -> Result<String, String> {
    let language = ui_language();
    let computed = sharing_of(&input).map_err(|refusal| refusal.message)?;
    let book = radinus_core::sharing::book(&computed, language);
    let file = std::path::PathBuf::from(&path);
    radinus_core::sheets::write_book(&book, &file).map_err(|error| {
        radinus_core::i18n::text_with(language, "export-failed", "reason", &error.to_string())
    })?;
    Ok(export_done(language, &file, &path))
}

/// **Enregistre le projet** en JSON, à l'endroit choisi — même quand le
/// partage ne tombe pas encore juste.
#[tauri::command]
pub fn save_sharing_project(input: radinus_core::sharing::Input, path: String) -> Result<String, String> {
    let language = ui_language();
    let text = radinus_core::sharing::to_file(&input, language).map_err(|refusal| refusal.message)?;
    std::fs::write(&path, text).map_err(|error| {
        radinus_core::i18n::text_with(language, "sharing-file-failed", "reason", &error.to_string())
    })?;
    Ok(radinus_core::i18n::text_with(language, "sharing-file-saved", "file", &file_name_of(&path)))
}

/// Un projet rouvert : les champs dans la langue en cours, et la phrase qui
/// le dit.
#[derive(Serialize)]
pub struct SharingProjectDto {
    pub input: radinus_core::sharing::Input,
    pub message: String,
}

/// **Rouvre un projet.** Le sélecteur du système s'ouvre côté Rust. `None` si
/// l'on renonce ; un fichier illisible est refusé avec sa phrase.
#[tauri::command]
pub async fn load_sharing_project<R: Runtime>(app: AppHandle<R>) -> Result<Option<SharingProjectDto>, String> {
    use tauri_plugin_dialog::DialogExt;
    let language = ui_language();
    let (answered, answer) = std::sync::mpsc::channel();
    app.dialog()
        .file()
        .add_filter(radinus_core::i18n::text(language, "sharing-file-filter"), &["json"])
        .pick_file(move |chosen| {
            let _ = answered.send(chosen);
        });
    let Ok(Some(chosen)) = answer.recv() else {
        return Ok(None);
    };
    let path = chosen.into_path().map_err(to_ipc_error)?;
    let text = std::fs::read_to_string(&path).map_err(|error| {
        radinus_core::i18n::text_with(language, "sharing-file-failed", "reason", &error.to_string())
    })?;
    let input = radinus_core::sharing::from_file(&text, language)
        .map_err(|refusal| radinus_core::i18n::text(language, refusal.key()))?;
    let shown = file_name_of(&path.to_string_lossy());
    Ok(Some(SharingProjectDto {
        input,
        message: radinus_core::i18n::text_with(language, "sharing-file-opened", "file", &shown),
    }))
}

/// Quitte F48. Masquée, jamais détruite ; la fenêtre efface tout en partant.
#[tauri::command]
pub fn close_sharing<R: Runtime>(app: AppHandle<R>) -> Result<(), String> {
    if let Some(window) = app.get_webview_window("sharing") {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(())
}

// --- F05, la classification rapide des opérations (phase 7) ---------------
//
// **Le brouillon vit ici, pas dans la fenêtre.** La structure en RAM est
// tenue par l'état de l'application (`state::AppState`), et la fenêtre ne la
// voit que par les tranches qu'elle demande. Une copie dans le navigateur
// serait une seconde vérité, et deux vérités divergent toujours.
//
// Trois gestes et trois seulement traversent ce pont : appliquer un
// changement à des lignes, changer une cellule, enregistrer. Tout le reste —
// la période, le tri, les entonnoirs — n'est que de l'affichage et ne quitte
// jamais la fenêtre.

/// Une ligne du tableau de F05. Les cinq nomenclatures et le statut voyagent
/// **deux fois** : le libellé pour la colonne, la clef pour le menu déroulant
/// qui s'y ouvre.
#[derive(Serialize)]
pub struct QuickLineDto {
    pub id: i64,
    pub date: String,
    /// La même date en ISO : c'est sur elle que la colonne se trie. Le texte
    /// affiché commence par le quantième, et s'y ranger reviendrait à classer
    /// par jour du mois (défaut relevé par Fabrice le 04/08/2026).
    pub date_value: String,
    pub label: String,
    /// Le montant écrit avec les séparateurs de l'interface, signe compris.
    pub amount_text: String,
    /// Et le montant brut, en micro-unités : c'est lui qui trie et qui
    /// s'exporte, « 1 549,81 € » ne se somme pas.
    pub amount: i64,
    pub category: String,
    pub assignment: String,
    pub payment_mode: String,
    pub payee: String,
    pub project: String,
    pub status: String,
    /// La septième caractéristique (Fabrice, 03/10/2026) : le mot, dans la
    /// langue en cours, et sa clef — qui choisit aussi sa couleur.
    pub verification: String,
    pub category_id: i64,
    pub assignment_id: i64,
    pub payment_mode_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
    pub status_id: i64,
    pub verification_id: i64,
}

/// Ce que la fenêtre reçoit à chaque lecture : les lignes de la période, et
/// combien de lignes attendent d'être écrites.
#[derive(Serialize)]
pub struct QuickLinesDto {
    pub rows: Vec<QuickLineDto>,
    /// Combien d'opérations le compte porte en tout — la période n'en montre
    /// qu'une part, et il vaut mieux que cela se voie.
    pub loaded: usize,
    pub pending: usize,
    /// Et la phrase qui le dit, déjà accordée. La fenêtre ne compose jamais :
    /// « 1 ligne modifiée » et « 34 lignes modifiées » ne se déduisent pas
    /// l'une de l'autre, et seul Fluent sait où est le trou.
    pub pending_text: String,
}

/// Les six caractéristiques, telles que le bandeau les envoie.
///
/// **`None` est une case décochée** : on n'y touche pas. Une case cochée
/// arrive en `Some`, et « Non précisé » (0) y est une valeur comme une autre,
/// celle du vide — c'est le seul moyen de déclasser un lot d'opérations
/// (décision de Fabrice, 27/07/2026).
#[derive(serde::Deserialize, Default)]
pub struct ChangeInput {
    pub category: Option<i64>,
    pub assignment: Option<i64>,
    pub payment_mode: Option<i64>,
    pub payee: Option<i64>,
    pub project: Option<i64>,
    pub status: Option<i64>,
    /// Absente d'un appel qui ne la connaît pas : c'est une case décochée.
    #[serde(default)]
    pub verification: Option<i64>,
}

impl From<&ChangeInput> for radinus_core::quick_classification::Change {
    fn from(input: &ChangeInput) -> Self {
        Self {
            category: input.category,
            assignment: input.assignment,
            payment_mode: input.payment_mode,
            payee: input.payee,
            project: input.project,
            status: input.status,
            verification: input.verification,
        }
    }
}

/// Ce qu'une application en masse a fait, dit en toutes lettres, plus l'état
/// du brouillon après elle.
#[derive(Serialize)]
pub struct QuickAppliedDto {
    pub said: String,
    pub pending: usize,
}

/// Les libellés dont le tableau a besoin pour écrire ce qu'il montre : cinq
/// nomenclatures et les trois statuts, par leur clef.
fn quick_labels(
    conn: &radinus_core::database::Connection,
    language: Language,
) -> Result<std::collections::HashMap<(&'static str, i64), String>, String> {
    use radinus_core::quick_classification::Characteristic;
    let unspecified = radinus_core::i18n::unspecified_label(language);
    let mut labels: std::collections::HashMap<(&'static str, i64), String> =
        std::collections::HashMap::new();
    for (which, kind) in [
        (Characteristic::Category, Nomenclature::Category),
        (Characteristic::Assignment, Nomenclature::Assignment),
        (Characteristic::PaymentMode, Nomenclature::PaymentMode),
        (Characteristic::Payee, Nomenclature::Payee),
        (Characteristic::Project, Nomenclature::Project),
    ] {
        labels.insert((which.key(), radinus_core::nomenclatures::UNSPECIFIED), unspecified.clone());
        for item in nomenclatures::list(conn, kind).map_err(to_ipc_error)? {
            labels.insert((which.key(), item.id), item.label);
        }
    }
    for item in radinus_core::operations::statuses(conn).map_err(to_ipc_error)? {
        // Le mot de la traduction, comme dans `list_operation_statuses`.
        let label = radinus_core::i18n::status_label(language, item.id).unwrap_or(item.label);
        labels.insert((Characteristic::Status.key(), item.id), label);
    }
    for item in radinus_core::operations::verifications(conn).map_err(to_ipc_error)? {
        let label =
            radinus_core::i18n::verification_label(language, item.id).unwrap_or(item.label);
        labels.insert((Characteristic::Verification.key(), item.id), label);
    }
    Ok(labels)
}

/// **Charge un compte dans le brouillon — et remplace ce qui s'y trouvait.**
///
/// C'est le seul endroit où la structure naît. Elle n'est jamais complétée :
/// `quick_classification::load` en construit une neuve, et celle-ci prend la
/// place de l'ancienne, qui s'en va avec tout ce qu'elle portait (précaution
/// demandée nommément par Fabrice, 27/07/2026).
///
/// Tout le compte y entre, quelle que soit la période : la période ne
/// commande que l'affichage.
#[tauri::command]
pub fn quick_classification_load(
    state: State<'_, AppState>,
    account_id: i64,
) -> Result<usize, String> {
    let conn = state.database()?;
    let bench = radinus_core::quick_classification::load(&conn, account_id).map_err(to_ipc_error)?;
    let loaded = bench.lines().len();
    drop(conn);
    state.set_workbench(bench)?;
    Ok(loaded)
}

/// Les lignes mères dont la date tombe dans la période, telles que le tableau
/// les montre.
///
/// **Le compte est redonné à chaque appel, et vérifié.** Une fenêtre qui
/// demanderait les lignes d'un compte alors que le brouillon en tient un autre
/// reçoit un refus, et non les opérations de quelqu'un d'autre — c'est la
/// faute des statistiques du 26/07/2026 rendue impossible à l'endroit où elle
/// se produirait.
#[tauri::command]
pub fn quick_classification_lines(
    state: State<'_, AppState>,
    account_id: i64,
    from: String,
    to: String,
) -> Result<QuickLinesDto, String> {
    use radinus_core::domain::NaiveDate;
    use radinus_core::quick_classification::Characteristic;

    let conn = state.database()?;
    let language = ui_language();
    let labels = quick_labels(&conn, language)?;
    drop(conn);

    let bounds = |text: &str| -> Result<NaiveDate, String> {
        NaiveDate::parse_from_str(text, "%Y-%m-%d")
            .map_err(|_| format!("Date illisible : « {text} »"))
    };
    let from = bounds(&from)?;
    let to = bounds(&to)?;

    state.with_workbench(account_id, |bench| {
        let named = |which: Characteristic, id: i64| -> String {
            labels.get(&(which.key(), id)).cloned().unwrap_or_default()
        };
        let rows = bench
            .between(from, to)
            .into_iter()
            .map(|line| QuickLineDto {
                id: line.id,
                date: line
                    .date
                    .map(|date| date.format("%d/%m/%Y").to_string())
                    .unwrap_or_default(),
                date_value: line.date.map(|date| date.to_string()).unwrap_or_default(),
                label: line.label.clone(),
                amount_text: radinus_core::money::format(line.amount, language),
                amount: line.amount,
                category: named(Characteristic::Category, line.current.category_id),
                assignment: named(Characteristic::Assignment, line.current.assignment_id),
                payment_mode: named(Characteristic::PaymentMode, line.current.payment_mode_id),
                payee: named(Characteristic::Payee, line.current.payee_id),
                project: named(Characteristic::Project, line.current.project_id),
                status: named(Characteristic::Status, line.current.status_id),
                verification: named(Characteristic::Verification, line.current.verification_id),
                category_id: line.current.category_id,
                assignment_id: line.current.assignment_id,
                payment_mode_id: line.current.payment_mode_id,
                payee_id: line.current.payee_id,
                project_id: line.current.project_id,
                status_id: line.current.status_id,
                verification_id: line.current.verification_id,
            })
            .collect();
        let pending = bench.pending();
        QuickLinesDto {
            rows,
            loaded: bench.lines().len(),
            pending,
            pending_text: radinus_core::i18n::message_of(
                language,
                "quick-pending",
                &[],
                &[("count", pending as i64)],
            ),
        }
    })
}

/// Le premier icône du panneau bleu : applique les caractéristiques cochées
/// aux lignes sélectionnées, **en mémoire seulement**.
#[tauri::command]
pub fn quick_classification_apply(
    state: State<'_, AppState>,
    account_id: i64,
    ids: Vec<i64>,
    change: ChangeInput,
) -> Result<QuickAppliedDto, String> {
    let conn = state.database()?;
    let language = ui_language();
    drop(conn);

    let change = radinus_core::quick_classification::Change::from(&change);
    let (touched, pending) =
        state.with_workbench(account_id, |bench| (bench.apply(&ids, &change), bench.pending()))?;
    Ok(QuickAppliedDto {
        said: radinus_core::i18n::message_of(
            language,
            "quick-applied",
            &[],
            &[("count", touched as i64)],
        ),
        pending,
    })
}

/// Le menu déroulant d'une cellule : une caractéristique, une ligne.
#[tauri::command]
pub fn quick_classification_set(
    state: State<'_, AppState>,
    account_id: i64,
    id: i64,
    characteristic: String,
    value: i64,
) -> Result<usize, String> {
    let which = radinus_core::quick_classification::Characteristic::from_key(&characteristic)
        .ok_or_else(|| format!("Caractéristique inconnue : « {characteristic} »"))?;
    state.with_workbench(account_id, |bench| {
        bench.set(id, which, value);
        bench.pending()
    })
}

/// La question posée avant d'écrire, avec le nombre dedans. La phrase vit dans
/// Fluent avec son trou ; la fenêtre ne sait pas où est le trou.
#[tauri::command]
pub fn quick_classification_question(
    state: State<'_, AppState>,
    count: i64,
) -> Result<String, String> {
    let _conn = state.database()?;
    Ok(radinus_core::i18n::message_of(
        ui_language(),
        "quick-save-question",
        &[],
        &[("count", count)],
    ))
}

/// **L'enregistrement.** Le seul geste de cette fenêtre qui touche le disque,
/// et il n'écrit que ce qui diffère de la réserve.
#[tauri::command]
pub fn quick_classification_save<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    account_id: i64,
) -> Result<String, String> {
    let mut conn = state.database()?;
    let language = ui_language();
    let written = state
        .with_workbench(account_id, |bench| bench.save(&mut conn))?
        .map_err(to_ipc_error)?;
    drop(conn);
    operations_changed(&app);
    Ok(radinus_core::i18n::message_of(
        language,
        "quick-saved",
        &[],
        &[("count", written as i64)],
    ))
}

/// Ouvre F05 sur un compte, et lui donne son nom dans son titre — comme la
/// liste des opérations, parce qu'on n'y travaille jamais que sur un compte et
/// qu'il ne doit y avoir aucun doute sur lequel.
#[tauri::command]
pub fn open_quick_classification<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    account_id: i64,
) -> Result<(), String> {
    let conn = state.database()?;
    let language = ui_language();
    let label = radinus_core::accounts::get(&conn, account_id)
        .map_err(to_ipc_error)?
        .map(|account| account.label)
        .unwrap_or_default();
    drop(conn);

    crate::windows::open(
        &app,
        &crate::windows::quick_classification_window(language, &label),
        Some(&format!("account={account_id}")),
    )
    .map_err(to_ipc_error)
}

/// Quitte F05 — et **jette le brouillon**. Ce qui n'a pas été enregistré n'a
/// jamais existé ; revenir plus tard, c'est repartir de la base.
#[tauri::command]
pub fn close_quick_classification<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
) -> Result<(), String> {
    state.drop_workbench()?;
    if let Some(window) = app.get_webview_window("quick-classification") {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(())
}

// --- F17/F18, l'importation d'un relevé bancaire (phase 8) ---------------
//
// Le relevé lu vit dans l'état de l'application, comme le brouillon de la
// classification rapide, et pour la même raison : ouvrir un fichier ne touche
// pas la base, et la fenêtre ne détient aucune copie qui pourrait diverger de
// ce qui sera écrit.
//
// **Le fichier est choisi et lu par Rust, jamais par la fenêtre.** Le sélecteur
// du système est ouvert ici, et c'est ici que les octets sont lus : la fenêtre
// ne reçoit jamais le pouvoir de lire un fichier, et `capabilities/default.json`
// n'accorde toujours que la sauvegarde.

/// Une ligne du relevé, telle que le tableau de F17 la montre.
#[derive(Serialize)]
pub struct StatementLineDto {
    /// La colonne ID : le rang dans le fichier.
    pub rank: usize,
    pub date: String,
    /// La même date en ISO : c'est sur elle que la colonne se trie. Le texte
    /// affiché commence par le quantième, et s'y ranger reviendrait à classer
    /// par jour du mois (défaut relevé par Fabrice le 04/08/2026).
    pub date_value: String,
    pub label: String,
    /// Débit et Crédit ne partagent jamais une colonne : le signe décide
    /// laquelle est écrite, comme dans la liste des opérations.
    pub debit: String,
    pub credit: String,
    pub amount: i64,
    /// **La colonne FITID** — `Existe_OpFitID` : ce FITID est déjà en base sur
    /// ce compte. Une certitude, et non « le fichier en a fourni un ».
    pub fitid_known: bool,
    /// **Le pastel et l'italique** — `Existe_TransacMemeType` : même date, même
    /// libellé, même montant. Un soupçon, qui joue pour tous les formats.
    pub looks_like_duplicate: bool,
    /// La colonne Rapproché : intégrée pendant cette séance. Gris clair.
    pub reconciled: bool,
}

/// Ce que F17 affiche : les lignes, et les trois montants du pied.
#[derive(Serialize)]
pub struct StatementImportDto {
    pub lines: Vec<StatementLineDto>,
    /// Le numéro de compte tel que le fichier l'écrit.
    pub account_number: String,
    pub period: String,
    /// Compte / Fichier / Ecart, déjà écrits.
    pub account_balance: String,
    pub file_balance: String,
    pub difference: String,
    /// Combien de lignes restent à intégrer, et combien la base connaissait.
    pub pending: usize,
    pub fitid_known: usize,
    /// **La colonne FITID ne s'affiche que pour les formats qui en portent
    /// un** : visible pour l'OFX, cachée pour le CSV, comme dans l'original.
    pub has_fitid_column: bool,
    /// La phrase du bas, déjà accordée.
    pub said: String,
}

/// Ce que le sélecteur de fichier a rendu : le chemin, ce que le fichier est,
/// et les comptes qu'il contient quand c'est de l'OFX.
#[derive(Serialize)]
pub struct PickedFileDto {
    pub path: String,
    /// `"ofx"`, `"qif"` ou `"csv"`. **Déduit du contenu, pas de l'extension** : un
    /// relevé OFX enregistré sous `.txt` reste un relevé OFX, et une extension
    /// ne prouve rien. C'est la même règle que partout dans ce module — on
    /// déduit de ce qu'on a, pas de ce qu'on nous dit.
    pub kind: String,
    /// Les `ACCTID` trouvés, dans l'ordre du fichier — ou, pour un QIF, les
    /// noms de ses comptes. C'est la liste dans laquelle l'utilisateur choisit
    /// quand il y en a plusieurs. Vide pour un CSV, qui ne nomme pas ses
    /// comptes de façon lisible.
    pub accounts: Vec<String>,
}

/// La ligne que la fiche de rapprochement (F18) montre.
#[derive(Serialize)]
pub struct StatementFormDto {
    pub rank: usize,
    pub date: String,
    pub label: String,
    /// `"D"` ou `"C"`, comme la fiche opération.
    pub direction: String,
    /// Le montant **en valeur absolue**, écrit : la fiche sépare le sens du
    /// montant, comme l'original.
    pub amount: String,
    pub clearing_date: String,
    /// L'avertissement rouge du bas, vide quand il n'y a rien à dire.
    pub warning: String,
}

/// Le classement que F18 renvoie.
#[derive(serde::Deserialize)]
pub struct StatementClassificationInput {
    pub payment_mode_id: i64,
    pub category_id: i64,
    pub assignment_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
    pub status_id: i64,
}

fn statement_view(
    conn: &radinus_core::database::Connection,
    language: Language,
    import: &radinus_core::statements::Import,
    said: String,
    // `after_integration` : **l'écart ne se calcule pas contre le même solde
    // aux deux moments** — `LEDGERBAL` au chargement, `AVAILBAL` après une
    // intégration. Bizarrerie de l'original, reproduite sur consigne de
    // Fabrice ; voir `statements::reconciliation`.
    after_integration: bool,
) -> Result<StatementImportDto, String> {
    let money = |amount: i64| radinus_core::money::format(amount, language);
    let day = |date: Option<radinus_core::domain::NaiveDate>| {
        date.map(|d| d.format("%d/%m/%Y").to_string()).unwrap_or_default()
    };
    let balances = radinus_core::statements::reconciliation(conn, import, after_integration)
        .map_err(to_ipc_error)?;
    Ok(StatementImportDto {
        lines: import
            .lines
            .iter()
            .map(|line| StatementLineDto {
                rank: line.rank,
                date: day(line.date),
                date_value: line.date.map(|d| d.to_string()).unwrap_or_default(),
                label: line.label.clone(),
                debit: if line.amount < 0 { money(line.amount) } else { String::new() },
                credit: if line.amount >= 0 { money(line.amount) } else { String::new() },
                amount: line.amount,
                fitid_known: line.fitid_known,
                looks_like_duplicate: line.looks_like_duplicate,
                reconciled: line.reconciled,
            })
            .collect(),
        account_number: import.account_number.clone(),
        period: match (import.from, import.to) {
            (Some(_), Some(_)) => format!("{} — {}", day(import.from), day(import.to)),
            _ => String::new(),
        },
        account_balance: money(balances.account),
        // Vides quand le fichier ne donne pas de solde lisible : jamais un
        // 0,00 € de remplissage (Fabrice, 15/10/2026).
        file_balance: balances.file.map(money).unwrap_or_default(),
        difference: balances.difference.map(money).unwrap_or_default(),
        pending: import.pending(),
        fitid_known: import.fitid_known(),
        has_fitid_column: import.lines.iter().any(|line| !line.fitid.is_empty()),
        said,
    })
}

/// Ouvre le sélecteur du système et rend le chemin choisi, avec les comptes que
/// le fichier contient.
///
/// **Rien n'est chargé à ce stade** : on ne sait pas encore de quel compte du
/// fichier on parlera, et c'est justement la question qu'on pose ensuite quand
/// il y en a plusieurs.
///
/// # Pourquoi cette commande est `async`, et pourquoi elle n'attend pas le
/// sélecteur elle-même
///
/// **Une commande Tauri écrite sans `async` s'exécute sur le fil principal**,
/// celui-là même qui fait tourner l'interface et le sélecteur de fichiers. Y
/// attendre le sélecteur, c'est attendre une réponse que seul ce fil peut
/// produire : l'application se fige, sans erreur ni message (signalé par
/// Fabrice, 27/07/2026 : « le programme gèle, il plante »). C'est un
/// interblocage, pas une lenteur — il ne se serait jamais dénoué.
///
/// La commande est donc `async`, ce qui la place sur un fil de travail, et
/// elle ouvre le sélecteur **sans l'attendre** : le système rappelle avec le
/// choix, et c'est ce rappel qui traverse le canal. Le fil principal n'est
/// bloqué à aucun moment.
#[tauri::command]
pub async fn statement_pick_file<R: Runtime>(
    app: AppHandle<R>,
) -> Result<Option<PickedFileDto>, String> {
    use tauri_plugin_dialog::DialogExt;
    let (answered, answer) = std::sync::mpsc::channel();
    app.dialog()
        .file()
        .add_filter(
            "Relevés bancaires",
            &["ofx", "OFX", "qfx", "QFX", "qif", "QIF", "csv", "CSV", "txt", "TXT"],
        )
        .pick_file(move |chosen| {
            let _ = answered.send(chosen);
        });
    let Some(chosen) = answer.recv().map_err(to_ipc_error)? else {
        return Ok(None);
    };
    let path = chosen.into_path().map_err(to_ipc_error)?;
    let bytes = std::fs::read(&path).map_err(to_ipc_error)?;
    let text = radinus_core::ofx_import::decode(&bytes);
    // Un relevé OFX se reconnaît à ses balises, où qu'elles soient et quelle
    // que soit l'extension du fichier. Tout le reste est traité comme un CSV,
    // qui n'a pas de forme propre et qu'il faudra régler à la main.
    let is_ofx = text.contains("<OFX")
        || text.contains("OFXHEADER")
        || text.contains("<STMTTRN>");
    // Le QIF ne se cherche **qu'après** l'OFX : la reconnaissance de l'OFX
    // reste exactement ce qu'elle était (Fabrice, 15/10/2026 : « l'OFX, tu
    // n'y touches pas »).
    let is_qif = !is_ofx && radinus_core::qif_import::looks_like_qif(&text);
    let accounts = if is_ofx {
        radinus_core::ofx_import::accounts_in(&text)
    } else if is_qif {
        // Un compte sans nom prend celui du fichier, comme un CSV.
        radinus_core::qif_import::accounts_in(&text, &file_name_of(&path.to_string_lossy()))
    } else {
        Vec::new()
    };
    Ok(Some(PickedFileDto {
        path: path.to_string_lossy().to_string(),
        kind: if is_ofx { "ofx" } else if is_qif { "qif" } else { "csv" }.to_string(),
        accounts,
    }))
}

/// Charge le relevé du compte choisi **en mémoire**, et le pose dans l'état.
///
/// Étape 3 de la marche à suivre : « le fichier OFX est chargé dans la fenêtre,
/// pas encore dans la base, il est en RAM c'est tout ».
#[tauri::command]
pub fn statement_load(
    state: State<'_, AppState>,
    account_id: i64,
    path: String,
    account_number: String,
) -> Result<StatementImportDto, String> {
    let bytes = std::fs::read(&path).map_err(to_ipc_error)?;
    let text = radinus_core::ofx_import::decode(&bytes);
    let statement = radinus_core::ofx_import::read(&text, &account_number)
        .ok_or_else(|| format!("Le fichier ne contient pas le compte « {account_number} »."))?;

    let conn = state.database()?;
    let language = ui_language();
    let import =
        radinus_core::statements::prepare(&conn, account_id, &statement).map_err(to_ipc_error)?;
    let said = radinus_core::statements::loaded_sentence(&import, language);
    let view = statement_view(&conn, language, &import, said, false)?;
    drop(conn);
    state.set_import(import)?;
    Ok(view)
}

/// Ce que le chargement d'un QIF rend : le relevé, **ou** la question de
/// l'ordre des dates quand rien dans le fichier ne le prouve.
#[derive(Serialize)]
pub struct QifLoadDto {
    pub question: Option<radinus_core::qif_import::Question>,
    pub view: Option<StatementImportDto>,
}

/// **Charge le compte choisi d'un relevé QIF**, en mémoire — la même étape
/// que [`statement_load`] pour l'OFX, qui, elle, ne change pas.
///
/// `account` est le rang du compte dans la liste que [`statement_pick_file`] a
/// rendue ; `order` la réponse à la question des dates, quand elle a été posée.
/// La suite — tableau, rapprochement, intégration — est celle de l'OFX.
#[tauri::command]
pub fn statement_load_qif(
    state: State<'_, AppState>,
    account_id: i64,
    path: String,
    account: usize,
    order: Option<String>,
) -> Result<QifLoadDto, String> {
    use radinus_core::qif_import;
    let bytes = std::fs::read(&path).map_err(to_ipc_error)?;
    let text = radinus_core::ofx_import::decode(&bytes);
    let language = ui_language();
    // Les réglages des Préférences (P-73). Une configuration illisible vaut
    // « me demander » et « tiers + mémo » : on ne devine jamais une date.
    let config = radinus_core::location::read_config(&state.data_root).unwrap_or_default();
    let options = qif_import::Options {
        // La réponse à la question passe avant le réglage ; le fichier, lui,
        // passe avant les deux quand une date prouve l'ordre.
        order: order.as_deref().and_then(qif_import::DateOrder::from_key).or(config.qif_order_choice()),
        label: config.qif_label_choice(),
        today: time_compute::Local::now().date_naive(),
    };
    let read = match qif_import::read(&text, account, &file_name_of(&path), options) {
        Ok(read) => read,
        Err(problem) => {
            return match qif_import::question(&problem, language) {
                Some(question) => Ok(QifLoadDto { question: Some(question), view: None }),
                None => Err(qif_import::problem_text(&problem, language)),
            };
        }
    };

    let conn = state.database()?;
    let mut import = radinus_core::statements::prepare(&conn, account_id, &read.statement)
        .map_err(to_ipc_error)?;
    import.notes = qif_import::notes(&read, language);
    let loaded = radinus_core::statements::loaded_sentence(&import, language);
    let said = std::iter::once(loaded).chain(import.notes.iter().cloned()).collect::<Vec<_>>().join(" ");
    let view = statement_view(&conn, language, &import, said, false)?;
    drop(conn);
    state.set_import(import)?;
    Ok(QifLoadDto { question: None, view: Some(view) })
}

/// Ce que la fenêtre affiche, redemandé — après une intégration, ou au retour
/// de la fiche de rapprochement.
#[tauri::command]
pub fn statement_lines(
    state: State<'_, AppState>,
    account_id: i64,
    after_integration: bool,
) -> Result<StatementImportDto, String> {
    let conn = state.database()?;
    let language = ui_language();
    let view = state.with_import(account_id, |import| {
        statement_view(&conn, language, import, String::new(), after_integration)
    })??;
    Ok(view)
}

/// Le second icône : ce que le fichier ouvert contient, en toutes lettres.
#[tauri::command]
pub fn statement_file_info(
    state: State<'_, AppState>,
    account_id: i64,
) -> Result<String, String> {
    let _conn = state.database()?;
    let language = ui_language();
    let day = |date: Option<radinus_core::domain::NaiveDate>| {
        date.map(|d| d.format("%d/%m/%Y").to_string()).unwrap_or_default()
    };
    state.with_import(account_id, |import| {
        // Sans solde lisible, on le dit plutôt que d'écrire 0,00 €.
        let balance = import.file_balance.map_or_else(
            || radinus_core::i18n::text(language, "statement-balance-unknown"),
            |balance| radinus_core::money::format(balance, language),
        );
        let info = radinus_core::i18n::message_of(
            language,
            "statement-file-info",
            &[
                ("account", import.account_number.as_str()),
                ("from", &day(import.from)),
                ("to", &day(import.to)),
                ("balance", &balance),
            ],
            &[],
        );
        // Ce que contient le fichier, dit comme au chargement — certitudes et
        // ressemblances, chacune avec son mot —, puis ce que la lecture a
        // écarté ou signalé, redit pour qui l'aurait manqué.
        [info, radinus_core::statements::loaded_sentence(import, language)]
            .into_iter()
            .chain(import.notes.iter().cloned())
            .collect::<Vec<_>>()
            .join("\n")
    })
}

/// Ce qu'une demande d'intégration a donné, pour **une** ligne — la mécanique
/// de `Integration_Ligne`.
///
/// L'original ne refuse pas un doublon : il pose une question à trois issues,
/// et n'écrit que sur un oui. La boucle est menée par la fenêtre, ligne par
/// ligne, exactement comme `Integration_MultiLigne`.
#[derive(Serialize)]
pub struct StatementOutcomeDto {
    /// `"added"`, `"reconciled"`, `"duplicate"` ou `"unknown"`.
    pub outcome: String,
    /// La question du doublon, déjà rédigée, quand il faut la poser.
    pub question: String,
}

/// Fait entrer **une** ligne, ou dit pourquoi elle s'arrête.
///
/// `force` est la réponse « Oui » à la question du doublon.
#[tauri::command]
pub fn statement_integrate_line<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    account_id: i64,
    rank: usize,
    force: bool,
) -> Result<StatementOutcomeDto, String> {
    use radinus_core::statements::Outcome;
    let mut conn = state.database()?;
    let language = ui_language();
    let classification = radinus_core::statements::Classification::plain();

    state.with_import(account_id, |import| {
        let outcome =
            radinus_core::statements::integrate(&conn, import, rank, &classification, None, force)
                .map_err(to_ipc_error)?;
        let question = match outcome {
            Outcome::NeedsConfirmation => {
                let line = import.line(rank).expect("la ligne vient d'être trouvée");
                radinus_core::i18n::message_of(
                    language,
                    "statement-duplicate-question",
                    &[
                        (
                            "date",
                            &line
                                .date
                                .map(|date| date.format("%d/%m/%Y").to_string())
                                .unwrap_or_default(),
                        ),
                        ("label", &line.label),
                        ("amount", &radinus_core::money::format(line.amount, language)),
                    ],
                    &[],
                )
            }
            _ => String::new(),
        };
        Ok::<_, String>(StatementOutcomeDto {
            outcome: match outcome {
                Outcome::Added(_) => "added",
                Outcome::AlreadyReconciled => "reconciled",
                Outcome::NeedsConfirmation => "duplicate",
                Outcome::Unknown => "unknown",
            }
            .to_string(),
            question,
        })
    })?
    .inspect(|answer| {
        // La connexion n'est plus utile, mais le compilateur veut la voir
        // vivre jusqu'ici : `integrate` l'emprunte à travers la fermeture.
        let _ = &mut conn;
        // **C'est ici que le bug de Fabrice était** (25/08/2026) : une ligne
        // entrée en base sans que personne ne le dise, et la liste des
        // opérations laissée ouverte restait figée. Seule l'entrée réelle
        // prévient — un doublon qui attend sa réponse n'a rien écrit.
        if answer.outcome == "added" {
            operations_changed(&app);
        }
    })
}

/// Le compte rendu de fin d'intégration, tel que l'original le rend :
/// « Nombre d'enregistrements intégrés / ignorés », précédé d'« Abandon de
/// l'intégration ! » quand on a renoncé en cours de route.
#[tauri::command]
pub fn statement_integration_report(
    state: State<'_, AppState>,
    added: i64,
    ignored: i64,
    abandoned: bool,
) -> Result<String, String> {
    let _conn = state.database()?;
    Ok(radinus_core::i18n::message_of(
        ui_language(),
        if abandoned {
            "statement-integration-abandoned"
        } else {
            "statement-integration-report"
        },
        &[],
        &[("added", added), ("ignored", ignored)],
    ))
}

/// La ligne que la fiche de rapprochement montre, avec son avertissement de
/// doublon s'il y a lieu.
#[tauri::command]
pub fn statement_line(
    state: State<'_, AppState>,
    account_id: i64,
    rank: usize,
) -> Result<StatementFormDto, String> {
    let _conn = state.database()?;
    let language = ui_language();
    state.with_import(account_id, |import| {
        let line = import
            .line(rank)
            .ok_or_else(|| format!("La ligne {rank} n'existe pas dans ce relevé."))?;
        let day = |date: Option<radinus_core::domain::NaiveDate>| {
            date.map(|d| d.format("%Y-%m-%d").to_string()).unwrap_or_default()
        };
        Ok::<_, String>(StatementFormDto {
            rank: line.rank,
            date: day(line.date),
            label: line.label.clone(),
            direction: if line.amount < 0 { "D" } else { "C" }.to_string(),
            // Avec la devise, comme la capture le montre : ce champ se lit, il
            // ne se saisit pas.
            amount: radinus_core::money::format(line.amount.abs(), language),
            clearing_date: day(line.date),
            // L'avertissement rouge du bas : le doublon avéré d'abord, le
            // soupçon ensuite, et le silence quand il n'y a rien à dire.
            warning: if line.fitid_known {
                radinus_core::i18n::text(language, "statement-duplicate")
            } else if line.looks_like_duplicate {
                radinus_core::i18n::text(language, "statement-no-fitid")
            } else {
                String::new()
            },
        })
    })?
}

/// **Ce que la fiche de rapprochement a modifié.**
///
/// Chez Fabrice la fiche reçoit la transaction et la **rend modifiée**, et la
/// liste se rafraîchit avec ce qui revient. Cette commande porte cette
/// correction dans la structure ; l'intégration écrira la version corrigée.
#[tauri::command]
pub fn statement_amend(
    state: State<'_, AppState>,
    account_id: i64,
    rank: usize,
    date: String,
    label: String,
    amount: i64,
) -> Result<(), String> {
    let day = radinus_core::domain::NaiveDate::parse_from_str(&date, "%Y-%m-%d").ok();
    state.with_import(account_id, |import| {
        radinus_core::statements::amend(import, rank, day, &label, amount);
    })
}

/// La fiche de rapprochement valide : la ligne entre dans le compte avec le
/// classement qu'on vient de lui donner.
#[tauri::command]
pub fn statement_integrate<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    account_id: i64,
    rank: usize,
    classification: StatementClassificationInput,
    clearing_date: String,
    force: bool,
) -> Result<StatementOutcomeDto, String> {
    use radinus_core::statements::Outcome;
    let conn = state.database()?;
    let language = ui_language();
    let clearing = radinus_core::domain::NaiveDate::parse_from_str(&clearing_date, "%Y-%m-%d").ok();
    let classification = radinus_core::statements::Classification {
        payment_mode_id: classification.payment_mode_id,
        category_id: classification.category_id,
        assignment_id: classification.assignment_id,
        payee_id: classification.payee_id,
        project_id: classification.project_id,
        status_id: classification.status_id,
    };
    let answer = state.with_import(account_id, |import| {
        let outcome = radinus_core::statements::integrate(
            &conn,
            import,
            rank,
            &classification,
            clearing,
            force,
        )
        .map_err(to_ipc_error)?;
        let question = match outcome {
            Outcome::NeedsConfirmation => {
                let line = import.line(rank).expect("la ligne vient d'être trouvée");
                radinus_core::i18n::message_of(
                    language,
                    "statement-duplicate-question",
                    &[
                        (
                            "date",
                            &line
                                .date
                                .map(|date| date.format("%d/%m/%Y").to_string())
                                .unwrap_or_default(),
                        ),
                        ("label", &line.label),
                        ("amount", &radinus_core::money::format(line.amount, language)),
                    ],
                    &[],
                )
            }
            _ => String::new(),
        };
        Ok::<_, String>(StatementOutcomeDto {
            outcome: match outcome {
                Outcome::Added(_) => "added",
                Outcome::AlreadyReconciled => "reconciled",
                Outcome::NeedsConfirmation => "duplicate",
                Outcome::Unknown => "unknown",
            }
            .to_string(),
            question,
        })
    })??;
    drop(conn);

    if answer.outcome == "added" {
        let _ = app.emit("data-changed:statement-import", String::new());
        let _ = app.emit("data-changed:operations", ());
    }
    Ok(answer)
}

/// Ouvre F17 sur un compte — après le choix d'**un** compte, comme le veut la
/// marche à suivre.
#[tauri::command]
pub fn open_statement_import<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    account_id: i64,
) -> Result<(), String> {
    let conn = state.database()?;
    let language = ui_language();
    let label = radinus_core::accounts::get(&conn, account_id)
        .map_err(to_ipc_error)?
        .map(|account| account.label)
        .unwrap_or_default();
    drop(conn);
    crate::windows::open(
        &app,
        &crate::windows::statement_import_window(language, &label),
        Some(&format!("account={account_id}")),
    )
    .map_err(to_ipc_error)
}

/// Quitte F17, et **jette le relevé**. Ce qui n'a pas été intégré n'a jamais
/// existé.
#[tauri::command]
pub fn close_statement_import<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
) -> Result<(), String> {
    state.drop_import()?;
    for label in ["statement-form", "statement-import"] {
        if let Some(window) = app.get_webview_window(label) {
            window.hide().map_err(to_ipc_error)?;
        }
    }
    Ok(())
}

/// Ouvre F18 sur une ligne du relevé.
#[tauri::command]
pub fn open_statement_form<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    account_id: i64,
    rank: usize,
) -> Result<(), String> {
    let language = window_language(&state);
    crate::windows::open(
        &app,
        &crate::windows::statement_form_window(language),
        Some(&format!("account={account_id}&rank={rank}")),
    )
    .map_err(to_ipc_error)
}

/// Quitte F18.
#[tauri::command]
pub fn close_statement_form<R: Runtime>(app: AppHandle<R>) -> Result<(), String> {
    if let Some(window) = app.get_webview_window("statement-form") {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(())
}


// --- La fenêtre de découpage d'un relevé CSV (phase 8) -------------------
//
// Elle ne s'ouvre que si le fichier choisi n'est pas de l'OFX. On y règle, on
// y teste, on y regarde, et à la validation les lignes basculent dans la
// fenêtre d'intégration **comme si c'était de l'OFX** — même tableau, même
// pastel, même intégration (demande de Fabrice, 27/07/2026).

/// Les six réglages, tels que la fenêtre les envoie.
#[derive(serde::Deserialize)]
pub struct CsvSettingsInput {
    pub header_lines: usize,
    /// Le séparateur, tel qu'il est écrit dans le menu déroulant. Un texte et
    /// non un caractère : `\t` y désigne la tabulation, qu'aucun menu ne peut
    /// montrer autrement.
    pub separator: String,
    pub date_at: usize,
    pub label_at: usize,
    pub debit_at: usize,
    pub credit_at: usize,
}

impl From<&CsvSettingsInput> for radinus_core::csv_statement::Settings {
    fn from(input: &CsvSettingsInput) -> Self {
        Self {
            header_lines: input.header_lines,
            separator: match input.separator.as_str() {
                "\\t" | "\t" => '\t',
                other => other.chars().next().unwrap_or(';'),
            },
            date_at: input.date_at,
            label_at: input.label_at,
            debit_at: input.debit_at,
            credit_at: input.credit_at,
        }
    }
}

/// Une ligne de l'aperçu du haut : le fichier tel qu'il est.
#[derive(Serialize)]
pub struct CsvSourceLineDto {
    pub number: usize,
    pub content: String,
}

/// Une ligne du tableau du bas : ce que le découpage produit.
#[derive(Serialize)]
pub struct CsvRowDto {
    pub number: usize,
    pub date: String,
    /// La même date en ISO : c'est sur elle que la colonne se trie. Le texte
    /// affiché commence par le quantième, et s'y ranger reviendrait à classer
    /// par jour du mois (défaut relevé par Fabrice le 04/08/2026).
    pub date_value: String,
    pub label: String,
    pub debit: String,
    pub credit: String,
    pub amount: i64,
    /// Deviendra-t-elle une opération ? L'aperçu montre tout ; seul le valide
    /// bascule.
    pub valid: bool,
}

#[derive(Serialize)]
pub struct CsvExtractionDto {
    pub rows: Vec<CsvRowDto>,
    pub valid: usize,
    pub dropped: usize,
    /// Ce que ça donnerait, en toutes lettres.
    pub said: String,
}

/// Le fichier tel qu'il est, ligne par ligne — l'aperçu du haut.
#[tauri::command]
pub fn csv_statement_source(path: String) -> Result<Vec<CsvSourceLineDto>, String> {
    let bytes = std::fs::read(&path).map_err(to_ipc_error)?;
    Ok(radinus_core::csv_statement::read(&bytes)
        .into_iter()
        .enumerate()
        .map(|(index, content)| CsvSourceLineDto {
            number: index + 1,
            content,
        })
        .collect())
}

/// « Tester les paramètres » : ce que le découpage donne, **tout compris**.
///
/// Le charabia est montré exprès — c'est en le voyant qu'on comprend qu'on
/// s'est trompé de nombre de lignes d'en-tête.
#[tauri::command]
pub fn csv_statement_extract(
    state: State<'_, AppState>,
    path: String,
    settings: CsvSettingsInput,
) -> Result<CsvExtractionDto, String> {
    let conn = state.database()?;
    let language = ui_language();
    drop(conn);

    let bytes = std::fs::read(&path).map_err(to_ipc_error)?;
    let lines = radinus_core::csv_statement::read(&bytes);
    let settings = radinus_core::csv_statement::Settings::from(&settings);
    let rows = radinus_core::csv_statement::extract(&lines, &settings);
    let outcome = radinus_core::csv_statement::outcome(&rows);
    let money = |amount: i64| radinus_core::money::format(amount, language);

    Ok(CsvExtractionDto {
        rows: rows
            .iter()
            .map(|row| CsvRowDto {
                number: row.source_line,
                date: row
                    .date
                    .map(|date| date.format("%d/%m/%Y").to_string())
                    .unwrap_or_default(),
                date_value: row.date.map(|date| date.to_string()).unwrap_or_default(),
                label: row.label.clone(),
                debit: match row.amount {
                    Some(amount) if amount < 0 => money(amount),
                    _ => String::new(),
                },
                credit: match row.amount {
                    Some(amount) if amount >= 0 => money(amount),
                    _ => String::new(),
                },
                amount: row.amount.unwrap_or(0),
                valid: row.is_valid(),
            })
            .collect(),
        valid: outcome.valid,
        dropped: outcome.dropped,
        said: radinus_core::i18n::message_of(
            language,
            "csv-extraction",
            &[],
            &[
                ("count", outcome.read as i64),
                ("valid", outcome.valid as i64),
                ("dropped", outcome.dropped as i64),
            ],
        ),
    })
}

/// La validation : les lignes valides basculent dans la fenêtre d'intégration,
/// **comme si c'était de l'OFX**.
///
/// Sévère, comme Fabrice l'a demandé : ce qui n'a ni date ni montant lisible
/// reste dehors. Rien n'est écrit en base — on ne fait que remplir le relevé en
/// mémoire, celui-là même qu'un fichier OFX aurait rempli.
#[tauri::command]
pub fn csv_statement_apply<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    account_id: i64,
    path: String,
    settings: CsvSettingsInput,
) -> Result<String, String> {
    let bytes = std::fs::read(&path).map_err(to_ipc_error)?;
    let lines = radinus_core::csv_statement::read(&bytes);
    let settings = radinus_core::csv_statement::Settings::from(&settings);
    let rows = radinus_core::csv_statement::extract(&lines, &settings);
    if radinus_core::csv_statement::outcome(&rows).valid == 0 {
        return Err(radinus_core::i18n::text(
            window_language(&state),
            "csv-nothing-valid",
        ));
    }
    // Le nom du fichier tient lieu de numéro de compte : un CSV n'en donne
    // aucun de lisible, et la fenêtre d'intégration a besoin de dire d'où
    // viennent ses lignes.
    let name = std::path::Path::new(&path)
        .file_name()
        .map(|name| name.to_string_lossy().to_string())
        .unwrap_or_default();
    let statement = radinus_core::csv_statement::into_statement(&rows, &name);

    let conn = state.database()?;
    let language = ui_language();
    let import =
        radinus_core::statements::prepare(&conn, account_id, &statement).map_err(to_ipc_error)?;
    let said = radinus_core::statements::loaded_sentence(&import, language);
    drop(conn);
    state.set_import(import)?;

    // La fenêtre d'intégration reçoit le chemin : c'est lui qui lui dit qu'un
    // relevé est désormais ouvert.
    let _ = app.emit("data-changed:statement-import", path);
    if let Some(window) = app.get_webview_window("csv-statement") {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(said)
}

/// Ouvre la fenêtre de découpage sur un fichier.
#[tauri::command]
pub fn open_csv_statement<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    account_id: i64,
    path: String,
) -> Result<(), String> {
    let language = window_language(&state);
    crate::windows::open(
        &app,
        &crate::windows::csv_statement_window(language),
        Some(&format!("account={account_id}&path={}", urlencode(&path))),
    )
    .map_err(to_ipc_error)
}

/// Quitte la fenêtre de découpage sans rien basculer.
#[tauri::command]
pub fn close_csv_statement<R: Runtime>(app: AppHandle<R>) -> Result<(), String> {
    if let Some(window) = app.get_webview_window("csv-statement") {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(())
}

/// Un chemin de fichier voyage dans une adresse : ce qui y a un sens propre
/// doit être échappé, sinon un dossier nommé « Relevés & co » couperait
/// l'adresse en deux.
fn urlencode(text: &str) -> String {
    let mut out = String::with_capacity(text.len());
    for byte in text.as_bytes() {
        match byte {
            b'A'..=b'Z' | b'a'..=b'z' | b'0'..=b'9' | b'-' | b'_' | b'.' | b'~' | b'/' => {
                out.push(*byte as char);
            }
            other => out.push_str(&format!("%{other:02X}")),
        }
    }
    out
}

// =====================================================================
// Phase 9 — chéquiers et chèques (F13, F31, F14, F12, et l'association).
//
// Cinq fenêtres, un carnet qui naît entier, une numérotation qui se fige, et
// un lien chèque↔opération à deux visages. Tout ce qui suit n'est que la
// traduction d'un appel JSON en un appel de `radinus_core::chequebooks` ou
// `radinus_core::cheques` : aucune règle ne vit ici.
// =====================================================================

/// Un chéquier, tel que la liste F13 le montre.
#[derive(Serialize)]
pub struct ChequebookRowDto {
    pub id: i64,
    pub reference: String,
    pub received_on: String,
    pub account_label: String,
    pub account_number: String,
    pub comments: String,
}

/// Un chéquier, tel que sa fiche F31 le montre. Les cinq champs figés y sont
/// quand même : la fiche les **affiche** en modification, grisés.
#[derive(Serialize)]
pub struct ChequebookDto {
    pub id: i64,
    pub reference: String,
    pub received_on: String,
    pub first_number: i64,
    pub last_number: i64,
    pub quantity: i64,
    pub comments: String,
    pub account_id: i64,
    /// Le compte auquel il est rattaché a disparu — sa phrase à lui.
    pub account_missing: bool,
}

/// Un chèque, tel que la composition du chéquier F14 le montre.
#[derive(Serialize)]
pub struct ChequeRowDto {
    pub id: i64,
    pub number: String,
    pub date: String,
    pub place: String,
    pub payee: String,
    pub amount: i64,
    pub amount_text: String,
    pub status_id: i64,
    pub status: String,
    pub comments: String,
    pub operations: i64,
}

/// Un chèque, tel que sa fiche F12 le montre.
#[derive(Serialize)]
pub struct ChequeDto {
    pub id: i64,
    pub number: String,
    pub issued_on: String,
    pub place: String,
    pub payee: String,
    pub amount_text: String,
    pub comments: String,
    pub status_id: i64,
}

/// Une opération, telle que les deux visages de la fenêtre d'association la
/// montrent.
#[derive(Serialize)]
pub struct LinkableOperationDto {
    pub id: i64,
    pub account_label: String,
    pub label: String,
    pub date: String,
    pub clearing_date: String,
    pub amount: i64,
    pub amount_text: String,
    /// Non nul : elle porte déjà un chèque, et **la fenêtre l'écrit en gras**.
    pub cheque_id: i64,
    pub cheque_reference: String,
}

fn iso(date: Option<time_compute::NaiveDate>) -> String {
    date.map(|d| d.format("%Y-%m-%d").to_string())
        .unwrap_or_default()
}

fn parse_iso(text: &str) -> Option<time_compute::NaiveDate> {
    time_compute::NaiveDate::parse_from_str(text, "%Y-%m-%d").ok()
}

/// Tous les chéquiers — le ⌘F7 les montre tous, sans choisir de compte.
#[tauri::command]
pub fn list_chequebooks(state: State<'_, AppState>) -> Result<Vec<ChequebookRowDto>, String> {
    let conn = state.database()?;
    Ok(radinus_core::chequebooks::list(&conn)
        .map_err(to_ipc_error)?
        .into_iter()
        .map(|row| ChequebookRowDto {
            id: row.id,
            reference: row.reference,
            received_on: iso(row.received_on),
            account_label: row.account_label,
            account_number: row.account_number,
            comments: row.comments,
        })
        .collect())
}

/// Un chéquier, pour sa fiche.
#[tauri::command]
pub fn get_chequebook(
    state: State<'_, AppState>,
    id: i64,
) -> Result<Option<ChequebookDto>, String> {
    let conn = state.database()?;
    let Some(book) = radinus_core::chequebooks::get(&conn, id).map_err(to_ipc_error)? else {
        return Ok(None);
    };
    let missing = radinus_core::chequebooks::account_is_missing(&conn, &book).map_err(to_ipc_error)?;
    Ok(Some(ChequebookDto {
        id: book.id,
        reference: book.reference,
        received_on: iso(book.received_on),
        first_number: book.first_number,
        last_number: book.last_number,
        quantity: book.quantity,
        comments: book.comments,
        account_id: book.account_id,
        account_missing: missing,
    }))
}

/// Pourquoi ce chéquier ne peut pas être enregistré, ou `null` s'il le peut.
///
/// **Les huit précautions de Fabrice**, dans son ordre, portées par le noyau et
/// dites ici dans la langue de l'interface. La fenêtre les pose avant d'écrire,
/// exactement comme son bouton d'enregistrement.
#[tauri::command]
pub fn chequebook_refusal(
    state: State<'_, AppState>,
    adding: bool,
    reference: String,
    received_on: String,
    first_number: i64,
    last_number: i64,
    account_id: i64,
) -> Result<Option<String>, String> {
    let conn = state.database()?;
    let language = ui_language();
    let book = radinus_core::chequebooks::Chequebook {
        id: 0,
        reference,
        received_on: parse_iso(&received_on),
        first_number,
        last_number,
        quantity: 0,
        number_format: 0,
        comments: String::new(),
        account_id,
    };
    Ok(
        radinus_core::chequebooks::refusal(&conn, &book, adding)
            .map_err(to_ipc_error)?
            .map(|key| radinus_core::i18n::text(language, key)),
    )
}

/// Sa demande de confirmation avant la création — elle compte les chèques et
/// les nomme, donc elle se demande avec ses valeurs et n'a rien à faire dans le
/// dictionnaire.
#[tauri::command]
pub fn chequebook_creation_question(
    state: State<'_, AppState>,
    first_number: i64,
    last_number: i64,
) -> Result<String, String> {
    let _conn = state.database()?;
    Ok(radinus_core::i18n::message_of(
        ui_language(),
        "chequebook-creation-question",
        &[],
        &[
            (
                "count",
                radinus_core::chequebooks::cheques_between(first_number, last_number),
            ),
            ("first", first_number),
            ("last", last_number),
        ],
    ))
}

/// Ajoute un chéquier **et tous ses chèques**. Rend l'identifiant du carnet,
/// ou `null` quand la référence était déjà prise — l'échec silencieux de son
/// `HAjoute`, laissé tel quel (arbitrage de Fabrice, 28/07/2026).
#[tauri::command]
pub fn create_chequebook(
    state: State<'_, AppState>,
    reference: String,
    received_on: String,
    first_number: i64,
    last_number: i64,
    account_id: i64,
    comments: String,
) -> Result<Option<i64>, String> {
    let mut conn = state.database()?;
    radinus_core::chequebooks::create(
        &mut conn,
        &radinus_core::chequebooks::Chequebook {
            id: 0,
            reference,
            received_on: parse_iso(&received_on),
            first_number,
            last_number,
            // **Calculé, jamais reçu de la fenêtre** : c'est ce nombre-là que
            // son plafond de mille contrôle, et un nombre venu d'ailleurs ne
            // bornerait rien.
            quantity: radinus_core::chequebooks::cheques_between(first_number, last_number),
            number_format: 0,
            comments,
            account_id,
        },
    )
    .map_err(to_ipc_error)
}

/// Change ce qui reste modifiable : le compte et les commentaires. Les cinq
/// champs figés ne passent pas par ici — aucune fenêtre ne peut les changer.
#[tauri::command]
pub fn update_chequebook(
    state: State<'_, AppState>,
    id: i64,
    account_id: i64,
    comments: String,
) -> Result<bool, String> {
    let conn = state.database()?;
    radinus_core::chequebooks::update(&conn, id, account_id, &comments).map_err(to_ipc_error)
}

/// Ce que supprimer cette sélection de carnets entraînerait. Sa question est
/// posée **une seule fois** pour toute la sélection (son `bConfirmation`).
#[tauri::command]
pub fn plan_chequebook_deletion(
    state: State<'_, AppState>,
    ids: Vec<i64>,
) -> Result<DeletionPlanDto, String> {
    let conn = state.database()?;
    let language = ui_language();
    let mut plan = DeletionPlanDto {
        refused: false,
        refusal: String::new(),
        needs_confirmation: false,
        question: String::new(),
        second_question: String::new(),
        confirmation_word: String::new(),
        operations: 0,
        operation_templates: 0,
        recurring_rules: 0,
    };
    for id in &ids {
        plan.operations +=
            radinus_core::chequebooks::linked_operations(&conn, *id).map_err(to_ipc_error)?;
    }
    if plan.operations > 0 {
        plan.needs_confirmation = true;
        plan.question = radinus_core::i18n::text(language, "chequebooks-delete-question");
    }
    Ok(plan)
}

/// Supprime des chéquiers : leurs chèques partent, leurs opérations restent et
/// sont détachées.
#[tauri::command]
pub fn delete_chequebooks(state: State<'_, AppState>, ids: Vec<i64>) -> Result<i64, String> {
    let mut conn = state.database()?;
    let mut deleted = 0;
    for id in ids {
        if radinus_core::chequebooks::delete(&mut conn, id).map_err(to_ipc_error)? {
            deleted += 1;
        }
    }
    Ok(deleted)
}

/// La phrase qui compte les chéquiers supprimés.
#[tauri::command]
pub fn chequebooks_deleted_text(
    state: State<'_, AppState>,
    count: i64,
) -> Result<String, String> {
    let _conn = state.database()?;
    Ok(radinus_core::i18n::message_of(
        ui_language(),
        "chequebooks-deleted",
        &[],
        &[("count", count)],
    ))
}

/// La composition d'un carnet — ses chèques, dans l'ordre de leur numéro.
#[tauri::command]
pub fn list_cheques(
    state: State<'_, AppState>,
    chequebook_id: i64,
) -> Result<Vec<ChequeRowDto>, String> {
    let conn = state.database()?;
    let language = ui_language();
    Ok(
        radinus_core::cheques::list_for_chequebook(&conn, chequebook_id)
            .map_err(to_ipc_error)?
            .into_iter()
            .map(|row| ChequeRowDto {
                id: row.id,
                number: radinus_core::cheques::formatted_number(row.number),
                date: iso(row.issued_on),
                place: row.place,
                payee: row.payee,
                amount: row.amount,
                amount_text: radinus_core::money::format(row.amount, language),
                status_id: row.status_id,
                status: row.status,
                comments: row.comments,
                operations: row.operations,
            })
            .collect(),
    )
}

/// Les quinze statuts de chèque, pour le combo de la fiche et pour la case du
/// tableau.
#[tauri::command]
pub fn list_cheque_statuses(state: State<'_, AppState>) -> Result<Vec<ItemDto>, String> {
    let conn = state.database()?;
    Ok(radinus_core::cheques::statuses(&conn)
        .map_err(to_ipc_error)?
        .into_iter()
        .map(|item| ItemDto {
            id: item.id,
            label: item.label,
        })
        .collect())
}

/// Un chèque, pour sa fiche.
#[tauri::command]
pub fn get_cheque(state: State<'_, AppState>, id: i64) -> Result<Option<ChequeDto>, String> {
    let conn = state.database()?;
    let language = ui_language();
    Ok(radinus_core::cheques::get(&conn, id)
        .map_err(to_ipc_error)?
        .map(|cheque| ChequeDto {
            id: cheque.id,
            number: radinus_core::cheques::formatted_number(cheque.number),
            issued_on: iso(cheque.issued_on),
            place: cheque.place,
            payee: cheque.payee,
            amount_text: radinus_core::money::format_plain(cheque.amount, language),
            comments: cheque.comments,
            status_id: cheque.status_id,
        }))
}

/// Change un chèque depuis sa fiche.
// Huit arguments, et ils sont les huit champs de la fiche chèque. Les
// regrouper dans une structure changerait la forme du message que la fenêtre
// envoie, donc le contrat entre les deux couches, pour ne gagner qu'un
// avertissement en moins.
#[allow(clippy::too_many_arguments)]
#[tauri::command]
pub fn update_cheque(
    state: State<'_, AppState>,
    id: i64,
    issued_on: String,
    place: String,
    payee: String,
    amount: i64,
    comments: String,
    status_id: i64,
) -> Result<bool, String> {
    let conn = state.database()?;
    let Some(current) = radinus_core::cheques::get(&conn, id).map_err(to_ipc_error)? else {
        return Ok(false);
    };
    radinus_core::cheques::update(
        &conn,
        id,
        &radinus_core::cheques::Cheque {
            issued_on: parse_iso(&issued_on),
            place,
            payee,
            amount,
            comments,
            status_id,
            ..current
        },
    )
    .map_err(to_ipc_error)
}

/// Change le seul statut — le clic dans la case du tableau F14.
#[tauri::command]
pub fn set_cheque_status(
    state: State<'_, AppState>,
    id: i64,
    status_id: i64,
) -> Result<bool, String> {
    let conn = state.database()?;
    radinus_core::cheques::set_status(&conn, id, status_id).map_err(to_ipc_error)
}

/// Les opérations d'un des deux visages : celles **déjà associées** quand
/// `chequeId` est donné, celles que l'on peut associer sinon.
#[tauri::command]
pub fn cheque_operations(
    state: State<'_, AppState>,
    cheque_id: i64,
    account_id: i64,
    linked: bool,
) -> Result<Vec<LinkableOperationDto>, String> {
    let conn = state.database()?;
    let language = ui_language();
    let rows = if linked {
        radinus_core::cheques::linked(&conn, cheque_id).map_err(to_ipc_error)?
    } else {
        radinus_core::cheques::candidates(&conn, account_id).map_err(to_ipc_error)?
    };
    Ok(rows
        .into_iter()
        .map(|row| LinkableOperationDto {
            id: row.id,
            account_label: row.account_label,
            label: row.label,
            date: iso(row.date),
            clearing_date: iso(row.clearing_date),
            amount: row.amount,
            amount_text: radinus_core::money::format(row.amount, language),
            cheque_id: row.cheque_id,
            cheque_reference: row.cheque_reference,
        })
        .collect())
}

/// Accroche une opération à un chèque. **Écrase** celui qu'elle portait, sans
/// rien demander : c'est son original, et le gras était l'avertissement.
#[tauri::command]
pub fn associate_cheque(
    state: State<'_, AppState>,
    operation_id: i64,
    cheque_id: i64,
) -> Result<bool, String> {
    let conn = state.database()?;
    radinus_core::cheques::associate(&conn, operation_id, cheque_id).map_err(to_ipc_error)
}

/// Détache le chèque d'une opération. Rien n'est supprimé.
#[tauri::command]
pub fn dissociate_cheque(
    state: State<'_, AppState>,
    operation_id: i64,
) -> Result<bool, String> {
    let conn = state.database()?;
    radinus_core::cheques::dissociate(&conn, operation_id).map_err(to_ipc_error)
}

/// Le chèque que porte une opération : son identifiant, et **son numéro** tel
/// que la fiche opération l'affiche — « 9 506 001 », ou « / » quand elle n'en
/// porte aucun (04_SPECIFICATIONS_FENETRES.md F03 : « affiche / si aucun, sinon
/// le n° de chèque »). L'identifiant, lui, ne s'affiche pas : il sert à ouvrir
/// la fiche du chèque, que le numéro seul ne saurait pas retrouver — deux
/// carnets peuvent porter le même numéro.
#[derive(Serialize)]
pub struct OperationChequeDto {
    pub cheque_id: i64,
    pub text: String,
}

#[tauri::command]
pub fn operation_cheque(
    state: State<'_, AppState>,
    operation_id: i64,
) -> Result<OperationChequeDto, String> {
    let conn = state.database()?;
    let cheque_id: i64 = conn
        .query_row(
            "SELECT IDCheque FROM Operation WHERE IDOperation = ?1",
            [operation_id],
            |row| row.get(0),
        )
        .unwrap_or(0);
    let text = radinus_core::cheques::get(&conn, cheque_id)
        .map_err(to_ipc_error)?
        .map(|cheque| radinus_core::cheques::formatted_number(cheque.number))
        .unwrap_or_default();
    Ok(OperationChequeDto {
        cheque_id,
        text: if text.is_empty() { "/".to_string() } else { text },
    })
}

/// **Le premier temps de la pêche au chèque**, depuis la fiche opération : la
/// liste des chéquiers dans son mode « choisir ». Ce qu'on vient y faire — quelle
/// opération attend son chèque — voyage avec la question, comme pour la liste
/// des comptes : sans cela, choisir un carnet ne saurait plus pour qui.
#[tauri::command]
pub fn choose_cheque_for_operation<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    operation_id: i64,
) -> Result<(), String> {
    let language = window_language(&state);
    crate::windows::open(
        &app,
        &crate::windows::chequebooks_selection_window(language),
        Some(&format!("operation={operation_id}")),
    )
    .map_err(to_ipc_error)
}

/// **Le second temps** : les chèques du carnet choisi, dans le même mode.
#[tauri::command]
pub fn choose_cheque_in_chequebook<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    operation_id: i64,
    chequebook_id: i64,
) -> Result<(), String> {
    let language = window_language(&state);
    crate::windows::open(
        &app,
        &crate::windows::cheques_selection_window(language),
        Some(&format!(
            "operation={operation_id}&chequebook={chequebook_id}"
        )),
    )
    .map_err(to_ipc_error)
}

/// Referme les deux fenêtres de choix, une fois le chèque accroché.
#[tauri::command]
pub fn close_cheque_choice<R: Runtime>(app: AppHandle<R>) -> Result<(), String> {
    for label in ["cheques-select", "chequebooks-select"] {
        if let Some(window) = app.get_webview_window(label) {
            window.hide().map_err(to_ipc_error)?;
        }
    }
    Ok(())
}

/// Ouvre F31, la fiche du carnet. `mode` est son vocabulaire à lui.
#[tauri::command]
pub fn open_chequebook_form<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    mode: String,
    id: Option<i64>,
) -> Result<(), String> {
    let query = match id {
        Some(id) => format!("mode={mode}&id={id}"),
        None => format!("mode={mode}"),
    };
    let language = window_language(&state);
    crate::windows::open(
        &app,
        &crate::windows::chequebook_form_window(language),
        Some(&query),
    )
    .map_err(to_ipc_error)
}

/// Ouvre F14 sur un carnet.
#[tauri::command]
pub fn open_cheques<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    chequebook_id: i64,
) -> Result<(), String> {
    let language = window_language(&state);
    crate::windows::open(
        &app,
        &crate::windows::cheques_window(language),
        Some(&format!("chequebook={chequebook_id}")),
    )
    .map_err(to_ipc_error)
}

/// Ouvre F12 sur un chèque.
#[tauri::command]
pub fn open_cheque_form<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    id: i64,
) -> Result<(), String> {
    let language = window_language(&state);
    crate::windows::open(
        &app,
        &crate::windows::cheque_form_window(language),
        Some(&format!("id={id}")),
    )
    .map_err(to_ipc_error)
}

/// Ouvre la fenêtre d'association, sur l'un de ses deux visages.
#[tauri::command]
pub fn open_cheque_operations<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    cheque_id: i64,
    linked: bool,
) -> Result<(), String> {
    let conn = state.database()?;
    let language = ui_language();
    // Le compte du carnet borne les candidates — la branche vivante de son
    // `TableData_SyncFichier`, celle qui pose le gras.
    let account_id = radinus_core::cheques::get(&conn, cheque_id)
        .map_err(to_ipc_error)?
        .and_then(|cheque| {
            radinus_core::chequebooks::get(&conn, cheque.chequebook_id)
                .ok()
                .flatten()
        })
        .map(|book| book.account_id)
        .unwrap_or(0);
    drop(conn);
    crate::windows::open(
        &app,
        &crate::windows::cheque_operations_window(language),
        Some(&format!(
            "cheque={cheque_id}&account={account_id}&linked={}",
            i32::from(linked)
        )),
    )
    .map_err(to_ipc_error)
}

/// Dit au sélecteur qu'une base vient de naître, et ce qu'il faut en dire.
///
/// La fiche de création ne sait pas montrer une liste de bases : elle vient
/// d'en créer une et s'efface. C'est le sélecteur qui relit, qui choisit la
/// nouvelle ligne et qui écrit le compte rendu dans sa barre d'état — chacun
/// son ouvrage, et le compte rendu ne se perd pas avec la fenêtre qui ferme.
#[tauri::command]
pub fn notify_databases_changed<R: Runtime>(app: AppHandle<R>, said: String) -> Result<(), String> {
    let _ = app.emit_to(
        tauri::EventTarget::webview_window("database-selector"),
        "data-changed:database-selector",
        said,
    );
    Ok(())
}

/// Dit aux fenêtres des chèques que leurs données ont bougé.
#[tauri::command]
pub fn notify_cheques_changed<R: Runtime>(app: AppHandle<R>) -> Result<(), String> {
    for label in ["chequebooks", "cheques", "cheque-operations"] {
        let _ = app.emit_to(
            tauri::EventTarget::webview_window(label),
            &format!("data-changed:{label}"),
            (),
        );
    }
    // La liste des opérations montre le numéro de chèque, et la fiche porte
    // son bandeau : les deux doivent se relire.
    let _ = app.emit("data-changed:operations", ());
    let _ = app.emit("data-changed:operation-form", ());
    Ok(())
}

/// Ferme l'une des cinq fenêtres de la phase 9. Une seule commande : elles
/// n'ont rien à jeter en partant — aucune ne tient de structure en RAM.
#[tauri::command]
pub fn close_cheque_window<R: Runtime>(app: AppHandle<R>, label: String) -> Result<(), String> {
    // La liste des chéquiers emmène ses filles : ce sont ses fenêtres.
    let closing: &[&str] = match label.as_str() {
        "chequebooks" => &[
            "cheque-operations",
            "cheque-form",
            "cheques",
            "chequebook-form",
            "chequebooks",
        ],
        "cheques" => &["cheque-operations", "cheque-form", "cheques"],
        "chequebook-form" => &["chequebook-form"],
        "cheque-form" => &["cheque-form"],
        "cheque-operations" => &["cheque-operations"],
        other => return Err(format!("Fenêtre inconnue : {other}")),
    };
    for label in closing {
        if let Some(window) = app.get_webview_window(label) {
            window.hide().map_err(to_ipc_error)?;
        }
    }
    Ok(())
}

// =====================================================================
// Phase 10 — les modèles d'opération (F36, F37, et le bouton de F03).
//
// **Un modèle écrase l'écran et n'écrit rien.** Règle de Fabrice, 29/07/2026 :
// appliquer un modèle remplit la fiche opération, et c'est la validation de
// cette fiche qui écrira. Aucune commande de ce bloc ne touche la table des
// opérations — sauf `save_operation_as_template`, qui va dans l'autre sens.
// =====================================================================

/// Un modèle, tel que sa liste et sa fiche le montrent.
#[derive(Serialize, Clone)]
pub struct TemplateDto {
    pub id: i64,
    pub label: String,
    /// Le montant signé, en micro-unités : la fiche en tire le sens et la
    /// grandeur, comme la fiche opération.
    pub amount: i64,
    /// La **grandeur**, pour la fiche du modèle : elle porte le sens dans un
    /// combo, comme sa capture le montre.
    pub amount_text: String,
    /// Le montant **avec son signe**, pour la fiche opération : elle, écrit
    /// « -70,00 » dans le champ (règle du 25/07/2026 — ce qui est tapé est ce
    /// qui est vu).
    pub signed_text: String,
    pub payment_mode_id: i64,
    pub category_id: i64,
    pub assignment_id: i64,
    pub status_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
}

fn template_dto(template: radinus_core::operation_templates::Template, language: Language) -> TemplateDto {
    TemplateDto {
        amount_text: radinus_core::money::format_plain(template.amount.abs(), language),
        signed_text: radinus_core::money::format_plain(template.amount, language),
        id: template.id,
        label: template.label,
        amount: template.amount,
        payment_mode_id: template.payment_mode_id,
        category_id: template.category_id,
        assignment_id: template.assignment_id,
        status_id: template.status_id,
        payee_id: template.payee_id,
        project_id: template.project_id,
    }
}

#[tauri::command]
pub fn list_operation_templates(state: State<'_, AppState>) -> Result<Vec<TemplateDto>, String> {
    let conn = state.database()?;
    let language = ui_language();
    Ok(radinus_core::operation_templates::list(&conn)
        .map_err(to_ipc_error)?
        .into_iter()
        .map(|template| template_dto(template, language))
        .collect())
}

#[tauri::command]
pub fn get_operation_template(
    state: State<'_, AppState>,
    id: i64,
) -> Result<Option<TemplateDto>, String> {
    let conn = state.database()?;
    let language = ui_language();
    Ok(radinus_core::operation_templates::get(&conn, id)
        .map_err(to_ipc_error)?
        .map(|template| template_dto(template, language)))
}

/// Pourquoi ce modèle ne peut pas être enregistré, ou `null` s'il le peut : un
/// nom est obligatoire, et deux modèles ne peuvent pas porter le même — on en
/// choisit un **par son nom**, dans une liste.
#[tauri::command]
pub fn operation_template_refusal(
    state: State<'_, AppState>,
    id: Option<i64>,
    label: String,
) -> Result<Option<String>, String> {
    let conn = state.database()?;
    let language = ui_language();
    if label.trim().is_empty() {
        return Ok(Some(radinus_core::i18n::text(
            language,
            "operation-template-label-required",
        )));
    }
    if radinus_core::operation_templates::same_name_as(&conn, &label, id)
        .map_err(to_ipc_error)?
        .is_some()
    {
        return Ok(Some(radinus_core::i18n::text(
            language,
            "operation-template-duplicate",
        )));
    }
    Ok(None)
}

#[allow(clippy::too_many_arguments)]
fn template_from(
    label: String,
    amount: i64,
    payment_mode_id: i64,
    category_id: i64,
    assignment_id: i64,
    status_id: i64,
    payee_id: i64,
    project_id: i64,
) -> radinus_core::operation_templates::Template {
    radinus_core::operation_templates::Template {
        id: 0,
        label,
        amount,
        payment_mode_id,
        category_id,
        assignment_id,
        status_id,
        payee_id,
        project_id,
    }
}

#[tauri::command]
#[allow(clippy::too_many_arguments)]
pub fn create_operation_template(
    state: State<'_, AppState>,
    label: String,
    amount: i64,
    payment_mode_id: i64,
    category_id: i64,
    assignment_id: i64,
    status_id: i64,
    payee_id: i64,
    project_id: i64,
) -> Result<i64, String> {
    let conn = state.database()?;
    radinus_core::operation_templates::create(
        &conn,
        &template_from(
            label,
            amount,
            payment_mode_id,
            category_id,
            assignment_id,
            status_id,
            payee_id,
            project_id,
        ),
    )
    .map_err(to_ipc_error)
}

#[tauri::command]
#[allow(clippy::too_many_arguments)]
pub fn update_operation_template(
    state: State<'_, AppState>,
    id: i64,
    label: String,
    amount: i64,
    payment_mode_id: i64,
    category_id: i64,
    assignment_id: i64,
    status_id: i64,
    payee_id: i64,
    project_id: i64,
) -> Result<bool, String> {
    let conn = state.database()?;
    radinus_core::operation_templates::update(
        &conn,
        id,
        &template_from(
            label,
            amount,
            payment_mode_id,
            category_id,
            assignment_id,
            status_id,
            payee_id,
            project_id,
        ),
    )
    .map_err(to_ipc_error)
}

#[tauri::command]
pub fn delete_operation_templates(
    state: State<'_, AppState>,
    ids: Vec<i64>,
) -> Result<i64, String> {
    let conn = state.database()?;
    let mut deleted = 0;
    for id in ids {
        if radinus_core::operation_templates::delete(&conn, id).map_err(to_ipc_error)? {
            deleted += 1;
        }
    }
    Ok(deleted)
}

/// La phrase qui compte les modèles supprimés.
#[tauri::command]
pub fn operation_templates_deleted_text(
    state: State<'_, AppState>,
    count: i64,
) -> Result<String, String> {
    let _conn = state.database()?;
    Ok(radinus_core::i18n::message_of(
        ui_language(),
        "operation-templates-deleted",
        &[],
        &[("count", count)],
    ))
}

/// Ouvre F37, dans l'un de ses deux usages.
#[tauri::command]
pub fn open_operation_templates<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    selecting: bool,
) -> Result<(), String> {
    let language = window_language(&state);
    crate::windows::open(
        &app,
        &crate::windows::operation_templates_window(language, selecting),
        None,
    )
    .map_err(to_ipc_error)
}

/// Ouvre F36, la fiche du modèle.
#[tauri::command]
pub fn open_operation_template_form<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    mode: String,
    id: Option<i64>,
) -> Result<(), String> {
    let query = match id {
        Some(id) => format!("mode={mode}&id={id}"),
        None => format!("mode={mode}"),
    };
    let language = window_language(&state);
    crate::windows::open(
        &app,
        &crate::windows::operation_template_form_window(language),
        Some(&query),
    )
    .map_err(to_ipc_error)
}

/// **Le modèle choisi part vers la fiche opération, et nulle part ailleurs.**
///
/// Rien n'est écrit : la fiche recevra les valeurs, les mettra à l'écran par
/// dessus ce qui s'y trouvait, et c'est sa validation qui écrira — règle de
/// Fabrice, 29/07/2026. La fenêtre de choix se referme dans la foulée.
#[tauri::command]
pub fn apply_operation_template<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    id: i64,
) -> Result<bool, String> {
    let conn = state.database()?;
    let language = ui_language();
    let Some(template) = radinus_core::operation_templates::get(&conn, id).map_err(to_ipc_error)?
    else {
        return Ok(false);
    };
    drop(conn);
    app.emit_to(
        tauri::EventTarget::webview_window("operation-form"),
        "template-chosen:operation-form",
        template_dto(template, language),
    )
    .map_err(to_ipc_error)?;
    if let Some(window) = app.get_webview_window("operation-templates-select") {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(true)
}

/// Ferme l'une des deux fenêtres des modèles.
#[tauri::command]
pub fn close_operation_template_window<R: Runtime>(
    app: AppHandle<R>,
    label: String,
) -> Result<(), String> {
    let closing: &[&str] = match label.as_str() {
        "operation-templates" => &["operation-template-form", "operation-templates"],
        "operation-template-form" => &["operation-template-form"],
        "operation-templates-select" => &["operation-templates-select"],
        other => return Err(format!("Fenêtre inconnue : {other}")),
    };
    for label in closing {
        if let Some(window) = app.get_webview_window(label) {
            window.hide().map_err(to_ipc_error)?;
        }
    }
    Ok(())
}

/// Dit à la liste des modèles que ses données ont bougé.
#[tauri::command]
pub fn notify_operation_templates_changed<R: Runtime>(app: AppHandle<R>) -> Result<(), String> {
    for label in ["operation-templates", "operation-templates-select"] {
        let _ = app.emit_to(
            tauri::EventTarget::webview_window(label),
            &format!("data-changed:{label}"),
            (),
        );
    }
    Ok(())
}

// =====================================================================
// Phase 11 — le budget (F26 la saisie, F39 le contrôle).
//
// Deux portes, deux questions. Le tout sur **une année**, naviguée comme les
// statistiques, et par **poste budgétaire**.
// =====================================================================

/// Une ligne du tableau de saisie : un poste, ses douze mois écrits, son total.
#[derive(Serialize)]
pub struct BudgetRowDto {
    pub id: i64,
    pub label: String,
    pub months: [i64; 12],
    pub month_texts: Vec<String>,
    pub total: i64,
    pub total_text: String,
}

#[derive(Serialize)]
pub struct BudgetGridDto {
    pub rows: Vec<BudgetRowDto>,
    pub sum_texts: Vec<String>,
    pub sum_total_text: String,
    pub cumulative_texts: Vec<String>,
    /// Les mêmes nombres, **en nombres** : la fenêtre en a besoin pour colorer
    /// les deux lignes de synthèse par leur signe, et lire un signe dans un
    /// texte écrit serait deviner ce qu'on sait déjà.
    pub sum: [i64; 12],
    pub sum_total: i64,
    pub cumulative: [i64; 12],
}

/// Le budget d'une année, tel que F26 le montre — **avec la saisie en cours
/// par-dessus**, s'il y en a une.
///
/// C'est ce qui rend les lignes Somme et Cumul vivantes : elles suivent la
/// frappe au lieu d'attendre l'enregistrement. Les montants tapés sont relus
/// par le noyau, jamais par la fenêtre.
#[tauri::command]
pub fn budget_grid(
    state: State<'_, AppState>,
    year: i32,
    cells: Option<Vec<(i64, i64, String)>>,
) -> Result<BudgetGridDto, String> {
    let conn = state.database()?;
    let language = ui_language();
    let pending: Vec<(i64, i64, i64)> = cells
        .unwrap_or_default()
        .into_iter()
        .map(|(line, month, written)| {
            (
                line,
                month,
                radinus_core::money::parse_or_zero(&written).unwrap_or(0),
            )
        })
        .collect();
    let grid = radinus_core::budget::grid_with(&conn, year, &pending).map_err(to_ipc_error)?;
    // Une case vide s'écrit vide, jamais « 0,00 € » : un budget non saisi et un
    // budget de zéro se lisent alors pareil, et l'on ne verrait plus ce qui
    // reste à faire.
    let written = |amount: i64| -> String {
        if amount == 0 {
            String::new()
        } else {
            radinus_core::money::format_plain(amount, language)
        }
    };
    Ok(BudgetGridDto {
        rows: grid
            .rows
            .iter()
            .map(|row| BudgetRowDto {
                id: row.id,
                label: row.label.clone(),
                months: row.months,
                month_texts: row.months.iter().map(|amount| written(*amount)).collect(),
                total: row.total,
                total_text: written(row.total),
            })
            .collect(),
        sum_texts: grid.sum.iter().map(|amount| written(*amount)).collect(),
        sum_total_text: written(grid.sum_total),
        cumulative_texts: grid
            .cumulative
            .iter()
            .map(|amount| written(*amount))
            .collect(),
        sum: grid.sum,
        sum_total: grid.sum_total,
        cumulative: grid.cumulative,
    })
}

/// Écrit le tableau : une année, et les cases qui ont changé — poste, mois,
/// montant tel qu'il a été tapé. Le noyau relit chaque montant, jamais la
/// fenêtre.
#[tauri::command]
pub fn budget_save(
    state: State<'_, AppState>,
    year: i32,
    cells: Vec<(i64, i64, String)>,
) -> Result<(), String> {
    let mut conn = state.database()?;
    let mut read = Vec::with_capacity(cells.len());
    for (line, month, written) in cells {
        let amount = radinus_core::money::parse_or_zero(&written).unwrap_or(0);
        read.push((line, month, amount));
    }
    radinus_core::budget::save(&mut conn, year, &read).map_err(to_ipc_error)
}

/// Une case du contrôle : ce qui était prévu, ce qui a été fait, comment ça se
/// lit dans les deux modes, et de quelle couleur.
#[derive(Serialize)]
pub struct ControlCellDto {
    pub planned: i64,
    pub actual: i64,
    /// Le réalisé en devise — le mode « valeur ».
    pub money: String,
    /// Le pourcentage du budget consommé — le mode « pourcentage ». Vide quand
    /// rien n'était prévu : diviser par rien n'a pas de sens.
    pub percent: String,
    /// « good », « bad » ou « none » — la règle des couleurs, calculée par le
    /// noyau et **la même pour les deux modes**.
    pub standing: &'static str,
    /// Ce que la case dit quand on s'y arrête : le prévu en regard du réalisé.
    pub detail: String,
}

#[derive(Serialize)]
pub struct ControlRowDto {
    pub id: i64,
    pub label: String,
    pub months: Vec<ControlCellDto>,
    pub total: ControlCellDto,
}

#[derive(Serialize)]
pub struct ControlDto {
    pub rows: Vec<ControlRowDto>,
    pub sum: Vec<ControlCellDto>,
    pub sum_total: ControlCellDto,
    /// Le cumul, sous la Somme — la même ligne que dans la saisie.
    pub cumulative: Vec<ControlCellDto>,
}

fn control_cell(
    planned: i64,
    actual: i64,
    language: Language,
    planned_word: &str,
    actual_word: &str,
) -> ControlCellDto {
    let standing = match radinus_core::budget::standing(planned, actual) {
        radinus_core::budget::Standing::Good => "good",
        radinus_core::budget::Standing::Bad => "bad",
        radinus_core::budget::Standing::Unplanned => "none",
    };
    let percent = radinus_core::budget::used(planned, actual)
        .map(|hundredths| {
            let whole = hundredths / 100;
            let rest = (hundredths % 100).abs();
            format!("{whole},{rest:02} %")
        })
        .unwrap_or_default();
    ControlCellDto {
        planned,
        actual,
        money: if planned == 0 && actual == 0 {
            String::new()
        } else {
            radinus_core::money::format(actual, language)
        },
        percent,
        standing,
        detail: format!(
            "{planned_word} {} — {actual_word} {}",
            radinus_core::money::format(planned, language),
            radinus_core::money::format(actual, language)
        ),
    }
}

/// Le contrôle d'une année : le budget en regard du réalisé, poste par poste.
#[tauri::command]
pub fn budget_control(
    state: State<'_, AppState>,
    year: i32,
    switches: SwitchesInput,
) -> Result<ControlDto, String> {
    let conn = state.database()?;
    let language = ui_language();
    let control =
        radinus_core::budget::control(&conn, year, switches.into()).map_err(to_ipc_error)?;
    let planned_word = radinus_core::i18n::text(language, "budget-planned");
    let actual_word = radinus_core::i18n::text(language, "budget-actual");
    let cell = |planned: i64, actual: i64| {
        control_cell(planned, actual, language, &planned_word, &actual_word)
    };
    Ok(ControlDto {
        rows: control
            .rows
            .iter()
            .map(|row| ControlRowDto {
                id: row.id,
                label: row.label.clone(),
                months: (0..12).map(|m| cell(row.planned[m], row.actual[m])).collect(),
                total: cell(row.planned_total, row.actual_total),
            })
            .collect(),
        sum: (0..12)
            .map(|m| cell(control.planned_sum[m], control.actual_sum[m]))
            .collect(),
        sum_total: cell(control.planned_total, control.actual_total),
        cumulative: (0..12)
            .map(|m| cell(control.planned_cumulative[m], control.actual_cumulative[m]))
            .collect(),
    })
}

// =====================================================================
// Phase 12 — le transfert d'un montant entre deux comptes (F09).
//
// **Un virement, deux écritures**, et elles partent ensemble ou pas du tout.
// =====================================================================

#[derive(serde::Deserialize)]
pub struct TransferInput {
    pub source_id: i64,
    pub target_id: i64,
    pub label: String,
    pub payment_reference: String,
    pub date: String,
    pub clearing_date: String,
    pub status_id: i64,
    pub category_id: i64,
    pub payment_mode_id: i64,
    pub assignment_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
    /// Tel que le champ d'argent l'écrit ; **le noyau le relit**, jamais la
    /// fenêtre.
    pub amount: String,
}

impl TransferInput {
    fn read(self) -> radinus_core::transfers::Transfer {
        radinus_core::transfers::Transfer {
            source_id: self.source_id,
            target_id: self.target_id,
            label: self.label,
            payment_reference: self.payment_reference,
            date: parse_iso(&self.date),
            clearing_date: parse_iso(&self.clearing_date),
            status_id: self.status_id,
            category_id: self.category_id,
            payment_mode_id: self.payment_mode_id,
            assignment_id: self.assignment_id,
            payee_id: self.payee_id,
            project_id: self.project_id,
            amount: radinus_core::money::parse_or_zero(&self.amount).unwrap_or(0),
        }
    }
}

/// **Les trois soldes du compte choisi**, en une phrase, pour la barre du bas.
///
/// Demande de Fabrice (29/07/2026) : au moment où l'on choisit un compte, on
/// doit savoir ce qu'implique le virement — « elle saura si elle peut
/// raisonnablement faire le débit ou pas ». Les trois, parce qu'un compte en a
/// trois et qu'aucun ne répond seul : **en banque** dit ce que la banque
/// connaît, **réel** y ajoute l'engagé, **final** ajoute le prévu.
#[tauri::command]
pub fn transfer_balances(state: State<'_, AppState>, account_id: i64) -> Result<String, String> {
    let conn = state.database()?;
    let language = ui_language();
    let Some(account) = radinus_core::accounts::get(&conn, account_id).map_err(to_ipc_error)?
    else {
        return Ok(String::new());
    };
    Ok(radinus_core::i18n::message_of(
        language,
        "transfer-balances",
        &[
            ("account", &account.label),
            (
                "bank",
                &radinus_core::money::format(account.balance_bank, language),
            ),
            (
                "real",
                &radinus_core::money::format(account.balance_real, language),
            ),
            (
                "final",
                &radinus_core::money::format(account.balance_final, language),
            ),
        ],
        &[],
    ))
}

/// Pourquoi ce virement ne peut pas être fait, ou `null` s'il le peut.
#[tauri::command]
pub fn transfer_refusal(
    state: State<'_, AppState>,
    transfer: TransferInput,
) -> Result<Option<String>, String> {
    let conn = state.database()?;
    let language = ui_language();
    Ok(
        radinus_core::transfers::refusal(&conn, &transfer.read())
            .map_err(to_ipc_error)?
            .map(|key| radinus_core::i18n::text(language, key)),
    )
}

/// Fait le virement, et rend **le récapitulatif à montrer** — ou `null` si le
/// noyau l'a refusé, ce qui ne devrait pas arriver puisque la fenêtre a déjà
/// posé les questions.
#[tauri::command]
pub fn perform_transfer<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    transfer: TransferInput,
) -> Result<Option<String>, String> {
    let mut conn = state.database()?;
    let language = ui_language();
    let transfer = transfer.read();
    if radinus_core::transfers::perform(&mut conn, &transfer)
        .map_err(to_ipc_error)?
        .is_none()
    {
        return Ok(None);
    }
    let name = |id: i64| -> String {
        radinus_core::accounts::get(&conn, id)
            .ok()
            .flatten()
            .map(|account| account.label)
            .unwrap_or_default()
    };
    let said = radinus_core::i18n::message_of(
        language,
        "transfer-done",
        &[
            (
                "amount",
                &radinus_core::money::format(transfer.amount, language),
            ),
            ("source", &name(transfer.source_id)),
            ("target", &name(transfer.target_id)),
            (
                "date",
                &transfer
                    .date
                    .map(|day| day.format("%d/%m/%Y").to_string())
                    .unwrap_or_default(),
            ),
        ],
        &[],
    );
    drop(conn);
    // Les deux comptes ont bougé, et leurs opérations aussi : ce qui les montre
    // doit se relire.
    let _ = app.emit("data-changed:accounts-list", ());
    let _ = app.emit("data-changed:operations", ());
    Ok(Some(said))
}

// =====================================================================
// Phase 13 — l'importation d'une feuille Excel (F34, F35, et la fenêtre
// d'association des données).
//
// Trois fenêtres, un classeur lu une seule fois, et rien d'écrit avant la
// toute fin. Tout ce qui suit n'est que la traduction d'un appel JSON en un
// appel de `radinus_core::csv_excel_import` : aucune règle ne vit ici.
// =====================================================================

use radinus_core::csv_excel_import as excel;

/// Le fichier désigné : son chemin, et les feuilles que le classeur porte.
#[derive(Serialize)]
pub struct ExcelFileDto {
    pub path: String,
    pub sheets: Vec<String>,
}

/// Les réglages de l'étape 1, tels que la fenêtre les envoie.
#[derive(serde::Deserialize)]
pub struct ExcelCaptureInput {
    pub sheet: usize,
    pub header_row: usize,
    pub first_column: usize,
    pub column_count: usize,
    pub first_data_row: usize,
    pub last_data_row: usize,
    pub shape: String,
}

impl From<&ExcelCaptureInput> for excel::Capture {
    fn from(input: &ExcelCaptureInput) -> Self {
        Self {
            sheet: input.sheet,
            header_row: input.header_row.max(1),
            first_column: input.first_column.max(1),
            column_count: input.column_count.clamp(1, 256),
            first_data_row: input.first_data_row.max(1),
            last_data_row: input.last_data_row.max(1),
            shape: excel::AmountShape::from_key(&input.shape),
        }
    }
}

/// Une ligne du rendu test.
#[derive(Serialize)]
pub struct ExcelRowDto {
    pub number: usize,
    pub cells: Vec<String>,
}

/// Ce que la zone de capture attrape, tel que le rendu test le montre.
#[derive(Serialize)]
pub struct ExcelPreviewDto {
    pub headers: Vec<String>,
    pub rows: Vec<ExcelRowDto>,
    pub said: String,
}

/// Ouvre le sélecteur du système, lit le classeur, et rend ses feuilles.
///
/// `async` pour la même raison que `statement_pick_file`, et la raison est
/// grave : une commande synchrone attendrait le sélecteur sur le fil qui fait
/// tourner le sélecteur, et l'application se figerait sans un mot.
#[tauri::command]
pub async fn excel_pick_file<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    account_id: i64,
) -> Result<Option<ExcelFileDto>, String> {
    use tauri_plugin_dialog::DialogExt;
    let (answered, answer) = std::sync::mpsc::channel();
    app.dialog()
        .file()
        .add_filter("Classeurs Excel", &["xlsx", "XLSX"])
        .pick_file(move |chosen| {
            let _ = answered.send(chosen);
        });
    let Some(chosen) = answer.recv().map_err(to_ipc_error)? else {
        return Ok(None);
    };
    let path = chosen.into_path().map_err(to_ipc_error)?;
    let book = excel::open(&path)?;
    let sheets = book.sheet_names.clone();
    // **Désigner un fichier jette le précédent** avec tous ses réglages : on ne
    // mélange pas deux feuilles.
    state.set_excel(crate::state::ExcelImport {
        account_id,
        path: path.to_string_lossy().to_string(),
        book,
        capture: excel::Capture::default(),
        grid: excel::Grid::default(),
        links: Vec::new(),
        policies: excel::Policies::default(),
    })?;
    Ok(Some(ExcelFileDto {
        path: path.to_string_lossy().to_string(),
        sheets,
    }))
}

/// « Testez les paramètres que vous avez définis aux étapes 2, 3 et 4. »
///
/// C'est le seul endroit où la zone de capture s'applique, et la fenêtre ne
/// peut pas passer à l'étape suivante sans être passée par ici (décision de
/// Fabrice, 29/07/2026).
#[tauri::command]
pub fn excel_test(
    state: State<'_, AppState>,
    settings: ExcelCaptureInput,
) -> Result<ExcelPreviewDto, String> {
    let language = window_language(&state);
    let capture = excel::Capture::from(&settings);
    state.with_excel(|import| {
        let grid = excel::capture(&import.book, &capture);
        // La concordance repart à neuf : les en-têtes ne sont plus les mêmes.
        import.links = excel::initial_links(&grid);
        import.capture = capture.clone();
        let said = radinus_core::i18n::message_of(
            language,
            "excel-tested",
            &[],
            &[
                ("rows", grid.rows.len() as i64),
                ("columns", grid.headers.len() as i64),
            ],
        );
        let dto = ExcelPreviewDto {
            headers: grid.headers.clone(),
            rows: grid
                .rows
                .iter()
                .map(|row| ExcelRowDto {
                    number: row.number,
                    cells: row.cells.iter().map(excel::Value::display).collect(),
                })
                .collect(),
            said,
        };
        import.grid = grid;
        dto
    })
}

/// Le chemin et le compte de l'import en cours — ce que la fenêtre réaffiche
/// quand on y revient.
#[derive(Serialize)]
pub struct ExcelStateDto {
    pub path: String,
    /// « Importation dans le compte X. » — une phrase à trou, donc rendue
    /// remplie par le contrôleur et jamais par la fenêtre.
    pub said: String,
}

#[tauri::command]
pub fn excel_state(state: State<'_, AppState>) -> Result<Option<ExcelStateDto>, String> {
    let language = window_language(&state);
    let Ok((path, account_id)) =
        state.with_excel(|import| (import.path.clone(), import.account_id))
    else {
        return Ok(None);
    };
    let conn = state.database()?;
    let label = radinus_core::accounts::get(&conn, account_id)
        .map_err(to_ipc_error)?
        .map(|account| account.label)
        .unwrap_or_default();
    Ok(Some(ExcelStateDto {
        path,
        said: radinus_core::i18n::text_with(language, "excel-into-account", "account", &label),
    }))
}

/// Une ligne de la table de concordance.
#[derive(Serialize, serde::Deserialize, Clone)]
pub struct ExcelLinkDto {
    pub header: String,
    pub field: String,
}

/// Ce que montre le premier onglet de l'étape 2.
#[derive(Serialize)]
pub struct ExcelLinksDto {
    /// Les en-têtes captés — ce que propose la combo de gauche, plus [IGNORE].
    pub headers: Vec<String>,
    /// Les rubriques Radinus — ce que propose la combo de droite. Elle
    /// **s'adapte à la forme du montant** déclarée à l'étape 1, si bien qu'une
    /// incohérence entre les deux n'est plus seulement refusée : elle n'est
    /// plus offerte.
    pub fields: Vec<String>,
    pub links: Vec<ExcelLinkDto>,
}

#[tauri::command]
pub fn excel_links(state: State<'_, AppState>) -> Result<ExcelLinksDto, String> {
    state.with_excel(|import| ExcelLinksDto {
        headers: import.grid.headers.clone(),
        fields: excel::fields(import.capture.shape)
            .into_iter()
            .map(str::to_string)
            .collect(),
        links: import
            .links
            .iter()
            .map(|link| ExcelLinkDto {
                header: link.header.clone(),
                field: link.field.clone(),
            })
            .collect(),
    })
}

/// Enregistre la concordance telle que la fenêtre la tient, et rend la raison
/// du refus s'il y en a une — déjà traduite.
#[tauri::command]
pub fn excel_set_links(
    state: State<'_, AppState>,
    links: Vec<ExcelLinkDto>,
) -> Result<Option<String>, String> {
    let language = window_language(&state);
    state.with_excel(|import| {
        import.links = links
            .iter()
            .map(|link| excel::Link {
                header: link.header.clone(),
                field: link.field.clone(),
            })
            .collect();
        excel::refusal(&import.links, &import.grid, import.capture.shape)
            .map(|key| radinus_core::i18n::text(language, key))
    })
}

/// Le réglage d'une nomenclature, tel que le second onglet le tient.
#[derive(Serialize, serde::Deserialize)]
pub struct ExcelRuleDto {
    pub kind: String,
    pub policy: String,
    pub default_id: i64,
    /// La rubrique est-elle mise en concordance ? Un groupe dont la colonne
    /// n'est pas réglée ne veut rien dire, et son code le dit lui-même :
    /// `SI nNumCol < 1 ALORS RETOUR`.
    pub linked: bool,
    /// La fenêtre d'association a-t-elle servi ?
    pub answered: bool,
    /// Le titre du groupe et les quatre libellés de ses boutons radio, déjà
    /// déclinés pour cette nomenclature. **Ils ne peuvent pas venir du
    /// dictionnaire** : ce sont des phrases à trou, et seule Fluent sait où est
    /// le trou.
    pub group: String,
    pub labels: Vec<String>,
    /// La phrase qui explique qu'un groupe est éteint faute de colonne.
    pub unlinked_note: String,
}

fn kind_of(key: &str) -> Result<Nomenclature, String> {
    Nomenclature::from_key(key).ok_or_else(|| format!("Nomenclature inconnue : {key}"))
}

#[tauri::command]
pub fn excel_policies(state: State<'_, AppState>) -> Result<Vec<ExcelRuleDto>, String> {
    let language = window_language(&state);
    state.with_excel(|import| {
        excel::SORTED
            .iter()
            .map(|(kind, field)| {
                let rule = import.policies.rule(*kind);
                let group = match *kind {
                    Nomenclature::Assignment => "excel-group-assignment",
                    Nomenclature::PaymentMode => "excel-group-payment-mode",
                    _ => "excel-group-category",
                };
                ExcelRuleDto {
                    kind: kind.key().to_string(),
                    policy: rule.policy.key().to_string(),
                    default_id: rule.default_id,
                    linked: excel::column_of(&import.links, &import.grid, field).is_some(),
                    answered: rule.answered,
                    group: radinus_core::i18n::text(language, group),
                    // L'ordre est celui de sa capture : créer, demander,
                    // laisser vierge, valeur par défaut.
                    labels: [
                        "excel-policy-create",
                        "excel-policy-ask",
                        "excel-policy-blank",
                        "excel-policy-default",
                    ]
                    .iter()
                    .map(|key| radinus_core::i18n::about(language, key, kind.key()))
                    .collect(),
                    unlinked_note: radinus_core::i18n::about(
                        language,
                        "excel-not-linked",
                        kind.key(),
                    ),
                }
            })
            .collect()
    })
}

#[tauri::command]
pub fn excel_set_policy(
    state: State<'_, AppState>,
    kind: String,
    policy: String,
    default_id: i64,
) -> Result<(), String> {
    let kind = kind_of(&kind)?;
    let policy = excel::Policy::from_key(&policy);
    state.with_excel(|import| {
        let rule = import.policies.rule_mut(kind);
        // Changer de politique périme ce que la fenêtre d'association avait
        // rapporté : ce n'est plus la même question.
        if rule.policy != policy {
            rule.chosen.clear();
            rule.answered = false;
        }
        rule.policy = policy;
        rule.default_id = default_id;
    })
}

/// Une valeur du fichier à ranger, et ce qu'on en a décidé.
#[derive(Serialize)]
pub struct ExcelUnknownDto {
    /// Le libellé tel que le fichier l'écrit.
    pub label: String,
    /// L'élément Radinus choisi, ou 0 tant qu'on n'a rien choisi.
    pub chosen_id: i64,
}

/// Ce que montre la fenêtre d'association des données : **uniquement les
/// valeurs que Radinus ne connaît pas**, et la liste de celles qu'il connaît.
#[derive(Serialize)]
pub struct ExcelAssociationDto {
    pub kind: String,
    /// Le titre de la colonne de droite, décliné pour cette nomenclature —
    /// `Categorie_Radinus`, `MoyenPaiement_Radinus`, `Affectation_Radinus`.
    pub column_title: String,
    pub values: Vec<ExcelUnknownDto>,
    /// La combo ne propose **que l'existant** (règle de Fabrice, 29/07/2026) :
    /// cette fenêtre sert à ranger un libellé mal orthographié dans une valeur
    /// qui existe, pas à en créer.
    pub choices: Vec<ItemDto>,
}

#[tauri::command]
pub fn excel_association(
    state: State<'_, AppState>,
    kind: String,
) -> Result<ExcelAssociationDto, String> {
    let kind = kind_of(&kind)?;
    // **La langue se demande avant de prendre la connexion, et jamais après.**
    // `window_language` verrouille lui-même la base ; l'appeler alors que la
    // connexion est déjà tenue verrouille deux fois le même mutex, qui n'est
    // pas réentrant : le fil s'attend lui-même, pour toujours. C'est ce qui
    // figeait cette fenêtre et tout le logiciel avec elle, jusqu'au blanc
    // (signalé par Fabrice, 30/07/2026).
    let language = window_language(&state);
    let conn = state.database()?;
    let values = state.with_excel(|import| {
        let unknown = excel::unknown_values(&conn, &import.grid, &import.links, kind)
            .unwrap_or_default();
        let rule = import.policies.rule(kind);
        unknown
            .into_iter()
            .map(|label| {
                let chosen_id = rule
                    .chosen
                    .get(&excel::key_of(&label))
                    .copied()
                    .unwrap_or(0);
                ExcelUnknownDto { label, chosen_id }
            })
            .collect::<Vec<_>>()
    })?;
    Ok(ExcelAssociationDto {
        kind: kind.key().to_string(),
        column_title: radinus_core::i18n::about(language, "excel-column-destination", kind.key()),
        values,
        choices: nomenclatures::list(&conn, kind)
            .map_err(to_ipc_error)?
            .into_iter()
            .map(|item| ItemDto {
                id: item.id,
                label: item.label,
            })
            .collect(),
    })
}

/// Ce que la fenêtre d'association rapporte. Une ligne laissée sans choix
/// garde l'identifiant 0 : la valeur restera vide pour ces opérations-là,
/// comme dans son code.
#[tauri::command]
pub fn excel_set_association(
    state: State<'_, AppState>,
    kind: String,
    values: Vec<ExcelUnknownDto2>,
) -> Result<(), String> {
    let kind = kind_of(&kind)?;
    state.with_excel(|import| {
        let rule = import.policies.rule_mut(kind);
        rule.chosen.clear();
        for value in &values {
            rule.chosen
                .insert(excel::key_of(&value.label), value.chosen_id);
        }
        // **C'est la fenêtre qui doit avoir été validée, pas chacune de ses
        // lignes** : ce qui n'a pas été rangé restera vide.
        rule.answered = true;
    })
}

/// Le même couple, en entrée. Un type distinct parce que `serde` sépare ce que
/// l'on rend de ce que l'on reçoit.
#[derive(serde::Deserialize)]
pub struct ExcelUnknownDto2 {
    pub label: String,
    pub chosen_id: i64,
}

/// Une ligne refusée, telle que le compte-rendu la montre.
#[derive(Serialize)]
pub struct ExcelRefusedDto {
    pub row: usize,
    pub content: String,
    pub reason: String,
}

/// Le compte-rendu de fin d'import.
#[derive(Serialize)]
pub struct ExcelReportDto {
    pub imported: i64,
    pub created: i64,
    pub refused: Vec<ExcelRefusedDto>,
    pub said: String,
}

/// Pourquoi l'étape 2 ne peut pas se valider, ou `None`.
///
/// Deux barrières : la concordance elle-même (les trois obligatoires et les
/// deux doublons), et **une politique « demander » dont la destination n'a
/// jamais été définie** — on ne laisse pas un choix rester sans effet
/// (décision de Fabrice, 29/07/2026).
#[tauri::command]
pub fn excel_run_refusal(state: State<'_, AppState>) -> Result<Option<String>, String> {
    let language = window_language(&state);
    state.with_excel(|import| {
        if let Some(key) = excel::refusal(&import.links, &import.grid, import.capture.shape) {
            return Some(radinus_core::i18n::text(language, key));
        }
        for (kind, field) in excel::SORTED {
            let linked = excel::column_of(&import.links, &import.grid, field).is_some();
            let rule = import.policies.rule(kind);
            if linked && rule.policy == excel::Policy::Ask && !rule.answered {
                return Some(radinus_core::i18n::about(
                    language,
                    "excel-refusal-ask-unset",
                    kind.key(),
                ));
            }
        }
        None
    })
}

/// L'étape 3/3 : l'intégration. **Tout ou rien**, et les soldes recalculés.
#[tauri::command]
pub fn excel_run<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
) -> Result<ExcelReportDto, String> {
    let language = window_language(&state);
    if let Some(refusal) = excel_run_refusal(state.clone())? {
        return Err(refusal);
    }
    let (account_id, grid, links, shape, policies) = state.with_excel(|import| {
        (
            import.account_id,
            import.grid.clone(),
            import.links.clone(),
            import.capture.shape,
            import.policies.clone(),
        )
    })?;

    let report = {
        let mut conn = state.database()?;
        excel::run(&mut conn, account_id, &grid, &links, shape, &policies).map_err(to_ipc_error)?
    };

    let said = radinus_core::i18n::message_of(
        language,
        "excel-imported",
        &[],
        &[
            ("count", report.imported),
            ("refused", report.refused.len() as i64),
            ("created", report.created),
        ],
    );
    // Ce qui vient d'entrer se voit partout : les listes et les soldes se
    // relisent.
    let _ = app.emit("data-changed:operations", ());
    let _ = app.emit("data-changed:accounts-list", ());
    for (kind, _) in excel::SORTED {
        let _ = app.emit(&format!("data-changed:{}-list", kind.key()), ());
    }
    Ok(ExcelReportDto {
        imported: report.imported,
        created: report.created,
        refused: report
            .refused
            .into_iter()
            .map(|refused| ExcelRefusedDto {
                row: refused.row,
                content: refused.content,
                reason: radinus_core::i18n::text(language, refused.reason),
            })
            .collect(),
        said,
    })
}

/// Ouvre l'étape 1/3 sur un compte.
#[tauri::command]
pub fn open_excel_import<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    account_id: i64,
) -> Result<(), String> {
    let language = window_language(&state);
    // Redemander la fenêtre repart d'une feuille blanche : ce qui n'a pas été
    // intégré n'a jamais existé.
    state.drop_excel()?;
    crate::windows::open(
        &app,
        &crate::windows::excel_import_window(language),
        Some(&format!("account={account_id}")),
    )
    .map_err(to_ipc_error)
}

/// Passe à l'étape 2/3.
#[tauri::command]
pub fn open_excel_fields<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
) -> Result<(), String> {
    let language = window_language(&state);
    crate::windows::open(&app, &crate::windows::excel_fields_window(language), None)
        .map_err(to_ipc_error)
}

/// Ouvre la fenêtre d'association des données pour une nomenclature — le
/// bouton « Définir destination ».
#[tauri::command]
pub fn open_excel_association<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    kind: String,
) -> Result<(), String> {
    let kind = kind_of(&kind)?;
    let language = window_language(&state);
    crate::windows::open(
        &app,
        &crate::windows::excel_association_window(language),
        Some(&format!("kind={}", kind.key())),
    )
    .map_err(to_ipc_error)
}

/// Quitte une des trois fenêtres de l'import Excel.
#[tauri::command]
pub fn close_excel_window<R: Runtime>(app: AppHandle<R>, label: String) -> Result<(), String> {
    if let Some(window) = app.get_webview_window(&label) {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(())
}

// =====================================================================
// Phase 14 — le menu Export de F02 : les deux sorties bancaires.
//
// Les dix autres formats du menu passent par `export_sheet`, puisqu'ils
// exportent un tableau. L'OFX et le QIF, eux, exportent des **opérations** :
// la fenêtre leur donne les clefs de ce qu'elle affiche, dans son ordre, et le
// noyau les relit.
// =====================================================================

/// Écrit les opérations désignées en OFX ou en QIF, selon l'extension du nom
/// que l'utilisateur a choisi dans le sélecteur du système.
///
/// **Les clefs viennent de la fenêtre** : ce sont celles qu'elle montre, dans
/// l'ordre du tri en cours, et les mères seules — une opération ventilée
/// s'exporte pour son montant total, sans ses filles, faute de quoi l'argent
/// serait compté deux fois (règle de Fabrice, 30/07/2026).
#[tauri::command]
pub fn export_operations(
    state: State<'_, AppState>,
    account_id: i64,
    ids: Vec<i64>,
    path: String,
) -> Result<String, String> {
    let file = std::path::PathBuf::from(&path);
    let conn = state.database()?;
    let language = ui_language();
    // La date du jour est donnée au noyau plutôt que lue par lui : le noyau ne
    // connaît pas l'horloge, et c'est ce qui rend ses sorties comparables dans
    // un test.
    let today = time_compute::Local::now().date_naive();
    radinus_core::exports::write(&conn, account_id, &ids, &file, today).map_err(|error| {
        radinus_core::i18n::text_with(language, "export-failed", "reason", &error.to_string())
    })?;
    Ok(export_done(language, &file, &path))
}

// =====================================================================
// Phase 17 — les pièces jointes d'une opération (F28).
//
// Le noyau tient les lignes et les fichiers ; le contrôleur ouvre le sélecteur,
// confie un document au système et envoie à la corbeille. La fenêtre ne
// détient rien : elle demande et montre.
// =====================================================================

/// Une pièce jointe, telle que la fenêtre la montre.
#[derive(serde::Serialize)]
pub struct AttachmentDto {
    id: i64,
    name: String,
    /// Le nom physique — c'est lui que la colonne « Identifiant » montre :
    /// il identifie vraiment la pièce, dans le dossier comme dans les
    /// sauvegardes, là où la clef numérique ne dit rien à personne.
    guid_name: String,
    size: i64,
    size_text: String,
    mime: String,
    added: String,
    /// L'état du fichier sur le disque : « ok », « modifié », « absent », ou
    /// « inconnu » quand l'empreinte vient de 1.9.3 et ne peut pas être lue.
    state: String,
}

/// Un poids de fichier, écrit pour être lu.
fn readable_size(bytes: i64) -> String {
    const UNITS: [&str; 4] = ["o", "ko", "Mo", "Go"];
    let mut value = bytes as f64;
    let mut unit = 0;
    while value >= 1024.0 && unit < UNITS.len() - 1 {
        value /= 1024.0;
        unit += 1;
    }
    if unit == 0 {
        format!("{bytes} {}", UNITS[0])
    } else {
        format!("{value:.2} {}", UNITS[unit])
    }
}

fn attachment_dto(
    attachment: radinus_core::attachments::Attachment,
    folder: &std::path::Path,
    language: Language,
) -> AttachmentDto {
    let path = radinus_core::attachments::path_in(folder, &attachment.guid_name);
    let guid_name = attachment.guid_name.clone();
    let state = if !path.is_file() {
        "attachment-state-missing"
    } else {
        match radinus_core::attachments::is_intact(&path, &attachment.checksum) {
            Some(true) => "attachment-state-ok",
            Some(false) => "attachment-state-changed",
            None => "attachment-state-unknown",
        }
    };
    AttachmentDto {
        id: attachment.id,
        name: attachment.name,
        guid_name,
        size: attachment.size,
        size_text: readable_size(attachment.size),
        mime: attachment.mime,
        added: attachment
            .added
            .map(|date| date.format("%d/%m/%Y").to_string())
            .unwrap_or_default(),
        state: radinus_core::i18n::text(language, state),
    }
}

#[tauri::command]
pub fn list_attachments(
    state: State<'_, AppState>,
    operation_id: i64,
) -> Result<Vec<AttachmentDto>, String> {
    let folder = state.attachments_dir();
    let conn = state.database()?;
    let language = ui_language();
    Ok(radinus_core::attachments::list(&conn, operation_id)
        .map_err(to_ipc_error)?
        .into_iter()
        .map(|attachment| attachment_dto(attachment, &folder, language))
        .collect())
}

/// Joint un document à une opération.
///
/// Le sélecteur est ouvert **sans être attendu** sur le fil principal, comme
/// celui des relevés bancaires : le système rappelle avec le choix.
#[tauri::command]
pub async fn add_attachment<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    operation_id: i64,
) -> Result<String, String> {
    use tauri_plugin_dialog::DialogExt;
    let language = window_language(&state);
    let folder = state.attachments_dir();

    let (answered, answer) = std::sync::mpsc::channel();
    app.dialog()
        .file()
        .add_filter(
            radinus_core::i18n::text(language, "attachment-filter"),
            radinus_core::attachments::ALLOWED,
        )
        .pick_file(move |chosen| {
            let _ = answered.send(chosen);
        });
    let Ok(Some(chosen)) = answer.recv() else {
        return Ok(String::new());
    };
    let source = chosen.into_path().map_err(to_ipc_error)?;

    let today = time_compute::Local::now().date_naive();
    let conn = state.database()?;
    match radinus_core::attachments::add(&conn, operation_id, &source, &folder, today) {
        Ok(added) => Ok(radinus_core::i18n::text_with(
            language,
            "attachment-added",
            "name",
            &added.name,
        )),
        Err(radinus_core::attachments::Failure::Refused(key)) => {
            Err(radinus_core::i18n::text(language, key))
        }
        Err(error) => Err(radinus_core::i18n::text_with(
            language,
            "attachment-failed",
            "reason",
            &error.to_string(),
        )),
    }
}

/// Remplace le document d'une pièce jointe par un autre.
///
/// La pièce reste la même — même clef, même opération —, seul le document
/// change. L'ancien fichier part à la corbeille une fois le nouveau en place.
#[tauri::command]
pub async fn replace_attachment<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    id: i64,
) -> Result<String, String> {
    use tauri_plugin_dialog::DialogExt;
    let language = window_language(&state);
    let folder = state.attachments_dir();

    let (answered, answer) = std::sync::mpsc::channel();
    app.dialog()
        .file()
        .add_filter(
            radinus_core::i18n::text(language, "attachment-filter"),
            radinus_core::attachments::ALLOWED,
        )
        .pick_file(move |chosen| {
            let _ = answered.send(chosen);
        });
    let Ok(Some(chosen)) = answer.recv() else {
        return Ok(String::new());
    };
    let source = chosen.into_path().map_err(to_ipc_error)?;

    let today = time_compute::Local::now().date_naive();
    let conn = state.database()?;
    match radinus_core::attachments::replace(&conn, id, &source, &folder, today) {
        Ok((changed, previous)) => {
            // L'ancien document rejoint la corbeille : il n'est plus désigné
            // par rien, mais une erreur de manipulation se rattrape encore.
            let _ = crate::system::move_to_trash(&previous);
            Ok(radinus_core::i18n::text_with(
                language,
                "attachment-replaced",
                "name",
                &changed.name,
            ))
        }
        Err(radinus_core::attachments::Failure::Refused(key)) => {
            Err(radinus_core::i18n::text(language, key))
        }
        Err(error) => Err(radinus_core::i18n::text_with(
            language,
            "attachment-failed",
            "reason",
            &error.to_string(),
        )),
    }
}

/// Ouvre la pièce jointe avec l'application du système qui sait la lire.
///
/// **L'intégrité est vérifiée avant d'ouvrir**, quand l'empreinte est des
/// nôtres : un document qui a bougé depuis qu'il a été joint n'est plus la
/// pièce que l'on croit produire, et le dire après coup ne servirait à rien.
#[tauri::command]
pub fn open_attachment(state: State<'_, AppState>, id: i64) -> Result<String, String> {
    let folder = state.attachments_dir();
    let conn = state.database()?;
    let language = ui_language();
    let Some(attachment) = radinus_core::attachments::get(&conn, id).map_err(to_ipc_error)? else {
        return Err(radinus_core::i18n::text(language, "attachment-gone"));
    };
    let path = radinus_core::attachments::path_in(&folder, &attachment.guid_name);
    if !path.is_file() {
        return Err(radinus_core::i18n::text_with(
            language,
            "attachment-file-missing",
            "name",
            &attachment.name,
        ));
    }
    let changed = radinus_core::attachments::is_intact(&path, &attachment.checksum) == Some(false);
    crate::system::open_with_desktop(&path).map_err(|error| {
        radinus_core::i18n::text_with(language, "attachment-failed", "reason", &error.to_string())
    })?;
    Ok(if changed {
        radinus_core::i18n::text_with(language, "attachment-opened-changed", "name", &attachment.name)
    } else {
        radinus_core::i18n::text_with(language, "attachment-opened", "name", &attachment.name)
    })
}

/// La question posée avant de retirer une pièce jointe.
#[tauri::command]
pub fn attachment_removal_question(
    state: State<'_, AppState>,
    id: i64,
) -> Result<String, String> {
    let conn = state.database()?;
    let language = ui_language();
    let name = radinus_core::attachments::get(&conn, id)
        .map_err(to_ipc_error)?
        .map(|attachment| attachment.name)
        .unwrap_or_default();
    Ok(radinus_core::i18n::text_with(
        language,
        "attachment-remove-question",
        "name",
        &name,
    ))
}

/// Retire une pièce jointe : la ligne part, le fichier va à la corbeille.
#[tauri::command]
pub fn delete_attachment(state: State<'_, AppState>, id: i64) -> Result<String, String> {
    let folder = state.attachments_dir();
    let conn = state.database()?;
    let language = ui_language();
    let Some(path) = radinus_core::attachments::remove(&conn, id, &folder).map_err(to_ipc_error)?
    else {
        return Err(radinus_core::i18n::text(language, "attachment-gone"));
    };
    // La ligne est partie ; si la corbeille refuse le fichier, on le dit sans
    // faire croire que la suppression a échoué — elle a eu lieu.
    match crate::system::move_to_trash(&path) {
        Ok(()) => Ok(radinus_core::i18n::text(language, "attachment-removed")),
        Err(_) => Ok(radinus_core::i18n::text(language, "attachment-removed-kept")),
    }
}

/// Une ligne de « Gestion des pièces jointes », telle que la fenêtre la pose.
#[derive(Serialize)]
pub struct InventoryRowDto {
    /// Vaut 0 pour un orphelin : il n'a pas de ligne en base.
    pub id: i64,
    /// Le nom de disque, seule prise sur un orphelin.
    pub guid_name: String,
    pub orphan: bool,
    /// L'opération qui porte la pièce, et le compte sur lequel sa fiche
    /// s'ouvre. Zéro tous les deux pour un orphelin, qui n'appartient à rien.
    pub operation_id: i64,
    pub account_id: i64,
    /// Le fichier est-il là ? **Un fait, pas une phrase** : décider d'après le
    /// libellé de l'état marcherait en français et nulle part ailleurs.
    pub on_disk: bool,
    pub date: String,
    /// La date en ISO, sur quoi la colonne se trie.
    pub date_key: String,
    pub operation: String,
    pub amount: String,
    pub name: String,
    pub size: String,
    /// La taille en octets, sur quoi la colonne se trie.
    pub size_key: i64,
    pub added: String,
    pub added_key: String,
    pub state: String,
    pub note: String,
}

/// **L'inventaire de toutes les pièces jointes** (Fabrice, 08/08/2026).
///
/// Le noyau rend des nombres et des états ; ce sont les phrases qui se
/// composent ici, dans la langue en cours — la vue n'en écrit aucune.
#[tauri::command]
pub fn attachments_inventory(state: State<'_, AppState>) -> Result<Vec<InventoryRowDto>, String> {
    use radinus_core::attachments::Health;
    let folder = state.attachments_dir();
    let conn = state.database()?;
    let language = ui_language();
    let lines = radinus_core::attachments::inventory(&conn, &folder).map_err(to_ipc_error)?;
    Ok(lines
        .into_iter()
        .map(|line| {
            let state_key = match line.health {
                Health::Intact => "attachments-state-intact",
                Health::Altered => "attachments-state-altered",
                Health::Missing => "attachments-state-missing",
                Health::Unknown => "attachments-state-unknown",
                Health::Orphan => "attachments-state-orphan",
            };
            let operation = line.operation.as_ref();
            InventoryRowDto {
                id: line.id.unwrap_or(0),
                guid_name: line.guid_name,
                orphan: line.health == Health::Orphan,
                operation_id: operation.map(|found| found.id).unwrap_or(0),
                account_id: operation.map(|found| found.account_id).unwrap_or(0),
                on_disk: line.health != Health::Missing,
                date: operation
                    .and_then(|found| found.date)
                    .map(|day| day.format("%d/%m/%Y").to_string())
                    .unwrap_or_default(),
                date_key: operation
                    .and_then(|found| found.date)
                    .map(|day| day.format("%Y-%m-%d").to_string())
                    .unwrap_or_default(),
                operation: operation
                    .map(|found| found.label.clone())
                    .unwrap_or_else(|| {
                        radinus_core::i18n::text(language, "attachments-no-operation")
                    }),
                amount: operation
                    .map(|found| radinus_core::money::format(found.amount, language))
                    .unwrap_or_default(),
                name: line.name,
                size: human_size(line.size),
                size_key: line.size,
                added: line
                    .added
                    .map(|day| day.format("%d/%m/%Y").to_string())
                    .unwrap_or_default(),
                added_key: line
                    .added
                    .map(|day| day.format("%Y-%m-%d").to_string())
                    .unwrap_or_default(),
                state: radinus_core::i18n::text(language, state_key),
                note: line.note,
            }
        })
        .collect())
}

/// Une taille lisible. **Les unités ne se traduisent pas** : « Ko », « Mo »,
/// « KB », « MB » — c'est le même octet partout, et inventer dix-huit jeux
/// d'abréviations ferait dix-huit occasions de se tromper.
fn human_size(bytes: i64) -> String {
    const STEP: f64 = 1024.0;
    let value = bytes.max(0) as f64;
    if value < STEP {
        return format!("{bytes} o");
    }
    for (rank, unit) in ["Ko", "Mo", "Go"].iter().enumerate() {
        let divisor = STEP.powi(rank as i32 + 1);
        if value < divisor * STEP || rank == 2 {
            return format!("{:.1} {unit}", value / divisor);
        }
    }
    format!("{bytes} o")
}

/// Ce que dit la barre du bas : combien de pièces, et la place qu'elles
/// prennent.
#[tauri::command]
pub fn attachments_summary(state: State<'_, AppState>) -> Result<String, String> {
    let folder = state.attachments_dir();
    let conn = state.database()?;
    let language = ui_language();
    let lines = radinus_core::attachments::inventory(&conn, &folder).map_err(to_ipc_error)?;
    let total: i64 = lines.iter().map(|line| line.size).sum();
    Ok(radinus_core::i18n::message_of(
        language,
        "attachments-manager-summary",
        &[
            ("count", &lines.len().to_string()),
            ("size", &human_size(total)),
        ],
        &[],
    ))
}

/// Le nom de disque d'une pièce, pour la barre du bas.
#[tauri::command]
pub fn attachment_disk_name(name: String) -> String {
    radinus_core::i18n::text_with(ui_language(), "attachments-disk-name", "name", &name)
}

/// Ouvre un fichier orphelin — celui qu'aucune opération ne réclame.
///
/// Il n'a pas de ligne en base, donc pas d'empreinte à vérifier : on ne peut
/// rien dire de son intégrité, et on ne prétend rien.
#[tauri::command]
pub fn open_orphan_attachment(
    state: State<'_, AppState>,
    guid_name: String,
) -> Result<(), String> {
    let folder = state.attachments_dir();
    let language = ui_language();
    let Some(path) = radinus_core::attachments::checked_path(&folder, &guid_name) else {
        return Err(radinus_core::i18n::text_with(
            language,
            "attachment-file-missing",
            "name",
            &guid_name,
        ));
    };
    crate::system::open_with_desktop(&path).map_err(|error| {
        radinus_core::i18n::text_with(language, "attachment-failed", "reason", &error.to_string())
    })
}

/// **Montre le fichier dans le navigateur de fichiers du système**, désigné
/// parmi ses voisins (Fabrice, 08/08/2026).
///
/// Une pièce jointe de Radinus porte un nom de GUID : la retrouver à l'œil
/// dans un dossier qui en contient trois cents n'est pas un travail qu'on
/// demande à quelqu'un. Le fichier est donc **sélectionné**, pas seulement
/// entouré de son dossier.
///
/// La fenêtre n'envoie qu'un nom, jamais un chemin : c'est le noyau qui vérifie
/// que ce nom désigne bien un fichier du dossier des pièces jointes, et lui
/// seul qui sait où ce dossier se trouve.
#[tauri::command]
pub fn reveal_attachment(state: State<'_, AppState>, guid_name: String) -> Result<(), String> {
    let folder = state.attachments_dir();
    let language = ui_language();
    let Some(path) = radinus_core::attachments::checked_path(&folder, &guid_name) else {
        return Err(radinus_core::i18n::text_with(
            language,
            "attachment-file-missing",
            "name",
            &guid_name,
        ));
    };
    crate::system::reveal_in_file_manager(&path).map_err(|error| {
        radinus_core::i18n::text_with(language, "attachment-failed", "reason", &error.to_string())
    })
}

/// La question posée avant de jeter un fichier orphelin.
#[tauri::command]
pub fn orphan_removal_question() -> String {
    radinus_core::i18n::text(ui_language(), "attachments-orphan-remove-question")
}

/// Jette un fichier orphelin à la corbeille. Rien à effacer en base : par
/// définition, aucune ligne ne le réclame.
#[tauri::command]
pub fn delete_orphan_attachment(
    state: State<'_, AppState>,
    guid_name: String,
) -> Result<String, String> {
    let folder = state.attachments_dir();
    let language = ui_language();
    let Some(path) = radinus_core::attachments::checked_path(&folder, &guid_name) else {
        return Err(radinus_core::i18n::text(language, "attachment-gone"));
    };
    match crate::system::move_to_trash(&path) {
        Ok(()) => Ok(radinus_core::i18n::text(language, "attachment-removed")),
        Err(_) => Ok(radinus_core::i18n::text(language, "attachment-removed-kept")),
    }
}

#[tauri::command]
pub fn open_attachments_window<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    operation_id: i64,
) -> Result<(), String> {
    let language = window_language(&state);
    let window = crate::windows::attachments_window(language);
    crate::windows::open(&app, &window, Some(&format!("operation={operation_id}")))
        .map_err(|error| error.to_string())
}

#[tauri::command]
pub fn close_attachments_window(app: AppHandle<impl Runtime>) -> Result<(), String> {
    if let Some(window) = app.get_webview_window("attachments") {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(())
}

// =====================================================================
// Phase 15 — les impressions et états.
//
// Le noyau compose et rend des octets ; le contrôleur les écrit et donne le
// fichier au système. Aucune fenêtre d'impression n'est ouverte : le PDF
// **est** l'aperçu avant impression, et la visionneuse du système est le
// dialogue d'impression (arbitrage de Fabrice, 01/08/2026).
// =====================================================================

/// Imprime la liste des opérations d'un compte : les lignes que la fenêtre
/// montre, dans l'ordre où elle les montre.
///
/// **Le PDF est écrit dans le dossier temporaire du système, puis ouvert.**
/// Il n'est pas demandé à l'utilisateur où le ranger : ce qu'il veut, c'est
/// voir son état, et sa visionneuse lui offrira aussi bien « Imprimer » que
/// « Enregistrer sous ». Un dialogue de plus avant de voir quoi que ce soit
/// serait un dialogue de trop.
#[tauri::command]
pub fn print_operations(
    state: State<'_, AppState>,
    ids: Vec<i64>,
    to_printer: bool,
    printer: Option<String>,
) -> Result<String, String> {
    let conn = state.database()?;
    let language = ui_language();
    if ids.is_empty() {
        return Ok(radinus_core::i18n::text(language, "print-nothing"));
    }
    // La date d'impression vient d'ici, comme partout : le noyau ne lit pas
    // l'horloge, ce qui rend ses sorties comparables dans un test.
    let today = time_compute::Local::now().date_naive();
    let report = radinus_core::printing::operations_report(&conn, &ids, language, today)
        .map_err(|error| {
            radinus_core::i18n::text_with(language, "print-failed", "reason", &error.to_string())
        })?;
    let bytes = radinus_core::printing::pdf(&report, language).map_err(|error| {
        radinus_core::i18n::text_with(language, "print-failed", "reason", &error.to_string())
    })?;

    let name = format!(
        "{} {}.pdf",
        crate::system::safe_file_name(&report.title),
        today.format("%Y-%m-%d")
    );
    let file = std::env::temp_dir().join(name);
    std::fs::write(&file, &bytes).map_err(|error| {
        radinus_core::i18n::text_with(language, "print-failed", "reason", &error.to_string())
    })?;

    let shown = file.to_string_lossy().to_string();

    // La sortie papier : l'imprimante choisie dans la fenêtre, ou celle par
    // défaut si le système n'a su en nommer aucune (Fabrice, 01/08/2026).
    if to_printer {
        return match crate::system::send_to_printer(&file, printer.as_deref()) {
            Ok(()) => Ok(match &printer {
                Some(name) => {
                    radinus_core::i18n::text_with(language, "print-sent-on", "printer", name)
                }
                None => radinus_core::i18n::text(language, "print-sent-default"),
            }),
            Err(error) => Err(radinus_core::i18n::text_with(
                language,
                "print-failed",
                "reason",
                &error.to_string(),
            )),
        };
    }

    // Le fichier est écrit : si le système ne sait pas l'ouvrir, ce n'est pas
    // un échec de l'impression, et on ne le présente pas comme tel.
    match crate::system::open_with_desktop(&file) {
        Ok(()) => Ok(radinus_core::i18n::text_with(
            language, "print-done", "file", &shown,
        )),
        Err(_) => Ok(radinus_core::i18n::text_with(
            language, "print-not-opened", "file", &shown,
        )),
    }
}

/// Les coordonnées bancaires d'un compte, telles que F32 les montre.
///
/// `None` quand le compte n'existe plus : la fenêtre le dit au lieu d'afficher
/// des cadres vides qui feraient croire à un compte sans RIB.
#[derive(serde::Serialize)]
pub struct BankDetails {
    bank: String,
    domiciliation: String,
    holder: String,
    holder_address: String,
    establishment: String,
    branch: String,
    number: String,
    key: String,
    iban: String,
    bic: String,
}

#[tauri::command]
pub fn bank_details(
    state: State<'_, AppState>,
    account_id: i64,
) -> Result<Option<BankDetails>, String> {
    let conn = state.database()?;
    let rib = radinus_core::printing::rib(&conn, account_id).map_err(to_ipc_error)?;
    Ok(rib.map(|rib| BankDetails {
        bank: rib.bank,
        domiciliation: rib.domiciliation,
        holder: rib.holder,
        holder_address: rib.holder_address,
        establishment: rib.establishment,
        branch: rib.branch,
        number: rib.number,
        key: rib.key,
        iban: rib.iban,
        bic: rib.bic,
    }))
}

/// Imprime le RIB : sur l'imprimante par défaut, ou en PDF.
///
/// **Le RIB est recomposé depuis la base à chaque impression**, jamais depuis
/// ce que la fenêtre affiche. F32 est en lecture seule et ne renvoie rien
/// d'autre que le numéro du compte : ce qui part chez le banquier est donc
/// toujours ce que porte la fiche.
///
/// La déclaration sur l'honneur est gardée par la fenêtre, qui éteint ses deux
/// boutons tant qu'elle n'est pas cochée (Fabrice, 01/08/2026).
#[tauri::command]
pub fn print_bank_details(
    state: State<'_, AppState>,
    account_id: i64,
    to_printer: bool,
    printer: Option<String>,
) -> Result<String, String> {
    let conn = state.database()?;
    let language = ui_language();
    let failed = |error: String| radinus_core::i18n::text_with(language, "rib-print-failed", "reason", &error);

    let rib = radinus_core::printing::rib(&conn, account_id)
        .map_err(|error| failed(error.to_string()))?
        .ok_or_else(|| radinus_core::i18n::text(language, "rib-account-gone"))?;
    let bytes =
        radinus_core::printing::rib_pdf(&rib, language).map_err(|error| failed(error.to_string()))?;

    let today = time_compute::Local::now().date_naive();
    let name = format!(
        "{} {}.pdf",
        crate::system::safe_file_name(&radinus_core::i18n::text(language, "rib-title")),
        today.format("%Y-%m-%d")
    );
    let file = std::env::temp_dir().join(name);
    std::fs::write(&file, &bytes).map_err(|error| failed(error.to_string()))?;
    let shown = file.to_string_lossy().to_string();

    if to_printer {
        // L'imprimante choisie dans la fenêtre, ou celle par défaut si le
        // système n'a su en nommer aucune.
        return match crate::system::send_to_printer(&file, printer.as_deref()) {
            Ok(()) => Ok(match &printer {
                Some(name) => {
                    radinus_core::i18n::text_with(language, "rib-printed-on", "printer", name)
                }
                None => radinus_core::i18n::text(language, "rib-printed"),
            }),
            Err(error) => Err(failed(error.to_string())),
        };
    }
    match crate::system::open_with_desktop(&file) {
        Ok(()) => Ok(radinus_core::i18n::text_with(
            language,
            "rib-pdf-done",
            "file",
            &shown,
        )),
        Err(_) => Ok(radinus_core::i18n::text_with(
            language,
            "rib-pdf-not-opened",
            "file",
            &shown,
        )),
    }
}

/// La porte de la fenêtre du journal. Comme les autres, elle se cache.
#[tauri::command]
pub fn close_journal_window(app: AppHandle<impl Runtime>) -> Result<(), String> {
    if let Some(window) = app.get_webview_window("journal") {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(())
}

/// Le journal de la dernière opération technique, pour la fenêtre ⌘H.
///
/// Vide tant qu'aucune sauvegarde, restauration, réparation ou effacement n'a
/// eu lieu depuis l'ouverture du logiciel : le journal ne survit pas à la
/// fermeture, il n'est pas une archive.
#[tauri::command]
pub fn journal_entries(state: State<'_, AppState>) -> Vec<radinus_core::journal::Entry> {
    state.journal()
}

/// Les imprimantes du système, celle par défaut en premier.
///
/// **Radinus pose lui-même la question du choix de l'imprimante** (demande de
/// Fabrice, 01/08/2026). Le dialogue d'impression du système n'est atteignable
/// depuis aucun des trois webviews, et aucune commande, sur aucun des trois
/// systèmes, ne l'ouvre pour un fichier PDF ; la fenêtre montre donc la liste
/// avec ses propres couleurs. Une liste vide n'est pas une faute : c'est un
/// poste sans imprimante, et la fenêtre le dit.
#[tauri::command]
pub fn list_printers() -> Vec<crate::system::Printer> {
    let mut found = crate::system::printers();
    found.sort_by(|a, b| b.is_default.cmp(&a.is_default).then_with(|| a.name.cmp(&b.name)));
    found
}

/// Ouvre F32 sur le compte choisi. Appelée par la liste des comptes en mode
/// choix, comme les autres fenêtres qui portent sur un compte unique.
#[tauri::command]
pub fn open_bank_details<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    account_id: i64,
) -> Result<(), String> {
    let language = window_language(&state);
    let window = crate::windows::rib_window(language);
    crate::windows::open(&app, &window, Some(&format!("account={account_id}")))
        .map_err(|error| error.to_string())
}

/// La porte de F32. La fenêtre est bâtie une fois et jamais détruite : sortir,
/// c'est la cacher.
#[tauri::command]
pub fn close_rib_window(app: AppHandle<impl Runtime>) -> Result<(), String> {
    if let Some(window) = app.get_webview_window("rib") {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(())
}

// =====================================================================
// Phase 16 — les opérations périodiques (F15, F38, F16).
//
// Une règle ne produit rien toute seule : on lui demande son calendrier, on y
// retire ce qu'on ne veut pas, et un second geste insère. Tout ce qui suit
// n'est que la traduction d'un appel JSON en un appel de
// `radinus_core::recurring_operations`.
// =====================================================================

use radinus_core::recurring_operations as recurring;

/// Une règle, telle que la liste F38 la montre : une seule colonne.
#[derive(Serialize)]
pub struct RecurringRowDto {
    pub id: i64,
    pub label: String,
}

/// Une règle, telle que sa fiche la tient.
#[derive(Serialize)]
pub struct RecurringRuleDto {
    pub id: i64,
    pub guid: String,
    pub account_id: i64,
    pub label: String,
    /// **Une grandeur** : le signe voyage dans `direction`, comme la fiche
    /// opération.
    pub amount: i64,
    pub direction: i64,
    pub category_id: i64,
    pub assignment_id: i64,
    pub payment_mode_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
    pub next_date: String,
    pub ending: String,
    pub end_date: String,
    pub unit: String,
    pub frequency: i64,
    pub repeat_count: i64,
    /// Les trois chiffres du bas de la fiche — **ceux de cette règle**.
    pub produced_count: i64,
    pub produced_total: String,
    pub produced_last: String,
}

/// Ce que la fiche renvoie.
#[derive(serde::Deserialize)]
pub struct RecurringRuleInput {
    pub account_id: i64,
    pub label: String,
    pub amount: String,
    pub direction: i64,
    pub category_id: i64,
    pub assignment_id: i64,
    pub payment_mode_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
    pub next_date: String,
    pub ending: String,
    pub end_date: String,
    pub unit: String,
    pub frequency: i64,
    pub repeat_count: i64,
}

fn as_day(text: &str) -> Option<radinus_core::domain::NaiveDate> {
    radinus_core::domain::NaiveDate::parse_from_str(text, "%Y-%m-%d").ok()
}

fn shown_day(date: Option<radinus_core::domain::NaiveDate>) -> String {
    date.map(|day| day.format("%Y-%m-%d").to_string())
        .unwrap_or_default()
}

fn unit_of(key: &str) -> recurring::Unit {
    recurring::Unit::ALL
        .into_iter()
        .find(|unit| unit.key() == key)
        .unwrap_or(recurring::Unit::Month)
}

fn ending_of(key: &str) -> recurring::Ending {
    match key {
        "until-date" => recurring::Ending::UntilDate,
        "repeat-count" => recurring::Ending::RepeatCount,
        _ => recurring::Ending::NoLimit,
    }
}

impl RecurringRuleInput {
    fn as_rule(&self) -> recurring::Rule {
        // Le montant part **tel qu'il est écrit** et c'est le noyau qui le
        // relit, comme partout ailleurs ; le sens lui donne son signe.
        let magnitude = radinus_core::money::parse_or_zero(&self.amount).unwrap_or(0).abs();
        recurring::Rule {
            id: 0,
            guid: String::new(),
            account_id: self.account_id,
            label: self.label.clone(),
            amount: if self.direction < 0 { -magnitude } else { magnitude },
            category_id: self.category_id,
            assignment_id: self.assignment_id,
            payment_mode_id: self.payment_mode_id,
            payee_id: self.payee_id,
            project_id: self.project_id,
            next_date: as_day(&self.next_date),
            ending: ending_of(&self.ending),
            end_date: as_day(&self.end_date),
            unit: unit_of(&self.unit),
            frequency: self.frequency.max(1),
            repeat_count: self.repeat_count.max(0),
        }
    }
}

#[tauri::command]
pub fn list_recurring_rules(state: State<'_, AppState>) -> Result<Vec<RecurringRowDto>, String> {
    let conn = state.database()?;
    Ok(recurring::list(&conn)
        .map_err(to_ipc_error)?
        .into_iter()
        .map(|rule| RecurringRowDto {
            id: rule.id,
            label: rule.label,
        })
        .collect())
}

#[tauri::command]
pub fn get_recurring_rule(
    state: State<'_, AppState>,
    id: i64,
) -> Result<Option<RecurringRuleDto>, String> {
    let conn = state.database()?;
    let language = ui_language();
    let Some(rule) = recurring::get(&conn, id).map_err(to_ipc_error)? else {
        return Ok(None);
    };
    let seen = recurring::produced(&conn, &rule.guid).map_err(to_ipc_error)?;
    Ok(Some(RecurringRuleDto {
        id: rule.id,
        guid: rule.guid,
        account_id: rule.account_id,
        label: rule.label,
        amount: rule.amount.abs(),
        direction: if rule.amount < 0 { -1 } else { 1 },
        category_id: rule.category_id,
        assignment_id: rule.assignment_id,
        payment_mode_id: rule.payment_mode_id,
        payee_id: rule.payee_id,
        project_id: rule.project_id,
        next_date: shown_day(rule.next_date),
        ending: rule.ending.key().to_string(),
        end_date: shown_day(rule.end_date),
        unit: rule.unit.key().to_string(),
        frequency: rule.frequency,
        repeat_count: rule.repeat_count,
        produced_count: seen.count,
        produced_total: radinus_core::money::format(seen.total, language),
        produced_last: shown_day(seen.last_date),
    }))
}

/// Pourquoi la règle ne peut pas être enregistrée, déjà traduite, ou `null`.
#[tauri::command]
pub fn recurring_refusal(
    state: State<'_, AppState>,
    rule: RecurringRuleInput,
) -> Result<Option<String>, String> {
    let conn = state.database()?;
    let language = ui_language();
    Ok(recurring::refusal(&conn, &rule.as_rule())
        .map_err(to_ipc_error)?
        .map(|key| radinus_core::i18n::text(language, key)))
}

/// Ajoute une règle. **Le GUID naît ici**, et il ne changera plus : c'est
/// l'identité de tout ce que la règle produira.
///
/// Il est tiré du générateur d'aléa de SQLite plutôt que d'une crate de plus :
/// seize octets, c'est la taille d'un GUID, et la base sait déjà les fabriquer.
#[tauri::command]
pub fn create_recurring_rule(
    app: AppHandle<impl Runtime>,
    state: State<'_, AppState>,
    rule: RecurringRuleInput,
) -> Result<i64, String> {
    let conn = state.database()?;
    let guid: String = conn
        .query_row("SELECT lower(hex(randomblob(16)))", [], |row| row.get(0))
        .map_err(to_ipc_error)?;
    let id = recurring::create(&conn, &rule.as_rule(), &guid).map_err(to_ipc_error)?;
    drop(conn);
    let _ = app.emit("data-changed:recurring", ());
    Ok(id)
}

#[tauri::command]
pub fn update_recurring_rule(
    app: AppHandle<impl Runtime>,
    state: State<'_, AppState>,
    id: i64,
    rule: RecurringRuleInput,
) -> Result<bool, String> {
    let conn = state.database()?;
    let changed = recurring::update(&conn, id, &rule.as_rule()).map_err(to_ipc_error)?;
    drop(conn);
    let _ = app.emit("data-changed:recurring", ());
    Ok(changed)
}

/// Supprime des règles. **Leurs opérations restent** (décision de Fabrice) :
/// supprimer la règle arrête l'avenir et ne touche pas au passé.
#[tauri::command]
pub fn delete_recurring_rules(
    app: AppHandle<impl Runtime>,
    state: State<'_, AppState>,
    ids: Vec<i64>,
) -> Result<String, String> {
    let conn = state.database()?;
    let language = ui_language();
    let removed = recurring::delete(&conn, &ids).map_err(to_ipc_error)? as i64;
    drop(conn);
    let _ = app.emit("data-changed:recurring", ());
    Ok(radinus_core::i18n::message_of(
        language,
        "recurring-deleted",
        &[],
        &[("count", removed)],
    ))
}

/// La question posée avant d'effacer ce qu'une règle a produit — la corbeille
/// rouge de la fiche.
#[tauri::command]
pub fn recurring_erase_question(
    state: State<'_, AppState>,
    id: i64,
) -> Result<Option<String>, String> {
    let conn = state.database()?;
    let language = ui_language();
    let Some(rule) = recurring::get(&conn, id).map_err(to_ipc_error)? else {
        return Ok(None);
    };
    let seen = recurring::produced(&conn, &rule.guid).map_err(to_ipc_error)?;
    if seen.count == 0 {
        return Ok(None);
    }
    Ok(Some(radinus_core::i18n::message_of(
        language,
        "recurring-erase-question",
        &[],
        &[("count", seen.count)],
    )))
}

/// Efface, par le GUID, les opérations que la règle a produites. **La règle ne
/// recule pas.**
#[tauri::command]
pub fn erase_recurring_operations(
    app: AppHandle<impl Runtime>,
    state: State<'_, AppState>,
    id: i64,
) -> Result<String, String> {
    let mut conn = state.database()?;
    let language = ui_language();
    let Some(rule) = recurring::get(&conn, id).map_err(to_ipc_error)? else {
        return Err(radinus_core::i18n::text(language, "recurring-gone"));
    };
    let (removed, _) = recurring::erase(&mut conn, &rule.guid).map_err(to_ipc_error)?;
    drop(conn);
    for event in ["data-changed:operations", "data-changed:accounts-list"] {
        let _ = app.emit(event, ());
    }
    Ok(radinus_core::i18n::message_of(
        language,
        "recurring-erased",
        &[],
        &[("count", removed as i64)],
    ))
}

/// Une ligne du calendrier proposé, avec ses libellés résolus.
#[derive(Serialize)]
pub struct OccurrenceDto {
    pub rank: i64,
    pub account: String,
    pub date: String,
    pub label: String,
    /// En micro-unités, pour le tri et l'export en nombre.
    pub amount: i64,
    /// **Écrit par le noyau**, comme partout : l'interface n'invente aucun
    /// format monétaire.
    pub amount_text: String,
    pub category: String,
    pub assignment: String,
    pub payment_mode: String,
    pub payee: String,
    pub project: String,
}

/// Le calendrier des règles demandées. **Rien n'est écrit** : la proposition
/// vit dans l'état, et c'est un second geste qui insère.
#[tauri::command]
pub fn recurring_calendar(
    state: State<'_, AppState>,
    ids: Vec<i64>,
) -> Result<Vec<OccurrenceDto>, String> {
    let conn = state.database()?;
    let language = ui_language();
    let proposed = recurring::calendar(&conn, &ids).map_err(to_ipc_error)?;

    let name = |kind: Nomenclature, id: i64| -> String {
        nomenclatures::label_of(&conn, kind, id)
            .ok()
            .flatten()
            .unwrap_or_default()
    };
    let shown: Vec<OccurrenceDto> = proposed
        .iter()
        .map(|line| OccurrenceDto {
            rank: line.rank,
            account: radinus_core::accounts::get(&conn, line.account_id)
                .ok()
                .flatten()
                .map(|account| account.label)
                .unwrap_or_default(),
            date: line.date.format("%Y-%m-%d").to_string(),
            label: line.label.clone(),
            amount: line.amount,
            amount_text: radinus_core::money::format(line.amount, language),
            category: name(Nomenclature::Category, line.category_id),
            assignment: name(Nomenclature::Assignment, line.assignment_id),
            payment_mode: name(Nomenclature::PaymentMode, line.payment_mode_id),
            payee: name(Nomenclature::Payee, line.payee_id),
            project: name(Nomenclature::Project, line.project_id),
        })
        .collect();
    drop(conn);
    state.set_calendar(proposed)?;
    Ok(shown)
}

/// La phrase qui dit combien d'échéances viennent d'être retirées de la
/// proposition. Une phrase à trou se demande avec sa valeur, jamais rédigée
/// par la fenêtre.
#[tauri::command]
pub fn recurring_removed_text(
    state: State<'_, AppState>,
    count: i64,
) -> Result<String, String> {
    let _conn = state.database()?;
    let language = ui_language();
    Ok(radinus_core::i18n::message_of(
        language,
        "recurring-calendar-removed",
        &[],
        &[("count", count)],
    ))
}

/// La question posée **avant** d'insérer. Insérer un calendrier crée de vraies
/// opérations dans de vrais comptes : cela ne se fait pas sur un clic distrait
/// (demande de Fabrice, 31/07/2026).
#[tauri::command]
pub fn recurring_insert_question(
    state: State<'_, AppState>,
    count: i64,
) -> Result<String, String> {
    let _conn = state.database()?;
    let language = ui_language();
    Ok(radinus_core::i18n::message_of(
        language,
        "recurring-insert-question",
        &[],
        &[("count", count)],
    ))
}

/// Insère les échéances retenues — celles dont le rang est encore là après le
/// passage de la corbeille rouge.
#[tauri::command]
pub fn insert_recurring(
    app: AppHandle<impl Runtime>,
    state: State<'_, AppState>,
    ranks: Vec<i64>,
) -> Result<String, String> {
    let chosen = state.with_calendar(|proposed| {
        proposed
            .iter()
            .filter(|line| ranks.contains(&line.rank))
            .cloned()
            .collect::<Vec<_>>()
    })?;
    if chosen.is_empty() {
        let _conn = state.database()?;
        let language = ui_language();
        return Ok(radinus_core::i18n::text(language, "recurring-nothing"));
    }

    let mut conn = state.database()?;
    let language = ui_language();
    let today = time_compute::Local::now().date_naive();
    let done = recurring::insert(&mut conn, &chosen, today).map_err(to_ipc_error)?;
    drop(conn);

    for event in [
        "data-changed:operations",
        "data-changed:accounts-list",
        "data-changed:recurring",
    ] {
        let _ = app.emit(event, ());
    }
    Ok(radinus_core::i18n::message_of(
        language,
        "recurring-inserted",
        &[],
        &[("count", done.count)],
    ))
}

/// Ouvre la fiche d'une règle (F15), en ajout, modification ou consultation.
#[tauri::command]
pub fn open_recurring_form(
    app: AppHandle<impl Runtime>,
    state: State<'_, AppState>,
    mode: String,
    id: i64,
) -> Result<(), String> {
    let language = window_language(&state);
    crate::windows::open(
        &app,
        &crate::windows::recurring_form_window(language),
        Some(&format!("mode={mode}&id={id}")),
    )
    .map_err(to_ipc_error)
}

/// **Créer une opération périodique à partir d'une opération** (Fabrice,
/// 25/08/2026), depuis le menu Divers de F02.
///
/// La fiche F15 s'ouvre en création, préremplie de ce que l'opération sait
/// donner — son libellé, son montant, son sens, ses cinq nomenclatures. Le
/// rythme, lui, n'est nulle part dans une opération : la date prochaine, la
/// fréquence et la condition de fin restent celles d'une fiche neuve, et c'est
/// l'utilisateur qui les pose.
///
/// **Rien n'est écrit tant qu'il n'a pas enregistré la règle** — la même règle
/// que « Dupliquer », décidée le 26/07/2026 : une fiche pré-remplie qu'il
/// valide lui-même, jamais une écriture faite derrière son dos.
#[tauri::command]
pub fn open_recurring_form_from_operation(
    app: AppHandle<impl Runtime>,
    state: State<'_, AppState>,
    id: i64,
) -> Result<(), String> {
    let language = window_language(&state);
    crate::windows::open(
        &app,
        &crate::windows::recurring_form_window(language),
        Some(&format!("mode=A&id=0&from={id}")),
    )
    .map_err(to_ipc_error)
}

/// Ouvre la proposition de calendrier (F16) sur les règles choisies.
#[tauri::command]
pub fn open_recurring_calendar(
    app: AppHandle<impl Runtime>,
    state: State<'_, AppState>,
    ids: Vec<i64>,
) -> Result<(), String> {
    let language = window_language(&state);
    let list = ids
        .iter()
        .map(i64::to_string)
        .collect::<Vec<_>>()
        .join(",");
    crate::windows::open(
        &app,
        &crate::windows::recurring_calendar_window(language),
        Some(&format!("rules={list}")),
    )
    .map_err(to_ipc_error)
}

/// Quitte une des trois fenêtres des opérations périodiques.
#[tauri::command]
pub fn close_recurring_window(
    app: AppHandle<impl Runtime>,
    label: String,
) -> Result<(), String> {
    if let Some(window) = app.get_webview_window(&label) {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(())
}

// --- Le choix de la langue et le sélecteur de base ------------------------
//
// Décisions de Fabrice du 02/08/2026, prises en discussion :
//
// * Radinus ne crée plus une base au premier lancement sans rien demander ;
// * sans langue en configuration, il demande la langue **avant tout le
//   reste** — une seule fois dans la vie du logiciel ;
// * une base est tout dossier de `databases/` qui contient un
//   `radinus.sqlite`, quel que soit son nom : l'utilisateur a le droit de
//   renommer ses dossiers hors du logiciel ;
// * changer de base **relance Radinus**. Une fenêtre de Radinus est bâtie une
//   fois et jamais détruite : rebrancher la base sous des fenêtres ouvertes
//   les laisserait montrer les données de l'ancienne. Repartir du démarrage
//   est la seule façon sûre, et c'est celle que Fabrice a choisie.

/// Une base telle que le sélecteur la montre.
#[derive(Serialize)]
pub struct DatabaseDto {
    /// Le nom du dossier — `Radinus_00002`, ou ce que l'utilisateur en a fait.
    pub folder: String,
    /// Le chemin du SQLite, relatif à la racine des données.
    pub path: String,
    /// Le nom que l'utilisateur a donné à sa base.
    pub label: String,
    pub comment: String,
    /// `AAAA-MM-JJ`, ou vide quand on ne sait pas.
    pub created_on: String,
    pub created_by: String,
    pub schema_version: i64,
    /// La base ouverte en ce moment, ou celle qui le sera au prochain
    /// démarrage. Le sélecteur la marque.
    pub current: bool,
}

/// Les bases que `databases/` contient vraiment.
#[tauri::command]
pub fn list_databases(state: State<'_, AppState>) -> Result<Vec<DatabaseDto>, String> {
    let root = state.data_root.clone();
    let current = radinus_core::location::read_config(&root)
        .unwrap_or_default()
        .default_database;

    let found = radinus_core::location::list_databases(&root).map_err(to_ipc_error)?;
    Ok(found
        .into_iter()
        .map(|entry| DatabaseDto {
            current: current.as_deref() == Some(entry.relative_path.as_str()),
            folder: entry.folder,
            path: entry.relative_path,
            label: entry.info.label,
            comment: entry.info.comment,
            created_on: entry.info.created_on,
            created_by: entry.info.created_by,
            schema_version: entry.info.schema_version,
        })
        .collect())
}

/// **Le choix de la langue.**
///
/// Au tout premier lancement, et **aussi depuis le menu Paramètres de la
/// fenêtre des bases** (Fabrice, 04/08/2026 : « au cas où l'utilisateur change
/// d'avis ou s'est trompé »). C'est ce second usage qui a révélé le défaut
/// réparé ci-dessous : la commande avait été écrite quand elle était seule au
/// monde.
///
/// Elle s'écrit dans `settings/radinus_config.json`, et non dans une base.
/// Puis la fenêtre s'efface et le sélecteur de base prend sa place : c'est
/// l'ordre que Fabrice a fixé, la langue d'abord, la base ensuite.
///
/// **Sans relancer le logiciel.** Le redémarrage était ma première idée, et
/// Fabrice a trouvé ce qu'il coûtait le 02/08/2026 : le processus relancé
/// affichait des fenêtres blanches — cadre, titre, et rien dedans.
#[tauri::command]
pub fn choose_language(app: AppHandle<impl Runtime>, code: i64) -> Result<(), String> {
    let language = Language::from_id(code);

    // **Un seul chemin pour changer de langue** (réparation du 04/08/2026).
    //
    // Cette commande refaisait le travail de `switch_language` à sa façon :
    // écrire la configuration, préparer le dictionnaire, rebâtir la barre de
    // menus. Elle en oubliait la dernière étape — **prévenir les fenêtres
    // ouvertes** — parce qu'elle avait été écrite pour le tout premier
    // lancement, où il n'y en a aucune.
    //
    // Depuis que le menu Paramètres de la fenêtre des bases rouvre le choix de
    // la langue, il y a une fenêtre derrière : le sélecteur restait dans
    // l'ancienne langue, ses menus, ses colonnes et ses boutons compris
    // (relevé par Fabrice le jour même).
    //
    // Deux chemins qui font la même chose finissent toujours par ne plus la
    // faire pareil. Il n'y en a plus qu'un.
    crate::menu::switch_language(&app, code)?;

    crate::windows::open(&app, &crate::windows::database_selector_window(language), None)
        .map_err(to_ipc_error)?;
    if let Some(window) = app.get_webview_window("language-choice") {
        let _ = window.hide();
    }
    Ok(())
}

/// **Branche la base et lance vraiment le logiciel.**
///
/// Le chemin est relatif à la racine des données, comme la configuration le
/// stocke. La langue vient de la base elle-même dès qu'elle est ouverte : une
/// base sait dans quelle langue elle tourne, et c'est elle qui a le dernier
/// mot sur la configuration.
///
/// **Toutes les autres fenêtres se ferment d'abord.** C'est ce qui remplace le
/// redémarrage du logiciel : le résultat visible est le même — plus rien
/// d'ouvert, l'accueil sur la base choisie — sans tuer le processus. Radinus
/// disparaissait sans un mot et sans une ligne dans le terminal ; Fabrice l'a
/// vu le 02/08/2026 en cliquant sur « ouvrir ».
fn connect_and_start<R: Runtime>(
    app: &AppHandle<R>,
    state: &AppState,
    relative: &str,
    password: Option<&str>,
) -> Result<(), String> {
    let root = state.data_root.clone();
    let db_path = root.join(relative);
    let attachments = db_path
        .parent()
        .map(|slot| slot.join("attachments"))
        .unwrap_or_default();

    let radinus_core::database::Opened {
        conn: connection,
        report,
    } = radinus_core::database::open_existing_database(&db_path, password)
        // **Le refus se dit dans la langue de l'interface, quel qu'il soit**
        // (Fabrice, 03/10/2026). Seul le mot de passe refusé avait sa phrase ;
        // une base trop récente, un fichier qui n'en est pas une et une
        // erreur de lecture montraient le texte anglais du code. Le noyau
        // tient désormais les quatre phrases (`OpenError::said`).
        //
        // Pour le mot de passe : la fenêtre des bases a déjà demandé avant
        // d'appeler, donc arriver ici veut dire que ce qui a été tapé ne
        // déverrouille pas ce fichier-là.
        .map_err(|error| error.said(radinus_core::i18n::in_use()))?;

    // **Ouvrir une base ne change plus la langue** (décision de Fabrice,
    // 03/08/2026). C'est ici que se faisait la bascule qu'il a relevée :
    // Radinus démarrait dans la langue de `settings/radinus_config.json`, puis
    // cette ligne lui donnait celle de la base, et les deux n'étaient jamais
    // remises d'accord. La langue en cours ne bouge pas d'un pouce.
    //
    // On profite en revanche d'avoir la base sous la main pour lui recopier la
    // langue du logiciel : la colonne reste vraie pour Radinus 1.9.3, sans
    // jamais rien décider ici.
    let _ = radinus_core::i18n::store_language(&connection, radinus_core::i18n::in_use());

    // Fermées **avant** de rebrancher : une fenêtre encore visible pourrait
    // demander quelque chose à la nouvelle base avec un identifiant de
    // l'ancienne. On ne nomme personne — une fenêtre ajoutée demain sera
    // fermée sans qu'on y pense.
    for (label, window) in app.webview_windows() {
        if label != "main" && label != "database-selector" {
            let _ = window.hide();
        }
    }

    // `attach` jette au passage tous les brouillons en mémoire : ils
    // parlaient de l'ancienne base.
    state.attach(connection, attachments)?;

    // **Ce que l'ouverture a eu à rétablir, écrit noir sur blanc** (décision
    // de Fabrice, 03/08/2026 : « une ligne dans le journal, sans
    // interrompre »). Le cas ordinaire — une base complète — n'écrit rien du
    // tout, et le journal reste vide comme avant.
    //
    // C'est **après** `attach` que cela s'écrit, et pas avant : `attach` jette
    // tout ce qui parlait de la base précédente, journal compris.
    if !report.is_empty() {
        let mut journal = radinus_core::journal::Journal::new(radinus_core::i18n::in_use());
        for table in &report.created {
            journal.add(
                "journal-step-table-created",
                table,
                radinus_core::journal::Status::Repaired,
                "",
                "",
            );
        }
        for table in &report.reseeded {
            journal.add(
                "journal-step-refill",
                table,
                radinus_core::journal::Status::Repaired,
                "",
                "",
            );
        }
        // A column that was missing and has just been added. It reaches every
        // existing row holding its default value, which is why the wording says
        // so rather than claiming the data came back.
        for column in &report.columns {
            journal.add(
                "journal-step-column-added",
                column,
                radinus_core::journal::Status::Repaired,
                "",
                "",
            );
        }
        state.set_journal(journal.into_entries());
    }

    // La devise de cette base-ci : elle est lue une fois la base attachée,
    // et c'est l'un des deux seuls endroits qui posent le signe. La langue,
    // elle, n'est pas relue : elle appartient au logiciel, pas à la base.
    apply_preferences(state);
    let menu = crate::menu::build(app).map_err(to_ipc_error)?;
    crate::menu::install(app, menu).map_err(to_ipc_error)?;

    if let Some(main) = app.get_webview_window("main") {
        let _ = main.show();
        let _ = main.set_focus();
    }
    if let Some(window) = app.get_webview_window("database-selector") {
        let _ = window.hide();
    }
    Ok(())
}

/// **Ouvre une base.**
///
/// Le sélecteur paraît à chaque démarrage (décision de Fabrice, 02/08/2026) :
/// Radinus n'ouvre plus aucune base tout seul. Cette commande est donc le seul
/// chemin par lequel une base s'ouvre, qu'on vienne du démarrage ou du menu
/// Fichier alors qu'une autre tournait déjà.
///
/// Ce que la configuration retient n'est plus une « base par défaut » mais la
/// **dernière ouverte** : rien ne s'ouvre de soi-même, et ce souvenir ne sert
/// qu'à la montrer en gras dans le sélecteur.
#[tauri::command]
pub fn open_database(
    app: AppHandle<impl Runtime>,
    state: State<'_, AppState>,
    path: String,
    password: Option<String>,
) -> Result<(), String> {
    let root = state.data_root.clone();
    if !root.join(&path).is_file() {
        return Err(radinus_core::i18n::text(
            window_language(&state),
            "database-gone",
        ));
    }

    let mut config = radinus_core::location::read_config(&root).map_err(to_ipc_error)?;
    config.set_default_database(&path);
    radinus_core::location::write_config(&root, &config).map_err(to_ipc_error)?;

    connect_and_start(&app, &state, &path, password.as_deref())
}

/// **Crée une base : elle paraît dans le tableau, et rien de plus.**
///
/// Créer et ouvrir sont deux intentions différentes (Fabrice, 02/08/2026) :
/// l'ajout se contente d'ajouter. La base neuve n'est pas ouverte, elle ne
/// devient pas celle du prochain démarrage, et la configuration n'est pas
/// touchée — l'utilisateur ouvre ensuite celle qu'il veut, avec le bouton
/// d'ouverture, neuve ou ancienne.
///
/// Le libellé et le commentaire ne se saisissent qu'ici : ils disent d'où
/// vient la base, et l'origine d'une chose ne change pas. Ils sont écrits dans
/// `radinus_base.json`, à côté du SQLite, et suivent donc le dossier si on le
/// déplace ou le renomme.
///
/// La base neuve reçoit la langue de la configuration — celle que
/// l'utilisateur vient de choisir, ou celle qu'il emploie depuis toujours —
/// sous son numéro WinDev, comme toute base de Radinus.
#[tauri::command]
pub fn create_database(
    state: State<'_, AppState>,
    label: String,
    comment: String,
    currency: String,
    custom: String,
    archive: String,
) -> Result<String, String> {
    let root = state.data_root.clone();
    let language = window_language(&state);

    let label = label.trim().to_string();
    if label.is_empty() {
        return Err(radinus_core::i18n::text(language, "database-label-required"));
    }

    let slot = radinus_core::location::create_next_database_slot(&root).map_err(to_ipc_error)?;
    let db_path = slot.join(radinus_core::location::DATABASE_FILE_NAME);

    let connection = radinus_core::database::create_new_database(&db_path)
        .map_err(|error| error.to_string())?;
    radinus_core::i18n::store_language(&connection, language).map_err(to_ipc_error)?;

    // **La devise, écrite à la naissance** (Fabrice, 04/08/2026). Elle est une
    // préférence de la base et se règle en F39 ; la demander ici évite d'ouvrir
    // une base pour y poser la seule chose qu'on savait déjà en la créant.
    //
    // Un signe personnalisé passe par la même barrière qu'en F39 : un signe qui
    // ressemble à un morceau de nombre serait ôté par `money::parse`, et
    // « 120 » deviendrait « 12 » sans un mot. La base n'est pas créée pour
    // rien — elle l'est déjà — mais elle garde alors la devise par défaut, et
    // la fenêtre le dit.
    let chosen = radinus_core::preferences::Currency::from_parts(&currency, &custom);
    if matches!(chosen, radinus_core::preferences::Currency::Custom(_)) {
        if let Some(refusal) = radinus_core::preferences::sign_refusal(&custom, language) {
            drop(connection);
            return Err(refusal);
        }
    }
    // **La base peut naître pleine** (Fabrice, 04/08/2026). L'archive est
    // remontée dans la base qui vient d'être créée, avant qu'elle ne soit
    // ouverte par qui que ce soit : il n'y a donc aucune fenêtre à prévenir,
    // aucun brouillon à jeter, et rien de ce qui rendait une restauration
    // délicate. C'est le cas le plus sûr des trois.
    //
    // **Une archive illisible ne fait pas échouer la création** : la base
    // existe, elle est saine, et une base vide se remplit — tandis qu'un
    // dossier à moitié écrit sur le disque ne se rattrape pas. La fenêtre dit
    // ce qui s'est passé.
    let mut said_about_archive = String::new();
    if !archive.trim().is_empty() {
        let mut connection = connection;
        match radinus_core::backup::read_archive(std::path::Path::new(archive.trim()))
            .and_then(|read| radinus_core::backup::restore_into(&mut connection, &read))
        {
            Ok(report) => {
                said_about_archive = format!(
                    " {}",
                    radinus_core::i18n::message_of(
                        language,
                        "restore-done",
                        &[],
                        &[
                            ("accounts", report.accounts as i64),
                            ("operations", report.operations as i64),
                        ],
                    )
                );
                // **Les fichiers des pièces jointes sortent aussi de
                // l'archive** (bug remonté par un utilisateur le 10/08/2026).
                // Ce chemin-ci remontait les tables et s'arrêtait là : la
                // fenêtre de gestion connaissait chaque document, le dossier
                // n'en portait aucun, et tout s'affichait « fichier absent ».
                // Le menu Outils › Restauration, lui, les extrayait depuis le
                // premier jour — c'est le même appel, oublié ici seulement.
                //
                // Une extraction qui échoue ne fait pas échouer la création,
                // comme une archive illisible ne la fait pas échouer : la base
                // est saine, et des fichiers manquants se rejoignent à la main.
                // Le dossier voisin du fichier, celui que `create_next_database_slot`
                // vient de créer et que l'ouverture retiendra.
                let folder = slot.join("attachments");
                if let Err(error) =
                    radinus_core::backup::restore_attachments(
                        std::path::Path::new(archive.trim()),
                        &folder,
                    )
                {
                    eprintln!("[radinus] Attachments not restored: {error}");
                }
                // L'archive porte sa langue et sa devise ; **celles de la
                // fenêtre l'emportent**, parce qu'on vient de les choisir.
                let _ = radinus_core::i18n::store_language(&connection, language);
            }
            Err(error) => {
                said_about_archive = format!(
                    " {}",
                    radinus_core::i18n::text_with(
                        language,
                        "restore-failed",
                        "reason",
                        &error.to_string(),
                    )
                );
            }
        }
        // Écrite après la remontée : l'archive vient d'écraser la table des
        // préférences avec la sienne.
        radinus_core::preferences::set_currency(&connection, &chosen).map_err(to_ipc_error)?;
        drop(connection);
    } else {
        radinus_core::preferences::set_currency(&connection, &chosen).map_err(to_ipc_error)?;
        drop(connection);
    }

    // Écrit après la base, et jamais avant : un fichier d'information posé à
    // côté d'un dossier vide décrirait une base qui n'existe pas.
    let info = radinus_core::location::DatabaseInfo {
        label: label.clone(),
        comment: comment.trim().to_string(),
        created_on: radinus_core::location::iso_day(std::time::SystemTime::now()),
        created_by: env!("CARGO_PKG_VERSION").to_string(),
        schema_version: radinus_core::database::schema::CURRENT_SCHEMA_VERSION,
    };
    // Indicatif : s'il ne s'écrit pas, la base reste parfaitement utilisable
    // et le sélecteur en régénérera un.
    let _ = radinus_core::location::write_database_info(&slot, &info);

    Ok(format!(
        "{}{said_about_archive}",
        radinus_core::i18n::text_with(language, "database-created", "label", &label)
    ))
}

/// **Le sélecteur s'ouvre-t-il sur un Radinus déjà lancé ?**
///
/// Il a deux modes, et c'est la même fenêtre (décision de Fabrice,
/// 02/08/2026) :
///
/// * **au démarrage**, aucune base n'est ouverte : on en choisit une et on
///   s'en sert. Le bouton d'ouverture est vivant ;
/// * **en cours d'utilisation**, par le menu Fichier : on peut consulter,
///   créer et supprimer, mais **plus ouvrir**. Le bouton d'ouverture est
///   grisé, et un double-clic dit qu'il faut quitter le logiciel.
///
/// Ce que la fenêtre demande ici, c'est donc dans lequel des deux elle est. Et
/// elle ne le devine pas : une base ouverte, ou pas.
#[tauri::command]
pub fn database_is_open(state: State<'_, AppState>) -> bool {
    state.has_database()
}

/// **La question avant de supprimer une base**, et le mot qu'il faut écrire.
///
/// La même barrière que partout ailleurs dans Radinus : une question qui
/// nomme ce qui va disparaître, et un mot à recopier — « OUI », « YES »,
/// « SÍ », celui de la langue en cours. Un bouton qu'on clique par mégarde ne
/// s'écrit pas tout seul.
#[tauri::command]
pub fn database_delete_question(
    state: State<'_, AppState>,
    path: String,
) -> Result<DeleteOperationsPromptDto, String> {
    let language = window_language(&state);
    let label = database_label(&state, &path);
    let word = radinus_core::i18n::text(language, "ui-yes").to_uppercase();
    Ok(DeleteOperationsPromptDto {
        question: radinus_core::i18n::text_with_all(
            language,
            "database-delete-question",
            &[("label", &label), ("word", &word)],
        ),
        word,
    })
}

/// Le nom que porte une base, ou le nom de son dossier quand elle n'en a pas.
fn database_label(state: &AppState, relative: &str) -> String {
    let slot = state.data_root.join(relative);
    let slot = slot.parent().unwrap_or(&state.data_root);
    radinus_core::location::read_database_info(slot)
        .map(|info| info.label)
        .filter(|label| !label.trim().is_empty())
        .unwrap_or_else(|| {
            slot.file_name()
                .and_then(|name| name.to_str())
                .unwrap_or_default()
                .to_string()
        })
}

/// **Supprime une base : son dossier part à la corbeille du système**
/// (décision de Fabrice, 02/08/2026).
///
/// À la corbeille et non effacé : une base supprimée par erreur se remet d'un
/// clic droit, et c'est déjà ce que Radinus fait de ses pièces jointes. Tout
/// le dossier y va — le SQLite, les pièces jointes, le fichier
/// d'information : ce qui appartient à cette base et à elle seule.
///
/// **La base ouverte est refusée** (même décision). Radinus tient son fichier
/// ouvert et écrirait dedans après coup ; celle du prochain démarrage, en
/// revanche, se supprime — la configuration oublie son chemin, et le
/// sélecteur reparaîtra au lancement suivant, ce qui est exactement ce qu'il
/// faut qu'il fasse.
#[tauri::command]
pub fn delete_database(state: State<'_, AppState>, path: String) -> Result<String, String> {
    let language = window_language(&state);
    let root = state.data_root.clone();
    let target = root.join(&path);
    let Some(slot) = target.parent().map(std::path::Path::to_path_buf) else {
        return Err(radinus_core::i18n::text(language, "database-gone"));
    };

    if !target.is_file() {
        return Err(radinus_core::i18n::text(language, "database-gone"));
    }

    // La base ouverte se reconnaît à son dossier de pièces jointes, qui est
    // `<base>/attachments/` : c'est le seul chemin que l'état retienne.
    if state.has_database() {
        let open = state.attachments_dir();
        if open.parent() == Some(slot.as_path()) {
            return Err(radinus_core::i18n::text(language, "database-in-use"));
        }
    }

    let label = database_label(&state, &path);
    crate::system::move_to_trash(&slot).map_err(|error| error.to_string())?;

    // La configuration ne doit plus la désigner : un chemin mort rouvrirait
    // le sélecteur au démarrage suivant — ce qui n'est pas grave, mais une
    // configuration qui parle d'un dossier disparu est une configuration qui
    // ment.
    let mut config = radinus_core::location::read_config(&root).map_err(to_ipc_error)?;
    if config.default_database.as_deref() == Some(path.as_str()) {
        config.default_database = None;
    }
    config.recent_databases.retain(|entry| entry != &path);
    radinus_core::location::write_config(&root, &config).map_err(to_ipc_error)?;

    Ok(radinus_core::i18n::text_with(
        language,
        "database-deleted",
        "label",
        &label,
    ))
}


/// La porte du sélecteur de base, et elle ne fait pas la même chose selon d'où
/// l'on vient.
///
/// Au démarrage, aucune base n'est ouverte et le sélecteur est la seule
/// fenêtre à l'écran : la cacher laisserait Radinus tourner sans rien montrer,
/// donc on quitte. Venu du menu Fichier, une base est ouverte et la fenêtre
/// d'accueil attend derrière : on se contente de cacher, comme toute fenêtre
/// de Radinus.
#[tauri::command]
pub fn leave_database_selector(app: AppHandle<impl Runtime>, state: State<'_, AppState>) {
    if state.database().is_err() {
        app.exit(0);
        return;
    }
    if let Some(window) = app.get_webview_window("database-selector") {
        let _ = window.hide();
    }
}

/// La porte de la fenêtre des langues.
///
/// **Elle ne quitte plus toujours** (04/08/2026). Elle quittait, et c'était
/// juste : au tout premier lancement il n'y a rien derrière elle, et une
/// fenêtre cachée sans rien pour la remplacer laisserait Radinus vivant et
/// invisible.
///
/// Depuis que le menu Paramètres de la fenêtre des bases la rouvre — « au cas
/// où l'utilisateur change d'avis ou s'est trompé » —, cette même porte aurait
/// **quitté le logiciel** au lieu de revenir en arrière. Le geste le plus
/// anodin de la fenêtre aurait été le plus destructeur.
///
/// La règle est donc celle de la porte du sélecteur, et pour la même raison :
/// on quitte s'il n'y a rien derrière, on se cache s'il y a quelque chose.
#[tauri::command]
pub fn leave_language_choice<R: Runtime>(app: AppHandle<R>) {
    let behind = app
        .get_webview_window("database-selector")
        .map(|window| window.is_visible().unwrap_or(false))
        .unwrap_or(false);
    if !behind {
        app.exit(0);
        return;
    }
    if let Some(window) = app.get_webview_window("language-choice") {
        let _ = window.hide();
    }
}

// --- F39 — les préférences (phase 17 ter) ---------------------------------

/// Pose les deux préférences d'affichage de la base ouverte : le signe
/// monétaire, et le zoom.
///
/// **Appelée à deux endroits, et deux seulement** : à l'ouverture d'une base
/// et à l'enregistrement des préférences. C'est ce qui rend l'état global de
/// `money::set_sign` tenable — deux écrivains nommés, pas un de plus.
///
/// Elle posait aussi la taille de l'affichage jusqu'au 04/08/2026 ; celle-ci a
/// quitté la base pour la configuration du logiciel, et se pose désormais au
/// démarrage, avant même qu'une base soit choisie.
///
/// Une base fermée ou illisible laisse le signe tel quel : il n'y a alors
/// aucun montant à écrire.
fn apply_preferences(state: &AppState) {
    let Ok(conn) = state.database() else { return };
    let Ok(currency) = radinus_core::preferences::currency(&conn) else { return };
    // Le système n'est interrogé **que** si le choix est « devise système » :
    // lancer une commande externe pour rien coûterait à chaque ouverture.
    let from_system = if currency == radinus_core::preferences::Currency::System {
        crate::system::currency_sign()
    } else {
        String::new()
    };
    radinus_core::money::set_sign(&currency.sign(&from_system));
}

#[derive(Serialize)]
pub struct CurrencyDto {
    /// `systeme`, `EUR`, `USD`, `XOF` ou `perso`.
    pub choice: String,
    /// Le signe tapé à la main, vide pour les autres choix.
    pub custom: String,
    /// Ce que le système répond, pour que la fenêtre puisse le montrer à côté
    /// de « Devise système » — sans quoi ce choix est une promesse aveugle.
    /// Vide si le système ne dit rien : la fenêtre l'annonce alors.
    pub system: String,
    /// Le zoom d'affichage, de 0,7 à 1,5.
    pub zoom: f64,
    pub zoom_min: f64,
    pub zoom_max: f64,
    pub zoom_step: f64,
    pub zoom_default: f64,
}

/// Le signe monétaire que le système annonce, sans base ouverte.
///
/// `preferences_currency` le rend déjà, mais elle lit la base — et la fiche
/// d'une base neuve n'en a aucune sous la main : la base qu'elle décrit
/// n'existe pas encore. D'où cette commande-ci, qui ne demande rien.
#[tauri::command]
pub fn system_currency_sign() -> String {
    crate::system::currency_sign()
}

/// Fait choisir une archive de sauvegarde, et rend son chemin.
///
/// **`async`, et pour la raison de `statement_pick_file`** : une commande Tauri
/// sans `async` s'exécute sur le fil principal, celui-là même qui fait tourner
/// le sélecteur de fichiers. Y attendre une réponse que seul ce fil peut
/// produire est un interblocage — le gel signalé par Fabrice le 27/07/2026, qui
/// ne se serait jamais dénoué.
///
/// Le sélecteur s'ouvre sur `backups/`, là où Radinus range les siennes.
#[tauri::command]
pub async fn pick_backup_archive<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
) -> Result<Option<String>, String> {
    use tauri_plugin_dialog::DialogExt;
    let language = window_language(&state);
    let directory = state
        .data_root
        .join(radinus_core::location::BACKUPS_DIR);
    let _ = std::fs::create_dir_all(&directory);

    let (answered, answer) = std::sync::mpsc::channel();
    app.dialog()
        .file()
        .set_directory(&directory)
        .add_filter(
            radinus_core::i18n::text(language, "backup-archive"),
            &["zip", "ZIP"],
        )
        .pick_file(move |chosen| {
            let _ = answered.send(chosen);
        });
    let Some(chosen) = answer.recv().map_err(to_ipc_error)? else {
        return Ok(None);
    };
    let path = chosen.into_path().map_err(to_ipc_error)?;
    Ok(Some(path.to_string_lossy().to_string()))
}

/// Ouvre la fenêtre des langues, depuis le menu Paramètres de la fenêtre des
/// bases.
///
/// **C'est la même fenêtre qu'au tout premier lancement** (Fabrice,
/// 04/08/2026 : « c'est au cas où l'utilisateur change d'avis ou s'est
/// trompé »). Elle n'écrit rien d'autre que la langue et rouvre le sélecteur
/// derrière elle : la reprendre ici ne coûte pas une ligne de comportement
/// nouveau, et une deuxième fenêtre qui ferait la même chose finirait par la
/// faire autrement.
#[tauri::command]
pub fn open_language_choice<R: Runtime>(app: AppHandle<R>) -> Result<(), String> {
    crate::windows::open(&app, &crate::windows::language_choice_window(), None)
        .map_err(to_ipc_error)
}

/// Ouvre la fenêtre des préférences (F39).
///
/// **Sans base ouverte, elle ne montre que ce qui appartient au logiciel** : la
/// langue et la taille de l'affichage, qui vivent dans la configuration. La
/// devise est une préférence de la base, et la fenêtre la grise — c'est elle
/// qui le décide, en demandant si une base est ouverte, plutôt que de recevoir
/// d'ici un drapeau « je viens du sélecteur ». La règle est ainsi vraie partout
/// et pas seulement sur le chemin qu'on a prévu.
#[tauri::command]
pub fn open_preferences<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
) -> Result<(), String> {
    let language = window_language(&state);
    crate::windows::open(&app, &crate::windows::preferences_window(language), None)
        .map_err(to_ipc_error)
}

/// Ouvre la fiche d'une base neuve, au-dessus du sélecteur.
#[tauri::command]
pub fn open_database_form<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
) -> Result<(), String> {
    let language = window_language(&state);
    crate::windows::open(&app, &crate::windows::database_form_window(language), None)
        .map_err(to_ipc_error)
}

/// **Ce fichier réclame-t-il un mot de passe ?**
///
/// La règle de Fabrice (05/08/2026) est « il essaie, et demande si ça
/// résiste » : Radinus ne tient aucune liste des bases protégées, il ouvre
/// sans clé et regarde. C'est ce que fait cette commande, et c'est tout ce
/// qu'elle fait — la fenêtre des bases l'appelle avant d'ouvrir ou avant une
/// opération technique, et ne demande la clé que si la réponse est oui.
///
/// **Un fichier absent répond non**, et ce n'est pas une négligence : ce n'est
/// pas à cette commande de dire qu'une base a disparu, c'est à celle qui
/// l'ouvre, qui le dit déjà et le dit mieux.
#[tauri::command]
pub fn database_needs_password(state: State<'_, AppState>, path: String) -> bool {
    let sqlite = state.data_root.join(&path);
    if !sqlite.is_file() {
        return false;
    }
    matches!(
        radinus_core::database::open_existing_database(&sqlite, None),
        Err(radinus_core::database::OpenError::Locked)
    )
}

/// Ouvre la fiche du mot de passe, au-dessus du sélecteur, sur une base.
#[tauri::command]
pub fn open_password_form<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    path: String,
    label: String,
) -> Result<(), String> {
    let language = window_language(&state);
    let query = format!(
        "path={}&label={}",
        urlencode(&path),
        urlencode(&label)
    );
    crate::windows::open(
        &app,
        &crate::windows::password_form_window(language),
        Some(&query),
    )
    .map_err(to_ipc_error)
}

/// **Pose, change ou retire le mot de passe d'une base.**
///
/// Les trois champs de la fiche arrivent tels quels, et c'est ici qu'ils sont
/// jugés — la vue ne décide de rien. L'ordre des contrôles est celui du bon
/// sens : d'abord les deux nouvelles saisies, qui ne coûtent rien à comparer,
/// et ensuite seulement l'ancien mot de passe, qui demande d'ouvrir le fichier.
///
/// **La base ouverte n'est pas touchée.** Changer la clé d'une base pendant
/// qu'on écrit dedans par une autre connexion, c'est la corruption qu'on ne
/// verra qu'après. Il faut la fermer d'abord, et Radinus le dit.
#[tauri::command]
pub fn set_database_password(
    state: State<'_, AppState>,
    path: String,
    old: String,
    fresh: String,
    repeat: String,
) -> Result<String, String> {
    let language = window_language(&state);
    if fresh != repeat {
        return Err(radinus_core::i18n::text(language, "password-mismatch"));
    }

    let sqlite = state.data_root.join(&path);
    if !sqlite.is_file() {
        return Err(radinus_core::i18n::text(language, "database-gone"));
    }

    let attachments = sqlite
        .parent()
        .map(|folder| folder.join("attachments"))
        .unwrap_or_default();
    if state.has_database() && state.attachments_dir() == attachments {
        return Err(radinus_core::i18n::text(language, "password-close-first"));
    }

    match radinus_core::database::lock::change(&sqlite, &old, &fresh).map_err(to_ipc_error)? {
        radinus_core::database::lock::ChangeOutcome::WrongPassword => {
            Err(radinus_core::i18n::text(language, "password-wrong"))
        }
        radinus_core::database::lock::ChangeOutcome::Protected => Ok(
            radinus_core::i18n::text(language, "password-now-protected"),
        ),
        radinus_core::database::lock::ChangeOutcome::Unprotected => {
            Ok(radinus_core::i18n::text(language, "password-now-clear"))
        }
    }
}

/// La devise choisie dans cette base.
#[tauri::command]
pub fn preferences_currency(state: State<'_, AppState>) -> Result<CurrencyDto, String> {
    // **Sans base, la fenêtre s'ouvre quand même** (04/08/2026) : la taille de
    // l'affichage appartient au logiciel depuis ce jour-là, et il faut pouvoir
    // la régler depuis l'écran de démarrage. La devise, elle, n'a alors aucune
    // valeur à montrer — la fenêtre grise sa feuille, et ce qu'on rend ici est
    // le choix par défaut, qui ne sera pas lu.
    let currency = match state.database() {
        Ok(conn) => radinus_core::preferences::currency(&conn).map_err(to_ipc_error)?,
        Err(_) => radinus_core::preferences::Currency::default(),
    };
    // La taille de l'affichage ne vient plus de la base : elle appartient au
    // logiciel depuis le 04/08/2026.
    let zoom = radinus_core::location::read_config(&state.data_root)
        .map(|config| config.zoom_factor())
        .unwrap_or(radinus_core::location::ZOOM_DEFAULT);
    Ok(CurrencyDto {
        choice: currency.key().to_string(),
        custom: currency.custom_sign().to_string(),
        system: crate::system::currency_sign(),
        zoom,
        zoom_min: radinus_core::location::ZOOM_MIN,
        zoom_max: radinus_core::location::ZOOM_MAX,
        zoom_step: radinus_core::location::ZOOM_STEP,
        zoom_default: radinus_core::location::ZOOM_DEFAULT,
    })
}

/// Enregistre la devise, la pose aussitôt, et prévient toutes les fenêtres.
///
/// **Le même événement que la bascule de langue.** Une fenêtre qui le reçoit
/// redemande son vocabulaire et repose ses étiquettes — or ce qu'elle repose
/// comprend ses montants, puisqu'ils sont écrits par le noyau. Il n'y avait
/// donc pas lieu d'inventer un second canal que chaque fenêtre aurait dû
/// apprendre à écouter : celui-ci fait déjà exactement ce qu'il faut, et il
/// est éprouvé depuis le 01/08/2026.
#[tauri::command]
pub fn save_preferences_currency<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    choice: String,
    custom: String,
) -> Result<(), String> {
    let chosen = radinus_core::preferences::Currency::from_parts(&choice, &custom);
    let conn = state.database()?;
    // **La deuxième des trois barrières.** La fenêtre refuse déjà à la frappe,
    // et `Currency::sign` refusera une troisième fois à l'affichage. Celle-ci
    // empêche d'écrire dans la base un signe qui casserait les saisies : un
    // signe qui ressemble à un morceau de nombre est ôté par `money::parse`,
    // et « 120 » deviendrait « 12 » sans un mot.
    if matches!(chosen, radinus_core::preferences::Currency::Custom(_)) {
        if let Some(refusal) = radinus_core::preferences::sign_refusal(&custom, ui_language()) {
            return Err(refusal);
        }
    }
    radinus_core::preferences::set_currency(&conn, &chosen).map_err(to_ipc_error)?;
    let language = ui_language();
    drop(conn);

    apply_preferences(&state);
    app.emit(crate::menu::LANGUAGE_CHANGED_EVENT, language.tag())
        .map_err(to_ipc_error)
}

/// **La vérification donnée aux opérations importées** : 2, « Vérifiée », ou
/// 1, « À vérifier » (Fabrice, 03/10/2026). Sans base ouverte, le défaut — la
/// fenêtre grise alors sa feuille, et la valeur ne sera pas lue.
#[tauri::command]
pub fn preferences_import_verification(state: State<'_, AppState>) -> Result<i64, String> {
    match state.database() {
        Ok(conn) => radinus_core::preferences::import_verification(&conn).map_err(to_ipc_error),
        Err(_) => Ok(radinus_core::operations::VERIFIED),
    }
}

/// Enregistre ce choix. Rien à prévenir : il ne vaut que pour les imports à
/// venir, et aucune fenêtre ne l'affiche.
#[tauri::command]
pub fn save_preferences_import_verification(
    state: State<'_, AppState>,
    verification_id: i64,
) -> Result<(), String> {
    let conn = state.database()?;
    radinus_core::preferences::set_import_verification(&conn, verification_id)
        .map_err(to_ipc_error)
}

/// L'événement qui dit qu'un tableau a changé de disposition. Il porte le nom
/// du tableau : une fenêtre n'a pas à se rhabiller pour celui d'une autre.
pub const TABLE_LAYOUT_CHANGED: &str = "table-layout-changed";

/// Prévient les fenêtres ouvertes qu'un tableau vient de changer de colonnes.
///
/// **La disposition est commune à tous les comptes** (Fabrice, 04/10/2026 :
/// « ce serait la préférence de la fenêtre »). Deux listes ouvertes côte à
/// côte doivent donc montrer la même, sans quoi l'une contredirait l'autre —
/// et la dernière fermée écraserait le réglage de la première.
fn table_layout_changed<R: Runtime>(app: &AppHandle<R>, table: &str) {
    let _ = app.emit(TABLE_LAYOUT_CHANGED, table);
}

/// Une fenêtre qui porte des tableaux réglables : son nom, et comment elle se
/// dit.
#[derive(serde::Serialize)]
pub struct WindowWithLayoutsDto {
    pub name: &'static str,
    pub label: String,
}

/// **Sous quel texte une fenêtre se dit dans les préférences.**
///
/// Une statistique porte le nom de son entrée dans le menu général — « Stat
/// par catégories » : c'est par là que l'utilisateur la connaît, et le texte
/// existe déjà dans les dix-huit langues. Le bilan croisé de même. Rien n'est
/// donc traduit une seconde fois, et un intitulé de menu corrigé demain le
/// sera ici aussi.
pub(crate) fn window_label_key(window: &str) -> Option<&'static str> {
    match window {
        "operations-list" => Some("preferences-table-operations-list"),
        "crossed-balance" => Some("menu-statistics-crossed-balance"),
        "balance-analysis" => Some("menu-statistics-balance-analysis"),
        "loan-simulation" => Some("menu-tools-loan-simulation"),
        "appliance-cost" => Some("menu-tools-appliance-cost"),
        "safety-cushion" => Some("menu-tools-safety-cushion"),
        "savings-goal" => Some("menu-tools-savings-goal"),
        "spending-cut" => Some("menu-tools-spending-cut"),
        "holiday" => Some("menu-tools-holiday"),
        _ => {
            let axis = window.strip_prefix(radinus_core::preferences::STATISTICS_LAYOUT_PREFIX)?;
            radinus_core::statistics::AXES
                .into_iter()
                .find(|candidate| candidate.key() == axis)
                .map(crate::menu::statistics_menu_key)
        }
    }
}

/// **Les fenêtres dont on règle les colonnes** — ce que la feuille des
/// préférences met dans son menu déroulant (Fabrice, 04/10/2026 : « il s'agit
/// du nom de la fenêtre, on réinitialise les tableaux contenus dans une
/// fenêtre »). Le nom sert à la commande, le libellé à l'écran : la fenêtre ne
/// compose rien.
#[tauri::command]
pub fn windows_with_table_layouts() -> Vec<WindowWithLayoutsDto> {
    let language = ui_language();
    radinus_core::preferences::windows_with_layouts()
        .into_iter()
        .map(|name| WindowWithLayoutsDto {
            name,
            label: match window_label_key(name) {
                Some(key) => radinus_core::i18n::text(language, key),
                None => name.to_string(),
            },
        })
        .collect()
}

/// Rend leur disposition de naissance aux tableaux d'une fenêtre — le bouton
/// « Réinitialiser » des préférences — et prévient chacun d'eux.
#[tauri::command]
pub fn reset_window_table_layouts<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    window: String,
) -> Result<(), String> {
    let tables = {
        let conn = state.database()?;
        radinus_core::preferences::reset_window_layouts(&conn, &window).map_err(to_ipc_error)?
    };
    for table in tables {
        table_layout_changed(&app, table);
    }
    Ok(())
}

/// **La disposition enregistrée d'un tableau**, ou rien : la fenêtre garde
/// alors celle avec laquelle son tableau est né. Sans base ouverte, rien non
/// plus — la préférence est dans la base.
#[tauri::command]
pub fn table_layout(
    state: State<'_, AppState>,
    table: String,
) -> Result<Option<radinus_core::preferences::TableLayout>, String> {
    match state.database() {
        Ok(conn) => radinus_core::preferences::table_layout(&conn, &table).map_err(to_ipc_error),
        Err(_) => Ok(None),
    }
}

/// Enregistre la disposition d'un tableau, et prévient les autres fenêtres.
///
/// Rend `false` quand rien n'a été écrit — un tableau inconnu, une disposition
/// qui ne se tient pas. Ce n'est pas une erreur à dire à l'utilisateur : il a
/// glissé une colonne, elle est où il l'a posée, et la mémoire seule a refusé.
#[tauri::command]
pub fn save_table_layout<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    table: String,
    layout: radinus_core::preferences::TableLayout,
) -> Result<bool, String> {
    let written = {
        let conn = state.database()?;
        radinus_core::preferences::set_table_layout(&conn, &table, &layout)
            .map_err(to_ipc_error)?
    };
    if written {
        table_layout_changed(&app, &table);
    }
    Ok(written)
}

/// Rend à un tableau sa disposition de naissance — « Rétablir les colonnes
/// par défaut » dans son menu, « Réinitialiser » dans les préférences.
#[tauri::command]
pub fn reset_table_layout<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    table: String,
) -> Result<(), String> {
    {
        let conn = state.database()?;
        radinus_core::preferences::reset_table_layout(&conn, &table).map_err(to_ipc_error)?;
    }
    table_layout_changed(&app, &table);
    Ok(())
}

/// La même chose pour tous les tableaux : « Tout réinitialiser ».
#[tauri::command]
pub fn reset_all_table_layouts<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
) -> Result<(), String> {
    {
        let conn = state.database()?;
        radinus_core::preferences::reset_all_table_layouts(&conn).map_err(to_ipc_error)?;
    }
    for table in radinus_core::preferences::TABLES_WITH_A_LAYOUT {
        table_layout_changed(&app, table);
    }
    Ok(())
}

/// L'événement qui dit que l'accueil doit se relire : l'ordre de ses tuiles ou
/// leurs cases viennent de changer ailleurs que chez lui.
pub const WELCOME_ACCOUNTS_CHANGED: &str = "welcome-accounts-changed";

/// Enregistre l'ordre des tuiles de l'accueil et les comptes décochés.
///
/// **La fenêtre envoie tout, à chaque geste** : l'ordre qu'elle montre et les
/// cases qu'elle montre. Deux commandes — une pour l'ordre, une pour la case —
/// auraient demandé au contrôleur de relire puis de recoller, et un geste
/// arrivé entre les deux aurait été perdu.
///
/// Un réglage qui ne se tient pas (un compte cité deux fois) n'est pas écrit,
/// et ce n'est pas une erreur à montrer : l'accueil se relit et retrouve ce
/// que la base contient vraiment.
#[tauri::command]
pub fn save_welcome_accounts(
    state: State<'_, AppState>,
    order: Vec<i64>,
    excluded: Vec<i64>,
) -> Result<(), String> {
    let conn = state.database()?;
    radinus_core::preferences::set_welcome_accounts(
        &conn,
        &radinus_core::preferences::WelcomeAccounts { order, excluded },
    )
    .map(|_| ())
    .map_err(to_ipc_error)
}

/// **« Réinitialiser les réglages de confort »** (Fabrice, 07/10/2026 : « il
/// faut avoir un bouton pour remettre à zéro les réglages de confort mais pas
/// le reste »).
///
/// Trois choses reviennent à leur état de naissance : les colonnes de tous les
/// tableaux, l'ordre et les cases des comptes de l'accueil, et la taille de
/// l'affichage. **Ni la langue, ni la devise, ni la vérification des
/// opérations importées** : celles-là ne sont pas du confort.
///
/// **La taille d'abord, parce qu'elle vit sur le poste** et non dans la base :
/// sans base ouverte, c'est la seule des trois qui existe, et le bouton fait
/// alors tout ce qu'il peut faire au lieu de refuser.
#[tauri::command]
pub fn reset_comfort_settings<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
) -> Result<(), String> {
    let root = state.data_root.clone();
    let mut config = radinus_core::location::read_config(&root).map_err(to_ipc_error)?;
    config.zoom = None;
    radinus_core::location::write_config(&root, &config).map_err(to_ipc_error)?;
    crate::windows::set_zoom_factor(config.zoom_factor());
    crate::windows::apply_zoom_everywhere(&app);

    if state.has_database() {
        {
            let conn = state.database()?;
            radinus_core::preferences::reset_comfort(&conn).map_err(to_ipc_error)?;
        }
        for table in radinus_core::preferences::TABLES_WITH_A_LAYOUT {
            table_layout_changed(&app, table);
        }
        let _ = app.emit(WELCOME_ACCOUNTS_CHANGED, ());
    }
    Ok(())
}

/// La feuille « Relevés QIF » des préférences : `order` vaut `ask`,
/// `day-month` ou `month-day` ; `label` vaut `both`, `payee` ou `memo`.
#[derive(Serialize)]
pub struct QifPreferencesDto {
    pub order: String,
    pub label: String,
}

/// Les deux réglages des relevés QIF (Fabrice, 15/10/2026, P-73). **Du
/// logiciel, pas de la base** : ils se lisent sans base ouverte.
#[tauri::command]
pub fn preferences_qif(state: State<'_, AppState>) -> QifPreferencesDto {
    let config = radinus_core::location::read_config(&state.data_root).unwrap_or_default();
    QifPreferencesDto {
        order: config.qif_order_choice().map_or("ask", |order| order.key()).to_string(),
        label: config.qif_label_choice().key().to_string(),
    }
}

/// Enregistre les deux réglages QIF dans `settings/radinus_config.json`. Une
/// valeur inconnue est refusée plutôt qu'écrite : ce qui part dans le fichier
/// est toujours relisible.
#[tauri::command]
pub fn save_preferences_qif(
    state: State<'_, AppState>,
    order: String,
    label: String,
) -> Result<(), String> {
    use radinus_core::qif_import::{DateOrder, LabelChoice};
    let date_order = match order.as_str() {
        "ask" => None,
        key => Some(DateOrder::from_key(key).ok_or_else(|| format!("QIF : « {key} » ?"))?),
    };
    let label = LabelChoice::from_key(&label).ok_or_else(|| format!("QIF : « {label} » ?"))?;
    let root = state.data_root.clone();
    let mut config = radinus_core::location::read_config(&root).map_err(to_ipc_error)?;
    config.qif_date_order = date_order.map(|order| order.key().to_string());
    config.qif_label = Some(label.key().to_string());
    radinus_core::location::write_config(&root, &config).map_err(to_ipc_error)
}

/// Enregistre le zoom d'affichage, et le pose sur toutes les fenêtres ouvertes.
///
/// **Y compris celle des préférences elle-même** : l'utilisateur voit tout de
/// suite ce qu'il vient de choisir, sur la fenêtre qu'il a sous les yeux. Un
/// réglage d'affichage qu'il faudrait aller vérifier ailleurs ne se règle pas,
/// il se devine.
#[tauri::command]
pub fn save_preferences_zoom<R: Runtime>(
    app: AppHandle<R>,
    state: State<'_, AppState>,
    factor: f64,
) -> Result<(), String> {
    // **Dans `settings/radinus_config.json`, plus dans la base** (Fabrice,
    // 04/08/2026). Cette commande n'a donc plus besoin d'une base ouverte pour
    // écrire — même si la fenêtre des préférences, elle, en demande toujours
    // une pour s'ouvrir, la devise étant restée une affaire de base.
    let root = state.data_root.clone();
    let mut config = radinus_core::location::read_config(&root).map_err(to_ipc_error)?;
    config.zoom = Some(radinus_core::location::clamp_zoom(factor));
    radinus_core::location::write_config(&root, &config).map_err(to_ipc_error)?;

    crate::windows::set_zoom_factor(config.zoom_factor());
    crate::windows::apply_zoom_everywhere(&app);
    Ok(())
}

/// « Version : 2.0.0 », phrase entière, dans la langue du logiciel.
///
/// **Le numéro vient du binaire qui tourne**, par `package_info`, et non d'une
/// chaîne recopiée : il est déjà écrit dans `Cargo.toml`, `package.json`,
/// `tauri.conf.json` et la table `Parametres`, et une cinquième copie aurait
/// fini par annoncer une version qu'on n'exécute pas. C'est pourtant la seule
/// chose qu'une fenêtre « à propos » doive dire juste.
///
/// La phrase est rédigée par le noyau, l'ordre des mots n'étant pas le même
/// partout.
#[tauri::command]
pub fn app_version<R: Runtime>(app: AppHandle<R>, state: State<'_, AppState>) -> String {
    let language = window_language(&state);
    radinus_core::i18n::message_of(
        language,
        "about-radinus-version",
        &[("version", app.package_info().version.to_string().as_str())],
        &[],
    )
}

/// **La table des raccourcis que cette fenêtre doit reconnaître.**
///
/// Demandée une fois, à l'ouverture de chaque fenêtre. Elle est **vide sur
/// macOS**, où la barre native entend déjà les frappes : une fenêtre qui
/// écouterait aussi déclencherait chaque entrée deux fois. Voir
/// `menu::shortcut_table` pour la raison complète.
#[tauri::command]
pub fn menu_shortcuts() -> Vec<crate::menu::Shortcut> {
    crate::menu::shortcut_table()
}

/// **La frappe a été reconnue : exécute l'entrée.**
///
/// La fenêtre ne fait que nommer l'entrée ; c'est `menu::trigger` qui vérifie
/// qu'elle est active et qui l'exécute par le chemin ordinaire, celui de la
/// souris. Aucune décision n'est prise dans la vue, et aucune branche du menu
/// n'est réécrite.
#[tauri::command]
pub fn menu_shortcut<R: Runtime>(app: AppHandle<R>, id: String) {
    crate::menu::trigger(&app, &id);
}

/// The official text of the GNU GPL v3, in the system's browser.
///
/// **The address lives here and nowhere else.** A command taking a URL from
/// the window would hand the view the power to open anything the machine can
/// open; this one opens a single page, and the view chooses nothing.
///
/// **It answers nothing, on purpose.** Waiting for the browser to confirm
/// would freeze the window on a machine whose default browser is slow to wake,
/// and there is nothing the person could do with a failure anyway — the same
/// choice as the « Aller sur le site de Radinus » entry of the menu, which
/// this reuses down to the function.
#[tauri::command]
pub fn open_licence_page() {
    const PAGE: &str = "https://www.gnu.org/licenses/gpl-3.0.html";
    if let Err(error) = crate::system::open_link(PAGE) {
        eprintln!("[radinus] Could not open the licence page: {error}");
    }
}

/// Quitte F39. Masquée, jamais détruite, comme toutes les fenêtres.
///
/// **Il n'y a pas de `open_preferences` en face**, et c'est voulu : la fenêtre
/// est ouverte par l'entrée du menu Paramètres, en Rust. J'en avais écrit une
/// par symétrie, que personne n'appelait — une commande offerte au frontend
/// que rien n'appelle est une porte ouverte pour rien, et le croisement l'a
/// dit aussitôt (03/08/2026, la même faute que `ping` le matin même).
#[tauri::command]
pub fn close_preferences<R: Runtime>(app: AppHandle<R>) -> Result<(), String> {
    if let Some(window) = app.get_webview_window("preferences") {
        window.hide().map_err(to_ipc_error)?;
    }
    Ok(())
}

// --- F01 — la fenêtre d'accueil (phase 17 bis) ----------------------------

/// Un compte tel que la tuile d'accueil le montre.
///
/// Les montants partent **écrits**, comme partout ailleurs : c'est le noyau
/// qui met en forme un montant, jamais la fenêtre. Ils partent aussi en
/// nombre, parce que la tuile n'a besoin que du **signe** pour peindre en
/// rouge foncé — et qu'elle ne doit jamais relire un montant dans le texte
/// qu'on lui a donné.
#[derive(Serialize)]
pub struct WelcomeAccountDto {
    pub id: i64,
    pub label: String,
    pub bank: String,
    pub balance_bank: String,
    pub balance_real: String,
    pub balance_final: String,
    pub balance_bank_value: i64,
    pub balance_real_value: i64,
    pub balance_final_value: i64,
    /// La case de la tuile (Fabrice, 07/10/2026) : ce compte entre-t-il dans
    /// les trois totaux et dans les deux anneaux ? `true` à la naissance.
    pub included: bool,
}

#[derive(Serialize)]
pub struct WelcomeDto {
    pub accounts: Vec<WelcomeAccountDto>,
    pub total_bank: String,
    pub total_real: String,
    pub total_final: String,
    pub total_bank_value: i64,
    pub total_real_value: i64,
    pub total_final_value: i64,
    /// « 4 comptes ouverts », rédigé par le noyau : un pluriel n'est pas le
    /// même dans les trois langues, et la fenêtre n'a pas à le savoir.
    pub accounts_line: String,
    /// Les deux titres des anneaux, **écrits en entier par le noyau**, mois
    /// compris. La fenêtre ne colle pas un mois derrière un titre : une phrase
    /// à trou ne se remplit que là où Fluent sait où est le trou, et l'ordre
    /// des mots n'est pas le même dans toutes les langues.
    pub spending_title: String,
    pub earning_title: String,
    /// L'en-tête de chaque carte : « Postes budgétaires », « Catégories », ou
    /// **le nom de la catégorie** à la courbe.
    ///
    /// **C'est lui qui dit à quel niveau on est** depuis que les titres ont été
    /// raccourcis (décision de Fabrice, 03/08/2026). Il porte donc une
    /// information, il n'est pas décoratif : à la courbe, c'est même la seule
    /// chose à l'écran qui nomme ce qu'on regarde.
    pub spending_legend: String,
    pub earning_legend: String,
    /// Le texte du lien qui remonte d'un niveau, ou `null` tout en haut.
    ///
    /// **C'est le nom du niveau où l'on va**, pas une phrase de plus : le lien
    /// sous les catégories dit « Postes budgétaires », celui sous la courbe dit
    /// « Catégories ». Aucune clef nouvelle n'a été nécessaire — un lien qui
    /// annonce sa destination se traduit tout seul.
    pub spending_back: Option<String>,
    pub earning_back: Option<String>,
    /// Où en est chaque carte dans sa descente. La fenêtre les renvoie tels
    /// quels au coup suivant : c'est ainsi qu'on **reste où l'on est** en
    /// changeant de mois.
    pub spending_line: Option<i64>,
    pub spending_category: Option<i64>,
    pub earning_line: Option<i64>,
    pub earning_category: Option<i64>,
    /// La courbe du cumul, au troisième niveau. Vide autrement.
    pub spending_curve: Vec<PointDto>,
    pub earning_curve: Vec<PointDto>,
    /// Le mois montré, et ses deux voisins, en ISO. **La fenêtre ne calcule
    /// aucune date** : elle garde ces trois chaînes, en renvoie une quand on
    /// clique un chevron, et n'a jamais à savoir que janvier moins un mois
    /// change d'année.
    pub month: String,
    pub previous_month: String,
    pub next_month: String,
    /// Vrai quand la flèche mène hors des bornes 1950-2550 : le voisin est
    /// alors le mois lui-même, et le bouton s'éteint plutôt que de ne rien
    /// faire en silence.
    pub at_first_month: bool,
    pub at_last_month: bool,
    pub spending: Vec<SliceDto>,
    pub earning: Vec<SliceDto>,
}

/// Tout ce que l'accueil montre, en une seule lecture.
///
/// **Aucun paramètre, et c'est la règle de la fenêtre** : l'accueil est la vue
/// sans un clic, donc il n'y a rien à lui régler. Les comptes sont ceux qui
/// sont ouverts, la période est le mois en cours, les trois statuts passent.
/// Le jour où cette commande prendrait un argument, c'est que la fenêtre
/// aurait cessé d'être un accueil.
///
/// Une seule commande plutôt que quatre : elle est appelée au lancement du
/// logiciel, c'est-à-dire au moment précis où l'on juge s'il est lent.
#[tauri::command]
pub fn welcome(
    state: State<'_, AppState>,
    month: Option<String>,
    spending_line: Option<i64>,
    spending_category: Option<i64>,
    earning_line: Option<i64>,
    earning_category: Option<i64>,
) -> Result<WelcomeDto, String> {
    let conn = state.database()?;
    let language = ui_language();
    let unclassified = radinus_core::i18n::text(language, "dashboard-unclassified");
    // Le mois demandé, ou aujourd'hui à l'ouverture. **Une date illisible
    // ramène à aujourd'hui plutôt que de faire échouer la fenêtre d'accueil** :
    // elle ne vient pas d'une saisie mais d'un aller-retour avec nous-mêmes, et
    // une fenêtre d'accueil en erreur est la première chose que verrait
    // l'utilisateur au lancement.
    let today = time_compute::Local::now().date_naive();
    let day = month
        .as_deref()
        .and_then(|text| radinus_core::domain::NaiveDate::parse_from_str(text, "%Y-%m-%d").ok())
        .unwrap_or(today);

    use radinus_core::welcome::Drill;
    let shown = radinus_core::welcome::welcome(
        &conn,
        day,
        &unclassified,
        Drill { budget_line: spending_line, category: spending_category },
        Drill { budget_line: earning_line, category: earning_category },
    )
    .map_err(to_ipc_error)?;

    let budget_lines = radinus_core::i18n::text(language, "ui-legend-budget-lines");
    let categories = radinus_core::i18n::text(language, "ui-legend-categories");

    // L'en-tête suit le niveau où la carte se trouve **réellement**, pas ce que
    // la fenêtre croit avoir demandé : c'est le noyau qui a le dernier mot.
    let legend_of = |drill: Drill, name: Option<&String>| match (drill.category, name) {
        (Some(_), Some(label)) => label.clone(),
        (Some(_), None) => categories.clone(),
        (None, _) if drill.budget_line.is_some() => categories.clone(),
        _ => budget_lines.clone(),
    };
    // Et le lien nomme le niveau où il mène. Rien tout en haut : il n'y a nulle
    // part où remonter, et un lien mort est pire qu'un lien absent.
    let back_of = |drill: Drill| match (drill.category, drill.budget_line) {
        (Some(_), _) => Some(categories.clone()),
        (None, Some(_)) => Some(budget_lines.clone()),
        _ => None,
    };
    let month_name = radinus_core::i18n::month_and_year(language, shown.from);

    let money = |amount: i64| radinus_core::money::format(amount, language);
    let slice = |part: &radinus_core::dashboard::Slice| SliceDto {
        id: part.id,
        label: part.label.clone(),
        amount: part.amount,
        text: money(part.amount),
    };

    Ok(WelcomeDto {
        accounts: shown
            .accounts
            .iter()
            .map(|account| WelcomeAccountDto {
                id: account.id,
                label: account.label.clone(),
                bank: account.bank.clone(),
                balance_bank: money(account.balance_bank),
                balance_real: money(account.balance_real),
                balance_final: money(account.balance_final),
                balance_bank_value: account.balance_bank,
                balance_real_value: account.balance_real,
                balance_final_value: account.balance_final,
                included: !shown.excluded.contains(&account.id),
            })
            .collect(),
        total_bank: money(shown.total_bank),
        total_real: money(shown.total_real),
        total_final: money(shown.total_final),
        total_bank_value: shown.total_bank,
        total_real_value: shown.total_real,
        total_final_value: shown.total_final,
        // **Dès qu'une case est décochée, la ligne le dit** : un total qui ne
        // compte pas tout sans l'annoncer serait un total faux pour celui qui
        // a oublié sa case — ou pour celui qui s'assoit devant l'écran d'un
        // autre.
        accounts_line: if shown.excluded.is_empty() {
            radinus_core::i18n::message_of(
                language,
                "welcome-accounts-count",
                &[],
                &[("count", shown.accounts.len() as i64)],
            )
        } else {
            radinus_core::i18n::message_of(
                language,
                "welcome-accounts-counted",
                &[],
                &[
                    ("count", (shown.accounts.len() - shown.excluded.len()) as i64),
                    ("total", shown.accounts.len() as i64),
                ],
            )
        },
        spending_title: radinus_core::i18n::message_of(
            language,
            "welcome-spending",
            &[("month", &month_name)],
            &[],
        ),
        earning_title: radinus_core::i18n::message_of(
            language,
            "welcome-earning",
            &[("month", &month_name)],
            &[],
        ),
        spending_legend: legend_of(shown.spending_drill, shown.spending_category_label.as_ref()),
        earning_legend: legend_of(shown.earning_drill, shown.earning_category_label.as_ref()),
        spending_back: back_of(shown.spending_drill),
        earning_back: back_of(shown.earning_drill),
        spending_line: shown.spending_drill.budget_line,
        spending_category: shown.spending_drill.category,
        earning_line: shown.earning_drill.budget_line,
        earning_category: shown.earning_drill.category,
        spending_curve: shown
            .spending_curve
            .iter()
            .map(|step| point(step, language))
            .collect(),
        earning_curve: shown
            .earning_curve
            .iter()
            .map(|step| point(step, language))
            .collect(),
        month: shown.from.to_string(),
        previous_month: shown.previous.to_string(),
        next_month: shown.next.to_string(),
        at_first_month: shown.previous == shown.from,
        at_last_month: shown.next == shown.from,
        spending: shown.spending.iter().map(slice).collect(),
        earning: shown.earning.iter().map(slice).collect(),
    })
}
