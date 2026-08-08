// F08 — « Fiche compte ».
//
// The same window as the nomenclature fiche, which Fabrice validated on
// 25/07/2026, with more fields: a reserve holding the record as it was read,
// compared field by field on the way out, the door as the only exit, the
// window built once and never destroyed, and nothing of a visit surviving it.
//
// Its own three things. The blue control line under the fields, which the
// core words and which says what the account was carried over with, what its
// operations did to it, and where it stands now. The IBAN, checked by its
// control digits before anything is written — a wrong IBAN copied into a
// transfer is a payment that leaves and does not arrive. And the three
// carried-over balances, which are typed here and nowhere else: everything
// the rest of Radinus shows is computed from them.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askForAmount, askForWord, askYesNo, questionIsOnScreen, tell } from "./dialog";
import { closeCurrentWindow } from "./window-frame";
import { asMoneyField } from "./money-field";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

const PARAMETERS_EVENT = "window-parameters:account-form";
const RESET_EVENT = "window-reset:account-form";

interface Item {
  id: number;
  label: string;
}

interface AccountDto extends AccountRecord {
  id: number;
  control_line: string;
}

type Mode = "A" | "M" | "L";

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

// --- The reserve ---------------------------------------------------------
// The editable part of an account, in one structure so that it reads like the
// record it is (Fabrice's rule, 25/07/2026). One member per field of the
// window, and nothing else in it.
interface AccountRecord {
  label: string;
  bank_id: number;
  account_type_id: number;
  branch_address: string;
  holder_name: string;
  holder_address: string;
  rib_bank_code: string;
  rib_branch_code: string;
  rib_account_number: string;
  rib_key: string;
  bic: string;
  iban: string;
  opening_date: string;
  closing_date: string;
  is_closed: boolean;
  opening_pointed: string;
  opening_committed: string;
  opening_planned: string;
}

const EMPTY_RECORD: AccountRecord = {
  label: "",
  bank_id: 0,
  account_type_id: 0,
  branch_address: "",
  holder_name: "",
  holder_address: "",
  rib_bank_code: "",
  rib_branch_code: "",
  rib_account_number: "",
  rib_key: "",
  bic: "",
  iban: "",
  opening_date: "",
  closing_date: "",
  is_closed: false,
  opening_pointed: "0,00",
  opening_committed: "0,00",
  opening_planned: "0,00",
};

/// Every field of the window, and the member of the record it holds. Written
/// once here so that reading the screen, filling it and comparing it are the
/// same list — a field added to the fiche and forgotten in the comparison is
/// exactly how a modification stops being detected.
const TEXT_FIELDS: [keyof AccountRecord, string][] = [
  ["label", "label"],
  ["branch_address", "branch-address"],
  ["holder_name", "holder-name"],
  ["holder_address", "holder-address"],
  ["rib_bank_code", "rib-bank"],
  ["rib_branch_code", "rib-branch"],
  ["rib_account_number", "rib-number"],
  ["rib_key", "rib-key"],
  ["bic", "bic"],
  ["iban", "iban"],
  ["opening_date", "opening-date"],
  ["closing_date", "closing-date"],
  ["opening_pointed", "opening-pointed"],
  ["opening_committed", "opening-committed"],
  ["opening_planned", "opening-planned"],
];

const NUMBER_FIELDS: [keyof AccountRecord, string][] = [
  ["bank_id", "bank"],
  ["account_type_id", "account-type"],
];

const infoBar = element<HTMLElement>("info-bar");
const saveButton = element<HTMLButtonElement>("save");
const closeButton = element<HTMLButtonElement>("close");
const closedBox = element<HTMLInputElement>("is-closed");

let mode: Mode = "A";
let recordId: number | null = null;
let reserve: AccountRecord = { ...EMPTY_RECORD };
/// The blue line, as the core worded it for the record on screen.
let controlLine = "";

function field(id: string): HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement {
  return element(id);
}

/// The record the screen holds right now.
function onScreen(): AccountRecord {
  const record = { ...EMPTY_RECORD };
  for (const [member, id] of TEXT_FIELDS) {
    (record as Record<string, unknown>)[member] = field(id).value;
  }
  for (const [member, id] of NUMBER_FIELDS) {
    (record as Record<string, unknown>)[member] = Number(field(id).value);
  }
  record.is_closed = closedBox.checked;
  return record;
}

