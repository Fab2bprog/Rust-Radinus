//! « Recherche des doublons » (menu Comptes) — le moteur, sans fenêtre.
//!
//! Conception arrêtée avec Fabrice le 29/10/2026. Un doublon, c'est **le même
//! montant**, des **dates proches** et des **textes qui se ressemblent** — le
//! libellé, mais aussi la référence paiement, où le MEMO d'un relevé OFX
//! arrive depuis P-75. Le moteur ne fait que proposer : il range les
//! opérations soupçonnées en groupes, chaque groupe avec un niveau, et c'est
//! l'utilisateur qui décide dans la fenêtre.
//!
//! Les règles, telles qu'elles ont été arrêtées :
//!
//!   * **Les mères seulement.** Une sous-opération n'est qu'une part du montant
//!     de sa mère ; la comparer serait comparer des morceaux.
//!   * **Le montant au centime.** Aucune tolérance : elle ouvrirait la porte à
//!     des faux doublons en masse (Fabrice, 29/10/2026).
//!   * **Un écart de dates borné**, réglé dans les préférences.
//!   * **Les textes comparés en croisé** : libellé contre libellé, et libellé
//!     contre référence dans les deux sens — le même texte de la banque
//!     arrive dans l'un ou dans l'autre selon le réglage d'import choisi. On
//!     garde la meilleure ressemblance. Référence contre référence a sa règle
//!     à elle, ci-dessous.
//!   * **Un nettoyage avant de comparer** : les dates écrites dans le texte
//!     (« 27/10/26 », « 27.10.2026 », « 27-10 », « 27_10_26 », « 271026 »),
//!     les heures (« 08H27 »), les majuscules, les accents, la ponctuation et
//!     les espaces. Les dates retirées ne sont pas perdues : deux textes qui
//!     portent chacun une date, et pas la même, parlent de deux achats.
//!   * **Une référence identique** fait monter le niveau ; **deux références
//!     différentes** mettent le groupe « à vérifier » (Fabrice, 29/10/2026).
//!
//! Rien ici n'écrit dans la base.

use crate::domain::NaiveDate;
use crate::operations::{self, OperationRow};
use rusqlite::{Connection, Result};
use std::collections::HashMap;

/// L'écart de dates le plus grand que les préférences acceptent.
pub const MAX_DAYS: i64 = 15;

/// Le niveau d'un groupe, du moins sûr au plus sûr — l'ordre des variantes
/// est celui de la comparaison.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum Level {
    /// Même montant, dates proches, et rien d'autre ne l'appuie — ou une
    /// référence, ou une date écrite dans le texte, qui le contredit.
    ToVerify,
    Possible,
    Probable,
    Identical,
}

impl Level {
    /// Les quatre niveaux, du plus sûr au moins sûr : l'ordre où les groupes
    /// se forment et où la fenêtre les montre.
    pub const ALL: [Level; 4] = [
        Level::Identical,
        Level::Probable,
        Level::Possible,
        Level::ToVerify,
    ];

    fn up(self) -> Level {
        match self {
            Level::ToVerify => Level::Possible,
            Level::Possible => Level::Probable,
            Level::Probable | Level::Identical => Level::Identical,
        }
    }

    /// Le mot qui voyage vers la fenêtre et dans la configuration.
    pub fn key(self) -> &'static str {
        match self {
            Level::Identical => "identical",
            Level::Probable => "probable",
            Level::Possible => "possible",
            Level::ToVerify => "to-verify",
        }
    }

    pub fn from_key(key: &str) -> Option<Level> {
        Level::ALL.into_iter().find(|level| level.key() == key)
    }
}

/// La ressemblance des textes demandée : trois niveaux plutôt qu'un
/// pourcentage, que personne ne saurait régler.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum Likeness {
    Strict,
    #[default]
    Normal,
    Large,
}

impl Likeness {
    /// La ressemblance à partir de laquelle deux textes « se ressemblent ».
    pub fn threshold(self) -> f64 {
        match self {
            Likeness::Strict => 0.85,
            Likeness::Normal => 0.70,
            Likeness::Large => 0.55,
        }
    }

    pub fn key(self) -> &'static str {
        match self {
            Likeness::Strict => "strict",
            Likeness::Normal => "normal",
            Likeness::Large => "large",
        }
    }

    pub fn from_key(key: &str) -> Option<Likeness> {
        [Likeness::Strict, Likeness::Normal, Likeness::Large]
            .into_iter()
            .find(|likeness| likeness.key() == key)
    }
}

/// Ce que la recherche prend des préférences « Détection des doublons ».
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Settings {
    /// De 0 (le même jour seulement) à [`MAX_DAYS`].
    pub max_days: i64,
    pub likeness: Likeness,
    pub compare_label: bool,
    pub compare_reference: bool,
}

impl Default for Settings {
    fn default() -> Self {
        Settings {
            max_days: 5,
            likeness: Likeness::Normal,
            compare_label: true,
            compare_reference: true,
        }
    }
}

/// Que faire de la ventilation d'une opération supprimée, quand l'opération
/// gardée n'en a pas (Fabrice, 29/10/2026 : « c'est l'utilisateur qui décide
/// et c'est un paramètre de plus dans les préférences »).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum Ventilation {
    /// La faire passer sur l'opération gardée — les montants sont égaux, elle
    /// tombe juste.
    #[default]
    TakeOver,
    /// Ne rien reprendre, et le dire dans la confirmation.
    WarnOnly,
}

impl Ventilation {
    pub fn key(self) -> &'static str {
        match self {
            Ventilation::TakeOver => "take-over",
            Ventilation::WarnOnly => "warn",
        }
    }

    pub fn from_key(key: &str) -> Option<Ventilation> {
        [Ventilation::TakeOver, Ventilation::WarnOnly]
            .into_iter()
            .find(|choice| choice.key() == key)
    }
}

/// Les préférences « Détection des doublons » : ce que la recherche prend, les
/// niveaux que la fenêtre montre à l'ouverture, et le sort d'une ventilation.
///
/// **Des réglages du logiciel**, dans `settings/radinus_config.json` comme
/// ceux des relevés OFX et QIF : ils disent comment l'utilisateur veut
/// chercher, pas ce que contiennent ses comptes. La feuille vit sans base.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Preferences {
    pub settings: Settings,
    /// Dans l'ordre de [`Level::ALL`]. Jamais vide : l'enregistrement refuse
    /// une liste vide, et la lecture la tient pour « tous ».
    pub levels: Vec<Level>,
    pub ventilation: Ventilation,
}

impl Default for Preferences {
    fn default() -> Self {
        Preferences {
            settings: Settings::default(),
            levels: Level::ALL.to_vec(),
            ventilation: Ventilation::default(),
        }
    }
}

