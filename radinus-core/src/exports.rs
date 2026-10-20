//! Les deux sorties bancaires du menu Export de F02 — OFX et QIF (phase 14).
//!
//! Portage de la classe `Ofx_Export` de Fabrice, jusqu'à ses valeurs de
//! remplissage. Le QIF, lui, n'a pas d'original côté export : sa classe
//! `Qif_Import` ne fait que lire, et Fabrice a tranché le 30/07/2026 que la
//! phase 14 **ne parle que d'exportation** — le fichier produit doit donc être
//! du QIF valide pour un autre logiciel, et non pour son importeur à lui.
//!
//! # Pourquoi ces deux-là ne passent pas par une feuille
//!
//! Les dix autres sorties du menu partent d'une [`crate::sheets::Sheet`] : une
//! grille de cellules, c'est-à-dire **ce que la fenêtre affiche**. Ces deux-ci
//! ne peuvent pas : un OFX ne porte pas des colonnes, il porte des opérations
//! — une date, un montant signé, un identifiant, un libellé — et ce que la
//! fenêtre montre à l'écran (« Débit » dans une colonne, « Crédit » dans une
//! autre) n'est pas ce que le format attend.
//!
//! Elles partent donc de la base, sur la liste de clefs que la fenêtre leur
//! donne. **C'est la fenêtre qui décide de quoi il s'agit** — l'ordre du tri,
//! la période, les entonnoirs — et le noyau qui relit ces opérations-là.
//!
//! # Trois règles dictées par Fabrice le 30/07/2026
//!
//!   * **les mères seules** : une opération ventilée s'exporte pour son
//!     montant total, sans ses filles. Écrire les deux ferait compter l'argent
//!     deux fois, et un logiciel relisant le fichier verrait le double du solde
//!     réel — une faute qui ne se voit pas, la pire sorte ;
//!   * **tel qu'affiché** : la période choisie, les filtres posés, l'ordre du
//!     tri en cours. La même règle que l'export par clic droit du 26/07 ;
//!   * **le FITID reste vide** quand la banque n'en a pas donné. On n'invente
//!     pas ce qu'on n'a pas. La conséquence est assumée et vaut d'être dite :
//!     la boucle « export puis réimport sans doublon » ne tient que pour les
//!     opérations venues d'une banque ; celles saisies à la main n'ont aucune
//!     identité dans le fichier et seront vues comme neuves à chaque lecture.

use crate::domain::NaiveDate;
use rusqlite::{Connection, Result};
use std::path::Path;

/// Une opération, telle que ces deux formats la demandent.
#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct Line {
    pub date: Option<NaiveDate>,
    pub label: String,
    /// Signé, en micro-unités.
    pub amount: i64,
    /// L'identifiant que la banque a donné, ou vide.
    pub fitid: String,
    pub payee: String,
    pub category: String,
    /// La référence paiement — souvent le MEMO de la banque depuis le
    /// 19/10/2026. Elle part dans le **mémo** du fichier, jamais dans le
    /// numéro de chèque : « ça n'a rien à voir avec un numéro de chèque »
    /// (Fabrice).
    pub reference: String,
    /// Le numéro du chèque, quand l'opération est liée à un chèque du
    /// chéquier ; vide sinon. Lui seul va dans `CHECKNUM` et dans `N`.
    pub check_number: String,
}

/// Ce que l'en-tête d'un OFX doit dire du compte.
///
/// Les valeurs de remplissage sont celles de sa classe — `00000` pour la
/// banque et le guichet, `00000000000` pour le numéro — et elles ne servent
/// que lorsque la fiche compte ne porte rien. Radinus 2 connaît le vrai RIB, il
/// n'y a pas de raison de l'omettre.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Account {
    pub bank: String,
    pub branch: String,
    pub number: String,
    pub currency: String,
    /// `SoldeBanque`, ce que la banque connaît — le `LEDGERBAL` du format.
    pub balance_bank: i64,
    /// `SoldeReel`, engagé compris — l'`AVAILBAL`.
    pub balance_real: i64,
}

