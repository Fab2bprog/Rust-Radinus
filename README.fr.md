# Radinus 2.0.4

Radinus est un logiciel libre de gestion de finances personnelles (licence GNU
GPL v3 ou ultérieure). La version 2.0.4 est une réécriture multiplateforme
(macOS d'abord) de Radinus 1.9.3, logiciel Windows/WinDev du même auteur.

- **Auteur :** Fabrice Garcia
- **Licence :** GNU GPL v3 ou ultérieure (voir `LICENSE`)
- **Technologie :** [Tauri](https://tauri.app) v2 + Rust, interface web
- **Base de données :** SQLite, fichier unique, portable
- **Journal des versions :** voir `CHANGELOG.md`

## Ce que fait Radinus

Radinus suit plusieurs comptes bancaires, les transactions (avec
sous-opérations et « Complément » automatique), les chèques et chéquiers, les
opérations périodiques, les budgets, six statistiques croisées, un tableau de
bord et une courbe d'évolution des soldes. Ses fonctions les plus stratégiques
sont l'importation de relevés bancaires au format OFX et la migration des
sauvegardes zip de Radinus 1.9.3 (Windows) — deux exigences non négociables
pour les milliers d'utilisateurs existants.

L'application est entièrement **portable** : tout (application, base de
données, paramètres, pièces jointes, journaux) vit dans un même dossier,
utilisable depuis une clé USB, sans aucune écriture en dehors de ce dossier.

## Architecture

Trois couches strictement séparées, dépendances à sens unique
(Vue → Contrôleur → Modèle) :

- **Vue** — interface web (HTML/CSS/TypeScript) reproduisant fidèlement les
  fenêtres d'origine ; aucune logique métier.
- **Contrôleur** — pont Tauri (Rust) squelettique exposant des commandes IPC
  typées.
- **Modèle** — `radinus-core`, bibliothèque Rust indépendante portant toutes
  les règles de gestion, l'accès SQLite, les imports/exports, la sauvegarde et
  la réparation. Compilable et testable seule, sans aucun framework.

La spécification fonctionnelle complète — modèle de données, charte
graphique, spécifications de fenêtres, décisions d'architecture — vit dans le
dossier de rétro-ingénierie de l'auteur, en dehors de ce dépôt. Les règles
sous lesquelles ce code est écrit sont résumées dans `CONTRIBUTING.md`.

## Développement

Nécessite Rust et Node.js. Rust et Xcode sont supposés installés sur le Mac du
développeur.

```bash
npm install
npm run tauri dev
```

Avant toute livraison :

```bash
npm run build
cargo test --workspace
cargo clippy --workspace --all-targets
```

Aucune phase ne démarre avant que le jalon de la phase précédente n'ait été
validé par l'auteur sur sa propre machine.

## Contribuer

Ce dépôt est pour l'instant privé et sous la seule direction de son auteur.
Aucune contribution externe n'est acceptée à ce stade. Les règles sous
lesquelles ce code est écrit sont dans `CONTRIBUTING.md` — à lire avant d'y
toucher, y compris dans six mois.
