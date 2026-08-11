//! Les opérations sur la base de données — menu Fichier › Opérations base de
//! données (phase 17).
//!
//! Trois gestes pour l'instant : **sauvegarder**, **restaurer**, **tout
//! supprimer**. La réparation et le journal, prévus au même sous-menu, restent
//! éteints — Fabrice les a remis à plus tard le 01/08/2026.
//!
//! **Pourquoi ces trois-là vivent en Rust et non dans une fenêtre.** Toutes les
//! autres questions de Radinus sont posées par le logiciel lui-même, en HTML,
//! avec ses couleurs. Celles-ci partent d'une entrée de menu, et une entrée de
//! menu n'appartient à aucune fenêtre : il faudrait en désigner une, l'ouvrir
//! si elle est fermée, lui envoyer un événement, et lui donner des feuilles de
//! style qu'elle n'a pas. Ces trois gestes portent d'ailleurs sur des
//! **fichiers** — un sélecteur du système est déjà nécessaire pour désigner
//! l'archive —, et la question qui les accompagne est de la même nature.
//! Elles sont donc posées par le système, comme les sélecteurs.
//!
//! **Rien ne bloque le fil principal.** Un dialogue ouvert depuis le
//! gestionnaire de menu figerait l'application sur macOS ; chaque geste part
//! donc sur son propre fil, et c'est là que les dialogues s'ouvrent et que la
//! base travaille.

use tauri::{AppHandle, Emitter, Manager, Runtime};
use tauri_plugin_dialog::{DialogExt, MessageDialogButtons, MessageDialogKind};

use radinus_core::i18n::{self, Language};
use radinus_core::journal::{Journal, Status};

use crate::state::AppState;
use radinus_core::database::Connection;

/// L'heure, telle que le journal l'écrit dans ses marqueurs de début et de
/// fin. C'est le contrôleur qui la lit : le noyau n'a pas d'horloge.
fn stamp() -> String {
    time_compute::Local::now()
        .format("%d/%m/%Y %H:%M:%S")
        .to_string()
}

/// Un poids d'octets, en kilo-octets à deux décimales — l'unité de son
/// journal.
fn kilobytes(bytes: usize) -> String {
    format!("{:.2} ko", bytes as f64 / 1024.0)
}

/// Range le journal du traitement qui vient de finir, et ouvre la fenêtre qui
/// le montre si l'appelant le demande.
///
/// **Le journal remplace le précédent**, comme le `SupprimeTout()` de
/// l'original : il ne raconte jamais qu'un traitement, le plus récent.
fn keep_journal<R: Runtime>(app: &AppHandle<R>, journal: Journal, show: bool) {
    if let Some(state) = app.try_state::<AppState>() {
        state.set_journal(journal.into_entries());
    }
    if show {
        open_journal(app);
    }
}

/// Ouvre la fenêtre du journal (⌘H).
pub fn open_journal<R: Runtime>(app: &AppHandle<R>) {
    let language = language(app);
    let window = crate::windows::journal_window(language);
    if let Err(error) = crate::windows::open(app, &window, None) {
        eprintln!("[radinus] Could not open the journal window: {error}");
    }
}

/// La langue du logiciel — celle de `settings/radinus_config.json`.
///
/// Elle lisait la base ouverte jusqu'au 03/08/2026. Les messages de la
/// sauvegarde et de la restauration parlaient donc la langue des données
/// qu'ils manipulaient, et non celle de l'utilisateur qui les lisait : une
/// restauration d'archive anglaise annonçait son succès en anglais.
fn language<R: Runtime>(_app: &AppHandle<R>) -> Language {
    i18n::in_use()
}

/// Dit quelque chose à l'utilisateur, et attend qu'il ait lu.
fn tell<R: Runtime>(app: &AppHandle<R>, title: &str, message: &str, bad: bool) {
    app.dialog()
        .message(message)
        .title(title)
        .kind(if bad {
            MessageDialogKind::Error
        } else {
            MessageDialogKind::Info
        })
        .blocking_show();
}

