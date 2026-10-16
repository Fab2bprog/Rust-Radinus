//! Les graphiques de la simulation de crédit, dessinés en SVG par le noyau.
//!
//! **Un seul dessin pour l'écran et pour le papier.** La fenêtre pose ces SVG
//! tels quels, et le rapport PDF les donne à Typst : on retrouve dans l'un
//! exactement ce qu'on a vu dans l'autre — c'était la promesse faite à
//! Fabrice le 08/10/2026, « les mêmes couleurs et les mêmes graphiques que
//! dans la fenêtre, pour qu'on reconnaisse l'une dans l'autre ». Une capture
//! d'écran aurait dépendu du système et de la taille de la fenêtre ; ce dessin
//! sort identique partout, et net à l'impression.
//!
//! **Aucune bibliothèque de graphiques**, comme pour l'anneau et la courbe de
//! l'accueil : des arcs, des rectangles et des segments.
//!
//! **Ce module ne parle aucune langue** : il reçoit ses mots déjà écrits. Il
//! ne fait que mettre les montants des axes en forme, dans la langue qu'on lui
//! donne.
//!
//! « Je veux quelque chose de beau qui fasse classe » (Fabrice, 08/10/2026) :
//! une palette retenue — un bleu nuit, un or, des gris bleutés — et les trois
//! couleurs du voyant réservées à ce qui juge, pour qu'elles sautent aux yeux.

use crate::i18n::Language;
use crate::money;

// --- La palette -------------------------------------------------------------

pub const INK: &str = "#1d2b34";
pub const MUTED: &str = "#6b7a88";
pub const GRID: &str = "#e3e8ed";
pub const NAVY: &str = "#24506e";
pub const GOLD: &str = "#c39a3c";
pub const SKY: &str = "#8eb2cb";
pub const SLATE: &str = "#56748c";
pub const SAND: &str = "#d9b77a";
pub const GREEN: &str = "#2e9a6a";
pub const ORANGE: &str = "#e48f2e";
pub const RED: &str = "#cf4436";

const FONT: &str = "Lato, 'Helvetica Neue', 'Segoe UI', Arial, sans-serif";

/// La couleur d'un verdict.
pub fn verdict_colour(verdict: crate::loan::Verdict) -> &'static str {
    match verdict {
        crate::loan::Verdict::Green => GREEN,
        crate::loan::Verdict::Orange => ORANGE,
        crate::loan::Verdict::Red => RED,
    }
}

/// Un texte posé dans du SVG : les cinq caractères qui le casseraient sont
/// échappés. Un libellé de crédit en cours vient de l'utilisateur.
pub fn escape(text: &str) -> String {
    let mut out = String::with_capacity(text.len());
    for c in text.chars() {
        match c {
            '&' => out.push_str("&amp;"),
            '<' => out.push_str("&lt;"),
            '>' => out.push_str("&gt;"),
            '"' => out.push_str("&quot;"),
            '\'' => out.push_str("&#39;"),
            _ => out.push(c),
        }
    }
    out
}

/// Un montant à l'euro près, pour les axes : « 12 000 € » et non
/// « 12 000,00 € » — les centimes n'ont rien à faire sur une graduation.
pub fn euros(amount: i64, language: Language) -> String {
    let rounded = ((amount as f64 / money::UNIT as f64).round() as i64) * money::UNIT;
    let written = money::format(rounded, language);
    let (_, decimal) = money::separators(language);
    written.replacen(&format!("{decimal}00"), "", 1)
}

pub(crate) fn svg_open(width: f64, height: f64, class: &str) -> String {
    format!(
        "<svg xmlns=\"http://www.w3.org/2000/svg\" class=\"loan-chart {class}\" \
         viewBox=\"0 0 {width} {height}\" width=\"{width}\" height=\"{height}\" \
         font-family=\"{FONT}\" role=\"img\">"
    )
}

pub(crate) fn text(x: f64, y: f64, size: f64, fill: &str, anchor: &str, weight: &str, content: &str) -> String {
    format!(
        "<text x=\"{x:.1}\" y=\"{y:.1}\" font-size=\"{size}\" fill=\"{fill}\" \
         text-anchor=\"{anchor}\" font-weight=\"{weight}\">{}</text>",
        escape(content)
    )
}

