//! Partager une dépense — F48 (Fabrice, 10–11/10/2026), `docs/Decisions.md` P-71.
//!
//! « Un outil de partage de dépense : partager une somme avec des
//! contraintes. » **Qui paie quoi ?** Une somme — une addition, une location,
//! un voyage en car — partagée entre des personnes, selon une règle, avec des
//! contraintes, puis suivie règlement après règlement.
//!
//! **Une calculette** : rien n'est lu ni écrit dans la base, si bien que
//! l'outil marche sans base ouverte (« oui on peut utiliser l'outil sans base
//! ouverte »). Ce qui doit durer part dans un fichier : un projet en JSON, trois
//! rapports PDF, un classeur Excel.
//!
//! # La méthode
//!
//! - **Toutes les règles sont des poids** : parts égales (1), parts, pourcentages,
//!   revenus. Le calcul n'a qu'une façon de partager : chacun paie selon son
//!   poids, poste par poste, parmi ceux qui participent au poste.
//! - **Les pourcentages doivent faire 100 %**, sinon le calcul est refusé
//!   (« doit faire 100 % donc refuser ») — là où ils sont tapés.
//! - **Une fourchette par personne** : plancher, plafond ; un montant fixe est
//!   un plancher égal au plafond. Une personne qui sort de sa fourchette voit
//!   son poids multiplié — à la baisse ou à la hausse — dans chacun de ses
//!   postes, jusqu'à ce que son total tombe sur la borne : ce qu'elle ne paie
//!   pas retombe sur les autres participants de ces postes, selon leur poids,
//!   et personne ne paie un poste auquel il ne participe pas.
//! - **Hors postes** : un montant qu'une personne doit payer au-delà de ses
//!   postes — un acompte gardé après un désistement, un cadeau plus gros que ce
//!   qu'elle a consommé — se déduit des autres postes, en proportion de leur
//!   montant.
//! - **« Pour lui seul »** est toujours payé par la personne, hors fourchette.
//! - **L'arrondi** : au centime, chaque poste tombe juste ; à l'euro, chacun
//!   paie un compte rond et une seule personne garde les centimes quand le
//!   total n'est pas rond.
//! - **Les règlements** se comptent par foyer ; « offert » fait d'un surplus un
//!   cadeau ; les virements ne sont proposés qu'une fois tout payé.

use std::collections::BTreeMap;

use crate::domain::NaiveDate;
use crate::i18n::{self, Language};
use crate::money;
use crate::printing::{self, Failure};
use crate::sheets::{Sheet, SheetCell};

/// Au plus 40 personnes, « grosso modo la contenance d'un bus ».
pub const PEOPLE_LIMIT: usize = 40;
/// Au plus 20 postes, sans compter le poste commun.
pub const ITEMS_LIMIT: usize = 20;
/// Au plus 400 règlements : dix par personne en moyenne.
pub const PAYMENTS_LIMIT: usize = 400;
/// L'identifiant du poste « Commun », ce qui reste du total.
pub const COMMON_ID: u32 = 0;

/// Un centime, en micro-unités.
const CENT: i64 = money::UNIT / 100;

// --- Ce qui est tapé --------------------------------------------------------------

/// Une personne telle que tapée. Son identifiant ne change jamais : c'est lui,
/// et non le nom, qui relie la personne à ses cases et à ses règlements.
#[derive(Debug, Clone, Default, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
#[serde(default)]
pub struct PersonInput {
    pub id: u32,
    pub name: String,
    pub household: String,
    pub income: String,
    pub parts: String,
    pub percent: String,
    pub floor: String,
    pub cap: String,
    pub fixed: String,
    pub alone: String,
    pub gift: bool,
}

/// La case d'une personne dans un poste : participe-t-elle, et, pour un poste en
/// parts ou en pourcentages, sa valeur propre.
#[derive(Debug, Clone, Default, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
#[serde(default)]
pub struct CellInput {
    pub person: u32,
    pub takes: bool,
    pub value: String,
}

/// Un poste tel que tapé. Le poste commun a l'identifiant 0, et ni libellé ni
/// montant : il est ce qui reste du total.
#[derive(Debug, Clone, Default, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
#[serde(default)]
pub struct ItemInput {
    pub id: u32,
    pub label: String,
    pub amount: String,
    pub rule: String,
    pub cells: Vec<CellInput>,
}

/// Un règlement tel que tapé ; la date au format ISO du champ date.
#[derive(Debug, Clone, Default, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
#[serde(default)]
pub struct PaymentInput {
    pub id: u32,
    pub person: u32,
    pub amount: String,
    pub date: String,
    pub label: String,
}

/// **Le partage tel que tapé** — les champs ne se lisent qu'ici.
#[derive(Debug, Clone, Default, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
#[serde(default)]
pub struct Input {
    pub label: String,
    pub total: String,
    /// `whole` : une règle pour toute la dépense ; `item` : une par poste.
    pub mode: String,
    /// La règle de toute la dépense.
    pub rule: String,
    /// `cent` ou `euro`.
    pub rounding: String,
    /// Montrer les revenus dans les rapports et le classeur. Faux par défaut :
    /// « Masquer les revenus » est cochée.
    pub show_incomes: bool,
    pub people: Vec<PersonInput>,
    pub common: ItemInput,
    pub items: Vec<ItemInput>,
    pub payments: Vec<PaymentInput>,
}

// --- Ce qui est lu ----------------------------------------------------------------

/// La règle d'un partage : quatre façons de donner un poids.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Rule {
    Equal,
    Parts,
    Percent,
    Income,
}

impl Rule {
    pub const ALL: [Rule; 4] = [Rule::Equal, Rule::Parts, Rule::Percent, Rule::Income];

    pub fn key(self) -> &'static str {
        match self {
            Rule::Equal => "equal",
            Rule::Parts => "parts",
            Rule::Percent => "percent",
            Rule::Income => "income",
        }
    }

    pub fn from_key(key: &str) -> Rule {
        Rule::ALL.into_iter().find(|rule| rule.key() == key).unwrap_or(Rule::Equal)
    }
}

/// Une règle pour tout, ou une par poste.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Mode {
    Whole,
    PerItem,
}

impl Mode {
    pub fn key(self) -> &'static str {
        match self {
            Mode::Whole => "whole",
            Mode::PerItem => "item",
        }
    }
    pub fn from_key(key: &str) -> Mode {
        if key == "item" {
            Mode::PerItem
        } else {
            Mode::Whole
        }
    }
}

/// Au centime, ou à l'euro.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Rounding {
    Cent,
    Euro,
}

impl Rounding {
    pub fn key(self) -> &'static str {
        match self {
            Rounding::Cent => "cent",
            Rounding::Euro => "euro",
        }
    }
    pub fn from_key(key: &str) -> Rounding {
        if key == "euro" {
            Rounding::Euro
        } else {
            Rounding::Cent
        }
    }
}

/// Une personne lue. Les montants en micro-unités, ronds au centime.
#[derive(Debug, Clone, PartialEq)]
pub struct Person {
    pub id: u32,
    pub name: String,
    pub household: String,
    pub income: Option<i64>,
    pub parts: Option<f64>,
    pub percent: Option<f64>,
    pub floor: Option<i64>,
    pub cap: Option<i64>,
    pub fixed: Option<i64>,
    pub alone: i64,
    pub gift: bool,
}

/// La case lue d'une personne dans un poste.
#[derive(Debug, Clone, PartialEq)]
pub struct Cell {
    pub takes: bool,
    /// La valeur propre au poste, pour une règle par poste en parts ou en
    /// pourcentages ; `None` si vide.
    pub value: Option<f64>,
}

/// Un poste lu. `cells` suit l'ordre des personnes.
#[derive(Debug, Clone, PartialEq)]
pub struct Item {
    pub id: u32,
    pub label: String,
    pub amount: i64,
    pub rule: Rule,
    pub cells: Vec<Cell>,
}

/// Un règlement lu ; `person` est le rang de la personne.
#[derive(Debug, Clone, PartialEq)]
pub struct Payment {
    pub id: u32,
    pub person: usize,
    pub amount: i64,
    pub date: Option<NaiveDate>,
    pub label: String,
}

/// **Le partage lu.** Le premier poste est toujours le poste commun.
#[derive(Debug, Clone, PartialEq)]
pub struct Plan {
    pub label: String,
    /// Le total : tapé, ou la somme des postes et de ce que chacun prend pour
    /// lui seul.
    pub total: i64,
    pub mode: Mode,
    pub rule: Rule,
    pub rounding: Rounding,
    pub show_incomes: bool,
    pub people: Vec<Person>,
    pub items: Vec<Item>,
    pub payments: Vec<Payment>,
}

impl Plan {
    /// La règle d'un poste : celle de toute la dépense, ou la sienne.
    pub fn rule_of(&self, item: &Item) -> Rule {
        match self.mode {
            Mode::Whole => self.rule,
            Mode::PerItem => item.rule,
        }
    }

    /// Ce qui se partage : le total moins ce que chacun prend pour lui seul.
    pub fn shared(&self) -> i64 {
        self.total - self.people.iter().map(|person| person.alone).sum::<i64>()
    }
}

/// Le champ qui empêche le calcul, et la phrase qui dit pourquoi.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Refusal {
    pub field: String,
    pub message: String,
}

/// Un montant tapé, rond au centime ; vide, `None`. Négatif, refusé.
fn amount_field(text: &str) -> Result<Option<i64>, ()> {
    if text.trim().is_empty() {
        return Ok(None);
    }
    let micro = money::parse(text).map_err(|_| ())?;
    if micro < 0 {
        return Err(());
    }
    Ok(Some(round_to(micro, CENT)))
}

/// Un nombre tapé, positif ; vide, `None`.
fn number_field(text: &str) -> Result<Option<f64>, ()> {
    if text.trim().is_empty() {
        return Ok(None);
    }
    crate::appliance::parse_number(text).map(Some).ok_or(())
}

fn round_to(value: i64, unit: i64) -> i64 {
    let half = unit / 2;
    if value >= 0 {
        (value + half) / unit * unit
    } else {
        -((-value + half) / unit * unit)
    }
}

/// Un nom comparé : sans majuscules ni espaces autour.
fn folded(text: &str) -> String {
    text.trim().to_lowercase()
}

/// **Lit les champs**, dans l'ordre où ils se lisent à l'écran : le partage, les
/// personnes, les postes, les règlements. Seules les erreurs de saisie sont
/// refusées ici ; ce qui ne peut pas se partager l'est par [`share`].
pub fn read(input: &Input, language: Language) -> Result<Plan, Refusal> {
    let text = |key: &str| i18n::text(language, key);
    let refuse = |field: String, key: &str| Refusal { field, message: text(key) };

    if input.people.len() > PEOPLE_LIMIT {
        return Err(refuse(String::new(), "sharing-too-many-people"));
    }
    if input.items.len() > ITEMS_LIMIT {
        return Err(refuse(String::new(), "sharing-too-many-items"));
    }
    if input.payments.len() > PAYMENTS_LIMIT {
        return Err(refuse(String::new(), "sharing-too-many-payments"));
    }
    let typed_total = amount_field(&input.total).map_err(|_| refuse("total".into(), "sharing-invalid-amount"))?;

    // Les personnes.
    let mut people = Vec::new();
    let mut seen: BTreeMap<String, String> = BTreeMap::new();
    for typed in &input.people {
        let field = |name: &str| format!("{name}-{}", typed.id);
        let name = typed.name.trim().to_string();
        if name.is_empty() {
            return Err(refuse(field("name"), "sharing-name-missing"));
        }
        if let Some(first) = seen.get(&folded(&name)) {
            return Err(Refusal {
                field: field("name"),
                message: i18n::text_with(language, "sharing-name-duplicate", "name", first),
            });
        }
        seen.insert(folded(&name), name.clone());
        let money_of = |value: &str, key: &str| amount_field(value).map_err(|_| refuse(field(key), "sharing-invalid-amount"));
        let number_of = |value: &str, key: &str| number_field(value).map_err(|_| refuse(field(key), "sharing-invalid-number"));
        let income = money_of(&typed.income, "income")?;
        let parts = number_of(&typed.parts, "parts")?;
        let percent = number_of(&typed.percent, "percent")?;
        if percent.is_some_and(|value| value > 100.0) {
            return Err(refuse(field("percent"), "sharing-invalid-percent"));
        }
        let floor = money_of(&typed.floor, "floor")?;
        let cap = money_of(&typed.cap, "cap")?;
        let fixed = money_of(&typed.fixed, "fixed")?;
        let alone = money_of(&typed.alone, "alone")?.unwrap_or(0);
        if let (Some(floor), Some(cap), None) = (floor, cap, fixed) {
            if floor > cap {
                return Err(refuse(field("floor"), "sharing-floor-above-cap"));
            }
        }
        people.push(Person {
            id: typed.id,
            name,
            household: typed.household.trim().to_string(),
            income,
            parts,
            percent,
            floor,
            cap,
            fixed,
            alone,
            gift: typed.gift,
        });
    }

    // Les postes : le commun d'abord, puis les autres.
    let read_cells = |item: &ItemInput| -> Result<Vec<Cell>, Refusal> {
        people
            .iter()
            .map(|person| {
                let typed = item.cells.iter().find(|cell| cell.person == person.id);
                let value = match typed {
                    Some(cell) => number_field(&cell.value).map_err(|_| Refusal {
                        field: format!("cell-{}-{}", item.id, person.id),
                        message: text("sharing-invalid-number"),
                    })?,
                    None => None,
                };
                if item.rule == Rule::Percent.key() && value.is_some_and(|value| value > 100.0) {
                    return Err(Refusal {
                        field: format!("cell-{}-{}", item.id, person.id),
                        message: text("sharing-invalid-percent"),
                    });
                }
                // Une case absente participe : un poste ajouté part tout coché.
                Ok(Cell { takes: typed.is_none_or(|cell| cell.takes), value })
            })
            .collect()
    };
    let mut items = vec![Item {
        id: COMMON_ID,
        label: text("sharing-common"),
        amount: 0,
        rule: Rule::from_key(&input.common.rule),
        cells: read_cells(&input.common)?,
    }];
    for typed in &input.items {
        let field = |name: &str| format!("{name}-{}", typed.id);
        let label = typed.label.trim().to_string();
        if label.is_empty() && !typed.amount.trim().is_empty() {
            return Err(refuse(field("label"), "sharing-item-label-missing"));
        }
        let amount = amount_field(&typed.amount)
            .map_err(|_| refuse(field("amount"), "sharing-invalid-amount"))?
            .unwrap_or(0);
        items.push(Item {
            id: typed.id,
            label,
            amount,
            rule: Rule::from_key(&typed.rule),
            cells: read_cells(typed)?,
        });
    }

    // Le total, et le poste commun : ce qui reste.
    let carved: i64 = items.iter().skip(1).map(|item| item.amount).sum::<i64>()
        + people.iter().map(|person| person.alone).sum::<i64>();
    let total = typed_total.unwrap_or(carved);
    if total < carved {
        return Err(Refusal {
            field: "total".into(),
            message: i18n::text_with(language, "sharing-items-above-total", "amount", &money::format(carved - total, language)),
        });
    }
    items[0].amount = total - carved;

    // Les règlements. Une ligne sans montant ne compte pas encore.
    let mut payments = Vec::new();
    for typed in &input.payments {
        let field = |name: &str| format!("payment-{name}-{}", typed.id);
        let Some(amount) = amount_field(&typed.amount).map_err(|_| refuse(field("amount"), "sharing-invalid-amount"))? else {
            continue;
        };
        let Some(person) = people.iter().position(|person| person.id == typed.person) else {
            return Err(refuse(field("person"), "sharing-payment-person"));
        };
        let date = if typed.date.trim().is_empty() {
            None
        } else {
            Some(
                NaiveDate::parse_from_str(typed.date.trim(), "%Y-%m-%d")
                    .map_err(|_| refuse(field("date"), "sharing-invalid-date"))?,
            )
        };
        payments.push(Payment { id: typed.id, person, amount, date, label: typed.label.trim().to_string() });
    }

    Ok(Plan {
        label: input.label.trim().to_string(),
        total,
        mode: Mode::from_key(&input.mode),
        rule: Rule::from_key(&input.rule),
        rounding: Rounding::from_key(&input.rounding),
        show_incomes: input.show_incomes,
        people,
        items,
        payments,
    })
}

// --- Le partage -------------------------------------------------------------------

/// Ce qui a fixé ce qu'une personne paie.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Constraint {
    /// Son poids, rien d'autre.
    Free,
    /// Son plancher l'a fait payer plus.
    Floor,
    /// Son plafond l'a fait payer moins.
    Cap,
    /// Un montant fixe.
    Fixed,
    /// Ce qu'elle a versé en plus de sa part, offert au groupe.
    Gift,
}

