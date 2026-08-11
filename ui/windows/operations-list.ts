// F02 — « Liste opérations du compte : <compte> ».
//
// The middle of the application, and the only window whose table is a **tree**
// (Fabrice, 25/07/2026). An operation carrying sub-operations shows a « + »;
// unfolding it inserts its children under it, before the next top-level
// operation. Everything below follows from that:
//
//   * what is drawn is the tree flattened according to what is unfolded, so
//     the number of visible lines changes without the data changing;
//   * a child follows its mother — sorting and filtering apply to mothers,
//     and a child never rises on its own;
//   * a child carries no balance: the Solde column is the account's running
//     balance, and a ventilation does not move the account;
//   * everything starts folded, and folds again at every opening (author's
//     ruling, 25/07/2026).
//
// The table only builds the rows that are on screen: the author's own account
// holds 2 502 operations and the plan asks for 40 000.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askYesNo } from "./dialog";
import { askWhereToSave, exportSheet, FORMATS } from "./export";
import { buildPeriodMenu, currentMonth } from "./period";
import { askForPrinter } from "./printers";
import { Table } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

const PARAMETERS_EVENT = "window-parameters:operations";
const CHANGED_EVENT = "data-changed:operations";

interface Row {
  id: number;
  label: string;
  date: string;
  clearing_date: string;
  /// Les deux mêmes dates en ISO. **Le tableau trie là-dessus**, jamais sur ce
  /// qui est affiché : « 15/01/2026 » se range par quantième, et un tri par
  /// date qui commence par le jour n'est pas un tri par date.
  date_value: string;
  clearing_date_value: string;
  month: string;
  category: string;
  assignment: string;
  payment_mode: string;
  payee: string;
  project: string;
  debit: string;
  credit: string;
  balance: string;
  /// Le solde courant en micro-unités, pour le tri : sa colonne se rangeait sur
  /// « 1 549,81 € », donc dans l'ordre des caractères.
  balance_value: number;
  amount: number;
  has_comment: boolean;
  comment: string;
  has_attachment: boolean;
  check_number: string;
  category_id: number;
  assignment_id: number;
  payment_mode_id: number;
  payee_id: number;
  project_id: number;
  parent_id: number;
  child_count: number;
  is_complement: boolean;
}

interface Operations {
  account_label: string;
  rows: Row[];
  debit: string;
  credit: string;
  total: string;
  balance_bank: string;
  balance_real: string;
  balance_final: string;
}

interface Item {
  id: number;
  label: string;
}

/// The five lists the combos of the table are picked from. Fetched once, when
/// the window opens.
interface Combos {
  category: Item[];
  assignment: Item[];
  payment_mode: Item[];
  payee: Item[];
  project: Item[];
}

