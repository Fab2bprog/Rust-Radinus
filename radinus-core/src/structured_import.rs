//! L'importation d'un fichier JSON ou XML — « Importation de fichier JSON /
//! XML » (Fabrice, 28/10/2026).
//!
//! # Le même assistant que l'Excel, sauf l'étape 1
//!
//! « De la même façon, avec la même philosophie » : les étapes 2 et 3 de
//! l'importation Excel ne travaillent que sur une [`Grid`] — des en-têtes et des
//! lignes — sans savoir d'où elle vient. Ce module fabrique cette grille à
//! partir d'un JSON ou d'un XML, et tout le reste est celui de
//! [`crate::csv_excel_import`] : concordance des champs, politiques, intégration
//! en une transaction, compte-rendu, **aucun contrôle de doublon** — c'est une
//! migration.
//!
//! # On ne devine rien, on fait déclarer — et on montre
//!
//! La règle de l'Excel, gardée telle quelle. Le fichier peut venir de
//! n'importe quel logiciel (« ça peut être n'importe quoi, c'est pour cela
//! qu'il faut être souple »), donc :
//!
//!   * **la liste** à importer est choisie par l'utilisateur parmi celles que
//!     le fichier contient ([`List`]) — comme la feuille d'un classeur ;
//!   * **le format des dates** et **celui des montants** sont déclarés dans
//!     deux menus à exemples ([`DateFormat`], [`AmountFormat`]) : l'aperçu
//!     montre les valeurs brutes juste dessous, et l'utilisateur reconnaît la
//!     sienne. Une ligne qui ne se lit pas avec le format déclaré n'entre pas,
//!     et le compte-rendu le dit ;
//!   * **la forme des montants** (une colonne signée, ou débit et crédit) est
//!     celle de l'Excel, sans rien de plus (« il ne faut rien inventer de
//!     nouveau et non indispensable »).
//!
//! # Mettre une ligne à plat
//!
//! Un objet JSON — ou un élément XML — est une ligne ; chacune de ses clefs
//! une colonne. Ce qui est imbriqué devient « parent.enfant » ; une petite
//! liste de valeurs simples devient un texte séparé par des virgules ; une
//! liste d'objets (une ventilation d'un autre logiciel) ne se met pas à plat et
//! n'est pas importée — elle est **nommée** dans [`List::skipped`], pour que
//! l'aperçu le dise. Les colonnes suivent l'ordre où le fichier les écrit.

use crate::csv_excel_import::{Book, Grid, GridRow, Value};
use crate::domain::NaiveDate;
use std::path::Path;

// ---------------------------------------------------------------------------
// 1. Les formats déclarés
// ---------------------------------------------------------------------------

/// Comment le fichier écrit les dates. Les exemples du menu sont tous le
/// 28 octobre 2026, pour qu'on les compare d'un coup d'œil.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DateFormat {
    /// `2026-10-28`
    Iso,
    /// `2026-10-28T14:30:00` — seule la date est gardée, telle qu'elle est
    /// écrite.
    IsoTime,
    /// `28/10/2026`
    DayMonthSlash,
    /// `10/28/2026`
    MonthDaySlash,
    /// `28.10.2026`
    DayMonthDot,
    /// `28-10-2026`
    DayMonthDash,
    /// `2026/10/28`
    YearMonthSlash,
    /// `1793145600` — secondes depuis le 1er janvier 1970, en temps universel.
    UnixSeconds,
    /// `1793145600000` — millisecondes depuis le 1er janvier 1970.
    UnixMillis,
}

impl DateFormat {
    /// Tous les formats, dans l'ordre du menu. Le premier est le défaut : la
    /// forme la plus courante dans les fichiers JSON.
    pub const ALL: [DateFormat; 9] = [
        DateFormat::Iso,
        DateFormat::IsoTime,
        DateFormat::DayMonthSlash,
        DateFormat::MonthDaySlash,
        DateFormat::DayMonthDot,
        DateFormat::DayMonthDash,
        DateFormat::YearMonthSlash,
        DateFormat::UnixSeconds,
        DateFormat::UnixMillis,
    ];

