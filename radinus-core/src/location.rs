//! **Où Radinus range tout** : la décision, l'arborescence du premier
//! lancement, et la lecture-écriture de `settings/radinus_config.json`.
//!
//! **Une seule version de Radinus existe** (décision de Fabrice, 05/08/2026).
//! Elle s'installe normalement et range ses données dans le dossier standard
//! du système ; elle devient **portable** quand elle trouve
//! `settings/start_mode.toml` à côté d'elle avec `portable_mode = 1`, et alors
//! tout vit à côté de l'application et se copie sur une clé. Trois
//! compilations au total — une par système —, pas six.
//!
//! Ce module s'appelait `portable.rs` et sa fonction principale
//! `portable_root`. Les deux noms sont devenus faux le jour où le mode
//! installé est apparu : la fonction rend le plus souvent
//! `~/Library/Application Support/Radinus`, qui n'a rien de portable. Un nom
//! qui ment finit toujours par produire une erreur, d'où le renommage du
//! 05/08/2026.
//!
//! Le dossier standard dépend du système ; voir [`system_folder`]. Exigence
//! d'origine : 01_CAHIER_DES_CHARGES.md §3.3 bis et 08_ARCHITECTURE.md §3bis,
//! qui ne demandaient que le mode portable.

use serde::{Deserialize, Serialize};
use std::fs;
use std::io;
use std::path::{Path, PathBuf};

/// The four folders created at first launch, right next to the app.
pub const SETTINGS_DIR: &str = "settings";
pub const DATABASES_DIR: &str = "databases";
pub const BACKUPS_DIR: &str = "backups";
pub const LOGS_DIR: &str = "logs";

pub const CONFIG_FILE_NAME: &str = "radinus_config.json";

/// Le nom du fichier SQLite, **le même dans chaque dossier de base**
/// (décision de Fabrice, 02/08/2026). C'est le dossier qui distingue deux
/// bases, jamais le nom du fichier.
pub const DATABASE_FILE_NAME: &str = "radinus.sqlite";

/// Le fichier qui raconte d'où vient une base, dans le dossier de la base, à
/// côté du SQLite.
pub const DATABASE_INFO_FILE_NAME: &str = "radinus_base.json";

/// Persisted application settings (`settings/radinus_config.json`).
///
/// Dossier reference: 08_ARCHITECTURE.md §3bis point 5 bis. Kept
/// intentionally minimal for Phase 0 — grows as later phases need more
/// fields (recent databases list, language, etc. are already provided for).
// **`Eq` est parti avec l'arrivée du zoom** (04/08/2026) : un flottant ne
// l'implémente pas, parce que `NaN` n'est même pas égal à lui-même.
// `PartialEq` suffit — c'est tout ce dont `assert_eq!` a besoin, et cette
// structure ne sert de clef à aucun dictionnaire.
#[derive(Debug, Clone, Default, Serialize, Deserialize, PartialEq)]
pub struct SoftwareConfig {
    /// **La dernière base ouverte**, en chemin relatif à la racine portable —
    /// `databases/Radinus_00001/radinus.sqlite`.
    ///
    /// Son nom dit encore « par défaut », et son sens a changé le 02/08/2026 :
    /// Radinus **n'ouvre plus aucune base tout seul**, le sélecteur paraît à
    /// chaque démarrage (décision de Fabrice). Ce souvenir ne sert donc plus
    /// qu'à montrer en gras, dans le sélecteur, celle qu'on a ouverte la fois
    /// précédente. Le nom du champ est conservé pour que les configurations
    /// déjà écrites restent lisibles.
    #[serde(default)]
    pub default_database: Option<String>,

    /// Recently opened databases, most recent first.
    #[serde(default)]
    pub recent_databases: Vec<String>,

    /// UI language code ("fr" or "en" at launch; extensible later).
    #[serde(default)]
    pub language: Option<String>,

    /// **La taille de l'affichage, en facteur** — 1.0 pour 100 %.
    ///
    /// Elle vivait dans la table `Preferences` de chaque base jusqu'au
    /// 04/08/2026, où Fabrice a tranché : *« ce sera un paramètre du logiciel
    /// et non pas un paramètre de la base »*. Et il a raison : la taille des
    /// caractères dit quelque chose de l'écran et des yeux qui le regardent,
    /// pas des comptes qu'on y tient. Rangée dans la base, elle changeait en
    /// passant d'une base à l'autre, et une sauvegarde la promenait d'une
    /// machine sur une autre — celle d'un poste de bureau s'imposant à un
    /// portable.
    ///
    /// Elle rejoint donc la langue, dans `settings/radinus_config.json`, pour
    /// la raison qui y avait mis la langue.
    ///
    /// `None` quand rien n'a jamais été choisi : c'est 100 %.
    #[serde(default)]
    pub zoom: Option<f64>,

    /// **L'ordre jour/mois des relevés QIF**, quand aucune date du fichier ne
    /// le prouve (Fabrice, 15/10/2026, P-73) : `day-month` ou `month-day`.
    /// `None` — ou une valeur qu'on ne connaît pas — veut dire « me demander
    /// à chaque fois », le choix le plus sûr. Un réglage du logiciel, pas de
    /// la base : il dit comment sont faits les fichiers de l'utilisateur, pas
    /// ce que contiennent ses comptes.
    #[serde(default)]
    pub qif_date_order: Option<String>,

    /// **Le libellé d'une opération QIF** qui porte un tiers et un mémo :
    /// `both`, `payee` ou `memo`. `None`, ou inconnu : « tiers + mémo ».
    #[serde(default)]
    pub qif_label: Option<String>,

    /// **Le libellé d'une opération OFX** (Fabrice, 20/10/2026, premier
    /// menu) : `name`, `memo` ou `name-and-memo`. `None`, ou inconnu : le nom.
    #[serde(default)]
    pub ofx_label: Option<String>,
    /// **Sa référence paiement** (second menu) : `memo`, `name`,
    /// `name-and-memo` ou `empty`. `None`, ou inconnu : le mémo.
    #[serde(default)]
    pub ofx_reference: Option<String>,

    /// Les deux cases du 19/10/2026, remplacées le lendemain par les menus :
    /// encore lues, pour qu'un réglage déjà fait ne se perde pas, et effacées
    /// au premier enregistrement des menus.
    #[serde(default)]
    pub ofx_memo_in_label: Option<bool>,
    #[serde(default)]
    pub ofx_memo_in_reference: Option<bool>,
}

/// Les bornes de la taille d'affichage, et le pas du curseur.
///
/// **Pas d'astronomie** (demande de Fabrice) : de 70 % pour un petit écran, où
/// il en tient davantage, à 150 % pour qui voit mal. Au-delà, une fenêtre ne
/// montre plus assez pour servir à quelque chose.
pub const ZOOM_MIN: f64 = 0.7;
pub const ZOOM_MAX: f64 = 1.5;
pub const ZOOM_STEP: f64 = 0.1;
pub const ZOOM_DEFAULT: f64 = 1.0;

