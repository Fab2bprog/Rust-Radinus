// F07 — « Soldes de vos comptes ».
//
// Compte / En Banque / Réel / Final, one line per account, then TOTAL in
// bold. **Closed accounts are left out** (04_SPECIFICATIONS_FENETRES.md):
// they no longer hold anything one can act on, and adding them to the total
// would say the household owns money it closed years ago.
//
// The three columns are cumulative, and the author put it in one line
// (25/07/2026): en banque is the pointed balance, réel is pointed plus
// committed, final is pointed plus committed plus planned.
//
// Nothing is done here — the right panel holds the door alone.

import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { Table } from "./table";
import { closeCurrentWindow } from "./window-frame";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

interface AccountRow {
  id: number;
  label: string;
  balance_bank: number;
  balance_real: number;
  balance_final: number;
  balance_bank_text: string;
  balance_real_text: string;
  balance_final_text: string;
  is_closed: boolean;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

/// The TOTAL line is a row of the table like any other, marked out by its
/// identifier: `0` is never a real account, the key generator starts at 1.
const TOTAL_ROW = 0;

const table = new Table<AccountRow>({
  container: element<HTMLDivElement>("rows"),
  columns: [
    { title: () => t("accounts-column-account"), cell: (row) => row.label, width: "1.6fr" },
    {
      title: () => t("accounts-column-bank-balance"),
      cell: (row) => row.balance_bank_text,
      key: (row) => row.balance_bank,
      numeric: true,
    },
    {
      title: () => t("accounts-column-real-balance"),
      cell: (row) => row.balance_real_text,
      key: (row) => row.balance_real,
      numeric: true,
    },
    {
      title: () => t("accounts-column-final-balance"),
      cell: (row) => row.balance_final_text,
      key: (row) => row.balance_final,
      numeric: true,
    },
  ],
  identity: (row) => row.id,
  rowClass: (row) => (row.id === TOTAL_ROW ? "list__row--total" : null),
  emptyText: () => t("accounts-none"),
  filteredOutText: () => t("ui-no-match"),
  onActivate: (row) => open(row),
});

/// **Double-cliquer un compte ouvre ses opérations** (Fabrice, 05/08/2026 :
/// « la version WinDev le faisait »).
///
/// La ligne **TOTAL** n'ouvre rien, et c'est le seul cas à écarter : c'est une
/// somme et non un compte, il n'existe aucune liste d'opérations derrière
/// elle. Les comptes clôturés ne se posent pas la question — ils ne figurent
/// pas dans ce tableau.
///
/// La commande est celle des tuiles de la fenêtre d'accueil, sans rien de
/// nouveau : deux endroits qui font le même geste passent par la même porte.
function open(row: AccountRow): void {
  if (row.id === TOTAL_ROW) {
    return;
  }
  void invoke("open_operations_list", { accountId: row.id }).catch((error) => {
    say(tError("ui-open-failed", error), true);
  });
}

async function reload(): Promise<void> {
  try {
    const rows = await invoke<AccountRow[]>("list_accounts");
    const total = await invoke<AccountRow>("accounts_total");
    table.setRows([...rows.filter((row) => !row.is_closed), total]);
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

element<HTMLButtonElement>("close").addEventListener("click", () => closeCurrentWindow());

window.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    event.preventDefault();
    closeCurrentWindow();
  }
});

/// Pose les mots de la fenêtre. Appelée à l'ouverture et à chaque changement
/// de langue : ce qu'elle montre n'est pas seulement écrit en français ou en
/// anglais, il est **calculé** dans cette langue — les montants ont leurs
/// séparateurs et le TOTAL vient du noyau —, alors elle relit ses soldes.
///
/// L'échec de démarrage reste dedans, à sa place : sans base il n'y a rien à
/// relire, et la fenêtre doit dire pourquoi elle est vide dans la langue qu'on
/// vient de choisir.
async function dress(): Promise<void> {
  table.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));
  element<HTMLElement>("close").title = t("ui-title-close");

  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    return;
  }
  await reload();
}

// **Elle ne se relisait jamais, et c'est un bug que Fabrice a constaté le
// 05/08/2026** : on note un solde, on ferme, on saisit une opération, on rouvre
// — et le solde n'a pas bougé. Une fenêtre de Radinus est bâtie une fois et
// jamais détruite ; la rouvrir ne fait que la remontrer, et celle-ci n'avait
// aucun moyen d'apprendre que les comptes avaient changé sous elle.
//
// Les deux filets sont ceux de l'accueil, et pour les mêmes raisons (voir son
// commentaire du 26/07/2026). **Les événements d'abord** : ils arrivent tout de
// suite et rafraîchissent la fenêtre même laissée ouverte pendant qu'on saisit
// ailleurs. **Le retour à l'écran ensuite**, parce qu'un événement qui n'arrive
// pas est pire que pas d'événement du tout. Relire est une lecture : elle ne
// coûte rien et ne peut rien casser.
//
// Le second filet est aussi celui qui rattrapera un changement de base : une
// fenêtre qu'on remontre reprend le focus, et ses soldes seront ceux de la base
// à laquelle on vient de se connecter, jamais ceux de la précédente.
for (const event of ["data-changed:operations", "data-changed:accounts-list"]) {
  void listen(event, () => void reload());
}
window.addEventListener("focus", () => void reload());

void (async () => {
  await loadTexts(null);
  await dress();
  onLanguageChanged(dress, { key: "window-balances-title" });
})();
