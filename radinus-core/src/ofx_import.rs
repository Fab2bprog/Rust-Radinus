//! La lecture d'un fichier OFX — le portage de la classe `Ofx_Import` de
//! Fabrice (`POINT 28 Ofx_Import est une Classe.txt`), et de son esprit.
//!
//! Référence : `06_FORMATS_SAUVEGARDE_IMPORT_EXPORT.md` §2.1, `PLAN_ACTION.md`
//! phase 8, et ce que Fabrice a dicté le 27/07/2026 avant tout code.
//!
//! # Ce module ne lit pas du XML
//!
//! L'en-tête d'un fichier OFX 1.x le dit lui-même : `DATA:OFXSGML`. C'est du
//! SGML, et **les balises terminales n'y sont pas fermées** : on lit
//! `<TRNAMT>-50.00<FITID>P_GDYTLL29`, où c'est la balise suivante qui termine
//! le montant. Aucun analyseur XML ne lit cela ; il s'arrête à la première
//! balise non refermée. La seule voie est donc de traiter le fichier comme un
//! texte jalonné de marqueurs, et c'est ce que fait l'original en quatre
//! temps, repris ici tels quels :
//!
//!   1. **isoler un conteneur** par son nom — les conteneurs, eux, sont
//!      fermés ;
//!   2. **nettoyer** retours chariot et tabulations, parce que le fichier peut
//!      arriver sur une ligne ou sur cinquante ;
//!   3. **découper sur `<`**, ce qui transforme chaque balise non fermée en un
//!      fragment `NOM>valeur` — l'absence de balise fermante devient une
//!      propriété au lieu d'un défaut ;
//!   4. **reconnaître par le préfixe**, et **ignorer tout le reste**.
//!
//! Le quatrième temps est celui qui a l'air le plus naïf et qui est le plus
//! solide : une banque qui ajoute `MEMO`, `CHECKNUM` ou `CURRENCY` ne casse
//! rien, l'ordre des balises ne compte pas, et une balise optionnelle absente
//! laisse simplement son champ vide.
//!
//! Et cette méthode lit **aussi bien l'OFX 2.x**, qui est du vrai XML avec
//! toutes ses balises fermées : `</TRNAMT>` produit un fragment `/TRNAMT>`,
//! qui ne commence par aucun préfixe connu et qu'on ignore. Le même code lit
//! les deux versions sans jamais demander laquelle il a sous les yeux — un
//! analyseur qui aurait choisi son camp aurait eu besoin d'un test pour les
//! départager, et ce test aurait été la prochaine chose à casser.
//!
//! # Le conteneur d'abord n'est pas une lourdeur
//!
//! `BALAMT` et `DTASOF` apparaissent **deux fois** dans un relevé : dans
//! `LEDGERBAL` et dans `AVAILBAL`. Chercher `BALAMT` dans tout le fichier
//! prendrait l'un pour l'autre — et l'on ne s'en apercevrait jamais, puisque
//! les deux soldes sont souvent égaux et que le jour où ils diffèrent est
//! précisément celui qui compte. Les cinq boucles qui se ressemblent dans
//! l'original ne sont pas cinq copies : ce sont cinq portées, et la portée
//! **est** l'argument de correction.
//!
//! # La méfiance
//!
//! « Il faut intégrer un fichier OFX avec une très grande méfiance » (Fabrice,
//! 27/07/2026). La norme existe, mais elle est appliquée par des gens, avec
//! des outils différents, et chacun se permet ce qu'il veut. Et l'on ne peut
//! **jamais** demander son fichier à un utilisateur — secret bancaire — donc
//! on ne saura jamais pourquoi ça a échoué. Un lecteur strict est un lecteur
//! qu'on ne pourra pas réparer.
//!
//! D'où la règle de conduite de tout ce module : **on déduit tout ce qui est
//! déductible**, on n'échoue pas, et ce qu'on n'a pas compris est ignoré
//! plutôt que fatal.
//!
//! # Un seul compte
//!
//! Radinus n'importe qu'un compte à la fois, celui que l'utilisateur désigne
//! ([`accounts_in`] puis [`read`]). Une fois le choix fait, **on isole le bloc
//! de ce compte et on ne lit plus rien en dehors** (règle de Fabrice) : sans
//! cela, un fichier à deux comptes verserait les opérations des deux dans le
//! même tableau et garderait le solde du dernier bloc rencontré.

use crate::domain::NaiveDate;

/// Une transaction telle que le fichier la porte — la structure `TransacOfx`.
///
/// Rien n'est encore rapproché ni intégré : c'est ce qui a été lu, et rien de
/// plus.
#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct Transaction {
    /// `NumTransac` : le rang dans le fichier, en partant de 1. C'est l'ordre
    /// de la banque, et il est conservé.
    pub rank: usize,
    /// `DTPOSTED`. Absente si le fichier n'en portait pas de lisible — une
    /// ligne sans date reste une ligne, et c'est l'écran qui la montrera.
    pub date: Option<NaiveDate>,
    /// `TRNAMT`, en micro-unités et **signé**, comme partout dans Radinus.
    pub amount: i64,
    /// `TRNTYPE` — `POS`, `ATM`, `PAYMENT`, `CHECK`…
    pub kind: String,
    /// `NAME` : le libellé, **avec ses espaces intérieurs**.
    pub label: String,
    /// `FITID`, opaque : on ne l'interprète jamais, on le compare.
    pub fitid: String,
    /// `MEMO` : le détail que certaines banques ajoutent au libellé — le
    /// créancier d'un prélèvement, le bénéficiaire et le motif d'un virement,
    /// le numéro d'un chèque (19/10/2026). Vide quand le fichier n'en porte
    /// pas, ou n'y met que des espaces : La Banque Postale n'en met jamais, la
    /// BNP en met partout. Ce qu'on en fait est décidé par [`compose`], selon
    /// les réglages de l'utilisateur.
    pub memo: String,
}

/// **Ce qui va dans le libellé** (Préférences › Relevés OFX, premier menu,
/// Fabrice, 20/10/2026).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum LabelSource {
    /// Le nom de l'opération (`NAME`) — le défaut, ce que la banque affiche.
    #[default]
    Name,
    /// Le mémo de la banque (`MEMO`).
    Memo,
    /// Le nom suivi du mémo.
    NameAndMemo,
}

/// **Ce qui va dans la référence paiement** (second menu, 20/10/2026).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum ReferenceSource {
    /// Le mémo de la banque — le défaut.
    #[default]
    Memo,
    /// Le nom de l'opération.
    Name,
    /// Le nom suivi du mémo.
    NameAndMemo,
    /// Rien : la référence reste vide.
    Empty,
}

impl LabelSource {
    /// Le mot qui le désigne dans le fichier de réglages et entre la fenêtre
    /// et le noyau — comme le choix du libellé QIF.
    pub fn key(self) -> &'static str {
        match self {
            LabelSource::Name => "name",
            LabelSource::Memo => "memo",
            LabelSource::NameAndMemo => "name-and-memo",
        }
    }

    pub fn from_key(key: &str) -> Option<LabelSource> {
        match key {
            "name" => Some(LabelSource::Name),
            "memo" => Some(LabelSource::Memo),
            "name-and-memo" => Some(LabelSource::NameAndMemo),
            _ => None,
        }
    }
}

