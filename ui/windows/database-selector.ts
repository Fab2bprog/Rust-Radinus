// Le sélecteur de base (décision de Fabrice, 02/08/2026).
//
// Il montre **ce que `databases/` contient vraiment** : est une base tout
// dossier qui contient un `radinus.sqlite`, quel que soit son nom.
// L'utilisateur a le droit de renommer, copier et effacer ses dossiers hors du
// logiciel — « il faut un système de pensée tolérant » —, si bien qu'une liste
// mémorisée mentirait tôt ou tard. On relit le disque à chaque ouverture.
//
// **Ajouter et ouvrir sont deux gestes séparés** (Fabrice, 02/08/2026). Le nom
// et le commentaire sont toujours à l'écran, sous le tableau ; l'icône d'ajout
// crée la base d'un seul clic et elle paraît dans le tableau au-dessus. Ma
// première version cachait la liste, montrait un formulaire et changeait
// l'icône d'ajout en icône d'enregistrement : deux gestes et deux visages pour
// une seule intention.
//
// **Elle a deux modes, et c'est la même fenêtre** (Fabrice, 02/08/2026) :
//
// * **au démarrage**, elle paraît d'elle-même, aucune base n'est ouverte : on
//   en choisit une et on s'en sert ;
// * **en cours d'utilisation**, appelée par le menu Fichier, elle ne sait plus
//   ouvrir. On consulte, on crée, on supprime ; le bouton d'ouverture est
//   grisé et un double-clic dit qu'il faut quitter le logiciel.
//
// Le second mode n'est pas une restriction inventée : une fenêtre de Radinus
// est bâtie une fois et jamais détruite, et rebrancher une base sous des
// fenêtres qui montrent déjà l'ancienne ferait écrire les opérations d'une
// base dans une autre, sans un mot.

import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askForPassword, askForWord, tell } from "./dialog";
import { Table } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

interface DatabaseDto {
  folder: string;
  path: string;
  label: string;
  comment: string;
  created_on: string;
  created_by: string;
  schema_version: number;
  current: boolean;
}

