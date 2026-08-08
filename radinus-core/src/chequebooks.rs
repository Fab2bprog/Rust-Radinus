//! Les chéquiers — `Chequier` (02_BASE_DE_DONNEES.md §3.5), les fenêtres F13
//! et F31 de `04_SPECIFICATIONS_FENETRES.md`.
//!
//! Portage de `Code Fiche Chequier.txt` et de `Code Liste Chequier.txt`, que
//! Fabrice a fournis le 28/07/2026 avec ses sept captures.
//!
//! **Un carnet naît entier.** L'ajout écrit le chéquier puis appelle
//! `Genere_Cheques`, qui boucle du premier numéro au dernier et crée chaque
//! chèque au statut 1, « Non encore utilisé » — sans date, sans montant, sans
//! bénéficiaire. Quarante chèques d'un coup. Les deux écritures sont ici dans
//! **une seule transaction** : un carnet sans ses chèques serait un carnet
//! vide que rien ne pourrait remplir, puisque la génération n'est appelée que
//! de la création.
//!
//! **Et une fois né, sa numérotation est figée.** `Maj_Controles`, cas « M » :
//! `GR_InterditModif..EnSaisie = Faux`. Référence, date de réception, premier
//! numéro, dernier numéro et quantité sont grisés dès que le carnet existe —
//! ses chèques sont déjà là, certains émis, certains payés, certains associés à
//! des opérations. [`update`] ne prend donc que les deux champs qui restent
//! noirs sur la capture : le compte et les commentaires.
//!
//! **Huit barrières avant d'écrire quoi que ce soit** — [`refusal`], portage
//! mot pour mot de son « Precauttion enregistrement cheque.txt », fourni le
//! 28/07/2026. Elles vivent dans le bouton d'enregistrement de sa fiche, et
//! non dans son `Enreg_Ajouter` : c'est pour cela que je les avais manquées, et
//! que je lui ai affirmé deux choses fausses — que son `Existe_Reference()` ne
//! servait jamais, et que rien ne bornait le nombre de chèques. Les deux
//! étaient déjà fermées chez lui.
//!
//! **Le plafond est mille.** `SI SAI_NbrChq>1000` — et son message de
//! confirmation dit « Nombre de chèques **à générer** », donc ce nombre est
//! bien celui que la boucle produira, c'est-à-dire l'écart des deux bornes.
//! Une faute de frappe qui demanderait dix millions de chèques est arrêtée là,
//! avant la moindre écriture.
//!
//! **Une fidélité assumée reste** (arbitrage de Fabrice, 28/07/2026) : le lien
//! vers le compte est souple, sans cascade — supprimer un compte laisse ses
//! carnets orphelins, et c'est [`account_is_missing`] qui le signale à
//! l'ouverture de la fiche, exactement comme son `Enreg_Lire`.

use crate::text::french_sort_key;
use rusqlite::{Connection, Result};
use time_compute::NaiveDate;

/// Un chéquier, tel que sa fiche le montre.
#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct Chequebook {
    pub id: i64,
    /// `IDReferenceChq` — la référence du carnet, affichée « LIBELLE » dans la
    /// liste. Stockée **sans aucun espace** (`SansEspace(…, sscTout)`).
    pub reference: String,
    /// `DateRecep` — « Fabriqué ou reçu le ».
    pub received_on: Option<NaiveDate>,
    pub first_number: i64,
    pub last_number: i64,
    /// `QteChq` — **calculé**, jamais tapé : c'est l'écart des deux bornes, et
    /// c'est ce nombre-là que son plafond de mille contrôle (voir
    /// [`cheques_between`]). Stocké quand même, parce que sa table le porte et
    /// que la sauvegarde doit se retrouver.
    pub quantity: i64,
    /// `FormatNumChq` — dort dans le schéma comme dans son code : aucune ligne
    /// ne le lit ni ne l'écrit. Conservé pour que la table reste celle de la
    /// sauvegarde.
    pub number_format: i64,
    pub comments: String,
    pub account_id: i64,
}

/// Un chéquier tel que la liste F13 le montre : LIBELLE, Date, NomCompte,
/// Num Compte, Commentaires.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ChequebookRow {
    pub id: i64,
    pub reference: String,
    pub received_on: Option<NaiveDate>,
    pub account_label: String,
    pub account_number: String,
    pub comments: String,
}

