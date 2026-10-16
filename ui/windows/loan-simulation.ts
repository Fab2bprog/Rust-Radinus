// F41 — « Simulation de crédit » (Fabrice, 08/10/2026).
//
// « Calculer un crédit c'est bien, mais […] j'aimerais que lorsqu'elle calcule
// son crédit il y ait des éléments d'information qui lui permettent de
// réfléchir pour savoir si c'est jouable ou pas et dans quelle mesure. »
//
// **La fenêtre ne calcule rien et n'écrit rien.** Elle envoie ses champs tels
// qu'ils sont tapés, et le noyau rend tout : les trois curseurs mis d'accord,
// les chiffres déjà écrits dans la langue, le tableau d'amortissement, et les
// graphiques en SVG — les mêmes que ceux du rapport PDF, au trait près.
//
// **Les trois curseurs se répondent** (« lorsque l'on bouge un curseur l'autre
// bouge automatiquement ») : le montant ou la durée bougent, la mensualité
// suit ; la mensualité bouge, la durée suit, au mois entier. C'est le noyau qui
// tient la règle ; la fenêtre dit seulement lequel a bougé.
//
// **Rien n'est enregistré** : une calculette. La fenêtre est masquée et non
// détruite quand on la quitte, donc la simulation est encore là au retour,
// tant que Radinus tourne.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { Table } from "./table";
import { guardFields } from "./money-field";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";
import { dressRange, fillRange, onRangeChange, rangeRequest } from "./period-range";

interface Figure {
  label: string;
  value: string;
  tone: string;
}

interface Due {
  number: number;
  date: string;
  date_value: string;
  payment: string;
  interest: string;
  capital: string;
  insurance: string;
  remaining: string;
  payment_value: number;
  interest_value: number;
  capital_value: number;
  insurance_value: number;
  remaining_value: number;
}

interface Running {
  label: string;
  monthly: string;
  end: string;
}

interface Analysis {
  verdict: string;
  verdict_word: string;
  checks: { tone: string; text: string }[];
  method_key: string;
  method_line: string;
  methods: {
    key: string;
    name: string;
    verdict: string;
    verdict_word: string;
    values: string[];
    growth: number;
    explanation: string;
  }[];
  rule_rows: string[];
  rules_intro: string;
  verdicts_line: string;
  warning: string | null;
  gauge: string;
  figures: Figure[];
  income_donut: string;
  bars: string;
  projection: string;
  loans: Running[];
  loans_empty: string;
  period: string;
  transfers: string;
  method: string;
}

interface Loan {
  invalid: string | null;
  kind: string;
  amount_field: string;
  payment_field: string;
  rate_field: string;
  fees_field: string;
  insurance_field: string;
  months: number;
  months_text: string;
  amount_euros: number;
  amount_min: number;
  amount_max: number;
  amount_step: number;
  months_min: number;
  months_max: number;
  payment_euros: number;
  payment_min: number;
  payment_max: number;
  notice: string | null;
  figures: Figure[];
  dues: Due[];
  cost_donut: string;
  capital_curve: string;
  analysis: Analysis | null;
  unavailable: string | null;
}

interface Choice {
  key: string;
  label: string;
}

interface Account {
  id: number;
  label: string;
  bank: string;
  balance: string;
  balance_value: number;
}

interface Choices {
  kinds: Choice[];
  histories: Choice[];
  years: number[];
  accounts: Account[];
  sign: string;
}

interface Defaults {
  amount: string;
  months: string;
  rate: string;
  fees: string;
  insurance: string;
}

type Field = "amount" | "payment" | "months" | "rate" | "fees" | "insurance";

/// Les trois méthodes de jugement, dans l'ordre du tableau (Fabrice,
/// 08/10/2026). La neutre est cochée à l'ouverture ; rien n'est mémorisé.
const METHODS = ["optimistic", "neutral", "severe"] as const;

function chosenMethod(): string {
  return (
    document.querySelector<HTMLInputElement>('input[name="method"]:checked')?.value ?? "neutral"
  );
}
const FIELDS: Field[] = ["amount", "payment", "months", "rate", "fees", "insurance"];

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

