//! Les opérations périodiques — F15, F38 et F16 (phase 16).
//!
//! Portage de `Class_EcheanceOPPeriod`, `FEN_FicheOpPeriode`,
//! `FEN_ListeOpPeriode` et `FEN_GenereOpPeriode`, avec les règles que Fabrice a
//! dictées le 31/07/2026 avant tout code.
//!
//! # Une règle ne produit rien toute seule
//!
//! Rien ne se déclenche au lancement du logiciel — Fabrice l'a tranché, et la
//! ligne que le plan d'action portait à ce sujet venait d'une déduction de la
//! rétro-ingénierie, pas de son programme. Une règle attend qu'on lui demande
//! son calendrier, et **le calendrier n'écrit rien non plus** : il propose, on
//! y retire ce qu'on ne veut pas, et c'est un second geste qui insère.
//!
//! # Le GUID est le seul lien entre une règle et ce qu'elle a produit
//!
//! Une échéance insérée devient une opération ordinaire, que rien ne distingue
//! d'une saisie à la main — sauf ce GUID, recopié dans chacune. Il sert aux
//! trois chiffres de consultation de la fiche, il sert à effacer d'un coup ce
//! qu'une règle a produit, et il **survit à la règle** : supprimer la règle
//! laisse les opérations, qui gardent leur marque.
//!
//! C'est un GUID et non le numéro de la règle pour une raison précise : les
//! clefs de Radinus se fabriquent en prenant la plus grande plus un, si bien
//! que supprimer la dernière règle libère son numéro. La règle suivante le
//! reprendrait et hériterait de l'historique de la précédente — ses trois
//! chiffres compteraient des opérations qui ne sont pas les siennes.
//!
//! # Les décisions de Fabrice, 31/07/2026
//!
//!   * **le statut vient de la date** : une échéance déjà passée entre en
//!     `Pointé`, une échéance à venir en `Prévu`. Une opération pointée compte
//!     dans le solde en banque, une opération prévue seulement dans le solde
//!     final — c'est exactement ce que ces deux cas sont ;
//!   * **la règle se décale après insertion**, au cul de la dernière échéance
//!     réellement insérée : ce qui a été retiré du calendrier reviendra dans la
//!     proposition suivante ;
//!   * **la corbeille de la fiche efface les opérations produites**, par le
//!     GUID, après confirmation et avec recalcul des soldes — mais **la règle
//!     ne recule pas** : effacer et rejouer sont deux gestes distincts ;
//!   * **tout ou rien** à l'insertion comme à l'effacement ;
//!   * une règle dont le compte n'existe plus est **écartée en silence**
//!     (fidélité à son code) ; sa fiche le dira si l'utilisateur s'en étonne.

use crate::domain::NaiveDate;
use rusqlite::{Connection, Result};
use time_compute::{Days, Months};

/// Le plafond de son `m_nLimite`. **Il s'applique aux trois façons de finir**,
/// y compris « sans limite » — qui veut donc dire cent échéances, pas l'infini.
pub const MOST_OCCURRENCES: usize = 100;

/// L'unité de la période. Les identifiants sont ceux de sa base et de son
/// `Date_EcheanceSuivante`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Unit {
    Day = 1,
    Week = 2,
    Month = 3,
    Quarter = 4,
    Year = 5,
}

impl Unit {
    pub const ALL: [Unit; 5] = [Unit::Day, Unit::Week, Unit::Month, Unit::Quarter, Unit::Year];

    pub fn key(self) -> &'static str {
        match self {
            Unit::Day => "day",
            Unit::Week => "week",
            Unit::Month => "month",
            Unit::Quarter => "quarter",
            Unit::Year => "year",
        }
    }

    pub fn from_id(id: i64) -> Self {
        match id {
            1 => Unit::Day,
            2 => Unit::Week,
            4 => Unit::Quarter,
            5 => Unit::Year,
            _ => Unit::Month,
        }
    }

    pub fn id(self) -> i64 {
        self as i64
    }
}

/// Comment la série s'arrête — son `ModeFinInsertion`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Ending {
    /// Sans limite — c'est-à-dire [`MOST_OCCURRENCES`].
    NoLimit = 1,
    /// Jusqu'à une date de fin, incluse.
    UntilDate = 2,
    /// Un nombre de répétitions.
    RepeatCount = 3,
}

impl Ending {
    pub fn key(self) -> &'static str {
        match self {
            Ending::NoLimit => "no-limit",
            Ending::UntilDate => "until-date",
            Ending::RepeatCount => "repeat-count",
        }
    }

    pub fn from_id(id: i64) -> Self {
        match id {
            2 => Ending::UntilDate,
            3 => Ending::RepeatCount,
            _ => Ending::NoLimit,
        }
    }

    pub fn id(self) -> i64 {
        self as i64
    }
}

/// Une règle de génération, telle que sa fiche la tient.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Rule {
    /// Le numéro visible, celui de sa colonne `IDOperation` et de son
    /// « Identifiant de Operation ».
    pub id: i64,
    /// La marque que porteront toutes les opérations produites.
    pub guid: String,
    pub account_id: i64,
    pub label: String,
    /// Signé, en micro-unités — le signe vient de la combo Débit/Crédit.
    pub amount: i64,
    pub category_id: i64,
    pub assignment_id: i64,
    pub payment_mode_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
    pub next_date: Option<NaiveDate>,
    pub ending: Ending,
    pub end_date: Option<NaiveDate>,
    pub unit: Unit,
    pub frequency: i64,
    pub repeat_count: i64,
}

impl Default for Rule {
    fn default() -> Self {
        Self {
            id: 0,
            guid: String::new(),
            account_id: 0,
            label: String::new(),
            amount: 0,
            category_id: 0,
            assignment_id: 0,
            payment_mode_id: 0,
            payee_id: 0,
            project_id: 0,
            next_date: None,
            ending: Ending::NoLimit,
            end_date: None,
            unit: Unit::Month,
            frequency: 1,
            repeat_count: 1,
        }
    }
}