impl Constraint {
    fn key(self) -> Option<&'static str> {
        match self {
            Constraint::Free => None,
            Constraint::Floor => Some("sharing-constraint-floor"),
            Constraint::Cap => Some("sharing-constraint-cap"),
            Constraint::Fixed => Some("sharing-constraint-fixed"),
            Constraint::Gift => Some("sharing-constraint-gift"),
        }
    }
}

/// **Le partage calculé.** Tout en micro-unités, au centime.
#[derive(Debug, Clone, PartialEq)]
pub struct Shares {
    /// Ce que chacun paie de chaque poste, `[personne][poste]`. Chaque colonne
    /// fait exactement le montant du poste.
    pub cells: Vec<Vec<i64>>,
    /// La part de ce qu'une personne paie dans des postes auxquels elle ne
    /// participe pas : son « hors postes ».
    pub outside: Vec<i64>,
    /// Ce que chacun paie des postes partagés.
    pub shared: Vec<i64>,
    /// L'ajustement de l'arrondi à l'euro ; zéro au centime.
    pub rounding: Vec<i64>,
    /// **Ce que chacun doit** : sa part, ce qu'il a pris pour lui seul, et
    /// l'arrondi.
    pub due: Vec<i64>,
    pub constraint: Vec<Constraint>,
    /// La personne qui garde les centimes quand l'arrondi à l'euro ne tombe pas
    /// rond.
    pub keeper: Option<usize>,
}

/// La part tapée de chacun dans chaque poste : `None` s'il n'y participe pas.
fn weights(plan: &Plan) -> Vec<Vec<Option<f64>>> {
    plan.people
        .iter()
        .enumerate()
        .map(|(rank, person)| {
            plan.items
                .iter()
                .map(|item| {
                    let cell = &item.cells[rank];
                    if !cell.takes {
                        return None;
                    }
                    let typed = match (plan.rule_of(item), plan.mode) {
                        (Rule::Equal, _) => 1.0,
                        (Rule::Parts, Mode::Whole) => person.parts.unwrap_or(1.0),
                        (Rule::Parts, Mode::PerItem) => cell.value.or(person.parts).unwrap_or(1.0),
                        (Rule::Percent, Mode::Whole) => person.percent.unwrap_or(0.0),
                        (Rule::Percent, Mode::PerItem) => cell.value.unwrap_or(0.0),
                        (Rule::Income, _) => person.income.unwrap_or(0) as f64,
                    };
                    // Un montant fixe n'a pas de poids tapé : il ne sert qu'à
                    // dire où son montant se range, et il lui en faut un.
                    Some(if person.fixed.is_some() && typed <= 0.0 { 1.0 } else { typed })
                })
                .collect()
        })
        .collect()
}

/// Un pourcentage écrit pour une phrase : « 90 », « 92,5 ».
fn percent_text(value: f64, language: Language) -> String {
    let decimals = if (value - value.round()).abs() < 1e-9 { 0 } else { 1 };
    crate::appliance::decimal(value, decimals, language)
}

/// **Vérifie ce qui ne dépend pas du calcul** : les pourcentages, les revenus,
/// les postes sans personne.
fn check(plan: &Plan, language: Language) -> Result<(), Refusal> {
    let refuse = |field: String, key: &str, texts: &[(&str, &str)]| Refusal {
        field,
        message: i18n::message_of(language, key, texts, &[]),
    };
    let label_of = |item: &Item| if item.id == COMMON_ID { i18n::text(language, "sharing-common") } else { item.label.clone() };
    // Les pourcentages d'une règle globale : sur tout le monde, sauf les montants fixes.
    if plan.mode == Mode::Whole && plan.rule == Rule::Percent && !plan.people.is_empty() {
        let sum: f64 = plan.people.iter().filter(|person| person.fixed.is_none()).map(|person| person.percent.unwrap_or(0.0)).sum();
        if (sum - 100.0).abs() > 1e-6 {
            return Err(refuse(String::new(), "sharing-percent-total", &[("sum", &percent_text(sum, language))]));
        }
    }
    for item in plan.items.iter().filter(|item| item.amount > 0) {
        let rule = plan.rule_of(item);
        let takers: Vec<usize> = (0..plan.people.len()).filter(|&rank| item.cells[rank].takes).collect();
        if takers.is_empty() {
            return Err(refuse(format!("item-{}", item.id), "sharing-item-nobody", &[("item", &label_of(item))]));
        }
        if plan.mode == Mode::PerItem && rule == Rule::Percent {
            let sum: f64 = takers
                .iter()
                .filter(|&&rank| plan.people[rank].fixed.is_none())
                .map(|&rank| item.cells[rank].value.unwrap_or(0.0))
                .sum();
            if (sum - 100.0).abs() > 1e-6 {
                return Err(refuse(
                    format!("item-{}", item.id),
                    "sharing-percent-total-item",
                    &[("item", &label_of(item)), ("sum", &percent_text(sum, language))],
                ));
            }
        }
        if rule == Rule::Income {
            if let Some(&rank) = takers
                .iter()
                .find(|&&rank| plan.people[rank].fixed.is_none() && plan.people[rank].income.is_none())
            {
                let person = &plan.people[rank];
                return Err(refuse(format!("income-{}", person.id), "sharing-income-missing", &[("name", &person.name)]));
            }
        }
    }
    Ok(())
}

/// Ce que paie chacun quand les poids des uns sont multipliés par `mu` :
/// `[personne][poste]`, sur les seuls participants.
fn spread(amounts: &[f64], weights: &[Vec<Option<f64>>], mu: &[f64]) -> Vec<Vec<f64>> {
    let people = weights.len();
    let mut out = vec![vec![0.0; amounts.len()]; people];
    for (column, &amount) in amounts.iter().enumerate() {
        if amount <= 0.0 {
            continue;
        }
        let whole: f64 = (0..people).map(|rank| weights[rank][column].unwrap_or(0.0) * mu[rank]).sum();
        if whole <= 0.0 {
            continue;
        }
        for rank in 0..people {
            let weight = weights[rank][column].unwrap_or(0.0) * mu[rank];
            if weight > 0.0 {
                out[rank][column] = amount * weight / whole;
            }
        }
    }
    out
}

/// Le total d'une personne en fonction de son seul multiplicateur, les autres
/// tenus : de quoi le chercher par dichotomie.
fn total_with(amounts: &[f64], weights: &[Vec<Option<f64>>], mu: &[f64], rank: usize, value: f64) -> f64 {
    let mut total = 0.0;
    for (column, &amount) in amounts.iter().enumerate() {
        let own = weights[rank][column].unwrap_or(0.0);
        if amount <= 0.0 || own <= 0.0 {
            continue;
        }
        let others: f64 = (0..weights.len())
            .filter(|&other| other != rank)
            .map(|other| weights[other][column].unwrap_or(0.0) * mu[other])
            .sum();
        let mine = own * value;
        total += amount * mine / (mine + others);
    }
    total
}

/// Le multiplicateur qui amène une personne sur sa borne.
fn solve(amounts: &[f64], weights: &[Vec<Option<f64>>], mu: &[f64], rank: usize, target: f64) -> f64 {
    let (mut low, mut high) = (-40.0_f64, 40.0_f64); // en logarithme
    for _ in 0..100 {
        let middle = (low + high) / 2.0;
        if total_with(amounts, weights, mu, rank, middle.exp()) < target {
            low = middle;
        } else {
            high = middle;
        }
    }
    ((low + high) / 2.0).exp()
}

/// **Partage, sans les cadeaux.** Voir la méthode en tête du module.
pub fn share(plan: &Plan, language: Language) -> Result<Shares, Refusal> {
    let people = plan.people.len();
    if people == 0 {
        return Ok(Shares {
            cells: Vec::new(),
            outside: Vec::new(),
            shared: Vec::new(),
            rounding: Vec::new(),
            due: Vec::new(),
            constraint: Vec::new(),
            keeper: None,
        });
    }
    check(plan, language)?;
    let columns = plan.items.len();
    let generic = || Refusal { field: String::new(), message: i18n::text(language, "sharing-impossible") };
    let amount_text = |value: f64| money::format(round_to(value.round() as i64, CENT), language);
    let label_of = |column: usize| {
        let item = &plan.items[column];
        if item.id == COMMON_ID { i18n::text(language, "sharing-common") } else { item.label.clone() }
    };
    let weights = weights(plan);
    for (column, item) in plan.items.iter().enumerate() {
        if item.amount > 0 && (0..people).all(|rank| weights[rank][column].unwrap_or(0.0) <= 0.0) {
            return Err(Refusal {
                field: format!("item-{}", item.id),
                message: i18n::text_with(language, "sharing-item-no-weight", "item", &label_of(column)),
            });
        }
    }
    let amounts: Vec<f64> = plan.items.iter().map(|item| item.amount as f64).collect();
    let shared: f64 = amounts.iter().sum();
    let low: Vec<f64> = plan.people.iter().map(|person| person.fixed.or(person.floor).unwrap_or(0) as f64).collect();
    let high: Vec<f64> = plan
        .people
        .iter()
        .map(|person| person.fixed.or(person.cap).map_or(f64::INFINITY, |value| value as f64))
        .collect();
    let fixed: f64 = plan.people.iter().filter_map(|person| person.fixed).sum::<i64>() as f64;
    if fixed > shared + 0.5 {
        return Err(Refusal {
            field: String::new(),
            message: i18n::text_with(language, "sharing-fixed-above", "amount", &amount_text(fixed - shared)),
        });
    }
    let floors: f64 = low.iter().sum();
    if floors > shared + 0.5 {
        return Err(Refusal {
            field: String::new(),
            message: i18n::text_with(language, "sharing-floors-above", "amount", &amount_text(floors - shared)),
        });
    }

    // Où chacun a un poids.
    let weighted = |rank: usize, column: usize| weights[rank][column].unwrap_or(0.0) > 0.0 && amounts[column] > 0.0;

    // **Hors postes** : ce qu'une personne doit au-delà de ses postes se déduit
    // des autres, en proportion de leur montant.
    let mut beyond = vec![0.0_f64; people];
    let mut remaining = amounts.clone();
    for _ in 0..60 {
        remaining = amounts.clone();
        for (rank, &owed) in beyond.iter().enumerate() {
            if owed <= 0.0 {
                continue;
            }
            let others: f64 = (0..columns).filter(|&column| !weighted(rank, column)).map(|column| amounts[column]).sum();
            if others <= 0.0 {
                return Err(generic());
            }
            for column in (0..columns).filter(|&column| !weighted(rank, column)) {
                remaining[column] -= owed * amounts[column] / others;
            }
        }
        let mut moved = 0.0_f64;
        for rank in 0..people {
            let reach: f64 = (0..columns).filter(|&column| weighted(rank, column)).map(|column| remaining[column].max(0.0)).sum();
            let wanted = (low[rank] - reach).max(0.0);
            moved = moved.max((wanted - beyond[rank]).abs());
            beyond[rank] = wanted;
        }
        if moved < 0.5 {
            break;
        }
    }
    if remaining.iter().any(|&value| value < -0.5) {
        let short: f64 = remaining.iter().filter(|&&value| value < 0.0).map(|value| -value).sum();
        return Err(Refusal {
            field: String::new(),
            message: i18n::text_with(language, "sharing-fixed-above", "amount", &amount_text(short)),
        });
    }
    for value in &mut remaining {
        *value = value.max(0.0);
    }
    let low_in: Vec<f64> = (0..people).map(|rank| (low[rank] - beyond[rank]).max(0.0)).collect();
    let high_in: Vec<f64> = (0..people).map(|rank| high[rank] - beyond[rank]).collect();

    // Ce qui ne peut pas tenir : un plafond sur un poste où l'on est seul, des
    // plafonds qui ne couvrent pas la somme.
    for (rank, &most) in high_in.iter().enumerate() {
        if most.is_infinite() {
            continue;
        }
        for column in (0..columns).filter(|&column| weighted(rank, column)) {
            let alone = (0..people).all(|other| other == rank || weights[other][column].unwrap_or(0.0) <= 0.0);
            if alone && remaining[column] > most + 0.5 && plan.people[rank].fixed.is_none() {
                return Err(Refusal {
                    field: format!("cap-{}", plan.people[rank].id),
                    message: i18n::message_of(
                        language,
                        "sharing-cap-alone",
                        &[("name", &plan.people[rank].name), ("item", &label_of(column))],
                        &[],
                    ),
                });
            }
        }
    }
    let reachable: f64 = (0..people)
        .map(|rank| {
            let reach: f64 = (0..columns).filter(|&column| weighted(rank, column)).map(|column| remaining[column]).sum();
            reach.min(high_in[rank])
        })
        .sum();
    let to_share: f64 = remaining.iter().sum();
    if reachable < to_share - 0.5 {
        return Err(Refusal {
            field: String::new(),
            message: i18n::text_with(language, "sharing-caps-short", "amount", &amount_text(to_share - reachable)),
        });
    }

    // **Les multiplicateurs.** Une personne libre garde 1 ; une personne sur sa
    // borne reçoit celui qui l'y amène. On recommence tant que quelqu'un sort de
    // sa fourchette, ou qu'une borne ne sert plus.
    let mut mu = vec![1.0_f64; people];
    let mut bound: Vec<Option<f64>> = vec![None; people];
    for rank in 0..people {
        if plan.people[rank].fixed.is_some() && (0..columns).any(|column| weighted(rank, column)) {
            bound[rank] = Some(low_in[rank]);
        }
    }
    let tolerance = CENT as f64 / 2.0;
    let mut settled = false;
    for _ in 0..200 {
        for _ in 0..200 {
            let mut moved = 0.0_f64;
            for rank in 0..people {
                if let Some(target) = bound[rank] {
                    let next = solve(&remaining, &weights, &mu, rank, target);
                    moved = moved.max((next.ln() - mu[rank].ln()).abs());
                    mu[rank] = next;
                }
            }
            if moved < 1e-12 {
                break;
            }
        }
        let totals: Vec<f64> = spread(&remaining, &weights, &mu).iter().map(|row| row.iter().sum()).collect();
        let mut changed = false;
        for rank in 0..people {
            match bound[rank] {
                None if totals[rank] > high_in[rank] + tolerance => {
                    bound[rank] = Some(high_in[rank]);
                    changed = true;
                }
                None if totals[rank] < low_in[rank] - tolerance => {
                    bound[rank] = Some(low_in[rank]);
                    changed = true;
                }
                Some(target) if plan.people[rank].fixed.is_none() => {
                    let on_cap = (target - high_in[rank]).abs() < tolerance;
                    if (on_cap && mu[rank] >= 1.0) || (!on_cap && mu[rank] <= 1.0) {
                        bound[rank] = None;
                        mu[rank] = 1.0;
                        changed = true;
                    }
                }
                _ => {}
            }
        }
        if !changed {
            settled = true;
            break;
        }
    }
    let real = spread(&remaining, &weights, &mu);
    let totals: Vec<f64> = real.iter().map(|row| row.iter().sum()).collect();
    if !settled
        || (0..people).any(|rank| {
            (0..columns).any(|column| weighted(rank, column))
                && (totals[rank] > high_in[rank] + CENT as f64 || totals[rank] < low_in[rank] - CENT as f64)
        })
    {
        return Err(generic());
    }

    // La matrice réelle, hors postes compris, en centimes.
    let mut matrix: Vec<Vec<f64>> = real;
    for rank in 0..people {
        if beyond[rank] <= 0.0 {
            continue;
        }
        let others: f64 = (0..columns).filter(|&column| !weighted(rank, column)).map(|column| amounts[column]).sum();
        for column in (0..columns).filter(|&column| !weighted(rank, column)) {
            matrix[rank][column] += beyond[rank] * amounts[column] / others;
        }
    }
    // Qui a une borne exacte : un montant fixe, un plancher ou un plafond atteint.
    let mut target: Vec<Option<i64>> = vec![None; people];
    let mut constraint = vec![Constraint::Free; people];
    for (rank, person) in plan.people.iter().enumerate() {
        let total: f64 = matrix[rank].iter().sum();
        if let Some(value) = person.fixed {
            target[rank] = Some(value);
            constraint[rank] = Constraint::Fixed;
        } else if person.floor.is_some_and(|floor| floor > 0 && (total - floor as f64).abs() < tolerance) && bound[rank].is_some()
            || beyond[rank] > 0.0
        {
            target[rank] = person.floor;
            constraint[rank] = Constraint::Floor;
        } else if person.cap.is_some_and(|cap| (total - cap as f64).abs() < tolerance) && bound[rank].is_some() {
            target[rank] = person.cap;
            constraint[rank] = Constraint::Cap;
        }
    }
    let cells = round_matrix(&matrix, &plan.items, &weights, &target);
    let outside: Vec<i64> = (0..people)
        .map(|rank| (0..columns).filter(|&column| !weighted(rank, column)).map(|column| cells[rank][column]).sum())
        .collect();
    let shared_of: Vec<i64> = cells.iter().map(|row| row.iter().sum()).collect();

    // L'arrondi à l'euro : sur les seules personnes libres.
    let mut rounding = vec![0_i64; people];
    let mut keeper = None;
    if plan.rounding == Rounding::Euro {
        let euro = money::UNIT;
        let free: Vec<usize> = (0..people).filter(|&rank| constraint[rank] == Constraint::Free).collect();
        let before: Vec<i64> = (0..people).map(|rank| shared_of[rank] + plan.people[rank].alone).collect();
        let base: Vec<i64> = before.iter().map(|value| value.div_euclid(euro) * euro).collect();
        let mut left: i64 = free.iter().map(|&rank| before[rank] - base[rank]).sum();
        let fits = |rank: usize, value: i64| {
            let part = (value - plan.people[rank].alone) as f64;
            part >= low[rank] - 0.5 && part <= high[rank] + 0.5
        };
        let mut order = free.clone();
        // D'abord ceux qu'un arrondi vers le bas ferait passer sous leur plancher,
        // puis les plus gros restes.
        order.sort_by(|&a, &b| {
            let must = |rank: usize| !fits(rank, base[rank]);
            must(b)
                .cmp(&must(a))
                .then((before[b] - base[b]).cmp(&(before[a] - base[a])))
                .then(a.cmp(&b))
        });
        let mut after = base.clone();
        for &rank in &order {
            if left >= euro && fits(rank, base[rank] + euro) {
                after[rank] += euro;
                left -= euro;
            }
        }
        for &rank in &order {
            if left >= euro {
                after[rank] += euro;
                left -= euro;
            }
        }
        if left > 0 {
            if let Some(&first) = order.first() {
                after[first] += left;
                keeper = Some(first);
            }
        }
        for &rank in &free {
            rounding[rank] = after[rank] - before[rank];
        }
    }
    let due: Vec<i64> = (0..people).map(|rank| shared_of[rank] + plan.people[rank].alone + rounding[rank]).collect();
    Ok(Shares { cells, outside, shared: shared_of, rounding, due, constraint, keeper })
}

