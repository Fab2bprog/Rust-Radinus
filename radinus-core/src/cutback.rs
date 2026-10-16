//! Et si je réduisais… ? — F45 (Fabrice, 10/10/2026).
//!
//! « Imaginer que l'on réduise en pourcentage ou en valeur les dépenses d'une
//! ou plusieurs catégories et voir l'impact sur une projection dans le
//! futur. »
//!
//! - **La base, réelle** : les comptes suivis et la période de référence,
//!   plage d'années comprise — les mêmes que pour « Objectif Épargne », dont
//!   la projection est reprise telle quelle (année type, crédits qui se
//!   terminent, intérêts).
//! - **Les postes**, au choix (Fabrice : « au choix catégories / tiers /
//!   postes budgétaires ») : ce que chacun a coûté en moyenne par mois, les
//!   virements entre comptes suivis mis à part. Une opération ventilée compte
//!   par ses filles, comme dans les statistiques.
//! - **La réduction** se tape en pourcent ou en euros par mois, et ne dépasse
//!   jamais la dépense elle-même. Elle suit les saisons de son poste : réduire
//!   de 20 % un poste qui pèse surtout l'été rapporte surtout l'été.
//! - **L'horizon** se règle au curseur, de 1 à 10 ans (« un curseur en années
//!   de 1 à 10 ans ») ; un taux d'intérêt et un montant visé sont facultatifs.
//!
//! Rien n'est enregistré — les réductions s'oublient à la fermeture de la
//! fenêtre (« on oublie les chiffres à la fermeture ») — mais **un rapport
//! PDF** les garde (« ça peut être complexe à saisir et c'est une façon de
//! sauvegarder les infos »).

use crate::domain::NaiveDate;
use crate::i18n::{self, Language};
use crate::loan::{first_of, last_of, Period};
use crate::loan_charts::{self, axes, bounds_of, svg_open, text, ticks, Frame, Part};
use crate::money;
use crate::printing::{self, Failure};
use crate::sheets::{Sheet, SheetCell};
use crate::savings_goal::{self as goal, day_of, iso, month_at, short_month, Flows, Scenario, HORIZON};
use crate::statistics::Axis;
use rusqlite::{Connection, Result};
use std::collections::{BTreeMap, HashMap, HashSet};
use time_compute::Datelike;

pub use crate::savings_goal::Unavailable;

/// Les trois classements offerts.
pub const AXES: [Axis; 3] = [Axis::Category, Axis::Payee, Axis::BudgetLine];

/// L'horizon le plus long, en années.
pub const YEARS_LIMIT: u32 = 10;

/// Les opérations sans classement — ou dont le classement a disparu.
pub const UNCLASSIFIED: i64 = 0;

/// Le classement demandé, ou les catégories.
pub fn axis_from_key(key: &str) -> Axis {
    AXES.into_iter().find(|axis| axis.key() == key).unwrap_or(Axis::Category)
}

/// **Une réduction**, telle que tapée.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Cut {
    /// En pourcent de la dépense, de 0 à 100.
    Percent(f64),
    /// En euros par mois.
    Amount(i64),
}

/// Ce que la personne a coché et tapé.
#[derive(Debug, Clone, PartialEq)]
pub struct Request {
    pub accounts: Vec<i64>,
    pub period: Period,
    pub axis: Axis,
    pub cuts: Vec<(i64, Cut)>,
    /// L'horizon, de 1 à 10 ans.
    pub years: u32,
    /// Le taux annuel, en pourcent.
    pub rate: f64,
    pub target: Option<i64>,
}

/// Un poste et ce qu'il a coûté.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Item {
    pub id: i64,
    pub label: String,
    /// La moyenne par mois, en positif.
    pub monthly: i64,
    /// L'année type du poste : la moyenne de chaque mois du calendrier.
    pub profile: [i64; 12],
}

/// **Ce que l'historique dit des comptes suivis**, et leurs postes.
#[derive(Debug, Clone, PartialEq)]
pub struct Reading {
    pub flows: Flows,
    /// Les postes qui ont porté une dépense, le plus lourd d'abord.
    pub items: Vec<Item>,
}

/// **Lit l'historique.** `unclassified_label` nomme la ligne des opérations
/// sans classement, dans la langue de l'appelant.
pub fn read(
    conn: &Connection,
    request: &Request,
    today: NaiveDate,
    unclassified_label: &str,
) -> Result<std::result::Result<Reading, Unavailable>> {
    let flows = match goal::read(conn, &request.accounts, request.period, today)? {
        Ok(flows) => flows,
        Err(unavailable) => return Ok(Err(unavailable)),
    };
    let months = request.period.months(today);
    let (Some(&first), Some(&last)) = (months.first(), months.last()) else {
        return Ok(Err(Unavailable::NoMonth));
    };
    let neutral: HashSet<i64> = flows.neutral.iter().copied().collect();
    let known: HashMap<i64, String> = request
        .axis
        .elements(conn)?
        .into_iter()
        .map(|item| (item.id, item.label))
        .collect();

    // Les feuilles débitrices des comptes suivis : une mère ventilée compte
    // par ses filles, chacune sous son classement.
    let marks = request.accounts.iter().map(|_| "?").collect::<Vec<_>>().join(",");
    let sql = format!(
        "SELECT o.IDOperation, o.IDOperationParent, o.Montant,
                COALESCE(o.Date, o.DatePointage), {key}
         FROM Operation o
         WHERE o.IDCompte IN ({marks}) AND o.IDStatutOperation IN (1, 2)
           AND o.Montant < 0
           AND COALESCE(o.Date, o.DatePointage) BETWEEN ? AND ?
           AND (o.IDOperationParent <> 0
                OR NOT EXISTS (SELECT 1 FROM Operation f
                               WHERE f.IDOperationParent = o.IDOperation))",
        key = request.axis.key_expression()
    );
    let mut parameters: Vec<rusqlite::types::Value> = request
        .accounts
        .iter()
        .map(|id| rusqlite::types::Value::Integer(*id))
        .collect();
    parameters.push(iso(first));
    parameters.push(iso(last_of(last)));
    let mut statement = conn.prepare(&sql)?;
    let mut rows = statement.query(rusqlite::params_from_iter(parameters))?;
    // Par poste, ce qu'il a coûté chaque mois de la période.
    let mut spent: BTreeMap<i64, BTreeMap<NaiveDate, i64>> = BTreeMap::new();
    while let Some(row) = rows.next()? {
        let (id, parent, amount): (i64, i64, i64) = (row.get(0)?, row.get(1)?, row.get(2)?);
        let Some(day) = day_of(row.get(3)?) else {
            continue;
        };
        if neutral.contains(&id) || neutral.contains(&parent) {
            continue;
        }
        let key: i64 = row.get(4)?;
        let key = if known.contains_key(&key) { key } else { UNCLASSIFIED };
        *spent.entry(key).or_default().entry(first_of(day)).or_default() -= amount;
    }

    let count = months.len() as i64;
    let mut items: Vec<Item> = spent
        .into_iter()
        .map(|(id, by_month)| {
            let total: i64 = by_month.values().sum();
            let monthly = total / count;
            let mut profile = [monthly; 12];
            for (rank, slot) in profile.iter_mut().enumerate() {
                let same: Vec<i64> = months
                    .iter()
                    .filter(|month| month.month0() as usize == rank)
                    .map(|month| by_month.get(month).copied().unwrap_or(0))
                    .collect();
                if !same.is_empty() {
                    *slot = same.iter().sum::<i64>() / same.len() as i64;
                }
            }
            Item {
                id,
                label: known.get(&id).cloned().unwrap_or_else(|| unclassified_label.to_string()),
                monthly,
                profile,
            }
        })
        .filter(|item| item.monthly > 0)
        .collect();
    items.sort_by(|a, b| b.monthly.cmp(&a.monthly).then_with(|| a.label.cmp(&b.label)));
    Ok(Ok(Reading { flows, items }))
}