/// Puts a record on the screen, member by member.
function showRecord(record: AccountRecord): void {
  for (const [member, id] of TEXT_FIELDS) {
    field(id).value = String(record[member] ?? "");
  }
  for (const [member, id] of NUMBER_FIELDS) {
    field(id).value = String(record[member] ?? 0);
  }
  closedBox.checked = record.is_closed;
}

function loadReserve(record: AccountRecord): void {
  reserve = { ...record };
}

/// Compares the fields with the members of the reserve, one by one.
function isModified(): boolean {
  const current = onScreen();
  for (const key of Object.keys(EMPTY_RECORD) as (keyof AccountRecord)[]) {
    if (current[key] !== reserve[key]) {
      return true;
    }
  }
  return false;
}

function declareRecord(id: number | null): void {
  void invoke("set_account_form_record", { id });
}

function showState(): void {
  const modified = mode !== "L" && isModified();
  infoBar.textContent = modified ? `${controlLine} ${t("ui-modified-suffix")}` : controlLine;
  infoBar.classList.toggle("info-bar--alert", false);
  void invoke("set_account_form_dirty", { dirty: modified });
}

function say(text: string, alert = false): void {
  controlLine = text;
  infoBar.textContent = text;
  infoBar.classList.toggle("info-bar--alert", alert);
}

function setEditable(editable: boolean): void {
  for (const [, id] of [...TEXT_FIELDS, ...NUMBER_FIELDS]) {
    (field(id) as HTMLInputElement).disabled = !editable;
  }
  closedBox.disabled = !editable;
  saveButton.disabled = !editable;
}

function readParameters(query: string): void {
  const parameters = new URLSearchParams(query);
  mode = (parameters.get("mode") ?? "A") as Mode;
  recordId = parameters.has("id") ? Number(parameters.get("id")) : null;
  const kept = recordId === null ? `mode=${mode}` : `mode=${mode}&id=${recordId}`;
  history.replaceState(null, "", `?${kept}`);
}

async function fillCombo(id: string, command: string, selected: number): Promise<void> {
  const items = await invoke<Item[]>(command);
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

/// Reads the record by the key the list handed over, fills the reserve from
/// what was read, and only then puts it on the screen. The fields are never
/// the source of anything.
async function applyParameters(): Promise<void> {
  setEditable(false);
  say(t("ui-loading"));

  try {
    const failure = await invoke<string | null>("startup_error");
    if (failure) {
      say(failure, true);
      return;
    }

    let loaded: AccountRecord = { ...EMPTY_RECORD };
    let line = t("accounts-fresh");

    if (mode === "A") {
      await fillCombo("bank", "list_banks", 0);
      await fillCombo("account-type", "list_account_types", 1);
      loaded.account_type_id = Number(element<HTMLSelectElement>("account-type").value);
      saveButton.title = t("ui-title-add");
    } else {
      if (recordId === null) {
        say(t("accounts-nothing-to-show"), true);
        return;
      }
      const account = await invoke<AccountDto | null>("get_account", { id: recordId });
      if (!account) {
        say(t("accounts-gone"), true);
        return;
      }
      await fillCombo("bank", "list_banks", account.bank_id);
      await fillCombo("account-type", "list_account_types", account.account_type_id);
      const { id: _id, control_line: _line, ...record } = account;
      loaded = record;
      line = account.control_line;
      saveButton.title = mode === "M" ? t("ui-title-modify") : t("ui-title-save");
    }

    loadReserve(loaded);
    showRecord(loaded);
    declareRecord(mode === "A" ? null : recordId);
    say(line);

    if (mode === "L") {
      setEditable(false);
      saveButton.hidden = true;
    } else {
      saveButton.hidden = false;
      setEditable(true);
      field("label").focus();
    }
  } catch (error) {
    say(tError("ui-load-failed", error), true);
  }
}

async function save(): Promise<void> {
  if (mode === "L" || saveButton.disabled) {
    return;
  }
  const account = onScreen();

  try {
    // Everything that could stop this being written, asked for before
    // anything is: an empty title, an invalid IBAN, a name already taken.
    // A refusal is the window's to show, never a failure thrown at it.
    const refusal = await invoke<string | null>("account_refusal", {
      id: mode === "A" ? null : recordId,
      label: account.label,
      iban: account.iban,
      amounts: [
        account.opening_pointed,
        account.opening_committed,
        account.opening_planned,
      ],
    });
    if (refusal) {
      say(refusal, true);
      field("label").focus();
      return;
    }

    if (mode === "A") {
      recordId = await invoke<number>("create_account", { account });
      mode = "M";
      say(t("accounts-created"));
    } else {
      const changed = await invoke<boolean>("update_account", { id: recordId, account });
      if (!changed) {
        say(t("accounts-gone"), true);
        return;
      }
      say(t("accounts-updated"));
    }

    loadReserve(onScreen());
    showState();
    declareRecord(null);
    await invoke("notify_accounts_changed");
    closeCurrentWindow();
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

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
  showRecord(reserve);
  showState();
  declareRecord(null);
  closeCurrentWindow();
}

for (const [, id] of TEXT_FIELDS) {
  field(id).addEventListener("input", showState);
}
for (const [, id] of NUMBER_FIELDS) {
  field(id).addEventListener("change", showState);
}
closedBox.addEventListener("change", showState);

saveButton.addEventListener("click", () => void save());
closeButton.addEventListener("click", () => void closeWindow());

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
  loadReserve(EMPTY_RECORD);
  showRecord(EMPTY_RECORD);
  declareRecord(null);
  say("");
});

