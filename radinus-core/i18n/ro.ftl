# Radinus — mesaje din partea core (Fluent), română.
# Completat progresiv, pe măsură ce sunt implementate modulele core care produc
# mesaje vizibile de către utilizator. A se vedea 08_ARCHITECTURE.md §2.1.

# Santinela „0 = Nespecificat” pe care o folosește orice legătură opțională de
# nomenclator (02_BASE_DE_DONNEES.md §7 regula 2). Afișată în capul fiecărui combo.
# ---------------------------------------------------------------------
# Numele limbii, scris în propria ei limbă.
#
# Este ceea ce arată meniul Setări și selectorul de la prima
# pornire (01_CAHIER_DES_CHARGES.md §3.5: „fiecare limbă scrisă în
# propria ei limbă”). Se află aici, și nu în cod, pentru că este singurul
# loc unde poate fi corect: a adăuga o limbă înseamnă a depune un
# fișier care știe să se numească.
# ---------------------------------------------------------------------
language-name = Română

nomenclature-unspecified = Nespecificat

# Întrebare pusă înainte de ștergerea unui element de nomenclator pe care
# operațiunile încă îl folosesc (02_BASE_DE_DONNEES.md §7 regula 5). Reprodusă
# cuvânt cu cuvânt din sursa WinDev originală (Enreg_Supprimer), inclusiv
# tipografia — formularea este a autorului, nu o traducere.
nomenclature-delete-confirm = Au fost detectate operațiuni (tranzacții bancare) care posedă atributul de tip '{ $label }'. Confirmați că doriți să reinițializați acest atribut?

# Întrebare pusă înainte de ștergerea unui element de nomenclator pe care nu îl
# folosește nimic. Originalul ștergea un asemenea element pe loc, fără o vorbă;
# Fabrice a cerut pe 25/07/2026 ca o ștergere să fie întotdeauna confirmată — o
# abatere asumată de la propriul său cod, și singura din acest modul.
nomenclature-delete-plain = Confirmați ștergerea „{ $label }”?

# Refuz afișat atunci când elementul pe care utilizatorul urmează să îl șteargă
# este chiar cel pe care îl arată fișa sa. Decizia lui Fabrice din 25/07/2026: un
# element nu se șterge de sub propria fișă deschisă — fișa se închide mai întâi,
# în loc să fie lăsată să arate o înregistrare care nu mai există.
nomenclature-delete-form-open = Fișa „{ $label }” este deschisă. Închideți-o înainte de a șterge.

# Refuz afișat atunci când descrierea care se salvează este deja purtată de un alt
# element al aceluiași nomenclator (decizia autorului, 25/07/2026: două elemente ale
# aceluiași nomenclator nu trebuie să aibă același nume — a clasa o operațiune sub
# una din două descrieri identice este dat cu banul). `element` este substantivul în
# genul său, „o categorie”, „un terț”; `label` este descrierea existentă, așa cum
# este stocată, pentru ca utilizatorul să vadă ce îi stă în cale.
nomenclature-duplicate = Există deja { $element } cu același nume: „{ $label }”.

# ---------------------------------------------------------------------
# Ceea ce ferestrele spun despre ele însele.
#
# Totul se află aici, inclusiv ceea ce depinde de nomenclatorul afișat: frazele
# sunt scrise în întregime, limbă cu limbă, în loc să fie fabricate prin
# asamblare de cuvinte și de genuri. O asamblare corectă în franceză este
# falsă în limba următoare, și ajunge codul să știe că există un feminin
# — nu aceasta este treaba lui (regula autorului,
# 25/07/2026: „programul funcționează cu Fluent în franceză și în
# engleză încă de la început”).
# ---------------------------------------------------------------------

ui-loading = Încărcare…
ui-editing = Modificare.
ui-viewing = Consultare.
ui-modified-suffix = — modificat
ui-label-required = Descrierea este obligatorie.
ui-discard-question = Abandonați modificările?
ui-yes = Da
ui-no = Nu
ui-select-record = Vă rugăm să selectați o înregistrare
ui-key-multiselect = CTRL
ui-multiselect-help = Info: Utilizați Clic Mouse + tasta [{ $modifier }] pe tabel pentru a selecta mai multe elemente
ui-no-match = Nicio descriere nu corespunde filtrului.
ui-filter-placeholder = Filtrați descrierile…
ui-column-label = DESCRIERE
ui-field-label = Descriere
ui-field-budget-line = Poziție bugetară
ui-identifier = Identificator
ui-deletion-abandoned = Ștergere abandonată: nu a fost modificat nimic.
ui-unknown-nomenclature = Nomenclator necunoscut:

ui-title-filter = Filtrare
ui-title-create = Creare
ui-title-update = Modificarea selecției
ui-title-delete = Ștergerea selecției
ui-title-read = Consultarea selecției
ui-title-close = Închidere
ui-title-save = Salvare
ui-title-add = Adăugare
ui-title-modify = Modificare

ui-load-failed = Încărcare imposibilă:
ui-save-failed = Salvare imposibilă:
ui-read-failed = Citire imposibilă:
ui-delete-failed = Ștergere imposibilă:
ui-open-failed = Deschidere imposibilă:
ui-close-failed = Închidere imposibilă:

# --- Fraze proprii fiecărui nomenclator ------------------------------

nomenclature-identifier = { $kind ->
    [category] Identificator de Categorie
    [assignment] Identificator de Alocare
    [payment-mode] Identificator de Modalitate de plata
    [payee] Identificator de Tert
    [project] Identificator de Proiect
    [budget-line] Identificator de Pozitie bugetara
   *[bank] Identificator de Banca
}

nomenclature-none = { $kind ->
    [category] Nicio categorie.
    [assignment] Nicio alocare.
    [payment-mode] Nicio modalitate de plată.
    [payee] Niciun terț.
    [project] Niciun proiect.
    [budget-line] Nicio poziție bugetară.
   *[bank] Nicio bancă.
}

nomenclature-nothing-to-show = { $kind ->
    [category] Nicio categorie de afișat.
    [assignment] Nicio alocare de afișat.
    [payment-mode] Nicio modalitate de plată de afișat.
    [payee] Niciun terț de afișat.
    [project] Niciun proiect de afișat.
    [budget-line] Nicio poziție bugetară de afișat.
   *[bank] Nicio bancă de afișat.
}

nomenclature-gone = { $kind ->
    [category] Această categorie nu mai există.
    [assignment] Această alocare nu mai există.
    [payment-mode] Această modalitate de plată nu mai există.
    [payee] Acest terț nu mai există.
    [project] Acest proiect nu mai există.
    [budget-line] Această poziție bugetară nu mai există.
   *[bank] Această bancă nu mai există.
}

nomenclature-fresh = { $kind ->
    [category] Categorie nouă.
    [assignment] Alocare nouă.
    [payment-mode] Modalitate de plată nouă.
    [payee] Terț nou.
    [project] Proiect nou.
    [budget-line] Poziție bugetară nouă.
   *[bank] Bancă nouă.
}

nomenclature-created = { $kind ->
    [category] Categorie adăugată.
    [assignment] Alocare adăugată.
    [payment-mode] Modalitate de plată adăugată.
    [payee] Terț adăugat.
    [project] Proiect adăugat.
    [budget-line] Poziție bugetară adăugată.
   *[bank] Bancă adăugată.
}

nomenclature-updated = { $kind ->
    [category] Categorie modificată.
    [assignment] Alocare modificată.
    [payment-mode] Modalitate de plată modificată.
    [payee] Terț modificat.
    [project] Proiect modificat.
    [budget-line] Poziție bugetară modificată.
   *[bank] Bancă modificată.
}

nomenclature-deleted = { $kind ->
    [category] { $count ->
        [one] O categorie ștearsă.
        [few] { $count } categorii șterse.
       *[other] { $count } de categorii șterse.
      }
    [assignment] { $count ->
        [one] O alocare ștearsă.
        [few] { $count } alocări șterse.
       *[other] { $count } de alocări șterse.
      }
    [payment-mode] { $count ->
        [one] O modalitate de plată ștearsă.
        [few] { $count } modalități de plată șterse.
       *[other] { $count } de modalități de plată șterse.
      }
    [payee] { $count ->
        [one] Un terț șters.
        [few] { $count } terți șterși.
       *[other] { $count } de terți șterși.
      }
    [project] { $count ->
        [one] Un proiect șters.
        [few] { $count } proiecte șterse.
       *[other] { $count } de proiecte șterse.
      }
    [budget-line] { $count ->
        [one] O poziție bugetară ștearsă.
        [few] { $count } poziții bugetare șterse.
       *[other] { $count } de poziții bugetare șterse.
      }
   *[bank] { $count ->
        [one] O bancă ștearsă.
        [few] { $count } bănci șterse.
       *[other] { $count } de bănci șterse.
      }
}

nomenclature-duplicate-name = { $kind ->
    [category] Există deja o categorie cu același nume: „{ $label }”.
    [assignment] Există deja o alocare cu același nume: „{ $label }”.
    [payment-mode] Există deja o modalitate de plată cu același nume: „{ $label }”.
    [payee] Există deja un terț cu același nume: „{ $label }”.
    [project] Există deja un proiect cu același nume: „{ $label }”.
    [budget-line] Există deja o poziție bugetară cu același nume: „{ $label }”.
   *[bank] Există deja o bancă cu același nume: „{ $label }”.
}

# --- Titluri de ferestre, fara diacritice ca pe ferestrele originale --

window-list-title = { $kind ->
    [category] Lista categoriilor
    [assignment] Lista alocarilor
    [payment-mode] Lista modalitatilor de plata
    [payee] Lista tertilor si comerciantilor
    [project] Lista proiectelor
    [budget-line] Lista pozitiilor bugetare
   *[bank] Lista bancilor
}

window-form-title = { $kind ->
    [category] Fisa categorie
    [assignment] Fisa alocare
    [payment-mode] Fisa modalitate de plata
    [payee] Fisa tert
    [project] Fisa proiect
    [budget-line] Fisa pozitie bugetara
   *[bank] Fisa banca
}

# --- Bara de meniuri (01_CAHIER_DES_CHARGES.md §6) --------------------

menu-file = Fișier
menu-file-import-statements = Import de extrase de cont bancar
menu-file-import-excel = Import de fișier Excel
menu-file-backup = Copie de siguranță
menu-file-restore = Restaurare
menu-file-repair = Reparare și optimizare a bazei de date
menu-file-log = Afișare jurnal
menu-tools-password = Protejați baza de date cu o parolă
menu-file-disconnect = Deconectare de la baza curentă
menu-file-quit = Ieșire

menu-accounts = Conturi
menu-accounts-manage = Gestionarea conturilor bancare
menu-accounts-balances = Vizualizarea soldurilor conturilor dumneavoastră
menu-accounts-operations = Gestionarea operațiunilor unui cont
menu-accounts-quick-classify = Clasificarea rapidă a operațiunilor
menu-accounts-recurring = Gestionarea operațiunilor periodice
menu-accounts-transfer = Transferul unei sume între două conturi
menu-accounts-checkbooks = Gestionarea carnetelor de cecuri

menu-statistics = Statistici
menu-statistics-balance-chart = Grafic Evoluția soldului
menu-statistics-balance-analysis = Analiză Evoluția soldului
menu-statistics-by-category = Stat pe categorii
menu-statistics-by-assignment = Stat pe alocări
menu-statistics-by-budget-line = Stat pe poziții bugetare
menu-statistics-by-payment-mode = Stat pe modalități de plată
menu-statistics-by-payee = Stat pe terți și comercianți
menu-statistics-by-project = Stat pe proiecte
menu-statistics-by-verification = Stat pe verificări
menu-statistics-dashboard = Tablou de bord al operațiunilor
menu-statistics-crossed-balance = Bilanț încrucișat

menu-budget = Buget
menu-budget-entry = Introducere buget
menu-budget-control = Control buget

menu-nomenclatures = Nomenclatoare
menu-nomenclature = { $kind ->
    [category] Categorii
    [assignment] Alocări
    [payment-mode] Moduri operațiune
    [payee] Terți și comercianți
    [project] Proiecte
    [budget-line] Poziții Bugetare
   *[bank] Bănci
}
menu-nomenclatures-templates = Șabloane de operațiuni

# Le menu Outils (Fabrice, 09/10/2026), entre Nomenclatures et Paramètres.
menu-tools = Instrumente
menu-settings = Setări
menu-settings-about-author = Despre autor
menu-settings-about-radinus = Despre Radinus
menu-settings-licence = Licență de utilizare

menu-misc = Diverse
menu-misc-calculator = Calculator
menu-misc-website = Accesarea site-ului Radinus
menu-misc-database-folder = Acces la folderul care conține baza de date

# L'avertissement posé devant ce dossier (Fabrice, 08/08/2026) : « un
# utilisateur ignorant peut faire des bêtises ». La question est posée
# avant l'ouverture, jamais après.
database-folder-warning-title = Deschiderea dosarului bazei de date
database-folder-warning =
    Acest dosar conține toate datele dumneavoastră. Redenumirea, mutarea sau ștergerea unui fișier vă poate pierde conturile, le poate deteriora sau poate împiedica Radinus să funcționeze.
    Doriți într-adevăr să îl deschideți?
menu-misc-application-folder = Acces la folderul care conține aplicația
menu-misc-attachments-folder = Acces la dosarul care conține atașamentele
# --- « Gestion des pièces jointes » (08/08/2026) -------------------------
#
# La fenêtre montre les pièces de toutes les opérations, plus les fichiers
# du dossier que la base ne réclame pas. Les cinq états ne sont pas trois :
# un fichier disparu, un fichier modifié et un fichier qu'on ne sait pas
# juger ne se traitent pas de la même façon.
menu-settings-attachments = Gestionarea atașamentelor
window-attachments-manager-title = Gestionarea atașamentelor
attachments-column-document = Document
attachments-column-size = Mărime
attachments-column-added = Adăugat la
attachments-column-state = Stare
attachments-state-intact = Intact
attachments-state-altered = Modificat între timp
attachments-state-missing = Fișier lipsă
attachments-state-unknown = Neverificabil
attachments-state-orphan = Orfan
attachments-no-operation = Nicio operațiune
attachments-orphan-remove-question = Acest fișier nu este legat de nicio operațiune. Îl trimiteți la coșul de gunoi?
attachments-manager-help = Faceți dublu clic pe o linie pentru a deschide documentul.

# Les deux entrées du clic droit. « Afficher l'opération » n'apparaît pas
# sur un orphelin — il n'appartient à aucune opération — et « Révéler »
# disparaît quand le fichier n'est plus sur le disque.
attachments-show-operation = Afișați operațiunea
attachments-reveal = Afișați în managerul de fișiere
attachments-manager-summary = { $count } atașamente, { $size } în total.
attachments-disk-name = Nume pe disc: { $name }

# L'avertissement du dossier des pièces jointes (Fabrice, 08/08/2026).
# Le danger n'y est pas le même que pour la base : on ne perd pas des
# comptes, on casse un lien — l'opération annonce une pièce qui ne
# s'ouvre plus. C'est ce que dit la phrase, plutôt que « ne faites pas
# n'importe quoi ».
attachments-folder-warning-title = Deschiderea dosarului atașamentelor
attachments-folder-warning =
    Acest dosar conține fișierele pe care le-ați atașat operațiunilor dumneavoastră. Radinus le păstrează sub un nume ales de el: redenumirea, mutarea sau ștergerea unui fișier nu îl desprinde de operațiune, care va continua să îl anunțe fără ca el să se mai deschidă.
    Doriți într-adevăr să îl deschideți?

# ---------------------------------------------------------------------
# Conturi bancare — F04, F06, F07, F08.
# Greșelile de tipar din versiunea 1.9.3 („Bank Identifer Code”, „Solde
# initial prevu”, „Est Cloturé”, spațiul dinaintea parantezei IBAN-ului)
# sunt corectate: decizia lui Fabrice din 25/07/2026.
# ---------------------------------------------------------------------

window-accounts-title = Gestionarea conturilor bancare
window-accounts-select-title = Lista conturilor
window-balances-title = Soldurile conturilor dumneavoastră
window-account-title = Fișă cont

accounts-none = Niciun cont.
accounts-nothing-to-show = Niciun cont de afișat.
accounts-gone = Acest cont nu mai există.
accounts-fresh = Cont nou.
accounts-created = Cont adăugat.
accounts-updated = Cont modificat.
accounts-deleted = { $count ->
    [one] Un cont șters.
    [few] { $count } conturi șterse.
   *[other] { $count } de conturi șterse.
}
accounts-duplicate-name = Există deja un cont cu același nume: „{ $label }”.
accounts-multiselect-help = Info: Utilizați clic de mouse + tasta [{ $modifier }] pe tabel pentru a selecta mai multe conturi
accounts-select-question = Pe ce conturi bancare trebuie să se bazeze statisticile?

accounts-column-label = DESCRIERE
accounts-column-bank = Bancă
accounts-column-type = Tip cont
accounts-column-number = Nr. cont
accounts-column-account = Cont
accounts-column-bank-balance = În Bancă
accounts-column-real-balance = Real
accounts-column-final-balance = Final
accounts-total = TOTAL

# Ștergerea unui cont atrage după sine ștergerea operațiunilor sale: este
# singurul loc din program unde o ștergere distruge istoric.
accounts-delete-plain = Confirmați ștergerea contului „{ $label }”?
accounts-delete-with-operations = Contul „{ $label }” conține un număr de { $count } operațiuni, care vor fi șterse odată cu el. Confirmați ștergerea?
accounts-delete-form-open = Fișa contului „{ $label }” este deschisă. Închideți-o înainte de ștergere.

account-group-bank = Informații cont și bancă
account-group-holder = Titular
account-group-rib = Coordonate bancare (RIB)
account-group-activity = Activitate
account-group-balances = Solduri

account-field-label = Denumirea contului
account-field-bank = Bancă
account-field-type = Tip cont
account-field-branch-address = Adresa agenției bancare
account-field-holder-name = Nume
account-field-holder-address = Adresă
account-field-rib-bank = Cod bancă
account-field-rib-branch = Cod ghișeu
account-field-rib-number = Număr cont
account-field-rib-key = Cheie RIB
account-field-bic = BIC (Bank Identifier Code)
account-field-iban = IBAN (International Bank Account Number)
account-field-opening-date = Data deschiderii
account-field-closing-date = Data închiderii
account-field-closed = Este închis
account-field-opening-pointed = Sold inițial reconciliat
account-field-opening-committed = Sold inițial angajat
account-field-opening-planned = Sold inițial planificat

account-label-required = Denumirea contului este obligatorie.
account-iban-invalid = Acest IBAN nu este valid: verificați cheia de control.
# Rândul albastru din josul fișei, cuvânt cu cuvânt cel din 1.9.3 — doar
# sumele urmează de acum formatul francez al celorlalte câmpuri.
account-control-line = Sold inițial reconciliat ({ $opening }) + Totalul operațiunilor ({ $operations }) = Sold bancar actual: { $balance }.

amount-not-readable = „{ $field }” nu conține o sumă validă.

ui-thousands-separator = .
ui-decimal-separator = ,

# --- Lista operațiunilor (F02) ---------------------------------------

window-operations-title = Lista operațiunilor contului: { $account }

operations-none = Nicio operațiune în această perioadă.
operations-bad-period = Limitele perioadei nu sunt date valide.
operations-from = Data început
operations-to = Data sfârșit
operations-delete-confirm = { $count ->
    [one] Confirmați ștergerea acestei operațiuni?
    [few] Confirmați ștergerea acestor { $count } rânduri? Suboperațiunile operațiunilor selectate pleacă odată cu ele.
   *[other] Confirmați ștergerea acestor { $count } de rânduri? Suboperațiunile operațiunilor selectate pleacă odată cu ele.
}
operations-deleted = { $count ->
    [one] O operațiune ștearsă.
    [few] { $count } operațiuni șterse.
   *[other] { $count } de operațiuni șterse.
}
operations-selection-total = Suma totală a operațiunilor selectate: { $amount }

operations-column-date = Data
operations-column-clearing-date = Data Reconciliere
operations-column-status = Statut operațiune
operation-status-pointed = Reconciliat
operation-status-committed = Angajat
operation-status-planned = Planificat
operations-column-verification = Verificare
operation-verification-to-verify = De verificat
operation-verification-verified = Verificată
operation-verification-doubtful = Îndoielnică
operation-verification-disputed = Contestată
operations-column-label = Descriere
operations-column-reference = Referință plată
operations-column-category = Categorie
operations-column-assignment = Alocare
operations-column-payment-mode = ModOp
operations-column-payee = Terți
operations-column-project = Proiecte
operations-column-month = Luna
operations-column-debit = Debit
operations-column-credit = Credit
operations-column-balance = Sold
operations-column-comments = Comentarii
operations-column-attachments = Atașamente
operations-column-check = Nr. Cec

operations-foot-debit = Debit:
operations-foot-credit = Credit:
operations-foot-total = Total:
operations-foot-bank = Sold bancar:
operations-foot-real = Sold real:
operations-foot-final = Sold final:

operations-menu-export = Export
operations-menu-print = Tipărire
operations-menu-filter = Filtru
operations-menu-period = Perioadă
operations-menu-misc = Diverse

operations-title-point = Reconcilierea selecției
operations-title-sub = Adăugarea unei suboperațiuni
operations-title-duplicate = Duplicarea selecției
operations-not-yet = Această fereastră nu există încă: vine mai departe în plan.

accounts-choose-question = Pe ce cont doriți să lucrați?
ui-title-select = Alegerea selecției

month-january = ianuarie
month-february = februarie
month-march = martie
month-april = aprilie
month-may = mai
month-june = iunie
month-july = iulie
month-august = august
month-september = septembrie
month-october = octombrie
month-november = noiembrie
month-december = decembrie

operations-period-year = Anul curent

# --- Meniul Perioadă din F02 -----------------------------------------
# Nouă intrări, dintre care două deschid un submeniu al celor douăsprezece luni.
# Fiecare nu face decât un singur lucru: să deducă din el o dată de început și o
# dată de sfârșit, pe care fereastra le pune în cele două câmpuri ale sale
# (cerere a lui Fabrice, 25/07/2026).

