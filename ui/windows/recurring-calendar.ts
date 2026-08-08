// F16 — la proposition de calendrier.
//
// **Elle n'écrit rien tant qu'on ne le lui demande pas.** Les échéances des
// règles choisies sont calculées et montrées ; la corbeille rouge en retire ;
// le calendrier-disquette insère ce qui reste.
//
// La fenêtre ne renvoie à Rust que des **rangs** — jamais des montants ni des
// dates. La proposition vit du côté du noyau, et ce qui sera écrit est
// exactement ce qui a été proposé, moins ce que l'utilisateur a retiré : une
// copie côté navigateur serait une seconde vérité, et deux vérités finissent
// toujours par diverger.

import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askYesNo } from "./dialog";
import { Table } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

interface Row {
  rank: number;
  account: string;
  date: string;
  label: string;
  amount: number;
  amount_text: string;
  category: string;
  assignment: string;
  payment_mode: string;
  payee: string;
  project: string;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

let rules: number[] = [];
let proposed: Row[] = [];

const table = new Table<Row>({
  container: element<HTMLDivElement>("rows"),
  virtualized: true,
  rowHeight: 22,
  columns: [
    { title: () => t("recurring-calendar-column-account"), cell: (row) => row.account, width: "1fr" },
    // **Ici la date arrive déjà en ISO** — le contrôleur l'écrit en
    // `%Y-%m-%d` — donc le tri était juste sans clef. Elle est écrite quand
    // même : une colonne de date qui ne dit pas sur quoi elle se range oblige
    // le prochain lecteur à aller vérifier, et le croisement
    // `toute_colonne_de_date_dit_sur_quoi_elle_se_trie` la réclame.
    //
    // ⚠ En revanche cette colonne **affiche** l'ISO, « 2026-07-15 », là où
    // tout le reste de Radinus montre « 15/07/2026 ». Signalé à Fabrice le
    // 04/08/2026 ; il n'a rien demandé là-dessus, donc rien n'a bougé.
    {
      title: () => t("recurring-calendar-column-date"),
      cell: (row) => row.date,
      key: (row) => row.date,
      width: "120px",
    },
    { title: () => t("recurring-calendar-column-label"), cell: (row) => row.label, width: "2fr" },
    {
      title: () => t("recurring-calendar-column-amount"),
      cell: (row) => row.amount_text,
      key: (row) => row.amount,
      money: (row) => row.amount,
      numeric: true,
      width: "1fr",
    },
    { title: () => t("recurring-calendar-column-category"), cell: (row) => row.category, width: "1fr" },
    { title: () => t("recurring-calendar-column-assignment"), cell: (row) => row.assignment, width: "1fr" },
    { title: () => t("recurring-calendar-column-mode"), cell: (row) => row.payment_mode, width: "1fr" },
    { title: () => t("recurring-calendar-column-payee"), cell: (row) => row.payee, width: "1fr" },
    { title: () => t("recurring-calendar-column-project"), cell: (row) => row.project, width: "1fr" },
  ],
  identity: (row) => row.rank,
  exportAs: () => ({ name: t("window-recurring-calendar-title"), detail: "" }),
  emptyText: () => t("recurring-calendar-none"),
  filteredOutText: () => t("ui-no-match"),
  onSelectionChange: () => say(t("ui-multiselect-help")),
});

/// La corbeille rouge : elle retire de la **proposition**, pas de la base —
/// rien n'y a encore été écrit.
function removeSelection(): void {
  const chosen = table.selected();
  if (chosen.length === 0) {
    say(t("ui-select-record"), true);
    return;
  }
  proposed = proposed.filter((row) => !chosen.includes(row.rank));
  table.clearSelection();
  table.setRows(proposed);
  void (async () => {
    say(await invoke<string>("recurring_removed_text", { count: chosen.length }));
  })();
}

/// L'insertion : les rangs qui restent.
///
/// **On demande avant d'écrire** (Fabrice, 31/07/2026) : ce geste crée de
/// vraies opérations dans de vrais comptes et recalcule les soldes ; il ne doit
/// pas partir sur un clic distrait.
async function insert(): Promise<void> {
  try {
    if (proposed.length === 0) {
      say(t("recurring-nothing"));
      return;
    }
    const question = await invoke<string>("recurring_insert_question", {
      count: proposed.length,
    });
    if (!(await askYesNo(question, t("ui-yes"), t("ui-no")))) {
      say(t("recurring-calendar-help"));
      return;
    }
    const said = await invoke<string>("insert_recurring", {
      ranks: proposed.map((row) => row.rank),
    });
    say(said);
    // Ce qui est entré ne se repropose pas : la fenêtre se vide.
    proposed = [];
    table.setRows(proposed);
  } catch (error) {
    say(String(error), true);
  }
}

async function leave(): Promise<void> {
  try {
    await invoke("close_recurring_window", { label: "recurring-calendar" });
  } catch (error) {
    say(tError("ui-close-failed", error), true);
  }
}

element<HTMLButtonElement>("remove").addEventListener("click", () => removeSelection());
element<HTMLButtonElement>("insert").addEventListener("click", () => void insert());
element<HTMLButtonElement>("close").addEventListener("click", () => void leave());

async function reload(): Promise<void> {
  try {
    proposed = await invoke<Row[]>("recurring_calendar", { ids: rules });
    table.setRows(proposed);
    say(proposed.length === 0 ? t("recurring-calendar-none") : t("recurring-calendar-help"));
  } catch (error) {
    say(tError("ui-load-failed", error), true);
  }
}

function readParameters(query: string): void {
  const asked = new URLSearchParams(query).get("rules") ?? "";
  rules = asked
    .split(",")
    .map((piece) => Number(piece))
    .filter((id) => Number.isFinite(id) && id > 0);
}

/// Redemandée sur d'autres règles : la fenêtre est bâtie une fois et jamais
/// détruite, donc les nouveaux identifiants arrivent par un événement. Sans
/// cette écoute, elle proposerait éternellement le calendrier des premières.
void listen<string>("window-parameters:recurring-calendar", (event) => {
  readParameters(event.payload);
  table.clearSelection();
  void reload();
});

/// **Pose les mots de la fenêtre.** Appelée à l'ouverture, et de nouveau à
/// chaque changement de langue.
///
/// Elle ne refabrique **pas** la proposition. `recurring_calendar` la
/// recalculerait depuis les règles et remplacerait celle du noyau : les
/// échéances que la corbeille a retirées reviendraient, et l'on insérerait dans
/// de vrais comptes ce que l'utilisateur avait justement écarté. On repose donc
/// les mêmes rangs, tels qu'ils restent.
function dress(): void {
  table.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));
  element<HTMLElement>("remove").title = t("ui-title-delete");
  element<HTMLElement>("insert").title = t("recurring-title-insert");
  element<HTMLElement>("close").title = t("ui-title-close");
  if (proposed.length > 0) {
    table.setRows(proposed);
  }
}

void (async () => {
  await loadTexts(null);
  dress();
  table.exportOnRightClick(say);

  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    element<HTMLButtonElement>("insert").disabled = true;
    return;
  }
  readParameters(window.location.search);
  await reload();
  onLanguageChanged(dress, { key: "window-recurring-calendar-title" });
})();
