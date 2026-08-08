//! Bank accounts — `Compte` (02_BASE_DE_DONNEES.md §3.1), the windows F04,
//! F06, F07 and F08 of `04_SPECIFICATIONS_FENETRES.md`.
//!
//! An account carries three **carried-over** balances, `ReportPointe`,
//! `ReportEngage` and `ReportPrevu`: what the account held before the first
//! operation Radinus knows about. The three balances it *shows* are computed
//! from them by [`crate::balances`] and stored in `SoldeBanque`, `SoldeReel`
//! and `SoldeFinal` — they are read here, never recomputed here.
//!
//! The three of them are cumulative, and the author put it in one line
//! (25/07/2026): **en banque** is the pointed one, **réel** is pointed plus
//! committed, **final** is pointed plus committed plus planned. F07 shows
//! them under those names, and the accounts list shows them next to each
//! account.

use crate::domain::{Account, NamedItem};
use crate::text::{french_sort_key, same_name_key};
use rusqlite::{Connection, Result};
use time_compute::NaiveDate;

/// An account as a list shows it: what identifies it, and where it stands.
#[derive(Debug, Clone, PartialEq)]
pub struct AccountRow {
    pub id: i64,
    pub label: String,
    pub bank: String,
    pub account_type: String,
    pub account_number: String,
    /// Pointed — « En Banque ».
    pub balance_bank: i64,
    /// Pointed + committed — « Réel ».
    pub balance_real: i64,
    /// Pointed + committed + planned — « Final ».
    pub balance_final: i64,
    pub is_closed: bool,
}

const COLUMNS: &str = "IDCompte, ReportPointe, ReportEngage, ReportPrevu, Libelle, \
     IDTypeCompte, IDBanques, SoldeBanque, SoldeReel, SoldeFinal, NomTitulaire, \
     AdresseTitulaire, COBCodeBanque, COBCodeGuichet, COBNumCompte, COBClefRIB, \
     COBIBAN, DateOuverture, DateCloture, AdresseAgenceBank, COBBIC, \
     NumProchCheque, CompteCloture, Devise";

fn read_account(row: &rusqlite::Row<'_>) -> rusqlite::Result<Account> {
    let date = |index: usize| -> rusqlite::Result<Option<NaiveDate>> {
        Ok(row
            .get::<_, Option<String>>(index)?
            .and_then(|text| NaiveDate::parse_from_str(&text, "%Y-%m-%d").ok()))
    };
    Ok(Account {
        id: row.get(0)?,
        opening_balance_pointed: row.get(1)?,
        opening_balance_committed: row.get(2)?,
        opening_balance_planned: row.get(3)?,
        label: row.get(4)?,
        account_type_id: row.get(5)?,
        bank_id: row.get(6)?,
        balance_bank: row.get(7)?,
        balance_real: row.get(8)?,
        balance_final: row.get(9)?,
        holder_name: row.get(10)?,
        holder_address: row.get(11)?,
        rib_bank_code: row.get(12)?,
        rib_branch_code: row.get(13)?,
        rib_account_number: row.get(14)?,
        rib_key: row.get(15)?,
        iban: row.get(16)?,
        opening_date: date(17)?,
        closing_date: date(18)?,
        branch_address: row.get(19)?,
        bic: row.get(20)?,
        next_check_number: row.get(21)?,
        is_closed: row.get::<_, i64>(22)? != 0,
        currency: row.get(23)?,
    })
}
/// **La base porte-t-elle au moins un compte bancaire ?**
///
/// Une question, pas une liste : la barre de menus la pose à chaque
/// reconstruction pour savoir ce qu'elle a le droit d'allumer (décision de
/// Fabrice, 04/08/2026 — une base sans compte n'ouvre que la gestion des
/// comptes, « pour que l'utilisateur ne se perde pas à explorer d'autres
/// options »). `list` aurait rendu la même réponse en calculant trois soldes
/// par compte, à chaque changement de langue et à chaque ouverture de base,
/// pour n'en garder que le nombre.
///
/// **Les comptes clôturés comptent.** Une base qui n'a plus qu'un compte fermé
/// n'est pas une base neuve : elle a un passé, des opérations, des
/// statistiques — et son propriétaire n'a pas besoin qu'on le pousse à créer
/// un compte.
pub fn any(conn: &Connection) -> Result<bool> {
    conn.query_row("SELECT EXISTS (SELECT 1 FROM Compte)", [], |row| {
        row.get::<_, i64>(0)
    })
    .map(|found| found == 1)
}


