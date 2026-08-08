// Which nomenclature a window is working on.
//
// The two windows are one gabarit each (04_SPECIFICATIONS_FENETRES.md: "gabarit
// identique pour les fiches Affectation, Mode, Tiers, Projet, Poste
// budgétaire, Banque — sans le champ Poste budgétaire", and the same for the
// lists). Which one is showing arrives in the window's address.
//
// **No word lives here.** There used to be a table of nouns and genders, so
// that « Aucune catégorie » and « Aucun tiers » could be assembled from
// pieces. That is right in French and wrong in the next language, and it
// taught the code that a feminine exists. Whole sentences now live in
// `radinus-core`'s Fluent resources, one branch per nomenclature, in both
// languages (author's ruling, 25/07/2026).

/// The seven keys a window may work on. Kept here only to refuse an eighth:
/// a window working on a nomenclature that does not exist would ask Rust for
/// a table that does not exist either.
const KINDS = [
  "category",
  "assignment",
  "payment-mode",
  "payee",
  "project",
  "budget-line",
  "bank",
];

/// Only the category carries a budget line (02_BASE_DE_DONNEES.md §3.10), and
/// it is the only reason the shared fiche ever shows a second field.
export const BUDGET_LINE_OWNER = "category";

/// The nomenclature this window works on, taken from its address. An unknown
/// one is not guessed at: a window working on the wrong table would write in
/// the wrong place without ever complaining.
export function currentKind(): string {
  const kind = new URLSearchParams(window.location.search).get("kind") ?? "";
  if (!KINDS.includes(kind)) {
    // Said out loud before giving up, and in the only language available at
    // this point: the dictionary is fetched *for* a nomenclature, and there
    // is none. A window that fails while loading shows nothing at all
    // otherwise — the very fault of a delivery that looked perfect and did
    // nothing (25/07/2026).
    const bar = document.getElementById("info-bar");
    if (bar) {
      bar.textContent = `Nomenclature inconnue / unknown nomenclature : « ${kind} »`;
      bar.classList.add("info-bar--alert");
    }
    throw new Error(`unknown nomenclature: ${kind}`);
  }
  return kind;
}
