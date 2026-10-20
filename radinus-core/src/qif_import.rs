//! La lecture d'un relevé QIF (Quicken Interchange Format) — Fabrice,
//! 15/10/2026 : « en plus du format OFX (que tu ne touches pas, merci), on
//! puisse importer du QIF », **ergonomiquement de la même façon** : même
//! fenêtre, mêmes boutons, même tableau. Ce module rend donc le même
//! [`ofx_import::Statement`] que la lecture OFX, et tout ce qui suit —
//! rapprochement, anti-doublon, intégration — ne sait pas d'où il vient.
//!
//! Référence : la classe `Qif_Import` de Radinus 1.x (`Classe QIF
//! Import.txt`), les deux exports de Microsoft Money que Fabrice a fournis
//! (« compatibilité stricte » et « compatibilité relative »), et la
//! description publique du format (Intuit, reprise par GnuCash et Wikipédia).
//!
//! # Le format
//!
//! Du texte, une ligne par champ, une lettre en tête de ligne : `D` la date,
//! `T` (ou `U`) le montant signé, `P` le tiers, `M` le mémo, `N` le numéro,
//! `L` la catégorie, `C` le pointage. `^` ferme l'opération. Un en-tête
//! `!Type:Bank` (ou `CCard`, `Cash`, `Oth A`, `Oth L`) ouvre une liste
//! d'opérations ; `!Account` nomme le compte qui suit.
//!
//! # La fiabilité avant tout
//!
//! « Je veux quelque chose de robuste et de fiable » (Fabrice). Le QIF n'a
//! **aucune norme** pour deux choses qui comptent plus que tout le reste :
//!
//!   * **l'ordre du jour et du mois** — `05/03/2023` est le 5 mars à Paris et
//!     le 3 mai à New York, et rien dans le fichier ne le dit ;
//!   * **le séparateur décimal** — `1,234` vaut mille deux cent trente-quatre
//!     en anglais et un virgule deux cent trente-quatre en français.
//!
//! Une date ou un montant faux qui entre en silence est le pire des défauts :
//! on ne le voit pas, et il fausse tout ce qui suit. D'où trois règles :
//!
//!   1. **On décide sur tout le compte, jamais ligne par ligne.** Une seule
//!      date `24/11` prouve que le jour vient d'abord ; un seul montant
//!      `-57.62` prouve que le point est décimal. Une ligne ne se lit pas
//!      d'une façon et sa voisine d'une autre.
//!   2. **Un fichier qui se contredit est refusé**, en citant les deux
//!      lignes : `24/11` et `11/24` dans le même relevé, c'est un fichier
//!      qu'on ne peut pas lire juste.
//!   3. **Ce qu'on ne peut pas prouver, on le demande** — l'ordre des dates
//!      quand aucune ne dépasse 12 — **ou on l'écarte en le disant** : une
//!      opération sans date ou sans montant lisible n'entre pas, et la barre
//!      d'information donne son numéro. Rien ne disparaît en silence.
//!
//! Le reste suit l'esprit de la lecture OFX : **un code qu'on ne connaît pas
//! est ignoré, jamais fatal** ; un fichier tronqué rend ce qu'il a ; aucun
//! octet, si étrange soit-il, ne fait tomber la lecture.
//!
//! # Ce que l'ancienne classe faisait, et ce qui change
//!
//! `Qif_Import` coupait sur `^`, lisait `D` et `T`, et prenait **toute autre
//! ligne** pour le libellé — le numéro de chèque, la catégorie, le pointage.
//! Elle ne lisait que les dates de 8 ou 10 caractères, pas `1/15'05` ; elle
//! ne connaissait ni les comptes multiples ni le solde initial. Le découpage
//! sur `^` et la lecture par la lettre de tête sont gardés : c'est ce qui
//! rend le format lisible. Le reste est repris.
//!
//! # Le solde initial
//!
//! Money et Quicken placent en tête du compte un enregistrement « Solde
//! initial » (« Opening Balance ») dont la catégorie est **le compte
//! lui-même**, entre crochets : `L[CCP banque post]`. C'est un solde de
//! départ, pas une opération : l'intégrer gonflerait le compte de son
//! montant. Il est écarté **et annoncé**. Pour le reconnaître, deux indices
//! doivent concorder — la forme (`L[…]` sur le premier enregistrement) et le
//! sens (une phrase connue, ou le nom du compte) ; un seul indice garde la
//! ligne et la signale. Mieux vaut une ligne en trop, visible, qu'une
//! opération perdue.
//!
//! # Pas d'identifiant
//!
//! Le QIF ne porte pas de FITID, et l'on n'en invente pas : comme pour le
//! CSV, l'anti-doublon ne joue que par ressemblance (même date, même libellé,
//! même montant), et la colonne FITID se cache d'elle-même.

use crate::domain::NaiveDate;
use crate::i18n::{self, Language};
use crate::money::{self, UNIT};
use crate::ofx_import::{Statement, Transaction};

// --- Les réglages -----------------------------------------------------------

/// L'ordre du jour et du mois, quand le fichier ne le prouve pas lui-même.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DateOrder {
    /// `05/03` = 5 mars, à la française.
    DayMonth,
    /// `05/03` = 3 mai, à l'américaine.
    MonthDay,
}

impl DateOrder {
    pub fn key(self) -> &'static str {
        match self {
            DateOrder::DayMonth => "day-month",
            DateOrder::MonthDay => "month-day",
        }
    }

    pub fn from_key(key: &str) -> Option<DateOrder> {
        match key {
            "day-month" => Some(DateOrder::DayMonth),
            "month-day" => Some(DateOrder::MonthDay),
            _ => None,
        }
    }
}

/// Ce qui fait le libellé quand une opération porte un tiers (`P`) **et** un
/// mémo (`M`). Quand elle n'en porte qu'un, c'est celui-là, quel que soit le
/// réglage.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum LabelChoice {
    /// « Tiers + mémo » : rien n'est perdu.
    #[default]
    Both,
    Payee,
    Memo,
}

impl LabelChoice {
    pub fn key(self) -> &'static str {
        match self {
            LabelChoice::Both => "both",
            LabelChoice::Payee => "payee",
            LabelChoice::Memo => "memo",
        }
    }

    pub fn from_key(key: &str) -> Option<LabelChoice> {
        match key {
            "both" => Some(LabelChoice::Both),
            "payee" => Some(LabelChoice::Payee),
            "memo" => Some(LabelChoice::Memo),
            _ => None,
        }
    }
}

/// Comment lire.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Options {
    /// L'ordre choisi par l'utilisateur, **pour le seul cas où le fichier ne
    /// le prouve pas**. Quand une date le prouve, le fichier l'emporte.
    pub order: Option<DateOrder>,
    pub label: LabelChoice,
    /// Aujourd'hui : il sert à lire une année sur deux chiffres et à écarter
    /// une date impossible (l'an 2105).
    pub today: NaiveDate,
}

// --- Le texte, découpé ----------------------------------------------------

/// Une opération telle que le fichier l'écrit : ses champs, dans l'ordre, avec
/// leur lettre. Rien n'est encore interprété.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
struct Record {
    fields: Vec<(char, String)>,
}

impl Record {
    /// Toutes les valeurs d'un code, dans l'ordre.
    fn all(&self, code: char) -> impl Iterator<Item = &str> {
        self.fields.iter().filter(move |(c, _)| *c == code).map(|(_, value)| value.as_str())
    }

    /// La première valeur d'un code, nettoyée.
    fn first(&self, code: char) -> String {
        self.all(code).next().map(clean_text).unwrap_or_default()
    }
}