impl Default for Account {
    fn default() -> Self {
        Self {
            bank: "00000".to_string(),
            branch: "00000".to_string(),
            number: "00000000000".to_string(),
            currency: "EUR".to_string(),
            balance_bank: 0,
            balance_real: 0,
        }
    }
}

/// Lit le compte tel que l'en-tête OFX en a besoin.
pub fn account_of(conn: &Connection, account_id: i64) -> Result<Account> {
    let mut statement = conn.prepare(
        "SELECT COBCodeBanque, COBCodeGuichet, COBNumCompte, Devise, SoldeBanque, SoldeReel
         FROM Compte WHERE IDCompte = ?1",
    )?;
    let mut rows = statement.query([account_id])?;
    let Some(row) = rows.next()? else {
        return Ok(Account::default());
    };
    let filled = |value: String, fallback: &str| {
        if value.trim().is_empty() {
            fallback.to_string()
        } else {
            value.trim().to_string()
        }
    };
    Ok(Account {
        bank: filled(row.get(0)?, "00000"),
        branch: filled(row.get(1)?, "00000"),
        number: filled(row.get(2)?, "00000000000"),
        currency: filled(row.get(3)?, "EUR"),
        balance_bank: row.get(4)?,
        balance_real: row.get(5)?,
    })
}

/// Relit les opérations que la fenêtre désigne, **dans l'ordre où elle les
/// donne** — c'est cet ordre qui porte le tri en cours.
///
/// Les clefs inconnues, ou celles d'un autre compte, sont simplement absentes
/// du résultat : une fenêtre ne doit pas pouvoir sortir les opérations d'un
/// compte qu'elle ne montre pas.
pub fn lines(conn: &Connection, account_id: i64, ids: &[i64]) -> Result<Vec<Line>> {
    let mut statement = conn.prepare(
        "SELECT o.Date, o.Libelle, o.Montant, o.FitID, o.ReferencePaiement,
                COALESCE(t.Libelle, ''), COALESCE(c.Libelle, ''), COALESCE(chq.NumChq, 0)
         FROM Operation o
         LEFT JOIN Tiers t ON t.IDTiers = o.IDTiers
         LEFT JOIN Categorie c ON c.IDCategorie = o.IDCategorie
         LEFT JOIN Cheque chq ON chq.IDCheque = o.IDCheque AND o.IDCheque <> 0
         WHERE o.IDOperation = ?1 AND o.IDCompte = ?2",
    )?;
    let mut found = Vec::with_capacity(ids.len());
    for id in ids {
        let mut rows = statement.query(rusqlite::params![id, account_id])?;
        let Some(row) = rows.next()? else {
            continue;
        };
        let date: Option<String> = row.get(0)?;
        found.push(Line {
            date: date.and_then(|text| NaiveDate::parse_from_str(&text, "%Y-%m-%d").ok()),
            label: row.get(1)?,
            amount: row.get(2)?,
            fitid: row.get(3)?,
            reference: row.get(4)?,
            payee: row.get(5)?,
            category: row.get(6)?,
            check_number: match row.get::<_, i64>(7)? {
                0 => String::new(),
                number => number.to_string(),
            },
        });
    }
    Ok(found)
}

/// Un montant tel que ces deux formats l'écrivent : au point, deux décimales,
/// signe compris. Aucun symbole, aucune espace de milliers — ce n'est pas un
/// affichage, c'est une donnée.
fn amount(micro: i64) -> String {
    let negative = micro < 0;
    let absolute = micro.unsigned_abs();
    let units = absolute / 1_000_000;
    let cents = (absolute % 1_000_000 + 5_000) / 10_000;
    // L'arrondi des centimes peut faire déborder sur l'unité.
    let (units, cents) = if cents >= 100 {
        (units + 1, 0)
    } else {
        (units, cents)
    };
    format!("{}{units}.{cents:02}", if negative { "-" } else { "" })
}

/// La date compacte de l'OFX : `AAAAMMJJ`, comme la lit son importeur.
fn compact(date: Option<NaiveDate>) -> String {
    date.map(|day| day.format("%Y%m%d").to_string())
        .unwrap_or_default()
}

