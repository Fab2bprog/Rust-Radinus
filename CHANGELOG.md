# Changelog

Notable changes to Radinus, newest first. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and Radinus follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Two version numbers live in this project and they do not move together:

- the **software** version, below, which restarts at 2.0.0 for the rewrite;
- the **database schema** version (`Parametres.VerDataBase`), which continues
  the line Radinus 1.x walked from 0 to 9 and is at 11 today. A database is
  migrated forward when it is opened, never backward.

## [3.0.0] — 03/10/2026

Never published under its first number, 2.1.1: this version becomes **3.0.0**
(Fabrice, 10/10/2026), for the size of what it adds — the Outils menu and its
seven tools among others.

### Added

- **QIF bank statements** (Fabrice, 15/10/2026, P-73). « Importation de
  relevés bancaires » now opens a `.qif` as well as an `.ofx` or a `.csv`, by
  the **same** yellow folder, account question, table and buttons as OFX —
  the OFX reader itself is untouched. Dates and decimal separators are
  decided over the whole account, never line by line; a file that
  contradicts itself is refused with both lines quoted; when no date proves
  the day/month order, the window asks. Microsoft Money's opening balance
  (« Solde initial », `L[account]`) is set aside and announced; an
  unreadable operation is set aside with its number, never silently.
  Microsoft Money's « stricte » and « relative » exports read the same.
  A **« Relevés QIF » page in the Preferences** (under « Importation »)
  sets a standing day/month order — « Me demander à chaque fois » by
  default — and the label (payee + memo by default, payee only, memo only);
  software settings, kept with the language and the zoom, usable with no
  database open.
- **« Fichier » and « Écart » stay empty when a statement gives no readable
  balance** — a QIF never does, a CSV neither — instead of showing a
  0,00 € the bank never stated (Fabrice, 15/10/2026).
- **The loading sentence no longer contradicts the table** (Fabrice,
  15/10/2026: « tu les as éclaircies : là tu te contredis »). It counted only
  the FITIDs already in the database, so a QIF or a CSV already integrated
  read « 106 lignes lues, dont 0 déjà présentes » while its 106 lines showed
  in pastel. It now counts both, each with its word: « déjà présentes » for
  the certainty, « qui ressemblent » for the suspicion (same date, label and
  amount), never the same line twice — in the information bar and in the
  file information.

- **A « Statut opération » column in the operations list**, between « Date
  pointage » and « Libellé ». Every row shows its status in words; the selected
  row turns it into a drop-down list — Pointé, Engagé, Prévu — exactly like the
  five nomenclature columns, and choosing writes at once. The clearing-date
  rules are those of the Pointer button: switching to Pointé sets the
  operation's date **only where the clearing date is empty**, and a date that
  is already there is never touched, in either direction. A sub-operation
  carries its mother's status, so the list is not offered on it. The column
  sorts in the logical order — pointed, committed, planned — not
  alphabetically, and is exported with the others.

- **« Vérification »: what the user thinks of an entry, next to what the bank
  did with it.** Some users do not trust their bank: they keep their paper
  receipts and check every line. For them "pointed" meant "I agree with this
  debit" — but an imported statement line arrives pointed, because the bank
  has passed it, before they have looked at anything. The status keeps saying
  what the bank did; a new field says what the user thinks, and the two never
  touch each other. Four values, identified by their key and translated in the
  18 languages: **À vérifier**, **Vérifiée**, **Douteuse**, **Contestée**.
  - In the operations list, a « Vérification » column right after « Statut
    opération »: the word on every row, a drop-down list on the selected one,
    and choosing writes at once. It is read by its colour — black, dark green,
    dark orange, red. The closed list is coloured everywhere; the open one is
    drawn by the system, which on macOS ignores colours.
  - In the operation fiche, a « Vérification » field under the clearing date.
  - A sub-operation carries its mother's: what is judged is the bank's line,
    and a ventilation is not one.
  - Typing an operation by hand, a transfer, a recurring operation, a template
    and a duplicate all give « Vérifiée ». **Only an import can give « À
    vérifier »**, and only if asked: Preferences has a new branch,
    « Importation », with one choice — « Vérifiée » (the default, nothing
    changes for those who trust their bank) or « À vérifier ». It applies to
    OFX and CSV statements and to the Excel import.
  - Balances and the status are untouched. So is the PDF printing of the
    list, which does not show the field yet.
- **The verification in the quick classification.** A seventh characteristic,
  on the principle of the six others and without changing that of the window:
  everything goes into the draft, and nothing is written until one saves.
  - In the table, a « Vérification » column in last position, the word in its
    colour and a drop-down list on the selected row.
  - In « Changer caractéristiques sélection en », a seventh tick box with its
    list of the four verifications, under the status in the right-hand column,
    to apply one to a whole selection.
  - It follows the rules of the status: it goes down to the sub-operations
    when saved, and it has no « Non précisé ». It touches neither the status
    nor the clearing date.
- **A horizontal scrollbar under the quick classification's list.** Ten
  columns do not fit in a narrowed window: each now has a width below which it
  refuses to shrink, and the table overflows instead, its header following the
  rows — the mechanism the operations list has had since 2.0.5.
- **The verification of a whole selection, by right-click in the operations
  list.** The table's right-click menu now opens with a « Vérification » entry,
  above the ten exports. It unfolds a sub-menu of the four verifications, each
  in its colour, and the one chosen is given to every selected row at once —
  where the drop-down list of the column changes one row at a time. A selected
  sub-operation stands for its mother. With no row selected the entry is
  greyed. Nothing announces the change: the table is reread and the colours
  move. The detail under the seven statistics, which carries the same column,
  has the same entry in its own right-click menu; every other table keeps its
  ten exports.
