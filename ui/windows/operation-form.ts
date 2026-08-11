// F03 — « Opération Compte : <compte> ».
//
// The fiche of one operation, built on the Categories model Fabrice validated
// on 25/07/2026, because that is what he asked for: "Les categories doivent
// etre ton exemple a suivre, ton modele de code".
//
// **How a modification is detected, and the only way it is.** A reserve: a
// structure holding the record exactly as the database gave it, one member per
// editable field. It is filled at one moment and one moment only — after the
// record has been read by the key the list handed over, and before anything is
// shown. On the way out, each field is compared with its own member, at that
// instant. There is no flag anywhere in this file: a flag is derived
// information, it goes stale the moment the thing it describes moves, and it
// has already cost this project a day. The reserve is a copy of the truth,
// rewritten at every load, and it cannot go stale.
//
// Its own rules, from the original and from the author:
//
//   * **the sign is shown**: a debit reads « -70,00 » in the field and Débit
//     in the combo, and the two are kept saying the same thing — what is
//     typed is what is seen, and what is seen is what is written;
//   * every amount goes through the shared money field, so a letter or a
//     second comma cannot be typed in the first place, and the core reads it
//     again before writing;
//   * **the date is required**: the list reads a period, and an operation
//     with no date falls outside every period there is;
//   * a **sub-operation is not modified here**: its date, its status and its
//     mode belong to its mother, and it has its own fiche (F04, §5.3);
//   * **the cheque zone is live** (phase 9): Info opens the cheque's own fiche,
//     Associer goes and picks one — the chequebook first, then the cheque, his
//     two lists in their « SEL » mode — and Supprimer **detaches**, deleting
//     nothing at all;
//   * the window is built once and never destroyed: leaving hides it, coming
//     back shows it, and being left behind empties it, reserve included.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askForText, askYesNo, questionIsOnScreen } from "./dialog";
import { closeCurrentWindow } from "./window-frame";
import { asMoneyField, SIGN_CHANGED } from "./money-field";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

const PARAMETERS_EVENT = "window-parameters:operation-form";
const RESET_EVENT = "window-reset:operation-form";

interface Item {
  id: number;
  label: string;
}

interface Combos {
  category: Item[];
  assignment: Item[];
  payment_mode: Item[];
  payee: Item[];
  project: Item[];
}

interface OperationDto extends OperationRecord {
  id: number;
  account_id: number;
  check_number: string;
  attachments: string;
  parent_id: number;
  child_count: number;
}

/// « A » ajoute, « M » modifie, « L » consulte — le vocabulaire de l'original
/// — et « D » duplique : la fiche s'ouvre pré-remplie des valeurs d'une autre
/// opération, mais **elle n'est pas cette opération**. Elle redevient un « A »
/// dès que les valeurs sont à l'écran : rien n'existe tant que l'utilisateur
/// n'a pas enregistré (décision de Fabrice, 26/07/2026).
type Mode = "A" | "M" | "L" | "D";

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

// --- The reserve ---------------------------------------------------------
// The editable part of an operation, in one structure so that it reads like
// the record it is. One member per field of the window, and nothing else in
// it: the key is generated, the balance is computed, the cheque belongs to
// another window — none of the three can be modified here.
interface OperationRecord {
  label: string;
  payment_reference: string;
  date: string;
  clearing_date: string;
  /// "D" or "C" — what the Type Opération combo is set on.
  direction: string;
  /// The amount **with its sign**, as the money field writes it: a debit is
  /// « -70,00 ». The sign and the combo always say the same thing.
  amount: string;
  status_id: number;
  category_id: number;
  assignment_id: number;
  payment_mode_id: number;
  payee_id: number;
  project_id: number;
  comment: string;
}

const EMPTY_RECORD: OperationRecord = {
  label: "",
  payment_reference: "",
  date: "",
  clearing_date: "",
  direction: "D",
  amount: "0,00",
  status_id: 1,
  category_id: 0,
  assignment_id: 0,
  payment_mode_id: 0,
  payee_id: 0,
  project_id: 0,
  comment: "",
};

/// Every field of the window and the member it holds, written once so that
/// reading the screen, filling it and comparing it are the same list. A field
/// added to the fiche and forgotten in the comparison is exactly how a
/// modification stops being detected.
const TEXT_FIELDS: [keyof OperationRecord, string][] = [
  ["label", "label"],
  ["payment_reference", "reference"],
  ["date", "date"],
  ["clearing_date", "clearing-date"],
  ["direction", "direction"],
  ["amount", "amount"],
  ["comment", "comment"],
];

const NUMBER_FIELDS: [keyof OperationRecord, string][] = [
  ["status_id", "status"],
  ["category_id", "category"],
  ["assignment_id", "assignment"],
  ["payment_mode_id", "payment-mode"],
  ["payee_id", "payee"],
  ["project_id", "project"],
];

