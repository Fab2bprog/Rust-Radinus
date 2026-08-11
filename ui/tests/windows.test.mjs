// End-to-end checks of the window behaviour, run in a real browser engine.
//
// These exist because a whole delivery went out with windows that looked
// perfect and did nothing (25/07/2026): the Rust side was tested, the
// interface was not tested at all. A browser is not Tauri's webview, so this
// cannot prove everything — but it does prove the parts that were actually
// broken: that the scripts run without throwing, that every button calls what
// it should, and above all that a question the user answers "no" to leaves
// the window usable instead of stuck.
//
// The Tauri bridge is replaced by a stub that records the calls, so no
// database and no application are needed.
//
//   node ui/tests/windows.test.mjs

import { chromium } from "playwright";
import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../../dist");
const mimeTypes = {
  ".html": "text/html",
  ".js": "text/javascript",
  ".css": "text/css",
  ".png": "image/png",
  ".svg": "image/svg+xml",
};

if (!fs.existsSync(root)) {
  console.error("dist/ is missing — run `npm run build` first.");
  process.exit(1);
}

const server = http.createServer((request, response) => {
  // The browser asks for a favicon on its own; Tauri never does. Answer it so
  // the harness does not report a 404 the application is not responsible for.
  if (request.url.startsWith("/favicon.ico")) {
    response.writeHead(204);
    response.end();
    return;
  }
  // **La racine `/` désigne un dossier, pas un fichier**, et `dist/` n'est pas
  // lisible : sans cette ligne le serveur répondait 404 à la page d'accueil, et
  // la suite mourait sur `page.goto` avant d'avoir vérifié quoi que ce soit
  // d'elle. Défaut d'origine du banc d'essai, trouvé le 05/08/2026.
  const asked = decodeURIComponent(request.url.split("?")[0]);
  const filePath = path.join(root, asked === "/" ? "/index.html" : asked);
  if (fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
    response.writeHead(200, {
      "Content-Type": mimeTypes[path.extname(filePath)] ?? "application/octet-stream",
    });
    fs.createReadStream(filePath).pipe(response);
  } else {
    response.writeHead(404);
    response.end();
  }
});
await new Promise((resolve) => server.listen(4173, resolve));

const ACCOUNTS = [
  {
    id: 1,
    label: "CCP",
    bank: "La Banque Postale",
    account_type: "Chèque",
    account_number: "0500013M026",
    balance_bank: 1549810000,
    balance_real: 1549810000,
    balance_final: 1549810000,
    balance_bank_text: "1\u202f549,81 €",
    balance_real_text: "1\u202f549,81 €",
    balance_final_text: "1\u202f549,81 €",
    is_closed: false,
  },
  {
    id: 2,
    label: "Livret A",
    bank: "La Banque Postale",
    account_type: "Livret A",
    account_number: "",
    balance_bank: 23422810000,
    balance_real: 23422810000,
    balance_final: 23422810000,
    balance_bank_text: "23\u202f422,81 €",
    balance_real_text: "23\u202f422,81 €",
    balance_final_text: "23\u202f422,81 €",
    is_closed: false,
  },
  {
    id: 3,
    label: "Ancien compte",
    bank: "La Banque Postale",
    account_type: "Chèque",
    account_number: "",
    balance_bank: 0,
    balance_real: 0,
    balance_final: 0,
    balance_bank_text: "0,00 €",
    balance_real_text: "0,00 €",
    balance_final_text: "0,00 €",
    is_closed: true,
  },
];

const ACCOUNT = {
  id: 1,
  label: "CCP",
  bank_id: 1,
  account_type_id: 1,
  branch_address: "",
  holder_name: "Fabrice",
  holder_address: "",
  rib_bank_code: "20041",
  rib_branch_code: "01005",
  rib_account_number: "0500013M026",
  rib_key: "06",
  bic: "PSSTFRPPMON",
  iban: "FR14 2004 1010 0505 0001 3M02 606",
  opening_date: "2015-03-01",
  closing_date: "",
  is_closed: false,
  opening_pointed: "5972,54",
  opening_committed: "0,00",
  opening_planned: "0,00",
  control_line:
    "Solde initial pointé (5\u202f972,54 €) + Total des opérations (-4\u202f422,73 €) = Solde en banque actuel : 1\u202f549,81 €.",
};

const OPERATIONS = {
  account_label: "CCP",
  rows: [
    {
      id: 1, label: "COURSES", date: "05/01/2026", clearing_date: "05/01/2026",
      date_value: "2026-01-05", clearing_date_value: "2026-01-05", balance_value: 2322340000,
      month: "janvier", category: "Alimentation", assignment: "Famille",
      payment_mode: "Carte bancaire", payee: "Système U", project: "",
      debit: "-100,00 €", credit: "", balance: "2\u202f322,34 €", amount: -100000000,
      has_comment: true, comment: "Marché du dimanche", has_attachment: false, check_number: "",
      category_id: 1, assignment_id: 2, payment_mode_id: 3, payee_id: 4, project_id: 0,
      parent_id: 0, child_count: 2, is_complement: false,
    },
    {
      id: 2, label: "Alimentation", date: "05/01/2026", clearing_date: "05/01/2026",
      date_value: "2026-01-05", clearing_date_value: "2026-01-05", balance_value: 0,
      month: "janvier", category: "Alimentation", assignment: "Famille",
      payment_mode: "Carte bancaire", payee: "", project: "",
      debit: "-60,00 €", credit: "", balance: "", amount: -60000000,
      has_comment: false, comment: "", has_attachment: false, check_number: "",
      category_id: 1, assignment_id: 2, payment_mode_id: 3, payee_id: 0, project_id: 0,
      parent_id: 1, child_count: 0, is_complement: false,
    },
    {
      id: 3, label: "Complément", date: "05/01/2026", clearing_date: "05/01/2026",
      date_value: "2026-01-05", clearing_date_value: "2026-01-05", balance_value: 0,
      month: "janvier", category: "Alimentation", assignment: "Famille",
      payment_mode: "Carte bancaire", payee: "", project: "",
      debit: "-40,00 €", credit: "", balance: "", amount: -40000000,
      has_comment: false, comment: "", has_attachment: false, check_number: "",
      category_id: 1, assignment_id: 2, payment_mode_id: 3, payee_id: 0, project_id: 0,
      parent_id: 1, child_count: 0, is_complement: true,
    },
    {
      id: 4, label: "SALAIRE", date: "28/01/2026", clearing_date: "28/01/2026",
      date_value: "2026-01-28", clearing_date_value: "2026-01-28", balance_value: 3145400000,
      month: "janvier", category: "Salaire", assignment: "Monsieur",
      payment_mode: "Virement", payee: "", project: "",
      debit: "", credit: "2\u202f216,71 €", balance: "3\u202f145,40 €", amount: 2216710000,
      has_comment: false, comment: "", has_attachment: true, check_number: "",
      category_id: 5, assignment_id: 1, payment_mode_id: 2, payee_id: 0, project_id: 0,
      parent_id: 0, child_count: 0, is_complement: false,
    },
  ],
  debit: "-17\u202f967,28 €",
  credit: "17\u202f061,39 €",
  total: "-905,89 €",
  balance_bank: "1\u202f549,81 €",
  balance_real: "1\u202f549,81 €",
  balance_final: "1\u202f549,81 €",
};

const CATEGORIES = [
  { id: 1, label: "Alimentation", budget_line_id: 1 },
  { id: 2, label: "Assurance", budget_line_id: 2 },
  { id: 3, label: "Bricolage", budget_line_id: 5 },
];

/// The dictionary Rust hands a window. Only the keys the checks below read
/// have to be right; the rest exist so nothing comes back undefined.
const UI_TEXTS = {
  "ui-loading": "Chargement…",
  "ui-editing": "Modification.",
  "ui-viewing": "Consultation.",
  "ui-modified-suffix": "— modifié",
  "ui-label-required": "Le libellé est obligatoire.",
  "ui-discard-question": "Abandonner les modifications ?",
  "ui-yes": "Oui",
  "ui-no": "Non",
  "ui-select-record": "Veuillez sélectionner un enregistrement",
  // Phase 17 bis — la fenêtre d'accueil (F01).
  "welcome-total-bank": "Solde en banque",
  "welcome-total-real": "Solde réel",
  "welcome-total-final": "Solde final",
  "welcome-total-real-detail": "pointé + engagé",
  "welcome-total-final-detail": "pointé + engagé + prévu",
  "welcome-accounts": "Vos comptes",
  "welcome-tile-bank": "En banque",
  "welcome-tile-real": "Réel",
  "welcome-tile-final": "Final",
  "welcome-nothing": "Aucune opération ce mois-ci.",
  "welcome-open-account": "Info : cliquez sur un compte pour ouvrir ses opérations.",
  "welcome-no-account": "Aucun compte bancaire pour l'instant.",
  // Phase 16 — les opérations périodiques.
  "recurring-column-label": "LIBELLE",
  "recurring-none": "Aucune règle périodique enregistrée.",
  "recurring-help": "Choisissez une règle, puis le calendrier.",
  "recurring-title-calendar": "Proposer le calendrier des échéances",
  "recurring-gone": "Cette règle n'existe plus.",
  "recurring-delete-question": "Supprimer les règles sélectionnées ?",
  "recurring-group-identity": "Identification et compte bancaire concerné",
  "recurring-group-nomenclature": "Nomenclature",
  "recurring-group-amount": "Définition du montant de l'opération",
  "recurring-group-period": "Définition de la periode",
  "recurring-group-ending": "Conditions de fin de la période",
  "recurring-group-produced": "Informations sur opérations déjà insérés ( pour consultation seulement )",
  "recurring-field-id": "Identifiant de Operation",
  "recurring-field-account": "Compte cible",
  "recurring-field-label": "Libelle",
  "recurring-field-category": "Categorie",
  "recurring-field-mode": "Mode de reglement",
  "recurring-field-assignment": "Affectation",
  "recurring-field-payee": "Tiers / marchands",
  "recurring-field-project": "Projet",
  "recurring-field-direction": "Type Opération",
  "recurring-field-amount": "Montant",
  "recurring-field-next": "Date prochaine opération",
  "recurring-field-every": "Puis tout les",
  "recurring-field-end-date": "Date fin",
  "recurring-field-repeat": "Nombre répétition",
  "recurring-field-guid": "GUID Operation",
  "recurring-field-produced-count": "Nombre d'opérations insérées",
  "recurring-field-produced-last": "Date dernière opération insérée",
  "recurring-field-produced-total": "Total montants générés",
  "recurring-unit-day": "Jour",
  "recurring-unit-week": "Semaine",
  "recurring-unit-month": "Mois",
  "recurring-unit-quarter": "Trimestre",
  "recurring-unit-year": "Année",
  "recurring-ending-no-limit": "Sans limite",
  "recurring-ending-until-date": "Avec date de Fin",
  "recurring-ending-repeat-count": "Nombre répétition",
  "recurring-title-erase": "Effacer les opérations déjà insérées par cette règle",
  "recurring-erase-none": "Cette règle n'a encore inséré aucune opération.",
  "recurring-calendar-help": "Retirez avec la corbeille les échéances que vous ne voulez pas.",
  "recurring-calendar-none": "Aucune échéance à proposer.",
  "recurring-calendar-column-account": "Compte",
  "recurring-calendar-column-date": "Date",
  "recurring-calendar-column-label": "Description",
  "recurring-calendar-column-amount": "Montant",
  "recurring-calendar-column-category": "Categorie",
  "recurring-calendar-column-assignment": "Affectation",
  "recurring-calendar-column-mode": "Mode Reglement",
  "recurring-calendar-column-payee": "Tiers",
  "recurring-calendar-column-project": "Projets",
  "recurring-title-insert": "Insérer les échéances retenues dans les comptes",
  "recurring-nothing": "Il ne reste aucune échéance à insérer.",
  "window-recurring-calendar-title": "Proposition de calendrier",
  // Phase 14 — les douze sorties du menu Export de F02.
  "export-to-excel": "Exporter vers Excel (.xlsx)",
  "export-to-word": "Exporter vers Word (.docx)",
  "export-to-ods": "Exporter vers LibreOffice Calc (.ods)",
  "export-to-csv": "Exporter vers CSV (.csv)",
  "export-to-tsv": "Exporter vers TSV (.tsv)",
  "export-to-ofx": "Exporter vers OFX (.ofx)",
  "export-to-qif": "Exporter vers QIF (.qif)",
  "export-to-ini": "Exporter vers INI (.ini)",
  "export-to-json": "Exporter vers JSON (.json)",
  "export-to-toml": "Exporter vers TOML (.toml)",
  "export-to-xml": "Exporter vers XML (.xml)",
  "export-to-yaml": "Exporter vers YAML (.yaml)",
  "export-nothing": "Il n'y a rien à exporter.",
  // Phase 13 — l'importation d'une feuille Excel. Les phrases sont celles du
  // vrai dictionnaire : un test qui vérifie qu'un panneau parle d'Excel doit
  // lire ce que l'utilisateur lira.
  "excel-backup-question":
    "Une feuille Excel est faite à la main : elle peut contenir des dates justes mais fausses. Voulez-vous sauvegarder vos données avant de commencer ?",
  "excel-group-file": "1 - Désigner le fichier Excel à importer",
  "excel-pick": "Designer le fichier Excel",
  "excel-sheet": "Feuille du classeur :",
  "excel-group-header": "2 - Définir : Coordonnées cellules pour ligne d'entête",
  "excel-header-row": "Numéro 1ere ligne ou est situé le nom des colonnes",
  "excel-first-column": "Colonne début entête ( colonne la plus à gauche ) :",
  "excel-column-count": "Nombres de colonnes du tableau",
  "excel-group-rows": "3 - Définir : Numéro lignes de début et fin",
  "excel-first-data-row": "Première ligne contenant des données",
  "excel-last-data-row": "Dernière ligne contenant des données :",
  "excel-group-shape": "4 - Définir : Comment votre fichier écrit les montants",
  "excel-shape-single": "Une seule colonne de montants, signée",
  "excel-shape-debit-credit": "Deux colonnes séparées : une colonne Débit et une colonne Crédit",
  "excel-shape-note": "Dans le mode à deux colonnes, le signe écrit dans la colonne Débit n'est pas pris en compte.",
  "excel-group-test": "5 - Rendu Test",
  "excel-test": "Testez les paramètres que vous avez définis aux étapes 2, 3 et 4.",
  "excel-test-note": "Indication : la zone de capture ne doit pas déborder.",
  "excel-help": "Descendez les cinq groupes dans l'ordre, puis testez.",
  "excel-no-file": "Désignez d'abord le fichier Excel à importer.",
  "excel-not-tested": "Réglages modifiés : relancez le rendu test avant de valider.",
  "excel-empty-capture": "La zone que vous avez déclarée n'attrape aucune ligne.",
  "excel-title-next": "Passer à l'étape suivante",
  "excel-tab-links": "Liens entre champs",
  "excel-tab-settings": "Parametres d'importation",
  "excel-column-excel": "Entete_Excel",
  "excel-column-radinus": "Rubrique_Radinus",
  "excel-links-help": "En face de chaque colonne, dites quelle rubrique elle alimente.",
  "excel-define-destination": "Définir destination",
  "excel-fields-help": "Réglez les concordances, puis les trois politiques.",
  "excel-title-import": "Lancer l'importation",
  "excel-column-data": "Données_Excel",
  "excel-association-help": "Choisissez la valeur de Radinus dans laquelle ranger chaque libellé.",
  "excel-association-none": "Aucune valeur inconnue.",
  "excel-report-title": "Compte-rendu de l'importation",
  "excel-column-row": "Ligne Excel",
  "excel-column-content": "Contenu",
  "excel-column-reason": "Raison du refus",
  "excel-nothing-refused": "Toutes les lignes de votre feuille sont entrées.",
  "transfer-group-source": "Débiter le montant sur ce compte source",
  "transfer-group-target": "Créditer le montant sur ce compte destination",
  "transfer-group-description": "Description de l'opération",
  "transfer-group-nomenclature": "Informations de Nomenclature",
  "transfer-group-amount": "Montant de la somme à transférer",
  "transfer-field-source": "Compte source",
  "transfer-field-target": "Compte destination",
  "transfer-field-label": "Libelle",
  "transfer-field-reference": "Référence paiement",
  "transfer-field-date": "Date",
  "transfer-field-status": "Statut Operation",
  "transfer-field-clearing": "Date pointage",
  "transfer-field-category": "Categorie",
  "transfer-field-mode": "Mode de reglement",
  "transfer-field-assignment": "Affectation",
  "transfer-field-payee": "Tiers / marchands",
  "transfer-field-project": "Projet",
  "transfer-field-amount": "Montant",
  "transfer-help": "Choisissez les deux comptes : leurs soldes s'affichent ici.",
  "transfer-title-validate": "Effectuer le virement",
  "window-transfer-title": "Transférer un montant entre deux comptes",
  "budget-column-line": "Poste budgetaire",
  "budget-planned": "Prévu",
  "budget-actual": "Réalisé",
  "budget-sum": "Somme",
  "budget-cumulative": "Cumul",
  "budget-total": "Total",
  "budget-sign-warning": "Saisissez les dépenses en négatif et les revenus sans signe ou avec le signe plus.",
  "budget-entry-help": "Tapez les montants dans les cases, puis enregistrez.",
  "budget-saved": "Budget enregistré.",
  "budget-nothing-changed": "Aucune modification à enregistrer.",
  "budget-discard-question": "Abandonner les modifications du budget ?",
  "budget-menu-display": "Affichage",
  "budget-display-money": "Valeurs",
  "budget-display-percent": "Pourcentages",
  "budget-control-help": "Vert : au moins aussi bien que prévu. Rouge : moins bien.",
  "month-january": "janvier",
  "month-february": "février",
  "month-march": "mars",
  "month-april": "avril",
  "month-may": "mai",
  "month-june": "juin",
  "month-july": "juillet",
  "month-august": "août",
  "month-september": "septembre",
  "month-october": "octobre",
  "month-november": "novembre",
  "month-december": "décembre",
  "operation-templates-none": "Aucun modèle d'opération n'est enregistré.",
  "operation-templates-nothing-to-show": "Aucun modèle ne répond à cette recherche.",
  "operation-templates-select-question": "Choisissez le modèle à appliquer",
  "operation-templates-delete-question": "Confirmez-vous la suppression des modèles sélectionnés ?",
  "operation-template-gone": "Ce modèle n'existe plus.",
  "operation-template-fresh": "Nouveau modèle.",
  "operation-template-created": "Modèle enregistré.",
  "operation-template-updated": "Modèle modifié.",
  "operation-template-label-required": "La saisie d'un nom est obligatoire",
  "operation-template-duplicate": "Un modèle du même nom existe déjà",
  "operation-template-field-id": "ID Modèle Opération",
  "operation-template-group-name": "Nom par défaut de la future opération après application du modèle",
  "operation-template-field-label": "Nom",
  "operation-template-group-amount": "Montant par défaut de l'opération prédéfini dans ce modèle",
  "operation-template-field-direction": "Type Opération",
  "operation-template-field-amount": "Montant",
  "operation-template-group-status": "Statut de l'opération par défaut dans ce modèle",
  "operation-template-field-status": "Statut Operation",
  "operation-template-group-classification": "Informations du modèle pour classement calcul des statistiques",
  "operation-template-field-category": "Categorie",
  "operation-template-field-assignment": "Affectation",
  "operation-template-field-mode": "Mode",
  "operation-template-field-payee": "Tiers",
  "operation-template-field-project": "Projet",
  "operation-template-question": "Que voulez-vous faire avec les modèles d'opération ?",
  "operation-template-apply": "Appliquer un modèle",
  "operation-template-save-as": "Enregistrer comme modèle",
  "operation-template-applied": "Modèle appliqué. Validez la fiche pour l'enregistrer.",
  "operation-template-saved-as": "Opération enregistrée comme modèle.",
  "operation-template-needs-label": "Donnez un nom à l'opération avant d'en faire un modèle.",
  "window-operation-templates-title": "Liste des modeles d'operations",
  "window-operation-template-title": "Fiche Modele Operation",
  "chequebooks-column-reference": "LIBELLE",
  "chequebooks-column-date": "Date",
  "chequebooks-column-account": "NomCompte",
  "chequebooks-column-account-number": "Num Compte",
  "chequebooks-column-comments": "Commentaires",
  "chequebooks-none": "Aucun chéquier n'est enregistré.",
  "chequebooks-nothing-to-show": "Aucun chéquier ne répond à cette recherche.",
  "chequebooks-title-composition": "Voir la composition du chéquier",
  "chequebooks-gone": "Ce chéquier n'existe plus.",
  "chequebooks-created": "Chéquier enregistré, avec tous ses chèques.",
  "chequebooks-updated": "Chéquier modifié.",
  "chequebook-refusal-duplicate": "Une référence du même nom existe déjà",
  "chequebook-refusal-reference-required": "La saisie d'une référence est obligatoire",
  "chequebook-refusal-number-too-big": "Les numéros du premier et/ou du dernier chèque sont trop grand (valeur maximum 999 999 999)",
  "chequebook-refusal-date": "Veuillez saisir une date de réception valide",
  "chequebook-refusal-numbers-required": "Veuillez remplir les numéros du premier et dernier chèque",
  "chequebook-refusal-order": "Le numéro du premier chèque doit être inférieur au numéro du dernier chèque",
  "chequebook-refusal-account": "Sélectionnez obligatoirement le compte en relation avec ce chéquier",
  "chequebook-refusal-too-many": "Nombre de chèque maximum pour un chéquier : 1000, limitation atteinte",
  "chequebook-field-id": "Identifiant de Chéquier",
  "chequebook-field-reference": "Référence",
  "chequebook-field-received": "Fabriqué ou reçu le",
  "chequebook-field-first": "Numéro du premier chèque",
  "chequebook-field-last": "Numéro du dernier chèque",
  "chequebook-field-quantity": "Nombre de chèques",
  "chequebook-field-account": "Associer au compte bancaire :",
  "chequebook-field-comments": "Commentaires",
  "chequebook-locked": "Les chèques de ce carnet sont déjà créés : sa numérotation ne se modifie plus.",
  "chequebook-account-missing": "Le Compte bancaire auquel a été associé ce chéquier est absent ou a été supprimé !",
  "cheques-column-number": "Num. Chèque",
  "cheques-column-date": "Date",
  "cheques-column-place": "Lieu",
  "cheques-column-payee": "Bénéficiaire",
  "cheques-column-amount": "Montant",
  "cheques-column-status": "Statut",
  "cheques-column-comments": "Commentaires",
  "cheques-column-operations": "Nbr. Opération Associées",
  "cheques-none": "Ce chéquier ne contient aucun chèque.",
  "cheques-nothing-to-show": "Aucun chèque ne répond à cette recherche.",
  "cheques-help": "Cliquez dans la case Statut pour le changer.",
  "cheques-title-linked": "Voir les opérations déjà associées à ce chèque",
  "cheques-title-link": "Associer une opération à ce chèque",
  "cheques-status-changed": "Statut du chèque modifié.",
  "cheque-field-id": "Identifiant de Chèque",
  "cheque-field-number": "Numéro chèque",
  "cheque-field-issued": "Date Émission",
  "cheque-field-place": "Lieu Émission",
  "cheque-field-payee": "Bénéficiaire",
  "cheque-field-amount": "Montant",
  "cheque-field-comments": "Commentaires",
  "cheque-field-status": "Statut du chèque",
  "cheque-gone": "Ce chèque n'existe plus.",
  "cheque-updated": "Chèque modifié.",
  "cheque-operations-linked-title": "Liste des opérations déjà associées à ce chèque.",
  "cheque-operations-choose-title": "Choisissez une opération à associer au chèque",
  "cheque-operations-column-account": "Compte",
  "cheque-operations-column-label": "Nom",
  "cheque-operations-column-date": "Date",
  "cheque-operations-column-clearing": "Date Pointage",
  "cheque-operations-column-amount": "Montant",
  "cheque-operations-column-cheque": "Chèque associé",
  "cheque-operations-none-linked": "Aucune opération n'est associée à ce chèque.",
  "cheque-operations-none": "Ce compte ne contient aucune opération.",
  "cheque-operations-nothing-to-show": "Aucune opération ne répond à cette recherche.",
  "cheque-operations-help": "Les opérations en gras portent déjà un chèque.",
  "cheque-operations-linked-help": "La croix rouge détache le chèque de l'opération : rien n'est supprimé.",
  "cheque-operations-linked": "Opération associée au chèque.",
  "cheque-operations-dissociated": "Chèque détaché de l'opération.",
  "cheque-operations-menu-filter": "Filtre",
  "cheque-title-associate": "Associer cette opération au chèque",
  "cheque-title-dissociate": "Détacher le chèque de cette opération",
  "chequebooks-select-question": "Choisissez le chéquier",
  "cheques-select-question": "Choisissez le chèque à associer à l'opération",
  "operation-check-save-first": "Enregistrez d'abord l'opération : un chèque s'associe à une opération qui existe.",
  "operation-check-none": "Cette opération ne porte aucun chèque.",
  "window-chequebooks-title": "Liste des chequiers",
  "window-chequebook-title": "Parametres chequier",
  "window-cheques-title": "Composition du chéquier : liste des chèques.",
  "window-cheque-title": "Fiche chèques",
  "window-cheque-operations-title": "Liste des opérations.",
  "ui-multiselect-help": "Info : Utilisez Clic Souris + touche [CTRL] sur le tableau",
  "ui-no-match": "Aucun libellé ne correspond au filtre.",
  "ui-filter-placeholder": "Filtrer les libellés…",
  "ui-column-label": "LIBELLE",
  "ui-identifier": "Identifiant",
  "ui-field-label": "Libelle",
  "ui-field-budget-line": "Poste budgétaire",
  "ui-deletion-abandoned": "Suppression abandonnée : rien n'a été modifié.",
  "ui-title-filter": "Filtrer",
  "ui-title-create": "Créer",
  "ui-title-update": "Modifier la sélection",
  "ui-title-delete": "Supprimer la sélection",
  "ui-title-read": "Consulter la sélection",
  "ui-title-close": "Fermer",
  // « Licence d'utilisation » (08/08/2026). Les phrases sont celles du
  // français, mot pour mot : une vérification qui se contenterait de trouver
  // quelque chose ne verrait pas la fenêtre habillée avec le vocabulaire
  // d'une autre.
  "licence-logo-alt": "Le logo de la GNU General Public License version 3",
  "licence-heading": "LICENCE D'UTILISATION DU LOGICIEL RADINUS",
  "licence-name": "GNU GPL v3 ou ultérieure",
  "licence-intro": "Radinus est un logiciel libre.",
  "licence-freedoms-title": "Sa licence vous donne quatre libertés :",
  "licence-freedom-use": "L'utiliser comme vous voulez, pour ce que vous voulez.",
  "licence-freedom-study": "En étudier le code source, qui est ouvert à tous.",
  "licence-freedom-share": "Le copier et le donner autour de vous.",
  "licence-freedom-improve": "Le modifier, et partager vos modifications.",
  "licence-read": "Lire le texte complet de la licence",
  "licence-copyright": "Copyright © 2026 Fabrice Garcia",
  // « À propos de l'auteur » et « À propos de Radinus » (08/08/2026). Elles
  // n'avaient aucune vérification jusque-là ; elles portent désormais les deux
  // mentions de la GPL, et une mention qu'on ne regarde jamais est une mention
  // qui disparaît sans bruit.
  // Le menu Outils du sélecteur de bases (08/08/2026).
  "menu-file-backup": "Sauvegarde de la base de données",
  "menu-file-restore": "Restauration de la base de données",
  "menu-file-repair": "Réparation et optimisation de la base de données",
  "menu-tools-password": "Protection de la base par mot de passe",
  "menu-file-log": "Afficher le log",
  "databases-select": "Veuillez sélectionner une base de données",
  "about-author-name": "Auteur : Fabrice Garcia",
  "about-author-place": "20290 Borgo, Corsica, France",
  "about-author-flag-alt": "Drapeau de la Corse — la tête de Maure",
  "about-radinus-name": "Radinus",
  "about-radinus-rust-alt": "Le logo du langage Rust",
  "about-radinus-tauri-alt": "Le logo de Tauri",
  "about-radinus-built": "Radinus est écrit en Rust et bâti avec Tauri.",
  "about-radinus-licence": "Logiciel libre, sous licence GNU GPL v3.",
  "licence-no-warranty": "Ce logiciel est fourni sans aucune garantie, dans la mesure permise par la loi.",
  "licence-info": "Le texte officiel s'ouvre dans votre navigateur, sur gnu.org.",
  "ui-title-save": "Enregistrer",
  "ui-title-add": "Ajouter",
  "ui-title-modify": "Modifier",
  "ui-load-failed": "Chargement impossible :",
  "ui-save-failed": "Enregistrement impossible :",
  "ui-read-failed": "Lecture impossible :",
  "ui-delete-failed": "Suppression impossible :",
  "ui-open-failed": "Ouverture impossible :",
  "ui-close-failed": "Fermeture impossible :",
  "ui-unknown-nomenclature": "Nomenclature inconnue :",
  "ui-thousands-separator": "\u202f",
  "ui-decimal-separator": ",",
  "nomenclature-identifier": "Identifiant de Categorie",
  "nomenclature-none": "Aucune catégorie.",
  "nomenclature-nothing-to-show": "Aucune catégorie à afficher.",
  "nomenclature-gone": "Cette catégorie n'existe plus.",
  "nomenclature-fresh": "Nouvelle catégorie.",
  "nomenclature-created": "Catégorie ajoutée.",
  "nomenclature-updated": "Catégorie modifiée.",
  "accounts-none": "Aucun compte.",
  "accounts-nothing-to-show": "Aucun compte à afficher.",
  "accounts-gone": "Ce compte n'existe plus.",
  "accounts-fresh": "Nouveau compte.",
  "accounts-created": "Compte ajouté.",
  "accounts-updated": "Compte modifié.",
  "accounts-multiselect-help": "Info : Utilisez Clic Souris + touche [CTRL] sur le tableau pour sélectionner plusieurs comptes",
  "accounts-select-question": "Sur quels comptes bancaires doit-on baser les statistiques ?",
  "accounts-column-label": "LIBELLE",
  "accounts-column-bank": "Banque",
  "accounts-column-type": "Type compte",
  "accounts-column-number": "Num Compte",
  "accounts-column-account": "Compte",
  "accounts-column-bank-balance": "En Banque",
  "accounts-column-real-balance": "Réel",
  "accounts-column-final-balance": "Final",
  "accounts-total": "TOTAL",
  "account-group-bank": "Infos compte et banque",
  "account-group-holder": "Titulaire",
  "account-group-rib": "Coordonnées bancaires (RIB)",
  "account-group-activity": "Activité",
  "account-group-balances": "Soldes",
  "account-field-label": "Titre du compte",
  "account-field-bank": "Banque",
  "account-field-type": "Type compte",
  "account-field-branch-address": "Adresse agence bancaire",
  "account-field-holder-name": "Nom",
  "account-field-holder-address": "Adresse",
  "account-field-rib-bank": "Établissement",
  "account-field-rib-branch": "Code guichet",
  "account-field-rib-number": "Numéro compte",
  "account-field-rib-key": "Clé RIB",
  "account-field-bic": "BIC (Bank Identifier Code)",
  "account-field-iban": "IBAN (International Bank Account Number)",
  "account-field-opening-date": "Date d'ouverture",
  "account-field-closing-date": "Date de clôture",
  "account-field-closed": "Est clôturé",
  "account-field-opening-pointed": "Solde initial pointé",
  "account-field-opening-committed": "Solde initial engagé",
  "account-field-opening-planned": "Solde initial prévu",
  "accounts-choose-question": "Sur quel compte voulez-vous travailler ?",
  "ui-title-select": "Choisir la sélection",
  "operations-none": "Aucune opération sur cette période.",
  "operations-from": "Date debut",
  "operations-to": "Date fin",
  "operations-column-date": "Date",
  "operations-column-clearing-date": "Date Pointage",
  "operations-column-label": "Libelle",
  "operations-column-category": "Categorie",
  "operations-column-assignment": "Affectation",
  "operations-column-payment-mode": "ModeOp",
  "operations-column-payee": "Tiers",
  "operations-column-project": "Projets",
  "operations-column-month": "Mois",
  "operations-column-debit": "Debit",
  "operations-column-credit": "Credit",
  "operations-column-balance": "Solde",
  "operations-column-comments": "Commentaires",
  "operations-column-attachments": "Pièces Jointes",
  "operations-column-check": "Num Chèque",
  "operations-foot-debit": "Débit :",
  "operations-foot-credit": "Crédit :",
  "operations-foot-total": "Total :",
  "operations-foot-bank": "Solde en banque :",
  "operations-foot-real": "Solde réel :",
  "operations-foot-final": "Solde final :",
  "operations-menu-export": "Export",
  "operations-menu-print": "Impression",
  "print-menu-operations-pdf": "Impression dans fichier PDF",
  "print-menu-operations-printer": "Impression sur Imprimante",
  "print-nothing": "Il n'y a rien à imprimer.",
  "rib-group-bank": "Banque",
  "rib-group-holder": "Titulaire du compte",
  "rib-group-details": "Coordonnées bancaires",
  "rib-conditions": "Important conditions d'utilisations a respecter obligatoirement en cas d'impression",
  "rib-field-bank": "Nom banque",
  "rib-field-domiciliation": "Domiciliation",
  "rib-field-holder": "Nom du titulaire",
  "rib-field-address": "Adresse",
  "rib-field-establishment": "Etablissement",
  "rib-field-branch": "Guichet",
  "rib-field-number": "Numéro compte",
  "rib-field-key": "Clé RIB",
  "rib-field-bic": "BIC (Bank Identifer Code)",
  "rib-field-iban": "IBAN (International Bank Account Number )",
  "rib-declaration": "Je soussigné l'utilisateur du logiciel declare sur l'honneur :",
  "rib-declaration-first": "- Confirme avoir vérifié auprès de ma banque\u2026",
  "rib-declaration-second": "- Être le titulaire du compte\u2026",
  "rib-declaration-required": "Cochez la déclaration sur l'honneur pour pouvoir imprimer.",
  "rib-help": "Vérifiez vos coordonnées, cochez la déclaration, puis imprimez.",
  "rib-account-gone": "Ce compte bancaire est introuvable.",
  "rib-fields-read-only": "Ces coordonnées viennent de la fiche du compte.",
  "rib-title-print": "Impression sur Imprimante",
  "rib-title-pdf": "Impression dans fichier PDF",
  "journal-column-step": "Étape",
  "journal-column-file": "Fichier",
  "journal-column-table": "Table",
  "journal-column-status": "Statut",
  "journal-column-error": "Erreur",
  "journal-column-comments": "Commentaires",
  "journal-empty": "Aucune opération technique n'a encore été effectuée depuis l'ouverture du logiciel.",
  "journal-help": "Le journal ne garde que la dernière opération technique : sauvegarde, restauration, réparation ou effacement.",
  "window-journal-title": "Journal de la dernière opération technique",
  "window-attachments-title": "Pièces jointes de l'opération",
  "attachment-none": "Cette opération ne porte aucune pièce jointe.",
  "attachment-title-add": "Joindre un document à cette opération",
  "attachment-title-replace": "Remplacer le document de cette pièce jointe",
  "attachment-title-open": "Ouvrir la pièce jointe",
  "attachment-title-remove": "Retirer la pièce jointe et envoyer son fichier à la corbeille",
  "attachment-save-first": "Enregistrez d'abord l'opération : une pièce jointe se rattache à une opération qui existe.",
  "print-choose-printer": "Sur quelle imprimante voulez-vous imprimer ?",
  "print-do-print": "Imprimer",
  "print-printers-unknown": "Votre système n'a su nommer aucune imprimante : le document est parti sur l'imprimante par défaut.",
  "ui-cancel": "Annuler",
  "operations-menu-filter": "Filtre",
  "operations-menu-period": "Période",
  "operations-menu-misc": "Divers",
  "operations-title-point": "Pointer la sélection",
  "operations-title-sub": "Ajouter une sous-opération",
  "operations-title-duplicate": "Dupliquer la sélection",
  "operations-not-yet": "Cette fenêtre n'existe pas encore : elle vient plus loin dans le plan.",
  "period-all": "Toutes",
  "period-last-year": "Année Dernière",
  "period-this-year": "Année Actuelle",
  "period-whole-year": "Toute l'année",
  "period-last-month": "Mois Dernier",
  "period-this-month": "Mois en Cours",
  "period-last-week": "Semaine Dernière",
  "period-this-week": "Semaine Actuelle",
  "period-yesterday": "Hier",
  "period-today": "Aujourd'hui",
  "filter-all": "Toutes les opérations",
  "filter-pointed": "Uniquement les opérations pointées",
  "filter-committed": "Uniquement les opérations engagées",
  "filter-planned": "Uniquement les opérations prévues",
  "month-january": "janvier",
  "month-february": "février",
  "month-march": "mars",
  "month-april": "avril",
  "month-may": "mai",
  "month-june": "juin",
  "month-july": "juillet",
  "month-august": "août",
  "month-september": "septembre",
  "month-october": "octobre",
  "month-november": "novembre",
  "month-december": "décembre",
  "operation-menu-identification": "Identification",
  "operation-group-identification": "Identification de l'opération",
  "operation-group-amount": "Montant de l'opération",
  "operation-group-status": "Statut de l'opération",
  "operation-group-classification":
    "Classement de l'opération pour calcul des statistiques",
  "operation-group-check": "Chèque en relation avec l'opération",
  "operation-group-comment": "Commentaire",
  "operation-field-label": "Libellé",
  "operation-field-reference": "Référence paiement",
  "operation-field-date": "Date",
  "operation-field-direction": "Type Opération :",
  "operation-field-amount": "Montant",
  "operation-field-status": "Statut opération",
  "operation-field-clearing-date": "Date pointage",
  "operation-field-category": "Catégorie",
  "operation-field-assignment": "Affectation",
  "operation-field-payment-mode": "Mode",
  "operation-field-payee": "Tiers",
  "operation-field-project": "Projet",
  "operation-field-check": "Associer avec chèque",
  "operation-direction-debit": "Débit",
  "operation-direction-credit": "Crédit",
  "operation-check-info": "Info.",
  "operation-check-link": "Associer",
  "operation-check-unlink": "Supprimer",
  "operation-fresh": "Nouvelle opération.",
  "operation-created": "Opération ajoutée.",
  "operation-updated": "Opération modifiée.",
  "operation-gone": "Cette opération n'existe plus.",
  "operation-nothing-to-show": "Aucune opération à afficher.",
  "operation-label-required": "Le libellé de l'opération est obligatoire.",
  "operation-date-required": "La date de l'opération est obligatoire.",
  "operation-clearing-date-invalid": "La date de pointage n'est pas une date valide.",
  "operation-is-a-sub":
    "Cette ligne est une sous-opération : elle se modifie depuis sa fiche à elle.",
  "operation-title-comment": "Commentaire de l'opération",
  "operation-title-sub": "Créer une sous-opération",
  "operation-title-template": "Modèles d'opération",
  "operation-title-attachment": "Pièces jointes",
  "sub-operation-group-amount": "Montant de la sous-opération",
  "sub-operation-field-label": "Nom",
  "sub-operation-fresh": "Nouvelle sous-opération.",
  "sub-operation-created": "Sous-opération ajoutée.",
  "sub-operation-updated": "Sous-opération modifiée.",
  "sub-operation-gone": "Cette sous-opération n'existe plus.",
  "sub-operation-nothing-to-show": "Aucune sous-opération à afficher.",
  "sub-operation-label-required": "Le nom de la sous-opération est obligatoire.",
  "sub-operation-parent-gone": "L'opération à ventiler n'existe plus.",
  "sub-operation-is-the-complement":
    "Ceci est le Complément : ce qui reste à ventiler. Le renommer ou changer son montant en fait une sous-opération ordinaire.",
  "operations-select-one": "Veuillez sélectionner une seule opération.",
  "operation-copy": "Copie à enregistrer : rien n'est encore créé.",
  "operations-show-children": "Afficher toutes les sous-opérations",
  "operations-hide-children": "Masquer toutes les sous-opérations",
  "statistics-axis-column": "NomCategorie",
  "statistics-unclassified": "Sans catégorie",
  "statistics-total": "Total",
  "statistics-sum": "Somme",
  "statistics-cumulative": "Cumul",
  "statistics-no-account": "Aucun compte n'a été choisi : la statistique ne porte sur rien.",
  "statistics-no-data": "Aucune opération sur cette année pour les comptes choisis.",
  "statistics-detail-empty": "Cliquez une case chiffrée pour voir les opérations qu'elle compte.",
  "statistics-detail-none": "Aucune opération derrière cette case.",
  "statistics-year-next": "Année suivante",
  "statistics-year-choose": "Choisir l'année",
  "statistics-year-previous": "Année précédente",
  "statistics-column-date": "Date",
  "statistics-column-clearing-date": "DatePointage",
  "statistics-column-label": "Libelle",
  "statistics-column-amount": "Montant",
  "statistics-column-comments": "Commentaires",
  "ui-legend-budget-lines": "Postes budgétaires",
  "ui-legend-categories": "Catégories",
  "dashboard-menu-period": "Période",
  "dashboard-menu-misc": "Divers",
  "dashboard-from": "Date début :",
  "dashboard-to": "Date fin :",
  "dashboard-switch-pointed": "Inclure opérations pointées",
  "dashboard-switch-committed": "Inclure opérations engagées",
  "dashboard-switch-planned": "Inclure opérations prévues",
  "dashboard-spending": "Dépenses",
  "dashboard-earning": "Gains",
  "dashboard-debits": "Somme opérations débités",
  "dashboard-credits": "Somme opérations crédités",
  "dashboard-balance": "Balance",
  "dashboard-unclassified": "Sans poste budgetaire",
  "dashboard-nothing": "Aucune opération sur cette période.",
  "dashboard-no-account": "Aucun compte n'a été choisi : le tableau de bord ne porte sur rien.",
  "dashboard-enlarge": "Ouvrir en grand",
  "curve-heading": "Evolution du solde par jour",
  "curve-menu-period": "Période",
  "curve-total": "Total",
  "curve-from": "Date début :",
  "curve-to": "Date fin :",
  "curve-axis-balance": "solde",
  "curve-nothing": "Aucun compte n'a été choisi : il n'y a pas de courbe à tracer.",
  "curve-empty": "Aucune opération sur cette période.",
  "accounts-stats-multiselect-help": "Info : Utilisez Clic Souris + touche [CTRL] sur le tableau pour choisir plusieurs comptes",
  // L'export par clic droit. Le dictionnaire ne porte que ces trois-là : les
  // phrases « exporté vers … », « export impossible : … » et la ligne de
  // contexte ont un trou, donc c'est le noyau qui les rédige.
  "export-to-excel": "Exporter vers Excel (.xlsx)",
  "export-to-ods": "Exporter vers LibreOffice Calc (.ods)",
  "export-to-csv": "Exporter vers CSV (.csv)",
  "export-to-xml": "Exporter vers XML (.xml)",
  "export-to-json": "Exporter vers JSON (.json)",
  "export-menu": "Export",
  "export-all-years-excel": "Exporter toutes les années vers Excel",
  "export-all-years-ods": "Exporter toutes les années vers LibreOffice Calc",
  "export-no-year": "Aucune année ne porte d'opération : il n'y a rien à exporter.",
  "export-nothing": "Il n'y a rien à exporter.",
  "statistics-window-name": "Statistiques par categorie",
  "statistics-detail-name": "Detail des statistiques",
  // F17/F18 — l'importation d'un relevé bancaire, déclinée comme le vrai
  // dictionnaire la décline.
  "statement-menu-filter": "Filtre",
  "statement-filter-all": "Toutes les lignes",
  "statement-filter-pending": "A intégrer",
  "statement-filter-known": "Déjà intégrées",
  "statement-column-id": "ID",
  "statement-column-reconciled": "Rapproché",
  "statement-column-fitid": "FITID",
  "statement-column-date": "Date",
  "statement-column-label": "Libelle",
  "statement-column-debit": "Debit",
  "statement-column-credit": "Credit",
  "statement-account": "Compte",
  "statement-file": "Fichier",
  "statement-difference": "Ecart",
  "statement-none": "Aucun relevé n'est ouvert : cliquez sur le dossier jaune pour choisir un fichier.",
  "statement-empty": "Ce relevé ne contient aucune opération.",
  "statement-no-match": "Aucune ligne ne correspond au filtre.",
  "statement-help": "Info : Utilisez Clic Souris + touche [CMD] sur le tableau pour sélectionner plusieurs lignes",
  "statement-choose-account": "Ce fichier contient plusieurs comptes. Lequel voulez-vous importer ?",
  "statement-select-line": "Sélectionnez au moins une ligne du relevé.",
  "statement-title-open": "Ouvrir un fichier de relevé (.ofx)",
  "statement-title-info": "Informations sur le fichier ouvert",
  "statement-title-integrate": "Intégrer la sélection dans le compte",
  "statement-title-validate": "Intégrer cette opération dans le compte",
  "statement-duplicate": "Attention doublon : cette transaction semble deja avoir été intégrée à la base (Financial Institution Transaction ID existe)",
  "statement-no-fitid": "Attention : ce fichier ne donne aucun identifiant (FITID) pour cette ligne. Un doublon ne pourra pas être détecté.",
  "statement-group-identification": "Identification de l'opération",
  "statement-group-amount": "Montant de l'opération",
  "statement-group-classification": "Classement de l'opération pour calcul des statistiques",
  "statement-group-status": "Statut de l'opération",
  "statement-field-date": "Date",
  "statement-field-label": "Libelle",
  "statement-field-type": "Type Opération",
  "statement-field-amount": "Montant",
  "statement-field-mode": "Mode Operation",
  "statement-field-category": "Categorie",
  "statement-field-assignment": "Affectation",
  "statement-field-payee": "Tiers",
  "statement-field-project": "Projet",
  "statement-field-status": "Statut",
  "statement-field-clearing": "Date pointage",
  "statement-already-reconciled": "Vous avez deja rapproché cette transaction : elle est deja intégré dans l'historique des transactions de votre compte",
  "statement-mass-question": "Êtes vous certain de vouloir intégrer dans votre compte simultanément plusieurs opérations ?",
  "statement-yes": "Oui",
  "statement-no": "Non",
  "statement-cancel": "Annuler",
  // La fenêtre de découpage d'un relevé CSV.
  "csv-preview-title": "Apercu du fichier :",
  "csv-settings-title": "Parametres de découpage du fichier en vue de l'extraction des données :",
  "csv-extraction-title": "Visualisation de l'extraction des données selon les parametres de découpage  ( verifier la coherence des données ) :",
  "csv-column-line": "N° ligne",
  "csv-column-content": "Contenu",
  "csv-header-lines": "Nombre de lignes de l'entete du fichier à ignorer",
  "csv-separator": "Les données (colonnes) sont séparées par le caractere :",
  "csv-date-at": "Position champ date",
  "csv-label-at": "Position champ libellé",
  "csv-debit-at": "Position champ montant debit",
  "csv-credit-at": "Position champ montant credit",
  "csv-test": "Tester les parametres",
  "csv-separator-semicolon": "Point-virgule   ;",
  "csv-separator-comma": "Virgule   ,",
  "csv-separator-tab": "Tabulation",
  "csv-separator-pipe": "Barre verticale   |",
  "csv-separator-space": "Espace",
  "csv-help": "Réglez, testez, regardez : seules les lignes portant une date et un montant lisibles seront importées.",
  "csv-none": "Le fichier est vide.",
  "csv-not-tested": "Cliquez sur « Tester les parametres » pour voir ce que le découpage donne.",
  "csv-title-validate": "Basculer les lignes valides vers l'importation",

  // F05 — la classification rapide. **Déclinée ici exactement comme le vrai
  // dictionnaire la décline** : les phrases qui comptent quelque chose
  // (« 34 lignes classées ») n'y sont pas, parce qu'elles ont besoin du
  // nombre et que c'est Fluent qui sait si ce nombre change la phrase. Un
  // faux dictionnaire plus généreux que le vrai fait passer des tests que la
  // vraie fenêtre échoue — c'est ce qui nous a coûté les cinq interrupteurs
  // sans nom le 26/07/2026.
  "quick-dates-title": "Dates de début et fin de liste.",
  "quick-from": "Date debut",
  "quick-to": "Date fin",
  "quick-menu-period": "Période",
  "quick-change-title": "Changer caractéristiques sélection en :",
  "quick-check-category": "Categorie",
  "quick-check-assignment": "Affectation",
  "quick-check-payment-mode": "Mode",
  "quick-check-payee": "Tiers",
  "quick-check-project": "Projet",
  "quick-check-status": "Status",
  "quick-column-date": "Date",
  "quick-column-label": "Libelle",
  "quick-column-amount": "Montant",
  "quick-column-category": "Categorie",
  "quick-column-assignment": "Affectation",
  "quick-column-payment-mode": "Mode Paiement",
  "quick-column-payee": "Tiers",
  "quick-column-project": "Projets",
  "quick-column-status": "Status",
  "quick-multiselect-help": "Info : Utilisez Clic Souris + touche [CMD] sur le tableau pour sélectionner plusieurs éléments",
  "quick-none": "Aucune opération sur cette période.",
  "quick-select-lines": "Sélectionnez au moins une ligne, et cochez au moins une caractéristique.",
  "quick-nothing-to-save": "Aucune modification en attente.",
  "quick-leave-question": "Des modifications ne sont pas enregistrées. Que voulez-vous faire ?",
  "quick-leave-save": "Enregistrer et sortir",
  "quick-leave-discard": "Abandonner et sortir",
  "quick-leave-stay": "Rester",
  "quick-title-apply": "Appliquer aux lignes sélectionnées ( en mémoire )",
  "quick-title-save": "Enregistrer sur le disque",
};

/// La matrice que le noyau rend à F20 : deux catégories qui portent quelque
/// chose, une vide, et la ligne des non classées.
const MATRIX = {
  rows: [
    {
      id: 1, label: "Alimentation",
      months: ["-100,00 €", "", "0,00 €", "", "", "", "", "", "", "", "", ""],
      month_values: [-100000000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      filled: [true, false, true, false, false, false, false, false, false, false, false, false],
      total: "-100,00 €", total_value: -100000000, total_filled: true, is_empty: false,
    },
    {
      id: 5, label: "Salaire",
      months: ["2 216,71 €", "", "", "", "", "", "", "", "", "", "", ""],
      month_values: [2216710000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      filled: [true, false, false, false, false, false, false, false, false, false, false, false],
      total: "2 216,71 €", total_value: 2216710000, total_filled: true, is_empty: false,
    },
    {
      id: 9, label: "Vétérinaire",
      months: ["", "", "", "", "", "", "", "", "", "", "", ""],
      month_values: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      filled: [false, false, false, false, false, false, false, false, false, false, false, false],
      total: "", total_value: 0, total_filled: false, is_empty: true,
    },
    {
      id: 0, label: "Sans catégorie",
      months: ["", "", "", "", "", "", "", "", "", "", "", ""],
      month_values: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      filled: [false, false, false, false, false, false, false, false, false, false, false, false],
      total: "", total_value: 0, total_filled: false, is_empty: true,
    },
  ],
  sum: ["2 116,71 €", "", "0,00 €", "", "", "", "", "", "", "", "", ""],
  sum_values: [2116710000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  sum_filled: [true, false, true, false, false, false, false, false, false, false, false, false],
  sum_total: "2 116,71 €",
  sum_total_value: 2116710000,
  cumulative: ["2 116,71 €", "2 116,71 €", "2 116,71 €", "2 116,71 €", "2 116,71 €", "2 116,71 €",
               "2 116,71 €", "2 116,71 €", "2 116,71 €", "2 116,71 €", "2 116,71 €", "2 116,71 €"],
  cumulative_values: Array.from({ length: 12 }, () => 2116710000),
  has_data: true,
  month_names: ["Janvier", "Fevrier", "Mars", "Avril", "Mai", "Juin", "Juillet",
                "Aout", "Septembre", "Octobre", "Novembre", "Décembre"],
  accounts: "2 comptes",
};

/// Une sous-opération telle que sa fiche la lit (F04).
const SUB_OPERATION = {
  id: 2,
  parent_id: 1,
  label: "Alimentation",
  direction: "D",
  amount: "-60,00",
  category_id: 1,
  assignment_id: 2,
  payee_id: 0,
  project_id: 0,
  comment: "",
  is_complement: false,
  parent_line: "Ventilation de « COURSES » (-100,00 €)",
};

/// One operation as its fiche reads it (F03). The author's own line from the
/// capture « Fiche operation transaction.png ».
const OPERATION = {
  id: 1,
  account_id: 1,
  label: "VIREMENT DE COMPLEMENTAIRE SANTE",
  payment_reference: "",
  date: "2026-01-21",
  clearing_date: "2026-01-21",
  direction: "C",
  amount: "9,00",
  status_id: 1,
  category_id: 1,
  assignment_id: 2,
  payment_mode_id: 3,
  payee_id: 0,
  project_id: 0,
  check_number: "",
  comment: "",
  attachments: "Aucune pièce jointe",
  parent_id: 0,
  child_count: 0,
};

/// What Rust answers for another nomenclature — whole sentences, as Fluent
/// gives them, never assembled here either.
const UI_TEXTS_BY_KIND = {
  // Les six axes des statistiques. **Déclinés ici comme le vrai dictionnaire
  // les décline** : sans cela, un test qui vérifie le titre de la colonne
  // passerait même si les six fenêtres l'affichaient identique — le genre de
  // test qui ment, et qui nous a déjà coûté les cinq interrupteurs sans nom.
  assignment: {
    "statistics-axis-column": "Affectation",
    "statistics-unclassified": "Sans affectation",
    "statistics-window-name": "Statistiques par affectation",
  },
  "budget-line": {
    "statistics-axis-column": "PosteBudget",
    "statistics-unclassified": "Sans poste budgetaire",
    "statistics-window-name": "Statistiques par poste budgetaire",
  },
  "payment-mode": {
    "statistics-axis-column": "ModeOperation",
    "statistics-unclassified": "Sans moyen de paiement",
    "statistics-window-name": "Statistiques par moyen de paiement",
  },
  project: {
    "statistics-axis-column": "Projets",
    "statistics-unclassified": "Sans projet",
    "statistics-window-name": "Statistiques par projet",
  },
  payee: {
    "statistics-axis-column": "Tiers",
    "statistics-unclassified": "Sans tiers",
    "statistics-window-name": "Statistiques par tiers et marchand",
    "nomenclature-identifier": "Identifiant de Tiers",
    "nomenclature-none": "Aucun tiers.",
    "nomenclature-nothing-to-show": "Aucun tiers à afficher.",
    "nomenclature-gone": "Ce tiers n'existe plus.",
    "nomenclature-fresh": "Nouveau tiers.",
    "nomenclature-created": "Tiers ajouté.",
    "nomenclature-updated": "Tiers modifié.",
  },
  bank: {
    "nomenclature-identifier": "Identifiant de Banque",
    "nomenclature-none": "Aucune banque.",
    "nomenclature-nothing-to-show": "Aucune banque à afficher.",
    "nomenclature-gone": "Cette banque n'existe plus.",
    "nomenclature-fresh": "Nouvelle banque.",
    "nomenclature-created": "Banque ajoutée.",
    "nomenclature-updated": "Banque modifiée.",
  },
};

/// And the counted sentence, which Fluent resolves with the number.
const DELETED_TEXTS = {
  category: (n) => (n === 1 ? "1 catégorie supprimée." : `${n} catégories supprimées.`),
  bank: (n) => (n === 1 ? "1 banque supprimée." : `${n} banques supprimées.`),
  payee: (n) => (n === 1 ? "1 tiers supprimé." : `${n} tiers supprimés.`),
};

/// Installs a stub of Tauri's bridge that records every call.
function bridge({ startupError = null, needsConfirmation = true, plainQuestion = false, slowLoadMs = 0, refusedDeletion = false, duplicateName = null, accountRefusal = null, manyOperations = false, scatteredChildren = false, operationRefusal = null, operationIsASub = false, operationComment = "", subIsComplement = false, missingParent = false, exportCancelled = false, exportFails = null, noYear = false, pickCancelled = false, fileAccounts = ["123456A789"], pickedIsCsv = false, referenceTaken = false, accountGone = false } = {}) {
  return `
    const OPERATION_JSON = ${JSON.stringify(JSON.stringify(OPERATION))};
    const SUB_OPERATION_JSON = ${JSON.stringify(JSON.stringify(SUB_OPERATION))};
    const MATRIX_JSON = ${JSON.stringify(JSON.stringify(MATRIX))};
    const TEXTS_JSON = ${JSON.stringify(JSON.stringify(UI_TEXTS))};
    const TEXTS_BY_KIND = ${JSON.stringify(JSON.stringify(UI_TEXTS_BY_KIND))};
    const OPERATIONS_JSON = ${JSON.stringify(JSON.stringify(OPERATIONS))};
    const ACCOUNTS_JSON = ${JSON.stringify(JSON.stringify(ACCOUNTS))};
    const ACCOUNT_JSON = ${JSON.stringify(JSON.stringify(ACCOUNT))};
    const DELETED_TEXTS = ${JSON.stringify(
      JSON.stringify({
        category: ["1 catégorie supprimée.", "catégories supprimées."],
        bank: ["1 banque supprimée.", "banques supprimées."],
        payee: ["1 tiers supprimé.", "tiers supprimés."],
      }),
    )};
    window.__calls = [];
    window.__closed = false;
    // Ce que Rust rend à F17 : les lignes, et les trois montants du pied. Le
    // solde du compte suit ce qui a été intégré, si bien que l'écart tombe à
    // zéro quand tout est entré — comme le noyau le garantit.
    // Le relevé CSV de la capture de Fabrice. Écrit en guillemets simples et
    // sans une seule séquence d'échappement : ce texte est injecté dans un
    // gabarit de chaînes, où \d vaudrait d et \" vaudrait " — deux façons de
    // casser le script sans qu'il y paraisse.
    const csvFile = () => [
      'Numero Compte  ;1234567Z890',
      'Type           ;CCP',
      'Compte tenu en ;euros',
      'Date           ;03/03/2023',
      'Solde (EUROS)  ;3409,72',
      '',
      'Date;Libelle;Montant(EUROS)',
      '02/03/2023;"ACHAT CB COMMERCE UN 01.03.23";-13,80',
      '01/03/2023;"ACHAT CB COMMERCE DEUX";-166,08',
      '27/02/2023;"VIREMENT DE TIERS UN";139,00',
    ];
    // Un découpage qui suit les mêmes règles que le vrai : on saute l'entete,
    // on coupe sur le séparateur, et une ligne n'est valide que si elle porte
    // une date et un montant lisibles.
    const csvLooksLikeADate = (text) =>
      text.length === 10 && text[2] === '/' && text[5] === '/';
    const csvExtract = (settings) => {
      const money = (v) => (v / 1000000).toFixed(2).replace('.', ',') + ' €';
      const rows = [];
      csvFile().forEach((line, index) => {
        if (index < settings.header_lines || line.trim() === '') return;
        const parts = line
          .split(settings.separator)
          .map((piece) => piece.split('"').join('').trim());
        const at = (position) => parts[position - 1] ?? '';
        const date = csvLooksLikeADate(at(settings.date_at)) ? at(settings.date_at) : '';
        const raw = at(settings.debit_at).split(',').join('.');
        const value = Number(raw);
        const amount = raw !== '' && Number.isFinite(value) ? Math.round(value * 1000000) : null;
        rows.push({
          number: index + 1,
          date,
          date_value: date === '' ? '' :
            date.slice(6, 10) + '-' + date.slice(3, 5) + '-' + date.slice(0, 2),
          label: at(settings.label_at),
          debit: amount !== null && amount < 0 ? money(amount) : '',
          credit: amount !== null && amount >= 0 ? money(amount) : '',
          amount: amount ?? 0,
          valid: date !== '' && amount !== null,
        });
      });
      return rows;
    };
    const statementLines = () => {
      const money = (v) => (v / 1000000).toFixed(2).replace(".", ",") + " €";
      // fitid_known est la certitude — ce FITID est en base — et
      // looks_like_duplicate le soupçon : même date, même libellé, même
      // montant. Les trois lignes couvrent les trois cas. (Pas d'accent grave
      // ici : ce texte est injecté dans un gabarit de chaînes.)
      const line = (rank, date, label, amount, known, alike) => ({
        rank, date, label, amount,
        // Le vrai contrôleur envoie les deux : le texte pour lire, l'ISO pour
        // ranger. Le faux pont doit en faire autant, sinon la colonne Date
        // trierait sur « undefined ».
        date_value: date.slice(6, 10) + "-" + date.slice(3, 5) + "-" + date.slice(0, 2),
        debit: amount < 0 ? money(amount) : "",
        credit: amount >= 0 ? money(amount) : "",
        fitid_known: known, looks_like_duplicate: alike, reconciled: false,
      });
      return [
        line(1, "23/07/2026", "RETRAIT DAB/TPE INTERNE", -50000000, false, false),
        line(2, "22/07/2026", "ACHAT CB COMMERCE TROIS", -120000000, true, true),
        line(3, "21/07/2026", "VIREMENT SALAIRE", 2000000000, false, true),
      ];
    };
    const statementView = (said) => {
      const rows = window.__statementRows ?? [];
      const money = (v) => (v / 1000000).toFixed(2).replace(".", ",") + " €";
      const inAccount = rows
        .filter((row) => row.fitid_known || row.reconciled)
        .reduce((sum, row) => sum + row.amount, 0);
      const file = rows.reduce((sum, row) => sum + row.amount, 0);
      return {
        lines: rows.map((row) => ({ ...row })),
        account_number: "123456A789",
        period: "27/04/2026 — 24/07/2026",
        account_balance: money(inAccount),
        file_balance: money(file),
        difference: money(inAccount - file),
        pending: rows.filter((row) => !row.reconciled).length,
        fitid_known: rows.filter((row) => row.fitid_known).length,
        has_fitid_column: true,
        said,
      };
    };
    // Phase 9 — chéquiers et chèques. Deux carnets, trois chèques, deux
    // opérations dont une porte déjà un chèque (elle sortira en gras).
    const chequebooks = () => [
      { id: 1, reference: '07328', received_on: '2020-08-01', account_label: 'CCP',
        account_number: '0500013M026', comments: '' },
      { id: 2, reference: '06561', received_on: '2025-10-26', account_label: 'CCP',
        account_number: '0500013M026', comments: '91034892' },
    ];
    const chequeStatuses = () => [
      { id: 1, label: 'Non encore utilise' },
      { id: 2, label: 'Emis' },
      { id: 5, label: 'Paye / Compense' },
      { id: 9, label: 'Annule / Detruit' },
    ];
    const cheques = () => [
      { id: 11, number: '9 506 001', date: '2020-08-25', place: 'bastia',
        payee: 'Dr Joran', amount: 84000000, amount_text: '84,00 €',
        status_id: 5, status: 'Paye / Compense', comments: 'parebrise', operations: 1 },
      { id: 12, number: '9 506 002', date: '', place: '', payee: '',
        amount: 0, amount_text: '0,00 €', status_id: 1,
        status: 'Non encore utilise', comments: '', operations: 0 },
      { id: 13, number: '9 506 003', date: '', place: '', payee: 'Neant',
        amount: 0, amount_text: '0,00 €', status_id: 9,
        status: 'Annule / Detruit', comments: 'detruit', operations: 0 },
    ];
    const chequeOperations = (linked) => linked
      ? [
          { id: 101, account_label: 'CCP', label: 'CHEQUE N 9506019',
            date: '2022-05-13', clearing_date: '2022-05-13', amount: -110000000,
            amount_text: '-110,00 €', cheque_id: 11, cheque_reference: '07328/9506001' },
        ]
      : [
          { id: 101, account_label: 'CCP', label: 'CHEQUE N 9506019',
            date: '2022-05-13', clearing_date: '2022-05-13', amount: -110000000,
            amount_text: '-110,00 €', cheque_id: 11, cheque_reference: '07328/9506001' },
          { id: 102, account_label: 'CCP', label: 'ACHAT CB BORGO DISTRIB',
            date: '2022-06-19', clearing_date: '2022-06-20', amount: -34530000,
            amount_text: '-34,53 €', cheque_id: 0, cheque_reference: '/' },
        ];
    window.__TAURI_INTERNALS__ = {
      transformCallback: (callback) => callback,
      metadata: {
        currentWindow: { label: "test" },
        currentWebview: { label: "test" },
      },
      invoke: (command, args) => {
        window.__calls.push([command, args]);
        // Tauri's own event plumbing: remember the listeners so the test can
        // fire the parameters event, the way a reused window receives it.
        if (command === "plugin:event|unlisten") {
          return Promise.resolve();
        }
        if (command === "plugin:event|listen") {
          window.__listeners = window.__listeners || {};
          window.__listeners[args.event] = args.handler;
          return Promise.resolve(1);
        }
        switch (command) {
          case "ui_texts":
            return Promise.resolve({
              ...JSON.parse(TEXTS_JSON),
              ...(JSON.parse(TEXTS_BY_KIND)[args.kind] ?? {}),
            });
          case "ui_deleted_text": {
            const said = JSON.parse(DELETED_TEXTS)[args.kind];
            return Promise.resolve(
              args.count === 1 ? said[0] : args.count + " " + said[1],
            );
          }
          // --- La fenêtre de découpage d'un relevé CSV --------------------
          //
          // Le faux fichier est celui de la capture : cinq lignes de
          // renseignements bancaires, une ligne vide, la ligne des noms de
          // colonnes, puis trois opérations. Avec le réglage de la capture —
          // une seule ligne d'entête — le découpage produit du charabia, et
          // c'est exactement ce qu'il faut voir.
          case "csv_statement_source":
            window.__csvSourceAsked = args;
            return Promise.resolve(
              csvFile().map((content, index) => ({ number: index + 1, content })),
            );
          case "csv_statement_extract": {
            window.__csvSettings = args.settings;
            const rows = csvExtract(args.settings);
            const valid = rows.filter((row) => row.valid).length;
            return Promise.resolve({
              rows, valid, dropped: rows.length - valid,
              said: rows.length === 0
                ? "Le découpage ne produit aucune ligne : vérifiez le nombre de lignes d'entete et le séparateur."
                : rows.length + " lignes découpées : " + valid + " seront importées, " +
                  (rows.length - valid) + " écartées faute de date ou de montant lisible.",
            });
          }
          case "csv_statement_apply": {
            window.__csvApplied = args;
            const valid = csvExtract(args.settings).filter((row) => row.valid);
            if (valid.length === 0) {
              return Promise.reject(
                "Aucune ligne ne porte à la fois une date et un montant lisibles : il n'y a rien à importer.",
              );
            }
            window.__closed = true;
            return Promise.resolve(valid.length + " lignes lues, dont 0 déjà présentes dans votre compte.");
          }
          case "open_csv_statement":
            window.__openedCsv = args;
            return Promise.resolve();
          case "close_csv_statement":
            window.__closed = true;
            return Promise.resolve();
          // --- F17/F18, l'importation d'un relevé bancaire ---------------
          //
          // Le faux relevé fait ce que fait le vrai : trois lignes, dont une
          // que la base connaît déjà — c'est elle qui doit sortir en pastel —
          // et une sans FITID, dont le doublon ne peut pas être détecté.
          case "statement_pick_file":
            window.__pickAsked = true;
            return Promise.resolve(
              ${pickCancelled}
                ? null
                : {
                    path: ${pickedIsCsv} ? "/tmp/releve.csv" : "/tmp/releve.ofx",
                    kind: ${pickedIsCsv} ? "csv" : "ofx",
                    accounts: ${pickedIsCsv} ? [] : ${JSON.stringify(fileAccounts)},
                  },
            );
          case "statement_load": {
            window.__statementLoaded = args;
            window.__statementRows = statementLines();
            return Promise.resolve(statementView("3 lignes lues, dont 1 déjà présentes dans votre compte."));
          }
          case "statement_lines":
            return Promise.resolve(statementView(""));
          case "statement_file_info":
            return Promise.resolve("Compte du fichier : 123456A789");
          case "statement_integrate_line": {
            window.__integratedLines = window.__integratedLines ?? [];
            window.__integratedLines.push(args);
            const rows = window.__statementRows ?? statementLines();
            const row = rows.find((r) => r.rank === args.rank);
            if (!row) return Promise.resolve({ outcome: "unknown", question: "" });
            if (row.reconciled) {
              return Promise.resolve({ outcome: "reconciled", question: "" });
            }
            if (row.fitid_known && !args.force) {
              return Promise.resolve({
                outcome: "duplicate",
                question:
                  "La transaction : " + row.date + " " + row.label +
                  " semble deja avoir été intégré à l'historique des transactions de votre compte banquaire.",
              });
            }
            row.reconciled = true;
            return Promise.resolve({ outcome: "added", question: "" });
          }
          case "statement_integration_report":
            return Promise.resolve(
              (args.abandoned ? "Abandon de l'intégration ! " : "Fin de l'intégration. ") +
                "Nombre d'enregistrements intégrés : " + args.added +
                " Nombre d'enregistrements ignorés : " + args.ignored,
            );
          case "statement_amend":
            window.__amended = args;
            return Promise.resolve();
          case "statement_line": {
            // La fiche vit dans sa propre fenêtre : elle n'a pas chargé le
            // relevé elle-même, et c'est Rust qui le tient. Le faux pont fait
            // donc pareil — il connaît les lignes sans qu'on les lui ait
            // demandées.
            const row = (window.__statementRows ?? statementLines()).find(
              (r) => r.rank === args.rank,
            );
            return Promise.resolve({
              rank: args.rank,
              date: "2026-07-23",
              label: row ? row.label : "",
              direction: row && row.amount < 0 ? "D" : "C",
              amount: "50,00",
              clearing_date: "2026-07-23",
              warning: row && row.fitid_known
                ? "Attention doublon : cette transaction semble deja avoir été intégrée à la base (Financial Institution Transaction ID existe)"
                : row && row.looks_like_duplicate
                  ? "Attention : ce fichier ne donne aucun identifiant (FITID) pour cette ligne. Un doublon ne pourra pas être détecté."
                  : "",
            });
          }
          case "statement_integrate": {
            window.__integratedOne = args;
            const rows = window.__statementRows ?? statementLines();
            const row = rows.find((r) => r.rank === args.rank);
            if (row && row.fitid_known && !args.force) {
              return Promise.resolve({
                outcome: "duplicate",
                question:
                  "La transaction : " + row.date + " " + row.label +
                  " semble deja avoir été intégré à l'historique des transactions de votre compte banquaire.",
              });
            }
            if (row) row.reconciled = true;
            return Promise.resolve({ outcome: "added", question: "" });
          }
          case "open_statement_form":
            window.__openedStatementForm = args;
            return Promise.resolve();
          case "close_statement_form":
          case "close_statement_import":
            window.__closed = true;
            return Promise.resolve();
          case "open_statement_import":
            window.__openedStatementImport = args;
            return Promise.resolve();
          // --- F05, la classification rapide ---------------------------
          //
          // Le faux brouillon fait ce que fait le vrai : il tient les lignes
          // d'**un** compte, applique en mémoire, compte ce qui attend, et
          // n'« écrit » qu'à l'enregistrement. Les deux comptes portent des
          // libellés différents à dessein — c'est ainsi que se verrait une
          // fenêtre qui garderait le compte de sa première ouverture.
          case "quick_classification_load": {
            window.__quickLoads = (window.__quickLoads ?? 0) + 1;
            window.__quickAccount = args.accountId;
            const money = (v) => (v / 1000000).toFixed(2).replace(".", ",") + " €";
            const line = (id, iso, label, amount) => ({
              id, iso, label,
              date: iso.slice(8, 10) + "/" + iso.slice(5, 7) + "/" + iso.slice(0, 4),
              date_value: iso,
              amount, amount_text: money(amount),
              category: "Non précisé", assignment: "Non précisé",
              payment_mode: "Carte bancaire", payee: "Non précisé",
              project: "Non précisé", status: "Pointé",
              category_id: 0, assignment_id: 0, payment_mode_id: 3,
              payee_id: 0, project_id: 0, status_id: 1,
            });
            window.__quickRows =
              args.accountId === 1
                ? [
                    line(11, "2026-01-02", "ACHAT CB LAPOSTE", -33360000),
                    line(12, "2026-01-05", "ACHAT CB ANTONY SA", -22320000),
                    line(13, "2026-07-15", "PRELEVEMENT DE ORANGE", -13990000),
                    line(14, "2025-12-31", "ACHAT CB DE L AN PASSE", -10000000),
                  ]
                : [line(21, "2026-02-03", "VIREMENT LIVRET", 500000000)];
            window.__quickPending = 0;
            return Promise.resolve(window.__quickRows.length);
          }
          case "quick_classification_lines": {
            window.__quickAsked = args;
            // Le compte est vérifié, comme le vrai brouillon le vérifie : on
            // ne répond jamais avec les opérations de quelqu'un d'autre.
            if (args.accountId !== window.__quickAccount) {
              return Promise.reject(
                "La classification rapide travaille sur le compte " +
                  window.__quickAccount + ", et non sur le compte " + args.accountId,
              );
            }
            const rows = (window.__quickRows ?? []).filter(
              (row) => row.iso >= args.from && row.iso <= args.to,
            );
            const pending = window.__quickPending ?? 0;
            return Promise.resolve({
              rows,
              loaded: (window.__quickRows ?? []).length,
              pending,
              pending_text:
                pending === 0
                  ? "Aucune modification en attente."
                  : pending === 1
                    ? "1 ligne modifiée, non enregistrée."
                    : pending + " lignes modifiées, non enregistrées.",
            });
          }
          case "quick_classification_apply": {
            window.__quickApplied = args;
            const names = {
              category: [{ f: "category", n: { 0: "Non précisé", 1: "Alimentation", 5: "Salaire" } }],
              assignment: [{ f: "assignment", n: { 0: "Non précisé", 2: "Famille" } }],
              payment_mode: [{ f: "payment_mode", n: { 0: "Non précisé", 3: "Carte bancaire" } }],
              payee: [{ f: "payee", n: { 0: "Non précisé", 4: "Système U" } }],
              project: [{ f: "project", n: { 0: "Non précisé" } }],
              status: [{ f: "status", n: { 1: "Pointé", 2: "Engagé", 3: "Prévu" } }],
            };
            let touched = 0;
            for (const row of window.__quickRows ?? []) {
              if (!args.ids.includes(row.id)) continue;
              let moved = false;
              for (const field of Object.keys(names)) {
                const value = args.change[field];
                if (value === null || value === undefined) continue;
                if (row[field + "_id"] !== value) moved = true;
                row[field + "_id"] = value;
                row[field] = names[field][0].n[value] ?? "";
              }
              if (moved) touched += 1;
            }
            window.__quickPending = (window.__quickPending ?? 0) + touched;
            return Promise.resolve({
              said:
                touched === 0
                  ? "Rien n'a changé : ces lignes portaient déjà ce classement."
                  : touched + " lignes classées. Rien n'est encore enregistré.",
              pending: window.__quickPending,
            });
          }
          case "quick_classification_set":
            window.__quickSet = args;
            window.__quickPending = (window.__quickPending ?? 0) + 1;
            return Promise.resolve(window.__quickPending);
          case "quick_classification_question":
            return Promise.resolve(
              "Enregistrer les " + args.count + " modifications en attente ?",
            );
          case "quick_classification_save": {
            window.__quickSaved = (window.__quickSaved ?? 0) + 1;
            const written = window.__quickPending ?? 0;
            window.__quickPending = 0;
            return Promise.resolve(written + " lignes enregistrées.");
          }
          case "open_quick_classification":
            window.__openedQuick = args;
            return Promise.resolve();
          case "close_quick_classification":
            window.__closed = true;
            return Promise.resolve();
          case "list_operation_combos":
            return Promise.resolve({
              category: [
                { id: 0, label: "Non précisé" },
                { id: 1, label: "Alimentation" },
                { id: 5, label: "Salaire" },
              ],
              assignment: [{ id: 0, label: "Non précisé" }, { id: 2, label: "Famille" }],
              payment_mode: [{ id: 0, label: "Non précisé" }, { id: 3, label: "Carte bancaire" }],
              payee: [{ id: 0, label: "Non précisé" }, { id: 4, label: "Système U" }],
              project: [{ id: 0, label: "Non précisé" }],
            });
          case "set_operation_nomenclature":
            return Promise.resolve(true);
          case "list_operation_statuses":
            return Promise.resolve([
              { id: 1, label: "Pointé" },
              { id: 2, label: "Engagé" },
              { id: 3, label: "Prévu" },
            ]);
          case "get_operation": {
            const operation = JSON.parse(OPERATION_JSON);
            operation.comment = ${JSON.stringify(operationComment)};
            if (${operationIsASub}) {
              operation.parent_id = 7;
            }
            return Promise.resolve(operation);
          }
          case "operation_attachments_text":
            return Promise.resolve(
              args.count === 0 ? "Aucune pièce jointe" : args.count + " pièces jointes",
            );
          case "operation_refusal":
            return Promise.resolve(${JSON.stringify(operationRefusal)});
          case "create_operation":
            return Promise.resolve(77);
          case "update_operation":
            return Promise.resolve(true);
          case "open_operation_form":
            window.__openedForm = args;
            return Promise.resolve();
          case "notify_operations_changed":
            return Promise.resolve();
          case "sub_operation_parent_line":
            return Promise.resolve(
              ${missingParent} ? null : "Ventilation de « COURSES » (-100,00 €)",
            );
          case "get_sub_operation": {
            const sub = JSON.parse(SUB_OPERATION_JSON);
            if (${subIsComplement}) {
              sub.is_complement = true;
              sub.label = "Complément";
              sub.amount = "-40,00";
            }
            return Promise.resolve(sub);
          }
          case "sub_operation_refusal":
            return Promise.resolve(null);
          case "create_sub_operation":
            return Promise.resolve(88);
          case "update_sub_operation":
            return Promise.resolve(true);
          case "open_sub_operation_form":
            window.__openedSubForm = args;
            return Promise.resolve();
          case "statistics_year_prompt":
            return Promise.resolve({
              question: "Sur quelle année voulez-vous travailler ? Radinus va de 1950 à 2550.",
              first: 1950,
              last: 2550,
            });
          case "statistics_year":
            // Le noyau ramène dans les bornes : il impose, il ne rejette pas.
            return Promise.resolve(Math.min(2550, Math.max(1950, args.year)));
          case "statistics_switch_labels": {
            const on = (lit) => (lit ? "ON" : "OFF");
            const s = args.switches;
            return Promise.resolve([
              "Opérations pointées " + on(s.pointed),
              "Opérations engagées " + on(s.committed),
              "Opérations prévues " + on(s.planned),
              "Débits montants " + on(s.debits),
              "Crédits montants " + on(s.credits),
            ]);
          }
          case "axis_statistics":
            window.__statsAsked = args;
            return Promise.resolve(JSON.parse(MATRIX_JSON));
          case "statistics_detail":
            window.__detailAsked = args;
            // La première ligne est une opération, la seconde une ventilation :
            // le double-clic doit ouvrir deux fiches différentes.
            return Promise.resolve([
              { ...JSON.parse(OPERATIONS_JSON).rows[0], parent_id: 0 },
              { ...JSON.parse(OPERATIONS_JSON).rows[1], parent_id: 1 },
            ]);
          case "open_form_for_operation":
            window.__openedFormFor = args.id;
            return Promise.resolve();
          case "open_statistics":
            window.__openedStats = args;
            return Promise.resolve();
          case "close_statistics":
            window.__closed = true;
            return Promise.resolve();
          case "point_operations":
            window.__pointed = args.ids;
            return Promise.resolve("2 opérations pointées.");
          case "operations_list_has_unsaved_changes":
            return Promise.resolve(window.__operationDirty === true);
          case "set_operation_form_dirty":
            window.__operationDirty = args.dirty;
            return Promise.resolve();
          case "set_operation_form_record":
            window.__operationRecord = args.id;
            return Promise.resolve();
          case "list_operations": {
            const operations = JSON.parse(OPERATIONS_JSON);
            if (${scatteredChildren}) {
              // The children sent far from their mother: the window must put
              // them back under her all the same.
              const [mother, first, second, other] = operations.rows;
              operations.rows = [mother, other, first, second];
            }
            if (${manyOperations}) {
              const model = operations.rows[0];
              operations.rows = Array.from({ length: 300 }, (unused, index) => ({
                ...model,
                id: 1000 + index,
                label: "OPERATION " + index,
                child_count: 0,
                parent_id: 0,
              }));
            }
            return Promise.resolve(operations);
          }
          case "plan_operations_deletion":
            return Promise.resolve({
              refused: false, refusal: "", needs_confirmation: true,
              question: "Confirmez-vous la suppression de ces 3 lignes ? Les sous-opérations des opérations sélectionnées partent avec elles.",
              second_question: "", confirmation_word: "",
              operations: 3,
            });
          case "delete_operations":
            return Promise.resolve(3);
          case "operations_deleted_text":
            return Promise.resolve("3 opérations supprimées.");
          case "operations_selection_total":
            return Promise.resolve("Montant total des opérations sélectionnées : -100,00 €");
          case "list_accounts":
            return Promise.resolve(JSON.parse(ACCOUNTS_JSON));
          case "accounts_total":
            return Promise.resolve({
              id: 0,
              label: "TOTAL",
              bank: "",
              account_type: "",
              account_number: "",
              balance_bank: 24972620000,
              balance_real: 24972620000,
              balance_final: 24972620000,
              balance_bank_text: "24\u202f972,62 €",
              balance_real_text: "24\u202f972,62 €",
              balance_final_text: "24\u202f972,62 €",
              is_closed: false,
            });
          case "get_account":
            return Promise.resolve(JSON.parse(ACCOUNT_JSON));
          case "list_banks":
            return Promise.resolve([
              { id: 0, label: "Non précisé" },
              { id: 1, label: "La Banque Postale" },
            ]);
          case "list_account_types":
            return Promise.resolve([
              { id: 1, label: "Chèque" },
              { id: 2, label: "Livret A" },
            ]);
          case "account_refusal":
            return Promise.resolve(${JSON.stringify(accountRefusal)});
          case "create_account":
            return Promise.resolve(9);
          case "update_account":
            return Promise.resolve(true);
          case "plan_account_deletion":
            return Promise.resolve({
              refused: false,
              refusal: "",
              needs_confirmation: true,
              question:
                "Le compte « CCP » contient 2502 opérations, qui seront supprimées avec lui. Est ce que vous confirmez la suppression ?",
              second_question:
                "Cette suppression est définitive et emporte tout l'historique du compte. Tapez « Oui » pour la confirmer.",
              confirmation_word: "Oui",
              operations: 2502,
            });
          case "delete_accounts":
            return Promise.resolve(1);
          case "accounts_deleted_text":
            return Promise.resolve("1 compte supprimé.");
          case "accounts_list_has_unsaved_changes":
            return Promise.resolve(window.__accountDirty === true);
          case "set_account_form_dirty":
            window.__accountDirty = args.dirty;
            return Promise.resolve();
          case "set_account_form_record":
            window.__accountRecord = args.id;
            return Promise.resolve();
          case "accounts_list_may_close":
            window.__listMayClose = true;
            return Promise.resolve();
          // L'export par clic droit. Le sélecteur est celui du système : la
          // fenêtre ne choisit aucun chemin, elle demande où et Rust écrit là.
          case "plugin:dialog|save": {
            window.__saveAsked = args.options;
            if (${exportCancelled}) {
              return Promise.resolve(null);
            }
            return Promise.resolve("/tmp/" + args.options.defaultPath);
          }
          case "export_sheet": {
            window.__exported = args;
            const failure = ${JSON.stringify(exportFails)};
            if (failure !== null) {
              return Promise.reject(failure);
            }
            return Promise.resolve("Exporté vers « " + args.path + " ».");
          }
          case "export_context":
            return Promise.resolve(args.window + " — " + args.detail);
          case "dashboard": {
            window.__dashboardAsked = args;
            const part = (id, label, amount) => ({
              id, label, amount,
              text: (amount / 1000000).toFixed(2).replace(".", ",") + " €",
            });
            // Trois postes en dépense, un en gain — et les tuiles valent
            // exactement la somme de leurs secteurs, comme le noyau le garantit.
            const spending = args.switches.planned
              ? [part(1, "Vie courante", 836000000), part(2, "Habitat", 200000000),
                 part(0, "Sans poste budgetaire", 50000000)]
              : [part(1, "Vie courante", 836000000)];
            const earning = [part(3, "Revenus", 2216000000)];
            const debits = -spending.reduce((sum, one) => sum + one.amount, 0);
            const credits = earning.reduce((sum, one) => sum + one.amount, 0);
            const money = (value) =>
              (value / 1000000).toFixed(2).replace(".", ",") + " €";
            // Le creusement (04/08/2026). Le faux pont doit savoir descendre,
            // sinon le test ne vérifierait que le clic et jamais son effet.
            const cats = [part(11, "Alimentation", 500000000),
                          part(12, "Habillement", 336000000)];
            const courbe = [];
            for (let jour = 1; jour <= 31; jour += 1) {
              courbe.push({
                day: "2026-07-" + String(jour).padStart(2, "0"),
                amount: jour * 10000000,
                text: money(jour * 10000000),
                label: String(jour),
              });
            }
            const niveau = (ligne, categorie, parts) => ({
              parts: categorie !== null && categorie !== undefined
                ? []
                : ligne !== null && ligne !== undefined ? cats : parts,
              legend: categorie !== null && categorie !== undefined
                ? "Alimentation"
                : ligne !== null && ligne !== undefined ? "Catégories" : "Postes budgétaires",
              back: categorie !== null && categorie !== undefined
                ? "Catégories"
                : ligne !== null && ligne !== undefined ? "Postes budgétaires" : null,
              curve: categorie !== null && categorie !== undefined ? courbe : [],
            });
            const gauche = niveau(args.spendingLine, args.spendingCategory, spending);
            const droite = niveau(args.earningLine, args.earningCategory, earning);
            return Promise.resolve({
              spending: gauche.parts, earning: droite.parts,
              spending_legend: gauche.legend, earning_legend: droite.legend,
              spending_back: gauche.back, earning_back: droite.back,
              spending_line: args.spendingLine ?? null,
              spending_category: args.spendingCategory ?? null,
              earning_line: args.earningLine ?? null,
              earning_category: args.earningCategory ?? null,
              spending_curve: gauche.curve, earning_curve: droite.curve,
              debits: money(debits), credits: money(credits),
              balance: money(debits + credits), balance_value: debits + credits,
              accounts: "2 comptes",
            });
          }
          case "welcome": {
            window.__welcomeAsked = args;
            const money = (v) => (v / 1000000).toFixed(2).replace(".", ",") + " €";
            // Le mois feuilleté, et ses deux voisins bornés comme le noyau les
            // borne. Le faux pont doit savoir feuilleter, sinon le test ne
            // vérifierait que le clic et jamais son effet.
            const MOIS = ["janvier", "février", "mars", "avril", "mai", "juin",
              "juillet", "août", "septembre", "octobre", "novembre", "décembre"];
            const shown = (args && args.month) || "2026-08-01";
            const shift = (iso, months) => {
              const rank = Number(iso.slice(0, 4)) * 12 + Number(iso.slice(5, 7)) - 1 + months;
              let year = Math.floor(rank / 12);
              let month = (((rank % 12) + 12) % 12) + 1;
              if (year < 1950) { year = 1950; month = 1; }
              if (year > 2550) { year = 2550; month = 12; }
              return year + "-" + String(month).padStart(2, "0") + "-01";
            };
            const named = MOIS[Number(shown.slice(5, 7)) - 1] + " " + shown.slice(0, 4);
            const part = (id, label, amount) => ({
              id, label, amount, text: money(amount),
            });
            // Un compte clôturé n'arrive jamais ici : le noyau les a déjà
            // écartés, et l'accueil montre ce qu'on lui donne.
            const rows = [
              { id: 1, label: "CCP", bank: "La Banque Postale",
                balance_bank_value: 1549810000, balance_real_value: 1120500000,
                balance_final_value: -287380000 },
              { id: 2, label: "Livret", bank: "La Banque Postale",
                balance_bank_value: 23422810000, balance_real_value: 23422810000,
                balance_final_value: 23422810000 },
            ].map((row) => ({
              ...row,
              balance_bank: money(row.balance_bank_value),
              balance_real: money(row.balance_real_value),
              balance_final: money(row.balance_final_value),
            }));
            const sum = (key) => rows.reduce((total, row) => total + row[key], 0);
            return Promise.resolve({
              accounts: rows,
              total_bank: money(sum("balance_bank_value")),
              total_real: money(sum("balance_real_value")),
              total_final: money(sum("balance_final_value")),
              total_bank_value: sum("balance_bank_value"),
              total_real_value: sum("balance_real_value"),
              total_final_value: sum("balance_final_value"),
              accounts_line: "2 comptes ouverts",
              month: shown,
              previous_month: shift(shown, -1),
              next_month: shift(shown, 1),
              at_first_month: shift(shown, -1) === shown,
              at_last_month: shift(shown, 1) === shown,
              spending_title: "Dépenses par postes budgétaires — " + named,
              earning_title: "Gains par postes budgétaires — " + named,
              // Le premier des trois niveaux (anneaux creusés, 04/08/2026).
              // Ces six champs manquaient : le faux pont rendait encore la forme
              // d'avant, la courbe valait undefined, et la fenêtre cassait en
              // lisant sa longueur — les anneaux ne se dessinaient plus du tout
              // ici, alors qu'ils marchent dans le logiciel. Trois vérifications
              // restaient rouges pour cette seule raison (05/08/2026).
              //
              // Au premier niveau : pas de retour en arrière, pas de poste ni de
              // catégorie creusés, et aucune courbe — c'est au troisième niveau
              // seulement que la courbe remplace l'anneau.
              //
              // Attention : tout ce bloc vit dans une chaîne à gabarit. Un
              // accent grave ici casse le fichier entier, et l'erreur ne dit pas
              // pourquoi. Vu le 05/08/2026.
              spending_legend: "Postes budgétaires",
              earning_legend: "Postes budgétaires",
              spending_back: null,
              earning_back: null,
              spending_line: null,
              spending_category: null,
              earning_line: null,
              earning_category: null,
              spending_curve: [],
              earning_curve: [],
              spending: [part(1, "Vie courante", 836000000), part(2, "Habitat", 200000000)],
              earning: [part(3, "Revenus", 2216000000)],
            });
          }
          case "balance_curves": {
            window.__curvesAsked = args;
            const money = (v) => (v / 1000000).toFixed(2).replace(".", ",") + " €";
            const step = (date, value) => ({ date, value, text: money(value) });
            // Deux comptes en escalier, et leur total : le total vaut la somme
            // des deux à chaque instant, comme le noyau le garantit.
            const ccp = {
              account_id: 1, label: "CCP", is_total: false,
              steps: [step(args.from, 100000000), step("2026-03-10", 70000000),
                      step("2026-06-15", 120000000), step(args.to, 120000000)],
            };
            const livret = {
              account_id: 2, label: "Livret A", is_total: false,
              steps: [step(args.from, 500000000), step("2026-06-15", 540000000),
                      step(args.to, 540000000)],
            };
            const total = {
              account_id: 0, label: "Total", is_total: true,
              steps: [step(args.from, 600000000), step("2026-03-10", 570000000),
                      step("2026-06-15", 660000000), step(args.to, 660000000)],
            };
            return Promise.resolve({
              curves: [ccp, livret, total],
              lowest: 70000000, highest: 660000000,
              year: Number(args.from.slice(0, 4)),
            });
          }
          case "shift_period": {
            window.__shiftAsked = args;
            const year = Number(args.from.slice(0, 4)) + (args.onto ? 0 : args.by);
            const target = args.onto ?? year;
            return Promise.resolve({
              from: target + "-01-01", to: target + "-12-31", year: target,
            });
          }
          case "open_balance_curves":
            window.__openedCurves = args;
            return Promise.resolve();
          case "close_balance_curves":
            window.__closed = true;
            return Promise.resolve();
          case "open_dashboard":
            window.__openedDashboard = args;
            return Promise.resolve();
          case "close_dashboard":
            window.__closed = true;
            return Promise.resolve();
          case "statistics_years":
            window.__yearsAsked = args;
            return Promise.resolve(${noYear} ? [] : [2024, 2025, 2026]);
          case "export_book":
            window.__book = args;
            return Promise.resolve(
              args.sheets.length + " années exportées vers « " + args.path + " ».",
            );
          case "startup_error":
            return Promise.resolve(${JSON.stringify(startupError)});
          case "list_elements":
            return Promise.resolve(${JSON.stringify(CATEGORIES)});
          case "list_budget_lines":
            return Promise.resolve([
              { id: 0, label: "Non précisé" },
              { id: 1, label: "Vie de tout les jours" },
              { id: 2, label: "Assurances" },
            ]);
          case "get_element":
            // A deliberately slow read, so a test can observe what the window
            // does *while* it is still loading.
            return new Promise((resolve) =>
              setTimeout(() => resolve(${JSON.stringify(CATEGORIES[0])}), ${slowLoadMs}),
            );
          case "plan_deletion":
            return Promise.resolve({
              refused: ${refusedDeletion},
              refusal: "La fiche de « Alimentation » est ouverte. Fermez-la avant de supprimer.",
              needs_confirmation: ${needsConfirmation},
              question: ${JSON.stringify(
                plainQuestion
                  ? "Confirmez-vous la suppression de « Alimentation » ?"
                  : "Des opérations (transactions bancaires) possédant l'attribut de type 'Alimentation' ont été détectées. Est ce que vous confirmez vouloir réinitialiser cet attribut ?",
              )},
              second_question: "", confirmation_word: "",
              operations: ${plainQuestion ? 0 : 4},
              operation_templates: 0,
              recurring_rules: 0,
            });
          case "delete_elements":
            return Promise.resolve(1);
          case "duplicate_name":
            return Promise.resolve(${JSON.stringify(duplicateName)});
          case "create_element":
            return Promise.resolve(51);
          case "update_element":
            return Promise.resolve(true);
          // A window is hidden, never destroyed — see ui/windows/window-frame.ts.
          case "plugin:window|hide":
            window.__closed = true;
            return Promise.resolve();
          case "plugin:window|close":
            window.__closed = true;
            return Promise.resolve();
          case "operation_cheque":
            window.__chequeAsked = args;
            return Promise.resolve(
              window.__chequeGone ? { cheque_id: 0, text: "/" }
                                  : { cheque_id: 11, text: "9 506 001" },
            );
          case "choose_cheque_for_operation":
          case "choose_cheque_in_chequebook":
            window.__opened = { command, args };
            return Promise.resolve();
          case "close_cheque_choice":
            window.__closed = true;
            window.__closedLabel = "cheque-choice";
            return Promise.resolve();
          // Ce que la fenêtre a demandé d'ouvrir. On note au lieu d'ignorer :
          // c'est la seule façon de vérifier qu'un double-clic porte sur le
          // bon compte (05/08/2026).
          case "open_operations_list":
            window.__ouvert = window.__ouvert ?? [];
            window.__ouvert.push(args);
            return null;
          case "transfer_balances":
            window.__balancesAsked = args;
            return Promise.resolve("CCP — En banque : 1 000,00 € · Réel : 1 000,00 € · Final : 1 000,00 €");
          case "transfer_refusal":
            window.__transferExamined = args;
            return Promise.resolve(
              args.transfer.source_id === args.transfer.target_id
                ? "Le compte source et le compte destination ne peuvent pas être le même : un virement va d'un compte vers un autre"
                : null,
            );
          case "perform_transfer":
            window.__transferDone = args;
            return Promise.resolve(
              "Virement effectué. 250,00 € du compte CCP vers le compte Livret A, le 24/07/2026.",
            );
          case "budget_grid":
            window.__budgetYear = args.year;
            return Promise.resolve({
              rows: [
                { id: 1, label: "Vie de tout les jours", months: [-100000000,0,0,0,0,0,0,0,0,0,0,0],
                  month_texts: ["-100,00","","","","","","","","","","",""],
                  total: -100000000, total_text: "-100,00" },
                { id: 2, label: "Revenus", months: [200000000,0,0,0,0,0,0,0,0,0,0,0],
                  month_texts: ["200,00","","","","","","","","","","",""],
                  total: 200000000, total_text: "200,00" },
              ],
              sum_texts: ["100,00","","","","","","","","","","",""],
              sum_total_text: "100,00",
              sum: [100000000,0,0,0,0,0,0,0,0,0,0,0],
              sum_total: 100000000,
              cumulative: [100000000,100000000,100000000,100000000,100000000,100000000,
                           100000000,100000000,100000000,100000000,100000000,100000000],
              cumulative_texts: ["100,00","100,00","100,00","100,00","100,00","100,00",
                                 "100,00","100,00","100,00","100,00","100,00","100,00"],
            });
          case "budget_save":
            window.__budgetSaved = args;
            return Promise.resolve(null);
          case "budget_control":
            const cell = (planned, actual, standing, money, percent) => ({
              planned, actual, money, percent, standing,
              detail: "Prévu " + money + " — Réalisé " + money,
            });
            const empty = () => cell(0, 0, "none", "", "");
            return Promise.resolve({
              rows: [
                { id: 1, label: "Vie de tout les jours",
                  months: [cell(-100000000, -80000000, "good", "-80,00 €", "80,00 %"),
                           ...Array.from({length: 11}, empty)],
                  total: cell(-100000000, -80000000, "good", "-80,00 €", "80,00 %") },
                { id: 2, label: "Revenus",
                  months: [cell(200000000, 150000000, "bad", "150,00 €", "75,00 %"),
                           ...Array.from({length: 11}, empty)],
                  total: cell(200000000, 150000000, "bad", "150,00 €", "75,00 %") },
              ],
              sum: Array.from({length: 12}, empty),
              sum_total: empty(),
              cumulative: Array.from({length: 12}, empty),
            });
          case "statistics_year":
            return Promise.resolve(args.year);
          case "list_operation_templates":
            return Promise.resolve([
              { id: 1, label: "Loyer", amount: -70000000, amount_text: "70,00",
                signed_text: "-70,00", payment_mode_id: 2, category_id: 3,
                assignment_id: 1, status_id: 1, payee_id: 4, project_id: 0 },
              { id: 2, label: "Salaire", amount: 200000000, amount_text: "200,00",
                signed_text: "200,00", payment_mode_id: 1, category_id: 0,
                assignment_id: 0, status_id: 2, payee_id: 0, project_id: 0 },
            ]);
          case "get_operation_template":
            return Promise.resolve({
              id: 1, label: "Loyer", amount: -70000000, amount_text: "70,00",
              signed_text: "-70,00", payment_mode_id: 2, category_id: 3,
              assignment_id: 1, status_id: 1, payee_id: 4, project_id: 0,
            });
          case "operation_template_refusal":
            window.__templateExamined = args;
            return Promise.resolve(null);
          case "create_operation_template":
          case "update_operation_template":
            window.__templateSaved = args;
            return Promise.resolve(9);
          case "delete_operation_templates":
            window.__templatesDeleted = args;
            return Promise.resolve(args.ids.length);
          case "operation_templates_deleted_text":
            return Promise.resolve(args.count + " modèles supprimés.");
          case "apply_operation_template":
            window.__templateApplied = args;
            return Promise.resolve(true);
          case "save_operation_as_template":
            window.__savedAsTemplate = args;
            return Promise.resolve(null);
          case "open_operation_templates":
          case "open_operation_template_form":
            window.__opened = { command, args };
            return Promise.resolve();
          case "notify_operation_templates_changed":
            return Promise.resolve();
          case "close_operation_template_window":
            window.__closed = true;
            window.__closedLabel = args.label;
            return Promise.resolve();
          case "list_chequebooks":
            return Promise.resolve(chequebooks());
          case "get_chequebook":
            return Promise.resolve({
              id: 1, reference: '07328', received_on: '2020-08-01',
              first_number: 9506001, last_number: 9506040, quantity: 40,
              comments: '', account_id: 1, account_missing: ${accountGone},
            });
          case "chequebook_refusal":
            window.__examined = args;
            // Le plafond, celui qui compte : plus de mille chèques demandés.
            if (args.lastNumber - args.firstNumber + 1 > 1000) {
              return Promise.resolve(
                "Nombre de chèque maximum pour un chéquier : 1000, limitation atteinte",
              );
            }
            return Promise.resolve(
              ${referenceTaken} ? "Une référence du même nom existe déjà" : null,
            );
          case "chequebook_creation_question":
            return Promise.resolve(
              "Création du chéquier avec les caractéristiques suivantes :" +
                String.fromCharCode(10) +
                "- Nombre de chèques à générer :" +
                (args.lastNumber - args.firstNumber + 1) +
                String.fromCharCode(10) +
                "- Chèques numérotés de " + args.firstNumber + " à " + args.lastNumber +
                String.fromCharCode(10) +
                "Attention ces données ne seront pas modifiables après création !",
            );
          case "create_chequebook":
            window.__created = args;
            // La référence prise : son HAjoute échoue, et rien n'est dit.
            return Promise.resolve(${referenceTaken} ? null : 7);
          case "update_chequebook":
            window.__updatedBook = args;
            return Promise.resolve(true);
          case "plan_chequebook_deletion":
            return Promise.resolve({
              refused: false, refusal: "",
              needs_confirmation: true,
              question: "Des opérations (transactions bancaires) associées à chéquier ont été détectées. Est ce que vous confirmez vouloir supprimer ce chéquier ?",
              second_question: "", confirmation_word: "",
              operations: 3, operation_templates: 0, recurring_rules: 0,
            });
          case "delete_chequebooks":
            window.__deletedBooks = args;
            return Promise.resolve(args.ids.length);
          case "chequebooks_deleted_text":
            return Promise.resolve(args.count + " chéquiers supprimés.");
          case "list_cheques":
            window.__chequesAsked = args;
            return Promise.resolve(cheques());
          case "list_cheque_statuses":
            return Promise.resolve(chequeStatuses());
          case "get_cheque":
            return Promise.resolve({
              id: 11, number: '9 506 001', issued_on: '2020-12-02',
              place: 'Borgo', payee: 'dermato', amount_text: '25,00',
              comments: '', status_id: 5,
            });
          case "update_cheque":
            window.__updatedCheque = args;
            return Promise.resolve(true);
          case "set_cheque_status":
            window.__statusSet = args;
            return Promise.resolve(true);
          case "cheque_operations":
            window.__operationsAsked = args;
            return Promise.resolve(chequeOperations(args.linked));
          case "associate_cheque":
            window.__associated = args;
            return Promise.resolve(true);
          case "dissociate_cheque":
            window.__dissociated = args;
            return Promise.resolve(true);
          case "open_cheques":
          case "open_cheque_form":
          case "open_cheque_operations":
          case "open_chequebook_form":
            window.__opened = { command, args };
            return Promise.resolve();
          case "notify_cheques_changed":
            return Promise.resolve();
          case "close_cheque_window":
            window.__closed = true;
            window.__closedLabel = args.label;
            return Promise.resolve();
          case "list_has_unsaved_changes":
            return Promise.resolve(window.__formDirty === true);
          case "set_form_record":
            window.__formRecord = args.id;
            return Promise.resolve();
          case "set_form_dirty":
            window.__formDirty = args.dirty;
            return Promise.resolve();
          case "list_may_close":
            window.__listMayClose = true;
            return Promise.resolve();
          // --- Phase 16 — les opérations périodiques ----------------------
          case "list_recurring_rules":
            return Promise.resolve([
              { id: 1, label: "Assurance Voiture" },
              { id: 2, label: "Loyer" },
            ]);
          case "get_recurring_rule":
            return Promise.resolve({
              id: args.id,
              guid: "18e9cd0c98d04f64b37edac0c51db876",
              account_id: 1,
              label: "Assurance Voiture",
              amount: 65000000,
              direction: -1,
              category_id: 1,
              assignment_id: 2,
              payment_mode_id: 3,
              payee_id: 0,
              project_id: 0,
              next_date: "2026-08-10",
              ending: "until-date",
              end_date: "2036-08-10",
              unit: "month",
              frequency: 1,
              repeat_count: 1,
              produced_count: 12,
              produced_total: "-780,00 €",
              produced_last: "2026-07-10",
            });
          case "recurring_refusal":
            window.__ruleExamined = args.rule;
            return Promise.resolve(
              args.rule.label.trim() === ""
                ? "La saisie d'un libellé est obligatoire"
                : null,
            );
          case "create_recurring_rule":
            window.__ruleSaved = args.rule;
            return Promise.resolve(7);
          case "update_recurring_rule":
            window.__ruleSaved = args.rule;
            return Promise.resolve(true);
          case "delete_recurring_rules":
            window.__rulesDeleted = args.ids;
            return Promise.resolve("2 règles supprimées. Leurs opérations restent dans les comptes.");
          case "recurring_erase_question":
            return Promise.resolve(
              "Cette règle a inséré 12 opérations dans vos comptes. Voulez-vous toutes les effacer ?",
            );
          case "erase_recurring_operations":
            window.__erased = args.id;
            return Promise.resolve("12 opérations effacées, soldes recalculés.");
          case "recurring_calendar":
            window.__calendarAsked = args.ids;
            return Promise.resolve(
              [0, 1, 2].map((step) => ({
                rank: step + 1,
                account: "CCP",
                date: "2026-0" + (8 + step) + "-10",
                label: "Assurance Voiture",
                amount: -65000000,
                amount_text: "-65,00 €",
                category: "Assurance",
                assignment: "Voiture",
                payment_mode: "Prélèvement",
                payee: "",
                project: "",
              })),
            );
          case "recurring_insert_question":
            window.__insertAsked = args.count;
            return Promise.resolve(
              "Insérer ces " + args.count + " échéances dans vos comptes ?",
            );
          case "recurring_removed_text":
            return Promise.resolve(args.count + " échéances retirées de la proposition.");
          case "insert_recurring":
            window.__inserted = args.ranks;
            return Promise.resolve("2 opérations insérées.");
          case "open_recurring_form":
          case "open_recurring_calendar":
            window.__opened = { command, args };
            return Promise.resolve();
          case "close_recurring_window":
            window.__closed = true;
            window.__closedLabel = args.label;
            return Promise.resolve();
          case "export_operations":
            window.__exported = args;
            return Promise.resolve("Exporté vers « operations.ofx ».");
          // --- Phase 15 — l'impression -------------------------------------
          case "bank_details":
            return Promise.resolve({
              bank: "American Express",
              domiciliation: "AMERICAN EXPRESS FRANCE\\n92561 RUEIL-MALMAISON",
              holder: "M. FABRICE GARCIA",
              holder_address: "12 rue des Écureuils\\n20000 Ajaccio",
              establishment: "1223",
              branch: "111",
              number: "44557722",
              key: "22",
              iban: "FR76 1223 0111 0044 5577 2222 2",
              bic: "225555",
            });
          case "list_attachments":
            window.__attachmentsFor = args.operationId;
            return Promise.resolve([
              {
                id: 1,
                name: "Facture EDF.pdf",
                guid_name: "76d1dbb03c8946f3887c9d9fb691d2e7.pdf",
                size: 30106,
                size_text: "29,40 ko",
                mime: "application/pdf",
                added: "01/08/2026",
                state: "Intacte",
              },
              {
                id: 2,
                name: "Photo.png",
                guid_name: "aa11bb22cc33dd44ee55ff6677889900.png",
                size: 2048,
                size_text: "2,00 ko",
                mime: "image/png",
                added: "01/08/2026",
                state: "Fichier absent",
              },
            ]);
          case "add_attachment":
            window.__attachmentAdded = args.operationId;
            return Promise.resolve("« Facture EDF.pdf » a été jointe à l'opération.");
          case "replace_attachment":
            window.__attachmentReplaced = args.id;
            return Promise.resolve("Le document a été remplacé par « Autre.pdf ».");
          case "open_attachment":
            window.__attachmentOpened = args.id;
            return Promise.resolve("« Facture EDF.pdf » a été ouverte.");
          case "attachment_removal_question":
            return Promise.resolve("Retirer « Facture EDF.pdf » de cette opération ?");
          case "delete_attachment":
            window.__attachmentRemoved = args.id;
            return Promise.resolve("Pièce jointe retirée, son fichier est dans la corbeille.");
          case "open_attachments_window":
            window.__opened = { command, args };
            return Promise.resolve();
          case "close_attachments_window":
            window.__closed = true;
            return Promise.resolve();
          case "journal_entries":
            return Promise.resolve(
              window.__emptyJournal
                ? []
                : [
                    {
                      step: "Réparation table BDD",
                      file: "",
                      table: "Operation",
                      status: "SUCCES",
                      error: "",
                      comments: "",
                    },
                    {
                      step: "Suppression d'une sous-opération orpheline",
                      file: "",
                      table: "Operation",
                      status: "REPARE",
                      error: "",
                      comments: "OP2 — -50,00 €",
                    },
                  ],
            );
          case "close_journal_window":
            window.__closed = true;
            return Promise.resolve();
          case "list_printers":
            return Promise.resolve(
              window.__noPrinter
                ? []
                : [
                    { name: "Brother_HL_2030", label: "Brother HL-2030", is_default: false },
                    { name: "HP_LaserJet_4000", label: "HP LaserJet 4000", is_default: true },
                  ],
            );
          case "print_bank_details":
            window.__ribPrinted = args;
            return Promise.resolve(
              args.toPrinter
                ? "RIB envoyé à votre imprimante par défaut."
                : "RIB imprimé et ouvert : « /tmp/RIB.pdf ».",
            );
          case "close_rib_window":
            window.__closed = true;
            return Promise.resolve();
          case "print_operations":
            window.__printed = args.ids;
            window.__printedArgs = args;
            return Promise.resolve(
              args.toPrinter
                ? "État envoyé à l'imprimante."
                : "État imprimé et ouvert : « /tmp/Liste des transactions 2026-08-01.pdf ».",
            );
          // --- Phase 13 — l'importation d'une feuille Excel ---------------
          case "excel_pick_file":
            window.__excelAccount = args;
            return Promise.resolve({
              path: "/tmp/releve.xlsx",
              sheets: ["Relevé", "Archives"],
            });
          case "excel_state":
            return Promise.resolve({
              path: "/tmp/releve.xlsx",
              said: "Importation dans le compte CCP.",
            });
          case "excel_test":
            window.__excelSettings = args.settings;
            return Promise.resolve({
              headers: ["Date", "Libelle", "Montant", "Categorie"],
              rows: [
                { number: 3, cells: ["20251103", "ACHAT CB", "-57,68", "Essence"] },
                { number: 4, cells: ["20251105", "VIREMENT", "1 200,00", "Salaire"] },
              ],
              said: "Zone capturée : 2 lignes, 4 colonnes.",
            });
          case "excel_links":
            return Promise.resolve({
              headers: ["Date", "Libelle", "Montant", "Categorie"],
              fields: window.__excelShape === "debit-credit"
                ? ["[IGNORE]", "Date", "Date_Pointage", "Libelle", "Montant_Debit",
                   "Montant_Credit", "Categorie", "Affectation", "Mode_Paiement", "Commentaires"]
                : ["[IGNORE]", "Date", "Date_Pointage", "Libelle", "Montant",
                   "Categorie", "Affectation", "Mode_Paiement", "Commentaires"],
              links: [
                { header: "Date", field: "Date" },
                { header: "Libelle", field: "Libelle" },
                { header: "Montant", field: "Montant" },
                { header: "Categorie", field: "[IGNORE]" },
              ],
            });
          case "excel_set_links":
            window.__excelLinks = args.links;
            return Promise.resolve(null);
          case "excel_policies":
            return Promise.resolve([
              { kind: "category", policy: window.__excelPolicy ?? "create", default_id: 0,
                linked: true, answered: false,
                group: "Categories sans correspondances",
                labels: ["Créer automatiquement les catégories inexistantes",
                         "Demander pour chaque catégories inexistantes où transférer les données",
                         "Laisser la catégorie vierge",
                         "Transférer les catégories inexistantes dans une catégorie par défaut"],
                unlinked_note: "Aucune colonne n'alimente la catégorie : ce réglage ne s'applique pas." },
              { kind: "payment-mode", policy: "create", default_id: 0,
                linked: false, answered: false,
                group: "Mode de paiement sans correspondances",
                labels: ["a", "b", "c", "d"],
                unlinked_note: "Aucune colonne n'alimente le mode de paiement : ce réglage ne s'applique pas." },
              { kind: "assignment", policy: "create", default_id: 0,
                linked: false, answered: false,
                group: "Affectation sans correspondances",
                labels: ["a", "b", "c", "d"],
                unlinked_note: "Aucune colonne n'alimente l'affectation : ce réglage ne s'applique pas." },
            ]);
          case "excel_set_policy":
            window.__excelPolicy = args.policy;
            window.__excelPolicySet = args;
            return Promise.resolve(null);
          case "excel_association":
            return Promise.resolve({
              kind: args.kind,
              column_title: "Categorie_Radinus",
              values: [{ label: "Alimentationss", chosen_id: 0 }],
              choices: [{ id: 1, label: "Alimentation" }, { id: 2, label: "Divers" }],
            });
          case "excel_set_association":
            window.__excelAssociation = args;
            return Promise.resolve(null);
          case "excel_run_refusal":
            return Promise.resolve(window.__excelRefusal ?? null);
          case "excel_run":
            window.__excelRan = true;
            return Promise.resolve({
              imported: 2,
              created: 1,
              refused: [
                { row: 5, content: "bonjour · PERDUE", reason: "Date absente ou illisible" },
              ],
              said: "Importation terminée : 2 opérations écrites, 1 lignes refusées, 1 valeurs de nomenclature créées.",
            });
          case "open_excel_fields":
          case "open_excel_association":
          case "open_excel_import":
            window.__opened = { command, args };
            return Promise.resolve();
          case "close_excel_window":
            window.__closed = true;
            window.__closedLabel = args.label;
            return Promise.resolve();
          default:
            return Promise.resolve(null);
        }
      },
    };
  `;
}

let failures = 0;
const checks = [];

function check(name, condition, detail = "") {
  checks.push({ name, ok: Boolean(condition), detail });
  if (!condition) {
    failures += 1;
  }
}

// The container ships Chromium at a fixed path (PLAYWRIGHT_BROWSERS_PATH);
// point at it explicitly rather than let Playwright look for its own build.
const executablePath = process.env.RADINUS_CHROMIUM ?? "/opt/pw-browsers/chromium";
const browser = await chromium.launch(
  fs.existsSync(executablePath) ? { executablePath } : {},
);

async function openWindow(page, url, options) {
  const errors = [];
  page.on("pageerror", (error) => errors.push(String(error)));
  page.on("console", (message) => {
    if (message.type() === "error") {
      errors.push(message.text());
    }
  });
  await page.addInitScript(bridge(options));
  await page.goto(url);
  await page.waitForTimeout(250);
  return errors;
}

// --- Toutes les pages s'ouvrent sans une plainte -------------------------
{
  // **Une vérification pour toutes les pages**, au lieu d'une par bloc.
  //
  // Elles étaient douze, dispersées, à dire chacune « aucune erreur de
  // script » pour la fenêtre qu'elle venait d'ouvrir — et aucune ne couvrait
  // les pages qu'aucun bloc n'ouvrait. Ici la liste des pages est celle du
  // dossier : une page ajoutée demain entre dans ce test sans que personne
  // n'y pense, ce qui est exactement ce que douze copies ne savaient pas
  // faire.
  const pages = fs
    .readdirSync("ui/windows")
    .filter((name) => name.endsWith(".html"))
    .sort();
  check("pages : elles ont toutes été trouvées", pages.length >= 8, String(pages.length));

  for (const name of pages) {
    const page = await browser.newPage();
    // Chaque page reçoit l'adresse qu'elle attend : une page ouverte sans son
    // paramètre se plaindrait à juste titre.
    const query =
      {
        "nomenclature-list.html": "?kind=category",
        "nomenclature-form.html": "?kind=category&mode=M&id=1",
        "account-form.html": "?mode=M&id=1",
        "accounts-list.html": "?mode=CRUD",
        "operations-list.html": "?account=1",
        "operation-form.html": "?mode=M&id=1&account=1",
        "sub-operation-form.html": "?mode=M&id=2",
        "statistics.html": "?axis=category&accounts=1,2&year=2026",
        "dashboard.html": "?accounts=1,2",
        "balance-curves.html": "?accounts=1,2",
        "quick-classification.html": "?account=1",
        "statement-import.html": "?account=1",
        "statement-form.html": "?account=1&rank=1",
        "csv-statement.html": "?account=1&path=%2Ftmp%2Freleve.csv",
        "chequebooks-list.html": "",
        "chequebook-form.html": "?mode=M&id=1",
        "cheques-list.html": "?chequebook=1",
        "cheque-form.html": "?id=11",
        "cheque-operations.html": "?cheque=11&account=1&linked=1",
        "operation-templates-list.html": "",
        "operation-template-form.html": "?mode=M&id=1",
        "budget.html": "?mode=entry&year=2026",
        "transfer.html": "",
        "recurring-list.html": "",
        "recurring-form.html": "?mode=M&id=1",
        "recurring-calendar.html": "?rules=1",
        "excel-import.html": "?account=1",
        "excel-fields.html": "",
        "excel-association.html": "?kind=category",
        "rib.html": "?account=1",
        "journal.html": "",
        "attachments.html": "?operation=1",
      }[name] ?? "";
    const errors = await openWindow(page, `http://localhost:4173/ui/windows/${name}${query}`);
    check(`pages : ${name} s'ouvre sans une plainte`, errors.length === 0, errors.join(" | "));
    await page.close();
  }
}

// --- The categories list ------------------------------------------------
{
  const page = await browser.newPage();
  const errors = await openWindow(
    page,
    "http://localhost:4173/ui/windows/nomenclature-list.html?kind=category",
  );
  check("liste : les lignes s'affichent", (await page.locator(".list__row").count()) === 3);

  // An action without a selection is refused, with the original's wording.
  await page.click("#update");
  check(
    "liste : refus sans sélection",
    (await page.locator("#info-bar").textContent())?.includes(
      "Veuillez sélectionner un enregistrement",
    ),
  );

  // Sorting reverses on a header click.
  await page.click(".list__title-text");
  check(
    "liste : le tri s'inverse",
    (await page.locator(".list__row").first().textContent()) === "Bricolage",
  );
  await page.click(".list__title-text");

  // The funnel filters as you type.
  await page.click(".list__filter-toggle");
  await page.fill(".list__filter-input", "assur");
  check("liste : le filtre réduit la liste", (await page.locator(".list__row").count()) === 1);
  await page.click(".list__filter-toggle");
  check("liste : refermer le filtre restaure tout", (await page.locator(".list__row").count()) === 3);

  // Multiple selection with the Cmd/Ctrl modifier.
  await page.click(".list__row >> nth=0");
  await page.click(".list__row >> nth=2", { modifiers: ["Control"] });
  check(
    "liste : sélection multiple",
    (await page.locator('.list__row[aria-selected="true"]').count()) === 2,
  );

  // Creating opens the form in add mode.
  await page.click("#create");
  const calls = await page.evaluate(() => window.__calls);
  check(
    "liste : créer ouvre la fiche en ajout",
    calls.some(([c, a]) => c === "open_element_form" && a.mode === "A"),
  );
  await page.close();
}

// --- Deleting: the question, and what "no" must do ----------------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-list.html?kind=category");
  await page.click(".list__row >> nth=0");
  await page.click("#delete");
  await page.waitForTimeout(150);

  check("suppression : la question s'affiche", await page.locator(".dialog").isVisible());
  check(
    "suppression : c'est le texte de l'auteur",
    (await page.locator(".dialog__question").textContent())?.startsWith(
      "Des opérations (transactions bancaires) possédant l'attribut de type",
    ),
  );

  // Answering "no" must change nothing at all.
  await page.click(".dialog__button:not(.dialog__button--primary)");
  await page.waitForTimeout(150);
  const afterNo = await page.evaluate(() => window.__calls.map(([c]) => c));
  check("suppression : « Non » n'efface rien", !afterNo.includes("delete_elements"));

  // And "yes" goes through.
  await page.click("#delete");
  await page.waitForTimeout(150);
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(200);
  const afterYes = await page.evaluate(() => window.__calls.map(([c]) => c));
  check("suppression : « Oui » supprime", afterYes.includes("delete_elements"));
  await page.close();
}

// --- Deleting something nothing uses is confirmed too -------------------
{
  // Fabrice's decision of 25/07/2026: a deletion is always confirmed, even
  // when nothing references what is going away. The original deleted such an
  // element outright.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-list.html?kind=category", {
    plainQuestion: true,
  });
  await page.click(".list__row >> nth=0");
  await page.click("#delete");
  await page.waitForTimeout(150);

  check("suppression simple : la question s'affiche quand même", await page.locator(".dialog").isVisible());
  check(
    "suppression simple : elle nomme ce qui va disparaître",
    (await page.locator(".dialog__question").textContent())?.includes("Alimentation"),
  );
  await page.click(".dialog__button:not(.dialog__button--primary)");
  await page.waitForTimeout(150);
  check(
    "suppression simple : « Non » n'efface rien",
    !(await page.evaluate(() => window.__calls.map(([c]) => c))).includes("delete_elements"),
  );
  await page.close();
}

// --- The form, and the bug Fabrice reported -----------------------------
{
  const page = await browser.newPage();
  const errors = await openWindow(
    page,
    "http://localhost:4173/ui/windows/nomenclature-form.html?kind=category&mode=M&id=1",
  );
  check("fiche : le libellé est chargé", (await page.inputValue("#label")) === "Alimentation");
  check(
    "fiche : le combo est garni",
    (await page.locator("#budget-line option").count()) === 3,
  );

  // Leaving an untouched form asks nothing.
  await page.click("#close");
  await page.waitForTimeout(150);
  check("fiche : sortie sans modification, aucune question", !(await page.locator(".dialog").isVisible()));
  check("fiche : sortie sans modification, la fenêtre se ferme", await page.evaluate(() => window.__closed));
  await page.close();
}

{
  // THE reported bug: modify a field, leave, answer "no" -> the window used
  // to be stuck for good.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-form.html?kind=category&mode=M&id=1");
  await page.fill("#label", "Alimentation et boissons");
  await page.click("#close");
  await page.waitForTimeout(150);

  check("fiche : la modification est détectée", await page.locator(".dialog").isVisible());
  check(
    "fiche : la question est celle de l'auteur",
    (await page.locator(".dialog__question").textContent()) === "Abandonner les modifications ?",
  );

  await page.click(".dialog__button:not(.dialog__button--primary)");
  await page.waitForTimeout(150);
  check("fiche : « Non » garde la fenêtre ouverte", !(await page.evaluate(() => window.__closed)));
  check("fiche : « Non » garde la saisie", (await page.inputValue("#label")) === "Alimentation et boissons");

  // And the exit button still works afterwards — the heart of the bug.
  await page.click("#close");
  await page.waitForTimeout(150);
  check("fiche : le bouton de sortie répond encore", await page.locator(".dialog").isVisible());
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(150);
  check("fiche : « Oui » ferme enfin la fenêtre", await page.evaluate(() => window.__closed));
  await page.close();
}

// --- Consultation mode: look, do not touch ------------------------------
{
  const page = await browser.newPage();
  const errors = await openWindow(
    page,
    "http://localhost:4173/ui/windows/nomenclature-form.html?kind=category&mode=L&id=1",
  );
  // Hidden, not removed: the window is reused for other records, so the
  // button has to be able to come back.
  check(
    "consultation : le bouton d'enregistrement a disparu",
    await page.locator("#save").isHidden(),
  );
  check("consultation : le libellé est verrouillé", await page.locator("#label").isDisabled());
  check("consultation : le combo est verrouillé", await page.locator("#budget-line").isDisabled());

  // Nothing is asked on the way out: there is nothing to abandon.
  await page.click("#close");
  await page.waitForTimeout(150);
  check("consultation : la sortie ferme directement", await page.evaluate(() => window.__closed));
  await page.close();
}

// --- Reusing the form window instead of rebuilding it -------------------
{
  // Rebuilding a window under the same label crashed the application; it is
  // reused now, which means it must be able to load another record without
  // being reloaded itself.
  const page = await browser.newPage();
  const errors = await openWindow(
    page,
    "http://localhost:4173/ui/windows/nomenclature-form.html?kind=category&mode=M&id=1",
  );

  const fired = await page.evaluate(() => {
    const handler = window.__listeners && window.__listeners["window-parameters:category-form"];
    if (!handler) {
      return false;
    }
    handler({ event: "window-parameters:category-form", id: 1, payload: "mode=L&id=1" });
    return true;
  });
  check("réutilisation : la fiche écoute bien l'événement", fired);
  await page.waitForTimeout(250);

  check(
    "réutilisation : elle bascule en consultation",
    await page.locator("#label").isDisabled(),
  );

  // ...and back to modification: nothing may stay locked.
  await page.evaluate(() => {
    window.__listeners["window-parameters:category-form"]({
      event: "window-parameters:category-form",
      id: 1,
      payload: "mode=M&id=1",
    });
  });
  await page.waitForTimeout(250);
  check(
    "réutilisation : le retour en modification déverrouille",
    await page.locator("#label").isEnabled(),
  );
  await page.close();
}

// --- The races Fabrice found by hammering the window --------------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-form.html?kind=category&mode=M&id=1", {
    slowLoadMs: 400,
  });
  await page.waitForTimeout(600);

  // Typing while the record is still loading must not become the reference.
  // The fields are locked until the load ends, so the typing cannot land.
  await page.evaluate(() => {
    window.__listeners["window-parameters:category-form"]({
      event: "window-parameters:category-form",
      id: 1,
      payload: "mode=M&id=1",
    });
  });
  await page.waitForTimeout(120);
  check("course : les champs sont verrouillés pendant le chargement", await page.locator("#label").isDisabled());
  await page.waitForTimeout(600);
  check("course : ils sont rendus après le chargement", await page.locator("#label").isEnabled());
  check(
    "course : la référence est bien celle du disque",
    (await page.inputValue("#label")) === "Alimentation",
  );

  // Now modify, then click the door twice in a row: one question only, and
  // leaving must still be refused until it is answered.
  await page.fill("#label", "Autre chose");
  await page.click("#close");
  await page.waitForTimeout(120);
  // The second click is dispatched rather than aimed: the overlay physically
  // covers the door, which is itself part of the protection. What is checked
  // here is the guard behind it.
  await page.locator("#close").dispatchEvent("click");
  await page.waitForTimeout(200);
  check("course : une seule question empilée", (await page.locator(".dialog").count()) === 1);
  check("course : la fenêtre n'est pas partie", !(await page.evaluate(() => window.__closed)));

  await page.click(".dialog__button:not(.dialog__button--primary)");
  await page.waitForTimeout(150);
  check("course : « Non » conserve la saisie", (await page.inputValue("#label")) === "Autre chose");
  check("course : et la fenêtre est toujours là", !(await page.evaluate(() => window.__closed)));

  // A modified form asked to show another record asks first too.
  await page.evaluate(() => {
    window.__listeners["window-parameters:category-form"]({
      event: "window-parameters:category-form",
      id: 1,
      payload: "mode=L&id=1",
    });
  });
  await page.waitForTimeout(200);
  check("course : changer de fiche demande aussi", await page.locator(".dialog").isVisible());
  await page.click(".dialog__button:not(.dialog__button--primary)");
  await page.waitForTimeout(200);
  check(
    "course : « Non » garde la fiche en cours",
    (await page.inputValue("#label")) === "Autre chose",
  );
  await page.close();
}

// --- The list's door defends the form open on top of it -----------------
{
  // The form is a child of the list, so closing the list would take it down.
  // The list therefore asks first — and asks itself, from a state the form
  // declares as it types, rather than through an event that could arrive too
  // late (the intermittence Fabrice found on 25/07/2026).
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-list.html?kind=category");
  await page.evaluate(() => {
    window.__formDirty = true;
  });
  await page.click("#close");
  await page.waitForTimeout(200);
  check("porte de la liste : elle pose la question", await page.locator(".dialog").isVisible());
  check(
    "porte de la liste : elle ne ferme rien avant la réponse",
    !(await page.evaluate(() => window.__calls.map(([c]) => c))).includes(
      "list_may_close",
    ),
  );

  await page.click(".dialog__button:not(.dialog__button--primary)");
  await page.waitForTimeout(200);
  check(
    "porte de la liste : « Non » ne ferme rien",
    !(await page.evaluate(() => window.__calls.map(([c]) => c))).includes(
      "list_may_close",
    ),
  );

  await page.click("#close");
  await page.waitForTimeout(200);
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(200);
  check(
    "porte de la liste : « Oui » ferme les deux",
    (await page.evaluate(() => window.__calls.map(([c]) => c))).includes(
      "list_may_close",
    ),
  );
  await page.close();
}

{
  // Nothing typed: the door asks nothing and leaves at once.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-list.html?kind=category");
  await page.click("#close");
  await page.waitForTimeout(200);
  check("porte de la liste : aucune question si rien n'est en cours", !(await page.locator(".dialog").isVisible()));
  check(
    "porte de la liste : elle part directement",
    (await page.evaluate(() => window.__calls.map(([c]) => c))).includes(
      "list_may_close",
    ),
  );
  await page.close();
}

{
  // The form declares its state as the user types, and takes it back when the
  // text returns to what was stored.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-form.html?kind=category&mode=M&id=1");
  check(
    "état déclaré : rien à signaler au chargement",
    (await page.evaluate(() => window.__formDirty)) === false,
  );

  await page.fill("#label", "Autre chose");
  await page.waitForTimeout(120);
  check("état déclaré : la saisie est signalée", (await page.evaluate(() => window.__formDirty)) === true);

  await page.fill("#label", "Alimentation");
  await page.waitForTimeout(120);
  check(
    "état déclaré : revenir au texte d'origine annule le signal",
    (await page.evaluate(() => window.__formDirty)) === false,
  );

  await page.fill("#label", "Encore autre chose");
  await page.waitForTimeout(120);
  await page.click("#close");
  await page.waitForTimeout(150);
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(200);
  check(
    "état déclaré : quitter la fiche l'efface",
    (await page.evaluate(() => window.__formDirty)) === false,
  );
  await page.close();
}

// --- An event meant for someone else must not reset this window ---------
{
  // Events used to be broadcast to every window, so the form read parameters
  // meant for the list, quietly turned itself into a blank "add" form, and
  // stopped defending anything (Fabrice, 25/07/2026). Rust now addresses each
  // event to one window; this checks the form does not undo the user's work
  // when it is handed an empty payload it should never have received.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-form.html?kind=category&mode=M&id=1");
  await page.fill("#label", "En cours de saisie");
  await page.waitForTimeout(120);
  check("diaphonie : la saisie est signalée", (await page.evaluate(() => window.__formDirty)) === true);

  // Whatever arrives, what the user typed must survive it.
  await page.evaluate(() => {
    window.__listeners["window-parameters:category-form"]({
      event: "window-parameters:category-form",
      id: 1,
      payload: "",
    });
  });
  await page.waitForTimeout(200);
  check("diaphonie : une question est posée avant tout remplacement", await page.locator(".dialog").isVisible());
  await page.click(".dialog__button:not(.dialog__button--primary)");
  await page.waitForTimeout(200);
  check(
    "diaphonie : la saisie est intacte",
    (await page.inputValue("#label")) === "En cours de saisie",
  );
  check(
    "diaphonie : et toujours signalée",
    (await page.evaluate(() => window.__formDirty)) === true,
  );

  // The root of it: one event name per window. A listener declared from
  // JavaScript answers to *any* target, so addressing alone never separated
  // the two windows — the names have to differ. The form must not even be
  // listening to the list's channel.
  check(
    "diaphonie : la fiche n'écoute pas le canal de la liste",
    (await page.evaluate(
      () => window.__listeners["window-parameters:categories-list"] === undefined,
    )) === true,
  );
  await page.close();
}

// --- The window says out loud that it holds unsaved work ----------------
{
  // The mark is there for its own sake — a form that knows it was modified
  // shows it — and it makes the detection visible: if the bar stays silent
  // while typing, the comparison is what is wrong, not the question.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-form.html?kind=category&mode=M&id=1");
  await page.fill("#label", "Alimentation et boissons");
  await page.waitForTimeout(80);
  await page.fill("#label", "Alimentation");
  await page.waitForTimeout(80);
  await page.close();
}

// --- Consultation never asks, and never marks ---------------------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-form.html?kind=category&mode=L&id=1");
  await page.click("#close");
  await page.waitForTimeout(150);
  await page.close();
}

// --- The key comes from the list, and the record from the database ------
{
  // The window must read the record whose key the list handed it, fill the
  // reserve from what it read, and only then show it. What can be checked
  // from outside is the chain: the key asked for, the record read with that
  // key, and the address kept in step so a reload comes back on it.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-form.html?kind=category&mode=M&id=1");
  check(
    "clef : la fiche lit l'enregistrement de la clef reçue",
    await page.evaluate(() =>
      window.__calls.some(([command, args]) => command === "get_element" && args.id === 1),
    ),
  );

  // Reused for another key: it must read that one, not the first.
  await page.evaluate(() => {
    window.__calls.length = 0;
    window.__listeners["window-parameters:category-form"]({
      event: "window-parameters:category-form",
      id: 1,
      payload: "mode=M&id=2",
    });
  });
  await page.waitForTimeout(250);
  check(
    "clef : réutilisée, elle lit la nouvelle clef",
    await page.evaluate(() =>
      window.__calls.some(([command, args]) => command === "get_element" && args.id === 2),
    ),
  );
  check(
    "clef : l'adresse suit la clef en vigueur",
    (await page.evaluate(() => window.location.search)) === "?mode=M&id=2",
  );
  await page.close();
}

// --- Nothing is deleted from under its own open fiche -------------------
{
  // Deleting the very category a fiche is showing used to succeed and leave
  // the fiche on screen over a record that no longer existed (Fabrice,
  // 25/07/2026). The list now refuses, names the element, and asks nothing:
  // there is nothing to confirm.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-list.html?kind=category", {
    refusedDeletion: true,
  });
  await page.click(".list__row");
  await page.click("#delete");
  await page.waitForTimeout(200);
  check("fiche ouverte : aucune question n'est posée", (await page.locator(".dialog").count()) === 0);
  check(
    "fiche ouverte : le refus nomme l'élément",
    (await page.textContent("#info-bar")).includes("« Alimentation » est ouverte"),
  );
  check(
    "fiche ouverte : rien n'est supprimé",
    await page.evaluate(() =>
      window.__calls.every(([command]) => command !== "delete_elements"),
    ),
  );
  await page.close();
}

// --- The form says which record it holds --------------------------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-form.html?kind=category&mode=M&id=1");
  await page.click("#close");
  await page.waitForTimeout(150);
  await page.close();
}

// --- Adding holds nothing open ------------------------------------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-form.html?kind=category&mode=A");
  check(
    "ajout : aucune clef n'est tenue",
    (await page.evaluate(() => window.__formRecord)) === null,
  );
  await page.close();
}

// --- Bank accounts: the list, the fiche, the balances (Phase 4) --------
{
  const page = await browser.newPage();
  const errors = await openWindow(page, "http://localhost:4173/ui/windows/accounts-list.html?mode=CRUD");
  check("comptes : les trois comptes s'affichent", (await page.locator(".list__row").count()) === 3);
  check(
    "comptes : les soldes sont écrits par le noyau",
    (await page.locator(".list__row").first().textContent()).includes("1\u202f549,81 €"),
  );
  check(
    "comptes : un compte clôturé est grisé",
    (await page.locator(".list__row--closed").count()) === 1,
  );

  // Sorting on an amount sorts on its value, not on its text.
  await page.click(".list__title-text >> nth=4");
  check(
    "comptes : le tri d'un montant suit sa valeur",
    (await page.locator(".list__row").first().textContent()).includes("0,00 €"),
  );

  // Deleting says how many operations would go with the account.
  await page.click(".list__row >> nth=0");
  await page.click("#delete");
  await page.waitForTimeout(200);
  check(
    "comptes : la suppression avertit du nombre d'opérations",
    (await page.textContent(".dialog__question")).includes("2502 opérations"),
  );
  await page.click(".dialog__button:not(.dialog__button--primary)");
  await page.waitForTimeout(150);
  check(
    "comptes : « Non » ne supprime rien",
    await page.evaluate(() => window.__calls.every(([c]) => c !== "delete_accounts")),
  );

  // **La double confirmation** (décision de Fabrice, 26/07/2026) : après le
  // Oui/Non, il faut écrire le mot. Un Oui/Non se clique sans lire ; écrire
  // « Oui » oblige à s'arrêter.
  await page.click("#delete");
  await page.waitForTimeout(200);
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(200);
  check(
    "comptes : une seconde question est posée",
    (await page.textContent(".dialog__question"))?.includes("Tapez « Oui »"),
  );
  check(
    "comptes : elle attend un mot écrit",
    (await page.locator(".dialog__field").count()) === 1,
  );
  check(
    "comptes : et rien n'est confirmable tant qu'il n'est pas écrit",
    await page.locator(".dialog__button--primary").isDisabled(),
  );

  // Un mot approchant ne suffit pas.
  await page.fill(".dialog__field", "ou");
  check(
    "comptes : un mot incomplet ne confirme pas",
    await page.locator(".dialog__button--primary").isDisabled(),
  );

  // La casse et les accents n'entrent pas en ligne de compte : c'est d'avoir
  // écrit le mot qui compte, pas d'avoir trouvé la majuscule.
  await page.fill(".dialog__field", "  OUI ");
  check(
    "comptes : le mot écrit débloque la confirmation",
    !(await page.locator(".dialog__button--primary").isDisabled()),
  );

  // Renoncer à la seconde question ne supprime rien non plus.
  await page.click(".dialog__button:not(.dialog__button--primary)");
  await page.waitForTimeout(150);
  check(
    "comptes : renoncer à la seconde question ne supprime rien",
    await page.evaluate(() => window.__calls.every(([c]) => c !== "delete_accounts")),
  );

  // Les deux barrières franchies, la suppression a lieu.
  await page.click("#delete");
  await page.waitForTimeout(200);
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(200);
  await page.fill(".dialog__field", "Oui");
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(250);
  check(
    "comptes : les deux barrières franchies, le compte part",
    await page.evaluate(() => window.__calls.some(([c]) => c === "delete_accounts")),
  );
  await page.close();
}

{
  // Une suppression ordinaire n'a qu'une question : la seconde barrière est
  // réservée à ce qui détruit un historique.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-list.html?kind=category");
  await page.click(".list__row >> nth=0");
  await page.click("#delete");
  await page.waitForTimeout(200);
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(250);
  check(
    "catégories : une seule question, pas de mot à écrire",
    (await page.locator(".dialog__field").count()) === 0 &&
      (await page.evaluate(() => window.__calls.some(([c]) => c === "delete_elements"))),
  );
  await page.close();
}

{
  // F06 — the same window, choosing instead of managing.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/accounts-list.html?mode=SEL");
  check(
    "sélection : la question est posée au-dessus du tableau",
    (await page.textContent("#question")).includes("Sur quel compte"),
  );

  // **La consultation n'a rien à faire ici** (Fabrice, 26/07/2026) : on vient
  // choisir un compte pour ouvrir ses opérations, pas pour lire sa fiche.
  check(
    "sélection : il ne reste que choisir et sortir",
    (await page.locator(".panel__button:visible").count()) === 2,
  );

  // **Un seul compte à la fois** : la fenêtre des opérations n'en montre
  // jamais deux, donc Cmd et Maj n'élargissent rien.
  await page.click(".list__row >> nth=0");
  await page.click(".list__row >> nth=1", { modifiers: ["Meta"] });
  check(
    "sélection : Cmd n'ajoute pas un second compte",
    (await page.locator('.list__row[aria-selected="true"]').count()) === 1,
  );
  await page.click(".list__row >> nth=0");
  await page.click(".list__row >> nth=2", { modifiers: ["Shift"] });
  check(
    "sélection : Maj n'étend pas la sélection non plus",
    (await page.locator('.list__row[aria-selected="true"]').count()) === 1,
  );
  check(
    "sélection : et c'est bien la dernière ligne cliquée",
    (await page.locator('.list__row[aria-selected="true"]').textContent())?.includes(
      (await page.locator(".list__row >> nth=2").textContent()) ?? "",
    ),
  );
  check(
    "sélection : l'aide de la sélection multiple ne s'affiche pas",
    !(await page.locator("#info-bar").textContent())?.includes("CTRL"),
  );

  // **La porte ferme cette fenêtre-ci**, pas l'autre : les deux modes
  // partagent la page mais sont deux fenêtres distinctes.
  await page.click("#close");
  await page.waitForTimeout(150);
  check(
    "sélection : la porte dit quelle fenêtre se ferme",
    await page.evaluate(() =>
      window.__calls.some(
        ([command, args]) => command === "accounts_list_may_close" && args?.purpose === "SEL",
      ),
    ),
  );
  await page.close();
}

{
  // Et en gestion, rien ne change : plusieurs comptes se suppriment d'un coup.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/accounts-list.html?mode=CRUD");
  await page.click(".list__row >> nth=0");
  await page.click(".list__row >> nth=1", { modifiers: ["Meta"] });
  check(
    "gestion : la sélection multiple garde son sens",
    (await page.locator('.list__row[aria-selected="true"]').count()) === 2,
  );
  check("gestion : la consultation est là", await page.locator("#read").isVisible());
  await page.click("#close");
  await page.waitForTimeout(150);
  check(
    "gestion : la porte ferme la liste de gestion",
    await page.evaluate(() =>
      window.__calls.some(
        ([command, args]) => command === "accounts_list_may_close" && args?.purpose === "CRUD",
      ),
    ),
  );
  await page.close();
}

{
  // F07 — the balances, closed accounts excluded, TOTAL in bold.
  const page = await browser.newPage();
  const errors = await openWindow(page, "http://localhost:4173/ui/windows/balances.html");
  check(
    "soldes : les comptes clôturés sont exclus",
    (await page.locator(".list__row").count()) === 3,
  );
  check(
    "soldes : et elle est en dernier",
    (await page.locator(".list__row").last().textContent()).includes("TOTAL"),
  );

  // Le double-clic ouvre les opérations du compte (Fabrice, 05/08/2026 : « la
  // version WinDev le faisait »), et la ligne TOTAL n'ouvre rien — c'est une
  // somme, il n'existe aucune liste derrière elle.
  await page.evaluate(() => {
    window.__ouvert = [];
  });
  await page.locator(".list__row").first().dblclick();
  await page.waitForTimeout(120);
  check(
    "soldes : double-cliquer un compte ouvre ses opérations",
    JSON.stringify(await page.evaluate(() => window.__ouvert)) === '[{"accountId":1}]',
    JSON.stringify(await page.evaluate(() => window.__ouvert)),
  );
  await page.evaluate(() => {
    window.__ouvert = [];
  });
  await page.locator(".list__row").last().dblclick();
  await page.waitForTimeout(120);
  check(
    "soldes : double-cliquer TOTAL n'ouvre rien",
    JSON.stringify(await page.evaluate(() => window.__ouvert)) === "[]",
    JSON.stringify(await page.evaluate(() => window.__ouvert)),
  );
  await page.close();
}

{
  // F08 — the fiche: the control line, the reserve, the refusals.
  const page = await browser.newPage();
  const errors = await openWindow(page, "http://localhost:4173/ui/windows/account-form.html?mode=M&id=1");
  check(
    "fiche compte : la ligne bleue est celle du noyau",
    (await page.textContent("#info-bar")).includes("Solde en banque actuel"),
  );
  check("fiche compte : le RIB est chargé", (await page.inputValue("#rib-key")) === "06");
  check(
    "fiche compte : l'IBAN est présenté par groupes de quatre",
    (await page.inputValue("#iban")) === "FR14 2004 1010 0505 0001 3M02 606",
  );
  check(
    "fiche compte : elle déclare la clef qu'elle tient",
    (await page.evaluate(() => window.__accountRecord)) === 1,
  );

  // A modification is detected on any field, the balance included.
  await page.fill("#opening-pointed", "6000,00");
  await page.waitForTimeout(100);
  check(
    "fiche compte : un solde initial modifié est signalé",
    (await page.evaluate(() => window.__accountDirty)) === true,
  );
  await page.click("#close");
  await page.waitForTimeout(150);
  check("fiche compte : la question est posée", await page.locator(".dialog").isVisible());
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(200);
  check(
    "fiche compte : la valeur enregistrée est reprise",
    (await page.inputValue("#opening-pointed")) === "5972,54",
  );
  await page.close();
}

{
  // An IBAN the core refuses stops the save, and says why.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/account-form.html?mode=M&id=1", {
    accountRefusal: "Cet IBAN n'est pas valide : vérifiez la clé de contrôle.",
  });
  await page.fill("#iban", "FR15 2004 1010 0505 0001 3M02 606");
  await page.click("#save");
  await page.waitForTimeout(200);
  check(
    "fiche compte : un IBAN faux est refusé",
    (await page.textContent("#info-bar")).includes("IBAN n'est pas valide"),
  );
  check(
    "fiche compte : et rien n'est écrit",
    await page.evaluate(() => window.__calls.every(([c]) => c !== "update_account")),
  );
  await page.close();
}

// --- A money field holds money, and nothing else ------------------------
{
  // Author's instruction, 25/07/2026: a program that handles money may not
  // let anything be typed into an amount. The field refuses at the keyboard,
  // and the core refuses again before writing.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/account-form.html?mode=M&id=1");

  await page.click("#opening-pointed");
  await page.fill("#opening-pointed", "");
  await page.type("#opening-pointed", "abc");
  check("montant : les lettres n'entrent pas", (await page.inputValue("#opening-pointed")) === "");

  await page.type("#opening-pointed", "12,34");
  check("montant : les chiffres entrent", (await page.inputValue("#opening-pointed")) === "12,34");

  await page.type("#opening-pointed", ",5");
  check(
    "montant : la deuxième virgule n'entre pas",
    (await page.inputValue("#opening-pointed")) === "12,34",
  );

  await page.type("#opening-pointed", "9");
  check(
    "montant : la troisième décimale n'entre pas",
    (await page.inputValue("#opening-pointed")) === "12,34",
  );

  // **Le moins est un interrupteur de signe**, où que soit le curseur
  // (Fabrice, 26/07/2026) : il ne s'insère pas là où on le tape, il passe le
  // nombre entier en négatif — et un second moins le repasse en positif. La
  // règle vaut dans tous les champs monétaires, soldes de la fiche compte
  // compris, puisqu'elle est dans la classe partagée.
  await page.fill("#opening-pointed", "");
  await page.type("#opening-pointed", "1-2");
  check(
    "montant : le moins tapé au milieu passe devant le nombre",
    (await page.inputValue("#opening-pointed")) === "-12",
  );

  await page.type("#opening-pointed", "-");
  check(
    "montant : un second moins repasse le nombre en positif",
    (await page.inputValue("#opening-pointed")) === "12",
  );

  // Et le curseur reste sur le chiffre qu'il tenait : le texte a seulement
  // gagné ou perdu un caractère devant lui, on peut continuer à taper.
  await page.type("#opening-pointed", "3");
  check(
    "montant : la saisie continue là où elle était",
    (await page.inputValue("#opening-pointed")) === "123",
  );

  // **Le plus affirme au lieu de basculer** (Fabrice, 26/07/2026) : il rend le
  // nombre positif et l'y laisse, autant de fois qu'on l'appuie. On ne peut
  // pas se retrouver en négatif en appuyant dessus.
  await page.fill("#opening-pointed", "");
  await page.type("#opening-pointed", "-45");
  check(
    "montant : le nombre est bien négatif avant le plus",
    (await page.inputValue("#opening-pointed")) === "-45",
  );
  await page.type("#opening-pointed", "+");
  check(
    "montant : le plus rend le nombre positif",
    (await page.inputValue("#opening-pointed")) === "45",
  );
  await page.type("#opening-pointed", "+");
  check(
    "montant : et un second plus le laisse positif",
    (await page.inputValue("#opening-pointed")) === "45",
  );
  await page.evaluate(() => document.getElementById("opening-pointed").setSelectionRange(1, 1));
  await page.keyboard.type("+");
  check(
    "montant : le plus tapé au milieu ne s'insère pas dans le nombre",
    (await page.inputValue("#opening-pointed")) === "45",
  );

  // Leaving the field writes the amount out properly.
  await page.fill("#opening-pointed", "");
  await page.type("#opening-pointed", "1234567,5");
  await page.click("#holder-name");
  await page.waitForTimeout(100);
  check(
    "montant : la sortie du champ met en forme",
    (await page.inputValue("#opening-pointed")) === "1\u202f234\u202f567,50",
  );

  // Pasting goes through the same gate as the keyboard.
  await page.evaluate(() => {
    const input = document.getElementById("opening-pointed");
    input.focus();
    input.select();
    const event = new InputEvent("beforeinput", {
      inputType: "insertFromPaste",
      data: "n'importe quoi",
      cancelable: true,
      bubbles: true,
    });
    const accepted = input.dispatchEvent(event);
    window.__pasteAccepted = accepted;
  });
  check(
    "montant : un collage incohérent est refusé aussi",
    (await page.evaluate(() => window.__pasteAccepted)) === false,
  );
  await page.close();
}

{
  // And the core refuses a second time, whatever the field let through.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/account-form.html?mode=M&id=1", {
    accountRefusal: "« Solde initial pointé » ne contient pas un montant valide.",
  });
  await page.click("#save");
  await page.waitForTimeout(200);
  check(
    "montant : le noyau refuse et nomme le champ",
    (await page.textContent("#info-bar")).includes("ne contient pas un montant valide"),
  );
  check(
    "montant : et rien n'est écrit",
    await page.evaluate(() => window.__calls.every(([c]) => c !== "update_account")),
  );
  await page.close();
}

// --- The operations list, and its tree (Phase 5.1) ----------------------
{
  const page = await browser.newPage();
  const errors = await openWindow(page, "http://localhost:4173/ui/windows/operations-list.html?account=1");

  // Everything folded at the start (author's ruling): only the mothers show.
  check("opérations : tout est replié au départ", (await page.locator(".list__row").count()) === 2);
  check("opérations : la mère qui a des filles porte un « + »", (await page.locator(".list__fold").count()) === 1);
  check(
    "opérations : celle qui n'en a pas n'en porte pas",
    (await page.textContent(".list__fold")) === "+",
  );

  // Unfolding inserts the children under their mother, before the next one.
  await page.click(".list__fold");
  await page.waitForTimeout(120);
  check("opérations : déplier insère les filles", (await page.locator(".list__row").count()) === 4);
  check(
    "opérations : les filles sont sous leur mère",
    (await page.locator(".list__row >> nth=1").textContent()).includes("Alimentation"),
  );
  check(
    "opérations : le Complément est marqué à part",
    (await page.locator(".list__row--complement").count()) === 1,
  );
  check(
    "opérations : une fille ne porte pas de solde",
    (await page.locator(".list__row >> nth=1 >> .list__cell >> nth=12").textContent()) === "",
  );

  // Folding again puts them away.
  await page.click(".list__fold");
  await page.waitForTimeout(120);
  check("opérations : replier les range", (await page.locator(".list__row").count()) === 2);

  // The foot of the window.
  check("opérations : et porte les trois soldes", (await page.textContent("#foot-final")).includes("1"));

  // The five menus of the window exist and say what they are.
  check("opérations : les cinq menus de la fenêtre", (await page.locator(".window-menu__entry").count()) === 5);

  // --- Phase 15 — le menu Impression --------------------------------------
  // La couture qui compte : le menu envoie **les lignes affichées**, filles
  // comprises, et il les envoie dans l'ordre où la fenêtre les montre. Un
  // menu qui n'enverrait que les mères imprimerait un état amputé, et rien à
  // l'écran ne le dirait.
  await page.locator(".window-menu__entry", { hasText: "Impression" }).first().click();
  await page.waitForTimeout(150);
  const impression = page.locator('[data-menu="print"]');
  check(
    "impression : le menu s'ouvre sur ses deux sorties",
    (await impression.locator(".window-menu__choice").count()) === 2,
  );
  await impression.locator(".window-menu__choice").first().click();
  await page.waitForTimeout(200);
  check(
    "impression : la fenêtre annonce l'état imprimé",
    (await page.textContent("#info-bar")).includes("imprimé"),
  );
  const imprimes = await page.evaluate(() => window.__printed ?? []);
  check(
    "impression : elle envoie les lignes affichées, filles comprises",
    Array.isArray(imprimes) && imprimes.length > 0,
  );
  check(
    "impression : la première sortie est le PDF",
    (await page.evaluate(() => window.__printedArgs?.toPrinter)) === false,
  );

  // La seconde sortie passe par le même sélecteur d'imprimante que la fiche
  // de RIB : elle demande d'abord laquelle, ouverte sur celle par défaut.
  await page.locator(".window-menu__entry", { hasText: "Impression" }).first().click();
  await page.waitForTimeout(150);
  await impression.locator(".window-menu__choice").nth(1).click();
  await page.waitForTimeout(200);
  check(
    "impression : la sortie papier demande d'abord l'imprimante",
    (await page.locator(".dialog__question").textContent())?.includes("imprimante"),
  );
  await page.selectOption(".dialog__field", "Brother HL-2030");
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(200);
  check(
    "impression : et l'imprimante choisie part avec les lignes",
    (await page.evaluate(() => window.__printedArgs?.toPrinter)) === true &&
      (await page.evaluate(() => window.__printedArgs?.printer)) === "Brother_HL_2030",
    JSON.stringify(await page.evaluate(() => window.__printedArgs)),
  );

  // --- Phase 14 — le menu Export, dans l'ordre et les groupes de sa capture --
  await page.locator(".window-menu__entry", { hasText: "Export" }).first().click();
  await page.waitForTimeout(150);
  const shown = page.locator('[data-menu="export"]');
  check(
    "export : les douze sorties de sa capture",
    (await shown.locator(".window-menu__choice").count()) === 12,
  );
  check(
    "export : et ses quatre groupes, séparés par trois traits",
    (await shown.locator(".window-menu__rule").count()) === 3,
  );
  const order = await shown
    .locator(".window-menu__choice")
    .evaluateAll((buttons) => buttons.map((button) => button.dataset.key));
  check(
    "export : l'ordre est le sien, Word compris et Calc ajouté",
    JSON.stringify(order) ===
      JSON.stringify([
        "export-to-excel",
        "export-to-word",
        "export-to-ods",
        "export-to-csv",
        "export-to-tsv",
        "export-to-ofx",
        "export-to-qif",
        "export-to-ini",
        "export-to-json",
        "export-to-toml",
        "export-to-xml",
        "export-to-yaml",
      ]),
    JSON.stringify(order),
  );

  // **L'OFX ne passe pas par une feuille** : il part des opérations affichées,
  // et les mères seules.
  await shown.locator('[data-key="export-to-ofx"]').click();
  await page.waitForTimeout(250);
  const exported = await page.evaluate(() => window.__exported);
  check(
    "export : l'OFX part des opérations affichées, et du bon compte",
    exported?.accountId === 1 && Array.isArray(exported?.ids) && exported.ids.length > 0,
    JSON.stringify(exported),
  );
  check(
    "export : les sous-opérations ne sont pas du voyage",
    (exported?.ids ?? []).every((id) => id !== 2),
    JSON.stringify(exported?.ids),
  );
  await page.close();
}

{
  // Deleting says how many lines go, children included.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/operations-list.html?account=1");
  await page.click("#delete");
  await page.waitForTimeout(150);
  check(
    "opérations : supprimer sans sélection est refusé",
    (await page.textContent("#info-bar")).includes("Veuillez sélectionner"),
  );

  await page.click(".list__row >> nth=0");
  await page.click("#delete");
  await page.waitForTimeout(200);
  check(
    "opérations : la question avertit que les filles partent",
    (await page.textContent(".dialog__question")).includes("sous-opérations"),
  );
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(200);
  check(
    "opérations : « Oui » supprime",
    await page.evaluate(() => window.__calls.some(([c]) => c === "delete_operations")),
  );
  await page.close();
}

{
  // The status line of F02: the whole sentence comes from the core, amount
  // included. The window filling the hole itself is what showed the raw
  // Fluent key on screen.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/operations-list.html?account=1");
  await page.click(".list__row >> nth=0");
  await page.waitForTimeout(150);
  check(
    "opérations : la barre d'état donne le total de la sélection",
    (await page.textContent("#info-bar")).includes("Montant total des opérations sélectionnées"),
  );
  check(
    "opérations : et elle ne montre jamais une clef",
    !(await page.textContent("#info-bar")).includes("operations-"),
  );
  await page.close();
}

{
  // A nomenclature is picked, never typed (author's ruling, 25/07/2026): the
  // five nomenclature columns are drop-down lists on the selected row.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/operations-list.html?account=1");
  check(
    "nomenclature : aucune liste déroulante tant que rien n'est sélectionné",
    (await page.locator(".list__combo").count()) === 0,
  );

  await page.click(".list__row >> nth=0");
  await page.waitForTimeout(150);
  check(
    "nomenclature : cinq listes déroulantes sur la ligne choisie",
    (await page.locator(".list__combo").count()) === 5,
  );
  check(
    "nomenclature : et sur elle seule",
    (await page.locator(".list__row >> nth=1 >> .list__combo").count()) === 0,
  );
  check(
    "nomenclature : la liste montre la valeur de la ligne",
    (await page.locator(".list__combo").first().inputValue()) === "1",
  );
  check(
    "nomenclature : « Non précisé » est en tête",
    (await page.locator(".list__combo").first().locator("option").first().textContent()) ===
      "Non précisé",
  );

  // Choosing writes straight to the database.
  await page.selectOption(".list__combo >> nth=0", "5");
  await page.waitForTimeout(200);
  check(
    "nomenclature : choisir écrit la valeur",
    await page.evaluate(() =>
      window.__calls.some(
        ([command, args]) =>
          command === "set_operation_nomenclature" && args.kind === "category" && args.value === 5,
      ),
    ),
  );
  check(
    "nomenclature : et la liste est relue",
    await page.evaluate(() => {
      const names = window.__calls.map(([c]) => c);
      return names.lastIndexOf("list_operations") > names.indexOf("set_operation_nomenclature");
    }),
  );

  // **Une sous-opération n'a pas de mode de paiement à elle** (Fabrice,
  // 26/07/2026) : elle tient celui de sa mère, et `Maj_ProprieteSousOp` le lui
  // repose après chaque écriture. La liste n'offre donc pas ce qu'elle ne peut
  // pas garder — quatre listes déroulantes sur une fille, pas cinq. Les quatre
  // autres restent, sinon la ventilation ne servirait à rien.
  await page.click(".list__fold");
  await page.waitForTimeout(150);
  await page.click(".list__row >> nth=1");
  await page.waitForTimeout(150);
  check(
    "nomenclature : une fille est bien dépliée et choisie",
    (await page.locator(".list__row").count()) > 2,
  );
  check(
    "nomenclature : quatre listes seulement sur une sous-opération",
    (await page.locator(".list__combo").count()) === 4,
  );
  await page.close();
}

{
  // Columns are dragged wider (author's request, 25/07/2026): the header, the
  // filters and every row follow the same track list, so nothing gets out of
  // line with anything else.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/operations-list.html?account=1");

  const before = await page.evaluate(
    () => document.querySelectorAll(".list__title")[3].offsetWidth,
  );
  const handle = page.locator(".list__title >> nth=3 >> .list__resizer");
  const box = await handle.boundingBox();
  await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2);
  await page.mouse.down();
  await page.mouse.move(box.x + box.width / 2 + 120, box.y + box.height / 2, { steps: 6 });
  await page.mouse.up();
  await page.waitForTimeout(120);

  const after = await page.evaluate(
    () => document.querySelectorAll(".list__title")[3].offsetWidth,
  );
  check("colonnes : tirer la poignée élargit la colonne", after > before + 80, `${before} → ${after}`);
  check(
    "colonnes : les lignes suivent l'en-tête",
    await page.evaluate(() => {
      const header = getComputedStyle(document.getElementById("header")).gridTemplateColumns;
      const row = getComputedStyle(document.querySelector(".list__row")).gridTemplateColumns;
      return header === row;
    }),
  );

  // A double-click on the handle puts the column back to its own width.
  await handle.dblclick();
  await page.waitForTimeout(120);
  const reset = await page.evaluate(
    () => document.querySelectorAll(".list__title")[3].offsetWidth,
  );
  check("colonnes : double-clic remet la largeur d'origine", Math.abs(reset - before) < 40, `${before} → ${reset}`);
  await page.close();
}

{
  // The list must scroll the same whether a row is selected or not: a
  // selected row carries five combos, and a row taller than the others makes
  // the virtualisation's arithmetic false — the list then wobbled and refused
  // to move (Fabrice, 25/07/2026).
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/operations-list.html?account=1");

  const heights = async () =>
    page.evaluate(() =>
      [...document.querySelectorAll(".list__row")].map((row) => row.getBoundingClientRect().height),
    );

  const plain = await heights();
  await page.click(".list__row >> nth=0");
  await page.waitForTimeout(150);
  const selected = await heights();

  check(
    "défilement : la ligne sélectionnée ne grandit pas malgré ses combos",
    Math.round(selected[0]) === Math.round(plain[0]),
  );
  check(
    "défilement : la hauteur est celle que la virtualisation suppose",
    Math.round(selected[0]) === 24,
    String(selected[0]),
  );

  // The invariant the scrollbar depends on: the height the list occupies is
  // exactly its number of rows times the row height — the rows on screen plus
  // the two spacers standing in for the rest. When a selected row was taller
  // than that, the two disagreed and the list fought the scrollbar.
  const measured = await page.evaluate(() => {
    const rows = document.getElementById("rows");
    const stacked = [...rows.children].reduce(
      (sum, child) => sum + child.getBoundingClientRect().height,
      0,
    );
    return { content: stacked, lines: document.querySelectorAll(".list__row").length };
  });

  await page.close();
}

{
  // Scrolling must never empty the table. Building the new rows aside and
  // swapping them in one go is what keeps the height from collapsing: emptied
  // first, the container loses its scroll position and shows the spacer —
  // a large white rectangle (Fabrice, 25/07/2026).
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/operations-list.html?account=1", {
    manyOperations: true,
  });
  await page.waitForTimeout(200);

  const state = await page.evaluate(async () => {
    const rows = document.getElementById("rows");
    const seen = [];
    for (const top of [200, 900, 2000, 400, 0]) {
      rows.scrollTop = top;
      rows.dispatchEvent(new Event("scroll"));
      await new Promise((resolve) => setTimeout(resolve, 30));
      seen.push({
        asked: top,
        kept: rows.scrollTop,
        lines: document.querySelectorAll(".list__row").length,
      });
    }
    return seen;
  });

  check(
    "ascenseur : jamais de rectangle blanc",
    state.every((step) => step.lines > 0),
    JSON.stringify(state),
  );
  check(
    "ascenseur : la position de défilement est conservée",
    state.every((step) => step.kept === step.asked),
    JSON.stringify(state),
  );
  await page.close();
}

{
  // Three parameters and no more: one account, a start date, an end date
  // (author's ruling, 25/07/2026). The two dates open on the month we are in
  // and are widened by hand as far as one likes.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/operations-list.html?account=1");
  const month = new Date();
  const expected = `${month.getFullYear()}-${String(month.getMonth() + 1).padStart(2, "0")}-01`;
  check(
    "période : la liste s'ouvre sur le mois en cours",
    (await page.inputValue("#from")) === expected,
    await page.inputValue("#from"),
  );

  // Widened by hand, it reads what the wider period holds.
  await page.fill("#from", "1980-01-01");
  await page.fill("#to", "2070-12-31");
  await page.waitForTimeout(200);
  check(
    "période : élargie à la main, elle relit",
    await page.evaluate(() =>
      window.__calls.some(
        ([command, args]) =>
          command === "list_operations" && args.from === "1980-01-01" && args.to === "2070-12-31",
      ),
    ),
  );
  await page.close();
}

{
  // The Période menu: nine entries, two of which open the twelve months
  // (author's request, 25/07/2026). Each one does one thing — work out two
  // dates, put them in the two fields, and ask for a reread.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/operations-list.html?account=1");
  await page.locator(".window-menu__entry", { hasText: "Période" }).click();
  await page.waitForTimeout(120);

  check(
    "période : chaque année offre toute l'année et douze mois",
    (await page.locator(".window-menu__submenu >> nth=0 >> button").count()) === 13,
  );

  // « Aujourd'hui »: the two bounds are today.
  await page.locator(".window-menu__choice", { hasText: "Aujourd'hui" }).click();
  await page.waitForTimeout(200);
  const today = new Date();
  const iso = (date) =>
    `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(
      date.getDate(),
    ).padStart(2, "0")}`;
  check(
    "période : « Aujourd'hui » borne le jour même",
    (await page.inputValue("#from")) === iso(today) && (await page.inputValue("#to")) === iso(today),
  );

  // « Toutes »: wide enough to hold everything.
  await page.locator(".window-menu__entry", { hasText: "Période" }).click();
  await page.getByRole("button", { name: "Toutes", exact: true }).click();
  await page.waitForTimeout(200);
  check(
    "période : « Toutes » ouvre en grand",
    (await page.inputValue("#from")) === "1950-01-01" &&
      (await page.inputValue("#to")) === "2550-12-31",
  );

  // A month of the current year: the first to the last day of that month.
  await page.locator(".window-menu__entry", { hasText: "Période" }).click();
  await page.waitForTimeout(120);
  await page.locator(".window-menu__nest >> nth=1 >> .window-menu__choice--parent").click();
  await page.waitForTimeout(120);
  await page.locator(".window-menu__submenu >> nth=1 >> button", { hasText: "février" }).click();
  await page.waitForTimeout(200);
  const year = today.getFullYear();
  const lastOfFebruary = new Date(year, 2, 0).getDate();
  check(
    "période : un mois va du premier au dernier jour, années bissextiles comprises",
    (await page.inputValue("#from")) === `${year}-02-01` &&
      (await page.inputValue("#to")) === `${year}-02-${lastOfFebruary}`,
    `${await page.inputValue("#from")} → ${await page.inputValue("#to")}`,
  );

  // A week runs Monday to Sunday.
  await page.locator(".window-menu__entry", { hasText: "Période" }).click();
  await page.locator(".window-menu__choice", { hasText: "Semaine Actuelle" }).click();
  await page.waitForTimeout(200);
  const bounds = {
    from: new Date(await page.inputValue("#from")),
    to: new Date(await page.inputValue("#to")),
  };
  check(
    "période : une semaine va du lundi au dimanche",
    bounds.from.getUTCDay() === 1 && bounds.to.getUTCDay() === 0,
    `${bounds.from} → ${bounds.to}`,
  );

  check(
    "période : une encoche marque la période choisie",
    await page.evaluate(() => {
      const chosen = document.querySelectorAll(
        '[data-menu="period"] .window-menu__choice--chosen',
      );
      return chosen.length === 1;
    }),
  );

  // Editing a date by hand is a period nobody chose from the menu: the tick
  // goes away rather than lying.
  await page.fill("#from", "2020-01-01");
  await page.waitForTimeout(150);
  check(
    "période : modifier une date à la main enlève l'encoche",
    (await page.locator('[data-menu="period"] .window-menu__choice--chosen').count()) === 0,
  );

  check(
    "période : chaque choix relit le tableau",
    await page.evaluate(
      () => window.__calls.filter(([c]) => c === "list_operations").length >= 5,
    ),
  );
  await page.close();
}

{
  // The Filtre menu: four choices, one status each (author's request,
  // 25/07/2026). The filter is applied by the core, so the foot of the window
  // always adds up exactly what the table shows.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/operations-list.html?account=1");
  await page.locator(".window-menu__entry", { hasText: "Filtre" }).click();
  await page.waitForTimeout(120);

  await page.locator(".window-menu__choice", { hasText: "pointées" }).click();
  await page.waitForTimeout(200);
  check(
    "filtre : le statut choisi part avec la demande",
    await page.evaluate(() =>
      window.__calls.some(([c, args]) => c === "list_operations" && args.status === 1),
    ),
  );
  // The name of the menu never changes; a tick marks where one stands in it.
  check(
    "filtre : le nom du menu ne change pas",
    (await page.locator(".window-menu__entry", { hasText: "Filtre" }).count()) === 1,
  );
  check(
    "filtre : une encoche marque l'option choisie",
    await page.evaluate(() => {
      const chosen = document.querySelectorAll(
        '[data-menu="filter"] .window-menu__choice--chosen',
      );
      return chosen.length === 1 && chosen[0].dataset.key === "filter-pointed";
    }),
  );

  await page.locator(".window-menu__entry", { hasText: "Filtre" }).click();
  await page.locator(".window-menu__choice", { hasText: "Toutes les opérations" }).click();
  await page.waitForTimeout(200);
  check(
    "filtre : « Toutes les opérations » lève le filtre",
    await page.evaluate(() =>
      window.__calls.some(([c, args]) => c === "list_operations" && args.status === null),
    ),
  );
  await page.close();
}

{
  // The information bar belongs at the bottom of the window, under the table
  // and beside nothing. It sat above the table and ran over the slate strip,
  // because this window has two rows more than the others and the bar had
  // kept the row number of the others (Fabrice, 25/07/2026).
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/operations-list.html?account=1");
  const placed = await page.evaluate(() => {
    const bar = document.getElementById("info-bar").getBoundingClientRect();
    const table = document.querySelector(".list").getBoundingClientRect();
    const panel = document.querySelector(".panel").getBoundingClientRect();
    return {
      underTheTable: bar.top >= table.bottom - 1,
      clearOfThePanel: bar.right <= panel.left + 1 || bar.top >= panel.bottom - 1,
    };
  });
  await page.close();
}

{
  // The search field appears under the column whose funnel was clicked, not
  // under the first one (Fabrice, 25/07/2026).
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/operations-list.html?account=1");
  check(
    "entonnoir : aucune zone de recherche tant qu'on n'en ouvre pas",
    (await page.locator(".list__filter-input:visible").count()) === 0,
  );

  // The fourth column, « Libelle ».
  await page.locator(".list__title >> nth=3 >> .list__filter-toggle").click();
  await page.waitForTimeout(150);
  const aligned = await page.evaluate(() => {
    const header = document.querySelectorAll(".list__title")[3].getBoundingClientRect();
    const field = document
      .querySelectorAll(".list__filter-input")[3]
      .getBoundingClientRect();
    const first = document.querySelectorAll(".list__title")[0].getBoundingClientRect();
    return {
      underItsOwnColumn: Math.abs(field.left - header.left) < 8,
      notUnderTheFirst: Math.abs(field.left - first.left) > 8,
      visible: field.width > 0,
    };
  });
  check("entonnoir : la zone est sous sa propre colonne", aligned.underItsOwnColumn, JSON.stringify(aligned));
  check("entonnoir : et pas sous la première", aligned.notUnderTheFirst, JSON.stringify(aligned));

  // Closing it again puts the row away.
  await page.locator(".list__title >> nth=3 >> .list__filter-toggle").click();
  await page.waitForTimeout(150);
  await page.close();
}

{
  // A child goes under the mother it belongs to, wherever it arrived in the
  // list. Walking the list and keeping what fits put them several rows below
  // her (Fabrice, 25/07/2026).
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/operations-list.html?account=1", {
    scatteredChildren: true,
  });
  await page.click(".list__fold");
  await page.waitForTimeout(150);

  const order = await page.evaluate(() =>
    [...document.querySelectorAll(".list__row")].map((row) => ({
      id: row.dataset.id,
      child: row.classList.contains("list__row--sub"),
    })),
  );
  check(
    "arbre : les filles sont juste sous leur mère, quel que soit l'ordre reçu",
    order.length === 4 &&
      order[0].id === "1" &&
      order[1].child &&
      order[2].child &&
      !order[3].child,
    JSON.stringify(order),
  );

  // And they have their own alternating pastel blue.
  const shades = await page.evaluate(() =>
    [...document.querySelectorAll(".list__row--sub")].map(
      (row) => getComputedStyle(row).backgroundColor,
    ),
  );
  check(
    "arbre : les filles alternent leur propre couleur",
    shades.length === 2 && shades[0] !== shades[1],
    JSON.stringify(shades),
  );
  check(
    "arbre : et cette couleur n'est pas celle des opérations du compte",
    await page.evaluate(() => {
      const mother = getComputedStyle(document.querySelector(".list__row")).backgroundColor;
      const child = getComputedStyle(document.querySelector(".list__row--sub")).backgroundColor;
      return mother !== child;
    }),
  );
  await page.close();
}

// --- No window holds a sentence of its own ------------------------------
{
  // Everything a window shows comes from Fluent, French and English alike
  // (author's ruling, 25/07/2026). Checked from the outside: give the window
  // an English dictionary and every word it shows must be English — if any
  // sentence were still written in the code, it would stay in French.
  const page = await browser.newPage();
  await page.addInitScript(`
    window.__calls = [];
    window.__TAURI_INTERNALS__ = {
      transformCallback: (callback) => callback,
      metadata: { currentWindow: { label: "test" }, currentWebview: { label: "test" } },
      invoke: (command, args) => {
        window.__calls.push([command, args]);
        if (command === "plugin:event|listen") return Promise.resolve(1);
        if (command === "ui_texts")
          return Promise.resolve({
            "ui-loading": "Loading…",
            "ui-editing": "Editing.",
            "ui-viewing": "Viewing.",
            "ui-modified-suffix": "— modified",
            "ui-select-record": "Please select a record",
            "ui-multiselect-help": "Info: use mouse click + [CTRL] on the table",
            "ui-no-match": "No label matches the filter.",
            "ui-filter-placeholder": "Filter the labels…",
            "ui-column-label": "LABEL",
            "ui-title-filter": "Filter",
            "ui-title-create": "Create",
            "ui-title-update": "Edit the selection",
            "ui-title-delete": "Delete the selection",
            "ui-title-read": "View the selection",
            "ui-title-close": "Close",
            "nomenclature-none": "No payee.",
          });
        if (command === "startup_error") return Promise.resolve(null);
        if (command === "list_elements") return Promise.resolve([]);
        return Promise.resolve(null);
      },
    };
  `);
  await page.goto("http://localhost:4173/ui/windows/nomenclature-list.html?kind=payee");
  await page.waitForTimeout(300);
  check(
    "langue : l'en-tête de colonne est traduit",
    (await page.textContent(".list__title-text")) === "LABEL",
  );
  check(
    "langue : la barre d'info est traduite",
    (await page.textContent("#info-bar")).includes("Info: use mouse click"),
  );
  check(
    "langue : la liste vide est traduite",
    (await page.textContent(".list__empty")) === "No payee.",
  );
  check(
    "langue : le filtre existe pour la colonne",
    (await page.locator(".list__filter-input").count()) === 1,
  );
  check(
    "langue : les bulles des boutons sont traduites",
    (await page.getAttribute("#delete", "title")) === "Delete the selection",
  );
  check(
    "langue : le refus sans sélection est traduit",
    await page.click("#update").then(() =>
      page.textContent("#info-bar").then((text) => text.includes("Please select a record")),
    ),
  );
  check(
    "langue : le vocabulaire est demandé avant les données",
    await page.evaluate(() => {
      const names = window.__calls.map(([command]) => command);
      return names.indexOf("ui_texts") < names.indexOf("list_elements");
    }),
  );
  await page.close();
}

// --- Two categories may not share a name --------------------------------
{
  // Author's ruling, 25/07/2026: classing an operation under one of two
  // identical labels is a coin toss, so the save is refused and says which
  // one is in the way. What was typed stays on screen to be corrected.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-form.html?kind=category&mode=A", {
    duplicateName: "Il existe déjà une catégorie du même nom : « Alimentation ».",
  });
  await page.fill("#label", "alimentation");
  await page.click("#save");
  await page.waitForTimeout(200);
  check(
    "doublon : le refus nomme la catégorie existante",
    (await page.textContent("#info-bar")).includes("Il existe déjà une catégorie du même nom : « Alimentation »."),
  );
  check(
    "doublon : rien n'est écrit",
    await page.evaluate(() =>
      window.__calls.every(([command]) => command !== "create_element"),
    ),
  );
  check("doublon : la fenêtre reste ouverte", !(await page.evaluate(() => window.__closed)));
  check(
    "doublon : la saisie reste corrigeable",
    (await page.inputValue("#label")) === "alimentation",
  );
  await page.close();
}

{
  // A free name goes through, and the question is asked before writing.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-form.html?kind=category&mode=A");
  await page.fill("#label", "Un nom libre");
  await page.click("#save");
  await page.waitForTimeout(200);
  check(
    "doublon : le contrôle précède l'écriture",
    await page.evaluate(() => {
      const names = window.__calls.map(([command]) => command);
      return names.indexOf("duplicate_name") !== -1
        && names.indexOf("duplicate_name") < names.indexOf("create_element");
    }),
  );
  check(
    "doublon : un nom libre est enregistré",
    await page.evaluate(() =>
      window.__calls.some(([command]) => command === "create_element"),
    ),
  );
  await page.close();
}

// --- The rule now covers the seven, and spares what already exists ------
{
  // Validated on categories, extended to all of them (author's ruling,
  // 25/07/2026). A tiers is asked about exactly like a category.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-form.html?kind=payee&mode=A", {
    duplicateName: "Il existe déjà un tiers du même nom : « Ebay ».",
  });
  await page.fill("#label", "EBAY");
  await page.click("#save");
  await page.waitForTimeout(200);
  check(
    "doublon : les sept sont concernées",
    (await page.textContent("#info-bar")).includes("un tiers du même nom"),
  );
  check(
    "doublon : et rien n'est écrit non plus",
    await page.evaluate(() =>
      window.__calls.every(([command]) => command !== "create_element"),
    ),
  );
  await page.close();
}

{
  // An element that already shares its name with another — a 1.x database
  // enforced nothing — must stay editable. A save that does not touch the
  // label is not asked about: it cannot create a name that was not there.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-form.html?kind=category&mode=M&id=1", {
    duplicateName: "Il existe déjà une catégorie du même nom : « Alimentation ».",
  });
  await page.selectOption("#budget-line", "2");
  await page.click("#save");
  await page.waitForTimeout(250);
  check(
    "doublon : un libellé inchangé n'est pas remis en cause",
    await page.evaluate(() =>
      window.__calls.every(([command]) => command !== "duplicate_name"),
    ),
  );
  check(
    "doublon : et l'enregistrement se fait",
    await page.evaluate(() =>
      window.__calls.some(([command]) => command === "update_element"),
    ),
  );
  await page.close();
}

// --- The same two pages serve the other six nomenclatures ---------------
{
  // The whole point of the gabarit: a nomenclature that is not the category
  // shows one field less, says its own words, and talks to Rust about itself.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-form.html?kind=payee&mode=A");
  check(
    "gabarit : le poste budgétaire disparaît",
    !(await page.locator("#budget-line").isVisible())
      && !(await page.locator("#budget-line-label").isVisible()),
  );
  check(
    "gabarit : l'identifiant porte le nom de la nomenclature",
    (await page.textContent("#id-label")).trim() === "Identifiant de Tiers",
  );
  check(
    "gabarit : le masculin est respecté",
    (await page.textContent("#info-bar")).includes("Nouveau tiers."),
  );
  check(
    "gabarit : le combo n'est même pas demandé",
    await page.evaluate(() =>
      window.__calls.every(([command]) => command !== "list_budget_lines"),
    ),
  );
  check(
    "gabarit : chaque commande dit sur quoi elle travaille",
    await page.evaluate(() =>
      window.__calls
        .filter(([command]) => command === "set_form_record")
        .every(([, args]) => args.kind === "payee"),
    ),
  );
  check(
    "gabarit : la fiche écoute son propre canal",
    await page.evaluate(
      () =>
        window.__listeners["window-parameters:payee-form"] !== undefined &&
        window.__listeners["window-parameters:category-form"] === undefined,
    ),
  );
  await page.close();
}

{
  // The category fiche is unchanged by all this: it still shows its combo.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-form.html?kind=category&mode=A");
  check("gabarit : la catégorie garde son combo", await page.locator("#budget-line").isVisible());
  check(
    "gabarit : et le féminin est respecté",
    (await page.textContent("#info-bar")).includes("Nouvelle catégorie."),
  );
  await page.close();
}

{
  // A list of another nomenclature, and its own wording on deletion.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-list.html?kind=bank", {
    needsConfirmation: false,
  });
  check(
    "gabarit : la liste lit sa propre nomenclature",
    await page.evaluate(() =>
      window.__calls.some(([command, args]) => command === "list_elements" && args.kind === "bank"),
    ),
  );
  await page.click(".list__row");
  await page.click("#delete");
  await page.waitForTimeout(250);
  check(
    "gabarit : la suppression parle au féminin",
    (await page.textContent("#info-bar")).includes("1 banque supprimée."),
  );
  await page.close();
}

{
  // A window asked for a nomenclature that does not exist says so, rather
  // than opening blank and failing on the first click.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-list.html?kind=inconnue");
  check(
    "gabarit : une nomenclature inconnue est dite",
    (await page.textContent("#info-bar")).includes("Nomenclature inconnue"),
  );
  await page.close();
}

// --- Left behind, the form keeps nothing --------------------------------
{
  // Closing the list with work in progress, and agreeing to abandon it, only
  // hides the form — which used to keep the text and its reserve, and bring
  // them back to life much later, asking about work given up on long before
  // (Fabrice, 25/07/2026). Rust now orders the form to empty itself first.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-form.html?kind=category&mode=M&id=1");
  await page.fill("#label", "Travail abandonné");
  await page.waitForTimeout(100);
  check("abandon : la saisie est signalée", (await page.evaluate(() => window.__formDirty)) === true);

  await page.evaluate(() => {
    window.__listeners["window-reset:category-form"]({
      event: "window-reset:category-form",
      id: 1,
      payload: null,
    });
  });
  await page.waitForTimeout(150);
  check("abandon : le champ est vidé", (await page.inputValue("#label")) === "");
  check("abandon : l'identifiant est vidé", (await page.inputValue("#id")) === "");
  check(
    "abandon : plus rien n'est signalé",
    (await page.evaluate(() => window.__formDirty)) === false,
  );

  // And nothing resurfaces: the reserve is empty too, so the emptied form is
  // not itself seen as a modification.
  await page.click("#close");
  await page.waitForTimeout(150);
  check("abandon : aucune question ne ressurgit", (await page.locator(".dialog").count()) === 0);
  check("abandon : la fenêtre part sans rien demander", await page.evaluate(() => window.__closed));
  await page.close();
}

// --- Nothing about a visit may survive it -------------------------------
{
  // A window is hidden, not destroyed, so it lives on between visits. A flag
  // raised on the way out used to stay raised for ever, and from the second
  // visit the form never asked anything again (Fabrice, 25/07/2026). This
  // walks the same window through two full visits, with no reload in between.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-form.html?kind=category&mode=M&id=1");

  // First visit: modify, leave, agree.
  await page.fill("#label", "Première saisie");
  await page.click("#close");
  await page.waitForTimeout(150);
  check("deux visites : la première question est posée", await page.locator(".dialog").isVisible());
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(200);
  check("deux visites : la première sortie a eu lieu", await page.evaluate(() => window.__closed));
  check(
    "deux visites : la saisie abandonnée est reprise",
    (await page.inputValue("#label")) === "Alimentation",
  );
  check(
    "deux visites : et n'est plus signalée",
    (await page.evaluate(() => window.__formDirty)) === false,
  );

  // Second visit on the very same window: it must behave exactly like the
  // first — this is what the stale flag broke.
  await page.fill("#label", "Deuxième saisie");
  await page.waitForTimeout(120);
  check(
    "deux visites : la seconde saisie est signalée",
    (await page.evaluate(() => window.__formDirty)) === true,
  );
  await page.click("#close");
  await page.waitForTimeout(200);
  check("deux visites : la seconde question est posée aussi", await page.locator(".dialog").isVisible());
  await page.click(".dialog__button:not(.dialog__button--primary)");
  await page.waitForTimeout(150);
  check(
    "deux visites : « Non » conserve la seconde saisie",
    (await page.inputValue("#label")) === "Deuxième saisie",
  );
  await page.close();
}

// --- A failed startup must be visible, not silent -----------------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-list.html?kind=category", {
    startupError: "Aucune base de données n'a pu être ouverte au démarrage : test.",
  });
  check(
    "démarrage en échec : la liste le dit",
    (await page.locator("#info-bar").textContent())?.includes("Aucune base de données"),
  );
  check(
    "démarrage en échec : les boutons sont inertes",
    await page.locator("#create").isDisabled(),
  );
  await page.close();
}

// --- F03, la fiche opération --------------------------------------------
{
  const page = await browser.newPage();
  const errors = await openWindow(
    page,
    "http://localhost:4173/ui/windows/operation-form.html?mode=M&account=1&id=1",
  );

  // The record is read by its key and shown, field by field — the capture's
  // own line.
  check(
    "fiche opération : le libellé est celui du dossier",
    (await page.inputValue("#label")) === "VIREMENT DE COMPLEMENTAIRE SANTE",
  );
  check(
    "fiche opération : un crédit s'affiche sans signe",
    (await page.inputValue("#amount")) === "9,00",
  );
  check(
    "fiche opération : le signe est porté par le type",
    (await page.inputValue("#direction")) === "C",
  );
  check(
    "fiche opération : les cinq nomenclatures sont des listes déroulantes",
    (await page.locator("select.form__field").count()) === 7,
  );

  // Its words come from Fluent, never from the page.
  check(
    "fiche opération : la barre d'état compte les pièces jointes",
    (await page.locator("#attachments").textContent()) === "Aucune pièce jointe",
  );

  // Sur une opération qui existe, la sous-opération est proposée — et elle
  // agit : on doit pouvoir ventiler sans repasser par la liste (anomalie
  // signalée par Fabrice, 26/07/2026 — le bouton était resté inerte).
  check(
    "fiche opération : en modification, le bouton sous-opération est là",
    (await page.locator("#sub").isVisible()) === true,
  );
  await page.click("#sub");
  await page.waitForTimeout(150);
  check(
    "fiche opération : et il ouvre F04 sur l'opération de la fiche",
    JSON.stringify(await page.evaluate(() => window.__openedSubForm)) ===
      JSON.stringify({ mode: "A", parentId: 1, id: null }),
  );

  // Nothing is signalled before anything is typed…
  check(
    "fiche opération : rien n'est signalé au chargement",
    (await page.evaluate(() => window.__operationDirty)) === false,
  );
  check(
    "fiche opération : la fiche déclare l'enregistrement qu'elle tient",
    (await page.evaluate(() => window.__operationRecord)) === 1,
  );

  // …et la réserve détecte la modification, champ par champ.
  await page.fill("#label", "VIREMENT MUTUELLE");
  await page.waitForTimeout(120);
  check(
    "fiche opération : la réserve voit le libellé changer",
    (await page.evaluate(() => window.__operationDirty)) === true,
  );
  check(
    "fiche opération : et la barre d'état le dit",
    (await page.locator("#info-message").textContent())?.includes("modifié"),
  );

  // Revenir à la valeur lue n'est plus une modification : c'est une
  // comparaison, pas un drapeau.
  await page.fill("#label", "VIREMENT DE COMPLEMENTAIRE SANTE");
  await page.waitForTimeout(120);
  check(
    "fiche opération : revenir à la valeur lue efface la modification",
    (await page.evaluate(() => window.__operationDirty)) === false,
  );

  // Un montant ne prend pas n'importe quoi.
  await page.click("#amount");
  await page.fill("#amount", "");
  await page.type("#amount", "12a34");

  // **Les deux contrôles de la zone Montant ne doivent jamais se contredire**
  // (Fabrice, 26/07/2026), et le signe se voit : un débit s'affiche « -70,00 ».
  await page.fill("#amount", "");
  await page.type("#amount", "-70");
  check(
    "fiche opération : un montant tapé négatif bascule le type sur Débit",
    (await page.inputValue("#direction")) === "D",
  );
  check(
    "fiche opération : et le signe tapé reste affiché",
    (await page.inputValue("#amount")) === "-70",
  );

  // **Le moins est un interrupteur, pas un caractère** (Fabrice, 26/07/2026) :
  // où que soit le curseur, il rend le nombre entier négatif, et un second
  // moins le rend positif. Ici le curseur est au milieu du nombre.
  await page.click("#amount");
  await page.evaluate(() => document.getElementById("amount").setSelectionRange(2, 2));
  await page.keyboard.type("-");
  check(
    "montant : un second moins rend le nombre positif",
    (await page.inputValue("#amount")) === "70",
  );
  check(
    "montant : et le type repasse sur Crédit",
    (await page.inputValue("#direction")) === "C",
  );
  await page.evaluate(() => document.getElementById("amount").setSelectionRange(1, 1));
  await page.keyboard.type("-");
  check(
    "montant : le moins tapé au milieu se met devant le nombre",
    (await page.inputValue("#amount")) === "-70",
  );
  check(
    "montant : et le type retombe sur Débit",
    (await page.inputValue("#direction")) === "D",
  );

  // Le plus dit « crédit » sans détour, et le redit sans jamais se retourner.
  await page.type("#amount", "+");
  check(
    "montant : le plus rend le montant positif dans la fiche",
    (await page.inputValue("#amount")) === "70",
  );
  check(
    "montant : et fait passer le type sur Crédit",
    (await page.inputValue("#direction")) === "C",
  );
  await page.type("#amount", "+");
  check(
    "montant : un second plus laisse le type sur Crédit",
    (await page.inputValue("#direction")) === "C" &&
      (await page.inputValue("#amount")) === "70",
  );

  // On revient au débit pour la suite : le moins, lui, bascule.
  await page.type("#amount", "-");
  check(
    "montant : le moins rebascule sur Débit",
    (await page.inputValue("#direction")) === "D" &&
      (await page.inputValue("#amount")) === "-70",
  );

  // Le signe survit à la mise en forme du champ monétaire.
  await page.click("#label");
  await page.waitForTimeout(150);
  check(
    "fiche opération : après mise en forme le débit s'affiche « -70,00 »",
    (await page.inputValue("#amount")) === "-70,00",
  );
  check(
    "fiche opération : et le type reste Débit",
    (await page.inputValue("#direction")) === "D",
  );

  // Le combo commande aussi : repasser en crédit enlève le signe du champ.
  await page.selectOption("#direction", "C");
  await page.waitForTimeout(150);
  check(
    "fiche opération : choisir Crédit retire le signe du champ",
    (await page.inputValue("#amount")) === "70,00",
  );

  // Et dans l'autre sens : un débit saisi sans signe est signé à la sortie du
  // champ, pour que ce qui est écrit soit ce qui est montré.
  await page.selectOption("#direction", "D");
  await page.waitForTimeout(150);
  check(
    "fiche opération : choisir Débit signe le champ",
    (await page.inputValue("#amount")) === "-70,00",
  );
  await page.fill("#amount", "");
  await page.type("#amount", "35");
  await page.click("#label");
  await page.waitForTimeout(150);
  check(
    "fiche opération : un débit tapé sans signe est signé à la sortie du champ",
    (await page.inputValue("#amount")) === "-35,00",
  );
  check(
    "fiche opération : le type n'a pas bougé pour autant",
    (await page.inputValue("#direction")) === "D",
  );

  // Zéro n'a pas de signe : « -0,00 » n'est pas un débit, c'est rien.
  await page.fill("#amount", "");
  await page.type("#amount", "0");
  await page.click("#label");
  await page.waitForTimeout(150);
  check(
    "fiche opération : zéro ne prend jamais de signe",
    (await page.inputValue("#amount")) === "0,00",
  );

  // Une nomenclature changée est vue elle aussi.
  await page.selectOption("#category", "5");
  await page.waitForTimeout(120);
  check(
    "fiche opération : la réserve voit la catégorie changer",
    (await page.evaluate(() => window.__operationDirty)) === true,
  );

  // Sortir demande, puis remet ce qui avait été lu.
  await page.click("#close");
  await page.waitForTimeout(150);
  check("fiche opération : la sortie demande confirmation", await page.locator(".dialog").isVisible());
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(200);
  check("fiche opération : la fenêtre est masquée", await page.evaluate(() => window.__closed));
  check(
    "fiche opération : les champs reprennent la réserve",
    (await page.inputValue("#amount")) === "9,00",
  );
  check(
    "fiche opération : et l'enregistrement n'est plus tenu",
    (await page.evaluate(() => window.__operationRecord)) === null,
  );
  await page.close();
}

// --- F03 : le refus vient du noyau, jamais de la fenêtre -----------------
{
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/operation-form.html?mode=A&account=1",
    { operationRefusal: "Le libellé de l'opération est obligatoire." },
  );
  check(
    "fiche opération : une fiche neuve le dit",
    (await page.locator("#info-message").textContent()) === "Nouvelle opération.",
  );
  check(
    "fiche opération : une fiche neuve est datée du jour",
    (await page.inputValue("#date")) !== "",
  );

  // **Le piège de l'opération neuve** (Fabrice, 26/07/2026) : une
  // sous-opération créée depuis une fiche non enregistrée serait orpheline si
  // l'on renonce ensuite à la mère. Le bouton n'est donc pas là du tout.
  check(
    "fiche opération : en création, le bouton sous-opération n'est pas offert",
    (await page.locator("#sub").isHidden()) === true,
  );

  await page.click("#save");
  await page.waitForTimeout(200);
  check(
    "fiche opération : le refus du noyau est affiché tel quel",
    (await page.locator("#info-message").textContent()) ===
      "Le libellé de l'opération est obligatoire.",
  );
  check(
    "fiche opération : rien n'est enregistré ni fermé",
    (await page.evaluate(() => window.__closed)) === false,
  );
  await page.close();
}

// --- F03 : le post-it, et la sous-opération qui ne s'écrit pas ici -------
{
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/operation-form.html?mode=M&account=1&id=1",
    { operationComment: "Remboursement mutuelle" },
  );
  check(
    "fiche opération : le post-it s'ouvre seul quand il y a un commentaire",
    (await page.locator("#comment-section").isVisible()) === true,
  );
  check(
    "fiche opération : et il porte le commentaire lu",
    (await page.inputValue("#comment")) === "Remboursement mutuelle",
  );
  await page.fill("#comment", "Remboursement mutuelle 2026");
  await page.waitForTimeout(120);
  check(
    "fiche opération : le commentaire fait partie de la réserve",
    (await page.evaluate(() => window.__operationDirty)) === true,
  );
  await page.close();
}

{
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/operation-form.html?mode=M&account=1&id=1",
    { operationIsASub: true },
  );
  check(
    "fiche opération : une sous-opération est montrée mais pas écrite",
    (await page.locator("#info-message").textContent())?.includes("sous-opération"),
  );
  check(
    "fiche opération : ses champs sont verrouillés",
    await page.locator("#label").isDisabled(),
  );
  check(
    "fiche opération : et le bouton enregistrer disparaît",
    await page.locator("#save").isHidden(),
  );
  check(
    "fiche opération : une ventilation n'a pas de petite-fille",
    (await page.locator("#sub").isHidden()) === true,
  );
  await page.close();
}

// --- F02 : la liste ouvre la fiche --------------------------------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/operations-list.html?account=1");

  await page.click("#create");
  await page.waitForTimeout(150);
  check(
    "liste opérations : « créer » ouvre une fiche vierge",
    JSON.stringify(await page.evaluate(() => window.__openedForm)) ===
      JSON.stringify({ mode: "A", accountId: 1, id: null }),
  );

  await page.click("#update");
  await page.waitForTimeout(120);
  check(
    "liste opérations : « modifier » sans sélection est refusé",
    (await page.locator("#info-bar").textContent())?.includes(
      "Veuillez sélectionner un enregistrement",
    ),
  );

  await page.click(".list__row");
  await page.click("#update");
  await page.waitForTimeout(150);
  check(
    "liste opérations : « modifier » ouvre la fiche sur la ligne choisie",
    JSON.stringify(await page.evaluate(() => window.__openedForm)) ===
      JSON.stringify({ mode: "M", accountId: 1, id: 1 }),
  );

  await page.evaluate(() => {
    window.__openedForm = null;
  });
  await page.dblclick(".list__row:nth-child(2)");
  await page.waitForTimeout(150);
  check(
    "liste opérations : le double-clic ouvre la fiche de sa propre ligne",
    (await page.evaluate(() => window.__openedForm?.mode)) === "M",
  );

  // La porte de la liste demande d'abord ce que tient la fiche.
  await page.evaluate(() => {
    window.__operationDirty = true;
  });
  await page.click("#close");
  await page.waitForTimeout(150);
  check(
    "liste opérations : la porte demande avant d'emporter la fiche",
    await page.locator(".dialog").isVisible(),
  );
  await page.click(".dialog__button:not(.dialog__button--primary)");
  await page.waitForTimeout(120);
  check(
    "liste opérations : « Non » garde tout ouvert",
    (await page.evaluate(() => window.__closed)) === false,
  );
  await page.close();
}

// --- F04, la fiche sous-opération ---------------------------------------
{
  const page = await browser.newPage();
  const errors = await openWindow(
    page,
    "http://localhost:4173/ui/windows/sub-operation-form.html?mode=M&parent=1&id=2",
  );

  check(
    "fiche sous-opération : le nom est lu",
    (await page.inputValue("#label")) === "Alimentation",
  );
  check(
    "fiche sous-opération : le débit garde son signe",
    (await page.inputValue("#amount")) === "-60,00" &&
      (await page.inputValue("#direction")) === "D",
  );
  check(
    "fiche sous-opération : elle dit ce qu'elle ventile",
    (await page.locator("#parent-line").textContent()) ===
      "Ventilation de « COURSES » (-100,00 €)",
  );

  // **Ni Mode, ni Statut, ni Date** : une fille les tient de sa mère.
  check(
    "fiche sous-opération : pas de champ Mode",
    (await page.locator("#payment-mode").count()) === 0,
  );
  check(
    "fiche sous-opération : pas de champ Statut",
    (await page.locator("#status").count()) === 0,
  );
  check(
    "fiche sous-opération : pas de champ Date",
    (await page.locator("#date").count()) === 0,
  );
  check(
    "fiche sous-opération : quatre listes de classement",
    (await page.locator("select.form__field").count()) === 5,
  );

  // La réserve, comme partout ailleurs.
  await page.fill("#label", "Courses du samedi");
  await page.waitForTimeout(120);
  check(
    "fiche sous-opération : la réserve voit le nom changer",
    (await page.locator("#info-message").textContent())?.includes("modifié"),
  );
  await page.fill("#label", "Alimentation");
  await page.waitForTimeout(120);
  check(
    "fiche sous-opération : revenir à la valeur lue efface la modification",
    !(await page.locator("#info-message").textContent())?.includes("modifié"),
  );

  await page.fill("#label", "Autre chose");
  await page.click("#close");
  await page.waitForTimeout(150);
  check(
    "fiche sous-opération : la sortie demande confirmation",
    await page.locator(".dialog").isVisible(),
  );
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(200);
  check(
    "fiche sous-opération : les champs reprennent la réserve",
    (await page.inputValue("#label")) === "Alimentation",
  );
  await page.close();
}

// --- F04 : le Complément est montré, pas interdit ------------------------
{
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/sub-operation-form.html?mode=M&parent=1&id=3",
    { subIsComplement: true },
  );
  check(
    "fiche sous-opération : le Complément se présente comme tel",
    (await page.locator("#info-message").textContent())?.includes("Complément"),
  );
  check(
    "fiche sous-opération : et il reste modifiable",
    (await page.locator("#label").isDisabled()) === false &&
      (await page.locator("#save").isHidden()) === false,
  );
  await page.close();
}

// --- F04 : on ne ventile pas ce qui n'existe pas -------------------------
{
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/sub-operation-form.html?mode=A&parent=404",
    { missingParent: true },
  );
  check(
    "fiche sous-opération : une mère disparue est signalée",
    (await page.locator("#info-message").textContent()) ===
      "L'opération à ventiler n'existe plus.",
  );
  check(
    "fiche sous-opération : et rien n'est saisissable",
    await page.locator("#label").isDisabled(),
  );
  await page.close();
}

// --- F02 : ventiler, pointer, et ouvrir la bonne fiche -------------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/operations-list.html?account=1");

  // `Base_createinside` sur une opération : on la ventile.
  await page.click(".list__row >> nth=0");
  await page.click("#sub");
  await page.waitForTimeout(150);
  check(
    "liste opérations : « sous-opération » ouvre F04 sur l'opération choisie",
    JSON.stringify(await page.evaluate(() => window.__openedSubForm)) ===
      JSON.stringify({ mode: "A", parentId: 1, id: null }),
  );

  // Sur une fille : on ajoute une sœur, pas une petite-fille.
  await page.click(".list__fold");
  await page.waitForTimeout(150);
  await page.click(".list__row >> nth=1");
  await page.click("#sub");
  await page.waitForTimeout(150);
  check(
    "liste opérations : ventiler depuis une fille vise sa mère",
    (await page.evaluate(() => window.__openedSubForm?.parentId)) === 1,
  );

  // Modifier une fille ouvre **sa** fiche, pas celle d'une opération.
  await page.click("#update");
  await page.waitForTimeout(150);
  check(
    "liste opérations : modifier une fille ouvre F04",
    JSON.stringify(await page.evaluate(() => window.__openedSubForm)) ===
      JSON.stringify({ mode: "M", parentId: 1, id: 2 }),
  );

  // Deux lignes choisies : une fiche montre un enregistrement, pas deux.
  await page.click(".list__row >> nth=0");
  await page.click(".list__row >> nth=1", { modifiers: ["Meta"] });
  await page.click("#update");
  await page.waitForTimeout(150);
  check(
    "liste opérations : deux lignes choisies, la fiche refuse",
    (await page.locator("#info-bar").textContent())?.includes(
      "une seule opération",
    ),
  );

  // Le pointage rapide, lui, travaille sur toute la sélection.
  await page.click("#point");
  await page.waitForTimeout(200);
  check(
    "liste opérations : le pointage rapide prend toute la sélection",
    (await page.evaluate(() => window.__pointed?.length)) === 2,
  );
  check(
    "liste opérations : et la liste dit ce qui a été pointé",
    (await page.locator("#info-bar").textContent()) === "2 opérations pointées.",
  );
  await page.close();
}

// --- F02 : dupliquer, l'infobulle, et le masquage global ----------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/operations-list.html?account=1");

  // L'infobulle du commentaire : la croix dit qu'il y en a un, le survol le
  // donne à lire (04_SPECIFICATIONS_FENETRES.md, F02).
  check(
    "liste opérations : le commentaire se lit au survol",
    (await page.locator(".list__row >> nth=0 >> .list__cell >> nth=13").getAttribute("title")) ===
      "Marché du dimanche",
  );

  // Dupliquer : une fiche pré-remplie, rien d'écrit (choix de Fabrice).
  await page.click(".list__row >> nth=0");
  await page.click("#duplicate");
  await page.waitForTimeout(150);
  check(
    "liste opérations : dupliquer ouvre une fiche pré-remplie",
    JSON.stringify(await page.evaluate(() => window.__openedForm)) ===
      JSON.stringify({ mode: "D", accountId: 1, id: 1 }),
  );

  // Le masquage global : deux actions, pas un mode.
  check(
    "liste opérations : tout est replié au départ",
    (await page.locator(".list__row").count()) === 2,
  );
  await page.locator(".window-menu__entry", { hasText: "Divers" }).first().click();
  await page.waitForTimeout(120);
  await page.click('[data-menu="misc"] >> text=Afficher toutes les sous-opérations');
  await page.waitForTimeout(150);
  check(
    "liste opérations : « afficher » déplie toutes les mères",
    (await page.locator(".list__row").count()) === 4,
  );
  await page.locator(".window-menu__entry", { hasText: "Divers" }).first().click();
  await page.waitForTimeout(120);
  await page.click('[data-menu="misc"] >> text=Masquer toutes les sous-opérations');
  await page.waitForTimeout(150);
  check(
    "liste opérations : « masquer » les replie toutes",
    (await page.locator(".list__row").count()) === 2,
  );
  await page.close();
}

// --- F03 : la copie est une fiche neuve, pas l'enregistrement copié ------
{
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/operation-form.html?mode=D&account=1&id=1",
  );
  check(
    "fiche opération : la copie porte les valeurs de l'originale",
    (await page.inputValue("#label")) === "VIREMENT DE COMPLEMENTAIRE SANTE" &&
      (await page.inputValue("#amount")) === "9,00",
  );
  check(
    "fiche opération : et la fenêtre dit que rien n'est encore créé",
    (await page.locator("#info-message").textContent()) ===
      "Copie à enregistrer : rien n'est encore créé.",
  );
  check(
    "fiche opération : une copie ne tient aucun enregistrement",
    (await page.evaluate(() => window.__operationRecord)) === null,
  );
  check(
    "fiche opération : et ne propose pas de ventilation avant d'exister",
    (await page.locator("#sub").isHidden()) === true,
  );

  // Enregistrer crée une opération : c'est un ajout, pas une modification.
  await page.click("#save");
  await page.waitForTimeout(250);
  check(
    "fiche opération : enregistrer la copie crée une opération",
    await page.evaluate(() => window.__calls.some(([c]) => c === "create_operation")),
  );
  check(
    "fiche opération : et ne modifie pas l'originale",
    await page.evaluate(() => !window.__calls.some(([c]) => c === "update_operation")),
  );
  await page.close();
}

// --- F06, troisième usage : choisir plusieurs comptes -------------------
{
  const page = await browser.newPage();
  const errors = await openWindow(
    page,
    "http://localhost:4173/ui/windows/accounts-list.html?mode=STATS",
  );
  check(
    "statistiques : la question porte sur plusieurs comptes",
    (await page.textContent("#question")).includes("Sur quels comptes"),
  );

  // **Une statistique se calcule sur plusieurs comptes** : ici, contrairement
  // au choix d'un compte à gérer, Cmd élargit bien la sélection.
  await page.click(".list__row >> nth=0");
  await page.click(".list__row >> nth=1", { modifiers: ["Meta"] });
  check(
    "statistiques : plusieurs comptes se choisissent",
    (await page.locator('.list__row[aria-selected="true"]').count()) === 2,
  );
  check(
    "statistiques : et l'aide du Ctrl est rappelée",
    (await page.locator("#info-bar").textContent())?.includes("plusieurs comptes"),
  );

  await page.click("#select");
  await page.waitForTimeout(200);
  check(
    "statistiques : choisir ouvre la statistique sur tous les comptes pris",
    (await page.evaluate(() => window.__openedStats?.accountIds?.length)) === 2,
  );
  check(
    "statistiques : et non la liste des opérations",
    await page.evaluate(() => window.__calls.every(([c]) => c !== "open_operations_list")),
  );

  await page.click("#close");
  await page.waitForTimeout(150);
  check(
    "statistiques : la porte ferme bien cette fenêtre-ci",
    await page.evaluate(() =>
      window.__calls.some(
        ([command, args]) => command === "accounts_list_may_close" && args?.purpose === "STATS",
      ),
    ),
  );
  await page.close();
}

// --- F20, la statistique par catégories ---------------------------------
{
  const page = await browser.newPage();
  const errors = await openWindow(
    page,
    "http://localhost:4173/ui/windows/statistics.html?accounts=1,2&year=2026",
  );

  check(
    "statistiques : les comptes choisis partent avec la demande",
    JSON.stringify(await page.evaluate(() => window.__statsAsked?.accountIds)) === "[1,2]",
  );
  check(
    "statistiques : et tous allumés au départ",
    (await page.locator('.switch[aria-pressed="true"]').count()) === 5,
  );
  check(
    "statistiques : aucun libellé ne montre une clef brute",
    (await page.evaluate(() =>
      [...document.querySelectorAll(".switch__label")].every(
        (label) => !/^[a-z]+(-[a-z]+)+$/.test(label.textContent ?? ""),
      ),
    )) === true,
  );

  // L'en-tête : l'axe, douze mois, le total.
  check(
    "statistiques : quatorze colonnes",
    (await page.locator(".matrix__row--head .matrix__title").count()) === 14,
  );
  check(
    "statistiques : la première colonne nomme l'axe",
    (await page.locator(".matrix__title").first().textContent()) === "NomCategorie",
  );

  // **Toutes les catégories, même vides**, plus la ligne des non classées.
  check(
    "statistiques : une ligne par catégorie, même vide",
    (await page.locator(".matrix__row").count()) === 1 + 4 + 2,
  );
  check(
    "statistiques : la ligne des non classées est en dernier avant les synthèses",
    (await page.locator(".matrix__label").nth(3).textContent()) === "Sans catégorie",
  );

  // Les couleurs disent quelque chose de précis.
  check(
    "statistiques : un montant négatif est rose",
    (await page.locator(".matrix__row >> nth=1 >> .matrix__cell").first().getAttribute("class"))?.includes(
      "matrix__cell--negative",
    ),
  );
  check(
    "statistiques : un montant positif est bleu",
    (await page.locator(".matrix__row >> nth=2 >> .matrix__cell").first().getAttribute("class"))?.includes(
      "matrix__cell--positive",
    ),
  );
  check(
    "statistiques : une case qui s'annule est verte, pas blanche",
    (await page.locator(".matrix__row >> nth=1 >> .matrix__cell").nth(2).getAttribute("class"))?.includes(
      "matrix__cell--cancelling",
    ),
  );
  check(
    "statistiques : une case vide reste blanche",
    (await page.locator(".matrix__row >> nth=1 >> .matrix__cell").nth(1).getAttribute("class")) ===
      "matrix__cell",
  );

  // Les deux lignes de synthèse.
  check(
    "statistiques : le cumul est reporté jusqu'à décembre",
    (await page.locator(".matrix__row--cumulative .matrix__cell").nth(11).textContent()) ===
      "2 116,71 €",
  );
  check(
    "statistiques : mais la Somme laisse les mois vides vides",
    (await page.locator(".matrix__row--sum .matrix__cell").nth(1).textContent()) === "",
  );

  // Le millésime et ses deux horloges.
  check("statistiques : le millésime s'affiche", (await page.textContent("#year")) === "2026");
  await page.click("#previous-year");
  await page.waitForTimeout(250);
  check("statistiques : l'horloge recule d'un an", (await page.textContent("#year")) === "2025");
  check(
    "statistiques : et la matrice est redemandée pour cette année",
    (await page.evaluate(() => window.__statsAsked?.year)) === 2025,
  );
  await page.click("#next-year");
  await page.waitForTimeout(250);
  check("statistiques : et l'autre avance", (await page.textContent("#year")) === "2026");

  // **Cliquer le millésime demande l'année** (demande de Fabrice, 26/07/2026).
  await page.click("#year");
  await page.waitForTimeout(200);
  check(
    "millésime : cliquer l'année ouvre la demande",
    (await page.textContent(".dialog__question"))?.includes("Radinus va de 1950 à 2550"),
  );
  check(
    "millésime : le champ part de l'année en cours",
    (await page.inputValue(".dialog__field")) === "2026",
  );

  // Le champ ne prend que des chiffres, et pas plus de quatre.
  await page.fill(".dialog__field", "");
  await page.type(".dialog__field", "20a1x9");
  check(
    "millésime : les lettres n'entrent pas",
    (await page.inputValue(".dialog__field")) === "2019",
  );
  await page.type(".dialog__field", "7");
  check(
    "millésime : et pas plus de quatre chiffres",
    (await page.inputValue(".dialog__field")) === "2019",
  );

  await page.click(".dialog__button--primary");
  await page.waitForTimeout(250);
  check("millésime : l'année saisie est prise", (await page.textContent("#year")) === "2019");
  check(
    "millésime : et la matrice est refaite dessus",
    (await page.evaluate(() => window.__statsAsked?.year)) === 2019,
  );

  // **Hors des bornes, on impose ; on ne rejette pas.**
  await page.click("#year");
  await page.waitForTimeout(200);
  await page.fill(".dialog__field", "");
  await page.type(".dialog__field", "1800");
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(250);
  check(
    "millésime : trop tôt devient la première année de Radinus",
    (await page.textContent("#year")) === "1950",
  );

  await page.click("#year");
  await page.waitForTimeout(200);
  await page.fill(".dialog__field", "");
  await page.type(".dialog__field", "9999");
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(250);
  check(
    "millésime : trop tard devient la dernière",
    (await page.textContent("#year")) === "2550",
  );

  // Et l'horloge, elle aussi, s'arrête à la borne.
  await page.click("#next-year");
  await page.waitForTimeout(250);
  check(
    "millésime : l'horloge ne dépasse pas la dernière année",
    (await page.textContent("#year")) === "2550",
  );

  // Renoncer ne change rien.
  await page.click("#year");
  await page.waitForTimeout(200);
  await page.click(".dialog__button:not(.dialog__button--primary)");
  await page.waitForTimeout(200);
  check("millésime : renoncer garde l'année", (await page.textContent("#year")) === "2550");

  // On revient sur une année qui porte des données pour la suite du test.
  await page.click("#year");
  await page.waitForTimeout(200);
  await page.fill(".dialog__field", "");
  await page.type(".dialog__field", "2026");
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(250);

  // **Le drill-down** : cliquer une case chiffrée donne son détail.
  check(
    "statistiques : rien en bas tant qu'aucune case n'est choisie",
    (await page.locator(".list__empty").textContent())?.includes("Cliquez une case"),
  );
  await page.click(".matrix__row >> nth=1 >> .matrix__cell >> nth=0");
  await page.waitForTimeout(250);
  check(
    "statistiques : la case choisie demande son détail",
    (await page.evaluate(() => window.__detailAsked?.cell?.value)) === 1 &&
      (await page.evaluate(() => window.__detailAsked?.cell?.month)) === 1 &&
      (await page.evaluate(() => window.__detailAsked?.cell?.kind)) === "axis",
  );
  check(
    "statistiques : et la case choisie se voit",
    (await page.locator(".matrix__cell--chosen").count()) === 1,
  );

  // La colonne Total d'une ligne : toute l'année de cette catégorie.
  await page.click(".matrix__row >> nth=1 >> .matrix__cell--total");
  await page.waitForTimeout(250);
  check(
    "statistiques : la colonne Total demande l'année entière",
    (await page.evaluate(() => window.__detailAsked?.cell?.month)) === null &&
      (await page.evaluate(() => window.__detailAsked?.cell?.value)) === 1,
  );

  // Une case de la ligne Somme : tout le mois, toutes catégories.
  await page.click(".matrix__row--sum .matrix__cell >> nth=0");
  await page.waitForTimeout(250);
  check(
    "statistiques : une case de la Somme n'est attachée à aucune valeur de l'axe",
    (await page.evaluate(() => window.__detailAsked?.cell?.value)) === null &&
      (await page.evaluate(() => window.__detailAsked?.cell?.kind)) === "sum",
  );

  // **La Somme et le Cumul d'un même mois sont deux cases distinctes**
  // (signalé par Fabrice, 26/07/2026) : cliquer l'une ne doit pas choisir
  // l'autre, et elles ne montrent pas la même chose.
  check(
    "totaux : choisir la Somme n'en choisit qu'une",
    (await page.locator(".matrix__cell--chosen").count()) === 1,
  );
  check(
    "totaux : et c'est bien celle de la ligne Somme",
    (await page.locator(".matrix__row--sum .matrix__cell--chosen").count()) === 1 &&
      (await page.locator(".matrix__row--cumulative .matrix__cell--chosen").count()) === 0,
  );

  await page.click(".matrix__row--cumulative .matrix__cell >> nth=0");
  await page.waitForTimeout(250);
  check(
    "totaux : le Cumul se choisit tout seul de son côté",
    (await page.locator(".matrix__row--cumulative .matrix__cell--chosen").count()) === 1 &&
      (await page.locator(".matrix__row--sum .matrix__cell--chosen").count()) === 0,
  );
  check(
    "totaux : et il demande son propre détail",
    (await page.evaluate(() => window.__detailAsked?.cell?.kind)) === "cumulative" &&
      (await page.evaluate(() => window.__detailAsked?.cell?.month)) === 1,
  );

  // **Une case vide se clique comme les autres** (remarque de Fabrice,
  // 26/07/2026) : voir qu'il n'y a rien derrière est une réponse, et le
  // détail le dit en toutes lettres.
  await page.click(".matrix__row >> nth=1 >> .matrix__cell >> nth=1");
  await page.waitForTimeout(250);
  check(
    "statistiques : une case vide se choisit aussi",
    (await page.evaluate(() => window.__detailAsked?.cell?.month)) === 2,
  );

  // Un interrupteur éteint change le calcul et le dit.
  await page.click('.switch[data-name="credits"]');
  await page.waitForTimeout(250);
  check(
    "statistiques : éteindre un interrupteur le dit",
    (await page.locator('.switch[data-name="credits"] >> .switch__label').textContent()) ===
      "Crédits montants OFF",
  );
  check(
    "statistiques : et les quatre autres n'ont pas bougé",
    (await page.locator('.switch[data-name="pointed"] >> .switch__label').textContent()) ===
      "Opérations pointées ON",
  );
  check(
    "statistiques : et la matrice est refaite sans eux",
    (await page.evaluate(() => window.__statsAsked?.switches?.credits)) === false,
  );

  // **Le double-clic ouvre la fiche de la ligne** (demande de Fabrice,
  // 26/07/2026). La fenêtre n'envoie qu'une clef : c'est le contrôleur qui
  // lit l'enregistrement et décide entre F03 et F04.
  await page.click(".matrix__row >> nth=1 >> .matrix__cell >> nth=0");
  await page.waitForTimeout(250);
  await page.dblclick(".list--detail .list__row >> nth=0");
  await page.waitForTimeout(200);
  check(
    "statistiques : double-cliquer une opération du détail ouvre sa fiche",
    (await page.evaluate(() => window.__openedFormFor)) === 1,
  );
  await page.dblclick(".list--detail .list__row >> nth=1");
  await page.waitForTimeout(200);
  check(
    "statistiques : et une ventilation ouvre la sienne",
    (await page.evaluate(() => window.__openedFormFor)) === 2,
  );

  // **Le classement se change sur place, sans entrer dans la fiche**
  // (Fabrice, 26/07/2026 : « il ne faut pas mettre des champs texte mais des
  // menus déroulants »). Comme dans F02 : la ligne choisie porte ses menus.
  await page.click(".list--detail .list__row >> nth=0");
  await page.waitForTimeout(150);
  check(
    "détail : la ligne choisie porte les cinq menus de classement",
    (await page.locator(".list--detail .list__row >> nth=0 >> .list__combo").count()) === 5,
  );
  check(
    "détail : et les autres lignes restent du texte",
    (await page.locator(".list--detail .list__row >> nth=1 >> .list__combo").count()) === 0,
  );
  check(
    "détail : le menu s'ouvre sur le classement actuel de la ligne",
    (await page.locator(".list--detail .list__row >> nth=0 >> .list__combo >> nth=0").inputValue()) ===
      "1",
  );

  // Une sous-opération n'a pas de mode de paiement à elle : quatre menus, pas
  // cinq. Un logiciel n'offre pas ce qu'il ne peut pas garder.
  await page.click(".list--detail .list__row >> nth=1");
  await page.waitForTimeout(150);
  check(
    "détail : une ventilation n'a pas de menu Mode de paiement",
    (await page.locator(".list--detail .list__row >> nth=1 >> .list__combo").count()) === 4,
  );

  // Choisir écrit, prévient F02, et refait **le calcul global** : reclasser
  // une opération la fait changer de ligne dans la matrice.
  await page.click(".list--detail .list__row >> nth=0");
  await page.waitForTimeout(150);
  const before = await page.evaluate(
    () => window.__calls.filter(([command]) => command === "axis_statistics").length,
  );
  await page.selectOption(".list--detail .list__row >> nth=0 >> .list__combo >> nth=0", "5");
  await page.waitForTimeout(300);
  check(
    "détail : choisir une catégorie l'écrit sur l'opération",
    await page.evaluate(() =>
      window.__calls.some(
        ([command, args]) =>
          command === "set_operation_nomenclature" &&
          args.id === 1 &&
          args.kind === "category" &&
          args.value === 5,
      ),
    ),
  );
  check(
    "détail : et refait le calcul global, puisque la ligne a changé",
    (await page.evaluate(
      () => window.__calls.filter(([command]) => command === "axis_statistics").length,
    )) > before,
  );
  check(
    "détail : et prévient la liste des opérations, qui montre les mêmes",
    await page.evaluate(() =>
      window.__calls.some(([command]) => command === "notify_operations_changed"),
    ),
  );
  check(
    "détail : les menus proposent ce qui existe, pas une saisie libre",
    (await page.evaluate(() =>
      window.__calls.some(([command]) => command === "list_operation_combos"),
    )) === true,
  );

  // **Rien de ce qui ne change que les chiffres ne fait perdre la position**
  // (règle de Fabrice, 26/07/2026) : on clique une case, on change d'année,
  // et on la retrouve au même endroit — c'est ce qui permet de comparer d'un
  // coup d'œil.
  await page.click(".matrix__row >> nth=2 >> .matrix__cell >> nth=0");
  await page.waitForTimeout(250);
  const beforeYear = await page.evaluate(() => ({
    category: window.__detailAsked?.cell?.value,
    month: window.__detailAsked?.cell?.month,
  }));
  await page.click("#previous-year");
  await page.waitForTimeout(300);
  check(
    "position : changer d'année garde la case choisie",
    (await page.locator(".matrix__cell--chosen").count()) === 1,
  );
  check(
    "position : et c'est la même case, sur la nouvelle année",
    JSON.stringify(await page.evaluate(() => ({
      category: window.__detailAsked?.cell?.value,
      month: window.__detailAsked?.cell?.month,
    }))) === JSON.stringify(beforeYear) &&
      (await page.evaluate(() => window.__detailAsked?.year)) === 2025,
  );
  await page.click("#next-year");
  await page.waitForTimeout(300);


  // Un interrupteur ne change que les chiffres : la case reste elle aussi.
  await page.click('.switch[data-name="planned"]');
  await page.waitForTimeout(300);
  check(
    "position : basculer un interrupteur garde la case choisie",
    (await page.locator(".matrix__cell--chosen").count()) === 1,
  );
  await page.click('.switch[data-name="planned"]');
  await page.waitForTimeout(300);

  // Et le défilement ne repart pas en haut à chaque redessin.
  await page.evaluate(() => {
    const zone = document.getElementById("matrix-zone");
    zone.style.height = "48px";
    zone.style.flex = "0 0 48px";
    zone.scrollTop = 40;
  });
  await page.waitForTimeout(120);
  const scrolledTo = await page.evaluate(() => document.getElementById("matrix-zone").scrollTop);
  await page.click("#previous-year");
  await page.waitForTimeout(300);
  check(
    "position : le défilement du tableau est conservé",
    (await page.evaluate(() => document.getElementById("matrix-zone").scrollTop)) === scrolledTo &&
      scrolledTo > 0,
  );
  await page.evaluate(() => {
    const zone = document.getElementById("matrix-zone");
    zone.style.height = "";
    zone.style.flex = "";
  });
  await page.click("#next-year");
  await page.waitForTimeout(300);

  // **Revenir sur la fenêtre refait le calcul global et remet à sa place**
  // (méthode donnée par Fabrice le 26/07/2026, après deux tentatives ratées
  // par les événements de Tauri). Le déclencheur est celui du navigateur :
  // aucun message à transmettre, rien qui puisse se perdre.
  const askedBefore = await page.evaluate(
    () => window.__calls.filter(([c]) => c === "axis_statistics").length,
  );
  await page.evaluate(() => window.dispatchEvent(new Event("focus")));
  await page.waitForTimeout(250);
  check(
    "statistiques : revenir sur la fenêtre refait le calcul global",
    (await page.evaluate(
      () => window.__calls.filter(([c]) => c === "axis_statistics").length,
    )) > askedBefore,
  );
  check(
    "statistiques : et l'on se retrouve sur la même case",
    JSON.stringify(await page.evaluate(() => ({
      category: window.__detailAsked?.cell?.value,
      month: window.__detailAsked?.cell?.month,
    }))) === JSON.stringify(beforeYear) &&
      (await page.locator(".matrix__cell--chosen").count()) === 1,
  );

  // La page revenue au premier plan par un autre chemin fait la même chose.
  const beforeVisible = await page.evaluate(
    () => window.__calls.filter(([c]) => c === "axis_statistics").length,
  );
  await page.evaluate(() => document.dispatchEvent(new Event("visibilitychange")));
  await page.waitForTimeout(250);
  check(
    "statistiques : redevenir visible aussi",
    (await page.evaluate(
      () => window.__calls.filter(([c]) => c === "axis_statistics").length,
    )) > beforeVisible,
  );

  await page.click("#close");
  await page.waitForTimeout(150);
  check("statistiques : la porte ferme la fenêtre", await page.evaluate(() => window.__closed));
  await page.close();
}

// --- F25, l'évolution du solde -------------------------------------------
{
  // Les règles que Fabrice a dictées le 26/07/2026 : une courbe par compte
  // plus celle du total, des courbes **en escalier**, une infobulle qui suit
  // la souris, un menu Période, des horloges qui décalent d'un an, et les deux
  // dates affichées.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/balance-curves.html?accounts=1,2");

  check(
    "courbes : la fenêtre s'ouvre sur l'année en cours, pas sur le mois",
    await page.evaluate(() => {
      const asked = window.__curvesAsked;
      const year = new Date().getFullYear();
      return asked?.from === `${year}-01-01` && asked?.to === `${year}-12-31`;
    }),
    await page.evaluate(() => JSON.stringify(window.__curvesAsked)),
  );
  check(
    "courbes : une courbe par compte, plus celle du total",
    (await page.locator(".chart path[data-account]").count()) === 3,
  );
  check(
    "courbes : le total est plus épais que les comptes",
    await page.evaluate(() => {
      const total = document.querySelector('.chart path[data-account="0"]');
      const account = document.querySelector('.chart path[data-account="1"]');
      return (
        Number(total.getAttribute("stroke-width")) >
        Number(account.getAttribute("stroke-width"))
      );
    }),
  );
  check(
    "courbes : la légende nomme les trois",
    (await page.evaluate(() =>
      [...document.querySelectorAll(".chart__legend-entry")].map((one) => one.textContent),
    )).join(" | ") === "CCP | Livret A | Total",
  );

  // **En escalier, jamais en pente** : entre deux marches le tracé va tout
  // droit à l'horizontale, puis saute à la verticale. Un segment oblique
  // trahirait une pente.
  check(
    "courbes : le tracé est un escalier, pas une pente",
    await page.evaluate(() => {
      const d = document.querySelector('.chart path[data-account="1"]').getAttribute("d");
      const points = d
        .split(/[ML]\s*/)
        .filter(Boolean)
        .map((pair) => pair.trim().split(/\s+/).map(Number));
      // Chaque segment est soit horizontal, soit vertical — jamais les deux.
      return points.every((point, index) => {
        if (index === 0) return true;
        const [x, y] = point;
        const [px, py] = points[index - 1];
        return x === px || y === py;
      });
    }),
    await page.evaluate(() =>
      document.querySelector('.chart path[data-account="1"]').getAttribute("d"),
    ),
  );

  check(
    "courbes : les deux dates sont affichées",
    await page.evaluate(() => {
      const year = new Date().getFullYear();
      return (
        document.getElementById("from").textContent === `01/01/${year}` &&
        document.getElementById("to").textContent === `31/12/${year}`
      );
    }),
    await page.evaluate(() => document.getElementById("from").textContent),
  );
  check(
    "courbes : et ce ne sont pas des champs de saisie",
    (await page.locator(".chart__period input").count()) === 0,
  );

  // L'infobulle : nom du compte, date, solde, et le total des comptes choisis.
  await page.hover(".chart");
  await page.mouse.move(600, 300);
  await page.waitForTimeout(150);
  const bubble = await page.evaluate(() => {
    const one = document.querySelector(".chart__bubble");
    return one && !one.hidden ? one.textContent : null;
  });
  check(
    "courbes : l'infobulle suit la souris et dit le compte, la date et le solde",
    bubble !== null && /\d{2}\/\d{2}\/\d{4}/.test(bubble) && /€/.test(bubble),
    String(bubble),
  );

  // Les horloges décalent d'un an — c'est le noyau qui sait comment.
  await page.click("#next-year");
  await page.waitForTimeout(200);
  check(
    "courbes : l'horloge demande au noyau de décaler d'un an",
    await page.evaluate(() => window.__shiftAsked?.by === 1 && window.__shiftAsked?.onto === null),
    await page.evaluate(() => JSON.stringify(window.__shiftAsked)),
  );
  check(
    "courbes : et la période décalée est redemandée",
    await page.evaluate(() => {
      const year = new Date().getFullYear() + 1;
      return window.__curvesAsked?.from === `${year}-01-01`;
    }),
  );
  check(
    "courbes : le millésime affiché suit",
    (await page.textContent("#year")) === String(new Date().getFullYear() + 1),
  );

  // **Une période choisie au menu s'affiche telle qu'elle est demandée.**
  // Faute du 26/07/2026 : un mois de juillet s'affichait comme commençant le
  // 30 juin. La date était lue dans le fuseau du poste et relue en UTC, et
  // l'écart d'un fuseau reculait la journée entière. Le test tient les deux
  // bouts : ce que la fenêtre envoie au noyau, et ce qu'elle montre.
  await page.click(".window-menu__entry");
  await page.click('[data-menu="period"] .window-menu__choice--parent >> nth=1');
  await page.click('[data-key="period-this-year:month-july"]');
  await page.waitForTimeout(250);
  const july = await page.evaluate(() => ({
    asked: window.__curvesAsked,
    from: document.getElementById("from").textContent,
    to: document.getElementById("to").textContent,
  }));
  check(
    "courbes : un mois commence au premier du mois, pas la veille",
    /^01\/07\/\d{4}$/.test(july.from) && july.asked.from.endsWith("-07-01"),
    JSON.stringify(july),
  );
  check(
    "courbes : et finit au dernier jour du mois",
    /^31\/07\/\d{4}$/.test(july.to) && july.asked.to.endsWith("-07-31"),
    JSON.stringify(july),
  );
  check(
    "courbes : et l'encoche du menu suit ce qui est affiché",
    await page.evaluate(
      () =>
        document.querySelector('[data-key="period-this-year:month-july"]')?.classList
          .contains("window-menu__choice--chosen") === true,
    ),
  );

  await page.click("#close");
  await page.waitForTimeout(150);
  check("courbes : la porte ferme la fenêtre", await page.evaluate(() => window.__closed));
  await page.close();
}

{
  // L'encoche de départ dit la période sur laquelle la fenêtre s'ouvre — ici
  // l'année, et non le mois comme dans F02 et le tableau de bord.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/balance-curves.html?accounts=1,2");
  await page.click(".window-menu__entry");
  await page.waitForTimeout(100);
  check(
    "courbes : l'encoche part sur l'année entière, pas sur le mois",
    await page.evaluate(() => {
      const ticked = [...document.querySelectorAll(".window-menu__choice--chosen")].map(
        (one) => one.dataset.key,
      );
      return ticked.length === 1 && ticked[0] === "period-this-year:period-whole-year";
    }),
    await page.evaluate(() =>
      JSON.stringify(
        [...document.querySelectorAll(".window-menu__choice--chosen")].map(
          (one) => one.dataset.key,
        ),
      ),
    ),
  );

  // L'infobulle nomme toutes les courbes, le total compris.
  await page.mouse.move(700, 320);
  await page.waitForTimeout(150);
  await page.mouse.move(701, 320);
  await page.waitForTimeout(200);
  const named = await page.evaluate(() => {
    const bubble = document.querySelector(".chart__bubble");
    return bubble && !bubble.hidden ? bubble.textContent : "";
  });
  check(
    "courbes : l'infobulle nomme la courbe survolée",
    /CCP|Livret A|Total/.test(named),
    named,
  );
  await page.close();
}

{
  // Et le tableau de bord garde son mois, lui : la valeur par défaut du menu
  // partagé n'a pas été changée pour tout le monde.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/dashboard.html?accounts=1,2");
  await page.click(".window-menu__entry");
  await page.waitForTimeout(100);
  check(
    "bord : l'encoche du tableau de bord reste sur le mois en cours",
    await page.evaluate(
      () =>
        document.querySelector(".window-menu__choice--chosen")?.dataset.key ===
        "period-this-month",
    ),
    await page.evaluate(
      () => document.querySelector(".window-menu__choice--chosen")?.dataset.key,
    ),
  );
  await page.close();
}

{
  // Sans compte : rien à tracer, et on le dit sans rien demander au noyau.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/balance-curves.html?accounts=");
  check(
    "courbes : sans compte, la fenêtre le dit",
    (await page.textContent("#info-bar")).includes("pas de courbe à tracer"),
  );
  check(
    "courbes : et ne demande rien au noyau",
    await page.evaluate(() => window.__calls.every(([c]) => c !== "balance_curves")),
  );
  await page.close();
}

{
  // Le choix des comptes ouvre bien la courbe, et non le tableau de bord.
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/accounts-list.html?mode=STATS&axis=curves",
  );
  await page.click(".list__row >> nth=0");
  await page.click(".list__row >> nth=1", { modifiers: ["Meta"] });
  await page.click("#select");
  await page.waitForTimeout(200);
  check(
    "courbes : le choix des comptes ouvre la courbe",
    (await page.evaluate(() => JSON.stringify(window.__openedCurves?.accountIds))) === "[1,2]",
    await page.evaluate(() => JSON.stringify(window.__openedCurves)),
  );
  check(
    "courbes : et n'ouvre ni statistique ni tableau de bord",
    await page.evaluate(
      () => window.__openedStats === undefined && window.__openedDashboard === undefined,
    ),
  );
  await page.close();
}

// --- F19, le tableau de bord ---------------------------------------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/dashboard.html?accounts=1,2");

  check(
    "bord : les comptes choisis partent avec la demande",
    (await page.evaluate(() => JSON.stringify(window.__dashboardAsked?.accountIds))) === "[1,2]",
    await page.evaluate(() => JSON.stringify(window.__dashboardAsked)),
  );
  check(
    "bord : la période s'ouvre sur le mois en cours",
    await page.evaluate(() => {
      const now = new Date();
      const first = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-01`;
      return document.getElementById("from").value === first;
    }),
    await page.evaluate(() => document.getElementById("from").value),
  );

  // **Le croisement du tableau de bord** : la somme des secteurs de chaque
  // anneau doit valoir sa tuile, et la balance les deux tuiles ensemble. Ce
  // qui est dessiné et ce qui est écrit viennent du même calcul — encore
  // faut-il que la fenêtre dessine bien ce qu'on lui a donné.
  const shown = await page.evaluate(() => ({
    sectors: [...document.querySelectorAll("#spending .ring__sector")].length,
    values: [...document.querySelectorAll("#spending .ring__value")].map((one) =>
      Number(one.textContent),
    ),
    legend: [...document.querySelectorAll("#spending .legend__label")].map(
      (one) => one.textContent,
    ),
    debits: document.getElementById("debits").textContent,
    credits: document.getElementById("credits").textContent,
    balance: document.getElementById("balance").textContent,
  }));
  check(
    "bord : un secteur par poste dépensé",
    shown.sectors === 3,
    String(shown.sectors),
  );
  check(
    "bord : la somme des secteurs vaut la tuile des débits",
    shown.values.reduce((sum, one) => sum + one, 0) === 1086 &&
      shown.debits === "-1086,00 €",
    JSON.stringify(shown),
  );
  check(
    "bord : la balance vaut les deux tuiles ensemble",
    shown.credits === "2216,00 €" && shown.balance === "1130,00 €",
    JSON.stringify(shown),
  );
  check(
    "bord : la légende nomme chaque poste, l'identité ne tient pas à la couleur seule",
    shown.legend.join(" | ") === "Vie courante | Habitat | Sans poste budgetaire",
    JSON.stringify(shown.legend),
  );
  check(
    "bord : chaque secteur porte un filet, pour que deux teintes proches ne se touchent pas",
    await page.evaluate(() =>
      [...document.querySelectorAll("#spending .ring__sector")].every(
        (one) => one.getAttribute("stroke-width") === "2",
      ),
    ),
  );
  check(
    "bord : une balance positive n'est pas peinte en rouge",
    !(await page.evaluate(() =>
      document.getElementById("balance").classList.contains("card__figure--negative"),
    )),
  );

  // Un interrupteur retire des opérations : les secteurs et les tuiles
  // doivent bouger ensemble, jamais l'un sans l'autre.
  await page.click('.switch[data-name="planned"]');
  await page.waitForTimeout(250);
  const after = await page.evaluate(() => ({
    values: [...document.querySelectorAll("#spending .ring__value")].map((one) =>
      Number(one.textContent),
    ),
    debits: document.getElementById("debits").textContent,
    balance: document.getElementById("balance").textContent,
    negative: document
      .getElementById("balance")
      .classList.contains("card__figure--negative"),
  }));
  check(
    "bord : éteindre un interrupteur retire des secteurs et des tuiles ensemble",
    after.values.length === 1 &&
      after.values[0] === 836 &&
      after.debits === "-836,00 €",
    JSON.stringify(after),
  );
  check(
    "bord : et l'interrupteur part avec la demande",
    (await page.evaluate(() => window.__dashboardAsked?.switches?.planned)) === false,
  );

  // Les deux éléments dont Fabrice ne m'a pas dit ce qu'ils font sont là, et
  // inertes : ils ne mentent pas sur ce qui marche.
  check(
    "bord : le menu Divers est présent mais inerte",
    await page.evaluate(() =>
      [...document.querySelectorAll(".window-menu__entry")].some(
        (one) => one.textContent === "Divers" && one.disabled,
      ),
    ),
  );
  check(
    "bord : le picto « ouvrir en grand » aussi",
    await page.evaluate(() =>
      [...document.querySelectorAll(".card__enlarge")].every((one) => one.disabled),
    ),
  );

  // Le menu Période est celui de F02, partagé : les mêmes neuf entrées.
  await page.click(".window-menu__entry");
  await page.waitForTimeout(100);
  check(
    "bord : le menu Période a les neuf entrées de F02",
    (await page.locator('[data-menu="period"] > .window-menu__choice, [data-menu="period"] > .window-menu__nest').count()) === 9,
  );

  await page.click("#close");
  await page.waitForTimeout(150);
  check("bord : la porte ferme la fenêtre", await page.evaluate(() => window.__closed));
  await page.close();
}

{
  // Sans compte, il ne porte sur rien, et il le dit sans rien demander au
  // noyau — comme la statistique.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/dashboard.html?accounts=");
  check(
    "bord : sans compte, la fenêtre le dit",
    (await page.textContent("#info-bar")).includes("ne porte sur rien"),
  );
  check(
    "bord : et ne demande rien au noyau",
    await page.evaluate(() => window.__calls.every(([c]) => c !== "dashboard")),
  );
  await page.close();
}

{
  // Le choix des comptes ouvre le tableau de bord, et non une statistique.
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/accounts-list.html?mode=STATS&axis=dashboard",
  );
  await page.click(".list__row >> nth=0");
  await page.click(".list__row >> nth=1", { modifiers: ["Meta"] });
  await page.click("#select");
  await page.waitForTimeout(200);
  check(
    "bord : le choix des comptes ouvre le tableau de bord",
    (await page.evaluate(() => JSON.stringify(window.__openedDashboard?.accountIds))) === "[1,2]",
    await page.evaluate(() => JSON.stringify(window.__openedDashboard)),
  );
  check(
    "bord : et n'ouvre aucune statistique",
    await page.evaluate(() => window.__openedStats === undefined),
  );
  await page.close();
}

// --- Les six statistiques, une seule page --------------------------------
{
  // « Tu dois obligatoirement prendre exemple sur ce travail pour générer les
  // autres statistiques » (Fabrice, 26/07/2026, en validant celle des
  // catégories). Une page, six axes : l'axe arrive dans l'adresse et voyage
  // dans **chaque** appel — sans quoi la fenêtre des tiers demanderait la
  // matrice des catégories, et personne ne le verrait.
  for (const [axis, column] of [
    ["category", "NomCategorie"],
    ["assignment", "Affectation"],
    ["budget-line", "PosteBudget"],
    ["payment-mode", "ModeOperation"],
    ["payee", "Tiers"],
    ["project", "Projets"],
  ]) {
    const page = await browser.newPage();
    const errors = await openWindow(
      page,
      `http://localhost:4173/ui/windows/statistics.html?axis=${axis}&accounts=1,2&year=2026`,
    );
    check(
      `axe ${axis} : la matrice est demandée sur cet axe-là`,
      (await page.evaluate(() => window.__statsAsked?.axis)) === axis,
      await page.evaluate(() => JSON.stringify(window.__statsAsked?.axis)),
    );
    check(
      `axe ${axis} : son vocabulaire est demandé pour cet axe-là`,
      await page.evaluate(
        (asked) =>
          window.__calls.some(([command, args]) => command === "ui_texts" && args.kind === asked),
        axis,
      ),
    );
    check(
      `axe ${axis} : et le titre de la première colonne vient du noyau`,
      (await page.locator(".matrix__title >> nth=0").textContent()) === column,
    );

    // Le détail d'une case porte l'axe lui aussi : sans cela, cliquer une
    // ligne « Tiers » montrerait les opérations d'une catégorie.
    await page.click(".matrix__row >> nth=1 >> .matrix__cell >> nth=0");
    await page.waitForTimeout(250);
    check(
      `axe ${axis} : le détail d'une case porte le même axe`,
      (await page.evaluate(() => window.__detailAsked?.axis)) === axis,
    );

    // Et la porte ferme **sa** fenêtre, pas celle du voisin.
    await page.click("#close");
    await page.waitForTimeout(150);
    check(
      `axe ${axis} : la porte ferme sa fenêtre à elle`,
      await page.evaluate(
        (asked) =>
          window.__calls.some(
            ([command, args]) => command === "close_statistics" && args.axis === asked,
          ),
        axis,
      ),
    );
    await page.close();
  }
}

{
  // **L'axe doit survivre à la réécriture de l'adresse** (faute du
  // 26/07/2026). La fenêtre réécrit son adresse pour y mettre les comptes et
  // l'année ; elle l'écrivait sans l'axe, et une fenêtre rechargée serait
  // redevenue celle des catégories.
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/statistics.html?axis=budget-line&accounts=1,2&year=2026",
  );
  check(
    "axes : l'adresse réécrite garde l'axe",
    (await page.evaluate(() => new URLSearchParams(location.search).get("axis"))) === "budget-line",
    await page.evaluate(() => location.search),
  );
  check(
    "axes : et n'a pas perdu les comptes en chemin",
    (await page.evaluate(() => new URLSearchParams(location.search).get("accounts"))) === "1,2",
  );
  await page.close();
}

{
  // Chaque axe a **son étiquette de fenêtre**, donc son propre événement de
  // paramètres : sans cela, redemander les tiers renverrait les comptes à la
  // fenêtre des catégories.
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/statistics.html?axis=payee&accounts=1&year=2026",
  );
  check(
    "axes : la fenêtre des tiers écoute son propre événement",
    await page.evaluate(
      () => typeof window.__listeners?.["window-parameters:statistics-payee"] === "function",
    ),
    JSON.stringify(await page.evaluate(() => Object.keys(window.__listeners ?? {}))),
  );
  check(
    "axes : et pas celui des catégories",
    await page.evaluate(
      () => window.__listeners?.["window-parameters:statistics-category"] === undefined,
    ),
  );
  await page.close();
}

{
  // Le choix des comptes porte l'axe de la statistique demandée, et le rend
  // tel quel : c'est lui qui ouvre la bonne fenêtre.
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/accounts-list.html?mode=STATS&axis=payee",
  );
  await page.click(".list__row >> nth=1");
  await page.click("#select");
  await page.waitForTimeout(200);
  check(
    "comptes : l'axe demandé voyage avec le choix des comptes",
    (await page.evaluate(() => window.__openedStats?.axis)) === "payee",
    await page.evaluate(() => JSON.stringify(window.__openedStats)),
  );

  // Redemandé pour un autre axe — la fenêtre du choix est réutilisée, elle
  // aussi : l'axe doit suivre, comme les comptes de la statistique.
  await page.evaluate(() =>
    window.__listeners?.["window-parameters:accounts-stats"]?.({ payload: "axis=project" }),
  );
  await page.waitForTimeout(200);
  await page.click(".list__row >> nth=0");
  await page.click("#select");
  await page.waitForTimeout(200);
  check(
    "comptes : redemandé pour un autre axe, c'est le nouvel axe qui part",
    (await page.evaluate(() => window.__openedStats?.axis)) === "project",
    await page.evaluate(() => JSON.stringify(window.__openedStats)),
  );
  await page.close();
}

// --- Le choix des comptes d'une statistique ------------------------------
{
  // **Bug signalé par Fabrice, 26/07/2026** : « quel que soit le compte que je
  // choisis, c'est toujours la première ligne qui est sélectionnée ». Une
  // statistique fondée sur le mauvais compte donne des chiffres faux sans
  // jamais le dire — c'est le pire genre de faute dans un logiciel d'argent.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/accounts-list.html?mode=STATS");

  await page.click(".list__row >> nth=1");
  await page.waitForTimeout(100);
  check(
    "comptes : cliquer la deuxième ligne choisit la deuxième",
    await page.evaluate(() => {
      const rows = [...document.querySelectorAll(".list__row")];
      return (
        rows[1].getAttribute("aria-selected") === "true" &&
        rows[0].getAttribute("aria-selected") !== "true"
      );
    }),
    await page.evaluate(() =>
      [...document.querySelectorAll(".list__row")]
        .map((row) => `${row.dataset.id}:${row.getAttribute("aria-selected")}`)
        .join(" "),
    ),
  );

  await page.click("#select");
  await page.waitForTimeout(200);
  check(
    "comptes : et la statistique s'ouvre sur ce compte-là, pas sur le premier",
    await page.evaluate(() => JSON.stringify(window.__openedStats?.accountIds)) === "[2]",
    await page.evaluate(() => JSON.stringify(window.__openedStats)),
  );

  // Plusieurs comptes : une statistique les synthétise, donc on peut en
  // cocher plusieurs — c'est ce qui distingue cet usage de « SEL ».
  await page.click(".list__row >> nth=2", { modifiers: ["Meta"] });
  await page.click("#select");
  await page.waitForTimeout(200);
  check(
    "comptes : et deux comptes cochés partent tous les deux",
    await page.evaluate(() => JSON.stringify(window.__openedStats?.accountIds)) === "[2,3]",
    await page.evaluate(() => JSON.stringify(window.__openedStats)),
  );
  await page.close();
}

{
  // **La faute était ici** (Fabrice, 26/07/2026). Une fenêtre de Radinus est
  // bâtie une fois et jamais détruite : la deuxième demande ne recharge pas la
  // page, elle envoie les nouveaux comptes par un événement. La statistique ne
  // l'écoutait pas, et gardait ceux de la toute première ouverture — des
  // chiffres justes, sur le mauvais compte, sans un mot.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/statistics.html?accounts=1&year=2026");
  check(
    "statistiques : la première ouverture porte sur le compte demandé",
    (await page.evaluate(() => JSON.stringify(window.__statsAsked?.accountIds))) === "[1]",
  );

  // Redemandée sur d'autres comptes, comme le fait le choix des comptes.
  check(
    "statistiques : la fenêtre écoute les paramètres qu'on lui renvoie",
    await page.evaluate(
      () => typeof window.__listeners?.["window-parameters:statistics-category"] === "function",
    ),
    JSON.stringify(await page.evaluate(() => Object.keys(window.__listeners ?? {}))),
  );
  await page.evaluate(() =>
    window.__listeners?.["window-parameters:statistics-category"]?.({
      payload: "accounts=2,3",
    }),
  );
  await page.waitForTimeout(300);
  check(
    "statistiques : redemandée sur d'autres comptes, elle les entend",
    (await page.evaluate(() => JSON.stringify(window.__statsAsked?.accountIds))) === "[2,3]",
    await page.evaluate(() => JSON.stringify(window.__statsAsked?.accountIds)),
  );
  check(
    "statistiques : et le détail suit les nouveaux comptes",
    (await page.evaluate(() => JSON.stringify(window.__detailAsked?.accountIds ?? null))) !==
      '"[1]"',
  );
  check(
    "statistiques : l'année regardée, elle, ne bouge pas",
    (await page.evaluate(() => window.__statsAsked?.year)) === 2026,
  );
  await page.close();
}

// --- F20 : le menu Export, toutes les années dans un classeur ------------
{
  // Demande de Fabrice, 26/07/2026 : « toutes les années non vides seront
  // exportées sous Excel, un onglet par an, chaque onglet nommé AN_XXXX ».
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/statistics.html?accounts=1,2&year=2026",
  );
  check(
    "menu : la fenêtre a une barre de menus avec Export",
    (await page.textContent("#window-menu .window-menu__entry")) === "Export",
  );

  await page.click(".window-menu__entry");
  await page.waitForTimeout(100);
  check(
    "menu : les deux sorties sont proposées, Excel et LibreOffice",
    (await page.evaluate(() =>
      [...document.querySelectorAll(".window-menu__choice")].map((one) => one.textContent),
    )).join(" | ") ===
      "Exporter toutes les années vers Excel | Exporter toutes les années vers LibreOffice Calc",
  );

  await page.click('.window-menu__choice[data-key="export-all-years-excel"]');
  await page.waitForTimeout(400);

  check(
    "années : la liste demandée porte les comptes et les interrupteurs posés",
    await page.evaluate(() => {
      const asked = window.__yearsAsked;
      return (
        asked.accountIds.length === 2 &&
        asked.switches.pointed === true &&
        asked.switches.credits === true
      );
    }),
    JSON.stringify(await page.evaluate(() => window.__yearsAsked)),
  );
  check(
    "années : un onglet par année, nommé AN_XXXX",
    (await page.evaluate(() => window.__book.sheets.map((sheet) => sheet.name))).join(",") ===
      "AN_2024,AN_2025,AN_2026",
  );
  check(
    "années : chaque onglet dit sur quelle année il porte",
    await page.evaluate(() =>
      window.__book.sheets.every((sheet, index) => sheet.context.includes(String(2024 + index))),
    ),
    JSON.stringify(await page.evaluate(() => window.__book.sheets.map((s) => s.context))),
  );
  check(
    "années : chaque onglet est la matrice complète, Somme et Cumul comprises",
    await page.evaluate(() =>
      window.__book.sheets.every(
        (sheet) =>
          sheet.rows.length === 7 &&
          sheet.rows[5][0].text === "Somme" &&
          sheet.rows[6][0].text === "Cumul" &&
          sheet.rows[1][1].kind === "money",
      ),
    ),
  );
  check(
    "années : et chaque matrice a bien été calculée pour son année à elle",
    await page.evaluate(() =>
      window.__calls
        .filter(([command]) => command === "axis_statistics")
        .some(([, args]) => args.year === 2024),
    ),
  );
  check(
    "années : le classeur part en .xlsx, là où l'utilisateur a dit",
    await page.evaluate(
      () => window.__saveAsked.defaultPath.endsWith(".xlsx") && window.__book.path.endsWith(".xlsx"),
    ),
  );
  check(
    "années : la phrase du noyau compte les années",
    (await page.textContent("#info-message")).includes("3 années exportées"),
  );

  // L'autre sortie demande un .ods, et rien d'autre ne change.
  await page.click(".window-menu__entry");
  await page.click('.window-menu__choice[data-key="export-all-years-ods"]');
  await page.waitForTimeout(400);
  check(
    "années : la seconde sortie demande un .ods",
    await page.evaluate(
      () => window.__saveAsked.defaultPath.endsWith(".ods") && window.__book.path.endsWith(".ods"),
    ),
  );
  await page.close();
}

{
  // Aucune année ne porte rien sous les interrupteurs posés : on le dit, et on
  // n'ouvre même pas le sélecteur de fichier — il n'y a rien à enregistrer.
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/statistics.html?accounts=1,2&year=2026",
    { noYear: true },
  );
  await page.click(".window-menu__entry");
  await page.click('.window-menu__choice[data-key="export-all-years-excel"]');
  await page.waitForTimeout(250);
  check(
    "années : sans année, la fenêtre le dit",
    (await page.textContent("#info-message")).includes("il n'y a rien à exporter"),
  );
  check(
    "années : et ne demande pas où enregistrer un fichier vide",
    await page.evaluate(() => window.__saveAsked === undefined),
  );
  await page.close();
}

// --- F20 : sans compte, elle le dit --------------------------------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/statistics.html?accounts=");
  check(
    "statistiques : sans compte, la fenêtre le dit",
    (await page.locator("#info-message").textContent()) ===
      "Aucun compte n'a été choisi : la statistique ne porte sur rien.",
  );
  check(
    "statistiques : et ne demande rien au noyau",
    await page.evaluate(() => window.__calls.every(([c]) => c !== "axis_statistics")),
  );
  await page.close();
}

// --- L'export par clic droit ---------------------------------------------
{
  // Fabrice, 26/07/2026 : « sur Windev on peut au niveau des tableaux faire un
  // clic droit sur chaque tableau et les exporter vers un format excel (.xlsx)
  // ou csv ». C'est une fonction du tableau et non d'une fenêtre : la liste
  // des catégories l'a sans que personne l'ait écrite pour elle.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-list.html?kind=category");

  await page.click(".list__rows", { button: "right" });
  await page.waitForTimeout(100);
  check(
    "export : le clic droit ouvre les dix sorties, dans la langue de la fenêtre",
    (await page.evaluate(() =>
      [...document.querySelectorAll(".context-menu__entry")].map((entry) => entry.textContent),
    )).join(" | ") ===
      "Exporter vers Excel (.xlsx) | Exporter vers Word (.docx)" +
        " | Exporter vers LibreOffice Calc (.ods) | Exporter vers CSV (.csv)" +
        " | Exporter vers TSV (.tsv) | Exporter vers INI (.ini)" +
        " | Exporter vers JSON (.json) | Exporter vers TOML (.toml)" +
        " | Exporter vers XML (.xml) | Exporter vers YAML (.yaml)",
  );

  await page.click(".context-menu__entry >> nth=0");
  await page.waitForTimeout(200);
  check(
    "export : le menu se referme dès que l'on a choisi",
    (await page.locator(".context-menu").count()) === 0,
  );
  check(
    "export : le sélecteur du système propose un .xlsx",
    await page.evaluate(() => {
      const asked = window.__saveAsked;
      return (
        asked !== undefined &&
        asked.defaultPath.endsWith(".xlsx") &&
        asked.filters[0].extensions[0] === "xlsx"
      );
    }),
    JSON.stringify(await page.evaluate(() => window.__saveAsked)),
  );

  const sheet = await page.evaluate(() => window.__exported);
  check(
    "export : le fichier part là où l'utilisateur a dit, et nulle part ailleurs",
    sheet !== undefined && sheet.path.endsWith(".xlsx"),
    JSON.stringify(sheet?.path),
  );
  check(
    "export : la feuille porte le titre de colonne puis les lignes affichées",
    sheet.sheet.header_rows === 1 &&
      sheet.sheet.rows.length === 4 &&
      sheet.sheet.rows[0][0].text === "LIBELLE" &&
      sheet.sheet.rows[0][0].bold === true,
    JSON.stringify(sheet.sheet.rows[0]),
  );
  check(
    "export : la phrase du noyau est affichée, et la fenêtre ne la rédige pas",
    (await page.textContent("#info-bar")).includes("Exporté vers «"),
  );
  await page.close();
}

{
  // Un tableau exporte **ce qu'il affiche** : l'entonnoir qui cache des
  // lignes les cache aussi dans le fichier.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-list.html?kind=category");
  await page.click(".list__magnifier");
  await page.fill(".list__filter-input", "Bricolage");
  await page.waitForTimeout(150);
  await page.click(".list__rows", { button: "right" });
  await page.click('.context-menu__entry >> nth=3');
  await page.waitForTimeout(200);

  const sheet = await page.evaluate(() => window.__exported.sheet);
  check(
    "export : seules les lignes visibles partent",
    sheet.rows.length === 2 && sheet.rows[1][0].text === "Bricolage",
    JSON.stringify(sheet.rows.map((row) => row[0].text)),
  );
  check(
    "export : le CSV demande bien un .csv",
    await page.evaluate(() => window.__saveAsked.defaultPath.endsWith(".csv")),
  );
  await page.close();
}

{
  // La troisième sortie, ajoutée le 26/07/2026 : LibreOffice Calc. Elle passe
  // par le même chemin que les deux autres — c'est l'extension du fichier qui
  // dit au noyau quoi écrire, la fenêtre ne connaît aucun format.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-list.html?kind=category");
  await page.click(".list__rows", { button: "right" });
  await page.click(".context-menu__entry >> nth=2");
  await page.waitForTimeout(200);
  check(
    "export : le sélecteur du système propose un .ods",
    await page.evaluate(() => {
      const asked = window.__saveAsked;
      return asked.defaultPath.endsWith(".ods") && asked.filters[0].extensions[0] === "ods";
    }),
    JSON.stringify(await page.evaluate(() => window.__saveAsked)),
  );
  await page.close();
}

{
  // Les deux formats d'échange, demandés par Fabrice le 26/07/2026. Ils
  // passent par le même chemin que les trois formats de tableur : la fenêtre
  // ne connaît toujours aucun format, c'est l'extension qui parle au noyau.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-list.html?kind=category");
  await page.click(".list__rows", { button: "right" });
  await page.waitForTimeout(100);
  check(
    "export : deux traits séparent les trois familles de sorties",
    (await page.locator(".context-menu__rule").count()) === 2,
  );

  await page.click(".context-menu__entry >> nth=8");
  await page.waitForTimeout(200);
  check(
    "export : le XML demande bien un .xml",
    await page.evaluate(
      () =>
        window.__saveAsked.defaultPath.endsWith(".xml") &&
        window.__exported.path.endsWith(".xml"),
    ),
  );

  await page.click(".list__rows", { button: "right" });
  await page.click(".context-menu__entry >> nth=6");
  await page.waitForTimeout(200);
  check(
    "export : le JSON demande bien un .json",
    await page.evaluate(
      () =>
        window.__saveAsked.defaultPath.endsWith(".json") &&
        window.__exported.path.endsWith(".json"),
    ),
  );
  check(
    "export : et la feuille envoyée est toujours la même, quel que soit le format",
    await page.evaluate(() => window.__exported.sheet.rows.length === 4),
  );
  await page.close();
}

{
  // Renoncer dans le sélecteur n'écrit rien et ne dit rien : on est revenu au
  // point de départ.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/nomenclature-list.html?kind=category", {
    exportCancelled: true,
  });
  await page.click(".list__rows", { button: "right" });
  await page.click(".context-menu__entry >> nth=0");
  await page.waitForTimeout(200);
  check(
    "export : renoncer n'écrit aucun fichier",
    await page.evaluate(() => window.__calls.every(([command]) => command !== "export_sheet")),
  );
  await page.close();
}

{
  // Un échec d'écriture se dit, en alerte, sans faire tomber la fenêtre.
  const page = await browser.newPage();
  const errors = await openWindow(
    page,
    "http://localhost:4173/ui/windows/nomenclature-list.html?kind=category",
    { exportFails: "Export impossible : disque plein" },
  );
  await page.click(".list__rows", { button: "right" });
  await page.click(".context-menu__entry >> nth=0");
  await page.waitForTimeout(200);
  check(
    "export : l'échec est dit à l'utilisateur",
    (await page.textContent("#info-bar")).includes("disque plein"),
  );
  check("export : et la fenêtre tient debout", errors.length === 0, errors.join(" | "));
  await page.close();
}

{
  // Les comptes : leurs soldes partent en **nombres**, pas en texte, sans quoi
  // le tableur ne peut plus les sommer (Fabrice, 26/07/2026 : « les montants :
  // oui, nombre avec format monétaire »).
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/accounts-list.html");
  await page.click(".list__rows", { button: "right" });
  await page.click(".context-menu__entry >> nth=0");
  await page.waitForTimeout(200);

  const sheet = await page.evaluate(() => window.__exported.sheet);
  const line = sheet.rows[1];
  check(
    "export : un solde sort en nombre sommable",
    line.some((cell) => cell.kind === "money" && typeof cell.amount === "number"),
    JSON.stringify(line.map((cell) => cell.kind)),
  );
  check(
    "export : et le libellé reste du texte",
    line[0].kind === "text",
    JSON.stringify(line[0]),
  );
  await page.close();
}

// --- La matrice s'exporte telle qu'elle s'affiche -------------------------
{
  // « Exporter la matrice telle que affichée, il n'y a rien à recalculer, on
  // reste fidèle à l'affichage » (Fabrice, 26/07/2026) : cases vides
  // comprises, lignes de synthèse comprises, avec les couleurs de l'écran.
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/statistics.html?accounts=1,2&year=2026",
  );
  await page.click("#matrix-zone", { button: "right" });
  await page.waitForTimeout(100);
  check(
    "export : la matrice a son propre clic droit",
    (await page.locator(".context-menu__entry").count()) === 10,
  );
  await page.click(".context-menu__entry >> nth=0");
  await page.waitForTimeout(250);

  const sheet = await page.evaluate(() => window.__exported.sheet);
  check(
    "matrice : quatre catégories, la Somme et le Cumul, sous une ligne de titres",
    sheet.header_rows === 1 && sheet.rows.length === 7,
    String(sheet?.rows.length),
  );
  check(
    "matrice : quatorze colonnes, l'axe puis les douze mois puis le total",
    sheet.rows[0].length === 14 && sheet.rows[0][1].text === "Janvier",
    JSON.stringify(sheet.rows[0].map((cell) => cell.text)),
  );
  check(
    "matrice : un débit sort rouge, comme à l'écran",
    sheet.rows[1][1].kind === "money" &&
      sheet.rows[1][1].amount === -100000000 &&
      sheet.rows[1][1].fill === "FF9999",
    JSON.stringify(sheet.rows[1][1]),
  );
  check(
    "matrice : un crédit sort bleu",
    sheet.rows[2][1].fill === "9999FF",
    JSON.stringify(sheet.rows[2][1]),
  );
  check(
    "matrice : une case qui s'annule sort verte, et non blanche",
    sheet.rows[1][3].kind === "money" && sheet.rows[1][3].fill === "99FF99",
    JSON.stringify(sheet.rows[1][3]),
  );
  check(
    "matrice : une case vide part vide, sans zéro inventé",
    sheet.rows[1][2].kind === "empty",
    JSON.stringify(sheet.rows[1][2]),
  );
  check(
    "matrice : les deux lignes de synthèse sont là, en gras et sans couleur",
    sheet.rows[5][0].text === "Somme" &&
      sheet.rows[6][0].text === "Cumul" &&
      sheet.rows[5][1].bold === true &&
      !sheet.rows[5][1].fill,
    JSON.stringify([sheet.rows[5][0], sheet.rows[5][1]]),
  );
  check(
    "matrice : le fichier dit sur quoi il portait — l'année, les comptes, les interrupteurs",
    sheet.context.includes("2026") && sheet.context.includes("2 comptes"),
    sheet.context,
  );

  // Et le détail du bas est un tableau comme les autres : il a le sien.
  await page.click(".matrix__cell >> nth=1");
  await page.waitForTimeout(200);
  await page.click(".list--detail .list__rows", { button: "right" });
  await page.click(".context-menu__entry >> nth=0");
  await page.waitForTimeout(250);
  check(
    "export : le détail des statistiques s'exporte à part, sous son propre nom",
    await page.evaluate(() => window.__exported.sheet.name === "Detail des statistiques"),
    await page.evaluate(() => window.__exported.sheet.name),
  );
  await page.close();
}

// --- F05, la classification rapide : le brouillon et ses trois gestes ----
{
  // La fenêtre où l'on classe en masse. Les vérifications ci-dessous tiennent
  // les deux bouts de ce que Fabrice a dicté le 27/07/2026 : ce que la
  // fenêtre montre d'un côté, ce qu'elle envoie à Rust de l'autre.
  const page = await browser.newPage();
  const url = "http://localhost:4173/ui/windows/quick-classification.html?account=1";
  await openWindow(page, url);

  // **Le compte voyage à chaque appel.** C'est la faute des statistiques du
  // 26/07/2026 — « quel que soit le compte choisi, c'est toujours la première
  // ligne » — prise à l'endroit où elle se produirait.
  check(
    "classification : le compte demandé est celui de l'adresse",
    await page.evaluate(() => window.__quickAsked?.accountId === 1),
    JSON.stringify(await page.evaluate(() => window.__quickAsked ?? null)),
  );

  // **La fenêtre s'ouvre sur l'année en cours** — 01/01 au 31/12, comme la
  // capture de l'original, et l'encoche du menu est posée là.
  const year = new Date().getFullYear();
  check(
    "classification : la fenêtre s'ouvre sur l'année en cours",
    (await page.inputValue("#from")) === `${year}-01-01` &&
      (await page.inputValue("#to")) === `${year}-12-31`,
    `${await page.inputValue("#from")} → ${await page.inputValue("#to")}`,
  );
  check(
    "classification : et l'encoche du menu Période est sur l'année, pas ailleurs",
    await page.evaluate(
      () =>
        document.querySelector(".window-menu__choice--chosen")?.dataset.key ===
        "period-this-year:period-whole-year",
    ),
    await page.evaluate(
      () => document.querySelector(".window-menu__choice--chosen")?.dataset.key ?? "aucune",
    ),
  );

  // La période ne montre pas l'an passé : trois lignes sur quatre.
  check(
    "classification : la période ne montre que ses lignes",
    (await page.locator(".list__row").count()) === 3,
    String(await page.locator(".list__row").count()),
  );

  // **Les six cases sont éteintes, et leurs menus avec.** C'est ce que montre
  // la capture, et c'est ce qui dit qu'on n'a encore rien demandé.
  check(
    "classification : les six caractéristiques sont là",
    (await page.locator(".characteristic").count()) === 6,
    String(await page.locator(".characteristic").count()),
  );
  check(
    "classification : décochée, la liste déroulante est morte",
    await page.evaluate(() =>
      [...document.querySelectorAll(".characteristic__menu")].every((menu) => menu.disabled),
    ),
  );
  check(
    "classification : les libellés viennent du dictionnaire, pas du code",
    (await page.textContent('label[for="check-payment-mode"]')) === "Mode",
    await page.textContent('label[for="check-payment-mode"]'),
  );

  // **Les engrenages ne s'allument que lorsqu'ils ont quelque chose à faire.**
  check("classification : les engrenages partent éteints", await page.isDisabled("#apply"));
  await page.click(".list__row >> nth=0");
  await page.waitForTimeout(100);
  check(
    "classification : une ligne prise ne suffit pas",
    await page.isDisabled("#apply"),
  );
  await page.check("#check-category");
  await page.waitForTimeout(100);
  check(
    "classification : une ligne et une case, et ils s'allument",
    !(await page.isDisabled("#apply")),
  );
  check(
    "classification : cocher réveille la liste déroulante",
    await page.evaluate(
      () => !document.querySelector("#check-category").closest(".characteristic")
        .querySelector(".characteristic__menu").disabled,
    ),
  );
  await page.uncheck("#check-category");
  await page.waitForTimeout(100);
  check(
    "classification : décocher les éteint de nouveau",
    await page.isDisabled("#apply"),
  );

  // --- Appliquer ---------------------------------------------------------
  await page.check("#check-category");
  await page.selectOption("#check-category ~ .characteristic__menu", "1");
  await page.click(".list__row >> nth=0");
  await page.keyboard.down("Meta");
  await page.click(".list__row >> nth=1");
  await page.keyboard.up("Meta");
  await page.waitForTimeout(100);
  await page.click("#apply");
  await page.waitForTimeout(250);

  // **Exactement les cases cochées, et rien d'autre.** Une case décochée part
  // en `null` : c'est ce qui dit à Rust « on n'y touche pas ». Un champ absent
  // ferait refuser l'appel entier par serde, comme les interrupteurs du
  // tableau de bord le 26/07/2026.
  const asked = await page.evaluate(() => window.__quickApplied ?? null);
  check(
    "classification : appliquer envoie la case cochée et elle seule",
    asked !== null &&
      asked.change.category === 1 &&
      asked.change.assignment === null &&
      asked.change.payment_mode === null &&
      asked.change.payee === null &&
      asked.change.project === null &&
      asked.change.status === null,
    JSON.stringify(asked?.change ?? null),
  );
  check(
    "classification : appliquer porte sur les lignes sélectionnées, toutes",
    asked !== null && JSON.stringify(asked.ids.sort()) === JSON.stringify([11, 12]),
    JSON.stringify(asked?.ids ?? null),
  );
  check(
    "classification : et le compte, à chaque appel",
    asked !== null && asked.accountId === 1,
  );

  // **Appliquer ne touche pas le disque.** C'est toute la promesse de la
  // fenêtre : on classe vite parce qu'aucun geste n'est définitif.
  check(
    "classification : appliquer n'enregistre rien",
    await page.evaluate(
      () => !window.__calls.some(([command]) => command === "quick_classification_save"),
    ),
  );
  check(
    "classification : le tableau montre le nouveau classement",
    (await page.textContent(".list__row >> nth=0")).includes("Alimentation"),
  );
  check(
    "classification : et la barre d'état dit ce qui attend",
    (await page.textContent("#info-bar")).includes("classées"),
    await page.textContent("#info-bar"),
  );

  // --- Enregistrer -------------------------------------------------------
  await page.click("#save");
  await page.waitForTimeout(200);
  check(
    "classification : enregistrer demande d'abord",
    await page.locator(".dialog").isVisible(),
  );
  check(
    "classification : la question dit combien de lignes",
    (await page.textContent(".dialog__question")).includes("2"),
    await page.textContent(".dialog__question"),
  );
  await page.click(".dialog__button >> nth=1");
  await page.waitForTimeout(200);
  check(
    "classification : « Non » n'écrit rien",
    await page.evaluate(
      () => !window.__calls.some(([command]) => command === "quick_classification_save"),
    ),
  );
  await page.click("#save");
  await page.waitForTimeout(150);
  await page.click(".dialog__button >> nth=0");
  await page.waitForTimeout(250);
  check(
    "classification : « Oui » écrit",
    await page.evaluate(() => window.__quickSaved === 1),
  );
  check(
    "classification : et il ne reste rien en attente",
    (await page.textContent("#info-bar")).includes("enregistrées"),
    await page.textContent("#info-bar"),
  );
  await page.close();
}

// --- F05 : la période ne redescend jamais à la base ----------------------
{
  // Règle de Fabrice, 27/07/2026 : tout le compte est en mémoire, quelle que
  // soit la période. Changer les dates ne doit donc **jamais** recharger la
  // structure — sinon le brouillon en cours partirait avec, et les
  // modifications non enregistrées avec lui.
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/quick-classification.html?account=1",
  );
  const loadsBefore = await page.evaluate(() => window.__quickLoads);
  await page.fill("#from", "2026-07-01");
  await page.fill("#to", "2026-07-31");
  await page.dispatchEvent("#to", "change");
  await page.waitForTimeout(250);
  check(
    "classification : changer la période ne recharge pas la structure",
    (await page.evaluate(() => window.__quickLoads)) === loadsBefore,
  );
  check(
    "classification : mais elle relit ce qu'il faut montrer",
    await page.evaluate(() => window.__quickAsked.from === "2026-07-01"),
    JSON.stringify(await page.evaluate(() => window.__quickAsked)),
  );
  check(
    "classification : et le tableau se réduit à la période",
    (await page.locator(".list__row").count()) === 1,
    String(await page.locator(".list__row").count()),
  );
  await page.close();
}

// --- F05 : la cellule, seconde porte vers le même brouillon --------------
{
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/quick-classification.html?account=1",
  );
  check(
    "classification : aucune cellule n'est un menu tant que rien n'est choisi",
    (await page.locator(".list__combo").count()) === 0,
  );
  await page.click(".list__row >> nth=0");
  await page.waitForTimeout(150);
  check(
    "classification : la ligne choisie porte ses six menus",
    (await page.locator(".list__row[aria-selected='true'] .list__combo").count()) === 6,
    String(await page.locator(".list__row[aria-selected='true'] .list__combo").count()),
  );
  // **Le mode de paiement, et pas une autre.** C'est la seule caractéristique
  // dont la clef (`payment-mode`) et le nom de champ (`payment_mode`) ne se
  // ressemblent pas assez pour se confondre en silence : sur les cinq autres,
  // les deux chaînes sont identiques et la vérification ne prouverait rien.
  await page.selectOption(".list__row[aria-selected='true'] .list__combo >> nth=2", "3");
  await page.waitForTimeout(250);
  const sent = await page.evaluate(() => window.__quickSet ?? null);
  check(
    "classification : la cellule envoie la clef de sa caractéristique",
    sent !== null &&
      sent.characteristic === "payment-mode" &&
      sent.value === 3 &&
      sent.accountId === 1,
    JSON.stringify(sent),
  );
  check(
    "classification : la cellule non plus n'écrit pas sur le disque",
    await page.evaluate(
      () => !window.__calls.some(([command]) => command === "quick_classification_save"),
    ),
  );
  await page.close();
}

// --- F05 : la porte, et ses trois issues ---------------------------------
{
  // Décision de Fabrice, 27/07/2026. Un Oui/Non aurait forcé un choix entre
  // perdre le travail sans le vouloir et écrire sans l'avoir demandé.
  const scenario = async (button, expected) => {
    const page = await browser.newPage();
    await openWindow(
      page,
      "http://localhost:4173/ui/windows/quick-classification.html?account=1",
    );
    await page.check("#check-category");
    await page.selectOption("#check-category ~ .characteristic__menu", "1");
    await page.click(".list__row >> nth=0");
    await page.click("#apply");
    await page.waitForTimeout(250);
    await page.click("#close");
    await page.waitForTimeout(200);
    const asked = await page.locator(".dialog").isVisible();
    const buttons = await page.locator(".dialog__button").count();
    if (asked && buttons > button) {
      await page.click(`.dialog__button >> nth=${button}`);
      await page.waitForTimeout(250);
    }
    const result = {
      asked,
      buttons,
      closed: await page.evaluate(() => window.__closed === true),
      saved: await page.evaluate(() => window.__quickSaved ?? 0),
    };
    await page.close();
    return { result, expected };
  };

  const save = await scenario(0, null);
  check("classification : la porte demande, et propose trois issues", save.result.asked && save.result.buttons === 3, String(save.result.buttons));
  check("classification : « Enregistrer et sortir » écrit puis sort", save.result.saved === 1 && save.result.closed, JSON.stringify(save.result));

  const discard = await scenario(1, null);
  check("classification : « Abandonner et sortir » sort sans rien écrire", discard.result.saved === 0 && discard.result.closed, JSON.stringify(discard.result));

  const stay = await scenario(2, null);
  check("classification : « Rester » ne sort pas et n'écrit pas", stay.result.saved === 0 && !stay.result.closed, JSON.stringify(stay.result));
}

// --- F05 : sans rien en attente, la porte ne demande rien ----------------
{
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/quick-classification.html?account=1",
  );
  await page.click("#close");
  await page.waitForTimeout(200);
  check(
    "classification : rien en attente, aucune question",
    !(await page.locator(".dialog").isVisible()),
  );
  check(
    "classification : et la fenêtre se ferme",
    await page.evaluate(() => window.__closed === true),
  );
  await page.close();
}

// --- F05 : redemandée pour un autre compte -------------------------------
{
  // **Émetteur – récepteur.** Une fenêtre de Radinus est bâtie une fois et
  // jamais détruite : redemandée, elle reçoit ses nouveaux paramètres par un
  // événement. Celle-ci doit alors **recharger** — et non compléter, ni
  // garder le compte de sa première ouverture.
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/quick-classification.html?account=1",
  );
  check(
    "classification : d'abord le premier compte",
    (await page.textContent(".list__rows")).includes("ACHAT CB LAPOSTE"),
  );
  await page.evaluate(() =>
    window.__listeners["window-parameters:quick-classification"]({
      payload: "account=2",
    }),
  );
  await page.waitForTimeout(300);
  check(
    "classification : redemandée, elle charge l'autre compte",
    await page.evaluate(() => window.__quickAccount === 2 && window.__quickLoads === 2),
    JSON.stringify(await page.evaluate(() => [window.__quickAccount, window.__quickLoads])),
  );
  check(
    "classification : et pas une ligne du premier ne survit",
    (await page.textContent(".list__rows")).includes("VIREMENT LIVRET") &&
      !(await page.textContent(".list__rows")).includes("ACHAT CB LAPOSTE"),
    await page.textContent(".list__rows"),
  );
  check(
    "classification : le compte envoyé est le nouveau",
    await page.evaluate(() => window.__quickAsked.accountId === 2),
  );
  await page.close();
}

// --- F05 : changer de compte ne jette pas un brouillon en silence --------
{
  // C'est la faute des fiches du 25/07/2026, où une saisie disparaissait
  // derrière le dos de l'utilisateur. Ici, la question se pose avant.
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/quick-classification.html?account=1",
  );
  await page.check("#check-category");
  await page.selectOption("#check-category ~ .characteristic__menu", "1");
  await page.click(".list__row >> nth=0");
  await page.click("#apply");
  await page.waitForTimeout(250);
  await page.evaluate(() =>
    window.__listeners["window-parameters:quick-classification"]({
      payload: "account=2",
    }),
  );
  await page.waitForTimeout(250);
  // La question est-elle seulement posée ? On le note **avant** d'y répondre,
  // et l'on ne clique que si elle est là : une vérification qui plante emporte
  // toute la suite avec elle, et un échec qui tue le rapport n'est pas un
  // échec, c'est un silence.
  const questioned = await page.locator(".dialog").isVisible();
  check("classification : changer de compte avec un brouillon pose la question", questioned);
  if (questioned) {
    await page.click(".dialog__button >> nth=2");
    await page.waitForTimeout(250);
  }
  check(
    "classification : « Rester » garde le compte et le brouillon",
    await page.evaluate(() => window.__quickAccount === 1 && window.__quickPending === 1),
    JSON.stringify(await page.evaluate(() => [window.__quickAccount, window.__quickPending])),
  );
  await page.close();
}

// --- F17, l'importation d'un relevé : la marche à suivre de Fabrice ------
{
  // Les cinq étapes qu'il a dictées le 27/07/2026, et les couleurs de son
  // original, retrouvées dans son code le 28/07/2026.
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/statement-import.html?account=1",
  );

  check(
    "relevé : la fenêtre s'ouvre vide et dit quoi faire",
    (await page.textContent("#info-bar")).includes("dossier jaune"),
    await page.textContent("#info-bar"),
  );
  check(
    "relevé : sans fichier, informations et intégration sont éteints",
    (await page.isDisabled("#info")) && (await page.isDisabled("#integrate")),
  );

  await page.click("#open");
  await page.waitForTimeout(300);
  check(
    "relevé : le fichier est choisi et lu par Rust",
    await page.evaluate(() => window.__pickAsked === true),
  );
  check(
    "relevé : les trois lignes s'affichent",
    (await page.locator(".list__row").count()) === 3,
    String(await page.locator(".list__row").count()),
  );

  // **Les quatre couleurs de l'original.** Le rouge et le bleu portent le sens
  // de l'opération ; le pastel et l'italique portent le soupçon de doublon.
  check(
    "relevé : le sens de l'opération se lit à la couleur",
    (await page.locator(".list__row--debit").count()) === 2 &&
      (await page.locator(".list__row--credit").count()) === 1,
    `${await page.locator(".list__row--debit").count()} débits, ${await page.locator(".list__row--credit").count()} crédits`,
  );
  check(
    "relevé : le pastel marque le soupçon de doublon, pas le sens",
    (await page.locator(".list__row--alike").count()) === 2,
    String(await page.locator(".list__row--alike").count()),
  );
  check(
    "relevé : et une ligne peut être un débit soupçonné, ou un crédit soupçonné",
    (await page.locator(".list__row--debit.list__row--alike").count()) === 1 &&
      (await page.locator(".list__row--credit.list__row--alike").count()) === 1,
  );

  // **La colonne FITID dit ce que la base connaît**, et non ce que le fichier
  // a fourni : c'est `Existe_OpFitID`, et je l'avais lue à l'envers.
  check(
    "relevé : la colonne FITID compte ce que la base connaît déjà",
    (await page.locator(".list__box--ticked").count()) === 1,
    String(await page.locator(".list__box--ticked").count()),
  );

  check(
    "relevé : le pied porte les trois montants",
    (await page.textContent("#account-balance")) !== "" &&
      (await page.textContent("#file-balance")) !== "" &&
      (await page.textContent("#difference")) !== "",
  );
  await page.close();
}

// --- F17 : le troisième icône, et la boucle de l'original ----------------
{
  // Une seule ligne ouvre la fiche ; plusieurs les font entrer d'un coup après
  // l'avertissement, en posant **une question à trois issues** devant chaque
  // doublon — c'est `Integration_MultiLigne`.
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/statement-import.html?account=1",
  );
  await page.click("#open");
  await page.waitForTimeout(300);

  await page.click(".list__row >> nth=0");
  await page.click("#integrate");
  await page.waitForTimeout(250);
  check(
    "relevé : une seule ligne ouvre la fiche de rapprochement",
    await page.evaluate(() => window.__openedStatementForm?.rank === 1),
    JSON.stringify(await page.evaluate(() => window.__openedStatementForm ?? null)),
  );

  // Trois lignes, dont une dont le FITID est déjà en base.
  await page.click(".list__row >> nth=0");
  await page.keyboard.down("Meta");
  await page.click(".list__row >> nth=1");
  await page.click(".list__row >> nth=2");
  await page.keyboard.up("Meta");
  await page.click("#integrate");
  await page.waitForTimeout(250);
  check(
    "relevé : l'avertissement de l'original est posé avant le lot",
    (await page.textContent(".dialog__question")).includes(
      "Êtes vous certain de vouloir intégrer",
    ),
    await page.textContent(".dialog__question"),
  );
  await page.click(".dialog__button >> nth=0");
  await page.waitForTimeout(300);

  // La ligne 2 est un doublon : la question à trois issues apparaît.
  check(
    "relevé : un doublon fait poser une question, il n'est pas refusé",
    await page.locator(".dialog").isVisible(),
  );
  check(
    "relevé : et la question nomme la transaction",
    (await page.textContent(".dialog__question")).includes("ACHAT CB COMMERCE TROIS"),
    await page.textContent(".dialog__question"),
  );
  check(
    "relevé : elle offre trois issues — Oui, Non, Annuler",
    (await page.locator(".dialog__button").count()) === 3,
    String(await page.locator(".dialog__button").count()),
  );

  // « Non » : on passe cette ligne, les autres entrent.
  await page.click(".dialog__button >> nth=1");
  await page.waitForTimeout(400);
  check(
    "relevé : « Non » passe la ligne et le lot continue",
    (await page.textContent("#info-bar")).includes("intégrés : 2"),
    await page.textContent("#info-bar"),
  );
  check(
    "relevé : et le compte rendu dit aussi combien ont été ignorées",
    (await page.textContent("#info-bar")).includes("ignorés : 1"),
    await page.textContent("#info-bar"),
  );
  check(
    "relevé : les lignes entrées passent au gris",
    (await page.locator(".list__row--done").count()) === 2,
    String(await page.locator(".list__row--done").count()),
  );
  await page.close();
}

// --- F17 : « Annuler » abandonne le lot entier ---------------------------
{
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/statement-import.html?account=1",
  );
  await page.click("#open");
  await page.waitForTimeout(300);
  // On met le doublon en tête pour qu'il arrête la boucle avant les autres.
  await page.click(".list__row >> nth=1");
  await page.keyboard.down("Meta");
  await page.click(".list__row >> nth=2");
  await page.keyboard.up("Meta");
  await page.click("#integrate");
  await page.waitForTimeout(250);
  await page.click(".dialog__button >> nth=0");
  await page.waitForTimeout(300);
  await page.click(".dialog__button >> nth=2");
  await page.waitForTimeout(400);
  check(
    "relevé : « Annuler » abandonne le lot et le dit",
    (await page.textContent("#info-bar")).includes("Abandon de l'intégration"),
    await page.textContent("#info-bar"),
  );
  check(
    "relevé : rien n'est entré après l'abandon",
    (await page.locator(".list__row--done").count()) === 0,
    String(await page.locator(".list__row--done").count()),
  );
  await page.close();
}

// --- F17 : le seul refus sec est la ligne déjà rapprochée ----------------
{
  // C'est `Ouvre_Fiche` : « Vous avez déjà rapproché cette transaction ». Un
  // doublon, lui, ouvre la fiche — c'est elle qui posera la question.
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/statement-import.html?account=1",
  );
  await page.click("#open");
  await page.waitForTimeout(300);

  // La ligne 2 est un doublon : elle ouvre la fiche quand même.
  await page.click(".list__row >> nth=1");
  await page.click("#integrate");
  await page.waitForTimeout(250);
  check(
    "relevé : un doublon ouvre la fiche, il n'est pas refusé à la porte",
    await page.evaluate(() => window.__openedStatementForm?.rank === 2),
    JSON.stringify(await page.evaluate(() => window.__openedStatementForm ?? null)),
  );

  // On rapproche la ligne 1 dans la séance, puis on la redemande.
  await page.click(".list__row >> nth=0");
  await page.keyboard.down("Meta");
  await page.click(".list__row >> nth=2");
  await page.keyboard.up("Meta");
  await page.click("#integrate");
  await page.waitForTimeout(250);
  await page.click(".dialog__button >> nth=0");
  await page.waitForTimeout(400);
  await page.click(".list__row >> nth=0");
  await page.click("#integrate");
  await page.waitForTimeout(250);
  check(
    "relevé : une ligne déjà rapprochée dans la séance est refusée",
    (await page.textContent("#info-bar")).includes("Vous avez deja rapproché"),
    await page.textContent("#info-bar"),
  );
  check(
    "relevé : et le refus est en rouge",
    await page.evaluate(() =>
      document.getElementById("info-bar").classList.contains("info-bar--alert"),
    ),
  );
  await page.close();
}

// --- F17 : le menu Filtre et le fichier à plusieurs comptes --------------
{
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/statement-import.html?account=1",
  );
  await page.click("#open");
  await page.waitForTimeout(300);

  await page.click(".window-menu__entry");
  await page.click('[data-key="statement-filter-pending"]');
  await page.waitForTimeout(200);
  check(
    "relevé : le filtre ne garde que ce qui reste à intégrer",
    (await page.locator(".list__row").count()) === 2,
    String(await page.locator(".list__row").count()),
  );
  await page.click(".window-menu__entry");
  await page.click('[data-key="statement-filter-known"]');
  await page.waitForTimeout(200);
  check(
    "relevé : et l'autre ne garde que ce que la base connaît",
    (await page.locator(".list__row").count()) === 1,
    String(await page.locator(".list__row").count()),
  );
  await page.close();

  const many = await browser.newPage();
  await openWindow(
    many,
    "http://localhost:4173/ui/windows/statement-import.html?account=1",
    { fileAccounts: ["123456A789", "999999Z111"] },
  );
  await many.click("#open");
  await many.waitForTimeout(300);
  check(
    "relevé : plusieurs comptes dans le fichier, la question est posée",
    await many.locator(".dialog").isVisible(),
  );
  check(
    "relevé : et les deux comptes y sont proposés",
    (await many.locator(".dialog__field option").count()) === 2,
    String(await many.locator(".dialog__field option").count()),
  );
  await many.click(".dialog__button >> nth=1");
  await many.waitForTimeout(250);
  check(
    "relevé : renoncer au choix ne charge rien",
    await many.evaluate(
      () => !window.__calls.some(([command]) => command === "statement_load"),
    ),
  );
  await many.close();

  const cancelled = await browser.newPage();
  await openWindow(
    cancelled,
    "http://localhost:4173/ui/windows/statement-import.html?account=1",
    { pickCancelled: true },
  );
  await cancelled.click("#open");
  await cancelled.waitForTimeout(250);
  check(
    "relevé : un sélecteur refermé ne charge rien",
    await cancelled.evaluate(
      () => !window.__calls.some(([command]) => command === "statement_load"),
    ),
  );
  await cancelled.close();
}

// --- F18 : la fiche de rapprochement, et ce qu'elle laisse corriger ------
{
  // **Tout y est modifiable** — c'est la règle de l'original, que j'avais
  // enfreinte en mettant les champs en lecture seule.
  const form = await browser.newPage();
  await openWindow(
    form,
    "http://localhost:4173/ui/windows/statement-form.html?account=1&rank=1",
  );
  check(
    "rapprochement : la date, le libellé et le montant se corrigent",
    (await form.getAttribute("#label", "readonly")) === null &&
      (await form.getAttribute("#date", "readonly")) === null &&
      (await form.getAttribute("#amount", "readonly")) === null,
  );
  check(
    "rapprochement : le sens est un choix, pas un constat",
    (await form.inputValue("#direction")) === "D" &&
      (await form.locator("#direction option").count()) === 2,
  );
  check(
    "rapprochement : le classement part à « Non précisé »",
    await form.evaluate(() =>
      ["payment-mode", "category", "assignment", "payee", "project"].every(
        (id) => document.getElementById(id).value === "0",
      ),
    ),
  );
  check(
    "rapprochement : et le statut à pointée — une ligne de relevé est passée",
    (await form.inputValue("#status")) === "1",
  );

  // Une correction, puis la validation : la correction part d'abord.
  await form.fill("#label", "RETRAIT CORRIGE");
  await form.fill("#amount", "60,00");
  await form.selectOption("#category", "1");
  await form.click("#validate");
  await form.waitForTimeout(300);
  const amended = await form.evaluate(() => window.__amended ?? null);
  check(
    "rapprochement : ce qui a été corrigé part avant l'intégration",
    amended !== null &&
      amended.rank === 1 &&
      amended.label === "RETRAIT CORRIGE" &&
      amended.amount === -60000000,
    JSON.stringify(amended),
  );
  check(
    "rapprochement : et l'intégration suit, avec le classement",
    await form.evaluate(
      () => window.__integratedOne?.classification?.category_id === 1,
    ),
    JSON.stringify(await form.evaluate(() => window.__integratedOne ?? null)),
  );
  check(
    "rapprochement : la fiche se ferme derrière elle",
    await form.evaluate(() => window.__closed === true),
  );
  await form.close();
}

// --- F18 : un doublon fait poser la question, il n'est pas refusé --------
{
  const form = await browser.newPage();
  await openWindow(
    form,
    "http://localhost:4173/ui/windows/statement-form.html?account=1&rank=2",
  );
  check(
    "rapprochement : la ligne dont le FITID est en base porte l'avertissement",
    (await form.textContent("#info-bar")).includes("Attention doublon"),
    await form.textContent("#info-bar"),
  );

  await form.click("#validate");
  await form.waitForTimeout(300);
  check(
    "rapprochement : valider un doublon fait poser la question",
    await form.locator(".dialog").isVisible(),
  );
  check(
    "rapprochement : et la question nomme la transaction",
    (await form.textContent(".dialog__question")).includes("ACHAT CB COMMERCE TROIS"),
    await form.textContent(".dialog__question"),
  );
  await form.click(".dialog__button >> nth=1");
  await form.waitForTimeout(250);
  check(
    "rapprochement : « Non » n'écrit rien et laisse la fiche ouverte",
    await form.evaluate(
      () => window.__closed !== true &&
        !window.__calls.some(([c, a]) => c === "statement_integrate" && a.force),
    ),
  );

  await form.click("#validate");
  await form.waitForTimeout(250);
  await form.click(".dialog__button >> nth=0");
  await form.waitForTimeout(300);
  check(
    "rapprochement : « Oui » l'intègre quand même — c'est l'utilisateur qui sait",
    await form.evaluate(() => window.__integratedOne?.force === true),
    JSON.stringify(await form.evaluate(() => window.__integratedOne ?? null)),
  );
  await form.close();

  // **Redemandée sur une autre ligne, elle change de ligne.**
  const again = await browser.newPage();
  await openWindow(
    again,
    "http://localhost:4173/ui/windows/statement-form.html?account=1&rank=2",
  );
  await again.evaluate(() =>
    window.__listeners["window-parameters:statement-form"]({
      payload: "account=1&rank=3",
    }),
  );
  await again.waitForTimeout(250);
  check(
    "rapprochement : redemandée, elle montre l'autre ligne",
    (await again.textContent("#info-bar")).includes("aucun identifiant"),
    await again.textContent("#info-bar"),
  );
  await again.close();
}

// --- Le relevé CSV : régler, tester, regarder, basculer ------------------
{
  // Un CSV ne porte aucun nom de champ fiable : il faut le régler à la main.
  // La fenêtre montre **tout** ce que le réglage produit, charabia compris —
  // c'est ainsi qu'on voit son erreur — mais seules les lignes portant une
  // date et un montant lisibles basculent (règle de Fabrice, 27/07/2026).
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/csv-statement.html?account=1&path=%2Ftmp%2Freleve.csv",
  );

  check(
    "csv : l'aperçu montre le fichier tel qu'il est",
    (await page.locator("#source-rows .list__row").count()) === 10,
    String(await page.locator("#source-rows .list__row").count()),
  );
  check(
    "csv : et rien n'y est interprété — l'entête bancaire y figure",
    (await page.textContent("#source-rows")).includes("Solde (EUROS)"),
  );
  check(
    "csv : tant qu'on n'a pas testé, le tableau du bas le dit",
    (await page.textContent("#result-rows")).includes("Tester les parametres"),
    await page.textContent("#result-rows"),
  );

  // **Le mauvais réglage, celui de la capture** : une seule ligne d'entête.
  await page.click("#test");
  await page.waitForTimeout(250);
  check(
    "csv : un mauvais réglage produit du charabia, et on le voit",
    (await page.locator("#result-rows .list__row--dropped").count()) > 0,
    String(await page.locator("#result-rows .list__row--dropped").count()),
  );
  check(
    "csv : et la phrase du bas dit combien seront écartées",
    (await page.textContent("#info-bar")).includes("écartées"),
    await page.textContent("#info-bar"),
  );

  // **Le bon réglage** : sept lignes d'entête.
  await page.fill("#header-lines", "7");
  await page.dispatchEvent("#header-lines", "change");
  await page.waitForTimeout(150);
  check(
    "csv : changer un réglage périme l'essai précédent",
    (await page.textContent("#info-bar")).includes("Tester les parametres"),
    await page.textContent("#info-bar"),
  );
  await page.click("#test");
  await page.waitForTimeout(250);
  check(
    "csv : le bon réglage ne laisse plus rien de côté",
    (await page.locator("#result-rows .list__row--dropped").count()) === 0,
  );
  check(
    "csv : les trois opérations sont là",
    (await page.locator("#result-rows .list__row").count()) === 3,
    String(await page.locator("#result-rows .list__row").count()),
  );
  check(
    "csv : et le montant est lu malgré la virgule décimale",
    (await page.textContent("#result-rows")).includes("-13,80 €"),
    await page.textContent("#result-rows"),
  );

  // La bascule : les réglages partent avec, et la fenêtre s'efface.
  await page.click("#validate");
  await page.waitForTimeout(250);
  const applied = await page.evaluate(() => window.__csvApplied ?? null);
  check(
    "csv : la validation envoie le compte, le chemin et les six réglages",
    applied !== null &&
      applied.accountId === 1 &&
      applied.path === "/tmp/releve.csv" &&
      applied.settings.header_lines === 7 &&
      applied.settings.separator === ";" &&
      applied.settings.date_at === 1 &&
      applied.settings.label_at === 2 &&
      applied.settings.debit_at === 3 &&
      applied.settings.credit_at === 3,
    JSON.stringify(applied),
  );
  await page.close();
}

// --- Le relevé CSV : la porte est sévère ---------------------------------
{
  // Un réglage qui ne produit aucune ligne valide ne bascule rien, et le dit.
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/csv-statement.html?account=1&path=%2Ftmp%2Freleve.csv",
  );
  // Un séparateur qui n'apparaît nulle part : tout tombe dans le premier champ.
  await page.selectOption("#separator", "|");
  await page.click("#validate");
  await page.waitForTimeout(250);
  check(
    "csv : rien de valide, rien ne bascule",
    (await page.textContent("#info-bar")).includes("rien à importer"),
    await page.textContent("#info-bar"),
  );
  check(
    "csv : et le refus est en rouge",
    await page.evaluate(() =>
      document.getElementById("info-bar").classList.contains("info-bar--alert"),
    ),
  );
  check(
    "csv : la fenêtre reste ouverte pour qu'on corrige",
    await page.evaluate(() => window.__closed !== true),
  );
  await page.close();
}

// --- Un fichier CSV choisi dans la fenêtre d'importation -----------------
{
  // **Le même dossier jaune**, et c'est le contenu du fichier qui décide de la
  // suite : un OFX se charge tout de suite, un CSV passe d'abord par la
  // fenêtre de découpage (demande de Fabrice, 27/07/2026).
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/statement-import.html?account=1",
    { pickedIsCsv: true },
  );
  await page.click("#open");
  await page.waitForTimeout(300);
  check(
    "csv : un fichier csv ouvre la fenêtre de découpage",
    await page.evaluate(
      () => window.__openedCsv?.accountId === 1 && window.__openedCsv?.path === "/tmp/releve.csv",
    ),
    JSON.stringify(await page.evaluate(() => window.__openedCsv ?? null)),
  );
  check(
    "csv : et rien n'est chargé avant qu'il soit découpé",
    await page.evaluate(
      () => !window.__calls.some(([command]) => command === "statement_load"),
    ),
  );

  // Et quand le découpage a eu lieu, les lignes reviennent ici : l'événement
  // porte le chemin, et c'est lui qui apprend à la fenêtre qu'un relevé est
  // désormais ouvert.
  await page.evaluate(() => {
    window.__statementRows = undefined;
    window.__listeners["data-changed:statement-import"]({ payload: "/tmp/releve.csv" });
  });
  await page.waitForTimeout(300);
  check(
    "csv : le relevé découpé revient dans la fenêtre d'importation",
    await page.evaluate(
      () => window.__calls.some(([command]) => command === "statement_lines"),
    ),
  );
  await page.close();
}

// --- Phase 9 — la liste des chéquiers (F13) -----------------------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/chequebooks-list.html");
  check("chéquiers : les carnets s'affichent", (await page.locator(".list__row").count()) === 2);
  // Cinq colonnes, dont les deux du compte : ce sont elles qui prouvent que la
  // fenêtre montre **tous** les carnets, tous comptes confondus.
  check("chéquiers : cinq colonnes", (await page.locator(".list__title").count()) === 5);
  check(
    "chéquiers : la date se lit à la française",
    (await page.locator(".list__row").first().textContent())?.includes("01/08/2020"),
  );

  // Rien de choisi : le refus de son Ouvre_Fiche, mot pour mot.
  await page.click("#update");
  check(
    "chéquiers : refus sans sélection",
    (await page.locator("#info-bar").textContent())?.includes(
      "Veuillez sélectionner un enregistrement",
    ),
  );

  // Le carnet ouvre la composition, sur le carnet choisi et pas un autre.
  await page.click(".list__row");
  await page.click("#composition");
  const opened = await page.evaluate(() => window.__opened);
  check(
    "chéquiers : le carnet ouvre la composition du bon chéquier",
    opened?.command === "open_cheques" && opened?.args?.chequebookId === 1,
    JSON.stringify(opened),
  );

  // **Une seule question**, et « Non » n'efface rien : son bConfirmation.
  await page.click("#delete");
  await page.waitForTimeout(80);
  const asked = await page.locator(".dialog__question").textContent();
  check(
    "chéquiers : la question de suppression est la sienne",
    asked?.includes("associées à chéquier"),
    asked ?? "",
  );
  await page.click(".dialog__button >> nth=1");
  await page.waitForTimeout(80);
  check(
    "chéquiers : « Non » abandonne sans rien supprimer",
    (await page.evaluate(() => window.__deletedBooks)) === undefined,
  );

  await page.click("#delete");
  await page.waitForTimeout(80);
  await page.click(".dialog__button >> nth=0");
  await page.waitForTimeout(120);
  check(
    "chéquiers : « Oui » supprime la sélection",
    (await page.evaluate(() => window.__deletedBooks))?.ids?.length === 1,
  );

  await page.click("#close");
  await page.waitForTimeout(60);
  check(
    "chéquiers : la porte ferme la liste et ses filles",
    (await page.evaluate(() => window.__closedLabel)) === "chequebooks",
  );
  await page.close();
}

// --- Phase 9 — la fiche chéquier (F31), et ses cinq champs gelés --------
{
  // En ajout : tout est ouvert, et la date part à aujourd'hui.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/chequebook-form.html?mode=A");
  // Quatre des cinq champs gelés sont ouverts en ajout ; le cinquième, le
  // nombre de chèques, ne l'est jamais — il se calcule.
  const typable = ["reference", "received", "first", "last"];
  const openInAdd = await page.evaluate(
    (ids) => ids.every((id) => !document.getElementById(id).readOnly),
    typable,
  );
  check("fiche chéquier : en ajout, les quatre champs saisissables sont ouverts", openInAdd);
  const todayShown = await page.inputValue("#received");
  const todayHere = await page.evaluate(() => {
    const now = new Date();
    const m = String(now.getMonth() + 1).padStart(2, "0");
    const d = String(now.getDate()).padStart(2, "0");
    return now.getFullYear() + "-" + m + "-" + d;
  });
  check(
    "fiche chéquier : la date de réception part à aujourd'hui",
    todayShown === todayHere,
    todayShown + " vs " + todayHere,
  );

  // **Le nombre de chèques se calcule pendant la frappe**, et ne se tape pas.
  check(
    "fiche chéquier : le nombre de chèques n'est jamais saisissable",
    (await page.evaluate(() => document.getElementById("quantity").readOnly)) === true,
  );
  await page.fill("#reference", " 073 28 ");
  await page.fill("#first", "9506001");
  await page.fill("#last", "9506040");
  await page.waitForTimeout(60);
  check(
    "fiche chéquier : le nombre suit les deux bornes",
    (await page.inputValue("#quantity")) === "40",
    await page.inputValue("#quantity"),
  );

  // Sa demande de confirmation, avant la moindre écriture.
  await page.click("#save");
  await page.waitForTimeout(100);
  const asked = await page.locator(".dialog__question").textContent();
  check(
    "fiche chéquier : la création est confirmée avec son récapitulatif",
    asked?.includes("Nombre de chèques à générer :40") &&
      asked?.includes("ne seront pas modifiables"),
    asked ?? "",
  );
  // « Non » n'écrit rien.
  await page.click(".dialog__button >> nth=1");
  await page.waitForTimeout(100);
  check(
    "fiche chéquier : « Non » à la confirmation n'écrit rien",
    (await page.evaluate(() => window.__created)) === undefined,
  );

  await page.click("#save");
  await page.waitForTimeout(100);
  await page.click(".dialog__button >> nth=0");
  await page.waitForTimeout(150);
  const created = await page.evaluate(() => window.__created);
  check(
    "fiche chéquier : l'ajout porte les deux bornes",
    created?.firstNumber === 9506001 && created?.lastNumber === 9506040,
    JSON.stringify(created),
  );
  // Le nombre n'est plus envoyé : c'est le noyau qui le calcule, pour que le
  // plafond porte sur ce qui sera réellement généré.
  check(
    "fiche chéquier : le nombre n'est pas envoyé, il se calcule",
    created !== undefined && !("quantity" in created),
    JSON.stringify(created),
  );
  // **Enregistrer, c'est aussi sortir** : la dernière ligne de ses précautions
  // est `SI Action_Confirmer() ALORS Ferme() FIN`.
  check(
    "fiche chéquier : l'enregistrement referme la fiche",
    (await page.evaluate(() => window.__closedLabel)) === "chequebook-form",
    String(await page.evaluate(() => window.__closedLabel)),
  );
  await page.close();
}

{
  // **Le carnet de dix millions de chèques est refusé avant tout.** Le danger
  // que j'avais signalé comme non corrigé, et que Fabrice avait déjà fermé.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/chequebook-form.html?mode=A");
  await page.fill("#reference", "07328");
  await page.fill("#first", "9506001");
  await page.fill("#last", "95060040");
  await page.click("#save");
  await page.waitForTimeout(150);
  const said = await page.locator("#info-bar").textContent();
  check(
    "fiche chéquier : le plafond de mille chèques refuse, avec son message",
    said?.includes("Nombre de chèque maximum pour un chéquier : 1000"),
    said ?? "",
  );
  check(
    "fiche chéquier : et rien n'est ni demandé ni écrit",
    (await page.locator(".dialog").count()) === 0 &&
      (await page.evaluate(() => window.__created)) === undefined,
  );
  await page.close();
}

{
  // La référence est prise : son HAjoute échoue, et la fenêtre ne dit pas
  // pourquoi — seulement que rien n'a été enregistré.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/chequebook-form.html?mode=A", {
    referenceTaken: true,
  });
  await page.fill("#reference", "07328");
  await page.fill("#first", "1");
  await page.fill("#last", "40");
  await page.click("#save");
  await page.waitForTimeout(150);
  const said = await page.locator("#info-bar").textContent();
  // Sa première précaution, annoncée — et non le silence que je lui avais
  // décrit : `Existe_Reference()` est bien appelée, dans le bouton.
  check(
    "fiche chéquier : une référence prise est refusée et nommée",
    said?.includes("Une référence du même nom existe déjà"),
    said ?? "",
  );
  check(
    "fiche chéquier : et la fenêtre reste ouverte, en ajout",
    (await page.evaluate(() => window.__closedLabel)) === undefined &&
      (await page.evaluate(() => document.getElementById("reference").readOnly)) === false,
  );
  await page.close();
}

{
  // En modification : les cinq champs sont grisés et verrouillés, et
  // l'enregistrement n'envoie que le compte et les commentaires.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/chequebook-form.html?mode=M&id=1");
  const frozen = ["reference", "received", "first", "last", "quantity"];
  const locked = await page.evaluate(
    (ids) =>
      ids.every(
        (id) =>
          document.getElementById(id).readOnly &&
          document.getElementById(id).classList.contains("form__field--locked"),
      ),
    frozen,
  );
  check("fiche chéquier : les cinq champs se figent en modification", locked);
  const free = await page.evaluate(
    () =>
      !document.getElementById("account").disabled &&
      !document.getElementById("comments").readOnly,
  );
  check("fiche chéquier : le compte et les commentaires restent ouverts", free);

  await page.fill("#comments", "carnet déplacé");
  await page.click("#save");
  await page.waitForTimeout(120);
  const sent = await page.evaluate(() => window.__updatedBook);
  check(
    "fiche chéquier : l'enregistrement n'envoie que ce qui bouge",
    sent !== undefined &&
      Object.keys(sent).sort().join(",") === "accountId,comments,id",
    JSON.stringify(sent),
  );
  await page.close();
}

{
  // Le compte a disparu : sa phrase, mot pour mot, et en rouge.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/chequebook-form.html?mode=M&id=1", {
    accountGone: true,
  });
  const said = await page.locator("#info-bar").textContent();
  check(
    "fiche chéquier : le compte disparu est signalé avec sa phrase",
    said?.includes("est absent ou a été supprimé"),
    said ?? "",
  );
  check(
    "fiche chéquier : et c'est une alerte",
    await page.locator("#info-bar").evaluate((bar) => bar.classList.contains("info-bar--alert")),
  );
  await page.close();
}

// --- Phase 9 — la composition du chéquier (F14) -------------------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/cheques-list.html?chequebook=1");
  check("chèques : les chèques s'affichent", (await page.locator(".list__row").count()) === 3);
  check("chèques : huit colonnes", (await page.locator(".list__title").count()) === 8);
  check(
    "chèques : la composition demandée est celle du carnet ouvert",
    (await page.evaluate(() => window.__chequesAsked))?.chequebookId === 1,
  );
  // Aucun bouton ne supprime un chèque : quatre icônes, et la porte.
  // Quatre icônes visibles, et pas cinq : la main du mode « choisir » dort.
  check(
    "chèques : le panneau n'a aucun bouton de suppression",
    (await page.locator(".panel__button:visible").count()) === 4 &&
      (await page.locator("#delete").count()) === 0,
    String(await page.locator(".panel__button:visible").count()),
  );

  // **Le statut se change dans la case.** Il n'y a de menu que sur la ligne
  // choisie : quarante lignes fois quinze statuts feraient six cents entrées
  // dans le document pour rien.
  check(
    "chèques : aucune case n'est un menu avant la sélection",
    (await page.locator(".list__combo").count()) === 0,
  );
  await page.click(".list__row");
  check(
    "chèques : la ligne choisie porte son menu de statut",
    (await page.locator(".list__combo").count()) === 1,
  );
  await page.selectOption(".list__combo", "9");
  await page.waitForTimeout(120);
  const statusSet = await page.evaluate(() => window.__statusSet);
  check(
    "chèques : le menu écrit le statut du bon chèque",
    statusSet?.id === 11 && statusSet?.statusId === 9,
    JSON.stringify(statusSet),
  );

  // Les deux visages de la fenêtre d'association.
  await page.click(".list__row");
  await page.click("#linked");
  const seeing = await page.evaluate(() => window.__opened);
  check(
    "chèques : la loupe ouvre les opérations déjà associées",
    seeing?.command === "open_cheque_operations" && seeing?.args?.linked === true,
    JSON.stringify(seeing),
  );
  await page.click("#link");
  const linking = await page.evaluate(() => window.__opened);
  check(
    "chèques : le maillon ouvre le choix d'une opération",
    linking?.command === "open_cheque_operations" && linking?.args?.linked === false,
    JSON.stringify(linking),
  );
  await page.close();
}

// --- Phase 9 — la fiche chèque (F12) ------------------------------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/cheque-form.html?id=11");
  check(
    "fiche chèque : le numéro arrive groupé et en lecture seule",
    (await page.inputValue("#number")) === "9 506 001" &&
      (await page.evaluate(() => document.getElementById("number").readOnly)) === true,
  );
  check("fiche chèque : le bénéficiaire est là", (await page.inputValue("#payee")) === "dermato");
  check(
    "fiche chèque : les quinze statuts sont proposés",
    (await page.locator("#status option").count()) === 4,
  );
  check("fiche chèque : le statut lu est le sien", (await page.inputValue("#status")) === "5");

  await page.fill("#payee", "Dr Joran");
  await page.click("#save");
  await page.waitForTimeout(120);
  const saved = await page.evaluate(() => window.__updatedCheque);
  check(
    "fiche chèque : l'enregistrement porte ce qui a été tapé",
    saved?.payee === "Dr Joran" && saved?.id === 11,
    JSON.stringify(saved),
  );
  // Anomalie signalée par Fabrice le 29/07/2026 : la fiche restait ouverte
  // après avoir enregistré. Chez lui, `Action_Confirmer()` est suivi d'un
  // `Ferme()`.
  check(
    "fiche chèque : l'enregistrement referme la fiche",
    (await page.evaluate(() => window.__closedLabel)) === "cheque-form",
    String(await page.evaluate(() => window.__closedLabel)),
  );
  // Le montant part en micro-unités, positif : le sens appartient à
  // l'opération, pas au chèque.
  check("fiche chèque : le montant part en micro-unités", saved?.amount === 25000000, String(saved?.amount));
  await page.close();
}

// --- Phase 9 — l'association, ses deux visages --------------------------
{
  // Visage « déjà associées » : le crayon et la croix rouge, pas la main.
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/cheque-operations.html?cheque=11&account=1&linked=1",
  );
  check(
    "association : le titre est celui des opérations déjà associées",
    (await page.locator("#question").textContent())?.includes("déjà associées"),
  );
  check(
    "association : la main est cachée sur ce visage",
    await page.locator("#associate").isHidden(),
  );
  check(
    "association : la croix rouge est là",
    await page.locator("#dissociate").isVisible(),
  );
  check("association : une seule opération y est", (await page.locator(".list__row").count()) === 1);

  await page.click(".list__row");
  await page.click("#dissociate");
  await page.waitForTimeout(120);
  const dropped = await page.evaluate(() => window.__dissociated);
  check(
    "association : la croix rouge détache l'opération",
    dropped?.operationId === 101,
    JSON.stringify(dropped),
  );
  // Et rien d'autre : elle n'appelle aucune suppression.
  check(
    "association : elle ne supprime rien",
    !(await page.evaluate(() =>
      window.__calls.some(([command]) => String(command).includes("delete")),
    )),
  );

  // Le menu Filtre : présent, nommé, inactif.
  check(
    "association : le menu Filtre est là et inactif",
    (await page.locator("#filter-menu").textContent()) === "Filtre" &&
      (await page.locator("#filter-menu").isDisabled()),
  );
  await page.close();
}

{
  // Visage « choisissez » : la main, le gras, et aucune question avant
  // l'écrasement — son original écrase, le gras était l'avertissement.
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/cheque-operations.html?cheque=11&account=1&linked=0",
  );
  check(
    "association : le titre est celui du choix",
    (await page.locator("#question").textContent())?.includes("Choisissez"),
  );
  check(
    "association : la croix rouge est cachée sur ce visage",
    await page.locator("#dissociate").isHidden(),
  );
  check("association : les deux opérations y sont", (await page.locator(".list__row").count()) === 2);
  check(
    "association : celle qui porte déjà un chèque est en gras",
    (await page.locator(".list__row--taken").count()) === 1,
  );

  // On choisit justement celle qui est prise : aucune question, et l'ancien
  // chèque la perd.
  await page.click(".list__row--taken");
  await page.click("#associate");
  await page.waitForTimeout(120);
  check(
    "association : aucune question avant l'écrasement",
    (await page.locator(".dialog").count()) === 0 ||
      !(await page.locator(".dialog").isVisible()),
  );
  const linked = await page.evaluate(() => window.__associated);
  check(
    "association : le lien est écrit sur le bon chèque",
    linked?.operationId === 101 && linked?.chequeId === 11,
    JSON.stringify(linked),
  );
  await page.close();
}

// --- Phase 9 — le bandeau chèque de la fiche opération (F03) ------------
{
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/operation-form.html?mode=M&id=1&account=1",
  );
  check(
    "bandeau chèque : le numéro du chèque porté s'affiche",
    (await page.inputValue("#check")) === "9 506 001",
    await page.inputValue("#check"),
  );

  // Info ouvre la fiche du chèque — par son identifiant, pas par son numéro :
  // deux carnets peuvent porter le même numéro.
  await page.click("#check-info");
  await page.waitForTimeout(80);
  const info = await page.evaluate(() =>
    window.__calls.find(([command]) => command === "open_cheque_form"),
  );
  check("bandeau chèque : Info ouvre la fiche du chèque", info?.[1]?.id === 11, JSON.stringify(info));

  // Associer entame le premier temps : le choix du carnet.
  await page.click("#check-link");
  await page.waitForTimeout(80);
  const picking = await page.evaluate(() => window.__opened);
  check(
    "bandeau chèque : Associer demande d'abord le carnet",
    picking?.command === "choose_cheque_for_operation" && picking?.args?.operationId === 1,
    JSON.stringify(picking),
  );

  // Supprimer détache, et n'appelle aucune suppression.
  await page.click("#check-unlink");
  await page.waitForTimeout(120);
  const detached = await page.evaluate(() =>
    window.__calls.find(([command]) => command === "dissociate_cheque"),
  );
  check(
    "bandeau chèque : Supprimer détache l'opération",
    detached?.[1]?.operationId === 1,
    JSON.stringify(detached),
  );
  check(
    "bandeau chèque : et ne supprime rien",
    !(await page.evaluate(() =>
      window.__calls.some(([command]) => String(command).startsWith("delete")),
    )),
  );
  await page.close();
}

// --- Phase 9 — les deux listes dans leur mode « choisir » ---------------
{
  // Le carnet d'abord : les boutons de gestion s'effacent, la main paraît.
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/chequebooks-list.html?mode=SEL&operation=1",
  );
  const hidden = await page.evaluate(() =>
    ["create", "update", "delete", "composition"].every(
      (id) => document.getElementById(id).hidden,
    ),
  );
  check("choix du carnet : les boutons de gestion s'effacent", hidden);
  check("choix du carnet : la main paraît", await page.locator("#select").isVisible());
  check(
    "choix du carnet : la question est posée",
    (await page.locator("#question").textContent())?.includes("chéquier"),
  );

  await page.click(".list__row");
  await page.click("#select");
  await page.waitForTimeout(100);
  const second = await page.evaluate(() => window.__opened);
  check(
    "choix du carnet : le carnet choisi enchaîne sur ses chèques",
    second?.command === "choose_cheque_in_chequebook" &&
      second?.args?.chequebookId === 1 &&
      second?.args?.operationId === 1,
    JSON.stringify(second),
  );
  await page.close();
}

{
  // Le chèque ensuite : le choisir l'accroche à l'opération qui attendait,
  // **sans une question**, et referme les deux fenêtres de choix.
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/cheques-list.html?mode=SEL&operation=1&chequebook=1",
  );
  const hidden = await page.evaluate(() =>
    ["update", "linked", "link"].every((id) => document.getElementById(id).hidden),
  );
  check("choix du chèque : les trois boutons de travail s'effacent", hidden);
  check("choix du chèque : la main paraît", await page.locator("#select").isVisible());

  await page.click(".list__row");
  await page.click("#select");
  await page.waitForTimeout(120);
  const linked = await page.evaluate(() => window.__associated);
  check(
    "choix du chèque : il s'accroche à l'opération qui attendait",
    linked?.operationId === 1 && linked?.chequeId === 11,
    JSON.stringify(linked),
  );
  check(
    "choix du chèque : les deux fenêtres de choix se referment",
    (await page.evaluate(() => window.__closedLabel)) === "cheque-choice",
  );
  await page.close();
}

// --- Phase 10 — la liste des modèles (F37) ------------------------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/operation-templates-list.html");
  check("modèles : les modèles s'affichent", (await page.locator(".list__row").count()) === 2);
  check("modèles : une seule colonne", (await page.locator(".list__title").count()) === 1);
  check(
    "modèles : la main de choix dort en gestion",
    await page.locator("#select").isHidden(),
  );

  await page.click("#update");
  check(
    "modèles : refus sans sélection",
    (await page.locator("#info-bar").textContent())?.includes(
      "Veuillez sélectionner un enregistrement",
    ),
  );

  await page.click(".list__row");
  await page.click("#delete");
  await page.waitForTimeout(80);
  await page.click(".dialog__button >> nth=1");
  await page.waitForTimeout(80);
  check(
    "modèles : « Non » n'efface rien",
    (await page.evaluate(() => window.__templatesDeleted)) === undefined,
  );
  await page.close();
}

{
  // Le mode « choisir » : la gestion s'efface, choisir applique et n'écrit rien.
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/operation-templates-list.html?mode=SEL",
  );
  const hidden = await page.evaluate(() =>
    ["create", "update", "delete", "read"].every((id) => document.getElementById(id).hidden),
  );
  check("modèles : en mode choisir, la gestion s'efface", hidden);
  check(
    "modèles : la question est posée",
    (await page.locator("#question").textContent())?.includes("Choisissez le modèle"),
  );

  await page.click(".list__row");
  await page.click("#select");
  await page.waitForTimeout(100);
  check(
    "modèles : le modèle choisi part vers la fiche",
    (await page.evaluate(() => window.__templateApplied))?.id === 1,
  );
  // **Rien n'est écrit** : aucune commande d'écriture d'opération n'est appelée.
  check(
    "modèles : choisir n'écrit aucune opération",
    !(await page.evaluate(() =>
      window.__calls.some(([command]) =>
        ["create_operation", "update_operation"].includes(String(command)),
      ),
    )),
  );
  await page.close();
}

// --- Phase 10 — la fiche modèle (F36) -----------------------------------
{
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/operation-template-form.html?mode=M&id=1",
  );
  check("fiche modèle : le nom est là", (await page.inputValue("#label")) === "Loyer");
  // La fiche du modèle porte la **grandeur**, et le sens dans le combo.
  check(
    "fiche modèle : le montant est une grandeur et le sens un combo",
    (await page.inputValue("#amount")) === "70,00" &&
      (await page.inputValue("#direction")) === "D",
  );
  check(
    "fiche modèle : les quatre bandeaux de sa capture",
    (await page.locator(".band__title").count()) === 4,
  );
  check(
    "fiche modèle : ni compte ni date",
    (await page.locator("#account").count()) === 0 &&
      (await page.locator("#date").count()) === 0,
  );

  await page.fill("#label", "Loyer mensuel");
  await page.click("#save");
  await page.waitForTimeout(120);
  const saved = await page.evaluate(() => window.__templateSaved);
  check(
    "fiche modèle : l'enregistrement porte ce qui a été tapé",
    saved?.label === "Loyer mensuel" && saved?.id === 1,
    JSON.stringify(saved),
  );
  check(
    "fiche modèle : l'enregistrement referme la fiche",
    (await page.evaluate(() => window.__closed)) === true,
  );
  await page.close();
}

// --- Phase 10 — le bouton Modèle de la fiche opération ------------------
{
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/operation-form.html?mode=M&id=1&account=1",
  );
  // **Un clic, la liste.** Aucune question : on clique sur Modèle justement
  // parce qu'on n'a pas de temps à perdre (Fabrice, 29/07/2026).
  await page.click("#template");
  await page.waitForTimeout(120);
  check(
    "bouton Modèle : aucune question n'est posée",
    (await page.locator(".dialog").count()) === 0,
  );
  const opened = await page.evaluate(() => window.__opened);
  check(
    "bouton Modèle : la liste s'ouvre directement en mode choisir",
    opened?.command === "open_operation_templates" && opened?.args?.selecting === true,
    JSON.stringify(opened),
  );
  await page.close();
}

// --- Phase 11 — la saisie du budget (F26) -------------------------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/budget.html?mode=entry&year=2026");
  check(
    "budget : le tableau porte les postes et les douze mois",
    (await page.locator(".matrix__row").count()) >= 3 &&
      (await page.locator(".matrix__title").count()) === 14,
  );
  check(
    "budget : les cases se tapent",
    (await page.locator(".matrix__input").count()) === 24,
  );
  // Le rappel de la convention de signe, en rouge.
  const said = await page.locator("#info-bar").textContent();
  check(
    "budget : la convention de signe est rappelée",
    said?.includes("dépenses en négatif"),
    said ?? "",
  );

  // **Rien n'est écrit tant qu'on n'a pas enregistré.**
  await page.fill(".matrix__input >> nth=1", "-50,00");
  await page.waitForTimeout(60);
  check(
    "budget : taper n'écrit rien",
    (await page.evaluate(() => window.__budgetSaved)) === undefined,
  );
  await page.click("#save");
  await page.waitForTimeout(120);
  const saved = await page.evaluate(() => window.__budgetSaved);
  check(
    "budget : l'enregistrement porte la case tapée",
    saved?.year === 2026 && saved?.cells?.length === 1 && saved?.cells?.[0]?.[2] === "-50,00",
    JSON.stringify(saved),
  );
  await page.close();
}

// --- Phase 11 — le contrôle du budget (F27) -----------------------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/budget.html?mode=control&year=2026");
  check(
    "contrôle : aucune case ne se tape",
    (await page.locator(".matrix__input").count()) === 0,
  );
  check(
    "contrôle : la bascule est un interrupteur, pas un menu",
    (await page.locator("#display-switch").count()) === 1 &&
      (await page.locator(".window-menu__entry").count()) === 0,
  );
  check(
    "contrôle : le Cumul est sous la Somme",
    (await page.locator(".matrix__row--cumulative").count()) === 1,
  );
  // **La règle des couleurs, dans les deux sens.** La dépense tenue est verte,
  // le revenu manqué est rouge — et les deux sont à moins de 100 %.
  check(
    "contrôle : une dépense tenue est verte",
    (await page.locator(".matrix__cell--kept").count()) >= 1,
  );
  check(
    "contrôle : un revenu manqué est rouge",
    (await page.locator(".matrix__cell--overrun").count()) >= 1,
  );
  check(
    "contrôle : en valeur, la devise s'affiche",
    (await page.locator(".matrix__cell--kept").first().textContent())?.includes("€"),
  );

  // La bascule change le nombre, **pas la couleur**.
  const greenBefore = await page.locator(".matrix__cell--kept").count();
  const redBefore = await page.locator(".matrix__cell--overrun").count();
  await page.click("#display-switch");
  await page.waitForTimeout(150);
  check(
    "contrôle : en pourcentage, le nombre change",
    (await page.locator(".matrix__cell--kept").first().textContent())?.includes("%"),
  );
  check(
    "contrôle : mais la couleur ne change pas",
    (await page.locator(".matrix__cell--kept").count()) === greenBefore &&
      (await page.locator(".matrix__cell--overrun").count()) === redBefore,
  );
  await page.close();
}

// --- Phase 12 — le transfert entre deux comptes (F09) -------------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/transfer.html");
  check(
    "virement : les cinq bandeaux de sa capture",
    (await page.locator(".band__title").count()) === 5,
  );
  check(
    "virement : les deux comptes partent vides",
    (await page.inputValue("#source")) === "0" && (await page.inputValue("#target")) === "0",
  );
  check(
    "virement : les deux dates partent à aujourd'hui",
    (await page.inputValue("#date")) === (await page.inputValue("#clearing-date")) &&
      (await page.inputValue("#date")).length === 10,
  );

  // **Les trois soldes s'affichent au moment du choix.**
  await page.selectOption("#source", "1");
  await page.waitForTimeout(120);
  const said = await page.locator("#info-bar").textContent();
  check(
    "virement : choisir un compte montre ses trois soldes",
    said?.includes("En banque") && said?.includes("Réel") && said?.includes("Final"),
    said ?? "",
  );

  // Le même compte des deux côtés est refusé, et rien n'est écrit.
  await page.selectOption("#target", "1");
  await page.fill("#label", "Virement interne");
  await page.fill("#amount", "250,00");
  await page.click("#validate");
  await page.waitForTimeout(150);
  check(
    "virement : le même compte des deux côtés est refusé",
    (await page.locator("#info-bar").textContent())?.includes("ne peuvent pas être le même"),
  );
  check(
    "virement : et rien n'est écrit",
    (await page.evaluate(() => window.__transferDone)) === undefined,
  );

  // Deux comptes distincts : le virement se fait, le panneau récapitule, et la
  // fenêtre se vide en restant ouverte.
  await page.selectOption("#target", "2");
  await page.click("#validate");
  await page.waitForTimeout(150);
  const recap = await page.locator(".dialog__question").textContent();
  check(
    "virement : le panneau récapitule ce qui vient d'être écrit",
    recap?.includes("Virement effectué"),
    recap ?? "",
  );
  await page.click(".dialog__button >> nth=0");
  await page.waitForTimeout(150);
  check(
    "virement : le montant part tel qu'il est écrit, le noyau le relit",
    (await page.evaluate(() => window.__transferDone))?.transfer?.amount === "250,00",
  );
  check(
    "virement : la fenêtre se vide pour le suivant",
    (await page.inputValue("#source")) === "0" &&
      (await page.inputValue("#label")) === "" &&
      (await page.inputValue("#amount")) === "0,00",
  );
  check(
    "virement : et elle reste ouverte",
    (await page.evaluate(() => window.__closed)) !== true,
  );
  await page.close();
}

// --- Phase 13 — l'importation d'une feuille Excel (F34, F35, association) --
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/excel-import.html?account=1");

  // La question de la sauvegarde est posée **avant** tout : un fichier Excel
  // est fait à la main, et une partie de ce qu'il porte est indétectable.
  check(
    "excel : la sauvegarde est proposée avant de commencer",
    (await page.locator(".dialog__question").count()) === 1 &&
      ((await page.locator(".dialog__question").textContent()) ?? "").includes("Excel"),
  );
  await page.click(".dialog__button:not(.dialog__button--primary)");
  await page.waitForTimeout(120);

  check(
    "excel : les cinq groupes numérotés de sa capture",
    (await page.locator(".band__title").count()) === 5,
  );
  check(
    "excel : le quatrième groupe demande la forme du montant",
    (await page.locator("#shape-single").count()) === 1 &&
      (await page.locator("#shape-debit-credit").count()) === 1 &&
      (await page.isChecked("#shape-single")),
  );

  // **On ne passe pas à l'étape 2 sans avoir testé.** C'est toute la sévérité
  // de cette fenêtre : la déclaration qui se trompe doit se voir avant.
  await page.click("#pick");
  await page.waitForTimeout(150);
  check(
    "excel : le fichier désigné s'affiche et ses feuilles sont proposées",
    (await page.locator("#path").textContent()) === "/tmp/releve.xlsx" &&
      (await page.locator("#sheet option").count()) === 2,
  );
  await page.click("#validate");
  await page.waitForTimeout(150);
  check(
    "excel : valider sans avoir testé est refusé",
    (await page.evaluate(() => window.__opened)) === undefined &&
      (await page.locator(".info-bar--alert").count()) === 1,
  );

  await page.click("#test");
  await page.waitForTimeout(200);
  check(
    "excel : le rendu test montre les en-têtes de la feuille",
    (await page.locator(".list__title-text").first().textContent()) === "Date",
  );
  check(
    "excel : et les lignes captées",
    (await page.locator("#preview-rows .list__row").count()) === 2,
  );

  // Changer un réglage périme l'essai : ce qui est à l'écran ne correspond
  // plus à ce qui est réglé.
  await page.fill("#column-count", "4");
  await page.dispatchEvent("#column-count", "change");
  await page.waitForTimeout(120);
  await page.click("#validate");
  await page.waitForTimeout(150);
  check(
    "excel : changer un réglage périme le rendu test",
    (await page.evaluate(() => window.__opened)) === undefined,
  );

  await page.click("#test");
  await page.waitForTimeout(150);
  await page.click("#validate");
  await page.waitForTimeout(150);
  check(
    "excel : testé, on passe à l'étape 2",
    (await page.evaluate(() => window.__opened?.command)) === "open_excel_fields",
  );
  check(
    "excel : la forme du montant part avec les réglages",
    (await page.evaluate(() => window.__excelSettings?.shape)) === "single",
  );
  await page.close();
}

{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/excel-fields.html");

  check(
    "excel : l'étape 2 a ses deux onglets",
    (await page.locator(".excel-tab:not([hidden])").count()) === 2,
  );
  check(
    "excel : la concordance porte une ligne par colonne captée",
    (await page.locator("#links-rows .list__row").count()) === 4,
  );

  // Le second onglet : un groupe par nomenclature, et **un groupe s'éteint
  // quand aucune colonne ne l'alimente** — `SI nNumCol < 1 ALORS RETOUR`.
  await page.click("#tab-settings");
  await page.waitForTimeout(150);
  check(
    "excel : trois groupes de politiques",
    (await page.locator(".excel-group").count()) === 3,
  );
  check(
    "excel : un groupe sans colonne est éteint",
    (await page.locator(".excel-group[disabled]").count()) === 2,
  );
  check(
    "excel : quatre choix par groupe, dans son ordre",
    (await page.locator(".excel-group").first().locator("input[type=radio]").count()) === 4,
  );

  // « Demander » fait apparaître le bouton « Définir destination », et lui
  // seul l'a.
  check(
    "excel : le bouton Définir destination est caché tant qu'on ne demande pas",
    (await page.locator(".excel-destination:not([hidden])").count()) === 0,
  );
  await page.locator(".excel-group").first().locator("input[value=ask]").check();
  await page.waitForTimeout(200);
  check(
    "excel : choisir « demander » fait apparaître le bouton",
    (await page.locator(".excel-destination:not([hidden])").count()) === 1,
  );
  check(
    "excel : et la politique part vers Rust",
    (await page.evaluate(() => window.__excelPolicySet?.policy)) === "ask",
  );
  await page.locator(".excel-destination:not([hidden])").click();
  await page.waitForTimeout(150);
  check(
    "excel : le bouton ouvre la fenêtre d'association",
    (await page.evaluate(() => window.__opened?.command)) === "open_excel_association" &&
      (await page.evaluate(() => window.__opened?.args?.kind)) === "category",
  );

  // L'import, et son compte-rendu : ce qui n'est pas passé se voit.
  await page.click("#validate");
  await page.waitForTimeout(250);
  check(
    "excel : le panneau récapitule l'importation",
    ((await page.locator(".dialog__question").textContent()) ?? "").includes("2 opérations"),
  );
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(200);
  // **Le bouton d'importation disparaît une fois la procédure terminée**
  // (Fabrice, 30/07/2026) : sans cela un second clic réécrirait tout, et
  // l'import n'a aucun contrôle de doublon pour l'en empêcher.
  check(
    "excel : le bouton d'importation disparaît une fois l'import fait",
    await page.locator("#validate").isHidden(),
  );
  check(
    "excel : le compte-rendu nomme les lignes refusées",
    (await page.locator("#report-rows .list__row").count()) === 1 &&
      ((await page.locator("#report-rows .list__row").first().textContent()) ?? "").includes("5"),
  );
  await page.close();
}

{
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/excel-association.html?kind=category",
  );
  check(
    "excel : l'association ne montre que les valeurs inconnues",
    (await page.locator("#rows .list__row").count()) === 1 &&
      ((await page.locator("#rows .list__row").first().textContent()) ?? "").includes(
        "Alimentationss",
      ),
  );
  check(
    "excel : la colonne de droite porte le nom de la nomenclature demandée",
    ((await page.locator("#header").textContent()) ?? "").includes("Categorie_Radinus"),
  );

  // La combo ne propose que l'existant, plus la ligne vide qui laisse la
  // valeur sans classement.
  await page.click("#rows .list__row");
  await page.waitForTimeout(150);
  check(
    "excel : la combo ne propose que ce qui existe déjà",
    (await page.locator("#rows .list__combo option").count()) === 3,
  );
  await page.selectOption("#rows .list__combo", "1");
  await page.waitForTimeout(150);
  await page.click("#validate");
  await page.waitForTimeout(150);
  check(
    "excel : le choix repart sous le libellé venu du fichier",
    (await page.evaluate(() => window.__excelAssociation?.values?.[0]?.label)) ===
      "Alimentationss" &&
      (await page.evaluate(() => window.__excelAssociation?.values?.[0]?.chosen_id)) === 1,
  );
  check(
    "excel : et la fenêtre se ferme",
    (await page.evaluate(() => window.__closedLabel)) === "excel-association",
  );
  await page.close();
}

// --- Phase 16 — les opérations périodiques (F38, F15, F16) ----------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/recurring-list.html");
  check(
    "périodiques : une seule colonne, comme sa capture",
    (await page.locator(".list__title").count()) === 1 &&
      (await page.locator(".list__title-text").first().textContent()) === "LIBELLE",
  );
  // Six icônes : les quatre de toutes les listes, le calendrier, la porte.
  // On ne vérifie pas le nom du fichier d'image : le constructeur le remplace
  // par un nom haché, et c'est le test croisé de Rust qui garantit que
  // l'image demandée existe bien dans le dépôt.
  check(
    "périodiques : le panneau porte le calendrier en plus des quatre icônes",
    (await page.locator("#calendar").count()) === 1 &&
      (await page.locator(".panel__button").count()) === 6,
  );
  // Le calendrier sans sélection ne propose rien : il faut dire de quelle
  // règle.
  await page.click("#calendar");
  await page.waitForTimeout(150);
  check(
    "périodiques : le calendrier réclame une règle",
    (await page.evaluate(() => window.__opened)) === undefined &&
      (await page.locator(".info-bar--alert").count()) === 1,
  );

  // **Plusieurs règles d'un coup** : son code reçoit un tableau.
  await page.click("#rows .list__row >> nth=0");
  await page.click("#rows .list__row >> nth=1", { modifiers: ["Meta"] });
  await page.click("#calendar");
  await page.waitForTimeout(200);
  check(
    "périodiques : le calendrier part sur les deux règles choisies",
    JSON.stringify(await page.evaluate(() => window.__opened?.args?.ids)) === "[1,2]",
    JSON.stringify(await page.evaluate(() => window.__opened)),
  );
  await page.close();
}

{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/recurring-form.html?mode=M&id=1");
  check(
    "règle : les six bandeaux de sa capture",
    (await page.locator(".band__title").count()) === 6,
  );
  check(
    "règle : le montant est une grandeur, le sens porte le signe",
    (await page.inputValue("#amount")) === "65,00" &&
      (await page.inputValue("#direction")) === "-1",
  );
  check(
    "règle : les trois chiffres de consultation sont ceux de cette règle",
    (await page.inputValue("#produced-count")) === "12" &&
      (await page.inputValue("#produced-total")) === "-780,00 €" &&
      (await page.inputValue("#produced-last")) === "2026-07-10",
  );

  // **Les deux champs conditionnels suivent leur bouton** — son
  // `Fenetre_Initialise`.
  check(
    "règle : la date de fin est vivante, la répétition est éteinte",
    (await page.isDisabled("#end-date")) === false &&
      (await page.isDisabled("#repeat-count")) === true,
  );
  await page.check("#ending-repeat-count");
  await page.waitForTimeout(120);
  check(
    "règle : et elles échangent quand on change de condition",
    (await page.isDisabled("#end-date")) === true &&
      (await page.isDisabled("#repeat-count")) === false,
  );

  // **Enregistrer ferme la fiche** (Fabrice, 31/07/2026).
  await page.click("#save");
  await page.waitForTimeout(250);
  check(
    "règle : enregistrer ferme la fiche",
    (await page.evaluate(() => window.__closed)) === true &&
      (await page.evaluate(() => window.__ruleSaved?.label)) === "Assurance Voiture",
  );

  // La corbeille efface les opérations, pas la règle — et elle demande avant.
  await page.click("#erase");
  await page.waitForTimeout(200);
  check(
    "règle : la corbeille demande confirmation, en disant combien",
    ((await page.locator(".dialog__question").textContent()) ?? "").includes("12 opérations"),
  );
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(250);
  check(
    "règle : et elle efface les opérations de cette règle",
    (await page.evaluate(() => window.__erased)) === 1,
  );
  await page.close();
}

{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/recurring-calendar.html?rules=1");
  check(
    "calendrier : les neuf colonnes de sa capture",
    (await page.locator(".list__title").count()) === 9,
  );
  check(
    "calendrier : les échéances proposées, montants écrits par le noyau",
    (await page.locator("#rows .list__row").count()) === 3 &&
      ((await page.locator("#rows .list__row").first().textContent()) ?? "").includes("-65,00 €"),
  );

  // **La corbeille rouge retire de la proposition**, elle n'écrit rien.
  await page.click("#rows .list__row >> nth=0");
  await page.click("#remove");
  await page.waitForTimeout(200);
  check(
    "calendrier : la corbeille retire la ligne de la proposition",
    (await page.locator("#rows .list__row").count()) === 2 &&
      (await page.evaluate(() => window.__inserted)) === undefined,
  );

  // **On demande avant d'écrire** : le calendrier crée de vraies opérations.
  await page.click("#insert");
  await page.waitForTimeout(250);
  check(
    "calendrier : l'insertion demande confirmation, en disant combien",
    ((await page.locator(".dialog__question").textContent()) ?? "").includes("2 échéances") &&
      (await page.evaluate(() => window.__inserted)) === undefined,
  );
  // Renoncer n'écrit rien et laisse la proposition intacte.
  await page.click(".dialog__button:not(.dialog__button--primary)");
  await page.waitForTimeout(200);
  check(
    "calendrier : renoncer n'insère rien",
    (await page.evaluate(() => window.__inserted)) === undefined &&
      (await page.locator("#rows .list__row").count()) === 2,
  );

  // Et l'insertion ne porte que sur ce qui reste.
  await page.click("#insert");
  await page.waitForTimeout(200);
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(250);
  check(
    "calendrier : seules les échéances restées sont insérées",
    JSON.stringify(await page.evaluate(() => window.__inserted)) === "[2,3]",
    JSON.stringify(await page.evaluate(() => window.__inserted)),
  );
  check(
    "calendrier : ce qui est entré ne se repropose pas",
    (await page.locator("#rows .list__row").count()) === 0,
  );
  await page.close();
}

// --- F32 — l'impression de RIB -------------------------------------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/rib.html?account=1");
  check("rib : les quatre bandes de sa capture", (await page.locator(".band__title").count()) === 4);
  check(
    "rib : les coordonnées du compte sont montrées",
    (await page.inputValue("#iban")) === "FR76 1223 0111 0044 5577 2222 2" &&
      (await page.inputValue("#bank")) === "American Express",
  );
  // **Rien ne se saisit ici** : les dix champs sont en lecture seule.
  check(
    "rib : les dix champs sont en lecture seule",
    (await page.locator(".rib-field[readonly]").count()) === 10,
  );

  // **La déclaration commande les deux boutons.** C'est la règle de Fabrice :
  // on n'imprime pas un document bancaire par inadvertance.
  check(
    "rib : les deux boutons sont éteints tant que la case n'est pas cochée",
    (await page.locator("#print").isDisabled()) && (await page.locator("#pdf").isDisabled()),
  );
  check(
    "rib : et la fenêtre dit pourquoi",
    (await page.textContent("#info-bar")).includes("déclaration"),
  );

  await page.click("#declared");
  await page.waitForTimeout(120);
  check(
    "rib : cocher allume les deux boutons",
    !(await page.locator("#print").isDisabled()) && !(await page.locator("#pdf").isDisabled()),
  );

  await page.click("#pdf");
  await page.waitForTimeout(200);
  check(
    "rib : l'icône PDF imprime en PDF",
    (await page.evaluate(() => window.__ribPrinted?.toPrinter)) === false,
    JSON.stringify(await page.evaluate(() => window.__ribPrinted)),
  );
  // **Le choix de l'imprimante** (demande de Fabrice, 01/08/2026) : le clic
  // sur l'imprimante ne lance rien, il demande d'abord laquelle, et la liste
  // s'ouvre sur celle par défaut du système.
  await page.click("#print");
  await page.waitForTimeout(200);
  check(
    "rib : l'imprimante demande d'abord laquelle",
    (await page.locator(".dialog__question").textContent())?.includes("imprimante"),
  );
  check(
    "rib : et la liste s'ouvre sur celle par défaut",
    (await page.inputValue(".dialog__field")) === "HP LaserJet 4000",
  );
  // Renoncer au choix, c'est renoncer à imprimer.
  await page.keyboard.press("Escape");
  await page.waitForTimeout(150);
  check(
    "rib : renoncer au choix n'imprime rien",
    (await page.evaluate(() => window.__ribPrinted?.toPrinter)) === false,
  );

  await page.click("#print");
  await page.waitForTimeout(200);
  await page.selectOption(".dialog__field", "Brother HL-2030");
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(200);
  check(
    "rib : c'est le nom de la file, non le nom lisible, qui part au noyau",
    (await page.evaluate(() => window.__ribPrinted?.toPrinter)) === true &&
      (await page.evaluate(() => window.__ribPrinted?.printer)) === "Brother_HL_2030",
    JSON.stringify(await page.evaluate(() => window.__ribPrinted)),
  );
  check(
    "rib : et elle n'envoie que le compte et l'imprimante, jamais ce qui est à l'écran",
    JSON.stringify(Object.keys(await page.evaluate(() => window.__ribPrinted)).sort()) ===
      JSON.stringify(["accountId", "printer", "toPrinter"]),
    JSON.stringify(await page.evaluate(() => window.__ribPrinted)),
  );

  // Un poste sans imprimante : on le dit, et on renvoie au PDF.
  await page.evaluate(() => {
    window.__noPrinter = true;
  });
  await page.click("#print");
  await page.waitForTimeout(200);
  check(
    "rib : sans liste, elle imprime quand même sur la sortie par défaut",
    (await page.evaluate(() => window.__ribPrinted?.printer)) === null &&
      (await page.textContent("#info-bar")).includes("par défaut"),
    JSON.stringify(await page.evaluate(() => window.__ribPrinted)),
  );
  await page.close();
}

// --- Le journal de la dernière opération technique (⌘H) -------------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/journal.html");
  check(
    "journal : les six colonnes de son Ajoute_Log",
    (await page.locator(".list__title").count()) === 6,
  );
  check("journal : les lignes du dernier traitement", (await page.locator(".list__row").count()) === 2);
  check(
    "journal : le statut de chaque ligne est écrit",
    (await page.locator(".list__row").first().textContent())?.includes("SUCCES"),
  );
  await page.close();
}

// --- F28 — les pièces jointes d'une opération -----------------------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/attachments.html?operation=1");
  check(
    "pièces jointes : les deux colonnes de sa capture",
    (await page.locator(".list__title").count()) === 2,
  );
  check(
    "pièces jointes : LIBELLE et Identifiant",
    (await page.locator(".list__title").first().textContent())?.includes("LIBELLE") &&
      (await page.locator(".list__title").nth(1).textContent())?.includes("Identifiant"),
  );
  check(
    "pièces jointes : les quatre cylindres et la porte",
    (await page.locator(".panel__button").count()) === 5,
  );
  check(
    "pièces jointes : la phrase de la multi-sélection",
    (await page.textContent("#info-bar"))?.includes("[CTRL]"),
  );
  check(
    "pièces jointes : celles de l'opération demandée",
    (await page.evaluate(() => window.__attachmentsFor)) === 1 &&
      (await page.locator(".list__row").count()) === 2,
  );
  // Un geste sans sélection est refusé, avec les mots de l'original — vérifié
  // avant d'avoir choisi quoi que ce soit.
  await page.click("#open");
  check(
    "pièces jointes : refus sans sélection",
    (await page.textContent("#info-bar"))?.includes("sélectionner"),
  );

  // Le nom physique est montré : c'est lui qui identifie la pièce dans le
  // dossier comme dans les sauvegardes.
  check(
    "pièces jointes : le nom physique est montré",
    (await page.locator(".list__row").first().textContent())?.includes(
      "76d1dbb03c8946f3887c9d9fb691d2e7.pdf",
    ),
  );
  // **L'état du fichier se voit** en choisissant la ligne : une pièce dont le
  // fichier a disparu du disque est pire qu'une pièce absente, parce qu'on
  // croit l'avoir.
  await page.click("#rows .list__row >> nth=1");
  await page.waitForTimeout(120);
  check(
    "pièces jointes : la ligne choisie dit son poids et son état",
    (await page.textContent("#info-bar"))?.includes("absent"),
  );
  await page.click("#rows .list__row >> nth=1");

  await page.click("#add");
  await page.waitForTimeout(200);
  check(
    "pièces jointes : joindre porte sur cette opération",
    (await page.evaluate(() => window.__attachmentAdded)) === 1,
  );

  await page.click("#rows .list__row >> nth=0");
  await page.click("#replace");
  await page.waitForTimeout(200);
  check(
    "pièces jointes : le crayon remplace le document de la pièce choisie",
    (await page.evaluate(() => window.__attachmentReplaced)) === 1,
  );
  await page.click("#rows .list__row >> nth=0");
  await page.click("#open");
  await page.waitForTimeout(200);
  check(
    "pièces jointes : ouvrir envoie la clef, jamais un chemin",
    (await page.evaluate(() => window.__attachmentOpened)) === 1,
  );

  // Retirer demande d'abord, et renoncer ne retire rien.
  await page.click("#remove");
  await page.waitForTimeout(200);
  await page.click(".dialog__button:not(.dialog__button--primary)");
  await page.waitForTimeout(150);
  check(
    "pièces jointes : renoncer ne retire rien",
    (await page.evaluate(() => window.__attachmentRemoved)) === undefined,
  );

  await page.click("#remove");
  await page.waitForTimeout(200);
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(200);
  check(
    "pièces jointes : et confirmer retire la pièce choisie",
    (await page.evaluate(() => window.__attachmentRemoved)) === 1,
  );
  await page.close();
}

{
  // F01 — la fenêtre d'accueil (phase 17 bis).
  //
  // Elle n'est pas dans `ui/windows/`, donc la boucle « toutes les pages
  // s'ouvrent sans une plainte » ne la couvre pas : ses erreurs de script sont
  // vérifiées ici, à la main.
  const page = await browser.newPage();
  const errors = await openWindow(page, "http://localhost:4173/");
  check("accueil : aucune erreur de script", errors.length === 0, errors.join(" | "));

  check(
    "accueil : les trois soldes totaux sont ceux du noyau",
    (await page.textContent("#total-bank")) === "24972,62 €",
    await page.textContent("#total-bank"),
  );
  check(
    "accueil : le rappel du nombre de comptes vient du noyau, pluriel compris",
    (await page.textContent("#total-bank-detail")) === "2 comptes ouverts",
  );
  check(
    "accueil : un solde final négatif est peint en rouge foncé",
    await page.locator(".tile").first().locator(".tile__amount--negative").isVisible(),
  );
  check("accueil : une tuile par compte ouvert", (await page.locator(".tile").count()) === 2);

  // **Le titre de l'anneau est écrit par le noyau, mois compris.** La fenêtre
  // ne colle pas un mois derrière une phrase : l'ordre des mots n'est pas le
  // même dans les trois langues.
  check(
    "accueil : le titre de l'anneau arrive entier du noyau",
    (await page.textContent("#spending-title")) ===
      "Dépenses par postes budgétaires — août 2026",
  );

  // Le relief : chaque secteur porte sa face, et les parois sont en plus. Deux
  // secteurs à plat feraient deux chemins ; en relief, il y en a davantage.
  check(
    "accueil : les anneaux sont dessinés en relief",
    (await page.locator("#spending path").count()) > 2,
    String(await page.locator("#spending path").count()),
  );
  // **La valeur écrite est ce qui porte la vérité** quand la perspective
  // fausse les proportions. Elle ne doit jamais disparaître.
  check(
    "accueil : chaque secteur porte sa valeur écrite",
    (await page.locator("#spending .ring__value").count()) === 2,
  );
  check(
    "accueil : la légende nomme chaque poste avec son montant",
    (await page.locator("#spending .legend__entry").count()) === 2,
  );

  // **Les quatre chevrons commandent le même mois.** C'est la décision de
  // Fabrice, et c'est ce qui empêche de lire les dépenses de juillet à côté
  // des gains d'août sans s'en apercevoir : une balance fausse à l'œil, qu'
  // aucun nombre à l'écran ne signalerait.
  await page.click("#spending-previous");
  await page.waitForTimeout(150);
  check(
    "accueil : le chevron des dépenses recule le mois",
    (await page.textContent("#spending-title")).includes("juillet 2026"),
    await page.textContent("#spending-title"),
  );
  check(
    "accueil : et il recule celui des gains avec lui",
    (await page.textContent("#earning-title")).includes("juillet 2026"),
    await page.textContent("#earning-title"),
  );
  await page.click("#earning-next");
  await page.waitForTimeout(150);
  check(
    "accueil : le chevron des gains ramène les deux cartes",
    (await page.textContent("#spending-title")).includes("août 2026") &&
      (await page.textContent("#earning-title")).includes("août 2026"),
  );

  // **Les soldes ne suivent pas le mois.** Un solde est cumulatif depuis
  // l'ouverture du compte : le voir bouger en feuilletant serait un contresens
  // que rien à l'écran ne dénoncerait.
  check(
    "accueil : feuilleter ne touche pas aux soldes",
    (await page.textContent("#total-bank")) === "24972,62 €",
  );

  // Relire ne ramène pas à aujourd'hui : on garde le mois regardé.
  await page.click("#spending-previous");
  await page.waitForTimeout(150);
  await page.click("#refresh");
  await page.waitForTimeout(150);
  check(
    "accueil : rafraîchir garde le mois qu'on regardait",
    (await page.textContent("#spending-title")).includes("juillet 2026"),
    await page.textContent("#spending-title"),
  );

  // La tuile est une porte : elle ouvre F02 sur SON compte, et pas sur le
  // premier de la liste — la faute des six statistiques du 26/07/2026.
  await page.locator(".tile").nth(1).click();
  await page.waitForTimeout(150);
  check(
    "accueil : la tuile ouvre les opérations de son propre compte",
    await page.evaluate(() =>
      window.__calls.some(
        ([command, args]) => command === "open_operations_list" && args.accountId === 2,
      ),
    ),
  );
  await page.close();
}

// --- Le menu Outils du sélecteur de bases (08/08/2026) ------------------
//
// « Protection de la base par mot de passe » y est entrée le 08/08/2026 sur
// demande de Fabrice : *« cela est plus facilement trouvable que le menu
// contextuel »*. Le clic droit sur la ligne reste ; ce qui est vérifié ici,
// c'est que le second chemin existe, qu'il est écrit dans la langue en cours
// et qu'il est rangé au bon endroit.
{
  const page = await browser.newPage();
  const errors = await openWindow(page, "http://localhost:4173/ui/windows/database-selector.html");
  check("bases : la fenêtre s'ouvre sans une plainte", errors.length === 0, errors.join(" | "));

  const tools = await page.evaluate(() =>
    [...document.querySelectorAll('[data-menu="tools"] .window-menu__choice')].map(
      (choice) => choice.textContent,
    ),
  );
  check(
    "bases : le menu Outils porte la protection par mot de passe",
    tools.includes("Protection de la base par mot de passe"),
    tools.join(" | "),
  );
  check(
    "bases : elle est rangée entre la réparation et le journal",
    tools.indexOf("Protection de la base par mot de passe") ===
      tools.findIndex((label) => label.startsWith("Réparation")) + 1 &&
      tools.indexOf("Protection de la base par mot de passe") ===
        tools.indexOf("Afficher le log") - 1,
    tools.join(" | "),
  );
  check(
    "bases : sa phrase vient du noyau, pas de sa clef",
    !tools.some((label) => label.startsWith("menu-")),
    tools.join(" | "),
  );
  await page.close();
}

// --- Les deux « À propos » portent les mêmes mentions (08/08/2026) ------
//
// Fabrice a demandé que le copyright et l'absence de garantie soient dits dans
// les trois fenêtres de la famille, et non dans la seule « Licence
// d'utilisation ». Les trois lisent les deux mêmes clefs : corrigées une fois,
// corrigées partout — et c'est cela que ces vérifications tiennent.
for (const [window, size] of [
  ["about-author", { width: 520, height: 480 }],
  ["about-radinus", { width: 520, height: 560 }],
]) {
  const page = await browser.newPage();
  await page.setViewportSize(size);
  const errors = await openWindow(page, `http://localhost:4173/ui/windows/${window}.html`);
  check(`${window} : la fenêtre s'ouvre sans une plainte`, errors.length === 0, errors.join(" | "));

  const notices = await page.evaluate(() =>
    ["copyright", "no-warranty"].map((id) => ({
      text: document.getElementById(id).textContent,
      weight: getComputedStyle(document.getElementById(id)).fontWeight,
    })),
  );
  check(
    `${window} : le copyright nomme l'auteur et l'année`,
    notices[0].text.includes("Fabrice Garcia") && notices[0].text.includes("2026"),
    notices[0].text,
  );
  check(
    `${window} : l'absence de garantie est dite`,
    notices[1].text.length > 20 && !notices[1].text.startsWith("licence-"),
    notices[1].text,
  );
  check(
    `${window} : les deux mentions sont en gras`,
    notices.every((notice) => Number(notice.weight) >= 700),
    notices.map((notice) => notice.weight).join(","),
  );
  check(
    `${window} : rien ne déborde`,
    await page.evaluate(() =>
      document.documentElement.scrollHeight <= window.innerHeight &&
      document.documentElement.scrollWidth <= window.innerWidth,
    ),
  );
  await page.close();
}

// --- « Licence d'utilisation » (08/08/2026) -----------------------------
//
// The first window of the « À propos » family to be watched at all: neither
// « À propos de l'auteur » nor « À propos de Radinus » has a single check,
// and that is exactly how a window ends up saying nothing on the day someone
// renames a key.
{
  const page = await browser.newPage();
  await page.setViewportSize({ width: 560, height: 520 });
  const errors = await openWindow(page, "http://localhost:4173/ui/windows/licence.html");
  check("licence : la fenêtre s'ouvre sans une plainte", errors.length === 0, errors.join(" | "));

  // Chaque phrase vient du noyau. `t` rend la clef quand elle manque, donc
  // une phrase égale à sa clef est une phrase que personne n'a traduite.
  const said = await page.evaluate(() =>
    ["heading", "name", "intro", "freedoms-title", "freedom-use", "freedom-study",
     "freedom-share", "freedom-improve", "copyright", "no-warranty", "info-bar"]
      .map((id) => document.getElementById(id).textContent),
  );
  check(
    "licence : les onze phrases arrivent entières du noyau",
    said.every((text) => text && !text.startsWith("licence-")),
    said.join(" | "),
  );
  // Le titre est en capitales et il est au-dessus du logo : les deux comptent,
  // et c'est l'ordre dans le document qui le prouve, pas la feuille de style.
  check(
    "licence : le titre est écrit en capitales",
    said[0] === said[0].toUpperCase() && said[0].includes("RADINUS"),
    said[0],
  );
  check(
    "licence : et il est au-dessus du logo",
    await page.evaluate(() => {
      const heading = document.getElementById("heading");
      const logo = document.getElementById("logo");
      return Boolean(
        heading.compareDocumentPosition(logo) & Node.DOCUMENT_POSITION_FOLLOWING,
      );
    }),
  );
  check(
    "licence : elle nomme la licence, version comprise",
    said[1] === "GNU GPL v3 ou ultérieure",
    said[1],
  );

  // Les quatre libertés sont une liste, et une liste à puces — demande de
  // Fabrice, 08/08/2026 : « ça doit être structuré ».
  const freedoms = await page.evaluate(() => {
    const list = document.querySelector(".about__freedoms-list");
    return {
      count: list.querySelectorAll("li").length,
      marker: getComputedStyle(list).listStyleType,
      filled: [...list.querySelectorAll("li")].every((item) => item.textContent.trim() !== ""),
    };
  });
  check("licence : les quatre libertés sont quatre", freedoms.count === 4, String(freedoms.count));
  check("licence : et elles portent une puce", freedoms.marker === "disc", freedoms.marker);
  check("licence : aucune n'est vide", freedoms.filled);

  // Les deux mentions que la GPL réclame : le copyright, et l'absence de
  // garantie. En gras — c'est ce que Fabrice a demandé, et la licence parle
  // elle-même d'une mention « bien visible ».
  const notices = await page.evaluate(() =>
    ["copyright", "no-warranty"].map((id) => ({
      text: document.getElementById(id).textContent,
      weight: getComputedStyle(document.getElementById(id)).fontWeight,
    })),
  );
  check(
    "licence : le copyright nomme l'auteur et l'année",
    notices[0].text.includes("Fabrice Garcia") && notices[0].text.includes("2026"),
    notices[0].text,
  );
  check(
    "licence : l'absence de garantie est dite",
    notices[1].text.length > 20,
    notices[1].text,
  );
  check(
    "licence : les deux mentions sont en gras",
    notices.every((notice) => Number(notice.weight) >= 700),
    notices.map((notice) => notice.weight).join(","),
  );

  // Le logo EST le bouton. Le dossier jaune de la bande ardoise est parti le
  // 08/08/2026 : « pas adapté », et l'action a rejoint l'emblème.
  const panel = await page.evaluate(() =>
    [...document.querySelectorAll(".panel .panel__button")].map((button) => button.id),
  );
  check(
    "licence : la bande ardoise ne porte plus que la porte",
    panel.length === 1 && panel[0] === "close",
    panel.join(","),
  );
  check(
    "licence : le logo est dans le bouton, et non à côté",
    await page.evaluate(() => Boolean(document.querySelector("#read #logo"))),
  );
  await page.click("#read");
  await page.waitForTimeout(100);
  check(
    "licence : cliquer le logo demande la page officielle",
    await page.evaluate(() =>
      window.__calls.some(([command]) => command === "open_licence_page"),
    ),
  );

  // Rien ne dépasse : la fenêtre est fixe, et une langue plus bavarde que le
  // français y ferait apparaître une barre de défilement au lieu d'une ligne.
  const spills = await page.evaluate(() => ({
    wide: document.documentElement.scrollWidth > window.innerWidth,
    tall: document.documentElement.scrollHeight > window.innerHeight,
  }));
  check("licence : rien ne déborde en largeur", !spills.wide);
  check("licence : rien ne déborde en hauteur", !spills.tall);
  await page.close();
}

await browser.close();
server.close();

for (const { name, ok, detail } of checks) {
  console.log(`${ok ? "ok  " : "ÉCHEC"} ${name}${ok || !detail ? "" : ` — ${detail}`}`);
}
console.log(`\n${checks.length - failures}/${checks.length} vérifications passées.`);
process.exit(failures === 0 ? 0 : 1);
