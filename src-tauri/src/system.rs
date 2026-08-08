//! Ce que Radinus demande au système d'exploitation, et rien de plus.
//!
//! Une seule chose pour l'instant : **ouvrir un fichier avec l'application que
//! l'utilisateur a choisie pour ce type de fichier**. C'est le geste final de
//! l'impression — le noyau a fabriqué le PDF, il faut le mettre sous les yeux
//! de l'utilisateur, dans une visionneuse d'où il pourra l'imprimer.
//!
//! **Pourquoi ce fichier existe.** Tauri n'offre aucune porte d'impression :
//! le sujet est ouvert chez eux depuis 2023 et les trois cases Windows, macOS
//! et Linux sont encore décochées. Les portes natives existent — `ShowPrintUI`
//! sous WebView2, `WebKitPrintOperation` sous WebKitGTK, `NSPrintOperation`
//! sous WKWebView — mais elles sont trois, différentes, et la troisième est
//! dépréciée par Apple. Plutôt que trois implémentations à maintenir, Radinus
//! fabrique lui-même le PDF (`radinus_core::printing`) et se contente ici de
//! le confier au système. Ce fichier fait donc **six lignes utiles par
//! système**, et c'est tout ce que l'impression coûte en code non portable.
//!
//! Ce module vit dans le contrôleur et non dans le noyau : lancer un processus
//! est un geste de plate-forme, et le noyau ne connaît ni le disque ni le
//! système (voir `08_ARCHITECTURE.md` §2.1).

use std::path::Path;
use std::process::Command;
#[cfg(target_os = "windows")]
use std::os::windows::process::CommandExt;

/// **Une commande qui ne fait pas surgir de console noire.**
///
/// Tout processus console lancé depuis une application graphique de Windows
/// reçoit une fenêtre de console **visible**. Radinus en lance pour la devise,
/// pour la liste des imprimantes, pour imprimer, pour l'explorateur et pour la
/// calculatrice : autant de rectangles noirs qui clignotent devant
/// l'utilisateur sans rien lui apprendre (dossier de portage du 05/08/2026,
/// §4.4).
///
/// `0x0800_0000` est `CREATE_NO_WINDOW`. Il n'existe que sur Windows ; ailleurs
/// cette fonction rend une `Command` ordinaire, et **rien ne change sur macOS
/// ni sous Linux**.
///
/// Toutes les commandes du fichier passent par ici. C'est le seul moyen qu'un
/// oubli ne se paie pas d'une console de plus : il n'y a plus de `Command::new`
/// à oublier.
fn silent_command(program: &str) -> Command {
    #[allow(unused_mut)]
    let mut command = Command::new(program);
    #[cfg(target_os = "windows")]
    command.creation_flags(0x0800_0000);
    command
}

/// Ouvre `path` avec l'application par défaut du système.
///
/// Ne bloque pas : la commande est lancée et Radinus continue. L'utilisateur
/// verra sa visionneuse s'ouvrir pendant que la fenêtre reste vivante.
///
/// **Aucune dépendance nouvelle.** Les trois commandes utilisées sont
/// présentes d'origine sur leur système : `open` fait partie de macOS,
/// `cmd /C start` de Windows, `xdg-open` du paquet `xdg-utils` que toutes les
/// distributions de bureau installent. Le crate `tauri-plugin-opener` ferait
/// la même chose ; il n'apporterait rien de plus que ces trois lignes.
pub fn open_with_desktop(path: &Path) -> std::io::Result<()> {
    #[cfg(target_os = "macos")]
    let mut command = {
        let mut command = silent_command("open");
        command.arg(path);
        command
    };

    #[cfg(target_os = "windows")]
    let mut command = {
        // Le premier argument de `start` est le **titre de la fenêtre** ; sans
        // la chaîne vide, un chemin entre guillemets serait pris pour ce
        // titre et rien ne s'ouvrirait. C'est le piège classique de `start`.
        let mut command = silent_command("cmd");
        command.args(["/C", "start", ""]).arg(path);
        command
    };

    #[cfg(all(not(target_os = "macos"), not(target_os = "windows")))]
    let mut command = {
        let mut command = silent_command("xdg-open");
        command.arg(path);
        command
    };

    command.spawn().map(|_| ())
}

