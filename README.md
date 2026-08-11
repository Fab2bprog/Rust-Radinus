# Radinus 2.0.4

Radinus is free software (GNU GPL v3 or later) for managing personal finances.
Version 2.0.4 is a cross-platform rewrite (macOS first) of Radinus 1.9.3, a
Windows/WinDev application, by the same author.

- **Author:** Fabrice Garcia
- **License:** GNU GPL v3 or later (see `LICENSE`)
- **Stack:** [Tauri](https://tauri.app) v2 + Rust, web-based UI
- **Database:** SQLite, single file, portable
- **Changelog:** see `CHANGELOG.md`

## What Radinus does

Radinus tracks multiple bank accounts, transactions (with sub-transactions and
automatic "Complement" splitting), checks and checkbooks, recurring
operations, budgets, six cross-tabulated statistics views, a dashboard, and a
balance evolution chart. Its most strategic features are bank statement import
via the OFX standard and migration of Radinus 1.9.3 (Windows) zip backups —
both are non-negotiable requirements for the thousands of existing users.

The application is fully **portable**: everything (app, database, settings,
attachments, logs) lives in one folder, usable from a USB drive, with no
writes outside that folder.

## Architecture

Three strictly layered pieces, dependencies flowing one way only
(View → Controller → Model):

- **View** — web UI (HTML/CSS/TypeScript) reproducing the original windows
  pixel-close; no business logic.
- **Controller** — thin Tauri (Rust) bridge exposing typed IPC commands.
- **Model** — `radinus-core`, an independent Rust library with all business
  rules, SQLite access, import/export, backup, and repair logic. Compiles and
  is tested standalone, with no framework dependency.

The full functional specification — database schema, graphic charter, window
specifications, architecture decisions — lives in the author's
reverse-engineering dossier, outside this repository. The rules the code is
written under are summarised in `CONTRIBUTING.md`.

## Development

Requires Rust and Node.js. Rust and Xcode are assumed installed on the
developer's Mac.

```bash
npm install
npm run tauri dev
```

Before anything is delivered:

```bash
npm run build
cargo test --workspace
cargo clippy --workspace --all-targets
```

No feature phase starts before the previous phase's milestone has been
validated by the author on his own machine.

## Contributing

This repository is currently private and under the sole direction of its
author. No external contributions are accepted at this stage. The rules the
code is written under are in `CONTRIBUTING.md` — read them before changing
anything, including six months from now.
