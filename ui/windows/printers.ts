// Le choix de l'imprimante, partagé par toutes les fenêtres qui impriment.
//
// **Radinus pose la question lui-même.** Le dialogue d'impression du système
// n'est atteignable depuis aucun des trois webviews — c'est tout le sujet de
// la phase 15 — et aucune commande, sur aucun des trois systèmes, ne l'ouvre
// pour un fichier PDF. La fenêtre montre donc la liste avec ses propres
// couleurs, ouverte sur l'imprimante par défaut du poste (demande de Fabrice,
// 01/08/2026).
//
// Ce fichier existe pour que F32 et la liste des opérations posent exactement
// la même question, de la même façon : deux copies auraient divergé.

import { invoke } from "@tauri-apps/api/core";
import { askForChoice } from "./dialog";
import { t } from "./texts";

interface Printer {
  /// Le nom de la file, celui que le système attend.
  name: string;
  /// Le nom lisible, celui que l'on montre. Sous CUPS les deux diffèrent :
  /// « Brother HL-2030 » d'un côté, « Brother_HL_2030 » de l'autre.
  label: string;
  is_default: boolean;
}

/// Ce que l'utilisateur a répondu.
///
/// Trois issues et pas deux : renoncer n'est pas la même chose que ne rien
/// avoir eu à choisir. Un poste dont le système refuse de nommer les
/// imprimantes doit pouvoir imprimer quand même, sur la sortie par défaut.
export type PrinterChoice =
  | { kind: "chosen"; printer: string }
  | { kind: "default" }
  | { kind: "cancelled" };

/// Demande sur quelle imprimante imprimer.
export async function askForPrinter(): Promise<PrinterChoice> {
  const printers = await invoke<Printer[]>("list_printers");
  if (printers.length === 0) {
    return { kind: "default" };
  }
  // On montre le nom lisible et on renvoie le nom de la file : c'est le second
  // que le système attend.
  const chosen = await askForChoice(
    t("print-choose-printer"),
    printers.map((one) => one.label),
    t("print-do-print"),
    t("ui-cancel"),
    printers.find((one) => one.is_default)?.label,
  );
  if (chosen === null) {
    return { kind: "cancelled" };
  }
  return {
    kind: "chosen",
    printer: printers.find((one) => one.label === chosen)?.name ?? chosen,
  };
}