/// Ce que le format interdit à l'intérieur d'une valeur.
///
/// L'OFX 1.x est du SGML : un `<` ouvrirait une balise là où il n'y en a pas,
/// et un `&` amorcerait une entité. Un libellé de banque en contient de temps
/// en temps, et le fichier ne doit pas devenir illisible pour autant.
fn sgml(text: &str) -> String {
    text.replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
        .replace(['\r', '\n'], " ")
}

/// Écrit l'OFX — le portage de sa classe, dans son ordre et avec ses valeurs.
///
/// `today` est donné plutôt que lu de l'horloge : le noyau ne connaît pas
/// l'heure, et un fichier produit deux fois de suite doit pouvoir être comparé
/// à lui-même dans un test.
pub fn ofx(account: &Account, lines: &[Line], today: NaiveDate) -> String {
    let stamp = today.format("%Y%m%d").to_string();
    let first = lines.iter().filter_map(|line| line.date).min();
    let last = lines.iter().filter_map(|line| line.date).max();

    let mut written = String::new();
    // Son en-tête, mot pour mot. `DATA:OFXSGML` annonce du SGML : les balises
    // ne se ferment pas, et c'est exactement ce que son importeur attend.
    written.push_str("OFXHEADER:100\r\n");
    written.push_str("DATA:OFXSGML\r\n");
    written.push_str("VERSION:102\r\n");
    written.push_str("SECURITY:NONE\r\n");
    written.push_str("ENCODING:USASCII\r\n");
    written.push_str("CHARSET:1252\r\n");
    written.push_str("COMPRESSION:NONE\r\n");
    written.push_str("OLDFILEUID:NONE\r\n");
    written.push_str("NEWFILEUID:NONE\r\n");
    written.push_str("<OFX>\r\n");
    written.push_str("<SIGNONMSGSRSV1>\r\n");
    written.push_str(&format!(
        "<SONRS><STATUS><CODE>0<SEVERITY>INFO</STATUS><DTSERVER>{stamp}000000\r\n"
    ));
    written.push_str("</SONRS>\r\n");
    written.push_str("</SIGNONMSGSRSV1>\r\n");
    written.push_str("<BANKMSGSRSV1>\r\n");
    written.push_str("<STMTTRNRS>\r\n");
    written.push_str("<LANGUAGE>FRE\r\n");
    written.push_str("<TRNUID>0000000000000<STATUS><CODE>0<SEVERITY>INFO</STATUS>\r\n");
    written.push_str("<CLTCOOKIE>0000000000000\r\n");
    written.push_str("<STMTRS>\r\n");
    written.push_str(&format!("<CURDEF>{}\r\n", sgml(&account.currency)));
    written.push_str("<BANKACCTFROM>\r\n");
    written.push_str(&format!("<BANKID>{}\r\n", sgml(&account.bank)));
    written.push_str(&format!(
        "<BRANCHID>{}<ACCTID>{}<ACCTTYPE>CHECKING<ACCTKEY>00\r\n",
        sgml(&account.branch),
        sgml(&account.number)
    ));
    written.push_str("</BANKACCTFROM>\r\n");
    written.push_str("<BANKTRANLIST>\r\n");
    written.push_str(&format!("<DTSTART>{}\r\n", compact(first)));
    written.push_str(&format!("<DTEND>{}\r\n", compact(last)));

    for line in lines {
        // Son `EcritFichier_Ligne` : le sens du montant fait le type, et rien
        // d'autre.
        let kind = if line.amount < 0 { "DEBIT" } else { "CREDIT" };
        written.push_str("<STMTTRN>\r\n");
        written.push_str(&format!("<TRNTYPE>{kind}\r\n"));
        written.push_str(&format!("<DTPOSTED>{}\r\n", compact(line.date)));
        written.push_str(&format!("<TRNAMT>{}\r\n", amount(line.amount)));
        written.push_str(&format!("<FITID>{}\r\n", sgml(&line.fitid)));
        written.push_str(&format!("<NAME>{}\r\n", sgml(&line.label)));
        // Le numéro d'un vrai chèque, et la référence paiement en mémo
        // (19/10/2026). Une balise vide n'est pas écrite.
        if !line.check_number.trim().is_empty() {
            written.push_str(&format!("<CHECKNUM>{}\r\n", sgml(line.check_number.trim())));
        }
        let memo = line.reference.replace(['\r', '\n'], " ");
        if !memo.trim().is_empty() {
            written.push_str(&format!("<MEMO>{}\r\n", sgml(memo.trim())));
        }
        written.push_str("</STMTTRN>\r\n");
    }

    written.push_str("</BANKTRANLIST>\r\n");
    written.push_str(&format!(
        "<LEDGERBAL><BALAMT>{}<DTASOF>{stamp}</LEDGERBAL>\r\n",
        amount(account.balance_bank)
    ));
    written.push_str(&format!(
        "<AVAILBAL><BALAMT>{}<DTASOF>{stamp}</AVAILBAL>\r\n",
        amount(account.balance_real)
    ));
    written.push_str("</STMTRS>\r\n");
    written.push_str("</STMTTRNRS>\r\n");
    written.push_str("</BANKMSGSRSV1>\r\n");
    written.push_str("</OFX>\r\n");
    written
}

