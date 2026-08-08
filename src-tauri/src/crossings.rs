//! **Les tests qui se croisent.**
//!
//! Principe donné par Fabrice le 26/07/2026, après que 519 vérifications
//! eurent laissé passer deux fautes qu'il a trouvées en une minute :
//!
//! > Les meilleurs tests sont ceux qui croisent les données ou ceux qui sont
//! > aux deux extrémités du problème (entrée – sortie, appelant – appelé,
//! > émetteur – récepteur). La vérité apparaît souvent là où les logiques se
//! > rencontrent.
//!
//! Il avait raison sur le diagnostic : mes vérifications étaient nombreuses
//! mais entraient toutes dans le logiciel au même endroit. Elles chargeaient
//! une page avec l'adresse que j'avais moi-même décidé qu'elle recevrait, si
//! bien qu'elles vérifiaient la page et jamais le câblage autour. Les deux
//! fautes étaient précisément dans ce câblage : une adresse fabriquée en Rust
//! et lue en TypeScript, et un fichier de permissions que le compilateur ne
//! lit pas.
//!
//! Ce module ne teste donc aucune fonction. Il tient les deux bouts de chaque
//! couture et vérifie qu'ils se rejoignent — en lisant les fichiers des deux
//! côtés, y compris ceux qui ne sont pas du Rust. Une couture qui se défait
//! ne se voit dans aucun des deux camps ; elle ne se voit qu'ici.

#![cfg(test)]

use std::collections::BTreeSet;
use std::path::{Path, PathBuf};

/// La racine du dépôt : `src-tauri/..`.
fn root() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("racine du projet")
        .to_path_buf()
}

fn read(path: &str) -> String {
    let file = root().join(path);
    std::fs::read_to_string(&file).unwrap_or_else(|_| panic!("{} est illisible", file.display()))
}

/// Tout le code des fenêtres, `ui/` compris — la page d'accueil en fait
/// partie, et c'est elle qui appelle `ping`.
fn pages() -> Vec<(String, String)> {
    fn walk(folder: &Path, found: &mut Vec<(String, String)>) {
        for entry in std::fs::read_dir(folder).expect("un dossier de l'interface") {
            let path = entry.expect("une entrée").path();
            if path.is_dir() {
                walk(&path, found);
            } else if path.extension().and_then(|e| e.to_str()) == Some("ts") {
                let name = path
                    .file_name()
                    .and_then(|n| n.to_str())
                    .expect("un nom")
                    .to_string();
                found.push((name, std::fs::read_to_string(&path).expect("lecture")));
            }
        }
    }
    let mut found = Vec::new();
    walk(&root().join("ui"), &mut found);
    assert!(found.len() > 10, "les pages n'ont pas été trouvées");
    found
}

/// **Toute fenêtre qui lit la base sait se relire.**
///
/// Le défaut du 05/08/2026, constaté par Fabrice sur « Soldes de vos comptes » :
/// *« le solde n'a effectivement pas bougé »*. On note un solde, on ferme la
/// fenêtre, on saisit une opération, on rouvre — et le chiffre est celui
/// d'avant. Rien ne clignote, rien n'est vide : le mauvais chiffre a exactement
/// l'air du bon.
///
/// La cause tient à ce qui fait par ailleurs la force de Radinus : **une
/// fenêtre est bâtie une fois et jamais détruite**. La porte la cache, la
/// rouvrir la remontre, et ce qu'elle affichait est encore là. Une fenêtre qui
/// n'a aucun moyen d'apprendre que la base a changé sous elle ment sans le
/// savoir.
///
/// Il y a trois façons d'apprendre, et ce test en exige **au moins une** :
///
/// - écouter `window-parameters:<label>`, l'événement que le contrôleur émet à
///   chaque réouverture — c'est ce que font les trente-deux fenêtres qui
///   reçoivent un paramètre ;
/// - écouter `data-changed:<...>`, diffusé quand les données bougent ;
/// - se relire au retour du focus, le filet de l'accueil posé le 26/07/2026
///   après que deux tentatives par événement avaient échoué.
///
/// Le troisième est le plus sûr des trois pour ce qui nous occupe : une fenêtre
/// qu'on remontre reprend le focus, toujours, sans que personne ait à penser à
/// lui envoyer quoi que ce soit.
///
/// **Ce test devient indispensable le jour où l'on pourra changer de base sans
/// quitter Radinus.** Aujourd'hui une fenêtre périmée montre des chiffres d'il
/// y a cinq minutes ; demain elle montrerait ceux d'une **autre base**, sous le
/// nom de celle qu'on vient d'ouvrir. C'est la faute qu'on ne rattrape pas,
/// parce qu'on ne la voit pas.
#[test]
fn toute_fenetre_qui_lit_la_base_sait_se_relire() {
    // Les commandes qui touchent la base ouverte. Une commande la touche quand
    // elle reçoit l'état de l'application **et** y demande la connexion : c'est
    // la seule porte, `AppState::database`, et il n'y en a pas d'autre.
    let source = read("src-tauri/src/commands.rs");
    let mut reading: BTreeSet<String> = BTreeSet::new();
    for piece in source.split("\npub fn ").skip(1) {
        let Some(name) = piece.split(['(', '<', ' ']).next() else {
            continue;
        };
        // La signature s'arrête à la première accolade ouvrante.
        let Some(brace) = piece.find(" {") else {
            continue;
        };
        let (signature, body) = piece.split_at(brace);
        // Le corps s'arrête à la prochaine accolade fermante en début de ligne.
        let body = body.split("\n}").next().unwrap_or(body);
        if signature.contains("AppState") && body.contains(".database()") {
            reading.insert(name.to_string());
        }
    }
    assert!(
        reading.len() > 50,
        "les commandes qui lisent la base n'ont pas été reconnues : {}",
        reading.len()
    );

    let mut muettes: Vec<String> = Vec::new();
    for (name, text) in pages() {
        // Les modules partagés ne sont pas des fenêtres : une fenêtre a une
        // page à son nom.
        let page = name.trim_end_matches(".ts");
        let has_page = root().join(format!("ui/windows/{page}.html")).is_file()
            || name == "main.ts";
        if !has_page {
            continue;
        }

        // Appelle-t-elle une commande qui lit la base ?
        let lit = reading
            .iter()
            .any(|command| text.contains(&format!("\"{command}\"")));
        if !lit {
            continue;
        }

        // A-t-elle un moyen d'apprendre que la base a changé ?
        let se_relit = text.contains("window-parameters")
            || text.contains("data-changed")
            || (text.contains("\"focus\"") && text.contains("reload"))
            || (text.contains("\"focus\"") && text.contains("dress"));
        if !se_relit {
            muettes.push(page.to_string());
        }
    }

    assert!(
        muettes.is_empty(),
        "ces fenêtres lisent la base et n'ont aucun moyen d'apprendre qu'elle a \
         changé — elles montreront des chiffres périmés sans le dire : {muettes:?}"
    );
}

