// F47 — « Carnet de ma voiture » (Fabrice, 10/10/2026).
//
// « Quelque chose qui gère l'historique de la voiture. » Huit rubriques, huit
// motorisations, la fiche, les échéances, un fichier JSON par voiture
// enregistré à la main, le dossier PDF et le classeur Excel.
//
// **La fenêtre ne calcule rien et ne garde rien.** Le carnet vit côté Rust :
// chaque geste — un champ de la fiche, une ligne ajoutée, modifiée ou
// supprimée — part au contrôleur, qui rend le carnet entier déjà écrit. La
// fenêtre ne fait que montrer, et cacher les champs qui ne concernent pas la
// rubrique choisie.
//
// **La porte demande avant d'oublier** (même panneau que la classification
// rapide), puis le carnet est oublié : la fenêtre se rouvre vierge.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { save } from "@tauri-apps/plugin-dialog";
import { askForChoice, askThreeWays, askYesNo } from "./dialog";
import { guardFields } from "./money-field";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

interface Choice {
  key: string;
  label: string;
}

interface EnergyChoice extends Choice {
  unit: string;
}

interface Choices {
  engines: Choice[];
  rubrics: Choice[];
  energies: EnergyChoice[];
  parts: Choice[];
  axles: Choice[];
  verdicts: Choice[];
  charges: Choice[];
  slots: Choice[];
  rechargeable: boolean;
  battery: boolean;
  off_peak: boolean;
  sign: string;
  price_unit: string;
}

interface TariffFields {
  option: string;
  base: string;
  peak: string;
  off_peak: string;
  off_peak_hours: string;
}

interface CarFields {
  plate: string;
  make: string;
  model: string;
  engine: string;
  first_hand: boolean;
  registered: string;
  acquired: string;
  acquired_km: string;
  service_months: string;
  service_km: string;
  tariff: TariffFields;
}

interface EntryFields {
  date: string;
  km: string;
  rubric: string;
  amount: string;
  garage: string;
  note: string;
  energy: string;
  quantity: string;
  charge: string;
  slot: string;
  part: string;
  part_name: string;
  axle: string;
  verdict: string;
  months: string;
  battery: string;
}

interface Row {
  id: number;
  date: string;
  km: string;
  rubric: string;
  rubric_key: string;
  colour: string;
  detail: string;
  amount: string;
  garage: string;
  note: string;
  fields: EntryFields;
}

interface Life {
  name: string;
  changes: string;
  amount: string;
  last: string;
  life: string;
  next: string;
}

interface Written {
  title: string;
  headline: string;
  tiles: { label: string; value: string }[];
  total: string;
  energy: { label: string; quantity: string; amount: string; price: string; consumption: string; per_km: string }[];
  parts: Life[];
  tyres: Life[];
  battery: string[];
  deadlines: { label: string; when: string; tone: string; badge: string }[];
  deadlines_empty: string;
  rows: Row[];
  years: string;
  donut: string;
  notes: string[];
}

interface View {
  car: CarFields;
  choices: Choices;
  written: Written;
  unsaved: boolean;
  empty: boolean;
}

