//! Objectif Épargne — F44 (Fabrice, 10/10/2026).
//!
//! « Si je continue au rythme actuel, dans combien de temps aurai-je tel
//! solde, et combien aurai-je épargné ? Ou à l'inverse : combien de temps
//! épargner pour arriver à tel montant ? » Trois questions, toutes trois
//! retenues (« les 3 ») :
//!
//! 1. **Quand aurai-je ce montant ?** — la date, et ce qui aura été épargné.
//! 2. **Combien aurai-je à cette date ?**
//! 3. **Combien épargner par mois pour avoir ce montant à cette date ?**
//!
//! # Le rythme
//!
//! Ce que les comptes suivis ont gagné ou perdu, mois par mois, sur la période
//! de référence : les douze derniers mois complets, une année, ou **une plage
//! d'années** (Fabrice : « une option d'année type ou moyenne sur une plage
//! d'années »). Un virement entre deux comptes suivis s'annule ; un virement
//! vers un compte qui ne l'est pas est une sortie. Les paires se reconnaissent
//! comme dans la simulation de crédit.
//!
//! # La projection
//!
//! - **L'année type** (« oui ») : chaque mois à venir reprend la moyenne des
//!   mêmes mois du calendrier dans la période — les septembres d'impôts, les
//!   décembres de treizième mois. Un mois que la période n'a pas vu prend la
//!   moyenne de tous.
//! - **La fourchette** (« ok, d'accord avec toi ») : la même projection,
//!   décalée de l'écart entre la moyenne et le quart le plus bas des mois —
//!   la prudente — ou le quart le plus haut — la favorable.
//! - **Les crédits qui se terminent** (« oui ») : une mensualité trouvée parmi
//!   les opérations périodiques des comptes suivis redevient libre le mois
//!   qui suit sa dernière échéance.
//! - **Les intérêts** (« ok ») : un taux annuel facultatif, compté chaque mois
//!   sur un solde positif — une approximation de la règle des quinzaines des
//!   livrets.
//! - **« Et si j'épargnais X € de plus par mois ? »** (« ok ») s'ajoute à
//!   chaque mois.
//!
//! Rien n'est enregistré, pas de rapport PDF. Cinquante ans au plus.

use crate::domain::NaiveDate;
use crate::i18n::{self, Language};
use crate::loan::{first_of, last_of, pair_transfers, quantile, Line, RunningLoan, TRANSFER_DAYS};
use crate::loan_charts::{self, axes, bounds_of, svg_open, text, ticks, Frame};
use crate::money;
use rusqlite::{Connection, Result};
use std::collections::HashSet;
use time_compute::{Datelike, Days, Months};

/// Le plus loin qu'une projection regarde : cinquante ans.
pub const HORIZON: usize = 600;
/// Le taux annuel le plus fort qu'un champ accepte.
pub const RATE_LIMIT: f64 = 100.0;
/// Combien de fins de mois réelles la courbe montre avant aujourd'hui.
pub const PAST_MONTHS: u32 = 12;

/// La période de référence : celle de la simulation de crédit, plage
/// d'années comprise.
pub use crate::loan::Period;

/// **La question posée.**
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Question {
    /// Quand aurai-je ce montant ?
    When { target: i64 },
    /// Combien aurai-je ce mois-là ?
    Amount { month: NaiveDate },
    /// Combien épargner par mois pour avoir ce montant ce mois-là ?
    Effort { target: i64, month: NaiveDate },
}

/// Ce que la personne a coché et tapé.
#[derive(Debug, Clone, PartialEq)]
pub struct Request {
    pub accounts: Vec<i64>,
    pub period: Period,
    pub question: Question,
    /// Le taux annuel, en pourcent.
    pub rate: f64,
    /// L'effort de plus, par mois, en micro-unités.
    pub extra: i64,
}

/// Pourquoi il n'y a rien à montrer.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Unavailable {
    NoAccount,
    NoMonth,
    /// La date visée est passée, ou à plus de cinquante ans.
    BadDate,
}

impl Unavailable {
    pub fn key(self) -> &'static str {
        match self {
            Unavailable::NoAccount => "goal-no-account",
            Unavailable::NoMonth => "goal-no-month",
            Unavailable::BadDate => "goal-invalid-date",
        }
    }
}

/// Les trois projections : prudente, probable, favorable.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Scenario {
    Prudent,
    Probable,
    Favorable,
}

pub const SCENARIOS: [Scenario; 3] = [Scenario::Prudent, Scenario::Probable, Scenario::Favorable];

/// **Ce que l'historique dit des comptes suivis.**
#[derive(Debug, Clone, PartialEq)]
pub struct Flows {
    /// Les mois de la période et ce que chacun a rapporté.
    pub months: Vec<(NaiveDate, i64)>,
    /// La moyenne des mois, et les quarts bas et haut.
    pub mean: i64,
    pub low: i64,
    pub high: i64,
    /// L'année type : la moyenne de chaque mois du calendrier.
    pub profile: [i64; 12],
    /// Le solde réel des comptes suivis, aujourd'hui.
    pub balance: i64,
    /// Le solde à la fin de chacun des douze derniers mois complets.
    pub past: Vec<(NaiveDate, i64)>,
    pub transfers: usize,
    /// Les deux moitiés des virements entre comptes suivis, par leur clef :
    /// « Et si je réduisais… ? » les écarte aussi de ses dépenses.
    pub neutral: Vec<i64>,
    /// Les crédits en cours des comptes suivis.
    pub loans: Vec<RunningLoan>,
}