/// Ce que la table manipule : la base, plus son rang. Le rang sert
/// d'identité — une base n'a pas de numéro, et son chemin est une chaîne.
interface Row extends DatabaseDto {
  index: number;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");
const openButton = element<HTMLButtonElement>("open");
const createButton = element<HTMLButtonElement>("create");
const deleteButton = element<HTMLButtonElement>("delete");

let rows: Row[] = [];
/// **Dans lequel de ses deux modes cette fenêtre est-elle ?** (Fabrice,
/// 02/08/2026.) Au démarrage, aucune base n'est ouverte : on en choisit une et
/// on s'en sert. En cours d'utilisation, une base tourne déjà et celle-ci ne
/// sait plus ouvrir — elle consulte, elle crée, elle supprime, et pour changer
/// de base il faut quitter.
let alreadyRunning = false;

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

const table = new Table<Row>({
  container: element<HTMLDivElement>("rows"),
  columns: [
    { title: () => t("databases-column-label"), cell: (row) => row.label, width: "1.4fr" },
    { title: () => t("databases-column-comment"), cell: (row) => row.comment, width: "2fr" },
    { title: () => t("databases-column-folder"), cell: (row) => row.folder, width: "1fr" },
    { title: () => t("databases-column-created"), cell: (row) => row.created_on, width: "0.8fr" },
  ],
  identity: (row) => row.index,
  // La base du prochain démarrage se voit sans qu'on ait à la lire.
  rowClass: (row) => (row.current ? "list__row--current" : null),
  emptyText: () => t("databases-none"),
  filteredOutText: () => t("ui-no-match"),
  onActivate: (row) => void open(row),
});

async function reload(): Promise<void> {
  try {
    const found = await invoke<DatabaseDto[]>("list_databases");
    rows = found.map((entry, index) => ({ ...entry, index }));
    table.setRows(rows);

    // La base du prochain démarrage se voit à sa ligne, en gras : la barre
    // d'information ne la nomme pas. Une fenêtre de Radinus ne compose jamais
    // une phrase à partir de morceaux — le français demanderait un genre,
    // l'anglais non, et la fenêtre finirait par connaître les deux.
    say(rows.length === 0 ? t("databases-none") : t("databases-help"));
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// Ouvre une base : Rust l'inscrit en configuration et démarre dessus.
///
/// **En cours d'utilisation, elle n'ouvre plus rien** : elle le dit, et elle
/// dit quoi faire. Une fenêtre de Radinus est bâtie une fois et jamais
/// détruite ; rien ne saurait lui faire oublier la base qu'elle montre, et
/// rebrancher une autre base sous elle ferait écrire les opérations d'une base
/// dans une autre, sans un mot.
async function open(row: Row): Promise<void> {
  if (alreadyRunning) {
    await tell(t("database-quit-first"), t("ui-ok"));
    return;
  }
  const password = await unlocked(row);
  if (password === false) {
    return;
  }
  try {
    await invoke("open_database", { path: row.path, password });
  } catch (error) {
    say(String(error), true);
  }
}

/// **Le mot de passe d'une base, s'il en faut un** (Fabrice, 05/08/2026).
///
/// La règle est « il essaie, et demande si ça résiste » : rien n'est noté
/// nulle part sur les bases protégées, on demande au fichier lui-même. Une
/// base en clair ne fait donc rien apparaître du tout, ce qui est le cas de
/// toutes celles d'aujourd'hui.
///
/// Rend `null` quand aucune clé n'est nécessaire, le mot de passe tapé quand
/// il en faut un, et `false` quand l'utilisateur renonce — trois réponses
/// différentes, parce que « pas de mot de passe » et « je ne veux pas »
/// n'ont rien à voir.
async function unlocked(row: Row): Promise<string | null | false> {
  let locked = false;
  try {
    locked = await invoke<boolean>("database_needs_password", { path: row.path });
  } catch (error) {
    say(tError("ui-read-failed", error), true);
    return false;
  }
  if (!locked) {
    return null;
  }
  const typed = await askForPassword(t("password-ask"), t("ui-ok"), t("ui-cancel"));
  return typed === null ? false : typed;
}

/// Le menu **Paramètres** (Fabrice, 04/08/2026). Deux entrées, qui n'ont besoin
/// d'aucune base — c'est ce qui les met ici plutôt qu'ailleurs.
///
/// **La langue**, « au cas où l'utilisateur change d'avis ou s'est trompé » :
/// c'est la fenêtre du tout premier lancement, reprise telle quelle. Elle
/// n'écrit que la langue et rouvre le sélecteur derrière elle.
///
/// **Les préférences**, où seule la partie qui appartient au logiciel est
/// atteignable : la langue et la taille de l'affichage. La devise est une
/// préférence de la base, et F39 grise sa feuille — c'est elle qui le décide,
/// en demandant si une base est ouverte, non ce menu-ci en lui passant un mot.
function settingsMenu(entry: HTMLElement): HTMLElement {
  const holder = document.createElement("div");
  holder.className = "window-menu__holder";
  const choices = document.createElement("div");
  choices.className = "window-menu__choices";
  choices.dataset.menu = "settings";
  choices.hidden = true;

  for (const [label, command] of [
    [t("preferences-leaf-language"), "open_language_choice"],
    [t("menu-settings-preferences"), "open_preferences"],
  ] as const) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "window-menu__choice window-menu__choice--plain";
    button.textContent = label;
    button.addEventListener("click", () => {
      choices.hidden = true;
      void invoke(command).catch((error) => say(tError("ui-open-failed", error), true));
    });
    choices.append(button);
  }

  entry.addEventListener("click", (event) => {
    event.stopPropagation();
    choices.hidden = !choices.hidden;
  });
  document.addEventListener("click", () => {
    choices.hidden = true;
  });

  holder.append(entry, choices);
  return holder;
}

/// La ligne choisie dans la liste, ou `null` quand rien n'est choisi.
function chosen(): Row | null {
  const selected = table.selected();
  return rows.find((candidate) => candidate.index === selected[0]) ?? null;
}

/// **Le menu Outils.** Les quatre opérations techniques, venues du menu général
/// le 04/08/2026, et qui visent désormais la ligne sélectionnée.
///
/// Trois d'entre elles ont une cible et la réclament : sans ligne choisie,
/// elles refusent en le disant plutôt que d'agir sur une base au hasard. **Le
/// journal, lui, n'en a pas** — c'est le compte rendu du dernier traitement,
/// gardé en mémoire, et il n'appartient à aucune base. Il ne demande donc rien
/// et s'ouvre toujours.
function toolsMenu(entry: HTMLElement): HTMLElement {
  const holder = document.createElement("div");
  holder.className = "window-menu__holder";
  const choices = document.createElement("div");
  choices.className = "window-menu__choices";
  choices.dataset.menu = "tools";
  choices.hidden = true;

  const entries: [string, string | null][] = [
    [t("menu-file-backup"), "backup_database"],
    [t("menu-file-restore"), "restore_database"],
    [t("menu-file-repair"), "repair_database"],
    [t("menu-file-log"), null],
  ];
  for (const [label, command] of entries) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "window-menu__choice window-menu__choice--plain";
    button.textContent = label;
    button.addEventListener("click", () => {
      choices.hidden = true;
      if (command === null) {
        void invoke("open_operations_journal").catch((error) =>
          say(tError("ui-open-failed", error), true),
        );
        return;
      }
      const row = chosen();
      if (!row) {
        say(t("databases-select"), true);
        return;
      }
      // La base visée n'est pas forcément celle qui est ouverte : si elle est
      // protégée, l'opération a besoin de sa clé pour la lire.
      void (async () => {
        const password = await unlocked(row);
        if (password === false) {
          return;
        }
        try {
          await invoke(command, { path: row.path, password });
        } catch (error) {
          say(tError("ui-open-failed", error), true);
        }
      })();
    });
    choices.append(button);
  }

  entry.addEventListener("click", (event) => {
    event.stopPropagation();
    choices.hidden = !choices.hidden;
  });
  document.addEventListener("click", () => {
    choices.hidden = true;
  });

  holder.append(entry, choices);
  return holder;
}

openButton.addEventListener("click", () => {
  const row = chosen();
  if (!row) {
    say(t("databases-select"), true);
    return;
  }
  void open(row);
});

/// Supprimer une base : son dossier part à la corbeille du système, et il
/// faut écrire le « oui » de la langue courante pour que ça arrive — la
/// double barrière de Radinus, celle du compte bancaire et celle des
/// nomenclatures.
async function remove(row: Row): Promise<void> {
  try {
    const prompt = await invoke<{ question: string; word: string }>(
      "database_delete_question",
      { path: row.path },
    );
    const confirmed = await askForWord(prompt.question, prompt.word, t("ui-yes"), t("ui-no"));
    if (!confirmed) {
      say(t("ui-deletion-abandoned"));
      return;
    }
    const report = await invoke<string>("delete_database", { path: row.path });
    await reload();
    say(report);
  } catch (error) {
    say(String(error), true);
  }
}

// **Le bouton vert n'ajoute plus, il ouvre** (Fabrice, 04/08/2026). Les deux
// champs qui étaient sous le tableau ont leur fenêtre, avec sa validation — et
// la devise en plus, qu'on ne pouvait pas régler avant d'ouvrir la base.
createButton.addEventListener("click", () => {
  void invoke("open_database_form").catch((error) =>
    say(tError("ui-open-failed", error), true),
  );
});

// La fiche vient de créer une base et s'est effacée : on relit, et l'on écrit
// son compte rendu ici, où il ne se perdra pas avec elle.
void listen<string>("data-changed:database-selector", (event) => {
  void (async () => {
    await reload();
    if (event.payload) {
      say(event.payload);
    }
  })();
});

deleteButton.addEventListener("click", () => {
  const row = chosen();
  if (!row) {
    say(t("databases-select"), true);
    return;
  }
  void remove(row);
});

// La porte : elle quitte l'application quand aucune base n'est ouverte —
// c'est le démarrage, et il n'y a rien derrière cette fenêtre —, et elle se
// contente de cacher la fenêtre quand on est venu par le menu Fichier.
element<HTMLButtonElement>("close").addEventListener("click", () => {
  void invoke("leave_database_selector");
});

/// **Redemandée par le menu alors qu'elle est déjà là.**
///
/// Une fenêtre de Radinus est bâtie une fois et jamais détruite : celle-ci a
/// paru au démarrage, elle s'est cachée quand la base s'est ouverte, et le
/// menu la remontre — la même fenêtre, avec le même script, qui n'a rien
/// réexécuté depuis. C'est ce qui a laissé le bouton d'ouverture allumé dans
/// le second mode alors que Fabrice l'avait demandé grisé (02/08/2026).
///
/// Elle se relit donc entière à chaque fois : son mode, et sa liste — une base
/// a pu naître ou partir à la corbeille entre-temps.
void listen("window-parameters:database-selector", () => void dress());

/// **Le clic droit sur une ligne : la protection de cette base-là** (Fabrice,
/// 05/08/2026).
///
/// Le clic droit choisit la ligne au passage — c'est ce que fait tout le monde,
/// et sans cela il faudrait cliquer deux fois pour un seul geste. Une seule
/// entrée pour l'instant ; le menu est écrit pour en accepter d'autres, mais il
/// n'en invente aucune.
///
/// **Branché une seule fois**, comme l'export du tableau partagé : la fenêtre
/// se rhabille à chaque changement de langue, et deux branchements ouvriraient
/// deux menus l'un sur l'autre. Les mots, eux, sont pris au moment du clic —
/// le menu suit donc la langue sans se rebrancher.
let rightClickBound = false;
function protectOnRightClick(): void {
  if (rightClickBound) {
    return;
  }
  rightClickBound = true;

  let menu: HTMLElement | null = null;
  const close = (): void => {
    menu?.remove();
    menu = null;
  };

  element<HTMLDivElement>("rows").addEventListener("contextmenu", (event) => {
    event.preventDefault();
    close();

    // La ligne sous le curseur devient la ligne choisie. Sans cela, le menu
    // agirait sur une autre base que celle qu'on vise du doigt.
    const line = (event.target as HTMLElement | null)?.closest<HTMLElement>(".list__row");
    if (line) {
      line.click();
    }
    const row = chosen();
    if (!row) {
      return;
    }

    menu = document.createElement("div");
    menu.className = "context-menu";
    menu.style.left = `${event.clientX}px`;
    menu.style.top = `${event.clientY}px`;

    const entry = document.createElement("button");
    entry.type = "button";
    entry.className = "context-menu__entry";
    entry.textContent = t("password-protect");
    entry.addEventListener("click", () => {
      close();
      void invoke("open_password_form", { path: row.path, label: row.label }).catch((error) =>
        say(tError("ui-open-failed", error), true),
      );
    });

    menu.append(entry);
    document.body.append(menu);
  });

  document.addEventListener("click", close);
  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
      close();
    }
  });
}

