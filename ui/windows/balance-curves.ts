// F25 — « Evolution du solde ».
//
// Une courbe par compte choisi, plus celle du total — laquelle n'existe qu'à
// partir de deux comptes. Les règles sont celles que Fabrice a dictées le
// 26/07/2026, et c'est le noyau qui les tient ; cette fenêtre ne fait que
// dessiner ce qu'il lui donne et écouter la souris.
//
// **Les courbes sont en escalier.** Le noyau ne rend qu'un point par
// changement de solde, et le tracé relie deux points par un palier puis un
// saut vertical — jamais par une pente. « C'est ce qui est de plus juste » :
// une pente ferait croire à un mouvement les jours où il ne s'est rien passé.
//
// **Le graphique a été refait**, Fabrice ayant rendu la main dessus. Ce qui a
// été décidé et pourquoi : traits fins, grille discrète, pas de filigrane
// derrière les courbes, et surtout des couleurs **mesurées** plutôt que
// choisies à l'œil — elles restent distinctes pour un daltonien, ce qui n'est
// pas vrai de n'importe quelle suite de teintes.

import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askForWholeNumber } from "./dialog";
import { buildPeriodMenu, wholeYear, type Period } from "./period";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

const PARAMETERS_EVENT = "window-parameters:balance-curves";
const CHANGED_EVENT = "data-changed:balance-curves";

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

  // Le trait de visée qui suit la souris.
  const crosshair = make("line");
  crosshair.setAttribute("class", "chart__crosshair");
  crosshair.setAttribute("y1", String(TOP));
  crosshair.setAttribute("y2", String(HEIGHT - BOTTOM));
  crosshair.setAttribute("visibility", "hidden");
  svg.append(crosshair);

  plot.append(svg);
  followTheMouse(svg, scale, crosshair);
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

// --- La lecture -----------------------------------------------------------

async function reload(): Promise<void> {
  element<HTMLElement>("from").textContent = formatDay(dayNumber(period.from));
  element<HTMLElement>("to").textContent = formatDay(dayNumber(period.to));

  if (accountIds.length === 0) {
    say(t("curve-nothing"), true);
    shown = null;
    draw();
    drawLegend();
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
  element<HTMLElement>("heading").textContent = t("curve-heading");
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
  void reload();
});
void listen(CHANGED_EVENT, () => void reload());

element<HTMLButtonElement>("year").addEventListener("click", () => void askForYear());
element<HTMLButtonElement>("next-year").addEventListener("click", () => void shift(1, null));
element<HTMLButtonElement>("previous-year").addEventListener("click", () => void shift(-1, null));
element<HTMLButtonElement>("close").addEventListener("click", () => {
  void invoke("close_balance_curves");
});
window.addEventListener("resize", () => draw());

void (async () => {
  await loadTexts(null);
  await dress(false);

  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    return;
  }
  readParameters(window.location.search);
  await reload();
  onLanguageChanged(dress, { key: "window-curve-title" });
})();
