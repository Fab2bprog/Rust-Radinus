//! Le test d'acceptation de la phase 8 : le **vrai** relevé OFX de la banque
//! de Fabrice, lu en entier (`PLAN_ACTION.md` phase 8, « fichier réel 151
//! transactions »).
//!
//! Un échantillon écrit à la main prouve qu'on sait lire ce qu'on a imaginé ;
//! il ne prouve rien sur ce qu'une banque envoie réellement. Celui-ci est le
//! fichier tel qu'il sort de La Banque Postale : OFX 1.02 SGML, tout sur une
//! seule ligne, balises terminales non fermées, 151 opérations.
//!
//! Le fichier porte des données bancaires réelles — un numéro de compte, des
//! soldes, des libellés qui nomment des commerçants. Il n'est donc **jamais
//! commité** (`.gitignore`), et ce test le cherche dans
//! `radinus-core/tests/fixtures/` : absent, il le dit haut et fort sur la
//! sortie plutôt que d'échouer, comme le fait déjà le test de l'archive réelle.
//! Un développeur sans le fichier ne doit pas être bloqué, et personne ne doit
//! prendre une absence pour une réussite.
//!
//!     cargo test --test real_ofx -- --nocapture

use radinus_core::ofx_import;
use std::path::PathBuf;

/// Ce que Fabrice a confirmé pour ce fichier.
///
/// **Le numéro de compte n'est pas écrit ici, et ne doit jamais l'être** : il
/// y était, et c'était une donnée bancaire réelle posée dans un dépôt de code
/// (08/08/2026). Le test le lit dans le fichier au lieu de le nommer, ce qui
/// vérifie d'ailleurs la même chose en mieux — que le module trouve un compte
/// et un seul, quel qu'il soit. Même règle pour les soldes, relus du texte
/// brut plutôt que recopiés.
const EXPECTED_TRANSACTIONS: usize = 151;

fn fixture() -> Option<PathBuf> {
    let path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("tests/fixtures/Fichier ofx exemple.ofx");
    path.is_file().then_some(path)
}

#[test]
fn le_releve_reel_se_lit_en_entier() {
    let Some(path) = fixture() else {
        println!(
            "\n[real_ofx] Le relevé réel est absent de radinus-core/tests/fixtures/ : \
             ce test n'a rien vérifié.\n"
        );
        return;
    };
    let text = ofx_import::decode(&std::fs::read(&path).expect("le relevé est illisible"));

    // Un seul compte dans ce fichier.
    let accounts = ofx_import::accounts_in(&text);
    assert_eq!(accounts.len(), 1, "le relevé ne porte pas un compte et un seul");
    let account = &accounts[0];

    let statement = ofx_import::read(&text, account).expect("le relevé du compte");
    assert_eq!(statement.transactions.len(), EXPECTED_TRANSACTIONS);

    // **Les deux bouts du fichier.** Le solde comptable et le solde disponible
    // sont ici égaux — c'est le cas ordinaire — et la période est celle que la
    // banque annonce.
    let announced = |tag: &str| -> i64 {
        let piece = text.split(tag).nth(1).expect("le solde annoncé");
        let amount = piece.split("<BALAMT>").nth(1).unwrap_or_default();
        let amount = amount.split('<').next().unwrap_or_default();
        let (whole, cents) = amount.split_once('.').unwrap_or((amount, "0"));
        whole.parse::<i64>().unwrap_or(0) * 1_000_000
            + format!("{cents:0<2}")[..2].parse::<i64>().unwrap_or(0) * 10_000
    };
    assert_eq!(statement.ledger_balance, Some(announced("<LEDGERBAL>")));
    assert_eq!(statement.available_balance, Some(announced("<AVAILBAL>")));
    assert_eq!(
        statement.ledger_balance, statement.available_balance,
        "les deux soldes de ce relevé sont égaux"
    );
    assert_eq!(
        statement.from,
        Some(radinus_core::domain::NaiveDate::from_ymd_opt(2026, 4, 27).unwrap())
    );
    assert_eq!(
        statement.to,
        Some(radinus_core::domain::NaiveDate::from_ymd_opt(2026, 7, 24).unwrap())
    );

    // **Le croisement du fichier avec lui-même** : la somme des 151 montants
    // lus par le module doit valoir celle des 151 montants comptés dans le
    // texte brut, sans passer par le module. Deux chemins indépendants vers le
    // même nombre — un montant mal lu, un signe perdu, une ligne oubliée se
    // verraient ici, et nulle part ailleurs.
    let read_total: i64 = statement.transactions.iter().map(|line| line.amount).sum();
    let raw_total: i64 = text
        .split("<TRNAMT>")
        .skip(1)
        .map(|piece| piece.split('<').next().unwrap_or_default())
        .map(|amount| {
            let (whole, cents) = amount.split_once('.').unwrap_or((amount, "0"));
            let negative = whole.starts_with('-');
            let units: i64 = whole.trim_start_matches(['-', '+']).parse().unwrap_or(0);
            let cents: i64 = format!("{cents:0<2}")[..2].parse().unwrap_or(0);
            let value = units * 1_000_000 + cents * 10_000;
            if negative {
                -value
            } else {
                value
            }
        })
        .sum();
    assert_eq!(
        read_total, raw_total,
        "la somme des montants lus ne vaut pas celle des montants du fichier"
    );

    // Aucune ligne perdue en route : chacune porte sa date, son FITID et son
    // rang. Un FITID vide rendrait l'anti-doublon aveugle sur cette ligne.
    for (index, line) in statement.transactions.iter().enumerate() {
        assert_eq!(line.rank, index + 1);
        assert!(line.date.is_some(), "ligne {} sans date", index + 1);
        assert!(!line.fitid.is_empty(), "ligne {} sans FITID", index + 1);
        assert!(!line.label.is_empty(), "ligne {} sans libellé", index + 1);
    }

    // Et les FITID sont bien distincts : c'est sur eux que reposera
    // l'anti-doublon, et deux lignes qui partageraient le même en feraient
    // disparaître une.
    let distinct: std::collections::BTreeSet<&str> = statement
        .transactions
        .iter()
        .map(|line| line.fitid.as_str())
        .collect();
    assert_eq!(
        distinct.len(),
        EXPECTED_TRANSACTIONS,
        "des FITID se répètent dans le relevé réel"
    );

    println!(
        "\n[real_ofx] {} opérations lues sur le compte {}, du {} au {}.\n",
        statement.transactions.len(),
        statement.account_number,
        statement.from.unwrap(),
        statement.to.unwrap()
    );
}