/// **Arrondit au centime** sans rien perdre : chaque poste tombe juste — les
/// centimes restants vont aux plus gros restes —, puis chaque personne qui a
/// une borne exacte y est ramenée, un centime à la fois, en échange avec une
/// personne libre du même poste.
fn round_matrix(matrix: &[Vec<f64>], items: &[Item], weights: &[Vec<Option<f64>>], target: &[Option<i64>]) -> Vec<Vec<i64>> {
    let people = matrix.len();
    let mut cents = vec![vec![0_i64; items.len()]; people];
    for (column, item) in items.iter().enumerate() {
        let whole = item.amount / CENT;
        let exact: Vec<f64> = (0..people).map(|rank| matrix[rank][column] / CENT as f64).collect();
        let mut floor: Vec<i64> = exact.iter().map(|value| value.floor().max(0.0) as i64).collect();
        let mut left = whole - floor.iter().sum::<i64>();
        let mut order: Vec<usize> = (0..people).filter(|&rank| exact[rank] > 0.0).collect();
        order.sort_by(|&a, &b| {
            let rest = |rank: usize| exact[rank] - exact[rank].floor();
            rest(b).partial_cmp(&rest(a)).unwrap_or(std::cmp::Ordering::Equal).then(a.cmp(&b))
        });
        while left > 0 && !order.is_empty() {
            for &rank in &order {
                if left == 0 {
                    break;
                }
                floor[rank] += 1;
                left -= 1;
            }
        }
        while left < 0 {
            let Some(rank) = (0..people).rev().find(|&rank| floor[rank] > 0) else { break };
            floor[rank] -= 1;
            left += 1;
        }
        for rank in 0..people {
            cents[rank][column] = floor[rank];
        }
    }
    // Ramène les bornes exactes.
    let free: Vec<bool> = target.iter().map(Option::is_none).collect();
    for rank in 0..people {
        let Some(goal) = target[rank] else { continue };
        let goal = goal / CENT;
        for _ in 0..(items.len() as i64 * 1000) {
            let now: i64 = cents[rank].iter().sum();
            if now == goal {
                break;
            }
            let giving = now > goal;
            let swap = (0..items.len()).find_map(|column| {
                if giving && cents[rank][column] == 0 {
                    return None;
                }
                (0..people)
                    .filter(|&other| other != rank && free[other] && weights[other][column].unwrap_or(0.0) > 0.0)
                    .find(|&other| giving || cents[other][column] > 0)
                    .map(|other| (column, other))
            });
            let Some((column, other)) = swap else { break };
            if giving {
                cents[rank][column] -= 1;
                cents[other][column] += 1;
            } else {
                cents[rank][column] += 1;
                cents[other][column] -= 1;
            }
        }
    }
    cents.into_iter().map(|row| row.into_iter().map(|value| value * CENT).collect()).collect()
}

// --- Les cadeaux, les foyers, les règlements -----------------------------------------

/// Ce que chacun a versé, par personne.
fn paid_by_person(plan: &Plan) -> Vec<i64> {
    let mut paid = vec![0_i64; plan.people.len()];
    for payment in &plan.payments {
        paid[payment.person] += payment.amount;
    }
    paid
}

/// Un foyer, ou une personne seule : ce qui paie et se rembourse ensemble.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Unit {
    /// `household-<nom replié>` ou `person-<id>` : de quoi l'imprimer seul.
    pub key: String,
    pub name: String,
    pub members: Vec<usize>,
    pub due: i64,
    pub paid: i64,
}

impl Unit {
    /// Positif : reste à régler ; négatif : a versé plus que sa part.
    pub fn balance(&self) -> i64 {
        self.due - self.paid
    }
    pub fn is_household(&self) -> bool {
        self.key.starts_with("household-")
    }
}

/// Un virement proposé, d'un foyer à un autre.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Transfer {
    pub from: usize,
    pub to: usize,
    pub amount: i64,
}

/// **Tout le calcul**, cadeaux, foyers et virements compris.
#[derive(Debug, Clone, PartialEq)]
pub struct Computed {
    /// Le partage, les cadeaux devenus des montants fixes.
    pub plan: Plan,
    pub shares: Shares,
    /// Qui a fait un cadeau.
    pub gifted: Vec<bool>,
    pub units: Vec<Unit>,
    /// Les virements, une fois la dépense entièrement réglée ; vide avant.
    pub transfers: Vec<Transfer>,
    /// Ce qui a été versé en tout.
    pub collected: i64,
}

/// Les foyers, dans l'ordre où leur premier membre apparaît.
fn units_of(plan: &Plan, shares: &Shares) -> Vec<Unit> {
    let paid = paid_by_person(plan);
    let mut units: Vec<Unit> = Vec::new();
    for (rank, person) in plan.people.iter().enumerate() {
        let key = if person.household.is_empty() {
            format!("person-{}", person.id)
        } else {
            format!("household-{}", folded(&person.household))
        };
        let index = match units.iter().position(|unit| unit.key == key) {
            Some(index) => index,
            None => {
                let name = if person.household.is_empty() { person.name.clone() } else { person.household.clone() };
                units.push(Unit { key, name, members: Vec::new(), due: 0, paid: 0 });
                units.len() - 1
            }
        };
        units[index].members.push(rank);
        units[index].due += shares.due[rank];
        units[index].paid += paid[rank];
    }
    units
}

/// **Les virements** : le plus gros débiteur paie le plus gros créancier, et
/// ainsi de suite — au plus un de moins que les foyers.
fn transfers_of(units: &[Unit]) -> Vec<Transfer> {
    let mut owing: Vec<(usize, i64)> = units.iter().enumerate().filter(|(_, unit)| unit.balance() > 0).map(|(index, unit)| (index, unit.balance())).collect();
    let mut owed: Vec<(usize, i64)> = units.iter().enumerate().filter(|(_, unit)| unit.balance() < 0).map(|(index, unit)| (index, -unit.balance())).collect();
    let mut out = Vec::new();
    loop {
        owing.sort_by(|a, b| b.1.cmp(&a.1).then(a.0.cmp(&b.0)));
        owed.sort_by(|a, b| b.1.cmp(&a.1).then(a.0.cmp(&b.0)));
        let (Some(debtor), Some(creditor)) = (owing.first_mut(), owed.first_mut()) else { break };
        if debtor.1 == 0 || creditor.1 == 0 {
            break;
        }
        let amount = debtor.1.min(creditor.1);
        out.push(Transfer { from: debtor.0, to: creditor.0, amount });
        debtor.1 -= amount;
        creditor.1 -= amount;
        owing.retain(|(_, left)| *left > 0);
        owed.retain(|(_, left)| *left > 0);
    }
    out
}

/// **Calcule tout.** « Offert » fait du surplus versé un montant fixe, et le
/// reste se partage entre les autres ; on recommence tant qu'un nouveau cadeau
/// apparaît.
pub fn compute(plan: &Plan, language: Language) -> Result<Computed, Refusal> {
    let people = plan.people.len();
    let mut plan = plan.clone();
    let mut gifted = vec![false; people];
    for _ in 0..=people {
        let mut shares = share(&plan, language)?;
        let paid = paid_by_person(&plan);
        let mut changed = false;
        for rank in 0..people {
            let person = &plan.people[rank];
            if person.gift && !gifted[rank] && person.fixed.is_none() && paid[rank] > shares.due[rank] {
                let others: i64 = (0..people)
                    .filter(|&other| other != rank)
                    .map(|other| plan.people[other].fixed.or(plan.people[other].floor).unwrap_or(0))
                    .sum();
                let fixed = (paid[rank] - person.alone).min(plan.shared() - others).max(0);
                plan.people[rank].fixed = Some(fixed);
                gifted[rank] = true;
                changed = true;
            }
        }
        if !changed {
            for (rank, given) in gifted.iter().enumerate() {
                if *given {
                    shares.constraint[rank] = Constraint::Gift;
                }
            }
            let units = units_of(&plan, &shares);
            let collected: i64 = plan.payments.iter().map(|payment| payment.amount).sum();
            let transfers = if collected >= plan.total && plan.total > 0 { transfers_of(&units) } else { Vec::new() };
            return Ok(Computed { plan, shares, gifted, units, transfers, collected });
        }
    }
    Err(Refusal { field: String::new(), message: i18n::text(language, "sharing-impossible") })
}

// --- Le résultat écrit ------------------------------------------------------------

/// Une personne dans le résultat.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct PersonLine {
    pub id: u32,
    pub name: String,
    /// Ce qu'elle doit, tout compris.
    pub due: String,
    /// Sa part réelle de ce qui se partage, en pourcent.
    pub share: String,
    /// Le pourcentage tapé, pour une règle globale en pourcentages ; vide sinon.
    pub typed: String,
    /// La contrainte qui a joué ; vide si aucune.
    pub constraint: String,
    pub alone: String,
    pub outside: String,
    pub rounding: String,
    /// Le détail par poste, pour une bulle : « Commun : 42,00 € · Vin : 30,00 € ».
    pub detail: String,
}

/// Ce qu'une personne paie d'un poste, pour la grille.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct CellLine {
    pub person: u32,
    pub item: u32,
    pub amount: String,
}

/// Un poste dans le résultat.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct ItemLine {
    pub id: u32,
    pub label: String,
    pub amount: String,
    pub participants: String,
}

/// Un foyer, ou une personne seule, et où il en est.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct UnitLine {
    pub key: String,
    pub name: String,
    pub members: String,
    pub due: String,
    pub paid: String,
    pub balance: String,
    /// `due`, `even` ou `over`.
    pub tone: String,
}

/// **Tout ce que la fenêtre affiche, déjà écrit.**
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Written {
    pub headline: String,
    /// `none` tant qu'il n'y a rien à partager, `good` ensuite.
    pub tone: String,
    /// Le montant du poste commun.
    pub common: String,
    pub people: Vec<PersonLine>,
    pub cells: Vec<CellLine>,
    pub items: Vec<ItemLine>,
    pub units: Vec<UnitLine>,
    pub summary: Vec<String>,
    pub transfers: Vec<String>,
    pub notes: Vec<String>,
    /// Les règlements dépassent la dépense : un avertissement, pas un refus.
    pub warning: Option<String>,
}

/// Le nom d'un poste, le commun compris.
fn item_label(item: &Item, language: Language) -> String {
    if item.id == COMMON_ID {
        i18n::text(language, "sharing-common")
    } else {
        item.label.clone()
    }
}

fn percent_of(part: i64, whole: i64, language: Language) -> String {
    if whole <= 0 {
        return String::new();
    }
    let value = part as f64 / whole as f64 * 100.0;
    i18n::message_of(language, "loan-percent", &[("value", &crate::appliance::decimal(value, 1, language))], &[])
}

/// Les noms d'une liste, joints.
fn joined(names: &[String], language: Language) -> String {
    match names.len() {
        0 => String::new(),
        1 => names[0].clone(),
        _ => i18n::message_of(
            language,
            "sharing-and",
            &[("first", &names[..names.len() - 1].join(", ")), ("last", &names[names.len() - 1])],
            &[],
        ),
    }
}

/// Le détail par poste d'une personne : « Commun : 42,00 € », un par poste où
/// elle paie quelque chose.
fn detail_of(computed: &Computed, rank: usize, language: Language) -> Vec<(String, String)> {
    let plan = &computed.plan;
    let mut lines: Vec<(String, String)> = plan
        .items
        .iter()
        .enumerate()
        .filter(|(column, item)| item.cells[rank].takes && computed.shares.cells[rank][*column] > 0)
        .map(|(column, item)| (item_label(item, language), money::format(computed.shares.cells[rank][column], language)))
        .collect();
    if computed.shares.outside[rank] > 0 {
        lines.push((i18n::text(language, "sharing-outside"), money::format(computed.shares.outside[rank], language)));
    }
    if plan.people[rank].alone > 0 {
        lines.push((i18n::text(language, "sharing-alone"), money::format(plan.people[rank].alone, language)));
    }
    if computed.shares.rounding[rank] != 0 {
        lines.push((i18n::text(language, "sharing-rounding"), signed(computed.shares.rounding[rank], language)));
    }
    lines
}

/// Un montant avec son signe : « +0,38 € », « −0,62 € ».
fn signed(value: i64, language: Language) -> String {
    let written = money::format(value.abs(), language);
    if value < 0 {
        format!("−{written}")
    } else {
        format!("+{written}")
    }
}

/// La phrase du solde d'un foyer.
fn balance_text(unit: &Unit, language: Language) -> (String, &'static str) {
    let balance = unit.balance();
    if balance > 0 {
        (i18n::text_with(language, "sharing-balance-due", "amount", &money::format(balance, language)), "due")
    } else if balance < 0 {
        (i18n::text_with(language, "sharing-balance-over", "amount", &money::format(-balance, language)), "over")
    } else {
        (i18n::text(language, "sharing-balance-even"), "even")
    }
}

/// Les lignes de l'état des paiements : ce qui a été versé, qui doit encore, et
/// ce qui reste à payer ou à rembourser.
fn summary_of(computed: &Computed, language: Language) -> Vec<String> {
    let plan = &computed.plan;
    let amount = |value: i64| money::format(value, language);
    let mut lines = vec![i18n::message_of(
        language,
        "sharing-summary-collected",
        &[("collected", &amount(computed.collected)), ("total", &amount(plan.total))],
        &[],
    )];
    let owing: Vec<&Unit> = computed.units.iter().filter(|unit| unit.balance() > 0).collect();
    let owed: i64 = owing.iter().map(|unit| unit.balance()).sum();
    lines.push(i18n::message_of(
        language,
        "sharing-summary-owing",
        &[("amount", &amount(owed))],
        &[("count", owing.len() as i64)],
    ));
    if computed.transfers.is_empty() {
        let outstanding = plan.total - computed.collected;
        if outstanding > 0 {
            lines.push(i18n::text_with(language, "sharing-remaining-outside", "amount", &amount(outstanding)));
        }
        for unit in computed.units.iter().filter(|unit| unit.balance() < 0) {
            lines.push(i18n::message_of(
                language,
                "sharing-remaining-reimburse",
                &[("name", &unit.name), ("amount", &amount(-unit.balance()))],
                &[],
            ));
        }
    }
    lines
}

/// Les virements écrits.
fn transfers_text(computed: &Computed, language: Language) -> Vec<String> {
    if computed.collected >= computed.plan.total && computed.plan.total > 0 && computed.transfers.is_empty() {
        return vec![i18n::text(language, "sharing-all-settled")];
    }
    computed
        .transfers
        .iter()
        .map(|transfer| {
            i18n::message_of(
                language,
                "sharing-transfer",
                &[
                    ("from", &computed.units[transfer.from].name),
                    ("to", &computed.units[transfer.to].name),
                    ("amount", &money::format(transfer.amount, language)),
                ],
                &[],
            )
        })
        .collect()
}