/// Une liste d'opérations : un compte du fichier.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
struct Section {
    /// Le nom que `!Account` donne au compte, s'il y en a un.
    name: Option<String>,
    records: Vec<Record>,
}

/// Les types d'en-tête qui portent des opérations bancaires. `Invst` (des
/// titres), `Cat`, `Class`, `Memorized`… n'en portent pas et sont ignorés.
const BANK_TYPES: [&str; 5] = ["bank", "ccard", "cash", "oth a", "oth l"];

/// Les lettres qui ouvrent une ligne d'opération — pour reconnaître un QIF
/// sans en-tête, et pour rien d'autre.
const RECORD_CODES: &str = "DTUPMNCLSEA$%F";

/// Le texte sans marque d'ordre des octets, en lignes. Les trois fins de ligne
/// (Windows, Unix, ancien Mac) sont acceptées ; les lignes vides qu'elles
/// laissent sont ignorées plus loin.
fn lines_of(text: &str) -> impl Iterator<Item = &str> {
    text.strip_prefix('\u{feff}').unwrap_or(text).split(['\n', '\r'])
}

/// Une valeur lisible : sans caractère de contrôle, sans blanc aux bouts. Les
/// espaces intérieurs sont gardés, comme en OFX — `CHEQUE N  9506023` reste
/// tel que la banque l'a écrit.
fn clean_text(value: &str) -> String {
    value
        .chars()
        .map(|c| if c.is_control() { ' ' } else { c })
        .collect::<String>()
        .trim()
        .to_string()
}

/// Ce que le découpage fait de chaque en-tête.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Mode {
    /// Avant tout en-tête : un QIF sans en-tête est lu comme un compte.
    Start,
    Transactions,
    /// L'enregistrement qui suit `!Account` nomme le compte.
    AccountName,
    /// Ce qui ne porte pas d'opérations bancaires.
    Ignored,
}

/// **Le découpage**, sans rien interpréter : les comptes et leurs opérations.
///
/// Un enregistrement sans `^` final (fichier tronqué, ou en-tête suivant
/// directement) est gardé : il rend ce qu'il a. Un en-tête inconnu ouvre une
/// zone ignorée — on n'importe pas ce qu'on ne comprend pas.
fn sections(text: &str) -> Vec<Section> {
    let mut found: Vec<Section> = Vec::new();
    let mut mode = Mode::Start;
    let mut autoswitch = false;
    let mut account_name: Option<String> = None;
    let mut current: Option<Section> = None;
    let mut record = Record::default();

    fn close(current: &mut Option<Section>, found: &mut Vec<Section>) {
        if let Some(section) = current.take() {
            if !section.records.is_empty() {
                found.push(section);
            }
        }
    }

    fn flush(
        record: &mut Record,
        mode: Mode,
        current: &mut Option<Section>,
        account_name: &mut Option<String>,
    ) {
        let taken = std::mem::take(record);
        if taken.fields.is_empty() {
            return;
        }
        match mode {
            Mode::Transactions | Mode::Start => {
                current.get_or_insert_with(Section::default).records.push(taken);
            }
            Mode::AccountName => {
                let name = taken.first('N');
                *account_name = (!name.is_empty()).then_some(name);
            }
            Mode::Ignored => {}
        }
    }

    for raw in lines_of(text) {
        let line = raw.trim_start();
        if line.trim().is_empty() {
            continue;
        }
        if let Some(header) = line.strip_prefix('!') {
            flush(&mut record, mode, &mut current, &mut account_name);
            let header = header.trim().to_lowercase();
            if header == "option:autoswitch" {
                autoswitch = true;
                mode = Mode::Ignored;
            } else if header == "clear:autoswitch" {
                autoswitch = false;
                mode = Mode::Ignored;
            } else if header == "account" {
                close(&mut current, &mut found);
                // Sous `AutoSwitch`, `!Account` ouvre la **liste** des comptes,
                // pas un compte : on n'y lit rien.
                mode = if autoswitch { Mode::Ignored } else { Mode::AccountName };
            } else if let Some(kind) = header.strip_prefix("type:") {
                close(&mut current, &mut found);
                let kind = kind.split_whitespace().collect::<Vec<_>>().join(" ");
                if BANK_TYPES.contains(&kind.as_str()) {
                    current = Some(Section { name: account_name.take(), records: Vec::new() });
                    mode = Mode::Transactions;
                } else {
                    account_name = None;
                    mode = Mode::Ignored;
                }
            } else {
                close(&mut current, &mut found);
                mode = Mode::Ignored;
            }
            continue;
        }
        if line.starts_with('^') {
            flush(&mut record, mode, &mut current, &mut account_name);
            continue;
        }
        let mut chars = line.chars();
        let Some(code) = chars.next() else { continue };
        record.fields.push((code.to_ascii_uppercase(), chars.as_str().trim_end().to_string()));
    }
    flush(&mut record, mode, &mut current, &mut account_name);
    close(&mut current, &mut found);
    found
}

/// **Ce fichier est-il un QIF ?** Déduit du contenu, pas de l'extension —
/// la règle de toute l'importation.
///
/// Un en-tête QIF en première ligne suffit (`!Type:`, `!Account`,
/// `!Option:`). Sans en-tête, il faut que **toutes** les lignes commencent par
/// une lettre de champ QIF et qu'on trouve au moins une date, un montant et
/// une fin d'opération : un CSV, dont les lignes commencent par des chiffres
/// ou des guillemets, n'y ressemble jamais.
pub fn looks_like_qif(text: &str) -> bool {
    let mut lines = lines_of(text).map(str::trim).filter(|line| !line.is_empty());
    let Some(first) = lines.next() else { return false };
    let first_lower = first.to_lowercase();
    if ["!type:", "!account", "!option:", "!clear:"].iter().any(|start| first_lower.starts_with(start)) {
        return true;
    }
    let (mut date, mut amount, mut end) = (false, false, false);
    for line in std::iter::once(first).chain(lines) {
        let Some(code) = line.chars().next() else { continue };
        match code.to_ascii_uppercase() {
            '^' => end = true,
            'D' => date = true,
            'T' | 'U' => amount = true,
            other if RECORD_CODES.contains(other) => {}
            _ => return false,
        }
    }
    date && amount && end
}

/// **Les comptes du fichier**, dans l'ordre, pour la question « lequel
/// voulez-vous importer ? ». Un compte sans nom prend celui du fichier ; deux
/// comptes au même nom sont numérotés, pour qu'on ne choisisse jamais l'un en
/// croyant prendre l'autre.
pub fn accounts_in(text: &str, file_name: &str) -> Vec<String> {
    labels(&sections(text), file_name)
}

fn labels(sections: &[Section], file_name: &str) -> Vec<String> {
    let raw: Vec<String> = sections
        .iter()
        .map(|section| section.name.clone().unwrap_or_else(|| file_name.to_string()))
        .collect();
    raw.iter()
        .enumerate()
        .map(|(index, name)| {
            let same = raw.iter().filter(|other| *other == name).count();
            if same > 1 {
                let rank = raw[..=index].iter().filter(|other| *other == name).count();
                format!("{name} ({rank})")
            } else {
                name.clone()
            }
        })
        .collect()
}

// --- Les dates ------------------------------------------------------------

/// Une date telle qu'écrite, découpée mais pas encore lue.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum DateShape {
    /// L'année d'abord (`2022-11-24`) : sans ambiguïté.
    YearFirst { year: i32, month: u32, day: u32 },
    /// Deux nombres puis l'année : `24/11'2022`, `1/15'05`, `11-24-22`.
    /// L'ordre des deux premiers reste à décider.
    Pair { first: u32, second: u32, year: i32 },
}

