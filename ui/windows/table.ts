// The table every Radinus list window is built on.
//
// One column or seven, the behaviour is the same and is written once here:
// a header that sorts and reverses on a click, a funnel per column that
// filters as you type, multiple selection with Cmd/Ctrl and Shift, and a
// double-click that opens the record. The nomenclature lists have a single
// LIBELLE column; the accounts list has seven, and each of its columns has
// its own funnel (04_SPECIFICATIONS_FENETRES.md, F06 capture).
//
// The alternative was a second copy of this for the accounts, which is
// exactly what the author refused for the fiches: seven copies of a fault
// take seven times as long to remove.
//
// **The table never sorts the labels itself.** Rows arrive already ordered by
// the core, under the French collation measured on the author's archive;
// sorting on the first column only walks that order backwards, and sorting on
// another column uses the key the caller gives with it.

import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { copyText, oneCell, pureNumber } from "./clipboard";
import {
  contextLine,
  money as exportMoney,
  onRightClick,
  text as exportText,
  type MenuAddition,
  type MenuHeadEntry,
  type Sheet,
} from "./export";
import { t } from "./texts";

/// **La disposition d'un tableau** : l'ordre de ses colonnes, celles qui sont
/// masquées, et les largeurs tirées à la main, en pixels (Fabrice,
/// 04/10/2026). Les colonnes y sont repérées par leur `id`, jamais par leur
/// rang. C'est la forme que le noyau enregistre dans `Preferences`.
export interface TableLayout {
  order: string[];
  hidden: string[];
  widths: Record<string, number>;
  /// La couleur dont une colonne est teintée, par son nom. Absent d'une
  /// disposition enregistrée avant le 05/10/2026.
  colors?: Record<string, string>;
}

/// **Les neuf couleurs dont une colonne peut se teinter** (Fabrice,
/// 05/10/2026), dans l'ordre où il les a dictées. Les mêmes noms que dans le
/// noyau (`preferences::COLUMN_COLOURS`), qui refuse tout autre ; la teinte
/// elle-même est dans la feuille de style, sous `data-tint`.
export const COLUMN_COLOURS = [
  "red",
  "orange",
  "pink",
  "pastel-green",
  "green",
  "pastel-blue",
  "blue",
  "pastel-yellow",
  "yellow",
] as const;

/// L'événement par lequel une fenêtre apprend qu'un tableau a changé de
/// disposition ailleurs. Il porte le nom du tableau.
const LAYOUT_CHANGED = "table-layout-changed";

/// De combien la souris doit bouger, bouton enfoncé sur un en-tête, pour que
/// le geste soit un déplacement de colonne et non un clic de tri.
const MOVE_THRESHOLD = 6;

/// Le plancher d'une colonne en `fr` qui n'annonce pas de minimum, dans un
/// tableau dont des largeurs ont été tirées à la main.
const LEAST_SHARE = 60;

export interface Column<Row> {
  /// **Le nom de la colonne**, fixe et propre au tableau : `date`, `label`…
  /// C'est par lui que la disposition enregistrée la retrouve. Un rang ne
  /// survit pas à la colonne qu'une version suivante glisse au milieu ; un
  /// nom, si. Des minuscules, des chiffres et des tirets.
  ///
  /// Ne sert que dans un tableau qui a un `layoutName`. Une colonne sans nom
  /// y est tenue pour `fixed`.
  id?: string;
  /// **Une colonne qui ne se déplace ni ne se masque**, et que le menu des
  /// colonnes ne cite pas — le « + » qui déplie les sous-opérations (Fabrice,
  /// 04/10/2026 : d'accord pour qu'il reste en tête). Les colonnes fixes
  /// viennent en premier, dans l'ordre où elles sont déclarées.
  fixed?: boolean;
  /// Header text. A function, not a string: the columns are described when
  /// the module loads and the window only has its words a moment later.
  title: () => string;
  /// What this column shows for a row.
  cell: (row: Row) => string;
  /// What this column sorts and filters on, when it is not the shown text —
  /// an amount sorts by its value, not by « 1 549,81 € ».
  key?: (row: Row) => string | number;
  /// Right-aligned, for amounts.
  numeric?: boolean;
  /// Le montant de la cellule, **en micro-unités**, quand il y en a un.
  ///
  /// Une colonne d'argent s'affiche en toutes lettres (« 1 549,81 € ») mais
  /// s'exporte en nombre : sans cela le tableur reçoit du texte, et l'on ne
  /// peut plus le sommer (Fabrice, 26/07/2026 : « les montants : oui, nombre
  /// avec format monétaire »). Rendre `null` pour une cellule qui, sur cette
  /// ligne-là, ne porte pas de montant — la colonne Débit d'un crédit est
  /// vide à l'écran, elle reste vide dans le fichier.
  money?: (row: Row) => number | null;
  /// Builds the cell itself, when text is not enough — the « + » that unfolds
  /// an operation, a tick box, a coloured amount.
  render?: (row: Row, cell: HTMLElement) => void;
  /// Makes the cell a drop-down list on the selected row. A nomenclature is
  /// never typed: it is picked from the elements that exist (author's ruling,
  /// 25/07/2026). Only the selected row carries its combos — forty rows times
  /// five lists times fifty elements would be ten thousand entries in the
  /// document for nothing.
  editor?: {
    options: () => { id: number; label: string }[];
    value: (row: Row) => number;
    change: (row: Row, value: number) => void;
    /// Rows that may not be edited, if any.
    editable?: (row: Row) => boolean;
    /// Le dernier mot sur la liste elle-même, une fois bâtie et réglée sur
    /// la valeur de la ligne — une couleur, une marque. La colonne
    /// « Vérification » s'en sert pour teindre son choix.
    decorate?: (row: Row, combo: HTMLSelectElement) => void;
  };
  /// Width, as a CSS grid track. Defaults to an equal share.
  width?: string;
  /// **En dessous de cette largeur, la colonne ne se comprime plus** — le
  /// tableau déborde et son ascenseur horizontal apparaît. En pixels, et par
  /// colonne : une case à cocher tient dans 34, un libellé demande 200.
  ///
  /// N'a d'effet que si la fenêtre a demandé `horizontalScroll`. Sans elle,
  /// les colonnes en `fr` se partagent la place et se serrent jusqu'à
  /// l'illisible sans que rien ne dépasse — il n'y a alors rien à faire
  /// défiler.
  minWidth?: number;
}

/// Ce que le tableau sait dire de lui-même quand on l'exporte : d'où il vient.
/// Sans cela, l'export existe quand même, mais le fichier ne dit pas sur quoi
/// il portait.
export interface TableExport {
  /// Le nom de l'onglet et du fichier proposé.
  name: string;
  /// Ce que la fenêtre montrait — la période, les comptes, l'année.
  detail: string;
}