/// Les phrases qui expliquent : un revenu à 0, une exclusion sous une règle en
/// pourcentages, un cadeau qui fait baisser les autres, un hors postes, les
/// centimes de l'arrondi.
fn notes_of(computed: &Computed, language: Language) -> Vec<String> {
    let plan = &computed.plan;
    let shares = &computed.shares;
    let mut notes = Vec::new();
    for (rank, person) in plan.people.iter().enumerate() {
        if person.fixed.is_some() {
            continue;
        }
        let zero: Vec<String> = plan
            .items
            .iter()
            .filter(|item| item.amount > 0 && item.cells[rank].takes && plan.rule_of(item) == Rule::Income && person.income == Some(0))
            .map(|item| item_label(item, language))
            .collect();
        if !zero.is_empty() {
            notes.push(i18n::message_of(
                language,
                "sharing-note-income-zero",
                &[("name", &person.name), ("items", &joined(&zero, language))],
                &[],
            ));
        }
        if plan.mode == Mode::Whole && plan.rule == Rule::Percent && person.percent.unwrap_or(0.0) > 0.0 {
            for item in plan.items.iter().filter(|item| item.amount > 0 && !item.cells[rank].takes) {
                notes.push(i18n::message_of(
                    language,
                    "sharing-note-excluded",
                    &[("name", &person.name), ("item", &item_label(item, language))],
                    &[],
                ));
            }
        }
    }
    let givers: Vec<String> = (0..plan.people.len()).filter(|&rank| computed.gifted[rank]).map(|rank| plan.people[rank].name.clone()).collect();
    if !givers.is_empty() {
        let paid = paid_by_person(plan);
        for (rank, person) in plan.people.iter().enumerate() {
            if !computed.gifted[rank] && paid[rank] > shares.due[rank] {
                notes.push(i18n::message_of(
                    language,
                    "sharing-note-gift",
                    &[("giver", &joined(&givers, language)), ("name", &person.name)],
                    &[],
                ));
            }
        }
    }
    for (rank, person) in plan.people.iter().enumerate() {
        if shares.outside[rank] > 0 {
            notes.push(i18n::message_of(
                language,
                "sharing-note-outside",
                &[("name", &person.name), ("amount", &money::format(shares.outside[rank], language))],
                &[],
            ));
        }
    }
    if let Some(rank) = shares.keeper {
        notes.push(i18n::text_with(language, "sharing-note-keeper", "name", &plan.people[rank].name));
    }
    notes
}

/// **Écrit le résultat.** Sans personne ou sans montant, une phrase d'invite.
pub fn write(computed: &Computed, original: &Plan, language: Language) -> Written {
    let plan = &computed.plan;
    let shares = &computed.shares;
    let amount = |value: i64| money::format(value, language);
    let headline = if plan.people.is_empty() {
        i18n::text(language, "sharing-headline-empty")
    } else if plan.total == 0 {
        i18n::text(language, "sharing-headline-no-amount")
    } else {
        // **Ce qu'on veut savoir** (Fabrice, 11/10/2026 : « on a du mal à
        // comprendre ce que l'on doit ») : « chacun paie 60,00 € », ou
        // l'écart entre le moins et le plus.
        let low = shares.due.iter().copied().min().unwrap_or(0);
        let high = shares.due.iter().copied().max().unwrap_or(0);
        if low == high {
            i18n::message_of(
                language,
                "sharing-headline-equal",
                &[("total", &amount(plan.total)), ("amount", &amount(low))],
                &[],
            )
        } else {
            i18n::message_of(
                language,
                "sharing-headline-range",
                &[("total", &amount(plan.total)), ("min", &amount(low)), ("max", &amount(high))],
                &[],
            )
        }
    };
    let tone = if plan.people.is_empty() || plan.total == 0 { "none" } else { "good" };
    let shared = plan.shared();
    let people = plan
        .people
        .iter()
        .enumerate()
        .map(|(rank, person)| PersonLine {
            id: person.id,
            name: person.name.clone(),
            due: amount(shares.due[rank]),
            share: percent_of(shares.shared[rank], shared, language),
            typed: if plan.mode == Mode::Whole && plan.rule == Rule::Percent && original.people[rank].fixed.is_none() {
                i18n::message_of(
                    language,
                    "loan-percent",
                    &[("value", &percent_text(person.percent.unwrap_or(0.0), language))],
                    &[],
                )
            } else {
                String::new()
            },
            constraint: shares.constraint[rank].key().map(|key| i18n::text(language, key)).unwrap_or_default(),
            alone: if person.alone > 0 { amount(person.alone) } else { String::new() },
            outside: if shares.outside[rank] > 0 { amount(shares.outside[rank]) } else { String::new() },
            rounding: if shares.rounding[rank] != 0 { signed(shares.rounding[rank], language) } else { String::new() },
            detail: detail_of(computed, rank, language)
                .into_iter()
                .map(|(label, value)| format!("{label} : {value}"))
                .collect::<Vec<_>>()
                .join(" · "),
        })
        .collect();
    let mut cells = Vec::new();
    for (rank, person) in plan.people.iter().enumerate() {
        for (column, item) in plan.items.iter().enumerate() {
            if item.cells[rank].takes && item.amount > 0 {
                cells.push(CellLine { person: person.id, item: item.id, amount: amount(shares.cells[rank][column]) });
            }
        }
    }
    let items = plan
        .items
        .iter()
        .map(|item| ItemLine {
            id: item.id,
            label: item_label(item, language),
            amount: amount(item.amount),
            participants: i18n::message_of(
                language,
                "sharing-participants",
                &[],
                &[("count", item.cells.iter().filter(|cell| cell.takes).count() as i64)],
            ),
        })
        .collect();
    let units = computed
        .units
        .iter()
        .map(|unit| {
            let (balance, tone) = balance_text(unit, language);
            UnitLine {
                key: unit.key.clone(),
                name: unit.name.clone(),
                members: if unit.is_household() {
                    unit.members.iter().map(|&rank| plan.people[rank].name.clone()).collect::<Vec<_>>().join(", ")
                } else {
                    String::new()
                },
                due: amount(unit.due),
                paid: amount(unit.paid),
                balance,
                tone: tone.to_string(),
            }
        })
        .collect();
    let warning = (computed.collected > plan.total && plan.total > 0).then(|| {
        i18n::text_with(language, "sharing-warning-over-paid", "amount", &amount(computed.collected - plan.total))
    });
    Written {
        headline,
        tone: tone.to_string(),
        common: amount(plan.items[0].amount),
        people,
        cells,
        items,
        units,
        summary: if plan.total > 0 && !plan.people.is_empty() { summary_of(computed, language) } else { Vec::new() },
        transfers: if plan.total > 0 { transfers_text(computed, language) } else { Vec::new() },
        notes: notes_of(computed, language),
        warning,
    }
}

// --- Le projet en fichier -------------------------------------------------------

/// Ce qui dit, en tête du fichier, qu'il s'agit d'un projet de partage.
pub const FILE_MARK: &str = "radinus-projet-partage";
/// La version du format. Un fichier plus ancien s'ouvre ; un plus récent est
/// refusé : il pourrait porter ce que cette version ne sait pas lire.
pub const FILE_VERSION: u32 = 1;

#[derive(Debug, Clone, Default, PartialEq, serde::Serialize, serde::Deserialize)]
#[serde(default)]
struct FilePerson {
    id: u32,
    name: String,
    household: String,
    income: Option<f64>,
    parts: Option<f64>,
    percent: Option<f64>,
    floor: Option<f64>,
    cap: Option<f64>,
    fixed: Option<f64>,
    alone: Option<f64>,
    gift: bool,
}

#[derive(Debug, Clone, Default, PartialEq, serde::Serialize, serde::Deserialize)]
#[serde(default)]
struct FileCell {
    person: u32,
    takes: bool,
    value: Option<f64>,
}

#[derive(Debug, Clone, Default, PartialEq, serde::Serialize, serde::Deserialize)]
#[serde(default)]
struct FileItem {
    id: u32,
    label: String,
    amount: Option<f64>,
    rule: String,
    cells: Vec<FileCell>,
}

#[derive(Debug, Clone, Default, PartialEq, serde::Serialize, serde::Deserialize)]
#[serde(default)]
struct FilePayment {
    id: u32,
    person: u32,
    amount: Option<f64>,
    /// AAAA-MM-JJ, ou vide.
    date: String,
    label: String,
}

#[derive(Debug, Clone, Default, PartialEq, serde::Serialize, serde::Deserialize)]
#[serde(default)]
struct File {
    format: String,
    version: u32,
    label: String,
    total: Option<f64>,
    mode: String,
    rule: String,
    rounding: String,
    show_incomes: bool,
    people: Vec<FilePerson>,
    common: FileItem,
    items: Vec<FileItem>,
    payments: Vec<FilePayment>,
}

/// **Le projet en JSON**, à partir de ce qui est tapé — seulement ce qui est
/// tapé, jamais le résultat, qui se recalcule à l'ouverture. Les montants y
/// sont écrits de façon neutre (« 1250.5 »), si bien qu'un projet enregistré en
/// français se rouvre en anglais. Il s'enregistre même quand le partage ne
/// tombe pas encore juste — des pourcentages qui ne font pas 100 % — : seul un
/// champ illisible l'empêche.
pub fn to_file(input: &Input, language: Language) -> Result<String, Refusal> {
    let unit = money::UNIT as f64;
    let unreadable = |field: String, key: &str| Refusal { field, message: i18n::text(language, key) };
    let money_of = |text: &str, field: String| -> Result<Option<f64>, Refusal> {
        amount_field(text).map(|value| value.map(|micro| micro as f64 / unit)).map_err(|_| unreadable(field, "sharing-invalid-amount"))
    };
    let number_of = |text: &str, field: String| -> Result<Option<f64>, Refusal> {
        number_field(text).map_err(|_| unreadable(field, "sharing-invalid-number"))
    };
    let cells_of = |item: &ItemInput| -> Result<Vec<FileCell>, Refusal> {
        item.cells
            .iter()
            .map(|cell| {
                Ok(FileCell {
                    person: cell.person,
                    takes: cell.takes,
                    value: number_of(&cell.value, format!("cell-{}-{}", item.id, cell.person))?,
                })
            })
            .collect()
    };
    let mut people = Vec::new();
    for person in &input.people {
        let field = |name: &str| format!("{name}-{}", person.id);
        people.push(FilePerson {
            id: person.id,
            name: person.name.trim().to_string(),
            household: person.household.trim().to_string(),
            income: money_of(&person.income, field("income"))?,
            parts: number_of(&person.parts, field("parts"))?,
            percent: number_of(&person.percent, field("percent"))?,
            floor: money_of(&person.floor, field("floor"))?,
            cap: money_of(&person.cap, field("cap"))?,
            fixed: money_of(&person.fixed, field("fixed"))?,
            alone: money_of(&person.alone, field("alone"))?,
            gift: person.gift,
        });
    }
    let mut items = Vec::new();
    for item in &input.items {
        items.push(FileItem {
            id: item.id,
            label: item.label.trim().to_string(),
            amount: money_of(&item.amount, format!("amount-{}", item.id))?,
            rule: item.rule.clone(),
            cells: cells_of(item)?,
        });
    }
    let mut payments = Vec::new();
    for payment in &input.payments {
        payments.push(FilePayment {
            id: payment.id,
            person: payment.person,
            amount: money_of(&payment.amount, format!("payment-amount-{}", payment.id))?,
            date: payment.date.trim().to_string(),
            label: payment.label.trim().to_string(),
        });
    }
    let file = File {
        format: FILE_MARK.to_string(),
        version: FILE_VERSION,
        label: input.label.trim().to_string(),
        total: money_of(&input.total, "total".into())?,
        mode: Mode::from_key(&input.mode).key().to_string(),
        rule: Rule::from_key(&input.rule).key().to_string(),
        rounding: Rounding::from_key(&input.rounding).key().to_string(),
        show_incomes: input.show_incomes,
        people,
        common: FileItem { id: COMMON_ID, label: String::new(), amount: None, rule: input.common.rule.clone(), cells: cells_of(&input.common)? },
        items,
        payments,
    };
    Ok(serde_json::to_string_pretty(&file).unwrap_or_default())
}

/// Pourquoi un fichier ne s'ouvre pas.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FileRefusal {
    NotAProject,
    TooRecent,
}

impl FileRefusal {
    pub fn key(self) -> &'static str {
        match self {
            FileRefusal::NotAProject => "sharing-file-not-project",
            FileRefusal::TooRecent => "sharing-file-too-recent",
        }
    }
}

/// **Rouvre un projet** : les champs tels que la fenêtre les montre, dans la
/// langue en cours. Au-delà des limites, le surplus est laissé de côté.
pub fn from_file(text: &str, language: Language) -> Result<Input, FileRefusal> {
    let file: File = serde_json::from_str(text).map_err(|_| FileRefusal::NotAProject)?;
    if file.format != FILE_MARK {
        return Err(FileRefusal::NotAProject);
    }
    if file.version > FILE_VERSION {
        return Err(FileRefusal::TooRecent);
    }
    let money_text = |value: Option<f64>| {
        value.map(|value| money::format_plain((value * money::UNIT as f64).round() as i64, language)).unwrap_or_default()
    };
    let number_text = |value: Option<f64>| {
        value
            .map(|value| {
                let decimals = if value.fract() == 0.0 { 0 } else { 2 };
                crate::appliance::decimal(value, decimals, language)
            })
            .unwrap_or_default()
    };
    let cells = |cells: &[FileCell]| -> Vec<CellInput> {
        cells.iter().map(|cell| CellInput { person: cell.person, takes: cell.takes, value: number_text(cell.value) }).collect()
    };
    Ok(Input {
        label: file.label,
        total: money_text(file.total),
        mode: file.mode,
        rule: file.rule,
        rounding: file.rounding,
        show_incomes: file.show_incomes,
        people: file
            .people
            .iter()
            .take(PEOPLE_LIMIT)
            .map(|person| PersonInput {
                id: person.id,
                name: person.name.clone(),
                household: person.household.clone(),
                income: money_text(person.income),
                parts: number_text(person.parts),
                percent: number_text(person.percent),
                floor: money_text(person.floor),
                cap: money_text(person.cap),
                fixed: money_text(person.fixed),
                alone: money_text(person.alone),
                gift: person.gift,
            })
            .collect(),
        common: ItemInput { id: COMMON_ID, label: String::new(), amount: String::new(), rule: file.common.rule.clone(), cells: cells(&file.common.cells) },
        items: file
            .items
            .iter()
            .filter(|item| item.id != COMMON_ID)
            .take(ITEMS_LIMIT)
            .map(|item| ItemInput {
                id: item.id,
                label: item.label.clone(),
                amount: money_text(item.amount),
                rule: item.rule.clone(),
                cells: cells(&item.cells),
            })
            .collect(),
        payments: file
            .payments
            .iter()
            .take(PAYMENTS_LIMIT)
            .map(|payment| PaymentInput {
                id: payment.id,
                person: payment.person,
                amount: money_text(payment.amount),
                date: payment.date.clone(),
                label: payment.label.clone(),
            })
            .collect(),
    })
}

// --- Les rapports et le classeur --------------------------------------------------

/// Le nom de la règle, ou « une règle par poste ».
fn rule_text(plan: &Plan, language: Language) -> String {
    match plan.mode {
        Mode::Whole => i18n::text(language, &format!("sharing-rule-{}", plan.rule.key())),
        Mode::PerItem => i18n::text(language, "sharing-mode-item"),
    }
}

/// Une date comme ailleurs dans Radinus.
pub fn date_text(day: NaiveDate) -> String {
    day.format("%d/%m/%Y").to_string()
}

/// Le titre d'un rapport : le libellé du partage, ou le nom de l'outil.
pub fn title_of(plan: &Plan, language: Language) -> String {
    if plan.label.is_empty() {
        i18n::text(language, "window-sharing-title")
    } else {
        plan.label.clone()
    }
}

/// Le revenu sert-il quelque part ?
fn uses_income(plan: &Plan) -> bool {
    plan.items.iter().any(|item| item.amount > 0 && plan.rule_of(item) == Rule::Income)
}

/// Les règlements, par date — les non datés à la fin —, et par ordre de saisie.
fn payments_by_date(plan: &Plan) -> Vec<&Payment> {
    let mut payments: Vec<&Payment> = plan.payments.iter().collect();
    payments.sort_by_key(|payment| (payment.date.is_none(), payment.date));
    payments
}

