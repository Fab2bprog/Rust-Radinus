// F48 — « Partager une dépense » (Fabrice, 11/10/2026, P-71).
//
// « Un outil de partage de dépense : partager une somme avec des
// contraintes. » Qui paie quoi ?
//
// **La fenêtre ne calcule rien.** Elle tient ce qui est tapé — les personnes,
// les postes, les règlements —, l'envoie à chaque changement, et montre ce
// que le noyau lui rend tout écrit : ce que chacun paie, poste par poste, et
// où en sont les règlements. Elle ne compose aucune phrase : même le nom
// d'une personne ajoutée (« Personne 3 ») vient du noyau.
//
// **Rien n'entre dans la base**, et l'outil marche sans base ouverte. Ce qui
// doit durer part dans un fichier — le projet en JSON, trois rapports PDF, le
// classeur Excel. La porte demande avant d'oublier, puis efface tout.

import "./shortcuts";
import { invoke } from "@tauri-apps/api/core";
import { save } from "@tauri-apps/plugin-dialog";
import { askThreeWays, askYesNo } from "./dialog";
import { asMoneyField, asNumberField } from "./money-field";
import { loadTexts, onLanguageChanged, t, tError } from "./texts";

interface PersonInput {
  id: number;
  name: string;
  household: string;
  income: string;
  parts: string;
  percent: string;
  floor: string;
  cap: string;
  fixed: string;
  alone: string;
  gift: boolean;
}

interface CellInput {
  person: number;
  takes: boolean;
  value: string;
}

interface ItemInput {
  id: number;
  label: string;
  amount: string;
  rule: string;
  cells: CellInput[];
}

interface PaymentInput {
  id: number;
  person: number;
  amount: string;
  date: string;
  label: string;
}

interface Input {
  label: string;
  total: string;
  mode: string;
  rule: string;
  rounding: string;
  show_incomes: boolean;
  people: PersonInput[];
  common: ItemInput;
  items: ItemInput[];
  payments: PaymentInput[];
}

interface PersonLine {
  id: number;
  name: string;
  due: string;
  share: string;
  typed: string;
  constraint: string;
  alone: string;
  outside: string;
  rounding: string;
  detail: string;
}

interface Written {
  headline: string;
  tone: string;
  common: string;
  people: PersonLine[];
  cells: { person: number; item: number; amount: string }[];
  items: { id: number; label: string; amount: string; participants: string }[];
  units: { key: string; name: string; members: string; due: string; paid: string; balance: string; tone: string }[];
  summary: string[];
  transfers: string[];
  notes: string[];
  warning: string | null;
}

/// Une valeur conseillée : la colonne d'une personne (`item` nul) ou la case
/// d'un poste.
interface Suggested {
  person: number;
  item: number | null;
  value: string;
}

/// **Les conseils** (P-72), donnés même quand le partage est refusé.
interface Advice {
  sentence: string;
  warn: boolean;
  items: { id: number; sentence: string; warn: boolean }[];
  suggested: Suggested[];
  from_incomes: Suggested[];
}

interface Result {
  invalid: string | null;
  message: string | null;
  written: Written | null;
  next_name: string;
  advice: Advice;
}

/// Les limites du noyau : au-delà, les boutons d'ajout s'éteignent.
const PEOPLE_LIMIT = 40;
const ITEMS_LIMIT = 20;
const PAYMENTS_LIMIT = 400;
const RULES = ["equal", "parts", "percent", "income"];

const element = <T extends HTMLElement>(id: string): T => document.getElementById(id) as T;
const field = (id: string): HTMLInputElement => element<HTMLInputElement>(id);

const infoBar = element<HTMLElement>("info-bar");

function say(message: string, alert = false): void {
  infoBar.textContent = message;
  infoBar.classList.toggle("info-bar--alert", alert);
}

// --- Ce qui est tapé ------------------------------------------------------------

function blank(): Input {
  return {
    label: "",
    total: "",
    mode: "whole",
    rule: "equal",
    rounding: "cent",
    show_incomes: false,
    people: [],
    common: { id: 0, label: "", amount: "", rule: "equal", cells: [] },
    items: [],
    payments: [],
  };
}

let model: Input = blank();

const input = (): Input => JSON.parse(JSON.stringify(model)) as Input;

/// Les postes, le commun d'abord.
const allItems = (): ItemInput[] => [model.common, ...model.items];

function nextId(ids: number[]): number {
  return ids.length === 0 ? 1 : Math.max(...ids) + 1;
}

function cellOf(item: ItemInput, person: number): CellInput {
  let cell = item.cells.find((one) => one.person === person);
  if (!cell) {
    cell = { person, takes: true, value: "" };
    item.cells.push(cell);
  }
  return cell;
}

/// La règle d'un poste : celle de toute la dépense, ou la sienne.
const ruleOf = (item: ItemInput): string => (model.mode === "item" ? item.rule : model.rule);
const usesRule = (rule: string): boolean => allItems().some((item) => ruleOf(item) === rule);

