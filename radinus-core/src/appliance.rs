//! Ce que coûte un appareil électrique — F42 (Fabrice, 09/10/2026).
//!
//! « Évaluer combien coûte la consommation d'un appareil électrique. » Et pas
//! n'importe comment : **« un résultat honnête, qui tienne compte de la
//! consommation allumée, ou en veille, mais aussi coût heure creuse ou heure
//! pleine »**. Radinus ne suppose rien de l'appareil — « je suis contre les
//! tableaux d'appareils et les listes d'appareils courants : tu ne peux faire
//! que des hypothèses, tu n'as pas les chiffres réels » : toutes les valeurs de
//! l'appareil viennent de la personne.
//!
//! # Le calcul
//!
//! - **Allumé** : la puissance en marche × les heures par jour × les jours
//!   d'utilisation par semaine.
//! - **En veille** : la puissance de veille × les heures en veille. Les jours
//!   d'utilisation, ce sont les heures en veille saisies ; **les autres jours,
//!   l'appareil reste branché autant d'heures qu'un jour d'utilisation, et
//!   tout ce temps est de la veille** — un téléviseur qu'on n'allume pas le
//!   dimanche n'est pas débranché pour autant.
//! - **Heures pleines, heures creuses** : la part du temps allumé en heures
//!   creuses est donnée par la personne (un chauffe-eau la nuit, 100 % ; un
//!   téléviseur le soir, 0 %) ; **la veille tourne jour et nuit**, sa part en
//!   heures creuses est celle des heures creuses du contrat dans la journée.
//! - L'**abonnement** n'entre pas dans le calcul : on le paie que l'appareil
//!   soit branché ou non.
//!
//! Une semaine fait sept jours, une année 365, un mois le douzième d'une
//! année. Les prix du kWh sont tenus en micro-unités, comme tout montant de
//! Radinus : 0,2001 € s'écrit `200_100`.

use crate::i18n::{self, Language};
use crate::loan_charts::{self, Part};
use crate::money::{self, UNIT};

/// La puissance la plus forte qu'un champ accepte : 100 kW, bien au-delà de
/// tout appareil domestique.
pub const WATTS_LIMIT: f64 = 100_000.0;

/// **Le tarif du contrat d'électricité.**
#[derive(Debug, Clone, Copy, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Tariff {
    /// Heures pleines / heures creuses, ou un prix unique (« Base »).
    pub off_peak_option: bool,
    /// Le prix du kWh en option Base, en micro-unités.
    pub base: i64,
    /// Les prix du kWh en heures pleines et en heures creuses.
    pub peak: i64,
    pub off_peak: i64,
    /// Combien d'heures creuses par jour, de 0 à 24.
    pub off_peak_hours: u32,
}

/// **Le Tarif Bleu d'EDF, prix TTC du kWh au 1er août 2026** — ce que la
/// fenêtre propose tant que rien n'est enregistré dans les préférences
/// (Fabrice, 09/10/2026 : « on prendra le tarif actuel par défaut en
/// France »). Option Base pour un compteur de 3 ou 6 kVA, le plus courant :
/// 0,2001 € ; heures pleines 0,2142 €, heures creuses 0,1589 €, huit heures
/// creuses par jour.
///
/// **Ces prix changent, en général en février et en août** : ils sont à
/// revoir à chaque version de Radinus. La personne tape de toute façon ceux de
/// sa facture, et c'est toujours eux qui comptent.
pub const BLUE_TARIFF: Tariff = Tariff {
    off_peak_option: false,
    base: 200_100,
    peak: 214_200,
    off_peak: 158_900,
    off_peak_hours: 8,
};

/// Le prix le plus fort qu'un champ accepte : 100 € le kWh.
pub const PRICE_LIMIT: i64 = 100 * UNIT;

impl Default for Tariff {
    fn default() -> Self {
        BLUE_TARIFF
    }
}

