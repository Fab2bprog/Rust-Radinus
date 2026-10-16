//! Ce que la simulation de crédit montre et imprime — F41 (Fabrice,
//! 08/10/2026).
//!
//! [`crate::loan`] calcule ; ce module **écrit** : chaque montant dans la
//! langue en cours, chaque phrase par Fluent, chaque graphique par
//! [`crate::loan_charts`]. La fenêtre reçoit tout cela déjà écrit et ne
//! compose rien ; le rapport PDF s'en sert à l'identique. C'est ce qui fait
//! que l'écran et le papier disent la même chose, au centime et au mot près.

use crate::domain::NaiveDate;
use crate::i18n::{self, Language};
use crate::loan::{
    self, Analysis, Due, Judgement, Judging, Period, Kind, Method, Moved, Settled, Summary, Terms,
    Unavailable, Verdict,
};
use crate::loan_charts::{self as charts, Bar, Part, Point};
use crate::money;
use crate::printing::{self, Failure};
use rusqlite::{Connection, Result};
use time_compute::Datelike;

/// Ce que la fenêtre demande.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Request {
    pub terms: Terms,
    /// La mensualité tapée ou glissée, quand c'est elle qui a bougé.
    pub wished_payment: i64,
    pub moved: Moved,
    /// Les comptes cochés.
    pub accounts: Vec<i64>,
    pub history: Period,
    /// La méthode de jugement retenue, et la hausse des dépenses de chacune.
    pub judging: Judging,
}

/// Le crédit calculé, et l'historique mis en regard.
#[derive(Debug, Clone, PartialEq)]
pub struct Simulation {
    pub settled: Settled,
    pub dues: Vec<Due>,
    pub summary: Summary,
    pub analysis: std::result::Result<Analysis, Unavailable>,
    pub history: Period,
    pub accounts: Vec<i64>,
    pub today: NaiveDate,
}

/// **Tout le calcul, d'un coup** : les curseurs mis d'accord, le tableau, le
/// coût, et l'analyse de l'historique sur les comptes cochés.
pub fn simulate(conn: &Connection, request: &Request, today: NaiveDate) -> Result<Simulation> {
    let settled = loan::settle(request.terms, request.wished_payment, request.moved);
    let first_due = loan::first_due(today);
    let dues = loan::schedule(&settled.terms, settled.payment, first_due);
    let summary = loan::summarise(&settled.terms, settled.payment, &dues);
    // Les comptes clôturés ne comptent pas, même cochés par une fenêtre qui
    // n'aurait pas été relue : ils n'ont plus de revenus à promettre.
    let open: Vec<i64> = crate::accounts::list(conn)?
        .into_iter()
        .filter(|row| !row.is_closed && request.accounts.contains(&row.id))
        .map(|row| row.id)
        .collect();
    let analysis = loan::analyse(
        conn,
        &open,
        request.history,
        today,
        summary.payment_with_insurance,
        settled.terms.months,
        first_due,
        &request.judging,
    )?;
    Ok(Simulation {
        settled,
        dues,
        summary,
        analysis,
        history: request.history,
        accounts: open,
        today,
    })
}

// ---------------------------------------------------------------------------
// L'écriture
// ---------------------------------------------------------------------------

/// Un chiffre clef : son intitulé, sa valeur écrite, et le ton qui la colore
/// — `good`, `warn`, `bad`, ou rien.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Figure {
    pub label: String,
    pub value: String,
    pub tone: &'static str,
}

/// Une ligne du tableau d'amortissement, écrite — et ses nombres, pour le
/// tri et pour l'export.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct WrittenDue {
    pub number: u32,
    pub date: String,
    pub date_value: String,
    pub payment: String,
    pub interest: String,
    pub capital: String,
    pub insurance: String,
    pub remaining: String,
    pub payment_value: i64,
    pub interest_value: i64,
    pub capital_value: i64,
    pub insurance_value: i64,
    pub remaining_value: i64,
}

/// Un crédit en cours, écrit.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct WrittenLoan {
    pub label: String,
    pub monthly: String,
    pub end: String,
}

/// Une des trois questions du voyant : sa réponse écrite, et sa couleur —
/// `good`, `warn`, `bad`, ou `info` quand la question est sans objet.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Check {
    pub tone: &'static str,
    pub text: String,
}

fn tone_of(verdict: Verdict) -> &'static str {
    match verdict {
        Verdict::Green => "good",
        Verdict::Orange => "warn",
        Verdict::Red => "bad",
    }
}

/// Une colonne de l'onglet « Réglages du jugement » : la méthode, son
/// verdict pour le crédit en cours, ce qu'elle exige — **écrit avec les
/// chiffres de la personne** — et ce qu'elle suppose.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct WrittenMethod {
    pub key: &'static str,
    pub name: String,
    pub verdict: &'static str,
    pub verdict_word: String,
    /// Une valeur par ligne du tableau, la hausse des dépenses exceptée : elle
    /// est un champ.
    pub values: Vec<String>,
    pub growth: u32,
    pub explanation: String,
}

/// L'onglet « Puis-je le rembourser ? », écrit.
#[derive(Debug, Clone, PartialEq)]
pub struct WrittenAnalysis {
    pub verdict: &'static str,
    pub verdict_word: String,
    /// Les trois questions qui font le voyant, chacune avec sa couleur.
    pub checks: Vec<Check>,
    /// « Méthode de jugement : Neutre ».
    pub method_line: String,
    /// Les trois méthodes, pour l'onglet « Réglages du jugement ».
    pub methods: Vec<WrittenMethod>,
    /// Les intitulés des lignes de son tableau, la hausse des dépenses en
    /// dernier.
    pub rule_rows: Vec<String>,
    pub rules_intro: String,
    /// « Optimiste : Jouable · Neutre : Serré · Sévère : Risqué ».
    pub verdicts_line: String,
    /// L'historique est déjà déficitaire avant tout crédit : dit à part.
    pub warning: Option<String>,
    pub gauge: String,
    pub figures: Vec<Figure>,
    pub income_donut: String,
    pub bars: String,
    pub projection: String,
    pub loans: Vec<WrittenLoan>,
    pub loans_empty: String,
    pub period: String,
    pub transfers: String,
    pub method: String,
}