const COLUMNS: &str = "IDChequier, IDReferenceChq, DateRecep, NumPremierChq, \
     NumDernChq, QteChq, FormatNumChq, Commentaires, IDCompte";

fn read(row: &rusqlite::Row<'_>) -> rusqlite::Result<Chequebook> {
    Ok(Chequebook {
        id: row.get(0)?,
        reference: row.get(1)?,
        received_on: row
            .get::<_, Option<String>>(2)?
            .and_then(|text| NaiveDate::parse_from_str(&text, "%Y-%m-%d").ok()),
        first_number: row.get(3)?,
        last_number: row.get(4)?,
        quantity: row.get(5)?,
        number_format: row.get(6)?,
        comments: row.get(7)?,
        account_id: row.get(8)?,
    })
}

/// La référence telle qu'elle est stockée : **sans aucun espace, où qu'il
/// soit**. C'est `SansEspace(Chequier.IDReferenceChq, sscTout)`, appelé à
/// l'ajout comme à la modification — « 073 28 » et « 07328 » sont le même
/// carnet, et l'index unique doit pouvoir le dire.
pub fn normalized_reference(reference: &str) -> String {
    reference.chars().filter(|c| !c.is_whitespace()).collect()
}

/// Tous les chéquiers, dans l'ordre de leur référence sous la collation
/// française. Le ⌘F7 les montre **tous** — c'est ce que disent ses deux
/// colonnes NomCompte et Num Compte, qui ne serviraient à rien sur un seul
/// compte (déduction confirmée par Fabrice le 28/07/2026).
pub fn list(conn: &Connection) -> Result<Vec<ChequebookRow>> {
    rows(conn, None)
}

/// Les chéquiers d'**un** compte — le `gSelIDCompte` de son original, pour la
/// porte qui viendra de la liste des comptes.
pub fn list_for_account(conn: &Connection, account_id: i64) -> Result<Vec<ChequebookRow>> {
    rows(conn, Some(account_id))
}

fn rows(conn: &Connection, account_id: Option<i64>) -> Result<Vec<ChequebookRow>> {
    // Le compte est joint en LEFT : un carnet dont le compte a disparu reste
    // dans la liste, avec ses deux colonnes vides. Le faire disparaître serait
    // pire — on ne pourrait plus ni le voir ni le supprimer.
    let sql = "SELECT q.IDChequier, q.IDReferenceChq, q.DateRecep,
                      COALESCE(c.Libelle, ''), COALESCE(c.COBNumCompte, ''),
                      q.Commentaires
               FROM Chequier q
               LEFT JOIN Compte c ON c.IDCompte = q.IDCompte";
    let build = |row: &rusqlite::Row<'_>| {
        Ok(ChequebookRow {
            id: row.get(0)?,
            reference: row.get(1)?,
            received_on: row
                .get::<_, Option<String>>(2)?
                .and_then(|text| NaiveDate::parse_from_str(&text, "%Y-%m-%d").ok()),
            account_label: row.get(3)?,
            account_number: row.get(4)?,
            comments: row.get(5)?,
        })
    };

    let mut rows: Vec<ChequebookRow> = match account_id {
        None => conn
            .prepare(sql)?
            .query_map([], build)?
            .collect::<Result<_>>()?,
        Some(id) => conn
            .prepare(&format!("{sql} WHERE q.IDCompte = ?1"))?
            .query_map([id], build)?
            .collect::<Result<_>>()?,
    };
    rows.sort_by_key(|row| french_sort_key(&row.reference));
    Ok(rows)
}

/// Lit un chéquier, ou `None` s'il n'existe plus.
pub fn get(conn: &Connection, id: i64) -> Result<Option<Chequebook>> {
    match conn.query_row(
        &format!("SELECT {COLUMNS} FROM Chequier WHERE IDChequier = ?1"),
        [id],
        read,
    ) {
        Ok(book) => Ok(Some(book)),
        Err(rusqlite::Error::QueryReturnedNoRows) => Ok(None),
        Err(other) => Err(other),
    }
}