/// Ce qu'une date dit de l'ordre du fichier.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Evidence {
    DayFirst,
    MonthFirst,
    None,
}

impl DateShape {
    fn evidence(self) -> Evidence {
        match self {
            DateShape::Pair { first, second, .. } if first > 12 && (1..=12).contains(&second) => Evidence::DayFirst,
            DateShape::Pair { first, second, .. } if second > 12 && (1..=12).contains(&first) => Evidence::MonthFirst,
            _ => Evidence::None,
        }
    }

    /// Ambiguë **et** qui change selon l'ordre : `05/03`, mais pas `05/05`.
    fn undecided(self) -> bool {
        matches!(self, DateShape::Pair { first, second, .. }
            if first != second && (1..=12).contains(&first) && (1..=12).contains(&second))
    }

    fn date(self, order: Option<DateOrder>, today: NaiveDate) -> Option<NaiveDate> {
        let date = match self {
            DateShape::YearFirst { year, month, day } => NaiveDate::from_ymd_opt(year, month, day)?,
            DateShape::Pair { first, second, year } => {
                let (day, month) = match (self.evidence(), order) {
                    (Evidence::DayFirst, _) | (Evidence::None, Some(DateOrder::DayMonth)) => (first, second),
                    (Evidence::MonthFirst, _) | (Evidence::None, Some(DateOrder::MonthDay)) => (second, first),
                    // Les deux lectures donnent la même date (`05/05`).
                    (Evidence::None, None) if first == second => (first, second),
                    (Evidence::None, None) => return None,
                };
                NaiveDate::from_ymd_opt(year, month, day)?
            }
        };
        // Une opération bancaire n'est ni d'avant 1900, ni d'au-delà de
        // l'an prochain : une telle date est une date mal lue.
        use time_compute::Datelike;
        (date.year() >= 1900 && date.year() <= today.year() + 1).then_some(date)
    }
}

/// **Découpe une date**, sans décider de l'ordre.
///
/// Les blancs sont ôtés (Quicken écrit ` 1/ 5'05`). Les séparateurs `/`, `-`,
/// `.` et `'` sont acceptés. L'apostrophe devant l'année est la marque de
/// Quicken et de Money pour les années 2000 : `1/15'05` est en 2005. Une année
/// sur deux chiffres sans apostrophe est placée dans le siècle qui ne la met
/// pas dans le futur lointain.
fn date_shape(raw: &str, today: NaiveDate) -> Option<DateShape> {
    let text: String = raw.chars().filter(|c| !c.is_whitespace()).collect();
    if text.is_empty() {
        return None;
    }
    let number = |digits: &str| -> Option<u32> {
        (!digits.is_empty() && digits.len() <= 4 && digits.chars().all(|c| c.is_ascii_digit()))
            .then(|| digits.parse().ok())
            .flatten()
    };
    // Huit chiffres collés : `20221124`, ou `24112022`.
    if text.len() == 8 && text.chars().all(|c| c.is_ascii_digit()) {
        let (head, tail) = text.split_at(4);
        let year = number(head)? as i32;
        let iso = DateShape::YearFirst { year, month: number(&tail[..2])?, day: number(&tail[2..])? };
        if (1900..=2100).contains(&year) && iso.date(None, today).is_some() {
            return Some(iso);
        }
        return Some(DateShape::Pair {
            first: number(&text[..2])?,
            second: number(&text[2..4])?,
            year: number(&text[4..])? as i32,
        });
    }
    let apostrophe = text.contains('\'');
    let parts: Vec<&str> = text.split(['/', '-', '.', '\'']).collect();
    let [a, b, c] = parts.as_slice() else { return None };
    if a.len() == 4 {
        if b.len() > 2 || c.len() > 2 {
            return None;
        }
        return Some(DateShape::YearFirst { year: number(a)? as i32, month: number(b)?, day: number(c)? });
    }
    if a.len() > 2 || b.len() > 2 {
        return None;
    }
    let short = number(c)?;
    let year = match c.len() {
        4 => short as i32,
        1 | 2 if apostrophe => 2000 + short as i32,
        1 | 2 => {
            use time_compute::Datelike;
            let modern = 2000 + short as i32;
            if modern <= today.year() + 1 { modern } else { 1900 + short as i32 }
        }
        _ => return None,
    };
    Some(DateShape::Pair { first: number(a)?, second: number(b)?, year })
}

// --- Les montants ---------------------------------------------------------

/// Ce qu'un montant dit du séparateur décimal du fichier.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum AmountShape {
    /// Pas de séparateur : `-84`.
    Whole,
    /// Ce caractère est forcément le séparateur décimal : `-57.62`,
    /// `3,382.63`, `1.234.567,00`.
    Decimal(char),
    /// Un seul séparateur suivi de trois chiffres : `1,234` — mille deux cent
    /// trente-quatre, ou un virgule deux cent trente-quatre. Le fichier
    /// décidera.
    Ambiguous(char),
    /// Ni chiffre, ni forme de montant.
    Unreadable,
}

/// Le texte d'un montant sans signe ni blanc, et son signe.
fn amount_body(raw: &str) -> Option<(bool, String)> {
    let text: String = raw.chars().filter(|c| !c.is_whitespace()).collect();
    let (negative, body) = match text.strip_prefix('-') {
        Some(rest) => (true, rest),
        None => (false, text.strip_prefix('+').unwrap_or(&text)),
    };
    let valid = !body.is_empty()
        && body.chars().all(|c| c.is_ascii_digit() || c == '.' || c == ',')
        && body.chars().any(|c| c.is_ascii_digit());
    valid.then(|| (negative, body.to_string()))
}

fn amount_shape(raw: &str) -> AmountShape {
    let Some((_, body)) = amount_body(raw) else { return AmountShape::Unreadable };
    let dots = body.matches('.').count();
    let commas = body.matches(',').count();
    match (dots, commas) {
        (0, 0) => AmountShape::Whole,
        (_, 0) | (0, _) => {
            let mark = if dots > 0 { '.' } else { ',' };
            if dots + commas > 1 {
                // Répété, il groupe les milliers : l'autre est le décimal.
                return AmountShape::Decimal(if mark == '.' { ',' } else { '.' });
            }
            let (whole, fraction) = body.split_once(mark).unwrap_or((&body, ""));
            if fraction.len() == 3 && !whole.is_empty() && !whole.starts_with('0') {
                AmountShape::Ambiguous(mark)
            } else {
                AmountShape::Decimal(mark)
            }
        }
        _ => {
            // Les deux : le dernier est le décimal.
            let last = body.chars().rev().find(|c| *c == '.' || *c == ',').unwrap_or('.');
            AmountShape::Decimal(last)
        }
    }
}