impl ReferenceSource {
    pub fn key(self) -> &'static str {
        match self {
            ReferenceSource::Memo => "memo",
            ReferenceSource::Name => "name",
            ReferenceSource::NameAndMemo => "name-and-memo",
            ReferenceSource::Empty => "empty",
        }
    }

    pub fn from_key(key: &str) -> Option<ReferenceSource> {
        match key {
            "memo" => Some(ReferenceSource::Memo),
            "name" => Some(ReferenceSource::Name),
            "name-and-memo" => Some(ReferenceSource::NameAndMemo),
            "empty" => Some(ReferenceSource::Empty),
            _ => None,
        }
    }
}

/// **Ce que l'utilisateur veut faire du NAME et du MEMO** : deux menus
/// déroulants, l'un pour le libellé, l'autre pour la référence paiement
/// (Fabrice, 20/10/2026 : deux cases « ne laissent pas assez de liberté »).
/// Par défaut, le nom dans le libellé et le mémo dans la référence.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct MemoOptions {
    pub label: LabelSource,
    pub reference: ReferenceSource,
}

/// La référence paiement tient 255 caractères dans la fiche : « le nom suivi
/// du mémo » est coupé là, par sécurité (le plus long vu, sur un vrai relevé
/// BNP, en ferait environ 230).
pub const REFERENCE_MAX: usize = 255;

/// **Le nom suivi du mémo, sans rien écrire deux fois.** Certaines banques
/// font du NAME le MEMO coupé à 32 caractères, d'autres répètent l'un dans
/// l'autre : un MEMO qui commence par le NAME est pris seul, complet ; un NAME
/// qui se termine par le MEMO est pris seul. Quand l'un des deux manque,
/// l'autre suffit.
fn name_and_memo(name: &str, memo: &str) -> String {
    if memo.is_empty() || name.ends_with(memo) {
        name.to_string()
    } else if name.is_empty() || memo.starts_with(name) {
        memo.to_string()
    } else {
        format!("{name} {memo}")
    }
}

/// **Le libellé et la référence d'une opération**, à partir de son NAME et de
/// son MEMO, selon les deux menus.
///
/// On ne cherche jamais à savoir de quelle banque vient le fichier (Fabrice :
/// « tu ne sauras pas de qui vient l'OFX ») : la règle se décide **opération
/// par opération**, sur ce qu'elle porte.
///
/// - **Le libellé n'est jamais vide** quand l'opération a un nom ou un mémo :
///   « le mémo » sans mémo garde le nom (La Banque Postale, Fabrice), et « le
///   nom » sans nom prend le mémo.
/// - **La référence dit ce qu'on a choisi, et rien d'autre** : « le mémo »
///   sans mémo la laisse vide, comme avant ; « le nom suivi du mémo » sans
///   mémo n'a que le nom. Elle est coupée à [`REFERENCE_MAX`] caractères.
///
/// Avec les réglages par défaut, un relevé est lu exactement comme avant le
/// 20/10/2026.
pub fn compose(name: &str, memo: &str, options: MemoOptions) -> (String, String) {
    let name = name.trim();
    let memo = memo.trim();
    let label = match options.label {
        LabelSource::Name if name.is_empty() => memo.to_string(),
        LabelSource::Name => name.to_string(),
        LabelSource::Memo if memo.is_empty() => name.to_string(),
        LabelSource::Memo => memo.to_string(),
        LabelSource::NameAndMemo => name_and_memo(name, memo),
    };
    let reference = match options.reference {
        ReferenceSource::Memo => memo.to_string(),
        ReferenceSource::Name => name.to_string(),
        ReferenceSource::NameAndMemo => name_and_memo(name, memo),
        ReferenceSource::Empty => String::new(),
    };
    let reference = reference.chars().take(REFERENCE_MAX).collect::<String>().trim_end().to_string();
    (label, reference)
}

/// Le relevé d'**un** compte, tel que la classe le tient après lecture.
#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct Statement {
    /// `ACCTID` — `m_sNumeroCompte`.
    pub account_number: String,
    /// `LEDGERBAL` : le solde comptable et sa date.
    pub ledger_balance: Option<i64>,
    pub ledger_balance_date: Option<NaiveDate>,
    /// `AVAILBAL` : le solde disponible et sa date. Souvent égal au précédent,
    /// et le jour où il en diffère est celui qui compte.
    pub available_balance: Option<i64>,
    pub available_balance_date: Option<NaiveDate>,
    /// `DTSTART` / `DTEND` de `BANKTRANLIST` : la période que le relevé couvre.
    pub from: Option<NaiveDate>,
    pub to: Option<NaiveDate>,
    pub transactions: Vec<Transaction>,
}

// --- Le texte, avant toute lecture --------------------------------------

/// Le fichier, en texte, quel que soit son encodage.
///
/// **L'en-tête n'est pas cru.** Il annonce `CHARSET:1252` ou `ENCODING:UTF-8`,
/// et il ment aussi souvent qu'il dit vrai. Ce qui ne ment pas, ce sont les
/// octets : une suite d'octets valide en UTF-8 n'est pratiquement jamais du
/// CP1252 par accident. On déduit donc de ce qu'on a plutôt que de ce qu'on
/// nous dit.
///
/// Le repli est CP1252, la page des banques françaises. Les octets 0x00–0x7F y
/// valent l'ASCII, 0xA0–0xFF le Latin-1, et seule la plage 0x80–0x9F demande
/// une table — celle qui porte l'euro, les guillemets typographiques et l'œ.
pub fn decode(bytes: &[u8]) -> String {
    if let Ok(text) = std::str::from_utf8(bytes) {
        return text.to_string();
    }
    /// La plage 0x80–0x9F du CP1252, dans l'ordre. Le caractère de
    /// remplacement pour les cinq positions que la page laisse vides.
    const HIGH: [char; 32] = [
        '\u{20AC}', '\u{FFFD}', '\u{201A}', '\u{0192}', '\u{201E}', '\u{2026}', '\u{2020}',
        '\u{2021}', '\u{02C6}', '\u{2030}', '\u{0160}', '\u{2039}', '\u{0152}', '\u{FFFD}',
        '\u{017D}', '\u{FFFD}', '\u{FFFD}', '\u{2018}', '\u{2019}', '\u{201C}', '\u{201D}',
        '\u{2022}', '\u{2013}', '\u{2014}', '\u{02DC}', '\u{2122}', '\u{0161}', '\u{203A}',
        '\u{0153}', '\u{FFFD}', '\u{017E}', '\u{0178}',
    ];
    bytes
        .iter()
        .map(|byte| match byte {
            0x80..=0x9F => HIGH[(*byte - 0x80) as usize],
            other => char::from(*other),
        })
        .collect()
}

/// `Netoie_RC_TAB` : retours chariot et tabulations s'en vont **avant** qu'on
/// regarde quoi que ce soit.
///
/// La même banque peut envoyer le fichier sur une seule ligne ou joliment
/// indenté ; sans ce nettoyage, ces caractères se retrouveraient collés dans
/// les valeurs et dans les noms de balises.
fn cleaned(source: &str) -> String {
    source
        .chars()
        .filter(|c| !matches!(c, '\r' | '\n' | '\t'))
        .collect()
}

// --- Les conteneurs ------------------------------------------------------

/// Le contenu du conteneur `<TAG>…</TAG>` à partir de `from`, et la position
/// où il se termine. L'équivalent de `XMLExtraitChaîne`.
///
/// **Un conteneur non fermé ne fait pas échouer** : si `</TAG>` manque, on
/// prend jusqu'à la fin du texte. Un fichier tronqué donne alors ce qu'il a,
/// au lieu de ne rien donner du tout.
fn container<'a>(source: &'a str, tag: &str, from: usize) -> Option<(&'a str, usize)> {
    let open = format!("<{tag}>");
    let close = format!("</{tag}>");
    let start = source[from..].find(&open)? + from + open.len();
    let end = source[start..]
        .find(&close)
        .map_or(source.len(), |at| start + at);
    Some((&source[start..end], end))
}

