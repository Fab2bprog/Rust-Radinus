//! Préparer mes vacances — F46 (Fabrice, 10/10/2026).
//!
//! « Le but, c'est simplement de calculer combien vont me coûter mes
//! prochaines vacances. » Un séjour ou une croisière (« ok »), des adultes et
//! des enfants (« oui »), des postes dont chacun se règle — pour tous ou par
//! personne, par nuit, par jour, par escale ou pour le séjour (« paramétrable »)
//! —, les lignes facultatives qu'on oublie toujours (« on garde tous »), et ce
//! qu'il faut mettre de côté d'ici le départ, après ce que les comptes cochés
//! portent déjà (« le solde d'un ou plusieurs comptes que l'on choisit »).
//!
//! **Rien n'est enregistré dans la base** : la fenêtre oublie à la fermeture
//! (« oui on oublie les chiffres »). Ce qui doit durer part dans un fichier :
//! un projet en JSON qu'on enregistre et qu'on rouvre (« ça évite de tout
//! retaper »), un rapport PDF, un classeur Excel.
//!
//! # Le calcul
//!
//! - « Par personne » : les adultes au prix tapé, les enfants au prix enfant
//!   s'il est donné — vide, ils paient comme un adulte ; 0, c'est gratuit.
//! - « Par nuit » multiplie par les nuits, « par jour » par les jours — les
//!   nuits plus une : sept nuits, huit jours —, « par escale » par les escales.
//! - La taxe de séjour ne compte que les adultes, par nuit.
//! - Les cabines d'une croisière : leur nombre × le prix d'une cabine.
//! - L'assurance annulation, en pourcent, porte sur les postes principaux du
//!   voyage ; les frais bancaires à l'étranger, sur les dépenses faites sur
//!   place.

use crate::i18n::{self, Language};
use crate::loan_charts::{self, Part};
use crate::money;
use crate::printing::{self, Failure};
use crate::sheets::{Sheet, SheetCell};

/// Le type de voyage.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Trip {
    Stay,
    Cruise,
}

impl Trip {
    pub fn key(self) -> &'static str {
        match self {
            Trip::Stay => "stay",
            Trip::Cruise => "cruise",
        }
    }
    pub fn from_key(key: &str) -> Trip {
        if key == "cruise" {
            Trip::Cruise
        } else {
            Trip::Stay
        }
    }
}

/// Pour qui un montant vaut.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Who {
    All,
    Person,
}

impl Who {
    pub fn key(self) -> &'static str {
        match self {
            Who::All => "all",
            Who::Person => "person",
        }
    }
}

/// Ce qu'un poste permet de dire de « pour qui ».
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum WhoRule {
    /// Pour tous, ou par personne.
    Choice(Who),
    /// Par adulte seulement : la taxe de séjour.
    Adults,
    /// Par cabine : un nombre de cabines × un prix.
    Cabins,
}

/// Pour combien de temps.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Span {
    Trip,
    Night,
    Day,
    Stop,
}

impl Span {
    pub fn key(self) -> &'static str {
        match self {
            Span::Trip => "trip",
            Span::Night => "night",
            Span::Day => "day",
            Span::Stop => "stop",
        }
    }
}

/// En quoi le montant se tape.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Unit {
    Amount,
    Percent,
}

impl Unit {
    pub fn key(self) -> &'static str {
        match self {
            Unit::Amount => "amount",
            Unit::Percent => "percent",
        }
    }
}

/// Sur quoi porte un pourcentage.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Base {
    /// Les postes principaux du voyage : l'assurance annulation.
    Main,
    /// Les dépenses faites sur place : les frais bancaires.
    OnSite,
}

/// **Un poste du budget.**
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Spec {
    pub key: &'static str,
    pub stay: bool,
    pub cruise: bool,
    pub optional: bool,
    pub who: WhoRule,
    /// Les durées offertes, la première par défaut.
    pub spans: &'static [Span],
    /// Les unités offertes, la première par défaut.
    pub units: &'static [Unit],
    /// Une dépense faite sur place : la base des frais bancaires.
    pub on_site: bool,
    /// Ce sur quoi porte son pourcentage, s'il en a un.
    pub base: Option<Base>,
}

const fn line(key: &'static str, stay: bool, cruise: bool, who: WhoRule, spans: &'static [Span], on_site: bool) -> Spec {
    Spec { key, stay, cruise, optional: false, who, spans, units: &[Unit::Amount], on_site, base: None }
}

const fn extra(key: &'static str, stay: bool, cruise: bool, who: WhoRule, spans: &'static [Span], on_site: bool) -> Spec {
    Spec { key, stay, cruise, optional: true, who, spans, units: &[Unit::Amount], on_site, base: None }
}

use Span::{Day, Night, Stop, Trip as Once};
use WhoRule::{Adults, Cabins, Choice};

