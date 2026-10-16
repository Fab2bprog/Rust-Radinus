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

## P-40 — A clearing date belongs to pointed operations only (21–25/08/2026)

**Ruled by Fabrice**, after users reported *« il y a une date de pointage alors
que le statut de l'écriture n'est pas en pointé »*, and refined over the audit
of the fix on 25/08/2026.

**Nine rules, and they hold together.** Nothing writes a clearing date on an
operation that is not pointed — the recurring generator, which dated every
instalment it produced, now dates only the ones already in the past. In a fiche
the field follows the status: emptied towards planned or committed, filled with
the operation's own date towards pointed, and the user may always type over it.
A pointed operation must carry its date, and the fiche refuses to save without
one — in a panel, not a line at the foot of the window, with a second line
offering the operation's date. Where the software points in bulk it writes the
operation's date **only where the field is empty**, and never over an existing
one. **Nothing is ever erased or rewritten in an existing database**: the dates
inherited from earlier versions stay where they are and go, fiche by fiche, as
their status is touched. In the list a date carried by a non-pointed operation
shows in grey and italic, and a non-pointed row shows no balance at all. The
« Pointer » button skips what is already pointed. A template writes what the
hand would write.

**What was deliberately left alone, and why.** The statement window keeps its
free choice of status: an OFX file only ever contains transactions the bank has
already passed, so the date there is always true, and *« pour être libre, parce
que sur 10 000 cas il y a toujours des exceptions »*. The fiche keeps emptying
the field when the status leaves "pointed", even though the Pointer button never
touches an existing date: *« le comportement de la fiche ne concerne qu'une
opération et demande une validation. Le bouton Pointer en un clic non désiré
peut détruire X informations »* — it is the size of the damage that decides,
not the symmetry of the rules. Quick classification may stamp a date on an
inherited row that is pointed without one: a silent repair, accepted as such.

## P-41 — Writing an operation is the controller's job to announce (25/08/2026)

**Ruled by Fabrice**, after finding that an operations list left open stayed
frozen once a statement had been imported.

**The bug was not where it looked.** The import wrote correctly; it simply told
nobody. Announcing was the job of the window that *asked* for the write, so
every window had to remember — the operation fiche remembered, the bulk
statement integration did not, and neither did five other paths. Offered the
choice between adding the missing calls and moving the duty, he chose the
second: *« option pour la seconde solution »*.

**Announcing now happens where the write happens**, in the controller, and a
window has nothing left to know. Two windows are told, not one: writing an
operation moves the balances, so the accounts list is as stale as the operations
list. A crossing test reads the controller, finds every command that makes the
core write an operation, and requires it to announce in the same breath — the
command written six months from now is caught there rather than at a user's
desk. The lesson is general and worth writing down: **a duty every caller must
remember is a duty that will be forgotten** — it belongs where the thing itself
happens, not in the list of things to think about.

## P-42 — The crossed balance crosses two nomenclatures, not one and time (25/08/2026)

**Ruled by Fabrice**: *« une nouvelle fenêtre de type statistique que nous
allons appeler Bilan croisé […] les catégories représenteront les lignes du
tableau et en colonne on n'aura plus du tout les mois mais les affectations »*.

**The six statistics all answer the same question in six ways** — one
nomenclature against the twelve months of a year. F39 asks a different one:
what did each assignment spend, under each category, *this month*. The time
axis is spent on the second nomenclature, so the period shrinks to a month and
one steps through months with the clocks that used to step through years.

**Three consequences follow from that alone.** There is no Cumul row: a running
total adds the months in order, and assignments have no order. Every category
and every assignment is shown even when empty, since columns that changed
places from one month to the next would be impossible to compare — and he
judged the width objection unfounded, *« il sera très rare que la personne ait
30 affectations »*, while asking for the horizontal scrollbar anyway. The export
follows the period: twelve tabs, one per month of the shown year, where the six
statistics export one tab per year.

**Everything else is the template of the six, on purpose.** Not a copy: the
same shared table, the same switches, the same colours, the same detail panel.
Six copies of a window are six copies of every fault it takes a day to remove.

## P-43 — A fiche that was not validated starts from zero (30/08/2026)

**Ruled by Fabrice**, after reporting that the reconciliation fiche kept part
of the previous line's answers. Asked whether reopening it on the *same* line
should give back what had been typed there: *« si on a pas intégré la fiche
c'est que l'on a pas validé donc c'est normal de recommencer cette fiche à
zéro »*.

**It says what Radinus already says everywhere else.** Nothing exists until it
is validated — the rule of "Duplicate" (26/07/2026), the rule of the recurring
operation created from an operation, the rule the transfer window follows when
it resets itself. A fiche left without validating produced nothing, so there is
nothing to find again, and one that gave back half a draft would mostly make
its author believe he had finished it.

**And it can be seen.** "Opened is blank" is checked at a glance. "Remembers
sometimes" is checked only by recalling what one did the time before — and in
F18 the two halves of the fiche were remembering in opposite directions: what
had been typed was lost, what had been chosen was kept, and which of the two
depended on whether Validate had been pressed before giving up.

**"From zero" is not "back to the bank's words"** — it is *the line as the
statement holds it today*. `statement_amend` is sent before any question, so a
correction confirmed with Validate and then abandoned at the duplicate question
has already entered the statement; the list refreshes with it, which is
Fabrice's own rule of 27/07/2026. The reopened fiche shows that corrected
label, and rightly: it belongs to the statement now. What returns to zero is
the classification, which never belonged to anything but the fiche.

**The fault was one of shape, and that is why it was missed.** In the transfer
window the reset is a named function two paths can call. In F18 it was written
*inside* the construction block: there was nothing to call, so nothing was
called. It is the third time this family has bitten — the title that did not
follow (P-14), the nomenclatures that did not reload, and this. The crossing
test can require a window to listen for its parameters; it cannot require it to
make itself new. Only a check written per window can, and F18 now has three.

## P-44 — The status is the bank's, the verification is the user's (03/10/2026)

**Decided.** An operation carries a second closed list next to its status:
`Verification` — 1 *À vérifier*, 2 *Vérifiée*, 3 *Douteuse*, 4 *Contestée*.
The status says what the bank did with the entry; the verification says what
the user thinks of it. Neither ever writes the other, and the verification
enters no balance and no statistic. Schema version 11.

**Why.** Fabrice, using the software, on 03/10/2026: an imported statement line
arrives *pointed*, and that is right — the bank has passed it. But *« j'ai
certains utilisateurs qui ne font pas confiance à leur banque […] ils
vérifient tout et conservent leur ticket papier. Pour eux pointé veut dire
qu'ils sont d'accord pour être débités, qu'ils reconnaissent la légitimité de
cette écriture »*. One word was carrying two facts, and the import was ticking
the second on the user's behalf before he had looked at anything.

**Three ways were on the table.** Importing as *engagé* cost nothing, but would
have made that status mean both "a cheque not yet debited" and "a line not yet
checked". A fourth status touched every balance, every switch and every
statistic. A separate field mixes nothing and moves no figure — Fabrice chose
it, and chose a list over a tick box: a box cannot tell "not looked at yet"
from "looked at, and it is wrong", and the second is the case these users care
about.

**The rules.**

- **Everything that is typed is verified.** The fiche, a transfer, a recurring
  operation, a template, a duplicate: the user wrote it, receipt in hand. The
  column's default is 2, so an `INSERT` that does not name it is right without
  knowing it exists — and a duplicate of a disputed entry is not disputed.
- **Only an import can be born "to verify", and only if asked.** A preference
  of the database (`verification_import`), two answers: 2, the default — nothing
  changes for whoever trusts his bank — or 1. *Doubtful* and *disputed* are
  judgements; an import carries none.
- **Operations already in a database are verified.** Otherwise ten years of
  history would ask to be checked the morning after the update.
- **A sub-operation has none of its own.** What is judged is the bank's line,
  and a ventilation is not one: it carries its mother's, pushed by
  `sync_from_parent`, and neither the list nor the core lets it be set.
- **A backup older than schema 11 restores as verified.** A value outside the
  list was first restored as verified too; P-45 corrects that the same day.
  `Verification` itself never travels: it is a frozen nomenclature, refilled by
  the software like `StatutOperation`.

**The migration is no migration.** The column has a default, so
`ensure_the_tables` adds it to a version-10 database on its own; the missing
table is created and refilled by `FROZEN`. No hand-written step, nothing to
replay if it is interrupted. A database is **not copied before being brought
up** — true of every step so far, and worth a decision of its own the day a
step rewrites data instead of adding to it.

**It is read by its colour** — black, dark green, dark orange, red, Fabrice's
choice. On the cell and on the closed list everywhere; the open list is drawn
by the system and macOS ignores colours there.

**A fault found on the way.** Debits were red by a style rule aimed at "the
eleventh cell" of a row. The « Statut opération » column, added two days
earlier, moved the debit to the twelfth, and debits went black without a test
noticing. A rule that counts cells breaks the day a column is added; the cell
now names itself (`list__cell--debit`) and a check holds the colour.

## P-45 — A seventh statistic, and what "no verification" means (03/10/2026)

**Decided.** The verification becomes a seventh axis of the statistics — four
rows, twelve months, amounts — on the template of the six. The detail under
the matrix carries a « Vérification » column in all seven. And a verification
that means nothing is *to verify*, never *verified*.

