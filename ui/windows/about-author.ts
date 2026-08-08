// « À propos de l'auteur ».
//
// Trois lignes à lire et une porte pour sortir. Elle est bâtie comme la
// fenêtre du choix de la langue — « ultra simple », mot de Fabrice — et pour
// la même raison : ce qu'elle a à dire tient en trois éléments, et tout ce
// qu'on ajouterait autour se mettrait entre eux et le lecteur.
//
// **Aucune phrase n'est écrite ici**, pas même le nom : il vit dans les
// fichiers de langue comme le reste, si bien qu'il se corrige à un seul
// endroit. Ce qui ne varie pas d'une langue à l'autre — le nom, l'adresse —
// y est écrit trois fois à l'identique, et c'est le prix à payer pour que la
// vue ne contienne toujours rien.

import { closeCurrentWindow } from "./window-frame";
import { loadTexts, onLanguageChanged, t } from "./texts";

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

function dress(): void {
  document.documentElement.lang = t("ui-language-tag");
  element<HTMLImageElement>("flag").alt = t("about-author-flag-alt");
  element<HTMLElement>("name").textContent = t("about-author-name");
  element<HTMLElement>("place").textContent = t("about-author-place");
  element<HTMLElement>("close").title = t("ui-title-close");
}

element<HTMLButtonElement>("close").addEventListener("click", () => closeCurrentWindow());

window.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    event.preventDefault();
    void closeCurrentWindow();
  }
});

void (async () => {
  await loadTexts(null);
  dress();
  onLanguageChanged(dress, { key: "window-about-author-title" });
})();
