// F31 — « Parametres chequier ».
//
// Portage de `Code Fiche Chequier.txt`. En ajout, la date part à aujourd'hui
// (`SAI_Reception = DateDuJour()`) et le bouton dit « Ajouter ». En
// modification, `GR_InterditModif` est grisé : **cinq champs se figent**.
//
// **Enregistrer un carnet neuf crée aussi tous ses chèques** — c'est
// `Genere_Cheques`, appelée juste après le `HAjoute`, et c'est pour cela que la
// numérotation ne se modifie plus ensuite.
//
// **Huit barrières avant d'écrire**, portage de son « Precauttion
// enregistrement cheque.txt » : référence en double, référence vide, numéros
// au-dessus de 999 999 999, date invalide, les deux numéros à zéro, premier
// au-dessus du dernier, compte non choisi, et le plafond de mille chèques.
// Elles vivent dans le noyau et la fenêtre les pose avant d'enregistrer,
// comme son bouton le fait.
//
// **Le nombre de chèques se calcule** — c'est l'écart des deux bornes, il se
// remplit pendant la frappe et ne se saisit pas. C'est ce qui donne son sens
// au plafond : « SI SAI_NbrChq>1000 » ne bornerait rien s'il portait sur un
// nombre sans rapport avec ce qui sera généré.
//
// Et à l'ajout, sa demande de confirmation récapitule tout avant d'écrire :
// « Attention ces données ne seront pas modifiables après création ! »
//
// **Enregistrer referme la fiche**, dans les deux modes : la dernière ligne de
// ses précautions est `SI Action_Confirmer() ALORS Ferme() FIN`.

import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askYesNo } from "./dialog";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

const PARAMETERS_EVENT = "window-parameters:chequebook-form";

interface Chequebook {
  id: number;
  reference: string;
  received_on: string;
  first_number: number;
  last_number: number;
  quantity: number;
  comments: string;
  account_id: number;
  account_missing: boolean;
}

