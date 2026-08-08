//! Aperçu des messages de l'importation, et vérification qu'aucun n'est vide
//! dans l'une des deux langues.
//!
//! Ce sont **les phrases de l'original**, reprises mot pour mot sur consigne de
//! Fabrice (28/07/2026). Le dictionnaire des fenêtres ne peut pas les
//! contrôler : elles portent des valeurs, et ne sont résolues qu'au moment où
//! on les dit.
//!
//!     cargo test --test statement_messages -- --nocapture

use radinus_core::i18n::{message_of, text, Language};

#[test]
fn les_messages_de_l_importation_existent_dans_les_deux_langues() {
    for language in [Language::French, Language::English] {
        for key in [
            "statement-mass-question",
            "statement-already-reconciled",
            "statement-duplicate",
            "statement-no-fitid",
        ] {
            assert!(!text(language, key).is_empty(), "{key} est vide en {language:?}");
        }

        let asked = message_of(
            language,
            "statement-duplicate-question",
            &[
                ("date", "22/07/2026"),
                ("label", "ACHAT CB COMMERCE TROIS"),
                ("amount", "-120,00 €"),
            ],
            &[],
        );
        assert!(asked.contains("ACHAT CB COMMERCE TROIS"), "{asked}");

        for key in ["statement-integration-report", "statement-integration-abandoned"] {
            let said = message_of(language, key, &[], &[("added", 7), ("ignored", 2)]);
            assert!(said.contains('7') && said.contains('2'), "{key} : {said}");
        }
    }

    // L'aperçu, en français : ce que voit quelqu'un qui intègre un lot de
    // douze lignes dont deux font doublon.
    let fr = Language::French;
    println!("\n----- l'avertissement du lot -----\n{}\n", text(fr, "statement-mass-question"));
    println!(
        "----- devant un doublon -----\n{}\n",
        message_of(
            fr,
            "statement-duplicate-question",
            &[
                ("date", "22/07/2026"),
                ("label", "ACHAT CB COMMERCE TROIS"),
                ("amount", "-120,00 €")
            ],
            &[],
        )
    );
    println!(
        "----- à la fin -----\n{}\n",
        message_of(fr, "statement-integration-report", &[], &[("added", 10), ("ignored", 2)])
    );
}