/// Une ligne de règlement : la date, qui, combien, le libellé.
fn payment_row(plan: &Plan, payment: &Payment, language: Language) -> [String; 4] {
    [
        payment.date.map(date_text).unwrap_or_default(),
        plan.people[payment.person].name.clone(),
        money::format(payment.amount, language),
        payment.label.clone(),
    ]
}

/// Les couples du partage : le total, la règle, l'arrondi, les personnes.
fn sharing_pairs(computed: &Computed, language: Language) -> Vec<(String, String)> {
    let plan = &computed.plan;
    let text = |key: &str| i18n::text(language, key);
    vec![
        (text("sharing-field-total"), money::format(plan.total, language)),
        (text("sharing-field-rule"), rule_text(plan, language)),
        (text("sharing-field-rounding"), text(&format!("sharing-rounding-{}", plan.rounding.key()))),
        (text("sharing-field-people"), plan.people.len().to_string()),
    ]
}

/// La ligne d'une personne dans la répartition : nom, foyer, revenu (s'il se
/// montre), part, contrainte, à payer.
fn distribution_rows(computed: &Computed, language: Language) -> Vec<Vec<String>> {
    let plan = &computed.plan;
    let shares = &computed.shares;
    let households = plan.people.iter().any(|person| !person.household.is_empty());
    let incomes = plan.show_incomes && uses_income(plan);
    let alone = plan.people.iter().any(|person| person.alone > 0);
    plan.people
        .iter()
        .enumerate()
        .map(|(rank, person)| {
            let mut row = vec![person.name.clone()];
            if households {
                row.push(person.household.clone());
            }
            if incomes {
                row.push(person.income.map(|value| money::format(value, language)).unwrap_or_default());
            }
            row.push(percent_of(shares.shared[rank], plan.shared(), language));
            row.push(shares.constraint[rank].key().map(|key| i18n::text(language, key)).unwrap_or_default());
            if alone {
                row.push(if person.alone > 0 { money::format(person.alone, language) } else { String::new() });
            }
            row.push(money::format(shares.due[rank], language));
            row
        })
        .collect()
}

fn distribution_columns(computed: &Computed, language: Language) -> Vec<String> {
    let plan = &computed.plan;
    let text = |key: &str| i18n::text(language, key);
    let mut columns = vec![text("sharing-column-person")];
    if plan.people.iter().any(|person| !person.household.is_empty()) {
        columns.push(text("sharing-column-household"));
    }
    if plan.show_incomes && uses_income(plan) {
        columns.push(text("sharing-column-income"));
    }
    columns.push(text("sharing-column-share"));
    columns.push(text("sharing-column-constraint"));
    if plan.people.iter().any(|person| person.alone > 0) {
        columns.push(text("sharing-column-alone"));
    }
    columns.push(text("sharing-column-due"));
    columns
}

/// Un poste dans la répartition : son nom, son montant, sa règle, et ce que
/// chacun en paie.
fn item_blocks(computed: &Computed, language: Language) -> Vec<(String, String)> {
    let plan = &computed.plan;
    plan.items
        .iter()
        .enumerate()
        .filter(|(_, item)| item.amount > 0)
        .map(|(column, item)| {
            let mut head = format!("{} — {}", item_label(item, language), money::format(item.amount, language));
            if plan.mode == Mode::PerItem {
                head.push_str(&format!(" — {}", i18n::text(language, &format!("sharing-rule-{}", item.rule.key()))));
            }
            let who: Vec<String> = plan
                .people
                .iter()
                .enumerate()
                .filter(|(rank, _)| computed.shares.cells[*rank][column] > 0)
                .map(|(rank, person)| format!("{} {}", person.name, money::format(computed.shares.cells[rank][column], language)))
                .collect();
            (head, who.join(" · "))
        })
        .collect()
}

const PRELUDE: &str = r##"
#let nuit = rgb("#24506e")
#let encre = rgb("#1d2b34")
#let gris = rgb("#6b7a88")
#let filet = rgb("#e3e8ed")
#let fond = rgb("#f4f6f8")
#let dore = rgb("#c39a3c")

#set text(font: famille, size: 9pt, fill: encre, lang: langue)
#set par(leading: 0.55em, spacing: 0.9em)
#set page(
  paper: "a4",
  margin: (left: 42pt, right: 42pt, top: 42pt, bottom: 58pt),
  footer: context {
    set text(size: 7.5pt, fill: gris)
    line(length: 100%, stroke: 0.5pt + filet)
    v(4pt)
    grid(columns: (1fr, auto), pied,
      [#counter(page).display() / #counter(page).final().first()])
  },
)

#let titre-section(texte) = {
  v(14pt)
  block(below: 8pt, {
    text(size: 13pt, weight: "bold", fill: nuit, texte)
    v(-6pt)
    line(length: 36pt, stroke: 2pt + dore)
  })
}

#let encadre(texte) = block(width: 100%, fill: fond, radius: (right: 6pt), stroke: (left: 5pt + dore),
  inset: (x: 14pt, y: 10pt), text(size: 12pt, weight: "bold", fill: nuit, texte))

#let tableau(colonnes, lignes, droite: ()) = table(
  columns: colonnes.map(c => auto).enumerate().map(((i, c)) => if i == 0 { 1fr } else { auto }),
  stroke: none,
  inset: (x: 6pt, y: 4pt),
  align: (x, y) => if droite.contains(x) { right } else { left },
  fill: (x, y) => if y == 0 { nuit } else if calc.even(y) { fond } else { white },
  table.header(..colonnes.map(c => text(fill: white, weight: "bold", c))),
  ..lignes.flatten(),
)

#block(width: 100%, fill: nuit, radius: 8pt, inset: (x: 16pt, y: 14pt), grid(
  columns: (auto, 1fr), column-gutter: 14pt, align: horizon,
  box(fill: white, radius: 6pt, inset: 4pt, image(logo, height: 46pt)),
  {
    text(size: 20pt, weight: "bold", fill: white, titre)
    v(-4pt)
    text(size: 10pt, fill: rgb("#d5e2ec"), sous-titre)
  },
))
"##;

/// Le début de toute source : les mots du rapport, puis le prélude.
fn head(language: Language, title: &str, subtitle: &str, footer: &str) -> String {
    let q = printing::quoted;
    let mut out = String::new();
    for (name, value) in [
        ("famille", printing::FAMILY.to_string()),
        ("langue", language.tag().to_string()),
        ("logo", printing::LOGO_PATH.to_string()),
        ("titre", title.to_string()),
        ("sous-titre", subtitle.to_string()),
        ("pied", footer.to_string()),
    ] {
        out.push_str(&format!("#let {name} = {}\n", q(&value)));
    }
    out.push_str(PRELUDE);
    out
}

/// Une liste de chaînes en Typst : `("a", "b",)`.
fn list(values: &[String]) -> String {
    let mut out = String::from("(");
    for value in values {
        out.push_str(&printing::quoted(value));
        out.push_str(", ");
    }
    out.push(')');
    out
}

/// Un tableau de lignes en Typst.
fn rows_of(rows: &[Vec<String>]) -> String {
    let mut out = String::from("(");
    for row in rows {
        out.push_str(&list(row));
        out.push_str(", ");
    }
    out.push(')');
    out
}

/// Une suite de paragraphes discrets.
fn small_lines(values: &[String]) -> String {
    if values.is_empty() {
        return String::new();
    }
    format!(
        "#block({{ set text(size: 8pt, fill: gris); for note in {} {{ [• #note]; linebreak() }} }})\n",
        list(values)
    )
}

/// **La répartition générale** : qui doit payer quoi, sans les règlements.
pub fn distribution_pdf(computed: &Computed, language: Language) -> Result<Vec<u8>, Failure> {
    let text = |key: &str| i18n::text(language, key);
    let written = write(computed, &computed.plan, language);
    let title = title_of(&computed.plan, language);
    let mut out = head(language, &text("sharing-report-distribution"), &title, &title);
    let pairs: Vec<Vec<String>> = sharing_pairs(computed, language).into_iter().map(|(a, b)| vec![a, b]).collect();
    out.push_str(&format!(
        "#titre-section({})\n#table(columns: (auto, 1fr), stroke: none, inset: (x: 0pt, y: 3.5pt), column-gutter: 14pt, ..{}.map(c => (text(fill: gris, c.at(0)), text(weight: \"bold\", c.at(1)))).flatten())\n",
        printing::quoted(&text("sharing-report-sharing")),
        rows_of(&pairs)
    ));
    out.push_str(&format!("#v(6pt)\n#encadre({})\n", printing::quoted(&written.headline)));
    let columns = distribution_columns(computed, language);
    // Les montants et la part s'alignent à droite.
    let share = columns.iter().position(|column| *column == text("sharing-column-share")).unwrap_or(0);
    let mut right = vec![share.to_string(), (columns.len() - 1).to_string()];
    if columns.len() - share == 4 {
        right.push((columns.len() - 2).to_string());
    }
    out.push_str(&format!(
        "#titre-section({})\n#tableau({}, {}, droite: ({},))\n",
        printing::quoted(&text("sharing-report-who-pays")),
        list(&columns),
        rows_of(&distribution_rows(computed, language)),
        right.join(", ")
    ));
    out.push_str(&format!("#titre-section({})\n", printing::quoted(&text("sharing-report-items"))));
    for (headline, who) in item_blocks(computed, language) {
        out.push_str(&format!(
            "#block(breakable: false, below: 8pt, {{ text(weight: \"bold\", fill: nuit, {}); linebreak(); text(fill: encre, {}) }})\n",
            printing::quoted(&headline),
            printing::quoted(&who)
        ));
    }
    out.push_str(&small_lines(&written.notes));
    printing::compose(out, "radinus-partage")
}

/// **L'état des paiements**, daté : ce qui a été versé, qui doit encore, les
/// règlements, et les virements ou ce qui reste.
pub fn payments_pdf(computed: &Computed, today: NaiveDate, language: Language) -> Result<Vec<u8>, Failure> {
    let text = |key: &str| i18n::text(language, key);
    let plan = &computed.plan;
    let written = write(computed, plan, language);
    let title = title_of(plan, language);
    let subtitle = format!("{} — {}", title, i18n::text_with(language, "sharing-report-as-of", "date", &date_text(today)));
    let mut out = head(language, &text("sharing-report-payments"), &subtitle, &title);
    let mut lines = written.summary.clone();
    if let Some(warning) = &written.warning {
        lines.push(warning.clone());
    }
    for line in &lines {
        out.push_str(&format!("#encadre({})\n#v(4pt)\n", printing::quoted(line)));
    }
    let units: Vec<Vec<String>> = written
        .units
        .iter()
        .map(|unit| vec![unit.name.clone(), unit.members.clone(), unit.due.clone(), unit.paid.clone(), unit.balance.clone()])
        .collect();
    out.push_str(&format!(
        "#titre-section({})\n#tableau({}, {}, droite: (2, 3))\n",
        printing::quoted(&text("sharing-report-balances")),
        list(&[
            text("sharing-column-unit"),
            text("sharing-column-members"),
            text("sharing-column-due"),
            text("sharing-column-paid"),
            text("sharing-column-balance"),
        ]),
        rows_of(&units)
    ));
    let payments: Vec<Vec<String>> = payments_by_date(plan).into_iter().map(|payment| payment_row(plan, payment, language).to_vec()).collect();
    out.push_str(&format!("#titre-section({})\n", printing::quoted(&text("sharing-payments-title"))));
    if payments.is_empty() {
        out.push_str(&format!("#text(fill: gris, {})\n", printing::quoted(&text("sharing-payments-none"))));
    } else {
        out.push_str(&format!(
            "#tableau({}, {}, droite: (2,))\n",
            list(&[
                text("sharing-column-date"),
                text("sharing-column-who"),
                text("sharing-column-amount"),
                text("sharing-column-label"),
            ]),
            rows_of(&payments)
        ));
    }
    if !written.transfers.is_empty() {
        out.push_str(&format!("#titre-section({})\n", printing::quoted(&text("sharing-transfers-title"))));
        for line in &written.transfers {
            out.push_str(&format!("#text(weight: \"bold\", {})\n#linebreak()\n", printing::quoted(line)));
        }
    }
    out.push_str(&small_lines(&written.notes));
    printing::compose(out, "radinus-partage-paiements")
}

/// **Le relevé d'un foyer** — ou d'une personne seule : sa part poste par
/// poste, ses règlements, ce qui lui reste. Rien sur les autres, et jamais un
/// revenu.
pub fn statement_pdf(computed: &Computed, unit: usize, today: NaiveDate, language: Language) -> Result<Vec<u8>, Failure> {
    let text = |key: &str| i18n::text(language, key);
    let plan = &computed.plan;
    let the_unit = &computed.units[unit];
    let title = title_of(plan, language);
    let subtitle = format!("{} — {}", title, i18n::text_with(language, "sharing-report-as-of", "date", &date_text(today)));
    let mut out = head(
        language,
        &i18n::text_with(language, "sharing-report-statement", "name", &the_unit.name),
        &subtitle,
        &title,
    );
    let (balance, _) = balance_text(the_unit, language);
    out.push_str(&format!("#encadre({})\n", printing::quoted(&balance)));
    out.push_str(&format!("#titre-section({})\n", printing::quoted(&text("sharing-report-your-share"))));
    for &rank in &the_unit.members {
        let mut rows: Vec<Vec<String>> = detail_of(computed, rank, language).into_iter().map(|(a, b)| vec![a, b]).collect();
        rows.push(vec![text("sharing-column-due"), money::format(computed.shares.due[rank], language)]);
        out.push_str(&format!(
            "#tableau({}, {}, droite: (1,))\n#v(4pt)\n",
            list(&[plan.people[rank].name.clone(), String::new()]),
            rows_of(&rows)
        ));
    }
    if the_unit.members.len() > 1 {
        out.push_str(&format!(
            "#text(weight: \"bold\", {})\n",
            printing::quoted(&i18n::text_with(language, "sharing-statement-total", "amount", &money::format(the_unit.due, language)))
        ));
    }
    let payments: Vec<Vec<String>> = payments_by_date(plan)
        .into_iter()
        .filter(|payment| the_unit.members.contains(&payment.person))
        .map(|payment| payment_row(plan, payment, language).to_vec())
        .collect();
    out.push_str(&format!("#titre-section({})\n", printing::quoted(&text("sharing-payments-title"))));
    if payments.is_empty() {
        out.push_str(&format!("#text(fill: gris, {})\n", printing::quoted(&text("sharing-payments-none"))));
    } else {
        out.push_str(&format!(
            "#tableau({}, {}, droite: (2,))\n",
            list(&[
                text("sharing-column-date"),
                text("sharing-column-who"),
                text("sharing-column-amount"),
                text("sharing-column-label"),
            ]),
            rows_of(&payments)
        ));
    }
    let mut moves = Vec::new();
    for transfer in &computed.transfers {
        if transfer.from == unit {
            moves.push(i18n::message_of(
                language,
                "sharing-statement-pay",
                &[("name", &computed.units[transfer.to].name), ("amount", &money::format(transfer.amount, language))],
                &[],
            ));
        } else if transfer.to == unit {
            moves.push(i18n::message_of(
                language,
                "sharing-statement-receive",
                &[("name", &computed.units[transfer.from].name), ("amount", &money::format(transfer.amount, language))],
                &[],
            ));
        }
    }
    if !moves.is_empty() {
        out.push_str(&format!("#titre-section({})\n", printing::quoted(&text("sharing-transfers-title"))));
        for line in &moves {
            out.push_str(&format!("#text(weight: \"bold\", {})\n#linebreak()\n", printing::quoted(line)));
        }
    }
    printing::compose(out, "radinus-partage-releve")
}

