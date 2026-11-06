// « Importation de fichier Money (MNY) » (Fabrice, 05/11/2026).
//
// Un compte Radinus d'abord — la liste des comptes l'a demandé —, puis quatre
// étapes dans cette seule fenêtre : le fichier et son compte Money, où va
// chaque donnée, les correspondances de valeurs, le récapitulatif.
//
// **La fenêtre ne décide de rien.** Le fichier est choisi et lu par Rust, qui
// le garde ; les menus de l'étape 2 et leurs propositions viennent du noyau
// (`mny_choices`), l'aperçu et les correspondances aussi. La fenêtre tient
// seulement ce que l'utilisateur a choisi, et le renvoie à chaque question.
//
// « On ne doit pas tout automatiser en forçant des choix » : chaque menu
// porte une proposition, et l'utilisateur peut tout changer.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askYesNo, tell } from "./dialog";
import { Table } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

const PARAMETERS_EVENT = "window-parameters:mny-import";

interface MoneyAccount {
  handle: number;
  label: string;
  detail: string;
}

interface Book {
  needs_password: boolean;
  problem: string | null;
  accounts: MoneyAccount[];
}

interface SourceChoice {
  key: string;
  default: string;
  destinations: string[];
}

interface Choices {
  sources: SourceChoice[];
  labels: string[];
  label: string;
  statuses: string[];
  cleared: string;
  not_cleared: string;
  scheduled: string[];
  scheduled_default: string;
  payees: string[];
  payees_default: string;
  frequent: number;
}

/// Ce que le fichier contient d'une donnée : la colonne « Exemple tiré du
/// fichier ».
interface Sample {
  key: string;
  example: string;
  absent: boolean;
}

interface Samples {
  sources: Sample[];
  payee: Sample;
  payees: string;
  cleared: Sample;
  not_cleared: Sample;
  scheduled: Sample;
}

interface PreviewRow {
  id: number;
  date: string;
  date_value: string;
  label: string;
  amount_text: string;
  amount: number;
  status: string;
  budget_line: string;
  category: string;
  payee: string;
  others: string;
}

interface Preview {
  refusal: string | null;
  conflicts: string[];
  rows: PreviewRow[];
  summary: string;
}

interface ValueRow {
  id: number;
  destination: string;
  label: string;
  budget_line: string;
  uses: number;
  proposal: string;
}

interface Item {
  id: number;
  label: string;
}

interface Values {
  rows: ValueRow[];
  options: { destination: string; items: Item[] }[];
}