export interface TableOptions<Row> {
  container: HTMLElement;
  columns: Column<Row>[];
  identity: (row: Row) => number;
  /// Told whenever the selection changes, so the window can say something.
  onSelectionChange?: (selection: number[]) => void;
  /// Double-clicking a line. It is handed the row it was fired on, so a
  /// list can open the fiche of that record without going through the
  /// selection.
  onActivate?: (row: Row) => void;
  /// Shown in place of the rows when there are none at all.
  emptyText: () => string;
  /// Shown in place of the rows when a filter hides them all.
  filteredOutText: () => string;
  /// Extra class on a row, for what the window wants to mark out.
  rowClass?: (row: Row) => string | null;
  /// **One row at a time.** Some lists exist to answer a question that has a
  /// single answer — « sur quel compte voulez-vous travailler ? » shows the
  /// operations of one account and one only (Fabrice, 26/07/2026), so letting
  /// two be ticked would be offering a choice the window cannot honour.
  /// Cmd/Ctrl and Shift then do nothing more than a plain click.
  singleSelection?: boolean;
  /// Draw only the rows that are on screen. Needed above a few thousand
  /// lines — the author's own account holds 2 502 operations and the plan
  /// asks for 40 000 (PLAN_ACTION.md 5.1). Every row must then have the same
  /// height, which `rowHeight` gives in pixels.
  virtualized?: boolean;
  rowHeight?: number;
  /// **Un ascenseur horizontal sous les lignes** (Fabrice, 21/08/2026 : dans
  /// la liste des opérations, « l'absence de cela fait que certaines colonnes
  /// sont inaccessibles »).
  ///
  /// Éteint par défaut, et volontairement : les quatorze autres listes de
  /// Radinus tiennent dans leur fenêtre, et leur en-tête n'a aucune raison de
  /// se mettre à bouger. Seule la fenêtre qui en a besoin l'allume, en
  /// donnant un `minWidth` à ses colonnes.
  ///
  /// L'ascenseur appartient au **tableau** et se pose sous sa dernière ligne ;
  /// l'en-tête et la ligne des filtres suivent le défilement, faute de quoi
  /// les titres mentiraient sur les colonnes qu'ils surmontent.
  horizontalScroll?: boolean;
  /// **Le nom sous lequel la disposition de ce tableau est mémorisée**
  /// (Fabrice, 04/10/2026 : « il faudrait dans la base une préférence par
  /// tableau »). Le donner suffit à tout allumer : on glisse un en-tête pour
  /// déplacer sa colonne, le clic droit sur les en-têtes coche et décoche les
  /// colonnes et offre de tout rétablir, et l'ordre, la présence et les
  /// largeurs sont retenus à la fin de chaque geste.
  ///
  /// Le nom doit être l'un de ceux que le noyau connaît
  /// (`preferences::TABLES_WITH_A_LAYOUT`) : un nom inconnu n'enregistre rien.
  /// Un tableau qui n'en donne pas reste exactement ce qu'il était.
  layoutName?: string;
  /// D'où vient ce tableau, pour la ligne de tête du fichier exporté. Une
  /// fonction, parce que la période ou l'année changent pendant la vie de la
  /// fenêtre — elle est appelée au moment de l'export, pas avant.
  exportAs?: () => TableExport;
}

/// The little magnifying glass that opens a column's search field.
///
/// It used to be a downward triangle, which reads as « sort » and not as
/// « search » — one clicked it expecting the order to change (Fabrice's
/// remark, 25/07/2026). Drawn rather than written: a glyph would be a colour
/// emoji on macOS and a hollow box elsewhere, and this one takes the colour
/// of the header it sits in.
function magnifier(): SVGSVGElement {
  const namespace = "http://www.w3.org/2000/svg";
  const svg = document.createElementNS(namespace, "svg");
  svg.setAttribute("viewBox", "0 0 16 16");
  svg.setAttribute("width", "13");
  svg.setAttribute("height", "13");
  svg.setAttribute("aria-hidden", "true");
  svg.classList.add("list__magnifier");

  const lens = document.createElementNS(namespace, "circle");
  lens.setAttribute("cx", "7");
  lens.setAttribute("cy", "7");
  lens.setAttribute("r", "4.5");
  lens.setAttribute("fill", "none");
  lens.setAttribute("stroke", "currentColor");
  lens.setAttribute("stroke-width", "1.6");

  const handle = document.createElementNS(namespace, "line");
  handle.setAttribute("x1", "10.6");
  handle.setAttribute("y1", "10.6");
  handle.setAttribute("x2", "14.5");
  handle.setAttribute("y2", "14.5");
  handle.setAttribute("stroke", "currentColor");
  handle.setAttribute("stroke-width", "1.8");
  handle.setAttribute("stroke-linecap", "round");

  svg.append(lens, handle);
  return svg;
}

export class Table<Row> {
  private rows: Row[] = [];
  private selection: number[] = [];
  private anchor: number | null = null;
  private sortColumn = 0;
  private ascending = true;
  private filters: string[] = [];
  // Ces quatre listes sont rangées **par le rang de la colonne dans
  // `options.columns`**, celui de sa naissance, et non par sa place à l'écran :
  // une colonne déplacée garde son filtre, son tri et sa largeur. Une colonne
  // masquée n'y a pas d'entrée.
  private headerCells: HTMLElement[] = [];
  private markers: HTMLElement[] = [];
  private filterInputs: HTMLInputElement[] = [];
  private funnels: HTMLElement[] = [];
  /// **Toutes les colonnes, dans l'ordre où on les lit**, masquées comprises —
  /// par leur rang de naissance. Les fixes d'abord.
  private order: number[] = [];
  /// Celles qu'on ne montre pas.
  private hidden = new Set<number>();
  /// La couleur dont chaque colonne est teintée, par son rang de naissance ;
  /// chaîne vide pour « aucune ».
  private colours: string[] = [];
  /// Vient-on de lâcher une colonne ? Le clic que le navigateur envoie après
  /// le relâchement ne doit pas trier.
  private justMoved = false;
  /// Les enregistrements partis d'ici et dont l'écho n'est pas encore revenu :
  /// la fenêtre n'a pas à relire ce qu'elle vient elle-même d'écrire.
  private ownEchoes = 0;
  /// Les en-têtes déjà branchés sur le menu des colonnes.
  private menuArmed = new WeakSet<HTMLElement>();
  private columnsMenu: HTMLElement | null = null;
  /// The width of each column, as a CSS grid track. It starts at what the
  /// column asked for and follows the handle the user drags.
  private widths: string[] = [];
  private header: HTMLElement | null = null;
  private filterRow: HTMLElement | null = null;
  /// Le clic droit est-il déjà branché ? Voir [`exportOnRightClick`].
  private rightClickArmed = false;
  /// Où dire qu'une copie a échoué. La fenêtre le donne en branchant son clic
  /// droit ; avant cela, un échec ne se dit nulle part.
  private said: ((message: string, alert?: boolean) => void) | null = null;
  /// The slice drawn last time. Scrolling within the same slice redraws
  /// nothing: rebuilding the identical rows under a moving finger is what
  /// made the list wobble, and it also killed the drop-down the user had just
  /// opened.
  private drawnSlice: string | null = null;

  constructor(private readonly options: TableOptions<Row>) {
    this.filters = options.columns.map(() => "");
    this.widths = options.columns.map((column) => column.width ?? "1fr");
    this.order = this.bornOrder();
    this.colours = options.columns.map(() => "");
    // **⌘C sur macOS, Ctrl+C ailleurs : copier les lignes choisies** (Fabrice,
    // 07/10/2026). Sur la touche elle-même, et non sur l'événement « copier »
    // du navigateur : Radinus n'a pas de menu Édition, et sans lui WebKit
    // n'envoie pas cet événement-là.
    document.addEventListener("keydown", (event) => this.copyOnTheKey(event));
    if (options.layoutName !== undefined) {
      const name = options.layoutName;
      void this.recallLayout();
      // Une autre fenêtre a changé les colonnes de ce tableau — une autre
      // liste d'opérations, ou les préférences qui réinitialisent.
      void listen<string>(LAYOUT_CHANGED, (event) => {
        if (event.payload !== name) {
          return;
        }
        if (this.ownEchoes > 0) {
          this.ownEchoes -= 1;
          return;
        }
        void this.recallLayout();
      });
      document.addEventListener("keydown", (event) => {
        if (event.key === "Escape") {
          this.closeColumnsMenu();
        }
      });
    }
    if (options.virtualized) {
      // Scrolling redraws the slice that is now in view, and nothing else.
      options.container.addEventListener("scroll", () => this.render());
      options.container.style.setProperty(
        "--radinus-row-height",
        `${options.rowHeight ?? 26}px`,
      );
    }
    if (options.horizontalScroll) {
      // Le cadre du tableau rogne ce qui dépasse, et les lignes deviennent le
      // seul endroit qui défile — dans les deux sens.
      options.container.parentElement?.classList.add("list--scrollable");
      options.container.classList.add("list__rows--scrollable");
      // **L'en-tête et les filtres ne défilent pas d'eux-mêmes** : ils sont
      // hors du conteneur qui porte l'ascenseur. On les décale de ce que les
      // lignes ont défilé, ce qui les fait suivre au pixel près.
      options.container.addEventListener("scroll", () => this.followSideways());
    }
  }