period-all = Toate
period-last-year = Anul Trecut
period-this-year = Anul Actual
period-whole-year = Tot anul
period-last-month = Luna Trecută
period-this-month = Luna Curentă
period-last-week = Săptămâna Trecută
period-this-week = Săptămâna Actuală
period-yesterday = Ieri
period-today = Astăzi

# --- Meniul Filtru din F02 --------------------------------------------
# Filtrează rândurile după natura operațiunii (cerere a lui Fabrice,
# 25/07/2026). Cele trei statute sunt cele din baza de date: 1 reconciliat,
# 2 angajat, 3 planificat (02_BASE_DE_DONNEES.md §5.2).

filter-all = Toate operațiunile
filter-pointed = Numai operațiunile reconciliate
filter-committed = Numai operațiunile angajate
filter-planned = Numai operațiunile planificate
filter-by-status = Filtru după statut
filter-by-verification = Filtru după verificare
filter-show-all = Afișează tot

# --- Fișa operațiunii (F03) -------------------------------------------
# Titlurile sunt cele din captura „Fiche operation transaction.png”, cu
# greșelile de tipar ale originalului corectate (aprobare de la Fabrice,
# 25/07/2026: „les coquilles tu les corriges”): „Libelle” devine „Libellé”,
# „Categorie” devine „Catégorie”, „Statut Operation” devine
# „Statut opération”.

window-operation-title = Operațiune Cont: { $account }

operation-menu-identification = Identificare
operation-menu-options = Opțiuni
operation-fitid-edit = Modificarea identificatorului FITID…
operation-fitid-delete = Ștergerea identificatorului FITID
operation-fitid-question = Identificatorul FITID al acestei tranzacții:
operation-fitid-delete-question = Ștergeți identificatorul FITID al acestei tranzacții?
operation-fitid-written = Identificator FITID salvat.
operation-fitid-removed = Identificator FITID șters.

operation-group-identification = Identificarea operațiunii
operation-group-amount = Suma operațiunii
operation-group-status = Statutul operațiunii
operation-group-classification = Clasificarea operațiunii pentru calculul statisticilor
operation-group-check = Cecul în legătură cu operațiunea
operation-group-comment = Comentariu

operation-field-label = Descriere
operation-field-reference = Referință plată
operation-field-date = Data
operation-field-direction = Tip Operațiune:
operation-field-amount = Sumă
operation-field-status = Statut operațiune
operation-field-clearing-date = Data reconcilierii
operation-field-verification = Verificare
operation-field-category = Categorie
operation-field-assignment = Alocare
operation-field-payment-mode = Mod
operation-field-payee = Terț
operation-field-project = Proiect
operation-field-check = Asociere cu cec

operation-direction-debit = Debit
operation-direction-credit = Credit

operation-check-info = Info.
operation-check-link = Asociere
operation-check-unlink = Ștergere

operation-fresh = Operațiune nouă.
operation-created = Operațiune adăugată.
operation-updated = Operațiune modificată.
operation-gone = Această operațiune nu mai există.
operation-nothing-to-show = Nicio operațiune de afișat.
operation-label-required = Descrierea operațiunii este obligatorie.
operation-date-required = Data operațiunii este obligatorie.
operation-clearing-date-invalid = Data reconcilierii nu este o dată validă.
operation-clearing-date-required = O operațiune punctată trebuie să aibă obligatoriu o dată de punctare.
operation-clearing-date-question =
    O operațiune punctată trebuie să aibă obligatoriu o dată de punctare.
    Doriți să înregistrați cu data operațiunii, { $date }?
operation-is-a-sub = Acest rând este o suboperațiune: se modifică din fișa ei proprie.
operation-delete-form-open = Fișa „{ $label }” este deschisă. Închideți-o înainte de ștergere.

operation-attachments = { $count ->
    [0] Niciun atașament
    [one] Un atașament
    [few] { $count } atașamente
   *[other] { $count } de atașamente
}

operation-title-comment = Comentariul operațiunii
operation-title-sub = Creare suboperațiune
operation-title-template = Șabloane de operațiune
operation-title-attachment = Atașamente

# --- Fișa suboperațiunii (F04) ----------------------------------------
# Versiune redusă a F03: fără Mod, fără Statut, fără Dată — o suboperațiune
# le preia de la operațiunea-mamă (`Maj_ProprieteSousOp`, confirmat de
# Fabrice pe 26/07/2026: „într-o suboperațiune, fiind complementul, nu se
# poate atinge modalitatea de plată, ar fi ilogic”).

window-sub-operation-title = Fișă Suboperațiune

sub-operation-group-amount = Suma suboperațiunii
sub-operation-field-label = Nume
sub-operation-fresh = Suboperațiune nouă.
sub-operation-created = Suboperațiune adăugată.
sub-operation-updated = Suboperațiune modificată.
sub-operation-gone = Această suboperațiune nu mai există.
sub-operation-nothing-to-show = Nicio suboperațiune de afișat.
sub-operation-label-required = Numele suboperațiunii este obligatoriu.
sub-operation-parent-gone = Operațiunea de repartizat nu mai există.
# Ce spune fișa atunci când arată Complementul. Nu este protejat: poate fi
# modificat, dar trebuie să se știe ce se ia (decizie a lui Fabrice,
# 26/07/2026).
sub-operation-is-the-complement = Acesta este Complementul: ceea ce rămâne de repartizat. Redenumirea lui sau schimbarea sumei sale îl transformă într-o suboperațiune obișnuită.
sub-operation-of = Repartizarea „{ $label }” ({ $amount })

operations-pointed = { $count ->
    [0] Nicio operațiune de reconciliat: selecția este deja reconciliată.
    [one] O operațiune reconciliată.
    [few] { $count } operațiuni reconciliate.
   *[other] { $count } de operațiuni reconciliate.
}
operations-select-one = Selectați o singură operațiune.

# --- Duplicarea și afișarea suboperațiunilor (F02) ---------------------
# Duplicarea deschide o fișă precompletată pe care utilizatorul o confirmă
# el însuși (decizie a lui Fabrice, 26/07/2026): nimic nu se scrie atât timp
# cât nu a salvat, iar înainte poate corecta data sau suma.

operation-copy = Copie de salvat: nu s-a creat încă nimic.
operations-show-children = Afișare toate suboperațiunile
operations-hide-children = Ascundere toate suboperațiunile
operations-recurring-from = Creați o operațiune periodică pornind de la această operațiune

# --- A doua confirmare a unei ștergeri grave --------------------------
# Ștergerea unui cont bancar duce cu ea tot istoricul lui: un Da/Nu se apasă
# fără să fie citit, așa că se cere scrierea cuvântului (decizie a lui
# Fabrice, 26/07/2026). Cuvântul este cel din dicționar — „Da” aici, „Yes” în
# engleză — deci nu este nimic de tradus de două ori aici.

accounts-delete-second-question = Această ștergere este definitivă și duce cu ea tot istoricul contului. Tastați „{ $word }” pentru a o confirma.

# --- F20-F24 — Cele șase statistici -----------------------------------
# Șablon comun, declinat pe șase axe. Cea pe categorii a servit drept model
# și Fabrice a validat-o pe 26/07/2026 înainte ca celelalte cinci să existe
# — numele coloanelor sunt cele din original.

window-statistics-title = { $kind ->
    [assignment] Statistici după alocare
    [budget-line] Statistici după pozitie bugetara
    [payment-mode] Statistici după modalitate de plata
    [payee] Statistici după terț și comerciant
    [project] Statistici după proiect
    [verification] Statistici după verificare
   *[category] Statistici după categorie
}

statistics-axis-column = { $kind ->
    [assignment] Alocare
    [budget-line] PozitieBuget
    [payment-mode] ModOperatiune
    [payee] Terți
    [project] Proiecte
    [verification] Verificare
   *[category] NumeCategorie
}

statistics-unclassified = { $kind ->
    [assignment] Fără alocare
    [budget-line] Fără pozitie bugetara
    [payment-mode] Fără modalitate de plata
    [payee] Fără terț
    [project] Fără proiect
    [verification] De verificat
   *[category] Fără categorie
}
statistics-total = Total
statistics-sum = Sumă
statistics-cumulative = Cumul

# Cele cinci comutatoare din bandă. Eticheta basculează ON/OFF, ca în
# original: comutatorul însuși spune unde se află.
statistics-switch-pointed = Operațiuni reconciliate { $state }
statistics-switch-committed = Operațiuni angajate { $state }
statistics-switch-planned = Operațiuni planificate { $state }
statistics-switch-debits = Sume debit { $state }
statistics-switch-credits = Sume credit { $state }
statistics-switch-on = ON
statistics-switch-off = OFF

statistics-no-account = Nu a fost ales niciun cont: statistica nu se referă la nimic.
statistics-no-data = Nicio operațiune în acest an pentru conturile alese.
statistics-detail-empty = Faceți clic pe o casetă cu cifre pentru a vedea operațiunile pe care le numără.
statistics-detail-none = Nicio operațiune în spatele acestei casete.
statistics-accounts = { $count ->
    [one] Un cont
    [few] { $count } conturi
   *[other] { $count } de conturi
}
statistics-year-next = Anul următor
statistics-year-previous = Anul precedent

statistics-column-date = Data
statistics-column-clearing-date = DataReconciliere
statistics-column-label = Descriere
statistics-column-amount = Suma
statistics-column-comments = Comentarii

accounts-stats-multiselect-help = Info: Utilizați clic de mouse + tasta [{ $modifier }] pe tabel pentru a alege mai multe conturi

# Anul statisticilor: se face clic pe el și se introduce un an. Limitele sunt
# cele ale opțiunii „Toate” din meniul Perioadă — un an Radinus este un
# întreg între 1950 și 2550 (Fabrice, 26/07/2026).
statistics-year-question = Cu ce an doriți să lucrați? Radinus merge de la { $first } la { $last }.
statistics-year-choose = Alegere an

# --- F27, le bilan croisé (Fabrice, 25/08/2026) ---------------------
# Les catégories en lignes, les affectations en colonnes, sur un mois.
# Tout le reste de son vocabulaire est celui des statistiques : Total,
# Somme, les interrupteurs, « Sans … », les colonnes du détail.
window-crossed-balance-title = Bilanț încrucișat
crossed-balance-window-name = Bilanț încrucișat
crossed-balance-column = Categorie
crossed-balance-no-data = Nicio operațiune în această lună pentru conturile alese.
crossed-balance-month-question = Pe ce lună doriți să lucrați? Un număr între { $first } și { $last }.
crossed-balance-month-choose = Alegeți luna
crossed-balance-next = Luna următoare
crossed-balance-previous = Luna precedentă

# --- Exportul tabelelor (clic dreapta) --------------------------------
# O funcție a tabelului, nu a unei ferestre: toate listele o au.

export-to-excel = Export către Excel (.xlsx)
export-to-word = Export către Word (.docx)
export-to-tsv = Export către TSV (.tsv)
export-to-ini = Export către INI (.ini)
export-to-toml = Export către TOML (.toml)
export-to-yaml = Export către YAML (.yaml)
export-to-ofx = Export către OFX (.ofx)
export-to-qif = Export către QIF (.qif)
export-to-ods = Export către LibreOffice Calc (.ods)
export-to-csv = Export către CSV (.csv)
export-to-xml = Export către XML (.xml)
# Meniul Export al ferestrei de statistici: o filă pe an, denumită AN_2026.
# Anii goi — cu comutatoarele așa cum au fost puse — nu figurează acolo.
export-menu = Export
export-to = Export către
# Copying from a table (Fabrice, 07/10/2026): the two entries at the head of
# the right-click menu, and what is said when the clipboard refuses.
copy-cell = Copiază celula
copy-rows = Copiază rândurile selectate
copy-failed = Copierea în clipboard a eșuat.
export-all-years-excel = Export toți anii către Excel
export-all-years-ods = Export toți anii către LibreOffice Calc
export-all-months-excel = Exportați toate lunile anului afișat în Excel
export-all-months-ods = Exportați toate lunile anului afișat în LibreOffice Calc
export-no-year = Niciun an nu poartă operațiuni: nu este nimic de exportat.
export-years-done = Ani exportați: { $years } — către „{ $file }”.
export-to-json = Export către JSON (.json)
export-done = Exportat către „{ $file }”.
export-failed = Export imposibil: { $reason }
export-nothing = Nu este nimic de exportat.
export-context = { $window } — { $detail }
statistics-window-name = { $kind ->
    [assignment] Statistici după alocare
    [budget-line] Statistici după pozitie bugetara
    [payment-mode] Statistici după modalitate de plata
    [payee] Statistici după terț și comerciant
    [project] Statistici după proiect
    [verification] Statistici după verificare
   *[category] Statistici după categorie
}
statistics-detail-name = Detaliu statistici

# --- F19 — Tablou de bord ----------------------------------------------
# O perioadă și trei întrerupătoare; două diagrame inelare pentru fiecare
# poziție bugetară; trei cifre mari. Culorile sectoarelor sunt cele ale
# originalului, preluate de pe captura lui Fabrice.

window-dashboard-title = Tablou de bord
dashboard-menu-period = Perioadă
dashboard-menu-misc = Diverse
dashboard-from = Data de început:
dashboard-to = Data de sfârșit:
dashboard-switch-pointed = Includere operațiuni reconciliate
dashboard-switch-committed = Includere operațiuni angajate
dashboard-switch-planned = Includere operațiuni planificate
dashboard-spending = Cheltuieli
dashboard-earning = Venituri
dashboard-debits = Suma operațiunilor debitate
dashboard-credits = Suma operațiunilor creditate
dashboard-balance = Balanță
dashboard-unclassified = Fără poziție bugetară
dashboard-nothing = Nicio operațiune în această perioadă.
dashboard-no-account = Niciun cont nu a fost ales: tabloul de bord nu se referă la nimic.
dashboard-enlarge = Deschidere pe ecran mare

# --- F25 — Evoluția soldului -------------------------------------------
# Câte un grafic pentru fiecare cont ales, plus cel al totalului — care nu
# există decât începând de la două conturi (regula lui Fabrice, 26/07/2026).
# Graficele sunt în trepte: soldul își păstrează valoarea până la operațiunea
# următoare.

window-curve-title = Evoluția soldului
curve-heading = Evoluția soldului pe zile
curve-menu-period = Perioadă
curve-total = Total
curve-from = Data de început:
curve-to = Data de sfârșit:
curve-axis-balance = sold
curve-nothing = Niciun cont nu a fost ales: nu există niciun grafic de trasat.
curve-empty = Nicio operațiune în această perioadă.

# F40 — « Analyse Évolution du solde » (Fabrice, 05/10/2026): the chart of F25,
# on which one drags a zone, and under it the operations of that zone. The
# chart's own words are F25's (curve-*); these are the summary of the zone.
window-analysis-title = Analiza evoluției soldului
analysis-heading = Analiza evoluției soldului
analysis-hint = Trasați o zonă pe grafic, cu butonul mouse-ului apăsat, pentru a vedea operațiunile din acea perioadă.
analysis-zone = Zonă:
analysis-opening = Sold inițial:
analysis-closing = Sold final:
analysis-variation = Variație:
analysis-detail-name = Analiza soldului
analysis-detail-none = Nicio operațiune în această zonă.

# --- F05 — Clasificarea rapidă a operațiunilor -------------------------
# Fereastra în care se clasifică **în masă**: se selectează rânduri, se bifează
# caracteristicile de schimbat și se aplică dintr-o dată — în memorie.
# Nimic nu se scrie atât timp cât nu s-a salvat, iar salvarea nu scrie decât
# ceea ce diferă de ceea ce a fost citit (regulile lui Fabrice,
# 27/07/2026).

window-quick-classification-title = Clasificarea rapidă a operațiunilor: { $account }
quick-dates-title = Datele de început și de sfârșit ale listei.
quick-from = Data de început
quick-to = Data de sfârșit
quick-menu-period = Perioadă
quick-change-title = Schimbați caracteristicile selecției în:
quick-check-category = Categorie
quick-check-assignment = Alocare
quick-check-payment-mode = Mod
quick-check-payee = Terț
quick-check-project = Proiect
quick-check-status = Stare
quick-check-verification = Verificare
quick-column-date = Data
quick-column-label = Descriere
quick-column-amount = Sumă
quick-column-category = Categorie
quick-column-assignment = Alocare
quick-column-payment-mode = Modalitate plată
quick-column-payee = Terț
quick-column-project = Proiecte
quick-column-status = Stare
quick-column-verification = Verificare
# Pe un Mac, Ctrl + clic este un clic dreapta: tasta care adaugă la o selecție
# este acolo ⌘, iar ajutorul trebuie să o indice pe cea care funcționează.
quick-multiselect-help = Info: Utilizați clic de mouse + tasta [{ $modifier }] pe tabel pentru a selecta mai multe elemente
quick-none = Nicio operațiune în această perioadă.
quick-select-lines = Selectați cel puțin un rând și bifați cel puțin o caracteristică.
quick-applied = { $count ->
    [0] Nimic nu s-a schimbat: aceste rânduri aveau deja această clasificare.
    [one] Un rând clasificat. Nimic nu este încă salvat.
    [few] { $count } rânduri clasificate. Nimic nu este încă salvat.
   *[other] { $count } de rânduri clasificate. Nimic nu este încă salvat.
}
quick-pending = { $count ->
    [0] Nicio modificare în așteptare.
    [one] Un rând modificat, nesalvat.
    [few] { $count } rânduri modificate, nesalvate.
   *[other] { $count } de rânduri modificate, nesalvate.
}
quick-save-question = { $count ->
    [one] Salvați modificarea în așteptare?
    [few] Salvați cele { $count } modificări în așteptare?
   *[other] Salvați cele { $count } de modificări în așteptare?
}
quick-saved = { $count ->
    [0] Nu era nimic de salvat.
    [one] Un rând salvat.
    [few] { $count } rânduri salvate.
   *[other] { $count } de rânduri salvate.
}
quick-nothing-to-save = Nicio modificare în așteptare.
quick-leave-question = Unele modificări nu sunt salvate. Ce doriți să faceți?
quick-leave-save = Salvare și ieșire
quick-leave-discard = Abandonare și ieșire
quick-leave-stay = Rămânere
quick-title-apply = Aplicare la rândurile selectate ( în memorie )
quick-title-save = Salvare pe disc

# --- F17 / F18 — Importarea unui extras de cont ------------------------
# Se alege un cont, se deschide un fișier OFX — care rămâne în RAM —,
# rândurile pe care baza de date le cunoaște deja se afișează în pastel, iar
# a treia pictogramă le integrează: în masă dacă sunt alese mai multe, unul
# câte unul prin fișa de reconciliere în caz contrar (procedura lui Fabrice,
# 27/07/2026).

window-statement-import-title = Importarea extraselor de conturi bancare: { $account }
window-statement-form-title = Reconcilierea unei tranzacții (Integrează o operațiune în istoricul contului dumneavoastră)
statement-menu-filter = Filtru
statement-filter-all = Toate rândurile
statement-filter-pending = De integrat
statement-filter-known = Deja integrate
statement-column-id = ID
statement-column-reconciled = Reconciliat
statement-column-fitid = FITID
statement-column-date = Data
statement-column-label = Descriere
statement-column-reference = Referință plată
statement-column-debit = Debit
statement-column-credit = Credit
statement-account = Cont
statement-file = Fișier
statement-difference = Diferență
statement-none = Niciun extras de cont nu este deschis: faceți clic pe folderul galben pentru a alege un fișier (OFX, CSV, QIF).
statement-empty = Acest extras de cont nu conține nicio operațiune.
statement-no-match = Niciun rând nu corespunde filtrului.
statement-help = Info: Utilizați clic de mouse + tasta [{ $modifier }] pe tabel pentru a selecta mai multe rânduri
statement-choose-account = Acest fișier conține mai multe conturi. Pe care doriți să îl importați?
statement-select-line = Selectați cel puțin un rând din extrasul de cont.
statement-title-open = Deschiderea unui fișier de extras de cont (OFX, QIF, CSV)
statement-title-info = Informații despre fișierul deschis
statement-title-integrate = Integrarea selecției în cont
statement-title-validate = Integrarea acestei operațiuni în cont
statement-duplicate = Atenție, duplicat: această tranzacție pare să fi fost deja integrată în baza de date (Financial Institution Transaction ID există)
statement-no-fitid = Atenție: acest fișier nu oferă niciun identificator (FITID) pentru acest rând. Un duplicat nu va putea fi detectat.
statement-loaded = { $count ->
    [0] Acest fișier nu conține nicio operațiune pentru acest cont.
    [one] { $count } rând citit, dintre care { $known } deja prezent în contul dumneavoastră.
    [few] { $count } rânduri citite, dintre care { $known } deja prezente în contul dumneavoastră.
   *[other] { $count } de rânduri citite, dintre care { $known } deja prezente în contul dumneavoastră.
}
statement-loaded-unidentified = { $alike ->
    [0] Rânduri citite: { $count }; niciunul nu seamănă cu o operațiune deja prezentă în contul dumneavoastră.
    [one] Rânduri citite: { $count }, dintre care unul seamănă cu o operațiune deja prezentă în contul dumneavoastră (aceeași dată, aceeași descriere, aceeași sumă).
    [few] Rânduri citite: { $count }, dintre care { $alike } seamănă cu operațiuni deja prezente în contul dumneavoastră (aceeași dată, aceeași descriere, aceeași sumă).
   *[other] Rânduri citite: { $count }, dintre care { $alike } seamănă cu operațiuni deja prezente în contul dumneavoastră (aceeași dată, aceeași descriere, aceeași sumă).
}
statement-loaded-also-alike = { $alike ->
    [one] Încă unul seamănă cu o operațiune deja prezentă (aceeași dată, aceeași descriere, aceeași sumă).
    [few] Încă { $alike } seamănă cu operațiuni deja prezente (aceeași dată, aceeași descriere, aceeași sumă).
   *[other] Încă { $alike } seamănă cu operațiuni deja prezente (aceeași dată, aceeași descriere, aceeași sumă).
}
statement-integrated = { $count ->
    [0] Nimic nu a fost introdus: aceste rânduri sunt deja în contul dumneavoastră.
    [one] O operațiune integrată.
    [few] { $count } operațiuni integrate.
   *[other] { $count } de operațiuni integrate.
}
# **Mesajele originalului, cuvânt cu cuvânt** (consemnul lui Fabrice,
# 28/07/2026: a rămâne fidel codului de origine). Al său avertizează înainte de
# lot, întreabă rând cu rând în fața unui duplicat și își prezintă socotelile
# la sfârșit.

