// La fenêtre de découpage d'un relevé CSV.
//
// Elle ne s'ouvre que si le fichier choisi dans la fenêtre d'importation n'est
// pas de l'OFX. Un fichier OFX se lit sans rien demander — ses balises portent
// leur nom ; un CSV ne porte rien du tout : pas de nom de champ fiable, pas
// d'ordre imposé, un séparateur au choix de la banque, et un entête de longueur
// quelconque. Il faut donc le régler à la main.
//
// **C'est une boucle, et elle est assumée** : on règle, on teste, on regarde,
// on recorrige. La fenêtre ne devine pas — elle montre ce que le réglage
// produit, charabia compris, parce que c'est en voyant du charabia qu'on
// comprend qu'on s'est trompé de nombre de lignes d'entête. « Si le paramétrage
// aurait dû être 7 au lieu de 1, ce n'est pas notre problème, c'est celui de
// l'utilisateur » (Fabrice, 27/07/2026).
//
// **Mais l'indulgence s'arrête à la porte** : ne basculent vers la fenêtre
// d'intégration que les lignes portant une date **et** un montant lisibles.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { Table } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

interface SourceLine {
  number: number;
  content: string;
}

interface ResultRow {
  number: number;
  date: string;
  /// La même date en ISO. **La colonne se trie là-dessus** : ce qui est
  /// affiché commence par le quantième, et s'y ranger classerait par jour du
  /// mois (défaut relevé par Fabrice le 04/08/2026).
  date_value: string;
  label: string;
  debit: string;
  credit: string;
  amount: number;
  valid: boolean;
}