/// **Toute colonne de date dit sur quoi elle se trie.**
///
/// Le défaut du 04/08/2026, relevé par Fabrice : *« lorsque je désire trier le
/// tableau par date, on dirait plutôt un tri par ordre alphabétique »*. Il
/// avait raison au mot près. Le contrôleur envoie la date déjà écrite —
/// « 15/01/2026 » — et le tableau, faute de clef, se rangeait sur ce texte : il
/// classait par quantième, puis par mois, puis par année.
///
/// Le remède tient en un mot : la ligne porte aussi la date en ISO, et la
/// colonne déclare `key`. En ISO, l'ordre des caractères **est** l'ordre du
/// temps.
///
/// **Le tableau ne peut pas se défendre seul.** Il compare ce qu'on lui donne ;
/// il n'a aucun moyen de savoir qu'une chaîne est une date. C'est donc à la
/// colonne de le dire, et à ce croisement de vérifier qu'elle l'a dit — sur
/// sept colonnes réparties dans cinq fenêtres, aucune ne le disait.
///
/// **Ce que ce test ne voit pas**, et il vaut mieux l'écrire que le croire
/// couvert : il reconnaît une colonne de date au nom du champ lu. Une date
/// rangée sous un nom qui ne contient pas « date » — `received_on`, par
/// exemple — lui échappe. Celle-là porte déjà sa clef, mais rien ici ne la
/// retient.
#[test]
fn toute_colonne_de_date_dit_sur_quoi_elle_se_trie() {
    let mut muettes: Vec<String> = Vec::new();
    let mut vues = 0;

    for (name, text) in pages() {
        // Chaque bloc `{ … }` qui contient `title: () =>` décrit une colonne.
        // Les colonnes n'en imbriquent pas d'autres : découper aux accolades
        // suffit, et évite d'avoir à analyser du TypeScript.
        for bloc in text.split('{') {
            let bloc = match bloc.find('}') {
                Some(fin) => &bloc[..fin],
                None => continue,
            };
            if !bloc.contains("title: () =>") {
                continue;
            }
            let Some(cellule) = bloc.split("cell:").nth(1) else {
                continue;
            };
            // `trim_start` AVANT de lire les caractères : ce qui suit la
            // flèche commence par une espace, et un `take_while` s'y arrêterait
            // aussitôt en ne rendant rien du tout.
            let lu: String = cellule
                .split("=>")
                .nth(1)
                .unwrap_or("")
                .trim_start()
                .chars()
                .take_while(|c| c.is_alphanumeric() || *c == '_' || *c == '.')
                .collect::<String>()
                .to_lowercase();
            if !lu.contains("date") {
                continue;
            }
            vues += 1;
            if !bloc.contains("key:") {
                muettes.push(format!("{name} : la colonne qui montre « {lu} »"));
            }
        }
    }

    assert!(
        vues >= 10,
        "le test ne reconnaît plus les colonnes de date : leur forme a changé, \
         et il ne surveille plus rien"
    );
    assert!(
        muettes.is_empty(),
        "ces colonnes montrent une date et ne disent pas sur quoi elles se \
         trient : le tableau se rangera sur le texte affiché, donc par \
         quantième — c'est le défaut du 04/08/2026 : {muettes:#?}"
    );
}

/// Toutes les chaînes littérales du code des fenêtres.
///
/// Plus large que les appels `invoke("…")`, et il le faut : le nom d'une
/// commande voyage parfois comme argument — `fillCombo("bank", "list_banks",
/// …)` — et un test qui ne regarderait que les appels directs déclarerait
/// morte une commande bien vivante.
fn every_literal() -> BTreeSet<String> {
    let mut said = BTreeSet::new();
    for (_, text) in pages() {
        let mut rest = text.as_str();
        while let Some(at) = rest.find('"') {
            rest = &rest[at + 1..];
            let Some(end) = rest.find('"') else { break };
            said.insert(rest[..end].to_string());
            rest = &rest[end + 1..];
        }
    }
    said
}

/// Ce qu'un appel `invoke("…")` nomme, dans tout le code des fenêtres.
///
/// Les appels au préfixe `plugin:` sont ceux de Tauri lui-même (fenêtres,
/// événements, sélecteur de fichier) : ils ne passent pas par nos commandes.
fn commands_invoked() -> BTreeSet<String> {
    let mut asked = BTreeSet::new();
    for (_, text) in pages() {
        let mut rest = text.as_str();
        while let Some(at) = rest.find("invoke") {
            rest = &rest[at + "invoke".len()..];
            // `invoke<T>("nom"` ou `invoke("nom"` : on saute jusqu'au premier
            // guillemet de la parenthèse.
            let Some(open) = rest.find('(') else { break };
            let after = &rest[open + 1..];
            let after = after.trim_start();
            let Some(quoted) = after.strip_prefix('"') else {
                continue;
            };
            let Some(end) = quoted.find('"') else { break };
            let name = &quoted[..end];
            if !name.starts_with("plugin:") && !name.is_empty() {
                asked.insert(name.to_string());
            }
        }
    }
    assert!(!asked.is_empty(), "aucune commande trouvée dans les fenêtres");
    asked
}

/// Les commandes que le contrôleur enregistre, lues dans `generate_handler!`.
fn commands_registered() -> BTreeSet<String> {
    let text = read("src-tauri/src/lib.rs");
    let list = text
        .split("generate_handler![")
        .nth(1)
        .and_then(|rest| rest.split(']').next())
        .expect("la liste des commandes");
    let registered: BTreeSet<String> = list
        .split(',')
        .filter_map(|entry| entry.trim().strip_prefix("commands::"))
        .map(|name| name.trim().to_string())
        .filter(|name| !name.is_empty())
        .collect();
    assert!(!registered.is_empty(), "aucune commande enregistrée");
    registered
}