/// Every account, in the order the lists show them: by label, under the
/// French collation measured on the author's archive.
///
/// The bank and the type are resolved here rather than by the windows: a list
/// shows names, and the names live in two other tables.
pub fn list(conn: &Connection) -> Result<Vec<AccountRow>> {
    let mut statement = conn.prepare(
        "SELECT c.IDCompte, c.Libelle, c.COBNumCompte, c.SoldeBanque, c.SoldeReel,
                c.SoldeFinal, c.CompteCloture,
                COALESCE(b.NomBanque, ''), COALESCE(t.Libelle, '')
         FROM Compte c
         LEFT JOIN Banques b ON b.IDBanques = c.IDBanques
         LEFT JOIN TypeCompte t ON t.IDTypeCompte = c.IDTypeCompte",
    )?;
    let mut rows: Vec<AccountRow> = statement
        .query_map([], |row| {
            Ok(AccountRow {
                id: row.get(0)?,
                label: row.get(1)?,
                account_number: row.get(2)?,
                balance_bank: row.get(3)?,
                balance_real: row.get(4)?,
                balance_final: row.get(5)?,
                is_closed: row.get::<_, i64>(6)? != 0,
                bank: row.get(7)?,
                account_type: row.get(8)?,
            })
        })?
        .collect::<Result<_>>()?;
    rows.sort_by_key(|row| french_sort_key(&row.label));
    Ok(rows)
}

/// The account types, for the combo of the fiche. A closed list prefilled by
/// the code (02_BASE_DE_DONNEES.md §3.1, `Init_TypeCompte`), so it is read as
/// it is and never added to by the user.
pub fn account_types(conn: &Connection) -> Result<Vec<NamedItem>> {
    let mut statement = conn.prepare("SELECT IDTypeCompte, Libelle FROM TypeCompte")?;
    let mut items: Vec<NamedItem> = statement
        .query_map([], |row| {
            Ok(NamedItem {
                id: row.get(0)?,
                label: row.get(1)?,
            })
        })?
        .collect::<Result<_>>()?;
    items.sort_by_key(|item| item.id);
    Ok(items)
}

/// Reads one account, or `None` if it no longer exists.
pub fn get(conn: &Connection, id: i64) -> Result<Option<Account>> {
    match conn.query_row(
        &format!("SELECT {COLUMNS} FROM Compte WHERE IDCompte = ?1"),
        [id],
        read_account,
    ) {
        Ok(account) => Ok(Some(account)),
        Err(rusqlite::Error::QueryReturnedNoRows) => Ok(None),
        Err(other) => Err(other),
    }
}

/// The account already going by `label`, if any — its own label, as stored.
/// `except` is the account being modified, which is not a duplicate of itself.
///
/// The rule the author set for the nomenclatures on 25/07/2026 applies here
/// for the same reason: two accounts sharing a name means every window that
/// asks which one to work on is asking a question with two identical answers.
pub fn same_name_as(conn: &Connection, label: &str, except: Option<i64>) -> Result<Option<String>> {
    let wanted = same_name_key(label);
    if wanted.is_empty() {
        return Ok(None);
    }
    Ok(list(conn)?
        .into_iter()
        .find(|row| Some(row.id) != except && same_name_key(&row.label) == wanted)
        .map(|row| row.label))
}

/// How many operations an account carries. Deleting an account would take
/// them with it (`Operation.IDCompte` cascades), so the caller has to know.
pub fn operation_count(conn: &Connection, id: i64) -> Result<i64> {
    conn.query_row(
        "SELECT COUNT(*) FROM Operation WHERE IDCompte = ?1",
        [id],
        |row| row.get(0),
    )
}