/// Si le compte auquel ce carnet est rattaché a disparu.
///
/// Son `Enreg_Lire` le vérifie à chaque ouverture de la fiche et le dit :
/// « Le Compte bancaire auquel a été associé ce chéquier est absent ou a été
/// supprimé ! ». Le lien est souple, sans cascade — supprimer un compte ne
/// touche pas ses carnets — donc le cas arrive vraiment, et c'est ici qu'on le
/// voit. La phrase, elle, vit dans Fluent : ce module ne parle pas.
pub fn account_is_missing(conn: &Connection, book: &Chequebook) -> Result<bool> {
    let found: i64 = conn.query_row(
        "SELECT COUNT(*) FROM Compte WHERE IDCompte = ?1",
        [book.account_id],
        |row| row.get(0),
    )?;
    Ok(found == 0)
}

/// Le plus grand numéro de chèque qu'un carnet accepte — sa valeur, écrite
/// dans son message : « valeur maximum 999 999 999 ».
pub const LARGEST_NUMBER: i64 = 999_999_999;

/// Le plus grand nombre de chèques qu'un carnet peut porter. Son plafond, et
/// c'est lui qui rend impossible le carnet de dix millions de chèques.
pub const MOST_CHEQUES: i64 = 1_000;

/// Combien de chèques ces deux bornes produiront — ce que sa fiche affiche
/// sous « Nombre de chèques », et ce que son message de confirmation annonce
/// comme « Nombre de chèques à générer ».
///
/// **Il se calcule, il ne se tape pas.** C'est ce qui donne son sens au
/// plafond : `SI SAI_NbrChq>1000` ne bornerait rien s'il portait sur un nombre
/// sans rapport avec les bornes. Deux bornes à l'envers en produisent zéro,
/// comme sa boucle.
pub fn cheques_between(first: i64, last: i64) -> i64 {
    if last < first {
        0
    } else {
        last - first + 1
    }
}

/// Pourquoi ce chéquier ne peut pas être enregistré, ou `None` s'il le peut.
///
/// **Portage mot pour mot de son « Precauttion enregistrement cheque.txt »**,
/// dans son ordre exact — l'ordre compte : c'est lui qui décide quel message
/// l'utilisateur voit quand deux choses vont mal à la fois. La clef Fluent est
/// rendue plutôt que la phrase : ce module ne parle aucune langue.
///
/// `adding` distingue ses deux modes : la référence en double n'est cherchée
/// qu'à l'ajout (`ET gsModeFiche="A"`), parce qu'en modification elle ne bouge
/// plus — elle est dans le groupe gelé.
pub fn refusal(conn: &Connection, book: &Chequebook, adding: bool) -> Result<Option<&'static str>> {
    let reference = normalized_reference(&book.reference);

    if adding {
        let taken: i64 = conn.query_row(
            "SELECT COUNT(*) FROM Chequier WHERE IDReferenceChq = ?1",
            [&reference],
            |row| row.get(0),
        )?;
        if taken > 0 {
            return Ok(Some("chequebook-refusal-duplicate"));
        }
    }
    if reference.is_empty() {
        return Ok(Some("chequebook-refusal-reference-required"));
    }
    if book.first_number > LARGEST_NUMBER || book.last_number > LARGEST_NUMBER {
        return Ok(Some("chequebook-refusal-number-too-big"));
    }
    if book.received_on.is_none() {
        return Ok(Some("chequebook-refusal-date"));
    }
    if book.first_number == 0 && book.last_number == 0 {
        return Ok(Some("chequebook-refusal-numbers-required"));
    }
    if book.first_number > book.last_number {
        return Ok(Some("chequebook-refusal-order"));
    }
    if book.account_id == 0 {
        return Ok(Some("chequebook-refusal-account"));
    }
    if cheques_between(book.first_number, book.last_number) > MOST_CHEQUES {
        return Ok(Some("chequebook-refusal-too-many"));
    }
    Ok(None)
}

