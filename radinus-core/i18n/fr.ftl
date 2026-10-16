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
menu-statistics-balance-analysis = Analyse Évolution du solde
menu-statistics-by-category = Stat par catégories
menu-statistics-by-assignment = Stat par affectations
menu-statistics-by-budget-line = Stat par postes budgétaires
menu-statistics-by-payment-mode = Stat par moyens de paiement
menu-statistics-by-payee = Stat par tiers et marchands
menu-statistics-by-project = Stat par projets
menu-statistics-by-verification = Stat par vérifications
menu-statistics-dashboard = Tableau de bord des opérations
menu-statistics-crossed-balance = Bilan croisé

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

# Le menu Outils (Fabrice, 09/10/2026), entre Nomenclatures et Paramètres.
menu-tools = Outils
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
operations-column-status = Statut opération
# Les trois statuts d'une opération, par leur clef dans StatutOperation
# (1, 2, 3). Le libellé stocké en base n'est plus affiché.
operation-status-pointed = Pointé
operation-status-committed = Engagé
operation-status-planned = Prévu
# Base 11 — la vérification : ce que l'utilisateur pense d'une écriture, à côté
# du statut, qui dit ce que la banque en a fait (Fabrice, 03/10/2026). Quatre
# valeurs repérées par leur clef dans Verification : 1, 2, 3, 4.
operations-column-verification = Vérification
operation-verification-to-verify = À vérifier
operation-verification-verified = Vérifiée
operation-verification-doubtful = Douteuse
operation-verification-disputed = Contestée
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
filter-by-status = Filtre Statut
filter-by-verification = Filtre Vérification
filter-show-all = Afficher tout

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
operation-field-verification = Vérification
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
operation-clearing-date-required = Une opération pointée doit obligatoirement porter une date de pointage.
operation-clearing-date-question =
    Une opération pointée doit obligatoirement porter une date de pointage.
    Voulez-vous enregistrer avec la date de l'opération, le { $date } ?
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
    [0] Aucune opération à pointer : la sélection est déjà pointée.
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
operations-recurring-from = Créer une opération périodique à partir de cette opération

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
    [verification] Statistiques par vérification
   *[category] Statistiques par categorie
}

statistics-axis-column = { $kind ->
    [assignment] Affectation
    [budget-line] PosteBudget
    [payment-mode] ModeOperation
    [payee] Tiers
    [project] Projets
    [verification] Vérification
   *[category] NomCategorie
}

