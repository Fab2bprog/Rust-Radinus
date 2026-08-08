//! Les chèques — `Cheque` (02_BASE_DE_DONNEES.md §3.6), les fenêtres F14 et
//! F12, et l'association chèque↔opération.
//!
//! Portage de `Code Fiche Cheque.txt`, `Code liste cheques.txt` et
//! `Code Liste Operation Cheques.txt`, fournis par Fabrice le 28/07/2026.
//!
//! **Un chèque ne naît jamais ici.** Il naît avec son carnet
//! ([`crate::chequebooks::create`]), et il meurt avec lui. Ce module le lit, le
//! remplit et l'accroche à une opération ; il ne l'ajoute ni ne le supprime,
//! parce que son panneau F14 n'a que quatre icônes — crayon, loupe, maillon,
//! porte — et aucune n'appelle son `Enreg_Supprimer` (arbitrage de Fabrice,
//! 28/07/2026 : un carnet de quarante a quarante chèques, même annulés ; il n'y
//! a pas de trous, il y a des « Annulé / Détruit »).
//!
//! **Rien ne bouge tout seul.** Un chèque naît « Non encore utilisé » et n'en
//! bouge que si on le change à la main, dans la case du tableau ou dans la
//! fiche. Le remplir ne le passe pas à « Émis », lui associer une opération ne
//! le passe pas à « Payé / Compensé ». C'est son original, et Fabrice l'a
//! confirmé : dans sa base réelle la correspondance est parfaite — mais c'est
//! lui qui l'a tenue, main à main, pendant six ans.
//!
//! **Deux fidélités assumées**, arbitrées le même jour :
//!
//! 1. [`operation_count`] — le « Nbr. Opération Associées » de F14 — compte
//!    **toutes** les opérations portant le chèque, filles comprises, alors que
//!    les deux listes d'association ne montrent que les mères. Les deux nombres
//!    peuvent donc diverger. C'est son `NombreOpChq`, tel quel.
//! 2. [`associate`] **écrase sans rien dire** : une opération qui portait déjà
//!    un autre chèque le perd. La fenêtre l'affiche en gras — c'est tout
//!    l'avertissement qu'il y a.

use crate::domain::NamedItem;
use rusqlite::{Connection, Result};
use time_compute::NaiveDate;

/// Un chèque, tel que sa fiche F12 le montre.
#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct Cheque {
    pub id: i64,
    /// `NumChq` — en lecture seule dans la fiche : il vient du carnet.
    pub number: i64,
    pub chequebook_id: i64,
    pub issued_on: Option<NaiveDate>,
    pub place: String,
    pub payee: String,
    /// En micro-unités. Positif (02_BASE_DE_DONNEES.md §3.6) : le sens est
    /// porté par l'opération, pas par le chèque.
    pub amount: i64,
    pub comments: String,
    pub status_id: i64,
}

/// Un chèque tel que la composition du chéquier F14 le montre.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ChequeRow {
    pub id: i64,
    pub number: i64,
    pub issued_on: Option<NaiveDate>,
    pub place: String,
    pub payee: String,
    pub amount: i64,
    pub status_id: i64,
    pub status: String,
    pub comments: String,
    /// `NombreOpChq` — **toutes** les opérations, filles comprises.
    pub operations: i64,
}

/// Une opération telle que les deux fenêtres d'association la montrent :
/// Compte, Nom, Date, Date Pointage, Montant, Chèque associé.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct LinkableOperation {
    pub id: i64,
    pub account_id: i64,
    pub account_label: String,
    pub label: String,
    pub date: Option<NaiveDate>,
    pub clearing_date: Option<NaiveDate>,
    pub amount: i64,
    /// Le chèque qu'elle porte déjà, ou 0. **C'est lui qui met la ligne en
    /// gras** dans son original — le seul avertissement avant l'écrasement.
    pub cheque_id: i64,
    /// « 07328/9506019 », ou « / » quand elle n'en porte aucun. Deux fonctions
    /// chez lui, `ReferenceChequier_NumCheque` et `Reference_NumCheque`,
    /// jointes par une barre — et **sans groupement de chiffres**, contrairement
    /// aux tableaux de F14 et de F02. Deux écritures du même nombre dans le même
    /// logiciel ; reproduites telles quelles.
    pub cheque_reference: String,
}

