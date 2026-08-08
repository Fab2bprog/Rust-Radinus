//! Core-side localization skeleton (Fluent — approved dependency, see
//! 08_ARCHITECTURE.md §2.1). Resources live in `radinus-core/i18n/*.ftl` and
//! are embedded into the binary at compile time (no filesystem lookup at
//! runtime, which fits the portable/self-contained requirement).
//!
//! **Everything the user reads is here**, in both languages: the business
//! messages, and every word the windows and the menu bar say for themselves
//! (author's ruling, 25/07/2026 — "le logiciel fonctionne avec Fluent en
//! français et en anglais dès le début"). The interface holds no sentence of
//! its own; it asks for the ones it needs and shows them.
//!
//! Sentences that depend on the nomenclature are written **whole**, one
//! branch per nomenclature, rather than assembled from a noun and a gender.
//! An assembly that reads correctly in French is wrong in the next language,
//! and it ends up teaching the code that a feminine exists — which is not its
//! job.

// **La variante « concurrent » du dictionnaire Fluent, et non l'ordinaire.**
// C'est la seule qui puisse être partagée entre plusieurs fils d'exécution, et
// il en faut une ici : le dictionnaire est construit une fois puis lu par
// toutes les fenêtres à la fois. Les deux variantes s'emploient exactement
// pareil ; elles ne diffèrent que par la façon dont Fluent mémorise ses règles
// de pluriel.
use fluent_bundle::concurrent::FluentBundle;
use fluent_bundle::{FluentArgs, FluentResource};
use std::sync::OnceLock;
use std::sync::RwLock;
use unic_langid::LanguageIdentifier;

const FR_FTL: &str = include_str!("../i18n/fr.ftl");
const EN_FTL: &str = include_str!("../i18n/en.ftl");
const ES_FTL: &str = include_str!("../i18n/es.ftl");
const PT_FTL: &str = include_str!("../i18n/pt.ftl");
const IT_FTL: &str = include_str!("../i18n/it.ftl");
const DE_FTL: &str = include_str!("../i18n/de.ftl");
const RU_FTL: &str = include_str!("../i18n/ru.ftl");
const PL_FTL: &str = include_str!("../i18n/pl.ftl");
const UK_FTL: &str = include_str!("../i18n/uk.ftl");
const NL_FTL: &str = include_str!("../i18n/nl.ftl");
const SV_FTL: &str = include_str!("../i18n/sv.ftl");
const NB_FTL: &str = include_str!("../i18n/nb.ftl");
const RO_FTL: &str = include_str!("../i18n/ro.ftl");
const FI_FTL: &str = include_str!("../i18n/fi.ftl");
const IS_FTL: &str = include_str!("../i18n/is.ftl");
const HE_FTL: &str = include_str!("../i18n/he.ftl");
const AR_FTL: &str = include_str!("../i18n/ar.ftl");
const EL_FTL: &str = include_str!("../i18n/el.ftl");

/// Une langue que Radinus sait parler.
///
/// **Trois choses la désignent, et pas une seule**, parce qu'elles ne servent
/// pas au même interlocuteur :
///
/// * `code` — le numéro de la constante « nation » du WLangage (5 = français,
///   1 = allemand, 3 = anglais, 7 = espagnol, 8 = finnois, 10 = islandais,
///   11 = italien, 12 = néerlandais, 19 = arabe, 27 = grec,
///   13 = norvégien, 14 = portugais, 16 = russe, 17 = suédois, 28 = hébreu,
///   34 = polonais, 35 = roumain ; table `Analyse/Langues/Code langue.xlsx`).
///   **Au-dessus de 99, ce sont les numéros de Radinus** : voir
///   [`FIRST_RADINUS_CODE`].
///   **C'est lui qui est écrit en base et dans l'archive de sauvegarde**
///   (décision de Fabrice, 01/08/2026, qui révise le 02_BASE_DE_DONNEES.md
///   §3.11) : une sauvegarde 1.9.3 porte ce nombre, et le lui rendre tel quel
///   est la seule façon qu'un aller-retour ne perde pas la langue ;
/// * `tag` — l'étiquette normalisée dont Fluent a besoin pour ses règles de
///   pluriel et Typst pour sa césure. Elle ne va jamais en base ;
/// * le **nom de la langue dans sa propre langue**, qui n'est pas ici : il est
///   dans le fichier de langue, sous la clef `language-name`. C'est le seul
///   endroit où il puisse être juste — « Español » s'écrit en espagnol.
struct Known {
    code: i64,
    tag: &'static str,
    source: &'static str,
}

/// Les langues du logiciel, **dans l'ordre où l'utilisateur les voit**.
///
/// Une langue de plus, c'est une ligne de plus ici et un fichier `.ftl` à
/// côté — rien d'autre dans tout le noyau. Les séparateurs de montant, le nom
/// de la langue et toutes ses phrases viennent de son fichier ; le numéro
/// WinDev et l'étiquette sont les deux seules choses que le code ait à savoir.
/// **Le premier numéro qui n'appartient pas à WinDev.**
///
/// La table du WLangage va de 1 à 50 et s'arrête au hindi ; **l'ukrainien n'y
/// est pas** (relevé le 03/08/2026 en l'ajoutant). Il fallait donc lui donner
/// un numéro que WinDev ne réclamerait jamais — parce que ce numéro part dans
/// la base de l'utilisateur et dans son archive de sauvegarde, et qu'un
/// numéro repris plus tard par WinDev ferait ouvrir une base ukrainienne dans
/// une autre langue.
///
/// **La règle, décidée par Fabrice le 03/08/2026 : trois chiffres.** Sous 100,
/// les numéros sont ceux de WinDev et lui restent réservés — 49 places libres
/// devant nous, de quoi voir venir si la table s'allonge. À partir de 100, ce
/// sont les nôtres, attribués ici dans l'ordre où les langues arrivent.
///
/// Un test vérifie qu'aucune langue ne s'assied entre les deux mondes : soit
/// son numéro vient de la table WinDev, soit il vaut au moins 100.
pub const FIRST_RADINUS_CODE: i64 = 100;

