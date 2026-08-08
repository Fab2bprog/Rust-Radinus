// « Importation de feuille excel : association des données » — la fenêtre du
// bouton « Définir destination ».
//
// **Une seule fenêtre pour les trois nomenclatures.** Sa maquette WinDev porte
// trois colonnes de destination et n'en montre qu'une, selon le type demandé ;
// c'est ce que fait son `SELON TypeTriXls`, et l'on fait pareil — le titre de
// la colonne de droite arrive avec les données.
//
// **La combo ne propose que l'existant** (règle de Fabrice, 29/07/2026) :
// ranger « Alimentationss » dans « Alimentation » est tout ce que cette fenêtre
// sait faire. Une ligne laissée sans choix garde l'identifiant 0 : la valeur
// restera vide pour ces opérations-là, comme dans son code — c'est la fenêtre
// qui doit avoir été validée, pas chacune de ses lignes.

import { invoke } from "@tauri-apps/api/core";
import { emit, listen } from "@tauri-apps/api/event";
import { Table } from "./table";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

interface Item {
  id: number;
  label: string;
}

interface Unknown {
  label: string;
  chosen_id: number;
}

interface Association {
  kind: string;
  column_title: string;
  values: Unknown[];
  choices: Item[];
}

interface Row {
  index: number;
  label: string;
  chosenId: number;
}

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

let kind = "category";
let columnTitle = "";
let choices: Item[] = [];
let rows: Row[] = [];

const table = new Table<Row>({
  container: element<HTMLDivElement>("rows"),
  columns: [
    {
      title: () => t("excel-column-data"),
      cell: (row) => row.label,
      width: "1fr",
    },
    {
      // Le titre vient de Rust, décliné pour la nomenclature demandée.
      title: () => columnTitle,
      cell: (row) =>
        choices.find((choice) => choice.id === row.chosenId)?.label ?? "",
      width: "1fr",
      editor: {
        // Une ligne vide en tête : ne rien choisir est un choix, et c'est
        // celui qui laisse la valeur sans classement.
        options: () => [{ id: 0, label: "" }, ...choices],
        value: (row) => row.chosenId,
        change: (row, value) => {
          row.chosenId = value;
          table.setRows(rows);
        },
      },
    },
  ],
  identity: (row) => row.index,
  emptyText: () => t("excel-association-none"),
  filteredOutText: () => t("ui-no-match"),
});

/// Rapporte les choix et quitte. C'est le `Transfert_Data` de Fabrice : les
/// identifiants retenus repartent dans le dictionnaire, indexés par le libellé
/// Excel — toutes les lignes du fichier qui portent ce libellé suivront la même
/// destination.
async function validate(): Promise<void> {
  try {
    await invoke("excel_set_association", {
      kind,
      values: rows.map((row) => ({ label: row.label, chosen_id: row.chosenId })),
    });
    await emit("data-changed:excel-association", kind);
    await invoke("close_excel_window", { label: "excel-association" });
  } catch (error) {
    say(tError("ui-save-failed", error), true);
  }
}

async function leave(): Promise<void> {
  try {
    await invoke("close_excel_window", { label: "excel-association" });
  } catch (error) {
    say(tError("ui-close-failed", error), true);
  }
}

element<HTMLButtonElement>("validate").addEventListener("click", () => void validate());
element<HTMLButtonElement>("close").addEventListener("click", () => void leave());

async function reload(): Promise<void> {
  try {
    const state = await invoke<Association>("excel_association", { kind });
    columnTitle = state.column_title;
    choices = state.choices;
    rows = state.values.map((value, index) => ({
      index,
      label: value.label,
      chosenId: value.chosen_id,
    }));
    // Le titre de la colonne de droite change avec la nomenclature : l'en-tête
    // doit donc être rebâti, pas seulement rempli.
    table.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));
    table.setRows(rows);
    say(rows.length === 0 ? t("excel-association-none") : t("excel-association-help"));
  } catch (error) {
    say(tError("ui-load-failed", error), true);
  }
}

function readParameters(query: string): void {
  kind = new URLSearchParams(query).get("kind") ?? kind;
}

/// Redemandée pour une autre nomenclature : la fenêtre est bâtie une fois et
/// jamais détruite, donc le type arrive par un événement. Sans cette écoute,
/// elle montrerait éternellement les catégories.
void listen<string>("window-parameters:excel-association", (event) => {
  readParameters(event.payload);
  void reload();
});

/// **Pose les mots de la fenêtre.** Appelée à l'ouverture, et de nouveau à
/// chaque changement de langue.
///
/// Le titre de la colonne de droite est écrit par le noyau et décliné pour la
/// nomenclature demandée : on le lui redemande, avec les valeurs qu'il propose.
/// **Les destinations choisies, elles, ne repassent pas par là** : elles ne
/// sont chez Rust qu'après validation, et les relire effacerait le travail en
/// cours. Au premier habillage il n'y a encore rien à redemander — `reload` s'en
/// charge un instant plus tard.
async function dress(): Promise<void> {
  if (columnTitle !== "") {
    try {
      const state = await invoke<Association>("excel_association", { kind });
      columnTitle = state.column_title;
      choices = state.choices;
    } catch (error) {
      say(tError("ui-load-failed", error), true);
    }
  }
  table.buildHeader(element<HTMLElement>("header"), element<HTMLElement>("filter"));
  element<HTMLElement>("help").textContent = t("excel-association-help");
  element<HTMLElement>("validate").title = t("ui-title-save");
  element<HTMLElement>("close").title = t("ui-title-close");
  if (rows.length > 0) {
    table.setRows(rows);
  }
}

void (async () => {
  await loadTexts(null);
  await dress();
  readParameters(window.location.search);
  await reload();
  onLanguageChanged(dress, { key: "window-excel-association-title" });
})();
