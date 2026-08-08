// F01 — la fenêtre d'accueil.
//
// Le bandeau, puis trois bandes : les trois soldes totaux, une tuile par
// compte ouvert, et les deux anneaux par poste budgétaire du mois en cours.
//
// **La règle de cette fenêtre, et elle vaut d'être relue avant d'y ajouter
// quoi que ce soit** (décision de Fabrice, 03/08/2026, tracée au document 04
// F01 et à `docs/Decisions.md` P-8) :
//
// > L'accueil est la vue SANS UN CLIC. Tout ce qui demande un réglage n'y a
// > pas sa place.
//
// **Précisée le 03/08/2026** : les anneaux se creusent d'un clic — un secteur
// montre les catégories de son poste. Ce n'est pas un réglage : rien à
// choisir, rien à saisir, rien qui se mémorise d'une ouverture à l'autre.
// C'est une lecture plus fine de ce qui est déjà à l'écran, et l'accueil
// répond toujours sans qu'on lui ait rien demandé.
//
// C'est ce qui fait que les mêmes chiffres qu'en F07 et F19 n'y sont pas une
// redite : F07 est un tableau qu'on ouvre exprès, F19 demande les comptes, la
// période et trois interrupteurs. L'accueil ne demande rien et a déjà répondu
// quand la fenêtre s'affiche. Le jour où il manquera ici un sélecteur d'année
// ou un menu Période, c'est qu'il fallait ouvrir F19.
//
// **Une seule commande** pour tout ce qu'elle montre : elle est appelée au
// lancement du logiciel, c'est-à-dire au moment précis où l'on juge s'il est
// lent.

import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { drawCurve, type CurvePoint } from "./windows/curve";
import { drawRing, type RingSlice } from "./windows/ring";
import { loadTexts, onLanguageChanged, t, tError } from "./windows/texts";

interface WelcomeAccount {
  id: number;
  label: string;
  bank: string;
  balance_bank: string;
  balance_real: string;
  balance_final: string;
  /// Les trois montants en nombre : la tuile n'a besoin que du **signe**, pour
  /// peindre en rouge foncé. Elle ne relit jamais un montant dans le texte
  /// qu'on lui a donné.
  balance_bank_value: number;
  balance_real_value: number;
  balance_final_value: number;
}

interface Welcome {
  accounts: WelcomeAccount[];
  total_bank: string;
  total_real: string;
  total_final: string;
  total_bank_value: number;
  total_real_value: number;
  total_final_value: number;
  accounts_line: string;
  spending_title: string;
  earning_title: string;
  spending_legend: string;
  earning_legend: string;
  spending_back: string | null;
  earning_back: string | null;
  spending_line: number | null;
  spending_category: number | null;
  earning_line: number | null;
  earning_category: number | null;
  spending_curve: CurvePoint[];
  earning_curve: CurvePoint[];
  month: string;
  previous_month: string;
  next_month: string;
  at_first_month: boolean;
  at_last_month: boolean;
  spending: RingSlice[];
  earning: RingSlice[];
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

/// Le mois que les deux anneaux montrent. `null` à l'ouverture : c'est le noyau
/// qui dit alors quel jour on est, et la fenêtre n'a pas d'horloge à consulter.
///
/// **Un seul mois pour les deux cartes** (décision de Fabrice, 03/08/2026) :
/// les chevrons sont sur chacune, mais ils bougent celui-ci. Voir les dépenses
/// de juillet à côté des gains d'août donnerait une balance fausse à l'œil, et
/// aucun nombre à l'écran ne le dirait.
let shownMonth: string | null = null;

/// Le mois d'avant et celui d'après, **calculés par le noyau** et gardés tels
/// quels. La fenêtre ne fait aucune arithmétique de date : elle n'a jamais à
/// savoir que janvier moins un mois change d'année, ni où sont les bornes.
let previousMonth: string | null = null;
let nextMonth: string | null = null;

/// Où en est chaque carte dans sa descente.
///
/// **Trois niveaux, et on descend toujours d'un clic** (décision de Fabrice,
/// 03/08/2026) : les postes budgétaires, les catégories d'un poste, puis la
/// courbe du cumul d'une catégorie. Rien du tout, c'est le premier niveau ; un
/// poste seul, le deuxième ; un poste **et** une catégorie, la courbe.
///
/// **On ne remonte jamais en cliquant le dessin** — c'était le cas quand il n'y
/// avait que deux niveaux, ça ne l'est plus : cliquer descend, toujours, et un
/// lien sous la carte remonte. Un même geste qui ferait tantôt l'un tantôt
/// l'autre selon l'endroit où l'on se trouve serait impossible à apprendre.
///
/// **Les deux cartes sont indépendantes** : elles n'ont pas les mêmes postes,
/// et descendre dans les dépenses n'a aucune raison de toucher aux gains.
///
/// **Elles survivent au changement de mois**, et c'est tout l'intérêt de la
/// chose : rester dans « Alimentation » et faire défiler les mois, c'est ce qui
/// transforme le dessin en outil de comparaison. Un mois sans rien n'en fait
/// pas sortir — il montre une carte vide, et le mois suivant retrouve la
/// sélection.
type Side = "spending" | "earning";
type Drill = { line: number | null; category: number | null };
const SIDES: Side[] = ["spending", "earning"];
const drill: Record<Side, Drill> = {
  spending: { line: null, category: null },
  earning: { line: null, category: null },
};

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("status-bar__info--alert", alert);
}