interface DeletionPlan {
  needs_confirmation: boolean;
  question: string;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");
const fromField = element<HTMLInputElement>("from");
const toField = element<HTMLInputElement>("to");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

let combos: Combos = {
  category: [],
  assignment: [],
  payment_mode: [],
  payee: [],
  project: [],
};

/// A nomenclature column: shown as text, and as a drop-down list on the
/// selected row. **A nomenclature is never typed** — the user picks one of
/// the elements that exist (author's ruling, 25/07/2026). Choosing writes
/// straight to the database and the row is reread, because a mother hands her
/// classification down to her Complément.
function nomenclatureColumn(
  title: string,
  kind: string,
  text: (row: Row) => string,
  options: () => Item[],
  value: (row: Row) => number,
  width: string,
  editable?: (row: Row) => boolean,
) {
  return {
    title: () => t(title),
    cell: text,
    width,
    editor: {
      options,
      value,
      editable,
      change: (row: Row, chosen: number) => {
        void invoke("set_operation_nomenclature", { id: row.id, kind, value: chosen })
          .then(() => reload())
          .catch((error) => say(tError("ui-save-failed", error), true));
      },
    },
  };
}

/// **A sub-operation has no payment mode of its own** (Fabrice, 26/07/2026:
/// « dans une sous-opération, comme est le complément, on ne peut pas toucher
/// au mode de paiement, cela serait illogique »). It holds its mother's, and
/// his own `Maj_ProprieteSousOp` pushes hers onto every one of her children
/// after each write — so a mode chosen on a child would be quietly wiped out
/// at the next recomputation. A list must not offer what it cannot keep: the
/// combo is simply not there on a child's line.
///
/// The four other nomenclatures are offered on a child, and must be: telling
/// one category from another is the entire point of a ventilation.
function isATopLevelOperation(row: Row): boolean {
  return row.parent_id === 0;
}

/// The Filtre menu: which kind of operation the table shows. `null` is « all
/// of them ». The three others are the statuses of the database — 1 pointed,
/// 2 committed, 3 planned (02_BASE_DE_DONNEES.md §5.2) — and the filter is
/// applied by the core, so the foot of the window always adds up exactly what
/// the table shows (author's request, 25/07/2026).
let status: number | null = null;

/// Which account this window is about. It arrives in the address and never
/// changes: another account is another window's business.
let accountId = 0;

/// Le titre de la fenêtre, tel qu'il sera reposé au prochain changement de
/// langue : « Liste opérations du compte : CCP ».
///
/// **Un objet, et non deux constantes**, parce que le nom du compte se relit à
/// chaque lecture des opérations : cette fenêtre change de compte sans se
/// rouvrir, et un titre reposé à partir du compte de son ouverture nommerait
/// celui qu'elle ne montre plus. C'est le noyau qui écrit la phrase — la
/// fenêtre ne rend que la clef et le nom.
const TITLE = { key: "window-operations-title", argument: null as string | null };

/// Everything read for the period, mothers and children together.
let everything: Row[] = [];

/// The mothers the user has unfolded. Nothing of this survives the window
/// being left: everything folds again at every opening.
const unfolded = new Set<number>();

/// Where each mother's children are, by her key. Built once per reading
/// rather than searched again at every fold.
let childrenOf = new Map<number, Row[]>();

/// The tree, flattened for the screen: every mother, and under her, her own
/// children when she is unfolded.
///
/// **Built mother by mother**, not by walking the list and keeping what fits.
/// Walking it assumes the children arrive right behind their mother, and when
/// they do not, they land several rows below her — which is exactly what
/// happened (reported by Fabrice, 25/07/2026). Here a child cannot go
/// anywhere but under the mother it belongs to.
function flattened(): Row[] {
  const shown: Row[] = [];
  for (const row of everything) {
    if (row.parent_id !== 0) {
      continue;
    }
    shown.push(row);
    if (unfolded.has(row.id)) {
      shown.push(...(childrenOf.get(row.id) ?? []));
    }
  }
  return shown;
}

/// Which line of its mother's ventilation a child is, so the table can
/// alternate their colours on their own count.
const childRank = new Map<number, number>();

/// The « + » of a mother, the indent of a child, and nothing for an operation
/// that carries none.
function foldingCell(row: Row, cell: HTMLElement): void {
  if (row.parent_id !== 0) {
    cell.classList.add("list__cell--child");
    return;
  }
  if (row.child_count === 0) {
    return;
  }
  const button = document.createElement("button");
  button.type = "button";
  button.className = "list__fold";
  button.textContent = unfolded.has(row.id) ? "−" : "+";
  button.addEventListener("click", (event) => {
    // The click unfolds; it does not also select the line under it.
    event.stopPropagation();
    if (unfolded.has(row.id)) {
      unfolded.delete(row.id);
    } else {
      unfolded.add(row.id);
    }
    table.setRows(flattened());
  });
  cell.append(button);
}

/// The tick of the Commentaires and Pièces Jointes columns. `hint`, when there
/// is one, is shown on hover — the comment itself, since a tick that says
/// « there is something to read » without letting one read it is only half a
/// column (04_SPECIFICATIONS_FENETRES.md, F02: « infobulle au survol avec le
/// texte »).
function tickCell(ticked: boolean, cell: HTMLElement, hint = ""): void {
  if (!ticked) {
    return;
  }
  const mark = document.createElement("span");
  mark.className = "list__tick";
  mark.textContent = "✓";
  cell.append(mark);
  if (hint !== "") {
    cell.title = hint;
  }
}

const table = new Table<Row>({
  container: element<HTMLDivElement>("rows"),
  virtualized: true,
  rowHeight: 24,
  columns: [
    { title: () => "", cell: () => "", render: foldingCell, width: "34px" },
    // **Les deux colonnes de date se trient sur l'ISO, pas sur ce qu'on lit**
    // (défaut relevé par Fabrice le 04/08/2026). Le tableau comparait
    // « 15/01/2026 » à « 03/02/2026 » caractère par caractère : il rangeait par
    // quantième, puis par mois, puis par année. En ISO, l'ordre des caractères
    // est l'ordre du temps, et la comparaison redevient juste sans que le
    // tableau ait à savoir ce qu'est une date.
    {
      title: () => t("operations-column-date"),
      cell: (row) => row.date,
      key: (row) => row.date_value,
      width: "92px",
    },
    {
      title: () => t("operations-column-clearing-date"),
      cell: (row) => row.clearing_date,
      key: (row) => row.clearing_date_value,
      width: "108px",
    },
    { title: () => t("operations-column-label"), cell: (row) => row.label, width: "2fr" },
    nomenclatureColumn(
      "operations-column-category",
      "category",
      (row) => row.category,
      () => combos.category,
      (row) => row.category_id,
      "1.1fr",
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
      "0.9fr",
    ),
    { title: () => t("operations-column-month"), cell: (row) => row.month, width: "0.8fr" },
    {
      title: () => t("operations-column-debit"),
      cell: (row) => row.debit,
      key: (row) => row.amount,
      // À l'écran une seule des deux colonnes est remplie ; à l'export aussi.
      money: (row) => (row.debit === "" ? null : row.amount),
      numeric: true,
      width: "1fr",
    },
    {
      title: () => t("operations-column-credit"),
      cell: (row) => row.credit,
      key: (row) => row.amount,
      money: (row) => (row.credit === "" ? null : row.amount),
      numeric: true,
      width: "1fr",
    },
    // Le même défaut, une colonne plus loin : le solde se rangeait sur son
    // texte, donc « 9,00 € » passait après « 1 549,81 € ».
    {
      title: () => t("operations-column-balance"),
      cell: (row) => row.balance,
      key: (row) => row.balance_value,
      numeric: true,
      width: "1fr",
    },
    {
      title: () => t("operations-column-comments"),
      cell: () => "",
      render: (row, cell) => tickCell(row.has_comment, cell, row.comment),
      width: "100px",
    },
    {
      title: () => t("operations-column-attachments"),
      cell: () => "",
      render: (row, cell) => tickCell(row.has_attachment, cell),
      width: "100px",
    },
    {
      title: () => t("operations-column-check"),
      cell: (row) => row.check_number,
      numeric: true,
      width: "1fr",
    },
  ],
  identity: (row) => row.id,
  rowClass: (row) => {
    if (row.parent_id === 0) {
      return null;
    }
    // A ventilation is set apart from the account's own operations by a
    // pastel blue, alternating on its own count so the break is plain to see
    // (author's request, 25/07/2026).
    const shade = (childRank.get(row.id) ?? 0) % 2 === 0 ? "even" : "odd";
    return `list__row--sub list__row--sub-${shade}${
      row.is_complement ? " list__row--complement" : ""
    }`;
  },
  // D'où vient le fichier exporté : le compte n'est pas dans la fenêtre, mais
  // la période l'est, et c'est elle qui fait qu'un export veut dire quelque
  // chose.
  exportAs: () => ({
    name: t("operations-column-label"),
    detail: `${t("operations-from")} ${fromField.value} — ${t("operations-to")} ${toField.value}`,
  }),
  emptyText: () => t("operations-none"),
  filteredOutText: () => t("ui-no-match"),
  onSelectionChange: () => showSelectionTotal(),
  // Double-clicking a line opens its fiche — the reflex of every list in the
  // original (04_SPECIFICATIONS_FENETRES.md, F02: « double-clic ligne =
  // ouvrir la fiche »).
  onActivate: (row: Row) => openRowsOwnForm(row),
});

/// The window's own status line: what the selection adds up to.
function showSelectionTotal(): void {
  const selected = new Set(table.selected());
  const rows = everything.filter((row) => selected.has(row.id));
  if (rows.length === 0) {
    say("");
    return;
  }
  const total = rows.reduce((sum, row) => sum + row.amount, 0);
  // The whole sentence comes from the core, amount included. Filling the hole
  // here would mean the window knowing where the hole is — and it showed the
  // raw key on screen the day the sentence was not in its dictionary.
  void invoke<string>("operations_selection_total", { amount: total }).then((sentence) =>
    say(sentence),
  );
}

function notYet(): void {
  say(t("operations-not-yet"), true);
}

function requireSelection(): boolean {
  if (table.selected().length === 0) {
    say(t("ui-select-record"), true);
    return false;
  }
  return true;
}

async function reload(): Promise<void> {
  try {
    const data = await invoke<Operations>("list_operations", {
      accountId,
      from: fromField.value,
      to: toField.value,
      status,
    });
    everything = data.rows;
    // Le compte que la fenêtre montre, pour son titre. Il vient avec les
    // lignes, et non de l'adresse : c'est le noyau qui le nomme.
    TITLE.argument = data.account_label;

    // The children, gathered under their mother's key, and numbered so that
    // their own alternation of colours starts again with each mother.
    childrenOf = new Map();
    childRank.clear();
    for (const row of everything) {
      if (row.parent_id === 0) {
        continue;
      }
      const family = childrenOf.get(row.parent_id) ?? [];
      childRank.set(row.id, family.length);
      family.push(row);
      childrenOf.set(row.parent_id, family);
    }
    // Nothing of a visit survives it: a mother that no longer exists must not
    // keep an unfolded state of her own.
    for (const id of [...unfolded]) {
      if (!everything.some((row) => row.id === id && row.child_count > 0)) {
        unfolded.delete(id);
      }
    }
    table.setRows(flattened());

    element<HTMLElement>("foot-debit").textContent = data.debit;
    element<HTMLElement>("foot-credit").textContent = data.credit;
    element<HTMLElement>("foot-total").textContent = data.total;
    element<HTMLElement>("foot-bank").textContent = data.balance_bank;
    element<HTMLElement>("foot-real").textContent = data.balance_real;
    element<HTMLElement>("foot-final").textContent = data.balance_final;
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

async function deleteSelection(): Promise<void> {
  if (!requireSelection()) {
    return;
  }
  try {
    const plan = await invoke<DeletionPlan>("plan_operations_deletion", {
      ids: table.selected(),
    });
    if (plan.needs_confirmation) {
      if (!(await askYesNo(plan.question, t("ui-yes"), t("ui-no")))) {
        say(t("ui-deletion-abandoned"));
        return;
      }
    }
    const gone = await invoke<number>("delete_operations", { ids: table.selected() });
    table.clearSelection();
    await reload();
    say(await invoke<string>("operations_deleted_text", { count: gone }));
  } catch (error) {
    say(tError("ui-delete-failed", error), true);
  }
}

/// **This window has three parameters and no more** (author's ruling,
/// 25/07/2026): one account — one account at a time, never two — a start date
/// and an end date. Everything else it shows is read from those three.
///
/// The Période menu below does one single thing: it works out a start and an
/// end, drops them into the two fields, and asks for a reread. It holds no
/// data of its own and knows nothing about operations.

/// Puts a period into the two fields and rereads. The only thing any entry of
/// the menu ever does.
async function showPeriod(period: { from: string; to: string }): Promise<void> {
  fromField.value = period.from;
  toField.value = period.to;
  await reload();
}

function readParameters(query: string): void {
  const parameters = new URLSearchParams(query);
  accountId = Number(parameters.get("account") ?? 0);
  history.replaceState(null, "", `?account=${accountId}`);
}

/// Opens the fiche opération (F03) on one record, or on none in add mode.
/// The key travels through Rust rather than through the window: the fiche
/// reads the record itself, by that key, and fills its reserve from what it
/// read — the list hands over a key and nothing else (author's rule,
/// 25/07/2026).
async function openForm(formMode: "A" | "M" | "D", id: number | null): Promise<void> {
  try {
    await invoke("open_operation_form", { mode: formMode, accountId, id });
  } catch (error) {
    say(tError("ui-open-failed", error), true);
  }
}

/// Opens the fiche sous-opération (F04), to add a ventilation to `parentId`
/// or to change one.
async function openSubForm(formMode: "A" | "M", parentId: number, id: number | null): Promise<void> {
  try {
    await invoke("open_sub_operation_form", { mode: formMode, parentId, id });
  } catch (error) {
    say(tError("ui-open-failed", error), true);
  }
}

/// The line a one-record action works on, or `null` when there is not exactly
/// one. **A fiche shows one record**: asking for two would mean choosing
/// silently, which is how one ends up editing the wrong operation.
function theOnlyChosenRow(): Row | null {
  const chosen = table.selected();
  if (chosen.length === 0) {
    say(t("ui-select-record"), true);
    return null;
  }
  if (chosen.length > 1) {
    say(t("operations-select-one"), true);
    return null;
  }
  return everything.find((row) => row.id === chosen[0]) ?? null;
}

/// Modifying opens the fiche the row belongs to: **F03 for an operation, F04
/// for a ventilation**. A sub-operation is not edited in the fiche of an
/// operation — it has neither mode, nor status, nor date of its own.
function modifySelection(): void {
  const row = theOnlyChosenRow();
  if (!row) {
    return;
  }
  void openRowsOwnForm(row);
}

function openRowsOwnForm(row: Row): void {
  if (row.parent_id === 0) {
    void openForm("M", row.id);
  } else {
    void openSubForm("M", row.parent_id, row.id);
  }
}

element<HTMLButtonElement>("create").addEventListener("click", () => void openForm("A", null));
element<HTMLButtonElement>("update").addEventListener("click", () => modifySelection());

/// `Base_createinside`: ventilate the chosen operation. A ventilation hangs
/// off a top-level operation, so choosing a child adds a sister to it rather
/// than a grandchild — there are two levels and no more.
element<HTMLButtonElement>("sub").addEventListener("click", () => {
  const row = theOnlyChosenRow();
  if (!row) {
    return;
  }
  void openSubForm("A", row.parent_id === 0 ? row.id : row.parent_id, null);
});

/// `Base_point`: the quick clearing, which needs no fiche. The clearing date
/// written is **the operation's own date** (Fabrice, 26/07/2026), and a child
/// is cleared through its mother — a status does not belong to a ventilation.
element<HTMLButtonElement>("point").addEventListener("click", () => {
  if (!requireSelection()) {
    return;
  }
  void invoke<string>("point_operations", { ids: table.selected() })
    .then(async (said) => {
      await reload();
      say(said);
    })
    .catch((error) => say(tError("ui-save-failed", error), true));
});

/// `Base_duplicate`: **a prefilled fiche, not a copy written behind one's
/// back** (Fabrice's choice, 26/07/2026). F03 opens in creation mode carrying
/// the values of the chosen operation; nothing exists until he saves, and he
/// can put the date or the amount right first — which is usually the whole
/// reason for duplicating.
///
/// A ventilation is not duplicated this way: it belongs to its mother, and
/// F04 is where one is added.
element<HTMLButtonElement>("duplicate").addEventListener("click", () => {
  const row = theOnlyChosenRow();
  if (!row) {
    return;
  }
  if (row.parent_id !== 0) {
    say(t("operation-is-a-sub"), true);
    return;
  }
  void openForm("D", row.id);
});
element<HTMLButtonElement>("delete").addEventListener("click", () => void deleteSelection());

/// Leaving the list takes its fiche with it, so it asks first whether the
/// fiche holds work nobody saved — the fiche is behind this window and the
/// user is clicking here (author's decision, 25/07/2026).
async function leave(): Promise<void> {
  try {
    if (await invoke<boolean>("operations_list_has_unsaved_changes")) {
      if (!(await askYesNo(t("ui-discard-question"), t("ui-yes"), t("ui-no")))) {
        return;
      }
    }
    await invoke("close_operations_list");
  } catch (error) {
    say(tError("ui-close-failed", error), true);
  }
}

element<HTMLButtonElement>("close").addEventListener("click", () => void leave());

for (const field of [fromField, toField]) {
  field.addEventListener("change", () => void reload());
}

void listen(CHANGED_EVENT, () => void reload());
void listen<string>(PARAMETERS_EVENT, (event) => {
  unfolded.clear();
  table.clearSelection();
  readParameters(event.payload);
  void reload();
});

/// Puts the tick in front of the chosen entry of a menu, and takes it off the
/// others. The name of the menu never changes: a menu says what it is, and
/// the tick says where one stands in it — which is how every menu of the
/// system behaves (author's remark, 25/07/2026).
function markChosen(choices: HTMLElement, key: string | null): void {
  for (const button of choices.querySelectorAll<HTMLElement>(".window-menu__choice")) {
    button.classList.toggle("window-menu__choice--chosen", button.dataset.key === key);
  }
}

/// Builds the Divers menu: showing or hiding every ventilation at once.
///
/// **Two actions, not a mode, and therefore no tick.** A tick says where one
/// stands; here one does not stand anywhere — unfolding everything and then
/// folding a single mother by hand would leave a tick claiming everything is
/// shown. That is exactly the stale flag we spent a day removing from the
/// fiches. These two entries do something and stop existing as a state: what
/// is unfolded is written in the table itself, one « + » at a time.
function miscMenu(entry: HTMLElement): HTMLElement {
  const holder = document.createElement("div");
  holder.className = "window-menu__holder";
  const choices = document.createElement("div");
  choices.className = "window-menu__choices";
  choices.dataset.menu = "misc";
  choices.hidden = true;

  for (const [key, showing] of [
    ["operations-show-children", true],
    ["operations-hide-children", false],
  ] as const) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "window-menu__choice window-menu__choice--plain";
    button.dataset.key = key;
    button.textContent = t(key);
    button.addEventListener("click", () => {
      choices.hidden = true;
      unfolded.clear();
      if (showing) {
        for (const row of everything) {
          if (row.parent_id === 0 && row.child_count > 0) {
            unfolded.add(row.id);
          }
        }
      }
      table.setRows(flattened());
    });
    choices.append(button);
  }

  entry.addEventListener("click", (event) => {
    event.stopPropagation();
    choices.hidden = !choices.hidden;
  });
  document.addEventListener("click", () => {
    choices.hidden = true;
  });

  holder.append(entry, choices);
  return holder;
}

/// Les douze sorties du menu Export de F02, dans l'ordre et les quatre groupes
/// de sa capture (30/07/2026).
///
/// **Les dix formats de tableau viennent de la liste partagée** — celle du clic
/// droit, qui sert à tous les tableaux du logiciel : un format ajouté là arrive
/// ici sans que personne y pense. Les deux formats bancaires s'insèrent entre
/// le groupe des tableurs en texte et celui des formats d'échange, exactement
/// où sa capture les montre.
function exportEntries(): { key: string; extension: string; apart?: boolean; bank?: boolean }[] {
  const entries: { key: string; extension: string; apart?: boolean; bank?: boolean }[] = [];
  for (const format of FORMATS) {
    // L'INI ouvre le dernier groupe : les deux formats bancaires viennent
    // juste avant, avec leur propre trait.
    if (format.extension === "ini") {
      entries.push({ key: "export-to-ofx", extension: "ofx", apart: true, bank: true });
      entries.push({ key: "export-to-qif", extension: "qif", bank: true });
    }
    entries.push({ ...format });
  }
  return entries;
}

/// Sort les opérations affichées en OFX ou en QIF.
///
/// **Les mères seules** (règle de Fabrice, 30/07/2026) : une opération
/// ventilée s'exporte pour son montant total, sans ses filles. Écrire les deux
/// ferait compter l'argent deux fois, et un logiciel relisant le fichier
/// verrait le double du solde réel — une faute qui ne se voit nulle part.
async function exportOperations(extension: string): Promise<void> {
  const ids = table
    .shownRows()
    .filter((row) => row.parent_id === 0)
    .map((row) => row.id);
  if (ids.length === 0) {
    say(t("export-nothing"));
    return;
  }
  const chosen = await askWhereToSave(t("operations-column-label"), extension);
  if (chosen === null) {
    return;
  }
  say(await invoke<string>("export_operations", { accountId, ids, path: chosen }));
}

/// Une sortie du menu Export, quelle qu'elle soit.
async function runExport(extension: string, bank: boolean): Promise<void> {
  try {
    if (bank) {
      await exportOperations(extension);
      return;
    }
    const answer = await exportSheet(await table.sheet(), extension);
    if (answer !== null) {
      say(answer);
    }
  } catch (error) {
    say(String(error), true);
  }
}

/// Imprime ce que la fenêtre montre.
///
/// **Toutes les lignes affichées, filles comprises** : l'état s'appelle
/// « Liste des transactions bancaires et sous-opérations », et une ventilation
/// dépliée à l'écran doit se retrouver sur le papier. Les totaux du bandeau,
/// eux, ne comptent que les mères — le noyau s'en charge, parce qu'additionner
/// une mère et ses filles compterait l'argent deux fois.
async function runPrint(toPrinter: boolean): Promise<void> {
  try {
    const ids = table.shownRows().map((row) => row.id);
    if (ids.length === 0) {
      say(t("print-nothing"));
      return;
    }
    let printer: string | null = null;
    if (toPrinter) {
      // La même question que la fiche de RIB, posée par le même code.
      const choice = await askForPrinter();
      if (choice.kind === "cancelled") {
        return;
      }
      if (choice.kind === "default") {
        say(await invoke<string>("print_operations", { ids, toPrinter, printer: null }));
        say(t("print-printers-unknown"));
        return;
      }
      printer = choice.printer;
    }
    say(await invoke<string>("print_operations", { ids, toPrinter, printer }));
  } catch (error) {
    say(String(error), true);
  }
}

/// Le menu Impression sous son entrée. Une seule sortie pour l'instant : les
/// autres états viennent avec les fenêtres qui les portent.
function printMenu(entry: HTMLElement): HTMLElement {
  const holder = document.createElement("div");
  holder.className = "window-menu__holder";
  const choices = document.createElement("div");
  choices.className = "window-menu__choices";
  choices.dataset.menu = "print";
  choices.hidden = true;

  // Deux sorties : le PDF, qui s'ouvre dans la visionneuse et sert d'aperçu,
  // et le papier, qui demande d'abord sur quelle imprimante.
  for (const [key, toPrinter] of [
    ["print-menu-operations-pdf", false],
    ["print-menu-operations-printer", true],
  ] as const) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "window-menu__choice window-menu__choice--plain";
    button.dataset.key = key;
    button.textContent = t(key);
    button.addEventListener("click", () => {
      choices.hidden = true;
      void runPrint(toPrinter);
    });
    choices.append(button);
  }

  entry.addEventListener("click", (event) => {
    event.stopPropagation();
    choices.hidden = !choices.hidden;
  });
  document.addEventListener("click", () => {
    choices.hidden = true;
  });

  holder.append(entry, choices);
  return holder;
}

/// Builds the Export menu under its entry: the twelve outputs, in four groups.
function exportMenu(entry: HTMLElement): HTMLElement {
  const holder = document.createElement("div");
  holder.className = "window-menu__holder";
  const choices = document.createElement("div");
  choices.className = "window-menu__choices";
  choices.dataset.menu = "export";
  choices.hidden = true;

  for (const format of exportEntries()) {
    if (format.apart === true) {
      const rule = document.createElement("hr");
      rule.className = "window-menu__rule";
      choices.append(rule);
    }
    const button = document.createElement("button");
    button.type = "button";
    button.className = "window-menu__choice window-menu__choice--plain";
    button.dataset.key = format.key;
    button.textContent = t(format.key);
    button.addEventListener("click", () => {
      choices.hidden = true;
      void runExport(format.extension, format.bank === true);
    });
    choices.append(button);
  }

  entry.addEventListener("click", (event) => {
    event.stopPropagation();
    choices.hidden = !choices.hidden;
  });
  document.addEventListener("click", () => {
    choices.hidden = true;
  });

  holder.append(entry, choices);
  return holder;
}

/// Le raccourci de sa capture — « Excel Ctrl+E », qui devient ⌘E sur macOS
/// comme tous les autres raccourcis du logiciel.
///
/// Il est posé sur la fenêtre et non sur le menu : un raccourci qui n'agirait
/// qu'une fois le menu ouvert ne servirait à rien.
document.addEventListener("keydown", (event) => {
  if (event.key.toLowerCase() === "e" && (event.metaKey || event.ctrlKey)) {
    event.preventDefault();
    void runExport("xlsx", false);
  }
});

/// Les quatre choix du menu Filtre, et le statut de chacun. Écrits une fois :
/// le menu s'en sert pour se construire, et pour savoir où poser son encoche
/// quand la fenêtre se rebâtit dans une autre langue.
const FILTERS = [
  ["filter-all", null],
  ["filter-pointed", 1],
  ["filter-committed", 2],
  ["filter-planned", 3],
] as const;

/// Builds the Filtre menu under its entry: four choices, one status each.
function filterMenu(entry: HTMLElement): HTMLElement {
  const holder = document.createElement("div");
  holder.className = "window-menu__holder";
  const choices = document.createElement("div");
  choices.className = "window-menu__choices";
  choices.dataset.menu = "filter";
  choices.hidden = true;

  for (const [key, chosen] of FILTERS) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "window-menu__choice window-menu__choice--plain";
    button.dataset.key = key;
    button.textContent = t(key);
    button.addEventListener("click", () => {
      choices.hidden = true;
      status = chosen;
      markChosen(choices, key);
      void reload();
    });
    choices.append(button);
  }

