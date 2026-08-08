//! L'importation d'une feuille Excel — F34 / F35 (phase 13).
//!
//! Portage de `Import Excel Association Champs.txt`, `Import Excel Association
//! Data.txt` et `Import Excel Liste option association champ.txt`, avec les
//! règles que Fabrice a dictées le 29/07/2026 avant tout code.
//!
//! # Ce module sert une migration, pas un usage quotidien
//!
//! « L'importation d'un fichier Excel a très souvent lieu les premiers temps de
//! l'acquisition de Radinus, pour importer un gros historique de données. Les
//! utilisateurs utilisaient d'autres logiciels et ont décidé de migrer vers
//! Radinus » (Fabrice). Trois conséquences, et ce sont elles qui expliquent
//! toutes les décisions qui suivent :
//!
//!   * **aucun contrôle de doublon** — on importe dans un compte neuf, il n'y a
//!     rien à dédoublonner ; réimporter le même fichier écrira tout deux fois,
//!     et c'est assumé ;
//!   * **trois étapes explicites** valent mieux qu'un devinage automatique : on
//!     les traverse une fois dans la vie du fichier ;
//!   * **le volume arrive d'un bloc**, d'où l'écriture en une seule transaction.
//!
//! # On ne détecte rien, on fait déclarer — et on montre
//!
//! C'est la ruse de l'original, et Fabrice a demandé qu'on la garde : la zone
//! de capture (ligne d'en-tête, colonne de départ, nombre de colonnes,
//! première et dernière ligne de données) est **déclarée par l'utilisateur**,
//! pas devinée. Le rendu test montre ensuite ce que cette zone attrape.
//!
//! La raison tient en une phrase : **une devinette qui se trompe ne se voit
//! pas, une déclaration qui se trompe se voit dans le rendu test**. Un
//! détecteur d'en-têtes aurait raison neuf fois sur dix et écrirait la dixième
//! dans la base sans un mot.
//!
//! Une fois la zone captée, tout s'accroche au **texte de l'en-tête** et jamais
//! au numéro de colonne — c'est [`column_of`], le portage de son
//! `Localise_ColEntete` suivi de `NumCol_EnteteXls`.
//!
//! # Les écarts avec l'original, tous demandés par Fabrice le 29/07/2026
//!
//!   * **deux rubriques de montant en plus** (`Montant_Debit`,
//!     `Montant_Credit`) : beaucoup de logiciels exportent le montant en deux
//!     colonnes. La destination en base ne change pas — il n'y a qu'une colonne
//!     `Montant`, signée ; ce sont les deux origines qui diffèrent. **Le signe
//!     écrit dans la colonne débit ne compte pas** : on prend la valeur absolue
//!     et on la rend négative, parce que certains fichiers écrivent « −50 » et
//!     d'autres « 50 » pour la même sortie d'argent, et qu'un débit importé en
//!     positif fausse le solde du double sans que rien ne se voie ;
//!   * **un compte-rendu de fin** : ce qui n'est pas passé se voit, avec le
//!     numéro de ligne Excel et la raison. Son code sautait les lignes fautives
//!     en silence ; sur 20 000 lignes, une perte muette est inacceptable ;
//!   * **les vraies cellules de date d'Excel sont acceptées**, en plus des deux
//!     formes texte qu'il lit déjà ;
//!   * **on s'arrête aux lignes réelles** de la feuille : la dernière ligne
//!     annoncée vaut 1 000 par défaut, et une feuille de 40 lignes ne doit pas
//!     produire 960 refus ;
//!   * **tout ou rien** : l'import entier dans une seule transaction, comme le
//!     virement de la phase 12.

use crate::domain::NaiveDate;
use crate::nomenclatures::Nomenclature;
use crate::text::french_sort_key;
use rusqlite::{Connection, Result};
use std::collections::BTreeMap;
use std::path::Path;

// ---------------------------------------------------------------------------
// 1. Le classeur, tel que la fenêtre a besoin de le lire
// ---------------------------------------------------------------------------

/// La valeur d'une cellule, réduite à ce dont l'import a besoin.
///
/// Excel n'a **pas** de type « date » : une date y est un nombre portant un
/// format d'affichage daté. La bibliothèque rend donc `Number(45 000)` pour ce
/// que l'utilisateur voit comme « 15/12/2023 » — c'est [`from_cell`] qui
/// tranche, et le doc de [`serial_date`] explique comment sans ambiguïté.
#[derive(Debug, Clone, PartialEq)]
pub enum Value {
    Empty,
    Text(String),
    Number(f64),
    Date(NaiveDate),
}

impl Value {
    /// Ce que la cellule montre — la chaîne que voit l'aperçu, et celle que
    /// lisent les analyses de texte.
    pub fn display(&self) -> String {
        match self {
            Value::Empty => String::new(),
            Value::Text(text) => clean(text),
            Value::Number(number) => plain_number(*number),
            Value::Date(day) => day.format("%d/%m/%Y").to_string(),
        }
    }

    pub fn is_empty(&self) -> bool {
        matches!(self, Value::Empty) || self.display().trim().is_empty()
    }
}

/// Un nombre écrit sans notation scientifique et sans zéros inutiles — un
/// numéro de compte à quatorze chiffres ne doit pas devenir `1.2e13`.
fn plain_number(number: f64) -> String {
    if number == number.trunc() && number.abs() < 1e15 {
        return format!("{}", number as i64);
    }
    let mut text = format!("{number:.6}");
    while text.ends_with('0') {
        text.pop();
    }
    if text.ends_with('.') {
        text.pop();
    }
    text
}

/// Le nettoyage de son `Optimise_ValChampsXls` : on retire l'espace insécable,
/// on rogne les bords, et l'on réduit toute suite d'espaces à une seule.
pub fn clean(text: &str) -> String {
    let without_nbsp: String = text
        .chars()
        .map(|c| if c == '\u{00a0}' || c == '\u{202f}' { ' ' } else { c })
        .collect();
    without_nbsp.split_whitespace().collect::<Vec<_>>().join(" ")
}

/// Le classeur ouvert, réduit aux valeurs de ses cellules.
///
/// Il est gardé en mémoire d'un bout à l'autre des trois étapes : on ne relit
/// pas le fichier entre l'étape 1 et l'intégration, faute de quoi une
/// modification du fichier en cours de route ferait entrer autre chose que ce
/// que le rendu test a montré.
#[derive(Debug, Clone, Default)]
pub struct Book {
    /// Le nom de chaque feuille, dans l'ordre du classeur.
    pub sheet_names: Vec<String>,
    /// `sheets[feuille][ligne][colonne]`, indices à partir de 0.
    sheets: Vec<Vec<Vec<Value>>>,
}

impl Book {
    /// La valeur d'une cellule, **en coordonnées d'Excel** : ligne 1, colonne 1
    /// pour A1. Hors de la feuille, une cellule vide — c'est ce qui permet
    /// d'annoncer une zone trop large sans provoquer d'erreur.
    pub fn value(&self, sheet: usize, row: usize, column: usize) -> Value {
        if row == 0 || column == 0 {
            return Value::Empty;
        }
        self.sheets
            .get(sheet)
            .and_then(|rows| rows.get(row - 1))
            .and_then(|cells| cells.get(column - 1))
            .cloned()
            .unwrap_or(Value::Empty)
    }

    /// Le numéro de la dernière ligne réellement présente dans la feuille.
    pub fn last_row(&self, sheet: usize) -> usize {
        self.sheets.get(sheet).map_or(0, Vec::len)
    }

