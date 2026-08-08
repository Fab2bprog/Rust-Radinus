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

import {
  contextLine,
  money as exportMoney,
  onRightClick,
  text as exportText,
  type Sheet,
} from "./export";

export interface Column<Row> {
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
  };
  /// Width, as a CSS grid track. Defaults to an equal share.
  width?: string;
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
  private headerCells: HTMLElement[] = [];
  private markers: HTMLElement[] = [];
  private filterInputs: HTMLInputElement[] = [];
  /// The width of each column, as a CSS grid track. It starts at what the
  /// column asked for and follows the handle the user drags.
  private widths: string[] = [];
  private header: HTMLElement | null = null;
  private filterRow: HTMLElement | null = null;
  /// Le clic droit est-il déjà branché ? Voir [`exportOnRightClick`].
  private rightClickArmed = false;
  /// The slice drawn last time. Scrolling within the same slice redraws
  /// nothing: rebuilding the identical rows under a moving finger is what
  /// made the list wobble, and it also killed the drop-down the user had just
  /// opened.
  private drawnSlice: string | null = null;

  constructor(private readonly options: TableOptions<Row>) {
    this.filters = options.columns.map(() => "");
    this.widths = options.columns.map((column) => column.width ?? "1fr");
    if (options.virtualized) {
      // Scrolling redraws the slice that is now in view, and nothing else.
      options.container.addEventListener("scroll", () => this.render());
      options.container.style.setProperty(
        "--radinus-row-height",
        `${options.rowHeight ?? 26}px`,
      );
    }
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
    // Les entonnoirs repartent fermés et vides : leurs champs viennent d'être
    // remplacés par des neufs. Garder les mots cherchés laisserait un filtre
    // agir sans que rien à l'écran ne dise plus lequel — des lignes cachées
    // sans raison visible, ce qu'une fenêtre qui compte de l'argent ne peut pas
    // se permettre.
    this.filters = this.options.columns.map(() => "");
    filterRow.classList.remove("list__filter--open");
    header.style.gridTemplateColumns = this.trackList();
    filterRow.style.gridTemplateColumns = this.trackList();

    this.options.columns.forEach((column, index) => {
      const cell = document.createElement("span");
      cell.className = "list__title";
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
      cell.addEventListener("click", () => this.sortBy(index));

      const funnel = document.createElement("button");
      funnel.type = "button";
      funnel.className = "list__filter-toggle";
      funnel.append(magnifier());
      funnel.ariaPressed = "false";
      funnel.addEventListener("click", (event) => {
        event.stopPropagation();
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
        this.widths[index] = this.options.columns[index].width ?? "1fr";
        this.applyTracks();
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
      input.style.gridColumn = String(index + 1);
      input.addEventListener("input", () => {
        this.filters[index] = input.value;
        this.drawnSlice = null;
        this.render();
      });

      header.append(cell);
      filterRow.append(input);
      this.headerCells.push(cell);
      this.markers.push(marker);
      this.filterInputs.push(input);
    });

    this.showSortMarkers();
  }

  private trackList(): string {
    return this.widths.join(" ");
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
    const startWidths = this.headerCells.map((header) => header.offsetWidth);
    const smallest = 34;

    this.widths = startWidths.map((width) => `${width}px`);
    this.applyTracks();

    const move = (moved: PointerEvent): void => {
      const width = Math.max(smallest, startWidths[index] + (moved.clientX - startX));
      this.widths[index] = `${width}px`;
      this.applyTracks();
    };
    const stop = (): void => {
      window.removeEventListener("pointermove", move);
      window.removeEventListener("pointerup", stop);
      document.body.classList.remove("resizing-column");
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
      line.role = "option";
      line.dataset.id = String(id);
      line.ariaSelected = String(this.selection.includes(id));

      // A window may mark a row with more than one class — a sub-operation is
      // both a child and, sometimes, a Complément.
      const extra = this.options.rowClass?.(row);
      if (extra) {
        line.classList.add(...extra.split(" ").filter(Boolean));
      }

      for (const column of this.options.columns) {
        const cell = document.createElement("span");
        cell.className = column.numeric ? "list__cell list__cell--numeric" : "list__cell";
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
    const columns = this.options.columns;
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

  /// Branche le clic droit du tableau sur l'export. Appelé par la fenêtre une
  /// fois qu'elle a ses mots.
  ///
  /// **Une seule fois, quoi qu'il arrive.** La fenêtre rappelle cette méthode
  /// chaque fois qu'elle se rhabille ; deux branchements ouvriraient deux
  /// menus l'un sur l'autre au premier clic droit. Le menu, lui, se construit
  /// au moment du clic : ses entrées suivent la langue sans rien rebrancher.
  exportOnRightClick(said: (message: string, alert?: boolean) => void): void {
    if (this.rightClickArmed) {
      return;
    }
    this.rightClickArmed = true;
    onRightClick(this.options.container, () => this.sheet(), said);
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
