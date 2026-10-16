# The file formats Radinus reads and writes

These are the strategic functions of the application, and the ones that break
without anyone noticing. A wrong column in a window is seen the same day; a
backup archive one byte off is seen the day someone needs it back.

Two of them are non-negotiable requirements: **restoring a Radinus 1.9.3
backup**, which is the migration path for the existing users, and **importing
an OFX bank statement**, which is how a month's operations get in without
being typed.

---

## 1. The Radinus 1.9.3 backup archive — read *and* written

`radinus-core/src/backup/` · reference: `06_FORMATS_SAUVEGARDE_IMPORT_EXPORT.md` §1

### What it is

A zip file named `radinus_sauvegarde_<AAAAMMJJHHMMSSmmm>.zip`, holding one
JSON file per table, plus the attachment files loose at the root under their
GUID names.

Nineteen tables travel in it:

```
categories   affectations   comptes      banques        modeoperation
operations   commentaires   postesbudget budget         calopperiodique
parametres   chequier       cheque       statutcheque   tiers
projets      modeleoperation piecesjointes preferences
```

Two tables are **absent on purpose**: `StatutOperation` and `TypeCompte`. They
are closed lists that the code recreates, which is exactly why 1.9.3 does not
back them up. `ParamSecurite` is absent too — the password is never exported.

### The rules that make it byte-identical

The target is not "valid JSON". It is **the same bytes 1.9.3 produces**, so
that a 1.9.3 installation can read what 2.0.0 writes. Serde cannot express
that layout, so `backup/writer.rs` emits the JSON by hand. Every rule below
was **measured on a real archive**, not guessed:

- a table file is `{ "Table":[ { "F":v, "F":v }, { … } ] }`, all on one line,
  with no trailing newline;
- an empty table is `{ "Table":[  ] }` — with two spaces;
- fields appear in the declaration order of the original `base.sql`, which is
  also the order of `database/schema.rs`;
- non-ASCII characters are escaped `\uXXXX`, so a file is pure ASCII;
- amounts are plain decimals **in their shortest form**: `1500`, `-7.5`,
  `5972.54` — never `1500.0`, never `-7.50`;
- dates are `AAAAMMJJ`, and the empty string when absent;
- booleans are `true` / `false`;
- one empty entry named `.` sits just before the last table file, because
  1.9.3 puts one there.

**Row order matters**, because 1.9.3 browses each table through one of its
indexes. Measured on the author's real archive: `Affectation`, `Categorie` and
`Tiers` come out sorted by label under a French collation that ignores
accents, case and punctuation — which is why `Ebay` precedes `E. Leclerc`;
`Commentaire` by operation; `Operation` by clearing date; everything else by
primary key.

One limit is stated plainly rather than hidden: where several rows share the
same sort key — 600 of the author's 932 distinct clearing dates do — 1.9.3
falls back on the physical record order inside its own file, which no
reimplementation can reproduce.

### What a restore does

**A restore wipes the target database.** It is reset to the blank prefilled
state, then every table the archive carries is emptied again and refilled from
the archive. Nothing of the previous content survives — which is why the
prefilled rows only survive for the two tables the archive does not carry.

Three details worth knowing:

- **the "Complément" is recognised on the way in**: a sub-operation whose
  label is exactly `Complément` sets the `EstComplement` marker. The reverse
  direction — marker to label — belongs to the writer;
- **the software version stored is this build's, not the archive's.** A 1.9.3
  archive carries 1/9/0; writing that into a 2.0.0 database would be a lie
  about which program is running;
- **a non-JSON entry is ignored, not treated as an error**, so an archive
  carrying attachment files still restores its tables.
- **`IDVerification` is 3.0.0's own field** (schema 11), written last on each
  operation so that the twenty fields of 1.9.3 stay where it expects them. An
  archive that does not carry it — every one written before — restores with
  its operations *verified*. A field that is there with a value outside 1–4 is
  an anomaly, and restores as *to verify* (P-45). The round-trip test
  strips this one field before comparing sizes.

### The test that guards it

`radinus-core/tests/round_trip.rs`: a real archive is restored, written back
out, and compared **field by field**. Three fields are excluded, and only
three — `VerSoftMajeur`, `VerSoftMineur`, `VerDataBase`, which are rewritten
by design.

If you touch anything in `backup/`, that test is the one to keep green. It
reads the author's real archive from `radinus-core/tests/fixtures/`, which is
not distributed; without it the test prints a notice and passes.

---

## 2. OFX — reading a bank statement

`radinus-core/src/ofx_import.rs` · reference: `06_…` §2.1

### It is not XML, and that is the whole point

An OFX 1.x header says so itself: `DATA:OFXSGML`. It is SGML, and **the leaf
tags are not closed**:

```
<TRNAMT>-50.00<FITID>P_GDYTLL29
```

The amount is ended by the *next* tag. No XML parser reads that; it stops at
the first unclosed tag. The only way is to treat the file as text studded with
markers, and that is what the original does, in four moves reproduced here:

