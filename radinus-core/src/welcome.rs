//! F01 — ce que la fenêtre d'accueil montre.
//!
//! Référence : `04_SPECIFICATIONS_FENETRES.md` F01, `03_CHARTE_GRAPHIQUE.md`
//! §3.1, et la décision du 03/08/2026 tracée au `00_LISEZMOI.md`.
//!
//! **La règle de l'accueil, et elle commande tout ce module :**
//!
//! > L'accueil est la vue **sans un clic**. Tout ce qui demande un réglage n'y
//! > a pas sa place.
//!
//! C'est pour cela que cette fonction n'a ni interrupteur, ni période, ni
//! liste de comptes en argument : les comptes sont ceux qui sont ouverts, la
//! période est le mois en cours, les trois statuts passent. Le jour où l'un de
//! ces trois deviendrait un paramètre, ce serait le signe qu'il fallait ouvrir
//! F19 plutôt qu'encombrer l'accueil.
//!
//! **La règle a été précisée le 03/08/2026**, et il faut lire la nuance.
//! L'anneau se creuse maintenant d'un clic : un secteur montre ses catégories.
//! Ce n'est pas un réglage — rien à choisir, rien à saisir, rien à mémoriser —
//! c'est une **lecture plus fine de ce qui est déjà à l'écran**, et l'accueil
//! répond toujours sans qu'on lui ait rien demandé. La distinction tient à
//! ceci : ce que l'accueil montre à l'ouverture n'a pas changé d'un pixel.
//!
//! **La règle a été révisée le 07/10/2026**, par Fabrice lui-même, et il faut
//! l'écrire pour qu'on ne prenne pas ce qui suit pour une entorse. La zone
//! « Vos comptes » porte désormais deux réglages, et ils sont mémorisés :
//! l'**ordre des tuiles**, qu'on glisse, et une **case à cocher** par compte,
//! qui dit s'il entre dans les trois totaux et dans les deux anneaux. Ce qui
//! tient toujours : l'accueil répond **à l'ouverture, sans qu'on lui ait rien
//! demandé** — il s'ouvre sur ce qu'on avait réglé la dernière fois, et tant
//! qu'on n'a rien réglé, sur ce qu'il a toujours montré. La préférence est lue
//! ici (`preferences::welcome_accounts`), et cette fonction n'a toujours ni
//! interrupteur ni liste de comptes en argument.
//!
//! **Rien ne se calcule ici.** Les totaux sortent de `accounts::list`, les deux
//! anneaux de `dashboard::dashboard`. Ce module ne fait que les appeler avec
//! des paramètres fixes. Ce n'est pas de la paresse, c'est la seule façon
//! d'être sûr que l'accueil ne contredira jamais F07 ni F19 : un chiffre
//! d'accueil en désaccord avec la fenêtre qui fait autorité serait pire que
//! pas de chiffre du tout, puisque rien ne le signalerait.

use crate::accounts::AccountRow;
use crate::dashboard::{self, DayPoint, Slice};
use crate::statistics::Switches;
use rusqlite::{Connection, Result};
use time_compute::{Datelike, NaiveDate};

/// **Où en est un anneau dans sa descente.**
///
/// Trois niveaux, et on descend toujours d'un clic (décision de Fabrice,
/// 03/08/2026) : les postes budgétaires, puis les catégories d'un poste, puis
/// la courbe d'une catégorie. On ne remonte jamais en cliquant l'anneau — il
/// y a un lien pour cela sous le dessin.
///
/// Les deux champs se lisent ensemble : rien du tout, c'est le premier niveau ;
/// un poste seul, c'est le deuxième ; un poste **et** une catégorie, c'est la
/// courbe. La catégorie ne va jamais sans son poste, parce qu'on remonte de
/// l'une à l'autre et qu'il faut savoir dans quel anneau revenir.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct Drill {
    pub budget_line: Option<i64>,
    pub category: Option<i64>,
}

