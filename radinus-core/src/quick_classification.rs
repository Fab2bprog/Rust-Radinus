//! F05 — la classification rapide des opérations.
//!
//! Référence : `04_SPECIFICATIONS_FENETRES.md` F05, `PLAN_ACTION.md` phase 7,
//! la capture « classification rapide operation.png », et les règles que
//! Fabrice a dictées le 27/07/2026 avant tout code. Elles sont recopiées ici
//! parce que c'est ce module qui les tient :
//!
//!   1. **Un compte, et un seul.** On n'entre dans cette fenêtre qu'après
//!      avoir choisi un compte unique ; tout ce qui suit ne concerne que lui.
//!   2. **Tout le compte en mémoire**, quelle que soit la période. La période
//!      ne commande que ce qu'on affiche : elle ne redescend jamais à la base.
//!   3. **Le brouillon.** Appliquer un classement ne touche pas le disque. On
//!      classe vite, sans peser chaque geste, parce qu'aucun geste n'est
//!      définitif tant qu'on n'a pas enregistré ; une bêtise se répare en
//!      quittant. « Si on confirme, on enregistre en sécurité, d'un coup. »
//!   4. **On n'écrit que ce qui diffère.** Chaque ligne garde l'état où elle a
//!      été lue — la réserve — et l'enregistrement compare membre à membre.
//!   5. **Mode de paiement et statut descendent aux filles**, les quatre
//!      classements non. Ce n'est pas une invention : c'est exactement ce que
//!      fait `Maj_ProprieteSousOp` dans le WinDev d'origine, et la raison est
//!      dans son commentaire — « pour des raisons de cohérence ». Le mode et
//!      le statut décrivent le mouvement bancaire, qui est unique et appartient
//!      à la mère ; la catégorie, l'affectation, le tiers et le projet
//!      décrivent à quoi l'argent a servi, et c'est précisément ce qu'une
//!      ventilation sert à éclater.
//!
//! **Le tableau ne montre que les lignes mères** (décision de Fabrice, même
//! jour) : les gens qui se servent de cette fenêtre viennent d'importer un gros
//! OFX et n'ont pas encore de filles. Les filles sont chargées quand même,
//! parce qu'elles reçoivent ce qui descend et qu'il faudra l'écrire.

use crate::domain::NaiveDate;
use rusqlite::{Connection, Result};
use std::collections::HashMap;

/// Ce que cette fenêtre sait changer d'une opération — et rien d'autre. Ni le
/// montant, ni la date, ni le libellé : classer n'est pas modifier.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct Classification {
    pub category_id: i64,
    pub assignment_id: i64,
    pub payment_mode_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
    pub status_id: i64,
}

/// L'une des six caractéristiques du bandeau « Changer caractéristiques
/// sélection en : ». Cinq nomenclatures et un statut — Fabrice a demandé qu'on
/// les distingue, et il a raison : les cinq premières **nomment** l'opération,
/// le statut dit **où elle en est**, et c'est le trio qui pilote les
/// interrupteurs des statistiques et du tableau de bord.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Characteristic {
    Category,
    Assignment,
    PaymentMode,
    Payee,
    Project,
    Status,
}

/// Les six, dans l'ordre du bandeau de la capture : la colonne de gauche
/// d'abord (catégorie, affectation, mode), puis celle de droite (tiers,
/// projet, statut).
pub const CHARACTERISTICS: [Characteristic; 6] = [
    Characteristic::Category,
    Characteristic::Assignment,
    Characteristic::PaymentMode,
    Characteristic::Payee,
    Characteristic::Project,
    Characteristic::Status,
];

impl Characteristic {
    /// Le nom sous lequel elle voyage — appel IPC, adresse, clef d'objet.
    /// Anglais comme tout identifiant du portage ; les noms français restent
    /// où ils doivent être, dans la base et à l'écran.
    pub fn key(self) -> &'static str {
        match self {
            Self::Category => "category",
            Self::Assignment => "assignment",
            Self::PaymentMode => "payment-mode",
            Self::Payee => "payee",
            Self::Project => "project",
            Self::Status => "status",
        }
    }

    /// La caractéristique qui porte ce nom, ou rien.
    pub fn from_key(key: &str) -> Option<Self> {
        CHARACTERISTICS.into_iter().find(|which| which.key() == key)
    }

    /// La colonne SQL, sous son nom français d'origine.
    pub fn column(self) -> &'static str {
        match self {
            Self::Category => "IDCategorie",
            Self::Assignment => "IDAffectation",
            Self::PaymentMode => "IDModeOperation",
            Self::Payee => "IDTiers",
            Self::Project => "IDProjets",
            Self::Status => "IDStatutOperation",
        }
    }

    /// **Descend-elle aux sous-opérations ?** Le mode de paiement et le statut
    /// oui, les quatre classements non — `Maj_ProprieteSousOp`, et la règle
    /// que Fabrice a redonnée de tête le 27/07/2026 : « si tu modifies le
    /// moyen de paiement d'une ligne mère il doit être modifié dans les
    /// filles ».
    pub fn descends_to_children(self) -> bool {
        matches!(self, Self::PaymentMode | Self::Status)
    }

    /// **Peut-elle être effacée ?** Une nomenclature revient à « Non précisé »
    /// (`nomenclatures::UNSPECIFIED`), et c'est le seul moyen de déclasser un
    /// lot d'opérations. Le statut, non : `StatutOperation` ne contient que
    /// trois lignes — pointé, engagé, prévu — et aucune ne vaut « rien ». Une
    /// opération est toujours dans l'un des trois états.
    pub fn can_be_cleared(self) -> bool {
        !matches!(self, Self::Status)
    }

    /// Ce que cette caractéristique vaut dans un classement.
    pub fn read(self, of: &Classification) -> i64 {
        match self {
            Self::Category => of.category_id,
            Self::Assignment => of.assignment_id,
            Self::PaymentMode => of.payment_mode_id,
            Self::Payee => of.payee_id,
            Self::Project => of.project_id,
            Self::Status => of.status_id,
        }
    }

    fn write(self, into: &mut Classification, value: i64) {
        match self {
            Self::Category => into.category_id = value,
            Self::Assignment => into.assignment_id = value,
            Self::PaymentMode => into.payment_mode_id = value,
            Self::Payee => into.payee_id = value,
            Self::Project => into.project_id = value,
            Self::Status => into.status_id = value,
        }
    }
}