impl Tariff {
    /// Des prix positifs et plausibles, au plus vingt-quatre heures creuses.
    pub fn holds(&self) -> bool {
        let price = |value: i64| (0..=PRICE_LIMIT).contains(&value);
        price(self.base) && price(self.peak) && price(self.off_peak) && self.off_peak_hours <= 24
    }
}

/// Ce que la personne dit de son appareil.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Usage {
    /// La puissance en marche, en watts.
    pub on_watts: f64,
    /// Les heures de marche par jour d'utilisation.
    pub on_hours: f64,
    /// Les jours d'utilisation par semaine, de 0 à 7.
    pub days: u32,
    /// La part de la marche en heures creuses, de 0 à 100 %.
    pub on_off_peak_share: f64,
    /// La puissance en veille, en watts.
    pub standby_watts: f64,
    /// Les heures en veille par jour d'utilisation. `None` : le reste de la
    /// journée, 24 h moins les heures de marche.
    pub standby_hours: Option<f64>,
}

/// Pourquoi le calcul ne se fait pas : le champ fautif.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Refusal {
    OnWatts,
    OnHours,
    Days,
    Share,
    StandbyWatts,
    /// Les heures de veille dépassent ce que la journée laisse.
    StandbyHours,
    Base,
    Peak,
    OffPeak,
    OffPeakHours,
}

impl Refusal {
    /// L'identifiant du champ dans les fenêtres.
    pub fn field(self) -> &'static str {
        match self {
            Refusal::OnWatts => "on-watts",
            Refusal::OnHours => "on-hours",
            Refusal::Days => "days",
            Refusal::Share => "share",
            Refusal::StandbyWatts => "standby-watts",
            Refusal::StandbyHours => "standby-hours",
            Refusal::Base => "base",
            Refusal::Peak => "peak",
            Refusal::OffPeak => "off-peak",
            Refusal::OffPeakHours => "off-peak-hours",
        }
    }

    /// Ce qu'on dit à la personne, en une phrase.
    pub fn message(self, language: Language) -> String {
        i18n::text(
            language,
            match self {
                Refusal::OnWatts | Refusal::StandbyWatts => "appliance-invalid-watts",
                Refusal::OnHours => "appliance-invalid-hours",
                Refusal::Days => "appliance-invalid-days",
                Refusal::Share => "appliance-invalid-share",
                Refusal::StandbyHours => "appliance-invalid-day-overflow",
                Refusal::Base | Refusal::Peak | Refusal::OffPeak => "appliance-invalid-price",
                Refusal::OffPeakHours => "appliance-invalid-off-peak-hours",
            },
        )
    }
}

/// Une part de la consommation sur une année : son énergie, et ce qu'elle
/// coûte.
#[derive(Debug, Clone, Copy, PartialEq, Default)]
pub struct Share {
    pub kwh: f64,
    /// En micro-unités.
    pub cost: i64,
}

/// **Le résultat**, ramené à l'année ; le jour et le mois s'en déduisent.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Bill {
    /// Les heures de veille retenues par jour d'utilisation.
    pub standby_hours: f64,
    pub on_peak: Share,
    pub on_off_peak: Share,
    pub standby_peak: Share,
    pub standby_off_peak: Share,
}

impl Bill {
    pub fn on(&self) -> Share {
        add(self.on_peak, self.on_off_peak)
    }
    pub fn standby(&self) -> Share {
        add(self.standby_peak, self.standby_off_peak)
    }
    pub fn peak(&self) -> Share {
        add(self.on_peak, self.standby_peak)
    }
    pub fn off_peak(&self) -> Share {
        add(self.on_off_peak, self.standby_off_peak)
    }
    pub fn year(&self) -> Share {
        add(self.on(), self.standby())
    }
    pub fn month(&self) -> Share {
        divide(self.year(), 12.0)
    }
    pub fn day(&self) -> Share {
        divide(self.year(), DAYS_A_YEAR)
    }
}