interface Result {
  invalid: string | null;
  message: string | null;
  view: View;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;
const field = (id: string): HTMLInputElement => element<HTMLInputElement>(id);
const select = (id: string): HTMLSelectElement => element<HTMLSelectElement>(id);

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

/// Le dernier carnet reçu.
let current: View | null = null;
/// La ligne qu'on modifie, ou `null` pour une nouvelle.
let editing: number | null = null;

// --- Les listes -------------------------------------------------------------------

function fillSelect(target: HTMLSelectElement, choices: Choice[], fallback?: string): void {
  const chosen = target.value;
  const same =
    target.options.length === choices.length &&
    choices.every((choice, rank) => target.options[rank].value === choice.key && target.options[rank].textContent === choice.label);
  if (!same) {
    target.replaceChildren();
    for (const choice of choices) {
      const option = document.createElement("option");
      option.value = choice.key;
      option.textContent = choice.label;
      target.append(option);
    }
  }
  if (choices.some((choice) => choice.key === chosen)) {
    target.value = chosen;
  } else if (fallback !== undefined && choices.some((choice) => choice.key === fallback)) {
    target.value = fallback;
  } else if (choices.length > 0) {
    target.value = choices[0].key;
  }
}

function fillChoices(choices: Choices): void {
  fillSelect(select("engine"), choices.engines);
  fillSelect(select("rubric"), choices.rubrics, "energy");
  fillSelect(select("energy"), choices.energies);
  fillSelect(select("part"), choices.parts);
  fillSelect(select("axle"), choices.axles);
  fillSelect(select("verdict"), choices.verdicts);
  fillSelect(select("charge"), choices.charges);
  fillSelect(select("slot"), choices.slots);
  fillSelect(select("filter"), [{ key: "", label: t("car-filter-all") }, ...choices.rubrics]);
  for (const unit of document.querySelectorAll<HTMLElement>("[data-sign]")) {
    unit.textContent = choices.sign;
  }
  for (const unit of document.querySelectorAll<HTMLElement>('[data-unit="price"]')) {
    unit.textContent = choices.price_unit;
  }
  element<HTMLElement>("tariff-card").hidden = !choices.rechargeable;
}

// --- La fiche ---------------------------------------------------------------------

const CAR_FIELDS: [string, keyof CarFields][] = [
  ["plate", "plate"],
  ["make", "make"],
  ["model", "model"],
  ["registered", "registered"],
  ["acquired", "acquired"],
  ["acquired-km", "acquired_km"],
  ["service-months", "service_months"],
  ["service-km", "service_km"],
];

const TARIFF_FIELDS: [string, keyof TariffFields][] = [
  ["tariff-base", "base"],
  ["tariff-peak", "peak"],
  ["tariff-off-peak", "off_peak"],
  ["tariff-hours", "off_peak_hours"],
];

function carFields(): CarFields {
  const read = (id: string): string => field(id).value;
  return {
    plate: read("plate"),
    make: read("make"),
    model: read("model"),
    engine: select("engine").value,
    first_hand: field("first-hand").checked,
    registered: read("registered"),
    acquired: read("acquired"),
    acquired_km: read("acquired-km"),
    service_months: read("service-months"),
    service_km: read("service-km"),
    tariff: {
      option: select("option").value,
      base: read("tariff-base"),
      peak: read("tariff-peak"),
      off_peak: read("tariff-off-peak"),
      off_peak_hours: read("tariff-hours"),
    },
  };
}

/// Pose la fiche reçue — sauf dans le champ qu'on est en train de taper.
function placeCar(car: CarFields): void {
  const put = (id: string, value: string): void => {
    const input = field(id);
    if (input !== document.activeElement && input.value !== value) {
      input.value = value;
    }
  };
  for (const [id, key] of CAR_FIELDS) {
    put(id, car[key] as string);
  }
  for (const [id, key] of TARIFF_FIELDS) {
    put(id, car.tariff[key]);
  }
  select("engine").value = car.engine;
  field("first-hand").checked = car.first_hand;
  select("option").value = car.tariff.option;
  showTariff();
}

function showTariff(): void {
  const offPeak = select("option").value === "off-peak";
  element<HTMLElement>("base-line").hidden = offPeak;
  for (const line of document.querySelectorAll<HTMLElement>("[data-off-peak]")) {
    line.hidden = !offPeak;
  }
}

function clearMarks(): void {
  for (const marked of document.querySelectorAll(".form__field--invalid")) {
    marked.classList.remove("form__field--invalid");
  }
}

/// Le nom d'un champ refusé, tel que le noyau le donne, vers son identifiant.
function markInvalid(name: string): void {
  document.getElementById(name)?.classList.add("form__field--invalid");
}

let sending = Promise.resolve();

/// **Envoie la fiche** : chaque changement part, le carnet revient écrit.
function sendCar(): void {
  sending = sending.then(async () => {
    try {
      const result = await invoke<Result>("car_set_car", { car: carFields() });
      clearMarks();
      if (result.invalid) {
        markInvalid(result.invalid);
        say(result.message ?? "", true);
      } else {
        say("");
      }
      show(result.view);
    } catch (error) {
      say(String(error), true);
    }
  });
}

// --- La ligne ---------------------------------------------------------------------

function entryFields(): EntryFields {
  const read = (id: string): string => field(id).value;
  return {
    date: read("date"),
    km: read("km"),
    rubric: select("rubric").value,
    amount: read("amount"),
    garage: read("garage"),
    note: read("note"),
    energy: select("energy").value,
    quantity: read("quantity"),
    charge: select("charge").value,
    slot: select("slot").value,
    part: select("part").value,
    part_name: read("part-name"),
    axle: select("axle").value,
    verdict: select("verdict").value,
    months: read("months"),
    battery: read("battery"),
  };
}

/// Le jour, en ISO, pour le champ de date d'une ligne nouvelle.
function today(): string {
  const now = new Date();
  const two = (value: number): string => String(value).padStart(2, "0");
  return `${now.getFullYear()}-${two(now.getMonth() + 1)}-${two(now.getDate())}`;
}

/// **Montre les champs de la rubrique**, et ceux de l'énergie choisie.
function showEntry(): void {
  const choices = current?.choices;
  const rubric = select("rubric").value;
  for (const line of document.querySelectorAll<HTMLElement>("[data-for]")) {
    line.hidden = line.dataset.for !== rubric;
  }
  const energies = choices?.energies ?? [];
  const energy = energies.find((one) => one.key === select("energy").value) ?? energies[0];
  if (rubric === "energy") {
    element<HTMLElement>("energy-line").hidden = energies.length < 2;
    element<HTMLElement>("quantity-unit").textContent = energy?.unit ?? "";
  }
  const electric = rubric === "energy" && energy?.key === "electricity";
  const home = electric && select("charge").value === "home";
  element<HTMLElement>("charge-line").hidden = !electric;
  element<HTMLElement>("slot-line").hidden = !home || !(choices?.off_peak ?? false);
  element<HTMLElement>("amount-line").hidden = home;
  element<HTMLElement>("home-hint").hidden = !home;
  element<HTMLElement>("part-name-line").hidden = rubric !== "wear" || select("part").value !== "other";
  element<HTMLElement>("battery-line").hidden = !(choices?.battery ?? false);
}

/// Pose des champs dans le formulaire de la ligne.
function placeEntry(fields: Partial<EntryFields>): void {
  const values: [string, string | undefined][] = [
    ["date", fields.date],
    ["km", fields.km],
    ["amount", fields.amount],
    ["garage", fields.garage],
    ["note", fields.note],
    ["quantity", fields.quantity],
    ["part-name", fields.part_name],
    ["months", fields.months],
    ["battery", fields.battery],
  ];
  for (const [id, value] of values) {
    if (value !== undefined) {
      field(id).value = value;
    }
  }
  const choices: [string, string | undefined][] = [
    ["rubric", fields.rubric],
    ["energy", fields.energy],
    ["charge", fields.charge],
    ["slot", fields.slot],
    ["part", fields.part],
    ["axle", fields.axle],
    ["verdict", fields.verdict],
  ];
  for (const [id, value] of choices) {
    if (value) {
      select(id).value = value;
    }
  }
  showEntry();
}

/// Une ligne neuve : la date du jour, la rubrique gardée, le reste vide.
function newEntry(): void {
  editing = null;
  const rubric = select("rubric").value;
  placeEntry({
    date: today(),
    km: "",
    amount: "",
    garage: "",
    note: "",
    quantity: "",
    part_name: "",
    months: "",
    battery: "",
    rubric,
    charge: "station",
  });
  showEditing();
}

function showEditing(): void {
  const card = element<HTMLElement>("entry-card");
  card.dataset.editing = String(editing !== null);
  element<HTMLElement>("entry-title").textContent = t(editing === null ? "car-entry-new" : "car-entry-edit");
  element<HTMLElement>("add-label").textContent = t(editing === null ? "car-entry-add" : "car-entry-update");
  element<HTMLElement>("cancel").hidden = editing === null;
  element<HTMLElement>("delete").hidden = editing === null;
  for (const line of document.querySelectorAll<HTMLElement>("#rows tr")) {
    line.classList.toggle("car__row--editing", Number(line.dataset.id) === editing);
  }
}

async function putEntry(): Promise<void> {
  try {
    const result = await invoke<Result>("car_put_entry", { id: editing, entry: entryFields() });
    clearMarks();
    if (result.invalid) {
      markInvalid(result.invalid);
      say(result.message ?? "", true);
      return;
    }
    say("");
    show(result.view);
    newEntry();
  } catch (error) {
    say(String(error), true);
  }
}

async function deleteEntry(): Promise<void> {
  if (editing === null || !(await askYesNo(t("car-delete-question"), t("ui-yes"), t("ui-no")))) {
    return;
  }
  try {
    show(await invoke<View>("car_delete_entry", { id: editing }));
    newEntry();
  } catch (error) {
    say(String(error), true);
  }
}

/// **Prendre une opération** (« oui mais facultatif ») : le compte, puis la
/// dépense ; la date, le montant, le tiers et le libellé remplissent la ligne.
async function takeOperation(): Promise<void> {
  try {
    const accounts = await invoke<{ id: number; label: string }[]>("list_accounts");
    if (accounts.length === 0) {
      return;
    }
    const accountLabel = await askForChoice(
      t("car-pick-account"),
      accounts.map((account) => account.label),
      t("car-pick-take"),
      t("ui-cancel"),
    );
    const account = accounts.find((one) => one.label === accountLabel);
    if (!account) {
      return;
    }
    const expenses = await invoke<{ id: number; text: string; fields: EntryFields }[]>("car_expenses", {
      account: account.id,
    });
    if (expenses.length === 0) {
      say(t("car-pick-none"));
      return;
    }
    const chosen = await askForChoice(
      t("car-pick-operation"),
      expenses.map((expense) => expense.text),
      t("car-pick-take"),
      t("ui-cancel"),
    );
    const expense = expenses.find((one) => one.text === chosen);
    if (!expense) {
      return;
    }
    placeEntry({
      date: expense.fields.date,
      amount: expense.fields.amount,
      garage: expense.fields.garage,
      note: expense.fields.note,
      charge: "station",
    });
    say(t("car-pick-taken"));
  } catch (error) {
    say(String(error), true);
  }
}

// --- L'affichage ------------------------------------------------------------------

function cell(text: string, className = ""): HTMLTableCellElement {
  const td = document.createElement("td");
  td.textContent = text;
  if (className) {
    td.className = className;
  }
  return td;
}

function fillRows(rows: Row[]): void {
  const body = element<HTMLElement>("rows");
  const filter = select("filter").value;
  body.replaceChildren();
  const shown = rows.filter((row) => filter === "" || row.rubric_key === filter);
  for (const row of shown) {
    const line = document.createElement("tr");
    line.dataset.id = String(row.id);
    line.className = "car__row";
    const rubric = cell("");
    const dot = document.createElement("span");
    dot.className = "car__dot";
    dot.style.background = row.colour;
    rubric.append(dot, document.createTextNode(row.rubric));
    line.append(
      cell(row.date),
      cell(row.km, "loan__number"),
      rubric,
      cell(row.detail),
      cell(row.amount, "loan__number"),
      cell(row.garage),
      cell(row.note, "car__note"),
    );
    line.addEventListener("click", () => {
      editing = row.id;
      placeEntry({ ...row.fields, part_name: "" });
      showEditing();
      element<HTMLElement>("entry-card").scrollIntoView({ block: "nearest" });
    });
    body.append(line);
  }
  const empty = element<HTMLElement>("history-empty");
  empty.hidden = rows.length > 0;
  empty.textContent = t("car-history-empty");
  showEditing();
}

function fillLives(target: string, card: string, lives: Life[]): void {
  element<HTMLElement>(card).hidden = lives.length === 0;
  const body = element<HTMLElement>(target);
  body.replaceChildren();
  for (const life of lives) {
    const line = document.createElement("tr");
    line.append(
      cell(life.name),
      cell(life.changes, "loan__number"),
      cell(life.amount, "loan__number"),
      cell(life.last),
      cell(life.life, "loan__number"),
      cell(life.next, "loan__number"),
    );
    body.append(line);
  }
}

/// **Montre le carnet reçu.**
function show(view: View): void {
  current = view;
  fillChoices(view.choices);
  placeCar(view.car);
  const written = view.written;
  element<HTMLElement>("car-title").textContent = written.title;
  element<HTMLElement>("headline").textContent = written.headline;
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

  const deadlines = element<HTMLElement>("deadlines");
  deadlines.replaceChildren();
  for (const deadline of written.deadlines) {
    const item = document.createElement("li");
    item.className = "car__deadline";
    item.dataset.tone = deadline.tone;
    const label = document.createElement("strong");
    label.textContent = deadline.label;
    const when = document.createElement("span");
    when.textContent = deadline.when;
    item.append(label, when);
    if (deadline.badge) {
      const badge = document.createElement("span");
      badge.className = "car__badge";
      badge.textContent = deadline.badge;
      item.append(badge);
    }
    deadlines.append(item);
  }
  if (written.deadlines.length === 0) {
    const item = document.createElement("li");
    item.className = "car__deadline car__deadline--empty";
    item.textContent = written.deadlines_empty;
    deadlines.append(item);
  }

  fillRows(written.rows);
  element<HTMLElement>("donut").innerHTML = written.donut;

  element<HTMLElement>("energy-card").hidden = written.energy.length === 0;
  const energy = element<HTMLElement>("energy-rows");
  energy.replaceChildren();
  for (const line of written.energy) {
    const row = document.createElement("tr");
    row.append(
      cell(line.label),
      cell(line.quantity, "loan__number"),
      cell(line.amount, "loan__number"),
      cell(line.price, "loan__number"),
      cell(line.consumption, "loan__number"),
      cell(line.per_km, "loan__number"),
    );
    energy.append(row);
  }
  fillLives("parts-rows", "parts-card", written.parts);
  fillLives("tyres-rows", "tyres-card", written.tyres);

  element<HTMLElement>("battery-card").hidden = written.battery.length === 0;
  const battery = element<HTMLElement>("battery-list");
  battery.replaceChildren();
  for (const line of written.battery) {
    const item = document.createElement("li");
    item.textContent = line;
    battery.append(item);
  }

  element<HTMLElement>("years-card").hidden = written.rows.length === 0;
  element<HTMLElement>("years").innerHTML = written.years;
  const notes = element<HTMLElement>("notes");
  notes.replaceChildren();
  for (const note of written.notes) {
    const item = document.createElement("li");
    item.textContent = note;
    notes.append(item);
  }
  showEntry();
}

async function reload(): Promise<void> {
  show(await invoke<View>("car_view"));
}

// --- Les mots ---------------------------------------------------------------------

function dress(): void {
  for (const [id, key] of [
    ["sheet-title", "car-sheet-title"],
    ["plate-label", "car-field-plate"],
    ["engine-label", "car-field-engine"],
    ["make-label", "car-field-make"],
    ["model-label", "car-field-model"],
    ["registered-label", "car-field-registered"],
    ["first-hand-label", "car-field-first-hand"],
    ["acquired-label", "car-field-acquired"],
    ["acquired-km-label", "car-field-acquired-km"],
    ["service-label", "car-field-service"],
    ["service-months-unit", "car-unit-months-short"],
    ["service-or-label", "car-field-service-or"],
    ["tariff-title", "car-tariff-title"],
    ["option-label", "appliance-field-option"],
    ["option-base", "appliance-option-base"],
    ["option-off-peak", "appliance-option-off-peak"],
    ["base-label", "appliance-field-base"],
    ["peak-label", "appliance-field-peak"],
    ["off-peak-label", "appliance-field-off-peak"],
    ["hours-label", "appliance-field-off-peak-hours"],
    ["hours-unit", "appliance-unit-hours"],
    ["tariff-hint", "car-tariff-hint"],
    ["tariff-reset", "car-tariff-reset"],
    ["date-label", "car-field-date"],
    ["km-label", "car-field-km"],
    ["rubric-label", "car-field-rubric"],
    ["energy-label", "car-field-energy"],
    ["quantity-label", "car-field-quantity"],
    ["charge-label", "car-field-charge"],
    ["slot-label", "car-field-slot"],
    ["part-label", "car-field-part"],
    ["part-name-label", "car-field-part-name"],
    ["axle-label", "car-field-axle"],
    ["verdict-label", "car-field-verdict"],
    ["months-label", "car-field-months"],
    ["months-unit", "car-unit-months-short"],
    ["amount-label", "car-field-amount"],
    ["home-hint", "car-home-amount-hint"],
    ["battery-label", "car-field-battery"],
    ["garage-label", "car-field-garage"],
    ["note-label", "car-field-note"],
    ["take", "car-from-operation"],
    ["cancel", "car-entry-cancel"],
    ["delete", "car-entry-delete"],
    ["open", "car-open"],
    ["save", "car-save"],
    ["pdf-label", "car-report-button"],
    ["excel", "holiday-excel"],
    ["deadlines-title", "car-deadlines-title"],
    ["history-title", "car-history-title"],
    ["history-hint", "car-history-hint"],
    ["column-date", "car-column-date"],
    ["column-km", "car-column-km"],
    ["column-rubric", "car-column-rubric"],
    ["column-detail", "car-column-detail"],
    ["column-amount", "car-column-amount"],
    ["column-garage", "car-column-garage"],
    ["column-note", "car-column-note"],
    ["rubrics-title", "car-donut-title"],
    ["energy-title", "car-energy-title"],
    ["energy-column-energy", "car-column-energy"],
    ["energy-column-quantity", "car-column-quantity"],
    ["energy-column-amount", "car-column-amount"],
    ["energy-column-price", "car-column-price"],
    ["energy-column-consumption", "car-column-consumption"],
    ["energy-column-per-km", "car-column-per-km"],
    ["parts-title", "car-parts-title"],
    ["tyres-title", "car-tyres-title"],
    ["battery-title", "car-battery-title"],
    ["years-title", "car-years-title"],
    ["disclaimer", "car-disclaimer"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  for (const unit of document.querySelectorAll<HTMLElement>('[data-unit="km"]')) {
    unit.textContent = t("car-unit-km");
  }
  for (const head of document.querySelectorAll<HTMLElement>("[data-lives]")) {
    head.replaceChildren();
    for (const [key, number] of [
      ["car-column-part", false],
      ["car-column-changes", true],
      ["car-column-amount", true],
      ["car-column-last", false],
      ["car-column-life", true],
      ["car-column-next", true],
    ] as const) {
      const th = document.createElement("th");
      th.textContent = t(key);
      if (number) {
        th.className = "loan__number";
      }
      head.append(th);
    }
  }
  showEditing();
  element<HTMLElement>("close").title = t("ui-title-close");
  element<HTMLElement>("pdf").title = t("car-report-button");
}

// --- Les gestes -------------------------------------------------------------------

// **Les champs ne prennent que des chiffres** (Fabrice, 11/10/2026 : « on peut
// écrire des lettres dans un champ numérique, c'est pas bien du tout ») : les
// kilométrages, les mois et l'heure des heures creuses sont des nombres
// entiers ; le prix du kWh a quatre décimales ; la quantité d'un plein et la
// santé de la batterie, deux ; le montant d'une ligne est un montant, écrit
// proprement en sortant.
guardFields({
  "acquired-km": 0,
  "service-months": 0,
  "service-km": 0,
  "tariff-base": 4,
  "tariff-peak": 4,
  "tariff-off-peak": 4,
  "tariff-hours": 0,
  km: 0,
  quantity: 2,
  months: 0,
  amount: "money",
  battery: 2,
});

for (const [id] of CAR_FIELDS) {
  field(id).addEventListener("change", sendCar);
}
for (const [id] of TARIFF_FIELDS) {
  field(id).addEventListener("change", sendCar);
}
for (const id of ["engine", "option"]) {
  select(id).addEventListener("change", () => {
    showTariff();
    sendCar();
  });
}
field("first-hand").addEventListener("change", sendCar);
for (const id of ["rubric", "energy", "charge", "part"]) {
  select(id).addEventListener("change", showEntry);
}
select("filter").addEventListener("change", () => {
  if (current) {
    fillRows(current.written.rows);
  }
});
for (const input of document.querySelectorAll<HTMLInputElement>("#entry-card input")) {
  input.addEventListener("keydown", (event) => {
    if (event.key === "Enter") {
      event.preventDefault();
      void putEntry();
    }
  });
}
element<HTMLButtonElement>("add").addEventListener("click", () => void putEntry());
element<HTMLButtonElement>("cancel").addEventListener("click", () => {
  clearMarks();
  newEntry();
});
element<HTMLButtonElement>("delete").addEventListener("click", () => void deleteEntry());
element<HTMLButtonElement>("take").addEventListener("click", () => void takeOperation());
element<HTMLButtonElement>("tariff-reset").addEventListener("click", () => {
  void (async () => {
    try {
      show(await invoke<View>("car_reset_tariff"));
    } catch (error) {
      say(String(error), true);
    }
  })();
});

/// Un nom de fichier sans ce que les systèmes refusent.
const fileName = (text: string): string => text.replace(/[\\/:*?\x22<>|…]/g, "").trim() || "Radinus";

/// Enregistre le carnet là où l'on choisit. Rend vrai s'il est écrit.
async function saveLogbook(): Promise<boolean> {
  await sending;
  const chosen = await save({
    defaultPath: `${fileName(current?.written.title ?? t("window-car-title"))}.json`,
    filters: [{ name: t("car-file-filter"), extensions: ["json"] }],
  });
  if (chosen === null) {
    return false;
  }
  try {
    say(await invoke<string>("save_car_logbook", { path: chosen }));
    await reload();
    return true;
  } catch (error) {
    say(String(error), true);
    return false;
  }
}

element<HTMLButtonElement>("save").addEventListener("click", () => void saveLogbook());

element<HTMLButtonElement>("open").addEventListener("click", () => {
  void (async () => {
    await sending;
    if (current && !current.empty && !(await askYesNo(t("car-replace-question"), t("ui-yes"), t("ui-no")))) {
      return;
    }
    try {
      const opened = await invoke<{ view: View; message: string } | null>("load_car_logbook");
      if (!opened) {
        return;
      }
      clearMarks();
      show(opened.view);
      newEntry();
      say(opened.message);
    } catch (error) {
      say(String(error), true);
    }
  })();
});

element<HTMLButtonElement>("excel").addEventListener("click", () => {
  void (async () => {
    await sending;
    const chosen = await save({
      defaultPath: `${fileName(current?.written.title ?? t("window-car-title"))}.xlsx`,
      filters: [{ name: "XLSX", extensions: ["xlsx"] }],
    });
    if (chosen === null) {
      return;
    }
    try {
      say(await invoke<string>("export_car", { path: chosen }));
    } catch (error) {
      say(String(error), true);
    }
  })();
});

element<HTMLButtonElement>("pdf").addEventListener("click", () => {
  void (async () => {
    await sending;
    try {
      say(await invoke<string>("print_car_report"));
    } catch (error) {
      say(String(error), true);
    }
  })();
});

/// **La porte demande d'abord** (Fabrice, 10/10/2026 : « confirmation de
/// sortie, pareil que dans les deux autres outils ») : enregistrer le carnet,
/// abandonner, rester — quand le carnet a changé depuis le dernier
/// enregistrement. Puis le carnet est oublié et la fenêtre masquée.
element<HTMLButtonElement>("close").addEventListener("click", () => {
  void (async () => {
    await sending;
    if (current && current.unsaved && !current.empty) {
      const answer = await askThreeWays(
        t("quick-leave-question"),
        t("quick-leave-save"),
        t("quick-leave-discard"),
        t("quick-leave-stay"),
      );
      if (answer === "stay" || (answer === "first" && !(await saveLogbook()))) {
        return;
      }
    }
    try {
      await invoke("close_car_logbook");
      clearMarks();
      say("");
      select("filter").value = "";
      await reload();
      select("rubric").value = "energy";
      newEntry();
    } catch (error) {
      say(tError("ui-close-failed", error), true);
    }
  })();
});

for (const event of ["data-changed:accounts-list", "data-changed:car-logbook"]) {
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
    newEntry();
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
  onLanguageChanged(
    async () => {
      dress();
      await reload();
    },
    { key: "window-car-title" },
  );
})();
