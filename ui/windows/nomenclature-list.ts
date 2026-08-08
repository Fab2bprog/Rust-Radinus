// F11 — the list of a nomenclature.
//
// **One page for the seven of them.** 04_SPECIFICATIONS_FENETRES.md: "gabarit
// identique pour les listes Affectations, Modes, Tiers, Projets, Postes
// budgétaires, Banques". The categories list was built first and hammered by
// Fabrice until it was right; it is the model, and this file *is* it, told in
// its address which nomenclature it is working on.
//
// Ported from the author's `Code liste categorie.txt`: the panel's four
// actions, the "Veuillez sélectionner un enregistrement" refusal when none is
// selected, and the reload of the table after the form closes
// (`TableData_SyncFichier`).
//
// The table itself — header that sorts, funnel that filters, multiple
// selection — is `table.ts`, shared with the accounts list, which has seven
// columns where this one has a single LIBELLE. It was written here first and
// moved out rather than copied: the accounts list would otherwise have been a
// second copy of everything Fabrice made me fix on this one.

import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askYesNo } from "./dialog";
import { currentKind } from "./nomenclature";
import { Table } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

/// Which nomenclature this window is working on. Read once, from the address.
const KIND = currentKind();

interface Item {
  id: number;
  label: string;
  budget_line_id: number;
}

/// Parameters addressed to **this** window and to no other — seven lists
/// share this page, so the event name carries the window's label.
const PARAMETERS_EVENT = `window-parameters:${KIND}-list`;
/// Its data moved and it should reload itself.
const CHANGED_EVENT = `data-changed:${KIND}-list`;

interface DeletionPlan {
  refused: boolean;
  refusal: string;
  needs_confirmation: boolean;
  question: string;
  operations: number;
  operation_templates: number;
  recurring_rules: number;
}

let items: Item[] = [];

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

/// The table itself is the shared gabarit: one column here, seven in the
/// accounts list, and the same behaviour written once (see `table.ts`).
const table = new Table<Item>({
  container: element<HTMLDivElement>("rows"),
  columns: [{ title: () => t("ui-column-label"), cell: (item) => item.label }],
  identity: (item) => item.id,
  exportAs: () => ({ name: t("ui-column-label"), detail: t("nomenclature-identifier") }),
  emptyText: () => t("nomenclature-none"),
  filteredOutText: () => t("ui-no-match"),
  onSelectionChange: () => say(t("ui-multiselect-help")),
  onActivate: () => void openForm("M"),
});

/// The original refuses every action needing a record when none is selected,
/// with this exact wording (`Ouvre_Fiche`).
function requireSelection(): boolean {
  if (table.selected().length === 0) {
    say(t("ui-select-record"), true);
    return false;
  }
  return true;
}

/// Nothing is worth attempting without a database: the window says so once,
/// plainly, and locks its buttons — rather than looking normal and failing on
/// every click.
async function checkStartup(): Promise<boolean> {
  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    for (const id of ["create", "update", "delete", "read"]) {
      element<HTMLButtonElement>(id).disabled = true;
    }
    table.setRows([]);
    return false;
  }
  return true;
}