- **The right-click menu of the operations list, in three entries.** It now
  reads « Statut opération ▸ », « Vérification ▸ », « Exporter vers ▸ ». The
  first is new: Pointé, Engagé, Prévu, given to every selected row at once,
  under the rules of the Pointer button — switching to pointé dates the
  clearing at the operation's date where the field is empty, and a date
  already there is never touched. The ten exports moved under « Exporter
  vers », under their short names (« Excel (.xlsx) »…), and stay offered with
  no row selected. This is the operations list only: the detail of the
  statistics keeps « Vérification » and its ten exports in a row, and every
  other table its ten exports.
- **Each user his own columns, in the operations list.** Not everyone uses
  the same columns, nor wants them in the same order.
  - Dragging a header moves its column; a vertical line shows where it will
    land. A plain click still sorts, the right edge still widens.
  - A right-click on the header row lists the columns, a tick before those
    shown; ticking and unticking acts at once and the menu stays open. One
    column always remains — whichever — and is greyed while it is the last.
    « Rétablir les colonnes par défaut » closes the list.
  - The order, the hidden columns and the widths pulled by hand are
    remembered at the end of each gesture, in the `Preferences` table of the
    database — one key per table (`tableau.operations-list`), one layout for
    all accounts. No schema change: the database stays at version 11, an older
    Radinus ignores the key, and a backup carries it.
  - A stored layout the table cannot read — a column it does not know,
    everything hidden — is dropped and the table opens as it was born. A
    column added by a later version takes its born place and the rest of the
    layout is kept.
  - Hiding a column that carries a filter clears that filter. The right-click
    export follows the columns shown, in their order. The « + » that unfolds
    sub-operations stays first and is not in the menu. PDF printing is
    unchanged.
  - Paramètres → Préférences has a new leaf, « Colonnes des tableaux »: a
    drop-down list naming the window, one « Réinitialiser » button beside it
    for the tables of that window, and « Tout réinitialiser ». They act at
    once, without the save button.
  - The mechanism lives in the shared table: a window names its table and its
    columns, nothing more.
- **The same in the detail of the seven statistics and of the crossed
  balance** — the list of operations at the bottom of the window, behind a
  cell; the matrix above is untouched. One layout **per statistic**: what is
  arranged in « Stat par catégories » changes nothing in « Stat par tiers ».
  The crossed balance has its own. All eleven columns can be moved and hidden,
  none is fixed. The drop-down list of « Colonnes des tableaux » in the
  preferences now names nine windows, each as its entry in the general menu.
- **A « Vérification » column in the detail of the crossed balance**, between
  the label and the category, as in the statistics: the word in its colour, a
  drop-down list on the selected row, and a « Vérification » entry at the head
  of the rows' right-click menu to judge a whole selection.
- **Copying from a table.** Nothing could be copied out of a list: its rows
  cannot be highlighted, and no command copied. Now, in every table:
  - ⌘C on macOS, Ctrl+C elsewhere, copies the selected rows — one line per
    row, in the order of the screen, the columns shown in their order,
    separated by tabs: a spreadsheet pastes one cell per column. No column
    titles.
  - The right-click menu opens on « Copier la cellule » (the cell under the
    pointer) and « Copier les lignes sélectionnées », greyed when there is
    nothing to copy.
  - An amount is copied as a pure number — « 1 549,81 € » gives « 1549,81 » —
    with the decimal separator of the language, so the spreadsheet reads a
    number; a debit keeps its minus sign. Anything else is copied as read.
  - In a search field or a drop-down list, the key keeps its usual meaning.
  - The matrices of the statistics and of the crossed balance offer « Copier
    la cellule » too.
- **A new window, « Analyse Évolution du solde »**, under « Graphique
  Évolution du solde » in the Statistiques menu. The chart says the balance
  fell on a given day; this window says why.
  - It shows the same chart — one stepped curve per account, the total, the
    Période menu, the year buttons — and, under it, a table of operations.
  - **One drags a zone on the chart**: pressing sets a bar on the day, dragging
    stretches a veil to the pointer in either direction while the two dates
    follow the hand, and releasing fills the table. A click without dragging
    takes a single day. Dragging past the edge stops the zone at the edge. The
    zone stays until another is drawn; changing the period, the year or the
    accounts clears it.
  - A summary line gives the zone's dates, the balance before it (the evening
    of the day before), the balance after it, the change, and the totals of
    debits and credits. The change is exactly the sum of the rows shown: both
    come from the same computation as the curve, which follows the final
    balance — every first-level operation, whatever its status.
  - The table is the detail of the statistics, with two differences: it lists
    the **mother** operations and not their sub-operations — it is the bank's
    entry that moves the balance — and it opens on a « Compte » column, a zone
    covering several accounts. Drop-down lists on the selected row,
    double-click to open the fiche, « Vérification » and the exports by
    right-click, and its own column layout (order, hidden, widths, tints).
  - « Graphique Évolution du solde » is untouched; the two windows are
    independent, and the chart's drawing was copied rather than shared.
- **A column can be tinted.** The right-click menu of the header row is now
  « Afficher/Masquer ▸ » (the list of columns and their ticks, as before),
  « Colorer la colonne : … ▸ », a rule, and « Rétablir les colonnes par
  défaut ». « Colorer » acts on the column whose header was clicked and names
  it; it offers « Aucune couleur » and nine tints — rouge, orange, rose, vert
  pastel, vert, bleu pastel, bleu, jaune pastel, jaune — each with its swatch.
  The tint is a transparent layer over the cells: the selected row, the
  sub-operations, the red of a debit and the colours of the verification stay
  readable. The header is not tinted, and neither the exports nor the PDF
  carry the colours. They are remembered with the layout, per table, and
  « Rétablir » takes them off. In the operations list, the detail of the seven
  statistics and that of the crossed balance; the « + » column cannot be
  tinted.