fn ask<R: Runtime>(app: &AppHandle<R>, language: Language, title: &str, question: &str) -> bool {
    app.dialog()
        .message(question)
        .title(title)
        .kind(MessageDialogKind::Warning)
        .buttons(MessageDialogButtons::OkCancelCustom(
            i18n::text(language, "ui-yes"),
            i18n::text(language, "ui-no"),
        ))
        .blocking_show()
}

/// **Tout ce qui est ouvert relit la base.**
///
/// Une restauration ou un effacement total ne laisse rien en place : les
/// comptes, les opérations, les nomenclatures, tout a changé sous les fenêtres
/// ouvertes. Or une fenêtre de Radinus n'est jamais détruite — la quitter la
/// cache —, donc elle continuerait d'afficher l'ancienne base jusqu'à ce que
/// l'utilisateur la rouvre.
///
/// On parcourt les fenêtres **réellement ouvertes** plutôt qu'une liste écrite
/// à la main : une fenêtre ajoutée demain sera prévenue sans que personne ait
/// à y penser, et c'est exactement de cette façon que cinq statistiques sont
/// passées entre les mailles le 26/07/2026.
fn everything_moved<R: Runtime>(app: &AppHandle<R>) {
    for label in app.webview_windows().keys() {
        let _ = app.emit(&format!("data-changed:{label}"), ());
    }
}

/// **La base sur laquelle une opération technique travaille.**
///
/// Elle n'est plus forcément celle qui est ouverte (décision de Fabrice,
/// 04/08/2026) : le menu Outils de la fenêtre des bases vise **la ligne
/// sélectionnée**, ouverte ou non. On peut donc sauvegarder « famille » sans
/// quitter « perso ».
///
/// Les trois opérations étaient câblées sur `AppState` — la connexion en cours
/// et son dossier de pièces jointes. C'est ce câblage que cette structure
/// remplace : elles reçoivent désormais ce sur quoi elles travaillent au lieu
/// d'aller le chercher.
struct Target {
    /// Le fichier SQLite de la base visée.
    sqlite: std::path::PathBuf,
    /// Son dossier de pièces jointes — voisin du SQLite, comme à l'ouverture.
    attachments: std::path::PathBuf,
    /// **Est-ce la base ouverte ?** Ce n'est pas une curiosité : une opération
    /// sur la base ouverte passe par la connexion existante, jamais par une
    /// seconde. Deux connexions qui écrivent le même fichier, c'est la
    /// corruption qu'on ne verra qu'après.
    open: bool,
}

/// La cible désignée par un chemin relatif venu de la fenêtre des bases.
///
/// Rend `None` quand la racine des données est introuvable — un Radinus qui ne
/// sait pas où il vit ne peut rien réparer.
fn target_of<R: Runtime>(app: &AppHandle<R>, relative: &str) -> Option<Target> {
    let state = app.try_state::<AppState>()?;
    let sqlite = state.data_root.join(relative);
    let attachments = sqlite
        .parent()
        .map(|folder| folder.join("attachments"))
        .unwrap_or_default();
    // La base ouverte se reconnaît à son dossier de pièces jointes : c'est ce
    // que `AppState` retient d'elle, et le seul chemin qu'il garde.
    let open = state.has_database() && state.attachments_dir() == attachments;
    Some(Target {
        sqlite,
        attachments,
        open,
    })
}

/// La connexion à la cible : celle qui est déjà ouverte, ou une seconde,
/// ouverte le temps de l'opération et refermée avec elle.
enum Held<'a> {
    Open(crate::state::DatabaseGuard<'a>),
    Aside(Connection),
}

impl Held<'_> {
    fn conn(&mut self) -> &mut Connection {
        match self {
            Held::Open(guard) => guard,
            Held::Aside(connection) => connection,
        }
    }
}

