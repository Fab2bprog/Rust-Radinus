//! Writing an amount for the user to read.
//!
//! Amounts are `i64` micro-units everywhere (value × 1 000 000, see
//! `domain`), which is exact and unreadable. This turns one into the string a
//! window shows, in the language the database runs in: « 1 549,81 € » in
//! French, "1,549.81 €" in English.
//!
//! It lives in the core rather than in the interface for the same reason
//! every sentence does: a window shows what it is given, and there is one
//! place to change when the format has to change.

use crate::i18n::Language;
use std::sync::RwLock;

/// One euro, in micro-units.
pub const UNIT: i64 = 1_000_000;

/// **Le signe de la devise, propriété unique du logiciel qui tourne.**
///
/// La vraie fonction de ce module est `format_with`, qui ne connaît que ses
/// arguments et que tous les tests emploient. `format` n'en est que le confort :
/// elle lit ce signe-ci. Il existe parce que `format` est appelée à
/// soixante-sept endroits, tous dans des fonctions qui tiennent déjà la langue
/// et pas la devise — la faire changer de signature reviendrait à toucher
/// soixante-sept appels pour transporter une valeur qui, elle, est unique dans
/// tout le logiciel, comme l'est la base ouverte.
///
/// **Deux écrivains, et deux seulement** : le contrôleur le pose à l'ouverture
/// d'une base, et à l'enregistrement des préférences. Nulle part ailleurs.
/// `None` tant que rien n'a été posé — ce qui vaut l'euro. `Some("")` est un
/// choix, et un choix différent : **l'utilisateur a demandé qu'aucune devise
/// ne s'affiche**. Les deux se distinguent, sans quoi « aucune » retomberait
/// sur l'euro à chaque démarrage.
static SIGN: RwLock<Option<String>> = RwLock::new(None);

/// Pose le signe employé par `format`. Appelé par le contrôleur, jamais par le
/// noyau lui-même.
pub fn set_sign(sign: &str) {
    if let Ok(mut held) = SIGN.write() {
        *held = Some(sign.to_string());
    }
}

/// Le signe en vigueur. L'euro tant que rien n'a été posé — une base fermée
/// n'affiche aucun montant, mais un montant sans signe ne dirait pas qu'on ne
/// sait pas, il dirait qu'il n'y a pas de devise.
pub fn sign() -> String {
    match SIGN.read() {
        Ok(held) => held.clone().unwrap_or_else(|| "€".to_string()),
        // Un verrou empoisonné n'empêche pas d'écrire un montant.
        Err(_) => "€".to_string(),
    }
}

/// The amount as it is shown, currency included.
pub fn format(amount: i64, language: Language) -> String {
    format_with(amount, language, &sign())
}

/// Le montant écrit, avec le signe qu'on lui donne.
///
/// **C'est la fonction, et `format` n'en est que le raccourci.** Elle ne lit
/// aucun état : deux appels avec les mêmes arguments rendent la même chaîne,
/// ce qui la rend vérifiable et ce qui évite que deux tests lancés en parallèle
/// se marchent dessus.
///
/// **La place du signe vient de la langue, jamais de la devise** (décision de
/// Fabrice, 03/08/2026) : le français et l'espagnol écrivent `1 549,81 €`,
/// l'anglais `€1,549.81`. Une devise ne dit pas dans quelle langue on la lit —
/// un anglophone peut être américain, britannique ou canadien —, et c'est
/// pourquoi aucun signe monétaire n'est écrit dans un fichier de langue.
pub fn format_with(amount: i64, language: Language, sign: &str) -> String {
    let (thousands, decimal) = separators(language);

    let negative = amount < 0;
    let absolute = amount.unsigned_abs();
    let units = absolute / UNIT as u64;
    // Rounded to the centime, not truncated: 0,999 999 € is 1,00 € on screen.
    let centimes = ((absolute % UNIT as u64) as f64 / 10_000.0).round() as u64;
    let (units, centimes) = if centimes == 100 {
        (units + 1, 0)
    } else {
        (units, centimes)
    };

    let mut whole = String::new();
    for (index, c) in units.to_string().chars().rev().enumerate() {
        if index > 0 && index % 3 == 0 {
            whole.push(thousands);
        }
        whole.push(c);
    }
    let whole: String = whole.chars().rev().collect();

    let minus = if negative { "-" } else { "" };
    // **Aucune devise demandée** : le nombre seul, et surtout pas l'espace qui
    // précédait le signe — une ligne qui finit par une espace invisible se
    // recopie mal et se compare mal.
    if sign.is_empty() {
        return format!("{minus}{whole}{decimal}{centimes:02}");
    }
    if sign_comes_first(language) {
        // Le moins reste **devant tout**, signe compris : « -$12,00 » et non
        // « $-12,00 ». C'est ce que fait tout logiciel de comptes anglophone,
        // et c'est ce qui se lit d'un coup d'œil dans une colonne.
        format!("{minus}{sign}{whole}{decimal}{centimes:02}")
    } else {
        // L'espace ordinaire, celui d'origine : passer à une espace insécable
        // changerait la chaîne de tous les montants déjà affichés, ce qui n'a
        // pas été demandé et se verrait dans chaque test qui les compare.
        format!("{minus}{whole}{decimal}{centimes:02} {sign}")
    }
}