/// Une ligne de la structure : une opération du compte, mère ou fille.
///
/// Elle porte **deux états** : celui où elle a été lue, qui ne bouge plus, et
/// celui qu'on est en train de lui donner. C'est tout le motif de la réserve,
/// et il est ici plutôt que dans deux tableaux parallèles pour la raison
/// qu'ont toujours les tableaux parallèles : ils se décalent.
#[derive(Debug, Clone, PartialEq)]
pub struct Line {
    pub id: i64,
    pub date: Option<NaiveDate>,
    pub label: String,
    pub amount: i64,
    /// `0` pour une opération de premier niveau, la clef de sa mère sinon.
    pub parent_id: i64,
    /// Le classement courant — celui que l'écran montre.
    pub current: Classification,
    /// Le classement lu en base. Écrit une fois, au chargement, et à chaque
    /// enregistrement réussi ; jamais ailleurs.
    reserve: Classification,
}

impl Line {
    /// Une opération de premier niveau : celles que le tableau montre.
    pub fn is_top_level(&self) -> bool {
        self.parent_id == 0
    }

    /// Diffère-t-elle de ce qui est en base ? C'est la seule question que se
    /// pose l'enregistrement.
    pub fn is_modified(&self) -> bool {
        self.current != self.reserve
    }

    /// Le classement tel qu'il a été lu.
    pub fn as_read(&self) -> Classification {
        self.reserve
    }
}

/// Ce que les six cases à cocher et leurs menus valent ensemble.
///
/// `None` est une case décochée : **on n'y touche pas**. `Some(valeur)` est une
/// case cochée, et « Non précisé » y est une valeur comme une autre — celle du
/// vide (décision de Fabrice, 27/07/2026 : la case dit déjà « je veux
/// changer », donc laisser le menu sur « Non précisé » efface le classement).
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct Change {
    pub category: Option<i64>,
    pub assignment: Option<i64>,
    pub payment_mode: Option<i64>,
    pub payee: Option<i64>,
    pub project: Option<i64>,
    pub status: Option<i64>,
}

impl Change {
    /// Ce que cette caractéristique doit devenir, ou rien.
    pub fn value(&self, which: Characteristic) -> Option<i64> {
        match which {
            Characteristic::Category => self.category,
            Characteristic::Assignment => self.assignment,
            Characteristic::PaymentMode => self.payment_mode,
            Characteristic::Payee => self.payee,
            Characteristic::Project => self.project,
            Characteristic::Status => self.status,
        }
    }

    /// Aucune case cochée : il n'y a rien à appliquer, et les engrenages
    /// restent éteints.
    pub fn is_empty(&self) -> bool {
        CHARACTERISTICS
            .into_iter()
            .all(|which| self.value(which).is_none())
    }
}

/// La structure en RAM : toutes les opérations d'**un** compte, et leur
/// réserve.
///
/// Elle ne se vide pas, elle se remplace : voir [`load`]. C'est la précaution
/// que Fabrice a demandée nommément (« il faut que la structure en RAM soit
/// obligatoirement vide avant de la charger »), et la rendre impossible vaut
/// mieux que la vérifier — une structure qu'on ne vide jamais ne peut pas mal
/// se vider.
#[derive(Debug)]
pub struct Workbench {
    account_id: i64,
    lines: Vec<Line>,
    /// Où trouver une ligne par sa clef, et où trouver les filles d'une mère.
    /// Construits une fois au chargement : les chercher à chaque application
    /// ferait, sur le compte de l'auteur, deux mille parcours par clic.
    at: HashMap<i64, usize>,
    children_of: HashMap<i64, Vec<usize>>,
}

