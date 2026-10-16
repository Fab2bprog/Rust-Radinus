//! La simulation de crédit — F41 (Fabrice, 08/10/2026).
//!
//! Deux questions, deux moitiés de ce module.
//!
//! **Combien coûte ce crédit ?** Le calcul classique du prêt à taux fixe et à
//! mensualités constantes — le seul que Radinus simule : « ok, donc on reste
//! sur du fixe ». Cinq saisies (le montant, le taux, la durée en mois, les
//! frais de dossier, l'assurance par mois) et tout le reste s'en déduit : la
//! mensualité, le tableau d'amortissement, le coût, le TAEG.
//!
//! **Puis-je le rembourser ?** Ce que l'historique de la base dit des moyens
//! de la personne, mis en regard de la mensualité. Fabrice : « je veux que
//! lorsqu'elle calcule son crédit il y ait des éléments d'information qui lui
//! permettent de réfléchir pour savoir si c'est jouable ou pas et dans quelle
//! mesure ». Et pour la méthode : « tu calcules avec ce que tu as comme tu
//! peux. Il faudra me dire ta méthode. » Elle est écrite ici, fonction par
//! fonction, et redite à `docs/Decisions.md` P-58.
//!
//! # Les conventions du calcul
//!
//! - **Le taux mensuel est le taux annuel divisé par douze** — le taux
//!   proportionnel, celui des offres françaises de crédit à la consommation.
//! - **Les frais de dossier sont financés** : ajoutés au capital emprunté,
//!   remboursés avec lui. C'est ce que fait la simulation de La Banque
//!   Postale que Fabrice a apportée le 08/10/2026 : 12 000 € plus 120 € de
//!   frais, à 6,41 % sur 22 mois, donnent ses 585,36 € à deux centimes près.
//!   Les deux centimes viennent de la première échéance, qu'elle compte « à
//!   30 jours » sur une année de 365 ; Radinus compte des mois entiers. Une
//!   simulation est indicative, et les conventions de chaque banque le sont
//!   aussi.
//! - **Chaque mensualité se coupe au centime** : les intérêts du mois sont
//!   arrondis, le capital remboursé est le reste, et **la dernière mensualité
//!   solde le compte** — elle est de quelques centimes différente des autres,
//!   comme dans un vrai tableau d'amortissement.
//! - **Le TAEG est actuariel** : le taux mensuel qui égale ce que la personne
//!   reçoit à ce qu'elle rembourse, porté à l'année par capitalisation. Il
//!   compte les intérêts et les frais ; l'assurance, facultative ici comme
//!   sur l'offre de Fabrice, en reste dehors.
//!
//! **Tous les montants sont en micro-unités**, comme partout dans Radinus. Le
//! taux aussi : 6,41 % s'écrit `6_410_000`, ce qui permet de le lire et de
//! l'écrire avec les mêmes fonctions qu'un montant.

use crate::domain::NaiveDate;
use crate::recurring_operations::{self, Ending, Unit};
use rusqlite::{Connection, Result};
use std::collections::HashMap;
use time_compute::{Datelike, Days, Months};

/// Un euro, en micro-unités.
pub const EURO: i64 = crate::money::UNIT;
/// Un centime.
pub const CENT: i64 = EURO / 100;

/// **La limite des champs texte** (Fabrice, 08/10/2026 : « plutôt à 100
/// millions d'euros la limite »). Celle des curseurs est bien plus basse et
/// dépend du type de crédit : « la limite des curseurs n'est pas la limite des
/// champs textes ».
pub const AMOUNT_LIMIT: i64 = 100_000_000 * EURO;
/// Six cents mois, cinquante ans : la limite de sécurité de la durée.
pub const MONTHS_LIMIT: u32 = 600;
/// Cent pour cent : au-delà, ce n'est plus un taux qu'une banque propose.
pub const RATE_LIMIT: i64 = 100 * EURO;

// ---------------------------------------------------------------------------
// Le type de crédit
// ---------------------------------------------------------------------------

/// **Consommation ou immobilier**, au choix d'un menu déroulant (Fabrice,
/// 08/10/2026 : « on pourrait mettre les deux via un choix sur menu
/// déroulant »). Le type ne change pas le calcul ; il change les bornes des
/// curseurs, les valeurs de départ, et la façon dont le rapport imprime le
/// tableau.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Kind {
    Consumer,
    Mortgage,
}

/// Ce que les trois curseurs couvrent. Les champs texte vont au-delà, jusqu'aux
/// limites de sécurité ; le curseur reste alors en butée.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Bounds {
    pub amount_min: i64,
    pub amount_max: i64,
    pub amount_step: i64,
    pub months_min: u32,
    pub months_max: u32,
}

impl Kind {
    pub const ALL: [Kind; 2] = [Kind::Consumer, Kind::Mortgage];

    pub fn key(self) -> &'static str {
        match self {
            Kind::Consumer => "consumer",
            Kind::Mortgage => "mortgage",
        }
    }

    pub fn from_key(key: &str) -> Kind {
        match key {
            "mortgage" => Kind::Mortgage,
            _ => Kind::Consumer,
        }
    }

    /// **Pour l'immobilier, le curseur va jusqu'à 500 000 €** (Fabrice,
    /// 08/10/2026), sur trente ans. La consommation s'arrête où s'arrête le
    /// crédit à la consommation en France : 75 000 €, sept ans.
    pub fn bounds(self) -> Bounds {
        match self {
            Kind::Consumer => Bounds {
                amount_min: 500 * EURO,
                amount_max: 75_000 * EURO,
                amount_step: 100 * EURO,
                months_min: 6,
                months_max: 84,
            },
            Kind::Mortgage => Bounds {
                amount_min: 10_000 * EURO,
                amount_max: 500_000 * EURO,
                amount_step: 1_000 * EURO,
                months_min: 12,
                months_max: 360,
            },
        }
    }

    /// Les valeurs de départ : un crédit plausible, pour que la fenêtre ne
    /// s'ouvre pas sur des zéros. Changer de type y ramène.
    pub fn defaults(self) -> Terms {
        match self {
            Kind::Consumer => Terms {
                kind: self,
                amount: 10_000 * EURO,
                rate: 6 * EURO,
                months: 48,
                fees: 0,
                insurance: 0,
            },
            Kind::Mortgage => Terms {
                kind: self,
                amount: 200_000 * EURO,
                rate: 3_500_000,
                months: 240,
                fees: 0,
                insurance: 0,
            },
        }
    }
}

// ---------------------------------------------------------------------------
// Le calcul du crédit
// ---------------------------------------------------------------------------

/// Les cinq saisies, et le type.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Terms {
    pub kind: Kind,
    /// Le montant emprunté, celui que la personne reçoit.
    pub amount: i64,
    /// Le taux débiteur fixe, annuel, en micro-pourcents.
    pub rate: i64,
    /// La durée, **en mois** (Fabrice, 08/10/2026).
    pub months: u32,
    /// Les frais de dossier, ajoutés au capital.
    pub fees: i64,
    /// L'assurance, **en euros par mois**, à côté de la mensualité.
    pub insurance: i64,
}

impl Terms {
    /// Ce sur quoi les intérêts courent : le montant et les frais.
    pub fn principal(&self) -> i64 {
        self.amount + self.fees
    }

    fn monthly_rate(&self) -> f64 {
        self.rate as f64 / EURO as f64 / 100.0 / 12.0
    }

    /// Chaque saisie ramenée dans ses limites de sécurité.
    pub fn within_limits(mut self) -> Terms {
        self.amount = self.amount.clamp(EURO, AMOUNT_LIMIT);
        self.rate = self.rate.clamp(0, RATE_LIMIT);
        self.months = self.months.clamp(1, MONTHS_LIMIT);
        self.fees = self.fees.clamp(0, AMOUNT_LIMIT);
        self.insurance = self.insurance.clamp(0, AMOUNT_LIMIT);
        self
    }
}

/// Lequel des trois curseurs vient de bouger.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Moved {
    Amount,
    Payment,
    Months,
    /// Le taux, les frais, l'assurance ou le type.
    Other,
}

impl Moved {
    pub fn from_key(key: &str) -> Moved {
        match key {
            "amount" => Moved::Amount,
            "payment" => Moved::Payment,
            "months" => Moved::Months,
            _ => Moved::Other,
        }
    }
}

/// Le crédit une fois les trois curseurs mis d'accord.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Settled {
    pub terms: Terms,
    pub payment: i64,
    /// La clef Fluent de ce qui n'a pas pu être fait tel que demandé, s'il y
    /// a lieu : une mensualité trop faible pour jamais rembourser.
    pub notice: Option<&'static str>,
}

fn round_to_cent(micro: f64) -> i64 {
    ((micro / CENT as f64).round() as i64) * CENT
}

/// **La mensualité constante**, arrondie au centime :
/// `C × t ÷ (1 − (1 + t)^−n)`, et `C ÷ n` à taux nul.
pub fn payment_for(principal: i64, rate: i64, months: u32) -> i64 {
    let months = months.max(1);
    let t = rate as f64 / EURO as f64 / 100.0 / 12.0;
    let c = principal as f64;
    let exact = if t <= 0.0 {
        c / f64::from(months)
    } else {
        c * t / (1.0 - (1.0 + t).powi(-(months as i32)))
    };
    round_to_cent(exact)
}

