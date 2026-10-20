//! **L'exportation par compte, en QIF ou en OFX** (Fabrice, 19/10/2026,
//! P-74) — pour qui quitte Radinus vers un autre logiciel de comptes
//! (HomeBank, Grisbi, GnuCash, Money, Quicken…). Ces logiciels ne lisent pas
//! un classeur de tables ; ils importent un relevé par compte.
//!
//! Un fichier par compte, tiré du même extrait que les autres formats
//! ([`crate::database_export::read`]) : la base n'est lue qu'une fois, en
//! lecture seule.
//!
//! # Le QIF : ce qu'il sait porter
//!
//! La date, le montant, le pointage (`C`), le numéro de chèque (`N`), le
//! tiers (`P`), le libellé et le commentaire (`M`), la catégorie (`L`) et,
//! derrière une barre oblique, le projet comme « classe » QIF. **Les
//! ventilations** partent avec leur détail (`S`, `E`, `$`) plutôt que le seul
//! total de la mère. En tête, **la liste complète des catégories** et des
//! projets — même ceux qu'aucune opération n'utilise — et **le solde
//! initial** du compte, bâti sur ses reports : sans lui, l'autre logiciel
//! démarrerait à zéro et tous ses soldes seraient faux.
//!
//! Ce que le QIF ne sait pas porter — le moyen de paiement, l'affectation, le
//! statut, la vérification — reste dans les exports par tables ; l'assistant
//! le dit.
//!
//! # L'OFX
//!
//! Un relevé par compte, écrit par l'exportateur OFX que Radinus a déjà
//! ([`crate::exports::ofx`]), inchangé : les opérations, leur FITID quand la
//! banque en a donné un — on n'en invente pas —, et les soldes du compte.
//!
//! # Trois règles communes
//!
//! * **Les opérations prévues n'y sont pas.** Ce sont des prévisions, pas des
//!   mouvements : un autre logiciel les prendrait pour réelles et ses soldes
//!   seraient faux. Elles restent dans les exports par tables, et la phrase de
//!   fin dit combien.
//! * **Les virements entre comptes sont de simples opérations** avec leur
//!   catégorie : écrits comme virements des deux côtés, certains logiciels les
//!   compteraient deux fois.
//! * **Rien ne change en silence** : une opération sans date (le QIF et l'OFX
//!   en exigent une) n'y entre pas, et une valeur qu'il a fallu ajuster — un
//!   retour à la ligne, un `:` dans un nom de catégorie, qui y sépare les
//!   sous-catégories — est comptée.

use crate::database_export::{money_text, Extract, Table, Value};
use crate::domain::NaiveDate;
use crate::qif_import::DateOrder;
use std::collections::HashMap;
use std::path::{Path, PathBuf};

/// Le statut « Prévu » : laissé hors des relevés.
const PLANNED: i64 = 3;
/// Le statut « Pointé » : `CX` en QIF.
const CLEARED: i64 = 1;

/// Ce que l'export par compte a laissé de côté ou ajusté, pour le dire.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct Report {
    /// Combien de fichiers — un par compte.
    pub accounts: usize,
    /// Combien d'opérations écrites, ventilations comptées une fois (la mère).
    pub operations: usize,
    /// Les opérations prévues, laissées de côté.
    pub planned: usize,
    /// Les opérations sans date, laissées de côté.
    pub undated: usize,
    /// Les valeurs qu'il a fallu ajuster pour le format.
    pub adjusted: usize,
}

// --- Lire l'extrait -------------------------------------------------------------

/// Une table de l'extrait, et l'accès à ses colonnes par leur nom.
struct Lookup<'a> {
    table: &'a Table,
    index: HashMap<&'a str, usize>,
}

impl<'a> Lookup<'a> {
    fn of(extract: &'a Extract, name: &str) -> Option<Self> {
        let table = extract.tables.iter().find(|table| table.name == name)?;
        let index = table.columns.iter().enumerate().map(|(rank, (column, _))| (column.as_str(), rank)).collect();
        Some(Self { table, index })
    }