/// The five nomenclature combos, and the list each is filled from.
const NOMENCLATURE_COMBOS: [string, keyof Combos, keyof OperationRecord][] = [
  ["category", "category", "category_id"],
  ["assignment", "assignment", "assignment_id"],
  ["payment-mode", "payment_mode", "payment_mode_id"],
  ["payee", "payee", "payee_id"],
  ["project", "project", "project_id"],
];

const infoBar = element<HTMLElement>("info-bar");
const infoMessage = element<HTMLElement>("info-message");
const attachmentsLine = element<HTMLElement>("attachments");
const saveButton = element<HTMLButtonElement>("save");
const closeButton = element<HTMLButtonElement>("close");
const commentSection = element<HTMLElement>("comment-section");
const checkField = element<HTMLInputElement>("check");

let mode: Mode = "A";
let recordId: number | null = null;
let accountId = 0;
/// The reserve: the record as it was read from the database.
let reserve: OperationRecord = { ...EMPTY_RECORD };
/// What the status line says, before the modification mark is added to it.
let message = "";
/// The mother's key of the record on screen, and `0` when it has none. Read
/// from the record like everything else here, at every load — a sub-operation
/// is shown but not written: its date, its status and its mode belong to its
/// mother, and it has a fiche of its own (F04).
let parentId = 0;

function isASubOperation(): boolean {
  return parentId !== 0;
}

/// Shows the buttons that need a record that already exists, and hides them
/// when there is none.
///
/// **The trap of the new operation** (Fabrice, 26/07/2026). A sub-operation
/// created from a fiche that has not been saved yet would belong to nothing:
/// validate the child, then give up on the parent, and the ventilation stays
/// behind attached to a key that was never written — an orphan nobody sees in
/// any list and that no total accounts for. Rather than try to catch that
/// afterwards, the button is simply not there until the operation exists.
///
/// So it shows **in modification only**: not while creating, not in
/// consultation, and not on a sub-operation either — a ventilation is two
/// levels deep and has no grandchildren. The attachments (F28) will join this
/// rule when they come: a file copied and registered against an operation
/// that is never written is the same orphan, with a file behind it.
function showWhatTheRecordAllows(): void {
  const written = mode === "M" && recordId !== null && !isASubOperation();
  element<HTMLButtonElement>("sub").hidden = !written;

  // **Le menu Options suit la même règle**, et pour la même raison : un FITID
  // se pose sur une écriture qui existe. Il est grisé plutôt que caché — une
  // entrée de menu qui va et vient ferait douter de ce que la fenêtre sait
  // faire. La barre n'existe pas encore au tout premier habillage.
  const options = document.getElementById("options-entry");
  if (options instanceof HTMLButtonElement) {
    options.disabled = !written;
  }
}

function field(id: string): HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement {
  return element(id);
}

/// The record the screen holds right now.
function onScreen(): OperationRecord {
  const record = { ...EMPTY_RECORD };
  for (const [member, id] of TEXT_FIELDS) {
    (record as Record<string, unknown>)[member] = field(id).value;
  }
  for (const [member, id] of NUMBER_FIELDS) {
    (record as Record<string, unknown>)[member] = Number(field(id).value);
  }
  return record;
}

/// Puts a record on the screen, member by member.
function showRecord(record: OperationRecord): void {
  for (const [member, id] of TEXT_FIELDS) {
    field(id).value = String(record[member] ?? "");
  }
  for (const [member, id] of NUMBER_FIELDS) {
    field(id).value = String(record[member] ?? 0);
  }
  // The post-it opens itself when there is something written on it.
  commentSection.hidden = record.comment.trim() === "";
}

/// Fills the reserve. The only two moments it happens: a record has just been
/// read, or one has just been written — nowhere else.
function loadReserve(record: OperationRecord): void {
  reserve = { ...record };
}

/// Compares the fields with the members of the reserve, one by one.
function isModified(): boolean {
  const current = onScreen();
  for (const key of Object.keys(EMPTY_RECORD) as (keyof OperationRecord)[]) {
    if (current[key] !== reserve[key]) {
      return true;
    }
  }
  return false;
}

/// Tells the controller which operation this window is showing, and `null`
/// when it shows none: the list refuses to delete an operation whose fiche is
/// open (author's ruling, 25/07/2026).
function declareRecord(id: number | null): void {
  void invoke("set_operation_form_record", { id });
}

function showState(): void {
  const modified = mode !== "L" && !isASubOperation() && isModified();
  infoMessage.textContent = modified ? `${message} ${t("ui-modified-suffix")}` : message;
  void invoke("set_operation_form_dirty", { dirty: modified });
}

function say(text: string, alert = false): void {
  message = text;
  infoBar.classList.toggle("info-bar--alert", alert);
  showState();
}

function setEditable(editable: boolean): void {
  for (const [, id] of [...TEXT_FIELDS, ...NUMBER_FIELDS]) {
    (field(id) as HTMLInputElement).disabled = !editable;
  }
  saveButton.disabled = !editable;
}

