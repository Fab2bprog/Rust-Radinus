//! Le **bilan croisé** (F39) — les catégories en lignes, les affectations en
//! colonnes, sur un mois.
//!
//! Demandé par Fabrice le 25/08/2026. Les six statistiques croisent une
//! nomenclature avec le temps : douze colonnes, une par mois de l'année. Celle-
//! ci croise **deux nomenclatures entre elles** et fixe le temps : un mois, et
//! l'on navigue de mois en mois. « Qui a dépensé quoi, ce mois-ci » — les
//! courses de la famille, l'essence de Monsieur, le vétérinaire des animaux,
//! dans un seul tableau.
//!
//! **Ce qui est repris tel quel de `statistics`**, et qui n'est donc pas
//! réécrit ici : les interrupteurs et les statuts qu'ils laissent passer, le
//! sens des montants, la règle de la feuille — une mère ventilée ne compte pas
//! pour elle-même, ses filles comptent à sa place —, les expressions qui
//! classent une opération, et les bornes d'un mois. Compter deux fois de deux
//! façons, ce serait deux comptes qui finissent par diverger.
//!
//! **Ce qui change, et pourquoi :**
//!
//!   * les colonnes ne sont plus douze mais autant que d'affectations, plus
//!     « Sans affectation » ; les lignes sont les catégories, plus « Sans
//!     catégorie ». Les deux nomenclatures sont montrées **en entier**, même
//!     ce qui ne porte rien : on navigue de mois en mois, et des colonnes qui
//!     changeraient de place d'un mois à l'autre rendraient toute comparaison
//!     impossible ;
//!   * **il n'y a pas de ligne « Cumul »** (décision de Fabrice, 25/08/2026).
//!     Le cumul additionne les mois dans l'ordre — celui de mai, c'est janvier
//!     à mai. Les affectations n'ont pas d'ordre, et le tableau ne porte que
//!     sur un mois : il n'y aurait rien à cumuler. La ligne « Somme », elle,
//!     garde tout son sens.

use crate::statistics::{first_day, last_day, placeholders, Axis, Switches};
use rusqlite::{Connection, Result};

/// La clef de la ligne ou de la colonne qui ramasse ce qui n'est pas classé.
/// Zéro est le « Non précisé » de la base depuis toujours.
const UNCLASSIFIED: i64 = 0;

/// Une colonne : une affectation, ou « Sans affectation » en dernier.
#[derive(Debug, Clone, PartialEq)]
pub struct Column {
    pub id: i64,
    pub label: String,
}

/// Une ligne : une catégorie, ou « Sans catégorie » en dernier.
#[derive(Debug, Clone, PartialEq)]
pub struct Row {
    pub id: i64,
    pub label: String,
    /// Un montant par colonne, dans l'ordre des colonnes.
    pub cells: Vec<i64>,
    /// Si une opération est tombée dans cette case. **Ce n'est pas
    /// `cells[i] != 0`** : une case où un crédit et un débit s'annulent vaut
    /// zéro sans être vide, et la fenêtre les peint différemment. Sans ce
    /// compte, les deux seraient indistinguables — la même règle que la
    /// matrice des statistiques.
    pub filled: Vec<bool>,
    pub total: i64,
    pub total_filled: bool,
}

impl Row {
    fn empty(id: i64, label: String, width: usize) -> Self {
        Self {
            id,
            label,
            cells: vec![0; width],
            filled: vec![false; width],
            total: 0,
            total_filled: false,
        }
    }

    /// Si cette ligne ne porte rien. Elle est montrée quand même — toutes les
    /// catégories apparaissent — mais la fenêtre peut vouloir le savoir.
    pub fn is_empty(&self) -> bool {
        !self.total_filled && !self.filled.iter().any(|filled| *filled)
    }
}