**The axis is the first that is not a nomenclature.** The six cross a list the
user manages; this one crosses a closed list of four. `Axis::nomenclature`
therefore answers `Option`, and two questions that used to be asked of the
nomenclature are now asked of the axis: `elements`, which gives the rows, and
`has_unclassified_row`. Everything else — the leaves rule, the switches, Somme
and Cumul, the cell and its detail — is untouched, which is the point of
having validated one statistic before deriving the others (26/07/2026).

**No « Sans vérification » row — and Fabrice's correction.** Every operation
carries a verification, so the row would always be empty. The first plan sent
a value outside the list to *verified*, by analogy with an old backup. Fabrice:
*« s'il devait y avoir une ligne qui serait sans vérification par erreur, elle
devrait être à vérifier ? »* He was right, and the analogy was the fault: they
are two different cases.

- **The field is absent** — a backup written before the question existed. The
  operation predates it and is *verified*, or ten years of history would ask to
  be checked.
- **The field is there and means nothing** — a damaged database, a file edited
  by hand. Nobody judged that entry; hiding it under *verified* would hide the
  very one to look at. It is *to verify*.

The rule is written once for the statistic, inside the axis's SQL expression,
so the matrix and its detail cannot count the anomaly in two different places.
The backup reader follows it: `0`, which is what an absent or empty field
reads as, restores as verified; any other value outside 1–4 restores as to
verify.

**The column goes in all seven, and that is the cheaper way.** The seven share
one page and one detail table: adding the column once puts it everywhere, and
restricting it to the new statistic would have needed a condition. Fabrice
asked whether "everywhere" cost more; it cost less. The crossed balance has a
copy of that table of its own and is left alone for now — decided apart.

**The shortcuts are renumbered.** The statistics take ⌘⇧1 to ⌘⇧7 in the order
of the menu, and the crossed balance moves from ⌘⇧7 to ⌘⇧8. Keeping it on 7
and giving the newcomer 8 would have spared a shortcut nobody had learned:
*« je préfère renumérotation car je n'ai pas encore publié »*.

**A fault it shipped with, and why no test saw it.** The window of the new
statistic opened empty the first time: no cell, keys in place of sentences,
"no account" in red. The page asks for its vocabulary under the name of its
axis, and `ui_texts` only knew nomenclatures — the two lists had coincided
exactly for as long as every statistic was a nomenclature. The request was
refused, and the window stopped before it had laid out anything. The browser
harness answers every `ui_texts` call, and the Rust test of the axis names
asked Fluent directly, so neither went through the counter where the refusal
was. `vocabulary_kind` now receives a nomenclature or an axis, and a crossing
test (`chaque_axe_des_statistiques_obtient_son_vocabulaire`) goes through it
for every axis. The lesson is the one of P-41: check at the door the call
actually passes, not beside it.

## P-46 — The verification joins the quick classification, as a draft (03/10/2026)

**Decided.** The verification is the seventh characteristic of F05: a column in
last position in the table, a tick box and its list under the status in the
banner. *« On ne change pas le principe de ce qui est dans cette fenêtre. »*

**So here, and only here, choosing a verification does not write it.** In the
operations list and in the statistics, the drop-down list writes at once. In
F05 it goes into the draft with everything else and waits for the diskette —
the rule Fabrice dictated for this window on 27/07/2026: one classifies fast
because no gesture is final. A seventh characteristic that wrote on its own
would have been the one cell of the window that could not be undone by
leaving.

**It follows the status, not the classifications.** `descends_to_children`
and `can_be_cleared` already separated the two kinds: what describes the bank's
movement — the payment mode, the status — goes down to the daughters and has
no « Non précisé » ; what describes what the money was for does not go down
and can be cleared. The verification is of the first kind: it judges the bank's
line. It writes neither the status nor the clearing date.

**The draft refuses a value outside the four.** The six others take what their
list offers and nothing checks them; a verification of 9 would have been
written to the database at the save, where nothing holds it back any more.
`Characteristic::accepts` stops it at both doors — the banner and the cell.

**The banner keeps its two columns.** Six pairs filled a grid of two columns
by three rows, column by column. A seventh, left to the automatic filling,
would have opened a third column. The grid now has four rows and the right-hand
column is named: from the fourth pair on, each is sent there and takes the
first free row. Naming only the fourth was tried first and put the project
under the payment mode — caught by the check that holds the six in place.

**And the list gets a horizontal scrollbar**, asked for in the same breath:
ten columns no longer fit in a narrowed window. It is `horizontalScroll` and a
`minWidth` per column, the mechanism of the operations list (21/08/2026) —
nothing new was written for it.

## P-47 — A window may add to its own right-click menu (03/10/2026)

**Decided.** The right-click menu of a table is common to every table of
Radinus and exports what the table shows. A window may now put entries of its
own at the head of it, each opening a sub-menu of choices. The operations list
is the first: « Vérification », then the four values, applied to the whole
selection.

**"Only at this place."** Fabrice: *« je veux modifier ce menu pour l'instant
uniquement à cet endroit »*. The menu therefore did not learn about
verifications; it learned to accept what a window hands it
(`MenuAddition`, in `export.ts`). A table that hands nothing has the menu it
always had — the check on the categories list still holds its ten entries word
for word, and would fail the day an addition leaked into it.

**The gesture is the Pointer button's.** A selection and one value. A selected
sub-operation stands for its mother, each mother is treated once, an operation
that already carries the value is not counted, and everything goes in one
transaction — a selection half-changed would not show on screen, which is what
would make it serious. The right-click does not move the selection: it acts on
the rows already taken, and with none taken the entry is greyed rather than
hidden, so that it says it exists and what it is waiting for.

**No sentence.** The plan had one — "3 operations set to Doubtful" — in
eighteen languages. Fabrice: *« je ne pense pas qu'il soit nécessaire de faire
une phrase »*. The table is reread and the colours change under the user's
eyes; that is the confirmation. Only a failure speaks.

**Then the detail of the statistics, the same day.** *« Il faut ajouter aussi
dans le menu contextuel la même option "Vérification" que dans le menu
contextuel de la liste des transactions d'un compte »* — wherever the column
is, so in the seven statistics. It was a matter of handing the same addition
to the detail's table: the menu already knew how to receive it, which is what
the mechanism was written for. The matrix above keeps its exports only, and
the crossed balance, whose detail has no such column, is not concerned. One
consequence is worth knowing there: the detail shows sub-operations in place
of their mothers, and judging a daughter judges her mother — so her sisters
follow, even those behind another cell.

**The sub-menu is drawn by Radinus, not by the system**, so the four choices
carry their colours on macOS too — which the drop-down list of the column
cannot do there. It opens to the right of its entry, and to the left when the
click was near the right edge of the window.

## P-48 — The operations list's right-click menu is three entries that open (03/10/2026)

**Decided.** In the operations list, and there only, the right-click menu is
« Statut opération ▸ », « Vérification ▸ », « Exporter vers ▸ ». Fabrice: *« en
premier, avant Vérification, nous allons créer une option "Statut opération"
qui pointera sur un sous-menu qui contiendra les options pointé, engagé, prévu.
Les options d'exportation seront déplacées dans un sous-menu, on y accédera via
l'option "Exporter vers". Ce nouveau menu ne concernera que la liste des
opérations. »*

**The status of a selection** is the gesture of P-47 with another value:
`operations::set_status_many`, one transaction, a sub-operation standing for
its mother, each mother once. It goes through `set_status`, so the clearing
date follows the one rule there is — pointé dates an empty field, and never
touches a date already there. No sentence, as for the verification.

**The exports are nested on request.** `onRightClick` takes an optional
`exportsUnder`: given, the ten formats go into a sub-menu under that name;
absent, they stay in a row. A table that asks nothing has the menu it had,
which is why the detail of the statistics and the nomenclature lists did not
move. « Exporter vers » is never greyed: exporting needs no selection.

**The short names are not translated.** Under « Exporter vers » the entries
read « Excel (.xlsx) », « CSV (.csv) »… They are proper names, the same in the
eighteen languages, and are written in `FORMATS` rather than in the language
files; only « Exporter vers » (`export-to`) is a translated text.

**A sub-menu of ten lines can leave the window by the bottom**, which the
four verifications could not: near the bottom edge it now opens upwards, as it
already opened leftwards near the right edge.

## P-49 — Each user his own columns: order, presence and widths are remembered (04/10/2026)

**Decided.** In the operations list, the user moves a column by dragging its
header, shows and hides columns from a right-click on the header row, and the
order, the hidden columns and the widths are remembered. Fabrice: *« en
fonction des utilisateurs et de leurs goûts personnels, tous n'utilisent pas
les mêmes colonnes, tous ne souhaitent pas le même ordre. […] Bien entendu il
faudrait un système très ergonomique. »*

**One layout for all accounts.** *« Je pencherais pour une disposition commune
à tous les comptes, ce serait la préférence de la fenêtre. »* Two lists open
side by side therefore show the same: saving sends `table-layout-changed`, and
every other table of that name rereads. A table does not reread its own echo.

