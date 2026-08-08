//! **Le verrou d'une base : son mot de passe** (décision de Fabrice,
//! 05/08/2026).
//!
//! Chaque base peut porter son propre mot de passe, ou n'en porter aucun.
//! C'est un ajout à Radinus, et non un portage : la 1.9.3 gardait dans
//! `ParamSecurite` un *hash* SHA3 du mot de passe — un verrou posé sur le
//! logiciel, pas sur le fichier, qui laissait les données lisibles par
//! quiconque ouvrait la base autrement.
//!
//! Ce que fait SQLCipher est d'une autre nature : **les pages du fichier sont
//! chiffrées en AES-256**, et sans la clé il n'y a rien à lire, pas même le
//! nom des tables. Le mot de passe n'est pas comparé à quelque chose de
//! rangé quelque part — il *est* la clé. C'est ce qui donne à ce module sa
//! forme : rien ici ne vérifie un mot de passe, on essaie de lire et on
//! regarde si la lecture réussit.
//!
//! **Rien n'est noté nulle part** (choix de Fabrice) : Radinus ne tient
//! aucune liste des bases protégées. Il ouvre, et si le fichier résiste il
//! demande. Une base copiée d'un autre ordinateur, renommée à la main ou
//! rangée ailleurs se comporte donc exactement pareil — il n'y a pas de
//! fiche à garder à jour, donc pas de fiche qui puisse mentir.
//!
//! **Et le prix, écrit ici pour qu'il ne se perde pas** : un mot de passe
//! oublié est une base perdue. Il n'y a pas de porte de service, pas de
//! question secrète, pas de récupération. C'est le principe même du
//! chiffrement, et Fabrice le sait.

use rusqlite::{Connection, Result};

/// Donne sa clé à une connexion fraîchement ouverte.
///
/// **Cela ne lit rien et ne vérifie rien** : SQLCipher se contente de retenir
/// la clé, dérivée en PBKDF2, et l'appliquera à la première page qu'il aura à
/// déchiffrer. Un mot de passe faux ne se voit donc pas ici — il se voit à
/// [`readable`], et nulle part avant.
///
/// L'ordre doit venir **avant toute autre requête** sur la connexion : une
/// lecture faite d'abord fixe l'état de la base et `PRAGMA key` n'a plus
/// d'effet.
pub fn unlock(conn: &Connection, password: &str) -> Result<()> {
    // `pragma_update` fait passer le mot de passe comme un paramètre lié :
    // une apostrophe dans un mot de passe ne casse donc rien, là où un
    // `format!` aurait fabriqué une requête invalide — ou pire, valide.
    conn.pragma_update(None, "key", password)
}

/// Est-ce que cette connexion sait lire son fichier ?
///
/// La seule question qui vaille, et elle se pose de la même façon pour les
/// trois cas : une base en clair ouverte sans clé répond oui, une base
/// protégée ouverte avec la bonne clé répond oui, tout le reste répond non.
///
/// La lecture choisie est celle du catalogue de SQLite — la toute première
/// page du fichier. C'est la moins chère possible, et c'est celle qui échoue
/// le plus tôt quand la clé est fausse.
pub fn readable(conn: &Connection) -> bool {
    conn.query_row("SELECT COUNT(*) FROM sqlite_master", [], |row| {
        row.get::<_, i64>(0)
    })
    .is_ok()
}

/// Change le mot de passe d'une base **déjà chiffrée et déjà déverrouillée**.
///
/// **Et rien d'autre** : `PRAGMA rekey` ne sait ni chiffrer une base en clair,
/// ni déchiffrer une base protégée. SQLCipher le dit lui-même quand on essaie
/// — « PRAGMA rekey can only be run on an existing encrypted database. Use
/// sqlcipher_export() and ATTACH » — et c'est ce que fait [`recopy_through`]
/// pour les deux passages entre les deux mondes. Je l'ai appris en le
/// cassant, le 05/08/2026.
fn rekey(conn: &Connection, password: &str) -> Result<()> {
    conn.pragma_update(None, "rekey", password)
}