/// Ramène un facteur dans les bornes.
///
/// **`NaN` vaut 100 %** : il n'est ni plus grand ni plus petit que quoi que ce
/// soit, donc `clamp` ne le rattraperait pas — c'est le seul nombre flottant
/// qui glisse entre les comparaisons.
pub fn clamp_zoom(factor: f64) -> f64 {
    if factor.is_nan() {
        return ZOOM_DEFAULT;
    }
    factor.clamp(ZOOM_MIN, ZOOM_MAX)
}

/// How many entries `SoftwareConfig::remember_recent_database` keeps. Ten is
/// the usual "recent files" depth; the list is only ever read to populate a
/// menu, so a bound is needed to stop the config file growing forever.
pub const MAX_RECENT_DATABASES: usize = 10;

impl SoftwareConfig {
    /// Records `relative_path` as the most recently opened database: moves it
    /// to the front of `recent_databases` (removing any earlier occurrence, so
    /// the list never holds duplicates) and drops the oldest entries past
    /// [`MAX_RECENT_DATABASES`].
    pub fn remember_recent_database(&mut self, relative_path: &str) {
        self.recent_databases.retain(|p| p != relative_path);
        self.recent_databases.insert(0, relative_path.to_string());
        self.recent_databases.truncate(MAX_RECENT_DATABASES);
    }

    /// Makes `relative_path` the database opened at launch ("Définir comme
    /// base par défaut", menu Fichier). Also records it as recently opened,
    /// since a database can never become the default without being opened.
    pub fn set_default_database(&mut self, relative_path: &str) {
        self.default_database = Some(relative_path.to_string());
        self.remember_recent_database(relative_path);
    }

    /// La taille de l'affichage, ramenée dans ses bornes. 100 % tant que rien
    /// n'a été choisi — et 100 % aussi si la configuration porte un nombre
    /// impossible, plutôt que de rendre Radinus illisible sur la foi d'un
    /// fichier que l'utilisateur a le droit d'ouvrir.
    pub fn zoom_factor(&self) -> f64 {
        clamp_zoom(self.zoom.unwrap_or(ZOOM_DEFAULT))
    }

    /// L'ordre des dates QIF choisi d'avance, ou `None` pour « me demander ».
    /// Une valeur illisible dans le fichier de configuration vaut « me
    /// demander » : on ne devine jamais une date sur la foi d'un réglage
    /// corrompu.
    pub fn qif_order_choice(&self) -> Option<crate::qif_import::DateOrder> {
        self.qif_date_order.as_deref().and_then(crate::qif_import::DateOrder::from_key)
    }

    /// Le libellé des opérations QIF ; « tiers + mémo » par défaut, ou si la
    /// valeur est illisible — rien n'est perdu.
    pub fn qif_label_choice(&self) -> crate::qif_import::LabelChoice {
        self.qif_label.as_deref().and_then(crate::qif_import::LabelChoice::from_key).unwrap_or_default()
    }

    /// Ce que l'import OFX fait du NAME et du MEMO. Un réglage absent prend
    /// la valeur par défaut : le nom dans le libellé, le mémo dans la
    /// référence paiement.
    ///
    /// Sans réglage des menus, les deux cases du 19/10/2026 se traduisent :
    /// « Ajouter le mémo au libellé » coché, c'est « le nom suivi du mémo » ;
    /// « Copier le mémo dans la référence » décoché, c'est « rien ».
    pub fn ofx_memo_options(&self) -> crate::ofx_import::MemoOptions {
        use crate::ofx_import::{LabelSource, MemoOptions, ReferenceSource};
        let label = self.ofx_label.as_deref().and_then(LabelSource::from_key).unwrap_or(
            if self.ofx_memo_in_label == Some(true) {
                LabelSource::NameAndMemo
            } else {
                LabelSource::default()
            },
        );
        let reference = self.ofx_reference.as_deref().and_then(ReferenceSource::from_key).unwrap_or(
            if self.ofx_memo_in_reference == Some(false) {
                ReferenceSource::Empty
            } else {
                ReferenceSource::default()
            },
        );
        MemoOptions { label, reference }
    }

    /// Enregistre les deux menus OFX, et oublie les deux anciennes cases.
    pub fn set_ofx_memo_options(&mut self, options: crate::ofx_import::MemoOptions) {
        self.ofx_label = Some(options.label.key().to_string());
        self.ofx_reference = Some(options.reference.key().to_string());
        self.ofx_memo_in_label = None;
        self.ofx_memo_in_reference = None;
    }
}

/// Expresses `path` the way the config file stores it: relative to the
/// portable root, with forward slashes on every platform, so that a portable
/// folder copied from macOS to Windows (or onto a USB drive with a different
/// mount point) still resolves its databases.
pub fn relative_to_root(root: &Path, path: &Path) -> String {
    path.strip_prefix(root)
        .unwrap_or(path)
        .to_string_lossy()
        .replace('\\', "/")
}

/// **Le fichier qui dit comment Radinus démarre** (décision de Fabrice,
/// 05/08/2026).
///
/// Il ne contient qu'une ligne, `portable_mode = 0` ou `1`, et il est le seul
/// réglage qui ne puisse pas vivre dans le dossier des données : c'est lui qui
/// **décide** de ce dossier. On ne peut pas ranger dans une maison la clé qui
/// dit où est la maison.
pub const START_MODE_FILE_NAME: &str = "start_mode.toml";

/// Ce que ce fichier contient quand Radinus l'écrit lui-même.
///
/// **Le commentaire n'est pas une politesse, il est la moitié du dispositif.**
/// Écrit dans le dossier standard, ce fichier **dort** : Radinus ne lit que
/// celui qui se trouve à côté de son exécutable. Quelqu'un qui le passerait à
/// `1` sans rien déplacer ne verrait rien changer et croirait le logiciel
/// cassé. Les trois lignes du haut lui évitent ça.
///
/// Il voyage avec les données, et c'est tout son intérêt : le jour où l'on
/// déplace le dossier à côté de l'application, il arrive au bon endroit tout
/// seul et il ne reste qu'un chiffre à changer.
pub const START_MODE_TEMPLATE: &str = "\
# Ce fichier n'agit que s'il se trouve à côté de l'application.
# portable_mode = 1 : Radinus range ses données à côté de lui.
# portable_mode = 0 : Radinus range ses données dans le dossier
#                     standard du système.
portable_mode = 0
";

/// Où Radinus range tout : à côté de lui, ou dans le dossier du système.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum StartMode {
    /// `portable_mode = 1` — les données vivent à côté de l'application, et
    /// le tout se copie sur une clé.
    Portable,
    /// `portable_mode = 0`, ou pas de fichier du tout — les données vivent
    /// dans le dossier standard du système d'exploitation.
    Installed,
}

