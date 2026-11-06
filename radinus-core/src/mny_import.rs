//! L'importation d'un fichier Microsoft Money — « Importation de fichier
//! Money (MNY) » (Fabrice, 05/11/2026).
//!
//! # Ce que fait ce module, et ce qu'il ne fait pas
//!
//! La bibliothèque `mny-reader` déchiffre un `.mny` et en lit les tables
//! brutes (`ACCT`, `TRN`, `CAT`, `PAY`…). Ce module en fait des données qu'un
//! utilisateur reconnaît — des comptes, et pour chacun ses opérations, avec
//! leurs catégories, leurs tiers, leurs ventilations — puis porte les choix de
//! l'assistant : **où va chaque donnée Money** dans Radinus, et **à quelle
//! valeur Radinus correspond chaque valeur Money**. Il n'écrit rien dans la
//! base : l'écriture est l'affaire de l'étape suivante.
//!
//! # Rien n'est imposé
//!
//! Fabrice, 05/11/2026 : « tu feras des menus déroulants avec une proposition
//! par défaut, car il faut que l'utilisateur puisse choisir, on ne doit pas
//! tout automatiser en forçant des choix ». Chaque choix a donc une valeur
//! proposée ([`Mapping::default`], [`ValueRow::proposal`]), et rien d'autre :
//! l'utilisateur peut tout changer, et « Ne pas importer » est toujours
//! possible.
//!
//! # Ce qu'on lit dans un `.mny`
//!
//! La référence est la spécification de Fabrice (`Analyse/mnyimport/docs`) :
//!
//!   * **les comptes** (`ACCT`), sauf les comptes de placements (`at = 5`),
//!     dont les lignes parlent de titres, pas d'argent ;
//!   * **les opérations** (`TRN`), sauf celles qui portent un titre (`hsec`),
//!     comptées et dites ;
//!   * **les catégories** (`CAT`, `hct = 0`), un arbre : « DÉPENSES » à la
//!     racine, puis la catégorie (« Alimentation »), puis la sous-catégorie
//!     (« Épicerie »). La racine n'est jamais une donnée ;
//!   * **les classifications 1 et 2**, rangées dans `CAT` elles aussi ;
//!   * **les tiers** (`PAY`), **les ventilations** (`TRN_SPLIT` : les lignes
//!     d'une opération ventilée sont des opérations de `TRN` qui désignent
//!     leur mère) et **les virements** (`TRN.hacctLink`, le compte d'en face).
//!
//! Chaque colonne est cherchée **par son nom** : le schéma change selon la
//! version et la langue de Money, et une colonne absente vaut « vide ».
//!
//! # Ce qui reste à vérifier sur un vrai fichier
//!
//! Deux sens ne sont pas établis par la spécification (marqués ⚠), et les
//! exemples du 05/11/2026 ne les contiennent pas : les valeurs du pointage
//! (`cs` : 0 = non pointé, le reste pointé ou rapproché) et celles du mode de
//! paiement (`payt`). Le pointage n'y perd rien — pointée et rapprochée vont
//! dans le même menu — ; un mode de paiement prend en attendant un nom
//! provisoire, « Mode de paiement Money n° 2 », que l'utilisateur peut faire
//! correspondre à un mode de Radinus.

use crate::domain::{NaiveDate, NamedItem};
use crate::i18n::{self, Language};
use crate::nomenclatures::{self, Nomenclature};
use crate::text::{french_sort_key, same_name_key};
use mny_reader::{MnyFile, Value};
use std::collections::{HashMap, HashSet};
use std::path::Path;

// ---------------------------------------------------------------------------
// 1. Le fichier
// ---------------------------------------------------------------------------

/// Pourquoi un fichier ne s'ouvre pas — ce que l'utilisateur peut y faire.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Problem {
    /// Le fichier est protégé et le mot de passe manque, ou n'est pas le bon.
    Password,
    /// Ce n'est pas un fichier Microsoft Money.
    NotMoney,
    /// Le fichier est un fichier Money, mais il ne se lit pas : abîmé, ou
    /// d'une version que la bibliothèque ne connaît pas. Le détail est celui
    /// de la bibliothèque.
    Unreadable(String),
}

impl From<mny_reader::Error> for Problem {
    fn from(error: mny_reader::Error) -> Self {
        match error {
            mny_reader::Error::WrongPassword | mny_reader::Error::DecryptionCheckFailed => {
                Problem::Password
            }
            mny_reader::Error::NotMoneyFile | mny_reader::Error::InvalidFileSize(_) => {
                Problem::NotMoney
            }
            other => Problem::Unreadable(other.to_string()),
        }
    }
}

/// Un compte du fichier, tel que l'assistant le propose.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Account {
    /// L'identifiant du compte dans le fichier (`ACCT.hacct`).
    pub handle: i32,
    pub name: String,
    /// Le solde d'ouverture, en micro-unités comme toute la base.
    pub opening: i64,
    pub closed: bool,
    /// Le code ISO de sa devise (`EUR`), vide s'il ne se lit pas.
    pub currency: String,
    /// Le nombre d'opérations, ventilations comprises comme une seule.
    pub operations: usize,
}

/// Le pointage d'une opération dans Money.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Cleared {
    No,
    Cleared,
    Reconciled,
}

/// Ce qu'une ligne Money porte et que Radinus peut ranger : une opération, ou
/// une ligne de sa ventilation.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct Line {
    /// En micro-unités ; négatif pour une dépense.
    pub amount: i64,
    /// La catégorie (« Alimentation »), premier niveau sous la racine.
    pub category: Option<String>,
    /// La sous-catégorie (« Épicerie »), s'il y en a une.
    pub sub_category: Option<String>,
    pub payee: Option<String>,
    /// Le code du mode de paiement (`TRN.payt`) ; son nom est provisoire tant
    /// que les codes ne sont pas établis (voir l'en-tête).
    pub payment_mode: Option<i32>,
    pub classification1: Option<String>,
    pub classification2: Option<String>,
    /// Le numéro de chèque ou la référence (`TRN.szId`).
    pub reference: Option<String>,
    /// La note (`TRN.mMemo`).
    pub memo: Option<String>,
}

/// Une opération d'un compte Money.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Operation {
    pub date: NaiveDate,
    pub cleared: Cleared,
    pub cleared_date: Option<NaiveDate>,
    /// Une échéance de l'échéancier Money (`TRN.frq ≠ -1`), pas une opération
    /// réalisée.
    pub scheduled: bool,
    /// Pour un virement, le nom du compte d'en face.
    pub transfer: Option<String>,
    pub line: Line,
    /// Les lignes de sa ventilation, dans l'ordre de Money. Vide si elle n'est
    /// pas ventilée.
    pub splits: Vec<Line>,
}

/// Tout ce qu'un fichier Money apporte à l'assistant.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct Book {
    /// Les comptes proposés, dans l'ordre du fichier.
    pub accounts: Vec<Account>,
    /// Les opérations de chaque compte (par `Account::handle`), par date.
    pub operations: HashMap<i32, Vec<Operation>>,
    /// Les lignes écartées parce qu'elles portent un titre de placement.
    pub investment_lines: usize,
    /// Les lignes écartées parce que leur date ne se lit pas.
    pub undated_lines: usize,
}

/// `ACCT.at` d'un compte de placements.
const INVESTMENT_ACCOUNT: i64 = 5;

impl Book {
    /// Ouvre et lit un fichier Money. `password` vaut `None` pour un fichier
    /// qui n'en a pas.
    pub fn open(path: &Path, password: Option<&str>) -> Result<Book, Problem> {
        let file = MnyFile::open(path, password)?;
        Book::read(&file)
    }

    /// Les opérations d'un compte du fichier ; aucune pour un compte inconnu.
    pub fn operations_of(&self, account: i32) -> &[Operation] {
        self.operations.get(&account).map(Vec::as_slice).unwrap_or(&[])
    }

    /// Lit un fichier déjà ouvert.
    pub fn read(file: &MnyFile) -> Result<Book, Problem> {
        let currencies = Table::read(file, "CRNC")?;
        let currency_of: HashMap<i64, String> = (0..currencies.len())
            .filter_map(|row| {
                Some((
                    currencies.handle(row, "hcrnc")?,
                    currencies.text(row, "szIsoCode").unwrap_or_default(),
                ))
            })
            .collect();

        // Les comptes. Un compte de placements n'est pas proposé, mais son
        // nom sert encore à dire « Virement vers … ».
        let accounts_table = Table::read(file, "ACCT")?;
        let mut accounts = Vec::new();
        let mut account_names = HashMap::new();
        let mut investment = HashSet::new();
        for row in 0..accounts_table.len() {
            let Some(handle) = accounts_table.handle(row, "hacct") else {
                continue;
            };
            let name = accounts_table.text(row, "szFull").unwrap_or_default();
            account_names.insert(handle, name.clone());
            if accounts_table.int(row, "at") == Some(INVESTMENT_ACCOUNT) {
                investment.insert(handle);
                continue;
            }
            accounts.push(Account {
                handle: handle as i32,
                name,
                opening: accounts_table.money(row, "amtOpen").unwrap_or(0),
                closed: accounts_table.boolean(row, "fClosed"),
                currency: accounts_table
                    .handle(row, "hcrnc")
                    .and_then(|currency| currency_of.get(&currency).cloned())
                    .unwrap_or_default(),
                operations: 0,
            });
        }

        let tree = Tree::read(file)?;
        let payees_table = Table::read(file, "PAY")?;
        let payees: HashMap<i64, String> = (0..payees_table.len())
            .filter_map(|row| {
                Some((
                    payees_table.handle(row, "hpay")?,
                    payees_table.text(row, "szFull")?,
                ))
            })
            .collect();

        // Les ventilations : chaque ligne désigne sa mère et son rang.
        let splits_table = Table::read(file, "TRN_SPLIT")?;
        let mut parent_of = HashMap::new();
        for row in 0..splits_table.len() {
            if let (Some(child), Some(parent)) = (
                splits_table.handle(row, "htrn"),
                splits_table.handle(row, "htrnParent"),
            ) {
                let rank = splits_table.int(row, "iSplit").unwrap_or(0);
                parent_of.insert(child, (parent, rank));
            }
        }

        let mut book = Book::default();
        let operations_table = Table::read(file, "TRN")?;
        let mut read: HashMap<i64, (i64, Operation)> = HashMap::new();
        let mut children: HashMap<i64, Vec<(i64, i64, Line)>> = HashMap::new();
        let mut order: Vec<(i64, i64)> = Vec::new();
        for row in 0..operations_table.len() {
            let t = &operations_table;
            let (Some(id), Some(account)) = (t.handle(row, "htrn"), t.handle(row, "hacct")) else {
                continue;
            };
            if investment.contains(&account) {
                continue;
            }
            if t.handle(row, "hsec").is_some() {
                book.investment_lines += 1;
                continue;
            }
            let line = Line {
                amount: t.money(row, "amt").unwrap_or(0),
                category: None,
                sub_category: None,
                payee: t.handle(row, "lHpay").and_then(|payee| payees.get(&payee).cloned()),
                payment_mode: t
                    .int(row, "payt")
                    .filter(|code| *code >= 0)
                    .map(|code| code as i32),
                classification1: t.handle(row, "lHcls1").and_then(|cls| tree.full_name(cls)),
                classification2: t.handle(row, "lHcls2").and_then(|cls| tree.full_name(cls)),
                reference: t.text(row, "szId"),
                memo: t.text(row, "mMemo"),
            };
            let line = match t.handle(row, "hcat").map(|cat| tree.path(cat)) {
                Some(path) if !path.is_empty() => Line {
                    category: Some(path[0].clone()),
                    sub_category: (path.len() > 1).then(|| path[1..].join(" : ")),
                    ..line
                },
                _ => line,
            };
            if let Some((parent, rank)) = parent_of.get(&id) {
                children.entry(*parent).or_default().push((*rank, id, line));
                continue;
            }
            let Some(date) = t.date(row, "dt") else {
                book.undated_lines += 1;
                continue;
            };
            let cleared = match t.int(row, "cs").unwrap_or(0) {
                0 => Cleared::No,
                2 => Cleared::Reconciled,
                _ => Cleared::Cleared,
            };
            let operation = Operation {
                date,
                cleared,
                cleared_date: t.date(row, "dtCleared"),
                scheduled: t.int(row, "frq").is_some_and(|frequency| frequency != -1),
                transfer: t
                    .handle(row, "hacctLink")
                    .and_then(|other| account_names.get(&other).cloned()),
                line,
                splits: Vec::new(),
            };
            read.insert(id, (account, operation));
            order.push((account, id));
        }

        // Chaque ventilation rejoint sa mère ; une ligne dont la mère n'est
        // plus là est perdue pour Money aussi, et n'entre pas.
        for (parent, mut lines) in children {
            if let Some((_, operation)) = read.get_mut(&parent) {
                lines.sort_by_key(|(rank, id, _)| (*rank, *id));
                operation.splits = lines.into_iter().map(|(_, _, line)| line).collect();
            }
        }
        let mut grouped: HashMap<i32, Vec<(i64, Operation)>> = HashMap::new();
        for (account, id) in order {
            if let Some((_, operation)) = read.remove(&id) {
                grouped.entry(account as i32).or_default().push((id, operation));
            }
        }
        let mut sorted: HashMap<i32, Vec<Operation>> = HashMap::new();
        for (account, mut operations) in grouped {
            operations.sort_by(|(a_id, a), (b_id, b)| a.date.cmp(&b.date).then(a_id.cmp(b_id)));
            sorted.insert(account, operations.into_iter().map(|(_, operation)| operation).collect());
        }
        for account in &mut accounts {
            account.operations = sorted.get(&account.handle).map_or(0, Vec::len);
        }
        book.accounts = accounts;
        book.operations = sorted;
        Ok(book)
    }
}