    /// Combien de colonnes porte la ligne la plus large de la feuille.
    pub fn width(&self, sheet: usize) -> usize {
        self.sheets
            .get(sheet)
            .map_or(0, |rows| rows.iter().map(Vec::len).max().unwrap_or(0))
    }

    /// Une feuille bâtie à la main — ce dont les tests ont besoin, et rien de
    /// plus.
    pub fn with_sheet(name: &str, rows: Vec<Vec<Value>>) -> Self {
        Self {
            sheet_names: vec![name.to_string()],
            sheets: vec![rows],
        }
    }
}

/// Ouvre un `.xlsx` et en tire son [`Book`].
///
/// `office-toolkit` est la crate de Fabrice, déjà autorisée et déjà utilisée
/// pour **écrire** les classeurs de l'export : elle sait aussi les lire, si
/// bien que cette phase n'ajoute aucune dépendance.
pub fn open(path: &Path) -> std::result::Result<Book, String> {
    use office_toolkit::excel::Workbook;
    use office_toolkit::OpenFile;

    let workbook = Workbook::open_file(path).map_err(|error| error.to_string())?;
    let mut book = Book::default();
    for sheet in &workbook.sheets {
        book.sheet_names.push(sheet.name.clone());
        book.sheets.push(
            sheet
                .rows
                .iter()
                .map(|row| row.cells.iter().map(from_cell).collect())
                .collect(),
        );
    }
    Ok(book)
}

/// Traduit une cellule de la bibliothèque en [`Value`].
fn from_cell(cell: &office_toolkit::excel::Cell) -> Value {
    use office_toolkit::excel::CellValue;
    let dated = cell
        .format
        .as_ref()
        .and_then(|format| format.number_format.as_ref())
        .is_some_and(|code| looks_like_a_date_format(code));
    let number_value = |number: f64| match (dated, serial_date(number)) {
        (true, Some(day)) => Value::Date(day),
        _ => Value::Number(number),
    };
    match &cell.value {
        CellValue::Empty => Value::Empty,
        CellValue::Text(text) => Value::Text(text.clone()),
        CellValue::RichText(runs) => {
            Value::Text(runs.iter().map(|run| run.text.as_str()).collect())
        }
        CellValue::Boolean(flag) => Value::Text(flag.to_string()),
        CellValue::Number(number) => number_value(*number),
        CellValue::Date(stamp) => NaiveDate::from_ymd_opt(stamp.year, stamp.month, stamp.day)
            .map_or(Value::Empty, Value::Date),
        CellValue::Formula { cached_value, .. }
        | CellValue::ArrayFormula { cached_value, .. }
        | CellValue::SharedFormula { cached_value, .. } => {
            cached_value.map_or(Value::Empty, number_value)
        }
    }
}

/// Un format d'affichage qui parle de dates. Les portions entre guillemets et
/// entre crochets sont du décor et ne comptent pas — `[Red]"jour "0` n'est pas
/// une date à cause de son `d`.
fn looks_like_a_date_format(code: &str) -> bool {
    let mut kept = String::new();
    let mut in_quotes = false;
    let mut in_brackets = false;
    for c in code.chars() {
        match c {
            '"' => in_quotes = !in_quotes,
            '[' => in_brackets = true,
            ']' => in_brackets = false,
            _ if in_quotes || in_brackets => {}
            _ => kept.push(c.to_ascii_lowercase()),
        }
    }
    kept.contains('y') || kept.contains('d')
}

/// Un numéro de série Excel converti en date, ou `None` si le nombre n'en est
/// pas un.
///
/// **Les deux écritures ne se recouvrent jamais**, et c'est ce qui rend la
/// décision sûre sans même connaître le format d'affichage de la cellule : un
/// numéro de série valide va de 1 à 2 958 465 (31/12/9999), tandis que la forme
/// compacte `20251103` que lit le code de Fabrice vaut au moins 19 000 101.
/// Aucun nombre ne peut être pris pour l'autre.
///
/// Excel compte les jours depuis le 30/12/1899 — un jour de trop, hérité du
/// 29 février 1900 qui n'a jamais existé et que le tableur compte quand même ;
/// avant le 61ᵉ jour, il faut donc partir du 31/12/1899.
pub fn serial_date(number: f64) -> Option<NaiveDate> {
    if !(1.0..2_958_466.0).contains(&number) {
        return None;
    }
    let days = number.trunc() as u64;
    let origin = if days < 60 {
        NaiveDate::from_ymd_opt(1899, 12, 31)?
    } else {
        NaiveDate::from_ymd_opt(1899, 12, 30)?
    };
    origin.checked_add_days(time_compute::Days::new(days))
}

// ---------------------------------------------------------------------------
// 2. Étape 1/3 — la zone de capture
// ---------------------------------------------------------------------------

/// Comment le fichier écrit les montants — la question que Fabrice a demandé
/// d'insérer entre ses groupes 3 et 4, en deux boutons radio.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AmountShape {
    /// Une colonne unique, signée. C'est la seule forme de l'original.
    Single,
    /// Deux colonnes, l'une pour les sorties, l'autre pour les entrées.
    DebitCredit,
}

impl AmountShape {
    pub fn key(self) -> &'static str {
        match self {
            AmountShape::Single => "single",
            AmountShape::DebitCredit => "debit-credit",
        }
    }

    pub fn from_key(key: &str) -> Self {
        if key == "debit-credit" {
            AmountShape::DebitCredit
        } else {
            AmountShape::Single
        }
    }
}

/// Les réglages de l'étape 1, tous déclarés par l'utilisateur.
///
/// Les numéros comptent **à partir de 1**, comme dans Excel : « colonne début
/// entête : A » vaut 1.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Capture {
    /// L'indice de la feuille dans le classeur, à partir de 0.
    pub sheet: usize,
    pub header_row: usize,
    pub first_column: usize,
    pub column_count: usize,
    pub first_data_row: usize,
    pub last_data_row: usize,
    pub shape: AmountShape,
}

impl Default for Capture {
    /// Les valeurs de sa capture d'écran.
    fn default() -> Self {
        Self {
            sheet: 0,
            header_row: 1,
            first_column: 1,
            column_count: 15,
            first_data_row: 2,
            last_data_row: 1_000,
            shape: AmountShape::Single,
        }
    }
}

/// Une ligne captée : son numéro dans la feuille, et ses cellules.
#[derive(Debug, Clone, PartialEq)]
pub struct GridRow {
    /// Le numéro de la ligne **dans Excel**, pour que le compte-rendu des refus
    /// désigne quelque chose que l'utilisateur puisse retrouver.
    pub number: usize,
    pub cells: Vec<Value>,
}

/// Ce que la zone de capture attrape : les en-têtes et les lignes.
#[derive(Debug, Clone, Default, PartialEq)]
pub struct Grid {
    pub headers: Vec<String>,
    pub rows: Vec<GridRow>,
}