/// Pose les mots de la fenêtre. Appelée à l'ouverture, à chaque retour par le
/// menu, et à chaque changement de langue.
async function dress(): Promise<void> {
  alreadyRunning = await invoke<boolean>("database_is_open");
  // Grisé plutôt que caché : un bandeau qui change de forme selon le mode se
  // cherche, et l'utilisateur doit voir que ce geste existe ailleurs.
  openButton.disabled = alreadyRunning;

  table.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));
  protectOnRightClick();
  openButton.title = t("databases-title-open");
  createButton.title = t("ui-title-create");
  deleteButton.title = t("databases-title-delete");
  element<HTMLElement>("close").title = t("ui-title-close");

  // La barre de menus se refait en entier à chaque habillage : ses entrées ne
  // sont que des mots. La vider d'abord, sans quoi la fenêtre en écrirait une
  // seconde à côté de la première en changeant de langue.
  const menu = element<HTMLElement>("window-menu");
  menu.replaceChildren();
  const tools = document.createElement("button");
  tools.type = "button";
  tools.className = "window-menu__entry";
  tools.textContent = t("databases-tools");
  menu.append(toolsMenu(tools));

  const settings = document.createElement("button");
  settings.type = "button";
  settings.className = "window-menu__entry";
  settings.textContent = t("menu-settings");
  menu.append(settingsMenu(settings));

  await reload();
}