void listen<string>(PARAMETERS_EVENT, async (event) => {
  if (!(await mayDiscardChanges())) {
    return;
  }
  readParameters(event.payload);
  await applyParameters();
  // Le mode a pu changer avec les paramètres : le menu Outils le suit.
  applyToolsMode();
});

/// Pose les étiquettes de la fiche, à l'ouverture et à chaque changement de
/// langue.
///
/// **Elle ne relit pas le compte.** Cinq groupes de champs peuvent porter une
/// saisie en cours ; changer de langue n'est pas y renoncer. La réserve reste
/// donc telle quelle : rhabiller une fiche ne doit pas la déclarer modifiée.
/// Le menu « Outils » de la fiche, et ses trois entrées.
///
/// Trois portages du WLangage de Fabrice, arbitrés avec lui le 02/08/2026.
/// Il n'agit **qu'en modification** : à la création le compte n'existe pas
/// encore et n'a rien à compter ni à vider ; en consultation la fiche ne fait
/// que montrer. L'entrée reste visible et grisée plutôt que de disparaître —
/// un menu qui change de forme selon le mode se cherche.
function buildToolsMenu(): void {
  const bar = element<HTMLElement>("window-menu");
  bar.replaceChildren();

  const entry = document.createElement("button");
  entry.type = "button";
  entry.className = "window-menu__entry";
  entry.id = "tools-entry";
  entry.textContent = t("account-tools");

  const holder = document.createElement("div");
  holder.className = "window-menu__holder";
  const choices = document.createElement("div");
  choices.className = "window-menu__choices";
  choices.dataset.menu = "tools";
  choices.hidden = true;

  for (const [key, run] of [
    ["account-tools-initial-balance", setOpeningPointedBalance],
    ["account-tools-statistics", showStatistics],
    ["account-tools-delete-operations", deleteEveryOperation],
  ] as const) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "window-menu__choice window-menu__choice--plain";
    button.dataset.key = key;
    button.textContent = t(key);
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
  bar.append(holder);
  applyToolsMode();
}

/// Le menu suit le mode de la fiche. Appelé à chaque fois que le mode change,
/// c'est-à-dire à chaque arrivée de paramètres.
function applyToolsMode(): void {
  const entry = document.getElementById("tools-entry");
  if (entry instanceof HTMLButtonElement) {
    entry.disabled = mode !== "M" || recordId === null;
  }
}

