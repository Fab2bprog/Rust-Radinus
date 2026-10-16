# The windows of Radinus

Radinus 1.9.3 numbers its windows F01 to F38, and Radinus 2.0.0 keeps those
numbers. A window that 1.9.3 never had takes the next free number after F38 —
F39 is the first, the crossed balance of 2.1.0. The comment at the top of
every page names its own — `// F02 — « Liste opérations du compte »` — and
this file is the map from that number to the files that make it.

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

F05 classifies in bulk, on a draft held in memory: seven characteristics —
five nomenclatures, the status and, since 3.0.0, the verification — each as a
tick box and a list in the banner, and as a column with its drop-down list in
the table. Nothing reaches the database until the diskette is clicked.

F02 is the window everything else orbits: eighteen columns, the tree of mothers
and daughters, the running balance, the three totals, the Période and Filtre
menus, the export by right-click and the printing menu. Its columns are the
user's own (P-49): a header is dragged to move its column, a right-click on
the header row ticks columns in and out, and the layout — order, hidden
columns, widths — is kept in `Preferences`, one for all accounts. The
mechanism is the shared table's (`layoutName`, and an `id` per column). The
detail at the bottom of the seven statistics and of the crossed balance asks
for it too (P-50) — one layout per statistic, the table being named after its
axis — and never the matrix above.

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
| F20–F24 | Statistiques, seven axes | `statistics-<axis>` | `statistics.html?axis=…` |
| F19 | Tableau de bord | `dashboard` | `dashboard.html` |
| F25 | Évolution du solde | `balance-curves` | `balance-curves.html` |
| F39 | Bilan croisé | `crossed-balance` | `crossed-balance.html` |
| F40 | Analyse Évolution du solde | `balance-analysis` | `balance-analysis.html` |

`<axis>` is `category`, `assignment`, `budget-line`, `payment-mode`, `payee`,
`project` or `verification`.

**The seventh axis is not a nomenclature** (3.0.0, 03/10/2026). The first six
cross a list the user manages with time; `verification` crosses the closed
list of four — to verify, verified, doubtful, disputed. It is the same page
and the same template, with two differences held in `statistics::Axis`: its
rows come from the `Verification` table, named in the language of the
interface, and it has no « Sans … » row — a value outside the list is counted
under « À vérifier ». It did not take a number of its own: like the six, it is
`statistics.html` with another axis. The detail under the matrix carries a
« Vérification » column in all seven.

**F40 is F25's chart with the reason under it** (3.0.0, 05/10/2026, P-54):
one drags a zone on the chart, and the operations of that zone appear in a
table below, with a line that sums the zone up — balance before, balance
after, change, debits, credits. The chart's drawing code is a *copy* of
F25's, at the author's request: F25 is not touched and the two windows live
apart. The zone is computed in the core beside the curve
(`balance_curve::zone`), so the change announced is the sum of the rows shown.

**F39 is the first window Radinus 2 adds of its own** (2.1.0, 25/08/2026):
1.9.3 stopped at F38, so a new window takes the next free number rather than
squeezing into a used one. The six statistics cross one nomenclature with
time; F39 crosses two nomenclatures with each other — categories down the
side, assignments across the top — and fixes the time to a single month, which
one steps through with the two clocks. It shares the template of the six, and
its rules of its own are at the top of `crossed-balance.ts`.

### Budget

| F | Name | Label | Page |
|---|---|---|---|
| F26 | Saisie du budget | `budget-entry` | `budget.html?mode=entry` |
| F27 | Contrôle du budget | `budget-control` | `budget.html?mode=control` |

**Two doors, two questions**: one enters a budget, the other checks whether it
was kept. Two menu entries and two labels rather than two tabs of one window.

### Tools

| F | Name | Label | Page |
|---|---|---|---|
| F41 | Simulation de crédit | `loan-simulation` | `loan-simulation.html` |
| F42 | Consommation d'un appareil électrique | `appliance-cost` | `appliance-cost.html` |
| F43 | Mon matelas de sécurité | `safety-cushion` | `safety-cushion.html` |
| F44 | Objectif Épargne | `savings-goal` | `savings-goal.html` |
| F45 | Et si je réduisais… ? | `spending-cut` | `spending-cut.html` |
| F46 | Préparer mes vacances | `holiday` | `holiday.html` |
| F47 | Carnet de ma voiture | `car-logbook` | `car-logbook.html` |
| F48 | Partager une dépense | `sharing` | `sharing.html` |

**F41 simulates a fixed-rate loan and weighs it against the database's
history** (3.0.0, 08/10/2026, P-58). Menu Outils, a main menu of its own between
Nomenclatures and Paramètres (P-61). At the
top, always visible: the type of loan, three linked sliders — amount,
monthly payment, term in months — each with its text field, then the rate, the
fees and the insurance, and the PDF report button. Below, three tabs: « Le
crédit » (eight figures, the cost ring, the outstanding principal, the
repayment schedule) and « Puis-je le rembourser ? » (the accounts to study, the
period, the verdict with its gauge, the income ring, the month-by-month bars,
the projected balance), and « Réglages du jugement » (the three judging
methods side by side, P-60). The window computes nothing and writes nothing: the
core settles the sliders, writes every figure and draws every chart as SVG
(`loan`, `loan_report`, `loan_charts`) — the same SVG the PDF report embeds.
Nothing is stored; the window is hidden, not destroyed, so a simulation is
still there when it is reopened while Radinus runs.

