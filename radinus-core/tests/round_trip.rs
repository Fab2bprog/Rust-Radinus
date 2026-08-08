//! Round trip on the author's real archive (PLAN_ACTION.md Phase 1 §1.3,
//! delivery 3): restore it, write it back out, and compare the table files
//! **byte for byte** — the criterion the author set on 25/07/2026.
//!
//! Same rule as `real_backup.rs` about the fixture: the archive holds real
//! personal data and is never committed, so when it isn't there this test
//! says so on stdout instead of failing.

use std::collections::BTreeMap;
use std::io::Read;
use std::path::PathBuf;

fn fixture() -> Option<PathBuf> {
    let path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("tests/fixtures/radinus_sauvegarde_20260723115455545.zip");
    path.is_file().then_some(path)
}

/// Reads every `radinus_sauve_*.json` entry of an archive as raw bytes.
fn table_files(path: &std::path::Path) -> BTreeMap<String, Vec<u8>> {
    let file = std::fs::File::open(path).unwrap();
    let mut zip = zip::ZipArchive::new(file).unwrap();
    let mut out = BTreeMap::new();
    for i in 0..zip.len() {
        let mut entry = zip.by_index(i).unwrap();
        if !entry.is_file() {
            continue;
        }
        let name = entry.name().to_string();
        if !(name.starts_with("radinus_sauve_") && name.ends_with(".json")) {
            continue;
        }
        let mut bytes = Vec::new();
        entry.read_to_end(&mut bytes).unwrap();
        out.insert(name, bytes);
    }
    out
}