1. **isolate a container** by name — containers *are* closed;
2. **clean out** carriage returns and tabs, because the file may arrive on one
   line or on fifty;
3. **split on `<`**, which turns every unclosed tag into a `NAME>value`
   fragment — the absence of a closing tag becomes a property instead of a
   defect;
4. **recognise by prefix, and ignore everything else.**

The fourth move looks the most naive and is the most robust: a bank adding
`MEMO`, `CHECKNUM` or `CURRENCY` breaks nothing, tag order does not matter,
and a missing optional tag simply leaves its field empty.

### What is taken from it

Date, amount (signed), label, and above all **`FITID`** — the unique
identifier the bank puts on each transaction. It is what makes reconciliation
reliable: the same file imported twice is recognised rather than duplicated.

`statements.rs` does the matching against what the database already knows, and
F18 reconciles a line by hand when the automatic match is not enough.

---

## 3. CSV bank statements — a window, not a guess

`radinus-core/src/csv_statement.rs`

An OFX file reads itself: its tags carry their names. **A CSV carries
nothing** — no reliable field names, no imposed order, a separator of the
bank's choosing, and a header of any length. The example statement begins with
five lines of bank details, one blank line, then the column names: the data
starts on the eighth.

Hence the window. One **sets**, **tests**, **looks**, and starts again. It
does not pretend to guess; it shows what the setting produces and lets the
user's eye judge.

> "If the setting should have been 7 instead of 1, that is not our problem, it
> is the user's."

But the tolerance stops at the door. **The preview shows everything** the
cutting produces, gibberish included — that is how one sees the mistake. What
crosses into the integration window is **severe**: only lines whose date and
amount are readable. A header line taken for an operation has neither, and
that is what keeps it out.

Once validated, the lines land in F18 exactly as OFX lines do.

## 3 bis. QIF bank statements — the same window as OFX

`radinus-core/src/qif_import.rs` (15/10/2026, P-73)

A QIF is a bank statement too, so it goes **through the OFX path**: the same
yellow folder, the same account question, the same table and buttons
(*« on utilise la même fenêtre, les mêmes boutons, la même interface »*). The
reader is a module of its own and returns the same `Statement` as the OFX
reader, which was not touched.

One line per field, a letter in front (`D` date, `T`/`U` amount, `P` payee,
`M` memo, `N` number, `L` category), `^` closing the operation, `!Type:Bank`
opening a list, `!Account` naming it. The format has **no rule** for the two
things that matter most — the order of day and month, and the decimal
separator — so:

- **both are decided over the whole account, never line by line**: one
  `24/11` proves day first, one `-57.62` proves the point is decimal;
- **a file that contradicts itself is refused**, quoting both lines;
- **what cannot be proven is asked** (the date order, when no date goes past
  12) **or set aside and said**: an operation without a readable date or
  amount does not enter, and the information bar gives its number.

Money and Quicken put an **opening balance** first, its category the account
itself in brackets (`L[CCP banque post]`): it is a starting balance, not an
operation, and it is set aside and announced. Two clues must agree — the
bracket, and a known phrase or the account's own name; one clue alone keeps
the line and flags it.

A QIF carries **no FITID and gives no balance**: nothing is invented — the
FITID column hides itself, duplicates are caught by resemblance only (as for
CSV), and the « Fichier » and « Écart » boxes stay empty rather than show a
0,00 € the bank never stated. Unknown codes are ignored, never fatal; the
three line endings, a byte-order mark, Windows-1252 and a truncated last
record are all read. Microsoft Money's two exports, « compatibilité
stricte » and « relative », give exactly the same statement.

The Preferences (« Relevés QIF ») may give a standing day/month order and
choose the label (payee + memo, payee only, memo only); they live in
`settings/radinus_config.json`. A date that proves the order beats the
setting.

---

## 4. Excel import — three steps, for a migration

`radinus-core/src/csv_excel_import.rs` · windows F34, F35

> "Importing an Excel file very often happens in the first days of owning
> Radinus, to bring in a big history. Users were on other software and decided
> to move to Radinus."

Three consequences follow from that one sentence, and they explain every
decision in the module:

- **no duplicate checking.** One imports into a fresh account; there is
  nothing to deduplicate. Reimporting the same file writes everything twice,
  and that is accepted;
- **three explicit steps beat automatic guessing** — one goes through them
  once in the file's life;
- **the volume arrives in one block**, hence a single transaction.

The three steps: the **capture zone** (which rows and columns actually hold
data), the **field mapping** (which column is the date, which is the amount),
and the **policies** (what to do with what is missing). Nothing is detected;
everything is declared, and shown.

---

## 5. Exports

### The ten that go through a sheet

`radinus-core/src/sheets.rs`

The right-click export is a function **of the table**, not of a window: once
written, every list in Radinus has it.