/// **Ce qu'une réduction fait gagner par mois**, en moyenne, et si elle a dû
/// être ramenée à la dépense elle-même.
pub fn saving(item: &Item, cut: Cut) -> (i64, bool) {
    match cut {
        Cut::Percent(percent) => {
            let percent = percent.clamp(0.0, 100.0);
            ((item.monthly as f64 * percent / 100.0).round() as i64, false)
        }
        Cut::Amount(amount) => (amount.clamp(0, item.monthly), amount > item.monthly),
    }
}

/// **Le résultat.**
#[derive(Debug, Clone, PartialEq)]
pub struct Outcome {
    /// Le gain moyen par mois.
    pub monthly: i64,
    /// Les dépenses moyennes par mois, avant et après.
    pub before: i64,
    pub after: i64,
    /// Les postes réduits.
    pub count: usize,
    /// Le solde, mois après mois, sans et avec les réductions : (mois, solde,
    /// intérêts cumulés).
    pub without: Vec<(NaiveDate, i64, i64)>,
    pub with: Vec<(NaiveDate, i64, i64)>,
    /// Le montant visé atteint, sans et avec, en mois depuis aujourd'hui.
    pub reached: Option<(Option<usize>, Option<usize>)>,
}

impl Outcome {
    /// Le gain sur l'horizon, intérêts compris, et la part des intérêts.
    pub fn gain(&self) -> (i64, i64) {
        match (self.without.last(), self.with.last()) {
            (Some(&(_, without, interest_without)), Some(&(_, with, interest_with))) => {
                (with - without, interest_with - interest_without)
            }
            _ => (0, 0),
        }
    }
}

/// **Projette**, sans et avec les réductions.
pub fn outcome(reading: &Reading, request: &Request, today: NaiveDate) -> Outcome {
    let cuts: HashMap<i64, Cut> = request.cuts.iter().copied().collect();
    // Ce que chaque poste réduit rapporte selon le mois du calendrier.
    let mut seasonal = [0_i64; 12];
    let mut monthly = 0;
    let mut count = 0;
    for item in &reading.items {
        let Some(&cut) = cuts.get(&item.id) else {
            continue;
        };
        let (saved, _) = saving(item, cut);
        if saved == 0 {
            continue;
        }
        count += 1;
        monthly += saved;
        let share = saved as f64 / item.monthly as f64;
        for (slot, spent) in seasonal.iter_mut().zip(item.profile) {
            *slot += (spent as f64 * share).round() as i64;
        }
    }
    let months = (request.years.clamp(1, YEARS_LIMIT) * 12) as usize;
    let flows = &reading.flows;
    let without = flows.project(today, Scenario::Probable, 0, request.rate, months);
    let with = flows.project_with(
        today,
        Scenario::Probable,
        |month| seasonal[month.month0() as usize],
        request.rate,
        months,
    );
    let reached = request.target.map(|target| {
        let first = |values: Vec<(NaiveDate, i64, i64)>| {
            values.iter().position(|(_, balance, _)| *balance >= target).map(|rank| rank + 1)
        };
        (
            first(flows.project(today, Scenario::Probable, 0, request.rate, HORIZON)),
            first(flows.project_with(
                today,
                Scenario::Probable,
                |month| seasonal[month.month0() as usize],
                request.rate,
                HORIZON,
            )),
        )
    });
    let before: i64 = reading.items.iter().map(|item| item.monthly).sum();
    Outcome {
        monthly,
        before,
        after: before - monthly,
        count,
        without,
        with,
        reached,
    }
}

// --- Ce que la fenêtre montre ---------------------------------------------------

#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Tile {
    pub label: String,
    pub value: String,
}

/// Une ligne du tableau.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Row {
    pub id: i64,
    pub label: String,
    pub monthly: String,
    /// La réduction telle que tapée — « −20 % », « −15,00 € » — ou vide.
    pub cut: String,
    pub after: String,
    pub yearly: String,
    /// La réduction tapée dépassait la dépense : elle y a été ramenée.
    pub capped: bool,
    pub reduced: bool,
}

/// **Tout ce que la fenêtre affiche, déjà écrit.**
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Written {
    pub headline: String,
    /// `good` dès qu'une réduction joue, `none` sinon.
    pub tone: String,
    pub tiles: Vec<Tile>,
    pub rows: Vec<Row>,
    pub total: Row,
    pub target: Option<String>,
    pub years: String,
    pub chart: String,
    pub donut: String,
    pub notes: Vec<String>,
    pub period: String,
}

fn cut_text(cut: Cut, language: Language) -> String {
    match cut {
        Cut::Percent(percent) => format!(
            "−{}",
            i18n::message_of(
                language,
                "loan-percent",
                &[("value", &crate::appliance::decimal(percent, if percent.fract() == 0.0 { 0 } else { 1 }, language))],
                &[],
            )
        ),
        Cut::Amount(amount) => format!("−{}", money::format(amount, language)),
    }
}