/// **Les postes**, dans l'ordre où la fenêtre les montre : ceux du séjour,
/// ceux de la croisière, puis les lignes facultatives communes.
pub const SPECS: &[Spec] = &[
    line("transport", true, false, Choice(Who::Person), &[Once], false),
    line("lodging", true, false, Choice(Who::All), &[Night, Once], false),
    line("meals", true, false, Choice(Who::Person), &[Day, Once], true),
    line("visits", true, false, Choice(Who::Person), &[Once, Day], true),
    line("port", false, true, Choice(Who::Person), &[Once], false),
    line("cabins", false, true, Cabins, &[Once], false),
    line("service", false, true, Choice(Who::Person), &[Night, Once], false),
    line("drinks", false, true, Choice(Who::Person), &[Day, Once], true),
    line("excursions", false, true, Choice(Who::Person), &[Stop, Once], true),
    line("port-taxes", false, true, Choice(Who::Person), &[Once], false),
    line("wifi", false, true, Choice(Who::All), &[Day, Once], false),
    line("onboard", false, true, Choice(Who::All), &[Day, Once], true),
    line("other", true, true, Choice(Who::All), &[Once, Day], true),
    Spec {
        key: "insurance",
        stay: true,
        cruise: true,
        optional: true,
        who: Choice(Who::All),
        spans: &[Once],
        units: &[Unit::Percent, Unit::Amount],
        on_site: false,
        base: Some(Base::Main),
    },
    extra("stay-tax", true, false, Adults, &[Night], false),
    extra("car", true, true, Choice(Who::All), &[Day, Once], true),
    extra("parking", true, true, Choice(Who::All), &[Day, Once], false),
    Spec {
        key: "bank",
        stay: true,
        cruise: true,
        optional: true,
        who: Choice(Who::All),
        spans: &[Once],
        units: &[Unit::Percent],
        on_site: false,
        base: Some(Base::OnSite),
    },
    extra("formalities", true, true, Choice(Who::Person), &[Once], false),
    extra("pets", true, true, Choice(Who::All), &[Day, Once], false),
];

impl Spec {
    pub fn of(key: &str) -> Option<&'static Spec> {
        SPECS.iter().find(|spec| spec.key == key)
    }
    pub fn shown(&self, trip: Trip) -> bool {
        match trip {
            Trip::Stay => self.stay,
            Trip::Cruise => self.cruise,
        }
    }
}

/// Les bornes des curseurs et des champs.
pub const PEOPLE_LIMIT: u32 = 20;
pub const NIGHTS_LIMIT: u32 = 365;
pub const MONTHS_LIMIT: u32 = 120;
pub const STOPS_LIMIT: u32 = 60;
pub const CABINS_LIMIT: u32 = 20;

// --- Ce que la fenêtre envoie ---------------------------------------------------

/// Une ligne telle que tapée.
#[derive(Debug, Clone, Default, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
#[serde(default)]
pub struct LineInput {
    pub key: String,
    pub amount: String,
    pub child: String,
    pub who: String,
    pub span: String,
    pub unit: String,
    pub count: String,
}

/// **Le voyage tel que tapé** — les champs ne se lisent qu'ici.
#[derive(Debug, Clone, Default, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
#[serde(default)]
pub struct Input {
    pub trip: String,
    pub adults: u32,
    pub children: u32,
    pub nights: String,
    pub months: String,
    pub stops: String,
    pub lines: Vec<LineInput>,
}

/// Une ligne lue.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Line {
    pub spec: &'static Spec,
    /// Le montant en micro-unités, ou le pourcentage ; `None` si vide.
    pub amount: Option<f64>,
    pub child: Option<i64>,
    pub who: Who,
    pub span: Span,
    pub unit: Unit,
    pub count: u32,
}

/// Le voyage lu.
#[derive(Debug, Clone, PartialEq)]
pub struct Plan {
    pub trip: Trip,
    pub adults: u32,
    pub children: u32,
    pub nights: u32,
    pub months: u32,
    pub stops: u32,
    pub lines: Vec<Line>,
}

impl Plan {
    pub fn people(&self) -> u32 {
        self.adults + self.children
    }
    /// Les jours : les nuits plus une.
    pub fn days(&self) -> u32 {
        self.nights + 1
    }
}

/// Le champ qui empêche le calcul, et la clef de sa phrase.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Refusal {
    pub field: String,
    pub key: &'static str,
}

fn whole(text: &str, limit: u32, field: &str) -> Result<u32, Refusal> {
    if text.trim().is_empty() {
        return Ok(0);
    }
    crate::appliance::parse_number(text)
        .filter(|value| value.fract() == 0.0 && *value <= f64::from(limit))
        .map(|value| value as u32)
        .ok_or(Refusal { field: field.to_string(), key: "holiday-invalid-count" })
}

