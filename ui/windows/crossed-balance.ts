// F39 — « Bilan croisé » : les catégories en lignes, les affectations en
// colonnes, sur un mois (demande de Fabrice, 25/08/2026).
//
// « Le principe sera exactement le même que les statistiques par catégories.
// Même mise en page, mêmes options ergonomiques etc… » — c'est donc le gabarit
// des six, avec les deux différences qu'il a demandées :
//
//   * les colonnes ne sont plus les douze mois mais **les affectations**, plus
//     « Sans affectation » ; les lignes sont les catégories, plus « Sans
//     catégorie ». Les deux nomenclatures sont montrées en entier, même ce que
//     le mois ne remplit pas : on navigue de mois en mois, et des colonnes qui
//     changeraient de place seraient incomparables ;
//   * la période est **un mois**, et non une année. Le bandeau bleu porte
//     « 09/2026 », les deux horloges avancent et reculent d'un mois, décembre
//     bascule sur janvier de l'année suivante ;
//   * **il n'y a pas de ligne Cumul** : le cumul additionne les mois dans
//     l'ordre, or les affectations n'ont pas d'ordre et le tableau ne porte que
//     sur un mois. La ligne Somme, elle, reste — le total de chaque
//     affectation, toutes catégories confondues.
//
// Tout le reste est celui des six : les cinq interrupteurs, les couleurs des
// cases, le clic qui ouvre le détail en bas, les menus déroulants qui
// reclassent sur place, le double-clic qui ouvre la fiche, le clic droit qui
// exporte. Ces phrases-là ne sont pas réécrites : ce fichier emprunte le
// vocabulaire des statistiques partout où il dit la même chose.

import "./shortcuts";
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
  type MenuAddition,
  type MenuHeadEntry,
  type Sheet,
  type SheetCell,
} from "./export";
import { copyText, oneCell, pureNumber } from "./clipboard";
import { Table } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

interface Column {
  id: number;
  label: string;
}

interface MatrixRow {
  id: number;
  label: string;
  cells: string[];
  cell_values: number[];
  filled: boolean[];
  total: string;
  total_value: number;
  total_filled: boolean;
  is_empty: boolean;
}

interface Matrix {
  columns: Column[];
  rows: MatrixRow[];
  sum: string[];
  sum_values: number[];
  sum_filled: boolean[];
  sum_total: string;
  sum_total_value: number;
  has_data: boolean;
  period: string;
  accounts: string;
}

interface DetailRow {
  id: number;
  parent_id: number;
  label: string;
  /// La référence paiement ; pour une ventilation, celle de sa mère.
  reference: string;
  date: string;
  clearing_date: string;
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

/// Les comptes choisis dans F06 — ils arrivent dans l'adresse et ne changent
/// pas : en changer, c'est repasser par le choix des comptes.
let accountIds: number[] = [];

/// Le mois regardé. Le mois courant à l'ouverture, comme l'année courante des
/// six statistiques.
let year = new Date().getFullYear();
let month = new Date().getMonth() + 1;

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

/// La case choisie. **Deux clefs, et l'absence veut dire « toutes »** : une
/// case ordinaire nomme sa catégorie et son affectation, la colonne Total ne
/// nomme que la catégorie, la ligne Somme ne nomme que l'affectation, et le
/// total général n'en nomme aucune. Le contrôleur lit la même chose.
interface Cell {
  category: number | null;
  assignment: number | null;
}

let chosen: Cell | null = null;

// --- Le détail du bas ----------------------------------------------------
//
// Le même que celui des six statistiques, aux mêmes colonnes et avec les mêmes
// menus déroulants : on regarde un bilan, on voit une opération mal classée,
// on la reclasse sur place sans entrer dans la fiche.

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
    // Le nom de la colonne est celui de sa nomenclature : `category`, `payee`…
    id: kind,
    title: () => t(title),
    cell: text,
    width,
    // Le plancher d'une liste déroulante lisible : en dessous, on ne voit plus
    // ce qu'elle propose.
    minWidth: 110,
    editor: {
      options,
      value,
      editable,
      change: (row: DetailRow, picked: number) => {
        // Reclasser change de ligne **et** de colonne dans ce tableau-ci : les
        // chiffres d'avant sont faux à la seconde où l'on a choisi. On refait
        // donc le calcul global et l'on se remet où l'on était. Les autres
        // fenêtres sont prévenues par le contrôleur, à l'endroit où l'écriture
        // a lieu.
        void invoke("set_operation_nomenclature", { id: row.id, kind, value: picked })
          .then(() => reload())
          .catch((error) => say(tError("ui-save-failed", error), true));
      },
    },
  };
}

