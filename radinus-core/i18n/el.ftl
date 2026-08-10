# Radinus — μηνύματα από την πλευρά του core (Fluent), ελληνικά.
# Συμπληρώνεται σταδιακά καθώς υλοποιούνται οι ενότητες του core που παράγουν
# μηνύματα ορατά στον χρήστη. Βλέπε 08_ARCHITECTURE.md §2.1.

# Η προεπιλεγμένη τιμή «0 = Μη καθορισμένο» που χρησιμοποιεί κάθε προαιρετικός
# σύνδεσμος βασικών δεδομένων (02_BASE_DE_DONNEES.md §7 κανόνας 2). Εμφανίζεται
# στην κορυφή κάθε λίστας επιλογών.
# ---------------------------------------------------------------------
# Το όνομα της γλώσσας, γραμμένο στη δική της γλώσσα.
#
# Αυτό δείχνουν το μενού Ρυθμίσεις και ο επιλογέας της πρώτης εκκίνησης
# (01_CAHIER_DES_CHARGES.md §3.5: «κάθε γλώσσα γραμμένη στη δική της
# γλώσσα»). Βρίσκεται εδώ, και όχι στον κώδικα, επειδή είναι το μόνο σημείο
# όπου μπορεί να είναι σωστό: προσθέτω μια γλώσσα σημαίνει καταθέτω ένα
# αρχείο που ξέρει να ονομάζεται.
# ---------------------------------------------------------------------
language-name = Ελληνικά

nomenclature-unspecified = Μη καθορισμένο

# Ερώτηση πριν από τη διαγραφή ενός στοιχείου των βασικών δεδομένων που
# χρησιμοποιούν ακόμη κινήσεις (02_BASE_DE_DONNEES.md §7 κανόνας 5).
# Αναπαράγεται λέξη προς λέξη από τον αρχικό κώδικα WinDev (Enreg_Supprimer),
# μαζί με τη στίξη — η διατύπωση είναι του συγγραφέα, όχι μετάφραση.
nomenclature-delete-confirm = Εντοπίστηκαν κινήσεις (τραπεζικές συναλλαγές) που έχουν το χαρακτηριστικό τύπου '{ $label }'. Επιβεβαιώνετε ότι θέλετε να επαναφέρετε αυτό το χαρακτηριστικό;

# Ερώτηση πριν από τη διαγραφή ενός στοιχείου των βασικών δεδομένων που δεν
# χρησιμοποιεί κανείς. Ο αρχικός κώδικας διέγραφε ένα τέτοιο στοιχείο αμέσως,
# χωρίς λέξη· ο Fabrice ζήτησε στις 25/07/2026 μια διαγραφή να επιβεβαιώνεται
# πάντοτε — μια συνειδητή απόκλιση από τον ίδιο του τον κώδικα, και η μόνη σε
# αυτή την ενότητα.
nomenclature-delete-plain = Επιβεβαιώνετε τη διαγραφή του «{ $label }»;

# Άρνηση που εμφανίζεται όταν το στοιχείο που πρόκειται να διαγράψει ο χρήστης
# είναι ακριβώς αυτό που δείχνει η καρτέλα του. Απόφαση του Fabrice της
# 25/07/2026: ένα στοιχείο δεν διαγράφεται κάτω από την ανοιχτή καρτέλα του —
# η καρτέλα κλείνει πρώτα, αντί να μείνει δείχνοντας μια εγγραφή που δεν
# υπάρχει πλέον.
nomenclature-delete-form-open = Η καρτέλα του «{ $label }» είναι ανοιχτή. Κλείστε την πριν από τη διαγραφή.

# Άρνηση που εμφανίζεται όταν η περιγραφή που αποθηκεύεται φέρεται ήδη από
# άλλο στοιχείο των ίδιων βασικών δεδομένων (απόφαση του συγγραφέα,
# 25/07/2026: δύο στοιχεία των ίδιων βασικών δεδομένων δεν πρέπει να μοιράζονται
# ένα όνομα — το να καταταχθεί μια κίνηση κάτω από τη μία από δύο πανομοιότυπες
# περιγραφές είναι κορώνα γράμματα). Το `element` είναι το ουσιαστικό στο γένος
# του, «μια κατηγορία», «ένας αντισυμβαλλόμενος»· το `label` είναι η υπάρχουσα
# περιγραφή, όπως έχει αποθηκευτεί, ώστε ο χρήστης να βλέπει τι τον εμποδίζει.
nomenclature-duplicate = Υπάρχει ήδη { $element } με το ίδιο όνομα: «{ $label }».

# ---------------------------------------------------------------------
# Αυτά που λένε τα παράθυρα για τον εαυτό τους.
#
# Όλα είναι εδώ, ακόμη και ό,τι εξαρτάται από τα βασικά δεδομένα που
# εμφανίζονται: οι φράσεις γράφονται ολόκληρες, γλώσσα προς γλώσσα, αντί να
# κατασκευάζονται με συναρμολόγηση λέξεων και γενών. Μια συναρμολόγηση σωστή
# στα γαλλικά είναι λανθασμένη στην επόμενη γλώσσα, και καταλήγει ο κώδικας να
# ξέρει ότι υπάρχει θηλυκό — δεν είναι δουλειά του (κανόνας του συγγραφέα,
# 25/07/2026: «το λογισμικό λειτουργεί με Fluent στα γαλλικά και στα
# αγγλικά από την αρχή»).
# ---------------------------------------------------------------------

ui-loading = Φόρτωση…
ui-editing = Επεξεργασία.
ui-viewing = Προβολή.
ui-modified-suffix = — τροποποιημένο
ui-label-required = Η περιγραφή είναι υποχρεωτική.
ui-discard-question = Απόρριψη των αλλαγών;
ui-yes = Ναι
ui-no = Όχι
ui-select-record = Επιλέξτε μια εγγραφή
ui-key-multiselect = CTRL
ui-multiselect-help = Πληροφορία: Χρησιμοποιήστε κλικ ποντικιού + πλήκτρο [{ $modifier }] στον πίνακα για να επιλέξετε πολλά στοιχεία
ui-no-match = Καμία περιγραφή δεν αντιστοιχεί στο φίλτρο.
ui-filter-placeholder = Φιλτράρισμα περιγραφών…
ui-column-label = ΠΕΡΙΓΡΑΦΗ
ui-field-label = Περιγραφη
ui-field-budget-line = Κονδύλι προϋπολογισμού
ui-identifier = Αναγνωριστικό
ui-deletion-abandoned = Η διαγραφή ματαιώθηκε: δεν τροποποιήθηκε τίποτα.
ui-unknown-nomenclature = Άγνωστα βασικά δεδομένα:

ui-title-filter = Φιλτράρισμα
ui-title-create = Δημιουργία
ui-title-update = Επεξεργασία επιλογής
ui-title-delete = Διαγραφή επιλογής
ui-title-read = Προβολή επιλογής
ui-title-close = Κλείσιμο
ui-title-save = Αποθήκευση
ui-title-add = Προσθήκη
ui-title-modify = Επεξεργασία

ui-load-failed = Αδύνατη η φόρτωση:
ui-save-failed = Αδύνατη η αποθήκευση:
ui-read-failed = Αδύνατη η ανάγνωση:
ui-delete-failed = Αδύνατη η διαγραφή:
ui-open-failed = Αδύνατο το άνοιγμα:
ui-close-failed = Αδύνατο το κλείσιμο:

# --- Φράσεις ιδιαίτερες για κάθε ομάδα βασικών δεδομένων -------------

nomenclature-identifier = { $kind ->
    [category] Αναγνωριστικο Κατηγοριας
    [assignment] Αναγνωριστικο Κατανομης
    [payment-mode] Αναγνωριστικο Τροπου πληρωμης
    [payee] Αναγνωριστικο Αντισυμβαλλομενου
    [project] Αναγνωριστικο Εργου
    [budget-line] Αναγνωριστικο Κονδυλιου προϋπολογισμου
   *[bank] Αναγνωριστικο Τραπεζας
}

nomenclature-none = { $kind ->
    [category] Καμία κατηγορία.
    [assignment] Καμία κατανομή.
    [payment-mode] Κανένας τρόπος πληρωμής.
    [payee] Κανένας αντισυμβαλλόμενος.
    [project] Κανένα έργο.
    [budget-line] Κανένα κονδύλι προϋπολογισμού.
   *[bank] Καμία τράπεζα.
}

nomenclature-nothing-to-show = { $kind ->
    [category] Καμία κατηγορία προς εμφάνιση.
    [assignment] Καμία κατανομή προς εμφάνιση.
    [payment-mode] Κανένας τρόπος πληρωμής προς εμφάνιση.
    [payee] Κανένας αντισυμβαλλόμενος προς εμφάνιση.
    [project] Κανένα έργο προς εμφάνιση.
    [budget-line] Κανένα κονδύλι προϋπολογισμού προς εμφάνιση.
   *[bank] Καμία τράπεζα προς εμφάνιση.
}

nomenclature-gone = { $kind ->
    [category] Αυτή η κατηγορία δεν υπάρχει πλέον.
    [assignment] Αυτή η κατανομή δεν υπάρχει πλέον.
    [payment-mode] Αυτός ο τρόπος πληρωμής δεν υπάρχει πλέον.
    [payee] Αυτός ο αντισυμβαλλόμενος δεν υπάρχει πλέον.
    [project] Αυτό το έργο δεν υπάρχει πλέον.
    [budget-line] Αυτό το κονδύλι προϋπολογισμού δεν υπάρχει πλέον.
   *[bank] Αυτή η τράπεζα δεν υπάρχει πλέον.
}

nomenclature-fresh = { $kind ->
    [category] Νέα κατηγορία.
    [assignment] Νέα κατανομή.
    [payment-mode] Νέος τρόπος πληρωμής.
    [payee] Νέος αντισυμβαλλόμενος.
    [project] Νέο έργο.
    [budget-line] Νέο κονδύλι προϋπολογισμού.
   *[bank] Νέα τράπεζα.
}

nomenclature-created = { $kind ->
    [category] Η κατηγορία προστέθηκε.
    [assignment] Η κατανομή προστέθηκε.
    [payment-mode] Ο τρόπος πληρωμής προστέθηκε.
    [payee] Ο αντισυμβαλλόμενος προστέθηκε.
    [project] Το έργο προστέθηκε.
    [budget-line] Το κονδύλι προϋπολογισμού προστέθηκε.
   *[bank] Η τράπεζα προστέθηκε.
}

nomenclature-updated = { $kind ->
    [category] Η κατηγορία τροποποιήθηκε.
    [assignment] Η κατανομή τροποποιήθηκε.
    [payment-mode] Ο τρόπος πληρωμής τροποποιήθηκε.
    [payee] Ο αντισυμβαλλόμενος τροποποιήθηκε.
    [project] Το έργο τροποποιήθηκε.
    [budget-line] Το κονδύλι προϋπολογισμού τροποποιήθηκε.
   *[bank] Η τράπεζα τροποποιήθηκε.
}

nomenclature-deleted = { $kind ->
    [category] { $count ->
        [one] 1 κατηγορία διαγράφηκε.
       *[other] { $count } κατηγορίες διαγράφηκαν.
      }
    [assignment] { $count ->
        [one] 1 κατανομή διαγράφηκε.
       *[other] { $count } κατανομές διαγράφηκαν.
      }
    [payment-mode] { $count ->
        [one] 1 τρόπος πληρωμής διαγράφηκε.
       *[other] { $count } τρόποι πληρωμής διαγράφηκαν.
      }
    [payee] { $count ->
        [one] 1 αντισυμβαλλόμενος διαγράφηκε.
       *[other] { $count } αντισυμβαλλόμενοι διαγράφηκαν.
      }
    [project] { $count ->
        [one] 1 έργο διαγράφηκε.
       *[other] { $count } έργα διαγράφηκαν.
      }
    [budget-line] { $count ->
        [one] 1 κονδύλι προϋπολογισμού διαγράφηκε.
       *[other] { $count } κονδύλια προϋπολογισμού διαγράφηκαν.
      }
   *[bank] { $count ->
        [one] 1 τράπεζα διαγράφηκε.
       *[other] { $count } τράπεζες διαγράφηκαν.
      }
}

nomenclature-duplicate-name = { $kind ->
    [category] Υπάρχει ήδη μια κατηγορία με το ίδιο όνομα: «{ $label }».
    [assignment] Υπάρχει ήδη μια κατανομή με το ίδιο όνομα: «{ $label }».
    [payment-mode] Υπάρχει ήδη ένας τρόπος πληρωμής με το ίδιο όνομα: «{ $label }».
    [payee] Υπάρχει ήδη ένας αντισυμβαλλόμενος με το ίδιο όνομα: «{ $label }».
    [project] Υπάρχει ήδη ένα έργο με το ίδιο όνομα: «{ $label }».
    [budget-line] Υπάρχει ήδη ένα κονδύλι προϋπολογισμού με το ίδιο όνομα: «{ $label }».
   *[bank] Υπάρχει ήδη μια τράπεζα με το ίδιο όνομα: «{ $label }».
}

# --- Τίτλοι παραθύρων, χωρίς τόνους όπως στα αρχικά παράθυρα ----------

window-list-title = { $kind ->
    [category] Λιστα κατηγοριων
    [assignment] Λιστα κατανομων
    [payment-mode] Λιστα τροπων πληρωμης
    [payee] Λιστα αντισυμβαλλομενων και εμπορων
    [project] Λιστα εργων
    [budget-line] Λιστα κονδυλιων προϋπολογισμου
   *[bank] Λιστα τραπεζων
}

window-form-title = { $kind ->
    [category] Καρτελα κατηγοριας
    [assignment] Καρτελα κατανομης
    [payment-mode] Καρτελα τροπου πληρωμης
    [payee] Καρτελα αντισυμβαλλομενου
    [project] Καρτελα εργου
    [budget-line] Καρτελα κονδυλιου προϋπολογισμου
   *[bank] Καρτελα τραπεζας
}

# --- Γραμμή μενού (01_CAHIER_DES_CHARGES.md §6) -----------------------

menu-file = Αρχείο
menu-file-import-statements = Εισαγωγή τραπεζικών καταστάσεων λογαριασμού
menu-file-import-excel = Εισαγωγή αρχείου Excel
menu-file-backup = Αντίγραφο ασφαλείας
menu-file-restore = Επαναφορά
menu-file-repair = Επιδιόρθωση και βελτιστοποίηση της βάσης δεδομένων
menu-file-log = Εμφάνιση του αρχείου καταγραφής
menu-tools-password = Προστασία της βάσης δεδομένων με κωδικό
menu-file-disconnect = Αποσύνδεση από την τρέχουσα βάση
menu-file-quit = Έξοδος

menu-accounts = Λογαριασμοί
menu-accounts-manage = Διαχείριση τραπεζικών λογαριασμών
menu-accounts-balances = Προβολή των υπολοίπων των λογαριασμών σας
menu-accounts-operations = Διαχείριση των κινήσεων ενός λογαριασμού
menu-accounts-quick-classify = Γρήγορη ταξινόμηση των κινήσεων
menu-accounts-recurring = Διαχείριση των επαναλαμβανόμενων κινήσεων
menu-accounts-transfer = Μεταφορά ποσού μεταξύ δύο λογαριασμών
menu-accounts-checkbooks = Διαχείριση των μπλοκ επιταγών

menu-statistics = Στατιστικά
menu-statistics-balance-chart = Γράφημα Εξέλιξη του υπολοίπου
menu-statistics-by-category = Στατ. ανά κατηγορία
menu-statistics-by-assignment = Στατ. ανά κατανομή
menu-statistics-by-budget-line = Στατ. ανά κονδύλι προϋπολογισμού
menu-statistics-by-payment-mode = Στατ. ανά τρόπο πληρωμής
menu-statistics-by-payee = Στατ. ανά αντισυμβαλλόμενο και έμπορο
menu-statistics-by-project = Στατ. ανά έργο
menu-statistics-dashboard = Πίνακας ελέγχου των κινήσεων

menu-budget = Προϋπολογισμός
menu-budget-entry = Καταχώριση προϋπολογισμού
menu-budget-control = Έλεγχος προϋπολογισμού

menu-nomenclatures = Βασικά δεδομένα
menu-nomenclature = { $kind ->
    [category] Κατηγορίες
    [assignment] Κατανομές
    [payment-mode] Τρόποι κίνησης
    [payee] Αντισυμβαλλόμενοι και έμποροι
    [project] Έργα
    [budget-line] Κονδύλια Προϋπολογισμού
   *[bank] Τράπεζες
}
menu-nomenclatures-templates = Πρότυπα κινήσεων

menu-settings = Ρυθμίσεις
menu-settings-about-author = Σχετικά με τον δημιουργό
menu-settings-about-radinus = Σχετικά με το Radinus
menu-settings-licence = Άδεια χρήσης

menu-misc = Διάφορα
menu-misc-calculator = Αριθμομηχανή
menu-misc-website = Μετάβαση στον ιστότοπο του Radinus
menu-misc-database-folder = Πρόσβαση στον φάκελο που περιέχει τη βάση δεδομένων

