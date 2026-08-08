//! L'importation d'un relevé bancaire — F17 et F18 (phase 8).
//!
//! Référence : `04_SPECIFICATIONS_FENETRES.md` F17/F18, les captures
//! « Importation releves de comptes bancaires.png » et « importation operation
//! unique depuis releve bancaire vers compte.png », et la marche à suivre que
//! Fabrice a dictée le 27/07/2026 :
//!
//!   1. l'utilisateur choisit **un** compte bancaire, un seul ;
//!   2. la fenêtre d'importation s'ouvre, vide ;
//!   3. il ouvre un fichier OFX : celui-ci est **chargé en RAM, pas en base** ;
//!   4. les lignes que Radinus connaît déjà s'affichent **en pastel**, et ce
//!      qui permet de les reconnaître est leur **FITID déjà présent en base** ;
//!   5. le troisième icône fait deux choses selon la sélection : plusieurs
//!      lignes, il les intègre **en masse** après un avertissement ; une seule,
//!      il ouvre la fiche de rapprochement où l'on classe l'opération avant de
//!      la faire entrer.
//!
//! Ce module ne lit aucun fichier : il reçoit ce que [`crate::ofx_import`] a
//! lu, et s'occupe de la seule question que la lecture ne pose pas — **cette
//! ligne est-elle déjà chez nous, et que devient-elle quand on la fait
//! entrer ?**
//!
//! # Le brouillon, encore
//!
//! Comme la classification rapide, l'importation travaille en mémoire et
//! n'écrit qu'à la demande. Ouvrir un fichier ne touche rien ; intégrer une
//! ligne écrit cette ligne-là et refait les trois soldes du compte. Ce qui n'a
//! pas été intégré n'a jamais existé.

use crate::domain::NaiveDate;
use crate::ofx_import;
use rusqlite::{Connection, Result};
use std::collections::HashSet;

/// Une ligne du relevé, telle que la fenêtre la montre.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Line {
    /// La colonne ID : le rang dans le fichier, en partant de 1.
    pub rank: usize,
    pub date: Option<NaiveDate>,
    pub label: String,
    /// Signé, en micro-unités. La fenêtre le range en Débit ou en Crédit selon
    /// son signe, comme la liste des opérations.
    pub amount: i64,
    /// `TRNTYPE` — gardé tel quel, sans être interprété.
    pub kind: String,
    pub fitid: String,
    /// **La colonne FITID** — `Existe_OpFitID` : ce FITID est **déjà en base**
    /// sur ce compte. C'est un doublon avéré, avec « la certitude absolue
    /// qu'en principe ça soit la même si la banque a bien fait son boulot »
    /// (commentaire de Fabrice).
    ///
    /// **Ce n'est pas un refus.** L'original demande, et laisse forcer — voir
    /// [`integrate`]. Un FITID vide rend ceci toujours faux : sans identifiant,
    /// on ne peut rien affirmer.
    pub fitid_known: bool,
    /// **Le pastel et l'italique** — `Existe_TransacMemeType` : une opération
    /// de ce compte porte **la même date, le même libellé et le même montant**.
    /// « Permet d'avertir l'utilisateur de la possibilité d'un doublon »
    /// (commentaire de Fabrice).
    ///
    /// C'est un soupçon, pas une certitude, et il joue pour **tous les
    /// formats** — c'est le seul filet dont dispose un CSV, qui n'a aucun
    /// identifiant.
    pub looks_like_duplicate: bool,
    /// **La colonne Rapproché** : intégrée pendant cette séance-ci. Au
    /// chargement, aucune ne l'est. C'est le **seul** état qui interdise
    /// vraiment une intégration.
    pub reconciled: bool,
}

impl Line {
    /// Reste-t-il quelque chose à faire de cette ligne ?
    ///
    /// **Seule une ligne déjà rapprochée dans la séance est hors jeu.** Un
    /// doublon soupçonné, et même un FITID déjà en base, restent intégrables :
    /// l'original pose la question et laisse l'utilisateur trancher.
    pub fn is_pending(&self) -> bool {
        !self.reconciled
    }
}