**Stored in `Preferences`, one key per table.** Fabrice's own idea: *« on
pourrait utiliser la table de préférence, et proposer dans Paramètres →
Préférences simplement une réinitialisation des colonnes »*, then *« il
faudrait dans la base une préférence par tableau »*. A key more is not a
schema change: version 11 stays, an older Radinus ignores it, and the backup —
which carries the whole table — carries it. The list of tables is closed, in
the core (`TABLES_WITH_A_LAYOUT`): a name that is not in it writes nothing,
which is what keeps the rule of 03/08/2026 — nothing enters that table
unasked. The column width that the module quoted as the very example of what
does not slip in « au passage » came in that day, but asked for: *« on doit
aussi mémoriser la largeur des colonnes »*.

**One column always remains — whichever.** I had proposed that Date and
Libellé could not be hidden. Fabrice: *« plutôt que de préférer une colonne
proprement dite comme non masquable, on pourrait exiger à la place qu'il reste
simplement une colonne, n'importe laquelle »*. It is simpler and decides
nothing in the user's place; and it guarantees what matters — while a column
remains, a header remains, hence the right-click that brings the others back.
The last one is greyed in the menu. *« Au pire des cas il pourra toujours
aller dans les préférences. »*

**The « + » stays first and out of the menu** (agreed): hiding it would make
sub-operations unreachable. It is `fixed`; fixed columns come first.

**On any trouble, the table is reset.** *« En cas de problème il doit y avoir
une réinitialisation de la préférence au niveau du tableau. »* Two barriers:
the core deletes on read what does not parse or does not hold; the table
refuses what names a column it does not have, opens as born, and asks for the
key to be removed. Without a word — the user can do nothing about it and the
table is readable. **A column the layout does not name is not trouble**: it
was born after the layout was saved. It takes its born place, after its left
neighbour, and the rest is kept — resetting at every update would cost the
user his setting for a column he did not ask for.

**The reset is in two places.** In the header menu, because that is where one
stands when the columns are in a mess; in the preferences, as the net of the
one who no longer understands his table. The preferences list one line per
table, built from the core's list, plus « Tout réinitialiser »; the buttons
act at once, without the save button and without a question (agreed).

**Written once, in the shared table.** A window gives `layoutName` and an
`id` to each column; a table that gives nothing is exactly what it was. All
per-column state — filter, sort, width — is now kept by the column's born
rank, not its place on screen, so a moved column keeps its own.

**Pointer events, not the browser's drag-and-drop.** *« Il faut que ce système
soit compatible macOS, Windows et Linux. »* Native drag-and-drop behaves
differently in WebKit, WebView2 and WebKitGTK, and Tauri intercepts part of it
on Windows. The move is written like the width handle, which already works on
the three; the menu is drawn by Radinus, like the rows' menu. A move starts
after six pixels — under that it is a click, and a click sorts.

**Refused: fitting a column to its content by double-click.** Asked, *« comme
dans Excel »*; but the double-click on that line already gives the column its
born width back (25/07/2026), and the two cannot share a gesture. Fabrice:
*« non, alors on ne fait pas cela »*. The double-click is unchanged.

**Three things that follow.** Hiding a column clears its filter and its sort:
a filter acting with nothing on screen to say so hides rows for no visible
reason. The right-click export follows the columns shown — a table exports
what one reads. And once a width has been pulled, a column left in `fr` gets
a floor (`minmax(min, fr)`): among columns frozen in pixels it received what
was left, that is nothing as soon as the table overflowed, and it was there
without being seen — which, now that the layout is remembered, would have
lasted from one opening to the next. A handle merely clicked no longer
freezes anything, for the same reason.

## P-50 — The detail of the statistics and of the crossed balance: one layout per statistic (04/10/2026)

**Decided.** The columns of the list at the bottom of the seven statistics and
of the crossed balance are the user's own, as in the operations list (P-49).
Fabrice: *« le même principe dans tous les tableaux des fenêtres statistiques :
mais attention, pas n'importe lesquels. Je parle des tableaux qui listent les
transactions lorsque l'on clique sur une cellule. Ceux du bas de la fenêtre. »*
The matrix above is not concerned, in any of these windows.

**One layout per statistic.** I had proposed a single layout for the seven —
they share one page and the same eleven columns. Fabrice: *« une disposition
par statistique »*. The page therefore names its table after its axis
(`statistics-<axis>`), and the core lists the seven names; a test holds that
list against `statistics::AXES`, so an eighth axis without its name fails
there instead of quietly forgetting its columns. Two windows of the same
statistic stay in step; two different statistics do not hear each other.

**The crossed balance is in, with the « Vérification » column.** *« Inclus la
colonne Vérification, et inclus les modifications sur les colonnes. »* It had
been left aside on 03/10/2026 (« décider à part pour le bilan croisé »). The
column is the one of the statistics, at the same place, with the drop-down
list and the right-click entry. Nothing was needed below the window: the
detail already arrived with each operation's verification.

**No fixed column here.** There is no « + » in these lists; the eleven columns
move and hide, and one always remains.

**The preferences name each table by its menu entry.** Nine lines now. The
detail of a statistic is called what its window is called in the general menu
— « Stat par catégories » — which is how the user knows it, and which already
exists in the eighteen languages: nothing was translated a second time. The
controller hands the label with the name; the window composes nothing.

**The amount is red by its class.** The stylesheet coloured « the last cell
but one » of a debit row; a column that moves cannot be counted. The cell now
names itself (`list__cell--amount`). To know: a later rule written for the
reconciliation (`.list__row--debit .list__cell`) also tints the *whole* debit
row in this detail, and has since it exists — that is what the screen shows,
and it was left as it is.

## P-51 — The preferences reset the tables of a *window*, chosen in a drop-down list (04/10/2026)

**Decided, and it corrects P-49 and P-50.** The « Colonnes des tableaux » leaf
is a drop-down list that names a window, one « Réinitialiser » button beside
it, and « Tout réinitialiser » below. No label before the list.

**The fault.** I had written one line and one button per table. With the
statistics and the crossed balance that made nine lines and nine buttons, and
one more for every table to come. Fabrice: *« tu as fait un truc un peu bête
au niveau de l'ergonomie. […] ça fait beaucoup de boutons et de lignes pour
rien. Il aurait mieux valu mettre un menu déroulant indiquant le nom de la
fenêtre et un bouton réinitialiser qui pointe sur le menu déroulant. »* An
action this rare does not deserve a button per object; a list that grows
costs nothing, a column of buttons does.

**Windows, not tables.** *« Il s'agit du nom de la fenêtre, on réinitialise
les tableaux contenus dans une fenêtre. Demain il peut y en avoir plusieurs
dans une fenêtre. »* The button sends the window's name
(`reset_window_table_layouts`) and the core knows which tables it holds.
Today each window holds one, named after it; the day a window holds two they
will be named `<window>.<table>` — `preferences::window_of` already reads
that — and neither the preferences nor the keys already stored will change.

**No label.** I had asked whether « Tableau : » should precede the list.
*« Tu mets simplement le nom de la fenêtre et réinitialiser, je pense que ça
sera suffisamment clair. »* Nothing new was translated.

## P-52 — The Filtre menu: two filters that combine, one choice in each (05/10/2026)

**Decided.** The Filtre menu of the operations list is « Toutes les
opérations », a rule, « Filtre Statut ▸ » and « Filtre Vérification ▸ ».
Fabrice: *« on mettra un séparateur en dessous de "Toutes les opérations", puis
une option Filtre Statut, avec comme sous-menu uniquement les opérations
pointées, engagées et prévues. C'est juste un changement ergonomique. […] En
dessous on va rajouter Filtre Vérification, avec en sous-menu les options
présentes dans la table Vérification. »*

**One per sub-menu, and they add up.** *« On pourra combiner, choisir
opérations pointées et filtre À vérifier, il pourra donc y avoir deux éléments
cochés mais un seul par sous-menu. »* The core applies both
(`operations::list_for_account`), on the mothers, like the period: the foot of
the window adds up what the table shows. A verification outside the list — a
damaged database — is kept by « À vérifier », as in the statistic by
verification: the filter that exists to find what nobody has judged must not
miss it.

**« Toutes les opérations » unticks everything** — *« pour rester cohérent »* —
and is ticked only when no filter acts. The ticks are read from the two
filters themselves, never from a remembered click.

**Three things agreed on my proposal.** A second click on a ticked choice
lifts it: without that, dropping one of the two filters would mean lifting
both and ticking the other again. The entry of a sub-menu is ticked while a
choice is made in it, so one sees what filters without opening anything. And
the filter is not remembered from one opening to the next, as before.

**« Afficher tout » at the head of each sub-menu, the same day.** Fabrice:
*« c'est bête mais j'ai peur que les utilisateurs âgés ne comprennent pas si on
ne le met pas »*. He was right, and not only for them: the second click was
the only way to lift one filter, and nothing in the menu said so. The entry
lifts the filter of its own sub-menu and is ticked when no choice is made
there — so each sub-menu always shows exactly one tick. The second click was
kept: it costs nothing to those who do not know it.

**The verifications are put in the menu when it opens**, not when it is
built: the menu bar is built with the window's words, before the database has
handed its lists, and a sub-menu filled then would be empty until the first
change of language.

## P-53 — A column can be tinted; the header menu becomes two sub-menus (05/10/2026)