function readParameters(query: string): void {
  const parameters = new URLSearchParams(query);
  mode = (parameters.get("mode") ?? "A") as Mode;
  accountId = Number(parameters.get("account") ?? 0);
  recordId = parameters.has("id") ? Number(parameters.get("id")) : null;

  // The address is kept in step with what is in force: a webview reloads on
  // its own, and it comes back on its address.
  const kept =
    recordId === null
      ? `mode=${mode}&account=${accountId}`
      : `mode=${mode}&account=${accountId}&id=${recordId}`;
  history.replaceState(null, "", `?${kept}`);
}

function fillCombo(id: string, items: Item[], selected: number): void {
  const combo = element<HTMLSelectElement>(id);
  combo.replaceChildren();
  for (const item of items) {
    const option = document.createElement("option");
    option.value = String(item.id);
    option.textContent = item.label;
    combo.append(option);
  }
  combo.value = String(selected);
}

/// Today, as a date field holds it. A new operation is dated today until the
/// user says otherwise: it is what he is doing nine times out of ten, and an
/// empty date is refused at the save.
function today(): string {
  const now = new Date();
  return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-${String(
    now.getDate(),
  ).padStart(2, "0")}`;
}

/// The two closed lists — Débit/Crédit and the three statuses — and the five
/// nomenclatures. Read once, when the window loads, and refilled at each
/// record so the values selected are the record's own.
let combos: Combos = {
  category: [],
  assignment: [],
  payment_mode: [],
  payee: [],
  project: [],
};
let statuses: Item[] = [];

/// Reads the record **by the key the list sent**, fills the reserve from what
/// was read, and only then puts it on the screen. The fields are never the
/// source of anything — they are the last step, never the first (author's
/// rule, 25/07/2026).
async function applyParameters(): Promise<void> {
  setEditable(false);
  parentId = 0;
  // Hidden until the record is known: nothing that needs an operation may be
  // offered while there is not yet one on screen.
  element<HTMLButtonElement>("sub").hidden = true;
  // Rien n'est encore lu : la réserve et les champs partent d'accord. Sans
  // cela une fiche qui n'a pas pu charger se déclare « modifiée » alors que
  // personne n'a rien tapé — les champs sont vides et la réserve, elle, porte
  // déjà le montant à zéro.
  loadReserve(EMPTY_RECORD);
  showRecord(EMPTY_RECORD);
  say(t("ui-loading"));

  try {
    const failure = await invoke<string | null>("startup_error");
    if (failure) {
      say(failure, true);
      return;
    }

    let loaded: OperationRecord = { ...EMPTY_RECORD };
    let line = t("operation-fresh");
    let attachments = await invoke<string>("operation_attachments_text", { count: 0 });
    checkField.value = "/";

    if (mode === "A") {
      loaded.date = today();
      loaded.clearing_date = today();
      loaded.status_id = statuses[0]?.id ?? 1;
      saveButton.title = t("ui-title-add");
    } else if (mode === "D") {
      // Une copie : on lit l'opération choisie, on garde ses valeurs, et on
      // oublie sa clef. La date est celle de l'originale — c'est souvent ce
      // qu'on duplique, et elle se corrige avant d'enregistrer.
      if (recordId === null) {
        say(t("operation-nothing-to-show"), true);
        return;
      }
      const source = await invoke<OperationDto | null>("get_operation", { id: recordId });
      if (!source) {
        say(t("operation-gone"), true);
        return;
      }
      const {
        id: _id,
        account_id: account,
        check_number: _check,
        attachments: _attached,
        parent_id: _parent,
        child_count: _children,
        ...record
      } = source;
      loaded = record;
      accountId = account;
      // La copie n'est pas l'enregistrement dont elle est la copie : ni sa
      // clef, ni son chèque, ni sa ventilation ne la suivent.
      recordId = null;
      mode = "A";
      line = t("operation-copy");
      saveButton.title = t("ui-title-add");
    } else {
      if (recordId === null) {
        say(t("operation-nothing-to-show"), true);
        return;
      }
      const operation = await invoke<OperationDto | null>("get_operation", { id: recordId });
      if (!operation) {
        say(t("operation-gone"), true);
        return;
      }
      const {
        id: _id,
        account_id: account,
        check_number: check,
        attachments: attached,
        parent_id: parent,
        child_count: _children,
        ...record
      } = operation;
      loaded = record;
      accountId = account;
      attachments = attached;
      // Le champ montre le numéro, comme chez lui — « / » quand il n'y en a
      // pas. Et l'on relit l'identifiant du chèque tout de suite après : c'est
      // lui, et non le numéro affiché, qui ouvre la fiche du chèque.
      checkField.value = check === "" ? "/" : check;
      void refreshCheque();
      // A sub-operation is shown, and not written: its date, its status and
      // its mode come from its mother, and changing them here would put the
      // ventilation out of step with what it ventilates.
      parentId = parent;
      line = isASubOperation() ? t("operation-is-a-sub") : t("ui-editing");
      saveButton.title = mode === "M" ? t("ui-title-modify") : t("ui-title-save");
    }

    // The combos are refilled before the record is shown: an option that is
    // not in the list cannot be selected, and the field would fall back to
    // the first one — a category chosen behind the user's back.
    fillCombo("status", statuses, loaded.status_id);
    for (const [id, list, member] of NOMENCLATURE_COMBOS) {
      fillCombo(id, combos[list], loaded[member] as number);
    }

    loadReserve(loaded);
    showRecord(loaded);
    declareRecord(mode === "A" ? null : recordId);
    say(line, isASubOperation());
    attachmentsLine.textContent = attachments;
    showWhatTheRecordAllows();

    if (mode === "L" || isASubOperation()) {
      setEditable(false);
      saveButton.hidden = true;
    } else {
      saveButton.hidden = false;
      setEditable(true);
      const label = element<HTMLInputElement>("label");
      label.focus();
      // The original opens with the label selected, ready to be typed over.
      label.select();
    }
  } catch (error) {
    say(tError("ui-load-failed", error), true);
  }
}

async function save(): Promise<void> {
  if (mode === "L" || isASubOperation() || saveButton.disabled) {
    return;
  }
  const operation = onScreen();

  try {
    // Everything that could stop this being written, asked for before
    // anything is: an empty label, an unreadable amount, a missing date. A
    // refusal is the window's to show, never a failure thrown at it.
    const refusal = await invoke<string | null>("operation_refusal", {
      label: operation.label,
      amount: operation.amount,
      date: operation.date,
      clearingDate: operation.clearing_date,
    });
    if (refusal) {
      say(refusal, true);
      element<HTMLInputElement>("label").focus();
      return;
    }

    if (mode === "A") {
      recordId = await invoke<number>("create_operation", { accountId, operation });
      mode = "M";
      // The operation exists now: what needed it may be offered.
      showWhatTheRecordAllows();
      say(t("operation-created"));
    } else {
      const changed = await invoke<boolean>("update_operation", { id: recordId, operation });
      if (!changed) {
        say(t("operation-gone"), true);
        return;
      }
      say(t("operation-updated"));
    }

    // Written: the reserve now holds what the database holds.
    loadReserve(onScreen());
    showState();
    declareRecord(null);
    await invoke("notify_operations_changed");
    closeCurrentWindow();
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

/// A second click while the question is up is not a second answer, and that
/// is settled by looking at the screen rather than by remembering anything.
async function mayDiscardChanges(): Promise<boolean> {
  if (!isModified() || mode === "L" || isASubOperation()) {
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
  // Hidden, not destroyed: it must come back holding the stored record, not
  // work the user has just given up on.
  showRecord(reserve);
  showState();
  declareRecord(null);
  closeCurrentWindow();
}

// --- The « Montant de l'opération » zone ---------------------------------
//
// **Two controls, one truth** (Fabrice, 26/07/2026). The zone holds a Type
// Opération combo and an amount, and they must never say different things: if
// the combo says Crédit while « -70 » sits in the field, one of the two is
// lying, and whichever the program believes, the other is what the user
// looked at. That is a bank balance made false by a minus sign nobody
// reconciled.
//
// So they are kept in step, both ways, and **the sign is shown**: a debit
// reads « -70,00 » in the field and Débit in the combo. Someone who types a
// negative number sees it stay negative — his own figure, not a corrected
// one.
//
//   * typing a minus is a way of saying « débit »: the combo follows at once;
//   * choosing in the combo re-signs the field: Débit puts the minus there,
//     Crédit takes it away;
//   * leaving the field writes it out with the sign the combo holds, so a
//     debit typed « 70 » is shown as « -70,00 » before it is ever saved.
//
// What is written is then a single interpretation, and the core alone makes
// it (`sub_operations::Direction::apply`, which the fiche sous-opération of
// §5.3 will use too): the **absolute value** of the amount, multiplied by −1
// for a debit and by 1 for a credit.

const amountField = element<HTMLInputElement>("amount");
const directionField = element<HTMLSelectElement>("direction");

/// One of the two sign keys of the money field was used, so the combo follows
/// what the field now shows: a minus means Débit, no minus means Crédit.
/// Driven by the key itself and not by the text, so it works **both ways** —
/// a second `-` makes the number positive again and the type goes back to
/// Crédit, and `+` says Crédit outright. Nothing is remembered: the field is
/// read as it stands at that instant.
function theTypeFollowsTheAmount(): void {
  directionField.value = amountField.value.trimStart().startsWith("-") ? "D" : "C";
}

/// And the other way round: the field carries the sign the combo holds. Zero
/// is never negative — « -0,00 » is not a debit, it is nothing at all.
function theAmountFollowsTheType(): void {
  const body = amountField.value.replace("-", "").trim();
  const nothing = body === "" || body.replace(/\D/g, "").replace(/0/g, "") === "";
  const wanted = directionField.value === "D" && !nothing ? `-${body}` : body;
  if (wanted !== amountField.value) {
    amountField.value = wanted;
  }
}

/// Leaving the field settles the two controls, whichever way the sign got
/// there. **A sign written in the field wins**: it is explicit, and it may
/// have arrived by a route the switch never saw — a pasted « -70 », a
/// dictated amount. Otherwise it is the combo that signs the field, so a
/// debit typed « 70 » leaves as « -70,00 » (Fabrice's rule of 26/07/2026 :
/// « si je choisis Débit avec un montant de 70 euros, tu dois enregistrer
/// -70 »).
function settleTheAmountAndItsType(): void {
  if (amountField.value.trimStart().startsWith("-")) {
    directionField.value = "D";
    return;
  }
  theAmountFollowsTheType();
}

// Registered before the general listeners below, so the two controls already
// agree when the reserve is consulted: what is compared must be what is on
// screen, never an intermediate state.
amountField.addEventListener(SIGN_CHANGED, theTypeFollowsTheAmount);
directionField.addEventListener("change", theAmountFollowsTheType);

for (const [, id] of TEXT_FIELDS) {
  field(id).addEventListener("input", showState);
}
for (const [, id] of NUMBER_FIELDS) {
  field(id).addEventListener("change", showState);
}
directionField.addEventListener("change", showState);

saveButton.addEventListener("click", () => void save());
closeButton.addEventListener("click", () => void closeWindow());

// The post-it: it opens the comment and puts the cursor in it. It holds no
// state of its own — what is on screen is read from the document.
element<HTMLButtonElement>("comment-button").addEventListener("click", () => {
  commentSection.hidden = !commentSection.hidden;
  if (!commentSection.hidden) {
    element<HTMLTextAreaElement>("comment").focus();
  }
});

/// `Base_createinside`: ventilate **this** operation, without going back
/// through the list. The button is only there once the operation exists (see
/// `showWhatTheRecordAllows`), so there is nothing to guard against here: it
/// hangs the ventilation off the record this fiche was opened on.
///
/// It works on the operation **as it is stored**, which is the only thing a
/// ventilation can hang off. If the fiche holds an amount that has not been
/// saved, the Complément is worked out from the stored one — and put right
/// the moment the fiche is saved, since writing an operation replays the
/// whole ventilation chain (`sub_operations::after_change`).
element<HTMLButtonElement>("sub").addEventListener("click", () => {
  if (recordId === null) {
    return;
  }
  void invoke("open_sub_operation_form", {
    mode: "A",
    parentId: recordId,
    id: null,
  }).catch((error) => say(tError("ui-open-failed", error), true));
});

// Les pièces jointes (F28) attendent encore leur phase : le bouton le dit
// plutôt que de ne rien faire.
/// Le trombone ouvre les pièces jointes de l'opération ouverte.
///
/// **Il faut que l'opération existe** : une pièce jointe se rattache à une
/// clef, et une fiche en saisie n'en a pas encore. Le bouton reste éteint tant
/// qu'elle n'est pas enregistrée, ce que `declareRecord` règle.
element<HTMLButtonElement>("attachment").addEventListener("click", () => {
  void (async () => {
    if (recordId === null) {
      say(t("attachment-save-first"), true);
      return;
    }
    try {
      await invoke("open_attachments_window", { operationId: recordId });
    } catch (error) {
      say(tError("ui-open-failed", error), true);
    }
  })();
});

// --- Le bouton « Modèle » (phase 10) -------------------------------------
//
// **Un clic, la liste.** Le document 04 prête deux gestes à cet icône, mais
// Fabrice a tranché : pas de question intermédiaire. Enregistrer une opération
// comme modèle attend donc l'endroit qu'il choisira.
//
// **Appliquer écrase l'écran et n'écrit rien** (règle de Fabrice, 29/07/2026) :
// les valeurs du modèle remplacent celles de la fiche, la réserve n'est pas
// touchée, donc la fiche se sait modifiée et c'est sa validation qui écrira.

/// **Le bouton ouvre la liste, un point c'est tout.** Aucune question : on
/// clique sur Modèle justement parce qu'on n'a pas de temps à perdre (Fabrice,
/// 29/07/2026). J'y avais mis une question à trois issues qu'il n'avait pas
/// demandée — elle est partie.
element<HTMLButtonElement>("template").addEventListener("click", () => {
  void invoke("open_operation_templates", { selecting: true }).catch((error) =>
    say(tError("ui-open-failed", error), true),
  );
});

/// Le modèle choisi arrive. **Il écrase**, il ne complète pas : un champ déjà
/// rempli est remplacé, sinon appliquer deux modèles à la suite donnerait un
/// mélange que personne n'a demandé.
///
/// La réserve n'est pas touchée — la fiche se retrouve donc modifiée, comme si
/// l'on avait tapé ces valeurs soi-même, et sa porte posera sa question.
void listen<{
  label: string;
  amount: number;
  signed_text: string;
  payment_mode_id: number;
  category_id: number;
  assignment_id: number;
  status_id: number;
  payee_id: number;
  project_id: number;
}>("template-chosen:operation-form", (event) => {
  const template = event.payload;
  element<HTMLInputElement>("label").value = template.label;
  // **Un modèle à zéro ne touche pas au montant** (demande de Fabrice,
  // 29/07/2026) : zéro n'est pas un montant, c'est l'absence de montant dans le
  // modèle — l'écraser effacerait ce que l'on venait de taper. Le sens reste
  // avec lui : sans montant, il n'y a rien qui dise débit ou crédit.
  //
  // Sinon, la fiche montre le montant **avec son signe**, et le combo dit la
  // même chose que lui.
  if (template.amount !== 0) {
    element<HTMLInputElement>("amount").value = template.signed_text;
    element<HTMLSelectElement>("direction").value = template.amount < 0 ? "D" : "C";
  }
  for (const [id, value] of [
    ["status", template.status_id],
    ["category", template.category_id],
    ["assignment", template.assignment_id],
    ["payment-mode", template.payment_mode_id],
    ["payee", template.payee_id],
    ["project", template.project_id],
  ] as const) {
    element<HTMLSelectElement>(id).value = String(value);
  }
  say(t("operation-template-applied"));
});

// --- Le bandeau « Chèque en relation avec l'opération » (phase 9) ---------
//
// Trois boutons, et le champ qui dit « / » quand il n'y a rien. Le chèque
// appartient à l'opération enregistrée, pas au brouillon : on ne peut pas en
// accrocher un à une fiche qui n'existe pas encore.

/// Le chèque que porte l'opération à l'instant : son identifiant, et son
/// écriture « 07328/9506001 ». Relu après chaque geste, jamais deviné.
let chequeId = 0;

async function refreshCheque(): Promise<void> {
  if (recordId === null) {
    chequeId = 0;
    checkField.value = "/";
    return;
  }
  try {
    const carried = await invoke<{ cheque_id: number; text: string }>("operation_cheque", {
      operationId: recordId,
    });
    chequeId = carried.cheque_id;
    checkField.value = carried.text;
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// Un chèque s'accroche à une opération qui existe : sur une fiche en ajout,
/// il n'y a pas encore de quoi l'accrocher.
/// Le menu **Options** et ses deux entrées : éditer l'identifiant FITID, le
/// supprimer.
///
/// **Ce qu'est un FITID, et pourquoi il a son menu à lui.** C'est
/// l'identifiant que la banque attache à une écriture dans un fichier OFX.
/// Radinus s'en sert pour une chose : reconnaître, au prochain import, une
/// opération déjà intégrée. Il ne se lit pas, il ne s'additionne pas, il ne
/// paraît nulle part sur la fiche — il ne mérite donc pas un champ de plus au
/// milieu de ceux qu'on remplit tous les jours, mais il faut pouvoir y
/// toucher quand une banque s'est trompée, ou n'en fournit pas.
///
/// **Une écriture immédiate, hors du bouton Enregistrer.** Comme le
/// rattachement d'un chèque : ce qui se fait par une question et non par un
/// champ s'écrit tout de suite, sinon la fiche porterait une modification que
/// rien à l'écran ne montre.
function optionsMenu(entry: HTMLElement): HTMLElement {
  const holder = document.createElement("div");
  holder.className = "window-menu__holder";
  const choices = document.createElement("div");
  choices.className = "window-menu__choices";
  choices.dataset.menu = "options";
  choices.hidden = true;

  // Les deux intitulés sont demandés **en toutes lettres**, et non par une
  // clef rangée dans un tableau : le croisement
  // `toute_clef_qu_une_fenetre_demande_est_une_clef_que_le_dictionnaire_sert`
  // ne reconnaît l'appel que si la clef est écrite entre guillemets à
  // l'intérieur des parenthèses. Une clef qu'il ne voit pas est une clef qu'il
  // ne protège pas.
  //
  // **Et le commentaire lui-même compte.** La première version de ces lignes
  // montrait l'appel en exemple, guillemets compris ; le croisement l'a lu
  // comme une vraie demande et a réclamé une clef nommée « … ». Il ne lit pas
  // du TypeScript, il lit du texte — un exemple dans un commentaire lui est
  // indiscernable d'un appel. On décrit donc la forme, on ne l'écrit pas.
  for (const [label, run] of [
    [t("operation-fitid-edit"), editTheFitid],
    [t("operation-fitid-delete"), removeTheFitid],
  ] as const) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "window-menu__choice window-menu__choice--plain";
    button.textContent = label;
    button.addEventListener("click", () => {
      choices.hidden = true;
      void run();
    });
    choices.append(button);
  }

  entry.addEventListener("click", (event) => {
    event.stopPropagation();
    choices.hidden = !choices.hidden;
  });
  document.addEventListener("click", () => {
    choices.hidden = true;
  });

  holder.append(entry, choices);
  return holder;
}

/// Montre l'identifiant dans une boîte, et écrit ce qu'on y met.
///
/// **Le champ part de ce qui est en base, et il est vide quand il n'y a
/// rien** — c'est le cas d'une opération saisie à la main, et on peut alors
/// lui en donner un (règle de Fabrice, 04/08/2026). Renoncer, ou tout
/// effacer, ne change rien : effacer se demande à l'autre entrée, qui pose sa
/// question avant.
async function editTheFitid(): Promise<void> {
  if (!requireSavedOperation()) {
    return;
  }
  try {
    const current = await invoke<string>("operation_fitid", { id: recordId });
    const written = await askForText(
      t("operation-fitid-question"),
      current,
      t("ui-ok"),
      t("ui-cancel"),
    );
    if (written === null || written === current) {
      return;
    }
    await invoke("set_operation_fitid", { id: recordId, value: written });
    say(t("operation-fitid-written"));
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

/// Efface l'identifiant, après confirmation.
///
/// Supprimer un FITID n'est pas rien : c'est le seul lien entre une ligne de
/// Radinus et la même ligne chez la banque, et sans lui le prochain import
/// réintégrera l'opération au lieu de la reconnaître. La question le mérite.
async function removeTheFitid(): Promise<void> {
  if (!requireSavedOperation()) {
    return;
  }
  try {
    if (!(await askYesNo(t("operation-fitid-delete-question"), t("ui-yes"), t("ui-no")))) {
      say(t("ui-deletion-abandoned"));
      return;
    }
    // La chaîne vide EST la suppression : c'est ainsi que « pas de FITID »
    // s'écrit partout ailleurs dans la base.
    await invoke("set_operation_fitid", { id: recordId, value: "" });
    say(t("operation-fitid-removed"));
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

function requireSavedOperation(): boolean {
  if (recordId === null) {
    say(t("operation-check-save-first"), true);
    return false;
  }
  return true;
}

element<HTMLButtonElement>("check-info").addEventListener("click", () => {
  if (chequeId === 0) {
    say(t("operation-check-none"));
    return;
  }
  void invoke("open_cheque_form", { id: chequeId }).catch((error) =>
    say(tError("ui-open-failed", error), true),
  );
});

// Associer : les deux temps de sa pêche au chèque — le carnet, puis le chèque.
// Ce sont ses deux listes dans leur mode « choisir », qu'il avait écrit et que
// rien n'appelait encore.
element<HTMLButtonElement>("check-link").addEventListener("click", () => {
  if (!requireSavedOperation()) {
    return;
  }
  void invoke("choose_cheque_for_operation", { operationId: recordId }).catch((error) =>
    say(tError("ui-open-failed", error), true),
  );
});

// Supprimer : **détache**, ne supprime rien. L'opération reste, le chèque reste.
element<HTMLButtonElement>("check-unlink").addEventListener("click", () => {
  if (!requireSavedOperation()) {
    return;
  }
  if (chequeId === 0) {
    say(t("operation-check-none"));
    return;
  }
  void (async () => {
    try {
      await invoke("dissociate_cheque", { operationId: recordId });
      await invoke("notify_cheques_changed");
      await refreshCheque();
      say(t("cheque-operations-dissociated"));
    } catch (error) {
      say(tError("ui-save-failed", error), true);
    }
  })();
});

// Le chèque a bougé ailleurs — dans la fenêtre de choix, ou dans celle de
// l'association. La fiche relit le sien plutôt que de deviner.
void listen("data-changed:operation-form", () => void refreshCheque());

window.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    event.preventDefault();
    void closeWindow();
  }
});

/// Left behind with work the user agreed to abandon: the window keeps
/// nothing — reserve and fields emptied together, and the key forgotten.
void listen(RESET_EVENT, () => {
  recordId = null;
  parentId = 0;
  showWhatTheRecordAllows();
  loadReserve(EMPTY_RECORD);
  showRecord(EMPTY_RECORD);
  checkField.value = "/";
  declareRecord(null);
  say("");
});

// Asked for again while already on screen: reloaded rather than rebuilt.
void listen<string>(PARAMETERS_EVENT, async (event) => {
  if (!(await mayDiscardChanges())) {
    return;
  }
  readParameters(event.payload);
  await applyParameters();
});

/// Pose les mots de la fiche, à l'ouverture et à chaque changement de langue.
///
/// **Elle ne relit pas l'opération.** Une fiche porte souvent une saisie en
/// cours — un libellé à moitié tapé, un montant que l'on vient de corriger —
/// et changer de langue n'est pas y renoncer. Rien ici ne touche non plus à la
/// réserve : rhabiller la fenêtre ne doit pas la déclarer modifiée.
function dress(): void {
  for (const [id, key] of [
    ["group-identification", "operation-group-identification"],
    ["group-amount", "operation-group-amount"],
    ["group-status", "operation-group-status"],
    ["group-classification", "operation-group-classification"],
    ["group-comment", "operation-group-comment"],
    ["group-check", "operation-group-check"],
    ["label-label", "operation-field-label"],
    ["reference-label", "operation-field-reference"],
    ["date-label", "operation-field-date"],
    ["direction-label", "operation-field-direction"],
    ["amount-label", "operation-field-amount"],
    ["status-label", "operation-field-status"],
    ["clearing-date-label", "operation-field-clearing-date"],
    ["category-label", "operation-field-category"],
    ["assignment-label", "operation-field-assignment"],
    ["payment-mode-label", "operation-field-payment-mode"],
    ["payee-label", "operation-field-payee"],
    ["project-label", "operation-field-project"],
    ["check-label", "operation-field-check"],
    ["check-info", "operation-check-info"],
    ["check-link", "operation-check-link"],
    ["check-unlink", "operation-check-unlink"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  for (const [id, key] of [
    ["comment-button", "operation-title-comment"],
    ["sub", "operation-title-sub"],
    ["template", "operation-title-template"],
    ["attachment", "operation-title-attachment"],
    ["save", "ui-title-save"],
    ["close", "ui-title-close"],
  ] as const) {
    element<HTMLElement>(id).title = t(key);
  }

  // La barre de menus de la fenêtre : **une seule entrée, Options**, qui porte
  // les deux gestes sur l'identifiant FITID.
  //
  // « Identification » y était et n'y est plus (Fabrice, 04/08/2026). Elle
  // venait de l'original, où elle nommait la page où l'on se trouve — mais
  // 1.9.3 en avait plusieurs, et la fiche de Radinus 2 n'en a qu'une : elle
  // nommait donc la seule page qu'il y ait, sous les yeux de quelqu'un qui la
  // regardait déjà. La clef reste au dictionnaire : **F04 s'en sert encore**.
  //
  // La barre est vidée avant : rhabillée, la fenêtre en écrirait une seconde à
  // côté de la première.
  const menu = element<HTMLElement>("window-menu");
  menu.replaceChildren();

  const options = document.createElement("button");
  options.type = "button";
  options.id = "options-entry";
  options.className = "window-menu__entry";
  options.textContent = t("operation-menu-options");
  menu.append(optionsMenu(options));

  // Le menu vient d'être refait : il ne sait pas encore ce que la fiche
  // contient. On le lui redit, sans quoi une fiche ouverte sur une opération
  // enregistrée verrait ses Options se griser en changeant de langue.
  showWhatTheRecordAllows();

  // Débit / Crédit: a closed list of two, worded by Fluent like everything
  // else. The sign of an amount is a choice, never something typed.
  //
  // Les deux mots changent avec la langue, le choix non : on le relève avant
  // de refaire la liste et on le repose. Une fiche qui passerait toute seule
  // de Crédit à Débit changerait le signe d'un montant sans que personne l'ait
  // demandé. À l'ouverture le champ est vide et part sur « D », comme avant.
  const chosen = directionField.value === "" ? "D" : directionField.value;
  directionField.replaceChildren();
  for (const [value, key] of [
    ["D", "operation-direction-debit"],
    ["C", "operation-direction-credit"],
  ] as const) {
    const option = document.createElement("option");
    option.value = value;
    option.textContent = t(key);
    directionField.append(option);
  }
  directionField.value = chosen;
}

// Its words before anything else: the window must never show a sentence of
// its own, not even for the instant before the dictionary arrives.
void (async () => {
  await loadTexts(null);
  dress();

  // The amount is money, and a money field refuses at the keyboard what
  // cannot be one. Turned on after the words: it formats with the separators
  // of the current language.
  asMoneyField(amountField);
  // And after it has written the amount out, the sign of the combo is put
  // back on it: a debit typed « 70 » leaves the field as « -70,00 ».
  // Registered after `asMoneyField` so it runs after its own formatting.
  amountField.addEventListener("blur", () => {
    settleTheAmountAndItsType();
    showState();
  });

  const failure = await invoke<string | null>("startup_error");
  if (!failure) {
    statuses = await invoke<Item[]>("list_operation_statuses");
    combos = await invoke<Combos>("list_operation_combos");
  }

  readParameters(window.location.search);
  await applyParameters();

  // **Sans titre à reposer.** « Opération Compte : CCP » nomme le compte, et
  // cette fiche n'en tient que la clef : elle n'a jamais eu son nom sous la
  // main. Le lui faire lire pour son seul titre serait une lecture de plus au
  // moment où la fenêtre se rhabille — la fiche est rhabillée, son étiquette
  // attend que quelqu'un lui donne le nom du compte.
  onLanguageChanged(dress);
})();

/// **Une nomenclature a changé pendant que cette fenêtre vivait.**
///
/// Bug remonté par un utilisateur le 10/08/2026 : « lorsque l'on rajoute une
/// nomenclature, il faut fermer le programme pour qu'on puisse avoir ce
/// nouveau libellé dans les opérations ». Une fenêtre de Radinus est bâtie une
/// fois et jamais détruite : elle lisait ses listes à sa construction et les
/// gardait jusqu'au prochain démarrage.
///
/// La liste est reposée sur place, **avec le choix en cours conservé** : on ne
/// refait pas l'écran d'une fiche que quelqu'un est en train de remplir.
void listen("nomenclatures-changed", async () => {
  combos = await invoke<Combos>("list_operation_combos");
  for (const [id, list] of NOMENCLATURE_COMBOS) {
    fillCombo(id, combos[list], Number(element<HTMLSelectElement>(id).value));
  }
});