const KNOWN: &[Known] = &[
    Known {
        code: 5,
        tag: "fr",
        source: FR_FTL,
    },
    Known {
        code: 3,
        tag: "en",
        source: EN_FTL,
    },
    Known {
        code: 7,
        tag: "es",
        source: ES_FTL,
    },
    Known {
        code: 14,
        tag: "pt",
        source: PT_FTL,
    },
    Known {
        code: 11,
        tag: "it",
        source: IT_FTL,
    },
    Known {
        code: 1,
        tag: "de",
        source: DE_FTL,
    },
    Known {
        code: 16,
        tag: "ru",
        source: RU_FTL,
    },
    Known {
        code: 34,
        tag: "pl",
        source: PL_FTL,
    },
    // Premier numéro de la plage Radinus — voir `FIRST_RADINUS_CODE`.
    Known {
        code: 100,
        tag: "uk",
        source: UK_FTL,
    },
    Known {
        code: 12,
        tag: "nl",
        source: NL_FTL,
    },
    Known {
        code: 17,
        tag: "sv",
        source: SV_FTL,
    },
    Known {
        code: 13,
        tag: "nb",
        source: NB_FTL,
    },
    Known {
        code: 35,
        tag: "ro",
        source: RO_FTL,
    },
    Known {
        code: 8,
        tag: "fi",
        source: FI_FTL,
    },
    Known {
        code: 10,
        tag: "is",
        source: IS_FTL,
    },
    Known {
        code: 28,
        tag: "he",
        source: HE_FTL,
    },
    Known {
        code: 19,
        tag: "ar",
        source: AR_FTL,
    },
    Known {
        code: 27,
        tag: "el",
        source: EL_FTL,
    },
];

/// Une des langues de [`KNOWN`], désignée par son rang.
///
/// Le rang plutôt que le numéro, pour que le casier de chaque langue soit un
/// simple élément de tableau et reste atteignable **sans verrou** : c'est ce
/// qui rend un mot gratuit une fois le dictionnaire construit.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Language(usize);

impl Language {
    /// Le français, langue par défaut et langue de l'original.
    #[allow(non_upper_case_globals)]
    pub const French: Language = Language(0);
    /// L'anglais.
    #[allow(non_upper_case_globals)]
    pub const English: Language = Language(1);
    /// L'espagnol — ajouté le 01/08/2026 à la demande de Fabrice.
    #[allow(non_upper_case_globals)]
    pub const Spanish: Language = Language(2);
    /// Le portugais — ajouté le 03/08/2026 à la demande de Fabrice. Le numéro
    /// 14 est `nationPortugais` ; le 15, `nationPortugaisBrésilien`, est une
    /// autre nation et n'est pas celle-ci.
    #[allow(non_upper_case_globals)]
    pub const Portuguese: Language = Language(3);
    /// L'italien — ajouté le 03/08/2026 à la demande de Fabrice.
    #[allow(non_upper_case_globals)]
    pub const Italian: Language = Language(4);
    /// L'allemand — ajouté le 03/08/2026 à la demande de Fabrice. Son numéro,
    /// **1**, était jusque-là l'exemple du test qui montrait qu'un numéro
    /// inconnu retombe sur le français. Il ne peut plus l'être : c'est
    /// maintenant une langue que le logiciel parle.
    #[allow(non_upper_case_globals)]
    pub const German: Language = Language(5);
    /// Le russe — ajouté le 03/08/2026 à la demande de Fabrice. **La première
    /// langue dont le fichier n'a pas la même forme que le français** : le
    /// russe compte quatre formes de pluriel là où le français en a deux, et
    /// `ru.ftl` porte donc 62 lignes de plus que `fr.ftl` sans porter une
    /// clef de plus. Rien à faire pour autant dans le code : c'est Fluent qui
    /// choisit la variante, à partir de l'étiquette `ru`.
    #[allow(non_upper_case_globals)]
    pub const Russian: Language = Language(6);
    /// Le polonais — ajouté le 03/08/2026 à la demande de Fabrice. Quatre
    /// formes de pluriel comme le russe, mais **pas les mêmes** : en polonais
    /// `one` ne vaut que pour 1, tandis que le russe y met aussi 21, 31, 101.
    /// Recopier les désinences russes aurait donné un fichier qui s'analyse,
    /// qui passe les tests, et qui écrit faux une fois sur dix.
    #[allow(non_upper_case_globals)]
    pub const Polish: Language = Language(7);
    /// L'ukrainien — ajouté le 03/08/2026 à la demande de Fabrice. **La
    /// première langue que WinDev ne connaît pas**, et donc la première à
    /// porter un numéro de Radinus : 100. Ses pluriels comptent comme ceux du
    /// russe (21 est `one`) et non comme ceux du polonais.
    #[allow(non_upper_case_globals)]
    pub const Ukrainian: Language = Language(8);
    /// Le néerlandais — ajouté le 03/08/2026 à la demande de Fabrice. Son
    /// étiquette `nl` servait depuis le matin d'exemple d'étiquette inconnue,
    /// exactement comme le numéro 1 de l'allemand avant lui ; l'exemple est
    /// passé au danois. **Seule langue avec l'anglais à mettre le signe
    /// monétaire devant le nombre** : « € 1.549,81 ».
    #[allow(non_upper_case_globals)]
    pub const Dutch: Language = Language(9);
    /// Le suédois — ajouté le 03/08/2026 à la demande de Fabrice.
    #[allow(non_upper_case_globals)]
    pub const Swedish: Language = Language(10);
    /// Le norvégien — ajouté le 03/08/2026 à la demande de Fabrice.
    ///
    /// **C'est le bokmål**, et l'étiquette le dit : `nb`, et non `no`. Le
    /// norvégien a deux normes écrites et WinDev n'a qu'un numéro pour les
    /// deux (13) ; l'étiquette est le seul endroit où Radinus peut dire
    /// laquelle il parle, et Fluent en a besoin pour ses règles.
    #[allow(non_upper_case_globals)]
    pub const Norwegian: Language = Language(11);
    /// Le roumain — ajouté le 03/08/2026 à la demande de Fabrice.
    ///
    /// **Troisième forme de pluriel rencontrée dans ce logiciel** : trois
    /// catégories, là où le français en a deux et le russe quatre. Et une
    /// raison que les autres n'ont pas — à partir de vingt, le roumain glisse
    /// `de` entre le nombre et le nom : « 19 operațiuni », mais
    /// « 20 **de** operațiuni ».
    #[allow(non_upper_case_globals)]
    pub const Romanian: Language = Language(12);
    /// Le finnois — ajouté le 03/08/2026 à la demande de Fabrice.
    ///
    /// Deux catégories de pluriel comme le français, **mais elles ne se
    /// remplissent pas pareil** : après un nombre, le finnois met son nom au
    /// partitif singulier et non au pluriel — « 1 tili » mais « 3 tiliä ».
    /// Rien dans la forme du fichier ne le montre ; c'est du vocabulaire, pas
    /// de la structure.
    #[allow(non_upper_case_globals)]
    pub const Finnish: Language = Language(13);
    /// L'islandais — ajouté le 03/08/2026 à la demande de Fabrice.
    ///
    /// **Deux catégories de pluriel, dont une qui ne veut pas dire ce qu'elle
    /// dit.** En islandais, `one` vaut pour tout nombre finissant par 1 sauf
    /// 11 — 1, 21, 31, 101. Une variante `[one]` qui écrirait « 1 » en dur,
    /// comme le fait le français, annoncerait une seule chose alors qu'il y en
    /// a vingt et une. Les 29 variantes `[one]` de `is.ftl` portent donc
    /// toutes `{ $count }`, et c'est vérifié.
    #[allow(non_upper_case_globals)]
    pub const Icelandic: Language = Language(14);
    /// L'hébreu — ajouté le 03/08/2026 à la demande de Fabrice.
    ///
    /// **Première écriture de droite à gauche du logiciel, et elle n'a rien
    /// coûté** : un fichier, comme les quinze autres. Chaque caractère hébreu
    /// porte sa direction, et le navigateur place le texte tout seul. Aucune
    /// fenêtre, aucune feuille de style, aucun champ n'a bougé — c'est la
    /// règle posée par Fabrice le même jour (P-28).
    ///
    /// Trois formes de pluriel : singulier, **duel** (exactement deux) et
    /// pluriel. `[two]` n'existe dans aucune autre langue du logiciel.
    #[allow(non_upper_case_globals)]
    pub const Hebrew: Language = Language(15);
    /// L'arabe — ajouté le 03/08/2026 à la demande de Fabrice, dans la foulée
    /// de l'hébreu et à la même condition : **traduction seule**, aucune
    /// fenêtre touchée (P-28).
    ///
    /// **Six formes de pluriel** — zéro, un, deux, peu (3-10), beaucoup
    /// (11-99), autre (100 et au-delà) : le système le plus riche des seize
    /// langues. Le russe en a quatre, l'hébreu trois, le français deux.
    ///
    /// Les nombres restent en **chiffres occidentaux**. Radinus ne produit que
    /// ceux-là, et écrire des chiffres arabo-indiens dans les phrases aurait
    /// donné des lignes où deux systèmes de numération se côtoient.
    #[allow(non_upper_case_globals)]
    pub const Arabic: Language = Language(16);
    /// Le grec — ajouté le 03/08/2026 à la demande de Fabrice. Deux formes de
    /// pluriel comme le français. Sa particularité est ailleurs : **le point
    /// d'interrogation grec s'écrit `;`**, et le point-virgule `·`.
    #[allow(non_upper_case_globals)]
    pub const Greek: Language = Language(17);