/// Le signe se pose-t-il avant le nombre dans cette langue ?
///
/// La clef vaut `before` ou n'importe quoi d'autre, et n'importe quoi d'autre
/// veut dire « après » : une langue ajoutée demain sans cette clef écrira à la
/// française, ce qui est lisible, plutôt que de ne rien écrire du tout.
pub fn sign_comes_first(language: Language) -> bool {
    crate::i18n::text(language, "ui-money-sign-position").trim() == "before"
}

/// The same, without the currency and without any grouping — what goes into
/// an editable field, and what comes back out of one.
pub fn format_plain(amount: i64, language: Language) -> String {
    let (_, decimal) = separators(language);
    let negative = amount < 0;
    let absolute = amount.unsigned_abs();
    let units = absolute / UNIT as u64;
    let centimes = ((absolute % UNIT as u64) as f64 / 10_000.0).round() as u64;
    let (units, centimes) = if centimes == 100 {
        (units + 1, 0)
    } else {
        (units, centimes)
    };
    format!("{}{units}{decimal}{centimes:02}", if negative { "-" } else { "" })
}

/// Les deux séparateurs d'une langue : celui qui groupe les milliers, et
/// celui qui ouvre les décimales.
///
/// **Ils viennent du fichier de langue**, sous les clefs
/// `ui-thousands-separator` et `ui-decimal-separator` — pas du code. C'est ce
/// qui permet d'ajouter une langue sans venir ici : l'espagnol écrit
/// « 1.549,81 € » et le dit lui-même, dans son propre fichier. La fenêtre lit
/// d'ailleurs déjà ces deux clefs pour filtrer la frappe sans redemander à
/// Rust à chaque touche ; il n'y a donc plus qu'une seule vérité.
///
/// Une clef absente ou vide retombe sur l'écriture française : un montant
/// doit rester lisible même si son fichier de langue est incomplet.
pub fn separators(language: Language) -> (char, char) {
    let one = |key: &str, fallback: char| -> char {
        crate::i18n::text(language, key).chars().next().unwrap_or(fallback)
    };
    (
        // Une espace insécable étroite en français, celle de l'original.
        one("ui-thousands-separator", '\u{202f}'),
        one("ui-decimal-separator", ','),
    )
}

/// What a text is not, when it is not an amount.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum NotAnAmount {
    /// Nothing was typed at all.
    Empty,
    /// Something that cannot belong to an amount — a letter, a symbol, a
    /// second decimal separator, a minus sign in the middle.
    Malformed,
}