  // --- La disposition : ordre, présence, largeurs ---------------------------

  /// Une colonne que l'utilisateur peut déplacer et masquer.
  private movable(index: number): boolean {
    const column = this.options.columns[index];
    return (
      this.options.layoutName !== undefined && column.id !== undefined && column.fixed !== true
    );
  }

  /// L'ordre de naissance : les fixes d'abord, puis les autres, chacune dans
  /// l'ordre où la fenêtre les a déclarées. Sans `layoutName` rien n'est
  /// mobile, donc c'est l'ordre déclaré tel quel.
  private bornOrder(): number[] {
    const all = this.options.columns.map((_, index) => index);
    if (this.options.layoutName === undefined) {
      return all;
    }
    return [
      ...all.filter((index) => !this.movable(index)),
      ...all.filter((index) => this.movable(index)),
    ];
  }

  /// Les colonnes qu'on voit, dans l'ordre où on les voit.
  private shown(): number[] {
    return this.order.filter((index) => !this.hidden.has(index));
  }

  private bornWidth(index: number): string {
    return this.options.columns[index].width ?? "1fr";
  }

  /// **La disposition en cours**, telle qu'elle s'enregistre.
  layout(): TableLayout {
    const columns = this.options.columns;
    const name = (index: number): string => columns[index].id as string;
    const widths: Record<string, number> = {};
    for (const index of this.order) {
      const width = this.widths[index];
      if (this.movable(index) && width !== this.bornWidth(index) && width.endsWith("px")) {
        widths[name(index)] = Math.round(parseFloat(width));
      }
    }
    const colors: Record<string, string> = {};
    for (const index of this.order) {
      if (this.movable(index) && this.colours[index] !== "") {
        colors[name(index)] = this.colours[index];
      }
    }
    return {
      order: this.order.filter((index) => this.movable(index)).map(name),
      hidden: this.order.filter((index) => this.hidden.has(index)).map(name),
      widths,
      colors,
    };
  }

  /// **Pose une disposition**, ou celle de naissance pour `null`.
  ///
  /// Rend `false` quand ce qu'on lui tend ne se tient pas pour ce tableau —
  /// une colonne qu'il ne connaît pas, tout masqué, une largeur qui n'en est
  /// pas une. Il se met alors dans sa disposition de naissance (Fabrice,
  /// 04/10/2026 : « en cas de problème il doit y avoir une réinitialisation
  /// de la préférence au niveau du tableau »).
  ///
  /// **Une colonne que la disposition ne cite pas n'est pas une faute** :
  /// c'est une colonne née après l'enregistrement, dans une version plus
  /// récente. Elle prend la place qu'elle a de naissance — juste après sa
  /// voisine de gauche — et le reste du réglage est gardé. Réinitialiser à
  /// chaque mise à jour ferait perdre son réglage à l'utilisateur pour une
  /// colonne qu'il n'a pas demandée.
  applyLayout(layout: TableLayout | null): boolean {
    const born = this.bornOrder();
    let order = born;
    let hidden = new Set<number>();
    let widths = this.options.columns.map((_, index) => this.bornWidth(index));
    let colours = this.options.columns.map(() => "");
    let sound = true;

    if (layout !== null) {
      const read = this.readLayout(layout, born);
      if (read === null) {
        sound = false;
      } else {
        ({ order, hidden, widths, colours } = read);
      }
    }

    const same =
      order.join() === this.order.join() &&
      widths.join() === this.widths.join() &&
      colours.join() === this.colours.join() &&
      hidden.size === this.hidden.size &&
      [...hidden].every((index) => this.hidden.has(index));
    if (!same) {
      this.order = order;
      this.hidden = hidden;
      this.widths = widths;
      this.colours = colours;
      this.forgetWhatIsHidden();
      this.redress();
    }
    return sound;
  }

  /// Lit une disposition contre les colonnes de ce tableau. `null` si elle ne
  /// se tient pas.
  private readLayout(
    layout: TableLayout,
    born: number[],
  ): { order: number[]; hidden: Set<number>; widths: string[]; colours: string[] } | null {
    const columns = this.options.columns;
    const byName = new Map<string, number>();
    born.forEach((index) => {
      if (this.movable(index)) {
        byName.set(columns[index].id as string, index);
      }
    });
    if (
      !Array.isArray(layout.order) ||
      !Array.isArray(layout.hidden) ||
      typeof layout.widths !== "object" ||
      layout.widths === null
    ) {
      return null;
    }

    const order = born.filter((index) => !this.movable(index));
    const placed = new Set<number>();
    for (const name of layout.order) {
      const index = byName.get(name);
      if (index === undefined || placed.has(index)) {
        return null;
      }
      placed.add(index);
      order.push(index);
    }
    // Les colonnes nées depuis : chacune après sa voisine de gauche.
    born.forEach((index, rank) => {
      if (!this.movable(index) || placed.has(index)) {
        return;
      }
      const neighbour = rank === 0 ? -1 : order.indexOf(born[rank - 1]);
      order.splice(neighbour + 1, 0, index);
      placed.add(index);
    });

    const hidden = new Set<number>();
    for (const name of layout.hidden) {
      const index = byName.get(name);
      if (index === undefined || hidden.has(index)) {
        return null;
      }
      hidden.add(index);
    }
    // Il reste toujours une colonne mobile à l'écran : tant qu'il y en a une,
    // il y a un en-tête où cliquer pour réafficher les autres.
    if (hidden.size >= byName.size) {
      return null;
    }

    const widths = columns.map((_, index) => this.bornWidth(index));
    for (const [name, width] of Object.entries(layout.widths)) {
      const index = byName.get(name);
      if (index === undefined || typeof width !== "number" || !(width >= 20 && width <= 4000)) {
        return null;
      }
      widths[index] = `${Math.round(width)}px`;
    }

    // Les couleurs. Leur absence n'est pas une faute — une disposition d'avant
    // elles n'en porte pas ; une couleur que ce tableau ne connaît pas en est
    // une.
    const colours = columns.map(() => "");
    const stated = layout.colors ?? {};
    if (typeof stated !== "object" || stated === null) {
      return null;
    }
    for (const [name, colour] of Object.entries(stated)) {
      const index = byName.get(name);
      if (index === undefined || !(COLUMN_COLOURS as readonly string[]).includes(colour)) {
        return null;
      }
      colours[index] = colour;
    }
    return { order, hidden, widths, colours };
  }

  /// Relit la disposition enregistrée et la pose. Une disposition que ce
  /// tableau refuse est ôtée de la base : elle serait relue, et refusée, à
  /// chaque ouverture.
  private async recallLayout(): Promise<void> {
    const name = this.options.layoutName;
    if (name === undefined) {
      return;
    }
    try {
      const stored = await invoke<TableLayout | null>("table_layout", { table: name });
      if (!this.applyLayout(stored ?? null)) {
        this.ownEchoes += 1;
        await invoke("reset_table_layout", { table: name }).catch(() => {
          this.ownEchoes -= 1;
        });
      }
    } catch {
      // Sans réponse, le tableau garde la disposition qu'il a : un réglage de
      // confort qui ne se lit pas ne doit pas empêcher de lire ses opérations.
    }
  }

