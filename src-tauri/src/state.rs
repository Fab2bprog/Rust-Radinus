//! The application's shared state: the database that is open right now.
//!
//! Until Phase 3 the bootstrap opened the database only to validate it and
//! dropped the connection immediately. Now that windows read and write real
//! data, the connection has to survive the bootstrap and be reachable from
//! every IPC command, so it lives here behind a mutex — SQLite serializes
//! writes anyway, and every command is short.
//!
//! Nothing business-related belongs in this crate (08_ARCHITECTURE.md §2.2):
//! this is plumbing, and every command below it forwards straight to
//! `radinus_core`.

use radinus_core::database::Connection;
use radinus_core::nomenclatures::Nomenclature;
use radinus_core::quick_classification::Workbench;
use radinus_core::csv_excel_import::{Book, Capture, Grid, Link, Policies};
use radinus_core::recurring_operations::Occurrence;
use radinus_core::statements::Import;
use std::collections::HashMap;
use std::path::PathBuf;
use std::sync::{Mutex, MutexGuard};

/// The accounts fiche is not a nomenclature, but it declares itself the same
/// way and in the same place. Its own key, which no nomenclature can take.
const ACCOUNT_FORM: &str = "account";

/// And the fiche opération (F03), which declares itself the same way again.
const OPERATION_FORM: &str = "operation";

/// What one nomenclature's fiche is holding right now.
#[derive(Default)]
struct FormState {
    /// Something typed and not saved.
    dirty: bool,
    /// The element it is showing, if any.
    record: Option<i64>,
}

pub struct AppState {
    /// The database currently open, or nothing when the bootstrap failed.
    /// Guarded rather than pooled: the application is single-user and its
    /// writes are short.
    database: Mutex<Option<Connection>>,
    /// Why there is no database, in the user's own terms. Set when, and only
    /// when, `database` is empty.
    startup_error: Option<String>,
    /// Whether each nomenclature's fiche currently holds something typed and
    /// not saved, and which element it is showing. Kept per nomenclature: the
    /// seven fiches share one page but are seven distinct windows, and the
    /// Catégories list must not answer for what the Tiers fiche holds.
    ///
    /// Both live here rather than being asked for when needed: a list has to
    /// know, before closing, whether it would take unsaved work down with it,
    /// and asking the fiche through an event was a round trip that sometimes
    /// arrived before the fiche was listening — the question was then simply
    /// not asked (reported by Fabrice, 25/07/2026: "certaines fois les
    /// modifications sont détectées, certaines fois non"). A declared state
    /// cannot arrive late.
    forms: Mutex<HashMap<&'static str, FormState>>,
    /// **Le brouillon de la classification rapide** (F05) : toutes les
    /// opérations d'un compte, et la réserve qui dit où elles en étaient.
    ///
    /// Elle vit ici, du côté de Rust, et non dans la fenêtre : le noyau tient
    /// le modèle, la fenêtre montre. Une copie dans le navigateur serait une
    /// seconde vérité, et deux vérités finissent toujours par diverger.
    ///
    /// `None` tant qu'aucun compte n'est chargé. **Charger remplace** — voir
    /// `quick_classification::load` : rien n'est jamais ajouté à une structure
    /// existante, elle est jetée entière avec ce qu'elle contenait.
    workbench: Mutex<Option<Workbench>>,
    /// **Le relevé bancaire en cours d'importation** (F17) : le fichier OFX lu,
    /// et ce que la base en connaît déjà.
    ///
    /// Il vit ici pour la même raison que le brouillon de la classification
    /// rapide : ouvrir un fichier ne touche pas la base, et la fenêtre ne
    /// détient aucune copie qui pourrait diverger de ce qui sera écrit.
    import: Mutex<Option<Import>>,
    /// **La feuille Excel en cours d'importation** (F34/F35, phase 13) : le
    /// classeur lu, la zone de capture réglée, la concordance des champs et les
    /// trois politiques.
    ///
    /// Elle traverse trois fenêtres et n'est écrite qu'à la fin ; la garder ici
    /// plutôt que dans les fenêtres a une raison précise : **le classeur est lu
    /// une seule fois**. Le relire entre l'étape 1 et l'intégration ferait
    /// entrer autre chose que ce que le rendu test a montré, si le fichier a
    /// changé entre-temps.
    excel: Mutex<Option<ExcelImport>>,
    /// **Le calendrier proposé** (F16, phase 16) : les échéances que les règles
    /// choisies produiraient.
    ///
    /// Il vit ici et non dans la fenêtre pour la raison de toujours — une copie
    /// dans le navigateur serait une seconde vérité — et pour une raison propre
    /// à cette fenêtre : ce qui sera écrit doit être exactement ce qui a été
    /// proposé, moins ce que la corbeille rouge a retiré. La fenêtre ne renvoie
    /// donc que des rangs, jamais des montants ni des dates.
    calendar: Mutex<Option<Vec<Occurrence>>>,
    /// **Le journal de la dernière opération technique** (phase 17).
    ///
    /// Il vit ici, en mémoire, et nulle part ailleurs : c'est ce que fait
    /// l'original, dont le `gtabMonLog` est vidé à l'ouverture de chacune des
    /// trois procédures. Le journal ne s'accumule pas et ne survit pas à la
    /// fermeture du logiciel — ce n'est pas une archive, c'est le compte rendu
    /// de ce qui vient de se passer.
    journal: Mutex<Vec<radinus_core::journal::Entry>>,
    /// **Where Radinus keeps its things**: the folder holding `settings/`,
    /// `databases/`, `backups/` and `logs/`. Resolved once at bootstrap by
    /// `location::data_root`, never recomputed.
    ///
    /// Since 05/08/2026 this is **not** necessarily the folder the application
    /// sits in — see [`Self::application_root`].
    #[allow(dead_code)]
    pub data_root: PathBuf,
    /// **The folder the application itself sits in**, which the Divers menu
    /// opens under its own name.
    ///
    /// It was the same thing as [`Self::data_root`] until the installed mode
    /// arrived: in that mode the application is in `/Applications` while its
    /// data is in `~/Library/Application Support/Radinus`. The two were kept as
    /// one field, so the menu entry saying "the folder containing the
    /// application" started opening the data folder. Reported by Fabrice the
    /// same day: *« je veux que ça ouvre le dossier de l'application comme
    /// c'est marqué »*.
    #[allow(dead_code)]
    pub application_root: PathBuf,
    /// Le dossier des pièces jointes de la base ouverte —
    /// `databases/<slot>/attachments/`. Chaque base a le sien : deux bases ne
    /// partagent pas leurs pièces, et une sauvegarde n'emporte que celles de
    /// la sienne.
    ///
    /// **Sous verrou depuis le 02/08/2026** : il change quand la base change,
    /// et au démarrage la base n'est branchée qu'une fois que l'utilisateur a
    /// dit laquelle. Voir [`AppState::attach`].
    attachments_dir: Mutex<PathBuf>,
}

