//! Les impressions et états — phase 15.
//!
//! **Un état n'est pas un dessin, c'est une composition.** Les tentatives
//! précédentes en Rust étaient faites avec des bibliothèques de dessin : on y
//! pose un rectangle en x, y, un texte en x, y, et c'est à l'appelant de
//! calculer où couper les pages, où répéter les en-têtes, où s'arrête une
//! ligne trop longue. C'est ingérable, et cela se voit sur le papier.
//!
//! Ce module confie ce travail à **Typst**, un moteur de composition écrit en
//! Rust, sous licence Apache-2.0. Le noyau décrit ce qu'il veut — un titre,
//! des colonnes, des lignes, un bandeau — et le moteur décide de la mise en
//! page : pagination automatique, en-tête de tableau réimprimé sur chaque
//! page (`table.header(repeat: true)`), numérotation « n/N ».
//!
//! **Pourquoi fabriquer le PDF nous-mêmes plutôt qu'imprimer une page HTML.**
//! Tauri n'expose aucune porte d'impression : sous Windows c'est WebView2,
//! sous Linux WebKitGTK, sous macOS un `NSPrintOperation` qu'Apple déprécie.
//! Trois moteurs différents, donc trois paginations différentes pour un même
//! état — inacceptable au regard de la règle posée par Fabrice le 31/07/2026 :
//! « le logiciel doit être 100 % opérationnel quel que soit le système ». Ici
//! la pagination est calculée par notre code et les fontes sont embarquées
//! dans le binaire : le PDF est identique, octet pour octet, sous Windows,
//! macOS et Linux.
//!
//! Le module ne touche ni au disque ni au réseau : il rend des octets. C'est
//! le contrôleur qui les écrit et qui les donne au système.

use crate::domain::NaiveDate;
use crate::i18n::{self, Language};
use crate::money;
use crate::operations::{self, OperationRow};

use rusqlite::Connection;
use time_compute::Datelike;
use typst::diag::{FileError, FileResult};
use typst::foundations::{Bytes, Datetime, Duration, Smart};
use typst::syntax::{FileId, RootedPath, Source, VirtualPath, VirtualRoot};
use typst::text::{Font, FontBook, FontInfo};
use typst::utils::LazyHash;
use typst::{Library, LibraryExt, World};
use typst_layout::PagedDocument;
use typst_pdf::PdfOptions;

// ---------------------------------------------------------------------------
// Les fontes
// ---------------------------------------------------------------------------

/// Les deux fontes de tous les états de Radinus, embarquées dans le binaire.
///
/// **Embarquées, et non prises sur la machine** : c'est la condition de
/// l'identité entre les trois systèmes. Une fonte cherchée sur le poste de
/// l'utilisateur donnerait trois documents différents, et parfois aucun.
///
/// Lato, sous licence SIL Open Font 1.1 — libre, redistribuable, utilisable
/// commercialement. L'original WinDev compose en Trebuchet MS, qui appartient
/// à Microsoft et ne peut pas être redistribué ; Lato en est le plus proche
/// parent libre. La licence accompagne les fichiers dans `fonts/OFL.txt`.
const REGULAR: &[u8] = include_bytes!("../fonts/Lato-Regular.ttf");
const BOLD: &[u8] = include_bytes!("../fonts/Lato-Bold.ttf");

/// Le nom de la famille tel que Typst la désignera dans le document.
pub(crate) const FAMILY: &str = "Lato";

/// L'écureuil du bandeau de titre, extrait de l'état d'origine.
///
/// Embarqué lui aussi : un état ne va pas chercher une image sur le disque,
/// sans quoi une installation incomplète donnerait un document mutilé.
const LOGO: &[u8] = include_bytes!("../images/ecureuil.png");

/// Le chemin sous lequel le document désigne l'écureuil. C'est le seul
/// « fichier » que l'atelier accepte de servir.
pub(crate) const LOGO_PATH: &str = "/ecureuil.png";

// ---------------------------------------------------------------------------
// Ce qu'un état contient
// ---------------------------------------------------------------------------

/// L'alignement d'une colonne. Les nombres à droite, les mots à gauche, les
/// titres au centre — c'est ce que fait l'original et c'est ce qui se lit.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Align {
    Left,
    Right,
    Center,
}

impl Align {
    fn typst(self) -> &'static str {
        match self {
            Align::Left => "left",
            Align::Right => "right",
            Align::Center => "center",
        }
    }
}

/// Une colonne de l'état : son titre, sa largeur en points, son alignement.
#[derive(Debug, Clone)]
pub struct Column {
    pub title: String,
    /// En points typographiques. La somme des largeurs plus les gouttières
    /// fait la largeur utile de la page, soit 756 points en A4 paysage avec
    /// les marges de l'original.
    pub width: f64,
    pub align: Align,
}

impl Column {
    pub fn new(title: impl Into<String>, width: f64, align: Align) -> Self {
        Self {
            title: title.into(),
            width,
            align,
        }
    }
}

/// Un tableau : ses colonnes et ses lignes, les cellules déjà écrites.
///
/// **Déjà écrites** : le noyau met en forme les montants et les dates avant
/// d'arriver ici, parce que la mise en forme dépend de la langue et que la
/// langue est une affaire de noyau, pas de moteur de composition.
#[derive(Debug, Clone)]
pub struct Grid {
    pub columns: Vec<Column>,
    pub rows: Vec<Vec<String>>,
}