impl Preferences {
    /// Lit ce que la configuration porte. **Chaque réglage illisible prend sa
    /// valeur par défaut, et lui seul** : un fichier que l'utilisateur a le
    /// droit d'ouvrir ne doit pas faire perdre les autres réglages.
    pub fn from_json(value: Option<&serde_json::Value>) -> Preferences {
        let defaults = Preferences::default();
        let Some(value) = value else {
            return defaults;
        };
        let text = |name: &str| value.get(name).and_then(|v| v.as_str());
        let flag = |name: &str, default: bool| {
            value.get(name).and_then(|v| v.as_bool()).unwrap_or(default)
        };
        let mut levels: Vec<Level> = value
            .get("levels")
            .and_then(|v| v.as_array())
            .map(|keys| {
                Level::ALL
                    .into_iter()
                    .filter(|level| keys.iter().any(|key| key.as_str() == Some(level.key())))
                    .collect()
            })
            .unwrap_or_default();
        if levels.is_empty() {
            levels = defaults.levels.clone();
        }
        Preferences {
            settings: Settings {
                max_days: value
                    .get("max_days")
                    .and_then(|v| v.as_i64())
                    .map_or(defaults.settings.max_days, |days| days.clamp(0, MAX_DAYS)),
                likeness: text("likeness")
                    .and_then(Likeness::from_key)
                    .unwrap_or(defaults.settings.likeness),
                compare_label: flag("compare_label", defaults.settings.compare_label),
                compare_reference: flag("compare_reference", defaults.settings.compare_reference),
            },
            levels,
            ventilation: text("ventilation")
                .and_then(Ventilation::from_key)
                .unwrap_or(defaults.ventilation),
        }
    }

    pub fn to_json(&self) -> serde_json::Value {
        serde_json::json!({
            "max_days": self.settings.max_days.clamp(0, MAX_DAYS),
            "likeness": self.settings.likeness.key(),
            "compare_label": self.settings.compare_label,
            "compare_reference": self.settings.compare_reference,
            "levels": self.levels.iter().map(|level| level.key()).collect::<Vec<_>>(),
            "ventilation": self.ventilation.key(),
        })
    }
}

/// Une opération candidate : la ligne telle que la liste la montre, plus ce
/// que la suppression aura besoin de savoir.
#[derive(Debug, Clone, PartialEq)]
pub struct Member {
    pub operation: OperationRow,
    /// Elle porte des sous-opérations.
    pub ventilated: bool,
    /// L'identifiant de la banque. Le même des deux côtés, c'est certain.
    pub fitid: String,
}

/// Des opérations soupçonnées d'être la même : doublon, triplon, X4…
#[derive(Debug, Clone, PartialEq)]
pub struct Group {
    pub level: Level,
    /// Par date, puis par clef.
    pub members: Vec<Member>,
}

impl Group {
    /// La somme de toutes les opérations du groupe.
    pub fn total(&self) -> i64 {
        self.members.iter().map(|m| m.operation.amount).sum()
    }

    /// Ce qui restera une fois le groupe traité : une seule opération. Les
    /// montants sont identiques, si bien que le résultat ne dépend pas de la
    /// ligne gardée — il se connaît avant même de cocher.
    pub fn after(&self) -> i64 {
        self.members.first().map_or(0, |m| m.operation.amount)
    }
}

/// Cherche les doublons d'un compte entre deux dates (incluses).
pub fn search(
    conn: &Connection,
    account_id: i64,
    from: NaiveDate,
    to: NaiveDate,
    settings: &Settings,
) -> Result<Vec<Group>> {
    let trees = operations::list_for_account(conn, account_id, from, to, None, None)?;
    let mut fitids: HashMap<i64, String> = HashMap::new();
    let mut statement = conn.prepare(
        "SELECT IDOperation, FitID FROM Operation
         WHERE IDCompte = ?1 AND IDOperationParent = 0 AND COALESCE(FitID, '') <> ''",
    )?;
    for row in statement.query_map([account_id], |row| {
        Ok((row.get::<_, i64>(0)?, row.get::<_, String>(1)?))
    })? {
        let (id, fitid) = row?;
        fitids.insert(id, fitid);
    }

    let candidates = trees
        .into_iter()
        .map(|tree| Member {
            ventilated: !tree.children.is_empty(),
            fitid: fitids.remove(&tree.parent.id).unwrap_or_default(),
            operation: tree.parent,
        })
        .collect();
    Ok(find(candidates, settings))
}

/// Range les candidates en groupes. Sans base : c'est ce que les tests
/// éprouvent.
///
/// **Les groupes se forment du plus sûr au moins sûr, et une opération
/// n'appartient qu'à un groupe.** Un vrai doublon reste « identique » même si
/// une troisième opération de même montant traîne à côté : elle n'entre pas
/// dans son groupe pour l'affaiblir, ni pour être supprimée avec lui. À un
/// même niveau, les liens s'enchaînent : A ressemble à B, B à C, et les trois
/// font un triplon.
pub fn find(candidates: Vec<Member>, settings: &Settings) -> Vec<Group> {
    let max_days = settings.max_days.clamp(0, MAX_DAYS);
    let texts: Vec<Texts> = candidates.iter().map(Texts::of).collect();

    // Les paires : même montant, dates assez proches.
    let mut by_amount: HashMap<i64, Vec<usize>> = HashMap::new();
    for (index, member) in candidates.iter().enumerate() {
        if member.operation.date.is_some() {
            by_amount
                .entry(member.operation.amount)
                .or_default()
                .push(index);
        }
    }
    let mut links: Vec<(usize, usize, Level)> = Vec::new();
    for indexes in by_amount.values() {
        for (position, &a) in indexes.iter().enumerate() {
            for &b in &indexes[position + 1..] {
                let (Some(day_a), Some(day_b)) =
                    (candidates[a].operation.date, candidates[b].operation.date)
                else {
                    continue;
                };
                let gap = (day_a - day_b).num_days().abs();
                if gap > max_days {
                    continue;
                }
                let level = pair_level(
                    &candidates[a],
                    &texts[a],
                    &candidates[b],
                    &texts[b],
                    gap == 0,
                    settings,
                );
                links.push((a, b, level));
            }
        }
    }

    let mut taken = vec![false; candidates.len()];
    let mut groups: Vec<(Level, Vec<usize>)> = Vec::new();
    for level in Level::ALL {
        let mut parent: Vec<usize> = (0..candidates.len()).collect();
        for &(a, b, link) in &links {
            if link == level && !taken[a] && !taken[b] {
                let (root_a, root_b) = (root(&mut parent, a), root(&mut parent, b));
                if root_a != root_b {
                    parent[root_b] = root_a;
                }
            }
        }
        let mut components: HashMap<usize, Vec<usize>> = HashMap::new();
        for &(a, b, link) in &links {
            if link == level && !taken[a] && !taken[b] {
                for index in [a, b] {
                    let top = root(&mut parent, index);
                    let members = components.entry(top).or_default();
                    if !members.contains(&index) {
                        members.push(index);
                    }
                }
            }
        }
        for members in components.into_values() {
            for &index in &members {
                taken[index] = true;
            }
            groups.push((level, members));
        }
    }

    let order = |index: &usize| {
        (
            candidates[*index].operation.date,
            candidates[*index].operation.id,
        )
    };
    let mut groups: Vec<(Level, Vec<usize>)> = groups
        .into_iter()
        .map(|(level, mut members)| {
            members.sort_by_key(order);
            (level, members)
        })
        .collect();
    groups.sort_by(|(level_a, a), (level_b, b)| {
        level_b
            .cmp(level_a)
            .then_with(|| order(&a[0]).cmp(&order(&b[0])))
    });

    let mut slots: Vec<Option<Member>> = candidates.into_iter().map(Some).collect();
    groups
        .into_iter()
        .map(|(level, members)| Group {
            level,
            members: members
                .into_iter()
                .filter_map(|index| slots[index].take())
                .collect(),
        })
        .collect()
}

