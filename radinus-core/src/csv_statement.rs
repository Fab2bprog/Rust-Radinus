//! Le relevé bancaire au format CSV — la fenêtre de découpage (phase 8).
//!
//! Référence : la capture « Point 14 Import CSV.png », et ce que Fabrice a
//! demandé le 27/07/2026 : le même dossier jaune ouvre un `.ofx` **ou** un
//! `.csv` ; si c'est un CSV, une fenêtre de découpage s'intercale, et après
//! validation les lignes basculent dans la fenêtre d'intégration **comme si
//! c'était de l'OFX**.
//!
//! # Un CSV ne se devine pas, il se règle
//!
//! Un fichier OFX se lit sans rien demander : ses balises portent leur nom.
//! Un CSV ne porte rien du tout — pas de nom de champ fiable, pas d'ordre
//! imposé, un séparateur au choix de la banque, et un en-tête de longueur
//! quelconque. Le relevé de l'exemple commence par cinq lignes de
//! renseignements bancaires, une ligne vide, puis les noms de colonnes : les
//! données ne commencent qu'à la huitième.
//!
//! D'où la fenêtre : on **règle**, on **teste**, on **regarde**, on
//! recommence. Elle ne prétend pas deviner ; elle montre ce que le réglage
//! produit et laisse l'œil de l'utilisateur juger. « Si le paramétrage aurait
//! dû être 7 au lieu de 1, ce n'est pas notre problème, c'est celui de
//! l'utilisateur » (Fabrice, même jour).
//!
//! # Mais l'indulgence s'arrête à la porte
//!
//! L'aperçu montre **tout** ce que le découpage produit, charabia compris —
//! c'est comme cela qu'on voit qu'on s'est trompé. Le passage vers la fenêtre
//! d'intégration, lui, est **sévère** : n'entrent que les lignes dont la date
//! et le montant sont lisibles (règle de Fabrice, même jour). Une ligne
//! d'en-tête prise pour une opération n'a ni l'une ni l'autre, et c'est ce qui
//! la trahit.
//!
//! # Un CSV n'a pas d'identifiant
//!
//! Aucun `FITID` là-dedans : l'anti-doublon sera aveugle sur tout ce qui vient
//! d'un CSV, et la fenêtre d'intégration le dira avec la phrase qu'elle réserve
//! aux lignes sans identifiant. Un même CSV importé deux fois entrera deux
//! fois. C'est un fait du format, pas un défaut du portage.

use crate::domain::NaiveDate;
use crate::ofx_import;

/// Comment découper le fichier — les six réglages de la fenêtre.
///
/// Les positions comptent **à partir de 1**, comme à l'écran : « position champ
/// date : 1 » veut dire la première colonne, pas la deuxième.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Settings {
    /// Combien de lignes d'en-tête sauter avant les données.
    pub header_lines: usize,
    /// Ce qui sépare les colonnes.
    pub separator: char,
    pub date_at: usize,
    pub label_at: usize,
    /// **Débit et crédit peuvent désigner la même colonne** — c'est le cas de
    /// l'exemple, 3 et 3 — et cela veut dire une colonne unique de montants
    /// signés. Deux positions différentes veulent dire deux colonnes, l'une
    /// pour les sorties, l'autre pour les entrées.
    pub debit_at: usize,
    pub credit_at: usize,
}

impl Default for Settings {
    /// Les valeurs de la capture, qui sont celles d'un relevé français
    /// ordinaire : point-virgule, date puis libellé puis montant.
    fn default() -> Self {
        Self {
            header_lines: 1,
            separator: ';',
            date_at: 1,
            label_at: 2,
            debit_at: 3,
            credit_at: 3,
        }
    }
}

/// Une ligne du fichier, découpée selon les réglages.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Row {
    /// Le numéro de la ligne dans le fichier, en partant de 1 — celui de
    /// l'aperçu du haut, pour qu'on puisse faire le lien entre les deux
    /// tableaux.
    pub source_line: usize,
    pub date: Option<NaiveDate>,
    pub label: String,
    /// Signé, en micro-unités. Absent quand la colonne ne portait rien de
    /// lisible.
    pub amount: Option<i64>,
}

impl Row {
    /// **Cette ligne peut-elle devenir une opération ?** Il lui faut une date
    /// et un montant ; le libellé peut manquer, un relevé en donne parfois de
    /// vides, et cela n'empêche pas l'opération d'exister.
    ///
    /// C'est la sévérité que Fabrice a demandée : l'aperçu montre tout, le
    /// passage vers l'intégration ne laisse entrer que ceci.
    pub fn is_valid(&self) -> bool {
        self.date.is_some() && self.amount.is_some()
    }
}

