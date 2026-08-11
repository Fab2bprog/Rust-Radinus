# Radinus — core-side messages (Fluent), French.
# Filled in progressively as core modules that produce user-facing messages
# are implemented. See 08_ARCHITECTURE.md §2.1.

# The "0 = Non précisé" sentinel every optional nomenclature link uses
# (02_BASE_DE_DONNEES.md §7 rule 2). Shown at the top of every combo.
# ---------------------------------------------------------------------
# Le nom de la langue, écrit dans sa propre langue.
#
# C'est ce que montrent le menu Paramètres et le sélecteur du premier
# lancement (01_CAHIER_DES_CHARGES.md §3.5 : « chaque langue écrite dans sa
# propre langue »). Il est ici, et non dans le code, parce que c'est le seul
# endroit où il puisse être juste : ajouter une langue, c'est déposer un
# fichier qui sait se nommer.
# ---------------------------------------------------------------------
language-name = Français

nomenclature-unspecified = Non précisé

# Asked before deleting a nomenclature element that operations still use
# (02_BASE_DE_DONNEES.md §7 rule 5). Reproduced word for word from the
# original WinDev source (Enreg_Supprimer), typography included — the wording
# is the author's, not a translation.
nomenclature-delete-confirm = Des opérations (transactions bancaires) possédant l'attribut de type '{ $label }' ont été détectées. Est ce que vous confirmez vouloir réinitialiser cet attribut ?

# Asked before deleting a nomenclature element that nothing uses. The original
# deleted such an element outright, without a word; Fabrice asked on
# 25/07/2026 that a deletion always be confirmed — an assumed departure from
# his own code, and the only one in this module.
nomenclature-delete-plain = Confirmez-vous la suppression de « { $label } » ?

# Refusal shown when the element the user is about to delete is the very one
# its fiche is showing. Fabrice's ruling of 25/07/2026: an element is not
# deleted from under its own open fiche — the fiche is closed first, rather
# than being left showing a record that no longer exists.
nomenclature-delete-form-open = La fiche de « { $label } » est ouverte. Fermez-la avant de supprimer.

# Refusal shown when the label being saved is already borne by another element
# of the same nomenclature (author's ruling, 25/07/2026: two elements of one
# nomenclature must not share a name — classing an operation under one of two
# identical labels is a coin toss). `element` is the noun in its own gender,
# « une catégorie », « un tiers » ; `label` is the existing label, as stored,
# so the user sees what is in the way.
nomenclature-duplicate = Il existe déjà { $element } du même nom : « { $label } ».

# ---------------------------------------------------------------------
# Ce que les fenêtres disent d'elles-mêmes.
#
# Tout est ici, y compris ce qui dépend de la nomenclature affichée : les
# phrases sont écrites en entier, langue par langue, plutôt que fabriquées
# par assemblage de mots et de genres. Un assemblage juste en français est
# faux dans la langue suivante, et c'est le code qui finit par savoir qu'il
# existe un féminin — ce n'est pas son travail (règle de l'auteur,
# 25/07/2026 : « le logiciel fonctionne avec Fluent en français et en
# anglais dès le début »).
# ---------------------------------------------------------------------

ui-loading = Chargement…
ui-editing = Modification.
ui-viewing = Consultation.
ui-modified-suffix = — modifié
ui-label-required = Le libellé est obligatoire.
ui-discard-question = Abandonner les modifications ?
ui-yes = Oui
ui-no = Non
ui-select-record = Veuillez sélectionner un enregistrement
ui-key-multiselect = CTRL
ui-multiselect-help = Info : Utilisez Clic Souris + touche [{ $modifier }] sur le tableau pour sélectionner plusieurs éléments
ui-no-match = Aucun libellé ne correspond au filtre.
ui-filter-placeholder = Filtrer les libellés…
ui-column-label = LIBELLE
ui-field-label = Libelle
ui-field-budget-line = Poste budgétaire
ui-identifier = Identifiant
ui-deletion-abandoned = Suppression abandonnée : rien n'a été modifié.
ui-unknown-nomenclature = Nomenclature inconnue :

ui-title-filter = Filtrer
ui-title-create = Créer
ui-title-update = Modifier la sélection
ui-title-delete = Supprimer la sélection
ui-title-read = Consulter la sélection
ui-title-close = Fermer
ui-title-save = Enregistrer
ui-title-add = Ajouter
ui-title-modify = Modifier

ui-load-failed = Chargement impossible :
ui-save-failed = Enregistrement impossible :
ui-read-failed = Lecture impossible :
ui-delete-failed = Suppression impossible :
ui-open-failed = Ouverture impossible :
ui-close-failed = Fermeture impossible :

# --- Phrases propres à chaque nomenclature ---------------------------

nomenclature-identifier = { $kind ->
    [category] Identifiant de Categorie
    [assignment] Identifiant d'Affectation
    [payment-mode] Identifiant de Mode operation
    [payee] Identifiant de Tiers
    [project] Identifiant de Projet
    [budget-line] Identifiant de Poste budgetaire
   *[bank] Identifiant de Banque
}

nomenclature-none = { $kind ->
    [category] Aucune catégorie.
    [assignment] Aucune affectation.
    [payment-mode] Aucun mode opération.
    [payee] Aucun tiers.
    [project] Aucun projet.
    [budget-line] Aucun poste budgétaire.
   *[bank] Aucune banque.
}

nomenclature-nothing-to-show = { $kind ->
    [category] Aucune catégorie à afficher.
    [assignment] Aucune affectation à afficher.
    [payment-mode] Aucun mode opération à afficher.
    [payee] Aucun tiers à afficher.
    [project] Aucun projet à afficher.
    [budget-line] Aucun poste budgétaire à afficher.
   *[bank] Aucune banque à afficher.
}

nomenclature-gone = { $kind ->
    [category] Cette catégorie n'existe plus.
    [assignment] Cette affectation n'existe plus.
    [payment-mode] Ce mode opération n'existe plus.
    [payee] Ce tiers n'existe plus.
    [project] Ce projet n'existe plus.
    [budget-line] Ce poste budgétaire n'existe plus.
   *[bank] Cette banque n'existe plus.
}

nomenclature-fresh = { $kind ->
    [category] Nouvelle catégorie.
    [assignment] Nouvelle affectation.
    [payment-mode] Nouveau mode opération.
    [payee] Nouveau tiers.
    [project] Nouveau projet.
    [budget-line] Nouveau poste budgétaire.
   *[bank] Nouvelle banque.
}

nomenclature-created = { $kind ->
    [category] Catégorie ajoutée.
    [assignment] Affectation ajoutée.
    [payment-mode] Mode opération ajouté.
    [payee] Tiers ajouté.
    [project] Projet ajouté.
    [budget-line] Poste budgétaire ajouté.
   *[bank] Banque ajoutée.
}

nomenclature-updated = { $kind ->
    [category] Catégorie modifiée.
    [assignment] Affectation modifiée.
    [payment-mode] Mode opération modifié.
    [payee] Tiers modifié.
    [project] Projet modifié.
    [budget-line] Poste budgétaire modifié.
   *[bank] Banque modifiée.
}

nomenclature-deleted = { $kind ->
    [category] { $count ->
        [one] 1 catégorie supprimée.
       *[other] { $count } catégories supprimées.
      }
    [assignment] { $count ->
        [one] 1 affectation supprimée.
       *[other] { $count } affectations supprimées.
      }
    [payment-mode] { $count ->
        [one] 1 mode opération supprimé.
       *[other] { $count } modes opération supprimés.
      }
    [payee] { $count ->
        [one] 1 tiers supprimé.
       *[other] { $count } tiers supprimés.
      }
    [project] { $count ->
        [one] 1 projet supprimé.
       *[other] { $count } projets supprimés.
      }
    [budget-line] { $count ->
        [one] 1 poste budgétaire supprimé.
       *[other] { $count } postes budgétaires supprimés.
      }
   *[bank] { $count ->
        [one] 1 banque supprimée.
       *[other] { $count } banques supprimées.
      }
}

nomenclature-duplicate-name = { $kind ->
    [category] Il existe déjà une catégorie du même nom : « { $label } ».
    [assignment] Il existe déjà une affectation du même nom : « { $label } ».
    [payment-mode] Il existe déjà un mode opération du même nom : « { $label } ».
    [payee] Il existe déjà un tiers du même nom : « { $label } ».
    [project] Il existe déjà un projet du même nom : « { $label } ».
    [budget-line] Il existe déjà un poste budgétaire du même nom : « { $label } ».
   *[bank] Il existe déjà une banque du même nom : « { $label } ».
}

# --- Titres de fenêtres, sans accents comme sur les fenêtres d'origine -

window-list-title = { $kind ->
    [category] Liste des categories
    [assignment] Liste des affectations
    [payment-mode] Liste des modes operation
    [payee] Liste des tiers et marchands
    [project] Liste des projets
    [budget-line] Liste des postes budgetaires
   *[bank] Liste des banques
}

window-form-title = { $kind ->
    [category] Fiche categorie
    [assignment] Fiche affectation
    [payment-mode] Fiche mode operation
    [payee] Fiche tiers
    [project] Fiche projet
    [budget-line] Fiche poste budgetaire
   *[bank] Fiche banque
}

# --- Barre de menus (01_CAHIER_DES_CHARGES.md §6) ---------------------

menu-file = Fichier
menu-file-import-statements = Importation de relevés bancaires
menu-file-import-excel = Importation de fichier Excel
menu-file-backup = Sauvegarde
menu-file-restore = Restauration
menu-file-repair = Réparation et optimisation de la base de données
menu-file-log = Afficher le log
menu-tools-password = Protection de la base par mot de passe
menu-file-disconnect = Se déconnecter de la base en cours
menu-file-quit = Quitter

menu-accounts = Comptes
menu-accounts-manage = Gestion des comptes bancaires
menu-accounts-balances = Voir les soldes de vos comptes
menu-accounts-operations = Gérer les opérations d'un compte
menu-accounts-quick-classify = Classification rapide des opérations
menu-accounts-recurring = Gestion des opérations périodiques
menu-accounts-transfer = Transférer un montant entre deux comptes
menu-accounts-checkbooks = Gestion des chéquiers

menu-statistics = Statistiques
menu-statistics-balance-chart = Graphique Évolution du solde
menu-statistics-by-category = Stat par catégories
menu-statistics-by-assignment = Stat par affectations
menu-statistics-by-budget-line = Stat par postes budgétaires
menu-statistics-by-payment-mode = Stat par moyens de paiement
menu-statistics-by-payee = Stat par tiers et marchands
menu-statistics-by-project = Stat par projets
menu-statistics-dashboard = Tableau de bord des opérations

menu-budget = Budget
menu-budget-entry = Saisie budget
menu-budget-control = Contrôle budget

menu-nomenclatures = Nomenclatures
menu-nomenclature = { $kind ->
    [category] Catégories
    [assignment] Affectations
    [payment-mode] Modes opération
    [payee] Tiers et marchands
    [project] Projets
    [budget-line] Postes Budgétaires
   *[bank] Banques
}
menu-nomenclatures-templates = Modèles d'opérations

menu-settings = Paramètres
menu-settings-about-author = À propos de l'auteur
menu-settings-about-radinus = À propos de Radinus
menu-settings-licence = Licence d'utilisation

menu-misc = Divers
menu-misc-calculator = Calculatrice
menu-misc-website = Aller sur le site de Radinus
menu-misc-database-folder = Accès au dossier contenant la base de données

# L'avertissement posé devant ce dossier (Fabrice, 08/08/2026) : « un
# utilisateur ignorant peut faire des bêtises ». La question est posée
# avant l'ouverture, jamais après.
database-folder-warning-title = Ouvrir le dossier de la base de données
database-folder-warning =
    Ce dossier contient toutes vos données. Y renommer, déplacer ou supprimer un fichier peut faire perdre vos comptes, les corrompre, ou empêcher Radinus de fonctionner.
    Voulez-vous vraiment l'ouvrir ?
