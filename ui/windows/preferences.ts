// F39 — « Préférences ».
//
// Un arbre à gauche, les champs de l'option choisie au milieu, la disquette et
// la porte à droite. Deux feuilles aujourd'hui, sous une branche « Affichage » :
// la langue et la devise.
//
// **La fenêtre écrit à deux endroits, et c'est voulu** : la devise part dans la
// table `Preferences` (clef `devise`, en JSON), la langue reste dans
// `Parametres.UtiliseLangue` où elle a toujours été. Ce ne sont pas deux
// réglages du même genre — la langue commande aussi les menus de la fenêtre
// principale, que Rust rebâtit lui-même.
//
// **Règle de Fabrice, 03/08/2026 :** rien n'entre dans `Preferences` qu'il
// n'ait demandé d'y mettre. Une préférence de plus se demande, elle ne se
// glisse pas.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { askYesNo } from "./dialog";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";
import { sortByOwnName } from "./languages";

interface Currency {
  choice: string;
  custom: string;
  system: string;
  zoom: number;
  zoom_min: number;
  zoom_max: number;
  zoom_step: number;
  zoom_default: number;
}

interface LanguageRow {
  code: number;
  tag: string;
  name: string;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");
const tree = element<HTMLElement>("tree");
const currencyField = element<HTMLSelectElement>("currency");
const customField = element<HTMLInputElement>("custom");
const languageField = element<HTMLSelectElement>("language");
const zoomField = element<HTMLInputElement>("zoom");
const verificationField = element<HTMLSelectElement>("verification");

/// Le zoom que la base porte. Les bornes viennent du noyau : la fenêtre ne
/// décide pas de ce qui est raisonnable.
let zoomDefault = 1;

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

/// Les cinq choix, dans l'ordre où Fabrice les a dictés. La clef part telle
/// quelle en base : la renommer casserait les bases déjà écrites.
const CHOICES: [string, string][] = [
  ["systeme", "preferences-currency-system"],
  ["EUR", "preferences-currency-euro"],
  ["USD", "preferences-currency-dollar"],
  ["CAD", "preferences-currency-canadian"],
  ["XOF", "preferences-currency-cfa"],
  ["XPF", "preferences-currency-cfp"],
  ["CHF", "preferences-currency-swiss"],
  ["aucune", "preferences-currency-none"],
  ["perso", "preferences-currency-custom"],
];

/// Les feuilles de l'arbre, chacune sous sa branche. Une branche est écrite
/// quand elle change : quatre aujourd'hui, « Affichage », « Importation »,
/// « Outils » (09/10/2026) et « Réinitialisation ».
const LEAVES: [string, string, string][] = [
  ["language", "preferences-leaf-language", "preferences-branch-display"],
  ["currency", "preferences-leaf-currency", "preferences-branch-display"],
  ["zoom", "preferences-leaf-zoom", "preferences-branch-display"],
  ["columns", "preferences-leaf-columns", "preferences-branch-display"],
  ["verification", "preferences-leaf-verification", "preferences-branch-import"],
  ["ofx", "preferences-leaf-ofx", "preferences-branch-import"],
  ["qif", "preferences-leaf-qif", "preferences-branch-import"],
  ["electricity", "preferences-leaf-electricity", "preferences-branch-tools"],
  ["comfort", "preferences-leaf-comfort", "preferences-branch-reset"],
];

/// **Les feuilles qui appartiennent à la base** : sans base ouverte, elles
/// n'ont rien à montrer et rien à écrire. La devise, et la vérification des
/// opérations importées, les colonnes, et le tarif d'électricité.
const NEEDS_A_DATABASE = ["currency", "verification", "columns", "electricity"];

/// Les deux seules réponses de la feuille « Vérification », par leur clef dans
/// `Verification` : 2, vérifiée — le défaut — et 1, à vérifier. « Douteuse »
/// et « Contestée » sont des jugements ; un import n'en porte pas.
const IMPORT_VERIFICATIONS = [2, 1];

let chosenLeaf = "currency";

/// **Une base est-elle ouverte ?** La devise est une préférence de la base ;
/// sans base, sa feuille n'a rien à montrer et rien à écrire.
///
/// La fenêtre pose la question elle-même plutôt que de recevoir un drapeau
/// « je viens du sélecteur » (Fabrice, 04/08/2026) : la règle devient vraie
/// partout — y compris sur un chemin qu'on n'a pas prévu — et il n'y a pas
/// deux façons d'ouvrir la même fenêtre.
let databaseOpen = true;

/// **La réserve** : ce que la base disait quand on est arrivé. La fenêtre se
/// sait modifiée en comparant champ à champ, la méthode que Fabrice a imposée
/// le 25/07/2026 — et non par un drapeau levé à la première frappe, qui
/// resterait levé après un aller-retour.
let reserve = {
  choice: "",
  custom: "",
  language: "",
  zoom: "",
  verification: "",
  electricity: "",
  qifOrder: "",
  qifLabel: "",
  ofxLabel: "",
  ofxReference: "",
};

/// Les deux réglages des relevés OFX (19/10/2026).
const ofxLabelField = element<HTMLSelectElement>("ofx-label");
const ofxReferenceField = element<HTMLSelectElement>("ofx-reference");

/// Les deux réglages des relevés QIF (P-73).
const qifOrderField = element<HTMLSelectElement>("qif-order");
const qifLabelField = element<HTMLSelectElement>("qif-label");

function current(): {
  choice: string;
  custom: string;
  language: string;
  zoom: string;
  verification: string;
  electricity: string;
  qifOrder: string;
  qifLabel: string;
  ofxLabel: string;
  ofxReference: string;
} {
  return {
    choice: currencyField.value,
    custom: customField.value.trim(),
    language: languageField.value,
    zoom: zoomField.value,
    verification: verificationField.value,
    // Les cinq champs du tarif, en un seul texte : la fenêtre se sait
    // modifiée en comparant, comme pour les autres feuilles.
    electricity: JSON.stringify(electricityFields()),
    qifOrder: qifOrderField.value,
    qifLabel: qifLabelField.value,
    ofxLabel: ofxLabelField.value,
    ofxReference: ofxReferenceField.value,
  };
}

// --- Le tarif d'électricité (Fabrice, 09/10/2026) ---------------------------------

interface ElectricityTariff {
  fields: {
    option: string;
    base: string;
    peak: string;
    off_peak: string;
    off_peak_hours: string;
  };
  price_unit: string;
}

const electricityOption = element<HTMLSelectElement>("electricity-option");
const electricityField = (name: string): HTMLInputElement =>
  element<HTMLInputElement>(`electricity-${name}`);

function electricityFields(): ElectricityTariff["fields"] {
  return {
    option: electricityOption.value,
    base: electricityField("base").value.trim(),
    peak: electricityField("peak").value.trim(),
    off_peak: electricityField("off-peak").value.trim(),
    off_peak_hours: electricityField("off-peak-hours").value.trim(),
  };
}

function placeElectricity(tariff: ElectricityTariff): void {
  electricityOption.value = tariff.fields.option;
  electricityField("base").value = tariff.fields.base;
  electricityField("peak").value = tariff.fields.peak;
  electricityField("off-peak").value = tariff.fields.off_peak;
  electricityField("off-peak-hours").value = tariff.fields.off_peak_hours;
  for (const unit of document.querySelectorAll<HTMLElement>("[data-price-unit]")) {
    unit.textContent = tariff.price_unit;
  }
  showElectricityOption();
}

/// En Base, un seul prix ; en heures pleines / heures creuses, deux prix et
/// le nombre d'heures creuses.
function showElectricityOption(): void {
  const offPeak = electricityOption.value === "off-peak";
  for (const [name, shown] of [
    ["base", !offPeak],
    ["peak", offPeak],
    ["off-peak", offPeak],
    ["off-peak-hours", offPeak],
  ] as const) {
    element<HTMLElement>(`electricity-${name}-line`).hidden = !shown;
    element<HTMLElement>(`electricity-${name}-label`).hidden = !shown;
  }
}

function modified(): boolean {
  const now = current();
  return (
    now.choice !== reserve.choice ||
    now.language !== reserve.language ||
    now.zoom !== reserve.zoom ||
    now.verification !== reserve.verification ||
    now.electricity !== reserve.electricity ||
    now.qifOrder !== reserve.qifOrder ||
    now.qifLabel !== reserve.qifLabel ||
    now.ofxLabel !== reserve.ofxLabel ||
    now.ofxReference !== reserve.ofxReference ||
    // Le signe personnalisé ne compte que si c'est lui qu'on emploie : l'avoir
    // tapé puis avoir choisi « Euros » ne modifie rien.
    (now.choice === "perso" && now.custom !== reserve.custom)
  );
}

/// **Ce qu'un signe de devise n'a pas le droit de contenir**, et ce n'est pas
/// une question de goût.
///
/// Le signe est aussi **ôté** par le noyau quand il lit une saisie, pour qu'on
/// puisse recopier « 1 549,81 $ » depuis sa propre fenêtre. Un signe qui
/// ressemble à un morceau de nombre corrompt donc les montants tapés : avec
/// « 0 » pour signe, taper `120` enregistre **12** ; avec « - », taper `-12`
/// enregistre un **crédit** de 12. Des chiffres justes, faux, sans un mot.
///
/// Trois barrières, comme pour le champ monétaire que Fabrice a fait doubler
/// le 25/07/2026 : celle-ci refuse à la frappe, le contrôleur refuse d'écrire,
/// et le noyau refuse une troisième fois d'afficher — un JSON modifié à la
/// main dans la base ne doit pas passer davantage.
// `\p{N}` et non `\p{Nd}` : le noyau refuse **tout** ce qui est numérique,
// « ½ » et « ² » compris, et les deux barrières doivent refuser la même
// chose — sinon le champ laisse passer ce que l'enregistrement refusera.
const FORBIDDEN_IN_SIGN = /[\p{N}\-+,.()]/gu;

/// Nettoie ce qui vient d'être tapé, collé ou dicté.
///
/// **On retire, on ne refuse pas.** Un champ qui ignore la touche laisserait
/// croire au clavier cassé ; un champ qui efface ce qu'on vient de coller
/// montre ce qu'il a gardé. La barre d'information dit pourquoi, sinon
/// l'utilisateur voit son texte maigrir sans comprendre.
function cleanSign(): void {
  const typed = customField.value;
  const kept = typed.replace(FORBIDDEN_IN_SIGN, "");
  if (kept !== typed) {
    const at = customField.selectionStart ?? kept.length;
    customField.value = kept;
    const moved = Math.max(0, at - (typed.length - kept.length));
    customField.setSelectionRange(moved, moved);
    say(t("preferences-sign-not-a-number"), true);
  }
}

/// Le champ du signe n'existe que pour « Personnalisé ».
function showCustomIfNeeded(): void {
  const wanted = currencyField.value === "perso";
  customField.hidden = !wanted;
  element<HTMLElement>("custom-label").hidden = !wanted;
  if (wanted) {
    customField.focus();
  }
}

/// Ce que « Devise système » vaut sur cette machine, dit en toutes lettres.
///
/// **Sans cela le choix serait aveugle** : on coche « devise système » et l'on
/// ne sait pas ce qu'on aura. Et quand le système ne répond rien — ce qui
/// arrive sur un macOS lancé depuis le Finder, sans langue dans son
/// environnement —, la fenêtre le dit plutôt que de laisser croire.
let systemSign = "";

function showHint(): void {
  const hint = element<HTMLElement>("currency-hint");
  if (currencyField.value !== "systeme") {
    hint.textContent = "";
    return;
  }
  hint.textContent = systemSign === "" ? t("preferences-currency-system-silent") : "";
  if (systemSign !== "") {
    hint.textContent = t("preferences-currency-system-is") + " " + systemSign;
  }
}

/// Le pourcentage en chiffres, et le bouton qui n'a plus rien à faire quand on
/// est déjà à la valeur par défaut.
function showZoom(): void {
  const factor = Number(zoomField.value);
  element<HTMLElement>("zoom-value").textContent = `${Math.round(factor * 100)} %`;
  element<HTMLButtonElement>("zoom-reset").disabled = factor === zoomDefault;
}

function chooseLeaf(leaf: string): void {
  // Une feuille éteinte ne s'ouvre pas : on reste où l'on est.
  if (NEEDS_A_DATABASE.includes(leaf) && !databaseOpen) {
    return;
  }
  chosenLeaf = leaf;
  for (const [key] of LEAVES) {
    element<HTMLElement>(`pane-${key}`).hidden = key !== leaf;
  }
  for (const button of tree.querySelectorAll(".tree__leaf")) {
    button.classList.toggle(
      "tree__leaf--chosen",
      (button as HTMLElement).dataset.leaf === leaf,
    );
  }
}

function buildTree(): void {
  tree.replaceChildren();
  let written = "";

  for (const [key, label, under] of LEAVES) {
    if (under !== written) {
      const branch = document.createElement("div");
      branch.className = "tree__branch";
      branch.textContent = t(under);
      tree.append(branch);
      written = under;
    }
    const leaf = document.createElement("button");
    leaf.type = "button";
    leaf.className = "tree__leaf";
    leaf.dataset.leaf = key;
    leaf.textContent = t(label);
    // **Grisée plutôt que cachée** : un arbre qui perd une branche selon d'où
    // l'on vient se cherche ; grise, elle dit que le réglage existe et qu'il
    // demande une base.
    if (NEEDS_A_DATABASE.includes(key) && !databaseOpen) {
      leaf.disabled = true;
      leaf.classList.add("tree__leaf--off");
    }
    leaf.addEventListener("click", () => chooseLeaf(key));
    tree.append(leaf);
  }
  // Sans base, la devise ne peut pas être la feuille ouverte au départ.
  if (NEEDS_A_DATABASE.includes(chosenLeaf) && !databaseOpen) {
    chosenLeaf = "language";
  }
  chooseLeaf(chosenLeaf);
}

/// **Le menu déroulant des fenêtres dont on règle les colonnes**, et un seul
/// bouton « Réinitialiser » pour celle qu'il nomme (Fabrice, 04/10/2026 : « un
/// menu déroulant indiquant le nom de la fenêtre et un bouton réinitialiser
/// qui pointe sur le menu déroulant »).
///
/// **Des fenêtres, et non des tableaux** : « on réinitialise les tableaux
/// contenus dans une fenêtre. Demain il peut y en avoir plusieurs dans une
/// fenêtre. » Le bouton envoie donc le nom de la fenêtre, et c'est le noyau
/// qui sait quels tableaux elle porte.
///
/// La liste vient du noyau, chaque fenêtre avec son libellé déjà dit dans la
/// langue en cours : en ajouter une là-bas l'ajoute ici, sans toucher à cette
/// page.
///
/// **Les boutons agissent tout de suite**, sans passer par la disquette et
/// sans question : le geste est sans gravité, et c'est le filet de celui qui
/// ne comprend plus son tableau. Ni le menu ni les boutons ne « modifient »
/// donc la fenêtre — la quitter après ne demande rien.
async function showTableLayouts(): Promise<void> {
  const field = element<HTMLSelectElement>("columns-window");
  // La fenêtre se relit en revenant à l'écran : ce qu'on avait choisi reste
  // choisi.
  const chosen = field.value;
  const windows = databaseOpen
    ? await invoke<{ name: string; label: string }[]>("windows_with_table_layouts")
    : [];
  field.replaceChildren();
  for (const { name, label } of windows) {
    const option = document.createElement("option");
    option.value = name;
    option.textContent = label;
    field.append(option);
  }
  if (windows.some((one) => one.name === chosen)) {
    field.value = chosen;
  }
}

async function load(): Promise<void> {
  try {
    await showTableLayouts();

    const currency = await invoke<Currency>("preferences_currency");
    systemSign = currency.system;

    currencyField.replaceChildren();
    for (const [value, label] of CHOICES) {
      const option = document.createElement("option");
      option.value = value;
      option.textContent = t(label);
      currencyField.append(option);
    }
    currencyField.value = currency.choice;
    customField.value = currency.custom;

    // Les bornes et le pas viennent du noyau : la fenêtre ne décide pas de ce
    // qui est raisonnable, elle montre ce qu'on lui donne.
    zoomField.min = String(currency.zoom_min);
    zoomField.max = String(currency.zoom_max);
    zoomField.step = String(currency.zoom_step);
    zoomField.value = String(currency.zoom);
    zoomDefault = currency.zoom_default;
    showZoom();

    const languages = await invoke<LanguageRow[]>("available_languages");
    // Le même ordre qu'au premier lancement : c'est la même liste, elle se
    // lit pareil. Voir `sortByOwnName` dans `languages.ts`.
    sortByOwnName(languages);
    const now = await invoke<LanguageRow>("current_language");
    languageField.replaceChildren();
    for (const language of languages) {
      const option = document.createElement("option");
      option.value = String(language.code);
      // Chaque langue écrite dans la sienne — la règle du premier lancement.
      option.textContent = language.name;
      languageField.append(option);
    }
    languageField.value = String(now.code);

    // La vérification des opérations importées. Ses deux mots sont ceux de la
    // colonne, lus à la même source ; sans base, la feuille est grise et l'on
    // ne lit rien.
    verificationField.replaceChildren();
    if (databaseOpen) {
      const words = await invoke<{ id: number; label: string }[]>("list_operation_verifications");
      for (const id of IMPORT_VERIFICATIONS) {
        const option = document.createElement("option");
        option.value = String(id);
        option.textContent = words.find((word) => word.id === id)?.label ?? String(id);
        verificationField.append(option);
      }
      verificationField.value = String(await invoke<number>("preferences_import_verification"));
      placeElectricity(await invoke<ElectricityTariff>("electricity_tariff"));
    }

    // Les relevés QIF : des réglages du logiciel, lus même sans base.
    const qif = await invoke<{ order: string; label: string }>("preferences_qif");
    qifOrderField.value = qif.order;
    qifLabelField.value = qif.label;
    // Les relevés OFX : réglages du logiciel aussi.
    const ofx = await invoke<{ label: string; reference: string }>("preferences_ofx");
    ofxLabelField.value = ofx.label;
    ofxReferenceField.value = ofx.reference;

    reserve = current();
    showCustomIfNeeded();
    showHint();
    say(t("preferences-help"));
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

async function save(): Promise<void> {
  const now = current();
  // Un « Personnalisé » sans signe n'écrit rien de bon : on le dit plutôt que
  // d'enregistrer un montant qui n'annoncerait aucune devise.
  if (now.choice === "perso" && now.custom === "") {
    say(t("preferences-custom-required"), true);
    customField.focus();
    return;
  }
  try {
    // **La vérification des imports part en premier.** Enregistrer la langue
    // ou la devise fait revenir l'événement de changement de langue, et la
    // fenêtre se relit alors d'elle-même : ce qu'elle relit doit déjà être
    // ce qu'on vient de choisir, sinon le champ reviendrait à l'ancienne
    // valeur sous les yeux de l'utilisateur.
    // **Le tarif d'électricité aussi**, et lui peut être refusé : un prix
    // illisible arrête l'enregistrement avant que rien d'autre ne parte.
    if (databaseOpen && now.electricity !== reserve.electricity) {
      try {
        await invoke("save_preferences_electricity", { tariff: electricityFields() });
      } catch (error) {
        chooseLeaf("electricity");
        say(String(error), true);
        return;
      }
    }
    // Les réglages QIF ne demandent pas de base : ils vivent dans la
    // configuration du logiciel.
    if (now.qifOrder !== reserve.qifOrder || now.qifLabel !== reserve.qifLabel) {
      await invoke("save_preferences_qif", { order: now.qifOrder, label: now.qifLabel });
    }
    if (now.ofxLabel !== reserve.ofxLabel || now.ofxReference !== reserve.ofxReference) {
      await invoke("save_preferences_ofx", { label: now.ofxLabel, reference: now.ofxReference });
    }
    if (databaseOpen && now.verification !== reserve.verification) {
      await invoke("save_preferences_import_verification", {
        verificationId: Number(now.verification),
      });
    }
    if (now.language !== reserve.language) {
      await invoke("set_language", { code: Number(now.language) });
    }
    // **Rien n'est écrit dans une base qui n'est pas ouverte.** Sans elle, la
    // feuille de la devise est grise et ce qu'affichent ses champs est un
    // défaut, pas un choix : l'enregistrer le graverait dans la première base
    // ouverte ensuite.
    if (databaseOpen) {
      await invoke("save_preferences_currency", {
        choice: now.choice,
        custom: now.custom,
      });
    }
    if (now.zoom !== reserve.zoom) {
      // **Le zoom part en dernier.** Il repeint toutes les fenêtres, celle-ci
      // comprise : ce qui se passe après serait vu au travers d'un écran qui
      // bouge sous les yeux de l'utilisateur.
      await invoke("save_preferences_zoom", { factor: Number(now.zoom) });
    }
    reserve = now;
    say(t("preferences-saved"));
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

async function leave(): Promise<void> {
  if (modified() && !(await askYesNo(t("ui-discard-question"), t("ui-yes"), t("ui-no")))) {
    return;
  }
  void invoke("close_preferences");
}

// `input` et non `keydown` : il attrape la frappe, mais aussi le collage, la
// dictée et le glisser-déposer — tout ce par quoi un texte entre dans un champ.
customField.addEventListener("input", cleanSign);
zoomField.addEventListener("input", showZoom);
element<HTMLButtonElement>("zoom-reset").addEventListener("click", () => {
  zoomField.value = String(zoomDefault);
  showZoom();
});

currencyField.addEventListener("change", () => {
  showCustomIfNeeded();
  showHint();
});
element<HTMLButtonElement>("columns-reset").addEventListener("click", () => {
  const window = element<HTMLSelectElement>("columns-window").value;
  if (window === "") {
    return;
  }
  invoke("reset_window_table_layouts", { window })
    .then(() => say(t("preferences-columns-done")))
    .catch((error) => say(tError("ui-save-failed", error), true));
});
element<HTMLButtonElement>("columns-reset-all").addEventListener("click", () => {
  invoke("reset_all_table_layouts")
    .then(() => say(t("preferences-columns-done")))
    .catch((error) => say(tError("ui-save-failed", error), true));
});
/// **« Réinitialiser les réglages de confort »** (Fabrice, 07/10/2026).
///
/// Le seul bouton de réinitialisation qui pose une question : il défait d'un
/// coup les colonnes de tous les tableaux, l'accueil et la taille — ce que
/// l'utilisateur a mis des semaines à ajuster — et rien ne le rend.
///
/// **Il agit tout de suite**, comme ceux des colonnes, sans passer par la
/// disquette. Et il ne touche à aucun champ en cours de saisie, sauf la
/// taille, qu'il vient de remettre lui-même : une langue ou une devise
/// choisies mais pas encore enregistrées restent choisies.
async function resetComfort(): Promise<void> {
  if (!(await askYesNo(t("preferences-comfort-question"), t("ui-yes"), t("ui-no")))) {
    return;
  }
  try {
    await invoke("reset_comfort_settings");
    zoomField.value = String(zoomDefault);
    reserve.zoom = zoomField.value;
    showZoom();
    say(t("preferences-comfort-done"));
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}
element<HTMLButtonElement>("comfort-reset").addEventListener("click", () => void resetComfort());
electricityOption.addEventListener("change", showElectricityOption);
/// **« Revenir au Tarif Bleu EDF »** : remplit les champs, sans enregistrer —
/// la disquette s'en charge, comme pour tout le reste de la feuille.
element<HTMLButtonElement>("electricity-blue").addEventListener("click", () => {
  invoke<ElectricityTariff>("electricity_blue_tariff")
    .then(placeElectricity)
    .catch((error) => say(tError("ui-read-failed", error), true));
});
element<HTMLButtonElement>("save").addEventListener("click", () => void save());
element<HTMLButtonElement>("close").addEventListener("click", () => void leave());

window.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    event.preventDefault();
    void leave();
  }
});

/// Pose les mots, rebâtit l'arbre, et relit.
///
/// Appelée à l'ouverture et à chaque changement de langue — **y compris celui
/// qu'on vient de faire soi-même** : enregistrer une nouvelle langue fait
/// revenir cet événement, et la fenêtre se rhabille dans la langue qu'elle
/// vient de choisir, sous les yeux de l'utilisateur.
async function dress(): Promise<void> {
  for (const [id, key] of [
    ["language-title", "preferences-leaf-language"],
    ["currency-title", "preferences-leaf-currency"],
    ["language-label", "preferences-field-language"],
    ["currency-label", "preferences-field-currency"],
    ["custom-label", "preferences-field-custom"],
    ["zoom-title", "preferences-leaf-zoom"],
    ["zoom-label", "preferences-field-zoom"],
    ["zoom-hint", "preferences-zoom-hint"],
    ["zoom-reset", "preferences-zoom-reset"],
    ["verification-title", "preferences-leaf-verification"],
    ["verification-label", "preferences-field-verification"],
    ["verification-hint", "preferences-verification-hint"],
    ["columns-title", "preferences-leaf-columns"],
    ["columns-reset", "preferences-columns-reset"],
    ["columns-reset-all", "preferences-columns-reset-all"],
    ["columns-hint", "preferences-columns-hint"],
    ["electricity-title", "preferences-leaf-electricity"],
    ["electricity-option-label", "appliance-field-option"],
    ["electricity-option-base", "appliance-option-base"],
    ["electricity-option-off-peak", "appliance-option-off-peak"],
    ["electricity-base-label", "appliance-field-base"],
    ["electricity-peak-label", "appliance-field-peak"],
    ["electricity-off-peak-label", "appliance-field-off-peak"],
    ["electricity-off-peak-hours-label", "appliance-field-off-peak-hours"],
    ["electricity-hours-unit", "appliance-unit-hours"],
    ["electricity-blue", "preferences-electricity-blue"],
    ["electricity-hint", "preferences-electricity-hint"],
    ["ofx-title", "preferences-leaf-ofx"],
    ["ofx-label-label", "preferences-field-ofx-label"],
    ["ofx-label-name", "preferences-ofx-choice-name"],
    ["ofx-label-memo", "preferences-ofx-choice-memo"],
    ["ofx-label-name-and-memo", "preferences-ofx-choice-name-and-memo"],
    ["ofx-reference-label", "preferences-field-ofx-reference"],
    ["ofx-reference-memo", "preferences-ofx-choice-memo"],
    ["ofx-reference-name", "preferences-ofx-choice-name"],
    ["ofx-reference-name-and-memo", "preferences-ofx-choice-name-and-memo"],
    ["ofx-reference-empty", "preferences-ofx-choice-empty"],
    ["ofx-hint", "preferences-ofx-hint"],
    ["qif-title", "preferences-leaf-qif"],
    ["qif-order-label", "preferences-field-qif-order"],
    ["qif-order-ask", "preferences-qif-order-ask"],
    ["qif-order-day-month", "preferences-qif-order-day-month"],
    ["qif-order-month-day", "preferences-qif-order-month-day"],
    ["qif-label-label", "preferences-field-qif-label"],
    ["qif-label-both", "preferences-qif-label-both"],
    ["qif-label-payee", "preferences-qif-label-payee"],
    ["qif-label-memo", "preferences-qif-label-memo"],
    ["qif-hint", "preferences-qif-hint"],
    ["comfort-title", "preferences-leaf-comfort"],
    ["comfort-reset", "preferences-comfort-reset"],
    ["comfort-hint", "preferences-comfort-hint"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  // **Chaque réglage QIF a sa bulle**, sur l'étiquette et sur la liste.
  for (const [ids, key] of [
    [["ofx-label-label", "ofx-label"], "preferences-ofx-label-help"],
    [["ofx-reference-label", "ofx-reference"], "preferences-ofx-reference-help"],
    [["qif-order-label", "qif-order"], "preferences-qif-order-help"],
    [["qif-label-label", "qif-label"], "preferences-qif-label-help"],
  ] as const) {
    for (const id of ids) {
      element<HTMLElement>(id).title = t(key);
    }
  }
  element<HTMLElement>("save").title = t("ui-title-save");
  element<HTMLElement>("close").title = t("ui-title-close");

  // **La question avant l'arbre** : c'est elle qui décide si la feuille de la
  // devise est grise, et un arbre bâti avant la réponse la montrerait vivante
  // le temps d'un battement de cil, puis grise. Une fenêtre qui se contredit à
  // l'ouverture donne à douter de tout le reste.
  databaseOpen = await invoke<boolean>("database_is_open").catch(() => true);
  buildTree();

  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    return;
  }
  await load();
}

// **Elle se relit en revenant à l'écran** (05/08/2026).
//
// Elle montre deux choses de nature différente : la langue et la taille de
// l'affichage, qui appartiennent au logiciel, et la devise, qui appartient à la
// **base**. C'est la devise qui l'oblige à ce filet — rouverte après un
// changement de base, elle montrerait celle de la précédente, et la feuille
// grisée ou vivante suivrait un état qui n'est plus vrai.
//
// Le même filet que l'accueil et que les soldes : une fenêtre qu'on remontre
// reprend le focus. `dress` et non `load`, parce qu'il faut aussi redemander si
// une base est ouverte — c'est cette réponse qui décide de la feuille grise.
window.addEventListener("focus", () => void dress());

void (async () => {
  await loadTexts(null);
  await dress();
  onLanguageChanged(dress, { key: "window-preferences-title" });
})();