    fn value<'r>(&self, row: &'r [Value], column: &str) -> &'r Value {
        static NULL: Value = Value::Null;
        self.index.get(column).and_then(|&rank| row.get(rank)).unwrap_or(&NULL)
    }

    fn integer(&self, row: &[Value], column: &str) -> i64 {
        match self.value(row, column) {
            Value::Integer(number) => *number,
            _ => 0,
        }
    }

    fn money(&self, row: &[Value], column: &str) -> i64 {
        match self.value(row, column) {
            Value::Money(micro) => *micro,
            _ => 0,
        }
    }

    fn text(&self, row: &[Value], column: &str) -> String {
        match self.value(row, column) {
            Value::Text(text) => text.clone(),
            Value::Null => String::new(),
            other => crate::database_export::plain(other),
        }
    }

    fn date(&self, row: &[Value], column: &str) -> Option<NaiveDate> {
        match self.value(row, column) {
            Value::Date(date) => Some(*date),
            _ => None,
        }
    }

    /// `id → libellé` d'une nomenclature.
    fn labels(&self, id: &str, label: &str) -> HashMap<i64, String> {
        self.table.rows.iter().map(|row| (self.integer(row, id), self.text(row, label))).collect()
    }
}

/// Une opération, telle que les relevés l'écrivent.
#[derive(Debug, Clone)]
struct Operation {
    id: i64,
    date: Option<NaiveDate>,
    amount: i64,
    status: i64,
    label: String,
    payee: String,
    category: String,
    project: String,
    /// Le numéro d'un vrai chèque, ou vide.
    number: String,
    /// La référence paiement : en mémo, jamais en numéro de chèque
    /// (Fabrice, 19/10/2026).
    reference: String,
    fitid: String,
    comment: String,
    /// Les ventilations : catégorie, projet, libellé, montant.
    splits: Vec<(String, String, String, i64)>,
}

/// Ce qu'il faut savoir de chaque compte.
#[derive(Debug, Clone)]
struct Account {
    id: i64,
    name: String,
    opening: i64,
    opened: Option<NaiveDate>,
    ofx: crate::exports::Account,
}

/// Tout l'extrait, rangé par compte.
struct Book {
    accounts: Vec<Account>,
    /// Les opérations mères de chaque compte, prévues comprises.
    operations: HashMap<i64, Vec<Operation>>,
    categories: Vec<String>,
    projects: Vec<String>,
}