fn root(parent: &mut [usize], mut index: usize) -> usize {
    while parent[index] != index {
        parent[index] = parent[parent[index]];
        index = parent[index];
    }
    index
}

/// Les textes d'une opération, nettoyés une fois pour toutes.
struct Texts {
    label: Cleaned,
    reference: Cleaned,
}

impl Texts {
    fn of(member: &Member) -> Texts {
        Texts {
            label: clean(&member.operation.label),
            reference: clean(&member.operation.reference),
        }
    }
}

/// Le niveau de deux opérations de même montant, assez proches dans le temps.
fn pair_level(
    a: &Member,
    texts_a: &Texts,
    b: &Member,
    texts_b: &Texts,
    same_day: bool,
    settings: &Settings,
) -> Level {
    // L'identifiant de la banque, « si la banque a bien fait son boulot »,
    // est une certitude — comme à l'import d'un relevé.
    let fitid = a.fitid.trim();
    if !fitid.is_empty() && fitid == b.fitid.trim() {
        return Level::Identical;
    }

    // Référence contre référence n'entre pas ici : elle a sa propre règle
    // plus bas (identique, elle fait monter d'un cran ; différente, elle
    // contredit). La compter deux fois ferait d'une référence générique
    // répétée — « CB », « PRLV » — un doublon presque certain.
    let mut compared: Vec<(&Cleaned, &Cleaned)> = Vec::new();
    if settings.compare_label {
        compared.push((&texts_a.label, &texts_b.label));
    }
    if settings.compare_label && settings.compare_reference {
        compared.push((&texts_a.label, &texts_b.reference));
        compared.push((&texts_a.reference, &texts_b.label));
    }
    let best = compared
        .iter()
        .map(|(one, other)| similarity(&one.key, &other.key))
        .fold(0.0_f64, f64::max);

    let threshold = settings.likeness.threshold();
    let mut level = if best >= 1.0 {
        if same_day {
            Level::Identical
        } else {
            Level::Probable
        }
    } else if best >= threshold {
        if same_day {
            Level::Probable
        } else {
            Level::Possible
        }
    } else {
        Level::ToVerify
    };

    let mut against = false;
    if settings.compare_reference {
        let (one, other) = (&texts_a.reference.key, &texts_b.reference.key);
        if !one.is_empty() && !other.is_empty() {
            // Deux références qui ne diffèrent que par la forme — tronquées,
            // ponctuées autrement — ne se contredisent pas. Des chiffres
            // différents, si : 9506038 et 9506039 sont deux chèques.
            let digits = |key: &str| key.chars().filter(char::is_ascii_digit).collect::<String>();
            let (digits_one, digits_other) = (digits(one), digits(other));
            if one == other {
                level = level.up();
            } else if similarity(one, other) < threshold
                || (!digits_one.is_empty()
                    && !digits_other.is_empty()
                    && digits_one != digits_other)
            {
                against = true;
            }
        }
    }

    // Les dates écrites dans les textes comparés : la même des deux côtés
    // appuie, deux dates différentes contredisent — deux passages à la même
    // boulangerie, deux jours de suite, ne sont pas un doublon.
    let written = |texts: &Texts| -> Vec<(u32, u32)> {
        let mut days = Vec::new();
        if settings.compare_label {
            days.extend(&texts.label.dates);
        }
        if settings.compare_reference {
            days.extend(&texts.reference.dates);
        }
        days
    };
    let (days_a, days_b) = (written(texts_a), written(texts_b));
    if !days_a.is_empty() && !days_b.is_empty() {
        if days_a.iter().any(|day| days_b.contains(day)) {
            level = level.up();
        } else {
            against = true;
        }
    }

    if against {
        level = level.min(Level::ToVerify);
    }
    level
}

/// Un texte nettoyé : la clef à comparer, et les dates qu'on en a retirées
/// (jour, mois — l'année s'écrit trop différemment pour compter).
#[derive(Debug, Clone, PartialEq, Default)]
struct Cleaned {
    key: String,
    dates: Vec<(u32, u32)>,
}

/// Retire les dates et les heures d'un texte, puis ne garde que les lettres et
/// les chiffres, sans accents ni majuscules — la règle de [`crate::text`].
fn clean(raw: &str) -> Cleaned {
    let chars: Vec<char> = raw.chars().collect();
    let mut kept = String::with_capacity(raw.len());
    let mut dates = Vec::new();
    let mut index = 0;
    while index < chars.len() {
        let starts_number =
            chars[index].is_ascii_digit() && (index == 0 || !chars[index - 1].is_ascii_digit());
        if starts_number {
            if let Some((end, date)) = date_at(&chars, index) {
                if let Some(date) = date {
                    dates.push(date);
                }
                kept.push(' ');
                index = end;
                continue;
            }
        }
        kept.push(chars[index]);
        index += 1;
    }
    Cleaned {
        key: crate::text::french_sort_key(&kept),
        dates,
    }
}

/// Une date ou une heure qui commence en `start`, au début d'un nombre :
/// où elle finit, et le jour et le mois quand c'est une date (rien pour une
/// heure).
#[allow(clippy::type_complexity)]
fn date_at(chars: &[char], start: usize) -> Option<(usize, Option<(u32, u32)>)> {
    let digits = |from: usize| -> usize {
        chars[from..]
            .iter()
            .take_while(|c| c.is_ascii_digit())
            .count()
    };
    let number = |from: usize, length: usize| -> u32 {
        chars[from..from + length]
            .iter()
            .fold(0, |value, c| value * 10 + c.to_digit(10).unwrap_or(0))
    };
    let valid = |day: u32, month: u32| (1..=31).contains(&day) && (1..=12).contains(&month);
    let ends_number = |end: usize| end >= chars.len() || !chars[end].is_ascii_alphanumeric();
    let preceded_by_letter = start > 0 && chars[start - 1].is_alphabetic();

    let first = digits(start);
    let after_first = start + first;

    // Une heure : 08H27, 8h27, 08:27.
    if (1..=2).contains(&first) && after_first < chars.len() {
        let mark = chars[after_first];
        if matches!(mark, 'h' | 'H' | ':') && after_first + 1 < chars.len() {
            let minutes = digits(after_first + 1);
            let end = after_first + 1 + minutes;
            if minutes == 2
                && number(start, first) <= 23
                && number(after_first + 1, 2) <= 59
                && ends_number(end)
            {
                return Some((end, None));
            }
        }
    }

    // Avec séparateurs : 27/10/26, 27.10.2026, 27-10, 27_10_26, 2026-10-27.
    if after_first < chars.len() && matches!(chars[after_first], '/' | '.' | '-' | '_') {
        let separator = chars[after_first];
        let second_start = after_first + 1;
        let second = digits(second_start);
        let after_second = second_start + second;
        if (1..=2).contains(&second) {
            let mut third = 0;
            if after_second < chars.len() && chars[after_second] == separator {
                third = digits(after_second + 1);
            }
            if first == 4 && third > 0 && third <= 2 {
                // Année d'abord : 2026-10-27.
                let (day, month) = (
                    number(after_second + 1, third),
                    number(second_start, second),
                );
                let end = after_second + 1 + third;
                if valid(day, month) && ends_number(end) {
                    return Some((end, Some((day, month))));
                }
            } else if (1..=2).contains(&first) {
                let (day, month) = (number(start, first), number(second_start, second));
                if valid(day, month) {
                    if third == 2 || third == 4 {
                        let end = after_second + 1 + third;
                        if ends_number(end) {
                            return Some((end, Some((day, month))));
                        }
                    } else if ends_number(after_second)
                        && !(after_second < chars.len() && chars[after_second] == separator)
                    {
                        return Some((after_second, Some((day, month))));
                    }
                }
            }
        }
    }

    // Tout collé : 271026 ou 27102026 — seul, pas collé à une lettre (une
    // carte « X2723… » n'est pas une date).
    if (first == 6 || first == 8) && !preceded_by_letter && ends_number(after_first) {
        let (day, month) = (number(start, 2), number(start + 2, 2));
        if valid(day, month) {
            return Some((after_first, Some((day, month))));
        }
    }
    None
}

