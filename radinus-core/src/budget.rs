//! Le budget — `Budget` (02_BASE_DE_DONNEES.md §3.9), les fenêtres F26 et F27.
//!
//! **Deux portes, deux questions** (règles dictées par Fabrice, 29/07/2026) :
//! on *saisit* son budget, ou on *contrôle* s'il a été tenu. Deux entrées de
//! menu distinctes, et non deux onglets d'une même fenêtre.
//!
//! **L'axe est le poste budgétaire**, jamais la catégorie — même si chaque
//! catégorie porte le sien, et que c'est par là que le réalisé remonte.
//!
//! **Le budget porte obligatoirement sur une année**, et se navigue comme les
//! statistiques : une année à la fois, en avant ou en arrière.
//!
//! **La convention de signe est celle des opérations** : une dépense s'écrit
//! négative, un revenu sans signe ou avec le plus. Ce n'est pas un détail de
//! présentation, c'est ce qui rend le budget et le réalisé directement
//! comparables — les deux nombres sont dans le même sens, et leur différence a
//! un sens immédiat sans qu'on ait à savoir de quel côté on se trouve.
//!
//! **Et c'est de là que sort la règle des couleurs**, qui tient en une
//! comparaison pour les deux sens à la fois — voir [`standing`].

use crate::statistics::{Matrix, Switches};
use rusqlite::{Connection, Result};

/// Une ligne du tableau : un poste budgétaire, ses douze mois, son total.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct BudgetRow {
    pub id: i64,
    pub label: String,
    /// Janvier à décembre, en micro-unités et **signés** : négatif pour une
    /// dépense prévue, positif pour un revenu prévu.
    pub months: [i64; 12],
    pub total: i64,
}

/// Ce que la fenêtre de saisie dessine : les postes, puis les deux lignes de
/// synthèse — les mêmes que les statistiques, pour que les deux fenêtres se
/// lisent de la même façon.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Grid {
    pub rows: Vec<BudgetRow>,
    pub sum: [i64; 12],
    pub sum_total: i64,
    /// La somme progressive, **reportée jusqu'à décembre** : en décembre elle
    /// vaut le budget de l'année même si plus rien n'a été prévu depuis juillet.
    pub cumulative: [i64; 12],
}

/// **Où l'on en est sur un poste, à un mois donné.**
///
/// La règle de Fabrice, mot pour mot : « vert quand on fait au moins aussi bien
/// que prévu, rouge quand on fait moins bien », et c'est le sens du poste qui
/// retourne la comparaison — sur une dépense on veut rester en dessous, sur un
/// revenu on veut dépasser.
///
/// **Et pourtant il n'y a qu'une comparaison**, parce que les deux montants
/// sont signés de la même façon : `réalisé >= prévu`.
///
/// - Dépense prévue −100, dépensé −80 : `−80 >= −100`, donc bien — on a
///   dépensé moins.
/// - Dépense prévue −100, dépensé −120 : moins bien.
/// - Revenu prévu +200, encaissé +250 : bien.
/// - Revenu prévu +200, encaissé +150 : moins bien.
///
/// La convention de signe fait tout le travail. C'est elle qui permet de ne pas
/// écrire deux règles qui finiraient un jour par diverger.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Standing {
    /// Au moins aussi bien que prévu — vert sombre.
    Good,
    /// Moins bien que prévu — rouge.
    Bad,
    /// Rien n'était prévu : on ne peut dire ni mieux ni moins bien, et la case
    /// reste de la couleur du texte. Peindre en vert un poste qu'on a oublié de
    /// budgéter serait une félicitation imméritée.
    Unplanned,
}

pub fn standing(planned: i64, actual: i64) -> Standing {
    if planned == 0 {
        return Standing::Unplanned;
    }
    if actual >= planned {
        Standing::Good
    } else {
        Standing::Bad
    }
}

