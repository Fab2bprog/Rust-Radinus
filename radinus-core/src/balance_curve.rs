//! F25 — l'évolution du solde, jour par jour.
//!
//! Référence : `04_SPECIFICATIONS_FENETRES.md` F25, `PLAN_ACTION.md` §6.4, et
//! les règles que Fabrice a dictées le 26/07/2026 — elles sont recopiées ici
//! parce que c'est le module qui doit les tenir, pas la fenêtre :
//!
//!   1. **une courbe par compte choisi**, plus **une courbe du total** des
//!      soldes — celle-ci n'existant qu'à partir de deux comptes, puisque avec
//!      un seul elle ferait doublon avec sa propre courbe ;
//!   2. **les trous se remplissent** : il n'y a pas d'opération tous les
//!      jours, mais un solde existe tous les jours. La courbe ne s'interrompt
//!      jamais ;
//!   3. **en escalier, jamais en pente** : le solde garde sa valeur jusqu'à
//!      l'opération suivante, où il saute d'un coup. « C'est ce qui est de plus
//!      juste » — et c'est vrai : une pente ferait croire à un mouvement les
//!      jours où il ne s'est rien passé.
//!
//! **Ce module ne rend qu'un point par changement**, pas un par jour. Ce n'est
//! pas une approximation, c'est la définition même d'un escalier : entre deux
//! marches, la valeur est celle de la marche précédente, et la fenêtre le
//! dessine ainsi. Un point par jour aurait été identique à l'écran et aurait
//! fait 219 000 points par compte sur la période « Toutes ».
//!
//! Le solde suivi est le **solde final** : les trois reports du compte plus
//! toutes ses opérations de premier niveau, sans filtre de statut — la même
//! définition que `balances::update_final_balance`. Les sous-opérations n'y
//! entrent pas : ventiler ne déplace pas l'argent du compte.

use crate::domain::NaiveDate;
use time_compute::Datelike;
use rusqlite::{Connection, Result};

/// Une marche : à partir de ce jour, le solde vaut cette valeur.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Step {
    pub date: NaiveDate,
    pub value: i64,
}

/// Une courbe : un compte, ou le total.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Curve {
    /// La clef du compte, ou `0` pour la courbe du total.
    pub account_id: i64,
    pub label: String,
    /// **Le premier point est toujours le premier jour de la période**, et le
    /// dernier toujours son dernier jour : la courbe couvre la période entière
    /// même si aucune opération n'y est tombée.
    pub steps: Vec<Step>,
    pub is_total: bool,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Curves {
    pub curves: Vec<Curve>,
    /// Les bornes verticales, pour que la fenêtre n'ait pas à les chercher.
    /// Égales quand tout est plat — la fenêtre écartera l'échelle elle-même.
    pub lowest: i64,
    pub highest: i64,
}

/// Les courbes des comptes choisis sur une période.
pub fn balance_curves(
    conn: &Connection,
    accounts: &[i64],
    from: NaiveDate,
    to: NaiveDate,
    total_label: &str,
) -> Result<Curves> {
    let mut curves = Vec::new();
    if accounts.is_empty() || to < from {
        return Ok(Curves {
            curves,
            lowest: 0,
            highest: 0,
        });
    }

    for account in accounts {
        if let Some(curve) = one_account(conn, *account, from, to)? {
            curves.push(curve);
        }
    }

    // **La courbe du total n'existe qu'à plusieurs** (règle de Fabrice) : avec
    // un seul compte elle recopierait sa courbe, trait pour trait.
    if curves.len() > 1 {
        curves.push(total_of(&curves, from, to, total_label));
    }

    let (lowest, highest) = curves
        .iter()
        .flat_map(|curve| curve.steps.iter().map(|step| step.value))
        .fold((i64::MAX, i64::MIN), |(low, high), value| {
            (low.min(value), high.max(value))
        });

    Ok(Curves {
        lowest: if lowest == i64::MAX { 0 } else { lowest },
        highest: if highest == i64::MIN { 0 } else { highest },
        curves,
    })
}