# L'avertissement posé devant ce dossier (Fabrice, 08/08/2026) : « un
# utilisateur ignorant peut faire des bêtises ». La question est posée
# avant l'ouverture, jamais après.
database-folder-warning-title = Άνοιγμα του φακέλου της βάσης δεδομένων
database-folder-warning =
    Αυτός ο φάκελος περιέχει όλα τα δεδομένα σας. Η μετονομασία, η μετακίνηση ή η διαγραφή ενός αρχείου μπορεί να χάσει τους λογαριασμούς σας, να τους αλλοιώσει ή να εμποδίσει το Radinus να λειτουργήσει.
    Θέλετε πραγματικά να τον ανοίξετε;
menu-misc-application-folder = Πρόσβαση στον φάκελο που περιέχει την εφαρμογή
menu-misc-attachments-folder = Πρόσβαση στον φάκελο με τα συνημμένα
# --- « Gestion des pièces jointes » (08/08/2026) -------------------------
#
# La fenêtre montre les pièces de toutes les opérations, plus les fichiers
# du dossier que la base ne réclame pas. Les cinq états ne sont pas trois :
# un fichier disparu, un fichier modifié et un fichier qu'on ne sait pas
# juger ne se traitent pas de la même façon.
menu-settings-attachments = Διαχείριση των συνημμένων
window-attachments-manager-title = Διαχείριση των συνημμένων
attachments-column-document = Έγγραφο
attachments-column-size = Μέγεθος
attachments-column-added = Προστέθηκε στις
attachments-column-state = Κατάσταση
attachments-state-intact = Ανέπαφο
attachments-state-altered = Άλλαξε έκτοτε
attachments-state-missing = Λείπει το αρχείο
attachments-state-unknown = Μη επαληθεύσιμο
attachments-state-orphan = Ορφανό
attachments-no-operation = Καμία κίνηση
attachments-orphan-remove-question = Αυτό το αρχείο δεν συνδέεται με καμία κίνηση. Να μεταφερθεί στον κάδο;
attachments-manager-help = Κάντε διπλό κλικ σε μια γραμμή για να ανοίξετε το έγγραφο.

# Les deux entrées du clic droit. « Afficher l'opération » n'apparaît pas
# sur un orphelin — il n'appartient à aucune opération — et « Révéler »
# disparaît quand le fichier n'est plus sur le disque.
attachments-show-operation = Εμφάνιση της κίνησης
attachments-reveal = Εμφάνιση στον διαχειριστή αρχείων
attachments-manager-summary = { $count } συνημμένα, { $size } συνολικά.
attachments-disk-name = Όνομα στον δίσκο: { $name }

# L'avertissement du dossier des pièces jointes (Fabrice, 08/08/2026).
# Le danger n'y est pas le même que pour la base : on ne perd pas des
# comptes, on casse un lien — l'opération annonce une pièce qui ne
# s'ouvre plus. C'est ce que dit la phrase, plutôt que « ne faites pas
# n'importe quoi ».
attachments-folder-warning-title = Άνοιγμα του φακέλου των συνημμένων
attachments-folder-warning =
    Αυτός ο φάκελος περιέχει τα αρχεία που επισυνάψατε στις κινήσεις σας. Το Radinus τα αποθηκεύει με όνομα που επιλέγει το ίδιο: η μετονομασία, η μετακίνηση ή η διαγραφή ενός αρχείου δεν το αποσυνδέει από την κίνηση, η οποία θα συνεχίσει να το αναγγέλλει χωρίς να ανοίγει πια.
    Θέλετε πραγματικά να τον ανοίξετε;

# ---------------------------------------------------------------------
# Τραπεζικοί λογαριασμοί — F04, F06, F07, F08.
# Τα τυπογραφικά λάθη της έκδοσης 1.9.3 («Bank Identifer Code», «Solde
# initial prevu», «Est Cloturé», το κενό πριν από την παρένθεση του IBAN)
# διορθώνονται: απόφαση του Fabrice της 25/07/2026.
# ---------------------------------------------------------------------

window-accounts-title = Διαχείριση τραπεζικών λογαριασμών
window-accounts-select-title = Λίστα λογαριασμών
window-balances-title = Υπόλοιπα των λογαριασμών σας
window-account-title = Καρτέλα λογαριασμού

accounts-none = Κανένας λογαριασμός.
accounts-nothing-to-show = Κανένας λογαριασμός προς εμφάνιση.
accounts-gone = Αυτός ο λογαριασμός δεν υπάρχει πλέον.
accounts-fresh = Νέος λογαριασμός.
accounts-created = Ο λογαριασμός προστέθηκε.
accounts-updated = Ο λογαριασμός τροποποιήθηκε.
accounts-deleted = { $count ->
    [one] 1 λογαριασμός διαγράφηκε.
   *[other] { $count } λογαριασμοί διαγράφηκαν.
}
accounts-duplicate-name = Υπάρχει ήδη λογαριασμός με το ίδιο όνομα: «{ $label }».
accounts-multiselect-help = Πληροφορία: Χρησιμοποιήστε Κλικ ποντικιού + πλήκτρο [{ $modifier }] στον πίνακα για να επιλέξετε πολλούς λογαριασμούς
accounts-select-question = Σε ποιους τραπεζικούς λογαριασμούς πρέπει να βασιστούν τα στατιστικά;

accounts-column-label = ΠΕΡΙΓΡΑΦΗ
accounts-column-bank = Τράπεζα
accounts-column-type = Τύπος λογ.
accounts-column-number = Αρ. λογ.
accounts-column-account = Λογαριασμός
accounts-column-bank-balance = Στην Τράπεζα
accounts-column-real-balance = Πραγματικό
accounts-column-final-balance = Τελικό
accounts-total = ΣΥΝΟΛΟ

# Η διαγραφή ενός λογαριασμού παρασύρει και τις κινήσεις του: είναι το μόνο σημείο
# του λογισμικού όπου μια διαγραφή καταστρέφει ιστορικό.
accounts-delete-plain = Επιβεβαιώνετε τη διαγραφή του λογαριασμού «{ $label }»;
accounts-delete-with-operations = Ο λογαριασμός «{ $label }» περιέχει { $count } κινήσεις, οι οποίες θα διαγραφούν μαζί του. Επιβεβαιώνετε τη διαγραφή;
accounts-delete-form-open = Η καρτέλα του λογαριασμού «{ $label }» είναι ανοιχτή. Κλείστε την πριν από τη διαγραφή.

account-group-bank = Στοιχεία λογαριασμού και τράπεζας
account-group-holder = Δικαιούχος
account-group-rib = Τραπεζικά στοιχεία (RIB)
account-group-activity = Δραστηριότητα
account-group-balances = Υπόλοιπα

account-field-label = Όνομα λογαριασμού
account-field-bank = Τράπεζα
account-field-type = Τύπος λογαριασμού
account-field-branch-address = Διεύθυνση τραπεζικού καταστήματος
account-field-holder-name = Όνομα
account-field-holder-address = Διεύθυνση
account-field-rib-bank = Ίδρυμα
account-field-rib-branch = Κωδικός καταστήματος
account-field-rib-number = Αριθμός λογαριασμού
account-field-rib-key = Κλειδί RIB
account-field-bic = BIC (Bank Identifier Code)
account-field-iban = IBAN (International Bank Account Number)
account-field-opening-date = Ημερομηνία ανοίγματος
account-field-closing-date = Ημερομηνία κλεισίματος
account-field-closed = Είναι κλειστός
account-field-opening-pointed = Αρχικό υπόλοιπο συμφωνημένο
account-field-opening-committed = Αρχικό υπόλοιπο δεσμευμένο
account-field-opening-planned = Αρχικό υπόλοιπο προγραμματισμένο

account-label-required = Το όνομα του λογαριασμού είναι υποχρεωτικό.
account-iban-invalid = Αυτό το IBAN δεν είναι έγκυρο: ελέγξτε τα ψηφία ελέγχου.
# Η μπλε γραμμή στο κάτω μέρος της καρτέλας, λέξη προς λέξη αυτή της 1.9.3 — μόνο
# τα ποσά ακολουθούν πλέον τη γαλλική μορφή των υπόλοιπων πεδίων.
account-control-line = Αρχικό υπόλοιπο συμφωνημένο ({ $opening }) + Σύνολο των κινήσεων ({ $operations }) = Τρέχον τραπεζικό υπόλοιπο: { $balance }.

amount-not-readable = Το «{ $field }» δεν περιέχει έγκυρο ποσό.

ui-thousands-separator = .
ui-decimal-separator = ,

# --- Λίστα κινήσεων (F02) --------------------------------------------

window-operations-title = Λίστα κινήσεων του λογαριασμού: { $account }

operations-none = Καμία κίνηση σε αυτήν την περίοδο.
operations-bad-period = Τα όρια της περιόδου δεν είναι έγκυρες ημερομηνίες.
operations-from = Ημ/νία έναρξης
operations-to = Ημ/νία λήξης
operations-delete-confirm = { $count ->
    [one] Επιβεβαιώνετε τη διαγραφή αυτής της κίνησης;
   *[other] Επιβεβαιώνετε τη διαγραφή αυτών των { $count } γραμμών; Οι υποκινήσεις των επιλεγμένων κινήσεων διαγράφονται μαζί τους.
}
operations-deleted = { $count ->
    [one] 1 κίνηση διαγράφηκε.
   *[other] { $count } κινήσεις διαγράφηκαν.
}
operations-selection-total = Συνολικό ποσό των επιλεγμένων κινήσεων: { $amount }

operations-column-date = Ημερομηνία
operations-column-clearing-date = Ημ/νία Συμφωνίας
operations-column-label = Περιγραφή
operations-column-category = Κατηγορία
operations-column-assignment = Κατανομή
operations-column-payment-mode = ΤρόποςΚίν
operations-column-payee = Αντισυμβ.
operations-column-project = Έργα
operations-column-month = Μήνας
operations-column-debit = Χρέωση
operations-column-credit = Πίστωση
operations-column-balance = Υπόλοιπο
operations-column-comments = Σχόλια
operations-column-attachments = Συνημμένα
operations-column-check = Αρ. Επιταγής

operations-foot-debit = Χρέωση:
operations-foot-credit = Πίστωση:
operations-foot-total = Σύνολο:
operations-foot-bank = Τραπεζικό υπόλοιπο:
operations-foot-real = Πραγματικό υπόλοιπο:
operations-foot-final = Τελικό υπόλοιπο:

operations-menu-export = Εξαγωγή
operations-menu-print = Εκτύπωση
operations-menu-filter = Φίλτρο
operations-menu-period = Περίοδος
operations-menu-misc = Διάφορα

operations-title-point = Συμφωνία της επιλογής
operations-title-sub = Προσθήκη υποκίνησης
operations-title-duplicate = Αντιγραφή της επιλογής
operations-not-yet = Αυτό το παράθυρο δεν υπάρχει ακόμη: έρχεται αργότερα στο πλάνο.

accounts-choose-question = Σε ποιον λογαριασμό θέλετε να εργαστείτε;
ui-title-select = Επιλογή

month-january = Ιανουάριος
month-february = Φεβρουάριος
month-march = Μάρτιος
month-april = Απρίλιος
month-may = Μάιος
month-june = Ιούνιος
month-july = Ιούλιος
month-august = Αύγουστος
month-september = Σεπτέμβριος
month-october = Οκτώβριος
month-november = Νοέμβριος
month-december = Δεκέμβριος

operations-period-year = Τρέχον έτος

# --- Μενού Περίοδος του F02 ------------------------------------------
# Εννέα καταχωρίσεις, δύο από τις οποίες ανοίγουν υπομενού των δώδεκα μηνών. Καθεμία
# κάνει ένα μόνο πράγμα: να συνάγει μια ημερομηνία έναρξης και μια ημερομηνία λήξης,
# τις οποίες το παράθυρο ξαναβάζει στα δύο πεδία του (αίτημα του Fabrice, 25/07/2026).

period-all = Όλες
period-last-year = Περασμένο Έτος
period-this-year = Τρέχον Έτος
period-whole-year = Όλο το έτος
period-last-month = Περασμένος Μήνας
period-this-month = Τρέχων Μήνας
period-last-week = Περασμένη Εβδομάδα
period-this-week = Τρέχουσα Εβδομάδα
period-yesterday = Χθες
period-today = Σήμερα

# --- Μενού Φίλτρο του F02 ---------------------------------------------
# Φιλτράρει τις γραμμές ανάλογα με τη φύση της κίνησης (αίτημα του Fabrice,
# 25/07/2026). Οι τρεις καταστάσεις είναι αυτές της βάσης: 1 συμφωνημένη,
# 2 δεσμευμένη, 3 προγραμματισμένη (02_BASE_DE_DONNEES.md §5.2).

filter-all = Όλες οι κινήσεις
filter-pointed = Μόνο οι συμφωνημένες κινήσεις
filter-committed = Μόνο οι δεσμευμένες κινήσεις
filter-planned = Μόνο οι προγραμματισμένες κινήσεις

# --- Καρτέλα κίνησης (F03) --------------------------------------------
# Οι τίτλοι είναι αυτοί της εικόνας «Fiche operation transaction.png», με τα
# τυπογραφικά λάθη του πρωτοτύπου διορθωμένα (άδεια του Fabrice, 25/07/2026:
# «les coquilles tu les corriges»): το «Libelle» γίνεται «Libellé», το
# «Categorie» γίνεται «Catégorie», το «Statut Operation» γίνεται
# «Statut opération».

window-operation-title = Κίνηση λογαριασμού: { $account }

operation-menu-identification = Στοιχεία
operation-menu-options = Επιλογές
operation-fitid-edit = Επεξεργασία του αναγνωριστικού FITID…
operation-fitid-delete = Διαγραφή του αναγνωριστικού FITID
operation-fitid-question = Αναγνωριστικό FITID αυτής της κίνησης:
operation-fitid-delete-question = Διαγραφή του αναγνωριστικού FITID αυτής της κίνησης;
operation-fitid-written = Το αναγνωριστικό FITID αποθηκεύτηκε.
operation-fitid-removed = Το αναγνωριστικό FITID διαγράφηκε.

operation-group-identification = Στοιχεία της κίνησης
operation-group-amount = Ποσό της κίνησης
operation-group-status = Κατάσταση της κίνησης
operation-group-classification = Ταξινόμηση της κίνησης για τον υπολογισμό των στατιστικών
operation-group-check = Επιταγή που σχετίζεται με την κίνηση
operation-group-comment = Σχόλιο

operation-field-label = Περιγραφή
operation-field-reference = Αναφορά πληρωμής
operation-field-date = Ημερομηνία
operation-field-direction = Τύπος κίνησης:
operation-field-amount = Ποσό
operation-field-status = Κατάσταση κίνησης
operation-field-clearing-date = Ημερομηνία συμφωνίας
operation-field-category = Κατηγορία
operation-field-assignment = Κατανομή
operation-field-payment-mode = Τρόπος
operation-field-payee = Αντισυμβαλλόμενος
operation-field-project = Έργο
operation-field-check = Σύνδεση με επιταγή

operation-direction-debit = Χρέωση
operation-direction-credit = Πίστωση

operation-check-info = Πληροφ.
operation-check-link = Σύνδεση
operation-check-unlink = Διαγραφή

operation-fresh = Νέα κίνηση.
operation-created = Η κίνηση προστέθηκε.
operation-updated = Η κίνηση τροποποιήθηκε.
operation-gone = Αυτή η κίνηση δεν υπάρχει πλέον.
operation-nothing-to-show = Καμία κίνηση προς εμφάνιση.
operation-label-required = Η περιγραφή της κίνησης είναι υποχρεωτική.
operation-date-required = Η ημερομηνία της κίνησης είναι υποχρεωτική.
operation-clearing-date-invalid = Η ημερομηνία συμφωνίας δεν είναι έγκυρη ημερομηνία.
operation-is-a-sub = Αυτή η γραμμή είναι υποκίνηση: τροποποιείται από τη δική της καρτέλα.
operation-delete-form-open = Η καρτέλα του «{ $label }» είναι ανοιχτή. Κλείστε την πριν από τη διαγραφή.

operation-attachments = { $count ->
    [0] Κανένα συνημμένο
    [one] 1 συνημμένο
   *[other] { $count } συνημμένα
}

operation-title-comment = Σχόλιο της κίνησης
operation-title-sub = Δημιουργία υποκίνησης
operation-title-template = Πρότυπα κινήσεων
operation-title-attachment = Συνημμένα

# --- Καρτέλα υποκίνησης (F04) -----------------------------------------
# Περιορισμένη εκδοχή του F03: ούτε Τρόπος, ούτε Κατάσταση, ούτε Ημερομηνία —
# μια υποκίνηση τα παίρνει από τη μητρική της (`Maj_ProprieteSousOp`,
# επιβεβαιωμένο από τον Fabrice στις 26/07/2026: «dans une sous-opération,
# comme est le complément, on ne peut pas toucher au mode de paiement, cela
# serait illogique»).

window-sub-operation-title = Καρτέλα υποκίνησης

