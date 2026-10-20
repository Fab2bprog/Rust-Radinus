// F17 — « Importation de relevés de comptes bancaires ».
//
// La marche à suivre est celle que Fabrice a dictée le 27/07/2026, dans cet
// ordre :
//
//   1. l'utilisateur a déjà choisi **un** compte bancaire, un seul ;
//   2. cette fenêtre s'ouvre, vide ;
//   3. le dossier jaune ouvre un fichier OFX — qui est lu **en RAM, pas en
//      base** ;
//   4. les lignes que Radinus connaît déjà s'affichent **en pastel**, et ce
//      qui les fait reconnaître est leur **FITID déjà présent en base** ;
//   5. le troisième icône les intègre : en masse après un avertissement quand
//      plusieurs lignes sont choisies, par la fiche de rapprochement quand il
//      n'y en a qu'une.
//
// **Le fichier n'est jamais lu par cette fenêtre.** Le sélecteur du système est
// ouvert côté Rust, et c'est Rust qui lit les octets : le pouvoir de lire un
// fichier n'est pas accordé à l'interface, et `capabilities/default.json`
// n'autorise toujours que la sauvegarde.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askForChoice, askThreeWays, askYesNo } from "./dialog";
import { Table } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

const PARAMETERS_EVENT = "window-parameters:statement-import";
const CHANGED_EVENT = "data-changed:statement-import";

interface Row {
  rank: number;
  date: string;
  /// La même date en ISO. **La colonne se trie là-dessus** : ce qui est
  /// affiché commence par le quantième, et s'y ranger classerait par jour du
  /// mois (défaut relevé par Fabrice le 04/08/2026).
  date_value: string;
  label: string;
  /// La référence paiement que l'opération recevra : le MEMO de la banque,
  /// selon les Préférences (19/10/2026). Vide quand la banque n'en donne pas.
  reference: string;
  debit: string;
  credit: string;
  amount: number;
  /// `Existe_OpFitID` : ce FITID est **déjà en base**. Une certitude.
  fitid_known: boolean;
  /// `Existe_TransacMemeType` : même date, même libellé, même montant. Un
  /// soupçon — et le seul filet d'un CSV, qui n'a aucun identifiant.
  looks_like_duplicate: boolean;
  reconciled: boolean;
}

interface Loaded {
  lines: Row[];
  account_number: string;
  period: string;
  account_balance: string;
  file_balance: string;
  difference: string;
  pending: number;
  fitid_known: number;
  /// La colonne FITID ne s'affiche que pour les formats qui en portent un.
  has_fitid_column: boolean;
  said: string;
}

interface Picked {
  path: string;
  /// « ofx », « qif » ou « csv » — **déduit du contenu du fichier, pas de son
  /// extension**. Un relevé OFX enregistré sous `.txt` reste un relevé OFX.
  kind: string;
  accounts: string[];
}

/// Ce que le chargement d'un QIF rend : le relevé, ou la question de l'ordre
/// des dates, rédigée par le noyau, quand rien dans le fichier ne le prouve.
interface QifLoaded {
  question: { text: string; choices: string[]; keys: string[] } | null;
  view: Loaded | null;
}