- **The Filtre menu of the operations list filters on the verification
  too.** It now reads « Toutes les opérations », a rule, « Filtre Statut ▸ »
  (pointées, engagées, prévues — the three choices that were there, one level
  down) and « Filtre Vérification ▸ » (the four verifications, in their
  colours). One choice per sub-menu, and the two combine: pointées *and* à
  vérifier. Each sub-menu opens on « Afficher tout », which lifts that filter
  alone and is ticked when no choice is made there; clicking a ticked choice
  again lifts it too; « Toutes les opérations » lifts both. A sub-menu's own entry is ticked while a choice is made in it.
  The core applies both filters, so the totals at the foot still add up what
  the table shows.
- **A horizontal scrollbar under the detail of the statistics and of the
  crossed balance.** The list of operations behind a cell squeezed its columns
  until they could not be read; with the « Vérification » column it carries
  eleven. It now overflows instead, and its header follows the rows. The seven
  statistics share one list and get it at once; the crossed balance has a copy
  of its own and gets it too.
- **« Stat par vérifications », a seventh statistic.** The same table as the
  six others — rows down the side, the twelve months across, Somme and Cumul
  at the foot, the five switches, clicking a cell to see the operations behind
  it, the export by right-click. Its rows are the four verifications, always
  shown, in the order of their key and each in its colour: « 340 € still to
  verify in September » is read at a glance. In the Statistics menu between
  « Stat par projets » and the dashboard, on ⌘⇧7.
  - It has **no « Sans … » row**, unlike the six others: every operation
    carries a verification. One that carried a value outside the list — a
    damaged database — is counted under « À vérifier », in the table and in
    the detail alike: an entry nobody has judged is an entry to look at.
- **A « Vérification » column in the detail of the seven statistics**, between
  the label and the category: the word in its colour on every row, a drop-down
  list on the selected one. An entry is checked where it is being looked at,
  without going back to the account. Choosing writes at once and everything is
  recomputed — in the statistic by verification the operation changes row and
  so leaves the detail of the cell it was in. The detail of the crossed
  balance is not changed.
- **The accounts of the welcome window can be chosen and ordered.** Each tile
  of « Vos comptes » carries a tick box before the account's name: unticked,
  the account leaves the three totals above — « Solde en banque », « Solde
  réel », « Solde final » — and the two rings « Dépenses » and « Gains ». It
  stays shown, set back, and still opens its operations with a click. A line
  under « Solde en banque » says how many accounts are counted as soon as one
  is not. Tiles are reordered by dragging them. Both are remembered in the
  database.
- **A button « Réinitialiser les réglages de confort »** in the preferences,
  under a new branch « Réinitialisation ». After a confirmation it puts back
  the columns of every table, the order and tick boxes of the welcome window,
  and the display size. The language, the currency and the verification of
  imported operations are not touched.
- **A credit simulation window** — « Simulation de crédit », in a new main
  menu « Outils » placed between Nomenclatures and Paramètres. A fixed-rate loan, consumer or mortgage: three linked sliders
  (amount, monthly payment, term in months), each with a text field that goes
  beyond the slider up to 100 million and 600 months, then the rate, the
  arrangement fees and the monthly insurance. Moving the amount or the term
  recomputes the payment; moving the payment recomputes the term, to the whole
  month. The first tab shows the payment, the APR, the cost of interest and
  insurance, the total owed, a ring of what the loan costs, the outstanding
  principal and the repayment schedule (copy, export, adjustable columns). The
  second tab weighs the loan against the history of the ticked accounts over
  the last 12 months or a calendar year (up to five years back): average
  income and spending, current loans found among the recurring operations,
  debt ratio on a gauge, money left to live on, months that would have ended in
  the red, and the projected balance over the life of the loan — summed up as
  « Jouable », « Serré » or « Risqué » from three questions, each about what
  the loan changes and each shown with its own coloured dot: is the debt ratio
  reasonable, does the payment fit in what an ordinary month puts aside, does
  the balance hold until the end. A history already in deficit before any
  loan is said apart, in a warning. A third tab, « Réglages du jugement »,
  sets out three methods side by side — optimistic, neutral (the default),
  severe — written with the person's own figures, each with its verdict for
  the loan; one is chosen with a tick, and each has its own yearly rise in
  spending (0, 2 and 3 % to start with, any whole number from 0 to 99).
  Nothing is remembered. Transfers between ticked accounts are
  recognised and set aside. A « Rapport PDF » button writes the whole
  simulation, charts included; for a mortgage the schedule is printed year by
  year unless « Tableau mois par mois » is ticked. Nothing is stored.

- **What an electrical appliance really costs** — « Consommation d'un appareil
  électrique », in the « Outils » menu under the credit simulation. Nothing is
  assumed about the appliance: no list of typical devices, every figure comes
  from the person — power when running, running hours per day, days of use
  per week, standby power and standby hours (left empty: the rest of the day;
  on days without use the appliance stays plugged in and all that time is
  standby). With peak / off-peak hours, the share of running time in off-peak
  hours is asked, and standby, which runs day and night, is split by the
  number of off-peak hours. The result, recomputed at each field: cost and
  kWh per day, per month and per year, a ring and a one-year table of where
  the money goes (running / standby × peak / off-peak), and what standby
  alone costs. The standing charge is not counted. No PDF report. The
  contract's prices come from a new preference, « Tarif d'électricité »
  (Paramètres › Préférences › Outils), set by default to EDF's Tarif Bleu on
  1 August 2026 (Base 0,2001 €/kWh; peak 0,2142 €, off-peak 0,1589 €, 8
  off-peak hours), with a « Revenir au Tarif Bleu EDF » button; prices changed
  in the calculation window apply to that calculation only.