/// Un relevé chargé, en mémoire, pour **un** compte de Radinus.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Import {
    /// Le compte de Radinus dans lequel on importe.
    pub account_id: i64,
    /// Le numéro de compte tel que le **fichier** l'écrit. Ce n'est pas
    /// forcément celui de la fiche compte : les banques n'écrivent pas toutes
    /// leurs numéros de la même façon, et Radinus n'en fait pas une condition.
    pub account_number: String,
    pub from: Option<NaiveDate>,
    pub to: Option<NaiveDate>,
    /// `LEDGERBAL` : ce que la banque dit que vaut le compte. C'est lui qui
    /// s'affiche dans la case « Fichier ».
    pub file_balance: Option<i64>,
    pub file_balance_date: Option<NaiveDate>,
    /// `AVAILBAL` : le solde disponible. L'original s'en sert pour recalculer
    /// l'écart **après** une intégration — voir [`reconciliation`].
    pub available_balance: Option<i64>,
    pub lines: Vec<Line>,
}

impl Import {
    /// La ligne de ce rang, si elle existe.
    pub fn line(&self, rank: usize) -> Option<&Line> {
        self.lines.iter().find(|line| line.rank == rank)
    }

    /// Combien de lignes restent à intégrer.
    pub fn pending(&self) -> usize {
        self.lines.iter().filter(|line| line.is_pending()).count()
    }

    /// Combien de lignes portent un FITID que la base connaît déjà.
    pub fn fitid_known(&self) -> usize {
        self.lines.iter().filter(|line| line.fitid_known).count()
    }

    /// Combien de lignes ressemblent à une opération déjà présente.
    pub fn looking_like_duplicates(&self) -> usize {
        self.lines
            .iter()
            .filter(|line| line.looks_like_duplicate)
            .count()
    }
}

/// Les trois montants du pied de F17 : ce que Radinus dit, ce que le fichier
/// dit, et leur écart.
///
/// « Compte » est le **solde banque** — les reports pointés plus toutes les
/// opérations pointées du compte (`balances::update_bank_balance`), c'est-à-dire
/// la définition même de ce qu'une banque appelle le solde comptable. C'est
/// donc bien à `LEDGERBAL` qu'il se compare, et à rien d'autre.
///
/// **L'écart est l'information, pas le solde.** Un écart nul dit que Radinus et
/// la banque sont d'accord ; un écart non nul dit qu'il reste quelque chose à
/// intégrer, ou qu'une opération a été saisie deux fois.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct Reconciliation {
    pub account: i64,
    pub file: i64,
    pub difference: i64,
}

/// Les trois montants, à l'instant où on les demande.
///
/// **`after_integration` change le solde auquel on se compare**, et c'est une
/// bizarrerie de l'original reproduite volontairement (consigne de Fabrice,
/// 28/07/2026 : « reste fidèle au code original »). Au chargement, son
/// `Charge_FichierOfx` calcule `SAI_SoldeEcart = solde − LEDGERBAL` ; après une
/// sélection ou une intégration, son `Action_SelectLigne` recalcule
/// `solde − AVAILBAL`. Les deux soldes sont souvent égaux, et le jour où ils
/// diffèrent l'écart change tout seul. Le montant affiché en « Fichier » reste
/// `LEDGERBAL` dans les deux cas, comme chez lui.
pub fn reconciliation(
    conn: &Connection,
    import: &Import,
    after_integration: bool,
) -> Result<Reconciliation> {
    let account: i64 = conn.query_row(
        "SELECT SoldeBanque FROM Compte WHERE IDCompte = ?1",
        [import.account_id],
        |row| row.get(0),
    )?;
    let file = import.file_balance.unwrap_or(0);
    let compared = if after_integration {
        import.available_balance.or(import.file_balance).unwrap_or(0)
    } else {
        file
    };
    Ok(Reconciliation {
        account,
        file,
        difference: account - compared,
    })
}