statement-mass-question =
    Sunteți sigur că doriți să integrați simultan mai multe operațiuni în contul dumneavoastră?
    Va trebui să le categorisiți și să le caracterizați ulterior pentru a face statistici precise
    În cazul fișierelor Ofx: dacă sunt detectate duplicate va trebui să alegeți comportamentul programului
    Pentru celelalte tipuri de fișiere: va trebui să fiți atent la duplicate
statement-duplicate-question =
    Tranzacția: { $date } { $label }: { $amount }
    pare să fi fost deja integrată în istoricul tranzacțiilor contului dumneavoastră bancar.
    Doriți într-adevăr să procedați la reconciliere?
statement-already-reconciled = Ați reconciliat deja această tranzacție: ea este deja integrată în istoricul tranzacțiilor contului dumneavoastră
statement-integration-report =
    Sfârșitul integrării.
    Număr de înregistrări integrate: { $added }
    Număr de înregistrări ignorate: { $ignored }
statement-integration-abandoned =
    Abandonarea integrării!
    Număr de înregistrări integrate: { $added }
    Număr de înregistrări ignorate: { $ignored }
statement-yes = Da
statement-no = Nu
statement-cancel = Anulare
statement-file-info =
    Contul fișierului: { $account }
    Perioada: de la { $from } până la { $to }
    Soldul anunțat de bancă: { $balance }
statement-qif-question = Nimic din acest fișier nu indică dacă data „{ $date }” se scrie zi/lună sau lună/zi. Ea înseamnă:
statement-qif-day-month = Ziua { $day }, luna { $month } (zi/lună)
statement-qif-month-day = Ziua { $day }, luna { $month } (lună/zi)
statement-qif-dates-mixed = Acest fișier își scrie datele în două moduri: „{ $first }” se citește zi/lună, „{ $second }” lună/zi. Nu este importat, pentru a nu denatura nicio dată.
statement-qif-amounts-mixed = Acest fișier își scrie sumele în două moduri: „{ $first }” cu punct, „{ $second }” cu virgulă. Nu este importat, pentru a nu denatura nicio sumă.
statement-qif-opening = Sold inițial de { $amount } la { $date }: nu este o operațiune, nu este importat.
statement-qif-opening-undated = Sold inițial de { $amount }: nu este o operațiune, nu este importat.
statement-qif-suspect = Rândul { $rank }, „{ $label }” ({ $amount }), seamănă cu un sold inițial: verificați-l înainte de a-l integra.
statement-qif-rejected = { $count ->
    [one] Un rând ilizibil nu este importat: { $lines }.
    [few] { $count } rânduri ilizibile nu sunt importate: { $lines }.
   *[other] { $count } de rânduri ilizibile nu sunt importate: { $lines }.
}
statement-qif-reason-date = dată
statement-qif-reason-amount = sumă
statement-qif-reason-differ = sume contradictorii
statement-qif-no-account = Acest cont nu mai este în fișier: redeschideți fișierul.
statement-balance-unknown = neindicat în fișier
statement-group-identification = Identificarea operațiunii
statement-group-amount = Suma operațiunii
statement-group-classification = Clasificarea operațiunii pentru calculul statisticilor
statement-group-status = Starea operațiunii
statement-field-date = Data
statement-field-label = Descriere
statement-field-reference = Referință plată
statement-field-type = Tip operațiune
statement-field-amount = Sumă
statement-field-mode = Mod operațiune
statement-field-category = Categorie
statement-field-assignment = Alocare
statement-field-payee = Terț
statement-field-project = Proiect
statement-field-status = Stare
statement-field-clearing = Data reconcilierii

# --- Fereastra de împărțire a unui extras CSV --------------------------
# Un CSV nu poartă niciun nume de câmp fiabil: se reglează, se testează, se
# privește, se reia. Previzualizarea arată totul, inclusiv aiureala — așa se
# vede că s-a greșit — dar numai rândurile valide trec către fereastra de
# integrare (regula lui Fabrice, 27/07/2026).

window-csv-statement-title = Importarea datelor provenind dintr-un fișier csv
csv-preview-title = Previzualizarea fișierului:
csv-settings-title = Parametri de împărțire a fișierului în vederea extragerii datelor:
csv-extraction-title = Vizualizarea extragerii datelor conform parametrilor de împărțire  ( verificați coerența datelor ):
csv-column-line = Nr. rând
csv-column-content = Conținut
csv-header-lines = Numărul de rânduri de antet ale fișierului care trebuie ignorate
csv-separator = Datele (coloanele) sunt separate prin caracterul:
csv-date-at = Poziția câmpului dată
csv-label-at = Poziția câmpului descriere
csv-debit-at = Poziția câmpului sumă debit
csv-credit-at = Poziția câmpului sumă credit
csv-test = Testarea parametrilor
csv-separator-semicolon = Punct și virgulă   ;
csv-separator-comma = Virgulă   ,
csv-separator-tab = Tabulator
csv-separator-pipe = Bară verticală   |
csv-separator-space = Spațiu
csv-help = Reglați, testați, priviți: numai rândurile care poartă o dată și o sumă lizibile vor fi importate.
csv-none = Fișierul este gol.
csv-not-tested = Faceți clic pe „Testarea parametrilor” pentru a vedea ce dă împărțirea.
csv-extraction = { $count ->
    [0] Împărțirea nu produce niciun rând: verificați numărul de rânduri de antet și separatorul.
    [one] { $count } rând împărțit: { $valid } va fi importat, { $dropped } înlăturat din lipsa unei date sau a unei sume lizibile.
    [few] { $count } rânduri împărțite: { $valid } vor fi importate, { $dropped } înlăturate din lipsa unei date sau a unei sume lizibile.
   *[other] { $count } de rânduri împărțite: { $valid } vor fi importate, { $dropped } înlăturate din lipsa unei date sau a unei sume lizibile.
}
csv-nothing-valid = Niciun rând nu poartă în același timp o dată și o sumă lizibile: nu există nimic de importat. Verificați numărul de rânduri de antet, separatorul și poziția câmpurilor.
csv-title-validate = Trecerea rândurilor valide către importare

# --- F13 / F31 / F14 / F12 — Carnete de cecuri și cecuri (etapa 9) -------
# Portarea celor cinci coduri WinDev ale sale și a celor șapte capturi,
# furnizate pe 28/07/2026. Frazele sale exacte acolo unde are una; ale mele în
# rest.
#
# Trei fidelități pe care le-a hotărât în acea zi și care se aud în cuvinte:
# referința dublă nu este anunțată (`Existe_Reference` al său nu este apelată
# niciodată), numărul de cecuri nu este confruntat cu limitele, iar contorul
# de operațiuni numără suboperațiunile pe care listele le refuză.

window-chequebooks-title = Lista carnetelor de cecuri
window-chequebook-title = Parametri carnet de cecuri
window-cheques-title = Compoziția carnetului de cecuri: lista cecurilor.
window-cheque-title = Fișă cecuri
window-cheque-operations-title = Lista operațiunilor.

# Lista carnetelor de cecuri (F13) — toate carnetele, din toate conturile
# laolaltă: cele două coloane de cont ale sale n-ar servi la nimic pe unul
# singur.
chequebooks-column-reference = DESCRIERE
chequebooks-column-date = Data
chequebooks-column-account = NumeCont
chequebooks-column-account-number = Nr. cont
chequebooks-column-comments = Comentarii
chequebooks-none = Nu este înregistrat niciun carnet de cecuri.
chequebooks-nothing-to-show = Niciun carnet de cecuri nu corespunde acestei căutări.
chequebooks-title-composition = Vizualizarea compoziției carnetului de cecuri
chequebooks-delete-question = Au fost detectate operațiuni (tranzacții bancare) asociate carnetului de cecuri. Confirmați că doriți să ștergeți acest carnet de cecuri?
chequebooks-deleted = { $count ->
    [one] Un carnet de cecuri șters.
    [few] { $count } carnete de cecuri șterse.
   *[other] { $count } de carnete de cecuri șterse.
}
chequebooks-gone = Acest carnet de cecuri nu mai există.
chequebooks-created = Carnet de cecuri înregistrat, cu toate cecurile sale.
chequebooks-updated = Carnet de cecuri modificat.
# Tăcerea `HAjoute` al său: fereastra nu spune că referința este deja luată.
# Spune doar că nu s-a înregistrat nimic — altfel s-ar crede că a fost creat
# carnetul.
# Cele opt precauții din „Precauttion enregistrement cheque.txt” al său,
# cuvânt cu cuvânt și în ordinea sa. Primele șapte sunt `Erreur()`, a opta
# este un `Info()` — iar ordinea decide ce se vede atunci când două lucruri
# merg prost în același timp.
chequebook-refusal-duplicate = Există deja o referință cu același nume
chequebook-refusal-reference-required = Introducerea unei referințe este obligatorie
chequebook-refusal-number-too-big = Numerele primului și/sau ultimului cec sunt prea mari (valoare maximă 999 999 999)
chequebook-refusal-date = Introduceți o dată de primire validă
chequebook-refusal-numbers-required = Completați numerele primului și ultimului cec
chequebook-refusal-order = Numărul primului cec trebuie să fie mai mic decât numărul ultimului cec
chequebook-refusal-account = Selectați obligatoriu contul în legătură cu acest carnet de cecuri
chequebook-refusal-too-many = Număr maxim de cecuri pentru un carnet: 1000, limită atinsă
# Cererea sa de confirmare, pusă doar la adăugare: recapitulează ce urmează
# să fie creat și avertizează că nimic nu va mai putea fi modificat după.
chequebook-creation-question =
    Crearea carnetului de cecuri cu următoarele caracteristici:
    - Număr de cecuri de generat:{ $count }
    - Cecuri numerotate de la { $first } la { $last }
    Atenție, aceste date nu vor mai putea fi modificate după creare!

# Fișa carnetului de cecuri (F31). Primele cinci câmpuri sunt inactive de
# îndată ce carnetul există: cecurile sale sunt deja acolo.
chequebook-field-id = Identificator carnet de cecuri
chequebook-field-reference = Referință
chequebook-field-received = Fabricat sau primit pe
chequebook-field-first = Numărul primului cec
chequebook-field-last = Numărul ultimului cec
chequebook-field-quantity = Număr de cecuri
chequebook-field-account = Asociere cu contul bancar:
chequebook-field-comments = Comentarii
chequebook-locked = Cecurile acestui carnet sunt deja create: numerotarea sa nu se mai modifică.
# Fraza sa, cuvânt cu cuvânt (`Enreg_Lire`).
chequebook-account-missing = Contul bancar căruia i-a fost asociat acest carnet de cecuri lipsește sau a fost șters!

# Compoziția carnetului de cecuri (F14). Starea se schimbă în casetă.
cheques-column-number = Nr. cec
cheques-column-date = Data
cheques-column-place = Loc
cheques-column-payee = Beneficiar
cheques-column-amount = Sumă
cheques-column-status = Stare
cheques-column-comments = Comentarii
cheques-column-operations = Nr. operațiuni asociate
cheques-none = Acest carnet de cecuri nu conține niciun cec.
cheques-nothing-to-show = Niciun cec nu corespunde acestei căutări.
cheques-help = Faceți clic în caseta Stare pentru a o schimba; lupa arată operațiunile asociate, veriga asociază una.
cheques-title-linked = Vizualizarea operațiunilor deja asociate acestui cec
cheques-title-link = Asocierea unei operațiuni la acest cec
cheques-status-changed = Starea cecului a fost modificată.

# Fișa cecului (F12).
cheque-field-id = Identificator cec
cheque-field-number = Număr cec
cheque-field-issued = Data emiterii
cheque-field-place = Locul emiterii
cheque-field-payee = Beneficiar
cheque-field-amount = Sumă
cheque-field-comments = Comentarii
cheque-field-status = Starea cecului
cheque-gone = Acest cec nu mai există.
cheque-updated = Cec modificat.

# Cele două fețe ale ferestrei de asociere.
cheque-operations-linked-title = Lista operațiunilor deja asociate acestui cec.
cheque-operations-choose-title = Alegeți o operațiune de asociat cecului
cheque-operations-column-account = Cont
cheque-operations-column-label = Nume
cheque-operations-column-date = Data
cheque-operations-column-clearing = Data reconcilierii
cheque-operations-column-amount = Sumă
cheque-operations-column-cheque = Cec asociat
cheque-operations-none-linked = Nicio operațiune nu este asociată acestui cec.
cheque-operations-none = Acest cont nu conține nicio operațiune.
cheque-operations-nothing-to-show = Nicio operațiune nu corespunde acestei căutări.
cheque-operations-help = Operațiunile îngroșate poartă deja un cec.
cheque-operations-linked-help = Crucea roșie detașează cecul de operațiune: nu se șterge nimic.
cheque-operations-linked = Operațiune asociată cecului.
cheque-operations-dissociated = Cec detașat de operațiune.
cheque-operations-menu-filter = Filtru
cheque-title-associate = Asocierea acestei operațiuni la cec
cheque-title-dissociate = Detașarea cecului de această operațiune

# Banda „Cec în legătură cu operațiunea” din fișa operațiunii și cei doi timpi
# ai pescuitului de cec — carnetul, apoi cecul.
chequebooks-select-question = Alegeți carnetul de cecuri
cheques-select-question = Alegeți cecul de asociat operațiunii
operation-check-save-first = Salvați mai întâi operațiunea: un cec se asociază unei operațiuni care există.
operation-check-none = Această operațiune nu poartă niciun cec.

# --- F36 / F37 — Șabloanele de operațiune (etapa 10) --------------------
# Un șablon este o introducere gata făcută: se aplică pentru a nu retasta și
# **suprascrie** ceea ce se află în fișă. Nimic nu ajunge pe disc atât timp
# cât fișa operațiunii nu este confirmată (regula lui Fabrice, 29/07/2026).

window-operation-templates-title = Lista șabloanelor de operațiuni
window-operation-template-title = Fișă șablon operațiune

operation-templates-none = Nu este înregistrat niciun șablon de operațiune.
operation-templates-nothing-to-show = Niciun șablon nu corespunde acestei căutări.
operation-templates-select-question = Alegeți șablonul de aplicat
operation-templates-delete-question = Confirmați ștergerea șabloanelor selectate?
operation-templates-deleted = { $count ->
    [one] Un șablon șters.
    [few] { $count } șabloane șterse.
   *[other] { $count } de șabloane șterse.
}
operation-template-gone = Acest șablon nu mai există.
operation-template-fresh = Șablon nou.
operation-template-created = Șablon înregistrat.
operation-template-updated = Șablon modificat.
operation-template-label-required = Introducerea unui nume este obligatorie
operation-template-duplicate = Există deja un șablon cu același nume

# Fișa F36, secțiune cu secțiune — denumirile sale exacte.
operation-template-field-id = ID șablon operațiune
operation-template-group-name = Numele implicit al viitoarei operațiuni după aplicarea șablonului
operation-template-field-label = Nume
operation-template-group-amount = Suma implicită a operațiunii predefinită în acest șablon
operation-template-field-direction = Tip operațiune
operation-template-field-amount = Sumă
operation-template-group-status = Starea implicită a operațiunii în acest șablon
operation-template-field-status = Stare operațiune
operation-template-group-classification = Informațiile șablonului pentru clasificarea și calculul statisticilor
operation-template-field-category = Categorie
operation-template-field-assignment = Alocare
operation-template-field-mode = Modalitate
operation-template-field-payee = Terț
operation-template-field-project = Proiect

# Butonul „Șablon” din fișa operațiunii: o pictogramă, două gesturi.
operation-template-question = Ce doriți să faceți cu șabloanele de operațiune?
operation-template-apply = Aplicarea unui șablon
operation-template-save-as = Salvare ca șablon
operation-template-applied = Șablon aplicat. Confirmați fișa pentru a o salva.
operation-template-saved-as = Operațiune salvată ca șablon.
operation-template-needs-label = Dați un nume operațiunii înainte de a face din ea un șablon.

# --- F26 / F27 — Bugetul (etapa 11) -------------------------------------
# Două uși, două întrebări: se introduce bugetul sau se controlează dacă a
# fost respectat. Axa este poziția bugetară, unitatea este anul, iar convenția
# de semn este cea a operațiunilor — o cheltuială se scrie negativ.

window-budget-entry-title = Introducere buget: cheltuieli(-) și venituri(+) prevăzute pe un an
window-budget-control-title = Controlul bugetului

budget-column-line = Poziție bugetară
budget-none = Nu este înregistrată nicio poziție bugetară: bugetul se introduce pe poziții.
budget-planned = Planificat
budget-actual = Realizat
budget-sum = Sumă
budget-cumulative = Cumulat
budget-total = Total
# Reamintirea convenției de semn, cu roșu sub tabelul de introducere. Fraza
# sa, cuvânt cu cuvânt și cu spații cu tot (captura „POINT 004 saisie
# budget.png”): este cu roșu sub tabel, iar titlul ferestrei o repetă
# prescurtat. Nimeni nu ar ghici convenția fără ea.
budget-sign-warning = Introduceți obligatoriu cheltuielile  cu semn negativ și veniturile prevăzute cu sume pozitive
budget-entry-help = Tastați sumele în casete, apoi salvați.
budget-saved = Buget salvat.
budget-nothing-changed = Nicio modificare de salvat.
budget-discard-question = Abandonați modificările bugetului?

# Meniul Afișare al controlului: cele două moduri de a citi aceeași abatere.
budget-menu-display = Afișare
budget-display-money = Valori
budget-display-percent = Procente
budget-control-help = Verde: cel puțin la fel de bine ca prevăzut. Roșu: mai puțin bine.

# --- F09 — Transferul unei sume între două conturi (etapa 12) ------------
# Un transfer nu este o operațiune, sunt două: un debit pe contul sursă, un
# credit pe contul destinație. Pleacă împreună sau deloc.

window-transfer-title = Transferul unei sume între două conturi

transfer-group-source = Debitarea sumei pe acest cont sursă
transfer-group-target = Creditarea sumei pe acest cont destinație
transfer-group-description = Descrierea operațiunii
transfer-group-nomenclature = Informații de nomenclator
transfer-group-amount = Valoarea sumei de transferat
transfer-field-source = Cont sursă
transfer-field-target = Cont destinație
transfer-field-label = Descriere
transfer-field-reference = Referință plată
transfer-field-date = Data
transfer-field-status = Stare operațiune
transfer-field-clearing = Data reconcilierii
transfer-field-category = Categorie
transfer-field-mode = Modalitate de plată
transfer-field-assignment = Alocare
transfer-field-payee = Terți / comercianți
transfer-field-project = Proiect
transfer-field-amount = Sumă

# Singurul buton al panourilor care anunță în loc să întrebe.
ui-ok = OK
transfer-help = Alegeți cele două conturi: soldurile lor se afișează aici.
transfer-title-validate = Efectuarea transferului
# Cele trei solduri ale contului ales, pentru a ști ce implică transferul.
transfer-balances = { $account } — În bancă: { $bank } · Real: { $real } · Final: { $final }
# Panoul care recapitulează ceea ce tocmai a fost scris.
transfer-done = Transfer efectuat. { $amount } din contul { $source } către contul { $target }, la { $date }.

transfer-refusal-accounts-required = Alegeți contul sursă și contul destinație
transfer-refusal-same-account = Contul sursă și contul destinație nu pot fi același: un transfer merge dintr-un cont către altul
transfer-refusal-account-gone = Unul dintre cele două conturi nu mai există
transfer-refusal-label-required = Descrierea este obligatorie
transfer-refusal-date-required = Data este obligatorie
transfer-refusal-amount = Suma de transferat trebuie să fie strict pozitivă

# ---------------------------------------------------------------------------
# Faza 13 — importul unei foi Excel (F34, F35, asociere).
# ---------------------------------------------------------------------------

window-excel-import-title = Importarea foii excel [ Etapa 1/3 ]: definirea zonei de captură
window-excel-fields-title = Importarea foii excel [ Etapa 2/3 ]: asocierea câmpurilor
window-excel-association-title = Importarea foii excel: asocierea datelor

# Întrebarea pusă la deschidere. Un fișier Excel este făcut de mână:
# conține ce conține, iar o parte din aiurelile pe care le poartă
# este imposibil de detectat. Se întinde deci plasa înainte de săritură.
excel-backup-question = O foaie Excel este făcută de mână: poate conține date valide, dar greșite, sume cu formatul corect și semnul greșit — iar acest lucru niciun control nu îl poate vedea. Importul va scrie aceste rânduri în contul dumneavoastră. Doriți să salvați o copie de siguranță a datelor înainte de a începe?