/// La courbe d'un compte, ou `None` si le compte n'existe pas.
fn one_account(
    conn: &Connection,
    account: i64,
    from: NaiveDate,
    to: NaiveDate,
) -> Result<Option<Curve>> {
    let found: Option<(String, i64)> = match conn.query_row(
        "SELECT Libelle, ReportPointe + ReportEngage + ReportPrevu
         FROM Compte WHERE IDCompte = ?1",
        [account],
        |row| Ok((row.get(0)?, row.get(1)?)),
    ) {
        Ok(row) => Some(row),
        Err(rusqlite::Error::QueryReturnedNoRows) => None,
        Err(other) => return Err(other),
    };
    let Some((label, carried)) = found else {
        return Ok(None);
    };

    // **Le solde au premier jour de la période n'est pas zéro** : c'est tout ce
    // qui s'est passé avant. Sans cela, la courbe d'un mois de juillet partirait
    // de rien, ce qui serait faux de tout l'historique du compte.
    let before: i64 = conn.query_row(
        "SELECT COALESCE(SUM(Montant), 0)
         FROM Operation
         WHERE IDCompte = ?1 AND IDOperationParent = 0
           AND Date IS NOT NULL AND Date < ?2",
        rusqlite::params![account, from.to_string()],
        |row| row.get(0),
    )?;

    // Les mouvements de la période, un total par jour : plusieurs opérations le
    // même jour ne font qu'une marche, celle du solde à la fin de ce jour-là.
    let mut statement = conn.prepare(
        "SELECT Date, SUM(Montant)
         FROM Operation
         WHERE IDCompte = ?1 AND IDOperationParent = 0
           AND Date IS NOT NULL AND Date >= ?2 AND Date <= ?3
         GROUP BY Date
         ORDER BY Date",
    )?;
    let mut rows = statement.query(rusqlite::params![
        account,
        from.to_string(),
        to.to_string()
    ])?;

    let mut running = carried + before;
    let mut steps = vec![Step {
        date: from,
        value: running,
    }];
    while let Some(row) = rows.next()? {
        let day: String = row.get(0)?;
        let moved: i64 = row.get(1)?;
        running += moved;
        let Ok(day) = day.parse::<NaiveDate>() else {
            continue;
        };
        if day == from {
            // Le premier jour porte déjà sa marche : on la corrige plutôt que
            // d'en poser une seconde au même endroit.
            steps[0].value = running;
        } else {
            steps.push(Step { date: day, value: running });
        }
    }
    // Et la période va jusqu'à son dernier jour, même si plus rien n'a bougé.
    if steps.last().map(|step| step.date) != Some(to) {
        steps.push(Step { date: to, value: running });
    }

    Ok(Some(Curve {
        account_id: account,
        label,
        steps,
        is_total: false,
    }))
}

/// La courbe du total : la somme des courbes, marche par marche.
///
/// Ses marches sont **l'union** de celles des comptes : le total change chaque
/// fois que l'un d'eux change. Entre deux marches, chaque compte garde sa
/// valeur — c'est l'escalier, appliqué à l'addition.
fn total_of(curves: &[Curve], from: NaiveDate, to: NaiveDate, label: &str) -> Curve {
    let mut days: Vec<NaiveDate> = curves
        .iter()
        .flat_map(|curve| curve.steps.iter().map(|step| step.date))
        .collect();
    days.push(from);
    days.push(to);
    days.sort();
    days.dedup();

    let steps = days
        .into_iter()
        .map(|day| Step {
            date: day,
            value: curves.iter().map(|curve| value_at(curve, day)).sum(),
        })
        .collect();

    Curve {
        account_id: 0,
        label: label.to_string(),
        steps,
        is_total: true,
    }
}

