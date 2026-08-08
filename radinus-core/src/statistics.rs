//! La matrice des statistiques, **sur six axes**.
//!
//! Référence : `04_SPECIFICATIONS_FENETRES.md` F20-F24, `PLAN_ACTION.md` §6.1,
//! et la capture « statistique categorie operation.png ».
//!
//! **Les catégories ont servi de modèle, et Fabrice les a validées le
//! 26/07/2026** avant que les cinq autres n'existent — sa méthode, la même que
//! pour les nomenclatures : on s'arrête à une, on la rend juste, on en tire
//! les autres. Elle a payé deux fois. D'abord parce que rien n'a été réécrit :
//! seul l'axe change, et un axe tient dans deux lignes de SQL
//! ([`Axis::key_expression`] et [`Axis::source`]). Ensuite parce que tout ce
//! qu'il a corrigé sur les catégories — la règle des feuilles, la case verte,
//! le cumul de janvier à mai, la position gardée — est arrivé aux six d'un
//! coup, déjà juste.
//!
//! **Cinq axes se lisent sur l'opération ; le sixième non.** Le poste
//! budgétaire est porté par la *catégorie* de l'opération, pas par l'opération
//! elle-même. C'est la seule irrégularité des six, et elle est enfermée dans
//! [`Axis::key_expression`] pour qu'elle ne se répande nulle part ailleurs.
//!
//! **La règle des feuilles — confirmée par Fabrice le 26/07/2026.** Une
//! opération ventilée ne compte pas pour elle-même : ce sont ses
//! sous-opérations qui comptent, et une opération sans ventilation compte pour
//! elle-même. Autrement ventiler ne servirait à rien — répartir un retrait de
//! 100 € entre trois catégories n'apparaîtrait dans aucune statistique. Et les
//! totaux restent exacts, parce que le Complément fait toujours que les filles
//! somment exactement leur mère (`sub_operations::refresh_complement`) : c'est
//! d'ailleurs à cela qu'il sert. Ce qui était une déduction est maintenant une
//! règle de l'auteur, et les cinq autres statistiques la suivront.

use crate::domain::NaiveDate;
use rusqlite::{Connection, Result};

/// La première et la dernière année que Radinus regarde.
///
/// Ce sont les bornes que Fabrice a données pour le « Toutes » du menu Période
/// de F02 (25/07/2026), et il les redonne ici pour le millésime des
/// statistiques (26/07/2026) : une année est un entier entre les deux. Écrites
/// une seule fois, ici, pour que les deux fenêtres ne puissent pas diverger.
pub const FIRST_YEAR: i32 = 1950;
pub const LAST_YEAR: i32 = 2550;

/// Ramène une année dans les bornes plutôt que de la refuser.
///
/// **On impose, on ne rejette pas** (règle de Fabrice, 26/07/2026) : quelqu'un
/// qui tape 1800 voulait « le plus loin possible », et lui rendre 1950 répond
/// à son intention. Un refus l'aurait laissé devant un champ rouge à deviner
/// ce qu'on attend de lui.
pub fn year_within_bounds(year: i32) -> i32 {
    year.clamp(FIRST_YEAR, LAST_YEAR)
}

/// Les cinq interrupteurs du bandeau, dans l'ordre de la capture. Tous
/// allumés au départ : la statistique montre tout tant qu'on ne lui a rien
/// retiré.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Switches {
    pub pointed: bool,
    pub committed: bool,
    pub planned: bool,
    pub debits: bool,
    pub credits: bool,
}

impl Default for Switches {
    fn default() -> Self {
        Self {
            pointed: true,
            committed: true,
            planned: true,
            debits: true,
            credits: true,
        }
    }
}

impl Switches {
    /// Les statuts retenus (1 pointé, 2 engagé, 3 prévu —
    /// 02_BASE_DE_DONNEES.md §5.2). Vide veut dire « rien ne passe ».
    ///
    /// Ouverte au tableau de bord, qui a les trois mêmes interrupteurs et doit
    /// laisser passer exactement les mêmes opérations.
    pub(crate) fn statuses(self) -> Vec<i64> {
        let mut kept = Vec::with_capacity(3);
        if self.pointed {
            kept.push(1);
        }
        if self.committed {
            kept.push(2);
        }
        if self.planned {
            kept.push(3);
        }
        kept
    }
}

/// Une ligne de la matrice : une valeur de l'axe, ses douze mois, son total.
#[derive(Debug, Clone, PartialEq)]
pub struct MatrixRow {
    /// La clef de l'élément, ou `0` pour la ligne « Sans catégorie ».
    pub id: i64,
    pub label: String,
    /// Janvier à décembre.
    pub months: [i64; 12],
    /// Si une opération est tombée dans ce mois. **Ce n'est pas
    /// `months[m] != 0`** : une case où un crédit et un débit s'annulent vaut
    /// zéro mais n'est pas vide — l'original la peint en vert, et une case
    /// vraiment vide reste blanche. Sans ce compte, les deux seraient
    /// indistinguables.
    pub filled: [bool; 12],
    pub total: i64,
    pub total_filled: bool,
}

impl MatrixRow {
    fn empty(id: i64, label: String) -> Self {
        Self {
            id,
            label,
            months: [0; 12],
            filled: [false; 12],
            total: 0,
            total_filled: false,
        }
    }

    /// Si cette ligne ne porte rien du tout. Elle est montrée quand même —
    /// « toutes les valeurs de l'axe apparaissent, même à zéro » — mais la
    /// fenêtre peut vouloir le savoir.
    pub fn is_empty(&self) -> bool {
        !self.total_filled && !self.filled.iter().any(|filled| *filled)
    }
}

/// Ce que la fenêtre dessine : les lignes de l'axe, puis les deux lignes de
/// synthèse.
#[derive(Debug, Clone, PartialEq)]
pub struct Matrix {
    pub rows: Vec<MatrixRow>,
    /// La ligne « Somme » : le total de chaque mois, tous axes confondus.
    pub sum: [i64; 12],
    pub sum_filled: [bool; 12],
    pub sum_total: i64,
    /// La ligne « Cumul » : la somme progressive des mois, **reportée sur les
    /// mois vides jusqu'à décembre** (04_SPECIFICATIONS_FENETRES.md). C'est ce
    /// qui fait qu'en décembre elle vaut le total de l'année même si rien n'a
    /// bougé depuis juillet.
    pub cumulative: [i64; 12],
    /// Si la matrice porte la moindre donnée. Une matrice vide n'affiche pas
    /// de lignes de synthèse : il n'y a rien à synthétiser.
    pub has_data: bool,
}

/// La ligne des opérations que l'utilisateur n'a pas classées. Son libellé est
/// donné par l'appelant, qui seul connaît la langue.
const UNCLASSIFIED: i64 = 0;

/// **Sur quoi la matrice est bâtie.** C'est la seule chose qui change d'une
/// statistique à l'autre.
///
/// Les catégories ont servi de modèle et Fabrice les a validées le 26/07/2026 ;
/// les cinq autres sont sorties de celle-là sans rien réécrire d'autre que ces
/// deux lignes de SQL par axe. C'est la méthode des nomenclatures, où l'on
/// s'est arrêté aux catégories jusqu'à ce qu'elles soient justes avant d'en
/// tirer les six autres.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Axis {
    Category,
    Assignment,
    BudgetLine,
    PaymentMode,
    Payee,
    Project,
}