/// Applique la zone de capture.
///
/// **On s'arrête aux lignes réelles** (décision de Fabrice) : la dernière ligne
/// annoncée est un plafond, pas une promesse, et les lignes entièrement vides
/// ne comptent pas — sans quoi une feuille de 40 lignes annoncée jusqu'à 1 000
/// produirait 960 refus qui noieraient les vrais.
pub fn capture(book: &Book, settings: &Capture) -> Grid {
    let columns = settings.first_column..settings.first_column + settings.column_count;
    let headers = columns
        .clone()
        .map(|column| {
            book.value(settings.sheet, settings.header_row, column)
                .display()
        })
        .collect();

    let last = settings.last_data_row.min(book.last_row(settings.sheet));
    let mut rows = Vec::new();
    let mut number = settings.first_data_row;
    while number <= last {
        let cells: Vec<Value> = columns
            .clone()
            .map(|column| book.value(settings.sheet, number, column))
            .collect();
        if !cells.iter().all(Value::is_empty) {
            rows.push(GridRow { number, cells });
        }
        number += 1;
    }
    Grid { headers, rows }
}

// ---------------------------------------------------------------------------
// 3. Étape 2/3, premier onglet — la concordance des champs
// ---------------------------------------------------------------------------

/// La valeur qui n'importe rien. **Elle est en tête de sa liste, donc c'est le
/// défaut** : une ligne de concordance qu'on n'a pas réglée ne fait jamais
/// entrer de données par accident.
pub const IGNORE: &str = "[IGNORE]";

/// Les rubriques Radinus, dans l'ordre et l'orthographe de son
/// `Import Excel Liste option association champ.txt`.
///
/// Ce ne sont pas des libellés d'affichage : ce sont les clefs sur lesquelles
/// [`column_of`] compare. Écrire « Libellé » avec son accent casserait la
/// recherche. Ni tiers, ni projet, ni statut, ni référence de paiement — la
/// fiche opération les a, l'import Excel non, et l'on n'en ajoute pas.
pub fn fields(shape: AmountShape) -> Vec<&'static str> {
    let mut list = vec![IGNORE, "Date", "Date_Pointage", "Libelle"];
    match shape {
        AmountShape::Single => list.push("Montant"),
        AmountShape::DebitCredit => {
            list.push("Montant_Debit");
            list.push("Montant_Credit");
        }
    }
    list.extend(["Categorie", "Affectation", "Mode_Paiement", "Commentaires"]);
    list
}

/// Une ligne du tableau de concordance. **Les deux côtés se règlent** : à
/// gauche l'en-tête Excel, à droite la rubrique Radinus, et les deux acceptent
/// [`IGNORE`].
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Link {
    pub header: String,
    pub field: String,
}

/// Le tableau tel qu'il s'ouvre : une ligne par colonne captée, l'en-tête à
/// gauche, rien de réglé à droite.
pub fn initial_links(grid: &Grid) -> Vec<Link> {
    grid.headers
        .iter()
        .map(|header| Link {
            header: header.clone(),
            field: IGNORE.to_string(),
        })
        .collect()
}

/// Dans quelle colonne de la grille se trouve une rubrique — le portage de
/// `Localise_ColEntete` suivi de `NumCol_EnteteXls`.
///
/// On part de la rubrique, on trouve la ligne du tableau qui la porte, on lit
/// l'en-tête Excel qu'elle désigne, et l'on cherche cet en-tête **parmi les
/// en-têtes captés** — jamais ailleurs dans la feuille.
pub fn column_of(links: &[Link], grid: &Grid, field: &str) -> Option<usize> {
    let wanted = links
        .iter()
        .find(|link| link.field.eq_ignore_ascii_case(field))?;
    if wanted.header == IGNORE || wanted.header.trim().is_empty() {
        return None;
    }
    grid.headers
        .iter()
        .position(|header| header.eq_ignore_ascii_case(&wanted.header))
}

/// Les rubriques de montant que la forme déclarée réclame.
fn amount_fields(shape: AmountShape) -> &'static [&'static str] {
    match shape {
        AmountShape::Single => &["Montant"],
        AmountShape::DebitCredit => &["Montant_Debit", "Montant_Credit"],
    }
}

/// Pourquoi cette concordance ne peut pas partir, ou `None` si elle le peut.
/// La clef Fluent est rendue plutôt que la phrase : ce module ne parle aucune
/// langue.
///
/// Les trois barrières de son `Verif_Parametrage`, avec la variante du montant.
/// Les nomenclatures restent **facultatives** : une catégorie non renseignée
/// n'empêche rien, la classification rapide est là pour trier après coup.
pub fn refusal(links: &[Link], grid: &Grid, shape: AmountShape) -> Option<&'static str> {
    let mut required: Vec<&str> = vec!["Date", "Libelle"];
    required.extend(amount_fields(shape));
    for field in required {
        if column_of(links, grid, field).is_none() {
            return Some("excel-refusal-required");
        }
    }

    // Deux rubriques différentes ne peuvent pas viser la même colonne Excel.
    // On parcourt les **rubriques**, comme son `TabCol` : deux lignes portant
    // la même rubrique désignent forcément la même colonne, et c'est l'autre
    // barrière qui les attrape.
    let mut taken: Vec<usize> = Vec::new();
    for field in fields(shape).into_iter().filter(|field| *field != IGNORE) {
        let Some(column) = column_of(links, grid, field) else {
            continue;
        };
        if taken.contains(&column) {
            return Some("excel-refusal-column-twice");
        }
        taken.push(column);
    }

    // Et une même rubrique ne peut pas apparaître deux fois.
    let mut seen: Vec<String> = Vec::new();
    for link in links.iter().filter(|link| link.field != IGNORE) {
        let key = link.field.to_ascii_lowercase();
        if seen.contains(&key) {
            return Some("excel-refusal-field-twice");
        }
        seen.push(key);
    }
    None
}

// ---------------------------------------------------------------------------
// 4. Étape 2/3, second onglet — les valeurs sans correspondance
// ---------------------------------------------------------------------------

/// Que faire d'une valeur de nomenclature que Radinus ne connaît pas.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Policy {
    /// Créer automatiquement les inexistantes.
    Create,
    /// Demander pour chacune où transférer les données.
    Ask,
    /// Laisser vierge.
    Blank,
    /// Transférer dans une valeur par défaut.
    Default,
}

impl Policy {
    pub fn key(self) -> &'static str {
        match self {
            Policy::Create => "create",
            Policy::Ask => "ask",
            Policy::Blank => "blank",
            Policy::Default => "default",
        }
    }

    pub fn from_key(key: &str) -> Self {
        match key {
            "ask" => Policy::Ask,
            "blank" => Policy::Blank,
            "default" => Policy::Default,
            _ => Policy::Create,
        }
    }
}

/// Le réglage d'une des trois nomenclatures.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Rule {
    pub policy: Policy,
    /// La valeur choisie pour « transférer dans une valeur par défaut ».
    pub default_id: i64,
    /// Ce que la fenêtre d'association a rapporté, sous la clef normalisée du
    /// libellé Excel. Vide tant qu'elle n'a pas servi.
    pub chosen: BTreeMap<String, i64>,
    /// La fenêtre d'association a-t-elle été ouverte et validée ? Une politique
    /// « demander » qu'on n'a jamais renseignée bloque la validation de
    /// l'étape 2 (décision de Fabrice, 29/07/2026) : on ne laisse pas un choix
    /// rester sans effet.
    pub answered: bool,
}

impl Default for Rule {
    /// Ce que montre sa capture : « créer automatiquement les inexistantes ».
    fn default() -> Self {
        Self {
            policy: Policy::Create,
            default_id: 0,
            chosen: BTreeMap::new(),
            answered: false,
        }
    }
}

/// Les trois réglages du second onglet.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct Policies {
    pub category: Rule,
    pub assignment: Rule,
    pub payment_mode: Rule,
}