sub-operation-group-amount = Ποσό της υποκίνησης
sub-operation-field-label = Όνομα
sub-operation-fresh = Νέα υποκίνηση.
sub-operation-created = Η υποκίνηση προστέθηκε.
sub-operation-updated = Η υποκίνηση τροποποιήθηκε.
sub-operation-gone = Αυτή η υποκίνηση δεν υπάρχει πλέον.
sub-operation-nothing-to-show = Καμία υποκίνηση προς εμφάνιση.
sub-operation-label-required = Το όνομα της υποκίνησης είναι υποχρεωτικό.
sub-operation-parent-gone = Η κίνηση προς επιμερισμό δεν υπάρχει πλέον.
# Τι λέει η καρτέλα όταν δείχνει το Συμπλήρωμα. Δεν είναι προστατευμένο:
# μπορεί να τροποποιηθεί, αλλά πρέπει να ξέρει κανείς τι αναλαμβάνει (απόφαση
# του Fabrice, 26/07/2026).
sub-operation-is-the-complement = Αυτό είναι το Συμπλήρωμα: ό,τι απομένει προς επιμερισμό. Αν το μετονομάσετε ή αλλάξετε το ποσό του, γίνεται συνηθισμένη υποκίνηση.
sub-operation-of = Επιμερισμός του «{ $label }» ({ $amount })

operations-pointed = { $count ->
    [one] 1 συμφωνημένη κίνηση.
   *[other] { $count } συμφωνημένες κινήσεις.
}
operations-select-one = Παρακαλώ επιλέξτε μία μόνο κίνηση.

# --- Αντιγραφή και εμφάνιση των υποκινήσεων (F02) ----------------------
# Η αντιγραφή ανοίγει μια προσυμπληρωμένη καρτέλα που την επιβεβαιώνει ο ίδιος
# ο χρήστης (απόφαση του Fabrice, 26/07/2026): τίποτα δεν γράφεται όσο δεν
# έχει αποθηκεύσει, και μπορεί πριν να διορθώσει την ημερομηνία ή το ποσό.

operation-copy = Αντίγραφο προς αποθήκευση: τίποτα δεν έχει δημιουργηθεί ακόμη.
operations-show-children = Εμφάνιση όλων των υποκινήσεων
operations-hide-children = Απόκρυψη όλων των υποκινήσεων

# --- Δεύτερη επιβεβαίωση μιας σοβαρής διαγραφής ------------------------
# Η διαγραφή ενός τραπεζικού λογαριασμού παρασύρει όλο το ιστορικό του: ένα
# Ναι/Όχι πατιέται χωρίς διάβασμα, οπότε ζητάμε να γραφτεί η λέξη (απόφαση
# του Fabrice, 26/07/2026). Η λέξη είναι αυτή του λεξικού — «Ναι» εδώ, «Yes»
# στα αγγλικά — άρα τίποτα δεν χρειάζεται να μεταφραστεί δύο φορές εδώ.

accounts-delete-second-question = Αυτή η διαγραφή είναι οριστική και παρασύρει όλο το ιστορικό του λογαριασμού. Πληκτρολογήστε «{ $word }» για να την επιβεβαιώσετε.

# --- F20-F24 — Τα έξι στατιστικά --------------------------------------
# Κοινό πρότυπο, σε έξι άξονες. Αυτό ανά κατηγορία χρησίμευσε ως υπόδειγμα και
# ο Fabrice το ενέκρινε στις 26/07/2026 πριν υπάρξουν τα άλλα πέντε — τα
# ονόματα των στηλών είναι αυτά του πρωτοτύπου.

window-statistics-title = { $kind ->
    [assignment] Στατιστικά ανά κατανομή
    [budget-line] Στατιστικά ανά κονδύλι προϋπολογισμού
    [payment-mode] Στατιστικά ανά τρόπο πληρωμής
    [payee] Στατιστικά ανά αντισυμβαλλόμενο και έμπορο
    [project] Στατιστικά ανά έργο
   *[category] Στατιστικά ανά κατηγορία
}

statistics-axis-column = { $kind ->
    [assignment] Κατανομή
    [budget-line] ΚονδύλιΠροϋπ
    [payment-mode] ΤρόποςΚίνησης
    [payee] Αντισυμβαλλόμενος
    [project] Έργα
   *[category] ΌνομαΚατηγορίας
}

statistics-unclassified = { $kind ->
    [assignment] Χωρίς κατανομή
    [budget-line] Χωρίς κονδύλι προϋπολογισμού
    [payment-mode] Χωρίς τρόπο πληρωμής
    [payee] Χωρίς αντισυμβαλλόμενο
    [project] Χωρίς έργο
   *[category] Χωρίς κατηγορία
}
statistics-total = Σύνολο
statistics-sum = Άθροισμα
statistics-cumulative = Σωρευτικό

# Οι πέντε διακόπτες της μπάρας. Η ετικέτα εναλλάσσεται ON/OFF, όπως στο
# πρωτότυπο: ο ίδιος ο διακόπτης λέει πού βρίσκεται.
statistics-switch-pointed = Συμφωνημένες κινήσεις { $state }
statistics-switch-committed = Δεσμευμένες κινήσεις { $state }
statistics-switch-planned = Προγραμματισμένες κινήσεις { $state }
statistics-switch-debits = Ποσά χρεώσεων { $state }
statistics-switch-credits = Ποσά πιστώσεων { $state }
statistics-switch-on = ON
statistics-switch-off = OFF

statistics-no-account = Δεν επιλέχθηκε κανένας λογαριασμός: τα στατιστικά δεν αφορούν τίποτα.
statistics-no-data = Καμία κίνηση αυτό το έτος για τους επιλεγμένους λογαριασμούς.
statistics-detail-empty = Κάντε κλικ σε ένα κελί με αριθμό για να δείτε τις κινήσεις που μετράει.
statistics-detail-none = Καμία κίνηση πίσω από αυτό το κελί.
statistics-accounts = { $count ->
    [one] 1 λογαριασμός
   *[other] { $count } λογαριασμοί
}
statistics-year-next = Επόμενο έτος
statistics-year-previous = Προηγούμενο έτος

statistics-column-date = Ημερομηνία
statistics-column-clearing-date = ΗμερομΣυμφωνίας
statistics-column-label = Περιγραφή
statistics-column-amount = Ποσό
statistics-column-comments = Σχόλια

accounts-stats-multiselect-help = Πληροφορία: Χρησιμοποιήστε κλικ ποντικιού + πλήκτρο [{ $modifier }] στον πίνακα για να επιλέξετε πολλούς λογαριασμούς

# Το έτος των στατιστικών: κάνετε κλικ πάνω του και εισάγετε ένα έτος. Τα όρια
# είναι αυτά του «Όλες» του μενού Περίοδος — ένα έτος του Radinus είναι
# ακέραιος μεταξύ 1950 και 2550 (Fabrice, 26/07/2026).
statistics-year-question = Σε ποιο έτος θέλετε να εργαστείτε; Το Radinus πάει από { $first } έως { $last }.
statistics-year-choose = Επιλογή έτους

# --- Εξαγωγή των πινάκων (δεξί κλικ) ----------------------------------
# Λειτουργία του πίνακα, όχι ενός παραθύρου: την έχουν όλες οι λίστες.

export-to-excel = Εξαγωγή σε Excel (.xlsx)
export-to-word = Εξαγωγή σε Word (.docx)
export-to-tsv = Εξαγωγή σε TSV (.tsv)
export-to-ini = Εξαγωγή σε INI (.ini)
export-to-toml = Εξαγωγή σε TOML (.toml)
export-to-yaml = Εξαγωγή σε YAML (.yaml)
export-to-ofx = Εξαγωγή σε OFX (.ofx)
export-to-qif = Εξαγωγή σε QIF (.qif)
export-to-ods = Εξαγωγή σε LibreOffice Calc (.ods)
export-to-csv = Εξαγωγή σε CSV (.csv)
export-to-xml = Εξαγωγή σε XML (.xml)
# Το μενού Εξαγωγή του παραθύρου των στατιστικών: μία καρτέλα ανά έτος, με
# όνομα AN_2026. Τα κενά έτη — με τους διακόπτες όπως έχουν τεθεί — δεν
# περιλαμβάνονται.
export-menu = Εξαγωγή
export-all-years-excel = Εξαγωγή όλων των ετών σε Excel
export-all-years-ods = Εξαγωγή όλων των ετών σε LibreOffice Calc
export-no-year = Κανένα έτος δεν έχει κινήσεις: δεν υπάρχει τίποτα προς εξαγωγή.
export-years-done = { $years } έτη εξήχθησαν στο «{ $file }».
export-to-json = Εξαγωγή σε JSON (.json)
export-done = Εξήχθη στο «{ $file }».
export-failed = Αδύνατη η εξαγωγή: { $reason }
export-nothing = Δεν υπάρχει τίποτα προς εξαγωγή.
export-context = { $window } — { $detail }
statistics-window-name = { $kind ->
    [assignment] Στατιστικά ανά κατανομή
    [budget-line] Στατιστικά ανά κονδύλι προϋπολογισμού
    [payment-mode] Στατιστικά ανά τρόπο πληρωμής
    [payee] Στατιστικά ανά αντισυμβαλλόμενο και έμπορο
    [project] Στατιστικά ανά έργο
   *[category] Στατιστικά ανά κατηγορία
}
statistics-detail-name = Λεπτομέρεια των στατιστικών

# --- F19 — Πίνακας ελέγχου --------------------------------------------
# Μία περίοδος και τρεις διακόπτες· δύο δακτυλιοειδή διαγράμματα ανά κονδύλι
# προϋπολογισμού· τρεις μεγάλοι αριθμοί. Τα χρώματα των τομέων είναι εκείνα
# του πρωτοτύπου, παρμένα από τη λήψη οθόνης του Fabrice.

window-dashboard-title = Πίνακας ελέγχου
dashboard-menu-period = Περίοδος
dashboard-menu-misc = Διάφορα
dashboard-from = Ημερομηνία έναρξης:
dashboard-to = Ημερομηνία τέλους:
dashboard-switch-pointed = Συμπερίληψη συμφωνημένων κινήσεων
dashboard-switch-committed = Συμπερίληψη δεσμευμένων κινήσεων
dashboard-switch-planned = Συμπερίληψη προγραμματισμένων κινήσεων
dashboard-spending = Δαπάνες
dashboard-earning = Έσοδα
dashboard-debits = Σύνολο χρεωστικών κινήσεων
dashboard-credits = Σύνολο πιστωτικών κινήσεων
dashboard-balance = Ισοζύγιο
dashboard-unclassified = Χωρίς κονδύλι προϋπολογισμού
dashboard-nothing = Καμία κίνηση σε αυτήν την περίοδο.
dashboard-no-account = Δεν επιλέχθηκε κανένας λογαριασμός: ο πίνακας ελέγχου δεν αφορά τίποτα.
dashboard-enlarge = Άνοιγμα σε μεγέθυνση

# --- F25 — Εξέλιξη του υπολοίπου ------------------------------------------
# Ένα γράφημα ανά επιλεγμένο λογαριασμό, συν εκείνο του συνόλου — που υπάρχει
# μόνο από δύο λογαριασμούς και πάνω (κανόνας του Fabrice, 26/07/2026). Τα
# γραφήματα είναι κλιμακωτά: το υπόλοιπο διατηρεί την τιμή του μέχρι την
# επόμενη κίνηση.

window-curve-title = Εξέλιξη του υπολοίπου
curve-heading = Εξέλιξη του υπολοίπου ανά ημέρα
curve-menu-period = Περίοδος
curve-total = Σύνολο
curve-from = Ημερομηνία έναρξης:
curve-to = Ημερομηνία τέλους:
curve-axis-balance = υπόλοιπο
curve-nothing = Δεν επιλέχθηκε κανένας λογαριασμός: δεν υπάρχει γράφημα για σχεδίαση.
curve-empty = Καμία κίνηση σε αυτήν την περίοδο.

# --- F05 — Γρήγορη ταξινόμηση των κινήσεων ------------------------
# Το παράθυρο όπου ταξινομεί κανείς **μαζικά**: επιλέγει γραμμές, τσεκάρει τα
# χαρακτηριστικά προς αλλαγή και τα εφαρμόζει με μία κίνηση — στη μνήμη.
# Τίποτα δεν γράφεται όσο δεν έχει γίνει αποθήκευση, και η αποθήκευση γράφει
# μόνο ό,τι διαφέρει από αυτό που διαβάστηκε (κανόνες του Fabrice,
# 27/07/2026).

window-quick-classification-title = Γρήγορη ταξινόμηση των κινήσεων: { $account }
quick-dates-title = Ημερομηνίες αρχής και τέλους της λίστας.
quick-from = Ημερομηνία έναρξης
quick-to = Ημερομηνία τέλους
quick-menu-period = Περίοδος
quick-change-title = Αλλαγή χαρακτηριστικών της επιλογής σε:
quick-check-category = Κατηγορία
quick-check-assignment = Κατανομή
quick-check-payment-mode = Τρόπος
quick-check-payee = Αντισυμβαλλόμενος
quick-check-project = Έργο
quick-check-status = Κατάσταση
quick-column-date = Ημερομηνία
quick-column-label = Περιγραφή
quick-column-amount = Ποσό
quick-column-category = Κατηγορία
quick-column-assignment = Κατανομή
quick-column-payment-mode = Τρόπος πληρωμής
quick-column-payee = Αντισυμβαλλόμενος
quick-column-project = Έργα
quick-column-status = Κατάσταση
# Σε Mac, Ctrl + κλικ είναι δεξί κλικ: το πλήκτρο που προσθέτει σε μια επιλογή
# είναι εκεί το ⌘, και η βοήθεια πρέπει να αναφέρει αυτό που δουλεύει.
quick-multiselect-help = Πληροφορία: Χρησιμοποιήστε κλικ ποντικιού + πλήκτρο [{ $modifier }] στον πίνακα για να επιλέξετε πολλά στοιχεία
quick-none = Καμία κίνηση σε αυτήν την περίοδο.
quick-select-lines = Επιλέξτε τουλάχιστον μία γραμμή και τσεκάρετε τουλάχιστον ένα χαρακτηριστικό.
quick-applied = { $count ->
    [0] Τίποτα δεν άλλαξε: αυτές οι γραμμές είχαν ήδη αυτήν την ταξινόμηση.
    [one] 1 γραμμή ταξινομήθηκε. Τίποτα δεν έχει αποθηκευτεί ακόμη.
   *[other] { $count } γραμμές ταξινομήθηκαν. Τίποτα δεν έχει αποθηκευτεί ακόμη.
}
quick-pending = { $count ->
    [0] Καμία εκκρεμής τροποποίηση.
    [one] 1 γραμμή τροποποιήθηκε, μη αποθηκευμένη.
   *[other] { $count } γραμμές τροποποιήθηκαν, μη αποθηκευμένες.
}
quick-save-question = { $count ->
    [one] Αποθήκευση της εκκρεμούς τροποποίησης;
   *[other] Αποθήκευση των { $count } εκκρεμών τροποποιήσεων;
}
quick-saved = { $count ->
    [0] Δεν υπήρχε τίποτα προς αποθήκευση.
    [one] 1 γραμμή αποθηκεύτηκε.
   *[other] { $count } γραμμές αποθηκεύτηκαν.
}
quick-nothing-to-save = Καμία εκκρεμής τροποποίηση.
quick-leave-question = Ορισμένες τροποποιήσεις δεν έχουν αποθηκευτεί. Τι θέλετε να κάνετε;
quick-leave-save = Αποθήκευση και έξοδος
quick-leave-discard = Απόρριψη και έξοδος
quick-leave-stay = Παραμονή
quick-title-apply = Εφαρμογή στις επιλεγμένες γραμμές ( στη μνήμη )
quick-title-save = Αποθήκευση στον δίσκο

# --- F17 / F18 — Εισαγωγή κατάστασης τραπεζικού λογαριασμού ----------------------
# Επιλέγει κανείς έναν λογαριασμό, ανοίγει ένα αρχείο OFX — που μένει στη RAM
# —, οι γραμμές που η βάση γνωρίζει ήδη εμφανίζονται σε παστέλ, και το τρίτο
# εικονίδιο τις εντάσσει: μαζικά αν έχουν επιλεγεί πολλές, μία προς μία μέσω
# της καρτέλας συμφωνίας αλλιώς (οδηγίες του Fabrice, 27/07/2026).