/// Combien de mois pour rembourser `principal` à `payment` par mois — **au
/// mois entier supérieur**, ou `None` si la mensualité ne couvre même pas les
/// intérêts du premier mois : la dette ne baisserait jamais.
pub fn months_for(principal: i64, rate: i64, payment: i64) -> Option<u32> {
    if payment <= 0 {
        return None;
    }
    let t = rate as f64 / EURO as f64 / 100.0 / 12.0;
    let c = principal as f64;
    let p = payment as f64;
    let exact = if t <= 0.0 {
        c / p
    } else {
        let left = 1.0 - c * t / p;
        if left <= 0.0 {
            return None;
        }
        -left.ln() / (1.0 + t).ln()
    };
    // Une poussière de calcul ne doit pas coûter un mois de plus : 48,000 001
    // mois, ce sont 48 mois.
    let months = (exact - 1e-9).ceil();
    if !months.is_finite() || months > f64::from(u32::MAX) {
        return None;
    }
    Some((months as u32).max(1))
}

/// **Les trois curseurs se mettent d'accord** (Fabrice, 08/10/2026 :
/// « lorsque l'on bouge un curseur l'autre bouge automatiquement »).
///
/// La règle, acceptée par lui le même jour :
///
/// - le montant ou la durée bougent → **la mensualité se recalcule** ;
/// - la mensualité bouge → **la durée se recalcule**, arrondie au mois
///   entier, **puis la mensualité se réajuste** sur cette durée ronde — on ne
///   peut pas rembourser en 47,3 mois ;
/// - le taux, les frais, l'assurance ou le type bougent → la mensualité se
///   recalcule, comme pour le montant.
///
/// Une mensualité trop faible pour jamais rembourser, ou qui demanderait plus
/// de six cents mois, laisse la durée à sa limite et le dit.
pub fn settle(asked: Terms, wished_payment: i64, moved: Moved) -> Settled {
    let mut terms = asked.within_limits();
    let mut notice = None;
    if moved == Moved::Payment {
        match months_for(terms.principal(), terms.rate, wished_payment) {
            Some(months) if months <= MONTHS_LIMIT => terms.months = months,
            Some(_) => {
                terms.months = MONTHS_LIMIT;
                notice = Some("loan-notice-too-long");
            }
            None => {
                terms.months = MONTHS_LIMIT;
                notice = Some("loan-notice-payment-too-low");
            }
        }
    }
    Settled {
        terms,
        payment: payment_for(terms.principal(), terms.rate, terms.months),
        notice,
    }
}

/// Ce que couvre le curseur de la mensualité : la plus petite, sur la durée
/// la plus longue du curseur des mois, et la plus grande, sur la plus courte.
/// Il suit le montant : sur 500 € ou sur 75 000 €, ce ne sont pas les mêmes.
pub fn payment_range(terms: &Terms) -> (i64, i64) {
    let bounds = terms.kind.bounds();
    (
        payment_for(terms.principal(), terms.rate, bounds.months_max),
        payment_for(terms.principal(), terms.rate, bounds.months_min),
    )
}

/// Une ligne du tableau d'amortissement.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Due {
    pub number: u32,
    pub date: NaiveDate,
    /// La mensualité, assurance non comprise.
    pub payment: i64,
    pub interest: i64,
    pub capital: i64,
    pub insurance: i64,
    /// Ce qui reste dû **après** cette échéance.
    pub remaining: i64,
}

/// **Le tableau d'amortissement**, une ligne par mois.
///
/// Les intérêts du mois sont ceux du capital restant, arrondis au centime ; le
/// capital remboursé est le reste de la mensualité. La dernière échéance rend
/// exactement ce qui reste : la dette tombe à zéro, pas à trois centimes.
///
/// `first_due` est la date de la première échéance ; les suivantes tombent le
/// même quantième des mois suivants, comptées depuis elle — le 31 janvier
/// donne le 28 février puis le 31 mars, comme les opérations périodiques.
pub fn schedule(terms: &Terms, payment: i64, first_due: NaiveDate) -> Vec<Due> {
    let t = terms.monthly_rate();
    let mut remaining = terms.principal();
    let mut dues = Vec::with_capacity(terms.months as usize);
    for number in 1..=terms.months {
        let interest = round_to_cent(remaining as f64 * t);
        let mut capital = payment - interest;
        if number == terms.months || capital > remaining {
            capital = remaining;
        }
        remaining -= capital;
        let date = first_due
            .checked_add_months(Months::new(number - 1))
            .unwrap_or(first_due);
        dues.push(Due {
            number,
            date,
            payment: capital + interest,
            interest,
            capital,
            insurance: terms.insurance,
            remaining,
        });
    }
    dues
}

/// Ce que coûte le crédit, tout compté.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Summary {
    /// La mensualité, assurance non comprise.
    pub payment: i64,
    /// La même, assurance comprise : ce qui sort du compte chaque mois.
    pub payment_with_insurance: i64,
    /// Le capital emprunté, frais compris.
    pub principal: i64,
    /// Tout ce qui est remboursé, hors assurance — « le montant total dû ».
    pub total_due: i64,
    pub interest: i64,
    pub fees: i64,
    pub insurance_total: i64,
    /// Ce que le crédit coûte de plus que ce qu'on a reçu : les intérêts, les
    /// frais et l'assurance.
    pub cost: i64,
    /// Tout ce qui sort du compte, assurance comprise.
    pub all_in: i64,
    /// Le TAEG, en pourcents. `None` si le calcul n'a pas de sens.
    pub taeg: Option<f64>,
}

pub fn summarise(terms: &Terms, payment: i64, dues: &[Due]) -> Summary {
    let total_due: i64 = dues.iter().map(|due| due.payment).sum();
    let interest: i64 = dues.iter().map(|due| due.interest).sum();
    let insurance_total = terms.insurance * dues.len() as i64;
    Summary {
        payment,
        payment_with_insurance: payment + terms.insurance,
        principal: terms.principal(),
        total_due,
        interest,
        fees: terms.fees,
        insurance_total,
        cost: interest + terms.fees + insurance_total,
        all_in: total_due + insurance_total,
        taeg: taeg(terms.amount, dues),
    }
}

/// **Le TAEG**, actuariel : le taux mensuel `r` tel que ce que la personne
/// reçoit égale la somme de ses échéances actualisées, porté à l'année par
/// `(1 + r)^12 − 1`.
///
/// Cherché par dichotomie : la valeur actualisée baisse quand le taux monte,
/// une seule racine existe, et cent vingt tours la cernent bien au-delà du
/// centième de point.
fn taeg(received: i64, dues: &[Due]) -> Option<f64> {
    if received <= 0 || dues.is_empty() {
        return None;
    }
    let received = received as f64;
    let present = |r: f64| -> f64 {
        dues.iter()
            .enumerate()
            .map(|(rank, due)| due.payment as f64 / (1.0 + r).powi(rank as i32 + 1))
            .sum()
    };
    // Rembourser moins que ce qu'on a reçu n'a pas de taux positif.
    if present(0.0) < received {
        return Some(0.0);
    }
    let (mut low, mut high) = (0.0_f64, 1.0_f64);
    if present(high) > received {
        return None;
    }
    for _ in 0..120 {
        let middle = (low + high) / 2.0;
        if present(middle) > received {
            low = middle;
        } else {
            high = middle;
        }
    }
    Some(((1.0 + low).powi(12) - 1.0) * 100.0)
}

/// Les échéances résumées année par année — ce que le rapport imprime pour un
/// crédit immobilier (Fabrice, 08/10/2026 : « pour l'immobilier une ligne par
/// année », sauf si l'on coche « Tableau mois par mois »).
///
/// Une « année » est une année de crédit, douze échéances à partir de la
/// première, et non une année civile : la première et la dernière ne seraient
/// sinon que des morceaux.
pub fn by_year(dues: &[Due]) -> Vec<Due> {
    dues.chunks(12)
        .enumerate()
        .map(|(rank, year)| Due {
            number: rank as u32 + 1,
            date: year[0].date,
            payment: year.iter().map(|due| due.payment).sum(),
            interest: year.iter().map(|due| due.interest).sum(),
            capital: year.iter().map(|due| due.capital).sum(),
            insurance: year.iter().map(|due| due.insurance).sum(),
            remaining: year[year.len() - 1].remaining,
        })
        .collect()
}

// ---------------------------------------------------------------------------
// Puis-je le rembourser ?
// ---------------------------------------------------------------------------

/// **La période de l'historique**, au choix (Fabrice, 08/10/2026 : « 12
/// derniers mois, année calendaire N, N-1, N-2… jusqu'à N-5 »).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum History {
    LastTwelve,
    Year(i32),
}

impl History {
    pub fn from_key(key: &str) -> History {
        key.parse::<i32>().map(History::Year).unwrap_or(History::LastTwelve)
    }

    pub fn key(self) -> String {
        match self {
            History::LastTwelve => "last-12".to_string(),
            History::Year(year) => year.to_string(),
        }
    }

