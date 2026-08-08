// Les raccourcis clavier du menu général, écoutés par la fenêtre.
//
// **Pourquoi une fenêtre écoute ce que le menu devrait entendre.** Sous
// Windows, aucune frappe faite dans une fenêtre de Radinus n'atteint la table
// d'accélérateurs du menu : le moteur WebView2 traite les frappes dans son
// propre processus, et rien ne les lui reprend. Une application Tauri étant un
// webview de bord à bord, aucun raccourci de menu n'y fonctionne — c'est ouvert
// chez eux et sans correctif (`wry#451`, `tauri#6365`). Dossier de portage du
// 05/08/2026, §5.2.
//
// **La fenêtre écoute, Rust décide.** Ce module reconnaît une frappe et rend un
// identifiant d'entrée de menu ; c'est Rust qui juge si cette entrée est active
// et qui l'exécute par le chemin ordinaire. Aucune décision ici, aucune branche
// du menu redite.
//
// **Ailleurs que sous Windows la table arrive vide** et ce module ne fait rien :
// là où la barre native entend, écouter en plus déclencherait chaque entrée
// deux fois. C'est le cas de macOS, et probablement celui de Linux, où GTK
// examine ses accélérateurs avant de passer la touche au widget qui a le focus
// (arbitrage de Fabrice, 08/08/2026 : n'affirmer que ce qui a été constaté).
// C'est Rust qui le décide, dans le seul fichier qui connaît les raccourcis —
// pas quarante-et-une fenêtres qui devraient y penser chacune.
//
// Importé par toutes les pages. Il n'a rien à exporter : c'est son chargement
// qui pose l'écouteur.

import { invoke } from "@tauri-apps/api/core";

interface Shortcut {
  /// L'entrée de menu à déclencher.
  id: string;
  /// La valeur de `KeyboardEvent.code` attendue — la **position** de la touche.
  code: string;
  /// Si la frappe demande Majuscule en plus de Ctrl.
  shift: boolean;
}

let table: Shortcut[] = [];

void (async () => {
  try {
    // `?? []` : une commande qui ne répondrait rien ne doit pas rendre la
    // fenêtre fragile au premier appui sur une touche.
    table = (await invoke<Shortcut[]>("menu_shortcuts")) ?? [];
  } catch {
    // Une fenêtre sans raccourcis reste une fenêtre qui marche : la souris et
    // le menu font tout ce que font les raccourcis.
  }
})();

// **En capture**, et c'est ce qui décide du résultat : sans cela un raccourci
// devient muet dès que le curseur est dans une zone de texte — c'est-à-dire la
// moitié du temps dans un logiciel de saisie.
window.addEventListener(
  "keydown",
  (event) => {
    if (table.length === 0 || !event.ctrlKey) {
      return;
    }
    // **`altKey` écarté**, et pas par prudence : sous Windows, AltGr *est*
    // Ctrl+Alt. Sans cette ligne, taper « @ » ou « # » sur un clavier français
    // déclencherait un raccourci.
    if (event.altKey || event.metaKey) {
      return;
    }
    const found = table.find(
      (shortcut) => shortcut.code === event.code && shortcut.shift === event.shiftKey,
    );
    if (!found) {
      return;
    }
    event.preventDefault();
    void invoke("menu_shortcut", { id: found.id });
  },
  true,
);
