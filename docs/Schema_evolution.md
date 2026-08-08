# Schema evolution

How Radinus creates a database, and how it brings every database already in the
wild up to the shape the current build expects.

Read this before adding, changing or removing anything in the database. It is
short on purpose: the whole mechanism lives in **one file**, and that is what
makes it possible to hold in your head.

---

## 1. What the mechanism does, and what it will never do

**It does, on every single open of a database, without any version number:**

- creates a declared table that is missing — empty;
- adds a declared column that is missing from a table that exists, with its
  type and its default value;
- creates a declared index that is missing;
- refills the three *frozen* nomenclatures when they are found empty.

**It will never:**

- remove a table or a column;
- rename anything;
- change a column's type or its constraints;
- touch a row of user data.

Those four stay **explicit, hand-written steps**. They are rare, they are
dangerous, and they should cost an effort. §7 says how to write one.

The rule behind all of it: *the schema is a declaration, not a history*
(`Decisions.md`, P-33). There is no numbered list of migrations to accumulate
and replay. There is a description of the wanted state, and a comparison made
each time a database opens. What has to change is **deduced**, never recorded.

---

## 2. The files

### The core of it

| File | Role |
|---|---|
| `radinus-core/src/database/schema.rs` | **Everything.** The declaration of the tables, the procedure that restores what is missing, the schema version number, and the one remaining hand-written step. |
| `radinus-core/src/database/seed.rs` | The **initial values**: the prefilled nomenclatures and the single `Parametres` row. Nothing about shape, everything about content. |
| `radinus-core/src/database/mod.rs` | The **two doors**: `create_new_database` and `open_existing_database`. Decides nothing about the schema; it calls. |

The two other files in that folder are unrelated to the schema:
`keygen.rs` produces identifiers, `lock.rs` handles the password (`Decisions.md`,
P-34).

### What ripples outwards

| File | When you touch it |
|---|---|
| `radinus-core/src/domain.rs` | If Rust code has to read the new field. |
| the business module (`accounts.rs`, `operations.rs`, …) | The queries that read or write the table. |
| `radinus-core/src/backup/records.rs` | If the field must travel inside backup archives. 933 hand-written lines — this is where the real work is. |
| `radinus-core/src/backup/writer.rs` | The column list written into the archive. |
| `src-tauri/src/commands.rs` | The DTO handed to a window. |
| `ui/windows/*.ts` | If it must be displayed. |
| `radinus-core/i18n/*.ftl` (18 files) | Any new sentence. |

---

## 3. The single source of truth

`schema.rs` holds one constant, `TABLES`, a slice of `TableDeclaration`:

```rust
struct TableDeclaration {
    name: &'static str,
    table: &'static str,          // the CREATE TABLE IF NOT EXISTS, alone
    indexes: &'static [&'static str],
}
```

One entry per table, twenty-two of them. `Parametres` is **not** in the list —
see §6.

The table and its indexes are separate fields, and that is not tidiness: the
column pass runs between the two, and an index declared on a brand-new column
would otherwise be created before the column existed, and fail.

A complete entry looks like this:

```rust
TableDeclaration {
    name: "Budget",
    table: r#"
    CREATE TABLE IF NOT EXISTS Budget (
        IDBudget      INTEGER PRIMARY KEY,
        Annee         INTEGER NOT NULL,
        Mois          INTEGER NOT NULL,
        IDPosteBudget INTEGER NOT NULL REFERENCES PosteBudget(IDPosteBudget) ON DELETE CASCADE,
        Montant       INTEGER NOT NULL DEFAULT 0
    );
    "#,
    indexes: &[
        r#"CREATE INDEX IF NOT EXISTS idx_budget_annee_mois_poste ON Budget(Annee, Mois, IDPosteBudget);"#,
    ],
},
```

> **No SQL comments inside these strings.** SQLite stores the `CREATE TABLE`
> text verbatim in every user's database, forever — and a `--` comment left in
> it makes `ALTER TABLE … DROP COLUMN` fail with *incomplete input*. Explain
> yourself in Rust comments above the entry instead.

---

## 4. Creating a brand-new database

```
database::create_new_database(path)          mod.rs
  └─ schema::migrate(conn)                   schema.rs
       └─ (no Parametres found → new database)
            schema::create_baseline_schema   PARAMETRES, then every TABLES entry
                                             table first, then its indexes
  └─ seed::seed_initial_data(conn)           seed.rs
```

`seed_initial_data` writes the prefilled nomenclatures — account types, payment
modes, banks, payees, categories, budget lines, cheque statuses — and the single
`Parametres` row carrying the schema version.

**The refill of §5 does not run here.** On a brand-new database every table is
empty, and refilling before `seed_initial_data` would collide on primary keys.

---

## 5. Opening an existing database