/// Ajoute un chéquier **et tous ses chèques**, en une seule transaction.
///
/// Rend l'identifiant du carnet, ou `None` quand [`refusal`] aurait refusé :
/// **la base est la dernière barrière**, pas la première. La fenêtre pose les
/// huit questions et montre les messages ; celle-ci se contente de ne pas
/// écrire ce qui n'aurait pas dû l'être — une fenêtre peut se tromper, une base
/// ne doit pas. Rien n'est écrit dans ce cas : ni carnet, ni chèque.
///
/// La génération est celle de `Genere_Cheques` : `POUR i = premier À dernier`.
pub fn create(conn: &mut Connection, book: &Chequebook) -> Result<Option<i64>> {
    if refusal(conn, book, true)?.is_some() {
        return Ok(None);
    }
    let reference = normalized_reference(&book.reference);

    let id = crate::database::keygen::next_id(conn, "Chequier", "IDChequier")?;
    let tx = conn.transaction()?;
    tx.execute(
        &format!(
            "INSERT INTO Chequier ({COLUMNS}) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9)"
        ),
        rusqlite::params![
            id,
            reference,
            book.received_on.map(|d| d.format("%Y-%m-%d").to_string()),
            book.first_number,
            book.last_number,
            book.quantity,
            book.number_format,
            book.comments.trim(),
            book.account_id,
        ],
    )?;

    let mut key: i64 = tx.query_row(
        "SELECT COALESCE(MAX(IDCheque), 0) + 1 FROM Cheque",
        [],
        |row| row.get(0),
    )?;
    let mut number = book.first_number;
    while number <= book.last_number {
        tx.execute(
            "INSERT INTO Cheque (IDCheque, NumChq, IDChequier, DateEmission,
                                 Beneficiaire, Montant, Commentaires, LieuEmission,
                                 IDStatutCheque)
             VALUES (?1, ?2, ?3, NULL, '', 0, '', '', 1)",
            rusqlite::params![key, number, id],
        )?;
        key += 1;
        number += 1;
    }
    tx.commit()?;
    Ok(Some(id))
}

/// Change ce qui reste modifiable d'un chéquier : **le compte et les
/// commentaires**, et rien d'autre.
///
/// Les cinq autres champs sont dans `GR_InterditModif`, grisé dès que le
/// carnet existe. Ils ne sont pas seulement invisibles à l'écran : ils ne
/// passent pas par ici, si bien qu'aucune fenêtre ne peut les changer par
/// erreur. Rend `false` si le carnet n'existe plus.
pub fn update(conn: &Connection, id: i64, account_id: i64, comments: &str) -> Result<bool> {
    let changed = conn.execute(
        "UPDATE Chequier SET IDCompte = ?1, Commentaires = ?2 WHERE IDChequier = ?3",
        rusqlite::params![account_id, comments.trim(), id],
    )?;
    Ok(changed > 0)
}

/// Combien d'opérations bancaires les chèques de ce carnet portent.
///
/// C'est ce que compte son `Enreg_Supprimer` avant de poser sa question : la
/// suppression ne détruira aucune de ces opérations, elle leur retirera leur
/// chèque. Le caller est celui qui demande ; ce module ne parle pas.
pub fn linked_operations(conn: &Connection, id: i64) -> Result<i64> {
    conn.query_row(
        "SELECT COUNT(*) FROM Operation
         WHERE IDCheque IN (SELECT IDCheque FROM Cheque WHERE IDChequier = ?1)",
        [id],
        |row| row.get(0),
    )
}