fn write_parameters(account: &Account) -> Vec<Box<dyn rusqlite::ToSql>> {
    let date = |value: Option<NaiveDate>| value.map(|d| d.format("%Y-%m-%d").to_string());
    vec![
        Box::new(account.opening_balance_pointed),
        Box::new(account.opening_balance_committed),
        Box::new(account.opening_balance_planned),
        Box::new(account.label.trim().to_string()),
        Box::new(account.account_type_id),
        Box::new(account.bank_id),
        Box::new(account.holder_name.trim().to_string()),
        Box::new(account.holder_address.trim().to_string()),
        Box::new(account.rib_bank_code.trim().to_string()),
        Box::new(account.rib_branch_code.trim().to_string()),
        Box::new(account.rib_account_number.trim().to_string()),
        Box::new(account.rib_key.trim().to_string()),
        Box::new(normalized_iban(&account.iban)),
        Box::new(date(account.opening_date)),
        Box::new(date(account.closing_date)),
        Box::new(account.branch_address.trim().to_string()),
        Box::new(account.bic.trim().to_uppercase()),
        Box::new(account.next_check_number),
        Box::new(i64::from(account.is_closed)),
        Box::new(account.currency.trim().to_string()),
    ]
}

const WRITABLE: &str = "ReportPointe, ReportEngage, ReportPrevu, Libelle, IDTypeCompte, \
     IDBanques, NomTitulaire, AdresseTitulaire, COBCodeBanque, COBCodeGuichet, \
     COBNumCompte, COBClefRIB, COBIBAN, DateOuverture, DateCloture, \
     AdresseAgenceBank, COBBIC, NumProchCheque, CompteCloture, Devise";

/// Adds an account. The key comes from the max+1 generator, exactly as the
/// original's `Genere_Clef`. The three shown balances are left at zero: they
/// are not typed, they are computed — [`crate::balances`] does it right after.
pub fn create(conn: &Connection, account: &Account) -> Result<i64> {
    let id = crate::database::keygen::next_id(conn, "Compte", "IDCompte")?;
    let mut values = vec![Box::new(id) as Box<dyn rusqlite::ToSql>];
    values.extend(write_parameters(account));
    let placeholders = (1..=values.len())
        .map(|n| format!("?{n}"))
        .collect::<Vec<_>>()
        .join(", ");
    conn.execute(
        &format!("INSERT INTO Compte (IDCompte, {WRITABLE}) VALUES ({placeholders})"),
        rusqlite::params_from_iter(values.iter().map(|value| value.as_ref())),
    )?;
    crate::balances::update_all(conn, id)?;
    Ok(id)
}

/// Changes an account. Returns `false` if it no longer exists.
pub fn update(conn: &Connection, id: i64, account: &Account) -> Result<bool> {
    let assignments = WRITABLE
        .split(',')
        .map(str::trim)
        .enumerate()
        .map(|(index, column)| format!("{column} = ?{}", index + 1))
        .collect::<Vec<_>>()
        .join(", ");
    let mut values = write_parameters(account);
    values.push(Box::new(id));
    let changed = conn.execute(
        &format!(
            "UPDATE Compte SET {assignments} WHERE IDCompte = ?{}",
            values.len()
        ),
        rusqlite::params_from_iter(values.iter().map(|value| value.as_ref())),
    )?;
    if changed > 0 {
        // The carried-over balances may have changed, and the three shown
        // ones are built on them.
        crate::balances::update_all(conn, id)?;
    }
    Ok(changed > 0)
}

/// Deletes an account **and everything hanging from it** — its operations
/// cascade (02_BASE_DE_DONNEES.md §3.2). Returns `false` if it no longer
/// exists.
///
/// The caller is the one that warns: [`operation_count`] says how much would
/// go, and no window may call this without having asked.
pub fn delete(conn: &mut Connection, id: i64) -> Result<bool> {
    if get(conn, id)?.is_none() {
        return Ok(false);
    }
    let tx = conn.transaction()?;
    tx.execute("DELETE FROM Operation WHERE IDCompte = ?1", [id])?;
    tx.execute("DELETE FROM Compte WHERE IDCompte = ?1", [id])?;
    tx.commit()?;
    Ok(true)
}