/// Ouvre une adresse web dans le navigateur par défaut.
///
/// Les trois mêmes commandes que pour un fichier — elles prennent une URL
/// aussi bien qu'un chemin. Séparée de `open_with_desktop` malgré tout : un
/// `Path` et une URL ne sont pas la même chose, et les confondre finirait par
/// faire passer un chemin pour une adresse.
pub fn open_link(url: &str) -> std::io::Result<()> {
    #[cfg(target_os = "macos")]
    let mut command = {
        let mut command = silent_command("open");
        command.arg(url);
        command
    };

    #[cfg(target_os = "windows")]
    let mut command = {
        let mut command = silent_command("cmd");
        command.args(["/C", "start", "", url]);
        command
    };

    #[cfg(all(not(target_os = "macos"), not(target_os = "windows")))]
    let mut command = {
        let mut command = silent_command("xdg-open");
        command.arg(url);
        command
    };

    command.spawn().map(|_| ())
}

/// Ouvre la calculatrice du système.
///
/// **Elle n'existe que sur deux systèmes, et c'est pourquoi cette fonction
/// n'est compilée que sur eux.** macOS a Calculator, Windows a `calc`. Linux
/// n'a rien de standard : selon le bureau installé c'est `gnome-calculator`,
/// `kcalc`, `galculator` ou rien du tout, et essayer une liste au hasard
/// revient à promettre quelque chose qu'on ne tient pas une fois sur deux.
///
/// Décision de Fabrice, 03/08/2026 : **l'entrée est masquée sous Linux** — pas
/// grisée, masquée. Une entrée grisée pose une question à laquelle rien ne
/// répond ; une entrée absente ne se remarque pas. Linux n'est de toute façon
/// pas la cible de la 2.0.0.
#[cfg(any(target_os = "macos", target_os = "windows"))]
pub fn open_calculator() -> std::io::Result<()> {
    #[cfg(target_os = "macos")]
    let mut command = {
        let mut command = silent_command("open");
        command.args(["-a", "Calculator"]);
        command
    };

    #[cfg(target_os = "windows")]
    let mut command = silent_command("calc");

    command.spawn().map(|_| ())
}

/// Une imprimante du système, telle que l'utilisateur la voit.
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub struct Printer {
    /// Le nom de la file d'impression, celui qu'on donne à `lp -d`. Sous CUPS
    /// il est souvent écrit avec des soulignés : « Brother_HL_2030 ».
    pub name: String,
    /// Le nom lisible, celui que la fenêtre montre. CUPS le range dans la
    /// description de la file ; à défaut, c'est le nom de la file.
    pub label: String,
    /// Celle que le système enverrait par défaut. Le choix s'ouvre dessus.
    pub is_default: bool,
}

/// La sortie d'une commande, ou rien si elle n'existe pas sur ce système.
/// Runs a PowerShell script and reads its output as UTF-8.
///
/// **PowerShell does not write UTF-8 into a pipe by default.** It uses the
/// console's code page — CP850 in France — where a good many characters simply
/// do not exist. The `€` sign is one of them, and PowerShell replaces it with a
/// literal `?` *before* Rust sees anything: there is nothing left to decode.
/// Fabrice found it on Windows on 05/08/2026, on « devise système ».
///
/// Setting `[Console]::OutputEncoding` first makes it emit real UTF-8, which
/// also brings back the accents in printer names.
#[cfg(target_os = "windows")]
fn powershell(script: &str) -> Option<String> {
    output_of(
        "powershell",
        &[
            "-NoProfile",
            "-NonInteractive",
            "-Command",
            &format!("[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; {script}"),
        ],
    )
}

fn output_of(program: &str, args: &[&str]) -> Option<String> {
    let output = silent_command(program).args(args).output().ok()?;
    if output.status.success() {
        Some(String::from_utf8_lossy(&output.stdout).into_owned())
    } else {
        None
    }
}