async function reload(): Promise<void> {
  try {
    items = await invoke<Item[]>("list_elements", { kind: KIND });
    // The table drops from its selection anything that no longer exists.
    table.setRows(items);
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

async function openForm(mode: "A" | "M" | "L"): Promise<void> {
  if (mode !== "A" && !requireSelection()) {
    return;
  }
  try {
    await invoke("open_element_form", {
      kind: KIND,
      mode,
      id: mode === "A" ? null : table.selected()[0],
    });
  } catch (error) {
    say(tError("ui-open-failed", error), true);
  }
}

async function deleteSelection(): Promise<void> {
  if (!requireSelection()) {
    return;
  }

  try {
    const plan = await invoke<DeletionPlan>("plan_deletion", {
      kind: KIND,
      ids: table.selected(),
    });

    // An element whose fiche is open is not deleted from under it (author's
    // ruling, 25/07/2026): the fiche would be left showing a record that no
    // longer exists. The refusal names it, so it is clear which one is in the
    // way — nothing is asked, since there is nothing to confirm.
    if (plan.refused) {
      say(plan.refusal, true);
      return;
    }

    // One question for the whole selection (author's ruling, 25/07/2026).
    if (plan.needs_confirmation) {
      const confirmed = await askYesNo(plan.question, t("ui-yes"), t("ui-no"));
      if (!confirmed) {
        say(t("ui-deletion-abandoned"));
        return;
      }
    }

    const deleted = await invoke<number>("delete_elements", {
      kind: KIND,
      ids: table.selected(),
    });
    table.clearSelection();
    await reload();
    await invoke("notify_elements_changed", { kind: KIND });
    // The only sentence that is not in the dictionary: it counts, and Fluent
    // is what knows whether the count changes the sentence.
    say(await invoke<string>("ui_deleted_text", { kind: KIND, count: deleted }));
  } catch (error) {
    say(tError("ui-delete-failed", error), true);
  }
}

element<HTMLButtonElement>("create").addEventListener("click", () => void openForm("A"));
element<HTMLButtonElement>("update").addEventListener("click", () => void openForm("M"));
element<HTMLButtonElement>("read").addEventListener("click", () => void openForm("L"));
element<HTMLButtonElement>("delete").addEventListener("click", () => void deleteSelection());
/// The door. A form may be open on top of this list with something typed in
/// it, and closing the list would take it down — so the question is asked
/// here, by the window the user just clicked (author's decision, 25/07/2026).
async function leave(): Promise<void> {
  try {
    if (await invoke<boolean>("list_has_unsaved_changes", { kind: KIND })) {
      if (!(await askYesNo(t("ui-discard-question"), t("ui-yes"), t("ui-no")))) {
        return;
      }
    }
    await invoke("list_may_close", { kind: KIND });
  } catch (error) {
    say(tError("ui-close-failed", error), true);
  }
}

element<HTMLButtonElement>("close").addEventListener("click", () => void leave());

// The fiche tells this list, through Rust, that the data changed.
void listen(CHANGED_EVENT, () => void reload());

// Shown again after having been hidden: the data may have moved on since.
// The name carries this window's label, so the form never hears it — both
// windows sharing one name meant the form was silently reset to a blank
// "add" form every time this list was reopened.
void listen(PARAMETERS_EVENT, () => {
  table.clearSelection();
  void reload();
});

/// Pose les mots de la fenêtre — et les redemande au noyau quand la langue
/// change, puisqu'une fenêtre n'est bâtie qu'une fois.
///
/// Elle finit par relire la table : ce qu'un tableau montre est écrit dans la
/// langue lui aussi, et une liste rhabillée qui garderait ses anciennes lignes
/// serait à moitié traduite.
async function dress(): Promise<void> {
  table.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));
  // Le clic droit exporte, dans toutes les listes : c'est le tableau partagé
  // qui le porte, pas chaque fenêtre (§3.1).
  table.exportOnRightClick(say);
  say(t("ui-multiselect-help"));
  for (const [id, key] of [
    ["create", "ui-title-create"],
    ["update", "ui-title-update"],
    ["delete", "ui-title-delete"],
    ["read", "ui-title-read"],
    ["close", "ui-title-close"],
  ] as const) {
    element<HTMLElement>(id).title = t(key);
  }

  if (await checkStartup()) {
    await reload();
  }
}

// Its words before anything else: the window must never show a sentence of
// its own, not even for the instant before the dictionary arrives.
void (async () => {
  await loadTexts(KIND);
  await dress();
  // **Sans titre à reposer.** Celui de cette fenêtre est
  // `window-list-title`, qui choisit sa phrase sur `$kind` — et `retitle` ne
  // sait porter qu'un argument, `account`. Le noyau rendrait une phrase vide
  // et la fenêtre garderait de toute façon son étiquette : autant ne rien
  // demander, plutôt que de faire croire que le titre suit la langue.
  // Le titre de cette page dépend de la nomenclature affichée : la phrase
  // sélectionne sur « kind », et c'est sous ce nom que la clef part.
  onLanguageChanged(dress, { key: "window-list-title", argument: KIND, argumentName: "kind" });
})();
