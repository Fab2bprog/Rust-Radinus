// La courbe du cumul d'une catégorie, dessinée à la main.
//
// Troisième niveau de la fenêtre d'accueil (décision de Fabrice, 03/08/2026) :
// on clique une catégorie dans l'anneau et la carte montre, jour après jour,
// ce que cette catégorie a coûté depuis le début du mois.
//
// **Elle répond à une question que l'anneau ne peut pas poser.** L'anneau dit
// combien ; la courbe dit **quand**. Un poste dépensé d'un coup le 3 et un
// poste dépensé un peu chaque jour font le même secteur et deux courbes qui
// n'ont rien à voir.
//
// **Aucune bibliothèque de graphiques**, comme pour l'anneau : ce sont des
// segments et des courbes de Bézier, et une dépendance de plus se paie à
// chaque mise à jour du logiciel pendant des années.
//
// **Lissée, et pas en escalier.** F25 dessine ses soldes en marches, parce
// qu'un solde saute à une date et y reste — c'est la vérité d'un compte. Ici
// Fabrice a demandé une courbe lissée, et c'est cohérent : on ne lit pas un
// état à un instant, on lit une **allure** sur un mois. Le lissage ne peut pas
// tromper sur le total, qui est écrit en toutes lettres au bout.

/// Un point de la courbe, tel que le noyau le rend.
export interface CurvePoint {
  /// La date en ISO. Elle se montre au survol ; **la fenêtre n'en tire aucun
  /// mot et ne calcule aucune date**.
  day: string;
  amount: number;
  /// Le cumul tel qu'il s'écrit, avec ses séparateurs et sa devise.
  text: string;
  /// Ce qui s'écrit sous l'axe : un quantième quand la courbe va de jour en
  /// jour, le nom du mois quand elle va de mois en mois. **Rédigé par le
  /// contrôleur** — un nom de mois est une phrase, et cette fenêtre n'en
  /// contient aucune (04/08/2026, quand F19 a hérité de la courbe et que sa
  /// période a pu couvrir une année).
  label: string;
}

const NAMESPACE = "http://www.w3.org/2000/svg";

// Les mesures, à la charte. La carte fait la même largeur que celle de
// l'anneau : passer de l'un à l'autre ne doit pas faire sauter la mise en page.
const WIDTH = 480;
const HEIGHT = 260;
const LEFT = 8;
const RIGHT = 12;
const TOP = 16;
const BOTTOM = 24;

/// La couleur du trait : celle du premier secteur d'un anneau, pour que la
/// courbe appartienne visiblement à la même famille de dessins.
const LINE = "#E14A39";
const FILL = "rgba(225, 74, 57, 0.12)";

function node(name: string, attributes: Record<string, string>): SVGElement {
  const element = document.createElementNS(NAMESPACE, name);
  for (const [key, value] of Object.entries(attributes)) {
    element.setAttribute(key, value);
  }
  return element;
}

/// Le chemin lissé qui passe par tous les points.
///
/// Lissage de Catmull-Rom converti en courbes de Bézier cubiques : chaque
/// point est **traversé** — la courbe ne s'écarte jamais d'une valeur réelle —
/// et seules les tangentes sont adoucies. Un lissage qui manquerait les points
/// afficherait un cumul que la base ne contient pas.
///
/// La tension de 6 est celle de la formule classique ; plus bas la courbe
/// devient anguleuse, plus haut elle enfle entre deux points et peut dépasser
/// le maximum réel, ce qui serait un mensonge sur un cumul.
function smoothPath(points: [number, number][]): string {
  if (points.length === 0) {
    return "";
  }
  if (points.length === 1) {
    const [x, y] = points[0];
    return `M ${x} ${y}`;
  }
  const parts = [`M ${points[0][0]} ${points[0][1]}`];
  for (let i = 0; i < points.length - 1; i += 1) {
    const before = points[Math.max(i - 1, 0)];
    const from = points[i];
    const to = points[i + 1];
    const after = points[Math.min(i + 2, points.length - 1)];
    const c1x = from[0] + (to[0] - before[0]) / 6;
    const c1y = from[1] + (to[1] - before[1]) / 6;
    const c2x = to[0] - (after[0] - from[0]) / 6;
    const c2y = to[1] - (after[1] - from[1]) / 6;
    parts.push(`C ${c1x} ${c1y}, ${c2x} ${c2y}, ${to[0]} ${to[1]}`);
  }
  return parts.join(" ");
}

export interface CurveOptions {
  /// La phrase à montrer quand le mois n'a rien.
  emptyText: string;
}

