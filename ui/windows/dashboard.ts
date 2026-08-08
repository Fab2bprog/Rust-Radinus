// F19 — « Tableau de bord ».
//
// Cinq cartes : deux anneaux, deux tuiles à gros chiffres et la balance. Une
// période et trois interrupteurs les commandent toutes.
//
// **Les deux anneaux se creusent depuis le 04/08/2026** (demande de Fabrice :
// « le même style 3D et la même logique que la fenêtre d'accueil »). Un clic
// sur un poste budgétaire montre ses catégories, un clic sur une catégorie
// laisse la place à la courbe de son cumul, et deux liens sous le dessin
// remontent. Le niveau **survit** à un changement de période ou d'interrupteur :
// c'est ce qui permet de comparer deux périodes sans se reperdre.
//
// C'est le même code qu'à l'accueil, et rien n'a été recopié : les deux
// fenêtres partagent l'anneau, la courbe et la carte.
//
// **Les anneaux sont dessinés à la main, en SVG.** Aucune bibliothèque de
// graphiques n'est entrée dans le projet pour cela : un anneau, ce sont des
// arcs de cercle, et une dépendance de plus se paie à chaque mise à jour du
// logiciel pendant des années. Les couleurs sont **celles de l'original**,
// relevées au pixel sur la capture de Fabrice — la fidélité l'emporte, mais
// elles ont été mesurées et ce qu'elles valent lui a été dit.
//
// Ce que le dessin doit à la lecture, et non au goût : la valeur est écrite
// **sur** chaque secteur (donc l'identité ne repose jamais sur la seule
// couleur), les secteurs sont séparés par un filet de la couleur du fond, et
// la légende nomme chaque poste à côté de son carré.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { buildPeriodMenu, currentMonth, type Period } from "./period";
import { drawCurve, type CurvePoint } from "./curve";
import { drawRing, type RingSlice } from "./ring";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

const PARAMETERS_EVENT = "window-parameters:dashboard";
const CHANGED_EVENT = "data-changed:dashboard";

interface Slice {
  id: number;
  label: string;
  amount: number;
  /// Le montant tel qu'il s'écrit, rédigé par le noyau.
  text: string;
}

interface Dashboard {
  spending: Slice[];
  earning: Slice[];
  /// L'en-tête de la carte : « Postes budgétaires », « Catégories », ou le nom
  /// de la catégorie à la courbe. **C'est lui qui dit à quel niveau on est**,
  /// depuis que les deux titres ont été raccourcis (Fabrice, 04/08/2026).
  spending_legend: string;
  earning_legend: string;
  /// Le nom du niveau où le lien de retour mène, ou `null` tout en haut.
  spending_back: string | null;
  earning_back: string | null;
  /// Où en est chaque carte dans sa descente, tel que le noyau l'a réellement
  /// dessiné. La fenêtre le repose et le renvoie au coup suivant.
  spending_line: number | null;
  spending_category: number | null;
  earning_line: number | null;
  earning_category: number | null;
  spending_curve: CurvePoint[];
  earning_curve: CurvePoint[];
  debits: string;
  credits: string;
  balance: string;
  balance_value: number;
  accounts: string;
}

/// Les deux côtés de la fenêtre. Ils font la même chose et ne diffèrent que
/// par leur nom : un seul code les sert tous les deux.
type Side = "spending" | "earning";
const SIDES: Side[] = ["spending", "earning"];

/// Où en est une carte dans sa descente : le poste budgétaire creusé, puis la
/// catégorie. Rien de plus — il n'y a que trois niveaux.
type Drill = { line: number | null; category: number | null };

/// **Le niveau survit à un changement de période ou d'interrupteur** (décision
/// de Fabrice, 04/08/2026, la même qu'à l'accueil pour les mois) : c'est ce qui
/// permet de comparer deux périodes dans la même catégorie sans se reperdre. Un
/// poste sans rien sur la nouvelle période montre un anneau vide, et on y
/// reste.
const drill: Record<Side, Drill> = {
  spending: { line: null, category: null },
  earning: { line: null, category: null },
};

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");
const fromField = element<HTMLInputElement>("from");
const toField = element<HTMLInputElement>("to");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

/// Les comptes choisis, arrivés par l'adresse. En changer, c'est repasser par
/// le choix des comptes.
let accountIds: number[] = [];

/// Les trois interrupteurs. Tous allumés au départ, comme les cinq de la
/// statistique : le tableau de bord montre tout tant qu'on ne lui a rien
/// retiré.
const switches = {
  pointed: true,
  committed: true,
  planned: true,
};

type SwitchName = keyof typeof switches;

const SWITCHES: [SwitchName, string][] = [
  ["pointed", "dashboard-switch-pointed"],
  ["committed", "dashboard-switch-committed"],
  ["planned", "dashboard-switch-planned"],
];