**Decided.** The right-click menu of a table's header row is « Afficher/Masquer
▸ », « Colorer la colonne : … ▸ », a rule, « Rétablir les colonnes par
défaut ». Fabrice: *« il y aurait un menu Afficher/Masquer qui contiendrait un
sous-menu avec le menu actuel. Et en dessous il y aurait une option Colorer,
lorsque l'on cliquerait sur cette dernière on aurait le choix entre des
couleurs »* — nine, in his order: rouge, orange, rose, vert pastel, vert, bleu
pastel, bleu, jaune pastel, jaune. And *« Aucune couleur »* at the head, which
I had proposed, on the model of « Afficher tout » in the Filtre menu.

**A transparent layer.** His words: *« comme un calque transparent de couleur
qui s'applique dessus »*. The tint is a background *image* over the cell, so it
adds to what the row already shows — the alternation, the blue of a
sub-operation, the selected row — instead of replacing it, and the red of a
debit and the colours of the verification stay readable on top. A tinted cell
takes the full height of its row: left at the height of its text it drew a
dotted column, not a band.

**« Colorer » acts on the header that was clicked, and says so.** A menu that
tinted « a column » without naming it would aim wrong half the time. The label
comes whole from Fluent, colon included, and the column's title follows it —
a substitution, as for an error message, not a composition. On the « + », or
beside every header, the entry is greyed.

**The database keeps a name, never a colour code.** `colors` in the layout
maps a column to one of nine names; the core refuses any other. What « rouge »
looks like is one line of the stylesheet, read by the cell and by the swatch
of the menu alike — Fabrice will judge the tints on his screen, and adjusting
one must not touch a single database. A test holds the four ends together:
core, table, stylesheet, and the eighteen language files.

**A layout stored before the colours still reads.** The field defaults to
empty. Without that, the first opening after the update would have rejected,
then deleted, the layout the user had made the day before.

**Agreed on my proposals.** The header is not tinted — sort marker and
magnifier stay readable. Neither the exports nor the PDF carry the colours: a
mark on the screen, each user's own. « Rétablir les colonnes par défaut »
stays at the first level, since it puts everything back, colours included. The
ticks leave the menu open; choosing a colour closes it, since one picks only
one.

## P-54 — « Analyse Évolution du solde »: a zone dragged on the chart, and its operations (05/10/2026)

**Decided.** A new window, F40, under « Graphique Évolution du solde » in the
Statistiques menu. Fabrice: *« On va faire une nouvelle fenêtre. Tu vas partir
de l'exemple de la fenêtre qui montre "Graphique Évolution Solde". […] En bas
de la fenêtre on aurait le même tableau qui détaille les transactions que dans
les statistiques catégories. Ce que je voudrais, c'est que lorsque
l'utilisateur clique sur le graphique et maintient la souris appuyée, il trace
le début et la fin d'une zone temporelle. On pourrait imaginer une barre
verticale, puis au fur et à mesure que l'on maintient le clic en avançant on
colore une zone, et à ce moment-là le détail des opérations apparaît dans le
tableau du bas pour les comptes qui avaient été sélectionnés. »*

**Two windows, and F25 is not touched.** I asked whether the zone and the
table should simply be added to the existing chart. *« Je veux deux fenêtres
distinctes. Tu ne touches pas à Graphique Évolution Solde : car on se
concentre sur le solde. Analyse, c'est une vision plus approfondie. »*

**The chart's drawing is copied, not shared — his ruling, against my
recommendation.** I proposed to move the drawing into a module both windows
would use; a fix of the line would then hold for both. *« Recopie le code pour
qu'il soit indépendant. »* So `balance-analysis.ts` carries its own copy, and
says so at its head. The cost is known and accepted: a correction of the
drawing is to be made twice. A crossing test holds the independence — neither
page imports the other, and F25 knows nothing of the zone.

**The zone is computed beside the curve.** `balance_curve::zone` uses the
curve's own definition of the balance: the account's three carried amounts
plus its first-level operations, with no status filter. The opening balance is
that of **the evening before the first day** (agreed), the closing balance
that of the last day, and the change is therefore, to the cent, the sum of the
rows shown. Two definitions in two modules would have drifted, and an analysis
whose detail does not add up to its total is worth nothing. The curves
themselves come from F25's command — it is the same computation.

**Mothers, and a « Compte » column.** The detail of the statistics shows
sub-operations in place of their mothers; here it is the bank's entry that
moves the balance. *« Je pense qu'il faut montrer les mères aussi. Colonne
Compte : oui. »* The rest is the statistics' detail — and that table too is a
copy, for the same reason as the chart.

**The gesture.** Pressing sets a bar on the day under the pointer — the
nearest day, the one the hover bubble names. Dragging stretches a veil, either
way, and the two dates follow the hand; **the table is read on release only**,
since rereading it at every pixel on an account of several thousand operations
would make the gesture stutter. Past the edge of the chart the zone stops at
the edge instead of being dropped. A click takes one day. Pointer events with
capture: the same code on the three systems, mouse and trackpad alike. The
zone stays until another is drawn, survives a reread (an operation edited
below changes neither its dates nor its place), and is cleared when the
period, the year or the accounts change — it would no longer mean the same.

**No shortcut**, as agreed. I had told Fabrice that the chart had none; that
was wrong — it has ⌘G, and the dashboard ⌘T. ⌘⇧9 is free if one is wanted.

## P-55 — Copying a cell, copying rows (07/10/2026)

**Decided, after a user's remark.** Fabrice: *« Je viens de me rendre compte
d'une chose très bête à la suite d'une critique d'un utilisateur. On ne peut
pas faire de Copier de ligne/cellule dans un tableau. »* It was true
everywhere: rows are not selectable as text — click and drag takes rows, not
letters — and nothing copied. To take one amount out of a list, one had to
export it to a file.

**Three rulings.** No column titles in what is copied. Amounts *« en nombre
pur »*. *« Tous les tableaux d'un coup »* — the mechanism is the shared
table's, so every list has it; and « Copier la cellule » alone in the
matrices of the statistics and of the crossed balance, where one picks a
single cell.

**What « pure number » means.** The currency sign and the grouping go, the
decimal separator stays the language's: it is the one the user's spreadsheet
expects, and what makes it read a number rather than a text. The conversion
is made from the text shown (`clipboard.ts`, `pureNumber`), on number columns
only — « 3,14 kg » in a label is a label. An amount is recognised by its two
decimals; a cheque number grouped by three, a date, a year come back as they
are.

**Rows as one sees them.** In the order of the screen, with the columns
shown, in their order — the rule of the export. Tabs between cells, line
breaks between rows; a cell's own tabs and line breaks become spaces, or a
comment on two lines would shift everything after it.

**On the key itself, not on the browser's « copy » event.** Radinus has no
Édition menu, and without one WebKit does not send that event. The table
listens for ⌘C / Ctrl+C and steps aside whenever the user is copying
something else: in a field, a drop-down list, or with text highlighted. With
Shift or Alt it is not the copy key — AltGr on Windows *is* Ctrl+Alt.

**Two ways to the clipboard.** The modern interface first, which may be absent
or refused; then the old copy command on a text area set down for the time of
the gesture. Neither is certain in the three engines Radinus lives in, both
are called during a user's gesture. If neither writes, the window says so.
None of this could be checked against a real clipboard from here: the checks
hold what is sent, not what the system does with it.

## P-56 — « Soldes de vos comptes » gets its right-click menu; six tables stay without (07/10/2026)

**The fault.** Fabrice: *« Il n'y a pas de menu contextuel sur ce tableau.
Aucun moyen de faire un copier de cellule ou de ligne. Aucun moyen d'exporter
le tableau via menu contextuel […] bref absence totale de menu contextuel. »*
The window uses the shared table and had never called `exportOnRightClick` —
one line, missing since the window was written, which nothing reported because
the table works perfectly well without it. And P-55 said « every table » for
the copy without my having checked that every table had a menu to put it in:
⌘C worked there, the two menu entries could not appear.

**Corrected for that window**: the menu, the name of the window on the
exported file, and its three balances exported as numbers, like every money
column.

**Six other tables are in the same state, and stay so by his choice.** Asked
whether to switch them all on, Fabrice chose the balances alone. They are the
attachments manager, the database selector, the two tables of the CSV
statement, the Excel import, the Excel association, and one of the two tables
of the Excel fields. ⌘C copies their selected rows — that lives in the shared
table — but they offer no right-click menu.

**A crossing test now holds the line**
(`tout_tableau_a_son_menu_du_clic_droit`): every page that builds a table must
switch its menu on, except those six, named in the test. A window added
tomorrow that forgets the line fails there.

## P-57 — The welcome window's accounts: one row, a tick box, an order; and a reset of the comfort settings (07/10/2026)

**Asked by Fabrice**, in three sentences. *« Lorsqu'on rétrécit la fenêtre
j'aimerais un ascenseur horizontal pour faire scroller les comptes. »* *« Avant
chaque nom de compte […] je veux une boîte à cocher. Le but sera de faire
comptabiliser ou non les soldes dans les 3 zones carrées du dessus […]. Les
carrés pourront aussi être déplacés par drag and drop et réordonnés dans cette
zone. Évidemment cela sera mémorisable dans les préférences. »* And for the
preferences: *« il faut avoir un bouton pour remettre à zéro les réglages de
confort mais pas le reste »*.

