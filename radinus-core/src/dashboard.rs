//! F19 — le tableau de bord.
//!
//! Référence : `04_SPECIFICATIONS_FENETRES.md` F19, `PLAN_ACTION.md` §6.3, et
//! la capture « Tableau de bord.png ».
//!
//! **Une période, pas une année.** C'est ce qui le distingue des six
//! statistiques : elles découpent une année en douze mois, il regarde deux
//! dates et ne découpe rien. Trois interrupteurs au lieu de cinq — les statuts
//! seulement, puisqu'il sépare lui-même les débits des gains.
//!
//! Cinq chiffres, et **ils se contrôlent mutuellement** : la somme des
//! dépenses par poste doit valoir la tuile « débités », celle des gains la
//! tuile « crédités », et la balance leur somme. Ce ne sont pas cinq calculs
//! indépendants qui se trouveraient d'accord par chance — c'est un seul
//! parcours des opérations, et le test le vérifie quand même, parce que c'est
//! là que deux logiques se rencontrent.
//!
//! **Le poste budgétaire n'est pas porté par l'opération** mais par sa
//! catégorie, exactement comme pour la statistique du même axe : on réutilise
//! son expression plutôt que d'en écrire une seconde qui pourrait diverger.

use crate::statistics::{Axis, Switches};
use rusqlite::{Connection, Result};
use time_compute::{Datelike, NaiveDate};

/// Une part de l'anneau : un poste budgétaire et ce qu'il pèse.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Slice {
    /// La clef du poste, ou `0` pour la part des opérations qui n'en ont pas.
    pub id: i64,
    pub label: String,
    /// **Toujours positif**, des deux côtés : un anneau montre des parts, et
    /// une part négative n'a pas de sens. Le signe est dans le titre de la
    /// carte — « Dépenses » d'un côté, « Gains » de l'autre.
    pub amount: i64,
}

/// Ce que la fenêtre dessine.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Dashboard {
    /// Les postes qui ont coûté, du plus lourd au plus léger : un anneau se
    /// lit du plus gros secteur au plus petit.
    pub spending: Vec<Slice>,
    /// Les postes qui ont rapporté. Souvent vide — la capture de l'auteur
    /// montre un anneau des gains sans rien dedans, et c'est une réponse.
    pub earning: Vec<Slice>,
    /// La somme des opérations débitées, négative ou nulle.
    pub debits: i64,
    /// La somme des opérations créditées, positive ou nulle.
    pub credits: i64,
    /// Leur somme. Le nom est celui de l'auteur.
    pub balance: i64,
}

/// Le tableau de bord d'une période, pour des comptes.
///
/// Mêmes règles que les statistiques, et volontairement les mêmes : la règle
/// des feuilles (une mère ventilée ne compte pas, ses filles comptent), les
/// statuts que les interrupteurs laissent passer, et un classement disparu qui
/// bascule dans la part « sans poste » plutôt que de faire disparaître un
/// montant.
pub fn dashboard(
    conn: &Connection,
    accounts: &[i64],
    from: &str,
    to: &str,
    switches: Switches,
    unclassified_label: &str,
) -> Result<Dashboard> {
    rings(
        conn,
        accounts,
        from,
        to,
        switches,
        unclassified_label,
        Axis::BudgetLine,
        None,
    )
}

/// **Le même découpage, à l'intérieur d'un seul poste budgétaire, par
/// catégorie.**
///
/// C'est ce que l'accueil montre quand on clique un secteur de son anneau
/// (décision de Fabrice, 03/08/2026) : l'anneau se creuse, il ne change pas de
/// nature. Même période, mêmes comptes, mêmes interrupteurs, mêmes règles de
/// feuilles — seul l'axe change, et un filtre s'ajoute.
///
/// **`budget_line` vaut `0` pour la part « sans poste »**, et ce n'est pas un
/// cas particulier à traiter : l'expression qui donne le poste d'une opération
/// rend déjà `0` quand la catégorie n'en porte pas, ou quand il n'y a pas de
/// catégorie du tout. Cliquer cette part montre donc les catégories orphelines
/// **et** la part sans catégorie, ce qui est exactement ce qu'elle contenait.
pub fn inside_budget_line(
    conn: &Connection,
    accounts: &[i64],
    from: &str,
    to: &str,
    switches: Switches,
    unclassified_label: &str,
    budget_line: i64,
) -> Result<Dashboard> {
    rings(
        conn,
        accounts,
        from,
        to,
        switches,
        unclassified_label,
        Axis::Category,
        Some(budget_line),
    )
}

