// F45 — « Et si je réduisais… ? » (Fabrice, 10/10/2026).
//
// « Imaginer que l'on réduise en pourcentage ou en valeur les dépenses d'une
// ou plusieurs catégories et voir l'impact sur une projection dans le futur. »
//
// **La fenêtre ne calcule rien.** Elle envoie ce qui est coché et tapé ; le
// noyau lit l'historique, projette sans et avec les réductions, et rend tout
// écrit dans la langue — le tableau, les tuiles, la courbe, l'anneau.
//
// **Les réductions s'oublient à la fermeture** (Fabrice : « on oublie les
// chiffres à la fermeture de la fenêtre ») : la porte les efface avant de
// masquer la fenêtre, qui se rouvre vierge. Le rapport PDF les garde, et le
// projet en JSON aussi (Fabrice, 10/10/2026 : « rajoute enregistrement et
// chargement JSON et aussi export Excel ») — on le rouvre pour reprendre.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { save } from "@tauri-apps/plugin-dialog";
import { askThreeWays, askYesNo } from "./dialog";
import { asNumberField, guardFields } from "./money-field";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";
import { dressRange, fillRange, onRangeChange, rangeRequest, showRange } from "./period-range";

interface Account {
  id: number;
  label: string;
  bank: string;
  balance: string;
}

interface Choice {
  key: string;
  label: string;
}

interface Choices {
  accounts: Account[];
  histories: Choice[];
  years: number[];
  axes: Choice[];
  sign: string;
  hint: string;
}

interface Row {
  id: number;
  label: string;
  monthly: string;
  cut: string;
  after: string;
  yearly: string;
  capped: boolean;
  reduced: boolean;
}

interface Written {
  headline: string;
  tone: string;
  tiles: { label: string; value: string }[];
  rows: Row[];
  total: Row;
  target: string | null;
  years: string;
  chart: string;
  donut: string;
  notes: string[];
  period: string;
}