    /// La langue que porte un numéro WinDev — ce que la base et l'archive
    /// stockent. Un numéro que ce logiciel ne sait pas parler retombe sur le
    /// français : mieux vaut une fenêtre lisible qu'une fenêtre vide.
    pub fn from_id(code: i64) -> Self {
        Language(
            KNOWN
                .iter()
                .position(|known| known.code == code)
                .unwrap_or(0),
        )
    }

    /// Le numéro WinDev de cette langue — ce qui s'écrit en base.
    pub fn code(self) -> i64 {
        KNOWN[self.0].code
    }

    /// L'étiquette normalisée (`fr`, `en`, `es`) — pour Fluent et pour Typst,
    /// jamais pour la base.
    pub fn tag(self) -> &'static str {
        KNOWN[self.0].tag
    }

    /// La langue que porte une étiquette normalisée. Sert aux endroits qui
    /// n'ont qu'un code court sous la main — le fichier de configuration
    /// portable, par exemple.
    pub fn from_tag(tag: &str) -> Self {
        let wanted = tag.trim().to_ascii_lowercase();
        Language(
            KNOWN
                .iter()
                .position(|known| known.tag == wanted)
                .unwrap_or(0),
        )
    }

    /// Toutes les langues du logiciel, dans l'ordre d'affichage. C'est ce que
    /// lit le menu Paramètres, et ce que lira le sélecteur du premier
    /// lancement : la liste n'est écrite nulle part ailleurs.
    pub fn all() -> Vec<Language> {
        (0..KNOWN.len()).map(Language).collect()
    }

    /// Le nom de la langue **écrit dans cette langue** : « Français »,
    /// « English », « Español ». Il vient du fichier de langue, pas d'ici.
    pub fn name(self) -> String {
        text(self, "language-name")
    }

    fn lang_id(self) -> LanguageIdentifier {
        self.tag().parse().expect("valid language id")
    }

    fn resource_source(self) -> &'static str {
        KNOWN[self.0].source
    }

    /// **Le casier de cette langue** — vide tant que personne n'a demandé un
    /// mot dans cette langue-là, rempli une seule fois ensuite, et jamais
    /// modifié.
    ///
    /// Un casier par langue, et non un tiroir unique que l'on viderait pour le
    /// remplir d'une autre langue : ce qui n'est écrit qu'une fois se partage
    /// entre les fenêtres sans verrou, alors qu'un tiroir remplaçable devrait
    /// être protégé à chaque mot. Une langue de plus ne coûte qu'un casier de
    /// plus dans le tableau — quelques octets tant qu'elle ne sert pas.
    fn locker(self) -> &'static OnceLock<Option<FluentBundle<FluentResource>>> {
        static LOCKERS: [OnceLock<Option<FluentBundle<FluentResource>>>; KNOWN.len()] =
            [const { OnceLock::new() }; KNOWN.len()];
        &LOCKERS[self.0]
    }
}

