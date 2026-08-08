# Decisions

Every entry below is a ruling by the author, Fabrice Garcia, with the date it
was given and the reason it holds. They are recorded because a decision whose
reason is lost becomes a rule nobody dares change and nobody can defend — and
because several of them were reached the hard way, after a fault.

Newest last, so the list reads as the project grew. Where a decision revised
an earlier one, both are kept: the revision is the interesting part.

---

## Architecture

### A-1 · Three layers, dependencies one way only
*24/07/2026*

View → Controller → Model, and nothing flows back. `radinus-core` knows
nothing of Tauri, of a window or of the disk layout, and compiles and is
tested on its own.

**Why.** 26 500 lines of business rules must be provable without launching an
application, and a second face — a command line, a server — must not mean a
rewrite.

### A-2 · The controller decides nothing
*24/07/2026*

A command takes a JSON call, calls one core function, and forwards the result.
No `if` in `commands.rs` decides anything about money, dates or accounts.

**Why.** In a classic MVC the controller decides; a rule that lives there is a
rule with no test and no second caller. The signal is easy to spot: an `if`
about a business fact in `commands.rs` is a rule in the wrong layer.

### A-3 · Code in English, work in French
*24/07/2026*

Identifiers, comments and commit messages in English. The working language
between the author and whoever writes the code is French.

### A-4 · No dependency without explicit permission
*24/07/2026*

Rust crate or JavaScript library alike. Each one already in place was asked
for and granted, and the reason is written beside it in `Cargo.toml`.

**Why.** Radinus handles money, and every library added is code nobody here
has read. See `About_dependencies.md`.

### A-5 · SQL names are sacred
*24/07/2026*

Table and column names keep the original French names of Radinus 1.9.3,
verbatim: `Operation`, `IDCompte`, `Maj_SoldeBanque`. Not translated, not
tidied, not pluralised.

**Why.** Thousands of users hold their history in 1.9.3 backups. A backup
restored into a renamed schema is a backup lost.

### A-6 · Amounts are `i64` micro-units
*24/07/2026*

The value times 1 000 000. No floating point ever touches money.

**Why.** A float does not hold exactly 0.10 €. A finance application cannot
afford the rounding that follows.

### A-7 · Keys are `max(id) + 1`, never SQL auto-increment
*24/07/2026*

Reproducing the original's `Genere_Clef()`, in `database/keygen.rs`.

**Why.** A restored 1.9.3 backup carries its own ids. An auto-increment
column would fight them.

---

## Windows and the interface

### W-1 · Real system windows, not one window with a router
*25/07/2026*

Each window of the original is a real system window with its own HTML page.

**Why.** That is what the original does, and it is what makes the windows
independent, movable and individually closable.

### W-2 · A window is built once and never destroyed
*25/07/2026*

Leaving a window hides it; asking for it again shows it. It is never
destroyed and never rebuilt.

**Why, and it was paid for twice.** Rebuilding a window under a label that was
still being torn down crashed the application outright. Even once that was
slowed down, a list asked for again a moment after closing came back as an
empty grey panel — a window already dead but not yet forgotten, faithfully
"reused". Hiding removes the race instead of racing better.

**Consequence.** A window that comes back does not reload its page. New
parameters reach it through a `window-parameters:<label>` event, and the label
is in the event name because a JavaScript `listen()` hears every `emit_to`.

### W-3 · The system close button is disabled everywhere
*25/07/2026*

A Radinus window is left through its door, as in the original.

**Why.** One exit to guard instead of two: no unsaved work slips out the side.

### W-4 · A form is the child of its list
*25/07/2026*

It stays above it and goes away with it. The relation is one-way: closing the
form leaves the list open, so records can be worked through one after another.

### W-5 · No window holds a sentence of its own
*25/07/2026*

Every word shown comes from `radinus-core/i18n/*.ftl`. A window asks for its
whole vocabulary in one call, before it draws anything.

**Why.** Two consequences make it worth the discipline: a window cannot flash
the wrong language, and an unknown key comes back **as the key itself** —
visibly wrong on screen rather than silently empty.

### W-6 · The dictionary carries whole sentences only
*26/07/2026, after the fault was made twice*

A sentence with a hole in it — "34 lines classified" — is never assembled by a
window. The core resolves it and hands it over finished.

**Why.** Only Fluent knows whether the number changes the sentence, and a
French sentence needs a gender where an English one does not. A window that
composes ends up knowing about both languages.

### W-7 · Declared state, never asked for
*25/07/2026*

Whether a form holds unsaved work is declared to `AppState` as it changes, not
asked for when needed.

**Why.** Asking the form through an event was a round trip that sometimes
arrived before the form was listening — the question was then simply not
asked. Reported as *"sometimes the modifications are detected, sometimes
not"*. A declared state cannot arrive late.

### W-8 · A window created invisible comes up blank
*02/08/2026*

Windows that must not show at startup are built **visible and hidden
immediately after**, never declared invisible in `tauri.conf.json`.

**Why.** A webview that has never been on screen has never been painted. The
home window came back with no image, no banner and no slogan — frame and
title, nothing inside.

---

## Testing

### T-1 · The best tests cross the data
*26/07/2026, after 519 checks let two faults through*

> The best tests are the ones that cross the data, or the ones at the two ends
> of the problem — input/output, caller/callee, sender/receiver. The truth
> often appears where the logics meet.

The 519 existing checks were numerous but all entered the application at the
same place: they loaded a page with the address the tests themselves had
decided it would get, so they verified the page and never the wiring around
it. Both faults were in that wiring.

`src-tauri/src/crossings.rs` came out of this ruling. Each crossing holds the
two ends of a seam nothing else links, reads the files on both sides —
including the ones that are not Rust — and carries in its comment the fault
that caused it.

### T-2 · The interface is tested in a real browser engine
*25/07/2026*

`ui/tests/windows.test.mjs` opens every page with the Tauri bridge replaced by
a stub, clicks its buttons and checks what appears.

**Why.** A whole delivery went out with windows that looked perfect and did
nothing: the Rust was tested, the interface was not tested at all.

### T-3 · The author's real data is never committed
*24/07/2026*

`radinus-core/tests/fixtures/` holds his own accounts and operations. It is in
`.gitignore`, and the tests that read it print a notice and pass when it is
absent — so the repository can be made public without the data going with it.

---

## Languages

### L-1 · The language switch takes effect at once
*01/08/2026*

No restart. Rust warns every open window with a `language-changed` event, and
each one re-dresses itself by calling the same `dress()` that dressed it when
it opened.

**Why the same function.** A label added tomorrow will follow the language
without anyone thinking about it.

### L-2 · The database stores the WinDev nation number
*01/08/2026 — revises `02_BASE_DE_DONNEES.md` §3.11*

`Parametres.UtiliseLangue` holds 5 for French, 3 for English, 7 for Spanish —
not `fr`, `en`, `es`.

**Why.** A 1.9.3 backup carries that number. Giving it back unchanged is the
only way a round trip loses nothing.

**What it cost to get right.** The first version wrote the number into a
column still declared `TEXT`, and SQLite's TEXT affinity turned 7 into `'7'`.
The write worked, the read asked for an integer, failed silently, and fell
back to French — *"impossible to change language: it stays in French"*. The
migration now rebuilds the table and runs unconditionally, because the faulty
version had already marked those databases as up to date.

### L-3 · An unknown language number is kept, and displays in French
*01/08/2026*

A backup carrying German (1) keeps its 1 in the database; the interface speaks
French until Radinus learns German.

**Why.** Better a readable window than an empty one — and better a preserved
number than a lost one.

### L-4 · Spanish, and the shape that lets a fourth follow
*01/08/2026*

Adding a language is **one line** in the `KNOWN` table of `i18n.rs` and one
`.ftl` file beside the others. Nothing else in the whole application: the
menu, the selector and the first-launch list all read `Language::all()`, and
each language's name is read from its own file under the key `language-name`
— which is the only place "Español" can be spelled correctly.

---

## Databases and startup

### D-1 · Radinus opens no database on its own
*02/08/2026*

The language is asked once in the software's lifetime, then the database
selector appears **at every launch**. Nothing is created without permission.

**Why.** The original never asked because it had one database. Radinus 2 has
as many as the user wants, and creating a folder behind his back — or worse,
after he deleted everything to start again — is not what he expects.

### D-2 · A database is any folder holding a `radinus.sqlite`
*02/08/2026*

Whatever the folder is called. Renaming `Radinus_00001` to `MesComptes`
outside the software changes nothing; numbering, for its part, only counts
folders named `Radinus_NNNNN`, and the next one follows the highest of those.

> "Il faut un système de pensée tolérant."

The user has the right to rename, copy and delete his folders outside the
application. What is on the disk is the truth; the remembered list never is.

### D-3 · `radinus_base.json` is indicative, and regenerated when missing
*02/08/2026*

It carries the label, the comment, and where the database came from. **Nothing
functional depends on it.** Missing or unreadable, Radinus rebuilds a standard
one with the folder name as label and everything else empty.

