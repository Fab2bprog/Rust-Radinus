// The words a window shows.
//
// **A window holds no sentence of its own** (author's ruling, 25/07/2026):
// everything it displays comes from `radinus-core`'s Fluent resources, French
// and English alike. It asks Rust for its whole vocabulary once, before it
// draws anything, and shows what it is given.
//
// Two consequences worth knowing. A window cannot show a word that has no
// Fluent key — asking for one gives its key back, visibly wrong on screen
// rather than silently empty. And nothing here composes a sentence out of
// pieces: French would need a gender, English would not, and the code would
// end up knowing about both. Whole sentences live in the `.ftl` files, one
// branch per nomenclature.

import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";

type Dictionary = Record<string, string>;

let dictionary: Dictionary = {};

// Ce que la fenêtre a demandé la première fois. Une fenêtre de nomenclature
// demande le vocabulaire d'une nomenclature précise ; en changeant de langue
// elle doit redemander le même, sinon elle se rhabille avec les mots d'une
// autre table.
let askedFor: string | null = null;

/// Fetches this window's vocabulary. Called once, before anything is drawn.
export async function loadTexts(kind: string | null): Promise<void> {
  askedFor = kind;
  dictionary = await invoke<Dictionary>("ui_texts", { kind });
}

/// A word or a sentence, by its Fluent key. An unknown key comes back as the
/// key itself: a missing translation must be seen, not guessed at.
export function t(key: string): string {
  return dictionary[key] ?? key;
}

/// A sentence that carries an error message — the only substitution the view
/// makes, and it is a substitution, not a composition: the sentence around it
/// comes whole from Fluent.
export function tError(key: string, error: unknown): string {
  return `${t(key)} ${String(error)}`;
}

/// **Rhabiller la fenêtre quand la langue change** (décision de Fabrice,
/// 01/08/2026 : la bascule prend effet tout de suite).
///
/// Une fenêtre de Radinus est bâtie une fois et jamais détruite : on ne peut
/// donc pas la reconstruire dans la nouvelle langue, il faut qu'elle sache se
/// rhabiller. Rust prévient toutes les fenêtres ouvertes d'un seul coup ;
/// chacune redemande ici son vocabulaire — le même `kind` que la première
/// fois — puis repose ses étiquettes.
///
/// `dress` est la fonction qui pose les mots sur la fenêtre. Elle est appelée
/// une fois à l'ouverture, comme avant, et une fois par changement de langue :
/// c'est la même, et c'est ce qui garantit qu'une étiquette ajoutée demain
/// suivra la langue sans que personne y pense.
///
/// `title` dit à Rust quel titre reposer sur la fenêtre. Un titre n'est pas
/// dans le dictionnaire — il est écrit par le noyau, qui seul sait composer
/// « Liste opérations du compte : CCP » — donc la fenêtre rend la clef et,
/// s'il y a lieu, son argument.
export function onLanguageChanged(
  dress: () => void | Promise<void>,
  title?: { key: string; argument?: string | null; argumentName?: string },
): void {
  void listen("language-changed", async () => {
    await loadTexts(askedFor);
    await dress();
    if (title) {
      try {
        await invoke("retitle", {
          key: title.key,
          argument: title.argument ?? null,
          argumentName: title.argumentName ?? null,
        });
      } catch {
        // Un titre qui ne se repose pas ne vaut pas d'interrompre la fenêtre :
        // elle est déjà rhabillée, et c'est ce qui compte.
      }
    }
  });
}