// ---------------------------------------------------------------------------
// 2. Où va chaque donnée Money
// ---------------------------------------------------------------------------

/// Une donnée Money que l'assistant sait ranger.
///
/// **Le bénéficiaire n'en est pas** (Fabrice, 05/11/2026). Money n'a pas de
/// libellé : ce qu'on tape dans « Bénéficiaire » en tient lieu — « Carottes »,
/// « Taxe habitation » —, si bien qu'en faire un tiers créerait un tiers par
/// libellé. Le bénéficiaire devient donc toujours le libellé ([`LabelFrom`]),
/// et la question des tiers est posée à part ([`Payees`]).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Source {
    Category,
    SubCategory,
    PaymentMode,
    Classification1,
    Classification2,
    Reference,
    Memo,
}

/// Les données Money, dans l'ordre où l'assistant les montre.
pub const SOURCES: [Source; 7] = [
    Source::Category,
    Source::SubCategory,
    Source::PaymentMode,
    Source::Classification1,
    Source::Classification2,
    Source::Reference,
    Source::Memo,
];

/// Une case de Radinus qui peut recevoir une donnée Money.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Destination {
    /// « Ne pas importer ».
    Ignore,
    BudgetLine,
    Category,
    Payee,
    PaymentMode,
    Assignment,
    Project,
    /// La référence paiement de l'opération.
    Reference,
    /// Le commentaire de l'opération.
    Comment,
}

/// Les cases qui reçoivent un **classement** — une valeur à faire
/// correspondre à un élément d'une nomenclature.
const CLASSING: [Destination; 6] = [
    Destination::BudgetLine,
    Destination::Category,
    Destination::Payee,
    Destination::PaymentMode,
    Destination::Assignment,
    Destination::Project,
];

impl Source {
    /// Le nom sous lequel la donnée voyage vers la fenêtre.
    pub fn key(self) -> &'static str {
        match self {
            Source::Category => "category",
            Source::SubCategory => "sub-category",
            Source::PaymentMode => "payment-mode",
            Source::Classification1 => "classification-1",
            Source::Classification2 => "classification-2",
            Source::Reference => "reference",
            Source::Memo => "memo",
        }
    }

    pub fn from_key(key: &str) -> Option<Source> {
        SOURCES.into_iter().find(|source| source.key() == key)
    }

    /// La case proposée par défaut (Fabrice, 05/11/2026).
    pub fn default_destination(self) -> Destination {
        match self {
            Source::Category => Destination::BudgetLine,
            Source::SubCategory => Destination::Category,
            Source::PaymentMode => Destination::PaymentMode,
            Source::Classification1 => Destination::Assignment,
            Source::Classification2 => Destination::Project,
            Source::Reference => Destination::Reference,
            Source::Memo => Destination::Comment,
        }
    }

    /// Les cases que son menu déroulant propose. Un classement va dans une
    /// nomenclature ou dans le commentaire ; un texte libre — la référence,
    /// la note — n'est pas un classement, et ne va que dans un texte. Les
    /// tiers ne sont proposés à personne : ils viennent du bénéficiaire, par
    /// sa propre question.
    pub fn destinations(self) -> &'static [Destination] {
        match self {
            Source::Reference | Source::Memo => {
                &[Destination::Ignore, Destination::Reference, Destination::Comment]
            }
            _ => &[
                Destination::Ignore,
                Destination::BudgetLine,
                Destination::Category,
                Destination::PaymentMode,
                Destination::Assignment,
                Destination::Project,
                Destination::Comment,
            ],
        }
    }

    /// La valeur que cette donnée prend sur une ligne.
    fn value(self, line: &Line, language: Language) -> Option<String> {
        match self {
            Source::Category => line.category.clone(),
            Source::SubCategory => line.sub_category.clone(),
            Source::PaymentMode => line
                .payment_mode
                .map(|code| i18n::text_with(language, "mny-payment-mode", "code", &code.to_string())),
            Source::Classification1 => line.classification1.clone(),
            Source::Classification2 => line.classification2.clone(),
            Source::Reference => line.reference.clone(),
            Source::Memo => line.memo.clone(),
        }
    }
}

impl Destination {
    pub fn key(self) -> &'static str {
        match self {
            Destination::Ignore => "ignore",
            Destination::BudgetLine => "budget-line",
            Destination::Category => "category",
            Destination::Payee => "payee",
            Destination::PaymentMode => "payment-mode",
            Destination::Assignment => "assignment",
            Destination::Project => "project",
            Destination::Reference => "reference",
            Destination::Comment => "comment",
        }
    }

    pub fn from_key(key: &str) -> Option<Destination> {
        [
            Destination::Ignore,
            Destination::Reference,
            Destination::Comment,
        ]
        .into_iter()
        .chain(CLASSING)
        .find(|destination| destination.key() == key)
    }

    /// La nomenclature qu'elle remplit, pour une case de classement.
    pub fn nomenclature(self) -> Option<Nomenclature> {
        match self {
            Destination::BudgetLine => Some(Nomenclature::BudgetLine),
            Destination::Category => Some(Nomenclature::Category),
            Destination::Payee => Some(Nomenclature::Payee),
            Destination::PaymentMode => Some(Nomenclature::PaymentMode),
            Destination::Assignment => Some(Nomenclature::Assignment),
            Destination::Project => Some(Nomenclature::Project),
            Destination::Ignore | Destination::Reference | Destination::Comment => None,
        }
    }
}

/// D'où vient le libellé d'une opération : Money n'a pas de champ « libellé ».
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum LabelFrom {
    Payee,
    Memo,
    PayeeAndMemo,
}

impl LabelFrom {
    pub const ALL: [LabelFrom; 3] = [LabelFrom::Payee, LabelFrom::Memo, LabelFrom::PayeeAndMemo];

    pub fn key(self) -> &'static str {
        match self {
            LabelFrom::Payee => "payee",
            LabelFrom::Memo => "memo",
            LabelFrom::PayeeAndMemo => "payee-and-memo",
        }
    }

    pub fn from_key(key: &str) -> Option<LabelFrom> {
        LabelFrom::ALL.into_iter().find(|one| one.key() == key)
    }
}

/// Le statut d'une opération dans Radinus (`StatutOperation`).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Status {
    Pointed,
    Committed,
    Planned,
}

impl Status {
    pub const ALL: [Status; 3] = [Status::Pointed, Status::Committed, Status::Planned];

    pub fn key(self) -> &'static str {
        match self {
            Status::Pointed => "pointed",
            Status::Committed => "committed",
            Status::Planned => "planned",
        }
    }

    pub fn from_key(key: &str) -> Option<Status> {
        Status::ALL.into_iter().find(|one| one.key() == key)
    }

    /// Son `IDStatutOperation`.
    pub fn id(self) -> i64 {
        match self {
            Status::Pointed => 1,
            Status::Committed => 2,
            Status::Planned => 3,
        }
    }
}

/// Ce qu'on fait des échéances de l'échéancier Money.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Scheduled {
    Skip,
    AsPlanned,
}

impl Scheduled {
    pub const ALL: [Scheduled; 2] = [Scheduled::Skip, Scheduled::AsPlanned];

    pub fn key(self) -> &'static str {
        match self {
            Scheduled::Skip => "skip",
            Scheduled::AsPlanned => "planned",
        }
    }

    pub fn from_key(key: &str) -> Option<Scheduled> {
        Scheduled::ALL.into_iter().find(|one| one.key() == key)
    }
}

/// Les bénéficiaires Money qui deviennent des tiers (Fabrice, 05/11/2026).
///
/// Le bénéficiaire devient toujours le libellé ; en faire **aussi** un tiers
/// est une question à part, car dans Money il tient lieu de libellé et un
/// tiers par libellé encombrerait la nomenclature.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Payees {
    /// « Non, aucun tiers » : la proposition.
    None,
    /// Seulement ceux qui reviennent souvent : au moins [`FREQUENT`] lignes.
    Frequent,
    /// Un tiers par bénéficiaire.
    All,
}

/// À partir de combien de lignes un bénéficiaire « revient souvent ».
pub const FREQUENT: usize = 3;

impl Payees {
    pub const ALL: [Payees; 3] = [Payees::None, Payees::Frequent, Payees::All];

    pub fn key(self) -> &'static str {
        match self {
            Payees::None => "none",
            Payees::Frequent => "frequent",
            Payees::All => "all",
        }
    }

    pub fn from_key(key: &str) -> Option<Payees> {
        Payees::ALL.into_iter().find(|one| one.key() == key)
    }
}

/// Tous les choix de l'étape « où va chaque donnée ».
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Mapping {
    /// La case de chaque donnée Money, dans l'ordre de [`SOURCES`].
    pub routes: [Destination; 7],
    /// Les bénéficiaires qui deviennent des tiers.
    pub payees: Payees,
    pub label: LabelFrom,
    /// Le statut d'une opération pointée ou rapprochée dans Money.
    pub cleared: Status,
    /// Le statut d'une opération non pointée dans Money.
    pub not_cleared: Status,
    pub scheduled: Scheduled,
}

