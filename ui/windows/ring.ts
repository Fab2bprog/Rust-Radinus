// L'anneau par poste budgétaire, dessiné à la main.
//
// **Une seule façon de dessiner un anneau dans tout Radinus.** Ce code vivait
// dans `dashboard.ts` ; la fenêtre d'accueil en a eu besoin à son tour
// (phase 17 bis) et il est sorti ici plutôt que d'être recopié — la même
// méthode que le menu Période sorti de F02 le 26/07/2026, et que le dessin
// d'onglet partagé entre l'écran et le classeur. Deux copies d'un dessin, ce
// sont deux occasions qu'une correction n'arrive que d'un côté.
//
// **Aucune bibliothèque de graphiques n'est entrée dans le projet pour cela** :
// un anneau, ce sont des arcs de cercle, et une dépendance de plus se paie à
// chaque mise à jour du logiciel pendant des années.
//
// Deux rendus, un seul code :
//
// - **plat**, celui de F19, validé par Fabrice le 26/07/2026 — inchangé, au
//   pixel près ;
// - **en relief**, celui de l'accueil, décidé le 03/08/2026. Il lui a été dit
//   ce qu'il coûte, et c'est écrit ici pour qui reprendra ce fichier : une
//   ellipse inclinée **surestime les secteurs qui passent devant** — ils
//   gagnent la paroi en plus de leur face — et écrase ceux du fond. Deux parts
//   de même valeur n'ont donc pas la même allure. C'est pour cela que la valeur
//   est écrite sur chaque secteur et répétée dans la légende : **la perspective
//   fait l'allure, le nombre dit la vérité.** Ne jamais retirer ces nombres.
//
// Ce que le dessin doit à la lecture et non au goût : la valeur écrite sur
// chaque secteur (donc rien ne repose sur la seule couleur), un filet de la
// couleur du fond entre deux voisins, et la légende qui nomme chaque poste.

/// Une part de l'anneau, telle que le noyau la rend.
export interface RingSlice {
  /// La clef du poste ou de la catégorie — `0` pour la part « sans ».
  id: number;
  label: string;
  amount: number;
  /// Le montant tel qu'il s'écrit, rédigé par le noyau.
  text: string;
}

// Les huit teintes de l'original.
//
// Relevées au pixel sur « Tableau de bord.png », dans l'ordre où sa légende
// les montre. **Elles sont assignées dans cet ordre fixe et ne tournent
// jamais** : un poste garde sa couleur quel que soit le nombre de secteurs à
// l'écran, sinon changer de période repeindrait tout et l'œil perdrait ses
// repères d'une lecture à l'autre.
//
// Mesurées, aussi : deux d'entre elles — le vert et le turquoise — sont trop
// proches pour être distinguées avec certitude, y compris à vision normale.
// C'est un défaut de l'original, il a été signalé à Fabrice, et il tranchera.
// En attendant, la valeur écrite sur chaque secteur et le nom dans la légende
// font que rien ne dépend de la seule couleur.
const COLOURS = [
  "#E14A39",
  "#FAA026",
  "#61BC6D",
  "#00A885",
  "#54ACD2",
  "#2B82C9",
  "#F85CA9",
  "#9265B8",
];

/// Au-delà de huit secteurs, on ne fabrique pas une neuvième teinte : elle ne
/// se distinguerait plus des huit autres. Les couleurs recommencent, et c'est
/// la valeur écrite sur le secteur qui tranche — comme dans l'original, dont
/// la palette s'arrête aussi à huit.
function colourOf(rank: number): string {
  return COLOURS[rank % COLOURS.length];
}

// --- Les mesures ----------------------------------------------------------

const SIZE = 260;
const OUTER = 110;
const INNER = 62;

/// L'écrasement vertical de l'ellipse en relief : 1 serait vu de dessus (donc
/// plat), 0 serait vu de côté (donc invisible). Et l'épaisseur de la galette,
/// en pixels d'écran. Les deux valeurs sont à la charte, §3.1.
const SQUASH = 0.42;
const DEPTH = 26;

/// Ce que la paroi perd en clarté par rapport à la face du dessus. La paroi
/// extérieure est au soleil, celle du trou est à l'ombre : **aucune couleur
/// nouvelle n'est introduite**, ce sont les huit teintes assombries.
const OUTER_WALL_SHADE = 0.3;
const INNER_WALL_SHADE = 0.45;

const NAMESPACE = "http://www.w3.org/2000/svg";

/// Un point de l'anneau, l'angle comptant depuis midi et tournant dans le sens
/// des aiguilles — le sens de lecture d'un camembert. `squash` vaut 1 à plat.
function pointAt(angle: number, radius: number, squash: number): [number, number] {
  const radians = ((angle - 90) * Math.PI) / 180;
  return [
    SIZE / 2 + radius * Math.cos(radians),
    centre(squash) + radius * squash * Math.sin(radians),
  ];
}

