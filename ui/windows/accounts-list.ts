// F04 — « Gestion des comptes bancaires », and F06, the same window in its
// choosing mode.
//
// Built on the nomenclature list, which Fabrice validated on 25/07/2026, and
// on the same shared table (`table.ts`): the door as the only way out, the
// question asked before anything is destroyed, the refusal when the fiche of
// the account is open, and the reload when the data moves.
//
// Two things it has that a nomenclature list has not. Seven columns instead of
// one, each with its own funnel — the original's capture shows a funnel per
// column. And the three balances beside each account, which the author asked
// for on 25/07/2026: pointed, pointed + committed, and final. They are read,
// never typed: the core computes them from the operations.
//
// **Deleting an account destroys history.** Its operations go with it — the
// only place in Radinus where that happens — so the question says how many.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askForWord, askYesNo } from "./dialog";
import { Table } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

/// **Une page, trois usages** — gérer les comptes (F04), en choisir **un**
/// pour ouvrir ses opérations, en choisir **plusieurs** pour une statistique
/// (F06, troisième usage confirmé par Fabrice le 26/07/2026). L'usage arrive
/// dans l'adresse et ne change jamais : ce sont trois fenêtres, pas une
/// fenêtre dans trois états.
const PURPOSE = new URLSearchParams(window.location.search).get("mode") ?? "CRUD";
/// On vient choisir, quel que soit le nombre.
const SELECTING = PURPOSE === "SEL" || PURPOSE === "STATS";
/// Et l'on n'en choisit qu'un seul : la liste des opérations ne montre jamais
/// deux comptes à la fois. Une statistique, elle, les synthétise.
const ONE_ACCOUNT = PURPOSE === "SEL";

/// **Sur quel axe la statistique demandée porte** — catégories, tiers, projets…
/// La question « sur quels comptes ? » est la même pour les six, alors le
/// chooser est unique et l'axe voyage avec la demande. Il change d'une demande
/// à l'autre, donc il se relit à chaque fois : c'est exactement la faute qu'on
/// a payée le 26/07/2026 sur la statistique elle-même, qui gardait les comptes
/// de sa première ouverture.
let axis = new URLSearchParams(window.location.search).get("axis") ?? "category";

/// **Ce qu'on vient faire du compte unique choisi.** Deux fenêtres n'en
/// demandent qu'un — la liste des opérations (F02) et la classification rapide
/// (F05) — et elles posent exactement la même question, donc elles partagent le
/// même chooser. Sans ce paramètre, choisir un compte ouvrirait toujours la
/// même des deux, quelle que soit l'entrée de menu cliquée : c'est mot pour mot
/// la faute des six statistiques du 26/07/2026, où l'étiquette savait et
/// l'adresse non.
///
/// Il se relit à chaque redemande, comme l'axe, parce qu'il change d'une
/// demande à l'autre.
let target = new URLSearchParams(window.location.search).get("target") ?? "operations";

const LABEL =
  PURPOSE === "STATS" ? "accounts-stats" : SELECTING ? "accounts-select" : "accounts-list";
const PARAMETERS_EVENT = `window-parameters:${LABEL}`;
const CHANGED_EVENT = `data-changed:${LABEL}`;

interface AccountRow {
  id: number;
  label: string;
  bank: string;
  account_type: string;
  account_number: string;
  balance_bank: number;
  balance_real: number;
  balance_final: number;
  balance_bank_text: string;
  balance_real_text: string;
  balance_final_text: string;
  is_closed: boolean;
}