- **« Mon matelas de sécurité »** — in the « Outils » menu, under the
  appliance tool: if income stopped tomorrow, how many months would savings
  last? Everything comes from the database. Each open account has two tick
  boxes, « Épargne » (the money one would draw on) and « Dépenses » (where
  everyday spending comes from), ticked to start with from the account's
  type: a cheque account for spending, a livret or a CEL for savings, a PEL,
  PERP or term account for neither. Spending is the monthly average of the
  complete months of the period (last 12 months, or a calendar year back to
  N-5), transfers between one's own accounts — any of them, ticked or not —
  set aside, and split by category: those one would cut in a hard time can be
  unticked. An optional fallback income (unemployment benefit, a partner's
  salary) is taken off. The answer: the months covered on a gauge from 0 to
  12 — red under 3, orange from 3 to 6, green beyond —, what is missing for
  3 and 6 months and when they would be reached at the saving pace of the
  period, and the curve of savings melting month by month until they run
  out. Nothing is stored, no PDF report.

- **« Objectif Épargne »** — in the « Outils » menu, under the safety
  cushion: three questions on the balance of the ticked accounts — *when will
  I have this amount?*, *how much will I have on this date?*, *how much should
  I save per month to have this amount on this date?* The pace comes from the
  history: the last 12 months, a calendar year, or a **range of years**;
  transfers between two followed accounts cancel out. The projection follows
  the **typical year** — each coming month takes the average of the same
  months of the period — and gives a range (prudent and favourable, from the
  lowest and highest quarter of the months) around the probable answer. A
  loan found among the recurring operations frees its instalment after its
  last due date. An optional annual savings rate adds monthly interest, and
  an optional « and if I saved more per month » shows the gain. A chart shows
  the real balance of the last twelve months, then the projection, its range
  and the goal. Nothing is stored, no PDF report.

- **A range of years in the credit simulation and the safety cushion.** Their
  period menu gains « Plage d'années… », with two lists « de » and « à » (the
  last three years to start with): averages, judgements and the cushion's
  spending and saving pace are then taken over every complete month of the
  range. In the credit simulation, the projected balance now follows the
  **typical year** — each coming month takes the income and spending of the
  same calendar months of the period, before the yearly rise of each method
  — and the month-by-month bars keep every month, thinner, with one label in
  two or three when there are many.

- **« Et si je réduisais… ? »** — in the « Outils » menu, under the savings
  goal: what cutting some spending would change over time. The followed
  accounts and the reference period (range of years included) are those of
  « Objectif Épargne », whose projection is reused. The spending is listed by
  categories, payees or budget lines, the heaviest first, each with its
  monthly average; a cut is typed on any line in % or in money per month,
  never more than the spending itself, and follows the seasons of its item.
  An horizon slider from 1 to 10 years, an optional savings rate and an
  optional target amount (« reached N months sooner »). The answer: the
  sentence, the gains per month, per year and over the horizon, the balance
  without and with the cuts — the money gained shaded in green — and a ring
  of the monthly spending after the cuts, savings included. The cuts are
  forgotten when the window is closed; a **PDF report** keeps them, with the
  settings, the result, both drawings and the full table.
  The project can also be **saved as a JSON file and reopened** — the period,
  the grouping, the horizon, the options, the ticked accounts and every cut,
  each found again by its label in the database opened — and **exported to
  Excel** (« Postes » and « Résultat »).
  In this tool and in « Préparer mes vacances », the exit door now asks first
  when typed figures would be lost — typed and not saved since: « Enregistrer
  et sortir », « Abandonner et sortir » or « Rester », as in the quick
  classification. Escape stays.

- **« Préparer mes vacances »** — in the « Outils » menu, under « Et si je
  réduisais… ? »: what the next trip will cost. A stay or a cruise; adults
  and children on sliders (1–20, 0–20); the nights (days are the nights plus
  one), the months before departure, and the ports of call of a cruise. Each
  cost item has an amount and its choices — for everyone or per person (with
  a child price), per night, per day, per port of call or for the stay. A
  stay has transport, accommodation, meals, visits and other costs; a cruise
  has getting to the port, cabins (number × price), service charge, drinks
  package, shore excursions, port taxes, on-board wifi, spending on board
  and ashore. Optional lines for both: cancellation insurance (% of the main
  items or an amount), tourist tax (per adult per night), car on site,
  parking, bank fees abroad (% of on-site spending), formalities, pet care.
  The money already saved is the real balance of the ticked accounts. The
  result: the total, per person, per person per day, still to fund, the
  saving needed per month, and a ring of where the money goes. A project can
  be **saved and reopened as a JSON file** (amounts written neutrally, ticked
  accounts found again by their label), exported as a **PDF report** and as
  an **Excel workbook** (« Budget » and « Résultat », values not formulas).
  Nothing enters the database; the door clears everything.