/// Le centre vertical. En relief, la galette descend de son épaisseur : on
/// remonte d'autant, sinon elle sortirait du cadre par le bas.
function centre(squash: number): number {
  return squash === 1 ? SIZE / 2 : SIZE / 2 - DEPTH / 2;
}

/// Le contour d'un secteur d'anneau : arc extérieur, trait vers l'intérieur,
/// arc intérieur en sens inverse, fermeture.
function sectorPath(from: number, to: number, squash: number): string {
  const large = to - from > 180 ? 1 : 0;
  const [ax, ay] = pointAt(from, OUTER, squash);
  const [bx, by] = pointAt(to, OUTER, squash);
  const [cx, cy] = pointAt(to, INNER, squash);
  const [dx, dy] = pointAt(from, INNER, squash);
  return [
    `M ${ax} ${ay}`,
    `A ${OUTER} ${OUTER * squash} 0 ${large} 1 ${bx} ${by}`,
    `L ${cx} ${cy}`,
    `A ${INNER} ${INNER * squash} 0 ${large} 0 ${dx} ${dy}`,
    "Z",
  ].join(" ");
}

/// L'anneau entier, quand un seul poste porte tout.
///
/// **Un arc ne peut pas faire le tour complet** : ses deux extrémités seraient
/// le même point, et la courbe n'est plus définie. On le fait donc en deux
/// demi-cercles, et les deux couronnes sont découpées l'une dans l'autre par
/// `fill-rule: evenodd` — sans quoi le disque se remplit et le trou disparaît.
/// C'est ce que le premier dessin faisait : la carte des gains montrait une
/// pastille pleine et échancrée, ce qu'aucun test ne pouvait voir puisque le
/// chemin existait bel et bien.
function wholeRingPath(squash: number): string {
  const middle = centre(squash);
  const circle = (radius: number): string =>
    [
      `M ${SIZE / 2} ${middle - radius * squash}`,
      `A ${radius} ${radius * squash} 0 1 1 ${SIZE / 2} ${middle + radius * squash}`,
      `A ${radius} ${radius * squash} 0 1 1 ${SIZE / 2} ${middle - radius * squash}`,
      "Z",
    ].join(" ");
  return `${circle(OUTER)} ${circle(INNER)}`;
}

/// La paroi d'un bord entre deux angles : l'arc du haut, la descente de
/// l'épaisseur, l'arc du bas en sens inverse, fermeture.
function wallPath(from: number, to: number, radius: number): string {
  const large = to - from > 180 ? 1 : 0;
  const [ax, ay] = pointAt(from, radius, SQUASH);
  const [bx, by] = pointAt(to, radius, SQUASH);
  return [
    `M ${ax} ${ay}`,
    `A ${radius} ${radius * SQUASH} 0 ${large} 1 ${bx} ${by}`,
    `L ${bx} ${by + DEPTH}`,
    `A ${radius} ${radius * SQUASH} 0 ${large} 0 ${ax} ${ay + DEPTH}`,
    "Z",
  ].join(" ");
}

/// La portion d'un secteur qui tombe dans une plage d'angles, ou rien.
/// Un morceau plus mince qu'un cinquième de degré ne se voit pas et ferait un
/// chemin dégénéré.
function clip(
  from: number,
  to: number,
  lowest: number,
  highest: number,
): [number, number] | null {
  const start = Math.max(from, lowest);
  const end = Math.min(to, highest);
  return end - start > 0.2 ? [start, end] : null;
}

/// La teinte assombrie d'une paroi. Aucune couleur nouvelle : la même, moins
/// de lumière.
function shade(colour: string, amount: number): string {
  const value = Number.parseInt(colour.slice(1), 16);
  const darker = (channel: number): number => Math.round(channel * (1 - amount));
  const red = darker((value >> 16) & 255);
  const green = darker((value >> 8) & 255);
  const blue = darker(value & 255);
  return `#${((1 << 24) | (red << 16) | (green << 8) | blue).toString(16).slice(1)}`;
}

/// L'unité entière, telle que l'original l'écrit sur ses secteurs : « 836 »,
/// sans décimales ni symbole — le montant exact est dans la légende et dans
/// les tuiles.
function roundedUnits(amount: number): string {
  return String(Math.round(amount / 1_000_000));
}

function node(name: string, attributes: Record<string, string>): SVGElement {
  const element = document.createElementNS(NAMESPACE, name);
  for (const [key, value] of Object.entries(attributes)) {
    element.setAttribute(key, value);
  }
  return element;
}