    pub fn key(self) -> &'static str {
        match self {
            DateFormat::Iso => "iso",
            DateFormat::IsoTime => "iso-time",
            DateFormat::DayMonthSlash => "day-month-slash",
            DateFormat::MonthDaySlash => "month-day-slash",
            DateFormat::DayMonthDot => "day-month-dot",
            DateFormat::DayMonthDash => "day-month-dash",
            DateFormat::YearMonthSlash => "year-month-slash",
            DateFormat::UnixSeconds => "unix-seconds",
            DateFormat::UnixMillis => "unix-millis",
        }
    }

    /// Une clef inconnue donne le défaut.
    pub fn from_key(key: &str) -> Self {
        Self::ALL
            .into_iter()
            .find(|format| format.key() == key)
            .unwrap_or(DateFormat::Iso)
    }

    /// L'exemple que montre le menu — du texte, pas une phrase : il ne se
    /// traduit pas.
    pub fn example(self) -> &'static str {
        match self {
            DateFormat::Iso => "2026-10-28",
            DateFormat::IsoTime => "2026-10-28T14:30:00",
            DateFormat::DayMonthSlash => "28/10/2026",
            DateFormat::MonthDaySlash => "10/28/2026",
            DateFormat::DayMonthDot => "28.10.2026",
            DateFormat::DayMonthDash => "28-10-2026",
            DateFormat::YearMonthSlash => "2026/10/28",
            DateFormat::UnixSeconds => "1793145600",
            DateFormat::UnixMillis => "1793145600000",
        }
    }

    /// Lit une date. `None` quand la valeur ne s'écrit pas ainsi — jamais une
    /// date approchée.
    pub fn read(self, value: &Value) -> Option<NaiveDate> {
        match self {
            DateFormat::UnixSeconds | DateFormat::UnixMillis => {
                let count = whole_number(value)?;
                let stamp = if self == DateFormat::UnixSeconds {
                    time_compute::DateTime::from_timestamp(count, 0)
                } else {
                    time_compute::DateTime::from_timestamp_millis(count)
                };
                stamp.map(|moment| moment.date_naive())
            }
            _ => {
                let Value::Text(text) = value else {
                    return None;
                };
                let text = text.trim();
                // La date seule : ce qui suit un espace ou un « T » est l'heure.
                let day = match self {
                    DateFormat::Iso | DateFormat::IsoTime => text.get(..10)?,
                    _ => text.split_whitespace().next()?,
                };
                let shape = match self {
                    DateFormat::Iso | DateFormat::IsoTime => "%Y-%m-%d",
                    DateFormat::DayMonthSlash => "%d/%m/%Y",
                    DateFormat::MonthDaySlash => "%m/%d/%Y",
                    DateFormat::DayMonthDot => "%d.%m.%Y",
                    DateFormat::DayMonthDash => "%d-%m-%Y",
                    _ => "%Y/%m/%d",
                };
                NaiveDate::parse_from_str(day, shape).ok()
            }
        }
    }
}

/// Un nombre entier, écrit en nombre ou en chiffres.
fn whole_number(value: &Value) -> Option<i64> {
    match value {
        Value::Number(number) if number.fract() == 0.0 && number.abs() < 9.0e15 => {
            Some(*number as i64)
        }
        Value::Text(text) => {
            let text = text.trim();
            let digits = text.strip_prefix('-').unwrap_or(text);
            if digits.is_empty() || !digits.chars().all(|c| c.is_ascii_digit()) {
                return None;
            }
            text.parse().ok()
        }
        _ => None,
    }
}

/// Comment le fichier écrit les montants. Les exemples sont tous 1 250,50.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AmountFormat {
    /// `1250.50` — et tout nombre JSON ordinaire.
    Point,
    /// `1250,50` ou `1 250,50`.
    Comma,
    /// `1.250,50`
    DotThousands,
    /// `1,250.50`
    CommaThousands,
    /// `125050` — en centimes.
    Cents,
    /// `1250500` — en millièmes.
    Thousandths,
}

impl AmountFormat {
    pub const ALL: [AmountFormat; 6] = [
        AmountFormat::Point,
        AmountFormat::Comma,
        AmountFormat::DotThousands,
        AmountFormat::CommaThousands,
        AmountFormat::Cents,
        AmountFormat::Thousandths,
    ];

    pub fn key(self) -> &'static str {
        match self {
            AmountFormat::Point => "point",
            AmountFormat::Comma => "comma",
            AmountFormat::DotThousands => "dot-thousands",
            AmountFormat::CommaThousands => "comma-thousands",
            AmountFormat::Cents => "cents",
            AmountFormat::Thousandths => "thousandths",
        }
    }

    pub fn from_key(key: &str) -> Self {
        Self::ALL
            .into_iter()
            .find(|format| format.key() == key)
            .unwrap_or(AmountFormat::Point)
    }

    pub fn example(self) -> &'static str {
        match self {
            AmountFormat::Point => "1250.50",
            AmountFormat::Comma => "1 250,50",
            AmountFormat::DotThousands => "1.250,50",
            AmountFormat::CommaThousands => "1,250.50",
            AmountFormat::Cents => "125050",
            AmountFormat::Thousandths => "1250500",
        }
    }

    /// Combien de micro-unités vaut une unité du fichier.
    fn scale(self) -> f64 {
        match self {
            AmountFormat::Cents => 10_000.0,
            AmountFormat::Thousandths => 1_000.0,
            _ => 1_000_000.0,
        }
    }

    /// Lit un montant, en micro-unités. `None` quand la valeur ne s'écrit pas
    /// ainsi : « 1.250,50 » déclaré en point décimal est refusé, pas deviné.
    ///
    /// **Un nombre JSON s'écrit toujours avec un point** : pour lui, le format
    /// ne dit que l'unité — unités, centimes ou millièmes.
    pub fn read(self, value: &Value) -> Option<i64> {
        match value {
            Value::Number(number) => {
                let micros = (number * self.scale()).round();
                (micros.abs() < 9.0e18).then_some(micros as i64)
            }
            Value::Text(text) => {
                // Les espaces groupent les milliers ; un symbole monétaire collé
                // au montant est toléré (`money::parse` l'ôte).
                let tight: String = text
                    .chars()
                    .filter(|c| !c.is_whitespace() && *c != '\u{00a0}' && *c != '\u{202f}')
                    .collect();
                if tight.is_empty() {
                    return None;
                }
                let canonical = match self {
                    AmountFormat::Point => {
                        if tight.contains(',') {
                            return None;
                        }
                        tight
                    }
                    AmountFormat::Comma => {
                        if tight.contains('.') {
                            return None;
                        }
                        tight.replace(',', ".")
                    }
                    AmountFormat::DotThousands => tight.replace('.', "").replace(',', "."),
                    AmountFormat::CommaThousands => tight.replace(',', ""),
                    AmountFormat::Cents | AmountFormat::Thousandths => {
                        let count = whole_number(&Value::Text(tight))?;
                        return count.checked_mul(self.scale() as i64);
                    }
                };
                crate::money::parse(&canonical).ok()
            }
            _ => None,
        }
    }
}