/// **Lit un montant** une fois le séparateur décimal du fichier connu, en
/// micro-unités. Strict : un groupe de milliers qui n'a pas trois chiffres,
/// deux séparateurs décimaux, plus de six décimales ou un nombre trop grand
/// rendent `None` — et l'opération est écartée en le disant.
fn parse_amount(raw: &str, decimal: Option<char>) -> Option<i64> {
    let (negative, body) = amount_body(raw)?;
    let (whole, fraction) = match decimal {
        Some(mark) => match body.rsplit_once(mark) {
            Some((whole, fraction)) => (whole.to_string(), fraction.to_string()),
            None => (body.clone(), String::new()),
        },
        None => (body.clone(), String::new()),
    };
    let thousands = match decimal {
        Some('.') => ',',
        Some(_) => '.',
        // Séparateur inconnu : seul un nombre entier se lit.
        None if whole.chars().all(|c| c.is_ascii_digit()) => '\0',
        None => return None,
    };
    if decimal.is_some_and(|mark| whole.contains(mark)) || !fraction.chars().all(|c| c.is_ascii_digit()) || fraction.len() > 6 {
        return None;
    }
    let digits: String = if whole.contains(thousands) {
        let groups: Vec<&str> = whole.split(thousands).collect();
        let first_ok = (1..=3).contains(&groups[0].len());
        let rest_ok = groups[1..].iter().all(|group| group.len() == 3);
        if !first_ok || !rest_ok {
            return None;
        }
        groups.concat()
    } else {
        whole
    };
    if !digits.chars().all(|c| c.is_ascii_digit()) {
        return None;
    }
    let units: i64 = if digits.is_empty() { 0 } else { digits.parse::<i64>().ok()? };
    let padded = format!("{fraction:0<6}");
    let micro: i64 = padded.parse().ok()?;
    let value = units.checked_mul(UNIT)?.checked_add(micro)?;
    Some(if negative { -value } else { value })
}

// --- La lecture -----------------------------------------------------------

/// Pourquoi une opération n'entre pas.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Reason {
    /// Pas de date, ou une date qu'on ne sait pas lire.
    Date,
    /// Pas de montant, ou un montant qu'on ne sait pas lire.
    Amount,
    /// `T` et `U`, ou deux `T`, qui ne disent pas le même montant.
    AmountsDiffer,
}

/// Une opération écartée, et son numéro dans le compte (le premier
/// enregistrement est le numéro 1) : c'est le numéro de la colonne ID, qui
/// saute là où une ligne manque.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Rejected {
    pub rank: usize,
    pub reason: Reason,
}

/// Le solde initial, écarté.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Opening {
    pub amount: i64,
    pub date: Option<NaiveDate>,
}

/// Une première opération qui **ressemble** à un solde initial, sans que les
/// deux indices concordent : elle est gardée, et signalée.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Suspect {
    pub rank: usize,
    pub label: String,
    pub amount: i64,
}

/// Ce que la lecture a donné.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Read {
    /// Le relevé, tel que la lecture OFX l'aurait rendu.
    pub statement: Statement,
    pub opening: Option<Opening>,
    pub suspect: Option<Suspect>,
    pub rejected: Vec<Rejected>,
}

/// Ce qui empêche de lire le compte, ou la question à poser d'abord.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Problem {
    /// Le compte demandé n'est plus dans le fichier (le fichier a changé entre
    /// le choix et la lecture).
    NoSuchAccount,
    /// Rien ne prouve l'ordre jour/mois : il faut le demander. `sample` est une
    /// date du fichier telle qu'écrite, `first` et `second` ses deux nombres.
    OrderNeeded { sample: String, first: u32, second: u32 },
    /// Le compte écrit ses dates des deux façons.
    DatesMixed { day_first: String, month_first: String },
    /// Le compte écrit ses montants des deux façons.
    AmountsMixed { dot: String, comma: String },
}

/// Les phrases du solde initial, sans accents ni majuscules, dans les langues
/// où Money et Quicken ont existé.
const OPENING_PHRASES: [&str; 16] = [
    "opening balance",
    "solde initial",
    "solde d'ouverture",
    "solde de depart",
    "solde d'ouverture du compte",
    "anfangssaldo",
    "eroffnungssaldo",
    "saldo inicial",
    "saldo iniziale",
    "saldo di apertura",
    "beginsaldo",
    "openingssaldo",
    "ingaende saldo",
    "inngaende saldo",
    "alkusaldo",
    "starting balance",
];

/// Minuscules, sans accents, espaces simples : pour comparer une phrase.
fn folded(text: &str) -> String {
    let plain: String = text
        .to_lowercase()
        .chars()
        .map(|c| match c {
            'à' | 'á' | 'â' | 'ä' | 'å' | 'ã' => 'a',
            'é' | 'è' | 'ê' | 'ë' => 'e',
            'í' | 'ì' | 'î' | 'ï' => 'i',
            'ó' | 'ò' | 'ô' | 'ö' | 'õ' | 'ø' => 'o',
            'ú' | 'ù' | 'û' | 'ü' => 'u',
            'ç' => 'c',
            'ñ' => 'n',
            '’' => '\'',
            other => other,
        })
        .collect();
    plain.split_whitespace().collect::<Vec<_>>().join(" ")
}

/// Le libellé d'une opération, selon le réglage.
fn label_of(record: &Record, choice: LabelChoice) -> String {
    let payee = record.first('P');
    let memo = record.first('M');
    match (payee.is_empty(), memo.is_empty()) {
        (true, _) => memo,
        (_, true) => payee,
        _ => match choice {
            LabelChoice::Payee => payee,
            LabelChoice::Memo => memo,
            LabelChoice::Both => {
                if folded(&payee).contains(&folded(&memo)) {
                    payee
                } else {
                    format!("{payee} {memo}")
                }
            }
        },
    }
}