/// **Le classeur** : Personnes, Postes, Résultat, Règlements, Remboursements.
/// Des valeurs, pas des formules.
pub fn book(computed: &Computed, language: Language) -> Vec<Sheet> {
    let text = |key: &str| i18n::text(language, key);
    let bold = |key: &str| SheetCell::text(text(key)).with_bold(true);
    let plan = &computed.plan;
    let shares = &computed.shares;
    let incomes = plan.show_incomes;
    let optional_money = |value: Option<i64>| value.map_or_else(SheetCell::empty, SheetCell::money);
    let optional_number = |value: Option<f64>| value.map_or_else(SheetCell::empty, SheetCell::number);

    let mut people = Sheet::new(text("sharing-sheet-people"));
    people.header_rows = 1;
    let mut head = vec![bold("sharing-column-person"), bold("sharing-column-household")];
    if incomes {
        head.push(bold("sharing-column-income"));
    }
    for key in [
        "sharing-column-parts",
        "sharing-column-percent",
        "sharing-column-floor",
        "sharing-column-cap",
        "sharing-column-fixed",
        "sharing-column-alone",
        "sharing-column-gift",
    ] {
        head.push(bold(key));
    }
    people.rows.push(head);
    for (rank, person) in plan.people.iter().enumerate() {
        let mut row = vec![SheetCell::text(person.name.clone()), SheetCell::text(person.household.clone())];
        if incomes {
            row.push(optional_money(person.income));
        }
        row.push(optional_number(person.parts));
        row.push(optional_number(person.percent));
        row.push(optional_money(person.floor));
        row.push(optional_money(person.cap));
        row.push(optional_money(if computed.gifted[rank] { None } else { person.fixed }));
        row.push(if person.alone > 0 { SheetCell::money(person.alone) } else { SheetCell::empty() });
        row.push(SheetCell::text(if person.gift { text("ui-yes") } else { String::new() }));
        people.rows.push(row);
    }

    let mut items = Sheet::new(text("sharing-sheet-items"));
    items.header_rows = 1;
    items.widths = vec![30.0, 14.0, 26.0, 14.0];
    items.rows.push(vec![
        bold("sharing-column-item"),
        bold("sharing-column-amount"),
        bold("sharing-column-rule"),
        bold("sharing-column-participants"),
    ]);
    for item in &plan.items {
        items.rows.push(vec![
            SheetCell::text(item_label(item, language)),
            SheetCell::money(item.amount),
            SheetCell::text(match plan.mode {
                Mode::Whole => text(&format!("sharing-rule-{}", plan.rule.key())),
                Mode::PerItem => text(&format!("sharing-rule-{}", item.rule.key())),
            }),
            SheetCell::number(item.cells.iter().filter(|cell| cell.takes).count() as f64),
        ]);
    }

    let mut result = Sheet::new(text("sharing-sheet-result"));
    result.header_rows = 1;
    let mut head = vec![bold("sharing-column-person")];
    for item in &plan.items {
        head.push(SheetCell::text(item_label(item, language)).with_bold(true));
    }
    for key in ["sharing-outside", "sharing-alone", "sharing-rounding", "sharing-column-due", "sharing-column-constraint"] {
        head.push(bold(key));
    }
    result.rows.push(head);
    for (rank, person) in plan.people.iter().enumerate() {
        let mut row = vec![SheetCell::text(person.name.clone())];
        for (column, item) in plan.items.iter().enumerate() {
            row.push(if item.cells[rank].takes { SheetCell::money(shares.cells[rank][column]) } else { SheetCell::empty() });
        }
        row.push(SheetCell::money(shares.outside[rank]));
        row.push(SheetCell::money(person.alone));
        row.push(SheetCell::money(shares.rounding[rank]));
        row.push(SheetCell::money(shares.due[rank]).with_bold(true));
        row.push(SheetCell::text(shares.constraint[rank].key().map(text).unwrap_or_default()));
        result.rows.push(row);
    }
    let mut total = vec![bold("sharing-field-total")];
    for item in &plan.items {
        total.push(SheetCell::money(item.amount).with_bold(true));
    }
    total.push(SheetCell::money(shares.outside.iter().sum::<i64>()));
    total.push(SheetCell::money(plan.people.iter().map(|person| person.alone).sum::<i64>()));
    total.push(SheetCell::money(shares.rounding.iter().sum::<i64>()));
    total.push(SheetCell::money(plan.total).with_bold(true));
    result.rows.push(total);

    let mut payments = Sheet::new(text("sharing-sheet-payments"));
    payments.header_rows = 1;
    payments.widths = vec![12.0, 24.0, 14.0, 36.0];
    payments.rows.push(vec![
        bold("sharing-column-date"),
        bold("sharing-column-who"),
        bold("sharing-column-amount"),
        bold("sharing-column-label"),
    ]);
    for payment in payments_by_date(plan) {
        payments.rows.push(vec![
            SheetCell::text(payment.date.map(date_text).unwrap_or_default()),
            SheetCell::text(plan.people[payment.person].name.clone()),
            SheetCell::money(payment.amount),
            SheetCell::text(payment.label.clone()),
        ]);
    }

    let mut balances = Sheet::new(text("sharing-sheet-balances"));
    balances.header_rows = 1;
    balances.widths = vec![26.0, 36.0, 14.0, 14.0, 14.0];
    balances.rows.push(vec![
        bold("sharing-column-unit"),
        bold("sharing-column-members"),
        bold("sharing-column-due"),
        bold("sharing-column-paid"),
        bold("sharing-column-balance"),
    ]);
    for unit in &computed.units {
        balances.rows.push(vec![
            SheetCell::text(unit.name.clone()),
            SheetCell::text(if unit.is_household() {
                unit.members.iter().map(|&rank| plan.people[rank].name.clone()).collect::<Vec<_>>().join(", ")
            } else {
                String::new()
            }),
            SheetCell::money(unit.due),
            SheetCell::money(unit.paid),
            SheetCell::money(unit.balance()),
        ]);
    }
    let written = write(computed, plan, language);
    if !written.summary.is_empty() || !written.transfers.is_empty() {
        balances.rows.push(Vec::new());
        for line in written.summary.iter().chain(written.transfers.iter()) {
            balances.rows.push(vec![SheetCell::text(line.clone())]);
        }
    }
    vec![people, items, result, payments, balances]
}

/// **Le nom d'une personne ajoutée** : « Personne 3 », le premier numéro qu'aucun
/// nom ne porte déjà. La fenêtre ne compose aucune phrase ; elle le demande.
pub fn next_name(input: &Input, language: Language) -> String {
    let taken: Vec<String> = input.people.iter().map(|person| folded(&person.name)).collect();
    (input.people.len() + 1..)
        .map(|number| i18n::message_of(language, "sharing-person-default", &[], &[("number", number as i64)]))
        .find(|name| !taken.contains(&folded(name)))
        .unwrap_or_default()
}

// --- Les conseils (Fabrice, 11/10/2026, P-72) -----------------------------------
//
// « C'est lui qui est obligé de calculer les parts, probablement avec une
// calculatrice… Il faudrait afficher des valeurs conseillées. » Le noyau dit
// en clair ce que la règle donne, et propose des chiffres pour les cases
// vides. **Un conseil n'est jamais enregistré** : il est recalculé à chaque
// geste, et il ne compte que si on le reprend. Il se donne même quand le
// partage est refusé — c'est quand les pourcentages ne font pas 100 % qu'on en
// a le plus besoin —, si bien qu'il lit les champs avec indulgence : un champ
// illisible compte comme vide.

/// Une valeur conseillée pour une case : la personne, et pour une case de
/// poste, le poste.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Suggested {
    pub person: u32,
    /// `None` : la colonne de la personne (pourcentage ou parts de toute la
    /// dépense) ; `Some` : la case d'un poste.
    pub item: Option<u32>,
    pub value: String,
}

/// La phrase d'un poste, en mode « une règle par poste ».
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct ItemAdvice {
    pub id: u32,
    pub sentence: String,
    /// Un avertissement plutôt qu'une phrase : quelqu'un ne paierait rien.
    pub warn: bool,
}

/// **Les conseils.**
#[derive(Debug, Clone, Default, PartialEq, Eq, serde::Serialize)]
pub struct Advice {
    /// La phrase sous la règle de toute la dépense ; vide par poste.
    pub sentence: String,
    pub warn: bool,
    pub items: Vec<ItemAdvice>,
    /// Les valeurs conseillées des cases vides.
    pub suggested: Vec<Suggested>,
    /// Des pourcentages d'après les revenus, qui font 100 % — vide si un revenu
    /// manque ou si la règle n'est pas en pourcentages.
    pub from_incomes: Vec<Suggested>,
}

/// Un nombre écrit pour une case : « 25 », « 33,34 ».
fn figure(value: f64, language: Language) -> String {
    let rounded = (value * 100.0).round() / 100.0;
    let decimals = if (rounded - rounded.round()).abs() < 1e-9 {
        0
    } else if ((rounded * 10.0) - (rounded * 10.0).round()).abs() < 1e-9 {
        1
    } else {
        2
    };
    crate::appliance::decimal(rounded, decimals, language)
}

/// Partage `whole` centièmes entre `count` cases, au plus gros reste : à
/// trois, 100 % donne 33,34 / 33,33 / 33,33 — le total tombe juste.
fn hundredths(whole: i64, count: usize) -> Vec<i64> {
    if count == 0 {
        return Vec::new();
    }
    let base = whole / count as i64;
    let extra = (whole % count as i64) as usize;
    (0..count).map(|rank| base + i64::from(rank < extra)).collect()
}

/// Ce que l'indulgence lit d'un partage tapé.
struct Lenient {
    ids: Vec<u32>,
    names: Vec<String>,
    income: Vec<Option<i64>>,
    parts: Vec<Option<f64>>,
    percent: Vec<Option<f64>>,
    limited: Vec<bool>,
    fixed: Vec<bool>,
    /// Les postes, le commun d'abord.
    items: Vec<LenientItem>,
}

/// Un poste lu avec indulgence : id, montant, règle, et pour chaque personne
/// si elle y prend part et le nombre tapé dans sa case.
type LenientItem = (u32, i64, Rule, Vec<(bool, Option<f64>)>);

fn lenient(input: &Input) -> Lenient {
    let money = |text: &str| amount_field(text).ok().flatten();
    let number = |text: &str| number_field(text).ok().flatten();
    let people = &input.people;
    let cells = |item: &ItemInput| -> Vec<(bool, Option<f64>)> {
        people
            .iter()
            .map(|person| {
                let cell = item.cells.iter().find(|cell| cell.person == person.id);
                (cell.is_none_or(|cell| cell.takes), cell.and_then(|cell| number(&cell.value)))
            })
            .collect()
    };
    let alone: i64 = people.iter().filter_map(|person| money(&person.alone)).sum();
    let carved: i64 = input.items.iter().filter_map(|item| money(&item.amount)).sum::<i64>() + alone;
    let total = money(&input.total).unwrap_or(carved);
    let mut items = vec![(COMMON_ID, (total - carved).max(0), Rule::from_key(&input.common.rule), cells(&input.common))];
    for item in &input.items {
        items.push((item.id, money(&item.amount).unwrap_or(0), Rule::from_key(&item.rule), cells(item)));
    }
    Lenient {
        ids: people.iter().map(|person| person.id).collect(),
        names: people.iter().map(|person| person.name.trim().to_string()).collect(),
        income: people.iter().map(|person| money(&person.income)).collect(),
        parts: people.iter().map(|person| number(&person.parts)).collect(),
        percent: people.iter().map(|person| number(&person.percent)).collect(),
        limited: people
            .iter()
            .map(|person| [&person.floor, &person.cap, &person.fixed].iter().any(|text| money(text).is_some()))
            .collect(),
        fixed: people.iter().map(|person| money(&person.fixed).is_some()).collect(),
        items,
    }
}

/// **La phrase d'une règle** sur une somme et ses participants : ce que
/// donnent les parts égales, ce que vaut une part, ce qui reste des
/// pourcentages, ce que chacun paie de son revenu. `plain` : tout le monde
/// participe à tout et aucune limite ne joue — sinon la phrase reste générale
/// plutôt que de donner un chiffre faux. Rend aussi les valeurs conseillées
/// des cases vides, et si quelqu'un ne paierait rien.
#[allow(clippy::too_many_arguments)]
fn rule_advice(
    rule: Rule,
    amount: i64,
    takers: &[usize],
    plain: bool,
    lenient: &Lenient,
    typed: &dyn Fn(usize) -> Option<f64>,
    language: Language,
) -> (String, bool, Vec<(usize, String)>) {
    let money_text = |value: f64| money::format(round_to(value.round() as i64, CENT), language);
    let say = |key: &str, texts: &[(&str, &str)], numbers: &[(&str, i64)]| i18n::message_of(language, key, texts, numbers);
    let payers: Vec<usize> = takers.iter().copied().filter(|&rank| !lenient.fixed[rank]).collect();
    if amount <= 0 && rule != Rule::Percent {
        return (say("sharing-advice-empty", &[], &[]), false, Vec::new());
    }
    match rule {
        Rule::Equal => {
            if plain && !payers.is_empty() {
                let each = amount as f64 / payers.len() as f64;
                (
                    say(
                        "sharing-advice-equal",
                        &[("total", &money_text(amount as f64)), ("amount", &money_text(each))],
                        &[("count", payers.len() as i64)],
                    ),
                    false,
                    Vec::new(),
                )
            } else {
                (say("sharing-advice-equal-varied", &[], &[]), false, Vec::new())
            }
        }
        Rule::Parts => {
            let suggested: Vec<(usize, String)> =
                payers.iter().filter(|&&rank| typed(rank).is_none()).map(|&rank| (rank, "1".to_string())).collect();
            let parts: f64 = payers.iter().map(|&rank| typed(rank).unwrap_or(1.0)).sum();
            if plain && parts > 0.0 {
                (
                    say(
                        "sharing-advice-parts",
                        &[("parts", &figure(parts, language)), ("amount", &money_text(amount as f64 / parts))],
                        &[],
                    ),
                    false,
                    suggested,
                )
            } else {
                (say("sharing-advice-parts-varied", &[], &[]), false, suggested)
            }
        }
        Rule::Percent => {
            let sum: f64 = payers.iter().filter_map(|&rank| typed(rank)).sum();
            let empty: Vec<usize> = payers.iter().copied().filter(|&rank| typed(rank).is_none()).collect();
            let rest = ((100.0 - sum) * 100.0).round() as i64;
            if rest > 0 {
                let shares = hundredths(rest, empty.len());
                let suggested = empty.iter().zip(shares).map(|(&rank, share)| (rank, figure(share as f64 / 100.0, language))).collect();
                (say("sharing-advice-percent-rest", &[("rest", &figure(rest as f64 / 100.0, language))], &[]), false, suggested)
            } else if rest < 0 {
                (say("sharing-advice-percent-over", &[("over", &figure(-rest as f64 / 100.0, language))], &[]), true, Vec::new())
            } else {
                let nobody: Vec<String> = payers
                    .iter()
                    .filter(|&&rank| typed(rank).unwrap_or(0.0) <= 0.0)
                    .map(|&rank| lenient.names[rank].clone())
                    .collect();
                if nobody.is_empty() {
                    (say("sharing-advice-percent-ok", &[], &[]), false, Vec::new())
                } else {
                    (
                        say(
                            "sharing-advice-percent-nobody",
                            &[("names", &joined(&nobody, language))],
                            &[("count", nobody.len() as i64)],
                        ),
                        true,
                        Vec::new(),
                    )
                }
            }
        }
        Rule::Income => {
            let incomes: Vec<Option<i64>> = payers.iter().map(|&rank| lenient.income[rank]).collect();
            if incomes.iter().any(Option::is_none) {
                return (say("sharing-advice-income-missing", &[], &[]), false, Vec::new());
            }
            let all: i64 = incomes.iter().flatten().sum();
            if plain && all > 0 {
                let rate = amount as f64 / all as f64 * 100.0;
                (
                    say("sharing-advice-income", &[("rate", &crate::appliance::decimal(rate, 1, language))], &[]),
                    false,
                    Vec::new(),
                )
            } else {
                (say("sharing-advice-income-varied", &[], &[]), false, Vec::new())
            }
        }
    }
}

/// **Les conseils d'un partage tapé** — même refusé.
pub fn advise(input: &Input, language: Language) -> Advice {
    let lenient = lenient(input);
    let people = lenient.ids.len();
    if people == 0 {
        return Advice::default();
    }
    let mode = Mode::from_key(&input.mode);
    let mut advice = Advice::default();
    match mode {
        Mode::Whole => {
            let rule = Rule::from_key(&input.rule);
            let shared: i64 = lenient.items.iter().map(|(_, amount, _, _)| amount).sum();
            let everyone = lenient
                .items
                .iter()
                .filter(|(_, amount, _, _)| *amount > 0)
                .all(|(_, _, _, cells)| cells.iter().all(|(takes, _)| *takes));
            let plain = everyone && !lenient.limited.iter().any(|&limited| limited);
            let takers: Vec<usize> = (0..people).collect();
            let typed = |rank: usize| match rule {
                Rule::Parts => lenient.parts[rank],
                Rule::Percent => lenient.percent[rank],
                _ => None,
            };
            let (sentence, warn, suggested) = rule_advice(rule, shared, &takers, plain, &lenient, &typed, language);
            advice.sentence = sentence;
            advice.warn = warn;
            advice.suggested =
                suggested.into_iter().map(|(rank, value)| Suggested { person: lenient.ids[rank], item: None, value }).collect();
            if rule == Rule::Percent {
                advice.from_incomes = from_incomes(&lenient, language);
            }
        }
        Mode::PerItem => {
            for (id, amount, rule, cells) in &lenient.items {
                let takers: Vec<usize> = (0..people).filter(|&rank| cells[rank].0).collect();
                let plain = !takers.iter().any(|&rank| lenient.limited[rank]);
                let typed = |rank: usize| match rule {
                    Rule::Parts => cells[rank].1.or(lenient.parts[rank]),
                    Rule::Percent => cells[rank].1,
                    _ => None,
                };
                // Un poste sans montant n'a rien à conseiller — le calcul ne le
                // vérifie pas non plus —, sauf le commun tant que rien n'est tapé.
                if *amount <= 0 && (*id != COMMON_ID || lenient.items.iter().any(|(_, other, _, _)| *other > 0)) {
                    continue;
                }
                let (sentence, warn, suggested) = rule_advice(*rule, *amount, &takers, plain, &lenient, &typed, language);
                advice.items.push(ItemAdvice { id: *id, sentence, warn });
                advice.suggested.extend(
                    suggested.into_iter().map(|(rank, value)| Suggested { person: lenient.ids[rank], item: Some(*id), value }),
                );
            }
        }
    }
    advice
}