/// La ressemblance de deux clefs nettoyées, de 0 à 1. Seules deux clefs
/// identiques valent 1.
///
/// On compare les paires de lettres qui se suivent, ce qui ne dépend ni des
/// espaces ni de l'ordre exact des mots. Un texte court **contenu** dans un
/// long — « Boulangerie » saisi à la main, « CARTE X2723 BOULANGERIE DUPONT »
/// importé — compte aussi, mais d'autant moins qu'il est court : « CARTE »
/// seul se retrouve dans toutes les opérations par carte et ne prouve rien.
pub fn similarity(one: &str, other: &str) -> f64 {
    if one.is_empty() || other.is_empty() {
        return 0.0;
    }
    if one == other {
        return 1.0;
    }
    let pairs = |text: &str| -> HashMap<(char, char), usize> {
        let chars: Vec<char> = text.chars().collect();
        let mut counted = HashMap::new();
        for window in chars.windows(2) {
            *counted.entry((window[0], window[1])).or_insert(0) += 1;
        }
        counted
    };
    let (pairs_one, pairs_other) = (pairs(one), pairs(other));
    let count = |pairs: &HashMap<(char, char), usize>| pairs.values().sum::<usize>();
    let (count_one, count_other) = (count(&pairs_one), count(&pairs_other));
    if count_one == 0 || count_other == 0 {
        return 0.0;
    }
    let common: usize = pairs_one
        .iter()
        .map(|(pair, n)| (*n).min(*pairs_other.get(pair).unwrap_or(&0)))
        .sum();
    let dice = 2.0 * common as f64 / (count_one + count_other) as f64;
    let shorter = one.chars().count().min(other.chars().count()) as f64;
    let contained =
        0.9 * common as f64 / count_one.min(count_other) as f64 * (shorter / 10.0).min(1.0);
    dice.max(contained).min(0.99)
}

// --- Le traitement : reprise et suppression (étape E, 29/10/2026) ---------
//
// Rien de ce qui précède n'écrit. Ce qui suit écrit, **d'un seul bloc** : la
// reprise de ce qui manque et les suppressions passent dans une transaction,
// et une écriture qui échoue n'en laisse aucune derrière elle.

/// Ce que l'utilisateur a décidé pour un groupe : les lignes cochées « Garder
/// celle-ci » et celles qui partent.
#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct Decision {
    pub kept: Vec<i64>,
    pub doomed: Vec<i64>,
}

/// Ce qu'une ligne gardée peut reprendre d'une ligne qui part.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Field {
    Category,
    Assignment,
    PaymentMode,
    Payee,
    Project,
    Cheque,
    Reference,
    Fitid,
    Statement,
    Comment,
    Attachments,
    Ventilation,
}

impl Field {
    /// La clef du mot qui le nomme, dans la confirmation et le journal.
    pub fn key(self) -> &'static str {
        match self {
            Field::Category => "duplicates-field-category",
            Field::Assignment => "duplicates-field-assignment",
            Field::PaymentMode => "duplicates-field-payment-mode",
            Field::Payee => "duplicates-field-payee",
            Field::Project => "duplicates-field-project",
            Field::Cheque => "duplicates-field-cheque",
            Field::Reference => "duplicates-field-reference",
            Field::Fitid => "duplicates-field-fitid",
            Field::Statement => "duplicates-field-statement",
            Field::Comment => "duplicates-field-comment",
            Field::Attachments => "duplicates-field-attachments",
            Field::Ventilation => "duplicates-field-ventilation",
        }
    }

    /// La colonne de `Operation` qui le porte, pour les champs qui ne sont
    /// qu'une colonne.
    fn column(self) -> Option<&'static str> {
        match self {
            Field::Category => Some("IDCategorie"),
            Field::Assignment => Some("IDAffectation"),
            Field::PaymentMode => Some("IDModeOperation"),
            Field::Payee => Some("IDTiers"),
            Field::Project => Some("IDProjets"),
            Field::Cheque => Some("IDCheque"),
            Field::Reference => Some("ReferencePaiement"),
            Field::Fitid => Some("FitID"),
            Field::Statement => Some("NumRelevBanque"),
            Field::Comment | Field::Attachments | Field::Ventilation => None,
        }
    }
}

/// Ce que la confirmation doit signaler.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Warning {
    /// Plusieurs lignes gardées : on ne sait pas laquelle reprendrait, rien
    /// n'est repris (Fabrice, 29/10/2026).
    SeveralKept,
    /// La ligne gardée est ventilée elle aussi : la ventilation de celle qui
    /// part s'en va avec elle.
    BothVentilated,
    /// La ventilation de la ligne qui part s'en va avec elle — préférence
    /// « Avertir seulement », ou plusieurs lignes gardées.
    VentilationLost,
}

/// Ce qui sera fait d'un groupe.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct GroupPlan {
    pub kept: Vec<i64>,
    pub doomed: Vec<i64>,
    /// La ligne gardée qui reprend — seulement quand elle est seule.
    pub taker: Option<i64>,
    /// Ce qu'elle reprend, et de quelle ligne.
    pub takes: Vec<(Field, i64)>,
    /// Ce que la confirmation signale, et l'opération concernée.
    pub warnings: Vec<(Warning, i64)>,
}

/// Ce qu'une opération porte, pour savoir ce qui lui manque.
struct Snapshot {
    columns: HashMap<&'static str, String>,
    comment: bool,
    attachments: bool,
    children: bool,
}

impl Snapshot {
    fn read(conn: &Connection, id: i64) -> Result<Snapshot> {
        let mut columns = HashMap::new();
        for field in [
            Field::Category,
            Field::Assignment,
            Field::PaymentMode,
            Field::Payee,
            Field::Project,
            Field::Cheque,
            Field::Reference,
            Field::Fitid,
            Field::Statement,
        ] {
            let column = field.column().unwrap_or_default();
            let value: String = conn.query_row(
                &format!("SELECT COALESCE(CAST({column} AS TEXT), '') FROM Operation WHERE IDOperation = ?1"),
                [id],
                |row| row.get(0),
            )?;
            columns.insert(column, value);
        }
        let comment: String = conn
            .query_row(
                "SELECT COALESCE(CommentaireTxt, '') FROM Commentaire WHERE IDOperation = ?1",
                [id],
                |row| row.get(0),
            )
            .unwrap_or_default();
        let count = |sql: &str| -> Result<i64> { conn.query_row(sql, [id], |row| row.get(0)) };
        Ok(Snapshot {
            columns,
            comment: !comment.trim().is_empty(),
            attachments: count("SELECT COUNT(*) FROM PiecesJointes WHERE IDOperation = ?1")? > 0,
            children: count("SELECT COUNT(*) FROM Operation WHERE IDOperationParent = ?1")? > 0,
        })
    }