/// **Lit les champs.**
pub fn read(input: &Input) -> Result<Plan, Refusal> {
    let trip = Trip::from_key(&input.trip);
    let nights = whole(&input.nights, NIGHTS_LIMIT, "nights")?;
    let months = whole(&input.months, MONTHS_LIMIT, "months")?;
    let stops = whole(&input.stops, STOPS_LIMIT, "stops")?;
    let mut lines = Vec::new();
    for spec in SPECS {
        let typed = input.lines.iter().find(|line| line.key == spec.key);
        let empty = LineInput::default();
        let typed = typed.unwrap_or(&empty);
        let unit = spec
            .units
            .iter()
            .copied()
            .find(|unit| unit.key() == typed.unit)
            .unwrap_or(spec.units[0]);
        let amount = if typed.amount.trim().is_empty() {
            None
        } else {
            let refused = || Refusal { field: format!("amount-{}", spec.key), key: "holiday-invalid-amount" };
            Some(match unit {
                Unit::Percent => crate::appliance::parse_number(&typed.amount)
                    .filter(|percent| *percent <= 100.0)
                    .ok_or_else(refused)?,
                Unit::Amount => {
                    let micro = money::parse(&typed.amount).map_err(|_| refused())?;
                    if micro < 0 {
                        return Err(refused());
                    }
                    micro as f64
                }
            })
        };
        let child = if typed.child.trim().is_empty() {
            None
        } else {
            let micro = money::parse(&typed.child)
                .ok()
                .filter(|micro| *micro >= 0)
                .ok_or(Refusal { field: format!("child-{}", spec.key), key: "holiday-invalid-amount" })?;
            Some(micro)
        };
        let who = match spec.who {
            Choice(default) => {
                if typed.who == Who::All.key() {
                    Who::All
                } else if typed.who == Who::Person.key() {
                    Who::Person
                } else {
                    default
                }
            }
            Adults => Who::Person,
            Cabins => Who::All,
        };
        let span = spec.spans.iter().copied().find(|span| span.key() == typed.span).unwrap_or(spec.spans[0]);
        let count = if spec.who == Cabins {
            whole(&typed.count, CABINS_LIMIT, &format!("count-{}", spec.key))?
        } else {
            0
        };
        lines.push(Line { spec, amount, child, who, span, unit, count });
    }
    Ok(Plan {
        trip,
        adults: input.adults.clamp(1, PEOPLE_LIMIT),
        children: input.children.min(PEOPLE_LIMIT),
        nights,
        months,
        stops,
        lines,
    })
}

// --- Le calcul ------------------------------------------------------------------

/// Ce que coûte une ligne qui n'est pas un pourcentage, en micro-unités.
fn amount_cost(plan: &Plan, line: &Line) -> i64 {
    let Some(amount) = line.amount else {
        return 0;
    };
    let amount = amount.round() as i64;
    let people = match line.spec.who {
        Cabins => i64::from(line.count) * amount,
        Adults => i64::from(plan.adults) * amount,
        Choice(_) => match line.who {
            Who::All => amount,
            Who::Person => {
                i64::from(plan.adults) * amount + i64::from(plan.children) * line.child.unwrap_or(amount)
            }
        },
    };
    let times = match line.span {
        Span::Trip => 1,
        Span::Night => i64::from(plan.nights),
        Span::Day => i64::from(plan.days()),
        Span::Stop => i64::from(plan.stops),
    };
    people * times
}

/// **Le coût de chaque poste du voyage**, dans l'ordre des postes.
pub fn costs(plan: &Plan) -> Vec<(&'static Spec, i64)> {
    let shown: Vec<&Line> = plan.lines.iter().filter(|line| line.spec.shown(plan.trip)).collect();
    let mut out: Vec<(&'static Spec, i64)> = shown
        .iter()
        .map(|line| (line.spec, if line.unit == Unit::Percent { 0 } else { amount_cost(plan, line) }))
        .collect();
    let base_of = |base: Base, out: &[(&'static Spec, i64)]| -> i64 {
        out.iter()
            .filter(|(spec, _)| match base {
                Base::Main => !spec.optional,
                Base::OnSite => spec.on_site,
            })
            .map(|(_, cost)| cost)
            .sum()
    };
    for (rank, line) in shown.iter().enumerate() {
        if line.unit != Unit::Percent {
            continue;
        }
        let (Some(percent), Some(base)) = (line.amount, line.spec.base) else {
            continue;
        };
        out[rank].1 = (base_of(base, &out) as f64 * percent / 100.0).round() as i64;
    }
    out
}

/// **Les chiffres du voyage.**
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Totals {
    pub total: i64,
    pub per_person: i64,
    pub per_person_day: i64,
    pub saved: i64,
    pub remaining: i64,
    /// L'épargne par mois d'ici le départ ; `None` quand on part ce mois-ci.
    pub monthly: Option<i64>,
}

/// `saved` est ce que portent les comptes cochés ; un total négatif compte
/// pour rien.
pub fn totals(plan: &Plan, saved: i64) -> Totals {
    let total: i64 = costs(plan).iter().map(|(_, cost)| cost).sum();
    let per_person = total / i64::from(plan.people().max(1));
    let saved = saved.max(0);
    let remaining = (total - saved).max(0);
    Totals {
        total,
        per_person,
        per_person_day: per_person / i64::from(plan.days()),
        saved,
        remaining,
        monthly: (plan.months > 0).then(|| (remaining + i64::from(plan.months) - 1) / i64::from(plan.months)),
    }
}

// --- Ce que la fenêtre montre ---------------------------------------------------

/// Un poste tel que la fenêtre le propose : son nom, ses choix.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Offer {
    pub key: String,
    pub label: String,
}

#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct CatalogLine {
    pub key: String,
    pub label: String,
    pub stay: bool,
    pub cruise: bool,
    pub optional: bool,
    /// `choice`, `adults` ou `cabins`.
    pub who: String,
    pub default_who: String,
    pub spans: Vec<Offer>,
    pub units: Vec<Offer>,
}