    /// Les choix du menu : les douze derniers mois, puis l'année en cours et
    /// les cinq d'avant.
    pub fn choices(today: NaiveDate) -> Vec<History> {
        let mut all = vec![History::LastTwelve];
        for back in 0..=5 {
            all.push(History::Year(today.year() - back));
        }
        all
    }

    /// **Les mois que la période couvre — des mois entiers seulement.**
    ///
    /// Les douze derniers mois sont les douze mois **complets** qui précèdent
    /// le mois en cours : un mois commencé ferait croire à un mois léger. Pour
    /// l'année en cours, de janvier au dernier mois fini — en octobre, neuf
    /// mois, et l'épreuve dira « 2 mois sur 9 ». Une année à venir n'a aucun
    /// mois.
    pub fn months(self, today: NaiveDate) -> Vec<NaiveDate> {
        let this_month = first_of(today);
        match self {
            History::LastTwelve => (1..=12)
                .rev()
                .filter_map(|back| this_month.checked_sub_months(Months::new(back)))
                .collect(),
            History::Year(year) => (1..=12)
                .filter_map(|month| NaiveDate::from_ymd_opt(year, month, 1))
                .filter(|month| *month < this_month)
                .collect(),
        }
    }
}

/// **La période de référence** : les douze derniers mois, une année, ou
/// **une plage d'années** — venue de l'objectif d'épargne (Fabrice,
/// 10/10/2026 : « une option d'année type ou moyenne sur une plage
/// d'années »), puis étendue à la simulation de crédit et au matelas de
/// sécurité.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Period {
    /// Les douze derniers mois complets, ou une année.
    History(History),
    /// Une plage d'années, bornes comprises.
    Range(i32, i32),
}

impl From<History> for Period {
    fn from(history: History) -> Period {
        Period::History(history)
    }
}

impl Period {
    /// Lue telle que la fenêtre l'envoie : `last-12`, une année, ou `range`
    /// avec ses deux bornes. Des bornes à l'envers sont remises dans l'ordre.
    pub fn from_keys(key: &str, from: i32, to: i32) -> Period {
        if key == "range" {
            Period::Range(from.min(to), from.max(to))
        } else {
            Period::History(History::from_key(key))
        }
    }

    /// Les mois que la période couvre — des mois entiers seulement.
    pub fn months(self, today: NaiveDate) -> Vec<NaiveDate> {
        match self {
            Period::History(history) => history.months(today),
            Period::Range(from, to) => (from..=to)
                .flat_map(|year| History::Year(year).months(today))
                .collect(),
        }
    }

    /// Les années qu'une plage peut prendre : l'année en cours et les cinq
    /// d'avant, comme les années seules.
    pub fn years(today: NaiveDate) -> Vec<i32> {
        (0..=5).map(|back| today.year() - back).collect()
    }
}

pub(crate) fn first_of(day: NaiveDate) -> NaiveDate {
    day.with_day(1).unwrap_or(day)
}

pub(crate) fn last_of(month: NaiveDate) -> NaiveDate {
    month
        .checked_add_months(Months::new(1))
        .and_then(|next| next.checked_sub_days(Days::new(1)))
        .unwrap_or(month)
}

/// Ce qui est entré et sorti des comptes cochés pendant un mois.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct MonthFlow {
    /// Le premier jour du mois.
    pub month: NaiveDate,
    pub income: i64,
    /// En positif.
    pub spending: i64,
}

impl MonthFlow {
    /// Ce qui serait resté ce mois-là, la nouvelle mensualité payée.
    pub fn left_with(&self, monthly: i64) -> i64 {
        self.income - self.spending - monthly
    }
}

/// Un crédit déjà en cours, reconnu parmi les opérations périodiques.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RunningLoan {
    pub label: String,
    pub account_id: i64,
    /// Ce qu'il coûte par mois, en positif.
    pub monthly: i64,
    /// Sa dernière échéance.
    pub end: NaiveDate,
}

/// Le voyant, et la couleur de chacune des trois questions qui le font.
///
/// **Révisé le 08/10/2026, après les essais de Fabrice** : « même emprunter
/// 100 euros sur 74 mois […] avec 0,39 % d'endettement il me dit risqué ». La
/// première règle jugeait l'historique et non le crédit : un reste à vivre
/// déjà négatif avant tout crédit, ou trois mois déjà dans le rouge sans lui,
/// mettaient au rouge n'importe quel crédit, même d'un euro. Fabrice : « il
/// faut faire mieux à ce niveau » — puis, sur la règle qui suit, « essaye, on
/// verra ».
///
/// Le voyant répond désormais à trois questions, **chacune sur ce que le
/// crédit change**, et prend la plus mauvaise des trois réponses (voir
/// [`analyse`]). Un historique déjà déficitaire est dit à part, par un
/// avertissement, et ne fait plus le verdict à lui seul.
///
/// L'ordre des variantes est celui de la gravité : le pire est le plus grand.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum Verdict {
    /// « Jouable ».
    Green,
    /// « Serré ».
    Orange,
    /// « Risqué ».
    Red,
}

impl Verdict {
    pub fn key(self) -> &'static str {
        match self {
            Verdict::Green => "green",
            Verdict::Orange => "orange",
            Verdict::Red => "red",
        }
    }
}

/// **Les trois méthodes de jugement** (Fabrice, 08/10/2026 : « une plus
/// favorable (optimiste), une plus neutre, une plus défavorable (sévère). En
/// fonction de son choix la personne pourra mieux évaluer ses risques. Mais il
/// faudrait être explicatif »).
///
/// Les trois posent **les mêmes trois questions** ; seules changent leurs
/// exigences, rassemblées dans [`Rules`]. La neutre est celle du 08/10/2026
/// (P-59), et elle s'ouvre par défaut. Rien n'est mémorisé : le choix revient
/// à la neutre au lancement suivant (« choix mémorisé : non »).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Method {
    Optimistic,
    Neutral,
    Severe,
}

/// Ce qu'une méthode exige, question par question.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Rules {
    /// L'endettement : vert jusqu'au premier seuil, orange jusqu'au second.
    pub debt_green: f64,
    pub debt_red: f64,
    /// Le mois de référence de la deuxième question, comme rang parmi les
    /// mois de la période : 0,75 pour un bon mois (meilleur que trois sur
    /// quatre), 0,5 pour un mois habituel (celui du milieu), 0,25 pour un mois
    /// difficile.
    pub reference: f64,
    /// La part de l'épargne de référence que la mensualité peut prendre.
    pub effort_green: f64,
    pub effort_red: f64,
    /// Le seuil que le solde ne doit pas franchir, en mois de dépenses
    /// moyennes : zéro, ou un mois gardé pour un imprévu.
    pub floor_months: i64,
    /// De combien de mois le crédit peut avancer le franchissement d'un seuil
    /// que le solde franchirait de toute façon.
    pub sooner_orange: usize,
    pub sooner_red: usize,
}

impl Method {
    pub const ALL: [Method; 3] = [Method::Optimistic, Method::Neutral, Method::Severe];

    pub fn key(self) -> &'static str {
        match self {
            Method::Optimistic => "optimistic",
            Method::Neutral => "neutral",
            Method::Severe => "severe",
        }
    }

    pub fn from_key(key: &str) -> Method {
        match key {
            "optimistic" => Method::Optimistic,
            "severe" => Method::Severe,
            _ => Method::Neutral,
        }
    }

    /// Le rang de la méthode dans [`Method::ALL`].
    pub fn rank(self) -> usize {
        match self {
            Method::Optimistic => 0,
            Method::Neutral => 1,
            Method::Severe => 2,
        }
    }

    /// **Le tableau accepté par Fabrice le 08/10/2026**, colonne par colonne.
    pub fn rules(self) -> Rules {
        match self {
            Method::Optimistic => Rules {
                debt_green: 35.0,
                debt_red: 40.0,
                reference: 0.75,
                effort_green: 75.0,
                effort_red: 100.0,
                floor_months: 0,
                sooner_orange: 6,
                sooner_red: 24,
            },
            // La règle des banques françaises pour l'immobilier, assurance
            // comprise : 33 et 35 %.
            Method::Neutral => Rules {
                debt_green: 33.0,
                debt_red: 35.0,
                reference: 0.5,
                effort_green: 50.0,
                effort_red: 100.0,
                floor_months: 0,
                sooner_orange: 3,
                sooner_red: 12,
            },
            Method::Severe => Rules {
                debt_green: 30.0,
                debt_red: 33.0,
                reference: 0.25,
                effort_green: 100.0 / 3.0,
                effort_red: 200.0 / 3.0,
                floor_months: 1,
                sooner_orange: 1,
                sooner_red: 6,
            },
        }
    }

    /// **La hausse des dépenses par an**, en pourcents, à l'ouverture
    /// (Fabrice, 08/10/2026 : « un champ par colonne »). Les prix montent,
    /// la mensualité non : sur un crédit long, l'écart compte.
    pub fn default_growth(self) -> u32 {
        match self {
            Method::Optimistic => 0,
            Method::Neutral => 2,
            Method::Severe => 3,
        }
    }
}

/// La hausse la plus forte qu'un champ accepte : 99 % par an.
pub const GROWTH_LIMIT: u32 = 99;