/// Les six, dans l'ordre où Fabrice les a demandées le 26/07/2026 — c'est
/// aussi l'ordre du menu.
pub const AXES: [Axis; 6] = [
    Axis::Category,
    Axis::Assignment,
    Axis::BudgetLine,
    Axis::PaymentMode,
    Axis::Payee,
    Axis::Project,
];

impl Axis {
    /// La nomenclature dont les éléments font les lignes.
    pub fn nomenclature(self) -> crate::nomenclatures::Nomenclature {
        use crate::nomenclatures::Nomenclature;
        match self {
            Self::Category => Nomenclature::Category,
            Self::Assignment => Nomenclature::Assignment,
            Self::BudgetLine => Nomenclature::BudgetLine,
            Self::PaymentMode => Nomenclature::PaymentMode,
            Self::Payee => Nomenclature::Payee,
            Self::Project => Nomenclature::Project,
        }
    }

    /// Le nom stable sous lequel cet axe voyage — appel IPC, étiquette de
    /// fenêtre, adresse de page. C'est celui de sa nomenclature : il n'y a
    /// pas deux vocabulaires pour désigner la même chose.
    pub fn key(self) -> &'static str {
        self.nomenclature().key()
    }

    pub fn from_key(key: &str) -> Option<Self> {
        AXES.into_iter().find(|axis| axis.key() == key)
    }

    /// **Ce qui classe une opération sur cet axe**, en SQL, sur l'alias `o`.
    ///
    /// Cinq axes lisent une colonne de l'opération elle-même. Le sixième, le
    /// poste budgétaire, **n'est pas sur l'opération** : il est porté par sa
    /// catégorie (`Categorie.IDPosteBudget`, 02_BASE_DE_DONNEES.md §3). Une
    /// opération est donc rattachée au poste de sa catégorie, et une opération
    /// sans catégorie — ou dont la catégorie a disparu — tombe dans « Sans
    /// poste budgétaire ». C'est la seule différence entre les six, et elle
    /// tient dans cette expression.
    fn key_expression(self) -> &'static str {
        self.dashboard_key()
    }

    /// La même expression, ouverte au tableau de bord (F19), qui classe lui
    /// aussi par poste budgétaire. **Une seule expression pour les deux** :
    /// deux copies de la jointure vers la catégorie, ce seraient deux
    /// occasions de diverger, et le tableau de bord ne compterait plus le même
    /// argent que la statistique du même axe.
    pub(crate) fn dashboard_key(self) -> &'static str {
        match self {
            Self::Category => "o.IDCategorie",
            Self::Assignment => "o.IDAffectation",
            Self::PaymentMode => "o.IDModeOperation",
            Self::Payee => "o.IDTiers",
            Self::Project => "o.IDProjets",
            Self::BudgetLine => {
                "COALESCE((SELECT c.IDPosteBudget FROM Categorie c
                           WHERE c.IDCategorie = o.IDCategorie), 0)"
            }
        }
    }

    /// La table où l'on va vérifier qu'un classement existe encore, et sa
    /// clef. **Un classement supprimé depuis ne fait pas disparaître un
    /// montant** : l'opération bascule dans la ligne « Sans … », elle ne
    /// s'évapore pas.
    fn source(self) -> (&'static str, &'static str) {
        match self {
            Self::Category => ("Categorie", "IDCategorie"),
            Self::Assignment => ("Affectation", "IDAffectation"),
            Self::BudgetLine => ("PosteBudget", "IDPosteBudget"),
            Self::PaymentMode => ("ModeOperation", "IDModeOperation"),
            Self::Payee => ("Tiers", "IDTiers"),
            Self::Project => ("Projets", "IDProjets"),
        }
    }
}

/// Construit la matrice **par catégories** de `year`, sur les comptes donnés.
///
/// `unclassified_label` est le nom de la ligne qui ramasse tout ce qui n'a pas
/// de catégorie — « Sans catégorie » en français. Il arrive de l'extérieur : ce
/// module ne connaît aucune langue.
pub fn by_axis(
    conn: &Connection,
    accounts: &[i64],
    year: i32,
    switches: Switches,
    axis: Axis,
    unclassified_label: &str,
) -> Result<Matrix> {
    let mut rows: Vec<MatrixRow> = Vec::new();
    let mut position: std::collections::HashMap<i64, usize> = std::collections::HashMap::new();

    // Toutes les valeurs de l'axe, dans l'ordre où les listes les montrent, et
    // même celles qui ne portent rien cette année : la matrice est un plan de
    // comptes, pas un résumé de ce qui s'est passé.
    for element in crate::nomenclatures::list(conn, axis.nomenclature())? {
        position.insert(element.id, rows.len());
        rows.push(MatrixRow::empty(element.id, element.label));
    }
    // Puis la ligne des non classées, en dernier, comme dans la capture.
    position.insert(UNCLASSIFIED, rows.len());
    rows.push(MatrixRow::empty(
        UNCLASSIFIED,
        unclassified_label.to_string(),
    ));
    let unclassified_at = rows.len() - 1;

    let mut matrix = Matrix {
        rows,
        sum: [0; 12],
        sum_filled: [false; 12],
        sum_total: 0,
        cumulative: [0; 12],
        has_data: false,
    };

    let statuses = switches.statuses();
    // Aucun statut retenu, ou ni les débits ni les crédits : il n'y a
    // strictement rien à compter, et ce n'est pas une erreur.
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

    // La règle des feuilles : une mère ventilée ne compte pas pour elle-même,
    // ses filles comptent à sa place. `NOT EXISTS` plutôt que `EstParent = 0` —
    // le drapeau peut être faux dans une base restaurée d'une vieille archive,
    // la question posée à la table ne peut pas l'être.
    // `GROUP BY 1, 2` plutôt que de répéter l'expression : celle du poste
    // budgétaire est une sous-requête, et la répéter serait l'occasion de la
    // laisser diverger d'elle-même.
    let query = format!(
        "SELECT {key},
                CAST(strftime('%m', o.Date) AS INTEGER),
                SUM(o.Montant), COUNT(*)
         FROM Operation o
         WHERE o.IDCompte IN ({accounts_in})
           AND o.Date IS NOT NULL AND o.Date >= ?a AND o.Date <= ?b
           AND o.IDStatutOperation IN ({statuses_in})
           AND (o.IDOperationParent <> 0
                OR NOT EXISTS (SELECT 1 FROM Operation f
                               WHERE f.IDOperationParent = o.IDOperation))
           {sign}
         GROUP BY 1, 2",
        key = axis.key_expression()
    );
    let query = query
        .replace("?a", &format!("'{year:04}-01-01'"))
        .replace("?b", &format!("'{year:04}-12-31'"));

    let mut parameters: Vec<i64> = accounts.to_vec();
    parameters.extend(statuses);

    let mut statement = conn.prepare(&query)?;
    let mut cells = statement.query(rusqlite::params_from_iter(parameters))?;
    while let Some(cell) = cells.next()? {
        let value: i64 = cell.get(0)?;
        let month: i64 = cell.get(1)?;
        let amount: i64 = cell.get(2)?;
        let count: i64 = cell.get(3)?;
        if count == 0 || !(1..=12).contains(&month) {
            continue;
        }
        let month = (month - 1) as usize;
        // Un classement supprimé depuis, ou le sentinelle « Non précisé » :
        // l'opération existe et son montant compte, mais sous « Sans … ». **Un
        // montant ne disparaît jamais d'une statistique parce que son
        // classement a disparu.**
        let at = *position.get(&value).unwrap_or(&unclassified_at);

        let row = &mut matrix.rows[at];
        row.months[month] += amount;
        row.filled[month] = true;
        row.total += amount;
        row.total_filled = true;

        matrix.sum[month] += amount;
        matrix.sum_filled[month] = true;
        matrix.sum_total += amount;
        matrix.has_data = true;
    }

    // Le cumul : la somme progressive, reportée jusqu'à décembre.
    let mut running = 0;
    for month in 0..12 {
        running += matrix.sum[month];
        matrix.cumulative[month] = running;
    }

    Ok(matrix)
}

