// La plage d'années (Fabrice, 10/10/2026 : « une option d'année type ou
// moyenne sur une plage d'années »), partagée par la simulation de crédit et
// le matelas de sécurité.
//
// Le menu de la période gagne une dernière entrée, « Plage d'années… », qui
// montre deux listes « de » et « à ». La fenêtre ne fait qu'envoyer les deux
// années ; c'est le noyau qui lit les mois de la plage.

import { t } from "./texts";

const element = <T extends HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

const period = (): HTMLSelectElement => element<HTMLSelectElement>("history");
const from = (): HTMLSelectElement => element<HTMLSelectElement>("range-from");
const to = (): HTMLSelectElement => element<HTMLSelectElement>("range-to");

let filled = false;

function fill(select: HTMLSelectElement, years: number[]): void {
  const chosen = select.value;
  select.replaceChildren();
  for (const year of years) {
    const option = document.createElement("option");
    option.value = String(year);
    option.textContent = String(year);
    select.append(option);
  }
  if (years.some((year) => String(year) === chosen)) {
    select.value = chosen;
  }
}

/// Ajoute « Plage d'années… » au menu de la période — après qu'il a été
/// rempli — et remplit les deux listes. La première fois, la plage couvre les
/// trois dernières années.
export function fillRange(years: number[], kept: string): void {
  const option = document.createElement("option");
  option.value = "range";
  option.textContent = t("goal-period-range");
  period().append(option);
  if (kept === "range") {
    period().value = "range";
  }
  fill(from(), [...years].reverse());
  fill(to(), years);
  if (!filled && years.length > 0) {
    filled = true;
    from().value = String(years[Math.min(2, years.length - 1)]);
    to().value = String(years[0]);
  }
  showRange();
}

/// Les deux listes ne se montrent que pour une plage.
export function showRange(): void {
  element<HTMLElement>("range").hidden = period().value !== "range";
}

/// Les deux bornes, telles que le noyau les attend.
export function rangeRequest(): { from: number; to: number } {
  return { from: Number(from().value) || 0, to: Number(to().value) || 0 };
}

/// Les deux petits mots, et le changement de période ou de borne qui relance
/// le calcul.
export function dressRange(): void {
  element<HTMLElement>("range-from-label").textContent = t("goal-range-from");
  element<HTMLElement>("range-to-label").textContent = t("goal-range-to");
}

export function onRangeChange(recompute: () => void): void {
  period().addEventListener("change", showRange);
  from().addEventListener("change", recompute);
  to().addEventListener("change", recompute);
}