/// Ouvre la cible, ou dit pourquoi elle ne s'ouvre pas.
///
/// **Le mot de passe ne sert que pour une base fermée** (05/08/2026) : la base
/// ouverte a déjà été déverrouillée à l'ouverture, sa connexion est
/// déverrouillée avec elle, et redemander sa clé serait redemander ce qu'on a
/// déjà.
fn hold<'a>(
    state: &'a AppState,
    target: &Target,
    language: Language,
    password: Option<&str>,
) -> Result<Held<'a>, String> {
    if target.open {
        return state.database().map(Held::Open);
    }
    radinus_core::database::open_existing_database(&target.sqlite, password)
        // Le compte rendu de schéma est écarté ici, et pas par négligence : le
        // journal appartient au traitement qui va suivre — sauvegarde,
        // restauration ou réparation — et l'écraserait de toute façon. Une
        // base ouverte de côté est une base qu'on ne regarde pas.
        .map(|opened| Held::Aside(opened.conn))
        .map_err(|error| match error {
            // Une base protégée dont on n'a pas la clé n'est pas une base
            // absente : le dire autrement enverrait chercher un fichier qui
            // est là.
            radinus_core::database::OpenError::Locked => {
                i18n::text(language, "password-wrong")
            }
            _ => i18n::text(language, "backup-no-database"),
        })
}

/// Le dossier où les sauvegardes se rangent, et le nom proposé pour celle-ci.
fn suggested_backup<R: Runtime>(app: &AppHandle<R>) -> (std::path::PathBuf, String) {
    let root = app
        .try_state::<AppState>()
        .map(|state| state.data_root.clone())
        .unwrap_or_default();
    let directory = root.join(radinus_core::location::BACKUPS_DIR);
    // Le dossier peut ne pas exister encore : le sélecteur s'ouvrirait alors
    // n'importe où. On le crée, il est de toute façon prévu par l'arborescence.
    let _ = std::fs::create_dir_all(&directory);
    let name = radinus_core::backup::writer::archive_file_name(std::time::SystemTime::now());
    (directory, name)
}

/// **Sauvegarde** — menu Fichier › Opérations base de données › Sauvegarde
/// (⌘S).
///
/// Le sélecteur s'ouvre sur `backups/` avec le nom horodaté déjà proposé
/// (choix de Fabrice, 01/08/2026), et l'utilisateur reste libre de ranger son
/// archive ailleurs — sur une clé, par exemple, ce qui est tout l'intérêt
/// d'une sauvegarde.
pub fn backup<R: Runtime>(app: AppHandle<R>, relative: String, password: Option<String>) {
    std::thread::spawn(move || {
        backup_now(&app, &relative, password.as_deref());
    });
}