/// **Comment les cellules sont lues à l'étape 3.** L'Excel lit avec tolérance —
/// une cellule de date est une date, un montant texte se démêle (`parse_date`,
/// `parse_amount`) ; le JSON et le XML lisent avec les formats déclarés.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub enum Reading {
    #[default]
    Tolerant,
    Declared {
        date: DateFormat,
        amount: AmountFormat,
    },
}

impl Reading {
    pub fn date(&self, value: &Value) -> Option<NaiveDate> {
        match self {
            Reading::Tolerant => crate::csv_excel_import::parse_date(value),
            Reading::Declared { date, .. } => date.read(value),
        }
    }

    pub fn amount(&self, value: &Value) -> Option<i64> {
        match self {
            Reading::Tolerant => crate::csv_excel_import::parse_amount(value),
            Reading::Declared { amount, .. } => amount.read(value),
        }
    }

    /// Le nom d'une opération qui n'en a pas : « une opération sans nom reste
    /// retrouvable » — et elle dit d'où elle vient.
    pub fn fallback_label(&self) -> &'static str {
        match self {
            Reading::Tolerant => "Transaction import excel",
            Reading::Declared { .. } => "Transaction import JSON / XML",
        }
    }
}

// ---------------------------------------------------------------------------
// 2. Le fichier, ses listes, et leur mise à plat
// ---------------------------------------------------------------------------

/// Une liste que le fichier propose à l'import.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct List {
    /// Où elle est : `transactions`, `data/items`, `/` pour la racine d'un
    /// JSON, `banque/operations/operation` pour un XML.
    pub path: String,
    /// Combien d'éléments elle compte.
    pub count: usize,
    /// Les colonnes qui ne se mettent pas à plat — des listes d'objets dans
    /// une ligne — et qui ne seront donc pas importées.
    pub skipped: Vec<String>,
}

/// Le fichier lu : un [`Book`] dont chaque feuille est une liste mise à plat
/// (ligne 1 : les en-têtes ; ensuite un élément par ligne), et la description
/// de ces listes, dans le même ordre.
#[derive(Debug, Clone, Default, PartialEq)]
pub struct Source {
    pub book: Book,
    pub lists: Vec<List>,
}

/// Pourquoi le fichier ne se lit pas. `key` est une clef Fluent ; `detail`,
/// ce que le lecteur a dit, sans traduction possible.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Unreadable {
    pub key: &'static str,
    pub detail: String,
}

impl Unreadable {
    fn new(key: &'static str, detail: impl ToString) -> Self {
        Self {
            key,
            detail: detail.to_string(),
        }
    }
}

/// Ouvre un fichier JSON ou XML. **L'extension décide** ; sans extension
/// connue, le premier caractère tranche (`{` ou `[` : JSON, `<` : XML).
pub fn open(path: &Path) -> Result<Source, Unreadable> {
    let bytes = std::fs::read(path).map_err(|error| Unreadable::new("structured-unreadable", error))?;
    let extension = path
        .extension()
        .and_then(|extension| extension.to_str())
        .unwrap_or("")
        .to_ascii_lowercase();
    match extension.as_str() {
        "json" => read_json(&bytes),
        "xml" => read_xml(&bytes),
        _ => {
            let first = bytes
                .iter()
                .copied()
                .find(|byte| !byte.is_ascii_whitespace() && *byte < 0x80);
            match first {
                Some(b'<') => read_xml(&bytes),
                _ => read_json(&bytes),
            }
        }
    }
}

/// Une cellule et son nom de colonne, dans l'ordre où l'élément les écrit.
type Flat = Vec<(String, Value)>;

/// Range des lignes mises à plat en feuille : les colonnes dans l'ordre de
/// leur première apparition, et une case vide là où un élément n'a pas la clef.
fn sheet_of(flats: Vec<Flat>) -> Vec<Vec<Value>> {
    let mut headers: Vec<String> = Vec::new();
    for flat in &flats {
        for (name, _) in flat {
            if !headers.contains(name) {
                headers.push(name.clone());
            }
        }
    }
    let mut rows = vec![headers.iter().map(|name| Value::Text(name.clone())).collect()];
    for flat in flats {
        let mut row = vec![Value::Empty; headers.len()];
        for (name, value) in flat {
            if let Some(at) = headers.iter().position(|header| *header == name) {
                row[at] = value;
            }
        }
        rows.push(row);
    }
    rows
}