/// Reads an amount the user typed. Comma or full stop, spaces of any kind
/// between the thousands, a currency sign or not — all accepted, because all
/// of them are what people actually type.
///
/// **Everything else is refused, and refused out loud.** This function used
/// to keep the digits it recognized and throw the rest away: « 12a34 » came
/// back as 1 234,00 € and « abc » came back as nothing at all, which the
/// caller then stored as 0,00 €. In a program that handles money, an amount
/// that silently becomes zero falsifies every balance of the account's life,
/// and an amount nobody typed is worse (reported by Fabrice, 25/07/2026).
///
/// More than two decimals are rounded rather than refused: the database holds
/// micro-units, and a third decimal is a slip of the finger, not a lie.
pub fn parse(text: &str) -> Result<i64, NotAnAmount> {
    // The currency sign is noise **around** a number, never inside one:
    // « 12€34 » is not an amount, and stripping it anywhere would have made
    // it one. Spaces group the thousands and may sit anywhere.
    //
    // **Le signe en vigueur est ôté comme l'euro l'était** (phase 17 ter) :
    // quelqu'un qui affiche des dollars recopie « 1 234,56 $ » depuis sa
    // propre fenêtre, et sa saisie doit rentrer. Les autres signes courants
    // sont ôtés aussi, parce qu'un montant collé depuis ailleurs en porte un.
    // Rien de plus : ôter des lettres quelconques ferait de « 12a34 » un
    // montant, la faute même que Fabrice a relevée le 25/07/2026.
    let current = sign();
    let mut trimmed = text.trim();
    for _ in 0..2 {
        trimmed = trimmed.trim();
        if !current.is_empty() {
            if let Some(rest) = trimmed.strip_prefix(current.as_str()) {
                trimmed = rest;
            } else if let Some(rest) = trimmed.strip_suffix(current.as_str()) {
                trimmed = rest;
            }
        }
        trimmed = trimmed.trim_matches(|c| matches!(c, '€' | '$' | '£' | '¥'));
    }
    let trimmed = trimmed.trim();
    let cleaned: String = trimmed
        .chars()
        .filter(|c| !c.is_whitespace() && *c != '\u{202f}' && *c != '\u{00a0}')
        .map(|c| if c == ',' { '.' } else { c })
        .collect();

    if cleaned.is_empty() {
        return Err(NotAnAmount::Empty);
    }

    let (negative, digits) = match cleaned.strip_prefix('-') {
        Some(rest) => (true, rest),
        None => (false, cleaned.strip_prefix('+').unwrap_or(&cleaned)),
    };
    if digits.is_empty() {
        return Err(NotAnAmount::Malformed);
    }

    // From here on, only digits and at most one separator are allowed. No
    // letter is dropped, no second separator is forgiven.
    let mut parts = digits.split('.');
    let whole = parts.next().unwrap_or_default();
    let fraction = parts.next().unwrap_or_default();
    if parts.next().is_some() {
        return Err(NotAnAmount::Malformed);
    }
    if whole.is_empty() && fraction.is_empty() {
        return Err(NotAnAmount::Malformed);
    }
    if !whole.chars().all(|c| c.is_ascii_digit())
        || !fraction.chars().all(|c| c.is_ascii_digit())
    {
        return Err(NotAnAmount::Malformed);
    }

    let units: i64 = if whole.is_empty() {
        0
    } else {
        whole.parse().map_err(|_| NotAnAmount::Malformed)?
    };

    // The fraction is read digit by digit rather than through a float: six
    // digits is a whole micro-unit, and anything beyond is rounded.
    let mut micros: i64 = 0;
    let mut scale = UNIT / 10;
    let mut rest = fraction.chars();
    for c in rest.by_ref().take(6) {
        micros += (c as i64 - '0' as i64) * scale;
        scale /= 10;
    }
    if let Some(next) = rest.next() {
        if next >= '5' {
            micros += 1;
        }
    }

    let total = units
        .checked_mul(UNIT)
        .and_then(|value| value.checked_add(micros))
        .ok_or(NotAnAmount::Malformed)?;
    Ok(if negative { -total } else { total })
}