/// Toutes les opérations du compte, **quelle que soit la période**, dans une
/// structure neuve.
///
/// La période ne redescend jamais ici : elle ne fait que rétrécir la fenêtre
/// par laquelle on regarde ce qui est déjà en mémoire ([`Workbench::between`]).
///
/// **Rien n'est jamais ajouté à une structure existante.** Cette fonction en
/// construit une et la rend ; l'appelant remplace la sienne, et l'ancienne
/// disparaît avec ce qu'elle contenait. C'est une affectation, pas une boucle
/// de vidage — et c'est pour cela qu'elle ne peut pas se tromper.
pub fn load(conn: &Connection, account_id: i64) -> Result<Workbench> {
    let mut statement = conn.prepare(
        "SELECT IDOperation, Date, Libelle, Montant, IDOperationParent,
                IDCategorie, IDAffectation, IDModeOperation, IDTiers,
                IDProjets, IDStatutOperation
           FROM Operation
          WHERE IDCompte = ?1
          ORDER BY Date, IDOperation",
    )?;
    let lines: Vec<Line> = statement
        .query_map([account_id], |row| {
            let classification = Classification {
                category_id: row.get(5)?,
                assignment_id: row.get(6)?,
                payment_mode_id: row.get(7)?,
                payee_id: row.get(8)?,
                project_id: row.get(9)?,
                status_id: row.get(10)?,
            };
            Ok(Line {
                id: row.get(0)?,
                date: row
                    .get::<_, Option<String>>(1)?
                    .and_then(|text| NaiveDate::parse_from_str(&text, "%Y-%m-%d").ok()),
                label: row.get(2)?,
                amount: row.get(3)?,
                parent_id: row.get(4)?,
                current: classification,
                reserve: classification,
            })
        })?
        .collect::<Result<_>>()?;

    Ok(Workbench::of(account_id, lines))
}

impl Workbench {
    /// Une structure vide, pour un compte qui n'a rien — et le point de départ
    /// de [`load`].
    fn of(account_id: i64, lines: Vec<Line>) -> Self {
        let mut at = HashMap::with_capacity(lines.len());
        let mut children_of: HashMap<i64, Vec<usize>> = HashMap::new();
        for (index, line) in lines.iter().enumerate() {
            at.insert(line.id, index);
            if line.parent_id != 0 {
                children_of.entry(line.parent_id).or_default().push(index);
            }
        }
        Self {
            account_id,
            lines,
            at,
            children_of,
        }
    }

    pub fn account_id(&self) -> i64 {
        self.account_id
    }

    /// Tout ce qui est chargé, filles comprises.
    pub fn lines(&self) -> &[Line] {
        &self.lines
    }

    /// Ce que le tableau montre : **les lignes mères** dont la date tombe entre
    /// les deux bornes, celles-ci comprises, dans l'ordre du chargement.
    ///
    /// Une opération sans date n'est nulle part dans le temps : elle
    /// n'apparaît sous aucune période. C'est la même règle que la liste des
    /// opérations (`operations::list_for_account`).
    pub fn between(&self, from: NaiveDate, to: NaiveDate) -> Vec<&Line> {
        self.lines
            .iter()
            .filter(|line| line.is_top_level())
            .filter(|line| line.date.is_some_and(|date| date >= from && date <= to))
            .collect()
    }

    /// La ligne de cette clef, si elle existe.
    pub fn line(&self, id: i64) -> Option<&Line> {
        self.at.get(&id).map(|index| &self.lines[*index])
    }

    /// Applique `change` aux lignes nommées — **en mémoire, et nulle part
    /// ailleurs**. C'est le premier icône du panneau bleu.
    ///
    /// Rend le nombre de lignes que cela a effectivement changées, filles
    /// comprises : une valeur redonnée à une ligne qui l'a déjà ne compte pas,
    /// puisqu'elle ne changera rien non plus à l'enregistrement.
    ///
    /// Une clef inconnue est ignorée. Cela n'arrive pas depuis la fenêtre, mais
    /// une structure rechargée entre-temps ne doit pas faire tomber
    /// l'application.
    pub fn apply(&mut self, ids: &[i64], change: &Change) -> usize {
        if change.is_empty() {
            return 0;
        }
        let mut touched = 0;
        for id in ids {
            let Some(index) = self.at.get(id).copied() else {
                continue;
            };
            let before = self.lines[index].current;
            for which in CHARACTERISTICS {
                if let Some(value) = change.value(which) {
                    which.write(&mut self.lines[index].current, value);
                }
            }
            if self.lines[index].current != before {
                touched += 1;
            }
            touched += self.push_down(index, change);
        }
        touched
    }

    /// Change **une** caractéristique d'**une** ligne : le menu déroulant dans
    /// la cellule, la seconde porte vers cette même structure.
    ///
    /// Elle mène exactement au même endroit que l'application en masse — même
    /// réserve, même descente aux filles, même enregistrement. Deux gestes, un
    /// seul chemin vers la base.
    pub fn set(&mut self, id: i64, which: Characteristic, value: i64) -> bool {
        let Some(index) = self.at.get(&id).copied() else {
            return false;
        };
        which.write(&mut self.lines[index].current, value);
        let mut change = Change::default();
        match which {
            Characteristic::Category => change.category = Some(value),
            Characteristic::Assignment => change.assignment = Some(value),
            Characteristic::PaymentMode => change.payment_mode = Some(value),
            Characteristic::Payee => change.payee = Some(value),
            Characteristic::Project => change.project = Some(value),
            Characteristic::Status => change.status = Some(value),
        }
        self.push_down(index, &change);
        true
    }