fn book_of(extract: &Extract) -> Option<Book> {
    let accounts = Lookup::of(extract, "Compte")?;
    let operations = Lookup::of(extract, "Operation")?;
    let categories = Lookup::of(extract, "Categorie")?;
    let category_types = Lookup::of(extract, "TypeCategorie")?.labels("IDTypeCategorie", "Libelle");
    let payees = Lookup::of(extract, "Tiers")?.labels("IDTiers", "Libelle");
    let projects = Lookup::of(extract, "Projets")?.labels("IDProjets", "Libelle");
    let cheques = Lookup::of(extract, "Cheque")?;
    let cheque_numbers: HashMap<i64, i64> =
        cheques.table.rows.iter().map(|row| (cheques.integer(row, "IDCheque"), cheques.integer(row, "NumChq"))).collect();
    let comments = Lookup::of(extract, "Commentaire")?;
    let comment_of: HashMap<i64, String> = comments
        .table
        .rows
        .iter()
        .map(|row| (comments.integer(row, "IDOperation"), comments.text(row, "CommentaireTxt")))
        .collect();

    // « Type:Catégorie » quand la catégorie a un type, comme un logiciel de
    // comptes range ses sous-catégories.
    let category_name: HashMap<i64, String> = categories
        .table
        .rows
        .iter()
        .map(|row| {
            let label = categories.text(row, "Libelle");
            let name = match category_types.get(&categories.integer(row, "IDTypeCategorie")) {
                Some(kind) if !kind.trim().is_empty() => format!("{}:{}", kind.trim(), label.trim()),
                _ => label.trim().to_string(),
            };
            (categories.integer(row, "IDCategorie"), name)
        })
        .collect();

    let mut by_account: HashMap<i64, Vec<Operation>> = HashMap::new();
    let mut daughters: HashMap<i64, Vec<(String, String, String, i64)>> = HashMap::new();
    let name_of = |map: &HashMap<i64, String>, id: i64| map.get(&id).cloned().unwrap_or_default();
    for row in &operations.table.rows {
        let parent = operations.integer(row, "IDOperationParent");
        let category = name_of(&category_name, operations.integer(row, "IDCategorie"));
        let project = name_of(&projects, operations.integer(row, "IDProjets"));
        let amount = operations.money(row, "Montant");
        if parent != 0 {
            daughters.entry(parent).or_default().push((
                category,
                project,
                operations.text(row, "Libelle"),
                amount,
            ));
            continue;
        }
        let cheque = operations.integer(row, "IDCheque");
        let number = match cheque_numbers.get(&cheque) {
            Some(number) if cheque != 0 => number.to_string(),
            _ => String::new(),
        };
        let id = operations.integer(row, "IDOperation");
        by_account.entry(operations.integer(row, "IDCompte")).or_default().push(Operation {
            id,
            date: operations.date(row, "Date"),
            amount,
            status: operations.integer(row, "IDStatutOperation"),
            label: operations.text(row, "Libelle"),
            payee: name_of(&payees, operations.integer(row, "IDTiers")),
            category,
            project,
            number,
            reference: operations.text(row, "ReferencePaiement").trim().to_string(),
            fitid: operations.text(row, "FitID"),
            comment: comment_of.get(&id).cloned().unwrap_or_default(),
            splits: Vec::new(),
        });
    }
    for list in by_account.values_mut() {
        for operation in list.iter_mut() {
            operation.splits = daughters.remove(&operation.id).unwrap_or_default();
        }
        list.sort_by_key(|operation| (operation.date, operation.id));
    }

    let filled = |value: String, fallback: &str| {
        if value.trim().is_empty() {
            fallback.to_string()
        } else {
            value.trim().to_string()
        }
    };
    let accounts = accounts
        .table
        .rows
        .iter()
        .map(|row| Account {
            id: accounts.integer(row, "IDCompte"),
            name: accounts.text(row, "Libelle").trim().to_string(),
            // Les reports pointé et engagé : le solde de départ, hors
            // prévisions, comme les opérations qui suivent.
            opening: accounts.money(row, "ReportPointe") + accounts.money(row, "ReportEngage"),
            opened: accounts.date(row, "DateOuverture"),
            ofx: crate::exports::Account {
                bank: filled(accounts.text(row, "COBCodeBanque"), "00000"),
                branch: filled(accounts.text(row, "COBCodeGuichet"), "00000"),
                number: filled(accounts.text(row, "COBNumCompte"), "00000000000"),
                currency: filled(accounts.text(row, "Devise"), "EUR"),
                balance_bank: accounts.money(row, "SoldeBanque"),
                balance_real: accounts.money(row, "SoldeReel"),
            },
        })
        .collect();

    let mut all_categories: Vec<String> = category_name.into_values().filter(|name| !name.trim().is_empty()).collect();
    all_categories.sort();
    all_categories.dedup();
    let mut all_projects: Vec<String> = projects.into_values().filter(|name| !name.trim().is_empty()).collect();
    all_projects.sort();
    all_projects.dedup();
    Some(Book { accounts, operations: by_account, categories: all_categories, projects: all_projects })
}

// --- Les noms de fichiers ---------------------------------------------------------

/// Un nom de fichier qu'aucun système ne refuse : sans `\ / : * ? " < > |`,
/// sans point ni espace en fin (Windows les ôte), jamais vide.
pub fn file_name(text: &str, fallback: &str) -> String {
    let cleaned: String = text
        .chars()
        .map(|c| if "\\/:*?\"<>|".contains(c) || c.is_control() { ' ' } else { c })
        .collect();
    let cleaned = cleaned.split_whitespace().collect::<Vec<_>>().join(" ");
    let cleaned = cleaned.trim_end_matches(['.', ' ']).to_string();
    if cleaned.is_empty() {
        fallback.to_string()
    } else {
        cleaned
    }
}

/// Le nom de fichier de chaque compte : son libellé, numéroté si deux comptes
/// s'appellent pareil — sans quoi l'un écraserait l'autre.
fn account_names(accounts: &[Account]) -> Vec<String> {
    let base: Vec<String> =
        accounts.iter().map(|account| file_name(&account.name, &format!("Compte {}", account.id))).collect();
    base.iter()
        .enumerate()
        .map(|(index, name)| {
            let same = base.iter().filter(|other| other.to_lowercase() == name.to_lowercase()).count();
            if same > 1 {
                let rank = base[..=index].iter().filter(|other| other.to_lowercase() == name.to_lowercase()).count();
                format!("{name} ({rank})")
            } else {
                name.clone()
            }
        })
        .collect()
}

// --- Le QIF -------------------------------------------------------------------------

