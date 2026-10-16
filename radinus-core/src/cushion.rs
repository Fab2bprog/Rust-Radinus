//! Mon matelas de sécurité — F43 (Fabrice, 09/10/2026).
//!
//! **« Si mes revenus s'arrêtaient demain, combien de mois tiendrais-je avec
//! mon épargne ? »** Tout vient de la base : l'épargne, ce sont les soldes
//! réels des comptes cochés « Épargne » ; les dépenses, la moyenne par mois
//! de ce qui est sorti des comptes cochés « Dépenses » sur la période choisie
//! — les douze derniers mois complets, ou une année entière de N à N-5, comme
//! la simulation de crédit.
//!
//! # La méthode
//!
//! - **Les virements entre ses propres comptes ne sont pas des dépenses.** Ils
//!   sont reconnus par paires, comme dans la simulation de crédit, mais sur
//!   **tous** les comptes de la base : mettre 200 € sur un livret qu'on n'a
//!   pas coché n'est pas dépenser 200 €.
//! - **Les catégories qu'on couperait en cas de coup dur** peuvent être
//!   décochées (Fabrice, 09/10/2026 : « possibilité de décocher ») : les
//!   loisirs, les vacances. Une opération ventilée compte par ses filles,
//!   chacune dans sa catégorie — la règle des statistiques.
//! - **Un revenu de secours** (Fabrice : « oui ») — le chômage, le salaire du
//!   conjoint — se retranche des dépenses : l'épargne fond de la différence.
//! - Le nombre de mois = l'épargne ÷ ce qu'elle perd par mois. Rouge sous
//!   trois mois, orange de trois à six, vert au-delà : la règle de prudence
//!   habituelle, **fixe** (Fabrice : « ok »).
//! - **Le rythme d'épargne** est ce que les comptes d'épargne ont gagné en
//!   moyenne par mois sur la période, virements reçus compris : c'est lui qui
//!   dit quand les trois et les six mois seraient atteints.
//!
//! Seuls les mois complets comptent, et seules les opérations pointées ou
//! engagées. Rien n'est enregistré, et il n'y a pas de rapport PDF (« pas de
//! rapport PDF »).

use crate::appliance::decimal;
use crate::domain::NaiveDate;
use crate::i18n::{self, Language};
use crate::loan::{first_of, last_of, pair_transfers, Line, Period, TRANSFER_DAYS};
use crate::loan_charts::{self, on_circle, ring_slice, svg_open, text, Point};
use crate::money;
use crate::nomenclatures::{self, Nomenclature};
use rusqlite::{Connection, Result};
use std::collections::{BTreeMap, HashSet};
use time_compute::{Datelike, Days, Months};

/// La catégorie des opérations qui n'en ont pas — ou dont la catégorie a
/// disparu depuis.
pub const UNCLASSIFIED: i64 = nomenclatures::UNSPECIFIED;

/// Les deux seuils de la jauge, en mois de dépenses.
pub const SHORT: u32 = 3;
pub const SOLID: u32 = 6;
/// Où la jauge s'arrête : un an. Au-delà, l'aiguille reste en butée.
pub const GAUGE_TOP: f64 = 12.0;

/// Ce que la personne a coché et tapé.
#[derive(Debug, Clone, PartialEq)]
pub struct Request {
    /// Les comptes dont le solde compte comme épargne.
    pub savings: Vec<i64>,
    /// Les comptes d'où partent les dépenses du quotidien.
    pub spending: Vec<i64>,
    pub history: Period,
    /// Les catégories décochées.
    pub excluded: Vec<i64>,
    /// Le revenu qui continuerait par mois, en micro-unités.
    pub backup: i64,
}

/// Une catégorie et ce qu'elle a coûté en moyenne par mois.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct CategorySpending {
    pub id: i64,
    pub label: String,
    pub monthly: i64,
}