pub(crate) fn day_of(text: Option<String>) -> Option<NaiveDate> {
    text.and_then(|day| NaiveDate::parse_from_str(&day, "%Y-%m-%d").ok())
}

pub(crate) fn iso(day: NaiveDate) -> rusqlite::types::Value {
    rusqlite::types::Value::Text(day.format("%Y-%m-%d").to_string())
}

pub(crate) fn add_months(month: NaiveDate, count: usize) -> Option<NaiveDate> {
    month.checked_add_months(Months::new(u32::try_from(count).ok()?))
}

/// Combien de mois entre le mois en cours et `month`.
pub fn months_until(today: NaiveDate, month: NaiveDate) -> i64 {
    let (from, to) = (first_of(today), first_of(month));
    i64::from(to.year() - from.year()) * 12 + i64::from(to.month()) - i64::from(from.month())
}

/// **Lit l'historique.**
pub fn read(
    conn: &Connection,
    accounts: &[i64],
    period: Period,
    today: NaiveDate,
) -> Result<std::result::Result<Flows, Unavailable>> {
    if accounts.is_empty() {
        return Ok(Err(Unavailable::NoAccount));
    }
    let months = period.months(today);
    let (Some(&first), Some(&last)) = (months.first(), months.last()) else {
        return Ok(Err(Unavailable::NoMonth));
    };
    let followed: HashSet<i64> = accounts.iter().copied().collect();

    // Les virements entre comptes suivis, reconnus sur toute la base pour
    // qu'une moitié ne soit pas appariée à tort avec une autre opération.
    let margin = Days::new(TRANSFER_DAYS as u64);
    let wide_from = first.checked_sub_days(margin).unwrap_or(first);
    let wide_to = last_of(last).checked_add_days(margin).unwrap_or(last);
    let mut statement = conn.prepare(
        "SELECT IDOperation, IDCompte, Montant, COALESCE(Date, DatePointage)
         FROM Operation
         WHERE IDOperationParent = 0 AND IDStatutOperation IN (1, 2)
           AND COALESCE(Date, DatePointage) BETWEEN ?1 AND ?2",
    )?;
    let lines: Vec<Line> = statement
        .query_map(rusqlite::params_from_iter([iso(wide_from), iso(wide_to)]), |row| {
            Ok((row.get::<_, i64>(0)?, row.get::<_, i64>(1)?, row.get::<_, i64>(2)?, row.get(3)?))
        })?
        .filter_map(|row| match row {
            Ok((id, account, amount, day)) => {
                day_of(day).map(|day| Ok(Line { id, account, amount, day }))
            }
            Err(error) => Some(Err(error)),
        })
        .collect::<Result<_>>()?;
    let account_of = |id: i64| lines.iter().find(|line| line.id == id).map(|line| line.account);
    let internal: Vec<(i64, i64)> = pair_transfers(&lines)
        .into_iter()
        .filter(|&(debit, credit)| {
            account_of(debit).is_some_and(|a| followed.contains(&a))
                && account_of(credit).is_some_and(|a| followed.contains(&a))
        })
        .collect();
    let neutral: HashSet<i64> = internal.iter().flat_map(|&(debit, credit)| [debit, credit]).collect();
    let (from, to) = (first, last_of(last));
    let inside = |id: i64| {
        lines
            .iter()
            .find(|line| line.id == id)
            .is_some_and(|line| line.day >= from && line.day <= to)
    };
    let transfers = internal
        .iter()
        .filter(|&&(debit, credit)| inside(debit) || inside(credit))
        .count();

    let mut nets: Vec<(NaiveDate, i64)> = months.iter().map(|&month| (month, 0)).collect();
    for line in &lines {
        if !followed.contains(&line.account) || neutral.contains(&line.id) {
            continue;
        }
        if let Some(slot) = nets.iter_mut().find(|(month, _)| *month == first_of(line.day)) {
            slot.1 += line.amount;
        }
    }

    let count = nets.len() as i64;
    let mean = nets.iter().map(|(_, net)| net).sum::<i64>() / count;
    let mut sorted: Vec<i64> = nets.iter().map(|(_, net)| *net).collect();
    sorted.sort_unstable();
    let mut profile = [mean; 12];
    for (rank, slot) in profile.iter_mut().enumerate() {
        let same: Vec<i64> = nets
            .iter()
            .filter(|(month, _)| month.month0() as usize == rank)
            .map(|(_, net)| *net)
            .collect();
        if !same.is_empty() {
            *slot = same.iter().sum::<i64>() / same.len() as i64;
        }
    }

    // Le solde d'aujourd'hui, et celui de la fin des douze derniers mois :
    // le solde d'aujourd'hui moins ce qui est entré depuis.
    let balance: i64 = crate::accounts::list(conn)?
        .iter()
        .filter(|row| followed.contains(&row.id))
        .map(|row| row.balance_real)
        .sum();
    let this_month = first_of(today);
    let past_months: Vec<NaiveDate> = (1..=PAST_MONTHS)
        .rev()
        .filter_map(|back| this_month.checked_sub_months(Months::new(back)))
        .collect();
    let mut past = Vec::new();
    if let Some(&oldest) = past_months.first() {
        let marks = accounts.iter().map(|_| "?").collect::<Vec<_>>().join(",");
        let sql = format!(
            "SELECT Montant, COALESCE(Date, DatePointage) FROM Operation
             WHERE IDOperationParent = 0 AND IDStatutOperation IN (1, 2)
               AND IDCompte IN ({marks}) AND COALESCE(Date, DatePointage) > ?"
        );
        let mut parameters: Vec<rusqlite::types::Value> =
            accounts.iter().map(|id| rusqlite::types::Value::Integer(*id)).collect();
        parameters.push(iso(last_of(oldest)));
        let mut statement = conn.prepare(&sql)?;
        let later: Vec<(i64, NaiveDate)> = statement
            .query_map(rusqlite::params_from_iter(parameters), |row| {
                Ok((row.get::<_, i64>(0)?, row.get::<_, Option<String>>(1)?))
            })?
            .filter_map(|row| match row {
                Ok((amount, day)) => day_of(day).map(|day| Ok((amount, day))),
                Err(error) => Some(Err(error)),
            })
            .collect::<Result<_>>()?;
        for month in past_months {
            let end = last_of(month);
            let after: i64 = later.iter().filter(|(_, day)| *day > end).map(|(amount, _)| amount).sum();
            past.push((month, balance - after));
        }
    }

    let loans = crate::loan::running_loans(conn, accounts, today)?;
    Ok(Ok(Flows {
        months: nets,
        mean,
        low: quantile(&sorted, 0.25),
        high: quantile(&sorted, 0.75),
        profile,
        balance,
        past,
        transfers,
        neutral: {
            let mut ids: Vec<i64> = neutral.into_iter().collect();
            ids.sort_unstable();
            ids
        },
        loans,
    }))
}