/// Les trois chiffres du bas de la fiche : ce que **cette** règle a déjà
/// produit.
///
/// « Cela permet de savoir visuellement si des opérations ont déjà été
/// renseignées » (Fabrice, 31/07/2026). Chaque fiche montre les siens : son
/// `Genere_StatOpPeriod` ne remet à zéro que le total des montants entre deux
/// règles, si bien qu'à partir de la deuxième le compteur additionnait celui
/// des précédentes — un défaut, pas un comportement à porter.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct Produced {
    pub count: i64,
    pub total: i64,
    pub last_date: Option<NaiveDate>,
}

/// La `step`-ième échéance après l'origine — **toujours comptée depuis
/// l'origine**, jamais depuis la précédente.
///
/// C'est là toute la règle du mois calendaire, et elle est de Fabrice
/// (31/07/2026) : « lorsque la période est le mois et que la première date
/// d'échéance est le 1er du mois, il faut que les échéances suivantes soient le
/// premier du mois aussi ; et lorsqu'on part d'un 31 janvier, l'échéance
/// suivante sera un 28 février, ou un 29 les années bissextiles ».
///
/// # Pourquoi compter depuis l'origine change tout
///
/// Le rabotage du quantième doit être **une correction d'affichage, pas un
/// déplacement de la série**. En enchaînant chaque échéance sur la précédente,
/// le 31 janvier donne le 28 février, puis le 28 mars, puis le 28 avril : le
/// quantième d'origine est perdu dès le premier mois court, et la série dérive
/// pour toujours. En comptant depuis l'origine, il donne le 31 janvier, le
/// 28 février, le **31 mars**, le 30 avril, le 31 mai — chaque mois retrouve
/// son quantième dès que le calendrier le permet.
///
/// Les jours et les semaines ne connaissent pas ce problème : `n` fois un
/// nombre de jours donne le même résultat des deux façons.
pub fn nth_after(origin: NaiveDate, unit: Unit, frequency: i64, step: i64) -> Option<NaiveDate> {
    if step <= 0 {
        return Some(origin);
    }
    let total = u32::try_from(frequency.max(1).checked_mul(step)?).ok()?;
    match unit {
        Unit::Day => origin.checked_add_days(Days::new(u64::from(total))),
        Unit::Week => origin.checked_add_days(Days::new(u64::from(total) * 7)),
        Unit::Month => origin.checked_add_months(Months::new(total)),
        Unit::Quarter => origin.checked_add_months(Months::new(total.checked_mul(3)?)),
        Unit::Year => origin.checked_add_months(Months::new(total.checked_mul(12)?)),
    }
}

/// L'échéance qui suit immédiatement l'origine — `nth_after` au premier pas.
///
/// **À n'employer que sur une origine**, jamais pour enchaîner : deux appels
/// successifs perdraient le quantième, ce que le doc de [`nth_after`] explique.
pub fn next_after(date: NaiveDate, unit: Unit, frequency: i64) -> Option<NaiveDate> {
    nth_after(date, unit, frequency, 1)
}

/// Les échéances que cette règle propose — le portage de son `Gen_Echeances`.
///
/// **La première est toujours produite**, à la date de prochaine opération,
/// avant même d'examiner la condition de fin. Les suivantes s'enchaînent tant
/// que `Existe_EcheanceSuivante` dit oui, et le plafond des cent s'applique
/// aux trois façons de finir.
pub fn occurrences(rule: &Rule) -> Vec<NaiveDate> {
    let Some(first) = rule.next_date else {
        return Vec::new();
    };

    // **La première échéance est posée sans condition, et c'est voulu.**
    //
    // Elle a été corrigée puis remise en place le 03/08/2026. Mon audit du
    // même jour la donnait pour un défaut : une règle dont `DateProchOp` a
    // dépassé `DateFin` propose quand même cette échéance. Fabrice a demandé
    // de vérifier dans son code plutôt que de juger, et son code tranche —
    // `Class_EcheanceOPPeriod.Gen_Echeances()` :
    //
    // ```wlangage
    // m_nIteration = 1
    // …
    // m_tabEche.Ajoute(m_stEnrEche)      // la 1re échéance, sans condition
    // TANTQUE Existe_EcheanceSuivante()
    // ```
    //
    // et `Existe_EcheanceSuivante()` ne compare `m_dDateFin` qu'à l'échéance
    // **suivante** (`CAS 2`). `FEN_GenereOpPeriode` ne filtre rien avant
    // l'appel. Radinus 1.9.3 se comporte donc exactement ainsi depuis
    // toujours, et le portage lui est fidèle.
    //
    // **Fidélité au WinDev, décision de Fabrice du 03/08/2026** : ce n'est pas
    // un défaut à corriger, c'est le logiciel qu'il a écrit. Que celui qui
    // relira ce code ne le « répare » pas une deuxième fois.
    let mut dates = vec![first];

    while dates.len() < MOST_OCCURRENCES {
        // **Depuis l'origine**, et non depuis la précédente : c'est ce qui
        // rend le 31 mars au mois suivant le 28 février.
        let Some(next) = nth_after(first, rule.unit, rule.frequency, dates.len() as i64) else {
            break;
        };
        let allowed = match rule.ending {
            Ending::NoLimit => true,
            // Sa comparaison porte sur l'échéance **suivante**, et la date de
            // fin est incluse.
            Ending::UntilDate => rule.end_date.is_some_and(|end| next <= end),
            Ending::RepeatCount => (dates.len() as i64) < rule.repeat_count,
        };
        if !allowed {
            break;
        }
        dates.push(next);
    }
    dates
}