impl Policies {
    pub fn rule(&self, kind: Nomenclature) -> &Rule {
        match kind {
            Nomenclature::Assignment => &self.assignment,
            Nomenclature::PaymentMode => &self.payment_mode,
            _ => &self.category,
        }
    }

    pub fn rule_mut(&mut self, kind: Nomenclature) -> &mut Rule {
        match kind {
            Nomenclature::Assignment => &mut self.assignment,
            Nomenclature::PaymentMode => &mut self.payment_mode,
            _ => &mut self.category,
        }
    }
}

/// Les trois nomenclatures que l'import Excel sait classer, et la rubrique qui
/// les porte.
pub const SORTED: [(Nomenclature, &str); 3] = [
    (Nomenclature::Category, "Categorie"),
    (Nomenclature::Assignment, "Affectation"),
    (Nomenclature::PaymentMode, "Mode_Paiement"),
];

/// La rubrique qui porte une nomenclature.
pub fn field_of(kind: Nomenclature) -> &'static str {
    SORTED
        .iter()
        .find(|(sorted, _)| *sorted == kind)
        .map_or("Categorie", |(_, field)| *field)
}

/// La clef sous laquelle deux libellés sont **le même**.
///
/// Son tableau associatif est déclaré `ccSansCasse + ccSansAccent +
/// ccSansPonctuationNiEspace` : « Frais financiers » et « FRAIS-FINANCIERS »
/// sont une seule et même catégorie. C'est exactement notre collation
/// française, qui ne garde que les lettres et les chiffres.
pub fn key_of(label: &str) -> String {
    french_sort_key(label)
}

/// Les valeurs distinctes que porte la colonne d'une nomenclature, dans l'ordre
/// où elles apparaissent, **sans celles que Radinus connaît déjà**.
///
/// C'est ce que montre la fenêtre d'association des données : uniquement ce
/// qu'il faut ranger.
pub fn unknown_values(
    conn: &Connection,
    grid: &Grid,
    links: &[Link],
    kind: Nomenclature,
) -> Result<Vec<String>> {
    let Some(column) = column_of(links, grid, field_of(kind)) else {
        return Ok(Vec::new());
    };
    let known = existing(conn, kind)?;
    let mut seen: Vec<String> = Vec::new();
    let mut values: Vec<String> = Vec::new();
    for row in &grid.rows {
        let Some(cell) = row.cells.get(column) else {
            continue;
        };
        let label = cell.display();
        if label.trim().is_empty() {
            continue;
        }
        let key = key_of(&label);
        if known.contains_key(&key) || seen.contains(&key) {
            continue;
        }
        seen.push(key);
        values.push(label);
    }
    Ok(values)
}

/// Ce que Radinus connaît déjà, sous la clef normalisée.
fn existing(conn: &Connection, kind: Nomenclature) -> Result<BTreeMap<String, i64>> {
    Ok(crate::nomenclatures::list(conn, kind)?
        .into_iter()
        .map(|item| (key_of(&item.label), item.id))
        .collect())
}

// ---------------------------------------------------------------------------
// 5. Lecture des valeurs — montants et dates
// ---------------------------------------------------------------------------

/// Un montant, en micro-unités, lu **par la droite** — le portage de son
/// `Extract_Montant_Xls`, et la même doctrine que pour l'OFX.
///
/// On retire les « T », les espaces insécables et toutes les espaces. Puis :
/// plusieurs virgules sont forcément des séparateurs de milliers et sautent
/// toutes ; une virgule unique n'est décimale **que si elle est en troisième
/// position depuis la fin**, sinon c'est un séparateur de milliers et elle
/// saute elle aussi.
///
/// Une cellule numérique ne passe pas par là : sa valeur est exacte, et la
/// réécrire en texte pour la relire n'ajouterait que des occasions de se
/// tromper.
pub fn parse_amount(value: &Value) -> Option<i64> {
    if let Value::Number(number) = value {
        return Some((number * 1_000_000.0).round() as i64);
    }
    let text = value.display();
    let mut cleaned: String = text
        .chars()
        .filter(|c| !c.is_whitespace() && *c != '\u{00a0}' && *c != '\u{202f}' && *c != 'T')
        .collect();
    let commas = cleaned.matches(',').count();
    if commas > 1 {
        cleaned = cleaned.replace(',', "");
    } else if commas == 1 {
        let decimal = cleaned.len() >= 3 && cleaned.chars().nth(cleaned.len() - 3) == Some(',');
        cleaned = if decimal {
            cleaned.replace(',', ".")
        } else {
            cleaned.replace(',', "")
        };
    }
    if cleaned.is_empty() {
        return None;
    }
    crate::money::parse(&cleaned).ok()
}

/// Une date — le portage de son `Netoyer_Date`, plus les vraies cellules de
/// date d'Excel que Fabrice a demandé d'accepter le 29/07/2026.
///
/// Si la valeur porte un `/` ou un `-`, on la lit comme une date écrite ;
/// sinon on la lit comme la forme compacte `20251103` que montrent ses
/// captures.
pub fn parse_date(value: &Value) -> Option<NaiveDate> {
    match value {
        Value::Date(day) => return Some(*day),
        // Un nombre nu dans une colonne de date : soit un numéro de série
        // Excel, soit la forme compacte. Les deux plages ne se recouvrent pas.
        Value::Number(number) => {
            if let Some(day) = serial_date(*number) {
                return Some(day);
            }
        }
        _ => {}
    }
    let text: String = value
        .display()
        .chars()
        .filter(|c| !c.is_whitespace())
        .collect();
    if text.is_empty() {
        return None;
    }
    if text.contains('/') || text.contains('-') {
        for shape in ["%d/%m/%Y", "%d/%m/%y", "%Y-%m-%d", "%d-%m-%Y", "%Y/%m/%d"] {
            if let Ok(day) = NaiveDate::parse_from_str(&text, shape) {
                return Some(day);
            }
        }
        return None;
    }
    NaiveDate::parse_from_str(&text, "%Y%m%d").ok()
}

// ---------------------------------------------------------------------------
// 6. Étape 3/3 — l'intégration
// ---------------------------------------------------------------------------

/// Une ligne qui n'est pas entrée, et pourquoi.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Refused {
    /// Son numéro dans la feuille Excel — celui qu'on retrouve en ouvrant le
    /// fichier.
    pub row: usize,
    /// Ce que la ligne portait, pour la reconnaître sans ouvrir le fichier.
    pub content: String,
    /// Clef Fluent de la raison.
    pub reason: &'static str,
}

/// Ce que l'import a fait. **Ce qui n'est pas passé se voit** : c'est l'écart
/// avec l'original, demandé par Fabrice.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct Report {
    pub imported: i64,
    pub refused: Vec<Refused>,
    /// Les valeurs de nomenclature créées au passage, par la politique
    /// « créer automatiquement les inexistantes ».
    pub created: i64,
}

/// Ce que la ligne portait, en une phrase courte pour le compte-rendu.
fn summarize(row: &GridRow) -> String {
    let parts: Vec<String> = row
        .cells
        .iter()
        .map(Value::display)
        .filter(|text| !text.trim().is_empty())
        .take(4)
        .collect();
    parts.join(" · ")
}