/// **Le résultat.**
#[derive(Debug, Clone, PartialEq)]
pub struct Cushion {
    /// Les mois de la période — des mois entiers.
    pub months: Vec<NaiveDate>,
    /// L'épargne d'aujourd'hui.
    pub savings: i64,
    /// Les dépenses moyennes par mois, toutes catégories.
    pub spending_all: i64,
    /// Les dépenses moyennes par mois, sans les catégories décochées.
    pub spending: i64,
    pub backup: i64,
    /// Ce que l'épargne perdrait par mois : les dépenses retenues moins le
    /// revenu de secours.
    pub burn: i64,
    /// Le nombre de mois couverts ; `None` quand l'épargne ne fond pas.
    pub cover: Option<f64>,
    /// Ce que les comptes d'épargne ont gagné en moyenne par mois.
    pub rhythm: i64,
    /// Les catégories qui ont porté une dépense, la plus lourde d'abord.
    pub categories: Vec<CategorySpending>,
    /// Les virements reconnus et mis de côté.
    pub transfers: usize,
}

/// Pourquoi il n'y a rien à montrer.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Unavailable {
    NoSpendingAccount,
    NoMonth,
}

impl Unavailable {
    pub fn key(self) -> &'static str {
        match self {
            Unavailable::NoSpendingAccount => "cushion-no-spending-account",
            Unavailable::NoMonth => "cushion-no-month",
        }
    }
}

/// La couleur du résultat.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Zone {
    Short,
    Fair,
    Solid,
}

impl Zone {
    pub fn of(cover: Option<f64>) -> Zone {
        match cover {
            Some(months) if months < f64::from(SHORT) => Zone::Short,
            Some(months) if months < f64::from(SOLID) => Zone::Fair,
            _ => Zone::Solid,
        }
    }

    pub fn tone(self) -> &'static str {
        match self {
            Zone::Short => "bad",
            Zone::Fair => "warn",
            Zone::Solid => "good",
        }
    }
}

/// **Les cases cochées d'office**, d'après le type du compte : (épargne,
/// dépenses). Un compte chèque porte les dépenses ; un livret ou un compte
/// épargne logement, l'épargne qu'on peut retirer tout de suite. Un PEL, un
/// PERP ou un compte à terme ne se retirent pas sans le casser ou sans
/// pénalité : ils restent décochés, comme « Autres », dont on ne sait rien.
/// La personne coche ce qu'elle veut ; rien n'est mémorisé.
pub fn suggested(account_type: i64) -> (bool, bool) {
    match account_type {
        1 => (false, true),
        2..=7 => (true, false),
        _ => (false, false),
    }
}

/// Les mois couverts par une épargne qui perd `burn` par mois.
pub fn cover(savings: i64, burn: i64) -> Option<f64> {
    (burn > 0).then(|| savings.max(0) as f64 / burn as f64)
}

fn day_of(text: Option<String>) -> Option<NaiveDate> {
    text.and_then(|day| NaiveDate::parse_from_str(&day, "%Y-%m-%d").ok())
}

fn dates(from: NaiveDate, to: NaiveDate) -> [rusqlite::types::Value; 2] {
    [
        rusqlite::types::Value::Text(from.format("%Y-%m-%d").to_string()),
        rusqlite::types::Value::Text(to.format("%Y-%m-%d").to_string()),
    ]
}