// --- L'anneau -------------------------------------------------------------
//
// **Le dessin est sorti d'ici** le 03/08/2026, dans `ring.ts`, quand la fenêtre
// d'accueil en a eu besoin à son tour : il est partagé plutôt que recopié, la
// même règle que le menu Période sorti de F02. Le rendu de F19 n'a pas bougé
// d'un pixel — c'est le mode par défaut du module, et le relief est réservé à
// l'accueil (décision de Fabrice du 03/08/2026 : il l'a voulu là et pas ici).

// --- Les interrupteurs ----------------------------------------------------

function buildSwitches(): void {
  const bar = element<HTMLElement>("switches");
  bar.replaceChildren();
  for (const [name, key] of SWITCHES) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "switch";
    button.dataset.name = name;
    button.setAttribute("aria-pressed", String(switches[name]));

    const knob = document.createElement("span");
    knob.className = "switch__knob";
    const label = document.createElement("span");
    label.className = "switch__label";
    label.textContent = t(key);
    button.append(knob, label);

    button.addEventListener("click", () => {
      switches[name] = !switches[name];
      button.setAttribute("aria-pressed", String(switches[name]));
      void reload();
    });
    bar.append(button);
  }
}

// --- Le creusement --------------------------------------------------------
//
// Tout ce bloc est le jumeau de celui de l'accueil, et volontairement : les
// deux fenêtres montrent les mêmes anneaux et doivent y répondre pareil.

/// **Un clic sur un secteur ou sur une ligne de légende fait descendre.**
///
/// Une seule règle : depuis les postes on entre dans un poste, depuis les
/// catégories on entre dans une catégorie, et il n'y a rien sous la courbe. On
/// ne remonte pas d'ici — c'est le lien sous le dessin qui le fait.
///
/// `slice` vaut `null` quand c'est l'anneau vide qu'on a cliqué : il n'y a rien
/// à ouvrir, et le lien est là pour sortir.
function pick(side: Side, slice: RingSlice | null): void {
  if (!slice) {
    return;
  }
  const level = drill[side];
  if (level.line === null) {
    level.line = slice.id;
  } else if (level.category === null) {
    level.category = slice.id;
  } else {
    return;
  }
  void reload();
}

/// Le lien qui remonte d'un niveau. Il défait exactement le dernier clic, dans
/// l'autre sens.
function goBack(side: Side): void {
  const level = drill[side];
  if (level.category !== null) {
    level.category = null;
  } else {
    level.line = null;
  }
  void reload();
}

/// Les trois étages de la carte : le nom du niveau, le dessin, le lien.
///
/// **Le corps de la carte est une rangée** — l'anneau et sa légende s'y posent
/// côte à côte — donc la colonne se pose dedans plutôt que de retourner une
/// règle partagée. Rend la colonne et l'étage du milieu, celui du dessin.
function stack(holder: HTMLElement): [HTMLElement, HTMLElement] {
  holder.replaceChildren();
  const column = document.createElement("div");
  column.className = "card__stack";
  const drawing = document.createElement("div");
  drawing.className = "card__drawing";
  column.append(drawing);
  holder.append(column);
  return [column, drawing];
}

/// Le nom de ce qu'on regarde, au-dessus du dessin. À la courbe, c'est la seule
/// chose à l'écran qui nomme la catégorie : le titre de la carte ne dit plus
/// que « Dépenses ».
function heading(column: HTMLElement, text: string): void {
  const title = document.createElement("p");
  title.className = "card__subject";
  title.textContent = text;
  column.prepend(title);
}

/// Le lien qui remonte d'un niveau, sous le dessin. Absent tout en haut.
function link(column: HTMLElement, text: string | null, go: () => void): void {
  if (!text) {
    return;
  }
  const back = document.createElement("button");
  back.type = "button";
  back.className = "card__back";
  // Le chevron dit le sens, le mot dit la destination. Il est écrit ici et non
  // dans le dictionnaire : ce n'est pas une phrase, c'est une flèche.
  back.textContent = `‹ ${text}`;
  back.addEventListener("click", go);
  column.append(back);
}

// --- La lecture -----------------------------------------------------------