/// Les années qui portent quelque chose, dans l'ordre.
///
/// **Sous les interrupteurs tels qu'ils sont posés** (choix de Fabrice,
/// 26/07/2026) : une année n'est « vide » que relativement à ce qu'on regarde.
/// Éteindre les crédits peut vider une année entière, et le classeur exporté
/// doit être ce que la fenêtre montrerait, année après année — pas autre chose.
///
/// C'est la requête de la matrice, moins le regroupement : mêmes comptes,
/// mêmes statuts, même sens des montants, même règle de la feuille. Une seule
/// façon de compter, donc aucune façon de se contredire.
pub fn years_with_data(
    conn: &Connection,
    accounts: &[i64],
    switches: Switches,
) -> Result<Vec<i32>> {
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

    let query = format!(
        "SELECT DISTINCT CAST(strftime('%Y', o.Date) AS INTEGER) AS an
         FROM Operation o
         WHERE o.IDCompte IN ({accounts_in})
           AND o.Date IS NOT NULL
           AND o.IDStatutOperation IN ({statuses_in})
           AND (o.IDOperationParent <> 0
                OR NOT EXISTS (SELECT 1 FROM Operation f
                               WHERE f.IDOperationParent = o.IDOperation))
           {sign}
         ORDER BY an"
    );

    let mut parameters: Vec<i64> = accounts.to_vec();
    parameters.extend(statuses);

    let mut statement = conn.prepare(&query)?;
    let mut found = Vec::new();
    let mut years = statement.query(rusqlite::params_from_iter(parameters))?;
    while let Some(year) = years.next()? {
        let year: i64 = year.get(0)?;
        // Une date aberrante dans une vieille archive ne doit pas fabriquer un
        // onglet « AN_0007 » : on s'en tient aux bornes de Radinus.
        let year = year as i32;
        if year_within_bounds(year) == year {
            found.push(year);
        }
    }
    Ok(found)
}

/// Quelle case de la matrice on interroge.
///
/// **Les trois sortes de cases ne demandent pas la même chose**, et c'est ce
/// qui manquait : la Somme d'un mois et le Cumul de ce même mois sont deux
/// cases distinctes, l'une au-dessus de l'autre, et cliquer l'une ne doit pas
/// choisir l'autre (Fabrice, 26/07/2026). Surtout, elles ne comptent pas les
/// mêmes opérations — le cumul de mai, ce sont celles de janvier à mai.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Cell {
    /// Un croisement de la matrice : une valeur de l'axe et un mois — ou toute
    /// l'année de cette valeur, pour la colonne Total.
    Axis { value: i64, month: Option<u32> },
    /// La ligne Somme : un mois entier, toutes valeurs de l'axe confondues —
    /// ou l'année entière pour sa colonne Total.
    Sum { month: Option<u32> },
    /// La ligne Cumul : **depuis janvier jusqu'à ce mois inclus**. C'est la
    /// définition même d'un cumul, et c'est pour cela qu'il ne peut pas
    /// partager sa sélection avec la Somme.
    Cumulative { month: u32 },
}

impl Cell {
    /// Le mois de départ et le mois de fin que cette case couvre.
    fn months(self) -> (u32, u32) {
        match self {
            Self::Axis { month: Some(month), .. } | Self::Sum { month: Some(month) } => {
                (month, month)
            }
            Self::Axis { month: None, .. } | Self::Sum { month: None } => (1, 12),
            Self::Cumulative { month } => (1, month),
        }
    }

    /// La valeur de l'axe à laquelle elle est attachée, s'il y en a une. Les
    /// deux lignes de synthèse n'en ont pas : elles portent sur tout.
    fn value(self) -> Option<i64> {
        match self {
            Self::Axis { value, .. } => Some(value),
            Self::Sum { .. } | Self::Cumulative { .. } => None,
        }
    }
}

