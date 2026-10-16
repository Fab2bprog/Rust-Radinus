// F09 — « Transférer un montant entre deux comptes ».
//
// **Un virement n'est pas une opération, c'en est deux** (règle de Fabrice,
// 29/07/2026) : un débit sur la source, un crédit du même montant sur la
// destination. Cette fenêtre ne les écrit pas — elle demande, et c'est le
// noyau qui écrit les deux **ensemble ou pas du tout**.
//
// Trois de ses règles se voient à l'écran :
//
//   * **les soldes s'affichent au moment du choix** — les trois, dans la barre
//     du bas, pour qu'on sache ce qu'implique le virement avant de le faire ;
//   * **le montant est une grandeur strictement positive** : le champ interdit
//     la touche de signe, un virement négatif étant un virement dans l'autre
//     sens qui ne le dit pas ;
//   * **la fenêtre reste ouverte** après un virement, vidée pour le suivant —
//     on n'en fait presque jamais un seul.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askYesNo, tell } from "./dialog";
import { asMoneyField, SIGN_CHANGED } from "./money-field";
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

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

const NOMENCLATURES = [
  ["category", "category"],
  ["payment-mode", "payment_mode"],
  ["assignment", "assignment"],
  ["payee", "payee"],
  ["project", "project"],
] as const;

let combos: Combos | null = null;
let statuses: Item[] = [];

/// Le statut « pointée », tel que la base le numérote.
const POINTED = 1;
let accounts: Item[] = [];

/// Le compte dont la barre du bas montre les soldes, ou `0` quand elle ne
/// montre que l'aide. Voir `showBalancesOf`.
let showing = 0;

function today(): string {
  const now = new Date();
  const month = `${now.getMonth() + 1}`.padStart(2, "0");
  const day = `${now.getDate()}`.padStart(2, "0");
  return `${now.getFullYear()}-${month}-${day}`;
}

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

/// Une ligne vide en tête des deux combos de compte : tant qu'on n'a rien
/// choisi, la fenêtre ne doit pas faire croire qu'un compte l'est.
function fillAccounts(menu: HTMLSelectElement): void {
  menu.replaceChildren();
  const blank = document.createElement("option");
  blank.value = "0";
  blank.textContent = "";
  menu.append(blank);
  for (const account of accounts) {
    const entry = document.createElement("option");
    entry.value = String(account.id);
    entry.textContent = account.label;
    menu.append(entry);
  }
  menu.value = "0";
}

