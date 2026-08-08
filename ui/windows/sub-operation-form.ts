// F04 — « Fiche Sous-Operation ».
//
// La ventilation d'une opération : une F03 réduite, sur le même modèle que
// tout le reste — réserve remplie après la lecture de l'enregistrement et
// avant tout affichage, comparée membre par membre au moment de sortir,
// aucun drapeau.
//
// Ce qu'elle n'a pas, et pourquoi. **Ni Mode, ni Statut, ni Date** : une
// sous-opération les tient de sa mère, que `Maj_ProprieteSousOp` lui repose
// après chaque écriture. Fabrice, 26/07/2026 : « dans une sous-opération,
// comme est le complément, on ne peut pas toucher au mode de paiement, cela
// serait illogique ». Les offrir ici serait offrir ce qu'on ne peut pas
// garder.
//
// **Le Complément n'est pas protégé.** C'est un état, pas un objet : ce qui
// reste à ventiler tant que personne ne le réclame. On peut l'ouvrir et le
// modifier ; le renommer ou changer son montant en fait une sous-opération
// ordinaire, et la vérification de cohérence lève alors un nouveau complément
// si la somme ne ferme plus la mère. Le classer, le commenter, ou
// l'enregistrer sans y toucher le laissent intact — rien de tout cela n'entre
// dans le calcul du reste. La fenêtre le dit, elle ne l'interdit pas.

import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askYesNo, questionIsOnScreen } from "./dialog";
import { closeCurrentWindow } from "./window-frame";
import { asMoneyField, SIGN_CHANGED } from "./money-field";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

const PARAMETERS_EVENT = "window-parameters:sub-operation-form";
const RESET_EVENT = "window-reset:sub-operation-form";

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

interface SubOperationDto extends SubOperationRecord {
  id: number;
  parent_id: number;
  is_complement: boolean;
  /// « Ventilation de « RETRAIT » (-100,00 €) », déjà rédigé par le noyau.
  parent_line: string;
}

type Mode = "A" | "M";

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

// --- La réserve ----------------------------------------------------------
interface SubOperationRecord {
  label: string;
  direction: string;
  amount: string;
  category_id: number;
  assignment_id: number;
  payee_id: number;
  project_id: number;
  comment: string;
}

const EMPTY_RECORD: SubOperationRecord = {
  label: "",
  direction: "D",
  amount: "0,00",
  category_id: 0,
  assignment_id: 0,
  payee_id: 0,
  project_id: 0,
  comment: "",
};

const TEXT_FIELDS: [keyof SubOperationRecord, string][] = [
  ["label", "label"],
  ["direction", "direction"],
  ["amount", "amount"],
  ["comment", "comment"],
];

const NUMBER_FIELDS: [keyof SubOperationRecord, string][] = [
  ["category_id", "category"],
  ["assignment_id", "assignment"],
  ["payee_id", "payee"],
  ["project_id", "project"],
];

const NOMENCLATURE_COMBOS: [string, keyof Combos, keyof SubOperationRecord][] = [
  ["category", "category", "category_id"],
  ["assignment", "assignment", "assignment_id"],
  ["payee", "payee", "payee_id"],
  ["project", "project", "project_id"],
];

const infoBar = element<HTMLElement>("info-bar");
const infoMessage = element<HTMLElement>("info-message");
const parentLine = element<HTMLElement>("parent-line");
const saveButton = element<HTMLButtonElement>("save");
const closeButton = element<HTMLButtonElement>("close");
const commentSection = element<HTMLElement>("comment-section");
const amountField = element<HTMLInputElement>("amount");
const directionField = element<HTMLSelectElement>("direction");

let mode: Mode = "A";
let recordId: number | null = null;
/// L'opération que l'on ventile. Elle arrive dans l'adresse et ne change pas.
let parentId = 0;
let reserve: SubOperationRecord = { ...EMPTY_RECORD };
let message = "";

let combos: Combos = {
  category: [],
  assignment: [],
  payment_mode: [],
  payee: [],
  project: [],
};

function field(id: string): HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement {
  return element(id);
}

function onScreen(): SubOperationRecord {
  const record = { ...EMPTY_RECORD };
  for (const [member, id] of TEXT_FIELDS) {
    (record as Record<string, unknown>)[member] = field(id).value;
  }
  for (const [member, id] of NUMBER_FIELDS) {
    (record as Record<string, unknown>)[member] = Number(field(id).value);
  }
  return record;
}