export interface RingOptions {
  /// La phrase à montrer quand il n'y a rien. Un anneau vide est une réponse,
  /// pas une panne — la capture de Fabrice montre une carte « Gains » sans
  /// rien dedans.
  emptyText: string;
  /// En relief pour l'accueil **et pour F19 depuis le 04/08/2026** ; à plat
  /// nulle part pour l'instant, le mode restant écrit pour la fenêtre qui en
  /// aurait besoin.
  relief?: boolean;
  /// L'en-tête de la légende — « Postes budgétaires » ou « Catégories ».
  /// Absent en F19, dont le titre de carte le dit déjà.
  legendTitle?: string;
  /// Ce qu'on fait d'un clic sur un secteur ou sur une ligne de légende.
  ///
  /// **Les deux gestes appellent le même code**, et c'est ce qui fait qu'ils ne
  /// peuvent pas se mettre à faire deux choses différentes : un anneau et sa
  /// légende montrent la même chose, ils doivent y répondre pareil (décision
  /// de Fabrice, 03/08/2026).
  ///
  /// Absent en F19 : son anneau ne se creuse pas, et il ne prend alors ni
  /// curseur de main ni rôle de bouton — un dessin qui a l'air cliquable sans
  /// l'être est pire qu'un dessin inerte.
  /// `null` désigne **l'anneau vide** : il n'y a pas de part à nommer, mais
  /// il faut pouvoir en sortir. Sans ce clic-là, un mois sans opération dans
  /// un poste creusé serait une impasse — l'anneau ne montre rien et rien ne
  /// permet de remonter.
  onPick?: (slice: RingSlice | null) => void;
}