/// Le fichier, ligne par ligne, tel qu'il est — l'aperçu du haut.
///
/// L'encodage se déduit des octets, comme pour l'OFX : une banque française
/// écrit volontiers en CP1252, et son en-tête, quand il y en a un, ment autant.
pub fn read(bytes: &[u8]) -> Vec<String> {
    ofx_import::decode(bytes)
        .replace("\r\n", "\n")
        .replace('\r', "\n")
        .split('\n')
        .map(str::to_string)
        .collect()
}

/// Découpe une ligne en champs, en respectant les guillemets.
///
/// Un champ entre guillemets peut contenir le séparateur — c'est même la
/// raison d'être des guillemets — et son contenu en sort intact, guillemets
/// ôtés. Un guillemet doublé à l'intérieur vaut un guillemet, comme partout.
fn fields(line: &str, separator: char) -> Vec<String> {
    let mut found = Vec::new();
    let mut current = String::new();
    let mut quoted = false;
    let mut characters = line.chars().peekable();
    while let Some(c) = characters.next() {
        match c {
            '"' if quoted && characters.peek() == Some(&'"') => {
                current.push('"');
                characters.next();
            }
            '"' => quoted = !quoted,
            c if c == separator && !quoted => {
                found.push(std::mem::take(&mut current));
            }
            c => current.push(c),
        }
    }
    found.push(current);
    found
}

/// Le champ de cette position, ou rien. Les positions comptent à partir de 1 ;
/// zéro veut dire « cette colonne n'existe pas », ce qui est le cas quand une
/// banque ne donne pas de libellé.
fn field(fields: &[String], at: usize) -> &str {
    if at == 0 {
        return "";
    }
    fields.get(at - 1).map_or("", String::as_str)
}

/// `Detect_Date` : **une date fait huit ou dix caractères, et pas autre chose.**
///
/// C'est la règle de Fabrice, et elle est plus stricte que celle de l'OFX à
/// dessein. Un CSV n'annonce pas ses colonnes : sans cette longueur imposée,
/// une ligne d'entête bancaire finirait par ressembler à une date et
/// entrerait dans le compte. Les espaces sont ôtés d'abord, tous.
fn detect_date(text: &str) -> Option<NaiveDate> {
    let tight: String = text.chars().filter(|c| !c.is_whitespace()).collect();
    if tight.len() != 8 && tight.len() != 10 {
        return None;
    }
    // `Extract_Date` ôte un « D » avant de convertir — un reste du QIF, gardé
    // pour rester fidèle et qui ne coûte rien : une date n'en contient pas.
    ofx_import::parse_date(&tight.replace('D', ""))
}

/// `Extract_Montant`, précédé de son `Detect_Montant` : la valeur ne compte
/// que si elle est un nombre, **à la française ou à l'américaine**.
///
/// L'original ôte aussi un « T » avant de lire — même reste du QIF, même
/// innocuité.
fn detect_amount(text: &str) -> Option<i64> {
    let tight: String = text
        .chars()
        .filter(|c| !c.is_whitespace())
        .filter(|c| *c != 'T')
        .collect();
    if tight.is_empty() {
        return None;
    }
    // Ce qui n'est fait que de chiffres, de séparateurs et d'un signe est un
    // nombre ; tout le reste n'en est pas un, et un libellé ne doit jamais
    // passer pour un montant.
    if !tight
        .chars()
        .all(|c| c.is_ascii_digit() || matches!(c, '.' | ',' | '-' | '+' | '(' | ')'))
    {
        return None;
    }
    ofx_import::parse_amount(&tight)
}

/// `Extract_Libelle` : **tous les guillemets sautent, où qu'ils soient.**
///
/// Neuf caractères, dans la liste exacte de Fabrice : le guillemet droit,
/// l'apostrophe, et les sept formes typographiques que Word, les banques et
/// les tableurs sèment un peu partout. Il ne s'agit pas de déballer un champ
/// entre guillemets — cela, le découpage l'a déjà fait — mais d'ôter ceux qui
/// traînent **à l'intérieur** du libellé.
fn extract_label(text: &str) -> String {
    const QUOTES: [char; 9] = [
        '"', '\'', '\u{201E}', '\u{2018}', '\u{2019}', '\u{201C}', '\u{201D}', '«', '»',
    ];
    text.chars().filter(|c| !QUOTES.contains(c)).collect()
}