**A consequence the author drew himself:** the GUID proposed to recognise a
moved folder was dropped. A file that gets regenerated would make a new one,
and the "moved" database would become an unknown one. A file that is
indicative cannot also be an identity.

### D-4 · The label and comment are entered at creation only
*02/08/2026*

They say where a database came from, and the origin of a thing does not
change.

### D-5 · Adding is one gesture, not a mode
*02/08/2026*

The name and comment fields are always on screen under the table. One click on
the add icon creates the database, and it appears in the table above. The add
icon never turns into a save icon.

**Why.** The first version hid the table to show a form and swapped the
button's face: two gestures and two faces for one intention.

**And:** creating is not opening. A new database is added to the table and
nothing more.

### D-6 · The name must not be empty or blank
*02/08/2026*

The add button stays dark until something is typed, and Rust refuses as well —
a barrier that exists only in the window is not a barrier.

### D-7 · Deleting sends the folder to the system trash
*02/08/2026*

The whole folder — SQLite, attachments, information file. The confirmation
asks for the translated word (OUI, YES, SÍ), as everywhere else in Radinus.

**Why the trash rather than erasing.** The original uses `frVersCorbeille`
everywhere it erases; a database deleted by mistake is put back with one
click.

**The open database is refused**: Radinus is holding its file.

### D-8 · The selector has two modes
*02/08/2026*

Opened at startup, it opens a database — that is what it is for. Opened from
the menu while Radinus is already running, it no longer can: the open button
is greyed and a double-click says to quit and start again. Reading, creating
and deleting stay whole, because **creating a database is not using it**.

**Why.** A Radinus window is built once and never destroyed (W-2), so nothing
could make the open windows forget the database they are showing. Rebinding
underneath them would write one database's operations into another, silently.

### D-9 · `app.restart()` is not used anywhere
*02/08/2026*

**Why.** The relaunched process painted blank windows — frame and title,
nothing inside — and then, once that was worked around, died without a single
line in the terminal. Nothing in the code kills the process on purpose any
more.

---

## Ports from the original

### P-1 · The original is the specification
*24/07/2026*

Where the code and Radinus 1.9.3 disagree, the original wins, unless the
author rules otherwise. Many modules name the WinDev procedure they were
ported from.

### P-2 · The "Complément" is recognised by a marker, never by its label
*25/07/2026*

`Operation.EstComplement`, a column of its own.

**Why.** The original recognised it by its label, which cannot survive three
languages.

### P-3 · A missing field never refuses a restore
*25/07/2026*

`Date` and `DatePointage` are nullable for that reason: an old backup may not
carry them, and a restore must never be refused over an absent field.

### P-4 · The three balances are recomputed, never patched
*25/07/2026*

`Maj_SoldeBanque`, `Maj_SoldeReel`, `Maj_SoldeFinal` are ports of the
original's procedures and run whole after anything that moves money.

### P-5 · Radinus builds its own PDF
*31/07/2026, dependency granted 01/08/2026*

Typesetting with Typst rather than asking the system's webview to print.

**Why.** The three webviews do not paginate alike, and would give three
different documents for one statement. Radinus composes it itself, and the
same document comes out everywhere.

### P-6 · The journal holds the last technical operation, and that one only
*01/08/2026*

Like the original, whose `gtabMonLog` is emptied at the start of each of its
three procedures. It is not an archive; it is the report of what has just
happened, and it does not survive the application closing.

### P-7 · The "pengagés" typo is corrected
*02/08/2026*

The account statistics reproduce the original's fourteen lines word for word,
with its typo fixed — as "Bank Identifer Code" was on the account form.

### P-8 · The welcome window answers before it is asked
*03/08/2026*

F01 stops being a banner alone and carries the totals, the accounts and the two
budget-line rings. It is the first feature Radinus 2.0.0 has that 1.9.3 does
not, and the divergence is deliberate.

**Why.** The rule that governs it is what keeps it from becoming a second
dashboard: *the welcome window is the no-click view, and anything that needs a
setting does not belong on it*. F07 is a table one opens on purpose; F19 asks
for accounts, a period and three switches. The welcome window asks nothing —
open accounts, current month, every status — so the same figures are a shortcut
and not a repetition. The corollary is the useful half: no year picker, no
period menu and no drill-down will ever be added here. The day one of them is
missed is the day F19 should have been opened instead.

Its numbers come from `accounts::list` and `dashboard::dashboard`, called with
fixed parameters. Nothing is computed a second time, so nothing can drift: a
figure on the welcome window that disagreed with F07 would be worse than no
figure at all.

### P-8 bis · The welcome window is leafed through, month by month
*03/08/2026, revising P-8 the same day*

P-8 said the welcome window takes no setting at all — "no year picker, no
period menu, no drill-down". Hours later Fabrice asked for a `‹` and a `›` on
each ring. The rule is **rewritten, not quietly broken**: *the welcome window
answers before it is asked, and is leafed through month by month; nothing more
— no account picking, no status switches, no drill-down. Anything needing more
than an arrow belongs to F19.*

**Why write it down rather than just add the buttons.** A rule one breaks in
silence stops protecting anything, and the next person to want "just one more
control here" would find no argument in their way. The revised wording still
draws the line, one notch further out.

Two consequences worth keeping. The two rings **share one month**, whichever
arrow is clicked: spending for July beside income for August would show a
balance that is false to the eye, and no number on screen would say so. And
the three big balances and the account tiles **do not move with the arrows** —
a balance is cumulative since the account was opened and belongs to no month.

### P-9 · The welcome rings are drawn in relief, F19's stay flat
*03/08/2026*

The same drawing code serves both, relief being an option of it.

**Why.** Fabrice asked for 3D and was told first what it costs: a tilted ring
overstates the sectors that pass in front, so two slices of equal value do not
look equal. He ruled for the relief with the amount written on every sector —
the perspective carries the look, the number carries the truth. F19 keeps the
flat rendering he validated on 26/07/2026, and the two are one function rather
than two, so a fix to the geometry reaches both.

### P-10 · The Preferences table holds what the author asked for, and nothing else
*03/08/2026*

`Preferences` has been in the schema since 1.x with nothing reading it. It now
holds one key, `devise`. Fabrice's ruling, in his words: nothing goes in that
he has not asked to be put there.

**Why it matters more than it looks.** A free-form key/JSON store is the one
place where a program quietly accumulates — a column width here, a last-used
folder there — until nobody knows what is in it or who wrote it. The rule is
what keeps it readable in five years. It also means no schema change:
`VerDataBase` stays at 10 and no database is migrated.

### P-11 · The currency is a display, and the symbol's place follows the language
*03/08/2026*

Amounts carried a `€` written into the Rust source. The symbol now comes from
a preference — system currency, euro, dollar, CFA franc, or one typed by hand
— and **where it sits relative to the number comes from the language file**,
beside the thousands and decimal separators that already live there.

**Why the split.** Currency and language are not the same axis: an English
speaker may be American, British or Canadian, so no `€` or `$` may ever be
written into a `.ftl`. But *placement* genuinely is a language matter — French
and Spanish write `1 549,81 €`, English writes `€1,549.81` — and the language
files already own the number's punctuation, so they own this too.

**What was argued and lost.** It was put to Fabrice that reading the system's
currency on every launch labels the money of the *machine*, not the money in
the *base*: a French user whose Mac is set to Canada would see euros marked
`$`, with every figure right and the label lying. He ruled that it is display
only and that the case is his users' business, not his. Recorded here because
the argument should not have to be made twice — and because if it ever bites,
this is where the reason it was accepted is written down.


### P-12 · The language leaves the Paramètres menu
*03/08/2026, revising the same day's ruling*

When F39 was specified, Fabrice asked that « Choix de la langue » stay in the
menu *and* appear in the preferences tree — two roads to one setting. Seeing it
built, he ruled the other way: the menu entry is redundant and goes.

**What went with it**, and it is the point of writing this down: the whole
`CheckMenuItem` submenu, the `settings-language:` id prefix, and the branch of
`on_event` that decoded it. All three existed only to serve that entry. The
window now calls the `set_language` command, which goes through the same
`switch_language` the menu used — so there is **one function, reached by one
road**, instead of one function reached by two.

`menu-settings-language` was removed from the three language files at the same
time. A key nobody asks for is not free: it is a promise that something still
shows it.

### P-13 · The display is zoomed, not the font
*03/08/2026*

Fabrice asked for a slider to enlarge or shrink the characters, "for people who
see badly or have a small screen". Radinus zooms the **webview** — the browser's
own `⌘+` — rather than scaling its base font size.

**Why, and it was measured rather than argued.** The stylesheets carry **415
lengths in pixels against 15 in em**, and eight of the seventeen font sizes are
themselves in pixels. Scaling the root font would have moved almost nothing, and
making it work would have meant rewriting 415 measurements across every window
already validated. The webview's zoom grows everything together — text, icons,
column widths, the rings — without touching one line of CSS.