/// Ce que vaut une courbe un jour donné : la dernière marche à cette date ou
/// avant. C'est la règle de l'escalier, et c'est aussi ce dont l'infobulle a
/// besoin.
pub fn value_at(curve: &Curve, day: NaiveDate) -> i64 {
    let mut value = curve.steps.first().map(|step| step.value).unwrap_or(0);
    for step in &curve.steps {
        if step.date > day {
            break;
        }
        value = step.value;
    }
    value
}


// --- Le millésime, et le décalage d'un an --------------------------------
//
// Deux règles données par Fabrice le 26/07/2026, après qu'il eut lui-même
// soulevé le cas de la semaine 53 :
//
//   * **le millésime affiché suit la norme ISO 8601** quand la période enjambe
//     deux années : une semaine appartient à l'année où tombe son **jeudi**.
//     La semaine du lundi 29 décembre 2025 au dimanche 4 janvier 2026 a son
//     jeudi le 1er janvier, elle est donc de 2026 ;
//   * **les horloges gardent la semaine**, plutôt que d'ajouter douze mois aux
//     deux dates : le 29/12/2025 est un lundi, le 29/12/2026 un mardi. On
//     décale d'un an *le numéro de semaine ISO*, et la semaine 53 d'une année
//     qui n'en a que 52 devient la 52 — on impose, on ne rejette pas, comme
//     pour les bornes 1950-2550.

/// L'année à afficher pour une période.
///
/// Une période enfermée dans une seule année porte la sienne. Une semaine à
/// cheval porte celle de son jeudi. Tout le reste — « Toutes », de 1950 à
/// 2550 — porte l'année de son début, faute de mieux : le millésime n'y a de
/// toute façon aucun sens, et les deux dates affichées lèvent l'ambiguïté.
pub fn year_of(from: NaiveDate, to: NaiveDate) -> i32 {
    if from.year() == to.year() {
        return from.year();
    }
    if is_one_week(from, to) {
        // Le jeudi de la semaine, c'est-à-dire le lundi plus trois jours.
        let mut thursday = from;
        for _ in 0..3 {
            thursday = thursday.succ_opt().unwrap_or(thursday);
        }
        return thursday.year();
    }
    from.year()
}

/// Sept jours du lundi au dimanche : la seule période des neuf du menu qui
/// puisse enjamber deux années sans être une année entière.
fn is_one_week(from: NaiveDate, to: NaiveDate) -> bool {
    let mut last = from;
    for _ in 0..6 {
        last = match last.succ_opt() {
            Some(day) => day,
            None => return false,
        };
    }
    last == to && from.weekday().num_days_from_monday() == 0
}

/// Décale une période, ou la porte sur une autre année.
///
/// `by` est le nombre d'années à ajouter — les horloges envoient `+1` ou `-1`.
/// `onto` porte la période sur une année précise, ce que fait le clic sur le
/// millésime ; il l'emporte sur `by`.
pub fn shift_period(
    from: NaiveDate,
    to: NaiveDate,
    by: i32,
    onto: Option<i32>,
) -> (NaiveDate, NaiveDate) {
    let current = year_of(from, to);
    let wanted = crate::statistics::year_within_bounds(match onto {
        Some(year) => year,
        None => current + by,
    });
    if wanted == current {
        return (from, to);
    }

    if is_one_week(from, to) {
        // **Une semaine reste une semaine** : on garde son numéro ISO, ramené
        // au nombre de semaines que l'année d'arrivée possède réellement.
        let week = iso_week_of(from).min(weeks_in_iso_year(wanted));
        let monday = monday_of_iso_week(wanted, week);
        let mut sunday = monday;
        for _ in 0..6 {
            sunday = sunday.succ_opt().unwrap_or(sunday);
        }
        return (monday, sunday);
    }

    // Tout le reste garde ses jours et ses mois. Le 29 février d'une année
    // bissextile portée sur une année qui ne l'est pas retombe au 28 : c'est
    // la règle que `time_compute` applique déjà partout ailleurs.
    let moved = wanted - current;
    (shift_years(from, moved), shift_years(to, moved))
}

