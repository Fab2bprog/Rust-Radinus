// F42 — « Consommation d'un appareil électrique » (Fabrice, 09/10/2026).
//
// « Évaluer combien coûte la consommation d'un appareil électrique », et
// **« un résultat honnête : qui tienne compte de la consommation allumée, ou
// en veille, mais aussi coût heure creuse ou heure pleine »**.
//
// **La fenêtre ne calcule rien.** Elle envoie ses champs tels qu'ils sont
// tapés ; le noyau les lit, calcule, et rend tout écrit dans la langue — les
// tuiles, le détail, l'anneau.
//
// **Aucune valeur supposée** (« je suis contre les tableaux d'appareils et les
// listes d'appareils courants : tu n'as pas les chiffres réels ») : les champs
// de l'appareil partent vides. Les prix du contrat viennent du tarif enregistré
// dans les préférences ; changés ici, **ils ne valent que pour ce calcul**.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { guardFields } from "./money-field";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

interface TariffFields {
  option: string;
  base: string;
  peak: string;
  off_peak: string;
  off_peak_hours: string;
}

interface Tariff {
  fields: TariffFields;
  price_unit: string;
}

interface Period {
  label: string;
  cost: string;
  energy: string;
}

interface Line {
  label: string;
  energy: string;
  cost: string;
  share: string;
  colour: string;
  total: boolean;
}