/// Fait l'import.
///
/// **Tout ou rien** (décision de Fabrice, 29/07/2026) : les opérations et les
/// valeurs de nomenclature créées au passage partent dans une seule
/// transaction. À la moindre panne, la base est exactement comme avant et
/// l'utilisateur recommence avec son fichier corrigé — une demi-migration
/// serait pire que pas de migration du tout, parce qu'elle ne se voit pas.
///
/// Les soldes sont recalculés **après** le commit, comme pour le virement : un
/// solde faux se répare, un demi-import non.
pub fn run(
    conn: &mut Connection,
    account_id: i64,
    grid: &Grid,
    links: &[Link],
    shape: AmountShape,
    policies: &Policies,
) -> Result<Report> {
    let date_at = column_of(links, grid, "Date");
    let clearing_at = column_of(links, grid, "Date_Pointage");
    let label_at = column_of(links, grid, "Libelle");
    let comment_at = column_of(links, grid, "Commentaires");
    let single_at = column_of(links, grid, "Montant");
    let debit_at = column_of(links, grid, "Montant_Debit");
    let credit_at = column_of(links, grid, "Montant_Credit");

    let mut report = Report::default();
    let tx = conn.transaction()?;

    // Le pré-balayage de ses `OPT_*` : avant d'écrire quoi que ce soit, on
    // construit le dictionnaire « libellé Excel → identifiant Radinus ». Une
    // politique ne s'applique donc pas ligne par ligne, mais une fois pour
    // toutes — et c'est ce qui fait que « créer automatiquement » ne crée pas
    // trois fois la même catégorie.
    let mut dictionaries: Vec<(Nomenclature, Option<usize>, BTreeMap<String, i64>)> = Vec::new();
    for (kind, field) in SORTED {
        let column = column_of(links, grid, field);
        let mut table = BTreeMap::new();
        if let Some(column) = column {
            table = sort_values(&tx, grid, column, kind, policies.rule(kind), &mut report)?;
        }
        dictionaries.push((kind, column, table));
    }
    let lookup = |kind: Nomenclature, row: &GridRow| -> i64 {
        let Some((_, column, table)) = dictionaries.iter().find(|(sorted, _, _)| *sorted == kind)
        else {
            return 0;
        };
        let Some(column) = column else { return 0 };
        let Some(cell) = row.cells.get(*column) else {
            return 0;
        };
        let label = cell.display();
        if label.trim().is_empty() {
            return 0;
        }
        table.get(&key_of(&label)).copied().unwrap_or(0)
    };

    for row in &grid.rows {
        let cell = |at: Option<usize>| -> Value {
            at.and_then(|column| row.cells.get(column))
                .cloned()
                .unwrap_or(Value::Empty)
        };

        let Some(date) = parse_date(&cell(date_at)) else {
            report.refused.push(Refused {
                row: row.number,
                content: summarize(row),
                reason: "excel-refused-date",
            });
            continue;
        };
        // Sa règle : la date de pointage vaut la date de l'opération quand la
        // colonne manque ou ne porte rien de lisible.
        let clearing = parse_date(&cell(clearing_at)).unwrap_or(date);

        let read = match shape {
            AmountShape::Single => parse_amount(&cell(single_at)).ok_or("excel-refused-amount"),
            AmountShape::DebitCredit => {
                // **Le signe écrit ne compte pas** : un débit sort de l'argent,
                // qu'il soit noté « −50 » ou « 50 ».
                let debit = parse_amount(&cell(debit_at)).filter(|amount| *amount != 0);
                let credit = parse_amount(&cell(credit_at)).filter(|amount| *amount != 0);
                match (debit, credit) {
                    (Some(_), Some(_)) => Err("excel-refused-amount-both"),
                    (Some(debit), None) => Ok(-debit.abs()),
                    (None, Some(credit)) => Ok(credit.abs()),
                    (None, None) => Err("excel-refused-amount-missing"),
                }
            }
        };
        let amount = match read {
            Ok(amount) => amount,
            Err(reason) => {
                report.refused.push(Refused {
                    row: row.number,
                    content: summarize(row),
                    reason,
                });
                continue;
            }
        };

        let label = cell(label_at).display();
        let comment = cell(comment_at).display();
        let input = crate::operations::OperationInput {
            // Son repli, mot pour mot : une opération sans nom reste
            // retrouvable.
            label: if label.trim().is_empty() {
                "Transaction import excel".to_string()
            } else {
                label
            },
            payment_reference: String::new(),
            date: Some(date),
            clearing_date: Some(clearing),
            // Le montant porte déjà son signe ; la fiche, elle, sépare la
            // grandeur du sens, et c'est le sens qui le rendra.
            direction: if amount < 0 {
                crate::sub_operations::Direction::Debit
            } else {
                crate::sub_operations::Direction::Credit
            },
            amount: amount.abs(),
            // Son code écrit le premier statut en dur, et Fabrice a demandé de
            // le garder tel quel (fidélité stricte, 29/07/2026).
            status_id: 1,
            category_id: lookup(Nomenclature::Category, row),
            assignment_id: lookup(Nomenclature::Assignment, row),
            payment_mode_id: lookup(Nomenclature::PaymentMode, row),
            // Ni tiers ni projet : son `Import_Data` écrit `IDTiers = 0` et ne
            // connaît pas les projets.
            payee_id: 0,
            project_id: 0,
            // Le commentaire est un enregistrement à part, et il n'est écrit
            // que s'il porte quelque chose — comme chez lui.
            comment: if comment.trim().is_empty() {
                None
            } else {
                Some(comment)
            },
        };
        crate::operations::create_within(&tx, account_id, &input)?;
        report.imported += 1;
    }

    tx.commit()?;
    crate::balances::update_all(conn, account_id)?;
    Ok(report)
}

