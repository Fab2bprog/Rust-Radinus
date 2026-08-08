// F05 — « Classification rapide des opérations ».
//
// La fenêtre où l'on classe **en masse**. Fabrice l'a dictée le 27/07/2026,
// avant tout code, et ce sont ses règles qui décident de tout ce qui suit :
//
//   * on n'y entre qu'après avoir choisi **un** compte, et un seul ;
//   * **tout le compte est en mémoire**, quelle que soit la période — la
//     période ne fait que rétrécir ce qu'on regarde, elle ne redescend jamais
//     à la base ;
//   * on classe **en masse**, c'est tout l'intérêt de la fenêtre : classer une
//     opération à la fois est possible, mais c'est le cas particulier ;
//   * appliquer écrit **en mémoire seulement**. Le disque n'apprend rien tant
//     qu'on n'a pas enregistré, et l'enregistrement ne réécrit que ce qui
//     diffère de ce qui a été lu ;
//   * en cas de bêtise, on quitte : il n'y a aucune conséquence.
//
// **Le brouillon n'est pas ici.** Il vit du côté de Rust, dans l'état de
// l'application ; cette page ne détient rien qu'elle ne redemande. Une copie
// dans le navigateur serait une seconde vérité, et deux vérités finissent
// toujours par diverger — ce qui, sur des opérations bancaires, veut dire
// enregistrer autre chose que ce qu'on a vu.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askThreeWays, askYesNo } from "./dialog";
import { buildPeriodMenu, wholeYear } from "./period";
import { Table } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

const PARAMETERS_EVENT = "window-parameters:quick-classification";
const CHANGED_EVENT = "data-changed:quick-classification";

interface Row {
  id: number;
  date: string;
  /// La même date en ISO. **La colonne se trie là-dessus** : ce qui est
  /// affiché commence par le quantième, et s'y ranger classerait par jour du
  /// mois (défaut relevé par Fabrice le 04/08/2026).
  date_value: string;
  label: string;
  amount_text: string;
  amount: number;
  category: string;
  assignment: string;
  payment_mode: string;
  payee: string;
  project: string;
  status: string;
  category_id: number;
  assignment_id: number;
  payment_mode_id: number;
  payee_id: number;
  project_id: number;
  status_id: number;
}

interface Lines {
  rows: Row[];
  loaded: number;
  pending: number;
  pending_text: string;
}

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

/// Ce qu'une application en masse a fait.
interface Applied {
  said: string;
  pending: number;
}

/// **Les six caractéristiques, déclarées une fois.**
///
/// Elles servent trois fois — la case du bandeau, la colonne du tableau, et le
/// champ envoyé à Rust — et les trois lisent cette liste. Écrire six blocs à
/// la main aurait fait six endroits où oublier la même correction, et surtout
/// six occasions de faire glisser un nom : envoyer le tiers dans le champ du
/// projet ne casse rien, n'alerte personne, et classe tout de travers.
///
/// `field` est le nom du champ de `ChangeInput`, côté Rust, et `key` celui que
/// `Characteristic::key` donne. Ce ne sont pas les mêmes chaînes : un croisement
/// les tient toutes les deux (`src-tauri/src/crossings.rs`).
const CHARACTERISTICS = [
  {
    key: "category",
    field: "category",
    label: "quick-check-category",
    column: "quick-column-category",
    text: (row: Row) => row.category,
    value: (row: Row) => row.category_id,
  },
  {
    key: "assignment",
    field: "assignment",
    label: "quick-check-assignment",
    column: "quick-column-assignment",
    text: (row: Row) => row.assignment,
    value: (row: Row) => row.assignment_id,
  },
  {
    key: "payment-mode",
    field: "payment_mode",
    label: "quick-check-payment-mode",
    column: "quick-column-payment-mode",
    text: (row: Row) => row.payment_mode,
    value: (row: Row) => row.payment_mode_id,
  },
  {
    key: "payee",
    field: "payee",
    label: "quick-check-payee",
    column: "quick-column-payee",
    text: (row: Row) => row.payee,
    value: (row: Row) => row.payee_id,
  },
  {
    key: "project",
    field: "project",
    label: "quick-check-project",
    column: "quick-column-project",
    text: (row: Row) => row.project,
    value: (row: Row) => row.project_id,
  },
  {
    key: "status",
    field: "status",
    label: "quick-check-status",
    column: "quick-column-status",
    text: (row: Row) => row.status,
    value: (row: Row) => row.status_id,
  },
] as const;

