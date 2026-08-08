// F36 — « Fiche Modele Operation ».
//
// Les quatre bandeaux de sa capture, dans son ordre. **Ni compte, ni date** :
// un modèle traverse plusieurs saisies, et ces deux-là appartiennent à chaque
// saisie.
//
// Le sens est un combo et le montant une grandeur, comme dans la fiche
// opération : ce qui est tapé est ce qui est vu, et ce qui est vu est ce qui
// sera appliqué.
//
// **Enregistrer referme la fiche**, comme les fiches chèque et chéquier.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { asMoneyField } from "./money-field";
import { closeCurrentWindow } from "./window-frame";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

const PARAMETERS_EVENT = "window-parameters:operation-template-form";

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

interface Template {
  id: number;
  label: string;
  amount: number;
  amount_text: string;
  payment_mode_id: number;
  category_id: number;
  assignment_id: number;
  status_id: number;
  payee_id: number;
  project_id: number;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

/// « A » ajoute, « M » modifie, « L » consulte — le vocabulaire de l'original.
let mode: "A" | "M" | "L" = "A";
let recordId = 0;
let statuses: Item[] = [];
let combos: Combos | null = null;

const NOMENCLATURES = [
  ["category", "category", "category_id"],
  ["assignment", "assignment", "assignment_id"],
  ["payment-mode", "payment_mode", "payment_mode_id"],
  ["payee", "payee", "payee_id"],
  ["project", "project", "project_id"],
] as const;

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

/// Le montant tapé, **signé par le sens choisi** — comme la fiche opération.
function typedAmount(): number {
  const written = element<HTMLInputElement>("amount").value.replace(/[^0-9.,]/g, "");
  const separator = written.lastIndexOf(",") > written.lastIndexOf(".") ? "," : ".";
  const [whole, decimals = ""] = written.split(separator);
  const units = Number(whole.replace(/[^0-9]/g, "")) || 0;
  const fraction = Number(`${decimals}000000`.slice(0, 6)) || 0;
  const value = units * 1_000_000 + fraction;
  return element<HTMLSelectElement>("direction").value === "D" ? -value : value;
}

/// Ce que la fiche laisse faire : en consultation, rien.
function applyMode(): void {
  const reading = mode === "L";
  for (const id of [
    "label",
    "amount",
    "direction",
    "status",
    "category",
    "assignment",
    "payment-mode",
    "payee",
    "project",
  ]) {
    const field = element<HTMLInputElement | HTMLSelectElement>(id);
    if (field instanceof HTMLSelectElement) {
      field.disabled = reading;
    } else {
      field.readOnly = reading;
    }
  }
  element<HTMLButtonElement>("save").hidden = reading;
  element<HTMLElement>("save").title = t(mode === "A" ? "ui-title-add" : "ui-title-modify");
}

function show(template: Template | null): void {
  element<HTMLInputElement>("id").value = String(template?.id ?? 0);
  element<HTMLInputElement>("label").value = template?.label ?? "";
  element<HTMLInputElement>("amount").value = template?.amount_text ?? "0,00";
  element<HTMLSelectElement>("direction").value =
    template === null || template.amount < 0 ? "D" : "C";
  fill(element<HTMLSelectElement>("status"), statuses, template?.status_id ?? 1);
  for (const [id, list, member] of NOMENCLATURES) {
    fill(element<HTMLSelectElement>(id), combos?.[list] ?? [], template?.[member] ?? 0);
  }
}

async function load(): Promise<void> {
  try {
    if (mode === "A") {
      show(null);
      applyMode();
      say(t("operation-template-fresh"));
      return;
    }
    const template = await invoke<Template | null>("get_operation_template", { id: recordId });
    if (!template) {
      say(t("operation-template-gone"), true);
      return;
    }
    show(template);
    applyMode();
    say(t(mode === "L" ? "ui-viewing" : "ui-editing"));
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

function typedValues(): Record<string, unknown> {
  return {
    label: element<HTMLInputElement>("label").value,
    amount: typedAmount(),
    paymentModeId: Number(element<HTMLSelectElement>("payment-mode").value) || 0,
    categoryId: Number(element<HTMLSelectElement>("category").value) || 0,
    assignmentId: Number(element<HTMLSelectElement>("assignment").value) || 0,
    statusId: Number(element<HTMLSelectElement>("status").value) || 1,
    payeeId: Number(element<HTMLSelectElement>("payee").value) || 0,
    projectId: Number(element<HTMLSelectElement>("project").value) || 0,
  };
}

async function save(): Promise<void> {
  try {
    const values = typedValues();
    const refusal = await invoke<string | null>("operation_template_refusal", {
      id: mode === "A" ? null : recordId,
      label: values.label,
    });
    if (refusal) {
      say(refusal, true);
      return;
    }
    if (mode === "A") {
      await invoke<number>("create_operation_template", values);
    } else if (!(await invoke<boolean>("update_operation_template", { id: recordId, ...values }))) {
      say(t("operation-template-gone"), true);
      return;
    }
    await invoke("notify_operation_templates_changed");
    closeCurrentWindow();
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

function readParameters(query: string): void {
  const parameters = new URLSearchParams(query);
  const asked = parameters.get("mode");
  mode = asked === "M" ? "M" : asked === "L" ? "L" : "A";
  recordId = Number(parameters.get("id") ?? 0);
}

element<HTMLButtonElement>("save").addEventListener("click", () => void save());
element<HTMLButtonElement>("close").addEventListener("click", () => closeCurrentWindow());

void listen<string>(PARAMETERS_EVENT, (event) => {
  readParameters(event.payload);
  void load();
});

/// La base a-t-elle pu s'ouvrir ? Sans elle il n'y a aucun modèle à lire, et
/// rien à enregistrer.
async function checkStartup(): Promise<boolean> {
  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    element<HTMLButtonElement>("save").disabled = true;
    return false;
  }
  return true;
}

/// Pose les mots de la fiche, à l'ouverture et à chaque changement de langue —
/// une fenêtre est bâtie une fois et jamais détruite, elle ne peut que se
/// rhabiller.
///
/// **Elle ne relit jamais le modèle.** Les quatre bandeaux, leurs étiquettes et
/// les bulles se reposent ; ce qui est dans les cases appartient à celui qui le
/// tape, et un libellé à demi écrit ne doit pas disparaître parce qu'on a
/// changé de langue.
function dress(): void {
  for (const [id, key] of [
    ["id-label", "operation-template-field-id"],
    ["group-name", "operation-template-group-name"],
    ["label-label", "operation-template-field-label"],
    ["group-amount", "operation-template-group-amount"],
    ["direction-label", "operation-template-field-direction"],
    ["amount-label", "operation-template-field-amount"],
    ["group-status", "operation-template-group-status"],
    ["status-label", "operation-template-field-status"],
    ["group-classification", "operation-template-group-classification"],
    ["category-label", "operation-template-field-category"],
    ["assignment-label", "operation-template-field-assignment"],
    ["payment-mode-label", "operation-template-field-mode"],
    ["payee-label", "operation-template-field-payee"],
    ["project-label", "operation-template-field-project"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  element<HTMLElement>("close").title = t("ui-title-close");

  // Le sens est écrit lui aussi : ses deux entrées se refont dans la nouvelle
  // langue. **Et le sens choisi est repris** — changer de langue ne doit pas
  // retourner un débit en crédit. À l'ouverture le menu est vide, il n'y a rien
  // à reprendre, et la première entrée reste choisie comme avant.
  const direction = element<HTMLSelectElement>("direction");
  const chosen = direction.value;
  direction.replaceChildren();
  for (const [value, key] of [
    ["D", "operation-direction-debit"],
    ["C", "operation-direction-credit"],
  ] as const) {
    const entry = document.createElement("option");
    entry.value = value;
    entry.textContent = t(key);
    direction.append(entry);
  }
  if (chosen !== "") {
    direction.value = chosen;
  }

  // La bulle d'Enregistrer dit « Ajouter » ou « Modifier » : c'est un mot, et
  // il dépend du mode. La rappeler ne touche à aucune case de la saisie, et ne
  // change pas le mode : elle ne fait que l'appliquer.
  applyMode();
}

void (async () => {
  await loadTexts(null);
  dress();
  asMoneyField(element<HTMLInputElement>("amount"));

  if (await checkStartup()) {
    combos = await invoke<Combos>("list_operation_combos");
    statuses = await invoke<Item[]>("list_operation_statuses");
    readParameters(window.location.search);
    await load();
  }
  onLanguageChanged(dress, { key: "window-operation-template-title" });
})();