impl AppState {
    /// **Branche une base sur un Radinus qui attendait la sienne**
    /// (02/08/2026).
    ///
    /// C'est ce qui remplace le redémarrage au démarrage : quand l'utilisateur
    /// choisit ou crée sa base dans le sélecteur, aucune fenêtre n'est encore
    /// ouverte et rien n'a été lu — il n'y a donc rien à réinitialiser, et
    /// relancer le logiciel pour brancher une base qu'on n'a pas encore
    /// touchée serait une cérémonie sans objet. Ce l'était même deux fois :
    /// le processus relancé par `restart()` rendait des fenêtres blanches,
    /// faute trouvée par Fabrice le 02/08/2026.
    ///
    /// Changer de base **alors qu'une est déjà ouverte** reste un
    /// redémarrage : là, des fenêtres montrent des données, et elles ne
    /// savent pas les oublier.
    pub fn attach(&self, database: Connection, attachments: PathBuf) -> Result<(), String> {
        // **Tout ce qui parlait de l'ancienne base est jeté d'abord.** Le
        // brouillon de la classification rapide, le relevé en cours
        // d'importation, la feuille Excel, le calendrier proposé, le journal
        // du dernier traitement, et ce que chaque fiche déclarait tenir : ce
        // sont des identifiants et des montants de l'ancienne base. Les
        // garder ferait écrire les opérations d'une base dans une autre —
        // silencieusement, et c'est le pire.
        self.forget_everything();

        let mut slot = self.database.lock().map_err(to_ipc_error)?;
        *slot = Some(database);
        let mut folder = self.attachments_dir.lock().map_err(to_ipc_error)?;
        *folder = attachments;
        Ok(())
    }