/// Whether an IBAN is valid — ISO 13616, the mod-97 check of ISO 7064.
///
/// An empty IBAN is accepted: the field is not compulsory, and most of the
/// author's own accounts have none. Anything else is checked properly rather
/// than by its length alone: a wrong IBAN copied into a transfer is a payment
/// that leaves and does not arrive.
pub fn iban_is_valid(iban: &str) -> bool {
    let cleaned = normalized_iban(iban);
    if cleaned.is_empty() {
        return true;
    }
    if cleaned.len() < 15 || cleaned.len() > 34 {
        return false;
    }
    if !cleaned.chars().all(|c| c.is_ascii_alphanumeric()) {
        return false;
    }
    if !cleaned[..2].chars().all(|c| c.is_ascii_alphabetic())
        || !cleaned[2..4].chars().all(|c| c.is_ascii_digit())
    {
        return false;
    }

    // The first four characters go to the end, then every letter becomes its
    // position in the alphabet plus nine, and the whole number must be 1
    // modulo 97. It is computed digit by digit: the number is far too long
    // for any integer type.
    let rearranged = format!("{}{}", &cleaned[4..], &cleaned[..4]);
    let mut remainder: u32 = 0;
    for c in rearranged.chars() {
        let value = if c.is_ascii_digit() {
            c as u32 - '0' as u32
        } else {
            c as u32 - 'A' as u32 + 10
        };
        remainder = if value > 9 {
            (remainder * 100 + value) % 97
        } else {
            (remainder * 10 + value) % 97
        };
    }
    remainder == 1
}

/// An IBAN without its spaces, in capitals — the form it is stored in.
pub fn normalized_iban(iban: &str) -> String {
    iban.chars()
        .filter(|c| !c.is_whitespace())
        .collect::<String>()
        .to_uppercase()
}

/// An IBAN as it is read out: groups of four, separated by a space.
pub fn formatted_iban(iban: &str) -> String {
    normalized_iban(iban)
        .chars()
        .enumerate()
        .flat_map(|(index, c)| {
            if index > 0 && index % 4 == 0 {
                vec![' ', c]
            } else {
                vec![c]
            }
        })
        .collect()
}

/// `Somme_OpPointe` — la somme des opérations **pointées** du compte.
///
/// C'est le « Total des opérations » de la ligne bleue de la fiche, et le
/// nombre dont « Définir le solde initial pointé » se sert : le solde en
/// banque vaut ce total plus le report pointé, ce qui est la définition même
/// de `Maj_SoldeBanque`. Mères seulement — une ventilation partage un montant
/// déjà compté.
pub fn pointed_total(conn: &Connection, account_id: i64) -> Result<i64> {
    conn.query_row(
        "SELECT COALESCE(SUM(Montant), 0) FROM Operation
          WHERE IDCompte = ?1 AND IDOperationParent = 0 AND IDStatutOperation = 1",
        [account_id],
        |row| row.get(0),
    )
}

/// Ce que compte « Statistiques compte bancaire » (menu Outils de F08).
///
/// Portage de la procédure du même nom. Trois blocs — pointé, engagé, prévu —
/// et pour chacun le nombre d'opérations, le total des débits et celui des
/// crédits ; plus la date de la plus ancienne et de la plus récente.
///
/// **Mères seulement**, comme partout où l'on compte de l'argent. Et le zéro
/// compte comme un crédit : c'est le `Montant >= 0` de l'original, et non un
/// oubli — une opération à zéro doit tomber d'un côté ou de l'autre.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct AccountStatistics {
    /// Toutes les opérations de premier niveau, quel que soit leur statut.
    pub operations: i64,
    pub pointed: i64,
    pub pointed_debits: i64,
    pub pointed_credits: i64,
    pub committed: i64,
    pub committed_debits: i64,
    pub committed_credits: i64,
    pub planned: i64,
    pub planned_debits: i64,
    pub planned_credits: i64,
    pub first: Option<NaiveDate>,
    pub last: Option<NaiveDate>,
}

impl AccountStatistics {
    /// La différence entre crédits et débits d'un bloc. Les deux sont signés,
    /// donc c'est leur somme.
    pub fn difference(credits: i64, debits: i64) -> i64 {
        credits + debits
    }
}