/// Lit le mode de démarrage dans le texte du fichier.
///
/// **Tout ce qui n'est pas un `1` franc vaut « installé »** : pas de fichier,
/// fichier vide, ligne absente, chiffre incompréhensible. Le choix va dans ce
/// sens et non dans l'autre parce qu'une application qui ne sait pas où elle
/// est doit écrire chez l'utilisateur, jamais à côté d'elle-même — sur une
/// machine qui n'est pas la sienne, écrire à côté de l'exécutable est le pire
/// des deux.
///
/// La lecture est faite à la main plutôt qu'avec une bibliothèque TOML : une
/// ligne `clef = valeur` ne justifie pas une dépendance, et ce qui est écrit
/// reste du TOML parfaitement valide.
pub fn read_start_mode(text: &str) -> StartMode {
    for line in text.lines() {
        let line = line.trim();
        if line.starts_with('#') {
            continue;
        }
        let Some((key, value)) = line.split_once('=') else {
            continue;
        };
        if key.trim() != "portable_mode" {
            continue;
        }
        // Les guillemets sont tolérés : `portable_mode = "1"` est du TOML
        // valide lui aussi, et refuser cette forme punirait quelqu'un qui a
        // écrit du TOML plus correct que le nôtre.
        let value = value.trim().trim_matches('"').trim();
        return if value == "1" {
            StartMode::Portable
        } else {
            StartMode::Installed
        };
    }
    StartMode::Installed
}

/// Le dossier qui contient l'exécutable — ou, sur macOS, celui qui contient
/// le paquet `.app`.
///
/// `exe_path` est passé explicitement plutôt que lu par `current_exe()` ici,
/// pour que tout ce calcul de chemins se teste sans toucher au disque.
///
/// La disposition macOS est `Radinus.app/Contents/MacOS/radinus` : on remonte
/// donc au-dessus de `Contents/MacOS/<binaire>` **et** au-dessus de
/// `Radinus.app` lui-même quand on reconnaît ce motif. Partout ailleurs —
/// Windows, Linux, et les compilations de développement — c'est simplement le
/// dossier parent de l'exécutable.
pub fn beside_the_application(exe_path: &Path) -> PathBuf {
    let mut dir = exe_path
        .parent()
        .map(Path::to_path_buf)
        .unwrap_or_else(|| PathBuf::from("."));

    // macOS bundle: .../Radinus.app/Contents/MacOS/radinus
    if dir.file_name().and_then(|n| n.to_str()) == Some("MacOS") {
        if let Some(contents_dir) = dir.parent() {
            if contents_dir.file_name().and_then(|n| n.to_str()) == Some("Contents") {
                if let Some(app_parent) = contents_dir.parent().and_then(Path::parent) {
                    dir = app_parent.to_path_buf();
                }
            }
        }
    }

    dir
}

/// **Le dossier standard du système où tourne Radinus.**
///
/// Un `match` sur trois systèmes, et une ligne de plus le jour où il y en aura
/// un quatrième :
///
/// | | dossier |
/// |---|---|
/// | Windows | `%APPDATA%\Radinus\` |
/// | macOS | `~/Library/Application Support/Radinus/` |
/// | Linux | `~/.local/share/radinus/` |
///
/// **Lu dans les variables d'environnement, sans bibliothèque.** Les trouver
/// autrement demanderait une dépendance de plus pour vingt lignes, et ces
/// variables sont posées par le système lui-même sur les trois plateformes.
///
/// `environment` est passé en paramètre — et non lu ici — pour que les trois
/// cas se testent sur n'importe quelle machine : un test qui n'exécuterait la
/// branche de son propre système ne vérifierait qu'un tiers du travail.
pub fn system_folder(environment: impl Fn(&str) -> Option<String>) -> Option<PathBuf> {
    if cfg!(target_os = "windows") {
        return environment("APPDATA").map(|base| PathBuf::from(base).join("Radinus"));
    }
    if cfg!(target_os = "macos") {
        return environment("HOME").map(|home| {
            PathBuf::from(home)
                .join("Library")
                .join("Application Support")
                .join("Radinus")
        });
    }
    // Linux et le reste du monde POSIX : la convention XDG, avec son défaut
    // quand la variable n'est pas posée — ce qui est le cas le plus courant.
    environment("XDG_DATA_HOME")
        .map(PathBuf::from)
        .or_else(|| environment("HOME").map(|home| PathBuf::from(home).join(".local/share")))
        .map(|base| base.join("radinus"))
}

/// **Où Radinus range tout.** Le seul endroit du logiciel qui décide de cela.
///
/// La règle, dans l'ordre (décision de Fabrice, 05/08/2026) :
///
/// 1. Chercher `settings/start_mode.toml` **à côté de l'exécutable**, et
///    nulle part ailleurs.
/// 2. S'il porte `portable_mode = 1` : la racine est le dossier de
///    l'application.
/// 3. Sinon — `0`, fichier absent, illisible ou incompréhensible : la racine
///    est le dossier standard du système.
/// 4. Et si le système ne dit pas où est ce dossier — pas de `HOME`, pas de
///    `APPDATA` —, on retombe à côté de l'application. Mieux vaut tourner là
///    que ne pas tourner du tout.
///
/// **Une seule version de Radinus existe**, installable, qui devient portable
/// quand on pose ce fichier à côté d'elle avec un `1`. Il n'y a pas deux
/// binaires à construire ni deux distributions à tenir.
pub fn data_root(exe_path: &Path) -> PathBuf {
    let beside = beside_the_application(exe_path);
    let declared = fs::read_to_string(beside.join(SETTINGS_DIR).join(START_MODE_FILE_NAME))
        .map(|text| read_start_mode(&text))
        .unwrap_or(StartMode::Installed);

    match declared {
        StartMode::Portable => beside,
        StartMode::Installed => {
            system_folder(|name| std::env::var(name).ok()).unwrap_or(beside)
        }
    }
}

/// Detects macOS "App Translocation": when a downloaded, quarantined `.app`
/// is launched without first being moved out of its original location,
/// Gatekeeper runs it from a randomized read-only path under
/// `/private/var/folders/.../AppTranslocation/...`, which would break
/// portable-root detection. See 08_ARCHITECTURE.md §3bis point 3.
pub fn is_app_translocated(exe_path: &Path) -> bool {
    exe_path
        .to_string_lossy()
        .contains("AppTranslocation")
}

/// Crée les quatre dossiers sous `root` s'ils n'y sont pas déjà, et y pose le
/// fichier de mode de démarrage. Rejouable sans dommage : rien n'est écrasé.
///
/// **Le fichier de mode n'est écrit que s'il n'existe pas.** C'est ce qui fait
/// qu'un `1` posé par l'utilisateur y reste : Radinus ne réécrit jamais ce
/// fichier, il ne fait que le créer manquant.
///
/// Écrit dans le dossier standard, il dort — Radinus ne lit que celui qui est
/// à côté de son exécutable. Il est là pour deux raisons : faire connaître
/// l'existence du mode portable à qui ouvre son dossier, et voyager avec les
/// données le jour où on les déplace à côté de l'application (voir
/// [`START_MODE_TEMPLATE`]).
pub fn ensure_tree(root: &Path) -> io::Result<()> {
    for dir in [SETTINGS_DIR, DATABASES_DIR, BACKUPS_DIR, LOGS_DIR] {
        fs::create_dir_all(root.join(dir))?;
    }
    let start_mode = root.join(SETTINGS_DIR).join(START_MODE_FILE_NAME);
    if !start_mode.exists() {
        fs::write(&start_mode, START_MODE_TEMPLATE)?;
    }
    Ok(())
}