**The part that had to be found rather than assumed:** zoom belongs to each
webview, not to the application. A window opened *after* the setting would have
ignored it. It is therefore reapplied at every window creation, and when a
hidden window is shown again.

Two things it deliberately does not reach: the system's menu bar and dialogs,
which follow the computer's own accessibility settings; and the printed
statements, which Typst composes outside the webview — a PDF keeps its layout
whatever the screen is doing.

### P-14 · A window that is shown again is renamed again
*03/08/2026, after a fault Fabrice found*

Clicking a second account on the welcome window opened its operations under the
**first** account's name. The rows were right; the title lied.

**Why it happened.** A Radinus window is built once and never destroyed, so
opening it a second time takes the reuse branch: it emits the new parameters and
shows the window. It did not rename it — although the caller had just built
`spec.title` with the right account in it. The name therefore stayed whatever it
was the very first time that window was ever opened, for the rest of the
session.

**Why it is worth an entry.** This is the same family as the statistics fault of
26/07: right figures, wrong subject, and nothing on screen to say so. There the
window ignored the parameters it was sent; here it heeded them and kept the old
label. Both are silent, and both are only visible to someone who happens to read
the title bar.

The fix is one line in `windows::open`, not one per window: F02, F05 and F17 all
carry an account name in their title and were all wrong in the same way.

`retitleWith` in `ui/windows/texts.ts` was removed at the same time. Its own
documentation described this exact case — "the operations list changes account
without reopening" — and **nothing ever called it**. A function that claims to
handle a bug it does not handle is worse than no function: the next reader
believes the case is covered.

### P-15 · The dedicated "import a 1.x backup" entry goes; the capability stays
*03/08/2026*

The dossier calls restoring a Radinus 1.9.3 archive an **absolute, non-negotiable
requirement** — thousands of Windows users migrate through it — and prescribed
"a dedicated menu entry". Fabrice removed that entry: it duplicated Restauration
and had never been wired to anything.

**He is right, and it was checked before removing it.** Fichier › Base de
données › Restauration calls `backup::read_archive` then `restore_into` — the
very pair that `tests/real_backup.rs` runs against his own 1.9.3 archive, and
that reads its 2 502 operations, 80 cheques and 175 comments. **The migration
path is intact**; only a second door to it is gone.

**What this exposes, and it is the part worth keeping.** `PLAN_ACTION.md` §17
carries `[X] Option de menu DÉDIÉE « Importer une sauvegarde Radinus 1.x… »`.
That box was ticked while the entry was built with `inert` — visible, greyed
out, wired to nothing. A ticked box on a plan is a claim, and this one was
false for days without anyone noticing, on the requirement the dossier shouts
about most. The line is corrected rather than deleted.

`fn inert` went with it: this was its last caller, and a menu with no dead
entries has no need of a helper for building them.

### P-16 · The main window's close button does not do the same thing everywhere
*03/08/2026*

On macOS it hides the welcome window, which "Paramètres › Afficher la fenêtre
principale" then brings back. On Windows and Linux it quits Radinus.

**Why it cannot be one behaviour.** The menu bar belongs to the *application* on
macOS and to the *window* on the other two. Hiding the only visible window under
Windows would leave Radinus running with nothing on screen, no menu, and no way
to open one — and since every other Radinus window is hidden rather than
destroyed, it would not exit by itself either. The Task Manager would have been
the only way out. Quitting is also what Radinus 1.9.3 does when its main window
is closed, and what a Windows user expects.

**How it was found.** The first version hid the window on all three systems.
Fabrice asked "ça ne risque pas de poser un problème sous Windows ?" before
anything was built for Windows. The trap was never sprung; the question alone
was enough.

---

## P-17 — Portuguese is nation 14, not 15 (03/08/2026)

**Decided.** Portuguese ships as a fourth language under the WinDev nation
number **14** (`nationPortugais`), European Portuguese, not 15
(`nationPortugaisBrésilien`).

**Why.** The number is not a label: it is what a 1.9.3 backup carries in
`Parametres.UtiliseLangue`, and it is what Radinus writes back. Choosing 15
would make every Portuguese base look Brazilian to a Windows install, and the
round trip through an archive would silently change the language of somebody
else's data. The two nations are separate rows in
`Analyse/Langues/Code langue.xlsx`; they are separate here too, and 15 falls
back to French until somebody translates it.

The wording follows: `ecrã`, `ficheiro`, `eliminar`, `reciclagem`. A Brazilian
reading them will understand; a Portuguese reader given Brazilian wording would
have been told, wrongly, that Radinus thinks he lives elsewhere.

**What it cost.** One `.ftl` file and one row in `KNOWN`. Nothing else in the
core, nothing at all in the view — the menu and the preferences window both read
the list from `available_languages`, so they gained the language without being
opened. That is the whole point of the table, and this is the first time it was
proved on a language nobody had planned for.

---

## P-18 — Italian, and the price of a language (03/08/2026)

**Decided.** Italian ships as a fifth language under WinDev nation number
**11** (`nationItalien`), the same day Portuguese shipped.

**Why it is recorded.** Not for the language — for the price. When the language
table was built, the claim was that one more language costs one `.ftl` file and
one row in `KNOWN`, and nothing else anywhere. Portuguese was the first test of
that claim and Italian was the second, on the same day. Both times the count
was exact: two files touched in the core, one line added to the migration that
turns an old text tag into a number, and **not one line in the view**. The menu
and the preferences window both read `available_languages`, so they gained
Italian without being opened.

A design is only proved by the thing it claimed to make cheap. This is the
entry that says it was.

**One trap, and it is not new.** The confirmation word for deletions is
`ui-yes` in capitals. In Italian that is **`SÌ`**, with the grave accent —
typing `SI` will not delete anything. Spanish has had the same edge since
01/08/2026 with `SÍ`. It is left as it is: the word must be the *yes* of the
language being read, and softening it to `SI` would be inventing a second
spelling that Italian does not have.

---

## P-19 — German is nation 1, and nation 1 was the fallback example (03/08/2026)

**Decided.** German ships as a sixth language under WinDev nation number **1**
(`nationAllemand`). The fallback example moves to **Danish (6)** for numbers and
to **`nl`** for tags.

**Why this one needed writing down.** Number 1 was not free. Since 01/08/2026 it
was the *illustration* of a rule, in three places at once:

* `i18n.rs` — "1 = allemand chez WinDev : nous ne le parlons pas encore, et une
  base allemande s'ouvre en français plutôt que dans le vide";
* `from_tag("de")` — the same idea with the tag;
* `backup/mod.rs::une_langue_inconnue_est_conservee_et_saffiche_en_francais` —
  a whole test built on a German archive, whose comment read "le jour où
  l'allemand arrivera, les bases restaurées d'ici là le diront encore".

Adding German makes all three **assert the opposite of what they mean**. They
would still have compiled. Two of them would still have passed for the wrong
reason. Only the backup one would have failed, and its failure would have looked
like a regression rather than a promise kept.

So the examples moved: Danish (6) for the number, Dutch (`nl`) for the tag. The
rule is untouched; only the language chosen to illustrate it changed.

**What it proves.** A test written with a real-world example carries a hidden
expiry date: the example can stop being an example. The comment that said "le
jour où l'allemand arrivera" is what made this cheap to find — it named its own
expiry. That is worth copying the next time a test needs a stand-in for
*something we do not support yet*: **say what will make it wrong.**

**The count so far.** Six languages, three of them added in one day. The claim
in P-18 held a third time: one `.ftl` file, one row in `KNOWN`, one line in the
migration, nothing in the view. The extra work here was not the language — it
was the three sentences that had been leaning on its absence.

---

## P-20 — Russian: the first language that is not shaped like French (03/08/2026)

**Decided.** Russian ships as a seventh language under WinDev nation number
**16** (`nationRusse`). Its plural selectors carry **four categories**, not two,
and `ru.ftl` is therefore 62 lines longer than `fr.ftl` while holding exactly the
same 1000 keys.

**Why it matters more than the language.** Portuguese, Italian and German were
all *shaped like French*: one message, one line, two plural forms. It was
tempting to think a language file is a column of translations. Russian says
otherwise. It has four:

| category | numbers | example |
|---|---|---|
| `one` | 1, 21, 31 (ends in 1, except 11) | 1 операция |
| `few` | 2–4, 22–24 (ends in 2–4, except 12–14) | 3 операции |
| `many` | 0, 5–20, 25–30 | 7 операций |
| `other` | decimals | 1,5 операции |

A translator who copied the French shape would have written `[one]` and
`*[other]` and produced *7 операция* — wrong to any Russian speaker, and
**invisible to every test we have**, because the key exists, the variable is
present and the file parses. The 31 plural selectors of `fr.ftl` were expanded
by hand, one by one, and checked by comparing the parsed syntax trees: every
plural selector in Russian must contain `one`, `few`, `many` and `other`, while
every *string* selector (`[category]`, `[bank]`, `[payee]`…) must stay exactly
as French has it. Those two rules are opposite, and telling them apart is the
whole job.

