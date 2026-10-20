// L'assistant d'exportation d'une base (P-74, Fabrice, 19/10/2026).
//
// **Quatre pages, une à la fois** : le format, ses options, l'emplacement, le
// récapitulatif. La fenêtre ne fait que recueillir des choix ; tout ce qui
// s'écrit — les fichiers, et chaque phrase qui dépend de la base — vient du
// contrôleur. La clé d'une base protégée ne passe jamais par ici : le
// sélecteur l'a demandée, et Rust la garde le temps de l'assistant.
//
// **Seule la base choisie dans la liste est exportée.** La phrase qui le dit
// reste en tête de toutes les pages ; le titre, le récapitulatif et la phrase
// de fin le redisent.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askYesNo } from "./dialog";
import { closeCurrentWindow } from "./window-frame";
import { loadTexts, onLanguageChanged, t } from "./texts";

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

/// Les formats, dans l'ordre où ils sont proposés : les tableurs d'abord, que
/// tout le monde connaît, les formats de comptes à la fin, avec leur mise en
/// garde.
const FORMATS = ["xlsx", "ods", "csv", "json", "xml", "sql", "sqlite", "qif", "ofx"] as const;
type Format = (typeof FORMATS)[number];

/// Ceux qui laissent choisir entre un fichier et un fichier par table.
const WITH_LAYOUT: readonly Format[] = ["xlsx", "ods", "json", "xml", "sql"];
/// Ceux qui ne gardent pas tout.
const LOSSY: readonly Format[] = ["qif", "ofx"];
const LAST_STEP = 3;

type Intro = { banner: string; protected: boolean };
type Place = { destination: string; folder: boolean; question: string | null };

const infoBar = element<HTMLElement>("info-bar");
const previousButton = element<HTMLButtonElement>("previous");
const nextButton = element<HTMLButtonElement>("next");
const runButton = element<HTMLButtonElement>("run");
const chooseButton = element<HTMLButtonElement>("choose");

/// La base visée, telle que la configuration la nomme, et son intitulé.
let target = "";
let label = "";
let isProtected = false;
let step = 0;
/// L'emplacement choisi — vidé dès que le format ou la disposition change,
/// puisqu'un fichier `.xlsx` ne convient pas à un export en CSV.
let place: Place | null = null;
let running = false;
let exported = false;

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

function readParameters(query: string): void {
  const parameters = new URLSearchParams(query);
  target = parameters.get("path") ?? "";
  label = parameters.get("label") ?? "";
}

function checked(name: string): string {
  return document.querySelector<HTMLInputElement>(`input[name="${name}"]:checked`)?.value ?? "";
}

function check(name: string, value: string): void {
  const input = document.querySelector<HTMLInputElement>(
    `input[name="${name}"][value="${value}"]`,
  );
  if (input) {
    input.checked = true;
  }
}

function format(): Format {
  return (checked("format") || "xlsx") as Format;
}

/// La disposition réellement employée : le CSV, le QIF et l'OFX sont toujours
/// un fichier par table ou par compte, la base SQLite toujours un fichier.
function layout(): string {
  return WITH_LAYOUT.includes(format()) ? checked("layout") || "one-file" : "one-file";
}

/// Les boutons radio des formats, bâtis une fois : un nom et, dessous, une
/// ligne qui dit à quoi il sert.
function buildFormats(): void {
  const holder = element<HTMLElement>("formats");
  holder.replaceChildren();
  for (const key of FORMATS) {
    const line = document.createElement("label");
    line.className = "export-choice";
    const radio = document.createElement("input");
    radio.type = "radio";
    radio.name = "format";
    radio.value = key;
    radio.checked = key === "xlsx";
    radio.addEventListener("change", changed);
    const name = document.createElement("span");
    name.className = "export-choice__name";
    name.dataset.key = `base-export-format-${key}`;
    const hint = document.createElement("span");
    hint.className = "export-choice__hint";
    hint.dataset.key = `base-export-format-${key}-hint`;
    line.append(radio, name, hint);
    holder.append(line);
  }
}

/// **Le séparateur décimal proposé d'abord est celui du système** : une
/// virgule sur un ordinateur réglé en français, un point en anglais. C'est
/// celui qu'attendra le tableur ou Access de la même machine.
function systemUsesComma(): boolean {
  try {
    return new Intl.NumberFormat().format(1.5).includes(",");
  } catch {
    return true;
  }
}

/// Remet l'assistant à sa première page, avec les choix par défaut.
///
/// **Appelée à chaque ouverture** : une fenêtre de Radinus est bâtie une fois
/// et jamais détruite, et les choix faits pour une base ne doivent pas
/// réapparaître pour la suivante — l'emplacement moins que tout.
function blank(): void {
  check("format", "xlsx");
  check("layout", "one-file");
  check("decimal", systemUsesComma() ? "comma" : "point");
  check("quotes", "all");
  check("order", "day-month");
  place = null;
  running = false;
  exported = false;
  step = 0;
  say("");
  show();
}

