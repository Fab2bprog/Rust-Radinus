// F32 — l'édition et l'impression du relevé d'identité bancaire.
//
// **La fenêtre ne sait rien faire d'autre que montrer et demander.** Elle
// n'écrit rien : ses champs sont en lecture seule, et les deux boutons ne
// font que demander au noyau de composer le RIB du compte. Ce qui s'imprime
// est donc toujours ce que porte la fiche du compte, jamais ce qui traîne à
// l'écran — un état bancaire tiré d'une saisie non enregistrée serait un
// piège.
//
// Les deux boutons sont éteints tant que la déclaration sur l'honneur n'est
// pas cochée (règle de Fabrice, 01/08/2026).

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askForPrinter } from "./printers";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

interface Details {
  bank: string;
  domiciliation: string;
  holder: string;
  holder_address: string;
  establishment: string;
  branch: string;
  number: string;
  key: string;
  iban: string;
  bic: string;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

let accountId = 0;

const declared = element<HTMLInputElement>("declared");
const printButton = element<HTMLButtonElement>("print");
const pdfButton = element<HTMLButtonElement>("pdf");

/// Les deux boutons suivent la case, et rien d'autre.
function followDeclaration(): void {
  printButton.disabled = !declared.checked;
  pdfButton.disabled = !declared.checked;
  say(declared.checked ? t("rib-help") : t("rib-declaration-required"));
}

declared.addEventListener("change", () => followDeclaration());

/// Imprimer : sur l'imprimante par défaut, ou en PDF.
///
/// Le noyau recompose le RIB à chaque fois à partir du compte : ce que la
/// fenêtre affiche n'est jamais renvoyé, il n'y a donc rien à falsifier
/// depuis l'écran.
async function print(toPrinter: boolean): Promise<void> {
  try {
    let printer: string | null = null;
    if (toPrinter) {
      // **On demande sur quelle imprimante** (Fabrice, 01/08/2026), par la
      // même porte que la liste des opérations : `printers.askForPrinter`.
      const choice = await askForPrinter();
      // Renoncer au choix, c'est renoncer à imprimer.
      if (choice.kind === "cancelled") {
        say(t("rib-help"));
        return;
      }
      // Le système n'a su nommer aucune imprimante : on part quand même sur
      // la sortie par défaut plutôt que de bloquer, et on dit pourquoi il n'y
      // a rien eu à choisir.
      if (choice.kind === "default") {
        say(await invoke<string>("print_bank_details", { accountId, toPrinter, printer: null }));
        say(t("print-printers-unknown"));
        return;
      }
      printer = choice.printer;
    }
    say(await invoke<string>("print_bank_details", { accountId, toPrinter, printer }));
  } catch (error) {
    say(String(error), true);
  }
}

printButton.addEventListener("click", () => void print(true));
pdfButton.addEventListener("click", () => void print(false));

element<HTMLButtonElement>("close").addEventListener("click", () => {
  void (async () => {
    try {
      await invoke("close_rib_window");
    } catch (error) {
      say(tError("ui-close-failed", error), true);
    }
  })();
});

function show(details: Details): void {
  const fields: [string, string][] = [
    ["bank", details.bank],
    ["domiciliation", details.domiciliation],
    ["holder", details.holder],
    ["address", details.holder_address],
    ["establishment", details.establishment],
    ["branch", details.branch],
    ["number", details.number],
    ["key", details.key],
    ["bic", details.bic],
    ["iban", details.iban],
  ];
  for (const [id, value] of fields) {
    element<HTMLInputElement | HTMLTextAreaElement>(id).value = value;
  }
}

async function reload(): Promise<void> {
  try {
    const details = await invoke<Details | null>("bank_details", { accountId });
    if (details === null) {
      say(t("rib-account-gone"), true);
      return;
    }
    show(details);
    // La case repart décochée à chaque compte : une déclaration cochée pour un
    // compte ne vaut pas pour le suivant.
    declared.checked = false;
    followDeclaration();
  } catch (error) {
    say(tError("ui-load-failed", error), true);
  }
}

/// **Tous les mots de la fenêtre, posés en un seul endroit.**
///
/// Une fenêtre de Radinus est bâtie une fois et jamais détruite : changer de
/// langue ne la reconstruit pas, il faut qu'elle sache se rhabiller. Ce qui
/// pose un mot est donc ici et nulle part ailleurs — une étiquette ajoutée
/// demain suivra la langue sans que personne y pense.
///
/// `alsoTheNumbers` dit d'où l'on vient. À l'ouverture, le RIB vient plus bas,
/// une fois passée la barrière de `startup_error` et le compte lu dans
/// l'adresse. Au changement de langue, la fenêtre le redemande : la phrase de
/// la barre — l'aide, ou le rappel que la déclaration n'est pas cochée — est
/// écrite par le noyau, et la case repart décochée comme à chaque relecture.
async function dress(alsoTheNumbers = true): Promise<void> {
  for (const [id, key] of [
    ["group-bank", "rib-group-bank"],
    ["group-holder", "rib-group-holder"],
    ["group-details", "rib-group-details"],
    ["group-conditions", "rib-conditions"],
    ["bank-label", "rib-field-bank"],
    ["domiciliation-label", "rib-field-domiciliation"],
    ["holder-label", "rib-field-holder"],
    ["address-label", "rib-field-address"],
    ["establishment-label", "rib-field-establishment"],
    ["branch-label", "rib-field-branch"],
    ["number-label", "rib-field-number"],
    ["key-label", "rib-field-key"],
    ["bic-label", "rib-field-bic"],
    ["iban-label", "rib-field-iban"],
    ["declaration-label", "rib-declaration"],
    ["declaration-first", "rib-declaration-first"],
    ["declaration-second", "rib-declaration-second"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  printButton.title = t("rib-title-print");
  pdfButton.title = t("rib-title-pdf");
  element<HTMLElement>("close").title = t("ui-title-close");
  // Dit une fois pourquoi rien ne se saisit ici, sans attendre une tentative.
  for (const id of ["bank", "domiciliation", "holder", "address"]) {
    element<HTMLElement>(id).title = t("rib-fields-read-only");
  }
  if (alsoTheNumbers) {
    await reload();
  }
}

function readParameters(query: string): void {
  const asked = Number(new URLSearchParams(query).get("account") ?? "0");
  accountId = Number.isFinite(asked) && asked > 0 ? asked : 0;
}

/// Redemandée sur un autre compte : la fenêtre est bâtie une fois et jamais
/// détruite, donc le nouveau compte arrive par un événement. Sans cette
/// écoute, elle imprimerait éternellement le RIB du premier.
void listen<string>("window-parameters:rib", (event) => {
  readParameters(event.payload);
  void reload();
});

void (async () => {
  await loadTexts(null);
  await dress(false);

  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    printButton.disabled = true;
    pdfButton.disabled = true;
    return;
  }
  readParameters(window.location.search);
  await reload();
  onLanguageChanged(dress, { key: "window-rib-title" });
})();