/// Quelque chose a-t-il été tapé ? Ouvrir un projet le remplacerait.
function typed(): boolean {
  return (
    model.label.trim() !== "" ||
    model.total.trim() !== "" ||
    model.people.length > 0 ||
    model.items.length > 0 ||
    model.payments.length > 0
  );
}

/// Ce que disait la fenêtre au dernier projet enregistré ou ouvert : tant
/// qu'elle le dit encore, il n'y a rien à perdre en sortant.
let kept = "";
const state = (): string => JSON.stringify(model);

// --- Le calcul ------------------------------------------------------------------

let running = false;
let again = false;
/// Une phrase à garder dans la barre après le prochain calcul — « Projet
/// ouvert : … » —, que le calcul effacerait sinon.
let pending: string | null = null;
/// Le nom de la prochaine personne ajoutée, donné par le noyau.
let nextName = "";
let last: Written | null = null;
const NO_ADVICE: Advice = { sentence: "", warn: false, items: [], suggested: [], from_incomes: [] };
let advice: Advice = NO_ADVICE;

function compute(): void {
  if (running) {
    again = true;
    return;
  }
  running = true;
  void (async () => {
    try {
      show(await invoke<Result>("sharing_compute", { input: input() }));
    } catch (error) {
      say(tError("ui-read-failed", error), true);
    } finally {
      running = false;
      if (again) {
        again = false;
        compute();
      }
    }
  })();
}

function show(result: Result): void {
  nextName = result.next_name;
  advice = result.advice ?? NO_ADVICE;
  showAdvice();
  for (const marked of document.querySelectorAll(".form__field--invalid, .sharing__row--invalid")) {
    marked.classList.remove("form__field--invalid", "sharing__row--invalid");
  }
  if (!result.written) {
    // **Un calcul refusé n'a pas de résultat** : les montants d'avant ne sont
    // plus vrais, ils s'effacent plutôt que de rester affichés comme s'ils
    // l'étaient.
    clearResult();
    if (result.invalid) {
      const target = document.getElementById(result.invalid);
      target?.classList.add(target.tagName === "TR" || target.tagName === "TH" ? "sharing__row--invalid" : "form__field--invalid");
    }
    say(result.message ?? "", true);
    return;
  }
  say(pending ?? "");
  pending = null;
  last = result.written;
  const written = result.written;
  element<HTMLElement>("answer").dataset.tone = written.tone;
  element<HTMLElement>("headline").textContent = written.headline;
  const warning = element<HTMLElement>("warning");
  warning.hidden = written.warning === null;
  warning.textContent = written.warning ?? "";

  // Les montants dans la grille, et les résultats au bout de chaque ligne.
  for (const out of document.querySelectorAll<HTMLElement>(".sharing__out")) {
    out.textContent = "";
  }
  for (const cell of written.cells) {
    const out = document.getElementById(`out-${cell.item}-${cell.person}`);
    if (out) {
      out.textContent = cell.amount;
    }
  }
  for (const line of written.people) {
    const set = (id: string, text: string): void => {
      const target = document.getElementById(`${id}-${line.id}`);
      if (target) {
        target.textContent = text;
      }
    };
    set("due", line.due);
    set("share", line.share);
    set("typed", line.typed);
    set("constraint", line.constraint);
    const row = document.getElementById(`person-${line.id}`);
    if (row) {
      row.title = line.detail;
    }
  }
  for (const item of written.items) {
    const amount = document.getElementById(`head-amount-${item.id}`);
    if (amount) {
      amount.textContent = item.amount;
    }
  }
  element<HTMLElement>("common-amount").textContent = written.common;

  // Où en sont les règlements.
  const summary = element<HTMLElement>("summary");
  summary.replaceChildren(...written.summary.map((line) => listItem(line)));
  const units = element<HTMLElement>("units");
  units.replaceChildren();
  for (const unit of written.units) {
    const row = document.createElement("tr");
    row.dataset.tone = unit.tone;
    for (const [text, number] of [
      [unit.name, false],
      [unit.members, false],
      [unit.due, true],
      [unit.paid, true],
      [unit.balance, false],
    ] as const) {
      const cell = document.createElement("td");
      cell.textContent = text;
      if (number) {
        cell.className = "loan__number";
      }
      row.append(cell);
    }
    row.lastElementChild?.classList.add("sharing__balance");
    units.append(row);
  }
  element<HTMLElement>("balances-card").hidden = written.units.length === 0 || written.summary.length === 0;
  element<HTMLElement>("transfers-title").hidden = written.transfers.length === 0;
  element<HTMLElement>("transfers").replaceChildren(...written.transfers.map((line) => listItem(line)));
  element<HTMLElement>("notes").replaceChildren(...written.notes.map((line) => listItem(line)));
  fillUnits(written);
}

