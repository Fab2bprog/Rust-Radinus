//! **Une feuille, et trois façons de l'écrire.**
//!
//! L'export par clic droit des tableaux (`PLAN_ACTION.md` §3.1) est une
//! fonction du *tableau*, pas d'une fenêtre : le jour où on l'écrit une fois,
//! toutes les listes de Radinus l'ont. Encore faut-il que ce qu'on exporte
//! soit dit dans un vocabulaire qui ne connaisse ni Excel ni les fenêtres.
//!
//! C'est ce que fait ce module. Une [`Sheet`] est une grille de cellules
//! typées — un texte, ou un nombre avec le format qui l'écrit — chacune
//! pouvant porter une couleur de fond et du gras. Rien d'autre. Les fenêtres
//! fabriquent une feuille à partir de ce qu'elles **affichent** ; trois
//! écrivains la consomment, en `.xlsx`, en `.ods` et en `.csv`. L'exportateur
//! ne sait rien de Radinus, et les fenêtres ne savent rien d'OOXML ni d'OpenDocument.
//!
//! **Et c'est là que la séparation paie.** L'ODS est arrivé le 26/07/2026,
//! après coup, sur demande de Fabrice : il n'a coûté qu'un troisième écrivain
//! au bas de ce fichier. La forme n'a pas bougé d'une ligne, aucune fenêtre
//! n'a rien appris, et les dix tableaux qui exportaient déjà ont eu le
//! nouveau format le même jour.
//!
//! **Les trois formats ne portent pas la même chose, et c'est dans leur
//! nature.** Le `.xlsx` et l'`.ods` portent les couleurs de l'écran et un vrai
//! format monétaire, donc on peut sommer et trier dans Excel comme dans
//! LibreOffice Calc. Le CSV ne porte que des valeurs : le nombre y est écrit à
//! la française — virgule décimale, sans le symbole — et le fichier commence
//! par un BOM UTF-8, sans lequel Excel ouvre « Catégorie » en « CatÃ©gorie ».
//! Ce sont ces trois détails-là qui comptent, et aucune bibliothèque générique
//! ne les aurait faits à notre place : c'est pourquoi le CSV est écrit ici, à
//! la main, plutôt qu'avec une dépendance de plus (décision prise avec Fabrice
//! le 26/07/2026).

use std::path::Path;

/// Comment un nombre s'écrit dans le tableur.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum NumberKind {
    /// Un nombre nu.
    Plain,
    /// Un montant. En `.xlsx` il reçoit un format monétaire, donc Excel
    /// l'affiche avec son symbole et le somme ; en CSV il part en clair, à la
    /// française.
    Money,
}

/// Ce qu'une cellule porte.
#[derive(Debug, Clone, PartialEq)]
pub enum CellContent {
    /// Rien. Une case vide de la matrice reste vide dans le fichier : c'est ce
    /// qu'on voit à l'écran, et un zéro à la place serait un mensonge.
    Empty,
    Text(String),
    Number { value: f64, kind: NumberKind },
}

/// Une cellule de la feuille : ce qu'elle porte, et comment elle se voit.
#[derive(Debug, Clone, PartialEq)]
pub struct SheetCell {
    pub content: CellContent,
    /// Couleur de fond, en six chiffres hexadécimaux comme à l'écran
    /// (« FF9999 »), ou rien. Le `.xlsx` la reprend ; le CSV l'ignore, il n'a
    /// pas de couleurs.
    pub fill: Option<String>,
    pub bold: bool,
}

impl SheetCell {
    pub fn empty() -> Self {
        Self {
            content: CellContent::Empty,
            fill: None,
            bold: false,
        }
    }

    pub fn text(text: impl Into<String>) -> Self {
        Self {
            content: CellContent::Text(text.into()),
            fill: None,
            bold: false,
        }
    }

    /// Un montant, donné en micro-unités comme partout dans Radinus.
    pub fn money(amount: i64) -> Self {
        Self {
            content: CellContent::Number {
                value: amount as f64 / crate::money::UNIT as f64,
                kind: NumberKind::Money,
            },
            fill: None,
            bold: false,
        }
    }

    pub fn number(value: f64) -> Self {
        Self {
            content: CellContent::Number {
                value,
                kind: NumberKind::Plain,
            },
            fill: None,
            bold: false,
        }
    }

    pub fn with_fill(mut self, fill: Option<String>) -> Self {
        self.fill = fill.filter(|colour| !colour.trim().is_empty());
        self
    }

    pub fn with_bold(mut self, bold: bool) -> Self {
        self.bold = bold;
        self
    }
}

/// Ce qu'une fenêtre donne à exporter.
#[derive(Debug, Clone, PartialEq)]
pub struct Sheet {
    /// Le nom de l'onglet dans le classeur.
    pub name: String,
    /// **D'où vient ce fichier** : la fenêtre, l'année, les comptes, l'état
    /// des interrupteurs. Écrite en tête, parce qu'un tableau nu retrouvé dans
    /// six mois ne dit plus sur quoi il portait (proposition acceptée par
    /// Fabrice, 26/07/2026). Vide, elle n'écrit rien.
    pub context: String,
    /// Combien de lignes du haut sont des titres : elles partent en gras.
    pub header_rows: usize,
    pub rows: Vec<Vec<SheetCell>>,
    /// Largeur de chaque colonne, en caractères. Une colonne sans largeur
    /// prend celle d'Excel.
    pub widths: Vec<f64>,
}

impl Sheet {
    pub fn new(name: impl Into<String>) -> Self {
        Self {
            name: name.into(),
            context: String::new(),
            header_rows: 0,
            rows: Vec::new(),
            widths: Vec::new(),
        }
    }
}

/// Écrit la feuille dans le fichier demandé, **d'après son extension**.
///
/// C'est l'utilisateur qui a choisi le nom dans le sélecteur du système : le
/// format suit ce qu'il a demandé, et un nom sans extension connue part en
/// `.xlsx`, qui est le format riche.
pub fn write(sheet: &Sheet, path: &Path) -> std::io::Result<()> {
    let extension = path
        .extension()
        .and_then(|extension| extension.to_str())
        .unwrap_or_default();
    if extension.eq_ignore_ascii_case("csv") {
        write_csv(sheet, path)
    } else if extension.eq_ignore_ascii_case("tsv") {
        write_tsv(sheet, path)
    } else if extension.eq_ignore_ascii_case("ods") {
        write_ods(std::slice::from_ref(sheet), path)
    } else if extension.eq_ignore_ascii_case("docx") {
        write_docx(sheet, path)
    } else if extension.eq_ignore_ascii_case("json") {
        write_json(sheet, path)
    } else if extension.eq_ignore_ascii_case("xml") {
        write_xml(sheet, path)
    } else if extension.eq_ignore_ascii_case("ini") {
        write_ini(sheet, path)
    } else if extension.eq_ignore_ascii_case("yaml") || extension.eq_ignore_ascii_case("yml") {
        write_yaml(sheet, path)
    } else if extension.eq_ignore_ascii_case("toml") {
        write_toml(sheet, path)
    } else {
        write_xlsx(std::slice::from_ref(sheet), path)
    }
}

/// Écrit **plusieurs feuilles dans un même classeur**, un onglet chacune.
///
/// C'est ce que demande « exporter toutes les années » (Fabrice, 26/07/2026) :
/// un onglet par an, nommé `AN_2026`. Chaque feuille porte son propre nom
/// d'onglet et sa propre ligne de contexte, si bien qu'un onglet retrouvé seul
/// dit encore sur quoi il portait.
///
/// **Réservé aux tableurs.** Le CSV, le XML et le JSON n'ont pas d'onglets :
/// leur donner un classeur de douze feuilles, ce serait en perdre onze en
/// silence. On préfère le dire.
pub fn write_book(sheets: &[Sheet], path: &Path) -> std::io::Result<()> {
    if sheets.is_empty() {
        return Err(std::io::Error::other("aucune feuille à écrire"));
    }
    let extension = path
        .extension()
        .and_then(|extension| extension.to_str())
        .unwrap_or_default();
    if extension.eq_ignore_ascii_case("ods") {
        write_ods(sheets, path)
    } else {
        write_xlsx(sheets, path)
    }
}