async function reload(): Promise<void> {
  if (accountIds.length === 0) {
    say(t("dashboard-no-account"), true);
    return;
  }
  try {
    const shown = await invoke<Dashboard>("dashboard", {
      accountIds,
      from: fromField.value,
      to: toField.value,
      switches,
      spendingLine: drill.spending.line,
      spendingCategory: drill.spending.category,
      earningLine: drill.earning.line,
      earningCategory: drill.earning.category,
    });

    // Le niveau revient du noyau : c'est ce qu'il a réellement dessiné qui fait
    // foi, pas ce que la fenêtre croyait avoir demandé.
    drill.spending = { line: shown.spending_line, category: shown.spending_category };
    drill.earning = { line: shown.earning_line, category: shown.earning_category };

    for (const side of SIDES) {
      const holder = element<HTMLElement>(side);
      const legend = side === "spending" ? shown.spending_legend : shown.earning_legend;
      const curve = side === "spending" ? shown.spending_curve : shown.earning_curve;
      const back = side === "spending" ? shown.spending_back : shown.earning_back;
      const [column, drawing] = stack(holder);

      // **La courbe remplace l'anneau, elle ne s'ajoute pas à lui.** Au
      // troisième niveau il n'y a plus de parts à montrer : un anneau d'une
      // seule catégorie serait un cercle plein qui n'apprendrait rien.
      if (curve.length > 0) {
        drawCurve(drawing, curve, { emptyText: t("dashboard-nothing") });
        heading(column, legend);
      } else {
        drawRing(drawing, shown[side], {
          emptyText: t("dashboard-nothing"),
          relief: true,
          legendTitle: legend,
          onPick: (slice) => pick(side, slice),
        });
      }
      link(column, back, () => goBack(side));
    }

    element<HTMLElement>("debits").textContent = shown.debits;
    element<HTMLElement>("credits").textContent = shown.credits;

    const balance = element<HTMLElement>("balance");
    balance.textContent = shown.balance;
    // Rouge foncé quand elle est négative, comme dans l'original : c'est la
    // seule chose que cette carte a besoin de dire d'un coup d'œil.
    balance.classList.toggle("card__figure--negative", shown.balance_value < 0);

    say(shown.accounts);
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

function readParameters(query: string): void {
  const parameters = new URLSearchParams(query);
  accountIds = (parameters.get("accounts") ?? "")
    .split(",")
    .map((piece) => Number(piece.trim()))
    .filter((id) => Number.isFinite(id) && id > 0);
  history.replaceState(null, "", `?accounts=${accountIds.join(",")}`);
}

/// La barre de menus : la Période, partagée avec F02, et Divers, inerte tant
/// que Fabrice ne m'aura pas dit ce qu'il contient.
function buildMenu(): void {
  const bar = element<HTMLElement>("window-menu");
  bar.replaceChildren();

  const period = document.createElement("button");
  period.type = "button";
  period.className = "window-menu__entry";
  period.textContent = t("dashboard-menu-period");
  bar.append(
    buildPeriodMenu(
      period,
      (chosen: Period) => {
        fromField.value = chosen.from;
        toField.value = chosen.to;
        void reload();
      },
      [fromField, toField],
    ),
  );

  const misc = document.createElement("button");
  misc.type = "button";
  misc.className = "window-menu__entry";
  misc.textContent = t("dashboard-menu-misc");
  misc.disabled = true;
  bar.append(misc);
}

/// **Tous les mots de la fenêtre, posés en un seul endroit.**
///
/// Une fenêtre de Radinus est bâtie une fois et jamais détruite : changer de
/// langue ne la reconstruit pas, il faut qu'elle sache se rhabiller. Ce qui
/// pose un mot est donc ici et nulle part ailleurs — une étiquette ajoutée
/// demain suivra la langue sans que personne y pense.
///
/// Les trois interrupteurs se rebâtissent avec le reste : leur état vit dans
/// `switches` et non dans les boutons, donc les refaire ne rallume ni n'éteint
/// rien.
///
/// `alsoTheNumbers` dit d'où l'on vient. À l'ouverture, les cinq cartes
/// viennent plus bas, une fois passée la barrière de `startup_error` et les
/// comptes lus dans l'adresse. Au changement de langue, elles sont redemandées :
/// les montants, les noms de postes et la ligne des comptes sont écrits par le
/// noyau, dans la langue du moment.
async function dress(alsoTheNumbers = true): Promise<void> {
  for (const [id, key] of [
    ["from-label", "dashboard-from"],
    ["to-label", "dashboard-to"],
    ["spending-title", "dashboard-spending"],
    ["earning-title", "dashboard-earning"],
    ["debits-title", "dashboard-debits"],
    ["credits-title", "dashboard-credits"],
    ["balance-title", "dashboard-balance"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  for (const id of ["spending-enlarge", "earning-enlarge"]) {
    element<HTMLElement>(id).title = t("dashboard-enlarge");
  }
  element<HTMLElement>("close").title = t("ui-title-close");

  buildMenu();
  buildSwitches();
  if (alsoTheNumbers) {
    await reload();
  }
}

// **Redemandé sur d'autres comptes, il doit les entendre** : une fenêtre de
// Radinus est bâtie une fois et jamais détruite, donc la page n'est pas
// rechargée et les nouveaux comptes arrivent par cet événement. C'est la faute
// que la statistique a payée le 26/07/2026 ; elle ne se refait pas ici.
void listen<string>(PARAMETERS_EVENT, (event) => {
  readParameters(event.payload);
  void reload();
});

// Les opérations ont bougé ailleurs : les chiffres d'ici sont périmés.
void listen(CHANGED_EVENT, () => void reload());

for (const field of [fromField, toField]) {
  field.addEventListener("change", () => void reload());
}

element<HTMLButtonElement>("close").addEventListener("click", () => {
  void invoke("close_dashboard");
});

void (async () => {
  await loadTexts(null);

  await dress(false);

  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    return;
  }

  const month = currentMonth();
  fromField.value = month.from;
  toField.value = month.to;
  readParameters(window.location.search);
  await reload();
  onLanguageChanged(dress, { key: "window-dashboard-title" });
})();