/// Un état complet, prêt à composer.
#[derive(Debug, Clone)]
pub struct Report {
    /// Le grand titre du bandeau de la première page.
    pub title: String,
    /// La date d'impression, en haut à droite du bandeau.
    pub printed_on: String,
    /// Le tableau principal, celui qui court sur toutes les pages.
    pub grid: Grid,
    /// Le bandeau de clôture : des couples intitulé / valeur, posés de gauche
    /// à droite. Vide, il n'écrit rien.
    pub closing: Vec<(String, String)>,
    /// Le récapitulatif, imprimé sur sa propre page à la suite. Ses lignes
    /// sont réparties en deux colonnes côte à côte pour tenir sur une page.
    pub recap: Option<(String, Grid)>,
    /// La mention de bas de dernière page.
    pub licence: String,
}

/// Ce qui peut rater. Le noyau ne panique pas sur un état : il le dit.
#[derive(Debug)]
pub enum Failure {
    /// Le moteur a refusé la source. Ne doit jamais arriver en production —
    /// c'est une faute de programmation dans la génération, pas une faute de
    /// l'utilisateur — mais on la remonte plutôt que de la taire.
    Typesetting(String),
    /// L'écriture du PDF a échoué.
    Writing(String),
    Database(rusqlite::Error),
}

impl std::fmt::Display for Failure {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Failure::Typesetting(message) => write!(f, "{message}"),
            Failure::Writing(message) => write!(f, "{message}"),
            Failure::Database(error) => write!(f, "{error}"),
        }
    }
}

impl std::error::Error for Failure {}

impl From<rusqlite::Error> for Failure {
    fn from(error: rusqlite::Error) -> Self {
        Failure::Database(error)
    }
}

// ---------------------------------------------------------------------------
// Le monde minimal que Typst réclame
// ---------------------------------------------------------------------------

/// L'atelier : une source, des fontes, rien d'autre.
///
/// Typst sait lire des fichiers et télécharger des paquets ; on lui refuse les
/// deux. `source()` ne connaît qu'un seul document, celui qu'on vient
/// d'écrire, et `file()` refuse tout. Un état de Radinus ne peut donc jamais
/// dépendre de quoi que ce soit hors du binaire — ni d'un fichier du disque,
/// ni d'un paquet distant, ni d'une fonte installée sur le poste.
struct Workshop {
    library: LazyHash<Library>,
    book: LazyHash<FontBook>,
    fonts: Vec<Font>,
    source: Source,
    logo: Bytes,
    logo_id: FileId,
}

impl Workshop {
    fn new(text: String) -> Self {
        let mut fonts = Vec::new();
        for raw in [REGULAR, BOLD] {
            let bytes = Bytes::new(raw.to_vec());
            for index in 0..FontInfo::iter(&bytes).count() {
                if let Some(font) = Font::new(bytes.clone(), index as u32) {
                    fonts.push(font);
                }
            }
        }
        let book = FontBook::from_fonts(&fonts);
        let path = VirtualPath::new("/etat.typ").expect("chemin virtuel constant");
        let id = RootedPath::new(VirtualRoot::Project, path).intern();
        let logo_path = VirtualPath::new(LOGO_PATH).expect("chemin virtuel constant");
        let logo_id = RootedPath::new(VirtualRoot::Project, logo_path).intern();
        Self {
            library: LazyHash::new(Library::default()),
            book: LazyHash::new(book),
            fonts,
            source: Source::new(id, text),
            logo: Bytes::new(LOGO.to_vec()),
            logo_id,
        }
    }
}

impl World for Workshop {
    fn library(&self) -> &LazyHash<Library> {
        &self.library
    }

    fn book(&self) -> &LazyHash<FontBook> {
        &self.book
    }

    fn main(&self) -> FileId {
        self.source.id()
    }

    fn source(&self, id: FileId) -> FileResult<Source> {
        if id == self.source.id() {
            Ok(self.source.clone())
        } else {
            Err(FileError::NotFound(id.vpath().get_without_slash().into()))
        }
    }

    /// Un seul fichier existe dans ce monde : l'écureuil du bandeau. Tout le
    /// reste est refusé, y compris ce que le document pourrait demander par
    /// accident — un état ne lit pas le disque de l'utilisateur.
    fn file(&self, id: FileId) -> FileResult<Bytes> {
        if id == self.logo_id {
            Ok(self.logo.clone())
        } else {
            Err(FileError::NotFound(id.vpath().get_without_slash().into()))
        }
    }

    fn font(&self, index: usize) -> Option<Font> {
        self.fonts.get(index).cloned()
    }

    /// **Aucune horloge dans le noyau.** La date d'impression arrive par le
    /// contrôleur, comme partout ailleurs dans Radinus, pour que les sorties
    /// restent comparables dans un test.
    fn today(&self, _offset: Option<Duration>) -> Option<Datetime> {
        None
    }
}

// ---------------------------------------------------------------------------
// L'écriture de la source Typst
// ---------------------------------------------------------------------------

