# Changelog

Notable changes to Radinus, newest first. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and Radinus follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Two version numbers live in this project and they do not move together:

- the **software** version, below, which restarts at 2.0.0 for the rewrite;
- the **database schema** version (`Parametres.VerDataBase`), which continues
  the line Radinus 1.x walked from 0 to 9 and is at 10 today. A database is
  migrated forward when it is opened, never backward.

## [2.0.1] — unreleased

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

[2.0.1]: https://github.com/