/// La méthode retenue, et la hausse des dépenses de chacune des trois.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Judging {
    pub chosen: Method,
    /// Dans l'ordre de [`Method::ALL`].
    pub growth: [u32; 3],
}

impl Default for Judging {
    fn default() -> Self {
        Judging {
            chosen: Method::Neutral,
            growth: Method::ALL.map(Method::default_growth),
        }
    }
}

/// **La mensualité tient-elle dans ce qu'un mois habituel met de côté ?**
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Effort {
    /// La part de cette épargne que la mensualité prend, en pourcents.
    Share(f64),
    /// Un mois habituel ne met rien de côté : la mensualité serait prise sur
    /// la réserve, et c'est la troisième question qui en juge.
    NoMargin,
}

/// **Le solde tient-il jusqu'à la fin du crédit ?**
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Reserve {
    /// Il reste positif d'un bout à l'autre.
    Holds,
    /// Il passerait sous zéro à cette date, et **à cause du crédit** : sans
    /// lui, il tiendrait.
    Breaks(NaiveDate),
    /// Il passerait sous zéro de toute façon, mais le crédit avance la date
    /// de tant de mois.
    Sooner { with: NaiveDate, months: usize },
    /// Il passerait sous zéro vers cette date même sans le crédit, qui n'y
    /// change presque rien.
    Anyway(NaiveDate),
}

/// Pourquoi l'analyse ne peut pas se faire, en clef Fluent.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Unavailable {
    NoAccount,
    NoMonth,
}

impl Unavailable {
    pub fn key(self) -> &'static str {
        match self {
            Unavailable::NoAccount => "loan-unavailable-no-account",
            Unavailable::NoMonth => "loan-unavailable-no-month",
        }
    }
}

/// Tout ce que l'onglet « Puis-je le rembourser ? » montre.
#[derive(Debug, Clone, PartialEq)]
pub struct Analysis {
    pub months: Vec<MonthFlow>,
    pub income: i64,
    pub spending: i64,
    /// Ce qui reste en moyenne chaque mois avant le nouveau crédit.
    pub saving: i64,
    pub running: Vec<RunningLoan>,
    pub running_monthly: i64,
    /// La nouvelle mensualité, assurance comprise.
    pub new_monthly: i64,
    /// Le taux d'endettement après le nouveau crédit, en pourcents. `None`
    /// quand il n'y a pas de revenu : il ne se calcule pas.
    pub debt_ratio: Option<f64>,
    /// Le reste à vivre : revenus − dépenses − nouvelle mensualité.
    pub rest: i64,
    /// Les mois que la mensualité ferait passer dans le rouge — positifs
    /// sans elle, négatifs avec.
    pub tipped_months: usize,
    /// Les mois qui étaient déjà dans le rouge sans le crédit.
    pub already_red_months: usize,
    /// Les dépenses moyennes dépassent déjà les revenus moyens, avant tout
    /// crédit : un avertissement à part, qui ne fait pas le verdict.
    pub deficit: bool,
    /// Les virements reconnus entre comptes cochés, et mis de côté.
    pub transfers: usize,
    /// Le solde réel des comptes cochés, aujourd'hui.
    pub start_balance: i64,
    /// La méthode retenue.
    pub chosen: Method,
    /// Le jugement des trois méthodes, dans l'ordre de [`Method::ALL`] : les
    /// trois verdicts se montrent côte à côte, et la méthode retenue en
    /// détail.
    pub judgements: Vec<Judgement>,
}

impl Analysis {
    /// Le jugement de la méthode retenue.
    pub fn judgement(&self) -> &Judgement {
        &self.judgements[self.chosen.rank()]
    }
}

/// **Ce qu'une méthode répond** aux trois questions.
#[derive(Debug, Clone, PartialEq)]
pub struct Judgement {
    pub method: Method,
    pub rules: Rules,
    /// La hausse des dépenses supposée, en pourcents par an.
    pub growth: u32,
    /// L'épargne du mois de référence de cette méthode : ce que ce mois-là a
    /// laissé, sans le nouveau crédit. Un rang et non une moyenne : un gros
    /// achat ou une prime isolés ne disent rien d'un mois ordinaire.
    pub reference_margin: i64,
    /// Le seuil que le solde ne doit pas franchir : zéro, ou la réserve de
    /// sécurité.
    pub floor: i64,
    pub effort: Effort,
    pub reserve: Reserve,
    /// La couleur de chacune des trois questions : l'endettement, l'effort,
    /// la réserve.
    pub checks: [Verdict; 3],
    pub verdict: Verdict,
    /// Le solde projeté après chaque échéance du nouveau crédit, dépenses
    /// augmentées de la hausse supposée.
    pub projection: Vec<(NaiveDate, i64)>,
    /// La première échéance où le solde passe sous le seuil.
    pub first_below: Option<NaiveDate>,
}

/// La valeur au rang `p` (de 0 à 1) d'une liste triée, entre ses deux voisins
/// les plus proches : 0,5 donne la médiane — la moyenne des deux du milieu
/// pour un nombre pair de mois.
pub(crate) fn quantile(sorted: &[i64], p: f64) -> i64 {
    if sorted.is_empty() {
        return 0;
    }
    let position = p.clamp(0.0, 1.0) * (sorted.len() - 1) as f64;
    let low = position.floor() as usize;
    let high = position.ceil() as usize;
    let weight = position - low as f64;
    (sorted[low] as f64 + (sorted[high] - sorted[low]) as f64 * weight).round() as i64
}

/// L'écart le plus grand entre les deux moitiés d'un virement.
pub const TRANSFER_DAYS: i64 = 5;

pub(crate) struct Line {
    pub(crate) id: i64,
    pub(crate) account: i64,
    pub(crate) amount: i64,
    pub(crate) day: NaiveDate,
}

/// **Les virements entre comptes cochés, reconnus par paires.**
///
/// Radinus ne marque pas un virement : c'est un débit et un crédit ordinaires,
/// et ceux qui viennent de la banque ne sont reliés à rien. Une paire, c'est
/// un débit sur un compte coché et un crédit **du même montant exact** sur un
/// **autre** compte coché, à cinq jours d'écart au plus — le temps que les
/// banques passent l'opération. Chaque opération ne sert qu'une fois, avec la
/// plus proche en date ; à égalité, la plus ancienne clef, pour qu'une même
/// base donne toujours la même réponse.
///
/// La limite, dite à Fabrice : deux opérations sans rapport, de même montant
/// à quelques jours d'écart sur deux comptes, seraient prises pour un
/// virement. C'est rare, et l'erreur va dans le sens prudent de ne rien
/// inventer comme revenu.
pub(crate) fn pair_transfers(lines: &[Line]) -> Vec<(i64, i64)> {
    let mut credits: HashMap<i64, Vec<usize>> = HashMap::new();
    for (rank, line) in lines.iter().enumerate() {
        if line.amount > 0 {
            credits.entry(line.amount).or_default().push(rank);
        }
    }
    let mut debits: Vec<usize> = (0..lines.len()).filter(|&rank| lines[rank].amount < 0).collect();
    debits.sort_by_key(|&rank| (lines[rank].day, lines[rank].id));

    let mut used = std::collections::HashSet::new();
    let mut pairs = Vec::new();
    for rank in debits {
        let debit = &lines[rank];
        let Some(candidates) = credits.get(&-debit.amount) else {
            continue;
        };
        let best = candidates
            .iter()
            .copied()
            .filter(|&other| !used.contains(&lines[other].id))
            .filter(|&other| lines[other].account != debit.account)
            .map(|other| {
                let gap = (lines[other].day - debit.day).num_days().abs();
                (gap, lines[other].id, other)
            })
            .filter(|(gap, _, _)| *gap <= TRANSFER_DAYS)
            .min();
        if let Some((_, credit_id, _)) = best {
            used.insert(debit.id);
            used.insert(credit_id);
            pairs.push((debit.id, credit_id));
        }
    }
    pairs
}

/// **Les crédits déjà en cours**, reconnus parmi les opérations périodiques
/// des comptes cochés.
///
/// Un loyer ou un abonnement n'a pas de fin ; un crédit en a une. Est donc
/// tenue pour un crédit toute règle qui **débite**, **au mois, au trimestre
/// ou à l'année**, et qui **finit** — à une date, ou après un nombre
/// d'échéances — **après aujourd'hui**. Les libellés ne sont jamais lus : ils
/// changent d'une banque et d'une langue à l'autre, et Radinus ne reconnaît
/// rien à son nom.
///
/// Pour une règle « nombre de répétitions », Radinus avance sa prochaine date
/// à chaque génération sans décompter les répétitions ; ce qui reste à payer
/// est donc le nombre prévu moins les opérations qu'elle a déjà produites.
pub fn running_loans(conn: &Connection, accounts: &[i64], today: NaiveDate) -> Result<Vec<RunningLoan>> {
    let mut found = Vec::new();
    for rule in recurring_operations::list(conn)? {
        if rule.amount >= 0 || !accounts.contains(&rule.account_id) {
            continue;
        }
        let months_per_step = match rule.unit {
            Unit::Month => 1,
            Unit::Quarter => 3,
            Unit::Year => 12,
            Unit::Day | Unit::Week => continue,
        } * rule.frequency.max(1);
        let Some(next) = rule.next_date else { continue };
        let end = match rule.ending {
            Ending::NoLimit => continue,
            Ending::UntilDate => match rule.end_date {
                Some(end) if next <= end => end,
                _ => continue,
            },
            Ending::RepeatCount => {
                let done = recurring_operations::produced(conn, &rule.guid)?.count;
                let left = rule.repeat_count - done;
                if left <= 0 {
                    continue;
                }
                match recurring_operations::nth_after(next, rule.unit, rule.frequency, left - 1) {
                    Some(end) => end,
                    None => continue,
                }
            }
        };
        if end < today {
            continue;
        }
        found.push(RunningLoan {
            label: rule.label.clone(),
            account_id: rule.account_id,
            monthly: round_to_cent(-rule.amount as f64 / months_per_step as f64),
            end,
        });
    }
    Ok(found)
}