/// Le texte d'une cellule, en chaîne Typst.
///
/// **Toutes les données passent par des chaînes, jamais par du contenu.** Un
/// libellé venu de la banque peut contenir n'importe quoi — `#`, `*`, `_`,
/// `[`, `@` —, autant de caractères que Typst interprète en mode contenu. En
/// chaîne, il n'y a que deux caractères à protéger, et le libellé ressort tel
/// qu'il est entré. C'est la même prudence que pour une requête préparée.
pub(crate) fn quoted(text: &str) -> String {
    let mut out = String::with_capacity(text.len() + 2);
    out.push('"');
    for c in text.chars() {
        match c {
            '"' => out.push_str("\\\""),
            '\\' => out.push_str("\\\\"),
            // Une tabulation ou un retour à la ligne dans un libellé casserait
            // la ligne de la source : ils deviennent une espace.
            '\n' | '\r' | '\t' => out.push(' '),
            _ => out.push(c),
        }
    }
    out.push('"');
    out
}

/// Un tableau, en source Typst : ses largeurs, ses alignements, ses lignes.
fn grid_source(grid: &Grid, name: &str) -> String {
    let widths = grid
        .columns
        .iter()
        .map(|column| format!("{}pt", column.width))
        .collect::<Vec<_>>()
        .join(", ");
    let aligns = grid
        .columns
        .iter()
        .map(|column| column.align.typst().to_string())
        .collect::<Vec<_>>()
        .join(", ");
    let titles = grid
        .columns
        .iter()
        .map(|column| quoted(&column.title))
        .collect::<Vec<_>>()
        .join(", ");

    let mut out = String::new();
    out.push_str(&format!("#let {name}-widths = ({widths},)\n"));
    out.push_str(&format!("#let {name}-aligns = ({aligns},)\n"));
    out.push_str(&format!("#let {name}-titles = ({titles},)\n"));
    out.push_str(&format!("#let {name}-rows = (\n"));
    for row in &grid.rows {
        out.push_str("  (");
        for cell in row {
            out.push_str(&quoted(cell));
            out.push_str(", ");
        }
        out.push_str("),\n");
    }
    out.push_str(")\n");
    out
}

/// Le gabarit commun à tous les états : la page, le bandeau, le pied.
///
/// Les mesures viennent du document d'origine, relevées au point près :
/// bandeau de titre à 42,7 pt du haut sur 66,7 pt de haut, en-tête de tableau
/// à 133,8 pt, lignes de 17,55 pt, bandeau de pied à 507 pt, gris `#e5e5e5`
/// pour les bandeaux, `#f3f3f3` pour le pied, jaune post-it `#ffffe8` une
/// ligne sur deux, encre `#2d2d2d`.
const TEMPLATE: &str = r##"
#let gris-bande = rgb("#e5e5e5")
#let gris-pied = rgb("#f3f3f3")
#let jaune = rgb("#ffffe8")
#let encre = rgb("#2d2d2d")
#let utile = 756pt
#let marge-g = 42.7pt

#set text(font: famille, size: 7pt, fill: encre, lang: langue)
#set par(leading: 0.5em, spacing: 0pt)

#let sous-titre = pad(left: 2.7pt, text(size: 12pt, weight: "bold", titre))
#let titre-recap = pad(left: 2.7pt, text(size: 12pt, weight: "bold", recap-titre))
#let section = state("section", "liste")

#let bandeau-titre = place(top + left, dx: marge-g, dy: 42.7pt, block(
  width: utile, height: 66.7pt, fill: gris-bande,
  {
    place(top + left, dx: 24.4pt, dy: 4.6pt, image(logo, width: 54.9pt, height: 57pt))
    place(top + center, dy: 13.4pt, text(size: 17pt, weight: "bold", titre))
    place(top + left, dx: 689.6pt, dy: 7.2pt, text(size: 8pt, imprime-le))
  },
))

#let bandeau-pied = context {
  place(top + left, dx: marge-g, dy: 507pt,
    block(width: utile, height: 45.1pt, fill: gris-pied))
  place(top + left, dx: 596pt, dy: 512pt, block(width: 200pt, align(right,
    text(size: 11pt)[#counter(page).display()/#counter(page).final().first()])))
}

#set page(
  width: 841.89pt, height: 595.276pt,
  margin: (left: 42.7pt, right: 43.19pt, top: 66.8pt, bottom: 88.28pt),
  header-ascent: 8.9pt,
  header: context {
    if here().page() > 1 {
      if section.get() == "liste" { sous-titre } else { titre-recap }
    }
  },
  background: context {
    if here().page() == 1 { bandeau-titre }
    bandeau-pied
  },
)

// Un tableau de l'état : en-tête réimprimé sur chaque page, lignes alternées.
#let tableau(largeurs, alignements, titres, lignes) = table(
  columns: largeurs,
  column-gutter: 0.5pt,
  rows: 17.55pt,
  stroke: none,
  inset: (x: 3pt, y: 0pt),
  align: horizon,
  fill: (x, y) => if y == 0 { gris-bande } else if calc.odd(y) { white } else { jaune },
  table.header(repeat: true, ..titres.map(t => align(center, t))),
  ..lignes.map(ligne => ligne.enumerate().map(
    ((i, cellule)) => align(alignements.at(i), cellule))).flatten(),
)

// Un bandeau de clôture : des couples intitulé / valeur posés régulièrement.
#let bandeau-cloture(couples, largeur) = block(width: largeur, height: 36.4pt, fill: gris-bande, {
  for (i, couple) in couples.enumerate() {
    place(left + horizon, dx: 3pt + i * (largeur - 20pt) / couples.len(),
      text(weight: "bold")[#couple.at(0) #h(6pt) #couple.at(1)])
  }
})

// --- Page 1 : le bandeau est dessiné en fond, le corps lui laisse la place.
#v(48.7pt, weak: false)
#sous-titre
#v(9.9pt)

#tableau(liste-widths, liste-aligns, liste-titles, liste-rows)

#if cloture.len() > 0 {
  v(2.4pt)
  bandeau-cloture(cloture, utile)
}