fn config_path(root: &Path) -> PathBuf {
    root.join(SETTINGS_DIR).join(CONFIG_FILE_NAME)
}

/// Creates the next available `databases/Radinus_NNNNN/` slot (5-digit,
/// zero-padded, incremented — see 01_CAHIER_DES_CHARGES.md §3.3 bis) with its
/// `attachments/` subfolder, and returns the slot's directory. Does not
/// create the `.sqlite` file itself: the caller picks its name.
pub fn create_next_database_slot(root: &Path) -> io::Result<PathBuf> {
    let databases_dir = root.join(DATABASES_DIR);
    fs::create_dir_all(&databases_dir)?;

    let mut max_n: u32 = 0;
    for entry in fs::read_dir(&databases_dir)? {
        let entry = entry?;
        if !entry.file_type()?.is_dir() {
            continue;
        }
        if let Some(name) = entry.file_name().to_str() {
            if let Some(digits) = name.strip_prefix("Radinus_") {
                if let Ok(n) = digits.parse::<u32>() {
                    max_n = max_n.max(n);
                }
            }
        }
    }

    let slot = databases_dir.join(format!("Radinus_{:05}", max_n + 1));
    fs::create_dir_all(slot.join("attachments"))?;
    Ok(slot)
}

/// **Ce qu'un dossier de base raconte de lui-même** — `radinus_base.json`.
///
/// Décision de Fabrice du 02/08/2026, et sa portée est aussi importante que
/// son contenu : ces informations sont **indicatives**. Elles disent d'où
/// vient une base, elles ne la font pas marcher. Rien dans le logiciel ne
/// doit en dépendre, parce que ce fichier vit en dehors du SQLite et que rien
/// ne les tient ensemble : on copie un dossier sans lui, on restaure une
/// sauvegarde 1.9.3 qui ne l'a jamais eu, un disque plein le coupe en deux.
/// Quand il manque, Radinus en régénère un standard et continue — il ne
/// refuse jamais une base à cause de lui.
///
/// C'est aussi pourquoi il ne porte que **l'origine** de la base, et rien
/// qu'on aurait à tenir à jour : un fichier qu'on n'écrit qu'une fois ne peut
/// pas devenir un mensonge. Le nombre de comptes, le solde, la langue sont
/// dans la base, et c'est la base qu'on interroge pour les connaître.
#[derive(Debug, Clone, Default, Serialize, Deserialize, PartialEq, Eq)]
pub struct DatabaseInfo {
    /// Le nom que l'utilisateur donne à sa base — « Base père de famille ».
    /// Saisi à la création (décision du 02/08/2026), et lui seul distingue
    /// deux bases pour un œil humain : le nom du dossier ne dit rien.
    #[serde(default)]
    pub label: String,
    /// Ce qu'il veut en dire de plus, en clair et sans limite de longueur.
    #[serde(default)]
    pub comment: String,
    /// Le jour de la création, `AAAA-MM-JJ`. **Vide quand on ne sait pas** —
    /// c'est le cas d'un fichier régénéré, et une case vide vaut mieux qu'une
    /// date inventée.
    #[serde(default)]
    pub created_on: String,
    /// La version du logiciel qui a créé la base. Vide quand on ne sait pas.
    #[serde(default)]
    pub created_by: String,
    /// La version de schéma à la création. `0` quand on ne sait pas.
    #[serde(default)]
    pub schema_version: i64,
}

/// Une base trouvée dans `databases/`, telle que le sélecteur la montre.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct DatabaseEntry {
    /// Le nom du dossier — `Radinus_00002`, ou `MesComptes` si quelqu'un l'a
    /// renommé hors du logiciel, ce qui est permis.
    pub folder: String,
    /// Le chemin du SQLite relatif à la racine portable, tel que le fichier
    /// de configuration le stocke.
    pub relative_path: String,
    /// Ce que son `radinus_base.json` raconte — régénéré s'il manquait.
    pub info: DatabaseInfo,
}

/// Le jour d'un instant, en `AAAA-MM-JJ`.
///
/// L'instant est **passé en paramètre** et non lu ici, comme
/// `backup::writer::archive_file_name` : c'est ce qui rend la fonction
/// vérifiable sans dépendre du jour où l'on essaie.
pub fn iso_day(now: std::time::SystemTime) -> String {
    use time_compute::{Datelike, TimeZone, Utc};

    let since_epoch = now
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default();
    let day = Utc
        .timestamp_opt(since_epoch.as_secs() as i64, 0)
        .single()
        .unwrap_or_default();
    format!("{:04}-{:02}-{:02}", day.year(), day.month(), day.day())
}

fn info_path(slot: &Path) -> PathBuf {
    slot.join(DATABASE_INFO_FILE_NAME)
}

/// Lit le `radinus_base.json` d'un dossier de base. Rend `None` s'il manque
/// **ou s'il est illisible** : les deux se traitent pareil, puisque dans les
/// deux cas on n'a rien à montrer. Une virgule en trop ne doit pas empêcher
/// d'ouvrir une base saine.
pub fn read_database_info(slot: &Path) -> Option<DatabaseInfo> {
    let contents = fs::read_to_string(info_path(slot)).ok()?;
    serde_json::from_str(&contents).ok()
}

/// Écrit le `radinus_base.json` d'un dossier de base, en clair et indenté :
/// il est fait pour être lu, et corrigé à la main au besoin.
pub fn write_database_info(slot: &Path, info: &DatabaseInfo) -> io::Result<()> {
    let contents = serde_json::to_string_pretty(info)
        .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e))?;
    fs::write(info_path(slot), contents)
}

/// Le fichier standard qu'on régénère quand il manque.
///
/// Le libellé est le nom du dossier — le seul mot vrai qu'on ait sous la
/// main. Tout le reste reste vide : on ne sait pas d'où vient cette base, et
/// **c'est cela qu'il faut dire**. Une date de création tirée de la date du
/// fichier serait une date de copie, pas une date de naissance.
pub fn regenerated_info(slot: &Path) -> DatabaseInfo {
    DatabaseInfo {
        label: slot
            .file_name()
            .and_then(|name| name.to_str())
            .unwrap_or_default()
            .to_string(),
        ..DatabaseInfo::default()
    }
}

