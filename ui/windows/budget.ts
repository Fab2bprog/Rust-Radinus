// F26 « Saisie du budget » et F27 « Contrôle du budget ».
//
// **Deux portes, deux questions** (règles dictées par Fabrice, 29/07/2026) :
// on saisit son budget, ou on contrôle s'il a été tenu. Une page pour les
// deux, parce que c'est le même tableau — les postes budgétaires en lignes,
// les douze mois en colonnes, l'année naviguée comme dans les statistiques.
//
// **En saisie** : les cases se tapent, les dépenses en négatif et les revenus
// sans signe. Rien n'est écrit tant qu'on n'a pas enregistré.
//
// **En contrôle** : les cases se lisent, et se colorent. Vert quand on fait au
// moins aussi bien que prévu, rouge quand on fait moins bien — c'est le sens du
// poste qui retourne la comparaison, et c'est le noyau qui tranche, jamais
// cette fenêtre. Le menu Affichage bascule entre la valeur et le pourcentage,
// et **la couleur ne change pas d'un mode à l'autre** : à 80 % une dépense est
// tenue et un revenu manque, seul le nombre affiché diffère.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askForWholeNumber, askYesNo } from "./dialog";
import { asMoneyField, SIGN_CHANGED } from "./money-field";
import { closeCurrentWindow } from "./window-frame";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

interface BudgetRow {
  id: number;
  label: string;
  months: number[];
  month_texts: string[];
  total: number;
  total_text: string;
}

interface Grid {
  rows: BudgetRow[];
  sum_texts: string[];
  sum_total_text: string;
  cumulative_texts: string[];
  sum: number[];
  sum_total: number;
  cumulative: number[];
}

interface ControlCell {
  planned: number;
  actual: number;
  money: string;
  percent: string;
  standing: "good" | "bad" | "none";
  detail: string;
}

interface ControlRow {
  id: number;
  label: string;
  months: ControlCell[];
  total: ControlCell;
}

interface Control {
  rows: ControlRow[];
  sum: ControlCell[];
  sum_total: ControlCell;
  cumulative: ControlCell[];
}

const MONTHS = [
  "month-january",
  "month-february",
  "month-march",
  "month-april",
  "month-may",
  "month-june",
  "month-july",
  "month-august",
  "month-september",
  "month-october",
  "month-november",
  "month-december",
] as const;

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");
const matrixGrid = element<HTMLElement>("matrix");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

/// Contrôle ou saisie — lu dans l'adresse, et **jamais reperdu** : l'événement
/// de réouverture ne reporte pas le mode de l'adresse de départ, et c'est la
/// faute qui a coûté la liste des modèles le 29/07/2026.
let controlling = false;
let year = new Date().getFullYear();
/// Ce que l'utilisateur a tapé et pas encore enregistré : poste, mois, texte.
/// **Rien ne part sur le disque avant l'enregistrement.**
const pending = new Map<string, { line: number; month: number; written: string }>();

function isModified(): boolean {
  return pending.size > 0;
}

/// La largeur des colonnes : le libellé, douze mois, le total.
function tracks(): string {
  return `minmax(180px, 1.4fr) repeat(12, minmax(78px, 1fr)) minmax(96px, 1fr)`;
}

function headerRow(): HTMLElement {
  const head = document.createElement("div");
  head.className = "matrix__row matrix__row--head";
  head.style.gridTemplateColumns = tracks();
  for (const title of [t("budget-column-line"), ...MONTHS.map((key) => t(key)), t("budget-total")]) {
    const cell = document.createElement("span");
    cell.className = "matrix__title";
    cell.textContent = title;
    head.append(cell);
  }
  return head;
}

// --- La saisie -----------------------------------------------------------

/// Les cases de synthèse — le total de chaque poste, les douze Somme, les douze
/// Cumul et le total général — retenues pour être **rafraîchies sans
/// redessiner le tableau** : redessiner ferait perdre le curseur de la case
/// qu'on vient de quitter.
let rowTotals = new Map<number, HTMLElement>();
let sumCells: HTMLElement[] = [];
let cumulativeCells: HTMLElement[] = [];
let sumTotalCell: HTMLElement | null = null;