/// **Le catalogue des postes**, écrit dans la langue : la fenêtre se bâtit
/// dessus, sans connaître un seul poste par son nom.
pub fn catalog(language: Language, sign: &str) -> Vec<CatalogLine> {
    let text = |key: &str| i18n::text(language, key);
    SPECS
        .iter()
        .map(|spec| CatalogLine {
            key: spec.key.to_string(),
            label: text(&format!("holiday-line-{}", spec.key)),
            stay: spec.stay,
            cruise: spec.cruise,
            optional: spec.optional,
            who: match spec.who {
                Choice(_) => "choice",
                Adults => "adults",
                Cabins => "cabins",
            }
            .to_string(),
            default_who: match spec.who {
                Choice(who) => who.key(),
                _ => "all",
            }
            .to_string(),
            spans: spec
                .spans
                .iter()
                .map(|span| Offer {
                    key: span.key().to_string(),
                    label: text(&format!("holiday-span-{}", span.key())),
                })
                .collect(),
            units: spec
                .units
                .iter()
                .map(|unit| Offer {
                    key: unit.key().to_string(),
                    label: match unit {
                        Unit::Amount => sign.to_string(),
                        Unit::Percent => "%".to_string(),
                    },
                })
                .collect(),
        })
        .collect()
}

#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Tile {
    pub label: String,
    pub value: String,
}

/// Le coût d'un poste, écrit.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Cost {
    pub key: String,
    pub cost: String,
    pub share: String,
    pub colour: String,
}

/// **Tout ce que la fenêtre affiche, déjà écrit.**
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Written {
    pub headline: String,
    pub tiles: Vec<Tile>,
    pub costs: Vec<Cost>,
    pub donut: String,
    pub days: String,
    pub notes: Vec<String>,
}

const COLOURS: [&str; 7] = [
    loan_charts::NAVY,
    loan_charts::GOLD,
    loan_charts::SKY,
    loan_charts::SLATE,
    loan_charts::SAND,
    loan_charts::GREEN,
    loan_charts::ORANGE,
];

fn share(part: i64, whole: i64, language: Language) -> String {
    if whole <= 0 || part <= 0 {
        return String::new();
    }
    let value = (part as f64 / whole as f64 * 100.0).round();
    i18n::message_of(language, "loan-percent", &[("value", &format!("{value:.0}"))], &[])
}

/// **Écrit le résultat.**
pub fn write(plan: &Plan, saved: i64, language: Language) -> Written {
    let text = |key: &str| i18n::text(language, key);
    let amount = |value: i64| money::format(value, language);
    let totals = totals(plan, saved);
    let costs = costs(plan);

    let headline = if totals.total == 0 {
        text("holiday-headline-empty")
    } else {
        i18n::message_of(
            language,
            if plan.trip == Trip::Cruise { "holiday-headline-cruise" } else { "holiday-headline-stay" },
            &[("total", &amount(totals.total))],
            &[("people", i64::from(plan.people())), ("nights", i64::from(plan.nights))],
        )
    };
    let tiles = vec![
        Tile { label: text("holiday-tile-person"), value: amount(totals.per_person) },
        Tile { label: text("holiday-tile-person-day"), value: amount(totals.per_person_day) },
        Tile { label: text("holiday-tile-saved"), value: amount(totals.saved) },
        Tile {
            label: text("holiday-tile-remaining"),
            value: if totals.remaining == 0 && totals.total > 0 {
                text("holiday-remaining-none")
            } else {
                amount(totals.remaining)
            },
        },
        Tile {
            label: text("holiday-tile-monthly"),
            value: match totals.monthly {
                _ if totals.remaining == 0 => text("holiday-monthly-none"),
                None => text("holiday-monthly-now"),
                Some(monthly) => i18n::message_of(
                    language,
                    "goal-per-month",
                    &[("amount", &amount(monthly))],
                    &[],
                ),
            },
        },
    ];

    let mut colour = COLOURS.iter().cycle();
    let mut written_costs = Vec::new();
    let mut parts = Vec::new();
    for (spec, cost) in &costs {
        let paint = if *cost > 0 { *colour.next().unwrap_or(&loan_charts::NAVY) } else { "" };
        written_costs.push(Cost {
            key: spec.key.to_string(),
            cost: if *cost > 0 { amount(*cost) } else { String::new() },
            share: share(*cost, totals.total, language),
            colour: paint.to_string(),
        });
        if *cost > 0 {
            parts.push(Part {
                label: text(&format!("holiday-line-{}", spec.key)),
                amount: *cost,
                written: amount(*cost),
                colour: paint,
            });
        }
    }
    let donut = loan_charts::donut(&parts, &amount(totals.total), &text("holiday-donut-caption"));

    let mut notes = vec![text("holiday-note-days"), text("holiday-note-child")];
    if plan.lines.iter().any(|line| line.spec.base.is_some() && line.unit == Unit::Percent && line.amount.is_some()) {
        notes.push(text("holiday-note-percent"));
    }

    Written {
        headline,
        tiles,
        costs: written_costs,
        donut,
        days: i18n::message_of(language, "holiday-days", &[], &[("days", i64::from(plan.days()))]),
        notes,
    }
}

// --- Le projet en fichier -------------------------------------------------------

/// Ce qui dit, en tête du fichier, qu'il s'agit d'un projet de vacances.
pub const FILE_MARK: &str = "radinus-projet-vacances";
/// La version du format. Un fichier plus ancien s'ouvre ; un plus récent est
/// refusé : il pourrait porter ce que cette version ne sait pas lire.
pub const FILE_VERSION: u32 = 1;