/// Tout ce que la fenêtre montre, déjà écrit.
#[derive(Debug, Clone, PartialEq)]
pub struct Written {
    pub kind: Kind,
    /// Les valeurs des champs, telles qu'on les retape : sans devise ni
    /// séparateur de milliers.
    pub amount_field: String,
    pub payment_field: String,
    pub rate_field: String,
    pub fees_field: String,
    pub insurance_field: String,
    pub months: u32,
    pub months_text: String,
    pub notice: Option<String>,
    pub figures: Vec<Figure>,
    pub dues: Vec<WrittenDue>,
    pub cost_donut: String,
    pub capital_curve: String,
    /// L'analyse, ou la phrase qui dit pourquoi elle n'a pas lieu.
    pub analysis: std::result::Result<WrittenAnalysis, String>,
}

/// Un pourcentage écrit dans la langue : « 7,74 % », « 7.74% ».
pub fn percent(value: f64, language: Language) -> String {
    let (_, decimal) = money::separators(language);
    let number = format!("{value:.2}").replace('.', &decimal.to_string());
    i18n::message_of(language, "loan-percent", &[("value", &number)], &[])
}

/// Le taux, tel qu'on le retape dans son champ : « 6,41 ».
pub fn rate_field(rate: i64, language: Language) -> String {
    money::format_plain(rate, language)
}

fn day(date: NaiveDate) -> String {
    date.format("%d/%m/%Y").to_string()
}

fn short_month(date: NaiveDate) -> String {
    format!("{:02}/{:02}", date.month(), date.year() % 100)
}

fn long_month(date: NaiveDate) -> String {
    format!("{:02}/{}", date.month(), date.year())
}

pub fn months_text(months: u32, language: Language) -> String {
    i18n::message_of(language, "loan-months-count", &[], &[("count", i64::from(months))])
}

/// **Écrit la simulation**, pour la fenêtre comme pour le papier.
pub fn write(simulation: &Simulation, language: Language) -> Written {
    let label = |key: &str| i18n::text(language, key);
    let written = |amount: i64| money::format(amount, language);
    let terms = &simulation.settled.terms;
    let summary = &simulation.summary;

    let figures = vec![
        Figure { label: label("loan-figure-payment"), value: written(summary.payment), tone: "" },
        Figure {
            label: label("loan-figure-payment-insured"),
            value: written(summary.payment_with_insurance),
            tone: "",
        },
        Figure {
            label: label("loan-figure-taeg"),
            value: summary.taeg.map_or_else(|| "—".to_string(), |taeg| percent(taeg, language)),
            tone: "",
        },
        Figure { label: label("loan-figure-interest"), value: written(summary.interest), tone: "" },
        Figure { label: label("loan-figure-insurance"), value: written(summary.insurance_total), tone: "" },
        Figure { label: label("loan-figure-cost"), value: written(summary.cost), tone: "" },
        Figure { label: label("loan-figure-total-due"), value: written(summary.total_due), tone: "" },
        Figure { label: label("loan-figure-all-in"), value: written(summary.all_in), tone: "" },
    ];

    let dues = simulation
        .dues
        .iter()
        .map(|due| WrittenDue {
            number: due.number,
            date: day(due.date),
            date_value: due.date.format("%Y-%m-%d").to_string(),
            payment: written(due.payment),
            interest: written(due.interest),
            capital: written(due.capital),
            insurance: written(due.insurance),
            remaining: written(due.remaining),
            payment_value: due.payment,
            interest_value: due.interest,
            capital_value: due.capital,
            insurance_value: due.insurance,
            remaining_value: due.remaining,
        })
        .collect();

    let cost_donut = charts::donut(
        &[
            Part { label: label("loan-part-capital"), amount: terms.amount, written: written(terms.amount), colour: charts::NAVY },
            Part { label: label("loan-part-interest"), amount: summary.interest, written: written(summary.interest), colour: charts::GOLD },
            Part { label: label("loan-part-fees"), amount: summary.fees, written: written(summary.fees), colour: charts::SAND },
            Part {
                label: label("loan-part-insurance"),
                amount: summary.insurance_total,
                written: written(summary.insurance_total),
                colour: charts::SKY,
            },
        ],
        &charts::euros(terms.amount + summary.cost, language),
        &label("loan-donut-cost-caption"),
    );

    // Le capital au départ, puis ce qui reste après chaque échéance : la
    // première étiquette est la date du déblocage, un mois avant la première
    // échéance.
    let mut points = vec![Point {
        label: long_month(simulation.today),
        value: summary.principal,
        written: written(summary.principal),
    }];
    points.extend(simulation.dues.iter().map(|due| Point {
        label: long_month(due.date),
        value: due.remaining,
        written: written(due.remaining),
    }));
    let capital_curve = charts::line(&points, charts::NAVY, &[], language, "capital", None);

    let analysis = match &simulation.analysis {
        Ok(analysis) => Ok(write_analysis(simulation, analysis, language)),
        Err(reason) => Err(label(reason.key())),
    };

    Written {
        kind: terms.kind,
        amount_field: money::format_plain(terms.amount, language),
        payment_field: money::format_plain(simulation.settled.payment, language),
        rate_field: rate_field(terms.rate, language),
        fees_field: money::format_plain(terms.fees, language),
        insurance_field: money::format_plain(terms.insurance, language),
        months: terms.months,
        months_text: months_text(terms.months, language),
        notice: simulation.settled.notice.map(label),
        figures,
        dues,
        cost_donut,
        capital_curve,
        analysis,
    }
}