const field = (name: Field): HTMLInputElement => element<HTMLInputElement>(name);
const range = (name: "amount" | "payment" | "months"): HTMLInputElement =>
  element<HTMLInputElement>(`${name}-range`);

/// Les comptes cochés. **Tous à l'ouverture** : c'est le cas le plus courant,
/// et décocher se fait d'un clic. Un compte apparu depuis arrive coché.
const ticked = new Set<number>();
let knownAccounts = new Set<number>();
let shown: Loan | null = null;

/// Le champ qu'on est en train de taper, s'il y en a un : un calcul revenu
/// entre-temps ne le réécrit pas sous les doigts. Et le curseur qu'on tient :
/// le noyau arrondit la durée au mois entier, et le curseur de la mensualité
/// sauterait sous la main s'il suivait chaque réponse — il se recale au
/// relâchement.
let editing: Field | null = null;
let sliding: string | null = null;

// --- Le calcul --------------------------------------------------------------

/// **Un seul calcul à la fois, et toujours le dernier demandé.** Un curseur
/// qu'on fait glisser envoie des dizaines de valeurs par seconde : on ne les
/// empile pas, on garde la plus récente et on la lance dès que la précédente
/// est revenue. Le curseur ne traîne jamais derrière la main.
let running = false;
let waiting: string | null = null;

function request(moved: string): Record<string, unknown> {
  return {
    kind: element<HTMLSelectElement>("kind").value,
    amount: field("amount").value,
    payment: field("payment").value,
    months: field("months").value,
    rate: field("rate").value,
    fees: field("fees").value,
    insurance: field("insurance").value,
    moved,
    accounts: [...ticked],
    history: element<HTMLSelectElement>("history").value || "last-12",
    ...rangeRequest(),
    method: chosenMethod(),
    growth: METHODS.map((method) => element<HTMLInputElement>(`growth-${method}`).value),
  };
}

function simulate(moved: string): void {
  if (running) {
    waiting = moved;
    return;
  }
  running = true;
  void (async () => {
    try {
      const loan = await invoke<Loan>("loan_simulate", { request: request(moved) });
      show(loan);
    } catch (error) {
      say(tError("ui-read-failed", error), true);
    } finally {
      running = false;
      if (waiting !== null) {
        const next = waiting;
        waiting = null;
        simulate(next);
      }
    }
  })();
}

// --- L'affichage ------------------------------------------------------------

/// Un curseur réglé sur ses bornes, et posé sur sa valeur — **en butée** quand
/// la valeur tapée est au-delà.
function setRange(input: HTMLInputElement, min: number, max: number, step: number, value: number): void {
  input.min = String(min);
  input.max = String(max);
  input.step = String(step);
  input.value = String(Math.min(Math.max(value, min), max));
}

/// L'aiguille de la jauge **glisse** d'une position à l'autre au lieu de
/// sauter (« quand on bouge un curseur, l'aiguille de la jauge glisse »).
/// L'angle vient du noyau, en `data-angle` ; la fenêtre ne fait que
/// l'interpoler.
let needleAngle: number | null = null;
let needleFrame = 0;