**What did not have to change.** Nothing. Not one line of Rust, not one line of
CSS or TypeScript. Fluent applies the CLDR plural rules of the `ru` tag by
itself; the tag was already there because Fluent needed it for hyphenation. The
design paid for this four languages ago without anyone noticing.

**What this costs going forward.** The claim "a language is one file and one
row" survives, but the *file* is no longer a mechanical translation. Any
language with a plural system of its own — Polish, Czech, Arabic — needs its
selectors rebuilt, not copied. That is a translator's job, not a programmer's,
and it is the first place a new language will go wrong.

---

## P-21 — Polish counts, and it does not count like Russian (03/08/2026)

**Decided.** Polish ships as an eighth language under WinDev nation number
**34** (`nationPolonais`). Its plural selectors carry four categories, exactly
as Russian does — and `pl.ftl` comes out at 1823 lines, the same as `ru.ftl`,
to the line.

**That coincidence is the trap.** Two files of identical shape, written a day
apart, for two Slavic languages with four plural categories each. Everything
invites copying one into the other. The categories do not agree:

| number | Russian | Polish |
|---|---|---|
| 1 | `one` | `one` |
| 3 | `few` | `few` |
| 7 | `many` | `many` |
| **21** | **`one`** | **`many`** |
| **101** | **`one`** | **`many`** |

Russian puts every number ending in 1 (except 11) into `one`: *21 операция*.
Polish reserves `one` for the number 1 alone: 21 is *21 kont*, not *21 konto*.
A translator who reused the Russian endings would produce a file that parses,
that passes every test in this repository, and that is wrong roughly one time
in ten — on exactly the numbers a real account reaches.

The Polish file was written from the Polish rules, not from the Russian file.
The verification compared syntax trees against **French**, never against
Russian, precisely so that a Russian mistake could not be inherited as a
Polish one.

**Rule for the next Slavic language.** Czech, Slovak, Ukrainian, Serbian,
Croatian all have four categories and **four different rule sets**. The shape
of the file may be copied. The endings may not. Always start from the CLDR
rules of the language being added, and check `one` on 21 — that single number
separates most of them.

---

## P-22 — Ukrainian, and a number range of our own (03/08/2026)

**Decided.** Numbers **1–99 belong to WinDev**. Numbers **100 and above belong
to Radinus**. Ukrainian, which WinDev does not have, takes **100** — the first
of our range. `FIRST_RADINUS_CODE` holds the boundary and a test enforces it.

**Why the question came up.** Every language so far had a WinDev nation number
because every language so far was in WinDev's table. Ukrainian is not: the
table runs 1 to 50 and stops at Hindi. Something had to be invented.

**Why not simply take the next free number.** 51 was free. So was 60. Taking one
of them would have worked today and broken later: WinDev's table is theirs to
extend, and the number Radinus writes does not stay inside Radinus. It goes into
`Parametres.UtiliseLangue` on the user's disk **and into every backup archive**.
If WinDev one day calls 51 Georgian, an old Ukrainian archive restored into a
newer build would come back speaking a language nobody chose. The failure would
surface years later, on somebody else's machine, with no way to tell which
number meant what when it was written.

Fabrice's instruction was "put a three-digit code on it". That is the right
shape: three digits cannot be mistaken for a WinDev constant by anyone reading
a database by hand, and the gap from 51 to 99 leaves WinDev room to nearly
double its table before the two ranges could ever meet.

**The test is the point.** `aucun_numero_ne_squatte_la_reserve_de_windev` walks
every declared language and asserts its number is ≤ 50 or ≥ 100. Nothing sits
between. Without it, the next language added in a hurry lands on 51 and the
whole reasoning above is lost — it would live only in this file, and files are
not run.

**Two smaller rulings inside this one.**

* The tag is **`uk`**, not `ua`. `ua` is the country's internet domain; `uk` is
  the language. Fluent would silently fall back on an unknown tag and Ukrainian
  plurals would quietly become English ones. A test pins `from_tag("ua")` to
  French so the mistake cannot be made twice.
* Ukrainian plurals count **like Russian, not like Polish**: 21 is `one`. That
  is now three Slavic languages in this repository with three different rule
  sets — Russian, Polish, Ukrainian — and two of them agree while the third
  does not. Copying between them is the standing hazard, recorded at P-21.

---

## P-23 — Dutch puts the currency sign in front (03/08/2026)

**Decided.** Dutch ships as a tenth language under WinDev nation number **12**
(`nationNéerlandais`), with `ui-money-sign-position = before`. It is the second
language to do that, after English, and the eight others all put the sign after
the number.

**Why it is worth an entry.** The rule established on 01/08/2026 is that the
sign's position follows the *language*, not the currency — it lives in the
language file next to the two separators. Nine languages in, that rule had only
ever been exercised by English, and it would have been easy to read the pattern
as "English is the odd one out". Dutch shows it is not an exception but a
property: a Dutchman writes **€ 1.549,81** with the sign in front and the
separators of the continent behind it — `.` for thousands, `,` for decimals,
exactly like German. Position and separators are two independent facts about a
language, and Dutch is the case that proves they do not travel together.

**The fallback example moved for the second time today.** `from_tag("nl")` was
the illustration of "an unknown tag falls back to French", inherited that
morning from `from_tag("de")` when German arrived. Dutch arriving made it wrong
again. It now says `da` (Danish). In one day this single line has cited three
languages, two of which were added hours later.

That is not bad luck. **The fallback example is always the next language
somebody asks for** — it gets chosen precisely because it is plausible and
absent, which is the same reason it gets requested. The lesson from P-19 is
therefore stronger than it looked: do not just say what will make the example
wrong; expect it to go wrong soon, and prefer a language nobody is likely to
want. Danish holds for now.

---

## P-24 — Norwegian: one nation number, two written languages (03/08/2026)

**Decided.** Norwegian ships in **Bokmål** under WinDev nation number 13, with
the tag **`nb`** — not `no`. `nn` (Nynorsk) is not spoken and falls back to
French. The database migration accepts both `nb` and `no` as 13.

**Why it needed a ruling.** Every language so far had one written form. Norwegian
has two, Bokmål and Nynorsk, both official, and WinDev has a single constant for
the pair. The number therefore cannot say which one a file is written in. The
**tag** can, and it is the only place that can: Fluent reads it, and it is what
appears in the language file itself.

Bokmål is written by roughly nine Norwegians in ten. Shipping it as plain `no`
would have been the easy choice and the dishonest one — it would claim to be
"Norwegian" while being one of its two forms, and a Nynorsk user asking for `nn`
would have been silently served Bokmål. So `nn` falls back to French instead:
**an obvious absence beats a quiet substitution.** A test pins it.

The name shown in the language list is `Norsk bokmål`, not `Norsk`, for the same
reason: a Norwegian should be able to see which of the two he is getting before
clicking, not after reading a sentence.

**The migration takes both spellings.** A 1.9.3 database coming from Windows may
carry the old text tag as `nb` or as `no`, depending on who set it; both mean
nation 13 and both are accepted. This is the first entry in that table with two
keys for one number, and it is deliberate — refusing `no` would have silently
turned a Norwegian base French on import.

---

## P-25 — Romanian has three plural categories, and a word French has no use for (03/08/2026)

**Decided.** Romanian ships under WinDev nation number 35 with **three** plural
categories — `one`, `few`, `other` — and **no `[many]`**. Every `*[other]`
variant carries the word **`de`**.

**The third shape.** This repository now holds three different plural systems:

| languages | categories |
|---|---|
| French, English, Spanish, Portuguese, Italian, German, Dutch, Swedish, Norwegian | `one`, `other` |
| Romanian | `one`, `few`, `other` |
| Russian, Polish, Ukrainian | `one`, `few`, `many`, `other` |

The hazard recorded at P-21 — copying one Slavic file into another — has a
sibling here. Romanian is the only three-category language, and it sits between
two groups that both look like plausible models. Adding `[many]` by analogy with
Russian would parse, pass every test, and be wrong; dropping to `[one]`/`[other]`
by analogy with Italian would be wrong the other way.

**The `de`.** This is the part no test can see. From twenty upward, Romanian
inserts `de` between the number and the noun: *19 operațiuni* but
*20 **de** operațiuni*. That single word is the reason the third category
exists at all — `few` and `other` differ by it and by nothing else in most
sentences. A translator working from the French, which has no such rule, has no
prompt to invent it, and the result reads as broken Romanian while being
structurally perfect.

So it was checked mechanically rather than trusted: the 31 plural selectors were
parsed, their `*[other]` branch extracted, and each one asserted to contain
`{ $count } de …`. All 31 do.

**Also pinned:** the diacritics are the **comma-below** forms `ș` (U+0219) and
`ț` (U+021B), never the cedilla lookalikes `ş`/`ţ`. The two pairs are visually
close, come from different code blocks, and the wrong one renders as a missing
glyph in several fonts. Zero cedillas in the file.

---

## P-26 — Finnish: two plural categories, and neither of them means what French means (03/08/2026)