impl Default for Mapping {
    /// Les propositions de Fabrice et de l'assistant (05/11/2026).
    fn default() -> Self {
        Mapping {
            routes: SOURCES.map(Source::default_destination),
            payees: Payees::None,
            label: LabelFrom::Payee,
            cleared: Status::Pointed,
            not_cleared: Status::Committed,
            scheduled: Scheduled::Skip,
        }
    }
}

/// Pourquoi l'assistant ne laisse pas passer des choix.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Refusal {
    /// Deux données Money envoyées dans la même case : une case de Radinus
    /// ne reçoit qu'une donnée.
    SameDestination {
        first: Source,
        second: Source,
        destination: Destination,
    },
    /// Une donnée envoyée dans une case que son menu ne propose pas.
    NotOffered {
        source: Source,
        destination: Destination,
    },
    /// Un poste budgétaire sans catégorie : dans Radinus, une opération ne
    /// porte pas de poste, elle le reçoit de sa catégorie.
    BudgetLineWithoutCategory,
}

impl Mapping {
    /// La case d'une donnée Money.
    pub fn destination(&self, source: Source) -> Destination {
        self.routes[SOURCES.iter().position(|one| *one == source).unwrap_or(0)]
    }

    /// Change la case d'une donnée Money.
    pub fn set(&mut self, source: Source, destination: Destination) {
        if let Some(index) = SOURCES.iter().position(|one| *one == source) {
            self.routes[index] = destination;
        }
    }

    /// La donnée Money qui remplit une case, s'il y en a une.
    pub fn source_of(&self, destination: Destination) -> Option<Source> {
        if destination == Destination::Ignore {
            return None;
        }
        SOURCES
            .into_iter()
            .find(|source| self.destination(*source) == destination)
    }

    /// Les données envoyées dans une case qu'une autre donnée remplit déjà :
    /// l'étape 2 met leurs lignes en rouge.
    pub fn conflicts(&self) -> Vec<Source> {
        SOURCES
            .into_iter()
            .filter(|source| {
                let destination = self.destination(*source);
                destination != Destination::Ignore
                    && SOURCES
                        .iter()
                        .any(|other| other != source && self.destination(*other) == destination)
            })
            .collect()
    }

    /// Les choix sont-ils recevables ? La première faute trouvée est rendue,
    /// dans l'ordre où l'assistant montre les données.
    pub fn check(&self) -> Result<(), Refusal> {
        for (index, source) in SOURCES.into_iter().enumerate() {
            let destination = self.routes[index];
            if !source.destinations().contains(&destination) {
                return Err(Refusal::NotOffered {
                    source,
                    destination,
                });
            }
            if destination == Destination::Ignore {
                continue;
            }
            if let Some(first) = SOURCES[..index]
                .iter()
                .find(|earlier| self.destination(**earlier) == destination)
            {
                return Err(Refusal::SameDestination {
                    first: *first,
                    second: source,
                    destination,
                });
            }
        }
        if self.source_of(Destination::BudgetLine).is_some()
            && self.source_of(Destination::Category).is_none()
        {
            return Err(Refusal::BudgetLineWithoutCategory);
        }
        Ok(())
    }
}

// ---------------------------------------------------------------------------
// 3. Une ligne Money rangée dans les cases de Radinus
// ---------------------------------------------------------------------------

/// Ce que chaque case de Radinus reçoit d'une ligne Money.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct Routed {
    pub budget_line: Option<String>,
    pub category: Option<String>,
    pub payee: Option<String>,
    pub payment_mode: Option<String>,
    pub assignment: Option<String>,
    pub project: Option<String>,
    pub reference: Option<String>,
    pub comment: Option<String>,
}

impl Routed {
    /// La valeur d'une case de classement.
    pub fn classing(&self, destination: Destination) -> Option<&String> {
        match destination {
            Destination::BudgetLine => self.budget_line.as_ref(),
            Destination::Category => self.category.as_ref(),
            Destination::Payee => self.payee.as_ref(),
            Destination::PaymentMode => self.payment_mode.as_ref(),
            Destination::Assignment => self.assignment.as_ref(),
            Destination::Project => self.project.as_ref(),
            _ => None,
        }
    }
}

/// Les choix, et ce qu'il faut savoir de toutes les opérations importées
/// pour ranger chacune d'elles.
pub struct Plan<'a> {
    pub mapping: &'a Mapping,
    pub language: Language,
    /// Les sous-catégories dont le nom revient sous plusieurs catégories
    /// (« Divers » sous « Auto » et sous « Maison »). Dans Radinus deux
    /// catégories ne portent pas le même nom : celles-ci prennent leur nom
    /// complet, « Auto : Divers ».
    ambiguous: HashSet<String>,
    /// Le nombre de lignes de chaque bénéficiaire (par [`same_name_key`]),
    /// pour « seulement ceux qui reviennent souvent ».
    payee_uses: HashMap<String, usize>,
}

impl<'a> Plan<'a> {
    pub fn new(operations: &[&Operation], mapping: &'a Mapping, language: Language) -> Plan<'a> {
        let mut parents: HashMap<String, HashSet<String>> = HashMap::new();
        let mut payee_uses: HashMap<String, usize> = HashMap::new();
        for line in operations.iter().flat_map(|operation| lines_of(operation)) {
            if let Some(payee) = &line.payee {
                *payee_uses.entry(same_name_key(payee)).or_default() += 1;
            }
            if let (Some(category), Some(sub)) = (&line.category, &line.sub_category) {
                parents
                    .entry(same_name_key(sub))
                    .or_default()
                    .insert(same_name_key(category));
            }
        }
        Plan {
            mapping,
            language,
            ambiguous: parents
                .into_iter()
                .filter(|(_, categories)| categories.len() > 1)
                .map(|(sub, _)| sub)
                .collect(),
            payee_uses,
        }
    }

    /// Le tiers d'une ligne : son bénéficiaire, si les choix en font un tiers.
    fn payee(&self, line: &Line) -> Option<String> {
        let payee = line.payee.as_ref()?;
        let kept = match self.mapping.payees {
            Payees::None => false,
            Payees::All => true,
            Payees::Frequent => {
                self.payee_uses
                    .get(&same_name_key(payee))
                    .copied()
                    .unwrap_or(0)
                    >= FREQUENT
            }
        };
        kept.then(|| payee.clone())
    }

    /// Range une ligne.
    pub fn route(&self, line: &Line) -> Routed {
        let mut routed = Routed {
            payee: self.payee(line),
            ..Routed::default()
        };
        for source in SOURCES {
            let value = self.value(source, line);
            let slot = match self.mapping.destination(source) {
                Destination::Ignore => continue,
                Destination::BudgetLine => &mut routed.budget_line,
                Destination::Category => &mut routed.category,
                Destination::Payee => &mut routed.payee,
                Destination::PaymentMode => &mut routed.payment_mode,
                Destination::Assignment => &mut routed.assignment,
                Destination::Project => &mut routed.project,
                Destination::Reference => &mut routed.reference,
                Destination::Comment => &mut routed.comment,
            };
            *slot = value;
        }
        // **Une catégorie sans sous-catégorie** (« Alimentation » seule) :
        // la catégorie Radinus prend le nom du poste, et se range dessous.
        if routed.category.is_none() && self.mapping.source_of(Destination::Category).is_some() {
            routed.category = routed.budget_line.clone();
        }
        routed
    }

    fn value(&self, source: Source, line: &Line) -> Option<String> {
        let value = source.value(line, self.language)?;
        if source == Source::SubCategory
            && self.ambiguous.contains(&same_name_key(&value))
            && let Some(category) = &line.category
        {
            return Some(format!("{category} : {value}"));
        }
        Some(value)
    }

    /// Le libellé d'une opération.
    pub fn label(&self, operation: &Operation) -> String {
        let line = &operation.line;
        let chosen = match self.mapping.label {
            LabelFrom::Payee => line.payee.clone().or_else(|| line.memo.clone()),
            LabelFrom::Memo => line.memo.clone().or_else(|| line.payee.clone()),
            LabelFrom::PayeeAndMemo => match (&line.payee, &line.memo) {
                (Some(payee), Some(memo)) => Some(format!("{payee} {memo}")),
                (payee, memo) => payee.clone().or_else(|| memo.clone()),
            },
        };
        chosen
            .or_else(|| {
                operation.transfer.as_ref().map(|account| {
                    let key = if line.amount < 0 {
                        "mny-transfer-to"
                    } else {
                        "mny-transfer-from"
                    };
                    i18n::text_with(self.language, key, "account", account)
                })
            })
            .unwrap_or_else(|| i18n::text(self.language, "mny-no-label"))
    }

    /// Le statut d'une opération.
    pub fn status(&self, operation: &Operation) -> Status {
        if operation.scheduled {
            return Status::Planned;
        }
        match operation.cleared {
            Cleared::No => self.mapping.not_cleared,
            Cleared::Cleared | Cleared::Reconciled => self.mapping.cleared,
        }
    }
}

/// Une opération et les lignes de sa ventilation.
fn lines_of(operation: &Operation) -> impl Iterator<Item = &Line> {
    std::iter::once(&operation.line).chain(operation.splits.iter())
}

/// Les opérations d'un compte que l'import prend : les échéances seulement si
/// on les a demandées.
pub fn selected<'b>(book: &'b Book, account: i32, mapping: &Mapping) -> Vec<&'b Operation> {
    book.operations_of(account)
        .iter()
        .filter(|operation| !operation.scheduled || mapping.scheduled == Scheduled::AsPlanned)
        .collect()
}

// ---------------------------------------------------------------------------
// 4. Les correspondances de valeurs
// ---------------------------------------------------------------------------

/// Ce que devient une valeur Money dans Radinus.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Choice {
    /// Un élément qui existe déjà (son identifiant).
    Existing(i64),
    /// Un élément à créer, du nom de la valeur Money.
    Create,
    /// « Non précisé ».
    Unspecified,
}

/// Les nomenclatures de la base, lues une fois pour toutes les propositions.
#[derive(Debug, Clone, Default, PartialEq)]
pub struct Existing {
    pub budget_lines: Vec<NamedItem>,
    pub categories: Vec<NamedItem>,
    pub payees: Vec<NamedItem>,
    pub payment_modes: Vec<NamedItem>,
    pub assignments: Vec<NamedItem>,
    pub projects: Vec<NamedItem>,
}

impl Existing {
    pub fn read(conn: &rusqlite::Connection) -> rusqlite::Result<Existing> {
        Ok(Existing {
            budget_lines: nomenclatures::list(conn, Nomenclature::BudgetLine)?,
            categories: nomenclatures::list(conn, Nomenclature::Category)?,
            payees: nomenclatures::list(conn, Nomenclature::Payee)?,
            payment_modes: nomenclatures::list(conn, Nomenclature::PaymentMode)?,
            assignments: nomenclatures::list(conn, Nomenclature::Assignment)?,
            projects: nomenclatures::list(conn, Nomenclature::Project)?,
        })
    }

    pub fn of(&self, destination: Destination) -> &[NamedItem] {
        match destination {
            Destination::BudgetLine => &self.budget_lines,
            Destination::Category => &self.categories,
            Destination::Payee => &self.payees,
            Destination::PaymentMode => &self.payment_modes,
            Destination::Assignment => &self.assignments,
            Destination::Project => &self.projects,
            _ => &[],
        }
    }
}

