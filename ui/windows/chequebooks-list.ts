// F13 — « Liste des chequiers ».
//
// Portage de `Code Liste Chequier.txt`. Les quatre actions du panneau, le refus
// « Veuillez sélectionner un enregistrement » quand rien n'est choisi
// (`Ouvre_Fiche`), et le rechargement du tableau quand la fiche se referme
// (`TableData_SyncFichier`).
//
// **Sa question de suppression est posée une seule fois** pour toute la
// sélection : c'est le `bConfirmation` de son `Enreg_Supprimer`, qui passe à
// Faux dès le premier Oui. Et elle ne détruit aucune opération bancaire — elle
// leur retire leur chèque.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askYesNo } from "./dialog";
import { Table } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

interface Row {
  id: number;
  reference: string;
  received_on: string;
  account_label: string;
  account_number: string;
  comments: string;
}

interface DeletionPlan {
  refused: boolean;
  refusal: string;
  needs_confirmation: boolean;
  question: string;
  operations: number;
}

/// **Une page, deux usages** — son `ModeListe`. Vide, on gère ses carnets ;
/// « SEL », on en choisit un pour la fiche opération qui cherche un chèque, et
/// les boutons de gestion s'effacent (`IHM_ModeListe`).
let selecting = false;
/// L'opération qui attend son chèque, quand on est venu en choisir un.
let operationId = 0;

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

/// Une date ISO écrite comme la fenêtre l'écrit : 01/08/2020. Vide reste vide —
/// un carnet sans date de réception n'affiche rien, pas « 01/01/1970 ».
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
    { title: () => t("chequebooks-column-reference"), cell: (row) => row.reference },
    {
      title: () => t("chequebooks-column-date"),
      cell: (row) => shownDate(row.received_on),
      // Trié sur l'ISO, pas sur ce qui est écrit : « 01/08/2020 » et
      // « 26/10/2025 » se trieraient par leur jour.
      key: (row) => row.received_on,
      width: "140px",
    },
    { title: () => t("chequebooks-column-account"), cell: (row) => row.account_label },
    {
      title: () => t("chequebooks-column-account-number"),
      cell: (row) => row.account_number,
    },
    { title: () => t("chequebooks-column-comments"), cell: (row) => row.comments },
  ],
  identity: (row) => row.id,
  exportAs: () => ({ name: t("window-chequebooks-title"), detail: "" }),
  emptyText: () => t("chequebooks-none"),
  filteredOutText: () => t("chequebooks-nothing-to-show"),
  onSelectionChange: () => say(t("ui-multiselect-help")),
  onActivate: () => void openForm("M"),
});

function requireSelection(): boolean {
  if (table.selected().length === 0) {
    say(t("ui-select-record"), true);
    return false;
  }
  return true;
}