**Decided.** Finnish ships under WinDev nation number 8 with the same two plural
categories as French — `one` and `*[other]` — and every `*[other]` that counts
something uses the **partitive singular**, not the plural.

**Why an entry for a language that changed nothing structurally.** Because that
is exactly the point. Romanian (P-25) announced its difficulty in the file
itself: a third variant appeared, and anyone reading `ro.ftl` sees it. Finnish
announces nothing. Its selectors are shaped identically to French, so the file
*looks* like Italian or Dutch — and the trap is entirely inside the words:

    1 tili       nominative singular   → [one]
    3 tiliä      PARTITIVE singular    → *[other]

Writing `{ $count } tilit` — the plural, by calque from French — parses, keeps
every variable, satisfies every test in this repository, and is wrong. There is
no structural signal to check for. This is the first language whose main hazard
**cannot be caught mechanically at all**; a heuristic pass over the 29 counting
selectors found 28 partitives and one genitive (`näiden { $count } rivin`, which
is correct Finnish — the partitive rule does not apply after a
genitive-governing structure), and that is as far as a machine gets.

**The second difficulty, which does show.** Finnish marks grammatical function
with case endings, and `{ $label }` arrives with no ending and no way to add
one. Sentences were therefore rewritten so the placeable stays in the
nominative — `Tili ”{ $label }” poistetaan.` rather than a form requiring a
genitive on the inserted word. This is a general lesson, not a Finnish one:
**a message that needs its placeable inflected is a message that cannot be
translated into a case language.** Hungarian, Estonian, Turkish and the Slavic
languages already shipped would all have preferred the same treatment.

**Fourteen languages.** Four plural systems: two categories (nine languages),
three (Romanian), four (Russian, Polish, Ukrainian), and now two-that-are-not-two
(Finnish).

---

## P-27 — Icelandic: `[one]` does not mean one (03/08/2026)

**Decided.** Icelandic ships under WinDev nation number 10 with the same two
plural categories as French, and **every one of its 29 `[one]` variants carries
`{ $count }`** — never a hard-coded `1`, never "a rule was deleted", never a
demonstrative.

**Why.** CLDR puts a number in Icelandic's `one` category when it ends in 1 and
does not end in 11. So `one` fires for **1, 21, 31, 101, 121** — and `other`
fires for 11 and 12. French's `one` fires for 1 and nothing else.

That difference is invisible in the shape of the file. `is.ftl` has exactly the
selectors `fr.ftl` has, in the same places, with the same two branches. It looks
like Dutch. And a translator copying the French habit writes

    [one] 1 færsla eydd.

which displays **"1 entry deleted"** after deleting twenty-one. Ten of the
French `[one]` variants make it worse by not writing a digit at all — *« Une
règle supprimée. »*, *« Confirmez-vous la suppression de cette opération ? »* —
so there is not even a `1` to notice and translate away. The wrongness is in the
word "une" and in the demonstrative "cette".

**This one is checkable, and that is the useful part.** Unlike Finnish's
partitive (P-26), which lives entirely in vocabulary, this rule has a
syntactic shadow: *if a `[one]` branch speaks of a quantity, it must contain the
count placeable.* That is a property of the parse tree. A pass over `is.ftl`
extracted all 29 `[one]` branches and asserted `{ $count }` in each. All 29 pass.

**The general shape of the rule.** Any language whose `one` category extends
beyond the number one — Icelandic, Russian, Ukrainian, and several others —
cannot reuse the French habit of spelling the numeral out in the singular
branch. The habit is invisible in French because there it is correct.

---

## P-28 — A language is a file. Nothing else moves. (03/08/2026)

**Ruled by Fabrice, in his own words:** *« tu ne retournes rien, aucun écran, tu
ne touches à aucune mise en page, tu ne bouges aucun champ pour aucune langue. »*

**The rule.** Adding a language means adding one `.ftl` file and one row in
`KNOWN`. It never means touching a window, a stylesheet, a field position or a
column order. No exception, no language.

**What this settles.** Right-to-left scripts — Hebrew, Arabic, Persian, Urdu.
The question was raised twice on 03/08/2026 and answered the same way both
times; this entry exists so it is not raised a third time.

**Why the rule is sound, and not a shortcut.** The text itself needs nothing.
Every Hebrew character carries its own direction, and the browser lays it out
right-to-left on its own — today, in Radinus as it stands, with no code at all.
A Hebrew file would display correctly in every field from the first launch. What
does *not* move by itself is the position of the boxes: the label stays left of
its field instead of right. That is a cosmetic difference in an otherwise
correct window, and it does not justify reworking thirty-eight screens.

**Where I was wrong, and it is worth recording.** I twice presented this as a
larger problem than it is — first by claiming the stylesheets would resist
(they mostly would not: the windows are built in grid and flex, which flip on
their own), then by pricing the remainder at half a day after counting the
declarations that were easy to count. Counting what is easy to measure is not
estimating. Fabrice's judgement was right both times and mine was not.

**The text is never reversed.** Sentences are written in normal reading order,
exactly as in every other language file. Nothing is inverted, stored backwards,
or transformed. That was never in question, and saying so here removes any doubt
for whoever reads this next.

---

## P-29 — Fidelity to the WinDev source outranks my judgement (03/08/2026)

**Ruled by Fabrice, in his own words:** *« tu ne touches à rien, fidélité à mon
code WinDev, c'est tout. »*

**The rule.** When Radinus 2 differs from Radinus 1.9.3, the question to ask is
"is the port faithful?" — never "is the original right?". A behaviour that looks
wrong but matches the WLangage source is not a defect. It is the software
Fabrice wrote, and it stays.

**What it cost to learn.** The reliability audit of the same day reported two
defects in the periodic rules:

* §5a — the first occurrence is offered without being checked against the end
  date, so a rule whose `DateProchOp` has passed `DateFin` still proposes it;
* §5b — the repeat count is compared to the length of the proposal being built,
  never to what the rule has already inserted, so a "3 repetitions" rule inserts
  three more every time the calendar is opened.

Both are **exactly what `Class_EcheanceOPPeriod` does**:

```wlangage
PROCÉDURE Gen_Echeances()
m_nIteration = 1                       // reset on every generation
…
m_tabEche.Ajoute(m_stEnrEche)          // first occurrence, unconditional
TANTQUE Existe_EcheanceSuivante()
    m_nIteration = m_nIteration + 1

PROCÉDURE Existe_EcheanceSuivante()
CAS 2 : SI Date_EcheanceSuivante() <= m_dDateFin ET m_nIteration < m_nLimite
CAS 3 : SI m_nIteration < m_nPeriodeNbrRepete ET m_nIteration < m_nLimite
```

`m_nIteration` is reset to 1 at every generation — the Rust `dates.len()` is its
exact equivalent. `m_dDateFin` is only ever compared to the *next* occurrence,
never the first. `FEN_GenereOpPeriode` filters nothing before calling. The port
is faithful, line for line.

§5a had already been "fixed" in the first batch of audit corrections. **It was
reverted**, and the reason is now written where the code is, so the next reader
does not repair it a second time.

**The lesson, which is about auditing and not about periodic rules.** An audit
of a port has two legitimate findings: the port betrays its source, or the port
crashes. "The original design is questionable" is a third thing, and it is not
the auditor's to rule on. Mine slid into the third without noticing, and stated
it with the same confidence as the first two. Anything found in future audits
must be checked against `Analyse/` before being called a defect — the WLangage
source is there, and reading it takes a minute.

---

## P-30 — Replacing a database closes Radinus; "Delete everything" is gone (03/08/2026)

**Two rulings by Fabrice, an hour apart, and the second follows from the first.**

**First.** Restoring a backup now **forces Radinus to close**. The confirmation
question warns of it beforehand; when the restore finishes, a panel with a
single button — *Quitter* — ends the application.

The defect it answers: a restore reassigns every identifier, but a Radinus
window is never destroyed, only hidden, and it keeps the identifiers it was
opened with. A statement-import window left open on account 3 would integrate
its lines into account 3 *of the restored database*, which is a different
account. No failure, no mistake by the user: an open window was enough.

The narrow fix existed — `AppState::forget_everything` already clears every
in-memory draft, and simply was not called after a restore. Fabrice ruled wider:
*« on quitte direct, car sinon tu n'empêcheras pas que l'on puisse aller
ailleurs »*. What goes stale while a database is being replaced cannot be
enumerated by hand; closing carries away the cases nobody thought of too.

**Second.** *« Tout supprimer ! »* is **removed from the software**, in his
words *« elle n'a plus de sens d'exister »*.

It came from WinDev, which knew one database and one only. Radinus 2 manages
several, and its selector already deletes one — and does it **better** in three
ways: the folder goes to the **trash**, so a mistake is undone with a right
click; it takes the **attachments** with it, which "Delete everything" left
orphaned on disk forever, unreferenced and unbacked-up; and it forces the user
to pick a database afterwards, which shows him what he has just done.

Removing it also removed the forced-quit path that had just been written for it,
and took `reset_to_blank`'s foreign-key window out of the user's reach.
`reset_to_blank` itself stays in the core: it is the first step of a restore.