/// **Le passage d'un monde à l'autre : en clair vers protégé, ou l'inverse.**
///
/// SQLCipher ne transforme pas un fichier sur place. Il recopie : on accroche
/// un second fichier avec la clé voulue — vide pour le clair —, on lui verse
/// tout le contenu du premier avec `sqlcipher_export`, et le second remplace
/// le premier. C'est la manœuvre que sa documentation prescrit, et la seule
/// qui marche.
///
/// **Le numéro de version du schéma est recopié à la main**, et cet oubli-là
/// est un classique : `sqlcipher_export` verse les tables, les index et les
/// données, mais pas `PRAGMA user_version`, qui est un entier rangé dans
/// l'en-tête du fichier. Sans cette ligne, la base convertie repartirait à
/// zéro et `migrate` la croirait plus vieille qu'elle n'est.
///
/// La connexion est **fermée avant le remplacement** : renommer un fichier
/// sous une connexion ouverte la laisserait parler à l'ancien, qui n'existe
/// plus. C'est pour cela que cette fonction prend la connexion et non une
/// référence — elle est faite pour la consommer.
fn recopy_through(conn: Connection, path: &std::path::Path, key: &str) -> Result<()> {
    // À côté du fichier d'origine, et non dans un dossier temporaire du
    // système : le renommage final doit rester sur le même disque pour être
    // instantané, et une base peut vivre sur une clé USB.
    let mut name = path.file_name().unwrap_or_default().to_os_string();
    name.push(".en-conversion");
    let target = path.with_file_name(name);
    std::fs::remove_file(&target).ok();

    let outcome = (|| -> Result<()> {
        conn.execute(
            "ATTACH DATABASE ?1 AS converti KEY ?2",
            (target.to_string_lossy().as_ref(), key),
        )?;
        conn.query_row("SELECT sqlcipher_export('converti')", [], |_| Ok(()))?;
        let version: i64 = conn.query_row("PRAGMA user_version", [], |row| row.get(0))?;
        conn.execute_batch(&format!("PRAGMA converti.user_version = {version};"))?;
        conn.execute_batch("DETACH DATABASE converti;")
    })();

    // La connexion s'en va dans tous les cas : ratée, elle tient encore le
    // fichier à moitié écrit qu'on veut jeter.
    drop(conn);

    if let Err(error) = outcome {
        std::fs::remove_file(&target).ok();
        return Err(error);
    }

    std::fs::rename(&target, path).map_err(|error| {
        rusqlite::Error::SqliteFailure(
            rusqlite::ffi::Error::new(rusqlite::ffi::SQLITE_CANTOPEN),
            Some(error.to_string()),
        )
    })
}

/// Ce qu'un changement de mot de passe peut donner.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ChangeOutcome {
    /// La base est désormais protégée par le nouveau mot de passe.
    Protected,
    /// La base n'est plus protégée du tout.
    Unprotected,
    /// L'ancien mot de passe ne déverrouille pas cette base — rien n'a été
    /// touché.
    WrongPassword,
}

