// « Liste des opérations. » — l'association chèque↔opération, **à deux
// visages**.
//
// Portage de `Code Liste Operation Cheques.txt`. Son `gChequeAsso` décide de
// tout : non nul, la fenêtre montre les opérations **déjà associées** à ce
// chèque ; à zéro, elle montre celles que l'on **peut** associer, bornées au
// compte du carnet.
//
// Les deux visages ne montrent que les opérations **mères**
// (`IDOperationParent = 0`) : une sous-opération ne porte jamais de chèque.
//
// **Le gras est le seul avertissement.** Une opération qui porte déjà un chèque
// s'affiche en gras et reste choisissable ; l'associer ailleurs écrase son lien
// sans rien demander. C'est son original, arbitré tel quel par Fabrice le
// 28/07/2026.
//
// **La croix rouge détache, elle ne supprime pas.** L'opération reste dans son
// compte, le chèque reste dans son carnet ; seul `IDCheque` revient à zéro.

import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { Table } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

const PARAMETERS_EVENT = "window-parameters:cheque-operations";

interface Row {
  id: number;
  account_label: string;
  label: string;
  date: string;
  clearing_date: string;
  amount: number;
  amount_text: string;
  cheque_id: number;
  cheque_reference: string;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

let chequeId = 0;
let accountId = 0;
/// Lequel des deux visages. `true` : celles déjà associées.
let showingLinked = true;

function shownDate(iso: string): string {
  if (!iso) {
    return "";
  }
  const [year, month, day] = iso.split("-");
  return `${day}/${month}/${year}`;
}

const table = new Table<Row>({
  container: element<HTMLDivElement>("rows"),
  columns: [
    {
      title: () => t("cheque-operations-column-account"),
      cell: (row) => row.account_label,
      width: "160px",
    },
    { title: () => t("cheque-operations-column-label"), cell: (row) => row.label },
    {
      title: () => t("cheque-operations-column-date"),
      cell: (row) => shownDate(row.date),
      key: (row) => row.date,
      width: "120px",
    },
    {
      title: () => t("cheque-operations-column-clearing"),
      cell: (row) => shownDate(row.clearing_date),
      key: (row) => row.clearing_date,
      width: "140px",
    },
    {
      title: () => t("cheque-operations-column-amount"),
      cell: (row) => row.amount_text,
      key: (row) => row.amount,
      money: (row) => row.amount,
      numeric: true,
      width: "130px",
    },
    {
      title: () => t("cheque-operations-column-cheque"),
      cell: (row) => row.cheque_reference,
      width: "170px",
    },
  ],
  identity: (row) => row.id,
  exportAs: () => ({ name: t("window-cheque-operations-title"), detail: "" }),
  emptyText: () =>
    showingLinked ? t("cheque-operations-none-linked") : t("cheque-operations-none"),
  filteredOutText: () => t("cheque-operations-nothing-to-show"),
  // Une opération à la fois : la question a une seule réponse.
  singleSelection: true,
  // **Le gras de son `TableData_SyncFichier`** : elle porte déjà un chèque.
  rowClass: (row) => (row.cheque_id !== 0 ? "list__row--taken" : null),
  onSelectionChange: () => say(helpText()),
  onActivate: () => void (showingLinked ? openOperation() : associate()),
});

function helpText(): string {
  return showingLinked ? t("cheque-operations-linked-help") : t("cheque-operations-help");
}

function requireSelection(): boolean {
  if (table.selected().length === 0) {
    say(t("ui-select-record"), true);
    return false;
  }
  return true;
}

/// Ce que le visage courant montre, et les boutons qu'il autorise.
function applyFace(): void {
  element<HTMLElement>("question").textContent = showingLinked
    ? t("cheque-operations-linked-title")
    : t("cheque-operations-choose-title");
  element<HTMLButtonElement>("open").hidden = !showingLinked;
  element<HTMLButtonElement>("dissociate").hidden = !showingLinked;
  element<HTMLButtonElement>("associate").hidden = showingLinked;
  say(helpText());
}

async function reload(): Promise<void> {
  try {
    table.setRows(
      await invoke<Row[]>("cheque_operations", {
        chequeId,
        accountId,
        linked: showingLinked,
      }),
    );
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// La base a-t-elle pu s'ouvrir ? Sans elle il n'y a aucune opération à
/// montrer, et les trois boutons du panneau ne mènent nulle part.
async function checkStartup(): Promise<boolean> {
  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    for (const id of ["open", "dissociate", "associate"]) {
      element<HTMLButtonElement>(id).disabled = true;
    }
    return false;
  }
  return true;
}

/// Le crayon : la fiche de l'opération, dans la liste des opérations de son
/// compte — c'est son `Ouvre(FEN_FicheOperation, …, COL_IDCompte)`.
async function openOperation(): Promise<void> {
  if (!requireSelection()) {
    return;
  }
  try {
    await invoke("open_form_for_operation", { id: table.selected()[0] });
  } catch (error) {
    say(tError("ui-open-failed", error), true);
  }
}

async function associate(): Promise<void> {
  if (!requireSelection()) {
    return;
  }
  try {
    // **Aucune question**, même quand la ligne est en gras : son original
    // écrase, et le gras était l'avertissement.
    if (!(await invoke<boolean>("associate_cheque", {
      operationId: table.selected()[0],
      chequeId,
    }))) {
      say(t("cheque-gone"), true);
      return;
    }
    await reload();
    await invoke("notify_cheques_changed");
    say(t("cheque-operations-linked"));
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

async function dissociate(): Promise<void> {
  if (!requireSelection()) {
    return;
  }
  try {
    if (!(await invoke<boolean>("dissociate_cheque", { operationId: table.selected()[0] }))) {
      say(t("cheque-gone"), true);
      return;
    }
    table.clearSelection();
    await reload();
    await invoke("notify_cheques_changed");
    say(t("cheque-operations-dissociated"));
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

element<HTMLButtonElement>("open").addEventListener("click", () => void openOperation());
element<HTMLButtonElement>("dissociate").addEventListener("click", () => void dissociate());
element<HTMLButtonElement>("associate").addEventListener("click", () => void associate());
element<HTMLButtonElement>("close").addEventListener("click", () => {
  void invoke("close_cheque_window", { label: "cheque-operations" }).catch((error) =>
    say(tError("ui-close-failed", error), true),
  );
});

void listen("data-changed:cheque-operations", () => void reload());
void listen<string>(PARAMETERS_EVENT, (event) => {
  readParameters(event.payload);
  table.clearSelection();
  applyFace();
  void reload();
});

function readParameters(query: string): void {
  const parameters = new URLSearchParams(query);
  chequeId = Number(parameters.get("cheque") ?? 0);
  accountId = Number(parameters.get("account") ?? 0);
  showingLinked = parameters.get("linked") === "1";
  history.replaceState(
    null,
    "",
    `?cheque=${chequeId}&account=${accountId}&linked=${showingLinked ? 1 : 0}`,
  );
}

/// Pose les mots de la fenêtre, à l'ouverture et à chaque changement de
/// langue — une fenêtre est bâtie une fois et jamais détruite, elle ne peut que
/// se rhabiller.
///
/// Elle finit par relire les opérations : les montants et les dates sont
/// écrits par le noyau, et une liste rhabillée qui garderait ses anciennes
/// lignes serait à moitié traduite.
async function dress(): Promise<void> {
  table.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));
  // Le clic droit exporte, dans toutes les listes : c'est le tableau partagé
  // qui le porte, et il ne se rebranche pas quand on le rappelle.
  table.exportOnRightClick(say);
  // Le menu Filtre : présent, nommé, et inactif. La place est réservée.
  element<HTMLElement>("filter-menu").textContent = t("cheque-operations-menu-filter");
  for (const [id, key] of [
    ["open", "ui-title-update"],
    ["dissociate", "cheque-title-dissociate"],
    ["associate", "cheque-title-associate"],
    ["close", "ui-title-close"],
  ] as const) {
    element<HTMLElement>(id).title = t(key);
  }
  // Le visage courant redit sa question et son aide. `applyFace` ne choisit
  // pas le visage, elle ne fait que l'appliquer — et elle ne touche pas à la
  // sélection : la rappeler ici ne change rien de ce que l'on regardait.
  applyFace();

  if (await checkStartup()) {
    await reload();
  }
}

void (async () => {
  await loadTexts(null);
  // Le visage d'abord : c'est lui qui décide de la question que les mots
  // posent, et des boutons qui la servent.
  readParameters(window.location.search);
  await dress();
  onLanguageChanged(dress, { key: "window-cheque-operations-title" });
})();