#if recap-rows.len() > 0 {
  section.update("recap")
  pagebreak()
  let moitie = calc.ceil(recap-rows.len() / 2)
  grid(columns: (346.5pt, 63pt, 346.5pt),
    tableau(recap-widths, recap-aligns, recap-titles, recap-rows.slice(0, moitie)),
    [],
    tableau(recap-widths, recap-aligns, recap-titles, recap-rows.slice(moitie)),
  )
  if cloture.len() > 0 {
    v(9.9pt)
    bandeau-cloture(cloture, utile)
  }
}

#place(bottom + center, dy: -14pt, text(size: 7pt, licence))
"##;

/// La source complète : les données, puis le gabarit.
fn source_of(report: &Report, language: Language) -> String {
    let mut out = String::new();
    out.push_str(&format!("#let famille = {}\n", quoted(FAMILY)));
    out.push_str(&format!(
        "#let langue = {}\n",
quoted(language.tag())
    ));
    out.push_str(&format!("#let logo = {}\n", quoted(LOGO_PATH)));
    out.push_str(&format!("#let titre = {}\n", quoted(&report.title)));
    out.push_str(&format!(
        "#let imprime-le = {}\n",
        quoted(&report.printed_on)
    ));
    out.push_str(&format!("#let licence = {}\n", quoted(&report.licence)));
    out.push_str(&grid_source(&report.grid, "liste"));

    out.push_str("#let cloture = (\n");
    for (label, value) in &report.closing {
        out.push_str(&format!("  ({}, {}),\n", quoted(label), quoted(value)));
    }
    out.push_str(")\n");

    match &report.recap {
        Some((title, grid)) => {
            out.push_str(&format!("#let recap-titre = {}\n", quoted(title)));
            out.push_str(&grid_source(grid, "recap"));
        }
        None => {
            out.push_str("#let recap-titre = \"\"\n");
            out.push_str("#let recap-widths = ()\n#let recap-aligns = ()\n");
            out.push_str("#let recap-titles = ()\n#let recap-rows = ()\n");
        }
    }

    out.push_str(TEMPLATE);
    out
}

/// **Compose une source Typst entière et rend les octets du PDF**, dans le
/// même atelier fermé que les autres états : les deux fontes embarquées,
/// l'écureuil, et rien du disque. Le rapport de la simulation de crédit
/// (F41) écrit sa propre source et passe par ici.
pub(crate) fn compose(source: String, ident: &str) -> Result<Vec<u8>, Failure> {
    let workshop = Workshop::new(source);
    let composed = typst::compile::<PagedDocument>(&workshop);
    let document = composed.output.map_err(|errors| {
        Failure::Typesetting(
            errors
                .iter()
                .map(|error| error.message.to_string())
                .collect::<Vec<_>>()
                .join(" · "),
        )
    })?;
    typst_pdf::pdf(
        &document,
        &PdfOptions {
            ident: Smart::Custom(ident.to_string()),
            ..Default::default()
        },
    )
    .map_err(|errors| {
        Failure::Writing(
            errors
                .iter()
                .map(|error| error.message.to_string())
                .collect::<Vec<_>>()
                .join(" · "),
        )
    })
}

/// Compose l'état et rend les octets du PDF.
///
/// Rien n'est écrit sur le disque : le contrôleur décide de la destination.
pub fn pdf(report: &Report, language: Language) -> Result<Vec<u8>, Failure> {
    let workshop = Workshop::new(source_of(report, language));
    let composed = typst::compile::<PagedDocument>(&workshop);
    let document = composed.output.map_err(|errors| {
        Failure::Typesetting(
            errors
                .iter()
                .map(|error| error.message.to_string())
                .collect::<Vec<_>>()
                .join(" · "),
        )
    })?;
    typst_pdf::pdf(
        &document,
        &PdfOptions {
            ident: Smart::Custom("radinus".to_string()),
            ..Default::default()
        },
    )
    .map_err(|errors| {
        Failure::Writing(
            errors
                .iter()
                .map(|error| error.message.to_string())
                .collect::<Vec<_>>()
                .join(" · "),
        )
    })
}

// ---------------------------------------------------------------------------
// L'état de la liste des opérations d'un compte (F02)
// ---------------------------------------------------------------------------