excel-group-file = 1 - Desemnarea fișierului Excel de importat
excel-pick = Desemnare fișier Excel
excel-sheet = Foaia din registru:
excel-group-header = 2 - Definire: coordonatele celulelor pentru rândul de antet al tabelului unde sunt scrise numele coloanelor.
excel-header-row = Numărul primului rând unde este situat numele coloanelor
excel-first-column = Coloana de început a antetului ( coloana cea mai din stânga ):
excel-column-count = Numărul de coloane ale tabelului
excel-group-rows = 3 - Definire: numerele rândurilor de început și de sfârșit ale listei care conține datele tabelului ( sub antet și fără a-l include )
excel-first-data-row = Primul rând care conține date
excel-last-data-row = Ultimul rând care conține date:
excel-group-shape = 4 - Definire: cum scrie sumele fișierul dumneavoastră
excel-shape-single = O singură coloană de sume, cu semn ( cheltuielile în negativ )
excel-shape-debit-credit = Două coloane separate: o coloană Debit și o coloană Credit
excel-shape-note = În modul cu două coloane, semnul scris în coloana Debit nu este luat în considerare: un debit scoate întotdeauna bani, fie că este notat „-50”, fie „50”.
excel-group-test = 5 - Rezultat Test: vizualizați captura efectuată în funcție de setările dumneavoastră
excel-test = Testați parametrii pe care i-ați definit la etapele 2, 3 și 4.
excel-test-note = Indicație: numele antetelor și conținutul tabelului de mai jos trebuie să corespundă cu cele ale tabelului dumneavoastră Excel. Zona de captură nu trebuie să depășească zona tabelului.

excel-help = Parcurgeți cele cinci grupuri în ordine, apoi testați: nu veți putea trece la etapa 2 decât după ce ați văzut ce prinde zona.
excel-no-file = Desemnați mai întâi fișierul Excel de importat.
excel-not-tested = Setări modificate: relansați rezultatul test înainte de a confirma.
excel-tested = Zonă capturată: { $rows } rânduri, { $columns } coloane. Verificați că tabelul de mai jos seamănă cu foaia dumneavoastră.
excel-empty-capture = Zona pe care ați declarat-o nu prinde niciun rând: verificați numerele de rând și de coloană.
excel-title-next = Trecerea la etapa următoare
excel-into-account = Import în contul { $account }.

excel-tab-links = Legături între câmpuri
excel-tab-settings = Parametri de import
excel-column-excel = Antet_Excel
excel-column-radinus = Rubrica_Radinus
excel-links-help = În dreptul fiecărei coloane din foaia dumneavoastră, spuneți ce rubrică din Radinus alimentează. Coloanele lăsate pe [IGNORE] nu sunt importate.
excel-group-category = Categorii fără corespondențe
excel-group-payment-mode = Modalitate de plată fără corespondențe
excel-group-assignment = Alocare fără corespondențe
excel-policy-create = { $kind ->
    [payment-mode] Se creează automat modalitățile de plată inexistente
    [assignment] Se creează automat alocările inexistente
   *[category] Se creează automat categoriile inexistente
}
excel-policy-ask = { $kind ->
    [payment-mode] Se întreabă, pentru fiecare modalitate de plată inexistentă, unde să fie transferate datele
    [assignment] Se întreabă, pentru fiecare alocare inexistentă, unde să fie transferate datele
   *[category] Se întreabă, pentru fiecare categorie inexistentă, unde să fie transferate datele
}
excel-policy-blank = { $kind ->
    [payment-mode] Se lasă modalitatea de plată necompletată
    [assignment] Se lasă alocarea necompletată
   *[category] Se lasă categoria necompletată
}
excel-policy-default = { $kind ->
    [payment-mode] Se transferă modalitățile de plată inexistente într-o modalitate de plată implicită
    [assignment] Se transferă alocările inexistente într-o alocare implicită
   *[category] Se transferă categoriile inexistente într-o categorie implicită
}
excel-define-destination = Definire destinație
excel-not-linked = { $kind ->
    [payment-mode] Nicio coloană nu alimentează modalitatea de plată: această setare nu se aplică.
    [assignment] Nicio coloană nu alimentează alocarea: această setare nu se aplică.
   *[category] Nicio coloană nu alimentează categoria: această setare nu se aplică.
}
excel-fields-help = Reglați concordanțele, apoi cele trei politici, înainte de a lansa importul.
excel-title-import = Lansarea importului

excel-refusal-required = Rubricile Data, Descriere și Suma trebuie să indice obligatoriu coloane excel
excel-refusal-column-twice = Rubrici Radinus diferite indică aceeași coloană excel: o coloană nu poate alimenta decât o singură rubrică
excel-refusal-field-twice = Aceeași rubrică Radinus este asociată cu două coloane excel: nu poate avea decât una
excel-refusal-ask-unset = { $kind ->
    [payment-mode] Ați ales să se întrebe unde să fie transferate modalitățile de plată necunoscute: apăsați „Definire destinație” înainte de a lansa importul.
    [assignment] Ați ales să se întrebe unde să fie transferate alocările necunoscute: apăsați „Definire destinație” înainte de a lansa importul.
   *[category] Ați ales să se întrebe unde să fie transferate categoriile necunoscute: apăsați „Definire destinație” înainte de a lansa importul.
}

excel-column-data = Date_Excel
excel-column-destination = { $kind ->
    [payment-mode] ModalitatePlată_Radinus
    [assignment] Alocare_Radinus
   *[category] Categorie_Radinus
}
excel-association-help = În dreptul fiecărei valori venite din foaia dumneavoastră, alegeți-o pe cea din Radinus în care trebuie să fie încadrată. Un rând lăsat gol va rămâne fără clasificare.
excel-association-none = Nicio valoare necunoscută: tot ceea ce conține foaia dumneavoastră există deja în Radinus.

excel-imported = Import terminat: { $count } operațiuni scrise, { $refused } rânduri refuzate, { $created } valori de nomenclator create.
excel-report-title = Raportul importului
excel-column-row = Rând Excel
excel-column-content = Conținut
excel-column-reason = Motivul refuzului
excel-nothing-refused = Toate rândurile din foaia dumneavoastră au intrat: niciun refuz.

excel-refused-date = Dată absentă sau ilizibilă
excel-refused-amount = Sumă absentă sau ilizibilă
excel-refused-amount-both = O sumă în coloana Debit și alta în coloana Credit: imposibil de ales
excel-refused-amount-missing = Nici debit, nici credit pe acest rând

# ---------------------------------------------------------------------------
# Faza 16 — operațiunile recurente (F15, F38, F16).
# ---------------------------------------------------------------------------

window-recurring-list-title = Lista operațiunilor recurente
window-recurring-form-title = Fișa care definește regula de generare a operațiunilor recurente
window-recurring-calendar-title = Propunere de calendar al operațiunilor de inserat în conturile dumneavoastră bancare

recurring-column-label = DESCRIERE
recurring-none = Nicio regulă recurentă înregistrată.
recurring-help = Alegeți o regulă, apoi calendarul, pentru a vedea scadențele pe care le propune.
recurring-title-calendar = Propunerea calendarului scadențelor
recurring-deleted = { $count ->
    [0] Nicio regulă ștearsă.
    [one] O regulă ștearsă. Operațiunile ei rămân în cont.
    [few] { $count } reguli șterse. Operațiunile lor rămân în conturi.
   *[other] { $count } de reguli șterse. Operațiunile lor rămân în conturi.
}
recurring-gone = Această regulă nu mai există.
recurring-delete-question = Ștergeți regulile selectate? Operațiunile pe care le-au inserat deja vor rămâne în conturile dumneavoastră.

recurring-group-identity = Identificare și cont bancar vizat
recurring-group-nomenclature = Nomenclator
recurring-group-amount = Definirea sumei operațiunii
recurring-group-period = Definirea perioadei
recurring-group-ending = Condiții de încheiere a perioadei
recurring-group-produced = Informații despre operațiunile deja inserate ( numai pentru consultare )

recurring-field-id = Identificatorul operațiunii
recurring-field-account = Cont țintă
recurring-field-label = Descriere
recurring-field-category = Categorie
recurring-field-mode = Modalitate de plată
recurring-field-assignment = Alocare
recurring-field-payee = Terț / comerciant
recurring-field-project = Proiect
recurring-field-direction = Tip operațiune
recurring-field-amount = Sumă
recurring-field-next = Data următoarei operațiuni
recurring-field-every = Apoi la fiecare
recurring-field-end-date = Data de sfârșit
recurring-field-repeat = Număr de repetări
recurring-field-guid = GUID operațiune
recurring-field-produced-count = Numărul de operațiuni inserate
recurring-field-produced-last = Data ultimei operațiuni inserate
recurring-field-produced-total = Totalul sumelor generate

recurring-unit-day = Zi
recurring-unit-week = Săptămână
recurring-unit-month = Lună
recurring-unit-quarter = Trimestru
recurring-unit-year = An
recurring-ending-no-limit = Fără limită
recurring-ending-until-date = Cu dată de sfârșit
recurring-ending-repeat-count = Număr de repetări

recurring-title-erase = Ștergerea operațiunilor deja inserate de această regulă
recurring-erase-question = { $count ->
    [one] Această regulă a inserat o operațiune în conturile dumneavoastră. Doriți să o ștergeți? Soldurile vor fi recalculate, iar regula nu va da înapoi.
    [few] Această regulă a inserat { $count } operațiuni în conturile dumneavoastră. Doriți să le ștergeți pe toate? Soldurile vor fi recalculate, iar regula nu va da înapoi.
   *[other] Această regulă a inserat { $count } de operațiuni în conturile dumneavoastră. Doriți să le ștergeți pe toate? Soldurile vor fi recalculate, iar regula nu va da înapoi.
}
recurring-erase-none = Această regulă nu a inserat încă nicio operațiune.
recurring-erased = { $count ->
    [0] Nicio operațiune ștearsă.
    [one] O operațiune ștearsă, solduri recalculate.
    [few] { $count } operațiuni șterse, solduri recalculate.
   *[other] { $count } de operațiuni șterse, solduri recalculate.
}

recurring-calendar-help = Scoateți cu coșul de gunoi scadențele pe care nu le doriți, apoi confirmați pentru a le insera.
recurring-calendar-none = Nicio scadență de propus: verificați data următoarei operațiuni și contul regulilor dumneavoastră.
recurring-calendar-column-account = Cont
recurring-calendar-column-date = Dată
recurring-calendar-column-label = Descriere
recurring-calendar-column-amount = Sumă
recurring-calendar-column-category = Categorie
recurring-calendar-column-assignment = Alocare
recurring-calendar-column-mode = Modalitate plată
recurring-calendar-column-payee = Terț
recurring-calendar-column-project = Proiecte
recurring-calendar-removed = { $count ->
    [one] O scadență scoasă din propunere.
    [few] { $count } scadențe scoase din propunere.
   *[other] { $count } de scadențe scoase din propunere.
}
recurring-title-insert = Inserarea scadențelor reținute în conturi
recurring-nothing = Nu mai rămâne nicio scadență de inserat.
# Întrebarea pusă înainte de a scrie: inserarea unui calendar creează operațiuni
# adevărate în conturi adevărate, iar asta nu se face cu un clic distrat.
recurring-insert-question = { $count ->
    [one] Inserați această scadență în contul dumneavoastră? Va fi creată o operațiune și soldurile vor fi recalculate.
    [few] Inserați aceste { $count } scadențe în conturile dumneavoastră? Vor fi create tot atâtea operațiuni și soldurile vor fi recalculate.
   *[other] Inserați aceste { $count } de scadențe în conturile dumneavoastră? Vor fi create tot atâtea operațiuni și soldurile vor fi recalculate.
}
recurring-inserted = { $count ->
    [one] O operațiune inserată. Regula repornește după ultima scadență inserată.
    [few] { $count } operațiuni inserate. Regulile repornesc după ultima lor scadență inserată.
   *[other] { $count } de operațiuni inserate. Regulile repornesc după ultima lor scadență inserată.
}

recurring-refusal-label-required = Introducerea unei descrieri este obligatorie
recurring-refusal-date-required = Introducerea datei următoarei operațiuni este obligatorie
recurring-refusal-date-too-old = Data următoarei operațiuni trebuie să fie mai mare sau egală cu anul 2000
recurring-refusal-account-gone = Contul bancar specificat nu poate fi găsit, vă rugăm să selectați altul pentru a face regula aplicabilă
recurring-refusal-end-required = În cazul unei date de sfârșit, data trebuie introdusă
recurring-refusal-end-before-start = Data de sfârșit nu poate fi mai mică decât data următoarei operațiuni
recurring-refusal-end-too-far = Diferența dintre data următoarei operațiuni și data de sfârșit nu poate depăși 10 000 de zile

# --- Faza 15 — tipăririle și rapoartele --------------------------------
# Titlul mare al benzii, preluat cuvânt cu cuvânt din raportul WinDev original.
print-operations-title = Lista tranzacțiilor bancare și a suboperațiunilor
print-menu-operations-pdf = Tipărire în fișier PDF
print-recap-title = Recapitulare pe categorii
print-recap-count = Rânduri
print-row-count = Număr de rânduri:
print-total-debit = Total debit:
print-total-credit = Total credit:
print-final-balance = Sold final:
print-licence = Radinus este software liber distribuit sub licența GNU GPL v3 sau ulterioară
print-nothing = Nu este nimic de tipărit.
print-done = Raport tipărit și deschis: „{ $file }”.
print-failed = Tipărire imposibilă: { $reason }
# PDF-ul este scris cum trebuie, dar sistemul nu a știut să îl deschidă: o
# spunem fără a lăsa impresia unui eșec, de vreme ce fișierul este acolo.
print-not-opened = Raport tipărit în „{ $file }”, dar sistemul dumneavoastră nu a știut să îl deschidă singur.

# --- Raportul RIB (F32) ------------------------------------------------
# Titulaturile extrasului de identitate bancară, preluate din documentul original.
rib-title = COORDONATE BANCARE
rib-bank = Bancă:
rib-national = RIB - Identificator național de cont
rib-establishment = INSTITUȚIE
rib-branch = GHIȘEU
rib-number = NUMĂR DE CONT
rib-key = CHEIE RIB
rib-domiciliation = DOMICILIERE
rib-iban = IBAN - Identificator internațional de cont
rib-bic = BIC - Identificator internațional al instituției
rib-holder = Titularul contului

# --- Fereastra F32 -----------------------------------------------------
window-rib-title = Tipărire de RIB ( Coordonate Bancare )
rib-group-bank = Bancă
rib-group-holder = Titularul contului
rib-group-details = Coordonate bancare
rib-field-bank = Nume bancă
rib-field-domiciliation = Domiciliere
rib-field-holder = Numele titularului
rib-field-address = Adresă
rib-field-establishment = Instituție
rib-field-branch = Ghișeu
rib-field-number = Număr cont
rib-field-key = Cheie RIB
rib-field-bic = BIC (Bank Identifer Code)
rib-field-iban = IBAN (International Bank Account Number )
rib-conditions = Condiții de utilizare importante, de respectat obligatoriu în caz de tipărire
rib-declaration = Subsemnatul, utilizator al programului, declar pe propria răspundere:
rib-declaration-first = - Confirm că am verificat la banca mea că informațiile bancare cuprinse în această fereastră sunt corecte și conforme cu voința mea . Confirm în același fel că mă angajez să verific că informațiile cuprinse în raportul tipărit al RIB-ului sunt corecte și conforme cu voința mea. Această tipărire și utilizarea RIB-ului se vor face pe deplina mea răspundere
rib-declaration-second = - Că sunt titularul contului al cărui RIB va fi tipărit și că nu voi folosi funcțiile acestui program într-un scop contrar legii.
rib-title-print = Tipărire la imprimantă
rib-title-pdf = Tipărire în fișier PDF
# Căsuța nu este un avertisment decorativ: cât timp nu este bifată, cele
# două butoane sunt stinse (arbitrajul lui Fabrice, 01/08/2026).
rib-declaration-required = Bifați declarația pe propria răspundere pentru a putea tipări.
rib-help = Verificați-vă coordonatele, bifați declarația, apoi tipăriți.
rib-account-gone = Acest cont bancar nu poate fi găsit.
rib-fields-read-only = Aceste coordonate provin din fișa contului: corectați-le în fișă pentru a le schimba aici.
rib-printed = RIB trimis la imprimanta dumneavoastră implicită.
rib-print-failed = Tipărire imposibilă: { $reason }
rib-pdf-done = RIB tipărit și deschis: „{ $file }”.
rib-pdf-not-opened = RIB tipărit în „{ $file }”, dar sistemul dumneavoastră nu a știut să îl deschidă singur.
menu-accounts-bank-details = Editare coordonate bancare

# Alegerea imprimantei. Radinus pune el însuși întrebarea: niciunul dintre
# cele trei webview-uri nu deschide dialogul de tipărire al sistemului.
print-choose-printer = La ce imprimantă doriți să tipăriți?
print-do-print = Tipărire
rib-printed-on = RIB trimis la imprimanta „{ $printer }”.
ui-cancel = Anulare

# Sistemul nu a știut să numească nicio imprimantă: tipărim oricum la cea
# implicită, în loc să blocăm utilizatorul.
print-printers-unknown = Sistemul dumneavoastră nu a știut să numească nicio imprimantă: documentul a plecat la imprimanta implicită.

print-menu-operations-printer = Tipărire la imprimantă
print-sent-on = Raport trimis la imprimanta „{ $printer }”.
print-sent-default = Raport trimis la imprimanta dumneavoastră implicită.

# --- Faza 17 — operațiunile asupra bazei de date ------------------------
backup-archive = Arhivă Radinus
backup-no-database = Nicio bază de date nu este deschisă.
backup-done = Copia de siguranță a bazei „{ $base }” a fost scrisă în „{ $file }”. Celelalte baze nu sunt afectate.
backup-failed = Copie de siguranță imposibilă: { $reason }
backup-not-started = Copia de siguranță nu a putut fi începută:
restore-unreadable = Acest fișier nu este o arhivă Radinus lizibilă: { $reason }
# Întrebarea spune ce se va pierde înainte de a se pierde. Arhiva a fost deja
# citită în acel moment: ceea ce anunță este sigur.
restore-question = Restaurați „{ $file }” în baza „{ $base }”? Tot conținutul actual al acestei baze va fi șters și înlocuit, iar ceea ce se află în ea va fi pierdut. Celelalte baze nu sunt atinse.
restore-done = Baza „{ $base }” a fost restaurată: { $accounts } conturi și { $operations } operațiuni. Celelalte baze nu sunt atinse.
restore-failed = Restaurare imposibilă: { $reason }
restore-empty-fields = Câmpuri goale citite ca valoare nulă: { $count }.


# --- Jurnalul operațiunilor tehnice (faza 17) ---------------------------
# Cele trei stări ale funcției sale Ajoute_Log, cu majuscule ca la el.
journal-status-success = SUCCES
journal-status-failure = EȘEC
journal-status-repaired = REPARAT
journal-step-reindex = Reparare tabel bază de date
journal-step-refill = Nomenclator de sistem gol: valori implicite restabilite
journal-step-table-created = Tabel absent din bază: recreat gol
journal-step-column-added = Coloană absentă din tabel: adăugată cu valoarea sa implicită

# --- Protection par mot de passe (05/08/2026) ---
password-protect = Protecție prin parolă
window-password-form-title = Protecție prin parolă
password-ask = Această bază este protejată. Introduceți parola ei.
password-group-database = Baza vizată
password-group-password = Parolă
password-group-warning = Înainte de a confirma
password-field-old = Parola veche
password-field-new = Parola nouă
password-field-repeat = Repetați parola nouă
password-hint = Lăsați parola veche goală dacă baza nu este încă protejată. Lăsați ambele parole noi goale pentru a retrage protecția.
password-lost-warning = O parolă pierdută este o bază pierdută: nimic nu o poate recupera. Copiile de siguranță, în schimb, rămân necriptate.
password-show = Afișează parola
password-remove-question = Retrageți protecția acestei baze?
password-mismatch = Cele două introduceri ale parolei noi sunt diferite
password-wrong = Parola nu se potrivește
database-too-recent = Această bază a fost salvată de o versiune mai recentă de Radinus (versiunea bazei { $found }; această versiune citește până la versiunea { $supported }). Actualizați Radinus pentru a o deschide.
database-not-radinus = Acest fișier nu este o bază Radinus.
database-unreadable = Baza nu a putut fi citită: { $reason }
password-close-first = Închideți această bază înainte de a-i schimba parola
password-now-protected = Baza este protejată printr-o parolă
password-now-clear = Baza nu mai este protejată
journal-step-date-fixed = Corectarea unei operațiuni fără dată
journal-step-circular = Ștergerea unei operațiuni incoerente: referință circulară
journal-step-flag-parent-true = Indicator greșit EstParent=Fals pe o operațiune principală
journal-step-flag-parent-false = Indicator greșit EstParent=Adevărat pe o operațiune principală
journal-step-flag-child = Indicator greșit EstParent=Adevărat pe o suboperațiune
journal-step-orphan = Ștergerea unei suboperațiuni orfane
journal-step-third-level = Ștergerea unei suboperațiuni atașate unei alte suboperațiuni
journal-step-coherence = Recalcularea generală a coerenței dintre suboperațiuni și operațiunile principale
journal-step-balances = Recalcularea tuturor soldurilor tuturor conturilor
journal-step-vacuum = Optimizarea fișierului bazei de date
journal-step-analyze = Actualizarea statisticilor de căutare
journal-step-backup-begin = Începutul copiei de siguranță a bazei
journal-step-backup-end = Sfârșitul copiei de siguranță a bazei
journal-step-restore-begin = Începutul restaurării bazei din arhivă
journal-step-restore-end = Sfârșitul restaurării bazei din arhivă
journal-step-restore-read = Citirea arhivei

# --- Fereastra jurnalului (⌘H) ------------------------------------------
window-journal-title = Jurnalul ultimei operațiuni tehnice
journal-column-step = Etapă
journal-column-file = Fișier
journal-column-table = Tabel
journal-column-status = Stare
journal-column-error = Eroare
journal-column-comments = Comentarii
journal-empty = Nicio operațiune tehnică nu a fost încă efectuată de la deschiderea programului.
journal-help = Jurnalul păstrează doar ultima operațiune tehnică: copie de siguranță, restaurare, reparare, ștergere sau deschiderea unei baze.

