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
menu-statistics-balance-analysis = Ανάλυση Εξέλιξη του υπολοίπου
menu-statistics-by-category = Στατ. ανά κατηγορία
menu-statistics-by-assignment = Στατ. ανά κατανομή
menu-statistics-by-budget-line = Στατ. ανά κονδύλι προϋπολογισμού
menu-statistics-by-payment-mode = Στατ. ανά τρόπο πληρωμής
menu-statistics-by-payee = Στατ. ανά αντισυμβαλλόμενο και έμπορο
menu-statistics-by-project = Στατ. ανά έργο
menu-statistics-by-verification = Στατ. ανά έλεγχο
menu-statistics-dashboard = Πίνακας ελέγχου των κινήσεων
menu-statistics-crossed-balance = Διασταυρωμένος απολογισμός

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

# Le menu Outils (Fabrice, 09/10/2026), entre Nomenclatures et Paramètres.
menu-tools = Εργαλεία
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
operations-column-status = Κατάσταση κίνησης
operation-status-pointed = Συμφωνημένη
operation-status-committed = Δεσμευμένη
operation-status-planned = Προγραμματισμένη
operations-column-verification = Έλεγχος
operation-verification-to-verify = Προς έλεγχο
operation-verification-verified = Ελεγμένη
operation-verification-doubtful = Αμφίβολη
operation-verification-disputed = Αμφισβητούμενη
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
filter-by-status = Φίλτρο κατάστασης
filter-by-verification = Φίλτρο ελέγχου
filter-show-all = Εμφάνιση όλων

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
operation-field-verification = Έλεγχος
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
operation-clearing-date-required = Μια σημειωμένη κίνηση πρέπει υποχρεωτικά να φέρει ημερομηνία σημείωσης.
operation-clearing-date-question =
    Μια σημειωμένη κίνηση πρέπει υποχρεωτικά να φέρει ημερομηνία σημείωσης.
    Θέλετε να αποθηκεύσετε με την ημερομηνία της κίνησης, { $date };
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
    [0] Καμία κίνηση προς συμφωνία: η επιλογή είναι ήδη συμφωνημένη.
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
operations-recurring-from = Δημιουργία περιοδικής κίνησης από αυτή την κίνηση

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
    [verification] Στατιστικά ανά έλεγχο
   *[category] Στατιστικά ανά κατηγορία
}

statistics-axis-column = { $kind ->
    [assignment] Κατανομή
    [budget-line] ΚονδύλιΠροϋπ
    [payment-mode] ΤρόποςΚίνησης
    [payee] Αντισυμβαλλόμενος
    [project] Έργα
    [verification] Έλεγχος
   *[category] ΌνομαΚατηγορίας
}

