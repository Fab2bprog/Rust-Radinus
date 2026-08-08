//! Les modèles d'opération — `ModeleOperation` (02_BASE_DE_DONNEES.md §3.8),
//! les fenêtres F36 et F37 de `04_SPECIFICATIONS_FENETRES.md`.
//!
//! **Un modèle est une saisie toute faite.** Règle donnée par Fabrice le
//! 29/07/2026, et c'est elle qui commande tout ce module : « les modèles
//! évitent de saisir au clavier, ce qui est long. Lorsqu'un utilisateur décide
//! d'appliquer un modèle, les informations contenues dans le modèle viennent
//! **écraser** celles contenues dans la fiche de la transaction. Cependant elles
//! ne sont pas encore enregistrées sur le disque. Elles ne le seront que lorsque
//! l'utilisateur aura validé la fiche. »
//!
//! Deux conséquences, et elles sont dans le code :
//!
//! 1. **Appliquer écrase, il ne complète pas.** Un champ déjà rempli dans la
//!    fiche est remplacé, pas préservé — sans quoi appliquer deux modèles à la
//!    suite donnerait un mélange des deux que personne n'a demandé.
//! 2. **Appliquer n'écrit rien.** Ce module ne connaît aucun chemin qui
//!    toucherait la table `Operation` : il lit et écrit des modèles, un point
//!    c'est tout. C'est la validation de la fiche opération qui écrit, comme
//!    pour n'importe quelle saisie faite au clavier — et la réserve de la fiche
//!    n'étant pas touchée, la fiche se sait modifiée et sa porte pose sa
//!    question.
//!
//! **Ni compte, ni date** dans un modèle (document 02 §3.8, et sa capture le
//! montre) : les deux ne prennent leur sens qu'au moment où l'on saisit, et un
//! modèle sert justement à traverser plusieurs saisies.

use crate::text::{french_sort_key, same_name_key};
use rusqlite::{Connection, Result};

/// Un modèle d'opération, tel que sa fiche F36 le montre.
#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct Template {
    pub id: i64,
    /// « Nom par défaut de la future opération après application du modèle ».
    pub label: String,
    /// En micro-unités, **signé** comme celui d'une opération : négatif pour un
    /// débit. La fiche montre le sens dans un combo et la grandeur dans le
    /// champ, exactement comme la fiche opération.
    pub amount: i64,
    pub payment_mode_id: i64,
    pub category_id: i64,
    pub assignment_id: i64,
    /// Pointé, engagé ou prévu — « Statut de l'opération par défaut dans ce
    /// modèle ».
    pub status_id: i64,
    pub payee_id: i64,
    pub project_id: i64,
}

const COLUMNS: &str = "IDModeleOperation, Libelle, Montant, IDModeOperation, \
     IDCategorie, IDAffectation, IDStatutOperation, IDTiers, IDProjets";

fn read(row: &rusqlite::Row<'_>) -> rusqlite::Result<Template> {
    Ok(Template {
        id: row.get(0)?,
        label: row.get(1)?,
        amount: row.get(2)?,
        payment_mode_id: row.get(3)?,
        category_id: row.get(4)?,
        assignment_id: row.get(5)?,
        status_id: row.get(6)?,
        payee_id: row.get(7)?,
        project_id: row.get(8)?,
    })
}

/// Tous les modèles, dans l'ordre où la liste F37 les montre : par libellé,
/// sous la collation française mesurée sur l'archive de l'auteur.
pub fn list(conn: &Connection) -> Result<Vec<Template>> {
    let mut statement = conn.prepare(&format!("SELECT {COLUMNS} FROM ModeleOperation"))?;
    let mut rows: Vec<Template> = statement.query_map([], read)?.collect::<Result<_>>()?;
    rows.sort_by_key(|template| french_sort_key(&template.label));
    Ok(rows)
}

/// Lit un modèle, ou `None` s'il n'existe plus.
pub fn get(conn: &Connection, id: i64) -> Result<Option<Template>> {
    match conn.query_row(
        &format!("SELECT {COLUMNS} FROM ModeleOperation WHERE IDModeleOperation = ?1"),
        [id],
        read,
    ) {
        Ok(template) => Ok(Some(template)),
        Err(rusqlite::Error::QueryReturnedNoRows) => Ok(None),
        Err(other) => Err(other),
    }
}