/// Ce que la fenêtre dessine : les colonnes, les lignes, et la Somme.
#[derive(Debug, Clone, PartialEq)]
pub struct Matrix {
    pub columns: Vec<Column>,
    pub rows: Vec<Row>,
    /// La ligne « Somme » : le total de chaque affectation, toutes catégories
    /// confondues.
    pub sum: Vec<i64>,
    pub sum_filled: Vec<bool>,
    pub sum_total: i64,
    /// Si le tableau porte la moindre donnée. Un tableau vide n'affiche pas sa
    /// ligne de synthèse : il n'y a rien à synthétiser.
    pub has_data: bool,
}

/// Construit le bilan croisé du mois donné, sur les comptes donnés.
///
/// Les deux libellés arrivent de l'extérieur : ce module ne connaît aucune
/// langue, et c'est le contrôleur qui sait dans laquelle on parle.
pub fn crossed(
    conn: &Connection,
    accounts: &[i64],
    year: i32,
    month: u32,
    switches: Switches,
    no_category: &str,
    no_assignment: &str,
) -> Result<Matrix> {
    // Les colonnes : toutes les affectations dans l'ordre des listes, puis
    // « Sans affectation ».
    let mut columns: Vec<Column> = Vec::new();
    let mut column_at: std::collections::HashMap<i64, usize> = std::collections::HashMap::new();
    for element in Axis::Assignment.elements(conn)? {
        column_at.insert(element.id, columns.len());
        columns.push(Column {
            id: element.id,
            label: element.label,
        });
    }
    column_at.insert(UNCLASSIFIED, columns.len());
    columns.push(Column {
        id: UNCLASSIFIED,
        label: no_assignment.to_string(),
    });
    let no_assignment_at = columns.len() - 1;
    let width = columns.len();

    // Les lignes : toutes les catégories, puis « Sans catégorie ».
    let mut rows: Vec<Row> = Vec::new();
    let mut row_at: std::collections::HashMap<i64, usize> = std::collections::HashMap::new();
    for element in Axis::Category.elements(conn)? {
        row_at.insert(element.id, rows.len());
        rows.push(Row::empty(element.id, element.label, width));
    }
    row_at.insert(UNCLASSIFIED, rows.len());
    rows.push(Row::empty(UNCLASSIFIED, no_category.to_string(), width));
    let no_category_at = rows.len() - 1;

    let mut matrix = Matrix {
        columns,
        rows,
        sum: vec![0; width],
        sum_filled: vec![false; width],
        sum_total: 0,
        has_data: false,
    };

    let statuses = switches.statuses();
    // Aucun statut retenu, ou ni les débits ni les crédits : il n'y a rien à
    // compter, et ce n'est pas une erreur. Le tableau se montre vide, avec
    // toutes ses lignes et toutes ses colonnes.
    if statuses.is_empty() || (!switches.debits && !switches.credits) || accounts.is_empty() {
        return Ok(matrix);
    }

    let accounts_in = placeholders(accounts.len());
    let statuses_in = placeholders(statuses.len());
    let sign = match (switches.debits, switches.credits) {
        (true, true) => "",
        (true, false) => "AND o.Montant < 0",
        (false, true) => "AND o.Montant > 0",
        (false, false) => unreachable!("écarté juste au-dessus"),
    };
    let (from, to) = (first_day(year, month), last_day(year, month));

    // Une seule requête, groupée sur les deux clefs à la fois : c'est
    // exactement la question que pose le tableau.
    let query = format!(
        "SELECT {category}, {assignment}, SUM(o.Montant), COUNT(*)
         FROM Operation o
         WHERE o.IDCompte IN ({accounts_in})
           AND o.Date IS NOT NULL AND o.Date >= '{from}' AND o.Date <= '{to}'
           AND o.IDStatutOperation IN ({statuses_in})
           AND (o.IDOperationParent <> 0
                OR NOT EXISTS (SELECT 1 FROM Operation f
                               WHERE f.IDOperationParent = o.IDOperation))
           {sign}
         GROUP BY 1, 2",
        category = Axis::Category.key_expression(),
        assignment = Axis::Assignment.key_expression(),
    );

    let mut parameters: Vec<i64> = accounts.to_vec();
    parameters.extend(statuses);

    let mut statement = conn.prepare(&query)?;
    let mut cells = statement.query(rusqlite::params_from_iter(parameters))?;
    while let Some(cell) = cells.next()? {
        let category: i64 = cell.get(0)?;
        let assignment: i64 = cell.get(1)?;
        let amount: i64 = cell.get(2)?;
        let count: i64 = cell.get(3)?;
        if count == 0 {
            continue;
        }
        // Un classement supprimé depuis, ou le sentinelle « Non précisé » :
        // l'opération existe et son montant compte, mais sous « Sans … ».
        // **Un montant ne disparaît jamais d'une statistique parce que son
        // classement a disparu** — la règle de la matrice, des deux côtés à la
        // fois puisque le tableau a deux axes.
        let line = *row_at.get(&category).unwrap_or(&no_category_at);
        let column = *column_at.get(&assignment).unwrap_or(&no_assignment_at);

        let row = &mut matrix.rows[line];
        row.cells[column] += amount;
        row.filled[column] = true;
        row.total += amount;
        row.total_filled = true;

        matrix.sum[column] += amount;
        matrix.sum_filled[column] = true;
        matrix.sum_total += amount;
        matrix.has_data = true;
    }

    Ok(matrix)
}

