// F14 — « Composition du chéquier : liste des chèques. »
//
// Portage de `Code liste cheques.txt`, moins ce que son panneau n'appelle pas :
// `Enreg_Supprimer` y est écrite, aucune icône ne la déclenche, et Fabrice a
// tranché — pas de bouton (28/07/2026). Un carnet de quarante a quarante
// chèques, même annulés.
//
// **Le statut se change dans la case**, comme dans la classification rapide.
// Le tableau partagé sait le faire : `editor` sur la colonne, et l'écriture
// part aussitôt — un chèque est un enregistrement à lui seul, il n'y a pas de
// brouillon à tenir comme dans F05.
//
// **La colonne « Nbr. Opération Associées » compte les filles**, alors que les
// deux listes d'association ne montrent que les mères. C'est son `NombreOpChq`,
// et les deux nombres peuvent donc diverger : fidélité assumée.

import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { Table } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

const PARAMETERS_EVENT = "window-parameters:cheques";

interface Row {
  id: number;
  number: string;
  date: string;
  place: string;
  payee: string;
  amount: number;
  amount_text: string;
  status_id: number;
  status: string;
  comments: string;
  operations: number;
}

interface Item {
  id: number;
  label: string;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

let chequebookId = 0;
let statuses: Item[] = [];
/// Le second temps de la pêche au chèque : « SEL », et l'opération qui attend.
let selecting = false;
let operationId = 0;

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
      title: () => t("cheques-column-number"),
      cell: (row) => row.number,
      // Trié sur le nombre, pas sur « 9 506 001 » : l'espace insécable
      // trierait 9 506 010 avant 9 506 009.
      key: (row) => Number(row.number.replace(/\D/g, "")),
      numeric: true,
      width: "130px",
    },
    {
      title: () => t("cheques-column-date"),
      cell: (row) => shownDate(row.date),
      key: (row) => row.date,
      width: "120px",
    },
    { title: () => t("cheques-column-place"), cell: (row) => row.place, width: "140px" },
    { title: () => t("cheques-column-payee"), cell: (row) => row.payee },
    {
      title: () => t("cheques-column-amount"),
      cell: (row) => row.amount_text,
      key: (row) => row.amount,
      money: (row) => row.amount,
      numeric: true,
      width: "130px",
    },
    {
      title: () => t("cheques-column-status"),
      cell: (row) => row.status,
      width: "190px",
      // **La case elle-même est le menu.** Sur la ligne choisie, la colonne
      // devient une liste des quinze statuts.
      editor: {
        options: () => statuses,
        value: (row) => row.status_id,
        change: (row, value) => void changeStatus(row, value),
      },
    },
    { title: () => t("cheques-column-comments"), cell: (row) => row.comments },
    {
      title: () => t("cheques-column-operations"),
      cell: (row) => String(row.operations),
      key: (row) => row.operations,
      numeric: true,
      width: "180px",
    },
  ],
  identity: (row) => row.id,
  exportAs: () => ({ name: t("window-cheques-title"), detail: "" }),
  emptyText: () => t("cheques-none"),
  filteredOutText: () => t("cheques-nothing-to-show"),
  singleSelection: true,
  onSelectionChange: () => say(t("cheques-help")),
  onActivate: () => void openForm(),
});