/// Une sous-opération n'a pas de mode de paiement à elle : elle porte celui de
/// sa mère, et un mode choisi sur une fille serait effacé au recalcul suivant.
function isATopLevelOperation(row: DetailRow): boolean {
  return row.parent_id === 0;
}

/// Les quatre vérifications, dans les mots de l'interface. Une liste fermée,
/// lue à l'ouverture et relue à chaque changement de langue.
let verifications: Item[] = [];

/// **La colonne « Vérification » du détail** (Fabrice, 04/10/2026 : « inclus
/// la colonne Vérification »). Elle avait été laissée de côté le jour où les
/// sept statistiques l'ont reçue — « décider à part pour le bilan croisé » ;
/// c'est décidé. La même, au même endroit : le mot dans sa couleur sur chaque
/// ligne, la liste déroulante sur la ligne choisie, et choisir écrit tout de
/// suite. Une sous-opération porte la vérification de sa mère : pas de liste
/// sur une fille.
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
      editable: isATopLevelOperation,
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

/// Ce que le détail ajoute à son menu du clic droit : l'entrée
/// « Vérification », la même que dans les statistiques et dans la liste du
/// compte. Elle change toute la sélection d'un coup ; sans ligne prise, elle
/// est grisée ; aucune phrase ne l'annonce.
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
  // **L'ascenseur horizontal du détail** (Fabrice, 03/10/2026), comme dans les
  // sept statistiques dont cette liste est la copie : dix colonnes qui se
  // comprimaient jusqu'à l'illisible débordent désormais, et l'en-tête suit.
  horizontalScroll: true,
  // Chacun ses colonnes, ici aussi, sous une disposition propre à cette
  // fenêtre (Fabrice, 04/10/2026). Le détail du bas seulement.
  layoutName: "crossed-balance",
  columns: [
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
      // La colonne qu'on lit : elle a droit à la place des autres.
      minWidth: 180,
    },
    // La référence paiement (Fabrice, 20/10/2026), juste après le libellé,
    // comme dans la liste du compte : on la voit, on la trie, on la filtre ;
    // elle se modifie dans la fiche. Coupée à l'écran, entière au survol. Une
    // ventilation montre celle de sa mère.
    {
      id: "reference",
      title: () => t("operations-column-reference"),
      cell: (row) => row.reference,
      render: (row, cell) => {
        cell.textContent = row.reference;
        cell.title = row.reference;
      },
      width: "1.2fr",
      minWidth: 100,
    },
    // Entre le libellé et la catégorie, comme dans les statistiques.
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
      id: "amount",
      title: () => t("statistics-column-amount"),
      cell: (row) => (row.amount < 0 ? row.debit : row.credit),
      // Le rouge d'un débit tient à cette cellule, où que soit sa colonne.
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

/// La phrase d'un interrupteur est écrite par le noyau, en entier : elle porte
/// un trou pour le mot ON/OFF, et seule Fluent sait où il est.
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
      void refreshSwitchLabels();
      void reload();
    });
    bar.append(button);
  }
}

// --- Le tableau ----------------------------------------------------------

/// La largeur des colonnes, et le plancher sous lequel le tableau déborde
/// plutôt que de rétrécir.
///
/// **L'ascenseur horizontal, demandé par Fabrice le 25/08/2026** : « je pense
/// qu'il faut quand même mettre l'ascenseur horizontal ». Les affectations
/// sont rarement nombreuses — parents, enfants, animaux —, mais le jour où
/// quelqu'un en aura quinze, le tableau tiendra au lieu d'écraser ses
/// colonnes. C'est le réglage de la liste des opérations : une largeur
/// plancher, et ce qui dépasse se rattrape à l'ascenseur.
const LABEL_WIDTH = 232;
const LABEL_FLOOR = 150;
const CELL_FLOOR = 96;
const TOTAL_FLOOR = 104;

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
  // Somme nulle mais des opérations derrière : le vert de l'auteur.
  return "matrix__cell matrix__cell--cancelling";
}

