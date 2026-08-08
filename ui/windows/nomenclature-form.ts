// F10 — the fiche of a nomenclature.
//
// **One page for the seven of them.** 04_SPECIFICATIONS_FENETRES.md says so:
// "gabarit identique pour les fiches Affectation, Mode, Tiers, Projet, Poste
// budgétaire, Banque — sans le champ Poste budgétaire". The category fiche was
// built first and hammered by Fabrice until it was right; it is the model, and
// this file *is* it, told in its address which nomenclature it is working on.
// Seven copies would have meant seven copies of every fault that took a day to
// remove.
//
// Ported from the author's `Code Fiche Categorie.txt`. Its three modes keep
// his own names: "A" adds, "M" modifies, "L" consults read-only — the confirm
// button reading "Ajouter" or "Modifier", and disappearing altogether in
// consultation with the fields locked (`Maj_Controles`). The window asks
// "Abandonner les modifications ?" on the way out when something was typed
// (`Action_Annuler`).
//
// **How a modification is detected. Fabrice's method, and the only one.**
// A reserve, filled when the record is loaded and holding exactly what the
// database gave. It is a structure and not loose variables, so that it reads
// like the record it is — one member per editable field. On the way out, each
// field is compared with its own member, one by one, at that moment. Nothing
// else is consulted and nothing is remembered from one visit to the next:
// there is no state that can get stuck, because the only values kept are the
// record's own, rewritten at every load.
//
// The identifier is read-only and, in add mode, only known once the record is
// written — the key generator is max+1, as in the original's `Genere_Clef`.
//
// **The window is reused, never rebuilt.** Asking for a record while this
// window is already on screen sends it the new parameters instead of
// destroying and recreating it — destroying and recreating under the same
// label crashed the application outright. The event carries this window's own
// label in its name: both windows listening to one name meant the parameters
// meant for the list also reached this form, which read them as "add a new
// record" and blanked itself, reserve variables included.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askYesNo, questionIsOnScreen } from "./dialog";
import { closeCurrentWindow } from "./window-frame";
import { BUDGET_LINE_OWNER, currentKind } from "./nomenclature";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

/// Which nomenclature this window is working on. Read once, from the address,
/// and never changed: a fiche does not become another nomenclature's fiche.
const KIND = currentKind();
/// Only the category carries a budget line, and it is the only reason this
/// fiche ever shows a second field.
const HAS_BUDGET_LINE = KIND === BUDGET_LINE_OWNER;

/// Parameters addressed to **this** window and to no other. Seven fiches share
/// this page: an event name that did not carry the window's label would reach
/// all of them.
const PARAMETERS_EVENT = `window-parameters:${KIND}-form`;
/// Order to empty itself: the window is being left behind and what it holds
/// has been abandoned.
const RESET_EVENT = `window-reset:${KIND}-form`;

interface Element {
  id: number;
  label: string;
  budget_line_id: number;
}

interface Item {
  id: number;
  label: string;
}

type Mode = "A" | "M" | "L";

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const idLabel = element<HTMLElement>("id-label");
const idField = element<HTMLInputElement>("id");
const labelField = element<HTMLInputElement>("label");
const labelLabel = element<HTMLElement>("label-label");
const budgetLineLabel = element<HTMLElement>("budget-line-label");
const budgetLineField = element<HTMLSelectElement>("budget-line");
const saveButton = element<HTMLButtonElement>("save");
const closeButton = element<HTMLButtonElement>("close");
const infoBar = element<HTMLElement>("info-bar");

// macOS rewrites what is typed into a text field on its own — autocorrection,
// capitals, smart quotes. A label is a proper noun of the user's household
// budget, not prose: the system has no business correcting it, and what he
// typed must be what is compared and what is stored. Turned off explicitly
// here rather than in the markup, so the reason travels with the code
// (Fabrice's lead, 25/07/2026).
labelField.spellcheck = false;
labelField.autocapitalize = "off";
labelField.setAttribute("autocorrect", "off");
labelField.setAttribute("autocomplete", "off");