// **Rien ne doit pouvoir arriver ici en silence** (02/08/2026).
//
// Cette fenêtre s'est présentée vide à Fabrice, sans un mot, et il a fallu
// trois échanges pour seulement savoir laquelle des deux était en cause. Une
// fenêtre de Radinus qui ne peut pas dire pourquoi elle est vide est la pire
// des pannes : on ne sait même pas qu'il s'en est produit une. Ce qui casse
// s'écrit désormais dans la barre d'information, en rouge, sur la fenêtre
// elle-même — sans qu'il faille ouvrir la console du navigateur.
window.addEventListener("error", (event) => {
  say(`${event.message} — ${event.filename}:${event.lineno}`, true);
});
window.addEventListener("unhandledrejection", (event) => {
  say(String(event.reason), true);
});

void (async () => {
  let complaint: string | null = null;
  try {
    await loadTexts(null);
  } catch (error) {
    // Le dictionnaire n'est pas venu. La fenêtre s'habille quand même : `t()`
    // rend alors la clef, visiblement fausse à l'écran plutôt que muette, ce
    // qui est la règle de Radinus depuis le premier jour.
    complaint = String(error);
  }
  try {
    await dress();
  } catch (error) {
    complaint = complaint ?? String(error);
  }
  if (complaint !== null) {
    say(complaint, true);
  }
  onLanguageChanged(dress, { key: "window-database-selector-title" });
})();