/// Une valeur Money à faire correspondre.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ValueRow {
    pub destination: Destination,
    /// La valeur, telle que Money l'écrit (une sous-catégorie ambiguë avec
    /// le nom de sa catégorie).
    pub label: String,
    /// Pour une catégorie, le poste sous lequel elle serait créée.
    pub budget_line: Option<String>,
    /// Le nombre de lignes qui la portent.
    pub uses: usize,
    /// L'élément de même nom s'il existe, sinon « à créer ».
    pub proposal: Choice,
}

/// Toutes les valeurs à faire correspondre, case par case puis dans l'ordre
/// des listes de Radinus.
pub fn values(operations: &[&Operation], plan: &Plan<'_>, existing: &Existing) -> Vec<ValueRow> {
    let mut rows: Vec<ValueRow> = Vec::new();
    let mut index: HashMap<(Destination, String), usize> = HashMap::new();
    for line in operations.iter().flat_map(|operation| lines_of(operation)) {
        let routed = plan.route(line);
        for destination in CLASSING {
            let Some(label) = routed.classing(destination) else {
                continue;
            };
            let key = (destination, same_name_key(label));
            if key.1.is_empty() {
                continue;
            }
            match index.get(&key) {
                Some(&at) => rows[at].uses += 1,
                None => {
                    index.insert(key, rows.len());
                    rows.push(ValueRow {
                        destination,
                        label: label.clone(),
                        budget_line: (destination == Destination::Category)
                            .then(|| routed.budget_line.clone())
                            .flatten(),
                        uses: 1,
                        proposal: proposal(existing.of(destination), label),
                    });
                }
            }
        }
    }
    rows.sort_by(|a, b| {
        let rank = |row: &ValueRow| CLASSING.iter().position(|one| *one == row.destination);
        rank(a)
            .cmp(&rank(b))
            .then_with(|| french_sort_key(&a.label).cmp(&french_sort_key(&b.label)))
    });
    rows
}

/// L'élément de même nom — espaces, casse et accents ignorés, comme partout
/// dans Radinus —, sinon « à créer ».
fn proposal(items: &[NamedItem], label: &str) -> Choice {
    let wanted = same_name_key(label);
    items
        .iter()
        .find(|item| same_name_key(&item.label) == wanted)
        .map_or(Choice::Create, |item| Choice::Existing(item.id))
}

// ---------------------------------------------------------------------------
// 5. L'aperçu
// ---------------------------------------------------------------------------

/// Le nombre de lignes que l'aperçu montre ; l'import les prend toutes.
pub const PREVIEW_LIMIT: usize = 200;

/// Une opération telle qu'elle arrivera dans Radinus.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PreviewRow {
    pub date: NaiveDate,
    pub label: String,
    pub amount: i64,
    pub status: Status,
    pub routed: Routed,
    /// Le nombre de lignes de sa ventilation, 0 si elle n'est pas ventilée.
    pub splits: usize,
    pub transfer: bool,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Preview {
    pub rows: Vec<PreviewRow>,
    /// Le nombre d'opérations que l'import prendra.
    pub total: usize,
    /// Leur somme, en micro-unités.
    pub sum: i64,
    /// Les échéances laissées de côté.
    pub scheduled_skipped: usize,
}

/// L'aperçu d'un compte avec les choix en cours.
pub fn preview(book: &Book, account: i32, mapping: &Mapping, language: Language, limit: usize) -> Preview {
    let operations = selected(book, account, mapping);
    let plan = Plan::new(&operations, mapping, language);
    let scheduled_skipped = book.operations_of(account).len() - operations.len();
    Preview {
        rows: operations
            .iter()
            .take(limit)
            .map(|operation| PreviewRow {
                date: operation.date,
                label: plan.label(operation),
                amount: operation.line.amount,
                status: plan.status(operation),
                routed: plan.route(&operation.line),
                splits: operation.splits.len(),
                transfer: operation.transfer.is_some(),
            })
            .collect(),
        total: operations.len(),
        sum: operations.iter().map(|operation| operation.line.amount).sum(),
        scheduled_skipped,
    }
}

/// Le nombre d'exemples que l'étape 2 reçoit pour chaque donnée.
pub const SAMPLE_LIMIT: usize = 3;

/// Ce que le fichier contient d'une donnée Money, pour l'étape 2 : « à
/// gauche, ce que contient votre fichier Money, avec un exemple ».
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct Sample {
    /// Les valeurs les plus fréquentes, avec leur nombre de lignes : au plus
    /// [`SAMPLE_LIMIT`], la plus fréquente d'abord.
    pub examples: Vec<(String, usize)>,
    /// Le nombre de valeurs différentes (par [`same_name_key`]).
    pub distinct: usize,
    /// Le nombre de lignes qui en portent une. 0 : la donnée est absente du
    /// fichier, et l'étape 2 la grise.
    pub lines: usize,
}

impl Sample {
    fn of(values: impl Iterator<Item = String>) -> Sample {
        let mut counts: HashMap<String, (String, usize)> = HashMap::new();
        let mut lines = 0;
        for value in values {
            let key = same_name_key(&value);
            if key.is_empty() {
                continue;
            }
            lines += 1;
            counts.entry(key).or_insert((value, 0)).1 += 1;
        }
        let distinct = counts.len();
        let mut examples: Vec<(String, usize)> = counts.into_values().collect();
        examples.sort_by(|a, b| {
            b.1.cmp(&a.1)
                .then_with(|| french_sort_key(&a.0).cmp(&french_sort_key(&b.0)))
        });
        examples.truncate(SAMPLE_LIMIT);
        Sample {
            examples,
            distinct,
            lines,
        }
    }

    /// Le nombre de valeurs portées par au moins [`FREQUENT`] lignes.
    fn frequent(values: impl Iterator<Item = String>) -> usize {
        let mut counts: HashMap<String, usize> = HashMap::new();
        for value in values {
            let key = same_name_key(&value);
            if !key.is_empty() {
                *counts.entry(key).or_default() += 1;
            }
        }
        counts.values().filter(|count| **count >= FREQUENT).count()
    }
}

/// Tout ce que l'étape 2 montre du fichier, pour un compte Money.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Samples {
    /// Une par donnée, dans l'ordre de [`SOURCES`].
    pub sources: Vec<(Source, Sample)>,
    /// Les bénéficiaires, qui ont leur propre question.
    pub payees: Sample,
    /// Combien d'entre eux reviennent au moins [`FREQUENT`] fois.
    pub frequent_payees: usize,
    /// Les opérations pointées ou rapprochées, puis les autres, hors échéances.
    pub cleared: usize,
    pub not_cleared: usize,
    /// Les échéances à venir.
    pub scheduled: usize,
}

/// Les exemples et les nombres d'un compte Money, échéances comprises.
pub fn samples(book: &Book, account: i32, language: Language) -> Samples {
    let operations = book.operations_of(account);
    let lines = || operations.iter().flat_map(lines_of);
    let payees = || lines().filter_map(|line| line.payee.clone());
    let dated = || operations.iter().filter(|operation| !operation.scheduled);
    Samples {
        sources: SOURCES
            .into_iter()
            .map(|source| {
                (
                    source,
                    Sample::of(lines().filter_map(|line| source.value(line, language))),
                )
            })
            .collect(),
        payees: Sample::of(payees()),
        frequent_payees: Sample::frequent(payees()),
        cleared: dated()
            .filter(|operation| operation.cleared != Cleared::No)
            .count(),
        not_cleared: dated()
            .filter(|operation| operation.cleared == Cleared::No)
            .count(),
        scheduled: operations.iter().filter(|operation| operation.scheduled).count(),
    }
}

// ---------------------------------------------------------------------------
// 6. L'importation
// ---------------------------------------------------------------------------

/// La longueur d'un libellé dans Radinus, et celle d'une référence paiement
/// (P-75) : au-delà, le texte est coupé plutôt que refusé.
const LABEL_LENGTH: usize = 300;
const REFERENCE_LENGTH: usize = 255;

/// Un élément créé dans une nomenclature, pour le journal.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Created {
    pub destination: Destination,
    pub label: String,
}

/// Ce que l'importation a fait.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Outcome {
    pub operations: usize,
    /// Les opérations ventilées parmi elles.
    pub splits: usize,
    pub sum: i64,
    pub created: Vec<Created>,
    /// Le solde d'ouverture Money a été repris comme solde initial pointé.
    pub opening_set: bool,
}

fn cut(text: &str, length: usize) -> String {
    text.chars().take(length).collect()
}

/// L'élément d'une nomenclature qui porte déjà ce nom — espaces, casse et
/// accents ignorés : Radinus ne laisse pas deux éléments porter le même nom.
fn same_name_id(conn: &rusqlite::Connection, kind: Nomenclature, label: &str) -> rusqlite::Result<Option<i64>> {
    let wanted = same_name_key(label);
    Ok(nomenclatures::list(conn, kind)?
        .into_iter()
        .find(|item| same_name_key(&item.label) == wanted)
        .map(|item| item.id))
}