/// Les imprimantes installées, la première étant celle par défaut si elle est
/// connue.
///
/// **Pourquoi Radinus les liste lui-même.** Fabrice a demandé le 01/08/2026 à
/// pouvoir choisir son imprimante plutôt que de partir sur celle par défaut.
/// Le dialogue d'impression du système n'est atteignable depuis aucun des
/// trois webviews — c'est tout le sujet de la phase 15 — et il n'existe aucune
/// commande, sur aucun des trois systèmes, qui ouvre ce dialogue pour un
/// fichier PDF. Radinus pose donc lui-même la question, avec ses propres
/// couleurs, à partir de ce que le système sait dire de ses imprimantes.
///
/// Une liste vide n'est pas une faute : c'est un poste sans imprimante, ou un
/// `lpstat` absent. L'appelant le dit et propose le PDF.
pub fn printers() -> Vec<Printer> {
    #[cfg(target_os = "windows")]
    {
        let names = powershell("Get-Printer | ForEach-Object { $_.Name }").unwrap_or_default();
        let default =
            powershell("(Get-CimInstance Win32_Printer -Filter 'Default = True').Name")
                .unwrap_or_default();
        let default = default.trim().to_string();
        return names
            .lines()
            .map(str::trim)
            .filter(|line| !line.is_empty())
            .map(|name| Printer {
                is_default: name == default,
                label: name.to_string(),
                name: name.to_string(),
            })
            .collect();
    }

    #[cfg(not(target_os = "windows"))]
    {
        // **On ne lit pas la prose de `lpstat`.** Sur macOS comme sous Linux,
        // ses phrases sont traduites dans la langue du poste : « printer X is
        // idle » devient « imprimante X est inactive ». Un analyseur qui
        // cherche le mot « printer » ne trouve rien sur une machine française
        // et conclut à tort qu'il n'y a aucune imprimante (anomalie signalée
        // par Fabrice, 01/08/2026).
        //
        // `lpstat -e` ne dit que les noms, un par ligne, sans une phrase :
        // c'est la seule sortie de CUPS qui ne dépend pas de la langue.
        let mut names: Vec<String> = output_of("lpstat", &["-e"])
            .unwrap_or_default()
            .lines()
            .map(str::trim)
            .filter(|line| !line.is_empty())
            .map(str::to_string)
            .collect();

        // Repli pour un CUPS trop ancien pour `-e` : dans `lpstat -p`, le nom
        // est le **deuxième** mot de chaque ligne non indentée — le premier
        // est le mot traduit, et c'est justement lui qu'on refuse de lire.
        if names.is_empty() {
            for line in output_of("lpstat", &["-p"]).unwrap_or_default().lines() {
                if line.starts_with(char::is_whitespace) {
                    continue;
                }
                if let Some(name) = line.split_whitespace().nth(1) {
                    names.push(name.to_string());
                }
            }
        }

        // `lpstat -d` porte une phrase, mais toutes ses traductions gardent
        // les deux-points : ce qui suit est le nom. Sans destination par
        // défaut, la phrase n'en a pas, et il n'y a rien à prendre.
        let default = output_of("lpstat", &["-d"])
            .unwrap_or_default()
            .split_once(':')
            .and_then(|(_, rest)| rest.split_whitespace().next().map(str::to_string))
            .unwrap_or_default();

        let mut found: Vec<Printer> = names
            .into_iter()
            .map(|name| Printer {
                is_default: name == default,
                // À défaut de mieux, le nom de la file rendu lisible : CUPS
                // remplace les espaces par des soulignés en la créant.
                label: name.replace('_', " "),
                name,
            })
            .collect();

        // Enrichissement facultatif : la description de chaque file, quand
        // `lpstat -l -p` la donne. Si le format ne se laisse pas lire, on
        // garde le nom rendu lisible — on ne perd jamais l'imprimante.
        let detailed = output_of("lpstat", &["-l", "-p"]).unwrap_or_default();
        let mut current: Option<usize> = None;
        for line in detailed.lines() {
            if !line.starts_with(char::is_whitespace) {
                current = line
                    .split_whitespace()
                    .find_map(|word| found.iter().position(|printer| printer.name == word));
                continue;
            }
            let trimmed = line.trim();
            // « Description: » en anglais, « Description : » en français : le
            // mot est le même, seule la ponctuation bouge.
            if let (Some(index), Some((head, rest))) = (current, trimmed.split_once(':')) {
                if head.trim().eq_ignore_ascii_case("description") {
                    let description = rest.trim();
                    if !description.is_empty() {
                        found[index].label = description.to_string();
                    }
                }
            }
        }
        found
    }
}

