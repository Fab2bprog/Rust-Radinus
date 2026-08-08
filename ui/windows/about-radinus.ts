// « À propos de Radinus ».
//
// Le nom, la version, les deux logos, une phrase. Bâtie comme « À propos de
// l'auteur », qui elle-même l'est comme la fenêtre du choix de la langue.
//
// **La version vient du binaire qui tourne**, et non d'une chaîne recopiée.
// Elle est écrite à quatre endroits dans le projet — `Cargo.toml`,
// `package.json`, `tauri.conf.json` et la table `Parametres` — et une
// cinquième copie dans cette page aurait fini par annoncer une version qu'on
// n'exécute pas. C'est pourtant la seule chose qu'une fenêtre « à propos »
// doive dire juste.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { closeCurrentWindow } from "./window-frame";
import { loadTexts, onLanguageChanged, t } from "./texts";

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

async function dress(): Promise<void> {
  document.documentElement.lang = t("ui-language-tag");
  element<HTMLElement>("name").textContent = t("about-radinus-name");
  element<HTMLImageElement>("rust").alt = t("about-radinus-rust-alt");
  element<HTMLImageElement>("tauri").alt = t("about-radinus-tauri-alt");
  element<HTMLElement>("built").textContent = t("about-radinus-built");
  element<HTMLElement>("copyright").textContent = t("licence-copyright");
  element<HTMLElement>("no-warranty").textContent = t("licence-no-warranty");
  element<HTMLElement>("info-bar").textContent = t("about-radinus-licence");
  element<HTMLElement>("close").title = t("ui-title-close");

  // La phrase entière vient du noyau, numéro compris : « Version : 2.0.0 »
  // n'a pas le même ordre de mots dans toutes les langues, et la fenêtre ne
  // remplit jamais un trou elle-même.
  element<HTMLElement>("version").textContent = await invoke<string>("app_version");
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
  await dress();
  onLanguageChanged(dress, { key: "window-about-radinus-title" });
})();
