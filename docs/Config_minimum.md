# What a machine needs to run Radinus

This file is about **running** Radinus, not building it. Whoever compiles it
needs a great deal more — see `Prerequisites.md` for that.

Radinus ships as one application with nothing to install beside it: no runtime,
no database server, no service. It opens a native window holding the system's
own webview, and it keeps its data in a single SQLite file on the user's disk.
The requirements below follow almost entirely from those two facts.

---

## 1. Operating system

| System | Minimum | Why that floor |
|---|---|---|
| macOS | **10.15 Catalina** | Declared in `tauri.conf.json` (`minimumSystemVersion`), and the oldest release Tauri v2 supports. |
| Windows | **Windows 10, 64-bit** | Needs the WebView2 runtime, which Microsoft supports on Windows 10 1803 and later. |
| Linux | **WebKitGTK 4.1** — Ubuntu 22.04, Debian 12, Fedora 36 or newer | The webview binding links against `libwebkit2gtk-4.1`. Older distributions carry 4.0 and cannot load the application. |

Notes that matter in practice:

- **Windows: WebView2 is required.** It is already present on Windows 11 and
  on an up-to-date Windows 10. Where it is missing, the Radinus installer
  fetches it; a machine kept off the network needs the Evergreen installer
  from Microsoft beforehand.
- **macOS: nothing to install.** WKWebView is part of the system.
- **Linux is the least travelled path.** Radinus is developed on macOS and
  checked on Windows; the Linux build works but sees far less use.

## 2. Processor

64-bit, and that is the whole requirement.

| System | Architectures |
|---|---|
| macOS | Apple Silicon **and** Intel — the release is a universal binary |
| Windows | x86-64 |
| Linux | x86-64 |

Any processor of the last fifteen years is enough. Radinus computes balances
over a few thousand rows of SQLite; the work is trivial for the machine. The
only visible pause comes from drawing very large tables, and it is the
webview, not the arithmetic, that takes the time.

## 3. Memory

- **Minimum: 4 GB of RAM.**
- **Comfortable: 8 GB**, which is what any current machine carries.

The application itself is modest. What consumes memory is the system webview,
and it consumes about as much as one tab of the machine's browser.

## 4. Disk

| What | Size |
|---|---|
| The application | 150 to 250 MB depending on the system — the macOS universal binary carries two architectures and is the largest |
| A database | a few hundred kilobytes. Two accounts and 500 operations occupy roughly 370 KB |
| Attachments | whatever the user attaches — this is the only part that grows without bound |

A database is therefore negligible; the disk is spent on the application and,
over the years, on scanned invoices. **1 GB free** is a comfortable floor.

## 5. Screen

This is the one requirement that is genuinely binding, because Radinus opens
windows at fixed sizes rather than adapting to the screen.

| | Resolution |
|---|---|
| Absolute minimum | **1440 × 900** |
| Recommended | **1920 × 1080** |

Where the floor comes from: the widest windows — statistics and quick
classification — open at 1600 × 900, and the tallest fixed-size forms are the
transfer window at 980 × 880 and the account form at 1000 × 860.

Two consequences worth knowing before promising anything to a user:

- **A window that can be resized will fit anywhere.** Most lists and tables
  are resizable, so a 1440 × 900 screen shows them, if snugly.
- **A window that cannot be resized will not shrink.** On a screen 900 pixels
  high, the transfer window and the account form fill it almost exactly once
  the menu bar and the title bar are taken out. They remain usable, with
  nothing to spare.
- **The tallest window of all is the periodic-rule form, at 1000 × 1085.** It
  is resizable, but seeing it whole calls for a screen at least 1200 pixels
  high.

Radinus does not run on a phone or a tablet, and this is why: not a licence
restriction, simply windows that were drawn for a desk.

## 6. What Radinus does not need

- **No Internet connection.** Radinus never contacts a bank, a server or the
  author. The network is used for exactly one thing: opening the Radinus web
  site when the user asks for it from the menu.
- **No account, no registration, no licence key.**
- **No administrator rights**, once the application is installed.
- **No printer** — printing produces a PDF file just as readily.
- **No Microsoft Excel.** Radinus reads `.xlsx` files by itself; the
  spreadsheet program does not have to be installed.

---

*Written for Radinus 2.0.2. The floors above follow from the versions this
release was built against; a later version may raise them.*
