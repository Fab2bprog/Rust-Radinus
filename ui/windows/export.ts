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
export const FORMATS = [
  { key: "export-to-excel", extension: "xlsx" },
  { key: "export-to-word", extension: "docx" },
  { key: "export-to-ods", extension: "ods" },
  { key: "export-to-csv", extension: "csv", apart: true },
  { key: "export-to-tsv", extension: "tsv" },
  { key: "export-to-ini", extension: "ini", apart: true },
  { key: "export-to-json", extension: "json" },
  { key: "export-to-toml", extension: "toml" },
  { key: "export-to-xml", extension: "xml" },
  { key: "export-to-yaml", extension: "yaml" },
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

/// Pose le menu du clic droit sur `zone`, avec les deux exports.
///
/// `build` n'est appelé qu'au moment où l'on choisit : une fenêtre n'a aucune
/// raison de fabriquer sa feuille tant que personne ne la demande.
export function onRightClick(
  zone: HTMLElement,
  build: () => Promise<Sheet> | Sheet,
  said: (message: string, alert?: boolean) => void,
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

    for (const format of FORMATS) {
      if ("apart" in format && format.apart) {
        const rule = document.createElement("hr");
        rule.className = "context-menu__rule";
        menu.append(rule);
      }
      const entry = document.createElement("button");
      entry.type = "button";
      entry.className = "context-menu__entry";
      entry.textContent = t(format.key);
      entry.addEventListener("click", () => run(format.extension));
      menu.append(entry);
    }
    document.body.append(menu);
    document.addEventListener("mousedown", closeIfOutside);
  });

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
      close();
    }
  });
}