/// **La sauvegarde elle-même**, sans le fil qui la porte.
///
/// [`backup`] la lance et rend la main aussitôt, parce que la fenêtre des
/// bases ne doit pas geler pendant qu'on écrit des mégaoctets. Mais
/// l'importation Excel, elle, a besoin du contraire : elle propose le filet
/// **avant** de sauter, et reprendre son cours pendant que la sauvegarde
/// s'écrit ne serait pas tenir la promesse faite à l'utilisateur. Elle appelle
/// donc ceci, et attend.
///
/// Rend la main quand tout est fini : archive écrite, relue, journalisée, et
/// le compte rendu affiché. Ne rend rien — elle parle elle-même.
pub fn backup_now<R: Runtime>(app: &AppHandle<R>, relative: &str, password: Option<&str>) {
    let language = language(app);
    let Some(target) = target_of(app, relative) else {
        return;
    };
    let title = i18n::text(language, "menu-file-backup");
    let (directory, name) = suggested_backup(app);

    let (answered, answer) = std::sync::mpsc::channel();
    app.dialog()
        .file()
        .set_directory(&directory)
        .set_file_name(&name)
        .add_filter(i18n::text(language, "backup-archive"), &["zip"])
        .save_file(move |chosen| {
            let _ = answered.send(chosen);
        });
    let Ok(Some(chosen)) = answer.recv() else {
        return;
    };
    let Ok(path) = chosen.into_path() else {
        return;
    };

    let mut journal = Journal::new(language);
    journal.add_file(
        "journal-step-backup-begin",
        &path.to_string_lossy(),
        Status::Started,
        "",
        &stamp(),
    );

    // **Les pièces jointes sont celles de la cible**, plus celles de la
    // base ouverte : sauvegarder « famille » depuis « perso » emportait
    // sinon les fichiers du mauvais dossier.
    let folder = target.attachments.clone();
    let written = match app.try_state::<AppState>() {
        Some(state) => match hold(&state, &target, language, password) {
            Ok(mut held) => radinus_core::backup::writer::write_archive_with_attachments(
                held.conn(),
                &path,
                Some(&folder),
            )
            .map_err(|error| error.to_string()),
            Err(error) => Err(error),
        },
        None => Err(i18n::text(language, "backup-no-database")),
    };

    // Une ligne par table, comme chez lui : le nombre d'enregistrements
    // versés et ce qu'ils pèsent. Notre écriture va droit dans le zip,
    // sans fichier temporaire : ses trois lignes par table deviennent une.
    let written = match written {
        Ok((tables, joined)) => {
            let mut rows = 0usize;
            let mut bytes = 0usize;
            for table in &tables {
                rows += table.rows;
                bytes += table.bytes;
                journal.add(
                    "journal-step-backup-table",
                    table.table,
                    Status::Success,
                    "",
                    &format!("{} — {}", table.rows, kilobytes(table.bytes)),
                );
            }
            // Les fichiers des pièces jointes, qui voyagent avec.
            let kept: Vec<_> = joined.iter().filter(|file| file.found).collect();
            let weight: usize = kept.iter().map(|file| file.bytes).sum();
            journal.add(
                "journal-step-backup-attachments",
                "PiecesJointes",
                Status::Success,
                "",
                &format!("{} — {}", kept.len(), kilobytes(weight)),
            );
            // Celles que la base désigne et que le disque n'a plus : une
            // par ligne, parce qu'il faudra bien savoir lesquelles.
            for missing in joined.iter().filter(|file| !file.found) {
                journal.add(
                    "journal-step-backup-attachment-missing",
                    "PiecesJointes",
                    Status::Failure,
                    "",
                    &missing.guid_name,
                );
            }
            Ok((rows, bytes, tables.len()))
        }
        Err(reason) => {
            journal.add_file(
                "journal-step-backup-write",
                &path.to_string_lossy(),
                Status::Failure,
                &reason,
                "",
            );
            Err(reason)
        }
    };

    // **La relecture**, le contrôle que 1.9.3 ne pouvait pas faire : on
    // rouvre l'archive par le chemin qu'emprunterait une restauration, et
    // on dit ce qu'on y retrouve.
    let written = match written {
        Ok((rows, bytes, tables)) => {
            match radinus_core::backup::verify_archive(&path) {
                Ok(read) => {
                    let found: usize = read.iter().filter(|table| table.present).count();
                    let reread: usize = read.iter().map(|table| table.rows).sum();
                    let ok = found == tables && reread == rows;
                    journal.add_file(
                        "journal-step-backup-verified",
                        &path.to_string_lossy(),
                        if ok { Status::Success } else { Status::Failure },
                        "",
                        &format!("{found} / {tables} — {reread} / {rows}"),
                    );
                    if ok {
                        Ok((rows, bytes))
                    } else {
                        Err(i18n::text(language, "backup-verify-mismatch"))
                    }
                }
                Err(error) => {
                    journal.add_file(
                        "journal-step-backup-verified",
                        &path.to_string_lossy(),
                        Status::Failure,
                        &error.to_string(),
                        "",
                    );
                    Err(error.to_string())
                }
            }
        }
        Err(reason) => Err(reason),
    };

    let written = written.map(|(rows, bytes)| {
        journal.add(
            "journal-step-backup-total",
            "",
            Status::Success,
            "",
            &format!(
                "{rows} — {} — {}",
                kilobytes(bytes),
                kilobytes(std::fs::metadata(&path).map(|m| m.len() as usize).unwrap_or(0))
            ),
        );
    });

    journal.add_file(
        "journal-step-backup-end",
        &path.to_string_lossy(),
        if written.is_ok() {
            Status::Finished
        } else {
            Status::Failure
        },
        "",
        &stamp(),
    );
    keep_journal(app, journal, false);

    match written {
        Ok(()) => tell(
            app,
            &title,
            &i18n::text_with(
                language,
                "backup-done",
                "file",
                &path.to_string_lossy(),
            ),
            false,
        ),
        Err(reason) => tell(
            app,
            &title,
            &i18n::text_with(language, "backup-failed", "reason", &reason),
            true,
        ),
    }
}