fn per_month(amount: i64, language: Language) -> String {
    i18n::message_of(language, "goal-per-month", &[("amount", &money::format(amount, language))], &[])
}

/// **Écrit le résultat.**
pub fn write(reading: &Reading, request: &Request, outcome: &Outcome, today: NaiveDate, language: Language) -> Written {
    let label = |key: &str| i18n::text(language, key);
    let amount = |value: i64| money::format(value, language);
    let years = request.years.clamp(1, YEARS_LIMIT);
    let years_text = i18n::message_of(language, "cut-years", &[], &[("years", i64::from(years))]);
    let cuts: HashMap<i64, Cut> = request.cuts.iter().copied().collect();

    let rows: Vec<Row> = reading
        .items
        .iter()
        .map(|item| {
            let cut = cuts.get(&item.id).copied();
            let (saved, capped) = cut.map_or((0, false), |cut| saving(item, cut));
            Row {
                id: item.id,
                label: item.label.clone(),
                monthly: amount(item.monthly),
                cut: cut.filter(|_| saved > 0).map(|cut| cut_text(cut, language)).unwrap_or_default(),
                after: amount(item.monthly - saved),
                yearly: if saved > 0 { format!("+{}", amount(saved * 12)) } else { String::new() },
                capped,
                reduced: saved > 0,
            }
        })
        .collect();
    let total = Row {
        id: -1,
        label: label("cut-total"),
        monthly: amount(outcome.before),
        cut: if outcome.monthly > 0 { format!("−{}", amount(outcome.monthly)) } else { String::new() },
        after: amount(outcome.after),
        yearly: if outcome.monthly > 0 { format!("+{}", amount(outcome.monthly * 12)) } else { String::new() },
        capped: false,
        reduced: outcome.monthly > 0,
    };

    let (gain, interest) = outcome.gain();
    let headline = if outcome.monthly == 0 {
        label("cut-headline-none")
    } else {
        i18n::message_of(
            language,
            "cut-headline",
            &[("monthly", &amount(outcome.monthly)), ("yearly", &amount(outcome.monthly * 12))],
            &[("count", outcome.count as i64)],
        )
    };
    let mut tiles = vec![
        Tile { label: label("cut-tile-monthly"), value: amount(outcome.monthly) },
        Tile { label: label("cut-tile-yearly"), value: amount(outcome.monthly * 12) },
        Tile {
            label: i18n::message_of(language, "cut-tile-horizon", &[], &[("years", i64::from(years))]),
            value: amount(gain),
        },
    ];
    if request.rate > 0.0 {
        tiles.push(Tile { label: label("goal-tile-interest"), value: amount(interest) });
    }
    tiles.push(Tile {
        label: label("cut-tile-spending"),
        value: format!("{} → {}", amount(outcome.before), amount(outcome.after)),
    });

    let month_text = |months: usize| i18n::month_and_year(language, month_at(today, months));
    let target = match (request.target, outcome.reached) {
        (Some(goal), _) if reading.flows.balance >= goal => Some(i18n::message_of(
            language,
            "cut-target-already",
            &[("amount", &amount(goal))],
            &[],
        )),
        (Some(goal), Some((Some(without), Some(with)))) => Some(i18n::message_of(
            language,
            "cut-target-sooner",
            &[("amount", &amount(goal)), ("with", &month_text(with)), ("without", &month_text(without))],
            &[("months", without.saturating_sub(with) as i64)],
        )),
        (Some(goal), Some((None, Some(with)))) => Some(i18n::message_of(
            language,
            "cut-target-only-with",
            &[("amount", &amount(goal)), ("with", &month_text(with))],
            &[],
        )),
        (Some(goal), Some((_, None))) => Some(i18n::message_of(
            language,
            "cut-target-never",
            &[("amount", &amount(goal))],
            &[],
        )),
        _ => None,
    };

    let chart = chart(&reading.flows, today, &outcome.without, &outcome.with, request.target, language);

    // L'anneau : les cinq postes les plus lourds après réduction, les autres
    // ensemble, et ce qui est économisé, en vert.
    let mut after: Vec<(String, i64)> = reading
        .items
        .iter()
        .map(|item| {
            let saved = cuts.get(&item.id).map_or(0, |cut| saving(item, *cut).0);
            (item.label.clone(), item.monthly - saved)
        })
        .collect();
    after.sort_by_key(|(_, value)| std::cmp::Reverse(*value));
    let colours = [
        loan_charts::NAVY,
        loan_charts::SLATE,
        loan_charts::SKY,
        loan_charts::SAND,
        loan_charts::GOLD,
    ];
    let mut parts: Vec<Part> = after
        .iter()
        .take(colours.len())
        .zip(colours)
        .map(|((name, value), colour)| Part {
            label: name.clone(),
            amount: *value,
            written: per_month(*value, language),
            colour,
        })
        .collect();
    let others: i64 = after.iter().skip(colours.len()).map(|(_, value)| value).sum();
    if others > 0 {
        parts.push(Part {
            label: label("cut-donut-others"),
            amount: others,
            written: per_month(others, language),
            colour: loan_charts::MUTED,
        });
    }
    if outcome.monthly > 0 {
        parts.push(Part {
            label: label("cut-donut-saved"),
            amount: outcome.monthly,
            written: per_month(outcome.monthly, language),
            colour: loan_charts::GREEN,
        });
    }
    let donut = loan_charts::donut(&parts, &amount(outcome.after), &label("cut-donut-caption"));

    let mut notes = vec![label("cut-note-seasons")];
    if rows.iter().any(|row| row.capped) {
        notes.push(label("cut-note-capped"));
    }
    for loan in &reading.flows.loans {
        if goal::months_until(today, loan.end) < HORIZON as i64 {
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

    let flows = &reading.flows;
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
        tone: if outcome.monthly > 0 { "good" } else { "none" }.to_string(),
        tiles,
        rows,
        total,
        target,
        years: years_text,
        chart,
        donut,
        notes,
        period,
    }
}

/// **La courbe** : le solde réel des douze derniers mois, puis deux
/// projections — sans les réductions en pointillés gris, avec elles en bleu
/// nuit —, l'écart entre les deux en vert : l'argent gagné.
fn chart(
    flows: &Flows,
    today: NaiveDate,
    without: &[(NaiveDate, i64, i64)],
    with: &[(NaiveDate, i64, i64)],
    target: Option<i64>,
    language: Language,
) -> String {
    let (width, height) = (760.0, 270.0);
    let mut out = svg_open(width, height, "loan-chart--line");
    let past: Vec<i64> = flows.past.iter().map(|(_, value)| *value).chain([flows.balance]).collect();
    let ahead = |values: &[(NaiveDate, i64, i64)]| -> Vec<i64> {
        std::iter::once(flows.balance).chain(values.iter().map(|(_, balance, _)| *balance)).collect()
    };
    let (plain, better) = (ahead(without), ahead(with));
    let (low, high) = bounds_of(past.iter().chain(&plain).chain(&better).copied().chain(target));
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
    let total = today_rank + without.len();
    let x = |rank: usize| frame.left + rank as f64 / total.max(1) as f64 * (frame.right - frame.left);
    let path = |values: &[i64], start: usize| -> Vec<String> {
        values
            .iter()
            .enumerate()
            .map(|(rank, value)| format!("{:.1} {:.1}", x(start + rank), frame.y(*value)))
            .collect()
    };
    // L'écart, en vert.
    let mut back = path(&plain, today_rank);
    back.reverse();
    out.push_str(&format!(
        "<path d=\"M {} L {} Z\" fill=\"{}\" fill-opacity=\"0.18\"/>",
        path(&better, today_rank).join(" L "),
        back.join(" L "),
        loan_charts::GREEN
    ));
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
    let now = x(today_rank);
    out.push_str(&format!(
        "<line x1=\"{now:.1}\" y1=\"{}\" x2=\"{now:.1}\" y2=\"{}\" stroke=\"{}\" stroke-width=\"1\"/>",
        frame.top,
        frame.bottom,
        loan_charts::MUTED
    ));
    out.push_str(&text(now + 4.0, frame.bottom - 6.0, 11.0, loan_charts::MUTED, "start", "normal", &i18n::text(language, "goal-chart-today")));
    out.push_str(&format!(
        "<path d=\"M {}\" fill=\"none\" stroke=\"{navy}\" stroke-width=\"2.4\" stroke-linejoin=\"round\"/>",
        path(&past, 0).join(" L "),
        navy = loan_charts::NAVY
    ));
    out.push_str(&format!(
        "<path d=\"M {}\" fill=\"none\" stroke=\"{}\" stroke-width=\"1.8\" stroke-dasharray=\"4 4\"/>",
        path(&plain, today_rank).join(" L "),
        loan_charts::MUTED
    ));
    out.push_str(&format!(
        "<path d=\"M {}\" fill=\"none\" stroke=\"{navy}\" stroke-width=\"2.4\" stroke-dasharray=\"7 5\" stroke-linejoin=\"round\"/>",
        path(&better, today_rank).join(" L "),
        navy = loan_charts::NAVY
    ));
    // La légende, en haut à droite.
    let legend_x = frame.right - 4.0;
    out.push_str(&text(legend_x, frame.top + 4.0, 11.0, loan_charts::NAVY, "end", "bold", &i18n::text(language, "cut-legend-with")));
    out.push_str(&text(legend_x, frame.top + 18.0, 11.0, loan_charts::MUTED, "end", "normal", &i18n::text(language, "cut-legend-without")));
    let months: Vec<NaiveDate> = flows
        .past
        .iter()
        .map(|(month, _)| *month)
        .chain([first_of(today)])
        .chain(without.iter().map(|(month, _, _)| *month))
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

// --- Le rapport PDF -------------------------------------------------------------

/// **Le rapport** : de quoi tout ressaisir plus tard — les comptes, la
/// période, le classement, les réglages, le tableau complet avec ses
/// réductions — et le résultat avec ses deux dessins.
pub fn pdf(
    conn: &Connection,
    reading: &Reading,
    request: &Request,
    outcome: &Outcome,
    today: NaiveDate,
    language: Language,
) -> std::result::Result<Vec<u8>, Failure> {
    let written = write(reading, request, outcome, today, language);
    let label = |key: &str| i18n::text(language, key);
    let q = |text: &str| printing::quoted(text);
    let mut out = String::new();
    let mut let_text = |name: &str, value: &str| out.push_str(&format!("#let {name} = {}\n", q(value)));
    let_text("famille", printing::FAMILY);
    let_text("langue", language.tag());
    let_text("logo", printing::LOGO_PATH);
    let_text("titre", &label("window-cut-title"));
    let_text(
        "sous-titre",
        &i18n::message_of(language, "loan-report-made-on", &[("date", &today.format("%d/%m/%Y").to_string())], &[]),
    );
    let_text("avertissement", &label("goal-disclaimer"));
    let_text("titre-reglages", &label("cut-report-settings"));
    let_text("titre-resultat", &label("cut-report-result"));
    let_text("titre-tableau", &label("cut-table-title"));
    let_text("titre-courbe", &label("cut-chart-title"));
    let_text("titre-anneau", &label("cut-donut-title"));
    let_text("phrase", &written.headline);
    let_text("objectif", written.target.as_deref().unwrap_or(""));
    let_text("courbe-svg", &written.chart);
    let_text("anneau-svg", &written.donut);
    let_text("periode", &written.period);

    let names: Vec<String> = crate::accounts::list(conn)?
        .into_iter()
        .filter(|row| request.accounts.contains(&row.id))
        .map(|row| row.label)
        .collect();
    let mut settings = vec![
        (label("cut-report-accounts"), names.join(", ")),
        (label("goal-period-label"), written.period.clone()),
        (label("cut-axis-label"), label(&format!("cut-axis-{}", request.axis.key()))),
        (label("cut-horizon-label"), written.years.clone()),
    ];
    if request.rate > 0.0 {
        settings.push((
            label("goal-field-rate"),
            format!("{} %", crate::appliance::decimal(request.rate, 2, language)),
        ));
    }
    if let Some(target) = request.target {
        settings.push((label("goal-field-target"), money::format(target, language)));
    }
    out.push_str("#let reglages = (\n");
    for (name, value) in &settings {
        out.push_str(&format!("  ({}, {}),\n", q(name), q(value)));
    }
    out.push_str(")\n#let tuiles = (\n");
    for tile in &written.tiles {
        out.push_str(&format!("  ({}, {}),\n", q(&tile.label), q(&tile.value)));
    }
    out.push_str(")\n#let notes = (\n");
    for note in &written.notes {
        out.push_str(&format!("  {},\n", q(note)));
    }
    out.push_str(")\n");
    out.push_str(&format!(
        "#let colonnes = ({}, {}, {}, {}, {})\n",
        q(&label(&format!("cut-axis-{}", request.axis.key()))),
        q(&label("cut-column-monthly")),
        q(&label("cut-column-cut")),
        q(&label("cut-column-after")),
        q(&label("cut-column-yearly")),
    ));
    out.push_str("#let lignes = (\n");
    for row in written.rows.iter().chain([&written.total]) {
        out.push_str(&format!(
            "  ({}, {}, {}, {}, {}, {}, {}),\n",
            q(&row.label),
            q(&row.monthly),
            q(&row.cut),
            q(&row.after),
            q(&row.yearly),
            if row.reduced { "true" } else { "false" },
            if row.id < 0 { "true" } else { "false" },
        ));
    }
    out.push_str(")\n");
    out.push_str(TEMPLATE);
    printing::compose(out, "radinus-reduction")
}

// --- Le projet en fichier, et le classeur -------------------------------------
//
// Fabrice, 10/10/2026 : « dans l'outil “Et si je réduisais ?”, rajoute
// enregistrement et chargement JSON et aussi export Excel » — comme pour
// « Préparer mes vacances ». La fenêtre oublie toujours à la fermeture ; le
// fichier est la mémoire qu'on choisit de garder.

/// Ce qui dit, en tête du fichier, qu'il s'agit d'un projet de réduction.
pub const FILE_MARK: &str = "radinus-projet-reduction";
/// La version du format : un fichier plus récent est refusé plutôt que lu à
/// moitié.
pub const FILE_VERSION: u32 = 1;

#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
struct FileCut {
    /// La clef du poste dans la base où le projet a été écrit…
    id: i64,
    /// … et son libellé, par lequel on le retrouve dans une autre base.
    label: String,
    unit: String,
    /// Le pourcentage, ou le montant par mois écrit à la façon neutre.
    value: f64,
}

#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
struct File {
    format: String,
    version: u32,
    /// `last-12`, une année, ou `range` avec ses deux bornes.
    history: String,
    #[serde(default)]
    from: i32,
    #[serde(default)]
    to: i32,
    axis: String,
    years: u32,
    #[serde(default)]
    rate: Option<f64>,
    #[serde(default)]
    target: Option<f64>,
    /// Les comptes suivis, par leur libellé seul — jamais leur numéro.
    #[serde(default)]
    accounts: Vec<String>,
    cuts: Vec<FileCut>,
}

/// **Le projet en JSON** : les réglages, les comptes suivis, et chaque
/// réduction avec le libellé de son poste. Les montants y sont neutres.
pub fn to_file(reading: &Reading, request: &Request, accounts: &[String]) -> String {
    let (history, from, to) = match request.period {
        Period::History(history) => (history.key(), 0, 0),
        Period::Range(from, to) => ("range".to_string(), from, to),
    };
    let unit = money::UNIT as f64;
    let file = File {
        format: FILE_MARK.to_string(),
        version: FILE_VERSION,
        history,
        from,
        to,
        axis: request.axis.key().to_string(),
        years: request.years.clamp(1, YEARS_LIMIT),
        rate: (request.rate > 0.0).then_some(request.rate),
        target: request.target.map(|target| target as f64 / unit),
        accounts: accounts.to_vec(),
        cuts: request
            .cuts
            .iter()
            .filter_map(|(id, cut)| {
                let item = reading.items.iter().find(|item| item.id == *id)?;
                Some(match cut {
                    Cut::Percent(percent) => FileCut {
                        id: *id,
                        label: item.label.clone(),
                        unit: "percent".to_string(),
                        value: *percent,
                    },
                    Cut::Amount(amount) => FileCut {
                        id: *id,
                        label: item.label.clone(),
                        unit: "amount".to_string(),
                        value: *amount as f64 / unit,
                    },
                })
            })
            .collect(),
    };
    serde_json::to_string_pretty(&file).unwrap_or_default()
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
            FileRefusal::NotAProject => "cut-file-not-project",
            FileRefusal::TooRecent => "cut-file-too-recent",
        }
    }
}