fn add(a: Share, b: Share) -> Share {
    Share { kwh: a.kwh + b.kwh, cost: a.cost + b.cost }
}

fn divide(share: Share, by: f64) -> Share {
    Share { kwh: share.kwh / by, cost: (share.cost as f64 / by).round() as i64 }
}

const DAYS_A_YEAR: f64 = 365.0;
const WEEKS_A_YEAR: f64 = DAYS_A_YEAR / 7.0;

/// **Le calcul**, ou le champ qui l'empêche.
pub fn compute(usage: &Usage, tariff: &Tariff) -> Result<Bill, Refusal> {
    let finite = |value: f64| value.is_finite();
    if !finite(usage.on_watts) || !(0.0..=WATTS_LIMIT).contains(&usage.on_watts) {
        return Err(Refusal::OnWatts);
    }
    if !finite(usage.on_hours) || !(0.0..=24.0).contains(&usage.on_hours) {
        return Err(Refusal::OnHours);
    }
    if usage.days > 7 {
        return Err(Refusal::Days);
    }
    if !finite(usage.on_off_peak_share) || !(0.0..=100.0).contains(&usage.on_off_peak_share) {
        return Err(Refusal::Share);
    }
    if !finite(usage.standby_watts) || !(0.0..=WATTS_LIMIT).contains(&usage.standby_watts) {
        return Err(Refusal::StandbyWatts);
    }
    let standby_hours = usage.standby_hours.unwrap_or(24.0 - usage.on_hours);
    if !finite(standby_hours) || standby_hours < 0.0 || usage.on_hours + standby_hours > 24.0 + 1e-9 {
        return Err(Refusal::StandbyHours);
    }

    // L'énergie d'une semaine, en kWh.
    let days = f64::from(usage.days);
    let on_week = usage.on_watts * usage.on_hours * days / 1000.0;
    let plugged = usage.on_hours + standby_hours;
    let standby_week =
        usage.standby_watts * (standby_hours * days + plugged * (7.0 - days)) / 1000.0;
    let on_year = on_week * WEEKS_A_YEAR;
    let standby_year = standby_week * WEEKS_A_YEAR;

    let cost = |kwh: f64, price: i64| (kwh * price as f64).round() as i64;
    let share = |kwh: f64, price: i64| Share { kwh, cost: cost(kwh, price) };
    if !tariff.off_peak_option {
        return Ok(Bill {
            standby_hours,
            on_peak: share(on_year, tariff.base),
            on_off_peak: Share::default(),
            standby_peak: share(standby_year, tariff.base),
            standby_off_peak: Share::default(),
        });
    }
    let on_off = on_year * usage.on_off_peak_share / 100.0;
    // La veille tourne jour et nuit : sa part en heures creuses est celle de
    // la journée.
    let standby_off = standby_year * f64::from(tariff.off_peak_hours.min(24)) / 24.0;
    Ok(Bill {
        standby_hours,
        on_peak: share(on_year - on_off, tariff.peak),
        on_off_peak: share(on_off, tariff.off_peak),
        standby_peak: share(standby_year - standby_off, tariff.peak),
        standby_off_peak: share(standby_off, tariff.off_peak),
    })
}

/// **Un nombre tapé** : des chiffres, une virgule ou un point, des espaces
/// entre les milliers. Rien d'autre — une lettre rend `None`, et le champ est
/// marqué plutôt que lu à moitié. Un champ vide rend `None` aussi ; c'est à
/// l'appelant de dire ce qu'il vaut.
pub fn parse_number(text: &str) -> Option<f64> {
    let cleaned: String = text
        .trim()
        .chars()
        .filter(|c| !c.is_whitespace() && *c != '\u{202f}' && *c != '\u{a0}')
        .map(|c| if c == ',' { '.' } else { c })
        .collect();
    if cleaned.is_empty()
        || cleaned.chars().filter(|c| *c == '.').count() > 1
        || !cleaned.chars().all(|c| c.is_ascii_digit() || c == '.')
    {
        return None;
    }
    cleaned.parse::<f64>().ok().filter(|value| value.is_finite())
}

