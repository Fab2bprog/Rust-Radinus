// F12 — « Fiche chèques ».
//
// Portage de `Code Fiche Cheque.txt`. La fiche n'a qu'un mode utile : la
// modification. Un chèque n'est jamais ajouté ici — il naît avec son carnet
// (`Genere_Cheques`) — ni supprimé, puisque le panneau de F14 n'a pas de
// bouton pour cela.
//
// L'identifiant et le numéro sont en lecture seule : ils viennent du carnet.
//
// **Le statut ne bouge que si on le change.** Remplir le bénéficiaire et le
// montant ne fait pas passer le chèque à « Émis » ; c'est son original, et
// Fabrice l'a confirmé le 28/07/2026.
//
// **Enregistrer referme la fiche** : chez lui, `Action_Confirmer()` est suivi
// d'un `Ferme()`. La fiche a fait ce qu'on lui demandait ; y rester donnerait à
// croire qu'il reste un geste à faire.

import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { asMoneyField } from "./money-field";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

const PARAMETERS_EVENT = "window-parameters:cheque-form";

interface Cheque {
  id: number;
  number: string;
  issued_on: string;
  place: string;
  payee: string;
  amount_text: string;
  comments: string;
  status_id: number;
}

interface Item {
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

let recordId = 0;

/// Le montant tapé, en micro-unités. Le champ ne porte qu'une grandeur : le
/// montant d'un chèque est positif (02_BASE_DE_DONNEES.md §3.6), le sens est
/// porté par l'opération qu'on lui associera.
function typedAmount(): number {
  const written = element<HTMLInputElement>("amount").value.replace(/[^0-9.,]/g, "");
  const separator = written.lastIndexOf(",") > written.lastIndexOf(".") ? "," : ".";
  const [whole, decimals = ""] = written.split(separator);
  const units = Number(whole.replace(/[^0-9]/g, "")) || 0;
  const fraction = Number(`${decimals}000000`.slice(0, 6)) || 0;
  return units * 1_000_000 + fraction;
}

async function load(): Promise<void> {
  try {
    const cheque = await invoke<Cheque | null>("get_cheque", { id: recordId });
    if (!cheque) {
      say(t("cheque-gone"), true);
      return;
    }
    element<HTMLInputElement>("id").value = String(cheque.id);
    element<HTMLInputElement>("number").value = cheque.number;
    element<HTMLInputElement>("issued").value = cheque.issued_on;
    element<HTMLInputElement>("place").value = cheque.place;
    element<HTMLInputElement>("payee").value = cheque.payee;
    element<HTMLInputElement>("amount").value = cheque.amount_text;
    element<HTMLInputElement>("comments").value = cheque.comments;
    element<HTMLSelectElement>("status").value = String(cheque.status_id);
    say("");
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

async function save(): Promise<void> {
  try {
    const changed = await invoke<boolean>("update_cheque", {
      id: recordId,
      issuedOn: element<HTMLInputElement>("issued").value,
      place: element<HTMLInputElement>("place").value,
      payee: element<HTMLInputElement>("payee").value,
      amount: typedAmount(),
      comments: element<HTMLInputElement>("comments").value,
      statusId: Number(element<HTMLSelectElement>("status").value) || 1,
    });
    if (!changed) {
      say(t("cheque-gone"), true);
      return;
    }
    await invoke("notify_cheques_changed");
    // **Enregistrer, c'est aussi sortir.** Son `Action_Confirmer()` est suivi
    // d'un `Ferme()` : la fiche a fait ce qu'on lui demandait, elle n'a plus
    // rien à montrer. Rester dessus laisse croire qu'il reste quelque chose à
    // faire (anomalie signalée par Fabrice, 29/07/2026).
    await invoke("close_cheque_window", { label: "cheque-form" });
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

function readParameters(query: string): void {
  recordId = Number(new URLSearchParams(query).get("id") ?? 0);
  history.replaceState(null, "", `?id=${recordId}`);
}

element<HTMLButtonElement>("save").addEventListener("click", () => void save());
element<HTMLButtonElement>("close").addEventListener("click", () => {
  void invoke("close_cheque_window", { label: "cheque-form" }).catch((error) =>
    say(tError("ui-close-failed", error), true),
  );
});

void listen<string>(PARAMETERS_EVENT, (event) => {
  readParameters(event.payload);
  void load();
});

/// La base a-t-elle pu s'ouvrir ? Sans elle il n'y a aucun chèque à lire, et
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
/// **Elle ne relit jamais le chèque.** Une fiche est un brouillon tant qu'on
/// n'a pas enregistré : le bénéficiaire à demi tapé, le montant corrigé,
/// disparaîtraient pour la seule raison qu'on a changé de langue. Seules les
/// étiquettes et les bulles se reposent ; ce qui est dans les cases appartient
/// à celui qui le tape.
function dress(): void {
  for (const [id, key] of [
    ["id-label", "cheque-field-id"],
    ["number-label", "cheque-field-number"],
    ["issued-label", "cheque-field-issued"],
    ["place-label", "cheque-field-place"],
    ["payee-label", "cheque-field-payee"],
    ["amount-label", "cheque-field-amount"],
    ["comments-label", "cheque-field-comments"],
    ["status-label", "cheque-field-status"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  element<HTMLElement>("save").title = t("ui-title-save");
  element<HTMLElement>("close").title = t("ui-title-close");
}

void (async () => {
  await loadTexts(null);
  dress();
  // Le champ d'argent partagé, comme partout ailleurs : il refuse au clavier
  // ce qui ne peut pas être un montant. Il se branche une fois, hors des mots :
  // rebrancher un écouteur à chaque changement de langue le ferait répondre
  // deux fois.
  asMoneyField(element<HTMLInputElement>("amount"));

  if (await checkStartup()) {
    const menu = element<HTMLSelectElement>("status");
    for (const status of await invoke<Item[]>("list_cheque_statuses")) {
      const entry = document.createElement("option");
      entry.value = String(status.id);
      entry.textContent = status.label;
      menu.append(entry);
    }

    readParameters(window.location.search);
    await load();
  }
  onLanguageChanged(dress, { key: "window-cheque-title" });
})();
