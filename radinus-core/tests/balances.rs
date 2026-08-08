//! The acceptance test of JALON 2, on the author's real data: restore his
//! 1.9.3 archive — which carries the balances Windows itself computed — then
//! recompute them from scratch and compare.
//!
//! Same fixture rule as the other integration tests: the archive holds real
//! personal data, is never committed, and its absence prints a notice instead
//! of failing.

use std::collections::HashMap;
use std::path::PathBuf;

/// The figures the author confirmed for these four accounts, in euros
/// (PLAN_ACTION.md Phase 2.1). Hard-coded on top of the comparison with the
/// archive, so a silent change on either side is caught.
const EXPECTED_BANK_BALANCES: &[(&str, &str)] = &[
    ("CCP", "1549.81"),
    ("Livret A", "23422.81"),
    ("LDDS", "8228.3"),
    ("LEP", "11348.89"),
];

fn fixture() -> Option<PathBuf> {
    let path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("tests/fixtures/radinus_sauvegarde_20260723115455545.zip");
    path.is_file().then_some(path)
}

/// Micro-units as a plain decimal, for readable failures.
fn euros(micros: i64) -> String {
    let sign = if micros < 0 { "-" } else { "" };
    let magnitude = micros.unsigned_abs();
    let mut decimals = format!("{:06}", magnitude % 1_000_000);
    while decimals.ends_with('0') {
        decimals.pop();
    }
    if decimals.is_empty() {
        format!("{sign}{}", magnitude / 1_000_000)
    } else {
        format!("{sign}{}.{decimals}", magnitude / 1_000_000)
    }
}

#[test]
fn recomputing_the_authors_balances_gives_the_windows_figures() {
    let Some(archive) = fixture() else {
        println!(
            "\n*** NOTE: reference archive absent from radinus-core/tests/fixtures/, \
             the balance test did NOT run. ***\n"
        );
        return;
    };

    let db_path = std::env::temp_dir().join("radinus_balances_test.sqlite");
    std::fs::remove_file(&db_path).ok();
    let mut conn = radinus_core::database::create_new_database(&db_path).unwrap();
    radinus_core::backup::restore_file_into(&mut conn, &archive).unwrap();

    // What Windows itself wrote, straight out of the archive.
    let mut before: HashMap<i64, (String, i64, i64, i64, )> = HashMap::new();
    {
        let mut stmt = conn
            .prepare("SELECT IDCompte, Libelle, SoldeBanque, SoldeReel, SoldeFinal FROM Compte")
            .unwrap();
        let rows = stmt
            .query_map([], |r| {
                Ok((
                    r.get::<_, i64>(0)?,
                    r.get::<_, String>(1)?,
                    r.get::<_, i64>(2)?,
                    r.get::<_, i64>(3)?,
                    r.get::<_, i64>(4)?,
                ))
            })
            .unwrap();
        for row in rows {
            let (id, label, bank, real, final_) = row.unwrap();
            before.insert(id, (label, bank, real, final_));
        }
    }

    // And the running balance Windows stamped on each operation.
    let mut pointed_before: HashMap<i64, i64> = HashMap::new();
    {
        let mut stmt = conn
            .prepare("SELECT IDOperation, SoldePointe FROM Operation WHERE IDOperationParent = 0")
            .unwrap();
        for row in stmt
            .query_map([], |r| Ok((r.get::<_, i64>(0)?, r.get::<_, i64>(1)?)))
            .unwrap()
        {
            let (id, balance) = row.unwrap();
            pointed_before.insert(id, balance);
        }
    }

    radinus_core::balances::update_all_accounts(&conn).unwrap();

    // --- The three totals of every account must match, to the cent. -------
    for (id, (label, bank, real, final_)) in &before {
        let (new_bank, new_real, new_final): (i64, i64, i64) = conn
            .query_row(
                "SELECT SoldeBanque, SoldeReel, SoldeFinal FROM Compte WHERE IDCompte = ?1",
                [id],
                |r| Ok((r.get(0)?, r.get(1)?, r.get(2)?)),
            )
            .unwrap();
        assert_eq!(
            (new_bank, new_real, new_final),
            (*bank, *real, *final_),
            "{label} : recalcul {} / {} / {} contre Windows {} / {} / {}",
            euros(new_bank),
            euros(new_real),
            euros(new_final),
            euros(*bank),
            euros(*real),
            euros(*final_)
        );

        if let Some((_, expected)) = EXPECTED_BANK_BALANCES
            .iter()
            .find(|(name, _)| *name == label)
        {
            assert_eq!(&euros(new_bank), expected, "solde en banque de {label}");
        }
    }

    // --- Every SoldePointe must match, except inside a same-date tie. -----
    //
    // Windows settles operations sharing a clearing date by the physical
    // record order of its own file, which does not survive the move to
    // SQLite (see `balances`'s doc comment). Rather than tolerate a count,
    // this checks the *reason*: any operation whose running balance changed
    // must share its clearing date with another operation of the same
    // account. A mismatch on an operation alone on its date would be a real
    // bug, and fails here.
    let mut mismatched = 0usize;
    let mut unexplained = Vec::new();
    {
        let mut stmt = conn
            .prepare(
                "SELECT o.IDOperation, o.SoldePointe, o.DatePointage, o.IDCompte,
                        (SELECT COUNT(*) FROM Operation p
                          WHERE p.IDCompte = o.IDCompte
                            AND p.IDOperationParent = 0
                            AND p.DatePointage IS o.DatePointage)
                 FROM Operation o
                 WHERE o.IDOperationParent = 0",
            )
            .unwrap();
        for row in stmt
            .query_map([], |r| {
                Ok((
                    r.get::<_, i64>(0)?,
                    r.get::<_, i64>(1)?,
                    r.get::<_, Option<String>>(2)?,
                    r.get::<_, i64>(3)?,
                    r.get::<_, i64>(4)?,
                ))
            })
            .unwrap()
        {
            let (id, now, date, account, same_date_count) = row.unwrap();
            let then = pointed_before[&id];
            if now != then {
                mismatched += 1;
                if same_date_count <= 1 {
                    unexplained.push(format!(
                        "opération {id} (compte {account}, {date:?}) : {} contre {}",
                        euros(now),
                        euros(then)
                    ));
                }
            }
        }
    }

    println!(
        "\nSoldePointe : {} / {} identiques à Windows au centime ; \
         {mismatched} écart(s), tous à l'intérieur d'un ex-æquo de date de pointage.\n",
        pointed_before.len() - mismatched,
        pointed_before.len()
    );

    assert!(
        unexplained.is_empty(),
        "des SoldePointe diffèrent sans ex-æquo pour l'expliquer : {unexplained:#?}"
    );

    std::fs::remove_file(&db_path).ok();
}