/// Une réduction rouverte, telle que la fenêtre la montre.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct OpenedCut {
    pub id: i64,
    pub value: String,
    pub unit: String,
}

/// **Un projet rouvert**, dans la langue en cours.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Opened {
    pub history: String,
    pub from: i32,
    pub to: i32,
    pub axis: String,
    pub years: u32,
    pub rate: String,
    pub target: String,
    pub accounts: Vec<String>,
    pub cuts: Vec<OpenedCut>,
}

/// **Rouvre un projet.** Chaque réduction retrouve son poste dans la base
/// ouverte : par sa clef si le libellé y est le même, sinon par son libellé ;
/// la ligne des opérations sans classement garde sa clef. Une réduction dont
/// le poste n'existe plus est laissée de côté.
pub fn from_file(conn: &Connection, text: &str, language: Language) -> std::result::Result<Result<Opened>, FileRefusal> {
    let file: File = serde_json::from_str(text).map_err(|_| FileRefusal::NotAProject)?;
    if file.format != FILE_MARK {
        return Err(FileRefusal::NotAProject);
    }
    if file.version > FILE_VERSION {
        return Err(FileRefusal::TooRecent);
    }
    let axis = axis_from_key(&file.axis);
    let elements = match axis.elements(conn) {
        Ok(elements) => elements,
        Err(error) => return Ok(Err(error)),
    };
    let find = |cut: &FileCut| -> Option<i64> {
        if cut.id == UNCLASSIFIED {
            return Some(UNCLASSIFIED);
        }
        if elements.iter().any(|element| element.id == cut.id && element.label == cut.label) {
            return Some(cut.id);
        }
        elements.iter().find(|element| element.label == cut.label).map(|element| element.id)
    };
    let decimal = |value: f64| {
        crate::appliance::decimal(value, if value.fract() == 0.0 { 0 } else { 2 }, language)
    };
    let money_field = |value: f64| money::format_plain((value * money::UNIT as f64).round() as i64, language);
    let cuts = file
        .cuts
        .iter()
        .filter_map(|cut| {
            let id = find(cut)?;
            let percent = cut.unit == "percent";
            Some(OpenedCut {
                id,
                value: if percent { decimal(cut.value) } else { money_field(cut.value) },
                unit: if percent { "percent" } else { "amount" }.to_string(),
            })
        })
        .collect();
    Ok(Ok(Opened {
        history: file.history,
        from: file.from,
        to: file.to,
        axis: axis.key().to_string(),
        years: file.years.clamp(1, YEARS_LIMIT),
        rate: file.rate.map(decimal).unwrap_or_default(),
        target: file.target.map(money_field).unwrap_or_default(),
        accounts: file.accounts,
        cuts,
    }))
}

