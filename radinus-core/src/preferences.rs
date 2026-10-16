//! La table `Preferences` — et **rien d'autre que ce qui a été demandé**.
//!
//! Elle est dans le schéma depuis la 1.x sans que rien ne la lise :
//! `IDPreferences`, `Cle` unique, `ValeurJSON`. Elle sert enfin, ce qui vaut
//! au passage de ne toucher ni au schéma ni à `VerDataBase`.
//!
//! **Règle de Fabrice, 03/08/2026, et elle est absolue** : rien n'entre dans
//! cette table qu'il n'ait demandé d'y mettre, clef par clef. Pas de largeur
//! de colonne mémorisée au passage, pas de dernier dossier ouvert, pas de
//! confort ajouté parce qu'il tombait sous la main. Un magasin clef/valeur
//! libre est précisément l'endroit où un logiciel accumule en silence jusqu'à
//! ce que personne ne sache plus ce qu'il y a dedans ni qui l'a écrit.
//!
//! **Les clefs qui existent** : `devise` ; `verification_import` (03/10/2026) ;
//! une clef `tableau.<nom>` par tableau dont l'utilisateur règle les colonnes
//! (04/10/2026) ; et `accueil.comptes`, l'ordre des comptes de l'accueil et
//! ceux qu'on y laisse hors des totaux (07/10/2026). Pour en ajouter une, il faut son accord, et elle
//! s'ajoute ici avec son type.
//!
//! La largeur de colonne citée plus haut comme l'exemple de ce qui ne
//! s'ajoute pas « au passage » est précisément entrée ce jour-là — mais
//! demandée, en toutes lettres : « on doit aussi mémoriser la largeur des
//! colonnes ». La règle n'a pas changé, c'est la demande qui est venue.

use rusqlite::{Connection, OptionalExtension, Result};

/// La clef de la devise. Écrite en toutes lettres et une seule fois : une
/// chaîne recopiée à deux endroits finit toujours par diverger.
pub const CURRENCY_KEY: &str = "devise";

// **Le zoom n'est plus une préférence de la base** (Fabrice, 04/08/2026) : il
// est passé dans `settings/radinus_config.json`, à côté de la langue, parce
// qu'il dit quelque chose de l'écran et non des comptes. Ses bornes, sa remise
// dans les bornes et sa lecture sont dans `location`.
//
// **La ligne `zoom` des bases déjà écrites n'est ni lue ni effacée** : elle ne
// gêne personne, et une migration qui touche à des données pour n'en rien
// tirer est une occasion de casser quelque chose pour rien.
//
// Ce paragraphe ne documente plus rien — la constante qu'il accompagnait est
// partie avec le zoom —, d'où le `//` et non le `///` : un commentaire de
// documentation orphelin va se coller à la déclaration suivante, qui ne parle
// pas du tout de la même chose.

/// Ce que l'utilisateur a choisi dans la fenêtre des préférences.
///
/// **Le nom des variantes n'est pas cosmétique** : il part tel quel dans le
/// JSON de la base, et une base écrite aujourd'hui doit se relire dans dix
/// ans. Les renommer casserait les bases existantes.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Currency {
    /// Celle du système d'exploitation, relue à chaque affichage.
    System,
    Euro,
    Dollar,
    /// Le dollar canadien.
    ///
    /// **Son signe est le même `$` que l'américain** — c'est la même glyphe, et
    /// au Canada on écrit « 1 549,81 $ » sans plus. Les formes `C$` et `CA$` ne
    /// servent qu'à distinguer les deux quand ils paraissent ensemble, ce qui
    /// n'arrive jamais ici : Radinus n'affiche qu'une devise.
    ///
    /// L'entrée existe donc pour une raison qui n'est pas le signe : **qu'un
    /// canadien se reconnaisse dans la liste**, comme chaque langue y est
    /// écrite dans la sienne. Fabrice en a, et il l'a demandée le 03/08/2026.
    CanadianDollar,
    /// Le franc CFA.
    Cfa,
    /// Le franc Pacifique, ou franc CFP (ISO `XPF`), émis par l'IEOM et arrimé
    /// à l'euro. Il a cours en Nouvelle-Calédonie, en Polynésie française et à
    /// Wallis-et-Futuna. Il s'écrit `F`, `FCFP` ou `F CFP` ; on retient
    /// **`FCFP`**, sans ambiguïté et en parallèle du `FCFA`.
    CfpFranc,
    /// Le franc suisse.
    ///
    /// Son signe est **`CHF`**, le code ISO lui-même : c'est ainsi qu'on écrit
    /// les montants en Suisse, et c'est ce que tout le monde reconnaît. Les
    /// formes `Fr.` et `SFr.` existent, mais leur point est justement un des
    /// caractères qu'un signe n'a pas le droit de porter — `money::parse`
    /// l'ôterait en lisant une saisie.
    SwissFranc,
    /// **Aucune devise affichée** : les montants sortent nus.
    ///
    /// Ce n'est pas « pas encore réglé », c'est un choix, et il se mémorise
    /// comme les autres — sans quoi il retomberait sur l'euro au démarrage
    /// suivant. Demandé par Fabrice le 03/08/2026.
    NoSign,
    /// Le signe tapé à la main.
    Custom(String),
}

impl Default for Currency {
    /// **Une base neuve suit le système.** C'est ce que Fabrice a demandé, et
    /// c'est aussi ce qui évite d'imposer l'euro à quelqu'un qui n'en a jamais
    /// vu.
    fn default() -> Self {
        Currency::System
    }
}

impl Currency {
    /// Le nom du choix, tel qu'il s'écrit en base.
    pub fn key(&self) -> &'static str {
        match self {
            Currency::System => "systeme",
            Currency::Euro => "EUR",
            Currency::Dollar => "USD",
            Currency::CanadianDollar => "CAD",
            Currency::NoSign => "aucune",
            Currency::Cfa => "XOF",
            Currency::CfpFranc => "XPF",
            Currency::SwissFranc => "CHF",
            Currency::Custom(_) => "perso",
        }
    }

    /// Le signe personnalisé, vide pour les autres choix.
    pub fn custom_sign(&self) -> &str {
        match self {
            Currency::Custom(sign) => sign,
            _ => "",
        }
    }

    /// Le choix relu depuis ce que porte la base.
    ///
    /// **Un choix inconnu retombe sur le système** plutôt que d'échouer : une
    /// base écrite par une version future, ou un JSON abîmé à la main, ne doit
    /// pas empêcher Radinus d'afficher un montant.
    pub fn from_parts(choice: &str, sign: &str) -> Self {
        match choice {
            "EUR" => Currency::Euro,
            "USD" => Currency::Dollar,
            "CAD" => Currency::CanadianDollar,
            "aucune" => Currency::NoSign,
            "XOF" => Currency::Cfa,
            "XPF" => Currency::CfpFranc,
            "CHF" => Currency::SwissFranc,
            "perso" => Currency::Custom(clamp_sign(sign)),
            _ => Currency::System,
        }
    }

    /// Le signe à écrire, `system` étant ce que la machine a répondu.
    ///
    /// Le noyau ne parle pas au système d'exploitation (08_ARCHITECTURE.md
    /// §2.1) : c'est le contrôleur qui lui tend cette réponse, et un système
    /// muet vaut l'euro.
    pub fn sign(&self, system: &str) -> String {
        match self {
            Currency::System if sign_is_usable(system) => clamp_sign(system),
            Currency::System => "€".to_string(),
            Currency::NoSign => String::new(),
            Currency::Euro => "€".to_string(),
            Currency::Dollar | Currency::CanadianDollar => "$".to_string(),
            Currency::Cfa => "FCFA".to_string(),
            Currency::CfpFranc => "FCFP".to_string(),
            Currency::SwissFranc => "CHF".to_string(),
            // **La seconde barrière.** La fenêtre refuse déjà à la frappe et le
            // contrôleur refuse d'enregistrer ; celle-ci protège de ce qu'aucun
            // des deux ne voit — un `ValeurJSON` modifié à la main dans la base,
            // ou écrit par une version future. Un signe inutilisable ne devient
            // jamais le signe en vigueur : il vaut l'euro.
            Currency::Custom(sign) if sign_is_usable(sign) => clamp_sign(sign),
            Currency::Custom(_) => "€".to_string(),
        }
    }
}