  /// **Retient la disposition**, à la fin d'un geste — une colonne lâchée, une
  /// coche, une poignée relâchée. Jamais pendant : tirer une poignée écrirait
  /// cent fois dans la base.
  private remember(): void {
    const name = this.options.layoutName;
    if (name === undefined) {
      return;
    }
    this.ownEchoes += 1;
    invoke<boolean>("save_table_layout", { table: name, layout: this.layout() })
      .then((written) => {
        // Rien d'écrit, donc aucun écho à attendre.
        if (!written) {
          this.ownEchoes -= 1;
        }
      })
      .catch(() => {
        this.ownEchoes -= 1;
      });
  }

  /// « Rétablir les colonnes par défaut » : l'ordre, la présence et les
  /// largeurs de naissance, ici et dans la base.
  private restoreBornLayout(): void {
    const name = this.options.layoutName;
    if (name === undefined) {
      return;
    }
    this.applyLayout(null);
    this.ownEchoes += 1;
    invoke("reset_table_layout", { table: name }).catch(() => {
      this.ownEchoes -= 1;
    });
  }

  /// **Une colonne masquée ne filtre ni ne trie plus.** Un filtre qui
  /// continuerait d'agir sans que rien à l'écran ne dise lequel cacherait des
  /// lignes sans raison visible — ce qu'une fenêtre qui compte de l'argent ne
  /// peut pas se permettre.
  private forgetWhatIsHidden(): void {
    for (const index of this.hidden) {
      this.filters[index] = "";
      if (this.sortColumn === index) {
        this.sortColumn = 0;
        this.ascending = true;
      }
    }
  }

  /// Rebâtit l'en-tête et les lignes sur la disposition en cours, **en gardant
  /// les filtres ouverts** : déplacer une colonne ne doit pas effacer ce qu'on
  /// cherchait. Avant que la fenêtre n'ait bâti son en-tête, il n'y a rien à
  /// rebâtir — elle le fera sur la disposition déjà posée.
  private redress(): void {
    this.drawnSlice = null;
    if (this.header === null || this.filterRow === null) {
      return;
    }
    const sought = [...this.filters];
    const open = new Set<number>();
    this.filterInputs.forEach((input, index) => {
      if (!input.hidden) {
        open.add(index);
      }
    });
    this.buildHeader(this.header, this.filterRow);
    for (const index of this.shown()) {
      if (!open.has(index)) {
        continue;
      }
      const input = this.filterInputs[index];
      input.hidden = false;
      input.value = sought[index];
      this.filters[index] = sought[index];
      this.funnels[index].ariaPressed = "true";
    }
    this.filterRow.classList.toggle("list__filter--open", open.size > 0);
    this.render();
  }

  /// Déplace une colonne devant une autre — ou en dernier pour `null`.
  private moveColumn(index: number, before: number | null): void {
    const order = this.order.filter((other) => other !== index);
    const at = before === null ? order.length : order.indexOf(before);
    order.splice(at < 0 ? order.length : at, 0, index);
    if (order.join() === this.order.join()) {
      return;
    }
    this.order = order;
    this.redress();
    this.remember();
  }

  /// Montre ou masque une colonne. La dernière colonne mobile visible ne se
  /// masque pas.
  private toggleColumn(index: number): void {
    if (this.hidden.has(index)) {
      this.hidden.delete(index);
    } else {
      if (this.lastOneShown(index)) {
        return;
      }
      this.hidden.add(index);
      this.forgetWhatIsHidden();
    }
    this.redress();
    this.remember();
  }

  /// Cette colonne est-elle la seule mobile encore visible ?
  private lastOneShown(index: number): boolean {
    const left = this.shown().filter((other) => this.movable(other));
    return left.length === 1 && left[0] === index;
  }

  /// **Glisser un en-tête déplace sa colonne.** Le geste ne commence qu'après
  /// quelques pixels : en deçà, c'est un clic, et un clic trie.
  ///
  /// Écrit avec les événements du pointeur, comme la poignée de largeur, et
  /// non avec le glisser-déposer du navigateur : celui-ci ne se comporte pas
  /// pareil dans les trois moteurs que Radinus habite — WebKit sur macOS,
  /// WebView2 sous Windows, WebKitGTK sous Linux — et Tauri en intercepte une
  /// partie sous Windows (Fabrice, 04/10/2026 : « il faut que ce système soit
  /// compatible macOS, Windows et Linux »).
  private startMoving(index: number, cell: HTMLElement, event: PointerEvent): void {
    const startX = event.clientX;
    const container = this.options.container;
    let mark: HTMLElement | null = null;
    let before: number | null = index;

    const move = (moved: PointerEvent): void => {
      if (mark === null) {
        if (Math.abs(moved.clientX - startX) < MOVE_THRESHOLD) {
          return;
        }
        mark = document.createElement("div");
        mark.className = "list__drop-mark";
        document.body.append(mark);
        document.body.classList.add("moving-column");
        cell.classList.add("list__title--moving");
      }
      // Au bord du tableau, il défile : une colonne doit pouvoir aller plus
      // loin que ce qu'on voit.
      const frame = container.getBoundingClientRect();
      if (moved.clientX > frame.right - 24) {
        container.scrollLeft += 18;
      } else if (moved.clientX < frame.left + 24) {
        container.scrollLeft -= 18;
      }
      // Le trait se pose sur la frontière la plus proche du pointeur.
      const candidates = this.shown().filter((other) => this.movable(other));
      let x = 0;
      before = null;
      for (const other of candidates) {
        const box = this.headerCells[other].getBoundingClientRect();
        if (moved.clientX < box.left + box.width / 2) {
          before = other;
          x = box.left;
          break;
        }
        x = box.right;
      }
      const top = (this.header as HTMLElement).getBoundingClientRect().top;
      mark.style.left = `${Math.round(x) - 1}px`;
      mark.style.top = `${top}px`;
      mark.style.height = `${frame.bottom - top}px`;
    };
    const stop = (): void => {
      window.removeEventListener("pointermove", move);
      window.removeEventListener("pointerup", stop);
      window.removeEventListener("pointercancel", stop);
      if (mark === null) {
        return;
      }
      mark.remove();
      document.body.classList.remove("moving-column");
      cell.classList.remove("list__title--moving");
      // Le navigateur envoie un clic après le relâchement : ce n'est pas une
      // demande de tri.
      this.justMoved = true;
      window.setTimeout(() => {
        this.justMoved = false;
      }, 0);
      this.moveColumn(index, before);
    };
    window.addEventListener("pointermove", move);
    window.addEventListener("pointerup", stop);
    window.addEventListener("pointercancel", stop);
  }

  private closeColumnsMenu(): void {
    this.columnsMenu?.remove();
    this.columnsMenu = null;
  }

  /// Teinte une colonne — ou lui ôte sa teinte, pour la chaîne vide.
  private colourColumn(index: number, colour: string): void {
    if (this.colours[index] === colour) {
      return;
    }
    this.colours[index] = colour;
    this.drawnSlice = null;
    this.render();
    this.remember();
  }