fn shift_years(date: NaiveDate, years: i32) -> NaiveDate {
    let wanted = date.year() + years;
    let day = date.day();
    let mut tried = day;
    loop {
        if let Some(moved) = NaiveDate::from_ymd_opt(wanted, date.month(), tried) {
            return moved;
        }
        if tried <= 28 {
            return date;
        }
        tried -= 1;
    }
}

/// Le numéro de semaine ISO d'un lundi.
fn iso_week_of(monday: NaiveDate) -> u32 {
    // Le jeudi de cette semaine décide de l'année ISO ; la semaine 1 est celle
    // qui contient le premier jeudi de janvier.
    let mut thursday = monday;
    for _ in 0..3 {
        thursday = thursday.succ_opt().unwrap_or(thursday);
    }
    let first = first_iso_monday(thursday.year());
    let mut week = 1;
    let mut walk = first;
    while walk < monday {
        walk = plus_days(walk, 7);
        week += 1;
    }
    week
}

/// Le lundi de la semaine 1 d'une année ISO : celle qui contient son premier
/// jeudi.
fn first_iso_monday(year: i32) -> NaiveDate {
    let fourth = NaiveDate::from_ymd_opt(year, 1, 4).expect("le 4 janvier existe toujours");
    let back = fourth.weekday().num_days_from_monday();
    let mut monday = fourth;
    for _ in 0..back {
        monday = monday.pred_opt().unwrap_or(monday);
    }
    monday
}

fn monday_of_iso_week(year: i32, week: u32) -> NaiveDate {
    plus_days(first_iso_monday(year), 7 * (week.saturating_sub(1) as i64))
}

/// Combien de semaines une année ISO compte : 52, ou 53 quand elle commence un
/// jeudi, ou qu'elle est bissextile et commence un mercredi.
fn weeks_in_iso_year(year: i32) -> u32 {
    let next = first_iso_monday(year + 1);
    let first = first_iso_monday(year);
    let mut weeks = 0;
    let mut walk = first;
    while walk < next {
        walk = plus_days(walk, 7);
        weeks += 1;
    }
    weeks
}