/// Le détail derrière une case : les opérations qu'elle compte, dans l'ordre
/// des dates.
///
/// `category` et `assignment` disent ce qui est demandé, et `None` veut dire
/// « toutes » : une case ordinaire nomme les deux, la colonne Total d'une ligne
/// ne nomme que la catégorie, la ligne Somme ne nomme que l'affectation, et le
/// total général n'en nomme aucune. Une seule fonction pour les quatre — quatre
/// requêtes, ce seraient quatre occasions de ne pas montrer ce que la case
/// annonce.
pub fn behind_the_cell(
    conn: &Connection,
    accounts: &[i64],
    year: i32,
    month: u32,
    switches: Switches,
    category: Option<i64>,
    assignment: Option<i64>,
) -> Result<Vec<(crate::operations::OperationRow, i64)>> {
    let statuses = switches.statuses();
    if statuses.is_empty() || (!switches.debits && !switches.credits) || accounts.is_empty() {
        return Ok(Vec::new());
    }

    let accounts_in = placeholders(accounts.len());
    let statuses_in = placeholders(statuses.len());
    let sign = match (switches.debits, switches.credits) {
        (true, true) => "",
        (true, false) => "AND o.Montant < 0",
        (false, true) => "AND o.Montant > 0",
        (false, false) => unreachable!("écarté juste au-dessus"),
    };
    let (from, to) = (first_day(year, month), last_day(year, month));

    // « Sans … » ramasse aussi les classements disparus : la même règle qu'à
    // la construction du tableau, sinon un clic dessus montrerait moins que ce
    // que la case annonce.
    let kept = |axis: Axis, asked: Option<i64>| -> String {
        let key = axis.key_expression();
        let (table, column) = axis.source();
        match asked {
            None => String::new(),
            Some(UNCLASSIFIED) => format!(
                "AND ({key} = {UNCLASSIFIED}
                      OR {key} NOT IN (SELECT {column} FROM {table}))"
            ),
            Some(id) => format!("AND {key} = {id}"),
        }
    };

    let query = format!(
        "{select}
         WHERE o.IDCompte IN ({accounts_in})
           AND o.Date IS NOT NULL AND o.Date >= '{from}' AND o.Date <= '{to}'
           AND o.IDStatutOperation IN ({statuses_in})
           AND (o.IDOperationParent <> 0
                OR NOT EXISTS (SELECT 1 FROM Operation f
                               WHERE f.IDOperationParent = o.IDOperation))
           {sign}
           {on_category}
           {on_assignment}
         ORDER BY o.Date, o.IDOperation",
        select = crate::operations::SELECT_ROW,
        on_category = kept(Axis::Category, category),
        on_assignment = kept(Axis::Assignment, assignment),
    );

    let mut parameters: Vec<i64> = accounts.to_vec();
    parameters.extend(statuses);

    let mut statement = conn.prepare(&query)?;
    let found = statement
        .query_map(rusqlite::params_from_iter(parameters), |row| {
            crate::operations::read_row(row)
        })?
        .collect();
    found
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
        conn.execute(
            "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte, IDBanques)
             VALUES (1, 'CCP', 1, 1)",
            [],
        )
        .expect("compte");
        conn
    }

    #[allow(clippy::too_many_arguments)]
    fn add(
        conn: &Connection,
        id: i64,
        date: &str,
        amount: i64,
        category: i64,
        assignment: i64,
        parent: i64,
    ) {
        conn.execute(
            "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte,
                                    IDStatutOperation, IDOperationParent,
                                    IDCategorie, IDAffectation)
             VALUES (?1, 'OP', ?2, ?3, 1, 1, ?4, ?5, ?6)",
            rusqlite::params![id, date, amount, parent, category, assignment],
        )
        .expect("opération");
    }

    fn ids(conn: &Connection, kind: crate::nomenclatures::Nomenclature) -> Vec<i64> {
        crate::nomenclatures::list(conn, kind)
            .expect("liste")
            .into_iter()
            .map(|element| element.id)
            .collect()
    }

    fn crossed_at(conn: &Connection, month: u32, switches: Switches) -> Matrix {
        crossed(
            conn,
            &[1],
            2026,
            month,
            switches,
            "Sans catégorie",
            "Sans affectation",
        )
        .expect("bilan")
    }

    /// Le tableau porte **tout le plan de comptes** : toutes les catégories,
    /// toutes les affectations, plus les deux « Sans … » en dernier — même ce
    /// que ce mois-là ne remplit pas. On navigue de mois en mois, et des
    /// colonnes qui changeraient de place seraient incomparables.
    #[test]
    fn le_tableau_porte_tout_le_plan_de_comptes() {
        let conn = database();
        let categories = ids(&conn, crate::nomenclatures::Nomenclature::Category);
        let assignments = ids(&conn, crate::nomenclatures::Nomenclature::Assignment);

        let matrix = crossed_at(&conn, 9, Switches::default());

        assert_eq!(matrix.rows.len(), categories.len() + 1);
        assert_eq!(matrix.columns.len(), assignments.len() + 1);
        assert_eq!(matrix.rows.last().expect("dernière").label, "Sans catégorie");
        let last = matrix.columns.last().expect("dernière");
        assert_eq!(last.label, "Sans affectation");
        assert_eq!(last.id, UNCLASSIFIED);
        assert!(!matrix.has_data, "un mois vide ne porte rien");
        assert!(matrix.rows[0].is_empty());
    }

    /// Chaque montant tombe dans la case de sa catégorie **et** de son
    /// affectation, et les deux totaux le comptent une fois.
    #[test]
    fn chaque_montant_tombe_dans_sa_case() {
        let conn = database();
        let category = ids(&conn, crate::nomenclatures::Nomenclature::Category)[0];
        let assignment = ids(&conn, crate::nomenclatures::Nomenclature::Assignment)[0];

        add(&conn, 1, "2026-09-05", -100 * EURO, category, assignment, 0);
        add(&conn, 2, "2026-09-12", -40 * EURO, category, assignment, 0);

        let matrix = crossed_at(&conn, 9, Switches::default());
        let line = matrix
            .rows
            .iter()
            .find(|row| row.id == category)
            .expect("la catégorie");
        let column = matrix
            .columns
            .iter()
            .position(|item| item.id == assignment)
            .expect("l'affectation");

        assert_eq!(line.cells[column], -140 * EURO);
        assert!(line.filled[column]);
        assert_eq!(line.total, -140 * EURO);
        assert_eq!(matrix.sum[column], -140 * EURO);
        assert!(matrix.sum_filled[column]);
        assert_eq!(matrix.sum_total, -140 * EURO);
        assert!(matrix.has_data);
    }

    /// **Une case à zéro n'est pas une case vide.** Un crédit et un débit qui
    /// s'annulent laissent une case à zéro que la fenêtre doit peindre — sans
    /// `filled`, elle serait indistinguable d'une case où rien n'est passé.
    #[test]
    fn une_case_qui_s_annule_reste_remplie() {
        let conn = database();
        let category = ids(&conn, crate::nomenclatures::Nomenclature::Category)[0];
        let assignment = ids(&conn, crate::nomenclatures::Nomenclature::Assignment)[0];

        add(&conn, 1, "2026-09-05", -50 * EURO, category, assignment, 0);
        add(&conn, 2, "2026-09-06", 50 * EURO, category, assignment, 0);

        let matrix = crossed_at(&conn, 9, Switches::default());
        let line = matrix
            .rows
            .iter()
            .find(|row| row.id == category)
            .expect("la catégorie");
        let column = matrix
            .columns
            .iter()
            .position(|item| item.id == assignment)
            .expect("l'affectation");

        assert_eq!(line.cells[column], 0);
        assert!(line.filled[column], "elle a vu passer deux opérations");
        assert!(matrix.has_data);
    }

    /// Une opération sans classement tombe dans « Sans … » — des deux côtés
    /// quand elle n'a ni catégorie ni affectation.
    #[test]
    fn ce_qui_n_est_pas_classe_tombe_dans_les_deux_sans() {
        let conn = database();
        add(&conn, 1, "2026-09-03", -50 * EURO, 0, 0, 0);

        let matrix = crossed_at(&conn, 9, Switches::default());
        let line = matrix.rows.last().expect("la dernière ligne");
        let column = matrix.columns.len() - 1;

        assert_eq!(line.cells[column], -50 * EURO);
        assert_eq!(matrix.sum_total, -50 * EURO);
    }

    /// **Un classement disparu ne fait pas disparaître un montant** : une
    /// catégorie effacée depuis renvoie son opération dans « Sans catégorie »,
    /// elle ne l'évapore pas.
    #[test]
    fn un_classement_disparu_retombe_dans_sans() {
        let conn = database();
        add(&conn, 1, "2026-09-03", -70 * EURO, 4242, 4243, 0);

        let matrix = crossed_at(&conn, 9, Switches::default());
        let line = matrix.rows.last().expect("la dernière ligne");
        let column = matrix.columns.len() - 1;

        assert_eq!(line.cells[column], -70 * EURO);
        assert_eq!(matrix.sum_total, -70 * EURO);
    }

    /// **Le mois seul.** Ce qui est tombé un autre mois n'entre pas : c'est
    /// toute la différence avec les six statistiques, qui prennent l'année.
    #[test]
    fn seul_le_mois_demande_est_compte() {
        let conn = database();
        let category = ids(&conn, crate::nomenclatures::Nomenclature::Category)[0];
        add(&conn, 1, "2026-09-15", -30 * EURO, category, 0, 0);

        assert!(
            !crossed_at(&conn, 8, Switches::default()).has_data,
            "août ne voit pas septembre"
        );
        assert_eq!(
            crossed_at(&conn, 9, Switches::default()).sum_total,
            -30 * EURO
        );
        assert!(
            !crossed_at(&conn, 10, Switches::default()).has_data,
            "octobre non plus"
        );
    }

    /// **La règle de la feuille** : une mère ventilée ne compte pas pour
    /// elle-même, ses filles comptent à sa place — et chacune sous son propre
    /// classement, ce qui est tout l'intérêt du tableau.
    #[test]
    fn une_mere_ventilee_ne_compte_pas_deux_fois() {
        let conn = database();
        let categories = ids(&conn, crate::nomenclatures::Nomenclature::Category);
        let assignments = ids(&conn, crate::nomenclatures::Nomenclature::Assignment);

        add(&conn, 1, "2026-09-08", -100 * EURO, categories[0], assignments[0], 0);
        add(&conn, 2, "2026-09-08", -60 * EURO, categories[0], assignments[0], 1);
        add(&conn, 3, "2026-09-08", -40 * EURO, categories[1], assignments[1], 1);

        let matrix = crossed_at(&conn, 9, Switches::default());
        assert_eq!(matrix.sum_total, -100 * EURO, "la mère ne compte pas deux fois");

        let first = matrix
            .rows
            .iter()
            .find(|row| row.id == categories[0])
            .expect("la première");
        let second = matrix
            .rows
            .iter()
            .find(|row| row.id == categories[1])
            .expect("la seconde");
        assert_eq!(first.total, -60 * EURO, "la fille, pas la mère");
        assert_eq!(second.total, -40 * EURO);
    }

    /// Le détail d'une case : les deux classements nommés. `None` veut dire
    /// « toutes », ce qui donne la colonne Total, la ligne Somme et le total
    /// général.
    #[test]
    fn le_detail_suit_ce_que_la_case_annonce() {
        let conn = database();
        let categories = ids(&conn, crate::nomenclatures::Nomenclature::Category);
        let assignments = ids(&conn, crate::nomenclatures::Nomenclature::Assignment);

        add(&conn, 1, "2026-09-05", -100 * EURO, categories[0], assignments[0], 0);
        add(&conn, 2, "2026-09-06", -60 * EURO, categories[1], assignments[0], 0);
        add(&conn, 3, "2026-09-07", -20 * EURO, categories[0], assignments[1], 0);

        let detail = |category, assignment| {
            behind_the_cell(
                &conn,
                &[1],
                2026,
                9,
                Switches::default(),
                category,
                assignment,
            )
            .expect("détail")
            .len()
        };

        assert_eq!(detail(Some(categories[0]), Some(assignments[0])), 1, "une case");
        assert_eq!(detail(None, Some(assignments[0])), 2, "la ligne Somme");
        assert_eq!(detail(Some(categories[0]), None), 2, "la colonne Total");
        assert_eq!(detail(None, None), 3, "le total général");
    }

    /// Le détail d'une case « Sans … » ramasse aussi les classements disparus,
    /// exactement comme la case l'annonce.
    #[test]
    fn le_detail_des_sans_ramasse_les_classements_disparus() {
        let conn = database();
        add(&conn, 1, "2026-09-03", -70 * EURO, 4242, 0, 0);
        add(&conn, 2, "2026-09-04", -30 * EURO, 0, 0, 0);

        let found = behind_the_cell(
            &conn,
            &[1],
            2026,
            9,
            Switches::default(),
            Some(UNCLASSIFIED),
            Some(UNCLASSIFIED),
        )
        .expect("détail");
        assert_eq!(found.len(), 2);
    }

    /// Les interrupteurs vident le tableau sans le casser : il garde ses
    /// lignes et ses colonnes, parce qu'un plan de comptes ne dépend pas de ce
    /// qu'on regarde.
    #[test]
    fn les_interrupteurs_vident_sans_casser() {
        let conn = database();
        let category = ids(&conn, crate::nomenclatures::Nomenclature::Category)[0];
        add(&conn, 1, "2026-09-02", 2_000 * EURO, category, 0, 0);

        let credits_off = Switches {
            credits: false,
            ..Switches::default()
        };
        let matrix = crossed_at(&conn, 9, credits_off);
        assert!(!matrix.has_data);
        assert!(!matrix.rows.is_empty(), "le plan de comptes reste");

        let nothing = Switches {
            pointed: false,
            committed: false,
            planned: false,
            ..Switches::default()
        };
        let matrix = crossed_at(&conn, 9, nothing);
        assert!(!matrix.has_data);
        assert!(!matrix.columns.is_empty());

        // Et le détail, sous les mêmes interrupteurs, ne montre rien non plus.
        assert!(behind_the_cell(&conn, &[1], 2026, 9, nothing, None, None)
            .expect("détail")
            .is_empty());
    }

    /// Un mois hors bornes ne fait pas tomber le noyau : il est ramené dans
    /// 1..=12, comme partout ailleurs dans les statistiques. C'est au
    /// contrôleur de refuser un mois impossible — le noyau, lui, rend toujours
    /// un tableau.
    #[test]
    fn un_mois_impossible_ne_panique_pas() {
        let conn = database();
        for month in [0, 13, 99] {
            assert!(!crossed_at(&conn, month, Switches::default()).rows.is_empty());
        }
    }
}
