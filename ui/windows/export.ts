// L'export d'un tableau, écrit une fois pour toutes les fenêtres.
//
// **C'est une fonction du tableau, pas d'une fenêtre** (`PLAN_ACTION.md` §3.1,
// et l'usage de l'original : clic droit sur n'importe quel tableau). Écrit ici,
// il sert aux sept listes de nomenclature, aux comptes, aux opérations, au
// détail des statistiques — et à la matrice, qui n'est pas un tableau partagé
// mais fabrique sa feuille de la même façon.
//
// Le vocabulaire est celui du noyau : une **feuille** est une grille de
// cellules typées, chacune pouvant porter une couleur de fond et du gras. La
// fenêtre décrit ce qu'elle **affiche** ; le noyau écrit le `.xlsx` ou le
// `.csv`. Aucune fenêtre ne sait ce qu'est un classeur, et l'exportateur ne
// sait rien de Radinus.

import { invoke } from "@tauri-apps/api/core";
import { save } from "@tauri-apps/plugin-dialog";
import { t } from "./texts";

/// Une cellule de la feuille. Un montant part **en micro-unités**, comme
/// partout dans Radinus : c'est le noyau qui en fait un nombre et lui donne
/// son format monétaire, pour qu'Excel puisse le sommer.
export type SheetCell =
  | { kind: "empty"; fill?: string | null; bold?: boolean }
  | { kind: "text"; text: string; fill?: string | null; bold?: boolean }
  | { kind: "money"; amount: number; fill?: string | null; bold?: boolean };

export interface Sheet {
  /// Le nom de l'onglet.
  name: string;
  /// D'où vient le fichier : la fenêtre, et ce qu'elle montrait.
  context: string;
  /// Combien de lignes du haut sont des titres.
  header_rows: number;
  rows: SheetCell[][];
  /// Largeur des colonnes, en caractères.
  widths: number[];
}

export const text = (value: string, bold = false): SheetCell => ({
  kind: "text",
  text: value,
  bold,
});

export const money = (amount: number, fill?: string | null, bold = false): SheetCell => ({
  kind: "money",
  amount,
  fill,
  bold,
});

export const empty = (fill?: string | null): SheetCell => ({ kind: "empty", fill });

/// Les sorties proposées, dans l'ordre où le menu les montre. **C'est la
/// seule liste** : ajouter un format se fait ici et nulle part ailleurs — le
/// noyau reconnaît l'extension du fichier, et aucune fenêtre n'a son mot à
/// dire. L'`.ods` de LibreOffice Calc est arrivé ainsi le 26/07/2026, sur
/// demande de Fabrice, sans qu'aucune fenêtre ne soit touchée.
/// Les trois premières sont pour un humain qui ouvre un tableur ; les deux
/// dernières pour un programme qui relit — d'où le trait qui les sépare dans
/// le menu.
/// Les dix sorties d'un tableau, dans l'ordre et les groupes du menu Export de
/// F02 (capture de Fabrice, 30/07/2026) : la bureautique d'abord, puis les
/// deux formats de tableur en texte, puis les cinq formats d'échange, par
/// ordre alphabétique comme chez lui. LibreOffice Calc s'ajoute aux deux
/// premiers sur sa demande — son menu d'origine ne l'a pas.
///
/// **Les deux formats bancaires n'y sont pas** : l'OFX et le QIF n'exportent
/// pas un tableau mais des opérations, et n'ont donc de sens que dans F02. Ils
/// vivent dans son menu à elle.
///
/// `name` est le nom du format tout seul, pour un menu qui a déjà dit
/// « Exporter vers » : « Excel (.xlsx) » sous cette entrée, et non « Exporter
/// vers Excel (.xlsx) » une seconde fois. **Ce sont des noms propres, et ils
/// ne se traduisent pas** — Excel s'appelle Excel dans les dix-huit langues —
/// c'est pourquoi ils sont écrits ici, et non dans les fichiers de langue.
export const FORMATS = [
  { key: "export-to-excel", extension: "xlsx", name: "Excel (.xlsx)" },
  { key: "export-to-word", extension: "docx", name: "Word (.docx)" },
  { key: "export-to-ods", extension: "ods", name: "LibreOffice Calc (.ods)" },
  { key: "export-to-csv", extension: "csv", name: "CSV (.csv)", apart: true },
  { key: "export-to-tsv", extension: "tsv", name: "TSV (.tsv)" },
  { key: "export-to-ini", extension: "ini", name: "INI (.ini)", apart: true },
  { key: "export-to-json", extension: "json", name: "JSON (.json)" },
  { key: "export-to-toml", extension: "toml", name: "TOML (.toml)" },
  { key: "export-to-xml", extension: "xml", name: "XML (.xml)" },
  { key: "export-to-yaml", extension: "yaml", name: "YAML (.yaml)" },
] as const;

export type Extension = (typeof FORMATS)[number]["extension"];

/// La ligne qui dit d'où vient le fichier, rédigée par le noyau.
export async function contextLine(window: string, detail: string): Promise<string> {
  try {
    return await invoke<string>("export_context", { window, detail });
  } catch {
    // Une ligne de contexte manquante ne doit pas empêcher un export.
    return "";
  }
}