/// **Un prix du kWh tapé**, en micro-unités : jusqu'à six décimales, car
/// 0,2001 € en a quatre — `money::parse` arrondit au centime. Le signe de la
/// monnaie autour est accepté, comme dans tout champ de montant.
pub fn parse_price(text: &str) -> Option<i64> {
    let sign = money::sign();
    let mut trimmed = text.trim();
    for _ in 0..2 {
        if !sign.is_empty() {
            trimmed = trimmed.strip_suffix(sign.as_str()).unwrap_or(trimmed).trim();
            trimmed = trimmed.strip_prefix(sign.as_str()).unwrap_or(trimmed).trim();
        }
        trimmed = trimmed.trim_matches(|c| matches!(c, '€' | '$' | '£' | '¥')).trim();
    }
    let value = parse_number(trimmed)?;
    let micro = (value * UNIT as f64).round();
    (micro <= PRICE_LIMIT as f64).then_some(micro as i64)
}

/// Un prix du kWh tel qu'on le retape : quatre décimales, « 0,2001 ».
pub fn price_field(price: i64, language: Language) -> String {
    let (_, decimal) = money::separators(language);
    let value = price as f64 / UNIT as f64;
    format!("{value:.4}").replace('.', &decimal.to_string())
}

// --- Les champs ---------------------------------------------------------------
//
// Les fenêtres envoient leurs champs **tels qu'ils sont tapés** ; c'est ici
// qu'ils se lisent, une seule fois pour la fenêtre de calcul et pour la
// feuille des préférences.

/// Les champs de l'appareil.
#[derive(Debug, Clone, Default, serde::Deserialize)]
pub struct UsageFields {
    pub on_watts: String,
    pub on_hours: String,
    pub days: String,
    pub share: String,
    pub standby_watts: String,
    pub standby_hours: String,
}

/// Les champs du tarif. `option` : `base` ou `off-peak`.
#[derive(Debug, Clone, Default, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
pub struct TariffFields {
    pub option: String,
    pub base: String,
    pub peak: String,
    pub off_peak: String,
    pub off_peak_hours: String,
}

/// Un champ vide vaut zéro — sauf les heures de veille, où il veut dire « le
/// reste de la journée ».
fn number_or_zero(text: &str, refusal: Refusal) -> Result<f64, Refusal> {
    if text.trim().is_empty() {
        return Ok(0.0);
    }
    parse_number(text).ok_or(refusal)
}

/// Lit les champs de l'appareil. Les bornes sont vérifiées par `compute`.
pub fn read_usage(fields: &UsageFields) -> Result<Usage, Refusal> {
    let days = number_or_zero(&fields.days, Refusal::Days)?;
    if days.fract() != 0.0 || days > 7.0 {
        return Err(Refusal::Days);
    }
    let standby_hours = if fields.standby_hours.trim().is_empty() {
        None
    } else {
        Some(parse_number(&fields.standby_hours).ok_or(Refusal::StandbyHours)?)
    };
    Ok(Usage {
        on_watts: number_or_zero(&fields.on_watts, Refusal::OnWatts)?,
        on_hours: number_or_zero(&fields.on_hours, Refusal::OnHours)?,
        days: days as u32,
        on_off_peak_share: number_or_zero(&fields.share, Refusal::Share)?,
        standby_watts: number_or_zero(&fields.standby_watts, Refusal::StandbyWatts)?,
        standby_hours,
    })
}