/// **Appelant – appelé.** Toute commande qu'une fenêtre appelle doit exister
/// de l'autre côté du pont, et toute commande enregistrée doit servir à
/// quelqu'un.
///
/// Les deux moitiés sont écrites dans deux langages, dans deux dossiers, et
/// rien ne les relie qu'une chaîne de caractères. Renommer d'un côté et
/// oublier l'autre ne fait échouer aucun compilateur : la fenêtre part en
/// marche, et casse au premier clic sur ce bouton-là — peut-être des mois plus
/// tard, chez l'utilisateur.
#[test]
fn every_command_a_window_calls_is_a_command_rust_answers() {
    let asked = commands_invoked();
    let registered = commands_registered();

    let unanswered: Vec<&String> = asked.difference(&registered).collect();
    assert!(
        unanswered.is_empty(),
        "ces commandes sont appelées par une fenêtre et n'existent pas dans \
         generate_handler! : {unanswered:?}"
    );

    // L'autre bout, et il a servi tout de suite : cinq commandes offrent au
    // frontend un pouvoir dont il ne se sert pas. Trois ouvrent des fenêtres
    // que le menu ouvre lui-même, en Rust. Les deux autres disent et changent
    // la langue d'une base ouverte : le menu Paramètres le fait aussi en Rust.
    //
    // `available_languages` en est sortie le 02/08/2026, et c'est le test
    // lui-même qui l'a exigé : la fenêtre du choix de la langue, au premier
    // lancement, est venue l'appeler.
    //
    // Elles sont nommées ici plutôt que tues : le jour où une sixième
    // apparaît, ce test le dira.
    // `current_language` et `set_language` en sont sorties le 03/08/2026, et
    // c'est encore ce test qui l'a exigé : la fenêtre des préférences (F39)
    // est venue les appeler pour sa feuille « Langue ». Le menu Paramètres les
    // faisait déjà, en Rust ; elles ont maintenant deux appelants, et c'est
    // voulu — Fabrice a demandé que les deux chemins mènent au même réglage.
    const KNOWN_UNUSED: [&str; 3] = [
        "open_nomenclature_list",
        "open_accounts_list",
        "open_balances_window",
    ];
    let literals = every_literal();
    let unused: Vec<&String> = registered
        .iter()
        .filter(|name| !literals.contains(*name))
        .filter(|name| !KNOWN_UNUSED.contains(&name.as_str()))
        .collect();
    assert!(
        unused.is_empty(),
        "ces commandes sont enregistrées et personne ne les appelle : {unused:?}"
    );
    // Et l'inverse : une commande de la liste ci-dessus qui reviendrait à la
    // vie doit en sortir, sinon la liste devient un mensonge qui grossit.
    for name in KNOWN_UNUSED {
        assert!(
            !literals.contains(name),
            "« {name} » est de nouveau appelée : retire-la de KNOWN_UNUSED"
        );
    }
}

/// **Émetteur – récepteur.** Toute fenêtre à qui l'on peut renvoyer des
/// paramètres doit les écouter.
///
/// C'est la faute du 26/07/2026, retrouvée telle quelle : une fenêtre de
/// Radinus est bâtie une fois et jamais détruite, donc la redemander ne
/// recharge pas sa page — les nouveaux paramètres arrivent par un événement.
/// La statistique ne l'écoutait pas et gardait les comptes de sa toute
/// première ouverture : des chiffres justes, sur le mauvais compte, sans un
/// mot. Rust émettait dans le vide, et rien, nulle part, ne pouvait le dire.
///
/// Trois fenêtres n'écoutent rien, et c'est justifié : la fenêtre principale
/// n'est jamais redemandée, les soldes s'ouvrent toujours sans paramètre, et
/// le choix de la langue ne paraît qu'une fois dans la vie du logiciel.
///
/// Le sélecteur de base en faisait partie, et il en est sorti le 02/08/2026 :
/// il paraît au démarrage, se cache quand la base s'ouvre, et le menu le
/// remontre — sans rien relire, il gardait le mode de sa première ouverture et
/// laissait son bouton d'ouverture allumé là où il devait être grisé.
#[test]
fn every_window_that_can_be_handed_new_parameters_listens_for_them() {
    const NO_PARAMETERS: [&str; 3] = ["main", "balances", "language-choice"];

    for spec in crate::windows::tests::every_spec() {
        if NO_PARAMETERS.contains(&spec.label.as_str()) {
            continue;
        }

        // **Le motif doit venir de la page de cette fenêtre-là.** Les chercher
        // dans tout le dossier rendait le test creux : une seule page déclare
        // `window-parameters:${LABEL}`, ce qui vaut n'importe quelle étiquette
        // et couvrait donc toutes les fenêtres, y compris celles qui
        // n'écoutaient rien. Une couture se vérifie bout à bout, pas au
        // voisinage.
        let page = spec
            .url
            .split('?')
            .next()
            .and_then(|path| path.rsplit('/').next())
            .map(|file| file.replace(".html", ".ts"))
            .expect("une page");
        let text = read(&format!("ui/windows/{page}"));

        let declared = listened_labels(&text);
        assert!(
            declared.iter().any(|pattern| glob(pattern, &spec.label)),
            "la fenêtre « {} » peut être redemandée avec d'autres paramètres, et sa \
             page {page} n'écoute pas « window-parameters:{} » — elle gardera ceux de \
             sa première ouverture. Ce qu'elle écoute : {declared:?}",
            spec.label,
            spec.label
        );
    }
}

/// Les étiquettes qu'une page dit écouter. Une interpolation `${…}` devient
/// une étoile : ce qu'elle vaudra à l'exécution n'est pas lisible ici, mais la
/// forme de l'étiquette l'est.
///
/// Seules comptent les occurrences qui **ouvrent** une chaîne — guillemet ou
/// accent grave juste avant. Sans cela, la phrase d'un commentaire passerait
/// pour un écouteur, et le test dirait le contraire de la vérité.
fn listened_labels(text: &str) -> Vec<String> {
    let mut found = Vec::new();
    let needle = "window-parameters:";
    let bytes = text.as_bytes();
    let mut from = 0;
    while let Some(at) = text[from..].find(needle) {
        let at = from + at;
        from = at + needle.len();
        let opens_a_string = at > 0 && matches!(bytes[at - 1], b'"' | b'`' | b'\'');
        if !opens_a_string {
            continue;
        }
        let label: String = text[from..]
            .chars()
            .take_while(|c| !matches!(c, '"' | '`' | '\'' | '\n'))
            .collect();
        let mut normalised = String::new();
        let mut rest = label.as_str();
        while let Some(at) = rest.find("${") {
            normalised.push_str(&rest[..at]);
            normalised.push('*');
            rest = match rest[at..].find('}') {
                Some(end) => &rest[at + end + 1..],
                None => "",
            };
        }
        normalised.push_str(rest);
        if !normalised.is_empty() {
            found.push(normalised);
        }
    }
    found
}

/// Le motif de Tauri, et le nôtre : une étoile, où qu'elle soit.
fn glob(pattern: &str, label: &str) -> bool {
    match pattern.split_once('*') {
        None => pattern == label,
        Some((before, after)) => {
            label.len() >= before.len() + after.len()
                && label.starts_with(before)
                && label.ends_with(after)
        }
    }
}

/// **Émetteur – récepteur, dans l'autre sens.** Tout événement de données
/// qu'une fenêtre écoute doit être émis par quelqu'un.
///
/// Une fenêtre qui écoute un nom que personne n'émet ne se rafraîchira jamais,
/// et cela ne se voit pas : elle affiche simplement des chiffres d'hier.
#[test]
fn every_data_event_a_window_waits_for_is_one_rust_sends() {
    let mut awaited: BTreeSet<String> = BTreeSet::new();
    for (_, text) in pages() {
        let mut rest = text.as_str();
        while let Some(at) = rest.find("data-changed:") {
            rest = &rest[at + "data-changed:".len()..];
            let label: String = rest
                .chars()
                .take_while(|c| !matches!(c, '"' | '`' | '\'' | ' ' | '\n' | '$'))
                .collect();
            if !label.is_empty() {
                awaited.insert(label);
            }
        }
    }
    assert!(!awaited.is_empty(), "aucun événement de données écouté");

    // Rust ne nomme jamais ces événements en clair : il les fabrique avec
    // `changed_event(spec)`. L'ensemble de ce qu'il peut émettre est donc
    // exactement l'ensemble des étiquettes de fenêtre.
    let labels: BTreeSet<String> = crate::windows::tests::every_spec()
        .into_iter()
        .map(|spec| spec.label)
        .collect();

    for label in &awaited {
        assert!(
            labels.contains(label),
            "une fenêtre attend « data-changed:{label} », qui ne correspond à \
             aucune fenêtre que cette version sait ouvrir : elle ne se \
             rafraîchira jamais"
        );
    }
}