type Which = (typeof CHARACTERISTICS)[number]["key"];

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");
const fromField = element<HTMLInputElement>("from");
const toField = element<HTMLInputElement>("to");
const applyButton = element<HTMLButtonElement>("apply");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

/// Le compte sur lequel on travaille. Il arrive dans l'adresse, et il change
/// quand la fenêtre est redemandée pour un autre — c'est pour cela qu'il est
/// renvoyé à Rust **à chaque appel** : le brouillon vérifie qu'on lui parle
/// bien du compte qu'il tient, et refuse plutôt que de répondre avec les
/// opérations de quelqu'un d'autre.
let accountId = 0;

/// Les listes où les menus puisent. Lues une fois pour toute la fenêtre.
const options = new Map<Which, Item[]>();

/// Le nom du compte sur lequel on travaille. Il ne sert qu'au titre, que le
/// noyau compose à partir de lui — la fenêtre est la seule à le savoir encore
/// quand la langue change, Rust ne l'ayant écrit qu'à l'ouverture.
let accountLabel = "";

/// Les six cases, leur étiquette et leur menu, une fois bâtis. **L'étiquette
/// est retenue avec le reste** : changer de langue la repose, là où rebâtir les
/// six lignes jetterait les cases cochées et le classement déjà choisi.
const boxes = new Map<
  Which,
  { box: HTMLInputElement; label: HTMLLabelElement; menu: HTMLSelectElement }
>();

/// Ce que le tableau montre en ce moment, pour n'avoir pas à le redemander.
let pending = 0;

// --- Le tableau ---------------------------------------------------------

/// Une colonne de classement : le libellé à l'écran, et un menu déroulant sur
/// la ligne sélectionnée. **Un classement ne se tape jamais** — on choisit
/// parmi ce qui existe (règle de l'auteur, 25/07/2026, déjà appliquée dans
/// F02).
///
/// Choisir écrit dans le brouillon, en mémoire, et jamais sur le disque : la
/// cellule et le bandeau mènent au même endroit.
function classificationColumn(which: (typeof CHARACTERISTICS)[number], width: string) {
  return {
    title: () => t(which.column),
    cell: which.text,
    width,
    editor: {
      options: () => options.get(which.key) ?? [],
      value: which.value,
      change: (row: Row, chosen: number) => {
        void invoke("quick_classification_set", {
          accountId,
          id: row.id,
          characteristic: which.key,
          value: chosen,
        })
          .then(() => reload())
          .catch((error) => say(tError("ui-save-failed", error), true));
      },
    },
  };
}

const table = new Table<Row>({
  container: element<HTMLDivElement>("rows"),
  // Le compte de l'auteur porte 2 502 opérations et le plan en prévoit
  // 40 000 : seules les lignes à l'écran sont construites.
  virtualized: true,
  rowHeight: 24,
  columns: [
    {
      title: () => t("quick-column-date"),
      cell: (row) => row.date,
      key: (row) => row.date_value,
      width: "100px",
    },
    { title: () => t("quick-column-label"), cell: (row) => row.label, width: "2.4fr" },
    {
      title: () => t("quick-column-amount"),
      cell: (row) => row.amount_text,
      key: (row) => row.amount,
      money: (row) => row.amount,
      numeric: true,
      width: "1fr",
    },
    classificationColumn(CHARACTERISTICS[0], "1.2fr"),
    classificationColumn(CHARACTERISTICS[1], "1fr"),
    classificationColumn(CHARACTERISTICS[2], "1.1fr"),
    classificationColumn(CHARACTERISTICS[3], "1.1fr"),
    classificationColumn(CHARACTERISTICS[4], "1fr"),
    classificationColumn(CHARACTERISTICS[5], "0.9fr"),
  ],
  identity: (row) => row.id,
  exportAs: () => ({
    name: t("quick-column-label"),
    detail: `${t("quick-from")} ${fromField.value} — ${t("quick-to")} ${toField.value}`,
  }),
  emptyText: () => t("quick-none"),
  filteredOutText: () => t("ui-no-match"),
  onSelectionChange: () => refreshApplyButton(),
});

