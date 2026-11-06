//! Tests sur les fichiers de référence A à F (spécification, document 06).
//!
//! Placer les fichiers dans `mny-reader/tests/data/` (jamais commités : `.gitignore`) sous les noms `A.mny` … `F.mny`
//! (ou définir `MNY_TEST_DATA` vers un autre dossier). Un fichier absent fait sauter le test.

use std::path::PathBuf;

use mny_reader::{Error, KeyScheme, MnyFile, Value};

fn path(letter: &str) -> Option<PathBuf> {
    let dir = std::env::var_os("MNY_TEST_DATA")
        .map(PathBuf::from)
        .unwrap_or_else(|| PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/data"));
    let p = dir.join(format!("{letter}.mny"));
    if p.exists() {
        Some(p)
    } else {
        eprintln!("fichier de référence {letter}.mny absent : test ignoré");
        None
    }
}

fn hex(b: &[u8]) -> String {
    b.iter().map(|x| format!("{x:02x}")).collect()
}

fn text(v: &Value) -> &str {
    match v {
        Value::Text(s) => s,
        other => panic!("texte attendu, obtenu {other:?}"),
    }
}

/// Quatre premières lignes de CRNC : (hcrnc, szName, lcid, szIsoCode, szSymbol).
fn check_crnc(mny: &MnyFile, expected: [(i32, &str, i32, &str, &str); 4]) {
    let t = mny.table("CRNC").unwrap();
    let ix = |n: &str| t.column_index(n).unwrap();
    let (h, n, l, iso, sym) = (
        ix("hcrnc"),
        ix("szName"),
        ix("lcid"),
        ix("szIsoCode"),
        ix("szSymbol"),
    );
    let rows: Vec<_> = t.rows().unwrap().take(4).map(|r| r.unwrap()).collect();
    for (row, e) in rows.iter().zip(expected) {
        assert_eq!(row[h], Value::Int32(e.0));
        assert_eq!(text(&row[n]), e.1);
        assert_eq!(row[l], Value::Int32(e.2));
        assert_eq!(text(&row[iso]), e.3);
        assert_eq!(text(&row[sym]), e.4);
    }
}

fn count(mny: &MnyFile, table: &str) -> usize {
    let mut n = 0;
    for row in mny.table(table).unwrap().rows().unwrap() {
        row.unwrap();
        n += 1;
    }
    n
}

#[test]
fn fichier_a() {
    let Some(p) = path("A") else { return };
    let mny = MnyFile::open(p, None).unwrap();
    let e = mny.encryption();
    assert_eq!(e.flags, 0x1D);
    assert_eq!(e.scheme, KeyScheme::Modern { sha1: false });
    assert!(e.password_checkable);
    assert_eq!(hex(&e.base_key), "fd4b38e94292e00251b9f39c47ee5710643b0616");
    assert_eq!(mny.page_count(), 929);
    assert_eq!(mny.tables().len(), 85);
    assert_eq!(mny.money_tables().count(), 81);
    assert_eq!(count(&mny, "TRN"), 8);
    assert_eq!(count(&mny, "CAT"), 140);
    assert_eq!(count(&mny, "CRNC"), 144);
    // Lignes déplacées : 15 lignes réelles, 10 annoncées.
    let tax = mny.table("Tax Rate Custom Pool").unwrap();
    assert_eq!(tax.declared_row_count(), 10);
    assert_eq!(count(&mny, "Tax Rate Custom Pool"), 15);
    assert_eq!(count(&mny, "XBAG"), 2);
    // GUID de la première transaction.
    let trn = mny.table("TRN").unwrap();
    let g = trn.column_index("sguid").unwrap();
    let first = trn.rows().unwrap().next().unwrap().unwrap();
    match &first[g] {
        Value::Guid(x) => assert_eq!(x.to_string(), "{AD215CBE-26FE-3FFA-84B2-6E6001FED7DD}"),
        v => panic!("{v:?}"),
    }
    check_crnc(
        &mny,
        [
            (1, "Peso argentin", 11274, "ARS", "/ARSUS"),
            (2, "Dollar australien", 3081, "AUD", "/AUDUS"),
            (3, "Schilling autrichien", 3079, "ATS", "/ATSUS"),
            (4, "Franc belge", 2060, "BEF", "/BECUS"),
        ],
    );
}

#[test]
fn fichier_b() {
    let Some(p) = path("B") else { return };
    let mny = MnyFile::open(p, None).unwrap();
    assert_eq!(mny.encryption().scheme, KeyScheme::Modern { sha1: true });
    assert_eq!(
        hex(&mny.encryption().base_key),
        "b80de5d138758541c5f05265ad144ab9b9778494"
    );
    assert_eq!(mny.money_tables().count(), 83);
    check_crnc(
        &mny,
        [
            (1, "Argentine peso", 11274, "ARS", "/ARSUS"),
            (2, "Australian dollar", 3081, "AUD", "/AUDUS"),
            (3, "Austrian schilling", 3079, "ATS", "/ATSUS"),
            (4, "Belgian franc", 2060, "BEF", "/BEFUS"),
        ],
    );
    // dtSerial de la ligne 1 : 2010-10-30 13:55:38.000 (arrondi à la ms).
    let t = mny.table("CRNC").unwrap();
    let c = t.column_index("dtSerial").unwrap();
    let row = t.rows().unwrap().next().unwrap().unwrap();
    match row[c] {
        Value::DateTime(d) => assert_eq!(
            d.to_naive()
                .unwrap()
                .format("%Y-%m-%d %H:%M:%S%.3f")
                .to_string(),
            "2010-10-30 13:55:38.000"
        ),
        ref v => panic!("{v:?}"),
    }
}

#[test]
fn fichier_c_mot_de_passe() {
    let Some(p) = path("C") else { return };
    assert!(matches!(MnyFile::open(&p, None), Err(Error::WrongPassword)));
    assert!(matches!(
        MnyFile::open(&p, Some("WrongPassword")),
        Err(Error::WrongPassword)
    ));
    let mny = MnyFile::open(&p, Some("Test12345")).unwrap();
    assert_eq!(
        hex(&mny.encryption().base_key),
        "ec6cc250ce16d2f66b5d72fd9236a62b73cb9796"
    );
    assert_eq!(mny.money_tables().count(), 83);
}

#[test]
fn fichier_d_sans_controle() {
    let Some(p) = path("D") else { return };
    let mny = MnyFile::open(p, None).unwrap();
    assert!(!mny.encryption().password_checkable);
    assert_eq!(
        hex(&mny.encryption().base_key),
        "fd4b38e94292e00251b9f39c47ee5710ee183156"
    );
    assert_eq!(mny.money_tables().count(), 86);
    check_crnc(
        &mny,
        [
            (1, "Argentinian peso", 11274, "ARS", "/ARSUS"),
            (2, "Australian dollar", 3081, "AUD", "/AUDUS"),
            (3, "Austrian schilling", 3079, "ATS", "/ATSUS"),
            (4, "Belgian franc", 2060, "BEF", "/BECUS"),
        ],
    );
}

#[test]
fn fichiers_e_f_schema_historique() {
    for (letter, key, pwd) in [
        ("E", "3dbb747e", None),
        ("F", "9f9e747e", Some("TEST12345")),
    ] {
        let Some(p) = path(letter) else { continue };
        let mny = MnyFile::open(p, None).unwrap();
        assert_eq!(mny.encryption().scheme, KeyScheme::Legacy);
        assert_eq!(hex(&mny.encryption().base_key), key);
        assert_eq!(mny.encryption().legacy_password.as_deref(), pwd);
        assert_eq!(mny.money_tables().count(), 66);
        check_crnc(
            &mny,
            [
                (1, "Argentinean peso", 11274, "ARS", "/ARSUS"),
                (2, "Australian dollar", 3081, "AUD", "/AUDUS"),
                (3, "Austrian schilling", 3079, "ATS", "/ATSUS"),
                (4, "Belgian franc", 2060, "BEF", "/BECUS"),
            ],
        );
    }
}

/// Toutes les tables de tous les fichiers se décodent sans aucune valeur invalide.
#[test]
fn non_regression_toutes_tables() {
    for (letter, pwd) in [
        ("A", None),
        ("B", None),
        ("C", Some("Test12345")),
        ("D", None),
        ("E", None),
        ("F", None),
    ] {
        let Some(p) = path(letter) else { continue };
        let mny = MnyFile::open(p, pwd).unwrap();
        for info in mny.tables() {
            for row in mny.table(&info.name).unwrap().rows().unwrap() {
                let row = row.unwrap();
                for v in row.values() {
                    assert!(
                        !matches!(v, Value::Invalid(_)),
                        "{letter} {} : {v:?}",
                        info.name
                    );
                }
            }
        }
    }
}