/// Découpe tout le fichier selon les réglages — ce que montre le tableau du
/// bas, et ce que le bouton « Tester les paramètres » recalcule.
///
/// **Tout est rendu**, y compris ce qui n'a ni date ni montant : c'est
/// précisément en voyant du charabia qu'on comprend qu'on s'est trompé de
/// nombre de lignes d'en-tête. Le tri se fait plus loin, à la porte.
///
/// Les lignes vides sont sautées : une ligne vide n'est pas une opération, et
/// un relevé en contient toujours au moins une, celle de la fin du fichier.
pub fn extract(lines: &[String], settings: &Settings) -> Vec<Row> {
    let mut rows = Vec::new();
    for (index, line) in lines.iter().enumerate().skip(settings.header_lines) {
        if line.trim().is_empty() {
            continue;
        }
        let parts = fields(line, settings.separator);
        // **Le signe vient du texte, pas de la colonne** (règle de Fabrice,
        // 28/07/2026 : rester fidèle à l'original). Les deux colonnes sont
        // lues l'une après l'autre et la dernière qui porte un nombre
        // l'emporte — ce qui, lorsque débit et crédit désignent la même
        // colonne, revient à la lire deux fois pour le même résultat.
        //
        // Cela suppose que la banque signe ses débits. Une banque qui écrirait
        // ses deux colonnes en positif ferait entrer de l'argent sur un débit ;
        // c'est le comportement de l'original, et il est assumé.
        let mut amount = detect_amount(field(&parts, settings.debit_at));
        if let Some(credit) = detect_amount(field(&parts, settings.credit_at)) {
            amount = Some(credit);
        }
        rows.push(Row {
            source_line: index + 1,
            date: detect_date(field(&parts, settings.date_at)),
            // Le libellé garde ses espaces intérieurs, comme dans l'OFX : ce
            // sont eux qui alignent « ACHAT CB …      000 ». Seuls les
            // guillemets s'en vont.
            label: extract_label(field(&parts, settings.label_at)).trim().to_string(),
            amount,
        });
    }
    rows
}

/// Ce que le découpage donnerait, en chiffres — de quoi écrire une phrase
/// honnête sous le tableau d'essai.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct Outcome {
    /// Combien de lignes le découpage a produites, charabia compris.
    pub read: usize,
    /// Combien deviendraient des opérations.
    pub valid: usize,
    /// Combien seraient écartées faute de date ou de montant lisible.
    pub dropped: usize,
}

pub fn outcome(rows: &[Row]) -> Outcome {
    let valid = rows.iter().filter(|row| row.is_valid()).count();
    Outcome {
        read: rows.len(),
        valid,
        dropped: rows.len() - valid,
    }
}