/// Huit caractères au plus, et **huit caractères, pas huit octets** : « € »
/// en pèse trois, et couper au milieu rendrait un texte invalide.
fn clamp_sign(sign: &str) -> String {
    sign.trim().chars().take(8).collect()
}

/// Longueur maximale d'un signe, en caractères.
pub const SIGN_MAX: usize = 8;

/// **Ce qu'un signe de devise n'a pas le droit de contenir**, et ce n'est pas
/// une question de goût.
///
/// Le signe n'est pas seulement écrit à côté des montants : `money::parse`
/// **l'ôte** avant de lire une saisie, pour qu'on puisse recopier
/// « 1 549,81 $ » depuis sa propre fenêtre. Un signe qui ressemble à un
/// morceau de nombre corrompt donc les saisies, en silence :
///
/// - signe `0` : l'utilisateur tape `120`, le zéro final est ôté, **12** est
///   enregistré ;
/// - signe `-` : il tape `-12`, le moins est ôté, et le débit devient un
///   **crédit**.
///
/// Des chiffres justes, faux, sans un mot. D'où l'interdiction de tout ce qui
/// peut appartenir à un nombre, **où que ce soit dans le signe** — et non du
/// seul chiffre isolé. Ce qui reste suffit à toutes les devises du monde :
/// lettres et symboles, `€ $ £ ¥ CHF kr zł Kč FCFA`.
fn forbidden_in_sign(c: char) -> bool {
    c.is_ascii_digit()
        // Les chiffres des autres écritures comptent autant : « ٠ » est un
        // zéro arabe, et `parse` ne le lit pas mieux qu'un autre.
        || c.is_numeric()
        || matches!(c, '-' | '+' | ',' | '.' | '(' | ')')
}

/// Un signe utilisable, ou non.
pub fn sign_is_usable(sign: &str) -> bool {
    let trimmed = sign.trim();
    !trimmed.is_empty()
        && trimmed.chars().count() <= SIGN_MAX
        && !trimmed.chars().any(forbidden_in_sign)
}

/// Pourquoi ce signe est refusé, dans la langue du logiciel — ou rien s'il
/// convient.
pub fn sign_refusal(sign: &str, language: crate::i18n::Language) -> Option<String> {
    let trimmed = sign.trim();
    if trimmed.is_empty() {
        return Some(crate::i18n::text(language, "preferences-custom-required"));
    }
    if trimmed.chars().count() > SIGN_MAX {
        return Some(crate::i18n::text(language, "preferences-sign-too-long"));
    }
    if trimmed.chars().any(forbidden_in_sign) {
        return Some(crate::i18n::text(language, "preferences-sign-not-a-number"));
    }
    None
}

/// La clef de la vérification donnée aux opérations importées.
pub const IMPORT_VERIFICATION_KEY: &str = "verification_import";

/// **Ce que vaut « Vérification » sur une opération qui vient d'un import**
/// (Fabrice, 03/10/2026) — relevé OFX, relevé CSV, tableau Excel.
///
/// Deux réponses possibles, et pas quatre : `2`, « Vérifiée », pour qui fait
/// confiance à sa banque — c'est le défaut, et rien ne change pour lui ; `1`,
/// « À vérifier », pour qui garde ses tickets et veut valider chaque ligne
/// lui-même. « Douteuse » et « Contestée » sont des jugements, et un import
/// n'en porte pas.
///
/// Une clef absente, illisible ou hors de ces deux valeurs rend le défaut.
pub fn import_verification(conn: &Connection) -> Result<i64> {
    let stored = read(conn, IMPORT_VERIFICATION_KEY)?;
    Ok(match stored.as_deref().map(str::trim) {
        Some("1") => crate::operations::TO_VERIFY,
        _ => crate::operations::VERIFIED,
    })
}

/// Enregistre ce choix. Toute autre valeur que « à vérifier » écrit le défaut.
pub fn set_import_verification(conn: &Connection, verification_id: i64) -> Result<()> {
    let value = if verification_id == crate::operations::TO_VERIFY {
        crate::operations::TO_VERIFY
    } else {
        crate::operations::VERIFIED
    };
    write(conn, IMPORT_VERIFICATION_KEY, &value.to_string())
}

/// **Les tableaux dont l'utilisateur règle les colonnes**, par leur nom.
///
/// Fabrice, 04/10/2026 : « il faudrait dans la base une préférence par
/// tableau » — et il a prévenu qu'il en demanderait d'autres. La liste des
/// opérations d'un compte d'abord ; puis, le même jour, le détail du bas des
/// sept statistiques — « une disposition par statistique », donc sept noms,
/// `statistics-<axe>` — et celui du bilan croisé. En ajouter un, c'est ajouter
/// son nom ici.
///
/// La liste est fermée, et c'est ce qui tient la règle de ce module : un nom
/// qui n'y figure pas n'écrit rien, donc aucune fenêtre ne peut se servir de
/// la table comme d'un fourre-tout en inventant le sien.
pub const TABLES_WITH_A_LAYOUT: &[&str] = &[
    "operations-list",
    "statistics-category",
    "statistics-assignment",
    "statistics-budget-line",
    "statistics-payment-mode",
    "statistics-payee",
    "statistics-project",
    "statistics-verification",
    "crossed-balance",
    "balance-analysis",
    // Le tableau d'amortissement de la simulation de crédit (08/10/2026).
    "loan-simulation",
];

/// Ce qui sépare, dans le nom d'un tableau, la fenêtre du tableau lui-même.
const WINDOW_SEPARATOR: char = '.';

/// **La fenêtre qui porte un tableau.**
///
/// Fabrice, 04/10/2026, en corrigeant la feuille des préférences : « il s'agit
/// du nom de la fenêtre, on réinitialise les tableaux contenus dans une
/// fenêtre. Demain il peut y en avoir plusieurs dans une fenêtre. » Les
/// préférences listent donc des fenêtres, et non des tableaux.
///
/// Aujourd'hui chaque fenêtre n'a qu'un tableau réglable, et il porte le nom
/// de sa fenêtre. Le jour où une fenêtre en aura deux, ils s'appelleront
/// `<fenêtre>.<tableau>` : rien d'autre n'est à écrire, ni ici ni dans les
/// préférences, et les dispositions déjà enregistrées gardent leur clef.
pub fn window_of(table: &str) -> &str {
    table.split(WINDOW_SEPARATOR).next().unwrap_or(table)
}