/// Un point de la courbe : une date, et ce que la catégorie a coûté **depuis le
/// début de la période** jusqu'à cette date comprise.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct DayPoint {
    /// La date en ISO. La fenêtre la montre, elle ne la calcule pas.
    pub day: String,
    /// Le cumul, **toujours positif**, comme les parts d'un anneau : le signe
    /// est dans le titre de la carte, « Dépenses » ou « Gains ».
    pub amount: i64,
    /// Vrai quand ce point **résume un mois entier** et non un jour, c'est-à-
    /// dire quand la période était trop longue pour être montrée jour par jour.
    ///
    /// **C'est le noyau qui le dit, et le contrôleur qui en tire un mot.** La
    /// règle du pas — jour ou mois — est écrite une seule fois, ici. Si le
    /// contrôleur la recalculait de son côté à partir des dates, les deux
    /// finiraient par ne plus dire la même chose, et l'axe annoncerait des
    /// jours sous une courbe mensuelle.
    pub whole_month: bool,
}

/// **Le cumul d'une catégorie, jour après jour, sur la période.**
///
/// Troisième niveau de l'accueil (décision de Fabrice, 03/08/2026) : on clique
/// une catégorie et l'anneau laisse la place à une courbe. Elle répond à une
/// question que l'anneau ne peut pas poser — non pas « combien ce mois-ci »,
/// mais « **quand** dans le mois ».
///
/// **Un point par jour, du premier au dernier, même les jours sans rien.**
/// C'est ce qui fait qu'une courbe se lit : les paliers deviennent visibles —
/// une semaine sans dépense est une ligne plate, et c'est une information. Ne
/// donner que les jours mouvementés donnerait une courbe qui ment sur le
/// rythme, en rapprochant deux dépenses éloignées de trois semaines.
///
/// **Au-delà de trois mois, un point par mois** (décision de Fabrice,
/// 04/08/2026, pour F19 dont la période est libre). L'accueil regarde un mois
/// et ne connaîtra jamais ce cas ; le tableau de bord peut regarder une année,
/// et trois cent soixante-cinq points sur une carte donnent un trait qui
/// tremble sous un axe illisible. Le cumul, lui, ne change pas d'un pas à
/// l'autre : ce sont les mêmes opérations, additionnées dans le même ordre.
/// Seuls les points où l'on s'arrête pour regarder changent.
///
/// **Le dernier jour de la période est toujours un point**, même s'il tombe au
/// milieu d'un mois : c'est lui qui porte le total, et un total absent serait
/// la seule chose que la courbe ne pourrait pas rattraper.
///
/// Mêmes règles que les anneaux, et volontairement les mêmes : les comptes, les
/// statuts, et la règle des feuilles. Une courbe qui compterait autrement que
/// le secteur d'où l'on vient ne finirait pas à la même valeur, et rien à
/// l'écran ne le dirait.
pub fn category_running_total(
    conn: &Connection,
    accounts: &[i64],
    from: NaiveDate,
    to: NaiveDate,
    switches: Switches,
    category: i64,
    debits: bool,
) -> Result<Vec<DayPoint>> {
    let statuses = switches.statuses();
    if statuses.is_empty() || accounts.is_empty() || to < from {
        return Ok(Vec::new());
    }

    let accounts_in = placeholders(accounts.len());
    let statuses_in = placeholders(statuses.len());
    let sign = if debits {
        "SUM(CASE WHEN o.Montant < 0 THEN -o.Montant ELSE 0 END)"
    } else {
        "SUM(CASE WHEN o.Montant > 0 THEN o.Montant ELSE 0 END)"
    };
    let query = format!(
        "SELECT o.Date, {sign}
         FROM Operation o
         WHERE o.IDCompte IN ({accounts_in})
           AND o.Date IS NOT NULL AND o.Date >= ?a AND o.Date <= ?b
           AND o.IDStatutOperation IN ({statuses_in})
           AND (o.IDOperationParent <> 0
                OR NOT EXISTS (SELECT 1 FROM Operation f
                               WHERE f.IDOperationParent = o.IDOperation))
           AND o.IDCategorie = ?
         GROUP BY o.Date"
    );
    let query = query
        .replace("?a", &format!("'{}'", escaped(&from.to_string())))
        .replace("?b", &format!("'{}'", escaped(&to.to_string())));

    let mut parameters: Vec<i64> = accounts.to_vec();
    parameters.extend(statuses);
    parameters.push(category);

    let mut by_day: std::collections::HashMap<String, i64> = std::collections::HashMap::new();
    let mut statement = conn.prepare(&query)?;
    let mut lines = statement.query(rusqlite::params_from_iter(parameters))?;
    while let Some(line) = lines.next()? {
        by_day.insert(line.get(0)?, line.get(1)?);
    }

    // Trois mois. Au-delà, la courbe s'arrête à la fin de chaque mois plutôt
    // qu'à chaque jour. Quatre-vingt-douze jours et non quatre-vingt-dix : un
    // trimestre d'été fait quatre-vingt-douze jours, et il doit rester du côté
    // du pas quotidien.
    const MOST_DAYS_ONE_BY_ONE: i64 = 92;
    let by_month = (to - from).num_days() > MOST_DAYS_ONE_BY_ONE;

    let mut points = Vec::new();
    let mut running = 0;
    let mut day = from;
    loop {
        let iso = day.to_string();
        running += by_day.get(&iso).copied().unwrap_or(0);
        let tomorrow = day.succ_opt();
        // La veille d'un changement de mois, ou le dernier jour de la période.
        // Le cumul court dans tous les cas : c'est **le point d'arrêt** qui est
        // choisi, jamais ce qu'on additionne.
        let month_ends = tomorrow.is_none_or(|next| next.month() != day.month());
        if !by_month || day == to || month_ends {
            points.push(DayPoint {
                day: iso,
                amount: running,
                whole_month: by_month,
            });
        }
        let Some(tomorrow) = tomorrow else { break };
        if tomorrow > to {
            break;
        }
        day = tomorrow;
    }
    Ok(points)
}