interface DeletionPlan {
  refused: boolean;
  refusal: string;
  needs_confirmation: boolean;
  question: string;
  /// La seconde question, à laquelle on répond en **écrivant un mot**. Vide
  /// quand une seule suffit — c'est le noyau qui décide, pas la fenêtre.
  second_question: string;
  /// Le mot qui y répond, dans la langue de l'interface.
  confirmation_word: string;
  operations: number;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

/// Ce que la barre d'état dit selon l'usage : l'aide de la sélection multiple
/// n'a rien à faire là où l'on ne choisit qu'une ligne — elle expliquerait un
/// geste qui n'y existe pas.
function helpLine(): string {
  if (ONE_ACCOUNT) {
    return t("accounts-choose-question");
  }
  return PURPOSE === "STATS"
    ? t("accounts-stats-multiselect-help")
    : t("accounts-multiselect-help");
}

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

const table = new Table<AccountRow>({
  container: element<HTMLDivElement>("rows"),
  columns: [
    { title: () => t("accounts-column-label"), cell: (row) => row.label, width: "1.6fr" },
    { title: () => t("accounts-column-bank"), cell: (row) => row.bank, width: "1.4fr" },
    { title: () => t("accounts-column-type"), cell: (row) => row.account_type, width: "1.6fr" },
    {
      title: () => t("accounts-column-number"),
      cell: (row) => row.account_number,
      width: "1fr",
    },
    {
      title: () => t("accounts-column-bank-balance"),
      cell: (row) => row.balance_bank_text,
      key: (row) => row.balance_bank,
      money: (row) => row.balance_bank,
      numeric: true,
      width: "1.1fr",
    },
    {
      title: () => t("accounts-column-real-balance"),
      cell: (row) => row.balance_real_text,
      key: (row) => row.balance_real,
      money: (row) => row.balance_real,
      numeric: true,
      width: "1.1fr",
    },
    {
      title: () => t("accounts-column-final-balance"),
      cell: (row) => row.balance_final_text,
      key: (row) => row.balance_final,
      money: (row) => row.balance_final,
      numeric: true,
      width: "1.1fr",
    },
  ],
  identity: (row) => row.id,
  // **Choisir un compte, c'est en choisir un seul** (Fabrice, 26/07/2026) :
  // la fenêtre des opérations ne montre jamais que les opérations d'un compte
  // à la fois, donc en cocher deux offrirait un choix qu'on ne peut pas
  // honorer. En gestion (F04), la sélection multiple garde son sens : on
  // supprime plusieurs comptes d'un coup.
  singleSelection: ONE_ACCOUNT,
  // A closed account is still shown, and greyed: it is history, not a place
  // to put an operation.
  rowClass: (row) => (row.is_closed ? "list__row--closed" : null),
  exportAs: () => ({ name: t("accounts-column-account"), detail: t("accounts-column-label") }),
  emptyText: () => t("accounts-none"),
  filteredOutText: () => t("ui-no-match"),
  // L'aide de la sélection multiple n'a rien à faire dans une fenêtre où l'on
  // ne choisit qu'une ligne : elle expliquerait un geste qui n'y existe pas.
  onSelectionChange: () => say(helpLine()),
  onActivate: () => void (SELECTING ? chooseAccount() : openForm("M")),
});

/// The original refuses every action needing a record when none is selected,
/// with this exact wording (`Ouvre_Fiche`).
function requireSelection(): boolean {
  if (table.selected().length === 0) {
    say(t("ui-select-record"), true);
    return false;
  }
  return true;
}

async function checkStartup(): Promise<boolean> {
  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    for (const id of ["create", "update", "delete", "read"]) {
      element<HTMLButtonElement>(id).disabled = true;
    }
    table.setRows([]);
    return false;
  }
  return true;
}