// The budget line is the one field that comes and goes: hidden with its own
// label, so the grid does not keep an empty row where it used to be.
budgetLineLabel.hidden = !HAS_BUDGET_LINE;
budgetLineField.hidden = !HAS_BUDGET_LINE;

/// Which record, in which mode. Both change when the window is reused.
let mode: Mode = "A";
let recordId: number | null = null;

// --- The reserve ---------------------------------------------------------
// The editable part of an element, gathered in one structure so that it reads
// like the record it is (Fabrice's rule, 25/07/2026). One field of the window
// per member, and nothing else in it: the identifier is generated, never
// typed, so it is not part of what can be modified. The budget line stays at
// « Non précisé » for the six nomenclatures that do not have one, so it never
// makes them look modified.
interface ElementRecord {
  label: string;
  budgetLineId: number;
}

/// The empty record: what a fiche holds when it holds nothing.
const EMPTY_RECORD: ElementRecord = { label: "", budgetLineId: 0 };

/// The reserve: the record as it was read from the database.
let reserve: ElementRecord = { ...EMPTY_RECORD };

/// The same structure, read from the screen as it stands now.
function onScreen(): ElementRecord {
  return {
    label: labelField.value,
    budgetLineId: Number(budgetLineField.value),
  };
}

/// Fills the reserve. The only two moments it happens: a record is loaded, or
/// one has just been written — nowhere else.
function loadReserve(record: ElementRecord): void {
  reserve = { ...record };
}

/// Tells the controller which element this window is showing, and `null` when
/// it shows none. The list refuses to delete an element whose fiche is open
/// (author's ruling, 25/07/2026): it would otherwise be left on screen
/// showing a record that no longer exists.
function declareRecord(id: number | null): void {
  void invoke("set_form_record", { kind: KIND, id });
}

/// Puts a record on the screen, member by member.
function showRecord(record: ElementRecord): void {
  labelField.value = record.label;
  budgetLineField.value = String(record.budgetLineId);
}

/// Compares the fields with the members of the reserve, one by one.
function isModified(): boolean {
  const current = onScreen();
  if (current.label !== reserve.label) {
    return true;
  }
  if (current.budgetLineId !== reserve.budgetLineId) {
    return true;
  }
  return false;
}

/// What the window is saying, before the modification mark is added to it.
let message = "";

/// Shows where the window stands, and tells the controller — the list needs
/// the answer before its own door does anything.
function showState(): void {
  const modified = mode !== "L" && isModified();
  infoBar.textContent = modified ? `${message} ${t("ui-modified-suffix")}` : message;
  void invoke("set_form_dirty", { kind: KIND, dirty: modified });
}

function say(text: string, alert = false): void {
  message = text;
  infoBar.classList.toggle("info-bar--alert", alert);
  showState();
}

function setEditable(editable: boolean): void {
  labelField.disabled = !editable;
  budgetLineField.disabled = !editable;
  saveButton.disabled = !editable;
}

/// Reads the mode and **the key sent by the list**. The key arrives in the
/// address the first time the window is built, and in the event payload every
/// time it is reused.
function readParameters(query: string): void {
  const parameters = new URLSearchParams(query);
  mode = (parameters.get("mode") ?? "A") as Mode;
  recordId = parameters.has("id") ? Number(parameters.get("id")) : null;

  // The address is kept in step with the key in force. A webview can reload
  // on its own — the development server does it at every save — and it comes
  // back on its address: without this it would come back on the record that
  // was asked for first, whatever the user is actually working on.
  const kept = recordId === null ? `mode=${mode}` : `mode=${mode}&id=${recordId}`;
  history.replaceState(null, "", `?${kept}`);
}

/// The combo of the category fiche. The six other nomenclatures never ask for
/// it: there is nothing to fill, and no reason to make the round trip.
async function fillBudgetLines(selected: number): Promise<void> {
  if (!HAS_BUDGET_LINE) {
    return;
  }
  const lines = await invoke<Item[]>("list_budget_lines");
  budgetLineField.replaceChildren();
  for (const line of lines) {
    const option = document.createElement("option");
    option.value = String(line.id);
    option.textContent = line.label;
    budgetLineField.append(option);
  }
  budgetLineField.value = String(selected);
}