/// Prépare un relevé lu pour la fenêtre : la seule chose que la lecture ne
/// savait pas, c'est ce que la base connaît déjà.
///
/// **Deux détecteurs, et ils ne disent pas la même chose** (code de Fabrice) :
///
///   * `Existe_OpFitID` — ce FITID est déjà en base sur ce compte. C'est la
///     colonne FITID, et c'est une **certitude**, « si la banque a bien fait
///     son boulot ». Un FITID vide rend le test toujours faux : sans
///     identifiant, on ne peut rien affirmer.
///   * `Existe_TransacMemeType` — une opération du compte porte la même date,
///     le même libellé et le même montant. C'est le **pastel et l'italique**,
///     et ce n'est qu'un soupçon — mais c'est le seul filet d'un CSV, qui n'a
///     aucun identifiant.
///
/// Ni l'un ni l'autre n'interdit quoi que ce soit : l'original avertit, et
/// laisse l'utilisateur trancher.
pub fn prepare(
    conn: &Connection,
    account_id: i64,
    statement: &ofx_import::Statement,
) -> Result<Import> {
    let known: HashSet<String> = conn
        .prepare("SELECT FitID FROM Operation WHERE IDCompte = ?1 AND FitID <> ''")?
        .query_map([account_id], |row| row.get::<_, String>(0))?
        .collect::<Result<_>>()?;

    // `Existe_TransacMemeType`, mais lu une fois pour tout le relevé plutôt
    // qu'une requête par ligne : sur les 151 opérations du relevé réel, cela
    // ferait 151 parcours de la table des opérations.
    let mut alike: HashSet<(String, String, i64)> = HashSet::new();
    let mut statement_rows = conn.prepare(
        "SELECT Date, Libelle, Montant FROM Operation WHERE IDCompte = ?1 AND Date IS NOT NULL",
    )?;
    for row in statement_rows.query_map([account_id], |row| {
        Ok((
            row.get::<_, String>(0)?,
            row.get::<_, String>(1)?,
            row.get::<_, i64>(2)?,
        ))
    })? {
        alike.insert(row?);
    }

    let lines = statement
        .transactions
        .iter()
        .map(|transaction| {
            let has_fitid = !transaction.fitid.trim().is_empty();
            let day = transaction
                .date
                .map(|date| date.format("%Y-%m-%d").to_string())
                .unwrap_or_default();
            Line {
                rank: transaction.rank,
                date: transaction.date,
                label: transaction.label.clone(),
                amount: transaction.amount,
                kind: transaction.kind.clone(),
                fitid: transaction.fitid.clone(),
                fitid_known: has_fitid && known.contains(&transaction.fitid),
                looks_like_duplicate: alike.contains(&(
                    day,
                    transaction.label.clone(),
                    transaction.amount,
                )),
                reconciled: false,
            }
        })
        .collect();

    Ok(Import {
        account_id,
        account_number: statement.account_number.clone(),
        from: statement.from,
        to: statement.to,
        file_balance: statement.ledger_balance,
        file_balance_date: statement.ledger_balance_date,
        available_balance: statement.available_balance,
        lines,
    })
}

/// Le classement qu'une ligne emporte en entrant dans le compte — ce que la
/// fiche de rapprochement (F18) renvoie.
///
/// Les cinq nomenclatures partent à « Non précisé » ([`Classification::plain`])
/// et le statut à **pointée** : une ligne de relevé bancaire est, par
/// définition, une opération que la banque a passée. La date de pointage est
/// celle de l'opération, comme pour le pointage rapide de F02 (règle de
/// Fabrice, 26/07/2026).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Classification {
    pub payment_mode_id: i64,
    pub category_id: i64,
    pub assignment_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
    pub status_id: i64,
}