/// Chaque conteneur `<TAG>…</TAG>` du texte, dans l'ordre.
fn containers<'a>(source: &'a str, tag: &str) -> Vec<&'a str> {
    let mut found = Vec::new();
    let mut from = 0;
    while let Some((inside, end)) = container(source, tag, from) {
        found.push(inside);
        from = end.max(from + 1);
    }
    found
}

/// La valeur d'une balise terminale dans un bloc — `<NOM>valeur`.
///
/// Le découpage sur `<` fait de chaque balise non fermée un fragment
/// `NOM>valeur` : reconnaître revient à comparer un préfixe. Ce qui ne
/// correspond à rien est ignoré, y compris les `/NOM>` de l'OFX 2.x.
fn field<'a>(block: &'a str, name: &str) -> Option<&'a str> {
    let needle = format!("{name}>");
    block
        .split('<')
        .map(str::trim_start)
        .find(|piece| piece.starts_with(&needle))
        .map(|piece| &piece[needle.len()..])
}

// --- Les déductions ------------------------------------------------------

/// Un montant, en micro-unités, **quelle que soit la façon dont il est écrit**.
///
/// La règle est de Fabrice, donnée le 27/07/2026 : « 1.234,56 EUR je le lis :
/// je déduis que les deux derniers sont des centimes, forcément ils sont à
/// droite ». On lit donc **par la droite**, et l'on n'a jamais besoin de savoir
/// si la banque écrit à l'américaine ou à la française — la question ne se pose
/// plus.
///
/// Dans l'ordre : on écarte tout ce qui n'est ni chiffre, ni séparateur, ni
/// signe — les lettres d'une devise, les espaces, un symbole ; on relève le
/// signe, qu'il soit devant, derrière, ou marqué par des parenthèses ; puis
/// **le dernier séparateur décide**. Il est décimal, sauf s'il est suivi
/// d'exactement trois chiffres, auquel cas c'est un séparateur de milliers.
/// Tout ce qui reste à gauche est du millier, et s'efface.
///
/// `1.234,56` et `1,234.56` font le même montant. `1.234` fait mille deux cent
/// trente-quatre, et non un euro vingt-trois, parce que trois chiffres suivent.
///
/// **Une extension à la règle**, signalée pour que Fabrice la tranche : un
/// séparateur suivi d'**un** seul chiffre est traité comme décimal, si bien que
/// `50.5` vaut cinquante euros cinquante. Sa règle telle qu'il l'a dite ne
/// regarde que deux décimales ; personne n'écrit un millier sur un chiffre,
/// donc l'extension ne peut pas se retourner contre nous.
pub fn parse_amount(text: &str) -> Option<i64> {
    let negative = text.contains('-') || (text.contains('(') && text.contains(')'));
    let kept: String = text
        .chars()
        .filter(|c| c.is_ascii_digit() || *c == '.' || *c == ',')
        .collect();
    if !kept.chars().any(|c| c.is_ascii_digit()) {
        return None;
    }

    let (whole, decimals) = match kept.rfind(['.', ',']) {
        None => (kept.as_str(), ""),
        Some(at) => {
            let after = &kept[at + 1..];
            // Trois chiffres derrière : c'est un millier, pas une décimale.
            // Rien derrière non plus : un séparateur qui traîne ne dit rien.
            if after.len() == 3 || after.is_empty() {
                (kept.as_str(), "")
            } else {
                (&kept[..at], after)
            }
        }
    };

    let digits: String = whole.chars().filter(char::is_ascii_digit).collect();
    let units: i64 = digits.parse().ok()?;
    // Les décimales sont ramenées à six chiffres — l'unité de Radinus — en
    // complétant ou en tronquant : deux, une ou quatre décimales entrent
    // toutes de la même façon.
    let mut fraction = String::new();
    for index in 0..6 {
        fraction.push(decimals.chars().nth(index).unwrap_or('0'));
    }
    let fraction: i64 = fraction.parse().ok()?;

    let amount = units.checked_mul(crate::money::UNIT)?.checked_add(fraction)?;
    Some(if negative { -amount } else { amount })
}

/// Une date, quelle que soit la façon dont elle est écrite.
///
/// La norme dit `AAAAMMJJ`, éventuellement suivi de l'heure et d'un fuseau
/// entre crochets : `20260723120000[+1:CET]`. On coupe au crochet, on ne garde
/// que les chiffres, et les huit premiers suffisent — l'heure ne veut rien dire
/// pour une opération bancaire.
///
/// **Les formes à séparateurs sont acceptées quand même**, parce qu'un émetteur
/// peut tout se permettre. `2026-04-03` est sans ambiguïté : quatre chiffres à
/// gauche, c'est l'année. `03/04/2026` ne l'est pas — le jour et le mois sont
/// tous deux courts et tous deux inférieurs à treize, et rien dans le nombre ne
/// dit lequel est lequel. Quand l'un des deux dépasse douze, on tranche ; sinon
/// on lit **à la française**, jour puis mois, parce que c'est le logiciel de
/// Fabrice. *Ce dernier choix attend son arbitrage ; il ne peut pas se produire
/// sur un fichier conforme à la norme.*
pub fn parse_date(text: &str) -> Option<NaiveDate> {
    let text = text.split('[').next().unwrap_or(text).trim();
    let day = |year: i32, month: u32, day: u32| NaiveDate::from_ymd_opt(year, month, day);

    // La forme de la norme : une suite de chiffres, dont les huit premiers.
    let digits: String = text.chars().filter(char::is_ascii_digit).collect();
    if !text.contains(['-', '/', '.']) && digits.len() >= 8 {
        return day(
            digits[0..4].parse().ok()?,
            digits[4..6].parse().ok()?,
            digits[6..8].parse().ok()?,
        );
    }

    // Les formes à séparateurs.
    let parts: Vec<&str> = text
        .split(['-', '/', '.', ' '])
        .filter(|piece| !piece.is_empty())
        .collect();
    if parts.len() < 3 {
        return None;
    }
    let number = |piece: &str| -> Option<u32> {
        piece
            .chars()
            .filter(char::is_ascii_digit)
            .collect::<String>()
            .parse()
            .ok()
    };
    let (first, second, third) = (number(parts[0])?, number(parts[1])?, number(parts[2])?);

    // Quatre chiffres à gauche : l'année ouvre, et l'ordre est fixé.
    if parts[0].len() == 4 {
        return day(first as i32, second, third);
    }
    // Sinon l'année ferme. Deux chiffres valent le XXIᵉ siècle : un relevé
    // bancaire de 1926 n'existe pas.
    let year = if third < 100 { 2000 + third } else { third } as i32;
    // Ce qui dépasse douze ne peut être qu'un jour.
    if first > 12 {
        return day(year, second, first);
    }
    if second > 12 {
        return day(year, first, second);
    }
    day(year, second, first)
}