# --- Repararea ----------------------------------------------------------
menu-file-repair-running = Reparare și optimizare în curs…
repair-done = { $anomalies ->
    [0] Repararea bazei „{ $base }” s-a încheiat: nicio anomalie găsită. Etape jurnalizate: { $lines }. Celelalte baze nu sunt afectate.
    [one] Repararea bazei „{ $base }” s-a încheiat: o anomalie reparată. Etape jurnalizate: { $lines }. Celelalte baze nu sunt afectate.
    [few] Repararea bazei „{ $base }” s-a încheiat: { $anomalies } anomalii reparate. Etape jurnalizate: { $lines }. Celelalte baze nu sunt afectate.
   *[other] Repararea bazei „{ $base }” s-a încheiat: { $anomalies } de anomalii reparate. Etape jurnalizate: { $lines }. Celelalte baze nu sunt afectate.
}
repair-failed = Reparare imposibilă: { $reason }

journal-status-started = ÎN CURS
journal-status-finished = TERMINAT
journal-step-backup-table = Scrierea tabelului în arhivă
journal-step-backup-write = Scrierea arhivei
journal-step-backup-verified = Verificarea arhivei scrise: fișiere recitite / așteptate, înregistrări recitite / scrise
journal-step-backup-total = Total salvat: înregistrări, date, dimensiunea fișierului
journal-step-restore-table = Citirea tabelului din arhivă
journal-step-restore-missing = Fișier absent din arhivă: acest tabel nu va fi restaurat
journal-step-restore-wipe = Ștergerea totală a conținutului bazei înainte de restaurare
journal-step-restore-write = Scrierea în bază
journal-step-restore-total = Total restaurat: conturi, operațiuni
journal-step-restore-empty-fields = Câmpuri goale completate la citire
backup-verify-mismatch = Arhiva scrisă nu se recitește așa cum a fost scrisă: nu vă bazați pe ea, refaceți copia de siguranță.

# --- Atașamentele unei operațiuni (F28, faza 17) ------------------------
window-attachments-title = Atașamentele operațiunii
attachment-filter = Documente acceptate
attachment-none = Această operațiune nu poartă niciun atașament.
attachment-title-add = Atașarea unui document la această operațiune
attachment-title-open = Deschiderea atașamentului
attachment-title-remove = Retragerea atașamentului și trimiterea fișierului său la coșul de gunoi
# Starea fișierului pe disc. „Neverificabil” nu este o recunoaștere gratuită a
# ignoranței: amprentele venite din Radinus 1.9.3 sunt trunchiate de formatul
# de salvare, iar a judeca un fișier după ele ar însemna a acuza la întâmplare.
attachment-state-ok = Intact
attachment-state-changed = Modificat
attachment-state-missing = Fișier absent
attachment-state-unknown = Neverificabil
attachment-added = „{ $name }” a fost atașat la operațiune.
attachment-removed = Atașament retras, fișierul său este în coșul de gunoi.
attachment-removed-kept = Atașament retras, dar fișierul său nu a putut fi pus în coșul de gunoi.
attachment-remove-question = Retrageți „{ $name }” din această operațiune? Fișierul său va fi trimis la coșul de gunoi.
attachment-opened = „{ $name }” a fost deschis.
attachment-opened-changed = „{ $name }” a fost deschis, dar conținutul său s-a schimbat de când a fost atașat.
attachment-gone = Acest atașament nu mai există.
attachment-file-missing = Fișierul lui „{ $name }” nu poate fi găsit pe disc.
attachment-failed = Operațiune imposibilă: { $reason }
attachment-save-first = Salvați mai întâi operațiunea: un atașament se leagă de o operațiune care există.
attachment-refusal-missing = Acest fișier nu există.
attachment-refusal-extension = Acest tip de fișier nu este acceptat. Sunt acceptate: pdf, jpeg, jpg, png, bmp, tiff, gif, webp, xls, xlsx, doc, docx, odt, rtf, txt, json, xml.
attachment-refusal-operation = Operațiunea la care să fie atașat acest document nu există.
journal-step-backup-attachments = Atașamente adăugate în arhivă
journal-step-backup-attachment-missing = Atașament negăsit pe disc: va lipsi din arhivă
journal-step-restore-attachments = Atașamente scoase din arhivă
attachment-title-replace = Înlocuirea documentului acestui atașament
attachment-replaced = Documentul a fost înlocuit cu „{ $name }”.

# ---------------------------------------------------------------------
# F08 — meniul „Instrumente” al fișei contului.
#
# Cele trei intrări ale sale sunt portări ale WLangage-ului lui Fabrice
# (folderul „Information import export base piece jointe”): calculul
# soldului inițial reconciliat, statisticile contului și ștergerea tuturor
# tranzacțiilor sale. Meniul acționează doar în modificare (arbitrajul din
# 02/08/2026): la creare nu este nimic de numărat, în consultare fișa
# doar arată.
# ---------------------------------------------------------------------

account-tools = Instrumente
account-tools-initial-balance = Definirea soldului inițial reconciliat
account-tools-statistics = Statistici cont bancar
account-tools-delete-operations = Ștergerea tuturor tranzacțiilor contului

# Întrebarea calculului, cuvânt cu cuvânt cea din original. { $total } este
# totalul operațiunilor reconciliate, deja scris în format monetar.
account-initial-balance-question =
    Pentru a calcula soldul inițial reconciliat în raport cu operațiunile prezente în acest cont, vă rugăm să indicați soldul actual de la banca dumneavoastră
    Soldul inițial reconciliat va fi calculat ca fiind egal cu:
    { "[" }Sold bancar actual] - [Total operațiuni reconciliate ({ $total }) ].
    { "" }
    Pentru a nu fi nevoit să reintroduceți această valoare, trebuie să fiți complet la zi cu lista operațiunilor bancare din acest cont.

account-statistics-none = Nicio tranzacție

# Cele paisprezece rânduri ale funcției sale Info(). Greșeala de tipar
# „pengagés” din original este corectată, prin decizia lui Fabrice din
# 02/08/2026 — ca și „Bank Identifer Code” de pe aceeași fișă.
account-statistics =
    Numărul total de tranzacții din acest cont: { $count }
    { "" }
    Numărul de tranzacții reconciliate din acest cont: { $pointed }
    Suma debitelor reconciliate: { $pointedDebits }
    Suma creditelor reconciliate: { $pointedCredits }
    Diferența dintre creditele și debitele reconciliate: { $pointedDifference }
    { "" }
    Numărul de tranzacții angajate din acest cont: { $committed }
    Suma debitelor angajate: { $committedDebits }
    Suma creditelor angajate: { $committedCredits }
    Diferența dintre creditele și debitele angajate: { $committedDifference }
    { "" }
    Numărul de tranzacții planificate din acest cont: { $planned }
    Suma debitelor planificate: { $plannedDebits }
    Suma creditelor planificate: { $plannedCredits }
    Diferența dintre creditele și debitele planificate: { $plannedDifference }
    { "" }
    Cea mai veche tranzacție: { $first }
    Cea mai recentă tranzacție: { $last }

# Dubla barieră a ștergerii. { $word } este „da”-ul limbii curente — un
# vorbitor de spaniolă căruia i s-ar cere să scrie OUI nu ar înțelege
# (decizie a lui Fabrice, 02/08/2026).
account-delete-operations-question =
    Sunteți sigur că doriți să ștergeți toate operațiunile conținute în contul bancar?
    Pentru a confirma, scrieți { $word } în câmpul de mai jos și confirmați

account-delete-operations-done =
    { $count ->
        [0] Nicio tranzacție ștearsă.
        [one] O tranzacție ștearsă.
        [few] { $count } tranzacții șterse.
       *[other] { $count } de tranzacții șterse.
    }

# ---------------------------------------------------------------------
# Selectorul de bază și alegerea limbii (02/08/2026)
#
# Decizii luate în discuție cu Fabrice: Radinus nu mai creează o bază
# fără autorizație; fără limbă în configurație, el cere limba înaintea
# tuturor celorlalte; este bază orice folder din databases/ care conține
# un radinus.sqlite, oricare i-ar fi numele.
#
# Fereastra alegerii limbii nu are nicio cheie aici: ea nu folosește
# nicio frază, și tocmai asta îi permite să fie înțeleasă înainte să se
# știe ce limbă vorbește utilizatorul.
# ---------------------------------------------------------------------

window-database-selector-title = Baze de date
window-database-form-title = Bază de date nouă
database-group-identity = Identificarea bazei de date
database-group-restore = Inițializarea bazei cu datele dintr-o copie de rezervă
database-choose-backup = Selectarea fișierului copiei de rezervă
database-no-backup = Nicio copie aleasă: baza se va crea goală.

databases-column-label = Bază
databases-column-comment = Comentariu
databases-column-folder = Folder
databases-column-created = Creată la

databases-none = Nicio bază deocamdată: creați una.
databases-help = Alegeți baza de deschis, sau creați una nouă.
databases-select = Alegeți mai întâi o bază din listă.
databases-tools = Instrumente
databases-title-open = Deschiderea acestei baze

database-created = Baza „{ $label }” este creată.
database-field-label = Numele bazei
database-field-comment = Comentariu
database-label-required = Dați un nume acestei baze: el este cel care o va deosebi de celelalte.
database-gone = Această bază nu mai este acolo: a fost mutată sau ștearsă de la deschiderea acestei ferestre.

# Ștergerea unei baze (02/08/2026). Folderul pleacă la coșul de gunoi al
# sistemului, ca și atașamentele: o bază ștearsă din greșeală se pune la loc
# cu un clic dreapta. Baza deschisă este refuzată — Radinus își ține fișierul.
databases-title-delete = Ștergerea acestei baze
database-delete-question =
    Sunteți sigur că doriți să ștergeți baza „{ $label }”?
    { "" }
    Tot folderul ei pleacă la coșul de gunoi: operațiunile, conturile și atașamentele.
    Pentru a confirma, scrieți { $word } în câmpul de mai jos și confirmați.
database-in-use = Această bază este deschisă: Radinus nu o poate șterge. Deschideți mai întâi alta.
database-deleted = Baza „{ $label }” este la coșul de gunoi.

# Selectorul are două moduri (Fabrice, 02/08/2026). Deschis în timpul
# utilizării, el nu mai știe să deschidă: o fereastră a lui Radinus este
# construită o dată și niciodată distrusă, și nimic nu ar putea s-o facă să
# uite baza pe care o arată. Se consultă, se creează, se șterge — iar pentru a
# schimba baza, se iese.
database-quit-first = Pentru a deschide această bază, închideți Radinus și relansați-l: selectorul v-o va propune la pornire.


# --- F01 — fereastra de întâmpinare (faza 17 bis, 03/08/2026) -------------
#
# Prima adăugire a versiunii 2.0.0 peste 1.9.3: fereastra de întâmpinare nu mai
# poartă doar bannerul. Regula care o guvernează este scrisă în documentul
# 04 F01: este vederea FĂRĂ NICIUN CLIC, și nimic din ce cere un reglaj nu
# intră aici.
#
# Cele două titluri de diagramă inelară poartă luna întreagă în loc să fie
# lipite cap la cap de fereastră: „Cheltuieli ... — august 2026” nu are aceeași
# ordine a cuvintelor în cele trei limbi, și doar Fluent știe unde este gaura.

window-main-title = Radinus
welcome-month = { $month } { $year }
welcome-accounts-count = { $count ->
    [0] Niciun cont deschis
    [one] Un cont deschis
    [few] { $count } conturi deschise
   *[other] { $count } de conturi deschise
}
welcome-total-bank = Sold bancar
welcome-total-real = Sold real
welcome-total-final = Sold final
welcome-total-real-detail = reconciliat + angajat
welcome-total-final-detail = reconciliat + angajat + planificat
welcome-accounts = Conturile dumneavoastră
# The tick box of an account on the home window (Fabrice, 07/10/2026), and the
# line that says so when not every account is counted. No plural on purpose:
# « counted: 3 of 5 » reads the same whatever the numbers.
welcome-accounts-counted = Conturi luate în calcul la totaluri: { $count } din { $total }
welcome-tile-counted = Ia acest cont în calcul la totaluri
welcome-tile-bank = În bancă
welcome-tile-real = Real
welcome-tile-final = Final
welcome-spending = Cheltuieli — { $month }
welcome-earning = Venituri — { $month }
ui-legend-budget-lines = Poziții bugetare
ui-legend-categories = Categorii
welcome-nothing = Nicio operațiune în această lună.
welcome-open-account = Info: faceți clic pe un cont pentru a-i deschide operațiunile.
welcome-no-account = Niciun cont bancar deocamdată.
welcome-no-account-create = Creați un cont bancar făcând clic aici
welcome-previous-month = Luna precedentă
welcome-next-month = Luna următoare
welcome-refresh = Recitire completă


# --- F39 — preferințele (faza 17 ter, 03/08/2026) -------------------------
#
# Locul semnului monetar trăiește aici, alături de cei doi separatori: el
# urmează limba și nu moneda. „before” pune semnul înaintea numărului, orice
# altă valoare îl pune după. NICIUN semn monetar nu este scris în acest
# fișier: „franceză” nu înseamnă „euro”.

ui-money-sign-position = after
window-preferences-title = Preferințe
menu-settings-preferences = Preferințe…
menu-settings-show-main = Afișarea ferestrei principale
menu-settings-folders = Dosarele Radinus
preferences-branch-display = Afișare
preferences-leaf-language = Limbă
preferences-leaf-currency = Monedă
preferences-field-language = Limba programului:
preferences-field-currency = Moneda afișată:
preferences-field-custom = Semnul monedei:
preferences-currency-system = Moneda sistemului
preferences-currency-euro = Euro
preferences-currency-dollar = Dolari
preferences-currency-canadian = Dolari canadieni
preferences-currency-cfa = Franci CFA
preferences-currency-cfp = Franci Pacific
preferences-currency-swiss = Franci elvețieni
preferences-currency-none = Niciuna
preferences-currency-custom = Personalizat
preferences-currency-system-is = Sistemul dumneavoastră anunță:
preferences-currency-system-silent = Sistemul dumneavoastră nu anunță nicio monedă: sumele se vor afișa în euro.
preferences-custom-required = Tastați semnul monedei dumneavoastră înainte de a salva.
preferences-saved = Preferințe salvate.
preferences-help = Alegeți o opțiune în arbore, apoi salvați.
preferences-sign-too-long = Semnul unei monede încape în cel mult 8 caractere.
preferences-sign-not-a-number = Semnul unei monede nu poate conține nici cifre, nici semne de calcul, nici virgule: Radinus le retrage când citește o sumă, iar „120” ar deveni „12”.
preferences-leaf-zoom = Mărimea afișării
preferences-field-zoom = Mărire:
preferences-zoom-reset = Valoare implicită
preferences-zoom-hint = Totul se mărește împreună: textul, pictogramele, coloanele. Sub 100 %, încape mai mult pe ecran. Bara de meniuri a sistemului și casetele lui de dialog, în schimb, urmează reglajele calculatorului dumneavoastră și nu pe acestea.
preferences-branch-import = Import
preferences-leaf-verification = Verificare
preferences-field-verification = Operațiuni importate:
preferences-verification-hint = „Verificată”: aveți încredere în banca dumneavoastră, o operațiune importată este considerată corectă. „De verificat”: fiecare operațiune importată așteaptă controlul dumneavoastră; apoi o treceți chiar dumneavoastră la „Verificată” în lista operațiunilor. Această setare se aplică numai importurilor viitoare.
preferences-leaf-ofx = Extrase de cont OFX
preferences-field-ofx-label = Descrierea operațiunii:
preferences-field-ofx-reference = Referință plată:
preferences-ofx-choice-name = Numele operațiunii
preferences-ofx-choice-memo = Nota băncii
preferences-ofx-choice-name-and-memo = Numele urmat de notă
preferences-ofx-choice-empty = Nimic (lăsați gol)
preferences-ofx-label-help = Ce primește descrierea unei operațiuni importate. Numele este cel afișat de bancă, de exemplu „PRLV SEPA”; unele bănci adaugă o notă detaliată: creditorul unui debit direct, beneficiarul și motivul unui transfer. Când o operațiune nu are notă, descrierea ei păstrează numele.
preferences-ofx-reference-help = Ce primește referința de plată a unei operațiuni importate, unde o puteți vedea și filtra. Când o operațiune nu are notă, opțiunea „Nota băncii” lasă referința goală. Dacă nota repetă deja numele, ea nu este scrisă de două ori.
preferences-ofx-hint = Aceste setări se aplică tuturor extraselor de cont OFX, oricare ar fi baza de date deschisă. Ele intră în vigoare la următorul extras de cont deschis.
preferences-leaf-qif = Extrase de cont QIF
preferences-field-qif-order = Ordinea zilei și a lunii:
preferences-qif-order-ask = Întrebați-mă de fiecare dată
preferences-qif-order-day-month = Întotdeauna zi/lună (05/03 = 5 martie)
preferences-qif-order-month-day = Întotdeauna lună/zi (05/03 = 3 mai)
preferences-qif-order-help = Se folosește doar dacă nicio dată din fișier nu permite stabilirea ordinii. De îndată ce o dată precum 24/11 dovedește ordinea, decide fișierul, oricare ar fi această setare.
preferences-field-qif-label = Descrierea operațiunii:
preferences-qif-label-both = Terț + notă
preferences-qif-label-payee = Doar terțul
preferences-qif-label-memo = Doar nota
preferences-qif-label-help = Când o operațiune are atât un terț, cât și o notă. Dacă are doar unul dintre ele, acela este folosit, oricare ar fi această setare.
preferences-qif-hint = Aceste setări se aplică tuturor extraselor de cont QIF, oricare ar fi baza de date deschisă. „Întrebați-mă de fiecare dată” este varianta cea mai sigură: un fișier cu date ambigue nu este niciodată citit la întâmplare.

# The columns of a table (Fabrice, 04/10/2026): each user has his own. The
# first is the last entry of the right-click menu on a table's header; the
# others are the « Table columns » leaf of the preferences, one line per
# table whose columns can be arranged, a « Reset » button facing it.
columns-reset = Restabilește coloanele implicite
# The header menu's two sub-menus (Fabrice, 05/10/2026). « columns-colour » is
# followed by the column's own title, hence its colon. Then the nine tints a
# column can take, and the entry that takes it off.
columns-show-hide = Afișează/Ascunde
columns-colour = Colorează coloana:
columns-colour-none = Nicio culoare
columns-colour-red = Roșu
columns-colour-orange = Portocaliu
columns-colour-pink = Roz
columns-colour-pastel-green = Verde pastel
columns-colour-green = Verde
columns-colour-pastel-blue = Albastru pastel
columns-colour-blue = Albastru
columns-colour-pastel-yellow = Galben pastel
columns-colour-yellow = Galben
preferences-leaf-columns = Coloanele tabelelor
preferences-table-operations-list = Lista operațiunilor
preferences-columns-reset = Reinițializează
preferences-columns-reset-all = Reinițializează tot
preferences-columns-done = Coloanele au revenit la dispunerea inițială.
preferences-columns-hint = Fiecare tabel reține ordinea coloanelor, pe cele pe care le ascundeți și lățimea lor. „Reinițializează” îi redă imediat dispunerea inițială.

# The reset of the comfort settings (Fabrice, 07/10/2026): columns, home
# window, display size — and nothing else.
preferences-branch-reset = Reinițializare
preferences-leaf-comfort = Setări de confort
preferences-comfort-reset = Reinițializează setările de confort
preferences-comfort-hint = Readuce la starea inițială coloanele tuturor tabelelor, ordinea și casetele conturilor din fereastra de pornire și mărimea afișării. Limba, moneda și verificarea operațiunilor importate nu sunt modificate.
preferences-comfort-question = Reinițializați setările de confort? Coloanele tabelelor, fereastra de pornire și mărimea afișării vor reveni la starea inițială.
preferences-comfort-done = Setările de confort au fost reinițializate.

# --- Bannerul ferestrei de întâmpinare ------------------------------------
#
# Aceste fraze erau scrise direct în `index.html` încă de la faza 0 și nu se
# traduceau, prin urmare (semnalat de Fabrice pe 03/08/2026). Deviza este
# vocea sa: versiunile engleză și spaniolă sunt propuneri, de corectat de
# către el — un slogan nu se traduce cuvânt cu cuvânt.
ui-language-tag = ro
welcome-banner-title = Radinus
welcome-mascot-alt = Radinus — veverița mascotă, în costum, înconjurată de un euro, un calculator de birou și grafice
welcome-slogan-one = Un program de gestiune a finanțelor personale care vă ajută să cheltuiți mai puțin pentru a câștiga mai mult
welcome-slogan-two = Cu Radinus veți înțelege de ce pâraiele mici fac râurile mari.

# --- „Despre autor” -------------------------------------------------------
#
# Numele și adresa sunt scrise identic în cele trei fișiere: ele nu se traduc.
# Sunt totuși aici, și nu în pagină, pentru ca vederea să nu poarte nicio
# frază — și pentru ca ele să se corecteze într-un singur loc în ziua în care
# autorul se mută.
about-author-name = Auteur : Fabrice Garcia
about-author-place = 20290 Borgo, Corsica, France
window-about-author-title = Despre autor
about-author-flag-alt = Steagul Corsicii — capul de maur

# --- „Despre Radinus” -----------------------------------------------------
#
# `about-radinus-version` poartă o gaură: numărul vine din binarul care
# rulează, niciodată dintr-un șir recopiat. Ea nu este deci în dicționarul
# ferestrelor — comanda `app_version` este cea care o completează.
window-about-radinus-title = Despre Radinus
about-radinus-name = Radinus
about-radinus-version = Versiunea { $version }
about-radinus-rust-alt = Logoul limbajului Rust
about-radinus-tauri-alt = Logoul Tauri
about-radinus-built = Radinus este scris în Rust și construit cu Tauri. Primul vă calculează conturile, al doilea face din el o aplicație de birou.
about-radinus-licence = Software liber, sub licență GNU GPL v3.

