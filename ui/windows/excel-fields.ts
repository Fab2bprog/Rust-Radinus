// F35 — l'étape 2/3 : l'association des champs, et les politiques.
//
// Deux onglets, comme l'original. Le premier met en face de chaque colonne de
// la feuille la rubrique de Radinus qu'elle alimente ; le second dit quoi faire
// des valeurs de nomenclature que Radinus ne connaît pas.
//
// **Les politiques ne s'appliquent pas ligne par ligne.** C'est ce que le code
// de Fabrice apprend : avant d'écrire quoi que ce soit, il balaie la colonne et
// construit un dictionnaire « libellé Excel → identifiant Radinus ». C'est pour
// cela que « créer automatiquement » ne crée pas trois fois la même catégorie,
// et que « demander » ouvre **une** fenêtre plutôt qu'une par ligne.
//
// Un troisième onglet apparaît après l'import : le compte-rendu. Son code
// sautait les lignes fautives en silence ; sur vingt mille lignes, une perte
// muette est inacceptable, et Fabrice a tranché pour le compte-rendu.

import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { tell } from "./dialog";
import { Table } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

interface Item {
  id: number;
  label: string;
}

interface LinkRow {
  index: number;
  header: string;
  field: string;
}

interface Links {
  headers: string[];
  fields: string[];
  links: { header: string; field: string }[];
}

interface Rule {
  kind: string;
  policy: string;
  default_id: number;
  linked: boolean;
  answered: boolean;
  group: string;
  labels: string[];
  unlinked_note: string;
}

interface Refused {
  row: number;
  content: string;
  reason: string;
}

interface Report {
  imported: number;
  created: number;
  refused: Refused[];
  said: string;
}

const IGNORE = "[IGNORE]";
/// L'ordre des quatre boutons radio, celui de sa capture.
const POLICIES = ["create", "ask", "blank", "default"] as const;

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

let headerChoices: string[] = [];
let fieldChoices: string[] = [];
let rows: LinkRow[] = [];

/// La table de concordance. **Les deux colonnes se règlent**, comme chez lui :
/// l'en-tête Excel à gauche, la rubrique Radinus à droite, et les deux
/// acceptent [IGNORE].
const links = new Table<LinkRow>({
  container: element<HTMLDivElement>("links-rows"),
  columns: [
    {
      title: () => t("excel-column-excel"),
      cell: (row) => row.header,
      width: "1fr",
      editor: {
        options: () => headerChoices.map((label, id) => ({ id, label })),
        value: (row) => Math.max(0, headerChoices.indexOf(row.header)),
        change: (row, value) => {
          row.header = headerChoices[value] ?? IGNORE;
          void store();
        },
      },
    },
    {
      title: () => t("excel-column-radinus"),
      cell: (row) => row.field,
      width: "1fr",
      editor: {
        options: () => fieldChoices.map((label, id) => ({ id, label })),
        value: (row) => Math.max(0, fieldChoices.indexOf(row.field)),
        change: (row, value) => {
          row.field = fieldChoices[value] ?? IGNORE;
          void store();
        },
      },
    },
  ],
  identity: (row) => row.index,
  emptyText: () => t("excel-empty-capture"),
  filteredOutText: () => t("ui-no-match"),
});

/// Le compte-rendu des lignes qui ne sont pas entrées.
const report = new Table<Refused>({
  container: element<HTMLDivElement>("report-rows"),
  virtualized: true,
  rowHeight: 22,
  columns: [
    {
      title: () => t("excel-column-row"),
      cell: (row) => String(row.row),
      key: (row) => row.row,
      numeric: true,
      width: "120px",
    },
    { title: () => t("excel-column-content"), cell: (row) => row.content, width: "2fr" },
    { title: () => t("excel-column-reason"), cell: (row) => row.reason, width: "1fr" },
  ],
  identity: (row) => row.row,
  emptyText: () => t("excel-nothing-refused"),
  filteredOutText: () => t("ui-no-match"),
  exportAs: () => ({ name: t("excel-report-title"), detail: t("excel-report-title") }),
});