/// Efface tout ce que le dernier calcul avait écrit.
function clearResult(): void {
  last = null;
  for (const out of document.querySelectorAll<HTMLElement>(".sharing__out, .sharing__due, [id^='share-'], .sharing__typed, .sharing__constraint, .sharing__item-amount")) {
    out.textContent = "";
  }
  const common = document.getElementById("common-amount");
  if (common) {
    common.textContent = "";
  }
  element<HTMLElement>("answer").dataset.tone = "none";
  element<HTMLElement>("headline").textContent = "";
  element<HTMLElement>("warning").hidden = true;
  element<HTMLElement>("balances-card").hidden = true;
  element<HTMLElement>("notes").replaceChildren();
}

// --- Les conseils (P-72) -----------------------------------------------------------
//
// « Il faudrait afficher des valeurs conseillées » (Fabrice, 11/10/2026). Le
// noyau les calcule ; la fenêtre les montre en gris dans les cases vides —
// **une valeur grise ne compte pas** tant qu'on ne l'a pas reprise.

/// Le champ où va une valeur conseillée.
function suggestedTarget(value: Suggested): HTMLInputElement | null {
  const id =
    value.item === null
      ? `${model.rule === "parts" ? "parts" : "percent"}-${value.person}`
      : `cell-${value.item}-${value.person}`;
  return document.getElementById(id) as HTMLInputElement | null;
}

/// Écrit une valeur dans le modèle, là où sa case la lit.
function adopt(value: Suggested): void {
  const person = model.people.find((one) => one.id === value.person);
  if (!person) {
    return;
  }
  if (value.item === null) {
    if (model.rule === "parts") {
      person.parts = value.value;
    } else {
      person.percent = value.value;
    }
    return;
  }
  const item = allItems().find((one) => one.id === value.item);
  if (item) {
    cellOf(item, value.person).value = value.value;
  }
}

function adviceLine(target: HTMLElement, sentence: string, warn: boolean): void {
  target.textContent = sentence;
  target.hidden = sentence === "";
  target.classList.toggle("sharing__advice--warn", warn);
}

/// Montre les phrases, les valeurs grises et les boutons du dernier conseil.
function showAdvice(): void {
  adviceLine(element<HTMLElement>("rule-advice"), model.mode === "whole" ? advice.sentence : "", advice.warn);
  for (const line of document.querySelectorAll<HTMLElement>(".sharing__item-advice")) {
    const said = advice.items.find((item) => `advice-${item.id}` === line.id);
    adviceLine(line, said?.sentence ?? "", said?.warn ?? false);
  }
  for (const box of document.querySelectorAll<HTMLInputElement>("input[data-placeholder]")) {
    box.placeholder = box.dataset.placeholder ?? "";
  }
  for (const value of advice.suggested) {
    const box = suggestedTarget(value);
    if (box && box.value.trim() === "") {
      box.placeholder = value.value;
    }
  }
  element<HTMLButtonElement>("apply-advice").hidden = advice.suggested.length === 0;
  element<HTMLButtonElement>("from-incomes").hidden = advice.from_incomes.length === 0;
  element<HTMLButtonElement>("reset-percents").hidden = !percentsTyped();
}

/// Des pourcentages tapés, qu'on pourrait vouloir répartir à nouveau.
function percentsTyped(): boolean {
  if (model.people.length === 0) {
    return false;
  }
  if (model.mode === "whole") {
    return model.rule === "percent" && model.people.some((person) => person.percent.trim() !== "");
  }
  return allItems().some((item) => item.rule === "percent" && item.cells.some((one) => one.value.trim() !== ""));
}

function listItem(text: string): HTMLLIElement {
  const item = document.createElement("li");
  item.textContent = text;
  return item;
}

/// Le choix des relevés : tout le monde, ou un foyer.
function fillUnits(written: Written | null): void {
  const target = element<HTMLSelectElement>("statements-unit");
  const chosen = target.value;
  target.replaceChildren();
  const everyone = document.createElement("option");
  everyone.value = "";
  everyone.textContent = t("sharing-statements-everyone");
  target.append(everyone);
  for (const unit of written?.units ?? []) {
    const option = document.createElement("option");
    option.value = unit.key;
    option.textContent = unit.name;
    target.append(option);
  }
  target.value = [...target.options].some((option) => option.value === chosen) ? chosen : "";
}

// --- Les champs -------------------------------------------------------------------

/// Un champ de saisie relié au modèle : il part au calcul quand on le quitte.
///
/// **Un montant ou un nombre est gardé à la frappe**, comme dans toutes les
/// fiches de Radinus (Fabrice, 11/10/2026 : « on peut écrire des lettres dans
/// un champ numérique, c'est pas bien du tout ») : `money-field`, sans signe
/// — rien n'est négatif dans un partage — et vide reste vide — un plafond
/// vide n'est pas un plafond à zéro.
function textInput(
  id: string,
  value: string,
  change: (value: string) => void,
  options: { kind?: "money" | "number"; size?: string } = {},
): HTMLInputElement {
  const box = document.createElement("input");
  box.className = `form__field ${options.size ?? "sharing__input"}`;
  box.id = id;
  box.value = value;
  box.autocomplete = "off";
  if (options.kind === "money") {
    asMoneyField(box, { unsigned: true, optional: true });
  } else if (options.kind === "number") {
    asNumberField(box);
  }
  // Le modèle suit chaque frappe — et la mise en forme d'un montant quand on
  // quitte le champ — ; le calcul part quand on le quitte.
  box.addEventListener("input", () => change(box.value));
  box.addEventListener("change", () => {
    change(box.value);
    compute();
  });
  box.addEventListener("keydown", (event) => {
    if (event.key === "Enter") {
      box.blur();
    }
  });
  return box;
}