# --- « Licence d'utilisation » (08/08/2026) -------------------------------
#
# The window names the licence and says, in four lines, what it gives the
# person using Radinus. The legal text itself is not translated here: the
# button opens the official page, published and maintained by the Free
# Software Foundation, which knows its own wording better than we do.
window-licence-title = Licență de utilizare
licence-heading = LICENȚA DE UTILIZARE A PROGRAMULUI RADINUS
licence-logo-alt = Logoul GNU General Public License versiunea 3
licence-name = GNU GPL v3 sau ulterioară
licence-intro = Radinus este software liber.
licence-freedoms-title = Licența sa vă oferă patru libertăți:
licence-freedom-use = Să îl folosiți cum doriți, pentru ce doriți.
licence-freedom-study = Să îi studiați codul sursă, deschis tuturor.
licence-freedom-share = Să îl copiați și să îl dați altora.
licence-freedom-improve = Să îl modificați și să vă împărtășiți modificările.
licence-read = Citiți textul complet al licenței

# The two notices the GPL asks an interactive interface to display, next
# to the right to redistribute and the way to read the licence, which the
# window already carried (LICENSE, definition of « Appropriate Legal
# Notices »). The copyright is a name and a year: identical everywhere,
# here all the same so that the view holds no sentence of its own.
licence-copyright = Copyright © 2026 Fabrice Garcia
licence-no-warranty = Acest program este furnizat fără nicio garanție, în măsura permisă de lege.
licence-info = Textul oficial se deschide în browserul dumneavoastră, pe gnu.org.

# --- F41 — Simulation de crédit (Fabrice, 08/10/2026) ------------------------
# Le calcul d'un prêt à taux fixe, et ce que l'historique de la base dit de la
# capacité à le rembourser. Les phrases sont écrites par le noyau ; la fenêtre
# n'en compose aucune.
menu-tools-loan-simulation = Simulare de credit
window-loan-title = Simulare de credit
loan-tab-credit = Creditul
loan-tab-afford = Îl pot rambursa?
loan-field-kind = Tipul creditului
loan-kind-consumer = Credit de consum
loan-kind-mortgage = Credit imobiliar
loan-field-amount = Suma împrumutată
loan-field-payment = Rata lunară
loan-field-months = Durata
loan-field-rate = Dobândă fixă
loan-field-fees = Comision de analiză
loan-field-insurance = Asigurare pe lună
loan-unit-months = luni
loan-unit-percent = %
loan-invalid-field = Această valoare nu este un număr: corectați-o pentru a relua calculul.
loan-report-button = Raport PDF
loan-monthly-table = Tabel lună de lună
loan-months-count = { $count ->
        [one] { $count } lună
        [few] { $count } luni
       *[other] { $count } de luni
    }
loan-percent = { $value } %
loan-notice-payment-too-low = Această rată nu acoperă dobânda: creditul nu ar fi rambursat niciodată. Durata rămâne la 600 de luni.
loan-notice-too-long = Această rată ar necesita peste 600 de luni: durata rămâne la 600 de luni.
loan-figure-payment = Rata lunară
loan-figure-payment-insured = Rata cu asigurare
loan-figure-taeg = DAE
loan-figure-interest = Costul dobânzii
loan-figure-insurance = Costul asigurării
loan-figure-cost = Costul total al creditului
loan-figure-total-due = Suma totală datorată
loan-figure-all-in = Total rambursat, cu asigurare
loan-part-capital = Suma împrumutată
loan-part-interest = Dobândă
loan-part-fees = Comision de analiză
loan-part-insurance = Asigurare
loan-donut-cost-caption = în total
loan-chart-cost = Cât costă acest credit
loan-chart-capital = Capital rămas
loan-schedule-title = Grafic de rambursare
loan-schedule-yearly = Grafic de rambursare, an cu an
loan-column-number = Nr.
loan-column-year = An
loan-column-date = Scadență
loan-column-payment = Rată
loan-column-payments = Rate
loan-column-interest = Dobândă
loan-column-capital = Capital
loan-column-insurance = Asigurare
loan-column-remaining = Capital rămas
loan-history-label = Perioada studiată
loan-period-last-12 = Ultimele 12 luni
loan-accounts-title = Conturi studiate
loan-period-title = Perioadă
loan-column-account = Cont
loan-column-bank = Bancă
loan-column-balance = Sold real
loan-unavailable-no-account = Bifați cel puțin un cont pentru a vă studia istoricul.
loan-unavailable-no-month = Această perioadă nu are încă nicio lună completă: alegeți alta.
loan-verdict-title = Pe scurt
loan-verdict-green = Realizabil
loan-verdict-orange = La limită
loan-verdict-red = Riscant
loan-verdict-no-income = Niciun venit în această perioadă: gradul de îndatorare nu se poate calcula.
loan-check-debt-green = Grad de îndatorare { $ratio }: sub pragul de { $green } al acestei metode.
loan-check-debt-orange = Grad de îndatorare { $ratio }: între { $green } și { $red }, la limită.
loan-check-debt-red = Grad de îndatorare { $ratio }: peste { $red }.
loan-check-effort = Rata de { $payment } ia { $share } din ce puneți deoparte { $kind ->
        [good] într-o lună bună
        [hard] într-o lună grea
       *[usual] într-o lună obișnuită
    } ({ $margin }).
loan-check-effort-none = { $kind ->
        [good] O lună bună
        [hard] O lună grea
       *[usual] O lună obișnuită
    } nu vă lasă nimic deoparte: rata de { $payment } ar fi luată din rezerva dumneavoastră.
loan-check-reserve-green = Soldul dumneavoastră rămâne pozitiv până la sfârșitul creditului.
loan-check-reserve-red = Soldul dumneavoastră ar scădea sub zero în { $month }, din cauza acestui credit.
loan-check-reserve-sooner = Soldul dumneavoastră ar scădea sub zero în { $month }, cu { $count ->
        [one] o lună
        [few] { $count } luni
       *[other] { $count } de luni
    } mai devreme decât fără acest credit.
loan-check-reserve-anyway = Soldul dumneavoastră ar scădea sub zero în jurul lui { $month } chiar și fără acest credit, care nu schimbă aproape nimic.
loan-check-reserve-floor-green = Soldul dumneavoastră rămâne peste rezerva de siguranță ({ $floor }) până la sfârșitul creditului.
loan-check-reserve-floor-red = Soldul dumneavoastră ar scădea sub rezerva de siguranță ({ $floor }) în { $month }, din cauza acestui credit.
loan-check-reserve-floor-sooner = Soldul dumneavoastră ar scădea sub rezerva de siguranță ({ $floor }) în { $month }, cu { $count ->
        [one] o lună
        [few] { $count } luni
       *[other] { $count } de luni
    } mai devreme decât fără acest credit.
loan-check-reserve-floor-anyway = Soldul dumneavoastră ar scădea sub rezerva de siguranță ({ $floor }) în jurul lui { $month } chiar și fără acest credit, care nu schimbă aproape nimic.
loan-warning-deficit = Atenție: în această perioadă, cheltuielile dumneavoastră depășesc deja veniturile cu { $amount } pe lună în medie, înainte de orice credit.
loan-figure-reference = Economii { $kind ->
        [good] într-o lună bună
        [hard] într-o lună grea
       *[usual] într-o lună obișnuită
    }
loan-figure-tipped = Luni pe care creditul le-ar duce pe minus
loan-gauge-caption = îndatorare
loan-figure-income = Venituri medii pe lună
loan-figure-spending = Cheltuieli medii pe lună
loan-figure-saving = Economii medii pe lună
loan-figure-running = Credite în curs pe lună
loan-figure-new = Noua rată, cu asigurare
loan-figure-rest = De trai pe lună
loan-figure-debt = Grad de îndatorare
loan-red-months-value = { $count } din { $total }
loan-figure-balance-now = Sold real astăzi
loan-figure-balance-end = Sold estimat la sfârșitul creditului
loan-chart-income = Unde merge venitul dumneavoastră mediu
loan-donut-income-caption = venit mediu
loan-part-spending = Cheltuieli curente
loan-part-running = Credite în curs
loan-part-new = Credit nou
loan-part-rest = Rest
loan-part-missing = Lipsesc
loan-chart-history = Istoricul dumneavoastră cu acest credit
loan-chart-history-hint = Ce ar fi rămas în fiecare lună, după plata ratei. Cu roșu aprins, lunile pe care creditul le-ar duce pe minus; cu roșu pal, cele care erau deja pe minus fără el.
loan-chart-projection = Soldul dumneavoastră estimat
loan-mark-loan-end = Sfârșit: { $label }
loan-mark-negative = Pe minus
loan-mark-floor = Sub rezervă
loan-mark-floor-line = Rezervă de siguranță
loan-running-title = Credite în curs luate în calcul
loan-running-column-label = Operațiune periodică
loan-running-column-monthly = Pe lună
loan-running-column-end = Ultima rată
loan-no-running = Niciun credit în curs recunoscut printre operațiunile dumneavoastră periodice.
loan-period-caption = din { $from } până în { $to } ({ $count ->
        [one] { $count } lună
        [few] { $count } luni
       *[other] { $count } de luni
    })
loan-transfers = { $count ->
        [0] Niciun transfer între conturile bifate nu a fost recunoscut.
        [one] Un transfer între conturile bifate a fost recunoscut și pus deoparte.
        [few] { $count } transferuri între conturile bifate au fost recunoscute și puse deoparte.
       *[other] { $count } de transferuri între conturile bifate au fost recunoscute și puse deoparte.
    }
loan-method = Medii pe lunile complete ale perioadei, operațiuni punctate și angajate, fără transferurile între conturile bifate.
loan-report-title = Simulare de credit
loan-report-made-on = simulare din { $date }
loan-disclaimer = Simulare orientativă, fără valoare contractuală. Doar oferta băncii este obligatorie.
loan-tab-rules = Setările evaluării
loan-method-optimistic = Optimistă
loan-method-neutral = Neutră
loan-method-severe = Severă
loan-method-line = Metoda de evaluare: { $method }
loan-method-verdict = { $method }: { $verdict }
loan-rules-intro = Verdictul răspunde la trei întrebări, iar fiecare metodă își pune propriile exigențe. Alegeți-o pe cea care vi se potrivește: verdictul din fila „Îl pot rambursa?” o urmează. Ultimul rând presupune că cheltuielile dumneavoastră cresc în fiecare an cu procentul indicat; rata nu se schimbă.
loan-rule-row-debt = Îndatorare acceptată
loan-rule-row-reference = Economii de referință
loan-rule-row-share = Partea din aceste economii pe care o poate lua rata
loan-rule-row-floor = Pragul sub care soldul nu trebuie să coboare
loan-rule-row-sooner = Dacă soldul coboară sub el chiar și fără credit
loan-rule-row-growth = Creșterea cheltuielilor pe an
loan-rule-limits = verde până la { $green }, portocaliu până la { $red }
loan-rule-reference = { $kind ->
        [good] o lună bună
        [hard] o lună grea
       *[usual] o lună obișnuită
    }: { $amount }
loan-rule-floor-zero = zero
loan-rule-floor-cushion = o lună de cheltuieli: { $amount }
loan-rule-sooner = portocaliu dacă îl grăbește cu { $orange }, roșu cu { $red }
loan-unit-percent-year = % pe an
loan-method-optimistic-explain = Metoda optimistă presupune o lună bună, acceptă o îndatorare de până la 40 % și nu păstrează nicio rezervă: arată ce este posibil dacă totul merge bine.
loan-method-neutral-explain = Metoda neutră presupune o lună obișnuită și urmează regula băncilor, 33–35 % îndatorare: este evaluarea de referință.
loan-method-severe-explain = Metoda severă presupune o lună grea și păstrează o lună de cheltuieli ca rezervă pentru neprevăzut: arată ce rezistă chiar dacă lucrurile merg prost.

# --- F42 — Consommation d'un appareil électrique (Fabrice, 09/10/2026) -------
# Ce que coûte un appareil, allumé et en veille, en heures pleines et en
# heures creuses. Le tarif est une préférence de la base (« tarif.electricite »).
menu-tools-appliance-cost = Consumul unui aparat electric
window-appliance-title = Consumul unui aparat electric
appliance-device-title = Aparatul
appliance-on-title = Pornit
appliance-standby-title = În standby
appliance-field-on-watts = Putere în funcțiune
appliance-field-on-hours = Timp de funcționare pe zi
appliance-field-days = Zile de utilizare pe săptămână
appliance-field-share = Partea de funcționare în orele în afara vârfului
appliance-field-standby-watts = Putere în standby
appliance-field-standby-hours = Timp în standby pe zi de utilizare
appliance-unit-watts = W
appliance-unit-hours = h
appliance-unit-days = din 7
appliance-unit-percent = %
appliance-unit-price = { $sign }/kWh
appliance-standby-hint = Dacă rămâne gol, standby-ul durează restul zilei. În zilele fără utilizare, aparatul rămâne în priză: tot acest timp contează ca standby. Scos din priză, consumul său în standby este de 0 W.
appliance-contract-title = Contractul dumneavoastră
appliance-field-option = Opțiune tarifară
appliance-option-base = De bază (un singur preț)
appliance-option-off-peak = Ore de vârf / Ore în afara vârfului
appliance-field-base = Preț per kWh
appliance-field-peak = Preț per kWh în orele de vârf
appliance-field-off-peak = Preț per kWh în orele în afara vârfului
appliance-field-off-peak-hours = Ore în afara vârfului pe zi
appliance-contract-hint = Aceste prețuri sunt valabile doar pentru acest calcul. Tariful salvat se setează în Setări › Preferințe › Instrumente.
appliance-contract-reset = Revenire la tariful salvat
appliance-period-day = Pe zi
appliance-period-month = Pe lună
appliance-period-year = Pe an
appliance-energy = { $value } kWh
appliance-less-than = mai puțin de { $amount }
appliance-detail-title = Detaliul pe un an
appliance-column-part = Element
appliance-column-energy = Energie
appliance-column-cost = Cost
appliance-column-share = Pondere
appliance-line-on = Pornit
appliance-line-standby = În standby
appliance-line-on-peak = Pornit, ore de vârf
appliance-line-on-off-peak = Pornit, ore în afara vârfului
appliance-line-standby-peak = În standby, ore de vârf
appliance-line-standby-off-peak = În standby, ore în afara vârfului
appliance-line-total = Total
appliance-chart-title = Unde se duc banii
appliance-chart-caption = pe an
appliance-standby-sentence = Doar standby-ul costă { $amount } pe an: { $share } din costul aparatului.
appliance-note-plate = Puterea înscrisă pe aparat sau în manualul său este un maxim: în funcțiune, majoritatea aparatelor consumă mai puțin. Pentru o valoare reală, măsurați-o cu o priză wattmetru și introduceți ce indică aceasta.
appliance-note-subscription = Abonamentul nu este inclus: îl plătiți fie că aparatul este în priză, fie că nu.
appliance-invalid-watts = Vă rugăm să introduceți o putere între 0 și 100.000 W.
appliance-invalid-hours = Vă rugăm să introduceți o durată între 0 și 24 de ore pe zi.
appliance-invalid-days = Vă rugăm să introduceți un număr întreg de zile, între 0 și 7.
appliance-invalid-share = Vă rugăm să introduceți o pondere între 0 și 100%.
appliance-invalid-day-overflow = Funcționarea și standby-ul depășesc 24 de ore pe zi.
appliance-invalid-price = Vă rugăm să introduceți un preț per kWh între 0 și 100.
appliance-invalid-off-peak-hours = Vă rugăm să introduceți un număr întreg de ore în afara vârfului, între 0 și 24.
preferences-branch-tools = Instrumente
preferences-leaf-electricity = Tariful energiei electrice
preferences-electricity-blue = Revenire la Tarif Bleu EDF
preferences-electricity-hint = Tariful contractului dumneavoastră, folosit de instrumentul „Consumul unui aparat electric”. Implicit: Tarif Bleu de la EDF (Franța) la 1 august 2026, prețuri cu toate taxele incluse, contor de 3 până la 6 kVA. Aceste prețuri se schimbă adesea în februarie și august: copiați-le pe cele de pe factura dumneavoastră.

# --- F43 — Mon matelas de sécurité (Fabrice, 09/10/2026) -------------------------
# Combien de mois l'épargne tiendrait si les revenus s'arrêtaient. Les
# phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-safety-cushion = Fondul meu de urgență
window-cushion-title = Fondul meu de urgență
cushion-question = Dacă veniturile dumneavoastră s-ar opri mâine, câte luni ați rezista din economii?
cushion-accounts-title = Conturile dumneavoastră
cushion-column-account = Cont
cushion-column-balance = Sold real
cushion-column-savings = Economii
cushion-column-spending = Cheltuieli
cushion-accounts-hint = „Economii”: banii pe care contați în caz de necaz. „Cheltuieli”: conturile din care pleacă cheltuielile de zi cu zi.
cushion-history-label = Perioada analizată
cushion-backup-label = Venit de rezervă pe lună
cushion-backup-hint = Ce ar continua să intre: indemnizația de șomaj, salariul partenerului… Gol: niciun venit.
cushion-categories-title = Cheltuielile luate în calcul
cushion-categories-hint = Debifați ce ați tăia în caz de necaz.
cushion-categories-empty = Nicio cheltuială în această perioadă.
cushion-verdict-title = Fondul dumneavoastră
cushion-targets-title = Pragurile de prudență
cushion-projection-title = Economiile dumneavoastră în caz de necaz
cushion-projection-hint = Ce ar rămâne în fiecare lună dacă veniturile dumneavoastră s-ar opri astăzi.
cushion-note = O estimare bazată pe istoricul dumneavoastră: cheltuielile dintr-o lună dificilă pot diferi de medie.
cushion-invalid-backup = Această sumă nu poate fi citită: corectați-o pentru a relua calculul.
cushion-no-spending-account = Bifați cel puțin un cont „Cheltuieli”.
cushion-no-month = Această perioadă nu are încă nicio lună completă.
cushion-months = { $value } luni
cushion-per-month = { $amount } pe lună
cushion-figure-holds = Fără limită
cushion-gauge-caption = din cheltuieli acoperite
cushion-verdict-short = Mai puțin de trei luni: un necaz v-ar pune repede în dificultate.
cushion-verdict-fair = Între trei și șase luni: un fond corect, de întărit dacă puteți.
cushion-verdict-solid = Șase luni sau mai mult: fondul dumneavoastră este solid.
cushion-verdict-holds = Venitul de rezervă vă acoperă cheltuielile: economiile nu s-ar topi.
cushion-verdict-nothing = Nicio cheltuială luată în calcul în această perioadă: nu este nimic de acoperit.
cushion-tile-savings = Economii disponibile
cushion-tile-spending = Cheltuieli luate în calcul
cushion-tile-backup = Venit de rezervă
cushion-tile-burn = Economiile s-ar topi cu
cushion-tile-rhythm = Ritmul de economisire
cushion-burn-none = Nimic
cushion-target-title = { $months } luni de cheltuieli: { $amount }
cushion-target-reached = Atins.
cushion-target-date = Lipsesc { $missing }. În ritmul dumneavoastră de economisire, pragul va fi atins în jurul datei: { $month }.
cushion-target-never = Lipsesc { $missing }. Economiile dumneavoastră nu au crescut în această perioadă: în acest ritm, pragul nu va fi atins.
cushion-mark-empty = Economii epuizate: { $month }
cushion-period = Medie pe { $count ->
        [one] { $count } lună completă
        [few] { $count } luni complete
       *[other] { $count } de luni complete
    } (perioada: { $from } – { $to }). { $transfers ->
        [0] Niciun transfer între conturile dumneavoastră.
        [one] Un transfer între conturile dumneavoastră, exclus din calcul.
        [few] { $transfers } transferuri între conturile dumneavoastră, excluse din calcul.
       *[other] { $transfers } de transferuri între conturile dumneavoastră, excluse din calcul.
    }

# --- F44 — Objectif Épargne (Fabrice, 10/10/2026) --------------------------------
# Quand aurai-je ce montant, combien aurai-je à cette date, combien épargner.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-savings-goal = Obiectiv de economisire
window-goal-title = Obiectiv de economisire
goal-accounts-title = Conturile urmărite
goal-column-account = Cont
goal-column-balance = Sold real
goal-accounts-hint = Un transfer între două conturi urmărite se anulează; un transfer către un cont neurmărit contează ca o ieșire.
goal-period-label = Perioada de referință
goal-period-range = Interval de ani…
goal-range-from = de la
goal-range-to = până la
goal-question-title = Întrebarea dumneavoastră
goal-question-when = Când voi avea această sumă?
goal-question-amount = Cât voi avea la această dată?
goal-question-effort = Cât să economisesc ca să am această sumă la această dată?
goal-field-target = Suma țintă
goal-field-date = Data țintă
goal-field-rate = Dobânda anuală a economiilor
goal-field-extra = Și dacă aș economisi în plus, pe lună
goal-options-hint = Goale: fără dobândă, nimic în plus.
goal-answer-title = Răspunsul
goal-chart-title = Soldul dumneavoastră, ieri și mâine
goal-chart-hint = Linie continuă: soldul real din ultimele douăsprezece luni; linie punctată: proiecția; zona deschisă: intervalul în funcție de luni.
goal-disclaimer = O proiecție bazată pe istoricul dumneavoastră, nu o promisiune: un eveniment neprevăzut poate schimba totul.
goal-no-account = Bifați cel puțin un cont de urmărit.
goal-no-month = Această perioadă nu are încă nicio lună completă.
goal-invalid-target = Vă rugăm să introduceți o sumă de atins.
goal-invalid-date = Vă rugăm să alegeți o dată viitoare, în următorii cincizeci de ani.
goal-invalid-rate = Vă rugăm să introduceți o dobândă între 0 și 100 %.
goal-invalid-extra = Această sumă nu poate fi citită: corectați-o pentru a relua calculul.
goal-per-month = { $amount } pe lună
goal-tile-balance = Soldul de azi
goal-tile-rhythm = Ritmul mediu
goal-tile-target = Obiectiv
goal-tile-reached = Atins aproximativ în
goal-tile-date = Data țintă
goal-tile-projected = Sold proiectat
goal-tile-saved = Economisit până atunci
goal-tile-interest = Din care dobânzi
goal-tile-needed = De economisit
goal-when-already = Aveți deja { $amount }: conturile dumneavoastră urmărite totalizează { $balance }.
goal-when-reached = Veți avea { $amount } peste aproximativ { $months ->
        [one] o lună
        [few] { $months } luni
       *[other] { $months } de luni
    } (în jurul datei: { $month }).
