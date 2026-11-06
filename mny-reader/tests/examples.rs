//! Tests sur les fichiers Money d'exemple de Fabrice (05/11/2026).
//!
//! **Aucun fichier `.mny` n'entre dans le dépôt** (Fabrice : « je n'ai pas
//! envie que tu me pollues le dépôt avec des fichiers mny »). Les exemples
//! restent sur son Mac, dans `Analyse/mnyimport/Exemples mny`, à côté du
//! dossier du dépôt ; `MNY_EXAMPLES` peut désigner un autre dossier. Sans
//! dossier, ou sans fichier dedans, le test le dit et passe.
//!
//! Il ne compte rien de propre à un fichier : il vérifie que **chaque**
//! exemple s'ouvre sans mot de passe et que les quatre tables qu'un import lit
//! — comptes, opérations, catégories, tiers — se lisent jusqu'à la dernière
//! ligne, sans une valeur illisible.

use std::path::PathBuf;

use mny_reader::{MnyFile, Value};

fn examples() -> Vec<PathBuf> {
    let dir = std::env::var_os("MNY_EXAMPLES")
        .map(PathBuf::from)
        .unwrap_or_else(|| {
            PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("../../Analyse/mnyimport/Exemples mny")
        });
    let Ok(entries) = std::fs::read_dir(&dir) else {
        eprintln!(
            "dossier d'exemples absent ({}) : test ignoré",
            dir.display()
        );
        return Vec::new();
    };
    let mut files: Vec<PathBuf> = entries
        .filter_map(|entry| entry.ok().map(|entry| entry.path()))
        .filter(|path| {
            path.extension()
                .is_some_and(|extension| extension.eq_ignore_ascii_case("mny"))
        })
        .collect();
    files.sort();
    if files.is_empty() {
        eprintln!("aucun .mny dans {} : test ignoré", dir.display());
    }
    files
}

#[test]
fn chaque_exemple_se_lit_entierement() {
    for path in examples() {
        let name = path.display().to_string();
        let mny = MnyFile::open(&path, None).unwrap_or_else(|error| panic!("{name} : {error}"));
        for table in ["ACCT", "TRN", "CAT", "PAY"] {
            let read = mny
                .table(table)
                .unwrap_or_else(|error| panic!("{name}, {table} : {error}"));
            let mut count = 0;
            for row in read
                .rows()
                .unwrap_or_else(|error| panic!("{name}, {table} : {error}"))
            {
                let row = row.unwrap_or_else(|error| panic!("{name}, {table} : {error}"));
                for value in row.values() {
                    assert!(
                        !matches!(value, Value::Invalid(_)),
                        "{name}, {table}, ligne {count} : {value:?}"
                    );
                }
                count += 1;
            }
            assert!(
                table == "TRN" || count > 0,
                "{name} : la table {table} est vide"
            );
        }
    }
}