/// **Bâtisseur – bâti.** Toute page qu'une fenêtre demande doit être déclarée
/// au bundler, sinon elle n'est pas construite.
///
/// Trouvé le 26/07/2026 en ajoutant le tableau de bord : la fenêtre était
/// écrite, la commande enregistrée, la permission accordée — et la page
/// n'existait pas dans le paquet, parce que `vite.config.ts` ne la nommait
/// pas. Rien dans le code ne pouvait le dire : c'est un fichier de
/// configuration, dans un troisième langage encore.
#[test]
fn every_page_a_window_asks_for_is_one_the_bundler_builds() {
    let config = read("vite.config.ts");
    let declared = config
        .split("input: {")
        .nth(1)
        .and_then(|rest| rest.split('}').next())
        .expect("la liste des pages");

    for spec in crate::windows::tests::every_spec() {
        let page = spec.url.split('?').next().expect("une adresse");
        assert!(
            declared.contains(page),
            "la page « {page} », que la fenêtre « {} » demande, n'est pas déclarée \
             dans vite.config.ts : elle ne sera pas construite",
            spec.label
        );
    }
}

/// **Appelant – appelé, jusqu'à la forme de l'argument.**
///
/// Faute du 26/07/2026, et la plus humiliante de la série : le tableau de bord
/// s'ouvrait entièrement vide. Sa fenêtre envoyait ses **trois** interrupteurs
/// à une structure qui en réclamait **cinq**, et `serde` refusait l'appel avant
/// qu'il n'arrive — « invalid args `switches` : missing field `debits` ».
///
/// Le nom de la commande était juste, le nom de l'argument aussi ; c'est son
/// contenu qui ne l'était pas. Ni le compilateur Rust, ni TypeScript, ni mes
/// vérifications de fenêtre ne pouvaient le voir : mon faux pont répondait
/// quoi qu'on lui demande, alors que le vrai regarde ce qu'on lui envoie.
///
/// Ce test compare donc les deux formes. Il est délibérément **ciblé sur
/// `switches`** : c'est le seul objet composé qui traverse le pont, et c'est
/// celui qui a cassé. Une couture qui a lâché une fois mérite son propre fil.
#[test]
fn the_switches_a_window_sends_are_the_switches_rust_expects() {
    // Quelle fenêtre envoie ses interrupteurs à quelle structure.
    const SEAMS: [(&str, &str); 2] = [
        ("statistics.ts", "SwitchesInput"),
        ("dashboard.ts", "DashboardSwitchesInput"),
    ];

    let controller = read("src-tauri/src/commands.rs");

    for (page, structure) in SEAMS {
        // Ce que la fenêtre déclare : `const switches = { pointed: true, … }`.
        let text = read(&format!("ui/windows/{page}"));
        let start = text
            .find("const switches = {")
            .unwrap_or_else(|| panic!("{page} ne déclare pas d'interrupteurs"));
        let body = &text[start + "const switches = {".len()..];
        let body = &body[..body.find('}').expect("l'objet des interrupteurs")];
        let mut sent: Vec<String> = body
            .lines()
            .filter_map(|line| line.split(':').next())
            .map(|name| name.trim().to_string())
            .filter(|name| !name.is_empty() && !name.starts_with("//"))
            .collect();

        // Ce que Rust réclame : les champs de la structure.
        let at = controller
            .find(&format!("pub struct {structure} {{"))
            .unwrap_or_else(|| panic!("{structure} est introuvable"));
        let fields = &controller[at + format!("pub struct {structure} {{").len()..];
        let fields = &fields[..fields.find('}').expect("la structure")];
        let mut expected: Vec<String> = fields
            .lines()
            .filter_map(|line| line.trim().strip_prefix("pub "))
            .filter_map(|line| line.split(':').next())
            .map(|name| name.trim().to_string())
            .collect();

        sent.sort();
        expected.sort();
        assert_eq!(
            sent, expected,
            "{page} envoie {sent:?} et {structure} attend {expected:?} : \
             l'appel sera refusé par serde et la fenêtre restera vide"
        );
    }
}

/// **Appelant – appelé, sur les six caractéristiques de la classification
/// rapide.**
///
/// F05 nomme ses six caractéristiques **deux fois** : par la clef qu'elle
/// envoie à `quick_classification_set` (`payment-mode`), et par le champ
/// qu'elle remplit dans l'objet `change` de `quick_classification_apply`
/// (`payment_mode`). Rust les nomme deux fois aussi, à deux endroits
/// différents : `Characteristic::key` dans le noyau, et les champs de
/// `ChangeInput` dans le contrôleur.
///
/// Quatre listes, deux langages, trois fichiers, et rien qui les relie qu'une
/// chaîne de caractères. Un nom qui glisse d'une case à l'autre — le tiers
/// écrit dans le champ du projet — ne casse aucune compilation, n'alerte
/// personne, et classe tout de travers : à l'écran, un classement faux est
/// parfaitement plausible. Ce test tient les quatre bouts à la fois.
#[test]
fn les_six_caracteristiques_portent_les_memes_noms_des_deux_cotes() {
    let page = read("ui/windows/quick-classification.ts");
    let start = page
        .find("const CHARACTERISTICS = [")
        .expect("la fenêtre ne déclare pas ses caractéristiques");
    let body = &page[start..];
    let body = &body[..body.find("] as const;").expect("la liste des caractéristiques")];

    /// Les valeurs d'un champ `nom: "…"`, dans l'ordre de la déclaration.
    fn values_of(body: &str, field: &str) -> Vec<String> {
        let needle = format!("{field}: \"");
        let mut found = Vec::new();
        let mut rest = body;
        while let Some(at) = rest.find(&needle) {
            rest = &rest[at + needle.len()..];
            let end = rest.find('"').expect("une chaîne fermée");
            found.push(rest[..end].to_string());
            rest = &rest[end..];
        }
        found
    }

    let keys_sent = values_of(body, "key");
    let fields_sent = values_of(body, "field");

    // Ce que le noyau nomme.
    let keys_expected: Vec<String> = radinus_core::quick_classification::CHARACTERISTICS
        .iter()
        .map(|which| which.key().to_string())
        .collect();
    assert_eq!(
        keys_sent, keys_expected,
        "les clefs envoyées par F05 ne sont pas celles de Characteristic::key : \
         quick_classification_set refusera celles qu'il ne connaît pas"
    );

    // Et ce que le contrôleur réclame — les champs de la structure que serde
    // remplit. Un champ manquant ou mal nommé fait refuser l'appel entier,
    // exactement comme les interrupteurs du tableau de bord le 26/07/2026.
    let controller = read("src-tauri/src/commands.rs");
    let at = controller
        .find("pub struct ChangeInput {")
        .expect("ChangeInput est introuvable");
    let fields = &controller[at + "pub struct ChangeInput {".len()..];
    let fields = &fields[..fields.find('}').expect("la structure")];
    let mut expected: Vec<String> = fields
        .lines()
        .filter_map(|line| line.trim().strip_prefix("pub "))
        .filter_map(|line| line.split(':').next())
        .map(|name| name.trim().to_string())
        .collect();

    let mut sent = fields_sent.clone();
    sent.sort();
    expected.sort();
    assert_eq!(
        sent, expected,
        "F05 remplit {sent:?} et ChangeInput attend {expected:?} : \
         serde refusera l'appel et rien ne sera classé"
    );

    // Et le troisième bout, celui qu'on oublie : l'objet que la fenêtre
    // fabrique doit avoir **toutes** les cases, y compris celles que
    // l'utilisateur n'a pas cochées. Un champ absent n'est pas un `null` pour
    // serde, c'est un champ manquant.
    let built = page
        .find("const change: Record<string, number | null> = {")
        .expect("F05 ne fabrique pas d'objet de changement");
    let object = &page[built..];
    let object = &object[..object.find("};").expect("l'objet de changement")];
    for field in &expected {
        assert!(
            object.contains(&format!("{field}:")),
            "l'objet envoyé par F05 ne porte pas « {field} » : serde refusera l'appel"
        );
    }
}