function showRecord(record: SubOperationRecord): void {
  for (const [member, id] of TEXT_FIELDS) {
    field(id).value = String(record[member] ?? "");
  }
  for (const [member, id] of NUMBER_FIELDS) {
    field(id).value = String(record[member] ?? 0);
  }
  commentSection.hidden = record.comment.trim() === "";
}

function loadReserve(record: SubOperationRecord): void {
  reserve = { ...record };
}

function isModified(): boolean {
  const current = onScreen();
  for (const key of Object.keys(EMPTY_RECORD) as (keyof SubOperationRecord)[]) {
    if (current[key] !== reserve[key]) {
      return true;
    }
  }
  return false;
}

function showState(): void {
  const modified = isModified();
  infoMessage.textContent = modified ? `${message} ${t("ui-modified-suffix")}` : message;
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

// --- Le signe, comme dans la fiche opération ------------------------------
// Les deux contrôles disent toujours la même chose et le signe se voit : un
// débit se lit « -30,00 ». Écrit ici comme là-bas parce que ce sont deux
// fenêtres, mais la règle est la même et le noyau l'applique une seule fois.

function theTypeFollowsTheAmount(): void {
  directionField.value = amountField.value.trimStart().startsWith("-") ? "D" : "C";
}

function theAmountFollowsTheType(): void {
  const body = amountField.value.replace("-", "").trim();
  const nothing = body === "" || body.replace(/\D/g, "").replace(/0/g, "") === "";
  const wanted = directionField.value === "D" && !nothing ? `-${body}` : body;
  if (wanted !== amountField.value) {
    amountField.value = wanted;
  }
}

function settleTheAmountAndItsType(): void {
  if (amountField.value.trimStart().startsWith("-")) {
    directionField.value = "D";
    return;
  }
  theAmountFollowsTheType();
}

amountField.addEventListener(SIGN_CHANGED, theTypeFollowsTheAmount);
directionField.addEventListener("change", theAmountFollowsTheType);

function readParameters(query: string): void {
  const parameters = new URLSearchParams(query);
  mode = (parameters.get("mode") ?? "A") as Mode;
  parentId = Number(parameters.get("parent") ?? 0);
  recordId = parameters.has("id") ? Number(parameters.get("id")) : null;
  const kept =
    recordId === null
      ? `mode=${mode}&parent=${parentId}`
      : `mode=${mode}&parent=${parentId}&id=${recordId}`;
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

/// Lit l'enregistrement par la clef reçue, remplit la réserve avec ce qui a
/// été lu, et seulement ensuite affiche. Les champs ne sont jamais la source
/// de quoi que ce soit.
async function applyParameters(): Promise<void> {
  setEditable(false);
  parentLine.textContent = "";
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

    let loaded: SubOperationRecord = { ...EMPTY_RECORD };
    let line = t("sub-operation-fresh");

    if (mode === "A") {
      // On ventile une opération : elle doit exister, et la fenêtre dit
      // laquelle. Le montant part à zéro — le complément absorbera le reste.
      const parent = await invoke<string | null>("sub_operation_parent_line", { parentId });
      if (!parent) {
        say(t("sub-operation-parent-gone"), true);
        return;
      }
      parentLine.textContent = parent;
      saveButton.title = t("ui-title-add");
    } else {
      if (recordId === null) {
        say(t("sub-operation-nothing-to-show"), true);
        return;
      }
      const sub = await invoke<SubOperationDto | null>("get_sub_operation", { id: recordId });
      if (!sub) {
        say(t("sub-operation-gone"), true);
        return;
      }
      const {
        id: _id,
        parent_id: parent,
        is_complement: isComplement,
        parent_line: parentText,
        ...record
      } = sub;
      loaded = record;
      parentId = parent;
      parentLine.textContent = parentText;
      // Le Complément est montré pour ce qu'il est, et reste modifiable.
      line = isComplement ? t("sub-operation-is-the-complement") : t("ui-editing");
      saveButton.title = t("ui-title-modify");
    }

    for (const [id, list, member] of NOMENCLATURE_COMBOS) {
      fillCombo(id, combos[list], loaded[member] as number);
    }

    loadReserve(loaded);
    showRecord(loaded);
    say(line);

    setEditable(true);
    const label = element<HTMLInputElement>("label");
    label.focus();
    label.select();
  } catch (error) {
    say(tError("ui-load-failed", error), true);
  }
}

async function save(): Promise<void> {
  if (saveButton.disabled) {
    return;
  }
  const sub = onScreen();

  try {
    const refusal = await invoke<string | null>("sub_operation_refusal", {
      label: sub.label,
      amount: sub.amount,
    });
    if (refusal) {
      say(refusal, true);
      element<HTMLInputElement>("label").focus();
      return;
    }

    if (mode === "A") {
      const id = await invoke<number | null>("create_sub_operation", { parentId, sub });
      if (id === null) {
        say(t("sub-operation-parent-gone"), true);
        return;
      }
      recordId = id;
      mode = "M";
      say(t("sub-operation-created"));
    } else {
      const changed = await invoke<boolean>("update_sub_operation", { id: recordId, sub });
      if (!changed) {
        say(t("sub-operation-gone"), true);
        return;
      }
      say(t("sub-operation-updated"));
    }

    loadReserve(onScreen());
    showState();
    await invoke("notify_operations_changed");
    closeCurrentWindow();
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

async function mayDiscardChanges(): Promise<boolean> {
  if (!isModified()) {
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
  closeCurrentWindow();
}

for (const [, id] of TEXT_FIELDS) {
  field(id).addEventListener("input", showState);
}
for (const [, id] of NUMBER_FIELDS) {
  field(id).addEventListener("change", showState);
}
directionField.addEventListener("change", showState);

saveButton.addEventListener("click", () => void save());
closeButton.addEventListener("click", () => void closeWindow());

element<HTMLButtonElement>("comment-button").addEventListener("click", () => {
  commentSection.hidden = !commentSection.hidden;
  if (!commentSection.hidden) {
    element<HTMLTextAreaElement>("comment").focus();
  }
});

window.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    event.preventDefault();
    void closeWindow();
  }
});

/// Laissée derrière avec une saisie abandonnée : la fenêtre ne garde rien.
void listen(RESET_EVENT, () => {
  recordId = null;
  parentId = 0;
  loadReserve(EMPTY_RECORD);
  showRecord(EMPTY_RECORD);
  parentLine.textContent = "";
  say("");
});

void listen<string>(PARAMETERS_EVENT, async (event) => {
  if (!(await mayDiscardChanges())) {
    return;
  }
  readParameters(event.payload);
  await applyParameters();
});

/// Pose les mots de la fiche, à l'ouverture et à chaque changement de langue.
///
/// **Elle ne relit pas la ventilation.** Une saisie en cours ne doit pas
/// disparaître parce qu'on a changé de langue, et la réserve n'est pas touchée
/// non plus : rhabiller la fenêtre ne doit pas la déclarer modifiée. La ligne
/// de la mère, elle, reste telle que le noyau l'a écrite — la reposer voudrait
/// dire relire l'opération.
function dress(): void {
  for (const [id, key] of [
    ["group-identification", "operation-group-identification"],
    ["group-amount", "sub-operation-group-amount"],
    ["group-classification", "operation-group-classification"],
    ["group-comment", "operation-group-comment"],
    ["label-label", "sub-operation-field-label"],
    ["direction-label", "operation-field-direction"],
    ["amount-label", "operation-field-amount"],
    ["category-label", "operation-field-category"],
    ["assignment-label", "operation-field-assignment"],
    ["payee-label", "operation-field-payee"],
    ["project-label", "operation-field-project"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  for (const [id, key] of [
    ["comment-button", "operation-title-comment"],
    ["save", "ui-title-save"],
    ["close", "ui-title-close"],
  ] as const) {
    element<HTMLElement>(id).title = t(key);
  }

  // La barre est vidée avant : rhabillée, la fenêtre en écrirait une seconde à
  // côté de la première.
  const menu = element<HTMLElement>("window-menu");
  menu.replaceChildren();
  const entry = document.createElement("span");
  entry.className = "window-menu__entry window-menu__entry--inert";
  entry.textContent = t("operation-menu-identification");
  menu.append(entry);

  // Les deux mots changent avec la langue, le choix non : on le relève avant
  // de refaire la liste et on le repose. Une ventilation qui passerait toute
  // seule de Crédit à Débit changerait le signe d'un montant sans que personne
  // l'ait demandé. À l'ouverture le champ est vide et part sur « D », comme
  // avant.
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

void (async () => {
  await loadTexts(null);
  dress();

  asMoneyField(amountField);
  amountField.addEventListener("blur", () => {
    settleTheAmountAndItsType();
    showState();
  });

  const failure = await invoke<string | null>("startup_error");
  if (!failure) {
    combos = await invoke<Combos>("list_operation_combos");
  }

  readParameters(window.location.search);
  await applyParameters();
  onLanguageChanged(dress, { key: "window-sub-operation-title" });
})();