impl Default for Language {
    fn default() -> Self {
        Language::French
    }
}

/// Builds a `FluentBundle` for the given language from the embedded `.ftl`
/// resource. Returns an error string (rather than panicking) if the resource
/// fails to parse — that would be a build-time authoring mistake, not a
/// runtime condition to crash over.
///
/// **Appelée une seule fois par langue**, par [`dictionary`], qui en garde le
/// résultat. Rien d'autre ne doit l'appeler : construire un dictionnaire pour
/// en tirer un mot est ce qui rendait le logiciel lent.
///
/// Bidirectional isolation is switched off: Fluent otherwise wraps every
/// substituted value in invisible U+2068/U+2069 marks, which would make a
/// message like the nomenclature deletion warning differ, character for
/// character, from the one Radinus 1.9.3 shows.
pub fn build_bundle(language: Language) -> Result<FluentBundle<FluentResource>, String> {
    let resource = FluentResource::try_new(language.resource_source().to_string())
        .map_err(|(_, errors)| format!("Fluent resource parse error(s): {errors:?}"))?;

    let mut bundle = FluentBundle::new_concurrent(vec![language.lang_id()]);
    bundle.set_use_isolating(false);
    bundle
        .add_resource(resource)
        .map_err(|errors| format!("Fluent resource load error(s): {errors:?}"))?;
    Ok(bundle)
}

/// Le dictionnaire de cette langue, **construit une fois pour toutes**.
///
/// Le premier appel analyse le fichier de langue — soixante-dix-huit mille
/// caractères pour le français — et range le résultat dans le casier de la
/// langue. Tous les appels suivants n'en reçoivent que l'adresse.
///
/// C'est le cœur de la correction du 01/08/2026. Cette fonction analysait
/// auparavant tout le fichier **à chaque mot demandé** : un clic sur une
/// période d'un an, qui demande le nom du mois de chacune de ses cinq cent
/// quatre-vingt-sept lignes, coûtait une seconde et demie d'analyse pour n'en
/// tirer que douze mots différents. Mesuré : deux millisecondes et sept par
/// mot avant, quatre dix-millièmes de milliseconde après.
///
/// Un fichier de langue qui ne s'analyse pas laisse le casier à `None` plutôt
/// que d'interrompre le programme : c'est une faute d'écriture, pas une
/// condition d'exécution, et le logiciel doit rester capable de dire qu'il ne
/// sait plus parler.
fn dictionary(language: Language) -> Option<&'static FluentBundle<FluentResource>> {
    language
        .locker()
        .get_or_init(|| build_bundle(language).ok())
        .as_ref()
}

/// Construit d'avance le dictionnaire d'une langue, pour que personne n'ait à
/// attendre sa construction devant une fenêtre.
///
/// Appelée au chargement du logiciel, une fois la base ouverte et sa langue
/// connue (demande de Fabrice, 01/08/2026) : les quelques millisecondes de
/// l'analyse se passent alors pendant le démarrage, où l'on attend déjà,
/// plutôt qu'à l'ouverture de la première fenêtre. Rien n'oblige à l'appeler —
/// une langue jamais préparée ouvre son casier toute seule au premier mot
/// qu'on lui demande.
/// **La langue que Radinus parle en ce moment.**
///
/// Elle est posée par [`prepare`] et lue partout ailleurs. `None` tant que
/// personne ne l'a posée : le tout premier instant du démarrage, avant que la
/// configuration ait été lue.
static IN_USE: RwLock<Option<Language>> = RwLock::new(None);

/// La langue en cours, celle dans laquelle tout s'écrit.
///
/// **Elle ne vient plus de la base** (décision de Fabrice, 03/08/2026). Elle
/// vient de `settings/radinus_config.json`, et de nulle part ailleurs. La
/// colonne `Parametres.UtiliseLangue` existe encore et se tient à jour, mais
/// **rien ne la lit pour décider ce qui s'affiche** : c'est une copie pour
/// Radinus 1.9.3, pas une source.
///
/// Ce qu'il y avait avant, et pourquoi ça ne pouvait pas durer : la langue
/// était écrite à deux endroits qui ne se parlaient pas. Le fichier décidait
/// du démarrage, la base décidait dès qu'on l'ouvrait, et changer la langue
/// dans les Préférences n'écrivait que dans la base. Radinus démarrait donc
/// dans l'ancienne langue et basculait dans la nouvelle à l'ouverture, à
/// chaque lancement, pour toujours.
pub fn in_use() -> Language {
    IN_USE
        .read()
        .ok()
        .and_then(|held| *held)
        .unwrap_or(Language::French)
}

/// Pose la langue du logiciel et chauffe son dictionnaire.
///
/// Les deux vont ensemble et c'est voulu : chauffer le dictionnaire d'une
/// langue qui n'est pas celle qu'on va parler ne sert à rien, et parler une
/// langue dont le dictionnaire n'est pas prêt fait attendre la première
/// fenêtre.
pub fn prepare(language: Language) {
    if let Ok(mut held) = IN_USE.write() {
        *held = Some(language);
    }
    let _ = dictionary(language);
}

/// Looks up `key` in `language` and substitutes `args`. Returns `None` when
/// the message does not exist, so a missing translation surfaces as a
/// caller-visible absence rather than a silently wrong string.
pub fn message(language: Language, key: &str, args: Option<&FluentArgs<'_>>) -> Option<String> {
    let bundle = dictionary(language)?;
    let pattern = bundle.get_message(key)?.value()?;
    let mut errors = Vec::new();
    let text = bundle.format_pattern(pattern, args, &mut errors);
    errors.is_empty().then(|| text.into_owned())
}