/// Envoie `path` à l'imprimante nommée, ou à celle par défaut si aucune n'est
/// nommée.
///
/// **C'est le bouton imprimante de F32**, celui qui imprime pour de bon, par
/// opposition à l'icône PDF qui ouvre le document. Fabrice a demandé les deux
/// gestes séparés le 01/08/2026 : « imprimante : pour imprimer sur imprimante,
/// icône rouge pdf : pour imprimer en PDF ».
///
/// **Les trois systèmes ne se valent pas ici, et il faut le dire.** macOS et
/// Linux portent CUPS d'origine : `lp` envoie le PDF à l'imprimante par défaut
/// et rend la main. Windows n'a pas d'équivalent en ligne de commande ; on y
/// passe par le **verbe `print` du shell**, qui confie le fichier à
/// l'application associée aux PDF en lui demandant d'imprimer. Cela marche si
/// cette application déclare ce verbe — Adobe Reader le fait, l'Edge livré
/// avec Windows aussi — et cela échoue proprement sinon, auquel cas la fenêtre
/// le dit et l'utilisateur reste libre de passer par le bouton PDF.
///
/// Ni `lp` ni les verbes du shell n'ouvrent de dialogue : c'est Radinus qui a
/// posé la question avant d'arriver ici (voir `printers`).
pub fn send_to_printer(path: &Path, printer: Option<&str>) -> std::io::Result<()> {
    #[cfg(target_os = "windows")]
    {
        // Deux verbes, et le choix de l'imprimante décide lequel : `Print`
        // envoie au défaut, `PrintTo` prend le nom en argument.
        let quoted = |text: &str| text.replace('\'', "''");
        let command = match printer {
            Some(name) => format!(
                "Start-Process -FilePath '{}' -Verb PrintTo -ArgumentList '\"{}\"'",
                quoted(&path.display().to_string()),
                quoted(name)
            ),
            None => format!(
                "Start-Process -FilePath '{}' -Verb Print",
                quoted(&path.display().to_string())
            ),
        };
        let status = silent_command("powershell")
            .args(["-NoProfile", "-NonInteractive", "-Command", &command])
            .status()?;
        if status.success() {
            Ok(())
        } else {
            Err(std::io::Error::other(
                "le verbe « print » de Windows a refuse le fichier",
            ))
        }
    }

    #[cfg(not(target_os = "windows"))]
    {
        let mut command = silent_command("lp");
        if let Some(name) = printer {
            command.args(["-d", name]);
        }
        let status = command.arg(path).status()?;
        if status.success() {
            Ok(())
        } else {
            Err(std::io::Error::other("lp a refuse le fichier"))
        }
    }
}

/// Le signe monétaire du système d'exploitation, ou une chaîne vide s'il ne
/// dit rien.
///
/// **Décision de Fabrice, 03/08/2026** : la devise affichée peut être celle de
/// la machine, relue à chaque fois, sans réglage ni mémorisation. Il lui a été
/// dit que la devise de la machine n'est pas celle de l'argent qui est dans la
/// base — un français dont le Mac est réglé sur le Canada verrait ses euros
/// étiquetés `$`, chaque chiffre juste et l'étiquette fausse. Il a tranché :
/// c'est de l'affichage. C'est son logiciel.
///
/// **Aucune dépendance nouvelle**, comme pour les imprimantes : on demande au
/// système ce qu'il sait dire, avec les commandes qu'il porte d'origine.
///
/// ⚠ **Une limite qu'il faut connaître** : sous macOS, une application lancée
/// depuis le Finder hérite souvent d'un environnement sans `LANG`, et `locale`
/// répond alors la locale « C », qui n'a pas de devise. Radinus retombe dans ce
/// cas sur l'euro. Lancé depuis un terminal — donc pendant tout le
/// développement — il répondra correctement. Ce n'est pas un défaut de ce code,
/// c'est ce que coûte le fait de ne rien mémoriser.
pub fn currency_sign() -> String {
    // **Demandé une fois, gardé pour la session** (dossier de portage du
    // 05/08/2026, §4.3).
    //
    // `Currency::System` est la valeur par défaut des préférences, si bien que
    // l'ouverture de **chaque** base appelait cette fonction — donc, sous
    // Windows, lançait PowerShell et l'attendait sur le fil principal. Un
    // démarrage à froid de PowerShell coûte une à deux secondes : c'était la
    // première cause de lenteur à l'ouverture d'une base, devant tout le reste.
    //
    // Le cache sert les trois systèmes : macOS et Linux lancent `locale`, moins
    // cher mais pas gratuit, et le résultat ne change pas d'une seconde à
    // l'autre.
    //
    // *Ce que ça coûte* : un réglage régional changé pendant que Radinus tourne
    // n'est vu qu'au lancement suivant. C'est le bon échange — personne ne
    // change de devise système en cours de saisie.
    static SIGN: std::sync::OnceLock<String> = std::sync::OnceLock::new();
    SIGN.get_or_init(ask_the_system_for_its_currency_sign).clone()
}