/// Le modèle qui porte déjà ce nom, s'il y en a un — son libellé, tel qu'il est
/// stocké. `except` est celui que l'on modifie, qui n'est pas un doublon de
/// lui-même.
///
/// La règle des nomenclatures (Fabrice, 25/07/2026) vaut ici pour la même
/// raison : on choisit un modèle **par son nom**, dans une liste, et deux noms
/// identiques feraient une question à deux réponses identiques.
pub fn same_name_as(conn: &Connection, label: &str, except: Option<i64>) -> Result<Option<String>> {
    let wanted = same_name_key(label);
    if wanted.is_empty() {
        return Ok(None);
    }
    Ok(list(conn)?
        .into_iter()
        .find(|template| Some(template.id) != except && same_name_key(&template.label) == wanted)
        .map(|template| template.label))
}

fn parameters(template: &Template) -> Vec<Box<dyn rusqlite::ToSql>> {
    vec![
        Box::new(template.label.trim().to_string()),
        Box::new(template.amount),
        Box::new(template.payment_mode_id),
        Box::new(template.category_id),
        Box::new(template.assignment_id),
        Box::new(template.status_id),
        Box::new(template.payee_id),
        Box::new(template.project_id),
    ]
}

const WRITABLE: &str = "Libelle, Montant, IDModeOperation, IDCategorie, \
     IDAffectation, IDStatutOperation, IDTiers, IDProjets";

/// Ajoute un modèle. La clef vient du générateur max+1, comme partout.
pub fn create(conn: &Connection, template: &Template) -> Result<i64> {
    let id = crate::database::keygen::next_id(conn, "ModeleOperation", "IDModeleOperation")?;
    let mut values = vec![Box::new(id) as Box<dyn rusqlite::ToSql>];
    values.extend(parameters(template));
    let placeholders = (1..=values.len())
        .map(|n| format!("?{n}"))
        .collect::<Vec<_>>()
        .join(", ");
    conn.execute(
        &format!(
            "INSERT INTO ModeleOperation (IDModeleOperation, {WRITABLE}) VALUES ({placeholders})"
        ),
        rusqlite::params_from_iter(values.iter().map(|value| value.as_ref())),
    )?;
    Ok(id)
}

/// Change un modèle. Rend `false` s'il n'existe plus.
pub fn update(conn: &Connection, id: i64, template: &Template) -> Result<bool> {
    let assignments = WRITABLE
        .split(',')
        .map(str::trim)
        .enumerate()
        .map(|(index, column)| format!("{column} = ?{}", index + 1))
        .collect::<Vec<_>>()
        .join(", ");
    let mut values = parameters(template);
    values.push(Box::new(id));
    let changed = conn.execute(
        &format!(
            "UPDATE ModeleOperation SET {assignments} WHERE IDModeleOperation = ?{}",
            values.len()
        ),
        rusqlite::params_from_iter(values.iter().map(|value| value.as_ref())),
    )?;
    Ok(changed > 0)
}