pub fn statistics(conn: &Connection, account_id: i64) -> Result<AccountStatistics> {
    let mut statement = conn.prepare(
        "SELECT Montant, IDStatutOperation, Date FROM Operation
          WHERE IDCompte = ?1 AND IDOperationParent = 0
          ORDER BY IDOperation",
    )?;
    let rows = statement.query_map([account_id], |row| {
        Ok((
            row.get::<_, i64>(0)?,
            row.get::<_, i64>(1)?,
            row.get::<_, Option<String>>(2)?,
        ))
    })?;

    let mut found = AccountStatistics::default();
    for row in rows {
        let (amount, status, date) = row?;
        found.operations += 1;

        let (count, debits, credits) = match status {
            1 => (
                &mut found.pointed,
                &mut found.pointed_debits,
                &mut found.pointed_credits,
            ),
            2 => (
                &mut found.committed,
                &mut found.committed_debits,
                &mut found.committed_credits,
            ),
            3 => (
                &mut found.planned,
                &mut found.planned_debits,
                &mut found.planned_credits,
            ),
            // Un statut hors des trois n'existe pas dans la table, mais il
            // compte quand même dans le total — c'est ce que fait l'original,
            // dont le compteur général est hors des six tests de statut.
            _ => continue,
        };
        *count += 1;
        if amount < 0 {
            *debits += amount;
        } else {
            *credits += amount;
        }

        // **Une opération sans date ne peut pas être la plus ancienne.**
        // L'original la prendrait quand même, sa première ligne posant les
        // bornes sans condition ; ici on la saute, parce qu'une date qui
        // n'existe pas ne borne rien.
        let Some(day) = date.and_then(|text| NaiveDate::parse_from_str(&text, "%Y-%m-%d").ok())
        else {
            continue;
        };
        found.first = Some(match found.first {
            Some(known) if known <= day => known,
            _ => day,
        });
        found.last = Some(match found.last {
            Some(known) if known >= day => known,
            _ => day,
        });
    }
    Ok(found)
}