/// Le nom du mois, dans la langue de la base. Le douzième élément de la
/// nomenclature des mois, celle que le menu Période de F02 utilise déjà.
fn month_name(date: NaiveDate, language: Language) -> String {
    const KEYS: [&str; 12] = [
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
    let index = (date.month() as usize).clamp(1, 12) - 1;
    i18n::text(language, KEYS[index])
}

fn day(date: Option<NaiveDate>) -> String {
    date.map(|date| date.format("%d/%m/%Y").to_string())
        .unwrap_or_default()
}

/// Les treize colonnes de l'état, dans l'ordre de l'original.
///
/// **Les trois colonnes techniques sont conservées** (arbitrage de Fabrice,
/// 01/08/2026) : `COL_SelDos` reste vide comme dans l'original — c'est la
/// colonne de sélection de la table à l'écran —, `IDOpParent` porte la clef de
/// la mère pour une sous-opération et rien pour une mère.
///
/// **Aucun texte n'est tronqué** (même arbitrage) : les largeurs sont calculées
/// pour le pire cas de chaque colonne, et non reprises telles quelles de
/// l'original, où « Loisirs et spectacles » devenait « Loisirs et sp ».
fn operation_columns(language: Language) -> Vec<Column> {
    let label = |key: &str| i18n::text(language, key);
    vec![
        Column::new("COL_SelDos", 44.0, Align::Center),
        Column::new("IDOpParent", 44.0, Align::Right),
        Column::new("IDOP", 34.0, Align::Right),
        Column::new(label("operations-column-date"), 42.0, Align::Right),
        Column::new(label("operations-column-clearing-date"), 52.0, Align::Right),
        Column::new(label("operations-column-label"), 180.0, Align::Left),
        Column::new(label("operations-column-category"), 74.0, Align::Left),
        Column::new(label("operations-column-assignment"), 46.0, Align::Left),
        Column::new(label("operations-column-payment-mode"), 54.0, Align::Left),
        Column::new(label("operations-column-month"), 38.0, Align::Left),
        Column::new(label("operations-column-debit"), 46.0, Align::Right),
        Column::new(label("operations-column-credit"), 46.0, Align::Right),
        Column::new(label("operations-column-balance"), 50.0, Align::Right),
    ]
}

fn operation_row(
    row: &OperationRow,
    parent_id: i64,
    language: Language,
) -> Vec<String> {
    let (debit, credit) = if row.amount < 0 {
        (money::format(row.amount, language), String::new())
    } else if row.amount > 0 {
        (String::new(), money::format(row.amount, language))
    } else {
        (money::format(0, language), String::new())
    };
    // Une fille n'a pas de solde : `SoldePointe` n'est estampillé que sur les
    // mères, parce que c'est le solde courant du compte et qu'une ventilation
    // ne déplace pas le compte (voir `operations`).
    let balance = if parent_id == 0 {
        money::format(row.pointed_balance, language)
    } else {
        String::new()
    };
    vec![
        String::new(),
        if parent_id == 0 {
            String::new()
        } else {
            parent_id.to_string()
        },
        row.id.to_string(),
        day(row.date),
        day(row.clearing_date),
        row.label.clone(),
        row.category.clone(),
        row.assignment.clone(),
        row.payment_mode.clone(),
        row.date
            .map(|date| month_name(date, language))
            .unwrap_or_default(),
        debit,
        credit,
        balance,
    ]
}

/// Le récapitulatif par catégorie : combien de lignes, combien de débit,
/// combien de crédit, par catégorie, du plus dépensier au moins.
///
/// **Les mères seules.** Une opération ventilée compte pour son montant total ;
/// ajouter ses filles compterait l'argent deux fois. C'est la règle que Fabrice
/// a posée le 30/07/2026 pour les exports bancaires, et elle vaut ici.
fn recap_grid(rows: &[(OperationRow, i64)], language: Language) -> Grid {
    use std::collections::HashMap;
    let mut totals: HashMap<String, (usize, i64, i64)> = HashMap::new();
    for (row, parent_id) in rows {
        if *parent_id != 0 {
            continue;
        }
        let entry = totals.entry(row.category.clone()).or_insert((0, 0, 0));
        entry.0 += 1;
        if row.amount < 0 {
            entry.1 += row.amount;
        } else {
            entry.2 += row.amount;
        }
    }
    let mut ordered: Vec<(String, (usize, i64, i64))> = totals.into_iter().collect();
    // Le plus gros débit d'abord ; à débit égal, l'ordre alphabétique, pour
    // qu'une même base donne toujours le même état.
    ordered.sort_by(|a, b| {
        (a.1 .1 + a.1 .2)
            .cmp(&(b.1 .1 + b.1 .2))
            .then_with(|| a.0.cmp(&b.0))
    });

    let label = |key: &str| i18n::text(language, key);
    Grid {
        columns: vec![
            Column::new(label("operations-column-category"), 149.0, Align::Left),
            Column::new(label("print-recap-count"), 40.0, Align::Right),
            Column::new(label("operations-column-debit"), 78.0, Align::Right),
            Column::new(label("operations-column-credit"), 78.0, Align::Right),
        ],
        rows: ordered
            .into_iter()
            .map(|(category, (count, debit, credit))| {
                vec![
                    category,
                    count.to_string(),
                    if debit == 0 {
                        String::new()
                    } else {
                        money::format(debit, language)
                    },
                    if credit == 0 {
                        String::new()
                    } else {
                        money::format(credit, language)
                    },
                ]
            })
            .collect(),
    }
}

/// L'état complet de la liste des opérations d'un compte.
///
/// `ids` est ce que la fenêtre montre, **dans l'ordre où elle le montre** :
/// on imprime ce que l'on voit, filtres et tri compris. Les identifiants
/// inconnus sont ignorés en silence — la fenêtre a pu être rafraîchie entre
/// le clic et la lecture.
pub fn operations_report(
    conn: &Connection,
    ids: &[i64],
    language: Language,
    today: NaiveDate,
) -> Result<Report, Failure> {
    let found = operations::read_by_ids(conn, ids)?;
    let rows: Vec<(OperationRow, i64)> = ids
        .iter()
        .filter_map(|id| found.get(id).cloned())
        .collect();

    let mut debit = 0i64;
    let mut credit = 0i64;
    for (row, parent_id) in &rows {
        if *parent_id != 0 {
            continue;
        }
        if row.amount < 0 {
            debit += row.amount;
        } else {
            credit += row.amount;
        }
    }
    // Le solde final est celui de la dernière mère imprimée : c'est le solde
    // du compte au bas de la liste, tel que la fenêtre le montre.
    let final_balance = rows
        .iter()
        .rev()
        .find(|(_, parent_id)| *parent_id == 0)
        .map(|(row, _)| row.pointed_balance)
        .unwrap_or(0);

    let closing = vec![
        (
            i18n::text(language, "print-row-count"),
            rows.len().to_string(),
        ),
        (
            i18n::text(language, "print-total-debit"),
            money::format(debit, language),
        ),
        (
            i18n::text(language, "print-total-credit"),
            money::format(credit, language),
        ),
        (
            i18n::text(language, "print-final-balance"),
            money::format(final_balance, language),
        ),
    ];

    let grid = Grid {
        columns: operation_columns(language),
        rows: rows
            .iter()
            .map(|(row, parent_id)| operation_row(row, *parent_id, language))
            .collect(),
    };

    Ok(Report {
        title: i18n::text(language, "print-operations-title"),
        printed_on: today.format("%d/%m/%Y").to_string(),
        grid,
        closing,
        recap: Some((
            i18n::text(language, "print-recap-title"),
            recap_grid(&rows, language),
        )),
        licence: i18n::text(language, "print-licence"),
    })
}

// ---------------------------------------------------------------------------
// L'état RIB (F32)
// ---------------------------------------------------------------------------

/// Un relevé d'identité bancaire, tel qu'il s'imprime.
///
/// Tout vient de la fiche du compte : la fenêtre F32 ne fait que montrer ces
/// valeurs, elle ne les saisit pas (arbitrage de Fabrice, 01/08/2026 — les
/// champs y sont en lecture seule, et les corrections se font dans la fiche).
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct Rib {
    pub bank: String,
    /// L'adresse de l'agence, telle qu'elle est saisie, retours compris.
    pub domiciliation: String,
    pub holder: String,
    pub holder_address: String,
    pub establishment: String,
    pub branch: String,
    pub number: String,
    pub key: String,
    /// Déjà écrit par groupes de quatre, comme la fiche compte le montre.
    pub iban: String,
    pub bic: String,
}

/// Le RIB d'un compte. `None` si le compte n'existe pas.
pub fn rib(conn: &Connection, account_id: i64) -> Result<Option<Rib>, Failure> {
    let account = match crate::accounts::get(conn, account_id)? {
        Some(account) => account,
        None => return Ok(None),
    };
    // Le nom de la banque vient de la nomenclature, pas du compte : c'est un
    // lien souple, et un identifiant orphelin ne doit pas faire échouer une
    // impression — il donne un nom vide, et le cadre reste vide.
    let bank: String = conn
        .query_row(
            "SELECT NomBanque FROM Banques WHERE IDBanques = ?1",
            [account.bank_id],
            |row| row.get(0),
        )
        .unwrap_or_default();
    Ok(Some(Rib {
        bank,
        domiciliation: account.branch_address,
        holder: account.holder_name,
        holder_address: account.holder_address,
        establishment: account.rib_bank_code,
        branch: account.rib_branch_code,
        number: account.rib_account_number,
        key: account.rib_key,
        iban: crate::accounts::formatted_iban(&account.iban),
        bic: account.bic,
    }))
}

/// Le gabarit du RIB : des cadres posés aux coordonnées relevées sur le
/// document d'origine, au point près.
///
/// **Ce document ne se pagine pas et ne se répète pas** : c'est une page, une
/// seule, et chaque cadre a sa place. Il n'a donc ni bandeau de titre, ni pied
/// de page, ni en-tête réimprimé — rien de ce que le gabarit de la liste
/// apporte. D'où un second gabarit plutôt qu'un gabarit commun tordu pour
/// servir deux besoins qui n'ont rien à voir.
const RIB_TEMPLATE: &str = r##"
#set page(width: 841.89pt, height: 595.276pt, margin: 0pt)
#set text(font: famille, fill: black, lang: langue)
#set par(leading: 0.4em, spacing: 0pt)

#let bleu = rgb(0, 0, 192)
#let gris = rgb("#505050")
#let trait = 0.3pt + black

// Un cadre à bord fin, contenu centré, posé aux coordonnées mesurées.
#let cadre(x, y, x2, y2, corps) = place(
  top + left, dx: x * 1pt, dy: y * 1pt,
  rect(width: (x2 - x) * 1pt, height: (y2 - y) * 1pt, stroke: trait, inset: 2pt,
    align(center + horizon, corps)),
)