/// Tout ce que l'accueil affiche, en une seule lecture.
///
/// Une seule commande plutôt que quatre : la fenêtre s'ouvre au lancement du
/// logiciel, c'est le moment où l'utilisateur juge s'il est lent.
// `AccountRow` ne déclare que `PartialEq`, jamais `Eq` : `Welcome` ne peut
// donc pas le porter non plus, et n'en a pas besoin — `PartialEq` suffit
// largement à ce que les tests comparent deux accueils.
#[derive(Debug, Clone, PartialEq)]
pub struct Welcome {
    /// Les comptes **ouverts**, dans l'ordre des listes. Les clôturés sont
    /// dehors, comme ils sont dehors de F07 : ils ne portent plus rien sur
    /// quoi agir, et les compter dirait que le foyer possède un argent qu'il a
    /// fermé il y a des années.
    ///
    /// **Dans l'ordre que l'utilisateur leur a donné** depuis le 07/10/2026 :
    /// ceux qu'il a rangés d'abord, dans son ordre, puis les autres — un compte
    /// né depuis — dans celui des listes.
    pub accounts: Vec<AccountRow>,
    /// **Les comptes laissés hors des totaux** : leur case est décochée. Ils
    /// sont dans `accounts` — on les montre —, mais ni les trois totaux ni les
    /// deux anneaux ne les comptent.
    pub excluded: Vec<i64>,
    pub total_bank: i64,
    pub total_real: i64,
    pub total_final: i64,
    /// Ce qui a coûté ce mois-ci, du plus lourd au plus léger : les postes
    /// budgétaires, ou les catégories d'un poste si l'anneau est creusé.
    pub spending: Vec<Slice>,
    /// Ce qui a rapporté. Souvent vide, et c'est une réponse.
    pub earning: Vec<Slice>,
    /// La courbe du cumul, quand une catégorie est choisie. Vide autrement.
    pub spending_curve: Vec<DayPoint>,
    pub earning_curve: Vec<DayPoint>,
    /// Le nom de la catégorie regardée, pour que l'en-tête le dise. C'est une
    /// donnée, pas une phrase : elle vient de la base, pas du dictionnaire.
    pub spending_category_label: Option<String>,
    pub earning_category_label: Option<String>,
    /// Où en est chaque anneau dans sa descente.
    ///
    /// **Rendus tels qu'ils ont été demandés**, pour que la fenêtre n'ait pas
    /// à se souvenir de ce qu'elle vient d'envoyer : ce qui revient du noyau
    /// décrit entièrement ce qu'elle doit dessiner. Les deux anneaux
    /// descendent séparément — ils n'ont pas les mêmes postes.
    pub spending_drill: Drill,
    pub earning_drill: Drill,
    /// Les deux bornes du mois regardé, pour que la fenêtre puisse le nommer
    /// sans le recalculer — elle n'a pas à savoir combien de jours a février.
    pub from: NaiveDate,
    pub to: NaiveDate,
    /// Le mois d'avant et celui d'après, déjà calculés.
    ///
    /// **La fenêtre ne fait aucune arithmétique de date.** Elle reçoit ces deux
    /// dates, en renvoie une quand on clique un chevron, et c'est tout — elle
    /// n'a jamais à savoir que janvier moins un mois change d'année. Aux
    /// bornes, le voisin est le mois lui-même : la flèche ne fait alors rien,
    /// plutôt que d'annoncer une erreur pour un geste anodin.
    pub previous: NaiveDate,
    pub next: NaiveDate,
}

/// Les bornes du calendrier de Radinus, celles du sélecteur d'année des
/// statistiques. Au-delà, une date n'est plus une date, c'est une faute de
/// frappe.
const FIRST_YEAR: i32 = 1950;
const LAST_YEAR: i32 = 2550;

/// Le premier jour du mois décalé de `months` — négatif pour reculer.
///
/// Écrit en arithmétique pure sur le rang du mois plutôt qu'avec un décalage
/// de calendrier : il n'y a ici ni quantième à raboter ni fin de mois à
/// deviner, on ne manipule que des premiers du mois. `div_euclid` et
/// `rem_euclid` — et non `/` et `%` — parce que le rang devient négatif avant
/// l'an zéro et que la division entière de Rust arrondit alors vers zéro, ce
/// qui ferait reculer de treize mois au lieu d'un.
pub fn shift_month(day: NaiveDate, months: i64) -> NaiveDate {
    let rank = i64::from(day.year()) * 12 + i64::from(day.month()) - 1 + months;
    let year = rank.div_euclid(12);
    let month = rank.rem_euclid(12) as u32 + 1;
    let (year, month) = if year < i64::from(FIRST_YEAR) {
        (FIRST_YEAR, 1)
    } else if year > i64::from(LAST_YEAR) {
        (LAST_YEAR, 12)
    } else {
        (year as i32, month)
    };
    NaiveDate::from_ymd_opt(year, month, 1).unwrap_or(day)
}


/// Le premier et le dernier jour du mois de `day`.
///
/// Le dernier jour se prend en reculant d'un jour depuis le premier du mois
/// suivant, plutôt qu'en consultant une table de longueurs de mois : c'est la
/// seule écriture qui ne se trompe pas une année bissextile sur quatre.
pub fn month_of(day: NaiveDate) -> (NaiveDate, NaiveDate) {
    let first = NaiveDate::from_ymd_opt(day.year(), day.month(), 1).unwrap_or(day);
    let next = if day.month() == 12 {
        NaiveDate::from_ymd_opt(day.year() + 1, 1, 1)
    } else {
        NaiveDate::from_ymd_opt(day.year(), day.month() + 1, 1)
    };
    let last = next
        .and_then(|first_of_next| first_of_next.pred_opt())
        .unwrap_or(first);
    (first, last)
}