/// Une valeur sur une seule ligne : un retour à la ligne y deviendrait un
/// nouveau champ.
fn one_line(text: &str, adjusted: &mut usize) -> String {
    let flat = text.replace("\r\n", " ").replace(['\r', '\n'], " ");
    if flat != text {
        *adjusted += 1;
    }
    flat.trim().to_string()
}

/// Un nom de catégorie ou de projet : en QIF, `:` sépare une sous-catégorie,
/// `/` annonce la classe, et des crochets désigneraient un compte. Ils
/// deviennent des tirets.
fn qif_name(text: &str, adjusted: &mut usize) -> String {
    let line = one_line(text, adjusted);
    let safe: String = line.chars().map(|c| if matches!(c, '/' | '[' | ']') { '-' } else { c }).collect();
    if safe != line {
        *adjusted += 1;
    }
    safe
}

/// Une catégorie suivie de son projet, en `Catégorie/Classe`. Le `:` du
/// « Type:Catégorie » est voulu ; celui d'un libellé ne l'est pas.
fn category_field(category: &str, project: &str, adjusted: &mut usize) -> String {
    let category = match category.split_once(':') {
        Some((kind, name)) => format!("{}:{}", qif_name(kind, adjusted), qif_name(&name.replace(':', "-"), adjusted)),
        None => qif_name(category, adjusted),
    };
    let project = qif_name(&project.replace(':', "-"), adjusted);
    match (category.is_empty(), project.is_empty()) {
        (_, true) => category,
        (true, false) => format!("/{project}"),
        (false, false) => format!("{category}/{project}"),
    }
}

fn qif_date(date: NaiveDate, order: DateOrder) -> String {
    match order {
        DateOrder::DayMonth => date.format("%d/%m/%Y").to_string(),
        DateOrder::MonthDay => date.format("%m/%d/%Y").to_string(),
    }
}

/// **Le QIF d'un compte.**
fn qif_of(book: &Book, account: &Account, order: DateOrder, today: NaiveDate, report: &mut Report) -> String {
    let mut adjusted = 0;
    let mut written = String::new();
    // La liste des catégories et celle des projets, en entier.
    if !book.categories.is_empty() {
        written.push_str("!Type:Cat\n");
        for category in &book.categories {
            written.push_str(&format!("N{}\n^\n", category_field(category, "", &mut adjusted)));
        }
    }
    if !book.projects.is_empty() {
        written.push_str("!Type:Class\n");
        for project in &book.projects {
            written.push_str(&format!("N{}\n^\n", qif_name(&project.replace(':', "-"), &mut adjusted)));
        }
    }
    let name = qif_name(&account.name, &mut adjusted);
    written.push_str(&format!("!Account\nN{name}\nTBank\n^\n!Type:Bank\n"));

    let operations = book.operations.get(&account.id).map(Vec::as_slice).unwrap_or_default();
    let kept: Vec<&Operation> = operations
        .iter()
        .filter(|operation| {
            if operation.status == PLANNED {
                report.planned += 1;
                return false;
            }
            if operation.date.is_none() {
                report.undated += 1;
                return false;
            }
            true
        })
        .collect();

    // Le solde initial : le compte lui-même entre crochets, comme Quicken et
    // Money l'écrivent — l'import QIF de Radinus le reconnaît ainsi.
    let first = kept.iter().filter_map(|operation| operation.date).min();
    let opening_date = match (account.opened, first) {
        (Some(opened), Some(first)) => opened.min(first),
        (Some(opened), None) => opened,
        (None, Some(first)) => first,
        (None, None) => today,
    };
    written.push_str(&format!(
        "D{}\nT{}\nCX\nPOpening Balance\nL[{name}]\n^\n",
        qif_date(opening_date, order),
        money_text(account.opening)
    ));

    for operation in kept {
        let Some(date) = operation.date else { continue };
        report.operations += 1;
        written.push_str(&format!("D{}\nT{}\n", qif_date(date, order), money_text(operation.amount)));
        if operation.status == CLEARED {
            written.push_str("CX\n");
        }
        let number = one_line(&operation.number, &mut adjusted);
        if !number.is_empty() {
            written.push_str(&format!("N{number}\n"));
        }
        // Le tiers s'il y en a un, sinon le libellé ; le libellé et le
        // commentaire en mémo.
        let payee = one_line(&operation.payee, &mut adjusted);
        let label = one_line(&operation.label, &mut adjusted);
        let comment = one_line(&operation.comment, &mut adjusted);
        let reference = one_line(&operation.reference, &mut adjusted);
        let (first_line, memo) = if payee.is_empty() { (label, String::new()) } else { (payee, label) };
        // La référence paiement suit le libellé en mémo, avant le commentaire.
        let memo = match (memo.is_empty(), reference.is_empty()) {
            (_, true) => memo,
            (true, false) => reference,
            (false, false) => format!("{memo} - {reference}"),
        };
        if !first_line.is_empty() {
            written.push_str(&format!("P{first_line}\n"));
        }
        let memo = match (memo.is_empty(), comment.is_empty()) {
            (_, true) => memo,
            (true, false) => comment,
            (false, false) => format!("{memo} — {comment}"),
        };
        if !memo.is_empty() {
            written.push_str(&format!("M{memo}\n"));
        }
        let category = category_field(&operation.category, &operation.project, &mut adjusted);
        if !category.is_empty() {
            written.push_str(&format!("L{category}\n"));
        }
        // Les ventilations, et ce qui manquerait pour faire le total : un
        // logiciel refuse une opération dont les parts ne font pas le tout.
        if !operation.splits.is_empty() {
            let mut sum = 0;
            for (category, project, label, amount) in &operation.splits {
                written.push_str(&format!("S{}\n", category_field(category, project, &mut adjusted)));
                let label = one_line(label, &mut adjusted);
                if !label.is_empty() {
                    written.push_str(&format!("E{label}\n"));
                }
                written.push_str(&format!("${}\n", money_text(*amount)));
                sum += amount;
            }
            if sum != operation.amount {
                written.push_str(&format!("S\n${}\n", money_text(operation.amount - sum)));
                adjusted += 1;
            }
        }
        written.push_str("^\n");
    }
    report.adjusted += adjusted;
    written
}