  entry.addEventListener("click", (event) => {
    event.stopPropagation();
    choices.hidden = !choices.hidden;
  });
  document.addEventListener("click", () => {
    choices.hidden = true;
  });

  // Nothing is filtered out to begin with — et, quand la fenêtre se rhabille,
  // l'encoche revient là où l'on en est. Une encoche sur « Toutes » au-dessus
  // d'un tableau qui ne montre que les opérations pointées serait un mensonge.
  markChosen(choices, FILTERS.find(([, chosen]) => chosen === status)?.[0] ?? "filter-all");
  holder.append(entry, choices);
  return holder;
}

/// L'encoche que porte un menu de la barre, relevée avant qu'on le rebâtisse
/// dans la nouvelle langue. `fallback` est l'encoche du premier passage, quand
/// il n'y a pas encore de menu ; une chaîne vide dit « aucune », ce qui est le
/// cas dès que les deux dates ont été saisies à la main.
function markedIn(name: string, fallback: string): string {
  const built = document.querySelector<HTMLElement>(`.window-menu__choices[data-menu="${name}"]`);
  if (built === null) {
    return fallback;
  }
  return built.querySelector<HTMLElement>(".window-menu__choice--chosen")?.dataset.key ?? "";
}

/// La fenêtre est-elle en état de relire ? Elle ne l'est qu'une fois la base
/// ouverte, les cinq listes lues et la période posée : rhabiller une fenêtre
/// qui n'en est pas là lui ferait demander les opérations d'un compte qu'elle
/// ne connaît pas encore, entre deux dates vides.
let ready = false;