const COLUMNS: &str = "IDCheque, NumChq, IDChequier, DateEmission, Beneficiaire, \
     Montant, Commentaires, LieuEmission, IDStatutCheque";

fn read(row: &rusqlite::Row<'_>) -> rusqlite::Result<Cheque> {
    Ok(Cheque {
        id: row.get(0)?,
        number: row.get(1)?,
        chequebook_id: row.get(2)?,
        issued_on: row
            .get::<_, Option<String>>(3)?
            .and_then(|text| NaiveDate::parse_from_str(&text, "%Y-%m-%d").ok()),
        payee: row.get(4)?,
        amount: row.get(5)?,
        comments: row.get(6)?,
        place: row.get(7)?,
        status_id: row.get(8)?,
    })
}

/// Le numéro d'un chèque **groupé par trois**, comme les tableaux de F14 et de
/// F02 l'écrivent : « 9 506 001 ».
///
/// L'espace est une espace insécable étroite, celle que WinDev pose entre les
/// groupes : un numéro coupé en fin de ligne se lirait comme deux nombres.
/// Zéro rend une chaîne vide — une opération sans chèque n'affiche rien, pas
/// « 0 ».
pub fn formatted_number(number: i64) -> String {
    if number == 0 {
        return String::new();
    }
    let digits = number.abs().to_string();
    let mut grouped = String::new();
    for (index, digit) in digits.chars().enumerate() {
        if index > 0 && (digits.len() - index).is_multiple_of(3) {
            grouped.push('\u{202F}');
        }
        grouped.push(digit);
    }
    if number < 0 {
        format!("-{grouped}")
    } else {
        grouped
    }
}

/// Les quinze statuts de chèque, dans l'ordre de leur identifiant — celui de la
/// table préremplie, qui est le sien (02_BASE_DE_DONNEES.md §5.7). Jamais
/// retriés : « Non encore utilisé » vient en premier parce que c'est là que
/// tout chèque commence.
pub fn statuses(conn: &Connection) -> Result<Vec<NamedItem>> {
    let mut statement =
        conn.prepare("SELECT IDStatutCheque, Libelle FROM StatutCheque ORDER BY IDStatutCheque")?;
    let items = statement
        .query_map([], |row| {
            Ok(NamedItem {
                id: row.get(0)?,
                label: row.get(1)?,
            })
        })?
        .collect();
    items
}

/// Les chèques d'un carnet, dans l'ordre de leur numéro.
pub fn list_for_chequebook(conn: &Connection, chequebook_id: i64) -> Result<Vec<ChequeRow>> {
    let mut statement = conn.prepare(
        "SELECT q.IDCheque, q.NumChq, q.DateEmission, q.LieuEmission, q.Beneficiaire,
                q.Montant, q.IDStatutCheque, COALESCE(s.Libelle, ''), q.Commentaires,
                (SELECT COUNT(*) FROM Operation o WHERE o.IDCheque = q.IDCheque)
         FROM Cheque q
         LEFT JOIN StatutCheque s ON s.IDStatutCheque = q.IDStatutCheque
         WHERE q.IDChequier = ?1
         ORDER BY q.NumChq",
    )?;
    let rows = statement
        .query_map([chequebook_id], |row| {
            Ok(ChequeRow {
                id: row.get(0)?,
                number: row.get(1)?,
                issued_on: row
                    .get::<_, Option<String>>(2)?
                    .and_then(|text| NaiveDate::parse_from_str(&text, "%Y-%m-%d").ok()),
                place: row.get(3)?,
                payee: row.get(4)?,
                amount: row.get(5)?,
                status_id: row.get(6)?,
                status: row.get(7)?,
                comments: row.get(8)?,
                operations: row.get(9)?,
            })
        })?
        .collect();
    rows
}