#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
struct FileLine {
    key: String,
    /// Le montant, écrit à la façon neutre : « 1250.5 », jamais « 1 250,50 ».
    #[serde(default)]
    amount: Option<f64>,
    #[serde(default)]
    child: Option<f64>,
    who: String,
    span: String,
    unit: String,
    #[serde(default)]
    count: u32,
}

#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
struct File {
    format: String,
    version: u32,
    trip: String,
    adults: u32,
    children: u32,
    nights: u32,
    months: u32,
    #[serde(default)]
    stops: u32,
    lines: Vec<FileLine>,
    /// Les comptes cochés, par leur libellé seul : Radinus les recoche à
    /// l'ouverture s'il les retrouve (Fabrice : « on laisse coché »). Jamais
    /// leur solde, qui change, ni leur numéro.
    #[serde(default)]
    accounts: Vec<String>,
}

/// **Le projet en JSON**, à partir du voyage lu : les montants y sont
/// neutres, si bien qu'un fichier écrit en français se rouvre en anglais.
pub fn to_file(plan: &Plan, accounts: &[String]) -> String {
    let unit = money::UNIT as f64;
    let file = File {
        format: FILE_MARK.to_string(),
        version: FILE_VERSION,
        trip: plan.trip.key().to_string(),
        adults: plan.adults,
        children: plan.children,
        nights: plan.nights,
        months: plan.months,
        stops: plan.stops,
        lines: plan
            .lines
            .iter()
            .map(|line| FileLine {
                key: line.spec.key.to_string(),
                amount: line.amount.map(|value| match line.unit {
                    Unit::Amount => value / unit,
                    Unit::Percent => value,
                }),
                child: line.child.map(|value| value as f64 / unit),
                who: line.who.key().to_string(),
                span: line.span.key().to_string(),
                unit: line.unit.key().to_string(),
                count: line.count,
            })
            .collect(),
        accounts: accounts.to_vec(),
    };
    serde_json::to_string_pretty(&file).unwrap_or_default()
}

/// Pourquoi un fichier ne s'ouvre pas.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FileRefusal {
    /// Ce n'est pas du JSON, ou pas un projet de vacances.
    NotAProject,
    /// Un projet d'une version plus récente de Radinus.
    TooRecent,
}

impl FileRefusal {
    pub fn key(self) -> &'static str {
        match self {
            FileRefusal::NotAProject => "holiday-file-not-project",
            FileRefusal::TooRecent => "holiday-file-too-recent",
        }
    }
}

/// **Rouvre un projet** : les champs tels que la fenêtre les montre, dans la
/// langue en cours, et les libellés des comptes à recocher. Un poste inconnu
/// est ignoré ; un poste absent reste vide.
pub fn from_file(text: &str, language: Language) -> Result<(Input, Vec<String>), FileRefusal> {
    let file: File = serde_json::from_str(text).map_err(|_| FileRefusal::NotAProject)?;
    if file.format != FILE_MARK {
        return Err(FileRefusal::NotAProject);
    }
    if file.version > FILE_VERSION {
        return Err(FileRefusal::TooRecent);
    }
    let money_field = |value: f64| money::format_plain((value * money::UNIT as f64).round() as i64, language);
    let number_field = |value: f64| {
        let decimals = if value.fract() == 0.0 { 0 } else { 2 };
        crate::appliance::decimal(value, decimals, language)
    };
    let field = |value: u32| if value == 0 { String::new() } else { value.to_string() };
    let lines = file
        .lines
        .iter()
        .filter(|line| Spec::of(&line.key).is_some())
        .map(|line| LineInput {
            key: line.key.clone(),
            amount: line
                .amount
                .map(|value| if line.unit == Unit::Percent.key() { number_field(value) } else { money_field(value) })
                .unwrap_or_default(),
            child: line.child.map(money_field).unwrap_or_default(),
            who: line.who.clone(),
            span: line.span.clone(),
            unit: line.unit.clone(),
            count: field(line.count),
        })
        .collect();
    Ok((
        Input {
            trip: file.trip,
            adults: file.adults.clamp(1, PEOPLE_LIMIT),
            children: file.children.min(PEOPLE_LIMIT),
            nights: field(file.nights),
            months: file.months.to_string(),
            stops: field(file.stops),
            lines,
        },
        file.accounts,
    ))
}

// --- Le rapport PDF et le classeur ----------------------------------------------

/// Une ligne du budget telle que le rapport et le classeur l'écrivent : le
/// poste, le montant tapé, le prix enfant, pour qui, pour combien de temps, et
/// le coût.
fn rows(plan: &Plan, language: Language) -> Vec<[String; 6]> {
    let text = |key: &str| i18n::text(language, key);
    let costs = costs(plan);
    plan.lines
        .iter()
        .filter(|line| line.spec.shown(plan.trip) && line.amount.is_some())
        .map(|line| {
            let cost = costs.iter().find(|(spec, _)| spec.key == line.spec.key).map_or(0, |(_, cost)| *cost);
            let typed = match (line.unit, line.amount) {
                (Unit::Percent, Some(percent)) => i18n::message_of(
                    language,
                    "loan-percent",
                    &[("value", &crate::appliance::decimal(percent, if percent.fract() == 0.0 { 0 } else { 2 }, language))],
                    &[],
                ),
                (Unit::Amount, Some(value)) => money::format(value.round() as i64, language),
                _ => String::new(),
            };
            let who = match line.spec.who {
                Cabins => i18n::message_of(language, "holiday-cabins-count", &[], &[("count", i64::from(line.count))]),
                Adults => text("holiday-who-adults"),
                Choice(_) if line.unit == Unit::Percent => String::new(),
                Choice(_) => text(&format!("holiday-who-{}", line.who.key())),
            };
            let span = if line.unit == Unit::Percent { String::new() } else { text(&format!("holiday-span-{}", line.span.key())) };
            [
                text(&format!("holiday-line-{}", line.spec.key)),
                typed,
                line.child.map(|child| money::format(child, language)).unwrap_or_default(),
                who,
                span,
                money::format(cost, language),
            ]
        })
        .collect()
}