/// La grille d'une liste — ce que l'étape 1 montre et que les étapes 2 et 3
/// reçoivent. **Une ligne porte le numéro de son élément** dans la liste, à
/// partir de 1 : c'est celui que le compte-rendu désigne.
pub fn grid(source: &Source, list: usize) -> Grid {
    let Some(described) = source.lists.get(list) else {
        return Grid::default();
    };
    let width = source.book.width(list);
    let headers = (1..=width)
        .map(|column| source.book.value(list, 1, column).display())
        .collect();
    let rows = (1..=described.count)
        .map(|number| GridRow {
            number,
            cells: (1..=width)
                .map(|column| source.book.value(list, number + 1, column))
                .collect(),
        })
        .filter(|row| !row.cells.iter().all(Value::is_empty))
        .collect();
    Grid { headers, rows }
}

// --- JSON -------------------------------------------------------------------

/// Un nœud JSON **qui garde l'ordre de ses clefs**. `serde_json::Value` les
/// range par ordre alphabétique ; l'aperçu doit montrer les colonnes dans
/// l'ordre où le fichier les écrit, sans rien changer à `serde_json` pour le
/// reste du logiciel.
#[derive(Debug, Clone, PartialEq)]
enum Node {
    Null,
    Bool(bool),
    Number(f64),
    Text(String),
    List(Vec<Node>),
    Object(Vec<(String, Node)>),
}

impl<'de> serde::Deserialize<'de> for Node {
    fn deserialize<D: serde::Deserializer<'de>>(deserializer: D) -> Result<Self, D::Error> {
        struct Visitor;
        impl<'de> serde::de::Visitor<'de> for Visitor {
            type Value = Node;
            fn expecting(&self, formatter: &mut std::fmt::Formatter) -> std::fmt::Result {
                formatter.write_str("une valeur JSON")
            }
            fn visit_unit<E>(self) -> Result<Node, E> {
                Ok(Node::Null)
            }
            fn visit_none<E>(self) -> Result<Node, E> {
                Ok(Node::Null)
            }
            fn visit_bool<E>(self, flag: bool) -> Result<Node, E> {
                Ok(Node::Bool(flag))
            }
            fn visit_i64<E>(self, number: i64) -> Result<Node, E> {
                Ok(Node::Number(number as f64))
            }
            fn visit_u64<E>(self, number: u64) -> Result<Node, E> {
                Ok(Node::Number(number as f64))
            }
            fn visit_f64<E>(self, number: f64) -> Result<Node, E> {
                Ok(Node::Number(number))
            }
            fn visit_str<E>(self, text: &str) -> Result<Node, E> {
                Ok(Node::Text(text.to_string()))
            }
            fn visit_string<E>(self, text: String) -> Result<Node, E> {
                Ok(Node::Text(text))
            }
            fn visit_seq<A: serde::de::SeqAccess<'de>>(self, mut seq: A) -> Result<Node, A::Error> {
                let mut items = Vec::new();
                while let Some(item) = seq.next_element()? {
                    items.push(item);
                }
                Ok(Node::List(items))
            }
            fn visit_map<A: serde::de::MapAccess<'de>>(self, mut map: A) -> Result<Node, A::Error> {
                let mut entries: Vec<(String, Node)> = Vec::new();
                while let Some((key, value)) = map.next_entry::<String, Node>()? {
                    // Une clef écrite deux fois : la dernière gagne, comme
                    // partout en JSON.
                    entries.retain(|(known, _)| *known != key);
                    entries.push((key, value));
                }
                Ok(Node::Object(entries))
            }
        }
        deserializer.deserialize_any(Visitor)
    }
}

/// Une liste d'objets — la seule forme proposée : une liste de listes n'a pas
/// de noms de colonnes, et l'on n'en invente pas.
fn is_list_of_objects(items: &[Node]) -> bool {
    !items.is_empty()
        && items.iter().all(|item| matches!(item, Node::Object(_) | Node::Null))
        && items.iter().any(|item| matches!(item, Node::Object(_)))
}

/// Lit un JSON (UTF-8 ; la marque d'ordre des octets en tête est tolérée).
pub fn read_json(bytes: &[u8]) -> Result<Source, Unreadable> {
    let bytes = bytes.strip_prefix(&[0xEF, 0xBB, 0xBF]).unwrap_or(bytes);
    let text = std::str::from_utf8(bytes).map_err(|_| Unreadable::new("structured-not-utf8", "UTF-8"))?;
    let root: Node = serde_json::from_str(text).map_err(|error| Unreadable::new("structured-not-json", error))?;

    let mut found: Vec<(String, &Vec<Node>)> = Vec::new();
    collect_json(&root, "", &mut found);
    let mut source = Source::default();
    for (path, items) in found {
        let mut skipped = Vec::new();
        let flats = items
            .iter()
            .filter_map(|item| match item {
                Node::Object(entries) => {
                    let mut flat = Flat::new();
                    flatten_json(entries, "", &mut flat, &mut skipped);
                    Some(flat)
                }
                _ => None,
            })
            .collect::<Vec<_>>();
        source.lists.push(List {
            path,
            count: flats.len(),
            skipped,
        });
        source.book.push_sheet(source.lists.last().map(|list| list.path.clone()).unwrap_or_default(), sheet_of(flats));
    }
    Ok(source)
}

