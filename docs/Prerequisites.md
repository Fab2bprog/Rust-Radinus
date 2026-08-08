# What must be installed to develop Radinus

Radinus is a Tauri v2 application: a Rust program that opens a native window
holding a webview, with the interface written in HTML, CSS and TypeScript.
Building it therefore needs **two toolchains** — Rust and Node.js — plus what
the operating system needs to compile native code and to provide a webview.

The application itself needs none of this: once built, it is one portable
folder with no installer and no runtime to deploy. Everything below is for
whoever builds it.

---

## 1. Rust

The whole model and controller are Rust. Install the toolchain through
`rustup`, which is how the compiler is kept up to date:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Windows: download `rustup-init.exe` from <https://rustup.rs>.

- **Channel:** stable.
- **Minimum version: 1.87.** The code uses inline `const` blocks in array
  repetition (`[const { OnceLock::new() }; N]`, stable since 1.79) and
  `is_multiple_of` on integers (stable since 1.87). An older compiler will
  refuse to build.
- Nothing pins the version in the repository — there is no `rust-toolchain`
  file. A recent stable is expected, and CI runs on the latest one.

Two components are used beyond the compiler, both installed by default with
`rustup`:

```bash
rustup component add clippy   # the linter — CI treats its warnings as errors
rustup component add rustfmt  # formatting
```

Check:

```bash
rustc --version    # 1.87.0 or newer
cargo --version
cargo clippy --version
```

---

## 2. Node.js

The interface is built by Vite and type-checked by TypeScript, both of which
run on Node.

- **Minimum: Node 20 LTS.** CI uses **Node 22**, and that is the safe choice.
- npm comes with it; no other package manager is expected — the repository
  carries a `package-lock.json`, and `npm ci` installs exactly what it says.

Install it from <https://nodejs.org>, or through `nvm`, `fnm`, Homebrew or
your distribution — Radinus does not care which.

Check:

```bash
node --version    # v20 or newer
npm --version
```

---

## 3. What the operating system must provide

> **The first build is long, and that is normal.** Since 05/08/2026 Radinus
> compiles **SQLCipher** instead of plain SQLite, along with the cryptography
> library it needs, both from source (`Decisions.md`, P-34). Expect ten to
> twenty minutes the first time, and the usual couple of minutes afterwards.
> Nothing has to be installed for it — that is the point of building them in.

Two things are needed from the system: a **C compiler** — SQLite is compiled
from its own C source into the binary, which is what makes the application
self-contained — and a **webview**, which displays the interface.

### macOS (the reference platform)

```bash
xcode-select --install
```

That gives the C compiler and the linker. The webview (WKWebView) is part of
the system; nothing else to install. macOS 10.15 or newer.

### Windows

- **Microsoft C++ Build Tools** — the "Desktop development with C++" workload
  of the Visual Studio Installer. The Visual Studio IDE itself is not needed.
- **WebView2 Runtime** — already present on Windows 11 and on up-to-date
  Windows 10; otherwise download the Evergreen installer from Microsoft.

### Linux

The webview and its dependencies must be installed. On Debian and Ubuntu:

```bash
sudo apt install libwebkit2gtk-4.1-dev build-essential curl wget file \
     libxdo-dev libssl-dev libayatana-appindicator3-dev librsvg2-dev
```

Other distributions carry the same libraries under other names; the Tauri
prerequisites page lists them. Note that Radinus targets **macOS first**: the
Linux build is expected to work but is not what the author checks daily.

---

## 4. Getting the project running

```bash
git clone <the repository>
cd Radinus-2

npm install          # or `npm ci` for exactly what the lockfile says
npm run tauri dev
```

The first build compiles the whole Rust dependency tree — Tauri, SQLite,
Typst and the rest. Expect **several minutes** and **around 3 to 5 GB** in
`target/`. Later builds are incremental and take seconds.

`npm run tauri dev` starts two things: Vite on `localhost:1420`, and the Rust
application pointed at it. A changed `.ts` or `.css` file reloads the window
without recompiling any Rust; a changed `.rs` file rebuilds and relaunches.

The `@tauri-apps/cli` package provides the `tauri` command and is installed by
`npm install`; there is nothing global to install.

---

## 5. To run the tests

The Rust tests need nothing more than the toolchain:

```bash
npm run build                              # tsc, then vite — must run first
cargo test --workspace
cargo clippy --workspace --all-targets
```

`npm run build` comes first because Tauri's build script reads `dist/` and
refuses to compile without it.

The window tests drive a **real browser engine**, which Playwright downloads
once:

```bash
npx playwright install chromium
npm run test:ui
```

That download is a few hundred megabytes and lands outside the repository, in
Playwright's own cache.

Two integration tests read the author's real financial data from
`radinus-core/tests/fixtures/`. That folder is in `.gitignore` and is not
distributed; the tests print a notice and pass without it.

---

## 6. To build the application

```bash
npm run tauri build
```

The result lands in `src-tauri/target/release/bundle/`: a `.app` and a `.dmg`
on macOS, an `.msi` and an `.exe` on Windows, a `.deb` and an `.AppImage` on
Linux.

**Cross-compilation is not part of the workflow.** Each platform is built on
itself: a macOS build needs a Mac. Building the three from one machine would
mean signing and notarising elsewhere, and none of that is set up.

---

## 7. Editor

Nothing is required, and two extensions save time:

- **rust-analyzer** — types, errors and jump-to-definition in Rust. The single
  most useful thing to install.
- **Tauri** (`tauri-apps.tauri-vscode`) — knows `tauri.conf.json` and the
  capability files.

TypeScript needs no extension: `tsconfig.json` is read by any editor that
understands TypeScript, and `npm run build` type-checks the whole interface
anyway.

---

## 8. Summary

| What | Minimum | Used by the author and by CI |
|---|---|---|
| Rust (stable, via rustup) | 1.87 | latest stable |
| Node.js | 20 LTS | 22 |
| macOS | 10.15 | current, with Xcode CLT |
| Disk for `target/` | ~3 GB | ~5 GB |
| Playwright browser | only for `npm run test:ui` | chromium |

Everything else — SQLite, the webview binding, the typesetting engine, the zip
reader — is compiled from the Rust dependencies and installs nothing on the
machine. See `About_dependencies.md` for what each of them does.