/// Écrit le QIF — les codes standards du format, un enregistrement par
/// opération, fermé par `^`.
///
/// `D` la date, `T` le montant signé, `P` le tiers, `M` le libellé suivi de la
/// référence paiement, `L` la catégorie, `N` le numéro d'un vrai chèque — et
/// rien d'autre : la référence « n'a rien à voir avec un numéro de chèque »
/// (Fabrice, 19/10/2026). Une ligne dont le contenu est vide
/// n'est pas écrite : le format n'exige que la date et le montant, et un `P`
/// suivi de rien ne dirait rien.
///
/// La date part en `JJ/MM/AAAA`. Le QIF n'a jamais eu de norme sur ce point —
/// les fichiers américains écrivent le mois d'abord — et le logiciel qui a
/// produit celui-ci est français.
pub fn qif(lines: &[Line]) -> String {
    let mut written = String::from("!Type:Bank\n");
    for line in lines {
        if let Some(date) = line.date {
            written.push_str(&format!("D{}\n", date.format("%d/%m/%Y")));
        }
        written.push_str(&format!("T{}\n", amount(line.amount)));
        let memo = match (line.label.trim(), line.reference.trim()) {
            (label, "") => label.to_string(),
            ("", reference) => reference.to_string(),
            (label, reference) => format!("{label} - {reference}"),
        };
        for (code, value) in [
            ('P', &line.payee),
            ('M', &memo),
            ('L', &line.category),
            ('N', &line.check_number),
        ] {
            let cleaned = value.replace(['\r', '\n'], " ");
            if !cleaned.trim().is_empty() {
                written.push_str(&format!("{code}{cleaned}\n"));
            }
        }
        written.push_str("^\n");
    }
    written
}