  /// **Le menu des colonnes**, au clic droit sur la ligne d'en-têtes.
  ///
  /// ```text
  /// Afficher/Masquer         ▸  une coche par colonne
  /// Colorer la colonne : X   ▸  Aucune couleur ─ les neuf couleurs
  /// ─────────────────────────
  /// Rétablir les colonnes par défaut
  /// ```
  ///
  /// D'abord un seul niveau — les coches, puis « Rétablir ». Fabrice,
  /// 05/10/2026 : « il y aurait un menu Afficher/Masquer qui contiendrait un
  /// sous-menu avec le menu actuel. Et en dessous il y aurait une option
  /// Colorer. »
  ///
  /// **« Colorer » teinte la colonne dont on a cliqué l'en-tête**, et la
  /// nomme : un menu qui colorerait « une colonne » sans dire laquelle se
  /// tromperait de cible une fois sur deux. Sur une colonne fixe — le « + » —
  /// ou à côté de tout en-tête, l'entrée est grisée.
  ///
  /// Dessiné par Radinus, comme le menu des lignes : le même sur les trois
  /// systèmes. **Les coches laissent le menu ouvert** — masquer cinq colonnes
  /// ne doit pas demander cinq clics droits ; choisir une couleur le ferme,
  /// puisqu'on n'en choisit qu'une.
  private openColumnsMenu(x: number, y: number, clicked: number | null): void {
    this.closeColumnsMenu();
    const menu = document.createElement("div");
    menu.className = "context-menu context-menu--columns";
    menu.role = "menu";
    this.columnsMenu = menu;

    /// Une entrée qui ouvre un sous-menu, au survol ou au clic.
    const nest = (label: string, name: string, enabled: boolean): HTMLElement => {
      const box = document.createElement("div");
      box.className = "context-menu__nest";
      box.dataset.menu = name;
      const opener = document.createElement("button");
      opener.type = "button";
      opener.className = "context-menu__entry context-menu__entry--opener";
      opener.textContent = label;
      opener.disabled = !enabled;
      box.append(opener);
      if (enabled) {
        const nested = document.createElement("div");
        nested.className = "context-menu__submenu";
        box.append(nested);
        opener.addEventListener("click", () => {
          box.classList.toggle("context-menu__nest--open");
        });
      }
      return box;
    };

    // --- Afficher/Masquer.
    const shown = nest(t("columns-show-hide"), "show-hide", true);
    const checks = shown.querySelector(".context-menu__submenu") as HTMLElement;
    const fill = (): void => {
      checks.replaceChildren();
      for (const index of this.order) {
        if (!this.movable(index)) {
          continue;
        }
        const column = this.options.columns[index];
        const entry = document.createElement("button");
        entry.type = "button";
        entry.className = "context-menu__entry context-menu__entry--check";
        entry.role = "menuitemcheckbox";
        entry.dataset.column = column.id;
        entry.ariaChecked = String(!this.hidden.has(index));
        entry.textContent = column.title() || (column.id as string);
        // La dernière colonne visible : elle dit qu'elle existe, et qu'on ne
        // peut pas la retirer tant qu'elle est seule.
        entry.disabled = this.lastOneShown(index);
        entry.addEventListener("click", () => {
          this.toggleColumn(index);
          fill();
        });
        checks.append(entry);
      }
    };
    fill();

    // --- Colorer la colonne cliquée.
    const subject = clicked !== null && this.movable(clicked) ? clicked : null;
    const title = subject === null ? "" : this.options.columns[subject].title();
    // « Colorer la colonne : Solde » — le libellé vient entier de Fluent, deux
    // points compris ; le nom de la colonne le suit, comme le message d'une
    // erreur suit sa phrase. Une substitution, pas une composition.
    const colour = nest(
      subject === null ? t("columns-colour") : `${t("columns-colour")} ${title}`,
      "colour",
      subject !== null,
    );
    if (subject !== null) {
      const tints = colour.querySelector(".context-menu__submenu") as HTMLElement;
      const choice = (name: string, label: string): HTMLButtonElement => {
        const entry = document.createElement("button");
        entry.type = "button";
        entry.className = "context-menu__entry context-menu__entry--check";
        entry.role = "menuitemradio";
        entry.dataset.colour = name;
        entry.ariaChecked = String(this.colours[subject] === name);
        if (name !== "") {
          // La pastille : la teinte, telle qu'elle se posera sur la colonne.
          const swatch = document.createElement("span");
          swatch.className = "context-menu__swatch";
          swatch.dataset.tint = name;
          entry.append(swatch);
        }
        entry.append(label);
        entry.addEventListener("click", () => {
          this.closeColumnsMenu();
          this.colourColumn(subject, name);
        });
        return entry;
      };
      const rule = document.createElement("hr");
      rule.className = "context-menu__rule";
      tints.append(
        choice("", t("columns-colour-none")),
        rule,
        ...COLUMN_COLOURS.map((name) => choice(name, t(`columns-colour-${name}`))),
      );
    }

    // --- Rétablir.
    const rule = document.createElement("hr");
    rule.className = "context-menu__rule";
    const reset = document.createElement("button");
    reset.type = "button";
    reset.className = "context-menu__entry";
    reset.dataset.column = "";
    reset.textContent = t("columns-reset");
    reset.addEventListener("click", () => {
      this.closeColumnsMenu();
      this.restoreBornLayout();
    });
    menu.append(shown, colour, rule, reset);

    document.body.append(menu);
    // Le menu tient dans la fenêtre, où qu'on ait cliqué, et ses sous-menus
    // aussi : à gauche près du bord droit, vers le haut près du bas — le
    // détail d'une statistique a ses en-têtes à mi-hauteur de la fenêtre. Et
    // un sous-menu plus haut que la place qui reste défile au lieu de sortir.
    const box = menu.getBoundingClientRect();
    menu.style.left = `${Math.max(0, Math.min(x, window.innerWidth - box.width - 4))}px`;
    menu.style.top = `${Math.max(0, Math.min(y, window.innerHeight - box.height - 4))}px`;
    const placed = menu.getBoundingClientRect();
    if (placed.right + 230 > window.innerWidth) {
      menu.classList.add("context-menu--near-the-edge");
    }
    const tallest = Math.max(checks.childElementCount, COLUMN_COLOURS.length + 2) * 28 + 12;
    const upwards = placed.top + tallest > window.innerHeight && placed.bottom > window.innerHeight / 2;
    if (upwards) {
      menu.classList.add("context-menu--near-the-bottom");
    }
    const room = upwards ? placed.bottom - 4 : window.innerHeight - placed.top - 4;
    for (const nested of menu.querySelectorAll<HTMLElement>(".context-menu__submenu")) {
      nested.style.maxHeight = `${Math.max(120, room)}px`;
      nested.style.overflowY = "auto";
    }

    const closeIfOutside = (event: MouseEvent): void => {
      if (this.columnsMenu !== menu) {
        document.removeEventListener("mousedown", closeIfOutside);
        return;
      }
      if (!menu.contains(event.target as Node)) {
        this.closeColumnsMenu();
        document.removeEventListener("mousedown", closeIfOutside);
      }
    };
    document.addEventListener("mousedown", closeIfOutside);
  }

  /// Aligne l'en-tête et la ligne des filtres sur le défilement horizontal des
  /// lignes. Un titre décalé d'une colonne serait pire qu'un tableau tronqué.
  private followSideways(): void {
    const shift = `translateX(${-this.options.container.scrollLeft}px)`;
    if (this.header) {
      this.header.style.transform = shift;
    }
    if (this.filterRow) {
      this.filterRow.style.transform = shift;
    }
  }

  /// La largeur en dessous de laquelle le tableau déborde plutôt que de se
  /// serrer : la somme des minimums de ses colonnes. Zéro quand la fenêtre
  /// n'a pas demandé d'ascenseur — le tableau se partage alors la place comme
  /// il l'a toujours fait.
  ///
  /// **C'est une largeur plancher, et non un minimum par piste.** Une piste
  /// `minmax(150px, 1fr)` a été essayée d'abord : elle ne fait rien de ce
  /// qu'on croit. Quand la place manque, une grille ne dépasse pas — elle
  /// ramène chaque piste à son minimum et s'arrête là, si bien que tirer une
  /// poignée ne pouvait plus élargir quoi que ce soit (attrapé par la
  /// vérification « tirer la poignée élargit la colonne »). Le plancher, lui,
  /// donne au tableau une largeur qu'il garde quoi qu'il arrive : les
  /// proportions restent celles d'une fenêtre de cette largeur-là, et ce qui
  /// dépasse se rattrape à l'ascenseur.
  private smallestWidth(): number {
    if (!this.options.horizontalScroll) {
      return 0;
    }
    return this.shown().reduce(
      (total, index) => total + (this.options.columns[index].minWidth ?? 0),
      0,
    );
  }