goal-when-range = În funcție de luni, între { $early } și { $late }.
goal-when-range-open = Cel mai devreme în jurul datei: { $early }; cu luni slabe, obiectivul nu ar fi atins.
goal-when-never = În acest ritm, nu veți atinge { $amount }.
goal-zero = Soldul dumneavoastră ar scădea la zero în jurul datei: { $month }.
goal-amount = În { $month }, ați avea aproximativ { $amount }.
goal-amount-range = În funcție de luni, între { $low } și { $high }.
goal-effort-more = Pentru a avea { $amount } în { $month }, ar trebui să economisiți în medie { $monthly } pe lună, adică { $gap } mai mult decât acum.
goal-effort-less = Pentru a avea { $amount } în { $month }, ar ajunge { $monthly } pe lună, adică { $gap } mai puțin decât acum: sunteți în avans.
goal-effort-range = În funcție de luni, diferența față de ritmul dumneavoastră ar fi între { $low } și { $high } pe lună.
goal-chart-target = Obiectiv: { $amount }
goal-chart-today = Astăzi
goal-note-seasons = Proiecția urmează anotimpurile: fiecare lună viitoare preia media acelorași luni din perioadă.
goal-note-range = Intervalul provine din lunile slabe și din lunile puternice ale perioadei: sfertul cel mai de jos și sfertul cel mai de sus.
goal-note-loan = Creditul „{ $label }” se încheie în { $month }: { $amount } în plus pe lună după aceea.
goal-note-interest = Dobânda este calculată în fiecare lună la o rată de { $rate } % pe an: o aproximare a regulii chenzinelor de la conturile de economii.
goal-period = Ritm calculat pe { $count ->
        [one] { $count } lună completă
        [few] { $count } luni complete
       *[other] { $count } de luni complete
    } (perioada: { $from } – { $to }). { $transfers ->
        [0] Niciun transfer între conturile dumneavoastră urmărite.
        [one] Un transfer între conturile dumneavoastră urmărite, exclus din calcul.
        [few] { $transfers } transferuri între conturile dumneavoastră urmărite, excluse din calcul.
       *[other] { $transfers } de transferuri între conturile dumneavoastră urmărite, excluse din calcul.
    }

# --- F45 — Et si je réduisais… ? (Fabrice, 10/10/2026) ----------------------------
# Réduire des postes de dépense, et voir ce que ça change dans le temps.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-spending-cut = Și dacă aș reduce…?
window-cut-title = Și dacă aș reduce…?
cut-axis-label = Grupare după
cut-axis-category = Categorii
cut-axis-payee = Terți
cut-axis-budget-line = Poziții bugetare
cut-table-title = Cheltuielile dumneavoastră, poziție cu poziție
cut-table-hint = Introduceți o reducere în % sau în { $sign } pe lună la pozițiile pe care ați dori să le diminuați. O reducere nu poate depăși cheltuiala însăși.
cut-column-monthly = Pe lună
cut-column-cut = Reducere
cut-column-after = După
cut-column-yearly = Câștig pe an
cut-total = Total
cut-horizon-label = Orizont
cut-settings-title = Setări
cut-options-hint = Dobânda și suma țintă sunt opționale.
cut-report-button = Raport PDF
cut-chart-title = Soldul dumneavoastră, fără și cu reduceri
cut-chart-hint = Linie continuă: soldul real din ultimele douăsprezece luni; linie punctată gri: proiecția fără reduceri; albastru: cu reduceri; verde: banii câștigați.
cut-donut-title = Cheltuielile dumneavoastră lunare după reduceri
cut-donut-caption = pe lună după reduceri
cut-donut-others = Alte poziții
cut-donut-saved = Economisit
cut-legend-with = Cu reducerile
cut-legend-without = Fără reduceri
cut-years = { $years ->
        [one] { $years } an
        [few] { $years } ani
       *[other] { $years } de ani
    }
cut-headline-none = Introduceți o reducere în tabel pentru a-i vedea efectul.
cut-headline = Reducând { $count ->
        [one] această poziție
        [few] aceste { $count } poziții
       *[other] aceste { $count } de poziții
    }, ați pune deoparte { $monthly } în plus pe lună, adică { $yearly } pe an.
cut-tile-monthly = Câștig pe lună
cut-tile-yearly = Câștig pe an
cut-tile-horizon = Câștig în { $years ->
        [one] { $years } an
        [few] { $years } ani
       *[other] { $years } de ani
    }
cut-tile-spending = Cheltuieli pe lună
cut-target-already = Aveți deja { $amount }.
cut-target-sooner = Ați atinge { $amount } în jurul datei: { $with } (fără reduceri: { $without }) — { $months ->
        [0] niciun câștig de timp
        [one] cu o lună mai devreme
        [few] cu { $months } luni mai devreme
       *[other] cu { $months } de luni mai devreme
    }.
cut-target-only-with = Cu aceste reduceri, ați atinge { $amount } în jurul datei: { $with }; fără ele, în ritmul actual, niciodată.
cut-target-never = Chiar și cu aceste reduceri, nu ați atinge { $amount } în ritmul dumneavoastră actual.
cut-note-seasons = Fiecare reducere urmează anotimpurile poziției sale: o poziție care cântărește mai ales vara aduce economii mai ales vara.
cut-note-capped = O reducere introdusă depășea cheltuiala: a fost adusă la nivelul cheltuielii înseși.
cut-invalid-cut = Această reducere nu poate fi citită: un procent între 0 și 100 sau o sumă pe lună.
cut-report-settings = Setările
cut-report-result = Rezultatul
cut-report-accounts = Conturile urmărite

# --- F46 — Préparer mes vacances (Fabrice, 10/10/2026) -----------------------------
# Ce que coûtera le prochain voyage, séjour ou croisière.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-holiday = Îmi pregătesc vacanța
window-holiday-title = Îmi pregătesc vacanța
holiday-trip-title = Călătoria
holiday-field-trip = Tipul călătoriei
holiday-trip-stay = Sejur
holiday-trip-cruise = Croazieră
holiday-field-adults = Adulți
holiday-field-children = Copii
holiday-field-nights = Durata sejurului, în nopți
holiday-field-days = Zile
holiday-field-months = Luni până la plecare
holiday-field-stops = Număr de escale
holiday-saved-title = Economisit deja
holiday-saved-hint = Bifați conturile în care banii pentru vacanță sunt deja puși deoparte: soldul lor real contează ca economisit deja.
holiday-budget-title = Bugetul
holiday-budget-hint = Pentru fiecare poziție, o sumă, pentru cine se aplică și pentru cât timp. O poziție goală nu se ia în calcul.
holiday-optional-title = Poziții opționale
holiday-result-title = Rezultatul
holiday-donut-title = Unde se duc banii călătoriei
holiday-donut-caption = pentru călătorie
holiday-child-label = Preț copil
holiday-count-label = Cabine
holiday-open = Deschideți un proiect…
holiday-save = Salvați proiectul…
holiday-pdf = Raport PDF
holiday-excel = Export în Excel
holiday-file-filter = Proiect de vacanță
holiday-replace-question = Deschiderea acestui proiect va înlocui ce este introdus în fereastră. Continuați?
holiday-file-saved = Proiect salvat: { $file }
holiday-file-opened = Proiect deschis: { $file }
holiday-file-not-project = Acest fișier nu este un proiect de vacanță Radinus.
holiday-file-too-recent = Acest proiect provine dintr-o versiune mai nouă de Radinus: actualizați Radinus pentru a-l deschide.
holiday-file-failed = Fișierul nu a putut fi citit sau scris: { $reason }
holiday-line-transport = Transport dus-întors
holiday-line-lodging = Cazare
holiday-line-meals = Mese și cheltuieli curente
holiday-line-visits = Vizite și activități de agrement
holiday-line-port = Drumul până în port
holiday-line-cabins = Cabine
holiday-line-service = Taxă de serviciu (bacșiș)
holiday-line-drinks = Pachet de băuturi
holiday-line-excursions = Excursii în escale
holiday-line-port-taxes = Taxe portuare
holiday-line-wifi = Wifi la bord
holiday-line-onboard = Cheltuieli la bord și în escale
holiday-line-other = Alte cheltuieli și neprevăzute
holiday-line-insurance = Asigurare storno
holiday-line-stay-tax = Taxă turistică
holiday-line-car = Mașină la destinație, carburant și taxe de drum
holiday-line-parking = Parcare la aeroport sau la gară
holiday-line-bank = Comisioane bancare în străinătate
holiday-line-formalities = Formalități (pașaport, viză, vaccinuri)
holiday-line-pets = Îngrijirea animalelor
holiday-span-trip = pentru sejur
holiday-span-night = pe noapte
holiday-span-day = pe zi
holiday-span-stop = pe escală
holiday-who-all = pentru toți
holiday-who-person = de persoană
holiday-who-adults = de adult
holiday-cabins-count = { $count ->
        [one] { $count } cabină
        [few] { $count } cabine
       *[other] { $count } de cabine
    }
holiday-days = { $days ->
        [one] { $days } zi
        [few] { $days } zile
       *[other] { $days } de zile
    }
holiday-invalid-count = Introduceți un număr întreg.
holiday-invalid-amount = Această sumă nu poate fi citită: un număr pozitiv sau un procent între 0 și 100.
holiday-headline-empty = Introduceți sumele din buget pentru a vedea cât va costa călătoria.
holiday-headline-stay = Acest sejur ar costa { $total } pentru { $people ->
        [one] o persoană
        [few] { $people } persoane
       *[other] { $people } de persoane
    } și { $nights ->
        [0] nicio noapte
        [one] o noapte
        [few] { $nights } nopți
       *[other] { $nights } de nopți
    }.
holiday-headline-cruise = Această croazieră ar costa { $total } pentru { $people ->
        [one] o persoană
        [few] { $people } persoane
       *[other] { $people } de persoane
    } și { $nights ->
        [0] nicio noapte
        [one] o noapte
        [few] { $nights } nopți
       *[other] { $nights } de nopți
    }.
holiday-tile-total = Cost total
holiday-tile-person = De persoană
holiday-tile-person-day = De persoană pe zi
holiday-tile-saved = Economisit deja
holiday-tile-remaining = Rămas de finanțat
holiday-tile-monthly = Economii necesare
holiday-remaining-none = Nimic: este acoperit
holiday-monthly-none = Nimic de pus deoparte
holiday-monthly-now = Plecare luna aceasta
holiday-note-days = Zilele sunt nopțile plus una: șapte nopți înseamnă opt zile.
holiday-note-child = De persoană, un copil plătește prețul pentru copii, dacă este indicat; dacă este gol, plătește ca un adult.
holiday-note-percent = Un procent de asigurare se aplică pozițiilor principale ale călătoriei; cel al comisioanelor bancare, cheltuielilor făcute la destinație.
holiday-sheet-budget = Buget
holiday-sheet-result = Rezultat
holiday-column-line = Poziție
holiday-column-amount = Sumă
holiday-column-child = Preț copil
holiday-column-who = Pentru cine
holiday-column-span = Pentru cât timp
holiday-column-cost = Cost
holiday-disclaimer = O estimare pe baza propriilor dumneavoastră sume: prețurile reale pot varia.

# --- F45 (suite) — le projet de réduction en fichier (Fabrice, 10/10/2026) --------
# « Rajoute enregistrement et chargement JSON et aussi export Excel. »
cut-file-filter = Proiect de reducere
cut-file-not-project = Acest fișier nu este un proiect de reducere Radinus.
cut-file-too-recent = Acest proiect provine dintr-o versiune mai nouă de Radinus: actualizați Radinus pentru a-l deschide.
cut-sheet-items = Poziții

# --- F47 — Carnet de ma voiture (Fabrice, 10/10/2026) --------------------------------
# L'historique de la voiture : énergie, entretien, pièces, pneus, pannes, assurance, contrôle.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-car = Carnetul mașinii mele
window-car-title = Carnetul mașinii mele
car-unnamed = Mașina mea
car-sheet-title = Mașina
car-field-plate = Număr de înmatriculare
car-field-make = Marcă
car-field-model = Model
car-field-engine = Motorizare
car-field-first-hand = Primul proprietar
car-field-registered = Prima înmatriculare
car-field-acquired = Data achiziției
car-field-acquired-km = Kilometraj la achiziție
car-field-service = Revizie la fiecare
car-field-service-or = sau la fiecare
car-unit-months-short = luni
car-unit-km = km
car-tariff-title = Tariful încărcării acasă
car-tariff-hint = Acest tarif este păstrat în carnetul mașinii: nu îl modifică pe cel din preferințe.
car-tariff-reset = Preluați tariful din preferințe
car-engine-petrol = Benzină
car-engine-diesel = Diesel
car-engine-lpg = GPL
car-engine-e85 = E85 (bioetanol)
car-engine-hybrid = Hibrid
car-engine-plug-in = Hibrid plug-in
car-engine-electric = Electric
car-engine-hydrogen = Hidrogen
car-energy-petrol = Benzină
car-energy-diesel = Motorină
car-energy-lpg = GPL
car-energy-e85 = E85
car-energy-electricity = Electricitate
car-energy-hydrogen = Hidrogen
car-unit-litre = L
car-unit-kwh = kWh
car-unit-kg = kg
car-rubric-energy = Energie
car-rubric-upkeep = Întreținere curentă
car-rubric-service = Revizie
car-rubric-wear = Piese de uzură
car-rubric-tyres = Anvelope
car-rubric-breakdown = Defecțiuni
car-rubric-insurance = Asigurare
car-rubric-inspection = Inspecție tehnică (ITP)
car-part-brake-pads = Plăcuțe de frână
car-part-brake-discs = Discuri de frână
car-part-timing-belt = Curea de distribuție
car-part-clutch = Ambreiaj
car-part-battery-12v = Baterie 12 V
car-part-shock-absorbers = Amortizoare
car-part-wipers = Ștergătoare
car-part-spark-plugs = Bujii
car-part-glow-plugs = Bujii incandescente
car-part-particulate-filter = Filtru de particule
car-part-catalytic-converter = Catalizator
car-part-fuel-cell-filter = Filtrul pilei de combustie
car-part-exhaust = Eșapament
car-part-other = Altă piesă…
car-axle-all = Toate cele patru anvelope
car-axle-front = Anvelope față
car-axle-rear = Anvelope spate
car-verdict-pass = Admis
car-verdict-counter = Reinspecție
car-charge-station = La o stație de încărcare
car-charge-home = Acasă
car-slot-peak = Ore de vârf
car-slot-off-peak = Ore în afara vârfului
car-entry-new = Linie nouă
car-entry-edit = Modificați linia
car-field-date = Data
car-field-km = Kilometraj
car-field-rubric = Rubrică
car-field-amount = Sumă
car-field-garage = Service sau stație
car-field-note = Notă
car-field-energy = Energie
car-field-quantity = Cantitate
car-field-charge = Încărcare
car-field-slot = Ora încărcării
car-field-part = Piesă
car-field-part-name = Numele piesei
car-field-axle = Anvelope schimbate
car-field-verdict = Rezultat
car-field-months = Luni acoperite
car-field-battery = Starea bateriei
car-home-amount-hint = Suma unei încărcări acasă se calculează cu tariful mașinii.
car-entry-add = Adăugați în carnet
car-entry-update = Salvați linia
car-entry-cancel = Anulați
car-entry-delete = Ștergeți linia
car-delete-question = Ștergeți această linie din carnet?
car-from-operation = Preluați o operațiune…
car-pick-account = Din ce cont provine cheltuiala?
car-pick-operation = Ce operațiune?
car-pick-take = Preluați
car-pick-none = Nicio cheltuială în acest cont.
car-pick-taken = Operațiune preluată: completați kilometrajul și rubrica, apoi adăugați linia.
car-history-title = Istoricul
car-filter-all = Toate rubricile
car-history-empty = Nicio linie deocamdată.
car-history-hint = Faceți clic pe o linie pentru a o modifica.
car-column-date = Data
car-column-km = Km
car-column-rubric = Rubrică
car-column-detail = Detaliu
car-column-amount = Sumă
car-column-garage = Service
car-column-note = Notă
car-column-share = Pondere
car-column-per-km = Pe km
car-column-energy = Energie
car-column-quantity = Cantitate
car-column-price = Preț mediu
car-column-consumption = Consum
car-column-part = Piesă
car-column-changes = Schimbări
car-column-last = Ultima schimbare
car-column-life = Durată de viață
car-column-next = Următoarea schimbare
car-total = Total
car-summary-title = Cât costă mașina
car-headline-empty = Completați fișa, apoi adăugați o primă linie: un plin, o revizie, o factură de service…
car-headline = Începând cu { $since }, mașina v-a costat { $total }.
car-headline-km = Începând cu { $since }, mașina v-a costat { $total } pentru { $km } parcurși: { $cost } pe kilometru.
car-tile-total = Cost total
car-tile-month = Pe lună
car-tile-km = Pe kilometru
car-tile-driven = Kilometri parcurși
car-tile-consumption = Consum
car-tile-energy-km = Energie pe kilometru
car-km = { $value } km
car-quantity = { $value } { $unit }
car-per-100 = { $value } { $unit } / 100 km
car-per-unit = { $price } / { $unit }
car-months = { $months ->
        [one] { $months } lună
        [few] { $months } luni
       *[other] { $months } de luni
    }
car-detail-battery = Baterie: { $value } %
car-battery-line = { $when }: { $value } %
car-rubrics-title = Pe rubrici
car-energy-title = Energia
car-parts-title = Piese de uzură
car-tyres-title = Anvelope
car-battery-title = Starea bateriei
car-years-title = Cât a costat mașina în fiecare an
car-donut-title = Unde se duc banii
car-donut-caption = în total
car-deadlines-title = Scadențele
car-deadlines-empty = Nicio scadență deocamdată: notați o revizie, o inspecție tehnică, o asigurare sau două schimbări ale aceleiași piese.
car-deadline-service = Revizie
car-deadline-inspection = Inspecție tehnică (ITP)
car-deadline-counter = Reinspecția tehnică
car-deadline-insurance = Expirarea asigurării
car-when-date = pe { $date }
car-when-km = la { $km }
car-when-km-reached = la { $km }, în ritmul dumneavoastră în jurul datei: { $month }
car-when-date-km = pe { $date } sau la { $km }, care survine primul
car-when-inspection-unknown = Notați ultima inspecție tehnică pentru a afla data următoarei.
car-tone-late = Depășită
car-tone-soon = În curând
car-note-since = Totul se calculează de la achiziție: data și kilometrajul notate în fișă.
car-note-consumption = Consumul se măsoară de la plin la plin: faceți plinul complet și notați kilometrajul de fiecare dată.
car-note-e85 = O mașină E85 consumă ce i se dă: kilometrii de după un plin se socotesc pentru carburantul acelui plin.
car-note-home = O încărcare acasă este calculată la tariful mașinii din ziua în care este notată și își păstrează acest cost.
car-note-inspection = Inspecția tehnică urmează regula franceză: prima în cei patru ani de la prima înmatriculare, apoi la fiecare doi ani; o reinspecție, în termen de două luni.
car-disclaimer = Scadențele și duratele de viață sunt estimări extrase din carnet: doar cartea de service a producătorului este de referință.
car-invalid-date = O dată validă, care să nu fie în viitor, vă rog.
car-invalid-acquired = Data achiziției nu poate fi anterioară primei înmatriculări.
car-invalid-km = Un kilometraj în kilometri întregi, vă rog.
car-invalid-amount = Această sumă nu poate fi citită.
car-invalid-quantity = Introduceți cantitatea: litri, kWh sau kilograme.
car-invalid-part = Alegeți piesa schimbată sau introduceți-i numele.
car-invalid-rubric = Alegeți o rubrică.
car-invalid-months = Un număr întreg de luni, vă rog.
car-invalid-battery = O stare a bateriei între 0 și 100 %, vă rog.
car-open = Deschideți un carnet…
car-save = Salvați carnetul…
car-report-button = Raport PDF
car-file-filter = Carnet auto
car-file-saved = Carnet salvat: { $file }
car-file-opened = Carnet deschis: { $file }
car-file-not-logbook = Acest fișier nu este un carnet auto Radinus.
car-file-too-recent = Acest carnet provine dintr-o versiune mai recentă de Radinus: actualizați Radinus pentru a-l deschide.
car-replace-question = Deschiderea acestui carnet îl va înlocui pe cel din fereastră. Continuați?
car-sheet-history = Carnet
car-sheet-summary = Sinteză

analysis-history-hint = Cu cât istoricul dumneavoastră este mai lung, cu atât această analiză va fi mai bună: ideal este să aveți cel puțin un an de operațiuni.