impl Classification {
    /// Le classement par défaut : rien de précisé, et pointée.
    ///
    /// **Rien n'est deviné à partir du `TRNTYPE`.** On pourrait être tenté de
    /// traduire `ATM` en « Retrait espèces » ou `CHECK` en « Chèque » ; ce
    /// serait une déduction de plus, mais elle porterait sur un classement que
    /// l'utilisateur relit dans ses statistiques, et une déduction fausse y est
    /// invisible. Elle attend l'accord de Fabrice.
    pub fn plain() -> Self {
        Self {
            payment_mode_id: crate::nomenclatures::UNSPECIFIED,
            category_id: crate::nomenclatures::UNSPECIFIED,
            assignment_id: crate::nomenclatures::UNSPECIFIED,
            payee_id: crate::nomenclatures::UNSPECIFIED,
            project_id: crate::nomenclatures::UNSPECIFIED,
            status_id: POINTED,
        }
    }
}

/// `IDStatutOperation` d'une opération pointée (02_BASE_DE_DONNEES.md §5.2).
const POINTED: i64 = 1;

/// Ce qu'une demande d'intégration donne — et pourquoi elle s'arrête, le cas
/// échéant.
///
/// C'est la mécanique de `Integration_Ligne` : la seule chose qui interdise est
/// d'avoir **déjà rapproché cette ligne dans la séance** ; un FITID déjà en
/// base fait **poser une question**, jamais un refus.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Outcome {
    /// Elle est entrée. La clef de l'opération créée.
    Added(i64),
    /// Elle avait déjà été rapprochée pendant cette séance : « Vous avez déjà
    /// rapproché cette transaction ».
    AlreadyReconciled,
    /// Son FITID est déjà en base : l'original demande « Souhaitez-vous
    /// vraiment procéder au rapprochement ? » et n'écrit que sur un oui.
    /// Rappeler [`integrate`] avec `force` fait entrer la ligne.
    NeedsConfirmation,
    /// Ce rang n'existe pas dans ce relevé.
    Unknown,
}

/// Fait entrer une ligne du relevé dans le compte, et **rend son FITID à la
/// base** : c'est lui qui permettra de la reconnaître plus tard.
///
/// **La ligne entre telle qu'elle est dans la structure**, y compris si la
/// fiche de rapprochement l'a modifiée : chez Fabrice, la fiche reçoit la
/// transaction et la **rend modifiée**, et c'est cette version-là qui est
/// écrite (`gtabTabTransacFich[…] = stTransRap`). Voir [`amend`].
///
/// `force` est la réponse « Oui » à la question du doublon. Sans lui, une ligne
/// dont le FITID est connu ne s'écrit pas : elle rend
/// [`Outcome::NeedsConfirmation`].
///
/// Le classement est celui de l'original : **rien n'est deviné du `TRNTYPE`** —
/// `IDModeOperation = 0` comme les quatre autres, statut pointé, date de
/// pointage égale à la date. Les trois soldes du compte sont refaits ensuite.
pub fn integrate(
    conn: &Connection,
    import: &mut Import,
    rank: usize,
    classification: &Classification,
    clearing_date: Option<NaiveDate>,
    force: bool,
) -> Result<Outcome> {
    let account_id = import.account_id;
    let Some(index) = import.lines.iter().position(|line| line.rank == rank) else {
        return Ok(Outcome::Unknown);
    };
    if import.lines[index].reconciled {
        return Ok(Outcome::AlreadyReconciled);
    }
    // La base a le dernier mot sur ce qu'elle connaît — le FITID peut être
    // arrivé entre-temps, par une autre importation — mais elle ne refuse pas :
    // elle fait poser la question.
    let known = is_known(conn, account_id, &import.lines[index].fitid)?;
    import.lines[index].fitid_known = known;
    if known && !force {
        return Ok(Outcome::NeedsConfirmation);
    }

    let line = &import.lines[index];
    let id = crate::database::keygen::next_id(conn, "Operation", "IDOperation")?;
    let iso = |date: Option<NaiveDate>| date.map(|d| d.format("%Y-%m-%d").to_string());
    conn.execute(
        "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDModeOperation,
            IDCategorie, IDAffectation, IDCompte, DatePointage, FitID, ReferencePaiement,
            NumRelevBanque, IDStatutOperation, IDOperationParent, SoldePointe, EstParent,
            GUIDCalOpPeriode, IDCheque, IDTiers, IDProjets, EstComplement)
         VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, '', '', ?11, 0, 0, 0, '', 0,
                 ?12, ?13, 0)",
        rusqlite::params![
            id,
            line.label,
            iso(line.date),
            line.amount,
            classification.payment_mode_id,
            classification.category_id,
            classification.assignment_id,
            account_id,
            iso(clearing_date.or(line.date)),
            line.fitid,
            classification.status_id,
            classification.payee_id,
            classification.project_id,
        ],
    )?;

    import.lines[index].reconciled = true;
    crate::balances::update_all(conn, account_id)?;
    Ok(Outcome::Added(id))
}