/// **Toutes les bases que `databases/` contient vraiment.**
///
/// Est une base tout dossier qui contient un `radinus.sqlite`, quel que soit
/// son nom (décision de Fabrice, 02/08/2026 : « il faut un système de pensée
/// tolérant »). L'utilisateur a le droit de renommer ses dossiers hors du
/// logiciel, d'en copier depuis une autre machine, d'en effacer ; ce qui est
/// sur le disque fait foi, et jamais la liste mémorisée dans la
/// configuration.
///
/// Un dossier sans SQLite n'est pas une base et n'apparaît pas — c'est ce qui
/// rend inoffensif l'emplacement créé puis abandonné.
///
/// Le `radinus_base.json` manquant est **régénéré au passage**, et si le
/// disque refuse l'écriture on rend quand même la base : la lister importe
/// plus que la décrire.
pub fn list_databases(root: &Path) -> io::Result<Vec<DatabaseEntry>> {
    let databases_dir = root.join(DATABASES_DIR);
    if !databases_dir.is_dir() {
        return Ok(Vec::new());
    }

    let mut found = Vec::new();
    for entry in fs::read_dir(&databases_dir)? {
        let entry = entry?;
        if !entry.file_type()?.is_dir() {
            continue;
        }
        let slot = entry.path();
        if !slot.join(DATABASE_FILE_NAME).is_file() {
            continue;
        }
        let Some(folder) = slot.file_name().and_then(|name| name.to_str()) else {
            continue;
        };

        let info = match read_database_info(&slot) {
            Some(info) => info,
            None => {
                let fresh = regenerated_info(&slot);
                let _ = write_database_info(&slot, &fresh);
                fresh
            }
        };

        found.push(DatabaseEntry {
            folder: folder.to_string(),
            relative_path: relative_to_root(root, &slot.join(DATABASE_FILE_NAME)),
            info,
        });
    }

    // Par nom de dossier : c'est l'ordre de création tant que personne n'a
    // renommé, et un ordre stable ensuite. Le sélecteur montre toujours la
    // même chose au même endroit.
    found.sort_by(|a, b| a.folder.cmp(&b.folder));
    Ok(found)
}

/// Reads `settings/radinus_config.json`, returning `SoftwareConfig::default()`
/// if it doesn't exist yet (first launch).
pub fn read_config(root: &Path) -> io::Result<SoftwareConfig> {
    let path = config_path(root);
    if !path.exists() {
        return Ok(SoftwareConfig::default());
    }
    let contents = fs::read_to_string(path)?;
    serde_json::from_str(&contents)
        .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e))
}