/// Le pourcentage du budget consommé, en centièmes de point pour ne rien perdre
/// à l'arrondi — 112,50 % vaut 11250.
///
/// **Le signe s'annule** : une dépense prévue −100 dont on a dépensé −80 rend
/// 80 %. Le pourcentage dit donc « combien du prévu a été consommé », dans les
/// deux sens, et il ne dit **pas** si c'est bien ou mal : c'est [`standing`] qui
/// le dit, parce qu'à 80 % une dépense est tenue et un revenu manque.
///
/// Rien de prévu ne donne aucun pourcentage : diviser par zéro n'a pas de sens,
/// et « 0 % » en donnerait un faux.
pub fn used(planned: i64, actual: i64) -> Option<i64> {
    if planned == 0 {
        return None;
    }
    Some(actual.saturating_mul(10_000) / planned)
}

/// Une ligne du contrôle : le prévu, le réalisé, mois par mois.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ControlRow {
    pub id: i64,
    pub label: String,
    pub planned: [i64; 12],
    pub actual: [i64; 12],
    pub planned_total: i64,
    pub actual_total: i64,
}

/// Ce que la fenêtre de contrôle dessine.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Control {
    pub rows: Vec<ControlRow>,
    pub planned_sum: [i64; 12],
    pub actual_sum: [i64; 12],
    /// Le **cumul**, prévu et réalisé, sous la Somme — comme dans la saisie et
    /// dans les statistiques. C'est lui qui répond à « depuis janvier, où en
    /// suis-je », alors que la Somme ne répond que pour le mois. Reporté
    /// jusqu'à décembre, si bien qu'en fin d'année il vaut l'année entière.
    pub planned_cumulative: [i64; 12],
    pub actual_cumulative: [i64; 12],
    pub planned_total: i64,
    pub actual_total: i64,
}

/// Le budget d'une année, poste par poste.
///
/// **Tous les postes sont là**, même ceux dont aucune case n'a été saisie : le
/// tableau est un plan, pas un résumé de ce qui a été tapé — c'est la même
/// règle que la matrice des statistiques, et c'est ce qui permet de voir qu'on
/// a oublié d'en budgéter un.
pub fn grid(conn: &Connection, year: i32) -> Result<Grid> {
    grid_with(conn, year, &[])
}

/// Le même tableau, mais **avec une saisie en cours par-dessus** : poste, mois,
/// montant tel qu'il vient d'être tapé.
///
/// C'est ce qui rend les lignes Somme et Cumul vivantes. Sans cela elles ne
/// peuvent montrer que ce qui est déjà sur le disque, c'est-à-dire rien tant
/// qu'on n'a pas enregistré — et une ligne de synthèse qui reste vide pendant
/// qu'on saisit ne sert à personne (Fabrice, 29/07/2026).
///
/// Les montants arrivent **déjà lus** : la fenêtre ne lit jamais un montant,
/// c'est le noyau qui le fait, ici comme à l'écriture.
pub fn grid_with(conn: &Connection, year: i32, pending: &[(i64, i64, i64)]) -> Result<Grid> {
    let mut rows: Vec<BudgetRow> = crate::nomenclatures::list(
        conn,
        crate::nomenclatures::Nomenclature::BudgetLine,
    )?
    .into_iter()
    .map(|element| BudgetRow {
        id: element.id,
        label: element.label,
        months: [0; 12],
        total: 0,
    })
    .collect();

    let mut position = std::collections::HashMap::new();
    for (index, row) in rows.iter().enumerate() {
        position.insert(row.id, index);
    }

    let mut statement = conn.prepare(
        "SELECT IDPosteBudget, Mois, Montant FROM Budget WHERE Annee = ?1",
    )?;
    let cells = statement.query_map([year], |row| {
        Ok((
            row.get::<_, i64>(0)?,
            row.get::<_, i64>(1)?,
            row.get::<_, i64>(2)?,
        ))
    })?;
    for cell in cells {
        let (line, month, amount) = cell?;
        // Un mois hors de 1..12 est une donnée abîmée : on l'ignore plutôt que
        // de sortir du tableau.
        let Some(index) = position.get(&line).copied() else {
            continue;
        };
        if !(1..=12).contains(&month) {
            continue;
        }
        rows[index].months[(month - 1) as usize] += amount;
    }

    // La saisie en cours écrase ce qui est en base, case par case : c'est ce
    // que l'utilisateur a sous les yeux, et c'est de cela qu'il veut la somme.
    for (line, month, amount) in pending {
        let Some(index) = position.get(line).copied() else {
            continue;
        };
        if !(1..=12).contains(month) {
            continue;
        }
        rows[index].months[(*month - 1) as usize] = *amount;
    }

    let mut grid = Grid {
        rows,
        sum: [0; 12],
        sum_total: 0,
        cumulative: [0; 12],
    };
    for row in &mut grid.rows {
        row.total = row.months.iter().sum();
        for month in 0..12 {
            grid.sum[month] += row.months[month];
        }
    }
    grid.sum_total = grid.sum.iter().sum();
    let mut running = 0;
    for month in 0..12 {
        running += grid.sum[month];
        grid.cumulative[month] = running;
    }
    Ok(grid)
}

