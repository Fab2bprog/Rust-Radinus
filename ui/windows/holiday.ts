// F46 — « Préparer mes vacances » (Fabrice, 10/10/2026).
//
// « Le but, c'est simplement de calculer combien vont me coûter mes
// prochaines vacances. »
//
// **La fenêtre ne calcule rien.** Elle se bâtit sur le catalogue des postes
// que le noyau lui donne — elle n'en connaît aucun par son nom —, envoie ce
// qui est tapé, et reçoit tout écrit dans la langue : le résultat, le coût de
// chaque poste, l'anneau.
//
// **Rien n'entre dans la base** (« oui on oublie les chiffres ») : la porte
// efface tout. Ce qui doit durer part dans un fichier — un projet en JSON
// qu'on rouvre (« ça évite de tout retaper »), un rapport PDF, un classeur
// Excel.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { save } from "@tauri-apps/plugin-dialog";
import { askThreeWays, askYesNo } from "./dialog";
import { asNumberField, guardFields } from "./money-field";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

interface Offer {
  key: string;
  label: string;
}

interface CatalogLine {
  key: string;
  label: string;
  stay: boolean;
  cruise: boolean;
  optional: boolean;
  who: string;
  default_who: string;
  spans: Offer[];
  units: Offer[];
}

interface Account {
  id: number;
  label: string;
  bank: string;
  balance: string;
}

interface Choices {
  accounts: Account[];
  catalog: CatalogLine[];
  sign: string;
}

interface LineInput {
  key: string;
  amount: string;
  child: string;
  who: string;
  span: string;
  unit: string;
  count: string;
}

interface Input {
  trip: string;
  adults: number;
  children: number;
  nights: string;
  months: string;
  stops: string;
  lines: LineInput[];
}