/// **Les fenêtres qui portent au moins un tableau réglable**, chacune une
/// fois, dans l'ordre de la liste.
pub fn windows_with_layouts() -> Vec<&'static str> {
    let mut windows: Vec<&'static str> = Vec::new();
    for table in TABLES_WITH_A_LAYOUT {
        let window = window_of(table);
        if !windows.contains(&window) {
            windows.push(window);
        }
    }
    windows
}

/// Les tableaux réglables d'une fenêtre. Vide pour une fenêtre inconnue.
pub fn tables_of_window(window: &str) -> Vec<&'static str> {
    TABLES_WITH_A_LAYOUT
        .iter()
        .copied()
        .filter(|table| window_of(table) == window)
        .collect()
}

/// **Rend leur disposition de naissance aux tableaux d'une fenêtre** — le
/// bouton « Réinitialiser » des préférences. Rend les tableaux concernés, pour
/// que le contrôleur prévienne les fenêtres ouvertes.
pub fn reset_window_layouts(conn: &Connection, window: &str) -> Result<Vec<&'static str>> {
    let tables = tables_of_window(window);
    for table in &tables {
        reset_table_layout(conn, table)?;
    }
    Ok(tables)
}

/// Le nom du tableau de détail d'une statistique : `statistics-<axe>`.
pub const STATISTICS_LAYOUT_PREFIX: &str = "statistics-";

/// Ce qu'une disposition a le droit de peser. Seize colonnes en demandent
/// quelques centaines d'octets ; au-delà, ce n'est plus une disposition.
const LAYOUT_COLUMNS_MAX: usize = 64;
const LAYOUT_WIDTH_MIN: u32 = 20;
const LAYOUT_WIDTH_MAX: u32 = 4000;

/// **La disposition d'un tableau** : l'ordre de ses colonnes, celles qui sont
/// masquées, et les largeurs que l'utilisateur a tirées, en pixels.
///
/// Les colonnes sont repérées par un **nom** que la fenêtre leur donne, et non
/// par leur rang : un rang ne survit pas à la colonne qu'une version suivante
/// glisse au milieu. Le noyau ne sait pas quelles colonnes un tableau porte —
/// c'est l'affaire de la fenêtre, qui écarte ce qu'elle ne reconnaît pas. Il
/// sait en revanche ce qu'une disposition ne peut pas être : un nom répété,
/// une largeur absurde, cent colonnes.
#[derive(Debug, Clone, Default, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
#[serde(deny_unknown_fields)]
pub struct TableLayout {
    /// Les colonnes, dans l'ordre où on les lit. Les masquées y gardent leur
    /// place : réaffichée, une colonne revient où elle était.
    pub order: Vec<String>,
    /// Celles qu'on ne montre pas.
    pub hidden: Vec<String>,
    /// Les largeurs tirées à la main. Une colonne absente d'ici garde celle
    /// avec laquelle elle est née.
    pub widths: std::collections::BTreeMap<String, u32>,
    /// **Les colonnes teintées**, chacune sous le nom de sa couleur (Fabrice,
    /// 05/10/2026 : « colorer certaines colonnes pour qu'il y ait comme un
    /// calque transparent de couleur qui s'applique dessus »). Une colonne
    /// absente d'ici n'a pas de couleur.
    ///
    /// Le champ est né après les trois autres : une disposition enregistrée
    /// avant lui ne le porte pas, et se lit comme si aucune colonne n'était
    /// teintée — sans quoi la première ouverture après la mise à jour aurait
    /// rejeté, puis effacé, le réglage de l'utilisateur.
    #[serde(default)]
    pub colors: std::collections::BTreeMap<String, String>,
}

/// **Les neuf couleurs dont une colonne peut se teinter**, par leur nom.
/// « Rouge, orange, rose, vert pastel, vert, bleu pastel, bleu, jaune pastel,
/// jaune » — la liste de Fabrice, dans son ordre, et elle est fermée : la base
/// retient un nom, jamais un code de couleur. La teinte elle-même est dans la
/// feuille de style, où on la règle sans toucher aux bases déjà écrites.
pub const COLUMN_COLOURS: &[&str] = &[
    "red",
    "orange",
    "pink",
    "pastel-green",
    "green",
    "pastel-blue",
    "blue",
    "pastel-yellow",
    "yellow",
];

impl TableLayout {
    /// **Cette disposition se tient-elle ?** Des noms courts et simples, aucun
    /// en double, rien de masqué qui ne soit dans l'ordre, au moins une
    /// colonne visible, des largeurs plausibles.
    ///
    /// « Au moins une colonne visible » est la règle de Fabrice (04/10/2026) :
    /// « exiger qu'il reste simplement une colonne, n'importe laquelle ». Tant
    /// qu'il en reste une, il reste un en-tête, donc le clic droit qui
    /// réaffiche les autres.
    pub fn holds(&self) -> bool {
        let simple = |name: &String| {
            !name.is_empty()
                && name.len() <= 40
                && name
                    .chars()
                    .all(|c| c.is_ascii_lowercase() || c.is_ascii_digit() || c == '-')
        };
        let mut seen = std::collections::BTreeSet::new();
        !self.order.is_empty()
            && self.order.len() <= LAYOUT_COLUMNS_MAX
            && self.order.iter().all(|name| simple(name) && seen.insert(name))
            && {
                let mut hidden = std::collections::BTreeSet::new();
                self.hidden
                    .iter()
                    .all(|name| seen.contains(name) && hidden.insert(name))
            }
            && self.hidden.len() < self.order.len()
            && self.widths.iter().all(|(name, width)| {
                seen.contains(name) && (LAYOUT_WIDTH_MIN..=LAYOUT_WIDTH_MAX).contains(width)
            })
            && self
                .colors
                .iter()
                .all(|(name, colour)| seen.contains(name) && COLUMN_COLOURS.contains(&colour.as_str()))
    }
}

/// La clef d'un tableau, ou rien si ce tableau n'est pas de ceux qu'on règle.
fn layout_key(table: &str) -> Option<String> {
    TABLES_WITH_A_LAYOUT
        .contains(&table)
        .then(|| format!("tableau.{table}"))
}

/// **La disposition enregistrée d'un tableau**, ou rien.
///
/// « Rien » couvre trois cas, et la fenêtre y répond de la même façon — par
/// sa disposition de naissance : aucune n'a été enregistrée ; le tableau n'est
/// pas de ceux qu'on règle ; ce qui est écrit ne se lit pas ou ne se tient
/// pas. Dans ce dernier cas **la ligne fautive est ôtée** (Fabrice,
/// 04/10/2026 : « en cas de problème il doit y avoir une réinitialisation de
/// la préférence au niveau du tableau »), sans quoi elle serait relue, et
/// rejetée, à chaque ouverture.
pub fn table_layout(conn: &Connection, table: &str) -> Result<Option<TableLayout>> {
    let Some(key) = layout_key(table) else {
        return Ok(None);
    };
    let Some(text) = read(conn, &key)? else {
        return Ok(None);
    };
    match serde_json::from_str::<TableLayout>(&text) {
        Ok(layout) if layout.holds() => Ok(Some(layout)),
        _ => {
            remove(conn, &key)?;
            Ok(None)
        }
    }
}