/// **Un fichier QIF par compte**, dans `folder`, nommé d'après le compte.
pub fn write_qif_files(
    extract: &Extract,
    folder: &Path,
    order: DateOrder,
    today: NaiveDate,
) -> std::io::Result<(Vec<PathBuf>, Report)> {
    let book = book_of(extract).ok_or_else(|| std::io::Error::other("extrait incomplet"))?;
    std::fs::create_dir_all(folder)?;
    let mut report = Report::default();
    let mut written = Vec::new();
    for (account, name) in book.accounts.iter().zip(account_names(&book.accounts)) {
        let text = qif_of(&book, account, order, today, &mut report);
        let path = folder.join(format!("{name}.qif"));
        crate::database_export::write_bytes(&path, text.as_bytes())?;
        written.push(path);
        report.accounts += 1;
    }
    Ok((written, report))
}

// --- L'OFX --------------------------------------------------------------------------

/// **Un fichier OFX par compte**, écrit par l'exportateur OFX de Radinus.
pub fn write_ofx_files(extract: &Extract, folder: &Path, today: NaiveDate) -> std::io::Result<(Vec<PathBuf>, Report)> {
    let book = book_of(extract).ok_or_else(|| std::io::Error::other("extrait incomplet"))?;
    std::fs::create_dir_all(folder)?;
    let mut report = Report::default();
    let mut written = Vec::new();
    for (account, name) in book.accounts.iter().zip(account_names(&book.accounts)) {
        let mut adjusted = 0;
        let lines: Vec<crate::exports::Line> = book
            .operations
            .get(&account.id)
            .map(Vec::as_slice)
            .unwrap_or_default()
            .iter()
            .filter(|operation| {
                if operation.status == PLANNED {
                    report.planned += 1;
                    return false;
                }
                if operation.date.is_none() {
                    report.undated += 1;
                    return false;
                }
                true
            })
            .map(|operation| crate::exports::Line {
                date: operation.date,
                label: one_line(&operation.label, &mut adjusted),
                amount: operation.amount,
                fitid: operation.fitid.trim().to_string(),
                payee: operation.payee.clone(),
                category: operation.category.clone(),
                reference: one_line(&operation.reference, &mut adjusted),
                check_number: operation.number.clone(),
            })
            .collect();
        report.operations += lines.len();
        report.adjusted += adjusted;
        let text = crate::exports::ofx(&account.ofx, &lines, today);
        let path = folder.join(format!("{name}.ofx"));
        crate::database_export::write_bytes(&path, text.as_bytes())?;
        written.push(path);
        report.accounts += 1;
    }
    Ok((written, report))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database_export::{open_read_only, read, Info};
    use std::sync::atomic::{AtomicU32, Ordering};

    static COUNTER: AtomicU32 = AtomicU32::new(0);

    fn scratch(label: &str) -> PathBuf {
        let n = COUNTER.fetch_add(1, Ordering::SeqCst);
        let dir = std::env::temp_dir().join(format!("radinus_comptes_{label}_{}_{n}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        dir
    }

    fn day(year: i32, month: u32, day: u32) -> NaiveDate {
        NaiveDate::from_ymd_opt(year, month, day).unwrap()
    }

    fn today() -> NaiveDate {
        day(2026, 10, 19)
    }

    /// Deux comptes, des catégories, un tiers, un projet, un chèque, une
    /// ventilation, une opération prévue et une sans date — puis les soldes
    /// recalculés par Radinus lui-même.
    fn sample(label: &str) -> (PathBuf, Extract) {
        let dir = scratch(label);
        let path = dir.join("radinus.sqlite");
        let conn = crate::database::create_new_database(&path).unwrap();
        conn.execute_batch(
            "INSERT INTO Compte (IDCompte, ReportPointe, ReportEngage, ReportPrevu, Libelle,
                IDTypeCompte, IDBanques, SoldeBanque, SoldeReel, SoldeFinal, NomTitulaire,
                AdresseTitulaire, COBCodeBanque, COBCodeGuichet, COBNumCompte, COBClefRIB,
                COBIBAN, DateOuverture, DateCloture, AdresseAgenceBank, COBBIC,
                NumProchCheque, CompteCloture, Devise)
             VALUES (1, 1000000000, 50000000, 7000000, 'CCP: courant', 1, 21, 0, 0, 0, '', '', '20041',
                     '01016', '1234567A020', '', '', '2026-01-01', '', '', '', 0, 0, 'EUR'),
                    (2, 0, 0, 0, 'Livret A', 2, 21, 0, 0, 0, '', '', '', '', '', '', '', '', '', '', '', 0, 0, 'EUR');
             INSERT INTO TypeCategorie (IDTypeCategorie, Libelle) VALUES (1, 'Maison');
             UPDATE Categorie SET IDTypeCategorie = 1 WHERE IDCategorie = 3;
             INSERT INTO Projets (IDProjets, Libelle) VALUES (1, 'Vacances 2026'), (2, 'Inutilisé');
             INSERT INTO Chequier (IDChequier, DateRecep, NumPremierChq, NumDernChq, QteChq, IDReferenceChq,
                FormatNumChq, Commentaires, IDCompte) VALUES (1, '2026-01-01', 9506001, 9506025, 25, '', 7, '', 1);
             INSERT INTO Cheque (IDCheque, NumChq, IDChequier, DateEmission, Beneficiaire, Montant,
                Commentaires, LieuEmission, IDStatutCheque) VALUES (1, 9506023, 1, '2026-02-01', 'Plombier', -185000000, '', '', 1);
             INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDModeOperation, IDCategorie,
                IDAffectation, IDCompte, DatePointage, FitID, ReferencePaiement, NumRelevBanque,
                IDStatutOperation, IDOperationParent, SoldePointe, EstParent, GUIDCalOpPeriode,
                IDCheque, IDTiers, IDProjets, EstComplement, IDVerification)
             VALUES
                (1, 'CB SUPERMARCHE', '2026-02-03', -57620000, 1, 1, 0, 1, '2026-02-04', 'P_A', '', '', 1, 0, 0, 0, '', 0, 1, 1, 0, 2),
                (2, 'Travaux', '2026-02-05', -185000000, 2, 3, 0, 1, '', '', '', '', 2, 0, 0, 1, '', 1, 0, 0, 0, 2),
                (3, 'Peinture', '2026-02-05', -120000000, 2, 3, 0, 1, '', '', '', '', 2, 2, 0, 0, '', 0, 0, 0, 0, 2),
                (4, 'Complément', '2026-02-05', -65000000, 2, 3, 0, 1, '', '', '', '', 2, 2, 0, 0, '', 0, 0, 0, 1, 2),
                (5, 'Loyer prévu', '2026-03-01', -700000000, 4, 0, 0, 1, '', '', '', '', 3, 0, 0, 0, '', 0, 0, 0, 0, 2),
                (6, 'Sans date', NULL, 10000000, 0, 0, 0, 1, '', '', '', '', 1, 0, 0, 0, '', 0, 0, 0, 0, 2),
                (7, 'VIREMENT RECU', '2026-02-10', 1500000000, 8, 0, 0, 2, '', '', '', '', 1, 0, 0, 0, '', 0, 0, 0, 0, 2);
             INSERT INTO Commentaire (IDCommentaire, CommentaireTxt, IDOperation) VALUES (1, 'Courses
de la semaine', 1);",
        )
        .unwrap();
        crate::balances::update_all(&conn, 1).unwrap();
        crate::balances::update_all(&conn, 2).unwrap();
        drop(conn);
        let conn = open_read_only(&path, None).unwrap();
        let info = Info { version: "3.0.0".into(), base: "Test".into(), date: today(), currency: "EUR".into() };
        (dir, read(&conn, &info).unwrap())
    }

    fn import_options(order: DateOrder) -> crate::qif_import::Options {
        crate::qif_import::Options { order: Some(order), label: crate::qif_import::LabelChoice::Both, today: today() }
    }

    #[test]
    fn un_qif_par_compte_avec_tout_ce_que_le_format_porte() {
        let (dir, extract) = sample("qif");
        let folder = dir.join("export");
        let (files, report) = write_qif_files(&extract, &folder, DateOrder::DayMonth, today()).unwrap();
        let names: Vec<String> = files.iter().map(|file| file.file_name().unwrap().to_string_lossy().to_string()).collect();
        assert_eq!(names, vec!["CCP courant.qif", "Livret A.qif"], "le « : » ôté du nom de fichier");
        assert_eq!(report, Report { accounts: 2, operations: 3, planned: 1, undated: 1, adjusted: 1 }, "le commentaire sur deux lignes");

        let text = std::fs::read_to_string(&files[0]).unwrap();
        // La liste complète des catégories et des projets, même inutilisés.
        assert!(text.starts_with("!Type:Cat\n"));
        assert!(text.contains("NMaison:Bricolage\n^\n"), "la catégorie et son type");
        assert!(text.contains("!Type:Class\nNInutilisé\n^\nNVacances 2026\n^\n"));
        assert!(text.contains("!Account\nNCCP: courant\nTBank\n^\n!Type:Bank\n"));
        // Le solde initial : reports pointé et engagé, hors prévu.
        assert!(text.contains("D01/01/2026\nT1050.00\nCX\nPOpening Balance\nL[CCP: courant]\n^\n"));
        // Le tiers en premier, le libellé et le commentaire en mémo, la
        // catégorie et le projet.
        assert!(text.contains(
            "D03/02/2026\nT-57.62\nCX\nPAldi\nMCB SUPERMARCHE — Courses de la semaine\nLAlimentation/Vacances 2026\n^\n"
        ), "{text}");
        // Le chèque, et la ventilation en détail.
        assert!(text.contains(
            "D05/02/2026\nT-185.00\nN9506023\nPTravaux\nLMaison:Bricolage\nSMaison:Bricolage\nEPeinture\n$-120.00\nSMaison:Bricolage\nEComplément\n$-65.00\n^\n"
        ), "{text}");
        assert!(!text.contains("Loyer prévu") && !text.contains("Sans date"));
    }

    /// **La référence paiement va en mémo, jamais dans `N`** (Fabrice,
    /// 19/10/2026) — entre le libellé et le commentaire.
    #[test]
    fn la_reference_paiement_va_en_memo() {
        let (dir, mut extract) = sample("qif-reference");
        let operations = extract.tables.iter_mut().find(|table| table.name == "Operation").unwrap();
        let column = operations.columns.iter().position(|(name, _)| name == "ReferencePaiement").unwrap();
        operations.rows[0][column] = Value::Text("URSSAF REF/42".into());
        let folder = dir.join("export");
        let (files, _) = write_qif_files(&extract, &folder, DateOrder::DayMonth, today()).unwrap();
        let text = std::fs::read_to_string(&files[0]).unwrap();
        assert!(
            text.contains("PAldi\nMCB SUPERMARCHE - URSSAF REF/42 — Courses de la semaine\n"),
            "{text}"
        );
        assert!(!text.contains("NURSSAF"), "{text}");
        let (files, _) = write_ofx_files(&extract, &dir.join("ofx"), today()).unwrap();
        let ofx = std::fs::read_to_string(&files[0]).unwrap();
        assert!(ofx.contains("<MEMO>URSSAF REF/42"), "{ofx}");
        assert!(ofx.contains("<CHECKNUM>9506023"), "{ofx}");
    }

    /// **L'aller-retour par l'import QIF de Radinus** : le fichier se relit,
    /// le solde initial est reconnu comme tel, et **le solde d'arrivée est
    /// celui de Radinus** — reports plus opérations, hors prévisions.
    #[test]
    fn le_qif_se_relit_et_tombe_sur_le_solde_de_radinus() {
        let (dir, extract) = sample("qif-retour");
        for order in [DateOrder::DayMonth, DateOrder::MonthDay] {
            let folder = dir.join(format!("export-{}", order.key()));
            let (files, _) = write_qif_files(&extract, &folder, order, today()).unwrap();
            let text = std::fs::read_to_string(&files[0]).unwrap();
            let read = crate::qif_import::read(&text, 0, "f", import_options(order)).unwrap();
            assert!(read.rejected.is_empty(), "{:?}", read.rejected);
            assert_eq!(read.statement.account_number, "CCP: courant");
            let opening = read.opening.expect("le solde initial est reconnu");
            assert_eq!(opening.amount, 1_050_000_000);
            let dates: Vec<_> = read.statement.transactions.iter().map(|t| t.date).collect();
            assert_eq!(dates, vec![Some(day(2026, 2, 3)), Some(day(2026, 2, 5))], "{}", order.key());
            let total: i64 = read.statement.transactions.iter().map(|t| t.amount).sum();
            let accounts = extract.tables.iter().find(|table| table.name == "Compte").unwrap();
            let real = match accounts.rows[0][8] {
                Value::Money(micro) => micro,
                _ => unreachable!(),
            };
            // Le solde réel de Radinus, moins l'opération sans date que le QIF
            // ne peut pas porter — et que la phrase de fin annonce.
            assert_eq!(opening.amount + total, real - 10_000_000, "le solde réel de Radinus");
            assert_eq!(read.statement.transactions[1].kind, "9506023", "le numéro de chèque");
        }
    }

    #[test]
    fn un_ofx_par_compte_se_relit() {
        let (dir, extract) = sample("ofx");
        let folder = dir.join("export");
        let (files, report) = write_ofx_files(&extract, &folder, today()).unwrap();
        assert_eq!(report.accounts, 2);
        assert_eq!(report.planned, 1);
        assert_eq!(report.undated, 1);
        let text = std::fs::read_to_string(&files[0]).unwrap();
        let statement = crate::ofx_import::read(&text, "1234567A020").expect("le compte du fichier");
        let amounts: Vec<i64> = statement.transactions.iter().map(|t| t.amount).collect();
        assert_eq!(amounts, vec![-57_620_000, -185_000_000], "la mère, pas ses ventilations");
        assert_eq!(statement.transactions[0].fitid, "P_A", "le FITID de la banque est gardé");
        assert_eq!(statement.transactions[1].fitid, "", "on n'en invente pas");
        let livret = std::fs::read_to_string(&files[1]).unwrap();
        let statement = crate::ofx_import::read(&livret, "00000000000").unwrap();
        assert_eq!(statement.ledger_balance, Some(1_500_000_000));
    }

    #[test]
    fn deux_comptes_au_meme_nom_ne_s_ecrasent_pas() {
        let accounts: Vec<Account> = [(1, "Courant"), (2, "courant"), (3, ""), (4, "A/B")]
            .iter()
            .map(|(id, name)| Account {
                id: *id,
                name: name.to_string(),
                opening: 0,
                opened: None,
                ofx: crate::exports::Account::default(),
            })
            .collect();
        assert_eq!(account_names(&accounts), vec!["Courant (1)", "courant (2)", "Compte 3", "A B"]);
        assert_eq!(file_name("Comptes : famille. ", "x"), "Comptes famille");
        assert_eq!(file_name("***", "Radinus"), "Radinus");
    }

    #[test]
    fn un_nom_ne_casse_pas_le_qif() {
        let mut adjusted = 0;
        assert_eq!(category_field("Maison:Sol/Mur", "Été [2026]", &mut adjusted), "Maison:Sol-Mur/Été -2026-");
        assert_eq!(adjusted, 2);
        assert_eq!(one_line("a\r\nb\nc", &mut adjusted), "a b c");
    }
}