    /// **Referme la base ouverte, et n'en ouvre aucune autre** (Fabrice,
    /// 05/08/2026, pour « Se déconnecter de la base en cours »).
    ///
    /// Le geste inverse d'[`Self::attach`], et il jette exactement les mêmes
    /// choses : le brouillon de la classification rapide, le relevé en cours
    /// d'importation, la feuille Excel, le calendrier proposé, le journal du
    /// dernier traitement, et ce que chaque fiche déclarait tenir. Ce sont des
    /// identifiants et des montants d'une base qu'on quitte.
    ///
    /// **La connexion se ferme en tombant du logement** : `*slot = None` la
    /// laisse partir, et SQLite ferme le fichier avec elle. C'est ce qui
    /// permet, juste après, de sauvegarder ou de protéger par mot de passe la
    /// base qu'on vient de quitter — deux opérations qui refusent de
    /// travailler sur une base ouverte.
    ///
    /// Le dossier des pièces jointes est vidé lui aussi : c'est à lui que
    /// `database_operations` reconnaît la base ouverte, et un chemin qui reste
    /// après le départ ferait passer pour ouverte une base qui ne l'est plus.
    pub fn detach(&self) -> Result<(), String> {
        self.forget_everything();

        let mut slot = self.database.lock().map_err(to_ipc_error)?;
        *slot = None;
        let mut folder = self.attachments_dir.lock().map_err(to_ipc_error)?;
        *folder = PathBuf::new();
        Ok(())
    }

    /// Oublie tout ce que Radinus tenait en mémoire de la base précédente.
    ///
    /// Rien n'est écrit nulle part : ce sont des brouillons, et un brouillon
    /// d'une autre base n'est pas un brouillon, c'est un piège.
    ///
    /// **Publique depuis le 04/08/2026** : la restauration ne fait plus quitter
    /// Radinus, et c'est elle qui doit maintenant jeter ces brouillons quand
    /// elle remonte une archive sur la base ouverte. C'est le remède étroit
    /// qui avait été écarté le 03/08 au profit de la fermeture.
    pub fn forget_drafts(&self) {
        self.forget_everything();
    }

    fn forget_everything(&self) {
        if let Ok(mut forms) = self.forms.lock() {
            forms.clear();
        }
        if let Ok(mut workbench) = self.workbench.lock() {
            *workbench = None;
        }
        if let Ok(mut import) = self.import.lock() {
            *import = None;
        }
        if let Ok(mut excel) = self.excel.lock() {
            *excel = None;
        }
        if let Ok(mut calendar) = self.calendar.lock() {
            *calendar = None;
        }
        if let Ok(mut journal) = self.journal.lock() {
            journal.clear();
        }
    }

    /// Le dossier des pièces jointes de la base ouverte.
    pub fn attachments_dir(&self) -> PathBuf {
        self.attachments_dir
            .lock()
            .map(|folder| folder.clone())
            .unwrap_or_default()
    }

    /// Une base est-elle ouverte ? Le sélecteur s'en sert pour savoir s'il
    /// peut brancher sur place ou s'il doit relancer.
    pub fn has_database(&self) -> bool {
        self.database
            .lock()
            .map(|slot| slot.is_some())
            .unwrap_or(false)
    }

    /// **L'état d'un Radinus qui attend qu'on lui dise quelle base ouvrir**
    /// (décision de Fabrice, 02/08/2026).
    ///
    /// Ce n'est pas une panne : aucune base n'est désignée, ou celle qui
    /// l'était a été renommée ou effacée hors du logiciel — ce que Fabrice
    /// autorise expressément. Radinus n'en fabrique pas une dans le dos de
    /// l'utilisateur ; il ouvre le sélecteur et attend son autorisation.
    ///
    /// D'où l'absence de `startup_error` : il n'y a rien à reprocher à
    /// personne, et une fenêtre qui interrogerait la base recevrait la phrase
    /// ordinaire « aucune base n'est ouverte » plutôt qu'un message d'alarme.
    pub fn pending(data_root: PathBuf, application_root: PathBuf) -> Self {
        Self {
            database: Mutex::new(None),
            startup_error: None,
            forms: Mutex::new(HashMap::new()),
            workbench: Mutex::new(None),
            import: Mutex::new(None),
            excel: Mutex::new(None),
            calendar: Mutex::new(None),
            journal: Mutex::new(Vec::new()),
            data_root,
            application_root,
            attachments_dir: Mutex::new(PathBuf::new()),
        }
    }