window-statement-import-title = Εισαγωγή καταστάσεων τραπεζικών λογαριασμών: { $account }
window-statement-form-title = Συμφωνία μιας συναλλαγής (Εντάσσει μια κίνηση στο ιστορικό του λογαριασμού σας)
statement-menu-filter = Φίλτρο
statement-filter-all = Όλες οι γραμμές
statement-filter-pending = Προς ένταξη
statement-filter-known = Ήδη ενταγμένες
statement-column-id = ID
statement-column-reconciled = Συμφωνημένη
statement-column-fitid = FITID
statement-column-date = Ημερομηνία
statement-column-label = Περιγραφή
statement-column-debit = Χρέωση
statement-column-credit = Πίστωση
statement-account = Λογαριασμός
statement-file = Αρχείο
statement-difference = Διαφορά
statement-none = Δεν έχει ανοίξει καμία κατάσταση λογαριασμού: κάντε κλικ στον κίτρινο φάκελο για να επιλέξετε ένα αρχείο.
statement-empty = Αυτή η κατάσταση λογαριασμού δεν περιέχει καμία κίνηση.
statement-no-match = Καμία γραμμή δεν αντιστοιχεί στο φίλτρο.
statement-help = Πληροφορία: Χρησιμοποιήστε κλικ ποντικιού + πλήκτρο [{ $modifier }] στον πίνακα για να επιλέξετε πολλές γραμμές
statement-choose-account = Αυτό το αρχείο περιέχει πολλούς λογαριασμούς. Ποιον θέλετε να εισαγάγετε;
statement-select-line = Επιλέξτε τουλάχιστον μία γραμμή της κατάστασης λογαριασμού.
statement-title-open = Άνοιγμα αρχείου κατάστασης λογαριασμού (.ofx)
statement-title-info = Πληροφορίες για το ανοιχτό αρχείο
statement-title-integrate = Ένταξη της επιλογής στον λογαριασμό
statement-title-validate = Ένταξη αυτής της κίνησης στον λογαριασμό
statement-duplicate = Προσοχή διπλότυπο: αυτή η συναλλαγή φαίνεται ότι έχει ήδη ενταχθεί στη βάση δεδομένων (το Financial Institution Transaction ID υπάρχει)
statement-no-fitid = Προσοχή: αυτό το αρχείο δεν δίνει κανένα αναγνωριστικό (FITID) για αυτήν τη γραμμή. Δεν θα μπορεί να εντοπιστεί διπλότυπο.
statement-loaded = { $count ->
    [0] Αυτό το αρχείο δεν περιέχει καμία κίνηση για αυτόν τον λογαριασμό.
   *[other] { $count } γραμμές διαβάστηκαν, εκ των οποίων { $known } υπάρχουν ήδη στον λογαριασμό σας.
}
statement-integrated = { $count ->
    [0] Τίποτα δεν εισήχθη: αυτές οι γραμμές βρίσκονται ήδη στον λογαριασμό σας.
    [one] 1 κίνηση εντάχθηκε.
   *[other] { $count } κινήσεις εντάχθηκαν.
}
# **Τα μηνύματα του πρωτοτύπου, λέξη προς λέξη** (οδηγία του Fabrice,
# 28/07/2026: να μείνουμε πιστοί στον αρχικό κώδικα). Το δικό του προειδοποιεί
# πριν από τη δέσμη, ρωτά γραμμή προς γραμμή μπροστά σε ένα διπλότυπο, και
# δίνει λογαριασμό στο τέλος.

statement-mass-question =
    Είστε βέβαιοι ότι θέλετε να εντάξετε στον λογαριασμό σας ταυτόχρονα πολλές κινήσεις;
    Θα πρέπει να τις κατηγοριοποιήσετε και να τις χαρακτηρίσετε αργότερα για να κάνετε ακριβή στατιστικά
    Στην περίπτωση των αρχείων Ofx: αν εντοπιστούν διπλότυπα θα πρέπει να επιλέξετε τη συμπεριφορά του προγράμματος
    Για τους άλλους τύπους αρχείων: θα πρέπει να προσέξετε τα διπλότυπα
statement-duplicate-question =
    Η συναλλαγή: { $date } { $label }: { $amount }
    φαίνεται ότι έχει ήδη ενταχθεί στο ιστορικό των συναλλαγών του τραπεζικού σας λογαριασμού.
    Θέλετε πραγματικά να προχωρήσετε στη συμφωνία;
statement-already-reconciled = Έχετε ήδη συμφωνήσει αυτήν τη συναλλαγή: είναι ήδη ενταγμένη στο ιστορικό των συναλλαγών του λογαριασμού σας
statement-integration-report =
    Τέλος της ένταξης.
    Αριθμός εγγραφών που εντάχθηκαν: { $added }
    Αριθμός εγγραφών που αγνοήθηκαν: { $ignored }
statement-integration-abandoned =
    Εγκατάλειψη της ένταξης!
    Αριθμός εγγραφών που εντάχθηκαν: { $added }
    Αριθμός εγγραφών που αγνοήθηκαν: { $ignored }
statement-yes = Ναι
statement-no = Όχι
statement-cancel = Ακύρωση
statement-file-info =
    Λογαριασμός του αρχείου: { $account }
    Περίοδος: από { $from } έως { $to }
    Υπόλοιπο που δηλώνει η τράπεζα: { $balance }
    { $count } κινήσεις, εκ των οποίων { $known } υπάρχουν ήδη στον λογαριασμό σας.
statement-group-identification = Ταυτοποίηση της κίνησης
statement-group-amount = Ποσό της κίνησης
statement-group-classification = Ταξινόμηση της κίνησης για υπολογισμό στατιστικών
statement-group-status = Κατάσταση της κίνησης
statement-field-date = Ημερομηνία
statement-field-label = Περιγραφή
statement-field-type = Τύπος κίνησης
statement-field-amount = Ποσό
statement-field-mode = Τρόπος κίνησης
statement-field-category = Κατηγορία
statement-field-assignment = Κατανομή
statement-field-payee = Αντισυμβαλλόμενος
statement-field-project = Έργο
statement-field-status = Κατάσταση
statement-field-clearing = Ημερομηνία συμφωνίας

# --- Το παράθυρο διαχωρισμού μιας κατάστασης CSV ---------------------------
# Ένα CSV δεν φέρει κανένα αξιόπιστο όνομα πεδίου: ρυθμίζει κανείς, δοκιμάζει,
# κοιτάζει, ξαναρχίζει. Η προεπισκόπηση δείχνει τα πάντα, ακαταλαβίστικα
# συμπεριλαμβανομένων — έτσι βλέπει κανείς ότι έκανε λάθος — αλλά μόνο οι
# έγκυρες γραμμές μεταφέρονται προς το παράθυρο ένταξης (κανόνας του Fabrice,
# 27/07/2026).

window-csv-statement-title = Εισαγωγή δεδομένων που προέρχονται από αρχείο csv
csv-preview-title = Προεπισκόπηση του αρχείου:
csv-settings-title = Παράμετροι διαχωρισμού του αρχείου για την άντληση των δεδομένων:
csv-extraction-title = Προβολή της άντλησης των δεδομένων σύμφωνα με τις παραμέτρους διαχωρισμού  ( ελέγξτε τη συνοχή των δεδομένων ):
csv-column-line = Αρ. γραμμής
csv-column-content = Περιεχόμενο
csv-header-lines = Αριθμός γραμμών κεφαλίδας του αρχείου προς παράβλεψη
csv-separator = Τα δεδομένα (στήλες) χωρίζονται με τον χαρακτήρα:
csv-date-at = Θέση πεδίου ημερομηνίας
csv-label-at = Θέση πεδίου περιγραφής
csv-debit-at = Θέση πεδίου ποσού χρέωσης
csv-credit-at = Θέση πεδίου ποσού πίστωσης
csv-test = Δοκιμή των παραμέτρων
csv-separator-semicolon = Ερωτηματικό   ;
csv-separator-comma = Κόμμα   ,
csv-separator-tab = Στηλοθέτης
csv-separator-pipe = Κάθετη γραμμή   |
csv-separator-space = Κενό
csv-help = Ρυθμίστε, δοκιμάστε, δείτε: μόνο οι γραμμές που φέρουν αναγνώσιμη ημερομηνία και ποσό θα εισαχθούν.
csv-none = Το αρχείο είναι κενό.
csv-not-tested = Κάντε κλικ στο «Δοκιμή των παραμέτρων» για να δείτε τι δίνει ο διαχωρισμός.
csv-extraction = { $count ->
    [0] Ο διαχωρισμός δεν παράγει καμία γραμμή: ελέγξτε τον αριθμό των γραμμών κεφαλίδας και τον διαχωριστικό χαρακτήρα.
   *[other] { $count } γραμμές διαχωρίστηκαν: { $valid } θα εισαχθούν, { $dropped } απορρίφθηκαν λόγω μη αναγνώσιμης ημερομηνίας ή ποσού.
}
csv-nothing-valid = Καμία γραμμή δεν φέρει ταυτόχρονα αναγνώσιμη ημερομηνία και ποσό: δεν υπάρχει τίποτα προς εισαγωγή. Ελέγξτε τον αριθμό των γραμμών κεφαλίδας, τον διαχωριστικό χαρακτήρα και τη θέση των πεδίων.
csv-title-validate = Μεταφορά των έγκυρων γραμμών προς την εισαγωγή

# --- F13 / F31 / F14 / F12 — Μπλοκ επιταγών και επιταγές (φάση 9) -------
# Μεταφορά των πέντε κωδίκων WinDev του και των επτά στιγμιοτύπων του, που
# δόθηκαν στις 28/07/2026. Οι ακριβείς φράσεις του όπου υπάρχει μία· οι δικές
# μου αλλού.
#
# Τρεις πιστότητες που έκρινε εκείνη την ημέρα και που ακούγονται μέσα στις
# λέξεις: η διπλή αναφορά δεν ανακοινώνεται (η `Existe_Reference` του δεν
# καλείται ποτέ), ο αριθμός των επιταγών δεν αντιπαραβάλλεται με τα όρια,
# και ο μετρητής κινήσεων μετρά τις θυγατρικές που οι λίστες απορρίπτουν.

window-chequebooks-title = Λίστα μπλοκ επιταγών
window-chequebook-title = Παράμετροι μπλοκ επιταγών
window-cheques-title = Σύνθεση του μπλοκ επιταγών: λίστα των επιταγών.
window-cheque-title = Καρτέλα επιταγών
window-cheque-operations-title = Λίστα των κινήσεων.

# Η λίστα των μπλοκ επιταγών (F13) — όλα τα μπλοκ, όλων των λογαριασμών μαζί:
# οι δύο στήλες λογαριασμού του δεν θα χρησίμευαν σε τίποτα σε έναν μόνο.
chequebooks-column-reference = ΠΕΡΙΓΡΑΦΗ
chequebooks-column-date = Ημερομηνία
chequebooks-column-account = Όνομα λογαριασμού
chequebooks-column-account-number = Αρ. λογαριασμού
chequebooks-column-comments = Σχόλια
chequebooks-none = Δεν έχει καταχωριστεί κανένα μπλοκ επιταγών.
chequebooks-nothing-to-show = Κανένα μπλοκ επιταγών δεν ανταποκρίνεται σε αυτήν την αναζήτηση.
chequebooks-title-composition = Προβολή της σύνθεσης του μπλοκ επιταγών
chequebooks-delete-question = Εντοπίστηκαν κινήσεις (τραπεζικές συναλλαγές) συνδεδεμένες με μπλοκ επιταγών. Επιβεβαιώνετε ότι θέλετε να διαγράψετε αυτό το μπλοκ επιταγών;
chequebooks-deleted = { $count ->
    [one] Ένα μπλοκ επιταγών διαγράφηκε.
   *[other] { $count } μπλοκ επιταγών διαγράφηκαν.
}
chequebooks-gone = Αυτό το μπλοκ επιταγών δεν υπάρχει πια.
chequebooks-created = Το μπλοκ επιταγών αποθηκεύτηκε, με όλες τις επιταγές του.
chequebooks-updated = Το μπλοκ επιταγών τροποποιήθηκε.
# Η σιωπή του `HAjoute` του: το παράθυρο δεν λέει ότι η αναφορά είναι ήδη
# πιασμένη. Λέει μόνο ότι τίποτα δεν αποθηκεύτηκε — αλλιώς θα πίστευε κανείς
# ότι το μπλοκ δημιουργήθηκε.
# Οι οκτώ προφυλάξεις του «Precauttion enregistrement cheque.txt» του, λέξη
# προς λέξη και με τη σειρά του. Οι επτά πρώτες είναι `Erreur()`, η όγδοη ένα
# `Info()` — και η σειρά αποφασίζει τι βλέπει κανείς όταν δύο πράγματα πάνε
# στραβά μαζί.
chequebook-refusal-duplicate = Υπάρχει ήδη αναφορά με το ίδιο όνομα
chequebook-refusal-reference-required = Η εισαγωγή αναφοράς είναι υποχρεωτική
chequebook-refusal-number-too-big = Οι αριθμοί της πρώτης ή/και της τελευταίας επιταγής είναι πολύ μεγάλοι (μέγιστη τιμή 999 999 999)
chequebook-refusal-date = Εισαγάγετε έγκυρη ημερομηνία παραλαβής
chequebook-refusal-numbers-required = Συμπληρώστε τους αριθμούς της πρώτης και της τελευταίας επιταγής
chequebook-refusal-order = Ο αριθμός της πρώτης επιταγής πρέπει να είναι μικρότερος από τον αριθμό της τελευταίας επιταγής
chequebook-refusal-account = Επιλέξτε υποχρεωτικά τον λογαριασμό που σχετίζεται με αυτό το μπλοκ επιταγών
chequebook-refusal-too-many = Μέγιστος αριθμός επιταγών για ένα μπλοκ: 1000, το όριο συμπληρώθηκε
# Η αίτηση επιβεβαίωσης του, που τίθεται μόνο κατά την προσθήκη: ανακεφαλαιώνει
# αυτό που πρόκειται να δημιουργηθεί και προειδοποιεί ότι τίποτα δεν θα είναι
# τροποποιήσιμο μετά.
chequebook-creation-question =
    Δημιουργία του μπλοκ επιταγών με τα ακόλουθα χαρακτηριστικά:
    - Αριθμός επιταγών προς δημιουργία:{ $count }
    - Επιταγές αριθμημένες από { $first } έως { $last }
    Προσοχή, αυτά τα δεδομένα δεν θα είναι τροποποιήσιμα μετά τη δημιουργία!

# Η καρτέλα μπλοκ επιταγών (F31). Τα πέντε πρώτα πεδία γκριζάρουν μόλις το
# μπλοκ υπάρξει: οι επιταγές του είναι ήδη εκεί.
chequebook-field-id = Αναγνωριστικό Μπλοκ Επιταγών
chequebook-field-reference = Αναφορά
chequebook-field-received = Κατασκευάστηκε ή παραλήφθηκε στις
chequebook-field-first = Αριθμός της πρώτης επιταγής
chequebook-field-last = Αριθμός της τελευταίας επιταγής
chequebook-field-quantity = Αριθμός επιταγών
chequebook-field-account = Σύνδεση με τον τραπεζικό λογαριασμό:
chequebook-field-comments = Σχόλια
chequebook-locked = Οι επιταγές αυτού του μπλοκ έχουν ήδη δημιουργηθεί: η αρίθμησή του δεν τροποποιείται πλέον.
# Η φράση του, λέξη προς λέξη (`Enreg_Lire`).
chequebook-account-missing = Ο τραπεζικός λογαριασμός με τον οποίο συνδέθηκε αυτό το μπλοκ επιταγών λείπει ή έχει διαγραφεί!

# Η σύνθεση του μπλοκ επιταγών (F14). Η κατάσταση αλλάζει μέσα στο κελί.
cheques-column-number = Αρ. επιταγής
cheques-column-date = Ημερομηνία
cheques-column-place = Τόπος
cheques-column-payee = Δικαιούχος
cheques-column-amount = Ποσό
cheques-column-status = Κατάσταση
cheques-column-comments = Σχόλια
cheques-column-operations = Αρ. συνδεδ. κινήσεων
cheques-none = Αυτό το μπλοκ επιταγών δεν περιέχει καμία επιταγή.
cheques-nothing-to-show = Καμία επιταγή δεν ανταποκρίνεται σε αυτήν την αναζήτηση.
cheques-help = Κάντε κλικ στο κελί Κατάσταση για να την αλλάξετε· ο μεγεθυντικός φακός δείχνει τις συνδεδεμένες κινήσεις, ο κρίκος συνδέει μία.
cheques-title-linked = Προβολή των κινήσεων που έχουν ήδη συνδεθεί με αυτήν την επιταγή
cheques-title-link = Σύνδεση κίνησης με αυτήν την επιταγή
cheques-status-changed = Η κατάσταση της επιταγής τροποποιήθηκε.

# Η καρτέλα επιταγής (F12).
cheque-field-id = Αναγνωριστικό Επιταγής
cheque-field-number = Αριθμός επιταγής
cheque-field-issued = Ημερομηνία Έκδοσης
cheque-field-place = Τόπος Έκδοσης
cheque-field-payee = Δικαιούχος
cheque-field-amount = Ποσό
cheque-field-comments = Σχόλια
cheque-field-status = Κατάσταση της επιταγής
cheque-gone = Αυτή η επιταγή δεν υπάρχει πια.
cheque-updated = Η επιταγή τροποποιήθηκε.