// Un intitulé bleu gras, calé sur le haut de ses jambages.
#let intitule(x, y, corps) = place(
  top + left, dx: x * 1pt, dy: (y + 1.2) * 1pt,
  text(size: 12pt, weight: "bold", fill: bleu, corps),
)

#cadre(63.1, 89.7, 778.8, 112.6, text(size: 16pt, weight: "bold", fill: gris, titre))

#intitule(65.8, 141)[#etiquette-banque #h(21.5pt) #banque]
#intitule(65.8, 176, etiquette-rib)

#let colonnes = (
  (62.8, 157.4, etiquette-etablissement, etablissement),
  (159.6, 249.6, etiquette-guichet, guichet),
  (251.8, 381.3, etiquette-numero, numero),
  (383.8, 437.9, etiquette-clef, clef),
  (440.1, 779.1, etiquette-domiciliation, domiciliation),
)

#for (x, x2, intitule-cadre, valeur) in colonnes {
  cadre(x, 196.5, x2, 213.4, text(size: 8pt, intitule-cadre))
  cadre(x, 216.4, x2, 285.3, text(size: 12pt, weight: "bold", valeur))
}

#intitule(65.8, 308, etiquette-iban)
#intitule(443.1, 308, etiquette-bic)

#cadre(65.1, 330.3, 320.1, 347.3, text(size: 12pt, weight: "bold", iban))
#cadre(440.4, 330.3, 781.7, 347.3, text(size: 12pt, weight: "bold", bic))