function placeGauge(svg: string): void {
  const holder = element<HTMLElement>("gauge");
  holder.innerHTML = svg;
  const needle = holder.querySelector<SVGGElement>(".gauge-needle");
  if (!needle) {
    needleAngle = null;
    return;
  }
  const target = Number(needle.dataset.angle ?? "0");
  const transform = needle.getAttribute("transform") ?? "";
  const pivot = transform.replace(/^rotate\(\s*[-\d.]+/, "");
  const from = needleAngle ?? 0;
  needleAngle = target;
  cancelAnimationFrame(needleFrame);
  const start = performance.now();
  const duration = 450;
  const step = (now: number): void => {
    const progress = Math.min((now - start) / duration, 1);
    const eased = 1 - Math.pow(1 - progress, 3);
    const angle = from + (target - from) * eased;
    needle.setAttribute("transform", `rotate(${angle.toFixed(2)}${pivot}`);
    if (progress < 1) {
      needleFrame = requestAnimationFrame(step);
    }
  };
  needle.setAttribute("transform", `rotate(${from.toFixed(2)}${pivot}`);
  needleFrame = requestAnimationFrame(step);
}

/// Les chiffres d'une rangée de tuiles. Une valeur qui change s'éclaire un
/// instant : l'œil voit ce que le geste a bougé.
function fillFigures(holder: HTMLElement, figures: Figure[], tag: "div" | "dl"): void {
  const before = new Map<string, string>();
  for (const node of holder.querySelectorAll<HTMLElement>("[data-label]")) {
    before.set(node.dataset.label ?? "", node.textContent ?? "");
  }
  holder.replaceChildren();
  for (const figure of figures) {
    if (tag === "div") {
      const tile = document.createElement("div");
      tile.className = "loan__tile";
      const label = document.createElement("span");
      label.className = "loan__tile-label";
      label.textContent = figure.label;
      const value = document.createElement("strong");
      value.className = "loan__tile-value";
      value.dataset.label = figure.label;
      value.textContent = figure.value;
      if (before.has(figure.label) && before.get(figure.label) !== figure.value) {
        value.classList.add("loan__changed");
      }
      tile.append(label, value);
      holder.append(tile);
    } else {
      const term = document.createElement("dt");
      term.textContent = figure.label;
      const value = document.createElement("dd");
      value.dataset.label = figure.label;
      value.dataset.tone = figure.tone;
      value.textContent = figure.value;
      if (before.has(figure.label) && before.get(figure.label) !== figure.value) {
        value.classList.add("loan__changed");
      }
      holder.append(term, value);
    }
  }
}

function placeRanges(loan: Loan): void {
  if (sliding !== "amount") {
    setRange(range("amount"), loan.amount_min, loan.amount_max, loan.amount_step, loan.amount_euros);
  }
  if (sliding !== "months") {
    setRange(range("months"), loan.months_min, loan.months_max, 1, loan.months);
  }
  if (sliding !== "payment") {
    setRange(range("payment"), loan.payment_min, loan.payment_max, 1, loan.payment_euros);
  }
}

function show(loan: Loan): void {
  for (const marked of document.querySelectorAll(".form__field--invalid")) {
    marked.classList.remove("form__field--invalid");
  }
  // **Un calcul refusé n'a pas de résultat** (11/10/2026) : ce qu'affichaient
  // les onglets venait des chiffres d'avant, et s'estompe tant que le champ
  // refusé n'est pas corrigé, plutôt que de rester affiché comme s'il était
  // juste.
  document.querySelector(".loan")?.classList.toggle("loan--stale", Boolean(loan.invalid));
  if (loan.invalid) {
    // Le nom du champ refusé est aussi son identifiant : « amount »,
    // « growth-severe »…
    document.getElementById(loan.invalid)?.classList.add("form__field--invalid");
    say(t("loan-invalid-field"), true);
    return;
  }
  // La phrase sur l'historique (Fabrice, 10/10/2026) : la moyenne ne vaut que
  // ce que vaut l'historique, et l'utilisateur doit le savoir.
  say(t("analysis-history-hint"));
  shown = loan;

  // Les champs reprennent ce que le noyau a retenu — sauf celui qu'on est en
  // train de taper.
  const values: Record<Field, string> = {
    amount: loan.amount_field,
    payment: loan.payment_field,
    months: String(loan.months),
    rate: loan.rate_field,
    fees: loan.fees_field,
    insurance: loan.insurance_field,
  };
  for (const name of FIELDS) {
    if (name !== editing) {
      field(name).value = values[name];
    }
  }
  placeRanges(loan);
  element<HTMLElement>("monthly-line").hidden = loan.kind !== "mortgage";

  const notice = element<HTMLElement>("notice");
  notice.hidden = loan.notice === null;
  notice.textContent = loan.notice ?? "";

  fillFigures(element<HTMLElement>("tiles"), loan.figures, "div");
  element<HTMLElement>("cost-chart").innerHTML = loan.cost_donut;
  element<HTMLElement>("capital-chart").innerHTML = loan.capital_curve;
  schedule.setRows(loan.dues);

  const analysis = loan.analysis;
  element<HTMLElement>("unavailable").hidden = analysis !== null;
  element<HTMLElement>("unavailable").textContent = loan.unavailable ?? "";
  element<HTMLElement>("analysis").hidden = analysis === null;
  if (analysis) {
    element<HTMLElement>("verdict").dataset.verdict = analysis.verdict;
    element<HTMLElement>("verdict-word").textContent = analysis.verdict_word;
    const checks = element<HTMLElement>("checks");
    checks.replaceChildren();
    for (const check of analysis.checks) {
      const item = document.createElement("li");
      item.dataset.tone = check.tone;
      item.textContent = check.text;
      checks.append(item);
    }
    element<HTMLElement>("method-line").textContent = analysis.method_line;
    showRules(analysis);
    const warning = element<HTMLElement>("warning");
    warning.hidden = analysis.warning === null;
    warning.textContent = analysis.warning ?? "";
    placeGauge(analysis.gauge);
    fillFigures(element<HTMLElement>("figures"), analysis.figures, "dl");
    element<HTMLElement>("income-chart").innerHTML = analysis.income_donut;
    element<HTMLElement>("bars-chart").innerHTML = analysis.bars;
    element<HTMLElement>("projection-chart").innerHTML = analysis.projection;
    element<HTMLElement>("period").textContent = analysis.period;
    element<HTMLElement>("transfers").textContent = analysis.transfers;
    element<HTMLElement>("method").textContent = analysis.method;
    const body = element<HTMLElement>("running");
    body.replaceChildren();
    for (const loanRow of analysis.loans) {
      const row = document.createElement("tr");
      for (const [text, numeric] of [
        [loanRow.label, false],
        [loanRow.monthly, true],
        [loanRow.end, true],
      ] as [string, boolean][]) {
        const cell = document.createElement("td");
        cell.textContent = text;
        if (numeric) {
          cell.className = "loan__number";
        }
        row.append(cell);
      }
      body.append(row);
    }
    element<HTMLElement>("running-table").hidden = analysis.loans.length === 0;
    element<HTMLElement>("running-empty").hidden = analysis.loans.length > 0;
    element<HTMLElement>("running-empty").textContent = analysis.loans_empty;
  } else {
    needleAngle = null;
  }
  element<HTMLElement>("rules").hidden = analysis === null;
  element<HTMLElement>("explanation").hidden = analysis === null;
  element<HTMLElement>("rules-unavailable").hidden = analysis !== null;
  element<HTMLElement>("rules-unavailable").textContent = loan.unavailable ?? "";
}

/// **L'onglet « Réglages du jugement »** : le tableau des trois méthodes,
/// écrit par le noyau avec les chiffres de la personne. Le tableau est bâti
/// une fois dans la page ; on n'y change que les mots, pour qu'un champ en
/// cours de frappe ne soit pas recréé sous les doigts.
function showRules(analysis: Analysis): void {
  element<HTMLElement>("rules-intro").textContent = analysis.rules_intro;
  const rows = element<HTMLElement>("rules").querySelectorAll<HTMLElement>("tbody tr");
  rows.forEach((row, rank) => {
    const label = row.querySelector<HTMLElement>(".loan__rules-label");
    if (label) {
      label.textContent = analysis.rule_rows[rank] ?? "";
    }
  });
  for (const method of analysis.methods) {
    const head = document.querySelector<HTMLElement>(`.loan__rules-head[data-method="${method.key}"]`);
    if (head) {
      head.querySelector<HTMLElement>(".loan__method-name")!.textContent = method.name;
      const badge = head.querySelector<HTMLElement>(".loan__badge")!;
      badge.textContent = method.verdict_word;
      badge.dataset.verdict = method.verdict;
    }
    method.values.forEach((value, rank) => {
      const cell = document.querySelector<HTMLElement>(
        `#rules tr[data-row="${rank}"] td[data-method="${method.key}"]`,
      );
      if (cell) {
        cell.textContent = value;
      }
    });
    const growth = element<HTMLInputElement>(`growth-${method.key}`);
    if (document.activeElement !== growth) {
      growth.value = String(method.growth);
    }
  }
  // La colonne retenue se détache, et sa phrase dit ce qu'elle suppose.
  for (const cell of document.querySelectorAll<HTMLElement>("#rules [data-method]")) {
    cell.classList.toggle("loan__rules-chosen", cell.dataset.method === analysis.method_key);
  }
  const radio = document.querySelector<HTMLInputElement>(
    `input[name="method"][value="${analysis.method_key}"]`,
  );
  if (radio) {
    radio.checked = true;
  }
  element<HTMLElement>("explanation").textContent =
    analysis.methods.find((method) => method.key === analysis.method_key)?.explanation ?? "";
}

// --- Le tableau d'amortissement -----------------------------------------------

const schedule = new Table<Due>({
  container: element<HTMLDivElement>("rows"),
  virtualized: true,
  rowHeight: 24,
  // Ses colonnes se règlent comme celles des autres tableaux (Fabrice,
  // 08/10/2026 : « copie, export et colonnes réglables »).
  layoutName: "loan-simulation",
  identity: (row) => row.number,
  emptyText: () => "",
  filteredOutText: () => t("ui-no-match"),
  exportAs: () => ({
    name: t("loan-schedule-title"),
    detail: shown?.months_text ?? "",
  }),
  columns: [
    {
      id: "number",
      title: () => t("loan-column-number"),
      cell: (row) => String(row.number),
      key: (row) => row.number,
      numeric: true,
      width: "76px",
    },
    {
      id: "date",
      title: () => t("loan-column-date"),
      cell: (row) => row.date,
      key: (row) => row.date_value,
      width: "120px",
    },
    {
      id: "payment",
      title: () => t("loan-column-payment"),
      cell: (row) => row.payment,
      key: (row) => row.payment_value,
      money: (row) => row.payment_value,
      numeric: true,
    },
    {
      id: "interest",
      title: () => t("loan-column-interest"),
      cell: (row) => row.interest,
      key: (row) => row.interest_value,
      money: (row) => row.interest_value,
      numeric: true,
    },
    {
      id: "capital",
      title: () => t("loan-column-capital"),
      cell: (row) => row.capital,
      key: (row) => row.capital_value,
      money: (row) => row.capital_value,
      numeric: true,
    },
    {
      id: "insurance",
      title: () => t("loan-column-insurance"),
      cell: (row) => row.insurance,
      key: (row) => row.insurance_value,
      money: (row) => row.insurance_value,
      numeric: true,
    },
    {
      id: "remaining",
      title: () => t("loan-column-remaining"),
      cell: (row) => row.remaining,
      key: (row) => row.remaining_value,
      money: (row) => row.remaining_value,
      numeric: true,
    },
  ],
});

// --- Les comptes et la période ---------------------------------------------

function fillAccounts(accounts: Account[]): void {
  const fresh = new Set(accounts.map((account) => account.id));
  for (const account of accounts) {
    if (!knownAccounts.has(account.id)) {
      ticked.add(account.id);
    }
  }
  for (const id of [...ticked]) {
    if (!fresh.has(id)) {
      ticked.delete(id);
    }
  }
  knownAccounts = fresh;

  const body = element<HTMLElement>("accounts");
  body.replaceChildren();
  for (const account of accounts) {
    const row = document.createElement("tr");
    const box = document.createElement("td");
    const check = document.createElement("input");
    check.type = "checkbox";
    check.checked = ticked.has(account.id);
    check.dataset.account = String(account.id);
    check.addEventListener("change", () => {
      if (check.checked) {
        ticked.add(account.id);
      } else {
        ticked.delete(account.id);
      }
      simulate("other");
    });
    box.append(check);
    const name = document.createElement("td");
    name.textContent = account.label;
    const bank = document.createElement("td");
    bank.textContent = account.bank;
    const balance = document.createElement("td");
    balance.className = "loan__number";
    balance.textContent = account.balance;
    balance.classList.toggle("loan__negative", account.balance_value < 0);
    row.append(box, name, bank, balance);
    // Toute la ligne coche : la case seule est une petite cible.
    row.addEventListener("click", (event) => {
      if (event.target !== check) {
        check.click();
      }
    });
    body.append(row);
  }
}

async function loadChoices(): Promise<void> {
  const choices = await invoke<Choices>("loan_choices");
  const kind = element<HTMLSelectElement>("kind");
  const keptKind = kind.value;
  kind.replaceChildren();
  for (const choice of choices.kinds) {
    const option = document.createElement("option");
    option.value = choice.key;
    option.textContent = choice.label;
    kind.append(option);
  }
  kind.value = keptKind || "consumer";

  const history = element<HTMLSelectElement>("history");
  const keptHistory = history.value;
  history.replaceChildren();
  for (const choice of choices.histories) {
    const option = document.createElement("option");
    option.value = choice.key;
    option.textContent = choice.label;
    history.append(option);
  }
  history.value = choices.histories.some((choice) => choice.key === keptHistory)
    ? keptHistory
    : "last-12";
  fillRange(choices.years, keptHistory);

  for (const unit of document.querySelectorAll<HTMLElement>("[data-sign]")) {
    unit.textContent = choices.sign;
  }
  fillAccounts(choices.accounts);
}

async function applyDefaults(kind: string): Promise<void> {
  const defaults = await invoke<Defaults>("loan_defaults", { kind });
  field("amount").value = defaults.amount;
  field("months").value = defaults.months;
  field("rate").value = defaults.rate;
  field("fees").value = defaults.fees;
  field("insurance").value = defaults.insurance;
}

// --- Les onglets ----------------------------------------------------------------

function chooseTab(which: "credit" | "afford" | "rules"): void {
  for (const name of ["credit", "afford", "rules"] as const) {
    element<HTMLElement>(`tab-${name}`).setAttribute("aria-selected", String(name === which));
    element<HTMLElement>(`pane-${name}`).hidden = name !== which;
  }
  if (which === "credit") {
    schedule.render();
  }
}

// --- Les mots ---------------------------------------------------------------------

/// **Tous les mots de la fenêtre, posés en un seul endroit**, pour qu'elle se
/// rhabille quand la langue change. Les chiffres et les graphiques viennent
/// du noyau, déjà dans la langue : un nouveau calcul les repose.
async function dress(alsoTheNumbers = true): Promise<void> {
  for (const [id, key] of [
    ["kind-label", "loan-field-kind"],
    ["rate-label", "loan-field-rate"],
    ["rate-unit", "loan-unit-percent"],
    ["fees-label", "loan-field-fees"],
    ["insurance-label", "loan-field-insurance"],
    ["amount-label", "loan-field-amount"],
    ["payment-label", "loan-field-payment"],
    ["months-label", "loan-field-months"],
    ["months-unit", "loan-unit-months"],
    ["pdf-label", "loan-report-button"],
    ["monthly-label", "loan-monthly-table"],
    ["tab-credit", "loan-tab-credit"],
    ["tab-afford", "loan-tab-afford"],
    ["tab-rules", "loan-tab-rules"],
    ["rules-title", "loan-tab-rules"],
    ["cost-title", "loan-chart-cost"],
    ["capital-title", "loan-chart-capital"],
    ["schedule-title", "loan-schedule-title"],
    ["accounts-title", "loan-accounts-title"],
    ["history-label", "loan-history-label"],
    ["account-column", "loan-column-account"],
    ["bank-column", "loan-column-bank"],
    ["balance-column", "loan-column-balance"],
    ["running-title", "loan-running-title"],
    ["running-label", "loan-running-column-label"],
    ["running-monthly", "loan-running-column-monthly"],
    ["running-end", "loan-running-column-end"],
    ["verdict-title", "loan-verdict-title"],
    ["income-title", "loan-chart-income"],
    ["history-title", "loan-chart-history"],
    ["history-hint", "loan-chart-history-hint"],
    ["projection-title", "loan-chart-projection"],
    ["disclaimer", "loan-disclaimer"],
    ["period-label", "loan-period-title"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  for (const unit of document.querySelectorAll<HTMLElement>("[data-percent-year]")) {
    unit.textContent = t("loan-unit-percent-year");
  }
  dressRange();
  element<HTMLElement>("close").title = t("ui-title-close");
  element<HTMLElement>("pdf").title = t("loan-report-button");
  schedule.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));
  if (alsoTheNumbers) {
    await loadChoices();
    simulate("other");
  }
}

// --- Les gestes -------------------------------------------------------------------

// **Les champs ne prennent que des chiffres** (Fabrice, 11/10/2026 : « on peut
// écrire des lettres dans un champ numérique, c'est pas bien du tout ») : le
// filtre des fiches, sans signe. Les montants restent tels que tapés — le
// noyau les réécrit lui-même après chaque calcul ; le taux a trois décimales
// (3,125 %), la durée et les hausses de revenus sont des nombres entiers.
guardFields({
  amount: "money-as-typed",
  payment: "money-as-typed",
  fees: "money-as-typed",
  insurance: "money-as-typed",
  rate: 3,
  months: 0,
  "growth-optimistic": 0,
  "growth-neutral": 0,
  "growth-severe": 0,
});

for (const name of ["amount", "payment", "months"] as const) {
  // Le curseur écrit sa valeur dans son champ, puis demande le calcul : c'est
  // le champ qui part au noyau, une seule façon de lire une saisie.
  range(name).addEventListener("input", () => {
    sliding = name;
    field(name).value = range(name).value;
    simulate(name);
  });
  range(name).addEventListener("change", () => {
    sliding = null;
    if (shown) {
      placeRanges(shown);
    }
  });
}
for (const name of FIELDS) {
  // Un champ tapé compte à la validation — Entrée ou la sortie du champ —,
  // pas à chaque touche : « 1 » puis « 12 » puis « 120 » ne sont pas trois
  // crédits.
  field(name).addEventListener("input", () => {
    editing = name;
  });
  field(name).addEventListener("change", () => {
    editing = null;
    // Un curseur dont on n'aurait pas vu le relâchement ne reste pas figé.
    sliding = null;
    const moved = name === "amount" || name === "payment" || name === "months" ? name : "other";
    simulate(moved);
  });
  field(name).addEventListener("keydown", (event) => {
    if (event.key === "Enter") {
      field(name).blur();
    }
  });
}
element<HTMLSelectElement>("kind").addEventListener("change", () => {
  void (async () => {
    await applyDefaults(element<HTMLSelectElement>("kind").value);
    simulate("other");
  })();
});
element<HTMLSelectElement>("history").addEventListener("change", () => simulate("other"));
onRangeChange(() => simulate("other"));
element<HTMLButtonElement>("tab-credit").addEventListener("click", () => chooseTab("credit"));
element<HTMLButtonElement>("tab-afford").addEventListener("click", () => chooseTab("afford"));
element<HTMLButtonElement>("tab-rules").addEventListener("click", () => chooseTab("rules"));
element<HTMLButtonElement>("method-line").addEventListener("click", () => chooseTab("rules"));
for (const radio of document.querySelectorAll<HTMLInputElement>('input[name="method"]')) {
  radio.addEventListener("change", () => simulate("other"));
}
for (const method of METHODS) {
  const growth = element<HTMLInputElement>(`growth-${method}`);
  growth.addEventListener("change", () => simulate("other"));
  growth.addEventListener("keydown", (event) => {
    if (event.key === "Enter") {
      growth.blur();
    }
  });
}
element<HTMLButtonElement>("pdf").addEventListener("click", () => {
  void (async () => {
    try {
      const message = await invoke<string>("print_loan_report", {
        request: request("other"),
        monthly: element<HTMLInputElement>("monthly").checked,
      });
      say(message);
    } catch (error) {
      say(String(error), true);
    }
  })();
});
element<HTMLButtonElement>("close").addEventListener("click", () => {
  void invoke("close_loan_simulation");
});

// L'historique a pu bouger pendant que la fenêtre attendait : une opération
// saisie ailleurs change les moyennes. Les comptes aussi — un compte créé
// arrive coché.
for (const event of ["data-changed:operations", "data-changed:accounts-list"]) {
  void listen(event, () => {
    void loadChoices().then(() => simulate("other"));
  });
}
window.addEventListener("focus", () => {
  void loadChoices()
    .then(() => simulate("other"))
    .catch(() => undefined);
});

void (async () => {
  await loadTexts(null);
  await dress(false);
  schedule.exportOnRightClick(say);
  schedule.setRows([]);

  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    return;
  }
  try {
    await loadChoices();
    await applyDefaults(element<HTMLSelectElement>("kind").value);
    simulate("other");
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
  onLanguageChanged(dress, { key: "window-loan-title" });
})();