/// **Bâtisseur – bâti, pour les images.** Toute image qu'une page demande doit
/// exister dans le dépôt.
///
/// Faute du 27/07/2026, et elle est bête : la fenêtre d'importation demandait
/// trois icônes que j'avais bien ajoutées **chez moi** et jamais livrées à
/// Fabrice. Chez lui, trois boutons sur quatre étaient vides — seule la porte
/// s'affichait, parce que son image existait depuis des semaines. Rien ne
/// pouvait le dire : un `<img>` dont la source manque ne fait pas d'erreur, il
/// ne dessine rien. Le compilateur ne lit pas le HTML, et le navigateur ne se
/// plaint pas.
///
/// Ce test lit les deux bouts : ce que les pages demandent, et ce que le
/// dossier contient.
#[test]
fn toute_image_demandee_par_une_fenetre_existe_dans_le_depot() {
    let root = root();
    let mut asked: BTreeSet<String> = BTreeSet::new();

    for entry in std::fs::read_dir(root.join("ui/windows")).expect("le dossier des fenêtres") {
        let path = entry.expect("une entrée").path();
        if path.extension().and_then(|e| e.to_str()) != Some("html") {
            continue;
        }
        let text = std::fs::read_to_string(&path).expect("lecture");
        let mut rest = text.as_str();
        while let Some(at) = rest.find("src=\"/ui/") {
            rest = &rest[at + "src=\"/".len()..];
            let end = rest.find('"').expect("une source fermée");
            asked.insert(rest[..end].to_string());
            rest = &rest[end..];
        }
    }
    assert!(!asked.is_empty(), "aucune image demandée : le test ne lit rien");

    for image in &asked {
        assert!(
            root.join(image).is_file(),
            "une fenêtre demande « {image} », qui n'existe pas dans le dépôt : \
             le bouton s'affichera vide, sans une erreur"
        );
    }
}

/// **Les cinq champs que la fiche chéquier fige sont les mêmes des deux
/// côtés.**
///
/// `GR_InterditModif` est un groupe chez Fabrice : un nom, et cinq champs
/// dedans. Ici il est deux choses — la liste `FROZEN` de la fenêtre, qui décide
/// ce qui se grise, et l'absence de ces champs dans `update_chequebook`, qui
/// décide ce qui peut être écrit. Les deux doivent dire la même chose : un
/// champ grisé mais accepté par la commande serait modifiable par tout ce qui
/// n'est pas la fenêtre, et un champ modifiable mais grisé serait une promesse
/// que l'écran ne tient pas.
#[test]
fn les_cinq_champs_geles_du_chequier_le_sont_des_deux_cotes() {
    let window = std::fs::read_to_string(root().join("ui/windows/chequebook-form.ts"))
        .expect("la fiche chéquier");
    let frozen_line = window
        .lines()
        .find(|line| line.contains("const FROZEN"))
        .expect("la liste FROZEN de la fenêtre");
    let frozen: Vec<&str> = frozen_line
        .split('"')
        .skip(1)
        .step_by(2)
        .collect();
    assert_eq!(
        frozen,
        vec!["reference", "received", "first", "last", "quantity"],
        "les cinq champs de GR_InterditModif ont changé dans la fenêtre"
    );

    // Et la commande d'écriture ne prend que ce qui reste : le compte et les
    // commentaires. Rien de ce qui est gelé n'a de chemin jusqu'à la base.
    let commands = std::fs::read_to_string(root().join("src-tauri/src/commands.rs")).expect("les commandes");
    let update = commands
        .split("pub fn update_chequebook(")
        .nth(1)
        .and_then(|rest| rest.split(')').next())
        .expect("la signature de update_chequebook");
    for field in &frozen {
        // « received » ne doit pas se confondre avec « received_on » d'une
        // autre commande : on lit la signature de celle-ci et d'elle seule.
        assert!(
            !update.contains(field),
            "update_chequebook accepte « {field} », que la fiche affiche pourtant \
             grisé : les chèques du carnet sont déjà créés, sa numérotation ne \
             doit plus avoir de chemin jusqu'à la base"
        );
    }
    assert!(update.contains("account_id") && update.contains("comments"));
}