menu-misc-application-folder = Accès au dossier contenant l'application
menu-misc-attachments-folder = Accès au dossier contenant les pièces jointes
# --- « Gestion des pièces jointes » (08/08/2026) -------------------------
#
# La fenêtre montre les pièces de toutes les opérations, plus les fichiers
# du dossier que la base ne réclame pas. Les cinq états ne sont pas trois :
# un fichier disparu, un fichier modifié et un fichier qu'on ne sait pas
# juger ne se traitent pas de la même façon.
menu-settings-attachments = Gestion des pièces jointes
window-attachments-manager-title = Gestion des pièces jointes
attachments-column-document = Document
attachments-column-size = Taille
attachments-column-added = Ajoutée le
attachments-column-state = État
attachments-state-intact = Intacte
attachments-state-altered = Modifiée depuis
attachments-state-missing = Fichier absent
attachments-state-unknown = Non vérifiable
attachments-state-orphan = Orpheline
attachments-no-operation = Aucune opération
attachments-orphan-remove-question = Ce fichier n'est rattaché à aucune opération. Le mettre à la corbeille ?
attachments-manager-help = Double-cliquez sur une ligne pour ouvrir le document.

# Les deux entrées du clic droit. « Afficher l'opération » n'apparaît pas
# sur un orphelin — il n'appartient à aucune opération — et « Révéler »
# disparaît quand le fichier n'est plus sur le disque.
attachments-show-operation = Afficher l'opération
attachments-reveal = Révéler dans le navigateur de fichiers
attachments-manager-summary = { $count } pièces jointes, { $size } au total.
attachments-disk-name = Nom sur le disque : { $name }

# L'avertissement du dossier des pièces jointes (Fabrice, 08/08/2026).
# Le danger n'y est pas le même que pour la base : on ne perd pas des
# comptes, on casse un lien — l'opération annonce une pièce qui ne
# s'ouvre plus. C'est ce que dit la phrase, plutôt que « ne faites pas
# n'importe quoi ».
attachments-folder-warning-title = Ouvrir le dossier des pièces jointes
attachments-folder-warning =
    Ce dossier contient les fichiers que vous avez attachés à vos opérations. Radinus les range sous un nom qu'il a choisi lui-même : y renommer, déplacer ou supprimer un fichier ne le retire pas de l'opération, celle-ci continuera de l'annoncer et il ne s'ouvrira plus.
    Voulez-vous vraiment l'ouvrir ?

# ---------------------------------------------------------------------
# Comptes bancaires — F04, F06, F07, F08.
# Les coquilles de la version 1.9.3 (« Bank Identifer Code », « Solde
# initial prevu », « Est Cloturé », l'espace avant la parenthèse de l'IBAN)
# sont corrigées : décision de Fabrice du 25/07/2026.
# ---------------------------------------------------------------------

window-accounts-title = Gestion des comptes bancaires
window-accounts-select-title = Liste des comptes
window-balances-title = Soldes de vos comptes
window-account-title = Fiche compte

accounts-none = Aucun compte.
accounts-nothing-to-show = Aucun compte à afficher.
accounts-gone = Ce compte n'existe plus.
accounts-fresh = Nouveau compte.
accounts-created = Compte ajouté.
accounts-updated = Compte modifié.
accounts-deleted = { $count ->
    [one] 1 compte supprimé.
   *[other] { $count } comptes supprimés.
}
accounts-duplicate-name = Il existe déjà un compte du même nom : « { $label } ».
accounts-multiselect-help = Info : Utilisez Clic Souris + touche [{ $modifier }] sur le tableau pour sélectionner plusieurs comptes
accounts-select-question = Sur quels comptes bancaires doit-on baser les statistiques ?

accounts-column-label = LIBELLE
accounts-column-bank = Banque
accounts-column-type = Type compte
accounts-column-number = Num Compte
accounts-column-account = Compte
accounts-column-bank-balance = En Banque
accounts-column-real-balance = Réel
accounts-column-final-balance = Final
accounts-total = TOTAL

# La suppression d'un compte emporte ses opérations : c'est le seul endroit
# du logiciel où une suppression détruit de l'historique.
accounts-delete-plain = Confirmez-vous la suppression du compte « { $label } » ?
accounts-delete-with-operations = Le compte « { $label } » contient { $count } opérations, qui seront supprimées avec lui. Est ce que vous confirmez la suppression ?
accounts-delete-form-open = La fiche du compte « { $label } » est ouverte. Fermez-la avant de supprimer.

account-group-bank = Infos compte et banque
account-group-holder = Titulaire
account-group-rib = Coordonnées bancaires (RIB)
account-group-activity = Activité
account-group-balances = Soldes

account-field-label = Titre du compte
account-field-bank = Banque
account-field-type = Type compte
account-field-branch-address = Adresse agence bancaire
account-field-holder-name = Nom
account-field-holder-address = Adresse
account-field-rib-bank = Établissement
account-field-rib-branch = Code guichet
account-field-rib-number = Numéro compte
account-field-rib-key = Clé RIB
account-field-bic = BIC (Bank Identifier Code)
account-field-iban = IBAN (International Bank Account Number)
account-field-opening-date = Date d'ouverture
account-field-closing-date = Date de clôture
account-field-closed = Est clôturé
account-field-opening-pointed = Solde initial pointé
account-field-opening-committed = Solde initial engagé
account-field-opening-planned = Solde initial prévu

account-label-required = Le titre du compte est obligatoire.
account-iban-invalid = Cet IBAN n'est pas valide : vérifiez la clé de contrôle.
# La ligne bleue du bas de la fiche, mot pour mot celle de 1.9.3 — seuls les
# montants suivent désormais le format français des autres champs.
account-control-line = Solde initial pointé ({ $opening }) + Total des opérations ({ $operations }) = Solde en banque actuel : { $balance }.

amount-not-readable = « { $field } » ne contient pas un montant valide.

ui-thousands-separator =  
ui-decimal-separator = ,

# --- Liste des opérations (F02) --------------------------------------

window-operations-title = Liste opérations du compte : { $account }

operations-none = Aucune opération sur cette période.
operations-bad-period = Les bornes de la période ne sont pas des dates valides.
operations-from = Date debut
operations-to = Date fin
operations-delete-confirm = { $count ->
    [one] Confirmez-vous la suppression de cette opération ?
   *[other] Confirmez-vous la suppression de ces { $count } lignes ? Les sous-opérations des opérations sélectionnées partent avec elles.
}
operations-deleted = { $count ->
    [one] 1 opération supprimée.
   *[other] { $count } opérations supprimées.
}
operations-selection-total = Montant total des opérations sélectionnées : { $amount }

operations-column-date = Date
operations-column-clearing-date = Date Pointage
operations-column-label = Libelle
operations-column-category = Categorie
operations-column-assignment = Affectation
operations-column-payment-mode = ModeOp
operations-column-payee = Tiers
operations-column-project = Projets
operations-column-month = Mois
operations-column-debit = Debit
operations-column-credit = Credit
operations-column-balance = Solde
operations-column-comments = Commentaires
operations-column-attachments = Pièces Jointes
operations-column-check = Num Chèque

operations-foot-debit = Débit :
operations-foot-credit = Crédit :
operations-foot-total = Total :
operations-foot-bank = Solde en banque :
operations-foot-real = Solde réel :
operations-foot-final = Solde final :

operations-menu-export = Export
operations-menu-print = Impression
operations-menu-filter = Filtre
operations-menu-period = Période
operations-menu-misc = Divers

operations-title-point = Pointer la sélection
operations-title-sub = Ajouter une sous-opération
operations-title-duplicate = Dupliquer la sélection
operations-not-yet = Cette fenêtre n'existe pas encore : elle vient plus loin dans le plan.

accounts-choose-question = Sur quel compte voulez-vous travailler ?
ui-title-select = Choisir la sélection

month-january = janvier
month-february = février
month-march = mars
month-april = avril
month-may = mai
month-june = juin
month-july = juillet
month-august = août
month-september = septembre
month-october = octobre
month-november = novembre
month-december = décembre

operations-period-year = Année en cours

# --- Menu Période de F02 ---------------------------------------------
# Neuf entrées, dont deux qui ouvrent un sous-menu des douze mois. Chacune ne
# fait qu'une chose : en déduire une date de début et une date de fin, que la
# fenêtre remet dans ses deux champs (demande de Fabrice, 25/07/2026).

period-all = Toutes
period-last-year = Année Dernière
period-this-year = Année Actuelle
period-whole-year = Toute l'année
period-last-month = Mois Dernier
period-this-month = Mois en Cours
period-last-week = Semaine Dernière
period-this-week = Semaine Actuelle
period-yesterday = Hier
period-today = Aujourd'hui

# --- Menu Filtre de F02 ----------------------------------------------
# Filtre les lignes selon la nature de l'opération (demande de Fabrice,
# 25/07/2026). Les trois statuts sont ceux de la base : 1 pointé, 2 engagé,
# 3 prévu (02_BASE_DE_DONNEES.md §5.2).

filter-all = Toutes les opérations
filter-pointed = Uniquement les opérations pointées
filter-committed = Uniquement les opérations engagées
filter-planned = Uniquement les opérations prévues

# --- Fiche opération (F03) -------------------------------------------
# Les intitulés sont ceux de la capture « Fiche operation transaction.png »,
# coquilles de l'original corrigées (autorisation de Fabrice, 25/07/2026 :
# « les coquilles tu les corriges ») : « Libelle » devient « Libellé »,
# « Categorie » devient « Catégorie », « Statut Operation » devient
# « Statut opération ».

window-operation-title = Opération Compte : { $account }

operation-menu-identification = Identification
operation-menu-options = Options
operation-fitid-edit = Éditer l'identifiant FITID…
operation-fitid-delete = Supprimer l'identifiant FITID
operation-fitid-question = Identifiant FITID de cette opération :
operation-fitid-delete-question = Supprimer l'identifiant FITID de cette opération ?
operation-fitid-written = Identifiant FITID enregistré.
operation-fitid-removed = Identifiant FITID supprimé.

operation-group-identification = Identification de l'opération
operation-group-amount = Montant de l'opération
operation-group-status = Statut de l'opération
operation-group-classification = Classement de l'opération pour calcul des statistiques
operation-group-check = Chèque en relation avec l'opération
operation-group-comment = Commentaire

operation-field-label = Libellé
operation-field-reference = Référence paiement
operation-field-date = Date
operation-field-direction = Type Opération :
operation-field-amount = Montant
operation-field-status = Statut opération
operation-field-clearing-date = Date pointage
operation-field-category = Catégorie
operation-field-assignment = Affectation
operation-field-payment-mode = Mode
operation-field-payee = Tiers
operation-field-project = Projet
operation-field-check = Associer avec chèque

operation-direction-debit = Débit
operation-direction-credit = Crédit

operation-check-info = Info.
operation-check-link = Associer
operation-check-unlink = Supprimer

operation-fresh = Nouvelle opération.
operation-created = Opération ajoutée.
operation-updated = Opération modifiée.
operation-gone = Cette opération n'existe plus.
operation-nothing-to-show = Aucune opération à afficher.
operation-label-required = Le libellé de l'opération est obligatoire.
operation-date-required = La date de l'opération est obligatoire.
operation-clearing-date-invalid = La date de pointage n'est pas une date valide.
operation-is-a-sub = Cette ligne est une sous-opération : elle se modifie depuis sa fiche à elle.
operation-delete-form-open = La fiche de « { $label } » est ouverte. Fermez-la avant de supprimer.

operation-attachments = { $count ->
    [0] Aucune pièce jointe
    [one] 1 pièce jointe
   *[other] { $count } pièces jointes
}