/// Le mot du mois de référence d'une méthode, pour les sélecteurs Fluent :
/// un bon mois, un mois habituel, un mois difficile.
fn reference_kind(method: Method) -> &'static str {
    match method {
        Method::Optimistic => "good",
        Method::Neutral => "usual",
        Method::Severe => "hard",
    }
}

fn method_name(method: Method, language: Language) -> String {
    i18n::text(language, &format!("loan-method-{}", method.key()))
}

fn verdict_word(verdict: Verdict, language: Language) -> String {
    i18n::text(
        language,
        match verdict {
            Verdict::Green => "loan-verdict-green",
            Verdict::Orange => "loan-verdict-orange",
            Verdict::Red => "loan-verdict-red",
        },
    )
}

/// Un seuil de pourcentage tel que le tableau l'écrit : « 33 % », sans
/// décimales — le tiers de la méthode sévère se lit « 33 % », ses deux tiers
/// « 67 % ».
fn whole_percent(value: f64, language: Language) -> String {
    i18n::message_of(language, "loan-percent", &[("value", &format!("{:.0}", value.round()))], &[])
}

/// **Les trois réponses d'une méthode**, écrites, chacune avec sa couleur.
fn write_checks(analysis: &Analysis, judgement: &Judgement, language: Language) -> Vec<Check> {
    let label = |key: &str| i18n::text(language, key);
    let written = |amount: i64| money::format(amount, language);
    let rules = &judgement.rules;
    let kind = reference_kind(judgement.method);
    let debt_text = match (analysis.debt_ratio, judgement.checks[0]) {
        (None, _) => label("loan-verdict-no-income"),
        (Some(ratio), verdict) => i18n::message_of(
            language,
            match verdict {
                Verdict::Green => "loan-check-debt-green",
                Verdict::Orange => "loan-check-debt-orange",
                Verdict::Red => "loan-check-debt-red",
            },
            &[
                ("ratio", &percent(ratio, language)),
                ("green", &whole_percent(rules.debt_green, language)),
                ("red", &whole_percent(rules.debt_red, language)),
            ],
            &[],
        ),
    };
    let effort_text = match judgement.effort {
        loan::Effort::Share(share) => i18n::message_of(
            language,
            "loan-check-effort",
            &[
                ("payment", &written(analysis.new_monthly)),
                ("share", &percent(share, language)),
                ("margin", &written(judgement.reference_margin)),
                ("kind", kind),
            ],
            &[],
        ),
        loan::Effort::NoMargin => i18n::message_of(
            language,
            "loan-check-effort-none",
            &[("payment", &written(analysis.new_monthly)), ("kind", kind)],
            &[],
        ),
    };
    // Le seuil de la méthode sévère est une réserve de sécurité, et la phrase
    // la nomme ; ailleurs, c'est zéro.
    let floor = judgement.floor > 0;
    let key = |base: &str| {
        if floor {
            format!("loan-check-reserve-floor-{base}")
        } else {
            format!("loan-check-reserve-{base}")
        }
    };
    let floor_text = written(judgement.floor);
    let reserve_text = match judgement.reserve {
        loan::Reserve::Holds => i18n::message_of(language, &key("green"), &[("floor", &floor_text)], &[]),
        loan::Reserve::Breaks(day) => i18n::message_of(
            language,
            &key("red"),
            &[("month", &i18n::month_and_year(language, day)), ("floor", &floor_text)],
            &[],
        ),
        loan::Reserve::Sooner { with, months } => i18n::message_of(
            language,
            &key("sooner"),
            &[("month", &i18n::month_and_year(language, with)), ("floor", &floor_text)],
            &[("count", months as i64)],
        ),
        loan::Reserve::Anyway(day) => i18n::message_of(
            language,
            &key("anyway"),
            &[("month", &i18n::month_and_year(language, day)), ("floor", &floor_text)],
            &[],
        ),
    };
    let mut checks: Vec<Check> = [debt_text, effort_text, reserve_text]
        .into_iter()
        .zip(judgement.checks)
        .map(|(text, verdict)| Check { tone: tone_of(verdict), text })
        .collect();
    // Sans épargne dans le mois de référence, la deuxième question est sans
    // objet : sa pastille est grise, et c'est la réserve qui juge. Un vert y
    // aurait promis quelque chose que la phrase ne dit pas.
    if judgement.effort == loan::Effort::NoMargin {
        checks[1].tone = "info";
    }
    checks
}

/// **Une colonne du tableau des méthodes**, écrite avec les chiffres de la
/// personne : « un mois difficile : 180 € », « un mois de dépenses :
/// 2 604 € ».
fn write_method(judgement: &Judgement, language: Language) -> WrittenMethod {
    let rules = &judgement.rules;
    let limits = |green: f64, red: f64| {
        i18n::message_of(
            language,
            "loan-rule-limits",
            &[
                ("green", &whole_percent(green, language)),
                ("red", &whole_percent(red, language)),
            ],
            &[],
        )
    };
    let values = vec![
        limits(rules.debt_green, rules.debt_red),
        i18n::message_of(
            language,
            "loan-rule-reference",
            &[
                ("kind", reference_kind(judgement.method)),
                ("amount", &money::format(judgement.reference_margin, language)),
            ],
            &[],
        ),
        limits(rules.effort_green, rules.effort_red),
        if judgement.floor > 0 {
            i18n::message_of(
                language,
                "loan-rule-floor-cushion",
                &[("amount", &money::format(judgement.floor, language))],
                &[],
            )
        } else {
            i18n::text(language, "loan-rule-floor-zero")
        },
        i18n::message_of(
            language,
            "loan-rule-sooner",
            &[
                ("orange", &months_text(rules.sooner_orange as u32, language)),
                ("red", &months_text(rules.sooner_red as u32, language)),
            ],
            &[],
        ),
    ];
    WrittenMethod {
        key: judgement.method.key(),
        name: method_name(judgement.method, language),
        verdict: judgement.verdict.key(),
        verdict_word: verdict_word(judgement.verdict, language),
        values,
        growth: judgement.growth,
        explanation: i18n::text(language, &format!("loan-method-{}-explain", judgement.method.key())),
    }
}