/// **Le nombre de chèques se compte pareil des deux côtés.**
///
/// Le noyau le calcule (`cheques_between`) pour le confronter au plafond de
/// mille, et la fenêtre le calcule aussi pour remplir le champ que
/// l'utilisateur lit. Deux calculs pour un seul nombre : s'ils divergent, la
/// fiche annoncerait un carnet et le noyau en ferait un autre — et l'écart ne
/// se verrait qu'au moment où le plafond refuserait quelque chose que l'écran
/// disait permis.
///
/// Le croisement lit les deux formules et vérifie qu'elles disent la même
/// chose, y compris sur le cas qui les sépare : deux bornes à l'envers.
#[test]
fn le_nombre_de_cheques_se_compte_pareil_dans_le_noyau_et_dans_la_fenetre() {
    let window = std::fs::read_to_string(root().join("ui/windows/chequebook-form.ts"))
        .expect("la fiche chéquier");
    let formula = window
        .lines()
        .find(|line| line.contains("return last < first"))
        .expect("la formule de la fenêtre");
    assert!(
        formula.contains("? 0 :") && formula.contains("last - first + 1"),
        "la fenêtre ne compte plus comme le noyau : {formula}"
    );

    for (first, last, expected) in [
        (9_506_001_i64, 9_506_040_i64, 40_i64),
        (7, 7, 1),
        (40, 1, 0),
        (1, 1_000, 1_000),
    ] {
        assert_eq!(
            radinus_core::chequebooks::cheques_between(first, last),
            expected
        );
    }

    // Et le plafond que ce nombre sert à contrôler est bien celui de son
    // message : « Nombre de chèque maximum pour un chéquier : 1000 ».
    assert_eq!(radinus_core::chequebooks::MOST_CHEQUES, 1_000);
    let french = radinus_core::i18n::text(
        radinus_core::i18n::Language::French,
        "chequebook-refusal-too-many",
    );
    assert!(
        french.contains("1000"),
        "le message ne dit pas le plafond qu'il applique : {french}"
    );
    // Idem pour le plus grand numéro, annoncé dans son message.
    assert_eq!(radinus_core::chequebooks::LARGEST_NUMBER, 999_999_999);
    let french = radinus_core::i18n::text(
        radinus_core::i18n::Language::French,
        "chequebook-refusal-number-too-big",
    );
    assert!(
        french.contains("999 999 999"),
        "le message n'annonce pas la limite qu'il applique : {french}"
    );
}