/// Loads the record, puts it in the fields, and **fills the reserve variables
/// from it** — never from whatever the fields happen to hold at that instant.
/// The fields are locked while this runs, so nothing typed meanwhile can be
/// taken for the record's own content.
async function applyParameters(): Promise<void> {
  setEditable(false);
  say(t("ui-loading"));

  try {
    const failure = await invoke<string | null>("startup_error");
    if (failure) {
      say(failure, true);
      return;
    }

    // The record this window is about to hold. In add mode it is the empty
    // one; otherwise it comes from the database.
    let loaded: ElementRecord = { ...EMPTY_RECORD };

    if (mode === "A") {
      // The identifier does not exist yet: the original leaves the field
      // empty until the record is written.
      await fillBudgetLines(0);
      idField.value = "";
      saveButton.title = t("ui-title-add");
    } else {
      if (recordId === null) {
        say(t("nomenclature-nothing-to-show"), true);
        return;
      }
      const record = await invoke<Element | null>("get_element", {
        kind: KIND,
        id: recordId,
      });
      if (!record) {
        say(t("nomenclature-gone"), true);
        return;
      }
      await fillBudgetLines(record.budget_line_id);
      idField.value = String(record.id);
      loaded = { label: record.label, budgetLineId: record.budget_line_id };
      saveButton.title = mode === "M" ? t("ui-title-modify") : t("ui-title-save");
    }

    // The order is the author's, and it is not negotiable: the record has
    // been read from the database by its key, the reserve is filled from what
    // was read, and only then is it put on the screen. The fields are never
    // the source of anything — they are the last step, never the first.
    loadReserve(loaded);
    showRecord(loaded);
    // Adding: no element exists yet, so none is shielded from deletion.
    declareRecord(mode === "A" ? null : recordId);

    say(
      mode === "A"
        ? t("nomenclature-fresh")
        : mode === "M"
          ? t("ui-editing")
          : t("ui-viewing"),
    );

    if (mode === "L") {
      // Consultation (`Maj_Controles`, CAS "L"): fields locked and the
      // confirm button gone — the exit door is all that is left.
      setEditable(false);
      saveButton.hidden = true;
    } else {
      saveButton.hidden = false;
      setEditable(true);
      labelField.focus();
      labelField.select();
    }
  } catch (error) {
    say(tError("ui-load-failed", error), true);
  }
}