impl Flows {
    /// Ce que rapporte un mois à venir, dans une projection.
    pub fn flow(&self, month: NaiveDate, scenario: Scenario, extra: i64) -> i64 {
        let shift = match scenario {
            Scenario::Prudent => self.low - self.mean,
            Scenario::Probable => 0,
            Scenario::Favorable => self.high - self.mean,
        };
        let freed: i64 = self
            .loans
            .iter()
            .filter(|loan| first_of(loan.end) < month)
            .map(|loan| loan.monthly)
            .sum();
        self.profile[month.month0() as usize] + shift + extra + freed
    }

    /// **La projection**, mois après mois : le solde à la fin de chacun des
    /// `count` mois qui suivent le mois en cours, et les intérêts cumulés.
    pub fn project(
        &self,
        today: NaiveDate,
        scenario: Scenario,
        extra: i64,
        rate: f64,
        count: usize,
    ) -> Vec<(NaiveDate, i64, i64)> {
        self.project_with(today, scenario, |_| extra, rate, count)
    }

    /// La même projection, avec un effort qui change selon le mois — celui
    /// d'« Et si je réduisais… ? », qui suit les saisons de chaque poste.
    pub fn project_with(
        &self,
        today: NaiveDate,
        scenario: Scenario,
        extra: impl Fn(NaiveDate) -> i64,
        rate: f64,
        count: usize,
    ) -> Vec<(NaiveDate, i64, i64)> {
        let monthly_rate = rate / 100.0 / 12.0;
        let mut balance = self.balance;
        let mut interest_total = 0;
        let mut out = Vec::with_capacity(count);
        for rank in 1..=count {
            let Some(month) = add_months(first_of(today), rank) else {
                break;
            };
            let interest = if balance > 0 { (balance as f64 * monthly_rate).round() as i64 } else { 0 };
            interest_total += interest;
            balance += interest + self.flow(month, scenario, extra(month));
            out.push((month, balance, interest_total));
        }
        out
    }

    /// Le premier mois où la projection atteint `target`, compté depuis le
    /// mois en cours.
    pub fn reach(&self, today: NaiveDate, scenario: Scenario, extra: i64, rate: f64, target: i64) -> Option<usize> {
        self.project(today, scenario, extra, rate, HORIZON)
            .iter()
            .position(|(_, balance, _)| *balance >= target)
            .map(|rank| rank + 1)
    }

    /// **L'effort de plus, par mois, qui amène à `target` en `months` mois**
    /// — négatif quand on est en avance. La projection croît avec l'effort :
    /// on cherche par dichotomie, au centime.
    pub fn effort(&self, today: NaiveDate, scenario: Scenario, rate: f64, target: i64, months: usize) -> i64 {
        let at = |extra: i64| {
            self.project(today, scenario, extra, rate, months)
                .last()
                .map_or(self.balance, |(_, balance, _)| *balance)
        };
        let bound = 100_000_000 * money::UNIT;
        let (mut low, mut high) = (-bound, bound);
        while high - low > money::UNIT / 100 {
            let middle = low + (high - low) / 2;
            if at(middle) >= target {
                high = middle;
            } else {
                low = middle;
            }
        }
        high
    }
}