function checkbox(id: string, checked: boolean, change: (checked: boolean) => void): HTMLInputElement {
  const box = document.createElement("input");
  box.type = "checkbox";
  box.id = id;
  box.checked = checked;
  box.addEventListener("change", () => {
    change(box.checked);
    compute();
  });
  return box;
}

function ruleSelect(id: string, value: string, change: (value: string) => void): HTMLSelectElement {
  const box = document.createElement("select");
  box.className = "form__field sharing__select";
  box.id = id;
  box.title = t(HELP.rule);
  for (const rule of RULES) {
    const option = document.createElement("option");
    option.value = rule;
    option.textContent = t(`sharing-rule-${rule}`);
    box.append(option);
  }
  box.value = value || "equal";
  box.addEventListener("change", () => {
    change(box.value);
    render();
    compute();
  });
  return box;
}

function deleteButton(title: string, act: () => void | Promise<void>): HTMLButtonElement {
  const button = document.createElement("button");
  button.type = "button";
  button.className = "sharing__delete";
  button.title = title;
  button.textContent = "×";
  button.addEventListener("click", () => {
    void (async () => {
      await act();
      render();
      compute();
    })();
  });
  return button;
}

function cell(...children: (Node | string)[]): HTMLTableCellElement {
  const target = document.createElement("td");
  target.append(...children);
  return target;
}

/// **Les infobulles** (Fabrice, 11/10/2026 : « il faudrait définir plafond,
/// montant fixe, foyer, contrainte… peut-être mettre des infos bulle ») :
/// une définition et un exemple, une par colonne. Les clefs sont écrites en
/// entier pour que le contrôle des textes les retrouve.
const HELP = {
  household: "sharing-help-household",
  income: "sharing-help-income",
  parts: "sharing-help-parts",
  percent: "sharing-help-percent",
  floor: "sharing-help-floor",
  cap: "sharing-help-cap",
  fixed: "sharing-help-fixed",
  alone: "sharing-help-alone",
  gift: "sharing-help-gift",
  items: "sharing-help-items",
  due: "sharing-help-due",
  share: "sharing-help-share",
  typed: "sharing-help-typed",
  constraint: "sharing-help-constraint",
  item: "sharing-help-item",
  rule: "sharing-help-rule",
  paid: "sharing-help-paid",
  balance: "sharing-help-balance",
} as const;

/// Ajoute à un titre son « ⓘ » et sa bulle — au survol du titre entier, pas
/// seulement du petit signe.
function withHelp(target: HTMLElement, help: keyof typeof HELP): void {
  const text = t(HELP[help]);
  const mark = document.createElement("span");
  mark.className = "sharing__help";
  mark.textContent = "ⓘ";
  mark.setAttribute("aria-label", text);
  target.append(" ", mark);
  target.title = text;
  target.dataset.help = help;
}

function heading(text: string, className = "", help?: keyof typeof HELP): HTMLTableCellElement {
  const target = document.createElement("th");
  target.textContent = text;
  if (className) {
    target.className = className;
  }
  if (help) {
    withHelp(target, help);
  }
  return target;
}

// --- Les postes -------------------------------------------------------------------

function renderItems(): void {
  const body = element<HTMLElement>("items");
  body.replaceChildren();
  const perItem = model.mode === "item";

  // La règle d'un poste se choisit sous son nom, en mode « une règle par poste ».
  // Dessous, ce que la règle donne : « 60,00 € ÷ 3 personnes = 20,00 € chacun ».
  const named = (name: Node | string, rule: HTMLSelectElement, id: number): HTMLTableCellElement => {
    const target = cell(name);
    if (perItem) {
      rule.classList.add("sharing__item-rule");
      const said = document.createElement("span");
      said.className = "sharing__advice sharing__item-advice";
      said.id = `advice-${id}`;
      said.hidden = true;
      target.append(rule, said);
    }
    return target;
  };

  const common = document.createElement("tr");
  common.id = "item-0";
  common.className = "sharing__common";
  const commonAmount = document.createElement("span");
  commonAmount.id = "common-amount";
  commonAmount.textContent = last?.common ?? "";
  const amountCell = cell(commonAmount);
  amountCell.className = "loan__number";
  common.append(
    named(t("sharing-common"), ruleSelect("rule-0", model.common.rule, (value) => (model.common.rule = value)), 0),
    amountCell,
    cell(),
  );
  body.append(common);

  for (const item of model.items) {
    const row = document.createElement("tr");
    row.id = `item-${item.id}`;
    const label = textInput(`label-${item.id}`, item.label, (value) => {
      item.label = value;
      const name = document.querySelector(`#head-${item.id} span`);
      if (name) {
        name.textContent = value;
      }
    });
    row.append(
      named(label, ruleSelect(`rule-${item.id}`, item.rule, (value) => (item.rule = value)), item.id),
      cell(textInput(`amount-${item.id}`, item.amount, (value) => (item.amount = value), { kind: "money", size: "sharing__money" })),
      cell(
        deleteButton(t("sharing-delete"), () => {
          model.items = model.items.filter((one) => one.id !== item.id);
        }),
      ),
    );
    body.append(row);
  }
  element<HTMLButtonElement>("add-item").disabled = model.items.length >= ITEMS_LIMIT;
}