/// Le voyage en quelques couples : le type, les voyageurs, la durée, le départ.
fn trip_pairs(plan: &Plan, accounts: &[String], language: Language) -> Vec<(String, String)> {
    let text = |key: &str| i18n::text(language, key);
    let mut pairs = vec![
        (text("holiday-field-trip"), text(&format!("holiday-trip-{}", plan.trip.key()))),
        (text("holiday-field-adults"), plan.adults.to_string()),
        (text("holiday-field-children"), plan.children.to_string()),
        (text("holiday-field-nights"), plan.nights.to_string()),
        (text("holiday-field-days"), plan.days().to_string()),
        (text("holiday-field-months"), plan.months.to_string()),
    ];
    if plan.trip == Trip::Cruise {
        pairs.push((text("holiday-field-stops"), plan.stops.to_string()));
    }
    if !accounts.is_empty() {
        pairs.push((text("holiday-saved-title"), accounts.join(", ")));
    }
    pairs
}

fn result_pairs(plan: &Plan, saved: i64, language: Language) -> Vec<(String, String)> {
    let written = write(plan, saved, language);
    let totals = totals(plan, saved);
    std::iter::once((i18n::text(language, "holiday-tile-total"), money::format(totals.total, language)))
        .chain(written.tiles.into_iter().map(|tile| (tile.label, tile.value)))
        .collect()
}

/// **Le classeur** : « Budget », une ligne par poste ; « Résultat », le voyage
/// et ses chiffres. Des valeurs, pas des formules.
pub fn book(plan: &Plan, saved: i64, accounts: &[String], language: Language) -> Vec<Sheet> {
    let text = |key: &str| i18n::text(language, key);
    let mut budget = Sheet::new(text("holiday-sheet-budget"));
    budget.header_rows = 1;
    budget.widths = vec![34.0, 14.0, 14.0, 18.0, 18.0, 14.0];
    budget.rows.push(
        [
            "holiday-column-line",
            "holiday-column-amount",
            "holiday-column-child",
            "holiday-column-who",
            "holiday-column-span",
            "holiday-column-cost",
        ]
        .iter()
        .map(|key| SheetCell::text(text(key)).with_bold(true))
        .collect(),
    );
    let costs = costs(plan);
    for (rank, row) in rows(plan, language).into_iter().enumerate() {
        let key = plan
            .lines
            .iter()
            .filter(|line| line.spec.shown(plan.trip) && line.amount.is_some())
            .nth(rank)
            .map(|line| line.spec.key)
            .unwrap_or_default();
        let cost = costs.iter().find(|(spec, _)| spec.key == key).map_or(0, |(_, cost)| *cost);
        let mut cells: Vec<SheetCell> = row[..5].iter().map(|value| SheetCell::text(value.clone())).collect();
        cells.push(SheetCell::money(cost));
        budget.rows.push(cells);
    }
    let total: i64 = costs.iter().map(|(_, cost)| cost).sum();
    budget.rows.push(vec![
        SheetCell::text(text("holiday-tile-total")).with_bold(true),
        SheetCell::empty(),
        SheetCell::empty(),
        SheetCell::empty(),
        SheetCell::empty(),
        SheetCell::money(total).with_bold(true),
    ]);

    let mut result = Sheet::new(text("holiday-sheet-result"));
    result.widths = vec![34.0, 30.0];
    for (name, value) in trip_pairs(plan, accounts, language)
        .into_iter()
        .chain(result_pairs(plan, saved, language))
    {
        result.rows.push(vec![SheetCell::text(name), SheetCell::text(value)]);
    }
    vec![budget, result]
}

