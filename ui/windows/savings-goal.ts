// F44 — « Objectif Épargne » (Fabrice, 10/10/2026).
//
// « Si je continue au rythme actuel, dans combien de temps aurai-je tel solde
// et combien aurai-je épargné ? Ou à l'inverse : combien de temps épargner
// pour arriver à tel montant ? »
//
// **La fenêtre ne calcule rien.** Elle envoie ce qui est coché et tapé ; le
// noyau lit l'historique, projette, et rend la réponse écrite dans la langue,
// avec sa courbe. Rien n'est mémorisé : la fenêtre est masquée et non
// détruite, donc la question posée est encore là au retour, tant que Radinus
// tourne.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { guardFields } from "./money-field";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

interface Account {
  id: number;
  label: string;
  bank: string;
  balance: string;
  ticked: boolean;
}

interface Choices {
  accounts: Account[];
  histories: { key: string; label: string }[];
  years: number[];
  months: string[];
  month: number;
  year: number;
  sign: string;
}

interface Written {
  headline: string;
  range: string | null;
  tone: string;
  tiles: { label: string; value: string }[];
  chart: string;
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

const FIELDS = ["target", "year", "rate", "extra"];
const field = (id: string): HTMLInputElement => element<HTMLInputElement>(id);

/// Les comptes suivis. Un compte apparu depuis arrive avec sa case d'office.
const followed = new Set<number>();
let known = new Set<number>();
let filled = false;

function question(): string {
  return document.querySelector<HTMLInputElement>('input[name="question"]:checked')?.value ?? "when";
}

/// Chaque question montre ses champs : le montant pour « quand » et
/// « combien épargner », la date pour « combien aurai-je » et « combien
/// épargner ». L'effort de plus n'a pas de sens quand c'est lui qu'on cherche.
function showQuestion(): void {
  const asked = question();
  element<HTMLElement>("target-line").hidden = asked === "amount";
  element<HTMLElement>("date-line").hidden = asked === "when";
  element<HTMLElement>("extra-line").hidden = asked === "effort";
}

function showRange(): void {
  element<HTMLElement>("range").hidden = element<HTMLSelectElement>("period").value !== "range";
}

// --- Le calcul ------------------------------------------------------------------

let running = false;
let again = false;

function request(): Record<string, unknown> {
  return {
    accounts: [...followed],
    period: element<HTMLSelectElement>("period").value || "last-12",
    from: Number(element<HTMLSelectElement>("range-from").value) || 0,
    to: Number(element<HTMLSelectElement>("range-to").value) || 0,
    question: question(),
    target: field("target").value,
    month: Number(element<HTMLSelectElement>("month").value) || 1,
    year: field("year").value,
    rate: field("rate").value,
    extra: question() === "effort" ? "" : field("extra").value,
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
      show(await invoke<Result>("goal_compute", { request: request() }));
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
  for (const id of FIELDS) {
    field(id).classList.toggle("form__field--invalid", result.invalid === id);
  }
  const unavailable = element<HTMLElement>("unavailable");
  const analysis = element<HTMLElement>("analysis");
  if (result.invalid || !result.written) {
    unavailable.textContent = result.message ?? "";
    unavailable.hidden = false;
    analysis.hidden = true;
    return;
  }
  // La phrase sur l'historique (Fabrice, 10/10/2026) : la moyenne ne vaut que
  // ce que vaut l'historique, et l'utilisateur doit le savoir.
  say(t("analysis-history-hint"));
  unavailable.hidden = true;
  analysis.hidden = false;
  const written = result.written;

  element<HTMLElement>("answer").dataset.tone = written.tone;
  element<HTMLElement>("headline").textContent = written.headline;
  const range = element<HTMLElement>("range-text");
  range.textContent = written.range ?? "";
  range.hidden = written.range === null;

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

  element<HTMLElement>("chart").innerHTML = written.chart;
  const notes = element<HTMLElement>("notes");
  notes.replaceChildren();
  for (const note of written.notes) {
    const item = document.createElement("li");
    item.textContent = note;
    notes.append(item);
  }
  element<HTMLElement>("period-text").textContent = written.period;
}

// --- Les comptes, les périodes, la date -----------------------------------------

function fillAccounts(accounts: Account[]): void {
  const now = new Set(accounts.map((account) => account.id));
  for (const account of accounts) {
    if (!known.has(account.id) && account.ticked) {
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
    // Un clic sur la ligne coche la case, comme dans la simulation de crédit.
    row.addEventListener("click", (event) => {
      if (event.target !== check) {
        check.click();
      }
    });
    body.append(row);
  }
}

function fillSelect(select: HTMLSelectElement, options: [string, string][]): void {
  const chosen = select.value;
  select.replaceChildren();
  for (const [value, label] of options) {
    const option = document.createElement("option");
    option.value = value;
    option.textContent = label;
    select.append(option);
  }
  if (options.some(([value]) => value === chosen)) {
    select.value = chosen;
  }
}

async function loadChoices(): Promise<void> {
  const choices = await invoke<Choices>("goal_choices");
  fillSelect(element<HTMLSelectElement>("period"), [
    ...choices.histories.map((choice): [string, string] => [choice.key, choice.label]),
    ["range", t("goal-period-range")],
  ]);
  const years = choices.years.map((year): [string, string] => [String(year), String(year)]);
  const from = element<HTMLSelectElement>("range-from");
  const to = element<HTMLSelectElement>("range-to");
  fillSelect(from, [...years].reverse());
  fillSelect(to, years);
  fillSelect(
    element<HTMLSelectElement>("month"),
    choices.months.map((name, rank): [string, string] => [String(rank + 1), name]),
  );
  // La première fois seulement : la date visée proposée est dans un an, et la
  // plage par défaut couvre les trois dernières années.
  if (!filled) {
    filled = true;
    element<HTMLSelectElement>("month").value = String(choices.month);
    field("year").value = String(choices.year);
    from.value = String(choices.years[Math.min(2, choices.years.length - 1)]);
    to.value = String(choices.years[0]);
  }
  for (const sign of document.querySelectorAll<HTMLElement>("[data-sign]")) {
    sign.textContent = choices.sign;
  }
  fillAccounts(choices.accounts);
  showRange();
}

// --- Les mots -------------------------------------------------------------------

function dress(): void {
  for (const [id, key] of [
    ["accounts-title", "goal-accounts-title"],
    ["period-label", "goal-period-label"],
    ["range-from-label", "goal-range-from"],
    ["range-to-label", "goal-range-to"],
    ["account-column", "goal-column-account"],
    ["balance-column", "goal-column-balance"],
    ["accounts-hint", "goal-accounts-hint"],
    ["question-title", "goal-question-title"],
    ["question-when", "goal-question-when"],
    ["question-amount", "goal-question-amount"],
    ["question-effort", "goal-question-effort"],
    ["target-label", "goal-field-target"],
    ["date-label", "goal-field-date"],
    ["rate-label", "goal-field-rate"],
    ["rate-unit", "loan-unit-percent-year"],
    ["extra-label", "goal-field-extra"],
    ["options-hint", "goal-options-hint"],
    ["answer-title", "goal-answer-title"],
    ["chart-title", "goal-chart-title"],
    ["chart-hint", "goal-chart-hint"],
    ["disclaimer", "goal-disclaimer"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  element<HTMLElement>("close").title = t("ui-title-close");
}

// --- Les gestes -----------------------------------------------------------------

for (const radio of document.querySelectorAll<HTMLInputElement>('input[name="question"]')) {
  radio.addEventListener("change", () => {
    showQuestion();
    compute();
  });
}
element<HTMLSelectElement>("period").addEventListener("change", () => {
  showRange();
  compute();
});
for (const id of ["range-from", "range-to", "month"]) {
  element<HTMLSelectElement>(id).addEventListener("change", compute);
}
// **Les champs ne prennent que des chiffres** (Fabrice, 11/10/2026 : « on peut
// écrire des lettres dans un champ numérique, c'est pas bien du tout ») : le
// montant visé et l'épargne en plus sont des montants, écrits proprement en
// sortant ; l'année est un nombre entier ; le taux a trois décimales.
guardFields({ target: "money", year: 0, rate: 3, extra: "money" });

for (const id of FIELDS) {
  // Un champ compte à la validation — Entrée ou la sortie du champ.
  field(id).addEventListener("change", compute);
  field(id).addEventListener("keydown", (event) => {
    if (event.key === "Enter") {
      field(id).blur();
    }
  });
}
element<HTMLButtonElement>("close").addEventListener("click", () => {
  void invoke("close_savings_goal");
});

// L'historique a pu bouger pendant que la fenêtre attendait, ou la base
// entière sous elle : on relit les comptes et on recalcule.
async function reload(): Promise<void> {
  await loadChoices();
  compute();
}
for (const event of ["data-changed:operations", "data-changed:accounts-list", "data-changed:savings-goal"]) {
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
  showQuestion();
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
    { key: "window-goal-title" },
  );
})();