async function reload(): Promise<void> {
  try {
    table.setRows(await invoke<AccountRow[]>("list_accounts"));
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

async function openForm(mode: "A" | "M" | "L"): Promise<void> {
  if (mode !== "A" && !requireSelection()) {
    return;
  }
  try {
    await invoke("open_account_form", {
      mode,
      id: mode === "A" ? null : table.selected()[0],
    });
  } catch (error) {
    say(tError("ui-open-failed", error), true);
  }
}

async function deleteSelection(): Promise<void> {
  if (!requireSelection()) {
    return;
  }
  try {
    const plan = await invoke<DeletionPlan>("plan_account_deletion", {
      ids: table.selected(),
    });
    if (plan.refused) {
      say(plan.refusal, true);
      return;
    }
    if (plan.needs_confirmation) {
      if (!(await askYesNo(plan.question, t("ui-yes"), t("ui-no")))) {
        say(t("ui-deletion-abandoned"));
        return;
      }
    }
    // **La seconde barrière** (décision de Fabrice, 26/07/2026). Supprimer un
    // compte emporte tout son historique : un Oui/Non se clique sans lire,
    // écrire le mot oblige à s'arrêter. La phrase et le mot viennent du
    // noyau — la fenêtre ne sait même pas dans quelle langue elle demande.
    if (plan.second_question !== "") {
      if (
        !(await askForWord(
          plan.second_question,
          plan.confirmation_word,
          t("ui-yes"),
          t("ui-no"),
        ))
      ) {
        say(t("ui-deletion-abandoned"));
        return;
      }
    }
    const deleted = await invoke<number>("delete_accounts", { ids: table.selected() });
    table.clearSelection();
    await reload();
    say(await invoke<string>("accounts_deleted_text", { count: deleted }));
  } catch (error) {
    say(tError("ui-delete-failed", error), true);
  }
}

/// F06's own action: the chosen account is handed to whoever asked. Today
/// there is one asker — « Gérer les opérations d'un compte » — so choosing
/// opens its operations. When the statistics come (phase 6), this is where
/// the answer will be routed to them instead.
async function chooseAccount(): Promise<void> {
  if (!requireSelection()) {
    return;
  }
  try {
    if (PURPOSE === "STATS") {
      // La statistique fait la synthèse de **tous** les comptes choisis.
      // Le tableau de bord passe par la même question que les six
      // statistiques, et voyage sous le même paramètre — mais ce n'est pas un
      // axe, c'est une autre fenêtre.
      if (axis === "dashboard") {
        await invoke("open_dashboard", { accountIds: table.selected() });
        return;
      }
      if (axis === "curves") {
        await invoke("open_balance_curves", { accountIds: table.selected() });
        return;
      }
      // L'analyse de l'évolution du solde (F40) : la même question que le
      // graphique, et une autre fenêtre.
      if (axis === "analysis") {
        await invoke("open_balance_analysis", { accountIds: table.selected() });
        return;
      }
      // Le bilan croisé (F39) emprunte la même porte : il se calcule lui aussi
      // sur plusieurs comptes, mais ses deux axes sont fixés par ce qu'il est.
      if (axis === "crossed-balance") {
        await invoke("open_crossed_balance", { accountIds: table.selected() });
        return;
      }
      await invoke("open_statistics", { axis, accountIds: table.selected() });
      return;
    }
    if (target === "quick-classify") {
      await invoke("open_quick_classification", { accountId: table.selected()[0] });
      return;
    }
    if (target === "statement-import") {
      await invoke("open_statement_import", { accountId: table.selected()[0] });
      return;
    }
    // L'import Excel emprunte la même porte : on importe toujours **dans** un
    // compte, jamais « quelque part » (première étape de la marche à suivre
    // dictée par Fabrice le 29/07/2026).
    if (target === "excel-import") {
      await invoke("open_excel_import", { accountId: table.selected()[0] });
      return;
    }
    // F32 — le RIB porte sur un compte, et un seul : on le choisit ici avant
    // que la fenêtre d'impression ne s'ouvre (Fabrice, 01/08/2026).
    if (target === "bank-details") {
      await invoke("open_bank_details", { accountId: table.selected()[0] });
      return;
    }
    await invoke("open_operations_list", { accountId: table.selected()[0] });
  } catch (error) {
    say(tError("ui-open-failed", error), true);
  }
}

/// La porte. La fiche peut être ouverte par-dessus avec une saisie dedans, et
/// fermer cette liste l'emporterait — la question se pose donc ici.
///
/// **Elle dit laquelle des deux fenêtres se ferme.** Les deux modes partagent
/// cette page mais sont deux fenêtres distinctes, portant deux étiquettes
/// différentes ; sans le dire, la fermeture masquait toujours la liste de
/// gestion, et la fenêtre de choix restait à l'écran, porte inerte, sans
/// aucun moyen d'en sortir (anomalie signalée par Fabrice, 26/07/2026).
async function leave(): Promise<void> {
  try {
    if (await invoke<boolean>("accounts_list_has_unsaved_changes")) {
      if (!(await askYesNo(t("ui-discard-question"), t("ui-yes"), t("ui-no")))) {
        return;
      }
    }
    await invoke("accounts_list_may_close", { purpose: PURPOSE });
  } catch (error) {
    say(tError("ui-close-failed", error), true);
  }
}

element<HTMLButtonElement>("create").addEventListener("click", () => void openForm("A"));
element<HTMLButtonElement>("update").addEventListener("click", () => void openForm("M"));
element<HTMLButtonElement>("read").addEventListener("click", () => void openForm("L"));
element<HTMLButtonElement>("delete").addEventListener("click", () => void deleteSelection());
element<HTMLButtonElement>("close").addEventListener("click", () => void leave());

// Le bouton « Choisir » n'existe que dans les deux modes de choix. Son écoute
// se pose ici, une fois pour toutes, et non avec ses mots : la fenêtre se
// rhabille à chaque changement de langue, et un bouton qui se rebrancherait à
// chaque fois finirait par ouvrir deux fenêtres d'un seul clic.
if (SELECTING) {
  element<HTMLButtonElement>("select").addEventListener("click", () => void chooseAccount());
}

void listen(CHANGED_EVENT, () => void reload());
void listen<string>(PARAMETERS_EVENT, (event) => {
  // Redemandée pour une autre statistique, ou pour l'autre fenêtre à compte
  // unique : ce qu'on vient chercher change, la question non.
  const parameters = new URLSearchParams(event.payload);
  const asked = parameters.get("axis");
  if (asked !== null) {
    axis = asked;
  }
  const wanted = parameters.get("target");
  if (wanted !== null) {
    target = wanted;
  }
  table.clearSelection();
  void reload();
});

/// Pose les mots de la fenêtre, à l'ouverture et à chaque changement de
/// langue. Elle finit par relire les comptes : les trois soldes de chaque
/// ligne sont écrits par le noyau, séparateurs compris.
async function dress(): Promise<void> {
  table.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));
  table.exportOnRightClick(say);
  say(helpLine());

  for (const [id, key] of [
    ["create", "ui-title-create"],
    ["update", "ui-title-update"],
    ["delete", "ui-title-delete"],
    ["read", "ui-title-read"],
    ["close", "ui-title-close"],
  ] as const) {
    element<HTMLElement>(id).title = t(key);
  }

  if (SELECTING) {
    // F06: the question above the table, and no CRUD — one only chooses.
    const question = element<HTMLElement>("question");
    question.textContent = ONE_ACCOUNT
      ? t("accounts-choose-question")
      : t("accounts-select-question");
    question.hidden = false;
    // La consultation n'a rien à faire ici non plus (Fabrice, 26/07/2026) :
    // on vient choisir un compte pour ouvrir ses opérations, pas pour lire sa
    // fiche. Il ne reste que choisir et sortir.
    for (const id of ["create", "update", "delete", "read"]) {
      element<HTMLButtonElement>(id).hidden = true;
    }
    if (ONE_ACCOUNT) {
      // Le tableau ne se dit plus à sélection multiple : il ne l'est plus.
      element<HTMLElement>("rows").setAttribute("aria-multiselectable", "false");
    }
    const choose = element<HTMLButtonElement>("select");
    choose.hidden = false;
    choose.title = t("ui-title-select");
  }

  if (await checkStartup()) {
    await reload();
  }
}

// Its words before anything else.
void (async () => {
  await loadTexts(null);
  await dress();
  // Trois usages, deux titres : on gère des comptes, ou l'on en choisit —
  // c'est la même distinction que fait `AccountsPurpose::title_key`.
  onLanguageChanged(dress, {
    key: SELECTING ? "window-accounts-select-title" : "window-accounts-title",
  });
})();