/// Le texte d'une balise, débarrassé des entités que le SGML y met.
///
/// `&amp;` est courant dans les libellés — « CARREFOUR &amp; CIE » — et le
/// laisser tel quel mettrait à l'écran un libellé que l'utilisateur ne
/// reconnaîtrait pas. Une entité inconnue est laissée telle quelle : on ne perd
/// rien, et c'est encore la même règle.
fn unescaped(text: &str) -> String {
    if !text.contains('&') {
        return text.to_string();
    }
    let mut out = String::with_capacity(text.len());
    let mut rest = text;
    while let Some(at) = rest.find('&') {
        out.push_str(&rest[..at]);
        rest = &rest[at..];
        let end = match rest.find(';') {
            Some(end) if end <= 10 => end,
            _ => {
                out.push('&');
                rest = &rest[1..];
                continue;
            }
        };
        let entity = &rest[1..end];
        let replacement = match entity {
            "amp" => Some('&'),
            "lt" => Some('<'),
            "gt" => Some('>'),
            "quot" => Some('"'),
            "apos" => Some('\''),
            "nbsp" => Some('\u{a0}'),
            other => other
                .strip_prefix('#')
                .and_then(|number| match number.strip_prefix(['x', 'X']) {
                    Some(hex) => u32::from_str_radix(hex, 16).ok(),
                    None => number.parse().ok(),
                })
                .and_then(char::from_u32),
        };
        match replacement {
            Some(c) => {
                out.push(c);
                rest = &rest[end + 1..];
            }
            None => {
                out.push('&');
                rest = &rest[1..];
            }
        }
    }
    out.push_str(rest);
    out
}

// --- Les deux passages ---------------------------------------------------

/// Où le relevé de chaque compte commence, dans le texte nettoyé.
///
/// On coupe sur les conteneurs de relevé — `STMTRS` pour un compte bancaire,
/// `CCSTMTRS` pour une carte. Quand le fichier n'en porte pas — un émetteur
/// peut tout se permettre — on se rabat sur les blocs d'identification du
/// compte, qui précèdent toujours les opérations et les soldes du même relevé.
/// Et s'il n'y a rien de tout cela, le fichier entier est un seul relevé, ce
/// qui est le cas ordinaire.
fn statements(source: &str) -> Vec<&str> {
    for markers in [
        ["<STMTRS>", "<CCSTMTRS>"],
        ["<BANKACCTFROM>", "<CCACCTFROM>"],
    ] {
        let mut cuts: Vec<usize> = Vec::new();
        for marker in markers {
            let mut from = 0;
            while let Some(at) = source[from..].find(marker) {
                cuts.push(from + at);
                from += at + marker.len();
            }
        }
        if cuts.is_empty() {
            continue;
        }
        cuts.sort_unstable();
        let mut blocks = Vec::with_capacity(cuts.len());
        for (index, start) in cuts.iter().enumerate() {
            let end = cuts.get(index + 1).copied().unwrap_or(source.len());
            blocks.push(&source[*start..end]);
        }
        return blocks;
    }
    vec![source]
}

/// Le numéro de compte d'un relevé — `ACCTID`.
fn account_of(block: &str) -> Option<String> {
    let number = field(block, "ACCTID")?.trim().to_string();
    (!number.is_empty()).then_some(number)
}

/// **Premier passage** : les numéros de compte que le fichier contient, dans
/// l'ordre où ils s'y trouvent, sans doublon.
///
/// C'est la liste que l'utilisateur voit, et dans laquelle il choisit. Rien
/// d'autre n'est lu à ce stade : on ne sait pas encore de quel compte on
/// parlera.
pub fn accounts_in(source: &str) -> Vec<String> {
    let source = cleaned(source);
    let mut found: Vec<String> = Vec::new();
    for block in statements(&source) {
        if let Some(number) = account_of(block) {
            if !found.contains(&number) {
                found.push(number);
            }
        }
    }
    found
}

