// « Liste des pieces jointes » — les pièces jointes d'une opération.
//
// Quatre gestes, ceux de sa capture : en ajouter une, **remplacer** le
// document par un autre, la supprimer avec confirmation, et l'ouvrir avec
// l'application par défaut du système. La fenêtre ne détient rien — ni le
// fichier, ni son chemin : elle envoie une clef et le noyau fait le reste. Le
// chemin d'un document n'a rien à faire dans le navigateur, où il ne servirait
// qu'à être détourné.
//
// **Retirer envoie le fichier à la corbeille**, jamais au néant : c'est le
// `frVersCorbeille` de l'original, et une pièce supprimée par erreur se
// récupère d'un clic droit.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askYesNo } from "./dialog";
import { Table } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

interface Row {
  id: number;
  name: string;
  guid_name: string;
  size: number;
  size_text: string;
  mime: string;
  added: string;
  state: string;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

let operationId = 0;
let rows: Row[] = [];

const table = new Table<Row>({
  container: element<HTMLDivElement>("rows"),
  // **Deux colonnes, les siennes.** Le nom du document sous LIBELLE, et son
  // nom physique sous Identifiant : c'est lui qui identifie vraiment une pièce
  // jointe, et c'est sous ce nom qu'on la retrouve dans le dossier et dans les
  // sauvegardes. Le poids, le type et la date vivent dans la barre du bas,
  // pour la ligne choisie.
  columns: [
    { title: () => t("ui-column-label"), cell: (row) => row.name, width: "2fr" },
    { title: () => t("ui-identifier"), cell: (row) => row.guid_name, width: "1fr" },
  ],
  identity: (row) => row.id,
  exportAs: () => ({ name: t("window-attachments-title"), detail: "" }),
  emptyText: () => t("attachment-none"),
  filteredOutText: () => t("ui-no-match"),
  onSelectionChange: () => describe(),
  onActivate: (row) => void open(row.id),
});

/// Ce que la barre du bas dit de la ligne choisie : son poids, son type, sa
/// date, et l'état de son fichier. Rien de choisi, et elle redit comment on
/// choisit plusieurs lignes — la phrase de sa capture.
function describe(): void {
  const selected = table.selected();
  if (selected.length !== 1) {
    say(t("ui-multiselect-help"));
    return;
  }
  const row = rows.find((one) => one.id === selected[0]);
  if (row === undefined) {
    say(t("ui-multiselect-help"));
    return;
  }
  say(`${row.size_text} — ${row.mime} — ${row.added} — ${row.state}`);
}

/// La pièce choisie, ou rien — avec le refus de l'original quand rien n'est
/// choisi.
function chosen(): number | null {
  const selected = table.selected();
  if (selected.length === 0) {
    say(t("ui-select-record"), true);
    return null;
  }
  return selected[0];
}

async function reload(): Promise<void> {
  try {
    rows = await invoke<Row[]>("list_attachments", { operationId });
    table.setRows(rows);
    say(t("ui-multiselect-help"));
  } catch (error) {
    say(tError("ui-load-failed", error), true);
  }
}

/// La base a-t-elle pu s'ouvrir ? Sans elle il n'y a aucune pièce à montrer, et
/// rien à quoi en accrocher une nouvelle.
async function checkStartup(): Promise<boolean> {
  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    element<HTMLButtonElement>("add").disabled = true;
    return false;
  }
  return true;
}

async function add(): Promise<void> {
  try {
    const said = await invoke<string>("add_attachment", { operationId });
    // Une chaîne vide : le sélecteur a été refermé sans rien choisir.
    if (said !== "") {
      say(said);
      await reload();
    }
  } catch (error) {
    say(String(error), true);
  }
}

async function open(id: number): Promise<void> {
  try {
    say(await invoke<string>("open_attachment", { id }));
  } catch (error) {
    say(String(error), true);
  }
}

/// Le crayon : **remplacer** le document par un autre, la pièce restant la
/// même — même clef, même opération.
async function replace(): Promise<void> {
  const id = chosen();
  if (id === null) {
    return;
  }
  try {
    const said = await invoke<string>("replace_attachment", { id });
    if (said !== "") {
      say(said);
      await reload();
    }
  } catch (error) {
    say(String(error), true);
  }
}

async function remove(): Promise<void> {
  const id = chosen();
  if (id === null) {
    return;
  }
  try {
    const question = await invoke<string>("attachment_removal_question", { id });
    if (!(await askYesNo(question, t("ui-yes"), t("ui-no")))) {
      say(t("ui-deletion-abandoned"));
      return;
    }
    say(await invoke<string>("delete_attachment", { id }));
    await reload();
  } catch (error) {
    say(String(error), true);
  }
}

element<HTMLButtonElement>("add").addEventListener("click", () => void add());
element<HTMLButtonElement>("open").addEventListener("click", () => {
  const id = chosen();
  if (id !== null) {
    void open(id);
  }
});
element<HTMLButtonElement>("replace").addEventListener("click", () => void replace());
element<HTMLButtonElement>("remove").addEventListener("click", () => void remove());
element<HTMLButtonElement>("close").addEventListener("click", () => {
  void (async () => {
    try {
      await invoke("close_attachments_window");
    } catch (error) {
      say(tError("ui-close-failed", error), true);
    }
  })();
});

function readParameters(query: string): void {
  const asked = Number(new URLSearchParams(query).get("operation") ?? "0");
  operationId = Number.isFinite(asked) && asked > 0 ? asked : 0;
}

/// Rouverte sur une autre opération : la fenêtre est bâtie une fois et jamais
/// détruite, donc la nouvelle clef arrive par un événement. Sans cette écoute,
/// elle montrerait éternellement les pièces de la première.
void listen<string>("window-parameters:attachments", (event) => {
  readParameters(event.payload);
  table.clearSelection();
  void reload();
});

/// Pose les mots de la fenêtre, à l'ouverture et à chaque changement de
/// langue — une fenêtre est bâtie une fois et jamais détruite, elle ne peut que
/// se rhabiller.
///
/// Elle finit par relire les pièces jointes : le poids d'un document, sa date
/// et l'état de son fichier sont écrits par le noyau, et c'est la barre du bas
/// qui les redit. Une liste rhabillée qui garderait ses anciennes lignes serait
/// à moitié traduite.
async function dress(): Promise<void> {
  table.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));
  // Le clic droit exporte, dans toutes les listes : c'est le tableau partagé
  // qui le porte, et il ne se rebranche pas quand on le rappelle.
  table.exportOnRightClick(say);
  for (const [id, key] of [
    ["add", "attachment-title-add"],
    ["replace", "attachment-title-replace"],
    ["open", "attachment-title-open"],
    ["remove", "attachment-title-remove"],
    ["close", "ui-title-close"],
  ] as const) {
    element<HTMLElement>(id).title = t(key);
  }

  if (await checkStartup()) {
    await reload();
  }
}

void (async () => {
  await loadTexts(null);
  // L'opération d'abord : c'est d'elle que dépendent les lignes que la
  // relecture ira chercher.
  readParameters(window.location.search);
  await dress();
  onLanguageChanged(dress, { key: "window-attachments-title" });
})();