// --- Le bandeau des six caractéristiques --------------------------------

/// Bâtit les six paires case + menu. Une case décochée éteint son menu : c'est
/// ce que montre la capture, et c'est ce qui dit à l'utilisateur qu'il n'a
/// encore rien demandé.
function buildCharacteristics(): void {
  const holder = element<HTMLElement>("characteristics");
  holder.replaceChildren();

  for (const which of CHARACTERISTICS) {
    const line = document.createElement("div");
    line.className = "characteristic";

    const box = document.createElement("input");
    box.type = "checkbox";
    box.className = "characteristic__box";
    box.id = `check-${which.key}`;

    const label = document.createElement("label");
    label.className = "characteristic__label";
    label.htmlFor = box.id;
    label.textContent = t(which.label);

    const menu = document.createElement("select");
    menu.className = "characteristic__menu";
    menu.disabled = true;

    box.addEventListener("change", () => {
      menu.disabled = !box.checked;
      line.classList.toggle("characteristic--armed", box.checked);
      refreshApplyButton();
    });

    line.append(box, label, menu);
    holder.append(line);
    boxes.set(which.key, { box, label, menu });
  }
}

/// Remplit les six menus avec ce que Rust a donné.
function fillCharacteristics(): void {
  for (const which of CHARACTERISTICS) {
    const armed = boxes.get(which.key);
    if (!armed) {
      continue;
    }
    armed.menu.replaceChildren();
    for (const item of options.get(which.key) ?? []) {
      const entry = document.createElement("option");
      entry.value = String(item.id);
      entry.textContent = item.label;
      armed.menu.append(entry);
    }
  }
}

/// Ce que les six cases valent ensemble : le changement qu'on demande.
///
/// Une case décochée n'apparaît pas — `null` veut dire « on n'y touche pas ».
/// Une case cochée porte la valeur de son menu, et « Non précisé » y est une
/// valeur comme une autre : celle du vide (décision de Fabrice, 27/07/2026).
function askedChange(): Record<string, number | null> {
  const change: Record<string, number | null> = {
    category: null,
    assignment: null,
    payment_mode: null,
    payee: null,
    project: null,
    status: null,
  };
  for (const which of CHARACTERISTICS) {
    const armed = boxes.get(which.key);
    if (armed?.box.checked) {
      change[which.field] = Number(armed.menu.value);
    }
  }
  return change;
}

function somethingIsChecked(): boolean {
  return CHARACTERISTICS.some((which) => boxes.get(which.key)?.box.checked ?? false);
}

/// **Les engrenages ne s'allument que lorsqu'ils ont quelque chose à faire** :
/// au moins une ligne prise, et au moins une case cochée (choix de Fabrice,
/// 27/07/2026). Un bouton qui refuse après coup laisse croire qu'on a agi ;
/// un bouton éteint dit d'avance ce qui manque.
function refreshApplyButton(): void {
  applyButton.disabled = !(table.selected().length > 0 && somethingIsChecked());
}

// --- Les trois gestes ---------------------------------------------------

