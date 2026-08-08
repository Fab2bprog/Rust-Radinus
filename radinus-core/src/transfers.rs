//! Le transfert d'un montant entre deux comptes — F09
//! (`04_SPECIFICATIONS_FENETRES.md`, capture « Transferer montant entre 2
//! comptes.png »).
//!
//! **Un virement n'est pas une opération, c'en est deux** (règle dictée par
//! Fabrice, 29/07/2026) : un débit sur le compte source, un crédit du même
//! montant sur le compte destination. Le même montant, les deux signes opposés,
//! deux comptes différents.
//!
//! **Et les deux partent ensemble, ou aucune ne part.** C'est tout le sens de
//! [`perform`], qui écrit dans une seule transaction : une seule des deux
//! écritures ferait apparaître de l'argent, ou en ferait disparaître, et **rien
//! dans les soldes ne le signalerait** — ils seraient justes chacun de leur
//! côté. Une incohérence qui ne se voit nulle part est la pire qui soit.
//!
//! **Une seule description pour les deux.** Le libellé, la référence, les deux
//! dates, le statut et les cinq nomenclatures sont saisis une fois et vont sur
//! les deux écritures ; seuls le compte et le signe les distinguent.
//!
//! **Les deux soldes sont recalculés**, pas seulement l'un des deux — sa
//! demande, et elle va de soi une fois qu'on a dit que le virement touche deux
//! comptes.
//!
//! Un effet que personne n'a eu à programmer : dans une statistique
//! multi-comptes, le débit et le crédit du même mois s'annulent, et la matrice
//! peint cette case-là en vert (voir [`crate::statistics`]) — c'est ainsi qu'un
//! virement interne se reconnaît d'un coup d'œil.

use crate::sub_operations::Direction;
use rusqlite::{Connection, Result};
use time_compute::NaiveDate;

/// Ce que la fenêtre de virement demande.
#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct Transfer {
    /// Le compte débité.
    pub source_id: i64,
    /// Le compte crédité.
    pub target_id: i64,
    pub label: String,
    pub payment_reference: String,
    pub date: Option<NaiveDate>,
    pub clearing_date: Option<NaiveDate>,
    pub status_id: i64,
    pub category_id: i64,
    pub payment_mode_id: i64,
    pub assignment_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
    /// En micro-unités, et **strictement positif** : c'est une grandeur, les
    /// deux signes sont donnés par les deux écritures.
    pub amount: i64,
}

/// Pourquoi ce virement ne peut pas être fait, ou `None` s'il le peut. La clef
/// Fluent est rendue plutôt que la phrase : ce module ne parle aucune langue.
///
/// Trois barrières, et les trois sont des règles de Fabrice :
///
/// 1. **Le même compte des deux côtés est interdit** — refusé, et non corrigé
///    en silence. Un virement d'un compte vers lui-même écrirait deux lignes
///    qui s'annulent, et l'utilisateur croirait avoir fait quelque chose.
/// 2. **Le montant est obligatoirement positif.** Zéro compris : un virement de
///    rien n'écrirait que deux lignes vides dans deux comptes.
/// 3. Une date est nécessaire, comme pour toute opération : la liste lit une
///    période, et une opération sans date tombe hors de toutes.
pub fn refusal(conn: &Connection, transfer: &Transfer) -> Result<Option<&'static str>> {
    if transfer.source_id == 0 || transfer.target_id == 0 {
        return Ok(Some("transfer-refusal-accounts-required"));
    }
    if transfer.source_id == transfer.target_id {
        return Ok(Some("transfer-refusal-same-account"));
    }
    for id in [transfer.source_id, transfer.target_id] {
        if crate::accounts::get(conn, id)?.is_none() {
            return Ok(Some("transfer-refusal-account-gone"));
        }
    }
    if transfer.label.trim().is_empty() {
        return Ok(Some("transfer-refusal-label-required"));
    }
    if transfer.date.is_none() {
        return Ok(Some("transfer-refusal-date-required"));
    }
    if transfer.amount <= 0 {
        return Ok(Some("transfer-refusal-amount"));
    }
    Ok(None)
}