  /// Pose cette largeur minimale sur une bande du tableau — en-tête, filtres
  /// ou ligne. Les trois portent la même, sans quoi elles ne défileraient pas
  /// du même pas.
  private holdTheWidth(band: HTMLElement): void {
    const smallest = this.smallestWidth();
    // Posée même à zéro : une colonne masquée abaisse le plancher, et une
    // bande rebâtie ne doit pas garder l'ancien.
    band.style.minWidth = smallest > 0 ? `${smallest}px` : "";
  }

  /// Builds the header — one cell, one sort marker and one funnel per column.
  /// Called after the window has its words, et **une fois par langue** : la
  /// fenêtre se rhabille sans être détruite, donc l'en-tête se rebâtit.
  buildHeader(header: HTMLElement, filterRow: HTMLElement): void {
    this.header = header;
    this.filterRow = filterRow;
    header.replaceChildren();
    filterRow.replaceChildren();
    // Les cellules qui viennent d'être ôtées du document ne sont plus les
    // siennes : les garder ferait chercher l'entonnoir de la colonne 3 dans un
    // en-tête que plus personne ne voit — le tri et le filtre agiraient sur du
    // vide après un changement de langue.
    this.headerCells = [];
    this.markers = [];
    this.filterInputs = [];
    this.funnels = [];
    if (this.options.layoutName !== undefined && !this.menuArmed.has(header)) {
      this.menuArmed.add(header);
      header.addEventListener("contextmenu", (event) => {
        event.preventDefault();
        // L'en-tête sous le pointeur : c'est sa colonne que « Colorer » teinte.
        const cell = (event.target as Element).closest<HTMLElement>(".list__title");
        const clicked = cell === null ? -1 : this.headerCells.indexOf(cell);
        this.openColumnsMenu(event.clientX, event.clientY, clicked < 0 ? null : clicked);
      });
    }
    // Les entonnoirs repartent fermés et vides : leurs champs viennent d'être
    // remplacés par des neufs. Garder les mots cherchés laisserait un filtre
    // agir sans que rien à l'écran ne dise plus lequel — des lignes cachées
    // sans raison visible, ce qu'une fenêtre qui compte de l'argent ne peut pas
    // se permettre.
    this.filters = this.options.columns.map(() => "");
    filterRow.classList.remove("list__filter--open");
    header.style.gridTemplateColumns = this.trackList();
    filterRow.style.gridTemplateColumns = this.trackList();
    this.holdTheWidth(header);
    this.holdTheWidth(filterRow);
    // L'en-tête vient d'être rebâti : il est revenu à sa position de départ
    // alors que les lignes, elles, n'ont pas bougé.
    this.followSideways();

    this.shown().forEach((index, place) => {
      const column = this.options.columns[index];
      const cell = document.createElement("span");
      cell.className = "list__title";
      if (column.id !== undefined) {
        cell.dataset.column = column.id;
      }
      cell.role = "button";
      cell.tabIndex = 0;
      if (column.numeric) {
        cell.classList.add("list__title--numeric");
      }

      const title = document.createElement("span");
      title.className = "list__title-text";
      title.textContent = column.title();
      const marker = document.createElement("span");
      marker.className = "list__sort-marker";
      cell.append(title, marker);
      cell.addEventListener("click", () => {
        if (!this.justMoved) {
          this.sortBy(index);
        }
      });
      if (this.movable(index)) {
        cell.addEventListener("pointerdown", (event) => {
          // Le bouton principal seulement. La poignée de largeur, elle,
          // arrête déjà l'événement avant qu'il n'arrive ici.
          if (event.button !== 0) {
            return;
          }
          this.startMoving(index, cell, event);
        });
      }

      const funnel = document.createElement("button");
      funnel.type = "button";
      funnel.className = "list__filter-toggle";
      funnel.append(magnifier());
      funnel.ariaPressed = "false";
      funnel.addEventListener("click", (event) => {
        event.stopPropagation();
        // Une colonne étroite est à moitié faite de sa loupe : on doit pouvoir
        // l'attraper par là aussi, et la lâcher n'ouvre pas la recherche.
        if (this.justMoved) {
          return;
        }
        this.toggleFilter(index, funnel);
      });
      cell.append(funnel);

      // The handle that widens the column. Dragged, it sets this column to a
      // width in pixels; double-clicked, it puts back the width the column
      // was born with (author's request, 25/07/2026).
      const handle = document.createElement("span");
      handle.className = "list__resizer";
      handle.addEventListener("click", (event) => event.stopPropagation());
      handle.addEventListener("pointerdown", (event) => {
        event.preventDefault();
        event.stopPropagation();
        this.startResizing(index, cell, event);
      });
      handle.addEventListener("dblclick", (event) => {
        event.stopPropagation();
        this.widths[index] = this.bornWidth(index);
        this.applyTracks();
        this.remember();
      });
      cell.append(handle);

      const input = document.createElement("input");
      input.type = "search";
      input.className = "list__filter-input";
      input.hidden = true;
      // **Nailed to its own column.** A hidden cell leaves the grid, so the
      // one search field on screen slid back into the first column whatever
      // funnel had been opened — one searched the labels and it looked like
      // one was searching the dates (reported by Fabrice, 25/07/2026).
      input.style.gridColumn = String(place + 1);
      input.addEventListener("input", () => {
        this.filters[index] = input.value;
        this.drawnSlice = null;
        this.render();
      });

      header.append(cell);
      filterRow.append(input);
      this.headerCells[index] = cell;
      this.markers[index] = marker;
      this.filterInputs[index] = input;
      this.funnels[index] = funnel;
    });

    this.showSortMarkers();
  }

  private trackList(): string {
    const shown = this.shown();
    // **Dès qu'une largeur a été tirée à la main, une colonne restée en `fr`
    // reçoit un plancher.** Tirer une poignée fige en pixels toutes les
    // colonnes visibles ; une colonne qui revient ensuite avec sa part `1fr` —
    // réaffichée, ou rendue à sa largeur de naissance par un double-clic —
    // reçoit ce qui reste, c'est-à-dire rien dès que le tableau déborde : elle
    // serait là sans qu'on la voie. Et depuis que la disposition est retenue,
    // elle le resterait d'une ouverture à l'autre.
    //
    // Le plancher n'est posé que dans ce cas. Un tableau où rien n'a été tiré
    // garde ses pistes telles quelles : `minmax` partout l'empêcherait de se
    // partager la place comme il l'a toujours fait (voir `smallestWidth`).
    const pulled = shown.some((index) => this.widths[index] !== this.bornWidth(index));
    return shown
      .map((index) => {
        const width = this.widths[index];
        if (!pulled || !width.endsWith("fr")) {
          return width;
        }
        const least = this.options.columns[index].minWidth ?? LEAST_SHARE;
        return `minmax(${least}px, ${width})`;
      })
      .join(" ");
  }

  /// Lays the same track list on the header, the filters and every row on
  /// screen. Called while a handle is being dragged, so the whole table
  /// follows the hand rather than jumping when it is let go.
  private applyTracks(): void {
    const tracks = this.trackList();
    if (this.header) {
      this.header.style.gridTemplateColumns = tracks;
    }
    if (this.filterRow) {
      this.filterRow.style.gridTemplateColumns = tracks;
    }
    for (const row of this.options.container.querySelectorAll<HTMLElement>(".list__row")) {
      row.style.gridTemplateColumns = tracks;
    }
  }