/// Lit les champs du tarif. **Seuls les prix de l'option choisie sont
/// exigés** : celui qui a vidé le prix Base avant de passer en heures
/// pleines / heures creuses ne s'en voit pas reprocher l'absence — le champ
/// reprend le Tarif Bleu.
pub fn read_tariff(fields: &TariffFields) -> Result<Tariff, Refusal> {
    let off_peak_option = fields.option == "off-peak";
    let price = |text: &str, used: bool, fallback: i64, refusal: Refusal| match parse_price(text) {
        Some(value) => Ok(value),
        None if used => Err(refusal),
        None => Ok(fallback),
    };
    let hours = match parse_number(&fields.off_peak_hours) {
        Some(value) if value.fract() == 0.0 && value <= 24.0 => value as u32,
        _ if !off_peak_option => BLUE_TARIFF.off_peak_hours,
        _ => return Err(Refusal::OffPeakHours),
    };
    Ok(Tariff {
        off_peak_option,
        base: price(&fields.base, !off_peak_option, BLUE_TARIFF.base, Refusal::Base)?,
        peak: price(&fields.peak, off_peak_option, BLUE_TARIFF.peak, Refusal::Peak)?,
        off_peak: price(&fields.off_peak, off_peak_option, BLUE_TARIFF.off_peak, Refusal::OffPeak)?,
        off_peak_hours: hours,
    })
}

/// Le tarif écrit dans ses champs.
pub fn tariff_fields(tariff: &Tariff, language: Language) -> TariffFields {
    TariffFields {
        option: if tariff.off_peak_option { "off-peak" } else { "base" }.to_string(),
        base: price_field(tariff.base, language),
        peak: price_field(tariff.peak, language),
        off_peak: price_field(tariff.off_peak, language),
        off_peak_hours: tariff.off_peak_hours.to_string(),
    }
}

// --- Ce que la fenêtre montre ---------------------------------------------------

/// Une tuile : par jour, par mois, par an.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Period {
    pub label: String,
    pub cost: String,
    pub energy: String,
}

/// Une ligne du détail sur un an.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Line {
    pub label: String,
    pub energy: String,
    pub cost: String,
    pub share: String,
    /// La couleur de sa part dans l'anneau ; vide pour le total.
    pub colour: String,
    pub total: bool,
}

/// **Tout ce que la fenêtre affiche, déjà écrit** dans la langue.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Written {
    pub periods: Vec<Period>,
    pub lines: Vec<Line>,
    pub donut: String,
    /// Les heures de veille retenues, écrites comme dans leur champ : ce que
    /// le champ montre en grisé tant qu'il est vide.
    pub standby_hours: String,
    /// « La veille seule coûte… », s'il y a une veille.
    pub standby_sentence: Option<String>,
}

/// Un nombre écrit à la façon de la langue, milliers groupés.
pub fn decimal(value: f64, decimals: usize, language: Language) -> String {
    let (thousands, decimal) = money::separators(language);
    let text = format!("{:.*}", decimals, value.abs());
    let (whole, fraction) = text.split_once('.').unwrap_or((&text, ""));
    let mut grouped = String::new();
    for (rank, digit) in whole.chars().enumerate() {
        if rank > 0 && (whole.len() - rank) % 3 == 0 {
            grouped.push(thousands);
        }
        grouped.push(digit);
    }
    if !fraction.is_empty() {
        grouped.push(decimal);
        grouped.push_str(fraction);
    }
    grouped
}

/// Une énergie : assez de décimales pour qu'une veille de 1 W ne s'écrive pas
/// « 0 kWh », pas tant qu'une année se lise mal.
pub fn energy(kwh: f64, language: Language) -> String {
    let decimals = match kwh.abs() {
        0.0 => 0,
        value if value < 1.0 => 3,
        value if value < 10.0 => 2,
        value if value < 100.0 => 1,
        _ => 0,
    };
    i18n::message_of(language, "appliance-energy", &[("value", &decimal(kwh, decimals, language))], &[])
}

/// Un coût. **Moins d'un centime n'est pas « 0,00 € »** : la veille d'un jour
/// coûte peu, mais pas rien, et le résultat doit être honnête.
pub fn cost(amount: i64, language: Language) -> String {
    if amount > 0 && amount < UNIT / 100 {
        let cent = money::format(UNIT / 100, language);
        return i18n::message_of(language, "appliance-less-than", &[("amount", &cent)], &[]);
    }
    money::format(amount, language)
}