async function save(): Promise<void> {
  if (mode === "L" || labelField.disabled) {
    return;
  }

  const label = labelField.value.trim();
  if (label === "") {
    say(t("ui-label-required"), true);
    labelField.focus();
    return;
  }

  const budgetLineId = Number(budgetLineField.value);

  try {
    // Two elements of one nomenclature must not share a name (author's
    // ruling, 25/07/2026). The refusal is asked for before anything is
    // written, and shown here — the same shape as the deletion question:
    // the window decides what to do with an answer, rather than being handed
    // a failure. Nothing is saved, nothing is closed, and what was typed
    // stays on screen so it can be corrected.
    //
    // A save that does not touch the label is not asked about: it cannot
    // create a name that was not there already. It matters for elements that
    // came in with a database from 1.x, where nothing enforced this — an
    // element that shares its name with another must stay editable, or its
    // budget line could never be corrected again. The rule stops a duplicate
    // being *created*; it does not punish someone for one already there.
    if (label !== reserve.label.trim()) {
      const duplicate = await invoke<string | null>("duplicate_name", {
        kind: KIND,
        id: mode === "A" ? null : recordId,
        label,
      });
      if (duplicate) {
        say(duplicate, true);
        labelField.focus();
        labelField.select();
        return;
      }
    }

    if (mode === "A") {
      const id = await invoke<number>("create_element", {
        kind: KIND,
        label,
        budgetLineId,
      });
      idField.value = String(id);
      say(t("nomenclature-created"));
    } else {
      const changed = await invoke<boolean>("update_element", {
        kind: KIND,
        id: recordId,
        label,
        budgetLineId,
      });
      if (!changed) {
        say(t("nomenclature-gone"), true);
        return;
      }
      say(t("nomenclature-updated"));
    }

    // Written: the reserve now holds what the database holds.
    loadReserve(onScreen());
    showState();
    declareRecord(null);
    await invoke("notify_elements_changed", { kind: KIND });
    closeCurrentWindow();
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

/// `Action_Annuler`. A second click while the question is up is not a second
/// answer — and that is settled by looking at the screen, not by remembering
/// anything: if a question is displayed, this click is ignored.
async function mayDiscardChanges(): Promise<boolean> {
  if (!isModified() || mode === "L") {
    return true;
  }
  if (questionIsOnScreen()) {
    return false;
  }
  return await askYesNo(t("ui-discard-question"), t("ui-yes"), t("ui-no"));
}

async function closeWindow(): Promise<void> {
  if (!(await mayDiscardChanges())) {
    return;
  }
  // The window is hidden, not destroyed, and comes back as it was left: it
  // must hold the stored record, not work the user has just given up on. The
  // reserve is what it is put back to.
  showRecord(reserve);
  showState();
  // Left: the element is no longer held open, and may be deleted again.
  declareRecord(null);
  closeCurrentWindow();
}

labelField.addEventListener("input", showState);
budgetLineField.addEventListener("change", showState);

saveButton.addEventListener("click", () => void save());
closeButton.addEventListener("click", () => void closeWindow());

// Enter confirms, Escape leaves — the two reflexes of the original windows.
window.addEventListener("keydown", (event) => {
  if (event.key === "Enter" && mode !== "L") {
    event.preventDefault();
    void save();
  } else if (event.key === "Escape") {
    event.preventDefault();
    void closeWindow();
  }
});

/// Left behind with work the user agreed to abandon: the window keeps
/// nothing. Reserve and fields are emptied together, and the key forgotten —
/// so there is nothing left to come back to life the next time it is opened,
/// and no question to ask about it (Fabrice, 25/07/2026).
void listen(RESET_EVENT, () => {
  recordId = null;
  loadReserve(EMPTY_RECORD);
  showRecord(EMPTY_RECORD);
  idField.value = "";
  declareRecord(null);
  say("");
});

// Asked for again while already on screen: reload rather than be rebuilt.
void listen<string>(PARAMETERS_EVENT, async (event) => {
  if (!(await mayDiscardChanges())) {
    return;
  }
  readParameters(event.payload);
  await applyParameters();
});

/// Pose les étiquettes de la fiche, à l'ouverture et à chaque changement de
/// langue.
///
/// **Elle ne relit pas l'enregistrement.** Une fiche peut porter une saisie en
/// cours ; la relire l'effacerait, et changer de langue n'est pas abandonner
/// son travail. La réserve n'est donc pas touchée non plus : rhabiller une
/// fenêtre ne doit pas la déclarer modifiée.
function dress(): void {
  idLabel.textContent = t("nomenclature-identifier");
  labelLabel.textContent = t("ui-field-label");
  budgetLineLabel.textContent = t("ui-field-budget-line");
  closeButton.title = t("ui-title-close");
}

// Its words before anything else: the window must never show a sentence of
// its own, not even for the instant before the dictionary arrives.
void (async () => {
  await loadTexts(KIND);
  dress();
  readParameters(window.location.search);
  await applyParameters();
  // **Sans titre à reposer.** `window-form-title` choisit sa phrase sur
  // `$kind`, et `retitle` ne sait porter qu'un argument, `account` : le noyau
  // rendrait une phrase vide et la fenêtre garderait son étiquette. Autant ne
  // rien demander plutôt que de faire croire que le titre suit la langue.
  // Le titre de cette page dépend de la nomenclature affichée : la phrase
  // sélectionne sur « kind », et c'est sous ce nom que la clef part.
  onLanguageChanged(dress, { key: "window-form-title", argument: KIND, argumentName: "kind" });
})();