/// Un choix a changé : l'emplacement ne vaut plus, l'export fait non plus.
function changed(): void {
  place = null;
  exported = false;
  show();
}

/// Ce que dit la ligne « Options » du récapitulatif.
function optionsText(): string {
  switch (format()) {
    case "csv":
      return [
        t(checked("decimal") === "point" ? "base-export-decimal-point" : "base-export-decimal-comma"),
        t(checked("quotes") === "none" ? "base-export-quotes-none" : "base-export-quotes-all"),
      ].join(" ; ");
    case "qif":
      return t(checked("order") === "month-day" ? "base-export-qif-month-day" : "base-export-qif-day-month");
    case "sqlite":
    case "ofx":
      return t("base-export-no-option");
    default:
      return t(layout() === "per-table" ? "base-export-layout-per-table" : "base-export-layout-one");
  }
}

/// Montre la page en cours, et ce que le format choisi y fait paraître.
function show(): void {
  const chosen = format();
  for (const page of document.querySelectorAll<HTMLElement>(".export-page")) {
    page.hidden = Number(page.dataset.page) !== step;
  }
  for (const item of document.querySelectorAll<HTMLElement>("#steps li")) {
    if (Number(item.dataset.step) === step) {
      item.setAttribute("aria-current", "step");
    } else {
      item.removeAttribute("aria-current");
    }
  }

  // Page 1 : la mise en garde des formats qui ne gardent pas tout.
  element<HTMLElement>("lossy").hidden = !LOSSY.includes(chosen);

  // Page 2 : seules les options du format choisi.
  element<HTMLElement>("group-layout").hidden = !WITH_LAYOUT.includes(chosen);
  element<HTMLElement>("group-decimal").hidden = chosen !== "csv";
  element<HTMLElement>("group-quotes").hidden = chosen !== "csv";
  element<HTMLElement>("group-order").hidden = chosen !== "qif";
  element<HTMLElement>("no-option").hidden = chosen !== "sqlite" && chosen !== "ofx";
  element<HTMLElement>("planned-note").hidden = !LOSSY.includes(chosen);
  element<HTMLElement>("dates-hint").hidden = LOSSY.includes(chosen);

  // Page 3 : le bouton dit ce qu'il va choisir — un fichier, ou un dossier.
  const folder = !WITH_LAYOUT.includes(chosen) ? chosen !== "sqlite" : layout() === "per-table";
  chooseButton.textContent = t(folder ? "base-export-choose-folder" : "base-export-choose-file");
  element<HTMLElement>("place-caption").textContent = place
    ? t(place.folder ? "base-export-place-folder" : "base-export-place-file")
    : t("base-export-place-none");
  element<HTMLElement>("place-path").textContent = place?.destination ?? "";

  // Page 4 : le récapitulatif.
  element<HTMLElement>("summary-base").textContent = label;
  element<HTMLElement>("summary-format").textContent = t(`base-export-format-${chosen}`);
  element<HTMLElement>("summary-options").textContent = optionsText();
  element<HTMLElement>("summary-place").textContent = place?.destination ?? "";
  element<HTMLElement>("unprotected").hidden = !isProtected;
  if (!exported) {
    element<HTMLElement>("done").hidden = true;
  }

  previousButton.hidden = step === 0;
  previousButton.disabled = running;
  nextButton.hidden = step === LAST_STEP;
  runButton.hidden = step !== LAST_STEP;
  runButton.disabled = running || exported;
  chooseButton.disabled = running;
}

function go(to: number): void {
  if (running) {
    return;
  }
  // **On ne passe au récapitulatif qu'avec un emplacement** : un bouton
  // « Exporter » qui ne saurait pas où écrire serait une promesse vide.
  if (to === LAST_STEP && place === null) {
    say(t("base-export-place-needed"), true);
    return;
  }
  step = Math.max(0, Math.min(LAST_STEP, to));
  say("");
  show();
}

/// Choisit où écrire. Le dialogue s'ouvre côté Rust, qui propose le nom ;
/// si le dossier existe déjà, il rend la question, et elle est posée ici.
async function choose(): Promise<void> {
  try {
    const picked = await invoke<Place | null>("database_export_destination", {
      label,
      format: format(),
      layout: layout(),
    });
    if (picked === null) {
      return;
    }
    if (picked.question) {
      const replace = await askYesNo(picked.question, t("ui-yes"), t("ui-no"));
      if (!replace) {
        return;
      }
    }
    place = picked;
    exported = false;
    say("");
    show();
  } catch (error) {
    say(String(error), true);
  }
}