/// **Sauvegarder la base ouverte**, sans avoir à en connaître le chemin.
///
/// Les quatre opérations techniques visent la ligne choisie dans la fenêtre
/// des bases, et reçoivent son chemin. Une fenêtre d'importation, elle, ne
/// connaît que le compte sur lequel elle travaille : le chemin de la base ne
/// lui a jamais été dit, et n'a aucune raison de l'être.
///
/// `AppState` ne retient de la base ouverte que son dossier de pièces
/// jointes — c'est ce qui sert à la reconnaître dans `target_of`. Le fichier
/// est son voisin, et le chemin attendu ici est celui-là, relatif à la racine
/// des données.
pub fn backup_open<R: Runtime>(app: &AppHandle<R>) -> Result<(), String> {
    let language = language(app);
    let absent = || i18n::text(language, "backup-no-database");

    let state = app.try_state::<AppState>().ok_or_else(absent)?;
    if !state.has_database() {
        return Err(absent());
    }
    let sqlite = state
        .attachments_dir()
        .parent()
        .map(|folder| folder.join(radinus_core::location::DATABASE_FILE_NAME))
        .ok_or_else(absent)?;
    let relative = sqlite
        .strip_prefix(&state.data_root)
        .map_err(|_| absent())?
        .to_path_buf();

    // La base ouverte est déjà déverrouillée : sa clé ne sert pas ici.
    backup_now(app, &relative.to_string_lossy(), None);
    Ok(())
}