/// **Le rapport PDF** : le voyage, les chiffres, l'anneau et le budget poste
/// par poste — de quoi tout ressaisir plus tard.
pub fn pdf(plan: &Plan, saved: i64, accounts: &[String], language: Language) -> std::result::Result<Vec<u8>, Failure> {
    let written = write(plan, saved, language);
    let text = |key: &str| i18n::text(language, key);
    let q = |value: &str| printing::quoted(value);
    let mut out = String::new();
    for (name, value) in [
        ("famille", printing::FAMILY.to_string()),
        ("langue", language.tag().to_string()),
        ("logo", printing::LOGO_PATH.to_string()),
        ("titre", text("window-holiday-title")),
        ("sous-titre", text(&format!("holiday-trip-{}", plan.trip.key()))),
        ("avertissement", text("holiday-disclaimer")),
        ("titre-voyage", text("holiday-trip-title")),
        ("titre-resultat", text("holiday-result-title")),
        ("titre-budget", text("holiday-budget-title")),
        ("titre-anneau", text("holiday-donut-title")),
        ("phrase", written.headline.clone()),
        ("anneau-svg", written.donut.clone()),
    ] {
        out.push_str(&format!("#let {name} = {}\n", q(&value)));
    }
    out.push_str("#let voyage = (\n");
    for (name, value) in trip_pairs(plan, accounts, language) {
        out.push_str(&format!("  ({}, {}),\n", q(&name), q(&value)));
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
        "#let colonnes = ({}, {}, {}, {}, {}, {})\n",
        q(&text("holiday-column-line")),
        q(&text("holiday-column-amount")),
        q(&text("holiday-column-child")),
        q(&text("holiday-column-who")),
        q(&text("holiday-column-span")),
        q(&text("holiday-column-cost")),
    ));
    out.push_str("#let lignes = (\n");
    for row in rows(plan, language) {
        out.push_str(&format!(
            "  ({}, {}, {}, {}, {}, {}),\n",
            q(&row[0]),
            q(&row[1]),
            q(&row[2]),
            q(&row[3]),
            q(&row[4]),
            q(&row[5])
        ));
    }
    out.push_str(")\n");
    let total = totals(plan, saved).total;
    out.push_str(&format!(
        "#let total = ({}, {})\n",
        q(&text("holiday-tile-total")),
        q(&money::format(total, language))
    ));
    out.push_str(TEMPLATE);
    printing::compose(out, "radinus-vacances")
}

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
    text(size: 13pt, weight: "bold", fill: nuit, valeur)
  },
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

#titre-section(titre-voyage)
#table(columns: (auto, 1fr), stroke: none, inset: (x: 0pt, y: 3.5pt), column-gutter: 14pt,
  ..voyage.map(c => (text(fill: gris, c.at(0)), text(weight: "bold", c.at(1)))).flatten())

#titre-section(titre-resultat)
#block(width: 100%, fill: fond, radius: (right: 6pt), stroke: (left: 5pt + dore), inset: (x: 14pt, y: 10pt),
  text(size: 12pt, weight: "bold", fill: nuit, phrase))
#v(6pt)
#grid(columns: (1fr, 1fr, 1fr), column-gutter: 8pt, row-gutter: 8pt,
  ..tuiles.map(t => tuile(t.at(0), t.at(1))))

#titre-section(titre-budget)
#table(
  columns: (1fr, auto, auto, auto, auto, auto),
  stroke: none,
  inset: (x: 6pt, y: 4pt),
  align: (x, y) => if x == 0 { left } else if x == 3 or x == 4 { left } else { right },
  fill: (x, y) => if y == 0 { nuit } else if calc.even(y) { fond } else { white },
  table.header(..colonnes.map(c => text(fill: white, weight: "bold", c))),
  ..lignes.flatten(),
  table.cell(colspan: 5, text(weight: "bold", total.at(0))), text(weight: "bold", fill: nuit, total.at(1)),
)

#v(10pt)
#block(width: 100%, stroke: 0.6pt + filet, radius: 6pt, inset: 12pt, breakable: false, {
  text(size: 10pt, weight: "bold", fill: nuit, titre-anneau)
  v(6pt)
  align(center, svg(anneau-svg, 330pt))
})
#v(6pt)
#block({
  set text(size: 8pt, fill: gris)
  for note in notes { [• #note]; linebreak() }
})
"##;

#[cfg(test)]
mod tests {
    use super::*;

    const EURO: i64 = money::UNIT;

    fn typed(key: &str, amount: &str, who: &str, span: &str) -> LineInput {
        LineInput {
            key: key.into(),
            amount: amount.into(),
            who: who.into(),
            span: span.into(),
            ..LineInput::default()
        }
    }

    fn stay() -> Input {
        Input {
            trip: "stay".into(),
            adults: 2,
            children: 1,
            nights: "7".into(),
            months: "6".into(),
            stops: String::new(),
            lines: vec![
                LineInput { child: "50".into(), ..typed("transport", "120", "person", "trip") },
                typed("lodging", "90", "all", "night"),
                LineInput { child: "10".into(), ..typed("meals", "30", "person", "day") },
                typed("visits", "200", "all", "trip"),
                LineInput { unit: "percent".into(), ..typed("insurance", "4", "", "") },
                typed("stay-tax", "1,5", "", ""),
            ],
        }
    }

    /// **Le calcul**, ligne par ligne.
    #[test]
    fn le_sejour_se_calcule_ligne_par_ligne() {
        let plan = read(&stay()).unwrap();
        assert_eq!(plan.days(), 8);
        let costs: Vec<(&str, i64)> = costs(&plan).iter().map(|(spec, cost)| (spec.key, *cost)).collect();
        let cost = |key: &str| costs.iter().find(|(k, _)| *k == key).unwrap().1;
        // 2 adultes × 120 + 1 enfant × 50.
        assert_eq!(cost("transport"), 290 * EURO);
        // 90 € la nuit, 7 nuits.
        assert_eq!(cost("lodging"), 630 * EURO);
        // (2 × 30 + 10) × 8 jours.
        assert_eq!(cost("meals"), 560 * EURO);
        assert_eq!(cost("visits"), 200 * EURO);
        // 4 % des postes principaux : 290 + 630 + 560 + 200.
        assert_eq!(cost("insurance"), 67_200_000);
        // 1,50 € par adulte et par nuit.
        assert_eq!(cost("stay-tax"), 21 * EURO);
        // La croisière n'a pas de place dans un séjour.
        assert!(costs.iter().all(|(key, _)| *key != "cabins"));
    }

