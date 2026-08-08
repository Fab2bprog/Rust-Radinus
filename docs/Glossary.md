# Glossary — the words of Radinus, French and English

Radinus is written in two languages at once, and it is not an accident.

**The SQL is French**, verbatim from Radinus 1.9.3: `Operation`, `IDCompte`,
`ReportPointe`. Those names are not translated, not tidied and not
pluralised — a 1.9.3 backup restored into a renamed schema is a backup lost,
and thousands of existing users hold their history in that format.

**The code is English**: identifiers, comments in the older modules, and every
commit message. **The interface is in three languages**, none of them hard
written: every sentence lives in `radinus-core/i18n/*.ftl`.

This file is the bridge. Someone who never used Radinus 1.9.3 cannot read
`IDStatutOperation` without it, and will end up believing that *pointé* means
"selected".

---

## The three states of an operation — the heart of it

Every operation carries one of exactly three statuses. The list is **closed**:
the user cannot add a fourth, and the three ids are fixed for ever.

| French | `IDStatutOperation` | English used in the code | What it means |
|---|---|---|---|
| **Pointé** | 1 | pointed | The bank has processed it. It appears on the statement; it is a fact. |
| **Engagé** | 2 | committed | Spent but not yet debited — the cheque is written, the card payment not yet cleared. Certain, not yet visible at the bank. |
| **Prévu** | 3 | planned | Foreseen: a standing order due next month, an expected salary. Not yet certain. |

*Pointé* has nothing to do with selecting a line. It comes from *pointer* — to
tick off against the bank statement, one by one, the way it was done on paper.

## The three balances — and they are cumulative

| French | Column | English | Definition |
|---|---|---|---|
| **Solde en banque** | `SoldeBanque` | bank balance | the pointed operations only |
| **Solde réel** | `SoldeReel` | real balance | pointed **+** committed |
| **Solde final** | `SoldeFinal` | final balance | pointed **+** committed **+** planned |

Each includes the one before it. The bank balance is what the bank would tell
you today; the final balance is where the account is heading if nothing
changes.

| French | Column | English | Definition |
|---|---|---|---|
| **Report** | `ReportPointe`, `ReportEngage`, `ReportPrevu` | carried-over balance | What the account held before the first operation Radinus knows about. Three of them, one per status. Setting them right is what makes the balances match the bank. |
| **Solde initial pointé** | `ReportPointe` | opening pointed balance | The same thing, seen from the account form. The Outils menu computes it: current bank balance − total of the pointed operations. |

---

## Operations

| French | English | What it is |
|---|---|---|
| **Opération** | operation | One line of an account: a date, a label, an amount, a status. Never called "transaction" in the code. |
| **Sous-opération** | sub-operation | An operation split into several: one payment at a supermarket becomes food, cleaning, petrol. The parent is the **mother**, the parts are her **daughters**. |
| **Opération mère** | mother operation | An operation with `IDOperationParent = 0`. Only mothers count in a balance — counting the daughters too would count the money twice. |
| **Complément** | complement | The daughter that closes a split, holding whatever was not allocated. It is recognised by a dedicated marker, `EstComplement`, **never by its label** — a label depends on the language. |
| **Ventilation** | split, allocation | The act of dividing an operation into sub-operations. |
| **Rapprochement** | reconciliation | Matching a line from an imported bank statement with an operation Radinus already knows, instead of creating a duplicate. |
| **FitID** | FitID | The unique identifier a bank puts on each transaction in an OFX file. It is what makes reconciliation reliable — the same line imported twice is recognised. |
| **Pointage** | ticking off | Changing an operation to *pointé*. `DatePointage` is the day the bank processed it, which is not the day it happened. |

---

## The seven nomenclatures

A *nomenclature* is a user-editable list feeding a drop-down. Radinus has
seven, they share one list window and one form window, and the same two rules
govern them all: a label cannot be empty, and it cannot be a duplicate.

| French | Table | English | Used for |
|---|---|---|---|
| **Catégorie** | `Categorie` | category | What the money was for: food, rent, salary. |
| **Affectation** | `Affectation` | assignment | Who or what it is charged to: household, car, holidays. |
| **Mode de paiement** | `ModeOperation` | payment mode | Card, cheque, transfer, cash. |
| **Tiers** | `Tiers` | payee | Who was paid, or who paid. |
| **Projet** | `Projets` | project | A one-off grouping: a move, a wedding, building work. |
| **Poste budgétaire** | `PosteBudget` | budget line | The heading a category is attached to, for the budget. |
| **Banque** | `Banques` | bank | The list of banks an account can belong to. |