/// Pourquoi cette règle ne peut pas être enregistrée, ou `None`. La clef
/// Fluent est rendue plutôt que la phrase : ce module ne parle aucune langue.
///
/// Les cinq contrôles de son `Valide_Formulaire`, dans son ordre. **Le passé
/// n'est pas interdit** : sa barrière porte sur l'an 2000, pas sur aujourd'hui,
/// et Fabrice l'a confirmé — on rattrape parfois des mois oubliés.
pub fn refusal(conn: &Connection, rule: &Rule) -> Result<Option<&'static str>> {
    if rule.label.trim().is_empty() {
        return Ok(Some("recurring-refusal-label-required"));
    }
    let Some(next) = rule.next_date else {
        return Ok(Some("recurring-refusal-date-required"));
    };
    let floor = NaiveDate::from_ymd_opt(2000, 1, 1);
    if floor.is_some_and(|floor| next < floor) {
        return Ok(Some("recurring-refusal-date-too-old"));
    }
    if crate::accounts::get(conn, rule.account_id)?.is_none() {
        return Ok(Some("recurring-refusal-account-gone"));
    }
    if rule.ending == Ending::UntilDate {
        let Some(end) = rule.end_date else {
            return Ok(Some("recurring-refusal-end-required"));
        };
        if end < next {
            return Ok(Some("recurring-refusal-end-before-start"));
        }
        if (end - next).num_days() > 10_000 {
            return Ok(Some("recurring-refusal-end-too-far"));
        }
    }
    Ok(None)
}

// ---------------------------------------------------------------------------
// Persistance des règles
// ---------------------------------------------------------------------------

fn iso(date: Option<NaiveDate>) -> Option<String> {
    date.map(|day| day.format("%Y-%m-%d").to_string())
}

fn day(text: Option<String>) -> Option<NaiveDate> {
    text.and_then(|text| NaiveDate::parse_from_str(&text, "%Y-%m-%d").ok())
}

const COLUMNS: &str = "IDOperation, GUIDCalOpPeriode, IDCompte, Libelle, Montant, IDCategorie,
     IDAffectation, IDModeOperation, IDTiers, IDProjets, DateProchOp, ModeFinInsertion,
     DateFin, Periode, PeriodeFreq, PeriodeNbrRepete";

fn read_rule(row: &rusqlite::Row<'_>) -> Result<Rule> {
    Ok(Rule {
        id: row.get(0)?,
        guid: row.get(1)?,
        account_id: row.get(2)?,
        label: row.get(3)?,
        amount: row.get(4)?,
        category_id: row.get(5)?,
        assignment_id: row.get(6)?,
        payment_mode_id: row.get(7)?,
        payee_id: row.get(8)?,
        project_id: row.get(9)?,
        next_date: day(row.get(10)?),
        ending: Ending::from_id(row.get(11)?),
        end_date: day(row.get(12)?),
        unit: Unit::from_id(row.get(13)?),
        frequency: row.get(14)?,
        repeat_count: row.get(15)?,
    })
}

/// Toutes les règles, dans l'ordre de la liste F38 — par libellé, sous la
/// collation française du logiciel.
pub fn list(conn: &Connection) -> Result<Vec<Rule>> {
    let mut statement = conn.prepare(&format!("SELECT {COLUMNS} FROM CalOpPeriodique"))?;
    let mut rules: Vec<Rule> = statement
        .query_map([], read_rule)?
        .collect::<Result<_>>()?;
    rules.sort_by(|a, b| {
        crate::text::french_sort_key(&a.label)
            .cmp(&crate::text::french_sort_key(&b.label))
            .then(a.id.cmp(&b.id))
    });
    Ok(rules)
}

/// Une règle par son numéro visible, ou `None`.
pub fn get(conn: &Connection, id: i64) -> Result<Option<Rule>> {
    let mut statement = conn.prepare(&format!(
        "SELECT {COLUMNS} FROM CalOpPeriodique WHERE IDOperation = ?1"
    ))?;
    let mut rows = statement.query([id])?;
    match rows.next()? {
        Some(row) => Ok(Some(read_rule(row)?)),
        None => Ok(None),
    }
}

/// Le plus grand numéro plus un — son `Genere_Clef`, la même mécanique que
/// partout ailleurs dans Radinus.
fn next_number(conn: &Connection) -> Result<i64> {
    conn.query_row(
        "SELECT COALESCE(MAX(IDOperation), 0) + 1 FROM CalOpPeriodique",
        [],
        |row| row.get(0),
    )
}

/// Ajoute une règle. **Le GUID est fabriqué ici**, à la création, et ne
/// changera plus de sa vie : les échéances de janvier et celles de décembre
/// portent le même.
pub fn create(conn: &Connection, rule: &Rule, guid: &str) -> Result<i64> {
    let id = next_number(conn)?;
    conn.execute(
        "INSERT INTO CalOpPeriodique (GUIDCalOpPeriode, IDOperation, IDCompte, Libelle, Montant,
             IDCategorie, IDAffectation, IDModeOperation, IDTiers, IDProjets, DateProchOp,
             ModeFinInsertion, DateFin, Periode, PeriodeFreq, PeriodeNbrRepete,
             IDStatutOperation, DateDernOpGen, NbrOpInsert, NbrOpAnterieur, MontantInsert)
         VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13, ?14, ?15, ?16,
                 0, NULL, 0, 0, 0)",
        rusqlite::params![
            guid,
            id,
            rule.account_id,
            rule.label.trim(),
            rule.amount,
            rule.category_id,
            rule.assignment_id,
            rule.payment_mode_id,
            rule.payee_id,
            rule.project_id,
            iso(rule.next_date),
            rule.ending.id(),
            iso(rule.end_date),
            rule.unit.id(),
            rule.frequency,
            rule.repeat_count,
        ],
    )?;
    Ok(id)
}