/// **Le classeur** : « Postes », une ligne par poste avec sa réduction, et
/// « Résultat », les réglages et les chiffres. Des valeurs, pas des formules.
pub fn book(
    reading: &Reading,
    request: &Request,
    outcome: &Outcome,
    today: NaiveDate,
    accounts: &[String],
    language: Language,
) -> Vec<Sheet> {
    let written = write(reading, request, outcome, today, language);
    let label = |key: &str| i18n::text(language, key);
    let cuts: HashMap<i64, Cut> = request.cuts.iter().copied().collect();
    let mut items = Sheet::new(label("cut-sheet-items"));
    items.header_rows = 1;
    items.widths = vec![34.0, 14.0, 14.0, 14.0, 14.0];
    items.rows.push(
        [
            format!("cut-axis-{}", request.axis.key()),
            "cut-column-monthly".to_string(),
            "cut-column-cut".to_string(),
            "cut-column-after".to_string(),
            "cut-column-yearly".to_string(),
        ]
        .iter()
        .map(|key| SheetCell::text(label(key)).with_bold(true))
        .collect(),
    );
    let reduced_fill = Some("FBF4E4".to_string());
    for (item, row) in reading.items.iter().zip(&written.rows) {
        let saved = cuts.get(&item.id).map_or(0, |cut| saving(item, *cut).0);
        let fill = if saved > 0 { reduced_fill.clone() } else { None };
        items.rows.push(vec![
            SheetCell::text(item.label.clone()).with_fill(fill.clone()).with_bold(saved > 0),
            SheetCell::money(item.monthly).with_fill(fill.clone()),
            SheetCell::text(row.cut.clone()).with_fill(fill.clone()),
            SheetCell::money(item.monthly - saved).with_fill(fill.clone()),
            if saved > 0 { SheetCell::money(saved * 12) } else { SheetCell::empty() }.with_fill(fill),
        ]);
    }
    items.rows.push(vec![
        SheetCell::text(label("cut-total")).with_bold(true),
        SheetCell::money(outcome.before).with_bold(true),
        // La réduction se lit en moins, comme sur chaque ligne.
        SheetCell::money(-outcome.monthly).with_bold(true),
        SheetCell::money(outcome.after).with_bold(true),
        SheetCell::money(outcome.monthly * 12).with_bold(true),
    ]);

    let mut result = Sheet::new(label("holiday-sheet-result"));
    result.widths = vec![34.0, 60.0];
    let mut pairs = vec![
        (label("cut-report-accounts"), accounts.join(", ")),
        (label("goal-period-label"), written.period.clone()),
        (label("cut-axis-label"), label(&format!("cut-axis-{}", request.axis.key()))),
        (label("cut-horizon-label"), written.years.clone()),
    ];
    if request.rate > 0.0 {
        pairs.push((
            label("goal-field-rate"),
            format!("{} %", crate::appliance::decimal(request.rate, 2, language)),
        ));
    }
    if let Some(target) = request.target {
        pairs.push((label("goal-field-target"), money::format(target, language)));
    }
    pairs.push((label("cut-report-result"), written.headline.clone()));
    if let Some(target) = &written.target {
        pairs.push((String::new(), target.clone()));
    }
    pairs.extend(written.tiles.iter().map(|tile| (tile.label.clone(), tile.value.clone())));
    for (name, value) in pairs {
        result.rows.push(vec![SheetCell::text(name).with_bold(true), SheetCell::text(value)]);
    }
    vec![items, result]
}