interface Written {
  periods: Period[];
  lines: Line[];
  donut: string;
  standby_hours: string;
  standby_sentence: string | null;
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

const USAGE_FIELDS = ["on-watts", "on-hours", "days", "share", "standby-watts", "standby-hours"];
const TARIFF_FIELDS = ["base", "peak", "off-peak", "off-peak-hours"];
const field = (id: string): HTMLInputElement => element<HTMLInputElement>(id);
const option = element<HTMLSelectElement>("option");

// --- Le contrat -------------------------------------------------------------------

/// Pose un tarif dans les champs du contrat.
function placeTariff(tariff: Tariff): void {
  option.value = tariff.fields.option;
  field("base").value = tariff.fields.base;
  field("peak").value = tariff.fields.peak;
  field("off-peak").value = tariff.fields.off_peak;
  field("off-peak-hours").value = tariff.fields.off_peak_hours;
  placeUnit(tariff.price_unit);
  showOption();
}

function placeUnit(unit: string): void {
  for (const node of document.querySelectorAll<HTMLElement>('[data-unit="price"]')) {
    node.textContent = unit;
  }
}

/// **Reprend le tarif enregistré** : à l'ouverture, au bouton, et quand les
/// préférences viennent de l'enregistrer.
async function loadSavedTariff(): Promise<void> {
  placeTariff(await invoke<Tariff>("electricity_tariff"));
}

/// En Base, un seul prix ; en heures pleines / heures creuses, deux prix, les
/// heures creuses, et la part de la marche qui y tombe.
function showOption(): void {
  const offPeak = option.value === "off-peak";
  element<HTMLElement>("base-line").hidden = offPeak;
  for (const node of document.querySelectorAll<HTMLElement>("[data-off-peak]")) {
    node.hidden = !offPeak;
  }
  element<HTMLElement>("share-line").hidden = !offPeak;
}

// --- Le calcul ------------------------------------------------------------------

function request(): Record<string, unknown> {
  return {
    usage: {
      on_watts: field("on-watts").value,
      on_hours: field("on-hours").value,
      days: field("days").value,
      share: field("share").value,
      standby_watts: field("standby-watts").value,
      standby_hours: field("standby-hours").value,
    },
    tariff: {
      option: option.value,
      base: field("base").value,
      peak: field("peak").value,
      off_peak: field("off-peak").value,
      off_peak_hours: field("off-peak-hours").value,
    },
  };
}

/// Un seul calcul à la fois, et toujours le dernier demandé.
let running = false;
let again = false;

function compute(): void {
  if (running) {
    again = true;
    return;
  }
  running = true;
  void (async () => {
    try {
      show(await invoke<Result>("appliance_compute", { request: request() }));
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
  const notice = element<HTMLElement>("notice");
  // **Un calcul refusé n'a pas de résultat** (11/10/2026) : les tuiles,
  // l'anneau et le détail d'avant s'estompent tant que le champ n'est pas
  // corrigé, plutôt que de rester affichés comme s'ils étaient justes.
  document.querySelector(".loan")?.classList.toggle("loan--stale", !result.written);
  if (result.invalid || !result.written) {
    if (result.invalid) {
      field(result.invalid).classList.add("form__field--invalid");
    }
    notice.textContent = result.message ?? "";
    notice.hidden = false;
    return;
  }
  notice.hidden = true;
  const written = result.written;

  // Les trois tuiles. Un chiffre qui change s'éclaire un instant.
  const tiles = element<HTMLElement>("tiles");
  const before = new Map<string, string>();
  for (const node of tiles.querySelectorAll<HTMLElement>("[data-label]")) {
    before.set(node.dataset.label ?? "", node.textContent ?? "");
  }
  tiles.replaceChildren();
  for (const period of written.periods) {
    const tile = document.createElement("div");
    tile.className = "loan__tile appliance__tile";
    const label = document.createElement("span");
    label.className = "loan__tile-label";
    label.textContent = period.label;
    const cost = document.createElement("strong");
    cost.className = "loan__tile-value";
    cost.dataset.label = period.label;
    cost.textContent = period.cost;
    if (before.has(period.label) && before.get(period.label) !== period.cost) {
      cost.classList.add("loan__changed");
    }
    const energy = document.createElement("span");
    energy.className = "appliance__energy";
    energy.textContent = period.energy;
    tile.append(label, cost, energy);
    tiles.append(tile);
  }

  const sentence = element<HTMLElement>("standby-sentence");
  sentence.textContent = written.standby_sentence ?? "";
  sentence.hidden = written.standby_sentence === null;

  // Laissé vide, le champ des heures de veille montre en grisé ce qui est
  // retenu : le reste de la journée.
  field("standby-hours").placeholder = written.standby_hours;

  element<HTMLElement>("chart").innerHTML = written.donut;

  const detail = element<HTMLElement>("detail");
  detail.replaceChildren();
  for (const line of written.lines) {
    const row = document.createElement("tr");
    if (line.total) {
      row.className = "appliance__total";
    }
    const name = document.createElement("td");
    if (line.colour) {
      const dot = document.createElement("span");
      dot.className = "appliance__dot";
      dot.style.backgroundColor = line.colour;
      name.append(dot);
    }
    name.append(line.label);
    row.append(name);
    for (const value of [line.energy, line.cost, line.share]) {
      const cell = document.createElement("td");
      cell.className = "appliance__number";
      cell.textContent = value;
      row.append(cell);
    }
    detail.append(row);
  }
}

// --- Les mots -------------------------------------------------------------------

async function dress(): Promise<void> {
  for (const [id, key] of [
    ["device-title", "appliance-device-title"],
    ["on-title", "appliance-on-title"],
    ["standby-title", "appliance-standby-title"],
    ["on-watts-label", "appliance-field-on-watts"],
    ["on-hours-label", "appliance-field-on-hours"],
    ["days-label", "appliance-field-days"],
    ["days-unit", "appliance-unit-days"],
    ["share-label", "appliance-field-share"],
    ["share-unit", "appliance-unit-percent"],
    ["standby-watts-label", "appliance-field-standby-watts"],
    ["standby-hours-label", "appliance-field-standby-hours"],
    ["standby-hint", "appliance-standby-hint"],
    ["contract-title", "appliance-contract-title"],
    ["option-label", "appliance-field-option"],
    ["option-base", "appliance-option-base"],
    ["option-off-peak", "appliance-option-off-peak"],
    ["base-label", "appliance-field-base"],
    ["peak-label", "appliance-field-peak"],
    ["off-peak-label", "appliance-field-off-peak"],
    ["off-peak-hours-label", "appliance-field-off-peak-hours"],
    ["contract-hint", "appliance-contract-hint"],
    ["contract-reset", "appliance-contract-reset"],
    ["chart-title", "appliance-chart-title"],
    ["detail-title", "appliance-detail-title"],
    ["column-part", "appliance-column-part"],
    ["column-energy", "appliance-column-energy"],
    ["column-cost", "appliance-column-cost"],
    ["column-share", "appliance-column-share"],
    ["note-plate", "appliance-note-plate"],
    ["note-subscription", "appliance-note-subscription"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  for (const node of document.querySelectorAll<HTMLElement>('[data-unit="watts"]')) {
    node.textContent = t("appliance-unit-watts");
  }
  for (const node of document.querySelectorAll<HTMLElement>('[data-unit="hours"]')) {
    node.textContent = t("appliance-unit-hours");
  }
  element<HTMLElement>("close").title = t("ui-title-close");
}

// --- Les gestes -----------------------------------------------------------------

// **Les champs ne prennent que des chiffres** (Fabrice, 11/10/2026 : « on peut
// écrire des lettres dans un champ numérique, c'est pas bien du tout ») :
// puissances et durées à deux décimales, la part en heures creuses aussi, le
// prix du kWh à quatre (0,2516 €), les jours et les heures creuses en nombres
// entiers. Rien n'est réécrit en sortant : le noyau lit ce qui est tapé.
guardFields({
  "on-watts": 2,
  "on-hours": 2,
  days: 0,
  share: 2,
  "standby-watts": 2,
  "standby-hours": 2,
  base: 4,
  peak: 4,
  "off-peak": 4,
  "off-peak-hours": 0,
});

for (const id of [...USAGE_FIELDS, ...TARIFF_FIELDS]) {
  // Un champ compte à la validation — Entrée ou la sortie du champ —, pas à
  // chaque touche.
  field(id).addEventListener("change", compute);
  field(id).addEventListener("keydown", (event) => {
    if (event.key === "Enter") {
      field(id).blur();
    }
  });
}
option.addEventListener("change", () => {
  showOption();
  compute();
});
element<HTMLButtonElement>("contract-reset").addEventListener("click", () => {
  void loadSavedTariff()
    .then(compute)
    .catch((error) => say(tError("ui-read-failed", error), true));
});
element<HTMLButtonElement>("close").addEventListener("click", () => {
  void invoke("close_appliance_cost");
});

// Le tarif enregistré vient de changer — dans les préférences, ou parce que
// la base a été restaurée ou effacée sous la fenêtre : on le reprend.
for (const event of ["electricity-tariff-changed", "data-changed:appliance-cost"]) {
  void listen(event, () => {
    void loadSavedTariff().then(compute);
  });
}

void (async () => {
  await loadTexts(null);
  await dress();
  field("days").value = "7";

  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    return;
  }
  try {
    await loadSavedTariff();
    compute();
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
  // La langue change : les mots, l'unité des prix, et le résultat réécrit.
  // Les champs restent tels qu'ils sont tapés.
  onLanguageChanged(
    async () => {
      await dress();
      const tariff = await invoke<Tariff>("electricity_tariff");
      placeUnit(tariff.price_unit);
      compute();
    },
    { key: "window-appliance-title" },
  );
})();