/// **La réponse**, pour les trois projections — prudente, probable,
/// favorable, dans cet ordre.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Answer {
    When {
        target: i64,
        /// Déjà atteint aujourd'hui.
        already: bool,
        reached: [Option<usize>; 3],
        /// Si la projection probable baisse : le mois où elle tomberait à zéro.
        zero: Option<usize>,
    },
    Amount { months: usize, values: [i64; 3] },
    Effort { target: i64, months: usize, extra: [i64; 3] },
}

/// **Répond à la question.**
pub fn answer(flows: &Flows, request: &Request, today: NaiveDate) -> std::result::Result<Answer, Unavailable> {
    let horizon = |month: NaiveDate| {
        let months = months_until(today, month);
        if months < 1 || months > HORIZON as i64 {
            Err(Unavailable::BadDate)
        } else {
            Ok(months as usize)
        }
    };
    Ok(match request.question {
        Question::When { target } => {
            let reached = SCENARIOS.map(|scenario| flows.reach(today, scenario, request.extra, request.rate, target));
            let zero = if reached[1].is_none() && flows.balance > 0 {
                flows
                    .project(today, Scenario::Probable, request.extra, request.rate, HORIZON)
                    .iter()
                    .position(|(_, balance, _)| *balance <= 0)
                    .map(|rank| rank + 1)
            } else {
                None
            };
            Answer::When { target, already: flows.balance >= target, reached, zero }
        }
        Question::Amount { month } => {
            let months = horizon(month)?;
            let values = SCENARIOS.map(|scenario| {
                flows
                    .project(today, scenario, request.extra, request.rate, months)
                    .last()
                    .map_or(flows.balance, |(_, balance, _)| *balance)
            });
            Answer::Amount { months, values }
        }
        Question::Effort { target, month } => {
            let months = horizon(month)?;
            let extra = SCENARIOS.map(|scenario| flows.effort(today, scenario, request.rate, target, months));
            Answer::Effort { target, months, extra }
        }
    })
}

// --- Ce que la fenêtre montre ---------------------------------------------------

#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Tile {
    pub label: String,
    pub value: String,
}

/// **Tout ce que la fenêtre affiche, déjà écrit.**
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Written {
    pub headline: String,
    pub range: Option<String>,
    /// `good`, `warn` ou `bad`.
    pub tone: String,
    pub tiles: Vec<Tile>,
    pub chart: String,
    pub notes: Vec<String>,
    pub period: String,
}

pub(crate) fn signed(amount: i64, language: Language) -> String {
    let written = money::format(amount, language);
    if amount > 0 {
        format!("+{written}")
    } else {
        written
    }
}

fn per_month(amount: String, language: Language) -> String {
    i18n::message_of(language, "goal-per-month", &[("amount", &amount)], &[])
}

pub(crate) fn month_at(today: NaiveDate, months: usize) -> NaiveDate {
    add_months(first_of(today), months).unwrap_or(today)
}