async function reload(): Promise<void> {
  try {
    const data = await invoke<Lines>("quick_classification_lines", {
      accountId,
      from: fromField.value,
      to: toField.value,
    });
    table.setRows(data.rows);
    pending = data.pending;
    say(pending > 0 ? data.pending_text : t("quick-multiselect-help"));
    refreshApplyButton();
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// Le premier icône du panneau bleu. **En mémoire, et nulle part ailleurs.**
async function applyToSelection(): Promise<void> {
  if (table.selected().length === 0 || !somethingIsChecked()) {
    say(t("quick-select-lines"), true);
    return;
  }
  try {
    const done = await invoke<Applied>("quick_classification_apply", {
      accountId,
      ids: table.selected(),
      change: askedChange(),
    });
    await reload();
    say(done.said);
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

/// L'enregistrement : le seul geste de cette fenêtre qui touche le disque, et
/// il demande confirmation avant.
///
/// Rend vrai quand tout est parti — ce dont la porte a besoin pour savoir si
/// elle peut s'ouvrir.
async function saveEverything(askFirst = true): Promise<boolean> {
  if (pending === 0) {
    say(t("quick-nothing-to-save"));
    return true;
  }
  try {
    if (askFirst) {
      const question = await invoke<string>("quick_classification_question", {
        count: pending,
      });
      if (!(await askYesNo(question, t("ui-yes"), t("ui-no")))) {
        return false;
      }
    }
    const said = await invoke<string>("quick_classification_save", { accountId });
    await reload();
    say(said);
    return true;
  } catch (error) {
    say(tError("ui-save-failed", error), true);
    return false;
  }
}

/// La porte, et **sa question à trois issues** (décision de Fabrice,
/// 27/07/2026) : enregistrer, abandonner, rester. Un Oui/Non aurait forcé un
/// choix entre perdre le travail sans le vouloir et écrire sans l'avoir
/// demandé.
///
/// Rend vrai quand il n'y a plus rien qui retienne.
async function settleBeforeLeaving(): Promise<boolean> {
  if (pending === 0) {
    return true;
  }
  const answer = await askThreeWays(
    t("quick-leave-question"),
    t("quick-leave-save"),
    t("quick-leave-discard"),
    t("quick-leave-stay"),
  );
  if (answer === "stay") {
    return false;
  }
  if (answer === "first") {
    return saveEverything(false);
  }
  // Abandonner : le brouillon est jeté par Rust, et rien n'a jamais atteint le
  // disque. C'est exactement ce que la fenêtre promet.
  return true;
}

async function leave(): Promise<void> {
  try {
    if (!(await settleBeforeLeaving())) {
      return;
    }
    await invoke("close_quick_classification");
  } catch (error) {
    say(tError("ui-close-failed", error), true);
  }
}

// --- L'arrivée dans la fenêtre ------------------------------------------

/// Charge un compte : **la structure est remplacée**, jamais complétée.
///
/// Fabrice a nommé cette faute avant qu'elle n'arrive — « il faut que la
/// structure en RAM soit obligatoirement vide avant de la charger ». Elle est
/// rendue impossible côté noyau, où charger construit une structure neuve ;
/// ici, il suffit de la demander.
async function openAccount(id: number): Promise<void> {
  accountId = id;
  history.replaceState(null, "", `?account=${accountId}`);
  table.clearSelection();
  try {
    await invoke<number>("quick_classification_load", { accountId });
    // Son nom, pour le titre. Il ne vaut pas de faire échouer l'ouverture :
    // s'il manque, la fenêtre s'ouvre quand même et garde le nom d'avant.
    accountLabel =
      (await invoke<Item[]>("list_accounts").catch(() => [] as Item[])).find(
        (account) => account.id === accountId,
      )?.label ?? accountLabel;
    await reload();
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

element<HTMLButtonElement>("apply").addEventListener("click", () => void applyToSelection());
element<HTMLButtonElement>("save").addEventListener("click", () => void saveEverything());
element<HTMLButtonElement>("close").addEventListener("click", () => void leave());

for (const field of [fromField, toField]) {
  field.addEventListener("change", () => void reload());
}

void listen(CHANGED_EVENT, () => void reload());

/// Redemandée pour un autre compte. **On demande d'abord ce qu'il advient du
/// brouillon** : changer de compte en silence emporterait un travail que
/// personne n'a abandonné — c'est la faute que les fiches ont eue, où une
/// saisie disparaissait derrière le dos de l'utilisateur.
void listen<string>(PARAMETERS_EVENT, (event) => {
  const asked = Number(new URLSearchParams(event.payload).get("account") ?? 0);
  void (async () => {
    if (asked !== accountId && !(await settleBeforeLeaving())) {
      return;
    }
    await openAccount(asked);
  })();
});

/// **Tous les mots de la fenêtre, posés en un seul endroit.**
///
/// Une fenêtre de Radinus est bâtie une fois et jamais détruite : changer de
/// langue ne la reconstruit pas, il faut qu'elle sache se rhabiller. Ce qui
/// pose un mot est donc ici et nulle part ailleurs — une étiquette ajoutée
/// demain suivra la langue sans que personne y pense.
///
/// **Les six cases ne se rebâtissent pas**, seules leurs étiquettes se
/// reposent : ce qui est coché et ce qui est choisi dans les six menus est un
/// changement que personne n'a encore appliqué, et changer de langue n'est pas
/// une raison de le jeter.
///
/// `alsoTheNumbers` dit d'où l'on vient. À l'ouverture, les lignes viennent
/// plus bas, une fois passée la barrière de `startup_error`, les six listes
/// lues et le compte ouvert. Au changement de langue elles sont redemandées :
/// les montants, les « Non précisé » des colonnes et la phrase de la barre —
/// combien de lignes attendent d'être enregistrées — sont écrits par le noyau.
async function dress(alsoTheNumbers = true): Promise<void> {
  for (const which of CHARACTERISTICS) {
    const armed = boxes.get(which.key);
    if (armed) {
      armed.label.textContent = t(which.label);
    }
  }
  table.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));

  element<HTMLElement>("dates-title").textContent = t("quick-dates-title");
  element<HTMLElement>("change-title").textContent = t("quick-change-title");
  element<HTMLElement>("from-label").textContent = t("quick-from");
  element<HTMLElement>("to-label").textContent = t("quick-to");
  applyButton.title = t("quick-title-apply");
  element<HTMLElement>("save").title = t("quick-title-save");
  element<HTMLElement>("close").title = t("ui-title-close");

  // Le menu Période, celui de F02, du tableau de bord et de la courbe.
  // **L'encoche part sur l'année en cours**, parce que c'est sur elle que la
  // fenêtre s'ouvre — 01/01 au 31/12 dans la capture de Fabrice, et le plan
  // d'action dit la même chose. Une encoche posée ailleurs qu'à l'endroit
  // affiché est un mensonge.
  //
  // Ses vingt-deux entrées sont autant de mots : il se rebâtit tout entier, et
  // la barre est vidée d'abord — sans quoi un second menu s'ajouterait au
  // premier à chaque changement de langue. Les deux dates, elles, ne bougent
  // pas : le menu les écrit, il ne les lit pas.
  const menu = element<HTMLElement>("window-menu");
  menu.replaceChildren();
  const entry = document.createElement("button");
  entry.type = "button";
  entry.className = "window-menu__entry";
  entry.textContent = t("quick-menu-period");
  menu.append(
    buildPeriodMenu(
      entry,
      (period) => {
        fromField.value = period.from;
        toField.value = period.to;
        void reload();
      },
      [fromField, toField],
      "period-this-year:period-whole-year",
    ),
  );
  if (alsoTheNumbers) {
    await reload();
  }
}

void (async () => {
  await loadTexts(null);
  buildCharacteristics();
  await dress(false);
  // L'export au clic droit ne pose aucun mot et ne se refait pas : c'est une
  // écoute sur le tableau, et une seconde ferait deux exports pour un clic.
  table.exportOnRightClick(say);

  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    return;
  }

  // Les six listes des menus : les cinq nomenclatures avec « Non précisé » en
  // tête — c'est lui qui efface — et les trois statuts, qui n'en ont pas.
  const combos = await invoke<Combos>("list_operation_combos");
  options.set("category", combos.category);
  options.set("assignment", combos.assignment);
  options.set("payment-mode", combos.payment_mode);
  options.set("payee", combos.payee);
  options.set("project", combos.project);
  options.set("status", await invoke<Item[]>("list_operation_statuses"));
  fillCharacteristics();

  const year = wholeYear(new Date().getFullYear());
  fromField.value = year.from;
  toField.value = year.to;
  await openAccount(Number(new URLSearchParams(window.location.search).get("account") ?? 0));
  // Le titre porte le nom du compte, comme la liste des opérations : le noyau
  // le compose, la fenêtre lui rend la clef et le nom. **Il est relu à chaque
  // changement de langue et non figé ici** — la fenêtre est redemandée sur
  // d'autres comptes au fil de sa vie, et un titre qui nommerait le compte de
  // la première ouverture serait la pire sorte de faute : un écran juste sous
  // un titre faux.
  onLanguageChanged(dress, {
    key: "window-quick-classification-title",
    get argument(): string {
      return accountLabel;
    },
  });
})();
