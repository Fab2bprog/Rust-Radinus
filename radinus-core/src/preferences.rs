//! La table `Preferences` — et **rien d'autre que ce qui a été demandé**.
//!
//! Elle est dans le schéma depuis la 1.x sans que rien ne la lise :
//! `IDPreferences`, `Cle` unique, `ValeurJSON`. Elle sert enfin, ce qui vaut
//! au passage de ne toucher ni au schéma ni à `VerDataBase`.
//!
//! **Règle de Fabrice, 03/08/2026, et elle est absolue** : rien n'entre dans
//! cette table qu'il n'ait demandé d'y mettre, clef par clef. Pas de largeur
//! de colonne mémorisée au passage, pas de dernier dossier ouvert, pas de
//! confort ajouté parce qu'il tombait sous la main. Un magasin clef/valeur
//! libre est précisément l'endroit où un logiciel accumule en silence jusqu'à
//! ce que personne ne sache plus ce qu'il y a dedans ni qui l'a écrit.
//!
//! **Une seule clef existe aujourd'hui : `devise`.** Pour en ajouter une, il
//! faut son accord, et elle s'ajoute ici avec son type.

use rusqlite::{Connection, OptionalExtension, Result};

/// La clef de la devise. Écrite en toutes lettres et une seule fois : une
/// chaîne recopiée à deux endroits finit toujours par diverger.
pub const CURRENCY_KEY: &str = "devise";

// **Le zoom n'est plus une préférence de la base** (Fabrice, 04/08/2026) : il
// est passé dans `settings/radinus_config.json`, à côté de la langue, parce
// qu'il dit quelque chose de l'écran et non des comptes. Ses bornes, sa remise
// dans les bornes et sa lecture sont dans `location`.
//
// **La ligne `zoom` des bases déjà écrites n'est ni lue ni effacée** : elle ne
// gêne personne, et une migration qui touche à des données pour n'en rien
// tirer est une occasion de casser quelque chose pour rien.
//
// Ce paragraphe ne documente plus rien — la constante qu'il accompagnait est
// partie avec le zoom —, d'où le `//` et non le `///` : un commentaire de
// documentation orphelin va se coller à la déclaration suivante, qui ne parle
// pas du tout de la même chose.

/// Ce que l'utilisateur a choisi dans la fenêtre des préférences.
///
/// **Le nom des variantes n'est pas cosmétique** : il part tel quel dans le
/// JSON de la base, et une base écrite aujourd'hui doit se relire dans dix
/// ans. Les renommer casserait les bases existantes.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Currency {
    /// Celle du système d'exploitation, relue à chaque affichage.
    System,
    Euro,
    Dollar,
    /// Le dollar canadien.
    ///
    /// **Son signe est le même `$` que l'américain** — c'est la même glyphe, et
    /// au Canada on écrit « 1 549,81 $ » sans plus. Les formes `C$` et `CA$` ne
    /// servent qu'à distinguer les deux quand ils paraissent ensemble, ce qui
    /// n'arrive jamais ici : Radinus n'affiche qu'une devise.
    ///
    /// L'entrée existe donc pour une raison qui n'est pas le signe : **qu'un
    /// canadien se reconnaisse dans la liste**, comme chaque langue y est
    /// écrite dans la sienne. Fabrice en a, et il l'a demandée le 03/08/2026.
    CanadianDollar,
    /// Le franc CFA.
    Cfa,
    /// Le franc Pacifique, ou franc CFP (ISO `XPF`), émis par l'IEOM et arrimé
    /// à l'euro. Il a cours en Nouvelle-Calédonie, en Polynésie française et à
    /// Wallis-et-Futuna. Il s'écrit `F`, `FCFP` ou `F CFP` ; on retient
    /// **`FCFP`**, sans ambiguïté et en parallèle du `FCFA`.
    CfpFranc,
    /// Le franc suisse.
    ///
    /// Son signe est **`CHF`**, le code ISO lui-même : c'est ainsi qu'on écrit
    /// les montants en Suisse, et c'est ce que tout le monde reconnaît. Les
    /// formes `Fr.` et `SFr.` existent, mais leur point est justement un des
    /// caractères qu'un signe n'a pas le droit de porter — `money::parse`
    /// l'ôterait en lisant une saisie.
    SwissFranc,
    /// **Aucune devise affichée** : les montants sortent nus.
    ///
    /// Ce n'est pas « pas encore réglé », c'est un choix, et il se mémorise
    /// comme les autres — sans quoi il retomberait sur l'euro au démarrage
    /// suivant. Demandé par Fabrice le 03/08/2026.
    NoSign,
    /// Le signe tapé à la main.
    Custom(String),
}

