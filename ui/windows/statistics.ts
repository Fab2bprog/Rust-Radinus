// F20-F24 — les six statistiques, **une seule page**.
//
// Catégories, affectations, postes budgétaires, moyens de paiement, tiers,
// projets : l'axe arrive dans l'adresse (`?axis=`), comme la nomenclature
// arrive dans celle des listes. Celle des catégories a été bâtie la première
// et Fabrice l'a validée le 26/07/2026 avant de demander les cinq autres — sa
// méthode : on s'arrête à une, on la rend juste, on en tire les autres.
//
// **Rien n'a été copié.** Six copies de ce fichier auraient été six copies de
// chaque faute qu'il a fallu une journée pour retirer — le rafraîchissement
// qui ne rafraîchissait pas, les interrupteurs sans nom, la case Cumul qui
// montrait le mauvais mois, la fenêtre qui gardait les comptes de sa première
// ouverture. Tout cela est corrigé une fois, et les six en profitent.
//
// Les trois temps de l'ergonomie (04_SPECIFICATIONS_FENETRES.md) : on a déjà
// choisi les comptes, la matrice en fait la synthèse par mois, et cliquer
// **n'importe quelle case chiffrée** — croisement, colonne Total, lignes de
// synthèse — donne en bas les opérations qu'elle compte.
//
// **Les couleurs disent quelque chose de précis** (règle confirmée par
// l'auteur) : blanche = rien du tout, bleu-violet = somme positive, rose =
// somme négative, verte = des montants qui s'annulent. Le vert et le blanc
// portent tous deux zéro et ne veulent pas dire la même chose — c'est
// pourquoi le noyau compte les opérations et ne se contente pas de sommer.
//
// La matrice n'est pas bâtie sur le tableau partagé : celui-ci sélectionne des
// **lignes**, alors qu'ici on choisit une **case**. Le détail du bas, lui, est
// une liste ordinaire et s'en sert.

import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { save } from "@tauri-apps/plugin-dialog";
import { askForWholeNumber } from "./dialog";
import {
  contextLine,
  empty as emptyCell,
  money as moneyCell,
  onRightClick,
  text as textCell,
  type Sheet,
  type SheetCell,
} from "./export";
import { Table } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

interface MatrixRow {
  id: number;
  label: string;
  months: string[];
  month_values: number[];
  filled: boolean[];
  total: string;
  total_value: number;
  total_filled: boolean;
  is_empty: boolean;
}

interface Matrix {
  rows: MatrixRow[];
  sum: string[];
  sum_values: number[];
  sum_filled: boolean[];
  sum_total: string;
  sum_total_value: number;
  cumulative: string[];
  cumulative_values: number[];
  has_data: boolean;
  month_names: string[];
  accounts: string;
}

interface DetailRow {
  id: number;
  /// `0` pour une opération, la clef de sa mère pour une ventilation. C'est
  /// ce qui décide quelle fiche s'ouvre au double-clic.
  parent_id: number;
  label: string;
  date: string;
  clearing_date: string;
  /// Les deux mêmes dates en ISO : c'est sur elles que les colonnes se trient,
  /// et non sur ce qui est affiché, qui commence par le quantième.
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
  /// Sur quoi les cinq menus déroulants sont posés.
  category_id: number;
  assignment_id: number;
  payment_mode_id: number;
  payee_id: number;
  project_id: number;
}

/// Un élément d'une nomenclature, tel qu'un menu déroulant le propose.
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

/// Les cinq listes dans lesquelles on choisit. Lues une fois à l'ouverture :
/// une nomenclature ne bouge pas pendant qu'on regarde une statistique.
let combos: Combos = {
  category: [],
  assignment: [],
  payment_mode: [],
  payee: [],
  project: [],
};

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoMessage = element<HTMLElement>("info-message");
const accountsLine = element<HTMLElement>("accounts-line");
const matrixGrid = element<HTMLElement>("matrix");

function say(message: string, alert = false): void {
  infoMessage.textContent = message;
  element<HTMLElement>("info-bar").classList.toggle("info-bar--alert", alert);
}

/// Les comptes choisis dans F06, et l'année regardée. Les comptes arrivent
/// dans l'adresse et ne changent pas : en changer, c'est repasser par le
/// choix des comptes.
let accountIds: number[] = [];
let year = new Date().getFullYear();

/// **Sur quel axe cette fenêtre porte** — catégories, affectations, postes
/// budgétaires, moyens de paiement, tiers, projets. Il arrive dans l'adresse
/// et ne change jamais : ce sont six fenêtres, chacune avec son étiquette,
/// pas une fenêtre dans six états. On veut pouvoir regarder les catégories et
/// les tiers côte à côte.
const AXIS = new URLSearchParams(window.location.search).get("axis") ?? "category";