/// **Lit un compte du fichier.**
///
/// `account` est son rang dans [`accounts_in`]. Rend le relevé, ou ce qui
/// empêche de le lire — dont la question de l'ordre des dates, quand rien ne
/// le prouve et que l'utilisateur n'a pas encore répondu.
pub fn read(text: &str, account: usize, file_name: &str, options: Options) -> Result<Read, Problem> {
    let all = sections(text);
    let names = labels(&all, file_name);
    let section = all.get(account).ok_or(Problem::NoSuchAccount)?;

    // 1. L'ordre des dates, décidé sur tout le compte.
    let shapes: Vec<Vec<(String, Option<DateShape>)>> = section
        .records
        .iter()
        .map(|record| record.all('D').map(|raw| (raw.trim().to_string(), date_shape(raw, options.today))).collect())
        .collect();
    let flat = || shapes.iter().flatten();
    let day_first = flat().find(|(_, shape)| shape.is_some_and(|s| s.evidence() == Evidence::DayFirst));
    let month_first = flat().find(|(_, shape)| shape.is_some_and(|s| s.evidence() == Evidence::MonthFirst));
    let order = match (day_first, month_first) {
        (Some((a, _)), Some((b, _))) => {
            return Err(Problem::DatesMixed { day_first: a.clone(), month_first: b.clone() });
        }
        (Some(_), None) => Some(DateOrder::DayMonth),
        (None, Some(_)) => Some(DateOrder::MonthDay),
        (None, None) => match (options.order, flat().find(|(_, shape)| shape.is_some_and(DateShape::undecided))) {
            (Some(chosen), _) => Some(chosen),
            (None, Some((sample, Some(DateShape::Pair { first, second, .. })))) => {
                return Err(Problem::OrderNeeded { sample: sample.clone(), first: *first, second: *second });
            }
            (None, _) => None,
        },
    };

    // 2. Le séparateur décimal, décidé sur tout le compte.
    let amounts = || section.records.iter().flat_map(|record| record.all('T').chain(record.all('U')));
    let with_dot = amounts().find(|raw| amount_shape(raw) == AmountShape::Decimal('.'));
    let with_comma = amounts().find(|raw| amount_shape(raw) == AmountShape::Decimal(','));
    let decimal = match (with_dot, with_comma) {
        (Some(dot), Some(comma)) => {
            return Err(Problem::AmountsMixed { dot: dot.trim().to_string(), comma: comma.trim().to_string() });
        }
        (Some(_), None) => Some('.'),
        (None, Some(_)) => Some(','),
        (None, None) => None,
    };

    // 3. Chaque opération.
    let mut transactions = Vec::new();
    let mut rejected = Vec::new();
    let mut opening = None;
    let mut suspect = None;
    for (index, record) in section.records.iter().enumerate() {
        let rank = index + 1;
        let dates: Vec<Option<NaiveDate>> = shapes[index]
            .iter()
            .map(|(_, shape)| shape.and_then(|shape| shape.date(order, options.today)))
            .collect();
        let date = match dates.first() {
            Some(Some(first)) if dates.iter().all(|other| *other == Some(*first)) => *first,
            _ => {
                rejected.push(Rejected { rank, reason: Reason::Date });
                continue;
            }
        };
        let values: Vec<Option<i64>> =
            record.all('T').chain(record.all('U')).map(|raw| parse_amount(raw, decimal)).collect();
        let amount = match values.first() {
            Some(Some(first)) if values.iter().all(|other| *other == Some(*first)) => *first,
            Some(Some(_)) if values.iter().all(Option::is_some) => {
                rejected.push(Rejected { rank, reason: Reason::AmountsDiffer });
                continue;
            }
            _ => {
                rejected.push(Rejected { rank, reason: Reason::Amount });
                continue;
            }
        };
        let label = label_of(record, options.label);

        // Le solde initial : le premier enregistrement seulement.
        if index == 0 {
            let category = record.first('L');
            let bracketed = category.len() > 2 && category.starts_with('[') && category.ends_with(']');
            let own = bracketed
                && section.name.as_deref().is_some_and(|name| {
                    folded(&category[1..category.len() - 1]) == folded(name)
                });
            let phrase = OPENING_PHRASES.contains(&folded(&record.first('P')).as_str());
            // Deux indices : la forme (`L[…]`) et le sens (la phrase, ou le
            // nom du compte entre les crochets). Les deux : c'est le solde
            // initial. Un seul : la ligne reste, et on la signale.
            let meaning = phrase || own;
            if bracketed && meaning {
                opening = Some(Opening { amount, date: Some(date) });
                continue;
            }
            if bracketed || meaning {
                suspect = Some(Suspect { rank, label: label.clone(), amount });
            }
        }

        transactions.push(Transaction {
            rank,
            date: Some(date),
            amount,
            kind: record.first('N'),
            label,
            fitid: String::new(),
            // Le QIF et le CSV n'ont pas de MEMO à part : le QIF range déjà le
            // sien selon ses propres réglages (P-73), le CSV n'en a pas.
            memo: String::new(),
        });
    }

    let from = transactions.iter().filter_map(|t| t.date).min();
    let to = transactions.iter().filter_map(|t| t.date).max();
    Ok(Read {
        statement: Statement {
            account_number: names[account].clone(),
            ledger_balance: None,
            ledger_balance_date: None,
            available_balance: None,
            available_balance_date: None,
            from,
            to,
            transactions,
        },
        opening,
        suspect,
        rejected,
    })
}

// --- Les phrases ----------------------------------------------------------

fn day_text(date: NaiveDate) -> String {
    date.format("%d/%m/%Y").to_string()
}

/// **Ce que la lecture a écarté ou signalé**, en phrases : la barre
/// d'information et l'icône d'information les montrent.
pub fn notes(read: &Read, language: Language) -> Vec<String> {
    let mut notes = Vec::new();
    if let Some(opening) = read.opening {
        let amount = money::format(opening.amount, language);
        notes.push(match opening.date {
            Some(date) => i18n::message_of(
                language,
                "statement-qif-opening",
                &[("amount", &amount), ("date", &day_text(date))],
                &[],
            ),
            None => i18n::message_of(language, "statement-qif-opening-undated", &[("amount", &amount)], &[]),
        });
    }
    if let Some(suspect) = &read.suspect {
        notes.push(i18n::message_of(
            language,
            "statement-qif-suspect",
            &[
                ("rank", &suspect.rank.to_string()),
                ("label", &suspect.label),
                ("amount", &money::format(suspect.amount, language)),
            ],
            &[],
        ));
    }
    if !read.rejected.is_empty() {
        let lines: Vec<String> = read
            .rejected
            .iter()
            .map(|rejected| {
                let reason = match rejected.reason {
                    Reason::Date => "statement-qif-reason-date",
                    Reason::Amount => "statement-qif-reason-amount",
                    Reason::AmountsDiffer => "statement-qif-reason-differ",
                };
                format!("{} ({})", rejected.rank, i18n::text(language, reason))
            })
            .collect();
        notes.push(i18n::message_of(
            language,
            "statement-qif-rejected",
            &[("lines", &lines.join(", "))],
            &[("count", read.rejected.len() as i64)],
        ));
    }
    notes
}

/// **La phrase d'un refus.**
pub fn problem_text(problem: &Problem, language: Language) -> String {
    match problem {
        Problem::NoSuchAccount => i18n::text(language, "statement-qif-no-account"),
        Problem::DatesMixed { day_first, month_first } => i18n::message_of(
            language,
            "statement-qif-dates-mixed",
            &[("first", day_first), ("second", month_first)],
            &[],
        ),
        Problem::AmountsMixed { dot, comma } => i18n::message_of(
            language,
            "statement-qif-amounts-mixed",
            &[("first", dot), ("second", comma)],
            &[],
        ),
        // Ce n'est pas un refus : la fenêtre pose la question.
        Problem::OrderNeeded { .. } => question(problem, language).map(|asked| asked.text).unwrap_or_default(),
    }
}

/// La question de l'ordre des dates, rédigée : le texte, et les deux réponses
/// avec leur clef.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Question {
    pub text: String,
    pub choices: Vec<String>,
    pub keys: Vec<String>,
}