/// Lit un chèque, ou `None` s'il n'existe plus.
pub fn get(conn: &Connection, id: i64) -> Result<Option<Cheque>> {
    match conn.query_row(
        &format!("SELECT {COLUMNS} FROM Cheque WHERE IDCheque = ?1"),
        [id],
        read,
    ) {
        Ok(cheque) => Ok(Some(cheque)),
        Err(rusqlite::Error::QueryReturnedNoRows) => Ok(None),
        Err(other) => Err(other),
    }
}

/// Change un chèque. Le numéro et le carnet ne bougent pas : ils sont en
/// lecture seule dans la fiche, parce qu'ils viennent du carnet et que rien ne
/// pourrait les y remettre d'accord.
pub fn update(conn: &Connection, id: i64, cheque: &Cheque) -> Result<bool> {
    let changed = conn.execute(
        "UPDATE Cheque SET DateEmission = ?1, LieuEmission = ?2, Beneficiaire = ?3,
                           Montant = ?4, Commentaires = ?5, IDStatutCheque = ?6
         WHERE IDCheque = ?7",
        rusqlite::params![
            cheque.issued_on.map(|d| d.format("%Y-%m-%d").to_string()),
            cheque.place.trim(),
            cheque.payee.trim(),
            cheque.amount,
            cheque.comments.trim(),
            cheque.status_id,
            id,
        ],
    )?;
    Ok(changed > 0)
}

/// Change le seul statut — ce que fait le clic dans la case du tableau F14.
///
/// Une écriture, pas six : modifier le statut dans la liste ne doit pas
/// réécrire la date et le bénéficiaire avec ce que la ligne affichait, sous
/// peine de perdre ce qu'une autre fenêtre y aurait mis entre-temps.
pub fn set_status(conn: &Connection, id: i64, status_id: i64) -> Result<bool> {
    let changed = conn.execute(
        "UPDATE Cheque SET IDStatutCheque = ?1 WHERE IDCheque = ?2",
        rusqlite::params![status_id, id],
    )?;
    Ok(changed > 0)
}

/// Combien d'opérations portent ce chèque — son `NombreOpChq`, **filles
/// comprises** (fidélité assumée, voir le module).
pub fn operation_count(conn: &Connection, cheque_id: i64) -> Result<i64> {
    conn.query_row(
        "SELECT COUNT(*) FROM Operation WHERE IDCheque = ?1",
        [cheque_id],
        |row| row.get(0),
    )
}

/// « 07328/9506019 » — le carnet et le numéro, joints par une barre. « / »
/// quand le chèque n'existe pas ou vaut zéro.
pub fn reference_of(conn: &Connection, cheque_id: i64) -> Result<String> {
    if cheque_id == 0 {
        return Ok("/".to_string());
    }
    let found = conn.query_row(
        "SELECT COALESCE(b.IDReferenceChq, ''), q.NumChq
         FROM Cheque q
         LEFT JOIN Chequier b ON b.IDChequier = q.IDChequier
         WHERE q.IDCheque = ?1",
        [cheque_id],
        |row| Ok((row.get::<_, String>(0)?, row.get::<_, i64>(1)?)),
    );
    match found {
        Ok((reference, number)) => Ok(format!("{reference}/{number}")),
        Err(rusqlite::Error::QueryReturnedNoRows) => Ok("/".to_string()),
        Err(other) => Err(other),
    }
}

const OPERATION_SELECT: &str = "SELECT o.IDOperation, o.IDCompte, COALESCE(c.Libelle, ''),
            o.Libelle, o.Date, o.DatePointage, o.Montant, o.IDCheque,
            COALESCE(b.IDReferenceChq, ''), COALESCE(q.NumChq, 0)
     FROM Operation o
     LEFT JOIN Compte c ON c.IDCompte = o.IDCompte
     LEFT JOIN Cheque q ON q.IDCheque = o.IDCheque
     LEFT JOIN Chequier b ON b.IDChequier = q.IDChequier
     WHERE o.IDOperationParent = 0";