function isChosen(cell: Cell): boolean {
  return (
    chosen !== null &&
    chosen.category === cell.category &&
    chosen.assignment === cell.assignment
  );
}

/// Pose une case. **Une case vide se clique comme les autres** : voir qu'il n'y
/// a rien derrière est une réponse, et le détail le dit en toutes lettres.
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
  // Les lignes de synthèse ne sont pas peintes : c'est le chiffre qui prend la
  // couleur, comme dans l'original.
  const base = summary
    ? `matrix__cell ${value < 0 ? "matrix__cell--down" : "matrix__cell--up"}`
    : cellClass(value, filled);
  cell.className = `${base}${extra ? ` ${extra}` : ""}`;
  cell.textContent = text;
  if (isChosen(where)) {
    cell.classList.add("matrix__cell--chosen");
  }
  cell.tabIndex = 0;
  cell.addEventListener("click", () => {
    chosen = where;
    draw();
    void showDetail();
  });
  row.append(cell);
}

let matrix: Matrix | null = null;

/// Une ligne du tableau : autant de colonnes que d'affectations, et la largeur
/// plancher posée dessus. Les six statistiques ont douze colonnes fixes et
/// peuvent l'écrire dans la feuille de style ; ici le nombre change avec la
/// base, donc la ligne le porte elle-même.
function newRow(columns: number, extra = ""): HTMLElement {
  const line = document.createElement("div");
  line.className = `matrix__row${extra ? ` ${extra}` : ""}`;
  line.style.gridTemplateColumns =
    `minmax(${LABEL_FLOOR}px, ${LABEL_WIDTH}px) ` +
    `repeat(${columns}, minmax(${CELL_FLOOR}px, 1fr)) ` +
    `minmax(${TOTAL_FLOOR}px, 1.2fr)`;
  line.style.minWidth = `${LABEL_FLOOR + columns * CELL_FLOOR + TOTAL_FLOOR}px`;
  return line;
}

/// **Rien de ce qui ne change que les chiffres ne doit faire perdre la
/// position** (règle de Fabrice, 26/07/2026, et elle vaut ici plus qu'ailleurs
/// puisqu'on navigue de mois en mois). Redessiner remplace tout le contenu, ce
/// qui remettrait le défilement à zéro : il est relevé avant et reposé après.
function draw(): void {
  if (matrix === null) {
    return;
  }
  const zone = element<HTMLElement>("matrix-zone");
  const wasAt = { top: zone.scrollTop, left: zone.scrollLeft };
  const built = document.createDocumentFragment();
  const width = matrix.columns.length;

  // L'en-tête : la colonne des catégories, les affectations, le total.
  const head = newRow(width, "matrix__row--head");
  for (const title of [
    t("crossed-balance-column"),
    ...matrix.columns.map((column) => column.label),
    t("statistics-total"),
  ]) {
    const cell = document.createElement("span");
    cell.className = "matrix__title";
    cell.textContent = title;
    head.append(cell);
  }
  built.append(head);

  // Une ligne par catégorie, **même vide** : le tableau est un plan de comptes,
  // pas un résumé de ce qui s'est passé ce mois-ci.
  for (const row of matrix.rows) {
    const line = newRow(width);
    const label = document.createElement("span");
    label.className = "matrix__label";
    label.textContent = row.label;
    line.append(label);

    matrix.columns.forEach((column, index) => {
      putCell(line, row.cells[index], row.cell_values[index], row.filled[index], {
        category: row.id,
        assignment: column.id,
      });
    });
    putCell(
      line,
      row.total,
      row.total_value,
      row.total_filled,
      { category: row.id, assignment: null },
      "matrix__cell--total",
    );
    built.append(line);
  }

  // La ligne Somme, et elle seule : pas de Cumul ici.
  if (matrix.has_data) {
    const line = newRow(width, "matrix__row--sum");
    const label = document.createElement("span");
    label.className = "matrix__label";
    label.textContent = t("statistics-sum");
    line.append(label);

    matrix.columns.forEach((column, index) => {
      putCell(
        line,
        matrix?.sum[index] ?? "",
        matrix?.sum_values[index] ?? 0,
        matrix?.sum_filled[index] ?? false,
        { category: null, assignment: column.id },
        "",
        true,
      );
    });
    putCell(
      line,
      matrix.sum_total,
      matrix.sum_total_value,
      true,
      { category: null, assignment: null },
      "matrix__cell--total",
      true,
    );
    built.append(line);
  }

  matrixGrid.replaceChildren(built);
  zone.scrollTop = wasAt.top;
  zone.scrollLeft = wasAt.left;
}