/// Un point du cercle de centre `(cx, cy)` et de rayon `r`, à l'angle
/// `degrees` compté depuis le haut, dans le sens des aiguilles d'une montre.
pub(crate) fn on_circle(cx: f64, cy: f64, r: f64, degrees: f64) -> (f64, f64) {
    let radians = (degrees - 90.0).to_radians();
    (cx + r * radians.cos(), cy + r * radians.sin())
}

/// Un secteur d'anneau, de `from` à `to` degrés.
pub(crate) fn ring_slice(cx: f64, cy: f64, outer: f64, inner: f64, from: f64, to: f64) -> String {
    // Un secteur plein ne se dessine pas d'un seul arc : ses deux bouts
    // seraient le même point. Il s'arrête un souffle avant.
    let to = if to - from >= 360.0 { from + 359.999 } else { to };
    let large = if to - from > 180.0 { 1 } else { 0 };
    let (x1, y1) = on_circle(cx, cy, outer, from);
    let (x2, y2) = on_circle(cx, cy, outer, to);
    let (x3, y3) = on_circle(cx, cy, inner, to);
    let (x4, y4) = on_circle(cx, cy, inner, from);
    format!(
        "M {x1:.2} {y1:.2} A {outer} {outer} 0 {large} 1 {x2:.2} {y2:.2} \
         L {x3:.2} {y3:.2} A {inner} {inner} 0 {large} 0 {x4:.2} {y4:.2} Z"
    )
}

// --- La jauge d'endettement -------------------------------------------------

/// Où la jauge s'arrête : 60 %. Au-delà, l'aiguille reste en butée — le
/// chiffre écrit dessous dit le reste.
pub const GAUGE_TOP: f64 = 60.0;

/// L'angle de l'aiguille, en degrés : 0 pour 0 %, 180 pour la butée.
pub fn gauge_angle(ratio: Option<f64>) -> f64 {
    ratio.map_or(0.0, |value| (value / GAUGE_TOP).clamp(0.0, 1.0) * 180.0)
}

/// **La jauge en demi-cercle**, en trois zones : vert jusqu'à 33 %, orange
/// jusqu'à 35 %, rouge au-delà. L'aiguille porte son angle en `data-angle` :
/// la fenêtre la fait glisser d'une position à l'autre quand on bouge un
/// curseur, au lieu de la faire sauter.
///
/// `figure` est le chiffre écrit au centre — « 28 % », ou un tiret quand
/// l'endettement ne se calcule pas —, `caption` la ligne sous lui.
///
/// Les deux frontières sont celles de la méthode de jugement retenue : 33 et
/// 35 % pour la neutre, 35 et 40 % pour l'optimiste, 30 et 33 % pour la
/// sévère.
pub fn gauge(ratio: Option<f64>, figure: &str, caption: &str, green: f64, red: f64) -> String {
    // Le chiffre se pose **sous** le pivot, et non dans l'arc : l'aiguille le
    // barrait dès qu'elle passait au-dessus.
    let (cx, cy, outer, inner) = (160.0, 150.0, 128.0, 100.0);
    let mut out = svg_open(320.0, 226.0, "loan-chart--gauge");
    // La piste, puis les trois zones, d'un demi-tour de gauche à droite.
    let degrees = |percent: f64| -90.0 + percent / GAUGE_TOP * 180.0;
    out.push_str(&format!(
        "<path d=\"{}\" fill=\"{GRID}\"/>",
        ring_slice(cx, cy, outer, inner, -90.0, 90.0)
    ));
    for (from, to, colour) in [
        (0.0, green, GREEN),
        (green, red, ORANGE),
        (red, GAUGE_TOP, RED),
    ] {
        out.push_str(&format!(
            "<path d=\"{}\" fill=\"{colour}\" fill-opacity=\"0.88\"/>",
            ring_slice(cx, cy, outer, inner, degrees(from), degrees(to))
        ));
    }
    // Les graduations aux frontières.
    let green_label = format!("{green:.0}");
    for (percent, label) in [(0.0, "0"), (green, green_label.as_str()), (GAUGE_TOP, "60")] {
        let (x, y) = on_circle(cx, cy, outer + 12.0, degrees(percent));
        let anchor = if percent == 0.0 {
            "end"
        } else if percent == GAUGE_TOP {
            "start"
        } else {
            "middle"
        };
        out.push_str(&text(x, y + 4.0, 11.0, MUTED, anchor, "normal", label));
    }
    // L'aiguille : dessinée couchée vers la gauche, puis tournée.
    let angle = gauge_angle(ratio);
    if ratio.is_some() {
        out.push_str(&format!(
            "<g class=\"gauge-needle\" data-angle=\"{angle:.2}\" \
             transform=\"rotate({angle:.2} {cx} {cy})\">\
             <path d=\"M {} {cy} L {cx} {} L {} {cy} L {cx} {} Z\" fill=\"{INK}\"/>\
             </g>",
            cx - outer + 8.0,
            cy - 6.0,
            cx + 10.0,
            cy + 6.0,
        ));
    }
    out.push_str(&format!(
        "<circle cx=\"{cx}\" cy=\"{cy}\" r=\"9\" fill=\"{INK}\"/>\
         <circle cx=\"{cx}\" cy=\"{cy}\" r=\"3.5\" fill=\"#ffffff\"/>"
    ));
    out.push_str(&text(cx, cy + 46.0, 32.0, INK, "middle", "bold", figure));
    out.push_str(&text(cx, cy + 66.0, 12.0, MUTED, "middle", "normal", caption));
    out.push_str("</svg>");
    out
}

