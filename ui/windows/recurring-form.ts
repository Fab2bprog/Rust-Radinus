// F15 — la fiche définissant une règle d'opération périodique.
//
// Trois modes, comme toutes les fiches de Radinus : ajout, modification,
// consultation. Le montant est une **grandeur** accompagnée d'une combo
// Débit/Crédit qui porte le signe — la même mécanique que la fiche opération,
// et celle de son `Enreg_Ajouter`.
//
// Deux champs ne s'allument qu'avec leur condition de fin : la date de fin et
// le nombre de répétitions. C'est ce que fait son `Fenetre_Initialise`, qui
// grise l'un ou l'autre selon le bouton coché.
//
// **La corbeille du panneau n'efface pas la règle**, elle efface les
// opérations que la règle a déjà insérées, retrouvées par son GUID (Fabrice,
// 31/07/2026). D'où le bandeau de consultation juste au-dessus : il dit ce
// qu'on s'apprête à détruire. La règle, elle, ne recule pas — effacer et
// rejouer sont deux gestes distincts.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askYesNo } from "./dialog";
import { asMoneyField } from "./money-field";
import { closeCurrentWindow } from "./window-frame";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

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

interface Rule {
  id: number;
  guid: string;
  account_id: number;
  label: string;
  amount: number;
  direction: number;
  category_id: number;
  assignment_id: number;
  payment_mode_id: number;
  payee_id: number;
  project_id: number;
  next_date: string;
  ending: string;
  end_date: string;
  unit: string;
  frequency: number;
  repeat_count: number;
  produced_count: number;
  produced_total: string;
  produced_last: string;
}

const UNITS = ["day", "week", "month", "quarter", "year"] as const;
const ENDINGS = ["no-limit", "until-date", "repeat-count"] as const;

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

let mode: "A" | "M" | "L" = "A";
let recordId = 0;
let sourceOperation = 0;
let accounts: Item[] = [];
let combos: Combos | null = null;

function fill(menu: HTMLSelectElement, items: Item[], chosen: number): void {
  menu.replaceChildren();
  for (const item of items) {
    const entry = document.createElement("option");
    entry.value = String(item.id);
    entry.textContent = item.label;
    menu.append(entry);
  }
  menu.value = String(chosen);
}

function today(): string {
  const now = new Date();
  const month = `${now.getMonth() + 1}`.padStart(2, "0");
  const day = `${now.getDate()}`.padStart(2, "0");
  return `${now.getFullYear()}-${month}-${day}`;
}

/// Les deux champs conditionnels s'allument avec leur bouton — son
/// `Fenetre_Initialise`, qui grise ce qui ne s'applique pas.
function refreshEndings(): void {
  const chosen = ENDINGS.find((key) => element<HTMLInputElement>(`ending-${key}`).checked);
  element<HTMLInputElement>("end-date").disabled = chosen !== "until-date";
  element<HTMLInputElement>("repeat-count").disabled = chosen !== "repeat-count";
}

/// Ce que la fiche tient, sous la forme que Rust attend.
function typedRule(): Record<string, unknown> {
  const chosen =
    ENDINGS.find((key) => element<HTMLInputElement>(`ending-${key}`).checked) ?? "no-limit";
  return {
    account_id: Number(element<HTMLSelectElement>("account").value) || 0,
    label: element<HTMLInputElement>("label").value,
    // Le montant part **tel qu'il est écrit** : c'est le noyau qui le relit.
    amount: element<HTMLInputElement>("amount").value,
    direction: Number(element<HTMLSelectElement>("direction").value) || 1,
    category_id: Number(element<HTMLSelectElement>("category").value) || 0,
    assignment_id: Number(element<HTMLSelectElement>("assignment").value) || 0,
    payment_mode_id: Number(element<HTMLSelectElement>("payment-mode").value) || 0,
    payee_id: Number(element<HTMLSelectElement>("payee").value) || 0,
    project_id: Number(element<HTMLSelectElement>("project").value) || 0,
    next_date: element<HTMLInputElement>("next-date").value,
    ending: chosen,
    end_date: element<HTMLInputElement>("end-date").value,
    unit: element<HTMLSelectElement>("unit").value,
    frequency: Number(element<HTMLInputElement>("frequency").value) || 1,
    repeat_count: Number(element<HTMLInputElement>("repeat-count").value) || 1,
  };
}