/// Un montant négatif s'écrit en rouge foncé, comme partout ailleurs. La
/// décision se prend sur le nombre, jamais sur le texte.
function paint(node: HTMLElement, value: number, negativeClass: string): void {
  node.classList.toggle(negativeClass, value < 0);
}

/// Les tuiles de comptes. **Chacune ouvre F02 sur son compte** : l'accueil
/// n'est pas qu'un tableau, c'est aussi une porte d'entrée.
function drawTiles(accounts: WelcomeAccount[]): void {
  const holder = element<HTMLElement>("tiles");
  holder.replaceChildren();

  // **Rien à faire, et une porte pour en sortir** (Fabrice, 04/08/2026). La
  // phrase disait « créez-en un par le menu Comptes, ou reprenez vos données
  // par Fichier › Importer une sauvegarde Radinus 1.x… » : le second chemin
  // n'existe plus depuis le 03/08, et le premier demandait d'aller chercher
  // ailleurs ce qu'on peut donner ici.
  //
  // **Deux phrases, et non une phrase coupée en deux.** Le constat, puis
  // l'action ; le lien porte la seconde en entier. Découper « Créez-en un » +
  // « en cliquant ici » aurait obligé la fenêtre à recoller des morceaux dans
  // un ordre qui n'est pas le même partout — en allemand le verbe finit la
  // phrase — et une fenêtre de Radinus ne compose aucune phrase.
  if (accounts.length === 0) {
    const empty = document.createElement("p");
    empty.className = "card__empty";
    empty.textContent = t("welcome-no-account");

    const create = document.createElement("button");
    create.type = "button";
    create.className = "card__link";
    create.textContent = t("welcome-no-account-create");
    create.addEventListener("click", () => {
      // « A » comme *Ajouter* : le vocabulaire de l'original, celui que la
      // liste des comptes emploie déjà pour ouvrir une fiche vierge.
      void invoke("open_account_form", { mode: "A", id: null }).catch((error) =>
        say(tError("ui-open-failed", error), true),
      );
    });

    holder.append(empty, create);
    return;
  }

  for (const account of accounts) {
    const tile = document.createElement("button");
    tile.type = "button";
    tile.className = "tile";
    tile.title = t("welcome-open-account");

    const name = document.createElement("span");
    name.className = "tile__name";
    name.textContent = account.label;
    const bank = document.createElement("span");
    bank.className = "tile__bank";
    bank.textContent = account.bank;
    tile.append(name, bank);

    for (const [key, text, value, strong] of [
      ["welcome-tile-bank", account.balance_bank, account.balance_bank_value, true],
      ["welcome-tile-real", account.balance_real, account.balance_real_value, false],
      ["welcome-tile-final", account.balance_final, account.balance_final_value, false],
    ] as [string, string, number, boolean][]) {
      const row = document.createElement("span");
      row.className = strong ? "tile__row tile__row--strong" : "tile__row";
      const label = document.createElement("span");
      label.textContent = t(key);
      const amount = document.createElement("span");
      amount.textContent = text;
      paint(amount, value, "tile__amount--negative");
      row.append(label, amount);
      tile.append(row);
    }

    tile.addEventListener("click", () => {
      void invoke("open_operations_list", { accountId: account.id }).catch((error) => {
        say(tError("ui-open-failed", error), true);
      });
    });
    holder.append(tile);
  }
}