/// **Second passage** : le relevé du compte choisi, et rien d'autre.
///
/// Le bloc de ce compte est isolé, et **on ne lit plus rien en dehors** (règle
/// de Fabrice, 27/07/2026) : sans cela, un fichier à deux comptes verserait les
/// opérations des deux dans le même tableau et garderait le solde du dernier
/// bloc rencontré.
///
/// Rend `None` quand le fichier ne porte pas ce compte. C'est le seul refus de
/// ce module, et il ne porte pas sur la forme du fichier : il porte sur une
/// question à laquelle il n'y a pas de réponse.
pub fn read(source: &str, account_number: &str) -> Option<Statement> {
    let source = cleaned(source);
    let block = statements(&source)
        .into_iter()
        .find(|block| account_of(block).as_deref() == Some(account_number))?;

    let mut statement = Statement {
        account_number: account_number.to_string(),
        ..Statement::default()
    };

    // Les bornes de la période, qui n'ont de sens que dans BANKTRANLIST.
    if let Some(list) = containers(block, "BANKTRANLIST").first() {
        statement.from = field(list, "DTSTART").and_then(parse_date);
        statement.to = field(list, "DTEND").and_then(parse_date);
    }

    // Les deux soldes. **Chacun dans son conteneur** : `BALAMT` et `DTASOF`
    // s'appellent pareil des deux côtés, et c'est la portée qui les distingue.
    if let Some(ledger) = containers(block, "LEDGERBAL").first() {
        statement.ledger_balance = field(ledger, "BALAMT").and_then(parse_amount);
        statement.ledger_balance_date = field(ledger, "DTASOF").and_then(parse_date);
    }
    if let Some(available) = containers(block, "AVAILBAL").first() {
        statement.available_balance = field(available, "BALAMT").and_then(parse_amount);
        statement.available_balance_date = field(available, "DTASOF").and_then(parse_date);
    }

    // Les opérations, dans l'ordre du fichier — celui de la banque.
    for (index, transaction) in containers(block, "STMTTRN").into_iter().enumerate() {
        statement.transactions.push(Transaction {
            rank: index + 1,
            date: field(transaction, "DTPOSTED").and_then(parse_date),
            amount: field(transaction, "TRNAMT")
                .and_then(parse_amount)
                .unwrap_or(0),
            kind: field(transaction, "TRNTYPE")
                .unwrap_or_default()
                .trim()
                .to_string(),
            // **Le libellé garde ses espaces intérieurs** : « CARTE X0000
            // 22/07/26 A 19H23 » tient son alignement d'eux, et les manger
            // changerait le libellé que Fabrice relit depuis des années. Seul
            // l'extérieur est rogné.
            label: unescaped(field(transaction, "NAME").unwrap_or_default().trim()),
            fitid: field(transaction, "FITID")
                .unwrap_or_default()
                .trim()
                .to_string(),
            // Le MEMO, à côté du libellé : le libellé lui-même ne change pas.
            memo: unescaped(field(transaction, "MEMO").unwrap_or_default().trim()),
        });
    }

    Some(statement)
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Le fichier de la banque de Fabrice, réduit à deux opérations : OFX 1.02
    /// SGML, tout sur une ligne, balises terminales non fermées.
    const SAMPLE: &str = "OFXHEADER:100\r\nDATA:OFXSGML\r\nVERSION:102\r\n\r\n\
<OFX><SIGNONMSGSRSV1><SONRS><STATUS><CODE>0<SEVERITY>INFO</STATUS>\
<DTSERVER>20260724181323<LANGUAGE>FRE</SONRS></SIGNONMSGSRSV1><BANKMSGSRSV1>\
<STMTTRNRS><TRNUID>1784909603038<STMTRS><CURDEF>EUR<BANKACCTFROM><BANKID>12345\
<BRANCHID>00001<ACCTID>123456A789<ACCTTYPE>CHECKING<ACCTKEY>12</BANKACCTFROM>\
<BANKTRANLIST><DTSTART>20260427<DTEND>20260724\
<STMTTRN><TRNTYPE>ATM<DTPOSTED>20260723<TRNAMT>-50.00<FITID>P_GDYTLL29\
<NAME>CARTE X0000    22/07/26 A 19H23</STMTTRN>\
<STMTTRN><TRNTYPE>POS<DTPOSTED>20260722<TRNAMT>-120.00<FITID>P_GDNTLLC@\
<NAME>ACHAT CB COMMERCE TROIS       21.07.26</STMTTRN>\
</BANKTRANLIST><LEDGERBAL><BALAMT>1549.81<DTASOF>20260724</LEDGERBAL>\
<AVAILBAL><BALAMT>1249.81<DTASOF>20260724</AVAILBAL></STMTRS></STMTTRNRS>\
</BANKMSGSRSV1></OFX>";

    fn day(text: &str) -> NaiveDate {
        NaiveDate::parse_from_str(text, "%Y-%m-%d").unwrap()
    }

    #[test]
    fn le_fichier_de_la_banque_se_lit_entierement() {
        assert_eq!(accounts_in(SAMPLE), vec!["123456A789".to_string()]);
        let statement = read(SAMPLE, "123456A789").unwrap();

        assert_eq!(statement.from, Some(day("2026-04-27")));
        assert_eq!(statement.to, Some(day("2026-07-24")));
        assert_eq!(statement.ledger_balance, Some(1_549_810_000));
        assert_eq!(statement.available_balance, Some(1_249_810_000));
        assert_eq!(statement.ledger_balance_date, Some(day("2026-07-24")));

        assert_eq!(statement.transactions.len(), 2);
        let first = &statement.transactions[0];
        assert_eq!(first.rank, 1);
        assert_eq!(first.date, Some(day("2026-07-23")));
        assert_eq!(first.amount, -50_000_000);
        assert_eq!(first.kind, "ATM");
        assert_eq!(first.fitid, "P_GDYTLL29");
        // Les espaces intérieurs du libellé sont intacts.
        assert_eq!(first.label, "CARTE X0000    22/07/26 A 19H23");
    }

    /// **Les deux soldes ne se confondent pas.** `BALAMT` et `DTASOF`
    /// s'appellent pareil dans `LEDGERBAL` et dans `AVAILBAL` : c'est la portée
    /// qui les distingue, et c'est le premier piège que l'original évite.
    ///
    /// Ils sont volontairement différents dans l'échantillon — égaux, ce test
    /// aurait passé même en lisant deux fois le même.
    #[test]
    fn le_solde_comptable_n_est_pas_le_solde_disponible() {
        let statement = read(SAMPLE, "123456A789").unwrap();
        assert_ne!(statement.ledger_balance, statement.available_balance);
        assert_eq!(statement.ledger_balance, Some(1_549_810_000));
    }

    /// **Même fichier, trois mises en forme, un seul résultat.**
    ///
    /// « Le fichier OFX peut être sur une ligne ou plusieurs, chaque
    /// développeur fait ce qu'il veut » (Fabrice). Voici donc le même relevé
    /// écrit de trois façons : sur une ligne, indenté avec des tabulations et
    /// des retours à la ligne, et en OFX 2.x avec **toutes** les balises
    /// fermées. Les trois doivent rendre exactement la même chose — c'est le
    /// croisement qui tient toute la philosophie du module.
    #[test]
    fn la_mise_en_forme_du_fichier_ne_change_rien_a_ce_qu_on_y_lit() {
        let reference = read(SAMPLE, "123456A789").unwrap();

        // Indenté : un retour et deux tabulations avant chaque balise.
        let indented = SAMPLE.replace('<', "\n\t\t<");
        assert_eq!(read(&indented, "123456A789").unwrap(), reference);

        // OFX 2.x : chaque balise terminale est refermée.
        let mut closed = SAMPLE.to_string();
        for tag in [
            "TRNTYPE", "DTPOSTED", "TRNAMT", "FITID", "NAME", "ACCTID", "BALAMT", "DTASOF",
            "DTSTART", "DTEND",
        ] {
            let opening = format!("<{tag}>");
            let mut rebuilt = String::new();
            let mut rest = closed.as_str();
            while let Some(at) = rest.find(&opening) {
                let after = &rest[at + opening.len()..];
                let end = after.find('<').unwrap_or(after.len());
                rebuilt.push_str(&rest[..at + opening.len()]);
                rebuilt.push_str(&after[..end]);
                rebuilt.push_str(&format!("</{tag}>"));
                rest = &after[end..];
            }
            rebuilt.push_str(rest);
            closed = rebuilt;
        }
        assert!(closed.contains("</TRNAMT>"), "l'échantillon 2.x est mal bâti");
        assert_eq!(read(&closed, "123456A789").unwrap(), reference);
    }

    /// **Ce qu'on ne connaît pas ne fait pas échouer.** Une banque qui ajoute
    /// des balises — et elles en ajoutent — ne doit rien changer. Le `MEMO`,
    /// lu depuis le 19/10/2026, arrive dans son propre champ et ne touche à
    /// rien d'autre.
    #[test]
    fn les_balises_inconnues_sont_ignorees_et_non_fatales() {
        let reference = read(SAMPLE, "123456A789").unwrap();
        let noisy = SAMPLE
            .replace(
                "<FITID>",
                "<MEMO>Un commentaire de la banque<CHECKNUM>1234<CURRENCY>EUR<FITID>",
            )
            .replace("<CURDEF>EUR", "<CURDEF>EUR<INTRATE>0.5<MKTGINFO>Publicite");
        let mut read_back = read(&noisy, "123456A789").unwrap();
        for transaction in &mut read_back.transactions {
            assert_eq!(transaction.memo, "Un commentaire de la banque");
            transaction.memo.clear();
        }
        assert_eq!(read_back, reference);
    }

    /// **Un fichier à deux comptes ne mélange rien.**
    ///
    /// C'est la raison d'être de l'isolement : lire pour le compte A doit
    /// donner exactement ce que donnerait un fichier ne portant que A. Le
    /// croisement tient les deux bouts — le même compte, dans deux fichiers
    /// différents.
    #[test]
    fn deux_comptes_dans_un_fichier_ne_se_melangent_pas() {
        let second = "<STMTRS><CURDEF>EUR<BANKACCTFROM><ACCTID>999999Z111</BANKACCTFROM>\
<BANKTRANLIST><DTSTART>20260101<DTEND>20260131\
<STMTTRN><TRNTYPE>CREDIT<DTPOSTED>20260115<TRNAMT>2000.00<FITID>AUTRE1\
<NAME>VIREMENT SALAIRE</STMTTRN></BANKTRANLIST>\
<LEDGERBAL><BALAMT>9999.99<DTASOF>20260131</LEDGERBAL></STMTRS>";
        let both = SAMPLE.replace("</BANKMSGSRSV1>", &format!("{second}</BANKMSGSRSV1>"));

        assert_eq!(
            accounts_in(&both),
            vec!["123456A789".to_string(), "999999Z111".to_string()]
        );

        // Le compte de l'échantillon, lu dans le fichier à deux comptes, est
        // identique à ce qu'il est dans le fichier à un compte.
        assert_eq!(
            read(&both, "123456A789").unwrap(),
            read(SAMPLE, "123456A789").unwrap()
        );

        // Et l'autre ne porte que ce qui est à lui.
        let other = read(&both, "999999Z111").unwrap();
        assert_eq!(other.transactions.len(), 1);
        assert_eq!(other.ledger_balance, Some(9_999_990_000));
        assert_eq!(other.from, Some(day("2026-01-01")));

        // Un compte que le fichier ne porte pas n'a pas de relevé.
        assert!(read(&both, "000000A000").is_none());
    }

    /// **À l'américaine ou à la française, c'est le même montant.**
    ///
    /// La règle de Fabrice : on lit par la droite, et l'on n'a jamais besoin de
    /// savoir dans quel pays le fichier a été écrit.
    #[test]
    fn un_montant_se_lit_par_la_droite_quelle_que_soit_son_ecriture() {
        for text in [
            "1234.56",
            "1234,56",
            "1.234,56",
            "1,234.56",
            "1 234,56",
            "1234.56 EUR",
        ] {
            assert_eq!(parse_amount(text), Some(1_234_560_000), "« {text} »");
        }
        // Trois chiffres derrière le dernier séparateur : ce sont des milliers.
        assert_eq!(parse_amount("1.234"), Some(1_234_000_000));
        assert_eq!(parse_amount("1,234"), Some(1_234_000_000));
        assert_eq!(parse_amount("1.234.567"), Some(1_234_567_000_000));
        // Sans séparateur du tout.
        assert_eq!(parse_amount("50"), Some(50_000_000));
        // Le signe, où qu'il soit.
        assert_eq!(parse_amount("-50.00"), Some(-50_000_000));
        assert_eq!(parse_amount("50.00-"), Some(-50_000_000));
        assert_eq!(parse_amount("(50.00)"), Some(-50_000_000));
        assert_eq!(parse_amount("+50.00"), Some(50_000_000));
        // Une décimale, deux, quatre : toutes entrent.
        assert_eq!(parse_amount("50.5"), Some(50_500_000));
        assert_eq!(parse_amount("50.1234"), Some(50_123_400));
        // Et ce qui n'est pas un nombre n'en est pas un.
        assert_eq!(parse_amount("EUR"), None);
        assert_eq!(parse_amount(""), None);
    }

    /// **Une date se déduit de sa forme.** Celle de la norme, celle de la norme
    /// avec l'heure et le fuseau, et les formes à séparateurs qu'un émetteur
    /// peut tout de même envoyer.
    #[test]
    fn une_date_se_lit_dans_toutes_ses_ecritures() {
        assert_eq!(parse_date("20260723"), Some(day("2026-07-23")));
        assert_eq!(parse_date("20260723120000"), Some(day("2026-07-23")));
        assert_eq!(parse_date("20260723120000[+1:CET]"), Some(day("2026-07-23")));
        assert_eq!(parse_date("20260723[-5:EST]"), Some(day("2026-07-23")));
        // Quatre chiffres à gauche : l'année ouvre, rien à trancher.
        assert_eq!(parse_date("2026-07-23"), Some(day("2026-07-23")));
        // Ce qui dépasse douze ne peut être qu'un jour.
        assert_eq!(parse_date("23/07/2026"), Some(day("2026-07-23")));
        assert_eq!(parse_date("07/23/2026"), Some(day("2026-07-23")));
        // Deux chiffres d'année : le XXIᵉ siècle.
        assert_eq!(parse_date("23/07/26"), Some(day("2026-07-23")));
        // Et ce qui n'est pas une date n'en est pas une.
        assert_eq!(parse_date(""), None);
        assert_eq!(parse_date("hier"), None);
    }

    /// **Rien ne fait tomber la lecture.** Un fichier vide, tronqué, sans
    /// balise, sans montant, sans date : on rend ce qu'on a, et l'on ne
    /// s'arrête pas. C'est ce qui permettra de réparer une panne qu'on ne
    /// pourra jamais reproduire — le fichier de l'utilisateur ne sortira jamais
    /// de chez lui.
    #[test]
    fn un_fichier_abime_ne_fait_pas_tomber_la_lecture() {
        assert!(accounts_in("").is_empty());
        assert!(read("", "123456A789").is_none());
        assert!(accounts_in("n'importe quoi").is_empty());

        // Tronqué en plein milieu : ce qui précède est lu quand même.
        let cut = &SAMPLE[..SAMPLE.len() - 220];
        let statement = read(cut, "123456A789").unwrap();
        assert!(!statement.transactions.is_empty());

        // Une opération sans montant ni date : elle existe quand même, à zéro
        // et sans date, plutôt que de faire disparaître la ligne.
        let bare = SAMPLE
            .replace("<TRNAMT>-50.00", "")
            .replace("<DTPOSTED>20260723", "");
        let statement = read(&bare, "123456A789").unwrap();
        assert_eq!(statement.transactions.len(), 2);
        assert_eq!(statement.transactions[0].amount, 0);
        assert_eq!(statement.transactions[0].date, None);
        assert_eq!(statement.transactions[0].fitid, "P_GDYTLL29");
    }

    /// Les entités du SGML reviennent à leur caractère : « CARREFOUR & CIE » et
    /// non « CARREFOUR &amp; CIE ».
    #[test]
    fn les_entites_reviennent_a_leur_caractere() {
        let with = SAMPLE.replace("CARTE X0000", "CARREFOUR &amp; CIE X&#233;");
        let statement = read(&with, "123456A789").unwrap();
        assert!(
            statement.transactions[0]
                .label
                .starts_with("CARREFOUR & CIE Xé"),
            "{}",
            statement.transactions[0].label
        );
    }

    /// Un fichier en CP1252 — la page des banques françaises — se lit sans
    /// qu'on ait à croire son en-tête, qui ment aussi souvent qu'il dit vrai.
    #[test]
    fn l_encodage_se_deduit_des_octets_et_non_de_l_en_tete() {
        // « CRÊPERIE » en CP1252 : le Ê vaut un seul octet, 0xCA.
        let mut bytes: Vec<u8> = b"<NAME>ACHAT CB CR".to_vec();
        bytes.push(0xCA);
        bytes.extend_from_slice(b"PERIE</STMTTRN>");
        assert!(decode(&bytes).contains("CRÊPERIE"));

        // Et le même texte en UTF-8 se lit comme de l'UTF-8.
        assert!(decode("<NAME>ACHAT CB CRÊPERIE".as_bytes()).contains("CRÊPERIE"));
    }

    // --- Les deux familles de relevés (étape A, 19/10/2026) ----------------
    //
    // Fabrice : « tu ne sauras pas de qui vient l'OFX ». Le lecteur ne cherche
    // jamais à reconnaître la banque ; il lit ce que chaque opération porte.
    // Ces échantillons reproduisent la **forme** des deux relevés réels
    // reçus — La Banque Postale (sur une ligne, sans MEMO, montants au point)
    // et la BNP (une balise par ligne, NAME générique, MEMO détaillé, DTUSER,
    // montants à la virgule) —, avec des montants et des noms inventés. Les
    // vrais relevés n'entrent jamais dans le projet (secret bancaire).

    /// Forme BNP : une balise par ligne, `</STMTTRN>` fermé, `DTUSER`, montants
    /// à la virgule, `NAME` court et générique, tout le détail dans `MEMO`.
    const BNP_LIKE: &str = "OFXHEADER:100\r\nDATA:OFXSGML\r\nVERSION:102\r\nCHARSET:1252\r\n\r\n\
<OFX>\r\n<SIGNONMSGSRSV1>\r\n<SONRS>\r\n<STATUS>\r\n<CODE>0\r\n<SEVERITY>INFO\r\n</STATUS>\r\n\
<DTSERVER>20260917\r\n<LANGUAGE>FRA\r\n</SONRS>\r\n</SIGNONMSGSRSV1>\r\n<BANKMSGSRSV1>\r\n\
<STMTTRNRS>\r\n<TRNUID>NOTPROVIDED\r\n<STMTRS>\r\n<CURDEF>EUR\r\n<BANKACCTFROM>\r\n\
<BANKID>99999\r\n<BRANCHID>00100\r\n<ACCTID>00099988877\r\n<ACCTTYPE>CHECKING\r\n</BANKACCTFROM>\r\n\
<BANKTRANLIST>\r\n<DTSTART>20260601\r\n<DTEND>20260916\r\n\
<STMTTRN>\r\n<TRNTYPE>DEBIT\r\n<DTPOSTED>20260916\r\n<DTUSER>20260916\r\n<TRNAMT>-1234,50\r\n\
<FITID>HST000000000000000001\r\n<NAME>PRLV SEPA\r\n\
<MEMO>CAISSE INVENTEE ECH/160926 ID EMETTEUR/FR00ZZZ000000 MDT/ABC123 REF/XYZ789 LIB/COTISATION\r\n</STMTTRN>\r\n\
<STMTTRN>\r\n<TRNTYPE>CREDIT\r\n<DTPOSTED>20260915\r\n<DTUSER>20260915\r\n<TRNAMT>838,49\r\n\
<FITID>HST000000000000000002\r\n<NAME>VIRT SEPA RECU\r\n\
<MEMO>/FRM SOCIETE IMAGINAIRE /EID 1D0750000 /RNF P 000000 BDR 000000\r\n</STMTTRN>\r\n\
<STMTTRN>\r\n<TRNTYPE>CHECK\r\n<DTPOSTED>20260903\r\n<DTUSER>20260902\r\n<TRNAMT>-476,60\r\n\
<FITID>HST000000000000000003\r\n<NAME>CHEQUE\r\n<MEMO>2256129\r\n</STMTTRN>\r\n\
</BANKTRANLIST>\r\n<LEDGERBAL>\r\n<BALAMT>58909,56\r\n<DTASOF>20260917\r\n</LEDGERBAL>\r\n\
<AVAILBAL>\r\n<BALAMT>58909,56\r\n<DTASOF>20260917\r\n</AVAILBAL>\r\n</STMTRS>\r\n</STMTTRNRS>\r\n\
</BANKMSGSRSV1>\r\n</OFX>\r\n";

    /// Les cas limites, sur une ligne : un MEMO qui répète le NAME, un MEMO
    /// qui le prolonge (NAME = le MEMO coupé à 32 caractères), un MEMO sans
    /// NAME, un MEMO vide, et une opération sans MEMO — dans un même fichier.
    const MIXED: &str = "OFXHEADER:100\r\nDATA:OFXSGML\r\nVERSION:102\r\n\r\n\
<OFX><BANKMSGSRSV1><STMTTRNRS><STMTRS><CURDEF>EUR<BANKACCTFROM><BANKID>11111\
<ACCTID>MIX001<ACCTTYPE>CHECKING</BANKACCTFROM><BANKTRANLIST><DTSTART>20260101<DTEND>20260131\
<STMTTRN><TRNTYPE>POS<DTPOSTED>20260105<TRNAMT>-10.00<FITID>M1<NAME>ACHAT CB BOULANGERIE<MEMO>ACHAT CB BOULANGERIE</STMTTRN>\
<STMTTRN><TRNTYPE>PAYMENT<DTPOSTED>20260106<TRNAMT>-20.00<FITID>M2<NAME>PRELEVEMENT DE MUTUELLE INVENTE<MEMO>PRELEVEMENT DE MUTUELLE INVENTEE DU NORD REF 42</STMTTRN>\
<STMTTRN><TRNTYPE>DEBIT<DTPOSTED>20260107<TRNAMT>-30.00<FITID>M3<MEMO>VIREMENT VERS EPARGNE</STMTTRN>\
<STMTTRN><TRNTYPE>DEBIT<DTPOSTED>20260108<TRNAMT>-40.00<FITID>M4<NAME>FRAIS<MEMO>   </STMTTRN>\
<STMTTRN><TRNTYPE>DEBIT<DTPOSTED>20260109<TRNAMT>-50.00<FITID>M5<NAME>RETRAIT DAB</STMTTRN>\
</BANKTRANLIST><LEDGERBAL><BALAMT>100.00<DTASOF>20260131</LEDGERBAL></STMTRS></STMTTRNRS></BANKMSGSRSV1></OFX>";

    /// Ce que le lecteur rend d'une opération, en une ligne comparable :
    /// date, montant, type, libellé, FITID.
    fn summary(transaction: &Transaction) -> String {
        format!(
            "{}|{}|{}|{}|{}",
            transaction.date.map(|d| d.format("%Y-%m-%d").to_string()).unwrap_or_default(),
            transaction.amount,
            transaction.kind,
            transaction.label,
            transaction.fitid
        )
    }

    /// **La référence d'aujourd'hui, figée** (étape A). Ce que le lecteur rend
    /// des trois formes avant qu'il ne lise le MEMO. Les étapes suivantes
    /// ajoutent le MEMO **à côté** : ces lignes-ci ne doivent jamais changer.
    #[test]
    fn les_trois_formes_se_lisent_comme_avant_le_memo() {
        let lbp = read(SAMPLE, "123456A789").unwrap();
        assert_eq!(
            lbp.transactions.iter().map(summary).collect::<Vec<_>>(),
            vec![
                "2026-07-23|-50000000|ATM|CARTE X0000    22/07/26 A 19H23|P_GDYTLL29",
                "2026-07-22|-120000000|POS|ACHAT CB COMMERCE TROIS       21.07.26|P_GDNTLLC@",
            ]
        );

        assert_eq!(accounts_in(BNP_LIKE), vec!["00099988877".to_string()]);
        let bnp = read(BNP_LIKE, "00099988877").unwrap();
        assert_eq!(
            bnp.transactions.iter().map(summary).collect::<Vec<_>>(),
            vec![
                "2026-09-16|-1234500000|DEBIT|PRLV SEPA|HST000000000000000001",
                "2026-09-15|838490000|CREDIT|VIRT SEPA RECU|HST000000000000000002",
                "2026-09-03|-476600000|CHECK|CHEQUE|HST000000000000000003",
            ]
        );
        assert_eq!(bnp.ledger_balance, Some(58_909_560_000));
        assert_eq!(bnp.from, Some(day("2026-06-01")));
        assert_eq!(bnp.to, Some(day("2026-09-16")));

        let mixed = read(MIXED, "MIX001").unwrap();
        assert_eq!(
            mixed.transactions.iter().map(summary).collect::<Vec<_>>(),
            vec![
                "2026-01-05|-10000000|POS|ACHAT CB BOULANGERIE|M1",
                "2026-01-06|-20000000|PAYMENT|PRELEVEMENT DE MUTUELLE INVENTE|M2",
                // Sans NAME, aujourd'hui, l'opération n'a pas de libellé.
                "2026-01-07|-30000000|DEBIT||M3",
                "2026-01-08|-40000000|DEBIT|FRAIS|M4",
                "2026-01-09|-50000000|DEBIT|RETRAIT DAB|M5",
            ]
        );
    }

    /// **Sur de vrais relevés** (étape A, 19/10/2026) : chaque opération lue
    /// est écrite, une par ligne, dans un fichier par relevé — la référence à
    /// laquelle on comparera après chaque étape. Les relevés ne sont pas dans
    /// le dépôt (secret bancaire).
    ///
    ///     RADINUS_OFX=/chemin/a.ofx:/chemin/b.ofx RADINUS_OFX_DUMP=/dossier \
    ///       cargo test -p radinus-core --lib vrais_releves_ofx -- --ignored --nocapture
    #[test]
    #[ignore]
    fn vrais_releves_ofx() {
        let files = std::env::var("RADINUS_OFX").expect("RADINUS_OFX");
        let dump = std::env::var("RADINUS_OFX_DUMP").ok().map(std::path::PathBuf::from);
        for path in files.split(':').filter(|path| !path.is_empty()) {
            let text = decode(&std::fs::read(path).unwrap());
            let name = std::path::Path::new(path).file_name().unwrap().to_string_lossy().to_string();
            let mut lines = Vec::new();
            for account in accounts_in(&text) {
                let statement = read(&text, &account).unwrap();
                let total: i64 = statement.transactions.iter().map(|t| t.amount).sum();
                let labels: std::collections::BTreeSet<&str> =
                    statement.transactions.iter().map(|t| t.label.as_str()).collect();
                println!(
                    "{name} — compte {account} : {} opérations du {:?} au {:?}, total {}, solde {:?} au {:?}, {} libellés différents, {} vides, {} MEMO (le plus long : {} caractères)",
                    statement.transactions.len(),
                    statement.from,
                    statement.to,
                    total,
                    statement.ledger_balance,
                    statement.ledger_balance_date,
                    labels.len(),
                    statement.transactions.iter().filter(|t| t.label.is_empty()).count(),
                    statement.transactions.iter().filter(|t| !t.memo.is_empty()).count(),
                    statement.transactions.iter().map(|t| t.memo.chars().count()).max().unwrap_or(0),
                );
                lines.push(format!(
                    "compte|{account}|{:?}|{:?}|{:?}|{:?}",
                    statement.from, statement.to, statement.ledger_balance, statement.available_balance
                ));
                lines.extend(statement.transactions.iter().map(summary));
            }
            if let Some(folder) = &dump {
                std::fs::create_dir_all(folder).unwrap();
                std::fs::write(folder.join(format!("{name}.txt")), lines.join("\n") + "\n").unwrap();
            }
        }
    }

    /// **Le MEMO se lit à côté du libellé** (étape B) : le libellé reste le
    /// NAME, intact ; le MEMO arrive dans son propre champ, vide quand le
    /// fichier n'en porte pas.
    #[test]
    fn le_memo_se_lit_a_cote_du_libelle() {
        let lbp = read(SAMPLE, "123456A789").unwrap();
        assert!(lbp.transactions.iter().all(|t| t.memo.is_empty()), "La Banque Postale n'a pas de MEMO");

        let bnp = read(BNP_LIKE, "00099988877").unwrap();
        let memos: Vec<&str> = bnp.transactions.iter().map(|t| t.memo.as_str()).collect();
        assert_eq!(
            memos,
            vec![
                "CAISSE INVENTEE ECH/160926 ID EMETTEUR/FR00ZZZ000000 MDT/ABC123 REF/XYZ789 LIB/COTISATION",
                "/FRM SOCIETE IMAGINAIRE /EID 1D0750000 /RNF P 000000 BDR 000000",
                "2256129",
            ]
        );

        let mixed = read(MIXED, "MIX001").unwrap();
        let memos: Vec<&str> = mixed.transactions.iter().map(|t| t.memo.as_str()).collect();
        assert_eq!(
            memos,
            vec![
                "ACHAT CB BOULANGERIE",
                "PRELEVEMENT DE MUTUELLE INVENTEE DU NORD REF 42",
                "VIREMENT VERS EPARGNE",
                "",
                "",
            ]
        );
        // Les entités du MEMO reviennent à leur caractère, comme celles du NAME.
        let with = BNP_LIKE.replace("SOCIETE IMAGINAIRE", "DUPONT &amp; FILS");
        assert!(read(&with, "00099988877").unwrap().transactions[1].memo.contains("DUPONT & FILS"));
    }

    /// **Le libellé et la référence, pour chaque forme et chaque réglage**
    /// (les deux menus, 20/10/2026).
    #[test]
    fn le_libelle_et_la_reference_se_composent_operation_par_operation() {
        use LabelSource as L;
        use ReferenceSource as R;
        let options = |label, reference| MemoOptions { label, reference };
        let labels = [L::Name, L::Memo, L::NameAndMemo];
        let references = [R::Memo, R::Name, R::NameAndMemo, R::Empty];
        assert_eq!(MemoOptions::default(), options(L::Name, R::Memo));

        // Les douze combinaisons, NAME générique et MEMO détaillé (BNP).
        let (name, memo) = ("PRLV SEPA", "EDF REF/42");
        let label_of = |label| match label {
            L::Name => "PRLV SEPA",
            L::Memo => "EDF REF/42",
            L::NameAndMemo => "PRLV SEPA EDF REF/42",
        };
        let reference_of = |reference| match reference {
            R::Memo => "EDF REF/42",
            R::Name => "PRLV SEPA",
            R::NameAndMemo => "PRLV SEPA EDF REF/42",
            R::Empty => "",
        };
        for label in labels {
            for reference in references {
                assert_eq!(
                    compose(name, memo, options(label, reference)),
                    (label_of(label).to_string(), reference_of(reference).to_string()),
                    "{label:?} / {reference:?}"
                );
            }
        }

        // Sans MEMO (La Banque Postale) : le libellé garde toujours le nom ;
        // la référence n'a que ce qui existe.
        for label in labels {
            for reference in references {
                let (got_label, got_reference) = compose("RETRAIT DAB", "   ", options(label, reference));
                assert_eq!(got_label, "RETRAIT DAB", "{label:?}");
                let expected = match reference {
                    R::Name | R::NameAndMemo => "RETRAIT DAB",
                    R::Memo | R::Empty => "",
                };
                assert_eq!(got_reference, expected, "{reference:?}");
            }
        }

        // Sans NAME : le libellé prend le mémo, quel que soit le choix.
        for label in labels {
            assert_eq!(compose("", "VIREMENT VERS EPARGNE", options(label, R::Memo)).0, "VIREMENT VERS EPARGNE");
        }
        assert_eq!(compose("", "VIREMENT VERS EPARGNE", options(L::Name, R::Name)).1, "");

        // Un MEMO qui répète le NAME, ou qui le prolonge : pas de doublon.
        let twice = options(L::NameAndMemo, R::NameAndMemo);
        assert_eq!(compose("ACHAT CB BOULANGERIE", "ACHAT CB BOULANGERIE", twice).0, "ACHAT CB BOULANGERIE");
        assert_eq!(
            compose("PRELEVEMENT DE MUTUELLE INVENTE", "PRELEVEMENT DE MUTUELLE INVENTEE DU NORD", twice),
            (
                "PRELEVEMENT DE MUTUELLE INVENTEE DU NORD".to_string(),
                "PRELEVEMENT DE MUTUELLE INVENTEE DU NORD".to_string()
            )
        );
        assert_eq!(compose("VIREMENT DE PAUL MARTIN", "PAUL MARTIN", twice).1, "VIREMENT DE PAUL MARTIN");

        // Chaque choix a son mot, et le relit.
        for label in labels {
            assert_eq!(LabelSource::from_key(label.key()), Some(label));
        }
        for reference in references {
            assert_eq!(ReferenceSource::from_key(reference.key()), Some(reference));
        }
        assert_eq!(LabelSource::from_key("autre"), None);

        // La référence est coupée à 255 caractères ; le libellé, non.
        let long = "X".repeat(250);
        let (label, reference) = compose("PRLV SEPA", &long, twice);
        assert_eq!(label.chars().count(), 260);
        assert_eq!(reference.chars().count(), REFERENCE_MAX);
    }
}