function showRule(rule: Rule | null): void {
  element<HTMLInputElement>("id").value = rule ? String(rule.id) : "";
  element<HTMLSelectElement>("account").value = String(rule?.account_id ?? accounts[0]?.id ?? 0);
  element<HTMLInputElement>("label").value = rule?.label ?? "";
  element<HTMLSelectElement>("direction").value = String(rule?.direction ?? -1);
  element<HTMLInputElement>("amount").value = rule
    ? (rule.amount / 1_000_000).toFixed(2).replace(".", ",")
    : "0,00";
  fill(element<HTMLSelectElement>("category"), combos?.category ?? [], rule?.category_id ?? 0);
  fill(element<HTMLSelectElement>("payment-mode"), combos?.payment_mode ?? [], rule?.payment_mode_id ?? 0);
  fill(element<HTMLSelectElement>("assignment"), combos?.assignment ?? [], rule?.assignment_id ?? 0);
  fill(element<HTMLSelectElement>("payee"), combos?.payee ?? [], rule?.payee_id ?? 0);
  fill(element<HTMLSelectElement>("project"), combos?.project ?? [], rule?.project_id ?? 0);
  element<HTMLInputElement>("next-date").value = rule?.next_date || today();
  element<HTMLSelectElement>("unit").value = rule?.unit ?? "month";
  element<HTMLInputElement>("frequency").value = String(rule?.frequency ?? 1);
  element<HTMLInputElement>("end-date").value = rule?.end_date ?? "";
  element<HTMLInputElement>("repeat-count").value = String(rule?.repeat_count || 1);
  for (const key of ENDINGS) {
    element<HTMLInputElement>(`ending-${key}`).checked = (rule?.ending ?? "no-limit") === key;
  }
  refreshEndings();

  element<HTMLInputElement>("guid").value = rule?.guid ?? "";
  element<HTMLInputElement>("produced-count").value = String(rule?.produced_count ?? 0);
  element<HTMLInputElement>("produced-last").value = rule?.produced_last ?? "";
  element<HTMLInputElement>("produced-total").value = rule?.produced_total ?? "";
}

/// La consultation ne se saisit pas : tout est gelé, et l'enregistrement
/// disparaît — c'est ce que fait son `Maj_Controles` en mode « L ».
function applyMode(): void {
  const reading = mode === "L";
  for (const id of [
    "account",
    "label",
    "category",
    "payment-mode",
    "assignment",
    "payee",
    "project",
    "direction",
    "amount",
    "next-date",
    "frequency",
    "unit",
    "end-date",
    "repeat-count",
    "ending-no-limit",
    "ending-until-date",
    "ending-repeat-count",
  ]) {
    (element<HTMLInputElement>(id) as HTMLInputElement).disabled = reading;
  }
  if (!reading) {
    refreshEndings();
  }
  element<HTMLButtonElement>("save").hidden = reading;
  // La corbeille n'a de sens que sur une règle qui existe.
  element<HTMLButtonElement>("erase").hidden = recordId === 0;
}