/// Change une règle. **Le GUID n'est jamais touché** : il est l'identité de ce
/// qu'elle a produit, et le changer orphelinerait tout l'historique.
pub fn update(conn: &Connection, id: i64, rule: &Rule) -> Result<bool> {
    let changed = conn.execute(
        "UPDATE CalOpPeriodique SET IDCompte = ?1, Libelle = ?2, Montant = ?3, IDCategorie = ?4,
             IDAffectation = ?5, IDModeOperation = ?6, IDTiers = ?7, IDProjets = ?8,
             DateProchOp = ?9, ModeFinInsertion = ?10, DateFin = ?11, Periode = ?12,
             PeriodeFreq = ?13, PeriodeNbrRepete = ?14
         WHERE IDOperation = ?15",
        rusqlite::params![
            rule.account_id,
            rule.label.trim(),
            rule.amount,
            rule.category_id,
            rule.assignment_id,
            rule.payment_mode_id,
            rule.payee_id,
            rule.project_id,
            iso(rule.next_date),
            rule.ending.id(),
            iso(rule.end_date),
            rule.unit.id(),
            rule.frequency,
            rule.repeat_count,
            id,
        ],
    )?;
    Ok(changed > 0)
}

/// Supprime des règles. **Leurs opérations restent** (décision de Fabrice,
/// 31/07/2026) : ce sont de vraies écritures, passées en banque pour
/// certaines. Supprimer la règle arrête l'avenir et ne touche pas au passé —
/// et les opérations gardent leur GUID, donc leur origine reste lisible.
pub fn delete(conn: &Connection, ids: &[i64]) -> Result<usize> {
    let mut removed = 0;
    for id in ids {
        removed += conn.execute("DELETE FROM CalOpPeriodique WHERE IDOperation = ?1", [id])?;
    }
    Ok(removed)
}

/// Ce que cette règle a déjà produit, compté sur son GUID.
///
/// **Les sous-opérations ne comptent pas** : elles héritent du GUID de leur
/// mère, et les compter reviendrait à compter l'argent deux fois. C'est ce que
/// fait son code, et c'est juste.
pub fn produced(conn: &Connection, guid: &str) -> Result<Produced> {
    let mut statement = conn.prepare(
        "SELECT COUNT(*), COALESCE(SUM(Montant), 0), MAX(Date)
         FROM Operation WHERE GUIDCalOpPeriode = ?1 AND IDOperationParent = 0",
    )?;
    let mut rows = statement.query([guid])?;
    let Some(row) = rows.next()? else {
        return Ok(Produced::default());
    };
    Ok(Produced {
        count: row.get(0)?,
        total: row.get(1)?,
        last_date: day(row.get(2)?),
    })
}

// ---------------------------------------------------------------------------
// Le calendrier — F16
// ---------------------------------------------------------------------------

/// Une échéance proposée, telle que le calendrier la montre.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Occurrence {
    /// Son rang dans la proposition, à partir de 1 — la clef de la ligne.
    pub rank: i64,
    /// La règle dont elle vient.
    pub rule_id: i64,
    pub guid: String,
    pub account_id: i64,
    pub date: NaiveDate,
    pub label: String,
    pub amount: i64,
    pub category_id: i64,
    pub assignment_id: i64,
    pub payment_mode_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
}

/// Les échéances de toutes les règles demandées, empilées dans l'ordre où
/// elles sont demandées — son `GenTab_OpPeriodique`.
///
/// **Une règle dont le compte n'existe plus est écartée en silence** (fidélité,
/// arbitrage de Fabrice du 31/07/2026) : sa fiche le dira si l'utilisateur s'en
/// étonne.
pub fn calendar(conn: &Connection, ids: &[i64]) -> Result<Vec<Occurrence>> {
    let mut proposed = Vec::new();
    let mut rank = 0;
    for id in ids {
        let Some(rule) = get(conn, *id)? else { continue };
        if crate::accounts::get(conn, rule.account_id)?.is_none() {
            continue;
        }
        for date in occurrences(&rule) {
            rank += 1;
            proposed.push(Occurrence {
                rank,
                rule_id: rule.id,
                guid: rule.guid.clone(),
                account_id: rule.account_id,
                date,
                label: rule.label.clone(),
                amount: rule.amount,
                category_id: rule.category_id,
                assignment_id: rule.assignment_id,
                payment_mode_id: rule.payment_mode_id,
                payee_id: rule.payee_id,
                project_id: rule.project_id,
            });
        }
    }
    Ok(proposed)
}

/// Le statut d'une échéance — **la date décide** (règle de Fabrice,
/// 31/07/2026).
///
/// Une échéance déjà passée a bel et bien été prélevée : elle entre en
/// `Pointé` et pèse sur le solde en banque. Une échéance à venir entre en
/// `Prévu` et ne pèse que sur le solde final. Aujourd'hui même compte comme à
/// venir : le jour n'est pas fini.
pub fn status_for(date: NaiveDate, today: NaiveDate) -> i64 {
    if date < today {
        1
    } else {
        3
    }
}

/// Ce que l'insertion a fait.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct Inserted {
    pub count: i64,
    /// Les comptes touchés, dont les soldes ont été recalculés.
    pub accounts: Vec<i64>,
    /// Les règles décalées, avec leur nouvelle date de prochaine opération.
    pub moved: Vec<(i64, NaiveDate)>,
}