```
database::open_existing_database(path, password)     mod.rs
  ├─ Connection::open
  ├─ lock::unlock + lock::readable       → OpenError::Locked if it resists
  ├─ Parametres present?                 → OpenError::NotARadinusDatabase if not
  ├─ VerDataBase > CURRENT_SCHEMA_VERSION → OpenError::UnsupportedSchemaVersion
  └─ schema::migrate(conn)               → returns a SchemaReport
       └─ schema::ensure_the_tables(conn)
            pass 1  every TABLES entry: CREATE TABLE IF NOT EXISTS
            pass 2  schema::ensure_the_columns(conn, &model()?)
            pass 3  every index: CREATE INDEX IF NOT EXISTS
            pass 4  FROZEN nomenclatures found empty are refilled
       └─ schema::language_becomes_a_number(conn)   the one hand-written step
       └─ PRAGMA user_version + Parametres.VerDataBase updated
```

`open_existing_database` returns `Opened { conn, report }`. The report is
`SchemaReport { created, reseeded, columns }` — see §8.

### Pass 2 in detail — how a missing column is noticed

This is the part worth understanding, because nothing is stored anywhere.

1. `schema::model()` opens **a database in memory** — `Connection::open_in_memory` —
   and runs the very same declarations into it. Result: an empty, perfectly
   shaped reference. It never touches the disk and vanishes when dropped.
   Building it costs a few milliseconds, once per open.
2. For each table, `columns_of(conn, name)` and `columns_of(model, name)` ask
   **SQLite itself** — `pragma_table_info` — for the name, declared type,
   mandatory flag and default value of every column. Nothing in this file
   parses SQL. SQLite already parsed it; asking is shorter and correct.
3. Whatever the model has and the real database has not is written by
   `add_column_statement` into an `ALTER TABLE … ADD COLUMN …` carrying the
   type, the mandatory flag and the default **taken from the model**, so the
   column added to an old database is shaped exactly like the one a new
   database gets.
4. Each one is recorded in `report.columns` as `Table.Column`.

**Why the model is built and not shipped.** A blank `.sqlite` embedded in the
binary, or a separate schema description, would be a *second* source of truth.
The day one changes without the other, the software compares real databases
against something false. A model built from the declarations **is** the
declarations, and cannot disagree with them.

**Where the added column lands.** At the end of its table, not at its declared
position — SQLite cannot insert one in the middle without rebuilding the table.
This is invisible everywhere it matters: every query in this crate names its
columns, and so does the archive format.

---

## 6. `Parametres`, the one table apart

`Parametres` is declared in the `PARAMETRES` constant, not in `TABLES`, and it
is **never created when opening a database** — only when creating one.

It is the badge that says *this file is a Radinus database*:
`open_existing_database` recognises one by that table and by nothing else. If
the restore procedure put it back like any other, the check would dissolve by
itself — any `.sqlite` picked by mistake would be turned into a Radinus
database and the message "this is not a Radinus database" could never appear
again.

The price is real and accepted: a database whose `Parametres` is deleted is lost
to the software, with every operation intact inside it (`Decisions.md`, P-33).

---

## 7. Recipes

### Add a table

1. `schema.rs` — add a `TableDeclaration` to `TABLES`, table and indexes
   separate, no SQL comments in the strings.
2. `schema.rs` — add its name to `EXPECTED_TABLES` in the test module, or
   `schema_mirrors_base_sql` fails. This is deliberate: a table appearing or
   disappearing must be a conscious act.
3. `seed.rs` — only if it needs initial values.
4. Business module, `backup/records.rs`, `backup/writer.rs`, DTOs, windows — as
   needed.

Existing databases get the table, empty, at their next open.

### Add a column

1. `schema.rs` — add the line to that table's `CREATE TABLE`. **Give it a
   default value** unless it is nullable; see §8.
2. Nothing else, for the database. Existing databases get it at their next
   open, holding its default on every row already there.
3. `domain.rs`, the business module, `backup/records.rs`, the DTO, the window —
   as needed.

### Add an index

`schema.rs` — one more string in that table's `indexes`. It appears everywhere
at the next open, and it is created after the columns, so an index on a column
added in the same build works.

### Change a column's type, or its constraints

**The mechanism will not do this.** Write an explicit step, and model it on
`language_becomes_a_number` in `schema.rs`, which had to turn
`Parametres.UtiliseLangue` from `TEXT` into `INTEGER`:

- SQLite cannot alter a column's type in place. The table is **rebuilt**: create
  `X_migration`, copy the rows across with the conversion, drop `X`, rename.
- **All of it in one transaction.** Without one, an interruption between the
  drop and the rename leaves a database with neither the old table nor the new,
  and `open_existing_database` then declares a perfectly intact database not to
  be a Radinus one, forever.
- **Drop any leftover scaffolding first** (`DROP TABLE IF EXISTS X_migration`),
  or a database wounded by an interrupted attempt fails on *table already
  exists* and stays unopenable.
- **Look at the database, not at its version number.** That migration's first
  version keyed off the version number and abandoned every database an earlier
  faulty build had already renumbered. It now inspects
  `pragma_table_info` and does nothing when there is nothing to do.
- It is called from `migrate` unconditionally, and it is idempotent.

### Remove a column or a table