/// **Un clic sur un secteur ou sur une ligne de légende fait descendre.**
///
/// Une seule règle : depuis les postes on entre dans un poste, depuis les
/// catégories on entre dans une catégorie, et il n'y a rien sous la courbe.
/// On ne remonte pas d'ici — c'est le lien sous la carte qui le fait.
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

/// **Le lien qui remonte d'un niveau.**
///
/// Il défait exactement le dernier clic, dans l'autre sens : la courbe rend les
/// catégories, les catégories rendent les postes. Son texte vient du noyau —
/// c'est le nom du niveau où il mène — et il n'existe pas tout en haut, où il
/// n'y aurait nulle part où aller.
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
/// côte à côte — et F19 s'en sert aussi. Un titre au-dessus et un lien en
/// dessous demandent une colonne, alors on la pose dedans. Rend la colonne et
/// l'étage du milieu, celui où le dessin va.
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

/// L'en-tête de la carte quand il n'y a pas de légende pour le porter.
///
/// À la courbe, c'est **la seule chose à l'écran qui nomme ce qu'on regarde** :
/// le titre de la carte dit « Dépenses — août 2026 » et rien de plus. Sans
/// cette ligne, on saurait qu'on regarde une catégorie sans savoir laquelle.
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
  // Le chevron dit le sens ; le mot dit la destination. Le chevron est écrit
  // ici et non dans le dictionnaire : ce n'est pas une phrase, c'est une
  // flèche.
  back.textContent = `‹ ${text}`;
  back.addEventListener("click", go);
  column.append(back);
}