impl Default for Currency {
    /// **Une base neuve suit le système.** C'est ce que Fabrice a demandé, et
    /// c'est aussi ce qui évite d'imposer l'euro à quelqu'un qui n'en a jamais
    /// vu.
    fn default() -> Self {
        Currency::System
    }
}

impl Currency {
    /// Le nom du choix, tel qu'il s'écrit en base.
    pub fn key(&self) -> &'static str {
        match self {
            Currency::System => "systeme",
            Currency::Euro => "EUR",
            Currency::Dollar => "USD",
            Currency::CanadianDollar => "CAD",
            Currency::NoSign => "aucune",
            Currency::Cfa => "XOF",
            Currency::CfpFranc => "XPF",
            Currency::SwissFranc => "CHF",
            Currency::Custom(_) => "perso",
        }
    }

    /// Le signe personnalisé, vide pour les autres choix.
    pub fn custom_sign(&self) -> &str {
        match self {
            Currency::Custom(sign) => sign,
            _ => "",
        }
    }

    /// Le choix relu depuis ce que porte la base.
    ///
    /// **Un choix inconnu retombe sur le système** plutôt que d'échouer : une
    /// base écrite par une version future, ou un JSON abîmé à la main, ne doit
    /// pas empêcher Radinus d'afficher un montant.
    pub fn from_parts(choice: &str, sign: &str) -> Self {
        match choice {
            "EUR" => Currency::Euro,
            "USD" => Currency::Dollar,
            "CAD" => Currency::CanadianDollar,
            "aucune" => Currency::NoSign,
            "XOF" => Currency::Cfa,
            "XPF" => Currency::CfpFranc,
            "CHF" => Currency::SwissFranc,
            "perso" => Currency::Custom(clamp_sign(sign)),
            _ => Currency::System,
        }
    }

    /// Le signe à écrire, `system` étant ce que la machine a répondu.
    ///
    /// Le noyau ne parle pas au système d'exploitation (08_ARCHITECTURE.md
    /// §2.1) : c'est le contrôleur qui lui tend cette réponse, et un système
    /// muet vaut l'euro.
    pub fn sign(&self, system: &str) -> String {
        match self {
            Currency::System if sign_is_usable(system) => clamp_sign(system),
            Currency::System => "€".to_string(),
            Currency::NoSign => String::new(),
            Currency::Euro => "€".to_string(),
            Currency::Dollar | Currency::CanadianDollar => "$".to_string(),
            Currency::Cfa => "FCFA".to_string(),
            Currency::CfpFranc => "FCFP".to_string(),
            Currency::SwissFranc => "CHF".to_string(),
            // **La seconde barrière.** La fenêtre refuse déjà à la frappe et le
            // contrôleur refuse d'enregistrer ; celle-ci protège de ce qu'aucun
            // des deux ne voit — un `ValeurJSON` modifié à la main dans la base,
            // ou écrit par une version future. Un signe inutilisable ne devient
            // jamais le signe en vigueur : il vaut l'euro.
            Currency::Custom(sign) if sign_is_usable(sign) => clamp_sign(sign),
            Currency::Custom(_) => "€".to_string(),
        }
    }
}

/// Huit caractères au plus, et **huit caractères, pas huit octets** : « € »
/// en pèse trois, et couper au milieu rendrait un texte invalide.
fn clamp_sign(sign: &str) -> String {
    sign.trim().chars().take(8).collect()
}

/// Longueur maximale d'un signe, en caractères.
pub const SIGN_MAX: usize = 8;