    #[test]
    fn les_chiffres_et_le_reste_a_financer() {
        let plan = read(&stay()).unwrap();
        let totals = totals(&plan, 800 * EURO);
        assert_eq!(totals.total, 1_768_200_000);
        assert_eq!(totals.per_person, 589_400_000);
        assert_eq!(totals.per_person_day, 73_675_000);
        assert_eq!(totals.remaining, 968_200_000);
        // Arrondi au centime supérieur : on ne finit pas à court.
        assert_eq!(totals.monthly, Some(161_366_667));
        let covered = totals_of(&plan, 5_000 * EURO);
        assert_eq!(covered.remaining, 0);
        let now = read(&Input { months: "0".into(), ..stay() }).unwrap();
        assert_eq!(super::totals(&now, 0).monthly, None);
        assert_eq!(super::totals(&plan, -300 * EURO).saved, 0);
    }

    fn totals_of(plan: &Plan, saved: i64) -> Totals {
        totals(plan, saved)
    }

    #[test]
    fn la_croisiere_a_ses_postes() {
        let input = Input {
            trip: "cruise".into(),
            adults: 2,
            children: 0,
            nights: "7".into(),
            months: "3".into(),
            stops: "5".into(),
            lines: vec![
                LineInput { count: "1".into(), ..typed("cabins", "2400", "", "") },
                typed("service", "14", "person", "night"),
                typed("excursions", "60", "person", "stop"),
                typed("lodging", "999", "all", "night"),
            ],
        };
        let plan = read(&input).unwrap();
        let costs: Vec<(&str, i64)> = costs(&plan).iter().map(|(spec, cost)| (spec.key, *cost)).collect();
        let cost = |key: &str| costs.iter().find(|(k, _)| *k == key).map(|(_, cost)| *cost);
        assert_eq!(cost("cabins"), Some(2_400 * EURO));
        assert_eq!(cost("service"), Some(196 * EURO));
        assert_eq!(cost("excursions"), Some(600 * EURO));
        // L'hébergement d'un séjour n'entre pas dans une croisière.
        assert_eq!(cost("lodging"), None);
        assert_eq!(cost("stay-tax"), None);
    }

    #[test]
    fn les_champs_illisibles_sont_refuses() {
        let mut input = stay();
        input.lines[0].amount = "cent".into();
        assert_eq!(read(&input).unwrap_err().field, "amount-transport");
        let mut input = stay();
        input.nights = "7,5".into();
        assert_eq!(read(&input).unwrap_err().field, "nights");
        let mut input = stay();
        input.lines[4].amount = "140".into();
        assert_eq!(read(&input).unwrap_err().field, "amount-insurance");
        let mut input = stay();
        input.lines[2].child = "-3".into();
        assert_eq!(read(&input).unwrap_err().field, "child-meals");
    }

    /// **Le projet en fichier** : enregistré en français, rouvert en anglais,
    /// il donne le même voyage.
    #[test]
    fn le_projet_se_relit_dans_une_autre_langue() {
        let plan = read(&stay()).unwrap();
        let text = to_file(&plan, &["Livret vacances".to_string()]);
        assert!(text.contains("\"amount\": 120.0"), "{text}");
        let (input, accounts) = from_file(&text, Language::English).unwrap();
        assert_eq!(accounts, vec!["Livret vacances".to_string()]);
        let transport = input.lines.iter().find(|line| line.key == "transport").unwrap();
        assert_eq!(transport.amount, "120.00");
        let tax = input.lines.iter().find(|line| line.key == "stay-tax").unwrap();
        assert_eq!(tax.amount, "1.50");
        assert_eq!(read(&input).unwrap(), plan);
        assert_eq!(from_file("{}", Language::French), Err(FileRefusal::NotAProject));
        assert_eq!(from_file("pas du json", Language::French), Err(FileRefusal::NotAProject));
        let newer = text.replace("\"version\": 1", "\"version\": 9");
        assert_eq!(from_file(&newer, Language::French), Err(FileRefusal::TooRecent));
    }

    #[test]
    fn le_resultat_le_classeur_et_le_rapport() {
        let plan = read(&stay()).unwrap();
        let written = write(&plan, 800 * EURO, Language::French);
        assert!(written.headline.contains("3 personnes"), "{}", written.headline);
        assert_eq!(written.tiles.len(), 5);
        assert!(written.donut.contains("<svg"));
        let book = book(&plan, 800 * EURO, &["Livret".into()], Language::French);
        assert_eq!(book.len(), 2);
        assert_eq!(book[0].rows.len(), 1 + 6 + 1);
        let bytes = pdf(&plan, 800 * EURO, &["Livret".into()], Language::French).expect("le rapport");
        assert!(bytes.starts_with(b"%PDF"));
        let catalog = catalog(Language::French, "€");
        assert_eq!(catalog.len(), SPECS.len());
        assert!(catalog.iter().all(|line| !line.label.starts_with("holiday-")));
    }
}
