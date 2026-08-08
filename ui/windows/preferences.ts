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

/// Les feuilles de l'arbre.
const LEAVES: [string, string][] = [
  ["language", "preferences-leaf-language"],
  ["currency", "preferences-leaf-currency"],
  ["zoom", "preferences-leaf-zoom"],
];

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
let reserve = { choice: "", custom: "", language: "", zoom: "" };

function current(): { choice: string; custom: string; language: string; zoom: string } {
  return {
    choice: currencyField.value,
    custom: customField.value.trim(),
    language: languageField.value,
    zoom: zoomField.value,
  };
}

function modified(): boolean {
  const now = current();
  return (
    now.choice !== reserve.choice ||
    now.language !== reserve.language ||
    now.zoom !== reserve.zoom ||
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
  if (leaf === "currency" && !databaseOpen) {
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
  const branch = document.createElement("div");
  branch.className = "tree__branch";
  branch.textContent = t("preferences-branch-display");
  tree.append(branch);

  for (const [key, label] of LEAVES) {
    const leaf = document.createElement("button");
    leaf.type = "button";
    leaf.className = "tree__leaf";
    leaf.dataset.leaf = key;
    leaf.textContent = t(label);
    // **Grisée plutôt que cachée** : un arbre qui perd une branche selon d'où
    // l'on vient se cherche ; grise, elle dit que le réglage existe et qu'il
    // demande une base.
    if (key === "currency" && !databaseOpen) {
      leaf.disabled = true;
      leaf.classList.add("tree__leaf--off");
    }
    leaf.addEventListener("click", () => chooseLeaf(key));
    tree.append(leaf);
  }
  // Sans base, la devise ne peut pas être la feuille ouverte au départ.
  if (chosenLeaf === "currency" && !databaseOpen) {
    chosenLeaf = "language";
  }
  chooseLeaf(chosenLeaf);
}

async function load(): Promise<void> {
  try {
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
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
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