// --- Les personnes : une seule grille ---------------------------------------------

/// Les colonnes d'une personne. Le revenu, les parts et le pourcentage ne se
/// montrent que si une règle s'en sert.
function personColumns(): { key: keyof typeof HELP; heading: string; money: boolean }[] {
  const columns: { key: keyof typeof HELP; heading: string; money: boolean }[] = [
    { key: "household", heading: "sharing-column-household", money: false },
  ];
  // En pourcentages, les revenus déjà tapés restent en vue : ils servent à
  // « Pourcentages d'après les revenus ».
  const percentWithIncomes =
    model.mode === "whole" && model.rule === "percent" && model.people.some((person) => person.income.trim() !== "");
  if (usesRule("income") || percentWithIncomes) {
    columns.push({ key: "income", heading: "sharing-column-income", money: true });
  }
  if (usesRule("parts")) {
    columns.push({ key: "parts", heading: "sharing-column-parts", money: false });
  }
  if (model.mode === "whole" && model.rule === "percent") {
    columns.push({ key: "percent", heading: "sharing-column-percent", money: false });
  }
  for (const key of ["floor", "cap", "fixed", "alone"] as const) {
    columns.push({ key, heading: `sharing-column-${key}`, money: true });
  }
  return columns;
}

function renderPeople(): void {
  const columns = personColumns();
  const items = allItems();
  const typedPercent = model.mode === "whole" && model.rule === "percent";

  const head = element<HTMLElement>("people-head");
  head.replaceChildren();
  const top = document.createElement("tr");
  top.append(heading("", "sharing__sticky-delete"), heading(t("sharing-column-person"), "sharing__sticky"));
  // Le résultat d'abord, à côté du nom : c'est ce qu'on cherche des yeux.
  top.append(
    heading(t("sharing-column-due"), "loan__number sharing__sticky-due", "due"),
    heading(t("sharing-column-share"), "loan__number", "share"),
  );
  if (typedPercent) {
    top.append(heading(t("sharing-column-typed"), "loan__number", "typed"));
  }
  top.append(heading(t("sharing-column-constraint"), "", "constraint"));
  for (const column of columns) {
    top.append(heading(t(column.heading), "", column.key));
  }
  top.append(heading(t("sharing-column-gift"), "", "gift"));
  for (const item of items) {
    const th = document.createElement("th");
    th.className = "sharing__item-head";
    th.id = `head-${item.id}`;
    const name = document.createElement("span");
    name.textContent = item.id === 0 ? t("sharing-common") : item.label;
    const amount = document.createElement("span");
    amount.className = "sharing__item-amount";
    amount.id = `head-amount-${item.id}`;
    amount.textContent = last?.items.find((one) => one.id === item.id)?.amount ?? "";
    th.append(name, amount);
    withHelp(th, "items");
    top.append(th);
  }
  head.append(top);

  const body = element<HTMLElement>("people");
  body.replaceChildren();
  for (const person of model.people) {
    const row = document.createElement("tr");
    row.id = `person-${person.id}`;
    const remove = cell(
      deleteButton(t("sharing-delete"), async () => {
        const paid = model.payments.some((payment) => payment.person === person.id);
        if (paid && !(await askYesNo(t("sharing-delete-person-question"), t("ui-yes"), t("ui-no")))) {
          return;
        }
        model.people = model.people.filter((one) => one.id !== person.id);
        model.payments = model.payments.filter((payment) => payment.person !== person.id);
        for (const item of allItems()) {
          item.cells = item.cells.filter((one) => one.person !== person.id);
        }
      }),
    );
    remove.className = "sharing__sticky-delete";
    const name = cell(
      textInput(`name-${person.id}`, person.name, (value) => {
        person.name = value;
        for (const option of document.querySelectorAll<HTMLOptionElement>(`#payments option[value="${person.id}"]`)) {
          option.textContent = value;
        }
      }),
    );
    name.className = "sharing__sticky";
    row.append(remove, name);
    const due = cell();
    due.id = `due-${person.id}`;
    due.className = "loan__number sharing__due sharing__sticky-due";
    const share = cell();
    share.id = `share-${person.id}`;
    share.className = "loan__number";
    row.append(due, share);
    if (typedPercent) {
      const typedCell = cell();
      typedCell.id = `typed-${person.id}`;
      typedCell.className = "loan__number sharing__typed";
      row.append(typedCell);
    }
    const constraint = cell();
    constraint.id = `constraint-${person.id}`;
    constraint.className = "sharing__constraint";
    row.append(constraint);
    for (const column of columns) {
      const key = column.key as keyof PersonInput;
      const box = textInput(
        `${column.key}-${person.id}`,
        String(person[key] ?? ""),
        (value) => {
          (person as unknown as Record<string, string>)[column.key] = value;
        },
        column.money
          ? { kind: "money", size: "sharing__money" }
          : column.key === "parts" || column.key === "percent"
            ? { kind: "number", size: "sharing__money" }
            : {},
      );
      if (column.key === "parts" || column.key === "percent") {
        box.dataset.placeholder = "";
      }
      row.append(cell(box));
    }
    row.append(cell(checkbox(`gift-${person.id}`, person.gift, (checked) => (person.gift = checked))));
    for (const item of items) {
      const own = cellOf(item, person.id);
      const box = document.createElement("td");
      box.className = "sharing__cell";
      box.append(
        checkbox(`takes-${item.id}-${person.id}`, own.takes, (checked) => {
          own.takes = checked;
        }),
      );
      const rule = ruleOf(item);
      if (model.mode === "item" && (rule === "parts" || rule === "percent")) {
        const value = textInput(`cell-${item.id}-${person.id}`, own.value, (text) => (own.value = text), {
          kind: "number",
          size: "sharing__tiny",
        });
        value.placeholder = rule === "parts" ? person.parts || "1" : "%";
        value.dataset.placeholder = value.placeholder;
        box.append(value);
      }
      const out = document.createElement("span");
      out.className = "sharing__out";
      out.id = `out-${item.id}-${person.id}`;
      box.append(out);
      row.append(box);
    }
    body.append(row);
  }
  element<HTMLButtonElement>("add-person").disabled = model.people.length >= PEOPLE_LIMIT;
}