fn write_analysis(simulation: &Simulation, analysis: &Analysis, language: Language) -> WrittenAnalysis {
    let label = |key: &str| i18n::text(language, key);
    let written = |amount: i64| money::format(amount, language);
    let ratio = analysis.debt_ratio.map(|ratio| percent(ratio, language));
    let count = analysis.months.len() as i64;
    let judgement = analysis.judgement();
    let rules = &judgement.rules;

    // **Les trois questions du voyant**, chacune avec sa réponse en clair : on
    // voit pourquoi le verdict est ce qu'il est.
    let checks = write_checks(analysis, judgement, language);
    let warning = analysis.deficit.then(|| {
        i18n::message_of(language, "loan-warning-deficit", &[("amount", &written(-analysis.saving))], &[])
    });
    let tone_of_ratio = tone_of(judgement.checks[0]);
    let end_balance = judgement.projection.last().map_or(analysis.start_balance, |point| point.1);
    let figures = vec![
        Figure { label: label("loan-figure-income"), value: written(analysis.income), tone: "" },
        Figure { label: label("loan-figure-spending"), value: written(analysis.spending), tone: "" },
        Figure {
            label: label("loan-figure-saving"),
            value: written(analysis.saving),
            tone: if analysis.saving < 0 { "bad" } else { "" },
        },
        Figure {
            label: i18n::message_of(
                language,
                "loan-figure-reference",
                &[("kind", reference_kind(judgement.method))],
                &[],
            ),
            value: written(judgement.reference_margin),
            tone: if judgement.reference_margin <= 0 { "warn" } else { "" },
        },
        Figure { label: label("loan-figure-running"), value: written(analysis.running_monthly), tone: "" },
        Figure { label: label("loan-figure-new"), value: written(analysis.new_monthly), tone: "" },
        Figure {
            label: label("loan-figure-rest"),
            value: written(analysis.rest),
            tone: if analysis.rest < 0 { "bad" } else { "good" },
        },
        Figure {
            label: label("loan-figure-debt"),
            value: ratio.clone().unwrap_or_else(|| "—".to_string()),
            tone: tone_of_ratio,
        },
        Figure {
            label: label("loan-figure-tipped"),
            value: i18n::message_of(
                language,
                "loan-red-months-value",
                &[],
                &[("count", analysis.tipped_months as i64), ("total", count)],
            ),
            tone: match analysis.tipped_months {
                0 => "good",
                1 | 2 => "warn",
                _ => "bad",
            },
        },
        Figure { label: label("loan-figure-balance-now"), value: written(analysis.start_balance), tone: "" },
        Figure {
            label: label("loan-figure-balance-end"),
            value: written(end_balance),
            tone: if end_balance < judgement.floor { "bad" } else { "" },
        },
    ];

    let gauge = charts::gauge(
        analysis.debt_ratio,
        ratio.as_deref().unwrap_or("—"),
        &label("loan-gauge-caption"),
        rules.debt_green,
        rules.debt_red,
    );

    let ordinary = (analysis.spending - analysis.running_monthly).max(0);
    let mut parts = vec![
        Part { label: label("loan-part-spending"), amount: ordinary, written: written(ordinary), colour: charts::SKY },
        Part {
            label: label("loan-part-running"),
            amount: analysis.running_monthly,
            written: written(analysis.running_monthly),
            colour: charts::SLATE,
        },
        Part {
            label: label("loan-part-new"),
            amount: analysis.new_monthly,
            written: written(analysis.new_monthly),
            colour: charts::GOLD,
        },
    ];
    if analysis.rest >= 0 {
        parts.push(Part {
            label: label("loan-part-rest"),
            amount: analysis.rest,
            written: written(analysis.rest),
            colour: charts::GREEN,
        });
    } else {
        parts.push(Part {
            label: label("loan-part-missing"),
            amount: -analysis.rest,
            written: written(-analysis.rest),
            colour: charts::RED,
        });
    }
    let income_donut = charts::donut(
        &parts,
        &charts::euros(analysis.income, language),
        &label("loan-donut-income-caption"),
    );

    let bars = charts::bars(
        &analysis
            .months
            .iter()
            .map(|flow| {
                let left = flow.left_with(analysis.new_monthly);
                Bar {
                    label: short_month(flow.month),
                    value: left,
                    written: written(left),
                    already: flow.left_with(0) < 0,
                }
            })
            .collect::<Vec<_>>(),
        language,
    );

    // La projection de la méthode retenue : sa hausse des dépenses, et sa
    // réserve de sécurité tracée en pointillés quand elle en a une.
    let mut points = vec![Point {
        label: long_month(simulation.today),
        value: analysis.start_balance,
        written: written(analysis.start_balance),
    }];
    points.extend(judgement.projection.iter().map(|(day, value)| Point {
        label: long_month(*day),
        value: *value,
        written: written(*value),
    }));
    let mut marks: Vec<(usize, String)> = Vec::new();
    for running in &analysis.running {
        // Le premier point où sa mensualité ne sort plus.
        if let Some(rank) = judgement.projection.iter().position(|(day, _)| *day > running.end) {
            marks.push((
                rank + 1,
                i18n::message_of(language, "loan-mark-loan-end", &[("label", &running.label)], &[]),
            ));
        }
    }
    if let Some(day) = judgement.first_below {
        if let Some(rank) = judgement.projection.iter().position(|(other, _)| *other == day) {
            marks.push((
                rank + 1,
                label(if judgement.floor > 0 { "loan-mark-floor" } else { "loan-mark-negative" }),
            ));
        }
    }
    marks.sort_by_key(|(rank, _)| *rank);
    marks.truncate(3);
    let floor_label = label("loan-mark-floor-line");
    let floor = (judgement.floor > 0).then_some((judgement.floor, floor_label.as_str()));
    let projection = charts::line(&points, charts::SLATE, &marks, language, "projection", floor);

    let loans = analysis
        .running
        .iter()
        .map(|running| WrittenLoan {
            label: running.label.clone(),
            monthly: written(running.monthly),
            end: day(running.end),
        })
        .collect();

    let (first, last) = (
        analysis.months.first().map(|flow| flow.month),
        analysis.months.last().map(|flow| flow.month),
    );
    let period = match (first, last) {
        (Some(first), Some(last)) => i18n::message_of(
            language,
            "loan-period-caption",
            &[
                ("from", &i18n::month_and_year(language, first)),
                ("to", &i18n::month_and_year(language, last)),
            ],
            &[("count", count)],
        ),
        _ => String::new(),
    };

    let methods: Vec<WrittenMethod> = analysis
        .judgements
        .iter()
        .map(|other| write_method(other, language))
        .collect();
    let verdicts_line = methods
        .iter()
        .map(|method| {
            i18n::message_of(
                language,
                "loan-method-verdict",
                &[("method", &method.name), ("verdict", &method.verdict_word)],
                &[],
            )
        })
        .collect::<Vec<_>>()
        .join(" · ");

    WrittenAnalysis {
        verdict: judgement.verdict.key(),
        verdict_word: verdict_word(judgement.verdict, language),
        checks,
        method_line: i18n::message_of(
            language,
            "loan-method-line",
            &[("method", &method_name(judgement.method, language))],
            &[],
        ),
        methods,
        rule_rows: [
            "loan-rule-row-debt",
            "loan-rule-row-reference",
            "loan-rule-row-share",
            "loan-rule-row-floor",
            "loan-rule-row-sooner",
            "loan-rule-row-growth",
        ]
        .iter()
        .map(|key| label(key))
        .collect(),
        rules_intro: label("loan-rules-intro"),
        verdicts_line,
        warning,
        gauge,
        figures,
        income_donut,
        bars,
        projection,
        loans,
        loans_empty: label("loan-no-running"),
        period,
        transfers: i18n::message_of(language, "loan-transfers", &[], &[("count", analysis.transfers as i64)]),
        method: label("loan-method"),
    }
}