/// Le format de nombre qu'Excel reçoit pour un montant.
///
/// Le code est écrit dans la notation invariante d'OOXML — la virgule y est le
/// séparateur de milliers et le point celui des décimales — et c'est Excel qui
/// l'affiche ensuite selon la langue du poste. Écrire « # ##0,00 » ici
/// donnerait un format que le tableur ne comprend pas.
const MONEY_FORMAT: &str = "#,##0.00 \"€\"";

/// Un nom d'onglet qu'un tableur accepte.
///
/// Excel refuse sept caractères et s'arrête à trente et un ; LibreOffice est à
/// peine plus tolérant. Un onglet nommé « AN_2026 » ne pose aucun problème,
/// mais un tableau exporté seul prend le nom de sa fenêtre, et
/// « Statistiques par categorie » y passe tout juste. **Un nom trop long ne
/// doit pas faire échouer un export** : on le raccourcit, on ne renonce pas.
fn tab_name(name: &str) -> String {
    let cleaned: String = name
        .chars()
        .map(|character| match character {
            '\\' | '/' | '?' | '*' | '[' | ']' | ':' => ' ',
            character => character,
        })
        .collect();
    let cleaned = cleaned.trim();
    if cleaned.is_empty() {
        return "Radinus".to_string();
    }
    cleaned.chars().take(31).collect::<String>().trim().to_string()
}

fn write_xlsx(sheets: &[Sheet], path: &Path) -> std::io::Result<()> {
    use office_toolkit::excel::{Cell, CellFormat, ColumnSetting, Row, Sheet as XlsxSheet, Workbook};
    use office_toolkit::SaveToFile;

    let mut workbook = Workbook::default();

    for sheet in sheets {
        let mut tab = XlsxSheet::new(tab_name(&sheet.name));

        // La ligne de contexte, puis une ligne vide : le tableau commence en
        // dessous, et le fichier dit d'où il vient.
        if !sheet.context.is_empty() {
            tab.rows.push(
                Row::new().with_cell(Cell {
                    value: office_toolkit::excel::CellValue::Text(sheet.context.clone()),
                    format: Some(CellFormat::new().with_bold(true)),
                }),
            );
            tab.rows.push(Row::new());
        }

        for (index, line) in sheet.rows.iter().enumerate() {
            let heading = index < sheet.header_rows;
            let mut row = Row::new();
            for cell in line {
                row = row.with_cell(as_xlsx_cell(cell, heading));
            }
            tab.rows.push(row);
        }

        for (column, width) in sheet.widths.iter().enumerate() {
            tab.column_settings
                .push(ColumnSetting::new(column).with_width(*width));
        }
        workbook.sheets.push(tab);
    }

    workbook
        .save_to_file(path)
        .map_err(|error| std::io::Error::other(error.to_string()))
}

fn as_xlsx_cell(cell: &SheetCell, heading: bool) -> office_toolkit::excel::Cell {
    use office_toolkit::excel::{Cell, CellFormat, CellValue};

    let mut format = CellFormat::new();
    let mut styled = false;
    if cell.bold || heading {
        format = format.with_bold(true);
        styled = true;
    }
    if let Some(fill) = &cell.fill {
        // Les couleurs d'OOXML sont en ARGB ; les nôtres viennent de l'écran,
        // en six chiffres. Opaques, donc « FF » devant.
        format = format.with_fill_color(format!("FF{}", fill.trim_start_matches('#')));
        styled = true;
    }
    if let CellContent::Number {
        kind: NumberKind::Money,
        ..
    } = cell.content
    {
        format = format.with_number_format(MONEY_FORMAT);
        styled = true;
    }

    let value = match &cell.content {
        CellContent::Empty => CellValue::Empty,
        CellContent::Text(text) => CellValue::Text(text.clone()),
        CellContent::Number { value, .. } => CellValue::Number(*value),
    };
    Cell {
        value,
        format: styled.then_some(format),
    }
}

/// L'`.ods` de LibreOffice Calc, ajouté le 26/07/2026 à la demande de Fabrice.
///
/// **Le même fichier que le `.xlsx`, dit dans l'autre langue** : les mêmes
/// nombres, le même format monétaire, les mêmes couleurs d'écran, le même
/// gras. Rien n'est appauvri au passage — OpenDocument sait tout ce dont on a
/// besoin ici.
///
/// Deux choix méritent d'être dits. Un montant part en `Value::Currency` et
/// non en nombre nu : c'est le type propre d'OpenDocument pour de l'argent, et
/// Calc le somme et le trie comme tel. Et les styles sont **partagés** — une
/// matrice a des centaines de cases rouges, mais il n'y a qu'un seul style
/// rouge dans le fichier, sinon le classeur enflerait d'autant.
fn write_ods(sheets: &[Sheet], path: &Path) -> std::io::Result<()> {
    use spreadsheet_ods::color::Rgb;
    use spreadsheet_ods::defaultstyles::DefaultFormat;
    use spreadsheet_ods::style::{units::Length, CellStyle};
    use spreadsheet_ods::{CellStyleRef, Sheet as OdsSheet, Value, ValueFormatCurrency, WorkBook};
    use std::collections::HashMap;

    // **Un classeur sans formats par défaut, et c'est voulu.** Les seuls
    // formats qu'on impose sont les nôtres — le monétaire ci-dessous ; le
    // texte et les nombres nus n'en portent aucun, si bien que LibreOffice les
    // affiche selon la langue du poste qui ouvre le fichier. Poser les
    // formats par défaut de la bibliothèque figerait tout en de-AT.
    let mut book = WorkBook::new_empty();

    // « 1 234,56 € » — bâti à la main plutôt que par la fonction toute faite
    // de la bibliothèque, qui réclame un type `Locale` d'une autre crate : une
    // dépendance de plus pour un symbole, cela ne valait pas la peine.
    let mut money_format = ValueFormatCurrency::new_named("radinus-money");
    money_format
        .part_number()
        .fixed_decimal_places(2)
        .grouping()
        .build();
    money_format.part_text(" ").build();
    money_format.part_currency().symbol("€").build();
    let money_format = book.add_currency_format(money_format);
    let plain_format = DefaultFormat::default();

    // Un style par apparence rencontrée, et non un par cellule.
    let mut styles: HashMap<(Option<String>, bool, bool), CellStyleRef> = HashMap::new();
    let mut style_of = |book: &mut WorkBook,
                        fill: &Option<String>,
                        bold: bool,
                        money: bool|
     -> CellStyleRef {
        let key = (fill.clone(), bold, money);
        if let Some(found) = styles.get(&key) {
            return found.clone();
        }
        let name = format!("radinus-{}", styles.len());
        let mut style = CellStyle::new(
            name,
            if money {
                &money_format
            } else {
                &plain_format
            },
        );
        if bold {
            style.set_font_bold();
        }
        if let Some(colour) = fill {
            if let Some(rgb) = as_rgb(colour) {
                style.set_background_color(Rgb::new(rgb.0, rgb.1, rgb.2));
            }
        }
        let made = book.add_cellstyle(style);
        styles.insert(key, made.clone());
        made
    };

    for sheet in sheets {
        let mut tab = OdsSheet::new(tab_name(&sheet.name));
        let mut line_number: u32 = 0;

        // La ligne de contexte, puis une ligne vide : le tableau commence en
        // dessous, exactement comme dans le `.xlsx`.
        if !sheet.context.is_empty() {
            let style = style_of(&mut book, &None, true, false);
            tab.set_styled_value(0, 0, sheet.context.clone(), &style);
            line_number = 2;
        }

        for (index, line) in sheet.rows.iter().enumerate() {
            let heading = index < sheet.header_rows;
            for (column, cell) in line.iter().enumerate() {
                let column = column as u32;
                let bold = cell.bold || heading;
                let money = matches!(
                    cell.content,
                    CellContent::Number {
                        kind: NumberKind::Money,
                        ..
                    }
                );
                let style = style_of(&mut book, &cell.fill, bold, money);
                match &cell.content {
                    // Une case vide sans apparence n'est pas écrite du tout :
                    // en OpenDocument, une cellule absente *est* une cellule
                    // vide.
                    CellContent::Empty => {
                        if bold || cell.fill.is_some() {
                            tab.set_styled_value(line_number, column, Value::Empty, &style);
                        }
                    }
                    CellContent::Text(text) => {
                        tab.set_styled_value(line_number, column, text.clone(), &style);
                    }
                    CellContent::Number { value, kind } => {
                        let written = match kind {
                            NumberKind::Money => Value::Currency(*value, "EUR".into()),
                            NumberKind::Plain => Value::Number(*value),
                        };
                        tab.set_styled_value(line_number, column, written, &style);
                    }
                }
            }
            line_number += 1;
        }

        // Nos largeurs sont en caractères, comme celles d'Excel ; OpenDocument
        // les veut en longueurs réelles. Un caractère de la police par défaut
        // fait un peu moins de deux millimètres.
        for (column, width) in sheet.widths.iter().enumerate() {
            tab.set_col_width(column as u32, Length::Mm(width * 1.9));
        }
        book.push_sheet(tab);
    }

    spreadsheet_ods::write_ods(&mut book, path)
        .map_err(|error| std::io::Error::other(error.to_string()))
}