interface Recap {
  lines: string[];
  warning: string | null;
  opening: string | null;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");
const fileField = element<HTMLInputElement>("file");
const passwordField = element<HTMLInputElement>("password");
const accountField = element<HTMLSelectElement>("money-account");
const labelField = element<HTMLSelectElement>("label-from");
const clearedField = element<HTMLSelectElement>("cleared");
const notClearedField = element<HTMLSelectElement>("not-cleared");
const scheduledField = element<HTMLSelectElement>("scheduled");

let accountId = 0;
let accountLabel = "";
let step: 1 | 2 | 3 | 4 = 1;
let filePath = "";
let accounts: MoneyAccount[] = [];
let choices: Choices | null = null;
/// La case choisie pour chaque donnée Money ; vide, c'est la proposition.
const routes = new Map<string, string>();
/// La réponse à « créer aussi des tiers ? » ; vide, c'est la proposition.
let payees = "";
/// Les exemples du compte Money choisi, lus en entrant à l'étape 2.
let samples: Samples | null = null;
/// Les données envoyées dans une même rubrique : leurs lignes en rouge.
let conflicts: string[] = [];
/// La raison du refus des choix en cours, s'ils sont refusés.
let refusal: string | null = null;
let valueRows: ValueRow[] = [];
/// Le choix de l'étape 3 pour chaque valeur (par son rang) ; absent, c'est la
/// proposition.
const valueChoices = new Map<number, string>();
const options = new Map<string, Item[]>();

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

/// Le compte Money choisi, ou 0 s'il n'y en a pas.
function handle(): number {
  return Number(accountField.value || 0);
}

/// Ce que l'utilisateur a choisi à l'étape 2, tel que Rust l'attend.
function mapping(): {
  routes: Record<string, string>;
  payees: string;
  label: string;
  cleared: string;
  not_cleared: string;
  scheduled: string;
} {
  const chosen: Record<string, string> = {};
  for (const source of choices?.sources ?? []) {
    chosen[source.key] = routes.get(source.key) ?? source.default;
  }
  return {
    routes: chosen,
    payees: payees || (choices?.payees_default ?? "none"),
    label: labelField.value || (choices?.label ?? "payee"),
    cleared: clearedField.value || (choices?.cleared ?? "pointed"),
    not_cleared: notClearedField.value || (choices?.not_cleared ?? "committed"),
    scheduled: scheduledField.value || (choices?.scheduled_default ?? "skip"),
  };
}

// --- Les deux tableaux -----------------------------------------------------

/// **L'aperçu, lisible** (Fabrice, 05/11/2026) : la date, le libellé, le
/// montant, le poste, la catégorie, le tiers, et tout le reste dans
/// « Autres ». Une colonne vide d'un bout à l'autre est masquée.
const preview = new Table<PreviewRow>({
  container: element<HTMLElement>("preview-rows"),
  columns: [
    { id: "date", title: () => t("operations-column-date"), cell: (row) => row.date, key: (row) => row.date_value, width: "0.7fr" },
    { id: "label", title: () => t("operations-column-label"), cell: (row) => row.label, width: "1.8fr" },
    { id: "amount", title: () => t("statistics-column-amount"), cell: (row) => row.amount_text, key: (row) => row.amount, numeric: true, width: "0.8fr" },
    { id: "budget-line", title: () => t("mny-destination-budget-line"), cell: (row) => row.budget_line, width: "1.1fr" },
    { id: "category", title: () => t("mny-destination-category"), cell: (row) => row.category, width: "1.1fr" },
    { id: "payee", title: () => t("mny-destination-payee"), cell: (row) => row.payee, width: "1fr" },
    { id: "others", title: () => t("mny-column-others"), cell: (row) => row.others, width: "1.8fr" },
  ],
  identity: (row) => row.id,
  // Des choix refusés : l'aperçu vide dit pourquoi, pas « aucune opération ».
  emptyText: () => refusal ?? t(filePath === "" ? "mny-empty-no-file" : "mny-empty"),
  filteredOutText: () => t("ui-no-match"),
});

/// Les colonnes de l'aperçu qui peuvent se trouver vides.
const OPTIONAL_COLUMNS: [string, (row: PreviewRow) => string][] = [
  ["budget-line", (row) => row.budget_line],
  ["category", (row) => row.category],
  ["payee", (row) => row.payee],
  ["others", (row) => row.others],
];

/// Pose les lignes de l'aperçu, et masque les colonnes qu'aucune ne remplit.
function showPreview(rows: PreviewRow[]): void {
  preview.setRows(rows);
  const hidden =
    rows.length === 0
      ? []
      : OPTIONAL_COLUMNS.filter(([, value]) => rows.every((row) => value(row) === "")).map(
          ([id]) => id,
        );
  preview.hideColumns(hidden);
}

/// Le menu d'une valeur à l'étape 3 : « à créer », « Non précisé », puis les
/// éléments de la nomenclature.
function choiceMenu(row: ValueRow, cell: HTMLElement): void {
  const menu = document.createElement("select");
  menu.className = "mny__choice";
  const add = (value: string, text: string): void => {
    const option = document.createElement("option");
    option.value = value;
    option.textContent = text;
    menu.append(option);
  };
  add("create", t("mny-choice-create"));
  add("unspecified", t("mny-choice-unspecified"));
  for (const item of options.get(row.destination) ?? []) {
    add(String(item.id), item.label);
  }
  menu.value = valueChoices.get(row.id) ?? row.proposal;
  // Choisir dans le menu n'est pas choisir la ligne.
  menu.addEventListener("click", (event) => event.stopPropagation());
  menu.addEventListener("change", () => valueChoices.set(row.id, menu.value));
  cell.append(menu);
}

const values = new Table<ValueRow>({
  container: element<HTMLElement>("values-rows"),
  columns: [
    { id: "destination", title: () => t("mny-column-destination"), cell: (row) => t(`mny-destination-${row.destination}`), width: "0.9fr" },
    { id: "value", title: () => t("mny-column-value"), cell: (row) => row.label, width: "1.6fr" },
    { id: "budget-line", title: () => t("mny-destination-budget-line"), cell: (row) => row.budget_line, width: "1.1fr" },
    { id: "uses", title: () => t("mny-column-uses"), cell: (row) => String(row.uses), key: (row) => row.uses, numeric: true, width: "0.5fr" },
    {
      id: "choice",
      title: () => t("mny-column-choice"),
      cell: (row) => valueChoices.get(row.id) ?? row.proposal,
      render: choiceMenu,
      width: "1.6fr",
    },
  ],
  identity: (row) => row.id,
  emptyText: () => t("mny-values-empty"),
  filteredOutText: () => t("ui-no-match"),
});

// --- Les étapes -------------------------------------------------------------

function titleKey(): string {
  return `window-mny-import-title-${step}`;
}

function retitle(): void {
  void invoke("retitle", { key: titleKey(), argument: accountLabel, argumentName: null }).catch(
    () => undefined,
  );
}

/// Montre une étape. L'aperçu sert aux deux premières.
function showStep(wanted: 1 | 2 | 3 | 4): void {
  step = wanted;
  element<HTMLElement>("step-1").hidden = step !== 1;
  element<HTMLElement>("step-2").hidden = step !== 2;
  element<HTMLElement>("preview").hidden = step > 2;
  element<HTMLElement>("summary").hidden = step > 2;
  element<HTMLElement>("values").hidden = step !== 3;
  element<HTMLElement>("recap").hidden = step !== 4;
  element<HTMLElement>("previous").hidden = step === 1;
  element<HTMLElement>("next").hidden = step === 4;
  element<HTMLElement>("save").hidden = step !== 4;
  retitle();
  if (step === 3) {
    values.refresh();
  } else if (step <= 2) {
    preview.refresh();
  }
  say(t(`mny-help-${step}`));
}

/// Désigne un fichier : le sélecteur du système, ouvert par Rust.
async function pick(): Promise<void> {
  try {
    const chosen = await invoke<string | null>("mny_pick_file", { accountId });
    if (chosen === null) {
      return;
    }
    filePath = chosen;
    fileField.value = chosen;
    passwordField.value = "";
    await read(null);
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// Lit le fichier désigné ; le mot de passe n'est demandé que s'il en faut un.
async function read(password: string | null): Promise<void> {
  const book = await invoke<Book>("mny_read", { password });
  const protectedFile = book.needs_password;
  element<HTMLElement>("password-label").hidden = !protectedFile;
  element<HTMLElement>("password-line").hidden = !protectedFile;
  accounts = book.accounts;
  accountField.replaceChildren(
    ...accounts.map((account) => {
      const option = document.createElement("option");
      option.value = String(account.handle);
      option.textContent = account.label;
      return option;
    }),
  );
  showDetail();
  if (book.problem !== null) {
    showPreview([]);
    element<HTMLElement>("summary").textContent = "";
    say(book.problem, true);
    if (protectedFile) {
      passwordField.focus();
    }
    return;
  }
  await refreshPreview();
  say(t("mny-help-1"));
}

/// Le solde d'ouverture et le nombre d'opérations du compte Money choisi.
function showDetail(): void {
  element<HTMLElement>("money-account-detail").textContent =
    accounts.find((account) => account.handle === handle())?.detail ?? "";
}

/// L'aperçu avec les choix en cours. `false` quand les choix ne passent pas —
/// la raison est dans la barre.
async function refreshPreview(): Promise<boolean> {
  if (handle() === 0) {
    refusal = null;
    showPreview([]);
    element<HTMLElement>("summary").textContent = "";
    return false;
  }
  const shown = await invoke<Preview>("mny_preview", { handle: handle(), mapping: mapping() });
  conflicts = shown.conflicts;
  refusal = shown.refusal;
  markConflicts();
  if (shown.refusal !== null) {
    showPreview([]);
    element<HTMLElement>("summary").textContent = "";
    say(shown.refusal, true);
    return false;
  }
  showPreview(shown.rows);
  element<HTMLElement>("summary").textContent = shown.summary;
  return true;
}

/// Une cellule du tableau de l'étape 2.
function cell(kind: string, source: string, ...content: (Node | string)[]): HTMLElement {
  const box = document.createElement("div");
  box.className = `mny__cell mny__cell--${kind}`;
  box.role = kind === "head" ? "columnheader" : "cell";
  if (source !== "") {
    box.dataset.source = source;
  }
  box.append(...content);
  return box;
}

/// Un texte d'appoint, sous un exemple ou sous un menu.
function hint(text: string): HTMLElement {
  const line = document.createElement("span");
  line.className = "mny__hint";
  line.textContent = text;
  return line;
}

/// Un menu déroulant, une option par clef, sur son choix.
function menuOf(id: string, keys: string[], prefix: string, chosen: string): HTMLSelectElement {
  const menu = document.createElement("select");
  menu.className = "form__field";
  menu.id = id;
  for (const key of keys) {
    const option = document.createElement("option");
    option.value = key;
    option.textContent = t(`${prefix}${key}`);
    menu.append(option);
  }
  menu.value = chosen;
  return menu;
}

/// **Le tableau de l'étape 2**, bâti d'après le noyau : en tête les quatre
/// colonnes, puis une ligne par donnée Money — son nom, un exemple tiré du
/// fichier, la flèche, et le menu de la rubrique Radinus. Le bénéficiaire a
/// sa ligne à lui, après la sous-catégorie : il donne le libellé, et sa
/// question dit s'il donne aussi des tiers.
function buildRoutes(): void {
  const holder = element<HTMLElement>("routes");
  holder.replaceChildren(
    cell("head", "", t("mny-column-money")),
    cell("head", "", t("mny-column-example")),
    cell("head", "", ""),
    cell("head", "", t("mny-column-choice")),
  );
  const row = (key: string, sample: Sample | undefined, extra: string, answer: HTMLElement[]): void => {
    const absent = sample?.absent ?? false;
    const grey = absent ? " mny__cell--absent" : "";
    const example = [sample?.example ?? ""] as (Node | string)[];
    if (extra !== "") {
      example.push(hint(extra));
    }
    holder.append(
      cell(`name${grey}`, key, t(`mny-source-${key}`)),
      cell(`example${grey}`, key, ...example),
      cell(`arrow${grey}`, key, "→"),
      cell(`choice${grey}`, key, ...answer),
    );
  };
  for (const source of choices?.sources ?? []) {
    const menu = menuOf(
      `route-${source.key}`,
      source.destinations,
      "mny-destination-",
      routes.get(source.key) ?? source.default,
    );
    menu.addEventListener("change", () => {
      routes.set(source.key, menu.value);
      void refreshPreview().then((passed) => passed && say(t("mny-help-2")));
    });
    row(
      source.key,
      samples?.sources.find((one) => one.key === source.key),
      "",
      [menu],
    );
    if (source.key === "sub-category" && choices !== null) {
      const menu = menuOf("payees", choices.payees, "mny-payees-", payees || choices.payees_default);
      menu.addEventListener("change", () => {
        payees = menu.value;
        void refreshPreview().then((passed) => passed && say(t("mny-help-2")));
      });
      row("payee", samples?.payee, samples?.payee.absent ? "" : samples?.payees ?? "", [
        menu,
        hint(t("mny-payee-hint")),
      ]);
    }
  }
  markConflicts();
  const fill = (menu: HTMLSelectElement, keys: string[], prefix: string, chosen: string): void => {
    const keep = menu.value;
    menu.replaceChildren(
      ...keys.map((key) => {
        const option = document.createElement("option");
        option.value = key;
        option.textContent = t(`${prefix}${key}`);
        return option;
      }),
    );
    menu.value = keep !== "" && keys.includes(keep) ? keep : chosen;
  };
  if (choices !== null) {
    fill(labelField, choices.labels, "mny-label-", choices.label);
    fill(clearedField, choices.statuses, "mny-status-", choices.cleared);
    fill(notClearedField, choices.statuses, "mny-status-", choices.not_cleared);
    fill(scheduledField, choices.scheduled, "mny-scheduled-", choices.scheduled_default);
  }
  // Combien d'opérations chaque question touche ; aucune, elle est grisée.
  for (const [id, sample] of [
    ["cleared", samples?.cleared],
    ["not-cleared", samples?.not_cleared],
    ["scheduled", samples?.scheduled],
  ] as const) {
    element<HTMLElement>(`${id}-count`).textContent = sample?.example ?? "";
    element<HTMLElement>(`${id}-label`).classList.toggle(
      "mny__question--absent",
      sample?.absent ?? false,
    );
  }
}

/// Les lignes des données envoyées dans une même rubrique passent en rouge.
function markConflicts(): void {
  for (const box of element<HTMLElement>("routes").querySelectorAll<HTMLElement>(".mny__cell")) {
    const source = box.dataset.source;
    box.classList.toggle("mny__cell--conflict", source !== undefined && conflicts.includes(source));
  }
}

/// **Étape suivante.** Chacune vérifie ce dont la suivante a besoin.
async function next(): Promise<void> {
  try {
    if (step === 1) {
      if (handle() === 0) {
        say(t("mny-need-account"), true);
        return;
      }
      samples = await invoke<Samples>("mny_samples", { handle: handle() });
      buildRoutes();
      showStep(2);
      await refreshPreview();
      return;
    }
    if (step === 2) {
      if (!(await refreshPreview())) {
        return;
      }
      const loaded = await invoke<Values>("mny_values", { handle: handle(), mapping: mapping() });
      options.clear();
      for (const group of loaded.options) {
        options.set(group.destination, group.items);
      }
      // Les choix faits sur les mêmes valeurs survivent à un aller-retour ;
      // de nouvelles valeurs repartent de leur proposition.
      const before = new Map(valueRows.map((row) => [`${row.destination}|${row.label}`, row.id]));
      const kept = new Map<number, string>();
      for (const row of loaded.rows) {
        const was = before.get(`${row.destination}|${row.label}`);
        const choice = was === undefined ? undefined : valueChoices.get(was);
        if (choice !== undefined) {
          kept.set(row.id, choice);
        }
      }
      valueChoices.clear();
      for (const [id, choice] of kept) {
        valueChoices.set(id, choice);
      }
      valueRows = loaded.rows;
      values.setRows(valueRows);
      showStep(3);
      return;
    }
    if (step === 3) {
      const recap = await invoke<Recap>("mny_recap", {
        handle: handle(),
        mapping: mapping(),
        choices: valueRows.map((row) => valueChoices.get(row.id) ?? row.proposal),
      });
      element<HTMLElement>("recap-lines").replaceChildren(
        ...recap.lines.map((line) => {
          const item = document.createElement("li");
          item.textContent = line;
          return item;
        }),
      );
      const warning = element<HTMLElement>("recap-warning");
      warning.textContent = recap.warning ?? "";
      warning.hidden = recap.warning === null;
      element<HTMLElement>("opening-text").textContent = recap.opening ?? "";
      element<HTMLElement>("opening-line").hidden = recap.opening === null;
      element<HTMLInputElement>("opening").checked = true;
      showStep(4);
    }
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// **La disquette de l'étape 4** : une dernière question, puis l'import d'un
/// seul bloc. Un message dit ce qui a été fait, avec un seul bouton « OK »,
/// puis l'assistant se ferme (Fabrice, 05/11/2026 : « si elle veut importer
/// un autre compte elle réouvre l'assistant »).
async function save(): Promise<void> {
  if (!(await askYesNo(t("mny-save-question"), t("ui-yes"), t("ui-no")))) {
    return;
  }
  try {
    const openingLine = element<HTMLElement>("opening-line");
    const done = await invoke<{ text: string }>("mny_import", {
      handle: handle(),
      mapping: mapping(),
      choices: valueRows.map((row) => valueChoices.get(row.id) ?? row.proposal),
      opening: !openingLine.hidden && element<HTMLInputElement>("opening").checked,
    });
    reset();
    await tell(done.text, t("ui-ok"));
    await invoke("close_mny_import");
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

/// **Étape précédente** : rien n'est perdu.
function previous(): void {
  if (step > 1) {
    showStep((step - 1) as 1 | 2 | 3);
  }
}

/// **La porte, à toutes les étapes.** Un fichier lu et des choix faits se
/// perdent : on le demande avant.
async function leave(): Promise<void> {
  if (filePath !== "" && !(await askYesNo(t("mny-close-question"), t("ui-yes"), t("ui-no")))) {
    return;
  }
  try {
    reset();
    await invoke("close_mny_import");
  } catch (error) {
    say(tError("ui-close-failed", error), true);
  }
}

/// Repart de zéro : aucun fichier, les propositions partout.
function reset(): void {
  filePath = "";
  fileField.value = "";
  passwordField.value = "";
  accounts = [];
  accountField.replaceChildren();
  routes.clear();
  payees = "";
  samples = null;
  conflicts = [];
  refusal = null;
  valueRows = [];
  valueChoices.clear();
  for (const menu of [labelField, clearedField, notClearedField, scheduledField]) {
    menu.value = "";
  }
  element<HTMLElement>("password-label").hidden = true;
  element<HTMLElement>("password-line").hidden = true;
  element<HTMLElement>("summary").textContent = "";
  showDetail();
  showPreview([]);
  values.setRows([]);
  buildRoutes();
  showStep(1);
}

/// Le compte Radinus, dont le nom va dans le titre.
async function openAccount(id: number): Promise<void> {
  accountId = id;
  history.replaceState(null, "", `?account=${accountId}`);
  try {
    accountLabel =
      (await invoke<Item[]>("list_accounts").catch(() => [] as Item[])).find(
        (account) => account.id === accountId,
      )?.label ?? "";
  } catch {
    accountLabel = "";
  }
  retitle();
}

function dress(): void {
  for (const [id, key] of [
    ["file-label", "mny-field-file"],
    ["pick", "mny-pick"],
    ["password-label", "mny-field-password"],
    ["unlock", "mny-unlock"],
    ["money-account-label", "mny-field-account"],
    ["label-from-label", "mny-field-label"],
    ["cleared-label", "mny-field-cleared"],
    ["not-cleared-label", "mny-field-not-cleared"],
    ["scheduled-label", "mny-field-scheduled"],
    ["recap-title", "mny-recap-title"],
    ["routes-intro", "mny-routes-intro"],
    ["settings-title", "mny-settings-title"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  element<HTMLElement>("next").title = t("duplicates-next");
  element<HTMLElement>("previous").title = t("duplicates-previous");
  element<HTMLElement>("close").title = t("mny-close");
  element<HTMLElement>("save").title = t("mny-save");
  buildRoutes();
  preview.buildHeader(element<HTMLElement>("preview-header"), element<HTMLElement>("preview-filter"));
  values.buildHeader(element<HTMLElement>("values-header"), element<HTMLElement>("values-filter"));
}

element<HTMLButtonElement>("pick").addEventListener("click", () => void pick());
element<HTMLButtonElement>("unlock").addEventListener("click", () => {
  void read(passwordField.value).catch((error) => say(tError("ui-read-failed", error), true));
});
passwordField.addEventListener("keydown", (event) => {
  if (event.key === "Enter") {
    event.preventDefault();
    void read(passwordField.value).catch((error) => say(tError("ui-read-failed", error), true));
  }
});
accountField.addEventListener("change", () => {
  showDetail();
  samples = null;
  valueRows = [];
  valueChoices.clear();
  void refreshPreview().catch((error) => say(tError("ui-read-failed", error), true));
});
for (const menu of [labelField, clearedField, notClearedField, scheduledField]) {
  menu.addEventListener("change", () => {
    void refreshPreview().catch((error) => say(tError("ui-read-failed", error), true));
  });
}
element<HTMLButtonElement>("next").addEventListener("click", () => void next());
element<HTMLButtonElement>("previous").addEventListener("click", () => previous());
element<HTMLButtonElement>("save").addEventListener("click", () => void save());
element<HTMLButtonElement>("close").addEventListener("click", () => void leave());
window.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    event.preventDefault();
    void leave();
  }
});

// Redemandée pour un autre compte : on repart de l'étape 1, sans fichier.
void listen<string>(PARAMETERS_EVENT, (event) => {
  reset();
  void openAccount(Number(new URLSearchParams(event.payload).get("account") ?? 0));
});

// Le clic droit des deux tableaux : copier, exporter, comme partout.
preview.exportOnRightClick(say);
values.exportOnRightClick(say);

void (async () => {
  await loadTexts(null);
  try {
    choices = await invoke<Choices>("mny_choices");
  } catch {
    choices = null;
  }
  dress();
  reset();
  const failure = await invoke<string | null>("startup_error").catch(() => null);
  if (failure) {
    say(failure, true);
    return;
  }
  await openAccount(Number(new URLSearchParams(window.location.search).get("account") ?? 0));
  onLanguageChanged(
    async () => {
      // Les exemples de l'étape 2 sont écrits par le noyau, dans la langue.
      if (samples !== null && handle() !== 0) {
        samples = await invoke<Samples>("mny_samples", { handle: handle() }).catch(() => samples);
      }
      dress();
      showStep(step);
      // L'aperçu et la barre viennent du noyau, dans la langue de l'interface.
      if (step <= 2) {
        await refreshPreview();
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