// --- L'anneau ---------------------------------------------------------------

/// Une part d'anneau : son nom, son montant, sa couleur. Le montant écrit est
/// celui de la légende.
pub struct Part {
    pub label: String,
    pub amount: i64,
    pub written: String,
    pub colour: &'static str,
}

/// **Un anneau à plat et sa légende**, côte à côte. Les parts nulles restent
/// dans la légende — « Frais de dossier : 0,00 € » est une réponse —, mais ne
/// prennent pas de place dans l'anneau.
///
/// Au centre, `figure` en grand et `caption` dessous.
pub fn donut(parts: &[Part], figure: &str, caption: &str) -> String {
    let (cx, cy, outer, inner) = (110.0, 110.0, 96.0, 64.0);
    let height = (parts.len() as f64 * 30.0 + 40.0).max(220.0);
    let mut out = svg_open(500.0, height, "loan-chart--donut");
    let total: i64 = parts.iter().map(|part| part.amount.max(0)).sum();
    if total <= 0 {
        out.push_str(&format!(
            "<path d=\"{}\" fill=\"{GRID}\"/>",
            ring_slice(cx, cy, outer, inner, 0.0, 360.0)
        ));
    } else {
        let mut from = 0.0;
        for part in parts.iter().filter(|part| part.amount > 0) {
            let sweep = part.amount as f64 / total as f64 * 360.0;
            out.push_str(&format!(
                "<path d=\"{}\" fill=\"{}\" stroke=\"#ffffff\" stroke-width=\"2\">\
                 <title>{} — {}</title></path>",
                ring_slice(cx, cy, outer, inner, from, from + sweep),
                part.colour,
                escape(&part.label),
                escape(&part.written),
            ));
            from += sweep;
        }
    }
    out.push_str(&text(cx, cy + 4.0, 19.0, INK, "middle", "bold", figure));
    out.push_str(&text(cx, cy + 22.0, 11.0, MUTED, "middle", "normal", caption));

    // La légende : la pastille, le nom, la part en pourcent, le montant.
    let top = (height - parts.len() as f64 * 30.0) / 2.0 + 10.0;
    for (rank, part) in parts.iter().enumerate() {
        let y = top + rank as f64 * 30.0;
        out.push_str(&format!(
            "<rect x=\"238\" y=\"{:.1}\" width=\"12\" height=\"12\" rx=\"3\" fill=\"{}\"/>",
            y - 10.0,
            part.colour
        ));
        out.push_str(&text(258.0, y, 13.0, INK, "start", "normal", &part.label));
        out.push_str(&text(496.0, y, 13.0, INK, "end", "bold", &part.written));
        if total > 0 {
            let share = (part.amount.max(0) as f64 / total as f64 * 100.0).round();
            out.push_str(&text(258.0, y + 14.0, 10.0, MUTED, "start", "normal", &format!("{share:.0} %")));
        }
    }
    out.push_str("</svg>");
    out
}

// --- Les axes ---------------------------------------------------------------