/// Les listes d'objets du fichier. **On ne descend pas dans les éléments d'une
/// liste** : des opérations rangées compte par compte donneraient sinon une
/// liste qui mélange les comptes.
fn collect_json<'a>(node: &'a Node, path: &str, found: &mut Vec<(String, &'a Vec<Node>)>) {
    match node {
        Node::List(items) if is_list_of_objects(items) => {
            found.push((if path.is_empty() { "/".to_string() } else { path.to_string() }, items));
        }
        Node::Object(entries) => {
            for (key, value) in entries {
                let inner = if path.is_empty() {
                    key.clone()
                } else {
                    format!("{path}/{key}")
                };
                collect_json(value, &inner, found);
            }
        }
        _ => {}
    }
}

/// Met un objet à plat : « parent.enfant » pour l'imbriqué, un texte à
/// virgules pour une liste de valeurs simples, rien — mais nommé — pour une
/// liste d'objets.
fn flatten_json(entries: &[(String, Node)], prefix: &str, flat: &mut Flat, skipped: &mut Vec<String>) {
    for (key, value) in entries {
        let name = if prefix.is_empty() {
            key.clone()
        } else {
            format!("{prefix}.{key}")
        };
        match value {
            Node::Object(inner) => flatten_json(inner, &name, flat, skipped),
            Node::List(items) => {
                if items.iter().all(|item| !matches!(item, Node::Object(_) | Node::List(_))) {
                    let words: Vec<String> = items.iter().map(scalar_text).filter(|word| !word.is_empty()).collect();
                    flat.push((name, if words.is_empty() { Value::Empty } else { Value::Text(words.join(", ")) }));
                } else if !skipped.contains(&name) {
                    skipped.push(name);
                }
            }
            other => flat.push((name, scalar_value(other))),
        }
    }
}

fn scalar_value(node: &Node) -> Value {
    match node {
        Node::Null => Value::Empty,
        Node::Bool(flag) => Value::Text(flag.to_string()),
        Node::Number(number) => Value::Number(*number),
        Node::Text(text) if text.trim().is_empty() => Value::Empty,
        Node::Text(text) => Value::Text(text.clone()),
        Node::List(_) | Node::Object(_) => Value::Empty,
    }
}

fn scalar_text(node: &Node) -> String {
    scalar_value(node).display()
}

// --- XML --------------------------------------------------------------------

/// Lit un XML. UTF-8 ou ISO-8859-1 (Latin-1), selon ce que sa déclaration
/// annonce ; un autre encodage est refusé en le nommant.
pub fn read_xml(bytes: &[u8]) -> Result<Source, Unreadable> {
    let text = decode_xml(bytes)?;
    let document = roxmltree::Document::parse(&text).map_err(|error| Unreadable::new("structured-not-xml", error))?;

    let mut found: Vec<(String, Vec<roxmltree::Node>)> = Vec::new();
    let root = document.root_element();
    collect_xml(root, root.tag_name().name(), &mut found);
    let mut source = Source::default();
    for (path, items) in found {
        let mut skipped = Vec::new();
        let flats: Vec<Flat> = items
            .iter()
            .map(|item| {
                let mut flat = Flat::new();
                flatten_xml(*item, "", &mut flat, &mut skipped);
                flat
            })
            .collect();
        source.lists.push(List {
            path: path.clone(),
            count: flats.len(),
            skipped,
        });
        source.book.push_sheet(path, sheet_of(flats));
    }
    Ok(source)
}

/// Le texte du fichier, décodé selon la déclaration `encoding="…"`.
fn decode_xml(bytes: &[u8]) -> Result<String, Unreadable> {
    let bytes = bytes.strip_prefix(&[0xEF, 0xBB, 0xBF]).unwrap_or(bytes);
    let head = String::from_utf8_lossy(&bytes[..bytes.len().min(200)]).to_ascii_lowercase();
    let declared = head
        .strip_prefix("<?xml")
        .and_then(|rest| rest.split("?>").next())
        .and_then(|prolog| prolog.split("encoding").nth(1))
        .map(|rest| {
            rest.trim_start_matches([' ', '='])
                .trim_start_matches(['"', '\''])
                .chars()
                .take_while(|c| !matches!(c, '"' | '\''))
                .collect::<String>()
        })
        .unwrap_or_else(|| "utf-8".to_string());
    match declared.trim() {
        "utf-8" | "utf8" | "" => String::from_utf8(bytes.to_vec()).map_err(|_| Unreadable::new("structured-not-utf8", "UTF-8")),
        "iso-8859-1" | "latin1" | "latin-1" | "iso8859-1" => Ok(bytes.iter().map(|byte| char::from(*byte)).collect()),
        other => Err(Unreadable::new("structured-encoding", other)),
    }
}