fn share_of(part: i64, whole: i64, language: Language) -> String {
    let value = if whole > 0 { part as f64 / whole as f64 * 100.0 } else { 0.0 };
    i18n::message_of(language, "loan-percent", &[("value", &format!("{:.0}", value.round()))], &[])
}

/// **Écrit le résultat.**
pub fn write(bill: &Bill, tariff: &Tariff, language: Language) -> Written {
    let text = |key: &str| i18n::text(language, key);
    let periods = [
        ("appliance-period-day", bill.day()),
        ("appliance-period-month", bill.month()),
        ("appliance-period-year", bill.year()),
    ]
    .into_iter()
    .map(|(key, share)| Period {
        label: text(key),
        cost: cost(share.cost, language),
        energy: energy(share.kwh, language),
    })
    .collect();

    let parts: Vec<(&str, Share, &'static str)> = if tariff.off_peak_option {
        vec![
            ("appliance-line-on-peak", bill.on_peak, loan_charts::NAVY),
            ("appliance-line-on-off-peak", bill.on_off_peak, loan_charts::SKY),
            ("appliance-line-standby-peak", bill.standby_peak, loan_charts::GOLD),
            ("appliance-line-standby-off-peak", bill.standby_off_peak, loan_charts::SAND),
        ]
    } else {
        vec![
            ("appliance-line-on", bill.on(), loan_charts::NAVY),
            ("appliance-line-standby", bill.standby(), loan_charts::GOLD),
        ]
    };
    let year = bill.year();
    let mut lines: Vec<Line> = parts
        .iter()
        .map(|(key, share, colour)| Line {
            label: text(key),
            energy: energy(share.kwh, language),
            cost: cost(share.cost, language),
            share: share_of(share.cost, year.cost, language),
            colour: (*colour).to_string(),
            total: false,
        })
        .collect();
    lines.push(Line {
        label: text("appliance-line-total"),
        energy: energy(year.kwh, language),
        cost: cost(year.cost, language),
        share: share_of(year.cost, year.cost, language),
        colour: String::new(),
        total: true,
    });

    let donut = loan_charts::donut(
        &parts
            .iter()
            .map(|(key, share, colour)| Part {
                label: text(key),
                amount: share.cost,
                written: cost(share.cost, language),
                colour,
            })
            .collect::<Vec<_>>(),
        &cost(year.cost, language),
        &text("appliance-chart-caption"),
    );

    let standby = bill.standby();
    let standby_sentence = (standby.kwh > 0.0).then(|| {
        i18n::message_of(
            language,
            "appliance-standby-sentence",
            &[
                ("amount", &cost(standby.cost, language)),
                ("share", &share_of(standby.cost, year.cost, language)),
            ],
            &[],
        )
    });

    Written {
        periods,
        lines,
        donut,
        standby_hours: decimal(bill.standby_hours, if bill.standby_hours.fract() == 0.0 { 0 } else { 1 }, language),
        standby_sentence,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn usage(on_watts: f64, on_hours: f64, days: u32, share: f64, standby_watts: f64) -> Usage {
        Usage { on_watts, on_hours, days, on_off_peak_share: share, standby_watts, standby_hours: None }
    }

    /// Un radiateur de 2 000 W, 5 h par jour, tous les jours, au tarif Base :
    /// 10 kWh par jour, 3 650 kWh par an, 730,37 € par an à 0,2001 €.
    #[test]
    fn un_radiateur_au_tarif_base() {
        let bill = compute(&usage(2000.0, 5.0, 7, 0.0, 0.0), &BLUE_TARIFF).unwrap();
        assert!((bill.year().kwh - 3650.0).abs() < 1e-6);
        assert!((bill.day().kwh - 10.0).abs() < 1e-9);
        assert_eq!(bill.year().cost, 730_365_000);
        assert_eq!(bill.standby().kwh, 0.0);
        // Le reste de la journée est en veille, à 0 W.
        assert_eq!(bill.standby_hours, 19.0);
    }

    /// **La veille compte**, et les jours où l'appareil ne sert pas, il reste
    /// branché : une télévision de 100 W allumée 3 h, 5 jours sur 7, et 1 W de
    /// veille le reste du temps.
    #[test]
    fn la_veille_court_aussi_les_jours_sans_usage() {
        let bill = compute(&usage(100.0, 3.0, 5, 0.0, 1.0), &BLUE_TARIFF).unwrap();
        // Allumé : 0,3 kWh × 5 jours ; veille : 21 h × 5 jours + 24 h × 2 jours.
        let week_on = 100.0 * 3.0 * 5.0 / 1000.0;
        let week_standby = 1.0 * (21.0 * 5.0 + 24.0 * 2.0) / 1000.0;
        assert!((bill.on().kwh - week_on * WEEKS_A_YEAR).abs() < 1e-9);
        assert!((bill.standby().kwh - week_standby * WEEKS_A_YEAR).abs() < 1e-9);
    }

    /// **Heures pleines, heures creuses** : la marche selon la part donnée, la
    /// veille selon les heures creuses du contrat.
    #[test]
    fn les_heures_creuses_se_partagent_comme_il_faut() {
        let tariff = Tariff { off_peak_option: true, ..BLUE_TARIFF };
        let mut asked = usage(3000.0, 4.0, 7, 100.0, 6.0);
        asked.standby_hours = Some(20.0);
        let bill = compute(&asked, &tariff).unwrap();
        // Un chauffe-eau la nuit : toute sa marche en heures creuses.
        assert_eq!(bill.on_peak.kwh, 0.0);
        assert!(bill.on_off_peak.kwh > 0.0);
        // La veille : 8 heures creuses sur 24.
        let standby = bill.standby().kwh;
        assert!((bill.standby_off_peak.kwh - standby / 3.0).abs() < 1e-9);
        assert_eq!(
            bill.on_off_peak.cost,
            (bill.on_off_peak.kwh * 158_900.0).round() as i64
        );
    }

    #[test]
    fn les_champs_hors_limites_sont_refuses() {
        let mut asked = usage(100.0, 20.0, 7, 0.0, 1.0);
        asked.standby_hours = Some(5.0);
        assert_eq!(compute(&asked, &BLUE_TARIFF), Err(Refusal::StandbyHours));
        assert_eq!(compute(&usage(100.0, 25.0, 7, 0.0, 1.0), &BLUE_TARIFF), Err(Refusal::OnHours));
        assert_eq!(compute(&usage(100.0, 2.0, 8, 0.0, 1.0), &BLUE_TARIFF), Err(Refusal::Days));
        assert_eq!(compute(&usage(-1.0, 2.0, 7, 0.0, 1.0), &BLUE_TARIFF), Err(Refusal::OnWatts));
        assert_eq!(compute(&usage(100.0, 2.0, 7, 120.0, 1.0), &BLUE_TARIFF), Err(Refusal::Share));
    }

    #[test]
    fn les_nombres_et_les_prix_se_lisent() {
        assert_eq!(parse_number("1 500,5"), Some(1500.5));
        assert_eq!(parse_number("0.5"), Some(0.5));
        assert_eq!(parse_number("12a"), None);
        assert_eq!(parse_number(""), None);
        assert_eq!(parse_number("-3"), None);
        assert_eq!(parse_price("0,2001"), Some(200_100));
        assert_eq!(parse_price("0,1589 €"), Some(158_900));
        assert_eq!(parse_price("deux"), None);
        assert_eq!(price_field(200_100, Language::French), "0,2001");
        assert_eq!(price_field(214_200, Language::English), "0.2142");
    }

    #[test]
    fn le_tarif_bleu_se_tient() {
        assert!(BLUE_TARIFF.holds());
        assert!(!Tariff { off_peak_hours: 25, ..BLUE_TARIFF }.holds());
        assert!(!Tariff { base: -1, ..BLUE_TARIFF }.holds());
    }

    #[test]
    fn les_champs_se_lisent_et_les_vides_ont_un_sens() {
        let fields = UsageFields {
            on_watts: "1 500".into(),
            on_hours: "2,5".into(),
            days: "5".into(),
            share: "".into(),
            standby_watts: "0.8".into(),
            standby_hours: "".into(),
        };
        let usage = read_usage(&fields).unwrap();
        assert_eq!(usage.on_watts, 1500.0);
        assert_eq!(usage.on_hours, 2.5);
        assert_eq!(usage.days, 5);
        assert_eq!(usage.on_off_peak_share, 0.0);
        assert_eq!(usage.standby_hours, None);
        assert_eq!(read_usage(&UsageFields { days: "5,5".into(), ..fields.clone() }), Err(Refusal::Days));
        assert_eq!(read_usage(&UsageFields { on_watts: "abc".into(), ..fields }), Err(Refusal::OnWatts));
    }

    #[test]
    fn le_tarif_se_lit_et_ne_reclame_que_ses_prix() {
        let language = Language::French;
        let fields = tariff_fields(&BLUE_TARIFF, language);
        assert_eq!(fields.base, "0,2001");
        assert_eq!(read_tariff(&fields), Ok(BLUE_TARIFF));
        let off_peak = TariffFields { option: "off-peak".into(), base: String::new(), ..fields.clone() };
        let read = read_tariff(&off_peak).unwrap();
        assert!(read.off_peak_option);
        assert_eq!(read.base, BLUE_TARIFF.base);
        assert_eq!(
            read_tariff(&TariffFields { peak: "x".into(), ..off_peak.clone() }),
            Err(Refusal::Peak)
        );
        assert_eq!(
            read_tariff(&TariffFields { off_peak_hours: "25".into(), ..off_peak }),
            Err(Refusal::OffPeakHours)
        );
        assert_eq!(read_tariff(&TariffFields { base: "".into(), ..fields }), Err(Refusal::Base));
    }

    /// Le résultat écrit : trois tuiles, le détail avec son total, l'anneau,
    /// et la phrase de la veille.
    #[test]
    fn le_resultat_s_ecrit() {
        let language = Language::French;
        let bill = compute(&usage(2000.0, 5.0, 7, 0.0, 1.0), &BLUE_TARIFF).unwrap();
        let written = write(&bill, &BLUE_TARIFF, language);
        assert_eq!(written.periods.len(), 3);
        assert_eq!(written.periods[0].label, "Par jour");
        assert!(written.periods[0].energy.contains("kWh"), "{:?}", written.periods[0]);
        assert_eq!(written.lines.len(), 3);
        assert!(written.lines[2].total);
        assert_eq!(written.lines[2].share, "100 %");
        assert!(written.donut.starts_with("<svg"));
        assert_eq!(written.standby_hours, "19");
        assert!(written.standby_sentence.unwrap().contains("veille"));

        let tariff = Tariff { off_peak_option: true, ..BLUE_TARIFF };
        let bill = compute(&usage(2000.0, 5.0, 7, 50.0, 0.0), &tariff).unwrap();
        let written = write(&bill, &tariff, language);
        assert_eq!(written.lines.len(), 5);
        assert_eq!(written.standby_sentence, None);
    }

    #[test]
    fn les_nombres_s_ecrivent_et_le_centime_ne_ment_pas() {
        let language = Language::French;
        assert_eq!(decimal(3650.0, 0, language), "3\u{202f}650");
        assert_eq!(decimal(0.024, 3, language), "0,024");
        assert_eq!(energy(0.024, language), "0,024 kWh");
        assert_eq!(cost(4_800, language), format!("moins de {}", money::format(10_000, language)));
    }
}