**F42 says what an electrical appliance costs** (3.0.0, 09/10/2026, P-62).
Menu Outils, under F41. One page, no tab: two cards at the top — the
appliance (running: power, hours per day, days per week, share in off-peak
hours; standby: power, hours per day of use) and the contract (option,
prices, off-peak hours, « Reprendre le tarif enregistré ») — then three tiles
(per day, per month, per year: cost and kWh), the standby sentence, the ring
of where the money goes and the one-year detail. The appliance fields start
empty; the contract starts from the `tarif.electricite` preference and
changes made here apply to this calculation only. The core reads the fields,
computes and writes (`appliance`); the ring is `loan_charts::donut`. No PDF.
The window reloads the saved tariff when the preferences save it
(`electricity-tariff-changed`) or when the database moves under it.

**F43 tells how many months savings would last if income stopped** (3.0.0,
09/10/2026, P-63). Menu Outils, under F42. Left: the accounts with two tick
boxes each (« Épargne », « Dépenses »), the period, the fallback income, and
the spending categories, each with its monthly average and a tick box. Right:
the gauge of months covered (0–12, red/orange/green at 3 and 6) with the
verdict and five figures, the two thresholds and when they would be reached,
the projected savings until they run out. The core does everything
(`cushion`); the window keeps only what is ticked. Nothing is stored; the
window rereads the accounts on focus and when operations or accounts change.

**F44 projects the balance of the followed accounts** (3.0.0, 10/10/2026,
P-64). Menu Outils, under F43. Left: the followed accounts (savings accounts
ticked to start with, all of them if there are none), the reference period
(last 12 months, a year, or a range of years with two lists), the question
among three, and its fields — target amount, target date (month list and
year), annual rate, extra effort per month (hidden for the third question,
whose answer it is). Right: the answer in one sentence with its range, the
figures, the chart (real balance of the last twelve months, projection,
range, goal), the notes and the period. The core reads, projects and writes
(`savings_goal`); the chart reuses the frame of `loan_charts`.

**F45 shows what cutting some spending would change** (3.0.0, 10/10/2026,
P-66). Menu Outils, under F44. Left: the followed accounts (all ticked to
start with) and the period, then the settings — group by (categories, payees,
budget lines), horizon slider 1–10 years, rate, target — and the files
(open a project, save it, PDF report, Excel export; P-68).
Right: the answer and its tiles, the table where cuts are typed (a field and
a % / money unit per line; the table is updated in place while its items do
not change, so the field being typed keeps its place), the chart without and
with the cuts, the ring after the cuts, the notes. The door clears every cut,
the rate, the target and the horizon before hiding the window. The core reads,
projects, writes and composes the PDF, the workbook and the JSON project
(`cutback`); the period helper is shared (`period-range.ts`). As in F46, the
project is opened by the Rust-side picker. The door of F45 and F46 asks first
when typed figures would be lost (save and leave, discard and leave, stay;
P-69).

**F46 says what the next trip will cost** (3.0.0, 10/10/2026, P-67). Menu
Outils, under F45. Left: the trip (stay or cruise, adults and children
sliders, nights with the days written beside them, months before departure,
ports of call for a cruise), the accounts whose balance counts as already
saved, and the files (open a project, save it, PDF report, Excel export).
Right: the result and its tiles, the budget — built from the catalogue the
core sends, so the window knows no item by name — with its optional lines
apart, and the ring. The core reads, computes, writes the PDF, the workbook
and the JSON project (`holiday`). Opening a project uses the file picker on
the Rust side: the window is granted no right to read a file.

**F47 keeps the history of a car** (3.0.0, 10/10/2026, P-70). Menu Outils,
under F46. Left: the car's sheet, the home charging tariff (for a car that
plugs in), the entry being added or edited — its fields follow the category
and the energy — with « Prendre une opération… » to fill it from a bank
transaction, and the files (open, save, PDF, Excel). Right: what the car
costs and its tiles, the upcoming dates, the history (filter by category;
click an entry to edit it), the ring by category, energy, wear parts, tyres,
battery health, and the bars by year. The logbook lives in the application
state; every gesture goes to the controller, which answers with the whole
logbook already written (`car`). Opening a logbook uses the Rust-side
picker. The door asks before forgetting unsaved changes (P-69), then
forgets the logbook.

**F48 splits a sum between people, with constraints** (3.0.0, 11/10/2026,
P-71). Menu Outils, under F47 — **the only tool enabled without an open
database**: it reads and writes nothing there. Left: the split (label,
total, one rule for everything or one per item, rounding, « Masquer les
revenus »), the items that do not concern everyone — the rest of the total is
the « Commun » item, each with its rule under its name in per-item mode —,
and the files (open, save, the general distribution PDF, the payment status
PDF, the individual statements written into a chosen folder, Excel). Right:
the result; one grid for the people — a row each, with what they owe kept in
view beside their name while the grid scrolls, their optional constraints,
and a column per item where one ticks who takes part (with a percentage or
parts field when that item's rule asks for one); the dated payments; and
where they stand, per household. The window computes nothing and composes
no sentence — even an added person's default name comes from the core
(`sharing`). Opening a project and choosing the statements' folder use the
Rust-side pickers. The door asks before forgetting (P-69). Each calculation
also returns the core's **advice** (P-72), even when refused: a sentence under
the rule (`#rule-advice`, or `#advice-<item>` per item), grey placeholders in
the empty boxes, and the buttons « Reprendre les valeurs conseillées »,
« Pourcentages d'après les revenus » and « Tout répartir à nouveau ».

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