/// Les opérations derrière une case de la matrice — le détail qui s'affiche en
/// bas quand on clique dessus.
///
/// Chaque ligne vient avec **la clef de sa mère** — `0` si elle n'en a pas.
/// Le détail mélange des opérations et des ventilations (règle des feuilles),
/// et double-cliquer dessus doit ouvrir la fiche qui convient : F03 pour une
/// opération, F04 pour une sous-opération (demande de Fabrice, 26/07/2026).
/// Sans cette clef, la fenêtre ne saurait pas laquelle des deux.
pub fn behind_the_cell(
    conn: &Connection,
    accounts: &[i64],
    year: i32,
    switches: Switches,
    axis: Axis,
    cell: Cell,
) -> Result<Vec<(crate::operations::OperationRow, i64)>> {
    let value = cell.value();
    let statuses = switches.statuses();
    if statuses.is_empty() || (!switches.debits && !switches.credits) || accounts.is_empty() {
        return Ok(Vec::new());
    }

    let (first_month, last_month) = cell.months();
    let (from, to) = (first_day(year, first_month), last_day(year, last_month));

    let accounts_in = placeholders(accounts.len());
    let statuses_in = placeholders(statuses.len());
    let sign = match (switches.debits, switches.credits) {
        (true, true) => "",
        (true, false) => "AND o.Montant < 0",
        (false, true) => "AND o.Montant > 0",
        (false, false) => unreachable!("écarté juste au-dessus"),
    };
    // La ligne « Sans … » ramasse aussi les classements disparus : **la même
    // règle qu'à la construction de la matrice**, et bâtie sur la même
    // expression, sinon un clic dessus montrerait moins que ce que la case
    // annonce.
    let key = axis.key_expression();
    let (table, column) = axis.source();
    let kept = match value {
        None => String::new(),
        Some(UNCLASSIFIED) => format!(
            "AND ({key} = {UNCLASSIFIED}
                  OR {key} NOT IN (SELECT {column} FROM {table}))"
        ),
        Some(id) => format!("AND {key} = {id}"),
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
           {kept}
         ORDER BY o.Date, o.IDOperation",
        select = crate::operations::SELECT_ROW,
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

fn placeholders(count: usize) -> String {
    std::iter::repeat_n("?", count)
        .collect::<Vec<_>>()
        .join(", ")
}

/// **Le mois ramené dans l'année, et l'année dans ses bornes.**
///
/// Sans cela, `last_day` paniquait (audit du 03/08/2026, §3). Elle appelait
/// `from_ymd_opt(…).expect(…)` sur un couple année/mois venu tel quel de la
/// fenêtre : un mois à 0 ou à 13 — un décalage d'indice, une colonne « Total »
/// comptée en treizième — et le noyau s'arrêtait net.
///
/// La panique n'aurait coûté qu'une fenêtre si la connexion à la base n'avait
/// pas été tenue au même instant. Elle l'était : le `Mutex` repartait
/// **empoisonné**, et toutes les autres fenêtres devenaient inutilisables
/// jusqu'au redémarrage.
///
/// On impose plutôt que de rejeter, comme partout ailleurs dans ce module
/// (règle de Fabrice, 26/07/2026) : **le noyau rend une date, toujours.** C'est
/// au contrôleur de refuser un mois impossible — lui seul peut le dire à
/// l'utilisateur.
fn a_real_month(year: i32, month: u32) -> (i32, u32) {
    (year_within_bounds(year), month.clamp(1, 12))
}

fn first_day(year: i32, month: u32) -> String {
    let (year, month) = a_real_month(year, month);
    format!("{year:04}-{month:02}-01")
}

/// **Une seule façon de trouver la fin d'un mois** dans tout le noyau.
///
/// Ce calcul vivait ici, en propre. La fenêtre d'accueil en avait besoin à son
/// tour (phase 17 bis) et l'a écrit dans `welcome` : deux écritures du même
/// calcul, ce sont deux occasions qu'une année bissextile soit traitée d'un
/// côté et pas de l'autre. Celle de `welcome` rend des dates plutôt que du
/// texte, ce dont la fenêtre a besoin pour nommer son mois, et celle-ci n'en
/// est plus que la mise en forme.
fn last_day(year: i32, month: u32) -> String {
    let (year, month) = a_real_month(year, month);
    // `from_ymd_opt` ne peut plus rendre `None` : le mois est dans 1..=12 et
    // l'année dans 1950..=2550. Le repli est là par principe — un noyau qui
    // calcule des comptes ne se termine pas sur un `expect`.
    let day = NaiveDate::from_ymd_opt(year, month, 1)
        .or_else(|| NaiveDate::from_ymd_opt(FIRST_YEAR, 1, 1))
        .unwrap_or_default();
    crate::welcome::month_of(day).1.format("%Y-%m-%d").to_string()
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
        for (id, label) in [(1, "CCP"), (2, "Livret")] {
            conn.execute(
                "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte, IDBanques)
                 VALUES (?1, ?2, 1, 1)",
                rusqlite::params![id, label],
            )
            .expect("compte");
        }
        conn
    }

    #[allow(clippy::too_many_arguments)]
    fn add(
        conn: &Connection,
        id: i64,
        account: i64,
        date: &str,
        amount: i64,
        category: i64,
        status: i64,
        parent: i64,
    ) {
        conn.execute(
            "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte,
                                    IDStatutOperation, IDOperationParent, IDCategorie)
             VALUES (?1, 'OP', ?2, ?3, ?4, ?5, ?6, ?7)",
            rusqlite::params![id, date, amount, account, status, parent, category],
        )
        .expect("opération");
    }

    fn matrix(conn: &Connection, accounts: &[i64], switches: Switches) -> Matrix {
        by_axis(conn, accounts, 2026, switches, Axis::Category, "Sans catégorie").expect("matrice")
    }

    fn row<'a>(matrix: &'a Matrix, label: &str) -> &'a MatrixRow {
        matrix
            .rows
            .iter()
            .find(|row| row.label == label)
            .unwrap_or_else(|| panic!("ligne « {label} » absente"))
    }

    /// La matrice est un plan de comptes : toutes les catégories y sont, même
    /// celles qui n'ont rien vu passer cette année, plus la ligne des non
    /// classées en dernier.
    #[test]
    fn every_category_has_its_line_even_at_zero() {
        let conn = database();
        let matrix = matrix(&conn, &[1], Switches::default());

        let categories =
            crate::nomenclatures::list(&conn, crate::nomenclatures::Nomenclature::Category)
                .expect("catégories");
        assert_eq!(matrix.rows.len(), categories.len() + 1);
        assert_eq!(matrix.rows.last().expect("dernière").label, "Sans catégorie");
        assert!(matrix.rows[0].is_empty());
        assert!(!matrix.has_data, "aucune opération, aucune donnée");
    }

    #[test]
    fn an_amount_lands_in_the_month_of_its_date() {
        let conn = database();
        add(&conn, 1, 1, "2026-01-15", -100 * EURO, 1, 1, 0);
        add(&conn, 2, 1, "2026-03-02", -50 * EURO, 1, 1, 0);
        let matrix = matrix(&conn, &[1], Switches::default());

        let alimentation = row(&matrix, "Alimentation");
        assert_eq!(alimentation.months[0], -100 * EURO, "janvier");
        assert_eq!(alimentation.months[2], -50 * EURO, "mars");
        assert_eq!(alimentation.months[1], 0, "février");
        assert!(!alimentation.filled[1], "et février est vide, pas à zéro");
        assert_eq!(alimentation.total, -150 * EURO);
    }

    /// Le piège des couleurs : une case où tout s'annule vaut zéro **mais
    /// n'est pas vide**. L'original la peint en vert, la vide reste blanche.
    #[test]
    fn a_cell_that_cancels_out_is_not_an_empty_cell() {
        let conn = database();
        add(&conn, 1, 1, "2026-05-02", -500 * EURO, 1, 1, 0);
        add(&conn, 2, 1, "2026-05-03", 500 * EURO, 1, 1, 0);
        let matrix = matrix(&conn, &[1], Switches::default());

        let alimentation = row(&matrix, "Alimentation");
        assert_eq!(alimentation.months[4], 0);
        assert!(alimentation.filled[4], "verte, pas blanche");
        assert!(!alimentation.filled[3], "avril, lui, est blanc");
    }

    /// **La règle des feuilles.** Une opération ventilée compte par ses
    /// filles ; le Complément fait que la somme reste exacte.
    #[test]
    fn a_ventilated_operation_counts_through_its_children() {
        let conn = database();
        // Un retrait de 100 €, classé « Divers », ventilé en 30 €
        // « Alimentation » et 70 € de Complément resté sur « Divers ».
        add(&conn, 1, 1, "2026-02-10", -100 * EURO, 20, 1, 0);
        add(&conn, 2, 1, "2026-02-10", -30 * EURO, 1, 1, 1);
        add(&conn, 3, 1, "2026-02-10", -70 * EURO, 20, 1, 1);

        let matrix = matrix(&conn, &[1], Switches::default());
        assert_eq!(row(&matrix, "Alimentation").months[1], -30 * EURO);
        // La mère ne compte pas pour elle-même : sinon on lirait -170 €.
        assert_eq!(matrix.sum[1], -100 * EURO, "la ventilation somme sa mère");
    }

    #[test]
    fn an_operation_without_children_counts_for_itself() {
        let conn = database();
        add(&conn, 1, 1, "2026-02-10", -100 * EURO, 1, 1, 0);
        assert_eq!(matrix(&conn, &[1], Switches::default()).sum[1], -100 * EURO);
    }

    /// Une catégorie effacée depuis n'efface pas les montants qu'elle portait.
    #[test]
    fn an_amount_whose_category_is_gone_falls_under_unclassified() {
        let conn = database();
        add(&conn, 1, 1, "2026-04-01", -40 * EURO, 0, 1, 0);
        add(&conn, 2, 1, "2026-04-02", -60 * EURO, 9999, 1, 0);
        let matrix = matrix(&conn, &[1], Switches::default());

        assert_eq!(row(&matrix, "Sans catégorie").months[3], -100 * EURO);
        assert_eq!(matrix.sum_total, -100 * EURO);
    }

    /// La matrice fait la synthèse de **tous** les comptes choisis.
    #[test]
    fn several_accounts_are_added_together() {
        let conn = database();
        add(&conn, 1, 1, "2026-01-05", -30 * EURO, 1, 1, 0);
        add(&conn, 2, 2, "2026-01-06", -20 * EURO, 1, 1, 0);

        assert_eq!(row(&matrix(&conn, &[1], Switches::default()), "Alimentation").months[0], -30 * EURO);
        assert_eq!(
            row(&matrix(&conn, &[1, 2], Switches::default()), "Alimentation").months[0],
            -50 * EURO
        );
    }

    #[test]
    fn the_five_switches_each_take_something_away() {
        let conn = database();
        add(&conn, 1, 1, "2026-01-05", -100 * EURO, 1, 1, 0); // pointée, débit
        add(&conn, 2, 1, "2026-01-06", -200 * EURO, 1, 2, 0); // engagée, débit
        add(&conn, 3, 1, "2026-01-07", -400 * EURO, 1, 3, 0); // prévue, débit
        add(&conn, 4, 1, "2026-01-08", 1000 * EURO, 1, 1, 0); // pointée, crédit

        let all = Switches::default();
        assert_eq!(matrix(&conn, &[1], all).sum_total, 300 * EURO);

        let only_pointed = Switches { committed: false, planned: false, ..all };
        assert_eq!(matrix(&conn, &[1], only_pointed).sum_total, 900 * EURO);

        let no_credits = Switches { credits: false, ..all };
        assert_eq!(matrix(&conn, &[1], no_credits).sum_total, -700 * EURO);

        let no_debits = Switches { debits: false, ..all };
        assert_eq!(matrix(&conn, &[1], no_debits).sum_total, 1000 * EURO);

        // Tout éteint : rien à compter, et ce n'est pas une erreur.
        let nothing = Switches { pointed: false, committed: false, planned: false, ..all };
        assert!(!matrix(&conn, &[1], nothing).has_data);
        let no_sign = Switches { debits: false, credits: false, ..all };
        assert!(!matrix(&conn, &[1], no_sign).has_data);
    }

    /// Le cumul est reporté sur les mois vides jusqu'à décembre : en décembre
    /// il vaut le total de l'année, même si plus rien n'a bougé depuis mars.
    #[test]
    fn the_running_total_is_carried_to_december() {
        let conn = database();
        add(&conn, 1, 1, "2026-01-10", 100 * EURO, 1, 1, 0);
        add(&conn, 2, 1, "2026-03-10", -30 * EURO, 1, 1, 0);
        let matrix = matrix(&conn, &[1], Switches::default());

        assert_eq!(matrix.cumulative[0], 100 * EURO);
        assert_eq!(matrix.cumulative[1], 100 * EURO, "février ne bouge pas");
        assert_eq!(matrix.cumulative[2], 70 * EURO);
        assert_eq!(matrix.cumulative[11], 70 * EURO, "décembre porte l'année");
        assert_eq!(matrix.sum_total, 70 * EURO);
        assert!(!matrix.sum_filled[1], "mais la Somme de février reste vide");
    }

    #[test]
    fn another_year_is_another_matrix() {
        let conn = database();
        add(&conn, 1, 1, "2025-06-10", -50 * EURO, 1, 1, 0);
        add(&conn, 2, 1, "2026-06-10", -70 * EURO, 1, 1, 0);

        assert_eq!(matrix(&conn, &[1], Switches::default()).sum_total, -70 * EURO);
        let previous =
            by_axis(&conn, &[1], 2025, Switches::default(), Axis::Category, "Sans catégorie").expect("matrice");
        assert_eq!(previous.sum_total, -50 * EURO);
    }

    // --- Le détail derrière une case ------------------------------------

    /// Une ventilation rendue par une case dit de qui elle est la fille : la
    /// fenêtre en a besoin pour ouvrir F04 plutôt que F03.
    #[test]
    fn a_ventilation_says_whose_daughter_it_is() {
        let conn = database();
        add(&conn, 1, 1, "2026-02-10", -100 * EURO, 20, 1, 0);
        add(&conn, 2, 1, "2026-02-10", -30 * EURO, 1, 1, 1);
        add(&conn, 3, 1, "2026-02-10", -70 * EURO, 20, 1, 1);

        let cell = Cell::Axis { value: 1, month: Some(2) };
        let detail = behind_the_cell(&conn, &[1], 2026, Switches::default(), Axis::Category, cell).expect("détail");
        assert_eq!(detail.len(), 1);
        assert_eq!(detail[0].1, 1, "fille de l'opération 1");

        // Et une opération sans mère le dit aussi, par un zéro.
        add(&conn, 4, 1, "2026-02-11", -10 * EURO, 1, 1, 0);
        let detail = behind_the_cell(&conn, &[1], 2026, Switches::default(), Axis::Category, cell).expect("détail");
        let orphan = detail.iter().find(|(row, _)| row.id == 4).expect("l'opération 4");
        assert_eq!(orphan.1, 0);
    }

    #[test]
    fn a_cell_hands_back_the_operations_behind_it() {
        let conn = database();
        add(&conn, 1, 1, "2026-01-05", -30 * EURO, 1, 1, 0);
        add(&conn, 2, 1, "2026-02-05", -40 * EURO, 1, 1, 0);
        add(&conn, 3, 1, "2026-01-06", -50 * EURO, 20, 1, 0);

        let detail = |cell: Cell| {
            behind_the_cell(&conn, &[1], 2026, Switches::default(), Axis::Category, cell).expect("détail")
        };

        // Une case : une catégorie, un mois.
        assert_eq!(detail(Cell::Axis { value: 1, month: Some(1) }).len(), 1);
        // La colonne Total d'une ligne : toute l'année de cette catégorie.
        assert_eq!(detail(Cell::Axis { value: 1, month: None }).len(), 2);
        // Une case de la ligne Somme : tout le mois, toutes catégories.
        assert_eq!(detail(Cell::Sum { month: Some(1) }).len(), 2);
        // Et le grand total : toute l'année.
        assert_eq!(detail(Cell::Sum { month: None }).len(), 3);
    }

    #[test]
    fn the_unclassified_line_hands_back_what_it_counted() {
        let conn = database();
        add(&conn, 1, 1, "2026-04-01", -40 * EURO, 0, 1, 0);
        add(&conn, 2, 1, "2026-04-02", -60 * EURO, 9999, 1, 0);
        let cell = Cell::Axis { value: 0, month: Some(4) };
        let detail = behind_the_cell(&conn, &[1], 2026, Switches::default(), Axis::Category, cell).expect("détail");
        assert_eq!(detail.len(), 2, "y compris le classement disparu");
    }

    /// Le détail obéit aux mêmes interrupteurs que la matrice : sinon on
    /// cliquerait sur une case à un montant et on lirait des lignes qui n'y
    /// sont pas comptées.
    #[test]
    fn the_detail_obeys_the_same_switches() {
        let conn = database();
        add(&conn, 1, 1, "2026-01-05", -30 * EURO, 1, 1, 0);
        add(&conn, 2, 1, "2026-01-06", 80 * EURO, 1, 1, 0);
        let only_debits = Switches { credits: false, ..Switches::default() };
        let cell = Cell::Axis { value: 1, month: Some(1) };
        let detail = behind_the_cell(&conn, &[1], 2026, only_debits, Axis::Category, cell).expect("détail");
        assert_eq!(detail.len(), 1);
        assert_eq!(detail[0].0.amount, -30 * EURO);
    }

    /// Une année hors des bornes est ramenée dedans, jamais refusée.
    #[test]
    fn a_year_outside_the_bounds_is_brought_back_into_them() {
        assert_eq!(year_within_bounds(1800), FIRST_YEAR);
        assert_eq!(year_within_bounds(0), FIRST_YEAR);
        assert_eq!(year_within_bounds(-40), FIRST_YEAR);
        assert_eq!(year_within_bounds(9999), LAST_YEAR);
        assert_eq!(year_within_bounds(2026), 2026);
        assert_eq!(year_within_bounds(FIRST_YEAR), FIRST_YEAR);
        assert_eq!(year_within_bounds(LAST_YEAR), LAST_YEAR);
    }

    /// **La Somme et le Cumul ne comptent pas la même chose.** La Somme de mai,
    /// ce sont les opérations de mai ; le Cumul de mai, celles de janvier à
    /// mai. Deux cases l'une au-dessus de l'autre, deux réponses différentes
    /// (Fabrice, 26/07/2026).
    #[test]
    fn the_running_total_of_a_month_reaches_back_to_january() {
        let conn = database();
        add(&conn, 1, 1, "2026-01-10", -10 * EURO, 1, 1, 0);
        add(&conn, 2, 1, "2026-03-10", -20 * EURO, 1, 1, 0);
        add(&conn, 3, 1, "2026-05-10", -30 * EURO, 20, 1, 0);
        add(&conn, 4, 1, "2026-09-10", -40 * EURO, 1, 1, 0);

        let detail = |cell: Cell| {
            behind_the_cell(&conn, &[1], 2026, Switches::default(), Axis::Category, cell).expect("détail")
        };

        // La Somme de mai : le mois de mai, et rien d'autre.
        assert_eq!(detail(Cell::Sum { month: Some(5) }).len(), 1);
        // Le Cumul de mai : janvier, mars et mai — pas septembre.
        assert_eq!(detail(Cell::Cumulative { month: 5 }).len(), 3);
        // Le Cumul de janvier ne remonte pas plus haut que janvier.
        assert_eq!(detail(Cell::Cumulative { month: 1 }).len(), 1);
        // Et celui de décembre, c'est l'année entière.
        assert_eq!(detail(Cell::Cumulative { month: 12 }).len(), 4);
    }

    #[test]
    fn the_last_day_of_a_month_is_the_real_one() {
        assert_eq!(last_day(2026, 1), "2026-01-31");
        assert_eq!(last_day(2026, 2), "2026-02-28");
        assert_eq!(last_day(2024, 2), "2024-02-29", "année bissextile");
        assert_eq!(last_day(2026, 12), "2026-12-31");
    }

    /// **Un mois impossible ne fait plus tomber le noyau** (audit du
    /// 03/08/2026, §3). Ces appels paniquaient tous les quatre ; ils rendent
    /// maintenant une date, ramenée dans l'année et dans les bornes.
    #[test]
    fn un_mois_impossible_ne_fait_plus_paniquer() {
        assert_eq!(last_day(2026, 0), "2026-01-31", "mois 0 ramené à janvier");
        assert_eq!(last_day(2026, 13), "2026-12-31", "mois 13 ramené à décembre");
        assert_eq!(first_day(2026, 0), "2026-01-01");
        assert_eq!(first_day(2026, 13), "2026-12-01");
        // Et l'année suit la même règle que le sélecteur des statistiques.
        assert_eq!(first_day(9999, 1), format!("{LAST_YEAR:04}-01-01"));
        assert_eq!(last_day(-40, 2), format!("{FIRST_YEAR:04}-02-28"));
    }

    // --- Les six axes ----------------------------------------------------

    /// Une opération classée sur les cinq axes qui vivent sur elle, plus la
    /// catégorie qui porte le sixième.
    fn add_classified(conn: &Connection, id: i64, date: &str, amount: i64, keys: [i64; 5]) {
        let [category, assignment, mode, payee, project] = keys;
        conn.execute(
            "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte,
                                    IDStatutOperation, IDOperationParent, IDCategorie,
                                    IDAffectation, IDModeOperation, IDTiers, IDProjets)
             VALUES (?1, 'OP', ?2, ?3, 1, 1, 0, ?4, ?5, ?6, ?7, ?8)",
            rusqlite::params![id, date, amount, category, assignment, mode, payee, project],
        )
        .expect("opération");
    }

    /// Chaque axe compte sur **sa** colonne, et pas sur celle du voisin.
    ///
    /// Une seule opération, classée différemment sur chaque axe : si deux axes
    /// lisaient la même colonne, les deux matrices se ressembleraient et
    /// personne ne le verrait à l'écran.
    #[test]
    fn each_axis_counts_on_its_own_classification() {
        let conn = database();
        for (table, id, label) in [
            ("Affectation", 907, "Essai affectation"),
            ("ModeOperation", 908, "Essai mode"),
            ("Tiers", 909, "Essai tiers"),
            ("Projets", 910, "Essai projet"),
        ] {
            conn.execute(
                &format!("INSERT INTO {table} (ID{table}, Libelle) VALUES (?1, ?2)"),
                rusqlite::params![id, label],
            )
            .expect("élément");
        }
        conn.execute(
            "INSERT INTO Categorie (IDCategorie, Libelle, IDPosteBudget) VALUES (911, 'Essai categorie', 0)",
            [],
        )
        .expect("catégorie");
        add_classified(&conn, 1, "2026-03-10", -50 * EURO, [911, 907, 908, 909, 910]);

        for (axis, label) in [
            (Axis::Category, "Essai categorie"),
            (Axis::Assignment, "Essai affectation"),
            (Axis::PaymentMode, "Essai mode"),
            (Axis::Payee, "Essai tiers"),
            (Axis::Project, "Essai projet"),
        ] {
            let built = by_axis(&conn, &[1], 2026, Switches::default(), axis, "Sans").expect("m");
            let line = row(&built, label);
            assert_eq!(
                line.months[2],
                -50 * EURO,
                "l'axe {axis:?} n'a pas compté sur sa propre colonne"
            );
            assert_eq!(built.sum[2], -50 * EURO);
        }
    }

    /// **Le poste budgétaire n'est pas sur l'opération** : il est porté par sa
    /// catégorie. C'est la seule irrégularité des six axes, et celle qu'un
    /// copier-coller depuis les catégories aurait manquée.
    #[test]
    fn the_budget_line_counts_through_the_category() {
        let conn = database();
        conn.execute(
            "INSERT INTO PosteBudget (IDPosteBudget, Libelle) VALUES (920, 'Vie courante')",
            [],
        )
        .expect("poste");
        // Deux catégories différentes, rattachées au même poste budgétaire :
        // leurs montants doivent se retrouver sur la même ligne.
        for (id, label) in [(921, "Courses"), (922, "Essence")] {
            conn.execute(
                "INSERT INTO Categorie (IDCategorie, Libelle, IDPosteBudget) VALUES (?1, ?2, 920)",
                rusqlite::params![id, label],
            )
            .expect("catégorie");
        }
        // Et une troisième sans poste : elle tombe dans « Sans poste ».
        conn.execute(
            "INSERT INTO Categorie (IDCategorie, Libelle, IDPosteBudget) VALUES (923, 'Divers', 0)",
            [],
        )
        .expect("catégorie");

        add_classified(&conn, 1, "2026-01-05", -30 * EURO, [921, 0, 0, 0, 0]);
        add_classified(&conn, 2, "2026-01-20", -20 * EURO, [922, 0, 0, 0, 0]);
        add_classified(&conn, 3, "2026-01-25", -7 * EURO, [923, 0, 0, 0, 0]);

        let built = by_axis(
            &conn,
            &[1],
            2026,
            Switches::default(),
            Axis::BudgetLine,
            "Sans poste",
        )
        .expect("matrice");

        assert_eq!(
            row(&built, "Vie courante").months[0],
            -50 * EURO,
            "deux catégories d'un même poste se somment sur sa ligne"
        );
        assert_eq!(row(&built, "Sans poste").months[0], -7 * EURO);
        assert_eq!(built.sum[0], -57 * EURO, "et rien n'est perdu en route");

        // Le détail d'une case suit exactement la même règle : cliquer la
        // ligne du poste doit montrer les deux opérations qu'elle compte.
        let detail = behind_the_cell(
            &conn,
            &[1],
            2026,
            Switches::default(),
            Axis::BudgetLine,
            Cell::Axis { value: 920, month: Some(1) },
        )
        .expect("détail");
        assert_eq!(detail.len(), 2);

        // Et la ligne « Sans poste » ramasse la catégorie qui n'en a pas.
        let orphans = behind_the_cell(
            &conn,
            &[1],
            2026,
            Switches::default(),
            Axis::BudgetLine,
            Cell::Axis { value: UNCLASSIFIED, month: Some(1) },
        )
        .expect("détail");
        assert_eq!(orphans.len(), 1);
    }

    /// Un classement supprimé depuis ne fait pas disparaître un montant : il
    /// bascule dans la ligne « Sans … ». Vérifié sur les six axes, parce que
    /// c'est la règle qui protège les totaux.
    #[test]
    fn a_classification_that_has_disappeared_never_loses_its_amount() {
        let conn = database();
        // Des clefs qui ne correspondent à rien : l'élément a été supprimé
        // depuis, comme dans une base restaurée d'une vieille archive.
        add_classified(&conn, 1, "2026-06-15", -12 * EURO, [999, 999, 999, 999, 999]);

        for axis in AXES {
            let built = by_axis(&conn, &[1], 2026, Switches::default(), axis, "Sans").expect("m");
            assert_eq!(
                row(&built, "Sans").months[5],
                -12 * EURO,
                "l'axe {axis:?} a perdu un montant dont le classement n'existe plus"
            );
            assert_eq!(built.sum_total, -12 * EURO, "l'axe {axis:?} fausse son total");

            let detail = behind_the_cell(
                &conn,
                &[1],
                2026,
                Switches::default(),
                axis,
                Cell::Axis { value: UNCLASSIFIED, month: Some(6) },
            )
            .expect("détail");
            assert_eq!(
                detail.len(),
                1,
                "l'axe {axis:?} annonce une case qu'il ne sait pas ouvrir"
            );
        }
    }

    /// **Là où deux logiques se rencontrent** (principe donné par Fabrice le
    /// 26/07/2026 : les meilleurs tests sont ceux qui croisent les données, ou
    /// qui se tiennent aux deux bouts du problème).
    ///
    /// La matrice et le détail sont **deux requêtes SQL écrites séparément**.
    /// L'une groupe et somme, l'autre ramène les lignes une par une. Rien dans
    /// le code n'oblige la seconde à répondre de la première : elles ont leur
    /// propre clause de comptes, de statuts, de signe, leur propre règle des
    /// feuilles, leur propre expression d'axe. Elles ne peuvent s'accorder que
    /// si elles ont toutes les deux raison.
    ///
    /// Ce test les confronte sur **toutes** les cases des six axes : chaque
    /// chiffre affiché doit être exactement la somme des opérations que le
    /// clic sur cette case fait apparaître. Une case qui montrerait un total
    /// que son détail ne justifie pas est le pire défaut possible dans un
    /// logiciel d'argent — et c'est précisément ce qu'aucun test de fenêtre ne
    /// peut voir.
    #[test]
    fn every_figure_is_justified_by_the_operations_behind_it() {
        let conn = database();

        // De quoi croiser pour de bon : deux comptes, des débits et des
        // crédits, plusieurs mois, une opération ventilée, une opération sans
        // classement, une autre dont le classement a été supprimé depuis, et
        // deux catégories rattachées au même poste budgétaire.
        conn.execute(
            "INSERT INTO PosteBudget (IDPosteBudget, Libelle) VALUES (930, 'Vie courante')",
            [],
        )
        .expect("poste");
        for (id, label, poste) in [(931, "Courses", 930), (932, "Essence", 930), (933, "Divers", 0)]
        {
            conn.execute(
                "INSERT INTO Categorie (IDCategorie, Libelle, IDPosteBudget) VALUES (?1, ?2, ?3)",
                rusqlite::params![id, label, poste],
            )
            .expect("catégorie");
        }
        for (table, id, label) in [
            ("Affectation", 940, "Essai affectation"),
            ("ModeOperation", 941, "Essai mode"),
            ("Tiers", 942, "Essai tiers"),
            ("Projets", 943, "Essai projet"),
        ] {
            conn.execute(
                &format!("INSERT INTO {table} (ID{table}, Libelle) VALUES (?1, ?2)"),
                rusqlite::params![id, label],
            )
            .expect("élément");
        }

        let put = |id: i64, account: i64, date: &str, amount: i64, keys: [i64; 5], parent: i64| {
            let [category, assignment, mode, payee, project] = keys;
            conn.execute(
                "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte,
                                        IDStatutOperation, IDOperationParent, IDCategorie,
                                        IDAffectation, IDModeOperation, IDTiers, IDProjets)
                 VALUES (?1, 'OP', ?2, ?3, ?4, 1, ?5, ?6, ?7, ?8, ?9, ?10)",
                rusqlite::params![
                    id, date, amount, account, parent, category, assignment, mode, payee, project
                ],
            )
            .expect("opération");
        };

        put(1, 1, "2026-01-05", -30 * EURO, [931, 940, 941, 942, 943], 0);
        put(2, 1, "2026-01-20", -20 * EURO, [932, 0, 941, 0, 0], 0);
        put(3, 2, "2026-02-01", 2216 * EURO, [933, 940, 0, 942, 0], 0);
        // Une opération sans aucun classement.
        put(4, 1, "2026-03-15", -12 * EURO, [0, 0, 0, 0, 0], 0);
        // Une dont tous les classements ont disparu depuis.
        put(5, 1, "2026-03-16", -8 * EURO, [999, 999, 999, 999, 999], 0);
        // Une mère ventilée : elle ne compte pas, ses deux filles comptent.
        put(6, 1, "2026-04-10", -100 * EURO, [931, 0, 941, 0, 0], 0);
        put(7, 1, "2026-04-10", -60 * EURO, [931, 940, 941, 0, 943], 6);
        put(8, 1, "2026-04-10", -40 * EURO, [932, 0, 941, 942, 0], 6);
        // Un débit et un crédit qui s'annulent dans le même mois : la case
        // vaut zéro sans être vide, et son détail doit tout de même montrer
        // les deux lignes.
        put(9, 2, "2026-05-02", -75 * EURO, [933, 940, 0, 0, 0], 0);
        put(10, 2, "2026-05-03", 75 * EURO, [933, 940, 0, 0, 0], 0);

        let accounts = [1, 2];
        // Trois réglages d'interrupteurs, pour que les deux requêtes soient
        // confrontées sur des populations différentes et non sur une seule.
        let settings = [
            Switches::default(),
            Switches { credits: false, ..Switches::default() },
            Switches { debits: false, ..Switches::default() },
        ];

        let behind = |axis: Axis, switches: Switches, cell: Cell| -> i64 {
            behind_the_cell(&conn, &accounts, 2026, switches, axis, cell)
                .expect("détail")
                .iter()
                .map(|(row, _)| row.amount)
                .sum()
        };

        let mut confronted = 0;
        for axis in AXES {
            for switches in settings {
                let built =
                    by_axis(&conn, &accounts, 2026, switches, axis, "Sans").expect("matrice");

                for line in &built.rows {
                    for month in 0..12u32 {
                        let cell = Cell::Axis { value: line.id, month: Some(month + 1) };
                        assert_eq!(
                            line.months[month as usize],
                            behind(axis, switches, cell),
                            "axe {axis:?}, ligne « {} », mois {} : le chiffre affiché n'est pas \
                             la somme des opérations que son détail montre",
                            line.label,
                            month + 1
                        );
                        confronted += 1;
                    }
                    // La colonne Total de la ligne : toute l'année.
                    assert_eq!(
                        line.total,
                        behind(axis, switches, Cell::Axis { value: line.id, month: None }),
                        "axe {axis:?}, ligne « {} » : le total de l'année ne vaut pas son détail",
                        line.label
                    );
                    confronted += 1;
                }

                // La ligne Somme, mois par mois puis sur l'année.
                for month in 0..12u32 {
                    assert_eq!(
                        built.sum[month as usize],
                        behind(axis, switches, Cell::Sum { month: Some(month + 1) }),
                        "axe {axis:?} : la Somme du mois {} ne vaut pas son détail",
                        month + 1
                    );
                    confronted += 1;
                }
                assert_eq!(
                    built.sum_total,
                    behind(axis, switches, Cell::Sum { month: None })
                );

                // Et la ligne Cumul, qui remonte à janvier — c'est là que les
                // deux logiques ont le plus d'occasions de diverger.
                for month in 1..=12u32 {
                    assert_eq!(
                        built.cumulative[(month - 1) as usize],
                        behind(axis, switches, Cell::Cumulative { month }),
                        "axe {axis:?} : le Cumul de {month} ne vaut pas les opérations de \
                         janvier à {month}"
                    );
                    confronted += 1;
                }

                // Et le croisement le plus simple de tous : la Somme d'un mois
                // est la somme de sa colonne, quel que soit l'axe.
                for month in 0..12usize {
                    let column: i64 = built.rows.iter().map(|line| line.months[month]).sum();
                    assert_eq!(
                        built.sum[month], column,
                        "axe {axis:?} : la ligne Somme ne vaut pas sa colonne au mois {}",
                        month + 1
                    );
                }
                // Donc les six axes, qui répartissent différemment, doivent
                // tous arriver au même total d'année.
                assert_eq!(
                    built.sum_total,
                    built.rows.iter().map(|line| line.total).sum::<i64>(),
                    "axe {axis:?} : le total de l'année ne vaut pas la somme de ses lignes"
                );
            }
        }
        assert!(
            confronted > 1000,
            "seulement {confronted} cases confrontées : le jeu d'essai s'est vidé"
        );

        // Le croisement final, celui qui vaut pour tout le reste : **les six
        // axes rangent les mêmes opérations autrement, donc ils doivent tomber
        // sur le même total**. Si un axe perdait une opération en route — un
        // classement disparu, une catégorie sans poste budgétaire — c'est ici
        // que cela se verrait, et nulle part ailleurs.
        let totals: Vec<i64> = AXES
            .iter()
            .map(|axis| {
                by_axis(&conn, &accounts, 2026, Switches::default(), *axis, "Sans")
                    .expect("matrice")
                    .sum_total
            })
            .collect();
        assert!(
            totals.windows(2).all(|pair| pair[0] == pair[1]),
            "les six axes ne comptent pas le même argent : {totals:?}"
        );
        // Et ce total est bien celui des opérations qui comptent : les feuilles
        // seules, la mère ventilée exclue.
        assert_eq!(
            totals[0],
            -30 * EURO + -20 * EURO + 2216 * EURO + -12 * EURO + -8 * EURO + -60 * EURO
                + -40 * EURO + -75 * EURO + 75 * EURO,
            "le total ne correspond pas aux opérations posées à la main"
        );
    }

    /// Les six axes voyagent sous un nom stable, et c'est celui de leur
    /// nomenclature : un seul vocabulaire pour désigner la même chose.
    #[test]
    fn every_axis_travels_under_the_name_of_its_nomenclature() {
        for axis in AXES {
            assert_eq!(Axis::from_key(axis.key()), Some(axis));
            assert_eq!(axis.key(), axis.nomenclature().key());
        }
        assert_eq!(Axis::from_key("bank"), None, "une banque ne classe rien");
        assert_eq!(Axis::from_key("n'importe quoi"), None);
    }
}