/// Les cinq interrupteurs. Tous allumés au départ, comme dans la capture :
/// la statistique montre tout tant qu'on ne lui a rien retiré.
const switches = {
  pointed: true,
  committed: true,
  planned: true,
  debits: true,
  credits: true,
};

type SwitchName = keyof typeof switches;

/// L'ordre du bandeau, et il compte : le noyau rend les cinq phrases dans
/// celui-ci.
const SWITCHES: [SwitchName][] = [
  ["pointed"],
  ["committed"],
  ["planned"],
  ["debits"],
  ["credits"],
];

/// De quelle sorte est une case : un croisement de la matrice, la ligne Somme
/// ou la ligne Cumul.
type CellKind = "axis" | "sum" | "cumulative";

/// La case choisie. **La sorte en fait partie** : la Somme d'un mois et le
/// Cumul du même mois sont deux cases l'une au-dessus de l'autre, et sans
/// cette distinction cliquer l'une choisissait les deux (Fabrice,
/// 26/07/2026). Elles ne montrent d'ailleurs pas la même chose — le cumul de
/// mai, ce sont les opérations de janvier à mai.
///
/// Rien n'est retenu d'autre : ce qui est peint en sélection est relu de la
/// matrice au moment du dessin.
interface Cell {
  kind: CellKind;
  /// La valeur de l'axe — une catégorie, un tiers, un poste budgétaire —, ou
  /// rien pour les deux lignes de synthèse, qui portent sur tout.
  value: number | null;
  month: number | null;
}

let chosen: Cell | null = null;

// --- Le détail du bas ----------------------------------------------------

/// Une colonne de classement : le libellé se lit, et sur la ligne choisie il
/// devient un **menu déroulant**.
///
/// « Il ne faut pas mettre des champs texte mais des menus déroulants, pour
/// que l'on puisse changer le classement sans rentrer dans la fiche »
/// (Fabrice, 26/07/2026). C'est exactement ce que fait déjà F02 : on regarde
/// une statistique, on voit une opération mal classée, on la reclasse sur
/// place. Un classement ne se tape jamais — on choisit parmi ce qui existe.
///
/// **Choisir écrit, puis tout est recalculé.** Reclasser une opération la fait
/// changer de ligne dans la matrice : les chiffres d'avant sont faux à la
/// seconde où l'on a choisi. On refait donc le calcul global et l'on se remet
/// où l'on était — la méthode que Fabrice a imposée le 26/07/2026, celle qui
/// vaut déjà pour le retour d'une fiche.
function nomenclatureColumn(
  title: string,
  kind: string,
  text: (row: DetailRow) => string,
  options: () => Item[],
  value: (row: DetailRow) => number,
  width: string,
  editable?: (row: DetailRow) => boolean,
) {
  return {
    title: () => t(title),
    cell: text,
    width,
    editor: {
      options,
      value,
      editable,
      change: (row: DetailRow, picked: number) => {
        void invoke("set_operation_nomenclature", { id: row.id, kind, value: picked })
          // F02 regarde peut-être les mêmes opérations : elle est prévenue,
          // sans quoi elle continuerait d'afficher l'ancien classement.
          .then(() => invoke("notify_operations_changed"))
          .then(() => reload())
          .catch((error) => say(tError("ui-save-failed", error), true));
      },
    },
  };
}

/// **Une sous-opération n'a pas de mode de paiement à elle** (règle de
/// Fabrice, 26/07/2026 : « dans une sous-opération, comme est le complément,
/// on ne peut pas toucher au mode de paiement, cela serait illogique »). Elle
/// porte celui de sa mère, et un mode choisi sur une fille serait effacé au
/// recalcul suivant. Le menu n'est donc pas là sur la ligne d'une fille — les
/// quatre autres y sont, et doivent y être : distinguer les catégories est
/// toute la raison d'être d'une ventilation.
function isATopLevelOperation(row: DetailRow): boolean {
  return row.parent_id === 0;
}