# Τα δύο πρόσωπα του παραθύρου σύνδεσης.
cheque-operations-linked-title = Λίστα των κινήσεων που έχουν ήδη συνδεθεί με αυτήν την επιταγή.
cheque-operations-choose-title = Επιλέξτε μια κίνηση για σύνδεση με την επιταγή
cheque-operations-column-account = Λογαριασμός
cheque-operations-column-label = Όνομα
cheque-operations-column-date = Ημερομηνία
cheque-operations-column-clearing = Ημ. συμφωνίας
cheque-operations-column-amount = Ποσό
cheque-operations-column-cheque = Συνδεδεμένη επιταγή
cheque-operations-none-linked = Καμία κίνηση δεν είναι συνδεδεμένη με αυτήν την επιταγή.
cheque-operations-none = Αυτός ο λογαριασμός δεν περιέχει καμία κίνηση.
cheque-operations-nothing-to-show = Καμία κίνηση δεν ανταποκρίνεται σε αυτήν την αναζήτηση.
cheque-operations-help = Οι κινήσεις με έντονα στοιχεία φέρουν ήδη επιταγή.
cheque-operations-linked-help = Ο κόκκινος σταυρός αποσυνδέει την επιταγή από την κίνηση: τίποτα δεν διαγράφεται.
cheque-operations-linked = Η κίνηση συνδέθηκε με την επιταγή.
cheque-operations-dissociated = Η επιταγή αποσυνδέθηκε από την κίνηση.
cheque-operations-menu-filter = Φίλτρο
cheque-title-associate = Σύνδεση αυτής της κίνησης με την επιταγή
cheque-title-dissociate = Αποσύνδεση της επιταγής από αυτήν την κίνηση

# Η ταινία «Επιταγή σε σχέση με την κίνηση» της καρτέλας κίνησης, και οι δύο
# χρόνοι του ψαρέματος της επιταγής — το μπλοκ, μετά η επιταγή.
chequebooks-select-question = Επιλέξτε το μπλοκ επιταγών
cheques-select-question = Επιλέξτε την επιταγή προς σύνδεση με την κίνηση
operation-check-save-first = Αποθηκεύστε πρώτα την κίνηση: μια επιταγή συνδέεται με κίνηση που υπάρχει.
operation-check-none = Αυτή η κίνηση δεν φέρει καμία επιταγή.

# --- F36 / F37 — Τα πρότυπα κίνησης (φάση 10) ---------------------------
# Ένα πρότυπο είναι μια έτοιμη καταχώριση: το εφαρμόζει κανείς για να μην
# ξαναπληκτρολογεί, και **αντικαθιστά** ό,τι υπάρχει στην καρτέλα. Τίποτα δεν
# φεύγει στον δίσκο όσο η καρτέλα κίνησης δεν έχει επιβεβαιωθεί (κανόνας του
# Fabrice, 29/07/2026).

window-operation-templates-title = Λίστα προτύπων κινήσεων
window-operation-template-title = Καρτέλα Προτύπου Κίνησης

operation-templates-none = Δεν έχει καταχωριστεί κανένα πρότυπο κίνησης.
operation-templates-nothing-to-show = Κανένα πρότυπο δεν ανταποκρίνεται σε αυτήν την αναζήτηση.
operation-templates-select-question = Επιλέξτε το πρότυπο προς εφαρμογή
operation-templates-delete-question = Επιβεβαιώνετε τη διαγραφή των επιλεγμένων προτύπων;
operation-templates-deleted = { $count ->
    [one] Ένα πρότυπο διαγράφηκε.
   *[other] { $count } πρότυπα διαγράφηκαν.
}
operation-template-gone = Αυτό το πρότυπο δεν υπάρχει πια.
operation-template-fresh = Νέο πρότυπο.
operation-template-created = Το πρότυπο αποθηκεύτηκε.
operation-template-updated = Το πρότυπο τροποποιήθηκε.
operation-template-label-required = Η εισαγωγή ονόματος είναι υποχρεωτική
operation-template-duplicate = Υπάρχει ήδη πρότυπο με το ίδιο όνομα

# Η καρτέλα F36, ενότητα προς ενότητα — οι ακριβείς τίτλοι του.
operation-template-field-id = ID Προτύπου Κίνησης
operation-template-group-name = Προεπιλεγμένο όνομα της μελλοντικής κίνησης μετά την εφαρμογή του προτύπου
operation-template-field-label = Όνομα
operation-template-group-amount = Προεπιλεγμένο ποσό της κίνησης, προκαθορισμένο σε αυτό το πρότυπο
operation-template-field-direction = Τύπος Κίνησης
operation-template-field-amount = Ποσό
operation-template-group-status = Προεπιλεγμένη κατάσταση της κίνησης σε αυτό το πρότυπο
operation-template-field-status = Κατάσταση Κίνησης
operation-template-group-classification = Πληροφορίες του προτύπου για την ταξινόμηση και τον υπολογισμό των στατιστικών
operation-template-field-category = Κατηγορία
operation-template-field-assignment = Κατανομή
operation-template-field-mode = Τρόπος
operation-template-field-payee = Αντισυμβαλλόμενος
operation-template-field-project = Έργο

# Το κουμπί «Πρότυπο» της καρτέλας κίνησης: ένα εικονίδιο, δύο ενέργειες.
operation-template-question = Τι θέλετε να κάνετε με τα πρότυπα κίνησης;
operation-template-apply = Εφαρμογή προτύπου
operation-template-save-as = Αποθήκευση ως πρότυπο
operation-template-applied = Το πρότυπο εφαρμόστηκε. Επιβεβαιώστε την καρτέλα για να το αποθηκεύσετε.
operation-template-saved-as = Η κίνηση αποθηκεύτηκε ως πρότυπο.
operation-template-needs-label = Δώστε ένα όνομα στην κίνηση πριν την κάνετε πρότυπο.

# --- F26 / F27 — Ο προϋπολογισμός (φάση 11) -----------------------------
# Δύο πόρτες, δύο ερωτήσεις: καταχωρίζει κανείς τον προϋπολογισμό του, ή
# ελέγχει αν τηρήθηκε. Ο άξονας είναι το κονδύλι προϋπολογισμού, η μονάδα
# είναι το έτος, και η σύμβαση προσήμου είναι εκείνη των κινήσεων — μια
# δαπάνη γράφεται αρνητική.

window-budget-entry-title = Καταχώριση Προϋπολογισμού: έξοδα(-) και έσοδα(+) προβλεπόμενα για ένα έτος
window-budget-control-title = Έλεγχος του προϋπολογισμού

budget-column-line = Κονδύλι προϋπολογισμού
budget-none = Δεν έχει καταχωριστεί κανένα κονδύλι προϋπολογισμού: ο προϋπολογισμός καταχωρίζεται ανά κονδύλι.
budget-planned = Προβλεπόμενο
budget-actual = Πραγματοποιηθέν
budget-sum = Άθροισμα
budget-cumulative = Σωρευτικό
budget-total = Σύνολο
# Η υπενθύμιση της σύμβασης προσήμου, με κόκκινα κάτω από τον πίνακα
# καταχώρισης. Η φράση του, λέξη προς λέξη και με τα κενά (στιγμιότυπο
# «POINT 004 saisie budget.png»): είναι με κόκκινα κάτω από τον πίνακα, και ο
# τίτλος του παραθύρου την ξαναλέει συνοπτικά. Κανείς δεν θα μάντευε τη
# σύμβαση χωρίς αυτήν.
budget-sign-warning = Καταχωρίστε υποχρεωτικά τα έξοδα  με αρνητικό πρόσημο και τα προβλεπόμενα έσοδα με θετικά ποσά
budget-entry-help = Πληκτρολογήστε τα ποσά στα κελιά και έπειτα αποθηκεύστε.
budget-saved = Ο προϋπολογισμός αποθηκεύτηκε.
budget-nothing-changed = Καμία τροποποίηση προς αποθήκευση.
budget-discard-question = Να εγκαταλειφθούν οι τροποποιήσεις του προϋπολογισμού;

# Το μενού Εμφάνιση του ελέγχου: οι δύο τρόποι να διαβαστεί η ίδια απόκλιση.
budget-menu-display = Εμφάνιση
budget-display-money = Τιμές
budget-display-percent = Ποσοστά
budget-control-help = Πράσινο: τουλάχιστον τόσο καλά όσο προβλεπόταν. Κόκκινο: χειρότερα.

# --- F09 — Μεταφορά ποσού μεταξύ δύο λογαριασμών (φάση 12) ---------------
# Μια μεταφορά δεν είναι μία κίνηση, είναι δύο: μια χρέωση στον λογαριασμό
# προέλευσης, μια πίστωση στον λογαριασμό προορισμού. Ξεκινούν μαζί ή καθόλου.

window-transfer-title = Μεταφορά ποσού μεταξύ δύο λογαριασμών

transfer-group-source = Χρέωση του ποσού σε αυτόν τον λογαριασμό προέλευσης
transfer-group-target = Πίστωση του ποσού σε αυτόν τον λογαριασμό προορισμού
transfer-group-description = Περιγραφή της κίνησης
transfer-group-nomenclature = Πληροφορίες Βασικών Δεδομένων
transfer-group-amount = Ύψος του ποσού προς μεταφορά
transfer-field-source = Λογαριασμός προέλευσης
transfer-field-target = Λογαριασμός προορισμού
transfer-field-label = Περιγραφή
transfer-field-reference = Αναφορά πληρωμής
transfer-field-date = Ημερομηνία
transfer-field-status = Κατάσταση Κίνησης
transfer-field-clearing = Ημερομηνία συμφωνίας
transfer-field-category = Κατηγορία
transfer-field-mode = Τρόπος πληρωμής
transfer-field-assignment = Κατανομή
transfer-field-payee = Αντισυμβαλλόμενοι / έμποροι
transfer-field-project = Έργο
transfer-field-amount = Ποσό

# Το μοναδικό κουμπί των πλαισίων που ανακοινώνουν αντί να ρωτούν.
ui-ok = OK
transfer-help = Επιλέξτε τους δύο λογαριασμούς: τα υπόλοιπά τους εμφανίζονται εδώ.
transfer-title-validate = Εκτέλεση της μεταφοράς
# Τα τρία υπόλοιπα του επιλεγμένου λογαριασμού, για να ξέρετε τι συνεπάγεται η μεταφορά.
transfer-balances = { $account } — Στην τράπεζα: { $bank } · Πραγματικό: { $real } · Τελικό: { $final }
# Το πλαίσιο που συνοψίζει αυτό που μόλις γράφτηκε.
transfer-done = Η μεταφορά εκτελέστηκε. { $amount } από τον λογαριασμό { $source } προς τον λογαριασμό { $target }, στις { $date }.

transfer-refusal-accounts-required = Επιλέξτε τον λογαριασμό προέλευσης και τον λογαριασμό προορισμού
transfer-refusal-same-account = Ο λογαριασμός προέλευσης και ο λογαριασμός προορισμού δεν μπορούν να είναι ο ίδιος: μια μεταφορά πηγαίνει από έναν λογαριασμό προς έναν άλλον
transfer-refusal-account-gone = Ένας από τους δύο λογαριασμούς δεν υπάρχει πλέον
transfer-refusal-label-required = Η περιγραφή είναι υποχρεωτική
transfer-refusal-date-required = Η ημερομηνία είναι υποχρεωτική
transfer-refusal-amount = Το ποσό προς μεταφορά πρέπει να είναι αυστηρά θετικό

# ---------------------------------------------------------------------------
# Φάση 13 — η εισαγωγή ενός φύλλου Excel (F34, F35, αντιστοίχιση).
# ---------------------------------------------------------------------------

window-excel-import-title = Εισαγωγή φύλλου excel [ Βήμα 1/3 ]: ορισμός της ζώνης λήψης
window-excel-fields-title = Εισαγωγή φύλλου excel [ Βήμα 2/3 ]: αντιστοίχιση των πεδίων
window-excel-association-title = Εισαγωγή φύλλου excel: αντιστοίχιση των δεδομένων

# Η ερώτηση που τίθεται κατά το άνοιγμα. Ένα αρχείο Excel φτιάχνεται στο χέρι:
# περιέχει ό,τι περιέχει, και ένα μέρος από τις ασυναρτησίες που κουβαλά
# είναι μη ανιχνεύσιμο. Προτείνουμε λοιπόν το δίχτυ πριν από το άλμα.
excel-backup-question = Ένα φύλλο Excel φτιάχνεται στο χέρι: μπορεί να περιέχει ημερομηνίες σωστές μεν αλλά εσφαλμένες, ποσά με τη σωστή μορφή και το λάθος πρόσημο — και αυτό, κανένας έλεγχος δεν μπορεί να το δει. Η εισαγωγή θα γράψει αυτές τις γραμμές στον λογαριασμό σας. Θέλετε να δημιουργήσετε αντίγραφο ασφαλείας των δεδομένων σας πριν ξεκινήσετε;
excel-backup-later = Το αντίγραφο ασφαλείας δεν είναι ακόμη συνδεδεμένο σε αυτήν την έκδοση του Radinus 2. Στο μεταξύ, κλείστε το Radinus και αντιγράψτε μόνοι σας το αρχείο της βάσης δεδομένων σας: θα μπορείτε τότε να κάνετε την εισαγωγή χωρίς κανέναν κίνδυνο.

excel-group-file = 1 - Υπόδειξη του αρχείου Excel προς εισαγωγή
excel-pick = Υπόδειξη του αρχείου Excel
excel-sheet = Φύλλο του βιβλίου εργασίας:
excel-group-header = 2 - Ορισμός: Συντεταγμένες κελιών για τη γραμμή κεφαλίδας του πίνακα όπου είναι γραμμένα τα ονόματα των στηλών.
excel-header-row = Αριθμός 1ης γραμμής όπου βρίσκονται τα ονόματα των στηλών
excel-first-column = Στήλη αρχής κεφαλίδας ( η πιο αριστερή στήλη ):
excel-column-count = Αριθμός στηλών του πίνακα
excel-group-rows = 3 - Ορισμός: Αριθμοί γραμμών αρχής και τέλους της λίστας που περιέχει τα δεδομένα του πίνακα ( κάτω από την κεφαλίδα και χωρίς να τη συμπεριλαμβάνει )
excel-first-data-row = Πρώτη γραμμή που περιέχει δεδομένα
excel-last-data-row = Τελευταία γραμμή που περιέχει δεδομένα:
excel-group-shape = 4 - Ορισμός: Πώς το αρχείο σας γράφει τα ποσά
excel-shape-single = Μία μόνο στήλη ποσών, με πρόσημο ( τα έξοδα αρνητικά )
excel-shape-debit-credit = Δύο ξεχωριστές στήλες: μια στήλη Χρέωση και μια στήλη Πίστωση
excel-shape-note = Στη λειτουργία με δύο στήλες, το πρόσημο που είναι γραμμένο στη στήλη Χρέωση δεν λαμβάνεται υπόψη: μια χρέωση βγάζει πάντα χρήματα, είτε σημειώνεται «-50» είτε «50».
excel-group-test = 5 - Δοκιμαστική απόδοση: Δείτε τη λήψη που έγινε σύμφωνα με τις ρυθμίσεις σας
excel-test = Δοκιμάστε τις παραμέτρους που ορίσατε στα βήματα 2, 3 και 4.
excel-test-note = Υπόδειξη: Τα ονόματα των κεφαλίδων και το περιεχόμενο του παρακάτω πίνακα πρέπει να αντιστοιχούν σε εκείνα του πίνακα Excel σας. Η ζώνη λήψης δεν πρέπει να ξεπερνά τα όρια του πίνακα.

excel-help = Κατεβείτε τις πέντε ομάδες με τη σειρά, μετά δοκιμάστε: θα μπορέσετε να περάσετε στο βήμα 2 μόνο αφού δείτε τι πιάνει η ζώνη.
excel-no-file = Υποδείξτε πρώτα το αρχείο Excel προς εισαγωγή.
excel-not-tested = Οι ρυθμίσεις άλλαξαν: ξανατρέξτε τη δοκιμαστική απόδοση πριν επιβεβαιώσετε.
excel-tested = Ζώνη που ελήφθη: { $rows } γραμμές, { $columns } στήλες. Ελέγξτε ότι ο παρακάτω πίνακας μοιάζει με το φύλλο σας.
excel-empty-capture = Η ζώνη που δηλώσατε δεν πιάνει καμία γραμμή: ελέγξτε τους αριθμούς γραμμής και στήλης.
excel-title-next = Μετάβαση στο επόμενο βήμα
excel-into-account = Εισαγωγή στον λογαριασμό { $account }.

