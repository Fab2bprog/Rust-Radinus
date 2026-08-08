// Le choix de la langue, au tout premier lancement.
//
// Décision de Fabrice du 02/08/2026 : « si Radinus démarre sans base, on
// demande avant tout le choix de la langue ». La question n'est posée
// **qu'une seule fois dans la vie du logiciel** — le lancement suivant trouve
// la langue dans `settings/radinus_config.json` et passe directement au
// sélecteur de base. Ensuite, c'est le menu Paramètres qui en change.
//
// **Cette fenêtre n'emploie aucune phrase du dictionnaire, et c'est voulu.**
// Aucune langue n'est choisie : il n'y en a aucune dans laquelle écrire une
// consigne. Elle n'en a pas besoin. Chaque ligne porte le nom d'une langue
// écrit dans cette langue-là — « Français », « English », « Español » —, ce
// qui se comprend sans qu'on sache déjà laquelle l'utilisateur parle. Ces
// noms viennent du noyau, qui va les chercher sous la clef `language-name` de
// chaque fichier de langue : rien n'est écrit ici, et une langue de plus
// apparaît dans cette liste sans qu'on rouvre ce fichier.
//
// **Ce qu'il a fallu rouvrir ce fichier pour faire**, le 03/08/2026, quand la
// dixième langue est arrivée : la ranger. La liste était rendue dans l'ordre
// de déclaration du noyau — l'ordre où les langues sont arrivées — et elle
// dépassait le bas d'une fenêtre qui ne se redimensionne pas. Elle est
// désormais triée par le nom de chaque langue (`languages.ts`) et défile
// (`window.css`). C'est la seule chose de cette fenêtre qui n'ait pas tenu
// jusqu'à dix langues, et elle tiendra maintenant jusqu'à cinquante.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { sortByOwnName } from "./languages";

interface LanguageDto {
  /// Le numéro « nation » du WLangage : 5 français, 3 anglais, 7 espagnol.
  code: number;
  tag: string;
  /// Le nom de la langue, écrit dans cette langue.
  name: string;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");
const list = element<HTMLDivElement>("languages");
const validateButton = element<HTMLButtonElement>("validate");

let languages: LanguageDto[] = [];
let chosen: number | null = null;

/// La barre d'information ne porte, elle aussi, que le nom d'une langue :
/// c'est le seul mot qui soit juste avant qu'on ait choisi.
function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

function draw(): void {
  list.replaceChildren();
  for (const language of languages) {
    const choice = document.createElement("button");
    choice.type = "button";
    choice.className = "language-choice__entry";
    choice.lang = language.tag;
    choice.textContent = language.name;
    choice.setAttribute("role", "option");
    choice.setAttribute("aria-selected", String(language.code === chosen));
    choice.addEventListener("click", () => {
      chosen = language.code;
      say(language.name);
      draw();
    });
    // Double-cliquer choisit et valide, comme partout ailleurs dans Radinus.
    choice.addEventListener("dblclick", () => {
      chosen = language.code;
      void validate();
    });
    list.append(choice);
  }
  validateButton.disabled = chosen === null;
}

/// Écrit la langue dans la configuration portable — il n'y a pas encore de
/// base où l'écrire —, après quoi Rust relance Radinus : le démarrage suivant
/// trouve la langue et pose la question de la base.
async function validate(): Promise<void> {
  if (chosen === null) {
    return;
  }
  try {
    await invoke("choose_language", { code: chosen });
  } catch (error) {
    say(String(error), true);
  }
}

validateButton.addEventListener("click", () => void validate());

// **La porte quitte, ou revient en arrière.** Au premier lancement il n'y a
// rien derrière cette fenêtre, et une fenêtre cachée sans rien pour la
// remplacer laisserait Radinus vivant et invisible : on quitte. Rouverte depuis
// le menu Paramètres de la fenêtre des bases (04/08/2026), il y a le sélecteur
// derrière : on se cache, et l'on y revient.
//
// **C'est Rust qui tranche**, comme pour la porte du sélecteur : lui seul voit
// ce qui est ouvert.
element<HTMLButtonElement>("close").addEventListener("click", () => {
  void invoke("leave_language_choice");
});

window.addEventListener("keydown", (event) => {
  if (event.key === "Enter") {
    event.preventDefault();
    void validate();
  }
});

// Rien ne doit pouvoir arriver ici en silence — même raison qu'au sélecteur
// de base, et la même barre d'information pour le dire.
window.addEventListener("error", (event) => {
  say(`${event.message} — ${event.filename}:${event.lineno}`, true);
});
window.addEventListener("unhandledrejection", (event) => {
  say(String(event.reason), true);
});

void (async () => {
  try {
    languages = await invoke<LanguageDto[]>("available_languages");
    sortByOwnName(languages);
    // Rien n'est coché d'avance : le premier lancement ne suppose pas que
    // l'utilisateur parle la langue de l'auteur.
    draw();
    say("");
  } catch (error) {
    say(String(error), true);
  }
})();