- **« Carnet de ma voiture »** — in the « Outils » menu, under « Préparer mes
  vacances »: the history of a car. The car's sheet: registration number,
  make, model, powertrain (petrol, diesel, LPG, E85, hybrid, plug-in hybrid,
  electric, hydrogen), first owner, first registration, date and mileage when
  acquired, service interval in months and/or km. Eight categories of entries:
  energy (litres, kWh or kilos; an E85 car also takes petrol; a plug-in
  hybrid both petrol and electricity), routine maintenance, service, wear
  parts (a starting list that follows the powertrain, completed with any part
  typed), tyres (front, rear or all four), breakdowns, insurance (months
  covered) and roadworthiness test (pass or retest). Each entry carries its
  date, odometer, amount, garage and note, and the battery health for an
  electric or plug-in car. A home charge is priced at the car's own tariff —
  taken from the appliance tool's, editable in the window, kept in the car's
  file — and keeps the cost of its day. An entry can be filled from a bank
  transaction (date, amount, payee, label), optionally. The summary: total
  cost, per month and per kilometre since the acquisition, kilometres driven,
  consumption measured from one full tank to the next, energy cost per km,
  costs by category (ring) and by year (stacked bars), the real lifetime of
  each part and set of tyres, the battery health over time. The upcoming
  dates: service, roadworthiness test (French rule: four years after first
  registration, then every two; a retest within two months), insurance
  renewal, parts and tyres at their observed lifetime — placed in time at
  the car's own pace. One **JSON file per car**, saved and opened by hand;
  a **PDF file** of the car (to show when selling it) and an **Excel
  workbook**. The door asks before forgetting unsaved changes. Nothing
  enters the database or the preferences.
- **« Partager une dépense »** — in the « Outils » menu, under the car
  logbook, and **usable without an open database** (Fabrice, 11/10/2026,
  P-71). « Qui paie quoi ? »: a sum shared between up to 40 people — a
  restaurant bill, a rental, a coach trip — by one rule for the whole
  expense or one per item: equal shares, parts, percentages (which must make
  100 %, or the calculation is refused) or in proportion to incomes. Items
  that do not concern everyone (the wine, for the drinkers) are carved out of
  the total, the rest going to a « Commun » item; what someone takes for
  themselves alone (« Ses extras ») stays theirs. Optional limits per
  person — « Au minimum », « Au maximum », « Montant exact »: whatever a
  person held to a maximum does not pay falls on the other participants of
  the same items, and nobody pays for an item they are not in; a column
  « Ce qui a joué » says which limit changed a share. Every column has a
  tooltip (« ⓘ ») with a definition and an example. Rounding to the cent or to the euro. Dated payments, counted per
  household; « Surplus offert » turns what someone paid beyond their share into a
  gift to the group; once everything is paid, the fewest transfers are
  suggested. A **JSON project**, **three PDF reports** — the general
  distribution, one statement per person or household written into a
  chosen folder, the state of payments —, and an **Excel workbook**, with
  incomes hidden by default. The door asks before forgetting.
  **Advice** (P-72): the headline says what each pays (« chacun paie
  60,00 € », or the range); a live sentence under the rule says what it gives
  (« 90,00 € ÷ 3 personnes = 30,00 € chacun », « Il manque 60 % pour arriver
  à 100 % »); empty boxes show suggested values in grey, which count only once
  taken with « Reprendre les valeurs conseillées »; « Pourcentages d'après les
  revenus » and « Tout répartir à nouveau » — for the person added after the
  percentages already made 100 %, announced in orange.
- **A reminder that an average is only as good as the history behind it**
  (Fabrice, 10/10/2026). The four tools that average the database's history
  — the loan simulation, « Mon matelas de sécurité », « Objectif Épargne »
  and « Et si je réduisais… ? » — show in their information bar, whenever a
  result is on screen: « Plus votre historique est long, meilleure sera
  cette analyse : l'idéal est d'avoir au moins un an d'opérations. »
  « Meilleure », not « fiable »: the user is meant to stay critical, even
  with a year of operations. In all eighteen languages.

### Changed

- **The crossed balance moves from ⌘⇧7 to ⌘⇧8.** The seven statistics now
  take ⌘⇧1 to ⌘⇧7 in the order of the menu, and it follows them. Nothing had
  been published with the old shortcut.
- **The database schema is at version 11.** `Operation.IDVerification` and its
  table `Verification`. A version-10 database is brought up when it is opened,
  with nothing to do: the column arrives with its default, so **every
  operation already there is « Vérifiée »**. A Radinus older than this one
  refuses a version-11 database rather than opening it, and asks for an update.
  Backups written from now on carry the field; older ones — 1.9.3's included —
  restore as before, their operations « Vérifiée ». A backup that carries the
  field with a value that means nothing restores that operation as « À
  vérifier ».
- **The account tiles of the welcome window stay on one row**, with a
  horizontal scrollbar when the window is too narrow for them. They used to
  wrap onto several lines and push the rings down.

### Fixed

- **Letters could be typed into the tools' figures** (Fabrice, 11/10/2026:
  « on peut écrire des lettres dans un champ numérique, c'est pas bien du
  tout »). The eight tools of the Outils menu now pass every field that holds
  a figure through the forms' own filter: no letter, no minus sign, a set
  number of decimals — whole numbers for months, nights or kilometres, three
  for an interest rate, four for a price per kWh, two elsewhere —; amounts are
  written out on leaving the field, and an empty optional field stays empty
  rather than becoming 0,00. A test checks that every numeric field of a
  tool's page goes through the filter, so a new one cannot be forgotten.
- **A refused calculation left the previous result on screen**, as if it
  still held: in the credit simulation, the appliance, the safety cushion,
  « Et si je réduisais… ? », the holidays and the expense split. The old
  result now fades (or, in the split, is cleared) until the field is
  corrected; the fields themselves stay sharp.
- **A written-out amount could no longer be corrected by typing**: once
  « 1 250,00 » carried its thousands separator, the filter refused every
  key in the field, in every form. The separators are now set aside when a
  key is judged.