// ---------------------------------------------------------------------------
// Le rapport PDF
// ---------------------------------------------------------------------------

/// **Le rapport PDF** (Fabrice, 08/10/2026 : « il serait bien aussi de faire
/// un rapport PDF imprimable »), A4 portrait.
///
/// Une première page soignée — le bandeau, les grandes tuiles, le verdict —,
/// puis les graphiques, puis le tableau d'amortissement : **en entier pour un
/// crédit à la consommation ; pour l'immobilier une ligne par année**, sauf
/// si `monthly` le demande mois par mois (« Tableau mois par mois »).
///
/// Les comptes y sont désignés **par leur nom seulement**, jamais par leur
/// numéro.
pub fn pdf(
    conn: &Connection,
    simulation: &Simulation,
    language: Language,
    monthly: bool,
) -> std::result::Result<Vec<u8>, Failure> {
    let written = write(simulation, language);
    let label = |key: &str| i18n::text(language, key);
    let q = |text: &str| printing::quoted(text);
    let terms = &simulation.settled.terms;
    let mut out = String::new();
    let mut let_text = |name: &str, value: &str| {
        out.push_str(&format!("#let {name} = {}\n", q(value)));
    };

    let_text("famille", printing::FAMILY);
    let_text("langue", language.tag());
    let_text("logo", printing::LOGO_PATH);
    let_text("titre", &label("loan-report-title"));
    let_text(
        "sous-titre",
        &format!(
            "{} · {}",
            label(match terms.kind {
                Kind::Consumer => "loan-kind-consumer",
                Kind::Mortgage => "loan-kind-mortgage",
            }),
            i18n::message_of(language, "loan-report-made-on", &[("date", &day(simulation.today))], &[]),
        ),
    );
    let_text("avertissement", &label("loan-disclaimer"));
    let_text("titre-credit", &label("loan-tab-credit"));
    let_text("titre-capacite", &label("loan-tab-afford"));
    let_text("titre-cout", &label("loan-chart-cost"));
    let_text("titre-capital", &label("loan-chart-capital"));
    let_text("titre-revenu", &label("loan-chart-income"));
    let_text("titre-historique", &label("loan-chart-history"));
    let_text("aide-historique", &label("loan-chart-history-hint"));
    let_text("titre-projection", &label("loan-chart-projection"));
    let_text("titre-comptes", &label("loan-accounts-title"));
    let_text("titre-periode", &label("loan-period-title"));
    let_text("titre-encours", &label("loan-running-title"));
    let yearly = terms.kind == Kind::Mortgage && !monthly;
    let_text(
        "titre-tableau",
        &label(if yearly { "loan-schedule-yearly" } else { "loan-schedule-title" }),
    );
    let_text("cout-svg", &written.cost_donut);
    let_text("capital-svg", &written.capital_curve);

    // Les saisies, en deux colonnes d'intitulés et de valeurs.
    let inputs = [
        (label("loan-field-amount"), money::format(terms.amount, language)),
        (label("loan-field-rate"), percent(terms.rate as f64 / loan::EURO as f64, language)),
        (label("loan-field-months"), written.months_text.clone()),
        (label("loan-field-fees"), money::format(terms.fees, language)),
        (label("loan-field-insurance"), money::format(terms.insurance, language)),
    ];
    out.push_str("#let saisies = (\n");
    for (name, value) in &inputs {
        out.push_str(&format!("  ({}, {}),\n", q(name), q(value)));
    }
    out.push_str(")\n");
    // Les quatre grandes tuiles, puis les autres chiffres.
    out.push_str("#let tuiles = (\n");
    for figure in [&written.figures[0], &written.figures[2], &written.figures[5], &written.figures[6]] {
        out.push_str(&format!("  ({}, {}),\n", q(&figure.label), q(&figure.value)));
    }
    out.push_str(")\n#let chiffres-credit = (\n");
    for figure in [&written.figures[1], &written.figures[3], &written.figures[4], &written.figures[7]] {
        out.push_str(&format!("  ({}, {}),\n", q(&figure.label), q(&figure.value)));
    }
    out.push_str(")\n");

    match &written.analysis {
        Ok(analysis) => {
            out.push_str("#let analyse = true\n");
            let colour = match analysis.verdict {
                "green" => charts::GREEN,
                "orange" => charts::ORANGE,
                _ => charts::RED,
            };
            out.push_str(&format!("#let couleur-verdict = rgb({})\n", q(colour)));
            out.push_str(&format!("#let verdict = {}\n", q(&analysis.verdict_word)));
            out.push_str(&format!("#let ligne-methode = {}\n", q(&analysis.method_line)));
            out.push_str(&format!("#let trois-verdicts = {}\n", q(&analysis.verdicts_line)));
            let explanation = analysis
                .methods
                .iter()
                .find(|method| method.key == simulation_method_key(simulation))
                .map(|method| method.explanation.clone())
                .unwrap_or_default();
            out.push_str(&format!("#let explication = {}\n", q(&explanation)));
            out.push_str("#let questions = (\n");
            for check in &analysis.checks {
                let colour = match check.tone {
                    "good" => charts::GREEN,
                    "warn" => charts::ORANGE,
                    "info" => charts::MUTED,
                    _ => charts::RED,
                };
                out.push_str(&format!("  (rgb({}), {}),\n", q(colour), q(&check.text)));
            }
            out.push_str(")\n");
            out.push_str(&format!(
                "#let alerte = {}\n",
                analysis.warning.as_deref().map_or_else(|| "none".to_string(), q)
            ));
            out.push_str(&format!("#let jauge-svg = {}\n", q(&analysis.gauge)));
            out.push_str(&format!("#let revenu-svg = {}\n", q(&analysis.income_donut)));
            out.push_str(&format!("#let barres-svg = {}\n", q(&analysis.bars)));
            out.push_str(&format!("#let projection-svg = {}\n", q(&analysis.projection)));
            out.push_str(&format!("#let periode = {}\n", q(&analysis.period)));
            out.push_str(&format!("#let virements = {}\n", q(&analysis.transfers)));
            out.push_str(&format!("#let methode = {}\n", q(&analysis.method)));
            out.push_str("#let chiffres-capacite = (\n");
            for figure in &analysis.figures {
                let tone = match figure.tone {
                    "good" => charts::GREEN,
                    "warn" => charts::ORANGE,
                    "bad" => charts::RED,
                    _ => charts::INK,
                };
                out.push_str(&format!("  ({}, {}, rgb({})),\n", q(&figure.label), q(&figure.value), q(tone)));
            }
            out.push_str(")\n");
            let names: Vec<String> = crate::accounts::list(conn)?
                .into_iter()
                .filter(|row| simulation.accounts.contains(&row.id))
                .map(|row| row.label)
                .collect();
            out.push_str(&format!("#let comptes = {}\n", q(&names.join(", "))));
            out.push_str("#let encours = (\n");
            for running in &analysis.loans {
                out.push_str(&format!("  ({}, {}, {}),\n", q(&running.label), q(&running.monthly), q(&running.end)));
            }
            out.push_str(")\n");
            out.push_str(&format!("#let encours-vide = {}\n", q(&analysis.loans_empty)));
            out.push_str(&format!(
                "#let encours-titres = ({}, {}, {})\n",
                q(&label("loan-running-column-label")),
                q(&label("loan-running-column-monthly")),
                q(&label("loan-running-column-end"))
            ));
        }
        Err(reason) => {
            out.push_str("#let analyse = false\n");
            out.push_str(&format!("#let raison = {}\n", q(reason)));
        }
    }

    // Le tableau d'amortissement.
    let rows: Vec<Due> = if yearly {
        loan::by_year(&simulation.dues)
    } else {
        simulation.dues.clone()
    };
    let first_title = label(if yearly { "loan-column-year" } else { "loan-column-number" });
    out.push_str(&format!(
        "#let colonnes = ({}, {}, {}, {}, {}, {}, {})\n",
        q(&first_title),
        q(&label("loan-column-date")),
        q(&label(if yearly { "loan-column-payments" } else { "loan-column-payment" })),
        q(&label("loan-column-interest")),
        q(&label("loan-column-capital")),
        q(&label("loan-column-insurance")),
        q(&label("loan-column-remaining")),
    ));
    out.push_str("#let lignes = (\n");
    for due in &rows {
        out.push_str(&format!(
            "  ({}, {}, {}, {}, {}, {}, {}),\n",
            q(&due.number.to_string()),
            q(&if yearly { due.date.year().to_string() } else { day(due.date) }),
            q(&money::format(due.payment, language)),
            q(&money::format(due.interest, language)),
            q(&money::format(due.capital, language)),
            q(&money::format(due.insurance, language)),
            q(&money::format(due.remaining, language)),
        ));
    }
    out.push_str(")\n");
    out.push_str(TEMPLATE);
    printing::compose(out, "radinus-credit")
}