/// The same, for the places where an empty field means zero — a balance that
/// was never carried over is zero, not a refusal.
pub fn parse_or_zero(text: &str) -> Result<i64, NotAnAmount> {
    match parse(text) {
        Err(NotAnAmount::Empty) => Ok(0),
        other => other,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// **Le signe est ce qu'on lui donne, et sa place vient de la langue.**
    /// C'est tout le sujet de la phase 17 ter, en un test.
    #[test]
    fn the_sign_is_whatever_it_is_given_and_its_place_comes_from_the_language() {
        assert_eq!(format_with(1_549_810_000, Language::French, "$"), "1\u{202f}549,81 $");
        assert_eq!(format_with(1_549_810_000, Language::English, "$"), "$1,549.81");
        assert_eq!(format_with(1_549_810_000, Language::French, "FCFA"), "1\u{202f}549,81 FCFA");
        // Le moins reste devant tout, signe compris : « -$12,00 » se lit d'un
        // coup d'œil dans une colonne, « $-12,00 » non.
        assert_eq!(format_with(-12_000_000, Language::English, "$"), "-$12.00");
        assert_eq!(format_with(-12_000_000, Language::French, "$"), "-12,00 $");
    }

    /// **« Aucune devise » rend le nombre seul**, sans l'espace qui traînerait
    /// derrière lui.
    #[test]
    fn no_currency_at_all_leaves_the_number_alone() {
        assert_eq!(format_with(1_549_810_000, Language::French, ""), "1\u{202f}549,81");
        assert_eq!(format_with(-12_000_000, Language::French, ""), "-12,00");
        // Et la place n'a plus de sens : l'anglais rend la même chose.
        assert_eq!(format_with(1_549_810_000, Language::English, ""), "1,549.81");
    }

    /// Une langue dont le fichier ne dit rien de la place écrit à la
    /// française — lisible, plutôt que rien.
    #[test]
    fn a_language_that_says_nothing_writes_the_sign_after() {
        for language in Language::all() {
            let shown = format_with(1_000_000, language, "¤");
            assert!(
                shown.contains('¤'),
                "le signe a disparu en {} : {shown}",
                language.tag()
            );
        }
    }


    #[test]
    fn an_amount_is_written_the_way_the_original_writes_it() {
        assert_eq!(format_with(1_549_810_000, Language::French, "€"), "1\u{202f}549,81 €");
        assert_eq!(format_with(44_549_810_000, Language::French, "€"), "44\u{202f}549,81 €");
        assert_eq!(format_with(0, Language::French, "€"), "0,00 €");
        assert_eq!(format_with(-4_422_730_000, Language::French, "€"), "-4\u{202f}422,73 €");
        assert_eq!(
            format_with(1_549_810_000, Language::English, "€"),
            "€1,549.81",
            "l'anglais pose le signe devant le nombre (décision du 03/08/2026)"
        );
        // L'espagnol groupe au point et décime à la virgule — et il le dit
        // dans son propre fichier, pas ici.
        assert_eq!(format_with(1_549_810_000, Language::Spanish, "€"), "1.549,81 €");
    }

    #[test]
    fn the_last_centime_is_rounded_and_not_dropped() {
        assert_eq!(format(999_999, Language::French), "1,00 €");
        assert_eq!(format(1_005_000, Language::French), "1,01 €");
        assert_eq!(format(1_004_000, Language::French), "1,00 €");
    }

    #[test]
    fn what_the_user_types_is_read_whatever_the_shape() {
        for text in ["1549,81", "1549.81", "1 549,81 €", "1\u{202f}549,81", "+1549,81"] {
            assert_eq!(parse(text), Ok(1_549_810_000), "« {text} »");
        }
        assert_eq!(parse("-4422,73"), Ok(-4_422_730_000));
        assert_eq!(parse("0"), Ok(0));
        assert_eq!(parse(",5"), Ok(500_000));
        assert_eq!(parse("12,"), Ok(12_000_000));
    }

    /// The heart of it, and the reason this function was rewritten: what is
    /// not an amount is refused, never guessed at and never turned into zero
    /// behind the user's back (Fabrice, 25/07/2026).
    #[test]
    fn what_is_not_an_amount_is_refused_out_loud() {
        assert_eq!(parse(""), Err(NotAnAmount::Empty));
        assert_eq!(parse("   "), Err(NotAnAmount::Empty));
        assert_eq!(parse("€"), Err(NotAnAmount::Empty));

        for text in [
            "abc", "12a34", "1e9", "--5", "1,,2", "1,2,3", "5-2", "12€34", "1..2", "-", "+",
        ] {
            assert_eq!(
                parse(text),
                Err(NotAnAmount::Malformed),
                "« {text} » n'est pas un montant"
            );
        }
    }

    /// An empty field is zero where a zero makes sense, and nowhere else.
    #[test]
    fn an_empty_field_is_zero_only_when_the_caller_says_so() {
        assert_eq!(parse_or_zero(""), Ok(0));
        assert_eq!(parse_or_zero("abc"), Err(NotAnAmount::Malformed));
    }

    /// Beyond the sixth decimal there is nothing left to store, so it rounds.
    #[test]
    fn too_many_decimals_are_rounded_not_refused() {
        assert_eq!(parse("1,0000004"), Ok(1_000_000));
        assert_eq!(parse("1,0000006"), Ok(1_000_001));
        assert_eq!(parse("1,005"), Ok(1_005_000));
    }

    #[test]
    fn a_field_round_trips_through_what_it_shows() {
        for amount in [0, 1_549_810_000, -4_422_730_000, 44_549_810_000] {
            let shown = format_plain(amount, Language::French);
            assert_eq!(parse(&shown), Ok(amount), "« {shown} »");
        }
    }
}