/// Écrit une case du budget : une année, un mois, un poste, un montant.
///
/// **Zéro efface la ligne** plutôt que d'écrire un zéro : une case vide et une
/// case à zéro se lisent pareil à l'écran, et garder les deux ferait grossir la
/// table d'autant de riens qu'il y a de postes et de mois.
pub fn set(conn: &Connection, year: i32, month: i64, line: i64, amount: i64) -> Result<()> {
    if !(1..=12).contains(&month) {
        return Ok(());
    }
    conn.execute(
        "DELETE FROM Budget WHERE Annee = ?1 AND Mois = ?2 AND IDPosteBudget = ?3",
        rusqlite::params![year, month, line],
    )?;
    if amount == 0 {
        return Ok(());
    }
    let id = crate::database::keygen::next_id(conn, "Budget", "IDBudget")?;
    conn.execute(
        "INSERT INTO Budget (IDBudget, Annee, Mois, IDPosteBudget, Montant)
         VALUES (?1, ?2, ?3, ?4, ?5)",
        rusqlite::params![id, year, month, line, amount],
    )?;
    Ok(())
}

/// Écrit un tableau entier d'un coup, dans **une seule transaction** : une
/// saisie de budget est un geste, pas cent quatre-vingts.
pub fn save(conn: &mut Connection, year: i32, cells: &[(i64, i64, i64)]) -> Result<()> {
    let tx = conn.transaction()?;
    for (line, month, amount) in cells {
        if !(1..=12).contains(month) {
            continue;
        }
        tx.execute(
            "DELETE FROM Budget WHERE Annee = ?1 AND Mois = ?2 AND IDPosteBudget = ?3",
            rusqlite::params![year, month, line],
        )?;
        if *amount == 0 {
            continue;
        }
        let id: i64 = tx.query_row(
            "SELECT COALESCE(MAX(IDBudget), 0) + 1 FROM Budget",
            [],
            |row| row.get(0),
        )?;
        tx.execute(
            "INSERT INTO Budget (IDBudget, Annee, Mois, IDPosteBudget, Montant)
             VALUES (?1, ?2, ?3, ?4, ?5)",
            rusqlite::params![id, year, month, line, amount],
        )?;
    }
    tx.commit()?;
    Ok(())
}