/// La clef de la méthode retenue, quand l'analyse a eu lieu.
fn simulation_method_key(simulation: &Simulation) -> &'static str {
    simulation
        .analysis
        .as_ref()
        .map(|analysis| analysis.chosen.key())
        .unwrap_or("neutral")
}

/// La mise en page du rapport. Les couleurs sont celles des graphiques.
const TEMPLATE: &str = r##"
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
    text(size: 15pt, weight: "bold", fill: nuit, valeur)
  },
)

#let paires(couples) = table(
  columns: (1fr, auto), stroke: none, inset: (x: 0pt, y: 3.5pt),
  ..couples.map(c => (text(fill: gris, c.at(0)), align(right, text(weight: "bold", c.at(1))))).flatten(),
)

#let carte(titre, corps) = block(
  width: 100%, stroke: 0.6pt + filet, radius: 6pt, inset: 12pt, breakable: false,
  { text(size: 10pt, weight: "bold", fill: nuit, titre); v(6pt); corps },
)

// --- Le bandeau -------------------------------------------------------------
#block(width: 100%, fill: nuit, radius: 8pt, inset: (x: 16pt, y: 14pt), grid(
  columns: (auto, 1fr), column-gutter: 14pt, align: horizon,
  box(fill: white, radius: 6pt, inset: 4pt, image(logo, height: 46pt)),
  {
    text(size: 22pt, weight: "bold", fill: white, titre)
    v(-4pt)
    text(size: 10pt, fill: rgb("#d5e2ec"), sous-titre)
  },
))

