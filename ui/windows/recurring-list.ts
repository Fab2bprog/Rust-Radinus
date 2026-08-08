// F38 — « Liste des operations periodiques ».
//
// Le gabarit des listes de Radinus, une colonne LIBELLE, plus **une icône que
// les autres n'ont pas** : le calendrier.
//
// Elle demande à une ou plusieurs règles ce qu'elles proposeraient, et
// **n'écrit rien** : la proposition s'ouvre dans sa propre fenêtre, où l'on
// retire ce qu'on ne veut pas avant qu'un second geste n'insère.
//
// Supprimer une règle laisse ses opérations dans les comptes (décision de
// Fabrice, 31/07/2026) : ce sont de vraies écritures, passées en banque pour
// certaines, et elles gardent la marque de la règle qui les a produites.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askYesNo } from "./dialog";
import { closeCurrentWindow } from "./window-frame";
import { Table } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

interface Row {
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

const table = new Table<Row>({
  container: element<HTMLDivElement>("rows"),
  columns: [{ title: () => t("recurring-column-label"), cell: (row) => row.label }],
  identity: (row) => row.id,
  exportAs: () => ({ name: t("recurring-column-label"), detail: "" }),
  emptyText: () => t("recurring-none"),
  filteredOutText: () => t("ui-no-match"),
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
    table.setRows(await invoke<Row[]>("list_recurring_rules"));
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

async function openForm(mode: "A" | "M" | "L"): Promise<void> {
  if (mode !== "A" && !requireSelection()) {
    return;
  }
  try {
    await invoke("open_recurring_form", {
      mode,
      id: mode === "A" ? 0 : table.selected()[0],
    });
  } catch (error) {
    say(tError("ui-open-failed", error), true);
  }
}

/// Le calendrier des règles choisies. **Plusieurs à la fois** : son code
/// reçoit un tableau d'identifiants, et empile les échéances de toutes.
async function proposeCalendar(): Promise<void> {
  if (!requireSelection()) {
    return;
  }
  try {
    await invoke("open_recurring_calendar", { ids: table.selected() });
  } catch (error) {
    say(tError("ui-open-failed", error), true);
  }
}

async function deleteSelection(): Promise<void> {
  if (!requireSelection()) {
    return;
  }
  try {
    // La question dit ce qui va rester : les opérations déjà insérées ne
    // partent pas avec la règle, et il vaut mieux le dire avant que de le
    // laisser découvrir.
    if (!(await askYesNo(t("recurring-delete-question"), t("ui-yes"), t("ui-no")))) {
      say(t("ui-deletion-abandoned"));
      return;
    }
    const said = await invoke<string>("delete_recurring_rules", { ids: table.selected() });
    table.clearSelection();
    await reload();
    say(said);
  } catch (error) {
    say(tError("ui-delete-failed", error), true);
  }
}

element<HTMLButtonElement>("create").addEventListener("click", () => void openForm("A"));
element<HTMLButtonElement>("update").addEventListener("click", () => void openForm("M"));
element<HTMLButtonElement>("read").addEventListener("click", () => void openForm("L"));
element<HTMLButtonElement>("delete").addEventListener("click", () => void deleteSelection());
element<HTMLButtonElement>("calendar").addEventListener("click", () => void proposeCalendar());
element<HTMLButtonElement>("close").addEventListener("click", () => closeCurrentWindow());

void listen("data-changed:recurring", () => void reload());
/// Redemandée par le menu alors qu'elle est déjà là : une fenêtre de Radinus
/// est bâtie une fois et jamais détruite, donc revenir dessus doit la relire —
/// une règle a pu naître ou disparaître entre-temps.
void listen("window-parameters:recurring", () => void reload());

/// **Pose les mots de la fenêtre.** Appelée à l'ouverture, et de nouveau à
/// chaque changement de langue.
///
/// Une liste ne tient rien qui lui soit propre : ses lignes viennent du noyau,
/// et la phrase du bas avec. Elle se termine donc par sa relecture — c'est le
/// seul moyen que la colonne LIBELLE et le message d'une liste vide suivent la
/// langue.
async function dress(): Promise<void> {
  table.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));

  for (const [id, key] of [
    ["create", "ui-title-create"],
    ["update", "ui-title-update"],
    ["delete", "ui-title-delete"],
    ["read", "ui-title-read"],
    ["calendar", "recurring-title-calendar"],
    ["close", "ui-title-close"],
  ] as const) {
    element<HTMLElement>(id).title = t(key);
  }

  await reload();
  say(t("recurring-help"));
}

void (async () => {
  await loadTexts(null);
  await dress();
  table.exportOnRightClick(say);

  // Le démarrage manqué se dit **après** l'habillage : la fenêtre garde ses
  // icônes et son en-tête, et la barre porte l'erreur plutôt que l'invitation à
  // choisir une règle.
  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    return;
  }
  onLanguageChanged(dress, { key: "window-recurring-list-title" });
})();