/// « Définir le solde initial pointé ».
///
/// La question vient du noyau, avec dedans le total des opérations pointées.
/// Ce qui est saisi est le solde **réel de la banque aujourd'hui** ; le noyau
/// en retranche ce total et rend le solde initial.
///
/// **Rien n'est écrit en base** (règle de Fabrice, fidèle à son code) : le
/// résultat va dans la case et dans la ligne bleue, et c'est l'enregistrement
/// de la fiche qui écrit. La fiche se sait donc modifiée, et sa porte posera
/// sa question.
async function setOpeningPointedBalance(): Promise<void> {
  if (recordId === null) {
    return;
  }
  try {
    const question = await invoke<string>("account_initial_balance_question", {
      accountId: recordId,
    });
    const typed = await askForAmount(
      question,
      element<HTMLInputElement>("opening-pointed").value,
      t("ui-yes"),
      t("ui-no"),
    );
    if (typed === null) {
      return;
    }
    const computed = await invoke<{ amount: string; control_line: string }>(
      "account_initial_balance",
      { accountId: recordId, typed },
    );
    element<HTMLInputElement>("opening-pointed").value = computed.amount;
    say(computed.control_line);
    showState();
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// « Statistiques compte bancaire » — les quatorze lignes de son `Info()`,
/// dans une boîte à un seul bouton, comme l'original.
async function showStatistics(): Promise<void> {
  if (recordId === null) {
    return;
  }
  try {
    const message = await invoke<string>("account_statistics", { accountId: recordId });
    await tell(message, t("ui-ok"));
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// « Supprimer toutes les transactions du compte » — la double barrière de
/// l'original : il faut écrire le « oui » de la langue courante.
///
/// Elle écrit **tout de suite**, sans regarder si la fiche porte des
/// modifications non enregistrées : c'est ce que fait l'original, et Fabrice a
/// tranché pour lui le 02/08/2026.
async function deleteEveryOperation(): Promise<void> {
  if (recordId === null) {
    return;
  }
  try {
    const prompt = await invoke<{ question: string; word: string }>(
      "account_delete_operations_question",
    );
    const confirmed = await askForWord(prompt.question, prompt.word, t("ui-yes"), t("ui-no"));
    if (!confirmed) {
      return;
    }
    const report = await invoke<string>("delete_account_operations", { accountId: recordId });
    say(report);
    // Les trois soldes du compte viennent de bouger : la liste des comptes et
    // tout ce qui montre ce compte doivent le savoir.
    await invoke("notify_accounts_changed");
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

function dress(): void {
  for (const [id, key] of [
    ["group-bank", "account-group-bank"],
    ["group-holder", "account-group-holder"],
    ["group-rib", "account-group-rib"],
    ["group-activity", "account-group-activity"],
    ["group-balances", "account-group-balances"],
    ["label-label", "account-field-label"],
    ["bank-label", "account-field-bank"],
    ["type-label", "account-field-type"],
    ["branch-address-label", "account-field-branch-address"],
    ["holder-name-label", "account-field-holder-name"],
    ["holder-address-label", "account-field-holder-address"],
    ["rib-bank-label", "account-field-rib-bank"],
    ["rib-branch-label", "account-field-rib-branch"],
    ["rib-number-label", "account-field-rib-number"],
    ["rib-key-label", "account-field-rib-key"],
    ["bic-label", "account-field-bic"],
    ["iban-label", "account-field-iban"],
    ["opening-date-label", "account-field-opening-date"],
    ["closing-date-label", "account-field-closing-date"],
    ["is-closed-label", "account-field-closed"],
    ["opening-pointed-label", "account-field-opening-pointed"],
    ["opening-committed-label", "account-field-opening-committed"],
    ["opening-planned-label", "account-field-opening-planned"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  closeButton.title = t("ui-title-close");
  buildToolsMenu();
}

void (async () => {
  await loadTexts(null);
  dress();

  // The three balances are money, and a money field refuses at the keyboard
  // what cannot be an amount. Turned on here, after the words: the field
  // formats with the separators of the current language.
  //
  // Hors de `dress()`, et pour deux raisons : ce n'est pas un mot mais une
  // écoute, qu'un second branchement doublerait ; et le champ va chercher ses
  // séparateurs dans le dictionnaire au moment où il écrit, donc il suit déjà
  // la langue tout seul.
  for (const id of ["opening-pointed", "opening-committed", "opening-planned"]) {
    asMoneyField(element<HTMLInputElement>(id));
  }

  readParameters(window.location.search);
  await applyParameters();
  applyToolsMode();
  onLanguageChanged(dress, { key: "window-account-title" });
})();