// --- Le crédit --------------------------------------------------------------
#titre-section(titre-credit)
#grid(columns: (1fr, 1fr, 1fr, 1fr), column-gutter: 8pt,
  ..tuiles.map(t => tuile(t.at(0), t.at(1))))
#v(8pt)
#grid(columns: (1fr, 1fr), column-gutter: 22pt, paires(saisies), paires(chiffres-credit))

// --- Puis-je le rembourser ? -------------------------------------------------
#titre-section(titre-capacite)
#if analyse {
  // Le liseré de gauche prend la couleur du voyant.
  block(width: 100%, fill: fond, radius: (right: 6pt), breakable: false,
    stroke: (left: 5pt + couleur-verdict), inset: (x: 14pt, y: 10pt), {
      grid(columns: (auto, 1fr), column-gutter: 10pt, align: bottom,
        text(size: 16pt, weight: "bold", fill: couleur-verdict, verdict),
        align(right, text(size: 8pt, fill: gris, ligne-methode)))
      v(2pt)
      for (couleur, phrase) in questions {
        grid(columns: (10pt, 1fr), column-gutter: 4pt, align: top,
          pad(top: 1.6pt, circle(radius: 3.2pt, fill: couleur)), text(size: 9pt, phrase))
        v(1pt)
      }
    })
  v(3pt)
  block(width: 100%, {
    set text(size: 8pt, fill: gris)
    trois-verdicts
    linebreak()
    explication
  })
  if alerte != none {
    v(6pt)
    block(width: 100%, fill: rgb("#fdf3e6"), radius: 6pt, inset: (x: 12pt, y: 8pt),
      text(size: 9pt, fill: rgb("#8a5a12"), alerte))
  }
  v(8pt)
  block(breakable: false, grid(columns: (170pt, 1fr), column-gutter: 18pt, align: horizon,
    svg(jauge-svg, 170pt),
    table(columns: (1fr, auto), stroke: none, inset: (x: 0pt, y: 3pt),
      ..chiffres-capacite.map(c => (text(fill: gris, c.at(0)),
        align(right, text(weight: "bold", fill: c.at(2), c.at(1))))).flatten())))
  v(6pt)
  block({
    set text(size: 8pt, fill: gris)
    [*#titre-periode* : #periode · *#titre-comptes* : #comptes]
    linebreak()
    virements
    linebreak()
    methode
  })
  v(10pt)
  carte(titre-revenu, align(center, svg(revenu-svg, 330pt)))
  v(10pt)
  carte(titre-historique, { text(size: 8pt, fill: gris, aide-historique); v(4pt); svg(barres-svg, 100%) })
  v(10pt)
  carte(titre-projection, svg(projection-svg, 100%))
  v(10pt)
  if encours.len() > 0 {
    carte(titre-encours, table(columns: (1fr, auto, auto), stroke: none, inset: (x: 4pt, y: 3pt),
      ..encours-titres.map(t => text(fill: gris, size: 8pt, t)),
      ..encours.map(l => (l.at(0), align(right, l.at(1)), align(right, l.at(2)))).flatten()))
  } else {
    text(size: 8pt, fill: gris, encours-vide)
  }
} else {
  block(width: 100%, fill: fond, radius: 6pt, inset: 12pt, text(fill: gris, raison))
}

// Les deux graphiques du crédit lui-même, en pleine largeur : en demi-page,
// leurs graduations ne se lisaient plus.
#v(10pt)
#carte(titre-cout, align(center, svg(cout-svg, 330pt)))
#v(10pt)
#carte(titre-capital, svg(capital-svg, 100%))

// --- Le tableau d'amortissement ------------------------------------------------
#pagebreak()
#titre-section(titre-tableau)
#set text(size: 8pt)
#table(
  columns: (auto, auto, 1fr, 1fr, 1fr, 1fr, 1fr),
  stroke: none,
  inset: (x: 5pt, y: 4pt),
  align: (x, y) => if x < 2 { left } else { right },
  fill: (x, y) => if y == 0 { nuit } else if calc.even(y) { fond } else { white },
  table.header(repeat: true, ..colonnes.map(c => text(fill: white, weight: "bold", c))),
  ..lignes.flatten(),
)
"##;