/// Les trois soldes du compte qu'on vient de choisir. **C'est le geste du
/// choix qui les montre** : savoir si l'on peut raisonnablement faire le débit
/// ne doit pas demander d'ouvrir une autre fenêtre.
async function showBalancesOf(id: number): Promise<void> {
  // **De quel compte la barre parle en ce moment.** Elle est retenue pour le
  // rhabillage : les trois soldes sont une phrase du noyau, et redire la même
  // chose dans l'autre langue demande de savoir sur quel compte elle portait.
  showing = id;
  if (id === 0) {
    say(t("transfer-help"));
    return;
  }
  try {
    say(await invoke<string>("transfer_balances", { accountId: id }));
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// Ce que la fenêtre montre, sous la forme que le noyau attend. Le montant part
/// **tel qu'il est écrit** : c'est le noyau qui le relit.
function typedTransfer(): Record<string, unknown> {
  return {
    source_id: Number(element<HTMLSelectElement>("source").value) || 0,
    target_id: Number(element<HTMLSelectElement>("target").value) || 0,
    label: element<HTMLInputElement>("label").value,
    payment_reference: element<HTMLInputElement>("reference").value,
    date: element<HTMLInputElement>("date").value,
    clearing_date: element<HTMLInputElement>("clearing-date").value,
    status_id: Number(element<HTMLSelectElement>("status").value) || 1,
    category_id: Number(element<HTMLSelectElement>("category").value) || 0,
    payment_mode_id: Number(element<HTMLSelectElement>("payment-mode").value) || 0,
    assignment_id: Number(element<HTMLSelectElement>("assignment").value) || 0,
    payee_id: Number(element<HTMLSelectElement>("payee").value) || 0,
    project_id: Number(element<HTMLSelectElement>("project").value) || 0,
    amount: element<HTMLInputElement>("amount").value,
  };
}

/// Vide la fenêtre pour le virement suivant.
function reset(): void {
  showing = 0;
  fillAccounts(element<HTMLSelectElement>("source"));
  fillAccounts(element<HTMLSelectElement>("target"));
  element<HTMLInputElement>("label").value = "";
  element<HTMLInputElement>("reference").value = "";
  element<HTMLInputElement>("date").value = today();
  element<HTMLInputElement>("clearing-date").value = today();
  element<HTMLInputElement>("amount").value = "0,00";
  fill(element<HTMLSelectElement>("status"), statuses, 1);
  for (const [id, list] of NOMENCLATURES) {
    fill(element<HTMLSelectElement>(id), combos?.[list] ?? [], 0);
  }
}

/// **La date de pointage suit le statut** (Fabrice, 21/08/2026), comme dans la
/// fiche opération : vidée vers prévu ou engagé, remplie de la date du virement
/// vers pointée. L'utilisateur peut toujours écrire ce qu'il veut ensuite.
function theClearingDateFollowsTheStatus(): void {
  const clearing = element<HTMLInputElement>("clearing-date");
  if (Number(element<HTMLSelectElement>("status").value) === POINTED) {
    if (clearing.value.trim() === "") {
      clearing.value = element<HTMLInputElement>("date").value;
    }
    return;
  }
  clearing.value = "";
}

element<HTMLSelectElement>("status").addEventListener(
  "change",
  theClearingDateFollowsTheStatus,
);

async function perform(): Promise<void> {
  try {
    const transfer = typedTransfer();
    // Les barrières d'abord : le même compte des deux côtés, un montant nul ou
    // négatif, un libellé ou une date manquants. Le noyau les repose derrière.
    const refusal = await invoke<string | null>("transfer_refusal", { transfer });
    if (refusal) {
      // **Le refus du pointage sans date s'affiche dans un panneau, et il
      // propose une issue** (Fabrice, 25/08/2026) : la même chose que dans la
      // fiche opération, parce que c'est le même refus. Non laisse la fenêtre
      // telle qu'elle est, sans rien écrire.
      if (refusal === t("operation-clearing-date-required")) {
        const date = element<HTMLInputElement>("date").value;
        const question = await invoke<string>("clearing_date_question", { date });
        if (!(await askYesNo(question, t("ui-yes"), t("ui-no")))) {
          return;
        }
        element<HTMLInputElement>("clearing-date").value = date;
        await perform();
        return;
      }
      say(refusal, true);
      return;
    }
    const done = await invoke<string | null>("perform_transfer", { transfer });
    if (!done) {
      say(t("ui-save-failed"), true);
      return;
    }
    // **Le panneau récapitule ce qui vient d'être écrit**, puis la fenêtre se
    // vide et reste ouverte : on enchaîne les virements sans la rouvrir.
    await tell(done, t("ui-ok"));
    reset();
    say(t("transfer-help"));
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

element<HTMLButtonElement>("validate").addEventListener("click", () => void perform());
element<HTMLButtonElement>("close").addEventListener("click", () => closeCurrentWindow());

for (const id of ["source", "target"] as const) {
  element<HTMLSelectElement>(id).addEventListener("change", () => {
    void showBalancesOf(Number(element<HTMLSelectElement>(id).value) || 0);
  });
}

/// **Tous les mots de la fenêtre, posés en un seul endroit.**
///
/// Une fenêtre de Radinus est bâtie une fois et jamais détruite : changer de
/// langue ne la reconstruit pas, il faut qu'elle sache se rhabiller. Ce qui
/// pose un mot est donc ici et nulle part ailleurs — une étiquette ajoutée
/// demain suivra la langue sans que personne y pense.
///
/// **Elle ne vide jamais rien.** `reset()` est le rechargement de cette
/// fenêtre, mais il est aussi ce qui la met à neuf : l'appeler ici jetterait un
/// virement à moitié saisi parce qu'on a changé de langue. Ne sont donc reposés
/// que les mots, et la phrase des trois soldes, qui vient du noyau.
async function dress(alsoTheNumbers = true): Promise<void> {
  for (const [id, key] of [
    ["group-source", "transfer-group-source"],
    ["group-target", "transfer-group-target"],
    ["group-description", "transfer-group-description"],
    ["group-nomenclature", "transfer-group-nomenclature"],
    ["group-amount", "transfer-group-amount"],
    ["source-label", "transfer-field-source"],
    ["target-label", "transfer-field-target"],
    ["label-label", "transfer-field-label"],
    ["reference-label", "transfer-field-reference"],
    ["date-label", "transfer-field-date"],
    ["status-label", "transfer-field-status"],
    ["clearing-date-label", "transfer-field-clearing"],
    ["category-label", "transfer-field-category"],
    ["payment-mode-label", "transfer-field-mode"],
    ["assignment-label", "transfer-field-assignment"],
    ["payee-label", "transfer-field-payee"],
    ["project-label", "transfer-field-project"],
    ["amount-label", "transfer-field-amount"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  element<HTMLElement>("validate").title = t("transfer-title-validate");
  element<HTMLElement>("close").title = t("ui-title-close");
  if (alsoTheNumbers) {
    await showBalancesOf(showing);
  }
}

/// Redemandée par le menu alors qu'elle est déjà là : elle est bâtie une fois
/// et jamais détruite, donc elle se remet à neuf elle-même. Sans cette écoute
/// elle garderait la saisie d'un virement abandonné et l'on croirait la
/// retrouver vierge.
void listen("window-parameters:transfer", () => {
  reset();
  say(t("transfer-help"));
});

void (async () => {
  await loadTexts(null);
  await dress(false);

  // Le champ d'argent partagé, **mais sans sa touche de signe** : le montant
  // d'un virement est une grandeur, et l'on ne transfère pas −250 €.
  const amount = element<HTMLInputElement>("amount");
  asMoneyField(amount);
  amount.addEventListener(SIGN_CHANGED, () => {
    amount.value = amount.value.replace("-", "");
  });

  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    element<HTMLButtonElement>("validate").disabled = true;
    return;
  }

  accounts = await invoke<Item[]>("list_accounts");
  combos = await invoke<Combos>("list_operation_combos");
  statuses = await invoke<Item[]>("list_operation_statuses");
  reset();
  say(t("transfer-help"));
  onLanguageChanged(dress, { key: "window-transfer-title" });
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
  for (const [id, list] of NOMENCLATURES) {
    const menu = element<HTMLSelectElement>(id);
    fill(menu, combos?.[list] ?? [], Number(menu.value));
  }
});