statistics-unclassified = { $kind ->
    [assignment] Χωρίς κατανομή
    [budget-line] Χωρίς κονδύλι προϋπολογισμού
    [payment-mode] Χωρίς τρόπο πληρωμής
    [payee] Χωρίς αντισυμβαλλόμενο
    [project] Χωρίς έργο
    [verification] Προς έλεγχο
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

# --- F27, le bilan croisé (Fabrice, 25/08/2026) ---------------------
# Les catégories en lignes, les affectations en colonnes, sur un mois.
# Tout le reste de son vocabulaire est celui des statistiques : Total,
# Somme, les interrupteurs, « Sans … », les colonnes du détail.
window-crossed-balance-title = Διασταυρωμένος απολογισμός
crossed-balance-window-name = Διασταυρωμένος απολογισμός
crossed-balance-column = Κατηγορία
crossed-balance-no-data = Καμία κίνηση αυτόν τον μήνα για τους επιλεγμένους λογαριασμούς.
crossed-balance-month-question = Σε ποιον μήνα θέλετε να εργαστείτε; Αριθμός από { $first } έως { $last }.
crossed-balance-month-choose = Επιλογή μήνα
crossed-balance-next = Επόμενος μήνας
crossed-balance-previous = Προηγούμενος μήνας

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
export-to = Εξαγωγή σε
# Copying from a table (Fabrice, 07/10/2026): the two entries at the head of
# the right-click menu, and what is said when the clipboard refuses.
copy-cell = Αντιγραφή κελιού
copy-rows = Αντιγραφή επιλεγμένων γραμμών
copy-failed = Η αντιγραφή στο πρόχειρο απέτυχε.
export-all-years-excel = Εξαγωγή όλων των ετών σε Excel
export-all-years-ods = Εξαγωγή όλων των ετών σε LibreOffice Calc
export-all-months-excel = Εξαγωγή όλων των μηνών του εμφανιζόμενου έτους σε Excel
export-all-months-ods = Εξαγωγή όλων των μηνών του εμφανιζόμενου έτους σε LibreOffice Calc
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
    [verification] Στατιστικά ανά έλεγχο
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

# F40 — « Analyse Évolution du solde » (Fabrice, 05/10/2026): the chart of F25,
# on which one drags a zone, and under it the operations of that zone. The
# chart's own words are F25's (curve-*); these are the summary of the zone.
window-analysis-title = Ανάλυση της εξέλιξης του υπολοίπου
analysis-heading = Ανάλυση της εξέλιξης του υπολοίπου
analysis-hint = Σύρετε πάνω στο γράφημα με πατημένο το κουμπί του ποντικιού για να δείτε τις κινήσεις αυτής της περιόδου.
analysis-zone = Ζώνη:
analysis-opening = Αρχικό υπόλοιπο:
analysis-closing = Τελικό υπόλοιπο:
analysis-variation = Μεταβολή:
analysis-detail-name = Ανάλυση υπολοίπου
analysis-detail-none = Καμία κίνηση σε αυτή τη ζώνη.

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
quick-check-verification = Έλεγχος
quick-column-date = Ημερομηνία
quick-column-label = Περιγραφή
quick-column-amount = Ποσό
quick-column-category = Κατηγορία
quick-column-assignment = Κατανομή
quick-column-payment-mode = Τρόπος πληρωμής
quick-column-payee = Αντισυμβαλλόμενος
quick-column-project = Έργα
quick-column-status = Κατάσταση
quick-column-verification = Έλεγχος
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
statement-title-open = Άνοιγμα αρχείου κατάστασης λογαριασμού (OFX, QIF, CSV)
statement-title-info = Πληροφορίες για το ανοιχτό αρχείο
statement-title-integrate = Ένταξη της επιλογής στον λογαριασμό
statement-title-validate = Ένταξη αυτής της κίνησης στον λογαριασμό
statement-duplicate = Προσοχή διπλότυπο: αυτή η συναλλαγή φαίνεται ότι έχει ήδη ενταχθεί στη βάση δεδομένων (το Financial Institution Transaction ID υπάρχει)
statement-no-fitid = Προσοχή: αυτό το αρχείο δεν δίνει κανένα αναγνωριστικό (FITID) για αυτήν τη γραμμή. Δεν θα μπορεί να εντοπιστεί διπλότυπο.
statement-loaded = { $count ->
    [0] Αυτό το αρχείο δεν περιέχει καμία κίνηση για αυτόν τον λογαριασμό.
   *[other] { $count } γραμμές διαβάστηκαν, εκ των οποίων { $known } υπάρχουν ήδη στον λογαριασμό σας.
}
statement-loaded-unidentified = { $alike ->
    [0] { $count } γραμμές διαβάστηκαν· καμία δεν μοιάζει με κίνηση που υπάρχει ήδη στον λογαριασμό σας.
    [one] { $count } γραμμές διαβάστηκαν, εκ των οποίων μία μοιάζει με κίνηση που υπάρχει ήδη στον λογαριασμό σας (ίδια ημερομηνία, ίδια περιγραφή, ίδιο ποσό).
   *[other] { $count } γραμμές διαβάστηκαν, εκ των οποίων { $alike } μοιάζουν με κινήσεις που υπάρχουν ήδη στον λογαριασμό σας (ίδια ημερομηνία, ίδια περιγραφή, ίδιο ποσό).
}
statement-loaded-also-alike = { $alike ->
    [one] Μία ακόμη γραμμή μοιάζει με κίνηση που υπάρχει ήδη (ίδια ημερομηνία, ίδια περιγραφή, ίδιο ποσό).
   *[other] { $alike } ακόμη γραμμές μοιάζουν με κινήσεις που υπάρχουν ήδη (ίδια ημερομηνία, ίδια περιγραφή, ίδιο ποσό).
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
statement-qif-question = Τίποτα σε αυτό το αρχείο δεν δείχνει αν η ημερομηνία «{ $date }» γράφεται ημέρα/μήνας ή μήνας/ημέρα. Σημαίνει:
statement-qif-day-month = Ημέρα { $day }, μήνας { $month } (ημέρα/μήνας)
statement-qif-month-day = Ημέρα { $day }, μήνας { $month } (μήνας/ημέρα)
statement-qif-dates-mixed = Αυτό το αρχείο γράφει τις ημερομηνίες του με δύο τρόπους: το «{ $first }» διαβάζεται ημέρα/μήνας, το «{ $second }» μήνας/ημέρα. Δεν εισάγεται, ώστε να μην αλλοιωθεί καμία ημερομηνία.
statement-qif-amounts-mixed = Αυτό το αρχείο γράφει τα ποσά του με δύο τρόπους: το «{ $first }» με τελεία, το «{ $second }» με κόμμα. Δεν εισάγεται, ώστε να μην αλλοιωθεί κανένα ποσό.
statement-qif-opening = Αρχικό υπόλοιπο { $amount } στις { $date }: δεν είναι κίνηση, δεν εισάγεται.
statement-qif-opening-undated = Αρχικό υπόλοιπο { $amount }: δεν είναι κίνηση, δεν εισάγεται.
statement-qif-suspect = Η γραμμή { $rank }, «{ $label }» ({ $amount }), μοιάζει με αρχικό υπόλοιπο: ελέγξτε την πριν την εντάξετε.
statement-qif-rejected = { $count ->
    [one] Μία δυσανάγνωστη γραμμή δεν εισάγεται: { $lines }.
   *[other] { $count } δυσανάγνωστες γραμμές δεν εισάγονται: { $lines }.
}
statement-qif-reason-date = ημερομηνία
statement-qif-reason-amount = ποσό
statement-qif-reason-differ = αντιφατικά ποσά
statement-qif-no-account = Αυτός ο λογαριασμός δεν υπάρχει πλέον στο αρχείο: ανοίξτε ξανά το αρχείο.
statement-balance-unknown = δεν αναφέρεται στο αρχείο
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
backup-not-started = Δεν ήταν δυνατή η έναρξη του αντιγράφου ασφαλείας:
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
database-too-recent = Αυτή η βάση αποθηκεύτηκε από νεότερη έκδοση του Radinus (έκδοση βάσης { $found }· αυτή η έκδοση διαβάζει έως την έκδοση { $supported }). Ενημερώστε το Radinus για να την ανοίξετε.
database-not-radinus = Αυτό το αρχείο δεν είναι βάση Radinus.
database-unreadable = Η βάση δεν μπόρεσε να διαβαστεί: { $reason }
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
# The tick box of an account on the home window (Fabrice, 07/10/2026), and the
# line that says so when not every account is counted. No plural on purpose:
# « counted: 3 of 5 » reads the same whatever the numbers.
welcome-accounts-counted = Λογαριασμοί που υπολογίζονται στα σύνολα: { $count } από { $total }
welcome-tile-counted = Υπολογισμός αυτού του λογαριασμού στα σύνολα
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
preferences-branch-import = Εισαγωγή
preferences-leaf-verification = Έλεγχος
preferences-field-verification = Εισαγόμενες κινήσεις:
preferences-verification-hint = «Ελεγμένη»: εμπιστεύεστε την τράπεζά σας, μια εισαγόμενη κίνηση θεωρείται σωστή. «Προς έλεγχο»: κάθε εισαγόμενη κίνηση περιμένει τον έλεγχό σας· έπειτα την αλλάζετε εσείς σε «Ελεγμένη» στη λίστα κινήσεων. Η ρύθμιση αυτή ισχύει μόνο για τις επόμενες εισαγωγές.
preferences-leaf-qif = Καταστάσεις λογαριασμού QIF
preferences-field-qif-order = Σειρά ημέρας και μήνα:
preferences-qif-order-ask = Να ερωτώμαι κάθε φορά
preferences-qif-order-day-month = Πάντα ημέρα/μήνας (05/03 = 5 Μαρτίου)
preferences-qif-order-month-day = Πάντα μήνας/ημέρα (05/03 = 3 Μαΐου)
preferences-qif-order-help = Χρησιμοποιείται μόνο όταν καμία ημερομηνία του αρχείου δεν επιτρέπει να κριθεί το ζήτημα. Μόλις μια ημερομηνία όπως 24/11 αποδείξει τη σειρά, αποφασίζει το αρχείο, όποια κι αν είναι αυτή η ρύθμιση.
preferences-field-qif-label = Περιγραφή της κίνησης:
preferences-qif-label-both = Αντισυμβαλλόμενος + σημείωση
preferences-qif-label-payee = Μόνο αντισυμβαλλόμενος
preferences-qif-label-memo = Μόνο σημείωση
preferences-qif-label-help = Όταν μια κίνηση φέρει ταυτόχρονα αντισυμβαλλόμενο και σημείωση. Αν φέρει μόνο ένα από τα δύο, χρησιμοποιείται αυτό, όποια κι αν είναι αυτή η ρύθμιση.
preferences-qif-hint = Αυτές οι ρυθμίσεις ισχύουν για όλες τις καταστάσεις λογαριασμού QIF, όποια βάση δεδομένων κι αν είναι ανοιχτή. Το «Να ερωτώμαι κάθε φορά» είναι το ασφαλέστερο: ένα αρχείο με αμφίσημες ημερομηνίες δεν διαβάζεται ποτέ στην τύχη.

# The columns of a table (Fabrice, 04/10/2026): each user has his own. The
# first is the last entry of the right-click menu on a table's header; the
# others are the « Table columns » leaf of the preferences, one line per
# table whose columns can be arranged, a « Reset » button facing it.
columns-reset = Επαναφορά προεπιλεγμένων στηλών
# The header menu's two sub-menus (Fabrice, 05/10/2026). « columns-colour » is
# followed by the column's own title, hence its colon. Then the nine tints a
# column can take, and the entry that takes it off.
columns-show-hide = Εμφάνιση/Απόκρυψη
columns-colour = Χρωματισμός στήλης:
columns-colour-none = Κανένα χρώμα
columns-colour-red = Κόκκινο
columns-colour-orange = Πορτοκαλί
columns-colour-pink = Ροζ
columns-colour-pastel-green = Παστέλ πράσινο
columns-colour-green = Πράσινο
columns-colour-pastel-blue = Παστέλ μπλε
columns-colour-blue = Μπλε
columns-colour-pastel-yellow = Παστέλ κίτρινο
columns-colour-yellow = Κίτρινο
preferences-leaf-columns = Στήλες πινάκων
preferences-table-operations-list = Λίστα κινήσεων
preferences-columns-reset = Επαναφορά
preferences-columns-reset-all = Επαναφορά όλων
preferences-columns-done = Οι στήλες επανήλθαν στην αρχική τους διάταξη.
preferences-columns-hint = Κάθε πίνακας θυμάται τη σειρά των στηλών του, όσες αποκρύπτετε και το πλάτος τους. Η «Επαναφορά» του επιστρέφει αμέσως την αρχική του διάταξη.

# The reset of the comfort settings (Fabrice, 07/10/2026): columns, home
# window, display size — and nothing else.
preferences-branch-reset = Επαναφορά
preferences-leaf-comfort = Ρυθμίσεις άνεσης
preferences-comfort-reset = Επαναφορά των ρυθμίσεων άνεσης
preferences-comfort-hint = Επαναφέρει τις στήλες όλων των πινάκων, τη σειρά και τα πλαίσια ελέγχου των λογαριασμών στο αρχικό παράθυρο, καθώς και το μέγεθος της εμφάνισης. Η γλώσσα, το νόμισμα και ο έλεγχος των εισαγόμενων κινήσεων δεν αλλάζουν.
preferences-comfort-question = Επαναφορά των ρυθμίσεων άνεσης; Οι στήλες των πινάκων, το αρχικό παράθυρο και το μέγεθος της εμφάνισης θα επανέλθουν στην αρχική τους κατάσταση.
preferences-comfort-done = Οι ρυθμίσεις άνεσης επαναφέρθηκαν.

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

# --- F41 — Simulation de crédit (Fabrice, 08/10/2026) ------------------------
# Le calcul d'un prêt à taux fixe, et ce que l'historique de la base dit de la
# capacité à le rembourser. Les phrases sont écrites par le noyau ; la fenêtre
# n'en compose aucune.
menu-tools-loan-simulation = Προσομοίωση δανείου
window-loan-title = Προσομοίωση δανείου
loan-tab-credit = Το δάνειο
loan-tab-afford = Μπορώ να το αποπληρώσω;
loan-field-kind = Είδος δανείου
loan-kind-consumer = Καταναλωτικό δάνειο
loan-kind-mortgage = Στεγαστικό δάνειο
loan-field-amount = Ποσό δανείου
loan-field-payment = Μηνιαία δόση
loan-field-months = Διάρκεια
loan-field-rate = Σταθερό επιτόκιο
loan-field-fees = Έξοδα φακέλου
loan-field-insurance = Ασφάλιση ανά μήνα
loan-unit-months = μήνες
loan-unit-percent = %
loan-invalid-field = Η τιμή δεν είναι αριθμός: διορθώστε την για να ξαναγίνει ο υπολογισμός.
loan-report-button = Αναφορά PDF
loan-monthly-table = Πίνακας ανά μήνα
loan-months-count = { $count ->
        [one] { $count } μήνας
       *[other] { $count } μήνες
    }
loan-percent = { $value }%
loan-notice-payment-too-low = Αυτή η δόση δεν καλύπτει τους τόκους: το δάνειο δεν θα αποπληρωνόταν ποτέ. Η διάρκεια μένει στους 600 μήνες.
loan-notice-too-long = Αυτή η δόση θα απαιτούσε πάνω από 600 μήνες: η διάρκεια μένει στους 600 μήνες.
loan-figure-payment = Μηνιαία δόση
loan-figure-payment-insured = Δόση με ασφάλιση
loan-figure-taeg = ΣΕΠΕ
loan-figure-interest = Κόστος τόκων
loan-figure-insurance = Κόστος ασφάλισης
loan-figure-cost = Συνολικό κόστος δανείου
loan-figure-total-due = Συνολικό οφειλόμενο ποσό
loan-figure-all-in = Σύνολο αποπληρωμής, με ασφάλιση
loan-part-capital = Ποσό δανείου
loan-part-interest = Τόκοι
loan-part-fees = Έξοδα φακέλου
loan-part-insurance = Ασφάλιση
loan-donut-cost-caption = συνολικά
loan-chart-cost = Τι κοστίζει αυτό το δάνειο
loan-chart-capital = Υπόλοιπο κεφαλαίου
loan-schedule-title = Πίνακας αποπληρωμής
loan-schedule-yearly = Πίνακας αποπληρωμής, ανά έτος
loan-column-number = Αρ.
loan-column-year = Έτος
loan-column-date = Λήξη
loan-column-payment = Δόση
loan-column-payments = Δόσεις
loan-column-interest = Τόκοι
loan-column-capital = Κεφάλαιο
loan-column-insurance = Ασφάλιση
loan-column-remaining = Υπόλοιπο κεφαλαίου
loan-history-label = Εξεταζόμενη περίοδος
loan-period-last-12 = Τελευταίοι 12 μήνες
loan-accounts-title = Εξεταζόμενοι λογαριασμοί
loan-period-title = Περίοδος
loan-column-account = Λογαριασμός
loan-column-bank = Τράπεζα
loan-column-balance = Πραγματικό υπόλοιπο
loan-unavailable-no-account = Επιλέξτε τουλάχιστον έναν λογαριασμό για να εξετάσετε το ιστορικό σας.
loan-unavailable-no-month = Αυτή η περίοδος δεν έχει ακόμη κανέναν πλήρη μήνα: επιλέξτε άλλη.
loan-verdict-title = Με λίγα λόγια
loan-verdict-green = Εφικτό
loan-verdict-orange = Οριακό
loan-verdict-red = Επικίνδυνο
loan-verdict-no-income = Κανένα έσοδο σε αυτή την περίοδο: ο δείκτης χρέους δεν υπολογίζεται.
loan-check-debt-green = Δείκτης χρέους { $ratio }: κάτω από το όριο της μεθόδου ({ $green }).
loan-check-debt-orange = Δείκτης χρέους { $ratio }: μεταξύ { $green } και { $red }, στο όριο.
loan-check-debt-red = Δείκτης χρέους { $ratio }: πάνω από { $red }.
loan-check-effort = Η δόση των { $payment } παίρνει το { $share } όσων αποταμιεύετε { $kind ->
        [good] έναν καλό μήνα
        [hard] έναν δύσκολο μήνα
       *[usual] έναν συνηθισμένο μήνα
    } ({ $margin }).
loan-check-effort-none = { $kind ->
        [good] Ένας καλός μήνας
        [hard] Ένας δύσκολος μήνας
       *[usual] Ένας συνηθισμένος μήνας
    } δεν σας αφήνει τίποτα στην άκρη: η δόση των { $payment } θα έβγαινε από το αποθεματικό σας.
loan-check-reserve-green = Το υπόλοιπό σας μένει θετικό ως το τέλος του δανείου.
loan-check-reserve-red = Εξαιτίας αυτού του δανείου, το υπόλοιπό σας θα έπεφτε κάτω από το μηδέν: { $month }.
loan-check-reserve-sooner = Το υπόλοιπό σας θα έπεφτε κάτω από το μηδέν ({ $month }), { $count ->
        [one] έναν μήνα
       *[other] { $count } μήνες
    } νωρίτερα απ' ό,τι χωρίς αυτό το δάνειο.
loan-check-reserve-anyway = Το υπόλοιπό σας θα έπεφτε κάτω από το μηδέν ακόμη και χωρίς αυτό το δάνειο (περίπου: { $month }), που δεν αλλάζει σχεδόν τίποτα.
loan-check-reserve-floor-green = Το υπόλοιπό σας μένει πάνω από το αποθεματικό ασφαλείας ({ $floor }) ως το τέλος του δανείου.
loan-check-reserve-floor-red = Εξαιτίας αυτού του δανείου, το υπόλοιπό σας θα έπεφτε κάτω από το αποθεματικό ασφαλείας ({ $floor }): { $month }.
loan-check-reserve-floor-sooner = Το υπόλοιπό σας θα έπεφτε κάτω από το αποθεματικό ασφαλείας ({ $floor }· { $month }), { $count ->
        [one] έναν μήνα
       *[other] { $count } μήνες
    } νωρίτερα απ' ό,τι χωρίς αυτό το δάνειο.
loan-check-reserve-floor-anyway = Το υπόλοιπό σας θα έπεφτε κάτω από το αποθεματικό ασφαλείας ({ $floor }) ακόμη και χωρίς αυτό το δάνειο (περίπου: { $month }), που δεν αλλάζει σχεδόν τίποτα.
loan-warning-deficit = Προσοχή: σε αυτή την περίοδο, τα έξοδά σας ξεπερνούν ήδη τα έσοδα κατά { $amount } τον μήνα κατά μέσο όρο, πριν από οποιοδήποτε δάνειο.
loan-figure-reference = Αποταμίευση { $kind ->
        [good] ενός καλού μήνα
        [hard] ενός δύσκολου μήνα
       *[usual] ενός συνηθισμένου μήνα
    }
loan-figure-tipped = Μήνες που το δάνειο θα έφερνε μείον
loan-gauge-caption = δείκτης χρέους
loan-figure-income = Μέσα έσοδα ανά μήνα
loan-figure-spending = Μέσα έξοδα ανά μήνα
loan-figure-saving = Μέση αποταμίευση ανά μήνα
loan-figure-running = Τρέχοντα δάνεια ανά μήνα
loan-figure-new = Νέα δόση, με ασφάλιση
loan-figure-rest = Για να ζείτε ανά μήνα
loan-figure-debt = Δείκτης χρέους
loan-red-months-value = { $count } από { $total }
loan-figure-balance-now = Πραγματικό υπόλοιπο σήμερα
loan-figure-balance-end = Προβλεπόμενο υπόλοιπο στη λήξη του δανείου
loan-chart-income = Πού πηγαίνει το μέσο εισόδημά σας
loan-donut-income-caption = μέσο εισόδημα
loan-part-spending = Τρέχοντα έξοδα
loan-part-running = Τρέχοντα δάνεια
loan-part-new = Νέο δάνειο
loan-part-rest = Υπόλοιπο
loan-part-missing = Λείπουν
loan-chart-history = Το ιστορικό σας με αυτό το δάνειο
loan-chart-history-hint = Τι θα είχε μείνει κάθε μήνα μετά τη δόση. Έντονο κόκκινο: οι μήνες που το δάνειο θα έφερνε μείον· απαλό κόκκινο: όσοι ήταν ήδη μείον χωρίς αυτό.
loan-chart-projection = Το προβλεπόμενο υπόλοιπό σας
loan-mark-loan-end = Λήξη: { $label }
loan-mark-negative = Μείον
loan-mark-floor = Κάτω από το αποθεματικό
loan-mark-floor-line = Αποθεματικό ασφαλείας
loan-running-title = Τρέχοντα δάνεια που λήφθηκαν υπόψη
loan-running-column-label = Περιοδική κίνηση
loan-running-column-monthly = Ανά μήνα
loan-running-column-end = Τελευταία δόση
loan-no-running = Δεν αναγνωρίστηκε κανένα τρέχον δάνειο στις περιοδικές κινήσεις σας.
loan-period-caption = { $from } – { $to } ({ $count ->
        [one] { $count } μήνας
       *[other] { $count } μήνες
    })
loan-transfers = { $count ->
        [0] Δεν αναγνωρίστηκε καμία μεταφορά ανάμεσα στους επιλεγμένους λογαριασμούς σας.
        [one] Μία μεταφορά ανάμεσα στους επιλεγμένους λογαριασμούς σας αναγνωρίστηκε και εξαιρέθηκε.
       *[other] { $count } μεταφορές ανάμεσα στους επιλεγμένους λογαριασμούς σας αναγνωρίστηκαν και εξαιρέθηκαν.
    }
loan-method = Μέσοι όροι στους πλήρεις μήνες της περιόδου, κινήσεις συμφωνημένες και δεσμευμένες, χωρίς τις μεταφορές ανάμεσα στους επιλεγμένους λογαριασμούς σας.
loan-report-title = Προσομοίωση δανείου
loan-report-made-on = προσομοίωση της { $date }
loan-disclaimer = Ενδεικτική προσομοίωση χωρίς συμβατική ισχύ. Δεσμευτική είναι μόνο η προσφορά της τράπεζας.
loan-tab-rules = Ρυθμίσεις κρίσης
loan-method-optimistic = Αισιόδοξη
loan-method-neutral = Ουδέτερη
loan-method-severe = Αυστηρή
loan-method-line = Μέθοδος κρίσης: { $method }
loan-method-verdict = { $method }: { $verdict }
loan-rules-intro = Η ετυμηγορία απαντά σε τρία ερωτήματα, και κάθε μέθοδος βάζει τις δικές της απαιτήσεις. Διαλέξτε αυτή που σας ταιριάζει: η ετυμηγορία της καρτέλας «Μπορώ να το αποπληρώσω;» την ακολουθεί. Η τελευταία γραμμή υποθέτει ότι τα έξοδά σας αυξάνονται κάθε χρόνο κατά το ποσοστό που δίνεται· η δόση δεν αλλάζει.
loan-rule-row-debt = Αποδεκτός δείκτης χρέους
loan-rule-row-reference = Αποταμίευση αναφοράς
loan-rule-row-share = Μέρος αυτής της αποταμίευσης που μπορεί να πάρει η δόση
loan-rule-row-floor = Όριο κάτω από το οποίο δεν πρέπει να πέσει το υπόλοιπο
loan-rule-row-sooner = Αν το υπόλοιπο πέσει κάτω από αυτό ακόμη και χωρίς το δάνειο
loan-rule-row-growth = Αύξηση των εξόδων σας ανά έτος
loan-rule-limits = πράσινο έως { $green }, πορτοκαλί έως { $red }
loan-rule-reference = { $kind ->
        [good] ένας καλός μήνας
        [hard] ένας δύσκολος μήνας
       *[usual] ένας συνηθισμένος μήνας
    }: { $amount }
loan-rule-floor-zero = μηδέν
loan-rule-floor-cushion = ένας μήνας εξόδων: { $amount }
loan-rule-sooner = πορτοκαλί αν το δάνειο το επισπεύδει κατά { $orange }, κόκκινο κατά { $red }
loan-unit-percent-year = % τον χρόνο
loan-method-optimistic-explain = Η αισιόδοξη μέθοδος υποθέτει έναν καλό μήνα, δέχεται δείκτη χρέους έως 40% και δεν κρατά αποθεματικό: δείχνει τι είναι δυνατό αν όλα πάνε καλά.
loan-method-neutral-explain = Η ουδέτερη μέθοδος υποθέτει έναν συνηθισμένο μήνα και ακολουθεί τον κανόνα των τραπεζών, 33 έως 35%: είναι η κρίση αναφοράς.
loan-method-severe-explain = Η αυστηρή μέθοδος υποθέτει έναν δύσκολο μήνα και κρατά έναν μήνα εξόδων ως αποθεματικό για τα απρόοπτα: δείχνει τι αντέχει ακόμη κι αν τα πράγματα πάνε άσχημα.

# --- F42 — Consommation d'un appareil électrique (Fabrice, 09/10/2026) -------
# Ce que coûte un appareil, allumé et en veille, en heures pleines et en
# heures creuses. Le tarif est une préférence de la base (« tarif.electricite »).
menu-tools-appliance-cost = Κατανάλωση ηλεκτρικής συσκευής
window-appliance-title = Κατανάλωση ηλεκτρικής συσκευής
appliance-device-title = Η συσκευή
appliance-on-title = Σε λειτουργία
appliance-standby-title = Σε αναμονή
appliance-field-on-watts = Ισχύς σε λειτουργία
appliance-field-on-hours = Χρόνος λειτουργίας ανά ημέρα
appliance-field-days = Ημέρες χρήσης ανά εβδομάδα
appliance-field-share = Ποσοστό λειτουργίας σε ώρες εκτός αιχμής
appliance-field-standby-watts = Ισχύς σε αναμονή
appliance-field-standby-hours = Χρόνος αναμονής ανά ημέρα χρήσης
appliance-unit-watts = W
appliance-unit-hours = h
appliance-unit-days = στις 7
appliance-unit-percent = %
appliance-unit-price = { $sign }/kWh
appliance-standby-hint = Αν μείνει κενό, η αναμονή διαρκεί το υπόλοιπο της ημέρας. Τις ημέρες χωρίς χρήση η συσκευή μένει στην πρίζα: όλος αυτός ο χρόνος μετρά ως αναμονή. Εκτός πρίζας, η ισχύς αναμονής της είναι 0 W.
appliance-contract-title = Το συμβόλαιό σας
appliance-field-option = Επιλογή τιμολογίου
appliance-option-base = Βασικό (μία τιμή)
appliance-option-off-peak = Ώρες αιχμής / Ώρες εκτός αιχμής
appliance-field-base = Τιμή ανά kWh
appliance-field-peak = Τιμή ανά kWh σε ώρες αιχμής
appliance-field-off-peak = Τιμή ανά kWh σε ώρες εκτός αιχμής
appliance-field-off-peak-hours = Ώρες εκτός αιχμής ανά ημέρα
appliance-contract-hint = Αυτές οι τιμές ισχύουν μόνο για αυτόν τον υπολογισμό. Το αποθηκευμένο τιμολόγιο ορίζεται στις Ρυθμίσεις › Προτιμήσεις › Εργαλεία.
appliance-contract-reset = Επαναφορά του αποθηκευμένου τιμολογίου
appliance-period-day = Ανά ημέρα
appliance-period-month = Ανά μήνα
appliance-period-year = Ανά έτος
appliance-energy = { $value } kWh
appliance-less-than = λιγότερο από { $amount }
appliance-detail-title = Αναλυτικά για ένα έτος
appliance-column-part = Στοιχείο
appliance-column-energy = Ενέργεια
appliance-column-cost = Κόστος
appliance-column-share = Ποσοστό
appliance-line-on = Σε λειτουργία
appliance-line-standby = Σε αναμονή
appliance-line-on-peak = Σε λειτουργία, ώρες αιχμής
appliance-line-on-off-peak = Σε λειτουργία, ώρες εκτός αιχμής
appliance-line-standby-peak = Σε αναμονή, ώρες αιχμής
appliance-line-standby-off-peak = Σε αναμονή, ώρες εκτός αιχμής
appliance-line-total = Σύνολο
appliance-chart-title = Πού πηγαίνουν τα χρήματα
appliance-chart-caption = ανά έτος
appliance-standby-sentence = Μόνο η αναμονή κοστίζει { $amount } τον χρόνο: { $share } του κόστους της συσκευής.
appliance-note-plate = Η ισχύς που αναγράφεται στη συσκευή ή στο εγχειρίδιό της είναι μέγιστη τιμή: σε λειτουργία, οι περισσότερες συσκευές καταναλώνουν λιγότερο. Για πραγματική τιμή, μετρήστε την με έναν μετρητή κατανάλωσης πρίζας και καταχωρίστε την ένδειξή του.
appliance-note-subscription = Το πάγιο δεν υπολογίζεται: το πληρώνετε είτε η συσκευή είναι στην πρίζα είτε όχι.
appliance-invalid-watts = Παρακαλώ εισαγάγετε ισχύ από 0 έως 100.000 W.
appliance-invalid-hours = Παρακαλώ εισαγάγετε διάρκεια από 0 έως 24 ώρες την ημέρα.
appliance-invalid-days = Παρακαλώ εισαγάγετε ακέραιο αριθμό ημερών, από 0 έως 7.
appliance-invalid-share = Παρακαλώ εισαγάγετε ποσοστό από 0 έως 100%.
appliance-invalid-day-overflow = Η λειτουργία και η αναμονή ξεπερνούν τις 24 ώρες την ημέρα.
appliance-invalid-price = Παρακαλώ εισαγάγετε τιμή ανά kWh από 0 έως 100.
appliance-invalid-off-peak-hours = Παρακαλώ εισαγάγετε ακέραιο αριθμό ωρών εκτός αιχμής, από 0 έως 24.
preferences-branch-tools = Εργαλεία
preferences-leaf-electricity = Τιμολόγιο ηλεκτρικού ρεύματος
preferences-electricity-blue = Επιστροφή στο Tarif Bleu της EDF
preferences-electricity-hint = Το τιμολόγιο του συμβολαίου σας, που χρησιμοποιεί το εργαλείο «Κατανάλωση ηλεκτρικής συσκευής». Προεπιλογή: το Tarif Bleu της EDF (Γαλλία) την 1η Αυγούστου 2026, τιμές με φόρους, μετρητής 3 έως 6 kVA. Αυτές οι τιμές αλλάζουν συχνά τον Φεβρουάριο και τον Αύγουστο: αντιγράψτε αυτές του λογαριασμού σας.

# --- F43 — Mon matelas de sécurité (Fabrice, 09/10/2026) -------------------------
# Combien de mois l'épargne tiendrait si les revenus s'arrêtaient. Les
# phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-safety-cushion = Το αποθεματικό ασφαλείας μου
window-cushion-title = Το αποθεματικό ασφαλείας μου
cushion-question = Αν τα εισοδήματά σας σταματούσαν αύριο, πόσους μήνες θα αντέχατε με τις αποταμιεύσεις σας;
cushion-accounts-title = Οι λογαριασμοί σας
cushion-column-account = Λογαριασμός
cushion-column-balance = Πραγματικό υπόλοιπο
cushion-column-savings = Αποταμίευση
cushion-column-spending = Έξοδα
cushion-accounts-hint = «Αποταμίευση»: τα χρήματα στα οποία βασίζεστε σε περίπτωση δυσκολίας. «Έξοδα»: οι λογαριασμοί από τους οποίους γίνονται τα καθημερινά σας έξοδα.
cushion-history-label = Περίοδος ανάλυσης
cushion-backup-label = Εναλλακτικό εισόδημα ανά μήνα
cushion-backup-hint = Ό,τι θα συνέχιζε να εισπράττεται: επίδομα ανεργίας, μισθός συντρόφου… Κενό: κανένα εισόδημα.
cushion-categories-title = Τα έξοδα που λαμβάνονται υπόψη
cushion-categories-hint = Αποεπιλέξτε ό,τι θα περικόπτατε σε περίπτωση δυσκολίας.
cushion-categories-empty = Κανένα έξοδο σε αυτή την περίοδο.
cushion-verdict-title = Το αποθεματικό σας
cushion-targets-title = Τα όρια ασφαλείας
cushion-projection-title = Οι αποταμιεύσεις σας σε περίπτωση δυσκολίας
cushion-projection-hint = Τι θα απέμενε κάθε μήνα αν τα εισοδήματά σας σταματούσαν σήμερα.
cushion-note = Εκτίμηση βάσει του ιστορικού σας: τα έξοδα ενός δύσκολου μήνα μπορεί να διαφέρουν από τον μέσο όρο.
cushion-invalid-backup = Αυτό το ποσό δεν είναι αναγνώσιμο: διορθώστε το για να γίνει ξανά ο υπολογισμός.
cushion-no-spending-account = Επιλέξτε τουλάχιστον έναν λογαριασμό «Έξοδα».
cushion-no-month = Αυτή η περίοδος δεν έχει ακόμη κανέναν πλήρη μήνα.
cushion-months = { $value } μήνες
cushion-per-month = { $amount } ανά μήνα
cushion-figure-holds = Χωρίς όριο
cushion-gauge-caption = καλυμμένων εξόδων
cushion-verdict-short = Λιγότερο από τρεις μήνες: ένα απρόοπτο θα σας έφερνε γρήγορα σε δύσκολη θέση.
cushion-verdict-fair = Από τρεις έως έξι μήνες: ένα ικανοποιητικό αποθεματικό, που αξίζει να ενισχύσετε αν μπορείτε.
cushion-verdict-solid = Έξι μήνες ή περισσότερο: το αποθεματικό σας είναι γερό.
cushion-verdict-holds = Το εναλλακτικό εισόδημά σας καλύπτει τα έξοδά σας: οι αποταμιεύσεις σας δεν θα μειώνονταν.
cushion-verdict-nothing = Κανένα έξοδο δεν λαμβάνεται υπόψη για την περίοδο: δεν υπάρχει τίποτα να καλυφθεί.
cushion-tile-savings = Διαθέσιμες αποταμιεύσεις
cushion-tile-spending = Έξοδα που λαμβάνονται υπόψη
cushion-tile-backup = Εναλλακτικό εισόδημα
cushion-tile-burn = Οι αποταμιεύσεις θα μειώνονταν κατά
cushion-tile-rhythm = Ρυθμός αποταμίευσης
cushion-burn-none = Τίποτα
cushion-target-title = { $months } μήνες εξόδων: { $amount }
cushion-target-reached = Επιτεύχθηκε.
cushion-target-date = Λείπουν { $missing }. Με τον ρυθμό αποταμίευσής σας, εκτιμώμενη επίτευξη: { $month }.
cushion-target-never = Λείπουν { $missing }. Οι αποταμιεύσεις σας δεν αυξήθηκαν κατά την περίοδο: με αυτόν τον ρυθμό, το όριο αυτό δεν θα επιτευχθεί.
cushion-mark-empty = Εξάντληση: { $month }
cushion-period = Μέσος όρος { $count ->
        [one] { $count } πλήρους μήνα
       *[other] { $count } πλήρων μηνών
    }. Περίοδος: { $from } – { $to }. { $transfers ->
        [0] Καμία μεταφορά μεταξύ των λογαριασμών σας.
        [one] Μία μεταφορά μεταξύ των λογαριασμών σας, εξαιρέθηκε.
       *[other] { $transfers } μεταφορές μεταξύ των λογαριασμών σας, εξαιρέθηκαν.
    }

# --- F44 — Objectif Épargne (Fabrice, 10/10/2026) --------------------------------
# Quand aurai-je ce montant, combien aurai-je à cette date, combien épargner.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-savings-goal = Στόχος αποταμίευσης
window-goal-title = Στόχος αποταμίευσης
goal-accounts-title = Οι λογαριασμοί που παρακολουθούνται
goal-column-account = Λογαριασμός
goal-column-balance = Πραγματικό υπόλοιπο
goal-accounts-hint = Μια μεταφορά μεταξύ δύο παρακολουθούμενων λογαριασμών αλληλοαναιρείται· μια μεταφορά προς λογαριασμό που δεν παρακολουθείται μετράει ως εκροή.
goal-period-label = Περίοδος αναφοράς
goal-period-range = Εύρος ετών…
goal-range-from = από
goal-range-to = έως
goal-question-title = Η ερώτησή σας
goal-question-when = Πότε θα έχω αυτό το ποσό;
goal-question-amount = Πόσα θα έχω σε αυτή την ημερομηνία;
goal-question-effort = Πόσα να αποταμιεύω για να έχω αυτό το ποσό σε αυτή την ημερομηνία;
goal-field-target = Ποσό-στόχος
goal-field-date = Ημερομηνία-στόχος
goal-field-rate = Ετήσιο επιτόκιο αποταμίευσης
goal-field-extra = Κι αν αποταμίευα επιπλέον, ανά μήνα
goal-options-hint = Κενά: χωρίς τόκους, τίποτα επιπλέον.
goal-answer-title = Η απάντηση
goal-chart-title = Το υπόλοιπό σας, χθες και αύριο
goal-chart-hint = Συνεχής γραμμή: το πραγματικό υπόλοιπο των τελευταίων δώδεκα μηνών· διακεκομμένη: η προβολή· ανοιχτόχρωμη ζώνη: το εύρος ανάλογα με τους μήνες.
goal-disclaimer = Μια προβολή βάσει του ιστορικού σας, όχι υπόσχεση: ένα απρόοπτο μπορεί να αλλάξει τα πάντα.
goal-no-account = Επιλέξτε τουλάχιστον έναν λογαριασμό για παρακολούθηση.
goal-no-month = Αυτή η περίοδος δεν έχει ακόμη κανέναν πλήρη μήνα.
goal-invalid-target = Ένα ποσό προς επίτευξη, παρακαλώ.
goal-invalid-date = Μια μελλοντική ημερομηνία, μέσα στα επόμενα πενήντα χρόνια, παρακαλώ.
goal-invalid-rate = Ένα επιτόκιο από 0 έως 100 %, παρακαλώ.
goal-invalid-extra = Αυτό το ποσό δεν είναι αναγνώσιμο: διορθώστε το για να γίνει ξανά ο υπολογισμός.
goal-per-month = { $amount } ανά μήνα
goal-tile-balance = Υπόλοιπο σήμερα
goal-tile-rhythm = Μέσος ρυθμός
goal-tile-target = Στόχος
goal-tile-reached = Επίτευξη περίπου
goal-tile-date = Ημερομηνία-στόχος
goal-tile-projected = Προβλεπόμενο υπόλοιπο
goal-tile-saved = Αποταμίευση έως τότε
goal-tile-interest = Εκ των οποίων τόκοι
goal-tile-needed = Προς αποταμίευση
goal-when-already = Έχετε ήδη { $amount }: οι παρακολουθούμενοι λογαριασμοί σας ανέρχονται συνολικά σε { $balance }.
goal-when-reached = Θα έχετε { $amount } σε { $months ->
        [one] έναν μήνα
       *[other] { $months } μήνες
    }. Εκτιμώμενη επίτευξη: { $month }.
goal-when-range = Ανάλογα με τους μήνες, εύρος: { $early } – { $late }.
goal-when-range-open = Νωρίτερη εκτίμηση: { $early }· με αδύναμους μήνες, ο στόχος δεν θα επιτυγχανόταν.
goal-when-never = Με αυτόν τον ρυθμό, δεν θα φτάσετε το ποσό των { $amount }.
goal-zero = Το υπόλοιπό σας θα μηδενιζόταν. Εκτιμώμενη ημερομηνία: { $month }.
goal-amount = { $month }: θα είχατε περίπου { $amount }.
goal-amount-range = Ανάλογα με τους μήνες, μεταξύ { $low } και { $high }.
goal-effort-more = Για να έχετε { $amount } (ημερομηνία-στόχος: { $month }), θα έπρεπε να αποταμιεύετε κατά μέσο όρο { $monthly } ανά μήνα, δηλαδή { $gap } περισσότερα από σήμερα.
goal-effort-less = Για να έχετε { $amount } (ημερομηνία-στόχος: { $month }), θα αρκούσαν { $monthly } ανά μήνα, δηλαδή { $gap } λιγότερα από σήμερα: είστε μπροστά από τον στόχο.
goal-effort-range = Ανάλογα με τους μήνες, η απόκλιση από τον ρυθμό σας θα κυμαινόταν από { $low } έως { $high } ανά μήνα.
goal-chart-target = Στόχος: { $amount }
goal-chart-today = Σήμερα
goal-note-seasons = Η προβολή ακολουθεί τις εποχές: κάθε επόμενος μήνας παίρνει τον μέσο όρο των ίδιων μηνών της περιόδου.
goal-note-range = Το εύρος προκύπτει από τους αδύναμους και τους ισχυρούς μήνες της περιόδου: το χαμηλότερο και το υψηλότερο τεταρτημόριο.
goal-note-loan = Λήξη του δανείου «{ $label }»: { $month }. Στη συνέχεια, { $amount } επιπλέον ανά μήνα.
goal-note-interest = Οι τόκοι υπολογίζονται κάθε μήνα με επιτόκιο { $rate } % ετησίως: μια προσέγγιση του κανόνα των δεκαπενθημέρων των λογαριασμών ταμιευτηρίου.
goal-period = Ρυθμός υπολογισμένος σε { $count ->
        [one] { $count } πλήρη μήνα
       *[other] { $count } πλήρεις μήνες
    }. Περίοδος: { $from } – { $to }. { $transfers ->
        [0] Καμία μεταφορά μεταξύ των παρακολουθούμενων λογαριασμών σας.
        [one] Μία μεταφορά μεταξύ των παρακολουθούμενων λογαριασμών σας, εξαιρέθηκε.
       *[other] { $transfers } μεταφορές μεταξύ των παρακολουθούμενων λογαριασμών σας, εξαιρέθηκαν.
    }

# --- F45 — Et si je réduisais… ? (Fabrice, 10/10/2026) ----------------------------
# Réduire des postes de dépense, et voir ce que ça change dans le temps.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-spending-cut = Κι αν μείωνα…;
window-cut-title = Κι αν μείωνα…;
cut-axis-label = Ομαδοποίηση ανά
cut-axis-category = Κατηγορίες
cut-axis-payee = Αντισυμβαλλόμενοι
cut-axis-budget-line = Κονδύλια προϋπολογισμού
cut-table-title = Οι δαπάνες σας, κονδύλι προς κονδύλι
cut-table-hint = Πληκτρολογήστε μια μείωση σε % ή σε { $sign } ανά μήνα στα κονδύλια που θέλετε να ελαφρύνετε. Μια μείωση δεν μπορεί να υπερβαίνει την ίδια τη δαπάνη.
cut-column-monthly = Ανά μήνα
cut-column-cut = Μείωση
cut-column-after = Μετά
cut-column-yearly = Όφελος ανά έτος
cut-total = Σύνολο
cut-horizon-label = Ορίζοντας
cut-settings-title = Ρυθμίσεις
cut-options-hint = Το επιτόκιο και το ποσό-στόχος είναι προαιρετικά.
cut-report-button = Αναφορά PDF
cut-chart-title = Το υπόλοιπό σας, χωρίς και με τις μειώσεις
cut-chart-hint = Συνεχής γραμμή: το πραγματικό υπόλοιπο των τελευταίων δώδεκα μηνών· γκρι διακεκομμένη: η προβολή χωρίς μείωση· μπλε: με τις μειώσεις· πράσινο: τα χρήματα που κερδίζετε.
cut-donut-title = Οι μηνιαίες δαπάνες σας μετά τη μείωση
cut-donut-caption = ανά μήνα μετά τη μείωση
cut-donut-others = Άλλα κονδύλια
cut-donut-saved = Εξοικονόμηση
cut-legend-with = Με τις μειώσεις
cut-legend-without = Χωρίς μείωση
cut-years = { $years ->
        [one] { $years } χρόνος
       *[other] { $years } χρόνια
    }
cut-headline-none = Πληκτρολογήστε μια μείωση στον πίνακα για να δείτε την επίδρασή της.
cut-headline = Μειώνοντας { $count ->
        [one] αυτό το κονδύλι
       *[other] αυτά τα { $count } κονδύλια
    }, θα βάζατε στην άκρη { $monthly } επιπλέον ανά μήνα, δηλαδή { $yearly } ετησίως.
cut-tile-monthly = Όφελος ανά μήνα
cut-tile-yearly = Όφελος ανά έτος
cut-tile-horizon = Όφελος σε { $years ->
        [one] { $years } χρόνο
       *[other] { $years } χρόνια
    }
cut-tile-spending = Δαπάνες ανά μήνα
cut-target-already = Έχετε ήδη { $amount }.
cut-target-sooner = Εκτιμώμενη επίτευξη του ποσού των { $amount }: { $with } (χωρίς μειώσεις: { $without }), { $months ->
        [0] όχι νωρίτερα
        [one] έναν μήνα νωρίτερα
       *[other] { $months } μήνες νωρίτερα
    }.
cut-target-only-with = Με αυτές τις μειώσεις, εκτιμώμενη επίτευξη του ποσού των { $amount }: { $with }· χωρίς αυτές, με τον τρέχοντα ρυθμό σας, ποτέ.
cut-target-never = Ακόμη και με αυτές τις μειώσεις, δεν θα φτάνατε το ποσό των { $amount } με τον τρέχοντα ρυθμό σας.
cut-note-seasons = Κάθε μείωση ακολουθεί τις εποχές του κονδυλίου της: ένα κονδύλι που βαραίνει κυρίως το καλοκαίρι αποδίδει κυρίως το καλοκαίρι.
cut-note-capped = Μια μείωση που πληκτρολογήθηκε υπερέβαινε τη δαπάνη: περιορίστηκε στην ίδια τη δαπάνη.
cut-invalid-cut = Αυτή η μείωση δεν είναι αναγνώσιμη: ένα ποσοστό από 0 έως 100 ή ένα ποσό ανά μήνα.
cut-report-settings = Οι ρυθμίσεις
cut-report-result = Το αποτέλεσμα
cut-report-accounts = Οι λογαριασμοί που παρακολουθούνται

# --- F46 — Préparer mes vacances (Fabrice, 10/10/2026) -----------------------------
# Ce que coûtera le prochain voyage, séjour ou croisière.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-holiday = Προετοιμασία των διακοπών μου
window-holiday-title = Προετοιμασία των διακοπών μου
holiday-trip-title = Το ταξίδι
holiday-field-trip = Είδος ταξιδιού
holiday-trip-stay = Διαμονή
holiday-trip-cruise = Κρουαζιέρα
holiday-field-adults = Ενήλικες
holiday-field-children = Παιδιά
holiday-field-nights = Διάρκεια διαμονής, σε νύχτες
holiday-field-days = Ημέρες
holiday-field-months = Μήνες πριν από την αναχώρηση
holiday-field-stops = Αριθμός λιμανιών προσέγγισης
holiday-saved-title = Ήδη αποταμιευμένα
holiday-saved-hint = Επιλέξτε τους λογαριασμούς όπου τα χρήματα των διακοπών έχουν ήδη μπει στην άκρη: το πραγματικό τους υπόλοιπο μετράει ως ήδη αποταμιευμένο.
holiday-budget-title = Ο προϋπολογισμός
holiday-budget-hint = Για κάθε κονδύλι, ένα ποσό, για ποιους ισχύει και για πόσο διάστημα. Ένα κενό κονδύλι δεν μετράει.
holiday-optional-title = Προαιρετικές γραμμές
holiday-result-title = Το αποτέλεσμα
holiday-donut-title = Πού πηγαίνουν τα χρήματα του ταξιδιού
holiday-donut-caption = για το ταξίδι
holiday-child-label = Τιμή παιδιού
holiday-count-label = Καμπίνες
holiday-open = Άνοιγμα έργου…
holiday-save = Αποθήκευση του έργου…
holiday-pdf = Αναφορά PDF
holiday-excel = Εξαγωγή σε Excel
holiday-file-filter = Έργο διακοπών
holiday-replace-question = Το άνοιγμα αυτού του έργου θα αντικαταστήσει ό,τι έχει πληκτρολογηθεί στο παράθυρο. Συνέχεια;
holiday-file-saved = Το έργο αποθηκεύτηκε: { $file }
holiday-file-opened = Το έργο άνοιξε: { $file }
holiday-file-not-project = Αυτό το αρχείο δεν είναι έργο διακοπών του Radinus.
holiday-file-too-recent = Αυτό το έργο προέρχεται από νεότερη έκδοση του Radinus: ενημερώστε το Radinus για να το ανοίξετε.
holiday-file-failed = Δεν ήταν δυνατή η ανάγνωση ή η εγγραφή του αρχείου: { $reason }
holiday-line-transport = Μεταφορά μετ' επιστροφής
holiday-line-lodging = Διαμονή
holiday-line-meals = Γεύματα και τρέχοντα έξοδα
holiday-line-visits = Επισκέψεις και ψυχαγωγία
holiday-line-port = Μετάβαση έως το λιμάνι
holiday-line-cabins = Καμπίνες
holiday-line-service = Χρέωση υπηρεσιών (φιλοδωρήματα)
holiday-line-drinks = Πακέτο ποτών
holiday-line-excursions = Εκδρομές στα λιμάνια προσέγγισης
holiday-line-port-taxes = Λιμενικά τέλη
holiday-line-wifi = Wifi εν πλω
holiday-line-onboard = Έξοδα εν πλω και στα λιμάνια
holiday-line-other = Άλλα έξοδα και απρόοπτα
holiday-line-insurance = Ασφάλεια ακύρωσης
holiday-line-stay-tax = Φόρος διαμονής
holiday-line-car = Αυτοκίνητο στον προορισμό, καύσιμα και διόδια
holiday-line-parking = Στάθμευση στο αεροδρόμιο ή στον σταθμό
holiday-line-bank = Τραπεζικές χρεώσεις στο εξωτερικό
holiday-line-formalities = Διατυπώσεις (διαβατήριο, βίζα, εμβόλια)
holiday-line-pets = Φύλαξη κατοικιδίων
holiday-span-trip = για τη διαμονή
holiday-span-night = ανά νύχτα
holiday-span-day = ανά ημέρα
holiday-span-stop = ανά λιμάνι
holiday-who-all = για όλους
holiday-who-person = ανά άτομο
holiday-who-adults = ανά ενήλικα
holiday-cabins-count = { $count ->
        [one] { $count } καμπίνα
       *[other] { $count } καμπίνες
    }
holiday-days = { $days ->
        [one] { $days } ημέρα
       *[other] { $days } ημέρες
    }
holiday-invalid-count = Έναν ακέραιο αριθμό, παρακαλώ.
holiday-invalid-amount = Αυτό το ποσό δεν είναι αναγνώσιμο: ένας θετικός αριθμός ή ένα ποσοστό από 0 έως 100.
holiday-headline-empty = Πληκτρολογήστε τα ποσά του προϋπολογισμού για να δείτε πόσο θα κοστίσει το ταξίδι.
holiday-headline-stay = Αυτή η διαμονή θα κόστιζε { $total } για { $people ->
        [one] ένα άτομο
       *[other] { $people } άτομα
    } και { $nights ->
        [0] καμία νύχτα
        [one] μία νύχτα
       *[other] { $nights } νύχτες
    }.
holiday-headline-cruise = Αυτή η κρουαζιέρα θα κόστιζε { $total } για { $people ->
        [one] ένα άτομο
       *[other] { $people } άτομα
    } και { $nights ->
        [0] καμία νύχτα
        [one] μία νύχτα
       *[other] { $nights } νύχτες
    }.
holiday-tile-total = Συνολικό κόστος
holiday-tile-person = Ανά άτομο
holiday-tile-person-day = Ανά άτομο ανά ημέρα
holiday-tile-saved = Ήδη αποταμιευμένα
holiday-tile-remaining = Απομένει να χρηματοδοτηθεί
holiday-tile-monthly = Απαιτούμενη αποταμίευση
holiday-remaining-none = Τίποτα: έχει καλυφθεί
holiday-monthly-none = Τίποτα να βάλετε στην άκρη
holiday-monthly-now = Αναχώρηση αυτόν τον μήνα
holiday-note-days = Οι ημέρες είναι οι νύχτες συν μία: επτά νύχτες κάνουν οκτώ ημέρες.
holiday-note-child = Ανά άτομο, ένα παιδί πληρώνει την τιμή παιδιού αν έχει δοθεί· αν είναι κενή, πληρώνει όπως ένας ενήλικας.
holiday-note-percent = Ένα ποσοστό ασφάλειας εφαρμόζεται στα κύρια κονδύλια του ταξιδιού· αυτό των τραπεζικών χρεώσεων, στα έξοδα στον προορισμό.
holiday-sheet-budget = Προϋπολογισμός
holiday-sheet-result = Αποτέλεσμα
holiday-column-line = Κονδύλι
holiday-column-amount = Ποσό
holiday-column-child = Τιμή παιδιού
holiday-column-who = Για ποιους
holiday-column-span = Για πόσο διάστημα
holiday-column-cost = Κόστος
holiday-disclaimer = Μια εκτίμηση βάσει των δικών σας ποσών: οι πραγματικές τιμές μπορεί να διαφέρουν.

# --- F45 (suite) — le projet de réduction en fichier (Fabrice, 10/10/2026) --------
# « Rajoute enregistrement et chargement JSON et aussi export Excel. »
cut-file-filter = Έργο μείωσης
cut-file-not-project = Αυτό το αρχείο δεν είναι έργο μείωσης του Radinus.
cut-file-too-recent = Αυτό το έργο προέρχεται από νεότερη έκδοση του Radinus: ενημερώστε το Radinus για να το ανοίξετε.
cut-sheet-items = Κονδύλια

# --- F47 — Carnet de ma voiture (Fabrice, 10/10/2026) --------------------------------
# L'historique de la voiture : énergie, entretien, pièces, pneus, pannes, assurance, contrôle.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-car = Το βιβλιάριο του αυτοκινήτου μου
window-car-title = Το βιβλιάριο του αυτοκινήτου μου
car-unnamed = Το αυτοκίνητό μου
car-sheet-title = Το αυτοκίνητο
car-field-plate = Αριθμός κυκλοφορίας
car-field-make = Μάρκα
car-field-model = Μοντέλο
car-field-engine = Κινητήρας
car-field-first-hand = Πρώτο χέρι
car-field-registered = Πρώτη άδεια κυκλοφορίας
car-field-acquired = Ημερομηνία απόκτησης
car-field-acquired-km = Χιλιόμετρα κατά την απόκτηση
car-field-service = Σέρβις κάθε
car-field-service-or = ή κάθε
car-unit-months-short = μήνες
car-unit-km = km
car-tariff-title = Τιμολόγιο φόρτισης στο σπίτι
car-tariff-hint = Αυτό το τιμολόγιο φυλάσσεται στο βιβλιάριο του αυτοκινήτου: δεν αλλάζει εκείνο των προτιμήσεων.
car-tariff-reset = Επαναφορά του τιμολογίου των προτιμήσεων
car-engine-petrol = Βενζίνη
car-engine-diesel = Diesel
car-engine-lpg = Υγραέριο (LPG)
car-engine-e85 = E85 (βιοαιθανόλη)
car-engine-hybrid = Υβριδικό
car-engine-plug-in = Plug-in υβριδικό
car-engine-electric = Ηλεκτρικό
car-engine-hydrogen = Υδρογόνο
car-energy-petrol = Βενζίνη
car-energy-diesel = Πετρέλαιο κίνησης
car-energy-lpg = Υγραέριο
car-energy-e85 = E85
car-energy-electricity = Ηλεκτρικό ρεύμα
car-energy-hydrogen = Υδρογόνο
car-unit-litre = L
car-unit-kwh = kWh
car-unit-kg = kg
car-rubric-energy = Ενέργεια
car-rubric-upkeep = Τρέχουσα συντήρηση
car-rubric-service = Σέρβις
car-rubric-wear = Αναλώσιμα ανταλλακτικά
car-rubric-tyres = Ελαστικά
car-rubric-breakdown = Βλάβες
car-rubric-insurance = Ασφάλιση
car-rubric-inspection = Τεχνικός έλεγχος (ΚΤΕΟ)
car-part-brake-pads = Τακάκια φρένων
car-part-brake-discs = Δισκόπλακες φρένων
car-part-timing-belt = Ιμάντας χρονισμού
car-part-clutch = Συμπλέκτης
car-part-battery-12v = Μπαταρία 12 V
car-part-shock-absorbers = Αμορτισέρ
car-part-wipers = Υαλοκαθαριστήρες
car-part-spark-plugs = Μπουζί
car-part-glow-plugs = Προθερμαντήρες
car-part-particulate-filter = Φίλτρο σωματιδίων
car-part-catalytic-converter = Καταλύτης
car-part-fuel-cell-filter = Φίλτρο κυψέλης καυσίμου
car-part-exhaust = Εξάτμιση
car-part-other = Άλλο ανταλλακτικό…
car-axle-all = Και τα τέσσερα ελαστικά
car-axle-front = Εμπρός ελαστικά
car-axle-rear = Πίσω ελαστικά
car-verdict-pass = Επιτυχής
car-verdict-counter = Επανέλεγχος
car-charge-station = Σε σταθμό φόρτισης
car-charge-home = Στο σπίτι
car-slot-peak = Ώρες αιχμής
car-slot-off-peak = Ώρες εκτός αιχμής
car-entry-new = Νέα γραμμή
car-entry-edit = Τροποποίηση της γραμμής
car-field-date = Ημερομηνία
car-field-km = Χιλιομετρητής
car-field-rubric = Ενότητα
car-field-amount = Ποσό
car-field-garage = Συνεργείο ή πρατήριο
car-field-note = Σημείωση
car-field-energy = Ενέργεια
car-field-quantity = Ποσότητα
car-field-charge = Φόρτιση
car-field-slot = Ώρα φόρτισης
car-field-part = Ανταλλακτικό
car-field-part-name = Όνομα του ανταλλακτικού
car-field-axle = Ελαστικά που άλλαξαν
car-field-verdict = Αποτέλεσμα
car-field-months = Μήνες κάλυψης
car-field-battery = Κατάσταση μπαταρίας
car-home-amount-hint = Το ποσό μιας φόρτισης στο σπίτι υπολογίζεται με το τιμολόγιο του αυτοκινήτου.
car-entry-add = Προσθήκη στο βιβλιάριο
car-entry-update = Αποθήκευση της γραμμής
car-entry-cancel = Ακύρωση
car-entry-delete = Διαγραφή της γραμμής
car-delete-question = Διαγραφή αυτής της γραμμής από το βιβλιάριο;
car-from-operation = Λήψη από κίνηση…
car-pick-account = Από ποιον λογαριασμό προέρχεται η δαπάνη;
car-pick-operation = Ποια κίνηση;
car-pick-take = Λήψη
car-pick-none = Καμία δαπάνη σε αυτόν τον λογαριασμό.
car-pick-taken = Η κίνηση μεταφέρθηκε: συμπληρώστε τον χιλιομετρητή και την ενότητα και, στη συνέχεια, προσθέστε τη γραμμή.
car-history-title = Το ιστορικό
car-filter-all = Όλες οι ενότητες
car-history-empty = Καμία γραμμή προς το παρόν.
car-history-hint = Κάντε κλικ σε μια γραμμή για να την τροποποιήσετε.
car-column-date = Ημερομηνία
car-column-km = Km
car-column-rubric = Ενότητα
car-column-detail = Λεπτομέρεια
car-column-amount = Ποσό
car-column-garage = Συνεργείο
car-column-note = Σημείωση
car-column-share = Μερίδιο
car-column-per-km = Ανά km
car-column-energy = Ενέργεια
car-column-quantity = Ποσότητα
car-column-price = Μέση τιμή
car-column-consumption = Κατανάλωση
car-column-part = Ανταλλακτικό
car-column-changes = Αλλαγές
car-column-last = Τελευταία αλλαγή
car-column-life = Διάρκεια ζωής
car-column-next = Επόμενη αλλαγή
car-total = Σύνολο
car-summary-title = Τι κοστίζει το αυτοκίνητο
car-headline-empty = Συμπληρώστε την καρτέλα και, στη συνέχεια, προσθέστε μια πρώτη γραμμή: ένα γέμισμα, ένα σέρβις, έναν λογαριασμό συνεργείου…
car-headline = Από τις { $since }, το αυτοκίνητό σας σάς κόστισε { $total }.
car-headline-km = Από τις { $since }, το αυτοκίνητό σας σάς κόστισε { $total } για διανυθείσα απόσταση { $km }: { $cost } ανά χιλιόμετρο.
car-tile-total = Συνολικό κόστος
car-tile-month = Ανά μήνα
car-tile-km = Ανά χιλιόμετρο
car-tile-driven = Διανυθέντα χιλιόμετρα
car-tile-consumption = Κατανάλωση
car-tile-energy-km = Ενέργεια ανά χιλιόμετρο
car-km = { $value } km
car-quantity = { $value } { $unit }
car-per-100 = { $value } { $unit } / 100 km
car-per-unit = { $price } / { $unit }
car-months = { $months ->
        [one] { $months } μήνας
       *[other] { $months } μήνες
    }
car-detail-battery = Μπαταρία: { $value } %
car-battery-line = { $when }: { $value } %
car-rubrics-title = Ανά ενότητα
car-energy-title = Η ενέργεια
car-parts-title = Αναλώσιμα ανταλλακτικά
car-tyres-title = Ελαστικά
car-battery-title = Κατάσταση μπαταρίας
car-years-title = Τι κόστισε το αυτοκίνητο κάθε χρόνο
car-donut-title = Πού πηγαίνουν τα χρήματα
car-donut-caption = συνολικά
car-deadlines-title = Οι προθεσμίες
car-deadlines-empty = Καμία προθεσμία προς το παρόν: σημειώστε ένα σέρβις, έναν τεχνικό έλεγχο, μια ασφάλιση ή δύο αλλαγές του ίδιου ανταλλακτικού.
car-deadline-service = Σέρβις
car-deadline-inspection = Τεχνικός έλεγχος ΚΤΕΟ
car-deadline-counter = Επανέλεγχος ΚΤΕΟ
car-deadline-insurance = Λήξη της ασφάλισης
car-when-date = στις { $date }
car-when-km = στα { $km }
car-when-km-reached = στα { $km }, με τον ρυθμό σας κατά προσέγγιση: { $month }
car-when-date-km = στις { $date } ή στα { $km }, όποιο έρθει πρώτο
car-when-inspection-unknown = Σημειώστε τον τελευταίο τεχνικό έλεγχο για να μάθετε την ημερομηνία του επόμενου.
car-tone-late = Εκπρόθεσμη
car-tone-soon = Σύντομα
car-note-since = Όλα μετρούν από την απόκτηση: την ημερομηνία και τα χιλιόμετρα που σημειώθηκαν στην καρτέλα.
car-note-consumption = Η κατανάλωση μετριέται από γέμισμα σε γέμισμα: γεμίζετε πάντα το ρεζερβουάρ εντελώς και σημειώνετε κάθε φορά τον χιλιομετρητή.
car-note-e85 = Ένα αυτοκίνητο E85 καίει ό,τι του βάζετε: τα χιλιόμετρα μετά από ένα γέμισμα μετρούν για το καύσιμο εκείνου του γεμίσματος.
car-note-home = Μια φόρτιση στο σπίτι κοστολογείται με το τιμολόγιο του αυτοκινήτου την ημέρα που σημειώνεται και διατηρεί αυτό το κόστος.
car-note-inspection = Ο τεχνικός έλεγχος ακολουθεί τον γαλλικό κανόνα: ο πρώτος εντός τεσσάρων ετών από την πρώτη άδεια κυκλοφορίας, έπειτα κάθε δύο χρόνια· ένας επανέλεγχος, εντός δύο μηνών.
car-disclaimer = Οι προθεσμίες και οι διάρκειες ζωής είναι εκτιμήσεις που βγαίνουν από το βιβλιάριο: μόνο το βιβλίο σέρβις του κατασκευαστή είναι δεσμευτικό.
car-invalid-date = Μια έγκυρη ημερομηνία, που να μην είναι στο μέλλον, παρακαλώ.
car-invalid-acquired = Η ημερομηνία απόκτησης δεν μπορεί να προηγείται της πρώτης άδειας κυκλοφορίας.
car-invalid-km = Μια ένδειξη χιλιομετρητή σε ακέραια χιλιόμετρα, παρακαλώ.
car-invalid-amount = Αυτό το ποσό δεν είναι αναγνώσιμο.
car-invalid-quantity = Πληκτρολογήστε την ποσότητα: λίτρα, kWh ή κιλά.
car-invalid-part = Επιλέξτε το ανταλλακτικό που άλλαξε ή πληκτρολογήστε το όνομά του.
car-invalid-rubric = Επιλέξτε μια ενότητα.
car-invalid-months = Έναν ακέραιο αριθμό μηνών, παρακαλώ.
car-invalid-battery = Μια κατάσταση μπαταρίας από 0 έως 100 %, παρακαλώ.
car-open = Άνοιγμα βιβλιαρίου…
car-save = Αποθήκευση του βιβλιαρίου…
car-report-button = Φάκελος PDF
car-file-filter = Βιβλιάριο αυτοκινήτου
car-file-saved = Το βιβλιάριο αποθηκεύτηκε: { $file }
car-file-opened = Το βιβλιάριο άνοιξε: { $file }
car-file-not-logbook = Αυτό το αρχείο δεν είναι βιβλιάριο αυτοκινήτου του Radinus.
car-file-too-recent = Αυτό το βιβλιάριο προέρχεται από νεότερη έκδοση του Radinus: ενημερώστε το Radinus για να το ανοίξετε.
car-replace-question = Το άνοιγμα αυτού του βιβλιαρίου θα αντικαταστήσει εκείνο του παραθύρου. Συνέχεια;
car-sheet-history = Βιβλιάριο
car-sheet-summary = Σύνοψη

analysis-history-hint = Όσο μεγαλύτερο είναι το ιστορικό σας, τόσο καλύτερη θα είναι αυτή η ανάλυση: ιδανικά, χρειάζεστε τουλάχιστον έναν χρόνο κινήσεων.

# --- F48 — Μοιρασμός δαπάνης (Fabrice, 11/10/2026, P-71) ---
menu-tools-sharing = Μοιρασμός δαπάνης
window-sharing-title = Μοιρασμός δαπάνης
sharing-question = Ποιος πληρώνει τι;
sharing-setup-title = Ο μοιρασμός
sharing-field-label = Τίτλος
sharing-label-hint = Για παράδειγμα «Εστιατόριο 12/10» ή «Ταξίδι στη Βρετάνη 2027»: δίνει το όνομα στα αρχεία και στις αναφορές.
sharing-field-total = Σύνολο
sharing-total-hint = Αν μείνει κενό, το σύνολο είναι το άθροισμα των ειδών και των προσωπικών έξτρα του καθενός.
sharing-field-rule = Κανόνας
sharing-field-rounding = Στρογγυλοποίηση
sharing-field-people = Άτομα
sharing-mode-whole = Ένας κανόνας για όλη τη δαπάνη
sharing-mode-item = Ένας κανόνας ανά είδος
sharing-rule-equal = Ίσα μερίδια
sharing-rule-parts = Ανά μερίδια
sharing-rule-percent = Σε ποσοστά
sharing-rule-income = Ανάλογα με τα εισοδήματα
sharing-rounding-cent = Στο λεπτό
sharing-rounding-euro = Στη μονάδα
sharing-round-euro = Στρογγυλοποίηση στη μονάδα
sharing-hide-incomes = Απόκρυψη των εισοδημάτων στις αναφορές και στην εξαγωγή
sharing-people-title = Τα άτομα
sharing-people-hint = Μία γραμμή ανά άτομο, μία στήλη ανά είδος: επιλέξτε ποιος συμμετέχει σε τι. Όλα τα υπόλοιπα είναι προαιρετικά. Κάποιος που αποχωρεί αφήνοντας την προκαταβολή του: ένα ακριβές ποσό ίσο με όσο έχει καταβάλει και κανένα τετραγωνάκι επιλεγμένο.
sharing-add-person = Προσθήκη ατόμου
sharing-person-default = Άτομο { $number }
sharing-items-title = Τα είδη
sharing-items-hint = Μόνο ό,τι δεν αφορά όλους, όπως το κρασί. Το υπόλοιπο του συνόλου πηγαίνει στο κοινό είδος.
sharing-add-item = Προσθήκη είδους
sharing-common = Κοινό
sharing-payments-title = Οι πληρωμές
sharing-payments-hint = Ποιος πλήρωσε, πόσο και πότε. Μια γραμμή χωρίς ποσό δεν υπολογίζεται ακόμη.
sharing-payments-none = Καμία πληρωμή προς το παρόν.
sharing-add-payment = Προσθήκη πληρωμής
sharing-result-title = Το αποτέλεσμα
sharing-balances-title = Πού βρίσκονται οι πληρωμές
sharing-transfers-title = Προτεινόμενες μεταφορές
sharing-delete = Διαγραφή
sharing-delete-person-question = Αυτό το άτομο έχει πληρωμές: να διαγραφούν μαζί του;
sharing-disclaimer = Το Radinus προτείνει έναν μοιρασμό: μεταξύ φίλων, ο καθένας είναι ελεύθερος να τακτοποιηθεί διαφορετικά.
sharing-column-person = Άτομο
sharing-column-household = Νοικοκυριό
sharing-column-income = Εισόδημα
sharing-column-parts = Μερίδια
sharing-column-percent = %
sharing-column-floor = Τουλάχιστον
sharing-column-cap = Το πολύ
sharing-column-fixed = Ακριβές ποσό
sharing-column-alone = Προσωπικά έξτρα
sharing-column-gift = Πλεόνασμα που προσφέρθηκε
sharing-column-share = Μερίδιο
sharing-column-typed = % που δόθηκε
sharing-column-constraint = Τι ίσχυσε
sharing-column-due = Πληρωτέο
sharing-column-item = Είδος
sharing-column-amount = Ποσό
sharing-column-rule = Κανόνας
sharing-column-participants = Συμμετέχοντες
sharing-column-unit = Νοικοκυριό ή άτομο
sharing-column-members = Μέλη
sharing-column-paid = Πληρωμένο
sharing-column-balance = Υπόλοιπο
sharing-column-date = Ημερομηνία
sharing-column-who = Ποιος
sharing-column-label = Τίτλος
sharing-help-household = Τα άτομα του ίδιου νοικοκυριού πληρώνουν μαζί: οι πληρωμές και τα ποσά που οφείλουν αθροίζονται και παίρνουν μία κοινή κατάσταση. Παράδειγμα: «Οικογένεια Μαρτίν» για τους γονείς και τα παιδιά.
sharing-help-income = Χρησιμοποιείται μόνο από τον κανόνα «Ανάλογα με τα εισοδήματα»: όσο μεγαλύτερο το εισόδημα, τόσο μεγαλύτερο το μερίδιο. Πληκτρολογήστε το μηνιαίο εισόδημα.
sharing-help-parts = Ένα άτομο με 2 μερίδια πληρώνει διπλάσια από ένα άτομο με 1 μερίδιο. Παράδειγμα: ενήλικας 1, παιδί 0,5.
sharing-help-percent = Το μερίδιο της δαπάνης που πληρώνει το άτομο. Τα ποσοστά πρέπει να κάνουν 100 % συνολικά.
sharing-help-floor = Το άτομο θα πληρώσει τουλάχιστον αυτό το ποσό, ακόμη κι αν το υπολογισμένο μερίδιό του είναι μικρότερο. Η διαφορά ελαφρύνει τους υπόλοιπους.
sharing-help-cap = Το άτομο δεν θα πληρώσει ποτέ περισσότερο από αυτό το ποσό. Ό,τι δεν πληρώνει πέφτει στους υπόλοιπους συμμετέχοντες των ειδών του.
sharing-help-fixed = Το άτομο πληρώνει ακριβώς αυτό το ποσό, ό,τι κι αν συμβεί, και το υπόλοιπο μοιράζεται στους άλλους. Παράδειγμα: κάποιος που αποχωρεί και αφήνει την προκαταβολή του.
sharing-help-alone = Ό,τι πήρε το άτομο μόνο για τον εαυτό του, όπως ένα γλυκό ή έναν καφέ. Το πληρώνει ολόκληρο, επιπλέον του μεριδίου του.
sharing-help-gift = Αν το άτομο έχει καταβάλει περισσότερα από το μερίδιό του: όταν είναι επιλεγμένο, το πλεόνασμα προσφέρεται στην ομάδα· όταν όχι, επιστρέφεται.
sharing-help-items = Επιλέξτε τα άτομα που συμμετέχουν σε αυτό το είδος. Το Κοινό είναι ό,τι μένει από το σύνολο αφού αφαιρεθούν τα άλλα είδη.
sharing-help-due = Όσα οφείλει συνολικά το άτομο: το μερίδιό του στα είδη, τα προσωπικά έξτρα και η στρογγυλοποίηση.
sharing-help-share = Το ποσοστό του συνόλου που μοιράζεται, το οποίο αντιστοιχεί στο μερίδιο.
sharing-help-typed = Το ποσοστό που δώσατε. Μπορεί να διαφέρει από το πραγματικό μερίδιο όταν ίσχυσε ελάχιστο, μέγιστο ή ακριβές ποσό.
sharing-help-constraint = Δείχνει αν το μερίδιο του ατόμου άλλαξε λόγω ελάχιστου, μέγιστου, ακριβούς ποσού ή πλεονάσματος που προσφέρθηκε.
sharing-help-item = Μόνο ό,τι δεν αφορά όλους, όπως το κρασί. Το υπόλοιπο του συνόλου πηγαίνει στο κοινό είδος, που μοιράζεται σε όσους είναι επιλεγμένοι σε αυτό.
sharing-help-rule = Πώς μοιράζεται αυτό το είδος: ίσα μερίδια, ανά μερίδια, σε ποσοστά ή ανάλογα με τα εισοδήματα.
sharing-help-paid = Όσα έχει ήδη καταβάλει το νοικοκυριό ή το άτομο, σύμφωνα με τις πληρωμές που καταχωρίστηκαν.
sharing-help-balance = Ό,τι απομένει να πληρωθεί ή ό,τι καταβλήθηκε επιπλέον του μεριδίου. Παράδειγμα: «Απομένει να πληρωθεί: 61,54 €».
sharing-advice-equal = { $count ->
        [one] { $total } για ένα μόνο άτομο.
       *[other] { $total } ÷ { $count } άτομα = { $amount } ο καθένας.
    }
sharing-advice-equal-varied = Σε ίσα μερίδια μεταξύ όσων συμμετέχουν, λαμβάνοντας υπόψη τα όρια και τις εξαιρέσεις.
sharing-advice-parts = { $parts } μερίδια συνολικά: ένα μερίδιο αξίζει { $amount }.
sharing-advice-parts-varied = Ο καθένας πληρώνει ανάλογα με τα μερίδιά του, λαμβάνοντας υπόψη τα όρια και τις εξαιρέσεις. Ένα κενό πεδίο μετράει για 1 μερίδιο.
sharing-advice-percent-rest = Λείπουν { $rest } % μέχρι το 100 %.
sharing-advice-percent-over = Τα ποσοστά ξεπερνούν το 100 % κατά { $over } %.
sharing-advice-percent-ok = Τα ποσοστά δίνουν ακριβώς 100 %.
sharing-advice-percent-nobody = Τα ποσοστά δίνουν ήδη 100 %: { $count ->
        [one] { $names } δεν θα πλήρωνε τίποτα.
       *[other] { $names } δεν θα πλήρωναν τίποτα.
    }
sharing-advice-income = Ο καθένας πληρώνει το { $rate } % του εισοδήματός του.
sharing-advice-income-missing = Πληκτρολογήστε το εισόδημα του καθενός για να γίνει το μοίρασμα ανάλογα με τα εισοδήματα.
sharing-advice-income-varied = Ο καθένας πληρώνει το ίδιο ποσοστό του εισοδήματός του, λαμβάνοντας υπόψη τα όρια και τις εξαιρέσεις.
sharing-advice-empty = Πληκτρολογήστε το ποσό προς μοιρασμό.
sharing-apply-advice = Χρήση των προτεινόμενων τιμών
sharing-help-apply-advice = Συμπληρώνει τα κενά πεδία με τις γκρι τιμές. Τα πεδία που είναι ήδη συμπληρωμένα δεν αλλάζουν.
sharing-from-incomes = Ποσοστά από τα εισοδήματα
sharing-help-from-incomes = Αντικαθιστά τα ποσοστά με το μερίδιο κάθε εισοδήματος στο σύνολο των εισοδημάτων. Δίνουν 100 %.
sharing-reset-percents = Νέο μοίρασμα από την αρχή
sharing-help-reset-percents = Σβήνει τα ποσοστά και τα μοιράζει ισόποσα σε όλους. Χρήσιμο αφού προσθέσετε ένα άτομο.
sharing-reset-percents-question = Να σβηστούν όλα τα ποσοστά και να μοιραστούν ισόποσα;
sharing-open = Άνοιγμα έργου…
sharing-save = Αποθήκευση του έργου…
sharing-pdf-distribution = Κατανομή (PDF)
sharing-pdf-payments = Κατάσταση πληρωμών (PDF)
sharing-pdf-statements = Ατομικές καταστάσεις (PDF)…
sharing-statements-everyone = Όλοι
sharing-excel = Εξαγωγή σε Excel
sharing-file-filter = Έργο μοιρασμού
sharing-replace-question = Το άνοιγμα αυτού του έργου θα αντικαταστήσει ό,τι έχει πληκτρολογηθεί στο παράθυρο. Συνέχεια;
sharing-file-saved = Το έργο αποθηκεύτηκε: { $file }
sharing-file-opened = Το έργο άνοιξε: { $file }
sharing-file-not-project = Αυτό το αρχείο δεν είναι έργο μοιρασμού του Radinus.
sharing-file-too-recent = Αυτό το έργο προέρχεται από νεότερη έκδοση του Radinus: ενημερώστε το Radinus για να το ανοίξετε.
sharing-file-failed = Δεν ήταν δυνατή η ανάγνωση ή η εγγραφή του αρχείου: { $reason }
sharing-statements-replace-question = { $count ->
        [one] Υπάρχει ήδη μία κατάσταση σε αυτόν τον φάκελο. Να αντικατασταθεί;
       *[other] Υπάρχουν ήδη { $count } καταστάσεις σε αυτόν τον φάκελο. Να αντικατασταθούν;
    }
sharing-statements-written = { $count ->
        [one] Γράφτηκε μία κατάσταση στον φάκελο «{ $folder }».
       *[other] Γράφτηκαν { $count } καταστάσεις στον φάκελο «{ $folder }».
    }
sharing-too-many-people = Ένας μοιρασμός έχει το πολύ 40 άτομα.
sharing-too-many-items = Ένας μοιρασμός έχει το πολύ 20 είδη.
sharing-too-many-payments = Ένας μοιρασμός έχει το πολύ 400 πληρωμές.
sharing-invalid-amount = Αυτό το ποσό δεν είναι αναγνώσιμο: χρειάζεται θετικός αριθμός.
sharing-invalid-number = Αυτός ο αριθμός δεν είναι αναγνώσιμος: χρειάζεται θετικός αριθμός.
sharing-invalid-percent = Ένα ποσοστό κυμαίνεται από 0 έως 100.
sharing-invalid-date = Αυτή η ημερομηνία δεν είναι αναγνώσιμη.
sharing-name-missing = Κάθε άτομο πρέπει να έχει όνομα.
sharing-name-duplicate = Υπάρχει ήδη «{ $name }»: ξεχωρίστε τα, για παράδειγμα με ένα αρχικό γράμμα.
sharing-floor-above-cap = Το ελάχιστο υπερβαίνει το μέγιστο.
sharing-item-label-missing = Αυτό το είδος δεν έχει όνομα.
sharing-items-above-total = Τα είδη και τα προσωπικά έξτρα του καθενός υπερβαίνουν το σύνολο κατά { $amount }.
sharing-payment-person = Επιλέξτε ποιος πλήρωσε.
sharing-percent-total = Τα ποσοστά δίνουν { $sum } %: πρέπει να δίνουν 100 %.
sharing-percent-total-item = «{ $item }»: τα ποσοστά δίνουν { $sum } %: πρέπει να δίνουν 100 %.
sharing-item-nobody = Κανείς δεν συμμετέχει στο «{ $item }».
sharing-item-no-weight = Κανείς δεν συνεισφέρει στο «{ $item }»: όλοι οι συμμετέχοντες έχουν μηδέν.
sharing-income-missing = Λείπει το εισόδημα: { $name }.
sharing-fixed-above = Τα ακριβή ποσά υπερβαίνουν το προς μοιρασμό ποσό κατά { $amount }.
sharing-floors-above = Τα ελάχιστα υπερβαίνουν το προς μοιρασμό ποσό κατά { $amount }.
sharing-cap-alone = Μόνο { $name } συμμετέχει στο «{ $item }»: το μέγιστο δεν μπορεί να τηρηθεί.
sharing-caps-short = Τα μέγιστα δεν αρκούν για να καλύψουν το ποσό: λείπουν { $amount }.
sharing-impossible = Αυτοί οι όροι δεν μπορούν να τηρηθούν όλοι: χαλαρώστε ένα ελάχιστο ή ένα μέγιστο.
sharing-constraint-floor = Έφτασε το ελάχιστο
sharing-constraint-cap = Έφτασε το μέγιστο
sharing-constraint-fixed = Ακριβές ποσό
sharing-constraint-gift = Πλεόνασμα που προσφέρθηκε
sharing-and = { $first } και { $last }
sharing-outside = Εκτός ειδών
sharing-alone = Προσωπικά έξτρα
sharing-rounding = Στρογγυλοποίηση
sharing-headline-empty = Προσθέστε τα άτομα που μοιράζονται τη δαπάνη.
sharing-headline-no-amount = Πληκτρολογήστε το σύνολο ή τα είδη προς μοιρασμό.
sharing-headline-equal = { $total } προς μοιρασμό: ο καθένας πληρώνει { $amount }.
sharing-headline-range = { $total } προς μοιρασμό: από { $min } έως { $max } ανάλογα με το άτομο.
sharing-participants = { $count ->
        [0] Κανένας συμμετέχων
        [one] Ένας συμμετέχων
       *[other] { $count } συμμετέχοντες
    }
sharing-balance-due = Απομένει να πληρωθεί: { $amount }
sharing-balance-over = Έχει καταβληθεί { $amount } περισσότερο από το μερίδιο
sharing-balance-even = Τακτοποιημένο
sharing-summary-collected = Πληρώθηκαν { $collected } από { $total }.
sharing-summary-owing = { $count ->
        [0] Όλοι είναι τακτοποιημένοι.
        [one] Μόνο ένας οφείλει ακόμη { $amount }.
       *[other] { $count } οφείλουν ακόμη { $amount } συνολικά.
    }
sharing-remaining-outside = Απομένει να πληρωθεί για τη δαπάνη: { $amount }
sharing-remaining-reimburse = Επιστροφή σε { $name }: { $amount }
sharing-all-settled = Όλα έχουν τακτοποιηθεί: κανείς δεν οφείλει τίποτα σε κανέναν.
sharing-transfer = { $from } οφείλει { $amount } σε { $to }
sharing-warning-over-paid = Οι πληρωμές υπερβαίνουν τη δαπάνη κατά { $amount }: ελέγξτε τα ποσά.
sharing-note-income-zero = { $name } δεν πληρώνει τίποτα για { $items }: το εισόδημα είναι 0.
sharing-note-excluded = { $name } δεν συμμετέχει στο «{ $item }»: το μερίδιο μοιράζεται στους υπόλοιπους.
sharing-note-gift = Το πλεόνασμα που προσφέρθηκε από { $giver } μειώνει το μερίδιο των υπολοίπων: για { $name } έχουν πλέον καταβληθεί περισσότερα από το μερίδιο.
sharing-note-outside = { $name } πληρώνει { $amount } εκτός των ειδών: το ποσό αφαιρείται από όσα μοιράζονται οι υπόλοιποι.
sharing-note-keeper = Στρογγυλοποίηση στη μονάδα: { $name } κρατά τα λεπτά, ώστε το σύνολο να βγαίνει ακριβώς.
sharing-report-distribution = Κατανομή
sharing-report-sharing = Ο μοιρασμός
sharing-report-who-pays = Ποιος πληρώνει τι
sharing-report-items = Ανάλυση ανά είδος
sharing-report-payments = Κατάσταση πληρωμών
sharing-report-as-of = Κατάσταση στις { $date }
sharing-report-balances = Μερίδιο, πληρωμένο, υπόλοιπο
sharing-report-statement = Κατάσταση — { $name }
sharing-report-your-share = Το μερίδιό σας
sharing-statement-total = Σύνολο για το νοικοκυριό: { $amount }
sharing-statement-pay = Πληρωτέο σε { $name }: { $amount }
sharing-statement-receive = Εισπρακτέο από { $name }: { $amount }
sharing-sheet-people = Άτομα
sharing-sheet-items = Είδη
sharing-sheet-result = Αποτέλεσμα
sharing-sheet-payments = Πληρωμές
sharing-sheet-balances = Επιστροφές
