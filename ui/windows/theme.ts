// Les couleurs de tokens.css, et le thème de la fenêtre (P-80).
//
// **Le thème.** Chaque page porte son thème sur la racine du document —
// `data-theme="light"`, `"sepia"` ou `"dark"` — et tokens.css donne à chaque
// couleur sa valeur dans chacun. Rust le pose avant le premier dessin des
// fenêtres qu'il bâtit (`initialization_script`) ; ce module le confirme en
// s'ouvrant, le change quand les préférences l'enregistrent
// (`appearance-changed`), et suit le système en direct quand c'est « Suivre le
// système ». Importé par toutes les pages, à travers `shortcuts.ts`.
//
// **Les couleurs pour le code qui dessine.** Une feuille de style lit ses
// couleurs dans tokens.css par `var(--…)`. Un dessin SVG les reçoit en
// attribut, où `var()` ne vaut rien : il les pose donc en style, où elle vaut
// (`live`). Lue au moment du dessin (thèmes, étape A), la couleur serait
// restée celle de l'ancien thème jusqu'au dessin suivant (étape D,
// 30/10/2026) ; posée en `var()`, elle change avec le thème, sans redessiner.
// La valeur de repli est celle d'avant, pour qu'un jeton manquant ne fasse
// jamais disparaître un trait.

import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";

/// Une couleur de tokens.css qui suit le thème : à poser dans un style
/// (`element.style.stroke`, `style="fill: …"`), jamais dans un attribut.
export function live(name: string, fallback: string): string {
  return `var(${name}, ${fallback})`;
}

/// Ce que l'utilisateur a choisi : `system`, `light`, `sepia` ou `dark`.
/// « Suivre le système » tant que rien n'est dit (31/10/2026).
let chosen = "system";

const systemDark = (): boolean =>
  typeof window.matchMedia === "function" &&
  window.matchMedia("(prefers-color-scheme: dark)").matches;

/// Pose le thème sur la page. Rien, ou un mot inconnu, vaut « Suivre le
/// système », le défaut (Fabrice, 31/10/2026).
function apply(choice: string | null | undefined): void {
  chosen = ["light", "sepia", "dark"].includes(choice ?? "") ? (choice as string) : "system";
  const theme = chosen === "system" ? (systemDark() ? "dark" : "light") : chosen;
  document.documentElement.dataset.theme = theme;
}

void invoke<string>("preferences_appearance")
  .then(apply)
  .catch(() => undefined);
void listen<string>("appearance-changed", (event) => apply(event.payload));
// « Suivre le système » : le système change, la page suit.
if (typeof window.matchMedia === "function") {
  window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", () => {
    if (chosen === "system") {
      apply(chosen);
    }
  });
}