**What both rulings have in common.** Neither is a repair. Both replace a
mechanism that had to be got right every time with one that cannot go wrong at
all — closing, and not having the button. That is the cheaper kind of
correctness, and it is worth preferring when it is available.

**Revised on 04/08/2026 — the forced quit is gone, and the first ruling with
it.** The same day the four database operations moved out of the menu bar and
into a **Tools menu on the databases window**, where they aim at *the selected
row* — open or not. Backing up "famille" from inside "perso" is now ordinary,
and quitting Radinus over a database nobody was looking at made no sense.
Fabrice went further and dropped the quit in every case, including a restore of
the open database, after the defect it protected against was restated to him.

What protects now, when the restored database is the open one: the in-memory
drafts are thrown away — `AppState::forget_drafts`, the narrow remedy that
existed on 03/08 and was set aside — and every window rereads. **One case is
covered by neither**, and he was told: a window sitting on account 3 will
reread account 3 *of the restored database*, which is a different account. Only
quitting prevented that.

The second ruling stands: "Delete everything" is still gone.

## P-31 — The welcome rings go three levels deep, and the third is a curve (03/08/2026)

**Ruled by Fabrice.** A click on a sector — or on the matching legend line —
redraws the ring by **category** inside that budget line. A click on a category
does *not* go back up: it switches to a **smoothed curve of that category's
running total across the month**. Under each drawing sits a link to the level
above: under the curve, *Catégories*; under the categories, *Postes
budgétaires*. At the top there is no link, because there is nowhere to go.

**Why this does not break the rule of the window.** P-8 says the welcome is the
**no-click view**, and that anything needing a setting belongs to F19. Drilling
is not a setting: nothing is chosen, nothing is typed, nothing is remembered
between two openings. It is a finer reading of what is already on the screen,
and the window still answers before anyone has asked it anything.

**Why the third level is a curve and not a fourth ring.** A ring of one category
would be a full circle, and a full circle says nothing. The ring answers *how
much*; the curve answers *when*. A budget line spent in one go on the 3rd and
one spent a little every day draw the same sector and two curves that have
nothing in common — and that difference is the only thing left to learn at that
depth.

**Smoothed, where F25 draws steps.** A balance jumps on a date and stays there;
drawing it in steps is the truth of an account. Here one reads a **shape** over
a month, not a state at an instant. The smoothing cannot lie about the total,
which is written out in full at the end of the line — the same rule as the value
written on every sector of a ring.

**An empty month keeps you where you are.** Fabrice chose it explicitly: a month
with nothing inside the drilled budget line shows a **pale grey silhouette of a
ring** and the sentence *« Aucune opération ce mois-ci »*, and one stays in that
budget line — the next month finds it again. The silhouette is clickable,
because otherwise an empty month would be a dead end. **F19 does not get it**:
its ring does not drill, it was accepted on 26/07/2026, and a drawing that looks
clickable without being clickable is worse than one that is plainly still.

**What this cost the layout, and what it was not allowed to cost.** The card
body is a *row* — ring and legend sit side by side — and F19 shares that rule.
A heading above and a link below need a column, so the column is placed **inside**
the card body (`.card__stack`, `.card__drawing`) rather than turning a shared
rule around. For the same reason the heading got a class of its own
(`.card__subject`): `.card__heading` is already the title of the three balance
cards, in F01 as in F19, and giving it a weight would have changed all six.

**Addendum, 04/08/2026 — a drawing never leaves its card.** Fabrice, shrinking
the window: the ring and the curve spilled over the neighbouring card, over the
window edge, and **over the chevrons ‹ ›, which stopped answering** — the click
landed on the drawing painted above them. His ruling: *« mets plutôt un
ascenseur vertical dans le cadre s'il n'y a pas de place… Les graphiques ne
doivent pas sortir de leur encadré. »*

So the card body now holds its content (`overflow: auto`) and scrolls when the
room runs out, and both drawings shrink before they overflow (`max-width: 100%`,
`height: auto` — the `viewBox` keeps their proportions). Each keeps a **floor,
set by legibility and not by room**: a drawing that shrinks shrinks its numbers
with it, so below 180 px for the ring and 360 px for the curve — where the day
numbers of the axis fall under 8 px — it stops shrinking and the scrollbar takes
over. An unreadable axis is not a smaller drawing, it is a lost one.

Two details worth keeping. `safe center` and not `center`: content wider than
its frame, centred, overflows on *both* sides, and the left side of a scrolling
box cannot be reached — `safe` makes an oversized item sit at the start instead.
And F19 was checked pixel by pixel at its normal size, before and after: the
containment rules cost it nothing, because they only take effect at the moment
something was going to escape.

## P-32 — Display size belongs to the software, not to the database (04/08/2026)

**Ruled by Fabrice.** The zoom factor moves out of each database's
`Preferences` table and into `settings/radinus_config.json`, next to the
language: *« ce sera un paramètre du logiciel et non pas un paramètre de la
base »*.

**Why it was wrong where it was.** Display size says something about the screen
and the eyes reading it, not about the accounts being kept. Stored in the
database it changed when you switched database, and — worse — it travelled: a
backup carried the zoom of the desktop it was made on onto whatever machine
restored it. The same argument that put the language in the config file on
03/08 applies here, and had simply not been applied.

**What it fixes on the way.** The zoom was applied when a database opened, so
the two windows you see *before* that — the language chooser and the database
list — were always drawn at 100 %, i.e. too small for exactly the person who
had set otherwise. It is now applied before the first window exists.

**The old rows are left alone.** Every existing database still has a `zoom` row
in `Preferences`; it is neither read nor deleted. A migration that touches data
to gain nothing is an opportunity to break something for nothing. One
consequence, and Fabrice knows it: the setting resets to 100 % once, and is
set again in the Preferences window.

**The `Preferences` table is back to one key**, `devise`, and the test that
counts them says so — if the zoom ever returns there, it will fail.

---

## P-33 — The schema is a declaration, not a history (03/08/2026)

**Ruled by Fabrice**, after asking what happens when a table is deleted from a
database behind Radinus's back: *« Tu vas créer chaque table dans une requête
sql différente avec un ordre du type "CREATE TABLE IF NOT EXISTS" […] à chaque
fois que l'on se connecte à une base tu lances cette procédure qui va créer
éventuellement des tables manquantes ou inexistantes. Le but est multiple :
réparer des bêtises, mais aussi faire progresser la base vers des versions
supérieures avec l'évolution du logiciel. »*

**What was wrong before.** `create_baseline_schema` was a single
`execute_batch` of 23 bare `CREATE TABLE` statements, run once and only when
`Parametres` was absent. A table deleted afterwards never came back: Radinus
opened the database, then failed on the first query with SQLite's *no such
table*, shown to the user as « Lecture impossible » — a dead end with no way
out from inside the software. And a table added by a future version of Radinus
would have needed a migration step written by hand for it, on top of a
`restore_the_mirror` that already covered exactly two tables and only below the
current version number.

**What it now does.** `ensure_the_tables` walks a list of twenty-two
`TableDeclaration`s — one name, one `CREATE TABLE IF NOT EXISTS` with its
indexes — and runs on **every** open, not only on creation. A missing table
comes back; a table added to the list tomorrow appears in every existing
database with nothing else to write. Adding a table to Radinus is now adding an
entry to a list.

**Where it stops, and this is the important part.** `CREATE TABLE IF NOT
EXISTS` does nothing at all when the table exists but has *changed* shape. A
column added, a type altered, a constraint tightened stays the business of an
explicit step — like `language_becomes_a_number`, which had to rebuild
`Parametres` because SQLite's `TEXT` affinity was quietly turning the language
number into a string. Fabrice ruled this out of the procedure on purpose:
*« hors de cette procédure, une étape à part »*. `restore_the_mirror` keeps
only its two column additions for the same reason.

**What it costs, accepted knowingly.** A deleted table used to break Radinus
loudly. It now comes back **empty**, and the software runs — showing operations
whose category no longer exists. A visible failure is traded for a silent hole.
Two things soften it: the three *frozen* nomenclatures (`TypeCompte`,
`StatutOperation`, `StatutCheque`) are refilled when found empty, because their
content comes from the software and an empty one makes data entry impossible;
and every table recreated or refilled writes a line in the journal (⌘H) —
Fabrice's answers to the two questions that decided it: *« On regarnit, et on
le dit »*, *« Une ligne dans le journal, sans interrompre »*. The nomenclatures
that belong to the user — banks, payees, categories, budget lines — are never
refilled: emptying one can be a choice.

**`Parametres` is the one table this never creates.** It is the badge that says
« this file is a Radinus database », and `open_existing_database` recognizes a
database by it and by nothing else. Had the procedure restored it like the
others, the check would have dissolved by itself: any `.sqlite` file picked by
mistake in the selector would have had twenty-three tables written into it and
become a Radinus database, and the message « ce fichier n'est pas une base
Radinus » could never have appeared again. Fabrice chose the badge over the
repair, knowing the price: a database whose `Parametres` is deleted is lost to
the software, with every operation intact inside it.