/// Le contrôle d'une année : le budget en regard du réalisé.
///
/// **Le réalisé vient de la statistique par poste budgétaire**, telle qu'elle
/// est déjà écrite — les mêmes opérations, les mêmes interrupteurs de statut,
/// le même découpage en mois. Deux façons de compter le même réalisé finiraient
/// par diverger, et l'utilisateur verrait un contrôle qui contredit sa
/// statistique.
///
/// Le budget n'ayant pas de compte dans sa table, le contrôle porte sur **tous**
/// les comptes.
pub fn control(conn: &Connection, year: i32, switches: Switches) -> Result<Control> {
    let accounts: Vec<i64> = crate::accounts::list(conn)?
        .into_iter()
        .map(|account| account.id)
        .collect();
    let realised: Matrix = crate::statistics::by_axis(
        conn,
        &accounts,
        year,
        switches,
        crate::statistics::Axis::BudgetLine,
        "",
    )?;
    let planned = grid(conn, year)?;

    let mut actual_by_line = std::collections::HashMap::new();
    for row in &realised.rows {
        actual_by_line.insert(row.id, row.months);
    }

    let mut control = Control {
        rows: Vec::with_capacity(planned.rows.len()),
        planned_sum: [0; 12],
        actual_sum: [0; 12],
        planned_cumulative: [0; 12],
        actual_cumulative: [0; 12],
        planned_total: 0,
        actual_total: 0,
    };
    for row in planned.rows {
        let actual = actual_by_line.get(&row.id).copied().unwrap_or([0; 12]);
        // Les deux sommes avancent ensemble, mois par mois : c'est un
        // appariement, pas un accès par index.
        for (month, (prevu, fait)) in row.months.iter().zip(actual.iter()).enumerate() {
            control.planned_sum[month] += prevu;
            control.actual_sum[month] += fait;
        }
        control.rows.push(ControlRow {
            id: row.id,
            label: row.label,
            planned: row.months,
            actual,
            planned_total: row.total,
            actual_total: actual.iter().sum(),
        });
    }
    control.planned_total = control.planned_sum.iter().sum();
    control.actual_total = control.actual_sum.iter().sum();
    let mut planned_running = 0;
    let mut actual_running = 0;
    for month in 0..12 {
        planned_running += control.planned_sum[month];
        actual_running += control.actual_sum[month];
        control.planned_cumulative[month] = planned_running;
        control.actual_cumulative[month] = actual_running;
    }
    Ok(control)
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

    /// **La règle des couleurs, dans les deux sens, avec une comparaison.**
    ///
    /// C'est la règle de Fabrice : vert quand on fait au moins aussi bien que
    /// prévu. La convention de signe fait le reste — et ce test est là pour
    /// qu'on ne la remplace jamais par deux règles séparées, qui divergeraient.
    #[test]
    fn le_vert_dit_toujours_la_meme_chose_dans_les_deux_sens() {
        // Une dépense prévue : on veut rester en dessous.
        assert_eq!(standing(-100, -80), Standing::Good);
        assert_eq!(standing(-100, -100), Standing::Good, "juste ce qu'il fallait");
        assert_eq!(standing(-100, -120), Standing::Bad);
        // Un revenu prévu : on veut dépasser.
        assert_eq!(standing(200, 250), Standing::Good);
        assert_eq!(standing(200, 200), Standing::Good);
        assert_eq!(standing(200, 150), Standing::Bad);
        // Rien de prévu : ni bien ni mal.
        assert_eq!(standing(0, -500), Standing::Unplanned);
        assert_eq!(standing(0, 0), Standing::Unplanned);
    }

    /// Le pourcentage dit ce qui est consommé, et **pas** si c'est bien : à
    /// 80 % une dépense est tenue et un revenu manque. La couleur vient de
    /// `standing`, jamais du pourcentage.
    #[test]
    fn le_pourcentage_ne_dit_pas_a_lui_seul_si_c_est_bien() {
        assert_eq!(used(-100, -80), Some(8_000));
        assert_eq!(used(200, 150), Some(7_500));
        assert_eq!(used(-100, -112), Some(11_200));
        assert_eq!(used(0, -500), None, "diviser par rien n'a pas de sens");

        // Le même 80 %, deux verdicts opposés.
        assert_eq!(used(-100, -80), used(200, 160));
        assert_eq!(standing(-100, -80), Standing::Good);
        assert_eq!(standing(200, 160), Standing::Bad);
    }

    fn a_budget_line(conn: &Connection, label: &str) -> i64 {
        let id = crate::database::keygen::next_id(conn, "PosteBudget", "IDPosteBudget")
            .expect("clef");
        conn.execute(
            "INSERT INTO PosteBudget (IDPosteBudget, Libelle) VALUES (?1, ?2)",
            rusqlite::params![id, label],
        )
        .expect("poste");
        id
    }

    #[test]
    fn un_budget_se_saisit_se_relit_et_se_totalise() {
        let mut conn = database();
        let line = a_budget_line(&conn, "Zzz test");

        save(
            &mut conn,
            2026,
            &[(line, 1, -100_000_000), (line, 2, -50_000_000), (line, 3, 0)],
        )
        .expect("saisie");

        let grid = grid(&conn, 2026).expect("lecture");
        let row = grid.rows.iter().find(|row| row.id == line).expect("le poste");
        assert_eq!(row.months[0], -100_000_000);
        assert_eq!(row.months[1], -50_000_000);
        assert_eq!(row.months[2], 0);
        assert_eq!(row.total, -150_000_000);
        // Le cumul se reporte jusqu'à décembre.
        assert_eq!(grid.cumulative[0], -100_000_000);
        assert_eq!(grid.cumulative[2], -150_000_000);
        assert_eq!(grid.cumulative[11], -150_000_000);
        assert_eq!(grid.sum_total, -150_000_000);

        // Tous les postes sont là, même ceux qu'on n'a pas budgétés.
        assert!(grid.rows.len() > 1);
        assert!(grid.rows.iter().any(|row| row.total == 0));
    }

    /// Zéro efface plutôt que d'écrire un zéro : une case vide et une case à
    /// zéro se lisent pareil, et garder les deux ferait grossir la table de
    /// riens.
    #[test]
    fn une_case_remise_a_zero_disparait_de_la_table() {
        let conn = database();
        let line = a_budget_line(&conn, "Zzz test");
        set(&conn, 2026, 1, line, -100_000_000).expect("écriture");
        let count = |conn: &Connection| -> i64 {
            conn.query_row("SELECT COUNT(*) FROM Budget", [], |row| row.get(0))
                .expect("compte")
        };
        assert_eq!(count(&conn), 1);
        set(&conn, 2026, 1, line, 0).expect("effacement");
        assert_eq!(count(&conn), 0);
        // Et la relecture donne bien zéro, pas l'ancien montant.
        let grid = grid(&conn, 2026).expect("lecture");
        let row = grid.rows.iter().find(|row| row.id == line).expect("le poste");
        assert_eq!(row.months[0], 0);
    }

    /// **Le croisement du contrôle.** Le réalisé du contrôle est celui de la
    /// statistique par poste budgétaire — pas un second calcul qui lui
    /// ressemble. Deux chemins, le même nombre.
    #[test]
    fn le_realise_du_controle_est_celui_de_la_statistique() {
        let conn = database();
        let line = a_budget_line(&conn, "Zzz test");
        let category = crate::database::keygen::next_id(&conn, "Categorie", "IDCategorie")
            .expect("clef");
        conn.execute(
            "INSERT INTO Categorie (IDCategorie, Libelle, IDPosteBudget)
             VALUES (?1, 'Zzz catégorie', ?2)",
            rusqlite::params![category, line],
        )
        .expect("catégorie");
        conn.execute(
            "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte) VALUES (1, 'CCP', 1)",
            [],
        )
        .expect("compte");
        conn.execute(
            "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte,
                                    IDStatutOperation, IDCategorie)
             VALUES (1, 'Courses', '2026-03-12', -80000000, 1, 1, ?1)",
            [category],
        )
        .expect("opération");

        set(&conn, 2026, 3, line, -100_000_000).expect("budget");

        let control = control(&conn, 2026, Switches::default()).expect("contrôle");
        let row = control.rows.iter().find(|row| row.id == line).expect("le poste");
        assert_eq!(row.planned[2], -100_000_000);
        assert_eq!(row.actual[2], -80_000_000);

        // Le même nombre par l'autre chemin : la statistique elle-même.
        let matrix = crate::statistics::by_axis(
            &conn,
            &[1],
            2026,
            Switches::default(),
            crate::statistics::Axis::BudgetLine,
            "",
        )
        .expect("statistique");
        let same = matrix.rows.iter().find(|row| row.id == line).expect("le poste");
        assert_eq!(row.actual[2], same.months[2]);

        // Et la couleur qui en découle : on a dépensé moins que prévu.
        assert_eq!(standing(row.planned[2], row.actual[2]), Standing::Good);
    }
}
