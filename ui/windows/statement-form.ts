// F18 — « Rapprocher une transaction (Intègre une opération dans l'historique
// de votre compte) ».
//
// La fiche d'**une** ligne du relevé, ouverte depuis la fenêtre d'importation
// quand une seule ligne est choisie. On y donne à l'opération son classement,
// puis elle entre dans le compte.
//
// **Tout y est modifiable**, y compris la date, le libellé, le sens et le
// montant. Chez Fabrice la fiche reçoit la transaction et la **rend modifiée**,
// et la liste se rafraîchit avec ce qui revient — je les avais mis en lecture
// seule en me disant que c'étaient les mots de la banque, c'était mon invention.
//
// L'avertissement du bas vient du noyau, jamais d'ici : c'est lui qui sait si
// le FITID est déjà en base, et c'est lui qui écrit la phrase.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askYesNo } from "./dialog";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

const PARAMETERS_EVENT = "window-parameters:statement-form";

interface Line {
  rank: number;
  date: string;
  label: string;
  direction: string;
  amount: string;
  clearing_date: string;
  warning: string;
}

interface Item {
  id: number;
  label: string;
}

/// Ce qu'une demande d'intégration a donné.
interface LineOutcome {
  outcome: "added" | "reconciled" | "duplicate" | "unknown";
  question: string;
}