/// Demande où enregistrer, puis écrit. Rend la phrase à afficher, ou `null` si
/// l'utilisateur a renoncé.
///
/// **Le sélecteur est celui du système** : l'explorateur sous Windows, le
/// Finder sous macOS, le portail sous Linux. La fenêtre ne connaît aucun
/// chemin par elle-même et n'a le droit d'écrire nulle part — elle demande où,
/// et c'est Rust qui écrit là.
export async function exportSheet(sheet: Sheet, extension: string): Promise<string | null> {
  if (sheet.rows.length === 0) {
    return t("export-nothing");
  }
  const chosen = await save({
    defaultPath: `${fileNameOf(sheet.name)}.${extension}`,
    filters: [{ name: extension.toUpperCase(), extensions: [extension] }],
  });
  if (chosen === null) {
    return null;
  }
  return await invoke<string>("export_sheet", { sheet, path: chosen });
}

/// Demande où enregistrer, sans rien écrire — pour les sorties qui ne partent
/// pas d'une feuille.
///
/// **Le sélecteur est celui du système**, comme partout ailleurs : la fenêtre
/// n'a le droit d'écrire nulle part, elle demande où, et c'est Rust qui écrit
/// là.
export async function askWhereToSave(
  name: string,
  extension: string,
): Promise<string | null> {
  return await save({
    defaultPath: `${fileNameOf(name)}.${extension}`,
    filters: [{ name: extension.toUpperCase(), extensions: [extension] }],
  });
}