/// Le parcours commun aux deux. **Un seul, et c'est la raison d'être de cette
/// fonction** : deux requêtes qui comptent le même argent par deux chemins
/// finiraient par ne plus dire la même chose, et l'anneau creusé ne
/// retomberait plus sur le secteur d'où l'on vient.
#[allow(clippy::too_many_arguments)]
fn rings(
    conn: &Connection,
    accounts: &[i64],
    from: &str,
    to: &str,
    switches: Switches,
    unclassified_label: &str,
    axis: Axis,
    within: Option<i64>,
) -> Result<Dashboard> {
    let mut built = Dashboard {
        spending: Vec::new(),
        earning: Vec::new(),
        debits: 0,
        credits: 0,
        balance: 0,
    };

    let statuses = switches.statuses();
    if statuses.is_empty() || accounts.is_empty() {
        return Ok(built);
    }

    // Les libellés des postes, pour nommer les parts. Un poste absent de la
    // table — supprimé depuis — n'a pas de nom : sa part rejoint « sans ».
    let mut names: std::collections::HashMap<i64, String> = std::collections::HashMap::new();
    for element in axis.elements(conn)? {
        names.insert(element.id, element.label);
    }

    let accounts_in = placeholders(accounts.len());
    let statuses_in = placeholders(statuses.len());
    let query = format!(
        "SELECT {key},
                SUM(CASE WHEN o.Montant < 0 THEN o.Montant ELSE 0 END),
                SUM(CASE WHEN o.Montant > 0 THEN o.Montant ELSE 0 END)
         FROM Operation o
         WHERE o.IDCompte IN ({accounts_in})
           AND o.Date IS NOT NULL AND o.Date >= ?a AND o.Date <= ?b
           AND o.IDStatutOperation IN ({statuses_in})
           AND (o.IDOperationParent <> 0
                OR NOT EXISTS (SELECT 1 FROM Operation f
                               WHERE f.IDOperationParent = o.IDOperation))
           {within_clause}
         GROUP BY 1",
        key = axis.dashboard_key(),
        // Le filtre vient **après** les autres paramètres nommés : son `?` est
        // le dernier de la requête, et c'est dans cet ordre que les valeurs
        // sont liées plus bas.
        within_clause = match within {
            Some(_) => format!("AND {} = ?", Axis::BudgetLine.dashboard_key()),
            None => String::new(),
        }
    );
    let query = query
        .replace("?a", &format!("'{}'", escaped(from)))
        .replace("?b", &format!("'{}'", escaped(to)));

    let mut parameters: Vec<i64> = accounts.to_vec();
    parameters.extend(statuses);
    if let Some(line) = within {
        parameters.push(line);
    }

    let mut spending: Vec<Slice> = Vec::new();
    let mut earning: Vec<Slice> = Vec::new();
    let mut statement = conn.prepare(&query)?;
    let mut lines = statement.query(rusqlite::params_from_iter(parameters))?;
    while let Some(line) = lines.next()? {
        let id: i64 = line.get(0)?;
        let spent: i64 = line.get(1)?;
        let earned: i64 = line.get(2)?;
        let label = names
            .get(&id)
            .cloned()
            .unwrap_or_else(|| unclassified_label.to_string());

        built.debits += spent;
        built.credits += earned;
        // Une part nulle n'est pas une part : un secteur de zéro degré ne se
        // voit pas, et sa légende ferait croire à une dépense qui n'existe pas.
        if spent != 0 {
            spending.push(Slice {
                id,
                label: label.clone(),
                amount: -spent,
            });
        }
        if earned != 0 {
            earning.push(Slice {
                id,
                label,
                amount: earned,
            });
        }
    }

    // Du plus lourd au plus léger, et à poids égal par ordre de nom pour que
    // deux lectures de la même base donnent le même anneau.
    for parts in [&mut spending, &mut earning] {
        parts.sort_by(|left, right| {
            right
                .amount
                .cmp(&left.amount)
                .then_with(|| left.label.cmp(&right.label))
        });
    }

    built.spending = spending;
    built.earning = earning;
    built.balance = built.debits + built.credits;
    Ok(built)
}