/// Ce qui est tapé, sous la forme que le noyau attend.
function pendingCells(): [number, number, string][] {
  return [...pending.values()].map((cell) => [cell.line, cell.month, cell.written]);
}

/// Redemande les totaux au noyau, la saisie en cours comprise, et repeint les
/// seules cases de synthèse. Appelé quand on quitte une case.
async function refreshTotals(): Promise<void> {
  try {
    const grid = await invoke<Grid>("budget_grid", { year, cells: pendingCells() });
    for (const row of grid.rows) {
      const cell = rowTotals.get(row.id);
      if (cell) {
        cell.textContent = row.total_text;
      }
    }
    for (let month = 0; month < 12; month += 1) {
      if (sumCells[month]) {
        sumCells[month].textContent = grid.sum_texts[month];
        paintSign(sumCells[month], grid.sum[month]);
      }
      if (cumulativeCells[month]) {
        cumulativeCells[month].textContent = grid.cumulative_texts[month];
        paintSign(cumulativeCells[month], grid.cumulative[month]);
      }
    }
    if (sumTotalCell) {
      sumTotalCell.textContent = grid.sum_total_text;
      paintSign(sumTotalCell, grid.sum_total);
    }
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// Positif vert, négatif rouge — pour les deux lignes de synthèse de la saisie,
/// exactement comme dans le contrôle.
function paintSign(cell: HTMLElement, value: number): void {
  cell.classList.remove("matrix__cell--kept", "matrix__cell--overrun");
  if (value > 0) {
    cell.classList.add("matrix__cell--kept");
  } else if (value < 0) {
    cell.classList.add("matrix__cell--overrun");
  }
}

function drawEntry(grid: Grid): void {
  rowTotals = new Map();
  sumCells = [];
  cumulativeCells = [];
  sumTotalCell = null;
  const built = document.createDocumentFragment();
  built.append(headerRow());

  for (const row of grid.rows) {
    const line = document.createElement("div");
    line.className = "matrix__row";
    line.style.gridTemplateColumns = tracks();
    const label = document.createElement("span");
    label.className = "matrix__label";
    label.textContent = row.label;
    line.append(label);

    for (let month = 0; month < 12; month += 1) {
      const cell = document.createElement("span");
      cell.className = "matrix__cell";
      const field = document.createElement("input");
      field.type = "text";
      field.className = "matrix__input";
      const key = `${row.id}:${month + 1}`;
      field.value = pending.get(key)?.written ?? row.month_texts[month];
      // **Une case de budget est une case d'argent**, comme partout ailleurs
      // dans Radinus : le champ partagé refuse au clavier ce qui ne peut pas
      // être un montant — une lettre n'apparaît pas, un second séparateur non
      // plus — et il écrit proprement ce qui a été tapé quand on le quitte.
      // C'est aussi lui qui porte les deux touches de signe : « - » retourne
      // le montant, « + » le rend positif.
      asMoneyField(field);
      // **Le rappel du signe ne s'efface jamais.** Écrire un message d'aide à
      // chaque frappe le chasserait de la barre, et c'est justement pendant
      // qu'on tape qu'il sert (Fabrice, 29/07/2026 : « sinon personne ne va le
      // deviner »).
      field.addEventListener("input", () => {
        pending.set(key, { line: row.id, month: month + 1, written: field.value });
      });
      // Le champ d'argent réécrit la case en la quittant : ce qui part à
      // l'enregistrement doit être cette écriture-là, pas la frappe brute.
      // **Les deux touches de signe ne sont pas une frappe.** Le champ d'argent
      // les traite comme des commandes sur le nombre entier et réécrit la case
      // lui-même : aucun `input`, aucun `change` n'est émis, et les lignes de
      // synthèse restaient sur l'ancien signe (Fabrice, 29/07/2026). Il émet en
      // revanche son propre événement, et c'est celui-là qu'il faut entendre.
      for (const name of ["change", SIGN_CHANGED]) {
        field.addEventListener(name, () => {
          pending.set(key, { line: row.id, month: month + 1, written: field.value });
          // Les lignes de synthèse suivent la frappe : elles se recalculent
          // avec la saisie en cours par-dessus la base.
          void refreshTotals();
        });
      }
      cell.append(field);
      line.append(cell);
    }

    const total = document.createElement("span");
    total.className = "matrix__cell matrix__cell--total";
    total.textContent = row.total_text;
    rowTotals.set(row.id, total);
    line.append(total);
    built.append(line);
  }

  // **Les deux lignes de synthèse se colorent par leur signe** : positif vert,
  // négatif rouge — la même lecture que dans la fenêtre de contrôle (Fabrice,
  // 29/07/2026). Elles mélangent dépenses et revenus : leur signe est le solde,
  // et c'est la seule chose qu'elles aient à dire.
  for (const [key, texts, extra, last, values, lastValue] of [
    ["budget-sum", grid.sum_texts, "matrix__row--sum", grid.sum_total_text, grid.sum, grid.sum_total],
    ["budget-cumulative", grid.cumulative_texts, "matrix__row--cumulative", "", grid.cumulative, 0],
  ] as const) {
    const line = document.createElement("div");
    line.className = `matrix__row ${extra}`;
    line.style.gridTemplateColumns = tracks();
    const label = document.createElement("span");
    label.className = "matrix__label";
    label.textContent = t(key);
    line.append(label);
    const summing = key === "budget-sum";
    for (let month = 0; month < 12; month += 1) {
      const cell = document.createElement("span");
      cell.className = "matrix__cell";
      cell.textContent = texts[month];
      paintSign(cell, values[month]);
      (summing ? sumCells : cumulativeCells).push(cell);
      line.append(cell);
    }
    const total = document.createElement("span");
    total.className = "matrix__cell matrix__cell--total";
    total.textContent = last;
    paintSign(total, lastValue);
    if (summing) {
      sumTotalCell = total;
    }
    line.append(total);
    built.append(line);
  }

  matrixGrid.replaceChildren(built);
}

// --- Le contrôle ---------------------------------------------------------

/// Comment on lit le même écart : en devise, ou en pourcentage du prévu.
let showingPercent = false;

function paint(cell: HTMLElement, value: ControlCell): void {
  cell.textContent = showingPercent ? value.percent : value.money;
  cell.title = value.detail;
  // **La couleur vient du noyau et ne dépend pas du mode d'affichage.**
  if (value.standing === "good") {
    cell.classList.add("matrix__cell--kept");
  } else if (value.standing === "bad") {
    cell.classList.add("matrix__cell--overrun");
  }
}

/// **Les deux lignes de synthèse ne se lisent pas comme les postes.**
///
/// Sur un poste, la couleur compare le réalisé au prévu — c'est la règle du
/// vert « au moins aussi bien que prévu ». Sur la Somme et le Cumul, elle ne
/// veut rien dire : ces lignes mélangent les dépenses et les revenus, et leur
/// « prévu » est un solde, pas un objectif. Ce qui compte là, c'est le signe :
/// **positif vert, négatif rouge** (Fabrice, 29/07/2026).
function paintBySign(cell: HTMLElement, value: ControlCell): void {
  cell.textContent = showingPercent ? value.percent : value.money;
  cell.title = value.detail;
  if (value.actual > 0) {
    cell.classList.add("matrix__cell--kept");
  } else if (value.actual < 0) {
    cell.classList.add("matrix__cell--overrun");
  }
}

function drawControl(control: Control): void {
  const built = document.createDocumentFragment();
  built.append(headerRow());

  for (const row of control.rows) {
    const line = document.createElement("div");
    line.className = "matrix__row";
    line.style.gridTemplateColumns = tracks();
    const label = document.createElement("span");
    label.className = "matrix__label";
    label.textContent = row.label;
    line.append(label);
    for (const month of row.months) {
      const cell = document.createElement("span");
      cell.className = "matrix__cell";
      paint(cell, month);
      line.append(cell);
    }
    const total = document.createElement("span");
    total.className = "matrix__cell matrix__cell--total";
    paint(total, row.total);
    line.append(total);
    built.append(line);
  }

  // Les deux lignes de synthèse, comme dans la saisie et dans les
  // statistiques : la Somme répond pour le mois, le **Cumul** répond « depuis
  // janvier, où en suis-je » — et il est reporté jusqu'à décembre.
  for (const [key, cells, last, extra] of [
    ["budget-sum", control.sum, control.sum_total, "matrix__row--sum"],
    ["budget-cumulative", control.cumulative, null, "matrix__row--cumulative"],
  ] as const) {
    const line = document.createElement("div");
    line.className = `matrix__row ${extra}`;
    line.style.gridTemplateColumns = tracks();
    const label = document.createElement("span");
    label.className = "matrix__label";
    label.textContent = t(key);
    line.append(label);
    for (const month of cells) {
      const cell = document.createElement("span");
      cell.className = "matrix__cell";
      paintBySign(cell, month);
      line.append(cell);
    }
    const total = document.createElement("span");
    total.className = "matrix__cell matrix__cell--total";
    if (last) {
      paintBySign(total, last);
    }
    line.append(total);
    built.append(line);
  }

  matrixGrid.replaceChildren(built);
}

// --- Le va-et-vient ------------------------------------------------------

async function reload(): Promise<void> {
  try {
    element<HTMLElement>("year").textContent = String(year);
    if (controlling) {
      drawControl(
        await invoke<Control>("budget_control", {
          year,
          switches: {
            pointed: true,
            committed: true,
            planned: true,
            debits: true,
            credits: true,
          },
        }),
      );
      say(t("budget-control-help"));
      return;
    }
    drawEntry(await invoke<Grid>("budget_grid", { year, cells: pendingCells() }));
    // Le rappel de la convention de signe, en rouge : c'est lui qui évite un
    // budget saisi à l'envers, qui ne se verrait qu'au contrôle.
    say(t("budget-sign-warning"), true);
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

async function save(): Promise<void> {
  if (!isModified()) {
    say(t("budget-nothing-changed"));
    return;
  }
  try {
    await invoke("budget_save", {
      year,
      cells: [...pending.values()].map((cell) => [cell.line, cell.month, cell.written]),
    });
    pending.clear();
    await reload();
    say(t("budget-saved"));
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

/// Changer d'année emporterait la saisie en cours : on demande avant.
async function goToYear(asked: number): Promise<void> {
  if (isModified() && !(await askYesNo(t("budget-discard-question"), t("ui-yes"), t("ui-no")))) {
    return;
  }
  pending.clear();
  try {
    year = await invoke<number>("statistics_year", { year: asked });
    await reload();
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// Le millésime se clique, et la boîte **pose une question** — je n'y avais mis
/// que l'année en cours, ce qui ne demandait rien à personne (Fabrice,
/// 29/07/2026). C'est la question des statistiques, la même : elle dit aussi
/// entre quelles bornes Radinus travaille.
async function askForYear(): Promise<void> {
  try {
    const prompt = await invoke<{ question: string; first: number; last: number }>(
      "statistics_year_prompt",
    );
    const asked = await askForWholeNumber(prompt.question, year, 4, t("ui-yes"), t("ui-no"));
    if (asked !== null) {
      await goToYear(asked);
    }
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

element<HTMLButtonElement>("year").addEventListener("click", () => void askForYear());
element<HTMLButtonElement>("next-year").addEventListener("click", () => void goToYear(year + 1));
element<HTMLButtonElement>("previous-year").addEventListener("click", () =>
  void goToYear(year - 1),
);
element<HTMLButtonElement>("save").addEventListener("click", () => void save());
element<HTMLButtonElement>("close").addEventListener("click", () => {
  void (async () => {
    if (isModified() && !(await askYesNo(t("budget-discard-question"), t("ui-yes"), t("ui-no")))) {
      return;
    }
    pending.clear();
    closeCurrentWindow();
  })();
});

function readParameters(query: string): void {
  const parameters = new URLSearchParams(query);
  controlling = controlling || parameters.get("mode") === "control";
  const asked = Number(parameters.get("year") ?? 0);
  if (asked > 0) {
    year = asked;
  }
}

/// **L'interrupteur du contrôle**, sur le modèle des statistiques : Valeurs
/// d'un côté, Pourcentages de l'autre. Fabrice l'a préféré aux deux entrées de
/// menu que j'avais mises — ce n'est pas deux commandes, c'est un état à deux
/// positions, et un interrupteur le dit mieux qu'un menu (29/07/2026).
///
/// Il n'existe qu'au contrôle : la saisie n'a rien à basculer.
function buildSwitch(): void {
  const bar = element<HTMLElement>("switches");
  bar.hidden = !controlling;
  if (!controlling) {
    return;
  }
  bar.replaceChildren();
  const button = document.createElement("button");
  button.type = "button";
  button.className = "switch";
  button.id = "display-switch";
  const knob = document.createElement("span");
  knob.className = "switch__knob";
  const label = document.createElement("span");
  label.className = "switch__label";
  button.append(knob, label);

  const show = (): void => {
    button.setAttribute("aria-pressed", String(showingPercent));
    label.textContent = t(showingPercent ? "budget-display-percent" : "budget-display-money");
  };
  button.addEventListener("click", () => {
    showingPercent = !showingPercent;
    show();
    void reload();
  });
  show();
  bar.append(button);
}

/// **Tous les mots de la fenêtre, posés en un seul endroit.**
///
/// Une fenêtre de Radinus est bâtie une fois et jamais détruite : changer de
/// langue ne la reconstruit pas, il faut qu'elle sache se rhabiller. Ce qui
/// pose un mot est donc ici et nulle part ailleurs — une étiquette ajoutée
/// demain suivra la langue sans que personne y pense. L'en-tête du tableau, les
/// douze mois, les lignes Somme et Cumul sont écrits par `headerRow` et les
/// deux dessins, que le rechargement rappelle.
///
/// **La saisie en cours n'est pas perdue.** `reload()` redemande la grille en
/// repassant au noyau ce qui est tapé — `pendingCells()` —, exactement comme
/// quand on quitte une case, et `drawEntry` repose dans chaque case ce que
/// `pending` porte. Changer de langue avec un budget à moitié saisi le laisse
/// donc où il est ; rien n'a jamais besoin d'aller sur le disque pour cela.
///
/// `alsoTheNumbers` dit d'où l'on vient. À l'ouverture, le tableau vient plus
/// bas, une fois passée la barrière de `startup_error` : le demander d'ici le
/// demanderait à une base peut-être fermée.
async function dress(alsoTheNumbers = true): Promise<void> {
  element<HTMLElement>("close").title = t("ui-title-close");
  element<HTMLElement>("save").title = t("ui-title-save");
  element<HTMLElement>("year").title = t("statistics-year-choose");
  element<HTMLElement>("next-year").title = t("statistics-year-next");
  element<HTMLElement>("previous-year").title = t("statistics-year-previous");
  buildSwitch();
  if (alsoTheNumbers) {
    await reload();
  }
}

for (const name of ["window-parameters:budget-entry", "window-parameters:budget-control"]) {
  void listen<string>(name, (event) => {
    readParameters(event.payload);
    void reload();
  });
}

void (async () => {
  await loadTexts(null);
  // L'adresse d'abord : c'est elle qui dit si l'on saisit ou si l'on contrôle,
  // et l'interrupteur d'affichage n'existe qu'au contrôle.
  readParameters(window.location.search);
  element<HTMLButtonElement>("save").hidden = controlling;
  await dress(false);

  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    return;
  }
  await reload();
  // Deux portes, deux titres — celui de la porte par laquelle on est entré.
  onLanguageChanged(dress, {
    key: controlling ? "window-budget-control-title" : "window-budget-entry-title",
  });
})();