operation-title-comment = Commentaire de l'opération
operation-title-sub = Créer une sous-opération
operation-title-template = Modèles d'opération
operation-title-attachment = Pièces jointes

# --- Fiche sous-opération (F04) --------------------------------------
# Version réduite de F03 : ni Mode, ni Statut, ni Date — une sous-opération
# les tient de sa mère (`Maj_ProprieteSousOp`, confirmé par Fabrice le
# 26/07/2026 : « dans une sous-opération, comme est le complément, on ne peut
# pas toucher au mode de paiement, cela serait illogique »).

window-sub-operation-title = Fiche Sous-Operation

sub-operation-group-amount = Montant de la sous-opération
sub-operation-field-label = Nom
sub-operation-fresh = Nouvelle sous-opération.
sub-operation-created = Sous-opération ajoutée.
sub-operation-updated = Sous-opération modifiée.
sub-operation-gone = Cette sous-opération n'existe plus.
sub-operation-nothing-to-show = Aucune sous-opération à afficher.
sub-operation-label-required = Le nom de la sous-opération est obligatoire.
sub-operation-parent-gone = L'opération à ventiler n'existe plus.
# Ce que la fiche dit quand elle montre le Complément. Il n'est pas protégé :
# on peut le modifier, mais on doit savoir ce qu'on prend (décision de
# Fabrice, 26/07/2026).
sub-operation-is-the-complement = Ceci est le Complément : ce qui reste à ventiler. Le renommer ou changer son montant en fait une sous-opération ordinaire.
sub-operation-of = Ventilation de « { $label } » ({ $amount })

operations-pointed = { $count ->
    [one] 1 opération pointée.
   *[other] { $count } opérations pointées.
}
operations-select-one = Veuillez sélectionner une seule opération.

# --- Dupliquer et l'affichage des sous-opérations (F02) ---------------
# Dupliquer ouvre une fiche pré-remplie que l'utilisateur valide lui-même
# (décision de Fabrice, 26/07/2026) : rien n'est écrit tant qu'il n'a pas
# enregistré, et il peut corriger la date ou le montant avant.

operation-copy = Copie à enregistrer : rien n'est encore créé.
operations-show-children = Afficher toutes les sous-opérations
operations-hide-children = Masquer toutes les sous-opérations

# --- Seconde confirmation d'une suppression grave ---------------------
# Supprimer un compte bancaire emporte tout son historique : un Oui/Non se
# clique sans lire, alors on demande d'écrire le mot (décision de Fabrice,
# 26/07/2026). Le mot est celui du dictionnaire — « Oui » ici, « Yes » en
# anglais — donc rien n'est à traduire ici deux fois.

accounts-delete-second-question = Cette suppression est définitive et emporte tout l'historique du compte. Tapez « { $word } » pour la confirmer.

# --- F20-F24 — Les six statistiques -----------------------------------
# Gabarit commun, décliné sur six axes. Celle par catégories a servi de
# modèle et Fabrice l'a validée le 26/07/2026 avant que les cinq autres
# n'existent — les noms de colonnes sont ceux de l'original.

window-statistics-title = { $kind ->
    [assignment] Statistiques par affectation
    [budget-line] Statistiques par poste budgetaire
    [payment-mode] Statistiques par moyen de paiement
    [payee] Statistiques par tiers et marchand
    [project] Statistiques par projet
   *[category] Statistiques par categorie
}

statistics-axis-column = { $kind ->
    [assignment] Affectation
    [budget-line] PosteBudget
    [payment-mode] ModeOperation
    [payee] Tiers
    [project] Projets
   *[category] NomCategorie
}

statistics-unclassified = { $kind ->
    [assignment] Sans affectation
    [budget-line] Sans poste budgetaire
    [payment-mode] Sans moyen de paiement
    [payee] Sans tiers
    [project] Sans projet
   *[category] Sans categorie
}
statistics-total = Total
statistics-sum = Somme
statistics-cumulative = Cumul

# Les cinq interrupteurs du bandeau. Le libellé bascule ON/OFF, comme dans
# l'original : c'est l'interrupteur lui-même qui dit où il est.
statistics-switch-pointed = Opérations pointées { $state }
statistics-switch-committed = Opérations engagées { $state }
statistics-switch-planned = Opérations prévues { $state }
statistics-switch-debits = Débits montants { $state }
statistics-switch-credits = Crédits montants { $state }
statistics-switch-on = ON
statistics-switch-off = OFF

statistics-no-account = Aucun compte n'a été choisi : la statistique ne porte sur rien.
statistics-no-data = Aucune opération sur cette année pour les comptes choisis.
statistics-detail-empty = Cliquez une case chiffrée pour voir les opérations qu'elle compte.
statistics-detail-none = Aucune opération derrière cette case.
statistics-accounts = { $count ->
    [one] 1 compte
   *[other] { $count } comptes
}
statistics-year-next = Année suivante
statistics-year-previous = Année précédente

statistics-column-date = Date
statistics-column-clearing-date = DatePointage
statistics-column-label = Libelle
statistics-column-amount = Montant
statistics-column-comments = Commentaires

accounts-stats-multiselect-help = Info : Utilisez Clic Souris + touche [{ $modifier }] sur le tableau pour choisir plusieurs comptes

# Le millésime des statistiques : on clique dessus et on saisit une année.
# Les bornes sont celles du « Toutes » du menu Période — une année de Radinus
# est un entier entre 1950 et 2550 (Fabrice, 26/07/2026).
statistics-year-question = Sur quelle année voulez-vous travailler ? Radinus va de { $first } à { $last }.
statistics-year-choose = Choisir l'année

# --- Export des tableaux (clic droit) ---------------------------------
# Une fonction du tableau, pas d'une fenêtre : toutes les listes l'ont.

export-to-excel = Exporter vers Excel (.xlsx)
export-to-word = Exporter vers Word (.docx)
export-to-tsv = Exporter vers TSV (.tsv)
export-to-ini = Exporter vers INI (.ini)
export-to-toml = Exporter vers TOML (.toml)
export-to-yaml = Exporter vers YAML (.yaml)
export-to-ofx = Exporter vers OFX (.ofx)
export-to-qif = Exporter vers QIF (.qif)
export-to-ods = Exporter vers LibreOffice Calc (.ods)
export-to-csv = Exporter vers CSV (.csv)
export-to-xml = Exporter vers XML (.xml)
# Le menu Export de la fenêtre des statistiques : un onglet par année, nommé
# AN_2026. Les années vides — sous les interrupteurs posés — n'y sont pas.
export-menu = Export
export-all-years-excel = Exporter toutes les années vers Excel
export-all-years-ods = Exporter toutes les années vers LibreOffice Calc
export-no-year = Aucune année ne porte d'opération : il n'y a rien à exporter.
export-years-done = { $years } années exportées vers « { $file } ».
export-to-json = Exporter vers JSON (.json)
export-done = Exporté vers « { $file } ».
export-failed = Export impossible : { $reason }
export-nothing = Il n'y a rien à exporter.
export-context = { $window } — { $detail }
statistics-window-name = { $kind ->
    [assignment] Statistiques par affectation
    [budget-line] Statistiques par poste budgetaire
    [payment-mode] Statistiques par moyen de paiement
    [payee] Statistiques par tiers et marchand
    [project] Statistiques par projet
   *[category] Statistiques par categorie
}
statistics-detail-name = Detail des statistiques

# --- F19 — Tableau de bord --------------------------------------------
# Une période et trois interrupteurs ; deux anneaux par poste budgétaire ;
# trois grands chiffres. Les couleurs des secteurs sont celles de l'original,
# relevées sur la capture de Fabrice.

window-dashboard-title = Tableau de bord
dashboard-menu-period = Période
dashboard-menu-misc = Divers
dashboard-from = Date début :
dashboard-to = Date fin :
dashboard-switch-pointed = Inclure opérations pointées
dashboard-switch-committed = Inclure opérations engagées
dashboard-switch-planned = Inclure opérations prévues
dashboard-spending = Dépenses
dashboard-earning = Gains
dashboard-debits = Somme opérations débités
dashboard-credits = Somme opérations crédités
dashboard-balance = Balance
dashboard-unclassified = Sans poste budgetaire
dashboard-nothing = Aucune opération sur cette période.
dashboard-no-account = Aucun compte n'a été choisi : le tableau de bord ne porte sur rien.
dashboard-enlarge = Ouvrir en grand

# --- F25 — Evolution du solde ------------------------------------------
# Une courbe par compte choisi, plus celle du total — qui n'existe qu'à
# partir de deux comptes (règle de Fabrice, 26/07/2026). Les courbes sont
# en escalier : le solde garde sa valeur jusqu'à l'opération suivante.

window-curve-title = Evolution du solde
curve-heading = Evolution du solde par jour
curve-menu-period = Période
curve-total = Total
curve-from = Date début :
curve-to = Date fin :
curve-axis-balance = solde
curve-nothing = Aucun compte n'a été choisi : il n'y a pas de courbe à tracer.
curve-empty = Aucune opération sur cette période.

# --- F05 — Classification rapide des opérations ------------------------
# La fenêtre où l'on classe **en masse** : on sélectionne des lignes, on coche
# les caractéristiques à changer, et on les applique d'un coup — en mémoire.
# Rien n'est écrit tant que l'on n'a pas enregistré, et l'enregistrement
# n'écrit que ce qui diffère de ce qui a été lu (règles de Fabrice,
# 27/07/2026).

window-quick-classification-title = Classification rapide des opérations : { $account }
quick-dates-title = Dates de début et fin de liste.
quick-from = Date debut
quick-to = Date fin
quick-menu-period = Période
quick-change-title = Changer caractéristiques sélection en :
quick-check-category = Categorie
quick-check-assignment = Affectation
quick-check-payment-mode = Mode
quick-check-payee = Tiers
quick-check-project = Projet
quick-check-status = Status
quick-column-date = Date
quick-column-label = Libelle
quick-column-amount = Montant
quick-column-category = Categorie
quick-column-assignment = Affectation
quick-column-payment-mode = Mode Paiement
quick-column-payee = Tiers
quick-column-project = Projets
quick-column-status = Status
# Sur un Mac, Ctrl + clic est un clic droit : la touche qui ajoute à une
# sélection y est ⌘, et l'aide doit dire celle qui marche.
quick-multiselect-help = Info : Utilisez Clic Souris + touche [{ $modifier }] sur le tableau pour sélectionner plusieurs éléments
quick-none = Aucune opération sur cette période.
quick-select-lines = Sélectionnez au moins une ligne, et cochez au moins une caractéristique.
quick-applied = { $count ->
    [0] Rien n'a changé : ces lignes portaient déjà ce classement.
    [one] 1 ligne classée. Rien n'est encore enregistré.
   *[other] { $count } lignes classées. Rien n'est encore enregistré.
}
quick-pending = { $count ->
    [0] Aucune modification en attente.
    [one] 1 ligne modifiée, non enregistrée.
   *[other] { $count } lignes modifiées, non enregistrées.
}
quick-save-question = { $count ->
    [one] Enregistrer la modification en attente ?
   *[other] Enregistrer les { $count } modifications en attente ?
}
quick-saved = { $count ->
    [0] Il n'y avait rien à enregistrer.
    [one] 1 ligne enregistrée.
   *[other] { $count } lignes enregistrées.
}
quick-nothing-to-save = Aucune modification en attente.
quick-leave-question = Des modifications ne sont pas enregistrées. Que voulez-vous faire ?
quick-leave-save = Enregistrer et sortir
quick-leave-discard = Abandonner et sortir
quick-leave-stay = Rester
quick-title-apply = Appliquer aux lignes sélectionnées ( en mémoire )
quick-title-save = Enregistrer sur le disque