    /// Fait descendre aux filles ce qui doit descendre — le mode de paiement et
    /// le statut, jamais les quatre classements.
    ///
    /// Une fille ne descend rien : il n'y a que deux niveaux dans Radinus, et
    /// une sous-opération n'en porte pas.
    fn push_down(&mut self, index: usize, change: &Change) -> usize {
        if !self.lines[index].is_top_level() {
            return 0;
        }
        let mother = self.lines[index].id;
        let Some(children) = self.children_of.get(&mother).cloned() else {
            return 0;
        };
        let mut touched = 0;
        for child in children {
            let before = self.lines[child].current;
            for which in CHARACTERISTICS {
                if !which.descends_to_children() {
                    continue;
                }
                if let Some(value) = change.value(which) {
                    which.write(&mut self.lines[child].current, value);
                }
            }
            if self.lines[child].current != before {
                touched += 1;
            }
        }
        touched
    }

    /// Combien de lignes attendent d'être écrites — filles comprises.
    ///
    /// C'est la même question que se pose l'enregistrement, posée avant lui :
    /// la porte s'en sert pour savoir s'il y a quelque chose à perdre.
    pub fn pending(&self) -> usize {
        self.lines.iter().filter(|line| line.is_modified()).count()
    }

    pub fn is_dirty(&self) -> bool {
        self.lines.iter().any(Line::is_modified)
    }

    /// Écrit sur le disque — et **seulement ce qui diffère de la réserve**.
    ///
    /// Tout part dans une seule transaction : il n'existe pas d'état où la
    /// moitié du travail serait enregistrée et l'autre perdue. Les trois soldes
    /// du compte sont refaits ensuite, parce qu'un statut changé les déplace :
    /// une opération passée de prévue à pointée entre dans le solde banque.
    ///
    /// Rend le nombre de lignes écrites.
    pub fn save(&mut self, conn: &mut Connection) -> Result<usize> {
        let to_write: Vec<usize> = (0..self.lines.len())
            .filter(|index| self.lines[*index].is_modified())
            .collect();
        if to_write.is_empty() {
            return Ok(0);
        }

        let transaction = conn.transaction()?;
        {
            let mut statement = transaction.prepare(
                "UPDATE Operation
                    SET IDCategorie = ?1, IDAffectation = ?2, IDModeOperation = ?3,
                        IDTiers = ?4, IDProjets = ?5, IDStatutOperation = ?6
                  WHERE IDOperation = ?7",
            )?;
            for index in &to_write {
                let line = &self.lines[*index];
                statement.execute(rusqlite::params![
                    line.current.category_id,
                    line.current.assignment_id,
                    line.current.payment_mode_id,
                    line.current.payee_id,
                    line.current.project_id,
                    line.current.status_id,
                    line.id,
                ])?;
            }
        }
        transaction.commit()?;

        // Ce qui est écrit devient ce qui a été lu : la réserve suit, sinon le
        // prochain enregistrement réécrirait les mêmes lignes pour rien.
        for index in &to_write {
            self.lines[*index].reserve = self.lines[*index].current;
        }

        crate::balances::update_all(conn, self.account_id)?;
        Ok(to_write.len())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database::{schema, seed};
    use crate::nomenclatures::UNSPECIFIED;

    /// Une base avec deux comptes et de quoi classer.
    fn database() -> Connection {
        let conn = Connection::open_in_memory().unwrap();
        schema::migrate(&conn).unwrap();
        seed::seed_initial_data(&conn).unwrap();
        for (id, label) in [(1, "CCP"), (2, "Livret")] {
            conn.execute(
                "INSERT INTO Compte (IDCompte, ReportPointe, ReportEngage, ReportPrevu, Libelle,
                    IDTypeCompte, IDBanques, SoldeBanque, SoldeReel, SoldeFinal, NomTitulaire,
                    AdresseTitulaire, COBCodeBanque, COBCodeGuichet, COBNumCompte, COBClefRIB,
                    COBIBAN, DateOuverture, DateCloture, AdresseAgenceBank, COBBIC,
                    NumProchCheque, CompteCloture, Devise)
                 VALUES (?1, 0, 0, 0, ?2, 1, 21, 0, 0, 0, '', '', '', '', '', '', '',
                         NULL, NULL, '', '', 0, 0, 'EUR')",
                rusqlite::params![id, label],
            )
            .unwrap();
        }
        for kind in [
            crate::nomenclatures::Nomenclature::Assignment,
            crate::nomenclatures::Nomenclature::PaymentMode,
            crate::nomenclatures::Nomenclature::Payee,
            crate::nomenclatures::Nomenclature::Project,
        ] {
            for label in ["Un", "Deux"] {
                crate::nomenclatures::create(&conn, kind, label).unwrap();
            }
        }
        // Une catégorie porte un poste budgétaire : elle a sa propre fonction.
        for label in ["Un", "Deux"] {
            crate::nomenclatures::create_category(&conn, label, UNSPECIFIED).unwrap();
        }
        conn
    }