/// **Des pourcentages d'après les revenus**, qui font exactement 100 % : à
/// arrondir ensuite à la main si l'on veut. Rien si un revenu manque.
fn from_incomes(lenient: &Lenient, language: Language) -> Vec<Suggested> {
    let payers: Vec<usize> = (0..lenient.ids.len()).filter(|&rank| !lenient.fixed[rank]).collect();
    if payers.is_empty() || payers.iter().any(|&rank| lenient.income[rank].is_none()) {
        return Vec::new();
    }
    let all: i64 = payers.iter().filter_map(|&rank| lenient.income[rank]).sum();
    if all <= 0 {
        return Vec::new();
    }
    let exact: Vec<f64> = payers.iter().map(|&rank| lenient.income[rank].unwrap_or(0) as f64 / all as f64 * 10_000.0).collect();
    let mut shares: Vec<i64> = exact.iter().map(|value| value.floor() as i64).collect();
    let mut left = 10_000 - shares.iter().sum::<i64>();
    let mut order: Vec<usize> = (0..payers.len()).collect();
    order.sort_by(|&a, &b| {
        (exact[b] - exact[b].floor()).partial_cmp(&(exact[a] - exact[a].floor())).unwrap_or(std::cmp::Ordering::Equal).then(a.cmp(&b))
    });
    for &rank in order.iter().cycle() {
        if left <= 0 {
            break;
        }
        shares[rank] += 1;
        left -= 1;
    }
    payers
        .iter()
        .zip(shares)
        .map(|(&rank, share)| Suggested { person: lenient.ids[rank], item: None, value: figure(share as f64 / 100.0, language) })
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    const FR: Language = Language::French;
    const EURO: i64 = money::UNIT;

    fn person(id: u32, name: &str) -> PersonInput {
        PersonInput { id, name: name.into(), ..PersonInput::default() }
    }

    fn input(people: Vec<PersonInput>, total: &str) -> Input {
        Input {
            label: "Restaurant".into(),
            total: total.into(),
            mode: "whole".into(),
            rule: "equal".into(),
            rounding: "cent".into(),
            people,
            ..Input::default()
        }
    }

    fn item(id: u32, label: &str, amount: &str, takers: &[u32], everyone: &[u32]) -> ItemInput {
        ItemInput {
            id,
            label: label.into(),
            amount: amount.into(),
            rule: "equal".into(),
            cells: everyone.iter().map(|&person| CellInput { person, takes: takers.contains(&person), value: String::new() }).collect(),
        }
    }

    fn pay(id: u32, person: u32, amount: &str) -> PaymentInput {
        PaymentInput { id, person, amount: amount.into(), ..PaymentInput::default() }
    }

    fn run(input: &Input) -> Computed {
        let plan = read(input, FR).expect("lu");
        compute(&plan, FR).expect("partagé")
    }

    fn refused(input: &Input) -> Refusal {
        match read(input, FR) {
            Err(refusal) => refusal,
            Ok(plan) => compute(&plan, FR).expect_err("refusé"),
        }
    }

    fn euros(value: i64) -> f64 {
        value as f64 / EURO as f64
    }

    fn dues(computed: &Computed) -> Vec<f64> {
        computed.shares.due.iter().map(|&value| euros(value)).collect()
    }

    /// Chaque poste tombe juste, et la somme des parts fait le total.
    fn exact(computed: &Computed) {
        for (column, item) in computed.plan.items.iter().enumerate() {
            let sum: i64 = computed.shares.cells.iter().map(|row| row[column]).sum();
            assert_eq!(sum, item.amount, "le poste {} ne tombe pas juste", item.label);
        }
        assert_eq!(computed.shares.due.iter().sum::<i64>(), computed.plan.total, "le total ne tombe pas juste");
    }

    #[test]
    fn au_restaurant_le_vin_ne_se_partage_qu_entre_buveurs() {
        let mut typed = input(vec![person(1, "A"), person(2, "B"), person(3, "C"), person(4, "D")], "240");
        typed.items.push(item(1, "Vin", "60", &[1, 2], &[1, 2, 3, 4]));
        typed.people[3].alone = "12".into();
        let computed = run(&typed);
        exact(&computed);
        assert_eq!(dues(&computed), vec![72.0, 72.0, 42.0, 54.0]);
        assert_eq!(computed.plan.items[0].amount, 168 * EURO, "le commun est ce qui reste");
    }

    #[test]
    fn au_prorata_des_revenus_un_plafond_retombe_sur_les_autres() {
        let mut typed = input(vec![person(1, "A"), person(2, "B"), person(3, "C"), person(4, "D")], "1000");
        typed.rule = "income".into();
        for (rank, income) in ["3000", "2000", "1500", "1500"].iter().enumerate() {
            typed.people[rank].income = (*income).into();
        }
        let free = run(&typed);
        assert_eq!(dues(&free), vec![375.0, 250.0, 187.5, 187.5]);
        typed.people[2].cap = "150".into();
        let capped = run(&typed);
        exact(&capped);
        assert_eq!(dues(&capped), vec![392.31, 261.54, 150.0, 196.15]);
        assert_eq!(capped.shares.constraint[2], Constraint::Cap);
    }

    #[test]
    fn les_pourcentages_doivent_faire_cent() {
        let mut typed = input(vec![person(1, "Léa"), person(2, "Paul")], "100");
        typed.rule = "percent".into();
        typed.people[0].percent = "40".into();
        typed.people[1].percent = "50".into();
        let refusal = refused(&typed);
        assert!(refusal.message.contains("90 %"), "{}", refusal.message);
        typed.people[1].percent = "60".into();
        assert_eq!(dues(&run(&typed)), vec![40.0, 60.0]);
    }

    #[test]
    fn une_exclusion_sous_des_pourcentages_globaux_se_dit() {
        let mut typed = input(vec![person(1, "Léa"), person(2, "Paul"), person(3, "Zoé")], "160");
        typed.rule = "percent".into();
        for (rank, value) in ["25", "25", "50"].iter().enumerate() {
            typed.people[rank].percent = (*value).into();
        }
        typed.items.push(item(1, "Bateau", "60", &[2, 3], &[1, 2, 3]));
        let computed = run(&typed);
        exact(&computed);
        // Commun 100 : 25 / 25 / 50 ; bateau 60 entre Paul et Zoé : 20 / 40.
        assert_eq!(dues(&computed), vec![25.0, 45.0, 90.0]);
        assert!(!computed.plan.items[1].cells[0].takes);
        let written = write(&computed, &computed.plan, FR);
        assert!(written.notes.iter().any(|note| note.contains("Léa ne participe pas à « Bateau »")), "{:?}", written.notes);
    }

    #[test]
    fn par_poste_chaque_poste_a_ses_pourcentages_et_ses_parts() {
        let mut typed = input(vec![person(1, "A"), person(2, "B")], "");
        typed.mode = "item".into();
        typed.common.rule = "equal".into();
        let mut wine = item(1, "Vin", "40", &[1, 2], &[1, 2]);
        wine.rule = "parts".into();
        wine.cells[0].value = "1".into();
        wine.cells[1].value = "3".into();
        let mut room = item(2, "Chambre", "100", &[1, 2], &[1, 2]);
        room.rule = "percent".into();
        room.cells[0].value = "70".into();
        room.cells[1].value = "20".into();
        typed.items = vec![wine.clone(), room.clone()];
        let refusal = refused(&typed);
        assert!(refusal.message.contains("« Chambre »") && refusal.message.contains("90 %"), "{}", refusal.message);
        room.cells[1].value = "30".into();
        typed.items = vec![wine, room];
        let computed = run(&typed);
        exact(&computed);
        assert_eq!(dues(&computed), vec![80.0, 60.0]);
        assert_eq!(computed.plan.total, 140 * EURO, "sans total tapé, le total est la somme des postes");
    }

    #[test]
    fn celui_qui_se_desiste_laisse_son_acompte_hors_postes() {
        let mut typed = input(vec![person(1, "A"), person(2, "B"), person(3, "C"), person(4, "D"), person(5, "Paul")], "1000");
        typed.common.cells = (1..=5).map(|id| CellInput { person: id, takes: id != 5, value: String::new() }).collect();
        typed.people[4].fixed = "100".into();
        let computed = run(&typed);
        exact(&computed);
        assert_eq!(dues(&computed), vec![225.0, 225.0, 225.0, 225.0, 100.0]);
        assert_eq!(computed.shares.outside[4], 100 * EURO);
        assert_eq!(computed.shares.constraint[4], Constraint::Fixed);
    }

    #[test]
    fn un_plancher_fait_payer_plus_et_soulage_les_autres() {
        let mut typed = input(vec![person(1, "A"), person(2, "B"), person(3, "C")], "90");
        typed.people[0].floor = "50".into();
        let computed = run(&typed);
        exact(&computed);
        assert_eq!(dues(&computed), vec![50.0, 20.0, 20.0]);
        assert_eq!(computed.shares.constraint[0], Constraint::Floor);
    }

    #[test]
    fn ce_qui_ne_peut_pas_tenir_est_dit_en_clair() {
        // Seule sur un poste, un plafond plus bas que le poste.
        let mut typed = input(vec![person(1, "Léa"), person(2, "Paul")], "100");
        typed.items.push(item(1, "Bateau", "60", &[1], &[1, 2]));
        typed.people[0].cap = "30".into();
        let refusal = refused(&typed);
        assert!(refusal.message.contains("Léa est seul à participer à « Bateau »"), "{}", refusal.message);
        // Des plafonds qui ne couvrent pas la somme.
        let mut typed = input(vec![person(1, "Léa"), person(2, "Paul")], "100");
        typed.people[0].cap = "30".into();
        typed.people[1].cap = "55".into();
        assert!(refused(&typed).message.contains("il manque 15,00"), "{}", refused(&typed).message);
        // Des montants fixes au-delà de la somme.
        let mut typed = input(vec![person(1, "Léa"), person(2, "Paul")], "100");
        typed.people[0].fixed = "80".into();
        typed.people[1].fixed = "40".into();
        assert!(refused(&typed).message.contains("20,00"), "{}", refused(&typed).message);
        // Des postes au-delà du total.
        let mut typed = input(vec![person(1, "Léa")], "50");
        typed.items.push(item(1, "Vin", "60", &[1], &[1]));
        assert_eq!(refused(&typed).field, "total");
        // Un nom manquant, un nom en double.
        let typed = input(vec![person(1, "Léa"), person(2, " ")], "50");
        assert_eq!(refused(&typed).field, "name-2");
        let typed = input(vec![person(1, "Léa"), person(2, "léa ")], "50");
        assert!(refused(&typed).message.contains("« Léa »"));
        // Un revenu manquant au prorata.
        let mut typed = input(vec![person(1, "Léa"), person(2, "Paul")], "50");
        typed.rule = "income".into();
        typed.people[0].income = "1000".into();
        assert_eq!(refused(&typed).field, "income-2");
    }

    #[test]
    fn un_revenu_nul_ne_paie_rien_et_le_resultat_le_dit() {
        let mut typed = input(vec![person(1, "Léa"), person(2, "Léo")], "100");
        typed.rule = "income".into();
        typed.people[0].income = "2000".into();
        typed.people[1].income = "0".into();
        let computed = run(&typed);
        assert_eq!(dues(&computed), vec![100.0, 0.0]);
        let written = write(&computed, &computed.plan, FR);
        assert!(written.notes.iter().any(|note| note == "Léo ne paie rien sur Commun : son revenu est de 0."), "{:?}", written.notes);
    }

    #[test]
    fn a_l_euro_chacun_paie_un_compte_rond() {
        let mut typed = input(vec![person(1, "A"), person(2, "B"), person(3, "C")], "100");
        typed.rounding = "euro".into();
        let computed = run(&typed);
        assert_eq!(dues(&computed), vec![34.0, 33.0, 33.0]);
        assert_eq!(computed.shares.due.iter().sum::<i64>(), 100 * EURO);
        assert_eq!(computed.shares.keeper, None);
        // Un total qui n'est pas rond : une seule personne garde les centimes.
        typed.total = "100,50".into();
        let computed = run(&typed);
        assert_eq!(computed.shares.due.iter().sum::<i64>(), 100 * EURO + EURO / 2);
        let odd: Vec<f64> = dues(&computed).into_iter().filter(|value| value.fract() != 0.0).collect();
        assert_eq!(odd.len(), 1, "{:?}", dues(&computed));
        assert!(computed.shares.keeper.is_some());
    }

    #[test]
    fn tout_paye_radinus_propose_les_virements() {
        let mut typed = input(vec![person(1, "A"), person(2, "B"), person(3, "C"), person(4, "D")], "1000");
        typed.rule = "income".into();
        for (rank, income) in ["3000", "2000", "1500", "1500"].iter().enumerate() {
            typed.people[rank].income = (*income).into();
        }
        typed.people[2].cap = "150".into();
        typed.payments.push(pay(1, 1, "1000"));
        let computed = run(&typed);
        let written = write(&computed, &computed.plan, FR);
        assert_eq!(
            written.transfers,
            vec!["B doit 261,54 € à A", "D doit 196,15 € à A", "C doit 150,00 € à A"],
        );
        assert_eq!(written.units[0].balance, "A versé 607,69 € de plus que sa part");
        assert_eq!(written.summary[0], "1\u{202f}000,00 € réglés sur 1\u{202f}000,00 €.");
    }

    #[test]
    fn a_moitie_paye_on_dit_ce_qui_reste_sans_imposer_de_virement() {
        let mut typed = input(vec![person(1, "A"), person(2, "B"), person(3, "C"), person(4, "D")], "1000");
        typed.rule = "income".into();
        for (rank, income) in ["3000", "2000", "1500", "1500"].iter().enumerate() {
            typed.people[rank].income = (*income).into();
        }
        typed.people[2].cap = "150".into();
        typed.payments = vec![pay(1, 1, "600"), pay(2, 2, "200")];
        let computed = run(&typed);
        let written = write(&computed, &computed.plan, FR);
        assert!(written.transfers.is_empty());
        assert!(written.summary.contains(&"Reste à payer sur la dépense : 200,00 €".to_string()), "{:?}", written.summary);
        assert!(written.summary.contains(&"À rembourser à A : 207,69 €".to_string()), "{:?}", written.summary);
        assert_eq!(written.units[1].balance, "Reste à régler : 61,54 €");
    }

    #[test]
    fn un_cadeau_fait_baisser_la_part_des_autres() {
        let mut typed = input(vec![person(1, "A"), person(2, "B"), person(3, "C"), person(4, "D")], "1000");
        typed.rule = "income".into();
        for (rank, income) in ["3000", "2000", "1500", "1500"].iter().enumerate() {
            typed.people[rank].income = (*income).into();
        }
        typed.people[2].cap = "150".into();
        typed.people[0].gift = true;
        typed.payments = vec![pay(1, 1, "600"), pay(2, 2, "200")];
        let computed = run(&typed);
        exact(&computed);
        assert_eq!(dues(&computed), vec![600.0, 160.0, 120.0, 120.0]);
        assert_eq!(computed.shares.constraint[0], Constraint::Gift);
        let written = write(&computed, &computed.plan, FR);
        assert_eq!(written.units[1].balance, "A versé 40,00 € de plus que sa part");
        assert!(written.notes.iter().any(|note| note.starts_with("Le surplus offert par A réduit la part des autres : B")), "{:?}", written.notes);
        // Sans la case, le surplus de A lui est rendu.
        typed.people[0].gift = false;
        assert_eq!(dues(&run(&typed))[0], 392.31);
    }

    #[test]
    fn un_cadeau_peut_payer_un_poste_qu_on_n_a_pas_consomme() {
        let mut typed = input(vec![person(1, "A"), person(2, "B")], "100");
        typed.items.push(item(1, "Vin", "20", &[2], &[1, 2]));
        typed.people[0].gift = true;
        typed.payments.push(pay(1, 1, "100"));
        let computed = run(&typed);
        exact(&computed);
        assert_eq!(dues(&computed), vec![100.0, 0.0]);
        assert_eq!(computed.shares.outside[0], 20 * EURO);
    }

    #[test]
    fn un_foyer_se_regle_ensemble() {
        let mut typed = input(
            vec![person(1, "Marc"), person(2, "Lou"), person(3, "Tom"), person(4, "Inès")],
            "700",
        );
        typed.rule = "parts".into();
        for (rank, parts) in ["2", "1", "1", "2"].iter().enumerate() {
            typed.people[rank].parts = (*parts).into();
        }
        for rank in 0..3 {
            typed.people[rank].household = "Famille Martin".into();
        }
        typed.payments = vec![pay(1, 1, "500"), pay(2, 4, "200")];
        let computed = run(&typed);
        assert_eq!(dues(&computed), vec![233.33, 116.67, 116.67, 233.33]);
        assert_eq!(computed.units.len(), 2);
        assert_eq!(computed.units[0].name, "Famille Martin");
        assert_eq!(computed.units[0].due, 466_670_000);
        let written = write(&computed, &computed.plan, FR);
        assert_eq!(written.units[0].members, "Marc, Lou, Tom");
        // Le père a versé 500 € pour 466,67 € ; Inès, 200 € pour 233,33 €.
        assert_eq!(written.transfers, vec!["Inès doit 33,33 € à Famille Martin"]);
    }

    #[test]
    fn des_contraintes_melees_tombent_toujours_juste() {
        // Un petit générateur déterministe : pas de dépendance pour un test.
        let mut seed: u64 = 7;
        let mut next = |range: u64| {
            seed = seed.wrapping_mul(6364136223846793005).wrapping_add(1442695040888963407);
            (seed >> 33) % range
        };
        for _ in 0..80 {
            let count = 2 + next(7) as u32;
            let people: Vec<PersonInput> = (1..=count).map(|id| person(id, &format!("P{id}"))).collect();
            let ids: Vec<u32> = (1..=count).collect();
            let mut typed = input(people, &format!("{},{:02}", 200 + next(800), next(100)));
            typed.rule = ["equal", "parts", "income"][next(3) as usize].into();
            for typed_person in &mut typed.people {
                typed_person.income = format!("{}", 500 + next(3000));
                typed_person.parts = format!("{}", 1 + next(3));
            }
            let takers: Vec<u32> = ids.iter().copied().filter(|_| next(3) > 0).collect();
            if !takers.is_empty() {
                typed.items.push(item(1, "Extra", &format!("{}", 10 + next(90)), &takers, &ids));
            }
            typed.people[0].cap = format!("{}", 60 + next(100));
            if count > 2 {
                typed.people[1].floor = format!("{}", 10 + next(60));
            }
            if next(2) == 0 {
                typed.rounding = "euro".into();
            }
            let Ok(plan) = read(&typed, FR) else { continue };
            let Ok(computed) = compute(&plan, FR) else { continue };
            exact(&computed);
            let cap = computed.plan.people[0].cap.unwrap();
            assert!(computed.shares.shared[0] <= cap, "le plafond est dépassé : {:?}", typed);
            if count > 2 {
                let floor = computed.plan.people[1].floor.unwrap();
                assert!(computed.shares.shared[1] + computed.shares.rounding[1] >= floor, "le plancher est manqué : {:?}", typed);
            }
            for (rank, row) in computed.shares.cells.iter().enumerate() {
                for (column, item) in computed.plan.items.iter().enumerate() {
                    if !item.cells[rank].takes && computed.shares.outside[rank] == 0 {
                        assert_eq!(row[column], 0, "quelqu'un paie un poste où il n'est pas");
                    }
                }
            }
        }
    }

    #[test]
    fn le_projet_se_rouvre_tel_qu_il_a_ete_tape() {
        let mut typed = input(vec![person(1, "Léa"), person(2, "Paul")], "1 250,50");
        typed.people[0].income = "2100".into();
        typed.people[1].parts = "1,5".into();
        typed.people[1].gift = true;
        typed.items.push(item(4, "Vin", "60", &[2], &[1, 2]));
        typed.payments.push(PaymentInput { id: 1, person: 2, amount: "300".into(), date: "2027-01-15".into(), label: "acompte".into() });
        typed.common.rule = "equal".into();
        let file = to_file(&typed, FR).expect("écrit");
        assert!(file.contains("\"total\": 1250.5"), "les montants sont neutres : {file}");
        let back = from_file(&file, Language::English).expect("rouvert");
        assert_eq!(back.total, "1250.50");
        assert_eq!(back.people[1].parts, "1.50");
        assert_eq!(back.items[0].label, "Vin");
        assert!(!back.items[0].cells[0].takes && back.items[0].cells[1].takes);
        assert_eq!(back.payments[0].date, "2027-01-15");
        assert!(back.people[1].gift);
        let again = from_file(&file, FR).expect("rouvert");
        assert_eq!(again.total, "1250,50");
        assert_eq!(again.people[0].income, "2100,00");
        // Un projet qui ne tombe pas juste s'enregistre quand même ; un champ
        // illisible, non.
        typed.rule = "percent".into();
        assert!(to_file(&typed, FR).is_ok());
        typed.people[0].floor = "beaucoup".into();
        assert_eq!(to_file(&typed, FR).unwrap_err().field, "floor-1");
        assert_eq!(from_file("{}", FR), Err(FileRefusal::NotAProject));
        assert_eq!(from_file("pas du json", FR), Err(FileRefusal::NotAProject));
        let newer = file.replace("\"version\": 1", "\"version\": 9");
        assert_eq!(from_file(&newer, FR), Err(FileRefusal::TooRecent));
    }

    #[test]
    fn les_noms_ajoutes_ne_se_marchent_pas_dessus() {
        let typed = input(vec![person(1, "Personne 2"), person(2, "Léa")], "");
        assert_eq!(next_name(&typed, FR), "Personne 3");
        let typed = input(vec![person(1, "Léa"), person(2, "personne 3")], "");
        assert_eq!(next_name(&typed, FR), "Personne 4");
    }

    #[test]
    fn sans_personne_une_invite_et_pas_de_refus() {
        let typed = input(Vec::new(), "120");
        let computed = run(&typed);
        let written = write(&computed, &computed.plan, FR);
        assert_eq!(written.headline, "Ajoutez les personnes qui partagent la dépense.");
        assert!(written.summary.is_empty() && written.transfers.is_empty());
    }

    // --- Les conseils (P-72) ---------------------------------------------

    fn values(advice: &Advice) -> Vec<(u32, Option<u32>, String)> {
        advice.suggested.iter().map(|value| (value.person, value.item, value.value.clone())).collect()
    }

    #[test]
    fn le_titre_dit_ce_que_chacun_paie() {
        let typed = input(vec![person(1, "Léa"), person(2, "Tom")], "120");
        let computed = run(&typed);
        let written = write(&computed, &computed.plan, FR);
        assert_eq!(written.headline.replace(['\u{a0}', '\u{202f}'], " "), "120,00 € à partager : chacun paie 60,00 €.");
        let mut typed = input(vec![person(1, "Léa"), person(2, "Tom")], "120");
        typed.people[0].fixed = "20".into();
        let computed = run(&typed);
        let written = write(&computed, &computed.plan, FR);
        assert!(written.headline.contains("de 20,00") && written.headline.contains("100,00"), "{}", written.headline);
    }

    #[test]
    fn les_parts_egales_se_disent_en_une_division() {
        let typed = input(vec![person(1, "Léa"), person(2, "Tom"), person(3, "Zoé")], "90");
        let advice = advise(&typed, FR);
        let sentence = advice.sentence.replace(['\u{a0}', '\u{202f}'], " ");
        assert_eq!(sentence, "90,00 € ÷ 3 personnes = 30,00 € chacun.");
        assert!(!advice.warn && advice.suggested.is_empty());
        // Une limite : plus de division qui serait fausse.
        let mut typed = typed;
        typed.people[0].cap = "10".into();
        assert!(advise(&typed, FR).sentence.starts_with("À parts égales"));
    }

    #[test]
    fn une_part_vide_vaut_une_part_et_se_conseille() {
        let mut typed = input(vec![person(1, "Léa"), person(2, "Tom"), person(3, "Zoé")], "100");
        typed.rule = "parts".into();
        typed.people[0].parts = "2".into();
        let advice = advise(&typed, FR);
        assert!(advice.sentence.starts_with("4 parts au total : une part vaut 25,00"), "{}", advice.sentence);
        assert_eq!(values(&advice), vec![(2, None, "1".into()), (3, None, "1".into())]);
    }

    #[test]
    fn les_pourcentages_conseillent_le_reste_qui_tombe_juste() {
        let mut typed = input(vec![person(1, "Léa"), person(2, "Tom"), person(3, "Zoé"), person(4, "Max")], "100");
        typed.rule = "percent".into();
        typed.people[0].percent = "abc".into(); // illisible : compte comme vide
        let advice = advise(&typed, FR);
        assert_eq!(advice.sentence, "Il manque 100 % pour arriver à 100 %.");
        assert_eq!(
            values(&advice),
            vec![(1, None, "25".into()), (2, None, "25".into()), (3, None, "25".into()), (4, None, "25".into())]
        );
        typed.people[0].percent = "40".into();
        typed.people.pop();
        let advice = advise(&typed, FR);
        assert_eq!(advice.sentence, "Il manque 60 % pour arriver à 100 %.");
        assert_eq!(values(&advice), vec![(2, None, "30".into()), (3, None, "30".into())]);
        typed.people[0].percent = "1".into();
        let advice = advise(&typed, FR);
        assert_eq!(values(&advice), vec![(2, None, "49,5".into()), (3, None, "49,5".into())]);
        typed.people[0].percent = "".into();
        let advice = advise(&typed, FR);
        assert_eq!(values(&advice), vec![(1, None, "33,34".into()), (2, None, "33,33".into()), (3, None, "33,33".into())]);
    }

    #[test]
    fn une_personne_ajoutee_apres_coup_ne_paierait_rien() {
        let mut typed = input(vec![person(1, "Léa"), person(2, "Tom"), person(3, "Zoé")], "100");
        typed.rule = "percent".into();
        typed.people[0].percent = "50".into();
        typed.people[1].percent = "50".into();
        let advice = advise(&typed, FR);
        assert!(advice.warn);
        assert_eq!(advice.sentence, "Les pourcentages font déjà 100 % : Zoé ne paierait rien.");
        typed.people[1].percent = "70".into();
        let advice = advise(&typed, FR);
        assert!(advice.warn && advice.sentence.contains("20 %"), "{}", advice.sentence);
        typed.people[1].percent = "30".into();
        typed.people[2].percent = "20".into();
        let advice = advise(&typed, FR);
        assert_eq!(advice.sentence, "Les pourcentages font bien 100 %.");
        assert!(!advice.warn);
    }

    #[test]
    fn les_revenus_donnent_un_taux_et_des_pourcentages() {
        let mut typed = input(vec![person(1, "Léa"), person(2, "Tom"), person(3, "Zoé")], "300");
        typed.rule = "income".into();
        typed.people[0].income = "1000".into();
        typed.people[1].income = "1000".into();
        assert!(advise(&typed, FR).sentence.starts_with("Tapez le revenu"));
        typed.people[2].income = "1000".into();
        assert_eq!(advise(&typed, FR).sentence, "Chacun paie 10,0 % de son revenu.");
        typed.rule = "percent".into();
        let advice = advise(&typed, FR);
        let incomes: Vec<String> = advice.from_incomes.iter().map(|value| value.value.clone()).collect();
        assert_eq!(incomes, vec!["33,34", "33,33", "33,33"]);
        typed.people[2].income = "2000".into();
        let incomes: Vec<String> = advise(&typed, FR).from_incomes.iter().map(|value| value.value.clone()).collect();
        assert_eq!(incomes, vec!["25", "25", "50"]);
    }

    #[test]
    fn par_poste_une_phrase_par_poste() {
        let everyone = [1, 2, 3];
        let mut typed = input(vec![person(1, "Léa"), person(2, "Tom"), person(3, "Zoé")], "160");
        typed.mode = "item".into();
        let mut wine = item(5, "Vin", "60", &[1, 2], &everyone);
        wine.rule = "percent".into();
        wine.cells[0].value = "70".into();
        typed.items = vec![wine];
        typed.common.cells = everyone.iter().map(|&person| CellInput { person, takes: true, value: String::new() }).collect();
        let advice = advise(&typed, FR);
        assert!(advice.sentence.is_empty());
        let common = advice.items.iter().find(|item| item.id == COMMON_ID).expect("commun");
        assert!(common.sentence.replace(['\u{a0}', '\u{202f}'], " ").starts_with("100,00 € ÷ 3 personnes"), "{}", common.sentence);
        let wine = advice.items.iter().find(|item| item.id == 5).expect("vin");
        assert_eq!(wine.sentence, "Il manque 30 % pour arriver à 100 %.");
        assert_eq!(values(&advice), vec![(2, Some(5), "30".into())]);
    }

    #[test]
    fn sans_personne_pas_de_conseil_et_sans_montant_une_invite() {
        assert_eq!(advise(&input(Vec::new(), "100"), FR), Advice::default());
        assert_eq!(advise(&input(vec![person(1, "Léa")], ""), FR).sentence, "Tapez le montant à partager.");
    }

    /// Chaque phrase de l'outil se dit dans chaque langue, ses trous remplis.
    #[test]
    fn chaque_phrase_se_dit_dans_chaque_langue() {
        let keys: Vec<&str> = include_str!("../i18n/fr.ftl")
            .lines()
            .filter(|line| line.starts_with("sharing-") || line.starts_with("menu-tools-sharing") || line.starts_with("window-sharing"))
            .filter_map(|line| line.split_once(" =").map(|(key, _)| key))
            .collect();
        assert!(keys.len() > 140, "{}", keys.len());
        let texts = [
            ("name", "Léa"), ("item", "Vin"), ("amount", "12,00 €"), ("sum", "90"), ("first", "A, B"), ("last", "C"),
            ("total", "100,00 €"), ("collected", "50,00 €"), ("from", "B"), ("to", "A"), ("giver", "A"), ("items", "Vin"),
            ("date", "11/10/2026"), ("file", "x.json"), ("folder", "Relevés"), ("reason", "?"),
            ("parts", "4,5"), ("rest", "10"), ("over", "5"), ("names", "Léa et Tom"), ("rate", "2,5"), ("min", "10,00 €"),
            ("max", "30,00 €"),
        ];
        for language in Language::all() {
            for key in &keys {
                for count in [0, 1, 2, 3, 5, 21, 40] {
                    let said = i18n::message_of(language, key, &texts, &[("count", count), ("number", count)]);
                    assert!(!said.trim().is_empty(), "« {key} » est vide en {}", language.tag());
                    assert!(!said.contains('{') && !said.contains('}'), "« {key} » garde un trou en {} : {said}", language.tag());
                }
            }
        }
    }

    #[test]
    fn les_trois_rapports_et_le_classeur_se_composent() {
        let mut typed = input(vec![person(1, "Marc"), person(2, "Lou"), person(3, "Inès")], "300");
        typed.label = "Voyage Bretagne 2027".into();
        typed.rule = "income".into();
        typed.people[0].income = "2000".into();
        typed.people[1].income = "0".into();
        typed.people[2].income = "1000".into();
        typed.people[0].household = "Martin".into();
        typed.people[1].household = "Martin".into();
        typed.items.push(item(1, "Vin \"maison\" #1", "30", &[1, 3], &[1, 2, 3]));
        typed.payments = vec![
            PaymentInput { id: 1, person: 1, amount: "300".into(), date: "2027-01-15".into(), label: "tout".into() },
        ];
        let computed = run(&typed);
        let today = NaiveDate::from_ymd_opt(2026, 10, 11).unwrap();
        for bytes in [
            distribution_pdf(&computed, FR).expect("répartition"),
            payments_pdf(&computed, today, FR).expect("état des paiements"),
            statement_pdf(&computed, 0, today, FR).expect("relevé du foyer"),
            statement_pdf(&computed, 1, today, FR).expect("relevé d'Inès"),
        ] {
            assert!(bytes.starts_with(b"%PDF"));
        }
        let sheets = book(&computed, FR);
        assert_eq!(
            sheets.iter().map(|sheet| sheet.name.as_str()).collect::<Vec<_>>(),
            vec!["Personnes", "Postes", "Résultat", "Règlements", "Remboursements"],
        );
        // Les revenus masqués : la colonne n'existe pas.
        assert!(!sheets[0].rows[0].iter().any(|cell| cell.content == crate::sheets::CellContent::Text("Revenu".into())));
        let mut shown = typed.clone();
        shown.show_incomes = true;
        let sheets = book(&run(&shown), FR);
        assert!(sheets[0].rows[0].iter().any(|cell| cell.content == crate::sheets::CellContent::Text("Revenu".into())));
    }
}