/// **Importe les opérations choisies dans un compte, d'un seul bloc.**
///
/// `values` et `choices` vont ensemble, rang pour rang : `choices[i]` est ce
/// que l'utilisateur a choisi pour `values[i]` à l'étape 3 (sa proposition
/// s'il n'a rien touché). Dans l'ordre :
///
///   1. **les éléments de nomenclature** : les postes d'abord, puisqu'une
///      catégorie créée se range sous le sien. « À créer » ne crée jamais un
///      second élément du même nom — s'il en existe un, c'est lui qui sert ;
///      un élément choisi qui n'existe plus est recréé ;
///   2. **les opérations**, au statut que les menus ont dit, avec la
///      vérification que les préférences donnent aux imports ; une opération
///      pointée reçoit sa date de pointage Money, ou sa date ;
///   3. **leurs ventilations**, en sous-opérations — tiers, catégorie,
///      affectation, projet et commentaire de chaque ligne ; leur somme est
///      celle de l'opération, si bien qu'aucun complément ne naît ;
///   4. **le solde d'ouverture**, si `opening` le donne et que le compte n'en
///      a pas encore ;
///   5. les trois soldes du compte.
///
/// Tout ou rien : une erreur défait l'ensemble.
pub fn import(
    conn: &mut rusqlite::Connection,
    account_id: i64,
    operations: &[&Operation],
    plan: &Plan<'_>,
    values: &[ValueRow],
    choices: &[Choice],
    opening: Option<i64>,
) -> rusqlite::Result<Outcome> {
    use crate::operations::OperationInput;
    use crate::sub_operations::{Direction, SubOperationInput};

    let transaction = conn.transaction()?;
    let tx: &rusqlite::Connection = &transaction;
    let verification = crate::preferences::import_verification(tx)?;

    // 1. Les éléments, les postes d'abord.
    let mut ids: HashMap<(Destination, String), i64> = HashMap::new();
    let mut created = Vec::new();
    let mut order: Vec<usize> = (0..values.len()).collect();
    order.sort_by_key(|index| (values[*index].destination != Destination::BudgetLine) as u8);
    for index in order {
        let row = &values[index];
        let Some(kind) = row.destination.nomenclature() else {
            continue;
        };
        let choice = choices.get(index).copied().unwrap_or(row.proposal);
        let still_there = |id: i64| -> rusqlite::Result<bool> {
            Ok(nomenclatures::get(tx, kind, id)?.is_some())
        };
        let id = match choice {
            Choice::Unspecified => nomenclatures::UNSPECIFIED,
            Choice::Existing(id) if still_there(id)? => id,
            Choice::Existing(_) | Choice::Create => match same_name_id(tx, kind, &row.label)? {
                Some(id) => id,
                None => {
                    let id = if kind == Nomenclature::Category {
                        let budget_line = row
                            .budget_line
                            .as_ref()
                            .and_then(|line| {
                                ids.get(&(Destination::BudgetLine, same_name_key(line))).copied()
                            })
                            .unwrap_or(nomenclatures::UNSPECIFIED);
                        nomenclatures::create_category(tx, &row.label, budget_line)?
                    } else {
                        nomenclatures::create(tx, kind, &row.label)?
                    };
                    created.push(Created {
                        destination: row.destination,
                        label: row.label.clone(),
                    });
                    id
                }
            },
        };
        ids.insert((row.destination, same_name_key(&row.label)), id);
    }
    let id_of = |destination: Destination, value: &Option<String>| {
        value
            .as_ref()
            .and_then(|label| ids.get(&(destination, same_name_key(label))).copied())
            .unwrap_or(nomenclatures::UNSPECIFIED)
    };
    let direction = |amount: i64| {
        if amount < 0 {
            Direction::Debit
        } else {
            Direction::Credit
        }
    };

    // 2 et 3. Les opérations et leurs ventilations.
    let mut splits = 0;
    for operation in operations {
        let routed = plan.route(&operation.line);
        let status = plan.status(operation);
        let input = OperationInput {
            label: cut(&plan.label(operation), LABEL_LENGTH),
            payment_reference: cut(routed.reference.as_deref().unwrap_or_default(), REFERENCE_LENGTH),
            date: Some(operation.date),
            clearing_date: (status == Status::Pointed)
                .then(|| operation.cleared_date.unwrap_or(operation.date)),
            direction: direction(operation.line.amount),
            amount: operation.line.amount.abs(),
            status_id: status.id(),
            category_id: id_of(Destination::Category, &routed.category),
            assignment_id: id_of(Destination::Assignment, &routed.assignment),
            payment_mode_id: id_of(Destination::PaymentMode, &routed.payment_mode),
            payee_id: id_of(Destination::Payee, &routed.payee),
            project_id: id_of(Destination::Project, &routed.project),
            verification_id: Some(verification),
            comment: routed.comment.clone(),
        };
        let parent = crate::operations::create_within(tx, account_id, &input)?;
        if operation.splits.is_empty() {
            continue;
        }
        splits += 1;
        for line in &operation.splits {
            let part = plan.route(line);
            let label = line
                .payee
                .clone()
                .or_else(|| line.memo.clone())
                .or_else(|| part.category.clone())
                .unwrap_or_else(|| input.label.clone());
            crate::sub_operations::create(
                tx,
                parent,
                &SubOperationInput {
                    label: cut(&label, LABEL_LENGTH),
                    direction: direction(line.amount),
                    amount: line.amount.abs(),
                    category_id: id_of(Destination::Category, &part.category),
                    assignment_id: id_of(Destination::Assignment, &part.assignment),
                    payee_id: id_of(Destination::Payee, &part.payee),
                    project_id: id_of(Destination::Project, &part.project),
                    comment: part.comment.clone(),
                },
            )?;
        }
    }

    // 4. Le solde d'ouverture, seulement sur un compte qui n'en a pas.
    let opening_set = match opening {
        Some(amount) if amount != 0 => {
            tx.execute(
                "UPDATE Compte SET ReportPointe = ?1 WHERE IDCompte = ?2 AND ReportPointe = 0",
                rusqlite::params![amount, account_id],
            )? > 0
        }
        _ => false,
    };

    // 5. Les soldes.
    crate::balances::update_all(tx, account_id)?;
    transaction.commit()?;
    Ok(Outcome {
        operations: operations.len(),
        splits,
        sum: operations.iter().map(|operation| operation.line.amount).sum(),
        created,
        opening_set,
    })
}

// ---------------------------------------------------------------------------
// La lecture des tables brutes
// ---------------------------------------------------------------------------

/// Une table lue en entier, ses colonnes retrouvées par leur nom.
struct Table {
    columns: HashMap<String, usize>,
    rows: Vec<Vec<Value>>,
}

impl Table {
    /// Lit une table ; une table absente est une table vide — le schéma
    /// change selon la version de Money.
    fn read(file: &MnyFile, name: &str) -> Result<Table, Problem> {
        let table = match file.table(name) {
            Ok(table) => table,
            Err(mny_reader::Error::TableNotFound(_)) => {
                return Ok(Table {
                    columns: HashMap::new(),
                    rows: Vec::new(),
                })
            }
            Err(other) => return Err(other.into()),
        };
        let columns = table
            .columns()
            .iter()
            .enumerate()
            .map(|(index, column)| (column.name.clone(), index))
            .collect();
        let mut rows = Vec::new();
        for row in table.rows()? {
            rows.push(row?.into_values());
        }
        Ok(Table { columns, rows })
    }

    fn len(&self) -> usize {
        self.rows.len()
    }

    fn cell(&self, row: usize, column: &str) -> Option<&Value> {
        self.rows.get(row)?.get(*self.columns.get(column)?)
    }

    fn int(&self, row: usize, column: &str) -> Option<i64> {
        match self.cell(row, column)? {
            Value::Byte(value) => Some(i64::from(*value)),
            Value::Int16(value) => Some(i64::from(*value)),
            Value::Int32(value) => Some(i64::from(*value)),
            Value::Int64(value) => Some(*value),
            _ => None,
        }
    }

    /// Un identifiant : Money écrit « aucun » par NULL, -1 ou 0.
    fn handle(&self, row: usize, column: &str) -> Option<i64> {
        self.int(row, column).filter(|value| *value > 0)
    }

    /// Un texte, sans ses espaces autour ; vide, il n'y en a pas.
    fn text(&self, row: usize, column: &str) -> Option<String> {
        match self.cell(row, column)? {
            Value::Text(value) => Some(value.trim().to_string()).filter(|text| !text.is_empty()),
            _ => None,
        }
    }

    /// Un montant, en micro-unités (Money le tient en dix-millièmes).
    fn money(&self, row: usize, column: &str) -> Option<i64> {
        match self.cell(row, column)? {
            Value::Money(value) => Some(value.raw() * 100),
            _ => None,
        }
    }

    fn boolean(&self, row: usize, column: &str) -> bool {
        matches!(self.cell(row, column), Some(Value::Bool(true)))
    }

    /// Une date ; la date « vide » de Money (l'an 10000) n'en est pas une.
    fn date(&self, row: usize, column: &str) -> Option<NaiveDate> {
        use chrono::Datelike;
        match self.cell(row, column)? {
            Value::DateTime(value) => {
                let date = value.to_naive()?.date();
                NaiveDate::from_ymd_opt(date.year(), date.month(), date.day())
            }
            _ => None,
        }
    }
}

/// L'arbre de `CAT` : catégories et classifications.
struct Tree {
    nodes: HashMap<i64, (String, i64, Option<i64>)>,
}

impl Tree {
    fn read(file: &MnyFile) -> Result<Tree, Problem> {
        let table = Table::read(file, "CAT")?;
        let nodes = (0..table.len())
            .filter_map(|row| {
                Some((
                    table.handle(row, "hcat")?,
                    (
                        table.text(row, "szFull").unwrap_or_default(),
                        table.int(row, "nLevel").unwrap_or(0),
                        table.handle(row, "hcatParent"),
                    ),
                ))
            })
            .collect();
        Ok(Tree { nodes })
    }

    /// Les noms du premier niveau jusqu'à l'élément, sans la racine
    /// (« DÉPENSES ») : `["Alimentation", "Épicerie"]`.
    fn path(&self, handle: i64) -> Vec<String> {
        let mut names = Vec::new();
        let mut current = Some(handle);
        // L'arbre a trois niveaux ; la borne protège d'un fichier abîmé qui
        // tournerait en rond.
        for _ in 0..16 {
            let Some((name, level, parent)) = current.and_then(|at| self.nodes.get(&at)) else {
                break;
            };
            if *level <= 0 {
                break;
            }
            names.insert(0, name.clone());
            current = *parent;
        }
        names
    }