/// Ce qu'une demande d'intégration a donné, pour une ligne.
interface LineOutcome {
  outcome: "added" | "reconciled" | "duplicate" | "unknown";
  question: string;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

/// Le compte de Radinus dans lequel on importe. Il arrive dans l'adresse, et il
/// est renvoyé à Rust **à chaque appel** : le relevé ouvert vérifie qu'on lui
/// parle bien du compte qu'il concerne, et refuse plutôt que d'intégrer des
/// lignes dans le compte de quelqu'un d'autre.
let accountId = 0;

/// Le fichier ouvert, et le compte du fichier qu'on lit dedans. Un fichier peut
/// en porter plusieurs ; on n'en importe qu'un.
let filePath = "";
let fileAccount = "";

/// Ce que le tableau montre en ce moment.
let lines: Row[] = [];

/// Le menu Filtre : toutes les lignes, celles qui restent à intégrer, ou celles
/// que la base connaît déjà.
let filter: "all" | "pending" | "known" = "all";

/// La case cochée d'une colonne — la colonne Rapproché et la colonne FITID.
/// Elle se lit, elle ne se clique pas : ce sont deux constats, pas deux
/// réglages.
function tick(ticked: boolean, cell: HTMLElement): void {
  const box = document.createElement("span");
  box.className = ticked ? "list__box list__box--ticked" : "list__box";
  box.textContent = ticked ? "✓" : "";
  cell.append(box);
}

const table = new Table<Row>({
  container: element<HTMLDivElement>("rows"),
  virtualized: true,
  rowHeight: 24,
  columns: [
    {
      title: () => t("statement-column-id"),
      cell: (row) => String(row.rank),
      key: (row) => row.rank,
      numeric: true,
      width: "80px",
    },
    {
      title: () => t("statement-column-reconciled"),
      cell: () => "",
      render: (row, cell) => tick(row.reconciled, cell),
      width: "125px",
    },
    {
      // **Elle dit que ce FITID est déjà dans le compte**, et non que le
      // fichier en a fourni un — c'est `Existe_OpFitID` de l'original, et je
      // l'avais lue à l'envers.
      title: () => t("statement-column-fitid"),
      cell: () => "",
      render: (row, cell) => tick(row.fitid_known, cell),
      width: "90px",
    },
    {
      title: () => t("statement-column-date"),
      cell: (row) => row.date,
      key: (row) => row.date_value,
      width: "110px",
    },
    { title: () => t("statement-column-label"), cell: (row) => row.label, width: "3fr" },
    {
      // **La référence paiement** (Fabrice, 19/10/2026) : le détail que la
      // banque met dans son MEMO — créancier, bénéficiaire, motif. Coupée
      // proprement à l'écran, entière au survol.
      title: () => t("statement-column-reference"),
      cell: (row) => row.reference,
      render: (row, cell) => {
        cell.textContent = row.reference;
        cell.title = row.reference;
      },
      width: "3fr",
    },
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
  identity: (row) => row.rank,
  // **Quatre états, comme dans l'original.** La couleur porte le **sens** de
  // l'opération — rouge pour un débit, bleu pour un crédit — et le pastel avec
  // l'italique portent le **soupçon de doublon** (`Existe_TransacMemeType`).
  // Une ligne rapprochée pendant la séance passe au gris clair et n'est plus
  // ni l'un ni l'autre : elle est faite.
  rowClass: (row) => {
    if (row.reconciled) {
      return "list__row--done";
    }
    const way = row.amount <= 0 ? "debit" : "credit";
    return row.looks_like_duplicate
      ? `list__row--${way} list__row--alike`
      : `list__row--${way}`;
  },
  exportAs: () => ({ name: t("statement-column-label"), detail: fileAccount }),
  emptyText: () => (filePath === "" ? t("statement-none") : t("statement-empty")),
  filteredOutText: () => t("statement-no-match"),
  onSelectionChange: () => refreshButtons(),
  // Double-cliquer une ligne ouvre sa fiche de rapprochement, comme partout.
  onActivate: (row: Row) => void openForm(row.rank),
});

function shown(): Row[] {
  if (filter === "pending") {
    return lines.filter((row) => !row.reconciled && !row.fitid_known);
  }
  if (filter === "known") {
    return lines.filter((row) => row.fitid_known || row.reconciled);
  }
  return lines;
}

function refreshButtons(): void {
  const open = filePath !== "";
  element<HTMLButtonElement>("info").disabled = !open;
  element<HTMLButtonElement>("integrate").disabled =
    !open || table.selected().length === 0;
}

function show(data: Loaded): void {
  lines = data.lines;
  fileAccount = data.account_number;
  // **La colonne FITID n'a de sens que pour un format qui en porte un** : elle
  // est visible pour l'OFX, cachée pour le CSV, comme dans l'original.
  document
    .querySelector(".window--statement")
    ?.classList.toggle("window--no-fitid", !data.has_fitid_column);
  table.setRows(shown());
  element<HTMLElement>("account-balance").textContent = data.account_balance;
  element<HTMLElement>("file-balance").textContent = data.file_balance;
  element<HTMLElement>("difference").textContent = data.difference;
  // L'écart est l'information : nul, tout concorde ; non nul, il reste
  // quelque chose à faire — et cela se voit.
  element<HTMLElement>("difference").classList.toggle(
    "totals__value--alert",
    data.difference !== "" && data.pending > 0,
  );
  refreshButtons();
  if (data.said !== "") {
    say(data.said);
  }
}

/// A-t-on déjà intégré quelque chose depuis l'ouverture ? **L'écart ne se
/// calcule pas contre le même solde avant et après** — `LEDGERBAL` au
/// chargement, `AVAILBAL` ensuite. C'est une bizarrerie de l'original, gardée
/// telle quelle sur la consigne de Fabrice.
let afterIntegration = false;

async function reload(): Promise<void> {
  if (filePath === "") {
    return;
  }
  try {
    show(await invoke<Loaded>("statement_lines", { accountId, afterIntegration }));
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// Le premier icône : choisir un fichier. **Rien n'est chargé tant qu'on ne
/// sait pas de quel compte du fichier on parle** — un fichier peut en porter
/// plusieurs, et Radinus n'en importe qu'un.
async function openFile(): Promise<void> {
  try {
    const picked = await invoke<Picked | null>("statement_pick_file");
    if (!picked) {
      return;
    }
    // **Un CSV passe par la fenêtre de découpage.** Il ne porte aucun nom de
    // champ fiable : il faut le régler avant de pouvoir en tirer quoi que ce
    // soit. Après validation, ses lignes reviennent ici comme si elles
    // venaient d'un OFX (demande de Fabrice, 27/07/2026).
    if (picked.kind === "csv") {
      await invoke("open_csv_statement", { accountId, path: picked.path });
      return;
    }
    if (picked.accounts.length === 0) {
      say(t("statement-empty"), true);
      return;
    }
    // **Un QIF suit le chemin de l'OFX** — même choix du compte, même tableau,
    // mêmes boutons (Fabrice, 15/10/2026 : « c'est un relevé bancaire aussi ») —
    // avec une seule question de plus, quand le fichier ne dit pas l'ordre des
    // dates.
    if (picked.kind === "qif") {
      await openQif(picked);
      return;
    }
    let chosen = picked.accounts[0];
    if (picked.accounts.length > 1) {
      const answer = await askForChoice(
        t("statement-choose-account"),
        picked.accounts,
        t("ui-yes"),
        t("ui-no"),
      );
      if (answer === null) {
        return;
      }
      chosen = answer;
    }
    filePath = picked.path;
    table.clearSelection();
    show(
      await invoke<Loaded>("statement_load", {
        accountId,
        path: filePath,
        accountNumber: chosen,
      }),
    );
  } catch (error) {
    filePath = "";
    say(tError("ui-read-failed", error), true);
  }
}

/// Ouvre un relevé QIF : le compte, puis, s'il le faut, l'ordre des dates.
async function openQif(picked: Picked): Promise<void> {
  let account = 0;
  if (picked.accounts.length > 1) {
    const answer = await askForChoice(t("statement-choose-account"), picked.accounts, t("ui-yes"), t("ui-no"));
    if (answer === null) {
      return;
    }
    account = picked.accounts.indexOf(answer);
  }
  let order: string | null = null;
  // Deux passages au plus : la lecture, puis la lecture avec la réponse.
  for (let attempt = 0; attempt < 2; attempt += 1) {
    const loaded: QifLoaded = await invoke<QifLoaded>("statement_load_qif", { accountId, path: picked.path, account, order });
    if (loaded.view) {
      filePath = picked.path;
      table.clearSelection();
      show(loaded.view);
      return;
    }
    if (!loaded.question || order !== null) {
      break;
    }
    const answer = await askForChoice(loaded.question.text, loaded.question.choices, t("ui-yes"), t("ui-no"));
    if (answer === null) {
      return;
    }
    order = loaded.question.keys[loaded.question.choices.indexOf(answer)] ?? null;
  }
}

/// Le deuxième icône : ce que le fichier ouvert contient, en toutes lettres.
async function showFileInfo(): Promise<void> {
  try {
    const said = await invoke<string>("statement_file_info", { accountId });
    await askYesNo(said, t("ui-yes"), t("ui-no"));
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// Le troisième icône, et ses deux visages : une seule ligne choisie ouvre la
/// fiche de rapprochement ; plusieurs les font entrer d'un coup, après
/// l'avertissement.
///
/// **La boucle est menée ici, ligne par ligne**, comme
/// `Integration_MultiLigne` : chaque ligne est proposée à Rust, et quand son
/// FITID est déjà en base c'est **une question à trois issues** qui décide —
/// Oui l'intègre quand même, Non la passe, Annuler abandonne le lot entier. À
/// la fin, le compte rendu : combien sont entrées, combien ont été ignorées.
async function integrate(): Promise<void> {
  const chosen = table.selected();
  if (chosen.length === 0) {
    say(t("statement-select-line"), true);
    return;
  }
  if (chosen.length === 1) {
    await openForm(chosen[0]);
    return;
  }
  if (!(await askYesNo(t("statement-mass-question"), t("ui-yes"), t("ui-no")))) {
    return;
  }

  let added = 0;
  let ignored = 0;
  let abandoned = false;
  try {
    for (const rank of chosen) {
      let answer = await invoke<LineOutcome>("statement_integrate_line", {
        accountId,
        rank,
        force: false,
      });
      if (answer.outcome === "duplicate") {
        const said = await askThreeWays(
          answer.question,
          t("statement-yes"),
          t("statement-no"),
          t("statement-cancel"),
        );
        if (said === "stay") {
          abandoned = true;
          break;
        }
        if (said === "second") {
          ignored += 1;
          continue;
        }
        answer = await invoke<LineOutcome>("statement_integrate_line", {
          accountId,
          rank,
          force: true,
        });
      }
      if (answer.outcome === "added") {
        added += 1;
      } else {
        ignored += 1;
      }
    }
    afterIntegration = true;
    await reload();
    table.clearSelection();
    say(
      await invoke<string>("statement_integration_report", { added, ignored, abandoned }),
      abandoned,
    );
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

async function openForm(rank: number): Promise<void> {
  // **Le seul refus sec de l'original** : une ligne déjà rapprochée pendant
  // cette séance. Un doublon, lui, ouvre la fiche — c'est elle qui posera la
  // question.
  if (lines.find((row) => row.rank === rank)?.reconciled) {
    say(t("statement-already-reconciled"), true);
    return;
  }
  try {
    await invoke("open_statement_form", { accountId, rank });
  } catch (error) {
    say(tError("ui-open-failed", error), true);
  }
}

async function leave(): Promise<void> {
  try {
    await invoke("close_statement_import");
  } catch (error) {
    say(tError("ui-close-failed", error), true);
  }
}

/// Le menu Filtre, celui de l'original : trois façons de regarder le même
/// relevé.
function filterMenu(entry: HTMLElement): HTMLElement {
  const holder = document.createElement("div");
  holder.className = "window-menu__holder";
  const choices = document.createElement("div");
  choices.className = "window-menu__choices";
  choices.dataset.menu = "filter";
  choices.hidden = true;

  for (const [key, chosen] of [
    ["statement-filter-all", "all"],
    ["statement-filter-pending", "pending"],
    ["statement-filter-known", "known"],
  ] as const) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "window-menu__choice window-menu__choice--plain";
    button.dataset.key = key;
    button.textContent = t(key);
    button.addEventListener("click", () => {
      choices.hidden = true;
      filter = chosen;
      for (const other of choices.querySelectorAll<HTMLElement>(".window-menu__choice")) {
        other.classList.toggle(
          "window-menu__choice--chosen",
          other.dataset.key === key,
        );
      }
      table.setRows(shown());
    });
    choices.append(button);
  }

  entry.addEventListener("click", (event) => {
    event.stopPropagation();
    choices.hidden = !choices.hidden;
  });
  document.addEventListener("click", () => {
    choices.hidden = true;
  });

  // Rien n'est filtré au départ, et l'encoche le dit.
  for (const other of choices.querySelectorAll<HTMLElement>(".window-menu__choice")) {
    other.classList.toggle(
      "window-menu__choice--chosen",
      other.dataset.key === "statement-filter-all",
    );
  }
  holder.append(entry, choices);
  return holder;
}

function readParameters(query: string): void {
  accountId = Number(new URLSearchParams(query).get("account") ?? 0);
  history.replaceState(null, "", `?account=${accountId}`);
}

/// L'entrée « Filtre » du menu de fenêtre. Elle n'est bâtie qu'une fois — la
/// fenêtre n'est jamais détruite — et se contente ensuite de changer de mot :
/// la rebâtir empilerait un second menu sous le premier et remettrait l'encoche
/// sur « toutes les lignes » alors que le filtre en cours, lui, n'aurait pas
/// bougé.
let filterEntry: HTMLButtonElement | null = null;

/// **Pose les mots de la fenêtre.** Appelée à l'ouverture, et de nouveau à
/// chaque changement de langue : c'est la même fonction dans les deux cas, et
/// c'est ce qui garantit qu'une étiquette ajoutée demain suivra la langue sans
/// que personne y pense.
async function dress(): Promise<void> {
  table.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));

  for (const [id, key] of [
    ["account-label", "statement-account"],
    ["file-label", "statement-file"],
    ["difference-label", "statement-difference"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  for (const [id, key] of [
    ["open", "statement-title-open"],
    ["info", "statement-title-info"],
    ["integrate", "statement-title-integrate"],
    ["close", "ui-title-close"],
  ] as const) {
    element<HTMLElement>(id).title = t(key);
  }

  const menu = element<HTMLElement>("window-menu");
  if (!filterEntry) {
    filterEntry = document.createElement("button");
    filterEntry.type = "button";
    filterEntry.className = "window-menu__entry";
    menu.append(filterMenu(filterEntry));
  }
  filterEntry.textContent = t("statement-menu-filter");
  // Les trois choix portent leur clef Fluent : on les rhabille un à un sans
  // toucher à l'encoche, sinon le filtre en cours et ce que le menu montre
  // diraient deux choses différentes.
  for (const choice of menu.querySelectorAll<HTMLElement>(".window-menu__choice")) {
    if (choice.dataset.key) {
      choice.textContent = t(choice.dataset.key);
    }
  }

  // **Le fichier n'est jamais relu.** Le relevé vit en RAM du côté de Rust, et
  // `statement_lines` rend ses lignes avec les phrases déjà écrites dans la
  // langue du moment : redemander les lignes suffit, rouvrir le fichier serait
  // repartir de zéro et perdre ce qui a été intégré pendant la séance. Sans
  // relevé ouvert il n'y a rien à redemander, et la barre redit ce qu'elle dit
  // au départ.
  if (filePath === "") {
    say(t("statement-none"));
  } else {
    await reload();
  }
}

element<HTMLButtonElement>("open").addEventListener("click", () => void openFile());
element<HTMLButtonElement>("info").addEventListener("click", () => void showFileInfo());
element<HTMLButtonElement>("integrate").addEventListener("click", () => void integrate());
element<HTMLButtonElement>("close").addEventListener("click", () => void leave());

// Deux choses arrivent par cet événement, et elles se distinguent par ce
// qu'il porte. Sans charge utile : une opération vient d'entrer par la fiche
// de rapprochement, on relit. Avec un chemin : **un relevé CSV vient d'être
// découpé et versé ici** — c'est lui qui nous apprend qu'un relevé est
// désormais ouvert.
void listen<string>(CHANGED_EVENT, (event) => {
  if (event.payload) {
    filePath = event.payload;
    table.clearSelection();
  } else {
    // Sans charge utile : la fiche de rapprochement vient de faire entrer une
    // opération, donc l'écart se compare désormais à l'autre solde.
    afterIntegration = true;
  }
  void reload();
});

/// Redemandée pour un autre compte : **le relevé ouvert ne la suit pas**. Un
/// relevé concerne un compte, et l'ouvrir dans un autre n'aurait aucun sens.
void listen<string>(PARAMETERS_EVENT, (event) => {
  readParameters(event.payload);
  filePath = "";
  fileAccount = "";
  lines = [];
  table.clearSelection();
  table.setRows([]);
  refreshButtons();
  say(t("statement-none"));
});

void (async () => {
  await loadTexts(null);
  await dress();
  table.exportOnRightClick(say);

  readParameters(window.location.search);
  refreshButtons();

  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    return;
  }
  say(t("statement-none"));

  // Le titre nomme le compte du relevé, et ce compte n'est connu qu'une fois un
  // fichier ouvert : l'argument se lit donc **au moment où la langue change**,
  // pas à l'inscription — d'où l'accesseur plutôt qu'une valeur figée.
  onLanguageChanged(dress, {
    key: "window-statement-import-title",
    get argument(): string {
      return fileAccount;
    },
  });
})();