const TEMPLATE: &str = r##"
#let nuit = rgb("#24506e")
#let encre = rgb("#1d2b34")
#let gris = rgb("#6b7a88")
#let filet = rgb("#e3e8ed")
#let fond = rgb("#f4f6f8")
#let dore = rgb("#c39a3c")
#let vert = rgb("#2e9a6a")
#let clair = rgb("#fbf4e4")

#set text(font: famille, size: 9pt, fill: encre, lang: langue)
#set par(leading: 0.55em, spacing: 0.9em)
#set page(
  paper: "a4",
  margin: (left: 42pt, right: 42pt, top: 42pt, bottom: 58pt),
  footer: context {
    set text(size: 7.5pt, fill: gris)
    line(length: 100%, stroke: 0.5pt + filet)
    v(4pt)
    grid(columns: (1fr, auto), avertissement,
      [#counter(page).display() / #counter(page).final().first()])
  },
)

#let svg(source, largeur) = image(bytes(source), format: "svg", width: largeur)

#let titre-section(texte) = {
  v(14pt)
  block(below: 8pt, {
    text(size: 13pt, weight: "bold", fill: nuit, texte)
    v(-6pt)
    line(length: 36pt, stroke: 2pt + dore)
  })
}

#let tuile(intitule, valeur) = block(
  width: 100%, fill: fond, radius: 6pt, inset: (x: 10pt, y: 10pt),
  {
    text(size: 7.5pt, fill: gris, upper(intitule))
    v(2pt)
    text(size: 13pt, weight: "bold", fill: nuit, valeur)
  },
)

#let carte(titre, corps) = block(
  width: 100%, stroke: 0.6pt + filet, radius: 6pt, inset: 12pt, breakable: false,
  { text(size: 10pt, weight: "bold", fill: nuit, titre); v(6pt); corps },
)

#block(width: 100%, fill: nuit, radius: 8pt, inset: (x: 16pt, y: 14pt), grid(
  columns: (auto, 1fr), column-gutter: 14pt, align: horizon,
  box(fill: white, radius: 6pt, inset: 4pt, image(logo, height: 46pt)),
  {
    text(size: 22pt, weight: "bold", fill: white, titre)
    v(-4pt)
    text(size: 10pt, fill: rgb("#d5e2ec"), sous-titre)
  },
))

