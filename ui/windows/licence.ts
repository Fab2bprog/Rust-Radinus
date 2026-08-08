// « Licence d'utilisation ».
//
// The GPLv3 logo, the name of the licence, and the four freedoms it grants —
// one line each. Built like « À propos de l'auteur », which is itself built
// like the language-choice window: what it has to say fits in a handful of
// elements, and anything added around them would stand between those and the
// reader.
//
// **No sentence is written here**, not even the name of the licence. The
// window asks the core for ten strings and puts them where they go.
//
// **The logo is the button**, and it carries no address. It calls a command
// that opens one page and only that one: a command taking a URL from the
// window would hand the view the power to open anything on the machine, and
// the view is never given a power it does not need.

import { invoke } from "@tauri-apps/api/core";
import { closeCurrentWindow } from "./window-frame";
import { loadTexts, onLanguageChanged, t } from "./texts";

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

function dress(): void {
  document.documentElement.lang = t("ui-language-tag");
  element<HTMLImageElement>("logo").alt = t("licence-logo-alt");
  element<HTMLElement>("name").textContent = t("licence-name");
  element<HTMLElement>("intro").textContent = t("licence-intro");
  element<HTMLElement>("freedoms-title").textContent = t("licence-freedoms-title");
  element<HTMLElement>("freedom-use").textContent = t("licence-freedom-use");
  element<HTMLElement>("freedom-study").textContent = t("licence-freedom-study");
  element<HTMLElement>("freedom-share").textContent = t("licence-freedom-share");
  element<HTMLElement>("freedom-improve").textContent = t("licence-freedom-improve");
  element<HTMLElement>("info-bar").textContent = t("licence-info");
  element<HTMLElement>("read").title = t("licence-read");
  element<HTMLElement>("close").title = t("ui-title-close");
}

element<HTMLButtonElement>("read").addEventListener("click", () => {
  void invoke("open_licence_page");
});

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
  onLanguageChanged(dress, { key: "window-licence-title" });
})();