/// Supprime un modèle. Rend `false` s'il n'existe plus.
///
/// **Rien ne dépend d'un modèle** : aucune table ne le référence, et une
/// opération créée à partir de lui ne se souvient pas de lui. Le supprimer
/// n'entraîne donc rien — contrairement à une nomenclature, dont la suppression
/// réaffecte tout ce qui la portait.
pub fn delete(conn: &Connection, id: i64) -> Result<bool> {
    let changed = conn.execute(
        "DELETE FROM ModeleOperation WHERE IDModeleOperation = ?1",
        [id],
    )?;
    Ok(changed > 0)
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

    fn a_template(label: &str) -> Template {
        Template {
            id: 0,
            label: label.to_string(),
            amount: -70_000_000,
            payment_mode_id: 2,
            category_id: 3,
            assignment_id: 1,
            status_id: 1,
            payee_id: 4,
            project_id: 0,
        }
    }

    #[test]
    fn un_modele_est_ecrit_relu_et_change() {
        let conn = database();
        let id = create(&conn, &a_template("  Plein d'essence  ")).expect("ajout");

        let stored = get(&conn, id).expect("lecture").expect("existe");
        assert_eq!(stored.label, "Plein d'essence");
        assert_eq!(stored.amount, -70_000_000);
        assert_eq!(stored.category_id, 3);
        assert_eq!(stored.status_id, 1);

        let mut changed = stored.clone();
        changed.amount = 1_200_000;
        changed.status_id = 3;
        assert!(update(&conn, id, &changed).expect("modification"));
        let stored = get(&conn, id).expect("relecture").expect("existe");
        assert_eq!(stored.amount, 1_200_000);
        assert_eq!(stored.status_id, 3);

        assert!(delete(&conn, id).expect("suppression"));
        assert!(get(&conn, id).expect("après").is_none());
        assert!(!delete(&conn, id).expect("seconde suppression"));
    }

    #[test]
    fn la_liste_est_triee_sous_la_collation_francaise() {
        let conn = database();
        for label in ["Loyer", "Cantine", "Électricité", "Assurance"] {
            create(&conn, &a_template(label)).expect("ajout");
        }
        let labels: Vec<String> = list(&conn)
            .expect("liste")
            .into_iter()
            .map(|template| template.label)
            .collect();
        assert_eq!(labels, vec!["Assurance", "Cantine", "Électricité", "Loyer"]);
    }

    #[test]
    fn deux_modeles_ne_peuvent_pas_porter_le_meme_nom() {
        let conn = database();
        let id = create(&conn, &a_template("Loyer")).expect("ajout");
        assert_eq!(
            same_name_as(&conn, "loyer", None).expect("recherche"),
            Some("Loyer".to_string())
        );
        assert_eq!(same_name_as(&conn, "Cantine", None).expect("recherche"), None);
        assert_eq!(same_name_as(&conn, "Loyer", Some(id)).expect("recherche"), None);
    }

    /// **Un modèle ne touche jamais une opération.**
    ///
    /// C'est la règle que Fabrice a dictée le 29/07/2026 : appliquer un modèle
    /// remplit l'écran et rien d'autre ; c'est la validation de la fiche qui
    /// écrit. Ce croisement le prouve du côté du noyau : on écrit, on relit, on
    /// modifie et on supprime un modèle, et la table `Operation` n'a pas bougé
    /// d'une ligne. Une écriture qui s'y glisserait un jour ferait échouer ce
    /// test, et non l'utilisateur au moment où il abandonne sa saisie.
    #[test]
    fn aucun_chemin_de_ce_module_n_ecrit_dans_les_operations() {
        let conn = database();
        conn.execute(
            "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte) VALUES (1, 'CCP', 1)",
            [],
        )
        .expect("compte");
        conn.execute(
            "INSERT INTO Operation (IDOperation, Libelle, Date, Montant, IDCompte,
                                    IDStatutOperation)
             VALUES (1, 'Opération', '2026-01-01', -1000000, 1, 1)",
            [],
        )
        .expect("opération");

        let before: (i64, i64) = conn
            .query_row(
                "SELECT COUNT(*), COALESCE(SUM(Montant), 0) FROM Operation",
                [],
                |row| Ok((row.get(0)?, row.get(1)?)),
            )
            .expect("avant");

        let id = create(&conn, &a_template("Loyer")).expect("ajout");
        let mut template = get(&conn, id).expect("lecture").expect("existe");
        template.amount = -999_000_000;
        update(&conn, id, &template).expect("modification");
        list(&conn).expect("liste");
        delete(&conn, id).expect("suppression");

        let after: (i64, i64) = conn
            .query_row(
                "SELECT COUNT(*), COALESCE(SUM(Montant), 0) FROM Operation",
                [],
                |row| Ok((row.get(0)?, row.get(1)?)),
            )
            .expect("après");
        assert_eq!(
            before, after,
            "un modèle a écrit dans les opérations : seule la validation de la \
             fiche doit le faire"
        );
    }
}