/// Enregistre la disposition d'un tableau. Rend `false`, sans rien écrire,
/// pour un tableau inconnu ou une disposition qui ne se tient pas.
pub fn set_table_layout(conn: &Connection, table: &str, layout: &TableLayout) -> Result<bool> {
    let Some(key) = layout_key(table) else {
        return Ok(false);
    };
    if !layout.holds() {
        return Ok(false);
    }
    let Ok(text) = serde_json::to_string(layout) else {
        return Ok(false);
    };
    write(conn, &key, &text)?;
    Ok(true)
}

/// Rend à un tableau sa disposition de naissance : sa ligne s'en va.
pub fn reset_table_layout(conn: &Connection, table: &str) -> Result<()> {
    match layout_key(table) {
        Some(key) => remove(conn, &key),
        None => Ok(()),
    }
}

/// La même chose pour tous les tableaux — le bouton « Tout réinitialiser ».
pub fn reset_all_table_layouts(conn: &Connection) -> Result<()> {
    for table in TABLES_WITH_A_LAYOUT {
        reset_table_layout(conn, table)?;
    }
    Ok(())
}

/// Ôte une clef. Sans effet si elle n'existe pas.
fn remove(conn: &Connection, key: &str) -> Result<()> {
    conn.execute("DELETE FROM Preferences WHERE Cle = ?1", [key])?;
    Ok(())
}

/// La clef de ce que l'utilisateur a réglé dans la zone « Vos comptes » de
/// l'accueil.
pub const WELCOME_ACCOUNTS_KEY: &str = "accueil.comptes";

/// **Les comptes de l'accueil, tels que l'utilisateur les a rangés** (Fabrice,
/// 07/10/2026) : l'ordre de leurs tuiles, qu'il glisse, et ceux dont il a
/// décoché la case — ils restent affichés, mais ne comptent plus dans les
/// trois totaux ni dans les deux anneaux.
///
/// Des clefs de comptes, donc une affaire de **cette base** : c'est pourquoi
/// la préférence est ici et non sur le poste.
///
/// **Elle n'a pas à être exacte.** Un compte né depuis n'y figure pas : il
/// vient en dernier, et il compte. Un compte supprimé y figure encore : il est
/// ignoré. L'accueil s'en sert comme d'un souhait, jamais comme d'une liste.
#[derive(Debug, Clone, Default, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
#[serde(deny_unknown_fields)]
pub struct WelcomeAccounts {
    /// Les comptes, dans l'ordre où on veut les lire.
    pub order: Vec<i64>,
    /// Ceux qu'on laisse hors des totaux.
    pub excluded: Vec<i64>,
}

impl WelcomeAccounts {
    /// Des clefs plausibles, aucune en double, et pas dix mille.
    pub fn holds(&self) -> bool {
        let sound = |ids: &Vec<i64>| {
            let mut seen = std::collections::BTreeSet::new();
            ids.len() <= 1000 && ids.iter().all(|id| *id > 0 && seen.insert(*id))
        };
        sound(&self.order) && sound(&self.excluded)
    }
}

/// Ce que l'utilisateur a réglé dans « Vos comptes », ou l'état de naissance —
/// l'ordre des listes, tout compté. Une valeur illisible ou qui ne se tient
/// pas est **ôtée**, comme la disposition d'un tableau.
pub fn welcome_accounts(conn: &Connection) -> Result<WelcomeAccounts> {
    let Some(text) = read(conn, WELCOME_ACCOUNTS_KEY)? else {
        return Ok(WelcomeAccounts::default());
    };
    match serde_json::from_str::<WelcomeAccounts>(&text) {
        Ok(stored) if stored.holds() => Ok(stored),
        _ => {
            remove(conn, WELCOME_ACCOUNTS_KEY)?;
            Ok(WelcomeAccounts::default())
        }
    }
}

/// Enregistre ce réglage. Rend `false`, sans rien écrire, s'il ne se tient pas.
pub fn set_welcome_accounts(conn: &Connection, chosen: &WelcomeAccounts) -> Result<bool> {
    if !chosen.holds() {
        return Ok(false);
    }
    let Ok(text) = serde_json::to_string(chosen) else {
        return Ok(false);
    };
    write(conn, WELCOME_ACCOUNTS_KEY, &text)?;
    Ok(true)
}

/// Rend à l'accueil son état de naissance.
pub fn reset_welcome_accounts(conn: &Connection) -> Result<()> {
    remove(conn, WELCOME_ACCOUNTS_KEY)
}

/// La clef du tarif d'électricité de l'outil « Consommation d'un appareil
/// électrique ».
pub const ELECTRICITY_TARIFF_KEY: &str = "tarif.electricite";

/// **Le tarif d'électricité enregistré** (Fabrice, 09/10/2026 : « finalement
/// on pourra mémoriser cela, cela sera enregistré en tant que préférences et
/// modifiable dans le panneau des préférences »), ou le Tarif Bleu d'EDF tant
/// que rien n'est écrit. Une valeur illisible ou qui ne se tient pas est
/// **ôtée**, et c'est le Tarif Bleu qui revient.
///
/// Ce n'est pas du confort : « Réinitialiser les réglages de confort » n'y
/// touche pas — ce sont les prix d'une facture.
pub fn electricity_tariff(conn: &Connection) -> Result<crate::appliance::Tariff> {
    let Some(text) = read(conn, ELECTRICITY_TARIFF_KEY)? else {
        return Ok(crate::appliance::BLUE_TARIFF);
    };
    match serde_json::from_str::<crate::appliance::Tariff>(&text) {
        Ok(stored) if stored.holds() => Ok(stored),
        _ => {
            remove(conn, ELECTRICITY_TARIFF_KEY)?;
            Ok(crate::appliance::BLUE_TARIFF)
        }
    }
}

/// Enregistre le tarif. Rend `false`, sans rien écrire, s'il ne se tient pas.
pub fn set_electricity_tariff(conn: &Connection, tariff: &crate::appliance::Tariff) -> Result<bool> {
    if !tariff.holds() {
        return Ok(false);
    }
    let Ok(text) = serde_json::to_string(tariff) else {
        return Ok(false);
    };
    write(conn, ELECTRICITY_TARIFF_KEY, &text)?;
    Ok(true)
}

/// **Remet d'origine les réglages de confort de cette base** — le bouton des
/// préférences (Fabrice, 07/10/2026 : « il faut avoir un bouton pour remettre
/// à zéro les réglages de confort mais pas le reste »).
///
/// Le confort, ici : les colonnes de tous les tableaux, et l'accueil. **Pas le
/// reste** : ni la devise, ni la vérification des opérations importées — elles
/// changent ce que Radinus écrit ou affiche comme donnée, et les remettre à
/// leur défaut sans que l'utilisateur y pense le surprendrait à son prochain
/// import. La taille de l'affichage est du confort aussi, mais elle vit sur le
/// poste et non dans la base : c'est le contrôleur qui s'en charge.
pub fn reset_comfort(conn: &Connection) -> Result<()> {
    reset_all_table_layouts(conn)?;
    reset_welcome_accounts(conn)
}