/// **Écrit la réponse.**
pub fn write(flows: &Flows, request: &Request, answer: &Answer, today: NaiveDate, language: Language) -> Written {
    let label = |key: &str| i18n::text(language, key);
    let amount = |value: i64| money::format(value, language);
    let month_text = |months: usize| i18n::month_and_year(language, month_at(today, months));
    let probable = |months: usize| {
        flows.project(today, Scenario::Probable, request.extra, request.rate, months)
    };

    let mut tiles = vec![
        Tile { label: label("goal-tile-balance"), value: amount(flows.balance) },
        Tile {
            label: label("goal-tile-rhythm"),
            value: per_month(signed(flows.mean + request.extra, language), language),
        },
    ];
    let (headline, range, tone, horizon, target_line, mark) = match *answer {
        Answer::When { target, already, reached, zero } => {
            tiles.push(Tile { label: label("goal-tile-target"), value: amount(target) });
            if already {
                let headline = i18n::message_of(
                    language,
                    "goal-when-already",
                    &[("amount", &amount(target)), ("balance", &amount(flows.balance))],
                    &[],
                );
                (headline, None, "good", 12, Some(target), None)
            } else if let Some(months) = reached[1] {
                let projected = probable(months);
                if let Some(&(_, balance, interest)) = projected.last() {
                    tiles.push(Tile { label: label("goal-tile-reached"), value: month_text(months) });
                    tiles.push(Tile { label: label("goal-tile-saved"), value: amount(balance - flows.balance) });
                    if request.rate > 0.0 {
                        tiles.push(Tile { label: label("goal-tile-interest"), value: amount(interest) });
                    }
                }
                let headline = i18n::message_of(
                    language,
                    "goal-when-reached",
                    &[("amount", &amount(target)), ("month", &month_text(months))],
                    &[("months", months as i64)],
                );
                let range = match (reached[2], reached[0]) {
                    (Some(early), Some(late)) if early != late => Some(i18n::message_of(
                        language,
                        "goal-when-range",
                        &[("early", &month_text(early)), ("late", &month_text(late))],
                        &[],
                    )),
                    (Some(early), None) => Some(i18n::message_of(
                        language,
                        "goal-when-range-open",
                        &[("early", &month_text(early))],
                        &[],
                    )),
                    _ => None,
                };
                let horizon = reached[0].unwrap_or(months + months / 2).max(months + 2).min(HORIZON);
                (headline, range, "good", horizon, Some(target), Some(months))
            } else {
                let mut headline =
                    i18n::message_of(language, "goal-when-never", &[("amount", &amount(target))], &[]);
                if let Some(months) = zero {
                    headline.push(' ');
                    headline.push_str(&i18n::message_of(
                        language,
                        "goal-zero",
                        &[("month", &month_text(months))],
                        &[],
                    ));
                }
                let horizon = zero.map_or(36, |months| (months + 3).min(HORIZON));
                (headline, None, "bad", horizon, Some(target), zero)
            }
        }
        Answer::Amount { months, values } => {
            tiles.push(Tile { label: label("goal-tile-date"), value: month_text(months) });
            tiles.push(Tile { label: label("goal-tile-projected"), value: amount(values[1]) });
            tiles.push(Tile { label: label("goal-tile-saved"), value: signed(values[1] - flows.balance, language) });
            if request.rate > 0.0 {
                if let Some(&(_, _, interest)) = probable(months).last() {
                    tiles.push(Tile { label: label("goal-tile-interest"), value: amount(interest) });
                }
            }
            let headline = i18n::message_of(
                language,
                "goal-amount",
                &[("month", &month_text(months)), ("amount", &amount(values[1]))],
                &[],
            );
            let range = (values[0] != values[2]).then(|| {
                i18n::message_of(
                    language,
                    "goal-amount-range",
                    &[("low", &amount(values[0])), ("high", &amount(values[2]))],
                    &[],
                )
            });
            let tone = if values[1] >= flows.balance { "good" } else { "bad" };
            (headline, range, tone, months, None, Some(months))
        }
        Answer::Effort { target, months, extra } => {
            tiles.push(Tile { label: label("goal-tile-target"), value: amount(target) });
            tiles.push(Tile { label: label("goal-tile-date"), value: month_text(months) });
            let needed = flows.mean + extra[1];
            tiles.push(Tile {
                label: label("goal-tile-needed"),
                value: per_month(amount(needed), language),
            });
            let key = if extra[1] > 0 { "goal-effort-more" } else { "goal-effort-less" };
            let headline = i18n::message_of(
                language,
                key,
                &[
                    ("amount", &amount(target)),
                    ("month", &month_text(months)),
                    ("monthly", &amount(needed)),
                    ("gap", &amount(extra[1].abs())),
                ],
                &[],
            );
            let range = (extra[0] != extra[2]).then(|| {
                i18n::message_of(
                    language,
                    "goal-effort-range",
                    &[("low", &signed(extra[2], language)), ("high", &signed(extra[0], language))],
                    &[],
                )
            });
            let tone = if extra[1] > 0 { "warn" } else { "good" };
            (headline, range, tone, months, Some(target), Some(months))
        }
    };

    // La courbe : l'effort cherché remplace l'effort tapé pour la troisième
    // question — on y voit la projection arriver sur l'objectif.
    let (extra_drawn, band) = match *answer {
        Answer::Effort { extra, .. } => (extra[1], false),
        _ => (request.extra, true),
    };
    let draw = |scenario: Scenario| -> Vec<i64> {
        flows
            .project(today, scenario, extra_drawn, request.rate, horizon)
            .iter()
            .map(|(_, balance, _)| *balance)
            .collect()
    };
    let current = matches!(answer, Answer::Effort { .. }).then(|| {
        flows
            .project(today, Scenario::Probable, 0, request.rate, horizon)
            .iter()
            .map(|(_, balance, _)| *balance)
            .collect::<Vec<_>>()
    });
    let chart = chart(
        flows,
        today,
        &draw(Scenario::Probable),
        band.then(|| (draw(Scenario::Prudent), draw(Scenario::Favorable))),
        current.as_deref(),
        target_line,
        mark,
        language,
    );

    let mut notes = vec![label("goal-note-seasons"), label("goal-note-range")];
    for loan in &flows.loans {
        if months_until(today, loan.end) < HORIZON as i64 {
            notes.push(i18n::message_of(
                language,
                "goal-note-loan",
                &[
                    ("label", &loan.label),
                    ("month", &i18n::month_and_year(language, loan.end)),
                    ("amount", &amount(loan.monthly)),
                ],
                &[],
            ));
        }
    }
    if request.rate > 0.0 {
        let rate = crate::appliance::decimal(request.rate, 2, language);
        notes.push(i18n::message_of(language, "goal-note-interest", &[("rate", &rate)], &[]));
    }

    let period = match (flows.months.first(), flows.months.last()) {
        (Some(&(first, _)), Some(&(last, _))) => i18n::message_of(
            language,
            "goal-period",
            &[
                ("from", &i18n::month_and_year(language, first)),
                ("to", &i18n::month_and_year(language, last)),
            ],
            &[("count", flows.months.len() as i64), ("transfers", flows.transfers as i64)],
        ),
        _ => String::new(),
    };

    Written {
        headline,
        range,
        tone: tone.to_string(),
        tiles,
        chart,
        notes,
        period,
    }
}

pub(crate) fn short_month(day: NaiveDate) -> String {
    format!("{:02}/{:02}", day.month(), day.year() % 100)
}