excel-tab-links = Συνδέσεις πεδίων
excel-tab-settings = Παράμετροι εισαγωγής
excel-column-excel = Κεφαλίδα_Excel
excel-column-radinus = Πεδίο_Radinus
excel-links-help = Απέναντι από κάθε στήλη του φύλλου σας, δηλώστε ποιο πεδίο του Radinus τροφοδοτεί. Οι στήλες που μένουν στο [IGNORE] δεν εισάγονται.
excel-group-category = Κατηγορίες χωρίς αντιστοιχίες
excel-group-payment-mode = Τρόπος πληρωμής χωρίς αντιστοιχίες
excel-group-assignment = Κατανομή χωρίς αντιστοιχίες
excel-policy-create = { $kind ->
    [payment-mode] Αυτόματη δημιουργία των ανύπαρκτων τρόπων πληρωμής
    [assignment] Αυτόματη δημιουργία των ανύπαρκτων κατανομών
   *[category] Αυτόματη δημιουργία των ανύπαρκτων κατηγοριών
}
excel-policy-ask = { $kind ->
    [payment-mode] Ερώτηση για κάθε ανύπαρκτο τρόπο πληρωμής, πού να μεταφερθούν τα δεδομένα
    [assignment] Ερώτηση για κάθε ανύπαρκτη κατανομή, πού να μεταφερθούν τα δεδομένα
   *[category] Ερώτηση για κάθε ανύπαρκτη κατηγορία, πού να μεταφερθούν τα δεδομένα
}
excel-policy-blank = { $kind ->
    [payment-mode] Να μείνει ο τρόπος πληρωμής κενός
    [assignment] Να μείνει η κατανομή κενή
   *[category] Να μείνει η κατηγορία κενή
}
excel-policy-default = { $kind ->
    [payment-mode] Μεταφορά των ανύπαρκτων τρόπων πληρωμής σε έναν προεπιλεγμένο τρόπο πληρωμής
    [assignment] Μεταφορά των ανύπαρκτων κατανομών σε μια προεπιλεγμένη κατανομή
   *[category] Μεταφορά των ανύπαρκτων κατηγοριών σε μια προεπιλεγμένη κατηγορία
}
excel-define-destination = Ορισμός προορισμού
excel-not-linked = { $kind ->
    [payment-mode] Καμία στήλη δεν τροφοδοτεί τον τρόπο πληρωμής: αυτή η ρύθμιση δεν εφαρμόζεται.
    [assignment] Καμία στήλη δεν τροφοδοτεί την κατανομή: αυτή η ρύθμιση δεν εφαρμόζεται.
   *[category] Καμία στήλη δεν τροφοδοτεί την κατηγορία: αυτή η ρύθμιση δεν εφαρμόζεται.
}
excel-fields-help = Ρυθμίστε τις αντιστοιχίες, μετά τις τρεις πολιτικές, πριν ξεκινήσετε την εισαγωγή.
excel-title-import = Έναρξη της εισαγωγής

excel-refusal-required = Τα πεδία Ημερομηνία, Περιγραφή και Ποσό πρέπει υποχρεωτικά να δείχνουν σε στήλες excel
excel-refusal-column-twice = Διαφορετικά πεδία Radinus δείχνουν στην ίδια στήλη excel: μια στήλη μπορεί να τροφοδοτήσει μόνο ένα πεδίο
excel-refusal-field-twice = Το ίδιο πεδίο Radinus έχει αντιστοιχιστεί σε δύο στήλες excel: δεν μπορεί να έχει παρά μία
excel-refusal-ask-unset = { $kind ->
    [payment-mode] Επιλέξατε να ερωτάστε πού να μεταφέρονται οι άγνωστοι τρόποι πληρωμής: πατήστε «Ορισμός προορισμού» πριν ξεκινήσετε την εισαγωγή.
    [assignment] Επιλέξατε να ερωτάστε πού να μεταφέρονται οι άγνωστες κατανομές: πατήστε «Ορισμός προορισμού» πριν ξεκινήσετε την εισαγωγή.
   *[category] Επιλέξατε να ερωτάστε πού να μεταφέρονται οι άγνωστες κατηγορίες: πατήστε «Ορισμός προορισμού» πριν ξεκινήσετε την εισαγωγή.
}

excel-column-data = Δεδομένα_Excel
excel-column-destination = { $kind ->
    [payment-mode] ΤρόποςΠληρωμής_Radinus
    [assignment] Κατανομή_Radinus
   *[category] Κατηγορία_Radinus
}
excel-association-help = Απέναντι από κάθε τιμή που προέρχεται από το φύλλο σας, επιλέξτε εκείνη του Radinus στην οποία πρέπει να ταξινομηθεί. Μια γραμμή που μένει κενή θα παραμείνει χωρίς ταξινόμηση.
excel-association-none = Καμία άγνωστη τιμή: όλα όσα περιέχει το φύλλο σας υπάρχουν ήδη στο Radinus.

excel-imported = Η εισαγωγή ολοκληρώθηκε: { $count } κινήσεις γράφτηκαν, { $refused } γραμμές απορρίφθηκαν, { $created } τιμές βασικών δεδομένων δημιουργήθηκαν.
excel-report-title = Αναφορά της εισαγωγής
excel-column-row = Γραμμή Excel
excel-column-content = Περιεχόμενο
excel-column-reason = Αιτία απόρριψης
excel-nothing-refused = Όλες οι γραμμές του φύλλου σας εισήχθησαν: καμία απόρριψη.

excel-refused-date = Ημερομηνία απούσα ή δυσανάγνωστη
excel-refused-amount = Ποσό απόν ή δυσανάγνωστο
excel-refused-amount-both = Ένα ποσό στη στήλη Χρέωση και ένα άλλο στη στήλη Πίστωση: αδύνατη η επιλογή
excel-refused-amount-missing = Ούτε χρέωση ούτε πίστωση σε αυτήν τη γραμμή

# ---------------------------------------------------------------------------
# Φάση 16 — οι επαναλαμβανόμενες κινήσεις (F15, F38, F16).
# ---------------------------------------------------------------------------

window-recurring-list-title = Λίστα των επαναλαμβανόμενων κινήσεων
window-recurring-form-title = Καρτέλα ορισμού του κανόνα δημιουργίας επαναλαμβανόμενης κίνησης
window-recurring-calendar-title = Πρόταση ημερολογίου των κινήσεων προς εισαγωγή στους τραπεζικούς σας λογαριασμούς

recurring-column-label = ΠΕΡΙΓΡΑΦΗ
recurring-none = Κανένας επαναλαμβανόμενος κανόνας δεν έχει αποθηκευτεί.
recurring-help = Επιλέξτε έναν κανόνα, μετά το ημερολόγιο για να δείτε τις ημερομηνίες λήξης που προτείνει.
recurring-title-calendar = Πρόταση του ημερολογίου των ημερομηνιών λήξης
recurring-deleted = { $count ->
    [0] Κανένας κανόνας δεν διαγράφηκε.
    [one] Ένας κανόνας διαγράφηκε. Οι κινήσεις του παραμένουν στον λογαριασμό.
   *[other] { $count } κανόνες διαγράφηκαν. Οι κινήσεις τους παραμένουν στους λογαριασμούς.
}
recurring-gone = Αυτός ο κανόνας δεν υπάρχει πλέον.
recurring-delete-question = Να διαγραφούν οι επιλεγμένοι κανόνες; Οι κινήσεις που έχουν ήδη εισαγάγει θα παραμείνουν στους λογαριασμούς σας.

recurring-group-identity = Ταυτοποίηση και σχετικός τραπεζικός λογαριασμός
recurring-group-nomenclature = Βασικά δεδομένα
recurring-group-amount = Ορισμός του ποσού της κίνησης
recurring-group-period = Ορισμός της περιόδου
recurring-group-ending = Συνθήκες λήξης της περιόδου
recurring-group-produced = Πληροφορίες για τις ήδη εισαγμένες κινήσεις ( μόνο για ενημέρωση )

recurring-field-id = Αναγνωριστικό Κίνησης
recurring-field-account = Λογαριασμός προορισμού
recurring-field-label = Περιγραφή
recurring-field-category = Κατηγορία
recurring-field-mode = Τρόπος πληρωμής
recurring-field-assignment = Κατανομή
recurring-field-payee = Αντισυμβαλλόμενος / έμποροι
recurring-field-project = Έργο
recurring-field-direction = Τύπος Κίνησης
recurring-field-amount = Ποσό
recurring-field-next = Ημερομηνία επόμενης κίνησης
recurring-field-every = Έπειτα κάθε
recurring-field-end-date = Ημερομηνία λήξης
recurring-field-repeat = Αριθμός επαναλήψεων
recurring-field-guid = GUID Κίνησης
recurring-field-produced-count = Αριθμός εισαγμένων κινήσεων
recurring-field-produced-last = Ημερομηνία τελευταίας εισαγμένης κίνησης
recurring-field-produced-total = Σύνολο παραγόμενων ποσών

recurring-unit-day = Ημέρα
recurring-unit-week = Εβδομάδα
recurring-unit-month = Μήνας
recurring-unit-quarter = Τρίμηνο
recurring-unit-year = Έτος
recurring-ending-no-limit = Χωρίς όριο
recurring-ending-until-date = Με ημερομηνία λήξης
recurring-ending-repeat-count = Αριθμός επαναλήψεων

recurring-title-erase = Διαγραφή των κινήσεων που έχει ήδη εισαγάγει αυτός ο κανόνας
recurring-erase-question = { $count ->
    [one] Αυτός ο κανόνας έχει εισαγάγει μία κίνηση στους λογαριασμούς σας. Θέλετε να τη διαγράψετε; Τα υπόλοιπα θα υπολογιστούν ξανά, και ο κανόνας δεν θα γυρίσει πίσω.
   *[other] Αυτός ο κανόνας έχει εισαγάγει { $count } κινήσεις στους λογαριασμούς σας. Θέλετε να τις διαγράψετε όλες; Τα υπόλοιπα θα υπολογιστούν ξανά, και ο κανόνας δεν θα γυρίσει πίσω.
}
recurring-erase-none = Αυτός ο κανόνας δεν έχει εισαγάγει ακόμη καμία κίνηση.
recurring-erased = { $count ->
    [0] Καμία κίνηση δεν διαγράφηκε.
    [one] Μία κίνηση διαγράφηκε, τα υπόλοιπα υπολογίστηκαν ξανά.
   *[other] { $count } κινήσεις διαγράφηκαν, τα υπόλοιπα υπολογίστηκαν ξανά.
}

recurring-calendar-help = Αφαιρέστε με τον κάδο ανακύκλωσης τις ημερομηνίες λήξης που δεν θέλετε, μετά επιβεβαιώστε για να τις εισαγάγετε.
recurring-calendar-none = Καμία ημερομηνία λήξης προς πρόταση: ελέγξτε την ημερομηνία επόμενης κίνησης και τον λογαριασμό των κανόνων σας.
recurring-calendar-column-account = Λογαριασμός
recurring-calendar-column-date = Ημερομηνία
recurring-calendar-column-label = Περιγραφή
recurring-calendar-column-amount = Ποσό
recurring-calendar-column-category = Κατηγορία
recurring-calendar-column-assignment = Κατανομή
recurring-calendar-column-mode = Τρόπος πληρωμής
recurring-calendar-column-payee = Αντισυμβαλλόμενος
recurring-calendar-column-project = Έργα
recurring-calendar-removed = { $count ->
    [one] Μία ημερομηνία λήξης αφαιρέθηκε από την πρόταση.
   *[other] { $count } ημερομηνίες λήξης αφαιρέθηκαν από την πρόταση.
}
recurring-title-insert = Εισαγωγή των επιλεγμένων ημερομηνιών λήξης στους λογαριασμούς
recurring-nothing = Δεν απομένει καμία ημερομηνία λήξης προς εισαγωγή.
# Η ερώτηση που τίθεται πριν από την εγγραφή: η εισαγωγή ενός ημερολογίου δημιουργεί
# πραγματικές κινήσεις σε πραγματικούς λογαριασμούς, και αυτό δεν γίνεται με ένα αφηρημένο κλικ.
recurring-insert-question = { $count ->
    [one] Να εισαχθεί αυτή η ημερομηνία λήξης στον λογαριασμό σας; Μία κίνηση θα δημιουργηθεί και τα υπόλοιπα θα υπολογιστούν ξανά.
   *[other] Να εισαχθούν αυτές οι { $count } ημερομηνίες λήξης στους λογαριασμούς σας; Θα δημιουργηθούν ισάριθμες κινήσεις και τα υπόλοιπα θα υπολογιστούν ξανά.
}
recurring-inserted = { $count ->
    [one] Μία κίνηση εισήχθη. Ο κανόνας ξεκινά ξανά μετά την τελευταία εισαγμένη ημερομηνία λήξης.
   *[other] { $count } κινήσεις εισήχθησαν. Οι κανόνες ξεκινούν ξανά μετά την τελευταία τους εισαγμένη ημερομηνία λήξης.
}

recurring-refusal-label-required = Η καταχώριση περιγραφής είναι υποχρεωτική
recurring-refusal-date-required = Η καταχώριση της ημερομηνίας επόμενης κίνησης είναι υποχρεωτική
recurring-refusal-date-too-old = Η ημερομηνία επόμενης κίνησης πρέπει να είναι μεγαλύτερη ή ίση του έτους 2000
recurring-refusal-account-gone = Ο καθορισμένος τραπεζικός λογαριασμός δεν βρέθηκε, παρακαλούμε επιλέξτε έναν νέο ώστε ο κανόνας να καταστεί εφαρμόσιμος
recurring-refusal-end-required = Σε περίπτωση ημερομηνίας λήξης, η ημερομηνία πρέπει να καταχωριστεί
recurring-refusal-end-before-start = Η ημερομηνία λήξης δεν μπορεί να είναι μικρότερη από την ημερομηνία της επόμενης κίνησης
recurring-refusal-end-too-far = Η διαφορά μεταξύ της ημερομηνίας επόμενης κίνησης και της ημερομηνίας λήξης δεν μπορεί να υπερβαίνει τις 10 000 ημέρες

# --- Φάση 15 — οι εκτυπώσεις και οι καταστάσεις ------------------------
# Ο μεγάλος τίτλος της κεφαλίδας, παρμένος λέξη προς λέξη από την αρχική κατάσταση WinDev.
print-operations-title = Κατάλογος τραπεζικών συναλλαγών και υποκινήσεων
print-menu-operations-pdf = Εκτύπωση σε αρχείο PDF
print-recap-title = Ανακεφαλαίωση ανά κατηγορία
print-recap-count = Γραμμές
print-row-count = Αριθμός γραμμών:
print-total-debit = Σύνολο χρεώσεων:
print-total-credit = Σύνολο πιστώσεων:
print-final-balance = Τελικό υπόλοιπο:
print-licence = Το Radinus είναι ελεύθερο λογισμικό υπό την άδεια GNU GPL v3 ή νεότερη
print-nothing = Δεν υπάρχει τίποτα προς εκτύπωση.
print-done = Η κατάσταση εκτυπώθηκε και άνοιξε: «{ $file }».
print-failed = Αδύνατη η εκτύπωση: { $reason }
# Το PDF γράφτηκε κανονικά, αλλά το σύστημα δεν μπόρεσε να το ανοίξει: το λέμε χωρίς
# να αφήνουμε να εννοηθεί αποτυχία, αφού το αρχείο βρίσκεται εκεί.
print-not-opened = Η κατάσταση εκτυπώθηκε στο «{ $file }», αλλά το σύστημά σας δεν μπόρεσε να το ανοίξει μόνο του.

# --- Η κατάσταση RIB (F32) ---------------------------------------------
# Οι τίτλοι της βεβαίωσης τραπεζικών στοιχείων, παρμένοι από το αρχικό έγγραφο.
rib-title = ΒΕΒΑΙΩΣΗ ΤΡΑΠΕΖΙΚΩΝ ΣΤΟΙΧΕΙΩΝ
rib-bank = Τράπεζα:
rib-national = RIB - Εθνικό αναγνωριστικό λογαριασμού
rib-establishment = ΙΔΡΥΜΑ
rib-branch = ΚΑΤΑΣΤΗΜΑ
rib-number = ΑΡΙΘΜΟΣ ΛΟΓΑΡΙΑΣΜΟΥ
rib-key = ΚΛΕΙΔΙ RIB
rib-domiciliation = ΔΙΕΥΘΥΝΣΗ ΚΑΤΑΣΤΗΜΑΤΟΣ
rib-iban = IBAN - Διεθνές αναγνωριστικό λογαριασμού
rib-bic = BIC - Διεθνές αναγνωριστικό του ιδρύματος
rib-holder = Δικαιούχος του λογαριασμού

# --- Το παράθυρο F32 ---------------------------------------------------
window-rib-title = Εκτύπωση RIB ( Βεβαίωση Τραπεζικών Στοιχείων )
rib-group-bank = Τράπεζα
rib-group-holder = Δικαιούχος του λογαριασμού
rib-group-details = Τραπεζικά στοιχεία
rib-field-bank = Όνομα τράπεζας
rib-field-domiciliation = Διεύθυνση καταστήματος
rib-field-holder = Όνομα δικαιούχου
rib-field-address = Διεύθυνση
rib-field-establishment = Ίδρυμα
rib-field-branch = Κατάστημα
rib-field-number = Αριθμός λογαριασμού
rib-field-key = Κλειδί RIB
rib-field-bic = BIC (Bank Identifer Code)
rib-field-iban = IBAN (International Bank Account Number )
rib-conditions = Σημαντικοί όροι χρήσης που πρέπει υποχρεωτικά να τηρούνται σε περίπτωση εκτύπωσης
rib-declaration = Ο υπογεγραμμένος χρήστης του λογισμικού δηλώνω υπεύθυνα:
rib-declaration-first = - Βεβαιώνω ότι επαλήθευσα στην τράπεζά μου ότι τα τραπεζικά στοιχεία που περιέχονται σε αυτό το παράθυρο είναι σωστά και σύμφωνα με τη βούλησή μου . Βεβαιώνω με τον ίδιο τρόπο ότι δεσμεύομαι να ελέγξω ότι τα στοιχεία που περιέχονται στην εκτύπωση του RIB είναι σωστά και σύμφωνα με τη βούλησή μου. Αυτή η εκτύπωση και η χρήση του RIB θα γίνουν με δική μου αποκλειστική ευθύνη
rib-declaration-second = - Ότι είμαι ο δικαιούχος του λογαριασμού του οποίου θα εκτυπωθεί το RIB, και ότι δεν θα χρησιμοποιήσω τις λειτουργίες αυτού του λογισμικού για σκοπό αντίθετο προς τον νόμο.
rib-title-print = Εκτύπωση σε εκτυπωτή
rib-title-pdf = Εκτύπωση σε αρχείο PDF
# Το πλαίσιο δεν είναι διακοσμητική προειδοποίηση: όσο δεν είναι
# επιλεγμένο, τα δύο κουμπιά μένουν ανενεργά (απόφαση του Fabrice, 01/08/2026).
rib-declaration-required = Επιλέξτε την υπεύθυνη δήλωση για να μπορέσετε να εκτυπώσετε.
rib-help = Ελέγξτε τα στοιχεία σας, επιλέξτε τη δήλωση και έπειτα εκτυπώστε.
rib-account-gone = Αυτός ο τραπεζικός λογαριασμός δεν βρέθηκε.
rib-fields-read-only = Αυτά τα στοιχεία προέρχονται από την καρτέλα του λογαριασμού: διορθώστε τα στην καρτέλα για να αλλάξουν εδώ.
rib-printed = Το RIB στάλθηκε στον προεπιλεγμένο εκτυπωτή σας.
rib-print-failed = Αδύνατη η εκτύπωση: { $reason }
rib-pdf-done = Το RIB εκτυπώθηκε και άνοιξε: «{ $file }».
rib-pdf-not-opened = Το RIB εκτυπώθηκε στο «{ $file }», αλλά το σύστημά σας δεν μπόρεσε να το ανοίξει μόνο του.
menu-accounts-bank-details = Έκδοση βεβαίωσης τραπεζικών στοιχείων