/// Pose les mots de la fenêtre, à l'ouverture et à chaque changement de
/// langue — les étiquettes, les infobulles, et la barre de menus entière, qui
/// n'est faite que de mots.
///
/// Elle finit par relire les opérations : les montants, les totaux du bandeau
/// et les noms des nomenclatures sont écrits par le noyau, dans sa langue.
async function dress(): Promise<void> {
  table.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));
  table.exportOnRightClick(say);

  for (const [id, key] of [
    ["from-label", "operations-from"],
    ["to-label", "operations-to"],
    ["foot-debit-label", "operations-foot-debit"],
    ["foot-credit-label", "operations-foot-credit"],
    ["foot-total-label", "operations-foot-total"],
    ["foot-bank-label", "operations-foot-bank"],
    ["foot-real-label", "operations-foot-real"],
    ["foot-final-label", "operations-foot-final"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  for (const [id, key] of [
    ["create", "ui-title-create"],
    ["update", "ui-title-update"],
    ["delete", "ui-title-delete"],
    ["point", "operations-title-point"],
    ["sub", "operations-title-sub"],
    ["duplicate", "operations-title-duplicate"],
    ["close", "ui-title-close"],
  ] as const) {
    element<HTMLElement>(id).title = t(key);
  }

  // The window's own menu bar. Its five entries belong to phases that have
  // not started; they are shown, and they say so when clicked.
  //
  // Elle se rebâtit en entier à chaque langue : ses entrées ne sont que des
  // mots. Ce qu'elle dit d'elle-même, en revanche, ne change pas — l'encoche
  // du menu Période est relevée avant, et reposée là où elle était : la
  // période affichée, elle, n'a pas bougé.
  const period = markedIn("period", "period-this-month");
  const menu = element<HTMLElement>("window-menu");
  menu.replaceChildren();
  for (const key of [
    "operations-menu-export",
    "operations-menu-print",
    "operations-menu-filter",
    "operations-menu-period",
    "operations-menu-misc",
  ]) {
    const entry = document.createElement("button");
    entry.type = "button";
    entry.className = "window-menu__entry";
    entry.textContent = t(key);

    if (key === "operations-menu-period") {
      menu.append(
        buildPeriodMenu(
          entry,
          (chosen) => void showPeriod(chosen),
          [fromField, toField],
          period,
        ),
      );
      continue;
    }
    if (key === "operations-menu-filter") {
      menu.append(filterMenu(entry));
      continue;
    }
    if (key === "operations-menu-misc") {
      menu.append(miscMenu(entry));
      continue;
    }
    if (key === "operations-menu-export") {
      menu.append(exportMenu(entry));
      continue;
    }
    if (key === "operations-menu-print") {
      menu.append(printMenu(entry));
      continue;
    }

    entry.addEventListener("click", () => notYet());
    menu.append(entry);
  }

  if (ready) {
    await reload();
  }
}

void (async () => {
  await loadTexts(null);
  await dress();

  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    return;
  }
  // The five lists the combos are picked from, once for the whole window.
  combos = await invoke<Combos>("list_operation_combos");
  const month = currentMonth();
  fromField.value = month.from;
  toField.value = month.to;
  readParameters(window.location.search);
  // À partir d'ici la fenêtre sait de quel compte et de quelle période elle
  // parle : elle peut se relire elle-même.
  ready = true;
  await reload();
  onLanguageChanged(dress, TITLE);
})();

/// **Une nomenclature a changé pendant que cette fenêtre vivait.**
///
/// Bug remonté par un utilisateur le 10/08/2026 : « lorsque l'on rajoute une
/// nomenclature, il faut fermer le programme pour qu'on puisse avoir ce
/// nouveau libellé dans les opérations ». Une fenêtre de Radinus est bâtie une
/// fois et jamais détruite : elle lisait ses listes à sa construction et les
/// gardait jusqu'au prochain démarrage.
///
/// Ici les listes ne sont lues qu'à l'ouverture d'un menu de colonne : relire
/// la variable suffit, il n'y a rien à reposer.
void listen("nomenclatures-changed", async () => {
  combos = await invoke<Combos>("list_operation_combos");
  // **Et les lignes elles-mêmes** (Fabrice, 10/08/2026). Elles portent le mot,
  // pas la clef : une catégorie renommée laissait l'ancien nom sous les yeux
  // de celui qui venait de la renommer, et lui faisait douter de son geste.
  // Le prix est une relecture de la période affichée, celle-là même que la
  // fenêtre paie déjà après une saisie.
  if (ready) {
    await reload();
  }
});