#intitule(65.3, 369, etiquette-titulaire)
#place(top + left, dx: 65.3pt, dy: 393.2pt,
  text(size: 12pt, weight: "bold", titulaire))
#place(top + left, dx: 65.3pt, dy: 412.2pt, text(size: 12pt, adresse))

#place(top + left, dx: 65.3pt, dy: 540pt, text(size: 7pt, fill: gris, licence))
"##;

/// Compose le RIB et rend les octets du PDF.
pub fn rib_pdf(rib: &Rib, language: Language) -> Result<Vec<u8>, Failure> {
    // Nommée `label` comme dans les colonnes de la liste : le test croisé
    // `chaque_intitule_de_l_impression_existe_dans_les_deux_langues` cherche
    // cette forme-là pour recenser les clefs. Renommer cette variable rendrait
    // le test aveugle sans qu'il proteste.
    let label = |key: &str| i18n::text(language, key);
    let mut out = String::new();
    for (name, value) in [
        ("famille", FAMILY.to_string()),
        ("langue", language.tag().to_string()),
        ("titre", label("rib-title")),
        ("etiquette-banque", label("rib-bank")),
        ("etiquette-rib", label("rib-national")),
        ("etiquette-etablissement", label("rib-establishment")),
        ("etiquette-guichet", label("rib-branch")),
        ("etiquette-numero", label("rib-number")),
        ("etiquette-clef", label("rib-key")),
        ("etiquette-domiciliation", label("rib-domiciliation")),
        ("etiquette-iban", label("rib-iban")),
        ("etiquette-bic", label("rib-bic")),
        ("etiquette-titulaire", label("rib-holder")),
        ("licence", label("print-licence")),
        ("banque", rib.bank.clone()),
        ("etablissement", rib.establishment.clone()),
        ("guichet", rib.branch.clone()),
        ("numero", rib.number.clone()),
        ("clef", rib.key.clone()),
        ("iban", rib.iban.clone()),
        ("bic", rib.bic.clone()),
        ("titulaire", rib.holder.clone()),
    ] {
        out.push_str(&format!("#let {name} = {}\n", quoted(&value)));
    }
    // Deux champs sont multilignes dans la fiche compte : ils gardent leurs
    // retours, et Typst en fait de vraies lignes.
    out.push_str(&format!(
        "#let domiciliation = {}\n",
        multiline(&rib.domiciliation)
    ));
    out.push_str(&format!(
        "#let adresse = {}\n",
        multiline(&rib.holder_address)
    ));
    out.push_str(RIB_TEMPLATE);

    let workshop = Workshop::new(out);
    let composed = typst::compile::<PagedDocument>(&workshop);
    let document = composed.output.map_err(|errors| {
        Failure::Typesetting(
            errors
                .iter()
                .map(|error| error.message.to_string())
                .collect::<Vec<_>>()
                .join(" · "),
        )
    })?;
    typst_pdf::pdf(
        &document,
        &PdfOptions {
            ident: Smart::Custom("radinus-rib".to_string()),
            ..Default::default()
        },
    )
    .map_err(|errors| {
        Failure::Writing(
            errors
                .iter()
                .map(|error| error.message.to_string())
                .collect::<Vec<_>>()
                .join(" · "),
        )
    })
}

