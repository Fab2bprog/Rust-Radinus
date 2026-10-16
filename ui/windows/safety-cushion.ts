// F43 — « Mon matelas de sécurité » (Fabrice, 09/10/2026).
//
// « Si mes revenus s'arrêtaient demain, combien de mois tiendrais-je avec mon
// épargne ? »
//
// **La fenêtre ne calcule rien.** Elle envoie ce qui est coché et tapé ; le
// noyau lit l'historique, calcule, et rend tout écrit dans la langue — la
// jauge, les seuils, la courbe.
//
// **Rien n'est mémorisé.** Les cases des comptes partent cochées d'après leur
// type (un compte chèque pour les dépenses, un livret pour l'épargne) ; la
// fenêtre est masquée et non détruite, donc ce qu'on a coché est encore là
// au retour, tant que Radinus tourne.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { guardFields } from "./money-field";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";
import { dressRange, fillRange, onRangeChange, rangeRequest } from "./period-range";

interface Account {
  id: number;
  label: string;
  bank: string;
  balance: string;
  savings: boolean;
  spending: boolean;
}

interface Choice {
  key: string;
  label: string;
}

interface Choices {
  accounts: Account[];
  histories: Choice[];
  years: number[];
  sign: string;
}

interface Written {
  verdict: string;
  tone: string;
  gauge: string;
  tiles: { label: string; value: string }[];
  targets: { title: string; status: string; reached: boolean }[];
  projection: string;
  categories: { id: number; label: string; monthly: string; kept: boolean }[];
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

/// Ce qui est coché. Un compte apparu depuis arrive avec ses cases d'office.
const savings = new Set<number>();
const spending = new Set<number>();
let known = new Set<number>();
/// Les catégories décochées, par leur clef : elles le restent quand la
/// période change.
const excluded = new Set<number>();

// --- Le calcul ------------------------------------------------------------------

let running = false;
let again = false;

function request(): Record<string, unknown> {
  return {
    savings: [...savings],
    spending: [...spending],
    history: element<HTMLSelectElement>("history").value || "last-12",
    ...rangeRequest(),
    excluded: [...excluded],
    backup: element<HTMLInputElement>("backup").value,
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
      show(await invoke<Result>("cushion_compute", { request: request() }));
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

const VERDICTS: Record<string, string> = { good: "green", warn: "orange", bad: "red" };

/// L'aiguille glisse d'une position à l'autre, comme celle du crédit.
let needleAngle: number | null = null;
let needleFrame = 0;

function placeGauge(svg: string): void {
  const holder = element<HTMLElement>("gauge");
  holder.innerHTML = svg;
  const needle = holder.querySelector<SVGGElement>(".gauge-needle");
  if (!needle) {
    return;
  }
  const target = Number(needle.dataset.angle ?? "0");
  const pivot = (needle.getAttribute("transform") ?? "").replace(/^rotate\(\s*[-\d.]+/, "");
  const from = needleAngle ?? 0;
  needleAngle = target;
  cancelAnimationFrame(needleFrame);
  const start = performance.now();
  const step = (now: number): void => {
    const progress = Math.min((now - start) / 450, 1);
    const eased = 1 - Math.pow(1 - progress, 3);
    needle.setAttribute("transform", `rotate(${(from + (target - from) * eased).toFixed(2)}${pivot}`);
    if (progress < 1) {
      needleFrame = requestAnimationFrame(step);
    }
  };
  needle.setAttribute("transform", `rotate(${from.toFixed(2)}${pivot}`);
  needleFrame = requestAnimationFrame(step);
}

function show(result: Result): void {
  const backup = element<HTMLInputElement>("backup");
  backup.classList.toggle("form__field--invalid", result.invalid === "backup");
  const unavailable = element<HTMLElement>("unavailable");
  const analysis = element<HTMLElement>("analysis");
  // **Un calcul refusé n'a pas de résultat** (11/10/2026) : l'analyse d'avant
  // s'estompe tant que le champ n'est pas corrigé.
  document.querySelector(".loan")?.classList.toggle("loan--stale", Boolean(result.invalid));
  if (result.invalid) {
    say(result.message ?? "", true);
    return;
  }
  if (!result.written) {
    unavailable.textContent = result.message ?? "";
    unavailable.hidden = false;
    analysis.hidden = true;
    fillCategories([]);
    return;
  }
  // La phrase sur l'historique (Fabrice, 10/10/2026) : la moyenne ne vaut que
  // ce que vaut l'historique, et l'utilisateur doit le savoir.
  say(t("analysis-history-hint"));
  unavailable.hidden = true;
  analysis.hidden = false;
  const written = result.written;

  element<HTMLElement>("verdict").dataset.verdict = VERDICTS[written.tone] ?? "green";
  element<HTMLElement>("verdict-text").textContent = written.verdict;
  placeGauge(written.gauge);

  const tiles = element<HTMLElement>("tiles");
  tiles.replaceChildren();
  for (const tile of written.tiles) {
    const term = document.createElement("dt");
    term.textContent = tile.label;
    const value = document.createElement("dd");
    value.textContent = tile.value;
    tiles.append(term, value);
  }

  // Les seuils : sans dépenses à couvrir, il n'y en a pas.
  element<HTMLElement>("targets-card").hidden = written.targets.length === 0;
  const targets = element<HTMLElement>("targets");
  targets.replaceChildren();
  for (const target of written.targets) {
    const item = document.createElement("li");
    item.dataset.tone = target.reached ? "good" : "warn";
    const title = document.createElement("strong");
    title.textContent = target.title;
    const status = document.createElement("span");
    status.textContent = target.status;
    item.append(title, status);
    targets.append(item);
  }

  element<HTMLElement>("projection").innerHTML = written.projection;
  element<HTMLElement>("period").textContent = written.period;
  fillCategories(written.categories);
}

/// Les catégories, la plus lourde d'abord, chacune avec sa case.
function fillCategories(categories: Written["categories"]): void {
  const list = element<HTMLElement>("categories");
  list.replaceChildren();
  for (const category of categories) {
    const item = document.createElement("li");
    const label = document.createElement("label");
    const check = document.createElement("input");
    check.type = "checkbox";
    check.checked = category.kept;
    check.dataset.category = String(category.id);
    check.addEventListener("change", () => {
      if (check.checked) {
        excluded.delete(category.id);
      } else {
        excluded.add(category.id);
      }
      compute();
    });
    const name = document.createElement("span");
    name.className = "cushion__category-name";
    name.textContent = category.label;
    const amount = document.createElement("span");
    amount.className = "loan__number cushion__category-amount";
    amount.textContent = category.monthly;
    label.append(check, name, amount);
    item.classList.toggle("cushion__category--off", !category.kept);
    item.append(label);
    list.append(item);
  }
  element<HTMLElement>("categories-empty").hidden = categories.length > 0;
}

// --- Les comptes et les périodes ------------------------------------------------

function fillAccounts(accounts: Account[]): void {
  const now = new Set(accounts.map((account) => account.id));
  for (const account of accounts) {
    if (!known.has(account.id)) {
      if (account.savings) {
        savings.add(account.id);
      }
      if (account.spending) {
        spending.add(account.id);
      }
    }
  }
  for (const set of [savings, spending]) {
    for (const id of [...set]) {
      if (!now.has(id)) {
        set.delete(id);
      }
    }
  }
  known = now;

  const body = element<HTMLElement>("accounts");
  body.replaceChildren();
  for (const account of accounts) {
    const row = document.createElement("tr");
    const name = document.createElement("td");
    name.textContent = account.label;
    if (account.bank) {
      name.title = account.bank;
    }
    const balance = document.createElement("td");
    balance.className = "loan__number";
    balance.textContent = account.balance;
    row.append(name, balance);
    for (const [set, role] of [
      [savings, "savings"],
      [spending, "spending"],
    ] as const) {
      const cell = document.createElement("td");
      cell.className = "cushion__tick";
      const check = document.createElement("input");
      check.type = "checkbox";
      check.dataset.role = role;
      check.dataset.account = String(account.id);
      check.checked = set.has(account.id);
      check.addEventListener("change", () => {
        if (check.checked) {
          set.add(account.id);
        } else {
          set.delete(account.id);
        }
        compute();
      });
      cell.append(check);
      row.append(cell);
    }
    body.append(row);
  }
}

async function loadChoices(): Promise<void> {
  const choices = await invoke<Choices>("cushion_choices");
  const history = element<HTMLSelectElement>("history");
  const chosen = history.value;
  history.replaceChildren();
  for (const choice of choices.histories) {
    const option = document.createElement("option");
    option.value = choice.key;
    option.textContent = choice.label;
    history.append(option);
  }
  if (choices.histories.some((choice) => choice.key === chosen)) {
    history.value = chosen;
  }
  fillRange(choices.years, chosen);
  element<HTMLElement>("sign").textContent = choices.sign;
  fillAccounts(choices.accounts);
}

// --- Les mots -------------------------------------------------------------------

function dress(): void {
  for (const [id, key] of [
    ["question", "cushion-question"],
    ["accounts-title", "cushion-accounts-title"],
    ["history-label", "cushion-history-label"],
    ["account-column", "cushion-column-account"],
    ["balance-column", "cushion-column-balance"],
    ["savings-column", "cushion-column-savings"],
    ["spending-column", "cushion-column-spending"],
    ["accounts-hint", "cushion-accounts-hint"],
    ["backup-label", "cushion-backup-label"],
    ["backup-hint", "cushion-backup-hint"],
    ["categories-title", "cushion-categories-title"],
    ["categories-hint", "cushion-categories-hint"],
    ["categories-empty", "cushion-categories-empty"],
    ["verdict-title", "cushion-verdict-title"],
    ["targets-title", "cushion-targets-title"],
    ["projection-title", "cushion-projection-title"],
    ["projection-hint", "cushion-projection-hint"],
    ["note", "cushion-note"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  dressRange();
  element<HTMLElement>("close").title = t("ui-title-close");
}

// --- Les gestes -----------------------------------------------------------------

element<HTMLSelectElement>("history").addEventListener("change", compute);
onRangeChange(compute);
// **Le revenu de secours ne prend que des chiffres** (Fabrice, 11/10/2026 :
// « on peut écrire des lettres dans un champ numérique, c'est pas bien du
// tout ») : un montant, sans signe, écrit proprement en sortant, et vide —
// aucun revenu — reste vide.
guardFields({ backup: "money" });
const backupField = element<HTMLInputElement>("backup");
backupField.addEventListener("change", compute);
backupField.addEventListener("keydown", (event) => {
  if (event.key === "Enter") {
    backupField.blur();
  }
});
element<HTMLButtonElement>("close").addEventListener("click", () => {
  void invoke("close_safety_cushion");
});

// L'historique a pu bouger pendant que la fenêtre attendait, ou la base
// entière sous elle : on relit les comptes et on recalcule.
async function reload(): Promise<void> {
  await loadChoices();
  compute();
}
for (const event of ["data-changed:operations", "data-changed:accounts-list", "data-changed:safety-cushion"]) {
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
    { key: "window-cushion-title" },
  );
})();
