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
menu-statistics-by-category = Stat pe categorii
menu-statistics-by-assignment = Stat pe alocări
menu-statistics-by-budget-line = Stat pe poziții bugetare
menu-statistics-by-payment-mode = Stat pe modalități de plată
menu-statistics-by-payee = Stat pe terți și comercianți
menu-statistics-by-project = Stat pe proiecte
menu-statistics-dashboard = Tablou de bord al operațiunilor

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

menu-settings = Setări
menu-settings-about-author = Despre autor
menu-settings-about-radinus = Despre Radinus
menu-settings-licence = Licență de utilizare

menu-misc = Diverse
menu-misc-calculator = Calculator
menu-misc-website = Accesarea site-ului Radinus
menu-misc-database-folder = Acces la folderul care conține baza de date
menu-misc-application-folder = Acces la folderul care conține aplicația

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
operations-column-label = Descriere
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
   *[category] Statistici după categorie
}

statistics-axis-column = { $kind ->
    [assignment] Alocare
    [budget-line] PozitieBuget
    [payment-mode] ModOperatiune
    [payee] Terți
    [project] Proiecte
   *[category] NumeCategorie
}

statistics-unclassified = { $kind ->
    [assignment] Fără alocare
    [budget-line] Fără pozitie bugetara
    [payment-mode] Fără modalitate de plata
    [payee] Fără terț
    [project] Fără proiect
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
export-all-years-excel = Export toți anii către Excel
export-all-years-ods = Export toți anii către LibreOffice Calc
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
quick-column-date = Data
quick-column-label = Descriere
quick-column-amount = Sumă
quick-column-category = Categorie
quick-column-assignment = Alocare
quick-column-payment-mode = Modalitate plată
quick-column-payee = Terț
quick-column-project = Proiecte
quick-column-status = Stare
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
statement-column-debit = Debit
statement-column-credit = Credit
statement-account = Cont
statement-file = Fișier
statement-difference = Diferență
statement-none = Niciun extras de cont nu este deschis: faceți clic pe folderul galben pentru a alege un fișier.
statement-empty = Acest extras de cont nu conține nicio operațiune.
statement-no-match = Niciun rând nu corespunde filtrului.
statement-help = Info: Utilizați clic de mouse + tasta [{ $modifier }] pe tabel pentru a selecta mai multe rânduri
statement-choose-account = Acest fișier conține mai multe conturi. Pe care doriți să îl importați?
statement-select-line = Selectați cel puțin un rând din extrasul de cont.
statement-title-open = Deschiderea unui fișier de extras de cont (.ofx)
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
    { $count } operațiuni, dintre care { $known } deja prezente în contul dumneavoastră.
statement-group-identification = Identificarea operațiunii
statement-group-amount = Suma operațiunii
statement-group-classification = Clasificarea operațiunii pentru calculul statisticilor
statement-group-status = Starea operațiunii
statement-field-date = Data
statement-field-label = Descriere
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
excel-backup-later = Copia de siguranță nu este încă branșată în această versiune de Radinus 2. Până atunci, închideți Radinus și copiați dumneavoastră fișierul bazei de date: veți putea astfel importa fără niciun risc.

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
backup-done = Copie de siguranță scrisă în „{ $file }”.
backup-failed = Copie de siguranță imposibilă: { $reason }
restore-unreadable = Acest fișier nu este o arhivă Radinus lizibilă: { $reason }
# Întrebarea spune ce se va pierde înainte de a se pierde. Arhiva a fost deja
# citită în acel moment: ceea ce anunță este sigur.
restore-question = Restaurați „{ $file }”? Tot conținutul actual al bazei dumneavoastră va fi șters și înlocuit, iar ceea ce se află în ea va fi pierdut.
restore-done = Restaurare terminată: { $accounts } conturi și { $operations } operațiuni.
restore-failed = Restaurare imposibilă: { $reason }


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
    [0] Reparare terminată: nicio anomalie găsită. Etape jurnalizate: { $lines }.
    [one] Reparare terminată: o anomalie reparată. Etape jurnalizate: { $lines }.
    [few] Reparare terminată: { $anomalies } anomalii reparate. Etape jurnalizate: { $lines }.
   *[other] Reparare terminată: { $anomalies } de anomalii reparate. Etape jurnalizate: { $lines }.
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
licence-logo-alt = Logoul GNU General Public License versiunea 3
licence-name = GNU GPL v3 sau ulterioară
licence-intro = Radinus este software liber.
licence-freedoms-title = Licența sa vă oferă patru libertăți:
licence-freedom-use = Să îl folosiți cum doriți, pentru ce doriți.
licence-freedom-study = Să îi studiați codul sursă, deschis tuturor.
licence-freedom-share = Să îl copiați și să îl dați altora.
licence-freedom-improve = Să îl modificați și să vă împărtășiți modificările.
licence-read = Citiți textul complet al licenței
licence-info = Textul oficial se deschide în browserul dumneavoastră, pe gnu.org.

