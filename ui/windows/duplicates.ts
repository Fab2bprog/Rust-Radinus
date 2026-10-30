// « Recherche des doublons » (menu Comptes).
//
// Conception arrêtée avec Fabrice le 29/10/2026 : un doublon a le même
// montant, des dates proches et des textes qui se ressemblent — le libellé
// comme la référence paiement. Le moteur est dans le noyau ; cette page ne
// fait que montrer ses groupes, chacun sous sa tête, les plus sûrs d'abord.
//
// Les niveaux cochés au départ sont ceux des préférences ; les décocher ici ne
// change que ce que la fenêtre montre.
//
// **Le marquage** (Fabrice, 29/10/2026) : « Garder celle-ci » se coche sur une
// ou plusieurs lignes d'un groupe — « on n'est pas obligé d'avoir 100 % tort
// ou raison ». Dès qu'une ligne d'un groupe est gardée, les autres sont « À
// supprimer » ; toutes gardées, rien ne l'est. Le marquage ne vit qu'ici, en
// mémoire, et Radinus ne s'en souvient pas d'une recherche à l'autre.
//
// **Un assistant en deux étapes** (Fabrice, 29/10/2026). Une question posée
// dans un panneau « débordera de l'écran » le jour où l'on supprime beaucoup
// de doublons, et l'utilisateur doit être obligé de valider ou de revenir au
// tableau. La flèche « Étape suivante » fait donc passer la même fenêtre à
// l'étape 2 : le récapitulatif, un vrai tableau qui défile.
//
// **Le panneau d'un assistant** (Fabrice, 30/10/2026) : le titre dit l'étape
// (1/2, 2/2) ; une flèche pour avancer, une flèche pour revenir sans rien
// perdre, la disquette pour enregistrer — une courte question, puis la
// suppression d'un seul bloc —, et la porte, à toutes les étapes, pour fermer
// l'assistant, avec une confirmation dès qu'un marquage est en cours. La porte
// ne sert jamais à revenir en arrière : elle laisserait croire qu'on perd son
// travail.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askYesNo } from "./dialog";
import { buildPeriodMenu, currentMonth } from "./period";
import { Table, type Grouping } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

const PARAMETERS_EVENT = "window-parameters:duplicates";
const CHANGED_EVENT = "data-changed:operations";

interface Row {
  id: number;
  group: number;
  date: string;
  /// La même date en ISO : la colonne se trie là-dessus.
  date_value: string;
  label: string;
  reference: string;
  debit: string;
  credit: string;
  amount: number;
  status: string;
  /// 1 pointée, 2 engagée, 3 prévue.
  status_id: number;
  category: string;
  payee: string;
  ventilated: boolean;
}

interface Group {
  level: string;
  title: string;
}

interface Found {
  rows: Row[];
  groups: Group[];
  said: string;
  balance_bank: number;
  balance_real: number;
  balance_final: number;
}

/// Les statuts : pointée compte dans les trois soldes, engagée dans le réel et
/// le final, prévue dans le final seulement (`balances`, Maj_Solde*).
const POINTED = 1;
const COMMITTED = 2;

