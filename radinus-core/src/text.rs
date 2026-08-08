//! Text helpers shared by the modules that have to order French labels the
//! way Radinus 1.9.3 does.
//!
//! There is only one rule here, and it was **measured** on the author's real
//! archive rather than assumed: labels are compared with accents removed,
//! case ignored, and punctuation and spaces ignored. That is what puts `Ebay`
//! before `E. Leclerc`, `Dépenses personnelles` between `Cotisations
//! syndicale` and `Divers`, and `La Redoute` before `LDLC`. Sorting the three
//! label-ordered tables of the archive under this rule reproduces their row
//! order exactly (see `backup::writer`), which is the evidence that it is the
//! right rule — and the same rule is what the nomenclature lists and combos
//! must use on screen (02_BASE_DE_DONNEES.md §7 rule 6).

/// Accents removed and case ignored, everything else kept as it is. The one
/// building block the two rules below share.
fn fold(label: &str) -> impl Iterator<Item = char> + '_ {
    label.chars().map(|c| match c {
                'à' | 'â' | 'ä' | 'á' | 'ã' | 'å' => 'a',
                'ç' => 'c',
                'è' | 'é' | 'ê' | 'ë' => 'e',
                'ì' | 'í' | 'î' | 'ï' => 'i',
                'ñ' => 'n',
                'ò' | 'ó' | 'ô' | 'ö' | 'õ' => 'o',
                'ù' | 'ú' | 'û' | 'ü' => 'u',
                'ý' | 'ÿ' => 'y',
                'À' | 'Â' | 'Ä' | 'Á' | 'Ã' | 'Å' => 'a',
                'Ç' => 'c',
                'È' | 'É' | 'Ê' | 'Ë' => 'e',
                'Ì' | 'Í' | 'Î' | 'Ï' => 'i',
                'Ñ' => 'n',
                'Ò' | 'Ó' | 'Ô' | 'Ö' | 'Õ' => 'o',
                'Ù' | 'Ú' | 'Û' | 'Ü' => 'u',
                'Ý' => 'y',
        other => other.to_lowercase().next().unwrap_or(other),
    })
}

/// The sort key of a label under the collation described in the module doc
/// comment. Compare two keys with the ordinary string comparison.
pub fn french_sort_key(label: &str) -> String {
    fold(label)
        .filter(char::is_ascii_alphanumeric)
        .collect()
}

/// The key that decides whether two labels are **the same name**.
///
/// A different rule from the collation above, and deliberately so (author's
/// ruling, 25/07/2026): surrounding spaces are dropped, case and accents do
/// not count, and **punctuation does** — « alimentation », « Alimentation »
/// and « ALIMENTATION » are one and the same, « Marché » and « Marche » too,
/// but « E. Leclerc » and « ELeclerc » stay two different names. The
/// collation ignores punctuation, which is right for putting labels in order
/// and much too strict for refusing one.
pub fn same_name_key(label: &str) -> String {
    fold(label.trim()).collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Every one of these pairs comes from the author's real archive, in the
    /// order 1.9.3 itself wrote them.
    #[test]
    fn the_collation_matches_the_measured_order() {
        for (first, second) in [
            ("Ebay", "E. Leclerc"),
            ("Cotisations syndicale", "Dépenses personnelles"),
            ("Dépenses personnelles", "Divers"),
            ("Brico Depot", "BricoMarché"),
            ("La Redoute", "LDLC"),
            ("LDLC", "LeBonCoin"),
            ("A fronda", "Aldi"),
            ("Cdiscount", "Décathlon"),
        ] {
            assert!(
                french_sort_key(first) < french_sort_key(second),
                "{first} devrait précéder {second}"
            );
        }
    }

    #[test]
    fn accents_case_and_punctuation_all_fold_away() {
        assert_eq!(french_sort_key("Épargne"), "epargne");
        assert_eq!(french_sort_key("E. Leclerc"), "eleclerc");
        assert_eq!(french_sort_key("Système U"), "systemeu");
        assert_eq!(french_sort_key("H&M"), "hm");
    }

    /// The rule that refuses a duplicate is not the rule that sorts. Case and
    /// accents fold away in both; punctuation only folds away in the sort.
    #[test]
    fn the_same_name_rule_keeps_the_punctuation_the_collation_throws_away() {
        for (one, other) in [
            ("Alimentation", "alimentation"),
            ("Alimentation", "ALIMENTATION"),
            ("  Alimentation  ", "Alimentation"),
            ("Marché", "Marche"),
            ("Épargne", "epargne"),
        ] {
            assert_eq!(
                same_name_key(one),
                same_name_key(other),
                "« {one} » et « {other} » sont le même nom"
            );
        }

        for (one, other) in [
            ("E. Leclerc", "ELeclerc"),
            ("EDF", "E.D.F."),
            ("H&M", "HM"),
            ("Alimentation", "Alimentaton"),
        ] {
            assert_ne!(
                same_name_key(one),
                same_name_key(other),
                "« {one} » et « {other} » sont deux noms différents"
            );
        }
    }

    #[test]
    fn a_full_list_sorts_the_way_the_archive_did() {
        let mut labels = vec![
            "Divers",
            "Dépenses personnelles",
            "Cotisations syndicale",
            "Alimentation",
            "Actions Bourse",
        ];
        labels.sort_by_key(|l| french_sort_key(l));
        assert_eq!(
            labels,
            vec![
                "Actions Bourse",
                "Alimentation",
                "Cotisations syndicale",
                "Dépenses personnelles",
                "Divers",
            ]
        );
    }
}