    /// Le champ est-il renseigné ? Un lien à `0` est « non précisé », un
    /// texte blanc est vide.
    fn has(&self, field: Field) -> bool {
        match field {
            Field::Comment => self.comment,
            Field::Attachments => self.attachments,
            Field::Ventilation => self.children,
            _ => {
                let value = field
                    .column()
                    .and_then(|column| self.columns.get(column))
                    .map(|value| value.trim().to_string())
                    .unwrap_or_default();
                !value.is_empty() && value != "0"
            }
        }
    }
}

/// Prépare le traitement **sans rien écrire** : ce qui sera repris, par quelle
/// ligne, et ce que la confirmation doit dire.
///
/// `None` quand les décisions ne correspondent plus à la base — une opération
/// supprimée ou déplacée ailleurs depuis la recherche, une ligne nommée deux
/// fois, un groupe sans ligne gardée ou sans ligne qui part. La fenêtre doit
/// alors relancer la recherche ; on ne supprime jamais sur la foi d'un écran
/// périmé.
pub fn plan(
    conn: &Connection,
    account_id: i64,
    decisions: &[Decision],
    ventilation: Ventilation,
) -> Result<Option<Vec<GroupPlan>>> {
    let mut seen = std::collections::HashSet::new();
    for decision in decisions {
        if decision.kept.is_empty() || decision.doomed.is_empty() {
            return Ok(None);
        }
        for id in decision.kept.iter().chain(&decision.doomed) {
            if !seen.insert(*id) {
                return Ok(None);
            }
            let found: Option<(i64, i64)> = conn
                .query_row(
                    "SELECT IDCompte, IDOperationParent FROM Operation WHERE IDOperation = ?1",
                    [id],
                    |row| Ok((row.get(0)?, row.get(1)?)),
                )
                .ok();
            if found != Some((account_id, 0)) {
                return Ok(None);
            }
        }
    }

    let mut plans = Vec::new();
    for decision in decisions {
        let mut plan = GroupPlan {
            kept: decision.kept.clone(),
            doomed: decision.doomed.clone(),
            taker: None,
            takes: Vec::new(),
            warnings: Vec::new(),
        };
        let doomed: Vec<(i64, Snapshot)> = decision
            .doomed
            .iter()
            .map(|id| Snapshot::read(conn, *id).map(|snapshot| (*id, snapshot)))
            .collect::<Result<_>>()?;

        if decision.kept.len() == 1 {
            let taker = decision.kept[0];
            let kept = Snapshot::read(conn, taker)?;
            plan.taker = Some(taker);
            for field in [
                Field::Category,
                Field::Assignment,
                Field::PaymentMode,
                Field::Payee,
                Field::Project,
                Field::Cheque,
                Field::Reference,
                Field::Fitid,
                Field::Statement,
                Field::Comment,
            ] {
                if kept.has(field) {
                    continue;
                }
                if let Some((source, _)) = doomed.iter().find(|(_, one)| one.has(field)) {
                    plan.takes.push((field, *source));
                }
            }
            // Les pièces jointes s'ajoutent : elles ne remplacent rien.
            if let Some((source, _)) = doomed.iter().find(|(_, one)| one.attachments) {
                plan.takes.push((Field::Attachments, *source));
            }
            // La ventilation : une seule, celle de la première ligne qui en
            // porte une, et seulement si la gardée n'en a pas.
            let mut moved = None;
            for (id, one) in &doomed {
                if !one.children {
                    continue;
                }
                if kept.children {
                    plan.warnings.push((Warning::BothVentilated, *id));
                } else if moved.is_none() && ventilation == Ventilation::TakeOver {
                    moved = Some(*id);
                    plan.takes.push((Field::Ventilation, *id));
                } else {
                    plan.warnings.push((Warning::VentilationLost, *id));
                }
            }
        } else {
            plan.warnings.push((Warning::SeveralKept, decision.kept[0]));
            for (id, one) in &doomed {
                if one.children {
                    plan.warnings.push((Warning::VentilationLost, *id));
                }
            }
        }
        plans.push(plan);
    }
    Ok(Some(plans))
}