const detail = new Table<DetailRow>({
  container: element<HTMLDivElement>("rows"),
  virtualized: true,
  rowHeight: 24,
  columns: [
    {
      title: () => t("statistics-column-date"),
      cell: (row) => row.date,
      key: (row) => row.date_value,
      width: "100px",
    },
    {
      title: () => t("statistics-column-clearing-date"),
      cell: (row) => row.clearing_date,
      key: (row) => row.clearing_date_value,
      width: "110px",
    },
    { title: () => t("statistics-column-label"), cell: (row) => row.label, width: "2.4fr" },
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
      isATopLevelOperation,
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
      title: () => t("statistics-column-amount"),
      cell: (row) => (row.amount < 0 ? row.debit : row.credit),
      key: (row) => row.amount,
      money: (row) => row.amount,
      numeric: true,
      width: "1fr",
    },
    {
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
    },
  ],
  identity: (row) => row.id,
  // **Double-cliquer ouvre la fiche de la ligne** : F03 pour une opération,
  // F04 pour une ventilation (demande de Fabrice, 26/07/2026). La fenêtre
  // n'envoie qu'une clef — c'est le contrôleur qui lit l'enregistrement et
  // décide, puisque lui seul sait à quel compte il appartient et un détail
  // porte souvent plusieurs comptes à la fois.
  onActivate: (row: DetailRow) => {
    void invoke("open_form_for_operation", { id: row.id }).catch((error) =>
      say(tError("ui-open-failed", error), true),
    );
  },
  rowClass: (row) => (row.amount < 0 ? "list__row--debit" : null),
  exportAs: () => ({ name: t("statistics-detail-name"), detail: contextOfWhatIsShown() }),
  emptyText: () => (chosen === null ? t("statistics-detail-empty") : t("statistics-detail-none")),
  filteredOutText: () => t("ui-no-match"),
});

// --- Les interrupteurs ---------------------------------------------------