/// Construit le dictionnaire d'une nomenclature selon sa politique — le portage
/// de ses douze procédures `OPT_*`, qui ne diffèrent que par ce qu'elles font
/// d'une valeur inconnue.
fn sort_values(
    conn: &Connection,
    grid: &Grid,
    column: usize,
    kind: Nomenclature,
    rule: &Rule,
    report: &mut Report,
) -> Result<BTreeMap<String, i64>> {
    let mut known = existing(conn, kind)?;
    let mut table: BTreeMap<String, i64> = BTreeMap::new();
    for row in &grid.rows {
        let Some(cell) = row.cells.get(column) else {
            continue;
        };
        let label = cell.display();
        // Une cellule vide donne toujours l'identifiant 0, quelle que soit la
        // politique — c'est sa règle, et elle vaut pour les quatre.
        if label.trim().is_empty() {
            continue;
        }
        let key = key_of(&label);
        if table.contains_key(&key) {
            continue;
        }
        if let Some(id) = known.get(&key) {
            table.insert(key, *id);
            continue;
        }
        let id = match rule.policy {
            Policy::Create => {
                let created = if kind.has_budget_line() {
                    crate::nomenclatures::create_category(conn, &label, 0)?
                } else {
                    crate::nomenclatures::create(conn, kind, &label)?
                };
                known.insert(key.clone(), created);
                report.created += 1;
                created
            }
            Policy::Default => rule.default_id,
            Policy::Ask => rule.chosen.get(&key).copied().unwrap_or(0),
            Policy::Blank => 0,
        };
        table.insert(key, id);
    }
    Ok(table)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database::schema;

    fn database() -> Connection {
        let conn = Connection::open_in_memory().expect("base en mémoire");
        schema::migrate(&conn).expect("schéma");
        crate::database::seed::seed_initial_data(&conn).expect("valeurs initiales");
        conn
    }

    fn an_account(conn: &Connection) -> i64 {
        let id = crate::database::keygen::next_id(conn, "Compte", "IDCompte").expect("clef");
        conn.execute(
            "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte, ReportPointe)
             VALUES (?1, 'CCP', 1, 0)",
            [id],
        )
        .expect("compte");
        crate::balances::update_all(conn, id).expect("soldes");
        id
    }

    /// Une grille bâtie à la main, comme la zone de capture la produirait.
    fn a_grid(headers: &[&str], rows: &[(usize, Vec<Value>)]) -> Grid {
        Grid {
            headers: headers.iter().map(|h| (*h).to_string()).collect(),
            rows: rows
                .iter()
                .map(|(number, cells)| GridRow {
                    number: *number,
                    cells: cells.clone(),
                })
                .collect(),
        }
    }

    fn links(pairs: &[(&str, &str)]) -> Vec<Link> {
        pairs
            .iter()
            .map(|(header, field)| Link {
                header: (*header).to_string(),
                field: (*field).to_string(),
            })
            .collect()
    }

    fn text(value: &str) -> Value {
        Value::Text(value.to_string())
    }

    /// **Sa règle du montant, lue par la droite.** Les cas viennent de son
    /// `Extract_Montant_Xls` : la virgule n'est décimale que collée aux deux
    /// derniers chiffres.
    #[test]
    fn le_montant_se_lit_par_la_droite() {
        for (written, expected) in [
            ("-57.68", -57_680_000),
            ("1 234,56", 1_234_560_000),
            ("1,234", 1_234_000_000),
            ("1,234,567", 1_234_567_000_000),
            ("-23", -23_000_000),
            ("12,50", 12_500_000),
        ] {
            assert_eq!(
                parse_amount(&text(written)),
                Some(expected),
                "montant « {written} »"
            );
        }
        // Une cellule numérique ne passe pas par le texte : sa valeur est
        // exacte.
        assert_eq!(parse_amount(&Value::Number(-57.68)), Some(-57_680_000));
        assert_eq!(parse_amount(&text("")), None);
        assert_eq!(parse_amount(&text("bonjour")), None);
    }

    /// Les deux formes de date de son code, plus les vraies cellules de date
    /// d'Excel — **et la preuve que les deux plages ne se recouvrent pas**.
    #[test]
    fn les_dates_se_lisent_sous_ses_deux_formes_et_en_serie_excel() {
        assert_eq!(
            parse_date(&text("20251103")),
            NaiveDate::from_ymd_opt(2025, 11, 3)
        );
        assert_eq!(
            parse_date(&text("03/11/2025")),
            NaiveDate::from_ymd_opt(2025, 11, 3)
        );
        assert_eq!(
            parse_date(&text("2025-11-03")),
            NaiveDate::from_ymd_opt(2025, 11, 3)
        );
        // Le numéro de série Excel du 3 novembre 2025.
        assert_eq!(
            parse_date(&Value::Number(45_964.0)),
            NaiveDate::from_ymd_opt(2025, 11, 3)
        );
        // La forme compacte est bien trop grande pour être un numéro de série,
        // et un numéro de série bien trop petit pour être une date compacte :
        // aucune des deux ne peut être prise pour l'autre.
        assert_eq!(serial_date(20_251_103.0), None);
        assert_eq!(
            parse_date(&Value::Number(20_251_103.0)),
            parse_date(&text("20251103"))
        );
        assert_eq!(parse_date(&text("")), None);
        assert_eq!(parse_date(&text("n'importe quoi")), None);
    }

    /// Les trois barrières de son `Verif_Parametrage`, et la variante du
    /// montant que Fabrice a demandée.
    #[test]
    fn la_concordance_refuse_ce_qui_est_incoherent() {
        let grid = a_grid(&["Date", "Libelle", "Debit", "Credit"], &[]);

        let incomplete = links(&[
            ("Date", "Date"),
            ("Libelle", "Libelle"),
            ("Debit", IGNORE),
            ("Credit", IGNORE),
        ]);
        assert_eq!(
            refusal(&incomplete, &grid, AmountShape::Single),
            Some("excel-refusal-required")
        );

        // En mode deux colonnes, les deux sont exigées.
        let one_side = links(&[
            ("Date", "Date"),
            ("Libelle", "Libelle"),
            ("Debit", "Montant_Debit"),
            ("Credit", IGNORE),
        ]);
        assert_eq!(
            refusal(&one_side, &grid, AmountShape::DebitCredit),
            Some("excel-refusal-required")
        );

        // Deux rubriques différentes sur la même colonne Excel.
        let same_column = links(&[
            ("Date", "Date"),
            ("Date", "Libelle"),
            ("Debit", "Montant"),
            ("Credit", IGNORE),
        ]);
        assert_eq!(
            refusal(&same_column, &grid, AmountShape::Single),
            Some("excel-refusal-column-twice")
        );

        // Une même rubrique deux fois.
        let twice = links(&[
            ("Date", "Date"),
            ("Libelle", "Libelle"),
            ("Debit", "Montant"),
            ("Credit", "Montant"),
        ]);
        assert_eq!(
            refusal(&twice, &grid, AmountShape::Single),
            Some("excel-refusal-field-twice")
        );

        // Et une concordance complète passe, sans qu'aucune nomenclature ne
        // soit réglée : elles sont facultatives.
        let enough = links(&[
            ("Date", "Date"),
            ("Libelle", "Libelle"),
            ("Debit", "Montant"),
            ("Credit", IGNORE),
        ]);
        assert_eq!(refusal(&enough, &grid, AmountShape::Single), None);
    }

    /// **Le croisement de l'import** : ce que la feuille porte se retrouve dans
    /// le compte, au centime près, et ce qui n'est pas entré est nommé.
    #[test]
    fn ce_que_la_feuille_porte_entre_dans_le_compte_et_le_reste_est_dit() {
        let mut conn = database();
        let account = an_account(&conn);
        let grid = a_grid(
            &["Date", "Libelle", "Montant", "Categorie"],
            &[
                (
                    3,
                    vec![
                        text("20251103"),
                        text("ACHAT CB"),
                        text("-57,68"),
                        text("Zorglub"),
                    ],
                ),
                (
                    4,
                    vec![
                        text("20251105"),
                        text("VIREMENT"),
                        text("1 200,00"),
                        text("Trucmuche"),
                    ],
                ),
                (
                    5,
                    vec![
                        text("bonjour"),
                        text("PERDUE"),
                        text("-10,00"),
                        text("Zorglub"),
                    ],
                ),
                (
                    6,
                    vec![text("20251107"), text("SANS MONTANT"), text(""), text("")],
                ),
            ],
        );
        let mapping = links(&[
            ("Date", "Date"),
            ("Libelle", "Libelle"),
            ("Montant", "Montant"),
            ("Categorie", "Categorie"),
        ]);
        assert_eq!(refusal(&mapping, &grid, AmountShape::Single), None);

        let report = run(
            &mut conn,
            account,
            &grid,
            &mapping,
            AmountShape::Single,
            &Policies::default(),
        )
        .expect("import");

        assert_eq!(report.imported, 2);
        assert_eq!(report.refused.len(), 2);
        assert_eq!(report.refused[0].row, 5);
        assert_eq!(report.refused[0].reason, "excel-refused-date");
        assert_eq!(report.refused[1].row, 6);
        assert_eq!(report.refused[1].reason, "excel-refused-amount");
        assert_eq!(report.created, 2);

        // Le croisement : la somme écrite en base est celle de la feuille, et
        // le solde du compte l'est aussi.
        let total: i64 = conn
            .query_row(
                "SELECT COALESCE(SUM(Montant), 0) FROM Operation",
                [],
                |row| row.get(0),
            )
            .expect("somme");
        assert_eq!(total, -57_680_000 + 1_200_000_000);
        assert_eq!(
            crate::accounts::get(&conn, account)
                .expect("lecture")
                .expect("le compte")
                .balance_final,
            total
        );
    }

    /// Le signe écrit dans la colonne débit ne compte pas — et deux montants
    /// sur la même ligne sont une ambiguïté, pas une somme.
    #[test]
    fn un_debit_sort_de_l_argent_quel_que_soit_son_signe() {
        let mut conn = database();
        let account = an_account(&conn);
        let grid = a_grid(
            &["Date", "Libelle", "Debit", "Credit"],
            &[
                (
                    2,
                    vec![
                        text("20260101"),
                        text("AVEC SIGNE"),
                        text("-50,00"),
                        text(""),
                    ],
                ),
                (
                    3,
                    vec![
                        text("20260102"),
                        text("SANS SIGNE"),
                        text("50,00"),
                        text(""),
                    ],
                ),
                (
                    4,
                    vec![text("20260103"), text("CREDIT"), text(""), text("30,00")],
                ),
                (
                    5,
                    vec![
                        text("20260104"),
                        text("LES DEUX"),
                        text("10,00"),
                        text("20,00"),
                    ],
                ),
                (
                    6,
                    vec![text("20260105"), text("AUCUN"), text(""), text("")],
                ),
            ],
        );
        let mapping = links(&[
            ("Date", "Date"),
            ("Libelle", "Libelle"),
            ("Debit", "Montant_Debit"),
            ("Credit", "Montant_Credit"),
        ]);
        let report = run(
            &mut conn,
            account,
            &grid,
            &mapping,
            AmountShape::DebitCredit,
            &Policies::default(),
        )
        .expect("import");

        assert_eq!(report.imported, 3);
        let amounts: Vec<i64> = conn
            .prepare("SELECT Montant FROM Operation ORDER BY IDOperation")
            .expect("requête")
            .query_map([], |row| row.get(0))
            .expect("montants")
            .collect::<Result<_>>()
            .expect("collecte");
        // Les deux débits donnent le même montant négatif, quel que soit le
        // signe écrit.
        assert_eq!(amounts, vec![-50_000_000, -50_000_000, 30_000_000]);

        assert_eq!(report.refused.len(), 2);
        assert_eq!(report.refused[0].reason, "excel-refused-amount-both");
        assert_eq!(report.refused[1].reason, "excel-refused-amount-missing");
    }

    /// Les quatre politiques, et le fait qu'elles s'appliquent **une fois pour
    /// toutes** et non ligne par ligne.
    #[test]
    fn les_quatre_politiques_font_ce_qu_elles_annoncent() {
        let rows = [
            (
                2,
                vec![text("20260101"), text("A"), text("-1,00"), text("Zorglub")],
            ),
            (
                3,
                vec![text("20260102"), text("B"), text("-2,00"), text("Zorglub")],
            ),
            (
                4,
                vec![text("20260103"), text("C"), text("-3,00"), text("ZORGLUB")],
            ),
        ];
        let grid = a_grid(&["Date", "Libelle", "Montant", "Categorie"], &rows);
        let mapping = links(&[
            ("Date", "Date"),
            ("Libelle", "Libelle"),
            ("Montant", "Montant"),
            ("Categorie", "Categorie"),
        ]);
        let count = |conn: &Connection| -> i64 {
            conn.query_row("SELECT COUNT(*) FROM Categorie", [], |row| row.get(0))
                .expect("compte")
        };
        let categories_written = |conn: &Connection| -> Vec<i64> {
            conn.prepare("SELECT IDCategorie FROM Operation")
                .expect("requête")
                .query_map([], |row| row.get(0))
                .expect("catégories")
                .collect::<Result<_>>()
                .expect("collecte")
        };

        // Créer : une seule catégorie créée pour les trois lignes, parce que la
        // clef ignore la casse — « Zorglub » et « ZORGLUB » sont la même.
        let mut conn = database();
        let account = an_account(&conn);
        let before = count(&conn);
        let report = run(
            &mut conn,
            account,
            &grid,
            &mapping,
            AmountShape::Single,
            &Policies::default(),
        )
        .expect("import");
        assert_eq!(report.created, 1);
        assert_eq!(count(&conn), before + 1);
        let written = categories_written(&conn);
        assert!(written.iter().all(|id| *id != 0 && *id == written[0]));

        // Laisser vierge : rien n'est créé, et la catégorie reste vide.
        let mut conn = database();
        let account = an_account(&conn);
        let before = count(&conn);
        let mut blank = Policies::default();
        blank.category.policy = Policy::Blank;
        run(
            &mut conn,
            account,
            &grid,
            &mapping,
            AmountShape::Single,
            &blank,
        )
        .expect("import");
        assert_eq!(count(&conn), before);
        assert!(categories_written(&conn).iter().all(|id| *id == 0));

        // Par défaut : tout tombe dans la valeur désignée.
        let mut conn = database();
        let account = an_account(&conn);
        let target = crate::nomenclatures::create_category(&conn, "Divers", 0).expect("catégorie");
        let mut fallback = Policies::default();
        fallback.category.policy = Policy::Default;
        fallback.category.default_id = target;
        run(
            &mut conn,
            account,
            &grid,
            &mapping,
            AmountShape::Single,
            &fallback,
        )
        .expect("import");
        assert!(categories_written(&conn).iter().all(|id| *id == target));

        // Demander : ce que la fenêtre d'association a rapporté, sous la clef
        // normalisée — donc les trois lignes, « ZORGLUB » comprise.
        let mut conn = database();
        let account = an_account(&conn);
        let chosen = crate::nomenclatures::create_category(&conn, "Carburant", 0).expect("cat");
        let mut asked = Policies::default();
        asked.category.policy = Policy::Ask;
        asked.category.answered = true;
        asked.category.chosen.insert(key_of("Zorglub"), chosen);
        run(
            &mut conn,
            account,
            &grid,
            &mapping,
            AmountShape::Single,
            &asked,
        )
        .expect("import");
        assert!(categories_written(&conn).iter().all(|id| *id == chosen));
    }

    /// La fenêtre d'association ne montre **que ce qu'il faut ranger** : les
    /// valeurs déjà connues de Radinus n'y sont pas.
    #[test]
    fn seules_les_valeurs_inconnues_sont_a_ranger() {
        let conn = database();
        crate::nomenclatures::create_category(&conn, "Alimentation", 0).expect("catégorie");
        let grid = a_grid(
            &["Date", "Categorie"],
            &[
                (2, vec![text("20260101"), text("Alimentation")]),
                (3, vec![text("20260102"), text("ALIMENTATION")]),
                (4, vec![text("20260103"), text("Alimentationss")]),
                (5, vec![text("20260104"), text("Alimentationss")]),
                (6, vec![text("20260105"), text("")]),
            ],
        );
        let mapping = links(&[("Date", "Date"), ("Categorie", "Categorie")]);
        let unknown =
            unknown_values(&conn, &grid, &mapping, Nomenclature::Category).expect("inconnues");
        // « Alimentation » est connue, sous toutes ses casses ; la faute de
        // frappe ne l'est pas, et n'apparaît qu'une fois ; le vide n'est pas
        // une valeur.
        assert_eq!(unknown, vec!["Alimentationss".to_string()]);
    }

    /// La zone de capture s'arrête aux lignes réelles — la décision de Fabrice
    /// qui évite 960 refus sur une feuille de 40 lignes.
    #[test]
    fn la_zone_s_arrete_aux_lignes_reelles() {
        let book = Book::with_sheet(
            "Feuille1",
            vec![
                vec![text("Date"), text("Libelle")],
                vec![text("20260101"), text("UNE")],
                vec![text("20260102"), text("DEUX")],
            ],
        );
        let settings = Capture {
            sheet: 0,
            header_row: 1,
            first_column: 1,
            column_count: 2,
            first_data_row: 2,
            // Annoncée bien trop large, comme le défaut de sa capture.
            last_data_row: 1_000,
            shape: AmountShape::Single,
        };
        let grid = capture(&book, &settings);
        assert_eq!(grid.headers, vec!["Date".to_string(), "Libelle".to_string()]);
        assert_eq!(grid.rows.len(), 2);
        assert_eq!(grid.rows[0].number, 2);
        assert_eq!(grid.rows[1].number, 3);
    }

    /// Un import qui échoue n'écrit rien du tout — le « tout ou rien » que
    /// Fabrice a demandé, et qu'on ne peut vérifier qu'en le cassant.
    #[test]
    fn le_dictionnaire_et_les_ecritures_partent_ensemble() {
        let mut conn = database();
        let _account = an_account(&conn);
        let grid = a_grid(
            &["Date", "Libelle", "Montant", "Categorie"],
            &[(
                2,
                vec![text("20260101"), text("A"), text("-1,00"), text("Neuve")],
            )],
        );
        let mapping = links(&[
            ("Date", "Date"),
            ("Libelle", "Libelle"),
            ("Montant", "Montant"),
            ("Categorie", "Categorie"),
        ]);
        let categories = |conn: &Connection| -> i64 {
            conn.query_row("SELECT COUNT(*) FROM Categorie", [], |row| row.get(0))
                .expect("compte")
        };
        let before = categories(&conn);
        // Un compte qui n'existe pas fait échouer l'écriture : la contrainte de
        // clef étrangère refuse, et rien ne doit rester.
        let outcome = run(
            &mut conn,
            9_999,
            &grid,
            &mapping,
            AmountShape::Single,
            &Policies::default(),
        );
        assert!(
            outcome.is_err(),
            "un compte inexistant doit faire échouer l'import"
        );
        // **La catégorie créée au passage est partie avec l'écriture** : elle
        // était dans la même transaction.
        assert_eq!(categories(&conn), before);
        assert_eq!(
            conn.query_row("SELECT COUNT(*) FROM Operation", [], |row| row
                .get::<_, i64>(0))
            .expect("compte"),
            0
        );
    }

    /// **Le croisement du format** : on écrit un vrai `.xlsx` avec la crate de
    /// Fabrice, on le relit par [`open`], et l'on vérifie que la feuille
    /// traverse la zone de capture puis l'intégration jusqu'au solde du compte.
    ///
    /// C'est le seul test qui tienne les deux bouts du format lui-même : les
    /// autres partent d'une grille bâtie à la main, donc d'une lecture supposée
    /// juste. Celui-ci part d'octets.
    ///
    /// Il porte aussi le cas que Fabrice a demandé d'accepter le 29/07/2026 :
    /// une **vraie cellule de date** d'Excel, qui n'est ni du texte ni la forme
    /// compacte — un nombre portant un format d'affichage daté.
    #[test]
    fn un_vrai_classeur_excel_traverse_toute_la_chaine() {
        use office_toolkit::excel::{Cell, CellFormat, CellValue, Row, Sheet, Workbook};
        use office_toolkit::SaveToFile;

        let text_cell = |value: &str| Cell {
            value: CellValue::Text(value.to_string()),
            format: None,
        };
        let number_cell = |value: f64| Cell {
            value: CellValue::Number(value),
            format: None,
        };
        // Une date telle qu'Excel la range vraiment : un numéro de série, plus
        // un format d'affichage. 45 964 est le 3 novembre 2025.
        let date_cell = |serial: f64| Cell {
            value: CellValue::Number(serial),
            format: Some(CellFormat::new().with_number_format("dd/mm/yyyy")),
        };

        let mut tab = Sheet::new("Relevé");
        // Deux lignes de préambule : la zone de capture doit pouvoir commencer
        // ailleurs qu'en A1, comme dans « ImportExcel1.png ».
        tab.rows.push(Row::new());
        tab.rows.push(
            Row::new()
                .with_cell(text_cell(""))
                .with_cell(text_cell("Date"))
                .with_cell(text_cell("Libelle"))
                .with_cell(text_cell("Montant"))
                .with_cell(text_cell("Categorie")),
        );
        tab.rows.push(
            Row::new()
                .with_cell(text_cell(""))
                .with_cell(date_cell(45_964.0))
                .with_cell(text_cell("ACHAT CB ETS FERRARI"))
                .with_cell(number_cell(-57.68))
                .with_cell(text_cell("Zorglub")),
        );
        tab.rows.push(
            Row::new()
                .with_cell(text_cell(""))
                .with_cell(text_cell("20251105"))
                .with_cell(text_cell("VIREMENT"))
                .with_cell(text_cell("1 200,00"))
                .with_cell(text_cell("Zorglub")),
        );
        let mut workbook = Workbook::default();
        workbook.sheets.push(tab);

        let file = std::env::temp_dir().join(format!(
            "radinus-import-{}-{}.xlsx",
            std::process::id(),
            "chaine"
        ));
        workbook.save_to_file(&file).expect("écriture du classeur");
        let book = open(&file).expect("relecture du classeur");
        std::fs::remove_file(&file).ok();

        assert_eq!(book.sheet_names, vec!["Relevé".to_string()]);
        let settings = Capture {
            sheet: 0,
            header_row: 2,
            first_column: 2,
            column_count: 4,
            first_data_row: 3,
            last_data_row: 1_000,
            shape: AmountShape::Single,
        };
        let grid = capture(&book, &settings);
        assert_eq!(
            grid.headers,
            vec![
                "Date".to_string(),
                "Libelle".to_string(),
                "Montant".to_string(),
                "Categorie".to_string(),
            ]
        );
        assert_eq!(grid.rows.len(), 2);

        // La vraie cellule de date est comprise, et rend le bon jour.
        assert_eq!(
            parse_date(&grid.rows[0].cells[0]),
            NaiveDate::from_ymd_opt(2025, 11, 3)
        );

        let mut conn = database();
        let account = an_account(&conn);
        let mapping = links(&[
            ("Date", "Date"),
            ("Libelle", "Libelle"),
            ("Montant", "Montant"),
            ("Categorie", "Categorie"),
        ]);
        assert_eq!(refusal(&mapping, &grid, AmountShape::Single), None);
        let report = run(
            &mut conn,
            account,
            &grid,
            &mapping,
            AmountShape::Single,
            &Policies::default(),
        )
        .expect("import");

        assert_eq!(report.imported, 2);
        assert!(report.refused.is_empty(), "{:?}", report.refused);
        // Une seule catégorie créée pour les deux lignes.
        assert_eq!(report.created, 1);
        // Et le croisement final : le solde du compte est la somme de la
        // feuille, au centime près, montant numérique et montant écrit
        // confondus.
        assert_eq!(
            crate::accounts::get(&conn, account)
                .expect("lecture")
                .expect("le compte")
                .balance_final,
            -57_680_000 + 1_200_000_000
        );
    }
}