async function reload(): Promise<void> {
  try {
    table.setRows(await invoke<Row[]>("list_chequebooks"));
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// La base a-t-elle pu s'ouvrir ? Sans elle il n'y a aucun carnet à montrer, et
/// les quatre actions du panneau ne mènent nulle part.
async function checkStartup(): Promise<boolean> {
  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    for (const id of ["create", "update", "delete", "composition"]) {
      element<HTMLButtonElement>(id).disabled = true;
    }
    return false;
  }
  return true;
}

async function openForm(mode: "A" | "M"): Promise<void> {
  if (mode !== "A" && !requireSelection()) {
    return;
  }
  try {
    await invoke("open_chequebook_form", {
      mode,
      id: mode === "A" ? null : table.selected()[0],
    });
  } catch (error) {
    say(tError("ui-open-failed", error), true);
  }
}

/// Le carnet : la composition du chéquier (F14), sur le carnet choisi.
async function openComposition(): Promise<void> {
  if (!requireSelection()) {
    return;
  }
  try {
    await invoke("open_cheques", { chequebookId: table.selected()[0] });
  } catch (error) {
    say(tError("ui-open-failed", error), true);
  }
}

async function deleteSelection(): Promise<void> {
  if (!requireSelection()) {
    return;
  }
  try {
    const plan = await invoke<DeletionPlan>("plan_chequebook_deletion", {
      ids: table.selected(),
    });
    // **Une seule question pour toute la sélection**, comme son bConfirmation.
    // Et elle ne parle jamais de supprimer des opérations : elle prévient que
    // des opérations y sont accrochées, et qu'elles vont perdre leur chèque.
    if (plan.needs_confirmation) {
      if (!(await askYesNo(plan.question, t("ui-yes"), t("ui-no")))) {
        say(t("ui-deletion-abandoned"));
        return;
      }
    }
    const deleted = await invoke<number>("delete_chequebooks", { ids: table.selected() });
    table.clearSelection();
    await reload();
    await invoke("notify_cheques_changed");
    say(await invoke<string>("chequebooks_deleted_text", { count: deleted }));
  } catch (error) {
    say(tError("ui-delete-failed", error), true);
  }
}

element<HTMLButtonElement>("create").addEventListener("click", () => void openForm("A"));
element<HTMLButtonElement>("update").addEventListener("click", () => void openForm("M"));
element<HTMLButtonElement>("delete").addEventListener("click", () => void deleteSelection());
element<HTMLButtonElement>("composition").addEventListener(
  "click",
  () => void openComposition(),
);
/// Le carnet choisi : on passe au second temps, ses chèques.
async function chooseBook(): Promise<void> {
  if (!requireSelection()) {
    return;
  }
  try {
    await invoke("choose_cheque_in_chequebook", {
      operationId,
      chequebookId: table.selected()[0],
    });
  } catch (error) {
    say(tError("ui-open-failed", error), true);
  }
}

element<HTMLButtonElement>("select").addEventListener("click", () => void chooseBook());
element<HTMLButtonElement>("close").addEventListener("click", () => {
  if (selecting) {
    void invoke("close_cheque_choice").catch((error) =>
      say(tError("ui-close-failed", error), true),
    );
    return;
  }
  void invoke("close_cheque_window", { label: "chequebooks" }).catch((error) =>
    say(tError("ui-close-failed", error), true),
  );
});

function readParameters(query: string): void {
  const parameters = new URLSearchParams(query);
  // Une fois « choisir », toujours « choisir » : l'événement de réouverture
  // ne reporte pas le mode de l'adresse de départ.
  selecting = selecting || parameters.get("mode") === "SEL";
  operationId = Number(parameters.get("operation") ?? 0);
}

/// `IHM_ModeListe` : ce que le mode laisse voir.
function applyMode(): void {
  for (const id of ["create", "update", "delete", "composition"]) {
    element<HTMLButtonElement>(id).hidden = selecting;
  }
  element<HTMLButtonElement>("select").hidden = !selecting;
  const question = element<HTMLElement>("question");
  question.hidden = !selecting;
  question.textContent = selecting ? t("chequebooks-select-question") : "";
  table.clearSelection();
}

void listen("data-changed:chequebooks", () => void reload());
void listen<string>("window-parameters:chequebooks", () => {
  table.clearSelection();
  void reload();
});
void listen<string>("window-parameters:chequebooks-select", (event) => {
  readParameters(event.payload);
  applyMode();
  void reload();
});

/// Pose les mots de la fenêtre, à l'ouverture et à chaque changement de
/// langue — une fenêtre est bâtie une fois et jamais détruite, elle ne peut que
/// se rhabiller.
///
/// Elle finit par relire les carnets : la date de réception et le libellé du
/// compte sont écrits par le noyau, et une liste rhabillée qui garderait ses
/// anciennes lignes serait à moitié traduite.
async function dress(): Promise<void> {
  table.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));
  // Le clic droit exporte, dans toutes les listes : c'est le tableau partagé
  // qui le porte, et il ne se rebranche pas quand on le rappelle.
  table.exportOnRightClick(say);
  for (const [id, key] of [
    ["select", "ui-title-select"],
    ["create", "ui-title-create"],
    ["update", "ui-title-update"],
    ["delete", "ui-title-delete"],
    ["composition", "chequebooks-title-composition"],
    ["close", "ui-title-close"],
  ] as const) {
    element<HTMLElement>(id).title = t(key);
  }
  // **La question se redit, le mode ne bouge pas.** Passer par `applyMode`
  // referait le partage des boutons et effacerait la sélection : perdre le
  // carnet que l'on venait de choisir parce qu'on a changé de langue serait
  // une surprise. Ici on ne fait que réécrire la question du mode en vigueur.
  const question = element<HTMLElement>("question");
  question.textContent = selecting ? t("chequebooks-select-question") : "";
  say(t("ui-multiselect-help"));

  if (await checkStartup()) {
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
  // Rust : `chequebooks_list` le tire de la même clef dans les deux modes.
  onLanguageChanged(dress, { key: "window-chequebooks-title" });
})();