/// **Le geste complet : ouvrir avec l'ancien, réécrire avec le nouveau.**
///
/// `old` vide veut dire « cette base n'est pas censée être protégée » et
/// `new` vide veut dire « qu'elle ne le soit plus ». Les quatre combinaisons
/// ont donc un sens, et c'est voulu : une seule fiche à trois champs sert à
/// protéger, à changer et à retirer.
///
/// Rien n'est écrit tant que la lecture n'a pas réussi. Un ancien mot de
/// passe faux rend [`ChangeOutcome::WrongPassword`] et laisse le fichier
/// intact — c'est le seul contrôle possible, et c'est le bon : il porte sur
/// ce que la clé permet de lire, pas sur une chaîne rangée à côté.
pub fn change(path: &std::path::Path, old: &str, new: &str) -> Result<ChangeOutcome> {
    let conn = Connection::open(path)?;
    if !old.is_empty() {
        unlock(&conn, old)?;
    }
    if !readable(&conn) {
        return Ok(ChangeOutcome::WrongPassword);
    }

    // La lecture a réussi, donc l'état d'avant n'est plus une supposition :
    // un ancien mot de passe fourni était le bon, et un ancien mot de passe
    // vide veut dire que la base était bien en clair.
    match (!old.is_empty(), !new.is_empty()) {
        // Protégée hier, protégée demain : le seul cas que `rekey` sait faire.
        (true, true) => {
            rekey(&conn, new)?;
            Ok(ChangeOutcome::Protected)
        }
        // En clair hier, en clair demain : on n'a rien demandé du tout.
        (false, false) => Ok(ChangeOutcome::Unprotected),
        // Les deux passages d'un monde à l'autre.
        (false, true) => {
            recopy_through(conn, path, new)?;
            Ok(ChangeOutcome::Protected)
        }
        (true, false) => {
            recopy_through(conn, path, "")?;
            Ok(ChangeOutcome::Unprotected)
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    static COUNTER: std::sync::atomic::AtomicU32 = std::sync::atomic::AtomicU32::new(0);

    fn scratch(label: &str) -> std::path::PathBuf {
        let n = COUNTER.fetch_add(1, std::sync::atomic::Ordering::SeqCst);
        let path = std::env::temp_dir().join(format!("radinus_lock_{label}_{n}.sqlite"));
        // **Le fichier d'un essai précédent est jeté d'abord.** Un test qui a
        // échoué laisse le sien derrière lui, et le compteur repart de zéro à
        // chaque exécution : sans cette ligne, le deuxième lancement échoue
        // sur « table already exists » et fait accuser le chiffrement d'une
        // faute qui n'est pas la sienne. Vu le 05/08/2026.
        std::fs::remove_file(&path).ok();
        path
    }

    /// Une base à laquelle on n'a rien demandé se lit sans clé — c'est le cas
    /// de toutes celles qui existent aujourd'hui, et il ne doit rien leur
    /// arriver.
    #[test]
    fn une_base_en_clair_se_lit_sans_rien_demander() {
        let path = scratch("clair");
        {
            let conn = Connection::open(&path).unwrap();
            conn.execute_batch("CREATE TABLE t (x INTEGER); INSERT INTO t VALUES (1);")
                .unwrap();
        }
        let conn = Connection::open(&path).unwrap();
        assert!(readable(&conn));
        drop(conn);
        std::fs::remove_file(&path).ok();
    }

    /// **Le cœur du dispositif** : protégée, la base ne se lit plus sans son
    /// mot de passe, et se lit de nouveau avec.
    #[test]
    fn une_base_protegee_ne_se_lit_plus_sans_son_mot_de_passe() {
        let path = scratch("protegee");
        {
            let conn = Connection::open(&path).unwrap();
            conn.execute_batch("CREATE TABLE t (x INTEGER); INSERT INTO t VALUES (42);")
                .unwrap();
        }
        assert_eq!(
            change(&path, "", "grand-mère").unwrap(),
            ChangeOutcome::Protected
        );

        // Sans clé : rien, pas même le nom des tables.
        {
            let conn = Connection::open(&path).unwrap();
            assert!(!readable(&conn));
        }
        // Avec la bonne clé : tout.
        {
            let conn = Connection::open(&path).unwrap();
            unlock(&conn, "grand-mère").unwrap();
            assert!(readable(&conn));
            let x: i64 = conn.query_row("SELECT x FROM t", [], |r| r.get(0)).unwrap();
            assert_eq!(x, 42);
        }
        // Avec une autre : rien non plus.
        {
            let conn = Connection::open(&path).unwrap();
            unlock(&conn, "grand-père").unwrap();
            assert!(!readable(&conn));
        }
        std::fs::remove_file(&path).ok();
    }

    /// Les trois gestes de la fiche à trois champs, dans l'ordre où un
    /// utilisateur les fait : poser, changer, retirer.
    #[test]
    fn poser_puis_changer_puis_retirer() {
        let path = scratch("trois_gestes");
        {
            let conn = Connection::open(&path).unwrap();
            conn.execute_batch("CREATE TABLE t (x INTEGER); INSERT INTO t VALUES (7);")
                .unwrap();
        }

        assert_eq!(change(&path, "", "un").unwrap(), ChangeOutcome::Protected);
        assert_eq!(change(&path, "un", "deux").unwrap(), ChangeOutcome::Protected);
        assert_eq!(
            change(&path, "deux", "").unwrap(),
            ChangeOutcome::Unprotected
        );

        let conn = Connection::open(&path).unwrap();
        assert!(readable(&conn), "la protection est bien retirée");
        let x: i64 = conn.query_row("SELECT x FROM t", [], |r| r.get(0)).unwrap();
        assert_eq!(x, 7, "et les données ont traversé les trois gestes");
        drop(conn);
        std::fs::remove_file(&path).ok();
    }

    /// **Un ancien mot de passe faux ne touche à rien.** C'est la seule
    /// garantie qui compte : se tromper en changeant son mot de passe ne doit
    /// pas rendre la base illisible avec l'ancien.
    #[test]
    fn un_ancien_mot_de_passe_faux_laisse_le_fichier_intact() {
        let path = scratch("faux");
        {
            let conn = Connection::open(&path).unwrap();
            conn.execute_batch("CREATE TABLE t (x INTEGER); INSERT INTO t VALUES (3);")
                .unwrap();
        }
        change(&path, "", "juste").unwrap();

        assert_eq!(
            change(&path, "faux", "nouveau").unwrap(),
            ChangeOutcome::WrongPassword
        );

        let conn = Connection::open(&path).unwrap();
        unlock(&conn, "juste").unwrap();
        assert!(readable(&conn), "l'ancien mot de passe marche toujours");
        drop(conn);
        std::fs::remove_file(&path).ok();
    }

    /// **Une vraie base Radinus traverse les deux conversions sans rien
    /// perdre** — ni ses données, ni son numéro de version de schéma.
    ///
    /// Le numéro est le point délicat : `sqlcipher_export` recopie les tables
    /// mais pas `PRAGMA user_version`. Perdu, il ferait croire à `migrate`
    /// que la base est plus vieille qu'elle n'est.
    #[test]
    fn une_vraie_base_radinus_traverse_les_deux_conversions() {
        let path = scratch("vraie_base");
        {
            let conn = crate::database::create_new_database(&path).unwrap();
            conn.execute(
                "INSERT INTO Compte (IDCompte, Libelle, IDTypeCompte) VALUES (1, 'Mon CCP', 1)",
                [],
            )
            .unwrap();
        }

        let attendu = crate::database::schema::CURRENT_SCHEMA_VERSION;

        // En clair -> protégée.
        assert_eq!(
            change(&path, "", "sésame").unwrap(),
            ChangeOutcome::Protected
        );
        {
            let opened = crate::database::open_existing_database(&path, Some("sésame")).unwrap();
            let label: String = opened
                .conn
                .query_row("SELECT Libelle FROM Compte WHERE IDCompte = 1", [], |r| {
                    r.get(0)
                })
                .unwrap();
            assert_eq!(label, "Mon CCP");
            let version: i64 = opened
                .conn
                .query_row("PRAGMA user_version", [], |r| r.get(0))
                .unwrap();
            assert_eq!(version, attendu, "le numéro de schéma a traversé");
            let banques: i64 = opened
                .conn
                .query_row("SELECT COUNT(*) FROM Banques", [], |r| r.get(0))
                .unwrap();
            assert_eq!(banques, 30, "les nomenclatures aussi");
        }

        // Protégée -> en clair.
        assert_eq!(
            change(&path, "sésame", "").unwrap(),
            ChangeOutcome::Unprotected
        );
        {
            let opened = crate::database::open_existing_database(&path, None).unwrap();
            let label: String = opened
                .conn
                .query_row("SELECT Libelle FROM Compte WHERE IDCompte = 1", [], |r| {
                    r.get(0)
                })
                .unwrap();
            assert_eq!(label, "Mon CCP");
            let version: i64 = opened
                .conn
                .query_row("PRAGMA user_version", [], |r| r.get(0))
                .unwrap();
            assert_eq!(version, attendu);
        }
        std::fs::remove_file(&path).ok();
    }

    /// Une apostrophe dans un mot de passe ne casse rien : le mot de passe
    /// voyage comme un paramètre lié, pas comme un morceau de requête.
    #[test]
    fn une_apostrophe_dans_le_mot_de_passe_ne_casse_rien() {
        let path = scratch("apostrophe");
        {
            let conn = Connection::open(&path).unwrap();
            conn.execute_batch("CREATE TABLE t (x INTEGER); INSERT INTO t VALUES (1);")
                .unwrap();
        }
        let tordu = "l'été ; DROP TABLE t; --";
        assert_eq!(change(&path, "", tordu).unwrap(), ChangeOutcome::Protected);

        let conn = Connection::open(&path).unwrap();
        unlock(&conn, tordu).unwrap();
        assert!(readable(&conn));
        let count: i64 = conn
            .query_row("SELECT COUNT(*) FROM t", [], |r| r.get(0))
            .unwrap();
        assert_eq!(count, 1);
        drop(conn);
        std::fs::remove_file(&path).ok();
    }
}