async function reload(): Promise<void> {
  try {
    const shown = await invoke<Welcome>("welcome", {
      month: shownMonth,
      spendingLine: drill.spending.line,
      spendingCategory: drill.spending.category,
      earningLine: drill.earning.line,
      earningCategory: drill.earning.category,
    });

    // Le mois revient du noyau — borné, et le sien fait foi : demander
    // décembre 2549 et recevoir décembre 2550 doit se voir dans la fenêtre.
    shownMonth = shown.month;
    previousMonth = shown.previous_month;
    nextMonth = shown.next_month;
    // Le niveau revient du noyau, comme le mois : c'est ce qu'il a réellement
    // dessiné qui fait foi, pas ce que la fenêtre croyait avoir demandé.
    drill.spending = { line: shown.spending_line, category: shown.spending_category };
    drill.earning = { line: shown.earning_line, category: shown.earning_category };
    for (const side of SIDES) {
      element<HTMLButtonElement>(`${side}-previous`).disabled = shown.at_first_month;
      element<HTMLButtonElement>(`${side}-next`).disabled = shown.at_last_month;
    }

    for (const [id, text, value] of [
      ["total-bank", shown.total_bank, shown.total_bank_value],
      ["total-real", shown.total_real, shown.total_real_value],
      ["total-final", shown.total_final, shown.total_final_value],
    ] as [string, string, number][]) {
      const node = element<HTMLElement>(id);
      node.textContent = text;
      paint(node, value, "card__figure--negative");
    }

    // « 4 comptes ouverts » : la phrase entière vient du noyau, pluriel
    // compris. Un pluriel n'est pas le même dans les trois langues.
    element<HTMLElement>("total-bank-detail").textContent = shown.accounts_line;
    element<HTMLElement>("accounts-title").textContent = t("welcome-accounts");
    element<HTMLElement>("spending-title").textContent = shown.spending_title;
    element<HTMLElement>("earning-title").textContent = shown.earning_title;

    drawTiles(shown.accounts);

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
        drawCurve(drawing, curve, { emptyText: t("welcome-nothing") });
        heading(column, legend);
      } else {
        drawRing(drawing, shown[side], {
          emptyText: t("welcome-nothing"),
          relief: true,
          legendTitle: legend,
          onPick: (slice) => pick(side, slice),
        });
      }
      link(column, back, () => goBack(side));
    }

    say(shown.accounts.length === 0 ? "" : t("welcome-open-account"));
    element<HTMLElement>("welcome").hidden = false;
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// Pose les mots de la fenêtre, puis relit ses chiffres.
///
/// Une fenêtre de Radinus est bâtie une fois et jamais détruite : changer de
/// langue ne la reconstruit pas, il faut qu'elle sache se rhabiller. Et ce
/// qu'elle montre n'est pas seulement écrit dans une langue, il y est
/// **calculé** — les montants ont leurs séparateurs, le mois a son nom, le
/// pluriel des comptes est compté par Fluent — donc se rhabiller, pour elle,
/// c'est tout relire.
async function dress(): Promise<void> {
  // La langue du document suit celle du logiciel : elle commande la coupure
  // des mots et ce qu'annonce un lecteur d'écran.
  document.documentElement.lang = t("ui-language-tag");

  element<HTMLImageElement>("mascot").alt = t("welcome-mascot-alt");

  // La version vient du binaire qui tourne : elle était écrite en dur ici, et
  // une copie de plus finit toujours par annoncer autre chose que ce qu'on
  // exécute.
  element<HTMLElement>("version").textContent = await invoke<string>("app_version");

  for (const [id, key] of [
    ["banner-title", "welcome-banner-title"],
    ["slogan-one", "welcome-slogan-one"],
    ["slogan-two", "welcome-slogan-two"],
    ["total-bank-title", "welcome-total-bank"],
    ["total-real-title", "welcome-total-real"],
    ["total-final-title", "welcome-total-final"],
    ["total-real-detail", "welcome-total-real-detail"],
    ["total-final-detail", "welcome-total-final-detail"],
    ["accounts-title", "welcome-accounts"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }

  element<HTMLElement>("refresh").title = t("welcome-refresh");
  for (const side of ["spending", "earning"]) {
    element<HTMLElement>(`${side}-previous`).title = t("welcome-previous-month");
    element<HTMLElement>(`${side}-next`).title = t("welcome-next-month");
  }

  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    return;
  }
  await reload();
}

// Les quatre chevrons et le bouton de relecture.
//
// **Les quatre chevrons commandent le même mois** : celui de la carte des gains
// recule les dépenses avec lui. C'est ce que Fabrice a tranché, et c'est ce qui
// empêche de lire deux mois différents côte à côte sans s'en apercevoir.
//
// **Et ils ne touchent pas au niveau des anneaux** — ce n'est pas un oubli,
// c'est le cœur de la chose. Rester dans « Alimentation » en faisant défiler
// les mois, c'est ce qui fait de l'anneau creusé un outil de comparaison
// plutôt qu'un détail. Un mois sans rien n'en fait pas sortir non plus : il
// montre un anneau vide, et le mois suivant retrouve le poste.
for (const side of SIDES) {
  element<HTMLButtonElement>(`${side}-previous`).addEventListener("click", () => {
    shownMonth = previousMonth;
    void reload();
  });
  element<HTMLButtonElement>(`${side}-next`).addEventListener("click", () => {
    shownMonth = nextMonth;
    void reload();
  });
}

// Relire **sans quitter le mois regardé** : rafraîchir n'est pas revenir à
// aujourd'hui, et ramener l'utilisateur en arrière sans le lui dire serait une
// surprise.
element<HTMLButtonElement>("refresh").addEventListener("click", () => void reload());

// **Les chiffres d'ici vieillissent dès qu'on touche à autre chose.** Un compte
// créé, une opération saisie, un relevé intégré, et les trois totaux sont
// périmés — sans que l'accueil, qui n'a rien fait, ait de quoi le savoir.
//
// Deux filets plutôt qu'un, et c'est délibéré. Les événements d'abord : ils
// sont diffusés à tout le monde et arrivent tout de suite. Le retour à l'écran
// ensuite, parce que **deux tentatives de rafraîchissement par événement ont
// échoué chez Fabrice le 26/07/2026** sur la fenêtre des statistiques — un
// avertissement qui n'arrive pas est pire que pas d'avertissement du tout,
// puisqu'on croit avoir prévenu. Relire est une lecture, elle ne coûte rien
// et ne peut rien casser.
for (const event of ["data-changed:operations", "data-changed:accounts-list"]) {
  void listen(event, () => void reload());
}
window.addEventListener("focus", () => void reload());

void (async () => {
  await loadTexts(null);
  await dress();
  onLanguageChanged(dress, { key: "window-main-title" });
})();