/// **Ce qu'un signe de devise n'a pas le droit de contenir**, et ce n'est pas
/// une question de goût.
///
/// Le signe n'est pas seulement écrit à côté des montants : `money::parse`
/// **l'ôte** avant de lire une saisie, pour qu'on puisse recopier
/// « 1 549,81 $ » depuis sa propre fenêtre. Un signe qui ressemble à un
/// morceau de nombre corrompt donc les saisies, en silence :
///
/// - signe `0` : l'utilisateur tape `120`, le zéro final est ôté, **12** est
///   enregistré ;
/// - signe `-` : il tape `-12`, le moins est ôté, et le débit devient un
///   **crédit**.
///
/// Des chiffres justes, faux, sans un mot. D'où l'interdiction de tout ce qui
/// peut appartenir à un nombre, **où que ce soit dans le signe** — et non du
/// seul chiffre isolé. Ce qui reste suffit à toutes les devises du monde :
/// lettres et symboles, `€ $ £ ¥ CHF kr zł Kč FCFA`.
fn forbidden_in_sign(c: char) -> bool {
    c.is_ascii_digit()
        // Les chiffres des autres écritures comptent autant : « ٠ » est un
        // zéro arabe, et `parse` ne le lit pas mieux qu'un autre.
        || c.is_numeric()
        || matches!(c, '-' | '+' | ',' | '.' | '(' | ')')
}

/// Un signe utilisable, ou non.
pub fn sign_is_usable(sign: &str) -> bool {
    let trimmed = sign.trim();
    !trimmed.is_empty()
        && trimmed.chars().count() <= SIGN_MAX
        && !trimmed.chars().any(forbidden_in_sign)
}

/// Pourquoi ce signe est refusé, dans la langue du logiciel — ou rien s'il
/// convient.
pub fn sign_refusal(sign: &str, language: crate::i18n::Language) -> Option<String> {
    let trimmed = sign.trim();
    if trimmed.is_empty() {
        return Some(crate::i18n::text(language, "preferences-custom-required"));
    }
    if trimmed.chars().count() > SIGN_MAX {
        return Some(crate::i18n::text(language, "preferences-sign-too-long"));
    }
    if trimmed.chars().any(forbidden_in_sign) {
        return Some(crate::i18n::text(language, "preferences-sign-not-a-number"));
    }
    None
}

/// La valeur brute d'une clef, ou rien.
pub fn read(conn: &Connection, key: &str) -> Result<Option<String>> {
    conn.query_row(
        "SELECT ValeurJSON FROM Preferences WHERE Cle = ?1",
        [key],
        |row| row.get(0),
    )
    .optional()
}

/// Écrit une clef, en remplaçant ce qui s'y trouvait.
///
/// La clef étant unique, `ON CONFLICT` évite d'avoir à savoir si la ligne
/// existe déjà — et évite surtout la course entre le savoir et l'écrire.
pub fn write(conn: &Connection, key: &str, value: &str) -> Result<()> {
    conn.execute(
        "INSERT INTO Preferences (Cle, ValeurJSON) VALUES (?1, ?2)
         ON CONFLICT(Cle) DO UPDATE SET ValeurJSON = excluded.ValeurJSON",
        [key, value],
    )?;
    Ok(())
}

/// La devise choisie, ou celle du système si rien n'a jamais été écrit.
pub fn currency(conn: &Connection) -> Result<Currency> {
    let Some(text) = read(conn, CURRENCY_KEY)? else {
        return Ok(Currency::default());
    };
    // Un JSON illisible ne fait pas échouer l'affichage des montants : on
    // retombe sur le système, comme pour un choix inconnu.
    let Ok(value) = serde_json::from_str::<serde_json::Value>(&text) else {
        return Ok(Currency::default());
    };
    let field = |name: &str| -> String {
        value
            .get(name)
            .and_then(serde_json::Value::as_str)
            .unwrap_or_default()
            .to_string()
    };
    Ok(Currency::from_parts(&field("choix"), &field("signe")))
}