- **In eleven languages, an amount of a thousand or more could not be
  saved**: the filter grouped the thousands with a full stop (German,
  Spanish, Italian…) or a comma (English, Hebrew, Arabic), which the core
  reads as decimals, and refused. Inside a field, the thousands are now
  grouped with a narrow space in every language — the core reads it
  everywhere; displays outside the fields are unchanged.
- **« Soldes de vos comptes » had no right-click menu at all** — neither copy
  nor export. The window used the shared table from the start and had never
  switched its menu on. It now opens on « Copier la cellule » and « Copier les
  lignes sélectionnées », then the ten exports; the TOTAL line is copied and
  exported with the others, and the balances are exported as numbers. Six
  other tables are still without a menu, by decision: the attachments manager,
  the database selector, and the previews of the CSV and Excel imports.
- **A column given back its born width could vanish.** After a width had been
  pulled, every visible column was frozen in pixels; a column then returned to
  its share by a double-click on its handle received what was left — nothing,
  as soon as the table overflowed. It now keeps its minimum width. And a
  handle merely clicked, not pulled, no longer freezes the widths.
- **A database that will not open says why in the language of the
  interface.** Opening a database saved by a more recent Radinus showed "This
  Radinus database uses schema version 11, which is newer than…" — the English
  text written in the code — whatever language was chosen. Only the refused
  password had a sentence of its own. A database that is too recent, a file
  that is not a Radinus database and a read error now have theirs, in the 18
  languages; the read error keeps the technical detail after it. This holds
  from this version on: an older Radinus still answers in English, since it is
  the one that speaks.
- **Debits are red again in the operations list.** The style rule aimed at
  "the eleventh cell" of a row. Adding the « Statut opération » column moved
  the debit to the twelfth, and debits turned black without anything saying
  so. The cell now names itself, and a check holds it.
- **The three operation statuses are now translated.** They were read from
  the `StatutOperation` table, whose labels were written in French when the
  database was created, so every language showed « Pointé », « Engagé »,
  « Prévu ». Radinus still identifies a status by its key (1, 2, 3) and now
  takes the word from the translations, in all 18 languages — in the
  operation fiche, the new column, the transfer window, the templates, the
  reconciliation fiche and the quick classification. The database is not
  touched.

## [2.1.0] — 25/08/2026

### Added

- **« Bilan croisé » (F39), a new window in the Statistics menu.** The six
  statistics cross one nomenclature with time — twelve columns, one per month.
  This one crosses **two nomenclatures with each other** and fixes the time:
  categories down the side, assignments across the top, one month at a time.
  "Who spent what, this month" — the family's groceries, Monsieur's petrol,
  the animals' vet, in a single table.

  Everything else is the template of the six, because that is what was asked
  for: the same five switches, the same four cell colours, clicking any cell
  to see the operations behind it in the panel below, the drop-down menus that
  reclassify an operation without opening its fiche, the double-click that
  opens that fiche, the right-click that exports the view. Its own rules:
  - the last row is **Sans catégorie** and the last column **Sans
    affectation**; every category and every assignment is shown, even the ones
    this month leaves empty — one navigates from month to month, and columns
    that changed places would be impossible to compare;
  - **there is no Cumul row.** A running total adds the months in order — May's
    is January to May. Assignments have no order, and the table holds a single
    month: there would be nothing to accumulate. The Somme row stays, and it
    sits at the foot of the frame;
  - the blue panel reads **09/2026** on one line. The two clocks step a month
    at a time and December rolls over to January of the next year; clicking the
    month asks for a number between 1 and 12, clicking the year asks for a year
    as the six statistics already do;
  - the Export menu offers **every month of the shown year**, twelve tabs named
    `MOIS_01` to `MOIS_12`, each one literally what the window would show on
    that month;
  - the table carries a floor width, so many assignments overflow into a
    horizontal scrollbar rather than squeezing the columns unreadable.

  Keyboard shortcut ⌘⇧7, after the six statistics. Like them, it asks which
  accounts it covers before it opens.

- **"Create a recurring operation from this operation", in the Divers menu of
  the operations list.** Behind a separator, at the foot of the menu: the two
  entries above it only fold and unfold the list, this one opens a fiche. F15
  opens in creation, prefilled with what the operation can give — its label,
  its amount, its direction, its account and its five classifications. The
  rhythm is nowhere in an operation, so the next date, the frequency and the
  ending condition stay those of a fresh fiche and the user finishes it
  himself. **Nothing is written until he saves the rule** — the rule of
  "Duplicate", decided on 26/07/2026. One operation must be selected; a
  sub-operation stands for the operation it ventilates, since a ventilation
  does not repeat on its own.
### Fixed

- **Writing an operation now announces itself.** Reported by Fabrice on
  25/08/2026: an operations list left open stayed frozen after importing an
  OFX statement — it had to be closed and reopened. The cause was not in the
  import. Announcing was the job of *the window that asked for the write*, and
  every window had to remember: the operation fiche remembered, the bulk
  statement integration did not, and neither did five other paths.

  Announcing is now the controller's job, at the place where the write
  happens. Eleven commands do it: statement integration, creating, updating
  and deleting operations, pointing, sub-operations, quick classification,
  reclassifying from the statistics, the FITID, and deleting all of an
  account's operations. The windows no longer announce anything — the three
  calls they made are gone, and so is the command that served them. **Two
  windows are told, not one**: writing an operation moves the balances, so the
  accounts list was as stale as the operations list.

  A crossing test keeps the rule: it reads the controller, finds every command
  that makes the core write an operation, and requires it to announce the
  change in the same breath. The command written six months from now will be
  caught there rather than at the user's desk.