fn plus_days(date: NaiveDate, days: i64) -> NaiveDate {
    let mut moved = date;
    for _ in 0..days {
        moved = moved.succ_opt().unwrap_or(moved);
    }
    moved
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database::{schema, seed};

    const EURO: i64 = 1_000_000;

    fn day(text: &str) -> NaiveDate {
        text.parse().expect("une date")
    }

    fn database() -> Connection {
        let conn = Connection::open_in_memory().expect("base en mémoire");
        schema::migrate(&conn).expect("schéma");
        seed::seed_initial_data(&conn).expect("valeurs initiales");
        for (id, label, report) in [(1, "CCP", 100 * EURO), (2, "Livret A", 500 * EURO)] {
            conn.execute(
                "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte, IDBanques, ReportPointe)
                 VALUES (?1, ?2, 1, 1, ?3)",
                rusqlite::params![id, label, report],
            )
            .expect("compte");
        }
        conn
    }

    fn add(conn: &Connection, id: i64, account: i64, date: &str, amount: i64, parent: i64) {
        conn.execute(
            "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte,
                                    IDStatutOperation, IDOperationParent)
             VALUES (?1, 'OP', ?2, ?3, ?4, 1, ?5)",
            rusqlite::params![id, date, amount, account, parent],
        )
        .expect("opération");
    }

    fn curves(conn: &Connection, accounts: &[i64], from: &str, to: &str) -> Curves {
        balance_curves(conn, accounts, day(from), day(to), "Total").expect("courbes")
    }

    fn curve<'a>(built: &'a Curves, label: &str) -> &'a Curve {
        built
            .curves
            .iter()
            .find(|curve| curve.label == label)
            .unwrap_or_else(|| panic!("courbe « {label} » absente"))
    }

    /// **Les trous se remplissent, et en escalier** : c'est la règle de
    /// Fabrice, et c'est ce que ce test vérifie jour par jour, y compris les
    /// jours où il ne s'est rien passé.
    #[test]
    fn the_balance_holds_its_value_until_the_next_operation() {
        let conn = database();
        add(&conn, 1, 1, "2026-03-10", -30 * EURO, 0);
        add(&conn, 2, 1, "2026-03-25", 50 * EURO, 0);

        let built = curves(&conn, &[1], "2026-03-01", "2026-03-31");
        let line = curve(&built, "CCP");

        // Le 1er mars : le report, rien de plus.
        assert_eq!(value_at(line, day("2026-03-01")), 100 * EURO);
        // La veille de la première opération : toujours rien.
        assert_eq!(value_at(line, day("2026-03-09")), 100 * EURO);
        // Le jour même : le saut.
        assert_eq!(value_at(line, day("2026-03-10")), 70 * EURO);
        // Les quinze jours suivants : plat, pas une pente.
        for date in ["2026-03-11", "2026-03-17", "2026-03-24"] {
            assert_eq!(
                value_at(line, day(date)),
                70 * EURO,
                "le {date} la courbe a bougé sans qu'aucune opération ne l'y oblige"
            );
        }
        assert_eq!(value_at(line, day("2026-03-25")), 120 * EURO);
        assert_eq!(value_at(line, day("2026-03-31")), 120 * EURO);

        // Et la courbe couvre la période entière, du premier au dernier jour.
        assert_eq!(line.steps.first().expect("un début").date, day("2026-03-01"));
        assert_eq!(line.steps.last().expect("une fin").date, day("2026-03-31"));
    }

    /// Le solde du premier jour n'est pas zéro : c'est tout ce qui s'est passé
    /// avant la période. Un mois de juillet ne part pas de rien.
    #[test]
    fn the_period_starts_from_everything_that_came_before_it() {
        let conn = database();
        add(&conn, 1, 1, "2025-11-04", -40 * EURO, 0);
        add(&conn, 2, 1, "2026-07-10", -10 * EURO, 0);

        let line = &curves(&conn, &[1], "2026-07-01", "2026-07-31").curves[0];
        assert_eq!(value_at(line, day("2026-07-01")), 60 * EURO);
        assert_eq!(value_at(line, day("2026-07-31")), 50 * EURO);
    }

    /// **La courbe du total n'existe qu'à partir de deux comptes** (règle de
    /// Fabrice) : avec un seul, elle recopierait sa courbe.
    #[test]
    fn the_total_curve_appears_only_when_several_accounts_are_chosen() {
        let conn = database();
        add(&conn, 1, 1, "2026-03-10", -30 * EURO, 0);

        let alone = curves(&conn, &[1], "2026-03-01", "2026-03-31");
        assert_eq!(alone.curves.len(), 1);
        assert!(!alone.curves.iter().any(|curve| curve.is_total));

        let together = curves(&conn, &[1, 2], "2026-03-01", "2026-03-31");
        assert_eq!(together.curves.len(), 3, "deux comptes et leur total");
        assert!(together.curves.last().expect("la dernière").is_total);
    }

    /// **Le croisement** : la courbe du total vaut, chaque jour, la somme des
    /// courbes des comptes. Elle est calculée séparément — l'union de leurs
    /// marches — donc rien ne l'oblige à leur répondre, sauf d'avoir raison.
    #[test]
    fn the_total_is_the_sum_of_the_accounts_on_every_single_day() {
        let conn = database();
        add(&conn, 1, 1, "2026-02-05", -30 * EURO, 0);
        add(&conn, 2, 2, "2026-02-05", 20 * EURO, 0);
        add(&conn, 3, 1, "2026-02-18", -12 * EURO, 0);
        add(&conn, 4, 2, "2026-03-02", 40 * EURO, 0);
        // Deux opérations le même jour sur le même compte : une seule marche.
        add(&conn, 5, 1, "2026-03-02", -5 * EURO, 0);
        add(&conn, 6, 1, "2026-03-02", -7 * EURO, 0);

        let built = curves(&conn, &[1, 2], "2026-01-15", "2026-03-31");
        let total = curve(&built, "Total");
        let ccp = curve(&built, "CCP");
        let livret = curve(&built, "Livret A");

        let mut checked = 0;
        let mut date = day("2026-01-15");
        let last = day("2026-03-31");
        while date <= last {
            assert_eq!(
                value_at(total, date),
                value_at(ccp, date) + value_at(livret, date),
                "le {date} le total ne vaut pas la somme des comptes"
            );
            date = date.succ_opt().expect("le jour suivant");
            checked += 1;
        }
        assert!(checked > 70, "seulement {checked} jours confrontés");

        // Et une journée à trois opérations n'a qu'une marche.
        assert_eq!(
            ccp.steps
                .iter()
                .filter(|step| step.date == day("2026-03-02"))
                .count(),
            1
        );
        assert_eq!(value_at(ccp, day("2026-03-02")), 100 * EURO - 30 * EURO - 12 * EURO - 12 * EURO);
    }

    /// Une ventilation ne déplace pas l'argent du compte : elle ne fait pas de
    /// marche. C'est la même règle que la colonne Solde de F02.
    #[test]
    fn a_sub_operation_does_not_move_the_account() {
        let conn = database();
        add(&conn, 1, 1, "2026-03-10", -100 * EURO, 0);
        add(&conn, 2, 1, "2026-03-10", -60 * EURO, 1);
        add(&conn, 3, 1, "2026-03-10", -40 * EURO, 1);

        let line = &curves(&conn, &[1], "2026-03-01", "2026-03-31").curves[0];
        assert_eq!(
            value_at(line, day("2026-03-31")),
            0,
            "les ventilations ont été comptées en plus de leur mère"
        );
    }

    /// Sans compte, ou sur une période à l'envers, il n'y a rien à tracer — et
    /// ce n'est pas une erreur.
    #[test]
    fn nothing_to_draw_is_not_a_failure() {
        let conn = database();
        assert!(curves(&conn, &[], "2026-01-01", "2026-12-31").curves.is_empty());
        assert!(curves(&conn, &[1], "2026-12-31", "2026-01-01").curves.is_empty());
        // Un compte qui n'existe pas ne fabrique pas de courbe vide.
        assert!(curves(&conn, &[99], "2026-01-01", "2026-12-31").curves.is_empty());
    }


    // --- Le millésime et les horloges ---------------------------------

    /// **La règle ISO, sur le cas que Fabrice a lui-même soulevé.** La semaine
    /// du 29 décembre 2025 au 4 janvier 2026 a son jeudi le 1er janvier : elle
    /// est de 2026, et non de 2025 comme le dirait sa date de début.
    #[test]
    fn a_week_belongs_to_the_year_of_its_thursday() {
        assert_eq!(year_of(day("2025-12-29"), day("2026-01-04")), 2026);
        // Et celle d'avant, dont le jeudi est le 25 décembre, reste de 2025.
        assert_eq!(year_of(day("2025-12-22"), day("2025-12-28")), 2025);
        // Une période enfermée dans une année porte la sienne, sans détour.
        assert_eq!(year_of(day("2026-07-01"), day("2026-07-31")), 2026);
        assert_eq!(year_of(day("2026-01-01"), day("2026-12-31")), 2026);
        // « Toutes » : l'année de début, faute de mieux — les deux dates
        // affichées lèvent l'ambiguïté.
        assert_eq!(year_of(day("1950-01-01"), day("2550-12-31")), 1950);
    }

    /// 2026 a 53 semaines — son 1er janvier est un jeudi —, et 2027 n'en a que
    /// 52. C'est exactement le cas que Fabrice a prévu.
    #[test]
    fn a_year_has_fifty_three_weeks_when_it_starts_on_a_thursday() {
        assert_eq!(weeks_in_iso_year(2026), 53, "2026 commence un jeudi");
        assert_eq!(weeks_in_iso_year(2027), 52);
        assert_eq!(weeks_in_iso_year(2020), 53, "bissextile, commence un mercredi");
        assert_eq!(weeks_in_iso_year(2025), 52);
    }

    /// **Une semaine reste une semaine** : l'horloge garde son numéro ISO, donc
    /// le lundi reste un lundi. Ajouter douze mois aux deux dates aurait fait
    /// tomber le lundi 29/12/2025 sur un mardi.
    #[test]
    fn the_clock_moves_a_week_to_the_same_week_of_the_next_year() {
        let (from, to) = shift_period(day("2026-03-09"), day("2026-03-15"), 1, None);
        assert_eq!(from.weekday().num_days_from_monday(), 0, "toujours un lundi");
        assert_eq!(to.weekday().num_days_from_monday(), 6, "toujours un dimanche");
        assert_eq!(iso_week_of(from), iso_week_of(day("2026-03-09")));
        assert_eq!(from.year(), 2027);
    }

    /// Et la semaine 53 d'une année qui n'en a que 52 devient la 52 : on
    /// impose, on ne rejette pas.
    #[test]
    fn the_fifty_third_week_becomes_the_fifty_second_when_there_is_no_other() {
        // La semaine 53 de 2026 : du lundi 28 décembre 2026 au 3 janvier 2027.
        let monday = monday_of_iso_week(2026, 53);
        assert_eq!(iso_week_of(monday), 53);

        let mut sunday = monday;
        for _ in 0..6 {
            sunday = sunday.succ_opt().expect("le jour suivant");
        }
        let (from, to) = shift_period(monday, sunday, 1, None);
        assert_eq!(
            iso_week_of(from),
            52,
            "2027 n'a que 52 semaines : la 53 doit y devenir la 52"
        );
        assert_eq!(from.weekday().num_days_from_monday(), 0);
        assert_eq!(year_of(from, to), 2027);
    }

    /// Un mois garde ses jours, et le 29 février retombe au 28 quand l'année
    /// d'arrivée n'est pas bissextile — la règle que `time_compute` applique
    /// déjà ailleurs dans Radinus.
    #[test]
    fn a_month_keeps_its_days_and_the_leap_day_falls_back() {
        let (from, to) = shift_period(day("2026-07-01"), day("2026-07-31"), 1, None);
        assert_eq!((from, to), (day("2027-07-01"), day("2027-07-31")));

        let (from, to) = shift_period(day("2028-02-01"), day("2028-02-29"), 1, None);
        assert_eq!(to, day("2029-02-28"), "2029 n'a pas de 29 février");
        assert_eq!(from, day("2029-02-01"));

        // L'horloge arrière, et le clic sur le millésime.
        assert_eq!(
            shift_period(day("2026-07-01"), day("2026-07-31"), -1, None),
            (day("2025-07-01"), day("2025-07-31"))
        );
        assert_eq!(
            shift_period(day("2026-07-01"), day("2026-07-31"), 0, Some(2030)),
            (day("2030-07-01"), day("2030-07-31"))
        );
        // Et les bornes de Radinus s'appliquent ici comme partout.
        let (far, _) = shift_period(day("2026-07-01"), day("2026-07-31"), 0, Some(3000));
        assert_eq!(far.year(), 2550);
    }

    /// Les bornes verticales encadrent bien toutes les courbes.
    #[test]
    fn the_bounds_hold_every_curve() {
        let conn = database();
        add(&conn, 1, 1, "2026-03-10", -300 * EURO, 0);
        let built = curves(&conn, &[1, 2], "2026-03-01", "2026-03-31");
        // Le CCP descend à -200, le total monte à 600 avant de retomber.
        assert_eq!(built.lowest, -200 * EURO);
        assert_eq!(built.highest, 600 * EURO);
    }
}