// --- Les règlements ---------------------------------------------------------------

function renderPayments(): void {
  const body = element<HTMLElement>("payments");
  body.replaceChildren();
  for (const payment of model.payments) {
    const row = document.createElement("tr");
    row.id = `payment-${payment.id}`;
    const date = textInput(`payment-date-${payment.id}`, payment.date, (value) => (payment.date = value), { size: "sharing__date" });
    date.type = "date";
    const who = document.createElement("select");
    who.className = "form__field sharing__select";
    who.id = `payment-person-${payment.id}`;
    for (const person of model.people) {
      const option = document.createElement("option");
      option.value = String(person.id);
      option.textContent = person.name;
      who.append(option);
    }
    who.value = String(payment.person);
    who.addEventListener("change", () => {
      payment.person = Number(who.value);
      compute();
    });
    row.append(
      cell(date),
      cell(who),
      cell(textInput(`payment-amount-${payment.id}`, payment.amount, (value) => (payment.amount = value), { kind: "money", size: "sharing__money" })),
      cell(textInput(`payment-label-${payment.id}`, payment.label, (value) => (payment.label = value))),
      cell(
        deleteButton(t("sharing-delete"), () => {
          model.payments = model.payments.filter((one) => one.id !== payment.id);
        }),
      ),
    );
    body.append(row);
  }
  element<HTMLButtonElement>("add-payment").disabled = model.payments.length >= PAYMENTS_LIMIT || model.people.length === 0;
}

// --- Le partage -------------------------------------------------------------------

function renderSetup(): void {
  field("label").value = model.label;
  field("total").value = model.total;
  const mode = document.querySelector<HTMLInputElement>(`input[name="mode"][value="${model.mode}"]`);
  if (mode) {
    mode.checked = true;
  }
  const rule = element<HTMLSelectElement>("rule");
  rule.replaceChildren();
  for (const key of RULES) {
    const option = document.createElement("option");
    option.value = key;
    option.textContent = t(`sharing-rule-${key}`);
    rule.append(option);
  }
  rule.value = model.rule;
  element<HTMLElement>("rule-line").hidden = model.mode !== "whole";
  field("round-euro").checked = model.rounding === "euro";
  field("hide-incomes").checked = !model.show_incomes;
}

function render(): void {
  renderSetup();
  renderItems();
  renderPeople();
  renderPayments();
  showAdvice();
}

// --- Les mots ---------------------------------------------------------------------