# --- F48 — Împărțirea unei cheltuieli (Fabrice, 11/10/2026, P-71) ---
menu-tools-sharing = Împărțirea unei cheltuieli
window-sharing-title = Împărțirea unei cheltuieli
sharing-question = Cine plătește ce?
sharing-setup-title = Împărțirea
sharing-field-label = Denumire
sharing-label-hint = De exemplu „Restaurant din 12/10” sau „Excursie în Bretania 2027”: denumirea dă numele fișierelor și al rapoartelor.
sharing-field-total = Total
sharing-total-hint = Dacă rămâne gol, totalul este suma articolelor și a extra-urilor fiecăruia.
sharing-field-rule = Regulă
sharing-field-rounding = Rotunjire
sharing-field-people = Persoane
sharing-mode-whole = O regulă pentru toată cheltuiala
sharing-mode-item = O regulă pe articol
sharing-rule-equal = Părți egale
sharing-rule-parts = După părți
sharing-rule-percent = În procente
sharing-rule-income = Proporțional cu veniturile
sharing-rounding-cent = La cent
sharing-rounding-euro = La unitatea întreagă
sharing-round-euro = Rotunjiți la unități întregi
sharing-hide-incomes = Ascundeți veniturile în rapoarte și în export
sharing-people-title = Persoanele
sharing-people-hint = Un rând pe persoană, o coloană pe articol: bifați cine participă la ce. Tot restul este opțional. Cineva care se retrage lăsându-și avansul: o sumă exactă egală cu ce a plătit și nicio casetă bifată.
sharing-add-person = Adăugați o persoană
sharing-person-default = Persoana { $number }
sharing-items-title = Articolele
sharing-items-hint = Doar ce nu privește pe toată lumea, cum ar fi vinul. Restul totalului merge la articolul comun.
sharing-add-item = Adăugați un articol
sharing-common = Comun
sharing-payments-title = Plățile
sharing-payments-hint = Cine a plătit, cât și când. Un rând fără sumă nu contează încă.
sharing-payments-none = Nicio plată deocamdată.
sharing-add-payment = Adăugați o plată
sharing-result-title = Rezultatul
sharing-balances-title = Cum stau plățile
sharing-transfers-title = Transferurile propuse
sharing-delete = Ștergeți
sharing-delete-person-question = Această persoană are plăți: le ștergeți împreună cu ea?
sharing-disclaimer = Radinus propune o împărțire: între prieteni, fiecare rămâne liber să se înțeleagă altfel.
sharing-column-person = Persoană
sharing-column-household = Gospodărie
sharing-column-income = Venit
sharing-column-parts = Părți
sharing-column-percent = %
sharing-column-floor = Cel puțin
sharing-column-cap = Cel mult
sharing-column-fixed = Sumă exactă
sharing-column-alone = Extra proprii
sharing-column-gift = Surplus oferit
sharing-column-share = Cotă
sharing-column-typed = % introdus
sharing-column-constraint = Ce s-a aplicat
sharing-column-due = De plătit
sharing-column-item = Articol
sharing-column-amount = Sumă
sharing-column-rule = Regulă
sharing-column-participants = Participanți
sharing-column-unit = Gospodărie sau persoană
sharing-column-members = Membri
sharing-column-paid = Achitat
sharing-column-balance = Sold
sharing-column-date = Data
sharing-column-who = Cine
sharing-column-label = Denumire
sharing-help-household = Persoanele din aceeași gospodărie achită împreună: plățile lor și ce datorează se adună, iar ele primesc un singur extras. Exemplu: „Familia Martin” pentru părinți și copii.
sharing-help-income = Folosit doar de regula „Proporțional cu veniturile”: cu cât venitul este mai mare, cu atât cota este mai mare. Introduceți venitul lunar.
sharing-help-parts = O persoană cu 2 părți plătește de două ori mai mult decât o persoană cu 1 parte. Exemplu: adult 1, copil 0,5.
sharing-help-percent = Partea din cheltuială pe care o plătește persoana. Procentele trebuie să însumeze 100 %.
sharing-help-floor = Persoana va plăti cel puțin această sumă, chiar dacă cota calculată este mai mică. Diferența îi ușurează pe ceilalți.
sharing-help-cap = Persoana nu va plăti niciodată mai mult decât această sumă. Ce nu plătește revine celorlalți participanți la articolele sale.
sharing-help-fixed = Persoana plătește această sumă, indiferent ce se întâmplă, iar restul se împarte între ceilalți. Exemplu: cineva care se retrage și își lasă avansul.
sharing-help-alone = Ce a luat persoana doar pentru ea, cum ar fi un desert sau o cafea. O plătește integral, în plus față de cotă.
sharing-help-gift = Dacă persoana a plătit mai mult decât cota: bifat, surplusul este un dar pentru grup; nebifat, i se restituie.
sharing-help-items = Bifați persoanele care participă la acest articol. Articolul comun este ceea ce rămâne din total după ce se scad celelalte articole.
sharing-help-due = Ce datorează persoana în total: cota sa din articole, extra-urile proprii și rotunjirea.
sharing-help-share = Ce reprezintă cota, ca procent din suma de împărțit.
sharing-help-typed = Procentul pe care l-ați introdus. Poate diferi de cota reală atunci când s-a aplicat un minim, un maxim sau o sumă exactă.
sharing-help-constraint = Arată dacă cota persoanei a fost modificată de un minim, un maxim, o sumă exactă sau un surplus oferit.
sharing-help-item = Doar ce nu privește pe toată lumea, cum ar fi vinul. Restul totalului merge la articolul comun, împărțit între cei bifați la el.
sharing-help-rule = Cum se împarte acest articol: în părți egale, după părți, în procente sau proporțional cu veniturile.
sharing-help-paid = Ce a achitat deja gospodăria sau persoana, conform plăților introduse.
sharing-help-balance = Ce rămâne de plătit sau ce s-a achitat în plus față de cotă. Exemplu: „Rămas de plătit: 61,54 €”.
sharing-advice-equal = { $count ->
        [one] { $total } pentru o singură persoană.
        [few] { $total } ÷ { $count } persoane = { $amount } fiecare.
       *[other] { $total } ÷ { $count } de persoane = { $amount } fiecare.
    }
sharing-advice-equal-varied = În părți egale între cei care participă, ținând cont de limite și de excluderi.
sharing-advice-parts = Total părți: { $parts }. O parte valorează { $amount }.
sharing-advice-parts-varied = Fiecare plătește după părțile sale, ținând cont de limite și de excluderi. O casetă goală contează ca 1 parte.
sharing-advice-percent-rest = Mai lipsesc { $rest } % până la 100 %.
sharing-advice-percent-over = Procentele depășesc 100 % cu { $over } %.
sharing-advice-percent-ok = Procentele însumează exact 100 %.
sharing-advice-percent-nobody = Procentele însumează deja 100 %: { $count ->
        [one] { $names } nu ar plăti nimic.
        [few] { $names } nu ar plăti nimic.
       *[other] { $names } nu ar plăti nimic.
    }
sharing-advice-income = Fiecare plătește { $rate } % din venitul său.
sharing-advice-income-missing = Introduceți venitul fiecăruia pentru a împărți proporțional cu veniturile.
sharing-advice-income-varied = Fiecare plătește aceeași proporție din venitul său, ținând cont de limite și de excluderi.
sharing-advice-empty = Introduceți suma de împărțit.
sharing-apply-advice = Preluați valorile sugerate
sharing-help-apply-advice = Completează casetele goale cu valorile afișate cu gri. Casetele deja completate nu se schimbă.
sharing-from-incomes = Procente după venituri
sharing-help-from-incomes = Înlocuiește procentele cu partea fiecărui venit din totalul veniturilor. Ele însumează 100 %.
sharing-reset-percents = Reîmpărțiți totul
sharing-help-reset-percents = Șterge procentele și le împarte în mod egal între toți. Util după ce ați adăugat o persoană.
sharing-reset-percents-question = Ștergeți toate procentele și le împărțiți în mod egal?
sharing-open = Deschideți un proiect…
sharing-save = Salvați proiectul…
sharing-pdf-distribution = Împărțire (PDF)
sharing-pdf-payments = Situația plăților (PDF)
sharing-pdf-statements = Extrase individuale (PDF)…
sharing-statements-everyone = Toată lumea
sharing-excel = Export în Excel
sharing-file-filter = Proiect de împărțire
sharing-replace-question = Deschiderea acestui proiect va înlocui ce este introdus în fereastră. Continuați?
sharing-file-saved = Proiect salvat: { $file }
sharing-file-opened = Proiect deschis: { $file }
sharing-file-not-project = Acest fișier nu este un proiect de împărțire Radinus.
sharing-file-too-recent = Acest proiect provine dintr-o versiune mai nouă de Radinus: actualizați Radinus pentru a-l deschide.
sharing-file-failed = Fișierul nu a putut fi citit sau scris: { $reason }
sharing-statements-replace-question = { $count ->
        [one] Există deja un extras în acest dosar. Îl înlocuiți?
        [few] Există deja { $count } extrase în acest dosar. Le înlocuiți?
       *[other] Există deja { $count } de extrase în acest dosar. Le înlocuiți?
    }
sharing-statements-written = { $count ->
        [one] Un extras scris în „{ $folder }”.
        [few] { $count } extrase scrise în „{ $folder }”.
       *[other] { $count } de extrase scrise în „{ $folder }”.
    }
sharing-too-many-people = O împărțire cuprinde cel mult 40 de persoane.
sharing-too-many-items = O împărțire cuprinde cel mult 20 de articole.
sharing-too-many-payments = O împărțire cuprinde cel mult 400 de plăți.
sharing-invalid-amount = Această sumă nu poate fi citită: un număr pozitiv.
sharing-invalid-number = Acest număr nu poate fi citit: un număr pozitiv.
sharing-invalid-percent = Un procent merge de la 0 la 100.
sharing-invalid-date = Această dată nu poate fi citită.
sharing-name-missing = Fiecare persoană trebuie să aibă un nume.
sharing-name-duplicate = Există deja „{ $name }”: deosebiți-le, de exemplu printr-o inițială.
sharing-floor-above-cap = Minimul depășește maximul.
sharing-item-label-missing = Acest articol nu are nume.
sharing-items-above-total = Articolele și extra-urile fiecăruia depășesc totalul cu { $amount }.
sharing-payment-person = Alegeți cine a plătit.
sharing-percent-total = Procentele însumează { $sum } %: trebuie să fie 100 %.
sharing-percent-total-item = „{ $item }”: procentele însumează { $sum } %: trebuie să fie 100 %.
sharing-item-nobody = Nimeni nu participă la „{ $item }”.
sharing-item-no-weight = Nimeni nu contează în „{ $item }”: toți participanții săi sunt la zero.
sharing-income-missing = Lipsește venitul lui { $name }.
sharing-fixed-above = Sumele exacte depășesc suma de împărțit cu { $amount }.
sharing-floors-above = Minimele depășesc suma de împărțit cu { $amount }.
sharing-cap-alone = La „{ $item }” participă doar { $name }: maximul nu poate fi respectat.
sharing-caps-short = Maximele nu sunt suficiente pentru a acoperi suma: lipsesc { $amount }.
sharing-impossible = Aceste condiții nu pot fi respectate toate: relaxați un minim sau un maxim.
sharing-constraint-floor = Minim atins
sharing-constraint-cap = Maxim atins
sharing-constraint-fixed = Sumă exactă
sharing-constraint-gift = Surplus oferit
sharing-and = { $first } și { $last }
sharing-outside = În afara articolelor
sharing-alone = Extra proprii
sharing-rounding = Rotunjire
sharing-headline-empty = Adăugați persoanele care împart cheltuiala.
sharing-headline-no-amount = Introduceți totalul sau articolele de împărțit.
sharing-headline-equal = { $total } de împărțit: fiecare plătește { $amount }.
sharing-headline-range = { $total } de împărțit: de la { $min } la { $max }, în funcție de persoană.
sharing-participants = { $count ->
        [0] Niciun participant
        [one] Un participant
        [few] { $count } participanți
       *[other] { $count } de participanți
    }
sharing-balance-due = Rămas de plătit: { $amount }
sharing-balance-over = A plătit cu { $amount } mai mult decât cota sa
sharing-balance-even = La zi
sharing-summary-collected = { $collected } achitați din { $total }.
sharing-summary-owing = { $count ->
        [0] Toată lumea este la zi.
        [one] O singură persoană mai datorează { $amount }.
        [few] { $count } persoane mai datorează { $amount } în total.
       *[other] { $count } de persoane mai datorează { $amount } în total.
    }
sharing-remaining-outside = Rămas de plătit din cheltuială: { $amount }
sharing-remaining-reimburse = De rambursat către { $name }: { $amount }
sharing-all-settled = Totul este achitat: nimeni nu datorează nimic nimănui.
sharing-transfer = { $from } trebuie să plătească { $amount } către { $to }
sharing-warning-over-paid = Plățile depășesc cheltuiala cu { $amount }: verificați sumele.
sharing-note-income-zero = { $name } nu plătește nimic pentru { $items }: venitul este 0.
sharing-note-excluded = { $name } nu participă la „{ $item }”: cota respectivă este repartizată între ceilalți.
sharing-note-gift = Surplusul oferit de { $giver } reduce cota celorlalți: { $name } a plătit acum mai mult decât cota sa.
sharing-note-outside = { $name } plătește { $amount } în afara articolelor sale: suma este dedusă din ce împart ceilalți.
sharing-note-keeper = Rotunjit la unități întregi: { $name } păstrează subdiviziunile, astfel încât totalul să iasă exact.
sharing-report-distribution = Împărțire
sharing-report-sharing = Împărțirea
sharing-report-who-pays = Cine plătește ce
sharing-report-items = Detaliu pe articole
sharing-report-payments = Situația plăților
sharing-report-as-of = Situația la { $date }
sharing-report-balances = Cotă, achitat, sold
sharing-report-statement = Extras — { $name }
sharing-report-your-share = Cota dumneavoastră
sharing-statement-total = Total pentru gospodărie: { $amount }
sharing-statement-pay = De plătit către { $name }: { $amount }
sharing-statement-receive = De primit de la { $name }: { $amount }
sharing-sheet-people = Persoane
sharing-sheet-items = Articole
sharing-sheet-result = Rezultat
sharing-sheet-payments = Plăți
sharing-sheet-balances = Rambursări

## Asistentul de export al unei baze de date (P-74, Fabrice, 19/10/2026).
window-database-export-title = Asistentul de export al bazei „{ $base }”
menu-tools-export = Asistentul de export al bazei…
base-export-only-this = Doar baza „{ $base }”, selectată în listă, va fi exportată. Celelalte baze nu sunt afectate.
base-export-purpose = Acest asistent copiază datele bazei în fișiere pe care alte programe le pot citi: o foaie de calcul, o bază de date precum Access, un alt program de gestiune a banilor. Baza în sine nu este modificată.
base-export-step-format = 1. Formatul
base-export-step-options = 2. Opțiunile
base-export-step-place = 3. Locația
base-export-step-summary = 4. Rezumatul
base-export-format-xlsx = Excel (.xlsx)
base-export-format-xlsx-hint = Un registru de calcul cu câte o foaie pentru fiecare tabel, care poate fi citit de Excel și de majoritatea programelor de calcul tabelar.
base-export-format-ods = Calc (.ods)
base-export-format-ods-hint = Formatul liber al LibreOffice și OpenOffice, cu câte o foaie pentru fiecare tabel.
base-export-format-csv = CSV (.csv)
base-export-format-csv-hint = Câte un fișier text pentru fiecare tabel, cu valorile separate prin punct și virgulă: formatul pe care aproape toate programele îl pot importa, inclusiv Access.
base-export-format-json = JSON (.json)
base-export-format-json-hint = Pentru programatori și aplicații: fiecare tabel sub numele său, cu un antet care descrie exportul.
base-export-format-xml = XML (.xml)
base-export-format-xml-hint = Același conținut ca în JSON, scris în XML.
base-export-format-sql = Script SQL (.sql)
base-export-format-sql-hint = Instrucțiunile care recreează tabelele și datele lor într-o altă bază de date (MySQL, PostgreSQL, SQLite…).
base-export-format-sqlite = Bază SQLite (.sqlite)
base-export-format-sqlite-hint = O bază de date de sine stătătoare, fără parolă, pe care multe instrumente o deschid direct.
base-export-format-qif = QIF, un fișier pe cont (.qif)
base-export-format-qif-hint = Pentru a vă muta conturile într-un alt program de gestiune a banilor (Money, Quicken, GnuCash, Grisbi…).
base-export-format-ofx = OFX, un fișier pe cont (.ofx)
base-export-format-ofx-hint = Formatul extraselor de cont bancare, pe care majoritatea programelor de gestiune a banilor îl pot importa.
base-export-lossy = Atenție: QIF și OFX nu pot reda totul. Trec doar operațiunile din conturi, cu terții, categoriile și comentariile lor; un transfer devine o operațiune obișnuită de fiecare parte, iar restul (bugete, operațiuni periodice, proiecte, alocări…) nu este preluat. Pentru a păstra totul, alegeți un alt format.
base-export-planned-note = Operațiunile planificate și operațiunile fără dată nu sunt exportate: ele nu au trecut încă prin bancă. Numărul lor va fi indicat la final.
base-export-dates-hint = Datele sunt scrise an-lună-zi (2026-12-31), iar sumele în moneda bazei: niciun program nu le poate citi greșit.
base-export-group-layout = Fișiere
base-export-layout-one = Totul într-un singur fișier
base-export-layout-per-table = Câte un fișier pentru fiecare tabel, într-un folder
base-export-group-decimal = Separatorul zecimal al sumelor
base-export-decimal-point = Punctul (1234.56)
base-export-decimal-comma = Virgula (1234,56)
base-export-group-quotes = Ghilimele
base-export-quotes-all = Fiecare valoare între ghilimele
base-export-quotes-none = Fără ghilimele
base-export-csv-replacements-hint = Pentru ca fiecare fișier să poată fi recitit fără erori, un punct și virgulă dintr-un text devine semn de exclamare, un rând nou devine spațiu și, fără ghilimele, o ghilimea devine apostrof. Numărul înlocuirilor va fi indicat la final.
base-export-group-qif-order = Ordinea datei
base-export-qif-day-month = Ziua înaintea lunii (31/12/2026)
base-export-qif-month-day = Luna înaintea zilei (12/31/2026)
base-export-qif-order-hint = Alegeți ordinea pe care o așteaptă programul care va citi fișierele: întâi ziua în Europa, întâi luna în Statele Unite.
base-export-no-option = Acest format nu are opțiuni.
base-export-choose-file = Alegeți fișierul…
base-export-choose-folder = Alegeți folderul…
base-export-place-file = Exportul va fi scris în acest fișier:
base-export-place-folder = Exportul va fi scris în acest folder, creat special pentru el:
base-export-place-none = Nu a fost aleasă încă nicio locație.
base-export-place-needed = Alegeți mai întâi unde să fie scris exportul.
base-export-folder-exists = Folderul „{ $name }” există deja. Fișierele cu același nume din el vor fi înlocuite. Continuați?
base-export-summary-base = Bază
base-export-summary-format = Format
base-export-summary-options = Opțiuni
base-export-summary-place = Locație
base-export-unprotected = Această bază este protejată prin parolă, dar exportul nu va fi: oricine are aceste fișiere vă poate citi conturile. Păstrați-le într-un loc sigur.
base-export-previous = Precedentul
base-export-next = Următorul
base-export-run = Exportați
base-export-running = Export în curs…
base-export-done = Baza „{ $base }” a fost exportată: { $tables ->
        [one] un tabel
        [few] { $tables } tabele
       *[other] { $tables } de tabele
    }, { $rows ->
        [one] un rând
        [few] { $rows } rânduri
       *[other] { $rows } de rânduri
    }.
base-export-done-accounts = Baza „{ $base }” a fost exportată: { $accounts ->
        [one] un cont
        [few] { $accounts } conturi
       *[other] { $accounts } de conturi
    }, { $operations ->
        [one] o operațiune
        [few] { $operations } operațiuni
       *[other] { $operations } de operațiuni
    }.
base-export-done-replacements = { $count ->
        [one] Un caracter a fost înlocuit în fișierele CSV.
        [few] { $count } caractere au fost înlocuite în fișierele CSV.
       *[other] { $count } de caractere au fost înlocuite în fișierele CSV.
    }
base-export-done-controls = { $count ->
        [one] { $count } caracter de control, pe care acest format nu îl poate conține, a fost înlocuit cu „�”.
        [few] { $count } caractere de control, pe care acest format nu le poate conține, au fost înlocuite cu „�”.
       *[other] { $count } de caractere de control, pe care acest format nu le poate conține, au fost înlocuite cu „�”.
    }
base-export-done-excel-cut = { $count ->
        [one] { $count } text depășea 32.767 de caractere, limita Excel: a fost tăiat în registrul de lucru. Celelalte formate îl păstrează întreg.
        [few] { $count } texte depășeau 32.767 de caractere, limita Excel: au fost tăiate în registrul de lucru. Celelalte formate le păstrează întregi.
       *[other] { $count } de texte depășeau 32.767 de caractere, limita Excel: au fost tăiate în registrul de lucru. Celelalte formate le păstrează întregi.
    }
base-export-done-anomalies = { $count ->
        [one] O valoare ilizibilă a fost copiată ca atare.
        [few] { $count } valori ilizibile au fost copiate ca atare.
       *[other] { $count } de valori ilizibile au fost copiate ca atare.
    }
base-export-done-planned = { $count ->
        [one] O operațiune planificată a fost lăsată deoparte.
        [few] { $count } operațiuni planificate au fost lăsate deoparte.
       *[other] { $count } de operațiuni planificate au fost lăsate deoparte.
    }
base-export-done-undated = { $count ->
        [one] O operațiune fără dată a fost lăsată deoparte.
        [few] { $count } operațiuni fără dată au fost lăsate deoparte.
       *[other] { $count } de operațiuni fără dată au fost lăsate deoparte.
    }
base-export-done-adjusted = { $count ->
        [one] O valoare a fost ajustată pentru format.
        [few] { $count } valori au fost ajustate pentru format.
       *[other] { $count } de valori au fost ajustate pentru format.
    }
base-export-too-old = Această bază provine dintr-o versiune mai veche de Radinus. Deschideți-o mai întâi o dată în Radinus, care o va actualiza, apoi exportați-o.
base-export-too-recent = Această bază a fost salvată de o versiune mai recentă de Radinus. Actualizați Radinus pentru a o exporta.
base-export-not-radinus = Acest fișier nu este o bază Radinus.
base-export-failed = Exportul nu a putut fi realizat: { $reason }

## Meniul Instrumente al ferestrei bazelor numește baza (Fabrice, 19/10/2026).
databases-tools-selected = Bază selectată: „{ $base }”
databases-tools-none = Nicio bază selectată
menu-tools-backup = Faceți o copie de siguranță a bazei „{ $base }”…
menu-tools-backup-none = Faceți o copie de siguranță a bazei selectate…
menu-tools-restore = Restaurați baza „{ $base }”…
menu-tools-restore-none = Restaurați baza selectată…
menu-tools-repair = Reparați și optimizați baza „{ $base }”…
menu-tools-repair-none = Reparați și optimizați baza selectată…