/// **Restauration** — menu Fichier › Opérations base de données ›
/// Restauration.
///
/// **L'archive est lue avant que la question ne soit posée.** Une confirmation
/// suivie d'un « ce fichier n'est pas une archive Radinus » serait cruelle :
/// l'utilisateur aurait accepté d'effacer sa base pour rien. On lit d'abord,
/// on demande ensuite, et ce que la question annonce est donc certain.
///
/// Une seule confirmation, sans sauvegarde automatique préalable (choix de
/// Fabrice, 01/08/2026) : la question dit ce qui sera perdu, l'utilisateur
/// reste maître de sauvegarder avant s'il le souhaite.
pub fn restore<R: Runtime>(app: AppHandle<R>, relative: String, password: Option<String>) {
    std::thread::spawn(move || {
        let language = language(&app);
        let Some(target) = target_of(&app, &relative) else {
            return;
        };
        let title = i18n::text(language, "menu-file-restore");

        let (answered, answer) = std::sync::mpsc::channel();
        app.dialog()
            .file()
            .add_filter(i18n::text(language, "backup-archive"), &["zip", "ZIP"])
            .pick_file(move |chosen| {
                let _ = answered.send(chosen);
            });
        let Ok(Some(chosen)) = answer.recv() else {
            return;
        };
        let Ok(path) = chosen.into_path() else {
            return;
        };

        let mut journal = Journal::new(language);
        journal.add_file(
            "journal-step-restore-begin",
            &path.to_string_lossy(),
            Status::Started,
            "",
            &stamp(),
        );

        let archive = match radinus_core::backup::read_archive(&path) {
            Ok(archive) => archive,
            Err(error) => {
                journal.add_file(
                    "journal-step-restore-read",
                    &path.to_string_lossy(),
                    Status::Failure,
                    &error.to_string(),
                    "",
                );
                keep_journal(&app, journal, false);
                tell(
                    &app,
                    &title,
                    &i18n::text_with(language, "restore-unreadable", "reason", &error.to_string()),
                    true,
                );
                return;
            }
        };

        // Une ligne par table, et **la distinction que nous ne faisions pas** :
        // un fichier absent de l'archive n'est pas une table vide.
        for table in &archive.read {
            if table.present {
                journal.add(
                    "journal-step-restore-table",
                    table.table,
                    Status::Success,
                    "",
                    &format!("{} — {}", table.rows, kilobytes(table.bytes)),
                );
            } else {
                journal.add(
                    "journal-step-restore-missing",
                    table.table,
                    Status::Failure,
                    "",
                    &format!("radinus_sauve_{}.json", table.stem),
                );
            }
        }

        if !ask(
            &app,
            language,
            &title,
            // **Plus d'avertissement de fermeture** : Radinus ne se ferme plus
            // (Fabrice, 04/08/2026). La question dit ce qu'elle a toujours dit
            // — le contenu actuel sera effacé et remplacé — et ne promet plus
            // rien d'autre.
            &i18n::text_with(
                language,
                "restore-question",
                "file",
                &path
                    .file_name()
                    .map(|name| name.to_string_lossy().to_string())
                    .unwrap_or_default(),
            ),
        ) {
            return;
        }

        journal.add("journal-step-restore-wipe", "", Status::Success, "", "");

        let restored = match app.try_state::<AppState>() {
            Some(state) => match hold(&state, &target, language, password.as_deref()) {
                Ok(mut held) => {
                    let conn = held.conn();
                    let issue = radinus_core::backup::restore_into(conn, &archive)
                        .map_err(|error| error.to_string());
                    if issue.is_ok() {
                        // **Remonter une sauvegarde ne change pas la langue**
                        // (décision de Fabrice, 03/08/2026). L'archive porte
                        // la sienne, et `restore_into` vient de l'écrire dans
                        // la base ; on la remet aussitôt sur celle du
                        // logiciel. Rien ne la relit pour l'affichage, mais la
                        // colonne ne doit pas mentir : une sauvegarde reprise
                        // dans la foulée l'emporterait sous Windows.
                        let _ = i18n::store_language(conn, i18n::in_use());
                    }
                    issue
                }
                Err(error) => Err(error),
            },
            None => Err(i18n::text(language, "backup-no-database")),
        };

        match &restored {
            Ok(report) => {
                journal.add(
                    "journal-step-restore-total",
                    "",
                    Status::Success,
                    "",
                    &format!("{} — {}", report.accounts, report.operations),
                );
                // Le journal garde la trace des champs comblés, même quand la
                // fenêtre n'en dit rien : c'est là qu'on ira voir six mois
                // plus tard, si un montant paraît suspect.
                if report.empty_fields > 0 {
                    journal.add(
                        "journal-step-restore-empty-fields",
                        "",
                        Status::Success,
                        "",
                        &report.empty_fields.to_string(),
                    );
                }
                // Les fichiers des pièces jointes ressortent de l'archive
                // après les lignes qui les désignent.
                let folder = target.attachments.clone();
                match radinus_core::backup::restore_attachments(&path, &folder) {
                    Ok(files) => {
                        let weight: usize = files.iter().map(|(_, bytes)| bytes).sum();
                        journal.add(
                            "journal-step-restore-attachments",
                            "PiecesJointes",
                            Status::Success,
                            "",
                            &format!("{} — {}", files.len(), kilobytes(weight)),
                        );
                    }
                    Err(error) => journal.add(
                        "journal-step-restore-attachments",
                        "PiecesJointes",
                        Status::Failure,
                        &error.to_string(),
                        "",
                    ),
                }
            }
            Err(reason) => journal.add_file(
                "journal-step-restore-write",
                &path.to_string_lossy(),
                Status::Failure,
                reason,
                "",
            ),
        }
        journal.add_file(
            "journal-step-restore-end",
            &path.to_string_lossy(),
            if restored.is_ok() {
                Status::Finished
            } else {
                Status::Failure
            },
            "",
            &stamp(),
        );
        keep_journal(&app, journal, false);

        match restored {
            Ok(report) => {
                // **Radinus ne quitte plus** (décision de Fabrice, 04/08/2026,
                // qui révise la sienne du 03/08). La sortie forcée existait
                // parce qu'une restauration réassigne tous les identifiants
                // sous des fenêtres déjà ouvertes ; elle n'a plus de sens quand
                // la base restaurée n'est même pas celle qu'on regarde, et il a
                // tranché qu'elle n'en avait plus dans aucun cas.
                //
                // **Ce qui protège maintenant, quand c'est la base ouverte** :
                // les brouillons en mémoire sont jetés — le relevé en cours
                // d'importation, la feuille Excel, le calendrier proposé, ce
                // que chaque fiche déclarait tenir — puis les fenêtres relisent
                // la base. C'est le remède étroit que j'avais signalé le
                // 03/08 et qu'il avait alors écarté au profit de la fermeture.
                //
                // ⚠ **Il reste un cas qu'aucun des deux ne couvre**, et il lui
                // a été dit : une fenêtre ouverte sur le compte 3 se relira sur
                // le compte 3 *de la base restaurée*, qui est un autre compte.
                // Seul quitter l'empêchait.
                if target.open {
                    if let Some(state) = app.try_state::<AppState>() {
                        state.forget_drafts();
                    }
                    everything_moved(&app);
                }
                // **Ce qui a été comblé se dit**, quand il y a eu quelque
                // chose à combler (10/08/2026). Une archive écrite par
                // Radinus n'en porte aucun ; beaucoup d'archives 1.9.3 en
                // portent des milliers, et l'utilisateur a le droit de savoir
                // que sa restauration a lu des champs vides plutôt que de
                // s'être arrêtée dessus.
                let mut said = i18n::message_of(
                    language,
                    "restore-done",
                    &[],
                    &[
                        ("accounts", report.accounts as i64),
                        ("operations", report.operations as i64),
                    ],
                );
                if report.empty_fields > 0 {
                    said.push(' ');
                    said.push_str(&i18n::message_of(
                        language,
                        "restore-empty-fields",
                        &[],
                        &[("count", report.empty_fields as i64)],
                    ));
                }
                tell(&app, &title, &said, false);
            }
            Err(reason) => tell(
                &app,
                &title,
                &i18n::text_with(language, "restore-failed", "reason", &reason),
                true,
            ),
        }
    });
}