/// **Le calcul.** `unclassified_label` nomme la ligne des opérations sans
/// catégorie, dans la langue de l'appelant.
pub fn analyse(
    conn: &Connection,
    request: &Request,
    today: NaiveDate,
    unclassified_label: &str,
) -> Result<std::result::Result<Cushion, Unavailable>> {
    if request.spending.is_empty() {
        return Ok(Err(Unavailable::NoSpendingAccount));
    }
    let period = request.history.months(today);
    let (Some(&first), Some(&last)) = (period.first(), period.last()) else {
        return Ok(Err(Unavailable::NoMonth));
    };
    let (from, to) = (first, last_of(last));
    let margin = Days::new(TRANSFER_DAYS as u64);
    let wide_from = from.checked_sub_days(margin).unwrap_or(from);
    let wide_to = to.checked_add_days(margin).unwrap_or(to);

    // Les virements, reconnus sur **tous** les comptes de la base.
    let mut statement = conn.prepare(
        "SELECT IDOperation, IDCompte, Montant, COALESCE(Date, DatePointage)
         FROM Operation
         WHERE IDOperationParent = 0 AND IDStatutOperation IN (1, 2)
           AND COALESCE(Date, DatePointage) BETWEEN ?1 AND ?2",
    )?;
    let lines: Vec<Line> = statement
        .query_map(rusqlite::params_from_iter(dates(wide_from, wide_to)), |row| {
            Ok((row.get::<_, i64>(0)?, row.get::<_, i64>(1)?, row.get::<_, i64>(2)?, row.get(3)?))
        })?
        .filter_map(|row| match row {
            Ok((id, account, amount, day)) => {
                day_of(day).map(|day| Ok(Line { id, account, amount, day }))
            }
            Err(error) => Some(Err(error)),
        })
        .collect::<Result<_>>()?;
    let pairs = pair_transfers(&lines);
    let paired: HashSet<i64> = pairs.iter().flat_map(|&(debit, credit)| [debit, credit]).collect();
    let watched: HashSet<i64> = request.spending.iter().chain(&request.savings).copied().collect();
    let touches = |id: i64| {
        lines
            .iter()
            .find(|line| line.id == id)
            .is_some_and(|line| watched.contains(&line.account) && line.day >= from && line.day <= to)
    };
    let transfers = pairs
        .iter()
        .filter(|&&(debit, credit)| touches(debit) || touches(credit))
        .count();

    // Les dépenses : les feuilles — une mère ventilée compte par ses filles —
    // débitrices, des comptes de dépenses, hors virements.
    let marks = request.spending.iter().map(|_| "?").collect::<Vec<_>>().join(",");
    let sql = format!(
        "SELECT o.IDOperation, o.IDOperationParent, o.Montant,
                COALESCE(o.Date, o.DatePointage),
                CASE WHEN o.IDCategorie IN (SELECT IDCategorie FROM Categorie)
                     THEN o.IDCategorie ELSE {UNCLASSIFIED} END
         FROM Operation o
         WHERE o.IDCompte IN ({marks}) AND o.IDStatutOperation IN (1, 2)
           AND o.Montant < 0
           AND (o.IDOperationParent <> 0
                OR NOT EXISTS (SELECT 1 FROM Operation f
                               WHERE f.IDOperationParent = o.IDOperation))"
    );
    let mut statement = conn.prepare(&sql)?;
    let mut by_category: BTreeMap<i64, i64> = BTreeMap::new();
    let mut rows = statement.query(rusqlite::params_from_iter(request.spending.iter()))?;
    while let Some(row) = rows.next()? {
        let (id, parent, amount): (i64, i64, i64) = (row.get(0)?, row.get(1)?, row.get(2)?);
        let Some(day) = day_of(row.get(3)?) else {
            continue;
        };
        if day < from || day > to || paired.contains(&id) || paired.contains(&parent) {
            continue;
        }
        *by_category.entry(row.get(4)?).or_default() -= amount;
    }

    let count = period.len() as i64;
    let labels: BTreeMap<i64, String> = nomenclatures::list(conn, Nomenclature::Category)?
        .into_iter()
        .map(|item| (item.id, item.label))
        .collect();
    let mut categories: Vec<CategorySpending> = by_category
        .iter()
        .map(|(&id, &total)| CategorySpending {
            id,
            label: labels.get(&id).cloned().unwrap_or_else(|| unclassified_label.to_string()),
            monthly: total / count,
        })
        .collect();
    categories.sort_by(|a, b| b.monthly.cmp(&a.monthly).then_with(|| a.label.cmp(&b.label)));
    let total_all: i64 = by_category.values().sum();
    let total_kept: i64 = by_category
        .iter()
        .filter(|(id, _)| !request.excluded.contains(id))
        .map(|(_, total)| total)
        .sum();

    // L'épargne d'aujourd'hui, et ce qu'elle a gagné sur la période.
    let savings: i64 = crate::accounts::list(conn)?
        .iter()
        .filter(|row| request.savings.contains(&row.id))
        .map(|row| row.balance_real)
        .sum();
    let rhythm = if request.savings.is_empty() {
        0
    } else {
        let marks = request.savings.iter().map(|_| "?").collect::<Vec<_>>().join(",");
        let sql = format!(
            "SELECT COALESCE(SUM(Montant), 0) FROM Operation
             WHERE IDOperationParent = 0 AND IDStatutOperation IN (1, 2)
               AND IDCompte IN ({marks})
               AND COALESCE(Date, DatePointage) BETWEEN ? AND ?"
        );
        let mut parameters: Vec<rusqlite::types::Value> = request
            .savings
            .iter()
            .map(|id| rusqlite::types::Value::Integer(*id))
            .collect();
        parameters.extend(dates(from, to));
        let gained: i64 = conn.query_row(&sql, rusqlite::params_from_iter(parameters), |row| row.get(0))?;
        gained / count
    };

    let spending = total_kept / count;
    let burn = spending - request.backup;
    Ok(Ok(Cushion {
        months: period,
        savings,
        spending_all: total_all / count,
        spending,
        backup: request.backup,
        burn,
        cover: cover(savings, burn),
        rhythm,
        categories,
        transfers,
    }))
}