interface Extraction {
  rows: ResultRow[];
  valid: number;
  dropped: number;
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
let path = "";
/// A-t-on testé depuis le dernier changement de réglage ? Valider sans avoir
/// regardé serait valider à l'aveugle.
let tested = false;

/// L'aperçu du haut : le fichier tel qu'il est, sans une interprétation.
const source = new Table<SourceLine>({
  container: element<HTMLDivElement>("source-rows"),
  virtualized: true,
  rowHeight: 22,
  columns: [
    {
      title: () => t("csv-column-line"),
      cell: (row) => String(row.number),
      key: (row) => row.number,
      numeric: true,
      width: "110px",
    },
    { title: () => t("csv-column-content"), cell: (row) => row.content, width: "1fr" },
  ],
  identity: (row) => row.number,
  emptyText: () => t("csv-none"),
  filteredOutText: () => t("ui-no-match"),
});

/// Le tableau du bas : ce que le découpage produit. **Tout y est**, y compris
/// ce qui n'a ni date ni montant — c'est le seul moyen de voir son erreur.
const result = new Table<ResultRow>({
  container: element<HTMLDivElement>("result-rows"),
  virtualized: true,
  rowHeight: 22,
  columns: [
    {
      title: () => t("statement-column-date"),
      cell: (row) => row.date,
      key: (row) => row.date_value,
      width: "110px",
    },
    { title: () => t("statement-column-label"), cell: (row) => row.label, width: "3fr" },
    {
      title: () => t("statement-column-debit"),
      cell: (row) => row.debit,
      key: (row) => row.amount,
      money: (row) => (row.debit === "" ? null : row.amount),
      numeric: true,
      width: "1fr",
    },
    {
      title: () => t("statement-column-credit"),
      cell: (row) => row.credit,
      key: (row) => row.amount,
      money: (row) => (row.credit === "" ? null : row.amount),
      numeric: true,
      width: "1fr",
    },
  ],
  identity: (row) => row.number,
  // Ce qui n'entrera pas se voit d'un coup d'œil, sans avoir à comparer les
  // colonnes une à une.
  rowClass: (row) => (row.valid ? null : "list__row--dropped"),
  emptyText: () => t("csv-not-tested"),
  filteredOutText: () => t("ui-no-match"),
});

/// Les six réglages, tels que la fenêtre les tient.
function settings(): Record<string, number | string> {
  const number = (id: string): number =>
    Math.max(0, Number(element<HTMLInputElement>(id).value) || 0);
  return {
    header_lines: number("header-lines"),
    separator: element<HTMLSelectElement>("separator").value,
    date_at: number("date-at"),
    label_at: number("label-at"),
    debit_at: number("debit-at"),
    credit_at: number("credit-at"),
  };
}

/// « Tester les paramètres ».
async function test(): Promise<void> {
  try {
    const extraction = await invoke<Extraction>("csv_statement_extract", {
      path,
      settings: settings(),
    });
    result.setRows(extraction.rows);
    tested = true;
    say(extraction.said, extraction.valid === 0);
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// La validation : les lignes valides basculent vers la fenêtre
/// d'intégration, et cette fenêtre-ci s'efface.
async function validate(): Promise<void> {
  if (!tested) {
    await test();
  }
  try {
    say(
      await invoke<string>("csv_statement_apply", {
        accountId,
        path,
        settings: settings(),
      }),
    );
  } catch (error) {
    // Le refus vient du noyau et se lit tel quel : c'est lui qui sait
    // qu'aucune ligne ne porte à la fois une date et un montant.
    say(String(error), true);
  }
}

async function leave(): Promise<void> {
  try {
    await invoke("close_csv_statement");
  } catch (error) {
    say(tError("ui-close-failed", error), true);
  }
}

element<HTMLButtonElement>("test").addEventListener("click", () => void test());
element<HTMLButtonElement>("validate").addEventListener("click", () => void validate());
element<HTMLButtonElement>("close").addEventListener("click", () => void leave());

// Changer un réglage périme l'essai précédent : ce qui est à l'écran ne
// correspond plus à ce qui est réglé, et il vaut mieux le dire que le laisser
// croire.
for (const id of ["header-lines", "separator", "date-at", "label-at", "debit-at", "credit-at"]) {
  element<HTMLElement>(id).addEventListener("change", () => {
    tested = false;
    say(t("csv-not-tested"));
  });
}

function readParameters(query: string): void {
  const parameters = new URLSearchParams(query);
  accountId = Number(parameters.get("account") ?? 0);
  path = parameters.get("path") ?? "";
}

/// Redemandée sur un autre fichier : la fenêtre est bâtie une fois et jamais
/// détruite, donc les nouveaux paramètres arrivent par un événement. Sans cette
/// écoute, elle découperait éternellement le premier fichier ouvert.
void (async () => {
  const { listen } = await import("@tauri-apps/api/event");
  void listen<string>("window-parameters:csv-statement", (event) => {
    readParameters(event.payload);
    tested = false;
    result.setRows([]);
    void showSource();
  });
})();

async function showSource(): Promise<void> {
  try {
    source.setRows(await invoke<SourceLine[]>("csv_statement_source", { path }));
    say(t("csv-help"));
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// **Pose les mots de la fenêtre.** Appelée à l'ouverture, et de nouveau à
/// chaque changement de langue.
///
/// Elle ne touche à **aucun réglage** : ni le nombre de lignes d'entête, ni les
/// rangs de colonnes, ni le séparateur choisi. Elle ne vide pas non plus le
/// tableau du bas — le rendu test déjà obtenu reste à l'écran, sans quoi
/// changer de langue reviendrait à redemander un essai qui a déjà eu lieu.
function dress(): void {
  source.buildHeader(
    element<HTMLElement>("source-header"),
    element<HTMLElement>("source-filter"),
  );
  result.buildHeader(
    element<HTMLElement>("result-header"),
    element<HTMLElement>("result-filter"),
  );

  for (const [id, key] of [
    ["preview-title", "csv-preview-title"],
    ["settings-title", "csv-settings-title"],
    ["extraction-title", "csv-extraction-title"],
    ["header-lines-label", "csv-header-lines"],
    ["separator-label", "csv-separator"],
    ["date-at-label", "csv-date-at"],
    ["label-at-label", "csv-label-at"],
    ["debit-at-label", "csv-debit-at"],
    ["credit-at-label", "csv-credit-at"],
    ["test", "csv-test"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  element<HTMLElement>("validate").title = t("csv-title-validate");
  element<HTMLElement>("close").title = t("ui-title-close");

  // Les séparateurs que l'on rencontre. La tabulation ne peut pas s'écrire
  // dans un menu : elle voyage sous un nom, et Rust la reconnaît.
  //
  // Le menu est **rebâti**, pas complété : ajouter à la suite doublerait ses
  // cinq entrées à chaque changement de langue. Le séparateur choisi lui est
  // remis ensuite — c'est un réglage saisi, et il ne doit pas repartir sur le
  // point-virgule. Au premier habillage il n'y a rien à remettre, et la
  // première entrée fait foi, comme avant.
  const separators = element<HTMLSelectElement>("separator");
  const chosen = separators.value;
  separators.replaceChildren();
  for (const [value, key] of [
    [";", "csv-separator-semicolon"],
    [",", "csv-separator-comma"],
    ["\\t", "csv-separator-tab"],
    ["|", "csv-separator-pipe"],
    [" ", "csv-separator-space"],
  ] as const) {
    const entry = document.createElement("option");
    entry.value = value;
    entry.textContent = t(key);
    separators.append(entry);
  }
  if (chosen !== "") {
    separators.value = chosen;
  }
}

void (async () => {
  await loadTexts(null);
  dress();
  // Le tableau du bas dit lui-même qu'il attend un essai : un cadre vide, sans
  // un mot, laisserait croire que le découpage ne donne rien. **C'est le seul
  // geste d'ouverture qui reste dehors** : rejoué à chaque langue, il périmerait
  // un rendu test déjà obtenu.
  result.setRows([]);

  // Les valeurs de départ sont celles d'un relevé français ordinaire, et
  // celles de la capture de l'original.
  element<HTMLInputElement>("header-lines").value = "1";
  element<HTMLInputElement>("date-at").value = "1";
  element<HTMLInputElement>("label-at").value = "2";
  element<HTMLInputElement>("debit-at").value = "3";
  element<HTMLInputElement>("credit-at").value = "3";

  readParameters(window.location.search);
  await showSource();
  onLanguageChanged(dress, { key: "window-csv-statement-title" });
})();