/// La langue que la base dit parler — `Parametres.UtiliseLangue`, le numéro
/// WinDev. Une base sans ligne `Parametres` (il y en a toujours exactement
/// une, mais un fichier abîmé est un fichier abîmé) parle français.
/// La langue **écrite dans la base**.
///
/// ⚠ **Elle ne décide plus de ce que Radinus affiche** (décision de Fabrice,
/// 03/08/2026 : « on ne tient compte que de ce qui est dans
/// `settings/radinus_config.json`, pas ailleurs »). Ce que la colonne porte
/// sert à deux choses, et à deux choses seulement : rendre une archive
/// lisible par Radinus 1.9.3, et ne rien détruire d'une base venue de
/// Windows. Pour savoir dans quelle langue écrire une phrase, c'est
/// [`in_use`] qu'il faut appeler.
pub fn stored_language(conn: &rusqlite::Connection) -> Language {
    // **Lue en texte, puis convertie.** Demander un entier à SQLite paraissait
    // plus juste ; c'est ce qui a fait « rester en français » le 01/08/2026,
    // une base d'avant la migration portant encore `'7'` et non 7, et la
    // lecture échouant en silence sur toute la ligne. Un `CAST` lit les deux,
    // et une langue illisible reste une langue lisible.
    conn.query_row(
        "SELECT CAST(UtiliseLangue AS TEXT) FROM Parametres WHERE IDParametres = 1",
        [],
        |row| row.get::<_, String>(0),
    )
    .map(|stored| match stored.trim().parse::<i64>() {
        Ok(code) => Language::from_id(code),
        // Les étiquettes de l'ancien format, pour qu'une base non migrée
        // s'ouvre quand même dans sa langue.
        Err(_) => Language::from_tag(stored.trim()),
    })
    .unwrap_or(Language::French)
}

/// Écrit la langue de la base — le numéro WinDev, et rien d'autre.
///
/// C'est le seul chemin vers cette colonne : la langue courante n'est pas un
/// réglage d'interface rangé à côté, c'est une donnée de la base, elle voyage
/// donc avec elle et avec sa sauvegarde.
/// Recopie la langue en cours dans la base.
///
/// **Une copie, pas une source** — voir [`stored_language`]. Elle est
/// rafraîchie à l'ouverture de la base et à chaque changement de langue, pour
/// qu'une sauvegarde emportée sous Windows dise la vérité.
pub fn store_language(conn: &rusqlite::Connection, language: Language) -> rusqlite::Result<()> {
    conn.execute(
        "UPDATE Parametres SET UtiliseLangue = ?1 WHERE IDParametres = 1",
        [language.code()],
    )?;
    Ok(())
}

/// A message with no argument.
pub fn text(language: Language, key: &str) -> String {
    message(language, key, None).unwrap_or_default()
}

/// A message with one argument.
pub fn text_with(language: Language, key: &str, name: &str, value: &str) -> String {
    let mut args = FluentArgs::new();
    args.set(name, value);
    message(language, key, Some(&args)).unwrap_or_default()
}

/// Une phrase à plusieurs trous — « supprimer la base « X » ? écrivez OUI ».
///
/// Le contrôleur ne peut pas fabriquer les arguments lui-même : `FluentArgs`
/// vient de `fluent-bundle`, dont il ne dépend pas et ne doit pas dépendre
/// (08_ARCHITECTURE.md §2.2). Il donne donc des couples nom/valeur, et la
/// phrase se compose ici, du côté qui sait ce qu'est une langue.
pub fn text_with_all(language: Language, key: &str, values: &[(&str, &str)]) -> String {
    let mut args = FluentArgs::new();
    for (name, value) in values {
        args.set(*name, *value);
    }
    message(language, key, Some(&args)).unwrap_or_default()
}

/// A sentence that depends on the nomenclature it is about. `kind` is the
/// nomenclature's key, and every message that takes one selects on it.
pub fn about(language: Language, key: &str, kind: &str) -> String {
    text_with(language, key, "kind", kind)
}

/// A sentence about a nomenclature that also names an element.
pub fn about_label(language: Language, key: &str, kind: &str, label: &str) -> String {
    let mut args = FluentArgs::new();
    args.set("kind", kind);
    args.set("label", label);
    message(language, key, Some(&args)).unwrap_or_default()
}

/// A sentence about a nomenclature that also counts something.
pub fn about_count(language: Language, key: &str, kind: &str, count: i64) -> String {
    let mut args = FluentArgs::new();
    args.set("kind", kind);
    args.set("count", count);
    message(language, key, Some(&args)).unwrap_or_default()
}

/// Any message, with its arguments — text ones and numbers.
///
/// Fluent's own argument type stays inside this crate: the controller has no
/// business depending on the localization library to ask for a sentence.
pub fn message_of(
    language: Language,
    key: &str,
    texts: &[(&str, &str)],
    numbers: &[(&str, i64)],
) -> String {
    let mut args = FluentArgs::new();
    for (name, value) in texts {
        args.set(*name, *value);
    }
    for (name, value) in numbers {
        args.set(*name, *value);
    }
    message(language, key, Some(&args)).unwrap_or_default()
}

/// The exact question asked before deleting a nomenclature element that
/// operations still reference (02_BASE_DE_DONNEES.md §7 rule 5, and the
/// original `Enreg_Supprimer`). `label` is the element being deleted.
pub fn nomenclature_delete_confirmation(language: Language, label: &str) -> String {
    let mut args = FluentArgs::new();
    args.set("label", label);
    message(language, "nomenclature-delete-confirm", Some(&args)).unwrap_or_default()
}

/// The plain question asked before deleting a nomenclature element that
/// nothing references. The original asks nothing at all in that case; Fabrice
/// asked (25/07/2026) that a deletion always be confirmed.
pub fn nomenclature_delete_plain_confirmation(language: Language, label: &str) -> String {
    let mut args = FluentArgs::new();
    args.set("label", label);
    message(language, "nomenclature-delete-plain", Some(&args)).unwrap_or_default()
}