/// Le mois où un seuil de `months` mois serait atteint au rythme d'épargne,
/// ou `None` s'il ne l'est jamais. Atteint déjà : le mois en cours.
pub fn reached(cushion: &Cushion, months: u32, today: NaiveDate) -> Option<NaiveDate> {
    let missing = i64::from(months) * cushion.burn - cushion.savings;
    if missing <= 0 {
        return Some(first_of(today));
    }
    if cushion.rhythm <= 0 {
        return None;
    }
    let needed = (missing + cushion.rhythm - 1) / cushion.rhythm;
    let needed = u32::try_from(needed).ok()?;
    first_of(today).checked_add_months(Months::new(needed))
}

/// **L'épargne qui fond**, mois après mois depuis aujourd'hui, jusqu'à deux
/// mois après qu'elle est à sec — six mois au moins, trois ans au plus. **Elle
/// s'arrête à zéro** : une épargne ne descend pas sous rien, ce qui suivrait
/// serait une dette, et la courbe dirait autre chose que ce qu'on lui demande.
pub fn projection(cushion: &Cushion, today: NaiveDate) -> Vec<(NaiveDate, i64)> {
    let length = match cushion.cover {
        Some(months) => (months.ceil() as usize + 2).clamp(6, 36),
        None => 12,
    };
    (0..=length)
        .filter_map(|rank| {
            let month = first_of(today).checked_add_months(Months::new(rank as u32))?;
            let left = cushion.savings - rank as i64 * cushion.burn;
            Some((month, if cushion.burn > 0 { left.max(0) } else { left }))
        })
        .collect()
}

// --- La jauge ---------------------------------------------------------------------

/// L'angle de l'aiguille, en degrés : 0 pour 0 mois, 180 pour la butée.
pub fn gauge_angle(cover: Option<f64>) -> f64 {
    cover.map_or(180.0, |months| (months / GAUGE_TOP).clamp(0.0, 1.0) * 180.0)
}