# Η επιλογή του εκτυπωτή. Το Radinus θέτει το ερώτημα το ίδιο: κανένα από τα
# τρία webviews δεν ανοίγει το παράθυρο εκτύπωσης του συστήματος.
print-choose-printer = Σε ποιον εκτυπωτή θέλετε να εκτυπώσετε;
print-do-print = Εκτύπωση
rib-printed-on = Το RIB στάλθηκε στον εκτυπωτή «{ $printer }».
ui-cancel = Ακύρωση

# Το σύστημα δεν μπόρεσε να ονομάσει κανέναν εκτυπωτή: εκτυπώνουμε ούτως ή άλλως
# στον προεπιλεγμένο αντί να μπλοκάρουμε τον χρήστη.
print-printers-unknown = Το σύστημά σας δεν μπόρεσε να ονομάσει κανέναν εκτυπωτή: το έγγραφο στάλθηκε στον προεπιλεγμένο εκτυπωτή.

print-menu-operations-printer = Εκτύπωση σε εκτυπωτή
print-sent-on = Η κατάσταση στάλθηκε στον εκτυπωτή «{ $printer }».
print-sent-default = Η κατάσταση στάλθηκε στον προεπιλεγμένο εκτυπωτή σας.

# --- Φάση 17 — οι λειτουργίες στη βάση δεδομένων -----------------------
backup-archive = Αρχειοθήκη Radinus
backup-no-database = Καμία βάση δεδομένων δεν είναι ανοιχτή.
backup-done = Το αντίγραφο ασφαλείας γράφτηκε στο «{ $file }».
backup-failed = Αδύνατο το αντίγραφο ασφαλείας: { $reason }
restore-unreadable = Αυτό το αρχείο δεν είναι αναγνώσιμη αρχειοθήκη Radinus: { $reason }
# Η ερώτηση λέει τι θα χαθεί προτού χαθεί. Η αρχειοθήκη έχει ήδη διαβαστεί
# σε αυτό το σημείο: ό,τι ανακοινώνει είναι βέβαιο.
restore-question = Να γίνει επαναφορά του «{ $file }»; Όλο το τρέχον περιεχόμενο της βάσης σας θα διαγραφεί και θα αντικατασταθεί, και ό,τι βρίσκεται εκεί θα χαθεί.
restore-done = Η επαναφορά ολοκληρώθηκε: { $accounts } λογαριασμοί και { $operations } κινήσεις.
restore-failed = Αδύνατη η επαναφορά: { $reason }
restore-empty-fields = Κενά πεδία που διαβάστηκαν ως μηδενική τιμή: { $count }.


# --- Το ημερολόγιο των τεχνικών λειτουργιών (φάση 17) ------------------
# Οι τρεις καταστάσεις του Ajoute_Log του, σε κεφαλαία όπως στο δικό του.
journal-status-success = ΕΠΙΤΥΧΙΑ
journal-status-failure = ΑΠΟΤΥΧΙΑ
journal-status-repaired = ΕΠΙΔΙΟΡΘΩΘΗΚΕ
journal-step-reindex = Επιδιόρθωση πίνακα βάσης δεδομένων
journal-step-refill = Κενά βασικά δεδομένα συστήματος: επαναφορά των προεπιλεγμένων τιμών
journal-step-table-created = Ο πίνακας λείπει από τη βάση: δημιουργήθηκε ξανά κενός
journal-step-column-added = Η στήλη λείπει από τον πίνακα: προστέθηκε με την προεπιλεγμένη τιμή της

# --- Protection par mot de passe (05/08/2026) ---
password-protect = Προστασία με κωδικό
window-password-form-title = Προστασία με κωδικό
password-ask = Αυτή η βάση είναι προστατευμένη. Εισαγάγετε τον κωδικό της.
password-group-database = Σχετική βάση
password-group-password = Κωδικός
password-group-warning = Πριν επιβεβαιώσετε
password-field-old = Παλιός κωδικός
password-field-new = Νέος κωδικός
password-field-repeat = Επαναλάβετε τον νέο κωδικό
password-hint = Αφήστε τον παλιό κενό αν η βάση δεν είναι ακόμη προστατευμένη. Αφήστε και τους δύο νέους κενούς για να αφαιρέσετε την προστασία.
password-lost-warning = Ένας χαμένος κωδικός είναι μια χαμένη βάση: τίποτα δεν την ανακτά. Τα αντίγραφα ασφαλείας, αντίθετα, μένουν χωρίς κρυπτογράφηση.
password-show = Εμφάνιση του κωδικού
password-remove-question = Να αφαιρεθεί η προστασία αυτής της βάσης;
password-mismatch = Οι δύο καταχωρίσεις του νέου κωδικού διαφέρουν
password-wrong = Ο κωδικός δεν ταιριάζει
password-close-first = Κλείστε αυτή τη βάση πριν αλλάξετε τον κωδικό της
password-now-protected = Η βάση προστατεύεται με κωδικό
password-now-clear = Η βάση δεν προστατεύεται πλέον
journal-step-date-fixed = Διόρθωση μιας κίνησης χωρίς ημερομηνία
journal-step-circular = Διαγραφή μιας ασυνεπούς κίνησης: κυκλική αναφορά
journal-step-flag-parent-true = Λανθασμένη σημαία EstParent=Faux σε κύρια κίνηση
journal-step-flag-parent-false = Λανθασμένη σημαία EstParent=Vrai σε κύρια κίνηση
journal-step-flag-child = Λανθασμένη σημαία EstParent=Vrai σε υποκίνηση
journal-step-orphan = Διαγραφή μιας ορφανής υποκίνησης
journal-step-third-level = Διαγραφή μιας υποκίνησης συνδεδεμένης με άλλη υποκίνηση
journal-step-coherence = Γενικός επανυπολογισμός της συνοχής μεταξύ υποκινήσεων και κύριων κινήσεων
journal-step-balances = Επανυπολογισμός όλων των υπολοίπων όλων των λογαριασμών
journal-step-vacuum = Βελτιστοποίηση του αρχείου της βάσης δεδομένων
journal-step-analyze = Ενημέρωση των στατιστικών αναζήτησης
journal-step-backup-begin = Έναρξη του αντιγράφου ασφαλείας της βάσης
journal-step-backup-end = Τέλος του αντιγράφου ασφαλείας της βάσης
journal-step-restore-begin = Έναρξη της επαναφοράς της βάσης από την αρχειοθήκη
journal-step-restore-end = Τέλος της επαναφοράς της βάσης από την αρχειοθήκη
journal-step-restore-read = Ανάγνωση της αρχειοθήκης

# --- Το παράθυρο του ημερολογίου (⌘H) ----------------------------------
window-journal-title = Ημερολόγιο της τελευταίας τεχνικής λειτουργίας
journal-column-step = Βήμα
journal-column-file = Αρχείο
journal-column-table = Πίνακας
journal-column-status = Κατάσταση
journal-column-error = Σφάλμα
journal-column-comments = Σχόλια
journal-empty = Καμία τεχνική λειτουργία δεν έχει εκτελεστεί ακόμη από το άνοιγμα του λογισμικού.
journal-help = Το ημερολόγιο κρατά μόνο την τελευταία τεχνική λειτουργία: αντίγραφο ασφαλείας, επαναφορά, επιδιόρθωση, διαγραφή ή άνοιγμα βάσης.

# --- Η επιδιόρθωση -----------------------------------------------------
menu-file-repair-running = Επιδιόρθωση και βελτιστοποίηση σε εξέλιξη…
repair-done = { $anomalies ->
    [0] Η επιδιόρθωση ολοκληρώθηκε: δεν βρέθηκε καμία ανωμαλία. { $lines } βήματα καταγράφηκαν.
    [one] Η επιδιόρθωση ολοκληρώθηκε: μία ανωμαλία επιδιορθώθηκε. { $lines } βήματα καταγράφηκαν.
   *[other] Η επιδιόρθωση ολοκληρώθηκε: { $anomalies } ανωμαλίες επιδιορθώθηκαν. { $lines } βήματα καταγράφηκαν.
}
repair-failed = Αδύνατη η επιδιόρθωση: { $reason }

journal-status-started = ΣΕ ΕΞΕΛΙΞΗ
journal-status-finished = ΟΛΟΚΛΗΡΩΘΗΚΕ
journal-step-backup-table = Εγγραφή του πίνακα στην αρχειοθήκη
journal-step-backup-write = Εγγραφή της αρχειοθήκης
journal-step-backup-verified = Επαλήθευση της αρχειοθήκης που γράφτηκε: αρχεία που ξαναδιαβάστηκαν / αναμενόμενα, εγγραφές που ξαναδιαβάστηκαν / γράφτηκαν
journal-step-backup-total = Σύνολο που αποθηκεύτηκε: εγγραφές, δεδομένα, μέγεθος του αρχείου
journal-step-restore-table = Ανάγνωση του πίνακα στην αρχειοθήκη
journal-step-restore-missing = Αρχείο απόν από την αρχειοθήκη: αυτός ο πίνακας δεν θα επαναφερθεί
journal-step-restore-wipe = Ολική διαγραφή του περιεχομένου της βάσης πριν από την επαναφορά
journal-step-restore-write = Εγγραφή στη βάση
journal-step-restore-total = Σύνολο που επαναφέρθηκε: λογαριασμοί, κινήσεις
journal-step-restore-empty-fields = Κενά πεδία που συμπληρώθηκαν κατά την ανάγνωση
backup-verify-mismatch = Η αρχειοθήκη που γράφτηκε δεν ξαναδιαβάζεται όπως γράφτηκε: μην τη θεωρείτε αξιόπιστη, ξανακάντε το αντίγραφο ασφαλείας.

# --- Τα συνημμένα μιας κίνησης (F28, φάση 17) --------------------------
window-attachments-title = Συνημμένα της κίνησης
attachment-filter = Αποδεκτά έγγραφα
attachment-none = Αυτή η κίνηση δεν φέρει κανένα συνημμένο.
attachment-title-add = Επισύναψη εγγράφου σε αυτήν την κίνηση
attachment-title-open = Άνοιγμα του συνημμένου
attachment-title-remove = Αφαίρεση του συνημμένου και αποστολή του αρχείου του στον κάδο ανακύκλωσης
# Η κατάσταση του αρχείου στον δίσκο. Το «Μη επαληθεύσιμο» δεν είναι δωρεάν
# ομολογία άγνοιας: τα αποτυπώματα που προέρχονται από το Radinus 1.9.3 είναι
# ακρωτηριασμένα από τη μορφή αποθήκευσης, και το να κρίνει κανείς ένα αρχείο βάσει αυτών θα ισοδυναμούσε με τυχαία κατηγορία.
attachment-state-ok = Άθικτο
attachment-state-changed = Τροποποιημένο
attachment-state-missing = Αρχείο απόν
attachment-state-unknown = Μη επαληθεύσιμο
attachment-added = Το «{ $name }» επισυνάφθηκε στην κίνηση.
attachment-removed = Το συνημμένο αφαιρέθηκε, το αρχείο του βρίσκεται στον κάδο ανακύκλωσης.
attachment-removed-kept = Το συνημμένο αφαιρέθηκε, αλλά το αρχείο του δεν μπόρεσε να μπει στον κάδο ανακύκλωσης.
attachment-remove-question = Να αφαιρεθεί το «{ $name }» από αυτήν την κίνηση; Το αρχείο του θα σταλεί στον κάδο ανακύκλωσης.
attachment-opened = Το «{ $name }» άνοιξε.
attachment-opened-changed = Το «{ $name }» άνοιξε, αλλά το περιεχόμενό του άλλαξε από τότε που επισυνάφθηκε.
attachment-gone = Αυτό το συνημμένο δεν υπάρχει πλέον.
attachment-file-missing = Το αρχείο του «{ $name }» δεν βρέθηκε στον δίσκο.
attachment-failed = Αδύνατη η λειτουργία: { $reason }
attachment-save-first = Αποθηκεύστε πρώτα την κίνηση: ένα συνημμένο συνδέεται με μια κίνηση που υπάρχει.
attachment-refusal-missing = Αυτό το αρχείο δεν υπάρχει.
attachment-refusal-extension = Αυτός ο τύπος αρχείου δεν γίνεται δεκτός. Γίνονται δεκτά: pdf, jpeg, jpg, png, bmp, tiff, gif, webp, xls, xlsx, doc, docx, odt, rtf, txt, json, xml.
attachment-refusal-operation = Η κίνηση στην οποία θα επισυναπτόταν αυτό το έγγραφο δεν υπάρχει.
journal-step-backup-attachments = Συνημμένα που προστέθηκαν στην αρχειοθήκη
journal-step-backup-attachment-missing = Συνημμένο που δεν βρέθηκε στον δίσκο: θα λείπει από την αρχειοθήκη
journal-step-restore-attachments = Συνημμένα που εξήχθησαν από την αρχειοθήκη
attachment-title-replace = Αντικατάσταση του εγγράφου αυτού του συνημμένου
attachment-replaced = Το έγγραφο αντικαταστάθηκε από το «{ $name }».

# ---------------------------------------------------------------------
# F08 — το μενού «Εργαλεία» της καρτέλας λογαριασμού.
#
# Οι τρεις καταχωρίσεις του είναι μεταφορές από το WLangage του Fabrice (φάκελος
# «Information import export base piece jointe»): ο υπολογισμός του αρχικού
# συμφωνημένου υπολοίπου, τα στατιστικά του λογαριασμού και η διαγραφή όλων
# των συναλλαγών του. Το μενού ενεργεί μόνο σε επεξεργασία (απόφαση της
# 02/08/2026): στη δημιουργία δεν υπάρχει τίποτα να μετρηθεί, σε προβολή η
# καρτέλα απλώς δείχνει.
# ---------------------------------------------------------------------

account-tools = Εργαλεία
account-tools-initial-balance = Ορισμός του αρχικού συμφωνημένου υπολοίπου
account-tools-statistics = Στατιστικά τραπεζικού λογαριασμού
account-tools-delete-operations = Διαγραφή όλων των συναλλαγών του λογαριασμού

# Η ερώτηση του υπολογισμού, λέξη προς λέξη αυτή του πρωτοτύπου. Το { $total } είναι
# το σύνολο των συμφωνημένων κινήσεων, ήδη γραμμένο σε νομισματική μορφή.
account-initial-balance-question =
    Για να υπολογιστεί το αρχικό συμφωνημένο υπόλοιπο σε σχέση με τις κινήσεις που υπάρχουν σε αυτόν τον λογαριασμό, παρακαλείστε να δηλώσετε το τρέχον υπόλοιπο της τράπεζάς σας
    Το αρχικό συμφωνημένο υπόλοιπο θα υπολογιστεί ως ίσο με:
    { "[" }Τρέχον τραπεζικό υπόλοιπο] - [Σύνολο συμφωνημένων κινήσεων ({ $total }) ].
    { "" }
    Για να μην χρειαστεί να ξαναπληκτρολογήσετε αυτήν την τιμή πρέπει να είστε πλήρως ενήμεροι ως προς τη λίστα των τραπεζικών κινήσεων αυτού του λογαριασμού.

account-statistics-none = Καμία συναλλαγή