/// Dessine la courbe du cumul dans `holder`.
export function drawCurve(
  holder: HTMLElement,
  points: CurvePoint[],
  options: CurveOptions,
): void {
  holder.replaceChildren();

  const highest = points.reduce((most, step) => Math.max(most, step.amount), 0);
  if (points.length === 0 || highest === 0) {
    const empty = document.createElement("p");
    empty.className = "card__empty";
    empty.textContent = options.emptyText;
    holder.append(empty);
    return;
  }

  const svg = node("svg", {
    viewBox: `0 0 ${WIDTH} ${HEIGHT}`,
    width: String(WIDTH),
    height: String(HEIGHT),
  });
  svg.classList.add("curve");

  const span = Math.max(points.length - 1, 1);
  const x = (rank: number): number =>
    LEFT + (rank / span) * (WIDTH - LEFT - RIGHT);
  const y = (amount: number): number =>
    HEIGHT - BOTTOM - (amount / highest) * (HEIGHT - TOP - BOTTOM);

  const placed: [number, number][] = points.map((step, rank) => [x(rank), y(step.amount)]);

  // La surface sous la courbe, puis la courbe. La surface d'abord : elle est
  // dessous, et l'ordre de pose suffit à le dire.
  const line = smoothPath(placed);
  svg.append(
    node("path", {
      d: `${line} L ${x(points.length - 1)} ${HEIGHT - BOTTOM} L ${x(0)} ${HEIGHT - BOTTOM} Z`,
      fill: FILL,
      stroke: "none",
    }),
  );
  svg.append(
    node("path", {
      d: line,
      fill: "none",
      stroke: LINE,
      "stroke-width": "2.5",
      "stroke-linejoin": "round",
      "stroke-linecap": "round",
    }),
  );

  // La ligne du sol, pour que la surface ait un bas visible.
  svg.append(
    node("line", {
      x1: String(x(0)),
      y1: String(HEIGHT - BOTTOM),
      x2: String(x(points.length - 1)),
      y2: String(HEIGHT - BOTTOM),
      stroke: "#d8dee3",
      "stroke-width": "1",
    }),
  );

  // **Sept étiquettes au plus, quel qu'en soit le nombre.** Trente et un
  // quantièmes sous une courbe se chevauchent et ne se lisent plus ; douze noms
  // de mois aussi. Une seule règle sert les deux cas depuis que F19 partage
  // cette courbe : on garde le premier, le dernier, et un point sur `stride`
  // entre les deux.
  const MOST_LABELS = 7;
  const stride = Math.max(1, Math.ceil(points.length / MOST_LABELS));
  points.forEach((step, rank) => {
    const last = rank === points.length - 1;
    if (!last && rank !== 0 && rank % stride !== 0) {
      return;
    }
    // **Le dernier chasse ses voisins.** Il est toujours écrit — c'est lui qui
    // porte le total — et une étiquette posée juste avant lui se toucheraient.
    if (!last && rank > points.length - 1 - stride) {
      return;
    }
    // **Les deux étiquettes des bords se rangent vers l'intérieur.** Centrées
    // comme les autres, elles débordaient du dessin : « janvier » perdait son
    // « ja » à gauche et « décembre » son « re » à droite. Un quantième, court,
    // ne l'avait jamais montré ; un nom de mois l'a montré tout de suite.
    const anchor =
      rank === 0 ? " curve__day--first" : last ? " curve__day--last" : "";
    const tick = node("text", {
      x: String(x(rank)),
      y: String(HEIGHT - BOTTOM + 16),
      class: `curve__day${anchor}`,
    });
    tick.textContent = step.label;
    svg.append(tick);
  });

  // **Le total, écrit en toutes lettres au bout de la courbe.** C'est lui qui
  // dit la vérité : le lissage fait l'allure, le nombre fait foi — la même
  // règle que la valeur écrite sur chaque secteur d'un anneau.
  const end = placed[placed.length - 1];
  const total = node("text", {
    x: String(Math.min(end[0], WIDTH - RIGHT)),
    y: String(Math.max(end[1] - 10, TOP)),
    class: "curve__total",
  });
  total.textContent = points[points.length - 1].text;
  svg.append(total);

  // Chaque point porte son jour et son cumul au survol : la courbe est lissée,
  // donc la valeur exacte d'un jour précis ne se lit pas à l'œil.
  points.forEach((step, rank) => {
    const dot = node("circle", {
      cx: String(x(rank)),
      cy: String(y(step.amount)),
      r: "7",
      fill: "transparent",
    });
    const title = document.createElementNS(NAMESPACE, "title");
    title.textContent = `${step.label} — ${step.text}`;
    dot.append(title);
    svg.append(dot);
  });

  holder.append(svg);
}