/// Remplace ce que la fiche de rapprochement a pu changer — la date, le
/// libellé, le montant.
///
/// **La fiche modifie la ligne, chez Fabrice.** Elle reçoit la transaction et
/// la rend, et la liste se rafraîchit avec ce qui revient : date, libellé,
/// débit et crédit. J'avais mis ces champs en lecture seule, en me disant que
/// c'étaient les mots de la banque — c'était mon invention, pas sa règle.
pub fn amend(
    import: &mut Import,
    rank: usize,
    date: Option<NaiveDate>,
    label: &str,
    amount: i64,
) -> bool {
    let Some(line) = import.lines.iter_mut().find(|line| line.rank == rank) else {
        return false;
    };
    line.date = date;
    line.label = label.to_string();
    line.amount = amount;
    true
}

/// Ce FITID est-il déjà en base sur ce compte ?
pub fn is_known(conn: &Connection, account_id: i64, fitid: &str) -> Result<bool> {
    if fitid.trim().is_empty() {
        return Ok(false);
    }
    let count: i64 = conn.query_row(
        "SELECT COUNT(*) FROM Operation WHERE IDCompte = ?1 AND FitID = ?2",
        rusqlite::params![account_id, fitid],
        |row| row.get(0),
    )?;
    Ok(count > 0)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database::{schema, seed};

    const SAMPLE: &str = "OFXHEADER:100\r\nDATA:OFXSGML\r\n\
<OFX><BANKMSGSRSV1><STMTTRNRS><STMTRS><CURDEF>EUR<BANKACCTFROM><ACCTID>123456A789\
</BANKACCTFROM><BANKTRANLIST><DTSTART>20260427<DTEND>20260724\
<STMTTRN><TRNTYPE>ATM<DTPOSTED>20260723<TRNAMT>-50.00<FITID>P_A\
<NAME>RETRAIT DAB/TPE INTERNE</STMTTRN>\
<STMTTRN><TRNTYPE>POS<DTPOSTED>20260722<TRNAMT>-120.00<FITID>P_B\
<NAME>ACHAT CB COMMERCE TROIS</STMTTRN>\
<STMTTRN><TRNTYPE>CREDIT<DTPOSTED>20260721<TRNAMT>2000.00<FITID>P_C\
<NAME>VIREMENT SALAIRE</STMTTRN>\
</BANKTRANLIST><LEDGERBAL><BALAMT>1830.00<DTASOF>20260724</LEDGERBAL>\
<AVAILBAL><BALAMT>1500.00<DTASOF>20260724</AVAILBAL>\
</STMTRS></STMTTRNRS></BANKMSGSRSV1></OFX>";

    fn database() -> Connection {
        let conn = Connection::open_in_memory().unwrap();
        schema::migrate(&conn).unwrap();
        seed::seed_initial_data(&conn).unwrap();
        conn.execute(
            "INSERT INTO Compte (IDCompte, ReportPointe, ReportEngage, ReportPrevu, Libelle,
                IDTypeCompte, IDBanques, SoldeBanque, SoldeReel, SoldeFinal, NomTitulaire,
                AdresseTitulaire, COBCodeBanque, COBCodeGuichet, COBNumCompte, COBClefRIB,
                COBIBAN, DateOuverture, DateCloture, AdresseAgenceBank, COBBIC,
                NumProchCheque, CompteCloture, Devise)
             VALUES (1, 0, 0, 0, 'CCP', 1, 21, 0, 0, 0, '', '', '', '', '', '', '',
                     NULL, NULL, '', '', 0, 0, 'EUR')",
            [],
        )
        .unwrap();
        conn
    }

    fn loaded(conn: &Connection) -> Import {
        let statement = ofx_import::read(SAMPLE, "123456A789").unwrap();
        prepare(conn, 1, &statement).unwrap()
    }

    /// Combien d'opérations le compte porte, lues par une seconde requête qui
    /// ne passe pas par le module.
    fn in_base(conn: &Connection) -> i64 {
        conn.query_row(
            "SELECT COUNT(*) FROM Operation WHERE IDCompte = 1",
            [],
            |row| row.get(0),
        )
        .unwrap()
    }

    /// Intègre sans discuter — ce que fait la fenêtre quand l'utilisateur a
    /// répondu oui, ou quand il n'y avait rien à demander.
    fn add(conn: &Connection, import: &mut Import, rank: usize) -> Outcome {
        integrate(conn, import, rank, &Classification::plain(), None, true).unwrap()
    }

    /// **Ouvrir un fichier n'écrit rien.** C'est la promesse de l'étape 3 : le
    /// relevé est en RAM, et la base n'en sait rien.
    #[test]
    fn charger_un_releve_ne_touche_pas_la_base() {
        let conn = database();
        let import = loaded(&conn);
        assert_eq!(import.lines.len(), 3);
        assert_eq!(import.pending(), 3);
        assert_eq!(in_base(&conn), 0);
    }

    /// **Les deux détecteurs de doublon disent deux choses différentes.**
    ///
    /// `Existe_OpFitID` est une certitude : ce FITID est en base. `Existe_
    /// TransacMemeType` n'est qu'un soupçon : même date, même libellé, même
    /// montant. Une opération saisie à la main a le second sans le premier —
    /// c'est le cas qui distingue vraiment les deux, et c'est celui qu'un CSV
    /// rencontrera toujours.
    #[test]
    fn le_fitid_est_une_certitude_la_ressemblance_un_soupcon() {
        let conn = database();
        // Une opération saisie à la main, sans identifiant, mais identique à
        // la première ligne du relevé.
        conn.execute(
            "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDModeOperation,
                IDCategorie, IDAffectation, IDCompte, DatePointage, FitID, ReferencePaiement,
                NumRelevBanque, IDStatutOperation, IDOperationParent, SoldePointe, EstParent,
                GUIDCalOpPeriode, IDCheque, IDTiers, IDProjets, EstComplement)
             VALUES (99, 'RETRAIT DAB/TPE INTERNE', '2026-07-23', -50000000, 0, 0, 0, 1,
                     '2026-07-23', '', '', '', 1, 0, 0, 0, '', 0, 0, 0, 0)",
            [],
        )
        .unwrap();

        let import = loaded(&conn);
        let first = import.line(1).unwrap();
        assert!(
            !first.fitid_known,
            "aucun FITID en base : la certitude ne peut pas jouer"
        );
        assert!(
            first.looks_like_duplicate,
            "même date, même libellé, même montant : le soupçon doit jouer"
        );
        // Et les deux autres lignes ne ressemblent à rien de connu.
        assert!(!import.line(2).unwrap().looks_like_duplicate);
        assert_eq!(import.looking_like_duplicates(), 1);
        assert_eq!(import.fitid_known(), 0);
    }

    /// **Le FITID, lui, se voit après une intégration.** C'est la colonne
    /// FITID de l'original : `Existe_OpFitID`, et non « le fichier en a
    /// fourni un ».
    #[test]
    fn la_colonne_fitid_dit_ce_que_la_base_connait() {
        let conn = database();
        let mut import = loaded(&conn);
        add(&conn, &mut import, 2);

        let again = loaded(&conn);
        assert!(!again.line(1).unwrap().fitid_known);
        assert!(again.line(2).unwrap().fitid_known);
        assert!(!again.line(3).unwrap().fitid_known);
        assert_eq!(again.fitid_known(), 1);
        // Et elle est aussi devenue un doublon soupçonné : même date, même
        // libellé, même montant. Les deux détecteurs se rejoignent.
        assert!(again.line(2).unwrap().looks_like_duplicate);
    }

    /// **Un doublon n'est pas refusé : il fait poser une question.**
    ///
    /// C'est `Integration_Ligne` : « Souhaitez-vous vraiment procéder au
    /// rapprochement ? ». Sans réponse, rien n'est écrit ; avec un oui, la
    /// ligne entre — même si elle fait doublon, parce que c'est l'utilisateur
    /// qui sait.
    #[test]
    fn un_doublon_fait_poser_une_question_et_peut_etre_force() {
        let conn = database();
        let mut import = loaded(&conn);
        add(&conn, &mut import, 1);
        assert_eq!(in_base(&conn), 1);

        // Le même relevé rechargé : la ligne 1 est un doublon avéré.
        let mut again = loaded(&conn);
        assert!(matches!(
            integrate(&conn, &mut again, 1, &Classification::plain(), None, false).unwrap(),
            Outcome::NeedsConfirmation
        ));
        assert_eq!(in_base(&conn), 1, "la question ne doit rien écrire");

        // Et sur un oui, elle entre.
        assert!(matches!(add(&conn, &mut again, 1), Outcome::Added(_)));
        assert_eq!(in_base(&conn), 2);
    }

    /// **Le seul refus sec est pour une ligne déjà rapprochée dans la
    /// séance** : « Vous avez déjà rapproché cette transaction ».
    #[test]
    fn une_ligne_deja_rapprochee_dans_la_seance_est_refusee() {
        let conn = database();
        let mut import = loaded(&conn);
        add(&conn, &mut import, 1);
        assert!(matches!(
            add(&conn, &mut import, 1),
            Outcome::AlreadyReconciled
        ));
        assert_eq!(in_base(&conn), 1);
    }

    /// **Ce qui entre est ce que le fichier disait**, et le classement est
    /// celui de l'original : rien de deviné du `TRNTYPE`, statut pointé, date
    /// de pointage égale à la date.
    #[test]
    fn ce_qui_entre_est_ce_que_le_fichier_disait() {
        let conn = database();
        let mut import = loaded(&conn);
        add(&conn, &mut import, 3);

        let (label, date, clearing, amount, fitid, status, mode): (
            String,
            String,
            String,
            i64,
            String,
            i64,
            i64,
        ) = conn
            .query_row(
                "SELECT Libelle, Date, DatePointage, Montant, FitID, IDStatutOperation,
                        IDModeOperation FROM Operation WHERE IDCompte = 1",
                [],
                |row| {
                    Ok((
                        row.get(0)?,
                        row.get(1)?,
                        row.get(2)?,
                        row.get(3)?,
                        row.get(4)?,
                        row.get(5)?,
                        row.get(6)?,
                    ))
                },
            )
            .unwrap();
        assert_eq!(label, "VIREMENT SALAIRE");
        assert_eq!(date, "2026-07-21");
        assert_eq!(clearing, "2026-07-21");
        assert_eq!(amount, 2_000_000_000);
        assert_eq!(fitid, "P_C");
        assert_eq!(status, POINTED);
        assert_eq!(mode, 0, "le TRNTYPE ne doit rien deviner");

        let balance: i64 = conn
            .query_row("SELECT SoldeBanque FROM Compte WHERE IDCompte = 1", [], |r| {
                r.get(0)
            })
            .unwrap();
        assert_eq!(balance, 2_000_000_000);
    }

    /// **La fiche de rapprochement modifie la ligne, et c'est la version
    /// modifiée qui entre.** Chez Fabrice la fiche rend la transaction changée
    /// et la liste se rafraîchit avec — j'avais mis ces champs en lecture
    /// seule, c'était mon invention.
    #[test]
    fn ce_que_la_fiche_a_modifie_est_ce_qui_entre() {
        let conn = database();
        let mut import = loaded(&conn);
        let corrected = NaiveDate::from_ymd_opt(2026, 7, 20).unwrap();
        assert!(amend(&mut import, 1, Some(corrected), "RETRAIT CORRIGE", -60_000_000));
        add(&conn, &mut import, 1);

        let (label, date, amount): (String, String, i64) = conn
            .query_row(
                "SELECT Libelle, Date, Montant FROM Operation WHERE IDCompte = 1",
                [],
                |row| Ok((row.get(0)?, row.get(1)?, row.get(2)?)),
            )
            .unwrap();
        assert_eq!(label, "RETRAIT CORRIGE");
        assert_eq!(date, "2026-07-20");
        assert_eq!(amount, -60_000_000);
        // Et la ligne du tableau porte la correction, comme dans l'original.
        assert_eq!(import.line(1).unwrap().label, "RETRAIT CORRIGE");
    }

    /// **L'écart, tel que l'original le calcule** — et il ne le calcule pas de
    /// la même façon aux deux moments : `LEDGERBAL` au chargement,
    /// `AVAILBAL` après une intégration. C'est reproduit délibérément, sur
    /// consigne de Fabrice (« reste fidèle au code original »), et c'est ce
    /// test qui le rend visible plutôt que de le laisser dormir.
    #[test]
    fn l_ecart_se_calcule_sur_deux_soldes_selon_le_moment() {
        let conn = database();
        let mut import = loaded(&conn);

        let opening = reconciliation(&conn, &import, false).unwrap();
        assert_eq!(opening.file, 1_830_000_000, "au chargement : LEDGERBAL");
        assert_eq!(opening.difference, -1_830_000_000);

        add(&conn, &mut import, 1);
        add(&conn, &mut import, 2);
        add(&conn, &mut import, 3);

        let after = reconciliation(&conn, &import, true).unwrap();
        assert_eq!(after.account, 1_830_000_000);
        assert_eq!(
            after.difference,
            1_830_000_000 - 1_500_000_000,
            "après intégration : AVAILBAL, comme dans l'original"
        );
    }

    /// Un rang qui n'existe pas ne fait pas tomber l'importation.
    #[test]
    fn un_rang_inconnu_ne_fait_rien_et_ne_casse_rien() {
        let conn = database();
        let mut import = loaded(&conn);
        assert!(matches!(add(&conn, &mut import, 99), Outcome::Unknown));
        assert_eq!(in_base(&conn), 0);
        assert!(!amend(&mut import, 99, None, "", 0));
    }

    /// **Une ligne sans FITID n'est jamais un doublon avéré.** Sans
    /// identifiant on ne peut rien affirmer — c'est le cas de tout ce qui
    /// vient d'un CSV, et de la banque dont Fabrice avertit en tête de sa
    /// classe. Le soupçon, lui, joue encore.
    #[test]
    fn une_ligne_sans_fitid_n_est_jamais_un_doublon_avere() {
        let conn = database();
        let without = SAMPLE.replace("<FITID>P_A", "<FITID>");
        let statement = ofx_import::read(&without, "123456A789").unwrap();
        let mut import = prepare(&conn, 1, &statement).unwrap();
        assert!(!import.line(1).unwrap().fitid_known);
        assert!(matches!(add(&conn, &mut import, 1), Outcome::Added(_)));

        // Rechargé : toujours pas de certitude, mais le soupçon est là.
        let statement = ofx_import::read(&without, "123456A789").unwrap();
        let again = prepare(&conn, 1, &statement).unwrap();
        assert!(!again.line(1).unwrap().fitid_known);
        assert!(
            again.line(1).unwrap().looks_like_duplicate,
            "sans identifiant, la ressemblance est le seul filet"
        );
    }
}
