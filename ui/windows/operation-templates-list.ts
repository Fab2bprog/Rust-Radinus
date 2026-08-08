// F37 — « Liste des modeles d'operations ».
//
// Le gabarit des listes de nomenclature, une colonne LIBELLE, et **deux
// usages** : gérer ses modèles, ou en choisir un pour la fiche opération.
//
// **Choisir n'écrit rien.** Le modèle choisi part vers la fiche opération, qui
// le met à l'écran ; c'est la validation de cette fiche qui écrira (règle de
// Fabrice, 29/07/2026).

import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { askYesNo } from "./dialog";
import { closeCurrentWindow } from "./window-frame";
import { Table } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

interface Row {
  id: number;
  label: string;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

/// « SEL » : on vient chercher un modèle pour une fiche opération.
let selecting = false;

const table = new Table<Row>({
  container: element<HTMLDivElement>("rows"),
  columns: [{ title: () => t("ui-column-label"), cell: (row) => row.label }],
  identity: (row) => row.id,
  exportAs: () => ({ name: t("window-operation-templates-title"), detail: "" }),
  emptyText: () => t("operation-templates-none"),
  filteredOutText: () => t("operation-templates-nothing-to-show"),
  onSelectionChange: () => say(t("ui-multiselect-help")),
  onActivate: () => void (selecting ? choose() : openForm("M")),
});

function requireSelection(): boolean {
  if (table.selected().length === 0) {
    say(t("ui-select-record"), true);
    return false;
  }
  return true;
}

async function reload(): Promise<void> {
  try {
    table.setRows(await invoke<Row[]>("list_operation_templates"));
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

/// La base a-t-elle pu s'ouvrir ? Sans elle il n'y a aucun modèle à montrer, ni
/// à gérer, ni à choisir.
async function checkStartup(): Promise<boolean> {
  const failure = await invoke<string | null>("startup_error");
  if (failure) {
    say(failure, true);
    for (const id of ["create", "update", "delete", "read", "select"]) {
      element<HTMLButtonElement>(id).disabled = true;
    }
    return false;
  }
  return true;
}

async function openForm(mode: "A" | "M" | "L"): Promise<void> {
  if (mode !== "A" && !requireSelection()) {
    return;
  }
  try {
    await invoke("open_operation_template_form", {
      mode,
      id: mode === "A" ? null : table.selected()[0],
    });
  } catch (error) {
    say(tError("ui-open-failed", error), true);
  }
}

/// Le modèle choisi : il part vers la fiche opération, et la fenêtre se
/// referme. Rien n'est écrit en base.
async function choose(): Promise<void> {
  if (!requireSelection()) {
    return;
  }
  try {
    if (!(await invoke<boolean>("apply_operation_template", { id: table.selected()[0] }))) {
      say(t("operation-template-gone"), true);
    }
  } catch (error) {
    say(tError("ui-open-failed", error), true);
  }
}

async function deleteSelection(): Promise<void> {
  if (!requireSelection()) {
    return;
  }
  try {
    // Rien ne dépend d'un modèle : la question est simple, elle ne prévient
    // d'aucune conséquence en cascade, parce qu'il n'y en a pas.
    if (!(await askYesNo(t("operation-templates-delete-question"), t("ui-yes"), t("ui-no")))) {
      say(t("ui-deletion-abandoned"));
      return;
    }
    const deleted = await invoke<number>("delete_operation_templates", {
      ids: table.selected(),
    });
    table.clearSelection();
    await reload();
    say(await invoke<string>("operation_templates_deleted_text", { count: deleted }));
  } catch (error) {
    say(tError("ui-delete-failed", error), true);
  }
}

element<HTMLButtonElement>("create").addEventListener("click", () => void openForm("A"));
element<HTMLButtonElement>("update").addEventListener("click", () => void openForm("M"));
element<HTMLButtonElement>("read").addEventListener("click", () => void openForm("L"));
element<HTMLButtonElement>("delete").addEventListener("click", () => void deleteSelection());
element<HTMLButtonElement>("select").addEventListener("click", () => void choose());
/// **La porte se ferme elle-même.** Passer par Rust pour cacher la fenêtre qui
/// clique ajoutait une étiquette à faire correspondre, donc une occasion de se
/// tromper — et c'est ce qui est arrivé (anomalie signalée par Fabrice,
/// 29/07/2026 : la liste ne se fermait pas). La fenêtre qui sait qu'elle part
/// est celle qui part ; Rust n'est appelé que pour la fiche qu'elle emmène
/// avec elle, et si cet appel échoue la porte fonctionne quand même.
element<HTMLButtonElement>("close").addEventListener("click", () => {
  if (!selecting) {
    void invoke("close_operation_template_window", {
      label: "operation-template-form",
    }).catch(() => undefined);
  }
  closeCurrentWindow();
});

/// **Le mode ne se perd jamais.** Une fenêtre est bâtie une fois et jamais
/// détruite : redemandée, elle reçoit ses nouveaux paramètres par un
/// événement, et cet événement-là ne porte pas le `mode=SEL` qui était dans
/// l'adresse de départ. Le relire bêtement rebasculait la fenêtre en gestion à
/// la deuxième ouverture — on y trouvait Ajouter, Modifier, Supprimer au lieu
/// du bouton de validation (anomalie signalée par Fabrice, 29/07/2026).
///
/// Le mode appartient à l'étiquette de la fenêtre, qui ne change pas de sa
/// vie : une fois « choisir », toujours « choisir ».
function readParameters(query: string): void {
  selecting = selecting || new URLSearchParams(query).get("mode") === "SEL";
}

/// `IHM_ModeListe` : ce que le mode laisse voir.
function applyMode(): void {
  for (const id of ["create", "update", "delete", "read"]) {
    element<HTMLButtonElement>(id).hidden = selecting;
  }
  element<HTMLButtonElement>("select").hidden = !selecting;
  const question = element<HTMLElement>("question");
  question.hidden = !selecting;
  question.textContent = selecting ? t("operation-templates-select-question") : "";
  table.clearSelection();
}

for (const name of ["data-changed:operation-templates", "data-changed:operation-templates-select"]) {
  void listen(name, () => void reload());
}
for (const name of [
  "window-parameters:operation-templates",
  "window-parameters:operation-templates-select",
]) {
  void listen<string>(name, (event) => {
    readParameters(event.payload);
    applyMode();
    void reload();
  });
}

/// Pose les mots de la fenêtre, à l'ouverture et à chaque changement de
/// langue — une fenêtre est bâtie une fois et jamais détruite, elle ne peut que
/// se rhabiller.
///
/// Elle finit par relire les modèles : leur libellé est de l'utilisateur, mais
/// ce que le tableau dit autour — l'absence, l'aide, l'export — vient du noyau,
/// et une liste rhabillée qui garderait ses anciennes lignes serait à moitié
/// traduite.
async function dress(): Promise<void> {
  table.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));
  // Le clic droit exporte, dans toutes les listes : c'est le tableau partagé
  // qui le porte, et il ne se rebranche pas quand on le rappelle.
  table.exportOnRightClick(say);
  for (const [id, key] of [
    ["select", "ui-title-select"],
    ["create", "ui-title-create"],
    ["update", "ui-title-update"],
    ["delete", "ui-title-delete"],
    ["read", "ui-title-read"],
    ["close", "ui-title-close"],
  ] as const) {
    element<HTMLElement>(id).title = t(key);
  }
  // **La question se redit, le mode ne bouge pas.** Passer par `applyMode`
  // referait le partage des boutons et effacerait la sélection : perdre le
  // modèle que l'on venait de choisir parce qu'on a changé de langue serait
  // une surprise. Ici on ne fait que réécrire la question du mode en vigueur.
  const question = element<HTMLElement>("question");
  question.textContent = selecting ? t("operation-templates-select-question") : "";
  say(t("ui-multiselect-help"));

  if (await checkStartup()) {
    await reload();
  }
}

void (async () => {
  await loadTexts(null);
  // Le mode d'abord : c'est lui qui décide de la question que les mots posent.
  readParameters(window.location.search);
  applyMode();
  await dress();
  onLanguageChanged(dress, { key: "window-operation-templates-title" });
})();