    /// The state of an application that started without a database. It is
    /// **still registered**: every command then answers with this explanation
    /// instead of the framework's own "state not managed", which says nothing
    /// to the user and only surfaces on the third click.
    pub fn failed(reason: String, data_root: PathBuf, application_root: PathBuf) -> Self {
        Self {
            database: Mutex::new(None),
            startup_error: Some(reason),
            forms: Mutex::new(HashMap::new()),
            workbench: Mutex::new(None),
            import: Mutex::new(None),
            excel: Mutex::new(None),
            calendar: Mutex::new(None),
            journal: Mutex::new(Vec::new()),
            data_root,
            application_root,
            attachments_dir: Mutex::new(PathBuf::new()),
        }
    }

    /// Records whether a nomenclature's fiche holds unsaved work.
    pub fn set_form_dirty(&self, kind: Nomenclature, dirty: bool) -> Result<(), String> {
        let mut forms = self.forms.lock().map_err(to_ipc_error)?;
        forms.entry(kind.key()).or_default().dirty = dirty;
        Ok(())
    }

    /// Whether a nomenclature's fiche holds unsaved work.
    pub fn form_is_dirty(&self, kind: Nomenclature) -> bool {
        self.forms
            .lock()
            .map(|forms| forms.get(kind.key()).is_some_and(|form| form.dirty))
            .unwrap_or(false)
    }

    /// Records which element a nomenclature's fiche is showing, or `None`.
    pub fn set_form_record(&self, kind: Nomenclature, id: Option<i64>) -> Result<(), String> {
        let mut forms = self.forms.lock().map_err(to_ipc_error)?;
        forms.entry(kind.key()).or_default().record = id;
        Ok(())
    }

    /// Which element a nomenclature's fiche is showing, if any.
    pub fn form_record(&self, kind: Nomenclature) -> Option<i64> {
        self.forms
            .lock()
            .map(|forms| forms.get(kind.key()).and_then(|form| form.record))
            .unwrap_or(None)
    }

    /// Which account the fiche compte is showing, or nothing. The accounts
    /// list refuses to delete an account whose fiche is open, for the reason
    /// the nomenclatures do — and here it matters more: deleting an account
    /// takes its operations with it.
    pub fn set_account_form_record(&self, id: Option<i64>) -> Result<(), String> {
        let mut forms = self.forms.lock().map_err(to_ipc_error)?;
        forms.entry(ACCOUNT_FORM).or_default().record = id;
        Ok(())
    }

    /// Which account the fiche compte is showing, if any.
    pub fn account_form_record(&self) -> Option<i64> {
        self.forms
            .lock()
            .map(|forms| forms.get(ACCOUNT_FORM).and_then(|form| form.record))
            .unwrap_or(None)
    }

    /// Whether the fiche compte holds unsaved work.
    pub fn set_account_form_dirty(&self, dirty: bool) -> Result<(), String> {
        let mut forms = self.forms.lock().map_err(to_ipc_error)?;
        forms.entry(ACCOUNT_FORM).or_default().dirty = dirty;
        Ok(())
    }

    pub fn account_form_is_dirty(&self) -> bool {
        self.forms
            .lock()
            .map(|forms| forms.get(ACCOUNT_FORM).is_some_and(|form| form.dirty))
            .unwrap_or(false)
    }

    /// Which operation the fiche opération is showing, or nothing. The list
    /// refuses to delete an operation whose fiche is open, as everywhere else
    /// in Radinus (author's ruling, 25/07/2026): a fiche left showing a
    /// record that no longer exists would write it back on the next save.
    pub fn set_operation_form_record(&self, id: Option<i64>) -> Result<(), String> {
        let mut forms = self.forms.lock().map_err(to_ipc_error)?;
        forms.entry(OPERATION_FORM).or_default().record = id;
        Ok(())
    }

    pub fn operation_form_record(&self) -> Option<i64> {
        self.forms
            .lock()
            .map(|forms| forms.get(OPERATION_FORM).and_then(|form| form.record))
            .unwrap_or(None)
    }

