//! Key generator reproducing WinDev's `Genere_Clef()` behaviour: **max(existing
//! id) + 1**, CONFIRMED in 02_BASE_DE_DONNEES.md §7.1 rule 1. No SGBD
//! auto-increment is used anywhere in this schema (see schema.rs) — every
//! insert must go through [`next_id`] first, including during backup restore,
//! to guarantee id uniqueness the same way the original application did.

use rusqlite::{Connection, Result};

/// Returns the next id to use when inserting into `table`'s `id_column`:
/// `MAX(id_column) + 1`, or `1` if the table is empty. Every table's id
/// column has its own French name (`IDCompte`, `IDOperation`, ...; see
/// `schema.rs`), so both must be supplied explicitly — there is no single
/// default column name to assume.
///
/// `table` and `id_column` must be compile-time-known, trusted identifiers
/// (module-internal table/column name constants, never external/user input)
/// — they are interpolated directly into the SQL text, as rusqlite has no
/// parameter placeholder for identifiers.
pub fn next_id(conn: &Connection, table: &str, id_column: &str) -> Result<i64> {
    let sql = format!("SELECT COALESCE(MAX({id_column}), 0) + 1 FROM {table}");
    conn.query_row(&sql, [], |row| row.get(0))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database::schema::migrate;

    fn memory_conn() -> Connection {
        let conn = Connection::open_in_memory().unwrap();
        migrate(&conn).unwrap();
        conn
    }

    #[test]
    fn next_id_is_one_on_empty_table() {
        let conn = memory_conn();
        assert_eq!(next_id(&conn, "Banques", "IDBanques").unwrap(), 1);
    }

    #[test]
    fn next_id_is_max_plus_one() {
        let conn = memory_conn();
        conn.execute(
            "INSERT INTO Banques (IDBanques, NomBanque) VALUES (1, 'A')",
            [],
        )
        .unwrap();
        conn.execute(
            "INSERT INTO Banques (IDBanques, NomBanque) VALUES (5, 'B')",
            [],
        )
        .unwrap();
        assert_eq!(next_id(&conn, "Banques", "IDBanques").unwrap(), 6);
    }

    #[test]
    fn next_id_fills_gap_correctly_after_deletion() {
        // WinDev's max+1 behaviour does NOT reuse deleted ids below the
        // current max — it only reuses ids once they're above every
        // remaining row. Confirms next_id tracks MAX(), not COUNT().
        let conn = memory_conn();
        conn.execute(
            "INSERT INTO Banques (IDBanques, NomBanque) VALUES (1, 'A')",
            [],
        )
        .unwrap();
        conn.execute(
            "INSERT INTO Banques (IDBanques, NomBanque) VALUES (2, 'B')",
            [],
        )
        .unwrap();
        conn.execute("DELETE FROM Banques WHERE IDBanques = 2", [])
            .unwrap();
        assert_eq!(next_id(&conn, "Banques", "IDBanques").unwrap(), 2);
    }
}