async function run(): Promise<void> {
  if (running || exported || place === null) {
    return;
  }
  running = true;
  show();
  say(t("base-export-running"));
  try {
    const said = await invoke<string>("run_database_export", {
      path: target,
      label,
      request: {
        format: format(),
        layout: layout(),
        decimal_comma: checked("decimal") !== "point",
        quote_all: checked("quotes") !== "none",
        date_order: checked("order") || "day-month",
        destination: place.destination,
      },
    });
    exported = true;
    const done = element<HTMLElement>("done");
    done.textContent = said;
    done.hidden = false;
    say(said);
  } catch (error) {
    say(String(error), true);
  } finally {
    running = false;
    show();
  }
}

/// La porte : la clé de la base est oubliée, puis la fenêtre se cache.
/// **Pas pendant l'écriture** : on ne laisse pas un export à moitié fait
/// derrière une fenêtre fermée.
function leave(): void {
  if (running) {
    return;
  }
  void invoke("forget_database_export").catch(() => undefined);
  closeCurrentWindow();
}

for (const name of ["layout", "decimal", "quotes", "order"]) {
  for (const input of document.querySelectorAll<HTMLInputElement>(`input[name="${name}"]`)) {
    // La disposition change la nature de l'emplacement ; les autres options,
    // seulement le contenu — l'emplacement reste bon, l'export fait non.
    input.addEventListener("change", name === "layout" ? changed : () => {
      exported = false;
      show();
    });
  }
}
previousButton.addEventListener("click", () => go(step - 1));
nextButton.addEventListener("click", () => go(step + 1));
runButton.addEventListener("click", () => void run());
chooseButton.addEventListener("click", () => void choose());
element<HTMLButtonElement>("close").addEventListener("click", leave);

window.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    event.preventDefault();
    leave();
  }
});

/// La phrase de tête et la protection de la base, demandées au contrôleur :
/// la phrase porte le nom de la base, et seule Fluent sait où le mettre.
async function introduce(): Promise<void> {
  try {
    const intro = await invoke<Intro>("database_export_intro", { path: target, label });
    element<HTMLElement>("only-this").textContent = intro.banner;
    isProtected = intro.protected;
  } catch (error) {
    say(String(error), true);
  }
  show();
}

/// Pose les mots de la fenêtre, à l'ouverture et à chaque changement de langue.
function dress(): void {
  for (const [id, key] of [
    ["purpose", "base-export-purpose"],
    ["step-format", "base-export-step-format"],
    ["step-options", "base-export-step-options"],
    ["step-place", "base-export-step-place"],
    ["step-summary", "base-export-step-summary"],
    ["lossy", "base-export-lossy"],
    ["layout-title", "base-export-group-layout"],
    ["layout-one", "base-export-layout-one"],
    ["layout-per-table", "base-export-layout-per-table"],
    ["decimal-title", "base-export-group-decimal"],
    ["decimal-comma", "base-export-decimal-comma"],
    ["decimal-point", "base-export-decimal-point"],
    ["quotes-title", "base-export-group-quotes"],
    ["quotes-all", "base-export-quotes-all"],
    ["quotes-none", "base-export-quotes-none"],
    ["csv-hint", "base-export-csv-replacements-hint"],
    ["order-title", "base-export-group-qif-order"],
    ["order-day-month", "base-export-qif-day-month"],
    ["order-month-day", "base-export-qif-month-day"],
    ["order-hint", "base-export-qif-order-hint"],
    ["no-option", "base-export-no-option"],
    ["dates-hint", "base-export-dates-hint"],
    ["planned-note", "base-export-planned-note"],
    ["summary-base-caption", "base-export-summary-base"],
    ["summary-format-caption", "base-export-summary-format"],
    ["summary-options-caption", "base-export-summary-options"],
    ["summary-place-caption", "base-export-summary-place"],
    ["unprotected", "base-export-unprotected"],
    ["previous", "base-export-previous"],
    ["next", "base-export-next"],
    ["run", "base-export-run"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  for (const holder of document.querySelectorAll<HTMLElement>("#formats [data-key]")) {
    holder.textContent = t(holder.dataset.key ?? "");
  }
  element<HTMLElement>("close").title = t("ui-title-close");
  show();
}

void (async () => {
  readParameters(window.location.search);
  buildFormats();
  await loadTexts(null);
  dress();
  blank();
  await introduce();
  onLanguageChanged(async () => {
    dress();
    await introduce();
    try {
      await invoke("retitle", {
        key: "window-database-export-title",
        argument: label,
        argumentName: "base",
      });
    } catch {
      // Le titre reste celui d'avant : la fenêtre, elle, est rhabillée.
    }
  });
})();

// Rouverte sur une autre base : tout repart de la première page.
void listen<string>("window-parameters:database-export", (event) => {
  readParameters(event.payload);
  blank();
  void introduce();
});