/// **La courbe : hier en trait plein, demain en pointillés.** Le solde réel
/// des douze derniers mois, puis la projection probable, la fourchette en
/// bande claire, la ligne de l'objectif, et un trait au mois visé.
#[allow(clippy::too_many_arguments)]
fn chart(
    flows: &Flows,
    today: NaiveDate,
    probable: &[i64],
    band: Option<(Vec<i64>, Vec<i64>)>,
    current: Option<&[i64]>,
    target: Option<i64>,
    mark: Option<usize>,
    language: Language,
) -> String {
    let (width, height) = (760.0, 270.0);
    let mut out = svg_open(width, height, "loan-chart--line");
    let past: Vec<i64> = flows.past.iter().map(|(_, value)| *value).chain([flows.balance]).collect();
    let all = past
        .iter()
        .chain(probable)
        .chain(band.iter().flat_map(|(low, high)| low.iter().chain(high)))
        .chain(current.into_iter().flatten())
        .copied()
        .chain(target);
    let (low, high) = bounds_of(all);
    // Un peu d'air au-dessus : la ligne de l'objectif et son mot ne collent
    // pas au bord.
    let high = high + (high - low) / 12;
    let graduations = ticks(low, high);
    let frame = Frame {
        left: 96.0,
        right: width - 24.0,
        top: 18.0,
        bottom: height - 34.0,
        low: *graduations.first().unwrap_or(&low),
        high: *graduations.last().unwrap_or(&high),
    };
    axes(&mut out, &frame, &graduations, language);
    let today_rank = past.len() - 1;
    let total = today_rank + probable.len();
    let x = |rank: usize| frame.left + rank as f64 / total.max(1) as f64 * (frame.right - frame.left);
    let path = |values: &[i64], start: usize| -> String {
        values
            .iter()
            .enumerate()
            .map(|(rank, value)| format!("{:.1} {:.1}", x(start + rank), frame.y(*value)))
            .collect::<Vec<_>>()
            .join(" L ")
    };
    let ahead = |values: &[i64]| -> Vec<i64> { std::iter::once(flows.balance).chain(values.iter().copied()).collect() };

    if let Some((prudent, favorable)) = &band {
        let upper = ahead(favorable);
        let lower: Vec<i64> = ahead(prudent);
        let back: Vec<String> = lower
            .iter()
            .enumerate()
            .rev()
            .map(|(rank, value)| format!("{:.1} {:.1}", x(today_rank + rank), frame.y(*value)))
            .collect();
        out.push_str(&format!(
            "<path d=\"M {} L {} Z\" fill=\"{}\" fill-opacity=\"0.22\"/>",
            path(&upper, today_rank),
            back.join(" L "),
            loan_charts::SKY
        ));
    }
    if let Some(value) = target {
        let at = frame.y(value);
        out.push_str(&format!(
            "<line x1=\"{}\" y1=\"{at:.1}\" x2=\"{}\" y2=\"{at:.1}\" stroke=\"{gold}\" stroke-width=\"1.4\" stroke-dasharray=\"6 4\"/>",
            frame.left,
            frame.right,
            gold = loan_charts::GOLD
        ));
        let words = i18n::message_of(language, "goal-chart-target", &[("amount", &money::format(value, language))], &[]);
        out.push_str(&text(frame.left + 6.0, at - 6.0, 11.0, loan_charts::GOLD, "start", "bold", &words));
    }
    // Aujourd'hui : un trait fin.
    let now = x(today_rank);
    out.push_str(&format!(
        "<line x1=\"{now:.1}\" y1=\"{}\" x2=\"{now:.1}\" y2=\"{}\" stroke=\"{}\" stroke-width=\"1\"/>",
        frame.top,
        frame.bottom,
        loan_charts::MUTED
    ));
    out.push_str(&text(now + 4.0, frame.bottom - 6.0, 11.0, loan_charts::MUTED, "start", "normal", &i18n::text(language, "goal-chart-today")));
    if let Some(values) = current {
        out.push_str(&format!(
            "<path d=\"M {}\" fill=\"none\" stroke=\"{}\" stroke-width=\"1.6\" stroke-dasharray=\"3 4\"/>",
            path(&ahead(values), today_rank),
            loan_charts::MUTED
        ));
    }
    out.push_str(&format!(
        "<path d=\"M {}\" fill=\"none\" stroke=\"{navy}\" stroke-width=\"2.4\" stroke-linejoin=\"round\"/>",
        path(&past, 0),
        navy = loan_charts::NAVY
    ));
    out.push_str(&format!(
        "<path d=\"M {}\" fill=\"none\" stroke=\"{navy}\" stroke-width=\"2.4\" stroke-dasharray=\"7 5\" stroke-linejoin=\"round\"/>",
        path(&ahead(probable), today_rank),
        navy = loan_charts::NAVY
    ));
    if let Some(months) = mark.filter(|&months| months <= probable.len()) {
        let at = x(today_rank + months);
        out.push_str(&format!(
            "<line x1=\"{at:.1}\" y1=\"{}\" x2=\"{at:.1}\" y2=\"{}\" stroke=\"{gold}\" stroke-width=\"1.4\" stroke-dasharray=\"4 3\"/>",
            frame.top,
            frame.bottom,
            gold = loan_charts::GOLD
        ));
        let anchor = if at > frame.right - 120.0 { "end" } else { "start" };
        let shift = if anchor == "end" { -5.0 } else { 5.0 };
        let words = i18n::month_and_year(language, month_at(today, months));
        out.push_str(&text(at + shift, frame.top + 11.0, 12.0, loan_charts::GOLD, anchor, "bold", &words));
    }
    // Les étiquettes d'axe : six au plus.
    let months: Vec<NaiveDate> = flows
        .past
        .iter()
        .map(|(month, _)| *month)
        .chain([first_of(today)])
        .chain((1..=probable.len()).map(|rank| month_at(today, rank)))
        .collect();
    let every = months.len().div_ceil(6).max(1);
    for (rank, month) in months.iter().enumerate() {
        let last = rank == months.len() - 1;
        if last || (rank % every == 0 && months.len() - 1 - rank > every / 2) {
            let anchor = if last { "end" } else if rank == 0 { "start" } else { "middle" };
            out.push_str(&text(x(rank), height - 12.0, 12.0, loan_charts::MUTED, anchor, "normal", &short_month(*month)));
        }
    }
    out.push_str("</svg>");
    out
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::loan::History;
    use crate::database::{schema, seed};

    const EURO: i64 = money::UNIT;

    fn date(year: i32, month: u32, day: u32) -> NaiveDate {
        NaiveDate::from_ymd_opt(year, month, day).unwrap()
    }

    /// Un compte courant à 1 000 €, un livret à 5 000 €, un PEL à 9 000 €.
    fn database() -> Connection {
        let conn = Connection::open_in_memory().expect("base en mémoire");
        schema::migrate(&conn).expect("schéma");
        seed::seed_initial_data(&conn).expect("valeurs initiales");
        for (id, label, real) in [(1, "CCP", 1_000 * EURO), (2, "Livret", 5_000 * EURO), (3, "PEL", 9_000 * EURO)] {
            conn.execute(
                "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte, IDBanques, SoldeBanque,
                                     SoldeReel, SoldeFinal, CompteCloture)
                 VALUES (?1, ?2, 1, 1, ?3, ?3, ?3, 0)",
                rusqlite::params![id, label, real],
            )
            .expect("compte");
        }
        conn
    }

    struct Adder<'a> {
        conn: &'a Connection,
        id: i64,
    }

    impl Adder<'_> {
        fn add(&mut self, account: i64, day: &str, amount: i64) {
            self.id += 1;
            self.conn
                .execute(
                    "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte,
                                            IDStatutOperation, IDOperationParent)
                     VALUES (?1, 'OP', ?2, ?3, ?4, 1, 0)",
                    rusqlite::params![self.id, day, amount, account],
                )
                .expect("opération");
        }
    }

    fn today() -> NaiveDate {
        date(2026, 10, 10)
    }

    /// 2025 : chaque mois +2 000 € de salaire et -1 700 € de dépenses sur le
    /// CCP, 200 € virés du CCP au livret, et en décembre 600 € de prime.
    fn history(conn: &Connection) {
        let mut ops = Adder { conn, id: 0 };
        for month in 1..=12 {
            let day = |d: u32| format!("2025-{month:02}-{d:02}");
            ops.add(1, &day(1), 2_000 * EURO);
            ops.add(1, &day(5), -1_700 * EURO);
            ops.add(1, &day(20), -200 * EURO);
            ops.add(2, &day(21), 200 * EURO);
        }
        ops.add(1, "2025-12-15", 600 * EURO);
    }

    fn request(accounts: Vec<i64>, question: Question) -> Request {
        Request {
            accounts,
            period: Period::History(History::Year(2025)),
            question,
            rate: 0.0,
            extra: 0,
        }
    }

    /// **Le rythme** : les deux comptes suivis gagnent 300 € par mois et 900 €
    /// en décembre ; le virement de l'un à l'autre s'annule. Suivi seul, le
    /// livret gagne 200 € par mois : le virement reçu est son épargne.
    #[test]
    fn le_rythme_se_lit_juste() {
        let conn = database();
        history(&conn);
        let both = read(&conn, &[1, 2], Period::History(History::Year(2025)), today()).unwrap().unwrap();
        assert_eq!(both.mean, 350 * EURO);
        assert_eq!(both.profile[0], 300 * EURO);
        assert_eq!(both.profile[11], 900 * EURO);
        assert_eq!(both.transfers, 12);
        assert_eq!(both.balance, 6_000 * EURO);
        assert_eq!(both.low, 300 * EURO);
        let livret = read(&conn, &[2], Period::History(History::Year(2025)), today()).unwrap().unwrap();
        assert_eq!(livret.mean, 200 * EURO);
        assert_eq!(livret.transfers, 0);
        assert_eq!(livret.balance, 5_000 * EURO);
    }

    /// **L'année type** : la projection suit les saisons — décembre rapporte
    /// 900 €, les autres mois 300 €.
    #[test]
    fn la_projection_suit_les_saisons() {
        let conn = database();
        history(&conn);
        let flows = read(&conn, &[1, 2], Period::History(History::Year(2025)), today()).unwrap().unwrap();
        let projected = flows.project(today(), Scenario::Probable, 0, 0.0, 3);
        assert_eq!(projected[0].0, date(2026, 11, 1));
        assert_eq!(projected[0].1, 6_300 * EURO);
        assert_eq!(projected[1].1, 7_200 * EURO);
        assert_eq!(projected[2].1, 7_500 * EURO);
        // Quand aurai-je 7 000 € ? En décembre, dans deux mois.
        let asked = request(vec![1, 2], Question::When { target: 7_000 * EURO });
        let Answer::When { reached, already, .. } = answer(&flows, &asked, today()).unwrap() else {
            panic!("une date");
        };
        assert!(!already);
        assert_eq!(reached[1], Some(2));
    }

    /// **Une plage d'années** : tous les mois complets des années choisies,
    /// l'année en cours jusqu'au dernier mois fini.
    #[test]
    fn une_plage_d_annees_couvre_ses_mois() {
        let months = Period::from_keys("range", 2026, 2024).months(today());
        assert_eq!(months.len(), 12 + 12 + 9);
        assert_eq!(months[0], date(2024, 1, 1));
        assert_eq!(*months.last().unwrap(), date(2026, 9, 1));
        assert_eq!(Period::from_keys("2025", 0, 0), Period::History(History::Year(2025)));
        assert_eq!(Period::years(today()), vec![2026, 2025, 2024, 2023, 2022, 2021]);
    }

    /// **Combien épargner** : pour 10 000 € dans 10 mois en partant de
    /// 6 000 € au rythme de 300 € (et 900 € en décembre), il manque 400 € :
    /// 40 € de plus par mois.
    #[test]
    fn l_effort_se_trouve_au_centime() {
        let conn = database();
        history(&conn);
        let flows = read(&conn, &[1, 2], Period::History(History::Year(2025)), today()).unwrap().unwrap();
        let month = date(2027, 8, 1);
        assert_eq!(months_until(today(), month), 10);
        let asked = request(vec![1, 2], Question::Effort { target: 10_000 * EURO, month });
        let Answer::Effort { extra, months, .. } = answer(&flows, &asked, today()).unwrap() else {
            panic!("un effort");
        };
        assert_eq!(months, 10);
        assert!((extra[1] - 40 * EURO).abs() <= EURO / 100, "{}", extra[1]);
        // Et la question inverse le confirme.
        let check = Request { extra: extra[1], question: Question::Amount { month }, ..asked };
        let Answer::Amount { values, .. } = answer(&flows, &check, today()).unwrap() else {
            panic!("un montant");
        };
        assert!(values[1] >= 10_000 * EURO && values[1] - 10_000 * EURO < EURO / 10);
    }

    #[test]
    fn les_interets_et_les_dates_impossibles() {
        let conn = database();
        history(&conn);
        let flows = read(&conn, &[2], Period::History(History::Year(2025)), today()).unwrap().unwrap();
        let with = flows.project(today(), Scenario::Probable, 0, 3.0, 12);
        let without = flows.project(today(), Scenario::Probable, 0, 0.0, 12);
        assert!(with.last().unwrap().1 > without.last().unwrap().1);
        assert!(with.last().unwrap().2 > 150 * EURO);
        let past = request(vec![2], Question::Amount { month: date(2026, 9, 1) });
        assert_eq!(answer(&flows, &past, today()), Err(Unavailable::BadDate));
        assert_eq!(read(&conn, &[], Period::History(History::LastTwelve), today()).unwrap(), Err(Unavailable::NoAccount));
    }

    /// **Un rythme qui baisse** : l'objectif n'est jamais atteint, et la
    /// fenêtre dit quand le solde tomberait à zéro.
    #[test]
    fn un_rythme_negatif_le_dit() {
        let conn = database();
        let mut ops = Adder { conn: &conn, id: 0 };
        for month in 1..=12 {
            ops.add(1, &format!("2025-{month:02}-05"), -250 * EURO);
        }
        let flows = read(&conn, &[1], Period::History(History::Year(2025)), today()).unwrap().unwrap();
        let asked = request(vec![1], Question::When { target: 5_000 * EURO });
        let found = answer(&flows, &asked, today()).unwrap();
        assert_eq!(found, Answer::When { target: 5_000 * EURO, already: false, reached: [None; 3], zero: Some(4) });
        let written = write(&flows, &asked, &found, today(), Language::French);
        assert_eq!(written.tone, "bad");
        assert!(written.headline.contains("zéro"), "{}", written.headline);
        assert!(written.chart.starts_with("<svg"));
    }

    #[test]
    fn la_reponse_s_ecrit() {
        let conn = database();
        history(&conn);
        let flows = read(&conn, &[1, 2], Period::History(History::Year(2025)), today()).unwrap().unwrap();
        for question in [
            Question::When { target: 9_000 * EURO },
            Question::Amount { month: date(2027, 6, 1) },
            Question::Effort { target: 12_000 * EURO, month: date(2027, 6, 1) },
        ] {
            let asked = Request { rate: 2.0, ..request(vec![1, 2], question) };
            let found = answer(&flows, &asked, today()).unwrap();
            let written = write(&flows, &asked, &found, today(), Language::French);
            assert!(!written.headline.is_empty() && !written.headline.contains('{'), "{}", written.headline);
            assert!(written.tiles.len() >= 4);
            assert!(written.notes.iter().any(|note| note.contains("2,00")));
            assert!(!written.period.is_empty());
        }
    }
}