/// Des graduations rondes entre `low` et `high` : 1, 2 ou 5 fois une puissance
/// de dix, quatre ou cinq traits.
pub(crate) fn ticks(low: i64, high: i64) -> Vec<i64> {
    let span = (high - low).max(1) as f64;
    let raw = span / 4.0;
    let power = 10f64.powf(raw.log10().floor());
    let step = [1.0, 2.0, 2.5, 5.0, 10.0]
        .iter()
        .map(|factor| factor * power)
        .find(|candidate| *candidate >= raw)
        .unwrap_or(10.0 * power);
    let first = (low as f64 / step).floor() * step;
    // On va jusqu'à la première graduation qui couvre le plus haut point.
    let mut out = Vec::new();
    let mut value = first;
    loop {
        out.push(value.round() as i64);
        if value >= high as f64 - step * 0.001 || out.len() > 12 {
            break;
        }
        value += step;
    }
    out
}

pub(crate) struct Frame {
    pub(crate) left: f64,
    pub(crate) right: f64,
    pub(crate) top: f64,
    pub(crate) bottom: f64,
    pub(crate) low: i64,
    pub(crate) high: i64,
}

impl Frame {
    pub(crate) fn y(&self, value: i64) -> f64 {
        let span = (self.high - self.low).max(1) as f64;
        self.bottom - (value - self.low) as f64 / span * (self.bottom - self.top)
    }
}

/// Le cadre d'un graphique : les graduations horizontales et leurs montants.
pub(crate) fn axes(out: &mut String, frame: &Frame, values: &[i64], language: Language) {
    for tick in values {
        let y = frame.y(*tick);
        let colour = if *tick == 0 { MUTED } else { GRID };
        out.push_str(&format!(
            "<line x1=\"{}\" y1=\"{y:.1}\" x2=\"{}\" y2=\"{y:.1}\" stroke=\"{colour}\" stroke-width=\"1\"/>",
            frame.left, frame.right
        ));
        out.push_str(&text(frame.left - 8.0, y + 4.0, 12.0, MUTED, "end", "normal", &euros(*tick, language)));
    }
}

pub(crate) fn bounds_of(values: impl Iterator<Item = i64>) -> (i64, i64) {
    let (mut low, mut high) = (0_i64, 0_i64);
    for value in values {
        low = low.min(value);
        high = high.max(value);
    }
    if low == high {
        high = low + money::UNIT;
    }
    (low, high)
}

// --- Les barres -------------------------------------------------------------

/// Une barre : ce qu'elle dit sous l'axe, sa valeur, et son montant écrit pour
/// la bulle.
pub struct Bar {
    pub label: String,
    pub value: i64,
    pub written: String,
    /// Le mois était déjà dans le rouge sans le crédit : il se peint d'un
    /// rouge pâle, et seul le mois que le crédit fait basculer reste d'un
    /// rouge vif (08/10/2026).
    pub already: bool,
}

/// Le rouge pâle des mois qui l'étaient déjà sans le crédit.
pub const PALE_RED: &str = "#eba49b";

/// **Les barres de l'historique** : une par mois, ce qui serait resté une fois
/// la mensualité payée. Un mois que le crédit fait passer dans le rouge est
/// d'un rouge vif — c'est lui qu'on cherche des yeux ; un mois qui y était
/// déjà sans lui, d'un rouge pâle : ce n'est pas le crédit qui l'y a mis.
pub fn bars(bars: &[Bar], language: Language) -> String {
    let (width, height) = (680.0, 250.0);
    let mut out = svg_open(width, height, "loan-chart--bars");
    let (low, high) = bounds_of(bars.iter().map(|bar| bar.value));
    let marks = ticks(low, high);
    let frame = Frame {
        left: 96.0,
        right: width - 12.0,
        top: 14.0,
        bottom: height - 34.0,
        low: *marks.first().unwrap_or(&low),
        high: *marks.last().unwrap_or(&high),
    };
    axes(&mut out, &frame, &marks, language);
    let slot = (frame.right - frame.left) / bars.len().max(1) as f64;
    let thickness = (slot * 0.62).min(38.0);
    let zero = frame.y(0);
    // **Une plage d'années donne jusqu'à soixante-neuf barres** (10/10/2026) :
    // toutes restent, plus fines, mais une étiquette sur deux, sur trois…
    // pour qu'elles ne se chevauchent pas — douze au plus.
    let every = bars.len().div_ceil(12).max(1);
    for (rank, bar) in bars.iter().enumerate() {
        let x = frame.left + slot * rank as f64 + (slot - thickness) / 2.0;
        let y = frame.y(bar.value);
        let (top, size) = if bar.value >= 0 { (y, zero - y) } else { (zero, y - zero) };
        let tipped = bar.value < 0 && !bar.already;
        let colour = if bar.value >= 0 {
            SLATE
        } else if bar.already {
            PALE_RED
        } else {
            RED
        };
        out.push_str(&format!(
            "<rect x=\"{x:.1}\" y=\"{top:.1}\" width=\"{thickness:.1}\" height=\"{:.1}\" rx=\"3\" \
             fill=\"{colour}\"><title>{} — {}</title></rect>",
            size.max(1.0),
            escape(&bar.label),
            escape(&bar.written)
        ));
        if rank % every != 0 {
            continue;
        }
        out.push_str(&text(
            x + thickness / 2.0,
            height - 12.0,
            12.0,
            if tipped { RED } else { MUTED },
            "middle",
            if tipped { "bold" } else { "normal" },
            &bar.label,
        ));
    }
    out.push_str("</svg>");
    out
}