  /// Follows the pointer until it is let go. Every column keeps the width it
  /// has at that moment, in pixels: leaving the untouched ones in `fr` would
  /// have them share out what the dragged one gives up, and the whole table
  /// would move when only one column was pulled.
  private startResizing(index: number, cell: HTMLElement, event: PointerEvent): void {
    const startX = event.clientX;
    // Par rang de naissance, comme `widths` : les colonnes masquées n'ont pas
    // d'en-tête à mesurer et gardent ce qu'elles avaient.
    const startWidths: number[] = [];
    for (const shown of this.shown()) {
      startWidths[shown] = this.headerCells[shown].offsetWidth;
    }
    const smallest = 34;
    // **Rien n'est figé tant que la poignée n'a pas bougé.** Un simple clic
    // dessus — ou les deux d'un double-clic — figeait toutes les colonnes en
    // pixels sans que l'utilisateur ait rien tiré ; cela ne se voyait pas,
    // mais depuis que la disposition est retenue, cela s'enregistrerait.
    let pulled = false;

    const move = (moved: PointerEvent): void => {
      if (!pulled) {
        pulled = true;
        for (const shown of this.shown()) {
          this.widths[shown] = `${startWidths[shown]}px`;
        }
      }
      const width = Math.max(smallest, startWidths[index] + (moved.clientX - startX));
      this.widths[index] = `${width}px`;
      this.applyTracks();
    };
    const stop = (): void => {
      window.removeEventListener("pointermove", move);
      window.removeEventListener("pointerup", stop);
      document.body.classList.remove("resizing-column");
      if (pulled) {
        this.remember();
      }
    };

    void cell;
    document.body.classList.add("resizing-column");
    window.addEventListener("pointermove", move);
    window.addEventListener("pointerup", stop);
  }

  private sortBy(index: number): void {
    this.drawnSlice = null;
    if (this.sortColumn === index) {
      this.ascending = !this.ascending;
    } else {
      this.sortColumn = index;
      this.ascending = true;
    }
    this.showSortMarkers();
    this.render();
  }

  private showSortMarkers(): void {
    this.markers.forEach((marker, index) => {
      marker.textContent = index === this.sortColumn ? (this.ascending ? "▲" : "▼") : "";
    });
  }

  private toggleFilter(index: number, funnel: HTMLElement): void {
    const input = this.filterInputs[index];
    const opening = input.hidden;
    input.hidden = !opening;
    funnel.ariaPressed = String(opening);
    if (opening) {
      input.focus();
    } else {
      input.value = "";
      this.filters[index] = "";
      this.drawnSlice = null;
      this.render();
    }
    // The row of search fields takes no room while none is open.
    this.filterRow?.classList.toggle(
      "list__filter--open",
      this.filterInputs.some((field) => !field.hidden),
    );
  }

  /// New data. The selection keeps whatever still exists.
  setRows(rows: Row[]): void {
    this.rows = rows;
    this.drawnSlice = null;
    const alive = new Set(rows.map((row) => this.options.identity(row)));
    this.selection = this.selection.filter((id) => alive.has(id));
    this.render();
  }

  selected(): number[] {
    return [...this.selection];
  }

  clearSelection(): void {
    this.selection = [];
    this.anchor = null;
    this.drawnSlice = null;
    this.render();
  }

  private sortKey(row: Row, index: number): string | number {
    const column = this.options.columns[index];
    return column.key ? column.key(row) : column.cell(row);
  }

  private visible(): Row[] {
    let kept = this.rows.filter((row) =>
      this.options.columns.every((column, index) => {
        const needle = this.filters[index].trim().toLocaleLowerCase("fr");
        if (!needle) {
          return true;
        }
        return column.cell(row).toLocaleLowerCase("fr").includes(needle);
      }),
    );

    // Column 0 keeps the order the core gave — that order *is* the French
    // collation, measured on the author's archive, and re-sorting here would
    // quietly replace it with the browser's own idea of alphabetical.
    if (this.sortColumn > 0) {
      kept = [...kept].sort((a, b) => {
        const left = this.sortKey(a, this.sortColumn);
        const right = this.sortKey(b, this.sortColumn);
        if (typeof left === "number" && typeof right === "number") {
          return left - right;
        }
        return String(left).localeCompare(String(right), "fr");
      });
    }
    return this.ascending ? kept : kept.reverse();
  }

  render(): void {
    const shown = this.visible();
    const container = this.options.container;

    // **Everything is built aside and swapped in one go.** Emptying the
    // container first would leave it, for an instant, with no content at all:
    // the browser then clamps the scrollbar back to the top, and what gets
    // drawn is the spacer standing in for the rows above — a large white
    // rectangle (reported by Fabrice, 25/07/2026). A single swap never lets
    // the height collapse, so the scroll position is kept.
    const built = document.createDocumentFragment();

    if (shown.length === 0) {
      const empty = document.createElement("div");
      empty.className = "list__empty";
      empty.textContent =
        this.rows.length === 0
          ? this.options.emptyText()
          : this.options.filteredOutText();
      built.append(empty);
      container.replaceChildren(built);
      return;
    }

    // Only what is on screen is built, with two spacers standing in for what
    // is above and below: forty thousand rows in the document would make
    // every scroll and every keystroke crawl.
    let slice = shown;
    let above = 0;
    let below = 0;
    if (this.options.virtualized) {
      const height = this.options.rowHeight ?? 26;
      const margin = 10;
      const first = Math.max(0, Math.floor(container.scrollTop / height) - margin);
      const count =
        Math.ceil((container.clientHeight || height * 20) / height) + margin * 2;
      const last = Math.min(shown.length, first + count);

      // Already on screen: nothing to rebuild. Replacing the very same rows
      // at every scroll event is what made the list fight the scrollbar.
      const drawn = `${first}-${last}-${shown.length}`;
      if (drawn === this.drawnSlice) {
        return;
      }
      this.drawnSlice = drawn;

      slice = shown.slice(first, last);
      above = first * height;
      below = (shown.length - last) * height;
    }

    if (above > 0) {
      const spacer = document.createElement("div");
      spacer.style.height = `${above}px`;
      built.append(spacer);
    }

    for (const row of slice) {
      const id = this.options.identity(row);
      const line = document.createElement("div");
      line.className = "list__row";
      line.style.gridTemplateColumns = this.trackList();
      this.holdTheWidth(line);
      line.role = "option";
      line.dataset.id = String(id);
      line.ariaSelected = String(this.selection.includes(id));

      // A window may mark a row with more than one class — a sub-operation is
      // both a child and, sometimes, a Complément.
      const extra = this.options.rowClass?.(row);
      if (extra) {
        line.classList.add(...extra.split(" ").filter(Boolean));
      }

      for (const index of this.shown()) {
        const column = this.options.columns[index];
        const cell = document.createElement("span");
        cell.className = column.numeric ? "list__cell list__cell--numeric" : "list__cell";
        // Le calque de couleur de la colonne, s'il y en a un.
        if (this.colours[index] !== "") {
          cell.dataset.tint = this.colours[index];
        }
        if (column.editor && this.selection.includes(id) && (column.editor.editable?.(row) ?? true)) {
          const combo = document.createElement("select");
          combo.className = "list__combo";
          for (const option of column.editor.options()) {
            const entry = document.createElement("option");
            entry.value = String(option.id);
            entry.textContent = option.label;
            combo.append(entry);
          }
          combo.value = String(column.editor.value(row));
          column.editor.decorate?.(row, combo);
          // The click that opens the list is not a click on the row: it must
          // not move the selection under the user's hand.
          combo.addEventListener("click", (event) => event.stopPropagation());
          combo.addEventListener("change", () =>
            column.editor?.change(row, Number(combo.value)),
          );
          cell.append(combo);
        } else if (column.render) {
          column.render(row, cell);
        } else {
          cell.textContent = column.cell(row);
        }
        line.append(cell);
      }

      line.addEventListener("click", (event) => this.onRowClick(event, id));
      line.addEventListener("dblclick", () => this.options.onActivate?.(row));
      built.append(line);
    }

    if (below > 0) {
      const spacer = document.createElement("div");
      spacer.style.height = `${below}px`;
      built.append(spacer);
    }

    container.replaceChildren(built);
  }

  /// How many rows the filters and the tree leave on screen.
  shownCount(): number {
    return this.visible().length;
  }