/// Exécute le traitement préparé par [`plan`] : la reprise, puis les
/// suppressions, puis les soldes — **tout ou rien**.
///
/// Rend le nombre de lignes supprimées, sous-opérations comprises.
pub fn apply(conn: &mut Connection, account_id: i64, plans: &[GroupPlan]) -> Result<usize> {
    let transaction = conn.transaction()?;
    let mut ventilated = Vec::new();
    for plan in plans {
        let Some(taker) = plan.taker else { continue };
        for (field, source) in &plan.takes {
            match field {
                Field::Comment => {
                    transaction
                        .execute("DELETE FROM Commentaire WHERE IDOperation = ?1", [taker])?;
                    transaction.execute(
                        "UPDATE Commentaire SET IDOperation = ?1 WHERE IDOperation = ?2",
                        [taker, *source],
                    )?;
                }
                // Toutes les pièces jointes de toutes les lignes qui partent :
                // seul leur rattachement change, les fichiers ne bougent pas.
                Field::Attachments => {
                    for doomed in &plan.doomed {
                        transaction.execute(
                            "UPDATE PiecesJointes SET IDOperation = ?1 WHERE IDOperation = ?2",
                            [taker, *doomed],
                        )?;
                    }
                }
                Field::Ventilation => {
                    transaction.execute(
                        "UPDATE Operation SET IDOperationParent = ?1 WHERE IDOperationParent = ?2",
                        [taker, *source],
                    )?;
                    ventilated.push(taker);
                }
                _ => {
                    let column = field.column().unwrap_or_default();
                    transaction.execute(
                        &format!(
                            "UPDATE Operation SET {column} =
                                 (SELECT {column} FROM Operation WHERE IDOperation = ?2)
                             WHERE IDOperation = ?1"
                        ),
                        [taker, *source],
                    )?;
                }
            }
        }
    }

    // Les suppressions : une mère emporte ce qui lui reste de filles, comme
    // dans la liste des opérations ; ses commentaires et ses pièces jointes
    // non repris partent avec elle par la cascade.
    let mut gone = 0;
    for plan in plans {
        for doomed in &plan.doomed {
            gone += transaction.execute(
                "DELETE FROM Operation WHERE IDOperation = ?1 OR IDOperationParent = ?1",
                [doomed],
            )?;
        }
    }

    // Une ventilation reprise : le complément, la synchronisation des filles
    // sur leur nouvelle mère et le drapeau `EstParent`, comme après toute
    // modification d'une sous-opération.
    for taker in ventilated {
        crate::sub_operations::after_change(&transaction, taker, account_id)?;
    }
    crate::balances::update_all(&transaction, account_id)?;
    transaction.commit()?;
    Ok(gone)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database::schema;

    fn day(year: i32, month: u32, day: u32) -> NaiveDate {
        NaiveDate::from_ymd_opt(year, month, day).expect("date")
    }

    fn member(id: i64, date: NaiveDate, amount: i64, label: &str, reference: &str) -> Member {
        Member {
            operation: OperationRow {
                id,
                label: label.to_string(),
                reference: reference.to_string(),
                date: Some(date),
                clearing_date: Some(date),
                amount,
                category: String::new(),
                assignment: String::new(),
                payment_mode: String::new(),
                payee: String::new(),
                project: String::new(),
                category_id: 0,
                assignment_id: 0,
                payment_mode_id: 0,
                payee_id: 0,
                project_id: 0,
                status_id: 1,
                verification_id: 2,
                pointed_balance: 0,
                comment: String::new(),
                has_attachment: false,
                check_number: String::new(),
                is_complement: false,
            },
            ventilated: false,
            fitid: String::new(),
        }
    }

    fn ids(groups: &[Group]) -> Vec<(Level, Vec<i64>)> {
        groups
            .iter()
            .map(|g| (g.level, g.members.iter().map(|m| m.operation.id).collect()))
            .collect()
    }

    #[test]
    fn the_dates_written_in_a_text_come_out_whatever_their_separators() {
        for text in [
            "CARTE X2723 27/10/26 A 08H27",
            "CARTE X2723 27.10.26 A 08H27",
            "CARTE X2723 27-10-2026 A 08:27",
            "CARTE X2723 27_10_26 A 8h27",
            "CARTE X2723 271026 A 08H27",
            "CARTE X2723 27102026 A 08H27",
            "CARTE X2723 2026-10-27 A 08H27",
        ] {
            let cleaned = clean(text);
            assert_eq!(cleaned.key, "cartex2723a", "« {text} »");
            assert_eq!(cleaned.dates, vec![(27, 10)], "« {text} »");
        }
        let short = clean("CB LECLERC 27/10");
        assert_eq!(
            (short.key.as_str(), short.dates),
            ("cbleclerc", vec![(27, 10)])
        );
    }

    #[test]
    fn numbers_that_are_not_dates_stay_in_the_text() {
        // Un numéro de carte, un montant, un numéro de chèque.
        assert_eq!(clean("CARTE X2723").key, "cartex2723");
        assert!(clean("FRAIS 12.50").dates.is_empty());
        assert_eq!(clean("CHEQUE 9506038").key, "cheque9506038");
        assert!(clean("CHEQUE 9506038").dates.is_empty());
        assert_eq!(clean("Épicerie Dupont").key, "epiceriedupont");
    }

    #[test]
    fn the_likeness_of_two_texts() {
        assert_eq!(similarity("boulangerie", "boulangerie"), 1.0);
        // Saisie à la main contre libellé de la banque.
        assert!(similarity("boulangerie", "cartex2723boulangeriedupont") >= 0.85);
        // « CARTE » seul ne prouve rien.
        assert!(similarity("carte", "cartex2723leclerc") < Likeness::Large.threshold());
        assert!(similarity("leclerc", "auchan") < 0.3);
        assert_eq!(similarity("", "leclerc"), 0.0);
    }

    #[test]
    fn the_same_line_imported_twice_is_identical() {
        let groups = find(
            vec![
                member(
                    1,
                    day(2026, 10, 27),
                    -2_350_000,
                    "CARTE X2723 27/10/26 LECLERC",
                    "",
                ),
                member(
                    2,
                    day(2026, 10, 27),
                    -2_350_000,
                    "CARTE X2723 27/10/26 LECLERC",
                    "",
                ),
                member(
                    3,
                    day(2026, 10, 27),
                    -1_000_000,
                    "CARTE X2723 27/10/26 LECLERC",
                    "",
                ),
            ],
            &Settings::default(),
        );
        assert_eq!(ids(&groups), vec![(Level::Identical, vec![1, 2])]);
        assert_eq!(groups[0].total(), -4_700_000);
        assert_eq!(groups[0].after(), -2_350_000);
    }

    #[test]
    fn the_label_of_one_import_meets_the_reference_of_another() {
        // Un relevé importé avec « le nom » en libellé et le mémo en
        // référence, l'autre avec « le nom suivi du mémo » en libellé.
        let groups = find(
            vec![
                member(
                    1,
                    day(2026, 10, 2),
                    -61_200_000,
                    "PRLV SEPA EDF",
                    "ECHEANCE OCTOBRE CLIENT 4471",
                ),
                member(
                    2,
                    day(2026, 10, 3),
                    -61_200_000,
                    "ECHEANCE OCTOBRE CLIENT 4471",
                    "",
                ),
            ],
            &Settings::default(),
        );
        assert_eq!(ids(&groups), vec![(Level::Probable, vec![1, 2])]);

        // Sans la référence dans la comparaison, les libellés seuls ne se
        // ressemblent pas : le soupçon tombe à « à vérifier ».
        let labels_only = Settings {
            compare_reference: false,
            ..Settings::default()
        };
        let groups = find(
            vec![
                member(
                    1,
                    day(2026, 10, 2),
                    -61_200_000,
                    "PRLV SEPA EDF",
                    "ECHEANCE OCTOBRE CLIENT 4471",
                ),
                member(
                    2,
                    day(2026, 10, 3),
                    -61_200_000,
                    "ECHEANCE OCTOBRE CLIENT 4471",
                    "",
                ),
            ],
            &labels_only,
        );
        assert_eq!(ids(&groups), vec![(Level::ToVerify, vec![1, 2])]);
    }

    #[test]
    fn a_hand_entry_and_the_bank_line_are_possible_duplicates() {
        let groups = find(
            vec![
                member(1, day(2026, 10, 25), -1_850_000, "Boulangerie", ""),
                member(
                    2,
                    day(2026, 10, 27),
                    -1_850_000,
                    "CARTE X2723 25/10/26 BOULANGERIE DUPONT",
                    "",
                ),
            ],
            &Settings::default(),
        );
        assert_eq!(ids(&groups), vec![(Level::Possible, vec![1, 2])]);
    }

    #[test]
    fn two_purchases_on_two_written_days_are_only_to_verify() {
        // La même boulangerie, deux jours de suite : les textes sont
        // identiques une fois les dates retirées, mais les dates diffèrent.
        let groups = find(
            vec![
                member(
                    1,
                    day(2026, 10, 27),
                    -1_200_000,
                    "CARTE X2723 26/10/26 BOULANGERIE",
                    "",
                ),
                member(
                    2,
                    day(2026, 10, 28),
                    -1_200_000,
                    "CARTE X2723 27/10/26 BOULANGERIE",
                    "",
                ),
            ],
            &Settings::default(),
        );
        assert_eq!(ids(&groups), vec![(Level::ToVerify, vec![1, 2])]);
    }

    #[test]
    fn two_different_references_put_the_group_to_verify() {
        // Deux chèques du même montant le même jour.
        let groups = find(
            vec![
                member(1, day(2026, 10, 27), -5_000_000, "CHEQUE", "9506038"),
                member(2, day(2026, 10, 27), -5_000_000, "CHEQUE", "9506039"),
            ],
            &Settings::default(),
        );
        assert_eq!(ids(&groups), vec![(Level::ToVerify, vec![1, 2])]);
    }

    #[test]
    fn the_same_reference_raises_the_level() {
        let groups = find(
            vec![
                member(1, day(2026, 10, 20), -5_000_000, "Plombier", "VIR 88412"),
                member(
                    2,
                    day(2026, 10, 22),
                    -5_000_000,
                    "VIREMENT MARTIN SARL",
                    "VIR 88412",
                ),
            ],
            &Settings::default(),
        );
        // Des libellés sans rapport : « à vérifier », que la référence
        // identique fait monter d'un cran.
        assert_eq!(ids(&groups), vec![(Level::Possible, vec![1, 2])]);
    }

    #[test]
    fn the_same_fitid_is_certain() {
        let mut one = member(1, day(2026, 10, 27), -990_000, "ABONNEMENT", "");
        let mut other = member(2, day(2026, 10, 29), -990_000, "PRLV FREE MOBILE", "");
        one.fitid = "20261027-001".into();
        other.fitid = "20261027-001".into();
        let groups = find(vec![one, other], &Settings::default());
        assert_eq!(ids(&groups), vec![(Level::Identical, vec![1, 2])]);
    }

    #[test]
    fn the_amount_must_be_the_same_to_the_cent_and_the_dates_close_enough() {
        let groups = find(
            vec![
                member(1, day(2026, 10, 1), -2_350_000, "LECLERC", ""),
                member(2, day(2026, 10, 1), -2_360_000, "LECLERC", ""),
                member(3, day(2026, 10, 7), -2_350_000, "LECLERC", ""),
            ],
            &Settings::default(),
        );
        assert!(groups.is_empty(), "{:?}", ids(&groups));

        let wider = Settings {
            max_days: 6,
            ..Settings::default()
        };
        let groups = find(
            vec![
                member(1, day(2026, 10, 1), -2_350_000, "LECLERC", ""),
                member(3, day(2026, 10, 7), -2_350_000, "LECLERC", ""),
            ],
            &wider,
        );
        assert_eq!(ids(&groups), vec![(Level::Probable, vec![1, 3])]);
    }

    #[test]
    fn a_monthly_payment_is_not_a_duplicate() {
        let groups = find(
            vec![
                member(1, day(2026, 9, 5), -990_000, "PRLV FREE MOBILE", ""),
                member(2, day(2026, 10, 5), -990_000, "PRLV FREE MOBILE", ""),
            ],
            &Settings {
                max_days: MAX_DAYS,
                ..Settings::default()
            },
        );
        assert!(groups.is_empty());
    }

    #[test]
    fn a_sure_pair_is_not_weakened_by_a_third_operation() {
        let groups = find(
            vec![
                member(1, day(2026, 10, 27), -2_000_000, "RETRAIT DAB 27/10", ""),
                member(2, day(2026, 10, 27), -2_000_000, "RETRAIT DAB 27/10", ""),
                member(3, day(2026, 10, 29), -2_000_000, "CARTE X2723 AUCHAN", ""),
            ],
            &Settings::default(),
        );
        assert_eq!(ids(&groups), vec![(Level::Identical, vec![1, 2])]);
    }

    #[test]
    fn three_lines_alike_make_a_triplet_and_the_surest_come_first() {
        let groups = find(
            vec![
                member(7, day(2026, 10, 3), -300_000, "CAFE DU PORT", ""),
                member(8, day(2026, 10, 5), -300_000, "TABAC", ""),
                member(1, day(2026, 10, 12), -4_500_000, "AMAZON EU", ""),
                member(2, day(2026, 10, 12), -4_500_000, "AMAZON EU", ""),
                member(3, day(2026, 10, 12), -4_500_000, "AMAZON EU", ""),
            ],
            &Settings::default(),
        );
        // Le café et le tabac : même montant, deux jours d'écart, des textes
        // sans rapport — « à vérifier », en dernier.
        assert_eq!(
            ids(&groups),
            vec![
                (Level::Identical, vec![1, 2, 3]),
                (Level::ToVerify, vec![7, 8])
            ]
        );
        assert_eq!(groups[0].total(), -13_500_000);
        assert_eq!(groups[0].after(), -4_500_000);
    }

    #[test]
    fn the_search_reads_the_mothers_of_the_period_only() {
        let conn = Connection::open_in_memory().expect("base en mémoire");
        schema::migrate(&conn).expect("schéma");
        crate::database::seed::seed_initial_data(&conn).expect("valeurs initiales");
        conn.execute(
            "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte, IDBanques)
             VALUES (1, 'CCP', 1, 1)",
            [],
        )
        .expect("compte");
        let add = |id: i64, label: &str, date: &str, amount: i64, parent: i64, fitid: &str| {
            conn.execute(
                "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte,
                     IDStatutOperation, IDOperationParent, IDCategorie, FitID, EstParent)
                 VALUES (?1, ?2, ?3, ?4, 1, 1, ?5, 1, ?6, 0)",
                rusqlite::params![id, label, date, amount, parent, fitid],
            )
            .expect("opération");
        };
        add(1, "LECLERC", "2026-10-27", -2_000_000, 0, "A1");
        add(2, "LECLERC", "2026-10-27", -2_000_000, 0, "");
        // Deux filles de même montant, sous la mère 1 : jamais comparées.
        add(3, "Courses", "2026-10-27", -1_000_000, 1, "");
        add(4, "Courses", "2026-10-27", -1_000_000, 1, "");
        // Hors de la période.
        add(5, "LECLERC", "2026-09-30", -2_000_000, 0, "");

        let groups = search(
            &conn,
            1,
            day(2026, 10, 1),
            day(2026, 10, 31),
            &Settings::default(),
        )
        .expect("recherche");
        assert_eq!(ids(&groups), vec![(Level::Identical, vec![1, 2])]);
        assert!(groups[0].members[0].ventilated);
        assert_eq!(groups[0].members[0].fitid, "A1");
        assert!(!groups[0].members[1].ventilated);
    }

    // --- Le traitement : reprise et suppression ---------------------------

    fn treated_database() -> Connection {
        let conn = Connection::open_in_memory().expect("base en mémoire");
        schema::migrate(&conn).expect("schéma");
        crate::database::seed::seed_initial_data(&conn).expect("valeurs initiales");
        conn.execute(
            "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte, IDBanques)
             VALUES (1, 'CCP', 1, 1), (2, 'Livret', 1, 1)",
            [],
        )
        .expect("comptes");
        conn
    }

    #[allow(clippy::too_many_arguments)]
    fn operation(
        conn: &Connection,
        id: i64,
        account: i64,
        parent: i64,
        amount: i64,
        status: i64,
        category: i64,
        fitid: &str,
    ) {
        conn.execute(
            "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte,
                 IDStatutOperation, IDOperationParent, IDCategorie, FitID, EstParent,
                 ReferencePaiement, NumRelevBanque)
             VALUES (?1, 'LECLERC', '2026-10-27', ?2, ?3, ?4, ?5, ?6, ?7, 0, '', '')",
            rusqlite::params![id, amount, account, status, parent, category, fitid],
        )
        .expect("opération");
    }

    fn column(conn: &Connection, id: i64, name: &str) -> String {
        conn.query_row(
            &format!(
                "SELECT COALESCE(CAST({name} AS TEXT), '') FROM Operation WHERE IDOperation = ?1"
            ),
            [id],
            |row| row.get(0),
        )
        .unwrap_or_else(|_| "absente".to_string())
    }

    fn decision(kept: &[i64], doomed: &[i64]) -> Decision {
        Decision {
            kept: kept.to_vec(),
            doomed: doomed.to_vec(),
        }
    }

    #[test]
    fn the_kept_line_takes_over_only_what_it_lacks() {
        let mut conn = treated_database();
        // La gardée : une catégorie, rien d'autre. Celle qui part : une autre
        // catégorie, un FitID, un commentaire, une pièce jointe.
        operation(&conn, 1, 1, 0, -2_000_000, 1, 5, "");
        operation(&conn, 2, 1, 0, -2_000_000, 1, 7, "F-42");
        conn.execute(
            "INSERT INTO Commentaire (IDCommentaire, CommentaireTxt, IDOperation) VALUES (1, 'ticket', 2)",
            [],
        )
        .expect("commentaire");
        conn.execute(
            "INSERT INTO PiecesJointes (IDOperation, IDPiecesJointes, NomFichier, NomFichierGUID, PathRelFichier)
             VALUES (2, 1, 'ticket.pdf', 'abc', 'attachments/abc')",
            [],
        )
        .expect("pièce jointe");

        let plans = plan(&conn, 1, &[decision(&[1], &[2])], Ventilation::TakeOver)
            .expect("plan")
            .expect("décisions valides");
        let fields: Vec<Field> = plans[0].takes.iter().map(|(field, _)| *field).collect();
        assert_eq!(
            fields,
            vec![Field::Fitid, Field::Comment, Field::Attachments]
        );
        assert!(plans[0].warnings.is_empty());

        assert_eq!(apply(&mut conn, 1, &plans).expect("traitement"), 1);
        assert_eq!(column(&conn, 2, "Libelle"), "absente");
        // Sa propre catégorie n'est pas écrasée ; le FitID, qui manquait, est repris.
        assert_eq!(column(&conn, 1, "IDCategorie"), "5");
        assert_eq!(column(&conn, 1, "FitID"), "F-42");
        let comment: String = conn
            .query_row(
                "SELECT CommentaireTxt FROM Commentaire WHERE IDOperation = 1",
                [],
                |row| row.get(0),
            )
            .expect("commentaire repris");
        assert_eq!(comment, "ticket");
        let attached: i64 = conn
            .query_row(
                "SELECT COUNT(*) FROM PiecesJointes WHERE IDOperation = 1",
                [],
                |row| row.get(0),
            )
            .expect("pièces jointes");
        assert_eq!(attached, 1);
    }

    #[test]
    fn several_kept_lines_take_nothing_over() {
        let mut conn = treated_database();
        operation(&conn, 1, 1, 0, -1_500_000, 1, 0, "");
        operation(&conn, 2, 1, 0, -1_500_000, 1, 0, "");
        operation(&conn, 3, 1, 0, -1_500_000, 1, 9, "F-1");
        let plans = plan(&conn, 1, &[decision(&[1, 2], &[3])], Ventilation::TakeOver)
            .expect("plan")
            .expect("décisions valides");
        assert_eq!(plans[0].taker, None);
        assert!(plans[0].takes.is_empty());
        assert_eq!(plans[0].warnings, vec![(Warning::SeveralKept, 1)]);
        apply(&mut conn, 1, &plans).expect("traitement");
        assert_eq!(column(&conn, 1, "IDCategorie"), "0");
        assert_eq!(column(&conn, 2, "IDCategorie"), "0");
        assert_eq!(column(&conn, 3, "Libelle"), "absente");
    }

    #[test]
    fn a_ventilation_moves_to_the_kept_line_or_is_announced_lost() {
        // Préférence « la reprendre » : les filles passent sous la gardée.
        let mut conn = treated_database();
        operation(&conn, 1, 1, 0, -3_000_000, 1, 0, "");
        operation(&conn, 2, 1, 0, -3_000_000, 1, 0, "");
        operation(&conn, 3, 1, 2, -1_000_000, 1, 4, "");
        conn.execute(
            "UPDATE Operation SET EstParent = 1 WHERE IDOperation = 2",
            [],
        )
        .expect("mère");
        let plans = plan(&conn, 1, &[decision(&[1], &[2])], Ventilation::TakeOver)
            .expect("plan")
            .expect("décisions valides");
        assert!(plans[0].takes.contains(&(Field::Ventilation, 2)));
        apply(&mut conn, 1, &plans).expect("traitement");
        assert_eq!(column(&conn, 3, "IDOperationParent"), "1");
        assert_eq!(column(&conn, 1, "EstParent"), "1");
        // Le complément est refait sous la nouvelle mère : la ventilation tombe juste.
        let children: i64 = conn
            .query_row(
                "SELECT COALESCE(SUM(Montant), 0) FROM Operation WHERE IDOperationParent = 1",
                [],
                |row| row.get(0),
            )
            .expect("somme des filles");
        assert_eq!(children, -3_000_000);

        // Préférence « avertir seulement » : rien ne bouge, la confirmation le dit.
        let conn = treated_database();
        operation(&conn, 1, 1, 0, -3_000_000, 1, 0, "");
        operation(&conn, 2, 1, 0, -3_000_000, 1, 0, "");
        operation(&conn, 3, 1, 2, -1_000_000, 1, 4, "");
        let plans = plan(&conn, 1, &[decision(&[1], &[2])], Ventilation::WarnOnly)
            .expect("plan")
            .expect("décisions valides");
        assert!(!plans[0]
            .takes
            .iter()
            .any(|(field, _)| *field == Field::Ventilation));
        assert_eq!(plans[0].warnings, vec![(Warning::VentilationLost, 2)]);
    }

    #[test]
    fn the_deletion_moves_the_three_balances() {
        let mut conn = treated_database();
        operation(&conn, 1, 1, 0, -2_000_000, 1, 0, "");
        operation(&conn, 2, 1, 0, -2_000_000, 1, 0, "");
        crate::balances::update_all(&conn, 1).expect("soldes");
        let before: i64 = conn
            .query_row(
                "SELECT SoldeBanque FROM Compte WHERE IDCompte = 1",
                [],
                |row| row.get(0),
            )
            .expect("solde");
        let plans = plan(&conn, 1, &[decision(&[1], &[2])], Ventilation::TakeOver)
            .expect("plan")
            .expect("décisions valides");
        apply(&mut conn, 1, &plans).expect("traitement");
        let after: i64 = conn
            .query_row(
                "SELECT SoldeBanque FROM Compte WHERE IDCompte = 1",
                [],
                |row| row.get(0),
            )
            .expect("solde");
        assert_eq!(after - before, 2_000_000);
    }

    #[test]
    fn a_stale_decision_is_refused_before_anything_is_written() {
        let conn = treated_database();
        operation(&conn, 1, 1, 0, -2_000_000, 1, 0, "");
        operation(&conn, 2, 1, 0, -2_000_000, 1, 0, "");
        operation(&conn, 4, 2, 0, -2_000_000, 1, 0, "");
        operation(&conn, 5, 1, 1, -1_000_000, 1, 0, "");
        for decisions in [
            vec![decision(&[1], &[99])],  // disparue
            vec![decision(&[1], &[4])],   // d'un autre compte
            vec![decision(&[1], &[5])],   // une sous-opération
            vec![decision(&[1], &[1])],   // nommée deux fois
            vec![decision(&[], &[2])],    // rien de gardé
            vec![decision(&[1, 2], &[])], // rien qui parte
        ] {
            assert_eq!(
                plan(&conn, 1, &decisions, Ventilation::TakeOver).expect("plan"),
                None,
                "{decisions:?}"
            );
        }
    }
}