async function changeStatus(row: Row, status: number): Promise<void> {
  try {
    if (!(await invoke<boolean>("set_cheque_status", { id: row.id, statusId: status }))) {
      say(t("cheque-gone"), true);
      return;
    }
    await reload();
    say(t("cheques-status-changed"));
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

function requireSelection(): boolean {
  if (table.selected().length === 0) {
    say(t("ui-select-record"), true);
    return false;
  }
  return true;
}

async function reload(): Promise<void> {
  try {
    table.setRows(await invoke<Row[]>("list_cheques", { chequebookId }));
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// La base a-t-elle pu s'ouvrir ? Sans elle il n'y a rien à lire, et les trois
/// boutons de travail ne mènent nulle part.
async function checkStartup(): Promise<boolean> {
  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    for (const id of ["update", "linked", "link"]) {
      element<HTMLButtonElement>(id).disabled = true;
    }
    return false;
  }
  return true;
}

async function openForm(): Promise<void> {
  if (!requireSelection()) {
    return;
  }
  try {
    await invoke("open_cheque_form", { id: table.selected()[0] });
  } catch (error) {
    say(tError("ui-open-failed", error), true);
  }
}

/// Les deux visages de la même fenêtre : la loupe montre ce qui est déjà
/// accroché, le maillon propose ce qu'on peut accrocher.
async function openOperations(linked: boolean): Promise<void> {
  if (!requireSelection()) {
    return;
  }
  try {
    await invoke("open_cheque_operations", { chequeId: table.selected()[0], linked });
  } catch (error) {
    say(tError("ui-open-failed", error), true);
  }
}

element<HTMLButtonElement>("update").addEventListener("click", () => void openForm());
element<HTMLButtonElement>("linked").addEventListener("click", () => void openOperations(true));
element<HTMLButtonElement>("link").addEventListener("click", () => void openOperations(false));
/// Le chèque choisi : on l'accroche à l'opération qui attendait, et les deux
/// fenêtres de choix se referment. **Aucune question**, même si l'opération
/// portait déjà un chèque — son original écrase.
async function chooseCheque(): Promise<void> {
  if (!requireSelection()) {
    return;
  }
  try {
    if (!(await invoke<boolean>("associate_cheque", {
      operationId,
      chequeId: table.selected()[0],
    }))) {
      say(t("cheque-gone"), true);
      return;
    }
    await invoke("notify_cheques_changed");
    await invoke("close_cheque_choice");
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

element<HTMLButtonElement>("select").addEventListener("click", () => void chooseCheque());
element<HTMLButtonElement>("close").addEventListener("click", () => {
  if (selecting) {
    void invoke("close_cheque_choice").catch((error) =>
      say(tError("ui-close-failed", error), true),
    );
    return;
  }
  void invoke("close_cheque_window", { label: "cheques" }).catch((error) =>
    say(tError("ui-close-failed", error), true),
  );
});

void listen("data-changed:cheques", () => void reload());
for (const name of [PARAMETERS_EVENT, "window-parameters:cheques-select"]) {
  void listen<string>(name, (event) => {
    readParameters(event.payload);
    applyMode();
    void reload();
  });
}

function readParameters(query: string): void {
  const parameters = new URLSearchParams(query);
  chequebookId = Number(parameters.get("chequebook") ?? 0);
  selecting = selecting || parameters.get("mode") === "SEL" || parameters.has("operation");
  operationId = Number(parameters.get("operation") ?? 0);
}

/// `IHM_ModeListe` : en mode « choisir », les trois boutons de travail
/// s'effacent et la main paraît.
function applyMode(): void {
  for (const id of ["update", "linked", "link"]) {
    element<HTMLButtonElement>(id).hidden = selecting;
  }
  element<HTMLButtonElement>("select").hidden = !selecting;
  const question = element<HTMLElement>("question");
  question.hidden = !selecting;
  question.textContent = selecting ? t("cheques-select-question") : "";
  table.clearSelection();
}

/// Pose les mots de la fenêtre, à l'ouverture et à chaque changement de
/// langue — une fenêtre est bâtie une fois et jamais détruite, elle ne peut que
/// se rhabiller.
///
/// Elle finit par relire les chèques : ce qu'une ligne montre est écrit dans la
/// langue lui aussi — le montant a ses séparateurs et le statut sa phrase —, et
/// une liste rhabillée qui garderait ses anciennes lignes serait à moitié
/// traduite.
async function dress(): Promise<void> {
  table.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));
  // Le clic droit exporte, dans toutes les listes : c'est le tableau partagé
  // qui le porte, et il ne se rebranche pas quand on le rappelle.
  table.exportOnRightClick(say);
  say(t("cheques-help"));
  for (const [id, key] of [
    ["select", "ui-title-select"],
    ["update", "ui-title-update"],
    ["linked", "cheques-title-linked"],
    ["link", "cheques-title-link"],
    ["close", "ui-title-close"],
  ] as const) {
    element<HTMLElement>(id).title = t(key);
  }
  // **La question se redit, le mode ne bouge pas.** Passer par `applyMode`
  // referait le partage des boutons et effacerait la sélection : perdre le
  // chèque que l'on venait de pointer parce qu'on a changé de langue serait
  // une surprise. Ici on ne fait que réécrire la question du mode en vigueur.
  const question = element<HTMLElement>("question");
  question.textContent = selecting ? t("cheques-select-question") : "";

  if (await checkStartup()) {
    // Les quinze statuts sont écrits par le noyau, et c'est cette liste-là qui
    // s'ouvre dans la case : sans la redemander, la colonne serait traduite et
    // son menu ne le serait pas.
    statuses = await invoke<Item[]>("list_cheque_statuses");
    await reload();
  }
}

void (async () => {
  await loadTexts(null);
  // Le mode d'abord : c'est lui qui décide de la question que les mots posent.
  readParameters(window.location.search);
  applyMode();
  await dress();
  // Les deux fenêtres — gestion et « choisir » — portent le même titre chez
  // Rust : `cheques_list` le tire de la même clef dans les deux modes.
  onLanguageChanged(dress, { key: "window-cheques-title" });
})();
