// Le journal de la dernière opération technique (⌘H) — phase 17.
//
// **Une fenêtre qui ne fait que lire.** Elle n'écrit rien, ne demande rien,
// n'a pas de sélection utile : elle montre les six colonnes du `Ajoute_Log` de
// l'original, dans l'ordre du traitement, et se referme.
//
// Elle se relit à chaque réouverture : le journal a pu changer entre deux
// visites — une sauvegarde, une réparation — et une fenêtre de Radinus n'est
// jamais détruite.

import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { Table } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

interface Entry {
  step: string;
  file: string;
  table: string;
  status: string;
  error: string;
  comments: string;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

/// Le rang sert d'identité : deux lignes peuvent être identiques mot pour mot
/// — vingt tables réindexées avec succès se ressemblent toutes —, et une
/// identité tirée du contenu les confondrait.
interface Row extends Entry {
  rank: number;
}

const table = new Table<Row>({
  container: element<HTMLDivElement>("rows"),
  virtualized: true,
  rowHeight: 22,
  columns: [
    { title: () => t("journal-column-step"), cell: (row) => row.step, width: "3fr" },
    { title: () => t("journal-column-file"), cell: (row) => row.file, width: "3fr" },
    { title: () => t("journal-column-table"), cell: (row) => row.table, width: "1fr" },
    { title: () => t("journal-column-status"), cell: (row) => row.status, width: "1fr" },
    { title: () => t("journal-column-error"), cell: (row) => row.error, width: "2fr" },
    { title: () => t("journal-column-comments"), cell: (row) => row.comments, width: "3fr" },
  ],
  identity: (row) => row.rank,
  exportAs: () => ({ name: t("window-journal-title"), detail: "" }),
  emptyText: () => t("journal-empty"),
  filteredOutText: () => t("ui-no-match"),
});

async function reload(): Promise<void> {
  try {
    const entries = await invoke<Entry[]>("journal_entries");
    table.setRows(entries.map((entry, rank) => ({ ...entry, rank })));
    say(entries.length === 0 ? t("journal-empty") : t("journal-help"));
  } catch (error) {
    say(tError("ui-load-failed", error), true);
  }
}

/// **Tous les mots de la fenêtre, posés en un seul endroit.**
///
/// Une fenêtre de Radinus est bâtie une fois et jamais détruite : changer de
/// langue ne la reconstruit pas, il faut qu'elle sache se rhabiller. Ce qui
/// pose un mot est donc ici et nulle part ailleurs — une étiquette ajoutée
/// demain suivra la langue sans que personne y pense.
///
/// `alsoTheNumbers` dit d'où l'on vient. À l'ouverture, les lignes viennent
/// plus bas, une fois passée la barrière de `startup_error` : les demander
/// d'ici les demanderait à une base peut-être fermée. Au changement de langue
/// il n'y a plus de barrière à passer, et il faut les redemander — les six
/// colonnes du journal sont écrites par le noyau, dans la langue du moment, et
/// ne se traduisent pas toutes seules.
async function dress(alsoTheNumbers = true): Promise<void> {
  table.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));
  element<HTMLElement>("close").title = t("ui-title-close");
  if (alsoTheNumbers) {
    await reload();
  }
}

element<HTMLButtonElement>("close").addEventListener("click", () => {
  void (async () => {
    try {
      await invoke("close_journal_window");
    } catch (error) {
      say(tError("ui-close-failed", error), true);
    }
  })();
});

// Rouverte après une nouvelle opération technique : la fenêtre existe déjà et
// n'a pas été détruite, il faut donc qu'elle relise.
void listen<string>("window-parameters:journal", () => {
  void reload();
});
void listen("data-changed:journal", () => {
  void reload();
});

void (async () => {
  await loadTexts(null);
  await dress(false);
  // L'export au clic droit ne pose aucun mot et ne se rebâtit pas : il pose
  // une écoute sur le tableau, et une seconde ferait deux exports pour un clic.
  table.exportOnRightClick(say);

  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    return;
  }
  await reload();
  onLanguageChanged(dress, { key: "window-journal-title" });
})();