# Οι δεκατέσσερις γραμμές του Info() του. Το τυπογραφικό λάθος «pengagés» του
# πρωτοτύπου διορθώνεται, με απόφαση του Fabrice της 02/08/2026 — όπως και το
# «Bank Identifer Code» στην ίδια αυτή καρτέλα.
account-statistics =
    Συνολικός αριθμός συναλλαγών σε αυτόν τον λογαριασμό: { $count }
    { "" }
    Αριθμός συμφωνημένων συναλλαγών σε αυτόν τον λογαριασμό: { $pointed }
    Ποσό των συμφωνημένων χρεώσεων: { $pointedDebits }
    Ποσό των συμφωνημένων πιστώσεων: { $pointedCredits }
    Διαφορά μεταξύ συμφωνημένων πιστώσεων και χρεώσεων: { $pointedDifference }
    { "" }
    Αριθμός δεσμευμένων συναλλαγών σε αυτόν τον λογαριασμό: { $committed }
    Ποσό των δεσμευμένων χρεώσεων: { $committedDebits }
    Ποσό των δεσμευμένων πιστώσεων: { $committedCredits }
    Διαφορά μεταξύ δεσμευμένων πιστώσεων και χρεώσεων: { $committedDifference }
    { "" }
    Αριθμός προγραμματισμένων συναλλαγών σε αυτόν τον λογαριασμό: { $planned }
    Ποσό των προγραμματισμένων χρεώσεων: { $plannedDebits }
    Ποσό των προγραμματισμένων πιστώσεων: { $plannedCredits }
    Διαφορά μεταξύ προγραμματισμένων πιστώσεων και χρεώσεων: { $plannedDifference }
    { "" }
    Παλαιότερη συναλλαγή: { $first }
    Νεότερη συναλλαγή: { $last }

# Το διπλό φράγμα της διαγραφής. Το { $word } είναι το «ναι» της καθημερινής
# γλώσσας — ένας ισπανόφωνος στον οποίο θα ζητούσαμε να γράψει OUI δεν θα
# καταλάβαινε (απόφαση του Fabrice, 02/08/2026).
account-delete-operations-question =
    Είστε βέβαιοι ότι θέλετε να διαγράψετε όλες τις κινήσεις που περιέχονται στον τραπεζικό λογαριασμό;
    Για να το επιβεβαιώσετε γράψτε { $word } στο παρακάτω πεδίο και επιβεβαιώστε

account-delete-operations-done =
    { $count ->
        [0] Καμία συναλλαγή δεν διαγράφηκε.
        [one] 1 συναλλαγή διαγράφηκε.
       *[other] { $count } συναλλαγές διαγράφηκαν.
    }

# ---------------------------------------------------------------------
# Ο επιλογέας βάσης και η επιλογή της γλώσσας (02/08/2026)
#
# Αποφάσεις που ελήφθησαν σε συζήτηση με τον Fabrice: το Radinus δεν
# δημιουργεί πλέον βάση χωρίς άδεια· χωρίς γλώσσα στη διαμόρφωση ζητά τη
# γλώσσα πριν από όλα τα υπόλοιπα· είναι βάση κάθε φάκελος του databases/
# που περιέχει ένα radinus.sqlite, όποιο κι αν είναι το όνομά του.
#
# Το παράθυρο επιλογής της γλώσσας δεν έχει κανένα κλειδί εδώ: δεν
# χρησιμοποιεί καμία φράση, και αυτό είναι που του επιτρέπει να γίνεται
# κατανοητό πριν μάθουμε ποια γλώσσα μιλά ο χρήστης.
# ---------------------------------------------------------------------

window-database-selector-title = Βάσεις δεδομένων
window-database-form-title = Νέα βάση δεδομένων
database-group-identity = Στοιχεία της βάσης δεδομένων
database-group-restore = Αρχικοποίηση της βάσης με τα δεδομένα ενός αντιγράφου ασφαλείας
database-choose-backup = Επιλογή αρχείου αντιγράφου ασφαλείας
database-no-backup = Δεν επιλέχθηκε αντίγραφο: η βάση θα δημιουργηθεί κενή.

databases-column-label = Βάση
databases-column-comment = Σχόλιο
databases-column-folder = Φάκελος
databases-column-created = Δημιουργήθηκε στις

databases-none = Καμία βάση προς το παρόν: δημιουργήστε μία.
databases-help = Επιλέξτε τη βάση που θα ανοίξετε ή δημιουργήστε μια νέα.
databases-select = Επιλέξτε πρώτα μια βάση από τη λίστα.
databases-tools = Εργαλεία
databases-title-open = Άνοιγμα αυτής της βάσης

database-created = Η βάση «{ $label }» δημιουργήθηκε.
database-field-label = Όνομα της βάσης
database-field-comment = Σχόλιο
database-label-required = Δώστε ένα όνομα σε αυτή τη βάση: αυτό θα την ξεχωρίζει από τις άλλες.
database-gone = Αυτή η βάση δεν υπάρχει πια: μετακινήθηκε ή διαγράφηκε από τότε που άνοιξε αυτό το παράθυρο.

# Η διαγραφή μιας βάσης (02/08/2026). Ο φάκελος πηγαίνει στον κάδο
# ανακύκλωσης του συστήματος, όπως τα συνημμένα: μια βάση που διαγράφηκε κατά
# λάθος επανέρχεται με ένα δεξί κλικ. Η ανοιχτή βάση απορρίπτεται — το Radinus
# κρατά το αρχείο της.
databases-title-delete = Διαγραφή αυτής της βάσης
database-delete-question =
    Είστε βέβαιοι ότι θέλετε να διαγράψετε τη βάση «{ $label }»;
    { "" }
    Όλος ο φάκελός της πηγαίνει στον κάδο ανακύκλωσης: οι κινήσεις, οι λογαριασμοί και τα συνημμένα.
    Για να το επιβεβαιώσετε, γράψτε { $word } στο παρακάτω πεδίο και επιβεβαιώστε.
database-in-use = Αυτή η βάση είναι ανοιχτή: το Radinus δεν μπορεί να τη διαγράψει. Ανοίξτε πρώτα μια άλλη.
database-deleted = Η βάση «{ $label }» βρίσκεται στον κάδο ανακύκλωσης.

# Ο επιλογέας έχει δύο λειτουργίες (Fabrice, 02/08/2026). Όταν ανοίγει κατά τη
# διάρκεια της χρήσης, δεν ξέρει πια να ανοίγει: ένα παράθυρο του Radinus
# χτίζεται μία φορά και δεν καταστρέφεται ποτέ, και τίποτα δεν θα μπορούσε να
# το κάνει να ξεχάσει τη βάση που δείχνει. Συμβουλευόμαστε, δημιουργούμε,
# διαγράφουμε — και για να αλλάξουμε βάση, βγαίνουμε.
database-quit-first = Για να ανοίξετε αυτή τη βάση, κλείστε το Radinus και ξεκινήστε το ξανά: ο επιλογέας θα σας την προτείνει κατά την εκκίνηση.


# --- F01 — το παράθυρο υποδοχής (φάση 17 bis, 03/08/2026) ----------------
#
# Πρώτη προσθήκη της 2.0.0 πάνω στην 1.9.3: το παράθυρο υποδοχής δεν φέρει
# πλέον μόνο το πανό. Ο κανόνας που το διέπει είναι γραμμένος στο έγγραφο
# 04 F01: είναι η όψη ΧΩΡΙΣ ΕΝΑ ΚΛΙΚ, και τίποτα από όσα απαιτούν ρύθμιση δεν
# μπαίνει εκεί.
#
# Οι δύο τίτλοι των δακτυλιοειδών διαγραμμάτων φέρουν ολόκληρο τον μήνα αντί
# να κολλιούνται άκρη με άκρη από το παράθυρο: το «Δαπάνες ... — Αύγουστος
# 2026» δεν έχει την ίδια σειρά λέξεων στις τρεις γλώσσες, και μόνο το Fluent
# ξέρει πού είναι το κενό.

window-main-title = Radinus
welcome-month = { $month } { $year }
welcome-accounts-count = { $count ->
    [0] Κανένας ανοιχτός λογαριασμός
    [one] 1 ανοιχτός λογαριασμός
   *[other] { $count } ανοιχτοί λογαριασμοί
}
welcome-total-bank = Τραπεζικό υπόλοιπο
welcome-total-real = Πραγματικό υπόλοιπο
welcome-total-final = Τελικό υπόλοιπο
welcome-total-real-detail = συμφωνημένες + δεσμευμένες
welcome-total-final-detail = συμφωνημένες + δεσμευμένες + προγραμματισμένες
welcome-accounts = Οι λογαριασμοί σας
welcome-tile-bank = Στην τράπεζα
welcome-tile-real = Πραγματικό
welcome-tile-final = Τελικό
welcome-spending = Δαπάνες — { $month }
welcome-earning = Έσοδα — { $month }
ui-legend-budget-lines = Κονδύλια προϋπολογισμού
ui-legend-categories = Κατηγορίες
welcome-nothing = Καμία κίνηση αυτόν τον μήνα.
welcome-open-account = Πληροφορία: κάντε κλικ σε έναν λογαριασμό για να ανοίξετε τις κινήσεις του.
welcome-no-account = Δεν υπάρχει ακόμη κανένας τραπεζικός λογαριασμός.
welcome-no-account-create = Δημιουργήστε έναν τραπεζικό λογαριασμό κάνοντας κλικ εδώ
welcome-previous-month = Προηγούμενος μήνας
welcome-next-month = Επόμενος μήνας
welcome-refresh = Επαναφόρτωση όλων


# --- F39 — οι προτιμήσεις (φάση 17 ter, 03/08/2026) ---------------------
#
# Η θέση του νομισματικού συμβόλου ζει εδώ, δίπλα στους δύο διαχωριστές:
# ακολουθεί τη γλώσσα και όχι το νόμισμα. Το «before» βάζει το σύμβολο μπροστά
# από τον αριθμό, κάθε άλλη τιμή το βάζει πίσω. ΚΑΝΕΝΑ νομισματικό σύμβολο δεν
# είναι γραμμένο σε αυτό το αρχείο: «γαλλικά» δεν σημαίνει «ευρώ».

ui-money-sign-position = after
window-preferences-title = Προτιμήσεις
menu-settings-preferences = Προτιμήσεις…
menu-settings-show-main = Εμφάνιση του κύριου παραθύρου
menu-settings-folders = Φάκελοι του Radinus
preferences-branch-display = Εμφάνιση
preferences-leaf-language = Γλώσσα
preferences-leaf-currency = Νόμισμα
preferences-field-language = Γλώσσα του λογισμικού:
preferences-field-currency = Εμφανιζόμενο νόμισμα:
preferences-field-custom = Σύμβολο του νομίσματος:
preferences-currency-system = Νόμισμα συστήματος
preferences-currency-euro = Ευρώ
preferences-currency-dollar = Δολάρια
preferences-currency-canadian = Καναδικά δολάρια
preferences-currency-cfa = Φράγκα CFA
preferences-currency-cfp = Φράγκα Ειρηνικού
preferences-currency-swiss = Ελβετικά φράγκα
preferences-currency-none = Κανένα
preferences-currency-custom = Προσαρμοσμένο
preferences-currency-system-is = Το σύστημά σας ανακοινώνει:
preferences-currency-system-silent = Το σύστημά σας δεν ανακοινώνει κανένα νόμισμα: τα ποσά θα εμφανίζονται σε ευρώ.
preferences-custom-required = Πληκτρολογήστε το σύμβολο του νομίσματός σας πριν από την αποθήκευση.
preferences-saved = Οι προτιμήσεις αποθηκεύτηκαν.
preferences-help = Επιλέξτε μια επιλογή από το δέντρο και έπειτα αποθηκεύστε.
preferences-sign-too-long = Το σύμβολο ενός νομίσματος χωρά σε 8 χαρακτήρες το πολύ.
preferences-sign-not-a-number = Το σύμβολο ενός νομίσματος δεν μπορεί να περιέχει ούτε ψηφίο, ούτε σύμβολο πράξης, ούτε υποδιαστολή: το Radinus τα αφαιρεί όταν διαβάζει ένα ποσό, και το «120» θα γινόταν «12».
preferences-leaf-zoom = Μέγεθος της εμφάνισης
preferences-field-zoom = Μεγέθυνση:
preferences-zoom-reset = Προεπιλεγμένη τιμή
preferences-zoom-hint = Όλα μεγαλώνουν μαζί: το κείμενο, τα εικονίδια, οι στήλες. Κάτω από 100 %, χωρούν περισσότερα στην οθόνη. Η γραμμή μενού του συστήματος και τα παράθυρα διαλόγου του, όμως, ακολουθούν τις ρυθμίσεις του υπολογιστή σας και όχι αυτές εδώ.

# --- Το πανό της υποδοχής ------------------------------------------------
#
# Αυτές οι φράσεις ήταν γραμμένες σταθερά μέσα στο `index.html` από τη φάση 0
# και δεν μεταφράζονταν λοιπόν (επισημάνθηκε από τον Fabrice στις 03/08/2026).
# Το σύνθημα είναι η φωνή του: η αγγλική και η ισπανική εκδοχή είναι
# προτάσεις, προς διόρθωση από τον ίδιο — ένα σύνθημα δεν μεταφράζεται λέξη
# προς λέξη.
ui-language-tag = el
welcome-banner-title = Radinus
welcome-mascot-alt = Radinus — ο σκίουρος μασκότ, με κοστούμι, περιτριγυρισμένος από ένα ευρώ, μια αριθμομηχανή και γραφήματα
welcome-slogan-one = Ένα λογισμικό διαχείρισης προσωπικών οικονομικών που σας βοηθά να ξοδεύετε λιγότερα για να κερδίζετε περισσότερα
welcome-slogan-two = Με το Radinus θα καταλάβετε γιατί τα μικρά ρυάκια κάνουν τα μεγάλα ποτάμια.

# --- «Σχετικά με τον συγγραφέα» ------------------------------------------
#
# Το όνομα και η διεύθυνση είναι γραμμένα πανομοιότυπα στα τρία αρχεία: δεν
# μεταφράζονται. Βρίσκονται εδώ παρ' όλα αυτά, και όχι μέσα στη σελίδα, ώστε η
# όψη να μη φέρει καμία φράση — και ώστε να διορθώνονται σε ένα μόνο σημείο
# την ημέρα που ο συγγραφέας θα μετακομίσει.
about-author-name = Auteur : Fabrice Garcia
about-author-place = 20290 Borgo, Corsica, France
window-about-author-title = Σχετικά με τον συγγραφέα
about-author-flag-alt = Σημαία της Κορσικής — η κεφαλή του Μαύρου

# --- «Σχετικά με το Radinus» ---------------------------------------------
#
# Το `about-radinus-version` φέρει ένα κενό: ο αριθμός προέρχεται από το
# εκτελέσιμο που τρέχει, ποτέ από μια αντιγραμμένη συμβολοσειρά. Δεν βρίσκεται
# λοιπόν στο λεξικό των παραθύρων — η εντολή `app_version` είναι που το
# συμπληρώνει.
window-about-radinus-title = Σχετικά με το Radinus
about-radinus-name = Radinus
about-radinus-version = Έκδοση { $version }
about-radinus-rust-alt = Το λογότυπο της γλώσσας Rust
about-radinus-tauri-alt = Το λογότυπο του Tauri
about-radinus-built = Το Radinus είναι γραμμένο σε Rust και χτισμένο με Tauri. Το πρώτο υπολογίζει τους λογαριασμούς σας, το δεύτερο το κάνει εφαρμογή γραφείου.
about-radinus-licence = Ελεύθερο λογισμικό, με άδεια GNU GPL v3.

# --- « Licence d'utilisation » (08/08/2026) -------------------------------
#
# The window names the licence and says, in four lines, what it gives the
# person using Radinus. The legal text itself is not translated here: the
# button opens the official page, published and maintained by the Free
# Software Foundation, which knows its own wording better than we do.
window-licence-title = Άδεια χρήσης
licence-heading = ΑΔΕΙΑ ΧΡΗΣΗΣ ΤΟΥ ΛΟΓΙΣΜΙΚΟΥ RADINUS
licence-logo-alt = Το λογότυπο της GNU General Public License έκδοση 3
licence-name = GNU GPL v3 ή νεότερη
licence-intro = Το Radinus είναι ελεύθερο λογισμικό.
licence-freedoms-title = Η άδειά του σας δίνει τέσσερις ελευθερίες:
licence-freedom-use = Να το χρησιμοποιείτε όπως θέλετε, για ό,τι θέλετε.
licence-freedom-study = Να μελετάτε τον πηγαίο κώδικά του, ανοιχτό σε όλους.
licence-freedom-share = Να το αντιγράφετε και να το δίνετε σε άλλους.
licence-freedom-improve = Να το τροποποιείτε και να μοιράζεστε τις αλλαγές σας.
licence-read = Διαβάστε το πλήρες κείμενο της άδειας

# The two notices the GPL asks an interactive interface to display, next
# to the right to redistribute and the way to read the licence, which the
# window already carried (LICENSE, definition of « Appropriate Legal
# Notices »). The copyright is a name and a year: identical everywhere,
# here all the same so that the view holds no sentence of its own.
licence-copyright = Copyright © 2026 Fabrice Garcia
licence-no-warranty = Αυτό το πρόγραμμα παρέχεται χωρίς καμία εγγύηση, στο μέτρο που επιτρέπει ο νόμος.
licence-info = Το επίσημο κείμενο ανοίγει στο πρόγραμμα περιήγησής σας, στο gnu.org.