/// Supprime **toutes** les opérations d'un compte (menu Outils de F08).
///
/// Portage de la procédure de l'auteur : les opérations partent, les trois
/// soldes sont refaits, et **les trois reports initiaux ne bougent pas** — le
/// compte est vidé de son histoire mais garde son point de départ (arbitrage
/// de Fabrice, 02/08/2026).
///
/// Tout part en une seule transaction : un compte à moitié vidé serait pire
/// qu'un compte plein. Les sous-opérations s'en vont avec les autres — la
/// clause porte sur le compte, pas sur le niveau —, et les commentaires et
/// pièces jointes suivent par les cascades du schéma. Les chèques survivent :
/// seule leur association disparaît, avec l'opération qui la portait.
///
/// Rend le nombre de lignes supprimées, sous-opérations comprises.
pub fn delete_all_operations(conn: &mut Connection, account_id: i64) -> Result<usize> {
    let transaction = conn.transaction()?;
    let gone = transaction.execute("DELETE FROM Operation WHERE IDCompte = ?1", [account_id])?;
    transaction.commit()?;
    crate::balances::update_all(conn, account_id)?;
    Ok(gone)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database::schema;

    fn database() -> Connection {
        let conn = Connection::open_in_memory().expect("base en mémoire");
        schema::migrate(&conn).expect("schéma");
        crate::database::seed::seed_initial_data(&conn).expect("valeurs initiales");
        conn
    }

    fn an_account(label: &str) -> Account {
        Account {
            id: 0,
            label: label.to_string(),
            account_type_id: 1,
            bank_id: 0,
            opening_balance_pointed: 5_972_540_000,
            opening_balance_committed: 0,
            opening_balance_planned: 0,
            balance_bank: 0,
            balance_real: 0,
            balance_final: 0,
            holder_name: "Fabrice".to_string(),
            holder_address: String::new(),
            rib_bank_code: "20041".to_string(),
            rib_branch_code: "01005".to_string(),
            rib_account_number: "0500013M026".to_string(),
            rib_key: "06".to_string(),
            iban: "FR14 2004 1010 0505 0001 3M02 606".to_string(),
            bic: "psstfrppmon".to_string(),
            branch_address: String::new(),
            opening_date: NaiveDate::from_ymd_opt(2015, 3, 1),
            closing_date: None,
            next_check_number: 0,
            is_closed: false,
            currency: "EUR".to_string(),
        }
    }

    #[test]
    fn an_account_is_written_read_back_and_changed() {
        let mut conn = database();
        let id = create(&conn, &an_account("CCP")).expect("ajout");

        let stored = get(&conn, id).expect("lecture").expect("le compte existe");
        assert_eq!(stored.label, "CCP");
        assert_eq!(stored.opening_balance_pointed, 5_972_540_000);
        // Stored without its spaces and in capitals, whatever was typed.
        assert_eq!(stored.iban, "FR1420041010050500013M02606");
        assert_eq!(stored.bic, "PSSTFRPPMON");
        assert_eq!(
            stored.opening_date,
            NaiveDate::from_ymd_opt(2015, 3, 1)
        );

        let mut changed = stored.clone();
        changed.label = "  CCP La Banque Postale  ".to_string();
        changed.is_closed = true;
        assert!(update(&conn, id, &changed).expect("modification"));
        let stored = get(&conn, id).expect("relecture").expect("existe");
        assert_eq!(stored.label, "CCP La Banque Postale");
        assert!(stored.is_closed);

        assert!(delete(&mut conn, id).expect("suppression"));
        assert!(get(&conn, id).expect("après suppression").is_none());
        assert!(!delete(&mut conn, id).expect("deuxième suppression"));
    }

    #[test]
    fn a_list_shows_the_bank_the_type_and_the_three_balances() {
        let conn = database();
        let mut account = an_account("CCP");
        account.account_type_id = 1; // Chèque
        account.bank_id = 1;
        let id = create(&conn, &account).expect("ajout");

        let bank: String = conn
            .query_row("SELECT NomBanque FROM Banques WHERE IDBanques = 1", [], |r| {
                r.get(0)
            })
            .expect("banque 1");

        let rows = list(&conn).expect("liste");
        let row = rows.iter().find(|row| row.id == id).expect("le compte");
        assert_eq!(row.bank, bank);
        assert_eq!(row.account_type, "Chèque");
        assert_eq!(row.account_number, "0500013M026");
        // No operation yet: the three balances are the carried-over ones,
        // and they are cumulative.
        assert_eq!(row.balance_bank, 5_972_540_000);
        assert_eq!(row.balance_real, 5_972_540_000);
        assert_eq!(row.balance_final, 5_972_540_000);
    }

    #[test]
    fn the_list_is_sorted_under_the_french_collation() {
        let conn = database();
        for label in ["LEP", "CCP", "Épargne", "Livret A"] {
            create(&conn, &an_account(label)).expect("ajout");
        }
        let labels: Vec<String> = list(&conn)
            .expect("liste")
            .into_iter()
            .map(|row| row.label)
            .collect();
        assert_eq!(labels, vec!["CCP", "Épargne", "LEP", "Livret A"]);
    }

    #[test]
    fn two_accounts_may_not_share_a_name() {
        let conn = database();
        let id = create(&conn, &an_account("CCP")).expect("ajout");
        assert_eq!(
            same_name_as(&conn, "ccp", None).expect("recherche"),
            Some("CCP".to_string())
        );
        assert_eq!(same_name_as(&conn, "Livret A", None).expect("recherche"), None);
        // Never a duplicate of itself.
        assert_eq!(same_name_as(&conn, "CCP", Some(id)).expect("recherche"), None);
    }

    /// Real IBANs, and the same ones with one character changed.
    #[test]
    fn an_iban_is_checked_and_not_merely_measured() {
        for valid in [
            "",
            "   ",
            "FR14 2004 1010 0505 0001 3M02 606",
            "FR1420041010050500013M02606",
            "fr1420041010050500013m02606",
            "DE89370400440532013000",
            "GB82WEST12345698765432",
            "BE68539007547034",
        ] {
            assert!(iban_is_valid(valid), "« {valid} » devrait être valide");
        }

        for invalid in [
            "FR1520041010050500013M02606", // clé de contrôle changée
            "FR1420041010050500013M02607", // dernier caractère changé
            "DE89370400440532013001",
            "FR14",                        // trop court
            "1414200410100505000",         // ne commence pas par deux lettres
            "FRAB20041010050500013M02606", // clé non numérique
            "FR14 2004 1010 0505 0001 3M02 60#",
        ] {
            assert!(!iban_is_valid(invalid), "« {invalid} » devrait être refusé");
        }
    }

    #[test]
    fn an_iban_is_stored_bare_and_shown_in_groups_of_four() {
        assert_eq!(
            normalized_iban("fr14 2004 1010 0505 0001 3m02 606"),
            "FR1420041010050500013M02606"
        );
        assert_eq!(
            formatted_iban("FR1420041010050500013M02606"),
            "FR14 2004 1010 0505 0001 3M02 606"
        );
        assert_eq!(formatted_iban(""), "");
    }

    #[test]
    fn deleting_an_account_takes_its_operations_with_it_and_says_how_many() {
        let mut conn = database();
        let id = create(&conn, &an_account("CCP")).expect("ajout");
        for n in 1..=3 {
            conn.execute(
                "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte,
                                        IDStatutOperation)
                 VALUES (?1, ?2, '2026-01-01', -1000000, ?3, 1)",
                rusqlite::params![n, format!("Opération {n}"), id],
            )
            .expect("opération");
        }
        assert_eq!(operation_count(&conn, id).expect("compte"), 3);

        assert!(delete(&mut conn, id).expect("suppression"));
        let left: i64 = conn
            .query_row("SELECT COUNT(*) FROM Operation", [], |row| row.get(0))
            .expect("reste");
        assert_eq!(left, 0, "les opérations partent avec leur compte");
    }

    // --- Le menu « Outils » de la fiche compte (F08) ---------------------

    const EURO: i64 = 1_000_000;

    fn an_operation(conn: &Connection, id: i64, account: i64, amount: i64, status: i64,
                    date: Option<&str>, parent: i64) {
        conn.execute(
            "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte,
                                    IDStatutOperation, IDOperationParent)
             VALUES (?1, 'OP', ?2, ?3, ?4, ?5, ?6)",
            rusqlite::params![id, date, amount, account, status, parent],
        )
        .expect("opération");
    }

    fn a_bare_account(conn: &Connection, id: i64) {
        conn.execute(
            "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte, IDBanques, ReportPointe)
             VALUES (?1, 'CCP', 1, 1, ?2)",
            rusqlite::params![id, 100 * EURO],
        )
        .expect("compte");
    }

    /// `Somme_OpPointe` : **les pointées seulement**, et les mères seules.
    /// C'est ce dont « Définir le solde initial pointé » se sert, et le
    /// nombre que porte déjà la ligne bleue de la fiche.
    #[test]
    fn le_total_des_operations_ne_compte_que_les_pointees() {
        let conn = database();
        a_bare_account(&conn, 1);
        an_operation(&conn, 1, 1, -30 * EURO, 1, Some("2026-01-05"), 0);
        an_operation(&conn, 2, 1, -50 * EURO, 2, Some("2026-01-06"), 0); // engagée
        an_operation(&conn, 3, 1, -70 * EURO, 3, Some("2026-01-07"), 0); // prévue
        an_operation(&conn, 4, 1, -10 * EURO, 1, Some("2026-01-05"), 1); // ventilation

        assert_eq!(pointed_total(&conn, 1).expect("total"), -30 * EURO);

        // Et il vaut bien « solde en banque moins report pointé », ce que la
        // ligne bleue de la fiche affiche : les deux ne peuvent pas diverger.
        crate::balances::update_all(&conn, 1).expect("soldes");
        let account = get(&conn, 1).expect("lecture").expect("le compte");
        assert_eq!(
            account.balance_bank - account.opening_balance_pointed,
            pointed_total(&conn, 1).expect("total")
        );
    }

    #[test]
    fn les_statistiques_comptent_par_statut_et_par_sens() {
        let conn = database();
        a_bare_account(&conn, 1);
        an_operation(&conn, 1, 1, -30 * EURO, 1, Some("2026-03-05"), 0);
        an_operation(&conn, 2, 1, 200 * EURO, 1, Some("2026-01-20"), 0);
        an_operation(&conn, 3, 1, -50 * EURO, 2, Some("2026-05-01"), 0);
        an_operation(&conn, 4, 1, -70 * EURO, 3, Some("2026-02-02"), 0);
        an_operation(&conn, 5, 1, 15 * EURO, 3, Some("2026-07-09"), 0);
        // Une ventilation : elle ne compte nulle part.
        an_operation(&conn, 6, 1, -10 * EURO, 1, Some("2026-03-05"), 1);

        let found = statistics(&conn, 1).expect("statistiques");
        assert_eq!(found.operations, 5, "les mères seules");
        assert_eq!((found.pointed, found.pointed_debits, found.pointed_credits),
                   (2, -30 * EURO, 200 * EURO));
        assert_eq!((found.committed, found.committed_debits, found.committed_credits),
                   (1, -50 * EURO, 0));
        assert_eq!((found.planned, found.planned_debits, found.planned_credits),
                   (2, -70 * EURO, 15 * EURO));
        assert_eq!(found.first, NaiveDate::from_ymd_opt(2026, 1, 20));
        assert_eq!(found.last, NaiveDate::from_ymd_opt(2026, 7, 9));
    }

    /// Le zéro tombe du côté des crédits — c'est le `Montant >= 0` de
    /// l'original, et une opération à zéro doit tomber d'un côté.
    #[test]
    fn une_operation_a_zero_compte_comme_un_credit() {
        let conn = database();
        a_bare_account(&conn, 1);
        an_operation(&conn, 1, 1, 0, 1, Some("2026-01-05"), 0);
        let found = statistics(&conn, 1).expect("statistiques");
        assert_eq!((found.pointed, found.pointed_credits, found.pointed_debits), (1, 0, 0));
        assert_eq!(found.operations, 1);
    }

    /// Une opération sans date ne borne rien, mais elle compte quand même.
    #[test]
    fn une_operation_sans_date_compte_sans_borner_la_periode() {
        let conn = database();
        a_bare_account(&conn, 1);
        an_operation(&conn, 1, 1, -30 * EURO, 1, None, 0);
        an_operation(&conn, 2, 1, -20 * EURO, 1, Some("2026-04-04"), 0);
        let found = statistics(&conn, 1).expect("statistiques");
        assert_eq!(found.operations, 2);
        assert_eq!(found.first, NaiveDate::from_ymd_opt(2026, 4, 4));
        assert_eq!(found.last, NaiveDate::from_ymd_opt(2026, 4, 4));
    }

    #[test]
    fn un_compte_sans_operation_ne_dit_rien() {
        let conn = database();
        a_bare_account(&conn, 1);
        let found = statistics(&conn, 1).expect("statistiques");
        assert_eq!(found.operations, 0);
        assert_eq!(found.first, None);
        assert_eq!(found.last, None);
    }

    /// La suppression emporte tout du compte visé, ventilations comprises,
    /// **laisse les reports initiaux** et ne touche pas aux autres comptes.
    #[test]
    fn supprimer_les_transactions_vide_le_compte_et_garde_ses_reports() {
        let mut conn = database();
        a_bare_account(&conn, 1);
        a_bare_account(&conn, 2);
        an_operation(&conn, 1, 1, -30 * EURO, 1, Some("2026-01-05"), 0);
        an_operation(&conn, 2, 1, -10 * EURO, 1, Some("2026-01-05"), 1);
        an_operation(&conn, 3, 2, -99 * EURO, 1, Some("2026-01-05"), 0);
        crate::balances::update_all_accounts(&conn).expect("soldes");

        let gone = delete_all_operations(&mut conn, 1).expect("suppression");
        assert_eq!(gone, 2, "la mère et sa fille");

        let account = get(&conn, 1).expect("lecture").expect("le compte");
        assert_eq!(account.opening_balance_pointed, 100 * EURO, "le report reste");
        assert_eq!(account.balance_bank, 100 * EURO, "et le solde vaut le report seul");
        assert_eq!(operation_count(&conn, 1).expect("compte"), 0);
        assert_eq!(operation_count(&conn, 2).expect("compte"), 1, "l'autre compte est intact");
    }

    /// Vider un compte déjà vide ne fait rien et ne se plaint pas.
    #[test]
    fn supprimer_les_transactions_dun_compte_vide_ne_fait_rien() {
        let mut conn = database();
        a_bare_account(&conn, 1);
        assert_eq!(delete_all_operations(&mut conn, 1).expect("suppression"), 0);
    }

}