/// Les enfants éléments d'un nœud, groupés par nom, dans l'ordre de leur
/// première apparition.
fn children_by_name<'a, 'input>(node: roxmltree::Node<'a, 'input>) -> Vec<(&'a str, Vec<roxmltree::Node<'a, 'input>>)> {
    let mut groups: Vec<(&str, Vec<roxmltree::Node>)> = Vec::new();
    for child in node.children().filter(roxmltree::Node::is_element) {
        let name = child.tag_name().name();
        match groups.iter_mut().find(|(known, _)| *known == name) {
            Some((_, members)) => members.push(child),
            None => groups.push((name, vec![child])),
        }
    }
    groups
}

/// Un élément qui fait une ligne : il porte des attributs ou des sous-éléments.
fn is_record(node: roxmltree::Node) -> bool {
    node.attributes().len() > 0 || node.children().any(|child| child.is_element())
}

/// Les listes d'un XML : des éléments **de même nom sous un même parent**, qui
/// font des lignes. Au moins deux — ou un seul quand son parent n'a rien
/// d'autre, comme un relevé d'une seule opération. On ne descend pas dans les
/// éléments d'une liste.
fn collect_xml<'a, 'input>(node: roxmltree::Node<'a, 'input>, path: &str, found: &mut Vec<(String, Vec<roxmltree::Node<'a, 'input>>)>) {
    let groups = children_by_name(node);
    let alone = groups.len() == 1;
    for (name, members) in groups {
        let inner = format!("{path}/{name}");
        let records = members.iter().all(|member| is_record(*member));
        if records && (members.len() >= 2 || alone) {
            found.push((inner, members));
        } else {
            for member in members {
                collect_xml(member, &inner, found);
            }
        }
    }
}

/// Met un élément à plat : ses attributs en « @nom », ses sous-éléments
/// simples en colonnes, l'imbriqué en « parent.enfant », un sous-élément
/// simple répété en texte à virgules, un sous-élément composé répété — nommé
/// dans `skipped` — pas du tout.
fn flatten_xml(node: roxmltree::Node, prefix: &str, flat: &mut Flat, skipped: &mut Vec<String>) {
    let join = |name: &str| {
        if prefix.is_empty() {
            name.to_string()
        } else {
            format!("{prefix}.{name}")
        }
    };
    for attribute in node.attributes() {
        flat.push((join(&format!("@{}", attribute.name())), xml_text(attribute.value())));
    }
    for (name, members) in children_by_name(node) {
        let column = join(name);
        let composed = members.iter().any(|member| member.children().any(|child| child.is_element()));
        if members.len() == 1 {
            let member = members[0];
            if composed {
                flatten_xml(member, &column, flat, skipped);
            } else {
                for attribute in member.attributes() {
                    flat.push((format!("{column}@{}", attribute.name()), xml_text(attribute.value())));
                }
                flat.push((column, xml_text(member.text().unwrap_or(""))));
            }
        } else if composed {
            if !skipped.contains(&column) {
                skipped.push(column);
            }
        } else {
            let words: Vec<String> = members
                .iter()
                .map(|member| member.text().unwrap_or("").trim().to_string())
                .filter(|word| !word.is_empty())
                .collect();
            flat.push((column, if words.is_empty() { Value::Empty } else { Value::Text(words.join(", ")) }));
        }
    }
}

/// Tout est texte en XML ; un texte vide est une case vide.
fn xml_text(text: &str) -> Value {
    if text.trim().is_empty() {
        Value::Empty
    } else {
        Value::Text(text.trim().to_string())
    }
}