/// « FF9999 » ou « #FF9999 » vers ses trois composantes. Rien, si ce n'est pas
/// une couleur — une couleur illisible ne doit pas faire échouer un export.
fn as_rgb(colour: &str) -> Option<(u8, u8, u8)> {
    let cleaned = colour.trim().trim_start_matches('#');
    if cleaned.len() != 6 {
        return None;
    }
    Some((
        u8::from_str_radix(&cleaned[0..2], 16).ok()?,
        u8::from_str_radix(&cleaned[2..4], 16).ok()?,
        u8::from_str_radix(&cleaned[4..6], 16).ok()?,
    ))
}

// --- Les deux formats pour les programmes --------------------------------
//
// **Le XML et le JSON ne s'adressent pas à la même personne que les trois
// autres** (décision de Fabrice, 26/07/2026). Un `.xlsx`, un `.ods`, un `.csv`
// sont faits pour un humain qui ouvre un tableur ; ces deux-ci sont faits pour
// un programme qui relit. D'où deux choix, les siens :
//
//   * **une ligne est un enregistrement**, dont les champs portent les noms
//     des colonnes affichées, et non une suite de cases anonymes ;
//   * **ni couleurs ni gras** : une couleur est une aide à la lecture pour un
//     œil, un programme n'en fait rien. Ces deux formats ne portent que des
//     valeurs, comme le CSV.
//
// Un montant y est un **nombre**, écrit au point décimal — c'est la notation
// des formats d'échange, quelle que soit la langue du poste. La virgule est
// pour les tableurs.

/// Le nom de chaque colonne, tiré des lignes de titres. `None` pour une
/// colonne qui n'en a pas.
///
/// La liste des opérations a une telle colonne : celle du « + » qui déplie une
/// ventilation. Elle sort vide dans un tableur et personne ne s'en émeut ; ici
/// elle est **sautée**, plutôt que de porter un nom inventé (choix de Fabrice,
/// 26/07/2026).
///
/// Deux colonnes de même nom ne sont pas censées exister, mais un fichier ne
/// doit jamais perdre une colonne en silence : la seconde reçoit un numéro.
fn column_names(sheet: &Sheet) -> Vec<Option<String>> {
    let width = sheet.rows.iter().map(Vec::len).max().unwrap_or(0);
    let mut names = Vec::with_capacity(width);
    let mut taken: Vec<String> = Vec::new();

    for column in 0..width {
        let found = sheet
            .rows
            .iter()
            .take(sheet.header_rows)
            .filter_map(|line| line.get(column))
            .find_map(|cell| match &cell.content {
                CellContent::Text(text) if !text.trim().is_empty() => Some(text.trim().to_string()),
                _ => None,
            });
        names.push(found.map(|name| {
            let mut unique = name.clone();
            let mut rank = 2;
            while taken.contains(&unique) {
                unique = format!("{name} {rank}");
                rank += 1;
            }
            taken.push(unique.clone());
            unique
        }));
    }
    names
}

/// Les lignes de données : la feuille moins ses lignes de titres.
fn data_rows(sheet: &Sheet) -> &[Vec<SheetCell>] {
    let from = sheet.header_rows.min(sheet.rows.len());
    &sheet.rows[from..]
}

/// Un nombre tel que ces deux formats l'écrivent : deux décimales pour un
/// montant, au point, sans symbole.
fn as_exchange_number(value: f64, kind: NumberKind) -> String {
    match kind {
        // L'arrondi évite les « -619.0000000000001 » que produit parfois le
        // passage par les flottants.
        NumberKind::Money => format!("{:.2}", (value * 100.0).round() / 100.0),
        NumberKind::Plain => {
            let rounded = (value * 1e6).round() / 1e6;
            if rounded.fract() == 0.0 {
                format!("{rounded:.0}")
            } else {
                format!("{rounded}")
            }
        }
    }
}

/// Le JSON, **écrit ici plutôt que sérialisé**.
///
/// Ce n'est pas de la méfiance envers `serde_json`, qui est déjà notre
/// dépendance : c'est que son dictionnaire trie ses clefs par ordre
/// alphabétique, ce qui mettrait « Total » avant « Janvier » et ferait perdre
/// l'ordre des colonnes affichées. La corriger — l'option `preserve_order` —
/// changerait l'ordre des clefs dans **toutes** nos sorties JSON, y compris le
/// fichier de sauvegarde. On garde donc la main sur la structure, et
/// `serde_json` fait ce qu'il fait le mieux : échapper correctement chaque
/// chaîne.
fn write_json(sheet: &Sheet, path: &Path) -> std::io::Result<()> {
    let names = column_names(sheet);
    let quoted = |text: &str| serde_json::to_string(text).unwrap_or_else(|_| "\"\"".to_string());

    let mut written = String::from("{\n");
    written.push_str(&format!("  \"tableau\": {},\n", quoted(&sheet.name)));
    if !sheet.context.is_empty() {
        written.push_str(&format!("  \"contexte\": {},\n", quoted(&sheet.context)));
    }
    let shown: Vec<&String> = names.iter().flatten().collect();
    let heading: Vec<String> = shown.iter().map(|name| quoted(name)).collect();
    written.push_str(&format!("  \"colonnes\": [{}],\n", heading.join(", ")));

    written.push_str("  \"lignes\": [\n");
    let lines = data_rows(sheet);
    for (index, line) in lines.iter().enumerate() {
        written.push_str("    {");
        let mut first = true;
        for (column, name) in names.iter().enumerate() {
            let Some(name) = name else { continue };
            if !first {
                written.push(',');
            }
            first = false;
            let value = match line.get(column).map(|cell| &cell.content) {
                // Une case vide est **une case vide**, et le champ le dit :
                // l'ôter ferait croire que la colonne n'existe pas sur cette
                // ligne-là.
                None | Some(CellContent::Empty) => "null".to_string(),
                Some(CellContent::Text(text)) => quoted(text),
                Some(CellContent::Number { value, kind }) => as_exchange_number(*value, *kind),
            };
            written.push_str(&format!("\n      {}: {}", quoted(name), value));
        }
        written.push_str(if first { "}" } else { "\n    }" });
        written.push_str(if index + 1 == lines.len() { "\n" } else { ",\n" });
    }
    written.push_str("  ]\n}\n");

    std::fs::write(path, written)
}