fn read_operation(row: &rusqlite::Row<'_>) -> rusqlite::Result<LinkableOperation> {
    let date = |index: usize| -> rusqlite::Result<Option<NaiveDate>> {
        Ok(row
            .get::<_, Option<String>>(index)?
            .and_then(|text| NaiveDate::parse_from_str(&text, "%Y-%m-%d").ok()))
    };
    let cheque_id: i64 = row.get(7)?;
    let reference: String = row.get(8)?;
    let number: i64 = row.get(9)?;
    Ok(LinkableOperation {
        id: row.get(0)?,
        account_id: row.get(1)?,
        account_label: row.get(2)?,
        label: row.get(3)?,
        date: date(4)?,
        clearing_date: date(5)?,
        amount: row.get(6)?,
        cheque_id,
        cheque_reference: if cheque_id == 0 {
            "/".to_string()
        } else {
            format!("{reference}/{number}")
        },
    })
}

/// Les opérations **déjà associées** à ce chèque — le `gChequeAsso > 0` de son
/// original, et le titre « Liste des opérations déjà associées à ce chèque ».
///
/// **Les mères seulement** (`IDOperationParent = 0`) : une sous-opération ne
/// porte jamais de chèque. C'est pour cela que ce nombre-ci peut être plus
/// petit que celui de [`operation_count`].
pub fn linked(conn: &Connection, cheque_id: i64) -> Result<Vec<LinkableOperation>> {
    let mut statement = conn.prepare(&format!(
        "{OPERATION_SELECT} AND o.IDCheque = ?1 ORDER BY o.Date, o.IDOperation"
    ))?;
    let rows = statement.query_map([cheque_id], read_operation)?.collect();
    rows
}

/// Les opérations que l'on peut associer — le `gChequeAsso = 0` de son
/// original, et le titre « Choisissez une opération à associer au chèque ».
///
/// Bornées **au compte du carnet** : c'est la seule des quatre branches de son
/// `TableData_SyncFichier` qui pose le gras sur les lignes déjà prises, et
/// c'est ce qui trahit la branche vivante — les trois autres sont du code mort
/// (déduction confirmée par Fabrice le 28/07/2026). Un compte à zéro les montre
/// toutes, comme chez lui.
///
/// **Rien n'est écarté** : une opération qui porte déjà un chèque reste
/// proposée, elle arrive seulement avec son `cheque_id` non nul, et c'est la
/// fenêtre qui la met en gras.
pub fn candidates(conn: &Connection, account_id: i64) -> Result<Vec<LinkableOperation>> {
    if account_id == 0 {
        let mut statement =
            conn.prepare(&format!("{OPERATION_SELECT} ORDER BY o.Date, o.IDOperation"))?;
        let rows = statement.query_map([], read_operation)?.collect();
        return rows;
    }
    let mut statement = conn.prepare(&format!(
        "{OPERATION_SELECT} AND o.IDCompte = ?1 ORDER BY o.Date, o.IDOperation"
    ))?;
    let rows = statement.query_map([account_id], read_operation)?.collect();
    rows
}

/// Accroche une opération à un chèque. **Écrase sans rien dire** le chèque
/// qu'elle portait (fidélité assumée, voir le module).
///
/// Rend `false` si l'opération ou le chèque n'existe plus — ou si l'opération
/// est une fille : une sous-opération ne porte pas de chèque, et laisser passer
/// ici ce que les deux listes refusent d'afficher créerait un lien que personne
/// ne pourrait plus voir ni défaire.
pub fn associate(conn: &Connection, operation_id: i64, cheque_id: i64) -> Result<bool> {
    if get(conn, cheque_id)?.is_none() {
        return Ok(false);
    }
    let changed = conn.execute(
        "UPDATE Operation SET IDCheque = ?1
         WHERE IDOperation = ?2 AND IDOperationParent = 0",
        rusqlite::params![cheque_id, operation_id],
    )?;
    Ok(changed > 0)
}

