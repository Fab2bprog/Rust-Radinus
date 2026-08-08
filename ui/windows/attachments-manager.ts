// « Gestion des pièces jointes » (Fabrice, 08/08/2026).
//
// **Ce que la fenêtre d'une opération ne peut pas montrer : l'ensemble.**
// Celle-ci liste les pièces de toutes les opérations, et surtout les deux
// pannes que rien ne montrait — une pièce dont le fichier a disparu du disque,
// et un fichier du dossier que plus aucune opération ne réclame. La colonne
// « État » les nomme, et c'est ce qui fait la différence entre une liste et un
// outil de ménage.
//
// **La fenêtre ne détient aucun chemin.** Elle envoie une clef — un numéro de
// pièce, ou un nom de disque pour un orphelin — et le noyau fait le reste. Le
// chemin d'un fichier n'a rien à faire dans le navigateur, où il ne servirait
// qu'à être détourné.
//
// **Deux chemins pour supprimer, et il le faut** : une pièce enregistrée part
// avec sa ligne en base ; un orphelin n'a pas de ligne, seulement un fichier.
// Les deux finissent à la corbeille, jamais au néant — la règle de Radinus
// depuis le 01/08/2026.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askYesNo } from "./dialog";
import { Table } from "./table";
import { closeCurrentWindow } from "./window-frame";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

interface Row {
  /// Zéro pour un orphelin : il n'a pas de ligne en base.
  id: number;
  guid_name: string;
  orphan: boolean;
  operation_id: number;
  account_id: number;
  on_disk: boolean;
  date: string;
  date_key: string;
  operation: string;
  amount: string;
  name: string;
  size: string;
  size_key: number;
  added: string;
  added_key: string;
  state: string;
  note: string;
  /// Posée par la fenêtre à la lecture — voir `numberTheOrphans`.
  key?: number;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

let rows: Row[] = [];

/// **La clef d'une ligne, orphelin compris.** Le tableau de Radinus identifie
/// ses lignes par un nombre, et le numéro de pièce ne suffit pas : tous les
/// orphelins portent zéro. Ils reçoivent donc un numéro négatif, attribué à la
/// lecture — les positifs sont des pièces enregistrées, les négatifs des
/// fichiers que rien ne réclame, et les deux mondes ne peuvent pas se
/// confondre.
function numberTheOrphans(found: Row[]): Row[] {
  let orphan = 0;
  for (const row of found) {
    if (row.orphan) {
      orphan += 1;
      row.key = -orphan;
    } else {
      row.key = row.id;
    }
  }
  return found;
}

const table = new Table<Row>({
  container: element<HTMLDivElement>("rows"),
  // **Trois colonnes pour l'opération, quatre pour le document** (choix de
  // Fabrice, 08/08/2026). Le nom de disque et la note ne sont pas dans le
  // tableau : ils vivent dans la barre du bas pour la ligne choisie, sinon
  // huit colonnes deviennent illisibles.
  columns: [
    {
      title: () => t("operations-column-date"),
      cell: (row) => row.date,
      // La colonne se trie sur l'ISO et non sur le « 08/08/2026 » affiché,
      // sans quoi le tri serait alphabétique et mélangerait les années — la
      // faute relevée par Fabrice le 04/08/2026 sur la liste des opérations.
      key: (row) => row.date_key,
      width: "92px",
    },
    { title: () => t("operations-column-label"), cell: (row) => row.operation, width: "2fr" },
    {
      title: () => t("cheque-operations-column-amount"),
      cell: (row) => row.amount,
      numeric: true,
      width: "1fr",
    },
    { title: () => t("attachments-column-document"), cell: (row) => row.name, width: "2fr" },
    {
      title: () => t("attachments-column-size"),
      cell: (row) => row.size,
      // Se trie sur les octets : « 9,8 Ko » et « 10,1 Ko » se rangeraient à
      // l'envers si l'on comparait ce qui est écrit.
      key: (row) => row.size_key,
      numeric: true,
      width: "88px",
    },
    {
      title: () => t("attachments-column-added"),
      cell: (row) => row.added,
      key: (row) => row.added_key,
      width: "100px",
    },
    { title: () => t("attachments-column-state"), cell: (row) => row.state, width: "1.2fr" },
  ],
  identity: (row) => row.key ?? row.id,
  exportAs: () => ({ name: t("window-attachments-manager-title"), detail: "" }),
  emptyText: () => t("attachment-none"),
  filteredOutText: () => t("ui-no-match"),
  onSelectionChange: () => describe(),
  onActivate: (row) => void open(row),
});

/// La ligne choisie, ou rien si le choix n'est pas d'une seule.
function chosen(): Row | null {
  const selected = table.selected();
  if (selected.length !== 1) {
    return null;
  }
  return rows.find((row) => (row.key ?? row.id) === selected[0]) ?? null;
}

/// Ce que la barre du bas dit de la ligne choisie : son nom sur le disque —
/// celui sous lequel on la retrouve dans le dossier et dans les sauvegardes —
/// et sa note, s'il y en a une.
function describe(): void {
  const row = chosen();
  if (row === null) {
    say(t("attachments-manager-help"));
    return;
  }
  void (async () => {
    const disk = await invoke<string>("attachment_disk_name", { name: row.guid_name });
    say(row.note === "" ? disk : `${disk} — ${row.note}`);
  })();
}

async function reload(): Promise<void> {
  try {
    rows = numberTheOrphans(await invoke<Row[]>("attachments_inventory"));
    table.setRows(rows);
    say(await invoke<string>("attachments_summary"));
  } catch (error) {
    say(tError("ui-load-failed", error), true);
  }
}

/// Ouvrir le document avec l'application du système.
///
/// Une pièce enregistrée passe par la commande qui vérifie son empreinte au
/// passage — un document qui a bougé depuis qu'il a été joint le dit. Un
/// orphelin n'a pas d'empreinte : on l'ouvre sans rien prétendre de lui.
async function open(row: Row): Promise<void> {
  try {
    if (row.orphan) {
      await invoke("open_orphan_attachment", { guidName: row.guid_name });
      return;
    }
    say(await invoke<string>("open_attachment", { id: row.id }));
  } catch (error) {
    say(String(error), true);
  }
}

/// Jeter le document à la corbeille, après confirmation.
async function remove(): Promise<void> {
  const row = chosen();
  if (row === null) {
    say(t("ui-select-record"), true);
    return;
  }
  try {
    // La question vient du noyau, dans la langue en cours, et elle n'est pas
    // la même selon qu'on jette une pièce ou un fichier que rien ne réclame.
    const question = row.orphan
      ? await invoke<string>("orphan_removal_question")
      : await invoke<string>("attachment_removal_question", { id: row.id });
    if (!(await askYesNo(question, t("ui-yes"), t("ui-no")))) {
      return;
    }
    const said = row.orphan
      ? await invoke<string>("delete_orphan_attachment", { guidName: row.guid_name })
      : await invoke<string>("delete_attachment", { id: row.id });
    await reload();
    say(said);
  } catch (error) {
    say(String(error), true);
  }
}

/// **Le clic droit sur une ligne** (Fabrice, 08/08/2026).
///
/// Deux gestes qui n'ont pas leur place dans la bande ardoise : aller voir
/// l'opération qui porte la pièce, et montrer le fichier dans le navigateur du
/// système. Ils regardent ailleurs — l'un vers la comptabilité, l'autre vers le
/// disque — alors que les boutons de la bande agissent sur la pièce elle-même.
///
/// **Les entrées apparaissent selon la ligne, elles ne se grisent pas.** Un
/// orphelin n'a pas d'opération à montrer, et un fichier absent n'a rien à
/// révéler : une entrée qui ne pourrait rien faire pose une question à laquelle
/// rien ne répond.
///
/// **Branché une seule fois**, comme dans le sélecteur de bases : la fenêtre se
/// rhabille à chaque changement de langue, et deux branchements ouvriraient deux
/// menus l'un sur l'autre. Les mots sont pris au moment du clic, le menu suit
/// donc la langue sans se rebrancher.
let rightClickBound = false;
function menuOnRightClick(): void {
  if (rightClickBound) {
    return;
  }
  rightClickBound = true;

  let menu: HTMLElement | null = null;
  const close = (): void => {
    menu?.remove();
    menu = null;
  };

  element<HTMLDivElement>("rows").addEventListener("contextmenu", (event) => {
    event.preventDefault();
    close();

    // La ligne sous le curseur devient la ligne choisie : sans cela le menu
    // agirait sur une autre pièce que celle qu'on vise du doigt.
    const line = (event.target as HTMLElement | null)?.closest<HTMLElement>(".list__row");
    if (line) {
      line.click();
    }
    const row = chosen();
    if (row === null) {
      return;
    }

    const entries: [string, () => void][] = [];
    if (!row.orphan) {
      entries.push([
        t("attachments-show-operation"),
        () => {
          void invoke("open_operation_form", {
            mode: "M",
            accountId: row.account_id,
            id: row.operation_id,
          }).catch((error) => say(tError("ui-open-failed", error), true));
        },
      ]);
    }
    // « Fichier absent » : il n'y a rien à révéler. Le noyau rend le fait
    // après avoir regardé le disque ; comparer le libellé de l'état marcherait
    // en français et nulle part ailleurs.
    if (row.on_disk) {
      entries.push([
        t("attachments-reveal"),
        () => {
          void invoke("reveal_attachment", { guidName: row.guid_name }).catch((error) =>
            say(String(error), true),
          );
        },
      ]);
    }
    if (entries.length === 0) {
      return;
    }

    menu = document.createElement("div");
    menu.className = "context-menu";
    menu.style.left = `${event.clientX}px`;
    menu.style.top = `${event.clientY}px`;
    for (const [label, run] of entries) {
      const entry = document.createElement("button");
      entry.type = "button";
      entry.className = "context-menu__entry";
      entry.textContent = label;
      entry.addEventListener("click", () => {
        close();
        run();
      });
      menu.append(entry);
    }
    document.body.append(menu);
  });

  document.addEventListener("click", close);
  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
      close();
    }
  });
}