/// Refusal shown when the element to delete is the one its fiche is showing.
/// The fiche is closed first (author's ruling, 25/07/2026): nothing is
/// deleted from under an open window.
pub fn nomenclature_delete_form_open(language: Language, label: &str) -> String {
    let mut args = FluentArgs::new();
    args.set("label", label);
    message(language, "nomenclature-delete-form-open", Some(&args)).unwrap_or_default()
}

/// The "0 = Non précisé" entry every nomenclature combo shows first.
/// Les douze mois, par leur clef Fluent. Ce sont celles que le menu Période
/// emploie déjà : un mois n'est nommé qu'à un seul endroit dans tout Radinus.
const MONTHS: [&str; 12] = [
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
];

/// « août 2026 » — le mois d'une date, écrit dans la langue du logiciel.
///
/// **L'année part en texte et non en nombre.** Fluent met des séparateurs de
/// milliers aux nombres, et l'accueil aurait annoncé « août 2 026 ». Un
/// millésime n'est pas une quantité.
///
/// L'ordre des deux mots vient du fichier de langue et non d'ici : ce n'est
/// pas « mois puis année » partout, et la vue comme le noyau doivent l'ignorer.
pub fn month_and_year(language: Language, day: time_compute::NaiveDate) -> String {
    use time_compute::Datelike;
    let name = text(language, MONTHS[(day.month() as usize - 1).min(11)]);
    message_of(
        language,
        "welcome-month",
        &[("month", name.as_str()), ("year", &day.year().to_string())],
        &[],
    )
}

/// « août » — le mois seul, sans son année.
///
/// Pour l'axe d'une courbe qui se lit mois par mois (F19, 04/08/2026) : la
/// place y est comptée, et l'année s'y répéterait douze fois pour ne rien
/// apprendre — la période est déjà écrite au-dessus, dans la barre de la
/// fenêtre.
///
/// **Les douze noms restent à un seul endroit dans tout Radinus.** C'est la
/// raison d'être de cette fonction plutôt qu'une deuxième table de mois chez
/// le contrôleur : le jour où un mois change d'orthographe dans une langue, il
/// change partout.
pub fn month_name(language: Language, day: time_compute::NaiveDate) -> String {
    use time_compute::Datelike;
    text(language, MONTHS[(day.month() as usize - 1).min(11)])
}

