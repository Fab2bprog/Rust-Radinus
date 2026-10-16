// Le presse-papiers — copier une cellule, copier des lignes.
//
// Fabrice, 07/10/2026, après la remarque d'un utilisateur : « on ne peut pas
// faire de Copier de ligne/cellule dans un tableau ». C'était vrai partout :
// les lignes ne se surlignent pas — cliquer et glisser y prend des lignes, pas
// du texte — et aucune commande ne copiait. Pour sortir un montant d'une
// liste, il fallait l'exporter dans un fichier.
//
// Ce module ne sait rien des tableaux : il écrit un texte dans le
// presse-papiers, et il sait rendre un montant collable. Les tableaux et les
// matrices s'en servent.

/// **Un montant, en nombre pur** (tranché par Fabrice : « en nombre pur »).
///
/// « 1 549,81 € » devient « 1549,81 » ; « -$1,549.81 » devient « -1549.81 ».
/// Le signe monétaire et le groupement des milliers s'en vont, **le séparateur
/// décimal reste celui de la langue** : c'est celui que le tableur de
/// l'utilisateur attend, et c'est ce qui fait qu'il reconnaît un nombre au
/// lieu d'un texte. Un débit garde son signe moins.
///
/// Ce qui n'est pas un montant revient tel quel — un numéro de chèque groupé
/// par trois, une date, un libellé. Un montant se reconnaît à ses deux
/// décimales ; rien d'autre dans Radinus n'en porte.
///
/// **À ne poser que sur une colonne de nombres** : « 3,14 kg » dans un libellé
/// est un libellé, et le resterait mal si cette fonction y passait.
export function pureNumber(text: string): string {
  const read =
    /^([-−]?)\s*([^\d\s\-−+.,]{0,8})\s*([-−]?)(\d[\d\s  .,'’]*)\s*([^\d\s\-−+.,]{0,8})$/u.exec(
      text.trim(),
    );
  if (read === null) {
    return text;
  }
  // Le corps a pu ramasser l'espace qui précède le signe monétaire.
  const body = read[4].replace(/[\s\u00a0\u202f]+$/u, "");
  const decimals = /([.,])(\d{2})$/.exec(body);
  if (decimals === null) {
    return text;
  }
  const whole = body.slice(0, -3).replace(/\D/g, "");
  if (whole === "") {
    return text;
  }
  const minus = read[1] !== "" || read[3] !== "" ? "-" : "";
  return `${minus}${whole}${decimals[1]}${decimals[2]}`;
}

/// Ce qu'une cellule devient dans une ligne copiée : sans tabulation ni saut
/// de ligne, qui sont précisément ce qui sépare les cellules et les lignes —
/// un commentaire sur deux lignes décalerait tout ce qui le suit.
export function oneCell(text: string): string {
  return text.replace(/[\t\r\n]+/g, " ").trim();
}

/// **Écrit un texte dans le presse-papiers.** Rend `false` si rien n'a pu
/// être écrit.
///
/// Deux chemins, parce que Radinus habite trois moteurs — WebKit sur macOS,
/// WebView2 sous Windows, WebKitGTK sous Linux — et qu'aucun des deux chemins
/// n'est sûr dans les trois : l'interface moderne d'abord, qui peut être
/// absente ou refusée ; puis l'ancienne commande de copie, sur une zone de
/// texte posée le temps du geste, que tous exécutent. Les deux demandent
/// d'être appelés pendant un geste de l'utilisateur — un clic, une touche —,
/// ce qui est toujours le cas ici.
export async function copyText(text: string): Promise<boolean> {
  try {
    if (navigator.clipboard?.writeText !== undefined) {
      await navigator.clipboard.writeText(text);
      return true;
    }
  } catch {
    // Refusée : on essaie l'autre chemin.
  }
  return copyTheOldWay(text);
}

function copyTheOldWay(text: string): boolean {
  const area = document.createElement("textarea");
  area.value = text;
  area.setAttribute("readonly", "");
  area.className = "clipboard-scratch";
  area.style.position = "fixed";
  area.style.top = "0";
  area.style.left = "0";
  area.style.opacity = "0";
  document.body.append(area);
  const before = document.activeElement as HTMLElement | null;
  area.select();
  let done = false;
  try {
    done = document.execCommand("copy");
  } catch {
    done = false;
  }
  area.remove();
  before?.focus?.();
  return done;
}