/// Le libellé d'un interrupteur bascule ON/OFF, comme dans l'original :
/// l'interrupteur dit lui-même où il est, plutôt qu'un état à deviner.
///
/// **La phrase est écrite par le noyau, en entier.** Elle porte un trou pour
/// le mot ON/OFF, et le dictionnaire ne porte que ce qui se résout sans
/// argument — la fenêtre remplissait ce trou elle-même et affichait la clef
/// brute : les cinq interrupteurs s'appelaient tous
/// « statistics-switch-pointed » (signalé par Fabrice, 26/07/2026). C'était
/// déjà la faute du total de la sélection de F02. Seule Fluent sait où est le
/// trou d'une phrase.
async function refreshSwitchLabels(): Promise<void> {
  try {
    const said = await invoke<string[]>("statistics_switch_labels", { switches });
    SWITCHES.forEach(([name], index) => {
      const label = document.querySelector<HTMLElement>(
        `.switch[data-name="${name}"] .switch__label`,
      );
      if (label && said[index] !== undefined) {
        label.textContent = said[index];
      }
    });
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

function buildSwitches(): void {
  const bar = element<HTMLElement>("switches");
  bar.replaceChildren();
  for (const [name] of SWITCHES) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "switch";
    button.dataset.name = name;
    button.setAttribute("aria-pressed", String(switches[name]));

    const knob = document.createElement("span");
    knob.className = "switch__knob";
    const text = document.createElement("span");
    text.className = "switch__label";

    button.append(knob, text);
    button.addEventListener("click", () => {
      switches[name] = !switches[name];
      button.setAttribute("aria-pressed", String(switches[name]));
      // La case choisie est gardée, pour la même raison qu'au changement
      // d'année : un interrupteur ne change que les chiffres. Voir une case
      // passer du rouge au blanc quand on retire les crédits est justement ce
      // qu'on cherche à observer.
      void refreshSwitchLabels();
      void reload();
    });
    bar.append(button);
  }
}

// --- La matrice ----------------------------------------------------------

/// La couleur d'une case, et rien d'autre ne la décide.
function cellClass(value: number, filled: boolean): string {
  if (!filled) {
    return "matrix__cell";
  }
  if (value > 0) {
    return "matrix__cell matrix__cell--positive";
  }
  if (value < 0) {
    return "matrix__cell matrix__cell--negative";
  }
  // Somme nulle mais des opérations derrière : le vert de l'auteur, celui du
  // virement d'un compte à l'autre quand les deux sont dans la sélection.
  return "matrix__cell matrix__cell--cancelling";
}

function isChosen(cell: Cell): boolean {
  return (
    chosen !== null &&
    chosen.kind === cell.kind &&
    chosen.value === cell.value &&
    chosen.month === cell.month
  );
}

/// Pose une case dans la grille. Une case chiffrée se clique et donne le
/// détail ; une case vide ne se clique pas — il n'y a rien derrière.
function putCell(
  row: HTMLElement,
  text: string,
  value: number,
  filled: boolean,
  where: Cell,
  extra = "",
  summary = false,
): void {
  const cell = document.createElement("span");
  // **Les lignes de synthèse ne sont pas peintes.** Dans l'original, Somme et
  // Cumul restent sur fond blanc et c'est le *chiffre* qui prend la couleur :
  // bleu s'il est positif, rouge s'il est négatif. Les peindre comme les
  // autres ferait deux bandes de couleur pleine en bas de la matrice, là où
  // l'auteur a mis deux lignes qui se lisent.
  const base = summary
    ? `matrix__cell ${value < 0 ? "matrix__cell--down" : "matrix__cell--up"}`
    : cellClass(value, filled);
  cell.className = `${base}${extra ? ` ${extra}` : ""}`;
  cell.textContent = text;
  if (isChosen(where)) {
    cell.classList.add("matrix__cell--chosen");
  }
  // **Une case vide se clique comme les autres** (remarque de Fabrice,
  // 26/07/2026). L'interdire ne protégeait de rien : voir qu'il n'y a aucune
  // opération derrière une case *est* une réponse, et le détail le dit en
  // toutes lettres. Une case sur laquelle on ne peut pas cliquer laisse
  // seulement croire que le logiciel a un problème.
  cell.tabIndex = 0;
  cell.addEventListener("click", () => {
    chosen = where;
    draw();
    void showDetail();
  });
  row.append(cell);
}

let matrix: Matrix | null = null;

/// **Rien de ce qui ne change que les chiffres ne doit faire perdre la
/// position** (règle de Fabrice, 26/07/2026).
///
/// Changer d'année, basculer un interrupteur, revenir sur la fenêtre : les
/// lignes et les colonnes sont exactement les mêmes — la matrice montre
/// **toutes** les catégories, même à zéro, toujours dans le même ordre — donc
/// la case sous le curseur désigne la même chose et le défilement se
/// transpose tel quel. C'est ce qui permet de cliquer Impôts / juin, de
/// reculer d'un an, et de lire le montant de l'an dernier au même endroit de
/// l'écran, sans le chercher des yeux.
///
/// Ce n'est vrai que parce qu'aucune ligne vide n'est masquée : une catégorie
/// sans mouvement en 2025 décalerait tout le tableau et la comparaison serait
/// perdue.
///
/// Redessiner remplace tout le contenu de la grille, ce qui remet le
/// défilement à zéro : il est donc relevé avant et reposé après.
function draw(): void {
  if (matrix === null) {
    return;
  }
  const zone = element<HTMLElement>("matrix-zone");
  const wasAt = { top: zone.scrollTop, left: zone.scrollLeft };
  const built = document.createDocumentFragment();

  // L'en-tête : l'axe, les douze mois, le total.
  const head = document.createElement("div");
  head.className = "matrix__row matrix__row--head";
  for (const title of [t("statistics-axis-column"), ...matrix.month_names, t("statistics-total")]) {
    const cell = document.createElement("span");
    cell.className = "matrix__title";
    cell.textContent = title;
    head.append(cell);
  }
  built.append(head);

  // Une ligne par valeur de l'axe, **même vide** : la matrice est un plan de
  // comptes, pas un résumé de ce qui s'est passé.
  for (const row of matrix.rows) {
    const line = document.createElement("div");
    line.className = "matrix__row";
    const label = document.createElement("span");
    label.className = "matrix__label";
    label.textContent = row.label;
    line.append(label);

    for (let month = 0; month < 12; month += 1) {
      putCell(line, row.months[month], row.month_values[month], row.filled[month], {
        kind: "axis",
        value: row.id,
        month: month + 1,
      });
    }
    putCell(
      line,
      row.total,
      row.total_value,
      row.total_filled,
      { kind: "axis", value: row.id, month: null },
      "matrix__cell--total",
    );
    built.append(line);
  }

  if (matrix.has_data) {
    for (const [key, values, texts, extra] of [
      ["statistics-sum", matrix.sum_values, matrix.sum, "matrix__row--sum"],
      ["statistics-cumulative", matrix.cumulative_values, matrix.cumulative, "matrix__row--cumulative"],
    ] as const) {
      const line = document.createElement("div");
      line.className = `matrix__row ${extra}`;
      const label = document.createElement("span");
      label.className = "matrix__label";
      label.textContent = t(key);
      line.append(label);

      const summing = key === "statistics-sum";
      for (let month = 0; month < 12; month += 1) {
        // La Somme n'écrit rien sur un mois vide ; le Cumul, lui, est reporté
        // jusqu'à décembre — c'est ce qui fait qu'en décembre il vaut l'année.
        const filled = summing ? matrix.sum_filled[month] : true;
        putCell(
          line,
          texts[month],
          values[month],
          filled,
          { kind: summing ? "sum" : "cumulative", value: null, month: month + 1 },
          "",
          true,
        );
      }
      if (summing) {
        putCell(
          line,
          matrix.sum_total,
          matrix.sum_total_value,
          true,
          { kind: "sum", value: null, month: null },
          "matrix__cell--total",
          true,
        );
      } else {
        const empty = document.createElement("span");
        empty.className = "matrix__cell matrix__cell--total";
        line.append(empty);
      }
      built.append(line);
    }
  }

  matrixGrid.replaceChildren(built);
  zone.scrollTop = wasAt.top;
  zone.scrollLeft = wasAt.left;
}

// --- L'export de la matrice ----------------------------------------------
//
// La matrice n'est pas un tableau partagé — elle se sélectionne à la case et
// non à la ligne — alors elle fabrique sa feuille elle-même. Mais c'est la
// même feuille, le même exportateur et les mêmes deux formats : le vocabulaire
// commun sert justement à ça.

/// Les couleurs des cellules, telles qu'elles sont à l'écran (charte §1). Le
/// `.xlsx` les reprend ; le CSV n'en a pas.
const FILLS = {
  positive: "9999FF",
  negative: "FF9999",
  cancelling: "99FF99",
};

function fillOf(value: number, filled: boolean): string | null {
  if (!filled) {
    return null;
  }
  if (value > 0) {
    return FILLS.positive;
  }
  if (value < 0) {
    return FILLS.negative;
  }
  return FILLS.cancelling;
}

/// Ce que la fenêtre montre en ce moment, dit en une ligne : l'année, les
/// comptes, et l'état des cinq interrupteurs. C'est ce qui part en tête du
/// fichier — un tableau nu retrouvé dans six mois ne dit plus sur quoi il
/// portait.
function contextOfWhatIsShown(): string {
  return contextOf(year, matrix?.accounts ?? "");
}

/// La même ligne, pour une année quelconque : chaque onglet du classeur de
/// toutes les années porte la sienne, si bien qu'un onglet retrouvé seul dit
/// encore sur quoi il portait.
function contextOf(shownYear: number, accounts: string): string {
  const lit = SWITCHES.filter(([name]) => switches[name]).length;
  return `${shownYear} — ${accounts} — ${lit}/5`;
}

/// La feuille de la matrice : **exactement ce qui est affiché**, cases vides
/// comprises, lignes de synthèse comprises, avec les couleurs de l'écran. Rien
/// n'est recalculé pour l'occasion — on lit les valeurs affichées (règle de
/// Fabrice, 26/07/2026).
///
/// **Écrite pour une matrice quelconque, et non pour celle de l'écran** : la
/// fenêtre l'appelle avec la sienne, et l'export de toutes les années
/// l'appelle douze fois, avec celle de chaque année. Une seule façon de
/// dessiner un onglet, donc aucune façon qu'un onglet diffère d'un autre.
async function sheetOf(shown: Matrix, name: string, detail: string): Promise<Sheet> {
  const heading: SheetCell[] = [
    textCell(t("statistics-axis-column"), true),
    ...shown.month_names.map((month) => textCell(month, true)),
    textCell(t("statistics-total"), true),
  ];

  const lines: SheetCell[][] = shown.rows.map((row) => [
    textCell(row.label),
    ...row.month_values.map((value, month) =>
      row.filled[month] ? moneyCell(value, fillOf(value, true)) : emptyCell(),
    ),
    row.total_filled ? moneyCell(row.total_value, fillOf(row.total_value, true)) : emptyCell(),
  ]);

  if (shown.has_data) {
    // Les deux lignes de synthèse ne sont pas peintes à l'écran : elles ne le
    // sont pas non plus dans le fichier. Elles partent en gras, comme elles
    // s'affichent.
    lines.push([
      textCell(t("statistics-sum"), true),
      ...shown.sum_values.map((value, month) =>
        shown.sum_filled[month] ? moneyCell(value, null, true) : emptyCell(),
      ),
      moneyCell(shown.sum_total_value, null, true),
    ]);
    lines.push([
      textCell(t("statistics-cumulative"), true),
      ...shown.cumulative_values.map((value) => moneyCell(value, null, true)),
      emptyCell(),
    ]);
  }

  return {
    name,
    context: await contextLine(t("statistics-window-name"), detail),
    header_rows: 1,
    rows: [heading, ...lines],
    // La colonne de l'axe est large, les douze mois et le total le sont moins.
    widths: [34, ...Array.from({ length: 13 }, () => 15)],
  };
}

async function matrixSheet(): Promise<Sheet> {
  const name = t("statistics-window-name");
  if (matrix === null) {
    return { name, context: "", header_rows: 0, rows: [], widths: [] };
  }
  return await sheetOf(matrix, name, contextOfWhatIsShown());
}

// --- Toutes les années dans un seul classeur -----------------------------
//
// Demande de Fabrice, 26/07/2026 : « toutes les années non vides seront
// exportées, un onglet par an, chaque onglet nommé AN_XXXX ».
//
// **Les années vides sont vides sous les interrupteurs posés** — c'est son
// choix, et c'est le seul qui garde le classeur fidèle à l'écran : éteindre
// les crédits peut vider une année entière, et le fichier doit alors être ce
// que la fenêtre montrerait, année après année.
//
// La fenêtre demande la liste des années, puis pour chacune la matrice
// qu'elle sait déjà demander, et fabrique la feuille qu'elle sait déjà
// fabriquer. **Rien n'est recalculé autrement qu'à l'écran** : chaque onglet
// est littéralement ce qu'on verrait en allant sur cette année-là.

async function exportEveryYear(extension: "xlsx" | "ods"): Promise<void> {
  try {
    const years = await invoke<number[]>("statistics_years", { accountIds, switches });
    if (years.length === 0) {
      say(t("export-no-year"), true);
      return;
    }

    const chosenFile = await save({
      defaultPath: `${t("statistics-window-name")}.${extension}`,
      filters: [{ name: extension.toUpperCase(), extensions: [extension] }],
    });
    if (chosenFile === null) {
      return;
    }

    const book: Sheet[] = [];
    for (const shownYear of years) {
      const yearly = await invoke<Matrix>("axis_statistics", {
        axis: AXIS,
        accountIds,
        year: shownYear,
        switches,
      });
      book.push(await sheetOf(yearly, `AN_${shownYear}`, contextOf(shownYear, yearly.accounts)));
    }
    say(await invoke<string>("export_book", { sheets: book, path: chosenFile }));
  } catch (error) {
    say(String(error), true);
  }
}

/// La barre de menus de la fenêtre. Une seule entrée pour l'instant, et c'est
/// assez : un menu qui ne sert à rien encombre.
function buildMenu(): void {
  const bar = element<HTMLElement>("window-menu");
  bar.replaceChildren();

  const holder = document.createElement("div");
  holder.className = "window-menu__holder";
  const entry = document.createElement("button");
  entry.type = "button";
  entry.className = "window-menu__entry";
  entry.textContent = t("export-menu");

  const choices = document.createElement("div");
  choices.className = "window-menu__choices";
  choices.hidden = true;
  for (const [key, extension] of [
    ["export-all-years-excel", "xlsx"],
    ["export-all-years-ods", "ods"],
  ] as const) {
    const choice = document.createElement("button");
    choice.type = "button";
    choice.className = "window-menu__choice window-menu__choice--plain";
    choice.dataset.key = key;
    choice.textContent = t(key);
    choice.addEventListener("click", () => {
      choices.hidden = true;
      void exportEveryYear(extension);
    });
    choices.append(choice);
  }

  entry.addEventListener("click", (event) => {
    event.stopPropagation();
    choices.hidden = !choices.hidden;
  });
  document.addEventListener("click", () => {
    choices.hidden = true;
  });

  holder.append(entry, choices);
  bar.append(holder);
}

async function showDetail(): Promise<void> {
  if (chosen === null) {
    detail.setRows([]);
    return;
  }
  try {
    const rows = await invoke<DetailRow[]>("statistics_detail", {
      axis: AXIS,
      accountIds,
      year,
      switches,
      cell: chosen,
    });
    detail.setRows(rows);
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

async function reload(): Promise<void> {
  element<HTMLElement>("year").textContent = String(year);
  if (accountIds.length === 0) {
    say(t("statistics-no-account"), true);
    matrix = null;
    matrixGrid.replaceChildren();
    detail.setRows([]);
    return;
  }
  try {
    matrix = await invoke<Matrix>("axis_statistics", { axis: AXIS, accountIds, year, switches });
    accountsLine.textContent = matrix.accounts;
    say(matrix.has_data ? "" : t("statistics-no-data"));
    draw();
    await showDetail();
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// **Redemandée avec d'autres comptes, la fenêtre doit les entendre.**
///
/// Faute signalée par Fabrice le 26/07/2026 : quel que soit le compte choisi,
/// la statistique restait celle du premier. La cause n'était pas dans le choix
/// des comptes, qui marchait, mais ici : une fenêtre de Radinus est **bâtie
/// une fois et jamais détruite**, donc la deuxième demande ne recharge pas la
/// page — elle envoie les nouveaux paramètres par cet événement et remontre la
/// fenêtre. Personne ne l'écoutait, et `accountIds` gardait la valeur de la
/// toute première ouverture. C'est la pire sorte de faute pour un logiciel
/// d'argent : des chiffres justes, sur le mauvais compte, sans un mot.
///
/// **La position est gardée** : changer de comptes ne change que les chiffres
/// — les catégories restent les catégories et juin reste juin —, et la règle
/// de Fabrice est que rien de ce qui ne change que les chiffres ne fait perdre
/// sa place.
const PARAMETERS_EVENT = `window-parameters:statistics-${AXIS}`;

void listen<string>(PARAMETERS_EVENT, (event) => {
  readParameters(event.payload);
  void reload();
});

function readParameters(query: string): void {
  const parameters = new URLSearchParams(query);
  accountIds = (parameters.get("accounts") ?? "")
    .split(",")
    .map((piece) => Number(piece.trim()))
    .filter((id) => Number.isFinite(id) && id > 0);
  const asked = Number(parameters.get("year"));
  if (Number.isFinite(asked) && asked > 0) {
    year = asked;
  }
  // **L'axe reste dans l'adresse.** Le réécrire sans lui l'effaçait, et la
  // fenêtre rechargée serait redevenue celle des catégories (faute du
  // 26/07/2026 : c'est la même que l'axe absent de l'adresse d'ouverture).
  history.replaceState(
    null,
    "",
    `?axis=${AXIS}&accounts=${accountIds.join(",")}&year=${year}`,
  );
}

/// Le splitter : la frontière entre la matrice et le détail se déplace à la
/// souris. Rien n'est retenu d'une fenêtre à l'autre — la hauteur est celle du
/// document, et le document est ce qui fait foi.
function makeSplitterDraggable(): void {
  const splitter = element<HTMLElement>("splitter");
  const zone = element<HTMLElement>("matrix-zone");
  let dragging = false;

  splitter.addEventListener("mousedown", (event) => {
    event.preventDefault();
    dragging = true;
    document.body.classList.add("splitting");
  });
  document.addEventListener("mousemove", (event) => {
    if (!dragging) {
      return;
    }
    const top = zone.getBoundingClientRect().top;
    const height = Math.max(120, event.clientY - top);
    zone.style.flex = `0 0 ${height}px`;
  });
  document.addEventListener("mouseup", () => {
    dragging = false;
    document.body.classList.remove("splitting");
  });
}

/// Change d'année, **en restant dans les bornes de Radinus**. C'est le noyau
/// qui les tient et qui ramène la valeur dedans : les deux horloges et la
/// saisie au clavier obéissent ainsi à exactement la même règle, plutôt qu'à
/// deux copies de la même règle.
async function goToYear(asked: number): Promise<void> {
  try {
    const kept = await invoke<number>("statistics_year", { year: asked });
    if (kept === year) {
      // Déjà au bout : rien n'a changé, rien à recalculer.
      return;
    }
    year = kept;
    // **La case choisie est gardée.** Les lignes ne bougent pas d'une année à
    // l'autre : Impôts reste Impôts et juin reste juin, seuls les montants
    // changent. Si la case était vide l'an dernier, elle reste choisie et le
    // détail le dit — c'est une réponse, pas un raté.
    await reload();
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// Le millésime se clique : on y saisit l'année voulue (demande de Fabrice,
/// 26/07/2026). Le champ n'accepte que des chiffres, quatre au plus, et le
/// noyau ramène ensuite la valeur entre 1950 et 2550 — **il impose, il ne
/// rejette pas**.
async function askForYear(): Promise<void> {
  try {
    const prompt = await invoke<{ question: string; first: number; last: number }>(
      "statistics_year_prompt",
    );
    const asked = await askForWholeNumber(prompt.question, year, 4, t("ui-yes"), t("ui-no"));
    if (asked === null) {
      return;
    }
    await goToYear(asked);
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

element<HTMLButtonElement>("year").addEventListener("click", () => void askForYear());
element<HTMLButtonElement>("next-year").addEventListener("click", () => void goToYear(year + 1));
element<HTMLButtonElement>("previous-year").addEventListener("click", () => void goToYear(year - 1));
element<HTMLButtonElement>("close").addEventListener("click", () => {
  void invoke("close_statistics", { axis: AXIS });
});

// --- Se remettre à jour, et se remettre où l'on était --------------------
//
// **La méthode est celle de Fabrice** (26/07/2026), après deux tentatives
// ratées de ma part : ne rien tenter de fin, retenir où l'on est, tout
// recalculer, et se replacer.
//
//   1. la position — catégorie, mois, année — est ce que la fenêtre garde ;
//   2. quand on revient dessus, elle refait **le calcul global**, sans
//      chercher ce qui a changé ni pourquoi ;
//   3. puis elle se remet exactement où elle était, case choisie comprise,
//      et rouvre le détail de cette case.
//
// **Et le déclencheur ne passe plus par Tauri.** Mes deux essais précédents
// — un événement adressé à la fenêtre, puis `onFocusChanged` — ont échoué de
// la même façon et pour la même raison : ils empruntaient tous les deux le
// canal d'événements de Tauri. Ici c'est le navigateur lui-même qui le dit,
// par ses propres `focus` et `visibilitychange` : aucun message à transmettre,
// rien à adresser, rien qui puisse se perdre en route.

/// Ce que la fenêtre garde d'elle-même : l'année est dans `year`, la case dans
/// `chosen`. Rien de plus n'est nécessaire pour se replacer — et rien de plus
/// n'est retenu, pour qu'aucun état ne puisse se périmer.
function comeBackToWhereWeWere(): void {
  void reload();
}

/// **Tous les mots de la fenêtre, posés en un seul endroit.**
///
/// Une fenêtre de Radinus est bâtie une fois et jamais détruite : changer de
/// langue ne la reconstruit pas, il faut qu'elle sache se rhabiller. Ce qui
/// pose un mot est donc ici et nulle part ailleurs — une étiquette ajoutée
/// demain suivra la langue sans que personne y pense. L'en-tête de la matrice,
/// les douze mois, les lignes Somme et Cumul sont dessinés par `draw`, que le
/// rechargement rappelle ; les cinq phrases des interrupteurs viennent du
/// noyau, qui seul sait où est leur trou ON/OFF.
///
/// Les cinq boutons se rebâtissent, et cela ne coûte rien : leur état vit dans
/// `switches` et non dans le bouton.
///
/// **La position est gardée** — la case choisie, le défilement de la matrice,
/// l'année, les interrupteurs. Se rhabiller ne change que des mots, et rien de
/// ce qui ne change que les mots ou les chiffres ne fait perdre sa place
/// (règle de Fabrice, 26/07/2026) : `chosen` et `year` ne sont pas touchés, et
/// `draw` relève puis repose le défilement.
///
/// `alsoTheNumbers` dit d'où l'on vient. À l'ouverture, la matrice vient plus
/// bas, une fois passée la barrière de `startup_error` et les comptes lus dans
/// l'adresse : la demander d'ici la demanderait à une base peut-être fermée.
async function dress(alsoTheNumbers = true): Promise<void> {
  detail.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));
  buildMenu();
  buildSwitches();
  await refreshSwitchLabels();
  for (const [id, key] of [
    ["year", "statistics-year-choose"],
    ["next-year", "statistics-year-next"],
    ["previous-year", "statistics-year-previous"],
    ["close", "ui-title-close"],
  ] as const) {
    element<HTMLElement>(id).title = t(key);
  }
  if (alsoTheNumbers) {
    await reload();
  }
}

// Revenir sur la fenêtre : le navigateur le dit sans intermédiaire.
window.addEventListener("focus", () => comeBackToWhereWeWere());
document.addEventListener("visibilitychange", () => {
  if (document.visibilityState === "visible") {
    comeBackToWhereWeWere();
  }
});

void (async () => {
  await loadTexts(AXIS);
  await dress(false);
  // Deux tableaux, deux exports : la matrice par le clic droit sur elle, le
  // détail par le clic droit sur lui, chacun exportant ce qu'il montre. Ni
  // ceux-là ni le splitter ne posent de mot, et ils ne se refont pas : ce sont
  // des écoutes, et une seconde ferait deux exports pour un clic.
  onRightClick(element<HTMLElement>("matrix-zone"), () => matrixSheet(), say);
  detail.exportOnRightClick(say);
  makeSplitterDraggable();
  detail.setRows([]);

  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    return;
  }
  // Ce dans quoi les cinq menus déroulants du détail font choisir. Lu avant
  // la première statistique : une ligne choisie sans ses listes n'offrirait
  // que des menus vides.
  try {
    combos = await invoke<Combos>("list_operation_combos");
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }

  readParameters(window.location.search);
  await reload();
  // **Le titre de ces six fenêtres se compose comme Rust le compose** :
  // `windows.rs` écrit `i18n::about(langue, "window-statistics-title", axe)`,
  // donc la clef part avec l'axe pour argument. Une seule page sert les six, et
  // c'est l'axe — lui seul — qui décide laquelle des six phrases est la bonne.
  //
  // Une réserve, et elle est en Rust : `retitle` nomme l'argument « account »,
  // le nom que réclame le titre de la liste des opérations, alors que la phrase
  // de la statistique choisit sur `$kind`. Tant que le contrôleur ne sait
  // nommer qu'un seul argument, les six titres retombent après un changement de
  // langue sur la branche par défaut, « Statistiques par catégorie ». Ce qui est
  // sous le titre reste juste ; c'est la faute du 26/07/2026 réduite au bandeau,
  // et elle se répare là où le nom est écrit, pas ici.
  // L'axe voyage sous le nom « kind » : c'est là-dessus que la phrase
  // sélectionne. Le lui donner sous « account » titrerait les six fenêtres
  // « par catégorie ».
  onLanguageChanged(dress, {
    key: "window-statistics-title",
    argument: AXIS,
    argumentName: "kind",
  });
})();