/// **Les rubriques de l'import Excel sont exactement les siennes.**
///
/// La couture est ici : le noyau les propose à la combo, et il les cherche
/// ensuite par leur nom (`Localise_ColEntete`). Un libellé embelli d'un
/// accent — « Libellé » pour « Libelle » — s'afficherait très bien et ne
/// trouverait plus jamais sa colonne. Les neuf valeurs de son
/// `Import Excel Liste option association champ.txt` sont donc écrites ici en
/// toutes lettres, et le mode à deux colonnes n'y ajoute que les deux
/// rubriques que Fabrice a demandées le 29/07/2026.
#[test]
fn les_rubriques_de_l_import_excel_sont_celles_de_son_fichier() {
    use radinus_core::csv_excel_import::{fields, AmountShape};

    assert_eq!(
        fields(AmountShape::Single),
        vec![
            "[IGNORE]",
            "Date",
            "Date_Pointage",
            "Libelle",
            "Montant",
            "Categorie",
            "Affectation",
            "Mode_Paiement",
            "Commentaires",
        ]
    );
    assert_eq!(
        fields(AmountShape::DebitCredit),
        vec![
            "[IGNORE]",
            "Date",
            "Date_Pointage",
            "Libelle",
            "Montant_Debit",
            "Montant_Credit",
            "Categorie",
            "Affectation",
            "Mode_Paiement",
            "Commentaires",
        ]
    );

    // [IGNORE] est en tête des deux listes, donc c'est le défaut : une ligne de
    // concordance qu'on n'a pas réglée ne fait jamais entrer de données par
    // accident. La fenêtre le sait aussi, et sous le même nom.
    let window = read("ui/windows/excel-fields.ts");
    assert!(
        window.contains(r#"const IGNORE = "[IGNORE]""#),
        "la fenêtre n'écrit plus [IGNORE] comme le noyau"
    );
}

/// **Les quatre politiques portent les mêmes clefs des deux côtés.**
///
/// La fenêtre envoie une chaîne, le noyau la relit. Une clef renommée d'un
/// côté ne casse rien de visible : `Policy::from_key` retomberait sur « créer
/// automatiquement », et l'import créerait des catégories là où l'utilisateur
/// avait demandé de laisser vierge. Une faute qui écrit dans la base sans un
/// mot est exactement celle qu'un test croisé doit attraper.
#[test]
fn les_quatre_politiques_de_l_import_excel_portent_les_memes_clefs() {
    use radinus_core::csv_excel_import::Policy;

    let window = read("ui/windows/excel-fields.ts");
    let list = window
        .split("const POLICIES = [")
        .nth(1)
        .and_then(|rest| rest.split(']').next())
        .expect("la liste des politiques de la fenêtre");
    for policy in [Policy::Create, Policy::Ask, Policy::Blank, Policy::Default] {
        assert!(
            list.contains(&format!("\"{}\"", policy.key())),
            "la fenêtre ne connaît pas la politique « {} » : {list}",
            policy.key()
        );
        // Et la relecture rend bien ce que la clef annonce.
        assert_eq!(Policy::from_key(policy.key()), policy);
    }
    // Une clef inconnue ne doit pas ouvrir la porte à une écriture : elle
    // retombe sur la politique de sa capture, celle qui est cochée d'origine.
    assert_eq!(Policy::from_key("n'importe quoi"), Policy::Create);

    // La forme du montant voyage de la même façon, et les deux clefs sont
    // celles que la fenêtre écrit dans ses boutons radio.
    use radinus_core::csv_excel_import::AmountShape;
    let step_one = read("ui/windows/excel-import.ts");
    for shape in [AmountShape::Single, AmountShape::DebitCredit] {
        assert!(
            step_one.contains(&format!("\"{}\"", shape.key())),
            "l'étape 1 ne connaît pas la forme « {} »",
            shape.key()
        );
        assert_eq!(AmountShape::from_key(shape.key()), shape);
    }
}

/// **Rien, dans le contrôleur, ne lit la langue dans la base.**
///
/// Décision de Fabrice, 03/08/2026 : « on ne tient compte que de ce qui est
/// dans `settings/radinus_config.json`, pas ailleurs ». La colonne
/// `Parametres.UtiliseLangue` existe toujours, et Radinus la tient à jour pour
/// que les archives restent lisibles par la version Windows — mais **rien ne
/// la lit pour décider ce qui s'affiche**.
///
/// Le défaut qu'il a relevé était exactement là. La langue vivait à deux
/// endroits : le fichier de configuration décidait du démarrage, la base
/// décidait dès qu'on l'ouvrait, et les Préférences n'écrivaient que dans la
/// base. Radinus démarrait donc en anglais et basculait en français à
/// l'ouverture, à chaque lancement, pour toujours. Aucun test ne le voyait :
/// les deux lectures étaient justes chacune de son côté.
///
/// Le compilateur en garde déjà la moitié — `ui_language()` ne prend plus de
/// connexion, donc aucune commande ne *peut* lire la langue d'une base. Ce
/// test garde l'autre moitié : que personne ne rappelle `stored_language`
/// directement, ce qui rouvrirait la porte sans que rien ne proteste.
///
/// **Ce test en remplace un autre**, qui interdisait de demander la langue en
/// tenant déjà la connexion — `window_language` verrouillait alors le même
/// mutex que `state.database()`, et l'ordre inverse figeait le logiciel
/// (rencontré par Fabrice le 30/07/2026 sur l'association des données). Cet
/// interblocage n'existe plus : la langue ne touche plus la base, donc plus
/// aucun verrou. L'ancien test aurait désormais accusé un ordre devenu
/// parfaitement sain.
#[test]
fn le_controleur_ne_lit_jamais_la_langue_dans_la_base() {
    const FICHIERS: [&str; 6] = [
        "commands.rs",
        "menu.rs",
        "windows.rs",
        "texts.rs",
        "lib.rs",
        "database_operations.rs",
    ];
    let mut fautifs: Vec<String> = Vec::new();
    for fichier in FICHIERS {
        let source = read(&format!("src-tauri/src/{fichier}"));
        for (numero, ligne) in source.lines().enumerate() {
            let nue = ligne.trim_start();
            // Les commentaires ont le droit d'en parler : c'est même là que
            // la règle est expliquée.
            if nue.starts_with("//") {
                continue;
            }
            if ligne.contains("stored_language") {
                fautifs.push(format!("{fichier}:{}", numero + 1));
            }
        }
    }
    assert!(
        fautifs.is_empty(),
        "ces lignes lisent la langue dans la base, alors que seule \
         `settings/radinus_config.json` en décide : {fautifs:?}"
    );

    // Et la moitié tenue par le compilateur, dite ici pour qu'on sache qu'elle
    // est voulue : la fonction qui donne la langue ne prend aucun argument.
    let commandes = read("src-tauri/src/commands.rs");
    assert!(
        commandes.contains("fn ui_language() -> Language {"),
        "`ui_language` a repris un paramètre : si c'est une connexion, les \
         quatre-vingt-quinze commandes qui l'appellent peuvent de nouveau \
         lire la langue de la base"
    );
}

/// **Chaque format proposé par le menu écrit vraiment son format.**
///
/// La couture est un `else` : `sheets::write` choisit l'écrivain d'après
/// l'extension du fichier, et **tout ce qu'il ne reconnaît pas part en
/// `.xlsx`**. C'est un repli raisonnable pour un nom sans extension ; c'est un
/// piège pour un format ajouté au menu et oublié dans l'aiguillage. L'utilisateur
/// choisirait « TOML », obtiendrait un fichier nommé `.toml` contenant un
/// classeur Excel, et rien ne le lui dirait — ni au moment d'écrire, ni à
/// l'ouverture, où son éditeur afficherait du binaire.
///
/// Le test tient donc les deux bouts : la liste des sorties telle que la
/// **fenêtre** la propose, et ce que le **noyau** écrit réellement pour
/// chacune. Trois d'entre elles sont des archives — `.xlsx`, `.ods` et `.docx`
/// commencent tous par `PK` — et les autres doivent être du texte.
#[test]
fn chaque_format_du_menu_export_ecrit_vraiment_son_format() {
    use radinus_core::sheets::{Sheet, SheetCell};

    // Les extensions telles que la fenêtre les propose : on lit sa liste
    // plutôt que d'en tenir une copie ici, sinon les deux divergeraient.
    let window = read("ui/windows/export.ts");
    let list = window
        .split("export const FORMATS = [")
        .nth(1)
        .and_then(|rest| rest.split("] as const;").next())
        .expect("la liste des sorties de la fenêtre");
    let extensions: Vec<String> = list
        .split("extension: \"")
        .skip(1)
        .filter_map(|piece| piece.split('"').next().map(str::to_string))
        .collect();
    assert!(
        extensions.len() >= 10,
        "la liste des sorties a fondu : {extensions:?}"
    );

    let mut sheet = Sheet::new("Croisement");
    sheet.header_rows = 1;
    sheet.rows = vec![
        vec![SheetCell::text("Libelle"), SheetCell::text("Montant")],
        vec![SheetCell::text("Alimentation"), SheetCell::money(-619_000_000)],
    ];

    // Les trois formats de bureautique sont des archives ; les sept autres
    // sont du texte. Une sortie qui se trompe de camp est un repli silencieux.
    let archives = ["xlsx", "ods", "docx"];
    for extension in &extensions {
        let file = std::env::temp_dir().join(format!(
            "radinus-croisement-{}.{extension}",
            std::process::id()
        ));
        radinus_core::sheets::write(&sheet, &file)
            .unwrap_or_else(|error| panic!("{extension} : écriture impossible — {error}"));
        let bytes = std::fs::read(&file).expect("relecture");
        std::fs::remove_file(&file).ok();

        let is_archive = bytes.starts_with(b"PK");
        assert_eq!(
            is_archive,
            archives.contains(&extension.as_str()),
            "« {extension} » n'écrit pas ce qu'il annonce : le noyau est retombé \
             sur le format par défaut, et l'utilisateur recevrait un classeur \
             Excel déguisé"
        );

        // Et chaque sortie porte bien un mot du tableau : un fichier vide
        // passerait les deux vérifications précédentes.
        if !is_archive {
            let text = String::from_utf8_lossy(&bytes);
            assert!(
                text.contains("Alimentation"),
                "« {extension} » n'a pas écrit le contenu du tableau"
            );
        }
    }

    // Enfin, chaque sortie du menu a bien sa phrase, dans les deux langues :
    // une entrée sans texte serait une ligne vide dans le menu.
    let keys: Vec<String> = list
        .split("key: \"")
        .skip(1)
        .filter_map(|piece| piece.split('"').next().map(str::to_string))
        .collect();
    for key in keys.iter().chain(
        [
            "export-to-ofx".to_string(),
            "export-to-qif".to_string(),
        ]
        .iter(),
    ) {
        for language in [
            radinus_core::i18n::Language::French,
            radinus_core::i18n::Language::English,
        ] {
            assert!(
                !radinus_core::i18n::text(language, key).is_empty(),
                "{key} n'a pas de phrase en {language:?}"
            );
        }
    }
}

/// **Chaque clef que l'impression demande existe dans les deux dictionnaires.**
///
/// La couture est silencieuse, et c'est ce qui la rend dangereuse. Le noyau
/// compose un état en demandant ses intitulés à Fluent ; une clef absente ne
/// lève rien, elle **imprime son propre nom**. L'utilisateur enverrait alors à
/// son banquier un tableau dont une colonne s'appelle `print-total-debit`, et
/// aucun test de compilation, aucun test unitaire du module d'impression ne le
/// verrait passer : le PDF est bien formé, il dit seulement une bêtise.
///
/// Le test tient donc les deux bouts : les clefs telles que
/// `radinus-core/src/printing.rs` les écrit, et les deux fichiers `.ftl` tels
/// qu'ils sont livrés. En français **et** en anglais : un état imprimé dans une
/// base anglaise est un état comme un autre.
#[test]
fn chaque_intitule_de_l_impression_existe_dans_les_deux_langues() {
    let source = read("radinus-core/src/printing.rs");
    let french = read("radinus-core/i18n/fr.ftl");
    let english = read("radinus-core/i18n/en.ftl");

    // Les clefs sont demandées de deux façons dans le module : `label("…")`
    // pour les titres de colonnes, `i18n::text(language, "…")` pour le reste.
    let mut keys: Vec<String> = Vec::new();
    for opening in ["label(\"", "i18n::text(language, \""] {
        let mut rest = source.as_str();
        while let Some(start) = rest.find(opening) {
            let after = &rest[start + opening.len()..];
            match after.find('"') {
                Some(end) => {
                    keys.push(after[..end].to_string());
                    rest = &after[end..];
                }
                None => break,
            }
        }
    }
    // Les noms de mois sont demandés par un tableau de constantes, pas par un
    // appel : on les ajoute à la main pour que la couture soit complète.
    for month in [
        "month-january",
        "month-february",
        "month-march",
        "month-april",
        "month-may",
        "month-june",
        "month-july",
        "month-august",
        "month-september",
        "month-october",
        "month-november",
        "month-december",
    ] {
        keys.push(month.to_string());
    }
    keys.sort();
    keys.dedup();

    assert!(
        keys.len() > 15,
        "le test ne trouve plus les clefs de l'impression : la façon de les \
         demander a changé dans printing.rs, et le test ne surveille plus rien"
    );

    let declared = |dictionary: &str, key: &str| {
        dictionary
            .lines()
            .any(|line| line.starts_with(key) && line[key.len()..].trim_start().starts_with('='))
    };

    let missing: Vec<&String> = keys
        .iter()
        .filter(|key| !declared(&french, key) || !declared(&english, key))
        .collect();

    assert!(
        missing.is_empty(),
        "ces clefs sont demandées par l'impression mais manquent dans fr.ftl \
         ou dans en.ftl : elles s'imprimeraient telles quelles sur l'état : {missing:?}"
    );
}

/// **Une entrée de menu qui porte un identifiant doit être écoutée.**
///
/// La couture est cruelle parce qu'elle ne se voit pas : une entrée déclarée
/// avec `MenuItem::with_id` est **vivante à l'écran** — elle n'est pas grisée,
/// le curseur la surligne, elle se clique — et si personne ne compare son
/// identifiant dans le gestionnaire d'événements, le clic ne fait rien. Aucune
/// erreur, aucun message : l'utilisateur clique, et le logiciel reste immobile.
/// C'est exactement ce qui distingue une entrée oubliée d'une entrée
/// délibérément éteinte, laquelle passe par `inert` et se voit grise.
///
/// Le test tient les deux bouts dans le même fichier : les constantes
/// d'identifiants telles qu'elles sont déclarées, et le gestionnaire tel qu'il
/// les compare.
#[test]
fn chaque_entree_de_menu_qui_porte_un_identifiant_est_ecoutee() {
    let source = read("src-tauri/src/menu.rs");

    // Les constantes : `pub const NOM_ITEM_ID: &str = "…";`
    let mut names: Vec<String> = Vec::new();
    for line in source.lines() {
        let line = line.trim();
        if let Some(rest) = line.strip_prefix("pub const ") {
            if let Some((name, _)) = rest.split_once(':') {
                if name.ends_with("_ITEM_ID") {
                    names.push(name.to_string());
                }
            }
        }
    }
    assert!(
        names.len() > 10,
        "le test ne trouve plus les identifiants de menu : leur forme a changé \
         dans menu.rs, et le test ne surveille plus rien"
    );

    // Chacune doit apparaître ailleurs que dans sa propre déclaration : soit
    // dans un `event.id() == …`, soit dans l'un des tableaux que le
    // gestionnaire parcourt.
    let deaf: Vec<&String> = names
        .iter()
        .filter(|name| source.matches(name.as_str()).count() < 2)
        .collect();

    assert!(
        deaf.is_empty(),
        "ces entrées de menu portent un identifiant mais rien ne les écoute : \
         elles s'affichent vivantes et ne font rien quand on clique dessus : {deaf:?}"
    );
}

/// Les clefs qu'une fenêtre demande à son dictionnaire — tout `t("…")` et
/// tout `tError("…")` de l'interface, avec le nom du fichier qui les demande.
fn keys_asked() -> BTreeSet<(String, String)> {
    let mut asked = BTreeSet::new();
    for (name, text) in pages() {
        let bytes = text.as_bytes();
        let mut at = 0;
        while let Some(found) = text[at..].find("(\"") {
            let open = at + found;
            // Le nom de la fonction appelée, juste avant la parenthèse.
            let mut start = open;
            while start > 0
                && (bytes[start - 1].is_ascii_alphanumeric() || bytes[start - 1] == b'_')
            {
                start -= 1;
            }
            if matches!(&text[start..open], "t" | "tError") {
                let rest = &text[open + 2..];
                if let Some(end) = rest.find('"') {
                    asked.insert((name.clone(), rest[..end].to_string()));
                }
            }
            at = open + 2;
        }
    }
    assert!(
        asked.len() > 100,
        "le test ne trouve plus les clefs demandées par les fenêtres : leur \
         forme a changé, et le test ne surveille plus rien"
    );
    asked
}

/// **Demandeur – guichet.** Toute clef qu'une fenêtre demande doit être une
/// clef que le dictionnaire lui sert.
///
/// La faute du 02/08/2026, retrouvée telle quelle. Les quatre intitulés du
/// menu « Outils » étaient écrits dans les trois fichiers de langue, et la
/// fiche compte affichait pourtant « account-tools » sur son bouton : ils
/// n'étaient pas dans la liste de `texts.rs`. Une fenêtre ne va pas chercher
/// ses mots un par un — elle reçoit d'un coup un dictionnaire dressé à la
/// main, et `t()` rend la clef quand elle n'y est pas.
///
/// Rien ne relie les deux bouts : la clef est écrite dans un `.ftl`, recopiée
/// dans un tableau Rust, redemandée dans un fichier TypeScript. Aucun
/// compilateur ne lit les trois. La faute ne se voit qu'à l'écran, et
/// seulement sur l'écran où l'on pense à regarder.
///
/// Dans ce sens-là seulement : une clef servie que personne ne demande ne
/// coûte que quelques octets, tandis qu'une clef demandée que personne ne
/// sert s'affiche en toutes lettres sur un bouton.
#[test]
fn toute_clef_qu_une_fenetre_demande_est_une_clef_que_le_dictionnaire_sert() {
    use radinus_core::i18n::Language;

    // Le vocabulaire d'une fenêtre de nomenclature porte en plus les phrases
    // de sa table : il faut donc réunir ce que servent tous les guichets.
    let mut served: BTreeSet<String> = crate::texts::dictionary(Language::French, None)
        .into_keys()
        .collect();
    for kind in radinus_core::nomenclatures::ALL {
        served.extend(crate::texts::dictionary(Language::French, Some(kind)).into_keys());
    }

    let unserved: Vec<String> = keys_asked()
        .into_iter()
        .filter(|(_, key)| !served.contains(key))
        .map(|(page, key)| format!("{page} demande « {key} »"))
        .collect();

    assert!(
        unserved.is_empty(),
        "ces clefs ne sont dans aucun dictionnaire : la fenêtre affichera la \
         clef elle-même, en toutes lettres, sur son étiquette : {unserved:#?}"
    );
}