/// Insère les échéances retenues.
///
/// **Tout ou rien** : les opérations et le décalage des règles partent dans une
/// seule transaction. Les soldes sont recalculés après le commit, comme
/// partout ailleurs — un solde faux se répare, une demi-insertion non.
///
/// **Chaque règle se décale au cul de sa dernière échéance réellement
/// insérée** : ce que l'utilisateur a retiré du calendrier avec la corbeille
/// rouge reviendra dans la proposition suivante.
pub fn insert(
    conn: &mut Connection,
    chosen: &[Occurrence],
    today: NaiveDate,
) -> Result<Inserted> {
    let mut done = Inserted::default();
    if chosen.is_empty() {
        return Ok(done);
    }

    let tx = conn.transaction()?;
    for occurrence in chosen {
        let input = crate::operations::OperationInput {
            label: occurrence.label.clone(),
            payment_reference: String::new(),
            date: Some(occurrence.date),
            clearing_date: Some(occurrence.date),
            direction: if occurrence.amount < 0 {
                crate::sub_operations::Direction::Debit
            } else {
                crate::sub_operations::Direction::Credit
            },
            amount: occurrence.amount.abs(),
            status_id: status_for(occurrence.date, today),
            category_id: occurrence.category_id,
            assignment_id: occurrence.assignment_id,
            payment_mode_id: occurrence.payment_mode_id,
            payee_id: occurrence.payee_id,
            project_id: occurrence.project_id,
            comment: None,
        };
        let id = crate::operations::create_within(&tx, occurrence.account_id, &input)?;
        // **La marque de la règle**, sans laquelle l'opération serait
        // indiscernable d'une saisie à la main.
        tx.execute(
            "UPDATE Operation SET GUIDCalOpPeriode = ?1 WHERE IDOperation = ?2",
            rusqlite::params![occurrence.guid, id],
        )?;
        done.count += 1;
        if !done.accounts.contains(&occurrence.account_id) {
            done.accounts.push(occurrence.account_id);
        }
    }

    // Le décalage, une règle à la fois : la plus tardive de ses échéances
    // insérées, puis un pas de plus.
    let mut rules: Vec<i64> = Vec::new();
    for occurrence in chosen {
        if !rules.contains(&occurrence.rule_id) {
            rules.push(occurrence.rule_id);
        }
    }
    for rule_id in rules {
        let Some(rule) = get(&tx, rule_id)? else { continue };
        let last = chosen
            .iter()
            .filter(|occurrence| occurrence.rule_id == rule_id)
            .map(|occurrence| occurrence.date)
            .max();
        let Some(last) = last else { continue };
        // **Le décalage garde le quantième d'origine.** Repartir de la
        // dernière échéance insérée suffirait si elle n'avait jamais été
        // rabotée ; comme elle a pu l'être — un 28 février venu d'un 31 —
        // on reprend la série à son rang suivant, calculé depuis l'origine.
        let series = occurrences(&rule);
        let following = match series.iter().position(|date| *date == last) {
            Some(rank) => rule
                .next_date
                .and_then(|origin| {
                    nth_after(origin, rule.unit, rule.frequency, rank as i64 + 1)
                }),
            None => next_after(last, rule.unit, rule.frequency),
        };
        let Some(following) = following else { continue };
        tx.execute(
            "UPDATE CalOpPeriodique SET DateProchOp = ?1, DateDernOpGen = ?2
             WHERE IDOperation = ?3",
            rusqlite::params![iso(Some(following)), iso(Some(last)), rule_id],
        )?;
        done.moved.push((rule_id, following));
    }
    tx.commit()?;

    for account in &done.accounts {
        crate::balances::update_all(conn, *account)?;
    }
    Ok(done)
}