  /// **Les lignes que l'on voit**, dans l'ordre du tri en cours et amputées de
  /// ce que les entonnoirs cachent.
  ///
  /// Une fenêtre qui exporte autre chose qu'un tableau — l'OFX et le QIF de
  /// F02 partent des opérations, pas des colonnes — a besoin de savoir
  /// **lesquelles** sont à l'écran. Sans cela elle exporterait tout, et la
  /// période comme les filtres ne serviraient à rien.
  shownRows(): Row[] {
    return this.visible();
  }

  /// La feuille de ce tableau : **ce qu'il affiche**, exactement.
  ///
  /// Les lignes sont celles que l'on voit — donc dans l'ordre du tri en cours
  /// et amputées de ce que les entonnoirs cachent — et les colonnes sont les
  /// siennes, titres compris. Un tableau exporte ce qu'on lit, pas ce qu'il
  /// aurait pu montrer (règle donnée par Fabrice le 26/07/2026).
  ///
  /// Une colonne qui ne montre pas de texte — le « + » du dépliage, une case
  /// à cocher — sort telle qu'elle se lit à l'écran, c'est-à-dire vide : rien
  /// n'est inventé pour la remplir.
  async sheet(): Promise<Sheet> {
    // Les colonnes qu'on voit, dans l'ordre où on les voit : un tableau
    // exporte ce qu'on lit, et l'utilisateur vient de choisir ce qu'il lit.
    const columns = this.shown().map((index) => this.options.columns[index]);
    const heading = columns.map((column) => exportText(column.title(), true));
    const lines = this.visible().map((row) =>
      columns.map((column) => {
        // Une colonne d'argent sort en nombre, pour être sommable ; les
        // autres sortent le texte que l'on lit.
        const amount = column.money?.(row) ?? null;
        return amount === null ? exportText(column.cell(row)) : exportMoney(amount);
      }),
    );
    const where = this.options.exportAs?.() ?? { name: "Radinus", detail: "" };
    return {
      name: where.name,
      context: where.detail === "" ? "" : await contextLine(where.name, where.detail),
      header_rows: 1,
      rows: [heading, ...lines],
      widths: columns.map(() => 18),
    };
  }

  // --- Copier ---------------------------------------------------------------

  /// Ce qu'une cellule vaut dans le presse-papiers : le texte qu'on lit, et
  /// **un nombre pur pour un montant** — sans signe monétaire ni groupement,
  /// le séparateur décimal de la langue (Fabrice, 07/10/2026 : « en nombre
  /// pur »). Seules les colonnes de nombres y passent : un libellé reste ce
  /// qu'il est.
  private copied(row: Row, index: number): string {
    const column = this.options.columns[index];
    const text = oneCell(column.cell(row));
    return column.numeric || column.money !== undefined ? pureNumber(text) : text;
  }

  /// **Les lignes choisies, telles qu'on les voit** : dans l'ordre de l'écran,
  /// avec les colonnes affichées, dans leur ordre. Une tabulation entre deux
  /// cellules, un saut de ligne entre deux lignes — ce qu'un tableur colle une
  /// cellule par colonne. **Sans titres** (tranché par Fabrice).
  private selectedAsText(): string {
    const chosen = new Set(this.selection);
    const shown = this.shown();
    return this.visible()
      .filter((row) => chosen.has(this.options.identity(row)))
      .map((row) => shown.map((index) => this.copied(row, index)).join("\t"))
      .join("\n");
  }

  private async toTheClipboard(text: string): Promise<void> {
    if (!(await copyText(text))) {
      this.said?.(t("copy-failed"), true);
    }
  }

  /// La touche de copie. Elle n'agit que si ce tableau a des lignes choisies,
  /// qu'il est à l'écran, et que l'utilisateur n'est pas en train de copier
  /// autre chose : dans une loupe de recherche, une liste déroulante ou un
  /// champ, ⌘C reste ce qu'il a toujours été — comme partout où un texte est
  /// surligné.
  private copyOnTheKey(event: KeyboardEvent): void {
    if (!(event.metaKey || event.ctrlKey) || event.altKey || event.shiftKey) {
      return;
    }
    if (event.key.toLowerCase() !== "c" || this.selection.length === 0) {
      return;
    }
    const container = this.options.container;
    if (!container.isConnected || container.offsetParent === null) {
      return;
    }
    const focused = document.activeElement;
    if (
      focused instanceof HTMLInputElement ||
      focused instanceof HTMLTextAreaElement ||
      focused instanceof HTMLSelectElement ||
      (focused instanceof HTMLElement && focused.isContentEditable)
    ) {
      return;
    }
    if ((window.getSelection()?.toString() ?? "") !== "") {
      return;
    }
    event.preventDefault();
    void this.toTheClipboard(this.selectedAsText());
  }

  /// **Les deux entrées de copie du menu du clic droit** : la cellule sous le
  /// pointeur, et les lignes choisies. La première est grisée sur une cellule
  /// vide — une coche, le « + » — ou hors de toute ligne ; la seconde, sans
  /// sélection.
  private copyEntries(event: MouseEvent): MenuHeadEntry[] {
    let cell: string | null = null;
    const under = (event.target as Element).closest<HTMLElement>(".list__cell");
    const line = under?.parentElement ?? null;
    if (under !== null && line !== null && line.dataset.id !== undefined) {
      const id = Number(line.dataset.id);
      const row = this.rows.find((one) => this.options.identity(one) === id);
      const index = this.shown()[[...line.children].indexOf(under)];
      if (row !== undefined && index !== undefined) {
        const text = this.copied(row, index);
        cell = text === "" ? null : text;
      }
    }
    return [
      {
        name: "copy-cell",
        label: t("copy-cell"),
        enabled: cell !== null,
        run: () => void this.toTheClipboard(cell ?? ""),
      },
      {
        name: "copy-rows",
        label: t("copy-rows"),
        enabled: this.selection.length > 0,
        run: () => void this.toTheClipboard(this.selectedAsText()),
      },
    ];
  }

  /// Branche le clic droit du tableau sur l'export. Appelé par la fenêtre une
  /// fois qu'elle a ses mots.
  ///
  /// **Une seule fois, quoi qu'il arrive.** La fenêtre rappelle cette méthode
  /// chaque fois qu'elle se rhabille ; deux branchements ouvriraient deux
  /// menus l'un sur l'autre au premier clic droit. Le menu, lui, se construit
  /// au moment du clic : ses entrées suivent la langue sans rien rebrancher.
  exportOnRightClick(
    said: (message: string, alert?: boolean) => void,
    additions?: () => MenuAddition[],
    exportsUnder?: () => string,
  ): void {
    if (this.rightClickArmed) {
      return;
    }
    this.rightClickArmed = true;
    this.said = said;
    onRightClick(
      this.options.container,
      () => this.sheet(),
      said,
      additions,
      exportsUnder,
      (event) => this.copyEntries(event),
    );
  }

  private onRowClick(event: MouseEvent, id: number): void {
    // A list that answers a single question ignores the two keys that would
    // widen the answer: there is no half-way between one and several.
    const additive = !this.options.singleSelection && (event.metaKey || event.ctrlKey);
    const range = !this.options.singleSelection && event.shiftKey;

    if (range && this.anchor !== null) {
      const shown = this.visible().map((row) => this.options.identity(row));
      const from = shown.indexOf(this.anchor);
      const to = shown.indexOf(id);
      if (from !== -1 && to !== -1) {
        const [start, end] = from <= to ? [from, to] : [to, from];
        this.selection = shown.slice(start, end + 1);
      }
    } else if (additive) {
      this.selection = this.selection.includes(id)
        ? this.selection.filter((selected) => selected !== id)
        : [...this.selection, id];
      this.anchor = id;
    } else {
      this.selection = [id];
      this.anchor = id;
    }

    this.options.onSelectionChange?.(this.selected());
    // The selected row gains its combos and the previous one loses them, so
    // the slice on screen really has changed.
    this.drawnSlice = null;
    this.render();
  }
}