#[cfg(test)]
mod tests {
    use super::*;
    use crate::loan::History;
    use crate::database::{schema, seed};

    const EURO: i64 = loan::EURO;

    fn date(year: i32, month: u32, day: u32) -> NaiveDate {
        NaiveDate::from_ymd_opt(year, month, day).expect("date")
    }

    fn database() -> Connection {
        let conn = Connection::open_in_memory().expect("base en mémoire");
        schema::migrate(&conn).expect("schéma");
        seed::seed_initial_data(&conn).expect("valeurs initiales");
        conn.execute(
            "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte, IDBanques, SoldeBanque, SoldeReel,
                                 SoldeFinal, CompteCloture, COBNumCompte)
             VALUES (1, 'Compte courant', 1, 1, 0, 2000000000, 0, 0, '12345678901')",
            [],
        )
        .expect("compte");
        for month in 1..=12 {
            for (id, day, amount) in [(month * 2, 2, 2_100 * EURO), (month * 2 + 1, 12, -1_500 * EURO)] {
                conn.execute(
                    "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte,
                                            IDStatutOperation, IDOperationParent)
                     VALUES (?1, 'OP', ?2, ?3, 1, 1, 0)",
                    rusqlite::params![id, format!("2025-{month:02}-{day:02}"), amount],
                )
                .expect("opération");
            }
        }
        conn
    }

    fn request(kind: Kind) -> Request {
        Request {
            terms: kind.defaults(),
            wished_payment: 0,
            moved: Moved::Other,
            accounts: vec![1],
            history: History::Year(2025).into(),
            judging: Judging { chosen: Method::Neutral, growth: [0; 3] },
        }
    }

    #[test]
    fn la_fenetre_recoit_tout_ecrit() {
        let conn = database();
        let simulation = simulate(&conn, &request(Kind::Consumer), date(2026, 10, 8)).unwrap();
        let written = write(&simulation, Language::French);
        assert_eq!(written.months, 48);
        assert_eq!(written.dues.len(), 48);
        assert_eq!(written.amount_field, "10000,00");
        assert_eq!(written.rate_field, "6,00");
        assert!(written.cost_donut.starts_with("<svg"));
        let analysis = written.analysis.expect("analyse");
        assert_eq!(analysis.verdict, "green");
        assert!(analysis.gauge.contains("gauge-needle"));
        assert_eq!(analysis.checks.len(), 3);
        assert!(analysis.checks.iter().all(|check| check.tone == "good" && !check.text.is_empty()));
        assert_eq!(analysis.warning, None);
        assert_eq!(analysis.figures.len(), 11);
    }

    /// **L'onglet « Réglages du jugement »** reçoit ses trois colonnes,
    /// écrites avec les chiffres de la personne, et la ligne des trois
    /// verdicts.
    #[test]
    fn les_trois_methodes_sont_ecrites_pour_l_onglet_des_reglages() {
        let conn = database();
        let mut asked = request(Kind::Consumer);
        asked.judging = Judging { chosen: Method::Severe, growth: [0, 2, 7] };
        let simulation = simulate(&conn, &asked, date(2026, 10, 8)).unwrap();
        let analysis = write(&simulation, Language::French).analysis.expect("analyse");
        assert_eq!(analysis.methods.len(), 3);
        assert!(analysis.methods.iter().all(|method| method.values.len() == 5));
        assert_eq!(analysis.rule_rows.len(), 6);
        assert_eq!(analysis.methods[2].growth, 7);
        assert_eq!(analysis.methods[0].name, "Optimiste");
        assert_eq!(analysis.method_line, "Méthode de jugement : Sévère");
        assert_eq!(analysis.methods[1].values[0], "vert jusqu'à 33 %, orange jusqu'à 35 %");
        assert!(analysis.methods[2].values[3].starts_with("un mois de dépenses : "));
        assert_eq!(analysis.methods[0].values[3], "zéro");
        assert!(analysis.verdicts_line.starts_with("Optimiste : "));
        assert_eq!(analysis.verdicts_line.matches(" · ").count(), 2);
        // La méthode sévère a une réserve : sa phrase la nomme.
        assert!(analysis.checks[2].text.contains("réserve de sécurité"), "{}", analysis.checks[2].text);
    }

    #[test]
    fn sans_compte_coche_la_raison_est_dite() {
        let conn = database();
        let mut asked = request(Kind::Consumer);
        asked.accounts.clear();
        let simulation = simulate(&conn, &asked, date(2026, 10, 8)).unwrap();
        let written = write(&simulation, Language::French);
        assert_eq!(written.analysis, Err(i18n::text(Language::French, "loan-unavailable-no-account")));
    }

    /// **Le rapport se compose**, avec ses graphiques, et ne porte jamais le
    /// numéro d'un compte — seulement son nom.
    #[test]
    fn le_rapport_se_compose_sans_numero_de_compte() {
        let conn = database();
        for kind in Kind::ALL {
            let simulation = simulate(&conn, &request(kind), date(2026, 10, 8)).unwrap();
            for monthly in [false, true] {
                let bytes = pdf(&conn, &simulation, Language::French, monthly).expect("PDF");
                assert!(bytes.starts_with(b"%PDF"));
            }
        }
        let simulation = simulate(&conn, &request(Kind::Consumer), date(2026, 10, 8)).unwrap();
        let written = write(&simulation, Language::French);
        let everything = format!("{written:?}");
        assert!(!everything.contains("12345678901"));
        // Et sans analyse, le rapport se compose aussi.
        let mut asked = request(Kind::Consumer);
        asked.accounts.clear();
        let alone = simulate(&conn, &asked, date(2026, 10, 8)).unwrap();
        assert!(pdf(&conn, &alone, Language::English, false).is_ok());
    }
}