/// Efface les opérations qu'une règle a produites — la corbeille rouge de sa
/// fiche.
///
/// **La règle ne recule pas** (arbitrage de Fabrice, 31/07/2026) : effacer et
/// rejouer sont deux gestes distincts, et c'est à l'utilisateur de remettre la
/// date de prochaine opération s'il veut refaire.
///
/// Les sous-opérations partent avec leur mère, comme partout ailleurs, et les
/// soldes de **tous** les comptes touchés sont recalculés — une règle a pu
/// changer de compte depuis, et ses anciennes écritures sont restées où elles
/// étaient.
pub fn erase(conn: &mut Connection, guid: &str) -> Result<(usize, Vec<i64>)> {
    let mut statement = conn.prepare(
        "SELECT DISTINCT IDCompte FROM Operation WHERE GUIDCalOpPeriode = ?1",
    )?;
    let accounts: Vec<i64> = statement
        .query_map([guid], |row| row.get(0))?
        .collect::<Result<_>>()?;
    drop(statement);

    let mut ids: Vec<i64> = conn
        .prepare("SELECT IDOperation FROM Operation WHERE GUIDCalOpPeriode = ?1")?
        .query_map([guid], |row| row.get(0))?
        .collect::<Result<_>>()?;
    ids.sort_unstable();
    if ids.is_empty() {
        return Ok((0, Vec::new()));
    }

    // `operations::delete` sait déjà emporter les filles et recalculer les
    // soldes : on lui laisse le travail plutôt que d'en écrire une seconde
    // version qui divergerait un jour.
    let removed = crate::operations::delete(conn, &ids)?;
    for account in &accounts {
        crate::balances::update_all(conn, *account)?;
    }
    Ok((removed, accounts))
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

    fn an_account(conn: &Connection, label: &str) -> i64 {
        let id = crate::database::keygen::next_id(conn, "Compte", "IDCompte").expect("clef");
        conn.execute(
            "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte, ReportPointe)
             VALUES (?1, ?2, 1, 0)",
            rusqlite::params![id, label],
        )
        .expect("compte");
        crate::balances::update_all(conn, id).expect("soldes");
        id
    }

    fn a_rule(account: i64) -> Rule {
        Rule {
            account_id: account,
            label: "Assurance Voiture".to_string(),
            amount: -65_000_000,
            next_date: NaiveDate::from_ymd_opt(2026, 8, 10),
            unit: Unit::Month,
            frequency: 1,
            ..Rule::default()
        }
    }

    fn date(year: i32, month: u32, day: u32) -> NaiveDate {
        NaiveDate::from_ymd_opt(year, month, day).expect("date")
    }

    /// **Le 31 ne se perd pas, et il ne déborde pas non plus.** Sa règle : on
    /// garde le quantième, et s'il n'existe pas dans le mois visé on prend le
    /// dernier jour de ce mois. C'est la raison pour laquelle `time_compute`
    /// est entrée dans le projet dès la phase 0.
    #[test]
    fn les_mois_gardent_le_quantieme_et_retombent_sur_la_fin_du_mois() {
        assert_eq!(next_after(date(2026, 1, 31), Unit::Month, 1), Some(date(2026, 2, 28)));
        assert_eq!(next_after(date(2028, 1, 31), Unit::Month, 1), Some(date(2028, 2, 29)));
        assert_eq!(next_after(date(2026, 1, 31), Unit::Month, 3), Some(date(2026, 4, 30)));
        // Et le mois suivant repart du 31 réel, pas du 28 : c'est bien la date
        // de départ qui commande, non la précédente rabotée.
        assert_eq!(next_after(date(2026, 3, 31), Unit::Month, 1), Some(date(2026, 4, 30)));

        // **La série entière, depuis un 31.** C'est ici que se voyait la
        // faute signalée par Fabrice le 31/07/2026 : en enchaînant chaque
        // échéance sur la précédente, mars tombait le 28 et la série dérivait
        // pour toujours. Comptée depuis l'origine, elle retrouve son quantième
        // dès que le calendrier le permet.
        let mut rule = a_rule(1);
        rule.next_date = Some(date(2026, 1, 31));
        rule.ending = Ending::RepeatCount;
        rule.repeat_count = 6;
        assert_eq!(
            occurrences(&rule),
            vec![
                date(2026, 1, 31),
                date(2026, 2, 28),
                date(2026, 3, 31),
                date(2026, 4, 30),
                date(2026, 5, 31),
                date(2026, 6, 30),
            ]
        );
        // Et une année bissextile donne le 29.
        rule.next_date = Some(date(2028, 1, 31));
        rule.repeat_count = 3;
        assert_eq!(
            occurrences(&rule),
            vec![date(2028, 1, 31), date(2028, 2, 29), date(2028, 3, 31)]
        );
        // Le 1er du mois reste le 1er, sans exception.
        rule.next_date = Some(date(2026, 1, 1));
        rule.repeat_count = 4;
        assert_eq!(
            occurrences(&rule),
            vec![
                date(2026, 1, 1),
                date(2026, 2, 1),
                date(2026, 3, 1),
                date(2026, 4, 1),
            ]
        );
        // Le trimestre suit la même règle : depuis un 31 mai, le 31 août.
        rule.unit = Unit::Quarter;
        rule.next_date = Some(date(2026, 5, 31));
        rule.repeat_count = 3;
        assert_eq!(
            occurrences(&rule),
            vec![date(2026, 5, 31), date(2026, 8, 31), date(2026, 11, 30)]
        );

        assert_eq!(next_after(date(2026, 8, 10), Unit::Day, 5), Some(date(2026, 8, 15)));
        assert_eq!(next_after(date(2026, 8, 10), Unit::Week, 2), Some(date(2026, 8, 24)));
        assert_eq!(next_after(date(2026, 8, 10), Unit::Quarter, 1), Some(date(2026, 11, 10)));
        assert_eq!(next_after(date(2024, 2, 29), Unit::Year, 1), Some(date(2025, 2, 28)));
    }

    /// Les trois façons de finir, et le plafond des cent qui vaut pour les
    /// trois.
    #[test]
    fn les_trois_conditions_de_fin_et_le_plafond_des_cent() {
        let account = 1;
        // Sans limite : cent, et pas une de plus.
        let mut rule = a_rule(account);
        rule.ending = Ending::NoLimit;
        let dates = occurrences(&rule);
        assert_eq!(dates.len(), MOST_OCCURRENCES);
        assert_eq!(dates[0], date(2026, 8, 10));
        assert_eq!(dates[1], date(2026, 9, 10));

        // Avec date de fin : la fin est incluse, et l'échéance qui la
        // dépasserait n'est pas produite.
        let mut rule = a_rule(account);
        rule.ending = Ending::UntilDate;
        rule.end_date = Some(date(2026, 11, 10));
        assert_eq!(
            occurrences(&rule),
            vec![
                date(2026, 8, 10),
                date(2026, 9, 10),
                date(2026, 10, 10),
                date(2026, 11, 10),
            ]
        );
        // Un jour plus tôt, et la dernière tombe.
        rule.end_date = Some(date(2026, 11, 9));
        assert_eq!(occurrences(&rule).len(), 3);

        // Nombre de répétitions : **c'est le nombre total d'échéances**, la
        // première comprise.
        let mut rule = a_rule(account);
        rule.ending = Ending::RepeatCount;
        rule.repeat_count = 3;
        assert_eq!(
            occurrences(&rule),
            vec![date(2026, 8, 10), date(2026, 9, 10), date(2026, 10, 10)]
        );
        rule.repeat_count = 1;
        assert_eq!(occurrences(&rule), vec![date(2026, 8, 10)]);
        // Et même un compte absurde produit la première : sa boucle la pose
        // avant d'examiner quoi que ce soit.
        rule.repeat_count = 0;
        assert_eq!(occurrences(&rule), vec![date(2026, 8, 10)]);

        // Une date de fin plus haute que le plafond ne le franchit pas.
        let mut rule = a_rule(account);
        rule.unit = Unit::Day;
        rule.ending = Ending::UntilDate;
        rule.end_date = Some(date(2036, 8, 10));
        assert_eq!(occurrences(&rule).len(), MOST_OCCURRENCES);
    }

    /// Les cinq contrôles de son `Valide_Formulaire`, dont celui qui **n'est
    /// pas** une interdiction du passé.
    #[test]
    fn la_fiche_refuse_ce_que_son_code_refuse_et_rien_de_plus() {
        let conn = database();
        let account = an_account(&conn, "CCP");

        let mut nameless = a_rule(account);
        nameless.label = "   ".to_string();
        assert_eq!(
            refusal(&conn, &nameless).expect("examen"),
            Some("recurring-refusal-label-required")
        );

        let mut undated = a_rule(account);
        undated.next_date = None;
        assert_eq!(
            refusal(&conn, &undated).expect("examen"),
            Some("recurring-refusal-date-required")
        );

        let mut ancient = a_rule(account);
        ancient.next_date = Some(date(1999, 12, 31));
        assert_eq!(
            refusal(&conn, &ancient).expect("examen"),
            Some("recurring-refusal-date-too-old")
        );

        let mut orphan = a_rule(account);
        orphan.account_id = 9_999;
        assert_eq!(
            refusal(&conn, &orphan).expect("examen"),
            Some("recurring-refusal-account-gone")
        );

        let mut backwards = a_rule(account);
        backwards.ending = Ending::UntilDate;
        backwards.end_date = Some(date(2026, 8, 9));
        assert_eq!(
            refusal(&conn, &backwards).expect("examen"),
            Some("recurring-refusal-end-before-start")
        );

        let mut distant = a_rule(account);
        distant.ending = Ending::UntilDate;
        distant.end_date = Some(date(2060, 1, 1));
        assert_eq!(
            refusal(&conn, &distant).expect("examen"),
            Some("recurring-refusal-end-too-far")
        );

        // **Une date dans le passé est acceptée** : sa barrière porte sur l'an
        // 2000, pas sur aujourd'hui, et Fabrice l'a confirmé le 31/07/2026 —
        // on rattrape parfois six mois oubliés.
        let mut late = a_rule(account);
        late.next_date = Some(date(2020, 3, 10));
        assert_eq!(refusal(&conn, &late).expect("examen"), None);
    }

    /// **Le croisement de l'insertion** : ce que le calendrier propose se
    /// retrouve dans le compte, avec le bon statut de chaque côté de
    /// aujourd'hui, et la règle décalée d'après ce qui est réellement entré.
    #[test]
    fn le_calendrier_entre_dans_le_compte_et_la_regle_se_decale() {
        let mut conn = database();
        let account = an_account(&conn, "CCP");
        let mut rule = a_rule(account);
        rule.ending = Ending::RepeatCount;
        rule.repeat_count = 4;
        // Elle commence dans le passé : les deux premières échéances sont
        // derrière nous, les deux autres devant.
        rule.next_date = Some(date(2026, 5, 10));
        let id = create(&conn, &rule, "GUID-TEST").expect("règle");

        let today = date(2026, 7, 31);
        let proposed = calendar(&conn, &[id]).expect("calendrier");
        assert_eq!(proposed.len(), 4);
        assert_eq!(proposed[0].date, date(2026, 5, 10));
        assert_eq!(proposed[3].date, date(2026, 8, 10));

        // La corbeille rouge : on retire la dernière avant d'insérer.
        let kept: Vec<Occurrence> = proposed[..3].to_vec();
        let done = insert(&mut conn, &kept, today).expect("insertion");
        assert_eq!(done.count, 3);
        assert_eq!(done.accounts, vec![account]);

        // **Le statut vient de la date** : passé pointé, à venir prévu.
        let statuses: Vec<(String, i64)> = conn
            .prepare("SELECT Date, IDStatutOperation FROM Operation ORDER BY Date")
            .expect("requête")
            .query_map([], |row| Ok((row.get(0)?, row.get(1)?)))
            .expect("statuts")
            .collect::<Result<_>>()
            .expect("collecte");
        assert_eq!(
            statuses,
            vec![
                ("2026-05-10".to_string(), 1),
                ("2026-06-10".to_string(), 1),
                ("2026-07-10".to_string(), 1),
            ]
        );

        // Toutes portent la marque de la règle.
        let marked: i64 = conn
            .query_row(
                "SELECT COUNT(*) FROM Operation WHERE GUIDCalOpPeriode = 'GUID-TEST'",
                [],
                |row| row.get(0),
            )
            .expect("marque");
        assert_eq!(marked, 3);

        // **La règle repart au cul de la dernière insérée**, pas de la dernière
        // proposée : celle qu'on a retirée reviendra.
        let moved = get(&conn, id).expect("relecture").expect("la règle");
        assert_eq!(moved.next_date, Some(date(2026, 8, 10)));

        // Les trois chiffres de la fiche disent ce qui est entré.
        let seen = produced(&conn, "GUID-TEST").expect("chiffres");
        assert_eq!(seen.count, 3);
        assert_eq!(seen.total, -195_000_000);
        assert_eq!(seen.last_date, Some(date(2026, 7, 10)));

        // Et le solde du compte est la somme des trois.
        assert_eq!(
            crate::accounts::get(&conn, account)
                .expect("lecture")
                .expect("le compte")
                .balance_final,
            -195_000_000
        );
    }

    /// **Le décalage de la règle garde le quantième d'origine.**
    ///
    /// Le cas qui le prouve : une règle du 31 janvier, mensuelle, dont on
    /// insère les deux premières échéances — le 31 janvier et le 28 février.
    /// Repartir bêtement de la dernière insérée donnerait le 28 mars, et la
    /// série aurait perdu son 31 pour toujours. Elle doit repartir au 31 mars.
    #[test]
    fn le_decalage_de_la_regle_ne_perd_pas_le_quantieme() {
        let mut conn = database();
        let account = an_account(&conn, "CCP");
        let mut rule = a_rule(account);
        rule.next_date = Some(date(2026, 1, 31));
        rule.ending = Ending::RepeatCount;
        rule.repeat_count = 2;
        let id = create(&conn, &rule, "GUID-TEST").expect("règle");

        let proposed = calendar(&conn, &[id]).expect("calendrier");
        assert_eq!(
            proposed.iter().map(|line| line.date).collect::<Vec<_>>(),
            vec![date(2026, 1, 31), date(2026, 2, 28)]
        );
        insert(&mut conn, &proposed, date(2026, 3, 1)).expect("insertion");

        let moved = get(&conn, id).expect("relecture").expect("la règle");
        assert_eq!(
            moved.next_date,
            Some(date(2026, 3, 31)),
            "la règle a perdu son quantième en repartant d'un 28 février raboté"
        );
    }

    /// Une échéance datée d'aujourd'hui est **à venir** : le jour n'est pas
    /// fini.
    #[test]
    fn aujourd_hui_compte_comme_a_venir() {
        let today = date(2026, 7, 31);
        assert_eq!(status_for(date(2026, 7, 30), today), 1);
        assert_eq!(status_for(today, today), 3);
        assert_eq!(status_for(date(2026, 8, 1), today), 3);
    }

    /// Chaque règle ne montre que **ses** chiffres — le défaut de son
    /// `Genere_StatOpPeriod`, qui n'est pas porté.
    #[test]
    fn chaque_regle_ne_compte_que_les_siennes() {
        let mut conn = database();
        let account = an_account(&conn, "CCP");
        let today = date(2026, 7, 31);

        let mut first = a_rule(account);
        first.ending = Ending::RepeatCount;
        first.repeat_count = 12;
        let first_id = create(&conn, &first, "GUID-A").expect("règle");

        let mut second = a_rule(account);
        second.label = "Loyer".to_string();
        second.amount = -500_000_000;
        second.ending = Ending::RepeatCount;
        second.repeat_count = 5;
        let second_id = create(&conn, &second, "GUID-B").expect("règle");

        for id in [first_id, second_id] {
            let proposed = calendar(&conn, &[id]).expect("calendrier");
            insert(&mut conn, &proposed, today).expect("insertion");
        }

        assert_eq!(produced(&conn, "GUID-A").expect("A").count, 12);
        // 5, et non 17 : le compteur ne traîne pas celui de la règle
        // précédente.
        assert_eq!(produced(&conn, "GUID-B").expect("B").count, 5);
        assert_eq!(produced(&conn, "GUID-B").expect("B").total, -2_500_000_000);
    }

    /// La corbeille de la fiche efface ce que la règle a produit, recalcule
    /// les soldes, **et laisse la règle où elle est**.
    #[test]
    fn la_corbeille_efface_les_operations_et_ne_recule_pas_la_regle() {
        let mut conn = database();
        let account = an_account(&conn, "CCP");
        let mut rule = a_rule(account);
        rule.ending = Ending::RepeatCount;
        rule.repeat_count = 6;
        let id = create(&conn, &rule, "GUID-TEST").expect("règle");
        let proposed = calendar(&conn, &[id]).expect("calendrier");
        insert(&mut conn, &proposed, date(2026, 7, 31)).expect("insertion");

        let moved = get(&conn, id).expect("relecture").expect("la règle");
        let after_insert = moved.next_date;
        assert_eq!(produced(&conn, "GUID-TEST").expect("chiffres").count, 6);

        let (removed, touched) = erase(&mut conn, "GUID-TEST").expect("effacement");
        assert_eq!(removed, 6);
        assert_eq!(touched, vec![account]);
        assert_eq!(produced(&conn, "GUID-TEST").expect("chiffres").count, 0);
        assert_eq!(
            crate::accounts::get(&conn, account)
                .expect("lecture")
                .expect("le compte")
                .balance_final,
            0
        );

        // **La règle n'a pas reculé** : effacer et rejouer sont deux gestes.
        let still = get(&conn, id).expect("relecture").expect("la règle");
        assert_eq!(still.next_date, after_insert);
    }

    /// Supprimer une règle laisse ses opérations, qui gardent leur marque.
    #[test]
    fn supprimer_une_regle_laisse_ses_operations() {
        let mut conn = database();
        let account = an_account(&conn, "CCP");
        let mut rule = a_rule(account);
        rule.ending = Ending::RepeatCount;
        rule.repeat_count = 3;
        let id = create(&conn, &rule, "GUID-TEST").expect("règle");
        let proposed = calendar(&conn, &[id]).expect("calendrier");
        insert(&mut conn, &proposed, date(2026, 7, 31)).expect("insertion");

        assert_eq!(delete(&conn, &[id]).expect("suppression"), 1);
        assert!(get(&conn, id).expect("relecture").is_none());
        // Les opérations sont toujours là, et toujours marquées.
        assert_eq!(produced(&conn, "GUID-TEST").expect("chiffres").count, 3);
    }

    /// Une règle dont le compte n'existe plus est **écartée en silence** du
    /// calendrier — fidélité à son code, arbitrage de Fabrice.
    #[test]
    fn une_regle_sans_compte_est_ecartee_sans_un_mot() {
        let conn = database();
        let account = an_account(&conn, "CCP");
        let mut good = a_rule(account);
        good.ending = Ending::RepeatCount;
        good.repeat_count = 2;
        let good_id = create(&conn, &good, "GUID-A").expect("règle");

        let mut orphan = a_rule(9_999);
        orphan.label = "Orpheline".to_string();
        orphan.ending = Ending::RepeatCount;
        orphan.repeat_count = 2;
        let orphan_id = create(&conn, &orphan, "GUID-B").expect("règle");

        let proposed = calendar(&conn, &[good_id, orphan_id]).expect("calendrier");
        assert_eq!(proposed.len(), 2, "seules celles de la règle valide");
        assert!(proposed.iter().all(|line| line.rule_id == good_id));
    }
}