A `Sheet` is a grid of typed cells — a text, or a number with the format that
writes it — each able to carry a background colour and bold. Nothing else.
Windows build a sheet out of **what they display**; three writers consume it,
in `.xlsx`, `.ods` and `.csv`, plus XML and JSON. **The exporter knows nothing
of Radinus, and the windows know nothing of OOXML or OpenDocument.**

That separation was paid off in a day: OpenDocument was asked for on
26/07/2026, after the fact. It cost one more writer at the bottom of that
file. The shape did not move, no window learned anything, and the ten tables
that already exported had the new format the same day.

Two rules govern the content:

- **as displayed** — the period chosen, the filters set, the sort in force;
- **mothers only** — a split operation exports for its total, without its
  daughters.

### The two that cannot

`radinus-core/src/exports.rs` · **OFX and QIF**

These two do not start from a sheet, and the reason is worth stating: an OFX
does not carry columns, it carries operations — a date, a signed amount, an
identifier, a label. What the window shows on screen ("Debit" in one column,
"Credit" in another) is not what the format expects.

They therefore start from the database, over the list of keys the window hands
them. **The window decides what it is about** — the sort, the period, the
funnels — and the core re-reads those operations.

Three rules, given on 30/07/2026:

- **mothers only.** A split operation is exported for its total, without its
  daughters. Writing both would count the money twice, and software reading
  the file back would see double the real balance — a fault that does not
  show, which is the worst kind;
- **as displayed** — the same rule as the right-click export;
- **the FITID stays empty** when the bank never gave one. Nothing is invented.

The QIF has no original on the export side: the author's `Qif_Import` class
only reads. The file produced must therefore be **valid QIF for other
software**, not for his own importer.

---

## 6. PDF — composed, not drawn

`radinus-core/src/printing.rs`

> A report is not a drawing, it is a composition.

Earlier attempts in Rust used drawing libraries: one places a line, one
measures a column, one discovers a page break by hand. Radinus uses **Typst**,
a typesetting engine written in Rust: it paginates, breaks pages in the right
place, and reprints table headers at the top of each one.

The alternative — asking the system's webview to print — was refused on
31/07/2026 for one reason: the three webviews do not paginate alike, and would
give three different documents for one statement. **Radinus composes its own
PDF**, and the same document comes out of Windows, macOS and Linux.

`system.rs` then hands the file to the operating system's default application,
in six lines per platform, calling nothing but commands present out of the
box: `open`, `cmd /C start`, `xdg-open`.

---

## 7. Attachments on disk

`radinus-core/src/attachments.rs`

**A file never carries its own name on disk.** It is stored under a GUID, in
the `attachments/` folder of the database it belongs to:

```
databases/Radinus_00001/attachments/<NomFichierGUID>
```

The row in `PiecesJointes` keeps the real name, the size, the MIME type, the
date and a CRC-32 checksum. Two files called `facture.pdf` therefore coexist
without either overwriting the other, and a filename with a slash or a colon
in it cannot break anything.

Each database has its own attachments folder: two databases share nothing, and
a backup only carries its own.

Deleting an attachment sends it to the **system trash**, as the original does
with its `frVersCorbeille` everywhere it erases.

---

## 8. The three files of our own that are not a format

All three are ours, all three are read by `location.rs`, and none has to match
anything.

**`settings/radinus_config.json`** — the interface language, the last database
opened, and the recent ones. Nothing in it opens by itself.

**`settings/start_mode.toml`** — one line, `portable_mode = 0` or `1`, and the
only setting that cannot live inside the data folder: it is what *decides* that
folder (`Decisions.md`, P-36). Radinus reads it **beside the executable and
nowhere else**; anything other than a plain `1` — a missing file, an empty one,
an unreadable one — means installed mode. It also writes a copy of it into the
data folder at first launch, with a comment explaining itself. That copy sleeps:
it is never read there, and it exists so that moving the data folder next to the
application brings it along, one digit away from switching mode. It is written
only when absent, so a `1` set by hand is never overwritten.

**`databases/<slot>/radinus_base.json`** — the label, the comment, and where
that database came from. **Indicative only**: nothing in the software depends
on it, and it is regenerated with the folder name as label when it is missing
or unreadable.

---

## 9. If you change any of this

| Format | The test that guards it |
|---|---|
| 1.9.3 backup | `radinus-core/tests/round_trip.rs` — restore, write, compare field by field |
| OFX import | `radinus-core/tests/real_ofx.rs` |
| statement messages | `radinus-core/tests/statement_messages.rs` |
| restore against real data | `radinus-core/tests/real_backup.rs` |
| balances after a restore | `radinus-core/tests/balances.rs` |

Four of the five read the author's real financial data from
`radinus-core/tests/fixtures/`. That folder is in `.gitignore` and does not
travel with the repository; the tests print a notice and pass without it —
which also means that **on a fresh clone, they prove nothing**. Ask the author
for the fixtures before touching a format.
