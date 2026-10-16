// **Ne lancer que les vérifications d'une fenêtre** (Fabrice, 11/10/2026 :
// « tu reteste l'ensemble du logiciel pour changer cette fenêtre ? »).
//
//   npm run test:ui:only -- F44
//   npm run test:ui:only -- "Objectif" "Préférences"
//
// `windows.test.mjs` est fait de sections qui commencent chacune par un titre
// `// --- …` et vont jusqu'au suivant. Ce lanceur en garde le préambule
// commun, la section qui ouvre toutes les pages — une page qui plante se voit
// partout —, les sections dont le titre contient l'un des mots donnés, et la
// conclusion ; il écrit le tout à côté, le lance, puis l'efface.
//
// **Il ne remplace pas la suite complète** : dès qu'un fichier commun change —
// le filtre des montants, la feuille de style partagée —, c'est elle qu'on lance.

import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const words = process.argv.slice(2).map((word) => word.toLowerCase());
if (words.length === 0) {
  console.error("Donnez au moins un mot du titre d'une section, par exemple : F44");
  process.exit(2);
}

const lines = fs.readFileSync(path.join(here, "windows.test.mjs"), "utf8").split("\n");
const heads = lines.flatMap((line, index) => (line.startsWith("// --- ") ? [index] : []));
const end = lines.findIndex((line) => line.startsWith("await browser.close"));
const smoke = heads.find((index) => lines[index].includes("Toutes les pages s'ouvrent"));

const kept = [...lines.slice(0, heads[0])];
const chosen = [];
heads.forEach((start, rank) => {
  const stop = rank + 1 < heads.length ? heads[rank + 1] : end;
  const title = lines[start].toLowerCase();
  if (start === smoke || words.some((word) => title.includes(word))) {
    kept.push(...lines.slice(start, stop));
    if (start !== smoke) {
      chosen.push(lines[start].replace(/^\/\/ --- /, "").replace(/ -+$/, ""));
    }
  }
});
kept.push(...lines.slice(end));
if (chosen.length === 0) {
  console.error(`Aucune section ne contient « ${words.join(" », « ")} ».`);
  process.exit(2);
}
console.log(`Sections lancées : ${chosen.join(" · ")}`);

const target = path.join(here, ".windows.only.mjs");
fs.writeFileSync(target, kept.join("\n"));
try {
  const run = spawnSync(process.execPath, [target], { stdio: "inherit", env: process.env });
  process.exitCode = run.status ?? 1;
} finally {
  fs.rmSync(target, { force: true });
}
