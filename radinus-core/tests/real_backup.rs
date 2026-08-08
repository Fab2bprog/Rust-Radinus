//! The strategic acceptance test: restoring the author's real Radinus 1.9.3
//! archive (PLAN_ACTION.md Phase 1 §1.3, "test automatique permanent sur le
//! zip réel", and JALON 1's acceptance criterion).
//!
//! The archive holds real personal financial data, so whether it is committed
//! alongside the code is the author's call (the repository may become public,
//! PLAN_ACTION.md Phase 16). This test therefore looks for it at
//! `radinus-core/tests/fixtures/` and, when it isn't there, says so loudly on
//! stdout instead of failing: a developer without the fixture must not be
//! blocked, but nobody should mistake a missing fixture for a passing check.
//! Run with `cargo test -- --nocapture` to see the notice.

use std::path::PathBuf;

/// Counts the author confirmed for this archive (JALON 1).
const EXPECTED_ACCOUNTS: usize = 4;
const EXPECTED_OPERATIONS: usize = 2502;
const EXPECTED_CHECKBOOKS: usize = 2;
const EXPECTED_CHECKS: usize = 80;
const EXPECTED_COMMENTS: usize = 175;
const EXPECTED_PAYEES: usize = 46;
const EXPECTED_CATEGORIES: usize = 50;

fn fixture() -> Option<PathBuf> {
    let path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("tests/fixtures/radinus_sauvegarde_20260723115455545.zip");
    path.is_file().then_some(path)
}

#[test]
fn the_authors_real_1_9_3_archive_restores_with_exact_counts() {
    let Some(archive_path) = fixture() else {
        println!(
            "\n*** NOTE: reference archive absent from radinus-core/tests/fixtures/, \
             the strategic restore test did NOT run. ***\n"
        );
        return;
    };

    let db_path = std::env::temp_dir().join("radinus_real_backup_test.sqlite");
    std::fs::remove_file(&db_path).ok();
    let mut conn = radinus_core::database::create_new_database(&db_path).unwrap();

    let report = radinus_core::backup::restore_file_into(&mut conn, &archive_path)
        .expect("the real 1.9.3 archive must restore without error");

    assert_eq!(report.accounts, EXPECTED_ACCOUNTS, "comptes");
    assert_eq!(report.operations, EXPECTED_OPERATIONS, "opérations");
    assert_eq!(report.checkbooks, EXPECTED_CHECKBOOKS, "chéquiers");
    assert_eq!(report.checks, EXPECTED_CHECKS, "chèques");
    assert_eq!(report.comments, EXPECTED_COMMENTS, "commentaires");
    assert_eq!(report.payees, EXPECTED_PAYEES, "tiers");
    assert_eq!(report.categories, EXPECTED_CATEGORIES, "catégories");

    // The report counts what was handed to SQLite; these count what SQLite
    // actually holds, which is the claim that matters.
    let in_database = |table: &str| -> i64 {
        conn.query_row(&format!("SELECT COUNT(*) FROM {table}"), [], |r| r.get(0))
            .unwrap()
    };
    assert_eq!(in_database("Compte"), EXPECTED_ACCOUNTS as i64);
    assert_eq!(in_database("Operation"), EXPECTED_OPERATIONS as i64);
    assert_eq!(in_database("Cheque"), EXPECTED_CHECKS as i64);
    assert_eq!(in_database("Commentaire"), EXPECTED_COMMENTS as i64);

    // The six "Complément" sub-operations of this archive must all have come
    // through as marked sub-operations, and nothing else may be marked.
    let complements: i64 = conn
        .query_row("SELECT COUNT(*) FROM Operation WHERE EstComplement = 1", [], |r| r.get(0))
        .unwrap();
    assert_eq!(complements, 6, "sous-opérations « Complément »");

    let orphan_complements: i64 = conn
        .query_row(
            "SELECT COUNT(*) FROM Operation WHERE EstComplement = 1 AND IDOperationParent = 0",
            [],
            |r| r.get(0),
        )
        .unwrap();
    assert_eq!(orphan_complements, 0);

    std::fs::remove_file(&db_path).ok();
}