**The journal it writes is the existing one** — the log of the *last* technical
operation, which a later backup or repair overwrites and which does not survive
closing Radinus. That was Fabrice's choice too, over a file that would
accumulate: the trace is fleeting, and faithful to `gtabMonLog.SupprimeTout()`.
The report travels out of the core in `database::Opened { conn, report }`
rather than being lost on the way, because repairing in silence is exactly what
this ruling refuses.

**Extended to columns on 05/08/2026**, on the same principle and at Fabrice's
request — he wanted to master the mechanism absolutely, and to be able to make
Radinus evolve without asking for a migration step every time. A declared column
missing from a table that exists is now added on every open too, its shape taken
from a model built in memory from these very declarations. The full account of
how it works, which files it touches, and the recipes for adding, changing or
removing anything in the database is in **`Schema_evolution.md`** — written the
same day, at his request, in place of a ruling of its own.

---

## P-34 — A database can carry its own password (05/08/2026)

**Ruled by Fabrice**, and it is an *addition*, not a port: *« Les bases de
données seront protégées spécifiquement sur ordre de l'utilisateur, chaque base
pourra avoir un mot de passe différent. »*

**What 1.9.3 actually did, since the difference matters.** `FEN_ChangePwd`
stored `HashChaîne(HA_HMAC_SHA3_256, sPwd, sPwd)` in `ParamSecurite`, with the
date of the last change and a hint. That is a *hash*, not a key: it locked the
software, not the file, and the data stayed readable to anyone who opened the
database another way. Radinus 2 encrypts the file itself. Told, and confirmed.

**The engine.** SQLite proposes no free encryption of its own — its official
extension, SEE, costs US $2 000. The free and universal answer is **SQLCipher**
(BSD-3, AES-256, PBKDF2, HMAC per page), which `rusqlite` compiles directly
through `bundled-sqlcipher-vendored-openssl`. Fabrice doubted the "nothing free"
framing and was right to: password protection *is* free and standard, it simply
does not come from the SQLite project. New dependency, authorized the same day.

**Nothing is written down about which databases are protected.** Radinus opens
without a key and looks; a file that resists gets asked for its password. That
was Fabrice's choice over a note in `radinus_config.json` with a padlock in the
table, and it buys something real: a database copied from another machine,
renamed by hand or moved elsewhere behaves exactly the same, because there is no
record to keep in step — therefore no record that can lie.

**Wrong password and not-a-Radinus-database are one event**, `OpenError::Locked`.
This is not an approximation: without the key there is nothing to read, not even
enough to tell an encrypted file from a damaged one. It also revises P-33's
answer in one respect — the `Parametres` badge can only be looked for *after* the
file has been unlocked.

**One fiche, three fields, three gestures.** Right-click a row of the database
window, "Protection par mot de passe", and the fiche opens: old password (empty
if there is none), new password twice. Old empty = protect. All three filled =
change. Both new ones empty = remove, with one confirmation. Fabrice dictated it
and said why: *« deux saisies égales : je n'invente rien »*.

**`PRAGMA rekey` was not enough, and finding that out cost a broken test.**
SQLCipher's rekey changes the key of an *already encrypted* database and nothing
else — it refuses to encrypt a plaintext file and refuses to decrypt back. Both
crossings go through `ATTACH` + `sqlcipher_export()` into a second file that
then replaces the first. `PRAGMA user_version` is copied by hand, because
`sqlcipher_export` carries tables, indexes and data but not the integer in the
file header — lose it and `migrate` would think the database older than it is.

**A wrong old password touches nothing.** There is no stored password to compare
against, so the check *is* the successful read: unlock, try to read the catalog,
and only write if that worked. Getting your own password wrong while changing it
cannot cost you the database.

**What this does not protect, stated plainly.** The backup archive stays
unencrypted — Fabrice's decision — so a protected database's backups are
readable by anyone who finds them, and there will be many, since he recommends
backing up often. Attachments are ordinary files in `attachments/`. And a lost
password is a lost database: no back door, no secret question, no recovery. The
fiche says so on screen, above the buttons, before anything is done.

---

## P-35 — Leaving a database without leaving Radinus (05/08/2026)

**Ruled by Fabrice**: *« ce que je veux c'est un bouton se déconnecter de la
base pour revenir au sélecteur avec aucune base ouverte à ce moment »*.
Fichier › « Se déconnecter de la base en cours », greyed unless a database is
open, and deliberately *not* requiring an account — a database you opened by
mistake is exactly the one you want to leave.

**Two other routes were considered and refused**, and the reasons matter more
than the conclusion.

*Closing every window for real.* In Tauri, closing means destroying: the
webview, the page, its dictionary, its listeners all go, and reopening rebuilds
from nothing — against the rule that every Radinus window is built once and
never destroyed. Worse, the gesture does not mean the same thing everywhere: on
Windows and Linux the last window closed ends the process, on macOS it does not.
The `main` window's own close handler already encodes that asymmetry. Hiding
does everything wanted here, so the windows are hidden.

*Relaunching the process.* Fabrice asked whether restarting Radinus would be
safer. It was tried on 02/08/2026 and it is the thing that broke: the relaunched
process came up with **blank windows**, and Radinus vanished without a word.
The cause was never established, which is the real objection — a failure that
only appears after an `exec` cannot be reproduced by any test we own. And a
restart means an instant where **two Radinus exist at once**, both looking for
the same portable root, both reading and writing the same
`settings/radinus_config.json`, possibly both connected to the same SQLite file.
Since P-34 that is worse still: changing a password copies the database into a
second file and renames it over the original.

**The precondition, and it was the real work.** A hidden window keeps what it
was showing. Fabrice confirmed the consequence on « Soldes de vos comptes »
before anything was built: note a balance, close, enter an operation, reopen —
*« le solde n'a effectivement pas bougé »*. That was already a bug, independent
of any disconnection; with one it would have become balances from *another
database* under the name of the one just opened. Of 40 windows, 35 read the
database and 33 already re-read on reopening; exactly two never did — « Soldes
de vos comptes » and « Préférences ». Both now use the welcome window's own net
from 26/07/2026: reload when the window regains focus, because a window being
shown again always regains it.

**And `toute_fenetre_qui_lit_la_base_sait_se_relire` locks it.** Any window
calling a command that asks `AppState` for the connection must have at least one
way of learning the database changed under it — the reopening event, the
data-changed event, or the focus net. The test was verified by breaking it: the
nets were removed from « Soldes de vos comptes », it failed by name, they were
put back, it passed.

**One premise of mine was wrong, and Fabrice corrected it.** I had planned to
tear down the selector's « quit Radinus first » wall. There is no wall left to
tear down: since 04/08 the selector is only reachable at startup, when no
database is open, so that branch is already unreachable. It stays where it is —
it costs nothing and would still be right if the selector ever came back with a
database open.

**A side effect worth having.** Once disconnected, the database is no longer
open, so it can immediately be backed up, repaired, or password-protected from
the selector's Outils menu — three operations that refuse to touch an open
database.

---

## P-36 — One Radinus, installed by default, portable on demand (05/08/2026)

**Ruled by Fabrice**, after asking whether abandoning the portable-only design
would be a large job — and then reframing the question far better than it was
asked: *« Radinus est et doit rester multiplateforme Windows Mac Linux tous les
trois en version installable ou portable […] je me demande si une ou plusieurs
constantes dans le code pourrait faire que je n'ai pas à te demander de changer
les choses à chaque fois. »*

**There is now one build per system, not two.** Radinus installs normally and
keeps its data in the operating system's standard folder. It becomes portable
when it finds `settings/start_mode.toml` **beside its executable** carrying
`portable_mode = 1`; then everything lives next to the application and the whole
thing copies onto a USB stick. Three builds in total instead of six, and no
second distribution to keep in step.