/// **La jauge en demi-cercle**, de zéro à douze mois : rouge jusqu'à trois,
/// orange jusqu'à six, vert au-delà. L'aiguille porte son angle en
/// `data-angle`, comme celle de la simulation de crédit.
pub fn gauge(cover: Option<f64>, figure: &str, caption: &str) -> String {
    let (cx, cy, outer, inner) = (160.0, 150.0, 128.0, 100.0);
    let mut out = svg_open(320.0, 226.0, "loan-chart--gauge");
    let degrees = |months: f64| -90.0 + months / GAUGE_TOP * 180.0;
    for (from, to, colour) in [
        (0.0, f64::from(SHORT), loan_charts::RED),
        (f64::from(SHORT), f64::from(SOLID), loan_charts::ORANGE),
        (f64::from(SOLID), GAUGE_TOP, loan_charts::GREEN),
    ] {
        out.push_str(&format!(
            "<path d=\"{}\" fill=\"{colour}\" fill-opacity=\"0.88\"/>",
            ring_slice(cx, cy, outer, inner, degrees(from), degrees(to))
        ));
    }
    for months in [0, SHORT, SOLID, GAUGE_TOP as u32] {
        let at = f64::from(months);
        let (x, y) = on_circle(cx, cy, outer + 12.0, degrees(at));
        let anchor = match months {
            0 => "end",
            m if f64::from(m) == GAUGE_TOP => "start",
            _ => "middle",
        };
        out.push_str(&text(x, y + 4.0, 11.0, loan_charts::MUTED, anchor, "normal", &months.to_string()));
    }
    let angle = gauge_angle(cover);
    out.push_str(&format!(
        "<g class=\"gauge-needle\" data-angle=\"{angle:.2}\" \
         transform=\"rotate({angle:.2} {cx} {cy})\">\
         <path d=\"M {} {cy} L {cx} {} L {} {cy} L {cx} {} Z\" fill=\"{}\"/>\
         </g>",
        cx - outer + 8.0,
        cy - 6.0,
        cx + 10.0,
        cy + 6.0,
        loan_charts::INK,
    ));
    out.push_str(&format!(
        "<circle cx=\"{cx}\" cy=\"{cy}\" r=\"9\" fill=\"{ink}\"/>\
         <circle cx=\"{cx}\" cy=\"{cy}\" r=\"3.5\" fill=\"#ffffff\"/>",
        ink = loan_charts::INK
    ));
    out.push_str(&text(cx, cy + 46.0, 30.0, loan_charts::INK, "middle", "bold", figure));
    out.push_str(&text(cx, cy + 66.0, 12.0, loan_charts::MUTED, "middle", "normal", caption));
    out.push_str("</svg>");
    out
}

// --- Ce que la fenêtre montre ---------------------------------------------------

/// Une tuile.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Tile {
    pub label: String,
    pub value: String,
}

/// Un seuil : trois mois, six mois.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Target {
    pub title: String,
    pub status: String,
    pub reached: bool,
}

/// Une catégorie à cocher.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct WrittenCategory {
    pub id: i64,
    pub label: String,
    pub monthly: String,
    pub kept: bool,
}

/// **Tout ce que la fenêtre affiche, déjà écrit.**
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Written {
    pub verdict: String,
    /// `good`, `warn` ou `bad`.
    pub tone: String,
    pub gauge: String,
    pub tiles: Vec<Tile>,
    pub targets: Vec<Target>,
    pub projection: String,
    pub categories: Vec<WrittenCategory>,
    pub period: String,
}

fn months_figure(cover: f64, language: Language) -> String {
    let decimals = if cover >= 100.0 { 0 } else { 1 };
    i18n::message_of(language, "cushion-months", &[("value", &decimal(cover, decimals, language))], &[])
}

fn per_month(amount: i64, language: Language) -> String {
    i18n::message_of(language, "cushion-per-month", &[("amount", &money::format(amount, language))], &[])
}

/// Un montant signé : « +210,00 € », « -50,00 € ».
fn signed(amount: i64, language: Language) -> String {
    let written = money::format(amount, language);
    if amount > 0 {
        format!("+{written}")
    } else {
        written
    }
}

fn short_month(day: NaiveDate) -> String {
    format!("{:02}/{:02}", day.month(), day.year() % 100)
}