# --- F17 / F18 — Importation d'un relevé bancaire ----------------------
# On choisit un compte, on ouvre un fichier OFX — qui reste en RAM —, les
# lignes que la base connaît déjà s'affichent en pastel, et le troisième
# icône les intègre : en masse si plusieurs sont choisies, une par une par la
# fiche de rapprochement sinon (marche à suivre de Fabrice, 27/07/2026).

window-statement-import-title = Importation de relevés de comptes bancaires : { $account }
window-statement-form-title = Rapprocher une transaction (Intègre une opération dans l'historique de votre compte)
statement-menu-filter = Filtre
statement-filter-all = Toutes les lignes
statement-filter-pending = A intégrer
statement-filter-known = Déjà intégrées
statement-column-id = ID
statement-column-reconciled = Rapproché
statement-column-fitid = FITID
statement-column-date = Date
statement-column-label = Libelle
statement-column-debit = Debit
statement-column-credit = Credit
statement-account = Compte
statement-file = Fichier
statement-difference = Ecart
statement-none = Aucun relevé n'est ouvert : cliquez sur le dossier jaune pour choisir un fichier.
statement-empty = Ce relevé ne contient aucune opération.
statement-no-match = Aucune ligne ne correspond au filtre.
statement-help = Info : Utilisez Clic Souris + touche [{ $modifier }] sur le tableau pour sélectionner plusieurs lignes
statement-choose-account = Ce fichier contient plusieurs comptes. Lequel voulez-vous importer ?
statement-select-line = Sélectionnez au moins une ligne du relevé.
statement-title-open = Ouvrir un fichier de relevé (.ofx)
statement-title-info = Informations sur le fichier ouvert
statement-title-integrate = Intégrer la sélection dans le compte
statement-title-validate = Intégrer cette opération dans le compte
statement-duplicate = Attention doublon : cette transaction semble deja avoir été intégrée à la base (Financial Institution Transaction ID existe)
statement-no-fitid = Attention : ce fichier ne donne aucun identifiant (FITID) pour cette ligne. Un doublon ne pourra pas être détecté.
statement-loaded = { $count ->
    [0] Ce fichier ne contient aucune opération pour ce compte.
   *[other] { $count } lignes lues, dont { $known } déjà présentes dans votre compte.
}
statement-integrated = { $count ->
    [0] Rien n'est entré : ces lignes sont déjà dans votre compte.
    [one] 1 opération intégrée.
   *[other] { $count } opérations intégrées.
}
# **Les messages de l'original, mot pour mot** (consigne de Fabrice,
# 28/07/2026 : rester fidèle au code d'origine). Le sien avertit avant le lot,
# demande ligne par ligne devant un doublon, et rend ses comptes à la fin.

statement-mass-question =
    Êtes vous certain de vouloir intégrer dans votre compte simultanément plusieurs opérations ?
    Vous devrez les catégoriser et les caractériser ultérieurement pour faire des statistiques précise
    Dans le cas des fichier Ofx : si des doublons sont détectés vous devrez choisir le comportement du programme
    Pour les autres type de fichier : vous devrez faire attention aux doublons
statement-duplicate-question =
    La transaction : { $date } { $label } : { $amount }
    semble deja avoir été intégré à l'historique des transactions de votre compte banquaire.
    Souhaitez-vous vraiment procéder au rapprochement ?
statement-already-reconciled = Vous avez deja rapproché cette transaction : elle est deja intégré dans l'historique des transactions de votre compte
statement-integration-report =
    Fin de l'intégration.
    Nombre d'enregistrements intégrés : { $added }
    Nombre d'enregistrements ignorés : { $ignored }
statement-integration-abandoned =
    Abandon de l'intégration !
    Nombre d'enregistrements intégrés : { $added }
    Nombre d'enregistrements ignorés : { $ignored }
statement-yes = Oui
statement-no = Non
statement-cancel = Annuler
statement-file-info =
    Compte du fichier : { $account }
    Période : du { $from } au { $to }
    Solde annoncé par la banque : { $balance }
    { $count } opérations, dont { $known } déjà présentes dans votre compte.
statement-group-identification = Identification de l'opération
statement-group-amount = Montant de l'opération
statement-group-classification = Classement de l'opération pour calcul des statistiques
statement-group-status = Statut de l'opération
statement-field-date = Date
statement-field-label = Libelle
statement-field-type = Type Opération
statement-field-amount = Montant
statement-field-mode = Mode Operation
statement-field-category = Categorie
statement-field-assignment = Affectation
statement-field-payee = Tiers
statement-field-project = Projet
statement-field-status = Statut
statement-field-clearing = Date pointage

# --- La fenêtre de découpage d'un relevé CSV ---------------------------
# Un CSV ne porte aucun nom de champ fiable : on règle, on teste, on regarde,
# on recommence. L'aperçu montre tout, charabia compris — c'est ainsi qu'on
# voit qu'on s'est trompé — mais seules les lignes valides basculent vers la
# fenêtre d'intégration (règle de Fabrice, 27/07/2026).

window-csv-statement-title = Importation de données provenant d'un fichier csv
csv-preview-title = Apercu du fichier :
csv-settings-title = Parametres de découpage du fichier en vue de l'extraction des données :
csv-extraction-title = Visualisation de l'extraction des données selon les parametres de découpage  ( verifier la coherence des données ) :
csv-column-line = N° ligne
csv-column-content = Contenu
csv-header-lines = Nombre de lignes de l'entete du fichier à ignorer
csv-separator = Les données (colonnes) sont séparées par le caractere :
csv-date-at = Position champ date
csv-label-at = Position champ libellé
csv-debit-at = Position champ montant debit
csv-credit-at = Position champ montant credit
csv-test = Tester les parametres
csv-separator-semicolon = Point-virgule   ;
csv-separator-comma = Virgule   ,
csv-separator-tab = Tabulation
csv-separator-pipe = Barre verticale   |
csv-separator-space = Espace
csv-help = Réglez, testez, regardez : seules les lignes portant une date et un montant lisibles seront importées.
csv-none = Le fichier est vide.
csv-not-tested = Cliquez sur « Tester les parametres » pour voir ce que le découpage donne.
csv-extraction = { $count ->
    [0] Le découpage ne produit aucune ligne : vérifiez le nombre de lignes d'entete et le séparateur.
   *[other] { $count } lignes découpées : { $valid } seront importées, { $dropped } écartées faute de date ou de montant lisible.
}
csv-nothing-valid = Aucune ligne ne porte à la fois une date et un montant lisibles : il n'y a rien à importer. Vérifiez le nombre de lignes d'entete, le séparateur et la position des champs.
csv-title-validate = Basculer les lignes valides vers l'importation

# --- F13 / F31 / F14 / F12 — Chéquiers et chèques (phase 9) -------------
# Portage de ses cinq codes WinDev et de ses sept captures, fournis le
# 28/07/2026. Ses phrases exactes là où il en a une ; les miennes ailleurs.
#
# Trois fidélités qu'il a arbitrées ce jour-là et qui s'entendent dans les
# mots : la référence en double n'est pas annoncée (son `Existe_Reference`
# n'est jamais appelée), le nombre de chèques n'est pas confronté aux bornes,
# et le compteur d'opérations compte les filles que les listes refusent.

window-chequebooks-title = Liste des chequiers
window-chequebook-title = Parametres chequier
window-cheques-title = Composition du chéquier : liste des chèques.
window-cheque-title = Fiche chèques
window-cheque-operations-title = Liste des opérations.

# La liste des chéquiers (F13) — tous les carnets, tous comptes confondus :
# ses deux colonnes de compte ne serviraient à rien sur un seul.
chequebooks-column-reference = LIBELLE
chequebooks-column-date = Date
chequebooks-column-account = NomCompte
chequebooks-column-account-number = Num Compte
chequebooks-column-comments = Commentaires
chequebooks-none = Aucun chéquier n'est enregistré.
chequebooks-nothing-to-show = Aucun chéquier ne répond à cette recherche.
chequebooks-title-composition = Voir la composition du chéquier
chequebooks-delete-question = Des opérations (transactions bancaires) associées à chéquier ont été détectées. Est ce que vous confirmez vouloir supprimer ce chéquier ?
chequebooks-deleted = { $count ->
    [one] Un chéquier supprimé.
   *[other] { $count } chéquiers supprimés.
}
chequebooks-gone = Ce chéquier n'existe plus.
chequebooks-created = Chéquier enregistré, avec tous ses chèques.
chequebooks-updated = Chéquier modifié.
# Le silence de son `HAjoute` : la fenêtre ne dit pas que la référence est
# prise. Elle dit seulement que rien n'a été enregistré — sans quoi on
# croirait le carnet créé.
# Les huit précautions de son « Precauttion enregistrement cheque.txt », mot
# pour mot et dans son ordre. Les sept premières sont des `Erreur()`, la
# huitième un `Info()` — et l'ordre décide de ce que l'on voit quand deux
# choses vont mal ensemble.
chequebook-refusal-duplicate = Une référence du même nom existe déjà
chequebook-refusal-reference-required = La saisie d'une référence est obligatoire
chequebook-refusal-number-too-big = Les numéros du premier et/ou du dernier chèque sont trop grand (valeur maximum 999 999 999)
chequebook-refusal-date = Veuillez saisir une date de réception valide
chequebook-refusal-numbers-required = Veuillez remplir les numéros du premier et dernier chèque
chequebook-refusal-order = Le numéro du premier chèque doit être inférieur au numéro du dernier chèque
chequebook-refusal-account = Sélectionnez obligatoirement le compte en relation avec ce chéquier
chequebook-refusal-too-many = Nombre de chèque maximum pour un chéquier : 1000, limitation atteinte
# Sa demande de confirmation, posée à l'ajout seulement : elle récapitule ce
# qui va être créé et prévient que rien n'en sera modifiable après.
chequebook-creation-question =
    Création du chéquier avec les caractéristiques suivantes :
    - Nombre de chèques à générer :{ $count }
    - Chèques numérotés de { $first } à { $last }
    Attention ces données ne seront pas modifiables après création !

# La fiche chéquier (F31). Les cinq premiers champs sont grisés dès que le
# carnet existe : ses chèques sont déjà là.
chequebook-field-id = Identifiant de Chéquier
chequebook-field-reference = Référence
chequebook-field-received = Fabriqué ou reçu le
chequebook-field-first = Numéro du premier chèque
chequebook-field-last = Numéro du dernier chèque
chequebook-field-quantity = Nombre de chèques
chequebook-field-account = Associer au compte bancaire :
chequebook-field-comments = Commentaires
chequebook-locked = Les chèques de ce carnet sont déjà créés : sa numérotation ne se modifie plus.
# Sa phrase, mot pour mot (`Enreg_Lire`).
chequebook-account-missing = Le Compte bancaire auquel a été associé ce chéquier est absent ou a été supprimé !

# La composition du chéquier (F14). Le statut se change dans la case.
cheques-column-number = Num. Chèque
cheques-column-date = Date
cheques-column-place = Lieu
cheques-column-payee = Bénéficiaire
cheques-column-amount = Montant
cheques-column-status = Statut
cheques-column-comments = Commentaires
cheques-column-operations = Nbr. Opération Associées
cheques-none = Ce chéquier ne contient aucun chèque.
cheques-nothing-to-show = Aucun chèque ne répond à cette recherche.
cheques-help = Cliquez dans la case Statut pour le changer ; la loupe montre les opérations associées, le maillon en associe une.
cheques-title-linked = Voir les opérations déjà associées à ce chèque
cheques-title-link = Associer une opération à ce chèque
cheques-status-changed = Statut du chèque modifié.

# La fiche chèque (F12).
cheque-field-id = Identifiant de Chèque
cheque-field-number = Numéro chèque
cheque-field-issued = Date Émission
cheque-field-place = Lieu Émission
cheque-field-payee = Bénéficiaire
cheque-field-amount = Montant
cheque-field-comments = Commentaires
cheque-field-status = Statut du chèque
cheque-gone = Ce chèque n'existe plus.
cheque-updated = Chèque modifié.

# Les deux visages de la fenêtre d'association.
cheque-operations-linked-title = Liste des opérations déjà associées à ce chèque.
cheque-operations-choose-title = Choisissez une opération à associer au chèque
cheque-operations-column-account = Compte
cheque-operations-column-label = Nom
cheque-operations-column-date = Date
cheque-operations-column-clearing = Date Pointage
cheque-operations-column-amount = Montant
cheque-operations-column-cheque = Chèque associé
cheque-operations-none-linked = Aucune opération n'est associée à ce chèque.
cheque-operations-none = Ce compte ne contient aucune opération.
cheque-operations-nothing-to-show = Aucune opération ne répond à cette recherche.
cheque-operations-help = Les opérations en gras portent déjà un chèque.
cheque-operations-linked-help = La croix rouge détache le chèque de l'opération : rien n'est supprimé.
cheque-operations-linked = Opération associée au chèque.
cheque-operations-dissociated = Chèque détaché de l'opération.
cheque-operations-menu-filter = Filtre
cheque-title-associate = Associer cette opération au chèque
cheque-title-dissociate = Détacher le chèque de cette opération

# Le bandeau « Chèque en relation avec l'opération » de la fiche opération, et
# les deux temps de la pêche au chèque — le carnet, puis le chèque.
chequebooks-select-question = Choisissez le chéquier
cheques-select-question = Choisissez le chèque à associer à l'opération
operation-check-save-first = Enregistrez d'abord l'opération : un chèque s'associe à une opération qui existe.
operation-check-none = Cette opération ne porte aucun chèque.

# --- F36 / F37 — Les modèles d'opération (phase 10) ---------------------
# Un modèle est une saisie toute faite : on l'applique pour ne pas retaper, et
# il **écrase** ce qui est dans la fiche. Rien ne part sur le disque tant que
# la fiche opération n'est pas validée (règle de Fabrice, 29/07/2026).

window-operation-templates-title = Liste des modeles d'operations
window-operation-template-title = Fiche Modele Operation

operation-templates-none = Aucun modèle d'opération n'est enregistré.
operation-templates-nothing-to-show = Aucun modèle ne répond à cette recherche.
operation-templates-select-question = Choisissez le modèle à appliquer
operation-templates-delete-question = Confirmez-vous la suppression des modèles sélectionnés ?
operation-templates-deleted = { $count ->
    [one] Un modèle supprimé.
   *[other] { $count } modèles supprimés.
}
operation-template-gone = Ce modèle n'existe plus.
operation-template-fresh = Nouveau modèle.
operation-template-created = Modèle enregistré.
operation-template-updated = Modèle modifié.
operation-template-label-required = La saisie d'un nom est obligatoire
operation-template-duplicate = Un modèle du même nom existe déjà

# La fiche F36, section par section — ses intitulés exacts.
operation-template-field-id = ID Modèle Opération
operation-template-group-name = Nom par défaut de la future opération après application du modèle
operation-template-field-label = Nom
operation-template-group-amount = Montant par défaut de l'opération prédéfini dans ce modèle
operation-template-field-direction = Type Opération
operation-template-field-amount = Montant
operation-template-group-status = Statut de l'opération par défaut dans ce modèle
operation-template-field-status = Statut Operation
operation-template-group-classification = Informations du modèle pour classement calcul des statistiques
operation-template-field-category = Categorie
operation-template-field-assignment = Affectation
operation-template-field-mode = Mode
operation-template-field-payee = Tiers
operation-template-field-project = Projet

# Le bouton « Modèle » de la fiche opération : un icône, deux gestes.
operation-template-question = Que voulez-vous faire avec les modèles d'opération ?
operation-template-apply = Appliquer un modèle
operation-template-save-as = Enregistrer comme modèle
operation-template-applied = Modèle appliqué. Validez la fiche pour l'enregistrer.
operation-template-saved-as = Opération enregistrée comme modèle.
operation-template-needs-label = Donnez un nom à l'opération avant d'en faire un modèle.

# --- F26 / F27 — Le budget (phase 11) -----------------------------------
# Deux portes, deux questions : on saisit son budget, ou on contrôle s'il a
# été tenu. L'axe est le poste budgétaire, l'unité est l'année, et la
# convention de signe est celle des opérations — une dépense s'écrit négative.

window-budget-entry-title = Saisie Budget : dépenses(-) et revenus(+) prévus sur une année
window-budget-control-title = Controle du budget

budget-column-line = Poste budgetaire
budget-none = Aucun poste budgetaire n'est enregistre : le budget se saisit par poste.
budget-planned = Prévu
budget-actual = Réalisé
budget-sum = Somme
budget-cumulative = Cumul
budget-total = Total
# Le rappel de la convention de signe, en rouge sous le tableau de saisie.
# Sa phrase, mot pour mot et espaces compris (capture « POINT 004 saisie
# budget.png ») : elle est en rouge sous le tableau, et le titre de la fenêtre
# la redit en abrégé. Personne ne devinerait la convention sans elle.
budget-sign-warning = Saisissez obligatoirement les dépenses  avec un signe négatif et les revenus prévus avec des montants positifs
budget-entry-help = Tapez les montants dans les cases, puis enregistrez.
budget-saved = Budget enregistré.
budget-nothing-changed = Aucune modification à enregistrer.
budget-discard-question = Abandonner les modifications du budget ?

# Le menu Affichage du contrôle : les deux façons de lire le même écart.
budget-menu-display = Affichage
budget-display-money = Valeurs
budget-display-percent = Pourcentages
budget-control-help = Vert : au moins aussi bien que prévu. Rouge : moins bien.

# --- F09 — Transfert d'un montant entre deux comptes (phase 12) ----------
# Un virement n'est pas une opération, c'en est deux : un débit sur la source,
# un crédit sur la destination. Elles partent ensemble ou pas du tout.

window-transfer-title = Transférer un montant entre deux comptes

transfer-group-source = Débiter le montant sur ce compte source
transfer-group-target = Créditer le montant sur ce compte destination
transfer-group-description = Description de l'opération
transfer-group-nomenclature = Informations de Nomenclature
transfer-group-amount = Montant de la somme à transférer
transfer-field-source = Compte source
transfer-field-target = Compte destination
transfer-field-label = Libelle
transfer-field-reference = Référence paiement
transfer-field-date = Date
transfer-field-status = Statut Operation
transfer-field-clearing = Date pointage
transfer-field-category = Categorie
transfer-field-mode = Mode de reglement
transfer-field-assignment = Affectation
transfer-field-payee = Tiers / marchands
transfer-field-project = Projet
transfer-field-amount = Montant

# Le seul bouton des panneaux qui annoncent au lieu de demander.
ui-ok = OK
transfer-help = Choisissez les deux comptes : leurs soldes s'affichent ici.
transfer-title-validate = Effectuer le virement
# Les trois soldes du compte choisi, pour savoir ce qu'implique le virement.
transfer-balances = { $account } — En banque : { $bank } · Réel : { $real } · Final : { $final }
# Le panneau qui récapitule ce qui vient d'être écrit.
transfer-done = Virement effectué. { $amount } du compte { $source } vers le compte { $target }, le { $date }.

transfer-refusal-accounts-required = Choisissez le compte source et le compte destination
transfer-refusal-same-account = Le compte source et le compte destination ne peuvent pas être le même : un virement va d'un compte vers un autre
transfer-refusal-account-gone = L'un des deux comptes n'existe plus
transfer-refusal-label-required = Le libellé est obligatoire
transfer-refusal-date-required = La date est obligatoire
transfer-refusal-amount = Le montant à transférer doit être strictement positif

# ---------------------------------------------------------------------------
# Phase 13 — l'importation d'une feuille Excel (F34, F35, association).
# ---------------------------------------------------------------------------

window-excel-import-title = Importation de feuille excel [ Étape 1/3 ] : définition de la zone de capture
window-excel-fields-title = Importation de feuille excel [ Étape 2/3 ] : association des champs
window-excel-association-title = Importation de feuille excel : association des données

# La question posée à l'ouverture. Un fichier Excel est fabriqué à la main :
# il contient ce qu'il contient, et une partie du n'importe quoi qu'il porte
# est indétectable. On propose donc le filet avant de sauter.
excel-backup-question = Une feuille Excel est faite à la main : elle peut contenir des dates justes mais fausses, des montants du bon format et du mauvais signe — et cela, aucun contrôle ne peut le voir. L'importation écrira ces lignes dans votre compte. Voulez-vous sauvegarder vos données avant de commencer ?

excel-group-file = 1 - Désigner le fichier Excel à importer
excel-pick = Designer le fichier Excel
excel-sheet = Feuille du classeur :
excel-group-header = 2 - Définir : Coordonnées cellules pour ligne d'entête du tableau où sont écris le nom des colonnes.
excel-header-row = Numéro 1ere ligne ou est situé le nom des colonnes
excel-first-column = Colonne début entête ( colonne la plus à gauche ) :
excel-column-count = Nombres de colonnes du tableau
excel-group-rows = 3 - Définir : Numéro lignes de début et fin de la liste contenant les données du tableau ( dessous entête et sans inclure celle-ci )
excel-first-data-row = Première ligne contenant des données
excel-last-data-row = Dernière ligne contenant des données :
excel-group-shape = 4 - Définir : Comment votre fichier écrit les montants
excel-shape-single = Une seule colonne de montants, signée ( les dépenses en négatif )
excel-shape-debit-credit = Deux colonnes séparées : une colonne Débit et une colonne Crédit
excel-shape-note = Dans le mode à deux colonnes, le signe écrit dans la colonne Débit n'est pas pris en compte : un débit sort toujours de l'argent, qu'il soit noté « -50 » ou « 50 ».
excel-group-test = 5 - Rendu Test : Visualisez la capture effectuée en fonction de votre paramétrage
excel-test = Testez les paramètres que vous avez définis aux étapes 2, 3 et 4.
excel-test-note = Indication : Le nom des entêtes et le contenu du tableau ci-dessous doivent correspondre à ceux de votre tableau Excel. La zone de capture ne doit pas déborder en dehors de la zone du tableau.

excel-help = Descendez les cinq groupes dans l'ordre, puis testez : vous ne pourrez passer à l'étape 2 qu'après avoir regardé ce que la zone attrape.
excel-no-file = Désignez d'abord le fichier Excel à importer.
excel-not-tested = Réglages modifiés : relancez le rendu test avant de valider.
excel-tested = Zone capturée : { $rows } lignes, { $columns } colonnes. Vérifiez que le tableau ci-dessous ressemble à votre feuille.
excel-empty-capture = La zone que vous avez déclarée n'attrape aucune ligne : vérifiez les numéros de ligne et de colonne.
excel-title-next = Passer à l'étape suivante
excel-into-account = Importation dans le compte { $account }.

excel-tab-links = Liens entre champs
excel-tab-settings = Parametres d'importation
excel-column-excel = Entete_Excel
excel-column-radinus = Rubrique_Radinus
excel-links-help = En face de chaque colonne de votre feuille, dites quelle rubrique de Radinus elle alimente. Les colonnes laissées à [IGNORE] ne sont pas importées.
excel-group-category = Categories sans correspondances
excel-group-payment-mode = Mode de paiement sans correspondances
excel-group-assignment = Affectation sans correspondances
excel-policy-create = { $kind ->
    [payment-mode] Créer automatiquement les mode de paiement inexistants
    [assignment] Créer automatiquement les affectations inexistantes
   *[category] Créer automatiquement les catégories inexistantes
}
excel-policy-ask = { $kind ->
    [payment-mode] Demander pour chaque mode de paiement inexistants où transférer les données
    [assignment] Demander pour chaque affectations inexistantes où transférer les données
   *[category] Demander pour chaque catégories inexistantes où transférer les données
}
excel-policy-blank = { $kind ->
    [payment-mode] Laisser le mode de paiement vierge
    [assignment] Laisser l'affectation vierge
   *[category] Laisser la catégorie vierge
}
excel-policy-default = { $kind ->
    [payment-mode] Transférer les mode de paiements inexistants dans un mode de paiement par défaut
    [assignment] Transférer les affectations inexistantes dans une affectation par défaut
   *[category] Transférer les catégories inexistantes dans une catégorie par défaut
}
excel-define-destination = Définir destination
excel-not-linked = { $kind ->
    [payment-mode] Aucune colonne n'alimente le mode de paiement : ce réglage ne s'applique pas.
    [assignment] Aucune colonne n'alimente l'affectation : ce réglage ne s'applique pas.
   *[category] Aucune colonne n'alimente la catégorie : ce réglage ne s'applique pas.
}
excel-fields-help = Réglez les concordances, puis les trois politiques, avant de lancer l'importation.
excel-title-import = Lancer l'importation

excel-refusal-required = Les rubriques Date, Libelle et Montant doivent obligatoirement pointer sur des colonnes excel
excel-refusal-column-twice = Des rubriques Radinus différentes pointent sur la même colonne excel : une colonne ne peut alimenter qu'une seule rubrique
excel-refusal-field-twice = Une même rubrique Radinus est associée à deux colonnes excel : elle ne peut en avoir qu'une
excel-refusal-ask-unset = { $kind ->
    [payment-mode] Vous avez choisi de demander où transférer les modes de paiement inconnus : pressez « Définir destination » avant de lancer l'importation.
    [assignment] Vous avez choisi de demander où transférer les affectations inconnues : pressez « Définir destination » avant de lancer l'importation.
   *[category] Vous avez choisi de demander où transférer les catégories inconnues : pressez « Définir destination » avant de lancer l'importation.
}

excel-column-data = Données_Excel
excel-column-destination = { $kind ->
    [payment-mode] MoyenPaiement_Radinus
    [assignment] Affectation_Radinus
   *[category] Categorie_Radinus
}
excel-association-help = En face de chaque valeur venue de votre feuille, choisissez celle de Radinus dans laquelle elle doit être rangée. Une ligne laissée vide restera sans classement.
excel-association-none = Aucune valeur inconnue : tout ce que porte votre feuille existe déjà dans Radinus.

excel-imported = Importation terminée : { $count } opérations écrites, { $refused } lignes refusées, { $created } valeurs de nomenclature créées.
excel-report-title = Compte-rendu de l'importation
excel-column-row = Ligne Excel
excel-column-content = Contenu
excel-column-reason = Raison du refus
excel-nothing-refused = Toutes les lignes de votre feuille sont entrées : aucun refus.

excel-refused-date = Date absente ou illisible
excel-refused-amount = Montant absent ou illisible
excel-refused-amount-both = Un montant dans la colonne Débit et un autre dans la colonne Crédit : impossible de choisir
excel-refused-amount-missing = Ni débit ni crédit sur cette ligne

# ---------------------------------------------------------------------------
# Phase 16 — les opérations périodiques (F15, F38, F16).
# ---------------------------------------------------------------------------

window-recurring-list-title = Liste des operations periodiques
window-recurring-form-title = Fiche définissant la règle de génération d'opération periodique
window-recurring-calendar-title = Proposition de calendrier des opérations à insérer dans vos compte bancaires

recurring-column-label = LIBELLE
recurring-none = Aucune règle périodique enregistrée.
recurring-help = Choisissez une règle, puis le calendrier pour voir les échéances qu'elle propose.
recurring-title-calendar = Proposer le calendrier des échéances
recurring-deleted = { $count ->
    [0] Aucune règle supprimée.
    [one] Une règle supprimée. Ses opérations restent dans le compte.
   *[other] { $count } règles supprimées. Leurs opérations restent dans les comptes.
}
recurring-gone = Cette règle n'existe plus.
recurring-delete-question = Supprimer les règles sélectionnées ? Les opérations qu'elles ont déjà insérées resteront dans vos comptes.

recurring-group-identity = Identification et compte bancaire concerné
recurring-group-nomenclature = Nomenclature
recurring-group-amount = Définition du montant de l'opération
recurring-group-period = Définition de la periode
recurring-group-ending = Conditions de fin de la période
recurring-group-produced = Informations sur opérations déjà insérés ( pour consultation seulement )

recurring-field-id = Identifiant de Operation
recurring-field-account = Compte cible
recurring-field-label = Libelle
recurring-field-category = Categorie
recurring-field-mode = Mode de reglement
recurring-field-assignment = Affectation
recurring-field-payee = Tiers / marchands
recurring-field-project = Projet
recurring-field-direction = Type Opération
recurring-field-amount = Montant
recurring-field-next = Date prochaine opération
recurring-field-every = Puis tout les
recurring-field-end-date = Date fin
recurring-field-repeat = Nombre répétition
recurring-field-guid = GUID Operation
recurring-field-produced-count = Nombre d'opérations insérées
recurring-field-produced-last = Date dernière opération insérée
recurring-field-produced-total = Total montants générés

recurring-unit-day = Jour
recurring-unit-week = Semaine
recurring-unit-month = Mois
recurring-unit-quarter = Trimestre
recurring-unit-year = Année
recurring-ending-no-limit = Sans limite
recurring-ending-until-date = Avec date de Fin
recurring-ending-repeat-count = Nombre répétition

recurring-title-erase = Effacer les opérations déjà insérées par cette règle
recurring-erase-question = { $count ->
    [one] Cette règle a inséré une opération dans vos comptes. Voulez-vous l'effacer ? Les soldes seront recalculés, et la règle ne reculera pas.
   *[other] Cette règle a inséré { $count } opérations dans vos comptes. Voulez-vous toutes les effacer ? Les soldes seront recalculés, et la règle ne reculera pas.
}
recurring-erase-none = Cette règle n'a encore inséré aucune opération.
recurring-erased = { $count ->
    [0] Aucune opération effacée.
    [one] Une opération effacée, soldes recalculés.
   *[other] { $count } opérations effacées, soldes recalculés.
}

recurring-calendar-help = Retirez avec la corbeille les échéances que vous ne voulez pas, puis validez pour les insérer.
recurring-calendar-none = Aucune échéance à proposer : vérifiez la date de prochaine opération et le compte de vos règles.
recurring-calendar-column-account = Compte
recurring-calendar-column-date = Date
recurring-calendar-column-label = Description
recurring-calendar-column-amount = Montant
recurring-calendar-column-category = Categorie
recurring-calendar-column-assignment = Affectation
recurring-calendar-column-mode = Mode Reglement
recurring-calendar-column-payee = Tiers
recurring-calendar-column-project = Projets
recurring-calendar-removed = { $count ->
    [one] Une échéance retirée de la proposition.
   *[other] { $count } échéances retirées de la proposition.
}
recurring-title-insert = Insérer les échéances retenues dans les comptes
recurring-nothing = Il ne reste aucune échéance à insérer.
# La question posée avant d'écrire : insérer un calendrier crée de vraies
# opérations dans de vrais comptes, et cela ne se fait pas sur un clic distrait.
recurring-insert-question = { $count ->
    [one] Insérer cette échéance dans votre compte ? Une opération sera créée et les soldes recalculés.
   *[other] Insérer ces { $count } échéances dans vos comptes ? Autant d'opérations seront créées et les soldes recalculés.
}
recurring-inserted = { $count ->
    [one] Une opération insérée. La règle repart après la dernière échéance insérée.
   *[other] { $count } opérations insérées. Les règles repartent après leur dernière échéance insérée.
}

recurring-refusal-label-required = La saisie d'un libellé est obligatoire
recurring-refusal-date-required = La saisie de la date de prochaine opération est obligatoire
recurring-refusal-date-too-old = La date de prochaine opération doit être supérieure ou égale à l'an 2000
recurring-refusal-account-gone = Le compte bancaire spécifié est introuvable, merci d'en sélectionner un nouveau pour rendre la règle applicable
recurring-refusal-end-required = En cas de date de fin, la date doit être saisie
recurring-refusal-end-before-start = La date de fin ne peut être inférieure à la date de la prochaine opération
recurring-refusal-end-too-far = L'écart entre la date de prochaine opération et la date de fin ne peut dépasser 10 000 jours

# --- Phase 15 — les impressions et états -------------------------------
# Le grand titre du bandeau, repris mot pour mot de l'état WinDev d'origine.
print-operations-title = Liste des transactions bancaires et sous-opérations
print-menu-operations-pdf = Impression dans fichier PDF
print-recap-title = Récapitulatif par catégorie
print-recap-count = Lignes
print-row-count = Nombre de lignes :
print-total-debit = Total débit :
print-total-credit = Total crédit :
print-final-balance = Solde final :
print-licence = Radinus est un logiciel libre distribué sous licence GNU GPL v3 ou ultérieure
print-nothing = Il n'y a rien à imprimer.
print-done = État imprimé et ouvert : « { $file } ».
print-failed = Impression impossible : { $reason }
# Le PDF est bien écrit, mais le système n'a pas su l'ouvrir : on le dit sans
# faire croire à un échec, puisque le fichier est là.
print-not-opened = État imprimé dans « { $file } », mais votre système n'a pas su l'ouvrir tout seul.

# --- L'état RIB (F32) --------------------------------------------------
# Les intitulés du relevé d'identité bancaire, repris du document d'origine.
rib-title = RELEVE D'IDENTITE BANCAIRE
rib-bank = Banque :
rib-national = RIB - Identifiant national de compte
rib-establishment = ETABLISSEMENT
rib-branch = GUICHET
rib-number = NUMERO DE COMPTE
rib-key = CLEF RIB
rib-domiciliation = DOMICILIATION
rib-iban = IBAN - Identifiant international de compte
rib-bic = BIC - Identifiant international de l'établissement
rib-holder = Titulaire du compte

# --- La fenêtre F32 ----------------------------------------------------
window-rib-title = Impression de RIB ( Relevé d'Identité Bancaire )
rib-group-bank = Banque
rib-group-holder = Titulaire du compte
rib-group-details = Coordonnées bancaires
rib-field-bank = Nom banque
rib-field-domiciliation = Domiciliation
rib-field-holder = Nom du titulaire
rib-field-address = Adresse
rib-field-establishment = Etablissement
rib-field-branch = Guichet
rib-field-number = Numéro compte
rib-field-key = Clé RIB
rib-field-bic = BIC (Bank Identifer Code)
rib-field-iban = IBAN (International Bank Account Number )
rib-conditions = Important conditions d'utilisations a respecter obligatoirement en cas d'impression
rib-declaration = Je soussigné l'utilisateur du logiciel declare sur l'honneur :
rib-declaration-first = - Confirme avoir vérifié auprès de ma banque que les informations bancaires contenus dans cette fenêtre sont correctes et conformes à ma volonté . Confirme de la même facon que je m'engage à verifier que les informations contenus dans l'etat d'impression du RIB sont correctes et conforme à ma volonté. Cette impression et l'utilisation du RIB se fera sous mon entière responsabilité
rib-declaration-second = - Être le titulaire du compte dont le RIB sera imprimé, et ne pas se servir des fonctions de ce logiciel dans un but contraire à la loi.
rib-title-print = Impression sur Imprimante
rib-title-pdf = Impression dans fichier PDF
# La case n'est pas un avertissement décoratif : tant qu'elle n'est pas
# cochée, les deux boutons sont éteints (arbitrage de Fabrice, 01/08/2026).
rib-declaration-required = Cochez la déclaration sur l'honneur pour pouvoir imprimer.
rib-help = Vérifiez vos coordonnées, cochez la déclaration, puis imprimez.
rib-account-gone = Ce compte bancaire est introuvable.
rib-fields-read-only = Ces coordonnées viennent de la fiche du compte : corrigez-les dans la fiche pour les changer ici.
rib-printed = RIB envoyé à votre imprimante par défaut.
rib-print-failed = Impression impossible : { $reason }
rib-pdf-done = RIB imprimé et ouvert : « { $file } ».
rib-pdf-not-opened = RIB imprimé dans « { $file } », mais votre système n'a pas su l'ouvrir tout seul.
menu-accounts-bank-details = Editer un Relevé d'Identité Bancaire

# Le choix de l'imprimante. Radinus pose la question lui-même : aucun des
# trois webviews n'ouvre le dialogue d'impression du système.
print-choose-printer = Sur quelle imprimante voulez-vous imprimer ?
print-do-print = Imprimer
rib-printed-on = RIB envoyé à l'imprimante « { $printer } ».
ui-cancel = Annuler

# Le système n'a su nommer aucune imprimante : on imprime quand même sur celle
# par défaut plutôt que de bloquer l'utilisateur.
print-printers-unknown = Votre système n'a su nommer aucune imprimante : le document est parti sur l'imprimante par défaut.

print-menu-operations-printer = Impression sur Imprimante
print-sent-on = État envoyé à l'imprimante « { $printer } ».
print-sent-default = État envoyé à votre imprimante par défaut.

# --- Phase 17 — les opérations sur la base de données -------------------
backup-archive = Archive Radinus
backup-no-database = Aucune base de données n'est ouverte.
backup-done = Sauvegarde écrite dans « { $file } ».
backup-failed = Sauvegarde impossible : { $reason }
backup-not-started = La sauvegarde n'a pas pu commencer :
restore-unreadable = Ce fichier n'est pas une archive Radinus lisible : { $reason }
# La question dit ce qui sera perdu avant de le perdre. L'archive a déjà été
# lue à ce moment : ce qu'elle annonce est certain.
restore-question = Restaurer « { $file } » ? Tout le contenu actuel de votre base sera effacé et remplacé, et ce qui s'y trouve sera perdu.
restore-done = Restauration terminée : { $accounts } comptes et { $operations } opérations.
restore-failed = Restauration impossible : { $reason }
restore-empty-fields = Champs vides lus comme valeur nulle : { $count }.

# **Remplacer une base sous un logiciel qui tourne, ça ne se rattrape pas**
# (décision de Fabrice, 03/08/2026). Une restauration et une remise à zéro
# changent tous les identifiants ; les fenêtres restées ouvertes, elles,
# gardent les leurs. Une fenêtre d'import laissée ouverte sur le compte n° 3
# écrivait ensuite dans le compte n° 3 de la base restaurée, qui n'est plus le
# même. Plutôt que de courir après chaque cas, Radinus se ferme : « on quitte
# direct, car sinon tu n'empêcheras pas que l'on puisse aller ailleurs ».

# --- Le journal des opérations techniques (phase 17) --------------------
# Les trois statuts de son Ajoute_Log, en capitales comme chez lui.
journal-status-success = SUCCES
journal-status-failure = ECHEC
journal-status-repaired = REPARE
journal-step-reindex = Réparation table BDD
journal-step-refill = Nomenclature système vide : valeurs par défaut rétablies
journal-step-table-created = Table absente de la base : recréée vide
journal-step-column-added = Colonne absente de la table : ajoutée avec sa valeur par défaut

# --- Protection par mot de passe (05/08/2026) ---
password-protect = Protection par mot de passe
window-password-form-title = Protection par mot de passe
password-ask = Cette base est protégée. Entrez son mot de passe.
password-group-database = Base concernée
password-group-password = Mot de passe
password-group-warning = À savoir avant de valider
password-field-old = Ancien mot de passe
password-field-new = Nouveau mot de passe
password-field-repeat = Répétez le nouveau mot de passe
password-hint = Laissez l'ancien vide si la base n'est pas encore protégée. Laissez les deux nouveaux vides pour retirer la protection.
password-lost-warning = Un mot de passe perdu est une base perdue : rien ne permet de la récupérer. Les sauvegardes, elles, restent en clair.
password-show = Afficher le mot de passe
password-remove-question = Retirer la protection de cette base ?
password-mismatch = Les deux saisies du nouveau mot de passe sont différentes
password-wrong = Le mot de passe ne convient pas
password-close-first = Fermez cette base avant de changer son mot de passe
password-now-protected = La base est protégée par un mot de passe
password-now-clear = La base n'est plus protégée
journal-step-date-fixed = Correction d'une opération sans date
journal-step-circular = Suppression d'une opération incohérente : référence circulaire
journal-step-flag-parent-true = Mauvais drapeau EstParent=Faux sur une opération principale
journal-step-flag-parent-false = Mauvais drapeau EstParent=Vrai sur une opération principale
journal-step-flag-child = Mauvais drapeau EstParent=Vrai sur une sous-opération
journal-step-orphan = Suppression d'une sous-opération orpheline
journal-step-third-level = Suppression d'une sous-opération rattachée à une autre sous-opération
journal-step-coherence = Recalcul général de la cohérence entre sous-opérations et opérations principales
journal-step-balances = Recalcul de tous les soldes de tous les comptes
journal-step-vacuum = Optimisation du fichier de base de données
journal-step-analyze = Mise à jour des statistiques de recherche
journal-step-backup-begin = Début de la sauvegarde de la base
journal-step-backup-end = Fin de la sauvegarde de la base
journal-step-restore-begin = Début de la restauration de la base à partir de l'archive
journal-step-restore-end = Fin de la restauration de la base à partir de l'archive
journal-step-restore-read = Lecture de l'archive

# --- La fenêtre du journal (⌘H) -----------------------------------------
window-journal-title = Journal de la dernière opération technique
journal-column-step = Étape
journal-column-file = Fichier
journal-column-table = Table
journal-column-status = Statut
journal-column-error = Erreur
journal-column-comments = Commentaires
journal-empty = Aucune opération technique n'a encore été effectuée depuis l'ouverture du logiciel.
journal-help = Le journal ne garde que la dernière opération technique : sauvegarde, restauration, réparation, effacement ou ouverture d'une base.

# --- La réparation ------------------------------------------------------
menu-file-repair-running = Réparation et optimisation en cours…
repair-done = { $anomalies ->
    [0] Réparation terminée : aucune anomalie trouvée. { $lines } étapes journalisées.
    [one] Réparation terminée : une anomalie réparée. { $lines } étapes journalisées.
   *[other] Réparation terminée : { $anomalies } anomalies réparées. { $lines } étapes journalisées.
}
repair-failed = Réparation impossible : { $reason }

journal-status-started = EN COURS
journal-status-finished = TERMINE
journal-step-backup-table = Écriture de la table dans l'archive
journal-step-backup-write = Écriture de l'archive
journal-step-backup-verified = Vérification de l'archive écrite : fichiers relus / attendus, enregistrements relus / écrits
journal-step-backup-total = Total sauvegardé : enregistrements, données, poids du fichier
journal-step-restore-table = Lecture de la table dans l'archive
journal-step-restore-missing = Fichier absent de l'archive : cette table ne sera pas restaurée
journal-step-restore-wipe = Effacement total du contenu de la base avant restauration
journal-step-restore-write = Écriture dans la base
journal-step-restore-total = Total restauré : comptes, opérations
journal-step-restore-empty-fields = Champs vides comblés à la lecture
backup-verify-mismatch = L'archive écrite ne se relit pas telle qu'elle a été écrite : ne vous y fiez pas, refaites la sauvegarde.

# --- Les pièces jointes d'une opération (F28, phase 17) -----------------
window-attachments-title = Pièces jointes de l'opération
attachment-filter = Documents acceptés
attachment-none = Cette opération ne porte aucune pièce jointe.
attachment-title-add = Joindre un document à cette opération
attachment-title-open = Ouvrir la pièce jointe
attachment-title-remove = Retirer la pièce jointe et envoyer son fichier à la corbeille
# L'état du fichier sur le disque. « Inconnu » n'est pas un aveu d'ignorance
# gratuit : les empreintes venues de Radinus 1.9.3 sont amputées par le format
# de sauvegarde, et juger un fichier dessus reviendrait à accuser au hasard.
attachment-state-ok = Intacte
attachment-state-changed = Modifiée
attachment-state-missing = Fichier absent
attachment-state-unknown = Non vérifiable
attachment-added = « { $name } » a été jointe à l'opération.
attachment-removed = Pièce jointe retirée, son fichier est dans la corbeille.
attachment-removed-kept = Pièce jointe retirée, mais son fichier n'a pas pu être mis à la corbeille.
attachment-remove-question = Retirer « { $name } » de cette opération ? Son fichier sera envoyé à la corbeille.
attachment-opened = « { $name } » a été ouverte.
attachment-opened-changed = « { $name } » a été ouverte, mais son contenu a changé depuis qu'elle a été jointe.
attachment-gone = Cette pièce jointe n'existe plus.
attachment-file-missing = Le fichier de « { $name } » est introuvable sur le disque.
attachment-failed = Opération impossible : { $reason }
attachment-save-first = Enregistrez d'abord l'opération : une pièce jointe se rattache à une opération qui existe.
attachment-refusal-missing = Ce fichier n'existe pas.
attachment-refusal-extension = Ce type de fichier n'est pas accepté. Sont acceptés : pdf, jpeg, jpg, png, bmp, tiff, gif, webp, xls, xlsx, doc, docx, odt, rtf, txt, json, xml.
attachment-refusal-operation = L'opération à laquelle joindre ce document n'existe pas.
journal-step-backup-attachments = Pièces jointes ajoutées à l'archive
journal-step-backup-attachment-missing = Pièce jointe introuvable sur le disque : elle manquera à l'archive
journal-step-restore-attachments = Pièces jointes ressorties de l'archive
attachment-title-replace = Remplacer le document de cette pièce jointe
attachment-replaced = Le document a été remplacé par « { $name } ».

# ---------------------------------------------------------------------
# F08 — le menu « Outils » de la fiche compte.
#
# Ses trois entrées sont des portages du WLangage de Fabrice (dossier
# « Information import export base piece jointe ») : le calcul du solde
# initial pointé, les statistiques du compte, et la suppression de toutes
# ses transactions. Le menu n'agit qu'en modification (arbitrage du
# 02/08/2026) : à la création il n'y a rien à compter, en consultation la
# fiche ne fait que montrer.
# ---------------------------------------------------------------------

account-tools = Outils
account-tools-initial-balance = Définir le solde initial pointé
account-tools-statistics = Statistiques compte bancaire
account-tools-delete-operations = Supprimer toutes les transactions du compte

# La question du calcul, mot pour mot celle de l'original. { $total } est le
# total des opérations pointées, déjà écrit au format monétaire.
account-initial-balance-question =
    Pour calculer le solde initial pointé au regard des opérations présentes sur ce compte, merci de renseigner le solde actuel de votre banque
    Le solde initial pointé sera calculé comme étant égale à :
    { "[" }Solde banque actuel] - [Total opération pointées ({ $total }) ].
    { "" }
    Pour ne pas avoir à ressaisir cette valeur vous devez être totalement à jour de la liste des opérations bancaires sur ce compte.

account-statistics-none = Aucune transaction

# Les quatorze lignes de son Info(). La coquille « pengagés » de l'original
# est corrigée, sur décision de Fabrice du 02/08/2026 — comme « Bank
# Identifer Code » sur cette même fiche.
account-statistics =
    Nombre de transactions totale dans ce compte : { $count }
    { "" }
    Nombre de transactions pointé dans ce compte : { $pointed }
    Montant des débits pointés : { $pointedDebits }
    Montant des crédits pointés : { $pointedCredits }
    Différence entre crédits et débits pointés : { $pointedDifference }
    { "" }
    Nombre de transactions engagés dans ce compte : { $committed }
    Montant des débits engagés : { $committedDebits }
    Montant des crédits engagés : { $committedCredits }
    Différence entre crédits et débits engagés : { $committedDifference }
    { "" }
    Nombre de transactions prévus dans ce compte : { $planned }
    Montant des débits prévus : { $plannedDebits }
    Montant des crédits prévus : { $plannedCredits }
    Différence entre crédits et débits prévus : { $plannedDifference }
    { "" }
    Transaction la plus ancienne : { $first }
    Transaction la plus récente : { $last }

# La double barrière de la suppression. { $word } est le « oui » de la langue
# courante — un hispanophone à qui l'on demanderait d'écrire OUI ne
# comprendrait pas (décision de Fabrice, 02/08/2026).
account-delete-operations-question =
    Êtes vous certain de supprimer toutes les opérations contenus dans compte bancaire ?
    Pour le confirmer écrivez { $word } dans le champ ci dessous et validez

account-delete-operations-done =
    { $count ->
        [0] Aucune transaction supprimée.
        [one] 1 transaction supprimée.
       *[other] { $count } transactions supprimées.
    }

# ---------------------------------------------------------------------
# Le sélecteur de base et le choix de la langue (02/08/2026)
#
# Décisions prises en discussion avec Fabrice : Radinus ne crée plus de
# base sans autorisation ; sans langue en configuration il demande la
# langue avant tout le reste ; est une base tout dossier de databases/
# qui contient un radinus.sqlite, quel que soit son nom.
#
# La fenêtre du choix de la langue n'a aucune clef ici : elle n'emploie
# aucune phrase, et c'est ce qui lui permet d'être comprise avant qu'on
# sache quelle langue l'utilisateur parle.
# ---------------------------------------------------------------------

window-database-selector-title = Bases de données
window-database-form-title = Nouvelle base de données
database-group-identity = Identification de la base
database-group-restore = Initialiser la base avec les données provenant d'une sauvegarde
database-choose-backup = Sélectionner fichier sauvegarde
database-no-backup = Aucune sauvegarde choisie : la base naîtra vide.

databases-column-label = Base
databases-column-comment = Commentaire
databases-column-folder = Dossier
databases-column-created = Créée le

databases-none = Aucune base pour l'instant : créez-en une.
databases-help = Choisissez la base à ouvrir, ou créez-en une nouvelle.
databases-select = Choisissez d'abord une base dans la liste.
databases-tools = Outils
databases-title-open = Ouvrir cette base

database-created = La base « { $label } » est créée.
database-field-label = Nom de la base
database-field-comment = Commentaire
database-label-required = Donnez un nom à cette base : c'est lui qui la distinguera des autres.
database-gone = Cette base n'est plus là : elle a été déplacée ou effacée depuis l'ouverture de cette fenêtre.

# La suppression d'une base (02/08/2026). Le dossier part à la corbeille du
# système, comme les pièces jointes : une base effacée par erreur se remet
# d'un clic droit. La base ouverte est refusée — Radinus tient son fichier.
databases-title-delete = Supprimer cette base
database-delete-question =
    Êtes-vous certain de supprimer la base « { $label } » ?
    { "" }
    Tout son dossier part à la corbeille : les opérations, les comptes et les pièces jointes.
    Pour le confirmer, écrivez { $word } dans le champ ci-dessous et validez.
database-in-use = Cette base est ouverte : Radinus ne peut pas la supprimer. Ouvrez-en une autre d'abord.
database-deleted = La base « { $label } » est à la corbeille.

# Le sélecteur a deux modes (Fabrice, 02/08/2026). Ouvert en cours
# d'utilisation, il ne sait plus ouvrir : une fenêtre de Radinus est bâtie une
# fois et jamais détruite, et rien ne saurait lui faire oublier la base qu'elle
# montre. On consulte, on crée, on supprime — et pour changer de base, on
# quitte.
database-quit-first = Pour ouvrir cette base, quittez Radinus et relancez-le : le sélecteur vous la proposera au démarrage.


# --- F01 — la fenêtre d'accueil (phase 17 bis, 03/08/2026) ----------------
#
# Premier ajout de la 2.0.0 sur la 1.9.3 : la fenêtre d'accueil ne porte plus
# seulement le bandeau. La règle qui la gouverne est écrite au document 04 F01 :
# c'est la vue SANS UN CLIC, et rien de ce qui demande un réglage n'y entre.
#
# Les deux titres d'anneau portent le mois entier plutôt que d'être collés bout
# à bout par la fenêtre : « Dépenses ... — août 2026 » n'a pas le même ordre de
# mots dans les trois langues, et seule Fluent sait où est le trou.

window-main-title = Radinus
welcome-month = { $month } { $year }
welcome-accounts-count = { $count ->
    [0] Aucun compte ouvert
    [one] 1 compte ouvert
   *[other] { $count } comptes ouverts
}
welcome-total-bank = Solde en banque
welcome-total-real = Solde réel
welcome-total-final = Solde final
welcome-total-real-detail = pointé + engagé
welcome-total-final-detail = pointé + engagé + prévu
welcome-accounts = Vos comptes
welcome-tile-bank = En banque
welcome-tile-real = Réel
welcome-tile-final = Final
welcome-spending = Dépenses — { $month }
welcome-earning = Gains — { $month }
ui-legend-budget-lines = Postes budgétaires
ui-legend-categories = Catégories
welcome-nothing = Aucune opération ce mois-ci.
welcome-open-account = Info : cliquez sur un compte pour ouvrir ses opérations.
welcome-no-account = Aucun compte bancaire pour l'instant.
welcome-no-account-create = Créez un compte bancaire en cliquant ici
welcome-previous-month = Mois précédent
welcome-next-month = Mois suivant
welcome-refresh = Tout relire


# --- F39 — les préférences (phase 17 ter, 03/08/2026) ---------------------
#
# La place du signe monétaire vit ici, à côté des deux séparateurs : elle suit
# la langue et non la devise. « before » met le signe devant le nombre, tout
# autre valeur le met derrière. AUCUN signe monétaire n'est écrit dans ce
# fichier : « français » ne veut pas dire « euro ».

ui-money-sign-position = after
window-preferences-title = Préférences
menu-settings-preferences = Préférences…
menu-settings-show-main = Afficher la fenêtre principale
menu-settings-folders = Accès dossiers Radinus
preferences-branch-display = Affichage
preferences-leaf-language = Langue
preferences-leaf-currency = Devise
preferences-field-language = Langue du logiciel :
preferences-field-currency = Devise affichée :
preferences-field-custom = Signe de la devise :
preferences-currency-system = Devise système
preferences-currency-euro = Euros
preferences-currency-dollar = Dollars
preferences-currency-canadian = Dollars canadiens
preferences-currency-cfa = Francs CFA
preferences-currency-cfp = Francs Pacifique
preferences-currency-swiss = Francs suisses
preferences-currency-none = Aucune
preferences-currency-custom = Personnalisé
preferences-currency-system-is = Votre système annonce :
preferences-currency-system-silent = Votre système n'annonce aucune devise : les montants s'afficheront en euros.
preferences-custom-required = Tapez le signe de votre devise avant d'enregistrer.
preferences-saved = Préférences enregistrées.
preferences-help = Choisissez une option dans l'arbre, puis enregistrez.
preferences-sign-too-long = Le signe d'une devise tient en 8 caractères au plus.
preferences-sign-not-a-number = Le signe d'une devise ne peut contenir ni chiffre, ni signe de calcul, ni virgule : Radinus les retire quand il lit un montant, et « 120 » deviendrait « 12 ».
preferences-leaf-zoom = Taille de l'affichage
preferences-field-zoom = Agrandissement :
preferences-zoom-reset = Valeur par défaut
preferences-zoom-hint = Tout grossit ensemble : le texte, les icônes, les colonnes. En dessous de 100 %, il en tient davantage à l'écran. La barre de menus du système et ses boîtes de dialogue, elles, suivent les réglages de votre ordinateur et non ceux-ci.

# --- Le bandeau de l'accueil ---------------------------------------------
#
# Ces phrases étaient écrites en dur dans `index.html` depuis la phase 0 et
# ne se traduisaient donc pas (relevé par Fabrice le 03/08/2026). La devise
# est sa voix : les versions anglaise et espagnole sont des propositions, à
# corriger par lui — un slogan ne se traduit pas mot à mot.
ui-language-tag = fr
welcome-banner-title = Radinus
welcome-mascot-alt = Radinus — l'écureuil mascotte, en costume, entouré d'un euro, d'une calculatrice et de graphiques
welcome-slogan-one = Un logiciel de gestion de finances personnelles qui vous aide à dépenser moins pour gagner plus
welcome-slogan-two = Avec Radinus vous comprendrez pourquoi les petits ruisseaux font les grandes rivières.

# --- « À propos de l'auteur » --------------------------------------------
#
# Le nom et l'adresse sont écrits à l'identique dans les trois fichiers : ils
# ne se traduisent pas. Ils sont ici malgré tout, et non dans la page, pour que
# la vue ne porte aucune phrase — et pour qu'ils se corrigent à un seul endroit
# le jour où l'auteur déménage.
about-author-name = Auteur : Fabrice Garcia
about-author-place = 20290 Borgo, Corsica, France
window-about-author-title = À propos de l'auteur
about-author-flag-alt = Drapeau de la Corse — la tête de Maure

# --- « À propos de Radinus » ---------------------------------------------
#
# `about-radinus-version` porte un trou : le numéro vient du binaire qui
# tourne, jamais d'une chaîne recopiée. Elle n'est donc pas dans le
# dictionnaire des fenêtres — c'est la commande `app_version` qui la remplit.
window-about-radinus-title = À propos de Radinus
about-radinus-name = Radinus
about-radinus-version = Version { $version }
about-radinus-rust-alt = Le logo du langage Rust
about-radinus-tauri-alt = Le logo de Tauri
about-radinus-built = Radinus est écrit en Rust et bâti avec Tauri. Le premier calcule vos comptes, le second en fait une application de bureau.
about-radinus-licence = Logiciel libre, sous licence GNU GPL v3.

# --- « Licence d'utilisation » (08/08/2026) -------------------------------
#
# The window names the licence and says, in four lines, what it gives the
# person using Radinus. The legal text itself is not translated here: the
# button opens the official page, published and maintained by the Free
# Software Foundation, which knows its own wording better than we do.
window-licence-title = Licence d'utilisation
licence-heading = LICENCE D'UTILISATION DU LOGICIEL RADINUS
licence-logo-alt = Le logo de la GNU General Public License version 3
licence-name = GNU GPL v3 ou ultérieure
licence-intro = Radinus est un logiciel libre.
licence-freedoms-title = Sa licence vous donne quatre libertés :
licence-freedom-use = L'utiliser comme vous voulez, pour ce que vous voulez.
licence-freedom-study = En étudier le code source, qui est ouvert à tous.
licence-freedom-share = Le copier et le donner autour de vous.
licence-freedom-improve = Le modifier, et partager vos modifications.
licence-read = Lire le texte complet de la licence

# The two notices the GPL asks an interactive interface to display, next
# to the right to redistribute and the way to read the licence, which the
# window already carried (LICENSE, definition of « Appropriate Legal
# Notices »). The copyright is a name and a year: identical everywhere,
# here all the same so that the view holds no sentence of its own.
licence-copyright = Copyright © 2026 Fabrice Garcia
licence-no-warranty = Ce logiciel est fourni sans aucune garantie, dans la mesure permise par la loi.
licence-info = Le texte officiel s'ouvre dans votre navigateur, sur gnu.org.
