// L'ordre dans lequel les langues se montrent à l'utilisateur.
//
// Deux fenêtres montrent la même liste : le choix du premier lancement
// (`language-choice.ts`) et les préférences (`preferences.ts`). Elle est ici
// pour qu'elles ne puissent pas la ranger différemment — deux ordres pour une
// même liste serait une petite trahison, et personne ne la verrait avant de
// chercher une langue au mauvais endroit.
//
// **Ce module n'a pas de page.** Il ne dessine rien et ne dit aucune phrase :
// il ne fait que trier, comme `table.ts` ne fait que présenter.

/// **Les langues sont rangées par leur propre nom** (demande de Fabrice,
/// 03/08/2026, en découvrant que la dixième passait sous le bord de la
/// fenêtre). Le noyau les rend dans l'ordre où elles ont été déclarées : celui
/// de l'histoire du logiciel, qui ne dit plus rien à personne dès qu'il y en a
/// dix.
///
/// Le tri est fait ici et non dans le noyau parce qu'il lui faut la collation
/// du système. `localeCompare` range « Čeština » à la lettre C, là où une
/// comparaison de codes de caractères la mettrait après le Z, et « Íslenska »
/// à la lettre I plutôt qu'à la fin. Rust ne sait pas le faire sans une
/// dépendance de plus, et il n'en est pas question pour un ordre d'affichage.
///
/// Le tri se fait **sur place**, sur le tableau reçu du noyau : il n'y a qu'une
/// liste, et rien ne doit pouvoir en garder une copie dans l'autre ordre.
export function sortByOwnName(list: { name: string }[]): void {
  list.sort((a, b) => a.name.localeCompare(b.name));
}