/// Écrit le fichier demandé, **d'après son extension** — la même règle que
/// [`crate::sheets::write`] : c'est l'utilisateur qui a choisi le nom dans le
/// sélecteur du système, et le format suit ce qu'il a demandé.
///
/// Rend le nombre d'opérations écrites.
pub fn write(
    conn: &Connection,
    account_id: i64,
    ids: &[i64],
    path: &Path,
    today: NaiveDate,
) -> Result<usize> {
    let lines = lines(conn, account_id, ids)?;
    let extension = path
        .extension()
        .and_then(|extension| extension.to_str())
        .unwrap_or_default();
    let written = if extension.eq_ignore_ascii_case("qif") {
        qif(&lines)
    } else {
        ofx(&account_of(conn, account_id)?, &lines, today)
    };
    std::fs::write(path, written).map_err(|error| {
        rusqlite::Error::ToSqlConversionFailure(Box::new(std::io::Error::other(error.to_string())))
    })?;
    Ok(lines.len())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn a_line(day: u32, label: &str, micro: i64, fitid: &str) -> Line {
        Line {
            date: NaiveDate::from_ymd_opt(2026, 7, day),
            label: label.to_string(),
            amount: micro,
            fitid: fitid.to_string(),
            payee: "E. Leclerc".to_string(),
            category: "Alimentation".to_string(),
            reference: "CB1234".to_string(),
            check_number: String::new(),
        }
    }

    /// **Les montants s'écrivent au centime, et le centime ne se perd pas.**
    /// Un micro-arrondi qui rabote un centime sur chaque ligne fait un écart
    /// de plusieurs euros sur un relevé, et cet écart ne se voit nulle part.
    #[test]
    fn un_montant_s_ecrit_au_centime_pres() {
        for (micro, written) in [
            (-57_680_000_i64, "-57.68"),
            (1_200_000_000, "1200.00"),
            (0, "0.00"),
            (-1_000_000, "-1.00"),
            (999_990_000, "999.99"),
            // L'arrondi qui déborde sur l'unité.
            (999_999_000, "1000.00"),
            (-1, "-0.00"),
        ] {
            assert_eq!(amount(micro), written, "montant {micro}");
        }
    }

    /// **Le croisement de l'OFX** : le fichier écrit est relu par notre propre
    /// analyseur d'import, et il y retrouve exactement ce qu'on lui a donné.
    ///
    /// C'est la seule vérification qui vaille pour un format : les deux bouts
    /// sont écrits par deux modules qui ne se connaissent pas, et le seul juge
    /// est le fichier lui-même.
    #[test]
    fn l_ofx_ecrit_se_relit_par_notre_propre_analyseur() {
        let account = Account {
            bank: "30002".to_string(),
            branch: "00550".to_string(),
            number: "0000123456A".to_string(),
            currency: "EUR".to_string(),
            balance_bank: 1_234_560_000,
            balance_real: 1_000_000_000,
        };
        let lines = vec![
            a_line(3, "ACHAT CB ETS FERRARI", -57_680_000, "20260703001"),
            a_line(5, "VIREMENT SALAIRE", 1_200_000_000, ""),
        ];
        let written = ofx(
            &account,
            &lines,
            NaiveDate::from_ymd_opt(2026, 7, 30).expect("date"),
        );

        // **Notre propre analyseur d'import le relit**, y compris le compte
        // qu'il annonce : le fichier est le seul juge.
        assert_eq!(
            crate::ofx_import::accounts_in(&written),
            vec!["0000123456A".to_string()]
        );
        let statement =
            crate::ofx_import::read(&written, "0000123456A").expect("le relevé de ce compte");
        assert_eq!(statement.transactions.len(), 2, "deux opérations relues");
        assert_eq!(statement.transactions[0].amount, -57_680_000);
        assert_eq!(statement.transactions[1].amount, 1_200_000_000);
        assert_eq!(statement.transactions[0].label, "ACHAT CB ETS FERRARI");
        assert_eq!(statement.transactions[0].fitid, "20260703001");
        // **Le FITID vide reste vide** : on n'invente pas ce que la banque n'a
        // pas donné (décision de Fabrice, 30/07/2026).
        assert_eq!(statement.transactions[1].fitid, "");
        assert_eq!(
            statement.transactions[0].date,
            NaiveDate::from_ymd_opt(2026, 7, 3),
            "la date compacte se relit"
        );
        // Les deux soldes du pied reviennent au centime.
        assert_eq!(statement.ledger_balance, Some(1_234_560_000));
        assert_eq!(statement.available_balance, Some(1_000_000_000));
        assert_eq!(statement.from, NaiveDate::from_ymd_opt(2026, 7, 3));
        assert_eq!(statement.to, NaiveDate::from_ymd_opt(2026, 7, 5));

        // Et le compte trouvé dans le fichier est bien le nôtre.
        assert!(written.contains("<ACCTID>0000123456A"));
        assert!(written.contains("<TRNTYPE>DEBIT"));
        assert!(written.contains("<TRNTYPE>CREDIT"));
        assert!(written.contains("<LEDGERBAL><BALAMT>1234.56<DTASOF>20260730"));
        assert!(written.contains("<DTSTART>20260703"));
        assert!(written.contains("<DTEND>20260705"));
    }

    /// Le QIF porte les six codes du format, et referme chaque enregistrement.
    #[test]
    fn le_qif_porte_les_codes_du_format() {
        let mut bare = a_line(3, "ACHAT CB", -57_680_000, "");
        bare.payee = String::new();
        bare.category = String::new();
        bare.reference = String::new();
        let written = qif(&[a_line(3, "ACHAT CB", -57_680_000, ""), bare]);

        let records: Vec<&str> = written.trim_end().split("^\n").collect();
        assert!(written.starts_with("!Type:Bank\n"));
        assert_eq!(records.len(), 2, "deux enregistrements, chacun fermé par ^");

        assert!(records[0].contains("D03/07/2026\n"));
        assert!(records[0].contains("T-57.68\n"));
        assert!(records[0].contains("PE. Leclerc\n"));
        // La référence paiement suit le libellé en mémo ; `N` ne porte qu'un
        // vrai numéro de chèque (Fabrice, 19/10/2026).
        assert!(records[0].contains("MACHAT CB - CB1234\n"));
        assert!(records[0].contains("LAlimentation\n"));
        assert!(!records[0].contains("\nN"), "pas de numéro de chèque : pas de N");

        // **Une ligne vide ne s'écrit pas** : un `P` suivi de rien ne dirait
        // rien.
        assert!(!records[1].contains("\nP"));
        assert!(!records[1].contains("\nL"));
        assert!(records[1].contains("T-57.68\n"));
    }

    /// **La référence paiement part en mémo, le numéro de chèque à sa place**
    /// (Fabrice, 19/10/2026 : « ça n'a rien à voir avec un numéro de
    /// chèque »). Une référence vide, ou un chèque absent, n'écrit rien.
    #[test]
    fn la_reference_va_en_memo_et_le_cheque_a_sa_place() {
        let account = Account {
            bank: "12345".into(),
            branch: "00001".into(),
            number: "123456A789".into(),
            currency: "EUR".into(),
            balance_bank: 0,
            balance_real: 0,
        };
        let mut prlv = a_line(3, "PRLV SEPA", -1_000_000, "F1");
        prlv.reference = "URSSAF REF/42 & CO".into();
        let mut cheque = a_line(4, "CHEQUE", -2_000_000, "F2");
        cheque.reference = String::new();
        cheque.check_number = "2256129".into();
        let mut plain = a_line(5, "RETRAIT", -3_000_000, "F3");
        plain.reference = String::new();
        let today = NaiveDate::from_ymd_opt(2026, 10, 19).unwrap();
        let written = ofx(&account, &[prlv.clone(), cheque.clone(), plain.clone()], today);
        assert!(written.contains("<NAME>PRLV SEPA\r\n<MEMO>URSSAF REF/42 &amp; CO\r\n</STMTTRN>"));
        assert!(written.contains("<NAME>CHEQUE\r\n<CHECKNUM>2256129\r\n</STMTTRN>"));
        assert!(written.contains("<NAME>RETRAIT\r\n</STMTTRN>"));
        // Et notre propre lecteur relit le mémo là où la banque l'aurait mis.
        let read = crate::ofx_import::read(&written, "123456A789").unwrap();
        assert_eq!(read.transactions[0].memo, "URSSAF REF/42 & CO");
        assert_eq!(read.transactions[0].label, "PRLV SEPA");

        let written = qif(&[prlv, cheque, plain]);
        assert!(written.contains("MPRLV SEPA - URSSAF REF/42 & CO\n"));
        assert!(written.contains("N2256129\n"));
        assert_eq!(written.matches("\nN").count(), 1, "un seul N : celui du vrai chèque");
    }

    /// Le SGML de l'OFX ne supporte ni `<` ni `&` dans une valeur, et une
    /// banque en met de temps en temps dans ses libellés.
    #[test]
    fn un_libelle_ne_peut_pas_casser_le_fichier() {
        let mut line = a_line(3, "ACHAT <CB> Pierre & Fils", -1_000_000, "");
        line.label = "ACHAT <CB> Pierre & Fils".to_string();
        let written = ofx(
            &Account::default(),
            &[line],
            NaiveDate::from_ymd_opt(2026, 7, 30).expect("date"),
        );
        assert!(written.contains("<NAME>ACHAT &lt;CB&gt; Pierre &amp; Fils"));
        // Et notre analyseur le relit sans y voir une balise de plus.
        let statement =
            crate::ofx_import::read(&written, "00000000000").expect("le relevé");
        assert_eq!(statement.transactions.len(), 1);
    }
}