/// Enregistre la devise choisie.
pub fn set_currency(conn: &Connection, currency: &Currency) -> Result<()> {
    let value = serde_json::json!({
        "choix": currency.key(),
        "signe": currency.custom_sign(),
    });
    write(conn, CURRENCY_KEY, &value.to_string())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database::{schema, seed};

    fn database() -> Connection {
        let conn = Connection::open_in_memory().expect("base en mémoire");
        schema::migrate(&conn).expect("schéma");
        seed::seed_initial_data(&conn).expect("valeurs initiales");
        conn
    }

    /// Une base neuve n'a rien écrit, et suit le système.
    #[test]
    fn a_fresh_database_follows_the_system() {
        let conn = database();
        assert_eq!(currency(&conn).expect("devise"), Currency::System);
        assert_eq!(read(&conn, CURRENCY_KEY).expect("lecture"), None);
    }

    /// Ce qui est écrit se relit, y compris le signe tapé à la main.
    #[test]
    fn what_is_written_reads_back() {
        let conn = database();
        for chosen in [
            Currency::Euro,
            Currency::Dollar,
            Currency::Cfa,
            Currency::CanadianDollar,
            Currency::NoSign,
            Currency::CfpFranc,
            Currency::SwissFranc,
            Currency::Custom("kr".to_string()),
            Currency::System,
        ] {
            set_currency(&conn, &chosen).expect("écriture");
            assert_eq!(currency(&conn).expect("devise"), chosen);
        }
    }

    /// **Une seule ligne, quoi qu'on fasse.** La clef est unique et l'écriture
    /// remplace : dix changements de devise ne laissent pas dix lignes.
    #[test]
    fn changing_the_choice_never_adds_a_second_row() {
        let conn = database();
        for chosen in [Currency::Euro, Currency::Dollar, Currency::Euro] {
            set_currency(&conn, &chosen).expect("écriture");
        }
        let count: i64 = conn
            .query_row("SELECT COUNT(*) FROM Preferences", [], |row| row.get(0))
            .expect("comptage");
        assert_eq!(count, 1);
    }

    /// Un JSON abîmé ou un choix venu d'une version future n'empêche pas
    /// d'afficher un montant.
    #[test]
    fn a_broken_value_falls_back_instead_of_failing() {
        let conn = database();
        write(&conn, CURRENCY_KEY, "ceci n'est pas du JSON").expect("écriture");
        assert_eq!(currency(&conn).expect("devise"), Currency::System);
        write(&conn, CURRENCY_KEY, r#"{"choix":"BITCOIN","signe":"₿"}"#).expect("écriture");
        assert_eq!(currency(&conn).expect("devise"), Currency::System);
    }

    /// **Un signe trop long est refusé, il n'est pas raccourci.**
    ///
    /// Ce test disait le contraire avant que le piège ne soit refermé : dix
    /// « € » devenaient huit. Tronquer afficherait un signe que personne n'a
    /// demandé, et sur toutes les lignes du logiciel — mieux vaut retomber sur
    /// l'euro, qui est au moins une devise que quelqu'un a choisie un jour.
    ///
    /// La longueur se compte en **caractères** et non en octets : « € » en
    /// pèse trois, et huit d'entre eux passeraient pour vingt-quatre.
    #[test]
    fn a_sign_that_is_too_long_is_refused_rather_than_shortened() {
        assert_eq!(Currency::Custom("€€€€€€€€€€".to_string()).sign(""), "€");
        assert_eq!(Currency::Custom("€€€€€€€€".to_string()).sign(""), "€€€€€€€€");
        // Les espaces autour ne comptent pas : on les ôte avant de mesurer.
        assert_eq!(Currency::Custom("  CHF  ".to_string()).sign(""), "CHF");
    }

    /// **Les deux dollars s'écrivent pareil, et se rangent à part.** Le choix
    /// est mémorisé distinctement — un canadien qui rouvre ses préférences
    /// retrouve « Dollars canadiens » coché, et non « Dollars ».
    #[test]
    fn both_dollars_write_the_same_sign_and_are_remembered_apart() {
        assert_eq!(Currency::Dollar.sign(""), "$");
        assert_eq!(Currency::CanadianDollar.sign(""), "$");
        assert_ne!(Currency::Dollar.key(), Currency::CanadianDollar.key());
        assert_eq!(Currency::from_parts("CAD", ""), Currency::CanadianDollar);
    }

    /// Le franc suisse porte son code ISO, et **c'est un signe utilisable** :
    /// les formes `Fr.` et `SFr.` ne le seraient pas, leur point étant l'un des
    /// caractères que `money::parse` ôte d'une saisie.
    #[test]
    fn the_swiss_franc_wears_its_iso_code() {
        assert_eq!(Currency::SwissFranc.sign(""), "CHF");
        assert!(sign_is_usable("CHF"));
        assert!(!sign_is_usable("Fr."));
        assert_eq!(Currency::from_parts("CHF", ""), Currency::SwissFranc);
    }

    /// **« Aucune » est un choix, pas une absence de choix.** Il se relit tel
    /// quel, et ne retombe pas sur l'euro au démarrage suivant — ce qui serait
    /// arrivé si on l'avait représenté par un signe vide.
    #[test]
    fn asking_for_no_currency_is_remembered_as_such() {
        let conn = database();
        set_currency(&conn, &Currency::NoSign).expect("écriture");
        assert_eq!(currency(&conn).expect("devise"), Currency::NoSign);
        assert_eq!(Currency::NoSign.sign("$"), "", "le signe du système s'est invité");
    }

    /// Les deux francs de la zone franc ne se confondent pas : le CFA et le
    /// Pacifique portent chacun le sien, et se rangent sous leur propre code.
    #[test]
    fn the_two_franc_zones_do_not_get_mixed_up() {
        assert_eq!(Currency::Cfa.sign(""), "FCFA");
        assert_eq!(Currency::CfpFranc.sign(""), "FCFP");
        assert_eq!(Currency::from_parts("XPF", ""), Currency::CfpFranc);
        assert_ne!(Currency::Cfa.key(), Currency::CfpFranc.key());
    }

    /// **Une seule clef depuis le 04/08/2026.** Le zoom est parti dans la
    /// configuration du logiciel ; s'il en revenait ici, ce test le dirait —
    /// et une taille d'affichage qui voyagerait de nouveau avec les sauvegardes
    /// serait exactement le défaut que Fabrice a fait corriger.
    #[test]
    fn radinus_writes_one_key_and_no_other() {
        let conn = database();
        set_currency(&conn, &Currency::Cfa).expect("devise");
        let keys: Vec<String> = conn
            .prepare("SELECT Cle FROM Preferences ORDER BY Cle")
            .expect("requête")
            .query_map([], |row| row.get(0))
            .expect("lecture")
            .collect::<Result<_>>()
            .expect("clefs");
        assert_eq!(keys, vec![CURRENCY_KEY.to_string()]);
    }

    /// **Le piège, et pourquoi il en est un.** Un signe qui ressemble à un
    /// morceau de nombre corrompt les saisies, parce que `money::parse` ôte le
    /// signe avant de lire. Ces deux-là sont les cas qui font mal.
    #[test]
    fn a_sign_that_looks_like_part_of_a_number_is_refused() {
        for refused in ["0", "12", "-", "+", "$-", ",", ".", "(", ")", "1F", "٠"] {
            assert!(!sign_is_usable(refused), "« {refused} » aurait dû être refusé");
        }
    }

    /// Et tout ce dont une devise a besoin passe.
    #[test]
    fn every_sign_a_currency_needs_goes_through() {
        for accepted in ["€", "$", "£", "¥", "CHF", "kr", "zł", "Kč", "FCFA", "F CFA"] {
            assert!(sign_is_usable(accepted), "« {accepted} » aurait dû passer");
        }
    }

    /// Trop long, vide, ou du blanc : refusés aussi.
    #[test]
    fn a_sign_is_bounded_and_never_empty() {
        assert!(!sign_is_usable(""));
        assert!(!sign_is_usable("   "));
        assert!(sign_is_usable("ABCDEFGH"));
        assert!(!sign_is_usable("ABCDEFGHI"));
    }

    /// **La seconde barrière tient.** Un JSON modifié à la main dans la base
    /// ne peut pas imposer un signe qui casserait les saisies : il vaut l'euro,
    /// et les montants restent lisibles.
    #[test]
    fn a_hand_edited_database_cannot_impose_a_broken_sign() {
        let conn = database();
        write(&conn, CURRENCY_KEY, r#"{"choix":"perso","signe":"0"}"#).expect("écriture");
        let chosen = currency(&conn).expect("devise");
        assert_eq!(chosen, Currency::Custom("0".to_string()));
        assert_eq!(chosen.sign(""), "€", "un signe cassé est devenu le signe en vigueur");
    }

    /// Un système qui répondrait n'importe quoi ne casse rien non plus.
    #[test]
    fn an_unusable_system_answer_is_worth_the_euro() {
        assert_eq!(Currency::System.sign("-"), "€");
        assert_eq!(Currency::System.sign("12"), "€");
        assert_eq!(Currency::System.sign("kr"), "kr");
    }

    /// Un système muet vaut l'euro, et un signe personnalisé vide aussi : un
    /// montant sans aucun signe ne dirait pas qu'il est en euros, il dirait
    /// qu'on ne sait pas.
    #[test]
    fn a_silent_system_is_worth_the_euro() {
        assert_eq!(Currency::System.sign(""), "€");
        assert_eq!(Currency::System.sign("   "), "€");
        assert_eq!(Currency::System.sign("$"), "$");
        assert_eq!(Currency::Custom(String::new()).sign("$"), "€");
    }
}