    /// Le nom complet, « Parent : Enfant », ou le nom seul d'une racine.
    fn full_name(&self, handle: i64) -> Option<String> {
        let path = self.path(handle);
        if path.is_empty() {
            self.nodes
                .get(&handle)
                .map(|(name, _, _)| name.clone())
                .filter(|name| !name.is_empty())
        } else {
            Some(path.join(" : "))
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn date(year: i32, month: u32, day: u32) -> NaiveDate {
        NaiveDate::from_ymd_opt(year, month, day).unwrap()
    }

    fn line(amount: i64, category: Option<&str>, sub: Option<&str>, payee: Option<&str>) -> Line {
        Line {
            amount: amount * crate::money::UNIT,
            category: category.map(str::to_string),
            sub_category: sub.map(str::to_string),
            payee: payee.map(str::to_string),
            ..Line::default()
        }
    }

    fn operation(day: u32, line: Line) -> Operation {
        Operation {
            date: date(2026, 11, day),
            cleared: Cleared::No,
            cleared_date: None,
            scheduled: false,
            transfer: None,
            line,
            splits: Vec::new(),
        }
    }

    /// Un compte courant inventé, qui a tous les cas : catégorie avec et sans
    /// sous-catégorie, une sous-catégorie de même nom sous deux catégories,
    /// une ventilation, un virement, une échéance, une opération pointée.
    fn book() -> Book {
        let mut pointed = operation(2, line(-90, Some("Abonnement/factures"), Some("Eau"), Some("H2O")));
        pointed.cleared = Cleared::Reconciled;
        let mut ventilated = operation(5, line(-150, None, None, Some("Supermarché")));
        ventilated.splits = vec![
            line(-100, Some("Alimentation"), Some("Épicerie"), None),
            line(-50, Some("Maison"), Some("Divers"), None),
        ];
        let mut transfer = operation(6, line(-500, None, None, None));
        transfer.transfer = Some("LivretA".to_string());
        let mut scheduled = operation(30, line(-20, Some("Loisirs"), None, Some("Club")));
        scheduled.scheduled = true;
        let mut with_memo = operation(7, line(-12, Some("Auto"), Some("Divers"), None));
        with_memo.line.memo = Some("Lave-auto".to_string());
        with_memo.line.reference = Some("1234567".to_string());
        with_memo.line.payment_mode = Some(2);
        let mut operations = HashMap::new();
        operations.insert(
            2,
            vec![
                operation(1, line(2200, Some("Traitements et salaires"), Some("Salaire net"), Some("Salaire"))),
                pointed,
                operation(4, line(-990, Some("Impôts"), None, Some("Taxe habitation"))),
                ventilated,
                transfer,
                with_memo,
                scheduled,
            ],
        );
        Book {
            accounts: vec![Account {
                handle: 2,
                name: "Compte courant".to_string(),
                opening: 1000 * crate::money::UNIT,
                closed: false,
                currency: "EUR".to_string(),
                operations: 7,
            }],
            operations,
            investment_lines: 0,
            undated_lines: 0,
        }
    }

    /// Les propositions, avec un tiers par bénéficiaire.
    fn every_payee() -> Mapping {
        Mapping {
            payees: Payees::All,
            ..Mapping::default()
        }
    }

    #[test]
    fn les_propositions_par_defaut_sont_celles_dictees() {
        let mapping = Mapping::default();
        assert_eq!(mapping.destination(Source::Category), Destination::BudgetLine);
        assert_eq!(mapping.destination(Source::SubCategory), Destination::Category);
        assert_eq!(mapping.destination(Source::PaymentMode), Destination::PaymentMode);
        assert_eq!(mapping.destination(Source::Classification1), Destination::Assignment);
        assert_eq!(mapping.destination(Source::Classification2), Destination::Project);
        assert_eq!(mapping.destination(Source::Reference), Destination::Reference);
        assert_eq!(mapping.destination(Source::Memo), Destination::Comment);
        assert_eq!(mapping.label, LabelFrom::Payee);
        assert_eq!(mapping.payees, Payees::None, "« Non, aucun tiers »");
        assert_eq!((mapping.cleared, mapping.not_cleared), (Status::Pointed, Status::Committed));
        assert_eq!(mapping.scheduled, Scheduled::Skip);
        assert_eq!(mapping.check(), Ok(()));
        // Chaque proposition est dans le menu de sa donnée.
        for source in SOURCES {
            assert!(source.destinations().contains(&source.default_destination()));
            assert!(source.destinations().contains(&Destination::Ignore), "« Ne pas importer » partout");
            // Les tiers ne viennent que du bénéficiaire, par sa question.
            assert!(!source.destinations().contains(&Destination::Payee), "{source:?}");
        }
        assert!(mapping.conflicts().is_empty());
    }

    #[test]
    fn les_clefs_font_l_aller_retour() {
        for source in SOURCES {
            assert_eq!(Source::from_key(source.key()), Some(source));
            for destination in source.destinations() {
                assert_eq!(Destination::from_key(destination.key()), Some(*destination));
            }
        }
        for one in LabelFrom::ALL {
            assert_eq!(LabelFrom::from_key(one.key()), Some(one));
        }
        for one in Status::ALL {
            assert_eq!(Status::from_key(one.key()), Some(one));
        }
        for one in Scheduled::ALL {
            assert_eq!(Scheduled::from_key(one.key()), Some(one));
        }
        for one in Payees::ALL {
            assert_eq!(Payees::from_key(one.key()), Some(one));
        }
        assert_eq!(Source::from_key("payee"), None, "le bénéficiaire n'a plus de menu");
        assert_eq!(Source::from_key("rien"), None);
        assert_eq!(Destination::from_key("rien"), None);
    }

    #[test]
    fn deux_donnees_ne_vont_pas_dans_la_meme_case() {
        let mut mapping = Mapping::default();
        mapping.set(Source::Classification2, Destination::Assignment);
        assert_eq!(
            mapping.check(),
            Err(Refusal::SameDestination {
                first: Source::Classification1,
                second: Source::Classification2,
                destination: Destination::Assignment,
            })
        );
        // Les deux lignes passent en rouge, et elles seules.
        assert_eq!(mapping.conflicts(), vec![Source::Classification1, Source::Classification2]);
        // « Ne pas importer » n'est pas une case : plusieurs peuvent y aller.
        let mut mapping = Mapping::default();
        mapping.set(Source::Classification1, Destination::Ignore);
        mapping.set(Source::Memo, Destination::Ignore);
        assert_eq!(mapping.check(), Ok(()));
        assert!(mapping.conflicts().is_empty());
    }

    #[test]
    fn une_note_ne_devient_pas_un_classement() {
        let mut mapping = Mapping::default();
        mapping.set(Source::Memo, Destination::Payee);
        assert_eq!(
            mapping.check(),
            Err(Refusal::NotOffered {
                source: Source::Memo,
                destination: Destination::Payee,
            })
        );
        // Ni une classification : les tiers ne viennent que du bénéficiaire.
        let mut mapping = Mapping::default();
        mapping.set(Source::Classification1, Destination::Payee);
        assert!(matches!(mapping.check(), Err(Refusal::NotOffered { .. })));
    }

    #[test]
    fn un_poste_sans_categorie_est_refuse() {
        let mut mapping = Mapping::default();
        mapping.set(Source::SubCategory, Destination::Ignore);
        assert_eq!(mapping.check(), Err(Refusal::BudgetLineWithoutCategory));
        // Sans poste du tout, la catégorie seule est permise.
        mapping.set(Source::Category, Destination::Category);
        assert_eq!(mapping.check(), Ok(()));
    }

    #[test]
    fn une_ligne_se_range_dans_les_cases_choisies() {
        let book = book();
        let mapping = Mapping::default();
        let operations = selected(&book, 2, &mapping);
        let plan = Plan::new(&operations, &mapping, Language::French);
        let salary = plan.route(&operations[0].line);
        assert_eq!(salary.budget_line.as_deref(), Some("Traitements et salaires"));
        assert_eq!(salary.category.as_deref(), Some("Salaire net"));
        assert_eq!(salary.payee, None, "aucun tiers par défaut");
        // Sans sous-catégorie, la catégorie prend le nom du poste.
        let tax = plan.route(&operations[2].line);
        assert_eq!(tax.budget_line.as_deref(), Some("Impôts"));
        assert_eq!(tax.category.as_deref(), Some("Impôts"));
        // La note, la référence et le mode de paiement.
        let wash = plan.route(&operations[5].line);
        assert_eq!(wash.comment.as_deref(), Some("Lave-auto"));
        assert_eq!(wash.reference.as_deref(), Some("1234567"));
        assert_eq!(wash.payment_mode.as_deref(), Some("Mode de paiement Money n° 2"));
    }

    #[test]
    fn une_sous_categorie_de_meme_nom_sous_deux_categories_prend_son_nom_complet() {
        let book = book();
        let mapping = Mapping::default();
        let operations = selected(&book, 2, &mapping);
        let plan = Plan::new(&operations, &mapping, Language::French);
        // « Divers » est sous « Maison » (ventilation) et sous « Auto ».
        assert_eq!(plan.route(&operations[3].splits[1]).category.as_deref(), Some("Maison : Divers"));
        assert_eq!(plan.route(&operations[5].line).category.as_deref(), Some("Auto : Divers"));
        // Une sous-catégorie unique garde son nom court.
        assert_eq!(plan.route(&operations[3].splits[0]).category.as_deref(), Some("Épicerie"));
    }

    #[test]
    fn le_menu_change_le_rangement() {
        let book = book();
        let mut mapping = Mapping::default();
        mapping.set(Source::Category, Destination::Category);
        mapping.set(Source::SubCategory, Destination::Comment);
        mapping.set(Source::Memo, Destination::Ignore);
        assert_eq!(mapping.check(), Ok(()));
        let operations = selected(&book, 2, &mapping);
        let plan = Plan::new(&operations, &mapping, Language::French);
        let salary = plan.route(&operations[0].line);
        assert_eq!(salary.budget_line, None);
        assert_eq!(salary.category.as_deref(), Some("Traitements et salaires"));
        assert_eq!(salary.comment.as_deref(), Some("Salaire net"));
    }

    #[test]
    fn le_libelle_suit_son_menu() {
        let book = book();
        let operations = selected(&book, 2, &Mapping::default());
        let wash = operations[5];
        let mut mapping = Mapping::default();
        let label = |mapping: &Mapping, operation: &Operation| {
            Plan::new(&operations, mapping, Language::French).label(operation)
        };
        // Pas de tiers : le libellé prend la note.
        assert_eq!(label(&mapping, wash), "Lave-auto");
        assert_eq!(label(&mapping, operations[0]), "Salaire");
        mapping.label = LabelFrom::PayeeAndMemo;
        let mut both = operations[0].clone();
        both.line.memo = Some("novembre".to_string());
        assert_eq!(label(&mapping, &both), "Salaire novembre");
        mapping.label = LabelFrom::Memo;
        assert_eq!(label(&mapping, &both), "novembre");
        // Un virement sans tiers ni note dit vers quel compte.
        assert_eq!(label(&mapping, operations[4]), "Virement vers LivretA");
        let mut back = operations[4].clone();
        back.line.amount = 500 * crate::money::UNIT;
        assert_eq!(label(&mapping, &back), "Virement de LivretA");
        // Rien du tout : un nom neutre, jamais un libellé vide.
        assert_eq!(label(&mapping, &operation(9, line(-1, None, None, None))), "Opération Money");
    }

    #[test]
    fn le_statut_suit_le_pointage_et_les_menus() {
        let book = book();
        let mut mapping = Mapping {
            scheduled: Scheduled::AsPlanned,
            ..Mapping::default()
        };
        let operations = selected(&book, 2, &mapping);
        let plan = Plan::new(&operations, &mapping, Language::French);
        assert_eq!(plan.status(operations[0]), Status::Committed, "non pointée");
        assert_eq!(plan.status(operations[1]), Status::Pointed, "rapprochée");
        assert_eq!(plan.status(operations[6]), Status::Planned, "échéance");
        mapping.not_cleared = Status::Planned;
        mapping.cleared = Status::Committed;
        let plan = Plan::new(&operations, &mapping, Language::French);
        assert_eq!(plan.status(operations[0]), Status::Planned);
        assert_eq!(plan.status(operations[1]), Status::Committed);
        assert_eq!((Status::Pointed.id(), Status::Committed.id(), Status::Planned.id()), (1, 2, 3));
    }

    #[test]
    fn les_echeances_ne_viennent_que_si_on_les_demande() {
        let book = book();
        let preview = preview(&book, 2, &Mapping::default(), Language::French, PREVIEW_LIMIT);
        assert_eq!((preview.total, preview.scheduled_skipped), (6, 1));
        let mapping = Mapping {
            scheduled: Scheduled::AsPlanned,
            ..Mapping::default()
        };
        let preview = super::preview(&book, 2, &mapping, Language::French, PREVIEW_LIMIT);
        assert_eq!((preview.total, preview.scheduled_skipped), (7, 0));
        assert_eq!(preview.rows[6].status, Status::Planned);
    }

    #[test]
    fn l_apercu_montre_au_plus_sa_limite_et_compte_tout() {
        let book = book();
        let preview = preview(&book, 2, &Mapping::default(), Language::French, 3);
        assert_eq!(preview.rows.len(), 3);
        assert_eq!(preview.total, 6);
        assert_eq!(preview.sum, (2200 - 90 - 990 - 150 - 500 - 12) * crate::money::UNIT);
        let full = super::preview(&book, 2, &Mapping::default(), Language::French, PREVIEW_LIMIT);
        assert_eq!(full.rows[3].splits, 2, "la ventilation est annoncée");
        assert!(full.rows[4].transfer);
        // Un compte inconnu n'a rien.
        assert_eq!(super::preview(&book, 99, &Mapping::default(), Language::French, 10).total, 0);
    }

    #[test]
    fn chaque_valeur_est_proposee_a_son_element_de_meme_nom_sinon_a_creer() {
        let book = book();
        let mapping = every_payee();
        let operations = selected(&book, 2, &mapping);
        let plan = Plan::new(&operations, &mapping, Language::French);
        let existing = Existing {
            // Casse et accents ignorés, comme partout dans Radinus.
            budget_lines: vec![NamedItem { id: 4, label: "IMPOTS".to_string() }],
            categories: vec![NamedItem { id: 7, label: "epicerie".to_string() }],
            payees: vec![NamedItem { id: 3, label: "Salaire".to_string() }],
            ..Existing::default()
        };
        let rows = values(&operations, &plan, &existing);
        let find = |destination, label: &str| {
            rows.iter()
                .find(|row| row.destination == destination && row.label == label)
                .unwrap_or_else(|| panic!("{label} absent de {rows:#?}"))
        };
        assert_eq!(find(Destination::BudgetLine, "Impôts").proposal, Choice::Existing(4));
        assert_eq!(find(Destination::Category, "Épicerie").proposal, Choice::Existing(7));
        assert_eq!(find(Destination::Payee, "Salaire").proposal, Choice::Existing(3));
        assert_eq!(find(Destination::Payee, "H2O").proposal, Choice::Create);
        // Une catégorie dit sous quel poste elle serait créée.
        assert_eq!(
            find(Destination::Category, "Maison : Divers").budget_line.as_deref(),
            Some("Maison")
        );
        assert_eq!(find(Destination::Category, "Impôts").budget_line.as_deref(), Some("Impôts"));
        // Les lignes d'une ventilation comptent ; l'échéance écartée, non.
        assert!(rows.iter().all(|row| row.label != "Loisirs" && row.label != "Club"));
        // Les postes d'abord, puis les catégories, puis les tiers…
        let order: Vec<Destination> = rows.iter().map(|row| row.destination).collect();
        let mut sorted = order.clone();
        sorted.sort_by_key(|destination| CLASSING.iter().position(|one| one == destination));
        assert_eq!(order, sorted);
    }

    #[test]
    fn une_valeur_portee_par_plusieurs_lignes_n_apparait_qu_une_fois() {
        let mut book = book();
        book.operations.get_mut(&2).unwrap().push(operation(8, line(-15, Some("Abonnement/factures"), Some("eau"), Some("h2o"))));
        let mapping = every_payee();
        let operations = selected(&book, 2, &mapping);
        let plan = Plan::new(&operations, &mapping, Language::French);
        let rows = values(&operations, &plan, &Existing::default());
        let water: Vec<&ValueRow> = rows
            .iter()
            .filter(|row| row.destination == Destination::Payee && same_name_key(&row.label) == "h2o")
            .collect();
        assert_eq!(water.len(), 1);
        assert_eq!(water[0].uses, 2);
    }

    #[test]
    fn les_tiers_suivent_leur_question_et_le_libelle_reste() {
        let mut book = book();
        // « H2O » revient trois fois, « Salaire » une seule.
        let more = book.operations.get_mut(&2).unwrap();
        more.push(operation(10, line(-30, None, None, Some("H2O"))));
        more.push(operation(11, line(-31, None, None, Some("h2o"))));
        let payee_of = |payees: Payees, index: usize| {
            let mapping = Mapping {
                payees,
                ..Mapping::default()
            };
            let operations = selected(&book, 2, &mapping);
            let plan = Plan::new(&operations, &mapping, Language::French);
            assert_eq!(plan.label(operations[0]), "Salaire", "le bénéficiaire reste le libellé");
            plan.route(&operations[index].line).payee
        };
        assert_eq!(payee_of(Payees::None, 0), None);
        assert_eq!(payee_of(Payees::None, 1), None);
        assert_eq!(payee_of(Payees::Frequent, 0), None, "une seule fois");
        assert_eq!(payee_of(Payees::Frequent, 1).as_deref(), Some("H2O"), "trois fois");
        assert_eq!(payee_of(Payees::All, 0).as_deref(), Some("Salaire"));
        // Sans tiers, l'étape 3 n'en propose aucun, et l'import n'en crée pas.
        let mut conn = database();
        let outcome = imported(&mut conn, &Mapping::default(), |row| row.proposal, None);
        assert!(outcome.created.iter().all(|one| one.destination != Destination::Payee));
        let with_payee: i64 = conn
            .query_row("SELECT COUNT(*) FROM Operation WHERE IDCompte = 1 AND IDTiers <> 0", [], |row| row.get(0))
            .unwrap();
        assert_eq!(with_payee, 0);
    }

    #[test]
    fn l_etape_2_montre_des_exemples_et_des_nombres() {
        let mut book = book();
        book.operations.get_mut(&2).unwrap().push(operation(10, line(-30, Some("Alimentation"), None, Some("H2O"))));
        book.operations.get_mut(&2).unwrap().push(operation(11, line(-31, None, None, Some("h2o"))));
        let samples = samples(&book, 2, Language::French);
        assert_eq!(samples.sources.len(), SOURCES.len());
        let (source, category) = &samples.sources[0];
        assert_eq!(*source, Source::Category);
        // Ventilation et échéance comprises : 8 lignes, 7 catégories.
        assert_eq!((category.lines, category.distinct), (8, 7));
        assert_eq!(category.examples[0], ("Alimentation".to_string(), 2), "la plus fréquente d'abord");
        assert_eq!(category.examples.len(), SAMPLE_LIMIT);
        assert_eq!(category.examples[1].0, "Abonnement/factures", "puis dans l'ordre alphabétique");
        // Une donnée absente : rien, et l'étape 2 la grise.
        let absent = &samples.sources[SOURCES.iter().position(|one| *one == Source::Classification1).unwrap()].1;
        assert_eq!(*absent, Sample::default());
        // Les bénéficiaires : 5 différents, dont un qui revient 3 fois.
        assert_eq!((samples.payees.distinct, samples.frequent_payees), (5, 1));
        assert_eq!(samples.payees.examples[0], ("H2O".to_string(), 3));
        assert_eq!((samples.cleared, samples.not_cleared, samples.scheduled), (1, 7, 1));
    }

    /// Les fichiers d'exemple de Fabrice, là où ils sont, hors du dépôt
    /// (`MNY_EXAMPLES` peut désigner un autre dossier). Sans eux, le test le
    /// dit et passe.
    fn examples() -> Vec<std::path::PathBuf> {
        let dir = std::env::var_os("MNY_EXAMPLES")
            .map(std::path::PathBuf::from)
            .unwrap_or_else(|| {
                std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR"))
                    .join("../../Analyse/mnyimport/Exemples mny")
            });
        let Ok(entries) = std::fs::read_dir(&dir) else {
            eprintln!("dossier d'exemples absent ({}) : test ignoré", dir.display());
            return Vec::new();
        };
        let mut files: Vec<_> = entries
            .filter_map(|entry| entry.ok().map(|entry| entry.path()))
            .filter(|path| path.extension().is_some_and(|ext| ext.eq_ignore_ascii_case("mny")))
            .collect();
        files.sort();
        files
    }

    #[test]
    fn les_exemples_de_fabrice_se_lisent() {
        for path in examples() {
            let name = path.display().to_string();
            let book = Book::open(&path, None).unwrap_or_else(|problem| panic!("{name} : {problem:?}"));
            assert!(!book.accounts.is_empty(), "{name} : aucun compte");
            assert!(
                book.accounts.iter().all(|account| !account.name.starts_with("Placements")),
                "{name} : un compte de placements est proposé"
            );
            for account in &book.accounts {
                assert_eq!(account.currency, "EUR", "{name}");
                let preview = preview(&book, account.handle, &Mapping::default(), Language::French, PREVIEW_LIMIT);
                assert_eq!(preview.total, account.operations, "{name}, {}", account.name);
                assert!(preview.rows.iter().all(|row| !row.label.is_empty()));
            }
            // « Archivage 2 comptes » : le compte courant et le livret.
            if name.ends_with("Archivage 2 comptes.mny") {
                let names: Vec<&str> = book.accounts.iter().map(|account| account.name.as_str()).collect();
                assert_eq!(names, ["Compte courant", "LivretA"]);
                assert_eq!(book.accounts[0].opening, 999_900 * crate::money::UNIT);
                assert_eq!((book.accounts[0].operations, book.accounts[1].operations), (4, 2));
                let preview = preview(&book, book.accounts[0].handle, &Mapping::default(), Language::French, PREVIEW_LIMIT);
                let carrots = preview
                    .rows
                    .iter()
                    .find(|row| row.label == "Carottes")
                    .expect("les carottes");
                assert_eq!(carrots.amount, -10 * crate::money::UNIT);
                assert_eq!(carrots.routed.budget_line.as_deref(), Some("Alimentation"));
                assert_eq!(carrots.routed.category.as_deref(), Some("Épicerie"));
                assert_eq!(carrots.routed.payee.as_deref(), Some("Carottes"));
                assert_eq!(carrots.status, Status::Committed);
            }
        }
    }

    /// Chaque mot de l'assistant est dit dans les dix-huit langues, et se
    /// compose : aucune accolade ne reste, aucun message ne sort vide.
    #[test]
    fn chaque_mot_de_l_assistant_est_dit_dans_toutes_les_langues() {
        let french = include_str!("../i18n/fr.ftl");
        let keys: Vec<&str> = french
            .lines()
            .filter_map(|line| line.split_once(" = ").map(|(key, _)| key))
            .filter(|key| {
                key.starts_with("mny-")
                    || key.starts_with("window-mny-import-title-")
                    || *key == "menu-file-import-mny"
            })
            .collect();
        assert!(keys.len() > 70, "{}", keys.len());
        for language in Language::all() {
            for key in &keys {
                let text = i18n::message_of(
                    language,
                    key,
                    &[
                        ("account", "CCP"),
                        ("opening", "1,00"),
                        ("sum", "2,00"),
                        ("detail", "x"),
                        ("first", "a"),
                        ("second", "b"),
                        ("source", "c"),
                        ("destination", "d"),
                        ("before", "1"),
                        ("after", "2"),
                        ("from", "01/01/2026"),
                        ("to", "02/01/2026"),
                        ("code", "3"),
                        ("amount", "4,00"),
                        ("label", "e"),
                        ("value", "Alimentation"),
                    ],
                    &[("count", 2), ("shown", 200), ("splits", 0), ("frequent", 1), ("min", 3)],
                );
                assert!(!text.trim().is_empty(), "{key} vide en {language:?}");
                assert!(!text.contains('{') && !text.contains('}'), "{key} en {language:?} : {text}");
            }
        }
        // Les exemples de l'étape 2.
        let sample = i18n::message_of(Language::French, "mny-sample-value", &[("value", "Alimentation")], &[("count", 3)]);
        assert_eq!(sample, "Alimentation (3 lignes)");
        let sample = i18n::message_of(Language::French, "mny-sample-value", &[("value", "Épicerie")], &[("count", 1)]);
        assert_eq!(sample, "Épicerie (1 ligne)");
        let payees = i18n::message_of(
            Language::French,
            "mny-sample-payees",
            &[],
            &[("count", 312), ("frequent", 18), ("min", FREQUENT as i64)],
        );
        assert_eq!(payees, "Bénéficiaires différents : 312, dont 18 présents au moins 3 fois");
        // Le pluriel et le zéro des ventilations.
        let one = i18n::message_of(Language::French, "mny-recap-operations", &[("sum", "5,00 €")], &[("count", 1), ("splits", 0)]);
        assert_eq!(one, "1 opération sera importée, pour une somme de 5,00 €.");
        let split = i18n::message_of(Language::French, "mny-recap-operations", &[("sum", "5,00 €")], &[("count", 3), ("splits", 2)]);
        assert_eq!(split, "3 opérations seront importées, pour une somme de 5,00 €, dont 2 ventilées.");
    }

    fn database() -> rusqlite::Connection {
        use crate::database::{schema, seed};
        let conn = rusqlite::Connection::open_in_memory().unwrap();
        schema::migrate(&conn).unwrap();
        seed::seed_initial_data(&conn).unwrap();
        conn.execute(
            "INSERT INTO Compte (IDCompte, ReportPointe, ReportEngage, ReportPrevu, Libelle,
                IDTypeCompte, IDBanques, SoldeBanque, SoldeReel, SoldeFinal, NomTitulaire,
                AdresseTitulaire, COBCodeBanque, COBCodeGuichet, COBNumCompte, COBClefRIB,
                COBIBAN, DateOuverture, DateCloture, AdresseAgenceBank, COBBIC,
                NumProchCheque, CompteCloture, Devise)
             VALUES (1, 0, 0, 0, 'CCP', 1, 21, 0, 0, 0, '', '', '', '', '', '', '',
                     NULL, NULL, '', '', 0, 0, 'EUR')",
            [],
        )
        .unwrap();
        conn
    }

    /// Importe le compte courant inventé avec les propositions, sauf ce que
    /// `choose` change à l'étape 3.
    fn imported(
        conn: &mut rusqlite::Connection,
        mapping: &Mapping,
        choose: impl Fn(&ValueRow) -> Choice,
        opening: Option<i64>,
    ) -> Outcome {
        let book = book();
        let operations = selected(&book, 2, mapping);
        let plan = Plan::new(&operations, mapping, Language::French);
        let rows = values(&operations, &plan, &Existing::read(conn).unwrap());
        let choices: Vec<Choice> = rows.iter().map(&choose).collect();
        import(conn, 1, &operations, &plan, &rows, &choices, opening).unwrap()
    }

    fn named(conn: &rusqlite::Connection, kind: Nomenclature, label: &str) -> Option<i64> {
        same_name_id(conn, kind, label).unwrap()
    }

    #[test]
    fn l_import_ecrit_les_operations_les_elements_et_les_soldes() {
        let mut conn = database();
        let outcome = imported(&mut conn, &every_payee(), |row| row.proposal, None);
        assert_eq!((outcome.operations, outcome.splits), (6, 1));
        assert_eq!(outcome.sum, (2200 - 90 - 990 - 150 - 500 - 12) * crate::money::UNIT);
        // Les éléments : la catégorie se range sous son poste.
        let food = named(&conn, Nomenclature::BudgetLine, "Alimentation").expect("le poste");
        let grocery = named(&conn, Nomenclature::Category, "Épicerie").expect("la catégorie");
        assert_eq!(nomenclatures::get_category(&conn, grocery).unwrap().unwrap().budget_line_id, food);
        // « Impôts » seule : une catégorie du nom du poste. La base de départ
        // en a déjà une, sous « Taxes » : c'est elle qui sert, et elle garde
        // son poste.
        assert!(named(&conn, Nomenclature::BudgetLine, "Impôts").is_some());
        let tax = named(&conn, Nomenclature::Category, "Impôts").expect("la catégorie");
        let taxes = named(&conn, Nomenclature::BudgetLine, "Taxes").unwrap();
        assert_eq!(nomenclatures::get_category(&conn, tax).unwrap().unwrap().budget_line_id, taxes);
        assert!(!outcome.created.iter().any(|one| one.destination == Destination::Category && one.label == "Impôts"));
        assert!(named(&conn, Nomenclature::Category, "Auto : Divers").is_some());
        assert!(named(&conn, Nomenclature::Category, "Maison : Divers").is_some());
        assert!(named(&conn, Nomenclature::Payee, "H2O").is_some());
        assert!(named(&conn, Nomenclature::PaymentMode, "Mode de paiement Money n° 2").is_some());
        assert!(outcome.created.iter().any(|one| one.destination == Destination::Payee && one.label == "H2O"));

        // Les opérations, leurs statuts, leurs dates de pointage.
        let rows: Vec<(String, i64, i64, Option<String>, String)> = {
            let mut statement = conn
                .prepare(
                    "SELECT Libelle, Montant, IDStatutOperation, DatePointage, ReferencePaiement
                     FROM Operation WHERE IDCompte = 1 AND IDOperationParent = 0 ORDER BY Date, IDOperation",
                )
                .unwrap();
            statement
                .query_map([], |row| Ok((row.get(0)?, row.get(1)?, row.get(2)?, row.get(3)?, row.get(4)?)))
                .unwrap()
                .collect::<rusqlite::Result<_>>()
                .unwrap()
        };
        assert_eq!(rows.len(), 6, "l'échéance n'est pas importée");
        assert_eq!(rows[0].0, "Salaire");
        assert_eq!(rows[0].1, 2200 * crate::money::UNIT);
        assert_eq!(rows[0].2, Status::Committed.id());
        assert_eq!(rows[0].3, None, "une opération engagée n'a pas de date de pointage");
        assert_eq!(rows[1].2, Status::Pointed.id(), "rapprochée dans Money");
        assert_eq!(rows[1].3.as_deref(), Some("2026-11-02"), "pointée à sa date");
        assert_eq!(rows[1].1, -90 * crate::money::UNIT);
        assert_eq!(rows[4].0, "Virement vers LivretA");
        assert_eq!(rows[5].4, "1234567", "la référence");

        // La ventilation : deux sous-opérations, sans complément.
        let children: Vec<(String, i64, i64)> = {
            let mut statement = conn
                .prepare(
                    "SELECT Libelle, Montant, EstComplement FROM Operation
                     WHERE IDOperationParent <> 0 ORDER BY IDOperation",
                )
                .unwrap();
            statement
                .query_map([], |row| Ok((row.get(0)?, row.get(1)?, row.get(2)?)))
                .unwrap()
                .collect::<rusqlite::Result<_>>()
                .unwrap()
        };
        assert_eq!(children.len(), 2, "{children:?}");
        assert_eq!(children[0].1 + children[1].1, -150 * crate::money::UNIT);
        assert!(children.iter().all(|child| child.2 == 0), "aucun complément");

        // La note en commentaire.
        let comment: String = conn
            .query_row(
                "SELECT c.CommentaireTxt FROM Commentaire c JOIN Operation o ON o.IDOperation = c.IDOperation
                 WHERE o.Libelle = 'Lave-auto'",
                [],
                |row| row.get(0),
            )
            .unwrap();
        assert_eq!(comment, "Lave-auto");

        // Les soldes suivent.
        let account = crate::accounts::get(&conn, 1).unwrap().unwrap();
        assert_eq!(account.balance_final, outcome.sum);
        assert_eq!(account.balance_bank, -90 * crate::money::UNIT, "seule la pointée");
    }

    #[test]
    fn les_choix_de_l_etape_3_sont_obeis() {
        let mut conn = database();
        let existing_payee = nomenclatures::create(&conn, Nomenclature::Payee, "Eau du robinet").unwrap();
        // « Non précisé » pour les postes ; « H2O » versé dans un tiers
        // existant ; un « à créer » qui porte un nom déjà là ne le double pas.
        nomenclatures::create(&conn, Nomenclature::Payee, "salaire").unwrap();
        let outcome = imported(
            &mut conn,
            &every_payee(),
            |row| match (row.destination, row.label.as_str()) {
                (Destination::BudgetLine, _) => Choice::Unspecified,
                (Destination::Payee, "H2O") => Choice::Existing(existing_payee),
                (Destination::Payee, "Salaire") => Choice::Create,
                _ => row.proposal,
            },
            None,
        );
        assert!(named(&conn, Nomenclature::BudgetLine, "Alimentation").is_none());
        let grocery = named(&conn, Nomenclature::Category, "Épicerie").unwrap();
        assert_eq!(
            nomenclatures::get_category(&conn, grocery).unwrap().unwrap().budget_line_id,
            nomenclatures::UNSPECIFIED
        );
        assert!(named(&conn, Nomenclature::Payee, "H2O").is_none());
        let payees = nomenclatures::list(&conn, Nomenclature::Payee).unwrap();
        assert_eq!(payees.iter().filter(|one| same_name_key(&one.label) == "salaire").count(), 1);
        let water: i64 = conn
            .query_row("SELECT IDTiers FROM Operation WHERE Montant = ?1", [-90 * crate::money::UNIT], |row| row.get(0))
            .unwrap();
        assert_eq!(water, existing_payee);
        assert!(outcome.created.iter().all(|one| one.destination != Destination::BudgetLine));
    }

    #[test]
    fn le_solde_d_ouverture_n_est_repris_que_sur_un_compte_qui_n_en_a_pas() {
        let mut conn = database();
        let outcome = imported(&mut conn, &Mapping::default(), |row| row.proposal, Some(1000 * crate::money::UNIT));
        assert!(outcome.opening_set);
        let account = crate::accounts::get(&conn, 1).unwrap().unwrap();
        assert_eq!(account.opening_balance_pointed, 1000 * crate::money::UNIT);
        assert_eq!(account.balance_final, 1000 * crate::money::UNIT + outcome.sum);

        let mut conn = database();
        conn.execute("UPDATE Compte SET ReportPointe = 5 WHERE IDCompte = 1", []).unwrap();
        let outcome = imported(&mut conn, &Mapping::default(), |row| row.proposal, Some(1000 * crate::money::UNIT));
        assert!(!outcome.opening_set, "un solde initial déjà saisi n'est pas écrasé");
        assert_eq!(crate::accounts::get(&conn, 1).unwrap().unwrap().opening_balance_pointed, 5);
    }

    /// **De bout en bout, sur les exemples de Fabrice** : chaque compte de
    /// chaque fichier, importé avec les propositions et son solde
    /// d'ouverture dans un compte vide, donne un solde final égal au solde
    /// d'ouverture Money plus ses opérations, au centime.
    #[test]
    fn les_exemples_s_importent_au_centime() {
        for path in examples() {
            let name = path.display().to_string();
            let book = Book::open(&path, None).unwrap();
            for account in &book.accounts {
                let mut conn = database();
                let mapping = Mapping::default();
                let operations = selected(&book, account.handle, &mapping);
                let plan = Plan::new(&operations, &mapping, Language::French);
                let rows = values(&operations, &plan, &Existing::read(&conn).unwrap());
                let choices: Vec<Choice> = rows.iter().map(|row| row.proposal).collect();
                let outcome = import(&mut conn, 1, &operations, &plan, &rows, &choices, Some(account.opening)).unwrap();
                assert_eq!(outcome.operations, account.operations, "{name}, {}", account.name);
                let stored = crate::accounts::get(&conn, 1).unwrap().unwrap();
                assert_eq!(
                    stored.balance_final,
                    account.opening + outcome.sum,
                    "{name}, {} : le solde final",
                    account.name
                );
                let count: i64 = conn
                    .query_row("SELECT COUNT(*) FROM Operation WHERE IDCompte = 1 AND IDOperationParent = 0", [], |row| row.get(0))
                    .unwrap();
                assert_eq!(count as usize, account.operations, "{name}, {}", account.name);
            }
        }
    }

    #[test]
    fn un_fichier_qui_n_est_pas_money_est_refuse() {
        let path = std::env::temp_dir().join(format!("radinus-pas-money-{}.mny", std::process::id()));
        std::fs::write(&path, vec![0u8; 4096 * 4]).unwrap();
        let result = Book::open(&path, None);
        std::fs::remove_file(&path).ok();
        assert_eq!(result.unwrap_err(), Problem::NotMoney);
    }
}