statistics-unclassified = { $kind ->
    [assignment] Sans affectation
    [budget-line] Sans poste budgetaire
    [payment-mode] Sans moyen de paiement
    [payee] Sans tiers
    [project] Sans projet
    [verification] À vérifier
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

# --- F27, le bilan croisé (Fabrice, 25/08/2026) ---------------------
# Les catégories en lignes, les affectations en colonnes, sur un mois.
# Tout le reste de son vocabulaire est celui des statistiques : Total,
# Somme, les interrupteurs, « Sans … », les colonnes du détail.
window-crossed-balance-title = Bilan croisé
crossed-balance-window-name = Bilan croisé
crossed-balance-column = Categorie
crossed-balance-no-data = Aucune opération sur ce mois pour les comptes choisis.
crossed-balance-month-question = Sur quel mois voulez-vous travailler ? Un nombre entre { $first } et { $last }.
crossed-balance-month-choose = Choisir le mois
crossed-balance-next = Mois suivant
crossed-balance-previous = Mois précédent

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
export-to = Exporter vers
# Copying from a table (Fabrice, 07/10/2026): the two entries at the head of
# the right-click menu, and what is said when the clipboard refuses.
copy-cell = Copier la cellule
copy-rows = Copier les lignes sélectionnées
copy-failed = La copie dans le presse-papiers a échoué.
export-all-years-excel = Exporter toutes les années vers Excel
export-all-years-ods = Exporter toutes les années vers LibreOffice Calc
export-all-months-excel = Exporter tous les mois de l'année affichée vers Excel
export-all-months-ods = Exporter tous les mois de l'année affichée vers LibreOffice Calc
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
    [verification] Statistiques par vérification
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

# F40 — « Analyse Évolution du solde » (Fabrice, 05/10/2026): the chart of F25,
# on which one drags a zone, and under it the operations of that zone. The
# chart's own words are F25's (curve-*); these are the summary of the zone.
window-analysis-title = Analyse de l'évolution du solde
analysis-heading = Analyse de l'évolution du solde
analysis-hint = Tracez une zone sur le graphique, bouton de la souris enfoncé, pour voir les opérations de cette période.
analysis-zone = Zone :
analysis-opening = Solde au début :
analysis-closing = Solde à la fin :
analysis-variation = Variation :
analysis-detail-name = Analyse du solde
analysis-detail-none = Aucune opération dans cette zone.

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
quick-check-verification = Vérification
quick-column-date = Date
quick-column-label = Libelle
quick-column-amount = Montant
quick-column-category = Categorie
quick-column-assignment = Affectation
quick-column-payment-mode = Mode Paiement
quick-column-payee = Tiers
quick-column-project = Projets
quick-column-status = Status
quick-column-verification = Vérification
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
statement-title-open = Ouvrir un fichier de relevé (OFX, QIF, CSV)
statement-title-info = Informations sur le fichier ouvert
statement-title-integrate = Intégrer la sélection dans le compte
statement-title-validate = Intégrer cette opération dans le compte
statement-duplicate = Attention doublon : cette transaction semble deja avoir été intégrée à la base (Financial Institution Transaction ID existe)
statement-no-fitid = Attention : ce fichier ne donne aucun identifiant (FITID) pour cette ligne. Un doublon ne pourra pas être détecté.
statement-loaded = { $count ->
    [0] Ce fichier ne contient aucune opération pour ce compte.
   *[other] { $count } lignes lues, dont { $known } déjà présentes dans votre compte.
}
statement-loaded-unidentified = { $alike ->
    [0] { $count } lignes lues ; aucune ne ressemble à une opération déjà présente dans votre compte.
    [one] { $count } lignes lues, dont une qui ressemble à une opération déjà présente dans votre compte (même date, même libellé, même montant).
   *[other] { $count } lignes lues, dont { $alike } qui ressemblent à des opérations déjà présentes dans votre compte (même date, même libellé, même montant).
}
statement-loaded-also-alike = { $alike ->
    [one] Une autre ressemble à une opération déjà présente (même date, même libellé, même montant).
   *[other] { $alike } autres ressemblent à des opérations déjà présentes (même date, même libellé, même montant).
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
statement-qif-question = Rien dans ce fichier ne dit si la date « { $date } » s'écrit jour/mois ou mois/jour. Elle veut dire :
statement-qif-day-month = Jour { $day }, mois { $month } (jour/mois)
statement-qif-month-day = Jour { $day }, mois { $month } (mois/jour)
statement-qif-dates-mixed = Ce fichier écrit ses dates de deux façons : « { $first } » se lit jour/mois, « { $second } » mois/jour. Il n'est pas importé, pour ne fausser aucune date.
statement-qif-amounts-mixed = Ce fichier écrit ses montants de deux façons : « { $first } » avec un point, « { $second } » avec une virgule. Il n'est pas importé, pour ne fausser aucun montant.
statement-qif-opening = Solde initial de { $amount } au { $date } : ce n'est pas une opération, il n'est pas importé.
statement-qif-opening-undated = Solde initial de { $amount } : ce n'est pas une opération, il n'est pas importé.
statement-qif-suspect = La ligne { $rank }, « { $label } » ({ $amount }), ressemble à un solde initial : vérifiez-la avant de l'intégrer.
statement-qif-rejected = { $count ->
    [one] Une ligne illisible n'est pas importée : { $lines }.
   *[other] { $count } lignes illisibles ne sont pas importées : { $lines }.
}
statement-qif-reason-date = date
statement-qif-reason-amount = montant
statement-qif-reason-differ = montants contradictoires
statement-qif-no-account = Ce compte n'est plus dans le fichier : rouvrez le fichier.
statement-balance-unknown = non indiqué dans le fichier
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
# Une base qui refuse de s'ouvrir, dite dans la langue de l'interface (Fabrice,
# 03/10/2026) : ces trois phrases étaient écrites en anglais dans le code.
database-too-recent = Cette base a été enregistrée par une version plus récente de Radinus (base version { $found } ; cette version lit jusqu'à la version { $supported }). Mettez Radinus à jour pour l'ouvrir.
database-not-radinus = Ce fichier n'est pas une base Radinus.
database-unreadable = La base n'a pas pu être lue : { $reason }
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
# The tick box of an account on the home window (Fabrice, 07/10/2026), and the
# line that says so when not every account is counted. No plural on purpose:
# « counted: 3 of 5 » reads the same whatever the numbers.
welcome-accounts-counted = Comptes comptés dans les totaux : { $count } sur { $total }
welcome-tile-counted = Compter ce compte dans les totaux
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
preferences-branch-import = Importation
preferences-leaf-verification = Vérification
preferences-field-verification = Opérations importées :
preferences-verification-hint = « Vérifiée » : vous faites confiance à votre banque, une opération importée est tenue pour bonne. « À vérifier » : chaque opération importée attend votre contrôle ; vous la passez ensuite vous-même à « Vérifiée » dans la liste des opérations. Ce réglage ne vaut que pour les imports à venir.
preferences-leaf-qif = Relevés QIF
preferences-field-qif-order = Ordre du jour et du mois :
preferences-qif-order-ask = Me demander à chaque fois
preferences-qif-order-day-month = Toujours jour/mois (05/03 = 5 mars)
preferences-qif-order-month-day = Toujours mois/jour (05/03 = 3 mai)
preferences-qif-order-help = Ne sert que si aucune date du fichier ne permet de trancher. Dès qu'une date comme 24/11 prouve l'ordre, c'est le fichier qui décide, quel que soit ce réglage.
preferences-field-qif-label = Libellé de l'opération :
preferences-qif-label-both = Tiers + mémo
preferences-qif-label-payee = Tiers seul
preferences-qif-label-memo = Mémo seul
preferences-qif-label-help = Quand une opération porte à la fois un tiers et un mémo. Si elle n'en porte qu'un, c'est celui-là qui sert, quel que soit ce réglage.
preferences-qif-hint = Ces réglages valent pour tous les relevés QIF, quelle que soit la base ouverte. « Me demander à chaque fois » est le plus sûr : un fichier dont les dates sont ambiguës n'est jamais lu au hasard.

# The columns of a table (Fabrice, 04/10/2026): each user has his own. The
# first is the last entry of the right-click menu on a table's header; the
# others are the « Table columns » leaf of the preferences, one line per
# table whose columns can be arranged, a « Reset » button facing it.
columns-reset = Rétablir les colonnes par défaut
# The header menu's two sub-menus (Fabrice, 05/10/2026). « columns-colour » is
# followed by the column's own title, hence its colon. Then the nine tints a
# column can take, and the entry that takes it off.
columns-show-hide = Afficher/Masquer
columns-colour = Colorer la colonne :
columns-colour-none = Aucune couleur
columns-colour-red = Rouge
columns-colour-orange = Orange
columns-colour-pink = Rose
columns-colour-pastel-green = Vert pastel
columns-colour-green = Vert
columns-colour-pastel-blue = Bleu pastel
columns-colour-blue = Bleu
columns-colour-pastel-yellow = Jaune pastel
columns-colour-yellow = Jaune
preferences-leaf-columns = Colonnes des tableaux
preferences-table-operations-list = Liste des opérations
preferences-columns-reset = Réinitialiser
preferences-columns-reset-all = Tout réinitialiser
preferences-columns-done = Les colonnes ont retrouvé leur disposition d'origine.
preferences-columns-hint = Chaque tableau retient l'ordre de ses colonnes, celles que vous masquez et leur largeur. « Réinitialiser » lui rend sa disposition d'origine, tout de suite.

# The reset of the comfort settings (Fabrice, 07/10/2026): columns, home
# window, display size — and nothing else.
preferences-branch-reset = Réinitialisation
preferences-leaf-comfort = Réglages de confort
preferences-comfort-reset = Réinitialiser les réglages de confort
preferences-comfort-hint = Remet d'origine les colonnes de tous les tableaux, l'ordre et les cases des comptes de l'accueil, et la taille de l'affichage. La langue, la devise et la vérification des opérations importées ne sont pas touchées.
preferences-comfort-question = Réinitialiser les réglages de confort ? Les colonnes des tableaux, l'accueil et la taille de l'affichage reviendront à leur état d'origine.
preferences-comfort-done = Les réglages de confort ont été réinitialisés.

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

# --- F41 — Simulation de crédit (Fabrice, 08/10/2026) ------------------------
# Le calcul d'un prêt à taux fixe, et ce que l'historique de la base dit de la
# capacité à le rembourser. Les phrases sont écrites par le noyau ; la fenêtre
# n'en compose aucune.
menu-tools-loan-simulation = Simulation de crédit
window-loan-title = Simulation de crédit
loan-tab-credit = Le crédit
loan-tab-afford = Puis-je le rembourser ?
loan-field-kind = Type de crédit
loan-kind-consumer = Crédit à la consommation
loan-kind-mortgage = Crédit immobilier
loan-field-amount = Montant emprunté
loan-field-payment = Mensualité
loan-field-months = Durée
loan-field-rate = Taux débiteur fixe
loan-field-fees = Frais de dossier
loan-field-insurance = Assurance par mois
loan-unit-months = mois
loan-unit-percent = %
loan-invalid-field = Cette valeur n'est pas un nombre : corrigez-la pour relancer le calcul.
loan-report-button = Rapport PDF
loan-monthly-table = Tableau mois par mois
loan-months-count = { $count ->
        [one] { $count } mois
       *[other] { $count } mois
    }
loan-percent = { $value } %
loan-notice-payment-too-low = Cette mensualité ne couvre pas les intérêts : le crédit ne serait jamais remboursé. La durée reste à 600 mois.
loan-notice-too-long = Cette mensualité demanderait plus de 600 mois : la durée reste à 600 mois.
loan-figure-payment = Mensualité
loan-figure-payment-insured = Mensualité assurance comprise
loan-figure-taeg = TAEG
loan-figure-interest = Coût des intérêts
loan-figure-insurance = Coût de l'assurance
loan-figure-cost = Coût total du crédit
loan-figure-total-due = Montant total dû
loan-figure-all-in = Total remboursé, assurance comprise
loan-part-capital = Capital emprunté
loan-part-interest = Intérêts
loan-part-fees = Frais de dossier
loan-part-insurance = Assurance
loan-donut-cost-caption = au total
loan-chart-cost = Ce que coûte ce crédit
loan-chart-capital = Capital restant dû
loan-schedule-title = Tableau d'amortissement
loan-schedule-yearly = Tableau d'amortissement, année par année
loan-column-number = N°
loan-column-year = Année
loan-column-date = Échéance
loan-column-payment = Mensualité
loan-column-payments = Échéances
loan-column-interest = Intérêts
loan-column-capital = Capital
loan-column-insurance = Assurance
loan-column-remaining = Capital restant dû
loan-history-label = Période étudiée
loan-period-last-12 = 12 derniers mois
loan-accounts-title = Comptes étudiés
loan-period-title = Période
loan-column-account = Compte
loan-column-bank = Banque
loan-column-balance = Solde réel
loan-unavailable-no-account = Cochez au moins un compte pour étudier votre historique.
loan-unavailable-no-month = Cette période n'a encore aucun mois complet : choisissez-en une autre.
loan-verdict-title = En résumé
loan-verdict-green = Jouable
loan-verdict-orange = Serré
loan-verdict-red = Risqué
loan-verdict-no-income = Aucun revenu sur cette période : l'endettement ne se calcule pas.
loan-check-debt-green = Endettement de { $ratio } : sous le seuil de { $green } de cette méthode.
loan-check-debt-orange = Endettement de { $ratio } : entre { $green } et { $red }, à la limite.
loan-check-debt-red = Endettement de { $ratio } : au-delà de { $red }.
loan-check-effort = La mensualité de { $payment } prend { $share } de ce que vous mettez de côté { $kind ->
        [good] un bon mois
        [hard] un mois difficile
       *[usual] un mois habituel
    } ({ $margin }).
loan-check-effort-none = { $kind ->
        [good] Un bon mois
        [hard] Un mois difficile
       *[usual] Un mois habituel
    } ne vous laisse rien de côté : la mensualité de { $payment } serait prise sur votre réserve.
loan-check-reserve-green = Votre solde reste positif jusqu'à la fin du crédit.
loan-check-reserve-red = Votre solde passerait sous zéro en { $month }, à cause de ce crédit.
loan-check-reserve-sooner = Votre solde passerait sous zéro en { $month }, { $count ->
        [one] un mois
       *[other] { $count } mois
    } plus tôt que sans ce crédit.
loan-check-reserve-anyway = Votre solde passerait sous zéro vers { $month } même sans ce crédit, qui n'y change presque rien.
loan-check-reserve-floor-green = Votre solde reste au-dessus de votre réserve de sécurité ({ $floor }) jusqu'à la fin du crédit.
loan-check-reserve-floor-red = Votre solde passerait sous votre réserve de sécurité ({ $floor }) en { $month }, à cause de ce crédit.
loan-check-reserve-floor-sooner = Votre solde passerait sous votre réserve de sécurité ({ $floor }) en { $month }, { $count ->
        [one] un mois
       *[other] { $count } mois
    } plus tôt que sans ce crédit.
loan-check-reserve-floor-anyway = Votre solde passerait sous votre réserve de sécurité ({ $floor }) vers { $month } même sans ce crédit, qui n'y change presque rien.
loan-warning-deficit = Attention : sur cette période, vos dépenses dépassent déjà vos revenus de { $amount } par mois en moyenne, avant tout crédit.
loan-figure-reference = Épargne { $kind ->
        [good] d'un bon mois
        [hard] d'un mois difficile
       *[usual] d'un mois habituel
    }
loan-figure-tipped = Mois que le crédit ferait passer dans le rouge
loan-gauge-caption = d'endettement
loan-figure-income = Revenus moyens par mois
loan-figure-spending = Dépenses moyennes par mois
loan-figure-saving = Épargne moyenne par mois
loan-figure-running = Crédits en cours par mois
loan-figure-new = Nouvelle mensualité, assurance comprise
loan-figure-rest = Reste à vivre par mois
loan-figure-debt = Taux d'endettement
loan-red-months-value = { $count } sur { $total }
loan-figure-balance-now = Solde réel aujourd'hui
loan-figure-balance-end = Solde projeté en fin de crédit
loan-chart-income = Où va votre revenu moyen
loan-donut-income-caption = revenu moyen
loan-part-spending = Dépenses courantes
loan-part-running = Crédits en cours
loan-part-new = Nouveau crédit
loan-part-rest = Reste
loan-part-missing = Il manque
loan-chart-history = Votre historique avec ce crédit
loan-chart-history-hint = Ce qui serait resté chaque mois, la mensualité payée. En rouge vif, les mois que le crédit ferait passer dans le rouge ; en rouge pâle, ceux qui y étaient déjà sans lui.
loan-chart-projection = Votre solde projeté
loan-mark-loan-end = Fin : { $label }
loan-mark-negative = Dans le rouge
loan-mark-floor = Sous la réserve
loan-mark-floor-line = Réserve de sécurité
loan-running-title = Crédits en cours retenus
loan-running-column-label = Opération périodique
loan-running-column-monthly = Par mois
loan-running-column-end = Dernière échéance
loan-no-running = Aucun crédit en cours reconnu parmi vos opérations périodiques.
loan-period-caption = de { $from } à { $to } ({ $count ->
        [one] { $count } mois
       *[other] { $count } mois
    })
loan-transfers = { $count ->
        [0] Aucun virement entre vos comptes cochés n'a été reconnu.
        [one] Un virement entre vos comptes cochés a été reconnu et mis de côté.
       *[other] { $count } virements entre vos comptes cochés ont été reconnus et mis de côté.
    }
loan-method = Moyennes sur les mois complets de la période, opérations pointées et engagées, sans les virements entre vos comptes cochés.
loan-report-title = Simulation de crédit
loan-report-made-on = simulation du { $date }
loan-disclaimer = Simulation indicative, sans valeur contractuelle. Seule l'offre de la banque fait foi.
loan-tab-rules = Réglages du jugement
loan-method-optimistic = Optimiste
loan-method-neutral = Neutre
loan-method-severe = Sévère
loan-method-line = Méthode de jugement : { $method }
loan-method-verdict = { $method } : { $verdict }
loan-rules-intro = Le verdict répond à trois questions, et chaque méthode y met ses propres exigences. Choisissez celle qui vous ressemble : le verdict de l'onglet « Puis-je le rembourser ? » la suit. La dernière ligne suppose que vos dépenses augmentent chaque année du pourcentage indiqué ; la mensualité, elle, ne bouge pas.
loan-rule-row-debt = Endettement accepté
loan-rule-row-reference = Épargne de référence
loan-rule-row-share = Part de cette épargne que la mensualité peut prendre
loan-rule-row-floor = Seuil que le solde ne doit pas franchir
loan-rule-row-sooner = Si le solde le franchit même sans le crédit
loan-rule-row-growth = Hausse de vos dépenses par an
loan-rule-limits = vert jusqu'à { $green }, orange jusqu'à { $red }
loan-rule-reference = { $kind ->
        [good] un bon mois
        [hard] un mois difficile
       *[usual] un mois habituel
    } : { $amount }
loan-rule-floor-zero = zéro
loan-rule-floor-cushion = un mois de dépenses : { $amount }
loan-rule-sooner = orange s'il l'avance de { $orange }, rouge de { $red }
loan-unit-percent-year = % par an
loan-method-optimistic-explain = La méthode optimiste suppose un bon mois, accepte un endettement jusqu'à 40 % et ne garde aucune réserve : elle dit ce qui est possible si tout se passe bien.
loan-method-neutral-explain = La méthode neutre suppose un mois habituel et suit la règle des banques, 33 à 35 % d'endettement : c'est le jugement de référence.
loan-method-severe-explain = La méthode sévère suppose un mois difficile et garde un mois de dépenses en réserve pour un imprévu : elle dit ce qui tient même si les choses se passent mal.

# --- F42 — Consommation d'un appareil électrique (Fabrice, 09/10/2026) -------
# Ce que coûte un appareil, allumé et en veille, en heures pleines et en
# heures creuses. Le tarif est une préférence de la base (« tarif.electricite »).
menu-tools-appliance-cost = Consommation d'un appareil électrique
window-appliance-title = Consommation d'un appareil électrique
appliance-device-title = L'appareil
appliance-on-title = Allumé
appliance-standby-title = En veille
appliance-field-on-watts = Puissance en marche
appliance-field-on-hours = Durée de marche par jour
appliance-field-days = Jours d'utilisation par semaine
appliance-field-share = Part de la marche en heures creuses
appliance-field-standby-watts = Puissance en veille
appliance-field-standby-hours = Durée de veille par jour d'utilisation
appliance-unit-watts = W
appliance-unit-hours = h
appliance-unit-days = sur 7
appliance-unit-percent = %
appliance-unit-price = { $sign }/kWh
appliance-standby-hint = Laissée vide, la veille dure le reste de la journée. Les jours sans usage, l'appareil reste branché : tout ce temps compte en veille. Débranché, sa veille est de 0 W.
appliance-contract-title = Votre contrat
appliance-field-option = Option tarifaire
appliance-option-base = Base (un seul prix)
appliance-option-off-peak = Heures pleines / Heures creuses
appliance-field-base = Prix du kWh
appliance-field-peak = Prix du kWh en heures pleines
appliance-field-off-peak = Prix du kWh en heures creuses
appliance-field-off-peak-hours = Heures creuses par jour
appliance-contract-hint = Ces prix ne valent que pour ce calcul. Le tarif enregistré se règle dans Paramètres › Préférences › Outils.
appliance-contract-reset = Reprendre le tarif enregistré
appliance-period-day = Par jour
appliance-period-month = Par mois
appliance-period-year = Par an
appliance-energy = { $value } kWh
appliance-less-than = moins de { $amount }
appliance-detail-title = Le détail sur un an
appliance-column-part = Poste
appliance-column-energy = Énergie
appliance-column-cost = Coût
appliance-column-share = Part
appliance-line-on = Allumé
appliance-line-standby = En veille
appliance-line-on-peak = Allumé, heures pleines
appliance-line-on-off-peak = Allumé, heures creuses
appliance-line-standby-peak = En veille, heures pleines
appliance-line-standby-off-peak = En veille, heures creuses
appliance-line-total = Total
appliance-chart-title = Où part l'argent
appliance-chart-caption = par an
appliance-standby-sentence = La veille seule coûte { $amount } par an : { $share } de ce que coûte l'appareil.
appliance-note-plate = La puissance inscrite sur l'appareil ou dans sa notice est un maximum : en marche, la plupart des appareils consomment moins. Pour un chiffre réel, mesurez-le avec une prise wattmètre et reportez ce qu'elle indique.
appliance-note-subscription = L'abonnement n'est pas compté : on le paie, que l'appareil soit branché ou non.
appliance-invalid-watts = Une puissance de 0 à 100 000 W, s'il vous plaît.
appliance-invalid-hours = Une durée de 0 à 24 heures par jour, s'il vous plaît.
appliance-invalid-days = Un nombre entier de jours, de 0 à 7, s'il vous plaît.
appliance-invalid-share = Une part de 0 à 100 %, s'il vous plaît.
appliance-invalid-day-overflow = La marche et la veille dépassent 24 heures par jour.
appliance-invalid-price = Un prix du kWh de 0 à 100, s'il vous plaît.
appliance-invalid-off-peak-hours = Un nombre entier d'heures creuses, de 0 à 24, s'il vous plaît.
preferences-branch-tools = Outils
preferences-leaf-electricity = Tarif d'électricité
preferences-electricity-blue = Revenir au Tarif Bleu EDF
preferences-electricity-hint = Le tarif de votre contrat, repris par l'outil « Consommation d'un appareil électrique ». Par défaut : le Tarif Bleu d'EDF au 1er août 2026, prix TTC, compteur de 3 à 6 kVA. Ces prix changent souvent en février et en août : recopiez ceux de votre facture.

# --- F43 — Mon matelas de sécurité (Fabrice, 09/10/2026) -------------------------
# Combien de mois l'épargne tiendrait si les revenus s'arrêtaient. Les
# phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-safety-cushion = Mon matelas de sécurité
window-cushion-title = Mon matelas de sécurité
cushion-question = Si vos revenus s'arrêtaient demain, combien de mois tiendriez-vous avec votre épargne ?
cushion-accounts-title = Vos comptes
cushion-column-account = Compte
cushion-column-balance = Solde réel
cushion-column-savings = Épargne
cushion-column-spending = Dépenses
cushion-accounts-hint = « Épargne » : l'argent sur lequel vous comptez en cas de coup dur. « Dépenses » : les comptes d'où partent les dépenses du quotidien.
cushion-history-label = Période étudiée
cushion-backup-label = Revenu de secours par mois
cushion-backup-hint = Ce qui continuerait d'arriver : allocation chômage, salaire du conjoint… Vide : aucun revenu.
cushion-categories-title = Les dépenses retenues
cushion-categories-hint = Décochez ce que vous couperiez en cas de coup dur.
cushion-categories-empty = Aucune dépense sur cette période.
cushion-verdict-title = Votre matelas
cushion-targets-title = Les seuils de prudence
cushion-projection-title = Votre épargne en cas de coup dur
cushion-projection-hint = Ce qui resterait chaque mois si vos revenus s'arrêtaient aujourd'hui.
cushion-note = Une estimation tirée de votre historique : les dépenses d'un mois difficile peuvent différer de la moyenne.
cushion-invalid-backup = Ce montant n'est pas lisible : corrigez-le pour relancer le calcul.
cushion-no-spending-account = Cochez au moins un compte « Dépenses ».
cushion-no-month = Cette période n'a encore aucun mois complet.
cushion-months = { $value } mois
cushion-per-month = { $amount } par mois
cushion-figure-holds = Sans limite
cushion-gauge-caption = de dépenses couvertes
cushion-verdict-short = Moins de trois mois : un coup dur vous mettrait vite en difficulté.
cushion-verdict-fair = Entre trois et six mois : un matelas correct, à étoffer si vous le pouvez.
cushion-verdict-solid = Six mois ou plus : votre matelas est solide.
cushion-verdict-holds = Votre revenu de secours couvre vos dépenses : votre épargne ne fondrait pas.
cushion-verdict-nothing = Aucune dépense retenue sur la période : il n'y a rien à couvrir.
cushion-tile-savings = Épargne disponible
cushion-tile-spending = Dépenses retenues
cushion-tile-backup = Revenu de secours
cushion-tile-burn = L'épargne fondrait de
cushion-tile-rhythm = Rythme d'épargne
cushion-burn-none = Rien
cushion-target-title = { $months } mois de dépenses : { $amount }
cushion-target-reached = Atteint.
cushion-target-date = Il manque { $missing }. À votre rythme d'épargne, atteint vers { $month }.
cushion-target-never = Il manque { $missing }. Votre épargne n'a pas grossi sur la période : à ce rythme, ce seuil ne sera pas atteint.
cushion-mark-empty = À sec : { $month }
cushion-period = Moyenne de { $count ->
        [one] { $count } mois complet
       *[other] { $count } mois complets
    }, de { $from } à { $to }. { $transfers ->
        [0] Aucun virement entre vos comptes.
        [one] Un virement entre vos comptes, non compté comme dépense.
       *[other] { $transfers } virements entre vos comptes, non comptés comme dépenses.
    }

# --- F44 — Objectif Épargne (Fabrice, 10/10/2026) --------------------------------
# Quand aurai-je ce montant, combien aurai-je à cette date, combien épargner.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-savings-goal = Objectif Épargne
window-goal-title = Objectif Épargne
goal-accounts-title = Les comptes suivis
goal-column-account = Compte
goal-column-balance = Solde réel
goal-accounts-hint = Un virement entre deux comptes suivis s'annule ; un virement vers un compte non suivi compte comme une sortie.
goal-period-label = Période de référence
goal-period-range = Plage d'années…
goal-range-from = de
goal-range-to = à
goal-question-title = Votre question
goal-question-when = Quand aurai-je ce montant ?
goal-question-amount = Combien aurai-je à cette date ?
goal-question-effort = Combien épargner pour avoir ce montant à cette date ?
goal-field-target = Montant visé
goal-field-date = Date visée
goal-field-rate = Taux annuel de l'épargne
goal-field-extra = Et si j'épargnais en plus, par mois
goal-options-hint = Vides : aucun intérêt, rien de plus.
goal-answer-title = La réponse
goal-chart-title = Votre solde, hier et demain
goal-chart-hint = En trait plein, le solde réel des douze derniers mois ; en pointillés, la projection ; en clair, la fourchette selon les mois.
goal-disclaimer = Une projection tirée de votre historique, pas une promesse : un imprévu peut tout changer.
goal-no-account = Cochez au moins un compte à suivre.
goal-no-month = Cette période n'a encore aucun mois complet.
goal-invalid-target = Un montant à atteindre, s'il vous plaît.
goal-invalid-date = Une date à venir, dans les cinquante prochaines années, s'il vous plaît.
goal-invalid-rate = Un taux de 0 à 100 %, s'il vous plaît.
goal-invalid-extra = Ce montant n'est pas lisible : corrigez-le pour relancer le calcul.
goal-per-month = { $amount } par mois
goal-tile-balance = Solde aujourd'hui
goal-tile-rhythm = Rythme moyen
goal-tile-target = Objectif
goal-tile-reached = Atteint vers
goal-tile-date = Date visée
goal-tile-projected = Solde projeté
goal-tile-saved = Épargné d'ici là
goal-tile-interest = Dont intérêts
goal-tile-needed = À épargner
goal-when-already = Vous avez déjà { $amount } : vos comptes suivis totalisent { $balance }.
goal-when-reached = Vous aurez { $amount } vers { $month }, dans { $months ->
        [one] un mois
       *[other] { $months } mois
    }.
goal-when-range = Selon les mois, entre { $early } et { $late }.
goal-when-range-open = Au plus tôt vers { $early } ; avec des mois faibles, l'objectif ne serait pas atteint.
goal-when-never = À ce rythme, vous n'atteindrez pas { $amount }.
goal-zero = Votre solde tomberait à zéro vers { $month }.
goal-amount = En { $month }, vous auriez environ { $amount }.
goal-amount-range = Selon les mois, entre { $low } et { $high }.
goal-effort-more = Pour avoir { $amount } en { $month }, il faudrait épargner en moyenne { $monthly } par mois, soit { $gap } de plus qu'aujourd'hui.
goal-effort-less = Pour avoir { $amount } en { $month }, { $monthly } par mois suffiraient, soit { $gap } de moins qu'aujourd'hui : vous êtes en avance.
goal-effort-range = Selon les mois, l'écart avec votre rythme irait de { $low } à { $high } par mois.
goal-chart-target = Objectif : { $amount }
goal-chart-today = Aujourd'hui
goal-note-seasons = La projection suit les saisons : chaque mois à venir reprend la moyenne des mêmes mois de la période.
goal-note-range = La fourchette vient des mois faibles et des mois forts de la période : le quart le plus bas et le quart le plus haut.
goal-note-loan = Le crédit « { $label } » se termine en { $month } : { $amount } par mois de plus ensuite.
goal-note-interest = Intérêts comptés chaque mois au taux de { $rate } % par an : une approximation de la règle des quinzaines des livrets.
goal-period = Rythme calculé sur { $count ->
        [one] { $count } mois complet
       *[other] { $count } mois complets
    }, de { $from } à { $to }. { $transfers ->
        [0] Aucun virement entre vos comptes suivis.
        [one] Un virement entre vos comptes suivis, neutralisé.
       *[other] { $transfers } virements entre vos comptes suivis, neutralisés.
    }

# --- F45 — Et si je réduisais… ? (Fabrice, 10/10/2026) ----------------------------
# Réduire des postes de dépense, et voir ce que ça change dans le temps.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-spending-cut = Et si je réduisais… ?
window-cut-title = Et si je réduisais… ?
cut-axis-label = Classer par
cut-axis-category = Catégories
cut-axis-payee = Tiers
cut-axis-budget-line = Postes budgétaires
cut-table-title = Vos dépenses, poste par poste
cut-table-hint = Tapez une réduction en % ou en { $sign } par mois sur les postes que vous voudriez alléger. Une réduction ne peut pas dépasser la dépense elle-même.
cut-column-monthly = Par mois
cut-column-cut = Réduction
cut-column-after = Après
cut-column-yearly = Gain par an
cut-total = Total
cut-horizon-label = Horizon
cut-settings-title = Réglages
cut-options-hint = Le taux et le montant visé sont facultatifs.
cut-report-button = Rapport PDF
cut-chart-title = Votre solde, sans et avec les réductions
cut-chart-hint = En trait plein, le solde réel des douze derniers mois ; en pointillés gris, la projection sans réduction ; en bleu, avec ; en vert, l'argent gagné.
cut-donut-title = Vos dépenses par mois après réduction
cut-donut-caption = après réduction
cut-donut-others = Autres postes
cut-donut-saved = Économisé
cut-legend-with = Avec les réductions
cut-legend-without = Sans réduction
cut-years = { $years ->
        [one] { $years } an
       *[other] { $years } ans
    }
cut-headline-none = Tapez une réduction dans le tableau pour en voir l'effet.
cut-headline = En réduisant { $count ->
        [one] ce poste
       *[other] ces { $count } postes
    }, vous mettriez de côté { $monthly } de plus par mois, soit { $yearly } par an.
cut-tile-monthly = Gain par mois
cut-tile-yearly = Gain par an
cut-tile-horizon = Gain sur { $years ->
        [one] { $years } an
       *[other] { $years } ans
    }
cut-tile-spending = Dépenses par mois
cut-target-already = Vous avez déjà { $amount }.
cut-target-sooner = Vous atteindriez { $amount } vers { $with } au lieu de { $without } : { $months ->
        [0] pas plus tôt
        [one] un mois plus tôt
       *[other] { $months } mois plus tôt
    }.
cut-target-only-with = Avec ces réductions, vous atteindriez { $amount } vers { $with } ; sans elles, à votre rythme actuel, jamais.
cut-target-never = Même avec ces réductions, vous n'atteindriez pas { $amount } à votre rythme actuel.
cut-note-seasons = Chaque réduction suit les saisons de son poste : un poste qui pèse surtout l'été rapporte surtout l'été.
cut-note-capped = Une réduction tapée dépassait la dépense : elle a été ramenée à la dépense elle-même.
cut-invalid-cut = Cette réduction n'est pas lisible : un pourcentage de 0 à 100, ou un montant par mois.
cut-report-settings = Les réglages
cut-report-result = Le résultat
cut-report-accounts = Comptes suivis

# --- F46 — Préparer mes vacances (Fabrice, 10/10/2026) -----------------------------
# Ce que coûtera le prochain voyage, séjour ou croisière.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-holiday = Préparer mes vacances
window-holiday-title = Préparer mes vacances
holiday-trip-title = Le voyage
holiday-field-trip = Type de voyage
holiday-trip-stay = Séjour
holiday-trip-cruise = Croisière
holiday-field-adults = Adultes
holiday-field-children = Enfants
holiday-field-nights = Durée du séjour, en nuits
holiday-field-days = Jours
holiday-field-months = Mois avant le départ
holiday-field-stops = Nombre d'escales
holiday-saved-title = Déjà épargné
holiday-saved-hint = Cochez les comptes où l'argent des vacances est déjà mis de côté : leur solde réel compte comme déjà épargné.
holiday-budget-title = Le budget
holiday-budget-hint = Pour chaque poste, un montant, pour qui il vaut et pour combien de temps. Vide, un poste ne compte pas.
holiday-optional-title = Lignes facultatives
holiday-result-title = Le résultat
holiday-donut-title = Où part l'argent du voyage
holiday-donut-caption = pour le voyage
holiday-child-label = Prix enfant
holiday-count-label = Cabines
holiday-open = Ouvrir un projet…
holiday-save = Enregistrer le projet…
holiday-pdf = Rapport PDF
holiday-excel = Exporter vers Excel
holiday-file-filter = Projet de vacances
holiday-replace-question = Ouvrir ce projet remplacera ce qui est tapé dans la fenêtre. Continuer ?
holiday-file-saved = Projet enregistré : { $file }
holiday-file-opened = Projet ouvert : { $file }
holiday-file-not-project = Ce fichier n'est pas un projet de vacances de Radinus.
holiday-file-too-recent = Ce projet vient d'une version plus récente de Radinus : mettez Radinus à jour pour l'ouvrir.
holiday-file-failed = Le fichier n'a pas pu être lu ou écrit : { $reason }
holiday-line-transport = Transport aller-retour
holiday-line-lodging = Hébergement
holiday-line-meals = Repas et dépenses courantes
holiday-line-visits = Visites et loisirs
holiday-line-port = Acheminement jusqu'au port
holiday-line-cabins = Cabines
holiday-line-service = Forfait service (pourboires)
holiday-line-drinks = Forfait boissons
holiday-line-excursions = Excursions aux escales
holiday-line-port-taxes = Taxes portuaires
holiday-line-wifi = Wifi à bord
holiday-line-onboard = Dépenses à bord et aux escales
holiday-line-other = Autres frais et imprévus
holiday-line-insurance = Assurance annulation
holiday-line-stay-tax = Taxe de séjour
holiday-line-car = Voiture sur place, carburant et péages
holiday-line-parking = Parking de l'aéroport ou de la gare
holiday-line-bank = Frais bancaires à l'étranger
holiday-line-formalities = Formalités (passeport, visa, vaccins)
holiday-line-pets = Garde des animaux
holiday-span-trip = pour le séjour
holiday-span-night = par nuit
holiday-span-day = par jour
holiday-span-stop = par escale
holiday-who-all = pour tous
holiday-who-person = par personne
holiday-who-adults = par adulte
holiday-cabins-count = { $count ->
        [one] { $count } cabine
       *[other] { $count } cabines
    }
holiday-days = { $days ->
        [one] { $days } jour
       *[other] { $days } jours
    }
holiday-invalid-count = Un nombre entier, s'il vous plaît.
holiday-invalid-amount = Ce montant n'est pas lisible : un nombre positif, ou un pourcentage de 0 à 100.
holiday-headline-empty = Tapez les montants du budget pour voir ce que coûtera le voyage.
holiday-headline-stay = Ce séjour coûterait { $total } pour { $people ->
        [one] une personne
       *[other] { $people } personnes
    } et { $nights ->
        [0] aucune nuit
        [one] une nuit
       *[other] { $nights } nuits
    }.
holiday-headline-cruise = Cette croisière coûterait { $total } pour { $people ->
        [one] une personne
       *[other] { $people } personnes
    } et { $nights ->
        [0] aucune nuit
        [one] une nuit
       *[other] { $nights } nuits
    }.
holiday-tile-total = Coût total
holiday-tile-person = Par personne
holiday-tile-person-day = Par personne et par jour
holiday-tile-saved = Déjà épargné
holiday-tile-remaining = Reste à financer
holiday-tile-monthly = Épargne nécessaire
holiday-remaining-none = Rien : c'est couvert
holiday-monthly-none = Rien à mettre de côté
holiday-monthly-now = Départ ce mois-ci
holiday-note-days = Les jours sont les nuits plus une : sept nuits font huit jours.
holiday-note-child = Par personne, un enfant paie le prix enfant s'il est donné ; vide, il paie comme un adulte.
holiday-note-percent = Un pourcentage d'assurance porte sur les postes principaux du voyage ; celui des frais bancaires, sur les dépenses faites sur place.
holiday-sheet-budget = Budget
holiday-sheet-result = Résultat
holiday-column-line = Poste
holiday-column-amount = Montant
holiday-column-child = Prix enfant
holiday-column-who = Pour qui
holiday-column-span = Pour combien de temps
holiday-column-cost = Coût
holiday-disclaimer = Une estimation tirée de vos propres montants : les prix réels peuvent varier.

# --- F45 (suite) — le projet de réduction en fichier (Fabrice, 10/10/2026) --------
# « Rajoute enregistrement et chargement JSON et aussi export Excel. »
cut-file-filter = Projet de réduction
cut-file-not-project = Ce fichier n'est pas un projet de réduction de Radinus.
cut-file-too-recent = Ce projet vient d'une version plus récente de Radinus : mettez Radinus à jour pour l'ouvrir.
cut-sheet-items = Postes

# --- F47 — Carnet de ma voiture (Fabrice, 10/10/2026) --------------------------------
# L'historique de la voiture : énergie, entretien, pièces, pneus, pannes, assurance, contrôle.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-car = Carnet de ma voiture
window-car-title = Carnet de ma voiture
car-unnamed = Ma voiture
car-sheet-title = La voiture
car-field-plate = Immatriculation
car-field-make = Marque
car-field-model = Modèle
car-field-engine = Motorisation
car-field-first-hand = Première main
car-field-registered = Première mise en circulation
car-field-acquired = Date d'acquisition
car-field-acquired-km = Kilométrage à l'acquisition
car-field-service = Révision tous les
car-field-service-or = ou tous les
car-unit-months-short = mois
car-unit-km = km
car-tariff-title = Tarif de la recharge à la maison
car-tariff-hint = Ce tarif est gardé dans le carnet de la voiture : il ne change pas celui des préférences.
car-tariff-reset = Reprendre le tarif des préférences
car-engine-petrol = Essence
car-engine-diesel = Diesel
car-engine-lpg = GPL
car-engine-e85 = E85 (superéthanol)
car-engine-hybrid = Hybride
car-engine-plug-in = Hybride rechargeable
car-engine-electric = Électrique
car-engine-hydrogen = Hydrogène
car-energy-petrol = Essence
car-energy-diesel = Gazole
car-energy-lpg = GPL
car-energy-e85 = E85
car-energy-electricity = Électricité
car-energy-hydrogen = Hydrogène
car-unit-litre = L
car-unit-kwh = kWh
car-unit-kg = kg
car-rubric-energy = Énergie
car-rubric-upkeep = Entretien courant
car-rubric-service = Révision
car-rubric-wear = Pièces d'usure
car-rubric-tyres = Pneus
car-rubric-breakdown = Pannes
car-rubric-insurance = Assurance
car-rubric-inspection = Contrôle technique
car-part-brake-pads = Plaquettes de frein
car-part-brake-discs = Disques de frein
car-part-timing-belt = Courroie de distribution
car-part-clutch = Embrayage
car-part-battery-12v = Batterie 12 V
car-part-shock-absorbers = Amortisseurs
car-part-wipers = Essuie-glaces
car-part-spark-plugs = Bougies d'allumage
car-part-glow-plugs = Bougies de préchauffage
car-part-particulate-filter = Filtre à particules
car-part-catalytic-converter = Pot catalytique
car-part-fuel-cell-filter = Filtre de la pile à combustible
car-part-exhaust = Échappement
car-part-other = Autre pièce…
car-axle-all = Les quatre pneus
car-axle-front = Pneus avant
car-axle-rear = Pneus arrière
car-verdict-pass = Favorable
car-verdict-counter = Contre-visite
car-charge-station = À une borne
car-charge-home = À la maison
car-slot-peak = Heures pleines
car-slot-off-peak = Heures creuses
car-entry-new = Nouvelle ligne
car-entry-edit = Modifier la ligne
car-field-date = Date
car-field-km = Compteur
car-field-rubric = Rubrique
car-field-amount = Montant
car-field-garage = Garage ou station
car-field-note = Note
car-field-energy = Énergie
car-field-quantity = Quantité
car-field-charge = Recharge
car-field-slot = Heure de recharge
car-field-part = Pièce
car-field-part-name = Nom de la pièce
car-field-axle = Pneus changés
car-field-verdict = Résultat
car-field-months = Mois couverts
car-field-battery = État de la batterie
car-home-amount-hint = Le montant d'une recharge à la maison se calcule avec le tarif de la voiture.
car-entry-add = Ajouter au carnet
car-entry-update = Enregistrer la ligne
car-entry-cancel = Annuler
car-entry-delete = Supprimer la ligne
car-delete-question = Supprimer cette ligne du carnet ?
car-from-operation = Prendre une opération…
car-pick-account = De quel compte vient la dépense ?
car-pick-operation = Quelle opération ?
car-pick-take = Prendre
car-pick-none = Aucune dépense dans ce compte.
car-pick-taken = Opération reprise : complétez le compteur et la rubrique, puis ajoutez la ligne.
car-history-title = L'historique
car-filter-all = Toutes les rubriques
car-history-empty = Aucune ligne pour l'instant.
car-history-hint = Cliquez une ligne pour la modifier.
car-column-date = Date
car-column-km = Km
car-column-rubric = Rubrique
car-column-detail = Détail
car-column-amount = Montant
car-column-garage = Garage
car-column-note = Note
car-column-share = Part
car-column-per-km = Au km
car-column-energy = Énergie
car-column-quantity = Quantité
car-column-price = Prix moyen
car-column-consumption = Consommation
car-column-part = Pièce
car-column-changes = Changements
car-column-last = Dernier changement
car-column-life = Durée de vie
car-column-next = Prochain changement
car-total = Total
car-summary-title = Ce que coûte la voiture
car-headline-empty = Remplissez la fiche, puis ajoutez une première ligne : un plein, une révision, une facture de garage…
car-headline = Depuis { $since }, votre voiture vous a coûté { $total }.
car-headline-km = Depuis { $since }, votre voiture vous a coûté { $total } pour { $km } parcourus : { $cost } par kilomètre.
car-tile-total = Coût total
car-tile-month = Par mois
car-tile-km = Au kilomètre
car-tile-driven = Kilomètres parcourus
car-tile-consumption = Consommation
car-tile-energy-km = Énergie au kilomètre
car-km = { $value } km
car-quantity = { $value } { $unit }
car-per-100 = { $value } { $unit } / 100 km
car-per-unit = { $price } / { $unit }
car-months = { $months ->
        [one] { $months } mois
       *[other] { $months } mois
    }
car-detail-battery = Batterie : { $value } %
car-battery-line = { $when } : { $value } %
car-rubrics-title = Par rubrique
car-energy-title = L'énergie
car-parts-title = Pièces d'usure
car-tyres-title = Pneus
car-battery-title = État de la batterie
car-years-title = Ce que la voiture a coûté chaque année
car-donut-title = Où part l'argent
car-donut-caption = en tout
car-deadlines-title = Les échéances
car-deadlines-empty = Aucune échéance pour l'instant : notez une révision, un contrôle technique, une assurance, ou deux changements d'une même pièce.
car-deadline-service = Révision
car-deadline-inspection = Contrôle technique
car-deadline-counter = Contre-visite du contrôle technique
car-deadline-insurance = Fin de l'assurance
car-when-date = le { $date }
car-when-km = à { $km }
car-when-km-reached = à { $km }, vers { $month } à votre rythme
car-when-date-km = le { $date } ou à { $km }, au premier des deux
car-when-inspection-unknown = Notez le dernier contrôle technique pour connaître la date du prochain.
car-tone-late = Dépassée
car-tone-soon = Bientôt
car-note-since = Tout se compte depuis l'acquisition : la date et le compteur notés sur la fiche.
car-note-consumption = La consommation se mesure de plein à plein : faites le plein complet et notez le compteur à chaque fois.
car-note-e85 = Une voiture E85 boit ce qu'on lui donne : les kilomètres qui suivent un plein comptent pour son carburant.
car-note-home = Une recharge à la maison est chiffrée au tarif de la voiture le jour où elle est notée, et garde ce coût.
car-note-inspection = Le contrôle technique suit la règle française : le premier dans les quatre ans de la mise en circulation, puis tous les deux ans ; une contre-visite, dans les deux mois.
car-disclaimer = Les échéances et les durées de vie sont des estimations tirées du carnet : seul le carnet d'entretien du constructeur fait foi.
car-invalid-date = Une date valide, qui n'est pas dans le futur, s'il vous plaît.
car-invalid-acquired = La date d'acquisition ne peut pas précéder la mise en circulation.
car-invalid-km = Un compteur en kilomètres entiers, s'il vous plaît.
car-invalid-amount = Ce montant n'est pas lisible.
car-invalid-quantity = Tapez la quantité : litres, kWh ou kilos.
car-invalid-part = Choisissez la pièce changée, ou tapez son nom.
car-invalid-rubric = Choisissez une rubrique.
car-invalid-months = Un nombre entier de mois, s'il vous plaît.
car-invalid-battery = Un état de batterie de 0 à 100 %, s'il vous plaît.
car-open = Ouvrir un carnet…
car-save = Enregistrer le carnet…
car-report-button = Dossier PDF
car-file-filter = Carnet de voiture
car-file-saved = Carnet enregistré : { $file }
car-file-opened = Carnet ouvert : { $file }
car-file-not-logbook = Ce fichier n'est pas un carnet de voiture de Radinus.
car-file-too-recent = Ce carnet vient d'une version plus récente de Radinus : mettez Radinus à jour pour l'ouvrir.
car-replace-question = Ouvrir ce carnet remplacera celui de la fenêtre. Continuer ?
car-sheet-history = Carnet
car-sheet-summary = Synthèse

# --- Fiabilité des analyses (Fabrice, 10/10/2026) ---------------------------------
# Dans la barre d'information des outils qui font une moyenne sur l'historique
# (crédit, matelas, objectif épargne, réduction). « Meilleure », pas « fiable » :
# l'utilisateur doit rester critique, même avec un an d'opérations.
analysis-history-hint = Plus votre historique est long, meilleure sera cette analyse : l'idéal est d'avoir au moins un an d'opérations.

# --- F48 — Partager une dépense (Fabrice, 11/10/2026, P-71) --------------------------
# Qui paie quoi : une somme partagée selon une règle, avec des contraintes, puis
# suivie règlement après règlement. Les phrases sont écrites par le noyau.
menu-tools-sharing = Partager une dépense
window-sharing-title = Partager une dépense
sharing-question = Qui paie quoi ?
sharing-setup-title = Le partage
sharing-field-label = Libellé
sharing-label-hint = Par exemple « Restaurant du 12/10 » ou « Voyage Bretagne 2027 » : il nomme les fichiers et les rapports.
sharing-field-total = Total
sharing-total-hint = Vide, le total est la somme des postes et des extras de chacun.
sharing-field-rule = Règle
sharing-field-rounding = Arrondi
sharing-field-people = Personnes
sharing-mode-whole = Une règle pour toute la dépense
sharing-mode-item = Une règle par poste
sharing-rule-equal = Parts égales
sharing-rule-parts = Par parts
sharing-rule-percent = En pourcentages
sharing-rule-income = Au prorata des revenus
sharing-rounding-cent = Au centime
sharing-rounding-euro = À l'euro
sharing-round-euro = Arrondir à l'euro
sharing-hide-incomes = Masquer les revenus dans les rapports et l'export
sharing-people-title = Les personnes
sharing-people-hint = Une ligne par personne, une colonne par poste : cochez qui participe à quoi. Tout le reste est facultatif. Quelqu'un qui se désiste en laissant son acompte : un montant exact égal à ce qu'il a versé, et aucune case cochée.
sharing-add-person = Ajouter une personne
sharing-person-default = Personne { $number }
sharing-items-title = Les postes
sharing-items-hint = Seulement ce qui ne concerne pas tout le monde, comme le vin. Le reste du total va dans le poste commun.
sharing-add-item = Ajouter un poste
sharing-common = Commun
sharing-payments-title = Les règlements
sharing-payments-hint = Qui a payé, combien, et quand. Une ligne sans montant ne compte pas encore.
sharing-payments-none = Aucun règlement pour l'instant.
sharing-add-payment = Ajouter un règlement
sharing-result-title = Le résultat
sharing-balances-title = Où en sont les règlements
sharing-transfers-title = Les virements proposés
sharing-delete = Supprimer
sharing-delete-person-question = Cette personne a des règlements : les supprimer avec elle ?
sharing-disclaimer = Radinus propose un partage : entre amis, chacun reste libre de s'arranger autrement.
sharing-column-person = Personne
sharing-column-household = Foyer
sharing-column-income = Revenu
sharing-column-parts = Parts
sharing-column-percent = %
sharing-column-floor = Au minimum
sharing-column-cap = Au maximum
sharing-column-fixed = Montant exact
sharing-column-alone = Ses extras
sharing-column-gift = Surplus offert
sharing-column-share = Part
sharing-column-typed = % tapé
sharing-column-constraint = Ce qui a joué
sharing-column-due = À payer
sharing-column-item = Poste
sharing-column-amount = Montant
sharing-column-rule = Règle
sharing-column-participants = Participants
sharing-column-unit = Foyer ou personne
sharing-column-members = Membres
sharing-column-paid = Réglé
sharing-column-balance = Solde
sharing-column-date = Date
sharing-column-who = Qui
sharing-column-label = Libellé
sharing-help-household = Les personnes d'un même foyer règlent ensemble : leurs paiements et ce qu'elles doivent s'additionnent, et elles reçoivent un seul relevé. Exemple : « Famille Martin » pour les parents et les enfants.
sharing-help-income = Ne sert qu'à la règle « au prorata des revenus » : plus le revenu est élevé, plus la part est grande. Tapez le revenu mensuel.
sharing-help-parts = Une personne à 2 parts paie deux fois plus qu'une personne à 1 part. Exemple : adulte 1, enfant 0,5.
sharing-help-percent = La part de la dépense que paie la personne. Les pourcentages doivent faire 100 % au total.
sharing-help-floor = La personne paiera au moins ce montant, même si sa part calculée est plus petite. La différence allège les autres.
sharing-help-cap = La personne ne paiera jamais plus que ce montant. Ce qu'elle ne paie pas retombe sur les autres participants de ses postes.
sharing-help-fixed = La personne paie ce montant, quoi qu'il arrive, et le reste se partage entre les autres. Exemple : quelqu'un qui se désiste et laisse son acompte.
sharing-help-alone = Ce que la personne a pris pour elle seule, comme un dessert ou un café. Elle le paie entièrement, en plus de sa part.
sharing-help-gift = Si la personne a versé plus que sa part : coché, le surplus est un cadeau au groupe ; décoché, on le lui rend.
sharing-help-items = Cochez les personnes qui participent à ce poste. Le Commun, c'est ce qui reste du total une fois les autres postes retirés.
sharing-help-due = Ce que la personne doit au total : sa part des postes, ses extras et l'arrondi.
sharing-help-share = Ce que sa part représente, en pourcentage de la somme partagée.
sharing-help-typed = Le pourcentage que vous avez tapé. Il peut différer de la part réelle quand un minimum, un maximum ou un montant exact a joué.
sharing-help-constraint = Indique si la part de la personne a été modifiée par un minimum, un maximum, un montant exact ou un surplus offert.
sharing-help-item = Seulement ce qui ne concerne pas tout le monde, comme le vin. Le reste du total va dans le Commun, partagé entre ceux qui y sont cochés.
sharing-help-rule = Comment ce poste se partage : à parts égales, par parts, en pourcentages ou au prorata des revenus.
sharing-help-paid = Ce que le foyer ou la personne a déjà versé, d'après les règlements saisis.
sharing-help-balance = Ce qui reste à régler, ou ce qui a été versé en plus de la part. Exemple : « Reste à régler : 61,54 € ».
sharing-advice-equal = { $count ->
        [one] { $total } pour une seule personne.
       *[other] { $total } ÷ { $count } personnes = { $amount } chacun.
    }
sharing-advice-equal-varied = À parts égales entre ceux qui prennent part, compte tenu des limites et des exclusions.
sharing-advice-parts = { $parts } parts au total : une part vaut { $amount }.
sharing-advice-parts-varied = Chacun paie selon ses parts, compte tenu des limites et des exclusions. Une case vide compte pour 1 part.
sharing-advice-percent-rest = Il manque { $rest } % pour arriver à 100 %.
sharing-advice-percent-over = Les pourcentages dépassent 100 % de { $over } %.
sharing-advice-percent-ok = Les pourcentages font bien 100 %.
sharing-advice-percent-nobody = Les pourcentages font déjà 100 % : { $names } ne { $count ->
        [one] paierait
       *[other] paieraient
    } rien.
sharing-advice-income = Chacun paie { $rate } % de son revenu.
sharing-advice-income-missing = Tapez le revenu de chacun pour partager au prorata des revenus.
sharing-advice-income-varied = Chacun paie la même proportion de son revenu, compte tenu des limites et des exclusions.
sharing-advice-empty = Tapez le montant à partager.
sharing-apply-advice = Reprendre les valeurs conseillées
sharing-help-apply-advice = Remplit les cases vides avec les valeurs en gris. Les cases déjà remplies ne changent pas.
sharing-from-incomes = Pourcentages d'après les revenus
sharing-help-from-incomes = Remplace les pourcentages par la part de chaque revenu dans le total des revenus. Ils font 100 %.
sharing-reset-percents = Tout répartir à nouveau
sharing-help-reset-percents = Efface les pourcentages et les répartit à parts égales entre tous. Utile après avoir ajouté une personne.
sharing-reset-percents-question = Effacer tous les pourcentages et les répartir à parts égales ?
sharing-open = Ouvrir un projet…
sharing-save = Enregistrer le projet…
sharing-pdf-distribution = Répartition (PDF)
sharing-pdf-payments = État des paiements (PDF)
sharing-pdf-statements = Relevés individuels (PDF)…
sharing-statements-everyone = Tout le monde
sharing-excel = Exporter vers Excel
sharing-file-filter = Projet de partage
sharing-replace-question = Ouvrir ce projet remplacera ce qui est saisi dans la fenêtre. Continuer ?
sharing-file-saved = Projet enregistré : { $file }
sharing-file-opened = Projet ouvert : { $file }
sharing-file-not-project = Ce fichier n'est pas un projet de partage de Radinus.
sharing-file-too-recent = Ce projet vient d'une version plus récente de Radinus : mettez Radinus à jour pour l'ouvrir.
sharing-file-failed = Le fichier n'a pas pu être lu ou écrit : { $reason }
sharing-statements-replace-question = { $count ->
        [one] Un relevé existe déjà dans ce dossier. Le remplacer ?
       *[other] { $count } relevés existent déjà dans ce dossier. Les remplacer ?
    }
sharing-statements-written = { $count ->
        [one] Un relevé écrit dans « { $folder } ».
       *[other] { $count } relevés écrits dans « { $folder } ».
    }
sharing-too-many-people = Un partage compte au plus 40 personnes.
sharing-too-many-items = Un partage compte au plus 20 postes.
sharing-too-many-payments = Un partage compte au plus 400 règlements.
sharing-invalid-amount = Ce montant n'est pas lisible : un nombre positif.
sharing-invalid-number = Ce nombre n'est pas lisible : un nombre positif.
sharing-invalid-percent = Un pourcentage va de 0 à 100.
sharing-invalid-date = Cette date n'est pas lisible.
sharing-name-missing = Chaque personne doit avoir un nom.
sharing-name-duplicate = Il y a déjà « { $name } » : distinguez-les, par exemple par une initiale.
sharing-floor-above-cap = Le minimum dépasse le maximum.
sharing-item-label-missing = Ce poste n'a pas de nom.
sharing-items-above-total = Les postes et les extras de chacun dépassent le total de { $amount }.
sharing-payment-person = Choisissez qui a payé.
sharing-percent-total = Les pourcentages font { $sum } % : il faut 100 %.
sharing-percent-total-item = « { $item } » : les pourcentages font { $sum } % : il faut 100 %.
sharing-item-nobody = Personne ne participe à « { $item } ».
sharing-item-no-weight = Personne ne pèse sur « { $item } » : tous ses participants sont à zéro.
sharing-income-missing = Il manque le revenu de { $name }.
sharing-fixed-above = Les montants exacts dépassent la somme à partager de { $amount }.
sharing-floors-above = Les minimums dépassent la somme à partager de { $amount }.
sharing-cap-alone = { $name } est seul à participer à « { $item } » : son maximum ne peut pas être respecté.
sharing-caps-short = Les maximums ne suffisent pas à couvrir la somme : il manque { $amount }.
sharing-impossible = Ces conditions ne peuvent pas être toutes respectées : desserrez un minimum ou un maximum.
sharing-constraint-floor = Minimum atteint
sharing-constraint-cap = Maximum atteint
sharing-constraint-fixed = Montant exact
sharing-constraint-gift = Surplus offert
sharing-and = { $first } et { $last }
sharing-outside = Hors postes
sharing-alone = Ses extras
sharing-rounding = Arrondi
sharing-headline-empty = Ajoutez les personnes qui partagent la dépense.
sharing-headline-no-amount = Tapez le total, ou les postes à partager.
sharing-headline-equal = { $total } à partager : chacun paie { $amount }.
sharing-headline-range = { $total } à partager : de { $min } à { $max } selon chacun.
sharing-participants = { $count ->
        [0] Aucun participant
        [one] Un participant
       *[other] { $count } participants
    }
sharing-balance-due = Reste à régler : { $amount }
sharing-balance-over = A versé { $amount } de plus que sa part
sharing-balance-even = À jour
sharing-summary-collected = { $collected } réglés sur { $total }.
sharing-summary-owing = { $count ->
        [0] Tout le monde est à jour.
        [one] Un seul doit encore { $amount }.
       *[other] { $count } doivent encore { $amount } au total.
    }
sharing-remaining-outside = Reste à payer sur la dépense : { $amount }
sharing-remaining-reimburse = À rembourser à { $name } : { $amount }
sharing-all-settled = Tout est réglé : personne ne doit rien à personne.
sharing-transfer = { $from } doit { $amount } à { $to }
sharing-warning-over-paid = Les règlements dépassent la dépense de { $amount } : vérifiez les montants.
sharing-note-income-zero = { $name } ne paie rien sur { $items } : son revenu est de 0.
sharing-note-excluded = { $name } ne participe pas à « { $item } » : sa part est répartie entre les autres.
sharing-note-gift = Le surplus offert par { $giver } réduit la part des autres : { $name } a désormais versé plus que sa part.
sharing-note-outside = { $name } paie { $amount } hors de ses postes : la somme est déduite de ce que partagent les autres.
sharing-note-keeper = Arrondi à l'euro : { $name } garde les centimes, pour que le total tombe juste.
sharing-report-distribution = Répartition
sharing-report-sharing = Le partage
sharing-report-who-pays = Qui paie quoi
sharing-report-items = Le détail par poste
sharing-report-payments = État des paiements
sharing-report-as-of = État au { $date }
sharing-report-balances = Part, réglé, solde
sharing-report-statement = Relevé — { $name }
sharing-report-your-share = Votre part
sharing-statement-total = Total pour le foyer : { $amount }
sharing-statement-pay = À verser à { $name } : { $amount }
sharing-statement-receive = À recevoir de { $name } : { $amount }
sharing-sheet-people = Personnes
sharing-sheet-items = Postes
sharing-sheet-result = Résultat
sharing-sheet-payments = Règlements
sharing-sheet-balances = Remboursements