/// Envoie la concordance à Rust après chaque changement. C'est Rust qui la
/// détient : une copie dans la fenêtre serait une seconde vérité.
async function store(): Promise<void> {
  try {
    await invoke<string | null>("excel_set_links", {
      links: rows.map((row) => ({ header: row.header, field: row.field })),
    });
    links.setRows(rows);
    await showPolicies();
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

function showTab(name: "links" | "settings" | "report"): void {
  for (const page of ["links", "settings", "report"] as const) {
    element<HTMLElement>(`page-${page}`).hidden = page !== name;
    element<HTMLElement>(`tab-${page}`).setAttribute(
      "aria-pressed",
      String(page === name),
    );
  }
}

/// Le second onglet, rebâti à chaque fois : un groupe ne s'allume que si la
/// rubrique correspondante est réglée dans le premier onglet — son code le dit
/// lui-même, `SI nNumCol < 1 ALORS RETOUR`, et une politique sur une colonne
/// absente ne veut rien dire.
async function showPolicies(): Promise<void> {
  const rules = await invoke<Rule[]>("excel_policies");
  const container = element<HTMLElement>("policies");
  container.replaceChildren();
  for (const rule of rules) {
    const group = document.createElement("fieldset");
    group.className = "excel-group";
    group.disabled = !rule.linked;
    const legend = document.createElement("legend");
    legend.textContent = rule.group;
    group.append(legend);

    POLICIES.forEach((policy, index) => {
      const line = document.createElement("div");
      line.className = "excel-choice__line";

      const label = document.createElement("label");
      label.className = "excel-choice__text";
      const radio = document.createElement("input");
      radio.type = "radio";
      radio.name = `policy-${rule.kind}`;
      radio.value = policy;
      radio.checked = rule.policy === policy;
      label.append(radio, document.createTextNode(` ${rule.labels[index] ?? policy}`));
      line.append(label);

      // « Demander » a son bouton, « par défaut » a sa combo : les deux autres
      // n'ont besoin de rien.
      if (policy === "ask") {
        const button = document.createElement("button");
        button.type = "button";
        button.className = "csv-test excel-destination";
        button.textContent = t("excel-define-destination");
        button.hidden = rule.policy !== "ask";
        button.addEventListener("click", () => void openAssociation(rule.kind));
        line.append(button);
      }
      if (policy === "default") {
        const combo = document.createElement("select");
        combo.className = "excel-settings__field excel-settings__field--wide";
        combo.hidden = rule.policy !== "default";
        void fillDefaults(combo, rule);
        combo.addEventListener("change", () => {
          void setPolicy(rule.kind, "default", Number(combo.value) || 0);
        });
        line.append(combo);
      }

      radio.addEventListener("change", () => {
        if (radio.checked) {
          void setPolicy(rule.kind, policy, rule.default_id);
        }
      });
      group.append(line);
    });

    if (!rule.linked) {
      const note = document.createElement("p");
      note.className = "excel-note";
      note.textContent = rule.unlinked_note;
      group.append(note);
    }
    container.append(group);
  }
}

async function fillDefaults(combo: HTMLSelectElement, rule: Rule): Promise<void> {
  try {
    const items = await invoke<Item[]>("list_elements", { kind: rule.kind });
    combo.replaceChildren();
    const blank = document.createElement("option");
    blank.value = "0";
    blank.textContent = "";
    combo.append(blank);
    for (const item of items) {
      const entry = document.createElement("option");
      entry.value = String(item.id);
      entry.textContent = item.label;
      combo.append(entry);
    }
    combo.value = String(rule.default_id);
  } catch (error) {
    say(tError("ui-read-failed", error), true);
  }
}

async function setPolicy(kind: string, policy: string, defaultId: number): Promise<void> {
  try {
    await invoke("excel_set_policy", { kind, policy, defaultId });
    await showPolicies();
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

async function openAssociation(kind: string): Promise<void> {
  try {
    await invoke("open_excel_association", { kind });
  } catch (error) {
    say(tError("ui-open-failed", error), true);
  }
}

/// L'étape 3/3 : l'intégration. Tout ou rien, et le compte-rendu ensuite.
async function run(): Promise<void> {
  try {
    const refusal = await invoke<string | null>("excel_run_refusal");
    if (refusal) {
      say(refusal, true);
      return;
    }
    const outcome = await invoke<Report>("excel_run");
    // **Le bouton disparaît, et il disparaît avant le panneau.** Une migration
    // ne se rejoue pas : l'import n'a aucun contrôle de doublon — il n'en a pas
    // besoin, on écrit dans un compte neuf — donc un second clic écrirait tout
    // une deuxième fois, un troisième une troisième, sans un mot et sans que
    // rien ne le signale (signalé par Fabrice, 30/07/2026). La porte reste, et
    // elle est désormais la seule chose à faire ici.
    element<HTMLButtonElement>("validate").hidden = true;
    await tell(outcome.said, t("ui-ok"));
    report.setRows(outcome.refused);
    element<HTMLElement>("tab-report").hidden = false;
    showTab("report");
    say(outcome.said, outcome.refused.length > 0);
  } catch (error) {
    say(String(error), true);
  }
}

async function leave(): Promise<void> {
  try {
    await invoke("close_excel_window", { label: "excel-fields" });
  } catch (error) {
    say(tError("ui-close-failed", error), true);
  }
}

element<HTMLButtonElement>("validate").addEventListener("click", () => void run());
element<HTMLButtonElement>("close").addEventListener("click", () => void leave());
for (const page of ["links", "settings", "report"] as const) {
  element<HTMLButtonElement>(`tab-${page}`).addEventListener("click", () => showTab(page));
}

/// Recharge tout depuis Rust — au premier affichage, en revenant de la fenêtre
/// d'association, et quand l'étape 1 renvoie ici avec d'autres en-têtes.
async function reload(): Promise<void> {
  try {
    const state = await invoke<Links>("excel_links");
    headerChoices = [IGNORE, ...state.headers];
    fieldChoices = state.fields;
    rows = state.links.map((link, index) => ({
      index,
      header: link.header,
      field: link.field,
    }));
    links.setRows(rows);
    await showPolicies();
    say(t("excel-fields-help"));
  } catch (error) {
    say(tError("ui-load-failed", error), true);
  }
}

// Revenir de la fenêtre d'association change ce que les politiques savent.
void listen("data-changed:excel-association", () => void showPolicies());
void listen("window-parameters:excel-fields", () => {
  // Une nouvelle importation commence : le compte-rendu de la précédente s'en
  // va, et le bouton revient — il n'était caché que parce que celle d'avant
  // était terminée.
  element<HTMLElement>("tab-report").hidden = true;
  element<HTMLButtonElement>("validate").hidden = false;
  showTab("links");
  void reload();
});

/// **Pose les mots de la fenêtre.** Appelée à l'ouverture, et de nouveau à
/// chaque changement de langue.
///
/// Elle ne repose que des étiquettes. La concordance et les politiques sont des
/// réglages saisis : aucune combo n'est remise à zéro, aucun bouton radio n'est
/// décoché, et l'onglet en cours ne bouge pas — le compte-rendu d'une
/// importation terminée reste sous les yeux de qui le lit.
async function dress(): Promise<void> {
  links.buildHeader(
    element<HTMLElement>("links-header"),
    element<HTMLElement>("links-filter"),
  );
  report.buildHeader(
    element<HTMLElement>("report-header"),
    element<HTMLElement>("report-filter"),
  );

  for (const [id, key] of [
    ["tab-links", "excel-tab-links"],
    ["tab-settings", "excel-tab-settings"],
    ["tab-report", "excel-report-title"],
    ["links-help", "excel-links-help"],
    ["report-title", "excel-report-title"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  element<HTMLElement>("validate").title = t("excel-title-import");
  element<HTMLElement>("close").title = t("ui-title-close");

  // Le titre de chaque groupe, les quatre libellés de ses boutons radio et la
  // phrase d'un groupe éteint sont écrits par le noyau : ce sont des phrases à
  // trou, que le dictionnaire ne porte pas. Il faut donc les lui redemander —
  // et cela ne coûte rien, puisque les politiques elles-mêmes vivent du côté de
  // Rust : ce qui est coché revient coché.
  //
  // Au premier habillage le panneau n'existe pas encore : `reload` le bâtit un
  // instant plus tard, et rien n'est demandé deux fois.
  if (element<HTMLElement>("policies").childElementCount > 0) {
    try {
      await showPolicies();
    } catch (error) {
      say(tError("ui-load-failed", error), true);
    }
  }
  // La concordance est celle que la fenêtre tient déjà — les en-têtes de la
  // feuille et les rubriques de Radinus ne sont d'aucune langue, on ne la
  // redemande donc pas : on la repose telle quelle, pour que le tableau se
  // redessine sous son en-tête neuf.
  if (rows.length > 0) {
    links.setRows(rows);
  }
}

void (async () => {
  await loadTexts(null);
  await dress();
  report.exportOnRightClick(say);

  showTab("links");
  await reload();
  onLanguageChanged(dress, { key: "window-excel-fields-title" });
})();