/// La valeur brute d'une clef, ou rien.
pub fn read(conn: &Connection, key: &str) -> Result<Option<String>> {
    conn.query_row(
        "SELECT ValeurJSON FROM Preferences WHERE Cle = ?1",
        [key],
        |row| row.get(0),
    )
    .optional()
}

/// Écrit une clef, en remplaçant ce qui s'y trouvait.
///
/// La clef étant unique, `ON CONFLICT` évite d'avoir à savoir si la ligne
/// existe déjà — et évite surtout la course entre le savoir et l'écrire.
pub fn write(conn: &Connection, key: &str, value: &str) -> Result<()> {
    conn.execute(
        "INSERT INTO Preferences (Cle, ValeurJSON) VALUES (?1, ?2)
         ON CONFLICT(Cle) DO UPDATE SET ValeurJSON = excluded.ValeurJSON",
        [key, value],
    )?;
    Ok(())
}

/// La devise choisie, ou celle du système si rien n'a jamais été écrit.
pub fn currency(conn: &Connection) -> Result<Currency> {
    let Some(text) = read(conn, CURRENCY_KEY)? else {
        return Ok(Currency::default());
    };
    // Un JSON illisible ne fait pas échouer l'affichage des montants : on
    // retombe sur le système, comme pour un choix inconnu.
    let Ok(value) = serde_json::from_str::<serde_json::Value>(&text) else {
        return Ok(Currency::default());
    };
    let field = |name: &str| -> String {
        value
            .get(name)
            .and_then(serde_json::Value::as_str)
            .unwrap_or_default()
            .to_string()
    };
    Ok(Currency::from_parts(&field("choix"), &field("signe")))
}