    /// Une opération de premier niveau.
    fn operation(conn: &Connection, id: i64, account: i64, date: &str, amount: i64) {
        conn.execute(
            "INSERT INTO Operation (IDOperation, IDCompte, IDOperationParent, Date, DatePointage,
                Libelle, Montant, IDCategorie, IDAffectation, IDModeOperation, IDTiers,
                IDProjets, IDStatutOperation, SoldePointe, EstParent, EstComplement,
                GUIDCalOpPeriode, IDCheque, ReferencePaiement)
             VALUES (?1, ?2, 0, ?3, ?3, ?4, ?5, 0, 0, 1, 0, 0, 1, 0, 0, 0, '', 0, '')",
            rusqlite::params![id, account, date, format!("OP{id}"), amount],
        )
        .unwrap();
    }

    /// Une sous-opération de `parent`.
    fn child(conn: &Connection, id: i64, parent: i64, account: i64, date: &str, amount: i64) {
        conn.execute(
            "INSERT INTO Operation (IDOperation, IDCompte, IDOperationParent, Date, DatePointage,
                Libelle, Montant, IDCategorie, IDAffectation, IDModeOperation, IDTiers,
                IDProjets, IDStatutOperation, SoldePointe, EstParent, EstComplement,
                GUIDCalOpPeriode, IDCheque, ReferencePaiement)
             VALUES (?1, ?2, ?3, ?4, ?4, ?5, ?6, 0, 0, 1, 0, 0, 1, 0, 0, 0, '', 0, '')",
            rusqlite::params![id, account, parent, date, format!("SOUS{id}"), amount],
        )
        .unwrap();
        conn.execute(
            "UPDATE Operation SET EstParent = 1 WHERE IDOperation = ?1",
            [parent],
        )
        .unwrap();
    }

    fn day(text: &str) -> NaiveDate {
        NaiveDate::parse_from_str(text, "%Y-%m-%d").unwrap()
    }

    /// **Ce que la base contient, relu autrement.** Une seconde requête, écrite
    /// à la main, qui ne partage rien avec le module : c'est elle qui tient
    /// l'autre bout de tous les croisements ci-dessous.
    fn read_back(conn: &Connection, id: i64) -> Classification {
        conn.query_row(
            "SELECT IDCategorie, IDAffectation, IDModeOperation, IDTiers, IDProjets,
                    IDStatutOperation
               FROM Operation WHERE IDOperation = ?1",
            [id],
            |row| {
                Ok(Classification {
                    category_id: row.get(0)?,
                    assignment_id: row.get(1)?,
                    payment_mode_id: row.get(2)?,
                    payee_id: row.get(3)?,
                    project_id: row.get(4)?,
                    status_id: row.get(5)?,
                })
            },
        )
        .unwrap()
    }

    fn classify(category: i64) -> Change {
        Change {
            category: Some(category),
            ..Change::default()
        }
    }

    // --- Les croisements ------------------------------------------------
    //
    // « Les meilleurs tests sont ceux qui croisent les données ou ceux qui
    // sont aux deux extrémités du problème » (Fabrice, 26/07/2026). Ici les
    // deux extrémités sont la RAM et le disque, et la vérité est dans leur
    // confrontation — jamais dans l'une des deux prise seule.

    /// **RAM contre disque, ligne à ligne.** Après enregistrement, ce que la
    /// base contient doit être exactement ce que la structure porte — pour
    /// **toutes** les lignes, y compris celles qu'on n'a pas touchées.
    #[test]
    fn ce_qui_est_en_memoire_est_ce_que_la_base_contient_apres_enregistrement() {
        let mut conn = database();
        for id in 1..=10 {
            operation(&conn, id, 1, "2026-03-01", -1_000_000 * id);
        }
        child(&conn, 20, 3, 1, "2026-03-01", -500_000);
        child(&conn, 21, 3, 1, "2026-03-01", -2_500_000);

        let mut bench = load(&conn, 1).unwrap();
        bench.apply(&[1, 2, 3], &classify(1));
        bench.apply(
            &[3, 4],
            &Change {
                payment_mode: Some(2),
                status: Some(2),
                ..Change::default()
            },
        );
        bench.set(5, Characteristic::Payee, 1);
        bench.save(&mut conn).unwrap();

        for line in bench.lines() {
            assert_eq!(
                read_back(&conn, line.id),
                line.current,
                "la ligne {} diffère entre la mémoire et la base",
                line.id
            );
        }
    }

    /// **Le compte des écritures contre le compte des différences.** On
    /// n'écrit que ce qui diffère de la réserve : le nombre rendu par
    /// l'enregistrement doit être exactement le nombre de lignes modifiées,
    /// pas une de plus.
    #[test]
    fn on_ecrit_exactement_les_lignes_qui_different_de_la_reserve() {
        let mut conn = database();
        for id in 1..=6 {
            operation(&conn, id, 1, "2026-03-01", -1_000_000);
        }

        let mut bench = load(&conn, 1).unwrap();
        bench.apply(&[2, 4, 6], &classify(2));
        let expected = bench.pending();
        assert_eq!(expected, 3);

        let written = bench.save(&mut conn).unwrap();
        assert_eq!(written, expected);

        // Et l'autre bout : les trois autres n'ont pas bougé d'un pouce.
        for id in [1, 3, 5] {
            assert_eq!(read_back(&conn, id).category_id, UNSPECIFIED);
        }
    }

    /// **L'aller-retour.** Donner une valeur puis remettre celle d'origine ne
    /// doit rien écrire du tout : la réserve dit que rien n'a bougé, quelle
    /// qu'ait été l'agitation entre-temps.
    ///
    /// C'est le test qui distingue une vraie réserve d'un simple drapeau
    /// « modifié » — un drapeau, lui, resterait levé.
    #[test]
    fn un_aller_retour_ne_laisse_aucune_trace() {
        let mut conn = database();
        operation(&conn, 1, 1, "2026-03-01", -1_000_000);

        let mut bench = load(&conn, 1).unwrap();
        let origin = bench.line(1).unwrap().as_read();

        bench.apply(&[1], &classify(1));
        bench.apply(&[1], &classify(2));
        assert!(bench.is_dirty());
        bench.apply(&[1], &classify(origin.category_id));

        assert!(!bench.is_dirty(), "la réserve n'a pas reconnu son propre état");
        assert_eq!(bench.save(&mut conn).unwrap(), 0);
    }

    /// **Mère et filles, aux deux bouts.** Un mode de paiement donné à une mère
    /// doit se retrouver sur ses filles **en base**, et une catégorie donnée à
    /// la même mère ne doit pas y descendre.
    ///
    /// Les filles ne sont pas à l'écran : c'est donc exactement le genre de
    /// chose qu'aucun essai à la main ne verrait.
    #[test]
    fn le_mode_descend_aux_filles_et_la_categorie_non() {
        let mut conn = database();
        operation(&conn, 1, 1, "2026-03-01", -3_000_000);
        child(&conn, 10, 1, 1, "2026-03-01", -1_000_000);
        child(&conn, 11, 1, 1, "2026-03-01", -2_000_000);
        // Une autre mère avec sa fille, pour vérifier que rien ne déborde.
        operation(&conn, 2, 1, "2026-03-01", -1_000_000);
        child(&conn, 12, 2, 1, "2026-03-01", -1_000_000);

        let mut bench = load(&conn, 1).unwrap();
        bench.apply(
            &[1],
            &Change {
                category: Some(2),
                payment_mode: Some(2),
                status: Some(3),
                ..Change::default()
            },
        );
        bench.save(&mut conn).unwrap();

        for daughter in [10, 11] {
            let read = read_back(&conn, daughter);
            assert_eq!(read.payment_mode_id, 2, "le mode n'est pas descendu");
            assert_eq!(read.status_id, 3, "le statut n'est pas descendu");
            assert_eq!(
                read.category_id, UNSPECIFIED,
                "la catégorie est descendue alors qu'elle ne doit pas"
            );
        }
        // La fille de l'autre mère n'a rien reçu.
        let outsider = read_back(&conn, 12);
        assert_eq!(outsider.payment_mode_id, 1);
        assert_eq!(outsider.status_id, 1);
    }

    /// **Le brouillon ne fuit pas.** Tant qu'on n'a pas enregistré, la base est
    /// exactement dans l'état où on l'a trouvée — c'est ce qui autorise à
    /// classer vite et à quitter en cas de bêtise.
    #[test]
    fn sans_enregistrement_la_base_est_intacte() {
        let conn = database();
        for id in 1..=5 {
            operation(&conn, id, 1, "2026-03-01", -1_000_000);
        }
        let before: Vec<Classification> = (1..=5).map(|id| read_back(&conn, id)).collect();

        let mut bench = load(&conn, 1).unwrap();
        bench.apply(
            &(1..=5).collect::<Vec<_>>(),
            &Change {
                category: Some(1),
                assignment: Some(2),
                payment_mode: Some(2),
                payee: Some(1),
                project: Some(2),
                status: Some(3),
            },
        );
        assert_eq!(bench.pending(), 5);

        let after: Vec<Classification> = (1..=5).map(|id| read_back(&conn, id)).collect();
        assert_eq!(before, after, "la base a bougé sans qu'on lui demande");
    }

    /// **La faute que Fabrice a nommée avant qu'elle n'arrive** : charger un
    /// compte sans avoir vidé la structure du précédent.
    ///
    /// Elle est rendue impossible plutôt que corrigée — [`load`] construit une
    /// structure neuve — et c'est ce test qui le tient : pas une ligne du
    /// compte A ne survit au chargement du compte B, ni par le nombre, ni par
    /// la clef.
    #[test]
    fn charger_un_autre_compte_ne_laisse_rien_du_precedent() {
        let conn = database();
        for id in 1..=7 {
            operation(&conn, id, 1, "2026-03-01", -1_000_000);
        }
        for id in 100..=102 {
            operation(&conn, id, 2, "2026-03-01", -2_000_000);
        }

        let first = load(&conn, 1).unwrap();
        let keys_of_first: Vec<i64> = first.lines().iter().map(|line| line.id).collect();
        assert_eq!(keys_of_first.len(), 7);

        let second = load(&conn, 2).unwrap();
        assert_eq!(second.account_id(), 2);
        assert_eq!(second.lines().len(), 3);
        for id in &keys_of_first {
            assert!(
                second.line(*id).is_none(),
                "la ligne {id} du compte 1 a survécu au chargement du compte 2"
            );
        }
    }

    /// Et le même compte deux fois : le total ne double pas. Une structure
    /// remplie deux fois se verrait ici, et nulle part ailleurs.
    #[test]
    fn charger_deux_fois_le_meme_compte_ne_double_rien() {
        let conn = database();
        for id in 1..=4 {
            operation(&conn, id, 1, "2026-03-01", -1_000_000);
        }
        let once = load(&conn, 1).unwrap();
        let twice = load(&conn, 1).unwrap();
        assert_eq!(once.lines().len(), twice.lines().len());
        assert_eq!(twice.lines().len(), 4);
    }

    /// **La période ne commande que l'affichage.** Tout le compte est en
    /// mémoire ; ce que `between` rend en est une tranche, et rétrécir la
    /// période ne fait perdre aucune ligne à la structure.
    #[test]
    fn la_periode_ne_reduit_que_ce_que_l_on_regarde() {
        let conn = database();
        operation(&conn, 1, 1, "2025-12-31", -1_000_000);
        operation(&conn, 2, 1, "2026-01-01", -1_000_000);
        operation(&conn, 3, 1, "2026-06-15", -1_000_000);
        operation(&conn, 4, 1, "2026-12-31", -1_000_000);
        operation(&conn, 5, 1, "2027-01-01", -1_000_000);
        child(&conn, 10, 3, 1, "2026-06-15", -1_000_000);

        let bench = load(&conn, 1).unwrap();
        assert_eq!(bench.lines().len(), 6, "tout le compte doit être chargé");

        let year: Vec<i64> = bench
            .between(day("2026-01-01"), day("2026-12-31"))
            .iter()
            .map(|line| line.id)
            .collect();
        assert_eq!(year, vec![2, 3, 4], "les bornes sont incluses, la fille non");

        // Et la structure n'a rien perdu en chemin.
        assert_eq!(bench.lines().len(), 6);
    }

    /// **Effacer est un classement comme un autre.** Case cochée, menu laissé
    /// sur « Non précisé » : le classement s'efface, en mémoire puis en base.
    /// C'est le seul moyen de déclasser un lot d'opérations.
    #[test]
    fn non_precise_efface_le_classement() {
        let mut conn = database();
        operation(&conn, 1, 1, "2026-03-01", -1_000_000);
        conn.execute(
            "UPDATE Operation SET IDCategorie = 2, IDTiers = 1 WHERE IDOperation = 1",
            [],
        )
        .unwrap();

        let mut bench = load(&conn, 1).unwrap();
        bench.apply(&[1], &classify(UNSPECIFIED));
        bench.save(&mut conn).unwrap();

        let read = read_back(&conn, 1);
        assert_eq!(read.category_id, UNSPECIFIED);
        // Ce qu'on n'a pas coché n'a pas bougé.
        assert_eq!(read.payee_id, 1);
    }

    /// Aucune case cochée : les engrenages n'ont rien à appliquer, et
    /// n'appliquent rien. La fenêtre les grise, mais le noyau ne compte pas
    /// là-dessus.
    #[test]
    fn un_changement_vide_ne_touche_a_rien() {
        let conn = database();
        operation(&conn, 1, 1, "2026-03-01", -1_000_000);
        let mut bench = load(&conn, 1).unwrap();
        assert!(Change::default().is_empty());
        assert_eq!(bench.apply(&[1], &Change::default()), 0);
        assert!(!bench.is_dirty());
    }

    /// **Le statut déplace les soldes.** Passer une opération de prévue à
    /// pointée la fait entrer dans le solde banque : l'enregistrement doit donc
    /// refaire les trois soldes, sinon la fenêtre des soldes ment jusqu'au
    /// prochain changement d'opération.
    #[test]
    fn enregistrer_un_statut_refait_les_soldes_du_compte() {
        let mut conn = database();
        operation(&conn, 1, 1, "2026-03-01", -1_000_000);
        conn.execute(
            "UPDATE Operation SET IDStatutOperation = 3 WHERE IDOperation = 1",
            [],
        )
        .unwrap();
        crate::balances::update_all(&conn, 1).unwrap();
        let before: i64 = conn
            .query_row("SELECT SoldeBanque FROM Compte WHERE IDCompte = 1", [], |r| {
                r.get(0)
            })
            .unwrap();
        assert_eq!(before, 0, "une opération prévue n'est pas au solde banque");

        let mut bench = load(&conn, 1).unwrap();
        bench.apply(
            &[1],
            &Change {
                status: Some(1),
                ..Change::default()
            },
        );
        bench.save(&mut conn).unwrap();

        let after: i64 = conn
            .query_row("SELECT SoldeBanque FROM Compte WHERE IDCompte = 1", [], |r| {
                r.get(0)
            })
            .unwrap();
        assert_eq!(after, -1_000_000, "le solde banque n'a pas suivi le pointage");
    }

    /// Enregistrer deux fois de suite n'écrit rien la seconde fois : la réserve
    /// a suivi ce qui est parti. Sans cela, chaque enregistrement réécrirait
    /// tout le compte.
    #[test]
    fn un_second_enregistrement_n_ecrit_rien() {
        let mut conn = database();
        for id in 1..=3 {
            operation(&conn, id, 1, "2026-03-01", -1_000_000);
        }
        let mut bench = load(&conn, 1).unwrap();
        bench.apply(&[1, 2, 3], &classify(1));
        assert_eq!(bench.save(&mut conn).unwrap(), 3);
        assert_eq!(bench.save(&mut conn).unwrap(), 0);
        assert!(!bench.is_dirty());
    }

    /// La cellule et le bandeau mènent au même endroit : même écriture, même
    /// descente aux filles. Deux gestes, un seul chemin.
    #[test]
    fn la_cellule_et_le_bandeau_font_la_meme_chose() {
        let mut conn = database();
        operation(&conn, 1, 1, "2026-03-01", -1_000_000);
        operation(&conn, 2, 1, "2026-03-01", -1_000_000);
        child(&conn, 10, 1, 1, "2026-03-01", -1_000_000);
        child(&conn, 20, 2, 1, "2026-03-01", -1_000_000);

        let mut bench = load(&conn, 1).unwrap();
        bench.apply(
            &[1],
            &Change {
                payment_mode: Some(2),
                ..Change::default()
            },
        );
        bench.set(2, Characteristic::PaymentMode, 2);
        bench.save(&mut conn).unwrap();

        assert_eq!(read_back(&conn, 1), read_back(&conn, 2));
        assert_eq!(read_back(&conn, 10), read_back(&conn, 20));
        assert_eq!(read_back(&conn, 10).payment_mode_id, 2);
    }

    /// Les six caractéristiques portent six noms distincts, six colonnes
    /// distinctes, et se retrouvent par leur nom. Une collision ici ferait
    /// écrire une caractéristique à la place d'une autre.
    #[test]
    fn les_six_caracteristiques_sont_bien_six() {
        let keys: std::collections::BTreeSet<&str> =
            CHARACTERISTICS.iter().map(|w| w.key()).collect();
        let columns: std::collections::BTreeSet<&str> =
            CHARACTERISTICS.iter().map(|w| w.column()).collect();
        assert_eq!(keys.len(), 6);
        assert_eq!(columns.len(), 6);
        for which in CHARACTERISTICS {
            assert_eq!(Characteristic::from_key(which.key()), Some(which));
        }
        assert_eq!(Characteristic::from_key("montant"), None);

        // Deux descendent, quatre non ; cinq s'effacent, le statut non.
        let descending: Vec<&str> = CHARACTERISTICS
            .iter()
            .filter(|w| w.descends_to_children())
            .map(|w| w.key())
            .collect();
        assert_eq!(descending, vec!["payment-mode", "status"]);
        let clearable: Vec<&str> = CHARACTERISTICS
            .iter()
            .filter(|w| w.can_be_cleared())
            .map(|w| w.key())
            .collect();
        assert_eq!(
            clearable,
            vec!["category", "assignment", "payment-mode", "payee", "project"]
        );
    }

    /// **Écrire puis relire, six fois.** Chaque caractéristique doit rendre ce
    /// qu'on lui a donné — et **n'avoir touché qu'elle-même**.
    ///
    /// Deux `match` de six branches se font face dans ce module, l'un qui lit
    /// et l'autre qui écrit. Une branche recopiée de travers y écrirait le
    /// tiers dans le projet sans qu'aucun compilateur ne bronche, et l'écran
    /// montrerait un classement parfaitement plausible. Ce test tient les deux
    /// bouts de ce couple.
    #[test]
    fn chaque_caracteristique_ecrit_chez_elle_et_nulle_part_ailleurs() {
        for which in CHARACTERISTICS {
            let mut classification = Classification::default();
            which.write(&mut classification, 7);
            assert_eq!(which.read(&classification), 7, "{} ne se relit pas", which.key());

            for other in CHARACTERISTICS {
                if other == which {
                    continue;
                }
                assert_eq!(
                    other.read(&classification),
                    0,
                    "écrire {} a débordé sur {}",
                    which.key(),
                    other.key()
                );
            }
        }
    }

    /// **La base dit elle-même que le statut n'a pas de vide.** Trois lignes
    /// dans `StatutOperation`, et aucune ne s'appelle « Non précisé » : c'est
    /// de là que vient [`Characteristic::can_be_cleared`], et non d'un choix
    /// de programmation.
    #[test]
    fn le_statut_n_a_que_trois_valeurs_et_aucune_n_est_vide() {
        let conn = database();
        let statuses = crate::operations::statuses(&conn).unwrap();
        assert_eq!(statuses.len(), 3);
        assert!(statuses.iter().all(|item| item.id != UNSPECIFIED));
        assert!(!Characteristic::Status.can_be_cleared());
    }
}
