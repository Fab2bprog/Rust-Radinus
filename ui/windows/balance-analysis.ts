// F40 — « Analyse Évolution du solde » (Fabrice, 05/10/2026).
//
// Le graphique de F25, et dessous le tableau du détail des statistiques. Le
// lien entre les deux est un geste : « lorsque l'utilisateur clique sur le
// graphique et maintient la souris appuyée, il trace le début et la fin d'une
// zone temporelle. On pourrait imaginer une barre verticale, puis au fur et à
// mesure que l'on maintient le clic en avançant on colore une zone, et à ce
// moment-là le détail des opérations apparaît dans le tableau du bas pour les
// comptes qui avaient été sélectionnés. »
//
// **Le dessin du graphique est une copie de celui de F25**, et c'est voulu.
// J'avais proposé de le partager ; Fabrice : « recopie le code pour qu'il soit
// indépendant ». F25 n'est donc pas touchée — « on se concentre sur le
// solde » — et cette fenêtre-ci, « une vision plus approfondie », peut évoluer
// sans elle. **Ce que cela coûte se sait** : une correction du tracé est à
// faire deux fois. Tout ce qui est entre « Les couleurs » et « La lecture »
// vient de `balance-curves.ts` ; ce qui est propre à F40 — la zone, le résumé,
// le tableau — est signalé comme tel.
//
// **Le noyau tient les deux bouts** (`balance_curve::zone`) : la zone est
// calculée à côté de la courbe, sur la même définition du solde. La variation
// du résumé est donc, au centime, la somme des lignes du tableau.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askForWholeNumber } from "./dialog";
import { type MenuAddition } from "./export";
import { buildPeriodMenu, wholeYear, type Period } from "./period";
import { Table } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

const PARAMETERS_EVENT = "window-parameters:balance-analysis";
const CHANGED_EVENT = "data-changed:balance-analysis";

interface Step {
  date: string;
  value: number;
  text: string;
}

interface Curve {
  account_id: number;
  label: string;
  steps: Step[];
  is_total: boolean;
}