/// Détache le chèque d'une opération — la croix rouge de « Liste des opérations
/// déjà associées ». **L'opération reste, le chèque reste** : seul le lien s'en
/// va (arbitrage de Fabrice, 28/07/2026).
pub fn dissociate(conn: &Connection, operation_id: i64) -> Result<bool> {
    let changed = conn.execute(
        "UPDATE Operation SET IDCheque = 0 WHERE IDOperation = ?1",
        [operation_id],
    )?;
    Ok(changed > 0)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::chequebooks::{self, Chequebook};
    use crate::database::schema;

    fn database() -> Connection {
        let conn = Connection::open_in_memory().expect("base en mémoire");
        schema::migrate(&conn).expect("schéma");
        crate::database::seed::seed_initial_data(&conn).expect("valeurs initiales");
        conn
    }

    fn an_account(conn: &Connection, label: &str) -> i64 {
        let id = crate::database::keygen::next_id(conn, "Compte", "IDCompte").expect("clef");
        conn.execute(
            "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte) VALUES (?1, ?2, 1)",
            rusqlite::params![id, label],
        )
        .expect("compte");
        id
    }

    fn a_book(conn: &mut Connection, account: i64, reference: &str, first: i64, last: i64) -> i64 {
        chequebooks::create(
            conn,
            &Chequebook {
                id: 0,
                reference: reference.to_string(),
                received_on: NaiveDate::from_ymd_opt(2020, 8, 1),
                first_number: first,
                last_number: last,
                quantity: last - first + 1,
                number_format: 0,
                comments: String::new(),
                account_id: account,
            },
        )
        .expect("carnet")
        .expect("référence libre")
    }

    fn an_operation(conn: &Connection, account: i64, label: &str, parent: i64) -> i64 {
        let id = crate::database::keygen::next_id(conn, "Operation", "IDOperation").expect("clef");
        conn.execute(
            "INSERT INTO Operation (IDOperation, Libelle, Date, DatePointage, Montant,
                                    IDCompte, IDStatutOperation, IDOperationParent)
             VALUES (?1, ?2, '2022-05-13', '2022-05-13', -110000000, ?3, 1, ?4)",
            rusqlite::params![id, label, account, parent],
        )
        .expect("opération");
        id
    }

    fn cheque_numbered(conn: &Connection, book: i64, number: i64) -> i64 {
        conn.query_row(
            "SELECT IDCheque FROM Cheque WHERE IDChequier = ?1 AND NumChq = ?2",
            rusqlite::params![book, number],
            |row| row.get(0),
        )
        .expect("le chèque")
    }

    /// Les quinze statuts sont là, dans l'ordre de la table préremplie, et le
    /// premier est celui où tout chèque commence.
    #[test]
    fn les_quinze_statuts_arrivent_dans_l_ordre_de_l_original() {
        let conn = database();
        let all = statuses(&conn).expect("statuts");
        assert_eq!(all.len(), 15);
        assert_eq!(all[0].id, 1);
        assert_eq!(all[0].label, "Non encore utilisé");
        assert!(all.windows(2).all(|pair| pair[0].id < pair[1].id));
    }

    /// « 9 506 001 » — groupé par trois, comme ses deux tableaux l'écrivent.
    #[test]
    fn un_numero_de_cheque_se_lit_par_groupes_de_trois() {
        assert_eq!(formatted_number(9_506_001), "9\u{202F}506\u{202F}001");
        assert_eq!(formatted_number(1), "1");
        assert_eq!(formatted_number(1_000), "1\u{202F}000");
        assert_eq!(formatted_number(999), "999");
        // Zéro n'est pas un numéro : c'est l'absence de chèque.
        assert_eq!(formatted_number(0), "");
    }

    /// La composition du chéquier : le statut résolu en toutes lettres, et le
    /// compteur d'opérations à côté.
    #[test]
    fn la_composition_du_carnet_montre_le_statut_et_le_compteur() {
        let mut conn = database();
        let account = an_account(&conn, "CCP");
        let book = a_book(&mut conn, account, "07328", 9_506_001, 9_506_003);

        let rows = list_for_chequebook(&conn, book).expect("composition");
        assert_eq!(rows.len(), 3);
        assert_eq!(rows[0].number, 9_506_001);
        assert_eq!(rows[0].status, "Non encore utilisé");
        assert_eq!(rows[0].operations, 0);
        assert!(rows.windows(2).all(|pair| pair[0].number < pair[1].number));
    }

    /// La fiche remplit le chèque ; le numéro et le carnet ne bougent pas.
    #[test]
    fn un_cheque_se_remplit_sans_changer_de_numero_ni_de_carnet() {
        let mut conn = database();
        let account = an_account(&conn, "CCP");
        let book = a_book(&mut conn, account, "07328", 9_506_001, 9_506_002);
        let id = cheque_numbered(&conn, book, 9_506_011 - 10);

        let mut cheque = get(&conn, id).expect("lecture").expect("existe");
        cheque.issued_on = NaiveDate::from_ymd_opt(2020, 12, 2);
        cheque.payee = "  dermato  ".to_string();
        cheque.amount = 25_000_000;
        cheque.status_id = 5;
        assert!(update(&conn, id, &cheque).expect("modification"));

        let stored = get(&conn, id).expect("relecture").expect("existe");
        assert_eq!(stored.payee, "dermato");
        assert_eq!(stored.amount, 25_000_000);
        assert_eq!(stored.status_id, 5);
        assert_eq!(stored.number, 9_506_001, "le numéro vient du carnet");
        assert_eq!(stored.chequebook_id, book);
    }

    /// Le clic dans la case ne touche qu'au statut : ce que la fiche avait mis
    /// dans les cinq autres champs reste.
    #[test]
    fn changer_le_statut_dans_la_case_ne_touche_a_rien_d_autre() {
        let mut conn = database();
        let account = an_account(&conn, "CCP");
        let book = a_book(&mut conn, account, "07328", 1, 1);
        let id = cheque_numbered(&conn, book, 1);

        let mut cheque = get(&conn, id).expect("lecture").expect("existe");
        cheque.payee = "Dr Joran".to_string();
        cheque.amount = 25_000_000;
        update(&conn, id, &cheque).expect("remplissage");

        assert!(set_status(&conn, id, 5).expect("statut"));
        let stored = get(&conn, id).expect("relecture").expect("existe");
        assert_eq!(stored.status_id, 5);
        assert_eq!(stored.payee, "Dr Joran");
        assert_eq!(stored.amount, 25_000_000);
    }

    /// **Le croisement de l'association.** Les deux visages de la même fenêtre :
    /// les candidates montrent tout le compte, les liées ne montrent que ce qui
    /// est accroché — et détacher rend exactement la ligne à la première liste,
    /// sans rien détruire.
    #[test]
    fn associer_puis_detacher_fait_voyager_la_ligne_entre_les_deux_visages() {
        let mut conn = database();
        let account = an_account(&conn, "CCP");
        let book = a_book(&mut conn, account, "07328", 9_506_019, 9_506_020);
        let cheque = cheque_numbered(&conn, book, 9_506_019);
        let operation = an_operation(&conn, account, "CHEQUE N 9506019", 0);
        an_operation(&conn, account, "ACHAT CB BORGO DISTRIB", 0);

        // Avant : deux candidates, aucune liée, et la colonne dit « / ».
        assert_eq!(candidates(&conn, account).expect("candidates").len(), 2);
        assert!(linked(&conn, cheque).expect("liées").is_empty());
        let free = candidates(&conn, account).expect("candidates");
        assert!(free.iter().all(|row| row.cheque_id == 0));
        assert!(free.iter().all(|row| row.cheque_reference == "/"));

        assert!(associate(&conn, operation, cheque).expect("association"));

        let attached = linked(&conn, cheque).expect("liées");
        assert_eq!(attached.len(), 1);
        assert_eq!(attached[0].id, operation);
        assert_eq!(attached[0].account_label, "CCP");
        assert_eq!(attached[0].cheque_reference, "07328/9506019");
        // Toujours candidate, mais elle porte maintenant son chèque — c'est ce
        // qui la met en gras.
        let marked = candidates(&conn, account).expect("candidates");
        assert_eq!(marked.iter().filter(|row| row.cheque_id != 0).count(), 1);
        assert_eq!(operation_count(&conn, cheque).expect("compteur"), 1);

        assert!(dissociate(&conn, operation).expect("détachement"));
        assert!(linked(&conn, cheque).expect("liées").is_empty());
        assert_eq!(candidates(&conn, account).expect("candidates").len(), 2);
        // Rien n'a disparu : ni l'opération, ni le chèque.
        let operations: i64 = conn
            .query_row("SELECT COUNT(*) FROM Operation", [], |row| row.get(0))
            .expect("opérations");
        assert_eq!(operations, 2);
        assert!(get(&conn, cheque).expect("le chèque").is_some());
    }

    /// **La fidélité assumée n°2.** Associer une opération déjà prise écrase :
    /// le premier chèque la perd, sans un mot.
    #[test]
    fn associer_une_operation_deja_prise_ecrase_en_silence() {
        let mut conn = database();
        let account = an_account(&conn, "CCP");
        let book = a_book(&mut conn, account, "07328", 1, 2);
        let first = cheque_numbered(&conn, book, 1);
        let second = cheque_numbered(&conn, book, 2);
        let operation = an_operation(&conn, account, "Plombier", 0);

        associate(&conn, operation, first).expect("première");
        assert_eq!(operation_count(&conn, first).expect("compteur"), 1);

        assert!(associate(&conn, operation, second).expect("seconde"));
        assert_eq!(operation_count(&conn, first).expect("compteur"), 0);
        assert_eq!(operation_count(&conn, second).expect("compteur"), 1);
    }

    /// **La fidélité assumée n°1.** Le compteur de F14 compte les filles, les
    /// deux listes non : les deux nombres divergent, et c'est voulu.
    #[test]
    fn le_compteur_compte_les_filles_que_les_listes_refusent() {
        let mut conn = database();
        let account = an_account(&conn, "CCP");
        let book = a_book(&mut conn, account, "07328", 1, 1);
        let cheque = cheque_numbered(&conn, book, 1);

        let mother = an_operation(&conn, account, "Plombier", 0);
        let daughter = an_operation(&conn, account, "Complément", mother);
        associate(&conn, mother, cheque).expect("la mère");
        // La fille est accrochée en base, à la main : c'est ce que ferait un
        // import ou une version antérieure.
        conn.execute(
            "UPDATE Operation SET IDCheque = ?1 WHERE IDOperation = ?2",
            rusqlite::params![cheque, daughter],
        )
        .expect("la fille");

        assert_eq!(operation_count(&conn, cheque).expect("compteur"), 2);
        assert_eq!(linked(&conn, cheque).expect("liées").len(), 1);
        let rows = list_for_chequebook(&conn, book).expect("composition");
        assert_eq!(rows[0].operations, 2, "F14 en annonce deux");
    }

    /// Une sous-opération ne porte jamais de chèque : ce que les listes
    /// refusent d'afficher, l'association refuse de créer.
    #[test]
    fn une_sous_operation_ne_peut_pas_etre_associee() {
        let mut conn = database();
        let account = an_account(&conn, "CCP");
        let book = a_book(&mut conn, account, "07328", 1, 1);
        let cheque = cheque_numbered(&conn, book, 1);
        let mother = an_operation(&conn, account, "Plombier", 0);
        let daughter = an_operation(&conn, account, "Complément", mother);

        assert!(!associate(&conn, daughter, cheque).expect("refus"));
        assert_eq!(operation_count(&conn, cheque).expect("compteur"), 0);
        // Et un chèque qui n'existe pas ne prend rien non plus.
        assert!(!associate(&conn, mother, 9_999).expect("chèque absent"));
    }

    /// La référence composée, et son cas nul.
    #[test]
    fn la_reference_dit_le_carnet_et_le_numero_ou_bien_rien() {
        let mut conn = database();
        let account = an_account(&conn, "CCP");
        let book = a_book(&mut conn, account, "07328", 9_506_019, 9_506_019);
        let cheque = cheque_numbered(&conn, book, 9_506_019);
        assert_eq!(reference_of(&conn, cheque).expect("référence"), "07328/9506019");
        assert_eq!(reference_of(&conn, 0).expect("aucun"), "/");
        assert_eq!(reference_of(&conn, 9_999).expect("disparu"), "/");
    }
}