interface Result {
  invalid: string | null;
  message: string | null;
  written: Written | null;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

const field = (id: string): HTMLInputElement => element<HTMLInputElement>(id);

/// Les comptes suivis : tous, au départ.
const followed = new Set<number>();
let known = new Set<number>();
/// Les réductions tapées, par poste : leur texte et leur unité.
const cuts = new Map<number, { value: string; unit: string }>();
/// Les postes du tableau tel qu'il est bâti : tant qu'ils ne changent pas, on
/// met les cellules à jour sans toucher aux champs — celui qu'on tape garde
/// sa place et son curseur.
let shownIds = "";
let sign = "€";
/// La phrase d'un projet qu'on vient d'ouvrir : le calcul qui suit ne doit
/// pas l'effacer de la barre.
let pending: string | null = null;
/// Ce que disait la fenêtre au dernier projet enregistré ou ouvert : tant
/// qu'elle le dit encore, il n'y a rien à perdre en sortant.
let kept = "";
const state = (): string => JSON.stringify(request());

// --- Le calcul ------------------------------------------------------------------

let running = false;
let again = false;

function request(): Record<string, unknown> {
  return {
    accounts: [...followed],
    history: element<HTMLSelectElement>("history").value || "last-12",
    ...rangeRequest(),
    axis: element<HTMLSelectElement>("axis").value || "category",
    cuts: [...cuts].map(([id, cut]) => ({ id, value: cut.value, unit: cut.unit })),
    years: Number(field("years").value) || 5,
    rate: field("rate").value,
    target: field("target").value,
  };
}

function compute(): void {
  if (running) {
    again = true;
    return;
  }
  running = true;
  void (async () => {
    try {
      show(await invoke<Result>("cut_compute", { request: request() }));
    } catch (error) {
      say(tError("ui-read-failed", error), true);
    } finally {
      running = false;
      if (again) {
        again = false;
        compute();
      }
    }
  })();
}

// --- L'affichage ----------------------------------------------------------------

function show(result: Result): void {
  for (const marked of document.querySelectorAll(".form__field--invalid")) {
    marked.classList.remove("form__field--invalid");
  }
  // **Un calcul refusé n'a pas de résultat** (11/10/2026) : la réponse, les
  // colonnes calculées, la courbe et l'anneau d'avant s'estompent tant que le
  // champ n'est pas corrigé ; les champs, eux, restent nets.
  document.querySelector(".loan")?.classList.toggle("loan--stale", Boolean(result.invalid));
  if (result.invalid) {
    document.getElementById(result.invalid)?.classList.add("form__field--invalid");
    say(result.message ?? "", true);
    return;
  }
  const unavailable = element<HTMLElement>("unavailable");
  const analysis = element<HTMLElement>("analysis");
  if (!result.written) {
    unavailable.textContent = result.message ?? "";
    unavailable.hidden = false;
    analysis.hidden = true;
    return;
  }
  // La phrase sur l'historique (Fabrice, 10/10/2026) : la moyenne ne vaut que
  // ce que vaut l'historique, et l'utilisateur doit le savoir.
  say(pending ?? t("analysis-history-hint"));
  pending = null;
  unavailable.hidden = true;
  analysis.hidden = false;
  const written = result.written;

  element<HTMLElement>("answer").dataset.tone = written.tone;
  element<HTMLElement>("headline").textContent = written.headline;
  const target = element<HTMLElement>("target-text");
  target.textContent = written.target ?? "";
  target.hidden = written.target === null;
  element<HTMLElement>("years-text").textContent = written.years;

  const tiles = element<HTMLElement>("tiles");
  tiles.replaceChildren();
  for (const tile of written.tiles) {
    const box = document.createElement("div");
    box.className = "goal__tile";
    const label = document.createElement("span");
    label.className = "loan__tile-label";
    label.textContent = tile.label;
    const value = document.createElement("strong");
    value.className = "goal__tile-value";
    value.textContent = tile.value;
    box.append(label, value);
    tiles.append(box);
  }

  fillRows(written.rows);
  const total = element<HTMLElement>("total");
  total.replaceChildren();
  const line = document.createElement("tr");
  for (const [text, number] of [
    [written.total.label, false],
    [written.total.monthly, true],
    [written.total.cut, true],
    [written.total.after, true],
    [written.total.yearly, true],
  ] as const) {
    const cell = document.createElement("td");
    cell.textContent = text;
    if (number) {
      cell.className = "loan__number";
    }
    line.append(cell);
  }
  total.append(line);

  element<HTMLElement>("chart").innerHTML = written.chart;
  element<HTMLElement>("donut").innerHTML = written.donut;
  const notes = element<HTMLElement>("notes");
  notes.replaceChildren();
  for (const note of written.notes) {
    const item = document.createElement("li");
    item.textContent = note;
    notes.append(item);
  }
  element<HTMLElement>("period-text").textContent = written.period;
}

/// **Le tableau des postes.** Bâti quand les postes changent, mis à jour
/// sinon.
function fillRows(rows: Row[]): void {
  const body = element<HTMLElement>("rows");
  const ids = rows.map((row) => row.id).join(",");
  if (ids !== shownIds) {
    shownIds = ids;
    body.replaceChildren();
    for (const row of rows) {
      const line = document.createElement("tr");
      line.dataset.id = String(row.id);
      const name = document.createElement("td");
      name.className = "cut__name";
      const monthly = document.createElement("td");
      monthly.className = "loan__number";
      monthly.dataset.cell = "monthly";
      const cut = document.createElement("td");
      cut.className = "cut__cut";
      const input = document.createElement("input");
      input.className = "form__field cut__input";
      input.id = `cut-${row.id}`;
      // Un pourcentage ou un montant par mois, selon l'unité de la ligne :
      // des chiffres, deux décimales, jamais réécrit — « 10 » % reste « 10 ».
      asNumberField(input, 2);
      const unit = document.createElement("select");
      unit.className = "form__field cut__unit";
      unit.id = `unit-${row.id}`;
      for (const [value, text] of [
        ["percent", "%"],
        ["amount", sign],
      ]) {
        const option = document.createElement("option");
        option.value = value;
        option.textContent = text;
        unit.append(option);
      }
      const kept = cuts.get(row.id);
      input.value = kept?.value ?? "";
      unit.value = kept?.unit ?? "percent";
      const remember = (): void => {
        if (input.value.trim() === "") {
          cuts.delete(row.id);
        } else {
          cuts.set(row.id, { value: input.value, unit: unit.value });
        }
        compute();
      };
      input.addEventListener("change", remember);
      input.addEventListener("keydown", (event) => {
        if (event.key === "Enter") {
          input.blur();
        }
      });
      unit.addEventListener("change", remember);
      cut.append(input, unit);
      const after = document.createElement("td");
      after.className = "loan__number";
      after.dataset.cell = "after";
      const yearly = document.createElement("td");
      yearly.className = "loan__number cut__gain";
      yearly.dataset.cell = "yearly";
      line.append(name, monthly, cut, after, yearly);
      body.append(line);
    }
  }
  for (const row of rows) {
    const line = body.querySelector<HTMLElement>(`tr[data-id="${row.id}"]`);
    if (!line) {
      continue;
    }
    line.classList.toggle("cut__row--reduced", row.reduced);
    line.querySelector<HTMLElement>(".cut__name")!.textContent = row.label;
    line.querySelector<HTMLElement>('[data-cell="monthly"]')!.textContent = row.monthly;
    line.querySelector<HTMLElement>('[data-cell="after"]')!.textContent = row.after;
    line.querySelector<HTMLElement>('[data-cell="yearly"]')!.textContent = row.yearly;
    line.querySelector<HTMLElement>(".cut__input")!.classList.toggle("cut__input--capped", row.capped);
  }
}

// --- Les comptes et les choix ---------------------------------------------------

function fillAccounts(accounts: Account[]): void {
  const now = new Set(accounts.map((account) => account.id));
  for (const account of accounts) {
    if (!known.has(account.id)) {
      followed.add(account.id);
    }
  }
  for (const id of [...followed]) {
    if (!now.has(id)) {
      followed.delete(id);
    }
  }
  known = now;
  const body = element<HTMLElement>("accounts");
  body.replaceChildren();
  for (const account of accounts) {
    const row = document.createElement("tr");
    const cell = document.createElement("td");
    const check = document.createElement("input");
    check.type = "checkbox";
    check.dataset.account = String(account.id);
    check.checked = followed.has(account.id);
    check.addEventListener("change", () => {
      if (check.checked) {
        followed.add(account.id);
      } else {
        followed.delete(account.id);
      }
      compute();
    });
    cell.append(check);
    const name = document.createElement("td");
    name.textContent = account.label;
    if (account.bank) {
      name.title = account.bank;
    }
    const balance = document.createElement("td");
    balance.className = "loan__number";
    balance.textContent = account.balance;
    row.append(cell, name, balance);
    row.addEventListener("click", (event) => {
      if (event.target !== check) {
        check.click();
      }
    });
    body.append(row);
  }
}

function fillSelect(select: HTMLSelectElement, choices: Choice[], fallback: string): void {
  const chosen = select.value;
  select.replaceChildren();
  for (const choice of choices) {
    const option = document.createElement("option");
    option.value = choice.key;
    option.textContent = choice.label;
    select.append(option);
  }
  select.value = choices.some((choice) => choice.key === chosen) ? chosen : fallback;
}

async function loadChoices(): Promise<void> {
  const choices = await invoke<Choices>("cut_choices");
  const history = element<HTMLSelectElement>("history");
  const kept = history.value;
  fillSelect(history, choices.histories, "last-12");
  fillRange(choices.years, kept);
  fillSelect(element<HTMLSelectElement>("axis"), choices.axes, "category");
  sign = choices.sign;
  element<HTMLElement>("table-hint").textContent = choices.hint;
  for (const unit of document.querySelectorAll<HTMLElement>("[data-sign]")) {
    unit.textContent = choices.sign;
  }
  fillAccounts(choices.accounts);
}

// --- Les mots -------------------------------------------------------------------

function dress(): void {
  for (const [id, key] of [
    ["accounts-title", "goal-accounts-title"],
    ["history-label", "goal-period-label"],
    ["account-column", "goal-column-account"],
    ["balance-column", "goal-column-balance"],
    ["accounts-hint", "goal-accounts-hint"],
    ["settings-title", "cut-settings-title"],
    ["axis-label", "cut-axis-label"],
    ["horizon-label", "cut-horizon-label"],
    ["rate-label", "goal-field-rate"],
    ["rate-unit", "loan-unit-percent-year"],
    ["target-label", "goal-field-target"],
    ["options-hint", "cut-options-hint"],
    ["pdf-label", "cut-report-button"],
    ["open", "holiday-open"],
    ["save", "holiday-save"],
    ["excel", "holiday-excel"],
    ["table-title", "cut-table-title"],
    ["column-monthly", "cut-column-monthly"],
    ["column-cut", "cut-column-cut"],
    ["column-after", "cut-column-after"],
    ["column-yearly", "cut-column-yearly"],
    ["chart-title", "cut-chart-title"],
    ["chart-hint", "cut-chart-hint"],
    ["donut-title", "cut-donut-title"],
    ["disclaimer", "goal-disclaimer"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  dressRange();
  showAxisColumn();
  element<HTMLElement>("close").title = t("ui-title-close");
  element<HTMLElement>("pdf").title = t("cut-report-button");
}

/// La première colonne porte le nom du classement choisi.
function showAxisColumn(): void {
  const axis = element<HTMLSelectElement>("axis");
  element<HTMLElement>("column-item").textContent =
    axis.selectedOptions[0]?.textContent ?? t("cut-axis-category");
}

// --- Les gestes -----------------------------------------------------------------

element<HTMLSelectElement>("history").addEventListener("change", compute);
onRangeChange(compute);
element<HTMLSelectElement>("axis").addEventListener("change", () => {
  // Un autre classement, d'autres postes : les réductions tapées ne valent
  // plus rien.
  cuts.clear();
  shownIds = "";
  showAxisColumn();
  compute();
});
field("years").addEventListener("input", compute);
// **Les champs ne prennent que des chiffres** (Fabrice, 11/10/2026 : « on peut
// écrire des lettres dans un champ numérique, c'est pas bien du tout ») : le
// taux a trois décimales ; le montant visé est un montant, écrit proprement en
// sortant.
guardFields({ rate: 3, target: "money" });

for (const id of ["rate", "target"]) {
  field(id).addEventListener("change", compute);
  field(id).addEventListener("keydown", (event) => {
    if (event.key === "Enter") {
      field(id).blur();
    }
  });
}
/// Un nom de fichier sans ce que les systèmes refusent.
const fileName = (text: string): string => text.replace(/[\\/:*?\x22<>|…]/g, "").trim() || "Radinus";

/// Quelque chose est-il tapé, qu'un projet ouvert effacerait ?
const typed = (): boolean => cuts.size > 0 || field("rate").value.trim() !== "" || field("target").value.trim() !== "";

interface Opened {
  history: string;
  from: number;
  to: number;
  axis: string;
  years: number;
  rate: string;
  target: string;
  account_ids: number[];
  cuts: { id: number; value: string; unit: string }[];
  message: string;
}

/// Pose un projet rouvert dans la fenêtre : la période, le classement,
/// l'horizon, les options, les comptes et les réductions.
function place(opened: Opened): void {
  const history = element<HTMLSelectElement>("history");
  history.value = opened.history;
  if (history.value !== opened.history) {
    history.value = "last-12";
  }
  if (opened.history === "range") {
    element<HTMLSelectElement>("range-from").value = String(opened.from);
    element<HTMLSelectElement>("range-to").value = String(opened.to);
  }
  showRange();
  element<HTMLSelectElement>("axis").value = opened.axis;
  showAxisColumn();
  field("years").value = String(opened.years);
  field("rate").value = opened.rate;
  field("target").value = opened.target;
  followed.clear();
  for (const id of opened.account_ids) {
    followed.add(id);
  }
  for (const check of document.querySelectorAll<HTMLInputElement>("#accounts input")) {
    check.checked = followed.has(Number(check.dataset.account));
  }
  cuts.clear();
  for (const cut of opened.cuts) {
    cuts.set(cut.id, { value: cut.value, unit: cut.unit });
  }
  // Le tableau se rebâtit, et ses champs reprennent les réductions.
  shownIds = "";
}

element<HTMLButtonElement>("open").addEventListener("click", () => {
  void (async () => {
    if (typed() && !(await askYesNo(t("holiday-replace-question"), t("ui-yes"), t("ui-no")))) {
      return;
    }
    try {
      const opened = await invoke<Opened | null>("load_cut_project");
      if (!opened) {
        return;
      }
      place(opened);
      kept = state();
      pending = opened.message;
      say(opened.message);
      compute();
    } catch (error) {
      say(String(error), true);
    }
  })();
});

/// Enregistre le projet là où l'on choisit. Rend vrai s'il est écrit.
async function saveProject(): Promise<boolean> {
  const chosen = await save({
    defaultPath: `${fileName(t("window-cut-title"))}.json`,
    filters: [{ name: t("cut-file-filter"), extensions: ["json"] }],
  });
  if (chosen === null) {
    return false;
  }
  try {
    const now = state();
    say(await invoke<string>("save_cut_project", { request: request(), path: chosen }));
    kept = now;
    return true;
  } catch (error) {
    say(String(error), true);
    return false;
  }
}

element<HTMLButtonElement>("save").addEventListener("click", () => void saveProject());

element<HTMLButtonElement>("excel").addEventListener("click", () => {
  void (async () => {
    const chosen = await save({
      defaultPath: `${fileName(t("window-cut-title"))}.xlsx`,
      filters: [{ name: "XLSX", extensions: ["xlsx"] }],
    });
    if (chosen === null) {
      return;
    }
    try {
      say(await invoke<string>("export_cut", { request: request(), path: chosen }));
    } catch (error) {
      say(String(error), true);
    }
  })();
});

element<HTMLButtonElement>("pdf").addEventListener("click", () => {
  void (async () => {
    try {
      say(await invoke<string>("print_cut_report", { request: request() }));
    } catch (error) {
      say(String(error), true);
    }
  })();
});

/// **La porte efface tout ce qui a été tapé**, puis masque la fenêtre : elle
/// se rouvrira vierge.
///
/// **Avant, la question de la porte** (Fabrice, 10/10/2026 : « un clic sur
/// le bouton de sortie doit se faire avec un panneau de confirmation, même
/// genre que dans la classification rapide ») : enregistrer le projet,
/// abandonner, rester — posée seulement quand des chiffres tapés seraient
/// perdus, c'est-à-dire tapés et pas enregistrés depuis. Échap reste.
element<HTMLButtonElement>("close").addEventListener("click", () => {
  void (async () => {
    if (typed() && state() !== kept) {
      const answer = await askThreeWays(
        t("quick-leave-question"),
        t("quick-leave-save"),
        t("quick-leave-discard"),
        t("quick-leave-stay"),
      );
      if (answer === "stay" || (answer === "first" && !(await saveProject()))) {
        return;
      }
    }
    cuts.clear();
    shownIds = "";
    kept = "";
    field("rate").value = "";
    field("target").value = "";
    field("years").value = "5";
    compute();
    void invoke("close_spending_cut");
  })();
});

async function reload(): Promise<void> {
  await loadChoices();
  showAxisColumn();
  compute();
}
for (const event of ["data-changed:operations", "data-changed:accounts-list", "data-changed:spending-cut"]) {
  void listen(event, () => {
    void reload().catch(() => undefined);
  });
}
window.addEventListener("focus", () => {
  void reload().catch(() => undefined);
});

void (async () => {
  await loadTexts(null);
  dress();
  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    return;
  }
  try {
    await reload();
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
  onLanguageChanged(
    async () => {
      dress();
      await reload();
    },
    { key: "window-cut-title" },
  );
})();