function dress(): void {
  document.documentElement.lang = t("ui-language-tag");
  table.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));
  menuOnRightClick();
  element<HTMLElement>("open").title = t("ui-title-read");
  element<HTMLElement>("remove").title = t("ui-title-delete");
  element<HTMLElement>("close").title = t("ui-title-close");
}

element<HTMLButtonElement>("open").addEventListener("click", () => {
  const row = chosen();
  if (row === null) {
    say(t("ui-select-record"), true);
    return;
  }
  void open(row);
});
element<HTMLButtonElement>("remove").addEventListener("click", () => void remove());
element<HTMLButtonElement>("close").addEventListener("click", () => closeCurrentWindow());

window.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    event.preventDefault();
    void closeCurrentWindow();
  }
});

// **Elle se relit en reprenant le focus**, et c'est nécessaire ici plus
// qu'ailleurs : on peut supprimer une opération dans une autre fenêtre, ou
// jeter un fichier depuis l'explorateur du système, et l'inventaire changerait
// sans que cette fenêtre en soit prévenue.
window.addEventListener("focus", () => void reload());
void listen("data-changed", () => void reload());

void (async () => {
  await loadTexts(null);
  dress();
  await reload();
  onLanguageChanged(async () => {
    dress();
    await reload();
  }, { key: "window-attachments-manager-title" });
})();