/// Supprime un chéquier, ses chèques, et **détache** les opérations qui les
/// portaient.
///
/// C'est son `Enreg_Supprimer` mot pour mot dans son ordre : parcourir les
/// chèques, remettre `Operation.IDCheque = 0` sur tout ce qui s'y accroche,
/// puis supprimer le carnet — les chèques suivent en cascade. **Aucune
/// opération bancaire n'est jamais détruite** : elles restent dans leur compte,
/// sans chèque.
///
/// La question, elle, est posée avant, par la fenêtre, et **une seule fois**
/// pour toute la sélection (son `bConfirmation`). Rend `false` si le carnet
/// n'existe plus.
pub fn delete(conn: &mut Connection, id: i64) -> Result<bool> {
    if get(conn, id)?.is_none() {
        return Ok(false);
    }
    let tx = conn.transaction()?;
    tx.execute(
        "UPDATE Operation SET IDCheque = 0
         WHERE IDCheque IN (SELECT IDCheque FROM Cheque WHERE IDChequier = ?1)",
        [id],
    )?;
    tx.execute("DELETE FROM Cheque WHERE IDChequier = ?1", [id])?;
    tx.execute("DELETE FROM Chequier WHERE IDChequier = ?1", [id])?;
    tx.commit()?;
    Ok(true)
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

    fn an_account(conn: &Connection, label: &str, number: &str) -> i64 {
        let id = crate::database::keygen::next_id(conn, "Compte", "IDCompte").expect("clef");
        conn.execute(
            "INSERT INTO Compte (IDCompte, Libelle, COBNumCompte, IDTypeCompte)
             VALUES (?1, ?2, ?3, 1)",
            rusqlite::params![id, label, number],
        )
        .expect("compte");
        id
    }

    fn a_book(account_id: i64, reference: &str, first: i64, last: i64) -> Chequebook {
        Chequebook {
            id: 0,
            reference: reference.to_string(),
            received_on: NaiveDate::from_ymd_opt(2020, 8, 1),
            first_number: first,
            last_number: last,
            quantity: last - first + 1,
            number_format: 0,
            comments: String::new(),
            account_id,
        }
    }

    /// **Les huit barrières, dans son ordre exact.**
    ///
    /// L'ordre n'est pas un détail : c'est lui qui décide quel message paraît
    /// quand deux choses vont mal à la fois. Chaque cas est ici avec, en
    /// regard, la ligne de son fichier de précautions.
    #[test]
    fn les_huit_precautions_refusent_dans_son_ordre() {
        let mut conn = database();
        let account = an_account(&conn, "CCP", "");
        create(&mut conn, &a_book(account, "07328", 1, 10))
            .expect("premier carnet")
            .expect("libre");

        let refused = |book: &Chequebook, adding: bool| {
            refusal(&conn, book, adding).expect("examen")
        };

        // 1 — SI Existe_Reference() ET gsModeFiche="A"
        let mut book = a_book(account, " 073 28 ", 20, 30);
        assert_eq!(refused(&book, true), Some("chequebook-refusal-duplicate"));
        // ...et pas en modification : la référence y est gelée.
        assert_eq!(refused(&book, false), None);

        // 2 — SI Taille(SansEspace(SAI_Reference))=0
        book = a_book(account, "   ", 20, 30);
        assert_eq!(refused(&book, true), Some("chequebook-refusal-reference-required"));

        // 3 — SI SAI_NumPremierChq>999999999 OU SAI_NumDernierChq>999999999
        book = a_book(account, "06561", 1, 1_000_000_000);
        assert_eq!(refused(&book, true), Some("chequebook-refusal-number-too-big"));
        book = a_book(account, "06561", 1_000_000_000, 1_000_000_001);
        assert_eq!(refused(&book, true), Some("chequebook-refusal-number-too-big"));
        // La borne elle-même passe : « valeur maximum 999 999 999 ».
        book = a_book(account, "06561", LARGEST_NUMBER, LARGEST_NUMBER);
        assert_eq!(refused(&book, true), None);

        // 4 — SI PAS DateValide(SAI_Reception)
        book = a_book(account, "06561", 1, 10);
        book.received_on = None;
        assert_eq!(refused(&book, true), Some("chequebook-refusal-date"));

        // 5 — SI SAI_NumPremierChq=0 ET SAI_NumDernierChq=0
        book = a_book(account, "06561", 0, 0);
        assert_eq!(refused(&book, true), Some("chequebook-refusal-numbers-required"));

        // 6 — SI SAI_NumPremierChq>SAI_NumDernierChq
        book = a_book(account, "06561", 40, 1);
        assert_eq!(refused(&book, true), Some("chequebook-refusal-order"));
        // Égaux, c'est un carnet d'un seul chèque, et il passe.
        book = a_book(account, "06561", 7, 7);
        assert_eq!(refused(&book, true), None);

        // 7 — SI COMBO_Compte.COL_IDCompte=0
        book = a_book(0, "06561", 1, 10);
        assert_eq!(refused(&book, true), Some("chequebook-refusal-account"));

        // 8 — SI SAI_NbrChq>1000
        book = a_book(account, "06561", 1, MOST_CHEQUES);
        assert_eq!(refused(&book, true), None, "mille pile, c'est permis");
        book = a_book(account, "06561", 1, MOST_CHEQUES + 1);
        assert_eq!(refused(&book, true), Some("chequebook-refusal-too-many"));
    }

    /// **Le carnet de dix millions de chèques n'existe pas.**
    ///
    /// C'est le danger que j'avais signalé à Fabrice comme non corrigé, et
    /// qu'il avait déjà fermé : une faute de frappe sur le dernier numéro est
    /// arrêtée **avant la moindre écriture**. Ni carnet, ni chèque.
    #[test]
    fn une_faute_de_frappe_sur_le_dernier_numero_n_ecrit_rien_du_tout() {
        let mut conn = database();
        let account = an_account(&conn, "CCP", "");
        // 9 506 001 → 95 060 040 : dix millions de chèques demandés.
        let refused = create(&mut conn, &a_book(account, "07328", 9_506_001, 95_060_040))
            .expect("examen");
        assert_eq!(refused, None);

        let books: i64 = conn
            .query_row("SELECT COUNT(*) FROM Chequier", [], |row| row.get(0))
            .expect("carnets");
        let cheques: i64 = conn
            .query_row("SELECT COUNT(*) FROM Cheque", [], |row| row.get(0))
            .expect("chèques");
        assert_eq!((books, cheques), (0, 0));
    }

    /// Le nombre de chèques se calcule, il ne se tape pas — et c'est ce qui
    /// donne son sens au plafond.
    #[test]
    fn le_nombre_de_cheques_est_l_ecart_des_deux_bornes() {
        assert_eq!(cheques_between(9_506_001, 9_506_040), 40);
        assert_eq!(cheques_between(7, 7), 1);
        assert_eq!(cheques_between(40, 1), 0, "à l'envers, sa boucle ne tourne pas");
        assert_eq!(cheques_between(1, MOST_CHEQUES), MOST_CHEQUES);
    }

    /// **Le croisement du carnet.** Un chéquier de 9 506 001 à 9 506 040 donne
    /// quarante chèques, tous au statut 1, numérotés sans trou — et les trois
    /// nombres sont comptés par trois chemins différents : la boucle, la base,
    /// et l'écart des deux bornes.
    #[test]
    fn un_carnet_nait_avec_tous_ses_cheques_au_statut_non_encore_utilise() {
        let mut conn = database();
        let account = an_account(&conn, "CCP", "0500013M026");
        let id = create(&mut conn, &a_book(account, "07328", 9_506_001, 9_506_040))
            .expect("ajout")
            .expect("la référence est libre");

        let count: i64 = conn
            .query_row(
                "SELECT COUNT(*) FROM Cheque WHERE IDChequier = ?1",
                [id],
                |row| row.get(0),
            )
            .expect("compte");
        assert_eq!(count, 40);
        assert_eq!(count, 9_506_040 - 9_506_001 + 1);

        let unused: i64 = conn
            .query_row(
                "SELECT COUNT(*) FROM Cheque WHERE IDChequier = ?1 AND IDStatutCheque = 1",
                [id],
                |row| row.get(0),
            )
            .expect("statuts");
        assert_eq!(unused, 40, "tous naissent « Non encore utilisé »");

        let (low, high): (i64, i64) = conn
            .query_row(
                "SELECT MIN(NumChq), MAX(NumChq) FROM Cheque WHERE IDChequier = ?1",
                [id],
                |row| Ok((row.get(0)?, row.get(1)?)),
            )
            .expect("bornes");
        assert_eq!((low, high), (9_506_001, 9_506_040));

        // Rien n'est rempli : ni date, ni bénéficiaire, ni montant.
        let filled: i64 = conn
            .query_row(
                "SELECT COUNT(*) FROM Cheque WHERE IDChequier = ?1
                 AND (DateEmission IS NOT NULL OR Beneficiaire <> '' OR Montant <> 0)",
                [id],
                |row| row.get(0),
            )
            .expect("remplissage");
        assert_eq!(filled, 0);
    }

    /// La référence perd ses espaces, où qu'ils soient — à l'ajout comme à la
    /// lecture. C'est `SansEspace(…, sscTout)`.
    #[test]
    fn la_reference_est_stockee_sans_aucun_espace() {
        let mut conn = database();
        let account = an_account(&conn, "CCP", "");
        let id = create(&mut conn, &a_book(account, " 073 28 ", 1, 2))
            .expect("ajout")
            .expect("libre");
        assert_eq!(get(&conn, id).expect("lecture").expect("existe").reference, "07328");
        assert_eq!(normalized_reference("07 3 28"), "07328");
    }

    /// Une référence déjà prise n'écrit rien — et, contrairement à ce que
    /// j'avais cru, **elle est annoncée** : son `Existe_Reference()` est bien
    /// appelée, dans le bouton d'enregistrement (voir [`refusal`]).
    #[test]
    fn une_reference_deja_prise_n_ecrit_rien() {
        let mut conn = database();
        let account = an_account(&conn, "CCP", "");
        create(&mut conn, &a_book(account, "07328", 1, 40))
            .expect("premier")
            .expect("libre");

        let refused = create(&mut conn, &a_book(account, " 07 328 ", 500, 540)).expect("second");
        assert_eq!(refused, None);

        let books: i64 = conn
            .query_row("SELECT COUNT(*) FROM Chequier", [], |row| row.get(0))
            .expect("carnets");
        let cheques: i64 = conn
            .query_row("SELECT COUNT(*) FROM Cheque", [], |row| row.get(0))
            .expect("chèques");
        assert_eq!(books, 1);
        assert_eq!(cheques, 40, "le carnet refusé n'a laissé aucun chèque");
    }

    /// **Un carnet à l'envers n'existe pas non plus.** J'avais écrit qu'il
    /// serait créé vide, comme le laisse croire sa boucle prise isolément ; sa
    /// sixième précaution l'arrête bien avant — « Le numéro du premier chèque
    /// doit être inférieur au numéro du dernier chèque ».
    #[test]
    fn un_carnet_a_l_envers_n_est_pas_cree() {
        let mut conn = database();
        let account = an_account(&conn, "CCP", "");
        assert_eq!(
            create(&mut conn, &a_book(account, "07328", 40, 1)).expect("examen"),
            None
        );
        let books: i64 = conn
            .query_row("SELECT COUNT(*) FROM Chequier", [], |row| row.get(0))
            .expect("carnets");
        assert_eq!(books, 0);
    }

    /// **La numérotation est figée.** `update` ne prend que le compte et les
    /// commentaires : les cinq champs de `GR_InterditModif` ne passent pas par
    /// lui, donc aucune fenêtre ne peut les changer.
    #[test]
    fn seuls_le_compte_et_les_commentaires_bougent_apres_la_creation() {
        let mut conn = database();
        let first = an_account(&conn, "CCP", "");
        let second = an_account(&conn, "Livret A", "");
        let id = create(&mut conn, &a_book(first, "07328", 9_506_001, 9_506_040))
            .expect("ajout")
            .expect("libre");

        assert!(update(&conn, id, second, "  carnet déplacé  ").expect("modification"));
        let book = get(&conn, id).expect("relecture").expect("existe");
        assert_eq!(book.account_id, second);
        assert_eq!(book.comments, "carnet déplacé");
        // Intactes, toutes les cinq.
        assert_eq!(book.reference, "07328");
        assert_eq!(book.first_number, 9_506_001);
        assert_eq!(book.last_number, 9_506_040);
        assert_eq!(book.quantity, 40);
        assert_eq!(book.received_on, NaiveDate::from_ymd_opt(2020, 8, 1));
    }

    /// **Le croisement de la suppression.** Supprimer un carnet laisse le
    /// compte avec **exactement autant d'opérations qu'avant**, toutes sans
    /// chèque. Deux chemins vers le même nombre : ce que le compte porte, et ce
    /// qu'il portait.
    #[test]
    fn supprimer_un_carnet_detache_les_operations_sans_en_detruire_une_seule() {
        let mut conn = database();
        let account = an_account(&conn, "CCP", "");
        let id = create(&mut conn, &a_book(account, "07328", 1, 5))
            .expect("ajout")
            .expect("libre");

        let cheques: Vec<i64> = conn
            .prepare("SELECT IDCheque FROM Cheque WHERE IDChequier = ?1")
            .expect("requête")
            .query_map([id], |row| row.get(0))
            .expect("chèques")
            .collect::<Result<_>>()
            .expect("collecte");
        for (rank, cheque) in cheques.iter().enumerate() {
            conn.execute(
                "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte,
                                        IDStatutOperation, IDCheque)
                 VALUES (?1, ?2, '2026-01-01', -1000000, ?3, 1, ?4)",
                rusqlite::params![rank as i64 + 1, format!("Chèque {rank}"), account, cheque],
            )
            .expect("opération");
        }

        let before: i64 = conn
            .query_row(
                "SELECT COUNT(*) FROM Operation WHERE IDCompte = ?1",
                [account],
                |row| row.get(0),
            )
            .expect("avant");
        assert_eq!(before, 5);
        assert_eq!(linked_operations(&conn, id).expect("liées"), 5);

        assert!(delete(&mut conn, id).expect("suppression"));

        let after: i64 = conn
            .query_row(
                "SELECT COUNT(*) FROM Operation WHERE IDCompte = ?1",
                [account],
                |row| row.get(0),
            )
            .expect("après");
        assert_eq!(after, before, "aucune opération n'est détruite");
        let still_linked: i64 = conn
            .query_row(
                "SELECT COUNT(*) FROM Operation WHERE IDCheque <> 0",
                [],
                |row| row.get(0),
            )
            .expect("liens");
        assert_eq!(still_linked, 0, "toutes sont détachées");
        let left: i64 = conn
            .query_row("SELECT COUNT(*) FROM Cheque", [], |row| row.get(0))
            .expect("chèques");
        assert_eq!(left, 0, "les chèques partent avec leur carnet");
        assert!(!delete(&mut conn, id).expect("seconde suppression"));
    }

    /// **La fidélité assumée n°3.** Le lien vers le compte est souple : le
    /// compte s'en va, le carnet reste, et c'est la fiche qui le dit.
    #[test]
    fn un_carnet_survit_a_son_compte_et_le_signale() {
        let mut conn = database();
        let account = an_account(&conn, "CCP", "0500013M026");
        let id = create(&mut conn, &a_book(account, "07328", 1, 3))
            .expect("ajout")
            .expect("libre");

        let book = get(&conn, id).expect("lecture").expect("existe");
        assert!(!account_is_missing(&conn, &book).expect("compte présent"));

        conn.execute("DELETE FROM Compte WHERE IDCompte = ?1", [account])
            .expect("suppression du compte");

        let book = get(&conn, id).expect("relecture").expect("le carnet est là");
        assert!(account_is_missing(&conn, &book).expect("compte absent"));
        // Et il reste visible dans la liste, avec ses deux colonnes vides.
        let rows = list(&conn).expect("liste");
        let row = rows.iter().find(|row| row.id == id).expect("le carnet");
        assert_eq!(row.account_label, "");
        assert_eq!(row.account_number, "");
    }

    /// La liste montre le nom et le numéro du compte, et se trie sous la
    /// collation française. Filtrée sur un compte, elle ne montre que le sien.
    #[test]
    fn la_liste_porte_le_compte_et_se_trie_a_la_francaise() {
        let mut conn = database();
        let ccp = an_account(&conn, "CCP", "0500013M026");
        let livret = an_account(&conn, "Livret A", "12345Z");
        for (account, reference) in [(ccp, "07328"), (livret, "06561"), (ccp, "Épargne-1")] {
            create(&mut conn, &a_book(account, reference, 1, 2))
                .expect("ajout")
                .expect("libre");
        }

        let all = list(&conn).expect("liste");
        let references: Vec<&str> = all.iter().map(|row| row.reference.as_str()).collect();
        assert_eq!(references, vec!["06561", "07328", "Épargne-1"]);
        let first = all.iter().find(|row| row.reference == "06561").expect("06561");
        assert_eq!(first.account_label, "Livret A");
        assert_eq!(first.account_number, "12345Z");

        let mine = list_for_account(&conn, ccp).expect("filtrée");
        assert_eq!(mine.len(), 2);
        assert!(mine.iter().all(|row| row.account_label == "CCP"));
    }
}