**This revises P-8.** P-8 said the welcome window takes no setting and
remembers nothing from one opening to the next; P-8 bis already let it be
leafed through. It now keeps two things in the database: the order of its
tiles and the accounts it does not count. It is still the view that answers
without a click — nothing has to be set for it to answer — but « nothing is
remembered there » is no longer true, by the decision of the one who wrote the
rule.

**One row, and a scrollbar.** The tiles no longer wrap: eleven accounts used
to push the two rings off the screen. They widen while there is room and never
go under their born width; past that the row scrolls inside its card.

**The tick box.** Ticked at birth. Unticked, the account leaves the three
totals **and the two rings** — asked whether the rings should follow, Fabrice:
*« oui ils doivent suivre les cases à cocher »*. The tile stays, set back, and
still opens its operations; ticking is not opening. As soon as one box is off,
the line under « Solde en banque » says so — « Comptes comptés dans les
totaux : 3 sur 5 » — because a total that leaves something out without saying
it is a wrong total for whoever forgot the box. With every box off the totals
are zero and the rings empty. « Soldes de vos comptes » is not concerned: its
TOTAL line is still every account.

**The order.** A tile is taken and put down elsewhere in the row, with the
same gesture and the same mark as the columns of the tables — pointer events,
not the browser's drag and drop, for the same reason: macOS, Windows and
Linux. Under six points it is a click and the account opens. A new account
arrives last and ticked.

**Stored under one key, `accueil.comptes`**, in the `Preferences` table of the
database: the order and the exclusions belong to the accounts of that
database. The welcome window sends both at each gesture; the core recounts.

**« Réinitialiser les réglages de confort »** — a new leaf of the preferences,
under its own branch « Réinitialisation ». It puts back the columns of every
table, the welcome window's order and boxes, and the display size. **Not the
language, not the currency, not the verification of imported operations**:
those change what Radinus writes or shows as data. It is the only reset button
that asks first, because it undoes at once what took weeks to adjust. The
display size lives on the machine and not in the database: without an open
database the button still resets it, and that alone.

**Not verified here**: the gesture and the scrollbar on a real macOS, Windows
and Linux window. Touch screens scroll the row with a finger and cannot
reorder by touch.

## P-58 — F41, the credit simulation: a calculator, and what the history says (08/10/2026)

**Asked by Fabrice**, who said he knew little about loans and asked to be
listened to. He brought a consumer-loan simulation from La Banque Postale
(12 000 €, 6,41 %, 22 months, 120 € of fees, 9,50 € of insurance a month:
585,36 € a month, APR 7,73 %), and described its tool: three sliders, each
doubled by a text field — amount, wished monthly payment, term — that move one
another. Then: *« calculer un crédit c'est bien, mais aurait-tu une idée au
regard de l'historique disponible dans Radinus pour conseiller la personne sur
ses facultés à rembourser le crédit […] savoir si c'est jouable ou pas et dans
quelle mesure »*, *« je veux quelque chose de chiffré mais aussi de visuel »*,
a printable PDF report, and *« quelque chose de beau qui fasse classe »*.

**What he settled, point by point.** Fixed rate only (« on reste sur du
fixe »). The term in months. Consumer or mortgage from a drop-down; the
sliders stop at 75 000 € / 84 months and 500 000 € / 360 months, the text
fields at 100 million and 600 months (« la limite des curseurs n'est pas la
limite des champs textes »). Amount or term moved → the payment follows;
payment moved → the term follows, rounded up to the whole month, and the
payment is readjusted on it. Menu Divers, under the calculator. The accounts in
a table with a tick box each; the period from a drop-down: last 12 months, or
the calendar year N down to N-5. Two tabs. The verdict thresholds as proposed.
A PDF report button always visible; the schedule in full for a consumer loan,
year by year for a mortgage unless « Tableau mois par mois » is ticked. No
mock-up: « Go, Code! ».

**The method — he asked for it: « tu calcules avec ce que tu as comme tu peux.
Il faudra me dire ta méthode. »**

- *The loan.* Monthly rate = annual rate ÷ 12. The fees are financed — added
  to the principal — as La Banque Postale does. Each month's interest is
  rounded to the cent and the last payment clears the balance. The APR is
  actuarial: the monthly rate that equates what is received (the amount, not
  the fees) with the payments, compounded to the year; optional insurance is
  outside it. On his own simulation Radinus gives 585,38 € and 7,74 %: two
  cents and one hundredth apart, because the bank counts its first instalment
  « à 30 jours » on a 365-day year and Radinus counts whole months. Said to
  him, and written in the module.
- *The history.* Mother operations only; cleared and committed only (a
  planned operation in the past did not happen); the operation's date, or its
  clearing date. Complete months only: « last 12 months » are the twelve
  finished months before the current one; year N runs to the last finished
  month, so the test reads « 2 months out of 9 » in October.
- *Transfers between own accounts.* Radinus does not mark them, and imported
  ones are linked to nothing. They are recognised by pairs: a debit on a
  ticked account and a credit of the same exact amount on another ticked
  account, at most five days apart; each operation serves once, with the
  nearest. A pair counts as neither income nor spending. A transfer to an
  unticked account counts as spending — the money leaves what is studied.
- *Current loans.* Their payments are already in the spending, since they were
  paid. They are needed apart only for the debt ratio and the projection.
  Recognised among the recurring operations of the ticked accounts: a rule
  that debits, monthly, quarterly or yearly, and that ends — at a date, or
  after a number of repetitions — after today. A rent or a subscription has no
  end; a loan has one. Labels are never read. The window lists what it
  retained.
- *The figures.* Average income and spending; debt ratio = (current loans +
  new payment with insurance) ÷ average income; left to live on = income −
  spending − new payment; months in the red = months of the period where that
  would have been negative; projected balance = today's real balance of the
  ticked accounts, plus each month's average saving, minus the new payment,
  plus a current loan's payment once it has ended.
- *The verdict.* Green: ratio ≤ 33 %, left to live on ≥ 0, no month in the
  red. Orange: ratio up to 35 %, or one or two months in the red. Red: above
  35 %, left to live on negative, three months in the red or more, or no income
  at all.

**One drawing for the screen and the paper.** The charts — gauge, two rings,
bars, two curves — are SVG written by the core (`loan_charts`), set as they are
in the window and given to Typst for the PDF. A screenshot would have depended
on the system and the window's size. The gauge's needle glides between two
angles the core gives; it is the window's only arithmetic, and a crossing test
holds that it does no other.

**Nothing is stored** — « une calculette ». No new preference key except the
layout of the schedule's columns, under the existing mechanism
(`tableau.loan-simulation`). The accounts are named by their label only, never
by their number, on screen and in the report.

**Not verified here**: the window on a real macOS, Windows and Linux; the PDF
opened by each system's viewer; the slider gesture under a real hand.

## P-59 — The verdict of F41 judges the loan, not the past (08/10/2026, revising P-58)

**The fault, found by Fabrice the same day.** *« Même emprunter 100 euros sur
74 mois […] la jauge me donne un pourcentage d'endettement réaliste, cependant
dans l'encadré "En résumé" il me dit "Risqué" […] avec 0,39 % d'endettement il
me dit risqué. »* The rule of P-58 put the voyant to red when the average left
to live on was negative or three months were in the red — whatever the loan.
Both judged the history: a household that already spends a little more than
it earns over the period, or that has three heavy months a year (taxes,
holidays, a big purchase), was « Risqué » for a loan of one euro. Fabrice:
*« il faut faire mieux à ce niveau »*; on the rule below, *« essaye, on
verra »*.

**The voyant now answers three questions, each about what the loan
changes**, and takes the worst of the three answers:

1. **Is the debt ratio reasonable?** Unchanged: green up to 33 %, orange up
   to 35 %, red above (and red without any income).
2. **Does the payment fit in what an ordinary month puts aside?** The
   ordinary month is the *median* of what each month of the period left —
   a one-off purchase or bonus no longer skews it. Green if the payment takes
   at most half of it, orange up to all of it, red beyond. When an ordinary
   month puts nothing aside, the question has no object: its dot is grey and
   the third question judges.
3. **Does the balance hold to the end?** The projection is made twice, with
   and without the loan. Green if it stays positive. Red if it goes below zero
   *because of* the loan — without it, it would hold. If it would go below
   zero anyway, the loan is judged on how much sooner it makes that happen:
   less than 3 months, green; 3 to 11, orange; a year or more, red. Without
   the loan the projection looks beyond the loan's last payment, so that a
   balance about to fall a month after it is not « saved » by the loan that
   makes it fall a month earlier.

**What became information and not judgement.** The months in the red are
counted only when the loan tips them — positive without it, negative with it;
on the bars, a month already in the red without the loan is pale red, a
month the loan tips is bright red. A history already in deficit before any
loan is said in a warning of its own, above the charts: « vos dépenses
dépassent déjà vos revenus de … par mois en moyenne, avant tout crédit ».

**Each answer is written under the verdict**, with its dot, on screen and in
the report: one sees why the verdict is what it is.

With this rule, 100 € over 74 months is « Jouable », with the warning if the
history is in deficit — the case a test now holds.

## P-60 — Three ways of judging a loan: optimistic, neutral, severe (08/10/2026)

