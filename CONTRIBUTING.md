# Contributing to Radinus

This repository is under the sole direction of its author, Fabrice Garcia.
Outside contributions are not accepted at this stage. This file exists so
that anyone reading the code — the author six months from now included —
knows the rules it was written under.

## Building and running

Rust and Node.js are required; on macOS, Xcode's command line tools too.

```bash
npm install
npm run tauri dev
```

## What has to pass before anything is delivered

```bash
npm run build          # tsc, then vite
cargo test --workspace
cargo clippy --workspace --all-targets
```

`cargo test -p radinus` runs the **crossings** (`src-tauri/src/crossings.rs`).
They are not ordinary tests: each one holds the two ends of a seam nothing
else links — a command name written in TypeScript and registered in Rust, a
window label and the permission file, a Fluent key and the dictionary that
serves it. Every one of them exists because a fault got through. Read the
comment above a crossing before changing it; it says which fault.

## The rules the code is written under

These are the author's, and they are not negotiable.

1. **Three layers, dependencies one way only.** View (`ui/`) → Controller
   (`src-tauri/`) → Model (`radinus-core/`). The model knows nothing of Tauri,
   of the disk layout, or of a window; it compiles and is tested on its own.
   No business rule lives in the controller — a command translates a JSON
   call into a core call and forwards the result.

2. **No new dependency without the author's explicit permission**, Rust crate
   or JavaScript library alike. The ones already in place were each asked for
   and granted, and the reason is written next to them in `Cargo.toml`.

3. **SQL table and column names are sacred.** They keep the original French
   names of Radinus 1.9.3, verbatim — `Operation`, `IDCompte`,
   `Maj_SoldeBanque`. A 1.9.3 backup restored into a renamed schema is a
   backup lost.

4. **No window holds a sentence of its own.** Everything shown comes from the
   Fluent resources in `radinus-core/i18n/`, and a window asks for its whole
   vocabulary in one call before it draws anything. A missing key comes back
   as the key itself: a missing translation must be seen, not guessed at. A
   window never composes a sentence out of pieces — French would need a
   gender, English would not, and the window would end up knowing both.

5. **A window is built once and never destroyed.** Leaving it hides it,
   coming back shows it again, and new parameters reach it through
   `window-parameters:<label>`. Destroying windows cost two separate faults.
   A window created hidden cost a third: it came back blank, never having
   been painted.

6. **Amounts are `i64` micro-units** (value × 1 000 000). No floating point
   ever touches money.

7. **Identifiers, comments and commit messages are written in English**; the
   working language between the author and whoever writes the code is French.

## What is never committed

`radinus-core/tests/fixtures/` holds the author's real financial data — his
own accounts, his own operations, real balances. It is in `.gitignore` and it
stays there. The tests that read it print a notice and pass when it is
absent, so the repository can be made public without the data going with it.