async function save(): Promise<void> {
  try {
    const rule = typedRule();
    const refusal = await invoke<string | null>("recurring_refusal", { rule });
    if (refusal) {
      say(refusal, true);
      return;
    }
    if (mode === "A") {
      await invoke<number>("create_recurring_rule", { rule });
    } else if (!(await invoke<boolean>("update_recurring_rule", { id: recordId, rule }))) {
      say(t("recurring-gone"), true);
      return;
    }
    // **Enregistrer, c'est avoir fini.** La fiche se ferme derrière elle,
    // comme celle du chèque et comme son `Action_Confirmer` suivi de `Ferme()`
    // (demande de Fabrice, 31/07/2026). La liste, elle, se relit toute seule :
    // elle écoute l'événement que l'enregistrement vient d'émettre.
    closeCurrentWindow();
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

/// La corbeille : elle efface **les opérations** que la règle a produites, pas
/// la règle. Confirmation d'abord, soldes recalculés ensuite.
async function erase(): Promise<void> {
  if (recordId === 0) {
    return;
  }
  try {
    const question = await invoke<string | null>("recurring_erase_question", { id: recordId });
    if (question === null) {
      say(t("recurring-erase-none"));
      return;
    }
    if (!(await askYesNo(question, t("ui-yes"), t("ui-no")))) {
      say(t("ui-deletion-abandoned"));
      return;
    }
    const said = await invoke<string>("erase_recurring_operations", { id: recordId });
    await load();
    say(said);
  } catch (error) {
    say(tError("ui-delete-failed", error), true);
  }
}

/// Ce que la fiche emprunte à une opération. Le reste de l'opération — sa
/// date, son statut, son pointage, son chèque — n'a pas de sens pour une règle
/// qui se répète.
interface Source {
  label: string;
  amount: string;
  direction: string;
  account_id: number;
  category_id: number;
  assignment_id: number;
  payment_mode_id: number;
  payee_id: number;
  project_id: number;
}

/// **Créer une règle à partir d'une opération** (Fabrice, 25/08/2026) : la
/// fiche s'ouvre neuve, puis reçoit ce que l'opération sait donner — « comme
/// si les champs avaient été remplis à la main ».
///
/// Ce qu'elle ne reçoit pas : la date prochaine, la fréquence, l'unité et la
/// condition de fin. Une opération ne dit pas à quel rythme elle se répète —
/// c'est précisément ce que l'utilisateur vient écrire. Ces champs gardent
/// donc les valeurs d'une fiche neuve.
///
/// **Rien n'est écrit** : c'est une fiche pré-remplie qu'il enregistre
/// lui-même, la règle de « Dupliquer » (26/07/2026).
async function fillFromOperation(id: number): Promise<void> {
  const source = await invoke<Source | null>("get_operation", { id });
  if (source === null) {
    say(t("operation-gone"), true);
    return;
  }
  element<HTMLInputElement>("label").value = source.label;
  element<HTMLInputElement>("amount").value = source.amount;
  // La fiche opération porte le sens dans une lettre, la règle dans un signe.
  element<HTMLSelectElement>("direction").value = source.direction === "D" ? "-1" : "1";
  element<HTMLSelectElement>("account").value = String(source.account_id);
  for (const [field, chosen] of [
    ["category", source.category_id],
    ["assignment", source.assignment_id],
    ["payment-mode", source.payment_mode_id],
    ["payee", source.payee_id],
    ["project", source.project_id],
  ] as const) {
    element<HTMLSelectElement>(field).value = String(chosen);
  }
}

async function load(): Promise<void> {
  if (recordId === 0) {
    showRule(null);
    applyMode();
    if (sourceOperation !== 0) {
      try {
        await fillFromOperation(sourceOperation);
      } catch (error) {
        say(tError("ui-load-failed", error), true);
      }
    }
    return;
  }
  try {
    const rule = await invoke<Rule | null>("get_recurring_rule", { id: recordId });
    if (rule === null) {
      say(t("recurring-gone"), true);
      return;
    }
    showRule(rule);
    applyMode();
  } catch (error) {
    say(tError("ui-load-failed", error), true);
  }
}

element<HTMLButtonElement>("save").addEventListener("click", () => void save());
element<HTMLButtonElement>("erase").addEventListener("click", () => void erase());
element<HTMLButtonElement>("close").addEventListener("click", () => closeCurrentWindow());
for (const key of ENDINGS) {
  element<HTMLInputElement>(`ending-${key}`).addEventListener("change", () => refreshEndings());
}

function readParameters(query: string): void {
  const parameters = new URLSearchParams(query);
  const asked = parameters.get("mode");
  mode = asked === "M" || asked === "L" ? asked : "A";
  recordId = Number(parameters.get("id") ?? 0);
  // L'opération dont cette règle est tirée, quand la fiche est ouverte depuis
  // le menu Divers de la liste des opérations. Zéro le reste du temps.
  sourceOperation = Number(parameters.get("from") ?? 0);
}

/// Redemandée sur une autre règle : la fenêtre est bâtie une fois et jamais
/// détruite, donc les nouveaux paramètres arrivent par un événement.
void listen<string>("window-parameters:recurring-form", (event) => {
  readParameters(event.payload);
  void load();
});

/// **Pose les mots de la fiche.** Appelée à l'ouverture, et de nouveau à chaque
/// changement de langue.
///
/// Elle ne relit **jamais** la règle : la fiche peut être en cours de saisie —
/// un libellé tapé, un montant, une date prochaine — et changer de langue ne
/// doit pas faire disparaître ce travail. Les deux combos sont rebâties dans la
/// nouvelle langue, mais ce qui y était choisi leur est remis.
function dress(): void {
  for (const [id, key] of [
    ["id-label", "recurring-field-id"],
    ["group-identity", "recurring-group-identity"],
    ["account-label", "recurring-field-account"],
    ["label-label", "recurring-field-label"],
    ["group-nomenclature", "recurring-group-nomenclature"],
    ["category-label", "recurring-field-category"],
    ["payment-mode-label", "recurring-field-mode"],
    ["assignment-label", "recurring-field-assignment"],
    ["payee-label", "recurring-field-payee"],
    ["project-label", "recurring-field-project"],
    ["group-amount", "recurring-group-amount"],
    ["direction-label", "recurring-field-direction"],
    ["amount-label", "recurring-field-amount"],
    ["group-period", "recurring-group-period"],
    ["next-date-label", "recurring-field-next"],
    ["frequency-label", "recurring-field-every"],
    ["group-ending", "recurring-group-ending"],
    ["ending-no-limit-label", "recurring-ending-no-limit"],
    ["ending-until-date-label", "recurring-ending-until-date"],
    ["ending-repeat-count-label", "recurring-ending-repeat-count"],
    ["end-date-label", "recurring-field-end-date"],
    ["repeat-count-label", "recurring-field-repeat"],
    ["group-produced", "recurring-group-produced"],
    ["guid-label", "recurring-field-guid"],
    ["produced-count-label", "recurring-field-produced-count"],
    ["produced-last-label", "recurring-field-produced-last"],
    ["produced-total-label", "recurring-field-produced-total"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  element<HTMLElement>("save").title = t("ui-title-save");
  element<HTMLElement>("erase").title = t("recurring-title-erase");
  element<HTMLElement>("close").title = t("ui-title-close");

  // Les deux combos sont **rebâties**, pas complétées : ajouter à la suite
  // doublerait leurs entrées à chaque changement de langue. Ce qui y était
  // choisi leur est remis ; au premier habillage il n'y a rien à remettre, et
  // la première entrée fait foi, comme avant.
  const units = element<HTMLSelectElement>("unit");
  const chosenUnit = units.value;
  units.replaceChildren();
  for (const key of UNITS) {
    const entry = document.createElement("option");
    entry.value = key;
    entry.textContent = t(`recurring-unit-${key}`);
    units.append(entry);
  }
  if (chosenUnit !== "") {
    units.value = chosenUnit;
  }
  // Débit et crédit, avec le signe en valeur — son `COMBO_TypeOp`.
  const direction = element<HTMLSelectElement>("direction");
  const chosenDirection = direction.value;
  direction.replaceChildren();
  for (const [value, key] of [
    [-1, "operation-direction-debit"],
    [1, "operation-direction-credit"],
  ] as const) {
    const entry = document.createElement("option");
    entry.value = String(value);
    entry.textContent = t(key);
    direction.append(entry);
  }
  if (chosenDirection !== "") {
    direction.value = chosenDirection;
  }
}

void (async () => {
  await loadTexts(null);
  dress();
  asMoneyField(element<HTMLInputElement>("amount"));

  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    element<HTMLButtonElement>("save").disabled = true;
    return;
  }

  accounts = await invoke<Item[]>("list_accounts");
  combos = await invoke<Combos>("list_operation_combos");
  fill(element<HTMLSelectElement>("account"), accounts, accounts[0]?.id ?? 0);
  readParameters(window.location.search);
  await load();
  onLanguageChanged(dress, { key: "window-recurring-form-title" });
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
  for (const [id, list] of [
    ["category", "category"],
    ["payment-mode", "payment_mode"],
    ["assignment", "assignment"],
    ["payee", "payee"],
    ["project", "project"],
  ] as [string, keyof Combos][]) {
    const menu = element<HTMLSelectElement>(id);
    fill(menu, combos?.[list] ?? [], Number(menu.value));
  }
});