/// **Écrit le résultat.**
pub fn write(cushion: &Cushion, request: &Request, today: NaiveDate, language: Language) -> Written {
    let label = |key: &str| i18n::text(language, key);
    let zone = Zone::of(cushion.cover);
    let nothing_spent = cushion.spending == 0;

    let (figure, verdict) = match cushion.cover {
        _ if nothing_spent => ("—".to_string(), label("cushion-verdict-nothing")),
        None => (label("cushion-figure-holds"), label("cushion-verdict-holds")),
        Some(cover) => (
            months_figure(cover, language),
            label(match zone {
                Zone::Short => "cushion-verdict-short",
                Zone::Fair => "cushion-verdict-fair",
                Zone::Solid => "cushion-verdict-solid",
            }),
        ),
    };
    let gauge = gauge(cushion.cover, &figure, &label("cushion-gauge-caption"));

    let mut tiles = vec![
        Tile { label: label("cushion-tile-savings"), value: money::format(cushion.savings, language) },
        Tile {
            label: label("cushion-tile-spending"),
            value: per_month(cushion.spending, language),
        },
    ];
    if cushion.backup > 0 {
        tiles.push(Tile {
            label: label("cushion-tile-backup"),
            value: per_month(cushion.backup, language),
        });
    }
    tiles.push(Tile {
        label: label("cushion-tile-burn"),
        value: if cushion.burn > 0 {
            per_month(cushion.burn, language)
        } else {
            label("cushion-burn-none")
        },
    });
    tiles.push(Tile {
        label: label("cushion-tile-rhythm"),
        value: i18n::message_of(
            language,
            "cushion-per-month",
            &[("amount", &signed(cushion.rhythm, language))],
            &[],
        ),
    });

    let targets = if cushion.burn > 0 {
        [SHORT, SOLID]
            .into_iter()
            .map(|months| {
                let needed = i64::from(months) * cushion.burn;
                let missing = needed - cushion.savings;
                let title = i18n::message_of(
                    language,
                    "cushion-target-title",
                    &[("amount", &money::format(needed, language))],
                    &[("months", i64::from(months))],
                );
                let status = if missing <= 0 {
                    label("cushion-target-reached")
                } else {
                    let missing_text = money::format(missing, language);
                    match reached(cushion, months, today) {
                        Some(month) => i18n::message_of(
                            language,
                            "cushion-target-date",
                            &[
                                ("missing", &missing_text),
                                ("month", &i18n::month_and_year(language, month)),
                            ],
                            &[],
                        ),
                        None => i18n::message_of(
                            language,
                            "cushion-target-never",
                            &[("missing", &missing_text)],
                            &[],
                        ),
                    }
                };
                Target { title, status, reached: missing <= 0 }
            })
            .collect()
    } else {
        Vec::new()
    };

    let points: Vec<(NaiveDate, i64)> = projection(cushion, today);
    let empty_at = points.iter().position(|(_, value)| *value <= 0).filter(|&rank| rank > 0);
    let marks: Vec<(usize, String)> = empty_at
        .map(|rank| {
            vec![(
                rank,
                i18n::message_of(
                    language,
                    "cushion-mark-empty",
                    &[("month", &i18n::month_and_year(language, points[rank].0))],
                    &[],
                ),
            )]
        })
        .unwrap_or_default();
    let projection = loan_charts::line(
        &points
            .iter()
            .map(|(month, value)| Point {
                label: short_month(*month),
                value: *value,
                written: money::format(*value, language),
            })
            .collect::<Vec<_>>(),
        loan_charts::NAVY,
        &marks,
        language,
        "cushion",
        None,
    );

    let categories = cushion
        .categories
        .iter()
        .map(|category| WrittenCategory {
            id: category.id,
            label: category.label.clone(),
            monthly: per_month(category.monthly, language),
            kept: !request.excluded.contains(&category.id),
        })
        .collect();

    let period = match (cushion.months.first(), cushion.months.last()) {
        (Some(&first), Some(&last)) => i18n::message_of(
            language,
            "cushion-period",
            &[
                ("from", &i18n::month_and_year(language, first)),
                ("to", &i18n::month_and_year(language, last)),
            ],
            &[("count", cushion.months.len() as i64), ("transfers", cushion.transfers as i64)],
        ),
        _ => String::new(),
    };

    Written {
        verdict,
        tone: if nothing_spent { "good" } else { zone.tone() }.to_string(),
        gauge,
        tiles,
        targets,
        projection,
        categories,
        period,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database::{schema, seed};
    use crate::loan::History;

    const EURO: i64 = money::UNIT;

    fn date(year: i32, month: u32, day: u32) -> NaiveDate {
        NaiveDate::from_ymd_opt(year, month, day).unwrap()
    }

    /// Un compte courant (type 1), un livret A (type 2), un PEL (type 8).
    fn database() -> Connection {
        let conn = Connection::open_in_memory().expect("base en mémoire");
        schema::migrate(&conn).expect("schéma");
        seed::seed_initial_data(&conn).expect("valeurs initiales");
        for (id, label, kind, real) in [
            (1, "CCP", 1, 1_000 * EURO),
            (2, "Livret", 2, 6_000 * EURO),
            (3, "PEL", 8, 9_000 * EURO),
        ] {
            conn.execute(
                "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte, IDBanques, SoldeBanque,
                                     SoldeReel, SoldeFinal, CompteCloture)
                 VALUES (?1, ?2, ?3, 1, ?4, ?4, ?4, 0)",
                rusqlite::params![id, label, kind, real],
            )
            .expect("compte");
        }
        for (id, label) in [(901, "Courses"), (902, "Loisirs")] {
            conn.execute(
                "INSERT INTO Categorie (IDCategorie, Libelle, IDPosteBudget) VALUES (?1, ?2, 0)",
                rusqlite::params![id, label],
            )
            .expect("catégorie");
        }
        conn
    }

    struct Adder<'a> {
        conn: &'a Connection,
        id: i64,
    }

    impl Adder<'_> {
        fn add(&mut self, account: i64, day: &str, amount: i64, category: i64, parent: i64) -> i64 {
            self.id += 1;
            self.conn
                .execute(
                    "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte,
                                            IDStatutOperation, IDOperationParent, IDCategorie)
                     VALUES (?1, 'OP', ?2, ?3, ?4, 1, ?5, ?6)",
                    rusqlite::params![self.id, day, amount, account, parent, category],
                )
                .expect("opération");
            self.id
        }
    }

    fn request() -> Request {
        Request {
            savings: vec![2],
            spending: vec![1],
            history: History::Year(2025).into(),
            excluded: vec![],
            backup: 0,
        }
    }

    /// **La méthode, de bout en bout** : douze mois de 1 500 € de dépenses,
    /// dont 300 € de loisirs, et 200 € virés chaque mois sur le livret. Le
    /// virement n'est pas une dépense, il est le rythme d'épargne.
    #[test]
    fn le_matelas_se_compte_juste() {
        let conn = database();
        let mut ops = Adder { conn: &conn, id: 0 };
        for month in 1..=12 {
            let day = |d: u32| format!("2025-{month:02}-{d:02}");
            ops.add(1, &day(1), 2_000 * EURO, 0, 0); // salaire
            ops.add(1, &day(5), -1_200 * EURO, 901, 0);
            // Une opération ventilée : 300 € dont 200 de courses et 100 de
            // loisirs, puis 200 € de loisirs seuls.
            let mother = ops.add(1, &day(10), -300 * EURO, 0, 0);
            ops.add(1, &day(10), -200 * EURO, 901, mother);
            ops.add(1, &day(10), -100 * EURO, 902, mother);
            ops.add(1, &day(12), -200 * EURO, 902, 0);
            // Le virement vers le livret.
            ops.add(1, &day(20), -200 * EURO, 0, 0);
            ops.add(2, &day(21), 200 * EURO, 0, 0);
        }
        let today = date(2026, 10, 9);
        let cushion = analyse(&conn, &request(), today, "Sans catégorie").unwrap().unwrap();
        assert_eq!(cushion.spending_all, 1_700 * EURO);
        assert_eq!(cushion.spending, 1_700 * EURO);
        assert_eq!(cushion.transfers, 12);
        assert_eq!(cushion.rhythm, 200 * EURO);
        assert_eq!(cushion.savings, 6_000 * EURO);
        assert_eq!(cushion.categories[0].label, "Courses");
        assert_eq!(cushion.categories[0].monthly, 1_400 * EURO);
        assert_eq!(cushion.categories[1].monthly, 300 * EURO);
        let cover = cushion.cover.unwrap();
        assert!((cover - 6_000.0 / 1_700.0).abs() < 1e-9);
        assert_eq!(Zone::of(cushion.cover), Zone::Fair);

        // Sans les loisirs, et avec 400 € de revenu de secours.
        let asked = Request { excluded: vec![902], backup: 400 * EURO, ..request() };
        let cushion = analyse(&conn, &asked, today, "Sans catégorie").unwrap().unwrap();
        assert_eq!(cushion.spending, 1_400 * EURO);
        assert_eq!(cushion.burn, 1_000 * EURO);
        assert_eq!(cushion.cover, Some(6.0));
        assert_eq!(Zone::of(cushion.cover), Zone::Solid);
        // Déjà atteint : six mois de 1 000 €.
        assert_eq!(reached(&cushion, SOLID, today), Some(date(2026, 10, 1)));
    }

    /// **Un virement vers un compte qu'on n'a pas coché** n'est pas une
    /// dépense non plus : les paires se cherchent sur toute la base.
    #[test]
    fn un_virement_vers_un_compte_non_coche_n_est_pas_une_depense() {
        let conn = database();
        let mut ops = Adder { conn: &conn, id: 0 };
        ops.add(1, "2025-03-05", -500 * EURO, 0, 0);
        ops.add(3, "2025-03-07", 500 * EURO, 0, 0);
        ops.add(1, "2025-03-08", -120 * EURO, 901, 0);
        let cushion = analyse(&conn, &request(), date(2026, 10, 9), "Sans catégorie").unwrap().unwrap();
        assert_eq!(cushion.spending_all, 120 * EURO / 12);
        assert_eq!(cushion.transfers, 1);
    }

    #[test]
    fn le_revenu_de_secours_peut_tout_couvrir() {
        assert_eq!(cover(5_000 * EURO, 0), None);
        assert_eq!(cover(5_000 * EURO, -10), None);
        assert_eq!(cover(-100, 1_000), Some(0.0));
        assert_eq!(Zone::of(None), Zone::Solid);
        assert_eq!(Zone::of(Some(2.9)), Zone::Short);
    }

    #[test]
    fn il_faut_un_compte_de_depenses_et_un_mois() {
        let conn = database();
        let today = date(2026, 10, 9);
        let asked = Request { spending: vec![], ..request() };
        assert_eq!(analyse(&conn, &asked, today, "-").unwrap(), Err(Unavailable::NoSpendingAccount));
        let asked = Request { history: History::Year(2027).into(), ..request() };
        assert_eq!(analyse(&conn, &asked, today, "-").unwrap(), Err(Unavailable::NoMonth));
    }

    /// Au rythme de 200 € par mois, il manque 1 000 € : cinq mois.
    #[test]
    fn le_seuil_s_atteint_au_rythme_d_epargne() {
        let cushion = Cushion {
            months: vec![],
            savings: 2_000 * EURO,
            spending_all: 1_000 * EURO,
            spending: 1_000 * EURO,
            backup: 0,
            burn: 1_000 * EURO,
            cover: cover(2_000 * EURO, 1_000 * EURO),
            rhythm: 200 * EURO,
            categories: vec![],
            transfers: 0,
        };
        let today = date(2026, 10, 9);
        assert_eq!(reached(&cushion, SHORT, today), Some(date(2027, 3, 1)));
        let still = Cushion { rhythm: 0, ..cushion.clone() };
        assert_eq!(reached(&still, SHORT, today), None);
        let points = projection(&cushion, today);
        assert_eq!(points.len(), 7);
        assert_eq!(points[2].1, 0);
        assert_eq!(points[6].1, 0, "la courbe s'arrête à zéro");
    }

    #[test]
    fn le_resultat_s_ecrit() {
        let conn = database();
        let mut ops = Adder { conn: &conn, id: 0 };
        for month in 1..=12 {
            ops.add(1, &format!("2025-{month:02}-05"), -1_500 * EURO, 901, 0);
        }
        let today = date(2026, 10, 9);
        let cushion = analyse(&conn, &request(), today, "Sans catégorie").unwrap().unwrap();
        let written = write(&cushion, &request(), today, Language::French);
        assert_eq!(written.tone, "warn");
        assert!(written.gauge.contains("4,0 mois"), "{}", written.gauge);
        assert_eq!(written.targets.len(), 2);
        assert!(written.targets[0].reached);
        assert!(!written.targets[1].reached);
        assert!(written.projection.contains("cushion-above"));
        assert!(written.projection.contains("À sec"));
        assert_eq!(written.categories.len(), 1);
        assert!(written.categories[0].kept);
        assert!(!written.period.is_empty());
    }

    #[test]
    fn les_cases_d_office_suivent_le_type_du_compte() {
        assert_eq!(suggested(1), (false, true));
        assert_eq!(suggested(2), (true, false));
        assert_eq!(suggested(7), (true, false));
        assert_eq!(suggested(8), (false, false));
        assert_eq!(suggested(11), (false, false));
    }
}