Two lists look like nomenclatures and are not, because they are **closed**:
`StatutOperation` (the three above) and `TypeCompte` (current account, savings,
and the rest).

---

## Cheques

| French | Table | English | What it is |
|---|---|---|---|
| **Chéquier** | `Chequier` | chequebook | A book of cheques, belonging to an account, with its first and last number. |
| **Chèque** | `Cheque` | cheque | One cheque of a book, which may be linked to an operation. |
| **Bénéficiaire** | `Beneficiaire` | payee | Who the cheque is made out to. |
| **Statut du chèque** | `StatutCheque` | cheque status | Where it stands: to be written, written, cashed, cancelled. |

---

## Money, dates and keys

| Term | What it means here |
|---|---|
| **Micro-unit** | Amounts are `i64`, equal to the value times 1 000 000. 12,34 € is stored as `12_340_000`. No floating point ever touches money: a float does not hold exactly 0.10 €. |
| **Débit / Crédit** | A debit is a negative amount, a credit a positive one. One column, one sign — never two columns. |
| **Genere_Clef** | The original's key generator: `max(id) + 1`. Radinus reproduces it in `database/keygen.rs`. **No SQL auto-increment anywhere**, because a restored backup brings its own ids. |
| **GUID** | Used where an id must survive outside the database: a recurring rule (`GUIDCalOpPeriode`), an attachment file on disk (`NomFichierGUID`). |
| **Lien souple** (soft link) | A foreign key that is not enforced, with `0` meaning "not specified". Most nomenclature links are soft: an operation with no category is normal, and deleting a category must not take operations with it. |

---

## The windows

The original numbers its windows F01 to F38, and the code keeps those numbers:
the comment at the top of every page names its own. A few worth knowing:

| Number | Name | What it is |
|---|---|---|
| F01 | Fenêtre principale | The home window — a banner, and the menu bar. |
| F02 | Liste opérations du compte | The middle of the application: sixteen columns, the running balance, the three totals. |
| F03 | Fiche opération | Entering or changing one operation. |
| F04 / F06 | Gestion des comptes | The accounts list — F06 is the same window in its *choosing* mode. |
| F05 | Classification rapide | Classifying many operations in one pass. |
| F07 | Soldes de vos comptes | The three balances of every account, and the total. |
| F08 | Fiche compte | One account, and its Outils menu. |
| F17 / F18 | Importation de relevés | Importing a bank statement, and reconciling one of its lines. |
| F20–F24 | Statistiques | The cross-tabulated matrix, on six axes — one page for all six. |
| F26 / F27 | Budget | Entering the budget, and checking whether it was kept. |

---

## The words this project uses about itself

These are not banking terms; they are the vocabulary of the codebase, and they
appear in comments and commit messages.

| Term | What it means |
|---|---|
| **The original** | Radinus 1.9.3, the Windows/WinDev application. It is the specification: when the code and the original disagree, the original wins unless the author says otherwise. |
| **Couture / crossing** | A test that holds the two ends of a seam nothing else links — a command name written in TypeScript and registered in Rust, a Fluent key and the dictionary that serves it. They live in `src-tauri/src/crossings.rs`, and each one exists because a fault got through. |
| **Fiche** | A form window: one record, its fields, its save button. The counterpart of a **liste**. |
| **Bandeau ardoise** (slate panel) | The vertical strip of icon buttons on the right of every window, and the door at its foot. |
| **La porte** (the door) | The exit button. A Radinus window is left by its door; the system's close button is disabled everywhere, which leaves one exit to guard instead of two. |
| **Dressing a window** (`dress()`) | Putting the words on a window. Called when it opens and again whenever the language changes — the same function, which is what guarantees a label added tomorrow follows the language without anyone thinking about it. |
| **Portable mode** | Everything the application needs lives in one folder next to the executable. Nothing is written outside it, so the whole thing runs from a USB drive. Since 05/08/2026 it is **one of two modes**, and not the default: Radinus is portable only when it finds `settings/start_mode.toml` beside itself carrying `portable_mode = 1` (`Decisions.md`, P-36). |
| **Installed mode** | The default. Radinus keeps its data in the operating system's standard folder — `~/Library/Application Support/Radinus` on macOS, `%APPDATA%\Radinus` on Windows, `~/.local/share/radinus` on Linux — while the application itself sits wherever it was installed. |
| **Data root** | The folder holding `settings/`, `databases/`, `backups/` and `logs/`, whichever mode is in force. Resolved once at startup by `location::data_root`. It was called the *portable root* until the installed mode arrived, when the name stopped being true. |
| **Nation number** | The WinDev constant identifying a language: 5 French, 3 English, 7 Spanish. It is what the database stores, because a 1.9.3 backup carries that number. |