// ---------------------------------------------------------------------------
// 3. Les tests — de petits fichiers inventés, jamais un vrai relevé
// ---------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use super::*;

    fn day(year: i32, month: u32, date: u32) -> NaiveDate {
        NaiveDate::from_ymd_opt(year, month, date).expect("date")
    }

    fn text(value: &str) -> Value {
        Value::Text(value.to_string())
    }

    /// **Chaque exemple du menu se lit en 28 octobre 2026** — l'exemple et la
    /// lecture ne peuvent pas se contredire.
    #[test]
    fn every_date_example_reads_as_the_28th_of_october() {
        for format in DateFormat::ALL {
            assert_eq!(format.read(&text(format.example())), Some(day(2026, 10, 28)), "{}", format.key());
        }
        // Les horodatages arrivent aussi en nombre JSON.
        assert_eq!(DateFormat::UnixSeconds.read(&Value::Number(1_793_145_600.0)), Some(day(2026, 10, 28)));
        assert_eq!(DateFormat::UnixMillis.read(&Value::Number(1_793_145_600_000.0)), Some(day(2026, 10, 28)));
        // L'heure après la date ne gêne pas.
        assert_eq!(DateFormat::DayMonthSlash.read(&text("28/10/2026 14:30")), Some(day(2026, 10, 28)));
        assert_eq!(DateFormat::IsoTime.read(&text("2026-10-28T23:59:59+02:00")), Some(day(2026, 10, 28)));
    }

    /// **Un format déclaré ne se devine pas** : une date écrite autrement est
    /// refusée, pas approchée.
    #[test]
    fn a_date_written_otherwise_is_refused() {
        assert_eq!(DateFormat::Iso.read(&text("28/10/2026")), None);
        assert_eq!(DateFormat::DayMonthSlash.read(&text("2026-10-28")), None);
        assert_eq!(DateFormat::MonthDaySlash.read(&text("28/10/2026")), None, "pas de 28e mois");
        assert_eq!(DateFormat::Iso.read(&Value::Number(45_000.0)), None, "un nombre n'est pas une date écrite");
        assert_eq!(DateFormat::UnixSeconds.read(&text("2026-10-28")), None);
        assert_eq!(DateFormat::Iso.read(&Value::Empty), None);
    }

    /// **Chaque exemple de montant se lit en 1 250,50.**
    #[test]
    fn every_amount_example_reads_as_1250_50() {
        for format in AmountFormat::ALL {
            assert_eq!(format.read(&text(format.example())), Some(1_250_500_000), "{}", format.key());
        }
        assert_eq!(AmountFormat::Point.read(&Value::Number(-12.5)), Some(-12_500_000));
        assert_eq!(AmountFormat::Cents.read(&Value::Number(-1250.0)), Some(-12_500_000), "-1250 centimes");
        assert_eq!(AmountFormat::Thousandths.read(&Value::Number(12_500.0)), Some(12_500_000));
        assert_eq!(AmountFormat::Comma.read(&text("-12,50 €")), Some(-12_500_000), "le symbole est toléré");
        assert_eq!(AmountFormat::Point.read(&text("1,250.50")), None, "virgule sans être déclarée");
        assert_eq!(AmountFormat::Comma.read(&text("1.250,50")), None);
        assert_eq!(AmountFormat::Cents.read(&text("12.50")), None, "des centimes sont entiers");
        assert_eq!(AmountFormat::Point.read(&text("douze")), None);
        assert_eq!(AmountFormat::Point.read(&Value::Empty), None);
    }

    /// Un JSON à la manière d'un export de logiciel : une rubrique de tête, la
    /// liste des opérations, de l'imbriqué, des étiquettes, une ventilation.
    const EXPORT: &str = r#"{
        "account": {"name": "Courant", "currency": "EUR"},
        "transactions": [
            {"date": "2026-10-01", "amount": -42.5, "payee": {"name": "Boulangerie", "id": 7},
             "tags": ["pain", "semaine"], "note": null,
             "splits": [{"amount": -40}, {"amount": -2.5}]},
            {"date": "2026-10-02", "amount": 1500, "payee": {"name": "Employeur"}, "memo": "Salaire", "cleared": true}
        ],
        "categories": [{"name": "Alimentation"}, {"name": "Salaire"}]
    }"#;

    #[test]
    fn a_json_export_offers_its_lists_and_flattens_its_rows() {
        let source = read_json(EXPORT.as_bytes()).expect("lu");
        let paths: Vec<(&str, usize)> = source.lists.iter().map(|list| (list.path.as_str(), list.count)).collect();
        assert_eq!(paths, vec![("transactions", 2), ("categories", 2)]);
        assert_eq!(source.lists[0].skipped, vec!["splits".to_string()]);

        let grid = grid(&source, 0);
        // Les colonnes dans l'ordre du fichier, celles du second élément ensuite.
        assert_eq!(
            grid.headers,
            vec!["date", "amount", "payee.name", "payee.id", "tags", "note", "memo", "cleared"]
        );
        assert_eq!(grid.rows.len(), 2);
        assert_eq!(grid.rows[0].number, 1);
        assert_eq!(grid.rows[0].cells[2], text("Boulangerie"));
        assert_eq!(grid.rows[0].cells[4], text("pain, semaine"));
        assert_eq!(grid.rows[0].cells[5], Value::Empty, "null est une case vide");
        assert_eq!(grid.rows[1].cells[1], Value::Number(1500.0));
        assert_eq!(grid.rows[1].cells[3], Value::Empty, "la clef absente est une case vide");
        assert_eq!(grid.rows[1].cells[7], text("true"));
    }

    #[test]
    fn a_json_list_at_the_root_is_offered_too() {
        let source = read_json(br#"[{"d": "28/10/2026", "m": "12,50"}]"#).expect("lu");
        assert_eq!(source.lists[0].path, "/");
        // Une liste de listes n'a pas de noms de colonnes : pas proposée.
        let none = read_json(br#"{"rows": [["2026-10-28", 12.5]]}"#).expect("lu");
        assert!(none.lists.is_empty());
        // La marque d'ordre des octets est tolérée ; un fichier abîmé est dit.
        assert!(read_json(b"\xEF\xBB\xBF[{\"a\": 1}]").is_ok());
        assert_eq!(read_json(b"{pas du json").unwrap_err().key, "structured-not-json");
    }

    const XML: &str = r#"<?xml version="1.0" encoding="UTF-8"?>
        <export xmlns:b="urn:banque">
          <compte><nom>Courant</nom></compte>
          <b:operations>
            <b:operation id="1" date="2026-10-01">
              <libelle>Boulangerie</libelle>
              <montant devise="EUR">-42,50</montant>
              <tiers><nom>Boulangerie</nom></tiers>
              <etiquette>pain</etiquette><etiquette>semaine</etiquette>
              <ventilation><montant>-40</montant></ventilation>
              <ventilation><montant>-2,50</montant></ventilation>
            </b:operation>
            <b:operation id="2" date="2026-10-02">
              <libelle>Salaire</libelle>
              <montant devise="EUR">1500,00</montant>
            </b:operation>
          </b:operations>
        </export>"#;

    #[test]
    fn an_xml_export_offers_its_repeated_elements_and_flattens_them() {
        let source = read_xml(XML.as_bytes()).expect("lu");
        let paths: Vec<(&str, usize)> = source.lists.iter().map(|list| (list.path.as_str(), list.count)).collect();
        // Le préfixe d'espace de noms est ôté ; <compte> est seul, mais son
        // parent a d'autres enfants : ce n'est pas une liste.
        assert_eq!(paths, vec![("export/operations/operation", 2)]);
        assert_eq!(source.lists[0].skipped, vec!["ventilation".to_string()]);

        let grid = grid(&source, 0);
        assert_eq!(
            grid.headers,
            vec!["@id", "@date", "libelle", "montant@devise", "montant", "tiers.nom", "etiquette"]
        );
        assert_eq!(grid.rows[0].cells[4], text("-42,50"));
        assert_eq!(grid.rows[0].cells[6], text("pain, semaine"));
        assert_eq!(grid.rows[1].cells[5], Value::Empty);
        assert_eq!(AmountFormat::Comma.read(&grid.rows[1].cells[4]), Some(1_500_000_000));
        assert_eq!(DateFormat::Iso.read(&grid.rows[1].cells[1]), Some(day(2026, 10, 2)));
    }

    /// **Le croisement** : un JSON d'autre logiciel — montants en centimes,
    /// dates en secondes — entre dans le compte au centime près par les étapes
    /// 2 et 3 de l'Excel, et la ligne illisible est nommée, pas perdue.
    #[test]
    fn a_json_goes_into_the_account_through_the_excel_steps() {
        use crate::csv_excel_import::{run_with, AmountShape, Link, Policies};
        let mut conn = rusqlite::Connection::open_in_memory().expect("base");
        crate::database::schema::migrate(&conn).expect("schéma");
        crate::database::seed::seed_initial_data(&conn).expect("valeurs initiales");
        let account = crate::database::keygen::next_id(&conn, "Compte", "IDCompte").expect("clef");
        conn.execute(
            "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte, ReportPointe) VALUES (?1, 'CCP', 1, 0)",
            [account],
        )
        .expect("compte");

        let source = read_json(
            br#"{"items": [
                {"when": 1793145600, "what": "Boulangerie", "cents": -4250},
                {"when": "1793232000", "what": "", "cents": 150000},
                {"when": "hier", "what": "Perdue", "cents": -100}
            ]}"#,
        )
        .expect("lu");
        let grid = grid(&source, 0);
        let links: Vec<Link> = [("when", "Date"), ("what", "Libelle"), ("cents", "Montant")]
            .iter()
            .map(|(header, field)| Link {
                header: (*header).to_string(),
                field: (*field).to_string(),
            })
            .collect();
        let reading = Reading::Declared {
            date: DateFormat::UnixSeconds,
            amount: AmountFormat::Cents,
        };
        let report = run_with(&mut conn, account, &grid, &links, AmountShape::Single, &Policies::default(), &reading)
            .expect("import");
        assert_eq!(report.imported, 2);
        assert_eq!(report.refused.len(), 1);
        assert_eq!(report.refused[0].row, 3, "le numéro de l'élément dans la liste");

        let rows: Vec<(String, String, i64)> = conn
            .prepare("SELECT Date, Libelle, Montant FROM Operation ORDER BY Date")
            .expect("requête")
            .query_map([], |row| Ok((row.get(0)?, row.get(1)?, row.get(2)?)))
            .expect("lecture")
            .collect::<rusqlite::Result<_>>()
            .expect("lignes");
        assert_eq!(
            rows,
            vec![
                ("2026-10-28".to_string(), "Boulangerie".to_string(), -42_500_000),
                ("2026-10-29".to_string(), "Transaction import JSON / XML".to_string(), 1_500_000_000),
            ]
        );
    }

    #[test]
    fn an_xml_encoding_is_honoured_or_named() {
        let latin = b"<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?><l><o><n>Caf\xE9</n></o><o><n>Th\xE9</n></o></l>";
        let source = read_xml(latin).expect("lu");
        assert_eq!(grid(&source, 0).rows[0].cells[0], text("Café"));
        let other = read_xml(b"<?xml version=\"1.0\" encoding=\"Shift_JIS\"?><l/>").unwrap_err();
        assert_eq!((other.key, other.detail.as_str()), ("structured-encoding", "shift_jis"));
        assert_eq!(read_xml(b"<l><o>").unwrap_err().key, "structured-not-xml");
        // Un seul élément, seul sous son parent : une liste d'une opération.
        let single = read_xml(b"<l><o a=\"1\"/></l>").expect("lu");
        assert_eq!(single.lists[0].count, 1);
    }
}
