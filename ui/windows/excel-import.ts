// F34 — l'étape 1/3 de l'importation d'une feuille Excel : la zone de capture.
//
// **Cette fenêtre ne devine rien.** L'utilisateur déclare où est l'en-tête, où
// commencent et où finissent les données, et comment son fichier écrit les
// montants ; le rendu test lui montre ce que sa déclaration attrape. C'est la
// ruse de l'original, gardée sur la recommandation de Fabrice (29/07/2026),
// et sa raison tient en une phrase : **une devinette qui se trompe ne se voit
// pas, une déclaration qui se trompe se voit dans le rendu test**.
//
// D'où la seule sévérité de la fenêtre : on ne passe pas à l'étape 2 sans
// avoir lancé le rendu test avec les réglages courants. Changer un nombre
// périme l'essai précédent — ce qui est à l'écran ne correspond plus à ce qui
// est réglé, et il vaut mieux le dire que le laisser croire.

import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askYesNo, tell } from "./dialog";
import { Table } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

interface PreviewRow {
  number: number;
  cells: string[];
}

interface Preview {
  headers: string[];
  rows: PreviewRow[];
  said: string;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

let accountId = 0;
let chosen = false;
/// A-t-on testé depuis le dernier changement de réglage ? Valider sans avoir
/// regardé serait valider à l'aveugle — et ici, à l'aveugle, on écrit des
/// milliers de lignes.
let tested = false;
let preview: Table<PreviewRow> | null = null;

/// Les noms de colonnes d'Excel, jusqu'à BZ — bien au-delà de ce qu'un relevé
/// porte, et sans prétendre couvrir les 16 384 colonnes du format.
function columnNames(): string[] {
  const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("");
  return [...letters, ...letters.slice(0, 2).flatMap((first) =>
    letters.map((second) => `${first}${second}`),
  )];
}

function columnNumber(name: string): number {
  let value = 0;
  for (const letter of name) {
    value = value * 26 + (letter.charCodeAt(0) - 64);
  }
  return value;
}

/// Les réglages, tels que la fenêtre les tient.
function settings(): Record<string, number | string> {
  const number = (id: string, least: number): number =>
    Math.max(least, Number(element<HTMLInputElement>(id).value) || least);
  return {
    sheet: Number(element<HTMLSelectElement>("sheet").value) || 0,
    header_row: number("header-row", 1),
    first_column: columnNumber(element<HTMLSelectElement>("first-column").value || "A"),
    column_count: number("column-count", 1),
    first_data_row: number("first-data-row", 1),
    last_data_row: number("last-data-row", 1),
    shape: element<HTMLInputElement>("shape-debit-credit").checked
      ? "debit-credit"
      : "single",
  };
}

/// Reconstruit l'aperçu : ses colonnes changent à chaque essai, puisqu'elles
/// sont celles de la feuille.
function showPreview(result: Preview): void {
  preview = new Table<PreviewRow>({
    container: element<HTMLDivElement>("preview-rows"),
    virtualized: true,
    rowHeight: 22,
    columns: result.headers.map((header, index) => ({
      // L'en-tête tel que la feuille l'écrit, vide compris : c'est ainsi qu'on
      // voit qu'on a déclaré une colonne de trop.
      title: () => header,
      cell: (row) => row.cells[index] ?? "",
      width: "1fr",
    })),
    identity: (row) => row.number,
    emptyText: () => t("excel-empty-capture"),
    filteredOutText: () => t("ui-no-match"),
  });
  preview.buildHeader(
    element<HTMLElement>("preview-header"),
    element<HTMLElement>("preview-filter"),
  );
  preview.setRows(result.rows);
}

async function pick(): Promise<void> {
  try {
    const file = await invoke<{ path: string; sheets: string[] } | null>(
      "excel_pick_file",
      { accountId },
    );
    if (!file) {
      return;
    }
    chosen = true;
    tested = false;
    element<HTMLElement>("path").textContent = file.path;
    const sheets = element<HTMLSelectElement>("sheet");
    sheets.replaceChildren();
    file.sheets.forEach((name, index) => {
      const entry = document.createElement("option");
      entry.value = String(index);
      entry.textContent = name;
      sheets.append(entry);
    });
    sheets.value = "0";
    // Un classeur d'une seule feuille ne pose pas de question : la combo est
    // là, elle ne gêne personne, et elle ne réclame rien.
    const state = await invoke<{ path: string; said: string } | null>("excel_state");
    say(state ? state.said : t("excel-help"));
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

async function test(): Promise<void> {
  if (!chosen) {
    say(t("excel-no-file"), true);
    return;
  }
  try {
    const result = await invoke<Preview>("excel_test", { settings: settings() });
    showPreview(result);
    tested = true;
    say(result.said, result.rows.length === 0);
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// Passer à l'étape 2. **Le rendu test est obligatoire** : on ne quitte pas
/// cette fenêtre sans avoir regardé ce que la zone attrape.
async function next(): Promise<void> {
  if (!chosen) {
    say(t("excel-no-file"), true);
    return;
  }
  if (!tested) {
    say(t("excel-not-tested"), true);
    return;
  }
  try {
    await invoke("open_excel_fields");
  } catch (error) {
    say(tError("ui-open-failed", error), true);
  }
}

async function leave(): Promise<void> {
  try {
    await invoke("close_excel_window", { label: "excel-import" });
  } catch (error) {
    say(tError("ui-close-failed", error), true);
  }
}

element<HTMLButtonElement>("pick").addEventListener("click", () => void pick());
element<HTMLButtonElement>("test").addEventListener("click", () => void test());
element<HTMLButtonElement>("validate").addEventListener("click", () => void next());
element<HTMLButtonElement>("close").addEventListener("click", () => void leave());

// Changer un réglage périme l'essai précédent.
for (const id of [
  "sheet",
  "header-row",
  "first-column",
  "column-count",
  "first-data-row",
  "last-data-row",
  "shape-single",
  "shape-debit-credit",
]) {
  element<HTMLElement>(id).addEventListener("change", () => {
    tested = false;
    say(t("excel-not-tested"));
  });
}

/// La question de la sauvegarde, posée **avant** de commencer.
///
/// Règle de Fabrice (29/07/2026) : « on peut supposer que dedans il y a les
/// pires conneries et que l'on ne pourra pas forcément les détecter, il y a
/// donc une part de risque inévitable ». On ne promet pas de tout rattraper —
/// on propose le filet avant de sauter, et l'on dit pourquoi.
async function offerBackup(): Promise<void> {
  const wanted = await askYesNo(
    t("excel-backup-question"),
    t("ui-yes"),
    t("ui-no"),
  );
  if (wanted) {
    // La sauvegarde n'est pas encore écrite (phase 17). On le dit plutôt que
    // de faire semblant : promettre une sauvegarde qui n'a pas lieu serait
    // pire que ne rien proposer du tout.
    await tell(t("excel-backup-later"), t("ui-ok"));
  }
}

function readParameters(query: string): void {
  accountId = Number(new URLSearchParams(query).get("account") ?? 0);
}

/// Redemandée sur un autre compte : la fenêtre est bâtie une fois et jamais
/// détruite, donc les nouveaux paramètres arrivent par un événement. Sans cette
/// écoute, elle importerait éternellement dans le premier compte choisi.
void listen<string>("window-parameters:excel-import", (event) => {
  readParameters(event.payload);
  chosen = false;
  tested = false;
  element<HTMLElement>("path").textContent = "";
  element<HTMLSelectElement>("sheet").replaceChildren();
  preview?.setRows([]);
  say(t("excel-help"));
  void offerBackup();
});

/// **Pose les mots de la fenêtre.** Appelée à l'ouverture, et de nouveau à
/// chaque changement de langue.
///
/// Elle ne repose que les cinq groupes numérotés et leurs étiquettes. Tout ce
/// que l'utilisateur a déclaré — la feuille, la ligne d'en-tête, la première
/// colonne, le nombre de colonnes, les deux bornes de lignes, la forme du
/// montant — reste tel quel : ce sont des réglages saisis, et une déclaration
/// effacée par un changement de langue serait une déclaration à refaire. Le
/// rendu test ne se périme pas non plus : ses colonnes sont celles de la
/// feuille, et la feuille ne parle aucune langue.
function dress(): void {
  for (const [id, key] of [
    ["group-file", "excel-group-file"],
    ["pick", "excel-pick"],
    ["sheet-label", "excel-sheet"],
    ["group-header", "excel-group-header"],
    ["header-row-label", "excel-header-row"],
    ["first-column-label", "excel-first-column"],
    ["column-count-label", "excel-column-count"],
    ["group-rows", "excel-group-rows"],
    ["first-data-row-label", "excel-first-data-row"],
    ["last-data-row-label", "excel-last-data-row"],
    ["group-shape", "excel-group-shape"],
    ["shape-single-label", "excel-shape-single"],
    ["shape-debit-credit-label", "excel-shape-debit-credit"],
    ["shape-note", "excel-shape-note"],
    ["group-test", "excel-group-test"],
    ["test", "excel-test"],
    ["test-note", "excel-test-note"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  element<HTMLElement>("validate").title = t("excel-title-next");
  element<HTMLElement>("close").title = t("ui-title-close");
}

void (async () => {
  await loadTexts(null);
  dress();

  // Les noms de colonnes d'Excel ne sont d'aucune langue, et la lettre choisie
  // est un réglage : ce menu se bâtit une fois pour toutes, hors de `dress`.
  const columns = element<HTMLSelectElement>("first-column");
  for (const name of columnNames()) {
    const entry = document.createElement("option");
    entry.value = name;
    entry.textContent = name;
    columns.append(entry);
  }
  columns.value = "A";

  // Les valeurs de départ sont celles de sa capture.
  element<HTMLInputElement>("header-row").value = "1";
  element<HTMLInputElement>("column-count").value = "15";
  element<HTMLInputElement>("first-data-row").value = "2";
  element<HTMLInputElement>("last-data-row").value = "1000";

  showPreview({ headers: [], rows: [], said: "" });
  readParameters(window.location.search);
  say(t("excel-help"));

  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    element<HTMLButtonElement>("validate").disabled = true;
    element<HTMLButtonElement>("pick").disabled = true;
    return;
  }
  // **Avant la question de la sauvegarde**, qui attend une réponse : inscrire
  // l'écoute après elle laisserait la fenêtre sourde au changement de langue
  // tant que le dialogue est ouvert.
  onLanguageChanged(dress, { key: "window-excel-import-title" });
  await offerBackup();
})();