Don't. Nothing has ever been removed from a Radinus database, and the rule is
the author's (25/07/2026): he designed that database, and it is not this port's
place to decide a table or a field is superfluous.

If it really must go, it is a table rebuild like the one above, plus removing
the entry from `TABLES` and from `EXPECTED_TABLES`, plus a version bump — and it
belongs in `Decisions.md` with its reason.

### Add a frozen nomenclature

The `FROZEN` constant in `schema.rs` lists the tables refilled when found empty,
with the function that refills them:

```rust
const FROZEN: &[(&str, Refill)] = &[
    ("TypeCompte", super::seed::seed_types_compte),
    ("StatutOperation", super::seed::seed_statuts_operation),
    ("StatutCheque", super::seed::seed_statuts_cheque),
];
```

Only closed lists belong here — content that comes from the software and that
the user cannot extend. Banks, payees, categories and budget lines are the
user's: emptying one can be a choice, and they are never refilled.

---

## 8. What SQLite refuses, and why that is good news

`ALTER TABLE … ADD COLUMN` cannot add:

- **a primary key** — declared at the table's birth, never missing on its own;
- **a mandatory column with no default value** — there would be nothing to
  write in the rows already there.

`schema::restorable` encodes both. A column it rejects is **skipped**, not
attempted: failing would turn a hole in one table into a database that refuses
to open at all, which is strictly worse.

Thirty-one columns inherited from `base.sql` fall in that second category —
`Operation.Libelle`, `Compte.Libelle`, `Budget.Annee` and so on. They are
legitimate where they are, declared at their table's birth. They are also
**unrestorable**: if one is lost, this mechanism cannot put it back.

The test `toute_colonne_obligatoire_porte_une_valeur_par_defaut` names all
thirty-one, so that **adding a thirty-second breaks it**. Give your new
mandatory column a default value — or add it to the list knowing it will appear
in fresh databases and silently never in anyone else's.

This is also the author's rule of 25/07/2026 seen from another angle: *a restore
must never be refused because an old archive lacks a field*. That only holds if
every field has something to fall back on.

---

## 9. The guards

Six tests, all in `schema.rs`. When one turns red, it is telling you something
about the database, not about itself.

| Test | Refuses |
|---|---|
| `aucune_colonne_ne_peut_manquer_sans_revenir` | Drops **each column of each table**, one at a time — its indexes first, since SQLite refuses to drop an indexed column — reopens, and checks the column is back with the same type, mandatory flag and default, and its indexes with it. 93 cases today. |
| `toute_colonne_obligatoire_porte_une_valeur_par_defaut` | A new mandatory column with no default. See §8. |
| `le_modele_en_memoire_est_le_schema_reel` | The in-memory model drifting from what a real database gets. If those two could differ, every comparison would be worthless. |
| `schema_mirrors_base_sql` | A table appearing or disappearing without `EXPECTED_TABLES` being updated. |
| `the_columns_dropped_by_mistake_are_present` | The three columns an early build had silently dropped. |
| `an_older_database_is_brought_back_to_the_mirror_without_losing_anything` | An old database losing its data while being brought up to date. |

Plus, in `mod.rs`: `une_table_effacee_revient_a_l_ouverture_suivante`,
`une_nomenclature_figee_videe_est_regarnie`,
`la_carte_d_identite_n_est_jamais_recreee`.

---

## 10. The version number

`CURRENT_SCHEMA_VERSION` in `schema.rs`, mirrored into `PRAGMA user_version` and
into `Parametres.VerDataBase`.

**It is no longer the engine of ordinary evolution.** Adding a table, a column
or an index needs no version bump: those happen on every open, unconditionally.

Two things still use it:

- **Refusing a database from a newer build.** `open_existing_database` returns
  `UnsupportedSchemaVersion` rather than misreading a schema it does not know.
- **Ordering the rare hand-written steps** of §7 — the rebuilds.

Bump it when you write one of those. Not otherwise.

It is a single continuous number line that Radinus 1.x already walked from 0 to
9; 10 is the first version of its own (`Parametres.UtiliseLangue` becoming an
integer). A 1.9.3 backup carries 9 and restores into a database already at 10.

---

## 11. What the user sees

Every table recreated, every column added and every nomenclature refilled writes
one line in the journal (⌘H), without interrupting anything. The wiring:

- `SchemaReport` travels out of the core inside `Opened`;
- `connect_and_start` in `src-tauri/src/commands.rs` turns it into journal
  entries, **after** `state.attach` — which throws away everything belonging to
  the previous database, the journal included;
- the sentences are the Fluent keys `journal-step-table-created`,
  `journal-step-column-added` and `journal-step-refill`, in all eighteen
  languages.

The ordinary case — a complete database — writes nothing at all.

**And the reason this matters.** Before P-33, a deleted table made Radinus fail
loudly on the first query. Now it comes back **empty**, and the software runs,
showing operations whose category no longer exists. A visible failure was traded
for a silent hole; the journal line is what keeps the hole from being invisible.
The same goes for a column: it arrives holding its default value on every
existing row, which is not the same thing as the data coming back.