// --- La courbe --------------------------------------------------------------

/// Un point de courbe : son étiquette d'axe, sa valeur, et sa bulle.
pub struct Point {
    pub label: String,
    pub value: i64,
    pub written: String,
}

/// **Une courbe et son aire**, de gauche à droite. Ce qui passe sous zéro est
/// teinté de rouge ; `mark` pose un trait vertical à un rang donné, avec son
/// mot — la fin d'un crédit en cours, ou le premier mois dans le rouge.
///
/// `name` distingue les découpes de deux courbes posées dans la même page :
/// deux `clipPath` du même nom, et la seconde courbe prendrait la découpe de
/// la première.
pub fn line(
    points: &[Point],
    colour: &str,
    marks: &[(usize, String)],
    language: Language,
    name: &str,
    floor: Option<(i64, &str)>,
) -> String {
    let (width, height) = (680.0, 250.0);
    let mut out = svg_open(width, height, "loan-chart--line");
    let (low, high) = bounds_of(
        points
            .iter()
            .map(|point| point.value)
            .chain(floor.map(|(value, _)| value)),
    );
    let graduations = ticks(low, high);
    let frame = Frame {
        left: 96.0,
        right: width - 24.0,
        top: 16.0,
        bottom: height - 34.0,
        low: *graduations.first().unwrap_or(&low),
        high: *graduations.last().unwrap_or(&high),
    };
    axes(&mut out, &frame, &graduations, language);
    if points.is_empty() {
        out.push_str("</svg>");
        return out;
    }
    let span = (points.len().max(2) - 1) as f64;
    let x = |rank: usize| frame.left + rank as f64 / span * (frame.right - frame.left);
    let zero = frame.y(0).clamp(frame.top, frame.bottom);

    let path: Vec<String> = points
        .iter()
        .enumerate()
        .map(|(rank, point)| format!("{:.1} {:.1}", x(rank), frame.y(point.value)))
        .collect();
    let area = format!(
        "M {:.1} {zero:.1} L {} L {:.1} {zero:.1} Z",
        x(0),
        path.join(" L "),
        x(points.len() - 1)
    );
    // L'aire au-dessus de zéro dans la couleur de la courbe, celle du dessous
    // en rouge : deux découpes de la même aire.
    out.push_str(&format!(
        "<defs><clipPath id=\"{name}-above\"><rect x=\"0\" y=\"0\" width=\"{width}\" height=\"{zero:.1}\"/></clipPath>\
         <clipPath id=\"{name}-below\"><rect x=\"0\" y=\"{zero:.1}\" width=\"{width}\" height=\"{height}\"/></clipPath></defs>"
    ));
    out.push_str(&format!(
        "<path d=\"{area}\" fill=\"{colour}\" fill-opacity=\"0.16\" clip-path=\"url(#{name}-above)\"/>\
         <path d=\"{area}\" fill=\"{RED}\" fill-opacity=\"0.18\" clip-path=\"url(#{name}-below)\"/>"
    ));
    out.push_str(&format!(
        "<path d=\"M {}\" fill=\"none\" stroke=\"{colour}\" stroke-width=\"2.4\" \
         stroke-linejoin=\"round\" stroke-linecap=\"round\"/>",
        path.join(" L ")
    ));
    // **La réserve de sécurité** de la méthode sévère : un trait pointillé
    // rouge à sa hauteur, et son nom au bout. Le solde ne doit pas passer
    // dessous.
    if let Some((value, label)) = floor {
        let at = frame.y(value);
        out.push_str(&format!(
            "<line x1=\"{}\" y1=\"{at:.1}\" x2=\"{}\" y2=\"{at:.1}\" stroke=\"{RED}\" \
             stroke-width=\"1.4\" stroke-dasharray=\"6 4\"/>",
            frame.left, frame.right
        ));
        out.push_str(&text(frame.right, at - 5.0, 11.0, RED, "end", "bold", label));
    }
    for (rank, label) in marks {
        if *rank >= points.len() {
            continue;
        }
        let at = x(*rank);
        out.push_str(&format!(
            "<line x1=\"{at:.1}\" y1=\"{}\" x2=\"{at:.1}\" y2=\"{}\" stroke=\"{GOLD}\" \
             stroke-width=\"1.4\" stroke-dasharray=\"4 3\"/>",
            frame.top,
            frame.bottom
        ));
        let anchor = if at > frame.right - 120.0 { "end" } else { "start" };
        let shift = if anchor == "end" { -5.0 } else { 5.0 };
        out.push_str(&text(at + shift, frame.top + 11.0, 12.0, GOLD, anchor, "bold", label));
    }
    // Des étiquettes d'axe, six au plus, réparties.
    let every = points.len().div_ceil(6).max(1);
    for (rank, point) in points.iter().enumerate() {
        // La dernière étiquette s'aligne sur la fin de l'axe : centrée, elle
        // sortait du dessin. Et elle ne chevauche pas sa voisine.
        let last = rank == points.len() - 1;
        if last || (rank % every == 0 && points.len() - 1 - rank > every / 2) {
            let anchor = if last { "end" } else if rank == 0 { "start" } else { "middle" };
            let at = if last { x(rank) + 4.0 } else { x(rank) };
            out.push_str(&text(at, height - 12.0, 12.0, MUTED, anchor, "normal", &point.label));
        }
    }
    // Les bulles : un point invisible par mois, assez large pour être visé.
    let reach = ((frame.right - frame.left) / span).clamp(3.0, 14.0);
    for (rank, point) in points.iter().enumerate() {
        out.push_str(&format!(
            "<circle cx=\"{:.1}\" cy=\"{:.1}\" r=\"{reach:.1}\" fill=\"transparent\">\
             <title>{} — {}</title></circle>",
            x(rank),
            frame.y(point.value),
            escape(&point.label),
            escape(&point.written)
        ));
    }
    out.push_str("</svg>");
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    const EURO: i64 = money::UNIT;

    #[test]
    fn les_axes_ont_des_graduations_rondes() {
        assert_eq!(ticks(0, 10_000 * EURO), vec![0, 2_500 * EURO, 5_000 * EURO, 7_500 * EURO, 10_000 * EURO]);
        let mixed = ticks(-1_300 * EURO, 2_100 * EURO);
        assert!(mixed.contains(&0));
        assert!(*mixed.first().unwrap() <= -1_300 * EURO && *mixed.last().unwrap() >= 2_100 * EURO);
    }

    #[test]
    fn un_montant_d_axe_s_ecrit_sans_centimes() {
        assert_eq!(euros(12_000 * EURO, Language::French), "12\u{202f}000 €");
        assert_eq!(euros(-1_499_600_000, Language::English), "-€1,500");
    }

    #[test]
    fn la_jauge_tourne_et_bute() {
        assert_eq!(gauge_angle(Some(0.0)), 0.0);
        assert_eq!(gauge_angle(Some(30.0)), 90.0);
        assert_eq!(gauge_angle(Some(400.0)), 180.0);
        let drawn = gauge(Some(30.0), "30 %", "endettement", 33.0, 35.0);
        assert!(drawn.contains("data-angle=\"90.00\""));
        // Sans revenu, pas d'aiguille : la jauge ne ment pas.
        assert!(!gauge(None, "—", "", 33.0, 35.0).contains("gauge-needle"));
    }

    /// Un libellé venu de l'utilisateur ne casse pas le dessin.
    #[test]
    fn un_libelle_est_echappe() {
        let drawn = donut(
            &[Part { label: "Prêt <auto> & \"moto\"".into(), amount: 10, written: "1 €".into(), colour: NAVY }],
            "1 €",
            "",
        );
        assert!(drawn.contains("Prêt &lt;auto&gt; &amp; &quot;moto&quot;"));
        assert!(!drawn.contains("<auto>"));
    }
}