fn placeholders(count: usize) -> String {
    std::iter::repeat_n("?", count)
        .collect::<Vec<_>>()
        .join(", ")
}

/// Une date qui vient de l'extérieur ne va pas dans une requête sans être
/// regardée. Elles arrivent d'un champ de date du système, donc au format
/// ISO — mais une apostrophe suffirait à casser la requête, et rien ne coûte
/// moins cher que de la doubler.
fn escaped(date: &str) -> String {
    date.replace('\'', "''")
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database::{schema, seed};

    const EURO: i64 = 1_000_000;

    fn database() -> Connection {
        let conn = Connection::open_in_memory().expect("base en mémoire");
        schema::migrate(&conn).expect("schéma");
        seed::seed_initial_data(&conn).expect("valeurs initiales");
        for id in [1, 2] {
            conn.execute(
                "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte, IDBanques)
                 VALUES (?1, 'Compte', 1, 1)",
                [id],
            )
            .expect("compte");
        }
        conn.execute(
            "INSERT INTO PosteBudget (IDPosteBudget, Libelle) VALUES (960, 'Vie courante')",
            [],
        )
        .expect("poste");
        conn.execute(
            "INSERT INTO PosteBudget (IDPosteBudget, Libelle) VALUES (961, 'Revenus')",
            [],
        )
        .expect("poste");
        for (id, poste) in [(970, 960), (971, 960), (972, 961), (973, 0)] {
            conn.execute(
                "INSERT INTO Categorie (IDCategorie, Libelle, IDPosteBudget)
                 VALUES (?1, 'Cat' || ?1, ?2)",
                rusqlite::params![id, poste],
            )
            .expect("catégorie");
        }
        conn
    }

    // Huit arguments : c'est une opération, et une opération a huit colonnes
    // qui comptent ici. Les regrouper dans une structure ne ferait que
    // déplacer la liste, et rendrait chaque appel de test moins lisible.
    #[allow(clippy::too_many_arguments)]
    fn add(conn: &Connection, id: i64, account: i64, date: &str, amount: i64, category: i64,
           status: i64, parent: i64) {
        conn.execute(
            "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte,
                                    IDStatutOperation, IDOperationParent, IDCategorie)
             VALUES (?1, 'OP', ?2, ?3, ?4, ?5, ?6, ?7)",
            rusqlite::params![id, date, amount, account, status, parent, category],
        )
        .expect("opération");
    }

    fn built(conn: &Connection, switches: Switches) -> Dashboard {
        dashboard(conn, &[1, 2], "2026-07-01", "2026-07-31", switches, "Sans poste")
            .expect("tableau de bord")
    }

    /// **Les cinq chiffres se tiennent.** C'est le croisement du tableau de
    /// bord : la somme des secteurs de chaque anneau doit valoir sa tuile, et
    /// la balance leur somme. Si un jour l'un des cinq se calcule autrement,
    /// c'est ici que cela se verra.
    #[test]
    fn the_rings_add_up_to_the_tiles_and_the_tiles_to_the_balance() {
        let conn = database();
        add(&conn, 1, 1, "2026-07-02", -836 * EURO, 970, 1, 0);
        add(&conn, 2, 1, "2026-07-05", -200 * EURO, 971, 1, 0);
        add(&conn, 3, 2, "2026-07-09", -50 * EURO, 973, 2, 0);
        add(&conn, 4, 1, "2026-07-15", 2216 * EURO, 972, 1, 0);
        add(&conn, 5, 2, "2026-07-20", 100 * EURO, 973, 3, 0);

        let shown = built(&conn, Switches::default());

        let spent: i64 = shown.spending.iter().map(|part| part.amount).sum();
        let earned: i64 = shown.earning.iter().map(|part| part.amount).sum();
        assert_eq!(
            -spent, shown.debits,
            "l'anneau des dépenses ne vaut pas la tuile des débits"
        );
        assert_eq!(
            earned, shown.credits,
            "l'anneau des gains ne vaut pas la tuile des crédits"
        );
        assert_eq!(
            shown.balance,
            shown.debits + shown.credits,
            "la balance n'est pas la somme des deux tuiles"
        );
        assert_eq!(shown.debits, -1086 * EURO);
        assert_eq!(shown.credits, 2316 * EURO);
        assert_eq!(shown.balance, 1230 * EURO);
    }

    /// Deux catégories d'un même poste font une seule part, et une catégorie
    /// sans poste tombe dans « Sans poste » — la règle de l'axe budgétaire,
    /// reprise telle quelle.
    #[test]
    fn two_categories_of_one_budget_line_make_a_single_slice() {
        let conn = database();
        add(&conn, 1, 1, "2026-07-02", -836 * EURO, 970, 1, 0);
        add(&conn, 2, 1, "2026-07-05", -200 * EURO, 971, 1, 0);
        add(&conn, 3, 1, "2026-07-09", -50 * EURO, 973, 1, 0);

        let shown = built(&conn, Switches::default());
        assert_eq!(shown.spending.len(), 2, "{:?}", shown.spending);
        assert_eq!(shown.spending[0].label, "Vie courante");
        assert_eq!(shown.spending[0].amount, 1036 * EURO);
        assert_eq!(shown.spending[1].label, "Sans poste");
        assert_eq!(shown.spending[1].amount, 50 * EURO);
    }

    /// Un anneau se lit du plus gros secteur au plus petit.
    #[test]
    fn the_slices_are_ordered_from_the_heaviest() {
        let conn = database();
        add(&conn, 1, 1, "2026-07-02", -50 * EURO, 970, 1, 0);
        add(&conn, 2, 1, "2026-07-05", -800 * EURO, 973, 1, 0);
        let shown = built(&conn, Switches::default());
        assert!(shown.spending[0].amount > shown.spending[1].amount);
    }

    /// Les trois interrupteurs retirent bien ce qu'ils disent, et le retirent
    /// des anneaux comme des tuiles.
    #[test]
    fn each_switch_takes_its_own_operations_away() {
        let conn = database();
        add(&conn, 1, 1, "2026-07-02", -100 * EURO, 970, 1, 0);
        add(&conn, 2, 1, "2026-07-03", -200 * EURO, 970, 2, 0);
        add(&conn, 3, 1, "2026-07-04", -400 * EURO, 970, 3, 0);

        let all = built(&conn, Switches::default());
        assert_eq!(all.debits, -700 * EURO);

        let no_planned = Switches { planned: false, ..Switches::default() };
        let shown = built(&conn, no_planned);
        assert_eq!(shown.debits, -300 * EURO);
        assert_eq!(
            shown.spending.iter().map(|part| part.amount).sum::<i64>(),
            300 * EURO,
            "l'anneau n'a pas suivi l'interrupteur"
        );

        // Aucun statut retenu : rien du tout, et ce n'est pas une erreur.
        let nothing = Switches {
            pointed: false,
            committed: false,
            planned: false,
            ..Switches::default()
        };
        let empty = built(&conn, nothing);
        assert!(empty.spending.is_empty() && empty.debits == 0 && empty.balance == 0);
    }

    /// La règle des feuilles : une mère ventilée ne compte pas pour elle-même.
    /// Sans cela le tableau de bord compterait deux fois le même argent.
    #[test]
    fn a_ventilated_operation_counts_through_its_children() {
        let conn = database();
        add(&conn, 1, 1, "2026-07-02", -100 * EURO, 970, 1, 0);
        add(&conn, 2, 1, "2026-07-02", -60 * EURO, 970, 1, 1);
        add(&conn, 3, 1, "2026-07-02", -40 * EURO, 973, 1, 1);

        let shown = built(&conn, Switches::default());
        assert_eq!(shown.debits, -100 * EURO, "la mère a été comptée en plus");
        assert_eq!(shown.spending.len(), 2, "les filles comptent chacune pour soi");
    }

    /// Ce qui est hors de la période n'y est pas, bornes comprises.
    #[test]
    fn the_period_is_closed_at_both_ends() {
        let conn = database();
        add(&conn, 1, 1, "2026-06-30", -10 * EURO, 970, 1, 0);
        add(&conn, 2, 1, "2026-07-01", -20 * EURO, 970, 1, 0);
        add(&conn, 3, 1, "2026-07-31", -40 * EURO, 970, 1, 0);
        add(&conn, 4, 1, "2026-08-01", -80 * EURO, 970, 1, 0);

        let shown = built(&conn, Switches::default());
        assert_eq!(shown.debits, -60 * EURO, "les deux bornes sont dedans, le reste dehors");
    }

    /// Un anneau vide est une réponse, pas une panne : la capture de l'auteur
    /// montre une carte « Gains » sans rien dedans.
    #[test]
    fn a_ring_with_nothing_in_it_is_an_answer() {
        let conn = database();
        add(&conn, 1, 1, "2026-07-02", -100 * EURO, 970, 1, 0);
        let shown = built(&conn, Switches::default());
        assert!(shown.earning.is_empty());
        assert_eq!(shown.credits, 0);
        assert_eq!(shown.balance, -100 * EURO);
    }

    /// Sans compte, il n'y a rien à synthétiser — et surtout pas une requête
    /// sur tous les comptes de la base.
    #[test]
    fn no_account_means_nothing_at_all() {
        let conn = database();
        add(&conn, 1, 1, "2026-07-02", -100 * EURO, 970, 1, 0);
        let shown = dashboard(&conn, &[], "2026-07-01", "2026-07-31", Switches::default(), "Sans")
            .expect("tableau de bord");
        assert_eq!(shown.balance, 0);
        assert!(shown.spending.is_empty());
    }

    fn day(year: i32, month: u32, day: u32) -> NaiveDate {
        NaiveDate::from_ymd_opt(year, month, day).expect("date")
    }

    /// Sous trois mois, rien ne change : un point par jour, comme à l'accueil.
    #[test]
    fn une_periode_courte_garde_un_point_par_jour() {
        let conn = database();
        add(&conn, 1, 1, "2026-07-10", -30 * EURO, 970, 1, 0);

        let curve = category_running_total(
            &conn, &[1, 2], day(2026, 7, 1), day(2026, 7, 31),
            Switches::default(), 970, true,
        )
        .expect("courbe");

        assert_eq!(curve.len(), 31);
        assert!(curve.iter().all(|step| !step.whole_month));
        assert_eq!(curve[30].amount, 30 * EURO);
    }

    /// **Au-delà de trois mois, un point par mois** — et le dernier jour de la
    /// période reste un point même s'il tombe au milieu d'un mois, parce que
    /// c'est lui qui porte le total.
    #[test]
    fn une_longue_periode_se_regarde_mois_par_mois() {
        let conn = database();
        add(&conn, 1, 1, "2026-01-15", -10 * EURO, 970, 1, 0);
        add(&conn, 2, 1, "2026-03-20", -25 * EURO, 970, 1, 0);
        add(&conn, 3, 1, "2026-05-08", -65 * EURO, 970, 1, 0);

        let curve = category_running_total(
            &conn, &[1, 2], day(2026, 1, 1), day(2026, 5, 20),
            Switches::default(), 970, true,
        )
        .expect("courbe");

        // Janvier, février, mars, avril — puis le 20 mai, qui clôt la période.
        let dates: Vec<&str> = curve.iter().map(|step| step.day.as_str()).collect();
        assert_eq!(
            dates,
            vec!["2026-01-31", "2026-02-28", "2026-03-31", "2026-04-30", "2026-05-20"]
        );
        assert!(curve.iter().all(|step| step.whole_month));
    }

    /// **Le cumul ne dépend pas du pas.** Les mêmes opérations, additionnées
    /// dans le même ordre : changer de pas ne change que les points où l'on
    /// s'arrête pour regarder. Si un jour ce n'était plus vrai, la courbe
    /// annoncerait un total autre que celui du secteur d'où l'on vient.
    #[test]
    fn le_total_est_le_meme_quel_que_soit_le_pas() {
        let conn = database();
        add(&conn, 1, 1, "2026-01-15", -10 * EURO, 970, 1, 0);
        add(&conn, 2, 1, "2026-02-20", -25 * EURO, 970, 1, 0);

        let jours = category_running_total(
            &conn, &[1, 2], day(2026, 1, 1), day(2026, 3, 31),
            Switches::default(), 970, true,
        )
        .expect("courbe au jour");
        let mois = category_running_total(
            &conn, &[1, 2], day(2026, 1, 1), day(2026, 6, 30),
            Switches::default(), 970, true,
        )
        .expect("courbe au mois");

        assert!(!jours[0].whole_month);
        assert!(mois[0].whole_month);
        assert_eq!(jours.last().expect("dernier").amount, 35 * EURO);
        assert_eq!(mois.last().expect("dernier").amount, 35 * EURO);
    }

    /// Quatre-vingt-douze jours restent du côté du pas quotidien, et
    /// quatre-vingt-treize basculent. La borne est écrite dans un test parce
    /// qu'un nombre choisi finit toujours par être changé sans savoir pourquoi
    /// il était là.
    ///
    /// **L'écart est vérifié avant ce qu'on en attend**, et ce n'est pas une
    /// précaution de style : la première version de ce test annonçait 93 jours
    /// entre le 1er janvier et le 3 avril, alors qu'il y en a 92. Il a échoué
    /// en accusant le code, qui était juste. Un test qui compte lui-même ne
    /// peut plus se tromper sur ce qu'il compte.
    #[test]
    fn la_borne_des_trois_mois_est_a_quatre_vingt_douze_jours() {
        let conn = database();
        let debut = day(2026, 1, 1);
        let quatre_vingt_douze = day(2026, 4, 3);
        let quatre_vingt_treize = day(2026, 4, 4);
        assert_eq!((quatre_vingt_douze - debut).num_days(), 92);
        assert_eq!((quatre_vingt_treize - debut).num_days(), 93);

        let court = category_running_total(
            &conn, &[1, 2], debut, quatre_vingt_douze,
            Switches::default(), 970, true,
        )
        .expect("92 jours");
        let long = category_running_total(
            &conn, &[1, 2], debut, quatre_vingt_treize,
            Switches::default(), 970, true,
        )
        .expect("93 jours");

        assert!(!court[0].whole_month, "92 jours d'écart : au jour");
        assert!(long[0].whole_month, "93 jours d'écart : au mois");
    }
}
