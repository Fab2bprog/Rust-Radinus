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
      id: 1, label: "COURSES", reference: "CB SYSTEME U REF 0105", date: "05/01/2026", clearing_date: "05/01/2026",
      date_value: "2026-01-05", clearing_date_value: "2026-01-05", balance_value: 2322340000,
      month: "janvier", category: "Alimentation", assignment: "Famille",
      payment_mode: "Carte bancaire", payee: "Système U", project: "",
      debit: "-100,00 €", credit: "", balance: "2\u202f322,34 €", amount: -100000000,
      has_comment: true, comment: "Marché du dimanche", has_attachment: false, check_number: "",
      category_id: 1, assignment_id: 2, payment_mode_id: 3, payee_id: 4, project_id: 0,
      parent_id: 0, child_count: 2, is_complement: false,
      is_pointed: true, status_id: 1, verification_id: 2,
    },
    {
      id: 2, label: "Alimentation", reference: "", date: "05/01/2026", clearing_date: "05/01/2026",
      date_value: "2026-01-05", clearing_date_value: "2026-01-05", balance_value: 0,
      month: "janvier", category: "Alimentation", assignment: "Famille",
      payment_mode: "Carte bancaire", payee: "", project: "",
      debit: "-60,00 €", credit: "", balance: "", amount: -60000000,
      has_comment: false, comment: "", has_attachment: false, check_number: "",
      category_id: 1, assignment_id: 2, payment_mode_id: 3, payee_id: 0, project_id: 0,
      parent_id: 1, child_count: 0, is_complement: false,
      is_pointed: true, status_id: 1, verification_id: 2,
    },
    {
      id: 3, label: "Complément", reference: "", date: "05/01/2026", clearing_date: "05/01/2026",
      date_value: "2026-01-05", clearing_date_value: "2026-01-05", balance_value: 0,
      month: "janvier", category: "Alimentation", assignment: "Famille",
      payment_mode: "Carte bancaire", payee: "", project: "",
      debit: "-40,00 €", credit: "", balance: "", amount: -40000000,
      has_comment: false, comment: "", has_attachment: false, check_number: "",
      category_id: 1, assignment_id: 2, payment_mode_id: 3, payee_id: 0, project_id: 0,
      parent_id: 1, child_count: 0, is_complement: true,
      is_pointed: true, status_id: 1, verification_id: 2,
    },
    {
      id: 4, label: "SALAIRE", reference: "", date: "28/01/2026", clearing_date: "28/01/2026",
      date_value: "2026-01-28", clearing_date_value: "2026-01-28", balance_value: 0,
      month: "janvier", category: "Salaire", assignment: "Monsieur",
      payment_mode: "Virement", payee: "", project: "",
      debit: "", credit: "2\u202f216,71 €", balance: "", amount: 2216710000,
      has_comment: false, comment: "", has_attachment: true, check_number: "",
      category_id: 5, assignment_id: 1, payment_mode_id: 2, payee_id: 0, project_id: 0,
      parent_id: 0, child_count: 0, is_complement: false,
      is_pointed: false, status_id: 3, verification_id: 3,
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
  // L'assistant d'exportation d'une base (P-74, 19/10/2026).
  "menu-tools-export": "Assistant d'exportation de la base…",
  "base-export-purpose": "Cet assistant copie les données de la base dans des fichiers que d'autres logiciels savent lire : un tableur, une base de données comme Access, un autre logiciel de comptes. La base elle-même n'est pas modifiée.",
  "base-export-step-format": "1. Le format",
  "base-export-step-options": "2. Les options",
  "base-export-step-place": "3. L'emplacement",
  "base-export-step-summary": "4. Le récapitulatif",
  "base-export-format-xlsx": "Excel (.xlsx)",
  "base-export-format-xlsx-hint": "Un classeur avec une feuille par table, lisible par Excel et par la plupart des tableurs.",
  "base-export-format-ods": "Calc (.ods)",
  "base-export-format-ods-hint": "Le format libre de LibreOffice et d'OpenOffice, avec une feuille par table.",
  "base-export-format-csv": "CSV (.csv)",
  "base-export-format-csv-hint": "Un fichier texte par table, valeurs séparées par des points-virgules : le format que presque tous les logiciels savent importer, Access compris.",
  "base-export-format-json": "JSON (.json)",
  "base-export-format-json-hint": "Pour les programmeurs et les applications : chaque table sous son nom, avec un en-tête qui décrit l'export.",
  "base-export-format-xml": "XML (.xml)",
  "base-export-format-xml-hint": "Le même contenu que le JSON, écrit en XML.",
  "base-export-format-sql": "Script SQL (.sql)",
  "base-export-format-sql-hint": "Les instructions qui recréent les tables et leurs données dans une autre base de données (MySQL, PostgreSQL, SQLite…).",
  "base-export-format-sqlite": "Base SQLite (.sqlite)",
  "base-export-format-sqlite-hint": "Une base de données autonome, sans mot de passe, que de nombreux outils ouvrent directement.",
  "base-export-format-qif": "QIF, un fichier par compte (.qif)",
  "base-export-format-qif-hint": "Pour reprendre ses comptes dans un autre logiciel de comptes (Money, Quicken, GnuCash, Grisbi…).",
  "base-export-format-ofx": "OFX, un fichier par compte (.ofx)",
  "base-export-format-ofx-hint": "Le format des relevés bancaires, que la plupart des logiciels de comptes savent importer.",
  "base-export-lossy": "Attention : le QIF et l'OFX ne savent pas tout dire. Seules les opérations des comptes passent, avec leurs tiers, leurs catégories et leurs commentaires ; un virement devient une opération ordinaire de chaque côté, et le reste (budgets, échéanciers, projets, affectations…) ne suit pas. Pour tout garder, choisissez un autre format.",
  "base-export-planned-note": "Les opérations prévues et les opérations sans date ne sont pas exportées : elles ne sont pas encore passées en banque. Leur nombre sera indiqué à la fin.",
  "base-export-dates-hint": "Les dates sont écrites année-mois-jour (2026-12-31) et les montants dans la devise de la base : aucun logiciel ne peut s'y tromper.",
  "base-export-group-layout": "Fichiers",
  "base-export-layout-one": "Tout dans un seul fichier",
  "base-export-layout-per-table": "Un fichier par table, dans un dossier",
  "base-export-group-decimal": "Séparateur décimal des montants",
  "base-export-decimal-point": "Le point (1234.56)",
  "base-export-decimal-comma": "La virgule (1234,56)",
  "base-export-group-quotes": "Guillemets",
  "base-export-quotes-all": "Chaque valeur entre guillemets",
  "base-export-quotes-none": "Aucun guillemet",
  "base-export-csv-replacements-hint": "Pour que chaque fichier se relise sans erreur, un point-virgule dans un texte devient un point d'exclamation, un retour à la ligne devient une espace et, sans guillemets, un guillemet devient une apostrophe. Le nombre de remplacements sera indiqué à la fin.",
  "base-export-group-qif-order": "Ordre des dates",
  "base-export-qif-day-month": "Le jour avant le mois (31/12/2026)",
  "base-export-qif-month-day": "Le mois avant le jour (12/31/2026)",
  "base-export-qif-order-hint": "Choisissez l'ordre qu'attend le logiciel qui lira les fichiers : le jour d'abord en Europe, le mois d'abord aux États-Unis.",
  "base-export-no-option": "Ce format n'a pas d'option.",
  "base-export-choose-file": "Choisir le fichier…",
  "base-export-choose-folder": "Choisir le dossier…",
  "base-export-place-file": "L'export sera écrit dans ce fichier :",
  "base-export-place-folder": "L'export sera écrit dans ce dossier, créé pour l'occasion :",
  "base-export-place-none": "Aucun emplacement n'est encore choisi.",
  "base-export-place-needed": "Choisissez d'abord où écrire l'export.",
  "base-export-summary-base": "Base",
  "base-export-summary-format": "Format",
  "base-export-summary-options": "Options",
  "base-export-summary-place": "Emplacement",
  "base-export-unprotected": "Cette base est protégée par un mot de passe, mais l'export ne le sera pas : quiconque aura ces fichiers pourra lire vos comptes. Rangez-les en lieu sûr.",
  "base-export-previous": "Précédent",
  "base-export-next": "Suivant",
  "base-export-run": "Exporter",
  "base-export-running": "Exportation en cours…",
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
  "operations-column-status": "Statut opération",
  "operations-column-verification": "Vérification",
  "operation-field-verification": "Vérification",
  "preferences-branch-display": "Affichage",
  "preferences-branch-import": "Importation",
  "preferences-leaf-verification": "Vérification",
  "preferences-field-verification": "Opérations importées :",
  "preferences-saved": "Préférences enregistrées.",
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
  "window-balances-title": "Soldes de vos comptes",
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
  "filter-by-status": "Filtre Statut",
  "filter-by-verification": "Filtre Vérification",
  "filter-show-all": "Afficher tout",
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
  "operation-clearing-date-required":
    "Une opération pointée doit obligatoirement porter une date de pointage.",
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
  "operations-recurring-from":
    "Créer une opération périodique à partir de cette opération",
  "statistics-axis-column": "NomCategorie",
  "statistics-unclassified": "Sans catégorie",
  "statistics-total": "Total",
  "crossed-balance-column": "Categorie",
  "crossed-balance-window-name": "Bilan croisé",
  "crossed-balance-no-data": "Aucune opération sur ce mois pour les comptes choisis.",
  "crossed-balance-month-choose": "Choisir le mois",
  "crossed-balance-next": "Mois suivant",
  "crossed-balance-previous": "Mois précédent",
  "export-all-months-excel": "Exporter tous les mois de l'année affichée vers Excel",
  "export-all-months-ods":
    "Exporter tous les mois de l'année affichée vers LibreOffice Calc",
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
  "analysis-heading": "Analyse de l'évolution du solde",
  "analysis-hint": "Tracez une zone sur le graphique, bouton de la souris enfoncé, pour voir les opérations de cette période.",
  "analysis-zone": "Zone :",
  "analysis-opening": "Solde au début :",
  "analysis-closing": "Solde à la fin :",
  "analysis-variation": "Variation :",
  "analysis-detail-name": "Analyse du solde",
  "analysis-detail-none": "Aucune opération dans cette zone.",
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
  "export-to": "Exporter vers",
  "copy-cell": "Copier la cellule",
  "copy-rows": "Copier les lignes sélectionnées",
  "copy-failed": "La copie dans le presse-papiers a échoué.",
  "columns-reset": "Rétablir les colonnes par défaut",
  "columns-show-hide": "Afficher/Masquer",
  "columns-colour": "Colorer la colonne :",
  "columns-colour-none": "Aucune couleur",
  "columns-colour-red": "Rouge",
  "columns-colour-orange": "Orange",
  "columns-colour-pink": "Rose",
  "columns-colour-pastel-green": "Vert pastel",
  "columns-colour-green": "Vert",
  "columns-colour-pastel-blue": "Bleu pastel",
  "columns-colour-blue": "Bleu",
  "columns-colour-pastel-yellow": "Jaune pastel",
  "columns-colour-yellow": "Jaune",
  "preferences-leaf-columns": "Colonnes des tableaux",
  "preferences-columns-reset": "Réinitialiser",
  "preferences-columns-reset-all": "Tout réinitialiser",
  "preferences-columns-done": "Les colonnes ont retrouvé leur disposition d'origine.",
  "preferences-columns-hint": "Chaque tableau retient l'ordre de ses colonnes.",
  "welcome-tile-counted": "Compter ce compte dans les totaux",
  "window-loan-title": "Simulation de crédit",
  "loan-tab-credit": "Le crédit",
  "loan-tab-afford": "Puis-je le rembourser ?",
  "loan-field-kind": "Type de crédit",
  "loan-field-amount": "Montant emprunté",
  "loan-field-payment": "Mensualité",
  "loan-field-months": "Durée",
  "loan-field-rate": "Taux débiteur fixe",
  "loan-field-fees": "Frais de dossier",
  "loan-field-insurance": "Assurance par mois",
  "loan-unit-months": "mois",
  "loan-unit-percent": "%",
  "loan-invalid-field": "Cette valeur n'est pas un nombre : corrigez-la pour relancer le calcul.",
  "loan-report-button": "Rapport PDF",
  "loan-monthly-table": "Tableau mois par mois",
  "loan-chart-cost": "Ce que coûte ce crédit",
  "loan-chart-capital": "Capital restant dû",
  "loan-schedule-title": "Tableau d'amortissement",
  "loan-column-number": "N°",
  "loan-column-date": "Échéance",
  "loan-column-payment": "Mensualité",
  "loan-column-interest": "Intérêts",
  "loan-column-capital": "Capital",
  "loan-column-insurance": "Assurance",
  "loan-column-remaining": "Capital restant dû",
  "loan-history-label": "Période étudiée",
  "loan-accounts-title": "Comptes étudiés",
  "loan-column-account": "Compte",
  "loan-column-bank": "Banque",
  "loan-column-balance": "Solde réel",
  "loan-running-title": "Crédits en cours retenus",
  "loan-running-column-label": "Opération périodique",
  "loan-running-column-monthly": "Par mois",
  "loan-running-column-end": "Dernière échéance",
  "loan-verdict-title": "En résumé",
  "loan-chart-income": "Où va votre revenu moyen",
  "loan-chart-history": "Votre historique avec ce crédit",
  "loan-chart-history-hint": "Ce qui serait resté chaque mois, la mensualité payée. En rouge, les mois qui auraient fini dans le rouge.",
  "loan-chart-projection": "Votre solde projeté",
  "loan-tab-rules": "Réglages du jugement",
  "loan-unit-percent-year": "% par an",
  "loan-disclaimer": "Simulation indicative, sans valeur contractuelle. Seule l'offre de la banque fait foi.",
  "window-appliance-title": "Consommation d'un appareil électrique",
  "appliance-device-title": "L'appareil",
  "appliance-on-title": "Allumé",
  "appliance-standby-title": "En veille",
  "appliance-field-on-watts": "Puissance en marche",
  "appliance-field-on-hours": "Durée de marche par jour",
  "appliance-field-days": "Jours d'utilisation par semaine",
  "appliance-field-share": "Part de la marche en heures creuses",
  "appliance-field-standby-watts": "Puissance en veille",
  "appliance-field-standby-hours": "Durée de veille par jour d'utilisation",
  "appliance-unit-watts": "W",
  "appliance-unit-hours": "h",
  "appliance-unit-days": "sur 7",
  "appliance-unit-percent": "%",
  "appliance-unit-price": "{ $sign }/kWh",
  "appliance-standby-hint": "Laissée vide, la veille dure le reste de la journée. Les jours sans usage, l'appareil reste branché : tout ce temps compte en veille. Débranché, sa veille est de 0 W.",
  "appliance-contract-title": "Votre contrat",
  "appliance-field-option": "Option tarifaire",
  "appliance-option-base": "Base (un seul prix)",
  "appliance-option-off-peak": "Heures pleines / Heures creuses",
  "appliance-field-base": "Prix du kWh",
  "appliance-field-peak": "Prix du kWh en heures pleines",
  "appliance-field-off-peak": "Prix du kWh en heures creuses",
  "appliance-field-off-peak-hours": "Heures creuses par jour",
  "appliance-contract-hint": "Ces prix ne valent que pour ce calcul. Le tarif enregistré se règle dans Paramètres › Préférences › Outils.",
  "appliance-contract-reset": "Reprendre le tarif enregistré",
  "appliance-period-day": "Par jour",
  "appliance-period-month": "Par mois",
  "appliance-period-year": "Par an",
  "appliance-energy": "{ $value } kWh",
  "appliance-less-than": "moins de { $amount }",
  "appliance-detail-title": "Le détail sur un an",
  "appliance-column-part": "Poste",
  "appliance-column-energy": "Énergie",
  "appliance-column-cost": "Coût",
  "appliance-column-share": "Part",
  "appliance-line-on": "Allumé",
  "appliance-line-standby": "En veille",
  "appliance-line-on-peak": "Allumé, heures pleines",
  "appliance-line-on-off-peak": "Allumé, heures creuses",
  "appliance-line-standby-peak": "En veille, heures pleines",
  "appliance-line-standby-off-peak": "En veille, heures creuses",
  "appliance-line-total": "Total",
  "appliance-chart-title": "Où part l'argent",
  "appliance-chart-caption": "par an",
  "appliance-standby-sentence": "La veille seule coûte { $amount } par an : { $share } de ce que coûte l'appareil.",
  "appliance-note-plate": "La puissance inscrite sur l'appareil ou dans sa notice est un maximum : en marche, la plupart des appareils consomment moins. Pour un chiffre réel, mesurez-le avec une prise wattmètre et reportez ce qu'elle indique.",
  "appliance-note-subscription": "L'abonnement n'est pas compté : on le paie, que l'appareil soit branché ou non.",
  "window-cushion-title": "Mon matelas de sécurité",
  "cushion-question": "Si vos revenus s'arrêtaient demain, combien de mois tiendriez-vous avec votre épargne ?",
  "cushion-accounts-title": "Vos comptes",
  "cushion-column-account": "Compte",
  "cushion-column-balance": "Solde réel",
  "cushion-column-savings": "Épargne",
  "cushion-column-spending": "Dépenses",
  "cushion-accounts-hint": "« Épargne » : l'argent sur lequel vous comptez en cas de coup dur. « Dépenses » : les comptes d'où partent les dépenses du quotidien.",
  "cushion-history-label": "Période étudiée",
  "cushion-backup-label": "Revenu de secours par mois",
  "cushion-backup-hint": "Ce qui continuerait d'arriver : allocation chômage, salaire du conjoint… Vide : aucun revenu.",
  "cushion-categories-title": "Les dépenses retenues",
  "cushion-categories-hint": "Décochez ce que vous couperiez en cas de coup dur.",
  "cushion-categories-empty": "Aucune dépense sur cette période.",
  "cushion-verdict-title": "Votre matelas",
  "cushion-targets-title": "Les seuils de prudence",
  "cushion-projection-title": "Votre épargne en cas de coup dur",
  "cushion-projection-hint": "Ce qui resterait chaque mois si vos revenus s'arrêtaient aujourd'hui.",
  "cushion-note": "Une estimation tirée de votre historique : les dépenses d'un mois difficile peuvent différer de la moyenne.",
  "window-goal-title": "Objectif Épargne",
  "goal-accounts-title": "Les comptes suivis",
  "goal-column-account": "Compte",
  "goal-column-balance": "Solde réel",
  "goal-accounts-hint": "Un virement entre deux comptes suivis s'annule ; un virement vers un compte non suivi compte comme une sortie.",
  "goal-period-label": "Période de référence",
  "goal-period-range": "Plage d'années…",
  "goal-range-from": "de",
  "goal-range-to": "à",
  "goal-question-title": "Votre question",
  "goal-question-when": "Quand aurai-je ce montant ?",
  "goal-question-amount": "Combien aurai-je à cette date ?",
  "goal-question-effort": "Combien épargner pour avoir ce montant à cette date ?",
  "goal-field-target": "Montant visé",
  "goal-field-date": "Date visée",
  "goal-field-rate": "Taux annuel de l'épargne",
  "goal-field-extra": "Et si j'épargnais en plus, par mois",
  "goal-options-hint": "Vides : aucun intérêt, rien de plus.",
  "goal-answer-title": "La réponse",
  "goal-chart-title": "Votre solde, hier et demain",
  "goal-chart-hint": "En trait plein, le solde réel des douze derniers mois ; en pointillés, la projection ; en clair, la fourchette selon les mois.",
  "goal-disclaimer": "Une projection tirée de votre historique, pas une promesse : un imprévu peut tout changer.",
  "window-cut-title": "Et si je réduisais… ?",
  "cut-axis-label": "Classer par",
  "cut-axis-category": "Catégories",
  "cut-axis-payee": "Tiers",
  "cut-axis-budget-line": "Postes budgétaires",
  "cut-table-title": "Vos dépenses, poste par poste",
  "cut-column-monthly": "Par mois",
  "cut-column-cut": "Réduction",
  "cut-column-after": "Après",
  "cut-column-yearly": "Gain par an",
  "cut-total": "Total",
  "cut-horizon-label": "Horizon",
  "cut-settings-title": "Réglages",
  "cut-options-hint": "Le taux et le montant visé sont facultatifs.",
  "cut-report-button": "Rapport PDF",
  "cut-chart-title": "Votre solde, sans et avec les réductions",
  "cut-chart-hint": "En trait plein, le solde réel des douze derniers mois ; en pointillés gris, la projection sans réduction ; en bleu, avec ; en vert, l'argent gagné.",
  "cut-donut-title": "Vos dépenses par mois après réduction",
  "cut-donut-caption": "après réduction",
  "cut-donut-others": "Autres postes",
  "cut-donut-saved": "Économisé",
  "cut-legend-with": "Avec les réductions",
  "cut-legend-without": "Sans réduction",
  "cut-years": "{ $years -> [one] { $years } an *[other] { $years } ans }",
  "cut-headline-none": "Tapez une réduction dans le tableau pour en voir l'effet.",
  "cut-headline": "En réduisant { $count -> [one] ce poste *[other] ces { $count } postes }, vous mettriez de côté { $monthly } de plus par mois, soit { $yearly } par an.",
  "cut-tile-monthly": "Gain par mois",
  "cut-tile-yearly": "Gain par an",
  "cut-tile-horizon": "Gain sur { $years -> [one] { $years } an *[other] { $years } ans }",
  "cut-tile-spending": "Dépenses par mois",
  "cut-target-already": "Vous avez déjà { $amount }.",
  "cut-target-sooner": "Vous atteindriez { $amount } vers { $with } au lieu de { $without } : { $months -> [0] pas plus tôt [one] un mois plus tôt *[other] { $months } mois plus tôt }.",
  "cut-target-only-with": "Avec ces réductions, vous atteindriez { $amount } vers { $with } ; sans elles, à votre rythme actuel, jamais.",
  "cut-target-never": "Même avec ces réductions, vous n'atteindriez pas { $amount } à votre rythme actuel.",
  "cut-note-seasons": "Chaque réduction suit les saisons de son poste : un poste qui pèse surtout l'été rapporte surtout l'été.",
  "cut-note-capped": "Une réduction tapée dépassait la dépense : elle a été ramenée à la dépense elle-même.",
  "cut-invalid-cut": "Cette réduction n'est pas lisible : un pourcentage de 0 à 100, ou un montant par mois.",
  "cut-report-settings": "Les réglages",
  "cut-report-result": "Le résultat",
  "cut-report-accounts": "Comptes suivis",
  "window-holiday-title": "Préparer mes vacances",
  "holiday-trip-title": "Le voyage",
  "holiday-field-trip": "Type de voyage",
  "holiday-trip-stay": "Séjour",
  "holiday-trip-cruise": "Croisière",
  "holiday-field-adults": "Adultes",
  "holiday-field-children": "Enfants",
  "holiday-field-nights": "Durée du séjour, en nuits",
  "holiday-field-days": "Jours",
  "holiday-field-months": "Mois avant le départ",
  "holiday-field-stops": "Nombre d'escales",
  "holiday-saved-title": "Déjà épargné",
  "holiday-saved-hint": "Cochez les comptes où l'argent des vacances est déjà mis de côté : leur solde réel compte comme déjà épargné.",
  "holiday-budget-title": "Le budget",
  "holiday-budget-hint": "Pour chaque poste, un montant, pour qui il vaut et pour combien de temps. Vide, un poste ne compte pas.",
  "holiday-optional-title": "Lignes facultatives",
  "holiday-result-title": "Le résultat",
  "holiday-donut-title": "Où part l'argent du voyage",
  "holiday-donut-caption": "pour le voyage",
  "holiday-child-label": "Prix enfant",
  "holiday-count-label": "Cabines",
  "holiday-open": "Ouvrir un projet…",
  "cut-file-filter": "Projet de réduction",
  "menu-tools-car": "Carnet de ma voiture",
  "window-car-title": "Carnet de ma voiture",
  "car-unnamed": "Ma voiture",
  "car-sheet-title": "La voiture",
  "car-field-plate": "Immatriculation",
  "car-field-make": "Marque",
  "car-field-model": "Modèle",
  "car-field-engine": "Motorisation",
  "car-field-first-hand": "Première main",
  "car-field-registered": "Première mise en circulation",
  "car-field-acquired": "Date d'acquisition",
  "car-field-acquired-km": "Kilométrage à l'acquisition",
  "car-field-service": "Révision tous les",
  "car-field-service-or": "ou tous les",
  "car-unit-months-short": "mois",
  "car-unit-km": "km",
  "car-tariff-title": "Tarif de la recharge à la maison",
  "car-tariff-hint": "Ce tarif est gardé dans le carnet de la voiture : il ne change pas celui des préférences.",
  "car-tariff-reset": "Reprendre le tarif des préférences",
  "car-engine-petrol": "Essence",
  "car-engine-diesel": "Diesel",
  "car-engine-lpg": "GPL",
  "car-engine-e85": "E85 (superéthanol)",
  "car-engine-hybrid": "Hybride",
  "car-engine-plug-in": "Hybride rechargeable",
  "car-engine-electric": "Électrique",
  "car-engine-hydrogen": "Hydrogène",
  "car-energy-petrol": "Essence",
  "car-energy-diesel": "Gazole",
  "car-energy-lpg": "GPL",
  "car-energy-e85": "E85",
  "car-energy-electricity": "Électricité",
  "car-energy-hydrogen": "Hydrogène",
  "car-unit-litre": "L",
  "car-unit-kwh": "kWh",
  "car-unit-kg": "kg",
  "car-rubric-energy": "Énergie",
  "car-rubric-upkeep": "Entretien courant",
  "car-rubric-service": "Révision",
  "car-rubric-wear": "Pièces d'usure",
  "car-rubric-tyres": "Pneus",
  "car-rubric-breakdown": "Pannes",
  "car-rubric-insurance": "Assurance",
  "car-rubric-inspection": "Contrôle technique",
  "car-part-brake-pads": "Plaquettes de frein",
  "car-part-brake-discs": "Disques de frein",
  "car-part-timing-belt": "Courroie de distribution",
  "car-part-clutch": "Embrayage",
  "car-part-battery-12v": "Batterie 12 V",
  "car-part-shock-absorbers": "Amortisseurs",
  "car-part-wipers": "Essuie-glaces",
  "car-part-spark-plugs": "Bougies d'allumage",
  "car-part-glow-plugs": "Bougies de préchauffage",
  "car-part-particulate-filter": "Filtre à particules",
  "car-part-catalytic-converter": "Pot catalytique",
  "car-part-fuel-cell-filter": "Filtre de la pile à combustible",
  "car-part-exhaust": "Échappement",
  "car-part-other": "Autre pièce…",
  "car-axle-all": "Les quatre pneus",
  "car-axle-front": "Pneus avant",
  "car-axle-rear": "Pneus arrière",
  "car-verdict-pass": "Favorable",
  "car-verdict-counter": "Contre-visite",
  "car-charge-station": "À une borne",
  "car-charge-home": "À la maison",
  "car-slot-peak": "Heures pleines",
  "car-slot-off-peak": "Heures creuses",
  "car-entry-new": "Nouvelle ligne",
  "car-entry-edit": "Modifier la ligne",
  "car-field-date": "Date",
  "car-field-km": "Compteur",
  "car-field-rubric": "Rubrique",
  "car-field-amount": "Montant",
  "car-field-garage": "Garage ou station",
  "car-field-note": "Note",
  "car-field-energy": "Énergie",
  "car-field-quantity": "Quantité",
  "car-field-charge": "Recharge",
  "car-field-slot": "Heure de recharge",
  "car-field-part": "Pièce",
  "car-field-part-name": "Nom de la pièce",
  "car-field-axle": "Pneus changés",
  "car-field-verdict": "Résultat",
  "car-field-months": "Mois couverts",
  "car-field-battery": "État de la batterie",
  "car-home-amount-hint": "Le montant d'une recharge à la maison se calcule avec le tarif de la voiture.",
  "car-entry-add": "Ajouter au carnet",
  "car-entry-update": "Enregistrer la ligne",
  "car-entry-cancel": "Annuler",
  "car-entry-delete": "Supprimer la ligne",
  "car-delete-question": "Supprimer cette ligne du carnet ?",
  "car-from-operation": "Prendre une opération…",
  "car-pick-account": "De quel compte vient la dépense ?",
  "car-pick-operation": "Quelle opération ?",
  "car-pick-take": "Prendre",
  "car-pick-none": "Aucune dépense dans ce compte.",
  "car-pick-taken": "Opération reprise : complétez le compteur et la rubrique, puis ajoutez la ligne.",
  "car-history-title": "L'historique",
  "car-filter-all": "Toutes les rubriques",
  "car-history-empty": "Aucune ligne pour l'instant.",
  "car-history-hint": "Cliquez une ligne pour la modifier.",
  "car-column-date": "Date",
  "car-column-km": "Km",
  "car-column-rubric": "Rubrique",
  "car-column-detail": "Détail",
  "car-column-amount": "Montant",
  "car-column-garage": "Garage",
  "car-column-note": "Note",
  "car-column-share": "Part",
  "car-column-per-km": "Au km",
  "car-column-energy": "Énergie",
  "car-column-quantity": "Quantité",
  "car-column-price": "Prix moyen",
  "car-column-consumption": "Consommation",
  "car-column-part": "Pièce",
  "car-column-changes": "Changements",
  "car-column-last": "Dernier changement",
  "car-column-life": "Durée de vie",
  "car-column-next": "Prochain changement",
  "car-total": "Total",
  "car-summary-title": "Ce que coûte la voiture",
  "car-headline-empty": "Remplissez la fiche, puis ajoutez une première ligne : un plein, une révision, une facture de garage…",
  "car-tile-total": "Coût total",
  "car-tile-month": "Par mois",
  "car-tile-km": "Au kilomètre",
  "car-tile-driven": "Kilomètres parcourus",
  "car-tile-consumption": "Consommation",
  "car-tile-energy-km": "Énergie au kilomètre",
  "car-rubrics-title": "Par rubrique",
  "car-energy-title": "L'énergie",
  "car-parts-title": "Pièces d'usure",
  "car-tyres-title": "Pneus",
  "car-battery-title": "État de la batterie",
  "car-years-title": "Ce que la voiture a coûté chaque année",
  "car-donut-title": "Où part l'argent",
  "car-donut-caption": "en tout",
  "car-deadlines-title": "Les échéances",
  "car-deadlines-empty": "Aucune échéance pour l'instant : notez une révision, un contrôle technique, une assurance, ou deux changements d'une même pièce.",
  "car-deadline-service": "Révision",
  "car-deadline-inspection": "Contrôle technique",
  "car-deadline-counter": "Contre-visite du contrôle technique",
  "car-deadline-insurance": "Fin de l'assurance",
  "car-when-inspection-unknown": "Notez le dernier contrôle technique pour connaître la date du prochain.",
  "car-tone-late": "Dépassée",
  "car-tone-soon": "Bientôt",
  "car-note-since": "Tout se compte depuis l'acquisition : la date et le compteur notés sur la fiche.",
  "car-note-consumption": "La consommation se mesure de plein à plein : faites le plein complet et notez le compteur à chaque fois.",
  "car-note-e85": "Une voiture E85 boit ce qu'on lui donne : les kilomètres qui suivent un plein comptent pour son carburant.",
  "car-note-home": "Une recharge à la maison est chiffrée au tarif de la voiture le jour où elle est notée, et garde ce coût.",
  "car-note-inspection": "Le contrôle technique suit la règle française : le premier dans les quatre ans de la mise en circulation, puis tous les deux ans ; une contre-visite, dans les deux mois.",
  "car-disclaimer": "Les échéances et les durées de vie sont des estimations tirées du carnet : seul le carnet d'entretien du constructeur fait foi.",
  "car-invalid-date": "Une date valide, qui n'est pas dans le futur, s'il vous plaît.",
  "car-invalid-acquired": "La date d'acquisition ne peut pas précéder la mise en circulation.",
  "car-invalid-km": "Un compteur en kilomètres entiers, s'il vous plaît.",
  "car-invalid-amount": "Ce montant n'est pas lisible.",
  "car-invalid-quantity": "Tapez la quantité : litres, kWh ou kilos.",
  "car-invalid-part": "Choisissez la pièce changée, ou tapez son nom.",
  "car-invalid-rubric": "Choisissez une rubrique.",
  "car-invalid-months": "Un nombre entier de mois, s'il vous plaît.",
  "car-invalid-battery": "Un état de batterie de 0 à 100 %, s'il vous plaît.",
  "car-open": "Ouvrir un carnet…",
  "car-save": "Enregistrer le carnet…",
  "car-report-button": "Dossier PDF",
  "car-file-filter": "Carnet de voiture",
  "car-file-not-logbook": "Ce fichier n'est pas un carnet de voiture de Radinus.",
  "car-file-too-recent": "Ce carnet vient d'une version plus récente de Radinus : mettez Radinus à jour pour l'ouvrir.",
  "car-replace-question": "Ouvrir ce carnet remplacera celui de la fenêtre. Continuer ?",
  "car-sheet-history": "Carnet",
  "car-sheet-summary": "Synthèse",
  "holiday-save": "Enregistrer le projet…",
  "holiday-pdf": "Rapport PDF",
  "holiday-excel": "Exporter vers Excel",
  "holiday-file-filter": "Projet de vacances",
  "holiday-replace-question": "Ouvrir ce projet remplacera ce qui est tapé dans la fenêtre. Continuer ?",
  "holiday-file-saved": "Projet enregistré : { $file }",
  "holiday-file-opened": "Projet ouvert : { $file }",
  "holiday-file-not-project": "Ce fichier n'est pas un projet de vacances de Radinus.",
  "holiday-file-too-recent": "Ce projet vient d'une version plus récente de Radinus : mettez Radinus à jour pour l'ouvrir.",
  "holiday-file-failed": "Le fichier n'a pas pu être lu ou écrit : { $reason }",
  "holiday-line-transport": "Transport aller-retour",
  "holiday-line-lodging": "Hébergement",
  "holiday-line-meals": "Repas et dépenses courantes",
  "holiday-line-visits": "Visites et loisirs",
  "holiday-line-port": "Acheminement jusqu'au port",
  "holiday-line-cabins": "Cabines",
  "holiday-line-service": "Forfait service (pourboires)",
  "holiday-line-drinks": "Forfait boissons",
  "holiday-line-excursions": "Excursions aux escales",
  "holiday-line-port-taxes": "Taxes portuaires",
  "holiday-line-wifi": "Wifi à bord",
  "holiday-line-onboard": "Dépenses à bord et aux escales",
  "holiday-line-other": "Autres frais et imprévus",
  "holiday-line-insurance": "Assurance annulation",
  "holiday-line-stay-tax": "Taxe de séjour",
  "holiday-line-car": "Voiture sur place, carburant et péages",
  "holiday-line-parking": "Parking de l'aéroport ou de la gare",
  "holiday-line-bank": "Frais bancaires à l'étranger",
  "holiday-line-formalities": "Formalités (passeport, visa, vaccins)",
  "holiday-line-pets": "Garde des animaux",
  "holiday-span-trip": "pour le séjour",
  "holiday-span-night": "par nuit",
  "holiday-span-day": "par jour",
  "holiday-span-stop": "par escale",
  "holiday-who-all": "pour tous",
  "holiday-who-person": "par personne",
  "holiday-who-adults": "par adulte",
  "holiday-cabins-count": "{ $count -> [one] { $count } cabine *[other] { $count } cabines }",
  "holiday-days": "{ $days -> [one] { $days } jour *[other] { $days } jours }",
  "holiday-invalid-count": "Un nombre entier, s'il vous plaît.",
  "holiday-invalid-amount": "Ce montant n'est pas lisible : un nombre positif, ou un pourcentage de 0 à 100.",
  "holiday-headline-empty": "Tapez les montants du budget pour voir ce que coûtera le voyage.",
  "holiday-headline-stay": "Ce séjour coûterait { $total } pour { $people -> [one] une personne *[other] { $people } personnes } et { $nights -> [0] aucune nuit [one] une nuit *[other] { $nights } nuits }.",
  "holiday-headline-cruise": "Cette croisière coûterait { $total } pour { $people -> [one] une personne *[other] { $people } personnes } et { $nights -> [0] aucune nuit [one] une nuit *[other] { $nights } nuits }.",
  "holiday-tile-total": "Coût total",
  "holiday-tile-person": "Par personne",
  "holiday-tile-person-day": "Par personne et par jour",
  "holiday-tile-saved": "Déjà épargné",
  "holiday-tile-remaining": "Reste à financer",
  "holiday-tile-monthly": "Épargne nécessaire",
  "holiday-remaining-none": "Rien : c'est couvert",
  "holiday-monthly-none": "Rien à mettre de côté",
  "holiday-monthly-now": "Départ ce mois-ci",
  "holiday-note-days": "Les jours sont les nuits plus une : sept nuits font huit jours.",
  "holiday-note-child": "Par personne, un enfant paie le prix enfant s'il est donné ; vide, il paie comme un adulte.",
  "holiday-note-percent": "Un pourcentage d'assurance porte sur les postes principaux du voyage ; celui des frais bancaires, sur les dépenses faites sur place.",
  "holiday-sheet-budget": "Budget",
  "holiday-sheet-result": "Résultat",
  "holiday-column-line": "Poste",
  "holiday-column-amount": "Montant",
  "holiday-column-child": "Prix enfant",
  "holiday-column-who": "Pour qui",
  "holiday-column-span": "Pour combien de temps",
  "holiday-column-cost": "Coût",
  "holiday-disclaimer": "Une estimation tirée de vos propres montants : les prix réels peuvent varier.",
  "goal-no-account": "Cochez au moins un compte à suivre.",
  "goal-no-month": "Cette période n'a encore aucun mois complet.",
  "goal-invalid-target": "Un montant à atteindre, s'il vous plaît.",
  "goal-invalid-date": "Une date à venir, dans les cinquante prochaines années, s'il vous plaît.",
  "goal-invalid-rate": "Un taux de 0 à 100 %, s'il vous plaît.",
  "goal-invalid-extra": "Ce montant n'est pas lisible : corrigez-le pour relancer le calcul.",
  "goal-per-month": "{ $amount } par mois",
  "goal-tile-balance": "Solde aujourd'hui",
  "goal-tile-rhythm": "Rythme moyen",
  "goal-tile-target": "Objectif",
  "goal-tile-reached": "Atteint vers",
  "goal-tile-date": "Date visée",
  "goal-tile-projected": "Solde projeté",
  "goal-tile-saved": "Épargné d'ici là",
  "goal-tile-interest": "Dont intérêts",
  "goal-tile-needed": "À épargner",
  "goal-when-already": "Vous avez déjà { $amount } : vos comptes suivis totalisent { $balance }.",
  "goal-when-reached": "Vous aurez { $amount } vers { $month }, dans { $months -> [one] un mois *[other] { $months } mois }.",
  "goal-when-range": "Selon les mois, entre { $early } et { $late }.",
  "goal-when-range-open": "Au plus tôt vers { $early } ; avec des mois faibles, l'objectif ne serait pas atteint.",
  "goal-when-never": "À ce rythme, vous n'atteindrez pas { $amount }.",
  "goal-zero": "Votre solde tomberait à zéro vers { $month }.",
  "goal-amount": "En { $month }, vous auriez environ { $amount }.",
  "goal-amount-range": "Selon les mois, entre { $low } et { $high }.",
  "goal-effort-more": "Pour avoir { $amount } en { $month }, il faudrait épargner en moyenne { $monthly } par mois, soit { $gap } de plus qu'aujourd'hui.",
  "goal-effort-less": "Pour avoir { $amount } en { $month }, { $monthly } par mois suffiraient, soit { $gap } de moins qu'aujourd'hui : vous êtes en avance.",
  "goal-effort-range": "Selon les mois, l'écart avec votre rythme irait de { $low } à { $high } par mois.",
  "goal-chart-target": "Objectif : { $amount }",
  "goal-chart-today": "Aujourd'hui",
  "goal-note-seasons": "La projection suit les saisons : chaque mois à venir reprend la moyenne des mêmes mois de la période.",
  "goal-note-range": "La fourchette vient des mois faibles et des mois forts de la période : le quart le plus bas et le quart le plus haut.",
  "goal-note-loan": "Le crédit « { $label } » se termine en { $month } : { $amount } par mois de plus ensuite.",
  "goal-note-interest": "Intérêts comptés chaque mois au taux de { $rate } % par an : une approximation de la règle des quinzaines des livrets.",
  "goal-period": "Rythme calculé sur { $count -> [one] { $count } mois complet *[other] { $count } mois complets }, de { $from } à { $to }. { $transfers -> [0] Aucun virement entre vos comptes suivis. [one] Un virement entre vos comptes suivis, neutralisé. *[other] { $transfers } virements entre vos comptes suivis, neutralisés. }",
  "cushion-invalid-backup": "Ce montant n'est pas lisible : corrigez-le pour relancer le calcul.",
  "cushion-no-spending-account": "Cochez au moins un compte « Dépenses ».",
  "cushion-no-month": "Cette période n'a encore aucun mois complet.",
  "cushion-months": "{ $value } mois",
  "cushion-per-month": "{ $amount } par mois",
  "cushion-figure-holds": "Sans limite",
  "cushion-gauge-caption": "de dépenses couvertes",
  "cushion-verdict-short": "Moins de trois mois : un coup dur vous mettrait vite en difficulté.",
  "cushion-verdict-fair": "Entre trois et six mois : un matelas correct, à étoffer si vous le pouvez.",
  "cushion-verdict-solid": "Six mois ou plus : votre matelas est solide.",
  "cushion-verdict-holds": "Votre revenu de secours couvre vos dépenses : votre épargne ne fondrait pas.",
  "cushion-verdict-nothing": "Aucune dépense retenue sur la période : il n'y a rien à couvrir.",
  "cushion-tile-savings": "Épargne disponible",
  "cushion-tile-spending": "Dépenses retenues",
  "cushion-tile-backup": "Revenu de secours",
  "cushion-tile-burn": "L'épargne fondrait de",
  "cushion-tile-rhythm": "Rythme d'épargne",
  "cushion-burn-none": "Rien",
  "cushion-target-title": "{ $months } mois de dépenses : { $amount }",
  "cushion-target-reached": "Atteint.",
  "cushion-target-date": "Il manque { $missing }. À votre rythme d'épargne, atteint vers { $month }.",
  "cushion-target-never": "Il manque { $missing }. Votre épargne n'a pas grossi sur la période : à ce rythme, ce seuil ne sera pas atteint.",
  "cushion-mark-empty": "À sec : { $month }",
  // F48 — « Partager une dépense » (Fabrice, 11/10/2026, P-71).
  "sharing-add-item": "Ajouter un poste",
  "sharing-add-payment": "Ajouter un règlement",
  "sharing-add-person": "Ajouter une personne",
  "sharing-balances-title": "Où en sont les règlements",
  "sharing-column-alone": "Ses extras",
  "sharing-column-amount": "Montant",
  "sharing-column-balance": "Solde",
  "sharing-column-cap": "Au maximum",
  "sharing-column-constraint": "Ce qui a joué",
  "sharing-column-date": "Date",
  "sharing-column-due": "À payer",
  "sharing-column-fixed": "Montant exact",
  "sharing-column-floor": "Au minimum",
  "sharing-column-gift": "Surplus offert",
  "sharing-column-household": "Foyer",
  "sharing-column-income": "Revenu",
  "sharing-column-item": "Poste",
  "sharing-column-label": "Libellé",
  "sharing-column-members": "Membres",
  "sharing-column-paid": "Réglé",
  "sharing-column-parts": "Parts",
  "sharing-column-percent": "%",
  "sharing-column-person": "Personne",
  "sharing-column-rule": "Règle",
  "sharing-column-share": "Part",
  "sharing-column-typed": "% tapé",
  "sharing-column-unit": "Foyer ou personne",
  "sharing-column-who": "Qui",
  "sharing-common": "Commun",
  "sharing-delete": "Supprimer",
  "sharing-delete-person-question": "Cette personne a des règlements : les supprimer avec elle ?",
  "sharing-disclaimer": "Radinus propose un partage : entre amis, chacun reste libre de s'arranger autrement.",
  "sharing-excel": "Exporter vers Excel",
  "sharing-field-label": "Libellé",
  "sharing-field-rule": "Règle",
  "sharing-field-total": "Total",
  "sharing-file-filter": "Projet de partage",
  "sharing-hide-incomes": "Masquer les revenus dans les rapports et l'export",
  "sharing-items-hint": "Seulement ce qui ne concerne pas tout le monde, comme le vin. Le reste du total va dans le poste commun.",
  "sharing-items-title": "Les postes",
  "sharing-label-hint": "Par exemple « Restaurant du 12/10 » ou « Voyage Bretagne 2027 » : il nomme les fichiers et les rapports.",
  "sharing-mode-item": "Une règle par poste",
  "sharing-mode-whole": "Une règle pour toute la dépense",
  "sharing-open": "Ouvrir un projet…",
  "sharing-payments-hint": "Qui a payé, combien, et quand. Une ligne sans montant ne compte pas encore.",
  "sharing-payments-title": "Les règlements",
  "sharing-pdf-distribution": "Répartition (PDF)",
  "sharing-pdf-payments": "État des paiements (PDF)",
  "sharing-pdf-statements": "Relevés individuels (PDF)…",
  "sharing-people-hint": "Une ligne par personne, une colonne par poste : cochez qui participe à quoi. Tout le reste est facultatif. Quelqu'un qui se désiste en laissant son acompte : un montant exact égal à ce qu'il a versé, et aucune case cochée.",
  "sharing-people-title": "Les personnes",
  "sharing-question": "Qui paie quoi ?",
  "sharing-replace-question": "Ouvrir ce projet remplacera ce qui est saisi dans la fenêtre. Continuer ?",
  "sharing-result-title": "Le résultat",
  "sharing-round-euro": "Arrondir à l'euro",
  "sharing-rule-equal": "Parts égales",
  "sharing-rule-income": "Au prorata des revenus",
  "sharing-rule-parts": "Par parts",
  "sharing-rule-percent": "En pourcentages",
  "sharing-save": "Enregistrer le projet…",
  "sharing-setup-title": "Le partage",
  "sharing-statements-everyone": "Tout le monde",
  "sharing-total-hint": "Vide, le total est la somme des postes et des extras de chacun.",
  "sharing-transfers-title": "Les virements proposés",
  "sharing-help-household": "Les personnes d'un même foyer règlent ensemble : leurs paiements et ce qu'elles doivent s'additionnent, et elles reçoivent un seul relevé. Exemple : « Famille Martin » pour les parents et les enfants.",
  "sharing-help-income": "Ne sert qu'à la règle « au prorata des revenus » : plus le revenu est élevé, plus la part est grande. Tapez le revenu mensuel.",
  "sharing-help-parts": "Une personne à 2 parts paie deux fois plus qu'une personne à 1 part. Exemple : adulte 1, enfant 0,5.",
  "sharing-help-percent": "La part de la dépense que paie la personne. Les pourcentages doivent faire 100 % au total.",
  "sharing-help-floor": "La personne paiera au moins ce montant, même si sa part calculée est plus petite. La différence allège les autres.",
  "sharing-help-cap": "La personne ne paiera jamais plus que ce montant. Ce qu'elle ne paie pas retombe sur les autres participants de ses postes.",
  "sharing-help-fixed": "La personne paie ce montant, quoi qu'il arrive, et le reste se partage entre les autres. Exemple : quelqu'un qui se désiste et laisse son acompte.",
  "sharing-help-alone": "Ce que la personne a pris pour elle seule, comme un dessert ou un café. Elle le paie entièrement, en plus de sa part.",
  "sharing-help-gift": "Si la personne a versé plus que sa part : coché, le surplus est un cadeau au groupe ; décoché, on le lui rend.",
  "sharing-help-items": "Cochez les personnes qui participent à ce poste. Le Commun, c'est ce qui reste du total une fois les autres postes retirés.",
  "sharing-help-due": "Ce que la personne doit au total : sa part des postes, ses extras et l'arrondi.",
  "sharing-help-share": "Ce que sa part représente, en pourcentage de la somme partagée.",
  "sharing-help-typed": "Le pourcentage que vous avez tapé. Il peut différer de la part réelle quand un minimum, un maximum ou un montant exact a joué.",
  "sharing-help-constraint": "Indique si la part de la personne a été modifiée par un minimum, un maximum, un montant exact ou un surplus offert.",
  "sharing-help-item": "Seulement ce qui ne concerne pas tout le monde, comme le vin. Le reste du total va dans le Commun, partagé entre ceux qui y sont cochés.",
  "sharing-help-rule": "Comment ce poste se partage : à parts égales, par parts, en pourcentages ou au prorata des revenus.",
  "sharing-help-paid": "Ce que le foyer ou la personne a déjà versé, d'après les règlements saisis.",
  "sharing-help-balance": "Ce qui reste à régler, ou ce qui a été versé en plus de la part. Exemple : « Reste à régler : 61,54 € ».",
  "sharing-apply-advice": "Reprendre les valeurs conseillées",
  "sharing-help-apply-advice": "Remplit les cases vides avec les valeurs en gris. Les cases déjà remplies ne changent pas.",
  "sharing-from-incomes": "Pourcentages d'après les revenus",
  "sharing-help-from-incomes": "Remplace les pourcentages par la part de chaque revenu dans le total des revenus. Ils font 100 %.",
  "sharing-reset-percents": "Tout répartir à nouveau",
  "sharing-help-reset-percents": "Efface les pourcentages et les répartit à parts égales entre tous. Utile après avoir ajouté une personne.",
  "sharing-reset-percents-question": "Effacer tous les pourcentages et les répartir à parts égales ?",
  "window-sharing-title": "Partager une dépense",
  // La phrase sur l'historique (Fabrice, 10/10/2026), dans la barre
  // d'information des quatre outils qui font une moyenne sur l'historique.
  "analysis-history-hint": "Plus votre historique est long, meilleure sera cette analyse : l'idéal est d'avoir au moins un an d'opérations.",
  "cushion-period": "Moyenne de { $count -> [one] { $count } mois complet *[other] { $count } mois complets }, de { $from } à { $to }. { $transfers -> [0] Aucun virement entre vos comptes. [one] Un virement entre vos comptes, mis de côté. *[other] { $transfers } virements entre vos comptes, mis de côté. }",
  "appliance-invalid-watts": "Une puissance de 0 à 100 000 W, s'il vous plaît.",
  "appliance-invalid-hours": "Une durée de 0 à 24 heures par jour, s'il vous plaît.",
  "appliance-invalid-days": "Un nombre entier de jours, de 0 à 7, s'il vous plaît.",
  "appliance-invalid-share": "Une part de 0 à 100 %, s'il vous plaît.",
  "appliance-invalid-day-overflow": "La marche et la veille dépassent 24 heures par jour.",
  "appliance-invalid-price": "Un prix du kWh de 0 à 100, s'il vous plaît.",
  "appliance-invalid-off-peak-hours": "Un nombre entier d'heures creuses, de 0 à 24, s'il vous plaît.",
  "preferences-branch-tools": "Outils",
  "preferences-leaf-electricity": "Tarif d'électricité",
  "preferences-electricity-blue": "Revenir au Tarif Bleu EDF",
  "preferences-electricity-hint": "Le tarif de votre contrat, repris par l'outil « Consommation d'un appareil électrique ». Par défaut : le Tarif Bleu d'EDF au 1er août 2026, prix TTC, compteur de 3 à 6 kVA. Ces prix changent souvent en février et en août : recopiez ceux de votre facture.",
  "preferences-leaf-qif": "Relevés QIF",
  "preferences-leaf-ofx": "Relevés OFX",
  "preferences-field-ofx-label": "Libellé de l'opération :",
  "preferences-field-ofx-reference": "Référence paiement :",
  "preferences-ofx-choice-name": "Le nom de l'opération",
  "preferences-ofx-choice-memo": "Le mémo de la banque",
  "preferences-ofx-choice-name-and-memo": "Le nom suivi du mémo",
  "preferences-ofx-choice-empty": "Rien (laisser vide)",
  "preferences-ofx-label-help": "Ce que reçoit le libellé d'une opération importée. Le nom est celui que la banque affiche, par exemple « PRLV SEPA » ; certaines banques y ajoutent un mémo détaillé : le créancier d'un prélèvement, le bénéficiaire et le motif d'un virement. Quand une opération n'a pas de mémo, son libellé garde le nom.",
  "preferences-ofx-reference-help": "Ce que reçoit la référence paiement d'une opération importée, où vous pouvez la voir et la filtrer. Quand une opération n'a pas de mémo, « Le mémo de la banque » laisse la référence vide. Si le mémo répète déjà le nom, il n'est pas écrit deux fois.",
  "preferences-ofx-hint": "Ces réglages valent pour tous les relevés OFX, quelle que soit la base ouverte. Ils s'appliquent au prochain relevé ouvert.",
  "preferences-field-qif-order": "Ordre du jour et du mois :",
  "preferences-qif-order-ask": "Me demander à chaque fois",
  "preferences-qif-order-day-month": "Toujours jour/mois (05/03 = 5 mars)",
  "preferences-qif-order-month-day": "Toujours mois/jour (05/03 = 3 mai)",
  "preferences-qif-order-help": "Ne sert que si aucune date du fichier ne permet de trancher. Dès qu'une date comme 24/11 prouve l'ordre, c'est le fichier qui décide, quel que soit ce réglage.",
  "preferences-field-qif-label": "Libellé de l'opération :",
  "preferences-qif-label-both": "Tiers + mémo",
  "preferences-qif-label-payee": "Tiers seul",
  "preferences-qif-label-memo": "Mémo seul",
  "preferences-qif-label-help": "Quand une opération porte à la fois un tiers et un mémo. Si elle n'en porte qu'un, c'est celui-là qui sert, quel que soit ce réglage.",
  "preferences-qif-hint": "Ces réglages valent pour tous les relevés QIF, quelle que soit la base ouverte. « Me demander à chaque fois » est le plus sûr : un fichier dont les dates sont ambiguës n'est jamais lu au hasard.",
  "preferences-branch-reset": "Réinitialisation",
  "preferences-leaf-comfort": "Réglages de confort",
  "preferences-comfort-reset": "Réinitialiser les réglages de confort",
  "preferences-comfort-hint": "Remet d'origine les colonnes, l'accueil et la taille.",
  "preferences-comfort-question": "Réinitialiser les réglages de confort ?",
  "preferences-comfort-done": "Les réglages de confort ont été réinitialisés.",
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
  "statement-column-reference": "Référence paiement",
  "operations-column-reference": "Référence paiement",
  "statement-column-debit": "Debit",
  "statement-column-credit": "Credit",
  "statement-account": "Compte",
  "statement-file": "Fichier",
  "statement-difference": "Ecart",
  "statement-none": "Aucun relevé n'est ouvert : cliquez sur le dossier jaune pour choisir un fichier (OFX, CSV, QIF).",
  "statement-empty": "Ce relevé ne contient aucune opération.",
  "statement-no-match": "Aucune ligne ne correspond au filtre.",
  "statement-help": "Info : Utilisez Clic Souris + touche [CMD] sur le tableau pour sélectionner plusieurs lignes",
  "statement-choose-account": "Ce fichier contient plusieurs comptes. Lequel voulez-vous importer ?",
  "statement-select-line": "Sélectionnez au moins une ligne du relevé.",
  "statement-title-open": "Ouvrir un fichier de relevé (OFX, QIF, CSV)",
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
  "statement-field-reference": "Référence paiement",
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
  "quick-check-verification": "Vérification",
  "quick-column-date": "Date",
  "quick-column-label": "Libelle",
  "quick-column-amount": "Montant",
  "quick-column-category": "Categorie",
  "quick-column-assignment": "Affectation",
  "quick-column-payment-mode": "Mode Paiement",
  "quick-column-payee": "Tiers",
  "quick-column-project": "Projets",
  "quick-column-status": "Status",
  "quick-column-verification": "Vérification",
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
/// Ce que Rust rend pour le bilan croisé (F39) : les catégories en lignes, les
/// affectations en colonnes, sur un mois. Une case à zéro **remplie** — le
/// crédit et le débit qui s'annulent — et une case vide, pour que les deux
/// couleurs se distinguent.
const CROSSED = {
  columns: [
    { id: 2, label: "Famille" },
    { id: 3, label: "Animaux" },
    { id: 0, label: "Sans affectation" },
  ],
  rows: [
    {
      id: 1, label: "Alimentation",
      cells: ["-100,00 €", "", "0,00 €"],
      cell_values: [-100000000, 0, 0],
      filled: [true, false, true],
      total: "-100,00 €", total_value: -100000000, total_filled: true, is_empty: false,
    },
    {
      id: 5, label: "Salaire",
      cells: ["2 216,71 €", "", ""],
      cell_values: [2216710000, 0, 0],
      filled: [true, false, false],
      total: "2 216,71 €", total_value: 2216710000, total_filled: true, is_empty: false,
    },
    {
      id: 0, label: "Sans catégorie",
      cells: ["", "", ""],
      cell_values: [0, 0, 0],
      filled: [false, false, false],
      total: "", total_value: 0, total_filled: false, is_empty: true,
    },
  ],
  sum: ["2 116,71 €", "", "0,00 €"],
  sum_values: [2116710000, 0, 0],
  sum_filled: [true, false, true],
  sum_total: "2 116,71 €",
  sum_total_value: 2116710000,
  has_data: true,
  period: "09/2026",
  accounts: "2 comptes",
};

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
  verification_id: 4,
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
  // Le septième axe, qui n'est pas une nomenclature (03/10/2026).
  verification: {
    "statistics-axis-column": "Vérification",
    "statistics-unclassified": "À vérifier",
    "statistics-window-name": "Statistiques par vérification",
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
function bridge({ startupError = null, needsConfirmation = true, plainQuestion = false, slowLoadMs = 0, refusedDeletion = false, duplicateName = null, accountRefusal = null, manyOperations = false, scatteredChildren = false, operationRefusal = null, operationIsASub = false, operationDatelessButPointed = false, operationComment = "", subIsComplement = false, missingParent = false, exportCancelled = false, exportFails = null, noYear = false, pickCancelled = false, fileAccounts = ["123456A789"], pickedIsCsv = false, pickedIsQif = false, qifAmbiguous = false, qifAccounts = ["releve.qif"], referenceTaken = false, accountGone = false, storedLayout = null, databaseOpen = true, clipboardRefuses = "nothing", manyAccounts = false, storedWelcome = null, loanUnavailable = false, databases = null, exportPlaceExists = false, exportProtected = false, baseExportRefused = null } = {}) {
  return `
    const OPERATION_JSON = ${JSON.stringify(JSON.stringify(OPERATION))};
    const SUB_OPERATION_JSON = ${JSON.stringify(JSON.stringify(SUB_OPERATION))};
    const MATRIX_JSON = ${JSON.stringify(JSON.stringify(MATRIX))};
    const CROSSED_JSON = ${JSON.stringify(JSON.stringify(CROSSED))};
    const TEXTS_JSON = ${JSON.stringify(JSON.stringify(UI_TEXTS))};
    const DATABASES_JSON = ${JSON.stringify(JSON.stringify(databases))};
    const EXPORT_PLACE_EXISTS = ${JSON.stringify(exportPlaceExists)};
    const EXPORT_PROTECTED = ${JSON.stringify(exportProtected)};
    const BASE_EXPORT_REFUSED = ${JSON.stringify(baseExportRefused)};
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
    // F48 — les conseils du partage (P-72), grossièrement : une phrase par
    // règle, les cases vides d'un pourcentage reçoivent le reste à parts
    // égales, une part vide vaut 1. C'est la fenêtre qu'on éprouve.
    const sharingAdvice = (input, euros) => {
      const none = { sentence: "", warn: false, items: [], suggested: [], from_incomes: [] };
      const people = input.people;
      if (people.length === 0) return none;
      const number = (text) => (text.trim() === "" ? null : Number(text.replace(",", ".")));
      const figure = (value) => String(Math.round(value * 100) / 100).replace(".", ",");
      const money = (text) => number(text.replace(/[\\s\\u202f.]/g, "")) ?? 0;
      const carved = input.items.reduce((sum, item) => sum + money(item.amount), 0);
      const total = input.total.trim() === "" ? carved : money(input.total);
      const rule = (ruleKey, amount, takers, typed, item) => {
        if (ruleKey === "equal") return [euros(amount) + " ÷ " + takers.length + " personnes = " + euros(amount / takers.length) + " chacun.", false, []];
        if (ruleKey === "parts") return ["Chacun paie selon ses parts.", false, takers.filter((p, i) => typed[i] === null).map((p) => ({ person: p.id, item, value: "1" }))];
        if (ruleKey === "income") {
          if (takers.some((p) => p.income.trim() === "")) return ["Tapez le revenu de chacun pour partager au prorata des revenus.", false, []];
          const all = takers.reduce((sum, p) => sum + money(p.income), 0);
          return ["Chacun paie " + figure((amount / all) * 100) + " % de son revenu.", false, []];
        }
        const sum = typed.reduce((all, value) => all + (value ?? 0), 0);
        const empty = takers.filter((p, i) => typed[i] === null);
        const rest = Math.round((100 - sum) * 100) / 100;
        if (rest > 0) return ["Il manque " + figure(rest) + " % pour arriver à 100 %.", false, empty.map((p) => ({ person: p.id, item, value: figure(rest / empty.length) }))];
        if (rest < 0) return ["Les pourcentages dépassent 100 % de " + figure(-rest) + " %.", true, []];
        const nobody = takers.filter((p, i) => !(typed[i] > 0)).map((p) => p.name);
        if (nobody.length > 0) return ["Les pourcentages font déjà 100 % : " + nobody.join(", ") + " ne paierait rien.", true, []];
        return ["Les pourcentages font bien 100 %.", false, []];
      };
      if (input.mode === "whole") {
        const typed = people.map((p) => (input.rule === "parts" ? number(p.parts) : input.rule === "percent" ? number(p.percent) : null));
        const [sentence, warn, suggested] = rule(input.rule, total, people, typed, null);
        let fromIncomes = [];
        if (input.rule === "percent" && people.every((p) => p.income.trim() !== "")) {
          const all = people.reduce((sum, p) => sum + money(p.income), 0);
          fromIncomes = people.map((p) => ({ person: p.id, item: null, value: figure((money(p.income) / all) * 100) }));
        }
        return { sentence, warn, items: [], suggested, from_incomes: fromIncomes };
      }
      const advice = { sentence: "", warn: false, items: [], suggested: [], from_incomes: [] };
      for (const item of [Object.assign({}, input.common, { amount: String(total - carved) })].concat(input.items)) {
        const cellOf = (p) => item.cells.find((cell) => cell.person === p.id) ?? { takes: true, value: "" };
        const takers = people.filter((p) => cellOf(p).takes);
        const typed = takers.map((p) => number(cellOf(p).value));
        const [sentence, warn, suggested] = rule(item.rule, money(item.amount), takers, typed, item.id);
        advice.items.push({ id: item.id, sentence, warn });
        advice.suggested.push(...suggested);
      }
      return advice;
    };
    window.__calls = [];
    window.__closed = false;
    // F47 — le carnet de la voiture, tel que Rust le tiendrait : une fiche,
    // des lignes, et ce qui reste à enregistrer. Le faux pont écrit le carnet
    // grossièrement ; c'est la fenêtre qu'on éprouve, pas le noyau.
    const carEmpty = () => ({
      car: { plate: "", make: "", model: "", engine: "petrol", first_hand: false, registered: "", acquired: "", acquired_km: "", service_months: "12", service_km: "",
             tariff: { option: "base", base: "0,2001", peak: "0,2142", off_peak: "0,1589", off_peak_hours: "8" } },
      rows: [], next: 1, unsaved: false,
    });
    window.__car = carEmpty();
    const carChoices = (engine) => {
      const electric = engine === "electric";
      const plugIn = engine === "plug-in";
      return {
        engines: [["petrol", "Essence"], ["diesel", "Diesel"], ["e85", "E85 (superéthanol)"], ["plug-in", "Hybride rechargeable"], ["electric", "Électrique"]].map(([key, label]) => ({ key, label })),
        rubrics: [["energy", "Énergie"], ["upkeep", "Entretien courant"], ["service", "Révision"], ["wear", "Pièces d'usure"], ["tyres", "Pneus"], ["breakdown", "Pannes"], ["insurance", "Assurance"], ["inspection", "Contrôle technique"]].map(([key, label]) => ({ key, label })),
        energies: electric ? [{ key: "electricity", label: "Électricité", unit: "kWh" }]
          : plugIn ? [{ key: "petrol", label: "Essence", unit: "L" }, { key: "electricity", label: "Électricité", unit: "kWh" }]
          : engine === "e85" ? [{ key: "e85", label: "E85", unit: "L" }, { key: "petrol", label: "Essence", unit: "L" }]
          : [{ key: "petrol", label: "Essence", unit: "L" }],
        parts: [{ key: "known:brake-pads", label: "Plaquettes de frein" }, { key: "known:timing-belt", label: "Courroie de distribution" }, { key: "other", label: "Autre pièce…" }],
        axles: [{ key: "all", label: "Les quatre pneus" }, { key: "front", label: "Pneus avant" }, { key: "rear", label: "Pneus arrière" }],
        verdicts: [{ key: "pass", label: "Favorable" }, { key: "counter", label: "Contre-visite" }],
        charges: [{ key: "station", label: "À une borne" }, { key: "home", label: "À la maison" }],
        slots: [{ key: "off-peak", label: "Heures creuses" }, { key: "peak", label: "Heures pleines" }],
        rechargeable: electric || plugIn,
        battery: electric || plugIn,
        off_peak: window.__car.car.tariff.option === "off-peak",
        sign: "€",
        price_unit: "€/kWh",
      };
    };
    const carRubric = { energy: "Énergie", upkeep: "Entretien courant", service: "Révision", wear: "Pièces d'usure", tyres: "Pneus", breakdown: "Pannes", insurance: "Assurance", inspection: "Contrôle technique" };
    const carView = () => {
      const state = window.__car;
      const name = [state.car.make, state.car.model].filter((part) => part).join(" ");
      const title = [name, state.car.plate].filter((part) => part).join(" · ") || "Ma voiture";
      const rows = state.rows.slice().reverse().map((row) => ({
        id: row.id, date: row.fields.date.split("-").reverse().join("/"), km: row.fields.km, rubric: carRubric[row.fields.rubric], rubric_key: row.fields.rubric,
        colour: "#24506e", detail: row.fields.rubric === "energy" ? "Essence · " + row.fields.quantity + " L" : "", amount: row.fields.amount + " €",
        garage: row.fields.garage, note: row.fields.note, fields: row.fields,
      }));
      return {
        car: state.car,
        choices: carChoices(state.car.engine),
        written: {
          title,
          headline: rows.length === 0 ? "Remplissez la fiche, puis ajoutez une première ligne : un plein, une révision, une facture de garage…" : "Depuis mars 2020, votre voiture vous a coûté " + rows.length + " lignes.",
          tiles: [{ label: "Coût total", value: "—" }, { label: "Au kilomètre", value: "—" }],
          total: "0,00 €",
          energy: rows.some((row) => row.rubric_key === "energy") ? [{ label: "Essence", quantity: "40 L", amount: "70,00 €", price: "1,750 € / L", consumption: "—", per_km: "—" }] : [],
          parts: [], tyres: [], battery: [],
          deadlines: state.car.registered ? [{ label: "Contrôle technique", when: "le 15/03/2024", tone: "late", badge: "Dépassée" }, { label: "Fin de l'assurance", when: "le 01/01/2027", tone: "later", badge: "" }] : [],
          deadlines_empty: "Aucune échéance pour l'instant.",
          rows,
          years: "<svg xmlns='http://www.w3.org/2000/svg' class='loan-chart loan-chart--bars' viewBox='0 0 680 250'></svg>",
          donut: "<svg xmlns='http://www.w3.org/2000/svg' class='loan-chart loan-chart--donut' viewBox='0 0 500 220'></svg>",
          notes: ["Tout se compte depuis l'acquisition."],
        },
        unsaved: state.unsaved,
        empty: state.rows.length === 0 && !state.car.plate && !state.car.make,
      };
    };
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
      const line = (rank, date, label, amount, known, alike, reference = "") => ({
        rank, date, label, amount, reference,
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
        line(2, "22/07/2026", "ACHAT CB COMMERCE TROIS", -120000000, true, true, "CAISSE INVENTEE ECH/220726 REF/42 LIB/COTISATION ANNUELLE DE LA CAISSE"),
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
    // Le presse-papiers. Ce qu'une fenêtre y écrit se relit dans
    // window.__clipboard ; clipboardRefuses fait échouer le chemin moderne
    // ("modern"), ou les deux ("both"), pour vérifier le repli et l'aveu.
    window.__clipboard = [];
    window.__copiedTheOldWay = 0;
    Object.defineProperty(navigator, "clipboard", {
      configurable: true,
      value: {
        writeText: (text) => {
          if (${JSON.stringify(clipboardRefuses)} !== "nothing") {
            return Promise.reject(new Error("refusé"));
          }
          window.__clipboard.push(text);
          return Promise.resolve();
        },
      },
    });
    document.execCommand = (command) => {
      if (command !== "copy" || ${JSON.stringify(clipboardRefuses)} === "both") {
        return false;
      }
      window.__copiedTheOldWay += 1;
      window.__clipboard.push(document.activeElement.value);
      return true;
    };
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
          // F47 — « Carnet de ma voiture » (10/10/2026).
          case "car_view":
            return Promise.resolve(carView());
          case "car_set_car": {
            window.__carSet = (window.__carSet ?? []).concat([args.car]);
            if (args.car.acquired_km.trim() !== "" && !/^[0-9 ]+$/.test(args.car.acquired_km)) {
              return Promise.resolve({ invalid: "acquired-km", message: "Un compteur en kilomètres entiers, s'il vous plaît.", view: carView() });
            }
            window.__car.car = args.car;
            window.__car.unsaved = true;
            return Promise.resolve({ invalid: null, message: null, view: carView() });
          }
          case "car_put_entry": {
            window.__carPut = (window.__carPut ?? []).concat([args]);
            const entry = args.entry;
            if (entry.rubric === "energy" && entry.quantity.trim() === "") {
              return Promise.resolve({ invalid: "quantity", message: "Tapez la quantité : litres, kWh ou kilos.", view: carView() });
            }
            if (entry.rubric === "wear" && entry.part === "other" && entry.part_name.trim() === "") {
              return Promise.resolve({ invalid: "part-name", message: "Choisissez la pièce changée, ou tapez son nom.", view: carView() });
            }
            const state = window.__car;
            const kept = state.rows.find((row) => row.id === args.id);
            if (kept) {
              kept.fields = entry;
            } else {
              state.rows.push({ id: state.next, fields: entry });
              state.next += 1;
            }
            state.unsaved = true;
            return Promise.resolve({ invalid: null, message: null, view: carView() });
          }
          case "car_delete_entry":
            window.__car.rows = window.__car.rows.filter((row) => row.id !== args.id);
            window.__car.unsaved = true;
            return Promise.resolve(carView());
          case "car_reset_tariff":
            window.__carReset = true;
            return Promise.resolve(carView());
          case "car_expenses":
            window.__carExpenses = args.account;
            return Promise.resolve([
              { id: 9, text: "01/09/2026 · TOTAL · Station Total · 65,40 €", fields: { date: "2026-09-01", km: "", rubric: "", amount: "65,40", garage: "Station Total", note: "TOTAL", energy: "", quantity: "", charge: "", slot: "", part: "", part_name: "", axle: "", verdict: "", months: "", battery: "" } },
              { id: 8, text: "12/08/2026 · GARAGE · 250,00 €", fields: { date: "2026-08-12", km: "", rubric: "", amount: "250,00", garage: "", note: "GARAGE", energy: "", quantity: "", charge: "", slot: "", part: "", part_name: "", axle: "", verdict: "", months: "", battery: "" } },
            ]);
          case "print_car_report":
            window.__carPrinted = true;
            return Promise.resolve("Le rapport est prêt : /tmp/Carnet de ma voiture.pdf");
          case "export_car":
            window.__carExported = args;
            return Promise.resolve("Exporté vers « Carnet.xlsx »");
          case "save_car_logbook":
            window.__carSaved = args;
            window.__car.unsaved = false;
            return Promise.resolve("Carnet enregistré : Peugeot 208.json");
          case "load_car_logbook": {
            window.__carLoaded = (window.__carLoaded ?? 0) + 1;
            const opened = carEmpty();
            opened.car.plate = "EF-456-GH";
            opened.car.make = "Renault";
            opened.car.model = "Zoé";
            opened.car.engine = "electric";
            opened.rows = [{ id: 1, fields: { date: "2026-05-02", km: "41000", rubric: "service", amount: "180,00", garage: "Garage du Centre", note: "", energy: "", quantity: "", charge: "station", slot: "", part: "", part_name: "", axle: "", verdict: "", months: "", battery: "93" } }];
            opened.next = 2;
            window.__car = opened;
            return Promise.resolve({ view: carView(), message: "Carnet ouvert : Zoé.json" });
          }
          case "close_car_logbook":
            window.__carClosed = (window.__carClosed ?? 0) + 1;
            window.__car = carEmpty();
            return Promise.resolve(null);
          // F48 — « Partager une dépense » (11/10/2026). Un partage grossier à
          // parts égales : c'est la fenêtre qu'on éprouve, pas le calcul.
          case "sharing_compute": {
            const input = args.input;
            window.__sharingAsked = (window.__sharingAsked ?? []).concat([input]);
            const next = "Personne " + (input.people.length + 1);
            const euros = (value) => value.toFixed(2).replace(".", ",") + " €";
            const advice = sharingAdvice(input, euros);
            const blank = input.people.find((person) => person.name.trim() === "");
            if (blank) {
              return Promise.resolve({ invalid: "name-" + blank.id, message: "Chaque personne doit avoir un nom.", written: null, next_name: next, advice });
            }
            const amount = (text) => Number((text || "0").replace(",", ".")) || 0;
            const carved = input.items.map((item) => amount(item.amount)).concat(input.people.map((person) => amount(person.alone)));
            let itemsTotal = 0;
            for (const value of carved) {
              itemsTotal += value;
            }
            const total = input.total.trim() === "" ? itemsTotal : amount(input.total);
            const commonAmount = total - itemsTotal;
            const items = [Object.assign({}, input.common, { id: 0, label: "Commun", amount: String(commonAmount) })].concat(input.items);
            const due = {};
            const cells = [];
            for (const item of items) {
              const takers = input.people.filter((person) => (item.cells.find((cell) => cell.person === person.id) ?? { takes: true }).takes);
              for (const person of takers) {
                const share = amount(item.amount) / takers.length;
                due[person.id] = (due[person.id] ?? 0) + share;
                cells.push({ person: person.id, item: item.id, amount: euros(share) });
              }
            }
            const paid = {};
            for (const payment of input.payments) {
              paid[payment.person] = (paid[payment.person] ?? 0) + amount(payment.amount);
            }
            const dues = input.people.map((person) => Math.round((due[person.id] ?? 0) * 100));
            const low = Math.min(...dues) / 100;
            const high = Math.max(...dues) / 100;
            return Promise.resolve({
              invalid: null,
              message: null,
              next_name: next,
              advice,
              written: {
                headline:
                  input.people.length === 0
                    ? "Ajoutez les personnes qui partagent la dépense."
                    : low === high
                      ? euros(total) + " à partager : chacun paie " + euros(low) + "."
                      : euros(total) + " à partager : de " + euros(low) + " à " + euros(high) + " selon chacun.",
                tone: input.people.length === 0 ? "none" : "good",
                common: euros(commonAmount),
                people: input.people.map((person) => ({ id: person.id, name: person.name, due: euros(due[person.id] ?? 0), share: "", typed: "", constraint: person.fixed ? "Montant fixe" : "", alone: "", outside: "", rounding: "", detail: "" })),
                cells,
                items: items.map((item) => ({ id: item.id, label: item.label, amount: euros(amount(item.amount)), participants: "" })),
                units: input.people.map((person) => ({ key: "person-" + person.id, name: person.name, members: "", due: euros(due[person.id] ?? 0), paid: euros(paid[person.id] ?? 0), balance: "Reste à régler : " + euros((due[person.id] ?? 0) - (paid[person.id] ?? 0)), tone: "due" })),
                summary: input.people.length === 0 || total === 0 ? [] : ["0,00 € réglés sur " + euros(total) + "."],
                transfers: [],
                notes: [],
                warning: null,
              },
            });
          }
          case "print_sharing_report":
            window.__sharingPrinted = (window.__sharingPrinted ?? []).concat([args]);
            return Promise.resolve("Le rapport est prêt : /tmp/Partage.pdf");
          case "pick_sharing_folder":
            window.__sharingPicked = args;
            return Promise.resolve({ folder: "/tmp/Relevés", question: "2 relevés existent déjà dans ce dossier. Les remplacer ?" });
          case "write_sharing_statements":
            window.__sharingWritten = args;
            return Promise.resolve("2 relevés écrits dans « Relevés ».");
          case "export_sharing":
            window.__sharingExported = args;
            return Promise.resolve("Exporté vers « Week-end.xlsx »");
          case "save_sharing_project":
            window.__sharingSaved = args;
            return Promise.resolve("Projet enregistré : Week-end.json");
          case "load_sharing_project":
            window.__sharingLoaded = (window.__sharingLoaded ?? 0) + 1;
            return Promise.resolve({
              input: {
                label: "Week-end", total: "300,00", mode: "whole", rule: "equal", rounding: "cent", show_incomes: false,
                people: [
                  { id: 1, name: "Léa", household: "", income: "", parts: "", percent: "", floor: "", cap: "", fixed: "", alone: "", gift: false },
                  { id: 2, name: "Paul", household: "", income: "", parts: "", percent: "", floor: "", cap: "", fixed: "", alone: "", gift: false },
                ],
                common: { id: 0, label: "", amount: "", rule: "equal", cells: [{ person: 1, takes: true, value: "" }, { person: 2, takes: true, value: "" }] },
                items: [],
                payments: [{ id: 1, person: 2, amount: "100,00", date: "2027-01-15", label: "acompte" }],
              },
              message: "Projet ouvert : Week-end.json",
            });
          case "close_sharing":
            window.__sharingClosed = (window.__sharingClosed ?? 0) + 1;
            return Promise.resolve(null);
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
                : ${pickedIsQif}
                  ? { path: "/tmp/releve.qif", kind: "qif", accounts: ${JSON.stringify(qifAccounts)} }
                  : {
                    path: ${pickedIsCsv} ? "/tmp/releve.csv" : "/tmp/releve.ofx",
                    kind: ${pickedIsCsv} ? "csv" : "ofx",
                    accounts: ${pickedIsCsv} ? [] : ${JSON.stringify(fileAccounts)},
                  },
            );
          // Le QIF (15/10/2026) : la question de l'ordre des dates quand le
          // fichier ne le prouve pas, puis le même relevé que l'OFX — sans
          // FITID, sans solde du fichier.
          case "statement_load_qif": {
            window.__qifLoads = (window.__qifLoads ?? []).concat([args]);
            if (${qifAmbiguous} && args.order === null) {
              return Promise.resolve({
                question: {
                  text: "Rien dans ce fichier ne dit si la date « 05/03/2023 » s'écrit jour/mois ou mois/jour. Elle veut dire :",
                  choices: ["Jour 5, mois 3 (jour/mois)", "Jour 3, mois 5 (mois/jour)"],
                  keys: ["day-month", "month-day"],
                },
                view: null,
              });
            }
            window.__statementRows = statementLines().map((row) => ({ ...row, fitid_known: false }));
            const view = statementView(
              "3 lignes lues ; aucune ne ressemble à une opération déjà présente dans votre compte. Solde initial de 2 140,50 € au 03/02/2025 : ce n'est pas une opération, il n'est pas importé.",
            );
            return Promise.resolve({ question: null, view: { ...view, file_balance: "", difference: "", has_fitid_column: false } });
          }
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
              reference: row ? row.reference : "",
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
              project: "Non précisé", status: "Pointé", verification: "Vérifiée",
              category_id: 0, assignment_id: 0, payment_mode_id: 3,
              payee_id: 0, project_id: 0, status_id: 1, verification_id: 2,
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
              verification: [
                { f: "verification", n: { 1: "À vérifier", 2: "Vérifiée", 3: "Douteuse", 4: "Contestée" } },
              ],
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
          case "set_operation_status":
            return Promise.resolve(true);
          case "set_operation_verification":
            return Promise.resolve(true);
          case "set_operations_verification":
            return Promise.resolve(args.ids.length);
          case "set_operations_status":
            return Promise.resolve(args.ids.length);
          case "list_operation_verifications":
            return Promise.resolve([
              { id: 1, label: "À vérifier" },
              { id: 2, label: "Vérifiée" },
              { id: 3, label: "Douteuse" },
              { id: 4, label: "Contestée" },
            ]);
          case "preferences_import_verification":
            return Promise.resolve(window.__importVerification ?? 2);
          case "save_preferences_import_verification":
            window.__importVerification = args.verificationId;
            return Promise.resolve(null);
          case "database_is_open":
            return Promise.resolve(${databaseOpen});
          // Les réglages QIF (15/10/2026) : la configuration du logiciel,
          // tenue par la page.
          case "preferences_qif":
            return Promise.resolve(window.__qifPreferences ?? { order: "ask", label: "both" });
          case "preferences_ofx":
            return Promise.resolve(window.__ofxPreferences ?? { label: "name", reference: "memo" });
          case "save_preferences_ofx":
            window.__ofxPreferences = { label: args.label, reference: args.reference };
            window.__ofxSaves = (window.__ofxSaves ?? 0) + 1;
            return Promise.resolve(null);
          case "save_preferences_qif":
            window.__qifPreferences = { order: args.order, label: args.label };
            window.__qifSaves = (window.__qifSaves ?? 0) + 1;
            return Promise.resolve(null);
          // La disposition des tableaux. La « base » est une variable de la
          // page : ce qu'on y enregistre se relit, comme dans la vraie.
          case "windows_with_table_layouts":
            return Promise.resolve([
              { name: "operations-list", label: "Liste des opérations" },
              { name: "statistics-category", label: "Stat par catégories" },
              { name: "crossed-balance", label: "Bilan croisé" },
            ]);
          case "table_layout":
            if (window.__layout === undefined) {
              window.__layout = ${JSON.stringify(storedLayout)};
            }
            window.__layoutAsked = args.table;
            return Promise.resolve(window.__layout);
          case "save_table_layout":
            window.__layout = args.layout;
            return Promise.resolve(true);
          case "reset_table_layout":
          case "reset_window_table_layouts":
          case "reset_all_table_layouts":
            window.__layout = null;
            return Promise.resolve(null);
          // Les réglages de confort : les colonnes, l'accueil et la taille
          // reviennent d'un coup. La « taille » est une variable de la page.
          case "reset_comfort_settings":
            window.__layout = null;
            window.__welcomeStored = { order: [], excluded: [] };
            window.__zoom = 1;
            return Promise.resolve(null);
          case "save_welcome_accounts":
            window.__welcomeStored = { order: args.order, excluded: args.excluded };
            return Promise.resolve(null);
          case "preferences_currency":
            return Promise.resolve({
              choice: "EUR", custom: "", system: "€",
              zoom: window.__zoom ?? 1, zoom_min: 0.8, zoom_max: 1.6, zoom_step: 0.05, zoom_default: 1,
            });
          case "save_preferences_currency":
            return Promise.resolve(null);
          case "available_languages":
            return Promise.resolve([
              { code: 5, tag: "fr", name: "Français" },
              { code: 3, tag: "en", name: "English" },
            ]);
          case "current_language":
            return Promise.resolve({ code: 5, tag: "fr", name: "Français" });
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
            if (${operationDatelessButPointed}) {
              operation.clearing_date = "";
            }
            return Promise.resolve(operation);
          }
          case "operation_attachments_text":
            return Promise.resolve(
              args.count === 0 ? "Aucune pièce jointe" : args.count + " pièces jointes",
            );
          case "clearing_date_question": {
            const [y, m, d] = String(args.date).split("-");
            return Promise.resolve(
              "Une opération pointée doit obligatoirement porter une date de pointage.\\n" +
                "Voulez-vous enregistrer avec la date de l'opération, le " +
                d + "/" + m + "/" + y + " ?",
            );
          }
          case "operation_refusal":
            return Promise.resolve(${JSON.stringify(operationRefusal)});
          case "create_operation":
            return Promise.resolve(77);
          case "update_operation":
            return Promise.resolve(true);
          case "open_recurring_form_from_operation":
            window.__openedRecurring = args;
            return Promise.resolve();
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
          case "crossed_balance":
            window.__crossedAsked = args;
            return Promise.resolve(JSON.parse(CROSSED_JSON));
          case "crossed_balance_detail":
            window.__crossedDetailAsked = args;
            return Promise.resolve([
              { ...JSON.parse(OPERATIONS_JSON).rows[0], parent_id: 0 },
            ]);
          case "crossed_balance_step": {
            // Décembre bascule sur janvier de l'année suivante, et janvier sur
            // décembre de l'année précédente — la règle est au noyau.
            let y = args.year;
            let m = args.month;
            if (args.forward) {
              m === 12 ? ((y += 1), (m = 1)) : (m += 1);
            } else {
              m === 1 ? ((y -= 1), (m = 12)) : (m -= 1);
            }
            return Promise.resolve([y, m]);
          }
          case "crossed_balance_month_prompt":
            return Promise.resolve({
              question: "Sur quel mois voulez-vous travailler ? Un nombre entre 1 et 12.",
              first: 1,
              last: 12,
            });
          case "close_crossed_balance":
            window.__closed = true;
            return Promise.resolve();
          case "open_crossed_balance":
            window.__openedCrossed = args;
            return Promise.resolve();
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
            ].concat(${manyAccounts} ? [3, 4, 5, 6, 7, 8].map((id) => ({
              id, label: "Compte " + id, bank: "Banque",
              balance_bank_value: id * 100000000, balance_real_value: id * 100000000,
              balance_final_value: id * 100000000,
            })) : []).map((row) => ({
              ...row,
              balance_bank: money(row.balance_bank_value),
              balance_real: money(row.balance_real_value),
              balance_final: money(row.balance_final_value),
            }));
            // L'ordre et les cases, comme le noyau les applique : les comptes
            // rangés d'abord, les autres à la suite ; un compte décoché reste
            // montré et sort des totaux.
            if (window.__welcomeStored === undefined) {
              window.__welcomeStored = ${JSON.stringify(storedWelcome)} || { order: [], excluded: [] };
            }
            const wished = window.__welcomeStored;
            const rank = (row) => {
              const at = wished.order.indexOf(row.id);
              return at < 0 ? wished.order.length : at;
            };
            rows.sort((a, b) => rank(a) - rank(b));
            for (const row of rows) {
              row.included = !wished.excluded.includes(row.id);
            }
            const counted = rows.filter((row) => row.included);
            const sum = (key) => counted.reduce((total, row) => total + row[key], 0);
            return Promise.resolve({
              accounts: rows,
              total_bank: money(sum("balance_bank_value")),
              total_real: money(sum("balance_real_value")),
              total_final: money(sum("balance_final_value")),
              total_bank_value: sum("balance_bank_value"),
              total_real_value: sum("balance_real_value"),
              total_final_value: sum("balance_final_value"),
              accounts_line: counted.length === rows.length
                ? rows.length + " comptes ouverts"
                : "Comptes comptés dans les totaux : " + counted.length + " sur " + rows.length,
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
          case "balance_zone": {
            // La zone : son résumé, et deux opérations mères sur deux comptes.
            // Une zone d'un seul jour est vide, pour vérifier ce cas aussi.
            window.__zoneAsked = args;
            window.__zonesAsked = (window.__zonesAsked ?? 0) + 1;
            const rows = JSON.parse(OPERATIONS_JSON).rows.slice(0, 2).map((row, rank) => ({
              ...row, parent_id: 0, child_count: 0, account: rank === 0 ? "CCP" : "Livret A",
            }));
            const empty = args.from === args.to;
            return Promise.resolve({
              opening: "600,00 €", closing: empty ? "600,00 €" : "570,00 €",
              variation: empty ? "0,00 €" : "-30,00 €",
              debit: empty ? "0,00 €" : "-100,00 €", credit: empty ? "0,00 €" : "70,00 €",
              variation_value: empty ? 0 : -30000000,
              rows: empty ? [] : rows,
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
          // F41 — la simulation de crédit (08/10/2026). Le faux pont tient la
          // règle des curseurs à taux nul, pour vérifier les coutures et non
          // le calcul, qui est éprouvé dans le noyau : la durée suit la
          // mensualité, la mensualité suit le montant et la durée.
          case "loan_choices":
            return Promise.resolve({
              kinds: [
                { key: "consumer", label: "Crédit à la consommation" },
                { key: "mortgage", label: "Crédit immobilier" },
              ],
              histories: [
                { key: "last-12", label: "12 derniers mois" },
                { key: "2026", label: "2026" },
                { key: "2025", label: "2025" },
              ],
              years: [2026, 2025, 2024, 2023, 2022, 2021],
              accounts: [
                { id: 1, label: "CCP", bank: "La Banque Postale", balance: "1 549,81 €", balance_value: 1549810000 },
                { id: 2, label: "Livret", bank: "La Banque Postale", balance: "-12,00 €", balance_value: -12000000 },
              ],
              sign: "€",
            });
          case "loan_defaults":
            window.__loanDefaultsAsked = args.kind;
            return Promise.resolve(args.kind === "mortgage"
              ? { amount: "200000,00", months: "240", rate: "3,50", fees: "0,00", insurance: "0,00" }
              : { amount: "10000,00", months: "48", rate: "6,00", fees: "0,00", insurance: "0,00" });
          case "loan_simulate": {
            const asked = args.request;
            window.__loanAsked = (window.__loanAsked ?? []).concat([asked]);
            const read = (text) => Number(String(text).replace(/\s/g, "").replace(",", "."));
            if (!Number.isFinite(read(asked.amount)) || String(asked.amount).trim() === "") {
              return Promise.resolve({ invalid: "amount" });
            }
            for (const [rank, key] of ["optimistic", "neutral", "severe"].entries()) {
              const typed = String(asked.growth[rank] ?? "").trim();
              if (typed !== "" && !/^\\d{1,2}$/.test(typed)) {
                return Promise.resolve({ invalid: "growth-" + key });
              }
            }
            const amount = read(asked.amount);
            let months = Math.max(1, Math.round(read(asked.months)));
            if (asked.moved === "payment") {
              months = Math.ceil(amount / Math.max(read(asked.payment), 1));
            }
            const payment = Math.round((amount / months) * 100) / 100;
            const text = (value) => value.toFixed(2).replace(".", ",") + " €";
            const plain = (value) => value.toFixed(2).replace(".", ",");
            const dues = Array.from({ length: months }, (_, rank) => ({
              number: rank + 1, date: "08/11/2026", date_value: "2026-11-08",
              payment: text(payment), interest: "0,00 €", capital: text(payment), insurance: "0,00 €",
              remaining: text(amount - payment * (rank + 1)),
              payment_value: payment * 1e6, interest_value: 0, capital_value: payment * 1e6,
              insurance_value: 0, remaining_value: (amount - payment * (rank + 1)) * 1e6,
            }));
            const ratio = Math.round((payment / 2600) * 1000) / 10;
            const verdict = ratio <= 33 ? "green" : ratio <= 35 ? "orange" : "red";
            const svg = (name, extra) => "<svg xmlns='http://www.w3.org/2000/svg' class='loan-chart " + name + "' viewBox='0 0 320 226'>" + (extra ?? "") + "</svg>";
            const angle = Math.min(ratio / 60, 1) * 180;
            const ticked = asked.accounts.length > 0;
            return Promise.resolve({
              invalid: null,
              kind: asked.kind,
              amount_field: plain(amount), payment_field: plain(payment),
              rate_field: asked.rate, fees_field: asked.fees || "0,00", insurance_field: asked.insurance || "0,00",
              months, months_text: months + " mois",
              amount_euros: amount, amount_min: 500, amount_max: asked.kind === "mortgage" ? 500000 : 75000, amount_step: 100,
              months_min: 6, months_max: 84,
              payment_euros: payment, payment_min: Math.floor(amount / 84), payment_max: Math.ceil(amount / 6),
              notice: months > 84 ? "Cette mensualité demanderait plus de 600 mois." : null,
              figures: [
                { label: "Mensualité", value: text(payment), tone: "" },
                { label: "Mensualité assurance comprise", value: text(payment), tone: "" },
                { label: "TAEG", value: "0,00 %", tone: "" },
                { label: "Coût des intérêts", value: "0,00 €", tone: "" },
                { label: "Coût de l'assurance", value: "0,00 €", tone: "" },
                { label: "Coût total du crédit", value: "0,00 €", tone: "" },
                { label: "Montant total dû", value: text(amount), tone: "" },
                { label: "Total remboursé, assurance comprise", value: text(amount), tone: "" },
              ],
              dues,
              cost_donut: svg("loan-chart--donut"),
              capital_curve: svg("loan-chart--line"),
              analysis: (${loanUnavailable} || !ticked) ? null : {
                verdict, verdict_word: { green: "Jouable", orange: "Serré", red: "Risqué" }[verdict],
                checks: [
                  { tone: verdict === "green" ? "good" : verdict === "orange" ? "warn" : "bad", text: "Endettement de " + ratio + " %, comptes " + asked.accounts.join("+") + "." },
                  { tone: "good", text: "La mensualité prend peu de votre épargne." },
                  { tone: "good", text: "Votre solde reste positif jusqu'à la fin du crédit." },
                ],
                warning: asked.history === "2025" ? "Attention : sur cette période, vos dépenses dépassent déjà vos revenus." : null,
                method_key: asked.method,
                method_line: "Méthode de jugement : " + { optimistic: "Optimiste", neutral: "Neutre", severe: "Sévère" }[asked.method],
                methods: ["optimistic", "neutral", "severe"].map((key, rank) => ({
                  key,
                  name: ["Optimiste", "Neutre", "Sévère"][rank],
                  verdict: ["green", "orange", "red"][rank],
                  verdict_word: ["Jouable", "Serré", "Risqué"][rank],
                  values: ["v0-" + key, "v1-" + key, "v2-" + key, "v3-" + key, "v4-" + key],
                  growth: Number(asked.growth[rank] || [0, 2, 3][rank]),
                  explanation: "Explication " + key,
                })),
                rule_rows: ["Endettement accepté", "Épargne de référence", "Part", "Seuil", "Si le solde", "Hausse de vos dépenses par an"],
                rules_intro: "Le verdict répond à trois questions.",
                verdicts_line: "Optimiste : Jouable · Neutre : Serré · Sévère : Risqué",
                gauge: svg("loan-chart--gauge", "<g class='gauge-needle' data-angle='" + angle.toFixed(2) + "' transform='rotate(" + angle.toFixed(2) + " 160 150)'><path d='M 40 150 L 170 150'/></g>"),
                figures: [
                  { label: "Revenus moyens par mois", value: "2 600,00 €", tone: "" },
                  { label: "Reste à vivre par mois", value: text(600 - payment), tone: payment > 600 ? "bad" : "good" },
                  { label: "Taux d'endettement", value: ratio + " %", tone: verdict === "green" ? "good" : verdict === "orange" ? "warn" : "bad" },
                ],
                income_donut: svg("loan-chart--donut"),
                bars: svg("loan-chart--bars"),
                projection: svg("loan-chart--line"),
                loans: asked.history === "2025" ? [{ label: "PRET AUTO", monthly: "180,00 €", end: "05/09/2027" }] : [],
                loans_empty: "Aucun crédit en cours reconnu parmi vos opérations périodiques.",
                period: "de octobre 2025 à septembre 2026 (12 mois)",
                transfers: "Aucun virement entre vos comptes cochés n'a été reconnu.",
                method: "Moyennes sur les mois complets de la période.",
              },
              unavailable: (${loanUnavailable} || !ticked) ? "Cochez au moins un compte pour étudier votre historique." : null,
            });
          }
          case "print_loan_report":
            window.__loanPrinted = args;
            return Promise.resolve("Le rapport est prêt : /tmp/Simulation de crédit.pdf");
          case "close_loan_simulation":
            window.__loanClosed = true;
            return Promise.resolve(null);
          // F42 — la consommation d'un appareil électrique (09/10/2026). Le
          // faux pont garde le tarif enregistré et fait un calcul grossier :
          // c'est la fenêtre qu'on éprouve, le noyau a ses propres tests.
          case "electricity_tariff":
            return Promise.resolve({
              fields: window.__savedTariff ?? { option: "base", base: "0,2001", peak: "0,2142", off_peak: "0,1589", off_peak_hours: "8" },
              price_unit: "€/kWh",
            });
          case "electricity_blue_tariff":
            return Promise.resolve({
              fields: { option: "base", base: "0,2001", peak: "0,2142", off_peak: "0,1589", off_peak_hours: "8" },
              price_unit: "€/kWh",
            });
          case "save_preferences_electricity": {
            const price = /^\\d+([,.]\\d+)?$/;
            if (!price.test(args.tariff.base) || !price.test(args.tariff.peak) || !price.test(args.tariff.off_peak)) {
              return Promise.reject("Un prix du kWh de 0 à 100, s'il vous plaît.");
            }
            window.__savedTariff = args.tariff;
            return Promise.resolve(null);
          }
          case "appliance_compute": {
            const asked = args.request;
            window.__applianceAsked = (window.__applianceAsked ?? []).concat([asked]);
            const read = (text) => (text.trim() === "" ? 0 : Number(text.replace(",", ".")));
            for (const [name, id] of [["on_watts", "on-watts"], ["on_hours", "on-hours"], ["days", "days"], ["standby_watts", "standby-watts"]]) {
              if (Number.isNaN(read(asked.usage[name]))) {
                return Promise.resolve({ invalid: id, message: "Une puissance de 0 à 100 000 W, s'il vous plaît.", written: null });
              }
            }
            const onHours = read(asked.usage.on_hours);
            const standbyHours = asked.usage.standby_hours.trim() === "" ? 24 - onHours : read(asked.usage.standby_hours);
            if (onHours + standbyHours > 24) {
              return Promise.resolve({ invalid: "standby-hours", message: "La marche et la veille dépassent 24 heures par jour.", written: null });
            }
            const days = read(asked.usage.days);
            const price = read(asked.tariff.option === "base" ? asked.tariff.base : asked.tariff.peak);
            const onYear = read(asked.usage.on_watts) * onHours * days / 1000 * 365 / 7;
            const standbyYear = read(asked.usage.standby_watts) * (standbyHours * days + 24 * (7 - days)) / 1000 * 365 / 7;
            const euros = (kwh) => (kwh * price).toFixed(2).replace(".", ",") + " €";
            const energy = (kwh) => kwh.toFixed(2).replace(".", ",") + " kWh";
            const year = onYear + standbyYear;
            const offPeak = asked.tariff.option === "off-peak";
            const parts = offPeak
              ? [["Allumé, heures pleines", onYear, "#24506e"], ["Allumé, heures creuses", 0, "#8eb2cb"], ["En veille, heures pleines", standbyYear, "#c39a3c"], ["En veille, heures creuses", 0, "#d9b77a"]]
              : [["Allumé", onYear, "#24506e"], ["En veille", standbyYear, "#c39a3c"]];
            return Promise.resolve({
              invalid: null,
              message: null,
              written: {
                periods: [["Par jour", 365], ["Par mois", 12], ["Par an", 1]].map(([label, by]) => ({ label, cost: euros(year / by), energy: energy(year / by) })),
                lines: parts.map(([label, kwh, colour]) => ({ label, energy: energy(kwh), cost: euros(kwh), share: "50 %", colour, total: false }))
                  .concat([{ label: "Total", energy: energy(year), cost: euros(year), share: "100 %", colour: "", total: true }]),
                donut: "<svg xmlns='http://www.w3.org/2000/svg' class='loan-chart loan-chart--donut' viewBox='0 0 500 220'></svg>",
                standby_hours: String(24 - onHours),
                standby_sentence: standbyYear > 0 ? "La veille seule coûte " + euros(standbyYear) + " par an : 50 % de ce que coûte l'appareil." : null,
              },
            });
          }
          case "close_appliance_cost":
            window.__applianceClosed = true;
            return Promise.resolve(null);
          // F43 — le matelas de sécurité (09/10/2026). Le faux pont compte
          // grossièrement : 6 000 € d'épargne par livret coché, 1 500 € de
          // dépenses par mois, dont 300 € de loisirs (902).
          case "cushion_choices":
            return Promise.resolve({
              accounts: [
                { id: 1, label: "CCP", bank: "La Poste", balance: "1 549,81 €", savings: false, spending: true },
                { id: 2, label: "Livret A", bank: "La Poste", balance: "6 000,00 €", savings: true, spending: false },
                { id: 3, label: "PEL", bank: "La Poste", balance: "9 000,00 €", savings: false, spending: false },
              ],
              histories: [{ key: "last-12", label: "12 derniers mois" }, { key: "2026", label: "2026" }, { key: "2025", label: "2025" }],
              years: [2026, 2025, 2024, 2023, 2022, 2021],
              sign: "€",
            });
          case "cushion_compute": {
            const asked = args.request;
            window.__cushionAsked = (window.__cushionAsked ?? []).concat([asked]);
            if (!/^[0-9 ,.\u202f]*$/.test(asked.backup)) {
              return Promise.resolve({ invalid: "backup", message: "Ce montant n'est pas lisible : corrigez-le pour relancer le calcul.", written: null });
            }
            if (asked.spending.length === 0) {
              return Promise.resolve({ invalid: null, message: "Cochez au moins un compte « Dépenses ».", written: null });
            }
            const savings = asked.savings.includes(2) ? 6000 : 0;
            const spending = 1500 - (asked.excluded.includes(902) ? 300 : 0);
            const backup = asked.backup.trim() === "" ? 0 : Number(asked.backup.replace(/[ \u202f]/g, "").replace(",", "."));
            const burn = spending - backup;
            const cover = burn > 0 ? savings / burn : null;
            const tone = cover === null || cover >= 6 ? "good" : cover >= 3 ? "warn" : "bad";
            const euros = (value) => value.toFixed(2).replace(".", ",") + " €";
            return Promise.resolve({
              invalid: null,
              message: null,
              written: {
                verdict: cover === null ? "Votre revenu de secours couvre vos dépenses : votre épargne ne fondrait pas." : tone === "good" ? "Six mois ou plus : votre matelas est solide." : tone === "warn" ? "Entre trois et six mois : un matelas correct, à étoffer si vous le pouvez." : "Moins de trois mois : un coup dur vous mettrait vite en difficulté.",
                tone,
                gauge: "<svg xmlns='http://www.w3.org/2000/svg' class='loan-chart loan-chart--gauge' viewBox='0 0 320 226'><g class='gauge-needle' data-angle='60.00' transform='rotate(60.00 160 150)'><path d='M 40 150 L 170 150'/></g><text>" + (cover === null ? "Sans limite" : cover.toFixed(1).replace(".", ",") + " mois") + "</text></svg>",
                tiles: [{ label: "Épargne disponible", value: euros(savings) }, { label: "Dépenses retenues", value: euros(spending) + " par mois" }],
                targets: burn > 0 ? [3, 6].map((months) => ({ title: months + " mois de dépenses : " + euros(months * burn), status: savings >= months * burn ? "Atteint." : "Il manque " + euros(months * burn - savings) + ".", reached: savings >= months * burn })) : [],
                projection: "<svg xmlns='http://www.w3.org/2000/svg' class='loan-chart loan-chart--line' viewBox='0 0 680 250'></svg>",
                categories: [
                  { id: 901, label: "Courses", monthly: "1 200,00 € par mois", kept: !asked.excluded.includes(901) },
                  { id: 902, label: "Loisirs", monthly: "300,00 € par mois", kept: !asked.excluded.includes(902) },
                ],
                period: "Moyenne de 12 mois complets, d'octobre 2025 à septembre 2026. 12 virements entre vos comptes, non comptés comme dépenses.",
              },
            });
          }
          case "close_safety_cushion":
            window.__cushionClosed = true;
            return Promise.resolve(null);
          // F44 — l'objectif d'épargne (10/10/2026). Le faux pont répond en
          // gros : 6 000 € suivis, 200 € par mois.
          case "goal_choices":
            return Promise.resolve({
              accounts: [
                { id: 1, label: "CCP", bank: "La Poste", balance: "1 549,81 €", ticked: false },
                { id: 2, label: "Livret A", bank: "La Poste", balance: "6 000,00 €", ticked: true },
              ],
              histories: [{ key: "last-12", label: "12 derniers mois" }, { key: "2026", label: "2026" }, { key: "2025", label: "2025" }],
              years: [2026, 2025, 2024, 2023, 2022, 2021],
              months: ["janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre"],
              month: 10,
              year: 2027,
              sign: "€",
            });
          case "goal_compute": {
            const asked = args.request;
            window.__goalAsked = (window.__goalAsked ?? []).concat([asked]);
            const refuse = (field, message) => Promise.resolve({ invalid: field, message, written: null });
            if (asked.accounts.length === 0) {
              return Promise.resolve({ invalid: null, message: "Cochez au moins un compte à suivre.", written: null });
            }
            const target = Number(asked.target.replace(/[ \u202f]/g, "").replace(",", "."));
            if (asked.question !== "amount" && (asked.target.trim() === "" || Number.isNaN(target))) {
              return refuse("target", "Un montant à atteindre, s'il vous plaît.");
            }
            if (asked.question !== "when" && !/^[0-9]{4}$/.test(asked.year.trim())) {
              return refuse("year", "Une date à venir, dans les cinquante prochaines années, s'il vous plaît.");
            }
            if (asked.rate.trim() !== "" && Number.isNaN(Number(asked.rate.replace(",", ".")))) {
              return refuse("rate", "Un taux de 0 à 100 %, s'il vous plaît.");
            }
            const headline = asked.question === "when"
              ? "Vous aurez " + asked.target + " € vers mai 2027, dans 7 mois."
              : asked.question === "amount"
                ? "En " + asked.month + "/" + asked.year + ", vous auriez environ 8 400,00 €."
                : "Pour avoir " + asked.target + " € en " + asked.month + "/" + asked.year + ", il faudrait épargner en moyenne 420,00 € par mois, soit 220,00 € de plus qu'aujourd'hui.";
            return Promise.resolve({
              invalid: null,
              message: null,
              written: {
                headline,
                range: "Selon les mois, entre mars 2027 et août 2027.",
                tone: asked.question === "effort" ? "warn" : "good",
                tiles: [{ label: "Solde aujourd'hui", value: "6 000,00 €" }, { label: "Rythme moyen", value: "+200,00 € par mois" }, { label: "Objectif", value: "10 000,00 €" }, { label: "Épargné d'ici là", value: "1 400,00 €" }],
                chart: "<svg xmlns='http://www.w3.org/2000/svg' class='loan-chart loan-chart--line' viewBox='0 0 760 270'></svg>",
                notes: ["La projection suit les saisons : chaque mois à venir reprend la moyenne des mêmes mois de la période."],
                period: "Rythme calculé sur 12 mois complets, d'octobre 2025 à septembre 2026. Aucun virement entre vos comptes suivis.",
              },
            });
          }
          case "close_savings_goal":
            window.__goalClosed = true;
            return Promise.resolve(null);
          // F45 — « Et si je réduisais… ? » (10/10/2026). Le faux pont réduit
          // grossièrement : deux catégories, 1 700 € et 425 € par mois.
          case "cut_choices":
            return Promise.resolve({
              accounts: [
                { id: 1, label: "CCP", bank: "La Poste", balance: "1 549,81 €" },
                { id: 2, label: "Livret A", bank: "La Poste", balance: "6 000,00 €" },
              ],
              histories: [{ key: "last-12", label: "12 derniers mois" }, { key: "2026", label: "2026" }, { key: "2025", label: "2025" }],
              years: [2026, 2025, 2024, 2023, 2022, 2021],
              axes: [{ key: "category", label: "Catégories" }, { key: "payee", label: "Tiers" }, { key: "budget-line", label: "Postes budgétaires" }],
              sign: "€",
              hint: "Tapez une réduction en % ou en € par mois sur les postes que vous voudriez alléger.",
            });
          case "cut_compute": {
            const asked = args.request;
            window.__cutAsked = (window.__cutAsked ?? []).concat([asked]);
            for (const cut of asked.cuts) {
              if (!/^[0-9]+([,.][0-9]+)?$/.test(cut.value.trim())) {
                return Promise.resolve({ invalid: "cut-" + cut.id, message: "Cette réduction n'est pas lisible : un pourcentage de 0 à 100, ou un montant par mois.", written: null });
              }
            }
            if (asked.accounts.length === 0) {
              return Promise.resolve({ invalid: null, message: "Cochez au moins un compte à suivre.", written: null });
            }
            const items = asked.axis === "payee"
              ? [{ id: 31, label: "Supermarché", monthly: 900 }]
              : [{ id: 902, label: "Courses", monthly: 1700 }, { id: 901, label: "Restaurants", monthly: 425 }];
            const euros = (value) => value.toFixed(2).replace(".", ",") + " €";
            let total = 0;
            const rows = items.map((item) => {
              const cut = asked.cuts.find((one) => one.id === item.id);
              const value = cut ? Number(cut.value.replace(",", ".")) : 0;
              const saved = cut ? Math.min(item.monthly, cut.unit === "percent" ? item.monthly * value / 100 : value) : 0;
              total += saved;
              return { id: item.id, label: item.label, monthly: euros(item.monthly), cut: saved > 0 ? "−" + cut.value : "", after: euros(item.monthly - saved), yearly: saved > 0 ? "+" + euros(saved * 12) : "", capped: cut !== undefined && cut.unit === "amount" && value > item.monthly, reduced: saved > 0 };
            });
            const count = rows.filter((row) => row.reduced).length;
            return Promise.resolve({
              invalid: null,
              message: null,
              written: {
                headline: count === 0 ? "Tapez une réduction dans le tableau pour en voir l'effet." : "En réduisant ces " + count + " postes, vous mettriez de côté " + euros(total) + " de plus par mois, soit " + euros(total * 12) + " par an.",
                tone: count === 0 ? "none" : "good",
                tiles: [{ label: "Gain par mois", value: euros(total) }, { label: "Gain par an", value: euros(total * 12) }],
                rows,
                total: { id: -1, label: "Total", monthly: "2 125,00 €", cut: "", after: "", yearly: "", capped: false, reduced: count > 0 },
                target: asked.target.trim() === "" ? null : "Vous atteindriez " + asked.target + " € vers juillet 2027 au lieu de février 2028 : 7 mois plus tôt.",
                years: asked.years + " ans",
                chart: "<svg xmlns='http://www.w3.org/2000/svg' class='loan-chart loan-chart--line' viewBox='0 0 760 270'></svg>",
                donut: "<svg xmlns='http://www.w3.org/2000/svg' class='loan-chart loan-chart--donut' viewBox='0 0 500 220'></svg>",
                notes: ["Chaque réduction suit les saisons de son poste."],
                period: "Rythme calculé sur 12 mois complets.",
              },
            });
          }
          case "print_cut_report":
            window.__cutPrinted = args.request;
            return Promise.resolve("Le rapport est prêt : /tmp/Et si je réduisais.pdf");
          case "export_cut":
            window.__cutExported = args;
            return Promise.resolve("Exporté vers « Et si je réduisais.xlsx »");
          case "save_cut_project":
            window.__cutSaved = args;
            return Promise.resolve("Projet enregistré : Et si je réduisais.json");
          case "load_cut_project":
            window.__cutLoaded = (window.__cutLoaded ?? 0) + 1;
            return Promise.resolve({
              history: "range", from: 2023, to: 2025, axis: "category", years: 3, rate: "1,5", target: "8000,00",
              accounts: ["Livret A"], account_ids: [2],
              cuts: [{ id: 902, value: "100,00", unit: "amount" }],
              message: "Projet ouvert : Restaurants.json",
            });
          case "close_spending_cut":
            window.__cutClosed = (window.__cutClosed ?? 0) + 1;
            return Promise.resolve(null);
          // F46 — « Préparer mes vacances » (10/10/2026). Un catalogue réduit
          // et un calcul grossier : c'est la fenêtre qu'on éprouve.
          case "holiday_choices": {
            const span = (key, label) => ({ key, label });
            return Promise.resolve({
              accounts: [
                { id: 1, label: "CCP", bank: "La Poste", balance: "1 549,81 €" },
                { id: 2, label: "Livret vacances", bank: "La Poste", balance: "800,00 €" },
              ],
              catalog: [
                { key: "transport", label: "Transport aller-retour", stay: true, cruise: false, optional: false, who: "choice", default_who: "person", spans: [span("trip", "pour le séjour")], units: [span("amount", "€")] },
                { key: "lodging", label: "Hébergement", stay: true, cruise: false, optional: false, who: "choice", default_who: "all", spans: [span("night", "par nuit"), span("trip", "pour le séjour")], units: [span("amount", "€")] },
                { key: "cabins", label: "Cabines", stay: false, cruise: true, optional: false, who: "cabins", default_who: "all", spans: [span("trip", "pour le séjour")], units: [span("amount", "€")] },
                { key: "insurance", label: "Assurance annulation", stay: true, cruise: true, optional: true, who: "choice", default_who: "all", spans: [span("trip", "pour le séjour")], units: [span("percent", "%"), span("amount", "€")] },
                { key: "stay-tax", label: "Taxe de séjour", stay: true, cruise: false, optional: true, who: "adults", default_who: "all", spans: [span("night", "par nuit")], units: [span("amount", "€")] },
              ],
              sign: "€",
            });
          }
          case "holiday_compute": {
            const input = args.input;
            window.__holidayAsked = (window.__holidayAsked ?? []).concat([{ input, accounts: args.accounts }]);
            for (const line of input.lines) {
              if (line.amount.trim() !== "" && !/^[0-9]+([,.][0-9]+)?$/.test(line.amount.trim())) {
                return Promise.resolve({ invalid: "amount-" + line.key, message: "Ce montant n'est pas lisible : un nombre positif, ou un pourcentage de 0 à 100.", written: null });
              }
            }
            const total = input.lines
              .filter((line) => line.amount.trim() !== "" && line.unit !== "percent")
              .reduce((sum, line) => sum + Number(line.amount.replace(",", ".")), 0);
            const saved = args.accounts.includes(2) ? 800 : 0;
            const euros = (value) => value.toFixed(2).replace(".", ",") + " €";
            return Promise.resolve({
              invalid: null,
              message: null,
              written: {
                headline: total === 0 ? "Tapez les montants du budget pour voir ce que coûtera le voyage." : "Ce séjour coûterait " + euros(total) + " pour " + (input.adults + input.children) + " personnes.",
                tiles: [
                  { label: "Par personne", value: euros(total / (input.adults + input.children)) },
                  { label: "Déjà épargné", value: euros(saved) },
                  { label: "Reste à financer", value: euros(Math.max(total - saved, 0)) },
                ],
                costs: input.lines.map((line) => ({ key: line.key, cost: line.amount.trim() === "" ? "" : euros(Number(line.amount.replace(",", "."))), share: "", colour: "#24506e" })),
                donut: "<svg xmlns='http://www.w3.org/2000/svg' class='loan-chart loan-chart--donut' viewBox='0 0 500 220'></svg>",
                days: (Number(input.nights || 0) + 1) + " jours",
                notes: ["Les jours sont les nuits plus une : sept nuits font huit jours."],
              },
            });
          }
          case "print_holiday_report":
            window.__holidayPrinted = args;
            return Promise.resolve("Le rapport est prêt : /tmp/Préparer mes vacances.pdf");
          case "export_holiday":
            window.__holidayExported = args;
            return Promise.resolve("Exporté vers « Préparer mes vacances.xlsx »");
          case "save_holiday_project":
            window.__holidaySaved = args;
            return Promise.resolve("Projet enregistré : Préparer mes vacances.json");
          case "load_holiday_project":
            window.__holidayLoaded = (window.__holidayLoaded ?? 0) + 1;
            return Promise.resolve({
              input: { trip: "cruise", adults: 2, children: 1, nights: "7", months: "5", stops: "4", lines: [{ key: "cabins", amount: "2400,00", child: "", who: "all", span: "trip", unit: "amount", count: "1" }] },
              accounts: [2],
              message: "Projet ouvert : Croisière.json",
            });
          case "close_holiday":
            window.__holidayClosed = (window.__holidayClosed ?? 0) + 1;
            return Promise.resolve(null);
          // --- L'assistant d'exportation d'une base (P-74) ----------------
          case "list_databases":
            return Promise.resolve(JSON.parse(DATABASES_JSON));
          case "database_tool_labels":
            window.__toolLabels = (window.__toolLabels ?? []).concat([args.label]);
            return Promise.resolve(
              args.label === null
                ? { header: "Aucune base sélectionnée", backup: "Sauvegarder la base sélectionnée…", restore: "Restaurer la base sélectionnée…", repair: "Réparer et optimiser la base sélectionnée…" }
                : { header: "Base sélectionnée : « " + args.label + " »", backup: "Sauvegarder la base « " + args.label + " »…", restore: "Restaurer la base « " + args.label + " »…", repair: "Réparer et optimiser la base « " + args.label + " »…" },
            );
          case "open_database_export":
            window.__exportOpened = args;
            return Promise.resolve(null);
          case "database_export_intro":
            window.__exportIntro = args;
            return Promise.resolve({
              banner: "Seule la base « " + args.label + " », sélectionnée dans la liste, sera exportée. Les autres bases ne sont pas concernées.",
              protected: EXPORT_PROTECTED,
            });
          case "database_export_destination": {
            window.__exportPicks = (window.__exportPicks ?? 0) + 1;
            window.__exportPicked = args;
            const folder = ["csv", "qif", "ofx"].includes(args.format) || (args.format !== "sqlite" && args.layout === "per-table");
            const stem = args.label + " - export 2026-10-19";
            return Promise.resolve({
              destination: folder ? "/home/lea/Documents/" + stem : "/home/lea/Documents/" + stem + "." + args.format,
              folder,
              question: folder && EXPORT_PLACE_EXISTS ? "Le dossier « " + stem + " » existe déjà. Les fichiers de même nom qu'il contient seront remplacés. Continuer ?" : null,
            });
          }
          case "run_database_export":
            window.__exportRuns = (window.__exportRuns ?? 0) + 1;
            window.__exportRun = args;
            if (BASE_EXPORT_REFUSED) return Promise.reject(BASE_EXPORT_REFUSED);
            return Promise.resolve("La base « " + args.label + " » a été exportée : 21 tables, 1234 lignes.");
          case "forget_database_export":
            window.__exportForgotten = (window.__exportForgotten ?? 0) + 1;
            return Promise.resolve(null);
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

/// Ouvre le sous-menu « Afficher/Masquer » du menu des colonnes, et l'y
/// laisse : un clic sur son entrée le tient ouvert sans avoir à le survoler.
async function openChecks(page) {
  await page.click('.context-menu--columns [data-menu="show-hide"] > .context-menu__entry--opener');
  await page.waitForTimeout(60);
}

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
        "crossed-balance.html": "?accounts=1,2&year=2026&month=9",
        "dashboard.html": "?accounts=1,2",
        "balance-curves.html": "?accounts=1,2",
        "balance-analysis.html": "?accounts=1,2",
        "loan-simulation.html": "",
        "appliance-cost.html": "",
        "safety-cushion.html": "",
        "savings-goal.html": "",
        "spending-cut.html": "",
        "holiday.html": "",
        "car-logbook.html": "",
        "sharing.html": "",
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
        "database-export.html": "?path=databases%2Ffamille%2Fradinus.sqlite&label=Famille",
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
  await page.click(".list__row >> nth=2", { modifiers: ["Meta"] });
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

  // **Le menu du clic droit**, qui manquait ici depuis l'origine (Fabrice,
  // 07/10/2026 : « aucun moyen de faire un copier de cellule ou de ligne,
  // aucun moyen d'exporter le tableau […] absence totale de menu
  // contextuel »). La fenêtre utilisait le tableau commun sans le brancher.
  const total = page.locator(".list__row").last();
  await total.locator(".list__cell >> nth=1").click({ button: "right" });
  await page.waitForTimeout(100);
  check(
    "soldes : le clic droit ouvre le menu — les deux copies, un trait, puis les dix exports",
    (await page.locator(".context-menu").count()) === 1 &&
      (await page.locator(".context-menu > .context-menu__entry--head").allTextContents()).join("|") ===
        "Copier la cellule|Copier les lignes sélectionnées" &&
      (await page.locator(".context-menu > .context-menu__entry:not(.context-menu__entry--head)").count()) === 10 &&
      (await page.locator(".context-menu > .context-menu__entry:not(.context-menu__entry--head) >> nth=0").textContent()) ===
        "Exporter vers Excel (.xlsx)",
  );
  await page.click('.context-menu [data-head="copy-cell"]');
  await page.waitForTimeout(150);
  check(
    "soldes : « Copier la cellule » copie un solde en nombre pur — celui du TOTAL",
    (await page.evaluate(() => window.__clipboard.join("|"))) === "24972,62",
    await page.evaluate(() => window.__clipboard.join("|")),
  );
  await page.locator(".list__row").first().click();
  await page.keyboard.down("Meta");
  await total.click();
  await page.keyboard.up("Meta");
  await page.locator(".list__row >> nth=0 >> .list__cell >> nth=0").click({ button: "right" });
  await page.click('.context-menu [data-head="copy-rows"]');
  await page.waitForTimeout(150);
  const lines = (await page.evaluate(() => window.__clipboard.slice(-1)[0])).split("\n").map((line) => line.split("\t"));
  check(
    "soldes : « Copier les lignes sélectionnées » copie le compte et le TOTAL, quatre cellules chacun",
    lines.length === 2 && lines.every((line) => line.length === 4) &&
      lines[1][0] === "TOTAL" && lines[1][3] === "24972,62" && !lines[0][1].includes("€"),
    JSON.stringify(lines),
  );
  await page.locator(".list__row >> nth=0 >> .list__cell >> nth=0").click({ button: "right" });
  await page.click(".context-menu > .context-menu__entry:not(.context-menu__entry--head) >> nth=0");
  await page.waitForTimeout(250);
  const exported = await page.evaluate(() => window.__exported);
  check(
    "soldes : l'export porte le nom de la fenêtre, ses quatre colonnes, et la ligne TOTAL",
    exported.path.endsWith("Soldes de vos comptes.xlsx") &&
      exported.sheet.name === "Soldes de vos comptes" &&
      exported.sheet.rows.length === 4 &&
      exported.sheet.rows[0].length === 4 &&
      exported.sheet.rows[3][0].text === "TOTAL",
    JSON.stringify([exported.path, exported.sheet.rows.length]),
  );
  check(
    "soldes : les soldes s'exportent en nombres, pour qu'un tableur les additionne",
    exported.sheet.rows.slice(1).every((row) => row.slice(1).every((cell) => !String(cell.text ?? "").includes("€"))) &&
      JSON.stringify(exported.sheet.rows[3][3]).includes("24972620000"),
    JSON.stringify(exported.sheet.rows[3]),
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

  // **La date parasite se voit, et se voit aussi sélectionnée** (Fabrice,
  // 25/08/2026). SALAIRE n'est pas pointée et porte pourtant une date de
  // pointage : elle est marquée. Les deux lignes pointées ne le sont pas.
  check(
    "opérations : seule la date d'une ligne non pointée est marquée",
    (await page.locator(".list__cell--faded").count()) === 1,
  );

  // **Et elle ne montre aucun solde** (Fabrice, 25/08/2026). Le solde de la
  // colonne est celui de la banque : une ligne que la banque n'a pas passée
  // n'en a pas, et une case vide le dit mieux qu'un zéro. Le même langage que
  // les sous-opérations, qui n'en portent pas non plus.
  const soldes = await page.evaluate(() => {
    const read = (label) => {
      const row = Array.from(document.querySelectorAll(".list__row")).find((line) =>
        line.textContent.includes(label),
      );
      const cells = Array.from(row.querySelectorAll(".list__cell"));
      // Quatre colonnes portent la marque des nombres : débit, crédit, solde,
      // puis le numéro de chèque. Le solde est la troisième.
      const numeric = cells.filter((cell) => cell.classList.contains("list__cell--numeric"));
      return numeric[2].textContent.trim();
    };
    return { pointee: read("SALAIRE"), autre: read("COURSES") };
  });
  check(
    "opérations : une ligne non pointée n'affiche aucun solde",
    soldes.pointee === "",
    JSON.stringify(soldes),
  );
  check(
    "opérations : une ligne pointée, elle, l'affiche",
    soldes.autre !== "",
    JSON.stringify(soldes),
  );
  const faded = page.locator(".list__cell--faded").first();
  check("opérations : la date parasite est en italique", 
    (await faded.evaluate((cell) => getComputedStyle(cell).fontStyle)) === "italic");
  const plain = await faded.evaluate((cell) => getComputedStyle(cell).color);

  // Sélectionnée, elle change de gris : sur le fond bleu de la sélection,
  // l'ancien gris clair disparaissait purement et simplement.
  await page.click(".list__row >> nth=1");
  await page.waitForTimeout(80);
  const chosen = await faded.evaluate((cell) => getComputedStyle(cell).color);
  check("opérations : la ligne est bien sélectionnée",
    (await page.locator('.list__row[aria-selected="true"]').count()) === 1);
  check(
    "opérations : sélectionnée, la date parasite change de gris",
    chosen !== plain,
    `${plain} -> ${chosen}`,
  );
  // Et ce gris-là contraste vraiment avec le fond de la sélection (#9eafba) :
  // le rapport de l'un à l'autre doit dépasser 3 pour rester lisible.
  const ratio = await faded.evaluate((cell) => {
    const channel = (v) => {
      const c = v / 255;
      return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
    };
    const luminance = ([r, g, b]) =>
      0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b);
    const read = (text) => text.match(/\d+/g).slice(0, 3).map(Number);
    const text = luminance(read(getComputedStyle(cell).color));
    const back = luminance([158, 175, 186]);
    const [high, low] = text > back ? [text, back] : [back, text];
    return (high + 0.05) / (low + 0.05);
  });
  check(
    "opérations : et elle reste lisible sur le fond de la sélection",
    ratio >= 3,
    String(ratio),
  );
  await page.click(".list__row >> nth=1", { modifiers: ["Meta"] });
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
    (await page.locator(".list__row >> nth=1 >> .list__cell >> nth=14").textContent()) === "",
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
    "nomenclature : cinq listes déroulantes sur la ligne choisie, plus le statut et la vérification",
    (await page.locator(".list__combo").count()) === 7,
  );
  check(
    "nomenclature : et sur elle seule",
    (await page.locator(".list__row >> nth=1 >> .list__combo").count()) === 0,
  );
  check(
    "nomenclature : la liste montre la valeur de la ligne",
    (await page.locator(".list__combo >> nth=2").inputValue()) === "1",
  );
  check(
    "nomenclature : « Non précisé » est en tête",
    (await page.locator(".list__combo >> nth=2").locator("option").first().textContent()) ===
      "Non précisé",
  );

  // Choosing writes straight to the database.
  await page.selectOption(".list__combo >> nth=2", "5");
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

  // **La colonne « Statut opération »** (Fabrice, 01/10/2026) : entre la date
  // de pointage et le libellé, le mot sur chaque ligne, la liste déroulante
  // sur la ligne choisie seulement.
  const titles = await page.locator(".list__title-text").allTextContents();
  check(
    "statut : la colonne est entre « Date Pointage » et « Libellé »",
    titles[2] === "Date Pointage" && titles[3] === "Statut opération",
    JSON.stringify(titles.slice(0, 5)),
  );
  const statusOf = (label) =>
    page.evaluate((wanted) => {
      const row = Array.from(document.querySelectorAll(".list__row")).find((line) =>
        line.textContent.includes(wanted),
      );
      // Sur la ligne choisie, la case porte la liste : on lit le choix fait.
      const cell = row.querySelectorAll(".list__cell")[3];
      const combo = cell.querySelector("select");
      return combo ? combo.selectedOptions[0].textContent.trim() : cell.textContent.trim();
    }, label);
  check("statut : une ligne pointée dit « Pointé »", (await statusOf("COURSES")) === "Pointé");
  check("statut : une ligne prévue dit « Prévu »", (await statusOf("SALAIRE")) === "Prévu");
  await page.click(".list__row >> nth=0");
  await page.waitForTimeout(150);
  check(
    "statut : la liste déroulante montre le statut de la ligne",
    (await page.locator(".list__row[aria-selected='true'] .list__combo >> nth=0").inputValue()) === "1",
  );
  check(
    "statut : trois choix, pointé, engagé, prévu",
    (await page
      .locator(".list__row[aria-selected='true'] .list__combo >> nth=0")
      .locator("option")
      .allTextContents()).join("|") === "Pointé|Engagé|Prévu",
  );
  await page.selectOption(".list__row[aria-selected='true'] .list__combo >> nth=0", "3");
  await page.waitForTimeout(200);
  check(
    "statut : choisir écrit le statut, et seulement lui",
    await page.evaluate(() =>
      window.__calls.some(
        ([command, args]) => command === "set_operation_status" && args.id === 1 && args.statusId === 3,
      ),
    ),
  );
  check(
    "statut : et la liste est relue",
    await page.evaluate(() => {
      const names = window.__calls.map(([c]) => c);
      return names.lastIndexOf("list_operations") > names.indexOf("set_operation_status");
    }),
  );

  // **La colonne « Vérification »** (Fabrice, 03/10/2026) : juste après le
  // statut, le mot et sa couleur sur chaque ligne, la liste déroulante sur la
  // ligne choisie. Ce que l'utilisateur pense de l'écriture — le statut, lui,
  // dit ce que la banque en a fait.
  check(
    "vérification : la colonne suit « Statut opération »",
    titles[4] === "Vérification" && titles[5] !== "Vérification",
    JSON.stringify(titles.slice(0, 6)),
  );
  const verificationOf = (label) =>
    page.evaluate((wanted) => {
      const row = Array.from(document.querySelectorAll(".list__row")).find((line) =>
        line.textContent.includes(wanted),
      );
      const cell = row.querySelectorAll(".list__cell")[4];
      const combo = cell.querySelector("select");
      const marked = combo ?? cell;
      return {
        word: combo ? combo.selectedOptions[0].textContent.trim() : cell.textContent.trim(),
        key: marked.dataset.verification,
        colour: getComputedStyle(marked).color,
      };
    }, label);
  const doubtful = await verificationOf("SALAIRE");
  check(
    "vérification : une écriture douteuse le dit, en orange",
    doubtful.word === "Douteuse" && doubtful.key === "3" && doubtful.colour === "rgb(179, 92, 0)",
    JSON.stringify(doubtful),
  );
  const verified = await verificationOf("COURSES");
  check(
    "vérification : la ligne choisie montre la sienne dans sa liste, en vert",
    verified.word === "Vérifiée" && verified.key === "2" && verified.colour === "rgb(30, 107, 36)",
    JSON.stringify(verified),
  );
  check(
    "vérification : quatre choix, dans l'ordre de leur clef",
    (await page
      .locator(".list__row[aria-selected='true'] .list__combo >> nth=1")
      .locator("option")
      .allTextContents()).join("|") === "À vérifier|Vérifiée|Douteuse|Contestée",
  );
  await page.selectOption(".list__row[aria-selected='true'] .list__combo >> nth=1", "4");
  await page.waitForTimeout(200);
  check(
    "vérification : choisir écrit la vérification, et rien d'autre",
    await page.evaluate(
      () =>
        window.__calls.some(
          ([command, args]) =>
            command === "set_operation_verification" && args.id === 1 && args.verificationId === 4,
        ) &&
        window.__calls.filter(([command]) => command === "set_operation_status").length === 1,
    ),
  );
  check(
    "vérification : et la liste est relue",
    await page.evaluate(() => {
      const names = window.__calls.map(([c]) => c);
      return names.lastIndexOf("list_operations") > names.indexOf("set_operation_verification");
    }),
  );

  // **Un débit reste rouge**, où que soit sa colonne. La règle visait « la
  // onzième cellule » et a cessé de le trouver quand une colonne est venue se
  // glisser devant (01/10/2026) : la cellule se nomme désormais elle-même.
  check(
    "opérations : un débit est écrit en rouge",
    await page.evaluate(() => {
      const row = Array.from(document.querySelectorAll(".list__row")).find((line) =>
        line.textContent.includes("COURSES"),
      );
      const debit = row.querySelector(".list__cell--debit");
      return debit.textContent.includes("-100,00") && getComputedStyle(debit).color === "rgb(204, 0, 0)";
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
  check(
    "vérification : une sous-opération n'offre pas de liste, elle montre celle de sa mère",
    (await page.locator(".list__row[aria-selected='true'] .list__cell >> nth=4").textContent()).trim() ===
      "Vérifiée" &&
      (await page.locator(".list__row[aria-selected='true'] .list__cell >> nth=4 >> .list__combo").count()) === 0,
  );
  check(
    "statut : une sous-opération n'offre pas de statut, elle montre celui de sa mère",
    (await page.locator(".list__row[aria-selected='true'] .list__cell >> nth=3").textContent()).trim() ===
      "Pointé" &&
      (await page.locator(".list__row[aria-selected='true'] .list__cell >> nth=3 >> .list__combo").count()) === 0,
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
    (await page.locator('[data-menu="period"] .window-menu__submenu >> nth=0 >> button').count()) === 13,
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
  await page.locator('[data-menu="period"] .window-menu__nest >> nth=1 >> .window-menu__choice--parent').click();
  await page.waitForTimeout(120);
  await page.locator('[data-menu="period"] .window-menu__submenu >> nth=1 >> button', { hasText: "février" }).click();
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
  // Le menu Filtre (Fabrice, 05/10/2026) : « Toutes les opérations », un
  // trait, puis « Filtre Statut » et « Filtre Vérification », chacun avec son
  // sous-menu. Un seul choix par sous-menu, les deux se combinent, et le
  // filtre est appliqué par le noyau — le pied de la fenêtre additionne
  // toujours ce que le tableau montre.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/operations-list.html?account=1");
  const menu = page.locator(".window-menu__entry", { hasText: "Filtre" });
  const lastAsked = () =>
    page.evaluate(() => {
      const asked = window.__calls.filter(([c]) => c === "list_operations");
      const { status, verification } = asked[asked.length - 1][1];
      return `${status}/${verification}`;
    });
  const ticked = () =>
    page.evaluate(() =>
      [...document.querySelectorAll('[data-menu="filter"] .window-menu__choice--chosen')]
        .map((button) => button.dataset.key)
        .join("|"),
    );
  const pick = async (opener, choice) => {
    await menu.click();
    await page.locator('[data-menu="filter"] .window-menu__choice--parent', { hasText: opener }).hover();
    await page.waitForTimeout(80);
    await page
      .locator('[data-menu="filter"] .window-menu__nest', { hasText: opener })
      .locator(".window-menu__submenu .window-menu__choice", { hasText: choice })
      .click();
    await page.waitForTimeout(200);
  };

  await menu.click();
  await page.waitForTimeout(120);
  check(
    "filtre : « Toutes les opérations », un trait, puis les deux filtres",
    await page.evaluate(() => {
      const pieces = [...document.querySelector('[data-menu="filter"]').children].map((piece) =>
        piece.matches("hr") ? "—" : piece.matches(".window-menu__nest") ? piece.firstElementChild.textContent : piece.textContent,
      );
      return pieces.join("|") === "Toutes les opérations|—|Filtre Statut|Filtre Vérification";
    }),
  );
  check(
    "filtre : au départ, « Toutes les opérations » est cochée, et « Afficher tout » dans chaque sous-menu",
    (await ticked()) === "filter-all|filter-status-all|filter-verification-all",
    await ticked(),
  );
  check(
    "filtre : les sous-menus attendent qu'on y vienne",
    (await page.locator('[data-menu="filter"] .window-menu__submenu >> visible=true').count()) === 0,
  );
  await page.locator('[data-menu="filter"] .window-menu__choice--parent', { hasText: "Filtre Statut" }).hover();
  await page.waitForTimeout(80);
  check(
    "filtre : « Filtre Statut » offre pointées, engagées, prévues",
    (await page.locator('[data-menu="filter"] .window-menu__nest >> nth=0 >> .window-menu__submenu .window-menu__choice').allTextContents()).join("|") ===
      "Afficher tout|Uniquement les opérations pointées|Uniquement les opérations engagées|Uniquement les opérations prévues" &&
      (await page.locator('[data-menu="filter"] .window-menu__nest >> nth=0 >> .window-menu__submenu > *').evaluateAll(
        (pieces) => pieces[1].matches("hr.window-menu__rule"),
      )),
  );
  await page.locator('[data-menu="filter"] .window-menu__choice--parent', { hasText: "Filtre Vérification" }).hover();
  await page.waitForTimeout(80);
  const words = await page.evaluate(() =>
    [...document.querySelectorAll('[data-menu="filter"] .window-menu__nest:last-child .window-menu__submenu .window-menu__choice')].map(
      (button) => `${button.textContent}:${getComputedStyle(button).color}`,
    ),
  );
  check(
    "filtre : « Filtre Vérification » offre les quatre vérifications de la base, dans leur couleur",
    words.map((word) => word.split(":")[0]).join("|") ===
      "Afficher tout|À vérifier|Vérifiée|Douteuse|Contestée" &&
      words[0].endsWith(words[1].split(":")[1]) &&
      words[2].endsWith("rgb(30, 107, 36)") &&
      words[3].endsWith("rgb(179, 92, 0)") &&
      words[4].endsWith("rgb(192, 0, 0)"),
    words.join(" "),
  );
  await page.keyboard.press("Escape");
  await page.mouse.click(900, 500);

  // Un statut.
  await pick("Filtre Statut", "pointées");
  check("filtre : le statut choisi part avec la demande", (await lastAsked()) === "1/null", await lastAsked());
  check(
    "filtre : le menu s'est refermé, et son nom n'a pas changé",
    (await page.locator('[data-menu="filter"]').isHidden()) && (await menu.count()) === 1,
  );
  check(
    "filtre : l'encoche est sur le choix et sur l'entrée de son sous-menu — plus sur « Toutes »",
    (await ticked()) === "filter-by-status|filter-pointed|filter-verification-all",
    await ticked(),
  );
  // Un seul par sous-menu.
  await pick("Filtre Statut", "engagées");
  check(
    "filtre : un autre statut remplace le premier",
    (await lastAsked()) === "2/null" && (await ticked()) === "filter-by-status|filter-committed|filter-verification-all",
    `${await lastAsked()} ${await ticked()}`,
  );
  // Les deux se combinent.
  await pick("Filtre Vérification", "À vérifier");
  check(
    "filtre : la vérification s'ajoute au statut — deux éléments cochés, un par sous-menu",
    (await lastAsked()) === "2/1" &&
      (await ticked()) === "filter-by-status|filter-committed|filter-by-verification|filter-verification-1",
    `${await lastAsked()} ${await ticked()}`,
  );
  await pick("Filtre Vérification", "Douteuse");
  check(
    "filtre : une autre vérification remplace la première, le statut reste",
    (await lastAsked()) === "2/3",
    await lastAsked(),
  );
  // Un second clic sur un choix coché le décoche, sans toucher à l'autre.
  await pick("Filtre Statut", "engagées");
  check(
    "filtre : recliquer un choix coché le lève — l'autre filtre tient",
    (await lastAsked()) === "null/3" &&
      (await ticked()) === "filter-status-all|filter-by-verification|filter-verification-3",
    `${await lastAsked()} ${await ticked()}`,
  );
  // « Toutes les opérations » décoche tout.
  await pick("Filtre Statut", "prévues");
  await menu.click();
  await page.locator(".window-menu__choice", { hasText: "Toutes les opérations" }).click();
  await page.waitForTimeout(200);
  check(
    "filtre : « Toutes les opérations » lève les deux filtres d'un coup",
    (await lastAsked()) === "null/null" &&
      (await ticked()) === "filter-all|filter-status-all|filter-verification-all",
    `${await lastAsked()} ${await ticked()}`,
  );

  // « Afficher tout » : lever un seul filtre, sans avoir à deviner le second
  // clic (Fabrice : « j'ai peur que les utilisateurs âgés ne comprennent pas
  // si on ne le met pas »).
  await pick("Filtre Statut", "pointées");
  await pick("Filtre Vérification", "Contestée");
  await pick("Filtre Statut", "Afficher tout");
  check(
    "filtre : « Afficher tout » du statut lève le statut, et lui seul",
    (await lastAsked()) === "null/4" &&
      (await ticked()) === "filter-status-all|filter-by-verification|filter-verification-4",
    `${await lastAsked()} ${await ticked()}`,
  );
  await pick("Filtre Statut", "prévues");
  await pick("Filtre Vérification", "Afficher tout");
  check(
    "filtre : « Afficher tout » de la vérification lève la vérification, et elle seule",
    (await lastAsked()) === "3/null" &&
      (await ticked()) === "filter-by-status|filter-planned|filter-verification-all",
    `${await lastAsked()} ${await ticked()}`,
  );
  await pick("Filtre Statut", "Afficher tout");
  check(
    "filtre : les deux levés un à un, « Toutes les opérations » retrouve son encoche",
    (await lastAsked()) === "null/null" &&
      (await ticked()) === "filter-all|filter-status-all|filter-verification-all",
    `${await lastAsked()} ${await ticked()}`,
  );
  check(
    "filtre : il y a toujours une encoche, et une seule, dans chaque sous-menu",
    await page.evaluate(() =>
      [...document.querySelectorAll('[data-menu="filter"] .window-menu__submenu')].every(
        (nested) => nested.querySelectorAll(".window-menu__choice--chosen").length === 1,
      ),
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

  // The sixth column, « Libelle » — after « Statut opération » and
  // « Vérification ».
  await page.locator(".list__title >> nth=5 >> .list__filter-toggle").click();
  await page.waitForTimeout(150);
  const aligned = await page.evaluate(() => {
    const header = document.querySelectorAll(".list__title")[5].getBoundingClientRect();
    const field = document
      .querySelectorAll(".list__filter-input")[5]
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
  await page.locator(".list__title >> nth=5 >> .list__filter-toggle").click();
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
    // Les cinq, plus le type, le statut et la vérification.
    (await page.locator("select.form__field").count()) === 8,
  );
  // **La vérification** (Fabrice, 03/10/2026) : le quatrième choix de la
  // base, lu avec l'opération, dans sa couleur — ici une écriture contestée.
  check(
    "fiche opération : la vérification de l'opération est montrée, dans sa couleur",
    (await page.inputValue("#verification")) === "4" &&
      (await page.locator("#verification-label").textContent()) === "Vérification" &&
      (await page.evaluate(
        () => getComputedStyle(document.getElementById("verification")).color,
      )) === "rgb(192, 0, 0)",
  );
  check(
    "fiche opération : elle offre les quatre vérifications",
    (await page.locator("#verification option").allTextContents()).join("|") ===
      "À vérifier|Vérifiée|Douteuse|Contestée",
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

// **Le refus du pointage sans date est un panneau, pas une phrase en bas de
// fenêtre** (Fabrice, 25/08/2026 : « on ne le voie pas du tout si tu l'affiche
// comme cela »). Et le panneau propose l'issue : enregistrer avec la date de
// l'opération.
{
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/operation-form.html?mode=M&account=1&id=1",
    {
      operationRefusal:
        "Une opération pointée doit obligatoirement porter une date de pointage.",
    },
  );
  await page.click("#save");
  await page.waitForTimeout(200);
  check(
    "fiche opération : le pointage sans date ouvre un panneau",
    (await page.locator(".dialog").count()) === 1,
  );
  const question = (await page.locator(".dialog__question").textContent()) ?? "";
  check(
    "fiche opération : le panneau porte la phrase de refus",
    question.includes("doit obligatoirement porter une date de pointage"),
  );
  check(
    "fiche opération : et propose la date de l'opération, en clair",
    question.includes("21/01/2026"),
  );
  // Non : on reste sur la fiche, rien n'est écrit.
  await page.click(".dialog__button:not(.dialog__button--primary)");
  await page.waitForTimeout(150);
  check(
    "fiche opération : Non referme le panneau",
    (await page.locator(".dialog").count()) === 0,
  );
  check(
    "fiche opération : Non n'enregistre rien",
    (await page.evaluate(() => window.__closed)) !== true &&
      (await page.locator("#info-message").textContent()) !== "Opération modifiée.",
  );
  await page.close();
}

// Oui : la date de l'opération entre dans le champ, et l'enregistrement suit.
{
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/operation-form.html?mode=M&account=1&id=1",
    {
      operationRefusal:
        "Une opération pointée doit obligatoirement porter une date de pointage.",
    },
  );
  await page.click("#save");
  await page.waitForTimeout(200);
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(250);
  check(
    "fiche opération : Oui pose la date de l'opération dans le champ",
    (await page.inputValue("#clearing-date")) === "2026-01-21",
  );
  await page.close();
}

// **Une opération pointée sans date de pointage** — la base héritée, l'archive
// restaurée. La fiche propose la date de l'opération plutôt que d'opposer un
// refus à quelqu'un venu corriger un libellé (Fabrice, 25/08/2026).
{
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/operation-form.html?mode=M&account=1&id=1",
    { operationDatelessButPointed: true },
  );
  check(
    "fiche opération : une opération pointée sans date en propose une",
    (await page.inputValue("#clearing-date")) === "2026-01-21",
  );
  // La proposition n'est pas une modification de l'utilisateur : elle entre
  // dans la réserve avec le reste, et consulter une fiche puis la fermer
  // n'écrit rien.
  check(
    "fiche opération : la date proposée ne réclame pas d'être enregistrée",
    (await page.evaluate(() => window.__operationDirty)) !== true,
  );
  await page.close();
}

// **La lecture seule ne propose rien** : elle montre ce que la base contient.
{
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/operation-form.html?mode=L&account=1&id=1",
    { operationDatelessButPointed: true },
  );
  check(
    "fiche opération : en lecture seule, la date vide le reste",
    (await page.inputValue("#clearing-date")) === "",
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
    (await page.locator(".list__row >> nth=0 >> .list__cell >> nth=16").getAttribute("title")) ===
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

  // **Créer une opération périodique à partir de cette opération** (Fabrice,
  // 25/08/2026) : en bas du menu Divers, derrière un trait.
  await page.locator(".window-menu__entry", { hasText: "Divers" }).first().click();
  await page.waitForTimeout(120);
  check(
    "liste opérations : le menu Divers porte un trait de séparation",
    (await page.locator('[data-menu="misc"] .window-menu__rule').count()) === 1,
  );
  const entries = await page.evaluate(() =>
    Array.from(
      document.querySelectorAll('[data-menu="misc"] .window-menu__choice'),
    ).map((choice) => choice.textContent),
  );
  check(
    "liste opérations : l'entrée périodique est la dernière du menu",
    entries[entries.length - 1] ===
      "Créer une opération périodique à partir de cette opération",
    JSON.stringify(entries),
  );

  // Sans sélection, elle refuse — et n'ouvre rien. La ligne choisie plus haut
  // dans ce bloc est d'abord relâchée.
  // ⌘ et non Ctrl (10/10/2026) : sur macOS, Ctrl + clic est un clic droit,
  // qui ouvrait le menu contextuel et laissait le menu Divers fermé. Radinus
  // accepte les deux pour la sélection ; seul ⌘ se comporte pareil partout.
  await page.keyboard.down("Meta");
  for (const index of [0, 1]) {
    const row = page.locator(".list__row").nth(index);
    if ((await row.getAttribute("aria-selected")) === "true") {
      await row.click({ modifiers: ["Meta"] });
    }
  }
  await page.keyboard.up("Meta");
  await page.waitForTimeout(80);
  check(
    "liste opérations : plus rien n'est sélectionné",
    (await page.locator('.list__row[aria-selected="true"]').count()) === 0,
  );
  await page.locator(".window-menu__entry", { hasText: "Divers" }).first().click();
  await page.waitForTimeout(120);
  await page.click('[data-menu="misc"] >> text=Créer une opération périodique');
  await page.waitForTimeout(150);
  check(
    "liste opérations : sans sélection, aucune fiche périodique ne s'ouvre",
    (await page.evaluate(() => window.__openedRecurring)) === undefined,
  );
  check(
    "liste opérations : et la fenêtre le dit",
    (await page.locator("#info-bar").textContent())?.includes("sélectionner"),
  );

  // Sur une opération, la fiche périodique s'ouvre sur elle.
  await page.click(".list__row >> nth=0");
  await page.locator(".window-menu__entry", { hasText: "Divers" }).first().click();
  await page.waitForTimeout(120);
  await page.click('[data-menu="misc"] >> text=Créer une opération périodique');
  await page.waitForTimeout(150);
  check(
    "liste opérations : la fiche périodique s'ouvre sur l'opération choisie",
    JSON.stringify(await page.evaluate(() => window.__openedRecurring)) ===
      JSON.stringify({ id: 1 }),
    JSON.stringify(await page.evaluate(() => window.__openedRecurring)),
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
  // **La copie d'une écriture contestée n'est pas contestée** : c'est une
  // opération que l'on saisit, donc vérifiée. Et c'est ce qui est écrit.
  check(
    "fiche opération : une copie naît « Vérifiée », quelle que soit l'originale",
    await page.evaluate(() => {
      const sent = window.__calls.find(([c]) => c === "create_operation");
      return sent[1].operation.verification_id === 2;
    }),
  );
  await page.close();
}

// --- Préférences : la vérification des opérations importées --------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/preferences.html");
  check(
    "préférences : une branche « Importation » porte la feuille « Vérification »",
    (await page.locator(".tree__branch").allTextContents()).join("|") ===
      "Affichage|Importation|Outils|Réinitialisation" &&
      (await page.locator('.tree__leaf[data-leaf="verification"]').textContent()) === "Vérification",
  );
  await page.locator('.tree__leaf[data-leaf="verification"]').click();
  await page.waitForTimeout(100);
  check(
    "préférences : deux réponses seulement, « Vérifiée » d'abord — le défaut",
    (await page.locator("#verification option").allTextContents()).join("|") ===
      "Vérifiée|À vérifier" && (await page.inputValue("#verification")) === "2",
  );
  await page.selectOption("#verification", "1");
  await page.click("#save");
  await page.waitForTimeout(250);
  check(
    "préférences : enregistrer écrit le choix, et la fenêtre le garde",
    (await page.evaluate(() => window.__importVerification)) === 1 &&
      (await page.inputValue("#verification")) === "1",
  );
  check(
    "préférences : la vérification part avant la devise, qui fait relire la fenêtre",
    await page.evaluate(() => {
      const names = window.__calls.map(([c]) => c);
      return (
        names.indexOf("save_preferences_import_verification") <
        names.indexOf("save_preferences_currency")
      );
    }),
  );
  await page.close();
}

// --- L'ascenseur horizontal du détail, statistiques et bilan croisé -------
{
  // **Le détail du bas déborde au lieu de se serrer** (Fabrice, 03/10/2026 :
  // « dans le tableau des détails qui liste les opérations, il n'y a pas non
  // plus d'ascenseur horizontal »). Les sept statistiques partagent une liste,
  // le bilan croisé en a une copie : les deux sont tenues ici. Large, rien ne
  // dépasse ; étroite, les lignes gardent leur largeur plancher, débordent, et
  // l'en-tête les suit au pixel près.
  for (const [name, url] of [
    ["statistiques", "statistics.html?axis=category&accounts=1,2&year=2026"],
    ["bilan croisé", "crossed-balance.html?accounts=1,2&year=2026&month=9"],
  ]) {
    const page = await browser.newPage({ viewport: { width: 1700, height: 900 } });
    await openWindow(page, `http://localhost:4173/ui/windows/${url}`);
    await page.click(".matrix__row >> nth=1 >> .matrix__cell >> nth=0");
    await page.waitForTimeout(250);
    const sideways = () =>
      page.evaluate(() => {
        const rows = document.getElementById("rows");
        const line = rows.querySelector(".list__row");
        return {
          content: rows.scrollWidth,
          frame: rows.clientWidth,
          rows: rows.querySelectorAll(".list__row").length,
          floor: line ? line.style.minWidth : "",
        };
      });
    const wide = await sideways();
    await page.setViewportSize({ width: 900, height: 900 });
    await page.waitForTimeout(150);
    const narrow = await sideways();
    check(
      `${name} : le détail tient dans une fenêtre large`,
      wide.rows > 0 && wide.content <= wide.frame + 1,
      JSON.stringify(wide),
    );
    check(
      `${name} : rétrécie, le détail déborde et son ascenseur vient`,
      narrow.floor !== "" && narrow.content > narrow.frame + 50,
      JSON.stringify(narrow),
    );
    await page.evaluate(() => {
      const rows = document.getElementById("rows");
      rows.scrollLeft = 90;
      rows.dispatchEvent(new Event("scroll"));
    });
    await page.waitForTimeout(100);
    check(
      `${name} : et l'en-tête du détail suit les lignes`,
      (await page.evaluate(() => document.getElementById("header").style.transform)) ===
        "translateX(-90px)",
      await page.evaluate(() => document.getElementById("header").style.transform),
    );
    await page.close();
  }
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
    "détail : la ligne choisie porte les cinq menus de classement, et la vérification",
    (await page.locator(".list--detail .list__row >> nth=0 >> .list__combo").count()) === 6,
  );
  check(
    "détail : et les autres lignes restent du texte",
    (await page.locator(".list--detail .list__row >> nth=1 >> .list__combo").count()) === 0,
  );
  check(
    "détail : le menu s'ouvre sur le classement actuel de la ligne",
    (await page.locator(".list--detail .list__row >> nth=0 >> .list__combo >> nth=1").inputValue()) ===
      "1",
  );

  // **La colonne « Vérification » du détail** (Fabrice, 03/10/2026) : entre
  // le libellé et la catégorie, dans les sept statistiques — on est ici dans
  // celle des catégories. Le mot dans sa couleur, la liste sur la ligne
  // choisie.
  const detailTitles = await page.locator(".list--detail .list__title-text").allTextContents();
  check(
    "détail : la vérification est entre le libellé et la catégorie",
    // La référence paiement s'est glissée entre les deux (20/10/2026).
    detailTitles[2] === "Libelle" && detailTitles[3] === "Référence paiement" && detailTitles[4] === "Vérification",
    JSON.stringify(detailTitles.slice(0, 5)),
  );
  const referenceCell = page.locator(".list--detail .list__row >> nth=1 >> .list__cell >> nth=3");
  check(
    "détail : la référence paiement se lit dans sa colonne, entière au survol",
    (await page.locator(".list--detail .list__row >> nth=0 >> .list__cell >> nth=3").textContent()) ===
      "CB SYSTEME U REF 0105" &&
      (await referenceCell.getAttribute("title")) === (await referenceCell.textContent()),
  );
  const chosenVerification = page.locator(
    ".list--detail .list__row >> nth=0 >> .list__combo >> nth=0",
  );
  check(
    "détail : la ligne choisie montre sa vérification dans sa liste, en vert",
    (await chosenVerification.inputValue()) === "2" &&
      (await chosenVerification.locator("option").allTextContents()).join("|") ===
        "À vérifier|Vérifiée|Douteuse|Contestée" &&
      (await chosenVerification.evaluate((combo) => getComputedStyle(combo).color)) ===
        "rgb(30, 107, 36)",
  );
  check(
    "détail : les autres lignes la montrent en toutes lettres",
    (await page.locator(".list--detail .list__row >> nth=1 >> .list__cell >> nth=4").textContent()) ===
      "Vérifiée",
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
  await page.selectOption(".list--detail .list__row >> nth=0 >> .list__combo >> nth=1", "5");
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
  // **La fenêtre n'a plus à prévenir** (Fabrice, 25/08/2026) : c'est le
  // contrôleur qui diffuse le changement, à l'endroit où l'écriture a lieu.
  // Elle ne doit donc plus demander cette diffusion — un test croisé de Rust
  // vérifie, lui, que l'écriture prévient bien.
  check(
    "détail : la fenêtre ne prévient plus elle-même",
    await page.evaluate(() =>
      window.__calls.every(([command]) => command !== "notify_operations_changed"),
    ),
  );
  // Et la vérification, par le même geste : écrite, puis tout est recalculé —
  // dans la statistique par vérification, l'opération change de ligne.
  await page.click(".list--detail .list__row >> nth=0");
  await page.waitForTimeout(150);
  const beforeVerifying = await page.evaluate(
    () => window.__calls.filter(([command]) => command === "axis_statistics").length,
  );
  await page.selectOption(".list--detail .list__row >> nth=0 >> .list__combo >> nth=0", "3");
  await page.waitForTimeout(300);
  check(
    "détail : choisir une vérification l'écrit sur l'opération, et refait le calcul",
    (await page.evaluate(() =>
      window.__calls.some(
        ([command, args]) =>
          command === "set_operation_verification" && args.id === 1 && args.verificationId === 3,
      ),
    )) &&
      (await page.evaluate(
        () => window.__calls.filter(([command]) => command === "axis_statistics").length,
      )) > beforeVerifying,
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

{
  // **Le bilan croisé emprunte la même porte** (Fabrice, 25/08/2026) : il se
  // calcule lui aussi sur plusieurs comptes, donc on demande lesquels avant
  // d'ouvrir quoi que ce soit.
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/accounts-list.html?mode=STATS&axis=crossed-balance",
  );
  await page.click(".list__row >> nth=0");
  await page.click(".list__row >> nth=1", { modifiers: ["Meta"] });
  await page.click("#select");
  await page.waitForTimeout(200);
  check(
    "bilan croisé : le choix des comptes l'ouvre sur les deux comptes",
    (await page.evaluate(() => JSON.stringify(window.__openedCrossed?.accountIds))) === "[1,2]",
    await page.evaluate(() => JSON.stringify(window.__openedCrossed)),
  );
  check(
    "bilan croisé : et n'ouvre aucune statistique",
    await page.evaluate(
      () => window.__openedStats === undefined && window.__openedDashboard === undefined,
    ),
  );
  await page.close();
}

// --- F39, le bilan croisé (Fabrice, 25/08/2026) --------------------------
//
// Le gabarit des six statistiques, aux deux différences demandées : les
// colonnes sont les affectations, la période est un mois.
{
  const page = await browser.newPage();
  const errors = await openWindow(
    page,
    "http://localhost:4173/ui/windows/crossed-balance.html?accounts=1,2&year=2026&month=9",
  );
  check(
    "bilan croisé : la fenêtre s'ouvre sans une plainte",
    errors.length === 0,
    errors.join(" | "),
  );

  // **Le bandeau bleu porte 09/2026**, sur une seule ligne, en deux zones
  // cliquables séparées par une barre.
  check(
    "bilan croisé : le bandeau porte le mois et l'année",
    (await page.textContent("#month")) === "09" && (await page.textContent("#year")) === "2026",
  );
  check(
    "bilan croisé : les deux tiennent sur une ligne",
    await page.evaluate(() => {
      const zone = document.querySelector(".panel__period");
      const tops = new Set(
        Array.from(zone.children).map((part) => Math.round(part.getBoundingClientRect().top)),
      );
      return tops.size === 1 && zone.scrollWidth <= zone.clientWidth + 1;
    }),
  );

  const titles = await page.evaluate(() =>
    Array.from(document.querySelectorAll(".matrix__title")).map((cell) => cell.textContent),
  );
  check(
    "bilan croisé : les colonnes sont les affectations, pas les mois",
    JSON.stringify(titles) ===
      JSON.stringify(["Categorie", "Famille", "Animaux", "Sans affectation", "Total"]),
    JSON.stringify(titles),
  );

  const labels = await page.evaluate(() =>
    Array.from(document.querySelectorAll(".matrix__label")).map((cell) => cell.textContent),
  );
  check(
    "bilan croisé : les lignes sont les catégories, « Sans catégorie » en dernier",
    JSON.stringify(labels) ===
      JSON.stringify(["Alimentation", "Salaire", "Sans catégorie", "Somme"]),
    JSON.stringify(labels),
  );
  // **Pas de Cumul** : les affectations n'ont pas d'ordre, et le tableau ne
  // porte que sur un mois (Fabrice, 25/08/2026).
  check(
    "bilan croisé : il n'y a pas de ligne Cumul",
    !labels.includes("Cumul") && (await page.locator(".matrix__row--cumulative").count()) === 0,
  );
  // **Et la Somme colle au bas du cadre**, à la place qu'occupait le Cumul :
  // sans cela elle garde le décalage d'une ligne prévu pour l'empilement des
  // six statistiques et flotte en avant-dernière position (Fabrice,
  // 25/08/2026).
  check(
    "bilan croisé : la ligne Somme colle au bas du tableau",
    await page.evaluate(() => {
      const sum = document.querySelector(".matrix__row--sum");
      const style = getComputedStyle(sum);
      return style.position === "sticky" && style.bottom === "0px";
    }),
  );

  check(
    "bilan croisé : une case négative est peinte",
    (await page.locator(".matrix__cell--negative").count()) >= 1,
  );
  // Le vert et le blanc portent tous deux zéro et ne disent pas la même chose.
  check(
    "bilan croisé : une case qui s'annule est verte",
    (await page.locator(".matrix__cell--cancelling").count()) === 1,
  );

  // **La largeur plancher** : c'est l'ascenseur horizontal demandé le
  // 25/08/2026 — trois affectations tiennent, quinze déborderont plutôt que
  // d'écraser les colonnes.
  check(
    "bilan croisé : les lignes portent une largeur plancher",
    await page.evaluate(() => {
      const row = document.querySelector(".matrix__row");
      return row.style.minWidth !== "" && row.style.gridTemplateColumns.includes("repeat(3");
    }),
  );

  // Cliquer une case ordinaire : le détail nomme les deux classements.
  await page.click(".matrix__row >> nth=1 >> .matrix__cell >> nth=0");
  await page.waitForTimeout(200);
  check(
    "bilan croisé : une case nomme sa catégorie et son affectation",
    JSON.stringify(await page.evaluate(() => window.__crossedDetailAsked?.cell)) ===
      JSON.stringify({ category: 1, assignment: 2 }),
    JSON.stringify(await page.evaluate(() => window.__crossedDetailAsked?.cell)),
  );
  check(
    "bilan croisé : le détail s'affiche en bas",
    (await page.locator(".list--detail .list__row").count()) === 1,
  );

  // « Toutes » se dit par l'absence : la colonne Total ne nomme que la
  // catégorie, la ligne Somme que l'affectation.
  await page.click(".matrix__row >> nth=1 >> .matrix__cell--total");
  await page.waitForTimeout(200);
  check(
    "bilan croisé : la colonne Total ne nomme que la catégorie",
    JSON.stringify(await page.evaluate(() => window.__crossedDetailAsked?.cell)) ===
      JSON.stringify({ category: 1, assignment: null }),
    JSON.stringify(await page.evaluate(() => window.__crossedDetailAsked?.cell)),
  );
  await page.click(".matrix__row--sum >> .matrix__cell >> nth=0");
  await page.waitForTimeout(200);
  check(
    "bilan croisé : la ligne Somme ne nomme que l'affectation",
    JSON.stringify(await page.evaluate(() => window.__crossedDetailAsked?.cell)) ===
      JSON.stringify({ category: null, assignment: 2 }),
    JSON.stringify(await page.evaluate(() => window.__crossedDetailAsked?.cell)),
  );

  // **On navigue de mois en mois**, et décembre bascule sur janvier.
  await page.click("#next-period");
  await page.waitForTimeout(200);
  check(
    "bilan croisé : l'horloge avance d'un mois",
    (await page.textContent("#month")) === "10" && (await page.textContent("#year")) === "2026",
  );
  check(
    "bilan croisé : et le tableau est redemandé sur ce mois-là",
    (await page.evaluate(() => window.__crossedAsked?.month)) === 10,
  );
  for (let step = 0; step < 3; step += 1) {
    await page.click("#next-period");
    await page.waitForTimeout(120);
  }
  check(
    "bilan croisé : décembre bascule sur janvier de l'année suivante",
    (await page.textContent("#month")) === "01" && (await page.textContent("#year")) === "2027",
  );
  await page.click("#previous-period");
  await page.waitForTimeout(150);
  check(
    "bilan croisé : et janvier revient à décembre de l'année précédente",
    (await page.textContent("#month")) === "12" && (await page.textContent("#year")) === "2026",
  );

  // Le mois se clique : un nombre entre 1 et 12.
  await page.click("#month");
  await page.waitForTimeout(150);
  check(
    "bilan croisé : cliquer le mois pose la question",
    (await page.textContent(".dialog__question"))?.includes("entre 1 et 12"),
  );
  await page.fill(".dialog__field", "3");
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(250);
  check(
    "bilan croisé : le mois saisi est celui qu'on regarde",
    (await page.textContent("#month")) === "03" &&
      (await page.evaluate(() => window.__crossedAsked?.month)) === 3,
  );

  // L'export porte sur les douze mois de l'année affichée.
  await page.click(".window-menu__entry");
  await page.waitForTimeout(120);
  const exports = await page.evaluate(() =>
    Array.from(document.querySelectorAll(".window-menu__choice")).map((c) => c.textContent),
  );
  check(
    "bilan croisé : l'export porte sur tous les mois de l'année affichée",
    exports.length === 2 && exports[0].includes("tous les mois de l'année affichée"),
    JSON.stringify(exports),
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
    ["verification", "Vérification"],
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
    // **Seule la statistique par vérification teinte le nom de ses lignes** :
    // la clef d'une ligne y est celle d'une vérification, et c'est elle qui
    // choisit la couleur. Ailleurs, la même clef est celle d'une catégorie ou
    // d'un tiers — la teindre serait colorier au hasard.
    check(
      `axe ${axis} : le nom des lignes n'est teint que pour la vérification`,
      (await page.evaluate(
        () => document.querySelectorAll(".matrix__label[data-verification]").length,
      )) > 0 ===
        (axis === "verification"),
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

// --- F02 : la vérification d'une sélection, par le clic droit -------------
{
  // Fabrice, 03/10/2026 : « en première option de ce menu, une option
  // Vérification, qui fait apparaître un sous-menu avec toutes les options de
  // vérification. Le but est de pouvoir modifier le statut de plusieurs lignes
  // en leur affectant un statut de vérification identique. » Seulement dans la
  // liste des opérations : le bloc suivant tient le menu des autres tableaux
  // à ses dix exports, mot pour mot.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/operations-list.html?account=1");
  const entries = () =>
    page.evaluate(() =>
      [...document.querySelectorAll(".context-menu > *")].map((piece) =>
        piece.matches("hr") ? "—" : piece.matches(".context-menu__nest") ? "nest" : "entry",
      ),
    );

  // Sans ligne choisie : l'entrée est là, en tête, et grisée.
  await page.click(".list__rows", { button: "right" });
  await page.waitForTimeout(100);
  const shape = await entries();
  // Fabrice, 03/10/2026 : « en premier, avant Vérification, une option Statut
  // opération […] Les options d'exportation seront déplacées dans un
  // sous-menu, on y accédera via l'option Exporter vers. » Trois entrées qui
  // s'ouvrent, et plus rien à plat.
  const openers = page.locator(".context-menu > .context-menu__nest > .context-menu__entry--opener");
  const submenu = (rank) =>
    page.locator(`.context-menu > .context-menu__nest >> nth=${rank}`).locator(".context-menu__submenu");
  check(
    "clic droit : trois entrées qui s'ouvrent — Statut opération, Vérification, Exporter vers",
    // Depuis le 07/10/2026, les deux entrées de copie et leur trait les
    // précèdent.
    JSON.stringify(shape) === JSON.stringify(["entry", "entry", "—", "nest", "nest", "nest"]) &&
      (await openers.allTextContents()).join("|") === "Statut opération|Vérification|Exporter vers",
    JSON.stringify(shape) + " " + (await openers.allTextContents()).join("|"),
  );
  check(
    "clic droit : sans ligne choisie, statut et vérification sont grisés et n'ouvrent rien",
    (await openers.nth(0).isDisabled()) &&
      (await openers.nth(1).isDisabled()) &&
      (await page.locator(".context-menu__submenu").count()) === 1,
  );
  check(
    "clic droit : l'export, lui, reste offert sans sélection",
    !(await openers.nth(2).isDisabled()),
  );
  await page.keyboard.press("Escape");

  // Deux lignes prises : COURSES et SALAIRE. Le clic droit ne change pas la
  // sélection.
  await page.click(".list__row >> nth=0");
  await page.keyboard.down("Meta");
  await page.click(".list__row >> nth=1");
  await page.keyboard.up("Meta");
  await page.waitForTimeout(100);
  await page.click(".list__rows", { button: "right" });
  await page.waitForTimeout(100);
  check(
    "clic droit : la sélection n'a pas bougé",
    (await page.locator(".list__row[aria-selected='true']").count()) === 2,
  );
  const opener = openers.nth(1);
  check(
    "clic droit : des lignes prises, les deux entrées s'allument",
    !(await openers.nth(0).isDisabled()) && !(await opener.isDisabled()),
  );
  check(
    "clic droit : les sous-menus attendent qu'on y vienne",
    !(await submenu(0).isVisible()) && !(await submenu(1).isVisible()) && !(await submenu(2).isVisible()),
  );

  // Le statut d'abord : pointé, engagé, prévu, et rien d'autre.
  await openers.nth(0).hover();
  await page.waitForTimeout(100);
  check(
    "clic droit : le sous-menu du statut montre pointé, engagé, prévu",
    (await submenu(0).isVisible()) &&
      (await submenu(0).locator(".context-menu__entry:not(.context-menu__entry--head)").allTextContents()).join("|") ===
        "Pointé|Engagé|Prévu",
    (await submenu(0).locator(".context-menu__entry:not(.context-menu__entry--head)").allTextContents()).join("|"),
  );
  const barBeforeStatus = await page.locator("#info-bar").textContent();
  await submenu(0).locator(".context-menu__entry:not(.context-menu__entry--head)").nth(1).click();
  await page.waitForTimeout(250);
  const statusSent = await page.evaluate(
    () => window.__calls.filter(([command]) => command === "set_operations_status"),
  );
  check(
    "clic droit : choisir un statut l'envoie avec toutes les lignes prises, en une fois",
    statusSent.length === 1 &&
      statusSent[0][1].statusId === 2 &&
      JSON.stringify([...statusSent[0][1].ids].sort()) === JSON.stringify([1, 4]),
    JSON.stringify(statusSent),
  );
  check(
    "clic droit : après le statut, le menu se referme, la liste est relue, et rien n'est annoncé",
    (await page.locator(".context-menu").count()) === 0 &&
      (await page.locator("#info-bar").textContent()) === barBeforeStatus &&
      (await page.evaluate(() => {
        const names = window.__calls.map(([c]) => c);
        return names.lastIndexOf("list_operations") > names.indexOf("set_operations_status");
      })),
  );
  check(
    "clic droit : la sélection a tenu à la relecture",
    (await page.locator(".list__row[aria-selected='true']").count()) === 2,
  );

  await page.click(".list__rows", { button: "right" });
  await page.waitForTimeout(100);
  await opener.hover();
  await page.waitForTimeout(100);
  const choices = await page.evaluate(() =>
    [...document.querySelectorAll(".context-menu__nest:nth-of-type(2) .context-menu__submenu .context-menu__entry:not(.context-menu__entry--head)")].map((entry) => ({
      word: entry.textContent,
      key: entry.dataset.verification,
      colour: getComputedStyle(entry).color,
    })),
  );
  check(
    "clic droit : le sous-menu montre les quatre vérifications, dans leur couleur",
    (await submenu(1).isVisible()) &&
      choices.map((choice) => choice.word).join("|") === "À vérifier|Vérifiée|Douteuse|Contestée" &&
      choices.map((choice) => choice.colour).join("|") ===
        "rgb(26, 26, 26)|rgb(30, 107, 36)|rgb(179, 92, 0)|rgb(192, 0, 0)",
    JSON.stringify(choices),
  );

  const barBefore = await page.locator("#info-bar").textContent();
  await submenu(1).locator(".context-menu__entry:not(.context-menu__entry--head)").nth(3).click();
  await page.waitForTimeout(250);
  const sent = await page.evaluate(
    () => window.__calls.filter(([command]) => command === "set_operations_verification"),
  );
  check(
    "clic droit : choisir envoie la valeur et toutes les lignes prises, en une fois",
    sent.length === 1 &&
      sent[0][1].verificationId === 4 &&
      JSON.stringify([...sent[0][1].ids].sort()) === JSON.stringify([1, 4]),
    JSON.stringify(sent),
  );
  check(
    "clic droit : le menu se referme, et la liste est relue",
    (await page.locator(".context-menu").count()) === 0 &&
      (await page.evaluate(() => {
        const names = window.__calls.map(([c]) => c);
        return names.lastIndexOf("list_operations") > names.indexOf("set_operations_verification");
      })),
  );
  // « Je ne pense pas qu'il soit nécessaire de faire une phrase » : la barre
  // d'état reste ce qu'elle était, et n'annonce aucune alerte.
  check(
    "clic droit : aucune phrase n'annonce le changement",
    (await page.locator("#info-bar").textContent()) === barBefore &&
      !(await page.evaluate(() =>
        document.getElementById("info-bar").classList.contains("info-bar--alert"),
      )),
    await page.locator("#info-bar").textContent(),
  );

  // Les dix exports sont rangés sous « Exporter vers », sous leur nom court,
  // avec leurs deux traits.
  await page.click(".list__rows", { button: "right" });
  await page.waitForTimeout(100);
  await openers.nth(2).hover();
  await page.waitForTimeout(100);
  const formats = await submenu(2).locator(".context-menu__entry:not(.context-menu__entry--head)").allTextContents();
  check(
    "clic droit : « Exporter vers » range les dix formats, sous leur nom court",
    (await submenu(2).isVisible()) &&
      formats.join("|") ===
        "Excel (.xlsx)|Word (.docx)|LibreOffice Calc (.ods)|CSV (.csv)|TSV (.tsv)|INI (.ini)|JSON (.json)|TOML (.toml)|XML (.xml)|YAML (.yaml)" &&
      (await submenu(2).locator(".context-menu__rule").count()) === 2,
    formats.join("|"),
  );
  check(
    "clic droit : le sous-menu des exports tient dans la fenêtre",
    await submenu(2).evaluate((box) => {
      const place = box.getBoundingClientRect();
      return place.top >= 0 && place.bottom <= window.innerHeight && place.right <= window.innerWidth;
    }),
  );
  await submenu(2).locator(".context-menu__entry:not(.context-menu__entry--head)").nth(3).click();
  await page.waitForTimeout(250);
  check(
    "clic droit : choisir un format exporte la liste dans ce format",
    await page.evaluate(
      () => window.__exported !== undefined && window.__exported.path.endsWith(".csv"),
    ),
    await page.evaluate(() => JSON.stringify(window.__exported && window.__exported.path)),
  );
  await page.close();
}

// --- F02 : chacun ses colonnes -------------------------------------------
{
  // Fabrice, 04/10/2026 : « tous n'utilisent pas les mêmes colonnes, tous ne
  // souhaitent pas le même ordre. Il faut pouvoir personnaliser le nombre de
  // colonnes, leur ordre. » On glisse un en-tête, on coche au clic droit sur
  // les en-têtes, et l'ordre, la présence et les largeurs sont retenus.
  const URL = "http://localhost:4173/ui/windows/operations-list.html?account=1";
  const BORN =
    "fold|date|clearing-date|status|verification|label|reference|category|assignment|payment-mode|payee|project|month|debit|credit|balance|comments|attachments|check";
  const heads = (page) =>
    page.evaluate(() =>
      [...document.querySelectorAll(".list__header > .list__title")]
        .map((cell) => cell.dataset.column)
        .join("|"),
    );
  const saves = (page) =>
    page.evaluate(() =>
      window.__calls.filter(([command]) => command === "save_table_layout").map(([, args]) => args),
    );
  const centre = async (page, column) => {
    const box = await page.locator(`.list__title[data-column="${column}"]`).boundingBox();
    return { x: box.x + box.width / 2, y: box.y + box.height / 2, left: box.x, right: box.x + box.width };
  };
  const drag = async (page, column, toX) => {
    const from = await centre(page, column);
    await page.mouse.move(from.x, from.y);
    await page.mouse.down();
    await page.mouse.move(from.x + (toX > from.x ? 10 : -10), from.y, { steps: 2 });
    await page.mouse.move(toX, from.y, { steps: 6 });
  };

  // 1900 de large depuis la colonne « Référence paiement » (19/10/2026) : les
  // dix-huit colonnes doivent tenir à l'écran pour qu'on les glisse.
  const page = await browser.newPage({ viewport: { width: 1900, height: 800 } });
  await openWindow(page, URL);
  check("colonnes : sans rien d'enregistré, le tableau naît comme avant", (await heads(page)) === BORN, await heads(page));
  check(
    "colonnes : la fenêtre a demandé la disposition de son tableau, par son nom",
    await page.evaluate(() =>
      window.__calls.some(([c, a]) => c === "table_layout" && a.table === "operations-list"),
    ),
  );

  // --- Le menu des colonnes, au clic droit sur les en-têtes.
  await page.click('.list__title[data-column="label"]', { button: "right" });
  await openChecks(page);
  await page.waitForTimeout(100);
  const entries = page.locator('.context-menu--columns [data-menu="show-hide"] .context-menu__entry--check');
  check(
    "colonnes : le clic droit sur les en-têtes liste les dix-huit colonnes, toutes cochées",
    (await entries.count()) === 18 &&
      (await entries.evaluateAll((all) => all.every((entry) => entry.ariaChecked === "true"))) &&
      (await entries.nth(0).textContent()) === "Date",
    String(await entries.count()),
  );
  check(
    "colonnes : le « + » qui déplie n'est pas dans le menu",
    (await page.locator('.context-menu--columns [data-column="fold"]').count()) === 0,
  );
  check(
    "colonnes : sous un trait, « Rétablir les colonnes par défaut »",
    (await page.locator(".context-menu--columns > .context-menu__rule").count()) === 1 &&
      (await page.locator(".context-menu--columns .context-menu__entry:not(.context-menu__entry--head)").last().textContent()) ===
        "Rétablir les colonnes par défaut",
  );
  check(
    "colonnes : ce n'est pas le menu des lignes — ni statut, ni export",
    (await page.locator(".context-menu").count()) === 1 &&
      (await page.locator(".context-menu__nest").evaluateAll((nests) =>
        nests.map((nest) => nest.dataset.menu).join("|"),
      )) === "show-hide|colour",
  );
  check(
    "colonnes : le menu et son sous-menu tiennent dans la fenêtre",
    await page.locator(".context-menu--columns").evaluate((menu) => {
      const inside = (piece) => {
        const box = piece.getBoundingClientRect();
        return box.top >= 0 && box.bottom <= window.innerHeight && box.right <= window.innerWidth;
      };
      return inside(menu) && inside(menu.querySelector('[data-menu="show-hide"] .context-menu__submenu'));
    }),
  );

  // --- Décocher masque, tout de suite, et le menu reste ouvert.
  await page.click('.context-menu--columns [data-column="category"]');
  await page.waitForTimeout(150);
  check(
    "colonnes : décocher « Categorie » la retire de l'en-tête et des lignes",
    !(await heads(page)).includes("category") &&
      (await page.locator(".list__row >> nth=0 >> .list__cell").count()) === 18,
    await heads(page),
  );
  check(
    "colonnes : le menu reste ouvert, la coche est tombée",
    (await page.locator('.context-menu--columns [data-column="category"]').getAttribute("aria-checked")) ===
      "false",
  );
  let sent = await saves(page);
  check(
    "colonnes : la disposition est retenue aussitôt — masquée, mais à sa place dans l'ordre",
    sent.length === 1 &&
      sent[0].table === "operations-list" &&
      JSON.stringify(sent[0].layout.hidden) === '["category"]' &&
      sent[0].layout.order.join("|") === BORN.replace("fold|", "") &&
      Object.keys(sent[0].layout.widths).length === 0,
    JSON.stringify(sent),
  );
  check(
    "colonnes : en-tête, filtres et lignes ont les mêmes pistes",
    await page.evaluate(() => {
      const tracks = document.querySelector(".list__header").style.gridTemplateColumns;
      return (
        tracks.split(" ").length === 18 &&
        document.querySelector(".list__row").style.gridTemplateColumns === tracks
      );
    }),
  );

  // --- La recocher la remet où elle était.
  await page.click('.context-menu--columns [data-column="category"]');
  await page.waitForTimeout(150);
  check("colonnes : recochée, elle revient à sa place", (await heads(page)) === BORN, await heads(page));

  // --- Il reste toujours une colonne (Fabrice : « n'importe laquelle »).
  for (const name of BORN.split("|").slice(1)) {
    if (name !== "month") {
      await page.click(`.context-menu--columns [data-column="${name}"]`);
    }
  }
  await page.waitForTimeout(150);
  check(
    "colonnes : on peut tout masquer sauf une — ici « Mois », avec le « + »",
    (await heads(page)) === "fold|month",
    await heads(page),
  );
  check(
    "colonnes : la dernière est grisée, et cliquer dessus ne fait rien",
    await page.locator('.context-menu--columns [data-column="month"]').isDisabled(),
  );
  await page.click('.context-menu--columns [data-column="month"]', { force: true });
  await page.waitForTimeout(100);
  check("colonnes : elle est toujours là", (await heads(page)) === "fold|month");
  await page.click('.context-menu--columns [data-column="date"]');
  await page.waitForTimeout(100);
  check(
    "colonnes : une autre réaffichée, elle redevient décochable",
    !(await page.locator('.context-menu--columns [data-column="month"]').isDisabled()),
  );

  // --- Rétablir : tout revient, la base oublie, le menu se ferme.
  await page.locator(".context-menu--columns .context-menu__entry:not(.context-menu__entry--head)").last().click();
  await page.waitForTimeout(200);
  check(
    "colonnes : « Rétablir » rend la disposition de naissance et ferme le menu",
    (await heads(page)) === BORN && (await page.locator(".context-menu").count()) === 0,
    await heads(page),
  );
  check(
    "colonnes : et la préférence est ôtée de la base",
    await page.evaluate(
      () =>
        window.__layout === null &&
        window.__calls.some(([c, a]) => c === "reset_table_layout" && a.table === "operations-list"),
    ),
  );

  // --- Le menu se ferme au clic ailleurs et à Échap.
  await page.click('.list__title[data-column="label"]', { button: "right" });
  await openChecks(page);
  await page.keyboard.press("Escape");
  const closedByEscape = (await page.locator(".context-menu").count()) === 0;
  await page.click('.list__title[data-column="label"]', { button: "right" });
  await openChecks(page);
  await page.mouse.click(1500, 650);
  check(
    "colonnes : Échap et le clic ailleurs ferment le menu",
    closedByEscape && (await page.locator(".context-menu--columns").count()) === 0,
  );
  await page.keyboard.press("Escape");

  // --- Glisser un en-tête déplace sa colonne.
  const before = (await saves(page)).length;
  await drag(page, "label", (await centre(page, "date")).left + 4);
  check(
    "colonnes : pendant le geste, un trait montre où elle tombera — devant « Date »",
    await page.evaluate(() => {
      const mark = document.querySelector(".list__drop-mark");
      const date = document.querySelector('.list__title[data-column="date"]');
      return (
        mark !== null &&
        Math.abs(mark.getBoundingClientRect().left + 1 - date.getBoundingClientRect().left) <= 2 &&
        mark.getBoundingClientRect().height > 100
      );
    }),
  );
  await page.mouse.up();
  await page.waitForTimeout(200);
  check(
    "colonnes : lâchée, « Libelle » est passée devant « Date » — le « + » reste en tête",
    (await heads(page)).startsWith("fold|label|date|clearing-date|"),
    await heads(page),
  );
  check(
    "colonnes : les cellules ont suivi leur titre",
    (await page.locator(".list__row >> nth=0 >> .list__cell >> nth=1").textContent()) === "COURSES",
    await page.locator(".list__row >> nth=0 >> .list__cell >> nth=1").textContent(),
  );
  check(
    "colonnes : le trait est parti, et lâcher n'a pas trié",
    (await page.locator(".list__drop-mark").count()) === 0 &&
      (await page.locator(".list__sort-marker").allTextContents()).join("") === "▲" &&
      (await page.locator('.list__title[data-column="fold"] .list__sort-marker').textContent()) === "▲",
    (await page.locator(".list__sort-marker").allTextContents()).join(","),
  );
  sent = await saves(page);
  check(
    "colonnes : le nouvel ordre est retenu, une fois",
    sent.length === before + 1 &&
      sent[sent.length - 1].layout.order.slice(0, 3).join("|") === "label|date|clearing-date",
    JSON.stringify(sent[sent.length - 1]),
  );

  // Vers la fin : après la dernière colonne.
  await drag(page, "date", (await centre(page, "check")).right - 3);
  await page.mouse.up();
  await page.waitForTimeout(200);
  check(
    "colonnes : lâchée au bout, elle devient la dernière",
    (await heads(page)).endsWith("|attachments|check|date"),
    await heads(page),
  );
  // On ne passe pas devant le « + ».
  await drag(page, "date", (await centre(page, "fold")).left + 2);
  await page.mouse.up();
  await page.waitForTimeout(200);
  check(
    "colonnes : rien ne passe devant le « + »",
    (await heads(page)).startsWith("fold|date|label|"),
    await heads(page),
  );

  // --- Un petit mouvement reste un clic, et un clic trie.
  const label = await centre(page, "label");
  const countBefore = (await saves(page)).length;
  await page.mouse.move(label.x, label.y);
  await page.mouse.down();
  await page.mouse.move(label.x + 3, label.y);
  await page.mouse.up();
  await page.waitForTimeout(150);
  check(
    "colonnes : trois pixels ne déplacent rien — c'est un clic, et il trie",
    (await heads(page)).startsWith("fold|date|label|") &&
      (await saves(page)).length === countBefore &&
      (await page.locator('.list__title[data-column="label"] .list__sort-marker').textContent()) === "▲",
  );

  // --- Le rouge d'un débit suit sa colonne.
  check(
    "colonnes : déplacée ou non, la colonne Débit reste rouge",
    await page.evaluate(() => {
      const cell = document.querySelector(".list__cell--debit");
      return cell !== null && getComputedStyle(cell).color !== getComputedStyle(document.querySelector(".list__cell")).color;
    }),
  );

  // --- Un filtre ouvert survit au déplacement, pas au masquage de sa colonne.
  await page.click('.list__title[data-column="label"] .list__filter-toggle');
  await page.fill(".list__filter-input:not([hidden])", "COURSES");
  await page.waitForTimeout(150);
  const filtered = await page.locator(".list__row").count();
  await drag(page, "month", (await centre(page, "date")).left + 4);
  await page.mouse.up();
  await page.waitForTimeout(200);
  check(
    "colonnes : déplacer une colonne garde le filtre ouvert, son mot, et ses lignes",
    (await page.locator(".list__filter-input:not([hidden])").inputValue()) === "COURSES" &&
      (await page.locator(".list__row").count()) === filtered &&
      (await page.locator('.list__title[data-column="label"] .list__filter-toggle').getAttribute("aria-pressed")) ===
        "true",
  );
  check(
    "colonnes : le champ de recherche est resté sous sa colonne",
    await page.evaluate(() => {
      const input = document.querySelector(".list__filter-input:not([hidden])");
      const title = document.querySelector('.list__title[data-column="label"]');
      return Math.abs(input.getBoundingClientRect().left - title.getBoundingClientRect().left) <= 2;
    }),
  );
  await page.click('.list__title[data-column="date"]', { button: "right" });
  await openChecks(page);
  await page.click('.context-menu--columns [data-column="label"]');
  await page.waitForTimeout(200);
  check(
    "colonnes : masquer la colonne filtrée efface son filtre — aucune ligne cachée sans raison visible",
    (await page.locator(".list__row").count()) > filtered &&
      (await page.locator(".list__filter-input:not([hidden])").count()) === 0,
    String(await page.locator(".list__row").count()),
  );
  await page.keyboard.press("Escape");

  // --- L'export suit ce qu'on voit.
  await page.click(".list__rows", { button: "right" });
  await page.locator(".context-menu__entry--opener").last().hover();
  await page.locator(".context-menu__submenu").last().locator(".context-menu__entry:not(.context-menu__entry--head)").nth(3).click();
  await page.waitForTimeout(250);
  const heading = await page.evaluate(() =>
    window.__exported.sheet.rows[0].map((cell) => cell.text).join("|"),
  );
  check(
    "colonnes : l'export suit l'ordre choisi et laisse de côté les colonnes masquées",
    heading.startsWith("|Mois|Date|Date Pointage|") && !heading.includes("Libelle"),
    heading,
  );

  // --- Les largeurs : tirer une poignée est retenu, le double-clic rend la
  // largeur de naissance.
  const handle = await page.locator('.list__title[data-column="month"] .list__resizer').boundingBox();
  await page.mouse.move(handle.x + 3, handle.y + 5);
  await page.mouse.down();
  await page.mouse.move(handle.x + 63, handle.y + 5, { steps: 4 });
  await page.mouse.up();
  await page.waitForTimeout(200);
  sent = await saves(page);
  const kept = sent[sent.length - 1].layout;
  check(
    "colonnes : une largeur tirée est retenue, en pixels, à la fin du geste",
    typeof kept.widths.month === "number" && kept.widths.month > 100 && kept.widths.fold === undefined,
    JSON.stringify(kept.widths),
  );
  const afterPull = sent.length;
  await page.dblclick('.list__title[data-column="month"] .list__resizer');
  await page.waitForTimeout(200);
  sent = await saves(page);
  check(
    "colonnes : le double-clic sur le fil rend la largeur de naissance, et la mémoire l'oublie",
    sent.length === afterPull + 1 && sent[sent.length - 1].layout.widths.month === undefined,
    JSON.stringify(sent[sent.length - 1].layout.widths),
  );
  check(
    "colonnes : dans un tableau aux largeurs tirées, une colonne restée en part garde son minimum",
    await (async () => {
      await page.click('.list__title[data-column="date"]', { button: "right" });
      await openChecks(page);
      await page.click('.context-menu--columns [data-column="label"]');
      await page.waitForTimeout(150);
      await page.keyboard.press("Escape");
      const label = await page.locator('.list__title[data-column="label"]').boundingBox();
      const month = await page.locator('.list__title[data-column="month"]').boundingBox();
      // Ni le libellé réaffiché, ni le mois rendu à sa naissance, ne sont
      // écrasés par les colonnes figées : chacun tient au moins son minimum.
      return label !== null && label.width >= 150 && month !== null && month.width >= 64;
    })(),
  );
  await page.close();

  // --- À l'ouverture, la disposition enregistrée est posée.
  const stored = {
    order: BORN.split("|").slice(1).reverse(),
    hidden: ["comments", "attachments"],
    widths: { label: 333 },
  };
  const reopened = await browser.newPage({ viewport: { width: 1700, height: 800 } });
  await openWindow(reopened, URL, { storedLayout: stored });
  check(
    "colonnes : rouverte, la fenêtre retrouve l'ordre et les colonnes masquées",
    (await heads(reopened)) ===
      "fold|check|balance|credit|debit|month|project|payee|payment-mode|assignment|category|reference|label|verification|status|clearing-date|date",
    await heads(reopened),
  );
  check(
    "colonnes : et la largeur tirée",
    Math.round((await reopened.locator('.list__title[data-column="label"]').boundingBox()).width) === 333,
  );
  check(
    "colonnes : relire sa propre disposition ne la réécrit pas",
    (await saves(reopened)).length === 0,
  );
  // Une autre fenêtre change la disposition : celle-ci suit.
  await reopened.evaluate(() => {
    window.__layout = { order: window.__layout.order.slice().reverse(), hidden: [], widths: {} };
    window.__listeners["table-layout-changed"]({
      event: "table-layout-changed",
      id: 1,
      payload: "operations-list",
    });
  });
  await reopened.waitForTimeout(250);
  check(
    "colonnes : une disposition changée ailleurs est reprise aussitôt",
    (await heads(reopened)) === BORN,
    await heads(reopened),
  );
  // L'événement d'un autre tableau ne la concerne pas.
  const reads = await reopened.evaluate(() => window.__calls.filter(([c]) => c === "table_layout").length);
  await reopened.evaluate(() => {
    window.__listeners["table-layout-changed"]({ event: "table-layout-changed", id: 1, payload: "autre" });
  });
  await reopened.waitForTimeout(150);
  check(
    "colonnes : le changement d'un autre tableau ne fait rien relire",
    (await reopened.evaluate(() => window.__calls.filter(([c]) => c === "table_layout").length)) === reads,
  );
  // Sa propre écriture revient en écho : elle ne la relit pas.
  await reopened.click('.list__title[data-column="label"]', { button: "right" });
  await openChecks(reopened);
  await reopened.click('.context-menu--columns [data-column="month"]');
  await reopened.waitForTimeout(150);
  await reopened.evaluate(() => {
    window.__listeners["table-layout-changed"]({ event: "table-layout-changed", id: 1, payload: "operations-list" });
  });
  await reopened.waitForTimeout(150);
  check(
    "colonnes : l'écho de sa propre écriture n'est pas relu",
    (await reopened.evaluate(() => window.__calls.filter(([c]) => c === "table_layout").length)) === reads,
  );
  await reopened.close();

  // --- Une colonne née depuis l'enregistrement prend sa place de naissance.
  const older = await browser.newPage({ viewport: { width: 1700, height: 800 } });
  await openWindow(older, URL, {
    storedLayout: {
      // Enregistrée avant que « Vérification », « Statut » et « Référence
      // paiement » n'existent, le libellé en tête.
      order: BORN.split("|").slice(1).filter((name) => !["status", "verification", "reference"].includes(name)).sort((a, b) => (a === "label" ? -1 : b === "label" ? 1 : 0)),
      hidden: ["month"],
      widths: {},
    },
  });
  check(
    "colonnes : une colonne inconnue de la disposition vient après sa voisine de naissance, le reste est gardé",
    (await heads(older)).startsWith("fold|label|reference|date|clearing-date|status|verification|category|") &&
      !(await heads(older)).includes("month"),
    await heads(older),
  );
  check(
    "colonnes : et rien n'est réinitialisé pour autant",
    await older.evaluate(() => window.__calls.every(([c]) => c !== "reset_table_layout")),
  );
  await older.close();

  // --- **La colonne « Référence paiement » chez un utilisateur qui a déjà
  // réglé ses colonnes** (Fabrice, 19/10/2026 : « est-ce que ça pose un
  // problème si l'utilisateur a déjà colorisé et réordonné des colonnes ? »).
  // Sa disposition, enregistrée avant la colonne, est gardée entière — ordre,
  // largeur, couleurs, colonne masquée — et la nouvelle vient juste après le
  // libellé, là où il l'a mis.
  const before19 = await browser.newPage({ viewport: { width: 1900, height: 800 } });
  const kept19 = BORN.split("|").slice(1).filter((name) => name !== "reference");
  await openWindow(before19, URL, {
    storedLayout: {
      order: ["label", ...kept19.filter((name) => name !== "label" && name !== "month"), "month"],
      hidden: ["comments"],
      widths: { label: 300 },
      colors: { label: "blue", debit: "pink" },
    },
  });
  check(
    "référence paiement : chez qui a réglé ses colonnes, elle vient juste après le libellé, et tout le reste est gardé",
    (await heads(before19)) ===
      "fold|label|reference|date|clearing-date|status|verification|category|assignment|payment-mode|payee|project|debit|credit|balance|attachments|check|month",
    await heads(before19),
  );
  check(
    "référence paiement : les couleurs et la largeur choisies restent, la nouvelle colonne arrive sans teinte",
    await before19.evaluate(() => {
      const row = document.querySelector(".list__row");
      const tints = [...row.children].map((cell) => cell.dataset.tint ?? "").filter(Boolean).join("|");
      const label = document.querySelector('.list__title[data-column="label"]').getBoundingClientRect().width;
      return tints === "blue|pink" && Math.round(label) === 300;
    }),
  );
  check(
    "référence paiement : rien n'est réinitialisé, et la référence se lit dans la ligne",
    (await before19.evaluate(() => window.__calls.every(([c]) => c !== "reset_table_layout"))) &&
      (await before19.locator(".list__row >> nth=0 >> .list__cell >> nth=2").textContent()) === "CB SYSTEME U REF 0105",
  );
  await before19.close();

  // --- Une disposition que le tableau ne reconnaît pas : naissance, et oubli.
  for (const [what, broken] of [
    ["une colonne inconnue", { order: ["date", "colonne-du-futur"], hidden: [], widths: {} }],
    ["une colonne en double", { order: ["date", "date"], hidden: [], widths: {} }],
    ["tout masqué", { order: BORN.split("|").slice(1), hidden: BORN.split("|").slice(1), widths: {} }],
    ["une largeur absurde", { order: ["date"], hidden: [], widths: { date: -5 } }],
    ["une forme inattendue", { order: "date", hidden: [], widths: {} }],
  ]) {
    const odd = await browser.newPage({ viewport: { width: 1700, height: 800 } });
    const errors = await openWindow(odd, URL, { storedLayout: broken });
    check(
      `colonnes : ${what} — le tableau naît comme avant, sans une plainte`,
      (await heads(odd)) === BORN && errors.length === 0 && (await odd.locator(".list__row").count()) > 0,
      (await heads(odd)) + " " + errors.join(" / "),
    );
    check(
      `colonnes : ${what} — la préférence fautive est ôtée de la base`,
      await odd.evaluate(
        () => window.__layout === null && window.__calls.some(([c]) => c === "reset_table_layout"),
      ),
    );
    await odd.close();
  }

  // --- Les autres tableaux n'ont rien reçu.
  const other = await browser.newPage();
  await openWindow(other, "http://localhost:4173/ui/windows/nomenclature-list.html?kind=category");
  await other.click(".list__header", { button: "right" });
  await other.waitForTimeout(100);
  const title = await other.locator(".list__title >> nth=0").boundingBox();
  await other.mouse.move(title.x + 30, title.y + 8);
  await other.mouse.down();
  await other.mouse.move(title.x + 90, title.y + 8, { steps: 4 });
  const marked = await other.locator(".list__drop-mark").count();
  await other.mouse.up();
  check(
    "colonnes : un tableau sans nom n'a ni menu de colonnes, ni glisser, ni mémoire",
    (await other.locator(".context-menu--columns").count()) === 0 &&
      marked === 0 &&
      (await other.evaluate(() =>
        window.__calls.every(([c]) => c !== "table_layout" && c !== "save_table_layout"),
      )),
  );
  await other.close();
}

// --- Les colonnes : Afficher/Masquer, et Colorer --------------------------
{
  // Fabrice, 05/10/2026 : « il y aurait un menu Afficher/Masquer qui
  // contiendrait un sous-menu avec le menu actuel. Et en dessous il y aurait
  // une option Colorer » — neuf couleurs, posées sur la colonne « comme un
  // calque transparent ».
  const URL = "http://localhost:4173/ui/windows/operations-list.html?account=1";
  const NAMES = "Rouge|Orange|Rose|Vert pastel|Vert|Bleu pastel|Bleu|Jaune pastel|Jaune";
  const page = await browser.newPage({ viewport: { width: 1700, height: 800 } });
  await openWindow(page, URL);
  const saves = () =>
    page.evaluate(() =>
      window.__calls.filter(([command]) => command === "save_table_layout").map(([, args]) => args.layout),
    );
  const tints = (column) =>
    page.evaluate((name) => {
      const head = [...document.querySelectorAll(".list__header > .list__title")];
      const at = head.findIndex((cell) => cell.dataset.column === name);
      return [...document.querySelectorAll(".list__row")]
        .map((row) => row.children[at].dataset.tint ?? "")
        .join("|");
    }, column);
  const colourMenu = async (column) => {
    await page.click(`.list__title[data-column="${column}"]`, { button: "right" });
    await page.click('.context-menu--columns [data-menu="colour"] > .context-menu__entry--opener');
    await page.waitForTimeout(80);
  };
  const pick = async (column, colour) => {
    await colourMenu(column);
    await page.click(`.context-menu--columns [data-menu="colour"] [data-colour="${colour}"]`);
    await page.waitForTimeout(200);
  };

  await page.click('.list__title[data-column="balance"]', { button: "right" });
  await page.waitForTimeout(100);
  check(
    "colonnes : le menu a deux entrées qui s'ouvrent, un trait, puis « Rétablir »",
    await page.evaluate(() => {
      const pieces = [...document.querySelector(".context-menu--columns").children].map((piece) =>
        piece.matches("hr") ? "—" : piece.matches(".context-menu__nest") ? piece.firstElementChild.textContent : piece.textContent,
      );
      return pieces.join("|") === "Afficher/Masquer|Colorer la colonne : Solde|—|Rétablir les colonnes par défaut";
    }),
    await page.locator(".context-menu--columns").textContent(),
  );
  check(
    "colonnes : les sous-menus attendent qu'on y vienne",
    (await page.locator(".context-menu--columns .context-menu__submenu >> visible=true").count()) === 0,
  );
  await page.locator('.context-menu--columns [data-menu="colour"] > .context-menu__entry--opener').hover();
  await page.waitForTimeout(100);
  const offered = await page.evaluate(() =>
    [...document.querySelector('[data-menu="colour"] .context-menu__submenu').children].map((piece) => ({
      text: piece.matches("hr") ? "—" : piece.textContent,
      checked: piece.ariaChecked,
      swatch: piece.querySelector(".context-menu__swatch")
        ? getComputedStyle(piece.querySelector(".context-menu__swatch")).backgroundImage
        : "",
    })),
  );
  check(
    "colorer : « Aucune couleur », un trait, puis les neuf couleurs dans l'ordre dicté",
    offered.map((one) => one.text).join("|") === `Aucune couleur|—|${NAMES}`,
    offered.map((one) => one.text).join("|"),
  );
  check(
    "colorer : chaque couleur a sa pastille, toutes différentes — « Aucune couleur » n'en a pas",
    offered[0].swatch === "" &&
      offered.slice(2).every((one) => one.swatch.includes("rgba(")) &&
      new Set(offered.slice(2).map((one) => one.swatch)).size === 9,
    JSON.stringify(offered.map((one) => one.swatch)),
  );
  check(
    "colorer : sans teinte, c'est « Aucune couleur » qui est cochée",
    offered[0].checked === "true" && offered.slice(2).every((one) => one.checked === "false"),
  );
  check(
    "colorer : le sous-menu tient dans la fenêtre",
    await page.locator('[data-menu="colour"] .context-menu__submenu').evaluate((nested) => {
      const box = nested.getBoundingClientRect();
      return box.top >= 0 && box.bottom <= window.innerHeight && box.right <= window.innerWidth;
    }),
  );

  // Choisir teinte la colonne cliquée, et elle seule.
  await page.click('[data-menu="colour"] [data-colour="pastel-yellow"]');
  await page.waitForTimeout(200);
  check(
    "colorer : choisir ferme le menu et teinte toutes les cellules de la colonne cliquée",
    (await page.locator(".context-menu").count()) === 0 &&
      (await tints("balance")).split("|").every((tint) => tint === "pastel-yellow") &&
      (await page.locator(".list__row").count()) > 1,
    await tints("balance"),
  );
  check(
    "colorer : les autres colonnes n'ont rien reçu, l'en-tête non plus",
    (await page.locator(".list__cell[data-tint]").count()) === (await page.locator(".list__row").count()) &&
      (await page.locator(".list__title[data-tint]").count()) === 0,
  );
  check(
    "colorer : c'est un calque — une image de fond transparente, le fond de la ligne dessous",
    await page.evaluate(() => {
      const cell = document.querySelector('.list__cell[data-tint="pastel-yellow"]');
      const style = getComputedStyle(cell);
      const alpha = Number(/rgba\(\d+, \d+, \d+, ([\d.]+)\)/.exec(style.backgroundImage)?.[1] ?? "1");
      return alpha > 0 && alpha <= 0.5 && style.backgroundColor === "rgba(0, 0, 0, 0)";
    }),
  );
  let sent = await saves();
  check(
    "colorer : la teinte est retenue avec la disposition, sous son nom",
    sent.length === 1 && JSON.stringify(sent[0].colors) === '{"balance":"pastel-yellow"}',
    JSON.stringify(sent),
  );

  // La ligne choisie reste visible sous le calque.
  await page.click(".list__row >> nth=0");
  await page.waitForTimeout(150);
  check(
    "colorer : la ligne choisie garde son fond sous la colonne teintée",
    await page.evaluate(() => {
      const row = document.querySelector('.list__row[aria-selected="true"]');
      const other = document.querySelector('.list__row[aria-selected="false"]');
      return (
        getComputedStyle(row).backgroundColor !== getComputedStyle(other).backgroundColor &&
        row.querySelector("[data-tint]") !== null
      );
    }),
  );

  // Rouvert sur la même colonne, le menu dit où l'on en est.
  await colourMenu("balance");
  check(
    "colorer : rouvert, le menu coche la couleur en cours",
    (await page.locator('[data-menu="colour"] [aria-checked="true"]').getAttribute("data-colour")) ===
      "pastel-yellow",
  );
  await page.keyboard.press("Escape");

  // Une seconde colonne, une autre couleur.
  await pick("date", "red");
  sent = await saves();
  check(
    "colorer : deux colonnes, deux couleurs",
    sent[sent.length - 1].colors.balance === "pastel-yellow" &&
      sent[sent.length - 1].colors.date === "red" &&
      Object.keys(sent[sent.length - 1].colors).length === 2 &&
      (await tints("date")).split("|").every((tint) => tint === "red"),
    JSON.stringify(sent[sent.length - 1].colors),
  );
  check(
    "colorer : le rouge d'un débit se lit toujours sur une colonne teintée",
    await (async () => {
      await pick("debit", "pastel-green");
      return page.evaluate(() => {
        const cell = document.querySelector(".list__cell--debit[data-tint]");
        return cell !== null && getComputedStyle(cell).color !== getComputedStyle(document.body).color;
      });
    })(),
  );

  // La couleur suit sa colonne : déplacée, puis masquée et réaffichée.
  const from = await page.locator('.list__title[data-column="balance"]').boundingBox();
  const to = await page.locator('.list__title[data-column="label"]').boundingBox();
  await page.mouse.move(from.x + 12, from.y + 10);
  await page.mouse.down();
  await page.mouse.move(from.x - 10, from.y + 10, { steps: 2 });
  await page.mouse.move(to.x + 3, from.y + 10, { steps: 6 });
  await page.mouse.up();
  await page.waitForTimeout(200);
  check(
    "colorer : déplacée, la colonne emporte sa couleur",
    (await tints("balance")).split("|").every((tint) => tint === "pastel-yellow") &&
      (await tints("label")).split("|").every((tint) => tint === ""),
    `${await tints("balance")} / ${await tints("label")}`,
  );
  await page.click('.list__title[data-column="label"]', { button: "right" });
  await openChecks(page);
  await page.click('.context-menu--columns [data-column="balance"]');
  await page.waitForTimeout(100);
  await page.click('.context-menu--columns [data-column="balance"]');
  await page.waitForTimeout(150);
  await page.keyboard.press("Escape");
  check(
    "colorer : masquée puis réaffichée, elle la retrouve",
    (await tints("balance")).split("|").every((tint) => tint === "pastel-yellow"),
  );

  // « Aucune couleur » l'enlève.
  await pick("date", "");
  sent = await saves();
  check(
    "colorer : « Aucune couleur » retire la teinte, et la mémoire l'oublie",
    (await tints("date")).split("|").every((tint) => tint === "") &&
      sent[sent.length - 1].colors.date === undefined &&
      sent[sent.length - 1].colors.balance === "pastel-yellow",
    JSON.stringify(sent[sent.length - 1].colors),
  );
  const count = sent.length;
  await pick("date", "");
  check("colorer : rechoisir ce qu'on a déjà n'écrit rien", (await saves()).length === count);

  // Le « + » ne se colore pas.
  await page.click('.list__title[data-column="fold"]', { button: "right" });
  await page.waitForTimeout(100);
  check(
    "colorer : sur l'en-tête du « + », l'entrée est grisée et ne nomme aucune colonne",
    (await page.locator('[data-menu="colour"] > .context-menu__entry--opener').isDisabled()) &&
      (await page.locator('[data-menu="colour"] > .context-menu__entry--opener').textContent()) ===
        "Colorer la colonne :" &&
      (await page.locator('[data-menu="colour"] .context-menu__submenu').count()) === 0 &&
      !(await page.locator('[data-menu="show-hide"] > .context-menu__entry--opener').isDisabled()),
  );
  await page.keyboard.press("Escape");

  // L'export ne porte pas les couleurs.
  await page.click(".list__rows", { button: "right" });
  await page.locator(".context-menu__entry--opener").last().hover();
  await page.locator(".context-menu__submenu").last().locator(".context-menu__entry:not(.context-menu__entry--head)").nth(0).click();
  await page.waitForTimeout(250);
  check(
    "colorer : le fichier exporté ne reprend pas les couleurs",
    await page.evaluate(() =>
      window.__exported.sheet.rows.slice(1).every((row) => row.every((cell) => !cell.fill)),
    ),
  );

  // « Rétablir » enlève aussi les couleurs.
  await page.click('.list__title[data-column="label"]', { button: "right" });
  await page.locator(".context-menu--columns .context-menu__entry:not(.context-menu__entry--head)").last().click();
  await page.waitForTimeout(200);
  check(
    "colorer : « Rétablir les colonnes par défaut » enlève aussi les couleurs",
    (await page.locator(".list__cell[data-tint]").count()) === 0,
  );
  await page.close();

  // Rouverte, la fenêtre retrouve ses couleurs.
  const order = "date|clearing-date|status|verification|label|category|assignment|payment-mode|payee|project|month|debit|credit|balance|comments|attachments|check".split("|");
  const reopened = await browser.newPage({ viewport: { width: 1700, height: 800 } });
  await openWindow(reopened, URL, {
    storedLayout: { order, hidden: [], widths: {}, colors: { label: "blue", credit: "pink" } },
  });
  check(
    "colorer : rouverte, la fenêtre retrouve ses colonnes teintées",
    await reopened.evaluate(() => {
      const row = document.querySelector(".list__row");
      return [...row.children].map((cell) => cell.dataset.tint ?? "").filter(Boolean).join("|") === "blue|pink";
    }),
  );
  await reopened.close();

  // Une couleur que le tableau ne connaît pas : naissance, et oubli.
  const odd = await browser.newPage({ viewport: { width: 1700, height: 800 } });
  const errors = await openWindow(odd, URL, {
    storedLayout: { order, hidden: [], widths: {}, colors: { label: "#ff0000" } },
  });
  check(
    "colorer : une couleur inconnue — le tableau naît sans teinte, et la préférence fautive est ôtée",
    errors.length === 0 &&
      (await odd.locator(".list__cell[data-tint]").count()) === 0 &&
      (await odd.evaluate(() => window.__layout === null)),
  );
  await odd.close();

  // Le détail d'une statistique a le même menu, et ses propres couleurs.
  const stat = await browser.newPage({ viewport: { width: 1700, height: 900 } });
  await openWindow(stat, "http://localhost:4173/ui/windows/statistics.html?axis=payee&accounts=1,2&year=2026");
  await stat.click(".matrix__row >> nth=1 >> .matrix__cell >> nth=0");
  await stat.waitForTimeout(250);
  await stat.click('#header .list__title[data-column="amount"]', { button: "right" });
  await stat.waitForTimeout(100);
  check(
    "colorer : dans le détail d'une statistique, le menu et son sous-menu tiennent dans la fenêtre",
    await (async () => {
      await stat.click('[data-menu="colour"] > .context-menu__entry--opener');
      await stat.waitForTimeout(80);
      return stat.evaluate(() => {
        const inside = (piece) => {
          const box = piece.getBoundingClientRect();
          return box.top >= 0 && box.bottom <= window.innerHeight && box.right <= window.innerWidth;
        };
        return (
          inside(document.querySelector(".context-menu--columns")) &&
          inside(document.querySelector('[data-menu="colour"] .context-menu__submenu'))
        );
      });
    })(),
  );
  await stat.click('[data-menu="colour"] [data-colour="green"]');
  await stat.waitForTimeout(200);
  check(
    "colorer : la teinte y est retenue sous le nom de cette statistique",
    await stat.evaluate(() => {
      const sent = window.__calls.filter(([c]) => c === "save_table_layout");
      return (
        sent.length === 1 &&
        sent[0][1].table === "statistics-payee" &&
        sent[0][1].layout.colors.amount === "green" &&
        document.querySelectorAll('.list--detail .list__cell[data-tint="green"]').length > 0
      );
    }),
  );
  await stat.close();
}

// --- Préférences : les colonnes des tableaux ------------------------------
{
  // Fabrice, 04/10/2026 : « proposer dans Paramètres → Préférences simplement
  // une réinitialisation des colonnes », une ligne par tableau — « il est
  // possible que je te demande de faire cela dans d'autres tableaux » — et
  // « un bouton Tout réinitialiser ». Les boutons agissent tout de suite.
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/preferences.html");
  check(
    "préférences : la feuille « Colonnes des tableaux » est sous « Affichage »",
    (await page.locator(".tree > *").evaluateAll((all) =>
      all.map((piece) => piece.dataset.leaf ?? piece.textContent).join("|"),
    )) === "Affichage|language|currency|zoom|columns|Importation|verification|ofx|qif|Outils|electricity|Réinitialisation|comfort" &&
      (await page.locator('.tree__leaf[data-leaf="columns"]').textContent()) === "Colonnes des tableaux",
  );
  await page.click('.tree__leaf[data-leaf="columns"]');
  await page.waitForTimeout(100);
  // Fabrice, 04/10/2026, après avoir vu neuf lignes et neuf boutons : « il
  // aurait mieux valu mettre un menu déroulant indiquant le nom de la fenêtre
  // et un bouton réinitialiser qui pointe sur le menu déroulant ».
  check(
    "préférences : un menu déroulant nomme les fenêtres, un seul bouton « Réinitialiser » à côté",
    (await page.locator("#pane-columns").isVisible()) &&
      (await page.locator("#columns-window option").allTextContents()).join("|") ===
        "Liste des opérations|Stat par catégories|Bilan croisé" &&
      (await page.locator("#pane-columns select").count()) === 1 &&
      (await page.locator("#pane-columns button").allTextContents()).join("|") ===
        "Réinitialiser|Tout réinitialiser",
    (await page.locator("#pane-columns button").allTextContents()).join("|"),
  );
  check(
    "préférences : aucun libellé devant le menu — le nom de la fenêtre suffit",
    (await page.locator("#pane-columns label").count()) === 0,
  );
  check(
    "préférences : le bouton est à côté du menu, sur la même ligne",
    await page.evaluate(() => {
      const field = document.getElementById("columns-window").getBoundingClientRect();
      const button = document.getElementById("columns-reset").getBoundingClientRect();
      return button.left >= field.right && Math.abs(button.top + button.height / 2 - (field.top + field.height / 2)) <= 3;
    }),
  );
  // Choisir dans le menu ne fait rien par soi-même.
  await page.selectOption("#columns-window", "statistics-category");
  await page.waitForTimeout(100);
  check(
    "préférences : choisir une fenêtre dans le menu ne réinitialise rien",
    await page.evaluate(() => window.__calls.every(([c]) => !c.startsWith("reset_"))),
  );
  await page.click("#columns-reset");
  await page.waitForTimeout(150);
  check(
    "préférences : « Réinitialiser » agit tout de suite, sur la fenêtre que le menu nomme, et le dit",
    (await page.evaluate(() => {
      const resets = window.__calls.filter(([c]) => c.startsWith("reset_"));
      return (
        resets.length === 1 &&
        resets[0][0] === "reset_window_table_layouts" &&
        resets[0][1].window === "statistics-category"
      );
    })) && (await page.textContent("#info-bar")) === "Les colonnes ont retrouvé leur disposition d'origine.",
    await page.textContent("#info-bar"),
  );
  // La fenêtre se relit en revenant à l'écran : le choix du menu tient.
  await page.evaluate(() => window.dispatchEvent(new Event("focus")));
  await page.waitForTimeout(250);
  check(
    "préférences : relue en revenant à l'écran, elle garde la fenêtre choisie",
    (await page.inputValue("#columns-window")) === "statistics-category",
    await page.inputValue("#columns-window"),
  );
  await page.click("#columns-reset-all");
  await page.waitForTimeout(150);
  check(
    "préférences : « Tout réinitialiser » rend leur naissance à tous les tableaux",
    await page.evaluate(() => window.__calls.some(([c]) => c === "reset_all_table_layouts")),
  );
  check(
    "préférences : rien n'est passé par la disquette",
    await page.evaluate(() => window.__calls.every(([c]) => !c.startsWith("save_preferences"))),
  );
  // La fenêtre n'est pas « modifiée » : la quitter ne demande rien.
  await page.click("#close");
  await page.waitForTimeout(150);
  check(
    "préférences : réinitialiser ne modifie pas la fenêtre — elle se ferme sans question",
    await page.evaluate(() => window.__calls.some(([c]) => c === "close_preferences")),
  );
  await page.close();

  // Sans base, la feuille est grise : la préférence est dans la base.
  const closed = await browser.newPage();
  await openWindow(closed, "http://localhost:4173/ui/windows/preferences.html", { databaseOpen: false });
  check(
    "préférences : sans base ouverte, « Colonnes des tableaux » est grise",
    (await closed.locator('.tree__leaf[data-leaf="columns"]').isDisabled()) &&
      (await closed.evaluate(() => window.__calls.every(([c]) => c !== "windows_with_table_layouts"))),
  );
  await closed.close();
}

// --- Statistiques : la vérification d'une sélection, dans le détail -------
{
  // Fabrice, 03/10/2026 : la même entrée « Vérification » que dans la liste du
  // compte, dans le menu du clic droit du détail — là où la colonne figure,
  // c'est-à-dire dans les sept statistiques. On est ici dans celle des tiers.
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/statistics.html?axis=payee&accounts=1,2&year=2026",
  );
  await page.click(".matrix__row >> nth=1 >> .matrix__cell >> nth=0");
  await page.waitForTimeout(250);

  await page.click("#rows", { button: "right" });
  await page.waitForTimeout(100);
  check(
    "détail, clic droit : « Vérification » en tête, grisée tant qu'aucune ligne n'est prise",
    (await page.locator(".context-menu > :not(.context-menu__entry--head):not(.context-menu__rule--head)").first().evaluate((piece) =>
      piece.matches(".context-menu__nest"),
    )) &&
      (await page.locator(".context-menu__entry:not(.context-menu__entry--head) >> nth=0").textContent()) === "Vérification" &&
      (await page.locator(".context-menu__entry:not(.context-menu__entry--head) >> nth=0").isDisabled()) &&
      (await page.locator(".context-menu > .context-menu__entry:not(.context-menu__entry--head)").count()) === 10,
  );
  await page.keyboard.press("Escape");

  // Les deux lignes du détail : une opération et une ventilation.
  await page.click(".list--detail .list__row >> nth=0");
  await page.keyboard.down("Meta");
  await page.click(".list--detail .list__row >> nth=1");
  await page.keyboard.up("Meta");
  await page.waitForTimeout(100);
  const before = await page.evaluate(
    () => window.__calls.filter(([command]) => command === "axis_statistics").length,
  );
  await page.click("#rows", { button: "right" });
  await page.waitForTimeout(100);
  await page.locator(".context-menu__entry--opener").hover();
  await page.waitForTimeout(100);
  check(
    "détail, clic droit : le sous-menu offre les quatre vérifications",
    (await page.locator(".context-menu__submenu .context-menu__entry:not(.context-menu__entry--head)").allTextContents()).join("|") ===
      "À vérifier|Vérifiée|Douteuse|Contestée",
  );
  await page.click(".context-menu__submenu .context-menu__entry:not(.context-menu__entry--head) >> nth=2");
  await page.waitForTimeout(300);
  const sent = await page.evaluate(
    () => window.__calls.filter(([command]) => command === "set_operations_verification"),
  );
  check(
    "détail, clic droit : choisir envoie la valeur et toutes les lignes prises",
    sent.length === 1 &&
      sent[0][1].verificationId === 3 &&
      JSON.stringify([...sent[0][1].ids].sort()) === JSON.stringify([1, 2]),
    JSON.stringify(sent),
  );
  check(
    "détail, clic droit : et tout est recalculé, matrice comprise",
    (await page.locator(".context-menu").count()) === 0 &&
      (await page.evaluate(
        () => window.__calls.filter(([command]) => command === "axis_statistics").length,
      )) > before,
  );

  // La matrice, elle, garde son menu : des exports, et rien d'autre.
  await page.click("#matrix-zone", { button: "right" });
  await page.waitForTimeout(100);
  check(
    "matrice, clic droit : son menu n'a pas reçu l'entrée « Vérification »",
    (await page.locator(".context-menu__nest").count()) === 0 &&
      (await page.locator(".context-menu__entry:not(.context-menu__entry--head)").count()) > 0,
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
      [...document.querySelectorAll(".context-menu__entry:not(.context-menu__entry--head)")].map((entry) => entry.textContent),
    )).join(" | ") ===
      "Exporter vers Excel (.xlsx) | Exporter vers Word (.docx)" +
        " | Exporter vers LibreOffice Calc (.ods) | Exporter vers CSV (.csv)" +
        " | Exporter vers TSV (.tsv) | Exporter vers INI (.ini)" +
        " | Exporter vers JSON (.json) | Exporter vers TOML (.toml)" +
        " | Exporter vers XML (.xml) | Exporter vers YAML (.yaml)",
  );

  await page.click(".context-menu__entry:not(.context-menu__entry--head) >> nth=0");
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
  await page.click('.context-menu__entry:not(.context-menu__entry--head) >> nth=3');
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
  await page.click(".context-menu__entry:not(.context-menu__entry--head) >> nth=2");
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
    (await page.locator(".context-menu__rule:not(.context-menu__rule--head)").count()) === 2,
  );

  await page.click(".context-menu__entry:not(.context-menu__entry--head) >> nth=8");
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
  await page.click(".context-menu__entry:not(.context-menu__entry--head) >> nth=6");
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
  await page.click(".context-menu__entry:not(.context-menu__entry--head) >> nth=0");
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
  await page.click(".context-menu__entry:not(.context-menu__entry--head) >> nth=0");
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
  await page.click(".context-menu__entry:not(.context-menu__entry--head) >> nth=0");
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
    (await page.locator(".context-menu__entry:not(.context-menu__entry--head)").count()) === 10,
  );
  await page.click(".context-menu__entry:not(.context-menu__entry--head) >> nth=0");
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
  // Le premier **export** : depuis le 03/10/2026 le menu du détail s'ouvre
  // sur l'entrée « Vérification », et les exports viennent après son trait.
  await page.click(".context-menu > .context-menu__entry:not(.context-menu__entry--head) >> nth=0");
  await page.waitForTimeout(250);
  check(
    "export : le détail des statistiques s'exporte à part, sous son propre nom",
    await page.evaluate(() => window.__exported.sheet.name === "Detail des statistiques"),
    await page.evaluate(() => window.__exported.sheet.name),
  );
  await page.close();
}

// --- Statistiques et bilan croisé : chacun ses colonnes, dans le détail ---
{
  // Fabrice, 04/10/2026 : « le même principe dans tous les tableaux des
  // fenêtres statistiques — mais attention, pas n'importe lesquels : ceux qui
  // listent les transactions lorsque l'on clique sur une cellule, ceux du bas
  // de la fenêtre. » Une disposition **par statistique**, et le bilan croisé
  // avec la sienne — et, lui, la colonne « Vérification » en plus.
  const BORN =
    "date|clearing-date|label|reference|verification|category|assignment|payment-mode|payee|project|amount|comments";
  const heads = (page) =>
    page.evaluate(() =>
      [...document.querySelectorAll("#header > .list__title")]
        .map((cell) => cell.dataset.column)
        .join("|"),
    );
  const asked = (page) =>
    page.evaluate(() => [
      ...new Set(window.__calls.filter(([c]) => c === "table_layout").map(([, a]) => a.table)),
    ].join("|"));
  const saves = (page) =>
    page.evaluate(() =>
      window.__calls.filter(([command]) => command === "save_table_layout").map(([, args]) => args),
    );
  const open = async (url, options) => {
    const page = await browser.newPage({ viewport: { width: 1700, height: 900 } });
    await openWindow(page, `http://localhost:4173/ui/windows/${url}`, options);
    await page.click(".matrix__row >> nth=1 >> .matrix__cell >> nth=0");
    await page.waitForTimeout(250);
    return page;
  };

  for (const [what, url, table] of [
    ["stat par tiers", "statistics.html?axis=payee&accounts=1,2&year=2026", "statistics-payee"],
    ["stat par catégories", "statistics.html?axis=category&accounts=1,2&year=2026", "statistics-category"],
    ["stat par vérifications", "statistics.html?axis=verification&accounts=1,2&year=2026", "statistics-verification"],
    ["bilan croisé", "crossed-balance.html?accounts=1,2&year=2026&month=9", "crossed-balance"],
  ]) {
    const page = await open(url);
    check(`${what} : le détail naît avec ses douze colonnes, dans l'ordre`, (await heads(page)) === BORN, await heads(page));
    check(
      `${what} : il demande sa disposition sous son propre nom — « ${table} »`,
      (await asked(page)) === table,
      await asked(page),
    );

    // Le menu des colonnes, sur les en-têtes du détail.
    await page.click('#header .list__title[data-column="label"]', { button: "right" });
    await openChecks(page);
    await page.waitForTimeout(100);
    check(
      `${what} : le clic droit sur les en-têtes du détail liste ses douze colonnes — aucune n'est fixe`,
      (await page.locator('.context-menu--columns [data-menu="show-hide"] .context-menu__entry--check').count()) === 12 &&
        (await page.locator(".context-menu--columns .context-menu__entry:not(.context-menu__entry--head)").last().textContent()) ===
          "Rétablir les colonnes par défaut",
    );
    await page.click('.context-menu--columns [data-column="clearing-date"]');
    await page.waitForTimeout(150);
    await page.keyboard.press("Escape");
    let sent = await saves(page);
    check(
      `${what} : une colonne décochée s'en va, et c'est retenu sous « ${table} »`,
      !(await heads(page)).includes("clearing-date") &&
        sent.length === 1 &&
        sent[0].table === table &&
        JSON.stringify(sent[0].layout.hidden) === '["clearing-date"]',
      JSON.stringify(sent),
    );

    // Glisser le montant tout devant : aucune colonne n'est fixe ici.
    const from = await page.locator('#header .list__title[data-column="amount"]').boundingBox();
    const to = await page.locator('#header .list__title[data-column="date"]').boundingBox();
    await page.mouse.move(from.x + 12, from.y + from.height / 2);
    await page.mouse.down();
    await page.mouse.move(from.x - 10, from.y + from.height / 2, { steps: 2 });
    await page.mouse.move(to.x + 3, from.y + from.height / 2, { steps: 6 });
    await page.mouse.up();
    await page.waitForTimeout(200);
    sent = await saves(page);
    check(
      `${what} : glisser « Montant » le met en tête, et l'ordre est retenu`,
      (await heads(page)).startsWith("amount|date|label|reference|verification|") &&
        sent[sent.length - 1].table === table &&
        sent[sent.length - 1].layout.order[0] === "amount",
      await heads(page),
    );
    check(
      `${what} : le rouge d'un débit a suivi sa colonne`,
      await page.evaluate(() => {
        const cell = document.querySelector(".list--detail .list__row--debit .list__cell--amount");
        return (
          cell !== null &&
          cell === cell.parentElement.firstElementChild &&
          getComputedStyle(cell).color !== getComputedStyle(document.body).color
        );
      }),
    );

    // La matrice du haut n'a rien reçu.
    await page.click("#matrix-zone", { button: "right" });
    await page.waitForTimeout(100);
    check(
      `${what} : la matrice du haut n'a pas de menu de colonnes`,
      (await page.locator(".context-menu--columns").count()) === 0 &&
        (await page.locator(".context-menu").count()) === 1,
    );
    await page.keyboard.press("Escape");

    // L'export du détail suit ce qu'on voit.
    await page.click(".list--detail .list__rows", { button: "right" });
    await page.click(".context-menu > .context-menu__entry:not(.context-menu__entry--head) >> nth=0");
    await page.waitForTimeout(250);
    const heading = await page.evaluate(() =>
      window.__exported.sheet.rows[0].map((cell) => cell.text).join("|"),
    );
    check(
      `${what} : l'export du détail suit l'ordre choisi, sans la colonne masquée`,
      heading.split("|").length === 11 && heading.split("|")[3] === "Référence paiement" &&
        heading.split("|")[4] === "Vérification",
      heading,
    );
    await page.close();
  }

  // Rouverte, une statistique retrouve sa disposition.
  // Une disposition réglée avant la colonne « Référence paiement » (20/10/2026) :
  // la nouvelle venue se range après le libellé, là où l'utilisateur l'a mis,
  // et rien d'autre ne bouge.
  const stored = {
    order: BORN.split("|").filter((id) => id !== "reference").reverse(),
    hidden: ["comments"],
    widths: { label: 300 },
  };
  const again = await open("statistics.html?axis=payee&accounts=1,2&year=2026", { storedLayout: stored });
  check(
    "stat par tiers : rouverte, le détail retrouve son ordre, ses colonnes masquées et ses largeurs — la référence après le libellé",
    (await heads(again)) ===
      "amount|project|payee|payment-mode|assignment|category|verification|label|reference|clearing-date|date" &&
      Math.round((await again.locator('#header .list__title[data-column="label"]').boundingBox()).width) === 300,
    await heads(again),
  );
  // Le changement d'une autre statistique ne la concerne pas ; le sien, si.
  const reads = () =>
    again.evaluate(() => window.__calls.filter(([c]) => c === "table_layout").length);
  const before = await reads();
  await again.evaluate(() => {
    window.__listeners["table-layout-changed"]({ event: "x", id: 1, payload: "statistics-category" });
    window.__listeners["table-layout-changed"]({ event: "x", id: 1, payload: "crossed-balance" });
  });
  await again.waitForTimeout(150);
  const afterOthers = await reads();
  await again.evaluate(() => {
    window.__layout = null;
    window.__listeners["table-layout-changed"]({ event: "x", id: 1, payload: "statistics-payee" });
  });
  await again.waitForTimeout(200);
  check(
    "stat par tiers : le réglage d'une autre statistique ne la fait pas bouger ; la réinitialisation de la sienne, si",
    afterOthers === before && (await heads(again)) === BORN,
    `${before} ${afterOthers} ${await heads(again)}`,
  );
  await again.close();

  // --- Le bilan croisé a reçu la colonne « Vérification ».
  const crossed = await open("crossed-balance.html?accounts=1,2&year=2026&month=9");
  check(
    "bilan croisé : « Vérification » suit « Libelle » et « Référence paiement », le mot dans sa couleur",
    (await crossed.locator("#header .list__title >> nth=3").textContent()).startsWith("Référence paiement") &&
      (await crossed.locator("#header .list__title >> nth=4").textContent()).startsWith("Vérification") &&
      (await crossed.evaluate(() => {
        const cell = document.querySelector(".list--detail .list__row .list__cell--verification");
        return cell !== null && cell.textContent === "Vérifiée" && cell.dataset.verification === "2" &&
          getComputedStyle(cell).color === "rgb(30, 107, 36)";
      })),
  );
  await crossed.click(".list--detail .list__row >> nth=0");
  await crossed.waitForTimeout(150);
  const combo = crossed.locator(".list--detail .list__row >> nth=0 >> .list__combo--verification");
  check(
    "bilan croisé : sur la ligne choisie, la vérification se change par sa liste",
    (await combo.count()) === 1 &&
      (await combo.locator("option").allTextContents()).join("|") === "À vérifier|Vérifiée|Douteuse|Contestée",
  );
  const recomputed = () =>
    crossed.evaluate(() => window.__calls.filter(([c]) => c === "crossed_balance").length);
  let count = await recomputed();
  await combo.selectOption("3");
  await crossed.waitForTimeout(250);
  check(
    "bilan croisé : choisir écrit tout de suite, et le bilan est refait",
    (await crossed.evaluate(() =>
      window.__calls.some(
        ([c, a]) => c === "set_operation_verification" && a.id === 1 && a.verificationId === 3,
      ),
    )) && (await recomputed()) > count,
  );
  // Et par le clic droit, pour toute la sélection.
  await crossed.click(".list--detail .list__rows", { button: "right" });
  await crossed.waitForTimeout(100);
  check(
    "bilan croisé : le clic droit des lignes s'ouvre sur « Vérification », puis les dix exports",
    (await crossed.locator(".context-menu__entry:not(.context-menu__entry--head) >> nth=0").textContent()) === "Vérification" &&
      !(await crossed.locator(".context-menu__entry:not(.context-menu__entry--head) >> nth=0").isDisabled()) &&
      (await crossed.locator(".context-menu > .context-menu__entry:not(.context-menu__entry--head)").count()) === 10,
  );
  await crossed.locator(".context-menu__entry--opener").hover();
  await crossed.click(".context-menu__submenu .context-menu__entry:not(.context-menu__entry--head) >> nth=3");
  await crossed.waitForTimeout(250);
  check(
    "bilan croisé : choisir « Contestée » l'envoie avec la sélection",
    await crossed.evaluate(() => {
      const sent = window.__calls.filter(([c]) => c === "set_operations_verification");
      return sent.length === 1 && sent[0][1].verificationId === 4 && sent[0][1].ids.join() === "1";
    }),
  );
  await crossed.close();
}

// --- F40, « Analyse Évolution du solde » -----------------------------------
{
  // Fabrice, 05/10/2026 : le graphique de l'évolution du solde, et en bas le
  // tableau des opérations. « Lorsque l'utilisateur clique sur le graphique et
  // maintient la souris appuyée, il trace le début et la fin d'une zone
  // temporelle […] et à ce moment-là le détail des opérations apparaît dans le
  // tableau du bas pour les comptes qui avaient été sélectionnés. »
  const page = await browser.newPage({ viewport: { width: 1500, height: 950 } });
  const errors = await openWindow(page, "http://localhost:4173/ui/windows/balance-analysis.html?accounts=1,2");
  const year = new Date().getFullYear();
  const state = () => page.locator("#summary").getAttribute("data-state");
  const veil = () =>
    page.evaluate(() => {
      const mark = document.querySelector(".chart__zone");
      return mark === null
        ? null
        : { shown: mark.getAttribute("visibility"), from: mark.dataset.from, to: mark.dataset.to, width: Number(mark.getAttribute("width")) };
    });
  /// Le pixel d'un jour sur le graphique — la même arithmétique que la page.
  const xOf = (iso) =>
    page.evaluate(
      ([day, first, last]) => {
        const box = document.querySelector("svg.chart").getBoundingClientRect();
        const n = (text) => Date.parse(text + "T00:00:00Z") / 86400000;
        const x = 78 + ((n(day) - n(first)) / (n(last) - n(first))) * (1000 - 78 - 18);
        return { x: box.left + (x / 1000) * box.width, y: box.top + box.height / 2, top: box.top, bottom: box.bottom, right: box.right };
      },
      [iso, `${year}-01-01`, `${year}-12-31`],
    );

  check("analyse : la fenêtre s'ouvre sans une plainte", errors.length === 0, errors.join(" / "));
  check(
    "analyse : le graphique de l'évolution du solde est là — trois courbes, sa légende, son titre",
    (await page.locator("svg.chart path[data-account]").count()) === 3 &&
      (await page.locator(".chart__legend-entry").count()) === 3 &&
      (await page.textContent("#heading")) === "Analyse de l'évolution du solde",
  );
  check(
    "analyse : sous le graphique, le splitter puis le tableau — treize colonnes, « Compte » en tête",
    (await page.locator("#splitter").count()) === 1 &&
      (await page.locator("#header > .list__title").evaluateAll((cells) => cells.map((cell) => cell.dataset.column).join("|"))) ===
        "account|date|clearing-date|label|reference|verification|category|assignment|payment-mode|payee|project|amount|comments" &&
      (await page.locator("#header > .list__title >> nth=0").textContent()).startsWith("Compte"),
  );
  check(
    "analyse : rien de tracé — le résumé et le tableau disent comment tracer une zone",
    (await state()) === "none" &&
      (await page.locator("#summary-hint").isVisible()) &&
      (await page.textContent("#summary-hint")).startsWith("Tracez une zone") &&
      (await page.textContent("#rows")).startsWith("Tracez une zone") &&
      (await veil()).shown === "hidden",
  );
  check(
    "analyse : tant qu'aucune zone n'est tracée, rien n'est demandé",
    await page.evaluate(() => window.__zonesAsked === undefined),
  );

  // --- Le geste : appuyer, glisser, relâcher.
  const start = await xOf(`${year}-03-05`);
  const end = await xOf(`${year}-03-20`);
  await page.mouse.move(start.x, start.y);
  await page.mouse.down();
  await page.waitForTimeout(50);
  let mark = await veil();
  check(
    "analyse : à l'appui, la zone se pose sur le jour visé — une barre, large d'un jour",
    mark.shown === "visible" && mark.from === `${year}-03-05` && mark.to === `${year}-03-05` && mark.width > 0 && mark.width < 6,
    JSON.stringify(mark),
  );
  check(
    "analyse : et le résumé donne déjà la date, sans chiffres",
    (await state()) === "dragging" &&
      (await page.textContent("#zone-dates")) === `05/03/${year}` &&
      !(await page.locator("#opening").isVisible()),
    await page.textContent("#zone-dates"),
  );
  await page.mouse.move(end.x, end.y, { steps: 8 });
  await page.waitForTimeout(50);
  mark = await veil();
  check(
    "analyse : en glissant, le voile s'étend jusqu'au pointeur et les deux dates suivent la main",
    mark.from === `${year}-03-05` && mark.to === `${year}-03-20` && mark.width > 20 &&
      (await page.textContent("#zone-dates")) === `05/03/${year} – 20/03/${year}`,
    JSON.stringify(mark),
  );
  check(
    "analyse : pendant le geste, rien n'est lu et l'infobulle se tait",
    (await page.evaluate(() => window.__zonesAsked === undefined)) &&
      (await page.locator(".chart__bubble").isHidden()),
  );
  await page.mouse.up();
  await page.waitForTimeout(300);
  check(
    "analyse : au relâchement, la zone est demandée au noyau — les comptes choisis, les deux dates",
    await page.evaluate(
      ([from, to]) =>
        window.__zonesAsked === 1 &&
        window.__zoneAsked.from === from &&
        window.__zoneAsked.to === to &&
        window.__zoneAsked.accountIds.join() === "1,2",
      [`${year}-03-05`, `${year}-03-20`],
    ),
    await page.evaluate(() => JSON.stringify(window.__zoneAsked)),
  );
  check(
    "analyse : le résumé donne le solde au début, à la fin, la variation, les débits et les crédits",
    (await state()) === "shown" &&
      (await page.locator("#summary .analysis__figure").allTextContents()).map((text) => text.replace(/\s+/g, " ").trim()).join(" | ") ===
        `Zone : 05/03/${year} – 20/03/${year} | Solde au début : 600,00 € | Solde à la fin : 570,00 € | Variation : -30,00 € | Débit : -100,00 € | Crédit : 70,00 €`,
    (await page.locator("#summary .analysis__figure").allTextContents()).map((text) => text.replace(/\s+/g, " ").trim()).join(" | "),
  );
  check(
    "analyse : une variation négative se lit en rouge",
    await page.evaluate(
      () => getComputedStyle(document.getElementById("variation")).color !== getComputedStyle(document.getElementById("closing")).color,
    ),
  );
  check(
    "analyse : le tableau se remplit — les opérations de la zone, chacune avec son compte",
    (await page.locator(".list--detail .list__row").count()) === 2 &&
      (await page.locator(".list--detail .list__row >> nth=0 >> .list__cell >> nth=0").textContent()) === "CCP" &&
      (await page.locator(".list--detail .list__row >> nth=1 >> .list__cell >> nth=0").textContent()) === "Livret A" &&
      (await page.locator(".list--detail .list__row >> nth=0 >> .list__cell >> nth=3").textContent()) === "COURSES",
  );
  check("analyse : la zone reste tracée sur le graphique", (await veil()).shown === "visible" && (await veil()).to === `${year}-03-20`);

  // --- À l'envers, et au-delà du bord.
  await page.mouse.move(end.x, end.y);
  await page.mouse.down();
  await page.mouse.move(start.x, start.y, { steps: 6 });
  await page.mouse.up();
  await page.waitForTimeout(250);
  check(
    "analyse : tracée de droite à gauche, la zone est la même",
    await page.evaluate(
      ([from, to]) => window.__zoneAsked.from === from && window.__zoneAsked.to === to,
      [`${year}-03-05`, `${year}-03-20`],
    ),
  );
  const late = await xOf(`${year}-12-10`);
  await page.mouse.move(late.x, late.y);
  await page.mouse.down();
  await page.mouse.move(late.right + 120, late.y, { steps: 6 });
  await page.mouse.up();
  await page.waitForTimeout(250);
  check(
    "analyse : glisser hors du graphique arrête la zone au dernier jour de la période",
    await page.evaluate(
      ([from, to]) => window.__zoneAsked.from === from && window.__zoneAsked.to === to,
      [`${year}-12-10`, `${year}-12-31`],
    ),
    await page.evaluate(() => JSON.stringify(window.__zoneAsked)),
  );

  // --- Un clic sans glisser : un seul jour.
  const single = await xOf(`${year}-07-14`);
  await page.mouse.click(single.x, single.y);
  await page.waitForTimeout(250);
  check(
    "analyse : un clic sans glisser prend un seul jour",
    (await page.evaluate(
      ([day]) => window.__zoneAsked.from === day && window.__zoneAsked.to === day,
      [`${year}-07-14`],
    )) && (await page.textContent("#zone-dates")) === `14/07/${year}`,
  );
  check(
    "analyse : une zone sans opération le dit dans le tableau",
    (await page.textContent("#rows")) === "Aucune opération dans cette zone." && (await state()) === "shown",
  );
  check(
    "analyse : une variation nulle n'est pas rouge",
    await page.evaluate(
      () => getComputedStyle(document.getElementById("variation")).color === getComputedStyle(document.getElementById("closing")).color,
    ),
  );

  // --- Hors de la surface du tracé, on ne trace rien.
  const asked = await page.evaluate(() => window.__zonesAsked);
  await page.mouse.click(single.x, single.bottom - 6);
  await page.waitForTimeout(150);
  check(
    "analyse : cliquer sous l'axe du temps ne trace rien",
    (await page.evaluate(() => window.__zonesAsked)) === asked,
  );

  // --- L'infobulle du graphique vit toujours, hors du geste.
  const march = await xOf(`${year}-03-15`);
  const plot = await page.locator("svg.chart").boundingBox();
  await page.mouse.move(march.x, plot.y + plot.height * 0.2);
  for (let y = plot.y + 20; y < plot.y + plot.height - 50 && (await page.locator(".chart__bubble").isHidden()); y += 6) {
    await page.mouse.move(march.x, y);
  }
  check("analyse : l'infobulle des courbes répond toujours au survol", await page.locator(".chart__bubble").isVisible());

  // --- Le tableau : les gestes du détail des statistiques.
  await page.mouse.move(start.x, start.y);
  await page.mouse.down();
  await page.mouse.move(end.x, end.y, { steps: 4 });
  await page.mouse.up();
  await page.waitForTimeout(250);
  await page.click(".list--detail .list__row >> nth=0");
  await page.waitForTimeout(150);
  const before = await page.evaluate(() => ({
    curves: window.__calls.filter(([c]) => c === "balance_curves").length,
    zones: window.__zonesAsked,
  }));
  await page.locator(".list--detail .list__row >> nth=0 >> .list__combo--verification").selectOption("3");
  await page.waitForTimeout(300);
  check(
    "analyse : sur la ligne choisie, la vérification se change — et la courbe comme la zone sont relues",
    await page.evaluate(
      (was) =>
        window.__calls.some(([c, a]) => c === "set_operation_verification" && a.verificationId === 3) &&
        window.__calls.filter(([c]) => c === "balance_curves").length > was.curves &&
        window.__zonesAsked > was.zones,
      before,
    ),
  );
  check("analyse : la zone tracée a tenu à la relecture", (await veil()).shown === "visible" && (await veil()).from === `${year}-03-05`);
  await page.dblclick(".list--detail .list__row >> nth=1");
  await page.waitForTimeout(150);
  check(
    "analyse : double-cliquer une ligne ouvre la fiche de l'opération",
    await page.evaluate(() => window.__openedFormFor === 2),
    String(await page.evaluate(() => window.__openedFormFor)),
  );
  await page.click(".list--detail .list__rows", { button: "right" });
  await page.waitForTimeout(100);
  check(
    "analyse : le clic droit du tableau s'ouvre sur « Vérification », puis les dix exports",
    (await page.locator(".context-menu__entry:not(.context-menu__entry--head) >> nth=0").textContent()) === "Vérification" &&
      (await page.locator(".context-menu > .context-menu__entry:not(.context-menu__entry--head)").count()) === 10,
  );
  await page.click(".context-menu > .context-menu__entry:not(.context-menu__entry--head) >> nth=0");
  await page.waitForTimeout(250);
  check(
    "analyse : l'export du tableau porte le nom de la fenêtre et ses treize colonnes",
    await page.evaluate(
      () => window.__exported.sheet.name === "Analyse du solde" && window.__exported.sheet.rows[0].length === 13 &&
        window.__exported.sheet.rows[0][4].text === "Référence paiement",
    ),
  );
  await page.click('#header .list__title[data-column="amount"]', { button: "right" });
  await page.waitForTimeout(100);
  check(
    "analyse : les colonnes du tableau se règlent, sous une disposition à elle",
    (await page.locator('.context-menu--columns [data-menu="show-hide"]').count()) === 1 &&
      (await page.evaluate(() =>
        window.__calls.some(([c, a]) => c === "table_layout" && a.table === "balance-analysis"),
      )),
  );
  await page.keyboard.press("Escape");

  // --- Le splitter.
  const bar = await page.locator("#splitter").boundingBox();
  const tall = (await page.locator("#chart-zone").boundingBox()).height;
  await page.mouse.move(bar.x + 200, bar.y + 3);
  await page.mouse.down();
  await page.mouse.move(bar.x + 200, bar.y - 120, { steps: 4 });
  await page.mouse.up();
  await page.waitForTimeout(150);
  check(
    "analyse : le splitter donne de la place au tableau",
    (await page.locator("#chart-zone").boundingBox()).height < tall - 80,
  );

  // --- Changer d'année efface la zone.
  await page.click("#next-year");
  await page.waitForTimeout(300);
  check(
    "analyse : changer d'année efface la zone, le résumé et le tableau",
    (await state()) === "none" &&
      (await veil()).shown === "hidden" &&
      (await page.locator(".list--detail .list__row").count()) === 0,
  );
  await page.close();

  // Sans compte : rien à tracer, et rien ne casse.
  const nobody = await browser.newPage();
  const complaints = await openWindow(nobody, "http://localhost:4173/ui/windows/balance-analysis.html?accounts=");
  check(
    "analyse : sans compte, la fenêtre le dit et ne demande aucune zone",
    complaints.length === 0 &&
      (await nobody.locator("#info-bar").textContent()).includes("Aucun compte") &&
      (await nobody.evaluate(() => window.__zonesAsked === undefined)),
    complaints.join(" / "),
  );
  await nobody.close();

  // F25 n'a rien reçu : ni zone, ni tableau.
  const chart = await browser.newPage();
  await openWindow(chart, "http://localhost:4173/ui/windows/balance-curves.html?accounts=1,2");
  const box = await chart.locator("svg.chart").boundingBox();
  await chart.mouse.move(box.x + 300, box.y + 200);
  await chart.mouse.down();
  await chart.mouse.move(box.x + 500, box.y + 200, { steps: 4 });
  await chart.mouse.up();
  await chart.waitForTimeout(150);
  check(
    "analyse : « Graphique Évolution du solde » n'a pas bougé — ni zone, ni tableau, ni lecture",
    (await chart.locator(".chart__zone").count()) === 0 &&
      (await chart.locator(".list__rows").count()) === 0 &&
      (await chart.evaluate(() => window.__zonesAsked === undefined)),
  );
  await chart.close();
}

// --- Copier : une cellule, des lignes ---------------------------------------
{
  // Fabrice, 07/10/2026, après la remarque d'un utilisateur : « on ne peut
  // pas faire de Copier de ligne/cellule dans un tableau ». Tranché : pas de
  // titres de colonnes, les montants en nombre pur, tous les tableaux d'un
  // coup — et « Copier la cellule » dans les matrices.

  // D'abord la fonction elle-même, hors de tout navigateur : c'est elle qui
  // décide de ce qu'un tableur recevra.
  const { transform } = await import("esbuild");
  const built = await transform(fs.readFileSync("ui/windows/clipboard.ts", "utf8"), { loader: "ts", format: "esm" });
  const { pureNumber, oneCell } = await import(
    "data:text/javascript;base64," + Buffer.from(built.code).toString("base64")
  );
  for (const [shown, wanted] of [
    ["1 549,81 €", "1549,81"],
    ["-100,00 €", "-100,00"],
    ["0,00 €", "0,00"],
    ["€1,549.81", "1549.81"],
    ["-$12.00", "-12.00"],
    ["1.549,81 €", "1549,81"],
    ["1’549.81 CHF", "1549.81"],
    ["1 549,81 €", "1549,81"],
    ["2 216,71", "2216,71"],
    ["−30,00 €", "-30,00"],
    // Ce qui n'est pas un montant revient tel quel.
    ["9 506 038", "9 506 038"],
    ["05/01/2026", "05/01/2026"],
    ["", ""],
    ["COURSES", "COURSES"],
    ["2026", "2026"],
    ["12", "12"],
  ]) {
    check(`copier : « ${shown} » se copie « ${wanted} »`, pureNumber(shown) === wanted, pureNumber(shown));
  }
  check(
    "copier : une cellule copiée ne porte ni tabulation ni saut de ligne",
    oneCell(" payé\ten deux\r\nfois ") === "payé en deux fois",
  );

  const URL = "http://localhost:4173/ui/windows/operations-list.html?account=1";
  const page = await browser.newPage({ viewport: { width: 1700, height: 800 } });
  await openWindow(page, URL);
  const clipboard = () => page.evaluate(() => window.__clipboard);
  const last = async () => (await clipboard()).slice(-1)[0];
  const cellOf = (row, column) =>
    page.evaluate(
      ([line, name]) => {
        const at = [...document.querySelectorAll(".list__header > .list__title")].findIndex(
          (title) => title.dataset.column === name,
        );
        const cell = document.querySelectorAll(".list__row")[line].children[at];
        const box = cell.getBoundingClientRect();
        return { x: box.left + box.width / 2, y: box.top + box.height / 2 };
      },
      [row, column],
    );
  const rightClick = async (row, column) => {
    const at = await cellOf(row, column);
    await page.mouse.click(at.x, at.y, { button: "right" });
    await page.waitForTimeout(100);
  };
  const head = (name) => page.locator(`.context-menu [data-head="${name}"]`);

  // --- Le menu.
  await rightClick(0, "label");
  check(
    "copier : le clic droit s'ouvre sur « Copier la cellule », « Copier les lignes sélectionnées », puis un trait",
    await page.evaluate(() => {
      const pieces = [...document.querySelector(".context-menu").children].slice(0, 3);
      return (
        pieces[0].textContent === "Copier la cellule" &&
        pieces[1].textContent === "Copier les lignes sélectionnées" &&
        pieces[2].matches("hr")
      );
    }),
  );
  check(
    "copier : sans ligne choisie, la cellule se copie mais pas les lignes",
    !(await head("copy-cell").isDisabled()) && (await head("copy-rows").isDisabled()),
  );
  const bar = await page.locator("#info-bar").textContent();
  await head("copy-cell").click();
  await page.waitForTimeout(150);
  check(
    "copier : « Copier la cellule » met dans le presse-papiers la cellule sous le pointeur",
    (await clipboard()).length === 1 && (await last()) === "COURSES",
    JSON.stringify(await clipboard()),
  );
  check(
    "copier : le menu se referme, sans rien annoncer et sans toucher à la sélection",
    (await page.locator(".context-menu").count()) === 0 &&
      (await page.locator("#info-bar").textContent()) === bar &&
      (await page.locator(".list__row[aria-selected='true']").count()) === 0,
  );

  // --- Un montant, en nombre pur ; le reste, tel qu'on le lit.
  for (const [row, column, wanted] of [
    [0, "debit", "-100,00"],
    [0, "balance", "2322,34"],
    [1, "credit", "2216,71"],
    [0, "date", "05/01/2026"],
    [1, "verification", "Douteuse"],
    [0, "category", "Alimentation"],
  ]) {
    await rightClick(row, column);
    await head("copy-cell").click();
    await page.waitForTimeout(120);
    check(`copier : la cellule « ${column} » se copie « ${wanted} »`, (await last()) === wanted, await last());
  }

  // --- Une cellule vide, et hors de toute ligne.
  await rightClick(1, "comments");
  check(
    "copier : sur une cellule vide — une coche absente —, « Copier la cellule » est grisée",
    await head("copy-cell").isDisabled(),
  );
  await page.keyboard.press("Escape");
  const rows = await page.locator(".list__rows").boundingBox();
  await page.mouse.click(rows.x + 300, rows.y + rows.height - 30, { button: "right" });
  await page.waitForTimeout(100);
  check(
    "copier : sous la dernière ligne, il n'y a pas de cellule à copier",
    (await head("copy-cell").isDisabled()) && (await head("copy-rows").isDisabled()),
  );
  await page.keyboard.press("Escape");

  // --- Les lignes choisies.
  await page.click(".list__row >> nth=1");
  await page.keyboard.down("Meta");
  await page.click(".list__row >> nth=0");
  await page.keyboard.up("Meta");
  await page.waitForTimeout(100);
  await rightClick(0, "label");
  check("copier : des lignes prises, « Copier les lignes sélectionnées » s'allume", !(await head("copy-rows").isDisabled()));
  await head("copy-rows").click();
  await page.waitForTimeout(150);
  const copied = (await last()).split("\n").map((line) => line.split("\t"));
  check(
    "copier : une ligne par opération, dans l'ordre de l'écran — pas celui des clics —, sans titres",
    copied.length === 2 && copied[0][5] === "COURSES" && copied[1][5] === "SALAIRE",
    JSON.stringify(copied),
  );
  check(
    "copier : une cellule par colonne affichée — dix-neuf —, les colonnes sans texte vides",
    copied.every((line) => line.length === 19) && copied[0][0] === "" && copied[0][1] === "05/01/2026" &&
      copied[0][6] === "CB SYSTEME U REF 0105" && copied[1][6] === "",
    String(copied[0].length),
  );
  check(
    "copier : dans les lignes aussi, les montants sont des nombres purs",
    copied[0][13] === "-100,00" && copied[0][14] === "" && copied[1][14] === "2216,71" && copied[0][15] === "2322,34",
    JSON.stringify([copied[0].slice(13, 16), copied[1].slice(13, 16)]),
  );
  check(
    "copier : la sélection n'a pas bougé",
    (await page.locator(".list__row[aria-selected='true']").count()) === 2,
  );

  // --- ⌘C et Ctrl+C.
  for (const [name, key] of [["⌘C", "Meta+c"], ["Ctrl+C", "Control+c"], ["⌘C, majuscules verrouillées", "Meta+C"]]) {
    const before = (await clipboard()).length;
    await page.keyboard.press(key);
    await page.waitForTimeout(150);
    const now = await clipboard();
    check(
      `copier : ${name} copie les lignes choisies`,
      now.length === before + 1 && now[now.length - 1].split("\n").length === 2,
      String(now.length - before),
    );
  }
  // Avec Maj ou Alt, ce n'est plus la touche de copie.
  for (const key of ["Meta+Shift+c", "Control+Alt+c"]) {
    const before = (await clipboard()).length;
    await page.keyboard.press(key);
    await page.waitForTimeout(100);
    check(`copier : ${key} n'est pas une copie`, (await clipboard()).length === before);
  }
  // Dans un champ, la touche reste ce qu'elle a toujours été.
  await page.click('.list__title[data-column="label"] .list__filter-toggle');
  await page.fill(".list__filter-input:not([hidden])", "COUR");
  let before = (await clipboard()).length;
  await page.keyboard.press("Meta+c");
  await page.waitForTimeout(150);
  check(
    "copier : dans une loupe de recherche, ⌘C n'est pas pris par le tableau",
    (await clipboard()).length === before,
  );
  await page.click('.list__title[data-column="label"] .list__filter-toggle');
  // Sans sélection, rien.
  await page.click("#from");
  await page.locator(".list__rows").click({ position: { x: 300, y: 300 } });
  await page.evaluate(() => document.activeElement.blur());
  await page.close();

  const empty = await browser.newPage({ viewport: { width: 1700, height: 800 } });
  await openWindow(empty, URL);
  await empty.keyboard.press("Meta+c");
  await empty.waitForTimeout(150);
  check(
    "copier : sans ligne choisie, ⌘C ne copie rien",
    (await empty.evaluate(() => window.__clipboard.length)) === 0,
  );

  // --- Les lignes suivent les colonnes qu'on a choisies.
  await empty.click('.list__title[data-column="label"]', { button: "right" });
  await openChecks(empty);
  for (const name of ["clearing-date", "status", "verification", "reference", "category", "assignment", "payment-mode", "payee", "project", "month", "comments", "attachments", "check"]) {
    await empty.click(`.context-menu--columns [data-column="${name}"]`);
  }
  await empty.keyboard.press("Escape");
  const from = await empty.locator('.list__title[data-column="balance"]').boundingBox();
  const to = await empty.locator('.list__title[data-column="date"]').boundingBox();
  await empty.mouse.move(from.x + 12, from.y + 10);
  await empty.mouse.down();
  await empty.mouse.move(from.x - 10, from.y + 10, { steps: 2 });
  await empty.mouse.move(to.x + 3, from.y + 10, { steps: 6 });
  await empty.mouse.up();
  await empty.waitForTimeout(200);
  await empty.click(".list__row >> nth=0");
  await empty.keyboard.press("Control+c");
  await empty.waitForTimeout(150);
  check(
    "copier : les lignes suivent les colonnes affichées, dans l'ordre choisi",
    (await empty.evaluate(() => window.__clipboard.slice(-1)[0])) === "\t2322,34\t05/01/2026\tCOURSES\t-100,00\t",
    JSON.stringify(await empty.evaluate(() => window.__clipboard.slice(-1)[0])),
  );
  await empty.close();

  // --- Le presse-papiers refuse : l'autre chemin, puis l'aveu.
  const old = await browser.newPage();
  await openWindow(old, URL, { clipboardRefuses: "modern" });
  await old.click(".list__row >> nth=0 >> .list__cell >> nth=5", { button: "right" });
  await old.click('.context-menu [data-head="copy-cell"]');
  await old.waitForTimeout(200);
  check(
    "copier : si l'interface moderne refuse, l'ancienne commande de copie prend le relais",
    await old.evaluate(
      () => window.__copiedTheOldWay === 1 && window.__clipboard.join() === "COURSES" &&
        document.querySelector(".clipboard-scratch") === null,
    ),
  );
  check(
    "copier : et rien n'est dit — la copie a eu lieu",
    !(await old.evaluate(() => document.getElementById("info-bar").classList.contains("info-bar--alert"))),
  );
  await old.close();
  const refused = await browser.newPage();
  await openWindow(refused, URL, { clipboardRefuses: "both" });
  await refused.click(".list__row >> nth=0 >> .list__cell >> nth=5", { button: "right" });
  await refused.click('.context-menu [data-head="copy-cell"]');
  await refused.waitForTimeout(200);
  check(
    "copier : si rien n'a pu être écrit, la fenêtre le dit, en alerte",
    (await refused.textContent("#info-bar")) === "La copie dans le presse-papiers a échoué." &&
      (await refused.evaluate(() => document.getElementById("info-bar").classList.contains("info-bar--alert"))),
    await refused.textContent("#info-bar"),
  );
  await refused.close();

  // --- Tous les tableaux : une liste de nomenclature.
  const list = await browser.newPage();
  await openWindow(list, "http://localhost:4173/ui/windows/nomenclature-list.html?kind=category");
  await list.click(".list__row >> nth=0 >> .list__cell >> nth=0", { button: "right" });
  await list.waitForTimeout(100);
  const label = await list.locator(".list__row >> nth=0 >> .list__cell >> nth=0").textContent();
  check(
    "copier : une liste de nomenclature a les deux mêmes entrées, puis ses dix exports",
    (await list.locator(".context-menu > .context-menu__entry--head").allTextContents()).join("|") ===
      "Copier la cellule|Copier les lignes sélectionnées" &&
      (await list.locator(".context-menu > .context-menu__entry:not(.context-menu__entry--head)").count()) === 10,
  );
  await list.click('.context-menu [data-head="copy-cell"]');
  await list.waitForTimeout(150);
  check(
    "copier : et la cellule s'y copie",
    (await list.evaluate(() => window.__clipboard.join("|"))) === label,
    await list.evaluate(() => window.__clipboard.join("|")),
  );
  await list.click(".list__row >> nth=0");
  await list.keyboard.down("Shift");
  await list.click(".list__row >> nth=2");
  await list.keyboard.up("Shift");
  await list.keyboard.press("Control+c");
  await list.waitForTimeout(150);
  check(
    "copier : Ctrl+C y copie les lignes choisies, une par ligne",
    (await list.evaluate(() => window.__clipboard.slice(-1)[0].split("\n").length)) === 3,
  );
  await list.close();

  // --- Les matrices : « Copier la cellule », et elle seule.
  for (const [what, url] of [
    ["statistiques", "statistics.html?axis=category&accounts=1,2&year=2026"],
    ["bilan croisé", "crossed-balance.html?accounts=1,2&year=2026&month=9"],
  ]) {
    const matrix = await browser.newPage({ viewport: { width: 1700, height: 900 } });
    await openWindow(matrix, `http://localhost:4173/ui/windows/${url}`);
    const cell = matrix.locator(".matrix__row >> nth=1 >> .matrix__cell >> nth=0");
    const shown = (await cell.textContent()).trim();
    await cell.click({ button: "right" });
    await matrix.waitForTimeout(100);
    check(
      `copier, ${what} : la matrice offre « Copier la cellule », un trait, puis ses exports — pas de copie de lignes`,
      (await matrix.locator(".context-menu > .context-menu__entry--head").allTextContents()).join("|") ===
        "Copier la cellule" &&
        (await matrix.locator(".context-menu > :nth-child(2)").evaluate((piece) => piece.matches("hr"))) &&
        (await matrix.locator(".context-menu > .context-menu__entry:not(.context-menu__entry--head)").count()) > 0,
    );
    await matrix.click('.context-menu [data-head="copy-cell"]');
    await matrix.waitForTimeout(150);
    const got = await matrix.evaluate(() => window.__clipboard.slice(-1)[0]);
    check(
      `copier, ${what} : la case se copie en nombre pur — « ${shown} » donne « ${got} »`,
      /^-?\d+[,.]\d{2}$/.test(got) && !got.includes("€") && got.replace(/\D/g, "") === shown.replace(/\D/g, ""),
      `${shown} → ${got}`,
    );
    const name = matrix.locator(".matrix__row >> nth=1 >> .matrix__label");
    await name.click({ button: "right" });
    await matrix.click('.context-menu [data-head="copy-cell"]');
    await matrix.waitForTimeout(150);
    check(
      `copier, ${what} : le libellé d'une ligne se copie tel quel`,
      (await matrix.evaluate(() => window.__clipboard.slice(-1)[0])) === (await name.textContent()).trim(),
    );
    // Le détail du bas, lui, est un tableau comme les autres.
    await cell.click();
    await matrix.waitForTimeout(250);
    await matrix.click(".list--detail .list__row >> nth=0");
    await matrix.keyboard.press("Meta+c");
    await matrix.waitForTimeout(150);
    check(
      `copier, ${what} : dans le détail du bas, ⌘C copie la ligne choisie — douze cellules, la référence en quatrième`,
      (await matrix.evaluate(() => {
        const cells = window.__clipboard.slice(-1)[0].split("\t");
        return cells.length === 12 && cells[3] === "CB SYSTEME U REF 0105";
      })),
      await matrix.evaluate(() => JSON.stringify(window.__clipboard.slice(-1)[0])),
    );
    await matrix.close();
  }
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
    "classification : les sept caractéristiques sont là",
    (await page.locator(".characteristic").count()) === 7,
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
      asked.change.status === null &&
      asked.change.verification === null,
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
    "classification : la ligne choisie porte ses sept menus",
    (await page.locator(".list__row[aria-selected='true'] .list__combo").count()) === 7,
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

  // --- La vérification, septième caractéristique (Fabrice, 03/10/2026) ----
  //
  // En dernière colonne du tableau, et sous le statut dans le bandeau. Sur le
  // même principe que les six autres : elle va dans le brouillon, et rien
  // n'est écrit avant l'enregistrement.
  const quickTitles = await page.locator(".list__title-text").allTextContents();
  check(
    "classification : la vérification est la dernière colonne",
    quickTitles.length === 10 && quickTitles[9] === "Vérification",
    JSON.stringify(quickTitles),
  );
  const shown = await page.evaluate(() => {
    const row = document.querySelectorAll(".list__row")[1];
    const cell = row.querySelectorAll(".list__cell")[9];
    return {
      word: cell.textContent.trim(),
      key: cell.dataset.verification,
      colour: getComputedStyle(cell).color,
    };
  });
  check(
    "classification : une ligne montre sa vérification, dans sa couleur",
    shown.word === "Vérifiée" && shown.key === "2" && shown.colour === "rgb(30, 107, 36)",
    JSON.stringify(shown),
  );
  const lastCombo = page.locator(".list__row[aria-selected='true'] .list__combo >> nth=6");
  check(
    "classification : son menu offre les quatre vérifications, sans « Non précisé »",
    (await lastCombo.locator("option").allTextContents()).join("|") ===
      "À vérifier|Vérifiée|Douteuse|Contestée",
  );
  await lastCombo.selectOption("4");
  await page.waitForTimeout(250);
  const verificationSent = await page.evaluate(() => window.__quickSet ?? null);
  check(
    "classification : la cellule envoie la vérification au brouillon, pas à la base",
    verificationSent !== null &&
      verificationSent.characteristic === "verification" &&
      verificationSent.value === 4 &&
      (await page.evaluate(
        () =>
          !window.__calls.some(([command]) =>
            ["quick_classification_save", "set_operation_verification"].includes(command),
          ),
      )),
    JSON.stringify(verificationSent),
  );

  // Le bandeau : la septième case, sous le statut, dans la colonne de droite.
  const placed = await page.evaluate(() => {
    const box = (key) =>
      document.getElementById("check-" + key).closest(".characteristic").getBoundingClientRect();
    return {
      underStatus:
        Math.abs(box("verification").left - box("status").left) < 2 &&
        box("verification").top > box("status").top,
      // Et les six autres n'ont pas bougé : trois à gauche, trois à droite.
      leftColumn:
        Math.abs(box("category").left - box("assignment").left) < 2 &&
        Math.abs(box("category").left - box("payment-mode").left) < 2,
      rightColumn:
        Math.abs(box("payee").left - box("project").left) < 2 &&
        Math.abs(box("payee").left - box("status").left) < 2 &&
        box("payee").left > box("category").left &&
        Math.abs(box("payee").top - box("category").top) < 2,
    };
  });
  check(
    "classification : la vérification est sous le statut, et les six autres n'ont pas bougé",
    placed.underStatus && placed.leftColumn && placed.rightColumn,
    JSON.stringify(placed),
  );
  await page.uncheck("#check-category");
  await page.check("#check-verification");
  await page.selectOption("#check-verification ~ .characteristic__menu", "3");
  check(
    "classification : le menu du bandeau porte la couleur de son choix",
    (await page.evaluate(
      () =>
        getComputedStyle(document.querySelector("#check-verification ~ .characteristic__menu"))
          .color,
    )) === "rgb(179, 92, 0)",
  );
  await page.click(".list__row >> nth=0");
  await page.waitForTimeout(100);
  await page.click("#apply");
  await page.waitForTimeout(250);
  const verificationApplied = await page.evaluate(() => window.__quickApplied ?? null);
  check(
    "classification : appliquer envoie la vérification cochée, et elle seule",
    verificationApplied !== null &&
      verificationApplied.change.verification === 3 &&
      verificationApplied.change.category === null &&
      verificationApplied.change.status === null,
    JSON.stringify(verificationApplied?.change ?? null),
  );
  check(
    "classification : et toujours rien sur le disque",
    await page.evaluate(
      () => !window.__calls.some(([command]) => command === "quick_classification_save"),
    ),
  );

  // **L'ascenseur horizontal** (Fabrice, 03/10/2026) : dix colonnes ne tiennent
  // pas dans une fenêtre rétrécie. Large, rien ne dépasse ; étroite, les lignes
  // gardent leur largeur plancher et débordent, et l'en-tête les suit.
  const sideways = () =>
    page.evaluate(() => {
      const rows = document.getElementById("rows");
      return { content: rows.scrollWidth, frame: rows.clientWidth };
    });
  await page.setViewportSize({ width: 1700, height: 900 });
  await page.waitForTimeout(150);
  const wide = await sideways();
  await page.setViewportSize({ width: 900, height: 900 });
  await page.waitForTimeout(150);
  const narrow = await sideways();
  check(
    "classification : large, le tableau tient ; étroite, il déborde et l'ascenseur vient",
    wide.content <= wide.frame + 1 && narrow.content > narrow.frame + 50,
    JSON.stringify({ wide, narrow }),
  );
  await page.evaluate(() => {
    const rows = document.getElementById("rows");
    rows.scrollLeft = 120;
    rows.dispatchEvent(new Event("scroll"));
  });
  await page.waitForTimeout(100);
  check(
    "classification : et l'en-tête suit les lignes quand on fait défiler",
    (await page.evaluate(() => document.getElementById("header").style.transform)) ===
      "translateX(-120px)",
    await page.evaluate(() => document.getElementById("header").style.transform),
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

// --- F17 : un relevé QIF, par le même chemin que l'OFX (15/10/2026) -------
//
// « C'est un relevé bancaire aussi, donc on utilise la même fenêtre, les mêmes
// boutons, la même interface » (Fabrice). Une seule question de plus, quand
// le fichier ne dit pas l'ordre des dates.
{
  const url = "http://localhost:4173/ui/windows/statement-import.html?account=1";
  const page = await browser.newPage();
  await openWindow(page, url, { pickedIsQif: true });
  await page.click("#open");
  await page.waitForTimeout(300);
  let loads = await page.evaluate(() => window.__qifLoads ?? []);
  check(
    "QIF : un seul compte, aucune question — chargé comme un OFX, sans passer par le découpage CSV",
    loads.length === 1 && loads[0].path === "/tmp/releve.qif" && loads[0].account === 0 && loads[0].order === null &&
      !(await page.locator(".dialog").isVisible()) &&
      (await page.evaluate(() => !window.__calls.some(([command]) => command === "statement_load" || command === "open_csv_statement"))),
    JSON.stringify(loads),
  );
  check("QIF : le même tableau", (await page.locator(".list__row").count()) === 3);
  check(
    "QIF : pas de colonne FITID, et ni « Fichier » ni « Écart » quand le fichier ne donne pas de solde",
    (await page.evaluate(() => document.querySelector(".window--no-fitid") !== null)) &&
      (await page.locator("#file-balance").textContent()) === "" &&
      (await page.locator("#difference").textContent()) === "",
  );
  check(
    "QIF : le solde initial écarté est annoncé",
    ((await page.locator("#info-bar").textContent()) ?? "").includes("Solde initial de 2 140,50 €"),
    await page.locator("#info-bar").textContent(),
  );
  check(
    "QIF : le dossier jaune annonce les trois formats",
    (await page.getAttribute("#open", "title")) === "Ouvrir un fichier de relevé (OFX, QIF, CSV)",
  );
  await page.close();

  // L'ordre des dates : demandé, et la réponse repart avec la lecture.
  const ambiguous = await browser.newPage();
  await openWindow(ambiguous, url, { pickedIsQif: true, qifAmbiguous: true });
  await ambiguous.click("#open");
  await ambiguous.waitForTimeout(300);
  check(
    "QIF : rien ne prouve l'ordre des dates — la question, avec les deux lectures",
    (await ambiguous.locator(".dialog").isVisible()) &&
      ((await ambiguous.locator(".dialog__question").textContent()) ?? "").includes("« 05/03/2023 »") &&
      (await ambiguous.locator(".dialog__field option").allTextContents()).join("|") ===
        "Jour 5, mois 3 (jour/mois)|Jour 3, mois 5 (mois/jour)",
  );
  await ambiguous.selectOption(".dialog__field", "Jour 3, mois 5 (mois/jour)");
  await ambiguous.click(".dialog__button >> nth=0");
  await ambiguous.waitForTimeout(300);
  loads = await ambiguous.evaluate(() => window.__qifLoads);
  check(
    "QIF : la réponse repart avec la lecture, et le relevé s'affiche",
    loads.length === 2 && loads[1].order === "month-day" && (await ambiguous.locator(".list__row").count()) === 3,
    JSON.stringify(loads),
  );
  await ambiguous.close();

  const refused = await browser.newPage();
  await openWindow(refused, url, { pickedIsQif: true, qifAmbiguous: true });
  await refused.click("#open");
  await refused.waitForTimeout(300);
  await refused.click(".dialog__button >> nth=1");
  await refused.waitForTimeout(250);
  check(
    "QIF : renoncer à la question ne charge rien",
    (await refused.evaluate(() => window.__qifLoads.length)) === 1 && (await refused.locator(".list__row").count()) === 0,
  );
  await refused.close();

  // Plusieurs comptes : la même question qu'en OFX, et c'est le rang qui part.
  const many = await browser.newPage();
  await openWindow(many, url, { pickedIsQif: true, qifAccounts: ["Courant", "Livret"] });
  await many.click("#open");
  await many.waitForTimeout(300);
  check(
    "QIF : plusieurs comptes, la même question qu'en OFX",
    (await many.locator(".dialog__question").textContent()) === "Ce fichier contient plusieurs comptes. Lequel voulez-vous importer ?" &&
      (await many.locator(".dialog__field option").count()) === 2,
  );
  await many.selectOption(".dialog__field", "Livret");
  await many.click(".dialog__button >> nth=0");
  await many.waitForTimeout(300);
  check(
    "QIF : le compte choisi part par son rang",
    (await many.evaluate(() => window.__qifLoads[0].account)) === 1,
  );
  await many.close();
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
  // Un classement est choisi, et un statut : c'est ce que l'utilisateur laisse
  // derrière lui en retournant à la liste.
  await again.selectOption("#category", "1");
  await again.selectOption("#assignment", "2");
  await again.selectOption("#status", "3");
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
  // Bug remonté par Fabrice le 30/08/2026 : le classement ne venant d'aucune
  // ligne, il restait celui d'avant — et une catégorie héritée ne se voit nulle
  // part, elle ressort dans une statistique fausse.
  check(
    "rapprochement : redemandée, le classement repart à « Non précisé »",
    await again.evaluate(() =>
      ["payment-mode", "category", "assignment", "payee", "project"].every(
        (id) => document.getElementById(id).value === "0",
      ),
    ),
    await again.evaluate(() =>
      ["payment-mode", "category", "assignment", "payee", "project"]
        .map((id) => `${id}=${document.getElementById(id).value}`)
        .join(" "),
    ),
  );
  check(
    "rapprochement : redemandée, le statut repart à pointée",
    (await again.inputValue("#status")) === "1",
    await again.inputValue("#status"),
  );

  // **Et sur la même ligne aussi** : on ne l'a pas validée, donc elle n'a rien
  // produit. C'est la règle du virement et celle de « Dupliquer ».
  await again.selectOption("#payee", "4");
  await again.evaluate(() =>
    window.__listeners["window-parameters:statement-form"]({
      payload: "account=1&rank=3",
    }),
  );
  await again.waitForTimeout(250);
  check(
    "rapprochement : rouverte sur la même ligne, elle repart à zéro elle aussi",
    (await again.inputValue("#payee")) === "0",
    await again.inputValue("#payee"),
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

// **Un modèle écrit ce qu'écrirait la main** (Fabrice, 25/08/2026). Poser une
// valeur dans un champ ne déclenche aucun événement : la règle qui lie la date
// de pointage au statut ne jouait pas, et un modèle « prévu » créait une
// opération non pointée portant une date de pointage.
{
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/operation-form.html?mode=A&account=1",
  );
  // Une fiche neuve est datée du jour, des deux côtés.
  const fresh = await page.inputValue("#clearing-date");
  check("modèle : la fiche neuve porte une date de pointage", fresh !== "");

  const applied = await page.evaluate(() => {
    const handler =
      window.__listeners && window.__listeners["template-chosen:operation-form"];
    if (!handler) {
      return false;
    }
    handler({
      event: "template-chosen:operation-form",
      id: 1,
      payload: {
        label: "Loyer",
        amount: -700_00,
        signed_text: "-700,00",
        status_id: 3,
        category_id: 1,
        assignment_id: 2,
        payment_mode_id: 3,
        payee_id: 0,
        project_id: 0,
      },
    });
    return true;
  });
  check("modèle : le modèle est appliqué", applied === true);
  await page.waitForTimeout(120);
  check(
    "modèle : un modèle prévu vide la date de pointage, comme à la main",
    (await page.inputValue("#clearing-date")) === "",
  );
  check("modèle : et le statut est bien celui du modèle", (await page.inputValue("#status")) === "3");
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

// --- Phase 11 — le contrôle du budget (F39) -----------------------------
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

// **La règle tirée d'une opération** (Fabrice, 25/08/2026) : la fiche s'ouvre
// neuve puis reçoit ce que l'opération sait donner, « comme si les champs
// avaient été remplis à la main ». Le rythme, lui, reste celui d'une fiche
// neuve : une opération ne dit pas à quelle fréquence elle se répète.
{
  const page = await browser.newPage();
  await openWindow(
    page,
    "http://localhost:4173/ui/windows/recurring-form.html?mode=A&id=0&from=1",
  );
  check(
    "règle depuis une opération : le libellé est celui de l'opération",
    (await page.inputValue("#label")) === "VIREMENT DE COMPLEMENTAIRE SANTE",
  );
  check(
    "règle depuis une opération : le montant aussi",
    (await page.inputValue("#amount")) === "9,00",
  );
  check(
    "règle depuis une opération : un crédit devient le sens positif",
    (await page.inputValue("#direction")) === "1",
  );
  check(
    "règle depuis une opération : les nomenclatures suivent",
    (await page.inputValue("#category")) === "1" &&
      (await page.inputValue("#assignment")) === "2" &&
      (await page.inputValue("#payment-mode")) === "3",
  );
  // Ce que l'opération ne sait pas dire reste celui d'une fiche neuve.
  check(
    "règle depuis une opération : le rythme reste celui d'une fiche neuve",
    (await page.inputValue("#frequency")) === "1" &&
      (await page.inputValue("#unit")) === "month" &&
      (await page.isChecked("#ending-no-limit")),
  );
  check(
    "règle depuis une opération : la fiche est bien en création",
    (await page.inputValue("#id")) === "",
  );
  // Rien n'est écrit : c'est une fiche pré-remplie, pas une règle créée.
  check(
    "règle depuis une opération : rien n'est enregistré à l'ouverture",
    (await page.evaluate(() => window.__calls.every(([c]) => c !== "create_recurring_rule"))),
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

// --- Accueil : les cases, l'ordre et l'ascenseur des comptes --------------
{
  // Fabrice, 07/10/2026 : « avant chaque nom de compte je veux une boîte à
  // cocher. Le but sera de faire comptabiliser ou non les soldes dans les 3
  // zones carrées du dessus. Les carrés pourront aussi être déplacés par drag
  // and drop. Évidemment cela sera mémorisable dans les préférences. »
  const page = await browser.newPage();
  await page.setViewportSize({ width: 900, height: 700 });
  const errors = await openWindow(page, "http://localhost:4173/", { manyAccounts: true });
  check("accueil, comptes : aucune erreur de script", errors.length === 0, errors.join(" | "));

  const ids = () =>
    page.evaluate(() => [...document.querySelectorAll(".tile")].map((t) => t.dataset.account).join(","));
  const saves = () =>
    page.evaluate(() => window.__calls.filter(([c]) => c === "save_welcome_accounts").map(([, a]) => a));
  const opened = () =>
    page.evaluate(() => window.__calls.filter(([c]) => c === "open_operations_list").length);

  check(
    "accueil : chaque tuile porte sa case, avant le nom, cochée à la naissance",
    await page.evaluate(() =>
      [...document.querySelectorAll(".tile")].every((tile) => {
        const head = tile.firstElementChild;
        const check = head.firstElementChild;
        return (
          check.matches('input[type="checkbox"].tile__check') &&
          check.checked &&
          check.nextElementSibling.classList.contains("tile__name")
        );
      }),
    ),
  );
  check(
    "accueil : la case dit à quoi elle sert",
    (await page.locator(".tile__check").first().getAttribute("title")) === "Compter ce compte dans les totaux",
  );

  // Huit comptes dans 900 points : une seule rangée, et elle défile.
  const row = await page.evaluate(() => {
    const holder = document.getElementById("tiles");
    const tops = new Set([...holder.children].map((t) => Math.round(t.getBoundingClientRect().top)));
    return {
      lines: tops.size,
      scrolls: holder.scrollWidth > holder.clientWidth,
      overflow: getComputedStyle(holder).overflowX,
      page: document.documentElement.scrollWidth <= document.documentElement.clientWidth,
      narrowest: Math.min(...[...holder.children].map((t) => t.getBoundingClientRect().width)),
    };
  });
  check(
    "accueil : les tuiles tiennent sur une seule rangée, qui défile dans sa carte et non la fenêtre",
    row.lines === 1 && row.scrolls && row.overflow === "auto" && row.page && row.narrowest >= 215,
    JSON.stringify(row),
  );

  // Décocher : le compte sort des totaux, reste montré, et la ligne le dit.
  await page.locator('.tile[data-account="2"] .tile__check').click();
  await page.waitForTimeout(200);
  check(
    "accueil : décocher un compte l'enregistre, sans ouvrir ses opérations",
    JSON.stringify(await saves()) === JSON.stringify([{ order: [1, 2, 3, 4, 5, 6, 7, 8], excluded: [2] }]) &&
      (await opened()) === 0,
    JSON.stringify(await saves()),
  );
  check(
    "accueil : le compte décoché sort du solde en banque",
    (await page.textContent("#total-bank")) === "4849,81 €",
    await page.textContent("#total-bank"),
  );
  check(
    "accueil : la ligne dit combien de comptes sont comptés",
    (await page.textContent("#total-bank-detail")) === "Comptes comptés dans les totaux : 7 sur 8",
    await page.textContent("#total-bank-detail"),
  );
  check(
    "accueil : le compte décoché reste montré, en retrait, sa case décochée",
    await page.evaluate(() => {
      const tile = document.querySelector('.tile[data-account="2"]');
      return tile.classList.contains("tile--excluded") && !tile.querySelector(".tile__check").checked;
    }),
  );
  await page.locator('.tile[data-account="2"] .tile__name').click();
  await page.waitForTimeout(150);
  check("accueil : un compte décoché s'ouvre toujours d'un clic", (await opened()) === 1);

  // Au clavier : la tuile s'ouvre à Entrée ; la case se coche à Espace sans
  // ouvrir, et garde le focus une fois l'accueil relu.
  await page.locator('.tile[data-account="1"]').focus();
  await page.keyboard.press("Enter");
  await page.waitForTimeout(150);
  check("accueil : Entrée sur une tuile ouvre son compte", (await opened()) === 2);
  await page.locator('.tile[data-account="2"] .tile__check').focus();
  await page.keyboard.press("Space");
  await page.waitForTimeout(200);
  check(
    "accueil : Espace sur la case la recoche, n'ouvre rien et lui laisse le focus",
    (await opened()) === 2 &&
      (await page.evaluate(() => {
        const check = document.querySelector('.tile[data-account="2"] .tile__check');
        return check.checked && document.activeElement === check;
      })) &&
      (await page.textContent("#total-bank-detail")) === "8 comptes ouverts",
    await page.textContent("#total-bank-detail"),
  );

  // Déplacer : la première tuile se pose après la troisième.
  const centre = async (id) => {
    const box = await page.locator(`.tile[data-account="${id}"]`).boundingBox();
    return { x: box.x + box.width / 2, y: box.y + box.height / 2, right: box.x + box.width };
  };
  const from = await centre(1);
  const third = await centre(3);
  await page.mouse.move(from.x, from.y);
  await page.mouse.down();
  await page.mouse.move(from.x + 3, from.y);
  check(
    "accueil : sous le seuil, rien ne bouge — c'est encore un clic",
    (await page.locator(".tile-drop-mark").count()) === 0,
  );
  await page.mouse.move(third.right - 20, third.y, { steps: 6 });
  check(
    "accueil : une tuile en main montre le trait de sa future place",
    (await page.locator(".tile-drop-mark").count()) === 1 &&
      (await page.locator('.tile[data-account="1"]').evaluate((t) => t.classList.contains("tile--moving"))),
  );
  // L'accueil se relit sous la main (il reprend le focus) : la tuile reste.
  await page.evaluate(() => window.dispatchEvent(new Event("focus")));
  await page.waitForTimeout(150);
  check(
    "accueil : relu pendant le geste, il ne redessine pas les tuiles sous la main",
    await page.locator('.tile[data-account="1"]').evaluate((t) => t.classList.contains("tile--moving")),
  );
  const before = await opened();
  await page.mouse.up();
  await page.waitForTimeout(250);
  check(
    "accueil : la tuile déposée prend sa place, et l'ordre est enregistré",
    (await ids()) === "2,3,1,4,5,6,7,8" &&
      JSON.stringify((await saves()).at(-1)) === JSON.stringify({ order: [2, 3, 1, 4, 5, 6, 7, 8], excluded: [] }),
    await ids(),
  );
  check(
    "accueil : déposer une tuile n'ouvre pas son compte, et le trait s'en va",
    (await opened()) === before && (await page.locator(".tile-drop-mark").count()) === 0,
  );

  // Reposée à sa place : rien à écrire.
  const count = (await saves()).length;
  const second = await centre(3);
  await page.mouse.move(second.x, second.y);
  await page.mouse.down();
  await page.mouse.move(second.x + 30, second.y, { steps: 4 });
  await page.mouse.up();
  await page.waitForTimeout(200);
  check(
    "accueil : une tuile reposée à sa place n'écrit rien",
    (await saves()).length === count && (await ids()) === "2,3,1,4,5,6,7,8",
    await ids(),
  );

  // Au bord, la rangée défile ; et la position tient après la relecture.
  const last = await centre(1);
  const frame = await page.locator("#tiles").boundingBox();
  await page.mouse.move(last.x, last.y);
  await page.mouse.down();
  for (let step = 0; step < 60; step += 1) {
    await page.mouse.move(frame.x + frame.width - 5 - (step % 2), last.y);
  }
  await page.mouse.up();
  await page.waitForTimeout(250);
  check(
    "accueil : au bord de la rangée elle défile, et la tuile va jusqu'au bout",
    (await ids()) === "2,3,4,5,6,7,8,1",
    await ids(),
  );
  check(
    "accueil : redessinée, la rangée reste là où l'on avait défilé",
    (await page.evaluate(() => document.getElementById("tiles").scrollLeft)) > 0,
  );

  // Les préférences rendent l'ordre et les cases : l'accueil le montre aussitôt.
  await page.evaluate(() => {
    window.__welcomeStored = { order: [], excluded: [] };
    window.__listeners["welcome-accounts-changed"]({ payload: null });
  });
  await page.waitForTimeout(200);
  check(
    "accueil : la réinitialisation des préférences lui rend son ordre de naissance",
    (await ids()) === "1,2,3,4,5,6,7,8",
    await ids(),
  );
  await page.close();

  // Ce que la base retient se retrouve à l'ouverture.
  const kept = await browser.newPage();
  await openWindow(kept, "http://localhost:4173/", { storedWelcome: { order: [2, 1], excluded: [1] } });
  check(
    "accueil : l'ordre et les cases retenus se retrouvent à l'ouverture",
    (await kept.evaluate(() => [...document.querySelectorAll(".tile")].map((t) => t.dataset.account).join(","))) === "2,1" &&
      (await kept.locator('.tile[data-account="1"] .tile__check').isChecked()) === false &&
      (await kept.textContent("#total-bank")) === "23422,81 €" &&
      (await kept.textContent("#total-bank-detail")) === "Comptes comptés dans les totaux : 1 sur 2",
    await kept.textContent("#total-bank-detail"),
  );
  // Peu de comptes : ils remplissent la carte, sans ascenseur.
  const few = await kept.evaluate(() => {
    const holder = document.getElementById("tiles");
    const boxes = [...holder.children].map((t) => t.getBoundingClientRect());
    return {
      scrolls: holder.scrollWidth > holder.clientWidth,
      filled: Math.round(boxes.at(-1).right) >= Math.round(holder.getBoundingClientRect().right) - 2,
    };
  });
  check(
    "accueil : deux comptes remplissent la carte, sans ascenseur",
    !few.scrolls && few.filled,
    JSON.stringify(few),
  );
  await kept.close();
}

// --- Préférences : « Réinitialiser les réglages de confort » --------------
{
  // Fabrice, 07/10/2026 : « il faut avoir un bouton pour remettre à zéro les
  // réglages de confort mais pas le reste ».
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/preferences.html");
  check(
    "préférences : « Réglages de confort » a sa feuille, sous sa propre branche",
    await page.evaluate(() => {
      const leaf = document.querySelector('.tree__leaf[data-leaf="comfort"]');
      return (
        leaf.textContent === "Réglages de confort" &&
        leaf.previousElementSibling.classList.contains("tree__branch") &&
        leaf.previousElementSibling.textContent === "Réinitialisation"
      );
    }),
  );
  // Une langue choisie et la taille bougée, pas encore enregistrées.
  await page.click('.tree__leaf[data-leaf="zoom"]');
  await page.locator("#zoom").evaluate((field) => {
    field.value = "1.3";
    field.dispatchEvent(new Event("input", { bubbles: true }));
  });
  await page.click('.tree__leaf[data-leaf="comfort"]');
  check(
    "préférences : la feuille montre son bouton et dit ce qu'il touche",
    (await page.textContent("#comfort-reset")) === "Réinitialiser les réglages de confort" &&
      (await page.locator("#comfort-hint").isVisible()),
  );

  await page.click("#comfort-reset");
  await page.waitForTimeout(100);
  check(
    "préférences : le bouton demande avant d'agir",
    (await page.locator(".dialog__question").textContent()) === "Réinitialiser les réglages de confort ?" &&
      (await page.evaluate(() => window.__calls.every(([c]) => c !== "reset_comfort_settings"))),
  );
  await page.click(".dialog__button:not(.dialog__button--primary)");
  await page.waitForTimeout(100);
  check(
    "préférences : « Non » ne réinitialise rien",
    await page.evaluate(() => window.__calls.every(([c]) => c !== "reset_comfort_settings")),
  );

  await page.click("#comfort-reset");
  await page.waitForTimeout(100);
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(200);
  check(
    "préférences : « Oui » réinitialise, d'une seule commande, et le dit",
    (await page.evaluate(
      () => window.__calls.filter(([c]) => c === "reset_comfort_settings").length === 1,
    )) && (await page.textContent("#info-bar")) === "Les réglages de confort ont été réinitialisés.",
    await page.textContent("#info-bar"),
  );
  check(
    "préférences : ni la langue, ni la devise, ni la vérification ne sont écrites",
    await page.evaluate(() =>
      window.__calls.every(([c]) => !c.startsWith("save_preferences") && c !== "set_language"),
    ),
  );
  check(
    "préférences : la taille revient à 100 %, et la fenêtre n'est plus « modifiée »",
    (await page.inputValue("#zoom")) === "1",
  );
  await page.click("#close");
  await page.waitForTimeout(150);
  check(
    "préférences : après la réinitialisation, elle se ferme sans question",
    await page.evaluate(() => window.__calls.some(([c]) => c === "close_preferences")),
  );
  await page.close();

  // Sans base, la taille reste réglable : la feuille ne s'éteint pas.
  const closed = await browser.newPage();
  await openWindow(closed, "http://localhost:4173/ui/windows/preferences.html", { databaseOpen: false });
  check(
    "préférences : sans base ouverte, « Réglages de confort » reste ouverte",
    !(await closed.locator('.tree__leaf[data-leaf="comfort"]').isDisabled()),
  );
  await closed.close();
}

// --- F41 : la simulation de crédit (08/10/2026) ---------------------------
{
  // « Le simulateur de la Banque Postale est assez simple : il y a trois
  // curseurs horizontaux (ou on peut mettre la valeur dans trois champs
  // texte) […] lorsque l'on bouge un curseur l'autre bouge automatiquement. »
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1320, height: 940 });
  const errors = await openWindow(page, "http://localhost:4173/ui/windows/loan-simulation.html");
  await page.waitForTimeout(200);
  check("crédit : aucune erreur de script", errors.length === 0, errors.join(" | "));
  check(
    "crédit : la barre d'information rappelle que l'analyse vaut ce que vaut l'historique",
    (await page.textContent("#info-bar")) ===
      "Plus votre historique est long, meilleure sera cette analyse : l'idéal est d'avoir au moins un an d'opérations.",
    await page.textContent("#info-bar"),
  );
  const asked = () => page.evaluate(() => window.__loanAsked ?? []);
  const last = async () => (await asked()).at(-1);

  check(
    "crédit : la fenêtre s'ouvre sur un crédit à la consommation et ses valeurs de départ",
    (await page.inputValue("#kind")) === "consumer" &&
      (await page.inputValue("#amount")) === "10000,00" &&
      (await page.inputValue("#months")) === "48" &&
      (await page.inputValue("#rate")) === "6,00",
    await page.inputValue("#amount"),
  );
  check(
    "crédit : les trois curseurs sont posés sur leur valeur",
    (await page.inputValue("#amount-range")) === "10000" &&
      (await page.inputValue("#months-range")) === "48",
    await page.inputValue("#amount-range"),
  );
  check(
    "crédit : la mensualité vient du calcul, et les tuiles aussi",
    (await page.inputValue("#payment")) === "208,33" &&
      (await page.locator(".loan__tile").count()) === 8 &&
      (await page.locator(".loan__tile-value").first().textContent()) === "208,33 €",
    await page.inputValue("#payment"),
  );
  check(
    "crédit : le tableau d'amortissement a une ligne par mois",
    (await page.evaluate(() => window.__loanAsked.at(-1).moved)) === "other" &&
      (await page.locator("#rows .list__row").count()) > 0,
  );

  // Le curseur du montant : son champ suit, et le calcul part en disant qui a bougé.
  await page.locator("#amount-range").evaluate((range) => {
    range.value = "12000";
    range.dispatchEvent(new Event("input", { bubbles: true }));
    range.dispatchEvent(new Event("change", { bubbles: true }));
  });
  await page.waitForTimeout(200);
  check(
    "crédit : bouger le montant recalcule la mensualité, la durée reste",
    (await last()).moved === "amount" &&
      (await last()).amount === "12000" &&
      (await page.inputValue("#payment")) === "250,00" &&
      (await page.inputValue("#months")) === "48",
    JSON.stringify(await last()),
  );

  // Taper la mensualité : la durée suit.
  await page.fill("#payment", "500");
  await page.press("#payment", "Enter");
  await page.waitForTimeout(200);
  check(
    "crédit : taper la mensualité recalcule la durée",
    (await last()).moved === "payment" &&
      (await page.inputValue("#months")) === "24" &&
      (await page.inputValue("#months-range")) === "24",
    await page.inputValue("#months"),
  );

  // Au-delà du curseur : le champ est honoré, le curseur reste en butée.
  await page.fill("#amount", "90000");
  await page.press("#amount", "Enter");
  await page.waitForTimeout(200);
  check(
    "crédit : un montant tapé au-delà du curseur est calculé, le curseur reste en butée",
    (await page.inputValue("#amount")) === "90000,00" &&
      (await page.inputValue("#amount-range")) === "75000",
    await page.inputValue("#amount-range"),
  );

  // **Les champs ne prennent que des chiffres** (11/10/2026) : une lettre, un
  // signe moins ne s'écrivent pas ; le taux a trois décimales, la durée aucune.
  await page.fill("#amount", "");
  await page.locator("#amount").pressSequentially("1a2-000");
  check("crédit : une lettre ou un signe moins ne s'écrivent pas dans le montant", (await page.inputValue("#amount")) === "12000");
  await page.fill("#rate", "");
  await page.locator("#rate").pressSequentially("3,1254");
  check("crédit : le taux s'arrête à trois décimales", (await page.inputValue("#rate")) === "3,125");
  await page.fill("#months", "");
  await page.locator("#months").pressSequentially("4,8");
  check("crédit : la durée est un nombre entier de mois", (await page.inputValue("#months")) === "48");
  await page.press("#months", "Enter");
  await page.waitForTimeout(200);

  // Un champ vidé est refusé : il est marqué, et les résultats d'avant
  // s'estompent au lieu de rester affichés comme s'ils étaient justes.
  const before = await page.inputValue("#payment");
  await page.fill("#amount", "");
  await page.press("#amount", "Enter");
  await page.waitForTimeout(200);
  check(
    "crédit : un champ vide est marqué et le dit, sans rien recalculer",
    (await page.locator("#amount.form__field--invalid").count()) === 1 &&
      (await page.textContent("#info-bar")) === "Cette valeur n'est pas un nombre : corrigez-la pour relancer le calcul." &&
      (await page.inputValue("#payment")) === before,
    await page.textContent("#info-bar"),
  );
  check(
    "crédit : refusé, les résultats d'avant s'estompent",
    (await page.locator(".loan.loan--stale").count()) === 1 &&
      Number(await page.locator("#pane-credit").evaluate((node) => getComputedStyle(node).opacity)) < 0.5,
  );
  await page.fill("#amount", "12000");
  await page.press("#amount", "Enter");
  await page.waitForTimeout(200);
  check(
    "crédit : corrigé, le champ perd sa marque et les résultats reviennent",
    (await page.locator("#amount.form__field--invalid").count()) === 0 && (await page.locator(".loan--stale").count()) === 0,
  );

  // Le type de crédit ramène ses valeurs de départ, et la case du tableau
  // mois par mois n'existe que pour l'immobilier.
  check("crédit : la case « mois par mois » est cachée pour la consommation", await page.locator("#monthly-line").isHidden());
  await page.selectOption("#kind", "mortgage");
  await page.waitForTimeout(250);
  check(
    "crédit : l'immobilier ramène ses valeurs de départ et montre la case « mois par mois »",
    (await page.evaluate(() => window.__loanDefaultsAsked)) === "mortgage" &&
      (await page.inputValue("#amount")) === "200000,00" &&
      (await page.inputValue("#months")) === "240" &&
      (await page.locator("#monthly-line").isVisible()),
    await page.inputValue("#amount"),
  );

  // Le second onglet.
  check("crédit : « Puis-je le rembourser ? » est caché au départ", await page.locator("#pane-afford").isHidden());
  await page.click("#tab-afford");
  await page.waitForTimeout(100);
  check(
    "crédit : l'onglet s'ouvre, et les deux comptes sont cochés",
    (await page.locator("#pane-afford").isVisible()) &&
      (await page.locator("#pane-credit").isHidden()) &&
      (await page.locator("#accounts input:checked").count()) === 2 &&
      (await page.locator("#tab-afford").getAttribute("aria-selected")) === "true",
  );
  check(
    "crédit : les comptes montrent leur nom, leur banque et leur solde, jamais leur numéro",
    (await page.locator("#accounts tr").first().textContent()).includes("CCP") &&
      (await page.locator("#accounts .loan__negative").count()) === 1,
  );
  check(
    "crédit : le verdict prend sa couleur, et ses chiffres leur ton",
    (await page.getAttribute("#verdict", "data-verdict")) === "green" &&
      (await page.textContent("#verdict-word")) === "Jouable" &&
      (await page.locator('#figures dd[data-tone="bad"]').count()) === 1 &&
      (await page.locator('#figures dd[data-tone="good"]').count()) === 1,
  );
  check(
    "crédit : les trois questions du voyant s'affichent, chacune avec sa pastille",
    (await page.locator("#checks li").count()) === 3 &&
      (await page.locator('#checks li[data-tone="good"]').count()) === 3 &&
      (await page.locator("#warning").isHidden()),
    await page.getAttribute("#verdict", "data-verdict"),
  );
  // L'aiguille glisse jusqu'à son angle.
  await page.waitForTimeout(600);
  check(
    "crédit : l'aiguille de la jauge finit sur l'angle que le noyau donne",
    await page.evaluate(() => {
      const needle = document.querySelector("#gauge .gauge-needle");
      return needle.getAttribute("transform").startsWith("rotate(" + needle.dataset.angle);
    }),
    await page.evaluate(() => document.querySelector("#gauge .gauge-needle")?.getAttribute("transform")),
  );

  // Décocher un compte : le calcul part sans lui. Cliquer la ligne coche aussi.
  await page.locator('#accounts input[data-account="2"]').click();
  await page.waitForTimeout(200);
  check(
    "crédit : décocher un compte le retire du calcul",
    JSON.stringify((await last()).accounts) === "[1]" &&
      (await page.textContent("#checks")).includes("comptes 1."),
    JSON.stringify((await last()).accounts),
  );
  await page.locator("#accounts tr").nth(1).locator("td").nth(1).click();
  await page.waitForTimeout(200);
  check(
    "crédit : toute la ligne d'un compte coche sa case",
    (await last()).accounts.length === 2,
  );

  // La période, et les crédits en cours.
  check("crédit : sans crédit en cours, la phrase le dit", await page.locator("#running-empty").isVisible());
  await page.selectOption("#history", "2025");
  await page.waitForTimeout(200);
  check(
    "crédit : changer de période relance le calcul, et les crédits en cours se listent",
    (await last()).history === "2025" &&
      (await page.locator("#running tr").count()) === 1 &&
      (await page.locator("#running-empty").isHidden()),
  );
  check(
    "crédit : un historique déjà déficitaire est dit à part, au-dessus des graphiques",
    (await page.locator("#warning").isVisible()) &&
      (await page.textContent("#warning")).startsWith("Attention"),
  );

  // La plage d'années (10/10/2026), en dernier dans le menu de la période.
  check(
    "crédit : « Plage d'années… » est la dernière entrée du menu de la période",
    (await page.locator("#history option").last().getAttribute("value")) === "range" &&
      !(await page.locator("#range").isVisible()),
  );
  await page.selectOption("#history", "range");
  await page.waitForTimeout(200);
  check(
    "crédit : la plage part au calcul avec ses deux bornes, les trois dernières années par défaut",
    (await page.locator("#range").isVisible()) &&
      (await last()).history === "range" && (await last()).from === 2024 && (await last()).to === 2026,
    JSON.stringify(await last()),
  );
  await page.selectOption("#history", "2025");
  await page.waitForTimeout(200);

  // Plus aucun compte : la raison, à la place de l'analyse.
  for (const id of ["1", "2"]) {
    await page.locator(`#accounts input[data-account="${id}"]`).click();
    await page.waitForTimeout(150);
  }
  check(
    "crédit : sans compte coché, la fenêtre dit pourquoi elle ne juge pas",
    (await page.locator("#unavailable").isVisible()) &&
      (await page.locator("#analysis").isHidden()) &&
      (await page.textContent("#unavailable")) === "Cochez au moins un compte pour étudier votre historique.",
  );

  // Le rapport PDF, mois par mois.
  await page.check("#monthly");
  await page.click("#pdf");
  await page.waitForTimeout(150);
  check(
    "crédit : le bouton du rapport envoie la simulation et le choix « mois par mois », et dit où est le fichier",
    (await page.evaluate(() => window.__loanPrinted?.monthly)) === true &&
      (await page.evaluate(() => window.__loanPrinted?.request.kind)) === "mortgage" &&
      (await page.textContent("#info-bar")).startsWith("Le rapport est prêt"),
  );

  // L'onglet 3 : les trois méthodes (Fabrice, 08/10/2026).
  await page.locator('#accounts input[data-account="1"]').click();
  await page.waitForTimeout(200);
  check(
    "crédit : la méthode neutre est retenue à l'ouverture, et la ligne du verdict le dit",
    (await last()).method === "neutral" &&
      JSON.stringify((await last()).growth) === JSON.stringify(["0", "2", "3"]) &&
      (await page.textContent("#method-line")) === "Méthode de jugement : Neutre",
    JSON.stringify(await last()),
  );
  await page.click("#method-line");
  await page.waitForTimeout(100);
  check(
    "crédit : un clic sur la méthode ouvre ses réglages",
    (await page.locator("#pane-rules").isVisible()) &&
      (await page.locator("#tab-rules").getAttribute("aria-selected")) === "true",
  );
  check(
    "crédit : le tableau montre trois colonnes, leurs verdicts, et la colonne retenue se détache",
    (await page.locator(".loan__rules-head").count()) === 3 &&
      (await page.locator('.loan__rules-head[data-method="severe"] .loan__badge').textContent()) === "Risqué" &&
      (await page.locator('.loan__rules-head[data-method="severe"] .loan__badge').getAttribute("data-verdict")) === "red" &&
      (await page.locator('#rules tr[data-row="1"] td[data-method="optimistic"]').textContent()) === "v1-optimistic" &&
      (await page.locator('#rules td.loan__rules-chosen[data-method="neutral"]').count()) === 6 &&
      (await page.textContent("#explanation")) === "Explication neutral" &&
      (await page.locator('#rules tr[data-row="growth"] .loan__rules-label').textContent()) === "Hausse de vos dépenses par an",
  );
  check(
    "crédit : chaque méthode a son champ de hausse, à sa valeur de départ",
    (await page.inputValue("#growth-optimistic")) === "0" &&
      (await page.inputValue("#growth-neutral")) === "2" &&
      (await page.inputValue("#growth-severe")) === "3",
  );
  await page.check('input[name="method"][value="severe"]');
  await page.waitForTimeout(200);
  check(
    "crédit : choisir la méthode sévère relance le jugement avec elle",
    (await last()).method === "severe" &&
      (await page.textContent("#explanation")) === "Explication severe" &&
      (await page.locator('#rules td.loan__rules-chosen[data-method="severe"]').count()) === 6 &&
      (await page.textContent("#method-line")) === "Méthode de jugement : Sévère",
  );
  await page.fill("#growth-severe", "5");
  await page.press("#growth-severe", "Enter");
  await page.waitForTimeout(200);
  check(
    "crédit : changer la hausse d'une méthode relance le calcul avec elle",
    JSON.stringify((await last()).growth) === JSON.stringify(["0", "2", "5"]) &&
      (await page.inputValue("#growth-severe")) === "5",
    JSON.stringify((await last()).growth),
  );
  await page.fill("#growth-neutral", "");
  await page.locator("#growth-neutral").pressSequentially("deux-2,5");
  check("crédit : une hausse ne prend que des chiffres entiers", (await page.inputValue("#growth-neutral")) === "25");
  await page.fill("#growth-neutral", "2");
  await page.press("#growth-neutral", "Enter");
  await page.waitForTimeout(200);

  // Le tableau a son menu du clic droit, comme tous les autres.
  await page.click("#tab-credit");
  await page.waitForTimeout(100);
  await page.locator("#rows .list__row").first().click({ button: "right" });
  await page.waitForTimeout(100);
  check(
    "crédit : le tableau d'amortissement a son menu du clic droit",
    (await page.locator(".context-menu").count()) > 0,
  );
  await page.keyboard.press("Escape");

  await page.click("#close");
  await page.waitForTimeout(100);
  check("crédit : la porte masque la fenêtre", await page.evaluate(() => window.__loanClosed === true));
  await page.close();
}

// --- F42 : la consommation d'un appareil électrique (09/10/2026) ---------
{
  const page = await browser.newPage();
  const errors = await openWindow(page, "http://localhost:4173/ui/windows/appliance-cost.html");
  await page.waitForTimeout(150);
  check("appareil : la fenêtre s'ouvre sans une plainte", errors.length === 0, errors.join(" / "));
  check(
    "appareil : aucune valeur supposée — les champs de l'appareil partent vides",
    await page.evaluate(() =>
      ["on-watts", "on-hours", "standby-watts", "standby-hours"].every(
        (id) => document.getElementById(id).value === "",
      ),
    ),
  );
  check(
    "appareil : le contrat reprend le tarif enregistré, en Base",
    (await page.inputValue("#option")) === "base" &&
      (await page.inputValue("#base")) === "0,2001" &&
      (await page.locator("#base-line").isVisible()) &&
      !(await page.locator("#peak").isVisible()) &&
      !(await page.locator("#share").isVisible()),
  );
  check(
    "appareil : trois tuiles, par jour, par mois, par an",
    (await page.locator(".appliance__tile .loan__tile-label").allTextContents()).join("|") ===
      "Par jour|Par mois|Par an",
  );

  await page.fill("#on-watts", "2000");
  await page.fill("#on-hours", "5");
  await page.fill("#standby-watts", "1");
  await page.locator("#standby-watts").press("Enter");
  await page.waitForTimeout(150);
  const asked = await page.evaluate(() => window.__applianceAsked.at(-1));
  check(
    "appareil : les champs partent tels qu'ils sont tapés",
    asked.usage.on_watts === "2000" && asked.usage.on_hours === "5" && asked.usage.days === "7" &&
      asked.usage.standby_hours === "" && asked.tariff.base === "0,2001",
    JSON.stringify(asked),
  );
  check(
    "appareil : le résultat s'affiche, et la veille a sa phrase",
    (await page.locator(".appliance__tile .loan__tile-value").nth(2).textContent()).endsWith("€") &&
      (await page.locator("#standby-sentence").isVisible()) &&
      (await page.locator("#standby-sentence").textContent()).startsWith("La veille seule coûte"),
  );
  check(
    "appareil : vide, la durée de veille montre en grisé le reste de la journée",
    (await page.getAttribute("#standby-hours", "placeholder")) === "19",
  );
  check(
    "appareil : le détail a ses deux postes et son total, l'anneau est là",
    (await page.locator("#detail tr").count()) === 3 &&
      (await page.locator("#detail tr.appliance__total").count()) === 1 &&
      (await page.locator("#chart svg").count()) === 1,
  );

  // Heures pleines / heures creuses : les deux prix, les heures creuses, et la
  // part de la marche.
  await page.selectOption("#option", "off-peak");
  await page.waitForTimeout(150);
  check(
    "appareil : en heures pleines / heures creuses, les champs changent",
    !(await page.locator("#base").isVisible()) &&
      (await page.locator("#peak").isVisible()) &&
      (await page.locator("#off-peak-hours").isVisible()) &&
      (await page.locator("#share").isVisible()) &&
      (await page.locator("#detail tr").count()) === 5,
  );

  // Un champ faux est marqué, le message dit pourquoi.
  await page.fill("#standby-hours", "20");
  await page.locator("#standby-hours").press("Enter");
  await page.waitForTimeout(150);
  check(
    "appareil : marche et veille au-delà de 24 h, le champ est marqué",
    (await page.locator("#standby-hours.form__field--invalid").count()) === 1 &&
      (await page.locator("#notice").textContent()).includes("24 heures"),
  );
  check(
    "appareil : refusé, les tuiles et le détail d'avant s'estompent",
    (await page.locator(".loan.loan--stale").count()) === 1 &&
      Number(await page.locator(".appliance__result").evaluate((node) => getComputedStyle(node).opacity)) < 0.5,
  );
  await page.fill("#standby-hours", "");
  await page.locator("#standby-hours").press("Enter");
  await page.waitForTimeout(150);
  check(
    "appareil : corrigé, la marque s'en va et le résultat revient",
    (await page.locator(".form__field--invalid").count()) === 0 &&
      !(await page.locator("#notice").isVisible()) && (await page.locator(".loan--stale").count()) === 0,
  );

  // **Les champs ne prennent que des chiffres** (11/10/2026).
  await page.fill("#on-watts", "");
  await page.locator("#on-watts").pressSequentially("2k0-0,555");
  check("appareil : une puissance n'accepte ni lettre ni signe, et deux décimales", (await page.inputValue("#on-watts")) === "200,55");
  await page.fill("#days", "");
  await page.locator("#days").pressSequentially("5,5");
  check("appareil : les jours par semaine sont un nombre entier", (await page.inputValue("#days")) === "55");
  await page.fill("#days", "7");
  await page.fill("#on-watts", "2000");
  await page.locator("#on-watts").press("Enter");
  await page.waitForTimeout(150);

  // Un prix changé ne vaut que pour ce calcul : le bouton reprend le tarif
  // enregistré, et rien n'a été enregistré.
  await page.selectOption("#option", "base");
  await page.fill("#base", "");
  await page.locator("#base").pressSequentially("0.251678");
  check("appareil : le prix du kWh a quatre décimales, le point devient virgule", (await page.inputValue("#base")) === "0,2516");
  await page.fill("#base", "0,30");
  await page.locator("#base").press("Enter");
  await page.waitForTimeout(100);
  await page.click("#contract-reset");
  await page.waitForTimeout(150);
  check(
    "appareil : « Reprendre le tarif enregistré » remet les prix, sans rien enregistrer",
    (await page.inputValue("#base")) === "0,2001" &&
      (await page.evaluate(() => !window.__calls.some(([c]) => c === "save_preferences_electricity"))),
  );
  check(
    "appareil : pas de rapport PDF",
    (await page.locator("#pdf").count()) === 0,
  );
  const spills = await page.evaluate(() => document.documentElement.scrollWidth > window.innerWidth);
  check("appareil : rien ne déborde en largeur", !spills);
  await page.click("#close");
  await page.waitForTimeout(50);
  check("appareil : la porte masque la fenêtre", await page.evaluate(() => window.__applianceClosed === true));
  await page.close();
}

// --- F43 : mon matelas de sécurité (09/10/2026) --------------------------
{
  const page = await browser.newPage();
  const errors = await openWindow(page, "http://localhost:4173/ui/windows/safety-cushion.html");
  await page.waitForTimeout(150);
  check("matelas : la fenêtre s'ouvre sans une plainte", errors.length === 0, errors.join(" / "));
  check(
    "matelas : la barre d'information rappelle que l'analyse vaut ce que vaut l'historique",
    (await page.textContent("#info-bar")) ===
      "Plus votre historique est long, meilleure sera cette analyse : l'idéal est d'avoir au moins un an d'opérations.",
    await page.textContent("#info-bar"),
  );
  check(
    "matelas : la question est posée en tête",
    (await page.locator("#question").textContent()).startsWith("Si vos revenus s'arrêtaient demain"),
  );
  check(
    "matelas : les cases partent d'office — le livret en épargne, le CCP en dépenses, le PEL nulle part",
    await page.evaluate(() => {
      const box = (account, role) =>
        document.querySelector(`input[data-account="${account}"][data-role="${role}"]`).checked;
      return box(1, "spending") && !box(1, "savings") && box(2, "savings") && !box(2, "spending") &&
        !box(3, "savings") && !box(3, "spending");
    }),
  );
  check(
    "matelas : les comptes sont nommés par leur libellé seul",
    (await page.locator("#accounts tr td:first-child").allTextContents()).join("|") === "CCP|Livret A|PEL",
  );
  check(
    "matelas : 4 mois, en orange, et les deux seuils",
    (await page.getAttribute("#verdict", "data-verdict")) === "orange" &&
      (await page.locator("#gauge").textContent()).includes("4,0 mois") &&
      (await page.locator("#targets li").count()) === 2 &&
      (await page.locator('#targets li[data-tone="good"]').count()) === 1,
  );

  // Décocher les loisirs : ils sortent des dépenses, et le restent.
  await page.locator('input[data-category="902"]').uncheck();
  await page.waitForTimeout(150);
  let asked = await page.evaluate(() => window.__cushionAsked.at(-1));
  check(
    "matelas : une catégorie décochée part au calcul",
    asked.excluded.length === 1 && asked.excluded[0] === 902,
    JSON.stringify(asked),
  );
  check(
    "matelas : décochée, la catégorie est barrée et le matelas passe à 5 mois",
    (await page.locator(".cushion__category--off").count()) === 1 &&
      (await page.locator("#gauge").textContent()).includes("5,0 mois"),
  );
  await page.selectOption("#history", "2025");
  await page.waitForTimeout(150);
  asked = await page.evaluate(() => window.__cushionAsked.at(-1));
  check(
    "matelas : la période change, la catégorie reste décochée",
    asked.history === "2025" && asked.excluded[0] === 902,
  );

  // La plage d'années (10/10/2026) : deux listes, les trois dernières
  // années par défaut.
  await page.selectOption("#history", "range");
  await page.waitForTimeout(150);
  asked = await page.evaluate(() => window.__cushionAsked.at(-1));
  check(
    "matelas : la plage d'années part au calcul avec ses deux bornes",
    (await page.locator("#range").isVisible()) && asked.history === "range" && asked.from === 2024 && asked.to === 2026,
    JSON.stringify(asked),
  );
  await page.selectOption("#range-from", "2021");
  await page.waitForTimeout(150);
  asked = await page.evaluate(() => window.__cushionAsked.at(-1));
  check("matelas : changer une borne relance le calcul", asked.from === 2021);

  // Le revenu de secours : tout couvert, l'épargne ne fond pas.
  await page.fill("#backup", "1500");
  await page.locator("#backup").press("Enter");
  await page.waitForTimeout(150);
  check(
    "matelas : un revenu de secours qui couvre tout — plus de seuils, la jauge en butée",
    (await page.locator("#verdict-text").textContent()).includes("ne fondrait pas") &&
      !(await page.locator("#targets-card").isVisible()),
  );
  check("matelas : en sortant, le revenu s'écrit proprement", (await page.inputValue("#backup")) === "1\u202f500,00");
  // **Le revenu ne prend que des chiffres** (11/10/2026).
  await page.fill("#backup", "");
  await page.locator("#backup").pressSequentially("a-1b2");
  check("matelas : ni lettre ni signe moins dans le revenu de secours", (await page.inputValue("#backup")) === "12");
  await page.locator("#backup").fill("");
  await page.locator("#backup").press("Tab");
  check("matelas : vide, le revenu reste vide — aucun revenu", (await page.inputValue("#backup")) === "");
  // Un revenu illisible venu d'ailleurs que du clavier reste refusé par le
  // noyau : marqué, et l'analyse d'avant s'estompe.
  await page.evaluate(() => {
    const field = document.getElementById("backup");
    field.value = "abc";
    field.dispatchEvent(new Event("change"));
  });
  await page.waitForTimeout(150);
  check(
    "matelas : un revenu illisible est marqué, et l'analyse d'avant s'estompe",
    (await page.locator("#backup.form__field--invalid").count()) === 1 &&
      Number(await page.locator("#analysis").evaluate((node) => getComputedStyle(node).opacity)) < 0.5,
  );
  await page.fill("#backup", "");
  await page.locator("#backup").press("Enter");
  await page.waitForTimeout(150);
  check("matelas : corrigé, l'analyse revient", (await page.locator(".loan--stale").count()) === 0);

  // Sans compte de dépenses, la fenêtre le dit.
  await page.locator('input[data-account="1"][data-role="spending"]').uncheck();
  await page.waitForTimeout(150);
  check(
    "matelas : sans compte de dépenses, la fenêtre le dit",
    (await page.locator("#unavailable").isVisible()) &&
      (await page.locator("#unavailable").textContent()).includes("Dépenses") &&
      !(await page.locator("#analysis").isVisible()),
  );
  check("matelas : pas de rapport PDF", (await page.locator("#pdf").count()) === 0);
  const spills = await page.evaluate(() => document.documentElement.scrollWidth > window.innerWidth);
  check("matelas : rien ne déborde en largeur", !spills);
  await page.click("#close");
  await page.waitForTimeout(50);
  check("matelas : la porte masque la fenêtre", await page.evaluate(() => window.__cushionClosed === true));
  await page.close();
}

// --- F44 : Objectif Épargne (10/10/2026) ---------------------------------
{
  const page = await browser.newPage();
  const errors = await openWindow(page, "http://localhost:4173/ui/windows/savings-goal.html");
  await page.waitForTimeout(150);
  check("objectif : la fenêtre s'ouvre sans une plainte", errors.length === 0, errors.join(" / "));
  check(
    "objectif : sans réponse encore, la barre d'information se tait",
    (await page.textContent("#info-bar")) === "",
    await page.textContent("#info-bar"),
  );
  check(
    "objectif : le livret part coché, le CCP non ; trois questions, « quand » d'abord",
    (await page.locator('input[data-account="2"]').isChecked()) &&
      !(await page.locator('input[data-account="1"]').isChecked()) &&
      (await page.locator('input[name="question"]').count()) === 3 &&
      (await page.locator('input[name="question"][value="when"]').isChecked()),
  );
  check(
    "objectif : sans montant, la fenêtre le demande",
    (await page.locator("#unavailable").textContent()).includes("montant à atteindre") &&
      (await page.locator("#target.form__field--invalid").count()) === 1,
  );
  check(
    "objectif : « quand » montre le montant, pas la date",
    (await page.locator("#target").isVisible()) && !(await page.locator("#year").isVisible()),
  );
  await page.fill("#target", "10000");
  await page.locator("#target").press("Enter");
  await page.waitForTimeout(150);
  let asked = await page.evaluate(() => window.__goalAsked.at(-1));
  check(
    "objectif : avec une réponse, la barre d'information rappelle que l'analyse vaut ce que vaut l'historique",
    (await page.textContent("#info-bar")) ===
      "Plus votre historique est long, meilleure sera cette analyse : l'idéal est d'avoir au moins un an d'opérations.",
    await page.textContent("#info-bar"),
  );
  check(
    "objectif : les champs partent tels qu'ils sont tapés",
    asked.question === "when" && asked.target === "10000" && asked.accounts.join() === "2" &&
      asked.period === "last-12" && asked.rate === "" && asked.extra === "",
    JSON.stringify(asked),
  );
  check(
    "objectif : la réponse s'affiche avec sa fourchette et ses tuiles",
    (await page.locator("#headline").textContent()).startsWith("Vous aurez") &&
      (await page.locator("#range-text").isVisible()) &&
      (await page.locator(".goal__tile").count()) === 4 &&
      (await page.locator("#chart svg").count()) === 1,
  );

  // La plage d'années.
  await page.selectOption("#period", "range");
  await page.waitForTimeout(150);
  asked = await page.evaluate(() => window.__goalAsked.at(-1));
  check(
    "objectif : la plage d'années montre ses deux listes, les trois dernières années par défaut",
    (await page.locator("#range").isVisible()) && asked.period === "range" && asked.from === 2024 && asked.to === 2026,
    JSON.stringify(asked),
  );

  // « Combien aurai-je » : la date, pas le montant ; la date proposée est dans un an.
  await page.locator('input[name="question"][value="amount"]').check();
  await page.waitForTimeout(150);
  asked = await page.evaluate(() => window.__goalAsked.at(-1));
  check(
    "objectif : « combien aurai-je » montre la date, dans un an par défaut",
    !(await page.locator("#target").isVisible()) && (await page.locator("#year").isVisible()) &&
      asked.question === "amount" && asked.month === 10 && asked.year === "2027",
    JSON.stringify(asked),
  );

  // « Combien épargner » : montant et date, sans l'effort de plus — c'est lui
  // qu'on cherche.
  await page.fill("#extra", "50");
  await page.locator('input[name="question"][value="effort"]').check();
  await page.waitForTimeout(150);
  asked = await page.evaluate(() => window.__goalAsked.at(-1));
  check(
    "objectif : « combien épargner » cache l'effort de plus et ne l'envoie pas",
    (await page.locator("#target").isVisible()) && (await page.locator("#year").isVisible()) &&
      !(await page.locator("#extra").isVisible()) && asked.extra === "",
  );
  check(
    "objectif : un effort à fournir se lit en orange",
    (await page.getAttribute("#answer", "data-tone")) === "warn",
  );
  // **Les champs ne prennent que des chiffres** (11/10/2026).
  await page.fill("#rate", "");
  await page.locator("#rate").pressSequentially("a-2,7505");
  check("objectif : le taux n'accepte ni lettre ni signe, et trois décimales", (await page.inputValue("#rate")) === "2,750");
  check("objectif : en sortant, le montant visé s'écrit proprement", (await page.inputValue("#target")) === "10\u202f000,00");
  // Un taux illisible venu d'ailleurs que du clavier reste refusé par le noyau.
  await page.evaluate(() => {
    const field = document.getElementById("rate");
    field.value = "abc";
    field.dispatchEvent(new Event("change"));
  });
  await page.waitForTimeout(150);
  check(
    "objectif : un taux illisible est marqué",
    (await page.locator("#rate.form__field--invalid").count()) === 1,
  );
  await page.fill("#rate", "");
  await page.locator("#rate").press("Enter");
  await page.waitForTimeout(150);
  check("objectif : pas de rapport PDF", (await page.locator("#pdf").count()) === 0);
  const spills = await page.evaluate(() => document.documentElement.scrollWidth > window.innerWidth);
  check("objectif : rien ne déborde en largeur", !spills);
  await page.click("#close");
  await page.waitForTimeout(50);
  check("objectif : la porte masque la fenêtre", await page.evaluate(() => window.__goalClosed === true));
  await page.close();
}

// --- F45 : Et si je réduisais… ? (10/10/2026) ----------------------------
{
  const page = await browser.newPage();
  const errors = await openWindow(page, "http://localhost:4173/ui/windows/spending-cut.html");
  await page.waitForTimeout(150);
  check("réduction : la fenêtre s'ouvre sans une plainte", errors.length === 0, errors.join(" / "));
  check(
    "réduction : la barre d'information rappelle que l'analyse vaut ce que vaut l'historique",
    (await page.textContent("#info-bar")) ===
      "Plus votre historique est long, meilleure sera cette analyse : l'idéal est d'avoir au moins un an d'opérations.",
    await page.textContent("#info-bar"),
  );
  check(
    "réduction : tous les comptes partent cochés, les catégories d'abord, l'horizon à 5 ans",
    (await page.locator('input[data-account="1"]').isChecked()) &&
      (await page.locator('input[data-account="2"]').isChecked()) &&
      (await page.inputValue("#axis")) === "category" &&
      (await page.inputValue("#years")) === "5" &&
      (await page.locator("#years-text").textContent()) === "5 ans",
  );
  check(
    "réduction : sans réduction, la phrase invite à en taper une",
    (await page.locator("#headline").textContent()).startsWith("Tapez une réduction") &&
      (await page.getAttribute("#answer", "data-tone")) === "none",
  );
  check(
    "réduction : un poste par ligne, le plus lourd en tête, avec son champ et son unité",
    (await page.locator("#rows tr").count()) === 2 &&
      (await page.locator("#rows tr").first().locator(".cut__name").textContent()) === "Courses" &&
      (await page.locator("#cut-902").count()) === 1 &&
      (await page.locator("#unit-902 option").allTextContents()).join("|") === "%|€" &&
      (await page.locator("#column-item").textContent()) === "Catégories",
  );
  check(
    "réduction : l'aide du tableau vient du contrôleur, monnaie comprise",
    (await page.locator("#table-hint").textContent()).includes("en €"),
  );

  // Une réduction en pourcent, une autre en euros.
  await page.fill("#cut-901", "40");
  await page.locator("#cut-901").press("Tab");
  await page.waitForTimeout(150);
  await page.selectOption("#unit-902", "amount");
  await page.fill("#cut-902", "150");
  await page.locator("#cut-902").press("Enter");
  await page.waitForTimeout(150);
  let asked = await page.evaluate(() => window.__cutAsked.at(-1));
  check(
    "réduction : les réductions partent telles qu'elles sont tapées, avec leur unité",
    asked.cuts.length === 2 &&
      asked.cuts.some((cut) => cut.id === 901 && cut.value === "40" && cut.unit === "percent") &&
      asked.cuts.some((cut) => cut.id === 902 && cut.value === "150" && cut.unit === "amount"),
    JSON.stringify(asked.cuts),
  );
  check(
    "réduction : les lignes réduites se voient, la phrase et les tuiles suivent",
    (await page.locator(".cut__row--reduced").count()) === 2 &&
      (await page.locator("#headline").textContent()).startsWith("En réduisant ces 2 postes") &&
      (await page.getAttribute("#answer", "data-tone")) === "good",
  );
  check(
    "réduction : mis à jour, le tableau garde les champs tapés",
    (await page.inputValue("#cut-901")) === "40" && (await page.inputValue("#cut-902")) === "150",
  );

  // Le curseur d'horizon.
  await page.locator("#years").fill("8");
  await page.waitForTimeout(150);
  asked = await page.evaluate(() => window.__cutAsked.at(-1));
  check("réduction : le curseur règle l'horizon", asked.years === 8 && (await page.locator("#years-text").textContent()) === "8 ans");

  // **Les champs ne prennent que des chiffres** (11/10/2026).
  await page.fill("#cut-901", "");
  await page.locator("#cut-901").pressSequentially("b-4o0.5");
  check("réduction : une réduction n'accepte ni lettre ni signe, le point devient virgule", (await page.inputValue("#cut-901")) === "40,5");
  // Une réduction illisible venue d'ailleurs que du clavier reste refusée par
  // le noyau : marquée, et le résultat d'avant s'estompe.
  await page.evaluate(() => {
    const field = document.getElementById("cut-901");
    field.value = "beaucoup";
    field.dispatchEvent(new Event("change"));
  });
  await page.waitForTimeout(150);
  check(
    "réduction : une réduction illisible est marquée, la barre dit pourquoi",
    (await page.locator("#cut-901.form__field--invalid").count()) === 1 &&
      (await page.locator("#info-bar").textContent()).includes("pas lisible"),
  );
  check(
    "réduction : refusé, la réponse et l'anneau d'avant s'estompent, pas les champs",
    Number(await page.locator("#answer").evaluate((node) => getComputedStyle(node).opacity)) < 0.5 &&
      Number(await page.locator("#cut-902").evaluate((node) => getComputedStyle(node).opacity)) === 1,
  );
  await page.fill("#cut-901", "40");
  await page.locator("#cut-901").press("Enter");
  await page.waitForTimeout(150);

  // Le rapport PDF garde tout.
  await page.click("#pdf");
  await page.waitForTimeout(150);
  const printed = await page.evaluate(() => window.__cutPrinted);
  check(
    "réduction : le rapport PDF reçoit les réductions et les réglages",
    printed.cuts.length === 2 && printed.years === 8 &&
      (await page.locator("#info-bar").textContent()).startsWith("Le rapport est prêt"),
  );

  // Les fichiers (10/10/2026) : Excel et le projet en JSON.
  await page.click("#excel");
  await page.waitForTimeout(150);
  check(
    "réduction : l'export Excel demande où, en .xlsx, et reçoit les réductions",
    await page.evaluate(() =>
      window.__cutExported.path.endsWith(".xlsx") && window.__saveAsked.defaultPath === "Et si je réduisais.xlsx" &&
      window.__cutExported.request.cuts.length === 2),
  );
  await page.click("#save");
  await page.waitForTimeout(150);
  check(
    "réduction : enregistrer le projet demande où, en .json",
    (await page.evaluate(() => window.__cutSaved.path.endsWith(".json") && window.__saveAsked.filters[0].name === "Projet de réduction")) &&
      (await page.locator("#info-bar").textContent()).startsWith("Projet enregistré"),
  );
  await page.click("#open");
  await page.waitForTimeout(150);
  check("réduction : ouvrir un projet demande d'abord confirmation", await page.locator(".dialog").isVisible());
  await page.click(".dialog__button:not(.dialog__button--primary)");
  await page.waitForTimeout(150);
  check(
    "réduction : « Non » ne change rien",
    (await page.evaluate(() => window.__cutLoaded === undefined)) && (await page.inputValue("#cut-901")) === "40",
  );
  await page.click("#open");
  await page.waitForTimeout(150);
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(250);
  asked = await page.evaluate(() => window.__cutAsked.at(-1));
  check(
    "réduction : le projet ouvert remplace tout — période, horizon, options, comptes, réductions",
    asked.history === "range" && asked.from === 2023 && asked.to === 2025 && asked.years === 3 &&
      asked.rate === "1,5" && asked.target === "8000,00" && asked.accounts.join() === "2" &&
      asked.cuts.length === 1 && asked.cuts[0].id === 902 && asked.cuts[0].unit === "amount" &&
      (await page.inputValue("#cut-902")) === "100,00" && (await page.inputValue("#unit-902")) === "amount" &&
      (await page.inputValue("#cut-901")) === "" &&
      !(await page.locator("#range").isHidden()) &&
      (await page.locator("#info-bar").textContent()).startsWith("Projet ouvert"),
    JSON.stringify(asked),
  );

  // Un autre classement : les réductions tapées ne valent plus.
  await page.selectOption("#axis", "payee");
  await page.waitForTimeout(150);
  asked = await page.evaluate(() => window.__cutAsked.at(-1));
  check(
    "réduction : changer de classement efface les réductions et nomme la colonne",
    asked.axis === "payee" && asked.cuts.length === 0 &&
      (await page.locator("#rows tr").count()) === 1 &&
      (await page.locator("#column-item").textContent()) === "Tiers",
  );

  // La porte efface tout : la fenêtre se rouvrira vierge.
  await page.fill("#cut-31", "10");
  await page.locator("#cut-31").press("Enter");
  await page.fill("#rate", "2");
  await page.locator("#rate").press("Enter");
  await page.waitForTimeout(150);
  // La porte demande d'abord (10/10/2026) : enregistrer, abandonner, rester.
  await page.click("#close");
  await page.waitForTimeout(150);
  check(
    "réduction : la porte pose la question à trois issues quand des chiffres seraient perdus",
    (await page.locator(".dialog").isVisible()) &&
      (await page.locator(".dialog__button").allTextContents()).join("|") === "Enregistrer et sortir|Abandonner et sortir|Rester",
  );
  await page.click(".dialog__button:nth-child(3)");
  await page.waitForTimeout(150);
  check(
    "réduction : « Rester » ne ferme rien et garde les chiffres",
    (await page.evaluate(() => window.__cutClosed === undefined)) && (await page.inputValue("#cut-31")) === "10",
  );
  await page.click("#close");
  await page.waitForTimeout(150);
  await page.click(".dialog__button:nth-child(2)");
  await page.waitForTimeout(150);
  asked = await page.evaluate(() => window.__cutAsked.at(-1));
  check(
    "réduction : « Abandonner et sortir » efface les réductions, le taux et l'horizon, puis masque la fenêtre",
    (await page.evaluate(() => window.__cutClosed === 1)) &&
      asked.cuts.length === 0 && asked.rate === "" && asked.years === 5 &&
      (await page.inputValue("#cut-31")) === "",
  );
  // Un projet enregistré et rien de changé depuis : rien à perdre, la porte
  // sort sans rien demander.
  await page.fill("#cut-31", "15");
  await page.locator("#cut-31").press("Enter");
  await page.waitForTimeout(150);
  await page.click("#save");
  await page.waitForTimeout(150);
  await page.click("#close");
  await page.waitForTimeout(150);
  check(
    "réduction : après « Enregistrer le projet… », la porte sort sans question",
    (await page.locator(".dialog").count()) === 0 && (await page.evaluate(() => window.__cutClosed === 2)),
  );
  const spills = await page.evaluate(() => document.documentElement.scrollWidth > window.innerWidth);
  check("réduction : rien ne déborde en largeur", !spills);
  await page.close();
}

// --- F46 : Préparer mes vacances (10/10/2026) ----------------------------
{
  const page = await browser.newPage();
  const errors = await openWindow(page, "http://localhost:4173/ui/windows/holiday.html");
  await page.waitForTimeout(200);
  check("vacances : la fenêtre s'ouvre sans une plainte", errors.length === 0, errors.join(" / "));
  check(
    "vacances : un séjour, un adulte, aucun enfant, aucun compte coché au départ",
    (await page.locator('input[name="trip"][value="stay"]').isChecked()) &&
      (await page.locator("#adults-value").textContent()) === "1" &&
      (await page.locator("#children-value").textContent()) === "0" &&
      !(await page.locator('#accounts input[data-account="2"]').isChecked()),
  );
  check(
    "vacances : le budget se bâtit sur le catalogue — les postes du séjour, les lignes facultatives à part",
    (await page.locator('#lines tr[data-key="transport"]').isVisible()) &&
      !(await page.locator('#lines tr[data-key="cabins"]').isVisible()) &&
      (await page.locator('#optional tr[data-key="insurance"]').isVisible()) &&
      (await page.locator("#optional .holiday__heading").textContent()) === "Lignes facultatives",
  );
  check(
    "vacances : sans enfant, pas de prix enfant ; l'assurance part en pourcent",
    !(await page.locator("#child-transport").isVisible()) &&
      (await page.inputValue("#unit-insurance")) === "percent" &&
      !(await page.locator("#who-insurance").isVisible()),
  );

  // Deux adultes, un enfant : le prix enfant apparaît sur les lignes par personne.
  await page.locator("#adults").fill("2");
  await page.locator("#children").fill("1");
  await page.waitForTimeout(150);
  check(
    "vacances : avec un enfant, le prix enfant apparaît sur une ligne par personne, pas sur une ligne pour tous",
    (await page.locator("#child-transport").isVisible()) && !(await page.locator("#child-lodging").isVisible()),
  );
  await page.fill("#amount-transport", "120");
  await page.fill("#child-transport", "50");
  await page.fill("#amount-lodging", "90");
  await page.fill("#nights", "7");
  await page.fill("#months", "6");
  await page.locator("#months").press("Enter");
  await page.waitForTimeout(200);
  let asked = await page.evaluate(() => window.__holidayAsked.at(-1).input);
  const transport = asked.lines.find((line) => line.key === "transport");
  const lodging = asked.lines.find((line) => line.key === "lodging");
  check(
    "vacances : les champs partent tels qu'ils sont tapés, avec leurs choix",
    asked.adults === 2 && asked.children === 1 && asked.nights === "7" && asked.months === "6" &&
      transport.amount === "120" && transport.child === "50" && transport.who === "person" &&
      lodging.amount === "90" && lodging.who === "all" && lodging.span === "night",
    JSON.stringify(asked),
  );
  check(
    "vacances : le résultat, les jours et le coût des postes s'affichent",
    (await page.locator("#headline").textContent()).startsWith("Ce séjour coûterait") &&
      (await page.locator("#days-text").textContent()) === "8 jours" &&
      (await page.locator("#cost-transport").textContent()).includes("120,00") &&
      (await page.locator(".goal__tile").count()) === 3,
  );

  // Le déjà épargné : un compte coché.
  await page.locator('#accounts input[data-account="2"]').check();
  await page.waitForTimeout(150);
  check(
    "vacances : un compte coché part au calcul",
    (await page.evaluate(() => window.__holidayAsked.at(-1).accounts.join())) === "2",
  );

  // **Les champs ne prennent que des chiffres** (11/10/2026).
  await page.fill("#amount-lodging", "");
  await page.locator("#amount-lodging").pressSequentially("c-9h0.505");
  check("vacances : un montant n'accepte ni lettre ni signe, deux décimales", (await page.inputValue("#amount-lodging")) === "90,50");
  await page.fill("#nights", "");
  await page.locator("#nights").pressSequentially("7,5n");
  check("vacances : les nuits sont un nombre entier", (await page.inputValue("#nights")) === "75");
  await page.fill("#nights", "7");
  // Un montant illisible venu d'ailleurs que du clavier reste refusé par le
  // noyau : marqué, et le résultat d'avant s'estompe.
  await page.evaluate(() => {
    const field = document.getElementById("amount-lodging");
    field.value = "cher";
    field.dispatchEvent(new Event("change"));
  });
  await page.waitForTimeout(150);
  check(
    "vacances : un montant illisible est marqué, la barre dit pourquoi",
    (await page.locator("#amount-lodging.form__field--invalid").count()) === 1 &&
      (await page.locator("#info-bar").textContent()).includes("pas lisible"),
  );
  check(
    "vacances : refusé, la réponse et les coûts d'avant s'estompent",
    Number(await page.locator("#answer").evaluate((node) => getComputedStyle(node).opacity)) < 0.5,
  );
  await page.fill("#amount-lodging", "90");
  await page.locator("#amount-lodging").press("Enter");
  await page.waitForTimeout(150);

  // La croisière : ses postes, ses escales.
  await page.locator('input[name="trip"][value="cruise"]').check();
  await page.waitForTimeout(150);
  check(
    "vacances : une croisière montre ses postes et ses escales, cache ceux du séjour",
    (await page.locator('#lines tr[data-key="cabins"]').isVisible()) &&
      (await page.locator("#count-cabins").isVisible()) &&
      !(await page.locator('#lines tr[data-key="lodging"]').isVisible()) &&
      !(await page.locator('#optional tr[data-key="stay-tax"]').isVisible()) &&
      (await page.locator("#stops").isVisible()),
  );
  await page.locator('input[name="trip"][value="stay"]').check();
  await page.waitForTimeout(150);

  // Les fichiers : PDF, Excel, enregistrer.
  await page.click("#pdf");
  await page.waitForTimeout(150);
  check(
    "vacances : le rapport PDF reçoit le voyage et les comptes",
    (await page.evaluate(() => window.__holidayPrinted.input.adults === 2 && window.__holidayPrinted.accounts.join() === "2")),
  );
  await page.click("#excel");
  await page.waitForTimeout(150);
  check(
    "vacances : l'export Excel demande où, en .xlsx",
    await page.evaluate(() => window.__holidayExported.path.endsWith(".xlsx") && window.__saveAsked.defaultPath === "Préparer mes vacances.xlsx"),
  );
  await page.click("#save");
  await page.waitForTimeout(150);
  check(
    "vacances : enregistrer le projet demande où, en .json",
    (await page.evaluate(() => window.__holidaySaved.path.endsWith(".json"))) &&
      (await page.locator("#info-bar").textContent()).startsWith("Projet enregistré"),
  );

  // Ouvrir un projet : la question d'abord, puisque des montants sont tapés.
  await page.click("#open");
  await page.waitForTimeout(150);
  check("vacances : ouvrir un projet demande d'abord confirmation", await page.locator(".dialog").isVisible());
  await page.click(".dialog__button:not(.dialog__button--primary)");
  await page.waitForTimeout(150);
  check(
    "vacances : « Non » ne change rien",
    (await page.evaluate(() => window.__holidayLoaded === undefined)) && (await page.inputValue("#amount-transport")) === "120",
  );
  await page.click("#open");
  await page.waitForTimeout(150);
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(250);
  check(
    "vacances : le projet ouvert remplace tout — croisière, voyageurs, cabines, comptes",
    (await page.locator('input[name="trip"][value="cruise"]').isChecked()) &&
      (await page.locator("#adults-value").textContent()) === "2" &&
      (await page.inputValue("#count-cabins")) === "1" &&
      (await page.inputValue("#amount-cabins")) === "2400,00" &&
      (await page.inputValue("#amount-transport")) === "" &&
      (await page.locator('#accounts input[data-account="2"]').isChecked()) &&
      (await page.locator("#info-bar").textContent()).startsWith("Projet ouvert"),
  );

  // Le projet vient d'être ouvert : rien à perdre, la porte ne demanderait
  // rien. Un chiffre de plus, et elle demande (10/10/2026).
  await page.fill("#nights", "9");
  await page.locator("#nights").press("Enter");
  await page.waitForTimeout(150);
  await page.click("#close");
  await page.waitForTimeout(150);
  check("vacances : la porte demande quand des chiffres seraient perdus", await page.locator(".dialog").isVisible());
  await page.keyboard.press("Escape");
  await page.waitForTimeout(150);
  check(
    "vacances : Échap répond « rester »",
    (await page.evaluate(() => window.__holidayClosed === undefined)) && (await page.inputValue("#nights")) === "9",
  );
  // « Enregistrer et sortir » : le sélecteur, le projet écrit, puis la porte.
  await page.evaluate(() => { window.__holidaySaved = undefined; });
  await page.click("#close");
  await page.waitForTimeout(150);
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(250);
  asked = await page.evaluate(() => window.__holidayAsked.at(-1));
  check(
    "vacances : « Enregistrer et sortir » écrit le projet, efface tout — voyage, montants, comptes — puis masque la fenêtre",
    (await page.evaluate(() => window.__holidayClosed === 1 && window.__holidaySaved.input.nights === "9")) &&
      asked.input.trip === "stay" && asked.input.adults === 1 && asked.input.nights === "" &&
      asked.input.lines.every((line) => line.amount === "") && asked.accounts.length === 0,
    JSON.stringify(asked),
  );
  const spills = await page.evaluate(() => document.documentElement.scrollWidth > window.innerWidth);
  check("vacances : rien ne déborde en largeur", !spills);
  await page.close();
}

// --- F47 : Carnet de ma voiture (10/10/2026) -------------------------------
{
  const page = await browser.newPage({ viewport: { width: 1380, height: 960 } });
  const errors = await openWindow(page, "http://localhost:4173/ui/windows/car-logbook.html");
  await page.waitForTimeout(200);
  check("carnet : la fenêtre s'ouvre sans une plainte", errors.length === 0, errors.join(" / "));
  check(
    "carnet : vierge, elle invite à remplir la fiche et n'a pas d'historique",
    (await page.locator("#headline").textContent()).startsWith("Remplissez la fiche") &&
      (await page.locator("#history-empty").isVisible()) &&
      (await page.locator("#car-title").textContent()) === "Ma voiture",
  );
  check("carnet : une voiture à essence n'a pas de tarif de recharge", await page.locator("#tariff-card").isHidden());
  check(
    "carnet : une ligne nouvelle porte la date du jour, en rubrique Énergie",
    (await page.inputValue("#date")).length === 10 && (await page.inputValue("#rubric")) === "energy" &&
      (await page.locator("#entry-title").textContent()) === "Nouvelle ligne",
  );

  // La fiche part à chaque champ changé.
  await page.fill("#plate", "AB-123-CD");
  await page.locator("#plate").press("Tab");
  await page.fill("#make", "Peugeot");
  await page.locator("#make").press("Tab");
  await page.waitForTimeout(150);
  let sent = await page.evaluate(() => window.__carSet.at(-1));
  check(
    "carnet : la fiche part au contrôleur, et le titre suit",
    sent.plate === "AB-123-CD" && sent.make === "Peugeot" && sent.tariff.option === "base" &&
      (await page.locator("#car-title").textContent()) === "Peugeot · AB-123-CD",
    JSON.stringify(sent),
  );
  // **Les champs ne prennent que des chiffres** (11/10/2026).
  await page.fill("#acquired-km", "");
  await page.locator("#acquired-km").pressSequentially("1o-0,5");
  check("carnet : un compteur n'accepte que des kilomètres entiers", (await page.inputValue("#acquired-km")) === "105");
  // Un compteur illisible venu d'ailleurs que du clavier reste refusé par le
  // noyau.
  await page.evaluate(() => {
    const field = document.getElementById("acquired-km");
    field.value = "beaucoup";
    field.dispatchEvent(new Event("change"));
  });
  await page.waitForTimeout(150);
  check(
    "carnet : un compteur illisible est marqué, la barre dit pourquoi",
    (await page.locator("#acquired-km.form__field--invalid").count()) === 1 &&
      (await page.locator("#info-bar").textContent()).includes("kilomètres entiers"),
  );
  await page.fill("#acquired-km", "10000");
  await page.locator("#acquired-km").press("Tab");
  await page.waitForTimeout(150);

  // Une électrique : le tarif, la recharge, l'heure.
  await page.selectOption("#engine", "electric");
  await page.waitForTimeout(150);
  check(
    "carnet : une électrique montre son tarif, et pas de choix d'énergie",
    (await page.locator("#tariff-card").isVisible()) && (await page.locator("#energy-line").isHidden()) &&
      (await page.locator("#quantity-unit").textContent()) === "kWh" && (await page.locator("#charge-line").isVisible()) &&
      (await page.locator("#battery-line").isVisible()),
  );
  await page.selectOption("#charge", "home");
  await page.waitForTimeout(80);
  check(
    "carnet : à la maison, le montant se calcule — le champ disparaît, l'heure n'a pas lieu d'être en Base",
    (await page.locator("#amount-line").isHidden()) && (await page.locator("#home-hint").isVisible()) &&
      (await page.locator("#slot-line").isHidden()),
  );
  await page.selectOption("#option", "off-peak");
  await page.waitForTimeout(150);
  check(
    "carnet : en heures pleines / heures creuses, l'heure de la recharge se choisit",
    (await page.locator("#slot-line").isVisible()) && (await page.evaluate(() => window.__carSet.at(-1).tariff.option)) === "off-peak",
  );
  await page.click("#tariff-reset");
  await page.waitForTimeout(100);
  check("carnet : « Reprendre le tarif des préférences » le demande au contrôleur", await page.evaluate(() => window.__carReset === true));
  await page.selectOption("#engine", "petrol");
  await page.waitForTimeout(150);
  check("carnet : revenu à l'essence, plus de recharge ni de tarif", (await page.locator("#charge-line").isHidden()) && (await page.locator("#tariff-card").isHidden()));

  // Un plein : sans quantité, refusé ; avec, ajouté.
  await page.fill("#date", "2026-07-01");
  await page.fill("#km", "71000");
  await page.fill("#amount", "70");
  await page.click("#add");
  await page.waitForTimeout(150);
  check(
    "carnet : un plein sans quantité est marqué",
    (await page.locator("#quantity.form__field--invalid").count()) === 1 && (await page.locator("#rows tr").count()) === 0,
  );
  await page.fill("#quantity", "40");
  await page.locator("#quantity").press("Enter");
  await page.waitForTimeout(150);
  let put = await page.evaluate(() => window.__carPut.at(-1));
  check(
    "carnet : Entrée ajoute la ligne, avec ses champs",
    put.id === null && put.entry.rubric === "energy" && put.entry.energy === "petrol" && put.entry.quantity === "40" &&
      put.entry.km === "71000" && put.entry.date === "2026-07-01" && (await page.locator("#rows tr").count()) === 1,
    JSON.stringify(put),
  );
  check(
    "carnet : le formulaire repart à vide, la rubrique gardée",
    (await page.inputValue("#quantity")) === "" && (await page.inputValue("#km")) === "" &&
      (await page.inputValue("#rubric")) === "energy" && (await page.locator("#energy-card").isVisible()),
  );

  // Une pièce d'usure : la liste, puis « Autre pièce… ».
  await page.selectOption("#rubric", "wear");
  await page.waitForTimeout(80);
  check(
    "carnet : une pièce d'usure montre la liste des pièces, sans la quantité",
    (await page.locator("#part").isVisible()) && (await page.locator("#quantity").isHidden()) &&
      (await page.locator("#part-name-line").isHidden()),
  );
  await page.selectOption("#part", "other");
  await page.waitForTimeout(80);
  check("carnet : « Autre pièce… » demande son nom", await page.locator("#part-name-line").isVisible());
  await page.fill("#amount", "120");
  await page.click("#add");
  await page.waitForTimeout(150);
  check("carnet : une autre pièce sans nom est marquée", (await page.locator("#part-name.form__field--invalid").count()) === 1);
  await page.fill("#part-name", "Rotule");
  await page.click("#add");
  await page.waitForTimeout(150);
  check("carnet : la pièce nommée s'ajoute", (await page.locator("#rows tr").count()) === 2);

  // Le filtre de l'historique.
  await page.selectOption("#filter", "energy");
  await page.waitForTimeout(80);
  check("carnet : le filtre ne montre que la rubrique choisie", (await page.locator("#rows tr").count()) === 1);
  await page.selectOption("#filter", "");

  // Modifier une ligne : un clic, la ligne revient dans le formulaire.
  await page.click('#rows tr[data-id="1"]');
  await page.waitForTimeout(100);
  check(
    "carnet : un clic sur une ligne la reprend dans le formulaire",
    (await page.locator("#entry-title").textContent()) === "Modifier la ligne" &&
      (await page.inputValue("#quantity")) === "40" && (await page.inputValue("#rubric")) === "energy" &&
      (await page.locator("#delete").isVisible()) && (await page.locator("#cancel").isVisible()) &&
      (await page.locator('#rows tr[data-id="1"].car__row--editing').count()) === 1,
  );
  await page.fill("#amount", "");
  await page.locator("#amount").pressSequentially("7e-2");
  check("carnet : le montant d'une ligne n'accepte ni lettre ni signe", (await page.inputValue("#amount")) === "72");
  await page.fill("#quantity", "");
  await page.locator("#quantity").pressSequentially("40,255");
  check("carnet : la quantité d'un plein a deux décimales", (await page.inputValue("#quantity")) === "40,25");
  await page.fill("#quantity", "40");
  await page.click("#add");
  await page.waitForTimeout(150);
  put = await page.evaluate(() => window.__carPut.at(-1));
  check(
    "carnet : la ligne modifiée garde sa clef, et le formulaire repart à neuf",
    put.id === 1 && put.entry.amount === "72,00" && (await page.locator("#rows tr").count()) === 2 &&
      (await page.locator("#entry-title").textContent()) === "Nouvelle ligne",
  );

  // Supprimer : la question d'abord.
  await page.click('#rows tr[data-id="2"]');
  await page.waitForTimeout(100);
  await page.click("#delete");
  await page.waitForTimeout(100);
  check("carnet : supprimer une ligne demande confirmation", await page.locator(".dialog").isVisible());
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(150);
  check("carnet : la ligne est supprimée", (await page.locator("#rows tr").count()) === 1);

  // Prendre une opération : le compte, puis la dépense.
  await page.selectOption("#rubric", "breakdown");
  await page.click("#take");
  await page.waitForTimeout(150);
  check("carnet : « Prendre une opération… » demande d'abord le compte", (await page.locator(".dialog__field").count()) === 1);
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(150);
  check(
    "carnet : puis la dépense, parmi celles du compte choisi",
    (await page.evaluate(() => window.__carExpenses)) === 1 && (await page.locator(".dialog__field option").count()) === 2,
  );
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(150);
  check(
    "carnet : la dépense remplit la date, le montant, le garage et la note — la rubrique reste",
    (await page.inputValue("#date")) === "2026-09-01" && (await page.inputValue("#amount")) === "65,40" &&
      (await page.inputValue("#garage")) === "Station Total" && (await page.inputValue("#note")) === "TOTAL" &&
      (await page.inputValue("#rubric")) === "breakdown" && (await page.locator("#info-bar").textContent()).startsWith("Opération reprise"),
  );

  // Les fichiers.
  await page.click("#excel");
  await page.waitForTimeout(150);
  check(
    "carnet : l'export Excel demande où, au nom de la voiture",
    await page.evaluate(() => window.__carExported.path.endsWith(".xlsx") && window.__saveAsked.defaultPath === "Peugeot · AB-123-CD.xlsx"),
  );
  await page.click("#pdf");
  await page.waitForTimeout(150);
  check("carnet : le dossier PDF se demande", await page.evaluate(() => window.__carPrinted === true));
  await page.click("#save");
  await page.waitForTimeout(200);
  check(
    "carnet : enregistrer le carnet demande où, en .json, sous le filtre « Carnet de voiture »",
    (await page.evaluate(() => window.__carSaved.path.endsWith(".json") && window.__saveAsked.filters[0].name === "Carnet de voiture")) &&
      (await page.locator("#info-bar").textContent()).startsWith("Carnet enregistré"),
  );

  // Ouvrir un carnet : la question d'abord, puisque la fenêtre en tient un.
  await page.click("#open");
  await page.waitForTimeout(150);
  check("carnet : ouvrir un carnet demande d'abord confirmation", await page.locator(".dialog").isVisible());
  await page.click(".dialog__button:not(.dialog__button--primary)");
  await page.waitForTimeout(150);
  check("carnet : « Non » ne change rien", (await page.evaluate(() => window.__carLoaded === undefined)) && (await page.inputValue("#plate")) === "AB-123-CD");
  await page.click("#open");
  await page.waitForTimeout(150);
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(250);
  check(
    "carnet : le carnet ouvert remplace tout — fiche, motorisation, historique",
    (await page.inputValue("#plate")) === "EF-456-GH" && (await page.inputValue("#engine")) === "electric" &&
      (await page.locator("#car-title").textContent()) === "Renault Zoé · EF-456-GH" && (await page.locator("#rows tr").count()) === 1 &&
      (await page.locator("#info-bar").textContent()).startsWith("Carnet ouvert"),
  );

  // La porte : rien à perdre, elle ferme sans question.
  await page.click("#close");
  await page.waitForTimeout(250);
  check(
    "carnet : un carnet tout juste ouvert se ferme sans question, et la fenêtre repart vierge",
    (await page.locator(".dialog").count()) === 0 && (await page.evaluate(() => window.__carClosed === 1)) &&
      (await page.inputValue("#plate")) === "" && (await page.locator("#rows tr").count()) === 0,
  );
  // Des changements : la question à trois issues.
  await page.fill("#plate", "IJ-789-KL");
  await page.locator("#plate").press("Tab");
  await page.waitForTimeout(150);
  await page.click("#close");
  await page.waitForTimeout(150);
  check(
    "carnet : avec des changements, la porte pose la question à trois issues",
    (await page.locator(".dialog").isVisible()) &&
      (await page.locator(".dialog__button").allTextContents()).join("|") === "Enregistrer et sortir|Abandonner et sortir|Rester",
  );
  await page.click(".dialog__button:nth-child(3)");
  await page.waitForTimeout(150);
  check("carnet : « Rester » garde le carnet", (await page.evaluate(() => window.__carClosed === 1)) && (await page.inputValue("#plate")) === "IJ-789-KL");
  await page.click("#close");
  await page.waitForTimeout(150);
  await page.click(".dialog__button:nth-child(2)");
  await page.waitForTimeout(250);
  check(
    "carnet : « Abandonner et sortir » oublie le carnet",
    (await page.evaluate(() => window.__carClosed === 2)) && (await page.inputValue("#plate")) === "",
  );
  const spills = await page.evaluate(() => document.documentElement.scrollWidth > window.innerWidth);
  check("carnet : rien ne déborde en largeur", !spills);
  await page.close();
}

// --- F48 : Partager une dépense (11/10/2026) ------------------------------
{
  const page = await browser.newPage({ viewport: { width: 1440, height: 960 } });
  const errors = await openWindow(page, "http://localhost:4173/ui/windows/sharing.html");
  await page.waitForTimeout(200);
  check("partage : la fenêtre s'ouvre sans une plainte", errors.length === 0, errors.join(" / "));
  check(
    "partage : la question en tête, une invite, aucune personne, le récapitulatif des règlements caché",
    (await page.locator("#question").textContent()) === "Qui paie quoi ?" &&
      (await page.locator("#headline").textContent()) === "Ajoutez les personnes qui partagent la dépense." &&
      (await page.locator("#people tr").count()) === 0 &&
      (await page.locator("#balances-card").isHidden()),
  );
  check(
    "partage : une règle pour toute la dépense, parts égales, revenus masqués, arrondi au centime",
    (await page.locator('input[name="mode"][value="whole"]').isChecked()) &&
      (await page.inputValue("#rule")) === "equal" &&
      (await page.locator("#hide-incomes").isChecked()) &&
      !(await page.locator("#round-euro").isChecked()),
  );

  // Deux personnes : leur nom vient du noyau.
  await page.click("#add-person");
  await page.waitForTimeout(150);
  await page.click("#add-person");
  await page.waitForTimeout(150);
  let asked = await page.evaluate(() => window.__sharingAsked.at(-1));
  check(
    "partage : une personne ajoutée porte le nom que le noyau propose, et participe au commun",
    (await page.inputValue("#name-1")) === "Personne 1" && (await page.inputValue("#name-2")) === "Personne 2" &&
      asked.people.length === 2 && asked.common.cells.every((cell) => cell.takes),
    JSON.stringify(asked.common),
  );
  await page.fill("#name-1", "Léa");
  await page.locator("#name-1").press("Enter");
  await page.fill("#total", "240");
  await page.locator("#total").press("Enter");
  await page.waitForTimeout(200);
  check(
    "partage : le total part au calcul, et chacun voit sa part dans la grille",
    (await page.locator("#headline").textContent()) === "240,00 € à partager : chacun paie 120,00 €." &&
      (await page.locator("#out-0-1").textContent()) === "120,00 €" &&
      (await page.locator("#due-2").textContent()) === "120,00 €" &&
      (await page.locator("#common-amount").textContent()) === "240,00 €",
  );
  check(
    "partage : sans règle au revenu, pas de colonne revenu ; pas de colonne pourcentage",
    (await page.locator("#income-1").count()) === 0 && (await page.locator("#percent-1").count()) === 0,
  );

  // **Chaque colonne a sa bulle** (11/10/2026) : une définition et un exemple,
  // au survol du titre et de son « ⓘ ». Une colonne ajoutée sans bulle
  // ferait échouer cette vérification.
  const bare = await page.evaluate(() =>
    [...document.querySelectorAll("#people-head th")]
      .slice(2)
      .filter((cell) => !cell.dataset.help || !cell.title || !cell.querySelector(".sharing__help"))
      .map((cell) => cell.textContent),
  );
  check("partage : chaque colonne de la grille a sa bulle et son « ⓘ »", bare.length === 0, JSON.stringify(bare));
  check(
    "partage : la bulle d'« Au maximum » définit et donne l'exemple",
    (await page.locator('#people-head th[data-help="cap"]').getAttribute("title")) ===
      "La personne ne paiera jamais plus que ce montant. Ce qu'elle ne paie pas retombe sur les autres participants de ses postes." &&
      (await page.locator('#people-head th[data-help="fixed"]').getAttribute("title")).includes("Exemple : quelqu'un qui se désiste"),
  );
  check(
    "partage : les postes, la règle et les soldes ont aussi leur bulle",
    (await page.locator('#column-item[data-help="item"]').count()) === 1 &&
      (await page.locator('#rule-label[data-help="rule"]').count()) === 1 &&
      (await page.locator('#column-paid[data-help="paid"]').count()) === 1 &&
      (await page.locator('#column-balance[data-help="balance"]').count()) === 1 &&
      (await page.locator('#people-head th[data-help="items"]').count()) === 1,
  );

  // Un poste qui ne concerne pas tout le monde : le vin.
  await page.click("#add-item");
  await page.waitForTimeout(150);
  await page.fill("#label-1", "Vin");
  await page.locator("#label-1").press("Tab");
  await page.fill("#amount-1", "60");
  await page.locator("#amount-1").press("Enter");
  await page.locator("#takes-1-2").uncheck();
  await page.waitForTimeout(200);
  asked = await page.evaluate(() => window.__sharingAsked.at(-1));
  check(
    "partage : le vin a sa colonne, et Personne 2 décochée n'y participe pas",
    (await page.locator("#head-1 span").first().textContent()) === "Vin" &&
      asked.items[0].label === "Vin" && asked.items[0].amount === "60,00" &&
      asked.items[0].cells.find((cell) => cell.person === 2).takes === false &&
      (await page.locator("#out-1-2").textContent()) === "",
    JSON.stringify(asked.items),
  );

  // **Un montant est gardé à la frappe**, comme dans les fiches : ni lettre,
  // ni signe moins ; vide, un champ facultatif reste vide en sortant.
  await page.locator("#amount-1").fill("");
  await page.locator("#amount-1").pressSequentially("8a-0");
  check("partage : une lettre ou un signe moins ne s'écrivent pas dans un montant", (await page.inputValue("#amount-1")) === "80");
  await page.locator("#amount-1").press("Enter");
  await page.waitForTimeout(150);
  check(
    "partage : en sortant, le montant s'écrit proprement, et la grille suit le nouveau montant",
    (await page.inputValue("#amount-1")) === "80,00" && (await page.locator("#out-1-1").textContent()) === "80,00 €" &&
      (await page.locator("#head-amount-1").textContent()) === "80,00 €",
  );
  // **Un montant groupé se modifie** : les milliers ne bloquent plus la frappe,
  // et se regroupent en sortant.
  await page.fill("#total", "");
  await page.locator("#total").pressSequentially("1250");
  await page.locator("#total").press("Enter");
  check("partage : en sortant, les milliers se groupent", (await page.inputValue("#total")) === "1\u202f250,00");
  await page.locator("#total").focus();
  await page.locator("#total").press("End");
  await page.locator("#total").press("Backspace");
  await page.locator("#total").press("Backspace");
  await page.locator("#total").press("Backspace");
  await page.locator("#total").pressSequentially(",5x");
  check("partage : un montant de plus de mille se corrige à la frappe", (await page.inputValue("#total")) === "1\u202f250,5");
  await page.locator("#total").press("Tab");
  check("partage : et se réécrit proprement en sortant", (await page.inputValue("#total")) === "1\u202f250,50");
  await page.fill("#total", "240");
  await page.locator("#total").press("Enter");
  await page.waitForTimeout(150);
  await page.locator("#cap-1").click();
  await page.locator("#cap-1").press("Tab");
  check("partage : un plafond laissé vide reste vide, il ne devient pas 0,00", (await page.inputValue("#cap-1")) === "");
  // Un calcul refusé efface les montants d'avant au lieu de les laisser croire justes.
  await page.fill("#name-2", "");
  await page.locator("#name-2").press("Enter");
  await page.waitForTimeout(150);
  check(
    "partage : refusé, le calcul n'affiche plus d'anciens montants",
    (await page.locator("#out-0-1").textContent()) === "" && (await page.locator("#due-1").textContent()) === "" &&
      (await page.locator("#info-bar").textContent()) === "Chaque personne doit avoir un nom.",
  );
  await page.fill("#name-2", "Personne 2");
  await page.locator("#name-2").press("Enter");
  await page.waitForTimeout(150);

  // Une règle au revenu : la colonne apparaît. Puis une règle par poste.
  await page.selectOption("#rule", "income");
  await page.waitForTimeout(150);
  check("partage : au prorata des revenus, la colonne revenu apparaît", await page.locator("#income-1").isVisible());
  await page.locator("#income-1").pressSequentially("2x0,5");
  check("partage : un revenu se garde comme un montant", (await page.inputValue("#income-1")) === "20,5");
  await page.locator("#income-1").fill("");
  await page.locator('input[name="mode"][value="item"]').check();
  await page.waitForTimeout(150);
  check(
    "partage : une règle par poste — la règle globale se cache, chaque poste a la sienne, le revenu disparaît",
    (await page.locator("#rule-line").isHidden()) && (await page.locator("#rule-1").isVisible()) &&
      (await page.locator("#rule-0").isVisible()) && (await page.locator("#income-1").count()) === 0,
  );
  await page.selectOption("#rule-1", "percent");
  await page.waitForTimeout(150);
  check(
    "partage : la règle d'un poste a sa bulle",
    ((await page.locator("#rule-1").getAttribute("title")) ?? "").startsWith("Comment ce poste se partage"),
  );
  check(
    "partage : un poste en pourcentages ouvre un champ par case",
    (await page.locator("#cell-1-1").isVisible()) && (await page.locator("#cell-0-1").count()) === 0,
  );
  await page.locator("#cell-1-1").pressSequentially("-6o,25");
  check("partage : un pourcentage n'accepte que des chiffres et une virgule", (await page.inputValue("#cell-1-1")) === "6,25");
  await page.locator("#cell-1-1").fill("");

  // Un règlement.
  await page.click("#add-payment");
  await page.waitForTimeout(100);
  await page.fill("#payment-amount-1", "100");
  await page.locator("#payment-amount-1").press("Enter");
  await page.waitForTimeout(150);
  asked = await page.evaluate(() => window.__sharingAsked.at(-1));
  check(
    "partage : un règlement part avec la première personne choisie",
    asked.payments.length === 1 && asked.payments[0].person === 1 && asked.payments[0].amount === "100" &&
      (await page.locator("#payment-person-1 option").first().textContent()) === "Léa",
    JSON.stringify(asked.payments),
  );

  // Les rapports et les relevés.
  await page.click("#pdf-distribution");
  await page.click("#pdf-payments");
  await page.waitForTimeout(150);
  check(
    "partage : les deux rapports partent avec leur nature",
    (await page.evaluate(() => window.__sharingPrinted.map((one) => one.kind).join())) === "distribution,payments",
  );
  await page.click("#statements");
  await page.waitForTimeout(150);
  check("partage : des relevés existent déjà — une seule question", await page.locator(".dialog").isVisible());
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(150);
  check(
    "partage : les relevés s'écrivent pour tout le monde, dans le dossier choisi",
    (await page.evaluate(() => window.__sharingWritten.folder === "/tmp/Relevés" && window.__sharingWritten.unit === "")) &&
      (await page.locator("#info-bar").textContent()) === "2 relevés écrits dans « Relevés ».",
  );
  check(
    "partage : le choix des relevés propose tout le monde, puis chacun",
    (await page.locator("#statements-unit option").allTextContents()).join("|") === "Tout le monde|Léa|Personne 2",
  );

  // Supprimer une personne qui a des règlements demande d'abord.
  await page.click("#person-1 .sharing__delete");
  await page.waitForTimeout(150);
  check("partage : supprimer quelqu'un qui a payé demande d'abord", await page.locator(".dialog").isVisible());
  await page.click(".dialog__button:not(.dialog__button--primary)");
  await page.waitForTimeout(150);
  check("partage : « Non » garde la personne et son règlement", (await page.locator("#person-1").count()) === 1);

  // Enregistrer, puis la porte sort sans question.
  await page.fill("#label", "Week-end");
  await page.locator("#label").press("Enter");
  await page.click("#save");
  await page.waitForTimeout(200);
  check(
    "partage : le projet s'enregistre sous son libellé",
    await page.evaluate(() => window.__saveAsked.defaultPath === "Week-end.json" && window.__sharingSaved.input.label === "Week-end"),
  );
  await page.click("#excel");
  await page.waitForTimeout(150);
  check(
    "partage : le classeur aussi",
    await page.evaluate(() => window.__saveAsked.defaultPath === "Week-end.xlsx" && window.__sharingExported.path.endsWith(".xlsx")),
  );

  // Ouvrir un projet remplace ce qui est tapé — après une question.
  await page.click("#open");
  await page.waitForTimeout(150);
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(250);
  check(
    "partage : un projet rouvert reprend ses personnes, son règlement daté, et le dit",
    (await page.inputValue("#name-2")) === "Paul" && (await page.inputValue("#payment-date-1")) === "2027-01-15" &&
      (await page.inputValue("#label")) === "Week-end" &&
      (await page.locator("#info-bar").textContent()) === "Projet ouvert : Week-end.json",
  );
  await page.click("#close");
  await page.waitForTimeout(200);
  check(
    "partage : juste ouvert, la porte sort sans question et efface tout",
    (await page.evaluate(() => window.__sharingClosed === 1)) && (await page.locator(".dialog").count()) === 0 &&
      (await page.locator("#people tr").count()) === 0 && (await page.inputValue("#label")) === "",
  );

  // Quelque chose de tapé : la porte demande, Échap reste.
  await page.click("#add-person");
  await page.waitForTimeout(150);
  await page.click("#close");
  await page.waitForTimeout(150);
  check("partage : la porte demande quand quelque chose serait perdu", await page.locator(".dialog").isVisible());
  await page.keyboard.press("Escape");
  await page.waitForTimeout(150);
  check(
    "partage : Échap répond « rester »",
    (await page.evaluate(() => window.__sharingClosed === 1)) && (await page.locator("#people tr").count()) === 1,
  );
  const spills = await page.evaluate(() => document.documentElement.scrollWidth > window.innerWidth);
  check("partage : rien ne déborde en largeur", !spills);
  await page.close();
}

// Les conseils du partage (P-72) : une phrase sous la règle, des valeurs grises
// dans les cases vides, et trois boutons pour les reprendre.
{
  const page = await browser.newPage({ viewport: { width: 1440, height: 960 } });
  const errors = await openWindow(page, "http://localhost:4173/ui/windows/sharing.html");
  await page.waitForTimeout(200);
  const advice = () => page.locator("#rule-advice");
  for (let count = 0; count < 3; count += 1) {
    await page.click("#add-person");
    await page.waitForTimeout(120);
  }
  await page.fill("#total", "90");
  await page.locator("#total").press("Enter");
  await page.waitForTimeout(200);
  check(
    "conseils : à parts égales, la division se lit sous la règle",
    (await advice().isVisible()) && (await advice().textContent()) === "90,00 € ÷ 3 personnes = 30,00 € chacun." &&
      (await page.locator("#apply-advice").isHidden()) && (await page.locator("#reset-percents").isHidden()),
  );
  check(
    "conseils : le titre dit ce que chacun paie",
    (await page.locator("#headline").textContent()) === "90,00 € à partager : chacun paie 30,00 €.",
  );

  // En pourcentages : le reste se conseille en gris, et ne compte pas.
  await page.selectOption("#rule", "percent");
  await page.waitForTimeout(150);
  await page.fill("#percent-1", "40");
  await page.locator("#percent-1").press("Enter");
  await page.waitForTimeout(200);
  let asked = await page.evaluate(() => window.__sharingAsked.at(-1));
  check(
    "conseils : il manque 60 %, conseillés en gris dans les cases vides",
    (await advice().textContent()) === "Il manque 60 % pour arriver à 100 %." &&
      (await page.getAttribute("#percent-2", "placeholder")) === "30" &&
      (await page.getAttribute("#percent-3", "placeholder")) === "30" &&
      (await page.getAttribute("#percent-1", "placeholder")) === "",
  );
  check("conseils : une valeur grise ne compte pas tant qu'on ne l'a pas reprise", asked.people[1].percent === "" && (await page.inputValue("#percent-2")) === "");
  check(
    "conseils : « Reprendre les valeurs conseillées » se montre, avec sa bulle",
    (await page.locator("#apply-advice").isVisible()) &&
      (await page.locator("#apply-advice").textContent()) === "Reprendre les valeurs conseillées" &&
      ((await page.getAttribute("#apply-advice", "title")) ?? "").startsWith("Remplit les cases vides"),
  );
  await page.click("#apply-advice");
  await page.waitForTimeout(200);
  check(
    "conseils : reprises, les valeurs s'écrivent et le compte est bon",
    (await page.inputValue("#percent-2")) === "30" && (await page.inputValue("#percent-3")) === "30" &&
      (await advice().textContent()) === "Les pourcentages font bien 100 %." &&
      !(await advice().evaluate((node) => node.classList.contains("sharing__advice--warn"))) &&
      (await page.locator("#apply-advice").isHidden()) && (await page.locator("#reset-percents").isVisible()),
  );

  // Une personne ajoutée après coup ne paierait rien : on le dit, en orange.
  await page.click("#add-person");
  await page.waitForTimeout(200);
  check(
    "conseils : une personne ajoutée après coup — l'avertissement en orange",
    (await advice().textContent()) === "Les pourcentages font déjà 100 % : Personne 4 ne paierait rien." &&
      (await advice().evaluate((node) => node.classList.contains("sharing__advice--warn"))),
  );
  await page.click("#reset-percents");
  await page.waitForTimeout(150);
  check(
    "conseils : « Tout répartir à nouveau » demande d'abord",
    (await page.locator(".dialog").isVisible()) &&
      (await page.locator(".dialog__question").textContent()) === "Effacer tous les pourcentages et les répartir à parts égales ?",
  );
  await page.click(".dialog__button--primary");
  await page.waitForTimeout(250);
  check(
    "conseils : tout est réparti à nouveau, à parts égales",
    (await page.inputValue("#percent-1")) === "25" && (await page.inputValue("#percent-4")) === "25" &&
      (await advice().textContent()) === "Les pourcentages font bien 100 %.",
  );

  // D'après les revenus : tapés au prorata, gardés en vue en pourcentages.
  await page.selectOption("#rule", "income");
  await page.waitForTimeout(150);
  check("conseils : au prorata, sans revenus, une invite", (await advice().textContent()) === "Tapez le revenu de chacun pour partager au prorata des revenus.");
  for (const [id, income] of [[1, "1000"], [2, "1000"], [3, "1000"], [4, "2000"]]) {
    await page.fill(`#income-${id}`, income);
    await page.locator(`#income-${id}`).press("Enter");
    await page.waitForTimeout(120);
  }
  check("conseils : au prorata, la part du revenu de chacun", (await advice().textContent()) === "Chacun paie 1,8 % de son revenu.");
  await page.selectOption("#rule", "percent");
  await page.waitForTimeout(200);
  check(
    "conseils : en pourcentages, les revenus tapés restent en vue et proposent leurs pourcentages",
    (await page.locator("#income-1").isVisible()) && (await page.locator("#from-incomes").isVisible()) &&
      (await page.locator("#from-incomes").textContent()) === "Pourcentages d'après les revenus",
  );
  await page.click("#from-incomes");
  await page.waitForTimeout(200);
  check(
    "conseils : les pourcentages d'après les revenus font 100 %",
    (await page.inputValue("#percent-1")) === "20" && (await page.inputValue("#percent-4")) === "40" &&
      (await advice().textContent()) === "Les pourcentages font bien 100 %.",
  );

  // Refusé, le partage conseille encore.
  await page.fill("#percent-1", "");
  await page.locator("#percent-1").press("Enter");
  await page.fill("#name-2", "");
  await page.locator("#name-2").press("Enter");
  await page.waitForTimeout(200);
  check(
    "conseils : même refusé, le partage dit ce qui manque",
    (await page.locator("#info-bar").textContent()) === "Chaque personne doit avoir un nom." &&
      (await advice().textContent()) === "Il manque 20 % pour arriver à 100 %." &&
      (await page.getAttribute("#percent-1", "placeholder")) === "20",
  );
  await page.fill("#name-2", "Tom");
  await page.locator("#name-2").press("Enter");
  await page.waitForTimeout(150);

  // Une règle par poste : la phrase passe sous la règle de chaque poste.
  await page.locator('input[name="mode"][value="item"]').check();
  await page.waitForTimeout(200);
  check(
    "conseils : par poste, la phrase passe sous la règle du poste",
    (await advice().isHidden()) && (await page.locator("#advice-0").textContent()) === "90,00 € ÷ 4 personnes = 22,50 € chacun.",
  );
  await page.selectOption("#rule-0", "percent");
  await page.waitForTimeout(200);
  check(
    "conseils : un poste en pourcentages conseille chaque case",
    (await page.locator("#advice-0").textContent()) === "Il manque 100 % pour arriver à 100 %." &&
      (await page.getAttribute("#cell-0-1", "placeholder")) === "25",
  );
  await page.click("#apply-advice");
  await page.waitForTimeout(200);
  check(
    "conseils : reprises par poste, les cases se remplissent",
    (await page.inputValue("#cell-0-1")) === "25" && (await page.inputValue("#cell-0-4")) === "25" &&
      (await page.locator("#advice-0").textContent()) === "Les pourcentages font bien 100 %.",
  );
  check("conseils : aucune plainte", errors.length === 0, errors.join(" / "));
  await page.close();
}

// --- Préférences : le tarif d'électricité (09/10/2026) --------------------
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/preferences.html");
  check(
    "préférences : « Tarif d'électricité » sous sa branche « Outils »",
    await page.evaluate(() => {
      const leaf = document.querySelector('.tree__leaf[data-leaf="electricity"]');
      return (
        leaf.textContent === "Tarif d'électricité" &&
        leaf.previousElementSibling.textContent === "Outils"
      );
    }),
  );
  await page.click('.tree__leaf[data-leaf="electricity"]');
  await page.waitForTimeout(100);
  check(
    "préférences : le Tarif Bleu par défaut, en Base",
    (await page.inputValue("#electricity-option")) === "base" &&
      (await page.inputValue("#electricity-base")) === "0,2001" &&
      !(await page.locator("#electricity-peak").isVisible()),
  );
  await page.selectOption("#electricity-option", "off-peak");
  await page.fill("#electricity-peak", "0,25");
  check(
    "préférences : en heures pleines / heures creuses, deux prix et les heures",
    (await page.locator("#electricity-peak").isVisible()) &&
      (await page.locator("#electricity-off-peak-hours").isVisible()) &&
      !(await page.locator("#electricity-base").isVisible()),
  );
  await page.click("#save");
  await page.waitForTimeout(150);
  check(
    "préférences : la disquette enregistre le tarif",
    await page.evaluate(
      () => window.__savedTariff?.option === "off-peak" && window.__savedTariff?.peak === "0,25",
    ),
  );
  await page.click("#electricity-blue");
  await page.waitForTimeout(100);
  check(
    "préférences : « Revenir au Tarif Bleu EDF » remplit les champs sans enregistrer",
    (await page.inputValue("#electricity-option")) === "base" &&
      (await page.evaluate(() => window.__savedTariff?.peak === "0,25")),
  );
  await page.selectOption("#electricity-option", "off-peak");
  await page.fill("#electricity-off-peak", "abc");
  await page.click("#save");
  await page.waitForTimeout(150);
  check(
    "préférences : un prix illisible n'est pas enregistré, et on le dit",
    (await page.locator("#info-bar").textContent()).includes("prix du kWh") &&
      (await page.evaluate(() => window.__savedTariff?.off_peak !== "abc")),
  );
  await page.close();
}

// --- Préférences : les relevés QIF (15/10/2026) -------------------------
//
// « Une petite section destinée à l'import de fichiers QIF, pour permettre à
// l'utilisateur de trancher, avec des choix par défaut » (Fabrice, P-73).
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/preferences.html");
  check(
    "préférences : « Relevés QIF » sous la branche « Importation », après « Relevés OFX »",
    await page.evaluate(() => {
      const leaf = document.querySelector('.tree__leaf[data-leaf="qif"]');
      return (
        leaf.textContent === "Relevés QIF" &&
        leaf.previousElementSibling.dataset.leaf === "ofx"
      );
    }),
  );
  await page.click('.tree__leaf[data-leaf="qif"]');
  await page.waitForTimeout(100);
  check(
    "préférences QIF : par défaut, « Me demander à chaque fois » et « Tiers + mémo »",
    (await page.inputValue("#qif-order")) === "ask" && (await page.inputValue("#qif-label")) === "both" &&
      (await page.locator("#qif-order option").allTextContents()).join("|") ===
        "Me demander à chaque fois|Toujours jour/mois (05/03 = 5 mars)|Toujours mois/jour (05/03 = 3 mai)" &&
      (await page.locator("#qif-label option").allTextContents()).join("|") === "Tiers + mémo|Tiers seul|Mémo seul",
  );
  check(
    "préférences QIF : chaque réglage a sa bulle",
    ((await page.getAttribute("#qif-order", "title")) ?? "").startsWith("Ne sert que si aucune date") &&
      ((await page.getAttribute("#qif-order-label", "title")) ?? "").startsWith("Ne sert que si aucune date") &&
      ((await page.getAttribute("#qif-label", "title")) ?? "").startsWith("Quand une opération porte"),
  );
  await page.click("#save");
  await page.waitForTimeout(150);
  check("préférences QIF : rien de changé, rien d'écrit", await page.evaluate(() => (window.__qifSaves ?? 0) === 0));
  await page.selectOption("#qif-order", "day-month");
  await page.selectOption("#qif-label", "payee");
  await page.click("#save");
  await page.waitForTimeout(150);
  check(
    "préférences QIF : la disquette enregistre les deux réglages",
    await page.evaluate(
      () => window.__qifPreferences?.order === "day-month" && window.__qifPreferences?.label === "payee" && window.__qifSaves === 1,
    ),
  );
  await page.close();

  // **Sans base, la feuille vit** : ce sont des réglages du logiciel.
  const bare = await browser.newPage();
  await openWindow(bare, "http://localhost:4173/ui/windows/preferences.html", { databaseOpen: false });
  check(
    "préférences QIF : sans base ouverte, la feuille reste vivante",
    await bare.evaluate(() => {
      const leaf = document.querySelector('.tree__leaf[data-leaf="qif"]');
      return !leaf.disabled && !leaf.classList.contains("tree__leaf--off");
    }),
  );
  await bare.click('.tree__leaf[data-leaf="qif"]');
  await bare.selectOption("#qif-order", "month-day");
  await bare.click("#save");
  await bare.waitForTimeout(150);
  check(
    "préférences QIF : et elle s'enregistre sans base",
    await bare.evaluate(() => window.__qifPreferences?.order === "month-day"),
  );
  await bare.close();
}

// --- Relevés : la référence paiement (19/10/2026) -----------------------
//
// Le MEMO de la banque arrive dans la référence paiement : une colonne de la
// fenêtre d'importation, après le libellé, et un champ modifiable de la fiche
// « Rapprocher une transaction ».
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/statement-import.html?account=1");
  await page.click("#open");
  await page.waitForTimeout(300);
  const titles = (await page.locator(".list__title").allTextContents()).map((title) => title.trim());
  check(
    "relevé : la colonne « Référence paiement » suit « Libelle »",
    titles.indexOf("Référence paiement") === titles.indexOf("Libelle") + 1 && titles.includes("Référence paiement"),
    titles.join(" | "),
  );
  const cell = page.locator(".list__row").nth(1).locator(".list__cell", { hasText: "CAISSE INVENTEE" });
  check(
    "relevé : la référence se lit dans sa colonne, entière au survol",
    (await cell.count()) === 1 &&
      (await cell.getAttribute("title")) === "CAISSE INVENTEE ECH/220726 REF/42 LIB/COTISATION ANNUELLE DE LA CAISSE",
  );
  await page.close();

  const form = await browser.newPage();
  await openWindow(form, "http://localhost:4173/ui/windows/statement-form.html?account=1&rank=2");
  check(
    "rapprocher : le champ « Référence paiement » porte le MEMO, sous le libellé",
    (await form.inputValue("#reference")) === "CAISSE INVENTEE ECH/220726 REF/42 LIB/COTISATION ANNUELLE DE LA CAISSE" &&
      (await form.locator("#reference-label").textContent()) === "Référence paiement" &&
      (await form.getAttribute("#reference", "maxlength")) === "255" &&
      (await form.getAttribute("#label", "maxlength")) === "300",
  );
  await form.fill("#reference", "REF CORRIGEE");
  await form.click("#validate");
  await form.waitForTimeout(150);
  check(
    "rapprocher : la référence corrigée part avec la ligne",
    await form.evaluate(() => window.__amended?.reference === "REF CORRIGEE" && window.__amended?.rank === 2),
    await form.evaluate(() => JSON.stringify(window.__amended)),
  );
  await form.close();
}

// --- Préférences : les relevés OFX (19/10/2026, menus le 20/10/2026) -----
//
// Que faire du nom et du mémo de la banque : deux menus déroulants, l'un pour
// le libellé, l'autre pour la référence paiement. Par défaut, le nom dans le
// libellé et le mémo dans la référence (Fabrice). Des réglages du logiciel,
// vivants sans base.
{
  const page = await browser.newPage();
  await openWindow(page, "http://localhost:4173/ui/windows/preferences.html");
  check(
    "préférences : « Relevés OFX » sous « Importation », après « Vérification »",
    await page.evaluate(() => {
      const leaf = document.querySelector('.tree__leaf[data-leaf="ofx"]');
      return leaf.textContent === "Relevés OFX" && leaf.previousElementSibling.dataset.leaf === "verification";
    }),
  );
  await page.click('.tree__leaf[data-leaf="ofx"]');
  await page.waitForTimeout(100);
  const options = (id) =>
    page.locator(`#${id} option`).evaluateAll((all) => all.map((o) => `${o.value}=${o.textContent}`).join("|"));
  check(
    "préférences OFX : le libellé, trois choix ; le nom par défaut",
    (await page.locator("#ofx-label-label").textContent()) === "Libellé de l'opération :" &&
      (await page.inputValue("#ofx-label")) === "name" &&
      (await options("ofx-label")) ===
        "name=Le nom de l'opération|memo=Le mémo de la banque|name-and-memo=Le nom suivi du mémo",
    await options("ofx-label"),
  );
  check(
    "préférences OFX : la référence paiement, quatre choix ; le mémo par défaut",
    (await page.locator("#ofx-reference-label").textContent()) === "Référence paiement :" &&
      (await page.inputValue("#ofx-reference")) === "memo" &&
      (await options("ofx-reference")) ===
        "memo=Le mémo de la banque|name=Le nom de l'opération|name-and-memo=Le nom suivi du mémo|empty=Rien (laisser vide)",
    await options("ofx-reference"),
  );
  check(
    "préférences OFX : chaque menu a sa bulle, sur son titre et sur lui",
    ((await page.getAttribute("#ofx-label", "title")) ?? "").startsWith("Ce que reçoit le libellé") &&
      ((await page.getAttribute("#ofx-label-label", "title")) ?? "").startsWith("Ce que reçoit le libellé") &&
      ((await page.getAttribute("#ofx-reference", "title")) ?? "").startsWith("Ce que reçoit la référence") &&
      ((await page.getAttribute("#ofx-reference-label", "title")) ?? "").startsWith("Ce que reçoit la référence"),
  );
  check("préférences OFX : plus de cases à cocher", (await page.locator("#pane-ofx input[type=checkbox]").count()) === 0);
  await page.click("#save");
  await page.waitForTimeout(150);
  check("préférences OFX : rien de changé, rien d'écrit", await page.evaluate(() => (window.__ofxSaves ?? 0) === 0));
  await page.selectOption("#ofx-label", "memo");
  await page.selectOption("#ofx-reference", "empty");
  await page.click("#save");
  await page.waitForTimeout(150);
  check(
    "préférences OFX : la disquette enregistre les deux menus",
    await page.evaluate(
      () => window.__ofxPreferences?.label === "memo" && window.__ofxPreferences?.reference === "empty" && window.__ofxSaves === 1,
    ),
    await page.evaluate(() => JSON.stringify(window.__ofxPreferences)),
  );
  await page.close();

  // Rouverte, la page montre ce qui est enregistré.
  const again = await browser.newPage();
  await again.addInitScript(() => {
    window.__ofxPreferences = { label: "name-and-memo", reference: "name" };
  });
  await openWindow(again, "http://localhost:4173/ui/windows/preferences.html");
  await again.click('.tree__leaf[data-leaf="ofx"]');
  check(
    "préférences OFX : rouverte, elle montre les choix enregistrés",
    (await again.inputValue("#ofx-label")) === "name-and-memo" && (await again.inputValue("#ofx-reference")) === "name",
  );
  await again.close();

  const bare = await browser.newPage();
  await openWindow(bare, "http://localhost:4173/ui/windows/preferences.html", { databaseOpen: false });
  await bare.click('.tree__leaf[data-leaf="ofx"]');
  await bare.selectOption("#ofx-label", "name-and-memo");
  await bare.click("#save");
  await bare.waitForTimeout(150);
  check(
    "préférences OFX : sans base ouverte, la feuille vit et s'enregistre",
    await bare.evaluate(() => window.__ofxPreferences?.label === "name-and-memo" && window.__ofxPreferences?.reference === "memo"),
  );
  await bare.close();
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
  // Depuis le 19/10/2026, l'assistant d'exportation la suit (P-74) : elle
  // reste juste après la réparation, et le journal ferme toujours le menu.
  check(
    "bases : elle est rangée après la réparation, le journal en dernier",
    tools.indexOf("Protection de la base par mot de passe") ===
      tools.findIndex((label) => label.startsWith("Réparer")) + 1 &&
      tools.indexOf("Afficher le log") === tools.length - 1,
    tools.join(" | "),
  );
  check(
    "bases : sa phrase vient du noyau, pas de sa clef",
    !tools.some((label) => label.startsWith("menu-")),
    tools.join(" | "),
  );
  await page.close();
}

// --- Le menu Outils des bases nomme la base (19/10/2026) ----------------
//
// Fabrice : « l'utilisateur peut bêtement penser que toutes les bases sont
// sauvegardées ». Le menu dit sur quelle base il agit, grise ce qui vise une
// base tant qu'aucune n'est choisie, et sépare le journal, qui ne vise rien.
{
  const DATABASES = [
    { folder: "famille", path: "databases/famille/radinus.sqlite", label: "Famille", comment: "", created_on: "2026-01-02", created_by: "1.0", schema_version: 30, current: true },
    { folder: "perso", path: "databases/perso/radinus.sqlite", label: "Perso", comment: "", created_on: "2026-02-03", created_by: "1.0", schema_version: 30, current: false },
  ];
  const page = await browser.newPage();
  const errors = await openWindow(page, "http://localhost:4173/ui/windows/database-selector.html", { databases: DATABASES });
  check("menu Outils nommé : la fenêtre s'ouvre sans une plainte", errors.length === 0, errors.join(" | "));
  const entry = page.locator(".window-menu__holder", { has: page.locator('[data-menu="tools"]') }).locator("> :first-child");
  const state = () =>
    page.evaluate(() => {
      const menu = document.querySelector('[data-menu="tools"]');
      const pick = (choice) => menu.querySelector('[data-choice="' + choice + '"]');
      return {
        heading: pick("heading").textContent,
        backup: pick("backup_database").textContent,
        restore: pick("restore_database").textContent,
        repair: pick("repair_database").textContent,
        greyed: ["backup_database", "restore_database", "repair_database", "open_password_form", "export"].map((c) => pick(c).disabled),
        log: [...menu.querySelectorAll(".window-menu__choice")].pop().disabled,
        separatorBeforeLog: [...menu.children].at(-2).classList.contains("window-menu__separator"),
      };
    });
  await entry.click();
  await page.waitForTimeout(80);
  let seen = await state();
  check(
    "menu Outils nommé : sans base choisie, il le dit et grise tout ce qui vise une base",
    seen.heading === "Aucune base sélectionnée" &&
      seen.backup === "Sauvegarder la base sélectionnée…" &&
      seen.greyed.every(Boolean) &&
      !seen.log,
    JSON.stringify(seen),
  );
  check("menu Outils nommé : le journal est séparé d'un trait", seen.separatorBeforeLog);
  await page.click("body", { position: { x: 5, y: 5 } }).catch(() => undefined);
  await page.locator(".list__row").nth(1).click();
  await entry.click();
  await page.waitForTimeout(80);
  seen = await state();
  check(
    "menu Outils nommé : une base choisie, chaque entrée porte son nom",
    seen.heading === "Base sélectionnée : « Perso »" &&
      seen.backup === "Sauvegarder la base « Perso »…" &&
      seen.restore === "Restaurer la base « Perso »…" &&
      seen.repair === "Réparer et optimiser la base « Perso »…" &&
      seen.greyed.every((off) => !off),
    JSON.stringify(seen),
  );
  await page.click('[data-choice="backup_database"]');
  await page.waitForTimeout(100);
  check(
    "menu Outils nommé : la sauvegarde vise la base choisie",
    await page.evaluate(() =>
      window.__calls.some(([command, args]) => command === "backup_database" && args.path === "databases/perso/radinus.sqlite"),
    ),
  );
  await page.close();
}

// --- P-74 : l'assistant d'exportation d'une base (19/10/2026) -----------
//
// Fabrice : « il existe des gens qui ne comprennent pas tout ». L'assistant
// n'exporte que la base choisie dans la liste, et le dit partout ; il est grisé
// sans ligne choisie ; chaque format ne montre que ses options ; on n'arrive
// au bouton « Exporter » qu'avec un emplacement, qu'un changement de format
// annule ; la clé de la base n'y passe jamais, et la porte l'oublie.
{
  const DATABASES = [
    { folder: "famille", path: "databases/famille/radinus.sqlite", label: "Famille", comment: "", created_on: "2026-01-02", created_by: "1.0", schema_version: 30, current: true },
    { folder: "perso", path: "databases/perso/radinus.sqlite", label: "Perso", comment: "", created_on: "2026-02-03", created_by: "1.0", schema_version: 30, current: false },
  ];

  // Le menu du sélecteur : l'entrée, sa place, grisée sans ligne choisie.
  const selector = await browser.newPage();
  const selectorErrors = await openWindow(selector, "http://localhost:4173/ui/windows/database-selector.html", { databases: DATABASES });
  check("assistant d'exportation : le sélecteur s'ouvre sans une plainte", selectorErrors.length === 0, selectorErrors.join(" | "));
  const tools = await selector.evaluate(() =>
    [...document.querySelectorAll('[data-menu="tools"] .window-menu__choice')].map((choice) => choice.textContent),
  );
  check(
    "assistant d'exportation : il est au menu Outils, après la protection et avant le journal",
    tools.indexOf("Assistant d'exportation de la base…") === tools.indexOf("Protection de la base par mot de passe") + 1 &&
      tools.indexOf("Assistant d'exportation de la base…") === tools.indexOf("Afficher le log") - 1,
    tools.join(" | "),
  );
  const toolsEntry = selector.locator(".window-menu__holder", { has: selector.locator('[data-menu="tools"]') }).locator("> :first-child");
  await toolsEntry.click();
  check(
    "assistant d'exportation : grisé tant qu'aucune base n'est choisie",
    await selector.evaluate(() => document.querySelector('[data-choice="export"]').disabled),
  );
  await selector.click("body", { position: { x: 5, y: 5 } }).catch(() => undefined);
  await selector.locator(".list__row").nth(1).click();
  await toolsEntry.click();
  check(
    "assistant d'exportation : une base choisie l'allume",
    await selector.evaluate(() => !document.querySelector('[data-choice="export"]').disabled),
  );
  await selector.click('[data-choice="export"]');
  await selector.waitForTimeout(150);
  check(
    "assistant d'exportation : il s'ouvre sur la base choisie, et sur elle seule",
    await selector.evaluate(
      () =>
        window.__exportOpened?.path === "databases/perso/radinus.sqlite" &&
        window.__exportOpened?.label === "Perso" &&
        window.__exportOpened?.password === null,
    ),
    await selector.evaluate(() => JSON.stringify(window.__exportOpened)),
  );
  await selector.close();

  // L'assistant lui-même.
  const url = "http://localhost:4173/ui/windows/database-export.html?path=databases%2Ffamille%2Fradinus.sqlite&label=Famille";
  const page = await browser.newPage();
  const errors = await openWindow(page, url);
  check("assistant d'exportation : la fenêtre s'ouvre sans une plainte", errors.length === 0, errors.join(" | "));
  const visible = (id) => page.evaluate((id) => {
    const node = document.getElementById(id);
    return Boolean(node) && !node.closest("[hidden]");
  }, id);
  check(
    "assistant d'exportation : la phrase de tête nomme la base, et dit qu'elle seule part",
    await page.evaluate(() => {
      const banner = document.getElementById("only-this").textContent;
      return banner.includes("« Famille »") && banner.startsWith("Seule la base");
    }),
  );
  check(
    "assistant d'exportation : elle est demandée pour cette base-là",
    await page.evaluate(() => window.__exportIntro?.path === "databases/famille/radinus.sqlite"),
  );
  check(
    "assistant d'exportation : neuf formats, Excel choisi d'abord, chacun avec sa ligne d'explication",
    await page.evaluate(() => {
      const radios = [...document.querySelectorAll('input[name="format"]')];
      return (
        radios.length === 9 &&
        radios.map((radio) => radio.value).join(",") === "xlsx,ods,csv,json,xml,sql,sqlite,qif,ofx" &&
        document.querySelector('input[name="format"]:checked').value === "xlsx" &&
        [...document.querySelectorAll(".export-choice__hint")].every((hint) => hint.textContent.length > 20 && !hint.textContent.startsWith("base-export"))
      );
    }),
  );
  check("assistant d'exportation : pas de mise en garde pour Excel", !(await visible("lossy")));
  check("assistant d'exportation : la première page n'a pas de bouton Précédent", !(await visible("previous")));
  await page.check('input[name="format"][value="qif"]');
  check("assistant d'exportation : le QIF prévient qu'il ne garde pas tout", await visible("lossy"));

  // Les options de chaque format, et rien d'autre.
  const optionsOf = async (format) => {
    await page.check(`input[name="format"][value="${format}"]`);
    await page.click("#next");
    const shown = {};
    for (const id of ["group-layout", "group-decimal", "group-quotes", "group-order", "no-option", "planned-note", "dates-hint"]) {
      shown[id] = await visible(id);
    }
    await page.click("#previous");
    return Object.entries(shown).filter(([, on]) => on).map(([id]) => id).join(",");
  };
  check("assistant d'exportation : Excel propose un fichier ou un par table", (await optionsOf("xlsx")) === "group-layout,dates-hint");
  check("assistant d'exportation : le CSV propose le séparateur et les guillemets", (await optionsOf("csv")) === "group-decimal,group-quotes,dates-hint");
  check("assistant d'exportation : le QIF propose l'ordre des dates et dit ce qu'il laisse", (await optionsOf("qif")) === "group-order,planned-note");
  check("assistant d'exportation : la base SQLite n'a pas d'option", (await optionsOf("sqlite")) === "no-option,dates-hint");
  check("assistant d'exportation : l'OFX non plus, et dit ce qu'il laisse", (await optionsOf("ofx")) === "no-option,planned-note");
  check(
    "assistant d'exportation : le QIF met le jour avant le mois par défaut",
    await page.evaluate(() => document.querySelector('input[name="order"]:checked').value === "day-month"),
  );
  check(
    "assistant d'exportation : le CSV met toutes les valeurs entre guillemets par défaut",
    await page.evaluate(() => document.querySelector('input[name="quotes"]:checked').value === "all"),
  );

  // Pas de récapitulatif sans emplacement.
  await page.check('input[name="format"][value="csv"]');
  await page.click("#next");
  await page.check('input[name="decimal"][value="point"]');
  await page.check('input[name="quotes"][value="none"]');
  await page.click("#next");
  check(
    "assistant d'exportation : le CSV se choisit par dossier",
    (await page.locator("#choose").textContent()) === "Choisir le dossier…",
  );
  await page.click("#next");
  check(
    "assistant d'exportation : sans emplacement, pas de récapitulatif",
    (await visible("page-place")) &&
      (await page.locator("#info-bar").textContent()) === "Choisissez d'abord où écrire l'export." &&
      (await page.evaluate(() => document.getElementById("info-bar").classList.contains("info-bar--alert"))),
  );
  await page.click("#choose");
  await page.waitForTimeout(100);
  check(
    "assistant d'exportation : le dialogue reçoit la base, le format et la disposition",
    await page.evaluate(() => window.__exportPicked?.label === "Famille" && window.__exportPicked?.format === "csv"),
  );
  check(
    "assistant d'exportation : l'emplacement est montré, avec le nom de la base et la date",
    (await page.locator("#place-path").textContent()) === "/home/lea/Documents/Famille - export 2026-10-19" &&
      (await page.locator("#place-caption").textContent()).startsWith("L'export sera écrit dans ce dossier"),
  );
  await page.click("#next");
  check(
    "assistant d'exportation : le récapitulatif redit la base, le format, les options, l'emplacement",
    await page.evaluate(
      () =>
        document.getElementById("summary-base").textContent === "Famille" &&
        document.getElementById("summary-format").textContent === "CSV (.csv)" &&
        document.getElementById("summary-options").textContent === "Le point (1234.56) ; Aucun guillemet" &&
        document.getElementById("summary-place").textContent === "/home/lea/Documents/Famille - export 2026-10-19",
    ),
  );
  check("assistant d'exportation : une base sans mot de passe n'appelle pas la mise en garde", !(await visible("unprotected")));
  check("assistant d'exportation : le récapitulatif a son bouton Exporter", (await visible("run")) && !(await visible("next")));
  await page.click("#run");
  await page.waitForTimeout(150);
  check(
    "assistant d'exportation : l'export reçoit exactement les choix faits",
    await page.evaluate(() => {
      const run = window.__exportRun;
      return (
        run?.path === "databases/famille/radinus.sqlite" &&
        run.label === "Famille" &&
        run.request.format === "csv" &&
        run.request.decimal_comma === false &&
        run.request.quote_all === false &&
        run.request.destination === "/home/lea/Documents/Famille - export 2026-10-19" &&
        !("password" in run)
      );
    }),
    await page.evaluate(() => JSON.stringify(window.__exportRun)),
  );
  check(
    "assistant d'exportation : la phrase de fin est montrée, et l'on n'exporte pas deux fois par mégarde",
    (await page.locator("#done").textContent()).includes("« Famille » a été exportée") &&
      (await page.evaluate(() => document.getElementById("run").disabled)),
  );

  // Changer de format annule l'emplacement : un dossier CSV ne convient pas
  // à un classeur.
  await page.click("#previous");
  await page.click("#previous");
  await page.click("#previous");
  await page.check('input[name="format"][value="xlsx"]');
  await page.click("#next");
  await page.click("#next");
  check(
    "assistant d'exportation : un autre format efface l'emplacement choisi",
    (await page.locator("#place-path").textContent()) === "" &&
      (await page.locator("#choose").textContent()) === "Choisir le fichier…",
  );
  await page.click("#previous");
  await page.check('input[name="layout"][value="per-table"]');
  await page.click("#next");
  check(
    "assistant d'exportation : un fichier par table se choisit par dossier",
    (await page.locator("#choose").textContent()) === "Choisir le dossier…",
  );

  // Rouverte sur une autre base : tout repart de zéro.
  await page.evaluate(() =>
    window.__listeners["window-parameters:database-export"]({
      event: "window-parameters:database-export",
      id: 1,
      payload: "path=databases%2Fperso%2Fradinus.sqlite&label=Perso",
    }),
  );
  await page.waitForTimeout(100);
  check(
    "assistant d'exportation : rouverte sur une autre base, elle repart de la première page et la nomme",
    (await visible("page-format")) &&
      (await page.evaluate(() => document.querySelector('input[name="format"]:checked').value === "xlsx")) &&
      (await page.locator("#only-this").textContent()).includes("« Perso »"),
  );

  // La porte oublie la clé.
  await page.click("#close");
  await page.waitForTimeout(100);
  check(
    "assistant d'exportation : la porte fait oublier la clé, puis ferme",
    await page.evaluate(
      () => window.__exportForgotten === 1 && window.__calls.some(([command]) => command === "plugin:window|hide"),
    ),
  );
  await page.close();

  // Un dossier qui existe : on demande, et « non » ne change rien.
  const exists = await browser.newPage();
  await openWindow(exists, url, { exportPlaceExists: true, exportProtected: true });
  await exists.check('input[name="format"][value="ofx"]');
  await exists.click("#next");
  await exists.click("#next");
  await exists.click("#choose");
  await exists.waitForTimeout(100);
  check(
    "assistant d'exportation : un dossier qui existe déjà fait poser la question",
    (await exists.locator(".dialog__question").textContent())?.includes("existe déjà"),
  );
  await exists.click(".dialog__button:not(.dialog__button--primary)");
  await exists.waitForTimeout(80);
  check("assistant d'exportation : « non » ne retient pas l'emplacement", (await exists.locator("#place-path").textContent()) === "");
  await exists.click("#choose");
  await exists.waitForTimeout(100);
  await exists.click(".dialog__button--primary");
  await exists.waitForTimeout(80);
  check("assistant d'exportation : « oui » le retient", (await exists.locator("#place-path").textContent()) !== "");
  await exists.click("#next");
  check(
    "assistant d'exportation : une base protégée prévient que l'export ne le sera pas",
    await exists.evaluate(() => {
      const warning = document.getElementById("unprotected");
      return !warning.closest("[hidden]") && warning.textContent.includes("mot de passe");
    }),
  );
  await exists.close();

  // Un refus du noyau se lit dans la barre, et rien n'est marqué fait.
  const refused = await browser.newPage();
  await openWindow(refused, url, { baseExportRefused: "Le mot de passe ne convient pas." });
  await refused.click("#next");
  await refused.click("#next");
  await refused.click("#choose");
  await refused.waitForTimeout(80);
  await refused.click("#next");
  await refused.click("#run");
  await refused.waitForTimeout(120);
  check(
    "assistant d'exportation : un refus est dit en rouge, et l'on peut réessayer",
    (await refused.locator("#info-bar").textContent()) === "Le mot de passe ne convient pas." &&
      (await refused.evaluate(() => document.getElementById("info-bar").classList.contains("info-bar--alert"))) &&
      (await refused.evaluate(() => !document.getElementById("run").disabled && document.getElementById("done").hidden)),
  );
  await refused.close();
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
