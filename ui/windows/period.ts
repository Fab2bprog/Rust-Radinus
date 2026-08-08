// Le menu Période, et les dates qu'il calcule.
//
// **Deux fenêtres l'ont** : la liste des opérations (F02) et le tableau de
// bord (F19), qui l'affichent au même endroit et en attendent exactement les
// mêmes neuf entrées. Il a été écrit pour F02 le 25/07/2026, hammered par
// Fabrice jusqu'à ce que les semaines commencent le lundi et que les mois de
// février fassent le bon nombre de jours ; il est sorti ici le 26/07/2026,
// quand F19 en a eu besoin, plutôt que d'en faire une seconde copie — deux
// copies, ce sont deux fois les mêmes corrections à refaire.
//
// Ce module ne connaît aucune fenêtre : il rend des dates et un menu, et
// c'est l'appelante qui décide quoi en faire.

import { t } from "./texts";

export interface Period {
  from: string;
  to: string;
}

/// Une date, écrite comme SQLite la range : `AAAA-MM-JJ`, **dans le fuseau du
/// poste**. `toISOString()` passe par UTC et rend la veille pour quiconque vit
/// à l'est de Greenwich.
export function iso(date: Date): string {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(
    date.getDate(),
  ).padStart(2, "0")}`;
}

/// Le lundi de la semaine où tombe `date`. La semaine commence le lundi, comme
/// sur tous les calendriers français ; `getDay()`, lui, compte à partir du
/// dimanche.
function mondayOf(date: Date): Date {
  const monday = new Date(date.getFullYear(), date.getMonth(), date.getDate());
  const weekday = (monday.getDay() + 6) % 7;
  monday.setDate(monday.getDate() - weekday);
  return monday;
}

/// Le mois entier. Le jour 0 du mois suivant est le dernier de celui-ci —
/// années bissextiles comprises, sans avoir à savoir lesquelles.
export function wholeMonth(year: number, month: number): Period {
  return {
    from: iso(new Date(year, month, 1)),
    to: iso(new Date(year, month + 1, 0)),
  };
}

export function wholeYear(year: number): Period {
  return { from: iso(new Date(year, 0, 1)), to: iso(new Date(year, 11, 31)) };
}

export function currentMonth(): Period {
  const today = new Date();
  return wholeMonth(today.getFullYear(), today.getMonth());
}

/// Une entrée du menu : son nom, et les deux dates qu'elle calcule. Une entrée
/// qui ouvre un sous-menu porte celui-ci à la place.
interface PeriodEntry {
  key: string;
  dates?: () => Period;
  submenu?: () => PeriodEntry[];
}

const MONTH_KEYS = [
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
];

/// Les douze mois d'une année, précédés de l'année entière.
function yearSubmenu(year: number): PeriodEntry[] {
  return [
    { key: "period-whole-year", dates: () => wholeYear(year) },
    ...MONTH_KEYS.map((key, month) => ({
      key,
      dates: () => wholeMonth(year, month),
    })),
  ];
}

/// Les neuf entrées, dans l'ordre de l'auteur.
function periodEntries(): PeriodEntry[] {
  const today = new Date();
  const year = today.getFullYear();
  return [
    // Assez large pour tenir tout ce qu'il y a, et tout ce qu'il y aura
    // (les bornes de Fabrice, 25/07/2026).
    { key: "period-all", dates: () => ({ from: "1950-01-01", to: "2550-12-31" }) },
    { key: "period-last-year", submenu: () => yearSubmenu(year - 1) },
    { key: "period-this-year", submenu: () => yearSubmenu(year) },
    {
      key: "period-last-month",
      dates: () => wholeMonth(year, today.getMonth() - 1),
    },
    { key: "period-this-month", dates: () => currentMonth() },
    {
      key: "period-last-week",
      dates: () => {
        const monday = mondayOf(today);
        monday.setDate(monday.getDate() - 7);
        const sunday = new Date(monday);
        sunday.setDate(sunday.getDate() + 6);
        return { from: iso(monday), to: iso(sunday) };
      },
    },
    {
      key: "period-this-week",
      dates: () => {
        const monday = mondayOf(today);
        const sunday = new Date(monday);
        sunday.setDate(sunday.getDate() + 6);
        return { from: iso(monday), to: iso(sunday) };
      },
    },
    {
      key: "period-yesterday",
      dates: () => {
        const yesterday = new Date(today);
        yesterday.setDate(yesterday.getDate() - 1);
        return { from: iso(yesterday), to: iso(yesterday) };
      },
    },
    { key: "period-today", dates: () => ({ from: iso(today), to: iso(today) }) },
  ];
}

/// Pose l'encoche sur l'entrée choisie, et l'ôte des autres. Le nom du menu ne
/// change jamais : un menu dit ce qu'il est, et l'encoche dit où l'on en est —
/// c'est ainsi que se comportent tous les menus du système (remarque de
/// Fabrice, 25/07/2026).
function markChosen(choices: HTMLElement, key: string | null): void {
  for (const button of choices.querySelectorAll<HTMLElement>(".window-menu__choice")) {
    button.classList.toggle("window-menu__choice--chosen", button.dataset.key === key);
  }
}

/// Construit le menu sous son entrée. `apply` reçoit la période choisie ;
/// `fields` sont les deux champs de dates, dont la saisie à la main retire
/// l'encoche — ce qui est alors à l'écran est une période que personne n'a
/// choisie dans ce menu.
export function buildPeriodMenu(
  entry: HTMLElement,
  apply: (period: Period) => void,
  fields: HTMLInputElement[],
  /// Sur quelle entrée l'encoche part. **C'est la période sur laquelle la
  /// fenêtre s'ouvre**, et elle n'est pas la même partout : F02 et le tableau
  /// de bord s'ouvrent sur le mois, l'évolution du solde sur l'année. Une
  /// encoche posée ailleurs qu'à l'endroit affiché est un mensonge, et c'en
  /// était un (signalé par Fabrice, 26/07/2026).
  chosen: string = "period-this-month",
): HTMLElement {
  const holder = document.createElement("div");
  holder.className = "window-menu__holder";
  const choices = document.createElement("div");
  choices.className = "window-menu__choices";
  choices.dataset.menu = "period";
  choices.hidden = true;

  for (const item of periodEntries()) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "window-menu__choice";
    button.textContent = t(item.key);

    if (item.submenu) {
      button.classList.add("window-menu__choice--parent");
      const nested = document.createElement("div");
      nested.className = "window-menu__submenu";
      for (const month of item.submenu()) {
        const monthButton = document.createElement("button");
        monthButton.type = "button";
        monthButton.className = "window-menu__choice";
        monthButton.dataset.key = `${item.key}:${month.key}`;
        monthButton.textContent = t(month.key);
        monthButton.addEventListener("click", () => {
          choices.hidden = true;
          markChosen(choices, monthButton.dataset.key!);
          apply(month.dates!());
        });
        nested.append(monthButton);
      }
      const nest = document.createElement("div");
      nest.className = "window-menu__nest";
      // Les mois apparaissent quand le pointeur s'arrête sur l'année, et aussi
      // quand on la clique : un menu qu'on ne peut que survoler est un menu
      // qu'on peut manquer.
      button.addEventListener("click", (event) => {
        event.stopPropagation();
        nest.classList.toggle("window-menu__nest--open");
      });
      nest.append(button, nested);
      choices.append(nest);
      continue;
    }

    button.dataset.key = item.key;
    button.addEventListener("click", () => {
      choices.hidden = true;
      markChosen(choices, item.key);
      apply(item.dates!());
    });
    choices.append(button);
  }

  entry.addEventListener("click", (event) => {
    event.stopPropagation();
    choices.hidden = !choices.hidden;
  });
  // Un clic ailleurs le referme, comme n'importe quel menu.
  document.addEventListener("click", () => {
    choices.hidden = true;
  });

  // La fenêtre s'ouvre sur une période, et le menu dit laquelle.
  markChosen(choices, chosen);
  for (const field of fields) {
    field.addEventListener("change", () => markChosen(choices, null));
  }

  holder.append(entry, choices);
  return holder;
}