    pub fn set_operation_form_dirty(&self, dirty: bool) -> Result<(), String> {
        let mut forms = self.forms.lock().map_err(to_ipc_error)?;
        forms.entry(OPERATION_FORM).or_default().dirty = dirty;
        Ok(())
    }

    pub fn operation_form_is_dirty(&self) -> bool {
        self.forms
            .lock()
            .map(|forms| forms.get(OPERATION_FORM).is_some_and(|form| form.dirty))
            .unwrap_or(false)
    }

    /// **Remplace** le brouillon de la classification rapide par celui-ci.
    /// L'ancien s'en va avec tout ce qu'il portait, y compris les
    /// modifications que personne n'avait enregistrées : c'est le prix, et le
    /// sens, d'un brouillon.
    pub fn set_workbench(&self, bench: Workbench) -> Result<(), String> {
        *self.workbench.lock().map_err(to_ipc_error)? = Some(bench);
        Ok(())
    }

    /// Fait quelque chose du brouillon **du compte demandé**.
    ///
    /// Le compte est vérifié, et c'est là tout l'intérêt : une fenêtre qui
    /// demanderait les lignes d'un compte alors que la structure en tient un
    /// autre recevrait un refus, et non les opérations de quelqu'un d'autre.
    /// C'est la faute des statistiques du 26/07/2026 — « quel que soit le
    /// compte choisi, c'est toujours la première ligne » — rendue impossible à
    /// l'endroit où elle se produirait.
    pub fn with_workbench<T>(
        &self,
        account_id: i64,
        act: impl FnOnce(&mut Workbench) -> T,
    ) -> Result<T, String> {
        let mut guard = self.workbench.lock().map_err(to_ipc_error)?;
        let Some(bench) = guard.as_mut() else {
            return Err("Aucun compte n'est chargé pour la classification rapide.".to_string());
        };
        if bench.account_id() != account_id {
            return Err(format!(
                "La classification rapide travaille sur le compte {}, et non sur le compte {account_id}.",
                bench.account_id()
            ));
        }
        Ok(act(bench))
    }

    /// Jette le brouillon. Quitter la fenêtre en abandonnant ne doit rien
    /// laisser derrière : revenir plus tard, c'est repartir de la base.
    pub fn drop_workbench(&self) -> Result<(), String> {
        *self.workbench.lock().map_err(to_ipc_error)? = None;
        Ok(())
    }

    /// **Remplace** le relevé en cours par celui-ci. Comme le brouillon, on ne
    /// complète jamais : ouvrir un second fichier jette le premier.
    pub fn set_import(&self, import: Import) -> Result<(), String> {
        *self.import.lock().map_err(to_ipc_error)? = Some(import);
        Ok(())
    }

    /// Fait quelque chose du relevé **du compte demandé**, et refuse quand ce
    /// n'est pas le sien : une fenêtre ne doit jamais intégrer les lignes d'un
    /// relevé dans un autre compte que celui qu'il concerne.
    pub fn with_import<T>(
        &self,
        account_id: i64,
        act: impl FnOnce(&mut Import) -> T,
    ) -> Result<T, String> {
        let mut guard = self.import.lock().map_err(to_ipc_error)?;
        let Some(import) = guard.as_mut() else {
            return Err("Aucun relevé n'est ouvert.".to_string());
        };
        if import.account_id != account_id {
            return Err(format!(
                "Le relevé ouvert concerne le compte {}, et non le compte {account_id}.",
                import.account_id
            ));
        }
        Ok(act(import))
    }

    /// Jette le relevé. Quitter la fenêtre ne laisse rien derrière : ce qui n'a
    /// pas été intégré n'a jamais existé.
    pub fn drop_import(&self) -> Result<(), String> {
        *self.import.lock().map_err(to_ipc_error)? = None;
        Ok(())
    }

    /// **Remplace** l'import Excel en cours. Désigner un autre fichier jette le
    /// précédent avec tous ses réglages : on ne mélange pas deux feuilles.
    pub fn set_excel(&self, excel: ExcelImport) -> Result<(), String> {
        *self.excel.lock().map_err(to_ipc_error)? = Some(excel);
        Ok(())
    }