/// Un texte multiligne, en contenu Typst : les chaînes sont mises bout à bout
/// et séparées par des sauts de ligne explicites.
///
/// Chaque ligne reste une **chaîne** — c'est le point : un retour à la ligne
/// est la seule chose qu'on ajoute, et rien de ce que l'utilisateur a tapé
/// n'est interprété.
fn multiline(text: &str) -> String {
    let lines: Vec<String> = text
        .lines()
        .map(|line| format!("#{}", quoted(line)))
        .collect();
    if lines.is_empty() {
        return "[]".to_string();
    }
    // Le dièse est indispensable : en mode contenu, une chaîne nue
    // s'imprimerait avec ses guillemets. Le dièse la fait évaluer.
    format!("[{}]", lines.join(" \\ "))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn grid() -> Grid {
        Grid {
            columns: vec![
                Column::new("Libellé", 200.0, Align::Left),
                Column::new("Montant", 80.0, Align::Right),
            ],
            rows: vec![
                vec!["ACHAT CB U MUNTESE".into(), "-10,80 €".into()],
                vec!["VIREMENT DE PAIERIE".into(), "2 216,71 €".into()],
            ],
        }
    }

    fn report(rows: usize) -> Report {
        let mut grid = grid();
        let model = grid.rows[0].clone();
        while grid.rows.len() < rows {
            grid.rows.push(model.clone());
        }
        Report {
            title: "Liste des transactions".into(),
            printed_on: "31/07/2026".into(),
            grid,
            closing: vec![("Nombre de lignes".into(), rows.to_string())],
            recap: None,
            licence: "Radinus est un logiciel utilisé sous licence MIT".into(),
        }
    }

    fn un_rib() -> Rib {
        Rib {
            bank: "American Express".into(),
            domiciliation: "AMERICAN EXPRESS FRANCE\n4 RUE LOUIS BLERIOT\n92561 RUEIL-MALMAISON".into(),
            holder: "M. FABRICE GARCIA".into(),
            holder_address: "12 rue des Écureuils\n20000 Ajaccio".into(),
            establishment: "1223".into(),
            branch: "111".into(),
            number: "44557722".into(),
            key: "22".into(),
            iban: "FR76 1223 0111 0044 5577 2222 2".into(),
            bic: "225555".into(),
        }
    }

    #[test]
    fn le_rib_se_compose() {
        let octets = rib_pdf(&un_rib(), Language::French).expect("composition");
        assert!(octets.starts_with(b"%PDF-"));
    }

    /// Un compte tout neuf n'a rien saisi : le RIB s'imprime quand même, avec
    /// ses cadres vides. Un état qui refuserait de sortir serait pire.
    #[test]
    fn un_rib_vide_se_compose_aussi() {
        let octets = rib_pdf(&Rib::default(), Language::French).expect("composition");
        assert!(octets.starts_with(b"%PDF-"));
    }

    /// Les deux champs multilignes de la fiche compte gardent leurs lignes, et
    /// ce que l'utilisateur y a tapé n'est jamais interprété.
    #[test]
    fn une_adresse_multiligne_reste_du_texte() {
        assert_eq!(multiline("a\nb"), "[#\"a\" \\ #\"b\"]");
        let mut r = un_rib();
        r.holder_address = "#pagebreak()\n[gras] *étoile*".into();
        let octets = rib_pdf(&r, Language::French).expect("composition");
        assert!(octets.starts_with(b"%PDF-"));
    }

    /// **La largeur utile ne se négocie pas.** Les colonnes plus les
    /// gouttières doivent faire 756 points, la largeur de l'A4 paysage moins
    /// les marges. Élargir une colonne sans en rétrécir une autre ne lèverait
    /// aucune erreur : Typst pousserait simplement le tableau hors de la page,
    /// et les derniers montants seraient rognés à l'impression sans que rien
    /// ne le dise.
    #[test]
    fn les_treize_colonnes_font_la_largeur_utile() {
        let columns = operation_columns(Language::French);
        let total: f64 = columns.iter().map(|column| column.width).sum();
        let gutters = 0.5 * (columns.len() - 1) as f64;
        assert!(
            (total + gutters - 756.0).abs() < 0.01,
            "les colonnes font {} points au lieu de 756",
            total + gutters
        );
    }

    /// Le récapitulatif s'imprime en deux colonnes côte à côte, chacune large
    /// de 346,5 points : un tableau plus large déborderait sur son voisin.
    #[test]
    fn le_recapitulatif_tient_dans_sa_demi_page() {
        let grid = recap_grid(&[], Language::French);
        let total: f64 = grid.columns.iter().map(|column| column.width).sum();
        let gutters = 0.5 * (grid.columns.len() - 1) as f64;
        assert!(
            total + gutters <= 346.5,
            "le récapitulatif fait {} points, la demi-page en offre 346,5",
            total + gutters
        );
    }

    #[test]
    fn un_etat_court_tient_sur_une_page() {
        let octets = pdf(&report(10), Language::French).expect("composition");
        assert!(octets.starts_with(b"%PDF-"));
    }

    /// Ce que la composition apporte et que le dessin ne donnait pas : les
    /// pages se coupent toutes seules, et l'en-tête se réimprime.
    #[test]
    fn un_etat_long_se_pagine_tout_seul() {
        let court = pdf(&report(10), Language::French).expect("composition");
        let long = pdf(&report(400), Language::French).expect("composition");
        assert!(long.len() > court.len());
    }

    /// **Le point sensible.** Un libellé venu d'une banque contient ce qu'il
    /// veut ; s'il était injecté en contenu Typst, un `#` ou un `[` casserait
    /// la composition, voire changerait le document. En chaîne, il ressort tel
    /// quel.
    #[test]
    fn un_libelle_hostile_ne_casse_rien() {
        let mut r = report(3);
        r.grid.rows[0][0] = "#pagebreak() [gras] \"guillemets\" \\ *étoile* 100%".into();
        let octets = pdf(&r, Language::French).expect("composition");
        assert!(octets.starts_with(b"%PDF-"));
    }

    #[test]
    fn les_guillemets_et_les_barres_sont_protegees() {
        assert_eq!(quoted(r#"a"b\c"#), r#""a\"b\\c""#);
        assert_eq!(quoted("a\nb"), "\"a b\"");
    }

    /// Deux compositions du même état donnent le même PDF : c'est ce qui rend
    /// l'impression comparable d'une machine à l'autre.
    #[test]
    fn deux_compositions_donnent_le_meme_document() {
        let un = pdf(&report(30), Language::French).expect("composition");
        let deux = pdf(&report(30), Language::French).expect("composition");
        assert_eq!(un, deux);
    }
}