- **The reconciliation fiche starts from zero every time it is opened.**
  Reported by Fabrice on 30/08/2026: open F18 on one statement line, go back to
  the list, open it on another — and part of the fiche still carries the first
  line's answers, the five classification menus and the status among them. F18
  is built once and never destroyed, so reopening it only replayed `load()`,
  which reposes what the *line* carries — date, label, direction, amount,
  clearing date. The classification comes from no line at all: it is a set of
  defaults, and defaults were written inside the construction block, which
  never runs twice.

  It matters more than the confusion it causes. A wrong label is visible in the
  list; **a category inherited from the previous line is visible nowhere** — it
  surfaces six months later as a wrong statistic. And an inherited status wrote
  an operation that is not pointed while the clearing date is written
  regardless, which is precisely the pair the rest of this release forbids.

  The defaults now live in a function of their own, called on opening and on
  every reopening — **including a reopening on the same line**: a fiche one
  did not validate produced nothing, so there is nothing to find again. "From
  zero" means *the line as the statement holds it today*: a correction
  confirmed with Validate belongs to the statement, not to the fiche, and comes
  back rightly. Three checks keep it, and the nomenclature list kept in the
  window is replaced when a nomenclature changes, so a label added during the
  session is there at the next opening.

- **The « Pointer » button no longer destroys real bank dates.** It rewrote
  `DatePointage = Date` over the whole selection, already-pointed rows
  included: an operation dated 28/07 that the bank passed on 02/08 lost its
  02/08 the moment the month was re-pointed as a precaution — and re-pointing
  as a precaution is exactly what one does. Two rules now: an operation that
  is already pointed is left alone and does not even enter the count, and for
  the others the operation's own date is written **only where the field is
  empty**. When the whole selection is already pointed, the button says so
  rather than reporting "0 operations pointed".

- **A refusal that could not be seen is now a panel.** "Une opération pointée
  doit obligatoirement porter une date de pointage" was displayed at the foot
  of the window, where it went unnoticed (Fabrice, 25/08/2026). It is now in
  the application's own Yes/No panel, and a second line offers the only
  sensible way out: save with the operation's date, shown in full. Yes saves,
  No leaves the fiche exactly as it was. Both the operation fiche and the
  transfer window. Multi-line questions now break where their author broke
  them, which also repairs the four-line questions of the statement import.

- **An operation fiche opened on a pointed operation with no clearing date
  offers one.** The rule above made those inherited rows — a WinDev database, a
  restored archive — impossible to save at all: the user opened the fiche to
  fix a label and hit a refusal about a field he had never needed. The fiche
  now shows the operation's own date, visible and editable, and **it is written
  only if he saves** — which he was doing anyway. Read-only fiches and
  sub-operations propose nothing: they show what the database holds.

- **An operation template now writes what the hand would write.** Setting a
  field's value fires no event, so the rule linking the clearing date to the
  status never played: a template carrying "planned" left the day's date in the
  field and created a non-pointed operation carrying a clearing date — while
  the same status chosen by hand emptied the field before the user's eyes. Two
  paths, two records; the template now plays the rule.

### Changed

- **A clearing date carried by an operation that is not pointed is shown in
  grey and in italic**, and the grey darkens on a selected row. The first grey
  was `#9aa8b2` against a selection background of `#9eafba`: a contrast ratio
  of 1.08, which is to say invisible — and a row is selected precisely when one
  is about to click « Pointer ». The italic carries the meaning wherever the
  background changes; it is the language the accounts list already speaks for a
  closed account.

- **A row that is not pointed shows no balance at all.** The column is the
  *bank* balance: it only advances on pointed operations, but it was copied
  onto every row at whatever value the walk held when it met them. That walk
  follows the clearing date, and an empty one sorts first — so since future
  instalments stopped carrying one, they were met first and received the
  account's opening carry-over, often 0,00 €. A user reading down his list saw
  his progression, then a column of zeroes over the whole future, and could
  read it as "my account will be empty". The empty cell says the only true
  thing: the bank has passed nothing, so there is no bank balance to show. It
  is already the language of sub-operations, one row above. Nothing changed in
  the arithmetic — the account's balances, the six totals at the foot of the
  window and the curve are what they were.

## [2.0.5] — 21/08/2026

### Changed

- **A clearing date now belongs to pointed operations only.** Users reported
  seeing one on operations that were not pointed at all — most visibly on
  future instalments, planned for November and already stamped as if the bank
  had passed them. Six rules, decided one by one:
  - nothing writes a clearing date on an operation that is not pointed. The
    recurring generator, which dated every instalment it produced, now dates
    only those that fall in the past and are therefore born pointed;
  - in a fiche, the field follows the status: emptied on the way to planned or
    committed, filled with the operation's own date on the way back to pointed
    — so hesitating between two statuses costs nothing. The user may always
    type whatever he wants over it;
  - a pointed operation must carry its date: the operation fiche and the
    transfer window refuse to save without one;
  - where the software points in bulk — the list's Point button, quick
    classification — it stamps the operation's own date, since no one is there
    to be asked. An existing date is never overwritten: it is truer than the
    one we would put. Statement import is untouched, it knows the real date
    from the bank's file;
  - **nothing is ever erased or rewritten in an existing database.** The dates
    inherited from earlier versions stay where they are and will go, fiche by
    fiche, as their status is touched;
  - in the operations list, a clearing date carried by an operation that is not
    pointed is shown in light grey. It stays sortable, filterable and exported
    — hiding it would be lying by omission, and the column would then sort on
    something invisible.
- **A horizontal scrollbar under the operations list.** Sixteen columns did not
  fit a narrowed window: they squeezed until unreadable and the last ones were
  out of reach. The table now holds a floor width — the sum of the minimum each
  column declares — below which it overflows rather than shrinks, and scrolls
  under its own last row. The header and the filter row follow it; the six
  totals at the foot of the window do not move. The other fourteen lists are
  untouched: the setting is off unless a window asks for it.