interface Written {
  headline: string;
  tiles: { label: string; value: string }[];
  costs: { key: string; cost: string; share: string; colour: string }[];
  donut: string;
  days: string;
  notes: string[];
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
const select = (id: string): HTMLSelectElement => element<HTMLSelectElement>(id);

let catalog: CatalogLine[] = [];
/// Les comptes cochés : aucun au départ.
const ticked = new Set<number>();

function trip(): string {
  return document.querySelector<HTMLInputElement>('input[name="trip"]:checked')?.value ?? "stay";
}

// --- Ce qui est tapé ------------------------------------------------------------

function input(): Input {
  return {
    trip: trip(),
    adults: Number(field("adults").value) || 1,
    children: Number(field("children").value) || 0,
    nights: field("nights").value,
    months: field("months").value,
    stops: field("stops").value,
    lines: catalog.map((line) => ({
      key: line.key,
      amount: field(`amount-${line.key}`).value,
      child: field(`child-${line.key}`)?.value ?? "",
      who: document.getElementById(`who-${line.key}`) ? select(`who-${line.key}`).value : "",
      span: select(`span-${line.key}`).value,
      unit: select(`unit-${line.key}`).value,
      count: document.getElementById(`count-${line.key}`) ? field(`count-${line.key}`).value : "",
    })),
  };
}

/// Quelque chose a-t-il été tapé ? Ouvrir un projet le remplacerait.
/// Ce que disait la fenêtre au dernier projet enregistré ou ouvert : tant
/// qu'elle le dit encore, il n'y a rien à perdre en sortant.
let kept = "";
const state = (): string => JSON.stringify({ input: input(), accounts: [...ticked].sort() });

function typed(): boolean {
  return (
    field("nights").value !== "" ||
    field("months").value !== "" ||
    catalog.some((line) => field(`amount-${line.key}`).value.trim() !== "")
  );
}

// --- Le calcul ------------------------------------------------------------------

let running = false;
let again = false;
/// Une phrase à garder dans la barre après le prochain calcul — « Projet
/// ouvert : … » —, que le calcul effacerait sinon.
let pending: string | null = null;

function compute(): void {
  if (running) {
    again = true;
    return;
  }
  running = true;
  void (async () => {
    try {
      show(await invoke<Result>("holiday_compute", { input: input(), accounts: [...ticked] }));
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

function show(result: Result): void {
  for (const marked of document.querySelectorAll(".form__field--invalid")) {
    marked.classList.remove("form__field--invalid");
  }
  // **Un calcul refusé n'a pas de résultat** (11/10/2026) : la réponse, les
  // coûts, l'anneau et les notes d'avant s'estompent tant que le champ n'est
  // pas corrigé ; les champs, eux, restent nets.
  document.querySelector(".loan")?.classList.toggle("loan--stale", !result.written);
  if (result.invalid || !result.written) {
    if (result.invalid) {
      document.getElementById(result.invalid)?.classList.add("form__field--invalid");
    }
    say(result.message ?? "", true);
    return;
  }
  say(pending ?? "");
  pending = null;
  const written = result.written;
  const answer = element<HTMLElement>("answer");
  answer.dataset.tone = written.costs.some((cost) => cost.cost !== "") ? "good" : "none";
  element<HTMLElement>("headline").textContent = written.headline;
  element<HTMLElement>("days-text").textContent = written.days;
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
  for (const cost of written.costs) {
    const cell = document.getElementById(`cost-${cost.key}`);
    if (!cell) {
      continue;
    }
    cell.replaceChildren();
    if (cost.cost !== "") {
      const dot = document.createElement("span");
      dot.className = "appliance__dot";
      dot.style.backgroundColor = cost.colour;
      cell.append(dot, cost.cost);
      cell.title = cost.share;
    }
  }
  element<HTMLElement>("donut").innerHTML = written.donut;
  const notes = element<HTMLElement>("notes");
  notes.replaceChildren();
  for (const note of written.notes) {
    const item = document.createElement("li");
    item.textContent = note;
    notes.append(item);
  }
}

// --- Le budget ------------------------------------------------------------------

function options(target: HTMLSelectElement, offers: Offer[]): void {
  target.replaceChildren();
  for (const offer of offers) {
    const option = document.createElement("option");
    option.value = offer.key;
    option.textContent = offer.label;
    target.append(option);
  }
}

/// **Bâtit le budget** sur le catalogue : une ligne par poste, ses champs et
/// ses choix. Les postes facultatifs vont dans leur propre bloc.
function buildLines(): void {
  const main = element<HTMLElement>("lines");
  const optional = element<HTMLElement>("optional");
  main.replaceChildren();
  optional.replaceChildren();
  const heading = document.createElement("tr");
  heading.className = "holiday__heading";
  const title = document.createElement("td");
  title.colSpan = 6;
  title.textContent = t("holiday-optional-title");
  heading.append(title);
  optional.append(heading);

  for (const line of catalog) {
    const row = document.createElement("tr");
    row.dataset.key = line.key;
    row.dataset.stay = String(line.stay);
    row.dataset.cruise = String(line.cruise);

    const name = document.createElement("td");
    name.textContent = line.label;

    const amountCell = document.createElement("td");
    amountCell.className = "holiday__amount";
    if (line.who === "cabins") {
      const count = document.createElement("input");
      count.className = "form__field holiday__count";
      count.id = `count-${line.key}`;
      asNumberField(count, 0);
      count.placeholder = t("holiday-count-label");
      count.title = t("holiday-count-label");
      amountCell.append(count, " × ");
    }
    const amount = document.createElement("input");
    amount.className = "form__field cut__input";
    amount.id = `amount-${line.key}`;
    // Un montant ou un pourcentage, selon l'unité du poste : des chiffres,
    // deux décimales, jamais réécrit — « 5 » % reste « 5 ».
    asNumberField(amount, 2);
    const unit = document.createElement("select");
    unit.className = "form__field cut__unit";
    unit.id = `unit-${line.key}`;
    options(unit, line.units);
    unit.hidden = line.units.length < 2;
    const unitText = document.createElement("span");
    unitText.className = "loan__unit";
    unitText.textContent = line.units.length < 2 ? (line.units[0]?.label ?? "") : "";
    amountCell.append(amount, unit, unitText);

    const childCell = document.createElement("td");
    const who = document.createElement("td");
    if (line.who === "choice") {
      const child = document.createElement("input");
      child.className = "form__field cut__input";
      child.id = `child-${line.key}`;
      asNumberField(child, 2);
      child.placeholder = t("holiday-child-label");
      child.title = t("holiday-child-label");
      childCell.append(child);
      const whoSelect = document.createElement("select");
      whoSelect.className = "form__field holiday__select";
      whoSelect.id = `who-${line.key}`;
      options(whoSelect, [
        { key: "all", label: t("holiday-who-all") },
        { key: "person", label: t("holiday-who-person") },
      ]);
      whoSelect.value = line.default_who;
      who.append(whoSelect);
    } else if (line.who === "adults") {
      who.textContent = t("holiday-who-adults");
    }

    const span = document.createElement("td");
    const spanSelect = document.createElement("select");
    spanSelect.className = "form__field holiday__select";
    spanSelect.id = `span-${line.key}`;
    options(spanSelect, line.spans);
    spanSelect.disabled = line.spans.length < 2;
    span.append(spanSelect);

    const cost = document.createElement("td");
    cost.className = "loan__number holiday__cost";
    cost.id = `cost-${line.key}`;

    row.append(name, amountCell, childCell, who, span, cost);
    (line.optional ? optional : main).append(row);

    for (const control of row.querySelectorAll<HTMLInputElement | HTMLSelectElement>("input, select")) {
      control.addEventListener("change", () => {
        showLines();
        compute();
      });
      if (control instanceof HTMLInputElement) {
        control.addEventListener("keydown", (event) => {
          if (event.key === "Enter") {
            control.blur();
          }
        });
      }
    }
  }
  showLines();
}

/// Chaque poste se montre selon le voyage ; le prix enfant, s'il y a des
/// enfants et que le poste est par personne ; pour qui et pour combien de
/// temps, sauf pour un pourcentage.
function showLines(): void {
  const kind = trip();
  const children = Number(field("children").value) > 0;
  element<HTMLElement>("stops-line").hidden = kind !== "cruise";
  for (const row of document.querySelectorAll<HTMLElement>("#lines tr, #optional tr[data-key]")) {
    const key = row.dataset.key ?? "";
    row.hidden = row.dataset[kind] !== "true";
    const percent = select(`unit-${key}`).value === "percent";
    const who = document.getElementById(`who-${key}`) as HTMLSelectElement | null;
    const child = document.getElementById(`child-${key}`) as HTMLInputElement | null;
    if (who) {
      who.hidden = percent;
    }
    if (child) {
      child.hidden = percent || !children || who?.value !== "person";
    }
    select(`span-${key}`).hidden = percent;
  }
}

// --- Les comptes ----------------------------------------------------------------

function fillAccounts(accounts: Account[]): void {
  for (const id of [...ticked]) {
    if (!accounts.some((account) => account.id === id)) {
      ticked.delete(id);
    }
  }
  const body = element<HTMLElement>("accounts");
  body.replaceChildren();
  for (const account of accounts) {
    const row = document.createElement("tr");
    const cell = document.createElement("td");
    const check = document.createElement("input");
    check.type = "checkbox";
    check.dataset.account = String(account.id);
    check.checked = ticked.has(account.id);
    check.addEventListener("change", () => {
      if (check.checked) {
        ticked.add(account.id);
      } else {
        ticked.delete(account.id);
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

async function loadChoices(rebuild: boolean): Promise<void> {
  const choices = await invoke<Choices>("holiday_choices");
  if (rebuild || catalog.length === 0) {
    const kept = catalog.length > 0 ? input() : null;
    catalog = choices.catalog;
    buildLines();
    if (kept) {
      place(kept);
    }
  }
  fillAccounts(choices.accounts);
}

// --- Les sliders et le voyage ---------------------------------------------------

function showPeople(): void {
  element<HTMLElement>("adults-value").textContent = field("adults").value;
  element<HTMLElement>("children-value").textContent = field("children").value;
}

/// Pose un voyage dans les champs : celui d'un projet rouvert, ou le même
/// après un changement de langue.
function place(given: Input): void {
  const radio = document.querySelector<HTMLInputElement>(`input[name="trip"][value="${given.trip}"]`);
  if (radio) {
    radio.checked = true;
  }
  field("adults").value = String(given.adults || 1);
  field("children").value = String(given.children || 0);
  field("nights").value = given.nights;
  field("months").value = given.months;
  field("stops").value = given.stops;
  for (const line of catalog) {
    const found = given.lines.find((one) => one.key === line.key);
    field(`amount-${line.key}`).value = found?.amount ?? "";
    const child = document.getElementById(`child-${line.key}`) as HTMLInputElement | null;
    if (child) {
      child.value = found?.child ?? "";
    }
    const who = document.getElementById(`who-${line.key}`) as HTMLSelectElement | null;
    if (who) {
      who.value = found?.who || line.default_who;
    }
    const span = select(`span-${line.key}`);
    span.value = found?.span && line.spans.some((one) => one.key === found.span) ? found.span : (line.spans[0]?.key ?? "");
    const unit = select(`unit-${line.key}`);
    unit.value = found?.unit && line.units.some((one) => one.key === found.unit) ? found.unit : (line.units[0]?.key ?? "");
    const count = document.getElementById(`count-${line.key}`) as HTMLInputElement | null;
    if (count) {
      count.value = found?.count ?? "";
    }
  }
  showPeople();
  showLines();
}

/// **La porte efface tout** : la fenêtre se rouvrira vierge.
function clear(): void {
  ticked.clear();
  place({ trip: "stay", adults: 1, children: 0, nights: "", months: "", stops: "", lines: [] });
  for (const check of document.querySelectorAll<HTMLInputElement>("#accounts input")) {
    check.checked = false;
  }
}

// --- Les mots -------------------------------------------------------------------

function dress(): void {
  for (const [id, key] of [
    ["trip-title", "holiday-trip-title"],
    ["trip-stay", "holiday-trip-stay"],
    ["trip-cruise", "holiday-trip-cruise"],
    ["adults-label", "holiday-field-adults"],
    ["children-label", "holiday-field-children"],
    ["nights-label", "holiday-field-nights"],
    ["months-label", "holiday-field-months"],
    ["stops-label", "holiday-field-stops"],
    ["saved-title", "holiday-saved-title"],
    ["saved-hint", "holiday-saved-hint"],
    ["account-column", "goal-column-account"],
    ["balance-column", "goal-column-balance"],
    ["open", "holiday-open"],
    ["save", "holiday-save"],
    ["pdf-label", "holiday-pdf"],
    ["excel", "holiday-excel"],
    ["result-title", "holiday-result-title"],
    ["budget-title", "holiday-budget-title"],
    ["budget-hint", "holiday-budget-hint"],
    ["column-line", "holiday-column-line"],
    ["column-amount", "holiday-column-amount"],
    ["column-child", "holiday-column-child"],
    ["column-who", "holiday-column-who"],
    ["column-span", "holiday-column-span"],
    ["column-cost", "holiday-column-cost"],
    ["donut-title", "holiday-donut-title"],
    ["disclaimer", "holiday-disclaimer"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  element<HTMLElement>("close").title = t("ui-title-close");
  element<HTMLElement>("pdf").title = t("holiday-pdf");
}

// --- Les gestes -----------------------------------------------------------------

for (const radio of document.querySelectorAll<HTMLInputElement>('input[name="trip"]')) {
  radio.addEventListener("change", () => {
    showLines();
    compute();
  });
}
for (const id of ["adults", "children"]) {
  field(id).addEventListener("input", () => {
    showPeople();
    showLines();
    compute();
  });
}
// **Les champs ne prennent que des chiffres** (Fabrice, 11/10/2026 : « on peut
// écrire des lettres dans un champ numérique, c'est pas bien du tout ») : les
// nuits, les mois et les escales sont des nombres entiers ; les montants des
// postes passent par le même filtre quand le budget se bâtit.
guardFields({ nights: 0, months: 0, stops: 0 });

for (const id of ["nights", "months", "stops"]) {
  field(id).addEventListener("change", compute);
  field(id).addEventListener("keydown", (event) => {
    if (event.key === "Enter") {
      field(id).blur();
    }
  });
}

/// Un nom de fichier sans ce que les systèmes refusent.
const fileName = (text: string): string => text.replace(/[\\/:*?\x22<>|…]/g, "").trim() || "Radinus";

element<HTMLButtonElement>("open").addEventListener("click", () => {
  void (async () => {
    if (typed() && !(await askYesNo(t("holiday-replace-question"), t("ui-yes"), t("ui-no")))) {
      return;
    }
    try {
      const opened = await invoke<{ input: Input; accounts: number[]; message: string } | null>(
        "load_holiday_project",
      );
      if (!opened) {
        return;
      }
      place(opened.input);
      ticked.clear();
      for (const id of opened.accounts) {
        ticked.add(id);
      }
      for (const check of document.querySelectorAll<HTMLInputElement>("#accounts input")) {
        check.checked = ticked.has(Number(check.dataset.account));
      }
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
    defaultPath: `${fileName(t("window-holiday-title"))}.json`,
    filters: [{ name: t("holiday-file-filter"), extensions: ["json"] }],
  });
  if (chosen === null) {
    return false;
  }
  try {
    const now = state();
    say(await invoke<string>("save_holiday_project", { input: input(), accounts: [...ticked], path: chosen }));
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
      defaultPath: `${fileName(t("window-holiday-title"))}.xlsx`,
      filters: [{ name: "XLSX", extensions: ["xlsx"] }],
    });
    if (chosen === null) {
      return;
    }
    try {
      say(await invoke<string>("export_holiday", { input: input(), accounts: [...ticked], path: chosen }));
    } catch (error) {
      say(String(error), true);
    }
  })();
});

element<HTMLButtonElement>("pdf").addEventListener("click", () => {
  void (async () => {
    try {
      say(await invoke<string>("print_holiday_report", { input: input(), accounts: [...ticked] }));
    } catch (error) {
      say(String(error), true);
    }
  })();
});

/// **La porte demande d'abord** (Fabrice, 10/10/2026 : « un clic sur le
/// bouton de sortie doit se faire avec un panneau de confirmation, même genre
/// que dans la classification rapide ») : enregistrer le projet, abandonner,
/// rester — posée seulement quand des chiffres tapés seraient perdus,
/// c'est-à-dire tapés et pas enregistrés depuis. Échap reste. Puis elle
/// efface tout et masque la fenêtre.
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
    clear();
    kept = "";
    compute();
    void invoke("close_holiday");
  })();
});

for (const event of ["data-changed:accounts-list", "data-changed:operations", "data-changed:holiday"]) {
  void listen(event, () => {
    void loadChoices(false)
      .then(compute)
      .catch(() => undefined);
  });
}
window.addEventListener("focus", () => {
  void loadChoices(false)
    .then(compute)
    .catch(() => undefined);
});

void (async () => {
  await loadTexts(null);
  dress();
  showPeople();
  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    return;
  }
  try {
    await loadChoices(true);
    compute();
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
  onLanguageChanged(
    async () => {
      dress();
      await loadChoices(true);
      compute();
    },
    { key: "window-holiday-title" },
  );
})();