pub fn unspecified_label(language: Language) -> String {
    message(language, "nomenclature-unspecified", None).unwrap_or_default()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn french_bundle_builds_from_the_empty_resource() {
        build_bundle(Language::French).expect("French Fluent bundle should build");
    }

    #[test]
    fn chaque_langue_du_logiciel_analyse_son_fichier() {
        for language in Language::all() {
            build_bundle(language)
                .unwrap_or_else(|e| panic!("le fichier « {} » ne s'analyse pas : {e}", language.tag()));
        }
    }

    /// **Le dictionnaire n'est construit qu'une fois par langue.**
    ///
    /// C'est toute la correction du 01/08/2026, et elle ne se voit pas à
    /// l'œil nu : le logiciel dit exactement la même chose qu'avant, en six
    /// mille fois moins de temps. Ce test tient la garantie par l'adresse —
    /// deux demandes successives doivent recevoir le même dictionnaire, et
    /// non deux copies. S'il échoue, c'est que quelqu'un a remis une
    /// construction par mot demandé, et la lenteur est revenue.
    #[test]
    fn le_dictionnaire_dune_langue_nest_construit_quune_fois() {
        let first = dictionary(Language::French).expect("le français doit s'analyser");
        let second = dictionary(Language::French).expect("le français doit s'analyser");
        assert!(
            std::ptr::eq(first, second),
            "le dictionnaire français est reconstruit à chaque demande"
        );

        // Et chaque langue a le sien : le français ne répond pas pour
        // l'anglais.
        let english = dictionary(Language::English).expect("l'anglais doit s'analyser");
        assert!(!std::ptr::eq(first, english), "les deux langues partagent un casier");
        assert_eq!(text(Language::French, "ui-yes"), "Oui");
        assert_eq!(text(Language::English, "ui-yes"), "Yes");
    }

    /// Préparer une langue d'avance ne change rien à ce qu'elle dit — c'est
    /// le même casier, rempli plus tôt.
    #[test]
    fn preparer_une_langue_ne_change_pas_ce_quelle_dit() {
        prepare(Language::French);
        assert_eq!(text(Language::French, "ui-no"), "Non");
    }

    /// Word for word the message of the original `Enreg_Supprimer`, with no
    /// invisible isolation marks around the substituted label.
    #[test]
    fn the_deletion_question_is_the_authors_own_wording() {
        assert_eq!(
            nomenclature_delete_confirmation(Language::French, "Alimentation"),
            "Des opérations (transactions bancaires) possédant l'attribut de type \
             'Alimentation' ont été détectées. Est ce que vous confirmez vouloir \
             réinitialiser cet attribut ?"
        );
    }

    #[test]
    fn the_plain_deletion_question_names_what_is_going_away() {
        assert_eq!(
            nomenclature_delete_plain_confirmation(Language::French, "Épargne Liquide"),
            "Confirmez-vous la suppression de « Épargne Liquide » ?"
        );
        assert!(!nomenclature_delete_plain_confirmation(Language::English, "X").is_empty());
    }

    #[test]
    fn the_unspecified_entry_exists_in_both_languages() {
        assert_eq!(unspecified_label(Language::French), "Non précisé");
        assert_eq!(unspecified_label(Language::English), "Unspecified");
    }

    #[test]
    fn an_unknown_key_is_reported_as_absent() {
        assert_eq!(message(Language::French, "no-such-message", None), None);
    }

    /// Whole sentences, one branch per nomenclature, in both languages —
    /// nothing assembled from a noun and a gender.
    #[test]
    fn each_nomenclature_has_its_own_sentence_in_both_languages() {
        assert_eq!(
            about(Language::French, "nomenclature-fresh", "category"),
            "Nouvelle catégorie."
        );
        assert_eq!(
            about(Language::French, "nomenclature-fresh", "payee"),
            "Nouveau tiers."
        );
        assert_eq!(
            about(Language::English, "nomenclature-fresh", "payee"),
            "New payee."
        );
        assert_eq!(
            about_count(Language::French, "nomenclature-deleted", "bank", 1),
            "1 banque supprimée."
        );
        assert_eq!(
            about_count(Language::French, "nomenclature-deleted", "payee", 3),
            "3 tiers supprimés."
        );
        assert_eq!(
            about_count(Language::English, "nomenclature-deleted", "budget-line", 2),
            "2 budget lines deleted."
        );
        assert_eq!(
            about_label(
                Language::French,
                "nomenclature-duplicate-name",
                "project",
                "Cuisine"
            ),
            "Il existe déjà un projet du même nom : « Cuisine »."
        );
    }

    /// Toute clef du français doit exister dans **chacune** des autres
    /// langues, et réciproquement : une phrase qui n'existe que dans une
    /// langue est une fenêtre qui se vide dans les autres.
    #[test]
    fn the_two_resources_carry_exactly_the_same_keys() {
        fn keys(source: &str) -> std::collections::BTreeSet<String> {
            let mut found = std::collections::BTreeSet::new();
            for line in source.lines() {
                if line.starts_with(|c: char| c.is_ascii_alphabetic()) {
                    if let Some((key, _)) = line.split_once('=') {
                        found.insert(key.trim().to_string());
                    }
                }
            }
            found
        }
        let french = keys(FR_FTL);
        for other in Language::all() {
            if other == Language::French {
                continue;
            }
            let theirs = keys(other.resource_source());
            let missing: Vec<_> = french.difference(&theirs).collect();
            let extra: Vec<_> = theirs.difference(&french).collect();
            assert!(
                missing.is_empty(),
                "absents de « {} » : {missing:?}",
                other.tag()
            );
            assert!(
                extra.is_empty(),
                "présents dans « {} » et pas en français : {extra:?}",
                other.tag()
            );
        }
    }

    /// **Les numéros sont ceux de WinDev**, et ce test est le seul endroit qui
    /// le garantisse. Les intervertir ferait ouvrir en anglais une sauvegarde
    /// française, sans qu'aucune compilation ne bronche.
    #[test]
    fn chaque_langue_porte_le_numero_windev_de_sa_nation() {
        assert_eq!(Language::French.code(), 5);
        assert_eq!(Language::English.code(), 3);
        assert_eq!(Language::Spanish.code(), 7);
        assert_eq!(Language::Portuguese.code(), 14);
        assert_eq!(Language::Italian.code(), 11);
        assert_eq!(Language::German.code(), 1);
        assert_eq!(Language::Russian.code(), 16);
        assert_eq!(Language::Polish.code(), 34);
        assert_eq!(Language::Ukrainian.code(), 100);
        assert_eq!(Language::Dutch.code(), 12);
        assert_eq!(Language::Swedish.code(), 17);
        assert_eq!(Language::Norwegian.code(), 13);
        assert_eq!(Language::Romanian.code(), 35);
        assert_eq!(Language::Finnish.code(), 8);
        assert_eq!(Language::Icelandic.code(), 10);
        assert_eq!(Language::Hebrew.code(), 28);
        assert_eq!(Language::Arabic.code(), 19);
        assert_eq!(Language::Greek.code(), 27);
        assert_eq!(Language::French.tag(), "fr");
        assert_eq!(Language::English.tag(), "en");
        assert_eq!(Language::Spanish.tag(), "es");
        assert_eq!(Language::Portuguese.tag(), "pt");
        assert_eq!(Language::Italian.tag(), "it");
        assert_eq!(Language::German.tag(), "de");
        assert_eq!(Language::Russian.tag(), "ru");
        assert_eq!(Language::Polish.tag(), "pl");
        assert_eq!(Language::Ukrainian.tag(), "uk");
        assert_eq!(Language::Dutch.tag(), "nl");
        assert_eq!(Language::Swedish.tag(), "sv");
        assert_eq!(Language::Norwegian.tag(), "nb");
        assert_eq!(Language::Romanian.tag(), "ro");
        assert_eq!(Language::Finnish.tag(), "fi");
        assert_eq!(Language::Icelandic.tag(), "is");
        assert_eq!(Language::Hebrew.tag(), "he");
        assert_eq!(Language::Arabic.tag(), "ar");
        assert_eq!(Language::Greek.tag(), "el");
    }

    #[test]
    fn une_base_dit_quelle_langue_elle_parle_par_son_numero() {
        assert_eq!(Language::from_id(5), Language::French);
        assert_eq!(Language::from_id(3), Language::English);
        assert_eq!(Language::from_id(7), Language::Spanish);
        assert_eq!(Language::from_id(14), Language::Portuguese);
        assert_eq!(Language::from_id(11), Language::Italian);
        assert_eq!(Language::from_id(1), Language::German);
        assert_eq!(Language::from_id(16), Language::Russian);
        assert_eq!(Language::from_id(34), Language::Polish);
        assert_eq!(Language::from_id(100), Language::Ukrainian);
        assert_eq!(Language::from_id(12), Language::Dutch);
        assert_eq!(Language::from_id(17), Language::Swedish);
        assert_eq!(Language::from_id(13), Language::Norwegian);
        assert_eq!(Language::from_id(35), Language::Romanian);
        assert_eq!(Language::from_id(8), Language::Finnish);
        assert_eq!(Language::from_id(10), Language::Icelandic);
        assert_eq!(Language::from_id(28), Language::Hebrew);
        assert_eq!(Language::from_id(19), Language::Arabic);
        assert_eq!(Language::from_id(27), Language::Greek);
        // 15 = portugais brésilien : une nation de plus, que nous ne parlons
        // pas encore. Elle ne se confond pas avec le portugais du Portugal.
        assert_eq!(Language::from_id(15), Language::French);
        // 6 = danois chez WinDev, que nous ne parlons pas : une base danoise
        // s'ouvre en français plutôt que dans le vide. Cette ligne disait
        // 1 = allemand jusqu'au 03/08/2026 ; l'allemand est arrivé, et
        // l'exemple du repli a dû déménager.
        assert_eq!(Language::from_id(6), Language::French);
        assert_eq!(Language::from_id(0), Language::French);
    }

    #[test]
    fn une_etiquette_normalisee_designe_aussi_sa_langue() {
        assert_eq!(Language::from_tag("es"), Language::Spanish);
        assert_eq!(Language::from_tag("ES"), Language::Spanish);
        assert_eq!(Language::from_tag("pt"), Language::Portuguese);
        assert_eq!(Language::from_tag("it"), Language::Italian);
        assert_eq!(Language::from_tag("de"), Language::German);
        assert_eq!(Language::from_tag("ru"), Language::Russian);
        assert_eq!(Language::from_tag("pl"), Language::Polish);
        // `uk`, et non `ua` : `ua` est le domaine du pays, pas la langue.
        assert_eq!(Language::from_tag("uk"), Language::Ukrainian);
        assert_eq!(Language::from_tag("ua"), Language::French);
        assert_eq!(Language::from_tag("nl"), Language::Dutch);
        assert_eq!(Language::from_tag("sv"), Language::Swedish);
        // `nb` = bokmål. `nn` est le nynorsk, l'autre norme écrite du
        // norvégien, que Radinus ne parle pas : elle retombe donc sur le
        // français plutôt que d'être servie en bokmål sans le dire.
        assert_eq!(Language::from_tag("nb"), Language::Norwegian);
        assert_eq!(Language::from_tag("ro"), Language::Romanian);
        assert_eq!(Language::from_tag("fi"), Language::Finnish);
        assert_eq!(Language::from_tag("is"), Language::Icelandic);
        // `he`, et non `iw` : `iw` est l'ancien code, abandonné depuis 1989 et
        // encore rendu par de vieux systèmes. Une base qui le porterait
        // s'ouvrirait en français ; c'est la migration qui le rattrape.
        assert_eq!(Language::from_tag("he"), Language::Hebrew);
        assert_eq!(Language::from_tag("ar"), Language::Arabic);
        // `el`, et non `gr` : `gr` est le code du pays, pas de la langue.
        assert_eq!(Language::from_tag("el"), Language::Greek);
        assert_eq!(Language::from_tag("gr"), Language::French);
        assert_eq!(Language::from_tag("nn"), Language::French);
        // `da` = danois, nation 6 : une étiquette que nous ne parlons pas.
        // Cette ligne a déjà dit `de`, puis `nl` — et les deux langues sont
        // arrivées dans la journée du 03/08/2026. L'exemple du repli est la
        // chose la plus instable de ce fichier ; c'est bon signe.
        assert_eq!(Language::from_tag("da"), Language::French);
    }

    /// Le nom d'une langue est écrit **dans cette langue**, et il vient de son
    /// fichier — c'est ce que le menu et le sélecteur du premier lancement
    /// montrent (exigence 01_CAHIER_DES_CHARGES.md §3.5).
    #[test]
    fn chaque_langue_se_nomme_dans_sa_propre_langue() {
        assert_eq!(Language::French.name(), "Français");
        assert_eq!(Language::English.name(), "English");
        assert_eq!(Language::Spanish.name(), "Español");
        assert_eq!(Language::Portuguese.name(), "Português");
        assert_eq!(Language::Italian.name(), "Italiano");
        assert_eq!(Language::German.name(), "Deutsch");
        assert_eq!(Language::Russian.name(), "Русский");
        assert_eq!(Language::Polish.name(), "Polski");
        assert_eq!(Language::Ukrainian.name(), "Українська");
        assert_eq!(Language::Dutch.name(), "Nederlands");
        assert_eq!(Language::Swedish.name(), "Svenska");
        assert_eq!(Language::Norwegian.name(), "Norsk bokmål");
        assert_eq!(Language::Romanian.name(), "Română");
        assert_eq!(Language::Finnish.name(), "Suomi");
        assert_eq!(Language::Icelandic.name(), "Íslenska");
        assert_eq!(Language::Hebrew.name(), "עברית");
        assert_eq!(Language::Arabic.name(), "العربية");
        assert_eq!(Language::Greek.name(), "Ελληνικά");
    }

    /// La liste des langues n'est écrite qu'à un seul endroit, et le menu la
    /// lit là. Dix-huit aujourd'hui ; une de plus se verra ici sans que
    /// personne ait à y penser.
    #[test]
    fn les_langues_du_logiciel_se_comptent_a_un_seul_endroit() {
        let all = Language::all();
        assert_eq!(all.len(), 18);
        assert_eq!(all[0], Language::French);
        let codes: Vec<i64> = all.iter().map(|l| l.code()).collect();
        assert_eq!(
            codes,
            vec![5, 3, 7, 14, 11, 1, 16, 34, 100, 12, 17, 13, 35, 8, 10, 28, 19, 27]
        );
        // Deux langues ne peuvent pas porter le même numéro : ce serait deux
        // bases indiscernables l'une de l'autre.
        let mut sorted = codes.clone();
        sorted.sort_unstable();
        sorted.dedup();
        assert_eq!(sorted.len(), codes.len());
    }

    /// **Aucune langue ne s'assied entre les deux mondes.**
    ///
    /// Le numéro d'une langue vient de la table WinDev (1 à 50 aujourd'hui,
    /// et la table peut s'allonger) ou de la plage de Radinus (100 et
    /// au-dessus). Rien entre les deux : un numéro pris à 60 « parce qu'il
    /// est libre » serait celui que WinDev attribuerait un jour à une langue
    /// qui n'est pas la nôtre, et une base changerait de langue toute seule
    /// à la restauration.
    #[test]
    fn aucun_numero_ne_squatte_la_reserve_de_windev() {
        // Le plus grand numéro de la table du WLangage à ce jour (hindi).
        const DERNIER_WINDEV: i64 = 50;
        for language in Language::all() {
            let code = language.code();
            assert!(
                code <= DERNIER_WINDEV || code >= FIRST_RADINUS_CODE,
                "{} porte le numéro {code} : ni WinDev, ni Radinus",
                language.tag()
            );
        }
    }
}
