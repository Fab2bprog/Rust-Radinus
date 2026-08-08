# The dependencies of Radinus, and why each one is here

Radinus follows one plain, severe rule: **no dependency enters without the
author's explicit permission.** Every one below was asked for, discussed and
granted, and this document says what it does *for Radinus* — not what it is
able to do in general.

Two things make that rule useful rather than tiresome. The first is that
Radinus handles money: every library added is code nobody here has read,
touching bank accounts. The second is that Radinus installs normally and
**must stay able to run portable** — copied onto a USB drive, its data beside
it, on a machine that has never seen it (ruling P-36). A library needing
something installed system-wide would break that, which is why nothing here
asks the machine for anything: every engine is compiled into the binary.

Every licence below is MIT, Apache-2.0, BSD, Zlib, MPL-2.0 or Unicode, and
every one of them is compatible with the GNU GPL v3 under which Radinus is
distributed. The one that had to be checked closely is OpenSSL, embedded by
`openssl-src` for SQLCipher: since OpenSSL 3.0 it is Apache-2.0, and the old
OpenSSL licence — which the GPL refuses — no longer applies.

---

## The core — `radinus-core`

The layer that carries every business rule. It knows nothing of Tauri, of the
disk, or of a window, and it compiles and is tested on its own.

### `rusqlite`, with the `bundled-sqlcipher-vendored-openssl` feature

Access to SQLite, the database of Radinus. The bundled part is the important
one: it compiles the engine inside the binary, so Radinus needs no library
installed on the machine. That is what lets the application run from a USB
drive, on a Mac that has never seen Radinus.

**Since 05/08/2026 the engine compiled in is SQLCipher, not plain SQLite**
(authorized by Fabrice, ruling P-34). SQLCipher *is* SQLite, plus AES-256
encryption of the file's pages; a database with no password opens exactly as
before, byte for byte. `vendored-openssl` builds its cryptography library from
source alongside it, so nothing has to be installed on the machine either — at
the price of a longer first compilation.

Licence: BSD-3-Clause, free including for commercial use. The *official*
encryption extension of SQLite, SEE, costs US $2 000 and is not used.

### `serde` and `serde_json`

Translation between Rust structures and JSON. They serve two places that have
nothing to do with each other: the **backup format** of Radinus 1.9.3, which
is made of JSON files inside a zip archive, and the **bridge** between the
core and the windows, where every command passes typed data.

### `zip`

Reading and writing the Radinus 1.9.3 backup archive. This is not a
convenience: the thousands of users of the Windows version hold their backups
in that format, and a version 2 unable to read them would be a version 2
nobody can move to.

### `fluent`, `fluent-bundle`, `unic-langid`

The translation system. **No window of Radinus holds a sentence of its own:**
everything the software says lives in `radinus-core/i18n/*.ftl`, one file per
language. Fluent was chosen over a plain lookup table because it knows each
language's plural rules and variants — "1 opération" and "2 opérations" are
not decided the same way in French, English and Spanish. `unic-langid`
carries the normalised tag (`fr`, `en`, `es`) that Fluent needs.

### `time_compute`

Calendar dates and the arithmetic that goes with them: adding three months to
a due date, knowing which day a quarter ends on, comparing two periods.
**This is Fabrice Garcia's own crate**, and the project's rule gives his
crates priority wherever they apply.

### `office-toolkit`

Reading and writing Excel workbooks, for importing a statement file and for
exporting the tables. **Also the author's own crate.** `default-features =
false` turns on only what Radinus uses — `excel` and `word` — and leaves the
rest out.

### `spreadsheet-ods`

Export to OpenDocument, the format of LibreOffice Calc. A user without Excel
must still be able to get his tables out.

### `typst`, `typst-layout`, `typst-pdf`

Typesetting for printouts and reports. Typst is a typesetting engine written
in Rust: it paginates, breaks pages in the right place, and reprints table
headers at the top of each page.

It was chosen against what looked like the simpler answer — asking the
system's webview to print the page. That answer gives three different
documents on Windows, macOS and Linux, because the three engines do not
paginate alike. **Radinus builds its own PDF**, and the same statement comes
out identical everywhere.

---

## The controller — `src-tauri`

The bridge between the windows and the core, deliberately thin: no business
rule lives in it.

### `tauri` and `tauri-build`

The application framework. It provides the native window, the webview that
displays the interface, the system menu bar, and the typed passage between
the windows' JavaScript and Rust. It is what makes Radinus a desktop
application rather than a web page.

### `tauri-plugin-dialog`

The system's own "save as" box — the real Finder on macOS, Explorer on
Windows. It serves the export of the tables. **Only saving is granted, never
reading** (see `src-tauri/capabilities/default.json`): the window asks where
to write, Rust writes there, and nothing else on the disk is reachable from
the interface.

### `trash`

Sending a file or a folder to the system trash instead of erasing it with no
way back. It is what the original does everywhere it erases, with its
`frVersCorbeille`. Radinus uses it for deleted **attachments** and for
**databases** deleted from the selector. The three systems have three
trashcans with nothing in common; this crate puts them behind one function.

### `serde`, `serde_json`, `time_compute`

The same as in the core, for the same reasons: the bridge passes typed data,
and some of it carries dates.

---

## The interface — `package.json`

### `@tauri-apps/api`

The JavaScript side of the bridge: `invoke` to call a Rust command, `listen`
to receive an event, and window handling. It is the strict counterpart of the
`tauri` crate.

### `@tauri-apps/plugin-dialog`

The JavaScript side of the "save as" box.

### Development tools only

These four do not ship with the application: they build it and check it.

- **`typescript`** — typing for the interface. `tsc` refuses to compile when a
  window calls a command with an argument of the wrong type; that is one fault
  fewer that will ever reach the screen.
- **`vite`** — the frontend build: it turns the TypeScript files into
  JavaScript and assembles the pages. It also serves them during development,
  which reloads a changed window without recompiling any Rust.
- **`@tauri-apps/cli`** — the `tauri dev` and `tauri build` commands.
- **`playwright`** — a real browser engine, driven by the tests in
  `ui/tests/windows.test.mjs`. It opens every Radinus window with the Tauri
  bridge replaced by a stub, clicks its buttons and checks what appears. Those
  tests exist because a whole delivery once went out with windows that looked
  perfect and did nothing: the Rust was tested, the interface was not tested
  at all.

---

## What Radinus does not use, and why

A few absences are choices, and they are better written down than
rediscovered.

- **No interface framework** — no React, no Vue, no Svelte. The windows are
  plain HTML, CSS and TypeScript. They reproduce windows drawn twenty years
  ago, and a framework would have added one more layer between the click and
  the data without simplifying anything.
- **No date library on the interface side** — dates are computed by the core
  and arrive already written.
- **No floating-point library** — amounts are 64-bit integers in micro-units
  (the value times 1 000 000). A float does not hold exactly 0.10 €, and a
  finance application cannot afford that.
- **`tauri-plugin-opener`** was turned down: opening a PDF with the system's
  default application takes six lines per operating system
  (`src-tauri/src/system.rs`), and those six lines call nothing but commands
  present out of the box everywhere — `open`, `cmd /C start`, `xdg-open`.