    /// Fait quelque chose de l'import Excel en cours, et refuse quand il n'y en
    /// a pas — une fenêtre d'étape 2 ne doit rien pouvoir faire sans l'étape 1.
    pub fn with_excel<T>(&self, act: impl FnOnce(&mut ExcelImport) -> T) -> Result<T, String> {
        let mut guard = self.excel.lock().map_err(to_ipc_error)?;
        let Some(excel) = guard.as_mut() else {
            return Err("Aucune feuille Excel n'est ouverte.".to_string());
        };
        Ok(act(excel))
    }

    /// Jette l'import Excel. Quitter l'étape 1 ne laisse rien derrière.
    pub fn drop_excel(&self) -> Result<(), String> {
        *self.excel.lock().map_err(to_ipc_error)? = None;
        Ok(())
    }

    /// **Remplace** le calendrier proposé. Redemander une proposition jette la
    /// précédente : on n'empile pas deux calendriers.
    pub fn set_calendar(&self, proposed: Vec<Occurrence>) -> Result<(), String> {
        *self.calendar.lock().map_err(to_ipc_error)? = Some(proposed);
        Ok(())
    }

    /// Fait quelque chose du calendrier proposé, et refuse quand il n'y en a
    /// pas — une fenêtre ne doit rien pouvoir insérer sans proposition.
    pub fn with_calendar<T>(
        &self,
        act: impl FnOnce(&[Occurrence]) -> T,
    ) -> Result<T, String> {
        let guard = self.calendar.lock().map_err(to_ipc_error)?;
        let Some(proposed) = guard.as_ref() else {
            return Err("Aucun calendrier n'est proposé.".to_string());
        };
        Ok(act(proposed))
    }

    /// What went wrong at startup, if anything.
    pub fn startup_error(&self) -> Option<&str> {
        self.startup_error.as_deref()
    }

    /// The open database, or the reason there is none.
    /// Remplace le journal par celui du traitement qui vient de finir.
    ///
    /// **Remplace, n'ajoute pas.** Une opération technique efface le compte
    /// rendu de la précédente, comme le `SupprimeTout()` de l'original : deux
    /// traitements mêlés dans une même liste ne se lisent plus.
    pub fn set_journal(&self, entries: Vec<radinus_core::journal::Entry>) {
        if let Ok(mut journal) = self.journal.lock() {
            *journal = entries;
        }
    }

    pub fn journal(&self) -> Vec<radinus_core::journal::Entry> {
        self.journal
            .lock()
            .map(|journal| journal.clone())
            .unwrap_or_default()
    }

    pub fn database(&self) -> Result<DatabaseGuard<'_>, String> {
        let guard = self.database.lock().map_err(to_ipc_error)?;
        if guard.is_none() {
            return Err(self
                .startup_error
                .clone()
                .unwrap_or_else(|| "Aucune base de données n'est ouverte.".to_string()));
        }
        Ok(DatabaseGuard(guard))
    }
}

/// La feuille Excel en cours d'importation, d'un bout à l'autre des trois
/// étapes (phase 13).
pub struct ExcelImport {
    /// Le compte dans lequel on importe — choisi **avant** d'ouvrir la fenêtre,
    /// comme pour l'OFX : on importe toujours dans un compte, jamais « quelque
    /// part ».
    pub account_id: i64,
    pub path: String,
    /// Le classeur, lu une seule fois.
    pub book: Book,
    pub capture: Capture,
    /// Ce que la zone de capture attrape, tel que le rendu test l'a montré.
    pub grid: Grid,
    pub links: Vec<Link>,
    pub policies: Policies,
}

/// Hands out the open connection while keeping the lock held. Dereferences to
/// the connection so command bodies read as if they held it directly.
pub struct DatabaseGuard<'a>(MutexGuard<'a, Option<Connection>>);

impl std::ops::Deref for DatabaseGuard<'_> {
    type Target = Connection;
    fn deref(&self) -> &Connection {
        self.0.as_ref().expect("checked when the guard was built")
    }
}

impl std::ops::DerefMut for DatabaseGuard<'_> {
    fn deref_mut(&mut self) -> &mut Connection {
        self.0.as_mut().expect("checked when the guard was built")
    }
}

/// Turns any error into the string the frontend receives. IPC carries no Rust
/// types, so a command's error is always a message — the frontend decides how
/// to show it.
pub fn to_ipc_error(error: impl std::fmt::Display) -> String {
    error.to_string()
}