/// Le XML.
///
/// **Les noms de colonnes sont des attributs, pas des balises.** « Num
/// Chèque » contient une espace et « 2026 » commencerait par un chiffre : ni
/// l'un ni l'autre n'est un nom d'élément XML valide. En attribut, tout passe,
/// et le fichier reste lisible à l'œil.
fn write_xml(sheet: &Sheet, path: &Path) -> std::io::Result<()> {
    let names = column_names(sheet);

    let mut written = String::from("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
    written.push_str(&format!("<tableau nom=\"{}\"", escaped(&sheet.name)));
    if !sheet.context.is_empty() {
        written.push_str(&format!(" contexte=\"{}\"", escaped(&sheet.context)));
    }
    written.push_str(">\n");

    for line in data_rows(sheet) {
        written.push_str("  <ligne>\n");
        for (column, name) in names.iter().enumerate() {
            let Some(name) = name else { continue };
            let (kind, value) = match line.get(column).map(|cell| &cell.content) {
                None | Some(CellContent::Empty) => ("vide", String::new()),
                Some(CellContent::Text(text)) => ("texte", escaped(text)),
                Some(CellContent::Number { value, kind }) => (
                    match kind {
                        NumberKind::Money => "montant",
                        NumberKind::Plain => "nombre",
                    },
                    as_exchange_number(*value, *kind),
                ),
            };
            written.push_str(&format!(
                "    <cellule colonne=\"{}\" type=\"{kind}\">{value}</cellule>\n",
                escaped(name)
            ));
        }
        written.push_str("  </ligne>\n");
    }
    written.push_str("</tableau>\n");

    std::fs::write(path, written)
}

/// Les cinq entités du XML, et les caractères de contrôle qu'il interdit.
///
/// Un libellé venu de la base peut porter n'importe quoi — c'est de la saisie
/// libre. Un `&` ou un `<` non échappé rendrait le fichier illisible d'un bout
/// à l'autre, et un caractère de contrôle le rendrait invalide sans qu'on
/// puisse le voir.
fn escaped(text: &str) -> String {
    let mut written = String::with_capacity(text.len());
    for character in text.chars() {
        match character {
            '&' => written.push_str("&amp;"),
            '<' => written.push_str("&lt;"),
            '>' => written.push_str("&gt;"),
            '"' => written.push_str("&quot;"),
            '\'' => written.push_str("&apos;"),
            '\t' | '\n' | '\r' => written.push(character),
            // XML 1.0 n'admet aucun autre caractère de contrôle, pas même
            // échappé : il n'y a rien à en faire d'autre que les ôter.
            character if (character as u32) < 0x20 => {}
            character => written.push(character),
        }
    }
    written
}

/// Le point-virgule : c'est ce qu'attend un Excel français, dont le séparateur
/// décimal est la virgule.
const SEPARATOR: char = ';';

/// Le BOM UTF-8. **Sans lui, Excel ouvre « Catégorie » en « CatÃ©gorie »** :
/// il lit un CSV dans l'encodage du poste tant que rien ne lui dit le
/// contraire, et c'est la seule façon de le lui dire dans un fichier texte.
const BOM: &str = "\u{feff}";

fn write_csv(sheet: &Sheet, path: &Path) -> std::io::Result<()> {
    let mut written = String::from(BOM);

    if !sheet.context.is_empty() {
        written.push_str(&quoted(&sheet.context));
        written.push_str("\r\n\r\n");
    }

    for line in &sheet.rows {
        let mut first = true;
        for cell in line {
            if !first {
                written.push(SEPARATOR);
            }
            first = false;
            written.push_str(&csv_value(cell));
        }
        // Fin de ligne de Windows : c'est ce qu'attendent les tableurs, et
        // aucun ne s'en offusque sur les autres systèmes.
        written.push_str("\r\n");
    }

    std::fs::write(path, written)
}

/// Ce qu'une cellule devient en CSV. **Un nombre part en nombre**, à la
/// française et sans le symbole : c'est à cette condition qu'Excel le somme au
/// lieu de le prendre pour du texte. Les couleurs, elles, n'existent pas ici.
fn csv_value(cell: &SheetCell) -> String {
    match &cell.content {
        CellContent::Empty => String::new(),
        CellContent::Text(text) => quoted(text),
        CellContent::Number { value, .. } => {
            let written = format!("{value:.2}");
            quoted(&written.replace('.', ","))
        }
    }
}

/// Entoure de guillemets ce qui en a besoin, et double les guillemets
/// intérieurs — les trois seules règles du format.
fn quoted(text: &str) -> String {
    let needs = text.contains(SEPARATOR)
        || text.contains('"')
        || text.contains('\n')
        || text.contains('\r');
    if !needs {
        return text.to_string();
    }
    format!("\"{}\"", text.replace('"', "\"\""))
}


// ---------------------------------------------------------------------------
// Les cinq sorties de la phase 14 — le menu Export de F02.
//
// Cinq écrivains de plus au bas de ce fichier, et **rien d'autre à toucher** :
// c'est la séparation forme/écriture qui avait déjà offert l'`.ods` en une
// soirée le 26/07/2026. Les dix tableaux du logiciel les ont gagnés le même
// jour, sans qu'aucune fenêtre ne bouge d'une ligne.
//
// Ils se rangent en deux familles, et la frontière est celle que Fabrice a
// tracée pour le JSON et le XML : **Word s'adresse à un œil**, donc il porte
// les couleurs de l'écran et le gras ; INI, YAML et TOML s'adressent à un
// programme, donc **une ligne est un enregistrement**, sans couleur ni gras,
// et les montants partent au point décimal. Le TSV, lui, est un CSV dont le
// séparateur est la tabulation : c'est un format de tableur, il garde donc la
// virgule décimale française et le BOM qui va avec.
// ---------------------------------------------------------------------------

/// Le TSV — un CSV dont le séparateur est la tabulation.
///
/// **Pas de guillemets** : ce format n'en a pas. Une tabulation ou un
/// passage à la ligne à l'intérieur d'une valeur casserait la grille, et
/// aucune convention ne dit comment les protéger — on les remplace donc par
/// une espace, ce qui est la seule chose honnête à faire.
fn write_tsv(sheet: &Sheet, path: &Path) -> std::io::Result<()> {
    let mut written = String::from(BOM);
    if !sheet.context.is_empty() {
        written.push_str(&flattened(&sheet.context));
        written.push_str("\r\n\r\n");
    }
    for line in &sheet.rows {
        let cells: Vec<String> = line
            .iter()
            .map(|cell| match &cell.content {
                CellContent::Empty => String::new(),
                CellContent::Text(text) => flattened(text),
                CellContent::Number { value, .. } => format!("{value:.2}").replace('.', ","),
            })
            .collect();
        written.push_str(&cells.join("\t"));
        written.push_str("\r\n");
    }
    std::fs::write(path, written)
}

/// Une valeur dont plus rien ne peut casser une grille de tabulations.
fn flattened(text: &str) -> String {
    text.replace(['\t', '\n', '\r'], " ")
}

/// Le nom d'une colonne, tel que ces trois formats l'écrivent en clef.
///
/// « Num Chèque » porte une espace et un accent : en INI il reste tel quel,
/// mais en TOML une clef nue n'admet que des lettres, des chiffres, le tiret
/// et le souligné — elle voyage donc entre guillemets. On ne renomme jamais la
/// colonne : le fichier doit dire ce que l'écran disait.
fn quoted_key(name: &str) -> String {
    if !name.is_empty()
        && name
            .chars()
            .all(|c| c.is_ascii_alphanumeric() || c == '-' || c == '_')
    {
        return name.to_string();
    }
    format!("\"{}\"", name.replace('\\', "\\\\").replace('"', "\\\""))
}

/// Une chaîne entre guillemets, échappée comme YAML et TOML l'attendent.
fn quoted_text(text: &str) -> String {
    let mut written = String::with_capacity(text.len() + 2);
    written.push('"');
    for character in text.chars() {
        match character {
            '\\' => written.push_str("\\\\"),
            '"' => written.push_str("\\\""),
            '\n' => written.push_str("\\n"),
            '\r' => written.push_str("\\r"),
            '\t' => written.push_str("\\t"),
            other => written.push(other),
        }
    }
    written.push('"');
    written
}

/// L'INI — une section par ligne du tableau, une clef par colonne.
///
/// Le format n'a ni tableau ni valeur nulle : une case vide s'écrit donc en
/// clef sans valeur, ce qui est la façon dont l'INI dit « rien ». La section
/// `[Tableau]` en tête dit d'où vient le fichier.
fn write_ini(sheet: &Sheet, path: &Path) -> std::io::Result<()> {
    let names = column_names(sheet);
    let mut written = String::from("[Tableau]\n");
    written.push_str(&format!("Nom = {}\n", flattened(&sheet.name)));
    if !sheet.context.is_empty() {
        written.push_str(&format!("Contexte = {}\n", flattened(&sheet.context)));
    }

    for (rank, line) in data_rows(sheet).iter().enumerate() {
        written.push_str(&format!("\n[Ligne {}]\n", rank + 1));
        for (column, name) in names.iter().enumerate() {
            let Some(name) = name else { continue };
            let value = match line.get(column).map(|cell| &cell.content) {
                None | Some(CellContent::Empty) => String::new(),
                Some(CellContent::Text(text)) => flattened(text),
                Some(CellContent::Number { value, kind }) => as_exchange_number(*value, *kind),
            };
            written.push_str(&format!("{name} = {value}\n"));
        }
    }
    std::fs::write(path, written)
}

/// Le YAML — une séquence de dictionnaires sous `lignes`.
///
/// Les clefs et les valeurs de texte partent entre guillemets, sans exception :
/// un libellé qui commencerait par `-`, `:` ou `#` changerait autrement de sens
/// pour l'analyseur. Une case vide est `null`, qui est la façon dont YAML dit
/// « rien » — la même décision que le JSON de la phase 3.1.
fn write_yaml(sheet: &Sheet, path: &Path) -> std::io::Result<()> {
    let names = column_names(sheet);
    let mut written = String::new();
    written.push_str(&format!("tableau: {}\n", quoted_text(&sheet.name)));
    if !sheet.context.is_empty() {
        written.push_str(&format!("contexte: {}\n", quoted_text(&sheet.context)));
    }
    let shown: Vec<String> = names
        .iter()
        .flatten()
        .map(|name| quoted_text(name))
        .collect();
    written.push_str(&format!("colonnes: [{}]\n", shown.join(", ")));

    written.push_str("lignes:\n");
    let lines = data_rows(sheet);
    if lines.is_empty() {
        written.push_str("  []\n");
    }
    for line in lines {
        let mut first = true;
        for (column, name) in names.iter().enumerate() {
            let Some(name) = name else { continue };
            let value = match line.get(column).map(|cell| &cell.content) {
                None | Some(CellContent::Empty) => "null".to_string(),
                Some(CellContent::Text(text)) => quoted_text(text),
                Some(CellContent::Number { value, kind }) => as_exchange_number(*value, *kind),
            };
            // Le tiret ne marque que la première clef de l'enregistrement ;
            // les suivantes s'alignent dessous.
            written.push_str(if first { "  - " } else { "    " });
            first = false;
            written.push_str(&format!("{}: {value}\n", quoted_text(name)));
        }
    }
    std::fs::write(path, written)
}

/// Le TOML — un tableau de tables sous `[[lignes]]`.
///
/// **TOML n'a pas de valeur nulle**, et c'est le seul de nos formats dans ce
/// cas : une case vide ne s'y écrit donc pas du tout, l'absence de la clef
/// étant la façon dont le format dit « rien ». C'est la seule sortie où une
/// case vide et une colonne absente se ressemblent, et il vaut mieux le dire
/// ici que laisser quelqu'un le découvrir.
fn write_toml(sheet: &Sheet, path: &Path) -> std::io::Result<()> {
    let names = column_names(sheet);
    let mut written = String::new();
    written.push_str(&format!("tableau = {}\n", quoted_text(&sheet.name)));
    if !sheet.context.is_empty() {
        written.push_str(&format!("contexte = {}\n", quoted_text(&sheet.context)));
    }
    let shown: Vec<String> = names
        .iter()
        .flatten()
        .map(|name| quoted_text(name))
        .collect();
    written.push_str(&format!("colonnes = [{}]\n", shown.join(", ")));

    for line in data_rows(sheet) {
        written.push_str("\n[[lignes]]\n");
        for (column, name) in names.iter().enumerate() {
            let Some(name) = name else { continue };
            let value = match line.get(column).map(|cell| &cell.content) {
                None | Some(CellContent::Empty) => continue,
                Some(CellContent::Text(text)) => quoted_text(text),
                Some(CellContent::Number { value, kind }) => as_exchange_number(*value, *kind),
            };
            written.push_str(&format!("{} = {value}\n", quoted_key(name)));
        }
    }
    std::fs::write(path, written)
}

/// Le `.docx` — le même tableau, dans un tableau Word.
///
/// Word sait faire des tableaux, et c'est tout ce qu'on lui demande (remarque
/// de Fabrice, 30/07/2026, après que j'eus compliqué la question). Il est donc
/// rangé avec Excel et Calc : il s'adresse à un œil, il porte les couleurs de
/// l'écran, le gras des titres, et les montants **écrits comme on les lit** —
/// un document Word ne somme rien, la virgule décimale y est donc la
/// française.
///
/// Page en paysage : le tableau des opérations a onze colonnes, et un portrait
/// les écraserait.
fn write_docx(sheet: &Sheet, path: &Path) -> std::io::Result<()> {
    use office_toolkit::word::{
        Alignment, Block, Document, Orientation, Paragraph, Run, Table, TableCell, TableRow,
    };
    use office_toolkit::SaveToFile;

    let mut document = Document::default();
    document.page_setup = document
        .page_setup
        .with_orientation(Orientation::Landscape);
    // Le paysage ne fait pas tourner la page tout seul : les dimensions se
    // donnent déjà dans le bon sens (A4 couché).
    document.page_setup.width_twips = 16_838;
    document.page_setup.height_twips = 11_906;

    let mut title = Paragraph::default();
    title.runs.push({
        let mut run = Run::new(sheet.name.clone());
        run.bold = true;
        run
    });
    document.blocks.push(Block::Paragraph(title));
    if !sheet.context.is_empty() {
        let mut line = Paragraph::default();
        line.runs.push({
            let mut run = Run::new(sheet.context.clone());
            run.italic = true;
            run
        });
        document.blocks.push(Block::Paragraph(line));
    }
    document.blocks.push(Block::Paragraph(Paragraph::default()));

    let mut table = Table::new();
    for (rank, line) in sheet.rows.iter().enumerate() {
        let heading = rank < sheet.header_rows;
        let mut row = TableRow::new().with_repeat_as_header_row(heading);
        for cell in line {
            let (text, numeric) = match &cell.content {
                CellContent::Empty => (String::new(), false),
                CellContent::Text(text) => (text.clone(), false),
                CellContent::Number { value, kind } => (
                    match kind {
                        NumberKind::Money => format!("{value:.2}").replace('.', ","),
                        NumberKind::Plain => as_exchange_number(*value, *kind),
                    },
                    true,
                ),
            };
            let mut paragraph = Paragraph::default();
            if numeric {
                paragraph.alignment = Some(Alignment::Right);
            }
            paragraph.runs.push({
                let mut run = Run::new(text);
                run.bold = cell.bold || heading;
                run
            });
            let mut written = TableCell::new().with_paragraph(paragraph);
            written.border = true;
            // Les couleurs sont celles de l'écran, sans la dièse d'OOXML.
            written.shading_color = cell
                .fill
                .as_ref()
                .map(|fill| fill.trim_start_matches('#').to_string());
            row = row.with_cell(written);
        }
        table = table.with_row(row);
    }
    document.blocks.push(Block::Table(table));

    document
        .save_to_file(path)
        .map_err(|error| std::io::Error::other(error.to_string()))
}

#[cfg(test)]
mod tests {
    use super::*;

    const EURO: i64 = 1_000_000;

    fn a_sheet() -> Sheet {
        let mut sheet = Sheet::new("Categories");
        sheet.context = "Statistiques par catégorie — 2026 — 2 comptes".to_string();
        sheet.header_rows = 1;
        sheet.rows = vec![
            vec![
                SheetCell::text("NomCategorie"),
                SheetCell::text("Janvier"),
                SheetCell::text("Total"),
            ],
            vec![
                SheetCell::text("Alimentation"),
                SheetCell::money(-619 * EURO).with_fill(Some("FF9999".to_string())),
                SheetCell::money(-619 * EURO),
            ],
            vec![
                SheetCell::text("Coiffeur"),
                SheetCell::empty(),
                SheetCell::empty(),
            ],
        ];
        sheet.widths = vec![32.0, 14.0, 14.0];
        sheet
    }

    /// Les tests d'un même module tournent en parallèle : chacun écrit dans
    /// son propre fichier, sinon ils se marchent dessus et l'échec ne dit rien
    /// de ce qu'on voulait vérifier.
    fn written_csv_as(sheet: &Sheet, who: &str) -> String {
        let file = std::env::temp_dir()
            .join(format!("radinus-{who}-{}.csv", std::process::id()));
        write(sheet, &file).expect("écriture");
        let read = std::fs::read_to_string(&file).expect("relecture");
        std::fs::remove_file(&file).ok();
        read
    }

    /// Le BOM, le point-virgule, la virgule décimale : les trois choses qui
    /// font qu'Excel français ouvre le fichier correctement.
    #[test]
    fn the_csv_is_the_one_a_french_excel_expects() {
        let written = written_csv_as(&a_sheet(), "francais");
        assert!(written.starts_with('\u{feff}'), "il manque le BOM");
        assert!(written.contains("NomCategorie;Janvier;Total"));
        assert!(
            written.contains("Alimentation;-619,00;-619,00"),
            "virgule décimale, sans symbole : {written}"
        );
    }

    /// Une case vide reste vide : c'est ce que montre l'écran, et un zéro
    /// serait un chiffre inventé.
    #[test]
    fn an_empty_cell_stays_empty() {
        assert!(written_csv_as(&a_sheet(), "vide").contains("Coiffeur;;"));
    }

    /// La ligne de contexte est en tête, suivie d'une ligne vide.
    #[test]
    fn the_file_says_where_it_comes_from() {
        let written = written_csv_as(&a_sheet(), "contexte");
        let mut lines = written.trim_start_matches('\u{feff}').lines();
        assert_eq!(
            lines.next(),
            Some("Statistiques par catégorie — 2026 — 2 comptes")
        );
        assert_eq!(lines.next(), Some(""));
        assert_eq!(lines.next(), Some("NomCategorie;Janvier;Total"));
    }

    /// Les trois règles du format, sur un libellé qui les déclenche toutes.
    #[test]
    fn a_label_that_would_break_the_format_is_quoted() {
        assert_eq!(quoted("Courses"), "Courses");
        assert_eq!(quoted("Poires ; pommes"), "\"Poires ; pommes\"");
        assert_eq!(quoted("Le \"grand\" marché"), "\"Le \"\"grand\"\" marché\"");
        assert_eq!(quoted("Deux\nlignes"), "\"Deux\nlignes\"");

        let mut sheet = Sheet::new("x");
        sheet.rows = vec![vec![
            SheetCell::text("Poires ; pommes"),
            SheetCell::money(EURO),
        ]];
        assert!(written_csv_as(&sheet, "guillemets").contains("\"Poires ; pommes\";1,00"));
    }


    /// **Les quatre sorties de texte de la phase 14**, et ce qui les distingue.
    ///
    /// Le TSV est un format de tableur : virgule décimale, tabulation en
    /// séparateur. Les trois autres s'adressent à un programme : point décimal,
    /// une ligne est un enregistrement. Et chacun dit « rien » à sa façon —
    /// c'est le seul endroit où ils divergent vraiment.
    #[test]
    fn les_quatre_sorties_de_texte_disent_chacune_le_vide_a_sa_facon() {
        let sheet = a_sheet();

        // TSV : tabulations, virgule décimale, et une case vide reste vide.
        let tsv = written_as(&sheet, "tsv", "tsv");
        assert!(tsv.starts_with(BOM), "le BOM, pour l'Excel français");
        assert!(tsv.contains("NomCategorie\tJanvier\tTotal\r\n"));
        assert!(tsv.contains("Alimentation\t-619,00\t-619,00\r\n"));
        assert!(tsv.contains("Coiffeur\t\t\r\n"), "deux cases vides");

        // INI : une section par ligne, une clef sans valeur pour le vide.
        let ini = written_as(&sheet, "ini", "ini");
        assert!(ini.contains("[Tableau]\nNom = Categories\n"));
        assert!(ini.contains("[Ligne 1]\nNomCategorie = Alimentation\n"));
        assert!(ini.contains("Janvier = -619.00\n"), "point décimal");
        assert!(ini.contains("[Ligne 2]\nNomCategorie = Coiffeur\nJanvier = \n"));

        // YAML : `null` pour le vide, tout entre guillemets pour qu'un libellé
        // commençant par `-` ne change pas de sens.
        let yaml = written_as(&sheet, "yaml", "yaml");
        assert!(yaml.contains("  - \"NomCategorie\": \"Alimentation\"\n"));
        assert!(yaml.contains("    \"Janvier\": -619.00\n"));
        assert!(yaml.contains("    \"Janvier\": null\n"), "le vide est null");

        // TOML : **la clef absente**, seule façon dont ce format dit « rien ».
        let toml = written_as(&sheet, "toml", "toml");
        // Une clef qui n'a besoin de rien reste nue ; c'est « Num Chèque »,
        // avec son espace et son accent, qui prend des guillemets.
        assert!(toml.contains("[[lignes]]\nNomCategorie = \"Alimentation\"\n"));
        assert!(toml.contains("Janvier = -619.00\n"));
        let last = toml.rsplit("[[lignes]]").next().expect("le dernier");
        assert!(last.contains("\"Coiffeur\""));
        assert!(
            !last.contains("Janvier"),
            "une case vide ne s'écrit pas du tout en TOML : {last}"
        );

        // Aucune des quatre ne porte de couleur : elles ne s'adressent pas à
        // un œil — sauf le TSV, qui n'a de toute façon nulle part où en mettre.
        for written in [&ini, &yaml, &toml] {
            assert!(!written.contains("FF9999"), "aucune couleur ici");
        }
    }

    /// Le `.docx` est un vrai document Word, et son tableau se relit.
    ///
    /// Word s'adresse à un œil : il garde donc les couleurs de l'écran et le
    /// gras des titres, comme Excel et Calc — c'est la frontière que Fabrice a
    /// tracée entre les formats de bureautique et les formats d'échange.
    #[test]
    fn le_docx_est_un_vrai_document_word_dont_le_tableau_se_relit() {
        use office_toolkit::word::{Block, Document};
        use office_toolkit::OpenFile;

        let file = std::env::temp_dir().join(format!("radinus-docx-{}.docx", std::process::id()));
        write(&a_sheet(), &file).expect("écriture");
        let read = Document::open_file(&file).expect("relecture");
        std::fs::remove_file(&file).ok();

        // Le titre, la ligne de contexte, une ligne vide, puis le tableau.
        let table = read
            .blocks
            .iter()
            .find_map(|block| match block {
                Block::Table(table) => Some(table),
                _ => None,
            })
            .expect("un tableau");
        assert_eq!(table.rows.len(), 3, "l'en-tête et les deux lignes");

        let text_of = |row: usize, cell: usize| -> String {
            table.rows[row].cells[cell]
                .blocks
                .iter()
                .filter_map(|block| match block {
                    Block::Paragraph(paragraph) => Some(paragraph),
                    _ => None,
                })
                .flat_map(|paragraph| paragraph.runs.iter())
                .filter_map(|run| match &run.content {
                    office_toolkit::word::RunContent::Text(text) => Some(text.as_str()),
                    _ => None,
                })
                .collect()
        };

        assert_eq!(text_of(0, 0), "NomCategorie");
        assert_eq!(text_of(1, 0), "Alimentation");
        // Le montant s'écrit comme on le lit : Word ne somme rien.
        assert_eq!(text_of(1, 1), "-619,00");
        assert_eq!(text_of(2, 1), "", "une case vide reste vide");
        // La couleur de l'écran est là, et le gras du titre aussi.
        assert_eq!(
            table.rows[1].cells[1].shading_color.as_deref(),
            Some("FF9999")
        );
    }

    /// Le classeur s'écrit, et se relit comme un vrai `.xlsx`.
    #[test]
    fn the_workbook_is_a_real_xlsx_that_reads_back() {
        use office_toolkit::excel::{CellValue, Workbook};
        use office_toolkit::OpenFile;

        let file = std::env::temp_dir().join(format!("radinus-xlsx-{}.xlsx", std::process::id()));
        write(&a_sheet(), &file).expect("écriture");

        let read = Workbook::open_file(&file).expect("relecture");
        std::fs::remove_file(&file).ok();

        let tab = read.sheets.first().expect("un onglet");
        assert_eq!(tab.name, "Categories");

        // Le contexte, la ligne vide, puis l'en-tête et les données.
        let context = &tab.rows[0].cells[0];
        assert_eq!(
            context.value,
            CellValue::Text("Statistiques par catégorie — 2026 — 2 comptes".to_string())
        );
        assert!(context.format.as_ref().expect("un style").bold);

        let heading = &tab.rows[2].cells[0];
        assert_eq!(heading.value, CellValue::Text("NomCategorie".to_string()));
        assert!(heading.format.as_ref().expect("un style").bold, "en gras");

        // **Un montant est un nombre**, pas un texte : c'est à cette condition
        // qu'on peut le sommer dans Excel.
        let amount = &tab.rows[3].cells[1];
        assert_eq!(amount.value, CellValue::Number(-619.0));
        let format = amount.format.as_ref().expect("un style");
        assert_eq!(format.number_format.as_deref(), Some(MONEY_FORMAT));
        // Et la couleur de l'écran est reprise, en ARGB opaque.
        assert_eq!(format.fill_color.as_deref(), Some("FFFF9999"));
    }

    /// Le classeur d'OpenDocument s'écrit, et se relit comme un vrai `.ods`.
    ///
    /// Même exigence que pour le `.xlsx` : le montant doit être un **nombre**,
    /// avec son format monétaire, et la couleur de l'écran doit y être. Sinon
    /// LibreOffice recevrait un tableau qu'il ne sait pas sommer.
    #[test]
    fn the_workbook_is_a_real_ods_that_reads_back() {
        use spreadsheet_ods::Value;

        let file = std::env::temp_dir().join(format!("radinus-ods-{}.ods", std::process::id()));
        write(&a_sheet(), &file).expect("écriture");

        let read = spreadsheet_ods::read_ods(&file).expect("relecture");
        std::fs::remove_file(&file).ok();

        let tab = read.sheet(0);
        assert_eq!(tab.name(), "Categories");

        // Le contexte en tête, une ligne vide, puis l'en-tête et les données.
        assert_eq!(
            tab.value(0, 0),
            &Value::Text("Statistiques par catégorie — 2026 — 2 comptes".to_string())
        );
        assert_eq!(tab.value(2, 0), &Value::Text("NomCategorie".to_string()));

        // **Un montant est de l'argent**, pas du texte : c'est le type propre
        // d'OpenDocument, et Calc le somme comme tel.
        assert_eq!(tab.value(3, 1), &Value::Currency(-619.0, "EUR".into()));

        // Et la couleur de l'écran est reprise telle quelle.
        let style = read
            .cellstyle(tab.cellstyle(3, 1).expect("un style"))
            .expect("le style existe");
        assert_eq!(
            style.cellstyle().attr("fo:background-color"),
            Some("#ff9999")
        );

        // Une case vide sans apparence n'est pas écrite du tout.
        assert_eq!(tab.value(4, 1), &Value::Empty);
    }

    /// Une couleur illisible n'empêche pas d'exporter : on écrit la cellule
    /// sans fond, plutôt que de refuser le fichier.
    #[test]
    fn a_colour_that_is_not_one_is_simply_ignored() {
        assert_eq!(as_rgb("FF9999"), Some((255, 153, 153)));
        assert_eq!(as_rgb("#ff9999"), Some((255, 153, 153)));
        assert_eq!(as_rgb("rouge"), None);
        assert_eq!(as_rgb("FF99"), None);
        assert_eq!(as_rgb("ZZ9999"), None);
    }

    fn written_as(sheet: &Sheet, who: &str, extension: &str) -> String {
        let file = std::env::temp_dir().join(format!(
            "radinus-{who}-{}.{extension}",
            std::process::id()
        ));
        write(sheet, &file).expect("écriture");
        let read = std::fs::read_to_string(&file).expect("relecture");
        std::fs::remove_file(&file).ok();
        read
    }

    /// **Une ligne est un enregistrement**, dont les champs portent les noms
    /// des colonnes affichées (choix de Fabrice, 26/07/2026) — et un montant
    /// est un nombre, sinon le programme qui relit ne peut rien en faire.
    #[test]
    fn the_json_is_one_record_per_row() {
        let written = written_as(&a_sheet(), "json", "json");
        let parsed: serde_json::Value = serde_json::from_str(&written).expect("du JSON valide");

        assert_eq!(parsed["tableau"], "Categories");
        assert_eq!(
            parsed["contexte"],
            "Statistiques par catégorie — 2026 — 2 comptes"
        );

        // Les colonnes gardent l'ordre de l'écran : « Total » est le dernier,
        // et non le premier comme un tri alphabétique le mettrait.
        assert_eq!(
            parsed["colonnes"],
            serde_json::json!(["NomCategorie", "Janvier", "Total"])
        );

        let lines = parsed["lignes"].as_array().expect("des lignes");
        assert_eq!(lines.len(), 2, "la ligne de titres n'est pas une donnée");
        assert_eq!(lines[0]["NomCategorie"], "Alimentation");
        assert_eq!(lines[0]["Janvier"], serde_json::json!(-619.0));
        assert!(
            lines[0]["Janvier"].is_number(),
            "un montant est un nombre, pas du texte"
        );

        // Une case vide reste une case vide, et le champ le dit.
        assert_eq!(lines[1]["Janvier"], serde_json::Value::Null);
    }

    /// Ni couleurs ni gras : ces deux formats-là ne portent que des valeurs.
    #[test]
    fn the_exchange_formats_carry_no_colours() {
        for (who, extension) in [("json-nu", "json"), ("xml-nu", "xml")] {
            let written = written_as(&a_sheet(), who, extension);
            assert!(
                !written.contains("FF9999") && !written.to_lowercase().contains("bold"),
                "{extension} ne devrait porter aucune apparence : {written}"
            );
        }
    }

    /// Le XML dit la même chose, dans sa grammaire à lui.
    #[test]
    fn the_xml_names_each_cell_by_its_column() {
        let written = written_as(&a_sheet(), "xml", "xml");
        assert!(written.starts_with("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"));
        assert!(written.contains("<tableau nom=\"Categories\""));
        assert!(
            written.contains("<cellule colonne=\"NomCategorie\" type=\"texte\">Alimentation</cellule>"),
            "{written}"
        );
        assert!(
            written.contains("<cellule colonne=\"Janvier\" type=\"montant\">-619.00</cellule>"),
            "un montant au point décimal : {written}"
        );
        assert!(
            written.contains("<cellule colonne=\"Janvier\" type=\"vide\"></cellule>"),
            "une case vide se dit : {written}"
        );
    }

    /// Une saisie libre peut porter n'importe quoi, et le fichier doit rester
    /// lisible d'un bout à l'autre.
    #[test]
    fn a_label_that_would_break_the_xml_is_escaped() {
        assert_eq!(escaped("Poires & pommes"), "Poires &amp; pommes");
        assert_eq!(escaped("a < b > c"), "a &lt; b &gt; c");
        assert_eq!(escaped("Le \"grand\" marché"), "Le &quot;grand&quot; marché");
        assert_eq!(escaped("l'été"), "l&apos;été");
        // Un caractère de contrôle est ôté : le XML n'en admet aucun.
        assert_eq!(escaped("avant\u{0007}après"), "avantaprès");
        // Les accents, eux, ne sont pas des caractères à échapper.
        assert_eq!(escaped("Vétérinaire"), "Vétérinaire");

        let mut sheet = Sheet::new("x");
        sheet.header_rows = 1;
        sheet.rows = vec![
            vec![SheetCell::text("Libelle")],
            vec![SheetCell::text("Poires & <pommes>")],
        ];
        let written = written_as(&sheet, "xml-echappe", "xml");
        assert!(written.contains("Poires &amp; &lt;pommes&gt;"), "{written}");

        // Et le JSON échappe les siens, qui ne sont pas les mêmes.
        sheet.rows[1] = vec![SheetCell::text("Le \"grand\" marché\\")];
        let written = written_as(&sheet, "json-echappe", "json");
        serde_json::from_str::<serde_json::Value>(&written).expect("du JSON valide malgré tout");
    }

    /// Une colonne sans titre est sautée : la liste des opérations en a une,
    /// celle du « + » qui déplie une ventilation.
    #[test]
    fn a_column_without_a_heading_is_left_out() {
        let mut sheet = Sheet::new("Operations");
        sheet.header_rows = 1;
        sheet.rows = vec![
            vec![
                SheetCell::text(""),
                SheetCell::text("Libelle"),
                SheetCell::text("Libelle"),
            ],
            vec![
                SheetCell::text("+"),
                SheetCell::text("COURSES"),
                SheetCell::text("bis"),
            ],
        ];
        let parsed: serde_json::Value =
            serde_json::from_str(&written_as(&sheet, "sans-titre", "json")).expect("du JSON");

        // La colonne muette n'est pas là ; la colonne en double, si, sous un
        // nom numéroté — un fichier ne perd pas une colonne en silence.
        assert_eq!(
            parsed["colonnes"],
            serde_json::json!(["Libelle", "Libelle 2"])
        );
        assert_eq!(parsed["lignes"][0]["Libelle"], "COURSES");
        assert_eq!(parsed["lignes"][0]["Libelle 2"], "bis");
    }

    /// **Un onglet par année**, ce que demande « exporter toutes les années »
    /// (Fabrice, 26/07/2026). Vérifié en relisant le classeur : les trois
    /// onglets sont là, dans l'ordre, avec chacun ses propres chiffres.
    #[test]
    fn a_workbook_holds_one_tab_per_year() {
        use office_toolkit::excel::{CellValue, Workbook};
        use office_toolkit::OpenFile;

        let book: Vec<Sheet> = [2024, 2025, 2026]
            .iter()
            .map(|year| {
                let mut sheet = a_sheet();
                sheet.name = format!("AN_{year}");
                sheet.context = format!("Statistiques par catégorie — {year}");
                sheet.rows[1][1] = SheetCell::money(*year as i64 * EURO);
                sheet
            })
            .collect();

        let file = std::env::temp_dir().join(format!("radinus-livre-{}.xlsx", std::process::id()));
        write_book(&book, &file).expect("écriture");
        let read = Workbook::open_file(&file).expect("relecture");
        std::fs::remove_file(&file).ok();

        assert_eq!(read.sheets.len(), 3);
        for (index, year) in [2024, 2025, 2026].iter().enumerate() {
            let tab = &read.sheets[index];
            assert_eq!(tab.name, format!("AN_{year}"));
            // Chaque onglet dit sur quelle année il porte…
            assert_eq!(
                tab.rows[0].cells[0].value,
                CellValue::Text(format!("Statistiques par catégorie — {year}"))
            );
            // …et porte bien ses chiffres à lui.
            assert_eq!(
                tab.rows[3].cells[1].value,
                CellValue::Number(*year as f64),
                "l'onglet {year} a les chiffres d'une autre année"
            );
        }
    }

    /// Et l'`.ods` en fait autant, puisque OpenDocument a des onglets aussi.
    #[test]
    fn the_ods_workbook_holds_several_tabs_too() {
        let book: Vec<Sheet> = [2025, 2026]
            .iter()
            .map(|year| {
                let mut sheet = a_sheet();
                sheet.name = format!("AN_{year}");
                sheet
            })
            .collect();

        let file = std::env::temp_dir().join(format!("radinus-livre-{}.ods", std::process::id()));
        write_book(&book, &file).expect("écriture");
        let read = spreadsheet_ods::read_ods(&file).expect("relecture");
        std::fs::remove_file(&file).ok();

        assert_eq!(read.num_sheets(), 2);
        assert_eq!(read.sheet(0).name(), "AN_2025");
        assert_eq!(read.sheet(1).name(), "AN_2026");
    }

    /// Un classeur vide n'est pas un fichier : on refuse plutôt que d'écrire
    /// une coquille que l'utilisateur croira pleine.
    #[test]
    fn an_empty_workbook_is_refused() {
        let file = std::env::temp_dir().join(format!("radinus-vide-{}.xlsx", std::process::id()));
        assert!(write_book(&[], &file).is_err());
        assert!(!file.exists(), "et rien n'a été écrit");
    }

    /// Un nom d'onglet trop long ou interdit ne doit pas faire échouer un
    /// export : on le raccourcit, on ne renonce pas.
    #[test]
    fn a_tab_name_is_always_one_a_spreadsheet_accepts() {
        assert_eq!(tab_name("AN_2026"), "AN_2026");
        assert_eq!(tab_name("Statistiques par categorie"), "Statistiques par categorie");
        assert_eq!(tab_name("Comptes 2025/2026"), "Comptes 2025 2026");
        assert_eq!(tab_name("   "), "Radinus");
        assert_eq!(tab_name(&"a".repeat(40)), "a".repeat(31));
    }

    /// L'extension décide du format, puisque c'est l'utilisateur qui l'a
    /// choisie dans le sélecteur du système.
    #[test]
    fn the_extension_chooses_the_format() {
        let sheet = a_sheet();
        let folder = std::env::temp_dir();
        let stem = format!("radinus-choix-{}", std::process::id());

        let csv = folder.join(format!("{stem}.CSV"));
        write(&sheet, &csv).expect("csv");
        assert!(
            std::fs::read_to_string(&csv).expect("relecture").starts_with('\u{feff}'),
            "l'extension en majuscules compte autant"
        );
        std::fs::remove_file(&csv).ok();

        // L'`.ods` est une archive, comme le `.xlsx`, mais ce n'est pas le
        // même : c'est son type MIME qui les distingue.
        let ods = folder.join(format!("{stem}.ODS"));
        write(&sheet, &ods).expect("ods");
        let mime = std::fs::read(&ods).expect("relecture");
        std::fs::remove_file(&ods).ok();
        assert!(
            String::from_utf8_lossy(&mime[0..100])
                .contains("application/vnd.oasis.opendocument.spreadsheet"),
            "un .ods s'annonce par son type MIME, en clair au début de l'archive"
        );

        // Sans extension connue, c'est le format riche.
        let other = folder.join(format!("{stem}.dat"));
        write(&sheet, &other).expect("xlsx");
        let bytes = std::fs::read(&other).expect("relecture");
        std::fs::remove_file(&other).ok();
        assert_eq!(&bytes[0..2], b"PK", "un .xlsx est une archive zip");
    }
}