interface Combos {
  category: Item[];
  assignment: Item[];
  payment_mode: Item[];
  payee: Item[];
  project: Item[];
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

let accountId = 0;
let rank = 0;

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

async function load(): Promise<void> {
  try {
    const line = await invoke<Line>("statement_line", { accountId, rank });
    element<HTMLInputElement>("date").value = line.date;
    element<HTMLInputElement>("label").value = line.label;
    element<HTMLSelectElement>("direction").value = line.direction;
    element<HTMLInputElement>("amount").value = line.amount;
    element<HTMLInputElement>("clearing-date").value = line.clearing_date;
    // L'avertissement rouge de l'original — doublon, ou fichier sans FITID.
    say(line.warning, line.warning !== "");
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// Le montant saisi, en micro-unités et **signé par le sens choisi** — comme
/// la fiche opération : le combo porte la direction, le champ ne porte qu'une
/// grandeur.
function typedAmount(): number {
  const written = element<HTMLInputElement>("amount").value.replace(/[^0-9.,-]/g, "");
  const separator = written.lastIndexOf(",") > written.lastIndexOf(".")
    ? ","
    : ".";
  const [whole, decimals = ""] = written.split(separator);
  const units = Number(whole.replace(/[^0-9]/g, "")) || 0;
  const fraction = Number(`${decimals}000000`.slice(0, 6)) || 0;
  const value = units * 1_000_000 + fraction;
  return element<HTMLSelectElement>("direction").value === "D" ? -value : value;
}

async function validate(): Promise<void> {
  try {
    // **Ce que la fiche a modifié part d'abord.** Chez Fabrice la fiche rend
    // la transaction changée, et c'est cette version-là qui entre.
    await invoke("statement_amend", {
      accountId,
      rank,
      date: element<HTMLInputElement>("date").value,
      label: element<HTMLInputElement>("label").value,
      amount: typedAmount(),
    });

    const classification = {
      payment_mode_id: Number(element<HTMLSelectElement>("payment-mode").value),
      category_id: Number(element<HTMLSelectElement>("category").value),
      assignment_id: Number(element<HTMLSelectElement>("assignment").value),
      payee_id: Number(element<HTMLSelectElement>("payee").value),
      project_id: Number(element<HTMLSelectElement>("project").value),
      status_id: Number(element<HTMLSelectElement>("status").value),
    };
    const clearingDate = element<HTMLInputElement>("clearing-date").value;

    let answer = await invoke<LineOutcome>("statement_integrate", {
      accountId,
      rank,
      classification,
      clearingDate,
      force: false,
    });
    // **Un doublon n'est pas refusé : il fait poser la question.** C'est
    // `Integration_Ligne`, et c'est l'utilisateur qui sait.
    if (answer.outcome === "duplicate") {
      if (!(await askYesNo(answer.question, t("statement-yes"), t("statement-no")))) {
        return;
      }
      answer = await invoke<LineOutcome>("statement_integrate", {
        accountId,
        rank,
        classification,
        clearingDate,
        force: true,
      });
    }
    if (answer.outcome === "reconciled") {
      say(t("statement-already-reconciled"), true);
      return;
    }
    await invoke("close_statement_form");
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

async function leave(): Promise<void> {
  try {
    await invoke("close_statement_form");
  } catch (error) {
    say(tError("ui-close-failed", error), true);
  }
}

function readParameters(query: string): void {
  const parameters = new URLSearchParams(query);
  accountId = Number(parameters.get("account") ?? 0);
  rank = Number(parameters.get("rank") ?? 0);
  history.replaceState(null, "", `?account=${accountId}&rank=${rank}`);
}

/// **Pose les mots de la fiche.** Appelée à l'ouverture, et de nouveau à chaque
/// changement de langue.
///
/// Elle ne relit **jamais** l'enregistrement : la fiche peut être en cours de
/// saisie — un libellé corrigé, un montant retapé — et changer de langue ne
/// doit pas faire disparaître ce travail. Seuls les mots changent.
function dress(): void {
  for (const [id, key] of [
    ["group-identification", "statement-group-identification"],
    ["group-amount", "statement-group-amount"],
    ["group-classification", "statement-group-classification"],
    ["group-status", "statement-group-status"],
    ["date-label", "statement-field-date"],
    ["label-label", "statement-field-label"],
    ["direction-label", "statement-field-type"],
    ["amount-label", "statement-field-amount"],
    ["payment-mode-label", "statement-field-mode"],
    ["category-label", "statement-field-category"],
    ["assignment-label", "statement-field-assignment"],
    ["payee-label", "statement-field-payee"],
    ["project-label", "statement-field-project"],
    ["status-label", "statement-field-status"],
    ["clearing-date-label", "statement-field-clearing"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  // Le sens, comme dans la fiche opération : un combo, et le champ montant ne
  // porte qu'une grandeur.
  //
  // Le combo est **rebâti**, pas complété : ajouter à la suite doublerait ses
  // deux entrées à chaque changement de langue. Le sens choisi lui est remis
  // ensuite — au premier habillage il n'y en a pas encore, et la première
  // entrée fait foi, comme avant.
  const direction = element<HTMLSelectElement>("direction");
  const chosenDirection = direction.value;
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
  if (chosenDirection !== "") {
    direction.value = chosenDirection;
  }

  element<HTMLElement>("validate").title = t("statement-title-validate");
  element<HTMLElement>("close").title = t("ui-title-close");
}

element<HTMLButtonElement>("validate").addEventListener("click", () => void validate());
element<HTMLButtonElement>("close").addEventListener("click", () => void leave());

/// Redemandée sur une autre ligne : la fiche est bâtie une fois et jamais
/// détruite, donc les nouveaux paramètres arrivent par un événement. Sans cette
/// écoute, elle montrerait éternellement la première ligne ouverte.
void listen<string>(PARAMETERS_EVENT, (event) => {
  readParameters(event.payload);
  void load();
});

void (async () => {
  await loadTexts(null);
  dress();

  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    return;
  }

  // Les cinq listes du classement, et les trois statuts. **Tout part à « Non
  // précisé »**, et le statut à pointée : une ligne de relevé bancaire est,
  // par définition, une opération que la banque a passée. Rien n'est deviné à
  // partir du type de transaction du fichier — ce serait une déduction de plus,
  // mais elle porterait sur un classement que l'on relit dans ses statistiques,
  // et une déduction fausse y est invisible.
  const combos = await invoke<Combos>("list_operation_combos");
  fill(element<HTMLSelectElement>("payment-mode"), combos.payment_mode, 0);
  fill(element<HTMLSelectElement>("category"), combos.category, 0);
  fill(element<HTMLSelectElement>("assignment"), combos.assignment, 0);
  fill(element<HTMLSelectElement>("payee"), combos.payee, 0);
  fill(element<HTMLSelectElement>("project"), combos.project, 0);
  fill(
    element<HTMLSelectElement>("status"),
    await invoke<Item[]>("list_operation_statuses"),
    1,
  );

  readParameters(window.location.search);
  await load();
  onLanguageChanged(dress, { key: "window-statement-form-title" });
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
  const fresh = await invoke<Combos>("list_operation_combos");
  for (const [id, list] of [
    ["payment-mode", "payment_mode"],
    ["category", "category"],
    ["assignment", "assignment"],
    ["payee", "payee"],
    ["project", "project"],
  ] as [string, keyof Combos][]) {
    const menu = element<HTMLSelectElement>(id);
    fill(menu, fresh[list], Number(menu.value));
  }
});