/// **Puis-je le rembourser ?** L'historique des comptes cochés, sur la
/// période choisie, mis en regard de la nouvelle mensualité.
///
/// Ce qui entre dans le calcul, et ce qui n'y entre pas :
///
/// - **les opérations mères seulement**, jamais leurs filles — la règle de
///   tout Radinus ;
/// - **les pointées et les engagées** : une opération « prévue » dans le passé
///   n'a pas eu lieu ;
/// - **ni les virements entre comptes cochés** ([`pair_transfers`]) : l'argent
///   n'a fait que changer de poche. Un virement vers un compte **non coché**
///   compte comme une dépense — l'argent sort bien des comptes étudiés ;
/// - la date de l'opération, ou à défaut sa date de pointage.
///
/// Les moyennes sont le total de la période divisé par son nombre de mois. Les
/// crédits en cours sont **déjà** dans les dépenses, puisqu'ils ont été payés :
/// ils ne servent à part qu'au taux d'endettement, et à la projection, où une
/// mensualité qui s'arrête redevient disponible.
#[allow(clippy::too_many_arguments)]
pub fn analyse(
    conn: &Connection,
    accounts: &[i64],
    history: impl Into<Period>,
    today: NaiveDate,
    new_monthly: i64,
    months: u32,
    first_due: NaiveDate,
    judging: &Judging,
) -> Result<std::result::Result<Analysis, Unavailable>> {
    if accounts.is_empty() {
        return Ok(Err(Unavailable::NoAccount));
    }
    let period = history.into().months(today);
    let (Some(&first), Some(&last)) = (period.first(), period.last()) else {
        return Ok(Err(Unavailable::NoMonth));
    };
    let from = first;
    let to = last_of(last);
    let margin = Days::new(TRANSFER_DAYS as u64);
    let wide_from = from.checked_sub_days(margin).unwrap_or(from);
    let wide_to = to.checked_add_days(margin).unwrap_or(to);

    let marks = accounts.iter().map(|_| "?").collect::<Vec<_>>().join(",");
    let sql = format!(
        "SELECT IDOperation, IDCompte, Montant, COALESCE(Date, DatePointage) AS Jour
         FROM Operation
         WHERE IDOperationParent = 0 AND IDStatutOperation IN (1, 2)
           AND IDCompte IN ({marks})
           AND COALESCE(Date, DatePointage) BETWEEN ? AND ?"
    );
    let mut parameters: Vec<rusqlite::types::Value> = accounts
        .iter()
        .map(|id| rusqlite::types::Value::Integer(*id))
        .collect();
    parameters.push(rusqlite::types::Value::Text(wide_from.format("%Y-%m-%d").to_string()));
    parameters.push(rusqlite::types::Value::Text(wide_to.format("%Y-%m-%d").to_string()));
    let mut statement = conn.prepare(&sql)?;
    let lines: Vec<Line> = statement
        .query_map(rusqlite::params_from_iter(parameters), |row| {
            Ok((
                row.get::<_, i64>(0)?,
                row.get::<_, i64>(1)?,
                row.get::<_, i64>(2)?,
                row.get::<_, Option<String>>(3)?,
            ))
        })?
        .filter_map(|row| match row {
            Ok((id, account, amount, Some(day))) => NaiveDate::parse_from_str(&day, "%Y-%m-%d")
                .ok()
                .map(|day| Ok(Line { id, account, amount, day })),
            Ok(_) => None,
            Err(error) => Some(Err(error)),
        })
        .collect::<Result<_>>()?;

    let pairs = pair_transfers(&lines);
    let paired: std::collections::HashSet<i64> =
        pairs.iter().flat_map(|&(debit, credit)| [debit, credit]).collect();
    let inside: std::collections::HashSet<i64> = lines
        .iter()
        .filter(|line| line.day >= from && line.day <= to)
        .map(|line| line.id)
        .collect();
    // Un virement compte s'il touche la période par l'une de ses moitiés.
    let transfers = pairs
        .iter()
        .filter(|(debit, credit)| inside.contains(debit) || inside.contains(credit))
        .count();
    let mut flows: Vec<MonthFlow> = period
        .iter()
        .map(|&month| MonthFlow { month, income: 0, spending: 0 })
        .collect();
    for line in &lines {
        if line.day < from || line.day > to {
            continue;
        }
        if paired.contains(&line.id) {
            continue;
        }
        let month = first_of(line.day);
        if let Some(flow) = flows.iter_mut().find(|flow| flow.month == month) {
            if line.amount >= 0 {
                flow.income += line.amount;
            } else {
                flow.spending -= line.amount;
            }
        }
    }

    let count = flows.len() as i64;
    let income = flows.iter().map(|flow| flow.income).sum::<i64>() / count;
    let spending = flows.iter().map(|flow| flow.spending).sum::<i64>() / count;
    let saving = income - spending;
    let running = running_loans(conn, accounts, today)?;
    let running_monthly: i64 = running.iter().map(|loan| loan.monthly).sum();
    let debt_ratio = (income > 0)
        .then(|| (running_monthly + new_monthly) as f64 / income as f64 * 100.0);
    let rest = saving - new_monthly;
    let tipped_months = flows
        .iter()
        .filter(|flow| flow.left_with(0) >= 0 && flow.left_with(new_monthly) < 0)
        .count();
    let already_red_months = flows.iter().filter(|flow| flow.left_with(0) < 0).count();
    let mut margins: Vec<i64> = flows.iter().map(|flow| flow.left_with(0)).collect();
    margins.sort_unstable();

    // **La projection** : le solde réel d'aujourd'hui, prolongé échéance par
    // échéance des revenus moyens, moins les dépenses moyennes augmentées de
    // la hausse supposée, moins la nouvelle mensualité — plus, une fois un
    // crédit en cours terminé, sa mensualité qui redevient libre.
    let start_balance: i64 = {
        let mut total = 0;
        for row in crate::accounts::list(conn)? {
            if accounts.contains(&row.id) {
                total += row.balance_real;
            }
        }
        total
    };
    // **L'année type** (Fabrice, 10/10/2026 : « oui, appliquer l'année
    // type ») : chaque mois à venir reprend les revenus et les dépenses
    // moyens des mêmes mois du calendrier dans la période — un septembre
    // d'impôts, un décembre de treizième mois. Un mois que la période n'a pas
    // vu prend la moyenne de tous.
    let typical = |pick: fn(&MonthFlow) -> i64, mean: i64| -> [i64; 12] {
        let mut profile = [mean; 12];
        for (rank, slot) in profile.iter_mut().enumerate() {
            let same: Vec<i64> = flows
                .iter()
                .filter(|flow| flow.month.month0() as usize == rank)
                .map(pick)
                .collect();
            if !same.is_empty() {
                *slot = same.iter().sum::<i64>() / same.len() as i64;
            }
        }
        profile
    };
    let income_profile = typical(|flow| flow.income, income);
    let spending_profile = typical(|flow| flow.spending, spending);
    let project = |monthly: i64, length: u32, growth: u32| -> Vec<(NaiveDate, i64)> {
        let yearly = 1.0 + f64::from(growth) / 100.0;
        let mut balance = start_balance;
        (0..length)
            .map(|number| {
                let day = first_due.checked_add_months(Months::new(number)).unwrap_or(first_due);
                let freed: i64 = running
                    .iter()
                    .filter(|loan| loan.end < day)
                    .map(|loan| loan.monthly)
                    .sum();
                // Mois après mois : à 2 %, 2 000 € deviennent environ 2 040 €
                // la deuxième année, 2 080 € la troisième.
                let calendar = day.month0() as usize;
                let grown = (spending_profile[calendar] as f64 * yearly.powf(f64::from(number) / 12.0))
                    .round() as i64;
                balance += income_profile[calendar] - grown - monthly + freed;
                (day, balance)
            })
            .collect()
    };

    let judge = |method: Method, growth: u32| -> Judgement {
        let rules = method.rules();
        let reference_margin = quantile(&margins, rules.reference);
        let floor = spending * rules.floor_months;
        let projection = project(new_monthly, months, growth);
        let first_below =
            |points: &[(NaiveDate, i64)]| points.iter().position(|(_, value)| *value < floor);
        let with = first_below(&projection);
        // Sans le crédit, on regarde plus loin que sa fin : un solde qui
        // franchirait le seuil un mois après la dernière échéance n'est pas
        // « sauvé » par le crédit qui le lui fait franchir un mois plus tôt.
        let horizon = project(0, months + MONTHS_LIMIT, growth);
        let without = first_below(&horizon);

        // **Les trois questions** — chacune sur ce que le crédit change.
        //
        // 1. L'endettement est-il raisonnable ?
        let debt_check = match debt_ratio {
            None => Verdict::Red,
            Some(ratio) if ratio > rules.debt_red => Verdict::Red,
            Some(ratio) if ratio > rules.debt_green => Verdict::Orange,
            Some(_) => Verdict::Green,
        };
        // 2. La mensualité tient-elle dans ce que le mois de référence met de
        //    côté ?
        let effort = if reference_margin > 0 {
            Effort::Share(new_monthly as f64 / reference_margin as f64 * 100.0)
        } else {
            Effort::NoMargin
        };
        let effort_check = match effort {
            Effort::Share(share) if share > rules.effort_red => Verdict::Red,
            Effort::Share(share) if share > rules.effort_green => Verdict::Orange,
            _ => Verdict::Green,
        };
        // 3. Le solde tient-il au-dessus du seuil jusqu'au bout ? Rouge s'il
        //    ne le franchit qu'à cause du crédit ; s'il le franchirait de
        //    toute façon, le crédit n'est jugé que sur ce qu'il avance la date.
        let reserve = match (with, without) {
            (None, _) => Reserve::Holds,
            (Some(rank), None) => Reserve::Breaks(projection[rank].0),
            (Some(rank), Some(other)) if other >= rank + rules.sooner_orange => {
                Reserve::Sooner { with: projection[rank].0, months: other - rank }
            }
            (Some(_), Some(other)) => Reserve::Anyway(horizon[other].0),
        };
        let reserve_check = match reserve {
            Reserve::Holds | Reserve::Anyway(_) => Verdict::Green,
            Reserve::Breaks(_) => Verdict::Red,
            Reserve::Sooner { months, .. } if months >= rules.sooner_red => Verdict::Red,
            Reserve::Sooner { .. } => Verdict::Orange,
        };
        let checks = [debt_check, effort_check, reserve_check];
        Judgement {
            method,
            rules,
            growth,
            reference_margin,
            floor,
            effort,
            reserve,
            checks,
            verdict: checks.iter().copied().max().unwrap_or(Verdict::Green),
            first_below: with.map(|rank| projection[rank].0),
            projection,
        }
    };
    let judgements = Method::ALL
        .iter()
        .map(|method| judge(*method, judging.growth[method.rank()].min(GROWTH_LIMIT)))
        .collect();

    Ok(Ok(Analysis {
        months: flows,
        income,
        spending,
        saving,
        running,
        running_monthly,
        new_monthly,
        debt_ratio,
        rest,
        tipped_months,
        already_red_months,
        deficit: saving < 0,
        transfers,
        start_balance,
        chosen: judging.chosen,
        judgements,
    }))
}