#titre-section(titre-reglages)
#table(columns: (auto, 1fr), stroke: none, inset: (x: 0pt, y: 3.5pt), column-gutter: 14pt,
  ..reglages.map(c => (text(fill: gris, c.at(0)), text(weight: "bold", c.at(1)))).flatten())

#titre-section(titre-resultat)
#block(width: 100%, fill: fond, radius: (right: 6pt), stroke: (left: 5pt + vert), inset: (x: 14pt, y: 10pt),
  text(size: 12pt, weight: "bold", fill: nuit, phrase))
#if objectif != "" { v(4pt); text(size: 9.5pt, objectif) }
#v(6pt)
#grid(columns: (1fr,) * calc.min(tuiles.len(), 3), column-gutter: 8pt, row-gutter: 8pt,
  ..tuiles.map(t => tuile(t.at(0), t.at(1))))
#v(10pt)
#carte(titre-courbe, svg(courbe-svg, 100%))
#v(10pt)
#carte(titre-anneau, align(center, svg(anneau-svg, 330pt)))
#v(6pt)
#block({
  set text(size: 8pt, fill: gris)
  for note in notes { [• #note]; linebreak() }
})

#pagebreak()
#titre-section(titre-tableau)
#set text(size: 8.5pt)
#table(
  columns: (1fr, auto, auto, auto, auto),
  stroke: none,
  inset: (x: 6pt, y: 4pt),
  align: (x, y) => if x == 0 { left } else { right },
  fill: (x, y) => if y == 0 { nuit } else if lignes.at(y - 1).at(6) { fond } else if lignes.at(y - 1).at(5) { clair } else { white },
  table.header(repeat: true, ..colonnes.map(c => text(fill: white, weight: "bold", c))),
  ..lignes.map(l => {
    let poids = if l.at(6) or l.at(5) { "bold" } else { "regular" }
    (text(weight: poids, l.at(0)), l.at(1), text(fill: vert, weight: poids, l.at(2)), text(weight: poids, l.at(3)), text(fill: vert, weight: poids, l.at(4)))
  }).flatten(),
)
"##;

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database::{schema, seed};
    use crate::loan::History;

    const EURO: i64 = money::UNIT;

    fn date(year: i32, month: u32, day: u32) -> NaiveDate {
        NaiveDate::from_ymd_opt(year, month, day).unwrap()
    }

    fn today() -> NaiveDate {
        date(2026, 10, 10)
    }

    /// Un compte courant à 2 000 €, deux catégories ; chaque mois de 2025,
    /// 2 500 € de salaire, 300 € de restaurants (600 € en juillet), 1 800 €
    /// de courses, et une opération ventilée en 2 × 100 €.
    fn database() -> Connection {
        let conn = Connection::open_in_memory().expect("base en mémoire");
        schema::migrate(&conn).expect("schéma");
        seed::seed_initial_data(&conn).expect("valeurs initiales");
        conn.execute(
            "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte, IDBanques, SoldeBanque, SoldeReel, SoldeFinal, CompteCloture)
             VALUES (1, 'CCP', 1, 1, 2000000000, 2000000000, 2000000000, 0)",
            [],
        )
        .unwrap();
        for (id, name) in [(901, "Restaurants"), (902, "Courses")] {
            conn.execute(
                "INSERT INTO Categorie (IDCategorie, Libelle, IDPosteBudget) VALUES (?1, ?2, 0)",
                rusqlite::params![id, name],
            )
            .unwrap();
        }
        let mut id = 0;
        let mut add = |day: String, amount: i64, category: i64, parent: i64| {
            id += 1;
            conn.execute(
                "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte, IDStatutOperation,
                                        IDOperationParent, IDCategorie)
                 VALUES (?1, 'OP', ?2, ?3, 1, 1, ?4, ?5)",
                rusqlite::params![id, day, amount, parent, category],
            )
            .unwrap();
            id
        };
        for month in 1..=12 {
            let day = |d: u32| format!("2025-{month:02}-{d:02}");
            add(day(1), 2_500 * EURO, 0, 0);
            add(day(5), if month == 7 { -600 } else { -300 } * EURO, 901, 0);
            add(day(8), -1_600 * EURO, 902, 0);
            let mother = add(day(12), -200 * EURO, 0, 0);
            add(day(12), -100 * EURO, 902, mother);
            add(day(12), -100 * EURO, 901, mother);
        }
        conn
    }

    fn request(cuts: Vec<(i64, Cut)>) -> Request {
        Request {
            accounts: vec![1],
            period: Period::History(History::Year(2025)),
            axis: Axis::Category,
            cuts,
            years: 1,
            rate: 0.0,
            target: None,
        }
    }

    #[test]
    fn les_postes_se_lisent_avec_leurs_saisons() {
        let conn = database();
        let reading = read(&conn, &request(vec![]), today(), "Sans catégorie").unwrap().unwrap();
        assert_eq!(reading.items.len(), 2);
        assert_eq!(reading.items[0].label, "Courses");
        assert_eq!(reading.items[0].monthly, 1_700 * EURO);
        assert_eq!(reading.items[1].monthly, 425 * EURO);
        assert_eq!(reading.items[1].profile[6], 700 * EURO);
        assert_eq!(reading.items[1].profile[0], 400 * EURO);
    }

    #[test]
    fn une_reduction_ne_depasse_jamais_la_depense() {
        let item = Item { id: 1, label: "X".into(), monthly: 50 * EURO, profile: [50 * EURO; 12] };
        assert_eq!(saving(&item, Cut::Amount(80 * EURO)), (50 * EURO, true));
        assert_eq!(saving(&item, Cut::Amount(20 * EURO)), (20 * EURO, false));
        assert_eq!(saving(&item, Cut::Percent(10.0)), (5 * EURO, false));
        assert_eq!(saving(&item, Cut::Percent(150.0)), (50 * EURO, false));
    }

    /// **La réduction suit les saisons de son poste** : −50 % sur les
    /// restaurants rapporte 200 € les mois ordinaires et 350 € en juillet.
    #[test]
    fn la_reduction_suit_les_saisons() {
        let conn = database();
        let asked = request(vec![(901, Cut::Percent(50.0))]);
        let reading = read(&conn, &asked, today(), "-").unwrap().unwrap();
        let outcome = outcome(&reading, &asked, today());
        assert_eq!(outcome.monthly, 212_500_000);
        assert_eq!(outcome.count, 1);
        assert_eq!(outcome.before, 2_125 * EURO);
        // Novembre : 200 € de plus que sans réduction.
        assert_eq!(outcome.with[0].1 - outcome.without[0].1, 200 * EURO);
        // Sur un an, juillet compris : 11 × 200 + 350.
        let (gain, interest) = outcome.gain();
        assert_eq!(gain, 2_550 * EURO);
        assert_eq!(interest, 0);
    }

    #[test]
    fn le_montant_vise_arrive_plus_tot() {
        let conn = database();
        let asked = Request { target: Some(6_000 * EURO), ..request(vec![(902, Cut::Amount(200 * EURO))]) };
        let reading = read(&conn, &asked, today(), "-").unwrap().unwrap();
        let outcome = outcome(&reading, &asked, today());
        let Some((Some(without), Some(with))) = outcome.reached else {
            panic!("atteint des deux côtés");
        };
        assert!(with < without, "{with} {without}");
        let written = write(&reading, &asked, &outcome, today(), Language::French);
        assert!(written.target.unwrap().contains("plus tôt"));
        assert!(written.rows.iter().any(|row| row.reduced && row.cut.contains('€')));
        assert!(written.donut.contains("<svg"));
        assert!(written.chart.contains("<svg"));
        assert!(!written.headline.contains('{'));
    }

    #[test]
    fn sans_reduction_la_phrase_invite_a_en_taper_une() {
        let conn = database();
        let asked = request(vec![]);
        let reading = read(&conn, &asked, today(), "-").unwrap().unwrap();
        let outcome = outcome(&reading, &asked, today());
        let written = write(&reading, &asked, &outcome, today(), Language::French);
        assert_eq!(written.tone, "none");
        assert_eq!(outcome.gain(), (0, 0));
    }

    #[test]
    fn les_tiers_et_les_postes_budgetaires_se_lisent_aussi() {
        let conn = database();
        for axis in [Axis::Payee, Axis::BudgetLine] {
            let asked = Request { axis, ..request(vec![]) };
            let reading = read(&conn, &asked, today(), "Sans").unwrap().unwrap();
            // Rien n'est classé sur ces axes : une seule ligne, « Sans ».
            assert_eq!(reading.items.len(), 1);
            assert_eq!(reading.items[0].label, "Sans");
            assert_eq!(reading.items[0].monthly, 2_125 * EURO);
        }
        assert_eq!(axis_from_key("payee"), Axis::Payee);
        assert_eq!(axis_from_key("budget-line"), Axis::BudgetLine);
        assert_eq!(axis_from_key("project"), Axis::Category);
    }

    /// **Le rapport se compose**, tableau, réglages et dessins compris.
    #[test]
    fn le_rapport_se_compose() {
        let conn = database();
        let asked = Request {
            rate: 2.0,
            target: Some(9_000 * EURO),
            years: 3,
            ..request(vec![(901, Cut::Percent(30.0)), (902, Cut::Amount(5_000 * EURO))])
        };
        let reading = read(&conn, &asked, today(), "-").unwrap().unwrap();
        let outcome = outcome(&reading, &asked, today());
        let bytes = pdf(&conn, &reading, &asked, &outcome, today(), Language::French).expect("le rapport");
        assert!(bytes.starts_with(b"%PDF"));
    }

    /// **Le projet en fichier** : enregistré, rouvert dans une autre langue,
    /// il retrouve ses postes par leur libellé.
    #[test]
    fn le_projet_se_relit_et_retrouve_ses_postes() {
        let conn = database();
        let asked = Request {
            period: Period::Range(2024, 2025),
            years: 4,
            rate: 1.5,
            target: Some(6_000 * EURO),
            ..request(vec![(901, Cut::Percent(30.0)), (902, Cut::Amount(150 * EURO))])
        };
        let reading = read(&conn, &asked, today(), "-").unwrap().unwrap();
        let text = to_file(&reading, &asked, &["CCP".to_string()]);
        assert!(text.contains("\"label\": \"Restaurants\""), "{text}");
        let opened = from_file(&conn, &text, Language::English).unwrap().unwrap();
        assert_eq!(opened.history, "range");
        assert_eq!((opened.from, opened.to, opened.years), (2024, 2025, 4));
        assert_eq!(opened.rate, "1.50");
        assert_eq!(opened.target, "6000.00");
        assert_eq!(opened.accounts, vec!["CCP".to_string()]);
        assert!(opened.cuts.contains(&OpenedCut { id: 901, value: "30".into(), unit: "percent".into() }));
        assert!(opened.cuts.contains(&OpenedCut { id: 902, value: "150.00".into(), unit: "amount".into() }));
        // Dans une base où « Courses » a une autre clef, on la retrouve par
        // son libellé ; un poste disparu est laissé de côté.
        conn.execute("UPDATE Categorie SET IDCategorie = 950 WHERE IDCategorie = 902", []).unwrap();
        conn.execute("DELETE FROM Categorie WHERE Libelle = 'Restaurants'", []).unwrap();
        let moved = from_file(&conn, &text, Language::French).unwrap().unwrap();
        assert_eq!(moved.cuts, vec![OpenedCut { id: 950, value: "150,00".into(), unit: "amount".into() }]);
        assert_eq!(from_file(&conn, "{}", Language::French), Err(FileRefusal::NotAProject));
        let newer = text.replace("\"version\": 1", "\"version\": 7");
        assert_eq!(from_file(&conn, &newer, Language::French), Err(FileRefusal::TooRecent));
    }

    #[test]
    fn le_classeur_porte_les_postes_et_le_resultat() {
        let conn = database();
        let asked = request(vec![(901, Cut::Percent(50.0))]);
        let reading = read(&conn, &asked, today(), "-").unwrap().unwrap();
        let outcome = outcome(&reading, &asked, today());
        let sheets = book(&reading, &asked, &outcome, today(), &["CCP".to_string()], Language::French);
        assert_eq!(sheets.len(), 2);
        // L'en-tête, les deux postes, le total.
        assert_eq!(sheets[0].rows.len(), 4);
        assert!(sheets[1].rows.len() >= 6);
        let path = std::env::temp_dir().join("radinus-reduction-essai.xlsx");
        crate::sheets::write_book(&sheets, &path).expect("le classeur s'écrit");
        let _ = std::fs::remove_file(path);
    }
}