interface Curves {
  curves: Curve[];
  lowest: number;
  highest: number;
  year: number;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

let accountIds: number[] = [];
/// La période regardée. **Par défaut l'année en cours** (Fabrice, 26/07/2026 :
/// une courbe sur un mois ne montre pas grand-chose, une année a du relief) —
/// c'est la seule fenêtre où le défaut n'est pas le mois.
let period: Period = wholeYear(new Date().getFullYear());
let shown: Curves | null = null;

// --- La zone (propre à F40) -----------------------------------------------

/// **La zone tracée**, par ses deux jours, bornes comprises — des numéros de
/// jour, comme tout ce qui se place sur l'axe du temps. Rien tant qu'on n'en a
/// pas tracé ; elle reste jusqu'à ce qu'on en trace une autre, et s'efface
/// quand la période, l'année ou les comptes changent : elle ne voudrait plus
/// dire la même chose.
let zone: { from: number; to: number } | null = null;

/// Le geste en cours : le jour où l'on a appuyé, et celui où est le pointeur.
let dragging: { anchor: number; now: number } | null = null;

/// Ce que le noyau rend d'une zone : son résumé, déjà écrit en monnaie, et
/// ses opérations.
interface Zone {
  opening: string;
  closing: string;
  variation: string;
  debit: string;
  credit: string;
  variation_value: number;
  rows: DetailRow[];
}

/// Une ligne du tableau : une opération **mère**, et le compte qui la porte.
interface DetailRow {
  id: number;
  account: string;
  label: string;
  date: string;
  clearing_date: string;
  /// Les deux mêmes dates en ISO : c'est sur elles que les colonnes se trient.
  date_value: string;
  clearing_date_value: string;
  category: string;
  assignment: string;
  payment_mode: string;
  payee: string;
  project: string;
  debit: string;
  credit: string;
  amount: number;
  has_comment: boolean;
  comment: string;
  category_id: number;
  assignment_id: number;
  payment_mode_id: number;
  payee_id: number;
  project_id: number;
  verification_id: number;
}

interface Item {
  id: number;
  label: string;
}

interface Combos {
  category: Item[];
  assignment: Item[];
  payment_mode: Item[];
  payee: Item[];
  project: Item[];
}

let combos: Combos = { category: [], assignment: [], payment_mode: [], payee: [], project: [] };
let verifications: Item[] = [];

// --- Les couleurs ---------------------------------------------------------
//
// **Mesurées, pas choisies.** Chaque teinte a été passée au validateur : bande
// de clarté, saturation minimale, et surtout séparation sous les trois
// daltonismes courants. L'ordre lui-même compte — deux teintes voisines de la
// liste sont celles qui risquent le plus de se retrouver côte à côte, et le
// vert et le rose ont dû être écartés l'un de l'autre pour passer.
//
// **Elles sont attribuées dans cet ordre fixe et ne tournent jamais** : un
// compte garde sa couleur quel que soit le nombre de courbes affichées, sinon
// décocher un compte repeindrait tous les autres.
const COLOURS = [
  "#0072B2",
  "#D55E00",
  "#009E73",
  "#7B5BA6",
  "#CC79A7",
  "#8A9A00",
  "#00A0A8",
  "#B05C00",
];

/// Le total n'est pas un compte de plus : c'est leur somme. Il porte donc un
/// gris ardoise et un trait plus épais, et non une neuvième teinte qui le
/// ferait passer pour un compte parmi les autres.
const TOTAL_COLOUR = "#33475B";

function colourOf(curve: Curve, rank: number): string {
  return curve.is_total ? TOTAL_COLOUR : COLOURS[rank % COLOURS.length];
}

// --- Le tracé -------------------------------------------------------------

const WIDTH = 1000;
const HEIGHT = 460;
const LEFT = 78;
const RIGHT = 18;
const TOP = 14;
const BOTTOM = 42;

const namespace = "http://www.w3.org/2000/svg";
const make = (name: string): SVGElement => document.createElementNS(namespace, name);

/// Le jour en nombre, pour placer un point sur l'axe.
///
/// **Le `Z` n'est pas décoratif.** Sans lui, `Date.parse` lit la date dans le
/// fuseau du poste : à Paris en été, « 2026-07-01 » devient le 30 juin à 22 h
/// UTC, et comme la mise en forme relit les champs UTC, un mois de juillet
/// s'affichait comme commençant le 30 juin (signalé par Fabrice, 26/07/2026).
/// Tout se passe donc en UTC d'un bout à l'autre : les numéros de jour sont des
/// entiers exacts, et une date revient identique à elle-même.
function dayNumber(iso: string): number {
  return Date.parse(`${iso}T00:00:00Z`) / 86_400_000;
}

/// Une graduation ronde pour l'axe des soldes : 1, 2, 5 fois une puissance de
/// dix. Une échelle graduée de 3 719 en 3 719 ne se lit pas.
function niceStep(span: number): number {
  const rough = span / 6;
  const power = 10 ** Math.floor(Math.log10(Math.max(rough, 1)));
  for (const factor of [1, 2, 5, 10]) {
    if (power * factor >= rough) {
      return power * factor;
    }
  }
  return power * 10;
}

interface Scale {
  x: (iso: string) => number;
  y: (value: number) => number;
  lowest: number;
  highest: number;
  step: number;
}

function scaleOf(curves: Curves): Scale {
  const first = dayNumber(period.from);
  const last = Math.max(dayNumber(period.to), first + 1);

  // Une échelle plate — tout à la même valeur — n'aurait aucune hauteur : on
  // l'écarte pour que la courbe ne soit pas collée à un bord.
  let low = Math.min(curves.lowest, 0);
  let high = Math.max(curves.highest, 0);
  if (high - low < 1) {
    low -= 1_000_000;
    high += 1_000_000;
  }
  const step = niceStep(high - low);
  low = Math.floor(low / step) * step;
  high = Math.ceil(high / step) * step;

  return {
    x: (iso) =>
      LEFT + ((dayNumber(iso) - first) / (last - first)) * (WIDTH - LEFT - RIGHT),
    y: (value) =>
      TOP + (1 - (value - low) / (high - low)) * (HEIGHT - TOP - BOTTOM),
    lowest: low,
    highest: high,
    step,
  };
}

/// Le tracé d'une courbe **en escalier** : on va tout droit jusqu'au jour du
/// changement, puis on saute à la verticale.
function stepPath(curve: Curve, scale: Scale): string {
  const parts: string[] = [];
  curve.steps.forEach((step, index) => {
    const x = scale.x(step.date);
    const y = scale.y(step.value);
    if (index === 0) {
      parts.push(`M ${x.toFixed(1)} ${y.toFixed(1)}`);
      return;
    }
    // Le palier, puis la marche.
    parts.push(`L ${x.toFixed(1)} ${scale.y(curve.steps[index - 1].value).toFixed(1)}`);
    parts.push(`L ${x.toFixed(1)} ${y.toFixed(1)}`);
  });
  return parts.join(" ");
}

/// Ce que vaut une courbe un jour donné : la dernière marche à cette date ou
/// avant. La même règle que dans le noyau, parce que l'infobulle doit dire
/// exactement ce que le tracé montre.
function valueAt(curve: Curve, day: number): Step | null {
  let found: Step | null = null;
  for (const step of curve.steps) {
    if (dayNumber(step.date) > day) {
      break;
    }
    found = step;
  }
  return found ?? curve.steps[0] ?? null;
}

/// Les graduations du temps : une dizaine, à des dates rondes, et libellées
/// selon la durée regardée. Un axe muet n'aide personne.
function timeTicks(): { iso: string; label: string }[] {
  const first = dayNumber(period.from);
  const last = Math.max(dayNumber(period.to), first + 1);
  const span = last - first;
  const ticks: { iso: string; label: string }[] = [];

  const pad = (value: number): string => String(value).padStart(2, "0");
  const push = (date: Date, label: string): void => {
    const iso = `${date.getUTCFullYear()}-${pad(date.getUTCMonth() + 1)}-${pad(
      date.getUTCDate(),
    )}`;
    if (dayNumber(iso) >= first && dayNumber(iso) <= last) {
      ticks.push({ iso, label });
    }
  };

  if (span > 400) {
    // Plus d'un an : une graduation par trimestre.
    const start = new Date(first * 86_400_000);
    for (let year = start.getUTCFullYear(); ticks.length < 40; year += 1) {
      for (const month of [0, 3, 6, 9]) {
        push(new Date(Date.UTC(year, month, 1)), `${pad(month + 1)}/${year}`);
      }
      if (Date.UTC(year, 0, 1) > last * 86_400_000) {
        break;
      }
    }
    return ticks;
  }
  if (span > 45) {
    // De deux mois à un an : le premier de chaque mois.
    const start = new Date(first * 86_400_000);
    let cursor = new Date(Date.UTC(start.getUTCFullYear(), start.getUTCMonth(), 1));
    while (dayNumber(
      `${cursor.getUTCFullYear()}-${pad(cursor.getUTCMonth() + 1)}-01`,
    ) <= last) {
      push(cursor, `${pad(cursor.getUTCMonth() + 1)}/${cursor.getUTCFullYear()}`);
      cursor = new Date(Date.UTC(cursor.getUTCFullYear(), cursor.getUTCMonth() + 1, 1));
    }
    return ticks;
  }

  // Court : une graduation tous les quelques jours.
  const every = Math.max(1, Math.round(span / 8));
  for (let day = first; day <= last; day += every) {
    const date = new Date(day * 86_400_000);
    push(date, `${pad(date.getUTCDate())}/${pad(date.getUTCMonth() + 1)}`);
  }
  return ticks;
}

function draw(): void {
  const plot = element<HTMLElement>("plot");
  plot.replaceChildren();
  zoneMarks = null;
  if (shown === null || shown.curves.length === 0) {
    const empty = document.createElement("p");
    empty.className = "chart__empty";
    empty.textContent = t("curve-empty");
    plot.append(empty);
    return;
  }

  const scale = scaleOf(shown);
  const svg = make("svg") as SVGSVGElement;
  svg.setAttribute("viewBox", `0 0 ${WIDTH} ${HEIGHT}`);
  svg.setAttribute("preserveAspectRatio", "none");
  svg.classList.add("chart");

  // La grille, en retrait : elle se lit sans se voir.
  for (let value = scale.lowest; value <= scale.highest; value += scale.step) {
    const y = scale.y(value);
    const line = make("line");
    line.setAttribute("x1", String(LEFT));
    line.setAttribute("x2", String(WIDTH - RIGHT));
    line.setAttribute("y1", y.toFixed(1));
    line.setAttribute("y2", y.toFixed(1));
    line.setAttribute("class", value === 0 ? "chart__zero" : "chart__grid");
    svg.append(line);

    const label = make("text");
    label.setAttribute("x", String(LEFT - 8));
    label.setAttribute("y", (y + 4).toFixed(1));
    label.setAttribute("class", "chart__tick");
    label.textContent = String(Math.round(value / 1_000_000));
    svg.append(label);
  }

  // L'axe du temps. **L'original graduait en semaines sans les nommer** : sur
  // une année, cela fait cinquante-deux coches muettes, et l'on ne sait pas
  // où l'on est. Fabrice ayant rendu la main sur le graphique, les
  // graduations portent ici une date lisible, et leur pas s'adapte à la durée
  // regardée — des mois sur une année, des jours sur une semaine.
  for (const day of timeTicks()) {
    const x = scale.x(day.iso);
    const line = make("line");
    line.setAttribute("x1", x.toFixed(1));
    line.setAttribute("x2", x.toFixed(1));
    line.setAttribute("y1", String(TOP));
    line.setAttribute("y2", String(HEIGHT - BOTTOM));
    line.setAttribute("class", "chart__grid");
    svg.append(line);

    const label = make("text");
    label.setAttribute("x", x.toFixed(1));
    label.setAttribute("y", String(HEIGHT - BOTTOM + 18));
    label.setAttribute("class", "chart__tick chart__tick--time");
    label.textContent = day.label;
    svg.append(label);
  }

  // Le nom de l'axe vertical, couché comme dans l'original.
  const axisName = make("text");
  axisName.setAttribute("class", "chart__axis-name");
  axisName.setAttribute(
    "transform",
    `translate(16 ${(TOP + HEIGHT - BOTTOM) / 2}) rotate(-90)`,
  );
  axisName.textContent = t("curve-axis-balance");
  svg.append(axisName);

  // Les courbes. Le total passe en dernier et par-dessus : c'est lui qu'on
  // regarde d'abord.
  const ordered = [...shown.curves].sort(
    (left, right) => Number(left.is_total) - Number(right.is_total),
  );
  ordered.forEach((curve) => {
    const rank = shown!.curves.indexOf(curve);
    const path = make("path");
    path.setAttribute("d", stepPath(curve, scale));
    path.setAttribute("fill", "none");
    path.setAttribute("stroke", colourOf(curve, rank));
    path.setAttribute("stroke-width", curve.is_total ? "3" : "2");
    path.setAttribute("stroke-linejoin", "round");
    path.dataset.account = String(curve.account_id);
    svg.append(path);
  });

  // **La zone** (F40) : un voile, et un trait à chacun de ses bords. Posée
  // sous le trait de visée et par-dessus les courbes, sans rien intercepter —
  // c'est le graphique qui écoute la souris, pas elle.
  const veil = make("rect");
  veil.setAttribute("class", "chart__zone");
  veil.setAttribute("y", String(TOP));
  veil.setAttribute("height", String(HEIGHT - TOP - BOTTOM));
  const edges = [make("line"), make("line")];
  for (const edge of edges) {
    edge.setAttribute("class", "chart__zone-edge");
    edge.setAttribute("y1", String(TOP));
    edge.setAttribute("y2", String(HEIGHT - BOTTOM));
  }
  svg.append(veil, ...edges);
  zoneMarks = { veil, edges };
  // Le graphique vient d'être redessiné : un geste commencé sur l'ancien n'a
  // plus rien sous la main.
  dragging = null;
  placeZone();

  // Le trait de visée qui suit la souris.
  const crosshair = make("line");
  crosshair.setAttribute("class", "chart__crosshair");
  crosshair.setAttribute("y1", String(TOP));
  crosshair.setAttribute("y2", String(HEIGHT - BOTTOM));
  crosshair.setAttribute("visibility", "hidden");
  svg.append(crosshair);

  plot.append(svg);
  followTheMouse(svg, scale, crosshair);
  selectWithTheMouse(svg);
}

// --- L'infobulle ----------------------------------------------------------
//
// Demande de Fabrice, mot pour mot : « lorsque l'on déplace le curseur de la
// souris sur une courbe il apparaît à côté du curseur le nom du compte, la
// date et le montant du solde, ainsi que le montant total de tous les soldes
// des comptes sélectionnés. Si je déplace la souris sur la courbe du total il
// s'affiche uniquement la date et le montant du solde. »

function followTheMouse(svg: SVGSVGElement, scale: Scale, crosshair: SVGElement): void {
  const bubble = document.createElement("div");
  bubble.className = "chart__bubble";
  bubble.hidden = true;
  element<HTMLElement>("plot").append(bubble);

  const hide = (): void => {
    bubble.hidden = true;
    crosshair.setAttribute("visibility", "hidden");
  };

  svg.addEventListener("mouseleave", hide);
  svg.addEventListener("mousemove", (event) => {
    if (shown === null || shown.curves.length === 0) {
      return;
    }
    // Pendant qu'on trace une zone, l'infobulle se tait : elle passerait sur
    // les dates qu'on est en train de choisir.
    if (dragging !== null) {
      hide();
      return;
    }
    const box = svg.getBoundingClientRect();
    // La vue est étirée : on repasse des pixels aux coordonnées du dessin.
    const x = ((event.clientX - box.left) / box.width) * WIDTH;
    const y = ((event.clientY - box.top) / box.height) * HEIGHT;
    if (x < LEFT || x > WIDTH - RIGHT || y < TOP || y > HEIGHT - BOTTOM) {
      hide();
      return;
    }

    const first = dayNumber(period.from);
    const last = Math.max(dayNumber(period.to), first + 1);
    const day = Math.round(
      first + ((x - LEFT) / (WIDTH - LEFT - RIGHT)) * (last - first),
    );

    // Sur quelle courbe est la souris : la plus proche verticalement.
    let nearest: Curve | null = null;
    let closest = Number.POSITIVE_INFINITY;
    for (const curve of shown.curves) {
      const step = valueAt(curve, day);
      if (step === null) {
        continue;
      }
      const distance = Math.abs(scale.y(step.value) - y);
      if (distance < closest) {
        closest = distance;
        nearest = curve;
      }
    }
    // Trop loin de tout : on ne raconte rien plutôt que d'inventer une courbe
    // que la souris ne survole pas.
    if (nearest === null || closest > 24) {
      hide();
      return;
    }

    const step = valueAt(nearest, day)!;
    const total = shown.curves.find((curve) => curve.is_total);
    // **Toute courbe se nomme**, le total comme les autres (Fabrice,
    // 26/07/2026) : sans son nom, l'infobulle ne dit pas ce qu'on survole.
    const lines: string[] = [nearest.label, formatDay(day)];
    lines.push(step.text);
    // Le total des soldes de tous les comptes choisis — mais pas sur la courbe
    // du total, où il répéterait le montant qu'on vient de lire.
    if (!nearest.is_total && total) {
      const at = valueAt(total, day);
      if (at) {
        lines.push(`${total.label} : ${at.text}`);
      }
    }

    bubble.replaceChildren();
    for (const line of lines) {
      const row = document.createElement("div");
      row.textContent = line;
      bubble.append(row);
    }
    const swatch = document.createElement("span");
    swatch.className = "chart__bubble-swatch";
    swatch.style.backgroundColor = colourOf(nearest, shown.curves.indexOf(nearest));
    bubble.prepend(swatch);

    bubble.hidden = false;
    // À côté du curseur, et jamais hors de la fenêtre.
    const holder = element<HTMLElement>("plot").getBoundingClientRect();
    const left = event.clientX - holder.left + 16;
    const top = event.clientY - holder.top + 16;
    bubble.style.left = `${Math.min(left, holder.width - bubble.offsetWidth - 8)}px`;
    bubble.style.top = `${Math.min(top, holder.height - bubble.offsetHeight - 8)}px`;

    crosshair.setAttribute("x1", x.toFixed(1));
    crosshair.setAttribute("x2", x.toFixed(1));
    crosshair.setAttribute("visibility", "visible");
  });
}

/// Un jour, écrit comme Radinus l'écrit partout : JJ/MM/AAAA.
function formatDay(day: number): string {
  const date = new Date(day * 86_400_000);
  const pad = (value: number): string => String(value).padStart(2, "0");
  return `${pad(date.getUTCDate())}/${pad(date.getUTCMonth() + 1)}/${date.getUTCFullYear()}`;
}

function drawLegend(): void {
  const legend = element<HTMLElement>("legend");
  legend.replaceChildren();
  if (shown === null) {
    return;
  }
  shown.curves.forEach((curve, rank) => {
    const entry = document.createElement("span");
    entry.className = "chart__legend-entry";
    const dash = document.createElement("span");
    dash.className = "chart__legend-dash";
    dash.style.backgroundColor = colourOf(curve, rank);
    if (curve.is_total) {
      dash.classList.add("chart__legend-dash--total");
    }
    const name = document.createElement("span");
    name.textContent = curve.label;
    entry.append(dash, name);
    legend.append(entry);
  });
}

// --- La zone : le geste, le voile, le résumé (propre à F40) ----------------

/// Les trois marques de la zone dans le dessin en cours, ou rien quand il n'y
/// a pas de graphique. Le dessin est refait à chaque relecture ; ces marques
/// sont celles du dernier.
let zoneMarks: { veil: SVGElement; edges: SVGElement[] } | null = null;

/// Le premier et le dernier jour de la période regardée.
function daysOfThePeriod(): { first: number; last: number } {
  const first = dayNumber(period.from);
  return { first, last: Math.max(dayNumber(period.to), first + 1) };
}

/// Où tombe un jour sur l'axe, en coordonnées du dessin. Un jour et demi a un
/// sens ici : la zone couvre ses jours **entiers**, donc son bord est à
/// mi-chemin entre le dernier jour pris et le premier qui ne l'est pas — là
/// où le pointeur cesse d'être « sur » ce jour-là.
function xOfDay(day: number): number {
  const { first, last } = daysOfThePeriod();
  const x = LEFT + ((day - first) / (last - first)) * (WIDTH - LEFT - RIGHT);
  return Math.min(WIDTH - RIGHT, Math.max(LEFT, x));
}

/// Le jour sous le pointeur — le plus proche, comme pour l'infobulle, pour que
/// la date annoncée par l'une soit celle que l'autre prend. `null` hors de la
/// surface du tracé, sauf si `held` : pendant le geste, sortir du graphique
/// arrête la zone à son bord au lieu de l'abandonner.
function dayUnder(svg: SVGSVGElement, event: PointerEvent, held: boolean): number | null {
  const box = svg.getBoundingClientRect();
  const x = ((event.clientX - box.left) / box.width) * WIDTH;
  const y = ((event.clientY - box.top) / box.height) * HEIGHT;
  if (!held && (x < LEFT || x > WIDTH - RIGHT || y < TOP || y > HEIGHT - BOTTOM)) {
    return null;
  }
  const { first, last } = daysOfThePeriod();
  const day = Math.round(first + ((x - LEFT) / (WIDTH - LEFT - RIGHT)) * (last - first));
  return Math.min(dayNumber(period.to), Math.max(first, day));
}

/// Pose le voile et ses deux traits sur la zone en cours de tracé, ou à
/// défaut sur la zone tracée ; les cache s'il n'y en a aucune.
function placeZone(): void {
  if (zoneMarks === null) {
    return;
  }
  const span =
    dragging !== null
      ? { from: Math.min(dragging.anchor, dragging.now), to: Math.max(dragging.anchor, dragging.now) }
      : zone;
  const visible = span === null ? "hidden" : "visible";
  zoneMarks.veil.setAttribute("visibility", visible);
  for (const edge of zoneMarks.edges) {
    edge.setAttribute("visibility", visible);
  }
  if (span === null) {
    return;
  }
  const left = xOfDay(span.from - 0.5);
  const right = xOfDay(span.to + 0.5);
  zoneMarks.veil.setAttribute("x", left.toFixed(1));
  zoneMarks.veil.setAttribute("width", Math.max(0, right - left).toFixed(1));
  zoneMarks.veil.dataset.from = isoOfDay(span.from);
  zoneMarks.veil.dataset.to = isoOfDay(span.to);
  [left, right].forEach((x, rank) => {
    zoneMarks!.edges[rank].setAttribute("x1", x.toFixed(1));
    zoneMarks!.edges[rank].setAttribute("x2", x.toFixed(1));
  });
}

/// Un numéro de jour, en ISO — ce que le noyau attend.
function isoOfDay(day: number): string {
  return new Date(day * 86_400_000).toISOString().slice(0, 10);
}

/// **Tracer une zone** : on appuie, une barre se pose ; on glisse, le voile
/// s'étend jusqu'au pointeur, dans un sens ou dans l'autre ; on relâche, et le
/// tableau se remplit.
///
/// **Le tableau n'est lu qu'au relâchement.** Le relire à chaque pixel sur un
/// compte de plusieurs milliers d'opérations rendrait le geste saccadé ;
/// pendant qu'on glisse, ce sont les deux dates qui suivent la main.
///
/// Un clic sans glisser prend un seul jour. Écrit avec les événements du
/// pointeur, capturé le temps du geste : le même code sous macOS, Windows et
/// Linux, à la souris comme au pavé tactile.
function selectWithTheMouse(svg: SVGSVGElement): void {
  svg.addEventListener("pointerdown", (event) => {
    if (event.button !== 0) {
      return;
    }
    const day = dayUnder(svg, event, false);
    if (day === null) {
      return;
    }
    event.preventDefault();
    svg.setPointerCapture(event.pointerId);
    dragging = { anchor: day, now: day };
    placeZone();
    showSummary();
  });
  svg.addEventListener("pointermove", (event) => {
    if (dragging === null) {
      return;
    }
    const day = dayUnder(svg, event, true) as number;
    if (day !== dragging.now) {
      dragging.now = day;
      placeZone();
      showSummary();
    }
  });
  const release = (event: PointerEvent): void => {
    if (dragging === null) {
      return;
    }
    if (svg.hasPointerCapture(event.pointerId)) {
      svg.releasePointerCapture(event.pointerId);
    }
    zone = {
      from: Math.min(dragging.anchor, dragging.now),
      to: Math.max(dragging.anchor, dragging.now),
    };
    dragging = null;
    // Les chiffres de la zone précédente ne sont pas ceux de celle-ci : le
    // résumé ne montre que les dates tant que la lecture n'est pas revenue.
    figures = null;
    placeZone();
    detail.clearSelection();
    void showZone();
  };
  svg.addEventListener("pointerup", release);
  svg.addEventListener("pointercancel", release);
}

/// Ce que la zone affichée a rendu, pour le résumé.
let figures: Zone | null = null;
/// Le rang de la dernière lecture demandée : une réponse qui arrive après une
/// plus récente n'a plus rien à dire.
let asked = 0;

/// Le résumé : rien de tracé, la phrase qui dit comment faire ; en cours de
/// tracé, les deux dates ; tracée, les dates et les cinq chiffres.
function showSummary(): void {
  const summary = element<HTMLElement>("summary");
  const span =
    dragging !== null
      ? { from: Math.min(dragging.anchor, dragging.now), to: Math.max(dragging.anchor, dragging.now) }
      : zone;
  summary.dataset.state = span === null ? "none" : dragging !== null || figures === null ? "dragging" : "shown";
  if (span === null) {
    return;
  }
  // Deux dates et un tiret : des chiffres, pas une phrase.
  element<HTMLElement>("zone-dates").textContent =
    span.from === span.to ? formatDay(span.from) : `${formatDay(span.from)} – ${formatDay(span.to)}`;
  if (figures !== null && dragging === null) {
    element<HTMLElement>("opening").textContent = figures.opening;
    element<HTMLElement>("closing").textContent = figures.closing;
    element<HTMLElement>("debit").textContent = figures.debit;
    element<HTMLElement>("credit").textContent = figures.credit;
    const variation = element<HTMLElement>("variation");
    variation.textContent = figures.variation;
    variation.classList.toggle("analysis__debit", figures.variation_value < 0);
  }
}

/// **Lit la zone et remplit le résumé et le tableau** — ou les vide, s'il n'y
/// en a pas.
async function showZone(): Promise<void> {
  asked += 1;
  const mine = asked;
  if (zone === null || accountIds.length === 0) {
    figures = null;
    showSummary();
    detail.setRows([]);
    return;
  }
  try {
    const found = await invoke<Zone>("balance_zone", {
      accountIds,
      from: isoOfDay(zone.from),
      to: isoOfDay(zone.to),
    });
    if (mine !== asked) {
      return;
    }
    figures = found;
    showSummary();
    detail.setRows(found.rows);
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

// --- Le tableau du bas (propre à F40) -------------------------------------
//
// Celui du détail des statistiques, avec deux différences que Fabrice a
// tranchées : il montre les **mères** — « c'est l'écriture de la banque qui
// fait bouger le solde » — et il porte une colonne « Compte », puisque la zone
// peut en couvrir plusieurs. Le reste est le même : on voit une opération mal
// classée, on la reclasse sur place.

function nomenclatureColumn(
  title: string,
  kind: string,
  text: (row: DetailRow) => string,
  options: () => Item[],
  value: (row: DetailRow) => number,
  width: string,
) {
  return {
    // Le nom de la colonne est celui de sa nomenclature : `category`, `payee`…
    id: kind,
    title: () => t(title),
    cell: text,
    width,
    minWidth: 110,
    editor: {
      options,
      value,
      change: (row: DetailRow, picked: number) => {
        void invoke("set_operation_nomenclature", { id: row.id, kind, value: picked })
          .then(() => reload())
          .catch((error) => say(tError("ui-save-failed", error), true));
      },
    },
  };
}

function verificationColumn() {
  const word = (row: DetailRow): string =>
    verifications.find((item) => item.id === row.verification_id)?.label ?? "";
  return {
    id: "verification",
    title: () => t("operations-column-verification"),
    cell: word,
    key: (row: DetailRow) => row.verification_id,
    render: (row: DetailRow, cell: HTMLElement) => {
      cell.textContent = word(row);
      cell.classList.add("list__cell--verification");
      cell.dataset.verification = String(row.verification_id);
    },
    width: "0.9fr",
    minWidth: 110,
    editor: {
      options: () => verifications,
      value: (row: DetailRow) => row.verification_id,
      decorate: (row: DetailRow, combo: HTMLSelectElement) => {
        combo.classList.add("list__combo--verification");
        combo.dataset.verification = String(row.verification_id);
      },
      change: (row: DetailRow, picked: number) => {
        void invoke("set_operation_verification", { id: row.id, verificationId: picked })
          .then(() => reload())
          .catch((error) => say(tError("ui-save-failed", error), true));
      },
    },
  };
}

/// L'entrée « Vérification » du clic droit, pour toute la sélection — la même
/// que dans la liste du compte et dans les statistiques.
function verificationOfTheSelection(): MenuAddition[] {
  return [
    {
      label: t("operations-column-verification"),
      enabled: detail.selected().length > 0,
      choices: verifications.map((item) => ({
        label: item.label,
        mark: { name: "verification", value: String(item.id) },
        run: () => {
          void invoke("set_operations_verification", {
            ids: detail.selected(),
            verificationId: item.id,
          })
            .then(() => reload())
            .catch((error) => say(tError("ui-save-failed", error), true));
        },
      })),
    },
  ];
}

const detail = new Table<DetailRow>({
  container: element<HTMLDivElement>("rows"),
  virtualized: true,
  rowHeight: 24,
  horizontalScroll: true,
  // Chacun ses colonnes, ici aussi, sous une disposition propre à cette
  // fenêtre : déplaçables, masquables, colorables.
  layoutName: "balance-analysis",
  columns: [
    // En tête : la zone peut couvrir plusieurs comptes.
    {
      id: "account",
      title: () => t("accounts-column-account"),
      cell: (row) => row.account,
      width: "1fr",
      minWidth: 100,
    },
    {
      id: "date",
      title: () => t("statistics-column-date"),
      cell: (row) => row.date,
      key: (row) => row.date_value,
      width: "100px",
      minWidth: 92,
    },
    {
      id: "clearing-date",
      title: () => t("statistics-column-clearing-date"),
      cell: (row) => row.clearing_date,
      key: (row) => row.clearing_date_value,
      width: "110px",
      minWidth: 100,
    },
    {
      id: "label",
      title: () => t("statistics-column-label"),
      cell: (row) => row.label,
      width: "2.4fr",
      minWidth: 180,
    },
    verificationColumn(),
    nomenclatureColumn(
      "operations-column-category",
      "category",
      (row) => row.category,
      () => combos.category,
      (row) => row.category_id,
      "1fr",
    ),
    nomenclatureColumn(
      "operations-column-assignment",
      "assignment",
      (row) => row.assignment,
      () => combos.assignment,
      (row) => row.assignment_id,
      "1fr",
    ),
    nomenclatureColumn(
      "operations-column-payment-mode",
      "payment-mode",
      (row) => row.payment_mode,
      () => combos.payment_mode,
      (row) => row.payment_mode_id,
      "1fr",
    ),
    nomenclatureColumn(
      "operations-column-payee",
      "payee",
      (row) => row.payee,
      () => combos.payee,
      (row) => row.payee_id,
      "1fr",
    ),
    nomenclatureColumn(
      "operations-column-project",
      "project",
      (row) => row.project,
      () => combos.project,
      (row) => row.project_id,
      "0.8fr",
    ),
    {
      id: "amount",
      title: () => t("statistics-column-amount"),
      cell: (row) => (row.amount < 0 ? row.debit : row.credit),
      render: (row, cell) => {
        cell.textContent = row.amount < 0 ? row.debit : row.credit;
        cell.classList.add("list__cell--amount");
      },
      key: (row) => row.amount,
      money: (row) => row.amount,
      numeric: true,
      width: "1fr",
      minWidth: 95,
    },
    {
      id: "comments",
      title: () => t("statistics-column-comments"),
      cell: () => "",
      render: (row, cell) => {
        if (!row.has_comment) {
          return;
        }
        const mark = document.createElement("span");
        mark.className = "list__tick";
        mark.textContent = "✓";
        cell.append(mark);
        if (row.comment !== "") {
          cell.title = row.comment;
        }
      },
      width: "110px",
      minWidth: 90,
    },
  ],
  identity: (row) => row.id,
  // Double-cliquer ouvre la fiche de l'opération.
  onActivate: (row: DetailRow) => {
    void invoke("open_form_for_operation", { id: row.id }).catch((error) =>
      say(tError("ui-open-failed", error), true),
    );
  },
  rowClass: (row) => (row.amount < 0 ? "list__row--debit" : null),
  exportAs: () => ({
    name: t("analysis-detail-name"),
    detail:
      zone === null
        ? ""
        : `${t("curve-from")} ${formatDay(zone.from)} — ${t("curve-to")} ${formatDay(zone.to)}`,
  }),
  // Tant qu'aucune zone n'est tracée, le tableau dit comment en tracer une.
  emptyText: () => (zone === null ? t("analysis-hint") : t("analysis-detail-none")),
  filteredOutText: () => t("ui-no-match"),
});

/// Le splitter : la frontière entre le graphique et le tableau se déplace à la
/// souris, comme dans les statistiques. Le graphique se redessine à sa
/// nouvelle taille.
function makeSplitterDraggable(): void {
  const splitter = element<HTMLElement>("splitter");
  const top = element<HTMLElement>("chart-zone");
  let moving = false;

  splitter.addEventListener("mousedown", (event) => {
    event.preventDefault();
    moving = true;
    document.body.classList.add("splitting");
  });
  document.addEventListener("mousemove", (event) => {
    if (!moving) {
      return;
    }
    const height = Math.max(260, event.clientY - top.getBoundingClientRect().top);
    top.style.flex = `0 0 ${height}px`;
  });
  document.addEventListener("mouseup", () => {
    moving = false;
    document.body.classList.remove("splitting");
  });
}

// --- La lecture -----------------------------------------------------------

async function reload(): Promise<void> {
  element<HTMLElement>("from").textContent = formatDay(dayNumber(period.from));
  element<HTMLElement>("to").textContent = formatDay(dayNumber(period.to));

  if (accountIds.length === 0) {
    say(t("curve-nothing"), true);
    shown = null;
    zone = null;
    draw();
    drawLegend();
    await showZone();
    return;
  }
  try {
    shown = await invoke<Curves>("balance_curves", {
      accountIds,
      from: period.from,
      to: period.to,
    });
    element<HTMLElement>("year").textContent = String(shown.year);
    say("");
    drawLegend();
    draw();
    await showZone();
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// Les deux horloges et le millésime. **Elles décalent la période entière d'un
/// an** (Fabrice, 26/07/2026), et c'est le noyau qui sait comment : une
/// semaine garde son numéro ISO plutôt que de glisser d'un jour, et la
/// semaine 53 d'une année qui n'en a que 52 devient la 52.
async function shift(by: number, onto: number | null): Promise<void> {
  try {
    period = await invoke<Period & { year: number }>("shift_period", {
      from: period.from,
      to: period.to,
      by,
      onto,
    });
    // Une autre année : la zone tracée sur la précédente ne veut plus rien dire.
    zone = null;
    await reload();
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

async function askForYear(): Promise<void> {
  try {
    const prompt = await invoke<{ question: string; first: number; last: number }>(
      "statistics_year_prompt",
    );
    const asked = await askForWholeNumber(
      prompt.question,
      shown?.year ?? new Date().getFullYear(),
      4,
      t("ui-yes"),
      t("ui-no"),
    );
    if (asked === null) {
      return;
    }
    await shift(0, asked);
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

function readParameters(query: string): void {
  const parameters = new URLSearchParams(query);
  accountIds = (parameters.get("accounts") ?? "")
    .split(",")
    .map((piece) => Number(piece.trim()))
    .filter((id) => Number.isFinite(id) && id > 0);
  history.replaceState(null, "", `?accounts=${accountIds.join(",")}`);
}

function buildMenu(): void {
  const bar = element<HTMLElement>("window-menu");
  bar.replaceChildren();
  const entry = document.createElement("button");
  entry.type = "button";
  entry.className = "window-menu__entry";
  entry.textContent = t("curve-menu-period");
  // Les deux dates ne sont que de l'affichage (Fabrice, 26/07/2026) : le menu
  // et les horloges sont les seuls à les faire bouger, donc aucun champ à
  // surveiller ici.
  bar.append(
    buildPeriodMenu(
      entry,
      (chosen) => {
        period = chosen;
        zone = null;
        void reload();
      },
      [],
      // **L'encoche part sur l'année**, puisque c'est là que la fenêtre
      // s'ouvre. Elle marquait le mois, qui n'est pas ce qui est affiché.
      "period-this-year:period-whole-year",
    ),
  );
}

/// **Tous les mots de la fenêtre, posés en un seul endroit.**
///
/// Une fenêtre de Radinus est bâtie une fois et jamais détruite : changer de
/// langue ne la reconstruit pas, il faut qu'elle sache se rhabiller. Ce qui
/// pose un mot est donc ici et nulle part ailleurs — une étiquette ajoutée
/// demain suivra la langue sans que personne y pense. Le graphique en fait
/// partie : le nom de l'axe et la phrase du vide sont dessinés par `draw`, que
/// le rechargement rappelle.
///
/// **La position ne bouge pas** : ni la période, ni l'année, ni les comptes ne
/// sont touchés — se rhabiller ne change que des mots, et rien de ce qui ne
/// change que les mots ou les chiffres ne fait perdre sa place.
///
/// `alsoTheNumbers` dit d'où l'on vient. À l'ouverture, les courbes viennent
/// plus bas, une fois passée la barrière de `startup_error` et les comptes lus
/// dans l'adresse.
async function dress(alsoTheNumbers = true): Promise<void> {
  element<HTMLElement>("heading").textContent = t("analysis-heading");
  // Les mots du résumé de la zone, et ceux du tableau (F40).
  for (const [id, key] of [
    ["summary-hint", "analysis-hint"],
    ["zone-label", "analysis-zone"],
    ["opening-label", "analysis-opening"],
    ["closing-label", "analysis-closing"],
    ["variation-label", "analysis-variation"],
    ["debit-label", "operations-foot-debit"],
    ["credit-label", "operations-foot-credit"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  // Les quatre vérifications, dans la langue en cours. Sans base ouverte il
  // n'y a rien à lire, et la fenêtre le dira plus bas.
  verifications =
    (await invoke<Item[] | null>("list_operation_verifications").catch(() => null)) ?? [];
  detail.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));
  element<HTMLElement>("from-label").textContent = t("curve-from");
  element<HTMLElement>("to-label").textContent = t("curve-to");
  element<HTMLElement>("close").title = t("ui-title-close");
  element<HTMLElement>("year").title = t("statistics-year-choose");
  element<HTMLElement>("next-year").title = t("statistics-year-next");
  element<HTMLElement>("previous-year").title = t("statistics-year-previous");
  buildMenu();
  if (alsoTheNumbers) {
    await reload();
  }
}

void listen<string>(PARAMETERS_EVENT, (event) => {
  readParameters(event.payload);
  // D'autres comptes : la zone se retrace.
  zone = null;
  detail.clearSelection();
  void reload();
});
void listen(CHANGED_EVENT, () => void reload());

element<HTMLButtonElement>("year").addEventListener("click", () => void askForYear());
element<HTMLButtonElement>("next-year").addEventListener("click", () => void shift(1, null));
element<HTMLButtonElement>("previous-year").addEventListener("click", () => void shift(-1, null));
element<HTMLButtonElement>("close").addEventListener("click", () => {
  void invoke("close_balance_analysis");
});
window.addEventListener("resize", () => draw());

// **Elle se relit en revenant à l'écran**, comme les statistiques : une fiche
// ouverte d'un double-clic a pu changer un montant, donc la courbe et la zone.
// La zone tracée, elle, reste où elle est.
window.addEventListener("focus", () => void reload());

void (async () => {
  await loadTexts(null);
  await dress(false);
  detail.exportOnRightClick(say, verificationOfTheSelection);
  makeSplitterDraggable();
  detail.setRows([]);

  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    return;
  }
  try {
    combos = await invoke<Combos>("list_operation_combos");
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
  readParameters(window.location.search);
  await reload();
  onLanguageChanged(dress, { key: "window-analysis-title" });
})();

/// Une nomenclature a changé pendant que cette fenêtre vivait : les listes des
/// menus déroulants sont relues.
void listen("nomenclatures-changed", async () => {
  combos = await invoke<Combos>("list_operation_combos");
});
