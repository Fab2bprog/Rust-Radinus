// La fiche d'une base neuve (décision de Fabrice, 04/08/2026).
//
// Ses deux premiers champs vivaient dans un coin du sélecteur, sous le tableau.
// Ils en sortent : **le bouton vert n'ajoute plus, il ouvre**. Une création est
// un geste à part entière, avec ses questions et sa validation, et non un
// formulaire posé à côté d'une liste qu'on est en train de parcourir.
//
// **La devise est le champ neuf.** Elle est une préférence de la base et se
// règle en F39 ; la demander ici évite d'ouvrir une base pour y poser la seule
// chose qu'on savait déjà en la créant. Les mots sont ceux de F39 — deux
// fenêtres qui demandent la même chose la demandent des mêmes mots.

import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { closeCurrentWindow } from "./window-frame";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");
const labelField = element<HTMLInputElement>("label");
const commentField = element<HTMLTextAreaElement>("comment");
const currencyField = element<HTMLSelectElement>("currency");
const customField = element<HTMLInputElement>("custom");
const saveButton = element<HTMLButtonElement>("save");

/// L'archive désignée, ou la chaîne vide. **Retenue et non appliquée** : tant
/// qu'on n'a pas validé, aucune base n'existe et il n'y a rien à remplir.
let archive = "";

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

/// Les neuf choix de devise, dans l'ordre où Fabrice les a dictés pour F39.
/// **La clef part telle quelle en base** : la renommer casserait les bases
/// déjà écrites.
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

/// Ce que « Devise système » vaut sur cette machine. Sans cette ligne, le choix
/// serait aveugle : on coche « système » et l'on ne sait pas ce qu'on aura.
let systemSign = "";

/// Le champ du signe n'existe que pour « Personnalisé ».
function showCustomIfNeeded(): void {
  const wanted = currencyField.value === "perso";
  customField.hidden = !wanted;
  element<HTMLElement>("custom-caption").hidden = !wanted;
}

function showHint(): void {
  const hint = element<HTMLElement>("currency-hint");
  if (currencyField.value !== "systeme") {
    hint.textContent = "";
    return;
  }
  hint.textContent =
    systemSign === ""
      ? t("preferences-currency-system-silent")
      : `${t("preferences-currency-system-is")} ${systemSign}`;
}

/// Rien à valider tant qu'il n'y a pas de nom : le bouton dit de lui-même où
/// l'on en est, sans qu'on ait à essayer.
function updateSaveButton(): void {
  saveButton.disabled = labelField.value.trim() === "";
}

/// **Créer, puis s'effacer.** La fenêtre se ferme et le sélecteur relit sa
/// liste : c'est ce que fait une fiche de Radinus quand on la valide, et la
/// nouvelle base y est déjà choisie quand on y revient.
async function create(): Promise<void> {
  if (labelField.value.trim() === "") {
    say(t("ui-label-required"), true);
    return;
  }
  try {
    const report = await invoke<string>("create_database", {
      label: labelField.value,
      comment: commentField.value,
      currency: currencyField.value,
      custom: customField.value,
      archive,
    });
    // Le sélecteur relit sa liste et choisit la nouvelle : il est le seul à
    // savoir la montrer, et il ne devine pas qu'une base vient de naître.
    await invoke("notify_databases_changed", { said: report });
    closeCurrentWindow();
  } catch (error) {
    say(String(error), true);
  }
}

/// Le nom du fichier choisi, ou la phrase qui dit qu'il n'y en a pas.
///
/// **Le chemin entier ne s'affiche pas** : il est long, il déborderait, et ce
/// qu'on veut vérifier d'un coup d'œil est le nom de l'archive — c'est lui qui
/// porte sa date.
function showChosenBackup(): void {
  const line = element<HTMLElement>("backup-chosen");
  if (archive === "") {
    line.textContent = t("database-no-backup");
    return;
  }
  const parts = archive.split(/[\\/]/);
  line.textContent = parts[parts.length - 1] ?? archive;
}

element<HTMLButtonElement>("choose-backup").addEventListener("click", () => {
  void (async () => {
    try {
      const chosen = await invoke<string | null>("pick_backup_archive");
      // Renoncer au sélecteur ne défait pas un choix précédent : on n'a rien
      // dit, et « rien dit » n'est pas « rien voulu ».
      if (chosen) {
        archive = chosen;
        showChosenBackup();
      }
    } catch (error) {
      say(tError("ui-open-failed", error), true);
    }
  })();
});

saveButton.addEventListener("click", () => void create());
labelField.addEventListener("input", updateSaveButton);
currencyField.addEventListener("change", () => {
  showCustomIfNeeded();
  showHint();
});
element<HTMLButtonElement>("close").addEventListener("click", () => closeCurrentWindow());

window.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    event.preventDefault();
    closeCurrentWindow();
  }
});

/// Pose les mots, puis remet la fiche à neuf.
///
/// **Elle repart vide à chaque ouverture** : une fenêtre de Radinus est bâtie
/// une fois et jamais détruite, et la seconde base porterait le nom de la
/// première si personne ne vidait les champs.
function dress(): void {
  for (const [id, key] of [
    ["group-identity", "database-group-identity"],
    ["group-currency", "preferences-leaf-currency"],
    ["group-restore", "database-group-restore"],
    ["label-caption", "database-field-label"],
    ["comment-caption", "database-field-comment"],
    ["currency-caption", "preferences-field-currency"],
    ["custom-caption", "preferences-field-custom"],
    ["choose-backup", "database-choose-backup"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  showChosenBackup();
  element<HTMLElement>("save").title = t("ui-title-save");
  element<HTMLElement>("close").title = t("ui-title-close");

  const chosen = currencyField.value === "" ? "systeme" : currencyField.value;
  currencyField.replaceChildren();
  for (const [value, key] of CHOICES) {
    const option = document.createElement("option");
    option.value = value;
    option.textContent = t(key);
    currencyField.append(option);
  }
  currencyField.value = chosen;
  showCustomIfNeeded();
  showHint();
  updateSaveButton();
  say("");
}

/// Redemandée alors qu'elle est déjà là : la fiche repart vierge.
void (async () => {
  await loadTexts(null);
  try {
    systemSign = await invoke<string>("system_currency_sign");
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
  dress();
  onLanguageChanged(dress, { key: "window-database-form-title" });
})();

// Rouverte par le bouton vert : elle se vide, sinon elle montrerait la base
// précédente comme si on était en train de la refaire. Une fenêtre de Radinus
// est bâtie une fois et jamais détruite ; c'est cet événement, et lui seul, qui
// lui dit qu'on revient.
void listen("window-parameters:database-form", () => {
  labelField.value = "";
  commentField.value = "";
  currencyField.value = "systeme";
  archive = "";
  dress();
});