// --- L'export ------------------------------------------------------------

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

/// Ce que la fenêtre montre en ce moment, dit en une ligne : le mois, les
/// comptes, et l'état des cinq interrupteurs. Un tableau nu retrouvé dans six
/// mois ne dit plus sur quoi il portait.
function contextOfWhatIsShown(): string {
  return contextOf(matrix?.period ?? periodText(), matrix?.accounts ?? "");
}

function contextOf(period: string, accounts: string): string {
  const lit = SWITCHES.filter(([name]) => switches[name]).length;
  return `${period} — ${accounts} — ${lit}/5`;
}

/// La feuille du tableau : **exactement ce qui est affiché**, cases vides
/// comprises, ligne de synthèse comprise, avec les couleurs de l'écran.
///
/// Écrite pour un tableau quelconque et non pour celui de l'écran : la fenêtre
/// l'appelle avec le sien, et l'export de l'année l'appelle douze fois, avec
/// celui de chaque mois. Une seule façon de dessiner un onglet, donc aucune
/// façon qu'un onglet diffère d'un autre.
async function sheetOf(shown: Matrix, name: string, detailLine: string): Promise<Sheet> {
  const heading: SheetCell[] = [
    textCell(t("crossed-balance-column"), true),
    ...shown.columns.map((column) => textCell(column.label, true)),
    textCell(t("statistics-total"), true),
  ];

  const lines: SheetCell[][] = shown.rows.map((row) => [
    textCell(row.label),
    ...row.cell_values.map((value, index) =>
      row.filled[index] ? moneyCell(value, fillOf(value, true)) : emptyCell(),
    ),
    row.total_filled ? moneyCell(row.total_value, fillOf(row.total_value, true)) : emptyCell(),
  ]);

  if (shown.has_data) {
    lines.push([
      textCell(t("statistics-sum"), true),
      ...shown.sum_values.map((value, index) =>
        shown.sum_filled[index] ? moneyCell(value, null, true) : emptyCell(),
      ),
      moneyCell(shown.sum_total_value, null, true),
    ]);
  }

  return {
    name,
    context: await contextLine(t("crossed-balance-window-name"), detailLine),
    header_rows: 1,
    rows: [heading, ...lines],
    widths: [34, ...shown.columns.map(() => 15), 15],
  };
}

async function matrixSheet(): Promise<Sheet> {
  const name = t("crossed-balance-window-name");
  if (matrix === null) {
    return { name, context: "", header_rows: 0, rows: [], widths: [] };
  }
  return await sheetOf(matrix, name, contextOfWhatIsShown());
}