interface Item {
  id: number;
  label: string;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");
const fromField = element<HTMLInputElement>("from");
const toField = element<HTMLInputElement>("to");
const levelBoxes = (): HTMLInputElement[] => [
  ...document.querySelectorAll<HTMLInputElement>(".period [data-level]"),
];

let accountId = 0;
let accountLabel = "";
let groups: Group[] = [];
let rows: Row[] = [];
let balances = { bank: 0, real: 0, final: 0 };
/// Les lignes cochées « Garder celle-ci », par leur clef.
const kept = new Set<number>();
/// Ce que la dernière validation a fait : dit dans la barre jusqu'au prochain
/// geste, devant le compte des groupes que la recherche relue retrouve.
let done = "";
/// L'étape de l'assistant : 1 la recherche et le marquage, 2 le récapitulatif.
let step: 1 | 2 = 1;
/// Ce que chaque ligne gardée reprend, et les avertissements — l'étape 2,
/// telle que Rust l'a préparée.
let recapTakes = new Map<number, string>();
let recapWarnings: string[] = [];

// --- Les montants, écrits par le noyau ----------------------------------

const formattedAmounts = new Map<number, string>();
const wantedAmounts = new Set<number>();
let askingForAmounts = false;

/// Un montant écrit dans la langue de l'interface. La fenêtre additionne mais
/// n'écrit jamais un montant elle-même : elle le demande (`format_amounts`),
/// et redessine quand la réponse arrive.
function money(amount: number): string {
  const known = formattedAmounts.get(amount);
  if (known !== undefined) {
    return known;
  }
  wantedAmounts.add(amount);
  if (!askingForAmounts) {
    askingForAmounts = true;
    queueMicrotask(() => void fetchAmounts());
  }
  return "…";
}

async function fetchAmounts(): Promise<void> {
  const amounts = [...wantedAmounts];
  wantedAmounts.clear();
  try {
    const texts = await invoke<string[]>("format_amounts", { amounts });
    amounts.forEach((amount, index) => formattedAmounts.set(amount, texts[index] ?? ""));
  } catch (error) {
    amounts.forEach((amount) => formattedAmounts.set(amount, "?"));
    say(tError("ui-read-failed", error), true);
  }
  askingForAmounts = false;
  table.refresh();
  recapTable.refresh();
  showFoot();
}

// --- Le marquage ------------------------------------------------------------

/// Les lignes d'un groupe.
function membersOf(group: number): Row[] {
  return rows.filter((row) => row.group === group);
}

/// Un groupe est traité dès qu'une de ses lignes est gardée.
function treated(group: number): boolean {
  return membersOf(group).some((row) => kept.has(row.id));
}

type State = "kept" | "doomed" | "none";

function stateOf(row: Row): State {
  if (kept.has(row.id)) {
    return "kept";
  }
  return treated(row.group) ? "doomed" : "none";
}

function stateWord(row: Row): string {
  const state = stateOf(row);
  if (state === "kept") {
    return t("duplicates-state-kept");
  }
  return state === "doomed" ? t("duplicates-state-doomed") : "";
}

function toggle(row: Row, keep: boolean): void {
  done = "";
  if (keep) {
    kept.add(row.id);
  } else {
    kept.delete(row.id);
  }
  table.refresh();
  showFoot();
}

/// Un texte barré quand la ligne part : le libellé et la référence.
function struck(text: (row: Row) => string): (row: Row, cell: HTMLElement) => void {
  return (row, cell) => {
    cell.textContent = text(row);
    cell.classList.toggle("duplicates__struck", stateOf(row) === "doomed");
  };
}
/// La fenêtre sait-elle de quel compte et de quelle période elle parle ?
let ready = false;

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

const table = new Table<Row>({
  container: element<HTMLElement>("rows"),
  columns: [
    {
      id: "keep",
      title: () => t("duplicates-column-keep"),
      cell: (row) => stateWord(row),
      render: (row, cell) => {
        const box = document.createElement("input");
        box.type = "checkbox";
        box.className = "duplicates__keep";
        box.checked = kept.has(row.id);
        // Cocher n'est pas choisir la ligne : le clic ne va pas au tableau.
        box.addEventListener("click", (event) => event.stopPropagation());
        box.addEventListener("change", () => toggle(row, box.checked));
        const word = document.createElement("span");
        word.textContent = stateWord(row);
        cell.append(box, word);
      },
      width: "1.1fr",
    },
    {
      id: "date",
      title: () => t("operations-column-date"),
      cell: (row) => row.date,
      key: (row) => row.date_value,
      width: "0.8fr",
    },
    {
      id: "label",
      title: () => t("operations-column-label"),
      cell: (row) => row.label,
      render: struck((row) => row.label),
      width: "2.4fr",
    },
    {
      id: "reference",
      title: () => t("operations-column-reference"),
      cell: (row) => row.reference,
      render: struck((row) => row.reference),
      width: "1.8fr",
    },
    {
      id: "debit",
      title: () => t("operations-column-debit"),
      cell: (row) => row.debit,
      key: (row) => row.amount,
      money: (row) => (row.amount < 0 ? row.amount : null),
      numeric: true,
      width: "0.9fr",
    },
    {
      id: "credit",
      title: () => t("operations-column-credit"),
      cell: (row) => row.credit,
      key: (row) => row.amount,
      money: (row) => (row.amount > 0 ? row.amount : null),
      numeric: true,
      width: "0.9fr",
    },
    {
      id: "status",
      title: () => t("operations-column-status"),
      cell: (row) => row.status,
      width: "0.9fr",
    },
    {
      id: "category",
      title: () => t("operations-column-category"),
      cell: (row) => row.category,
      width: "1.1fr",
    },
    {
      id: "payee",
      title: () => t("operations-column-payee"),
      cell: (row) => row.payee,
      width: "1.1fr",
    },
  ],
  identity: (row) => row.id,
  // Les groupes tiennent quel que soit le tri : une colonne triée ne range
  // que l'intérieur de chacun.
  groupOf: (row) => row.group,
  exportAs: () => ({
    name: t("menu-accounts-duplicates"),
    detail: `${accountLabel} — ${t("operations-from")} ${fromField.value} — ${t("operations-to")} ${toField.value}`,
  }),
  emptyText: () => t("duplicates-empty"),
  filteredOutText: () => t("ui-no-match"),
  rowClass: (row) => {
    const state = stateOf(row);
    return state === "none" ? null : `duplicates__row--${state}`;
  },
});

const grouping: Grouping<Row> = {
  groupable: () => true,
  of: (row) => ({ key: String(row.group), text: String(row.group) }),
  // Le total du groupe, et ce qui restera : une ligne gardée tant qu'on n'a
  // rien coché, puis autant que de lignes gardées.
  line: (text) => {
    const number = Number(text);
    const members = membersOf(number);
    const total = members.reduce((sum, row) => sum + row.amount, 0);
    const keeping = Math.max(1, members.filter((row) => kept.has(row.id)).length);
    const after = (members[0]?.amount ?? 0) * keeping;
    return {
      title: groups[number]?.title ?? "",
      sums: `${t("duplicates-total")} ${money(total)} · ${t("duplicates-after")} ${money(after)}`,
    };
  },
};
table.setGrouping(grouping);

// --- L'étape 2 : le récapitulatif ------------------------------------------

/// Les lignes des groupes traités seulement, avec ce que chaque gardée
/// reprend. Les mêmes couleurs et le même texte barré qu'à l'étape 1 : on
/// reconnaît ce qu'on vient de décider.
const recapTable = new Table<Row>({
  container: element<HTMLElement>("recap-rows"),
  columns: [
    {
      id: "state",
      title: () => t("duplicates-column-state"),
      cell: (row) => stateWord(row),
      width: "0.9fr",
    },
    {
      id: "date",
      title: () => t("operations-column-date"),
      cell: (row) => row.date,
      key: (row) => row.date_value,
      width: "0.8fr",
    },
    {
      id: "label",
      title: () => t("operations-column-label"),
      cell: (row) => row.label,
      render: struck((row) => row.label),
      width: "2.2fr",
    },
    {
      id: "reference",
      title: () => t("operations-column-reference"),
      cell: (row) => row.reference,
      render: struck((row) => row.reference),
      width: "1.6fr",
    },
    {
      id: "debit",
      title: () => t("operations-column-debit"),
      cell: (row) => row.debit,
      key: (row) => row.amount,
      money: (row) => (row.amount < 0 ? row.amount : null),
      numeric: true,
      width: "0.9fr",
    },
    {
      id: "credit",
      title: () => t("operations-column-credit"),
      cell: (row) => row.credit,
      key: (row) => row.amount,
      money: (row) => (row.amount > 0 ? row.amount : null),
      numeric: true,
      width: "0.9fr",
    },
    {
      id: "status",
      title: () => t("operations-column-status"),
      cell: (row) => row.status,
      width: "0.9fr",
    },
    {
      id: "takes",
      title: () => t("duplicates-column-takes"),
      cell: (row) => recapTakes.get(row.id) ?? "",
      width: "2fr",
    },
  ],
  identity: (row) => row.id,
  groupOf: (row) => row.group,
  exportAs: () => ({
    name: t("duplicates-recap-title"),
    detail: `${accountLabel} — ${t("operations-from")} ${fromField.value} — ${t("operations-to")} ${toField.value}`,
  }),
  emptyText: () => t("duplicates-empty"),
  filteredOutText: () => t("ui-no-match"),
  rowClass: (row) => {
    const state = stateOf(row);
    return state === "none" ? null : `duplicates__row--${state}`;
  },
});
recapTable.setGrouping(grouping);

/// Montre l'une ou l'autre étape. À l'étape 2, **rien d'autre que les deux
/// boutons** : ni menu Période, ni dates, ni niveaux, ni cases à cocher — on
/// supprime, ou l'on revient au tableau.
function showStep(wanted: 1 | 2): void {
  step = wanted;
  const recap = wanted === 2;
  for (const id of ["window-menu", "period", "search", "next"]) {
    element<HTMLElement>(id).hidden = recap;
  }
  for (const id of ["recap", "previous", "save"]) {
    element<HTMLElement>(id).hidden = !recap;
  }
  retitle();
  if (recap) {
    recapTable.setRows(rows.filter((row) => treated(row.group)));
    recapTable.refresh();
    const holder = element<HTMLElement>("warnings");
    const list = element<HTMLElement>("warnings-list");
    list.replaceChildren(
      ...recapWarnings.map((warning) => {
        const item = document.createElement("li");
        item.textContent = warning;
        return item;
      }),
    );
    holder.hidden = recapWarnings.length === 0;
    say(t("duplicates-recap-help"));
  } else {
    table.refresh();
  }
}

/// La clef du titre : il dit l'étape où l'on est.
function titleKey(): string {
  return step === 2 ? "window-duplicates-title-2" : "window-duplicates-title-1";
}

/// Le titre de la fenêtre, composé par Rust : le nom de l'assistant, le
/// compte, et l'étape.
function retitle(): void {
  void invoke("retitle", { key: titleKey(), argument: accountLabel, argumentName: null }).catch(
    () => undefined,
  );
}

/// Demande à Rust ce que chaque ligne gardée reprendra et ce qu'il faut
/// savoir. `false` quand c'est refusé — la raison est déjà dans la barre.
async function readRecap(): Promise<boolean> {
  const recap = await invoke<{
    refused: boolean;
    text: string;
    takes: { id: number; what: string }[];
    warnings: string[];
  }>("duplicates_recap", { accountId, decisions: decisions() });
  if (recap.refused) {
    say(recap.text, true);
    return false;
  }
  recapTakes = new Map(recap.takes.map((take) => [take.id, take.what]));
  recapWarnings = recap.warnings;
  return true;
}

// --- Le pied : ce qui partira, et les trois soldes --------------------------

function showFoot(): void {
  const shown = (id: string, text: string): void => {
    element<HTMLElement>(id).textContent = text;
  };
  const treatedGroups = groups.filter((_, number) => treated(number)).length;
  const doomed = rows.filter((row) => stateOf(row) === "doomed");
  const removed = (counts: (row: Row) => boolean): number =>
    doomed.filter(counts).reduce((sum, row) => sum + row.amount, 0);
  shown("foot-groups", `${treatedGroups} / ${groups.length}`);
  shown("foot-doomed", String(doomed.length));
  shown("foot-amount", money(removed(() => true)));
  for (const [name, before, gone] of [
    ["bank", balances.bank, removed((row) => row.status_id === POINTED)],
    ["real", balances.real, removed((row) => row.status_id === POINTED || row.status_id === COMMITTED)],
    ["final", balances.final, removed(() => true)],
  ] as const) {
    shown(`foot-${name}-before`, money(before));
    shown(`foot-${name}-after`, money(before - gone));
    shown(`foot-${name}-gap`, money(-gone));
  }
}

function levels(): string[] {
  return levelBoxes()
    .filter((box) => box.checked)
    .map((box) => box.dataset.level ?? "");
}

/// Relit les groupes : la période, les niveaux cochés, et les préférences du
/// moment — le noyau les relit à chaque recherche.
async function reload(): Promise<void> {
  if (!ready || accountId === 0) {
    return;
  }
  try {
    const found = await invoke<Found>("duplicates_search", {
      accountId,
      from: fromField.value,
      to: toField.value,
      levels: levels(),
    });
    groups = found.groups;
    rows = found.rows;
    balances = { bank: found.balance_bank, real: found.balance_real, final: found.balance_final };
    // Une ligne qui n'est plus là ne peut plus être gardée.
    const alive = new Set(rows.map((row) => row.id));
    for (const id of [...kept]) {
      if (!alive.has(id)) {
        kept.delete(id);
      }
    }
    table.setRows(rows);
    table.refresh();
    showFoot();
    say(done === "" ? found.said : `${done} ${found.said}`);
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// Un compte : les niveaux repartent de ce que disent les préférences.
async function openAccount(id: number): Promise<void> {
  accountId = id;
  kept.clear();
  done = "";
  history.replaceState(null, "", `?account=${accountId}`);
  table.clearSelection();
  try {
    const shown = await invoke<string[]>("duplicates_levels");
    for (const box of levelBoxes()) {
      box.checked = shown.includes(box.dataset.level ?? "");
    }
    accountLabel =
      (await invoke<Item[]>("list_accounts").catch(() => [] as Item[])).find(
        (account) => account.id === accountId,
      )?.label ?? accountLabel;
    retitle();
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
  await reload();
}

/// Ce qui a été décidé, groupe par groupe : seuls les groupes où une ligne au
/// moins est gardée, et dont une ligne au moins part.
function decisions(): { kept: number[]; doomed: number[] }[] {
  return groups
    .map((_, number) => {
      const members = membersOf(number);
      return {
        kept: members.filter((row) => kept.has(row.id)).map((row) => row.id),
        doomed: members.filter((row) => !kept.has(row.id)).map((row) => row.id),
      };
    })
    .filter((decision) => decision.kept.length > 0 && decision.doomed.length > 0);
}

/// **Étape suivante** : le récapitulatif. Rien n'est écrit.
async function next(): Promise<void> {
  try {
    if (await readRecap()) {
      showStep(2);
    }
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// **Enregistrer**, à l'étape 2 : une dernière question courte, puis la
/// reprise et les suppressions d'un seul bloc. Retour à l'étape 1, qui se
/// relit.
async function save(): Promise<void> {
  if (!(await askYesNo(t("duplicates-confirm-question"), t("ui-yes"), t("ui-no")))) {
    return;
  }
  try {
    const outcome = await invoke<{ refused: boolean; text: string }>("duplicates_apply", {
      accountId,
      from: fromField.value,
      to: toField.value,
      decisions: decisions(),
    });
    if (outcome.refused) {
      showStep(1);
      say(outcome.text, true);
      return;
    }
    kept.clear();
    done = outcome.text;
    showStep(1);
    await reload();
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

/// **Étape précédente** : le tableau, le marquage intact.
function previous(): void {
  showStep(1);
  say(done);
  void reload();
}

/// **La porte, à toutes les étapes : fermer l'assistant.** Un marquage en
/// cours se perd — rien n'est supprimé —, et on le demande avant.
async function leave(): Promise<void> {
  if (kept.size > 0 && !(await askYesNo(t("duplicates-close-question"), t("ui-yes"), t("ui-no")))) {
    return;
  }
  try {
    kept.clear();
    showStep(1);
    await invoke("close_duplicates");
  } catch (error) {
    say(tError("ui-close-failed", error), true);
  }
}

function dress(): void {
  for (const [id, key] of [
    ["from-label", "operations-from"],
    ["to-label", "operations-to"],
    ["levels-label", "duplicates-levels"],
    ["level-identical-word", "duplicates-level-identical"],
    ["level-probable-word", "duplicates-level-probable"],
    ["level-possible-word", "duplicates-level-possible"],
    ["level-to-verify-word", "duplicates-level-to-verify"],
    ["foot-groups-label", "duplicates-foot-groups"],
    ["foot-doomed-label", "duplicates-foot-doomed"],
    ["foot-amount-label", "duplicates-foot-amount"],
    ["foot-before-label", "duplicates-foot-before"],
    ["foot-after-label", "duplicates-foot-after"],
    ["foot-gap-label", "duplicates-foot-gap"],
    ["foot-bank-label", "operations-foot-bank"],
    ["foot-real-label", "operations-foot-real"],
    ["foot-final-label", "operations-foot-final"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  element<HTMLElement>("close").title = t("duplicates-close");
  element<HTMLElement>("next").title = t("duplicates-next");
  element<HTMLElement>("previous").title = t("duplicates-previous");
  element<HTMLElement>("save").title = t("duplicates-save");
  element<HTMLElement>("recap-title").textContent = t("duplicates-recap-title");
  element<HTMLElement>("warnings-title").textContent = t("duplicates-confirm-warnings");

  // **Le menu Période** de la liste des opérations (Fabrice, 29/10/2026 : « c'est
  // pour rendre la recherche plus rapide »). L'encoche part sur l'année en
  // cours, puisque c'est sur elle que la fenêtre s'ouvre. Ses entrées sont des
  // mots : il se rebâtit tout entier à chaque changement de langue, la barre
  // vidée d'abord.
  const menu = element<HTMLElement>("window-menu");
  menu.replaceChildren();
  const entry = document.createElement("button");
  entry.type = "button";
  entry.className = "window-menu__entry";
  entry.textContent = t("operations-menu-period");
  menu.append(
    buildPeriodMenu(
      entry,
      (period) => {
        fromField.value = period.from;
        toField.value = period.to;
        done = "";
        void reload();
      },
      [fromField, toField],
      // L'encoche part sur le mois en cours : c'est sur lui que l'assistant
      // s'ouvre (Fabrice, 30/10/2026).
      "period-this-month",
    ),
  );
  table.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));
  recapTable.buildHeader(element<HTMLElement>("recap-header"), element<HTMLElement>("recap-filter"));
}

element<HTMLButtonElement>("next").addEventListener("click", () => void next());
element<HTMLButtonElement>("previous").addEventListener("click", () => previous());
element<HTMLButtonElement>("save").addEventListener("click", () => void save());
element<HTMLButtonElement>("close").addEventListener("click", () => void leave());
for (const field of [fromField, toField]) {
  field.addEventListener("change", () => {
    done = "";
    void reload();
  });
}
for (const box of levelBoxes()) {
  box.addEventListener("change", () => {
    done = "";
    void reload();
  });
}
window.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    event.preventDefault();
    void leave();
  }
});

// Une opération a changé ailleurs : les groupes se relisent. **Un
// récapitulatif ne survit pas à ce changement** : il décrivait des opérations
// qui ne sont peut-être plus les mêmes. On revient au tableau, marquage gardé
// pour ce qui existe encore, et l'on revalide.
void listen(CHANGED_EVENT, () => {
  if (step === 2) {
    showStep(1);
  }
  void reload();
});
// Redemandée pour un autre compte.
void listen<string>(PARAMETERS_EVENT, (event) => {
  showStep(1);
  // Chaque ouverture repart sur le mois en cours, l'encoche du menu avec.
  showThisMonth();
  dress();
  void openAccount(Number(new URLSearchParams(event.payload).get("account") ?? 0));
});

/// **La période d'ouverture : le mois en cours** (Fabrice, 30/10/2026).
function showThisMonth(): void {
  const month = currentMonth();
  fromField.value = month.from;
  toField.value = month.to;
}

void (async () => {
  await loadTexts(null);
  dress();
  table.exportOnRightClick(say);
  recapTable.exportOnRightClick(say);
  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    return;
  }
  showThisMonth();
  ready = true;
  await openAccount(Number(new URLSearchParams(window.location.search).get("account") ?? 0));
  onLanguageChanged(
    async () => {
      // Les montants s'écrivent autrement dans une autre langue.
      formattedAmounts.clear();
      dress();
      // Les mots des têtes et la phrase de la barre viennent du noyau, dans
      // la langue de l'interface : on les redemande — et ceux du
      // récapitulatif aussi, s'il est à l'écran.
      await reload();
      if (step === 2 && (await readRecap())) {
        showStep(2);
      }
    },
    {
      get key(): string {
        return titleKey();
      },
      get argument(): string {
        return accountLabel;
      },
    },
  );
})();