function dress(): void {
  for (const [id, key] of [
    ["question", "sharing-question"],
    ["setup-title", "sharing-setup-title"],
    ["label-label", "sharing-field-label"],
    ["label-hint", "sharing-label-hint"],
    ["total-label", "sharing-field-total"],
    ["total-hint", "sharing-total-hint"],
    ["mode-whole", "sharing-mode-whole"],
    ["mode-item", "sharing-mode-item"],
    ["rule-label", "sharing-field-rule"],
    ["round-euro-label", "sharing-round-euro"],
    ["hide-incomes-label", "sharing-hide-incomes"],
    ["items-title", "sharing-items-title"],
    ["items-hint", "sharing-items-hint"],
    ["column-item", "sharing-column-item"],
    ["column-amount", "sharing-column-amount"],
    ["add-item", "sharing-add-item"],
    ["open", "sharing-open"],
    ["save", "sharing-save"],
    ["pdf-distribution-label", "sharing-pdf-distribution"],
    ["pdf-payments-label", "sharing-pdf-payments"],
    ["statements-label", "sharing-pdf-statements"],
    ["excel", "sharing-excel"],
    ["result-title", "sharing-result-title"],
    ["people-title", "sharing-people-title"],
    ["people-hint", "sharing-people-hint"],
    ["add-person", "sharing-add-person"],
    ["apply-advice", "sharing-apply-advice"],
    ["from-incomes", "sharing-from-incomes"],
    ["reset-percents", "sharing-reset-percents"],
    ["payments-title", "sharing-payments-title"],
    ["payments-hint", "sharing-payments-hint"],
    ["column-date", "sharing-column-date"],
    ["column-who", "sharing-column-who"],
    ["column-paid-amount", "sharing-column-amount"],
    ["column-label", "sharing-column-label"],
    ["add-payment", "sharing-add-payment"],
    ["balances-title", "sharing-balances-title"],
    ["column-unit", "sharing-column-unit"],
    ["column-members", "sharing-column-members"],
    ["column-due", "sharing-column-due"],
    ["column-paid", "sharing-column-paid"],
    ["column-balance", "sharing-column-balance"],
    ["transfers-title", "sharing-transfers-title"],
    ["disclaimer", "sharing-disclaimer"],
  ] as const) {
    element<HTMLElement>(id).textContent = t(key);
  }
  for (const [id, help] of [
    ["column-item", "item"],
    ["rule-label", "rule"],
    ["column-due", "due"],
    ["column-paid", "paid"],
    ["column-balance", "balance"],
  ] as const) {
    withHelp(element<HTMLElement>(id), help);
  }
  for (const [id, key] of [
    ["apply-advice", "sharing-help-apply-advice"],
    ["from-incomes", "sharing-help-from-incomes"],
    ["reset-percents", "sharing-help-reset-percents"],
  ] as const) {
    element<HTMLElement>(id).title = t(key);
  }
  element<HTMLElement>("close").title = t("ui-title-close");
}

// --- Les gestes -------------------------------------------------------------------

asMoneyField(field("total"), { unsigned: true, optional: true });
for (const [id, key] of [
  ["label", "label"],
  ["total", "total"],
] as const) {
  field(id).addEventListener("input", () => {
    model[key] = field(id).value;
  });
  field(id).addEventListener("change", () => {
    model[key] = field(id).value;
    compute();
  });
  field(id).addEventListener("keydown", (event) => {
    if (event.key === "Enter") {
      field(id).blur();
    }
  });
}
for (const radio of document.querySelectorAll<HTMLInputElement>('input[name="mode"]')) {
  radio.addEventListener("change", () => {
    model.mode = radio.value;
    render();
    compute();
  });
}
element<HTMLSelectElement>("rule").addEventListener("change", () => {
  model.rule = element<HTMLSelectElement>("rule").value;
  render();
  compute();
});
field("round-euro").addEventListener("change", () => {
  model.rounding = field("round-euro").checked ? "euro" : "cent";
  compute();
});
field("hide-incomes").addEventListener("change", () => {
  model.show_incomes = !field("hide-incomes").checked;
});

element<HTMLButtonElement>("add-person").addEventListener("click", () => {
  const id = nextId(model.people.map((person) => person.id));
  model.people.push({
    id,
    name: nextName,
    household: "",
    income: "",
    parts: "",
    percent: "",
    floor: "",
    cap: "",
    fixed: "",
    alone: "",
    gift: false,
  });
  for (const item of allItems()) {
    cellOf(item, id);
  }
  render();
  compute();
  field(`name-${id}`).select();
});

// Les conseils : reprendre les valeurs grises, partir des revenus, ou tout
// répartir à nouveau après une personne ajoutée.
element<HTMLButtonElement>("apply-advice").addEventListener("click", () => {
  for (const value of advice.suggested) {
    adopt(value);
  }
  render();
  compute();
});

element<HTMLButtonElement>("from-incomes").addEventListener("click", () => {
  for (const value of advice.from_incomes) {
    adopt(value);
  }
  render();
  compute();
});

element<HTMLButtonElement>("reset-percents").addEventListener("click", () => {
  void (async () => {
    if (!(await askYesNo(t("sharing-reset-percents-question"), t("ui-yes"), t("ui-no")))) {
      return;
    }
    if (model.mode === "whole") {
      for (const person of model.people) {
        person.percent = "";
      }
    } else {
      for (const item of allItems().filter((one) => one.rule === "percent")) {
        for (const one of item.cells) {
          one.value = "";
        }
      }
    }
    // Vidés, les pourcentages se conseillent à parts égales : on les reprend.
    try {
      const fresh = await invoke<Result>("sharing_compute", { input: input() });
      for (const value of fresh.advice?.suggested ?? []) {
        adopt(value);
      }
    } catch (error) {
      say(tError("ui-read-failed", error), true);
    }
    render();
    compute();
  })();
});