**Asked by Fabrice**, the evening after P-59: *« pourrait-on garder ta méthode
de calcul et en faire deux autres : une plus sévère et une moins sévère. Le
but c'est de donner au final trois méthodes de jugement […] En fonction de son
choix la personne pourra mieux évaluer ses risques. Mais il faudrait être
explicatif. »* Then: a third tab, « Réglages du jugement », showing the table
with a choice to make.

**The same three questions, three levels of demand.** P-59 is the neutral
method, unchanged except for the rise in spending below.

| | Optimistic | Neutral | Severe |
|---|---|---|---|
| Debt ratio: green up to / orange up to | 35 % / 40 % | 33 % / 35 % | 30 % / 33 % |
| Reference month | a good month (better than 3 in 4) | an ordinary month (the median) | a difficult month (worse than 3 in 4) |
| Share of its savings the payment may take | 3/4 / all | 1/2 / all | 1/3 / 2/3 |
| Level the balance must not fall below | zero | zero | one month of average spending |
| Brought forward even without the loan: orange / red | 6 / 24 months | 3 / 12 months | 1 / 6 months |
| Rise in spending per year, to start with | 0 % | 2 % | 3 % |

The reference month is read as a rank among the months of the period —
the 75th, 50th or 25th percentile of what each month left — between its two
nearest neighbours.

**The rise in spending.** Prices rise, the payment does not: on a long loan
the gap counts. Fabrice did not follow the first wording, which was explained
to him; he then asked for *« un champ texte numérique (supérieur ou égal à 0)
[…] compris comme étant un pourcentage »*, **one per column**, from 0 to 99, a
whole number. The rise applies month after month to the average spending in
the projection, the income and the payment staying as they are; it does not
touch the history.

**Explanatory.** The third tab shows the table with the person's own figures
(« un mois difficile : 275,00 € », « un mois de dépenses : 2 129,17 € »), a
radio button at the head of each column with that method's verdict for the
loan in a coloured badge, the chosen column set off in gold, the rise fields
in the last line, and under the table one sentence saying what the chosen
method assumes. The verdict of the second tab follows the chosen method, and
says which one in a small button that opens the third tab. The gauge's zones
follow the method's thresholds; the severe method's safety reserve is drawn as
a dashed red line on the projected balance. The PDF report gives the chosen
method's verdict and detail, the three verdicts in one line, and the sentence.

**Neutral by default, nothing remembered** (« choix mémorisé : non »): the
method and the three percentages come back to their starting values each time
Radinus starts. No preference key.

## P-61 — A main menu « Outils », between Nomenclatures and Paramètres (09/10/2026)

Fabrice: *« Nous allons déplacer l'option du menu "Simulation de crédit". Nous
allons créer une nouvelle option principale entre Nomenclatures et
Paramètres : Outils. »* The credit simulation leaves Divers, where P-58 had
put it under the calculator, and becomes the only entry of the new menu. Like
Comptes or Statistiques, the whole menu is greyed until a database with at
least one account is open — its entry reads the history. The text key follows
the move (`menu-tools-loan-simulation`), and so does the window's name in the
preferences' list of tables.

## P-62 — « Consommation d'un appareil électrique », and the electricity tariff as a preference (09/10/2026)

Fabrice: *« Évaluer combien coûte la consommation d'un appareil électrique. »*
A second entry in Outils, under the credit simulation. Three rulings shaped
it. **No list of appliances and no assumed value** — *« je suis contre les
tableaux d'appareil et liste d'appareil courant, parce que tu ne peux faire
que des hypothèses : tu n'as pas les chiffres réels. Moi je veux un résultat
réel »*: every figure about the device is typed by the person, the fields
start empty, and a note says that the power on the plate is a maximum and that
a plug-in power meter gives the real one. **An honest result** — *« qui
tienne compte de la consommation allumée, ou en veille, mais aussi coût heure
creuse ou heure pleine »*: running and standby are counted apart; on days
without use the appliance stays plugged in and all that time is standby;
running time is split by the share the person gives, standby by the number of
off-peak hours in the day, since it runs day and night. The standing charge is
left out: it is paid whether the appliance is plugged in or not.

**The tariff is a preference of the database**, key `tarif.electricite`,
asked for by Fabrice (*« on pourra mémoriser cela, cela sera enregistré en
tant que préférences et modifiable dans le panneau de paramètres /
préférences »*) — the rule of 03/08/2026 is kept. It defaults to EDF's Tarif
Bleu (*« on prendra le tarif actuel par défaut en France »*), prices
including tax on 1 August 2026: Base 0,2001 €/kWh for a 3–6 kVA meter; peak
0,2142 €, off-peak 0,1589 €, 8 off-peak hours. These prices change, usually
in February and August: they are to be checked at each release. A new branch
« Outils » in the preferences carries the leaf « Tarif d'électricité », with
« Revenir au Tarif Bleu EDF », saved with the disk like everything else
there. Prices changed in the calculation window apply to that calculation
only (« Fait selon ta sagesse »): the window is a calculator, and a price
tried for a comparison must not overwrite the contract. Not a comfort
setting: the comfort reset leaves it alone. **No PDF report** (*« Pas de
rapport PDF pour cela »*).

## P-63 — « Mon matelas de sécurité » (09/10/2026)

Chosen by Fabrice among several proposals (*« j'aime bien : Mon matelas de
sécurité »*), after setting aside a buy-or-lease car comparison (*« trop de
paramètres »*) and a heating calculator. Its rulings: spending categories can
be **unticked** (what one would cut in a hard time); a **fallback income**
field (*« oui »*); the running loans are **not** shown apart (*« non »*); the
thresholds are **fixed** at 3 and 6 months, the usual rule of prudence; **no
PDF report**; in **Outils**. Nothing is stored. Method choices made on the
way: transfers are recognised on all the accounts of the database, not only
the ticked ones — moving 200 € to an unticked livret is not spending; a
ventilated operation counts by its daughters, as in the statistics; the
saving pace is what the savings accounts gained on average per month over
the period, received transfers included; the projected savings stop at zero,
because below it the curve would be a debt. The default ticks follow the
account type: a cheque account for spending, a livret or CEL for savings; a
PEL, PERP or term account cannot be drawn on without breaking it, so it is
left unticked, as is « Autres ».

## P-64 — « Objectif Épargne » (10/10/2026)

Fabrice: *« si je continue au rythme actuel, dans combien de temps aurais-je
tel solde et combien aurais-je épargné, ou la question inverse : combien de
temps épargner pour arriver à tel montant »*. Rulings: **the three
questions** (when, how much at a date, how much per month); **a range**
around the probable answer, from the lowest and highest quarter of the
months; **loans ending** free their instalment afterwards; an optional
**annual rate**, counted monthly — an approximation of the fortnight rule of
livrets; an optional **extra effort**; in Outils, no PDF, nothing stored.
Then, on the history: *« peut-être faudrait-il rajouter une option d'année
type ou moyenne sur une plage d'années »* — so the period menu gains **a
range of years**, and the projection always follows **the typical year**:
each coming month takes the average of the same calendar months of the
period. Bringing the range of years to the credit simulation and the safety
cushion is left for later (*« on fera ça plus tard »*). The name is
Fabrice's: *« Objectif Épargne est très bien »*. Method choices on the way:
a transfer between two followed accounts cancels out, one to an account not
followed is money going out; the shown past is the real balance at the end
of each of the last twelve months, computed back from today's.

## P-65 — The range of years in the credit simulation and the safety cushion (10/10/2026)