/// Ce que l'accueil montre, pour le mois où tombe `day`.
///
/// `day` est **donné** et non lu à l'horloge : le noyau ne consulte pas
/// l'heure, sans quoi ses tests dépendraient du jour où on les lance et le
/// mois de la fenêtre changerait de sens à minuit sans qu'aucun test ne le
/// voie. C'est le contrôleur qui sait quel jour on est — et la fenêtre qui
/// sait quel mois on feuillette, une fois qu'on a cliqué un chevron.
pub fn welcome(
    conn: &Connection,
    day: NaiveDate,
    unclassified_label: &str,
    spending_drill: Drill,
    earning_drill: Drill,
) -> Result<Welcome> {
    let open: Vec<AccountRow> = crate::accounts::list(conn)?
        .into_iter()
        .filter(|account| !account.is_closed)
        .collect();

    // **Ce que l'utilisateur a réglé dans « Vos comptes »** : un ordre, et des
    // comptes laissés hors des totaux. Un souhait, pas une liste — un compte
    // qu'il ne cite pas vient après les autres et compte ; un compte qu'il
    // cite et qui n'existe plus, ou qui a été clôturé, est ignoré.
    let wished = crate::preferences::welcome_accounts(conn)?;
    let rank = |account: &AccountRow| {
        wished
            .order
            .iter()
            .position(|id| *id == account.id)
            .unwrap_or(usize::MAX)
    };
    let mut accounts = open;
    // Tri stable : à rang égal — tous ceux qu'il n'a pas rangés —, l'ordre des
    // listes est gardé.
    accounts.sort_by_key(rank);
    let excluded: Vec<i64> = accounts
        .iter()
        .map(|account| account.id)
        .filter(|id| wished.excluded.contains(id))
        .collect();
    let counted = || accounts.iter().filter(|account| !excluded.contains(&account.id));

    let total_bank = counted().map(|account| account.balance_bank).sum();
    let total_real = counted().map(|account| account.balance_real).sum();
    let total_final = counted().map(|account| account.balance_final).sum();

    let (from, to) = month_of(day);
    // Les anneaux portent sur les mêmes comptes que les totaux : « toute la
    // fenêtre parle des mêmes comptes » (tranché par Fabrice).
    let ids: Vec<i64> = counted().map(|account| account.id).collect();

    // Les trois statuts, les deux sens : l'accueil ne porte aucun
    // interrupteur, donc rien n'est retiré. `Switches::default()` est
    // exactement ce que F19 montre quand on ne lui a rien éteint.
    let rings = dashboard::dashboard(
        conn,
        &ids,
        &from.to_string(),
        &to.to_string(),
        Switches::default(),
        unclassified_label,
    )?;

    // **La lecture d'ensemble est faite dans tous les cas**, et les deux
    // creusements ne sont demandés que s'ils servent. Un accueil ordinaire —
    // les deux anneaux au niveau des postes — reste donc à une seule requête,
    // ce qui compte : cette fenêtre s'ouvre au lancement du logiciel.
    let deeper = |drill: Drill| -> Result<Option<dashboard::Dashboard>> {
        match drill.budget_line {
            None => Ok(None),
            Some(line) => dashboard::inside_budget_line(
                conn,
                &ids,
                &from.to_string(),
                &to.to_string(),
                Switches::default(),
                unclassified_label,
                line,
            )
            .map(Some),
        }
    };
    let spending = match deeper(spending_drill)? {
        Some(inside) => inside.spending,
        None => rings.spending,
    };
    let earning = match deeper(earning_drill)? {
        Some(inside) => inside.earning,
        None => rings.earning,
    };

    // La courbe, au troisième niveau seulement. `debits` dit de quel côté on
    // est : la carte des dépenses trace des débits, celle des gains des
    // crédits — la même règle que les deux anneaux, pour la même raison.
    let curve = |drill: Drill, debits: bool| -> Result<Vec<DayPoint>> {
        match drill.category {
            None => Ok(Vec::new()),
            Some(category) => dashboard::category_running_total(
                conn,
                &ids,
                from,
                to,
                Switches::default(),
                category,
                debits,
            ),
        }
    };
    // Le nom de la catégorie regardée. Une catégorie supprimée depuis n'a plus
    // de nom : l'en-tête retombe alors sur celui de la nomenclature absente,
    // exactement comme une part « sans ».
    let named = |drill: Drill| -> Result<Option<String>> {
        let Some(category) = drill.category else {
            return Ok(None);
        };
        let found = crate::nomenclatures::list(conn, crate::nomenclatures::Nomenclature::Category)?
            .into_iter()
            .find(|element| element.id == category)
            .map(|element| element.label)
            .unwrap_or_else(|| unclassified_label.to_string());
        Ok(Some(found))
    };

    Ok(Welcome {
        accounts,
        excluded,
        total_bank,
        total_real,
        total_final,
        spending,
        earning,
        spending_curve: curve(spending_drill, true)?,
        earning_curve: curve(earning_drill, false)?,
        spending_category_label: named(spending_drill)?,
        earning_category_label: named(earning_drill)?,
        spending_drill,
        earning_drill,
        from,
        to,
        previous: shift_month(from, -1),
        next: shift_month(from, 1),
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database::{schema, seed};

    const EURO: i64 = 1_000_000;

    fn date(year: i32, month: u32, day: u32) -> NaiveDate {
        NaiveDate::from_ymd_opt(year, month, day).expect("date")
    }

    fn database() -> Connection {
        let conn = Connection::open_in_memory().expect("base en mémoire");
        schema::migrate(&conn).expect("schéma");
        seed::seed_initial_data(&conn).expect("valeurs initiales");
        conn.execute(
            "INSERT INTO PosteBudget (IDPosteBudget, Libelle) VALUES (960, 'Vie courante')",
            [],
        )
        .expect("poste");
        conn.execute(
            "INSERT INTO Categorie (IDCategorie, Libelle, IDPosteBudget) VALUES (970, 'Cat', 960)",
            [],
        )
        .expect("catégorie");
        conn
    }

    #[allow(clippy::too_many_arguments)]
    fn account(conn: &Connection, id: i64, label: &str, closed: bool, bank: i64, real: i64, last: i64) {
        conn.execute(
            "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte, IDBanques, SoldeBanque,
                                 SoldeReel, SoldeFinal, CompteCloture)
             VALUES (?1, ?2, 1, 1, ?3, ?4, ?5, ?6)",
            rusqlite::params![id, label, bank, real, last, i64::from(closed)],
        )
        .expect("compte");
    }

    fn operation(conn: &Connection, id: i64, account_id: i64, day: &str, amount: i64) {
        conn.execute(
            "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte,
                                    IDStatutOperation, IDOperationParent, IDCategorie)
             VALUES (?1, 'OP', ?2, ?3, ?4, 1, 0, 970)",
            rusqlite::params![id, day, amount, account_id],
        )
        .expect("opération");
    }

    /// **La case à cocher d'un compte, et l'ordre des tuiles** (Fabrice,
    /// 07/10/2026) : « le but sera de faire comptabiliser ou non les soldes
    /// dans les trois zones carrées du dessus. Les carrés dans Vos comptes
    /// pourront aussi être déplacés par drag and drop et réordonnés. » — et
    /// les anneaux « doivent suivre les cases à cocher ».
    #[test]
    fn les_comptes_decoches_sortent_des_totaux_et_des_anneaux_mais_restent_montres() {
        let conn = database();
        account(&conn, 1, "CCP", false, 100 * EURO, 110 * EURO, 120 * EURO);
        account(&conn, 2, "Livret", false, 1000 * EURO, 1000 * EURO, 1000 * EURO);
        account(&conn, 3, "Epargne", false, 5 * EURO, 6 * EURO, 7 * EURO);
        account(&conn, 4, "Ancien", true, 9999 * EURO, 9999 * EURO, 9999 * EURO);
        operation(&conn, 1, 1, "2026-03-05", -30 * EURO);
        operation(&conn, 2, 2, "2026-03-06", -400 * EURO);
        operation(&conn, 3, 3, "2026-03-07", 50 * EURO);
        let read = || {
            welcome(&conn, date(2026, 3, 15), "Sans", Drill::default(), Drill::default()).unwrap()
        };
        let labels = |shown: &Welcome| -> Vec<String> {
            shown.accounts.iter().map(|one| one.label.clone()).collect()
        };
        let spent = |shown: &Welcome| -> i64 { shown.spending.iter().map(|part| part.amount).sum() };
        let earned = |shown: &Welcome| -> i64 { shown.earning.iter().map(|part| part.amount).sum() };

        // Rien de réglé : l'accueil de toujours.
        let born = read();
        assert_eq!(labels(&born).len(), 3);
        assert!(born.excluded.is_empty());
        assert_eq!(born.total_bank, 1105 * EURO);
        let (all_spent, all_earned) = (spent(&born), earned(&born));
        assert_ne!(all_spent, 0);
        assert_ne!(all_earned, 0);

        // Le Livret décoché, et l'épargne glissée en tête. Le compte clôturé et
        // un compte disparu sont cités : ils ne comptent pour rien.
        let order: Vec<i64> = vec![3, 99, 4, 1];
        crate::preferences::set_welcome_accounts(
            &conn,
            &crate::preferences::WelcomeAccounts { order, excluded: vec![2, 4, 99] },
        )
        .unwrap();
        let shown = read();
        // L'ordre voulu d'abord ; le Livret, qu'on n'a pas rangé, vient après.
        assert_eq!(labels(&shown), vec!["Epargne", "CCP", "Livret"]);
        // Il est toujours montré, et dit décoché.
        assert_eq!(shown.excluded, vec![2]);
        assert_eq!(shown.total_bank, 105 * EURO);
        assert_eq!(shown.total_real, 116 * EURO);
        assert_eq!(shown.total_final, 127 * EURO);
        // Les anneaux ont perdu ses 400 de dépenses, et rien d'autre.
        assert_eq!((spent(&shown) - all_spent).abs(), 400 * EURO);
        assert_eq!(earned(&shown), all_earned);

        // Tout décoché : des zéros, des anneaux vides, et rien ne casse.
        crate::preferences::set_welcome_accounts(
            &conn,
            &crate::preferences::WelcomeAccounts { order: vec![], excluded: vec![1, 2, 3] },
        )
        .unwrap();
        let nothing = read();
        assert_eq!(labels(&nothing).len(), 3);
        // Dans l'ordre où ils sont montrés — celui des listes, faute de mieux.
        assert_eq!(nothing.excluded.len(), 3);
        assert_eq!((nothing.total_bank, nothing.total_real, nothing.total_final), (0, 0, 0));
        assert!(nothing.spending.is_empty() && nothing.earning.is_empty());

        // Un compte né depuis vient en dernier, et il compte.
        crate::preferences::set_welcome_accounts(
            &conn,
            &crate::preferences::WelcomeAccounts { order: vec![3, 2, 1], excluded: vec![1] },
        )
        .unwrap();
        account(&conn, 5, "Nouveau", false, EURO, EURO, EURO);
        let later = read();
        assert_eq!(labels(&later), vec!["Epargne", "Livret", "CCP", "Nouveau"]);
        assert_eq!(later.total_bank, 1006 * EURO);

        // Et la remise à zéro du confort rend l'accueil de naissance.
        crate::preferences::reset_comfort(&conn).unwrap();
        let again = read();
        assert!(again.excluded.is_empty());
        assert_eq!(again.total_bank, 1106 * EURO);
    }

    /// **L'anneau creusé montre les catégories du poste, et rien d'autre.**
    ///
    /// Demandé par Fabrice le 03/08/2026 : un clic sur un secteur ouvre la
    /// répartition par catégorie de ce poste-là. Ce test tient les deux bouts —
    /// que le creusement ne montre que ce qui appartient au poste, et que **la
    /// somme du creusé vaut le secteur d'où l'on vient**. Sans cette seconde
    /// vérification, l'anneau pourrait s'ouvrir sur un total différent de la
    /// part cliquée, et rien à l'écran ne le dirait.
    #[test]
    fn un_anneau_creuse_montre_les_categories_du_poste_et_leur_somme_tient() {
        let conn = database();
        account(&conn, 1, "Compte", false, 0, 0, 0);
        // Un second poste, avec deux catégories, pour qu'il y ait de quoi se
        // tromper de côté.
        conn.execute(
            "INSERT INTO PosteBudget (IDPosteBudget, Libelle) VALUES (961, 'Loisirs')",
            [],
        )
        .expect("poste");
        for (id, label) in [(971, "Cinéma"), (972, "Livres")] {
            conn.execute(
                "INSERT INTO Categorie (IDCategorie, Libelle, IDPosteBudget)
                 VALUES (?1, ?2, 961)",
                rusqlite::params![id, label],
            )
            .expect("catégorie");
        }
        let spend = |id: i64, category: i64, amount: i64| {
            conn.execute(
                "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte,
                                        IDStatutOperation, IDOperationParent, IDCategorie)
                 VALUES (?1, 'OP', '2026-08-12', ?2, 1, 1, 0, ?3)",
                rusqlite::params![id, amount, category],
            )
            .expect("opération");
        };
        spend(1, 970, -100 * EURO); // Vie courante
        spend(2, 971, -30 * EURO); // Loisirs / Cinéma
        spend(3, 972, -20 * EURO); // Loisirs / Livres
        spend(4, 971, -5 * EURO); // Loisirs / Cinéma encore

        // Sans creusement : deux postes.
        let large = welcome(&conn, date(2026, 8, 3), "Sans poste", Drill::default(), Drill::default()).expect("accueil");
        assert_eq!(large.spending.len(), 2);
        let loisirs = large
            .spending
            .iter()
            .find(|part| part.label == "Loisirs")
            .expect("le poste Loisirs");
        assert_eq!(loisirs.amount, 55 * EURO);

        // Creusé dans Loisirs : ses deux catégories, et **rien de Vie
        // courante**.
        let inside =
            welcome(&conn, date(2026, 8, 3), "Sans poste", Drill { budget_line: Some(961), category: None }, Drill::default()).expect("accueil");
        assert_eq!(inside.spending_drill.budget_line, Some(961));
        let noms: Vec<&str> = inside.spending.iter().map(|part| part.label.as_str()).collect();
        assert_eq!(noms, vec!["Cinéma", "Livres"], "du plus lourd au plus léger");
        assert_eq!(inside.spending.iter().map(|part| part.amount).sum::<i64>(), loisirs.amount);

        // Et l'autre anneau n'a pas bougé : les deux se creusent séparément.
        assert_eq!(inside.earning_drill.budget_line, None);
    }

    /// **La courbe couvre tout le mois, et finit sur le total de la
    /// catégorie.**
    ///
    /// Troisième niveau, demandé par Fabrice le 03/08/2026. Deux choses sont
    /// vérifiées ici, et la seconde est la plus importante : un point par jour
    /// **même les jours sans rien** — sinon les paliers disparaissent et la
    /// courbe ment sur le rythme —, et **le dernier point vaut exactement le
    /// secteur d'où l'on vient**. Sans cette égalité, la courbe et l'anneau
    /// diraient deux chiffres différents pour la même catégorie, et rien à
    /// l'écran ne le signalerait.
    #[test]
    fn la_courbe_couvre_le_mois_entier_et_finit_sur_le_total_de_la_categorie() {
        let conn = database();
        account(&conn, 1, "Compte", false, 0, 0, 0);
        // Trois dépenses de la catégorie 970, espacées dans le mois.
        operation(&conn, 1, 1, "2026-08-03", -40 * EURO);
        operation(&conn, 2, 1, "2026-08-03", -10 * EURO);
        operation(&conn, 3, 1, "2026-08-20", -50 * EURO);

        let dedans = Drill { budget_line: Some(960), category: Some(970) };
        let shown = welcome(&conn, date(2026, 8, 3), "Sans poste", dedans, Drill::default())
            .expect("accueil");

        // Août a trente et un jours : il y a trente et un points, pas trois.
        assert_eq!(shown.spending_curve.len(), 31, "un point par jour du mois");
        assert_eq!(shown.spending_curve[0].day, "2026-08-01");
        assert_eq!(shown.spending_curve[30].day, "2026-08-31");

        // Le cumul monte par paliers et ne redescend jamais.
        assert_eq!(shown.spending_curve[0].amount, 0, "le 1er août, rien encore");
        assert_eq!(shown.spending_curve[2].amount, 50 * EURO, "le 3, les deux premières");
        assert_eq!(shown.spending_curve[18].amount, 50 * EURO, "le 19, toujours rien de plus");
        assert_eq!(shown.spending_curve[19].amount, 100 * EURO, "le 20, la troisième");
        assert_eq!(shown.spending_curve[30].amount, 100 * EURO, "et jusqu'au bout");

        // **Le dernier point vaut le secteur d'où l'on vient.**
        let anneau = welcome(
            &conn,
            date(2026, 8, 3),
            "Sans poste",
            Drill { budget_line: Some(960), category: None },
            Drill::default(),
        )
        .expect("accueil");
        let part = anneau
            .spending
            .iter()
            .find(|part| part.id == 970)
            .expect("la catégorie dans l'anneau");
        assert_eq!(shown.spending_curve[30].amount, part.amount);

        // Et l'en-tête sait se nommer.
        assert_eq!(shown.spending_category_label.as_deref(), Some("Cat"));
        assert_eq!(shown.earning_category_label, None);
    }

    /// **Un mois sans rien laisse l'anneau creusé où il est.**
    ///
    /// Décision de Fabrice, 03/08/2026 : « un anneau vide gris clair avec le
    /// message, et on reste dans Alimentation — le mois suivant la retrouve ».
    /// Le noyau tient sa moitié de cette promesse : il rend une liste vide
    /// **et** garde la sélection, pour que la fenêtre n'ait pas à décider de
    /// remonter d'elle-même.
    #[test]
    fn un_mois_sans_rien_ne_fait_pas_sortir_du_poste_creuse() {
        let conn = database();
        account(&conn, 1, "Compte", false, 0, 0, 0);
        operation(&conn, 1, 1, "2026-08-12", -100 * EURO);

        let vide = welcome(&conn, date(2026, 5, 3), "Sans poste", Drill { budget_line: Some(960), category: None }, Drill::default()).expect("accueil");

        assert!(vide.spending.is_empty(), "mai n'a rien");
        assert_eq!(vide.spending_drill.budget_line, Some(960), "on reste dans le poste");
    }

    /// **Le mois se prend par ses deux bouts, février compris.** C'est le seul
    /// calcul que ce module fait lui-même, donc le seul qu'il peut rater.
    #[test]
    fn a_month_is_taken_from_its_first_day_to_its_last() {
        assert_eq!(month_of(date(2026, 8, 17)), (date(2026, 8, 1), date(2026, 8, 31)));
        assert_eq!(month_of(date(2026, 2, 1)), (date(2026, 2, 1), date(2026, 2, 28)));
        // 2024 est bissextile, 2026 ne l'est pas : la table de longueurs de
        // mois se serait trompée ici.
        assert_eq!(month_of(date(2024, 2, 9)), (date(2024, 2, 1), date(2024, 2, 29)));
        // Décembre change d'année, et c'est la seule branche du calcul.
        assert_eq!(month_of(date(2026, 12, 31)), (date(2026, 12, 1), date(2026, 12, 31)));
    }

    /// **Feuilleter recule et avance d'un mois, pas de treize.** Janvier moins
    /// un mois change d'année, et c'est le seul endroit où ce module peut se
    /// tromper : `div_euclid` est là pour cela.
    #[test]
    fn leafing_moves_one_month_at_a_time_across_the_new_year() {
        assert_eq!(shift_month(date(2026, 8, 1), -1), date(2026, 7, 1));
        assert_eq!(shift_month(date(2026, 8, 1), 1), date(2026, 9, 1));
        assert_eq!(shift_month(date(2026, 1, 1), -1), date(2025, 12, 1));
        assert_eq!(shift_month(date(2026, 12, 1), 1), date(2027, 1, 1));
        // Depuis n'importe quel jour du mois, et non le premier seulement.
        assert_eq!(shift_month(date(2026, 3, 31), -1), date(2026, 2, 1));
        // Douze pas en arrière font une année pleine, sans dérive.
        let mut walked = date(2026, 8, 1);
        for _ in 0..12 {
            walked = shift_month(walked, -1);
        }
        assert_eq!(walked, date(2025, 8, 1));
    }

    /// **Au bord, la flèche ne fait rien.** On impose, on ne rejette pas : le
    /// voisin d'un mois extrême est ce mois-là, si bien que la fenêtre n'a
    /// aucune erreur à montrer pour un geste anodin.
    #[test]
    fn at_the_edges_the_neighbour_is_the_month_itself() {
        assert_eq!(shift_month(date(1950, 1, 1), -1), date(1950, 1, 1));
        assert_eq!(shift_month(date(2550, 12, 1), 1), date(2550, 12, 1));
        // Et un bond démesuré ne sort pas non plus des bornes.
        assert_eq!(shift_month(date(2026, 8, 1), -100_000), date(1950, 1, 1));
        assert_eq!(shift_month(date(2026, 8, 1), 100_000), date(2550, 12, 1));
    }

    /// L'accueil rend les deux voisins du mois qu'il montre : la fenêtre n'a
    /// jamais à les calculer.
    #[test]
    fn the_welcome_carries_the_month_before_and_the_month_after() {
        let conn = database();
        let shown = welcome(&conn, date(2026, 1, 17), "Sans poste", Drill::default(), Drill::default()).expect("accueil");
        assert_eq!(shown.from, date(2026, 1, 1));
        assert_eq!(shown.previous, date(2025, 12, 1));
        assert_eq!(shown.next, date(2026, 2, 1));
    }

    /// **Feuilleter change les anneaux et rien d'autre.** Un solde est
    /// cumulatif depuis l'ouverture du compte : le faire varier avec le mois
    /// regardé serait un contresens, et un contresens qui ne se voit pas.
    #[test]
    fn leafing_moves_the_rings_and_never_the_balances() {
        let conn = database();
        account(&conn, 1, "Compte", false, 1000 * EURO, 900 * EURO, 800 * EURO);
        operation(&conn, 1, 1, "2026-07-10", -60 * EURO);
        operation(&conn, 2, 1, "2026-08-10", -25 * EURO);

        let august = welcome(&conn, date(2026, 8, 3), "Sans poste", Drill::default(), Drill::default()).expect("accueil");
        let july = welcome(&conn, august.previous, "Sans poste", Drill::default(), Drill::default()).expect("accueil");

        assert_eq!(august.spending[0].amount, 25 * EURO);
        assert_eq!(july.spending[0].amount, 60 * EURO, "le mois d'avant a ses propres dépenses");
        assert_eq!(
            (july.total_bank, july.total_real, july.total_final),
            (august.total_bank, august.total_real, august.total_final),
            "les soldes ont bougé avec le mois, ce qu'un solde ne fait jamais"
        );
    }

    /// **Le croisement de l'accueil** : ses trois totaux sont exactement la
    /// somme des comptes qu'il montre. Rien ne les calcule deux fois, et le
    /// test l'exige quand même — c'est là que la fenêtre d'accueil et F07
    /// pourraient un jour se mettre à dire deux choses différentes.
    #[test]
    fn the_three_totals_are_the_sum_of_the_accounts_shown() {
        let conn = database();
        account(&conn, 1, "Compte Courant", false, 1549 * EURO, 1120 * EURO, -287 * EURO);
        account(&conn, 2, "Livret A", false, 23422 * EURO, 23422 * EURO, 23422 * EURO);

        let shown = welcome(&conn, date(2026, 8, 3), "Sans poste", Drill::default(), Drill::default()).expect("accueil");

        assert_eq!(shown.total_bank, shown.accounts.iter().map(|a| a.balance_bank).sum::<i64>());
        assert_eq!(shown.total_real, shown.accounts.iter().map(|a| a.balance_real).sum::<i64>());
        assert_eq!(shown.total_final, shown.accounts.iter().map(|a| a.balance_final).sum::<i64>());
        assert_eq!(shown.total_bank, 24971 * EURO);
        assert_eq!(shown.total_final, 23135 * EURO);
    }

    /// Un compte clôturé n'est ni dans la liste ni dans les totaux — la règle
    /// de F07, reprise telle quelle.
    #[test]
    fn a_closed_account_is_neither_shown_nor_added_up() {
        let conn = database();
        account(&conn, 1, "Ouvert", false, 100 * EURO, 100 * EURO, 100 * EURO);
        account(&conn, 2, "Fermé", true, 900 * EURO, 900 * EURO, 900 * EURO);

        let shown = welcome(&conn, date(2026, 8, 3), "Sans poste", Drill::default(), Drill::default()).expect("accueil");

        assert_eq!(shown.accounts.len(), 1);
        assert_eq!(shown.accounts[0].label, "Ouvert");
        assert_eq!(shown.total_bank, 100 * EURO);
    }

    /// **Et ses opérations non plus.** Un compte clôturé sortant de la liste,
    /// il sort aussi des anneaux : sans quoi les secteurs porteraient un mois
    /// de dépenses d'un compte que la fenêtre ne montre pas.
    #[test]
    fn a_closed_account_keeps_its_operations_out_of_the_rings() {
        let conn = database();
        account(&conn, 1, "Ouvert", false, 0, 0, 0);
        account(&conn, 2, "Fermé", true, 0, 0, 0);
        operation(&conn, 1, 1, "2026-08-04", -60 * EURO);
        operation(&conn, 2, 2, "2026-08-05", -900 * EURO);

        let shown = welcome(&conn, date(2026, 8, 3), "Sans poste", Drill::default(), Drill::default()).expect("accueil");

        assert_eq!(shown.spending.len(), 1);
        assert_eq!(shown.spending[0].amount, 60 * EURO);
    }

    /// L'accueil ne regarde que le mois en cours : ce qui est avant ou après
    /// n'entre pas dans les anneaux, bornes comprises.
    #[test]
    fn only_the_current_month_reaches_the_rings() {
        let conn = database();
        account(&conn, 1, "Compte", false, 0, 0, 0);
        operation(&conn, 1, 1, "2026-07-31", -10 * EURO);
        operation(&conn, 2, 1, "2026-08-01", -20 * EURO);
        operation(&conn, 3, 1, "2026-08-31", -40 * EURO);
        operation(&conn, 4, 1, "2026-09-01", -80 * EURO);

        let shown = welcome(&conn, date(2026, 8, 17), "Sans poste", Drill::default(), Drill::default()).expect("accueil");

        let spent: i64 = shown.spending.iter().map(|part| part.amount).sum();
        assert_eq!(spent, 60 * EURO, "les deux bornes sont dedans, le reste dehors");
        assert_eq!(shown.from, date(2026, 8, 1));
        assert_eq!(shown.to, date(2026, 8, 31));
    }

    /// **Une base neuve n'est pas une panne.** Sans un compte, l'accueil rend
    /// zéro et deux anneaux vides, et c'est à la fenêtre de le dire avec des
    /// mots. Ce test existe parce que `dashboard` interrogé sans compte
    /// pourrait tout aussi bien répondre sur toute la base.
    #[test]
    fn a_fresh_database_answers_zero_rather_than_failing() {
        let conn = database();
        let shown = welcome(&conn, date(2026, 8, 3), "Sans poste", Drill::default(), Drill::default()).expect("accueil");

        assert!(shown.accounts.is_empty());
        assert_eq!((shown.total_bank, shown.total_real, shown.total_final), (0, 0, 0));
        assert!(shown.spending.is_empty() && shown.earning.is_empty());
    }

    /// Les deux sens se rangent chacun de son côté, comme en F19.
    #[test]
    fn what_was_spent_and_what_was_earned_do_not_mix() {
        let conn = database();
        account(&conn, 1, "Compte", false, 0, 0, 0);
        operation(&conn, 1, 1, "2026-08-04", -300 * EURO);
        operation(&conn, 2, 1, "2026-08-06", 2480 * EURO);

        let shown = welcome(&conn, date(2026, 8, 3), "Sans poste", Drill::default(), Drill::default()).expect("accueil");

        assert_eq!(shown.spending.len(), 1);
        assert_eq!(shown.spending[0].amount, 300 * EURO, "une part d'anneau est positive");
        assert_eq!(shown.earning.len(), 1);
        assert_eq!(shown.earning[0].amount, 2480 * EURO);
    }
}