/// Writes `settings/radinus_config.json`, pretty-printed. `settings/` must
/// already exist (call `ensure_tree` first).
pub fn write_config(root: &Path, config: &SoftwareConfig) -> io::Result<()> {
    let path = config_path(root);
    let contents = serde_json::to_string_pretty(config)
        .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e))?;
    fs::write(path, contents)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::atomic::{AtomicU32, Ordering};

    // No "tempfile" dependency has been authorized yet (minimum-dependency
    // policy — see 08_ARCHITECTURE.md), so tests build their own scratch
    // directory under the OS temp dir and clean it up manually.
    static COUNTER: AtomicU32 = AtomicU32::new(0);

    fn scratch_dir(label: &str) -> PathBuf {
        let n = COUNTER.fetch_add(1, Ordering::SeqCst);
        let dir = std::env::temp_dir().join(format!("radinus_core_test_{label}_{n}"));
        fs::create_dir_all(&dir).unwrap();
        dir
    }

    #[test]
    fn beside_the_application_is_the_executable_parent_on_plain_layout() {
        let exe = Path::new("/some/folder/radinus");
        assert_eq!(beside_the_application(exe), Path::new("/some/folder"));
    }

    #[test]
    fn beside_the_application_walks_up_past_the_macos_bundle() {
        let exe = Path::new("/Users/fabrice/Radinus/Radinus.app/Contents/MacOS/radinus");
        assert_eq!(beside_the_application(exe), Path::new("/Users/fabrice/Radinus"));
    }

    // -----------------------------------------------------------------
    // Le mode de démarrage (Fabrice, 05/08/2026)
    // -----------------------------------------------------------------

    /// **`1` et rien d'autre fait basculer en portable.**
    #[test]
    fn seul_un_un_franc_donne_le_mode_portable() {
        assert_eq!(read_start_mode("portable_mode = 1"), StartMode::Portable);
        assert_eq!(read_start_mode("portable_mode=1"), StartMode::Portable);
        assert_eq!(read_start_mode("  portable_mode  =  1  "), StartMode::Portable);
        // Du TOML plus correct que le nôtre ne doit pas être puni.
        assert_eq!(read_start_mode("portable_mode = \"1\""), StartMode::Portable);
    }

    /// **Tout le reste vaut « installé »**, et c'est le sens voulu du doute :
    /// une application qui ne sait pas où elle est écrit chez l'utilisateur,
    /// jamais à côté d'elle-même.
    #[test]
    fn tout_le_reste_vaut_installe() {
        for texte in [
            "portable_mode = 0",
            "portable_mode = 2",
            "portable_mode = oui",
            "portable_mode =",
            "portable_mode",
            "autre_chose = 1",
            "# portable_mode = 1",
            "",
            "n'importe quoi",
        ] {
            assert_eq!(
                read_start_mode(texte),
                StartMode::Installed,
                "« {texte} » ne doit pas donner le mode portable"
            );
        }
    }

    /// Le commentaire du fichier livré ne doit pas se lire lui-même comme un
    /// réglage : ses trois lignes d'explication citent les deux valeurs.
    #[test]
    fn le_fichier_ecrit_par_radinus_se_relit_en_mode_installe() {
        assert_eq!(read_start_mode(START_MODE_TEMPLATE), StartMode::Installed);
    }

    /// **Les trois dossiers standard**, chacun vérifié sur toutes les machines
    /// et pas seulement sur celle qui exécute le test — l'environnement est
    /// passé en paramètre pour cette raison exactement.
    #[test]
    fn le_dossier_standard_est_celui_du_systeme() {
        let faux = |name: &str| match name {
            "HOME" => Some("/Users/fabrice".to_string()),
            "APPDATA" => Some(r"C:\Users\fabrice\AppData\Roaming".to_string()),
            _ => None,
        };
        let attendu = if cfg!(target_os = "windows") {
            PathBuf::from(r"C:\Users\fabrice\AppData\Roaming").join("Radinus")
        } else if cfg!(target_os = "macos") {
            PathBuf::from("/Users/fabrice/Library/Application Support/Radinus")
        } else {
            PathBuf::from("/Users/fabrice/.local/share/radinus")
        };
        assert_eq!(system_folder(faux), Some(attendu));
    }

    /// Sur les systèmes POSIX, `XDG_DATA_HOME` prime sur le défaut — c'est la
    /// convention, et quelqu'un qui l'a posée l'a posée pour être suivie.
    #[cfg(not(any(target_os = "windows", target_os = "macos")))]
    #[test]
    fn xdg_prime_sur_le_defaut() {
        let faux = |name: &str| match name {
            "HOME" => Some("/home/fabrice".to_string()),
            "XDG_DATA_HOME" => Some("/ailleurs/data".to_string()),
            _ => None,
        };
        assert_eq!(
            system_folder(faux),
            Some(PathBuf::from("/ailleurs/data/radinus"))
        );
    }

    /// **Un système muet ne fait pas tomber Radinus** : sans `HOME` ni
    /// `APPDATA`, il n'y a pas de dossier standard, et la racine retombe à
    /// côté de l'application. Tourner là vaut mieux que ne pas tourner.
    #[test]
    fn un_systeme_muet_ne_donne_aucun_dossier() {
        assert_eq!(system_folder(|_| None), None);
    }

    /// **Le geste complet, sur un vrai disque** : le fichier posé à côté de
    /// l'application avec un `1` fait ranger les données là, et son absence
    /// envoie ailleurs.
    #[test]
    fn le_fichier_pose_a_cote_decide_de_la_racine() {
        let dossier = scratch_dir("mode_portable");
        let exe = dossier.join("radinus");

        // Sans fichier : la racine n'est pas le dossier de l'application.
        assert_ne!(
            data_root(&exe),
            dossier,
            "sans fichier, Radinus doit partir dans le dossier du système"
        );

        // Avec le fichier à 1 : elle l'est.
        fs::create_dir_all(dossier.join(SETTINGS_DIR)).unwrap();
        fs::write(
            dossier.join(SETTINGS_DIR).join(START_MODE_FILE_NAME),
            "portable_mode = 1\n",
        )
        .unwrap();
        assert_eq!(data_root(&exe), dossier);

        // Repassé à 0 : elle ne l'est plus.
        fs::write(
            dossier.join(SETTINGS_DIR).join(START_MODE_FILE_NAME),
            START_MODE_TEMPLATE,
        )
        .unwrap();
        assert_ne!(data_root(&exe), dossier);

        fs::remove_dir_all(&dossier).ok();
    }

    /// **`ensure_tree` pose le fichier de mode, et ne l'écrase jamais.**
    ///
    /// C'est ce qui fait qu'un `1` posé par l'utilisateur y reste : Radinus
    /// crée ce fichier manquant, il ne le réécrit pas.
    #[test]
    fn l_arborescence_pose_le_fichier_de_mode_sans_jamais_l_ecraser() {
        let dossier = scratch_dir("arborescence");
        ensure_tree(&dossier).unwrap();

        let fichier = dossier.join(SETTINGS_DIR).join(START_MODE_FILE_NAME);
        assert!(fichier.is_file());
        assert_eq!(
            read_start_mode(&fs::read_to_string(&fichier).unwrap()),
            StartMode::Installed
        );
        for dir in [SETTINGS_DIR, DATABASES_DIR, BACKUPS_DIR, LOGS_DIR] {
            assert!(dossier.join(dir).is_dir(), "{dir} manque");
        }

        // L'utilisateur bascule en portable, puis Radinus redémarre.
        fs::write(&fichier, "portable_mode = 1\n").unwrap();
        ensure_tree(&dossier).unwrap();
        assert_eq!(
            read_start_mode(&fs::read_to_string(&fichier).unwrap()),
            StartMode::Portable,
            "son choix a été écrasé au démarrage suivant"
        );

        fs::remove_dir_all(&dossier).ok();
    }

    #[test]
    fn detects_app_translocation() {
        let translocated = Path::new(
            "/private/var/folders/xy/abc123/T/AppTranslocation/AAAA-BBBB/d/Radinus.app/Contents/MacOS/radinus",
        );
        assert!(is_app_translocated(translocated));

        let normal = Path::new("/Users/fabrice/Radinus/Radinus.app/Contents/MacOS/radinus");
        assert!(!is_app_translocated(normal));
    }

    #[test]
    fn ensure_tree_creates_all_four_folders() {
        let root = scratch_dir("tree");
        ensure_tree(&root).unwrap();
        for dir in [SETTINGS_DIR, DATABASES_DIR, BACKUPS_DIR, LOGS_DIR] {
            assert!(root.join(dir).is_dir(), "missing {dir}");
        }
        fs::remove_dir_all(&root).ok();
    }

    #[test]
    fn ensure_tree_is_idempotent() {
        let root = scratch_dir("tree_idempotent");
        ensure_tree(&root).unwrap();
        ensure_tree(&root).unwrap(); // must not fail the second time
        fs::remove_dir_all(&root).ok();
    }

    #[test]
    fn read_config_defaults_when_absent() {
        let root = scratch_dir("config_default");
        let config = read_config(&root).unwrap();
        assert_eq!(config, SoftwareConfig::default());
        fs::remove_dir_all(&root).ok();
    }

    #[test]
    fn write_then_read_config_round_trips() {
        let root = scratch_dir("config_roundtrip");
        ensure_tree(&root).unwrap();

        let config = SoftwareConfig {
            default_database: Some("databases/Radinus_00001/radinus.sqlite".to_string()),
            recent_databases: vec!["databases/Radinus_00001/radinus.sqlite".to_string()],
            language: Some("fr".to_string()),
            // Écrit en toutes lettres et non par `..default()` : **ce test
            // vérifie qu'un aller-retour ne perd aucun champ**, et un champ
            // rempli par défaut serait le seul qu'il ne vérifierait pas.
            zoom: Some(1.2),
            qif_date_order: Some("day-month".to_string()),
            qif_label: Some("memo".to_string()),
            ofx_label: Some("memo".to_string()),
            ofx_reference: Some("name-and-memo".to_string()),
            ofx_memo_in_label: Some(true),
            ofx_memo_in_reference: Some(false),
        };
        write_config(&root, &config).unwrap();

        let read_back = read_config(&root).unwrap();
        assert_eq!(read_back, config);
        fs::remove_dir_all(&root).ok();
    }

    #[test]
    fn remembering_a_database_puts_it_first_without_duplicating_it() {
        let mut config = SoftwareConfig::default();
        config.remember_recent_database("databases/Radinus_00001/radinus.sqlite");
        config.remember_recent_database("databases/Radinus_00002/famille.sqlite");
        // Re-opening the first one moves it back to the front, it is not added twice.
        config.remember_recent_database("databases/Radinus_00001/radinus.sqlite");

        assert_eq!(
            config.recent_databases,
            vec![
                "databases/Radinus_00001/radinus.sqlite".to_string(),
                "databases/Radinus_00002/famille.sqlite".to_string(),
            ]
        );
    }

    #[test]
    fn recent_databases_are_capped() {
        let mut config = SoftwareConfig::default();
        for n in 1..=(MAX_RECENT_DATABASES + 5) {
            config.remember_recent_database(&format!("databases/Radinus_{n:05}/radinus.sqlite"));
        }
        assert_eq!(config.recent_databases.len(), MAX_RECENT_DATABASES);
        // Most recent first, oldest dropped.
        assert_eq!(
            config.recent_databases[0],
            format!("databases/Radinus_{:05}/radinus.sqlite", MAX_RECENT_DATABASES + 5)
        );
        assert!(!config
            .recent_databases
            .contains(&"databases/Radinus_00001/radinus.sqlite".to_string()));
    }

    #[test]
    fn setting_the_default_database_also_records_it_as_recent() {
        let mut config = SoftwareConfig::default();
        config.set_default_database("databases/Radinus_00002/famille.sqlite");

        assert_eq!(
            config.default_database.as_deref(),
            Some("databases/Radinus_00002/famille.sqlite")
        );
        assert_eq!(
            config.recent_databases,
            vec!["databases/Radinus_00002/famille.sqlite".to_string()]
        );
    }

    #[test]
    fn the_default_database_survives_a_config_round_trip() {
        let root = scratch_dir("default_db_roundtrip");
        ensure_tree(&root).unwrap();

        let mut config = SoftwareConfig::default();
        config.set_default_database("databases/Radinus_00002/famille.sqlite");
        config.remember_recent_database("databases/Radinus_00001/radinus.sqlite");
        write_config(&root, &config).unwrap();

        // What the next launch would read to decide which database to open.
        let reloaded = read_config(&root).unwrap();
        assert_eq!(
            reloaded.default_database.as_deref(),
            Some("databases/Radinus_00002/famille.sqlite")
        );
        assert_eq!(reloaded.recent_databases.len(), 2);
        fs::remove_dir_all(&root).ok();
    }

    #[test]
    fn relative_to_root_uses_forward_slashes_from_the_root() {
        let root = Path::new("/Users/fabrice/Radinus");
        let db = root.join("databases/Radinus_00001/radinus.sqlite");
        assert_eq!(
            relative_to_root(root, &db),
            "databases/Radinus_00001/radinus.sqlite"
        );
    }

    #[test]
    fn first_database_slot_is_radinus_00001() {
        let root = scratch_dir("first_slot");
        let slot = create_next_database_slot(&root).unwrap();
        assert_eq!(slot.file_name().unwrap(), "Radinus_00001");
        assert!(slot.join("attachments").is_dir());
        fs::remove_dir_all(&root).ok();
    }

    #[test]
    fn database_slots_increment_past_existing_ones() {
        let root = scratch_dir("increment_slot");
        create_next_database_slot(&root).unwrap(); // Radinus_00001
        create_next_database_slot(&root).unwrap(); // Radinus_00002
        let third = create_next_database_slot(&root).unwrap();
        assert_eq!(third.file_name().unwrap(), "Radinus_00003");
        fs::remove_dir_all(&root).ok();
    }

    // ---------------------------------------------------------------
    // Le sélecteur de base (02/08/2026)
    // ---------------------------------------------------------------

    /// Fabrique un dossier de base : le dossier, et son SQLite — vide, car
    /// rien ici ne l'ouvre. Ce qui compte est qu'il soit là.
    fn a_database(root: &Path, folder: &str) -> PathBuf {
        let slot = root.join(DATABASES_DIR).join(folder);
        fs::create_dir_all(&slot).unwrap();
        fs::write(slot.join(DATABASE_FILE_NAME), b"").unwrap();
        slot
    }

    #[test]
    fn une_base_est_un_dossier_qui_contient_un_sqlite() {
        let root = scratch_dir("liste_bases");
        a_database(&root, "Radinus_00001");
        // Un emplacement créé puis abandonné : pas de SQLite, pas de base.
        fs::create_dir_all(root.join(DATABASES_DIR).join("Radinus_00002")).unwrap();

        let found = list_databases(&root).unwrap();
        assert_eq!(found.len(), 1);
        assert_eq!(found[0].folder, "Radinus_00001");
        assert_eq!(
            found[0].relative_path,
            "databases/Radinus_00001/radinus.sqlite"
        );
        fs::remove_dir_all(&root).ok();
    }

    /// **La règle tolérante de Fabrice.** Il a le droit de renommer ses
    /// dossiers hors du logiciel ; le sélecteur doit continuer de les voir.
    #[test]
    fn un_dossier_renomme_reste_une_base() {
        let root = scratch_dir("dossier_renomme");
        a_database(&root, "MesComptes");

        let found = list_databases(&root).unwrap();
        assert_eq!(found.len(), 1);
        assert_eq!(found[0].folder, "MesComptes");
        assert_eq!(found[0].info.label, "MesComptes");
        fs::remove_dir_all(&root).ok();
    }

    /// Et l'autre moitié de la même règle : un nom hors norme ne perturbe pas
    /// la numérotation. Le dernier `Radinus_NNNNN` fait foi, les autres noms
    /// ne comptent pas.
    #[test]
    fn la_numerotation_ignore_les_dossiers_qui_ne_portent_pas_de_numero() {
        let root = scratch_dir("numerotation_tolerante");
        a_database(&root, "Radinus_00010");
        a_database(&root, "MesComptes");

        let slot = create_next_database_slot(&root).unwrap();
        assert_eq!(slot.file_name().unwrap(), "Radinus_00011");
        fs::remove_dir_all(&root).ok();
    }

    #[test]
    fn le_fichier_dinformation_manquant_est_regenere_et_ecrit() {
        let root = scratch_dir("info_regeneree");
        let slot = a_database(&root, "Radinus_00003");
        assert!(!slot.join(DATABASE_INFO_FILE_NAME).exists());

        let found = list_databases(&root).unwrap();
        assert_eq!(found[0].info.label, "Radinus_00003");
        assert_eq!(found[0].info.comment, "");
        assert_eq!(found[0].info.created_on, "");
        assert_eq!(found[0].info.schema_version, 0);
        // Régénéré veut dire écrit : le lancement suivant le relit tel quel.
        assert!(slot.join(DATABASE_INFO_FILE_NAME).is_file());
        assert_eq!(
            read_database_info(&slot).unwrap().label,
            "Radinus_00003"
        );
        fs::remove_dir_all(&root).ok();
    }

    /// Un fichier coupé en deux par un disque plein, ou corrigé à la main
    /// avec une virgule en trop, se traite comme un fichier absent : la base
    /// est saine, et c'est elle qui compte.
    #[test]
    fn un_fichier_dinformation_illisible_se_traite_comme_absent() {
        let root = scratch_dir("info_illisible");
        let slot = a_database(&root, "Radinus_00004");
        fs::write(slot.join(DATABASE_INFO_FILE_NAME), b"{ \"label\": ").unwrap();

        let found = list_databases(&root).unwrap();
        assert_eq!(found.len(), 1);
        assert_eq!(found[0].info.label, "Radinus_00004");
        fs::remove_dir_all(&root).ok();
    }

    #[test]
    fn le_libelle_et_le_commentaire_font_l_aller_retour() {
        let root = scratch_dir("info_aller_retour");
        let slot = a_database(&root, "Radinus_00005");
        let written = DatabaseInfo {
            label: "Base père de famille".to_string(),
            comment: "Comptes courants et livrets\nà ne pas mélanger avec l'association".to_string(),
            created_on: "2026-08-02".to_string(),
            created_by: "0.1.0".to_string(),
            schema_version: 10,
        };
        write_database_info(&slot, &written).unwrap();

        assert_eq!(read_database_info(&slot).unwrap(), written);
        // Et le sélecteur ne régénère rien par-dessus.
        let found = list_databases(&root).unwrap();
        assert_eq!(found[0].info, written);
        fs::remove_dir_all(&root).ok();
    }

    #[test]
    fn les_bases_sont_rendues_dans_un_ordre_stable() {
        let root = scratch_dir("ordre_bases");
        a_database(&root, "Radinus_00002");
        a_database(&root, "MesComptes");
        a_database(&root, "Radinus_00001");

        let names: Vec<String> = list_databases(&root)
            .unwrap()
            .into_iter()
            .map(|entry| entry.folder)
            .collect();
        assert_eq!(names, ["MesComptes", "Radinus_00001", "Radinus_00002"]);
        fs::remove_dir_all(&root).ok();
    }

    /// L'exécutable nu, sans rien à côté : `databases/` n'existe pas encore
    /// et lister n'est pas une erreur — c'est une liste vide, et le sélecteur
    /// n'offre que « créer ».
    #[test]
    fn lister_sans_dossier_databases_rend_une_liste_vide() {
        let root = scratch_dir("aucune_base");
        assert!(list_databases(&root).unwrap().is_empty());
        fs::remove_dir_all(&root).ok();
    }

    #[test]
    fn le_jour_dun_instant_secrit_en_iso() {
        assert_eq!(iso_day(std::time::UNIX_EPOCH), "1970-01-01");
        assert_eq!(
            iso_day(std::time::UNIX_EPOCH + std::time::Duration::from_secs(1_785_691_200)),
            "2026-08-02"
        );
    }

    /// Une configuration neuve affiche à 100 %.
    #[test]
    fn a_fresh_config_shows_at_full_size() {
        assert_eq!(SoftwareConfig::default().zoom_factor(), 1.0);
    }

    /// **Une valeur hors bornes est ramenée, pas refusée** : on impose, on ne
    /// rejette pas — la règle du sélecteur d'année. Une préférence d'affichage
    /// ne doit jamais empêcher une fenêtre de s'ouvrir.
    #[test]
    fn the_zoom_stays_within_its_bounds() {
        for (written, expected) in [(0.7, 0.7), (1.5, 1.5), (1.2, 1.2), (9.0, 1.5), (0.1, 0.7)] {
            let config = SoftwareConfig {
                zoom: Some(written),
                ..SoftwareConfig::default()
            };
            assert!((config.zoom_factor() - expected).abs() < 1e-9, "{written}");
        }
    }

    /// **`NaN` est le seul nombre qui glisse entre les comparaisons** : il
    /// n'est ni plus grand ni plus petit qu'une borne, donc `clamp` ne le
    /// rattrape pas. Un zoom `NaN` rendrait une fenêtre vide.
    #[test]
    fn a_zoom_that_is_not_a_number_is_worth_full_size() {
        assert_eq!(clamp_zoom(f64::NAN), 1.0);
        assert_eq!(clamp_zoom(f64::INFINITY), 1.5);
        assert_eq!(clamp_zoom(f64::NEG_INFINITY), 0.7);
    }

    /// **La taille de l'affichage se relit d'un lancement à l'autre**, comme la
    /// langue : c'est tout l'objet du déplacement du 04/08/2026.
    #[test]
    fn the_zoom_survives_a_round_trip_through_the_config_file() {
        let root = scratch_dir("zoom_aller_retour");
        ensure_tree(&root).unwrap();
        let config = SoftwareConfig {
            zoom: Some(1.3),
            ..SoftwareConfig::default()
        };
        write_config(&root, &config).unwrap();
        assert_eq!(read_config(&root).unwrap().zoom_factor(), 1.3);
    }

    /// **Les réglages QIF** (15/10/2026) : gardés d'un lancement à l'autre ;
    /// absents d'une configuration plus ancienne, ou illisibles, ils valent
    /// « me demander » et « tiers + mémo » — jamais une date devinée.
    #[test]
    fn the_qif_settings_survive_and_default_to_the_safest() {
        use crate::qif_import::{DateOrder, LabelChoice};
        let root = scratch_dir("qif_aller_retour");
        ensure_tree(&root).unwrap();
        let config = SoftwareConfig {
            qif_date_order: Some("month-day".into()),
            qif_label: Some("payee".into()),
            ..SoftwareConfig::default()
        };
        write_config(&root, &config).unwrap();
        let back = read_config(&root).unwrap();
        assert_eq!(back.qif_order_choice(), Some(DateOrder::MonthDay));
        assert_eq!(back.qif_label_choice(), LabelChoice::Payee);

        let older: SoftwareConfig = serde_json::from_str(r#"{"language":"fr","zoom":1.0}"#).unwrap();
        assert_eq!((older.qif_order_choice(), older.qif_label_choice()), (None, LabelChoice::Both));
        let edited: SoftwareConfig =
            serde_json::from_str(r#"{"qif_date_order":"jour-mois","qif_label":"???"}"#).unwrap();
        assert_eq!((edited.qif_order_choice(), edited.qif_label_choice()), (None, LabelChoice::Both));
    }

    /// **Les réglages OFX** (les deux menus, 20/10/2026) : gardés d'un
    /// lancement à l'autre ; absents d'une configuration plus ancienne, ils
    /// valent le défaut de Fabrice — le nom dans le libellé, le mémo dans la
    /// référence ; les deux cases de la veille sont traduites, puis oubliées.
    #[test]
    fn the_ofx_settings_survive_and_default_to_the_reference() {
        use crate::ofx_import::{LabelSource, MemoOptions, ReferenceSource};
        let root = scratch_dir("ofx_aller_retour");
        ensure_tree(&root).unwrap();

        // Les deux cases de la veille : traduites dans les menus.
        let cases = SoftwareConfig {
            ofx_memo_in_label: Some(true),
            ofx_memo_in_reference: Some(false),
            ..SoftwareConfig::default()
        };
        assert_eq!(
            cases.ofx_memo_options(),
            MemoOptions { label: LabelSource::NameAndMemo, reference: ReferenceSource::Empty }
        );

        // Les menus enregistrés passent devant, et les cases s'effacent.
        let mut config = cases;
        let chosen = MemoOptions { label: LabelSource::Memo, reference: ReferenceSource::Name };
        config.set_ofx_memo_options(chosen);
        write_config(&root, &config).unwrap();
        let back = read_config(&root).unwrap();
        assert_eq!(back.ofx_memo_options(), chosen);
        assert_eq!((back.ofx_memo_in_label, back.ofx_memo_in_reference), (None, None));

        // Rien de réglé, ou un mot inconnu : le défaut.
        let older: SoftwareConfig = serde_json::from_str(r#"{"language":"fr","zoom":1.0}"#).unwrap();
        assert_eq!(older.ofx_memo_options(), MemoOptions::default());
        let edited: SoftwareConfig =
            serde_json::from_str(r#"{"ofx_label":"???","ofx_reference":"rien"}"#).unwrap();
        assert_eq!(edited.ofx_memo_options(), MemoOptions::default());
        fs::remove_dir_all(&root).ok();
    }
}