## [2.0.4] — 11/08/2026

### Fixed

- **Attachments come out of the archive when a database is born from a
  backup.** Creating a database with "initialise from a backup" restored the
  tables and stopped there: the attachments window listed every document, the
  folder held none of them, and everything read "file missing". The very same
  extraction had always run in Tools › Restore — it was simply missing here.
  Reported by a user on 10/08/2026.
- **A new nomenclature shows up without restarting.** "When you add a
  nomenclature you have to close the program before the new label appears in
  the operations" — a window of Radinus is built once and never destroyed, so
  it read its lists at construction and kept them for the session. Saving a
  nomenclature now broadcasts a second event to every window; the six fiches
  put their lists back **keeping the current selection** — a fiche someone is
  filling in must not be wiped — and the three tables read themselves again,
  since their rows carry the word and not the key.

### Changed

- **The Excel import backs up for real.** Answering "yes" to "would you like
  to back up your data before starting?" used to display a message written
  when backup was not yet wired up, and left the user with nothing. It now
  opens the file selector, writes the archive, verifies it, says where it is
  — and the import waits until it is done, because a net offered before the
  jump has to be there before the jump.

## [2.0.3] — 10/08/2026

### Fixed

- **A 1.9.3 archive whose fields are `null` restores again.** Two users lost
  a whole restore on `invalid type: null, expected i64`: a column added to
  their database long after it was created had been left `null` on every row
  written before that day, and serde stops at the first field it cannot read
  — one field of one row sank nineteen tables. Every field of every table now
  reads through `backup::records::lenient`: a `null` gives the neutral value,
  and so does a field the archive does not carry at all, which is the same
  problem seen from an older archive still. Nothing is swallowed silently:
  the substitutions are counted and the restore reports the total, in the
  window and in the journal. The writer is untouched — archives Radinus
  produces stay readable by 1.9.3.

## [2.0.2] — unreleased

The cross-platform rewrite of Radinus 1.9.3 (Windows/WinDev) in Rust and
Tauri, macOS first. Same author, same data, same windows — a different
machine underneath.

### Added

- **Installed by default, portable on demand.** Radinus installs normally and
  keeps its data in the operating system's standard folder —
  `%APPDATA%\Radinus\` on Windows, `~/Library/Application Support/Radinus/`
  on macOS, `~/.local/share/radinus/` on Linux. It becomes portable when it
  finds `settings/start_mode.toml` beside its executable carrying
  `portable_mode = 1`: everything then lives next to the application and the
  whole thing runs from a USB drive. One build per system, not two. Either
  way the data root holds the same four folders — `settings/`,
  `databases/Radinus_NNNNN/`, `backups/`, `logs/` — and nothing is written
  outside it.
- **Several databases, chosen by the user.** Radinus opens none of them on
  its own: the selector appears at every launch and lists what `databases/`
  really holds. A folder holding a `radinus.sqlite` is a database whatever
  its name, so folders may be renamed, copied and deleted outside the
  software.
- **Eighteen languages** — French, English, Spanish, Portuguese, Italian,
  German, Dutch, Swedish, Norwegian, Finnish, Icelandic, Romanian, Polish,
  Russian, Ukrainian, Greek, Hebrew, Arabic — switched from the Paramètres
  menu and applied immediately, without restarting. Every sentence the
  software says lives in a Fluent resource; no window holds a sentence of its
  own, and none composes one. The language a database runs in is stored as a
  number, and it is WinDev's own "nation" number wherever WinDev has one — 5
  for French, 3 for English, 7 for Spanish — so an archive stays readable
  both ways. Ukrainian has none in that table and takes the first Radinus
  number, 100; below 100 the numbers stay WinDev's, and a test refuses any
  language sitting between the two worlds.
  Sentences naming a keyboard key adapt to the machine — `⌘` on a Mac,
  `CTRL` or `STRG` elsewhere.
- **A password per database, and real encryption.** A database can be given
  its own password, on the user's order and never by default. It is not a
  lock on the software but on the file: SQLCipher encrypts the pages in
  AES-256, and without the key there is nothing to read, not even the names
  of the tables. 1.9.3 stored a SHA3 hash and left the data legible to anyone
  opening the file another way. A database without a password opens exactly
  as before, byte for byte.
- **Leaving a database without leaving Radinus.** « Se déconnecter de la base
  en cours » closes every window, forgets everything read, and brings back
  the selector. Nothing of the previous database survives in a window that
  reopens on another.
- **Radinus 1.9.3 backup restore.** The zip archive of the Windows version is
  read whole, tables and all, so an existing user keeps his history.
- **OFX bank statement import**, plus CSV and Excel imports with a
  configurable field mapping.
- Accounts, operations with sub-operations and the "Complément" mechanism,
  checks and checkbooks, recurring operations, budgets, six cross-tabulated
  statistics, a dashboard, a balance evolution chart, attachments, printing
  through a PDF the application composes itself.

### Changed

- **The licence is now the GNU GPL v3 or later**, where it was MIT. Whoever
  distributes a modified Radinus must distribute its source under the same
  terms; the users gain nothing they did not already have, and nobody can
  take it from the next one. Anything published under MIT before 08/08/2026
  keeps those terms. All 687 dependencies were audited first — the one that
  decided it is OpenSSL, embedded for SQLCipher, Apache-2.0 since its version
  3.0 and therefore compatible.
- The application no longer creates a database silently at first launch. It
  asks for the language, then for the database, and creates one only when
  told to.

[2.0.2]: https://github.com/
