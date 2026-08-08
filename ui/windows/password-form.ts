// La fiche du mot de passe d'une base (décision de Fabrice, 05/08/2026).
//
// **Trois champs, une seule fiche, trois gestes.** L'ancien mot de passe reste
// vide quand la base n'en a pas ; les deux nouveaux restent vides quand on veut
// retirer la protection ; les trois sont remplis quand on la change. C'est la
// procédure de saisie que tout le monde connaît, et Fabrice l'a demandée telle
// quelle : « je n'invente rien ».
//
// **Rien n'est jugé ici.** L'égalité des deux nouvelles saisies, la validité de
// l'ancien mot de passe, ce que l'opération a produit : tout est décidé par le
// contrôleur, qui rend une phrase déjà écrite dans la langue en cours. La
// fenêtre pose la seule question qu'elle ait le droit de poser — celle du
// retrait, parce qu'elle porte sur ce que l'utilisateur vient de taper et
// qu'aucun aller-retour ne rendrait plus sûr.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askYesNo } from "./dialog";
import { closeCurrentWindow } from "./window-frame";
import { loadTexts, onLanguageChanged, t } from "./texts";

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");
const oldField = element<HTMLInputElement>("old");
const freshField = element<HTMLInputElement>("fresh");
const repeatField = element<HTMLInputElement>("repeat");
const revealBox = element<HTMLInputElement>("reveal");

/// La base visée, telle que la configuration la nomme — un chemin relatif à la
/// racine portable, comme partout ailleurs.
let target = "";
/// Son intitulé, pour que la fiche dise sur quoi elle travaille.
let label = "";

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

function readParameters(query: string): void {
  const parameters = new URLSearchParams(query);
  target = parameters.get("path") ?? "";
  label = parameters.get("label") ?? "";
}

/// Remet les trois champs à blanc.
///
/// **Appelée à chaque ouverture**, et c'est indispensable : une fenêtre de
/// Radinus est bâtie une fois et jamais détruite, et sans cette remise à zéro
/// le mot de passe d'une base resterait tapé dans la fiche de la suivante.
function blank(): void {
  oldField.value = "";
  freshField.value = "";
  repeatField.value = "";
  // **La case repart décochée**, comme les champs repartent vides : la fenêtre
  // est bâtie une fois et jamais détruite, et un mot de passe à découvert
  // parce que la base précédente l'était serait le contraire de ce qu'on
  // demande à cette fiche.
  revealBox.checked = false;
  reveal();
  say("");
}

/// Montre ou masque **les trois champs** (correction de Fabrice, 05/08/2026).
///
/// J'avais réservé la case à la saisie double, en me disant que l'ancien mot
/// de passe, on le connaît déjà. Le raisonnement était faux : on le tape tout
/// aussi à l'aveugle, et une base qui refuse de s'ouvrir sans qu'on sache si
/// c'est le doigt ou la mémoire qui a fauté est exactement ce que cette case
/// est là pour éviter. Qui est seul dans la pièce veut voir ce qu'il tape,
/// partout.
function reveal(): void {
  const kind = revealBox.checked ? "text" : "password";
  oldField.type = kind;
  freshField.type = kind;
  repeatField.type = kind;
}

/// Applique ce qui est tapé.
///
/// La seule question posée d'ici est celle du **retrait** : les deux nouveaux
/// champs vides veulent dire « que cette base ne soit plus protégée », et cela
/// se demande une fois. Tout le reste — les deux saisies qui diffèrent, l'ancien
/// mot de passe qui ne convient pas, ce qui s'est passé — est écrit par le
/// contrôleur.
async function apply(): Promise<void> {
  const removing = freshField.value === "" && repeatField.value === "";
  if (removing) {
    const sure = await askYesNo(t("password-remove-question"), t("ui-yes"), t("ui-no"));
    if (!sure) {
      return;
    }
  }
  try {
    const report = await invoke<string>("set_database_password", {
      path: target,
      old: oldField.value,
      fresh: freshField.value,
      repeat: repeatField.value,
    });
    // Le sélecteur redit ce qui vient de se passer dans sa barre : c'est lui
    // qu'on retrouve derrière cette fiche.
    await invoke("notify_databases_changed", { said: report });
    closeCurrentWindow();
  } catch (error) {
    // Une saisie qui ne va pas ne referme rien : on la corrige sur place.
    say(String(error), true);
  }
}

revealBox.addEventListener("change", reveal);
element<HTMLButtonElement>("save").addEventListener("click", () => void apply());
element<HTMLButtonElement>("close").addEventListener("click", () => closeCurrentWindow());

window.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    event.preventDefault();
    closeCurrentWindow();
  }
});

/// Pose les mots de la fenêtre, à l'ouverture et à chaque changement de langue.
function dress(): void {
  for (const [id, key] of [
    ["group-database", "password-group-database"],
    ["group-password", "password-group-password"],
    ["group-warning", "password-group-warning"],
    ["old-caption", "password-field-old"],
    ["fresh-caption", "password-field-new"],
    ["repeat-caption", "password-field-repeat"],
    ["password-hint", "password-hint"],
    ["warning", "password-lost-warning"],
    ["reveal-label", "password-show"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  element<HTMLElement>("database-name").textContent = label;
  element<HTMLElement>("save").title = t("ui-title-save");
  element<HTMLElement>("close").title = t("ui-title-close");
}

void (async () => {
  readParameters(window.location.search);
  await loadTexts(null);
  dress();
  blank();
  onLanguageChanged(dress, { key: "window-password-form-title" });
})();

// Rouverte sur une autre base : les paramètres arrivent par un événement, et
// les champs repartent vides.
void listen<string>("window-parameters:password-form", (event) => {
  readParameters(event.payload);
  dress();
  blank();
  oldField.focus();
});