interface Account {
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

/// « A » ajouter, « M » modifier — son vocabulaire.
let mode: "A" | "M" = "A";
let recordId = 0;

/// Les cinq champs de `GR_InterditModif`. Nommés **une seule fois** ici, et
/// employés partout ailleurs : une liste recopiée est une liste qui finit par
/// diverger de l'autre.
const FROZEN = ["reference", "received", "first", "last", "quantity"] as const;

/// Le nombre de chèques n'est **jamais** saisissable, dans aucun des deux
/// modes : il se calcule. Il est dans le groupe gelé pour la modification, et
/// en lecture seule dès la création.
const ALWAYS_COMPUTED = "quantity";

/// Ce que les deux bornes produiront. Le même calcul que le noyau — et il est
/// **croisé** avec lui par un test : deux endroits qui comptent la même chose
/// doivent la compter pareil.
function chequesBetween(first: number, last: number): number {
  return last < first ? 0 : last - first + 1;
}

/// Remplit « Nombre de chèques » depuis les deux numéros. Appelé à chaque
/// frappe : le champ suit, il ne se tape pas.
function refreshQuantity(): void {
  const first = Number(element<HTMLInputElement>("first").value) || 0;
  const last = Number(element<HTMLInputElement>("last").value) || 0;
  element<HTMLInputElement>("quantity").value = String(chequesBetween(first, last));
}

function today(): string {
  const now = new Date();
  const month = `${now.getMonth() + 1}`.padStart(2, "0");
  const day = `${now.getDate()}`.padStart(2, "0");
  return `${now.getFullYear()}-${month}-${day}`;
}

/// `Maj_Controles` : ce que la fiche laisse faire, selon le mode.
function applyMode(): void {
  const frozen = mode === "M";
  for (const id of FROZEN) {
    const field = element<HTMLInputElement>(id);
    field.readOnly = frozen || id === ALWAYS_COMPUTED;
    field.classList.toggle("form__field--locked", frozen);
  }
  element<HTMLElement>("save").title = t(mode === "A" ? "ui-title-add" : "ui-title-modify");
}

async function loadAccounts(chosen: number): Promise<void> {
  const menu = element<HTMLSelectElement>("account");
  menu.replaceChildren();
  const accounts = await invoke<Account[]>("list_accounts");
  for (const account of accounts) {
    const entry = document.createElement("option");
    entry.value = String(account.id);
    entry.textContent = account.label;
    menu.append(entry);
  }
  menu.value = String(chosen);
}

async function load(): Promise<void> {
  try {
    if (mode === "A") {
      element<HTMLInputElement>("id").value = "0";
      element<HTMLInputElement>("reference").value = "";
      // `SAI_Reception = DateDuJour()` — la seule valeur qu'il préremplit.
      element<HTMLInputElement>("received").value = today();
      element<HTMLInputElement>("first").value = "0";
      element<HTMLInputElement>("last").value = "0";
      refreshQuantity();
      element<HTMLTextAreaElement>("comments").value = "";
      await loadAccounts(0);
      applyMode();
      say("");
      return;
    }

    const book = await invoke<Chequebook | null>("get_chequebook", { id: recordId });
    if (!book) {
      say(t("chequebooks-gone"), true);
      return;
    }
    element<HTMLInputElement>("id").value = String(book.id);
    element<HTMLInputElement>("reference").value = book.reference;
    element<HTMLInputElement>("received").value = book.received_on;
    element<HTMLInputElement>("first").value = String(book.first_number);
    element<HTMLInputElement>("last").value = String(book.last_number);
    element<HTMLInputElement>("quantity").value = String(book.quantity);
    element<HTMLTextAreaElement>("comments").value = book.comments;
    await loadAccounts(book.account_id);
    applyMode();
    // Sa phrase, à l'ouverture, quand le compte a disparu — le lien est souple
    // et sans cascade, donc le cas arrive vraiment.
    say(
      book.account_missing ? t("chequebook-account-missing") : t("chequebook-locked"),
      book.account_missing,
    );
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

async function save(): Promise<void> {
  try {
    const accountId = Number(element<HTMLSelectElement>("account").value) || 0;
    const comments = element<HTMLTextAreaElement>("comments").value;
    const reference = element<HTMLInputElement>("reference").value;
    const receivedOn = element<HTMLInputElement>("received").value;
    const firstNumber = Number(element<HTMLInputElement>("first").value) || 0;
    const lastNumber = Number(element<HTMLInputElement>("last").value) || 0;

    // **Les huit précautions, avant tout le reste.** Le noyau les pose dans
    // son ordre à lui, et rend la première qui refuse — l'ordre décide de ce
    // que l'on voit quand deux choses vont mal ensemble.
    const refusal = await invoke<string | null>("chequebook_refusal", {
      adding: mode === "A",
      reference,
      receivedOn,
      firstNumber,
      lastNumber,
      accountId,
    });
    if (refusal) {
      say(refusal, true);
      return;
    }

    if (mode === "M") {
      // Seuls le compte et les commentaires : les cinq figés ne sont même pas
      // envoyés, si bien que rien ne peut les changer par erreur.
      if (!(await invoke<boolean>("update_chequebook", { id: recordId, accountId, comments }))) {
        say(t("chequebooks-gone"), true);
        return;
      }
      await invoke("notify_cheques_changed");
      await invoke("close_cheque_window", { label: "chequebook-form" });
      return;
    }

    // Sa demande de confirmation : elle récapitule ce qui va être créé, et
    // prévient que rien n'en sera modifiable ensuite. À l'ajout seulement.
    const question = await invoke<string>("chequebook_creation_question", {
      firstNumber,
      lastNumber,
    });
    if (!(await askYesNo(question, t("ui-yes"), t("ui-no")))) {
      return;
    }

    const created = await invoke<number | null>("create_chequebook", {
      reference,
      receivedOn,
      firstNumber,
      lastNumber,
      accountId,
      comments,
    });
    // La base est la dernière barrière, jamais la première : si elle refuse
    // ici, c'est que la fenêtre s'est trompée, et il n'y a rien à expliquer à
    // l'utilisateur qu'elle n'ait déjà dit.
    if (created === null) {
      say(t("chequebook-refusal-duplicate"), true);
      return;
    }
    await invoke("notify_cheques_changed");
    await invoke("close_cheque_window", { label: "chequebook-form" });
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

function readParameters(query: string): void {
  const parameters = new URLSearchParams(query);
  mode = parameters.get("mode") === "M" ? "M" : "A";
  recordId = Number(parameters.get("id") ?? 0);
}

for (const id of ["first", "last"]) {
  element<HTMLInputElement>(id).addEventListener("input", () => refreshQuantity());
}

element<HTMLButtonElement>("save").addEventListener("click", () => void save());
element<HTMLButtonElement>("close").addEventListener("click", () => {
  void invoke("close_cheque_window", { label: "chequebook-form" }).catch((error) =>
    say(tError("ui-close-failed", error), true),
  );
});

void listen<string>(PARAMETERS_EVENT, (event) => {
  readParameters(event.payload);
  void load();
});

/// La base a-t-elle pu s'ouvrir ? Sans elle il n'y a aucun carnet à lire, et
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
/// **Elle ne relit jamais le carnet.** Une référence à demi tapée, deux bornes
/// que l'on venait de corriger, ne doivent pas disparaître parce qu'on a changé
/// de langue : seules les étiquettes et les bulles se reposent.
function dress(): void {
  for (const [id, key] of [
    ["id-label", "chequebook-field-id"],
    ["reference-label", "chequebook-field-reference"],
    ["received-label", "chequebook-field-received"],
    ["first-label", "chequebook-field-first"],
    ["last-label", "chequebook-field-last"],
    ["quantity-label", "chequebook-field-quantity"],
    ["account-label", "chequebook-field-account"],
    ["comments-label", "chequebook-field-comments"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  element<HTMLElement>("close").title = t("ui-title-close");
  // La bulle d'Enregistrer dit « Ajouter » ou « Modifier » : c'est un mot, et
  // il dépend du mode. `Maj_Controles` la repose sans toucher à une seule case
  // de la saisie — elle ne fait qu'appliquer le mode en vigueur, jamais en
  // changer.
  applyMode();
}

void (async () => {
  await loadTexts(null);
  dress();

  if (await checkStartup()) {
    readParameters(window.location.search);
    await load();
  }
  onLanguageChanged(dress, { key: "window-chequebook-title" });
})();