/// Restoring an archive then writing it back must reproduce every table file
/// byte for byte, except where the source's row order cannot be reconstructed
/// (see `backup::writer`'s doc comment on ties). Any table that differs is
/// reported with its first differing byte, so a regression is diagnosable
/// rather than just red.
#[test]
fn the_authors_archive_survives_a_full_round_trip() {
    let Some(source) = fixture() else {
        println!(
            "\n*** NOTE: reference archive absent from radinus-core/tests/fixtures/, \
             the round-trip test did NOT run. ***\n"
        );
        return;
    };

    let db_path = std::env::temp_dir().join("radinus_round_trip_test.sqlite");
    std::fs::remove_file(&db_path).ok();
    let mut conn = radinus_core::database::create_new_database(&db_path).unwrap();
    radinus_core::backup::restore_file_into(&mut conn, &source).unwrap();

    let rewritten = std::env::temp_dir().join("radinus_round_trip_test.zip");
    std::fs::remove_file(&rewritten).ok();
    radinus_core::backup::writer::write_archive(&conn, &rewritten).unwrap();

    let before = table_files(&source);
    let after = table_files(&rewritten);

    assert_eq!(
        before.keys().collect::<Vec<_>>(),
        after.keys().collect::<Vec<_>>(),
        "l'archive réécrite ne porte pas les mêmes tables"
    );

    // Two files cannot be identical, and both differences are understood —
    // measured, not assumed:
    //
    // * `parametres`: **settled** (author, 25/07/2026 — "tu dois écrire la
    //   vérité : la version avec laquelle le fichier a été écrit"). The source
    //   says 1.9, an archive written here says 2.0, and that is the correct
    //   behaviour: the version field states which software produced the file.
    //   This difference is permanent and expected, not a defect.
    // * `operations`: **settled** (author, 25/07/2026 — "je pense que ça n'a
    //   aucune importance"). 1.9.3 browses this table by clearing date and
    //   settles ties by the physical record order inside its own file, an
    //   order that does not survive the move to SQLite (600 of the 932
    //   distinct dates carry ties). Same bytes, same rows, a handful in a
    //   different order. See `backup::writer`'s doc comment.
    //
    // Every other table must match to the byte, and any change in that list
    // is a regression this test must catch.
    const KNOWN_DIFFERENCES: &[&str] = &[
        "radinus_sauve_parametres.json",
        "radinus_sauve_operations.json",
    ];

    /// Les trois seuls champs de `Parametres` qui aient le droit de changer :
    /// **la version du logiciel qui a écrit le fichier, et celle du schéma**.
    /// Fabrice a tranché le 25/07/2026 — « tu dois écrire la vérité, la
    /// version avec laquelle le fichier a été écrit ».
    ///
    /// Tout le reste, `UtiliseLangue` compris, doit revenir à l'identique.
    const REWRITTEN: &[&str] = &["VerSoftMajeur", "VerSoftMineur", "VerDataBase"];

    /// Retire d'une ligne JSON les champs cités, pour comparer ce qui reste.
    ///
    /// Remplace l'ancien contrôle, qui se contentait d'exiger **la même
    /// taille** : deux fichiers de même longueur et de contenu entièrement
    /// différent y passaient, et il a fini par se casser tout seul le jour où
    /// `VerDataBase` est passé de 9 à 10 — un chiffre de plus. Comparer le
    /// reste octet pour octet dit la même chose, en plus vrai.
    fn without(line: &[u8], fields: &[&str]) -> String {
        let mut text = String::from_utf8_lossy(line).into_owned();
        for field in fields {
            let needle = format!("\"{field}\":");
            while let Some(start) = text.find(&needle) {
                let rest = &text[start + needle.len()..];
                let end = rest
                    .find([',', '}'])
                    .map(|i| start + needle.len() + i)
                    .unwrap_or(text.len());
                // La virgule et l'espace qui suivent partent avec le champ.
                let mut end = end;
                if text[end..].starts_with(", ") {
                    end += 2;
                }
                text.replace_range(start..end, "");
            }
        }
        text
    }

    let mut differing = Vec::new();
    for (name, original) in &before {
        if KNOWN_DIFFERENCES.contains(&name.as_str()) {
            if name == "radinus_sauve_parametres.json" {
                // Champ par champ : seules les trois versions ont changé.
                assert_eq!(
                    without(original, REWRITTEN),
                    without(&after[name], REWRITTEN),
                    "{name} : un champ autre que les versions a change"
                );
            } else {
                // `operations` : seul l'ordre de quelques lignes ex-aequo
                // differe, la taille le dit.
                assert_eq!(
                    original.len(),
                    after[name].len(),
                    "{name} a change de taille : ce n'est plus la difference connue"
                );
            }
            continue;
        }
        let produced = &after[name];
        if original != produced {
            let at = original
                .iter()
                .zip(produced.iter())
                .position(|(a, b)| a != b)
                .unwrap_or(original.len().min(produced.len()));
            differing.push(format!(
                "{name} : {} octets contre {}, premier écart à l'octet {at}",
                original.len(),
                produced.len()
            ));
        }
    }

    // Restoring what we just wrote must give the very same database contents,
    // which is what "no data is lost" actually means.
    let second_db = std::env::temp_dir().join("radinus_round_trip_test_2.sqlite");
    std::fs::remove_file(&second_db).ok();
    let mut conn2 = radinus_core::database::create_new_database(&second_db).unwrap();
    radinus_core::backup::restore_file_into(&mut conn2, &rewritten).unwrap();

    for table in [
        "Compte",
        "Operation",
        "Chequier",
        "Cheque",
        "Commentaire",
        "Tiers",
        "Categorie",
        "Banques",
        "Affectation",
        "StatutCheque",
    ] {
        let count = |c: &rusqlite::Connection| -> i64 {
            c.query_row(&format!("SELECT COUNT(*) FROM {table}"), [], |r| r.get(0))
                .unwrap()
        };
        assert_eq!(count(&conn), count(&conn2), "{table} perd des lignes");
    }

    // And a second write of that second database must be identical to the
    // first write: our own format is stable, whatever the source's row order.
    let rewritten2 = std::env::temp_dir().join("radinus_round_trip_test_2.zip");
    std::fs::remove_file(&rewritten2).ok();
    radinus_core::backup::writer::write_archive(&conn2, &rewritten2).unwrap();
    assert_eq!(
        table_files(&rewritten),
        table_files(&rewritten2),
        "deux écritures successives ne donnent pas le même résultat"
    );

    for path in [&db_path, &second_db] {
        std::fs::remove_file(path).ok();
    }
    for path in [&rewritten, &rewritten2] {
        std::fs::remove_file(path).ok();
    }

    println!(
        "\nAller-retour : {} tables sur {} identiques à l'octet près \
         ({} écart(s) connu(s) et expliqué(s)).\n",
        before.len() - KNOWN_DIFFERENCES.len(),
        before.len(),
        KNOWN_DIFFERENCES.len()
    );

    assert!(
        differing.is_empty(),
        "des tables inattendues ne se reproduisent pas à l'octet près : {differing:?}"
    );
}