element<HTMLButtonElement>("add-item").addEventListener("click", () => {
  const id = nextId(model.items.map((item) => item.id));
  model.items.push({
    id,
    label: "",
    amount: "",
    rule: "equal",
    cells: model.people.map((person) => ({ person: person.id, takes: true, value: "" })),
  });
  render();
  compute();
  field(`label-${id}`).focus();
});

element<HTMLButtonElement>("add-payment").addEventListener("click", () => {
  const id = nextId(model.payments.map((payment) => payment.id));
  model.payments.push({ id, person: model.people[0]?.id ?? 0, amount: "", date: "", label: "" });
  renderPayments();
  field(`payment-amount-${id}`).focus();
});

/// Un nom de fichier sans ce que les systèmes refusent.
const fileName = (text: string): string => text.replace(/[\\/:*?\x22<>|…]/g, "").trim() || "Radinus";
const title = (): string => model.label.trim() || t("window-sharing-title");

element<HTMLButtonElement>("open").addEventListener("click", () => {
  void (async () => {
    if (typed() && !(await askYesNo(t("sharing-replace-question"), t("ui-yes"), t("ui-no")))) {
      return;
    }
    try {
      const opened = await invoke<{ input: Input; message: string } | null>("load_sharing_project");
      if (!opened) {
        return;
      }
      model = { ...blank(), ...opened.input, common: { ...blank().common, ...opened.input.common, id: 0 } };
      last = null;
      render();
      kept = state();
      pending = opened.message;
      say(opened.message);
      compute();
    } catch (error) {
      say(String(error), true);
    }
  })();
});

/// Enregistre le projet là où l'on choisit. Rend vrai s'il est écrit.
async function saveProject(): Promise<boolean> {
  const chosen = await save({
    defaultPath: `${fileName(title())}.json`,
    filters: [{ name: t("sharing-file-filter"), extensions: ["json"] }],
  });
  if (chosen === null) {
    return false;
  }
  try {
    const now = state();
    say(await invoke<string>("save_sharing_project", { input: input(), path: chosen }));
    kept = now;
    return true;
  } catch (error) {
    say(String(error), true);
    return false;
  }
}

element<HTMLButtonElement>("save").addEventListener("click", () => void saveProject());

element<HTMLButtonElement>("excel").addEventListener("click", () => {
  void (async () => {
    const chosen = await save({
      defaultPath: `${fileName(title())}.xlsx`,
      filters: [{ name: "XLSX", extensions: ["xlsx"] }],
    });
    if (chosen === null) {
      return;
    }
    try {
      say(await invoke<string>("export_sharing", { input: input(), path: chosen }));
    } catch (error) {
      say(String(error), true);
    }
  })();
});

for (const [id, kind] of [
  ["pdf-distribution", "distribution"],
  ["pdf-payments", "payments"],
] as const) {
  element<HTMLButtonElement>(id).addEventListener("click", () => {
    void (async () => {
      try {
        say(await invoke<string>("print_sharing_report", { input: input(), kind }));
      } catch (error) {
        say(String(error), true);
      }
    })();
  });
}

/// **Les relevés** : un fichier par foyer — ou celui d'un seul —, dans le
/// dossier choisi. S'il en existe déjà, une seule question pour tous.
element<HTMLButtonElement>("statements").addEventListener("click", () => {
  void (async () => {
    const unit = element<HTMLSelectElement>("statements-unit").value;
    try {
      const picked = await invoke<{ folder: string; question: string | null } | null>("pick_sharing_folder", {
        input: input(),
        unit,
      });
      if (!picked) {
        return;
      }
      if (picked.question && !(await askYesNo(picked.question, t("ui-yes"), t("ui-no")))) {
        return;
      }
      say(await invoke<string>("write_sharing_statements", { input: input(), folder: picked.folder, unit }));
    } catch (error) {
      say(String(error), true);
    }
  })();
});

/// **La porte demande d'abord**, comme celle des autres outils (P-69) :
/// enregistrer le projet, abandonner, rester — posée seulement quand quelque
/// chose serait perdu. Échap reste. Puis elle efface tout et masque la fenêtre.
element<HTMLButtonElement>("close").addEventListener("click", () => {
  void (async () => {
    if (typed() && state() !== kept) {
      const answer = await askThreeWays(
        t("quick-leave-question"),
        t("quick-leave-save"),
        t("quick-leave-discard"),
        t("quick-leave-stay"),
      );
      if (answer === "stay" || (answer === "first" && !(await saveProject()))) {
        return;
      }
    }
    model = blank();
    last = null;
    kept = "";
    render();
    compute();
    void invoke("close_sharing");
  })();
});

void (async () => {
  await loadTexts(null);
  dress();
  render();
  compute();
  onLanguageChanged(
    () => {
      dress();
      render();
      compute();
    },
    { key: "window-sharing-title" },
  );
})();