/// La date de la première échéance : un mois après aujourd'hui.
pub fn first_due(today: NaiveDate) -> NaiveDate {
    today.checked_add_months(Months::new(1)).unwrap_or(today)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database::{schema, seed};

    /// La méthode neutre **sans hausse des dépenses** : celle sur laquelle
    /// les essais d'avant les trois méthodes ont été écrits.
    fn flat() -> Judging {
        Judging { chosen: Method::Neutral, growth: [0; 3] }
    }

    fn date(year: i32, month: u32, day: u32) -> NaiveDate {
        NaiveDate::from_ymd_opt(year, month, day).expect("date")
    }

    fn consumer(amount: i64, rate: i64, months: u32, fees: i64, insurance: i64) -> Terms {
        Terms { kind: Kind::Consumer, amount, rate, months, fees, insurance }
    }

    /// **La simulation de La Banque Postale que Fabrice a apportée**
    /// (08/10/2026) : 12 000 € plus 120 € de frais de dossier, à 6,41 % sur
    /// 22 mois, 9,50 € d'assurance par mois. Elle annonce 585,36 € par mois,
    /// 12 877,72 € dus, un TAEG de 7,73 % et 209 € d'assurance. Radinus
    /// compte des mois entiers et elle une première échéance à 30 jours sur
    /// 365 : les deux restent à quelques centimes l'un de l'autre.
    #[test]
    fn la_simulation_de_la_banque_postale_se_retrouve_a_quelques_centimes() {
        let terms = consumer(12_000 * EURO, 6_410_000, 22, 120 * EURO, 9_500_000);
        let settled = settle(terms, 0, Moved::Other);
        assert!((settled.payment - 585_360_000).abs() <= 3 * CENT, "{}", settled.payment);
        let dues = schedule(&settled.terms, settled.payment, date(2026, 11, 8));
        assert_eq!(dues.len(), 22);
        assert_eq!(dues.last().unwrap().remaining, 0);
        let summary = summarise(&settled.terms, settled.payment, &dues);
        assert!((summary.total_due - 12_877_720_000).abs() <= 100 * CENT, "{}", summary.total_due);
        assert_eq!(summary.insurance_total, 209 * EURO);
        let taeg = summary.taeg.unwrap();
        assert!((taeg - 7.73).abs() < 0.02, "{taeg}");
        // Le capital remboursé fait exactement le capital emprunté.
        assert_eq!(dues.iter().map(|due| due.capital).sum::<i64>(), 12_120 * EURO);
        assert_eq!(summary.cost, summary.interest + 120 * EURO + 209 * EURO);
    }

    #[test]
    fn la_mensualite_classique_et_le_taux_nul() {
        // 200 000 € à 3,5 % sur 20 ans : 1 159,92 €.
        assert_eq!(payment_for(200_000 * EURO, 3_500_000, 240), 1_159_920_000);
        // Sans intérêts, le capital divisé par la durée.
        assert_eq!(payment_for(1_200 * EURO, 0, 12), 100 * EURO);
        let terms = consumer(1_200 * EURO, 0, 12, 0, 0);
        let dues = schedule(&terms, 100 * EURO, date(2026, 1, 31));
        assert!(dues.iter().all(|due| due.interest == 0));
        assert_eq!(summarise(&terms, 100 * EURO, &dues).taeg, Some(0.0));
        // Le quantième d'origine revient dès que le calendrier le permet.
        assert_eq!(dues[1].date, date(2026, 2, 28));
        assert_eq!(dues[2].date, date(2026, 3, 31));
    }

    /// **Les trois curseurs se mettent d'accord** (Fabrice, 08/10/2026).
    #[test]
    fn les_curseurs_se_mettent_d_accord() {
        let base = consumer(10_000 * EURO, 6 * EURO, 48, 0, 0);
        // La durée bouge : la mensualité suit.
        let shorter = settle(Terms { months: 24, ..base }, 0, Moved::Months);
        assert_eq!(shorter.terms.months, 24);
        assert_eq!(shorter.payment, payment_for(10_000 * EURO, 6 * EURO, 24));
        // La mensualité bouge : la durée suit, au mois entier, et la
        // mensualité se réajuste sur elle.
        let wished = 300 * EURO;
        let moved = settle(base, wished, Moved::Payment);
        assert_eq!(moved.terms.months, months_for(10_000 * EURO, 6 * EURO, wished).unwrap());
        assert!(moved.payment <= wished && moved.payment > wished - 20 * EURO, "{}", moved.payment);
        assert_eq!(moved.notice, None);
        // Trop faible pour couvrir les intérêts : la durée reste à sa limite,
        // et la fenêtre le dira.
        let hopeless = settle(base, 10 * EURO, Moved::Payment);
        assert_eq!(hopeless.terms.months, MONTHS_LIMIT);
        assert_eq!(hopeless.notice, Some("loan-notice-payment-too-low"));
        // Les limites des champs texte.
        let huge = settle(Terms { amount: 500_000_000 * EURO, months: 9_000, ..base }, 0, Moved::Amount);
        assert_eq!(huge.terms.amount, AMOUNT_LIMIT);
        assert_eq!(huge.terms.months, MONTHS_LIMIT);
        // Au-delà du curseur mais dans la limite : le montant est honoré.
        let big = settle(Terms { kind: Kind::Mortgage, amount: 650_000 * EURO, ..base }, 0, Moved::Amount);
        assert_eq!(big.terms.amount, 650_000 * EURO);
    }

    #[test]
    fn l_annee_de_credit_resume_douze_echeances() {
        let terms = Terms { kind: Kind::Mortgage, amount: 100_000 * EURO, rate: 3 * EURO, months: 30, fees: 0, insurance: 10 * EURO };
        let payment = payment_for(terms.principal(), terms.rate, terms.months);
        let dues = schedule(&terms, payment, date(2026, 11, 1));
        let years = by_year(&dues);
        assert_eq!(years.len(), 3);
        assert_eq!(years[0].insurance, 120 * EURO);
        assert_eq!(years[2].insurance, 60 * EURO);
        assert_eq!(years.iter().map(|year| year.capital).sum::<i64>(), 100_000 * EURO);
        assert_eq!(years[2].remaining, 0);
    }

    #[test]
    fn les_periodes_ne_comptent_que_des_mois_entiers() {
        let today = date(2026, 10, 8);
        let twelve = History::LastTwelve.months(today);
        assert_eq!(twelve.len(), 12);
        assert_eq!(twelve[0], date(2025, 10, 1));
        assert_eq!(twelve[11], date(2026, 9, 1));
        assert_eq!(History::Year(2026).months(today).len(), 9);
        assert_eq!(History::Year(2025).months(today).len(), 12);
        assert!(History::Year(2026).months(date(2026, 1, 15)).is_empty());
        let choices = History::choices(today);
        assert_eq!(choices.len(), 7);
        assert_eq!(choices[6], History::Year(2021));
        assert_eq!(History::from_key("2024"), History::Year(2024));
        assert_eq!(History::from_key("last-12"), History::LastTwelve);
    }

    fn database() -> Connection {
        let conn = Connection::open_in_memory().expect("base en mémoire");
        schema::migrate(&conn).expect("schéma");
        seed::seed_initial_data(&conn).expect("valeurs initiales");
        for (id, label, real) in [(1, "CCP", 1_000 * EURO), (2, "Livret", 5_000 * EURO), (3, "Joint", 0)] {
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

    fn operation(conn: &Connection, id: i64, account: i64, day: &str, amount: i64, status: i64, parent: i64) {
        conn.execute(
            "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte,
                                    IDStatutOperation, IDOperationParent)
             VALUES (?1, 'OP', ?2, ?3, ?4, ?5, ?6)",
            rusqlite::params![id, day, amount, account, status, parent],
        )
        .expect("opération");
    }

    /// **La méthode, de bout en bout** : les revenus et les dépenses des
    /// comptes cochés, sans les virements entre eux, sans les filles ni les
    /// opérations prévues.
    #[test]
    fn l_historique_compte_ce_qu_il_doit_et_rien_d_autre() {
        let conn = database();
        let today = date(2026, 10, 8);
        let mut id = 0;
        let mut add = |account: i64, day: &str, amount: i64, status: i64, parent: i64| {
            id += 1;
            operation(&conn, id, account, day, amount, status, parent);
        };
        for month in 1..=9 {
            add(1, &format!("2026-{month:02}-02"), 2_000 * EURO, 1, 0); // salaire
            add(1, &format!("2026-{month:02}-10"), -1_500 * EURO, 1, 0); // dépenses
            // Un virement vers le livret, passé deux jours plus tard.
            add(1, &format!("2026-{month:02}-15"), -300 * EURO, 1, 0);
            add(2, &format!("2026-{month:02}-17"), 300 * EURO, 1, 0);
        }
        // Une fille ne compte pas, une opération prévue non plus.
        add(1, "2026-03-10", -500 * EURO, 1, 4);
        add(1, "2026-03-11", -9_999 * EURO, 3, 0);
        // Un virement vers un compte non coché (le joint) est une dépense.
        add(1, "2026-05-20", -100 * EURO, 1, 0);
        add(3, "2026-05-20", 100 * EURO, 1, 0);
        // Un virement de décembre à janvier, à cheval sur la période.
        add(1, "2025-12-30", -50 * EURO, 1, 0);
        add(2, "2026-01-02", 50 * EURO, 1, 0);

        let monthly = 200 * EURO;
        let analysis = analyse(&conn, &[1, 2], History::Year(2026), today, monthly, 12, first_due(today), &flat())
            .unwrap()
            .unwrap();
        assert_eq!(analysis.months.len(), 9);
        assert_eq!(analysis.income, 2_000 * EURO);
        // 1 500 € par mois, et les 100 € vers le joint une fois.
        assert_eq!(analysis.spending, 1_500 * EURO + 100 * EURO / 9);
        assert_eq!(analysis.transfers, 10);
        assert_eq!(analysis.tipped_months, 0);
        assert_eq!(analysis.judgement().reference_margin, 500 * EURO);
        assert_eq!(analysis.judgement().checks, [Verdict::Green; 3]);
        assert!(!analysis.deficit);
        assert!((analysis.debt_ratio.unwrap() - 10.0).abs() < 1e-9);
        assert_eq!(analysis.judgement().verdict, Verdict::Green);
        assert_eq!(analysis.start_balance, 6_000 * EURO);
        assert_eq!(analysis.judgement().projection.len(), 12);
        assert_eq!(analysis.judgement().projection[0].1, 6_000 * EURO + analysis.saving - monthly);

        // Le livret décoché : le virement vers lui devient une dépense.
        let alone = analyse(&conn, &[1], History::Year(2026), today, monthly, 12, first_due(today), &flat())
            .unwrap()
            .unwrap();
        assert_eq!(alone.transfers, 0);
        assert!(alone.spending > analysis.spending + 290 * EURO);

        // Une mensualité qui mange tout passe au rouge.
        let heavy = analyse(&conn, &[1, 2], History::Year(2026), today, 900 * EURO, 12, first_due(today), &flat())
            .unwrap()
            .unwrap();
        assert_eq!(heavy.judgement().verdict, Verdict::Red);
        assert_eq!(heavy.tipped_months, 9);
        // 900 € sur 500 € d'épargne habituelle : l'effort est rouge.
        assert_eq!(heavy.judgement().checks[1], Verdict::Red);
        assert!(heavy.judgement().first_below.is_none() || heavy.rest < 0);

        assert_eq!(
            analyse(&conn, &[], History::Year(2026), today, monthly, 12, first_due(today), &flat()).unwrap(),
            Err(Unavailable::NoAccount)
        );
        assert_eq!(
            analyse(&conn, &[1], History::Year(2027), today, monthly, 12, first_due(today), &flat()).unwrap(),
            Err(Unavailable::NoMonth)
        );
    }

    /// **Le cas de Fabrice** (08/10/2026) : « même emprunter 100 euros sur 74
    /// mois […] avec 0,39 % d'endettement il me dit risqué ». Un historique
    /// déjà déficitaire et des mois déjà dans le rouge ne font plus, à eux
    /// seuls, le verdict d'un crédit qui n'y change rien.
    #[test]
    fn un_petit_credit_sur_un_historique_deficitaire_reste_jouable() {
        let conn = database();
        let today = date(2026, 10, 8);
        let mut id = 100;
        for month in 1..=12 {
            id += 1;
            operation(&conn, id, 1, &format!("2025-{month:02}-02"), 2_000 * EURO, 1, 0);
            id += 1;
            // Des mois chargés : la moyenne dépense un peu plus qu'elle ne gagne.
            let spent = if month % 3 == 0 { 2_600 } else { 1_950 };
            operation(&conn, id, 1, &format!("2025-{month:02}-15"), -spent * EURO, 1, 0);
        }
        let small = 1_350_000; // 1,35 € par mois : 100 € sur 74 mois.
        let analysis = analyse(&conn, &[1], History::Year(2025), today, small, 74, first_due(today), &flat())
            .unwrap()
            .unwrap();
        assert!(analysis.deficit, "l'historique est déficitaire avant tout crédit");
        assert_eq!(analysis.already_red_months, 4);
        assert_eq!(analysis.tipped_months, 0);
        assert_eq!(analysis.judgement().reference_margin, 50 * EURO);
        assert_eq!(analysis.judgement().verdict, Verdict::Green, "{:?} {:?}", analysis.judgement().checks, analysis.judgement().reserve);

        // Le même historique, et un crédit qui pèse : la réserve de 1 000 €
        // fond bien plus vite, et le voyant le dit.
        let heavy = analyse(&conn, &[1], History::Year(2025), today, 400 * EURO, 48, first_due(today), &flat())
            .unwrap()
            .unwrap();
        assert_eq!(heavy.judgement().checks[1], Verdict::Red);
        assert!(matches!(heavy.judgement().reserve, Reserve::Sooner { .. } | Reserve::Breaks(_)));
        assert_eq!(heavy.judgement().verdict, Verdict::Red);
    }

    /// Un solde qui ne passe sous zéro qu'à cause du crédit : rouge, même si
    /// l'endettement est sage.
    #[test]
    fn la_reserve_qui_ne_tient_qu_a_cause_du_credit_met_au_rouge() {
        let conn = database();
        let today = date(2026, 10, 8);
        conn.execute("UPDATE Compte SET SoldeReel = 0", []).unwrap();
        for month in 1..=12 {
            operation(&conn, 200 + month, 1, &format!("2025-{month:02}-02"), 3_000 * EURO, 1, 0);
            operation(&conn, 300 + month, 1, &format!("2025-{month:02}-15"), -2_950 * EURO, 1, 0);
        }
        // 60 € par mois contre 50 € d'épargne : 2 % d'endettement, mais le
        // solde, nul aujourd'hui, passe sous zéro dès la première échéance.
        let analysis = analyse(&conn, &[1], History::Year(2025), today, 60 * EURO, 12, first_due(today), &flat())
            .unwrap()
            .unwrap();
        assert_eq!(analysis.judgement().checks[0], Verdict::Green);
        assert!(matches!(analysis.judgement().reserve, Reserve::Breaks(_)));
        assert_eq!(analysis.judgement().verdict, Verdict::Red);
    }

    /// **Les trois méthodes** (Fabrice, 08/10/2026) : un même crédit, trois
    /// exigences. Ici 300 € par mois sur un foyer qui gagne 2 000 € et met de
    /// côté entre 200 et 900 € selon les mois.
    #[test]
    fn les_trois_methodes_jugent_du_plus_doux_au_plus_severe() {
        let conn = database();
        let today = date(2026, 10, 8);
        let left = [200, 300, 400, 500, 500, 500, 600, 600, 700, 800, 900, 900];
        for (rank, kept) in left.iter().enumerate() {
            let month = rank + 1;
            operation(&conn, 400 + month as i64, 1, &format!("2025-{month:02}-02"), 2_000 * EURO, 1, 0);
            operation(&conn, 500 + month as i64, 1, &format!("2025-{month:02}-15"), -(2_000 - kept) * EURO, 1, 0);
        }
        let judging = Judging { chosen: Method::Severe, growth: [0, 0, 0] };
        let analysis = analyse(&conn, &[1], History::Year(2025), today, 300 * EURO, 24, first_due(today), &judging)
            .unwrap()
            .unwrap();
        assert_eq!(analysis.judgements.len(), 3);
        assert_eq!(analysis.judgement().method, Method::Severe);
        let [optimistic, neutral, severe] = [0, 1, 2].map(|rank| &analysis.judgements[rank]);
        // Un bon mois, un mois habituel, un mois difficile.
        assert!(optimistic.reference_margin > neutral.reference_margin);
        assert!(neutral.reference_margin > severe.reference_margin);
        assert_eq!(neutral.reference_margin, 550 * EURO);
        // 15 % d'endettement : vert partout. L'effort fait la différence.
        assert_eq!(optimistic.verdict, Verdict::Green);
        assert_eq!(neutral.verdict, Verdict::Orange, "{:?}", neutral.checks);
        // Depuis l'année type (10/10/2026), la projection commence en
        // novembre, l'un des meilleurs mois de cet historique : la réserve de
        // la méthode sévère tient. Elle reste la plus exigeante sur l'effort.
        assert!(severe.verdict >= neutral.verdict, "{:?}", severe.checks);
        assert!(severe.checks[1] >= neutral.checks[1]);
        // La méthode sévère garde un mois de dépenses en réserve.
        assert_eq!(severe.floor, analysis.spending);
        assert_eq!(neutral.floor, 0);
    }

    /// **La hausse des dépenses** creuse la projection, mois après mois.
    #[test]
    fn la_hausse_des_depenses_creuse_la_projection() {
        let conn = database();
        let today = date(2026, 10, 8);
        for month in 1..=12 {
            operation(&conn, 600 + month, 1, &format!("2025-{month:02}-02"), 2_000 * EURO, 1, 0);
            operation(&conn, 700 + month, 1, &format!("2025-{month:02}-15"), -1_800 * EURO, 1, 0);
        }
        let flat_run = analyse(&conn, &[1], History::Year(2025), today, 100 * EURO, 240, first_due(today), &flat())
            .unwrap()
            .unwrap();
        let grown = analyse(&conn, &[1], History::Year(2025), today, 100 * EURO, 240, first_due(today), &Judging::default())
            .unwrap()
            .unwrap();
        let end = |analysis: &Analysis| analysis.judgement().projection.last().unwrap().1;
        assert!(end(&grown) < end(&flat_run));
        // Le premier mois ne bouge pas : la hausse commence à zéro.
        assert_eq!(
            grown.judgement().projection[0].1,
            flat_run.judgement().projection[0].1
        );
        assert_eq!(Judging::default().growth, [0, 2, 3]);
    }

    #[test]
    fn le_rang_d_un_mois_se_lit_entre_ses_voisins() {
        assert_eq!(quantile(&[1, 2, 3, 4], 0.5), 3); // 2,5 arrondi
        assert_eq!(quantile(&[10, 20, 30], 0.5), 20);
        assert_eq!(quantile(&[0, 100], 0.25), 25);
        assert_eq!(quantile(&[], 0.5), 0);
    }

    #[test]
    fn deux_virements_identiques_ne_servent_qu_une_fois() {
        let line = |id, account, amount, day: NaiveDate| Line { id, account, amount, day };
        let lines = vec![
            line(1, 1, -100, date(2026, 3, 1)),
            line(2, 1, -100, date(2026, 3, 3)),
            line(3, 2, 100, date(2026, 3, 3)),
            // Même compte : pas un virement.
            line(4, 1, 100, date(2026, 3, 1)),
            // Trop loin.
            line(5, 2, 100, date(2026, 3, 20)),
        ];
        // Le premier débit prend le seul crédit possible, le second reste seul.
        assert_eq!(pair_transfers(&lines), vec![(1, 3)]);
    }

    /// **Un crédit en cours, c'est une règle qui débite et qui finit.**
    #[test]
    fn les_credits_en_cours_sont_les_regles_qui_finissent() {
        let conn = database();
        let today = date(2026, 10, 8);
        let rule = |guid: &str, account: i64, amount: i64, unit: i64, ending: i64, end: Option<&str>, repeat: i64| {
            conn.execute(
                "INSERT INTO CalOpPeriodique (IDOperation, GUIDCalOpPeriode, IDCompte, Libelle, Montant,
                     DateProchOp, ModeFinInsertion, DateFin, Periode, PeriodeFreq, PeriodeNbrRepete)
                 VALUES ((SELECT COALESCE(MAX(IDOperation), 0) + 1 FROM CalOpPeriodique),
                         ?1, ?2, ?1, ?3, '2026-11-05', ?4, ?5, ?6, 1, ?7)",
                rusqlite::params![guid, account, amount, ending, end, unit, repeat],
            )
            .expect("règle");
        };
        rule("PRET AUTO", 1, -250 * EURO, 3, 2, Some("2028-05-05"), 1);
        rule("LOYER", 1, -700 * EURO, 3, 1, None, 1);
        rule("SALAIRE", 1, 2_000 * EURO, 3, 2, Some("2030-01-01"), 1);
        rule("FINI", 1, -90 * EURO, 3, 2, Some("2026-01-01"), 1);
        rule("ASSURANCE", 1, -120 * EURO, 4, 3, None, 8);
        rule("AUTRE COMPTE", 2, -50 * EURO, 3, 2, Some("2028-01-01"), 1);
        let found = running_loans(&conn, &[1], today).unwrap();
        let labels: Vec<&str> = found.iter().map(|loan| loan.label.as_str()).collect();
        assert_eq!(labels.len(), 2, "{labels:?}");
        let auto = found.iter().find(|loan| loan.label == "PRET AUTO").unwrap();
        assert_eq!(auto.monthly, 250 * EURO);
        assert_eq!(auto.end, date(2028, 5, 5));
        let quarterly = found.iter().find(|loan| loan.label == "ASSURANCE").unwrap();
        assert_eq!(quarterly.monthly, 40 * EURO);
        // Huit trimestres à partir du 5 novembre 2026.
        assert_eq!(quarterly.end, date(2028, 8, 5));
    }

    /// **L'année type** (Fabrice, 10/10/2026) : la projection reprend, mois
    /// après mois, ce que les mêmes mois de la période ont laissé — ici 900 €
    /// en décembre, 100 € les autres mois.
    #[test]
    fn la_projection_suit_l_annee_type() {
        let conn = database();
        let today = date(2026, 10, 8);
        conn.execute("UPDATE Compte SET SoldeReel = 0", []).unwrap();
        for month in 1..=12 {
            let kept = if month == 12 { 900 } else { 100 };
            operation(&conn, 800 + month, 1, &format!("2025-{month:02}-02"), 2_000 * EURO, 1, 0);
            operation(&conn, 900 + month, 1, &format!("2025-{month:02}-15"), -(2_000 - kept) * EURO, 1, 0);
        }
        let analysis = analyse(&conn, &[1], History::Year(2025), today, 0, 3, first_due(today), &flat())
            .unwrap()
            .unwrap();
        let projection = &analysis.judgement().projection;
        // Première échéance le 8 novembre : novembre, décembre, janvier.
        assert_eq!(projection[0].1, 100 * EURO);
        assert_eq!(projection[1].1, 1_000 * EURO);
        assert_eq!(projection[2].1, 1_100 * EURO);
    }

    /// **Une plage d'années** se lit comme une année : tous ses mois complets.
    #[test]
    fn une_plage_d_annees_se_lit_comme_une_annee() {
        let conn = database();
        let today = date(2026, 10, 8);
        for (rank, year) in [2024, 2025].iter().enumerate() {
            for month in 1..=12 {
                let id = 1_000 + rank as i64 * 100 + month;
                operation(&conn, id, 1, &format!("{year}-{month:02}-02"), 2_000 * EURO, 1, 0);
            }
        }
        let analysis = analyse(&conn, &[1], Period::Range(2024, 2025), today, 0, 12, first_due(today), &flat())
            .unwrap()
            .unwrap();
        assert_eq!(analysis.months.len(), 24);
        assert_eq!(analysis.income, 2_000 * EURO);
        assert_eq!(Period::from_keys("range", 2025, 2024), Period::Range(2024, 2025));
    }
}