| | standard folder |
|---|---|
| Windows | `%APPDATA%\Radinus\` |
| macOS | `~/Library/Application Support/Radinus/` |
| Linux | `~/.local/share/radinus/` (or `$XDG_DATA_HOME`) |

Read from the environment, without a library: three variables the system sets
itself, twenty lines, no new dependency to authorize. `system_folder` takes the
environment as a parameter rather than reading it, so all three branches are
tested on any machine — a test that only exercised its own platform would check
a third of the work.

**Anything that is not a plain `1` means installed**, including a missing,
empty, or unreadable file. The doubt resolves that way and not the other because
an application that does not know where it is must write in the user's folder,
never beside itself: on a machine that is not yours, writing next to the
executable is the worse of the two.

**The file cannot live in the folder it defines**, which is why it sits beside
the executable and nowhere else. Every other setting lives *inside* the data
root; this one *decides* the root. `settings/radinus_config.json` — language,
zoom, last database opened — stays where it always was.

**Radinus writes a copy of it into the standard folder, and never reads it
there.** That copy sleeps, and Fabrice asked for it on purpose: *« si un jour je
demande à un utilisateur de copier les données ailleurs […] il me suffira de
changer portable_mode=0 en 1 »*. Moving the data folder next to the application
brings the file along, already in the right place, and one digit finishes the
job. It also makes the portable mode *discoverable* — nobody looks for a marker
whose existence they cannot guess. The comment inside it says both what it does
and why it does nothing where it currently sits, so a `1` set there without
moving anything does not read as a broken program. **It is written only when
absent**: a user's `1` is never overwritten at the next launch.

**The renaming was part of the ruling, not a tidy-up.** `portable_root` would
have returned `~/Library/Application Support/Radinus` — a name stating the
opposite of the truth. It became `data_root`, `ensure_portable_tree` became
`ensure_tree`, `PortableConfig` became `SoftwareConfig`, and `portable.rs`
became `location.rs`. Fabrice chose to do it immediately rather than later: it
is mechanical, it changes no behaviour, and it was the last moment it stayed
cheap.

**Order matters at startup, and it already did.** `data_root` only reads; the
tree is created afterwards, in the folder just chosen. Creating first would
leave an empty folder beside the application before Radinus went elsewhere.

**One consequence on macOS, for the record.** An app running under App
Translocation cannot read its own `start_mode.toml`, so it always starts in
installed mode whatever is placed beside it. The startup warning now says so
instead of talking about a portable folder that may not exist.

---

## P-37 — Radinus leaves the MIT licence for the GNU GPL v3 (08/08/2026)

**Ruled by Fabrice**: *« Je décide de changer de licence, on va changer de
licence et adopter GPL V3 »*, then `GPL-3.0-or-later` rather than plain
`GPL-3.0-only` when asked which of the two.

**What the change actually does.** MIT lets anyone take Radinus, close it, and
sell it without giving anything back. The GPL does not: whoever distributes a
modified Radinus must distribute its source under the same terms. The users
gain nothing they did not already have — they could always read and modify the
code — and what they gain is that nobody can take that away from the next one.

**`or later` and not `only`.** A licence pinned to version 3 alone cannot be
combined with code released under a future version 4, and the project would
have to be relicensed by hand to move. *Or later* leaves that door open without
forcing anything through it: Radinus is under v3 today, and stays usable under
whatever the Free Software Foundation publishes next.

**The dependencies were audited before the ruling, not after.** All 687 of them:
MIT, Apache-2.0, BSD, Zlib, MPL-2.0 or Unicode — every one compatible with the
GPL v3. One of them decided the whole question. `openssl-src`, pulled in by
SQLCipher, embeds OpenSSL; the *old* OpenSSL licence carries an advertising
clause the GPL refuses, and had it still applied, Radinus could not have been
GPL at all without dropping database encryption. Since OpenSSL 3.0 it is
Apache-2.0, and the version embedded here is 3.6.3. The audit is what turned a
preference into a decision.

**One door closes, and it is not one Radinus uses.** The GPL v3 is incompatible
with the Apple App Store, whose terms limit redistribution in ways the licence
forbids. Radinus is distributed from radinus.fr, so this costs nothing today —
it is written down so that nobody rediscovers it as a surprise later. A signed
and notarized `.dmg` outside the store stays perfectly possible.

**What was already granted stays granted.** Everything published under MIT
before this date remains MIT for whoever holds it; a licence cannot be
withdrawn from a copy already handed over. `LICENSE` says so above the GPL text
rather than leaving it to be worked out.

**Seven places name the licence, and all seven moved together**: `LICENSE`,
`Cargo.toml`, `package.json` — which had no `license` field at all and now has
one — both READMEs, `docs/About_dependencies.md`, and the eighteen `.ftl` files,
which carry it twice: `print-licence`, on every document Radinus prints, and
`about-radinus-licence`, in the « À propos » window. That second one is a fixed
460-pixel bar, so it names the licence and stops there; the *or later* lives in
`LICENSE` and in the printed line, where there is room to say it.

---

## P-38 — A window that says what the licence gives (08/08/2026)

**Asked for by Fabrice**, the same day the licence changed (P-37): *« Je veux
que tu crée une nouvelle fenetre comme celle de a propos de l'auteur et que tu
rendra disponible dans le menu parametre via l'option : "Licence
d'utilisation" »*. He had found the GPLv3 logo himself, in his own
`Imagestechno` folder, and named it.

**It says what the licence gives, not what it says.** The GPL v3 runs to some
thirty pages of law; a window holding them would be a window nobody reads. So
it names the licence, and lists the four freedoms in four lines — use, study,
share, improve. Whoever wants the legal text gets it from gnu.org, published
and maintained by the Free Software Foundation, which knows its own wording
better than a translation of ours would.

**Nothing here is translated that the FSF already publishes.** Eleven new
sentences in the eighteen language files, and not one line of licence text
among them.

**The logo is the button.** The first version put the action on a folder icon
in the slate panel — *« l'icone de dossier jaune dans la barre bleu n'est pas
adapté »*, and he was right twice: a yellow folder announces a folder, and the
thing one reaches for to read a licence is that licence's own emblem, which
was already on screen and already meant it. The panel now carries the door and
nothing else. The button has no frame and no background; only the cursor says
something happens there.

**The address is in Rust and reachable from nowhere else.** `open_licence_page`
takes no argument. A command accepting a URL from the window would hand the
view the power to open anything the machine can open, and the view is never
given a power it does not need. It reuses `system::open_link`, which the
« Aller sur le site de Radinus » menu entry has used since 03/08/2026 — three
lines, three system commands, no new dependency.

**Four freedoms are a list, not a paragraph cut in four** — *« ça doit être
structuré »*. Bullets, flush left as a block, with the line that announces them
on its own line above. Centring four sentences of unequal length gives a ragged
edge on both sides and reads as a poster.

**560 × 520, fixed.** It began at 460 and was too narrow. Fixed like its two
sisters: there is nothing in it one could want to enlarge.

**It is the first of the « À propos » family to be watched.** Neither « À
propos de l'auteur » nor « À propos de Radinus » carries a single render check,
which is exactly how a window ends up saying nothing on the day someone renames
a key. This one has twelve: that every sentence arrives whole from the core,
that the freedoms are four and bulleted, that the panel holds only the door,
that clicking the logo asks for the official page, and that nothing spills out
of a window which cannot be resized.

---

## P-39 — The Windows fixes come home, and macOS loses nothing (08/08/2026)

**Ruled by Fabrice**, after reading the handover file written on his Windows
machine on 05/08/2026: *« je te demande ton avis […] je me demande si à terme il
ne va pas falloir 1 version de base (macOS) et 2 variantes »*, then, once
answered: *« fais-moi les modifications que tu penses bonnes […] en préservant
la convivialité et le bon fonctionnement de la version macOS »*.

**One source, three systems — and the question was worth asking.** Three
codebases would have to be corrected three times; in practice they are corrected
one and a half times, and the day of a release someone discovers the Linux one
is six months behind. The eighteen languages, the schema, the core, the 863
render checks and the crossing tests are all shared, and all of it would have
tripled. `#[cfg]` is not a makeshift: the compiler puts the Windows lines in the
Windows binary and nowhere else, so the Mac executable carries none of this.

**None of the nine fixes was incompatible with macOS**, which is what decided
it. Four are branches macOS never executes. One — `Cmd` becoming `CmdOrCtrl` —
changes nothing at all on a Mac: the library reads it as ⌘ there and as Ctrl
elsewhere, and it merely writes at last what this file's own header had
announced from the first day. **Two are not Windows fixes at all** and the Mac
gains from them: the SQLite settings and the grouped balance transaction. NTFS
only made visible what APFS was charging quietly.

**Where the real limit is, and it is not in the code.** One source for three
systems is honest only if the three are compiled. The CI builds macOS alone
today; until a Windows job joins it, four of these fixes are verified by nobody
but Fabrice, by hand. That is the open item, and it is named here so it is not
forgotten.

**One correction to the handover file itself.** Its invariant 4 states that
Radinus is portable by nature, its root being the executable's folder. P-36
reversed that the same day: Radinus installs by default and becomes portable on
`portable_mode = 1`. The argument that ruled WAL out still holds — a database
folder one copies onto a stick must not travel with two open state files — but
it no longer rests on the same sentence.

**Two things the document promised that turned out false, and both were caught
by the tests.** It stated that no caller of `update_all_accounts` had a
transaction open: true of 2.0.0, false here — `repair::run` has one, and
SQLite said so eight tests at a time. The fix asks instead of assuming: it
opens its own transaction only when none is running. And the console gate it
named `command()` would have collided with a local variable of that name in
`send_to_printer` —
the very trap the document recorded. Named `silent_command`, the trap does not
exist.

**What was deliberately not brought back**: the « VERSION BETA » banner, which
belongs to a test machine and not to the line that will be released.

---

## How to add to this file

One entry per ruling: an id, a date, what was decided in one sentence, and
**why** in a paragraph. If a decision revises an earlier one, say so and keep
both. If it was reached after a fault, say which fault — that is the part that
stops it being undone by someone who never saw it.