Left for later in P-64, then asked for: the period menu of « Simulation de
crédit » and « Mon matelas de sécurité » gains the range of years of
« Objectif Épargne » (`loan::Period`, now shared by the three tools). The
typical year is applied to the credit simulation's projected balance
(*« oui appliquer l'année type, je suis d'accord avec toi »*), not to the
cushion, which looks at a hard blow rather than at the seasons. The bars of
« Votre historique avec ce crédit » keep one bar per real month even over
five years — up to 69 thinner bars, at most twelve labels — rather than
twelve averaged bars: the real months that would have gone red are the point
of that chart (*« fais comme tu penses que c'est le mieux »*). One test had to
change: with the typical year, the severe method's reserve now holds in a
history whose next months are its strongest.

## P-66 — « Et si je réduisais… ? » (10/10/2026)

Fabrice: *« imaginer que l'on réduise en pourcentage ou en valeur les
dépenses d'une ou plusieurs catégories et voir l'impact sur une projection
dans le futur »*. Rulings: items **by categories, payees or budget lines**,
at choice; **a window of its own** (*« c'est un nouvel outil »*) with an
optional target amount; the horizon on **a slider from 1 to 10 years**; an
optional **interest rate**; the cuts **forgotten when the window is closed**
(*« on oublie les chiffres à la fermeture de la fenêtre pour l'instant »*) —
nothing enters `Preferences`; and, first refused then asked for, **a PDF
report** (*« ça peut être complexe à saisir et c'est une façon de sauvegarder
les infos »*), which therefore carries everything needed to type the cuts
again. Method choices: the projection is that of « Objectif Épargne »; a cut
never exceeds the spending; a cut follows the seasons of its item (−20 % on
an item that weighs in summer saves in summer); transfers between followed
accounts are not spending; a ventilated operation counts by its daughters.
The table hint names the currency in use, so it is written by the
controller, not the view.

## P-67 — « Préparer mes vacances » (10/10/2026)

Fabrice first set aside a richer planner (past trips by project, a saving
plan against the history): *« le but c'est simplement de calculer combien vont
me coûter mes prochaines vacances »*. Then, item by item: people on **a
slider from 1 to 20**; the nights, the months before departure; transport,
accommodation, meals, visits, other costs, each **« for everyone » or « per
person »** and **per night / per day / for the stay** (*« paramétrable »*);
the result **per person, per person per day, still to fund, saving needed
per month**; **a stay or a cruise** (*« ok »*), with the cruise's own items
(cabins, service charge, drinks package, excursions per port of call, port
taxes, wifi); **all the optional lines** (*« on garde tous »*); **adults and
children** (*« oui »*) — a child price beside each per-person line, empty
meaning the adult price; the already saved as **the balance of one or more
chosen accounts**; **a PDF report** and **an Excel export**; everything
**forgotten when the window is closed**; and, his idea, **projects saved and
reopened as JSON files** (*« ça évite de tout retaper »*), the ticked
accounts found again by label (*« on laisse coché »*). Method choices: days
are nights plus one; the tourist tax counts adults only; the insurance
percentage applies to the main items, the bank fees percentage to on-site
spending; the monthly saving is rounded up to the cent; amounts in the JSON
file are written neutrally so a project saved in French reopens in English;
a newer file version is refused rather than half read.

## P-68 — « Et si je réduisais… ? » keeps its projects in files (10/10/2026)

Fabrice: *« dans l'outil “Et si je réduisais ?”, rajoute enregistrement et
chargement JSON et aussi export Excel »* — what F46 already does. P-66 still
holds: the window forgets everything when closed, and nothing enters
`Preferences`; the file is the memory one chooses to keep. Method choices,
those of P-67: amounts written neutrally, a newer version refused, the
accounts by label only, the picker opened on the Rust side. Peculiar to this
tool: each cut carries the **label** of its item beside its key, because keys
differ from one database to another; on opening, the key is kept if the label
still matches, else the item is found by its label, else the cut is dropped.
The « unclassified » line keeps its key. The workbook writes values, not
formulas, like the other exports.

## P-69 — The tools' door asks before forgetting (10/10/2026)

Fabrice: *« un clic sur le bouton de sortie doit se faire avec un panneau de
confirmation de sortie (même genre que dans classification rapide) »*, for
« Et si je réduisais… ? » and « Préparer mes vacances ». The same three-way
question and the same words as the quick classification: save the project
and leave, discard and leave, stay; Escape stays. As there, it is asked only
when something would be lost — figures typed and not saved or opened since
(the window compares what it would send with what it last saved or opened);
an empty window, or one just saved, closes at once. If the save picker is
cancelled or the write fails, the window stays.

## P-70 — « Carnet de ma voiture » (10/10/2026)

Fabrice wanted a car tool (*« coût entretien, carburants, kilométrage, coût
résolution panne, coût changement pièces d'usure, coût changement pneus,
coûts révisions annuelles »*), turned down a cost-of-ownership summary drawn
from the bank history, and asked for *« quelque chose qui gère l'historique
de la voiture »* built on his own list. Rulings, point by point: **eight
categories** — his seven, energy replacing fuel (*« carburant devient
énergie »*), plus insurance and the roadworthiness test (*« oui pour
l'assurance et le contrôle technique »*); no tolls nor parking, which depend
on the trips and not on the car (*« qu'on ait une petite voiture ou une
Ferrari ça coûte pareil »*); **eight powertrains**, E85 added (*« on peut
ajouter E85 »*), each with its energy unit and its starting list of wear
parts, which the user completes; a **first-owner** flag, the **first
registration**, the **date and mileage when acquired**, and the registration
number on the sheet; one car per **JSON file, saved by hand**, with the exit
door's three-way question; the filling from a bank transaction **optional**
(*« oui mais facultatif »*) — a copy, no lasting link, since the file does
not know the database; the upcoming dates **shown in the window only**;
**PDF and Excel** (*« oui aux 2 »*); the **battery health** followed
(*« oui »*); a home charge priced with the appliance tool's tariff,
**editable in the window and kept in the car's file** (*« oui ça reste dans
le fichier de la voiture »*) — nothing enters `Preferences`. Method choices:
everything counts from the acquisition; consumption is measured from one
full tank to the next, and for an E85 car the kilometres after a fill-up go
to that fill-up's fuel; a part's lifetime is the mileage between two changes,
from zero for a first owner's original part; the roadworthiness test follows
the French rule; a home charge keeps the cost computed on the day it is
noted, so a later tariff change does not rewrite the history; an unreadable
entry in a file is skipped rather than refusing the whole logbook. The
logbook lives on the Rust side (`AppState::with_car`), like the quick
classification's draft: the window shows, the core keeps.

## P-71 — F48 « Partager une dépense » (11/10/2026)

*Built on 11/10/2026, in 3.0.0.* Fabrice: *« un outil de partage de dépense :
partager une somme avec des contraintes »*. Worked out with him point by point
on 10–11/10/2026; his rulings are quoted, the rest are method choices he read
and did not contest. The window's question: **« Qui paie quoi ? »**.

**What it covers.** **One sum to share** between people — not a running
« who owes whom » ledger between several spenders, and not a couple's monthly
charges. **A calculator**: it reads and writes nothing in the database, so it
is **the first tool usable without an open database** (*« oui on peut
utiliser l'outil sans base ouverte »*); the other tools stay greyed as they
are. Limits: **40 people, 20 items** (*« grosso modo la contenance d'un bus,
on doit pouvoir partager les frais d'un voyage »*), and 400 payments.

**The words on screen** (Fabrice, 11/10/2026: *« c'est pas facile de comprendre à
quoi servent ces cases »*): the floor reads **« Au minimum »**, the cap **« Au
maximum »** (*« plutôt Au minimum ? et Au maximum ? »*), the fixed amount
**« Montant exact »**, « for him alone » **« Ses extras »**, the gift **« Surplus
offert »**, and the column saying which of them played **« Ce qui a joué »**
(*« on peut les garder mais il faut des infos bulle »*). **Every column carries
a tooltip**, marked « ⓘ » beside its heading: a short definition and a
concrete example (the Martin family, the dessert, the drop-out), served by the
core in the eighteen languages; a UI check fails if a column of the people's
grid has none. The entry below keeps the method's own terms.

**The people.** One row each, in the order typed (never re-sorted): a
**name**, mandatory and unique (*« on doit pouvoir mettre le nom de chaque
personne qui contribue »*) — compared without case nor surrounding spaces,
since « Paul doit à Paul » would mean nothing. Behind the name, a fixed
identifier: renaming carries payments, ticks and constraints along; deleting
someone who has payments asks first. Then, all optional: an **income**, a
number of **parts**, a **floor**, a **cap**, a **fixed amount**, a **« for
him alone »** amount, and a **household** (*« ok »*, below).

**The sum.** A **total**, from which the items that do not concern everyone
are carved out (« Vin : 60 € », ticked for the drinkers only — *« ceux qui ne
boivent pas d'alcool ne veulent pas payer pour eux »*); what remains is an
automatic **« Commun »** item. No total typed: the total is the sum of the
items. **No discounts nor vouchers** — the total is typed net (*« superflu »*).
On screen, **people in rows, items in columns**: each cell is a tick
(takes part or not), turned into a percentage or parts field when the
item's rule asks for it; names and item headers stay put while scrolling.

**The rule.** **One rule for the whole expense, or one per item, as the user
chooses** (*« règle par poste ou pour toutes les dépenses au choix »*): equal
shares, parts, percentages, or in proportion to incomes. All four are weights
— the engine has one way of splitting. Percentages **must total 100 %, or the
calculation is refused** (*« doit faire 100 % donc refuser »*), checked where
they are typed: over everyone for a whole-expense rule, over an item's
participants for a per-item rule, and the message names the item. A person
excluded from an item under a whole-expense percentage rule has his share of
that item spread over the others in proportion to theirs — said in words, not
silently. A person with a fixed amount has no percentage: the others' total
100 % between them. Parts typed on a person are only the starting value; a
per-item parts rule takes its own (one glass for A, three for B). The
« Commun » item starts on equal shares, can take another rule, and can leave
someone out (*« oui »*). An income of 0 is accepted and weighs 0, said in the
result: « Léo ne paie rien sur la location : son revenu est de 0 »
(*« on accepte »*).

**The constraints.** A fixed amount is a floor equal to a cap: one mechanism,
a range per person, open by default. The constraints bear on a person's
**total**. A person outside his range has **his weight multiplied** — down
for a cap, up for a floor — in each of his items until his total lands on
the bound: what he does not pay falls on that item's other participants by
that item's rule, so nobody pays for an item he is not in. Repeated until
every range holds. What a person owes **beyond his own items** — a deposit
kept after dropping out, a gift larger than what he consumed, the floor of
someone whose income is 0 — is taken off the other items in proportion to
their amount, and shown as « hors postes ». **« For him alone »** (his dessert, his
coffee) is always his: outside floors and caps, never passed on — a cap is
solidarity, not a way of making others pay one's own choices. What cannot be
done is said plainly: fixed amounts above the sum, caps that do not cover it
(« il manque 85,00 € »), floors above it, an item left with nobody to absorb a
cap. Rounding: **to the cent, or to the euro by a tick box**. To the cent,
each item falls exactly — leftover cents go to the largest remainders — and a
fixed amount, floor or cap reached is met to the cent. To the euro, everyone
without a binding constraint pays a round amount, the difference shown as
« Arrondi »; when the total is not round, one person keeps the cents, and the
result says who.

**The payments.** *« Qui a réglé et à hauteur de quel montant, ce qu'il reste
à régler par personne »*: a list of payments — who, how much, **an optional
date** (*« utile »*), an optional label. Each person's balance is his share
minus what he paid: still to pay, up to date, or paid more than his share.
Paying more is not an error (*« on a le droit d'être généreux »*): a person
who paid more has an **« offert »** box, **unticked by default**; ticked, his
share becomes what he paid and the rest is shared among the others — and the
result explains when that leaves someone else having paid more than his new
share. A partial gift (an amount instead of the box) can come later without
changing the rest. Payments above the whole expense are a **warning, not a
refusal**. **No treasurer** (*« on se fiche du trésorier, Radinus est un
logiciel pour particuliers, entre amis ils s'arrangent »*): while the expense
is not fully paid, the result shows what remains due, outside and per person;
once it is, it **proposes the transfers** — the fewest, largest debtor to
largest creditor, at most one fewer than the people — as a suggestion only.

**Households** (*« ok »*). An optional « Foyer » column: each member keeps his
own share (a child's half part, his exclusions), but payments and balance
count per household — the father's 600 € cover the whole family — the
personal PDF becomes one per household, and transfers go from household to
household. **Someone who drops out** after a non-refundable deposit
(*« ok »*): a fixed amount equal to what he paid, unticked from every item —
no special status; the hint of the people's card gives the example.

**Files** (*« comme dans les autres outils »*). A **label** for the sharing
(« Voyage Bretagne 2027 ») names the files and titles the reports. **JSON
project**, as P-67: a mark (`radinus-projet-partage`) and a version, a newer
version refused, amounts written neutrally; only what is typed, never the
result, which is recomputed on opening; each person's identifier kept so the
links survive a renaming. Payments arrive over months, so the exit door asks
before forgetting, as P-69. **Three PDF reports** (*« un PDF général qui
montre la répartition générale, un PDF par personne qui synthétise ce qu'elle
doit payer, un PDF qui montre l'état des paiements actuel »*):

1. **The general distribution** — the label, the total, the rule, each
   person's share in money and percent with the constraint that played, the
   detail per item, the explanatory sentences. No payments: it does not move
   when money comes in.
2. **One file per person** (per household where there is one), written into a
   chosen folder as `<label> - <name>.pdf`, the name cleaned of characters a
   file name refuses, a number added if two names clean to the same; one
   « replace? » for the lot, not forty; one person alone can be printed. His
   share and the items he is in, his dated payments, what remains — « À verser
   à Paul : 120,00 € » once transfers are proposed. Nothing about anyone else.
3. **The state of payments**, dated (« État au 11/10/2026 »): a summary line
   (people up to date, people still owing and how much, collected over
   total), the table of shares, paid and balances, the payments by date, and
   the transfers or what remains due.

On 20 items a grid does not fit an A4 page: the reports list the items rather
than draw them as columns. A **« Masquer les revenus »** box, ticked by
default, applies to the general distribution, the state of payments and the
Excel export; the personal PDF never shows an income. The **Excel workbook**:
sheets Personnes, Postes, Règlements, Résultat, Remboursements — values, not
formulas, as the other exports: caps carried over several rounds are not
honest formulas, and the workbook is a snapshot, edited through Radinus and
its JSON.

## P-72 — The sharing's advice (11/10/2026)

*« C'est lui qui est obligé de calculer les parts, probablement avec une
calculatrice… Il faudrait afficher des valeurs conseillées »* (Fabrice,
11/10/2026). F48 now says what the rule gives and suggests figures — the
**core** computes the advice (`sharing::advise`), the window only shows it.

1. **The headline says what one wants to know**: « 120,00 € à partager :
   chacun paie 60,00 € », or « de 20,00 € à 100,00 € selon chacun » when
   shares differ — not the number of people, which the grid already shows.
2. **A sentence under the rule**, live (under each item's rule in per-item
   mode): « 90,00 € ÷ 3 personnes = 30,00 € chacun », « 4 parts au total :
   une part vaut 25,00 € », « Il manque 60 % pour arriver à 100 % »,
   « Chacun paie 1,8 % de son revenu ». When a limit or an exclusion plays,
   the sentence stays general rather than give a figure that would be false.
3. **Suggested values in grey** in the empty boxes — the rest of the
   percentages shared among the empty boxes by the largest remainder
   (33,34 / 33,33 / 33,33: the total falls exactly), 1 for an empty part.
   **A grey value counts for nothing until taken**: it is a placeholder, never
   written, recomputed at every gesture — so the advice follows the people
   added or the boxes typed (*« lorsque l'on ajoute les personnes les valeurs
   conseillées changent ; s'il y a déjà des valeurs dans les cases, ça change
   le calcul »*): typed values are kept, only the rest is advised.
4. **Three buttons**: « Reprendre les valeurs conseillées » fills the empty
   boxes, never touching a typed one; « Pourcentages d'après les revenus »
   (when every income is known; incomes already typed stay in view under a
   percentage rule) gives percentages that make exactly 100 %;
   « Tout répartir à nouveau » clears the percentages after a question and
   shares them equally — the case of a person added after the percentages
   already made 100 %, which the sentence announces **in orange**: « Les
   pourcentages font déjà 100 % : Zoé ne paierait rien. »
5. **Advice is given even when the calculation is refused** — it is when the
   percentages do not make 100 % that one needs it most; the fields are read
   leniently for it (an unreadable field counts as empty).

## P-73 — QIF bank statements (15/10/2026)

*« Je souhaiterais que dans l'importation de relevés bancaires, en plus du
format OFX (que tu ne touches pas, merci), on puisse importer du QIF »* —
*« ergonomiquement de la même façon que les fichiers OFX, car c'est un relevé
bancaire aussi »* — *« je veux quelque chose de robuste et de fiable »*.

1. **The same window.** Same yellow folder, same account question, same
   table, same buttons; no cutting window as for CSV. The format is
   recognised from the content (`!Type:`, `!Account`…), **after** the OFX
   test, which is unchanged. A module of its own, `qif_import`, returns the
   OFX `Statement`; nothing downstream knows where it came from.
2. **Decide over the whole account, refuse a contradiction, ask or set
   aside what cannot be proven.** Day/month order and decimal separator are
   proven by the file (`24/11`, `-57.62`); a file proving both ways is
   refused with both lines quoted; with no proof of the order, the window
   asks — unless the Preferences give a standing answer (point 7), and the
   file always wins over it. An operation without a readable date or amount
   is set aside **and announced with its number**; `T` and `U` that
   disagree likewise.
3. **The opening balance** (« Solde initial », « Opening Balance »), first
   record, category the account itself in brackets, is set aside and
   announced. Two clues must agree; one alone keeps the line and flags it.
4. **Nothing is invented**: no FITID (duplicates by resemblance only, as
   CSV), no file balance. **« Fichier » and « Écart » stay empty when the
   balance is absent, corrupt or incorrect** (*« tu laisses vide si absence
   d'info ou info corrompue ou incorrecte »*), for every format — an OFX with
   a readable `LEDGERBAL` is unchanged.
5. **The label**: the payee (`P`) and the memo (`M`) joined when both exist —
   or payee only, or memo only, by the Preferences (point 7). With only one
   of the two, that one, whatever the setting.
6. **Proven on Fabrice's two Microsoft Money exports**, « compatibilité
   stricte » and « relative »: 106 operations, the opening balance of
   3 382,63 € set aside, the same statement from both. Those files stay out
   of the project (bank secrecy); the tests use an invented file of the same
   shape, plus a round trip through Radinus's own QIF export and thousands of
   generated files that must never make the reader fall.
7. **A « Relevés QIF » page in the Preferences**, under « Importation »
   (*« pour permettre à l'utilisateur de trancher, avec des choix par
   défaut »*): the day/month order — « Me demander à chaque fois »
   (default), always day/month, always month/day — and the label — payee +
   memo (default), payee only, memo only —, each with its tooltip. **Settings
   of the software, not of the database**: in `settings/radinus_config.json`
   beside the language and the zoom, so the page lives with no database
   open. An unreadable value in that file reads as the default — never a
   guessed date. The answer to the window's question beats the setting; a
   date in the file beats both.
8. **The loading sentence says what the table shows** (*« là tu te
   contredis »*): « 106 lignes lues, dont 106 qui ressemblent à des
   opérations déjà présentes » for a file without identifiers; for an OFX,
   the certain ones (« déjà présentes ») then « une autre ressemble… » for
   the suspicion alone. Integrating pastel lines in bulk still asks nothing —
   the original's behaviour —, an open question left to Fabrice.

## How to add to this file

One entry per ruling: an id, a date, what was decided in one sentence, and
**why** in a paragraph. If a decision revises an earlier one, say so and keep
both. If it was reached after a fault, say which fault — that is the part that
stops it being undone by someone who never saw it.