/// Dessine un anneau et sa légende dans `holder`.
export function drawRing(
  holder: HTMLElement,
  slices: RingSlice[],
  options: RingOptions,
): void {
  holder.replaceChildren();

  if (slices.length === 0) {
    // **Un anneau vide reste un anneau** (décision de Fabrice, 03/08/2026) :
    // « un anneau vide gris clair avec le message ». La carte garde sa forme
    // et sa place — un mois sans rien ne fait pas sauter la mise en page — et
    // surtout il reste cliquable, ce qui est la seule façon de sortir d'un
    // poste creusé dont le mois regardé ne contient rien.
    //
    // **Seulement là où l'anneau se creuse.** F19 garde exactement ce qu'elle
    // montrait — sa phrase, et rien d'autre : elle a été validée le 26/07/2026
    // et son anneau vide n'a personne à faire revenir en arrière. La silhouette
    // grise n'existe que pour être cliquée ; là où l'on ne clique pas, elle
    // n'aurait été qu'une décoration nouvelle dans une fenêtre déjà acceptée.
    if (!options.onPick) {
      const alone = document.createElement("p");
      alone.className = "card__empty";
      alone.textContent = options.emptyText;
      holder.append(alone);
      return;
    }

    const back = options.onPick;
    const hollow = node("svg", {
      viewBox: `0 0 ${SIZE} ${SIZE}`,
      width: String(SIZE),
      height: String(SIZE),
    });
    hollow.classList.add("ring", "ring--empty");
    const silhouette = node("path", {
      d: wholeRingPath(options.relief === true ? SQUASH : 1),
      "fill-rule": "evenodd",
    });
    hollow.append(silhouette);
    {
      hollow.classList.add("is-pickable");
      hollow.setAttribute("role", "button");
      hollow.setAttribute("tabindex", "0");
      hollow.addEventListener("click", () => back(null));
      hollow.addEventListener("keydown", (event) => {
        const key = (event as KeyboardEvent).key;
        if (key === "Enter" || key === " ") {
          event.preventDefault();
          back(null);
        }
      });
    }
    const empty = document.createElement("p");
    empty.className = "card__empty";
    empty.textContent = options.emptyText;
    holder.append(hollow, empty);
    return;
  }

  const relief = options.relief === true;
  const squash = relief ? SQUASH : 1;
  const total = slices.reduce((sum, part) => sum + part.amount, 0);
  const alone = slices.length === 1;

  const svg = node("svg", {
    viewBox: `0 0 ${SIZE} ${SIZE}`,
    width: String(SIZE),
    height: String(SIZE),
  });
  svg.classList.add("ring");

  // Les bornes de chaque secteur, calculées d'abord : les parois se dessinent
  // toutes avant les faces du dessus, et il faut donc les avoir sous la main.
  let angle = 0;
  const sectors = slices.map((part, rank) => {
    const sweep = total === 0 ? 0 : (part.amount / total) * 360;
    const sector = { part, rank, from: angle, to: angle + sweep, sweep };
    angle += sweep;
    return sector;
  });

  if (relief) {
    // **Les parois d'abord, les faces ensuite.** Une paroi descend depuis le
    // bord ; une face est au-dessus. Poser les faces en dernier suffit donc à
    // ce que chacune recouvre ce qu'elle doit, sans trier quoi que ce soit.
    //
    // La paroi du trou ne se voit qu'à l'**arrière** (on aperçoit le fond du
    // trou) et celle du bord extérieur qu'à l'**avant** — soit, midi étant en
    // haut et le tour se faisant dans le sens des aiguilles, 270°→90° pour
    // l'une et 90°→270° pour l'autre.
    for (const sector of sectors) {
      for (const range of [
        clip(sector.from, sector.to, -0.001, 90),
        clip(sector.from, sector.to, 270, 360.001),
      ]) {
        if (range) {
          svg.append(
            node("path", {
              d: wallPath(range[0], range[1], INNER),
              fill: shade(colourOf(sector.rank), INNER_WALL_SHADE),
            }),
          );
        }
      }
    }
    for (const sector of sectors) {
      const front = clip(sector.from, sector.to, 90, 270);
      if (front) {
        svg.append(
          node("path", {
            d: wallPath(front[0], front[1], OUTER),
            fill: shade(colourOf(sector.rank), OUTER_WALL_SHADE),
          }),
        );
      }
    }
  }

  for (const sector of sectors) {
    const face = node("path", {
      d: alone ? wholeRingPath(squash) : sectorPath(sector.from, sector.to, squash),
      fill: colourOf(sector.rank),
      // Le filet de la couleur du fond sépare deux secteurs voisins : sans lui,
      // deux teintes proches se touchent et ne font plus qu'une tache.
      stroke: "#FFFFFF",
      "stroke-width": "2",
      // **La face d'un secteur se nomme**, pour qu'on puisse la compter sans
      // compter les parois (04/08/2026). En relief un secteur porte deux ou
      // trois tracés ; « un tracé, une part » était vrai à plat et ne l'est
      // plus. Une vérification qui compte des tracés compterait alors le
      // relief au lieu de compter les postes budgétaires.
      class: "ring__sector",
    });
    if (alone) {
      face.setAttribute("fill-rule", "evenodd");
    }
    const title = document.createElementNS(NAMESPACE, "title");
    title.textContent = `${sector.part.label} — ${sector.part.text}`;
    face.append(title);
    pickable(face, sector.part, options);
    svg.append(face);

    // La valeur, écrite au milieu du secteur. Un secteur trop mince ne peut
    // pas la porter : elle déborderait sur ses voisins et deviendrait
    // illisible pour tout le monde.
    if (sector.sweep >= 12) {
      const [x, y] = pointAt(sector.from + sector.sweep / 2, (OUTER + INNER) / 2, squash);
      const label = node("text", {
        x: String(x),
        y: String(y),
        class: "ring__value",
      });
      label.textContent = roundedUnits(sector.part.amount);
      svg.append(label);
    }
  }

  const legend = document.createElement("ul");
  legend.className = "legend";
  if (options.legendTitle) {
    const heading = document.createElement("li");
    heading.className = "legend__title";
    heading.textContent = options.legendTitle;
    legend.append(heading);
  }
  slices.forEach((part, rank) => {
    const line = document.createElement("li");
    line.className = "legend__entry";
    const square = document.createElement("span");
    square.className = "legend__square";
    square.style.backgroundColor = colourOf(rank);
    const name = document.createElement("span");
    name.className = "legend__label";
    name.textContent = part.label;
    const amount = document.createElement("span");
    amount.className = "legend__amount";
    amount.textContent = part.text;
    line.append(square, name, amount);
    pickable(line, part, options);
    legend.append(line);
  });

  holder.append(svg, legend);
}

/// Rend un secteur ou une ligne de légende cliquable — ou ne fait rien.
///
/// **Au clavier aussi.** Un secteur est un tracé SVG, pas un bouton : sans
/// `tabindex` ni touche Entrée, il n'existerait que pour la souris, et une
/// fenêtre de Radinus se parcourt au clavier comme le reste du logiciel.
function pickable(
  node: SVGElement | HTMLElement,
  slice: RingSlice,
  options: RingOptions,
): void {
  const pick = options.onPick;
  if (!pick) {
    return;
  }
  node.classList.add("is-pickable");
  node.setAttribute("role", "button");
  node.setAttribute("tabindex", "0");
  node.addEventListener("click", () => pick(slice));
  node.addEventListener("keydown", (event) => {
    const key = (event as KeyboardEvent).key;
    if (key === "Enter" || key === " ") {
      event.preventDefault();
      pick(slice);
    }
  });
}