/// Enregistre la devise choisie.
pub fn set_currency(conn: &Connection, currency: &Currency) -> Result<()> {
    let value = serde_json::json!({
        "choix": currency.key(),
        "signe": currency.custom_sign(),
    });
    write(conn, CURRENCY_KEY, &value.to_string())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn layout(order: &[&str], hidden: &[&str], widths: &[(&str, u32)]) -> TableLayout {
        TableLayout {
            order: order.iter().map(|name| name.to_string()).collect(),
            hidden: hidden.iter().map(|name| name.to_string()).collect(),
            widths: widths
                .iter()
                .map(|(name, width)| (name.to_string(), *width))
                .collect(),
            colors: Default::default(),
        }
    }

    /// Fabrice, 05/10/2026 : une colonne se teinte d'une des neuf couleurs, et
    /// la teinte est retenue avec le reste de la disposition.
    #[test]
    fn la_couleur_d_une_colonne_se_retrouve() {
        let conn = Connection::open_in_memory().unwrap();
        crate::database::schema::migrate(&conn).unwrap();
        let mut chosen = layout(&["label", "date", "balance"], &[], &[]);
        chosen.colors.insert("balance".into(), "pastel-yellow".into());
        chosen.colors.insert("date".into(), "red".into());
        assert!(set_table_layout(&conn, "operations-list", &chosen).unwrap());
        assert_eq!(table_layout(&conn, "operations-list").unwrap(), Some(chosen));

        // Une couleur hors de la liste, ou sur une colonne qui n'existe pas,
        // ne se tient pas.
        let mut odd = layout(&["label"], &[], &[]);
        odd.colors.insert("label".into(), "#ff0000".into());
        assert!(!odd.holds());
        let mut lost = layout(&["label"], &[], &[]);
        lost.colors.insert("ailleurs".into(), "red".into());
        assert!(!lost.holds());
        // Les neuf couleurs de la liste se tiennent toutes.
        for colour in COLUMN_COLOURS {
            let mut one = layout(&["label"], &[], &[]);
            one.colors.insert("label".into(), (*colour).into());
            assert!(one.holds(), "{colour}");
        }
        assert_eq!(COLUMN_COLOURS.len(), 9);
    }

    /// **Une disposition enregistrée avant les couleurs se lit toujours.** Le
    /// réglage que l'utilisateur avait fait la veille ne doit pas être rejeté,
    /// puis effacé, à la première ouverture après la mise à jour.
    #[test]
    fn une_disposition_d_avant_les_couleurs_se_lit_sans_couleur() {
        let conn = Connection::open_in_memory().unwrap();
        crate::database::schema::migrate(&conn).unwrap();
        write(
            &conn,
            "tableau.operations-list",
            r#"{"order":["label","date"],"hidden":["date"],"widths":{"label":300}}"#,
        )
        .unwrap();
        let kept = table_layout(&conn, "operations-list").unwrap().expect("lisible");
        assert_eq!(kept.order, vec!["label", "date"]);
        assert_eq!(kept.hidden, vec!["date"]);
        assert!(kept.colors.is_empty());
        assert!(super::read(&conn, "tableau.operations-list").unwrap().is_some());
    }

    /// Fabrice, 04/10/2026 : l'ordre, les colonnes masquées et les largeurs
    /// se retrouvent — une préférence par tableau.
    #[test]
    fn la_disposition_d_un_tableau_se_retrouve() {
        let conn = Connection::open_in_memory().unwrap();
        crate::database::schema::migrate(&conn).unwrap();
        assert_eq!(table_layout(&conn, "operations-list").unwrap(), None);

        let chosen = layout(&["label", "date", "debit"], &["debit"], &[("label", 320)]);
        assert!(set_table_layout(&conn, "operations-list", &chosen).unwrap());
        assert_eq!(table_layout(&conn, "operations-list").unwrap(), Some(chosen));

        // Sa clef est la sienne, et les autres préférences n'ont pas bougé.
        assert!(read(&conn, "tableau.operations-list").unwrap().is_some());
        assert_eq!(import_verification(&conn).unwrap(), 2);

        reset_table_layout(&conn, "operations-list").unwrap();
        assert_eq!(table_layout(&conn, "operations-list").unwrap(), None);
        assert_eq!(read(&conn, "tableau.operations-list").unwrap(), None);
    }

    /// Un nom de tableau inventé n'écrit rien : la table n'est pas un
    /// fourre-tout.
    #[test]
    fn un_tableau_inconnu_n_ecrit_rien() {
        let conn = Connection::open_in_memory().unwrap();
        crate::database::schema::migrate(&conn).unwrap();
        let chosen = layout(&["a"], &[], &[]);
        assert!(!set_table_layout(&conn, "n-importe-quoi", &chosen).unwrap());
        let rows: i64 = conn
            .query_row("SELECT COUNT(*) FROM Preferences", [], |row| row.get(0))
            .unwrap();
        assert_eq!(rows, 0);
        assert_eq!(table_layout(&conn, "n-importe-quoi").unwrap(), None);
    }

    /// « Il reste simplement une colonne, n'importe laquelle » — et le reste
    /// de ce qu'une disposition ne peut pas être.
    #[test]
    fn une_disposition_qui_ne_se_tient_pas_est_refusee() {
        assert!(layout(&["a", "b"], &["a"], &[("b", 120)]).holds());
        // Tout masquer.
        assert!(!layout(&["a", "b"], &["a", "b"], &[]).holds());
        // Aucune colonne.
        assert!(!layout(&[], &[], &[]).holds());
        // Un nom en double, dans l'ordre comme dans les masquées.
        assert!(!layout(&["a", "a"], &[], &[]).holds());
        assert!(!layout(&["a", "b", "c"], &["a", "a"], &[]).holds());
        // Masquer ou élargir une colonne qui n'est pas dans l'ordre.
        assert!(!layout(&["a"], &["z"], &[]).holds());
        assert!(!layout(&["a"], &[], &[("z", 100)]).holds());
        // Des largeurs absurdes.
        assert!(!layout(&["a"], &[], &[("a", 0)]).holds());
        assert!(!layout(&["a"], &[], &[("a", 90_000)]).holds());
        // Un nom qui n'en est pas un.
        assert!(!layout(&["Libellé !"], &[], &[]).holds());

        let conn = Connection::open_in_memory().unwrap();
        crate::database::schema::migrate(&conn).unwrap();
        let broken = layout(&["a", "b"], &["a", "b"], &[]);
        assert!(!set_table_layout(&conn, "operations-list", &broken).unwrap());
        assert_eq!(read(&conn, "tableau.operations-list").unwrap(), None);
    }

    /// Fabrice, 04/10/2026 : « en cas de problème il doit y avoir une
    /// réinitialisation de la préférence au niveau du tableau ». Une valeur
    /// illisible — écrite à la main, venue d'une archive d'une autre version —
    /// rend la disposition de naissance, et **s'en va** de la base.
    #[test]
    fn une_disposition_illisible_est_otee_et_vaut_le_defaut() {
        let conn = Connection::open_in_memory().unwrap();
        crate::database::schema::migrate(&conn).unwrap();
        for broken in [
            "pas du JSON",
            "[1, 2, 3]",
            r#"{"order":["a"],"hidden":["a"],"widths":{}}"#,
            r#"{"order":["a"],"hidden":[],"widths":{},"surprise":true}"#,
            r#"{"order":["a"],"hidden":[],"widths":{"a":"large"}}"#,
        ] {
            write(&conn, "tableau.operations-list", broken).unwrap();
            assert_eq!(table_layout(&conn, "operations-list").unwrap(), None, "{broken}");
            assert_eq!(
                read(&conn, "tableau.operations-list").unwrap(),
                None,
                "{broken} : la ligne fautive est restée"
            );
        }
    }

    /// **Chaque statistique a son tableau, et il n'y en a pas d'autre**
    /// (Fabrice, 04/10/2026 : « une disposition par statistique »). Un axe
    /// ajouté demain sans son nom ici aurait un détail qui oublie tout.
    #[test]
    fn chaque_statistique_a_son_tableau() {
        let wanted: Vec<String> = crate::statistics::AXES
            .iter()
            .map(|axis| format!("{STATISTICS_LAYOUT_PREFIX}{}", axis.key()))
            .collect();
        let have: Vec<String> = TABLES_WITH_A_LAYOUT
            .iter()
            .filter(|name| name.starts_with(STATISTICS_LAYOUT_PREFIX))
            .map(|name| name.to_string())
            .collect();
        assert_eq!(have, wanted);
        // Et aucun nom en double dans la liste entière.
        let mut all = TABLES_WITH_A_LAYOUT.to_vec();
        all.sort_unstable();
        all.dedup();
        assert_eq!(all.len(), TABLES_WITH_A_LAYOUT.len());
    }

    /// Régler les colonnes d'une statistique ne touche pas à celles d'une
    /// autre, et réinitialiser l'une laisse l'autre.
    #[test]
    fn deux_statistiques_ne_partagent_pas_leur_disposition() {
        let conn = Connection::open_in_memory().unwrap();
        crate::database::schema::migrate(&conn).unwrap();
        let first = layout(&["label", "date"], &[], &[]);
        let second = layout(&["date", "label"], &["label"], &[]);
        assert!(set_table_layout(&conn, "statistics-category", &first).unwrap());
        assert!(set_table_layout(&conn, "statistics-payee", &second).unwrap());
        assert_eq!(table_layout(&conn, "statistics-category").unwrap(), Some(first));
        assert_eq!(table_layout(&conn, "statistics-payee").unwrap(), Some(second.clone()));
        assert_eq!(table_layout(&conn, "statistics-project").unwrap(), None);
        reset_table_layout(&conn, "statistics-category").unwrap();
        assert_eq!(table_layout(&conn, "statistics-category").unwrap(), None);
        assert_eq!(table_layout(&conn, "statistics-payee").unwrap(), Some(second));
    }

    /// Fabrice, 04/10/2026 : « on réinitialise les tableaux contenus dans une
    /// fenêtre. Demain il peut y en avoir plusieurs dans une fenêtre. »
    #[test]
    fn une_fenetre_reinitialise_ses_tableaux_et_seulement_les_siens() {
        // Aujourd'hui : une fenêtre, un tableau, le même nom.
        assert_eq!(windows_with_layouts(), TABLES_WITH_A_LAYOUT.to_vec());
        assert_eq!(tables_of_window("crossed-balance"), vec!["crossed-balance"]);
        assert!(tables_of_window("n-importe-quoi").is_empty());
        // « statistics » n'est pas une fenêtre : chaque statistique est la sienne.
        assert!(tables_of_window("statistics").is_empty());
        // Demain : deux tableaux dans une fenêtre porteront son nom en tête.
        assert_eq!(window_of("budget.depenses"), "budget");
        assert_eq!(window_of("budget.recettes"), "budget");
        assert_eq!(window_of("operations-list"), "operations-list");

        let conn = Connection::open_in_memory().unwrap();
        crate::database::schema::migrate(&conn).unwrap();
        let chosen = layout(&["a", "b"], &["a"], &[]);
        for table in TABLES_WITH_A_LAYOUT {
            assert!(set_table_layout(&conn, table, &chosen).unwrap());
        }
        assert_eq!(
            reset_window_layouts(&conn, "statistics-payee").unwrap(),
            vec!["statistics-payee"]
        );
        for table in TABLES_WITH_A_LAYOUT {
            let kept = table_layout(&conn, table).unwrap();
            assert_eq!(kept.is_none(), *table == "statistics-payee", "{table}");
        }
        // Une fenêtre inconnue ne réinitialise rien.
        assert!(reset_window_layouts(&conn, "n-importe-quoi").unwrap().is_empty());
        assert!(table_layout(&conn, "operations-list").unwrap().is_some());
    }

    /// Fabrice, 07/10/2026 : l'ordre des comptes de l'accueil et leurs cases
    /// se retrouvent ; une valeur qui ne se tient pas est ôtée.
    #[test]
    fn les_comptes_de_l_accueil_se_retrouvent() {
        let conn = Connection::open_in_memory().unwrap();
        crate::database::schema::migrate(&conn).unwrap();
        assert_eq!(welcome_accounts(&conn).unwrap(), WelcomeAccounts::default());

        let chosen = WelcomeAccounts { order: vec![3, 1, 2], excluded: vec![2] };
        assert!(set_welcome_accounts(&conn, &chosen).unwrap());
        assert_eq!(welcome_accounts(&conn).unwrap(), chosen);

        for broken in [
            WelcomeAccounts { order: vec![1, 1], excluded: vec![] },
            WelcomeAccounts { order: vec![1], excluded: vec![2, 2] },
            WelcomeAccounts { order: vec![0], excluded: vec![] },
            WelcomeAccounts { order: vec![], excluded: vec![-4] },
        ] {
            assert!(!broken.holds());
            assert!(!set_welcome_accounts(&conn, &broken).unwrap());
        }
        assert_eq!(welcome_accounts(&conn).unwrap(), chosen);

        for text in ["rien", "[1,2]", r#"{"order":[1,1],"excluded":[]}"#, r#"{"order":[1]}"#] {
            write(&conn, WELCOME_ACCOUNTS_KEY, text).unwrap();
            assert_eq!(welcome_accounts(&conn).unwrap(), WelcomeAccounts::default(), "{text}");
            assert_eq!(read(&conn, WELCOME_ACCOUNTS_KEY).unwrap(), None, "{text}");
        }
    }

    /// « Remettre à zéro les réglages de confort mais pas le reste. »
    #[test]
    fn la_remise_a_zero_du_confort_laisse_le_reste() {
        let conn = Connection::open_in_memory().unwrap();
        crate::database::schema::migrate(&conn).unwrap();
        set_import_verification(&conn, 1).unwrap();
        write(&conn, CURRENCY_KEY, r#"{"choix":"CHF","signe":""}"#).unwrap();
        for table in TABLES_WITH_A_LAYOUT {
            assert!(set_table_layout(&conn, table, &layout(&["a", "b"], &[], &[])).unwrap());
        }
        let chosen = WelcomeAccounts { order: vec![2, 1], excluded: vec![1] };
        assert!(set_welcome_accounts(&conn, &chosen).unwrap());

        reset_comfort(&conn).unwrap();

        for table in TABLES_WITH_A_LAYOUT {
            assert_eq!(table_layout(&conn, table).unwrap(), None);
        }
        assert_eq!(welcome_accounts(&conn).unwrap(), WelcomeAccounts::default());
        // Le reste n'a pas bougé.
        assert_eq!(import_verification(&conn).unwrap(), 1);
        assert!(read(&conn, CURRENCY_KEY).unwrap().is_some());
        let rows: i64 = conn
            .query_row("SELECT COUNT(*) FROM Preferences", [], |row| row.get(0))
            .unwrap();
        assert_eq!(rows, 2);
    }

    /// « Tout réinitialiser » rend leur naissance aux tableaux, et ne touche à
    /// rien d'autre — ni la devise, ni la vérification des imports.
    #[test]
    fn tout_reinitialiser_ne_touche_qu_aux_tableaux() {
        let conn = Connection::open_in_memory().unwrap();
        crate::database::schema::migrate(&conn).unwrap();
        set_import_verification(&conn, 1).unwrap();
        write(&conn, CURRENCY_KEY, r#"{"choix":"CHF","signe":""}"#).unwrap();
        for table in TABLES_WITH_A_LAYOUT {
            assert!(set_table_layout(&conn, table, &layout(&["a", "b"], &[], &[])).unwrap());
        }
        reset_all_table_layouts(&conn).unwrap();
        for table in TABLES_WITH_A_LAYOUT {
            assert_eq!(table_layout(&conn, table).unwrap(), None);
        }
        assert_eq!(import_verification(&conn).unwrap(), 1);
        assert!(read(&conn, CURRENCY_KEY).unwrap().is_some());
    }

    #[test]
    fn la_verification_des_imports_n_a_que_deux_reponses() {
        let conn = Connection::open_in_memory().unwrap();
        crate::database::schema::migrate(&conn).unwrap();
        // Rien d'écrit : on fait confiance à sa banque.
        assert_eq!(import_verification(&conn).unwrap(), 2);
        set_import_verification(&conn, 1).unwrap();
        assert_eq!(import_verification(&conn).unwrap(), 1);
        // « Douteuse » n'est pas une réponse d'import : retour au défaut.
        set_import_verification(&conn, 3).unwrap();
        assert_eq!(import_verification(&conn).unwrap(), 2);
        write(&conn, IMPORT_VERIFICATION_KEY, "n'importe quoi").unwrap();
        assert_eq!(import_verification(&conn).unwrap(), 2);
    }
    use crate::database::{schema, seed};

    fn database() -> Connection {
        let conn = Connection::open_in_memory().expect("base en mémoire");
        schema::migrate(&conn).expect("schéma");
        seed::seed_initial_data(&conn).expect("valeurs initiales");
        conn
    }

    /// Une base neuve n'a rien écrit, et suit le système.
    #[test]
    fn a_fresh_database_follows_the_system() {
        let conn = database();
        assert_eq!(currency(&conn).expect("devise"), Currency::System);
        assert_eq!(read(&conn, CURRENCY_KEY).expect("lecture"), None);
    }

    /// Ce qui est écrit se relit, y compris le signe tapé à la main.
    #[test]
    fn what_is_written_reads_back() {
        let conn = database();
        for chosen in [
            Currency::Euro,
            Currency::Dollar,
            Currency::Cfa,
            Currency::CanadianDollar,
            Currency::NoSign,
            Currency::CfpFranc,
            Currency::SwissFranc,
            Currency::Custom("kr".to_string()),
            Currency::System,
        ] {
            set_currency(&conn, &chosen).expect("écriture");
            assert_eq!(currency(&conn).expect("devise"), chosen);
        }
    }

    /// **Une seule ligne, quoi qu'on fasse.** La clef est unique et l'écriture
    /// remplace : dix changements de devise ne laissent pas dix lignes.
    #[test]
    fn changing_the_choice_never_adds_a_second_row() {
        let conn = database();
        for chosen in [Currency::Euro, Currency::Dollar, Currency::Euro] {
            set_currency(&conn, &chosen).expect("écriture");
        }
        let count: i64 = conn
            .query_row("SELECT COUNT(*) FROM Preferences", [], |row| row.get(0))
            .expect("comptage");
        assert_eq!(count, 1);
    }

    /// Un JSON abîmé ou un choix venu d'une version future n'empêche pas
    /// d'afficher un montant.
    #[test]
    fn a_broken_value_falls_back_instead_of_failing() {
        let conn = database();
        write(&conn, CURRENCY_KEY, "ceci n'est pas du JSON").expect("écriture");
        assert_eq!(currency(&conn).expect("devise"), Currency::System);
        write(&conn, CURRENCY_KEY, r#"{"choix":"BITCOIN","signe":"₿"}"#).expect("écriture");
        assert_eq!(currency(&conn).expect("devise"), Currency::System);
    }

    /// **Un signe trop long est refusé, il n'est pas raccourci.**
    ///
    /// Ce test disait le contraire avant que le piège ne soit refermé : dix
    /// « € » devenaient huit. Tronquer afficherait un signe que personne n'a
    /// demandé, et sur toutes les lignes du logiciel — mieux vaut retomber sur
    /// l'euro, qui est au moins une devise que quelqu'un a choisie un jour.
    ///
    /// La longueur se compte en **caractères** et non en octets : « € » en
    /// pèse trois, et huit d'entre eux passeraient pour vingt-quatre.
    #[test]
    fn a_sign_that_is_too_long_is_refused_rather_than_shortened() {
        assert_eq!(Currency::Custom("€€€€€€€€€€".to_string()).sign(""), "€");
        assert_eq!(Currency::Custom("€€€€€€€€".to_string()).sign(""), "€€€€€€€€");
        // Les espaces autour ne comptent pas : on les ôte avant de mesurer.
        assert_eq!(Currency::Custom("  CHF  ".to_string()).sign(""), "CHF");
    }

    /// **Les deux dollars s'écrivent pareil, et se rangent à part.** Le choix
    /// est mémorisé distinctement — un canadien qui rouvre ses préférences
    /// retrouve « Dollars canadiens » coché, et non « Dollars ».
    #[test]
    fn both_dollars_write_the_same_sign_and_are_remembered_apart() {
        assert_eq!(Currency::Dollar.sign(""), "$");
        assert_eq!(Currency::CanadianDollar.sign(""), "$");
        assert_ne!(Currency::Dollar.key(), Currency::CanadianDollar.key());
        assert_eq!(Currency::from_parts("CAD", ""), Currency::CanadianDollar);
    }

    /// Le franc suisse porte son code ISO, et **c'est un signe utilisable** :
    /// les formes `Fr.` et `SFr.` ne le seraient pas, leur point étant l'un des
    /// caractères que `money::parse` ôte d'une saisie.
    #[test]
    fn the_swiss_franc_wears_its_iso_code() {
        assert_eq!(Currency::SwissFranc.sign(""), "CHF");
        assert!(sign_is_usable("CHF"));
        assert!(!sign_is_usable("Fr."));
        assert_eq!(Currency::from_parts("CHF", ""), Currency::SwissFranc);
    }

    /// **« Aucune » est un choix, pas une absence de choix.** Il se relit tel
    /// quel, et ne retombe pas sur l'euro au démarrage suivant — ce qui serait
    /// arrivé si on l'avait représenté par un signe vide.
    #[test]
    fn asking_for_no_currency_is_remembered_as_such() {
        let conn = database();
        set_currency(&conn, &Currency::NoSign).expect("écriture");
        assert_eq!(currency(&conn).expect("devise"), Currency::NoSign);
        assert_eq!(Currency::NoSign.sign("$"), "", "le signe du système s'est invité");
    }

    /// Les deux francs de la zone franc ne se confondent pas : le CFA et le
    /// Pacifique portent chacun le sien, et se rangent sous leur propre code.
    #[test]
    fn the_two_franc_zones_do_not_get_mixed_up() {
        assert_eq!(Currency::Cfa.sign(""), "FCFA");
        assert_eq!(Currency::CfpFranc.sign(""), "FCFP");
        assert_eq!(Currency::from_parts("XPF", ""), Currency::CfpFranc);
        assert_ne!(Currency::Cfa.key(), Currency::CfpFranc.key());
    }

    /// **Une seule clef depuis le 04/08/2026.** Le zoom est parti dans la
    /// configuration du logiciel ; s'il en revenait ici, ce test le dirait —
    /// et une taille d'affichage qui voyagerait de nouveau avec les sauvegardes
    /// serait exactement le défaut que Fabrice a fait corriger.
    #[test]
    fn radinus_writes_one_key_and_no_other() {
        let conn = database();
        set_currency(&conn, &Currency::Cfa).expect("devise");
        let keys: Vec<String> = conn
            .prepare("SELECT Cle FROM Preferences ORDER BY Cle")
            .expect("requête")
            .query_map([], |row| row.get(0))
            .expect("lecture")
            .collect::<Result<_>>()
            .expect("clefs");
        assert_eq!(keys, vec![CURRENCY_KEY.to_string()]);
    }

    /// **Le piège, et pourquoi il en est un.** Un signe qui ressemble à un
    /// morceau de nombre corrompt les saisies, parce que `money::parse` ôte le
    /// signe avant de lire. Ces deux-là sont les cas qui font mal.
    #[test]
    fn a_sign_that_looks_like_part_of_a_number_is_refused() {
        for refused in ["0", "12", "-", "+", "$-", ",", ".", "(", ")", "1F", "٠"] {
            assert!(!sign_is_usable(refused), "« {refused} » aurait dû être refusé");
        }
    }

    /// Et tout ce dont une devise a besoin passe.
    #[test]
    fn every_sign_a_currency_needs_goes_through() {
        for accepted in ["€", "$", "£", "¥", "CHF", "kr", "zł", "Kč", "FCFA", "F CFA"] {
            assert!(sign_is_usable(accepted), "« {accepted} » aurait dû passer");
        }
    }

    /// Trop long, vide, ou du blanc : refusés aussi.
    #[test]
    fn a_sign_is_bounded_and_never_empty() {
        assert!(!sign_is_usable(""));
        assert!(!sign_is_usable("   "));
        assert!(sign_is_usable("ABCDEFGH"));
        assert!(!sign_is_usable("ABCDEFGHI"));
    }

    /// **La seconde barrière tient.** Un JSON modifié à la main dans la base
    /// ne peut pas imposer un signe qui casserait les saisies : il vaut l'euro,
    /// et les montants restent lisibles.
    #[test]
    fn a_hand_edited_database_cannot_impose_a_broken_sign() {
        let conn = database();
        write(&conn, CURRENCY_KEY, r#"{"choix":"perso","signe":"0"}"#).expect("écriture");
        let chosen = currency(&conn).expect("devise");
        assert_eq!(chosen, Currency::Custom("0".to_string()));
        assert_eq!(chosen.sign(""), "€", "un signe cassé est devenu le signe en vigueur");
    }

    /// Un système qui répondrait n'importe quoi ne casse rien non plus.
    #[test]
    fn an_unusable_system_answer_is_worth_the_euro() {
        assert_eq!(Currency::System.sign("-"), "€");
        assert_eq!(Currency::System.sign("12"), "€");
        assert_eq!(Currency::System.sign("kr"), "kr");
    }

    /// Un système muet vaut l'euro, et un signe personnalisé vide aussi : un
    /// montant sans aucun signe ne dirait pas qu'il est en euros, il dirait
    /// qu'on ne sait pas.
    #[test]
    fn a_silent_system_is_worth_the_euro() {
        assert_eq!(Currency::System.sign(""), "€");
        assert_eq!(Currency::System.sign("   "), "€");
        assert_eq!(Currency::System.sign("$"), "$");
        assert_eq!(Currency::Custom(String::new()).sign("$"), "€");
    }

    /// **Le tarif d'électricité** : le Tarif Bleu tant que rien n'est écrit,
    /// le tarif enregistré ensuite, et un tarif qui ne se tient pas est ôté.
    /// La remise à zéro du confort n'y touche pas.
    #[test]
    fn the_electricity_tariff_is_kept_and_survives_the_comfort_reset() {
        use crate::appliance::{Tariff, BLUE_TARIFF};
        let conn = database();
        assert_eq!(electricity_tariff(&conn).unwrap(), BLUE_TARIFF);
        let mine = Tariff { off_peak_option: true, peak: 250_000, ..BLUE_TARIFF };
        assert!(set_electricity_tariff(&conn, &mine).unwrap());
        assert_eq!(electricity_tariff(&conn).unwrap(), mine);
        reset_comfort(&conn).unwrap();
        assert_eq!(electricity_tariff(&conn).unwrap(), mine);
        assert!(!set_electricity_tariff(&conn, &Tariff { off_peak_hours: 30, ..mine }).unwrap());
        write(&conn, ELECTRICITY_TARIFF_KEY, r#"{"off_peak_option":true}"#).unwrap();
        assert_eq!(electricity_tariff(&conn).unwrap(), BLUE_TARIFF);
        assert_eq!(read(&conn, ELECTRICITY_TARIFF_KEY).unwrap(), None);
    }
}