/// **Tous les mois de l'année affichée, un onglet par mois** (Fabrice,
/// 25/08/2026).
///
/// Les six statistiques exportent toutes les années non vides, un onglet par
/// an. Ici la période est le mois : c'est donc l'année affichée qui se déplie,
/// de janvier à décembre. Les douze y sont, même vides — un classeur dont il
/// manquerait des mois se lirait de travers, et l'onglet vide dit lui-même
/// qu'il ne s'est rien passé.
///
/// **Rien n'est recalculé autrement qu'à l'écran** : chaque onglet est
/// littéralement ce qu'on verrait en allant sur ce mois-là.
async function exportEveryMonth(extension: "xlsx" | "ods"): Promise<void> {
  try {
    const chosenFile = await save({
      defaultPath: `${t("crossed-balance-window-name")}.${extension}`,
      filters: [{ name: extension.toUpperCase(), extensions: [extension] }],
    });
    if (chosenFile === null) {
      return;
    }

    const book: Sheet[] = [];
    for (let each = 1; each <= 12; each += 1) {
      const monthly = await invoke<Matrix>("crossed_balance", {
        accountIds,
        year,
        month: each,
        switches,
      });
      book.push(
        await sheetOf(
          monthly,
          `MOIS_${String(each).padStart(2, "0")}`,
          contextOf(monthly.period, monthly.accounts),
        ),
      );
    }
    say(await invoke<string>("export_book", { sheets: book, path: chosenFile }));
  } catch (error) {
    say(String(error), true);
  }
}

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
    ["export-all-months-excel", "xlsx"],
    ["export-all-months-ods", "ods"],
  ] as const) {
    const choice = document.createElement("button");
    choice.type = "button";
    choice.className = "window-menu__choice window-menu__choice--plain";
    choice.dataset.key = key;
    choice.textContent = t(key);
    choice.addEventListener("click", () => {
      choices.hidden = true;
      void exportEveryMonth(extension);
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
    const rows = await invoke<DetailRow[]>("crossed_balance_detail", {
      accountIds,
      year,
      month,
      switches,
      cell: chosen,
    });
    detail.setRows(rows);
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// « 09/2026 », tel que le bandeau l'affiche avant que le noyau ne l'ait
/// écrit — à l'ouverture, et quand aucun compte n'est choisi.
function periodText(): string {
  return `${String(month).padStart(2, "0")}/${year}`;
}

function showPeriod(): void {
  element<HTMLElement>("month").textContent = String(month).padStart(2, "0");
  element<HTMLElement>("year").textContent = String(year);
}

async function reload(): Promise<void> {
  showPeriod();
  if (accountIds.length === 0) {
    say(t("statistics-no-account"), true);
    matrix = null;
    matrixGrid.replaceChildren();
    detail.setRows([]);
    return;
  }
  try {
    matrix = await invoke<Matrix>("crossed_balance", { accountIds, year, month, switches });
    accountsLine.textContent = matrix.accounts;
    say(matrix.has_data ? "" : t("crossed-balance-no-data"));
    draw();
    await showDetail();
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

const PARAMETERS_EVENT = "window-parameters:crossed-balance";

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
  const askedYear = Number(parameters.get("year"));
  if (Number.isFinite(askedYear) && askedYear > 0) {
    year = askedYear;
  }
  const askedMonth = Number(parameters.get("month"));
  if (Number.isFinite(askedMonth) && askedMonth >= 1 && askedMonth <= 12) {
    month = askedMonth;
  }
  history.replaceState(
    null,
    "",
    `?accounts=${accountIds.join(",")}&year=${year}&month=${month}`,
  );
}

/// **« Copier la cellule » dans la matrice** (Fabrice, 07/10/2026) : la case
/// sous le pointeur — un total, un libellé de ligne —, le montant en nombre
/// pur. Pas de copie de lignes ici : on n'y choisit qu'une case.
function copyMatrixCell(event: MouseEvent): MenuHeadEntry[] {
  const under = (event.target as Element).closest<HTMLElement>(".matrix__row > *");
  const text =
    under === null
      ? ""
      : under.classList.contains("matrix__label")
        ? oneCell(under.textContent ?? "")
        : pureNumber(oneCell(under.textContent ?? ""));
  return [
    {
      name: "copy-cell",
      label: t("copy-cell"),
      enabled: text !== "",
      run: () => {
        void copyText(text).then((done) => {
          if (!done) {
            say(t("copy-failed"), true);
          }
        });
      },
    },
  ];
}

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

/// **Un mois en avant ou en arrière**, l'année suivie : décembre bascule sur
/// janvier de l'année d'après, janvier sur décembre de l'année d'avant. La
/// règle est au noyau, comme celle des bornes, pour que les deux horloges et
/// les deux saisies lui obéissent également.
async function step(forward: boolean): Promise<void> {
  try {
    const [keptYear, keptMonth] = await invoke<[number, number]>("crossed_balance_step", {
      year,
      month,
      forward,
    });
    if (keptYear === year && keptMonth === month) {
      // Déjà au bout des bornes de Radinus : rien n'a changé.
      return;
    }
    year = keptYear;
    month = keptMonth;
    // **La case choisie est gardée** : les lignes et les colonnes ne bougent
    // pas d'un mois à l'autre — Alimentation reste Alimentation et Famille
    // reste Famille —, seuls les montants changent. C'est ce qui permet de
    // cliquer une case, de reculer d'un mois, et de lire le montant du mois
    // dernier au même endroit de l'écran.
    await reload();
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// Le mois se clique : on y saisit un nombre entre 1 et 12. Le contrôleur
/// refuse ce qui n'en est pas un — un mois hors bornes montrerait un autre
/// mois sous un titre qui en annonce un.
async function askForMonth(): Promise<void> {
  try {
    const prompt = await invoke<{ question: string; first: number; last: number }>(
      "crossed_balance_month_prompt",
    );
    const asked = await askForWholeNumber(prompt.question, month, 2, t("ui-yes"), t("ui-no"));
    if (asked === null || asked === month) {
      return;
    }
    if (asked < prompt.first || asked > prompt.last) {
      say(prompt.question, true);
      return;
    }
    month = asked;
    await reload();
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// L'année se clique, exactement comme dans les six statistiques : le noyau
/// ramène la valeur entre 1950 et 2550 — **il impose, il ne rejette pas**.
async function askForYear(): Promise<void> {
  try {
    const prompt = await invoke<{ question: string; first: number; last: number }>(
      "statistics_year_prompt",
    );
    const asked = await askForWholeNumber(prompt.question, year, 4, t("ui-yes"), t("ui-no"));
    if (asked === null) {
      return;
    }
    const kept = await invoke<number>("statistics_year", { year: asked });
    if (kept === year) {
      return;
    }
    year = kept;
    await reload();
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

element<HTMLButtonElement>("month").addEventListener("click", () => void askForMonth());
element<HTMLButtonElement>("year").addEventListener("click", () => void askForYear());
element<HTMLButtonElement>("next-period").addEventListener("click", () => void step(true));
element<HTMLButtonElement>("previous-period").addEventListener("click", () => void step(false));
element<HTMLButtonElement>("close").addEventListener("click", () => {
  void invoke("close_crossed_balance");
});

function comeBackToWhereWeWere(): void {
  void reload();
}

/// **Tous les mots de la fenêtre, posés en un seul endroit.** Une fenêtre de
/// Radinus est bâtie une fois et jamais détruite : changer de langue ne la
/// reconstruit pas, il faut qu'elle sache se rhabiller.
async function dress(alsoTheNumbers = true): Promise<void> {
  // Les mots des quatre vérifications, dans la langue en cours. Sans base
  // ouverte il n'y a rien à lire, et la fenêtre le dira plus bas.
  verifications =
    (await invoke<Item[] | null>("list_operation_verifications").catch(() => null)) ?? [];
  detail.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));
  buildMenu();
  buildSwitches();
  await refreshSwitchLabels();
  for (const [id, key] of [
    ["month", "crossed-balance-month-choose"],
    ["year", "statistics-year-choose"],
    ["next-period", "crossed-balance-next"],
    ["previous-period", "crossed-balance-previous"],
    ["close", "ui-title-close"],
  ] as const) {
    element<HTMLElement>(id).title = t(key);
  }
  if (alsoTheNumbers) {
    await reload();
  }
}

window.addEventListener("focus", () => comeBackToWhereWeWere());
document.addEventListener("visibilitychange", () => {
  if (document.visibilityState === "visible") {
    comeBackToWhereWeWere();
  }
});

void (async () => {
  await loadTexts(null);
  await dress(false);
  onRightClick(
    element<HTMLElement>("matrix-zone"),
    () => matrixSheet(),
    say,
    undefined,
    undefined,
    copyMatrixCell,
  );
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
  onLanguageChanged(dress, { key: "window-crossed-balance-title" });
})();

/// **Une nomenclature a changé pendant que cette fenêtre vivait.** Les listes
/// des menus déroulants sont relues ; le tableau, lui, se refait au retour sur
/// la fenêtre, et une affectation ajoutée y prendra sa colonne.
void listen("nomenclatures-changed", async () => {
  combos = await invoke<Combos>("list_operation_combos");
});