/// Bascule le découpage vers la fenêtre d'intégration, **comme si c'était de
/// l'OFX** : le même type de relevé, le même chemin ensuite.
///
/// **Sévère, ici** : n'entrent que les lignes valides. Et aucune ne porte de
/// `FITID`, puisqu'un CSV n'en contient pas — ce qui rendra chacune
/// « sans identifiant » dans la fenêtre d'intégration, avec l'avertissement qui
/// va avec.
///
/// Le solde et les bornes de période restent vides : un CSV ne les donne pas de
/// façon fiable — celui de l'exemple annonce bien un solde, mais dans une ligne
/// d'en-tête libre que personne ne peut lire à coup sûr. Mieux vaut un écart
/// que la fenêtre montre comme inconnu qu'un écart faux.
pub fn into_statement(rows: &[Row], account_number: &str) -> ofx_import::Statement {
    let transactions = rows
        .iter()
        .filter(|row| row.is_valid())
        .enumerate()
        .map(|(rank, row)| ofx_import::Transaction {
            rank: rank + 1,
            date: row.date,
            amount: row.amount.unwrap_or(0),
            kind: String::new(),
            label: row.label.clone(),
            fitid: String::new(),
            // Le QIF et le CSV n'ont pas de MEMO à part : le QIF range déjà le
            // sien selon ses propres réglages (P-73), le CSV n'en a pas.
            memo: String::new(),
        })
        .collect();
    ofx_import::Statement {
        account_number: account_number.to_string(),
        transactions,
        ..ofx_import::Statement::default()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Le relevé de la capture, réduit : cinq lignes de renseignements, une
    /// ligne vide, la ligne des noms de colonnes, puis les opérations.
    const SAMPLE: &str = "Numéro Compte  ;1234567Z890\r\n\
Type           ;CCP\r\n\
Compte tenu en ;euros\r\n\
Date           ;03/03/2023\r\n\
Solde (EUROS)  ;3409,72\r\n\
\r\n\
Date;Libellé;Montant(EUROS)\r\n\
02/03/2023;\"ACHAT CB COMMERCE UN 01.03.23 CARTE NUMERO      000 \";-13,80\r\n\
01/03/2023;\"ACHAT CB COMMERCE DEUX  28.02.23 EUR    166,08\";-166,08\r\n\
27/02/2023;\"VIREMENT DE TIERS UN\";139,00\r\n";

    fn lines() -> Vec<String> {
        read(SAMPLE.as_bytes())
    }

    fn day(text: &str) -> NaiveDate {
        NaiveDate::parse_from_str(text, "%Y-%m-%d").unwrap()
    }

    /// **Le mauvais réglage produit du charabia, et c'est voulu.** Avec une
    /// seule ligne d'en-tête sautée — le réglage de la capture — les lignes de
    /// renseignements deviennent des opérations sans date ni montant. C'est
    /// ainsi que l'utilisateur voit qu'il s'est trompé.
    #[test]
    fn un_mauvais_reglage_se_voit_dans_l_apercu() {
        let rows = extract(&lines(), &Settings::default());
        let outcome = outcome(&rows);
        assert!(outcome.dropped > 0, "le charabia devrait se voir");
        // « Type ;CCP » : pas de date, pas de montant.
        let junk = rows.iter().find(|row| row.label == "CCP").unwrap();
        assert!(junk.date.is_none());
        assert!(junk.amount.is_none());
        assert!(!junk.is_valid());
    }

    /// **Le bon réglage donne exactement les opérations, et rien d'autre.**
    #[test]
    fn le_bon_reglage_donne_les_operations_et_rien_d_autre() {
        let settings = Settings {
            header_lines: 7,
            ..Settings::default()
        };
        let rows = extract(&lines(), &settings);
        let outcome = outcome(&rows);
        assert_eq!(outcome.read, 3);
        assert_eq!(outcome.valid, 3);
        assert_eq!(outcome.dropped, 0);

        assert_eq!(rows[0].date, Some(day("2023-03-02")));
        assert_eq!(rows[0].amount, Some(-13_800_000));
        // Les guillemets sont ôtés, les espaces intérieurs gardés.
        assert_eq!(
            rows[0].label,
            "ACHAT CB COMMERCE UN 01.03.23 CARTE NUMERO      000"
        );
        assert_eq!(rows[2].amount, Some(139_000_000));
        // Et le numéro de ligne renvoie à l'aperçu du haut.
        assert_eq!(rows[0].source_line, 8);
    }

    /// **La sévérité de la porte.** L'aperçu montre tout ; la bascule vers la
    /// fenêtre d'intégration ne laisse passer que ce qui a une date et un
    /// montant (règle de Fabrice, 27/07/2026).
    ///
    /// Le croisement tient les deux bouts : ce que l'aperçu annonce comme
    /// valide, et ce que le relevé produit réellement.
    #[test]
    fn seules_les_lignes_valides_basculent_vers_l_integration() {
        let rows = extract(&lines(), &Settings::default());
        let announced = outcome(&rows).valid;
        let statement = into_statement(&rows, "1234567Z890");
        assert_eq!(statement.transactions.len(), announced);
        assert_eq!(announced, 3, "les trois opérations, et elles seules");

        // Les rangs sont renumérotés sans trou : la fenêtre d'intégration
        // compte ses lignes à partir de 1, quoi qu'on ait écarté.
        let ranks: Vec<usize> = statement.transactions.iter().map(|t| t.rank).collect();
        assert_eq!(ranks, vec![1, 2, 3]);

        // Et aucune ne porte d'identifiant : c'est le format qui veut ça.
        assert!(statement.transactions.iter().all(|t| t.fitid.is_empty()));
    }

    /// **Un champ entre guillemets peut contenir le séparateur.** C'est même
    /// sa raison d'être, et un découpage naïf couperait le libellé en deux.
    #[test]
    fn un_champ_entre_guillemets_garde_son_separateur() {
        let line = "02/03/2023;\"ACHAT; CB; PARIS\";-13,80";
        let parts = fields(line, ';');
        assert_eq!(parts.len(), 3);
        assert_eq!(parts[1], "ACHAT; CB; PARIS");
        // Un guillemet doublé vaut un guillemet.
        assert_eq!(fields("a;\"b\"\"c\";d", ';')[1], "b\"c");
    }

    /// **Deux colonnes de montants : la dernière qui porte un nombre
    /// l'emporte, et le signe vient du texte.**
    ///
    /// C'est la mécanique de l'original — débit lu, puis crédit lu, chacun
    /// écrasant le précédent quand il détecte quelque chose — et Fabrice a
    /// demandé qu'on la garde telle quelle (28/07/2026). Elle suppose que la
    /// banque signe ses débits ; une banque qui écrirait ses deux colonnes en
    /// positif ferait entrer de l'argent sur un débit, et c'est assumé.
    #[test]
    fn de_deux_colonnes_la_derniere_remplie_l_emporte_avec_son_signe() {
        let file = read(
            "Date;Libelle;Debit;Credit\r\n\
02/03/2023;ACHAT;-13,80;\r\n\
03/03/2023;SALAIRE;;2000,00\r\n"
                .as_bytes(),
        );
        let settings = Settings {
            header_lines: 1,
            separator: ';',
            date_at: 1,
            label_at: 2,
            debit_at: 3,
            credit_at: 4,
        };
        let rows = extract(&file, &settings);
        assert_eq!(rows.len(), 2);
        // La colonne crédit est vide : c'est le débit qui reste, avec son signe.
        assert_eq!(rows[0].amount, Some(-13_800_000));
        // La colonne débit est vide : c'est le crédit qui parle.
        assert_eq!(rows[1].amount, Some(2_000_000_000));
    }

    /// **Un libellé ne doit jamais passer pour un montant.** C'est le
    /// `Detect_Montant` de Fabrice : ce qui n'est pas un nombre n'en est pas
    /// un, et la colonne reste vide plutôt que de valoir zéro.
    #[test]
    fn un_libelle_ne_passe_pas_pour_un_montant_ni_pour_une_date() {
        let file = read("Date;Libelle;Montant\r\nCompte tenu en;euros;CCP\r\n".as_bytes());
        let rows = extract(&file, &Settings::default());
        assert_eq!(rows.len(), 1);
        assert!(rows[0].amount.is_none());
        assert!(rows[0].date.is_none());
        assert!(!rows[0].is_valid());
    }

    /// **Une date fait huit ou dix caractères, et pas autre chose** — la règle
    /// de `Detect_Date`, plus stricte que celle de l'OFX à dessein : sans elle,
    /// une ligne d'entête finirait par ressembler à une date.
    #[test]
    fn une_date_de_csv_fait_huit_ou_dix_caracteres() {
        assert!(detect_date("02/03/2023").is_some());
        assert!(detect_date("02/03/23").is_some());
        assert!(detect_date("20230302").is_some());
        // Trop court, trop long : ce n'en est pas une.
        assert!(detect_date("2/3/23").is_none());
        assert!(detect_date("20230302120000").is_none());
        assert!(detect_date("Compte tenu en").is_none());
    }

    /// **Tous les guillemets sautent, où qu'ils soient** — les neuf de la
    /// liste de Fabrice, et pas seulement ceux qui entourent le champ.
    #[test]
    fn les_guillemets_sautent_meme_au_milieu_du_libelle() {
        let file = read(
            "Date;Libelle;Montant\r\n02/03/2023;ACHAT \u{ab}L\u{2019}\u{c9}PICERIE\u{bb} \"BIO\";-13,80\r\n"
                .as_bytes(),
        );
        let rows = extract(&file, &Settings::default());
        assert_eq!(rows[0].label, "ACHAT LÉPICERIE BIO");
    }

    /// Le séparateur n'est pas toujours le point-virgule, et la virgule
    /// décimale n'empêche rien tant qu'elle est protégée par des guillemets —
    /// ce que fait tout émetteur sérieux.
    #[test]
    fn un_autre_separateur_se_regle_sans_rien_changer_d_autre() {
        let file = read("date,libelle,montant\r\n02/03/2023,ACHAT,\"-13,80\"\r\n".as_bytes());
        let rows = extract(
            &file,
            &Settings {
                separator: ',',
                ..Settings::default()
            },
        );
        assert_eq!(rows.len(), 1);
        assert_eq!(rows[0].amount, Some(-13_800_000));
        assert_eq!(rows[0].label, "ACHAT");
    }

    /// Un fichier vide, un séparateur qui n'apparaît nulle part, un en-tête
    /// plus long que le fichier : rien ne tombe, on rend ce qu'on a.
    #[test]
    fn un_fichier_abime_ne_fait_pas_tomber_le_decoupage() {
        assert!(extract(&read(b""), &Settings::default()).is_empty());
        assert!(extract(&lines(), &Settings {
            header_lines: 1000,
            ..Settings::default()
        })
        .is_empty());

        // Un séparateur absent : tout le contenu tombe dans le premier champ,
        // et le reste est vide. Aucune ligne n'est valide, et cela se voit.
        let rows = extract(
            &lines(),
            &Settings {
                separator: '|',
                ..Settings::default()
            },
        );
        assert_eq!(outcome(&rows).valid, 0);
    }
}