fn one_side(transfer: &Transfer, direction: Direction) -> crate::operations::OperationInput {
    crate::operations::OperationInput {
        label: transfer.label.trim().to_string(),
        payment_reference: transfer.payment_reference.trim().to_string(),
        date: transfer.date,
        clearing_date: transfer.clearing_date,
        direction,
        amount: transfer.amount,
        status_id: transfer.status_id,
        category_id: transfer.category_id,
        assignment_id: transfer.assignment_id,
        payment_mode_id: transfer.payment_mode_id,
        payee_id: transfer.payee_id,
        project_id: transfer.project_id,
        comment: None,
    }
}

/// Fait le virement : le débit sur la source, le crédit sur la destination,
/// **dans une seule transaction**, puis les deux soldes recalculés.
///
/// Rend les deux clefs écrites — le débit d'abord, le crédit ensuite.
///
/// Le caller a posé les questions ([`refusal`]) ; celle-ci les repose quand
/// même, parce qu'une fenêtre peut se tromper et qu'une base ne doit pas.
pub fn perform(conn: &mut Connection, transfer: &Transfer) -> Result<Option<(i64, i64)>> {
    if refusal(conn, transfer)?.is_some() {
        return Ok(None);
    }

    let debit = one_side(transfer, Direction::Debit);
    let credit = one_side(transfer, Direction::Credit);
    let (source, target) = (transfer.source_id, transfer.target_id);

    let tx = conn.transaction()?;
    let debit_id = crate::operations::create_within(&tx, source, &debit)?;
    let credit_id = crate::operations::create_within(&tx, target, &credit)?;
    tx.commit()?;

    // Les deux soldes, et non l'un des deux : le virement touche deux comptes.
    // Hors de la transaction, parce que le recalcul lit ce qui vient d'être
    // écrit — et qu'un solde faux se répare, alors qu'un demi-virement non.
    crate::balances::update_all(conn, source)?;
    crate::balances::update_all(conn, target)?;
    Ok(Some((debit_id, credit_id)))
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

    fn an_account(conn: &Connection, label: &str, opening: i64) -> i64 {
        let id = crate::database::keygen::next_id(conn, "Compte", "IDCompte").expect("clef");
        conn.execute(
            "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte, ReportPointe)
             VALUES (?1, ?2, 1, ?3)",
            rusqlite::params![id, label, opening],
        )
        .expect("compte");
        crate::balances::update_all(conn, id).expect("soldes");
        id
    }

    fn a_transfer(source: i64, target: i64, amount: i64) -> Transfer {
        Transfer {
            source_id: source,
            target_id: target,
            label: "Virement interne".to_string(),
            payment_reference: String::new(),
            date: NaiveDate::from_ymd_opt(2026, 7, 24),
            clearing_date: NaiveDate::from_ymd_opt(2026, 7, 24),
            status_id: 1,
            category_id: 0,
            payment_mode_id: 0,
            assignment_id: 0,
            payee_id: 0,
            project_id: 0,
            amount,
        }
    }

    /// **Le croisement du virement.** Ce qui part d'un compte arrive sur
    /// l'autre : la somme des deux soldes ne bouge pas d'un centime, et chacun
    /// a bougé du montant, dans son sens.
    #[test]
    fn ce_qui_part_d_un_compte_arrive_sur_l_autre() {
        let mut conn = database();
        let source = an_account(&conn, "CCP", 1_000_000_000);
        let target = an_account(&conn, "Livret A", 500_000_000);

        let balance = |conn: &Connection, id: i64| -> i64 {
            crate::accounts::get(conn, id)
                .expect("lecture")
                .expect("le compte")
                .balance_final
        };
        let before = (balance(&conn, source), balance(&conn, target));

        let written = perform(&mut conn, &a_transfer(source, target, 250_000_000))
            .expect("virement")
            .expect("accepté");

        let after = (balance(&conn, source), balance(&conn, target));
        assert_eq!(after.0, before.0 - 250_000_000);
        assert_eq!(after.1, before.1 + 250_000_000);
        // Le croisement : rien n'a été créé ni détruit.
        assert_eq!(after.0 + after.1, before.0 + before.1);

        // Deux opérations, et deux seulement, de signes opposés.
        let amounts: Vec<i64> = conn
            .prepare("SELECT Montant FROM Operation ORDER BY IDOperation")
            .expect("requête")
            .query_map([], |row| row.get(0))
            .expect("montants")
            .collect::<Result<_>>()
            .expect("collecte");
        assert_eq!(amounts, vec![-250_000_000, 250_000_000]);
        assert_eq!(written.0 + 1, written.1);

        // Et la description est la même des deux côtés : seuls le compte et le
        // signe les distinguent.
        let labels: Vec<String> = conn
            .prepare("SELECT Libelle FROM Operation")
            .expect("requête")
            .query_map([], |row| row.get(0))
            .expect("libellés")
            .collect::<Result<_>>()
            .expect("collecte");
        assert_eq!(labels, vec!["Virement interne", "Virement interne"]);
    }

    /// Les trois barrières de Fabrice, et **rien n'est écrit quand l'une
    /// arrête** : ni la moitié du virement, ni un solde touché.
    #[test]
    fn un_virement_refuse_n_ecrit_pas_la_moitie_de_lui_meme() {
        let mut conn = database();
        let source = an_account(&conn, "CCP", 1_000_000_000);
        let target = an_account(&conn, "Livret A", 0);

        let count = |conn: &Connection| -> i64 {
            conn.query_row("SELECT COUNT(*) FROM Operation", [], |row| row.get(0))
                .expect("compte")
        };

        // Le même compte des deux côtés.
        let same = a_transfer(source, source, 100_000_000);
        assert_eq!(
            refusal(&conn, &same).expect("examen"),
            Some("transfer-refusal-same-account")
        );
        assert_eq!(perform(&mut conn, &same).expect("refus"), None);

        // Zéro, et le négatif : le montant est une grandeur, strictement
        // positive.
        for amount in [0, -100_000_000] {
            let wrong = a_transfer(source, target, amount);
            assert_eq!(
                refusal(&conn, &wrong).expect("examen"),
                Some("transfer-refusal-amount")
            );
            assert_eq!(perform(&mut conn, &wrong).expect("refus"), None);
        }

        // Sans libellé, sans date, sans compte.
        let mut nameless = a_transfer(source, target, 100_000_000);
        nameless.label = "   ".to_string();
        assert_eq!(
            refusal(&conn, &nameless).expect("examen"),
            Some("transfer-refusal-label-required")
        );
        let mut undated = a_transfer(source, target, 100_000_000);
        undated.date = None;
        assert_eq!(
            refusal(&conn, &undated).expect("examen"),
            Some("transfer-refusal-date-required")
        );
        assert_eq!(
            refusal(&conn, &a_transfer(0, target, 1)).expect("examen"),
            Some("transfer-refusal-accounts-required")
        );
        assert_eq!(
            refusal(&conn, &a_transfer(source, 9_999, 1)).expect("examen"),
            Some("transfer-refusal-account-gone")
        );

        assert_eq!(count(&conn), 0, "aucun refus n'a laissé la moindre écriture");
        assert_eq!(
            crate::accounts::get(&conn, source)
                .expect("lecture")
                .expect("le compte")
                .balance_final,
            1_000_000_000
        );
    }

    /// Un virement accepté passe toutes les barrières, y compris reposées par
    /// le noyau : la fenêtre n'est pas la dernière ligne de défense.
    #[test]
    fn un_virement_correct_est_accepte() {
        let mut conn = database();
        let source = an_account(&conn, "CCP", 1_000_000_000);
        let target = an_account(&conn, "Livret A", 0);
        let transfer = a_transfer(source, target, 1_000_000);
        assert_eq!(refusal(&conn, &transfer).expect("examen"), None);
        assert!(perform(&mut conn, &transfer).expect("virement").is_some());
    }
}