/// **Réparation et optimisation** — menu Fichier › Opérations base de données.
///
/// Aucune question préalable : c'est le choix de Fabrice (01/08/2026), et
/// c'est celui de son code. Réparer est un geste voulu, et celui qui le
/// demande sait ce qu'il fait — y compris que le traitement peut effacer des
/// enregistrements incohérents.
///
/// Le résultat va dans le journal, comme chez lui, et la fenêtre du journal
/// s'ouvre à la fin : « le résultat est consultable dans le journal »
/// (06_FORMATS_SAUVEGARDE_IMPORT_EXPORT.md §6).
pub fn repair<R: Runtime>(app: AppHandle<R>, relative: String, password: Option<String>) {
    std::thread::spawn(move || {
        let language = language(&app);
        let title = i18n::text(language, "menu-file-repair");
        let Some(target) = target_of(&app, &relative) else {
            return;
        };

        let done = match app.try_state::<AppState>() {
            Some(state) => match hold(&state, &target, language, password.as_deref()) {
                Ok(mut held) => radinus_core::repair::run(held.conn(), language)
                    .map_err(|error| error.to_string()),
                Err(error) => Err(error),
            },
            None => Err(i18n::text(language, "backup-no-database")),
        };

        match done {
            Ok(report) => {
                let anomalies = report.anomalies as i64;
                let lines = report.journal.len() as i64;
                keep_journal(&app, report.journal, true);
                // Une réparation touche les soldes et peut effacer des
                // opérations : tout ce qui est ouvert relit la base.
                everything_moved(&app);
                tell(
                    &app,
                    &title,
                    &i18n::message_of(
                        language,
                        "repair-done",
                        &[],
                        &[("anomalies", anomalies), ("lines", lines)],
                    ),
                    false,
                );
            }
            Err(reason) => tell(
                &app,
                &title,
                &i18n::text_with(language, "repair-failed", "reason", &reason),
                true,
            ),
        }
    });
}
