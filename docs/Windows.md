# The windows of Radinus

Radinus 1.9.3 numbers its windows F01 to F38, and Radinus 2.0.0 keeps those
numbers. The comment at the top of every page names its own — `// F02 — «
Liste opérations du compte »` — and this file is the map from that number to
the files that make it.

Read `Architecture.md` §6 first if you have not: it explains the window
lifecycle these pages live under, and it is not the usual one.

---

## 1. How a window is made

Four things, in four places:

| Where | What it holds |
|---|---|
| `src-tauri/src/windows.rs` | The `WindowSpec`: its **label** (Tauri's identity for it), its page, its title key, its size, whether it is closable and resizable, and its parent. |
| `src-tauri/capabilities/default.json` | The label again. **A window missing here cannot talk to Rust at all** — not even to close itself. |
| `vite.config.ts` | The page again. A page missing here is not built, and the window opens on a 404. |
| `ui/windows/<name>.html` + `.ts` | The window itself. |

Those four are checked against each other by the crossings
(`src-tauri/src/crossings.rs`). Forget one and `cargo test -p radinus --lib`
names it.

**One page can serve several windows.** The seven nomenclatures share one list
page and one form page; the six statistics share one page; the two budget
doors share one. Which one it is travels in the address (`?kind=category`,
`?axis=payee`, `?mode=control`) **and** in the label, and both matter: an axis
carried by the label but not by the address opened six distinct windows all
showing the categories.

---

## 2. The catalogue

### The middle of the application

| F | Name | Label | Page |
|---|---|---|---|
| F01 | Fenêtre principale | `main` | `index.html` |
| F02 | Liste opérations du compte | `operations` | `operations-list.html` |
| F03 | Fiche opération | `operation-form` | `operation-form.html` |
| F04 | Fiche sous-opération | `sub-operation-form` | `sub-operation-form.html` |
| F05 | Classification rapide | `quick-classification` | `quick-classification.html` |

F02 is the window everything else orbits: sixteen columns, the tree of mothers
and daughters, the running balance, the three totals, the Période and Filtre
menus, the export by right-click and the printing menu.

### Accounts

| F | Name | Label | Page |
|---|---|---|---|
| F04 / F06 | Gestion des comptes | `accounts-list`, `accounts-select`, `accounts-stats` | `accounts-list.html?mode=…` |
| F07 | Soldes de vos comptes | `balances` | `balances.html` |
| F08 | Fiche compte | `account-form` | `account-form.html` |
| F09 | Transférer un montant | `transfer` | `transfer.html` |
| F32 | Relevé d'identité bancaire | `rib` | `rib.html` |

**The accounts list has three uses and three labels.** Managing accounts,
choosing *one* account (for the operations list, the quick classification, the
statement import, the bank details), and choosing *several* (for the six
statistics, the dashboard, the balance curve). What one came to do travels
with the question — without it, choosing an account would always open the same
thing, whichever menu entry was clicked.

F08 carries the **Outils** menu: setting the opening pointed balance from the
bank's current balance, the account statistics, and deleting every operation
of the account.

### Nomenclatures

| F | Name | Label | Page |
|---|---|---|---|
| F10 | Fiche d'une nomenclature | `<kind>-form` | `nomenclature-form.html?kind=…` |
| F11 | Liste d'une nomenclature | `<kind>-list` | `nomenclature-list.html?kind=…` |
| F36 | Fiche modèle d'opération | `operation-template-form` | `operation-template-form.html` |
| F37 | Liste des modèles d'opérations | `operation-templates`, `operation-templates-select` | `operation-templates-list.html` |

`<kind>` is one of `category`, `assignment`, `payment-mode`, `payee`,
`project`, `budget-line`, `bank` — so fourteen windows out of two pages. The
dossier says it outright: *"gabarit identique pour les fiches Affectation,
Mode, Tiers, Projet, Poste budgétaire, Banque — sans le champ Poste
budgétaire"*.

### Cheques

| F | Name | Label | Page |
|---|---|---|---|
| F12 | Fiche chèque | `cheque-form` | `cheque-form.html` |
| F13 | Liste des chéquiers | `chequebooks`, `chequebooks-select` | `chequebooks-list.html` |
| F14 | Composition du chéquier | `cheques`, `cheques-select` | `cheques-list.html` |
| — | Association chèque ↔ opération | `cheque-operations` | `cheque-operations.html` |
| F31 | Paramètres chéquier | `chequebook-form` | `chequebook-form.html` |

F13 and F14 each have a **selecting** mode with its own label, for when
another window is asking for a chequebook or a cheque rather than managing
them.

### Recurring operations

| F | Name | Label | Page |
|---|---|---|---|
| F15 | Fiche opération périodique | `recurring-form` | `recurring-form.html` |
| F16 | Proposition de calendrier | `recurring-calendar` | `recurring-calendar.html` |
| F38 | Liste des opérations périodiques | `recurring` | `recurring-list.html` |

### Importing

| F | Name | Label | Page |
|---|---|---|---|
| F17 | Importation de relevés bancaires | `statement-import` | `statement-import.html` |
| F18 | Rapprocher une transaction | `statement-form` | `statement-form.html` |
| — | Découpage d'un relevé CSV | `csv-statement` | `csv-statement.html` |
| F34 | Importation Excel — la zone | `excel-import` | `excel-import.html` |
| F35 | Importation Excel — les champs | `excel-fields` | `excel-fields.html` |
| — | Importation Excel — la destination | `excel-association` | `excel-association.html` |

The same yellow folder opens an `.ofx` **or** a `.csv`. When it is a CSV, the
cutting window steps in first; once validated, its lines fall into the
integration window **as if they had been OFX**.

### Statistics and analysis

| F | Name | Label | Page |
|---|---|---|---|
| F20–F24 | Statistiques, six axes | `statistics-<axis>` | `statistics.html?axis=…` |
| F19 | Tableau de bord | `dashboard` | `dashboard.html` |
| F25 | Évolution du solde | `balance-curves` | `balance-curves.html` |

`<axis>` is `category`, `assignment`, `budget-line`, `payment-mode`, `payee`
or `project`.

### Budget

| F | Name | Label | Page |
|---|---|---|---|
| F26 | Saisie du budget | `budget-entry` | `budget.html?mode=entry` |
| F27 | Contrôle du budget | `budget-control` | `budget.html?mode=control` |

**Two doors, two questions**: one enters a budget, the other checks whether it
was kept. Two menu entries and two labels rather than two tabs of one window.

### Everything else

| Name | Label | Page |
|---|---|---|
| Pièces jointes | `attachments` | `attachments.html` |
| Journal (⌘H) | `journal` | `journal.html` |
| Choix de la langue | `language-choice` | `language-choice.html` |
| Gestion de base de données | `database-selector` | `database-selector.html` |
| Nouvelle base de données | `database-form` | `database-form.html` |
| Protection par mot de passe | `password-form` | `password-form.html` |

The last four have no F number: the original had nothing like them. The two
fiches belong to the database window and open above it — one creates a database,
the other sets, changes or removes its password (`Decisions.md`, P-34). The
language window is the only page in the application that **uses no sentence at
all** — each line is the name of a language written in that language, which is
understood before anyone knows what the user speaks.

---

## 3. The shape they all share

Every window is the same frame, described in the graphic charter and built by
`ui/windows/window.css`:

```
┌──────────────────────────────────────────────┬────────┐
│                                              │        │
│   .window__content                           │ .panel │
│   a table (.list) or a form (.form)          │ slate  │
│                                              │ icons  │
│                                              │        │
│                                              │  ···   │
│                                              │ door   │
├──────────────────────────────────────────────┴────────┤
│ .info-bar — what just happened, or what is expected   │
└───────────────────────────────────────────────────────┘
```

- **the slate panel** on the right carries the icon buttons, and the **door**
  alone at its foot. Some forms carry a second, decorative panel on the left
  with a theme image;
- **the info bar** at the bottom says what happened. It never carries a
  sentence of its own: everything in it comes from the dictionary, or from the
  core already written;
- **the door is the only way out.** The system's close button is disabled on
  every window, which leaves one exit to guard instead of two.

Two shared pieces do most of the work and are worth reading before any window:

- **`ui/windows/table.ts`** — the table every list is built on: columns,
  sorting, a funnel filter per column, multiple selection, virtualised rows,
  and the right-click export.
- **`ui/windows/texts.ts`** — the window's words: fetched once before anything
  is drawn, and put back by `dress()` whenever the language changes.

---

## 4. Adding a window

Six steps, and the crossings will tell you which one you forgot:

1. the rule in `radinus-core`, if it needs one;
2. the commands in `commands.rs`, registered in `lib.rs`;
3. a `WindowSpec` in `windows.rs`, and its label in
   `capabilities/default.json`;
4. the page in `ui/windows/`, and its entry in `vite.config.ts`;
5. its keys in the three `.ftl` files, and in `texts.rs`;
6. `listen("window-parameters:<label>")` in its script — unless it truly never
   receives any, and then name it in the crossing test that checks for it.

```bash
cargo test -p radinus --lib
```