/// Un nom de fichier proposé, tiré du nom de l'onglet : sans ce qu'un système
/// de fichiers refuse.
function fileNameOf(name: string): string {
  const cleaned = name.replace(/[\\/:*?"<>|]/g, " ").trim();
  return cleaned === "" ? "radinus" : cleaned;
}

/// **Une entrée qu'une fenêtre ajoute en tête de son menu du clic droit**, au
/// dessus des exports, et qui ouvre un sous-menu de choix.
///
/// Le menu est commun à tous les tableaux de Radinus ; ce qu'une fenêtre y
/// ajoute ne regarde qu'elle (Fabrice, 03/10/2026 : « je veux modifier ce menu
/// pour l'instant uniquement à cet endroit »). Un tableau qui ne donne rien
/// garde le menu qu'il a toujours eu.
export interface MenuAddition {
  label: string;
  /// Éteinte, l'entrée est montrée en grisé et son sous-menu ne s'ouvre pas :
  /// elle dit qu'elle existe, et qu'il lui manque quelque chose pour servir.
  enabled: boolean;
  choices: {
    label: string;
    /// Une marque posée sur le choix (`data-<name>="<value>"`), que la feuille
    /// de style peut teinter — la clef d'une vérification, par exemple. Elle
    /// porte son nom : une autre entrée, un autre jour, n'héritera pas des
    /// couleurs de celle-ci parce que ses clefs se ressemblent.
    mark?: { name: string; value: string };
    run: () => void;
  }[];
}

/// **Une entrée simple en tête du menu du clic droit** — « Copier la
/// cellule », « Copier les lignes sélectionnées » (Fabrice, 07/10/2026). Elle
/// fait quelque chose tout de suite, sans sous-menu. Éteinte, elle est montrée
/// en grisé : elle dit qu'elle existe, et qu'il lui manque quelque chose.
export interface MenuHeadEntry {
  label: string;
  enabled: boolean;
  /// Ce qui distingue l'entrée pour une feuille de style ou une vérification.
  name: string;
  run: () => void;
}

/// Pose le menu du clic droit sur `zone`, avec les deux exports.
///
/// `build` n'est appelé qu'au moment où l'on choisit : une fenêtre n'a aucune
/// raison de fabriquer sa feuille tant que personne ne la demande.
///
/// `additions` est appelé à chaque ouverture du menu : ce qu'il rend dépend
/// de l'instant — de la sélection, de la langue.
///
/// `exportsUnder`, quand il est donné, **range les dix exports dans un
/// sous-menu** sous le nom qu'il rend — « Exporter vers » (Fabrice,
/// 03/10/2026). Un menu qui porte deux entrées à lui et dix exports à plat ne
/// se lit plus ; trois entrées qui s'ouvrent, si. Sans lui, les exports
/// restent à plat, comme dans tous les autres tableaux.
export function onRightClick(
  zone: HTMLElement,
  build: () => Promise<Sheet> | Sheet,
  said: (message: string, alert?: boolean) => void,
  additions?: () => MenuAddition[],
  exportsUnder?: () => string,
  head?: (event: MouseEvent) => MenuHeadEntry[],
): void {
  let menu: HTMLElement | null = null;

  // Un clic **ailleurs**, la touche d'échappement : le menu s'en va, comme
  // n'importe quel menu contextuel.
  //
  // « Ailleurs » est à prendre au mot. Le fermer sur n'importe quel
  // `mousedown` le retirait du document avant que le `click` de l'entrée n'ait
  // eu lieu — l'entrée disparaissait sous le doigt et l'export ne partait
  // jamais. Le menu ne se ferme donc que sur ce qui n'est pas lui.
  const closeIfOutside = (event: MouseEvent): void => {
    if (menu !== null && !menu.contains(event.target as Node)) {
      close();
    }
  };

  const close = (): void => {
    menu?.remove();
    menu = null;
    document.removeEventListener("mousedown", closeIfOutside);
  };

  const run = (extension: string): void => {
    close();
    void (async () => {
      try {
        const answer = await exportSheet(await build(), extension);
        if (answer !== null) {
          said(answer);
        }
      } catch (error) {
        said(String(error), true);
      }
    })();
  };

  zone.addEventListener("contextmenu", (event) => {
    event.preventDefault();
    close();

    menu = document.createElement("div");
    menu.className = "context-menu";
    menu.style.left = `${event.clientX}px`;
    menu.style.top = `${event.clientY}px`;

    // **Tout en haut, la copie**, puis un trait : c'est le geste le plus
    // courant du menu, et le seul qui dépende de l'endroit exact du clic —
    // d'où l'événement qu'on lui tend.
    const first = head?.(event) ?? [];
    for (const one of first) {
      const entry = document.createElement("button");
      entry.type = "button";
      entry.className = "context-menu__entry context-menu__entry--head";
      entry.dataset.head = one.name;
      entry.textContent = one.label;
      entry.disabled = !one.enabled;
      entry.addEventListener("click", () => {
        close();
        one.run();
      });
      menu.append(entry);
    }
    if (first.length > 0) {
      const rule = document.createElement("hr");
      rule.className = "context-menu__rule context-menu__rule--head";
      menu.append(rule);
    }

    // Ce que la fenêtre ajoute, en tête, puis un trait : les exports viennent
    // après, tels qu'ils ont toujours été.
    const added = additions?.() ?? [];
    for (const addition of added) {
      const nest = document.createElement("div");
      nest.className = "context-menu__nest";
      const opener = document.createElement("button");
      opener.type = "button";
      opener.className = "context-menu__entry context-menu__entry--opener";
      opener.textContent = addition.label;
      opener.disabled = !addition.enabled;
      nest.append(opener);

      if (addition.enabled) {
        const nested = document.createElement("div");
        nested.className = "context-menu__submenu";
        for (const choice of addition.choices) {
          const entry = document.createElement("button");
          entry.type = "button";
          entry.className = "context-menu__entry";
          entry.textContent = choice.label;
          if (choice.mark !== undefined) {
            entry.dataset[choice.mark.name] = choice.mark.value;
          }
          entry.addEventListener("click", () => {
            close();
            choice.run();
          });
          nested.append(entry);
        }
        nest.append(nested);
        // Le survol l'ouvre ; le clic aussi, pour qui n'a pas de survol ou
        // préfère le clavier.
        opener.addEventListener("click", () => {
          nest.classList.toggle("context-menu__nest--open");
        });
      }
      menu.append(nest);
    }
    // Les exports : à plat sous un trait, ou rangés dans leur propre
    // sous-menu quand la fenêtre l'a demandé.
    let exports: HTMLElement = menu;
    if (exportsUnder !== undefined) {
      const nest = document.createElement("div");
      nest.className = "context-menu__nest";
      const opener = document.createElement("button");
      opener.type = "button";
      opener.className = "context-menu__entry context-menu__entry--opener";
      opener.textContent = exportsUnder();
      opener.addEventListener("click", () => {
        nest.classList.toggle("context-menu__nest--open");
      });
      exports = document.createElement("div");
      exports.className = "context-menu__submenu";
      nest.append(opener, exports);
      menu.append(nest);
    } else if (added.length > 0) {
      const rule = document.createElement("hr");
      rule.className = "context-menu__rule";
      menu.append(rule);
    }

    for (const format of FORMATS) {
      if ("apart" in format && format.apart) {
        const rule = document.createElement("hr");
        rule.className = "context-menu__rule";
        exports.append(rule);
      }
      const entry = document.createElement("button");
      entry.type = "button";
      entry.className = "context-menu__entry";
      // Sous « Exporter vers », le nom du format suffit.
      entry.textContent = exportsUnder !== undefined ? format.name : t(format.key);
      entry.addEventListener("click", () => run(format.extension));
      exports.append(entry);
    }
    document.body.append(menu);
    // **Un sous-menu s'ouvre du côté où il y a de la place.** À droite du
    // menu d'ordinaire ; à gauche quand le clic a eu lieu près du bord droit
    // de la fenêtre, où il sortirait de l'écran. Et vers le haut quand le
    // clic a eu lieu près du bas : celui des exports porte dix lignes.
    const nested = added.length > 0 || exportsUnder !== undefined;
    const placed = menu.getBoundingClientRect();
    if (nested && placed.right + 210 > window.innerWidth) {
      menu.classList.add("context-menu--near-the-edge");
    }
    if (nested && placed.bottom + 300 > window.innerHeight) {
      menu.classList.add("context-menu--near-the-bottom");
    }
    document.addEventListener("mousedown", closeIfOutside);
  });

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
      close();
    }
  });
}