/// Ce que `currency_sign` demande au système, une seule fois par session.
fn ask_the_system_for_its_currency_sign() -> String {
    #[cfg(target_os = "windows")]
    {
        // **The symbol comes back as numbers, not as text**, and that is the
        // whole point (Fabrice, Windows, 05/08/2026 — « il me marque ? au lieu
        // de l'euro »).
        //
        // Asking PowerShell for the symbol itself means asking it to write a
        // character into a pipe, and it writes with the console code page. CP850
        // has no `€`, so PowerShell substitutes a literal `?` before Rust reads
        // anything — no decoding can undo that.
        //
        // Asking for the character *numbers* means asking it to write digits and
        // commas. No code page can mangle those, on any Windows, in any country,
        // whatever PowerShell version is installed. Radinus rebuilds the symbol
        // from them. `[Console]::OutputEncoding` alone would probably do, but it
        // depends on the PowerShell version and this cannot be tested from here.
        //
        // Currency symbols all live in the basic plane, so one number is one
        // character; anything outside it is skipped rather than guessed.
        let numbers =
            powershell("[int[]][char[]]((Get-Culture).NumberFormat.CurrencySymbol) -join ','")
                .unwrap_or_default();
        return numbers
            .trim()
            .split(',')
            .filter_map(|number| number.trim().parse::<u32>().ok())
            .filter_map(char::from_u32)
            .collect::<String>()
            .trim()
            .to_string();
    }

    #[cfg(not(target_os = "windows"))]
    {
        // `locale -k LC_MONETARY` rend des lignes `clef=valeur`, les textes
        // entre guillemets : `currency_symbol="€"`, `int_curr_symbol="EUR "`.
        // C'est la seule sortie qui donne le signe sans passer par une table
        // de correspondance.
        let described = output_of("locale", &["-k", "LC_MONETARY"]).unwrap_or_default();
        let value_of = |key: &str| -> String {
            described
                .lines()
                .find_map(|line| line.strip_prefix(key)?.strip_prefix('='))
                .unwrap_or_default()
                .trim()
                .trim_matches('"')
                .trim()
                .to_string()
        };

        let symbol = value_of("currency_symbol");
        if !symbol.is_empty() {
            return symbol;
        }

        // Repli : le code ISO, que la même sortie porte. Une poignée de codes
        // ont un signe que tout le monde reconnaît ; pour les autres, le code
        // lui-même est ce qu'il y a de plus honnête — « 1 234,56 SEK » se lit,
        // et n'invente rien.
        let code = value_of("int_curr_symbol");
        let code = code.trim();
        match code {
            "EUR" => "€".to_string(),
            "USD" | "CAD" | "AUD" => "$".to_string(),
            "GBP" => "£".to_string(),
            "JPY" | "CNY" => "¥".to_string(),
            "XOF" | "XAF" => "FCFA".to_string(),
            other => other.to_string(),
        }
    }
}

/// Envoie `path` à la corbeille du système.
///
/// **Pas `remove_file`.** L'original efface ses fichiers avec
/// `frVersCorbeille` partout où il efface, et Fabrice l'a redemandé pour les
/// pièces jointes le 01/08/2026 : une pièce supprimée par erreur se récupère
/// d'un clic droit dans la Corbeille, alors qu'un `remove_file` est sans
/// retour. La bibliothèque `trash` parle aux trois corbeilles, qui n'ont rien
/// en commun — la Corbeille de macOS, celle de Windows, et le dossier
/// normalisé de freedesktop sous Linux.
///
/// Un fichier déjà absent n'est pas une faute : la ligne a peut-être été
/// effacée deux fois, ou le fichier perdu par ailleurs. Ce qui compte est
/// qu'il ne soit plus là.
pub fn move_to_trash(path: &Path) -> std::io::Result<()> {
    if !path.exists() {
        return Ok(());
    }
    trash::delete(path).map_err(std::io::Error::other)
}

/// Un nom de fichier acceptable sur les trois systèmes.
///
/// Windows refuse `\ / : * ? " < > |`, macOS n'aime pas les deux-points, et
/// personne n'aime les espaces de fin. Les accents passent partout et sont
/// conservés : « Récapitulatif » reste lisible.
pub fn safe_file_name(name: &str) -> String {
    let cleaned: String = name
        .chars()
        .map(|c| match c {
            '\\' | '/' | ':' | '*' | '?' | '"' | '<' | '>' | '|' => '-',
            c if c.is_control() => ' ',
            c => c,
        })
        .collect();
    let trimmed = cleaned.trim().trim_matches('.').trim();
    if trimmed.is_empty() {
        "radinus".to_string()
    } else {
        trimmed.to_string()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn les_caracteres_interdits_de_windows_disparaissent() {
        assert_eq!(safe_file_name("a/b:c*d?e"), "a-b-c-d-e");
    }

    #[test]
    fn les_accents_restent() {
        assert_eq!(safe_file_name("Récapitulatif par catégorie"), "Récapitulatif par catégorie");
    }

    #[test]
    fn un_nom_vide_reste_utilisable() {
        assert_eq!(safe_file_name("   "), "radinus");
        assert_eq!(safe_file_name("..."), "radinus");
    }
}