pub fn question(problem: &Problem, language: Language) -> Option<Question> {
    let Problem::OrderNeeded { sample, first, second } = problem else { return None };
    let say = |key: &str, day: u32, month: u32| {
        i18n::message_of(language, key, &[("day", &day.to_string()), ("month", &month.to_string())], &[])
    };
    Some(Question {
        text: i18n::message_of(language, "statement-qif-question", &[("date", sample)], &[]),
        choices: vec![
            say("statement-qif-day-month", *first, *second),
            say("statement-qif-month-day", *second, *first),
        ],
        keys: vec![DateOrder::DayMonth.key().to_string(), DateOrder::MonthDay.key().to_string()],
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    fn today() -> NaiveDate {
        NaiveDate::from_ymd_opt(2026, 10, 15).unwrap()
    }

    fn options() -> Options {
        Options { order: None, label: LabelChoice::Both, today: today() }
    }

    fn day(year: i32, month: u32, day: u32) -> NaiveDate {
        NaiveDate::from_ymd_opt(year, month, day).unwrap()
    }

    fn euros(text: &str) -> i64 {
        parse_amount(text, Some('.')).unwrap()
    }

    fn read_all(text: &str) -> Read {
        read(text, 0, "releve.qif", options()).expect("lu")
    }

    /// Un relevé à la manière de Microsoft Money, **données inventées** : la
    /// forme exacte des deux fichiers de Fabrice (fins de ligne Windows,
    /// `JJ/MM'AAAA`, montants à l'américaine, solde initial en tête, chèques,
    /// catégories) sans aucune de ses opérations.
    fn money(account: &str, category: &str) -> String {
        [
            "!Type:Bank",
            "D03/02'2025",
            "T2,140.50",
            "CX",
            "PSolde initial",
            &format!("L[{account}]"),
            "^",
            "D03/02'2025",
            "CX",
            "T-42.17",
            "PACHAT CB SUPERMARCHE  02.02.25",
            "^",
            "D05/02'2025",
            "CX",
            "T-120.00",
            "N1234567",
            "PCHEQUE N  1234567",
            "^",
            "D17/02'2025",
            "CX",
            "T1,250.00",
            "PVIREMENT DE EMPLOYEUR",
            "^",
            "D21/02'2025",
            "CX",
            "T-1,005.30",
            "PPRELEVEMENT LOYER",
            &format!("L{category}"),
            "^",
            "",
        ]
        .join("\r\n")
    }

    #[test]
    fn un_releve_money_se_lit_juste() {
        let text = money("Compte courant", "Logement:Loyer");
        assert!(looks_like_qif(&text));
        let read = read_all(&text);
        let lines = &read.statement.transactions;
        assert_eq!(lines.len(), 4, "le solde initial n'est pas une opération");
        assert_eq!(read.opening, Some(Opening { amount: 2_140_500_000, date: Some(day(2025, 2, 3)) }));
        assert_eq!(lines[0].rank, 2, "les numéros sont ceux du fichier");
        assert_eq!(lines[0].date, Some(day(2025, 2, 3)));
        assert_eq!(lines[0].amount, -42_170_000);
        assert_eq!(lines[0].label, "ACHAT CB SUPERMARCHE  02.02.25", "les espaces intérieurs restent");
        assert_eq!(lines[1].kind, "1234567", "le numéro de chèque est gardé");
        assert_eq!(lines[2].amount, 1_250_000_000, "la virgule groupe les milliers");
        assert_eq!(lines[3].amount, -1_005_300_000);
        assert!(lines.iter().all(|line| line.fitid.is_empty()), "aucun identifiant inventé");
        assert_eq!(read.statement.from, Some(day(2025, 2, 3)));
        assert_eq!(read.statement.to, Some(day(2025, 2, 21)));
        assert_eq!(read.statement.ledger_balance, None, "le QIF ne donne pas de solde");
        assert!(read.rejected.is_empty() && read.suspect.is_none());
    }

    /// **Les deux exports de Money** — « compatibilité stricte », qui coupe les
    /// noms, et « relative », qui les garde — donnent exactement le même relevé.
    #[test]
    fn money_strict_et_relatif_donnent_le_meme_releve() {
        let strict = read_all(&money("CCP banque post", "Loisirs-culture:Articles de spo"));
        let relative = read_all(&money("CCP banque postale", "Loisirs-culture-sport:Articles de sport"));
        assert_eq!(strict, relative);
    }

    #[test]
    fn quicken_ecrit_le_mois_d_abord_et_l_apostrophe_veut_dire_2000() {
        let text = "!Type:Bank\nD1/15'05\nT-1,234.56\nPGrocery\n^\nD 2/ 3' 5\nT10.00\nPRefund\n^\n";
        let read = read_all(text);
        assert_eq!(read.statement.transactions[0].date, Some(day(2005, 1, 15)));
        assert_eq!(read.statement.transactions[0].amount, -1_234_560_000);
        assert_eq!(read.statement.transactions[1].date, Some(day(2005, 2, 3)), "le fichier a prouvé l'ordre : mois/jour");
    }

    #[test]
    fn des_montants_a_la_francaise() {
        let text = "!Type:Bank\nD24/11/2022\nT-1 234,56\nPA\n^\nD25/11/2022\nT57,62\nPB\n^\nD26/11/2022\nT1.000.000,00\nPC\n^\n";
        let read = read_all(text);
        let amounts: Vec<i64> = read.statement.transactions.iter().map(|t| t.amount).collect();
        assert_eq!(amounts, vec![-1_234_560_000, 57_620_000, 1_000_000_000_000]);
    }

    #[test]
    fn rien_ne_prouve_l_ordre_on_le_demande() {
        let text = "!Type:Bank\nD05/03/2023\nT-10.00\nPA\n^\nD06/03/2023\nT-20.00\nPB\n^\n";
        let asked = read(text, 0, "f", options()).unwrap_err();
        assert_eq!(asked, Problem::OrderNeeded { sample: "05/03/2023".into(), first: 5, second: 3 });
        let question = question(&asked, Language::French).unwrap();
        assert_eq!(question.choices, vec!["Jour 5, mois 3 (jour/mois)", "Jour 3, mois 5 (mois/jour)"]);
        assert_eq!(question.keys, vec!["day-month", "month-day"]);

        let french = read(text, 0, "f", Options { order: Some(DateOrder::DayMonth), ..options() }).unwrap();
        assert_eq!(french.statement.transactions[0].date, Some(day(2023, 3, 5)));
        let american = read(text, 0, "f", Options { order: Some(DateOrder::MonthDay), ..options() }).unwrap();
        assert_eq!(american.statement.transactions[0].date, Some(day(2023, 5, 3)));
    }

    #[test]
    fn le_fichier_l_emporte_sur_le_reglage() {
        let text = "!Type:Bank\nD05/03/2023\nT-10.00\n^\nD24/03/2023\nT-20.00\n^\n";
        let read = read(text, 0, "f", Options { order: Some(DateOrder::MonthDay), ..options() }).unwrap();
        assert_eq!(read.statement.transactions[0].date, Some(day(2023, 3, 5)), "24/03 prouve jour/mois");
    }

    #[test]
    fn une_date_qui_ne_change_pas_selon_l_ordre_ne_fait_pas_poser_la_question() {
        let read = read_all("!Type:Bank\nD05/05/2023\nT-10.00\n^\nD2023-06-01\nT1.00\n^\n");
        assert_eq!(read.statement.transactions[0].date, Some(day(2023, 5, 5)));
        assert_eq!(read.statement.transactions[1].date, Some(day(2023, 6, 1)));
    }

    #[test]
    fn un_fichier_qui_se_contredit_est_refuse() {
        let dates = "!Type:Bank\nD24/11/2022\nT-1.00\n^\nD11/25/2022\nT-2.00\n^\n";
        assert_eq!(
            read(dates, 0, "f", options()).unwrap_err(),
            Problem::DatesMixed { day_first: "24/11/2022".into(), month_first: "11/25/2022".into() }
        );
        let amounts = "!Type:Bank\nD24/11/2022\nT-1.50\n^\nD25/11/2022\nT-2,50\n^\n";
        assert_eq!(
            read(amounts, 0, "f", options()).unwrap_err(),
            Problem::AmountsMixed { dot: "-1.50".into(), comma: "-2,50".into() }
        );
        let said = problem_text(&read(amounts, 0, "f", options()).unwrap_err(), Language::French);
        assert!(said.contains("-1.50") && said.contains("-2,50") && !said.contains('{'), "{said}");
    }

    /// **Un montant `1,234` se lit d'après le reste du fichier** — jamais au
    /// hasard. Seul, il est écarté en le disant.
    #[test]
    fn un_montant_ambigu_suit_le_fichier_ou_s_ecarte() {
        let with_dot = read_all("!Type:Bank\nD24/11/2022\nT1,234\n^\nD25/11/2022\nT-3.50\n^\n");
        assert_eq!(with_dot.statement.transactions[0].amount, 1_234_000_000);
        let with_comma = read_all("!Type:Bank\nD24/11/2022\nT1.234\n^\nD25/11/2022\nT-3,50\n^\n");
        assert_eq!(with_comma.statement.transactions[0].amount, 1_234_000_000);
        let alone = read_all("!Type:Bank\nD24/11/2022\nT1,234\nPA\n^\nD25/11/2022\nT-3\nPB\n^\n");
        assert_eq!(alone.rejected, vec![Rejected { rank: 1, reason: Reason::Amount }]);
        assert_eq!(alone.statement.transactions.len(), 1);
    }

    #[test]
    fn ce_qui_ne_se_lit_pas_est_ecarte_et_numerote() {
        let text = "!Type:Bank\nD24/11/2022\nT-1.00\nPBon\n^\nD32/13/2022\nT-2.00\nPDate folle\n^\nD25/11/2022\nPSans montant\n^\nT-4.00\nPSans date\n^\nD26/11/2022\nT-5.00\nU-5.01\nPContradiction\n^\nD27/11/2022\nT-6.00\nU-6.00\nPAccord\n^\nD28/11/2022\nT12,34.5\nPGroupes faux\n^\nD01/01/2105\nT-1.00\nPFutur\n^\n";
        let read = read_all(text);
        let kept: Vec<&str> = read.statement.transactions.iter().map(|t| t.label.as_str()).collect();
        assert_eq!(kept, vec!["Bon", "Accord"]);
        assert_eq!(
            read.rejected,
            vec![
                Rejected { rank: 2, reason: Reason::Date },
                Rejected { rank: 3, reason: Reason::Amount },
                Rejected { rank: 4, reason: Reason::Date },
                Rejected { rank: 5, reason: Reason::AmountsDiffer },
                Rejected { rank: 7, reason: Reason::Amount },
                Rejected { rank: 8, reason: Reason::Date },
            ]
        );
        let notes = notes(&read, Language::French).join(" ");
        assert!(notes.contains("2 (date)") && notes.contains("5 (montants contradictoires)"), "{notes}");
    }

    #[test]
    fn plusieurs_comptes_on_n_en_lit_qu_un() {
        let text = "!Option:AutoSwitch\n!Account\nNCourant\nTBank\n^\nNLivret\nTBank\n^\n!Clear:AutoSwitch\n\
                    !Type:Cat\nNAlimentation\nE\n^\n\
                    !Account\nNCourant\nTBank\n^\n!Type:Bank\nD24/11/2022\nT-1.00\nPDu courant\n^\n\
                    !Account\nNTitres\nTInvst\n^\n!Type:Invst\nD24/11/2022\nNBuy\nYACME\nT100.00\n^\n\
                    !Account\nNLivret\nTBank\n^\n!Type:Bank\nD25/11/2022\nT50.00\nPDu livret\n^\n";
        assert_eq!(accounts_in(text, "f.qif"), vec!["Courant", "Livret"], "les titres et les catégories ne sont pas des comptes");
        let second = read(text, 1, "f.qif", options()).unwrap();
        assert_eq!(second.statement.account_number, "Livret");
        assert_eq!(second.statement.transactions.len(), 1);
        assert_eq!(second.statement.transactions[0].label, "Du livret", "rien du compte voisin");
        assert_eq!(read(text, 5, "f.qif", options()).unwrap_err(), Problem::NoSuchAccount);
    }

    #[test]
    fn deux_comptes_sans_nom_sont_numerotes() {
        let text = "!Type:Bank\nD24/11/2022\nT-1.00\n^\n!Type:CCard\nD24/11/2022\nT-2.00\n^\n";
        assert_eq!(accounts_in(text, "export.qif"), vec!["export.qif (1)", "export.qif (2)"]);
    }

    #[test]
    fn le_solde_initial_se_reconnait_aux_deux_indices() {
        // Le nom du compte entre crochets suffit au sens, en toute langue.
        let named = "!Account\nNMon livret\nTBank\n^\n!Type:Bank\nD24/11/2022\nT500.00\nPΑρχικό υπόλοιπο\nL[Mon livret]\n^\nD25/11/2022\nT-1.00\n^\n";
        let read = read_all(named);
        assert!(read.opening.is_some() && read.suspect.is_none());
        assert_eq!(read.statement.transactions.len(), 1);
        // Un seul indice : un vrai virement en tête reste, signalé.
        let transfer = "!Type:Bank\nD24/11/2022\nT-200.00\nPVIREMENT EPARGNE\nL[Livret A]\n^\nD25/11/2022\nT-1.00\n^\n";
        let read = read_all(transfer);
        assert!(read.opening.is_none());
        assert_eq!(read.statement.transactions.len(), 2);
        assert_eq!(read.suspect.as_ref().map(|s| s.rank), Some(1));
        let phrase_only = "!Type:Bank\nD24/11/2022\nT100.00\nPOpening Balance\n^\n";
        let read = read_all(phrase_only);
        assert!(read.opening.is_none() && read.suspect.is_some());
        // Plus loin que la première ligne, ce n'est jamais un solde initial.
        let later = "!Type:Bank\nD24/11/2022\nT-1.00\nPA\n^\nD25/11/2022\nT100.00\nPSolde initial\nL[Compte]\n^\n";
        let read = read_all(later);
        assert!(read.opening.is_none() && read.suspect.is_none());
        assert_eq!(read.statement.transactions.len(), 2);
    }

    #[test]
    fn le_libelle_selon_le_reglage() {
        let text = "!Type:Bank\nD24/11/2022\nT-1.00\nPE.LECLERC\nMCourses semaine\n^\nD25/11/2022\nT-2.00\nMSeul memo\n^\nD26/11/2022\nT-3.00\nPCARTE E.LECLERC\nMe.leclerc\n^\n";
        let with = |label| read(text, 0, "f", Options { label, ..options() }).unwrap().statement.transactions;
        let both: Vec<String> = with(LabelChoice::Both).into_iter().map(|t| t.label).collect();
        assert_eq!(both, vec!["E.LECLERC Courses semaine", "Seul memo", "CARTE E.LECLERC"]);
        let payee: Vec<String> = with(LabelChoice::Payee).into_iter().map(|t| t.label).collect();
        assert_eq!(payee, vec!["E.LECLERC", "Seul memo", "CARTE E.LECLERC"]);
        let memo: Vec<String> = with(LabelChoice::Memo).into_iter().map(|t| t.label).collect();
        assert_eq!(memo, vec!["Courses semaine", "Seul memo", "e.leclerc"]);
    }

    #[test]
    fn les_annees_sur_deux_chiffres() {
        let read = read_all("!Type:Bank\nD15/03/26\nT-1.00\n^\nD15/03/99\nT-1.00\n^\n");
        let dates: Vec<_> = read.statement.transactions.iter().map(|t| t.date).collect();
        assert_eq!(dates, vec![Some(day(2026, 3, 15)), Some(day(1999, 3, 15))]);
    }

    #[test]
    fn fins_de_ligne_marque_d_octets_fichier_tronque_et_sans_en_tete() {
        let mac = "\u{feff}!Type:Bank\rD24/11/2022\rT-1.00\rPA\r^\rD25/11/2022\rT-2.00\rPB";
        let read = read_all(mac);
        assert_eq!(read.statement.transactions.len(), 2, "le dernier enregistrement, sans ^, est gardé");
        let bare = "D24/11/2022\nT-1.00\nPA\n^\n";
        assert!(looks_like_qif(bare));
        assert_eq!(read_all(bare).statement.transactions.len(), 1);
        let lower = "!type:bank\nd24/11/2022\nt-1.00\npA\n^\n";
        assert_eq!(read_all(lower).statement.transactions.len(), 1);
    }

    #[test]
    fn un_csv_ou_un_ofx_ne_passent_pas_pour_un_qif() {
        assert!(!looks_like_qif("Date;Libellé;Montant\n24/11/2022;ACHAT;-1,00\n"));
        assert!(!looks_like_qif("OFXHEADER:100\nDATA:OFXSGML\n<OFX><STMTTRN><TRNAMT>-1.00</STMTTRN></OFX>"));
        assert!(!looks_like_qif(""));
        assert!(!looks_like_qif("Bonjour\n"));
    }

    #[test]
    fn un_qif_en_windows_1252_garde_ses_accents() {
        let bytes = b"!Type:Bank\r\nD24/11/2022\r\nT-1.00\r\nPCaf\xe9 \x80\r\n^\r\n";
        let text = crate::ofx_import::decode(bytes);
        assert_eq!(read_all(&text).statement.transactions[0].label, "Café €");
    }

    /// **L'aller-retour** : ce que l'export QIF de Radinus écrit, l'import le
    /// relit à l'identique — date, montant, libellé.
    #[test]
    fn un_export_radinus_se_relit_a_l_identique() {
        let line = |date: NaiveDate, label: &str, amount: i64| crate::exports::Line {
            date: Some(date),
            label: label.into(),
            amount,
            fitid: String::new(),
            payee: String::new(),
            category: "Alimentation".into(),
            reference: String::new(),
            check_number: String::new(),
        };
        let written = crate::exports::qif(&[
            line(day(2026, 7, 14), "Marché", -23_450_000),
            line(day(2026, 7, 3), "Salaire", 2_100_000_000),
            line(day(2026, 7, 31), "Café", -1_200_000),
        ]);
        let read = read_all(&written);
        let back: Vec<(Option<NaiveDate>, String, i64)> =
            read.statement.transactions.iter().map(|t| (t.date, t.label.clone(), t.amount)).collect();
        assert_eq!(
            back,
            vec![
                (Some(day(2026, 7, 14)), "Marché".into(), -23_450_000),
                (Some(day(2026, 7, 3)), "Salaire".into(), 2_100_000_000),
                (Some(day(2026, 7, 31)), "Café".into(), -1_200_000),
            ]
        );
    }

    #[test]
    fn la_forme_des_montants() {
        assert_eq!(amount_shape("-57.62"), AmountShape::Decimal('.'));
        assert_eq!(amount_shape("3,382.63"), AmountShape::Decimal('.'));
        assert_eq!(amount_shape("1.234.567"), AmountShape::Decimal(','));
        assert_eq!(amount_shape("1,234"), AmountShape::Ambiguous(','));
        assert_eq!(amount_shape("0,123"), AmountShape::Decimal(','));
        assert_eq!(amount_shape("-84"), AmountShape::Whole);
        assert_eq!(amount_shape("12 €"), AmountShape::Unreadable);
        assert_eq!(euros(".5"), 500_000);
        assert_eq!(euros("+7"), 7_000_000);
        assert_eq!(parse_amount("1.2345678", Some('.')), None, "plus de six décimales");
        assert_eq!(parse_amount("99999999999999999999", Some('.')), None, "trop grand");
        assert_eq!(parse_amount("1.2.3", Some('.')), None);
        assert_eq!(parse_amount("--5", Some('.')), None);
    }

    /// **Aucun octet ne fait tomber la lecture.** Un générateur simple, sans
    /// dépendance, fabrique des milliers de fichiers : du bruit, et surtout du
    /// presque-QIF — des lignes valides mélangées, coupées, doublées.
    #[test]
    fn rien_ne_fait_tomber_la_lecture() {
        let mut seed: u64 = 0x5EED_CAFE;
        let mut next = move || {
            seed ^= seed << 13;
            seed ^= seed >> 7;
            seed ^= seed << 17;
            seed
        };
        let pieces = [
            "!Type:Bank", "!type:ccard", "!Account", "!Option:AutoSwitch", "!Clear:AutoSwitch", "!Type:Invst",
            "!Type:Cat", "^", "D24/11'2022", "D1/15'05", "D05/03/2023", "D2023-06-01", "D99/99/99", "D", "D'",
            "D//", "D1/2/3/4", "T-1,234.56", "T1.234,56", "T", "T-", "T1,234", "T.", "T,,", "U5", "PÉté café €",
            "M", "N123", "L[Compte]", "LCat:Sub", "CX", "S", "E", "$1.00", "X", "", " ", "\u{0}", "é", "日本",
        ];
        for round in 0..3000 {
            let text: String = if round % 10 == 0 {
                (0..(next() % 400)).map(|_| char::from_u32((next() % 0x2FFF) as u32).unwrap_or('?')).collect()
            } else {
                let count = next() % 60;
                let separators = ["\n", "\r\n", "\r"];
                (0..count)
                    .map(|_| {
                        let piece = pieces[(next() % pieces.len() as u64) as usize];
                        format!("{piece}{}", separators[(next() % 3) as usize])
                    })
                    .collect()
            };
            let _ = looks_like_qif(&text);
            let accounts = accounts_in(&text, "f");
            for account in 0..=accounts.len() {
                for order in [None, Some(DateOrder::DayMonth), Some(DateOrder::MonthDay)] {
                    if let Ok(read) = read(&text, account, "f", Options { order, ..options() }) {
                        let _ = notes(&read, Language::French);
                    }
                }
            }
        }
    }

    /// **L'épreuve sur de vrais relevés**, qui ne vivent pas dans le projet
    /// (secret bancaire) : `RADINUS_QIF="a.qif;b.qif" cargo test -- --ignored
    /// vrais_releves`. Chaque fichier doit se lire sans ligne écartée, et tous
    /// doivent donner le même relevé — c'est le cas des deux exports Money,
    /// « stricte » et « relative ».
    #[test]
    #[ignore = "demande de vrais fichiers QIF, désignés par RADINUS_QIF"]
    fn vrais_releves() {
        let paths = std::env::var("RADINUS_QIF").unwrap_or_default();
        let mut reads = Vec::new();
        for path in paths.split(';').filter(|path| !path.is_empty()) {
            let text = crate::ofx_import::decode(&std::fs::read(path).expect(path));
            assert!(looks_like_qif(&text), "{path} n'est pas reconnu");
            let read = read(&text, 0, "f", options()).unwrap_or_else(|problem| panic!("{path} : {problem:?}"));
            assert!(read.rejected.is_empty(), "{path} : {:?}", read.rejected);
            let total: i64 = read.statement.transactions.iter().map(|t| t.amount).sum();
            println!(
                "{path} : {} opérations du {:?} au {:?}, solde initial {:?}, total {} ; {}",
                read.statement.transactions.len(),
                read.statement.from,
                read.statement.to,
                read.opening,
                money::format(total, Language::French),
                notes(&read, Language::French).join(" ")
            );
            reads.push(read);
        }
        assert!(!reads.is_empty(), "aucun fichier dans RADINUS_QIF");
        assert!(reads.windows(2).all(|pair| pair[0] == pair[1]), "les fichiers ne donnent pas le même relevé");
    }

    #[test]
    fn chaque_phrase_se_dit_dans_chaque_langue() {
        let keys: Vec<&str> = include_str!("../i18n/fr.ftl")
            .lines()
            .filter(|line| line.starts_with("statement-qif-") || line.starts_with("statement-balance-unknown"))
            .filter_map(|line| line.split_once(" =").map(|(key, _)| key))
            .collect();
        assert!(keys.len() >= 12, "{}", keys.len());
        let texts = [
            ("amount", "1,00 €"), ("date", "05/03/2023"), ("rank", "1"), ("label", "A"), ("lines", "2 (date)"),
            ("first", "a"), ("second", "b"), ("day", "5"), ("month", "3"),
        ];
        for language in Language::all() {
            for key in &keys {
                for count in [1, 2, 5, 21] {
                    let said = i18n::message_of(language, key, &texts, &[("count", count)]);
                    assert!(!said.trim().is_empty(), "« {key} » est vide en {}", language.tag());
                    assert!(!said.contains('{') && !said.contains('}'), "« {key} » garde un trou en {} : {said}", language.tag());
                }
            }
        }
    }
}
