# Radinus — meddelanden på core-sidan (Fluent), svenska.
# Fylls på efterhand som de core-moduler som skapar meddelanden till
# användaren blir färdiga. Se 08_ARCHITECTURE.md §2.1.

# Platshållaren ”0 = Ej angivet” som varje valfri koppling till grunddata
# använder (02_BASE_DE_DONNEES.md §7 regel 2). Visas överst i varje kombiruta.
# ---------------------------------------------------------------------
# Språkets namn, skrivet på sitt eget språk.
#
# Det är det som menyn Inställningar och väljaren vid första starten
# visar (01_CAHIER_DES_CHARGES.md §3.5: ”varje språk skrivet på sitt
# eget språk”). Det står här och inte i koden, för det är den enda plats
# där det kan vara riktigt: att lägga till ett språk är att lägga dit en
# fil som kan namnge sig själv.
# ---------------------------------------------------------------------
language-name = Svenska

nomenclature-unspecified = Ej angivet

# Frågas innan ett grunddataelement tas bort som transaktioner fortfarande
# använder (02_BASE_DE_DONNEES.md §7 regel 5). Återgiven ord för ord från
# den ursprungliga WinDev-källan (Enreg_Supprimer), typografin inbegripen —
# formuleringen är författarens, den är ingen översättning.
nomenclature-delete-confirm = Transaktioner (banktransaktioner) som har attributet av typen '{ $label }' har upptäckts. Bekräftar du att du vill återställa det här attributet?

# Frågas innan ett grunddataelement tas bort som ingenting använder. Originalet
# tog bort ett sådant element direkt, utan ett ord; Fabrice bad den 25/07/2026
# att en borttagning alltid ska bekräftas — en medvetet vald avvikelse från
# hans egen kod, och den enda i den här modulen.
nomenclature-delete-plain = Bekräftar du borttagningen av ”{ $label }”?

# Nekande som visas när elementet användaren håller på att ta bort är just det
# som dess kort visar. Fabrices beslut den 25/07/2026: ett element tas inte
# bort under sitt eget öppna kort — kortet stängs först, i stället för att
# lämnas visande en post som inte längre finns.
nomenclature-delete-form-open = Kortet för ”{ $label }” är öppet. Stäng det innan du tar bort.

# Nekande som visas när beskrivningen som sparas redan bärs av ett annat element
# i samma grunddata (författarens beslut, 25/07/2026: två element i samma
# grunddata får inte dela namn — att sortera in en transaktion under en av två
# identiska beskrivningar är en slantsingling). `element` är substantivet med
# sitt eget genus, ”en kategori”, ”en motpart”; `label` är den befintliga
# beskrivningen, så som den är lagrad, så att användaren ser vad som står i vägen.
nomenclature-duplicate = Det finns redan { $element } med samma namn: ”{ $label }”.

# ---------------------------------------------------------------------
# Vad fönstren säger om sig själva.
#
# Allt står här, även det som beror på de grunddata som visas: meningarna
# är utskrivna i sin helhet, språk för språk, i stället för att byggas ihop
# av ord och genus. En hopbyggnad som är riktig på franska är fel i nästa
# språk, och det slutar med att koden vet att det finns ett femininum — det
# är inte dess uppgift (författarens regel, 25/07/2026: ”programmet fungerar
# med Fluent på franska och engelska redan från början”).
# ---------------------------------------------------------------------

ui-loading = Läser in…
ui-editing = Redigering.
ui-viewing = Visning.
ui-modified-suffix = — ändrad
ui-label-required = Beskrivningen är obligatorisk.
ui-discard-question = Vill du kasta ändringarna?
ui-yes = Ja
ui-no = Nej
ui-select-record = Välj en post
ui-key-multiselect = CTRL
ui-multiselect-help = Info: Använd musklick + tangenten [{ $modifier }] i tabellen för att välja flera element
ui-no-match = Ingen beskrivning motsvarar filtret.
ui-filter-placeholder = Filtrera beskrivningar…
ui-column-label = BESKRIVNING
ui-field-label = Beskrivning
ui-field-budget-line = Budgetpost
ui-identifier = Identifierare
ui-deletion-abandoned = Borttagningen avbröts: ingenting har ändrats.
ui-unknown-nomenclature = Okända grunddata:

ui-title-filter = Filtrera
ui-title-create = Skapa
ui-title-update = Redigera markeringen
ui-title-delete = Ta bort markeringen
ui-title-read = Visa markeringen
ui-title-close = Stäng
ui-title-save = Spara
ui-title-add = Lägg till
ui-title-modify = Redigera

ui-load-failed = Kan inte läsa in:
ui-save-failed = Kan inte spara:
ui-read-failed = Kan inte läsa:
ui-delete-failed = Kan inte ta bort:
ui-open-failed = Kan inte öppna:
ui-close-failed = Kan inte stänga:

# --- Meningar som hör till varje slags grunddata ----------------------

nomenclature-identifier = { $kind ->
    [category] Identifierare för kategori
    [assignment] Identifierare för tilldelning
    [payment-mode] Identifierare för betalningssätt
    [payee] Identifierare för motpart
    [project] Identifierare för projekt
    [budget-line] Identifierare för budgetpost
   *[bank] Identifierare för bank
}

nomenclature-none = { $kind ->
    [category] Ingen kategori.
    [assignment] Ingen tilldelning.
    [payment-mode] Inget betalningssätt.
    [payee] Ingen motpart.
    [project] Inget projekt.
    [budget-line] Ingen budgetpost.
   *[bank] Ingen bank.
}

nomenclature-nothing-to-show = { $kind ->
    [category] Ingen kategori att visa.
    [assignment] Ingen tilldelning att visa.
    [payment-mode] Inget betalningssätt att visa.
    [payee] Ingen motpart att visa.
    [project] Inget projekt att visa.
    [budget-line] Ingen budgetpost att visa.
   *[bank] Ingen bank att visa.
}

nomenclature-gone = { $kind ->
    [category] Den här kategorin finns inte längre.
    [assignment] Den här tilldelningen finns inte längre.
    [payment-mode] Det här betalningssättet finns inte längre.
    [payee] Den här motparten finns inte längre.
    [project] Det här projektet finns inte längre.
    [budget-line] Den här budgetposten finns inte längre.
   *[bank] Den här banken finns inte längre.
}

nomenclature-fresh = { $kind ->
    [category] Ny kategori.
    [assignment] Ny tilldelning.
    [payment-mode] Nytt betalningssätt.
    [payee] Ny motpart.
    [project] Nytt projekt.
    [budget-line] Ny budgetpost.
   *[bank] Ny bank.
}

nomenclature-created = { $kind ->
    [category] Kategori tillagd.
    [assignment] Tilldelning tillagd.
    [payment-mode] Betalningssätt tillagt.
    [payee] Motpart tillagd.
    [project] Projekt tillagt.
    [budget-line] Budgetpost tillagd.
   *[bank] Bank tillagd.
}

nomenclature-updated = { $kind ->
    [category] Kategori ändrad.
    [assignment] Tilldelning ändrad.
    [payment-mode] Betalningssätt ändrat.
    [payee] Motpart ändrad.
    [project] Projekt ändrat.
    [budget-line] Budgetpost ändrad.
   *[bank] Bank ändrad.
}

nomenclature-deleted = { $kind ->
    [category] { $count ->
        [one] 1 kategori borttagen.
       *[other] { $count } kategorier borttagna.
      }
    [assignment] { $count ->
        [one] 1 tilldelning borttagen.
       *[other] { $count } tilldelningar borttagna.
      }
    [payment-mode] { $count ->
        [one] 1 betalningssätt borttaget.
       *[other] { $count } betalningssätt borttagna.
      }
    [payee] { $count ->
        [one] 1 motpart borttagen.
       *[other] { $count } motparter borttagna.
      }
    [project] { $count ->
        [one] 1 projekt borttaget.
       *[other] { $count } projekt borttagna.
      }
    [budget-line] { $count ->
        [one] 1 budgetpost borttagen.
       *[other] { $count } budgetposter borttagna.
      }
   *[bank] { $count ->
        [one] 1 bank borttagen.
       *[other] { $count } banker borttagna.
      }
}

nomenclature-duplicate-name = { $kind ->
    [category] Det finns redan en kategori med samma namn: ”{ $label }”.
    [assignment] Det finns redan en tilldelning med samma namn: ”{ $label }”.
    [payment-mode] Det finns redan ett betalningssätt med samma namn: ”{ $label }”.
    [payee] Det finns redan en motpart med samma namn: ”{ $label }”.
    [project] Det finns redan ett projekt med samma namn: ”{ $label }”.
    [budget-line] Det finns redan en budgetpost med samma namn: ”{ $label }”.
   *[bank] Det finns redan en bank med samma namn: ”{ $label }”.
}

# --- Fönstertitlar, utan accenter som på de ursprungliga fönstren -----

window-list-title = { $kind ->
    [category] Lista över kategorier
    [assignment] Lista över tilldelningar
    [payment-mode] Lista över betalningssätt
    [payee] Lista över motparter och handlare
    [project] Lista över projekt
    [budget-line] Lista över budgetposter
   *[bank] Lista över banker
}

window-form-title = { $kind ->
    [category] Kort för kategori
    [assignment] Kort för tilldelning
    [payment-mode] Kort för betalningssätt
    [payee] Kort för motpart
    [project] Kort för projekt
    [budget-line] Kort för budgetpost
   *[bank] Kort för bank
}

# --- Menyrad (01_CAHIER_DES_CHARGES.md §6) ---------------------------

menu-file = Arkiv
menu-file-import-statements = Import av kontoutdrag
menu-file-import-excel = Import av Excel-fil
menu-file-backup = Säkerhetskopiering
menu-file-restore = Återställning
menu-file-repair = Reparation och optimering av databasen
menu-file-log = Visa loggen
menu-tools-password = Skydda databasen med ett lösenord
menu-file-disconnect = Koppla från den aktuella databasen
menu-file-quit = Avsluta

menu-accounts = Konton
menu-accounts-manage = Hantering av bankkonton
menu-accounts-balances = Visa saldon för dina konton
menu-accounts-operations = Hantera transaktionerna på ett konto
menu-accounts-quick-classify = Snabb klassificering av transaktioner
menu-accounts-recurring = Hantering av återkommande transaktioner
menu-accounts-transfer = Överför ett belopp mellan två konton
menu-accounts-checkbooks = Hantering av checkhäften

menu-statistics = Statistik
menu-statistics-balance-chart = Diagram Saldots utveckling
menu-statistics-balance-analysis = Analys Saldots utveckling
menu-statistics-by-category = Statistik per kategori
menu-statistics-by-assignment = Statistik per tilldelning
menu-statistics-by-budget-line = Statistik per budgetpost
menu-statistics-by-payment-mode = Statistik per betalningssätt
menu-statistics-by-payee = Statistik per motpart och handlare
menu-statistics-by-project = Statistik per projekt
menu-statistics-by-verification = Statistik per kontroll
menu-statistics-dashboard = Instrumentpanel för transaktioner
menu-statistics-crossed-balance = Korsbalans

menu-budget = Budget
menu-budget-entry = Budgetregistrering
menu-budget-control = Budgetkontroll

menu-nomenclatures = Grunddata
menu-nomenclature = { $kind ->
    [category] Kategorier
    [assignment] Tilldelningar
    [payment-mode] Betalningssätt
    [payee] Motparter och handlare
    [project] Projekt
    [budget-line] Budgetposter
   *[bank] Banker
}
menu-nomenclatures-templates = Transaktionsmallar

# Le menu Outils (Fabrice, 09/10/2026), entre Nomenclatures et Paramètres.
menu-tools = Verktyg
menu-settings = Inställningar
menu-settings-about-author = Om upphovsmannen
menu-settings-about-radinus = Om Radinus
menu-settings-licence = Licens

menu-misc = Övrigt
menu-misc-calculator = Kalkylator
menu-misc-website = Gå till Radinus webbplats
menu-misc-database-folder = Öppna mappen som innehåller databasen

# L'avertissement posé devant ce dossier (Fabrice, 08/08/2026) : « un
# utilisateur ignorant peut faire des bêtises ». La question est posée
# avant l'ouverture, jamais après.
database-folder-warning-title = Öppna databasens mapp
database-folder-warning =
    Den här mappen innehåller alla dina data. Att byta namn på, flytta eller ta bort en fil kan förlora dina konton, skada dem eller hindra Radinus från att fungera.
    Vill du verkligen öppna den?
menu-misc-application-folder = Öppna mappen som innehåller programmet
menu-misc-attachments-folder = Åtkomst till mappen med bilagorna
# --- « Gestion des pièces jointes » (08/08/2026) -------------------------
#
# La fenêtre montre les pièces de toutes les opérations, plus les fichiers
# du dossier que la base ne réclame pas. Les cinq états ne sont pas trois :
# un fichier disparu, un fichier modifié et un fichier qu'on ne sait pas
# juger ne se traitent pas de la même façon.
menu-settings-attachments = Hantera bilagorna
window-attachments-manager-title = Hantera bilagorna
attachments-column-document = Dokument
attachments-column-size = Storlek
attachments-column-added = Tillagd den
attachments-column-state = Tillstånd
attachments-state-intact = Oförändrad
attachments-state-altered = Ändrad sedan dess
attachments-state-missing = Filen saknas
attachments-state-unknown = Kan ej kontrolleras
attachments-state-orphan = Föräldralös
attachments-no-operation = Ingen transaktion
attachments-orphan-remove-question = Den här filen hör inte till någon transaktion. Flytta den till papperskorgen?
attachments-manager-help = Dubbelklicka på en rad för att öppna dokumentet.

# Les deux entrées du clic droit. « Afficher l'opération » n'apparaît pas
# sur un orphelin — il n'appartient à aucune opération — et « Révéler »
# disparaît quand le fichier n'est plus sur le disque.
attachments-show-operation = Visa transaktionen
attachments-reveal = Visa i filhanteraren
attachments-manager-summary = { $count } bilagor, { $size } totalt.
attachments-disk-name = Namn på disken: { $name }

# L'avertissement du dossier des pièces jointes (Fabrice, 08/08/2026).
# Le danger n'y est pas le même que pour la base : on ne perd pas des
# comptes, on casse un lien — l'opération annonce une pièce qui ne
# s'ouvre plus. C'est ce que dit la phrase, plutôt que « ne faites pas
# n'importe quoi ».
attachments-folder-warning-title = Öppna bilagornas mapp
attachments-folder-warning =
    Den här mappen innehåller filerna du bifogat till dina transaktioner. Radinus lagrar dem under ett namn som det väljer själv: att byta namn på, flytta eller ta bort en fil lossar den inte från transaktionen, som fortsätter att visa den fast den inte längre öppnas.
    Vill du verkligen öppna den?

# ---------------------------------------------------------------------
# Bankkonton — F04, F06, F07, F08.
# Skrivfelen i version 1.9.3 (”Bank Identifer Code”, ”Solde
# initial prevu”, ”Est Cloturé”, mellanslaget före IBAN-parentesen)
# är rättade: beslut av Fabrice den 25/07/2026.
# ---------------------------------------------------------------------

window-accounts-title = Hantering av bankkonton
window-accounts-select-title = Lista över konton
window-balances-title = Saldon för dina konton
window-account-title = Kontokort

accounts-none = Inget konto.
accounts-nothing-to-show = Inget konto att visa.
accounts-gone = Det här kontot finns inte längre.
accounts-fresh = Nytt konto.
accounts-created = Kontot har lagts till.
accounts-updated = Kontot har ändrats.
accounts-deleted = { $count ->
    [one] 1 konto borttaget.
   *[other] { $count } konton borttagna.
}
accounts-duplicate-name = Det finns redan ett konto med samma namn: ”{ $label }”.
accounts-multiselect-help = Info: Använd musklick + tangenten [{ $modifier }] i tabellen för att välja flera konton
accounts-select-question = Vilka bankkonton ska statistiken baseras på?

accounts-column-label = BESKRIVNING
accounts-column-bank = Bank
accounts-column-type = Kontotyp
accounts-column-number = Kontonr
accounts-column-account = Konto
accounts-column-bank-balance = Banksaldo
accounts-column-real-balance = Verkligt
accounts-column-final-balance = Slutligt
accounts-total = TOTALT

# När ett konto tas bort följer dess transaktioner med: det är det enda stället
# i programmet där en borttagning förstör historik.
accounts-delete-plain = Bekräftar du borttagningen av kontot ”{ $label }”?
accounts-delete-with-operations = Kontot ”{ $label }” innehåller { $count } transaktioner, som tas bort tillsammans med det. Bekräftar du borttagningen?
accounts-delete-form-open = Kontokortet för ”{ $label }” är öppet. Stäng det innan du tar bort.

account-group-bank = Konto- och bankuppgifter
account-group-holder = Kontoinnehavare
account-group-rib = Bankuppgifter (RIB)
account-group-activity = Aktivitet
account-group-balances = Saldon

account-field-label = Kontonamn
account-field-bank = Bank
account-field-type = Kontotyp
account-field-branch-address = Bankkontorets adress
account-field-holder-name = Namn
account-field-holder-address = Adress
account-field-rib-bank = Bankkod
account-field-rib-branch = Kontorskod
account-field-rib-number = Kontonummer
account-field-rib-key = RIB-kontrollsiffror
account-field-bic = BIC (Bank Identifier Code)
account-field-iban = IBAN (International Bank Account Number)
account-field-opening-date = Öppningsdatum
account-field-closing-date = Avslutsdatum
account-field-closed = Är avslutat
account-field-opening-pointed = Avstämt ingående saldo
account-field-opening-committed = Reserverat ingående saldo
account-field-opening-planned = Planerat ingående saldo

account-label-required = Kontonamnet är obligatoriskt.
account-iban-invalid = Detta IBAN är inte giltigt: kontrollera kontrollsiffrorna.
# Den blå raden längst ned på kontokortet, ord för ord den från 1.9.3 — bara
# beloppen följer numera samma format som de övriga fälten.
account-control-line = Avstämt ingående saldo ({ $opening }) + Summa transaktioner ({ $operations }) = Aktuellt banksaldo: { $balance }.

amount-not-readable = ”{ $field }” innehåller inte ett giltigt belopp.

ui-thousands-separator =  
ui-decimal-separator = ,

# --- Transaktionslista (F02) -----------------------------------------

window-operations-title = Transaktionslista för kontot: { $account }

operations-none = Inga transaktioner under den här perioden.
operations-bad-period = Periodens gränser är inte giltiga datum.
operations-from = Startdatum
operations-to = Slutdatum
operations-delete-confirm = { $count ->
    [one] Bekräftar du borttagningen av den här transaktionen?
   *[other] Bekräftar du borttagningen av de här { $count } raderna? Deltransaktionerna till de valda transaktionerna följer med dem.
}
operations-deleted = { $count ->
    [one] 1 transaktion borttagen.
   *[other] { $count } transaktioner borttagna.
}
operations-selection-total = Totalt belopp för de valda transaktionerna: { $amount }

operations-column-date = Datum
operations-column-clearing-date = Avstämningsdatum
operations-column-status = Transaktionsstatus
operation-status-pointed = Avstämd
operation-status-committed = Reserverad
operation-status-planned = Planerad
operations-column-verification = Kontroll
operation-verification-to-verify = Att kontrollera
operation-verification-verified = Kontrollerad
operation-verification-doubtful = Tveksam
operation-verification-disputed = Bestridd
operations-column-label = Beskrivning
operations-column-category = Kategori
operations-column-assignment = Tilldelning
operations-column-payment-mode = Betalsätt
operations-column-payee = Motpart
operations-column-project = Projekt
operations-column-month = Månad
operations-column-debit = Debet
operations-column-credit = Kredit
operations-column-balance = Saldo
operations-column-comments = Kommentarer
operations-column-attachments = Bilagor
operations-column-check = Checknr

operations-foot-debit = Debet:
operations-foot-credit = Kredit:
operations-foot-total = Totalt:
operations-foot-bank = Banksaldo:
operations-foot-real = Verkligt saldo:
operations-foot-final = Slutsaldo:

operations-menu-export = Export
operations-menu-print = Utskrift
operations-menu-filter = Filter
operations-menu-period = Period
operations-menu-misc = Övrigt

operations-title-point = Stäm av markeringen
operations-title-sub = Lägg till en deltransaktion
operations-title-duplicate = Duplicera markeringen
operations-not-yet = Det här fönstret finns inte än: det kommer längre fram i planen.

accounts-choose-question = Vilket konto vill du arbeta med?
ui-title-select = Välj markering

month-january = januari
month-february = februari
month-march = mars
month-april = april
month-may = maj
month-june = juni
month-july = juli
month-august = augusti
month-september = september
month-october = oktober
month-november = november
month-december = december

operations-period-year = Innevarande år

# --- Periodmenyn i F02 -----------------------------------------------
# Nio poster, varav två öppnar en undermeny med de tolv månaderna. Var och en
# gör bara en sak: härleda ett startdatum och ett slutdatum, som fönstret
# lägger tillbaka i sina två fält (önskemål från Fabrice, 25/07/2026).

period-all = Alla
period-last-year = Förra Året
period-this-year = Innevarande År
period-whole-year = Hela året
period-last-month = Förra Månaden
period-this-month = Innevarande Månad
period-last-week = Förra Veckan
period-this-week = Innevarande Vecka
period-yesterday = Igår
period-today = Idag

# --- Filtermenyn i F02 -----------------------------------------------
# Filtrerar raderna efter transaktionens art (önskemål från Fabrice,
# 25/07/2026). De tre statusvärdena är databasens: 1 avstämd, 2 reserverad,
# 3 planerad (02_BASE_DE_DONNEES.md §5.2).

filter-all = Alla transaktioner
filter-pointed = Endast avstämda transaktioner
filter-committed = Endast reserverade transaktioner
filter-planned = Endast planerade transaktioner
filter-by-status = Filtrera efter status
filter-by-verification = Filtrera efter kontroll
filter-show-all = Visa alla

# --- Transaktionsformulär (F03) --------------------------------------
# Etiketterna är hämtade från skärmbilden ”Fiche operation transaction.png”,
# med originalets stavfel rättade (godkänt av Fabrice, 25/07/2026:
# ”les coquilles tu les corriges”): ”Libelle” blir ”Libellé”,
# ”Categorie” blir ”Catégorie”, ”Statut Operation” blir
# ”Statut opération”.

window-operation-title = Transaktion konto: { $account }

operation-menu-identification = Identifiering
operation-menu-options = Alternativ
operation-fitid-edit = Redigera FITID…
operation-fitid-delete = Ta bort FITID
operation-fitid-question = FITID för denna transaktion:
operation-fitid-delete-question = Ta bort FITID för denna transaktion?
operation-fitid-written = FITID sparat.
operation-fitid-removed = FITID borttaget.

operation-group-identification = Identifiering av transaktionen
operation-group-amount = Transaktionens belopp
operation-group-status = Transaktionens status
operation-group-classification = Klassificering av transaktionen för beräkning av statistiken
operation-group-check = Check kopplad till transaktionen
operation-group-comment = Kommentar

operation-field-label = Beskrivning
operation-field-reference = Betalningsreferens
operation-field-date = Datum
operation-field-direction = Transaktionstyp:
operation-field-amount = Belopp
operation-field-status = Transaktionsstatus
operation-field-clearing-date = Avstämningsdatum
operation-field-verification = Kontroll
operation-field-category = Kategori
operation-field-assignment = Tilldelning
operation-field-payment-mode = Sätt
operation-field-payee = Motpart
operation-field-project = Projekt
operation-field-check = Koppla till check

operation-direction-debit = Debet
operation-direction-credit = Kredit

operation-check-info = Info.
operation-check-link = Koppla
operation-check-unlink = Ta bort

operation-fresh = Ny transaktion.
operation-created = Transaktion tillagd.
operation-updated = Transaktion ändrad.
operation-gone = Den här transaktionen finns inte längre.
operation-nothing-to-show = Ingen transaktion att visa.
operation-label-required = Transaktionens beskrivning är obligatorisk.
operation-date-required = Transaktionens datum är obligatoriskt.
operation-clearing-date-invalid = Avstämningsdatumet är inte ett giltigt datum.
operation-clearing-date-required = En avprickad transaktion måste ha ett avprickningsdatum.
operation-clearing-date-question =
    En avprickad transaktion måste ha ett avprickningsdatum.
    Vill du spara med transaktionens eget datum, { $date }?
operation-is-a-sub = Den här raden är en deltransaktion: den ändras från sitt eget formulär.
operation-delete-form-open = Formuläret för ”{ $label }” är öppet. Stäng det innan du tar bort.

operation-attachments = { $count ->
    [0] Ingen bilaga
    [one] 1 bilaga
   *[other] { $count } bilagor
}

operation-title-comment = Kommentar till transaktionen
operation-title-sub = Skapa en deltransaktion
operation-title-template = Transaktionsmallar
operation-title-attachment = Bilagor

# --- Formulär för deltransaktion (F04) -------------------------------
# Nedbantad version av F03: varken Sätt, Status eller Datum — en
# deltransaktion ärver dem från sin moder (`Maj_ProprieteSousOp`, bekräftat
# av Fabrice den 26/07/2026: ”dans une sous-opération, comme est le
# complément, on ne peut pas toucher au mode de paiement, cela serait illogique”).

window-sub-operation-title = Formulär Deltransaktion

sub-operation-group-amount = Deltransaktionens belopp
sub-operation-field-label = Namn
sub-operation-fresh = Ny deltransaktion.
sub-operation-created = Deltransaktion tillagd.
sub-operation-updated = Deltransaktion ändrad.
sub-operation-gone = Den här deltransaktionen finns inte längre.
sub-operation-nothing-to-show = Ingen deltransaktion att visa.
sub-operation-label-required = Deltransaktionens namn är obligatoriskt.
sub-operation-parent-gone = Transaktionen som ska fördelas finns inte längre.
# Vad formuläret säger när det visar Resten. Den är inte skyddad: den går att
# ändra, men man måste veta vad man ger sig in på (beslut av Fabrice,
# 26/07/2026).
sub-operation-is-the-complement = Det här är Resten: det som återstår att fördela. Byter du namn på den eller ändrar dess belopp blir den en vanlig deltransaktion.
sub-operation-of = Fördelning av ”{ $label }” ({ $amount })

operations-pointed = { $count ->
    [0] Ingen transaktion att stämma av: markeringen är redan avstämd.
    [one] 1 transaktion avstämd.
   *[other] { $count } transaktioner avstämda.
}
operations-select-one = Välj endast en transaktion.

# --- Duplicera och visningen av deltransaktionerna (F02) --------------
# Duplicera öppnar ett förifyllt formulär som användaren själv bekräftar
# (beslut av Fabrice, 26/07/2026): ingenting skrivs så länge han inte har
# sparat, och han kan rätta datumet eller beloppet innan.

operation-copy = Kopia att spara: ingenting har skapats ännu.
operations-show-children = Visa alla deltransaktioner
operations-hide-children = Dölj alla deltransaktioner
operations-recurring-from = Skapa en återkommande transaktion från den här transaktionen

# --- Andra bekräftelsen vid en allvarlig borttagning ------------------
# Att ta bort ett bankkonto drar med sig hela dess historik: ett Ja/Nej
# klickas bort utan att läsas, så vi ber om att ordet skrivs (beslut av
# Fabrice, 26/07/2026). Ordet är ordbokens — ”Ja” här, ”Yes” på engelska —
# alltså finns det inget att översätta två gånger här.

accounts-delete-second-question = Den här borttagningen är slutgiltig och drar med sig kontots hela historik. Skriv ”{ $word }” för att bekräfta den.

# --- F20-F24 — De sex statistikerna -----------------------------------
# Gemensam mall, utvecklad längs sex axlar. Den per kategori fick tjäna som
# förlaga och Fabrice godkände den den 26/07/2026 innan de fem andra fanns —
# kolumnnamnen är originalets.

window-statistics-title = { $kind ->
    [assignment] Statistik per tilldelning
    [budget-line] Statistik per budgetpost
    [payment-mode] Statistik per betalningssätt
    [payee] Statistik per motpart och handlare
    [project] Statistik per projekt
    [verification] Statistik per kontroll
   *[category] Statistik per kategori
}

statistics-axis-column = { $kind ->
    [assignment] Tilldelning
    [budget-line] BudgetPost
    [payment-mode] TransaktionsSätt
    [payee] Motpart
    [project] Projekt
    [verification] Kontroll
   *[category] KategoriNamn
}

statistics-unclassified = { $kind ->
    [assignment] Utan tilldelning
    [budget-line] Utan budgetpost
    [payment-mode] Utan betalningssätt
    [payee] Utan motpart
    [project] Utan projekt
    [verification] Att kontrollera
   *[category] Utan kategori
}
statistics-total = Totalt
statistics-sum = Summa
statistics-cumulative = Ackumulerat

# Bandets fem strömbrytare. Etiketten växlar ON/OFF, precis som i originalet:
# det är strömbrytaren själv som säger var den står.
statistics-switch-pointed = Avstämda transaktioner { $state }
statistics-switch-committed = Reserverade transaktioner { $state }
statistics-switch-planned = Planerade transaktioner { $state }
statistics-switch-debits = Debetbelopp { $state }
statistics-switch-credits = Kreditbelopp { $state }
statistics-switch-on = ON
statistics-switch-off = OFF

statistics-no-account = Inget konto har valts: statistiken omfattar ingenting.
statistics-no-data = Ingen transaktion under det här året för de valda kontona.
statistics-detail-empty = Klicka på en ruta med siffror för att se transaktionerna den räknar.
statistics-detail-none = Ingen transaktion bakom den här rutan.
statistics-accounts = { $count ->
    [one] 1 konto
   *[other] { $count } konton
}
statistics-year-next = Nästa år
statistics-year-previous = Föregående år

statistics-column-date = Datum
statistics-column-clearing-date = AvstämningsDatum
statistics-column-label = Beskrivning
statistics-column-amount = Belopp
statistics-column-comments = Kommentarer

accounts-stats-multiselect-help = Info: Använd musklick + tangenten [{ $modifier }] i tabellen för att välja flera konton

# Statistikens årtal: man klickar på det och skriver in ett år. Gränserna är
# desamma som för ”Alla” i menyn Period — ett år i Radinus är ett heltal
# mellan 1950 och 2550 (Fabrice, 26/07/2026).
statistics-year-question = Vilket år vill du arbeta med? Radinus går från { $first } till { $last }.
statistics-year-choose = Välj år

# --- F27, le bilan croisé (Fabrice, 25/08/2026) ---------------------
# Les catégories en lignes, les affectations en colonnes, sur un mois.
# Tout le reste de son vocabulaire est celui des statistiques : Total,
# Somme, les interrupteurs, « Sans … », les colonnes du détail.
window-crossed-balance-title = Korsbalans
crossed-balance-window-name = Korsbalans
crossed-balance-column = Kategori
crossed-balance-no-data = Ingen transaktion denna månad för de valda kontona.
crossed-balance-month-question = Vilken månad vill du arbeta med? Ett tal mellan { $first } och { $last }.
crossed-balance-month-choose = Välj månad
crossed-balance-next = Nästa månad
crossed-balance-previous = Föregående månad

# --- Export av tabellerna (högerklick) --------------------------------
# En funktion hos tabellen, inte hos ett fönster: alla listor har den.

export-to-excel = Exportera till Excel (.xlsx)
export-to-word = Exportera till Word (.docx)
export-to-tsv = Exportera till TSV (.tsv)
export-to-ini = Exportera till INI (.ini)
export-to-toml = Exportera till TOML (.toml)
export-to-yaml = Exportera till YAML (.yaml)
export-to-ofx = Exportera till OFX (.ofx)
export-to-qif = Exportera till QIF (.qif)
export-to-ods = Exportera till LibreOffice Calc (.ods)
export-to-csv = Exportera till CSV (.csv)
export-to-xml = Exportera till XML (.xml)
# Exportmenyn i statistikfönstret: en flik per år, med namnet AN_2026. De
# tomma åren — med de inställda strömbrytarna — finns inte med.
export-menu = Export
export-to = Exportera till
# Copying from a table (Fabrice, 07/10/2026): the two entries at the head of
# the right-click menu, and what is said when the clipboard refuses.
copy-cell = Kopiera cellen
copy-rows = Kopiera markerade rader
copy-failed = Det gick inte att kopiera till urklipp.
export-all-years-excel = Exportera alla år till Excel
export-all-years-ods = Exportera alla år till LibreOffice Calc
export-all-months-excel = Exportera alla månader för det visade året till Excel
export-all-months-ods = Exportera alla månader för det visade året till LibreOffice Calc
export-no-year = Inget år innehåller någon transaktion: det finns inget att exportera.
export-years-done = { $years } år exporterade till ”{ $file }”.
export-to-json = Exportera till JSON (.json)
export-done = Exporterat till ”{ $file }”.
export-failed = Export omöjlig: { $reason }
export-nothing = Det finns inget att exportera.
export-context = { $window } — { $detail }
statistics-window-name = { $kind ->
    [assignment] Statistik per tilldelning
    [budget-line] Statistik per budgetpost
    [payment-mode] Statistik per betalningssätt
    [payee] Statistik per motpart och handlare
    [project] Statistik per projekt
    [verification] Statistik per kontroll
   *[category] Statistik per kategori
}
statistics-detail-name = Statistikdetaljer

# --- F19 — Översikt ---------------------------------------------------
# En period och tre reglage; två ringdiagram per budgetpost;
# tre stora tal. Sektorernas färger är originalets, avlästa på
# Fabrices skärmbild.

window-dashboard-title = Översikt
dashboard-menu-period = Period
dashboard-menu-misc = Diverse
dashboard-from = Startdatum:
dashboard-to = Slutdatum:
dashboard-switch-pointed = Inkludera avstämda transaktioner
dashboard-switch-committed = Inkludera reserverade transaktioner
dashboard-switch-planned = Inkludera planerade transaktioner
dashboard-spending = Utgifter
dashboard-earning = Inkomster
dashboard-debits = Summa debettransaktioner
dashboard-credits = Summa kredittransaktioner
dashboard-balance = Balans
dashboard-unclassified = Utan budgetpost
dashboard-nothing = Inga transaktioner under den här perioden.
dashboard-no-account = Inget konto har valts: översikten visar ingenting.
dashboard-enlarge = Öppna i stort format

# --- F25 — Saldoutveckling ---------------------------------------------
# En kurva per valt konto, plus totalens — som bara finns från och med
# två konton (Fabrices regel, 26/07/2026). Kurvorna är trappstegsformade:
# saldot behåller sitt värde fram till nästa transaktion.

window-curve-title = Saldoutveckling
curve-heading = Saldoutveckling per dag
curve-menu-period = Period
curve-total = Totalt
curve-from = Startdatum:
curve-to = Slutdatum:
curve-axis-balance = saldo
curve-nothing = Inget konto har valts: det finns ingen kurva att rita.
curve-empty = Inga transaktioner under den här perioden.

# F40 — « Analyse Évolution du solde » (Fabrice, 05/10/2026): the chart of F25,
# on which one drags a zone, and under it the operations of that zone. The
# chart's own words are F25's (curve-*); these are the summary of the zone.
window-analysis-title = Analys av saldoutvecklingen
analysis-heading = Analys av saldoutvecklingen
analysis-hint = Dra över diagrammet med musknappen nedtryckt för att se transaktionerna under den perioden.
analysis-zone = Zon:
analysis-opening = Ingående saldo:
analysis-closing = Utgående saldo:
analysis-variation = Förändring:
analysis-detail-name = Saldoanalys
analysis-detail-none = Ingen transaktion i den här zonen.

# --- F05 — Snabb klassificering av transaktioner -----------------------
# Fönstret där man klassificerar **i klump**: man markerar rader, kryssar i
# de egenskaper som ska ändras och tillämpar dem på en gång — i minnet.
# Ingenting skrivs så länge man inte har sparat, och sparandet skriver bara
# det som skiljer sig från det som lästes in (Fabrices regler,
# 27/07/2026).

window-quick-classification-title = Snabb klassificering av transaktioner: { $account }
quick-dates-title = Listans start- och slutdatum.
quick-from = Startdatum
quick-to = Slutdatum
quick-menu-period = Period
quick-change-title = Ändra markeringens egenskaper till:
quick-check-category = Kategori
quick-check-assignment = Tilldelning
quick-check-payment-mode = Sätt
quick-check-payee = Motpart
quick-check-project = Projekt
quick-check-status = Status
quick-check-verification = Kontroll
quick-column-date = Datum
quick-column-label = Beskrivning
quick-column-amount = Belopp
quick-column-category = Kategori
quick-column-assignment = Tilldelning
quick-column-payment-mode = Betalningssätt
quick-column-payee = Motpart
quick-column-project = Projekt
quick-column-status = Status
quick-column-verification = Kontroll
# På en Mac är Ctrl + klick ett högerklick: tangenten som lägger till i en
# markering är där ⌘, och hjälptexten ska ange den som fungerar.
quick-multiselect-help = Info: Använd musklick + tangenten [{ $modifier }] i tabellen för att markera flera element
quick-none = Inga transaktioner under den här perioden.
quick-select-lines = Markera minst en rad och kryssa i minst en egenskap.
quick-applied = { $count ->
    [0] Ingenting ändrades: raderna hade redan den här klassificeringen.
    [one] 1 rad klassificerad. Ingenting är sparat ännu.
   *[other] { $count } rader klassificerade. Ingenting är sparat ännu.
}
quick-pending = { $count ->
    [0] Inga ändringar väntar.
    [one] 1 rad ändrad, inte sparad.
   *[other] { $count } rader ändrade, inte sparade.
}
quick-save-question = { $count ->
    [one] Spara den väntande ändringen?
   *[other] Spara de { $count } väntande ändringarna?
}
quick-saved = { $count ->
    [0] Det fanns ingenting att spara.
    [one] 1 rad sparad.
   *[other] { $count } rader sparade.
}
quick-nothing-to-save = Inga ändringar väntar.
quick-leave-question = Vissa ändringar är inte sparade. Vad vill du göra?
quick-leave-save = Spara och avsluta
quick-leave-discard = Kasta och avsluta
quick-leave-stay = Stanna kvar
quick-title-apply = Tillämpa på markerade rader ( i minnet )
quick-title-save = Spara till disken

# --- F17 / F18 — Import av ett kontoutdrag -----------------------------
# Man väljer ett konto, öppnar en OFX-fil — som stannar i RAM —, raderna
# som databasen redan känner till visas i pastell, och den tredje ikonen
# för in dem: i klump om flera är valda, annars en och en via
# avstämningsformuläret (Fabrices arbetsgång, 27/07/2026).

window-statement-import-title = Import av kontoutdrag: { $account }
window-statement-form-title = Stäm av en transaktion (för in en transaktion i ditt kontos historik)
statement-menu-filter = Filter
statement-filter-all = Alla rader
statement-filter-pending = Att föra in
statement-filter-known = Redan införda
statement-column-id = ID
statement-column-reconciled = Avstämd
statement-column-fitid = FITID
statement-column-date = Datum
statement-column-label = Beskrivning
statement-column-debit = Debet
statement-column-credit = Kredit
statement-account = Konto
statement-file = Fil
statement-difference = Differens
statement-none = Inget kontoutdrag är öppet: klicka på den gula mappen för att välja en fil.
statement-empty = Det här kontoutdraget innehåller inga transaktioner.
statement-no-match = Ingen rad motsvarar filtret.
statement-help = Info: Använd musklick + tangenten [{ $modifier }] i tabellen för att markera flera rader
statement-choose-account = Den här filen innehåller flera konton. Vilket vill du importera?
statement-select-line = Markera minst en rad i kontoutdraget.
statement-title-open = Öppna en kontoutdragsfil (OFX, QIF, CSV)
statement-title-info = Information om den öppnade filen
statement-title-integrate = För in markeringen i kontot
statement-title-validate = För in den här transaktionen i kontot
statement-duplicate = Varning dubblett: den här transaktionen verkar redan ha förts in i databasen (Financial Institution Transaction ID finns)
statement-no-fitid = Varning: den här filen anger ingen identifierare (FITID) för den här raden. En dubblett kan inte upptäckas.
statement-loaded = { $count ->
    [0] Den här filen innehåller inga transaktioner för det här kontot.
   *[other] { $count } rader lästa, varav { $known } redan finns i ditt konto.
}
statement-loaded-unidentified = { $alike ->
    [0] { $count } rader lästa; ingen liknar en transaktion som redan finns i ditt konto.
    [one] { $count } rader lästa, varav en liknar en transaktion som redan finns i ditt konto (samma datum, samma beskrivning, samma belopp).
   *[other] { $count } rader lästa, varav { $alike } liknar transaktioner som redan finns i ditt konto (samma datum, samma beskrivning, samma belopp).
}
statement-loaded-also-alike = { $alike ->
    [one] Ytterligare en liknar en transaktion som redan finns (samma datum, samma beskrivning, samma belopp).
   *[other] Ytterligare { $alike } liknar transaktioner som redan finns (samma datum, samma beskrivning, samma belopp).
}
statement-integrated = { $count ->
    [0] Ingenting fördes in: raderna finns redan i ditt konto.
    [one] 1 transaktion införd.
   *[other] { $count } transaktioner införda.
}
# **Originalets meddelanden, ord för ord** (Fabrices anvisning,
# 28/07/2026: hålla sig trogen ursprungskoden). Hans varnar före klumpen,
# frågar rad för rad inför en dubblett och redovisar till slut.

statement-mass-question =
    Är du säker på att du vill föra in flera transaktioner samtidigt i ditt konto?
    Du måste kategorisera och beskriva dem senare för att få exakt statistik
    När det gäller Ofx-filer: om dubbletter upptäcks får du välja hur programmet ska bete sig
    För andra filtyper: du måste själv se upp med dubbletter
statement-duplicate-question =
    Transaktionen: { $date } { $label }: { $amount }
    verkar redan ha förts in i transaktionshistoriken för ditt bankkonto.
    Vill du verkligen genomföra avstämningen?
statement-already-reconciled = Du har redan stämt av den här transaktionen: den finns redan i transaktionshistoriken för ditt konto
statement-integration-report =
    Införandet är klart.
    Antal införda poster: { $added }
    Antal ignorerade poster: { $ignored }
statement-integration-abandoned =
    Införandet avbrutet!
    Antal införda poster: { $added }
    Antal ignorerade poster: { $ignored }
statement-yes = Ja
statement-no = Nej
statement-cancel = Avbryt
statement-file-info =
    Filens konto: { $account }
    Period: från { $from } till { $to }
    Saldo enligt banken: { $balance }
statement-qif-question = Ingenting i den här filen anger om datumet ”{ $date }” skrivs dag/månad eller månad/dag. Det betyder:
statement-qif-day-month = Dag { $day }, månad { $month } (dag/månad)
statement-qif-month-day = Dag { $day }, månad { $month } (månad/dag)
statement-qif-dates-mixed = Den här filen skriver sina datum på två sätt: ”{ $first }” läses dag/månad, ”{ $second }” månad/dag. Den importeras inte, så att inget datum blir fel.
statement-qif-amounts-mixed = Den här filen skriver sina belopp på två sätt: ”{ $first }” med punkt, ”{ $second }” med kommatecken. Den importeras inte, så att inget belopp blir fel.
statement-qif-opening = Ingående saldo på { $amount } den { $date }: det är ingen transaktion och importeras inte.
statement-qif-opening-undated = Ingående saldo på { $amount }: det är ingen transaktion och importeras inte.
statement-qif-suspect = Rad { $rank }, ”{ $label }” ({ $amount }), ser ut som ett ingående saldo: kontrollera den innan du för in den.
statement-qif-rejected = { $count ->
    [one] En oläslig rad importeras inte: { $lines }.
   *[other] { $count } oläsliga rader importeras inte: { $lines }.
}
statement-qif-reason-date = datum
statement-qif-reason-amount = belopp
statement-qif-reason-differ = motstridiga belopp
statement-qif-no-account = Det här kontot finns inte längre i filen: öppna filen igen.
statement-balance-unknown = inte angivet i filen
statement-group-identification = Identifiering av transaktionen
statement-group-amount = Transaktionens belopp
statement-group-classification = Klassificering av transaktionen för statistikberäkning
statement-group-status = Transaktionens status
statement-field-date = Datum
statement-field-label = Beskrivning
statement-field-type = Transaktionstyp
statement-field-amount = Belopp
statement-field-mode = Transaktionssätt
statement-field-category = Kategori
statement-field-assignment = Tilldelning
statement-field-payee = Motpart
statement-field-project = Projekt
statement-field-status = Status
statement-field-clearing = Avstämningsdatum

# --- Fönstret för uppdelning av ett CSV-kontoutdrag --------------------
# En CSV bär inga tillförlitliga fältnamn: man ställer in, testar, tittar,
# börjar om. Förhandsgranskningen visar allt, rappakalja inbegripet — det är
# så man ser att man har haft fel — men bara de giltiga raderna förs vidare
# till importfönstret (Fabrices regel, 27/07/2026).

window-csv-statement-title = Import av data från en csv-fil
csv-preview-title = Förhandsgranskning av filen:
csv-settings-title = Parametrar för uppdelning av filen inför extrahering av data:
csv-extraction-title = Visning av extraherade data enligt uppdelningsparametrarna  ( kontrollera att uppgifterna stämmer ):
csv-column-line = Radnr
csv-column-content = Innehåll
csv-header-lines = Antal rubrikrader i filen som ska ignoreras
csv-separator = Data (kolumner) separeras av tecknet:
csv-date-at = Position för datumfältet
csv-label-at = Position för beskrivningsfältet
csv-debit-at = Position för debetbeloppsfältet
csv-credit-at = Position för kreditbeloppsfältet
csv-test = Testa parametrarna
csv-separator-semicolon = Semikolon   ;
csv-separator-comma = Komma   ,
csv-separator-tab = Tabb
csv-separator-pipe = Lodstreck   |
csv-separator-space = Blanksteg
csv-help = Ställ in, testa, titta: bara rader med ett läsbart datum och belopp importeras.
csv-none = Filen är tom.
csv-not-tested = Klicka på ”Testa parametrarna” för att se vad uppdelningen ger.
csv-extraction = { $count ->
    [0] Uppdelningen ger ingen rad: kontrollera antalet rubrikrader och separatorn.
   *[other] { $count } rader uppdelade: { $valid } kommer att importeras, { $dropped } utelämnas eftersom datum eller belopp inte är läsbart.
}
csv-nothing-valid = Ingen rad har både ett läsbart datum och ett läsbart belopp: det finns ingenting att importera. Kontrollera antalet rubrikrader, separatorn och fältens positioner.
csv-title-validate = För över de giltiga raderna till importen

# --- F13 / F31 / F14 / F12 — Checkhäften och checkar (fas 9) ------------
# Överföring av hans fem WinDev-koder och hans sju skärmbilder, levererade
# 28/07/2026. Hans exakta meningar där han har en; mina i övrigt.
#
# Tre trogenheter som han avgjorde den dagen och som hörs i orden: den
# dubbla referensen aviseras inte (hans `Existe_Reference` anropas aldrig),
# antalet checkar ställs inte mot gränsvärdena, och transaktionsräknaren
# räknar med de deltransaktioner som listorna vägrar.

window-chequebooks-title = Lista över checkhäften
window-chequebook-title = Inställningar checkhäfte
window-cheques-title = Checkhäftets sammansättning: lista över checkar.
window-cheque-title = Checkuppgifter
window-cheque-operations-title = Lista över transaktioner.

# Listan över checkhäften (F13) — alla häften, oavsett konto: hans två
# kontokolumner vore till ingen nytta på ett enda konto.
chequebooks-column-reference = BESKRIVNING
chequebooks-column-date = Datum
chequebooks-column-account = Kontonamn
chequebooks-column-account-number = Kontonr
chequebooks-column-comments = Kommentarer
chequebooks-none = Inget checkhäfte är registrerat.
chequebooks-nothing-to-show = Inget checkhäfte matchar den här sökningen.
chequebooks-title-composition = Visa checkhäftets sammansättning
chequebooks-delete-question = Transaktioner (banktransaktioner) kopplade till checkhäfte har upptäckts. Bekräftar du att du vill ta bort det här checkhäftet?
chequebooks-deleted = { $count ->
    [one] Ett checkhäfte borttaget.
   *[other] { $count } checkhäften borttagna.
}
chequebooks-gone = Det här checkhäftet finns inte längre.
chequebooks-created = Checkhäftet sparat, med alla sina checkar.
chequebooks-updated = Checkhäftet ändrat.
# Tystnaden i hans `HAjoute`: fönstret säger inte att referensen redan är
# tagen. Det säger bara att ingenting har sparats — annars skulle man tro att
# häftet var skapat.
# De åtta försiktighetsåtgärderna i hans ”Precauttion enregistrement
# cheque.txt”, ord för ord och i hans ordning. De sju första är `Erreur()`,
# den åttonde ett `Info()` — och ordningen avgör vad man ser när två saker går
# fel samtidigt.
chequebook-refusal-duplicate = En referens med samma namn finns redan
chequebook-refusal-reference-required = Du måste ange en referens
chequebook-refusal-number-too-big = Numren på den första och/eller den sista checken är för stora (maxvärde 999 999 999)
chequebook-refusal-date = Ange ett giltigt mottagningsdatum
chequebook-refusal-numbers-required = Fyll i numren på den första och den sista checken
chequebook-refusal-order = Numret på den första checken måste vara lägre än numret på den sista checken
chequebook-refusal-account = Du måste välja det konto som hör till det här checkhäftet
chequebook-refusal-too-many = Högsta antal checkar för ett checkhäfte: 1000, gränsen är nådd
# Hans bekräftelsefråga, som bara ställs när något läggs till: den sammanfattar
# vad som ska skapas och varnar för att inget av det går att ändra efteråt.
chequebook-creation-question =
    Skapande av checkhäftet med följande egenskaper:
    - Antal checkar att generera:{ $count }
    - Checkar numrerade från { $first } till { $last }
    Obs! Dessa uppgifter går inte att ändra efter skapandet!

# Checkhäftesbladet (F31). De fem första fälten gråas ut så snart häftet
# finns: dess checkar är redan där.
chequebook-field-id = Checkhäftesidentifierare
chequebook-field-reference = Referens
chequebook-field-received = Tillverkat eller mottaget den
chequebook-field-first = Numret på den första checken
chequebook-field-last = Numret på den sista checken
chequebook-field-quantity = Antal checkar
chequebook-field-account = Koppla till bankkontot:
chequebook-field-comments = Kommentarer
chequebook-locked = Checkarna i det här häftet är redan skapade: numreringen går inte längre att ändra.
# Hans mening, ord för ord (`Enreg_Lire`).
chequebook-account-missing = Bankkontot som det här checkhäftet kopplades till saknas eller har tagits bort!

# Checkhäftets sammansättning (F14). Statusen ändras i rutan.
cheques-column-number = Checknr
cheques-column-date = Datum
cheques-column-place = Ort
cheques-column-payee = Betalningsmottagare
cheques-column-amount = Belopp
cheques-column-status = Status
cheques-column-comments = Kommentarer
cheques-column-operations = Ant. kopplade transaktioner
cheques-none = Det här checkhäftet innehåller ingen check.
cheques-nothing-to-show = Ingen check matchar den här sökningen.
cheques-help = Klicka i rutan Status för att ändra den; förstoringsglaset visar de kopplade transaktionerna, länken kopplar en.
cheques-title-linked = Visa transaktionerna som redan är kopplade till den här checken
cheques-title-link = Koppla en transaktion till den här checken
cheques-status-changed = Checkens status ändrad.

# Checkbladet (F12).
cheque-field-id = Checkidentifierare
cheque-field-number = Checknummer
cheque-field-issued = Utfärdandedatum
cheque-field-place = Utfärdandeort
cheque-field-payee = Betalningsmottagare
cheque-field-amount = Belopp
cheque-field-comments = Kommentarer
cheque-field-status = Checkens status
cheque-gone = Den här checken finns inte längre.
cheque-updated = Checken ändrad.

# Kopplingsfönstrets två ansikten.
cheque-operations-linked-title = Lista över transaktioner som redan är kopplade till den här checken.
cheque-operations-choose-title = Välj en transaktion att koppla till checken
cheque-operations-column-account = Konto
cheque-operations-column-label = Namn
cheque-operations-column-date = Datum
cheque-operations-column-clearing = Avstämningsdatum
cheque-operations-column-amount = Belopp
cheque-operations-column-cheque = Kopplad check
cheque-operations-none-linked = Ingen transaktion är kopplad till den här checken.
cheque-operations-none = Det här kontot innehåller ingen transaktion.
cheque-operations-nothing-to-show = Ingen transaktion matchar den här sökningen.
cheque-operations-help = Transaktionerna i fetstil bär redan en check.
cheque-operations-linked-help = Det röda krysset lossar checken från transaktionen: ingenting tas bort.
cheque-operations-linked = Transaktionen kopplad till checken.
cheque-operations-dissociated = Checken lossad från transaktionen.
cheque-operations-menu-filter = Filter
cheque-title-associate = Koppla den här transaktionen till checken
cheque-title-dissociate = Lossa checken från den här transaktionen

# Banderollen ”Check kopplad till transaktionen” på transaktionsbladet, och
# checkfiskets två steg — först häftet, sedan checken.
chequebooks-select-question = Välj checkhäfte
cheques-select-question = Välj checken som ska kopplas till transaktionen
operation-check-save-first = Spara transaktionen först: en check kopplas till en transaktion som finns.
operation-check-none = Den här transaktionen bär ingen check.

# --- F36 / F37 — Transaktionsmallarna (fas 10) --------------------------
# En mall är en färdig inmatning: man tillämpar den för att slippa skriva om,
# och den **skriver över** det som står i formuläret. Ingenting går ut på
# disken så länge transaktionsformuläret inte har bekräftats (Fabrices regel,
# 29/07/2026).

window-operation-templates-title = Lista över transaktionsmallar
window-operation-template-title = Transaktionsmall

operation-templates-none = Ingen transaktionsmall är registrerad.
operation-templates-nothing-to-show = Ingen mall matchar den här sökningen.
operation-templates-select-question = Välj mallen som ska tillämpas
operation-templates-delete-question = Bekräftar du att de valda mallarna ska tas bort?
operation-templates-deleted = { $count ->
    [one] En mall borttagen.
   *[other] { $count } mallar borttagna.
}
operation-template-gone = Den här mallen finns inte längre.
operation-template-fresh = Ny mall.
operation-template-created = Mallen sparad.
operation-template-updated = Mallen ändrad.
operation-template-label-required = Du måste ange ett namn
operation-template-duplicate = En mall med samma namn finns redan

# Formuläret F36, avsnitt för avsnitt — hans exakta rubriker.
operation-template-field-id = ID transaktionsmall
operation-template-group-name = Standardnamn på den framtida transaktionen efter att mallen tillämpats
operation-template-field-label = Namn
operation-template-group-amount = Transaktionens standardbelopp fördefinierat i den här mallen
operation-template-field-direction = Transaktionstyp
operation-template-field-amount = Belopp
operation-template-group-status = Transaktionens standardstatus i den här mallen
operation-template-field-status = Transaktionsstatus
operation-template-group-classification = Mallens uppgifter för klassificering och beräkning av statistik
operation-template-field-category = Kategori
operation-template-field-assignment = Tilldelning
operation-template-field-mode = Betalningssätt
operation-template-field-payee = Motpart
operation-template-field-project = Projekt

# Knappen ”Mall” på transaktionsformuläret: en ikon, två gester.
operation-template-question = Vad vill du göra med transaktionsmallarna?
operation-template-apply = Tillämpa en mall
operation-template-save-as = Spara som mall
operation-template-applied = Mallen tillämpad. Bekräfta formuläret för att spara den.
operation-template-saved-as = Transaktionen sparad som mall.
operation-template-needs-label = Ge transaktionen ett namn innan du gör en mall av den.

# --- F26 / F27 — Budgeten (fas 11) --------------------------------------
# Två dörrar, två frågor: man matar in sin budget, eller man kontrollerar om
# den har hållits. Axeln är budgetposten, enheten är året, och
# teckenkonventionen är transaktionernas — en utgift skrivs negativ.

window-budget-entry-title = Budgetinmatning: planerade utgifter(-) och inkomster(+) för ett år
window-budget-control-title = Budgetkontroll

budget-column-line = Budgetpost
budget-none = Ingen budgetpost är registrerad: budgeten matas in per post.
budget-planned = Planerat
budget-actual = Utfall
budget-sum = Summa
budget-cumulative = Ackumulerat
budget-total = Totalt
# Påminnelsen om teckenkonventionen, i rött under inmatningstabellen.
# Hans mening, ord för ord och med mellanslagen (skärmbilden ”POINT 004 saisie
# budget.png”): den står i rött under tabellen, och fönstrets titel upprepar
# den i förkortad form. Ingen skulle gissa konventionen utan den.
budget-sign-warning = Ange alltid utgifterna  med negativt tecken och de planerade inkomsterna med positiva belopp
budget-entry-help = Skriv beloppen i rutorna och spara sedan.
budget-saved = Budgeten sparad.
budget-nothing-changed = Inga ändringar att spara.
budget-discard-question = Kasta ändringarna i budgeten?

# Kontrollens meny Visning: de två sätten att läsa samma avvikelse.
budget-menu-display = Visning
budget-display-money = Värden
budget-display-percent = Procent
budget-control-help = Grönt: minst lika bra som planerat. Rött: sämre.

# --- F09 — Överföring av ett belopp mellan två konton (fas 12) ----------
# En överföring är inte en transaktion, det är två: en debitering på
# källkontot, en kreditering på destinationskontot. De går i väg tillsammans
# eller inte alls.

window-transfer-title = Överför ett belopp mellan två konton

transfer-group-source = Debitera beloppet på det här källkontot
transfer-group-target = Kreditera beloppet på det här destinationskontot
transfer-group-description = Beskrivning av transaktionen
transfer-group-nomenclature = Uppgifter om grunddata
transfer-group-amount = Beloppet som ska överföras
transfer-field-source = Källkonto
transfer-field-target = Destinationskonto
transfer-field-label = Beskrivning
transfer-field-reference = Betalningsreferens
transfer-field-date = Datum
transfer-field-status = Transaktionsstatus
transfer-field-clearing = Avstämningsdatum
transfer-field-category = Kategori
transfer-field-mode = Betalningssätt
transfer-field-assignment = Tilldelning
transfer-field-payee = Motpart / handlare
transfer-field-project = Projekt
transfer-field-amount = Belopp

# Den enda knappen i de paneler som meddelar i stället för att fråga.
ui-ok = OK
transfer-help = Välj de två kontona: deras saldon visas här.
transfer-title-validate = Utför överföringen
# De tre saldona för det valda kontot, för att veta vad överföringen innebär.
transfer-balances = { $account } — Banksaldo: { $bank } · Verkligt saldo: { $real } · Slutsaldo: { $final }
# Panelen som sammanfattar det som just har skrivits.
transfer-done = Överföringen är utförd. { $amount } från kontot { $source } till kontot { $target }, den { $date }.

transfer-refusal-accounts-required = Välj källkonto och målkonto
transfer-refusal-same-account = Källkontot och målkontot kan inte vara samma konto: en överföring går från ett konto till ett annat
transfer-refusal-account-gone = Ett av de två kontona finns inte längre
transfer-refusal-label-required = Beskrivningen är obligatorisk
transfer-refusal-date-required = Datumet är obligatoriskt
transfer-refusal-amount = Beloppet som ska föras över måste vara strikt positivt

# ---------------------------------------------------------------------------
# Fas 13 — importen av ett Excel-blad (F34, F35, koppling).
# ---------------------------------------------------------------------------

window-excel-import-title = Import av Excel-blad [ Steg 1/3 ]: definition av insamlingsområdet
window-excel-fields-title = Import av Excel-blad [ Steg 2/3 ]: koppling av fälten
window-excel-association-title = Import av Excel-blad: koppling av data

# Frågan som ställs vid öppningen. En Excel-fil är gjord för hand:
# den innehåller det den innehåller, och en del av allt strunt den bär på
# går inte att upptäcka. Därför erbjuds skyddsnätet före hoppet.
excel-backup-question = Ett Excel-blad är gjort för hand: det kan innehålla datum som är riktiga men ändå fel, belopp med rätt format och fel tecken — och det kan ingen kontroll se. Importen skriver in de här raderna på ditt konto. Vill du säkerhetskopiera dina data innan du börjar?

excel-group-file = 1 - Ange vilken Excel-fil som ska importeras
excel-pick = Ange Excel-filen
excel-sheet = Blad i arbetsboken:
excel-group-header = 2 - Definiera: cellkoordinater för tabellens rubrikrad där kolumnnamnen står.
excel-header-row = Nummer på den första raden där kolumnnamnen står
excel-first-column = Rubrikradens första kolumn ( kolumnen längst till vänster ):
excel-column-count = Antal kolumner i tabellen
excel-group-rows = 3 - Definiera: radnummer för början och slut på listan med tabellens data ( under rubrikraden och utan att räkna med den )
excel-first-data-row = Första raden som innehåller data
excel-last-data-row = Sista raden som innehåller data:
excel-group-shape = 4 - Definiera: hur din fil skriver beloppen
excel-shape-single = En enda beloppskolumn, med tecken ( utgifterna negativa )
excel-shape-debit-credit = Två separata kolumner: en kolumn Debet och en kolumn Kredit
excel-shape-note = I läget med två kolumner tas ingen hänsyn till tecknet i kolumnen Debet: en debet tar alltid pengar, oavsett om det står ”-50” eller ”50”.
excel-group-test = 5 - Testvisning: se hur insamlingen blir med dina inställningar
excel-test = Testa de inställningar du har definierat i steg 2, 3 och 4.
excel-test-note = Obs: rubriknamnen och innehållet i tabellen nedan måste stämma med din Excel-tabell. Insamlingsområdet får inte gå utanför tabellens område.

excel-help = Gå igenom de fem grupperna i ordning och testa sedan: du kan gå vidare till steg 2 först när du har sett vad området fångar.
excel-no-file = Ange först vilken Excel-fil som ska importeras.
excel-not-tested = Inställningarna är ändrade: kör testvisningen igen innan du bekräftar.
excel-tested = Insamlat område: { $rows } rader, { $columns } kolumner. Kontrollera att tabellen nedan liknar ditt blad.
excel-empty-capture = Området du har angett fångar ingen enda rad: kontrollera rad- och kolumnnumren.
excel-title-next = Gå till nästa steg
excel-into-account = Import till kontot { $account }.

excel-tab-links = Kopplingar mellan fält
excel-tab-settings = Importinställningar
excel-column-excel = Rubrik_Excel
excel-column-radinus = Fält_Radinus
excel-links-help = Ange bredvid varje kolumn i ditt blad vilket fält i Radinus den fyller. Kolumner som lämnas på [IGNORE] importeras inte.
excel-group-category = Kategorier utan motsvarighet
excel-group-payment-mode = Betalningssätt utan motsvarighet
excel-group-assignment = Tilldelning utan motsvarighet
excel-policy-create = { $kind ->
    [payment-mode] Skapa automatiskt betalningssätt som inte finns
    [assignment] Skapa automatiskt tilldelningar som inte finns
   *[category] Skapa automatiskt kategorier som inte finns
}
excel-policy-ask = { $kind ->
    [payment-mode] Fråga för varje betalningssätt som inte finns vart data ska föras
    [assignment] Fråga för varje tilldelning som inte finns vart data ska föras
   *[category] Fråga för varje kategori som inte finns vart data ska föras
}
excel-policy-blank = { $kind ->
    [payment-mode] Lämna betalningssättet tomt
    [assignment] Lämna tilldelningen tom
   *[category] Lämna kategorin tom
}
excel-policy-default = { $kind ->
    [payment-mode] Placera betalningssätt som inte finns i ett standardbetalningssätt
    [assignment] Placera tilldelningar som inte finns i en standardtilldelning
   *[category] Placera kategorier som inte finns i en standardkategori
}
excel-define-destination = Ange mål
excel-not-linked = { $kind ->
    [payment-mode] Ingen kolumn fyller betalningssättet: den här inställningen gäller inte.
    [assignment] Ingen kolumn fyller tilldelningen: den här inställningen gäller inte.
   *[category] Ingen kolumn fyller kategorin: den här inställningen gäller inte.
}
excel-fields-help = Ställ in kopplingarna och sedan de tre reglerna innan du startar importen.
excel-title-import = Starta importen

excel-refusal-required = Fälten Datum, Beskrivning och Belopp måste ovillkorligen peka på Excel-kolumner
excel-refusal-column-twice = Olika Radinus-fält pekar på samma Excel-kolumn: en kolumn kan bara fylla ett enda fält
excel-refusal-field-twice = Samma Radinus-fält är kopplat till två Excel-kolumner: det kan bara ha en
excel-refusal-ask-unset = { $kind ->
    [payment-mode] Du har valt att bli tillfrågad om vart okända betalningssätt ska föras: tryck på ”Ange mål” innan du startar importen.
    [assignment] Du har valt att bli tillfrågad om vart okända tilldelningar ska föras: tryck på ”Ange mål” innan du startar importen.
   *[category] Du har valt att bli tillfrågad om vart okända kategorier ska föras: tryck på ”Ange mål” innan du startar importen.
}

excel-column-data = Data_Excel
excel-column-destination = { $kind ->
    [payment-mode] Betalningssätt_Radinus
    [assignment] Tilldelning_Radinus
   *[category] Kategori_Radinus
}
excel-association-help = Välj bredvid varje värde från ditt blad det värde i Radinus som det ska placeras under. En rad som lämnas tom blir utan klassificering.
excel-association-none = Inget okänt värde: allt som ditt blad innehåller finns redan i Radinus.

excel-imported = Importen är klar: { $count } transaktioner skrivna, { $refused } rader avvisade, { $created } värden i grunddata skapade.
excel-report-title = Rapport över importen
excel-column-row = Excel-rad
excel-column-content = Innehåll
excel-column-reason = Orsak till avvisningen
excel-nothing-refused = Alla rader i ditt blad har kommit in: ingen avvisning.

excel-refused-date = Datum saknas eller är oläsligt
excel-refused-amount = Belopp saknas eller är oläsligt
excel-refused-amount-both = Ett belopp i kolumnen Debet och ett annat i kolumnen Kredit: omöjligt att välja
excel-refused-amount-missing = Varken debet eller kredit på den här raden

# ---------------------------------------------------------------------------
# Fas 16 — de återkommande transaktionerna (F15, F38, F16).
# ---------------------------------------------------------------------------

window-recurring-list-title = Lista över återkommande transaktioner
window-recurring-form-title = Kort som definierar regeln för generering av återkommande transaktioner
window-recurring-calendar-title = Förslag till kalender över de transaktioner som ska läggas in på dina bankkonton

recurring-column-label = BESKRIVNING
recurring-none = Ingen återkommande regel är sparad.
recurring-help = Välj en regel och sedan kalendern för att se de förfallodatum den föreslår.
recurring-title-calendar = Föreslå kalender över förfallodatum
recurring-deleted = { $count ->
    [0] Ingen regel borttagen.
    [one] En regel borttagen. Dess transaktioner blir kvar på kontot.
   *[other] { $count } regler borttagna. Deras transaktioner blir kvar på kontona.
}
recurring-gone = Den här regeln finns inte längre.
recurring-delete-question = Ta bort de valda reglerna? De transaktioner som de redan har lagt in blir kvar på dina konton.

recurring-group-identity = Identifiering och berört bankkonto
recurring-group-nomenclature = Grunddata
recurring-group-amount = Definition av transaktionens belopp
recurring-group-period = Definition av intervallet
recurring-group-ending = Villkor för periodens slut
recurring-group-produced = Information om redan inlagda transaktioner ( endast för visning )

recurring-field-id = Transaktionens identifierare
recurring-field-account = Målkonto
recurring-field-label = Beskrivning
recurring-field-category = Kategori
recurring-field-mode = Betalningssätt
recurring-field-assignment = Tilldelning
recurring-field-payee = Motpart / handlare
recurring-field-project = Projekt
recurring-field-direction = Transaktionstyp
recurring-field-amount = Belopp
recurring-field-next = Datum för nästa transaktion
recurring-field-every = Sedan var
recurring-field-end-date = Slutdatum
recurring-field-repeat = Antal upprepningar
recurring-field-guid = GUID Transaktion
recurring-field-produced-count = Antal inlagda transaktioner
recurring-field-produced-last = Datum för senaste inlagda transaktionen
recurring-field-produced-total = Summa genererade belopp

recurring-unit-day = Dag
recurring-unit-week = Vecka
recurring-unit-month = Månad
recurring-unit-quarter = Kvartal
recurring-unit-year = År
recurring-ending-no-limit = Utan gräns
recurring-ending-until-date = Med slutdatum
recurring-ending-repeat-count = Antal upprepningar

recurring-title-erase = Ta bort de transaktioner som den här regeln redan har lagt in
recurring-erase-question = { $count ->
    [one] Den här regeln har lagt in en transaktion på dina konton. Vill du ta bort den? Saldona räknas om, och regeln backar inte.
   *[other] Den här regeln har lagt in { $count } transaktioner på dina konton. Vill du ta bort dem alla? Saldona räknas om, och regeln backar inte.
}
recurring-erase-none = Den här regeln har ännu inte lagt in någon transaktion.
recurring-erased = { $count ->
    [0] Ingen transaktion borttagen.
    [one] En transaktion borttagen, saldona omräknade.
   *[other] { $count } transaktioner borttagna, saldona omräknade.
}

recurring-calendar-help = Ta bort de förfallodatum du inte vill ha med papperskorgen och bekräfta sedan för att lägga in dem.
recurring-calendar-none = Inget förfallodatum att föreslå: kontrollera datumet för nästa transaktion och kontot i dina regler.
recurring-calendar-column-account = Konto
recurring-calendar-column-date = Datum
recurring-calendar-column-label = Beskrivning
recurring-calendar-column-amount = Belopp
recurring-calendar-column-category = Kategori
recurring-calendar-column-assignment = Tilldelning
recurring-calendar-column-mode = Betalningssätt
recurring-calendar-column-payee = Motpart
recurring-calendar-column-project = Projekt
recurring-calendar-removed = { $count ->
    [one] Ett förfallodatum borttaget från förslaget.
   *[other] { $count } förfallodatum borttagna från förslaget.
}
recurring-title-insert = Lägg in de valda förfallodatumen på kontona
recurring-nothing = Det finns inget förfallodatum kvar att lägga in.
# Frågan som ställs innan något skrivs: att lägga in en kalender skapar riktiga
# transaktioner på riktiga konton, och det gör man inte på ett tankspritt klick.
recurring-insert-question = { $count ->
    [one] Lägga in det här förfallodatumet på ditt konto? En transaktion skapas och saldona räknas om.
   *[other] Lägga in de här { $count } förfallodatumen på dina konton? Lika många transaktioner skapas och saldona räknas om.
}
recurring-inserted = { $count ->
    [one] En transaktion inlagd. Regeln startar om efter det senast inlagda förfallodatumet.
   *[other] { $count } transaktioner inlagda. Reglerna startar om efter sitt senast inlagda förfallodatum.
}

recurring-refusal-label-required = En beskrivning måste anges
recurring-refusal-date-required = Datum för nästa transaktion måste anges
recurring-refusal-date-too-old = Datumet för nästa transaktion måste vara år 2000 eller senare
recurring-refusal-account-gone = Det angivna bankkontot går inte att hitta, välj ett nytt så att regeln blir användbar
recurring-refusal-end-required = Om ett slutdatum används måste datumet anges
recurring-refusal-end-before-start = Slutdatumet kan inte vara tidigare än datumet för nästa transaktion
recurring-refusal-end-too-far = Avståndet mellan datumet för nästa transaktion och slutdatumet får inte överstiga 10 000 dagar

# --- Fas 15 — utskrifterna och rapporterna -----------------------------
# Bandets stora rubrik, ord för ord hämtad från den ursprungliga WinDev-rapporten.
print-operations-title = Lista över banktransaktioner och deltransaktioner
print-menu-operations-pdf = Utskrift till PDF-fil
print-recap-title = Sammanställning per kategori
print-recap-count = Rader
print-row-count = Antal rader:
print-total-debit = Summa debet:
print-total-credit = Summa kredit:
print-final-balance = Slutsaldo:
print-licence = Radinus är fri programvara som distribueras under GNU GPL v3 eller senare
print-nothing = Det finns inget att skriva ut.
print-done = Rapporten är utskriven och öppnad: ”{ $file }”.
print-failed = Det gick inte att skriva ut: { $reason }
# PDF-filen är korrekt skriven, men systemet kunde inte öppna den: vi säger det
# utan att låta det framstå som ett misslyckande, eftersom filen finns där.
print-not-opened = Rapporten är utskriven i ”{ $file }”, men ditt system kunde inte öppna den av sig självt.

# --- RIB-rapporten (F32) -----------------------------------------------
# Rubrikerna i bankkontouppgifterna, hämtade från originaldokumentet.
rib-title = BANKKONTOUPPGIFTER
rib-bank = Bank:
rib-national = RIB - Nationell kontoidentifierare
rib-establishment = BANKINSTITUT
rib-branch = KONTOR
rib-number = KONTONUMMER
rib-key = RIB-KONTROLLSIFFRA
rib-domiciliation = KONTOFÖRANDE KONTOR
rib-iban = IBAN - Internationell kontoidentifierare
rib-bic = BIC - Internationell identifierare för bankinstitutet
rib-holder = Kontoinnehavare

# --- Fönstret F32 ------------------------------------------------------
window-rib-title = Utskrift av RIB ( Relevé d'Identité Bancaire )
rib-group-bank = Bank
rib-group-holder = Kontoinnehavare
rib-group-details = Bankuppgifter
rib-field-bank = Bankens namn
rib-field-domiciliation = Kontoförande kontor
rib-field-holder = Innehavarens namn
rib-field-address = Adress
rib-field-establishment = Bankinstitut
rib-field-branch = Kontor
rib-field-number = Kontonummer
rib-field-key = RIB-kontrollsiffra
rib-field-bic = BIC (Bank Identifer Code)
rib-field-iban = IBAN (International Bank Account Number )
rib-conditions = Viktiga användningsvillkor som måste följas vid utskrift
rib-declaration = Jag, undertecknad användare av programvaran, försäkrar på heder och samvete:
rib-declaration-first = - Bekräftar att jag hos min bank har kontrollerat att bankuppgifterna i det här fönstret är korrekta och överensstämmer med min vilja . Bekräftar på samma sätt att jag åtar mig att kontrollera att uppgifterna i den utskrivna RIB-rapporten är korrekta och överensstämmer med min vilja. Denna utskrift och användningen av RIB sker på mitt eget fulla ansvar
rib-declaration-second = - Att vara innehavare av det konto vars RIB skrivs ut, och att inte använda programvarans funktioner i ett syfte som strider mot lagen.
rib-title-print = Utskrift på skrivare
rib-title-pdf = Utskrift till PDF-fil
# Kryssrutan är ingen dekorativ varning: så länge den inte är ikryssad är de
# båda knapparna släckta (Fabrices avgörande, 01/08/2026).
rib-declaration-required = Kryssa i försäkran på heder och samvete för att kunna skriva ut.
rib-help = Kontrollera dina uppgifter, kryssa i försäkran och skriv sedan ut.
rib-account-gone = Det här bankkontot går inte att hitta.
rib-fields-read-only = De här uppgifterna kommer från kontoformuläret: rätta dem där för att ändra dem här.
rib-printed = RIB har skickats till din standardskrivare.
rib-print-failed = Det gick inte att skriva ut: { $reason }
rib-pdf-done = RIB är utskriven och öppnad: ”{ $file }”.
rib-pdf-not-opened = RIB är utskriven i ”{ $file }”, men ditt system kunde inte öppna filen av sig självt.
menu-accounts-bank-details = Ta fram bankkontouppgifter (RIB)

# Valet av skrivare. Radinus ställer frågan själv: ingen av de tre webbvyerna
# öppnar systemets utskriftsdialog.
print-choose-printer = Vilken skrivare vill du skriva ut på?
print-do-print = Skriv ut
rib-printed-on = RIB har skickats till skrivaren ”{ $printer }”.
ui-cancel = Avbryt

# Systemet kunde inte namnge någon skrivare: vi skriver ut på standardskrivaren
# ändå i stället för att blockera användaren.
print-printers-unknown = Ditt system kunde inte namnge någon skrivare: dokumentet gick till standardskrivaren.

print-menu-operations-printer = Utskrift på skrivare
print-sent-on = Rapporten har skickats till skrivaren ”{ $printer }”.
print-sent-default = Rapporten har skickats till din standardskrivare.

# --- Fas 17 — åtgärderna på databasen -----------------------------------
backup-archive = Radinus-arkiv
backup-no-database = Ingen databas är öppen.
backup-done = Säkerhetskopian skriven till ”{ $file }”.
backup-failed = Det gick inte att göra säkerhetskopian: { $reason }
backup-not-started = Säkerhetskopieringen kunde inte startas:
restore-unreadable = Den här filen är inget läsbart Radinus-arkiv: { $reason }
# Frågan säger vad som går förlorat innan det går förlorat. Arkivet har redan
# lästs vid det laget: det som den aviserar är säkert.
restore-question = Återställa ”{ $file }”? Allt nuvarande innehåll i din databas raderas och ersätts, och det som finns där går förlorat.
restore-done = Återställningen är klar: { $accounts } konton och { $operations } transaktioner.
restore-failed = Det gick inte att återställa: { $reason }
restore-empty-fields = Tomma fält lästa som nollvärde: { $count }.


# --- Loggen över tekniska åtgärder (fas 17) -----------------------------
# De tre statusarna i hans Ajoute_Log, i versaler som hos honom.
journal-status-success = LYCKADES
journal-status-failure = MISSLYCKADES
journal-status-repaired = REPARERAD
journal-step-reindex = Reparation av databastabell
journal-step-refill = Systemgrunddata tomma: standardvärden återställda
journal-step-table-created = Tabellen saknas i databasen: återskapad tom
journal-step-column-added = Kolumnen saknas i tabellen: tillagd med sitt standardvärde

# --- Protection par mot de passe (05/08/2026) ---
password-protect = Lösenordsskydd
window-password-form-title = Lösenordsskydd
password-ask = Den här databasen är skyddad. Ange dess lösenord.
password-group-database = Berörd databas
password-group-password = Lösenord
password-group-warning = Innan du bekräftar
password-field-old = Gammalt lösenord
password-field-new = Nytt lösenord
password-field-repeat = Upprepa det nya lösenordet
password-hint = Lämna det gamla tomt om databasen ännu inte är skyddad. Lämna båda nya tomma för att ta bort skyddet.
password-lost-warning = Ett förlorat lösenord är en förlorad databas: ingenting kan återställa den. Säkerhetskopiorna förblir däremot okrypterade.
password-show = Visa lösenordet
password-remove-question = Ta bort skyddet från den här databasen?
password-mismatch = De två inmatningarna av det nya lösenordet skiljer sig åt
password-wrong = Lösenordet passar inte
database-too-recent = Den här databasen har sparats av en nyare version av Radinus (databasversion { $found }; den här versionen läser till och med version { $supported }). Uppdatera Radinus för att öppna den.
database-not-radinus = Den här filen är ingen Radinus-databas.
database-unreadable = Databasen kunde inte läsas: { $reason }
password-close-first = Stäng den här databasen innan du ändrar dess lösenord
password-now-protected = Databasen är skyddad av ett lösenord
password-now-clear = Databasen är inte längre skyddad
journal-step-date-fixed = Korrigering av en transaktion utan datum
journal-step-circular = Borttagning av en motstridig transaktion: cirkelreferens
journal-step-flag-parent-true = Fel flagga EstParent=Falskt på en huvudtransaktion
journal-step-flag-parent-false = Fel flagga EstParent=Sant på en huvudtransaktion
journal-step-flag-child = Fel flagga EstParent=Sant på en deltransaktion
journal-step-orphan = Borttagning av en föräldralös deltransaktion
journal-step-third-level = Borttagning av en deltransaktion som var kopplad till en annan deltransaktion
journal-step-coherence = Allmän omräkning av samstämmigheten mellan deltransaktioner och huvudtransaktioner
journal-step-balances = Omräkning av alla saldon på alla konton
journal-step-vacuum = Optimering av databasfilen
journal-step-analyze = Uppdatering av sökstatistiken
journal-step-backup-begin = Början på säkerhetskopieringen av databasen
journal-step-backup-end = Slut på säkerhetskopieringen av databasen
journal-step-restore-begin = Början på återställningen av databasen från arkivet
journal-step-restore-end = Slut på återställningen av databasen från arkivet
journal-step-restore-read = Läsning av arkivet

# --- Loggfönstret (⌘H) --------------------------------------------------
window-journal-title = Logg över den senaste tekniska åtgärden
journal-column-step = Steg
journal-column-file = Fil
journal-column-table = Tabell
journal-column-status = Status
journal-column-error = Fel
journal-column-comments = Kommentarer
journal-empty = Ingen teknisk åtgärd har ännu utförts sedan programmet öppnades.
journal-help = Loggen behåller bara den senaste tekniska åtgärden: säkerhetskopiering, återställning, reparation, radering eller öppnande av en databas.

# --- Reparationen -------------------------------------------------------
menu-file-repair-running = Reparation och optimering pågår…
repair-done = { $anomalies ->
    [0] Reparationen är klar: ingen avvikelse hittades. { $lines } steg loggade.
    [one] Reparationen är klar: en avvikelse reparerad. { $lines } steg loggade.
   *[other] Reparationen är klar: { $anomalies } avvikelser reparerade. { $lines } steg loggade.
}
repair-failed = Det gick inte att reparera: { $reason }

journal-status-started = PÅGÅR
journal-status-finished = AVSLUTAD
journal-step-backup-table = Skrivning av tabellen till arkivet
journal-step-backup-write = Skrivning av arkivet
journal-step-backup-verified = Kontroll av det skrivna arkivet: filer omlästa / förväntade, poster omlästa / skrivna
journal-step-backup-total = Totalt säkerhetskopierat: poster, data, filstorlek
journal-step-restore-table = Läsning av tabellen i arkivet
journal-step-restore-missing = Filen saknas i arkivet: den här tabellen återställs inte
journal-step-restore-wipe = Total radering av databasens innehåll före återställning
journal-step-restore-write = Skrivning i databasen
journal-step-restore-total = Totalt återställt: konton, transaktioner
journal-step-restore-empty-fields = Tomma fält ifyllda vid inläsning
backup-verify-mismatch = Det skrivna arkivet läses inte tillbaka så som det skrevs: lita inte på det, gör om säkerhetskopian.

# --- En transaktions bilagor (F28, fas 17) ------------------------------
window-attachments-title = Transaktionens bilagor
attachment-filter = Godkända dokument
attachment-none = Den här transaktionen har ingen bilaga.
attachment-title-add = Bifoga ett dokument till den här transaktionen
attachment-title-open = Öppna bilagan
attachment-title-remove = Ta bort bilagan och skicka dess fil till papperskorgen
# Filens tillstånd på disken. ”Går inte att kontrollera” är inget grundlöst
# erkännande av okunskap: kontrollsummorna från Radinus 1.9.3 är stympade av
# sparformatet, och att döma en fil utifrån dem vore att anklaga på måfå.
attachment-state-ok = Intakt
attachment-state-changed = Ändrad
attachment-state-missing = Filen saknas
attachment-state-unknown = Går inte att kontrollera
attachment-added = ”{ $name }” har bifogats transaktionen.
attachment-removed = Bilagan är borttagen, dess fil ligger i papperskorgen.
attachment-removed-kept = Bilagan är borttagen, men dess fil kunde inte läggas i papperskorgen.
attachment-remove-question = Ta bort ”{ $name }” från den här transaktionen? Dess fil skickas till papperskorgen.
attachment-opened = ”{ $name }” har öppnats.
attachment-opened-changed = ”{ $name }” har öppnats, men innehållet har ändrats sedan den bifogades.
attachment-gone = Den här bilagan finns inte längre.
attachment-file-missing = Filen för ”{ $name }” går inte att hitta på disken.
attachment-failed = Åtgärden gick inte att utföra: { $reason }
attachment-save-first = Spara transaktionen först: en bilaga hör till en transaktion som finns.
attachment-refusal-missing = Den här filen finns inte.
attachment-refusal-extension = Den här filtypen accepteras inte. Godkända typer är: pdf, jpeg, jpg, png, bmp, tiff, gif, webp, xls, xlsx, doc, docx, odt, rtf, txt, json, xml.
attachment-refusal-operation = Transaktionen som dokumentet ska bifogas till finns inte.
journal-step-backup-attachments = Bilagor tillagda i arkivet
journal-step-backup-attachment-missing = Bilagan går inte att hitta på disken: den kommer att saknas i arkivet
journal-step-restore-attachments = Bilagor uttagna ur arkivet
attachment-title-replace = Ersätt den här bilagans dokument
attachment-replaced = Dokumentet har ersatts med ”{ $name }”.

# ---------------------------------------------------------------------
# F08 — menyn ”Verktyg” i kontoformuläret.
#
# Dess tre poster är portningar av Fabrices WLangage (mappen
# ”Information import export base piece jointe”): beräkningen av det
# avstämda ingående saldot, kontots statistik och borttagningen av alla
# dess transaktioner. Menyn verkar bara vid redigering (avgörandet av
# den 02/08/2026): vid skapandet finns det inget att räkna, vid
# visningen gör formuläret bara just det, visar.
# ---------------------------------------------------------------------

account-tools = Verktyg
account-tools-initial-balance = Ange avstämt ingående saldo
account-tools-statistics = Statistik bankkonto
account-tools-delete-operations = Ta bort alla transaktioner på kontot

# Frågan vid beräkningen, ord för ord originalets. { $total } är summan av de
# avstämda transaktionerna, redan skriven i valutaformat.
account-initial-balance-question =
    För att beräkna det avstämda ingående saldot med hänsyn till transaktionerna på det här kontot, ange det aktuella saldot hos din bank
    Det avstämda ingående saldot beräknas som:
    { "[" }Aktuellt banksaldo] - [Summa avstämda transaktioner ({ $total }) ].
    { "" }
    För att slippa mata in det här värdet på nytt måste du vara helt uppdaterad med listan över banktransaktioner på det här kontot.

account-statistics-none = Ingen transaktion

# De fjorton raderna i hans Info(). Originalets stavfel ”pengagés” är rättat,
# efter Fabrices beslut av den 02/08/2026 — liksom ”Bank Identifer Code” på
# samma formulär.
account-statistics =
    Totalt antal transaktioner på det här kontot: { $count }
    { "" }
    Antal avstämda transaktioner på det här kontot: { $pointed }
    Avstämda debetbelopp: { $pointedDebits }
    Avstämda kreditbelopp: { $pointedCredits }
    Skillnad mellan avstämda kredit- och debetbelopp: { $pointedDifference }
    { "" }
    Antal reserverade transaktioner på det här kontot: { $committed }
    Reserverade debetbelopp: { $committedDebits }
    Reserverade kreditbelopp: { $committedCredits }
    Skillnad mellan reserverade kredit- och debetbelopp: { $committedDifference }
    { "" }
    Antal planerade transaktioner på det här kontot: { $planned }
    Planerade debetbelopp: { $plannedDebits }
    Planerade kreditbelopp: { $plannedCredits }
    Skillnad mellan planerade kredit- och debetbelopp: { $plannedDifference }
    { "" }
    Äldsta transaktionen: { $first }
    Senaste transaktionen: { $last }

# Den dubbla spärren vid borttagning. { $word } är ”ja” på användarens eget
# språk — en spansktalande som ombads skriva OUI skulle inte förstå
# (beslut av Fabrice, 02/08/2026).
account-delete-operations-question =
    Är du säker på att du vill ta bort alla transaktioner i bankkontot?
    Skriv { $word } i fältet nedan som bekräftelse och bekräfta

account-delete-operations-done =
    { $count ->
        [0] Inga transaktioner borttagna.
        [one] 1 transaktion borttagen.
       *[other] { $count } transaktioner borttagna.
    }

# ---------------------------------------------------------------------
# Databasväljaren och valet av språk (02/08/2026)
#
# Beslut fattade i samtal med Fabrice: Radinus skapar inte längre någon
# databas utan tillåtelse; utan språk i konfigurationen frågar det efter
# språket före allt annat; en databas är varje mapp i databases/ som
# innehåller en radinus.sqlite, oavsett vad den heter.
#
# Fönstret för språkvalet har inte en enda nyckel här: det använder ingen
# mening alls, och det är det som gör att det kan förstås innan man vet
# vilket språk användaren talar.
# ---------------------------------------------------------------------

window-database-selector-title = Databaser
window-database-form-title = Ny databas
database-group-identity = Identifiering av databasen
database-group-restore = Initiera databasen med data från en säkerhetskopia
database-choose-backup = Välj säkerhetskopia
database-no-backup = Ingen säkerhetskopia vald: databasen skapas tom.

databases-column-label = Databas
databases-column-comment = Kommentar
databases-column-folder = Mapp
databases-column-created = Skapad den

databases-none = Ingen databas ännu: skapa en.
databases-help = Välj den databas du vill öppna, eller skapa en ny.
databases-select = Välj först en databas i listan.
databases-tools = Verktyg
databases-title-open = Öppna denna databas

database-created = Databasen ”{ $label }” är skapad.
database-field-label = Databasens namn
database-field-comment = Kommentar
database-label-required = Ge databasen ett namn: det är namnet som skiljer den från de andra.
database-gone = Databasen finns inte längre: den har flyttats eller tagits bort sedan detta fönster öppnades.

# Borttagningen av en databas (02/08/2026). Mappen hamnar i systemets
# papperskorg, precis som bilagorna: en databas som tagits bort av misstag
# läggs tillbaka med ett högerklick. Den öppna databasen nekas — Radinus
# håller i sin fil.
databases-title-delete = Ta bort denna databas
database-delete-question =
    Är du säker på att du vill ta bort databasen ”{ $label }”?
    { "" }
    Hela dess mapp hamnar i papperskorgen: transaktionerna, kontona och bilagorna.
    Skriv { $word } i fältet nedan som bekräftelse och bekräfta.
database-in-use = Databasen är öppen: Radinus kan inte ta bort den. Öppna en annan först.
database-deleted = Databasen ”{ $label }” ligger i papperskorgen.

# Väljaren har två lägen (Fabrice, 02/08/2026). Öppnad mitt under
# användningen kan den inte längre öppna: ett Radinus-fönster byggs en gång och
# rivs aldrig, och ingenting kan få det att glömma den databas det visar. Man
# tittar, man skapar, man tar bort — och för att byta databas avslutar man.
database-quit-first = För att öppna databasen, avsluta Radinus och starta om det: väljaren erbjuder dig den vid starten.


# --- F01 — välkomstfönstret (fas 17 bis, 03/08/2026) ----------------------
#
# Första tillägget i 2.0.0 jämfört med 1.9.3: välkomstfönstret bär inte längre
# bara banderollen. Regeln som styr det står i dokument 04 F01: det är vyn
# UTAN ETT ENDA KLICK, och ingenting som kräver en inställning kommer in där.
#
# De två ringdiagrammens rubriker bär hela månaden i stället för att klistras
# ihop av fönstret: ”Utgifter ... — augusti 2026” har inte samma ordföljd på
# de tre språken, och bara Fluent vet var hålet sitter.

window-main-title = Radinus
welcome-month = { $month } { $year }
welcome-accounts-count = { $count ->
    [0] Inget öppet konto
    [one] 1 öppet konto
   *[other] { $count } öppna konton
}
welcome-total-bank = Banksaldo
welcome-total-real = Verkligt saldo
welcome-total-final = Slutsaldo
welcome-total-real-detail = avstämd + reserverad
welcome-total-final-detail = avstämd + reserverad + planerad
welcome-accounts = Dina konton
# The tick box of an account on the home window (Fabrice, 07/10/2026), and the
# line that says so when not every account is counted. No plural on purpose:
# « counted: 3 of 5 » reads the same whatever the numbers.
welcome-accounts-counted = Konton som räknas i summorna: { $count } av { $total }
welcome-tile-counted = Räkna det här kontot i summorna
welcome-tile-bank = På banken
welcome-tile-real = Verkligt
welcome-tile-final = Slutligt
welcome-spending = Utgifter — { $month }
welcome-earning = Inkomster — { $month }
ui-legend-budget-lines = Budgetposter
ui-legend-categories = Kategorier
welcome-nothing = Ingen transaktion den här månaden.
welcome-open-account = Info: klicka på ett konto för att öppna dess transaktioner.
welcome-no-account = Inget bankkonto ännu.
welcome-no-account-create = Skapa ett bankkonto genom att klicka här
welcome-previous-month = Föregående månad
welcome-next-month = Nästa månad
welcome-refresh = Läs om allt


# --- F39 — alternativen (fas 17 ter, 03/08/2026) --------------------------
#
# Valutatecknets plats bor här, bredvid de två avskiljarna: den följer språket
# och inte valutan. ”before” sätter tecknet före talet, alla andra värden
# sätter det efter. INGET valutatecken skrivs i den här filen: ”franska”
# betyder inte ”euro”.

ui-money-sign-position = after
window-preferences-title = Alternativ
menu-settings-preferences = Alternativ…
menu-settings-show-main = Visa huvudfönstret
menu-settings-folders = Radinus mappar
preferences-branch-display = Visning
preferences-leaf-language = Språk
preferences-leaf-currency = Valuta
preferences-field-language = Programmets språk:
preferences-field-currency = Visad valuta:
preferences-field-custom = Valutans tecken:
preferences-currency-system = Systemets valuta
preferences-currency-euro = Euro
preferences-currency-dollar = Dollar
preferences-currency-canadian = Kanadensiska dollar
preferences-currency-cfa = CFA-franc
preferences-currency-cfp = CFP-franc
preferences-currency-swiss = Schweiziska franc
preferences-currency-none = Ingen
preferences-currency-custom = Anpassad
preferences-currency-system-is = Ditt system anger:
preferences-currency-system-silent = Ditt system anger ingen valuta: beloppen visas i euro.
preferences-custom-required = Skriv in din valutas tecken innan du sparar.
preferences-saved = Alternativen sparade.
preferences-help = Välj ett alternativ i trädet och spara sedan.
preferences-sign-too-long = En valutas tecken får vara högst 8 tecken långt.
preferences-sign-not-a-number = En valutas tecken får varken innehålla siffror, räknetecken eller kommatecken: Radinus tar bort dem när det läser ett belopp, och ”120” skulle bli ”12”.
preferences-leaf-zoom = Visningens storlek
preferences-field-zoom = Förstoring:
preferences-zoom-reset = Standardvärde
preferences-zoom-hint = Allt växer tillsammans: texten, ikonerna, kolumnerna. Under 100 % får mer plats på skärmen. Systemets menyrad och dess dialogrutor följer däremot inställningarna i din dator och inte de här.
preferences-branch-import = Import
preferences-leaf-verification = Kontroll
preferences-field-verification = Importerade transaktioner:
preferences-verification-hint = ”Kontrollerad”: du litar på din bank, en importerad transaktion anses vara riktig. ”Att kontrollera”: varje importerad transaktion väntar på din kontroll; sedan sätter du den själv till ”Kontrollerad” i transaktionslistan. Inställningen gäller bara kommande importer.
preferences-leaf-qif = QIF-kontoutdrag
preferences-field-qif-order = Ordning för dag och månad:
preferences-qif-order-ask = Fråga mig varje gång
preferences-qif-order-day-month = Alltid dag/månad (05/03 = 5 mars)
preferences-qif-order-month-day = Alltid månad/dag (05/03 = 3 maj)
preferences-qif-order-help = Används bara när inget datum i filen avgör saken. Så snart ett datum som 24/11 visar ordningen avgör filen, oavsett den här inställningen.
preferences-field-qif-label = Transaktionens beskrivning:
preferences-qif-label-both = Motpart + memo
preferences-qif-label-payee = Endast motpart
preferences-qif-label-memo = Endast memo
preferences-qif-label-help = När en transaktion har både en motpart och ett memo. Om den bara har det ena används det, oavsett den här inställningen.
preferences-qif-hint = Inställningarna gäller alla QIF-kontoutdrag, oavsett vilken databas som är öppen. ”Fråga mig varje gång” är säkrast: en fil med tvetydiga datum läses aldrig på måfå.

# The columns of a table (Fabrice, 04/10/2026): each user has his own. The
# first is the last entry of the right-click menu on a table's header; the
# others are the « Table columns » leaf of the preferences, one line per
# table whose columns can be arranged, a « Reset » button facing it.
columns-reset = Återställ standardkolumner
# The header menu's two sub-menus (Fabrice, 05/10/2026). « columns-colour » is
# followed by the column's own title, hence its colon. Then the nine tints a
# column can take, and the entry that takes it off.
columns-show-hide = Visa/Dölj
columns-colour = Färga kolumnen:
columns-colour-none = Ingen färg
columns-colour-red = Röd
columns-colour-orange = Orange
columns-colour-pink = Rosa
columns-colour-pastel-green = Pastellgrön
columns-colour-green = Grön
columns-colour-pastel-blue = Pastellblå
columns-colour-blue = Blå
columns-colour-pastel-yellow = Pastellgul
columns-colour-yellow = Gul
preferences-leaf-columns = Tabellkolumner
preferences-table-operations-list = Transaktionslista
preferences-columns-reset = Återställ
preferences-columns-reset-all = Återställ alla
preferences-columns-done = Kolumnerna har fått tillbaka sin ursprungliga layout.
preferences-columns-hint = Varje tabell minns kolumnernas ordning, vilka du döljer och deras bredd. ”Återställ” ger genast tabellen dess ursprungliga layout.

# The reset of the comfort settings (Fabrice, 07/10/2026): columns, home
# window, display size — and nothing else.
preferences-branch-reset = Återställning
preferences-leaf-comfort = Bekvämlighetsinställningar
preferences-comfort-reset = Återställ bekvämlighetsinställningarna
preferences-comfort-hint = Återställer kolumnerna i alla tabeller, ordningen och kryssrutorna för kontona i startfönstret samt visningens storlek. Språket, valutan och kontrollen av importerade transaktioner rörs inte.
preferences-comfort-question = Återställa bekvämlighetsinställningarna? Tabellkolumnerna, startfönstret och visningens storlek återgår till sitt ursprungliga läge.
preferences-comfort-done = Bekvämlighetsinställningarna har återställts.

# --- Välkomstsidans banderoll --------------------------------------------
#
# Dessa meningar stod hårdkodade i `index.html` sedan fas 0 och översattes
# därför inte (påpekat av Fabrice den 03/08/2026). Devisen är hans röst: den
# engelska och den spanska versionen är förslag som han själv får rätta —
# en slogan översätts inte ord för ord.
ui-language-tag = sv
welcome-banner-title = Radinus
welcome-mascot-alt = Radinus — ekorren som maskot, i kostym, omgiven av en euro, en miniräknare och diagram
welcome-slogan-one = Ett program för privatekonomi som hjälper dig att spendera mindre för att tjäna mer
welcome-slogan-two = Med Radinus förstår du varför många bäckar små gör en stor å.

# --- ”Om författaren” ----------------------------------------------------
#
# Namnet och adressen är skrivna likadant i alla tre filerna: de översätts
# inte. De ligger ändå här, och inte på sidan, för att vyn inte ska bära
# någon mening alls — och för att de ska rättas på ett enda ställe den dag
# författaren flyttar.
about-author-name = Auteur : Fabrice Garcia
about-author-place = 20290 Borgo, Corsica, France
window-about-author-title = Om författaren
about-author-flag-alt = Korsikas flagga — morhuvudet

# --- ”Om Radinus” --------------------------------------------------------
#
# `about-radinus-version` bär ett hål: numret kommer från binären som körs,
# aldrig från en avskriven sträng. Den ligger därför inte i fönstrens
# ordlista — det är kommandot `app_version` som fyller den.
window-about-radinus-title = Om Radinus
about-radinus-name = Radinus
about-radinus-version = Version { $version }
about-radinus-rust-alt = Logotypen för språket Rust
about-radinus-tauri-alt = Tauris logotyp
about-radinus-built = Radinus är skrivet i Rust och byggt med Tauri. Det första räknar ut dina konton, det andra gör det till ett skrivbordsprogram.
about-radinus-licence = Fri programvara, under GNU GPL v3-licens.

# --- « Licence d'utilisation » (08/08/2026) -------------------------------
#
# The window names the licence and says, in four lines, what it gives the
# person using Radinus. The legal text itself is not translated here: the
# button opens the official page, published and maintained by the Free
# Software Foundation, which knows its own wording better than we do.
window-licence-title = Licens
licence-heading = ANVÄNDARLICENS FÖR PROGRAMMET RADINUS
licence-logo-alt = Logotypen för GNU General Public License version 3
licence-name = GNU GPL v3 eller senare
licence-intro = Radinus är fri programvara.
licence-freedoms-title = Licensen ger dig fyra friheter:
licence-freedom-use = Använda det som du vill, till vad du vill.
licence-freedom-study = Studera dess källkod, som är öppen för alla.
licence-freedom-share = Kopiera det och ge det vidare.
licence-freedom-improve = Ändra det och dela dina ändringar.
licence-read = Läs licensens fullständiga text

# The two notices the GPL asks an interactive interface to display, next
# to the right to redistribute and the way to read the licence, which the
# window already carried (LICENSE, definition of « Appropriate Legal
# Notices »). The copyright is a name and a year: identical everywhere,
# here all the same so that the view holds no sentence of its own.
licence-copyright = Copyright © 2026 Fabrice Garcia
licence-no-warranty = Detta program levereras utan någon garanti, i den mån lagen tillåter.
licence-info = Den officiella texten öppnas i din webbläsare, på gnu.org.

# --- F41 — Simulation de crédit (Fabrice, 08/10/2026) ------------------------
# Le calcul d'un prêt à taux fixe, et ce que l'historique de la base dit de la
# capacité à le rembourser. Les phrases sont écrites par le noyau ; la fenêtre
# n'en compose aucune.
menu-tools-loan-simulation = Lånesimulering
window-loan-title = Lånesimulering
loan-tab-credit = Lånet
loan-tab-afford = Har jag råd att betala tillbaka?
loan-field-kind = Lånetyp
loan-kind-consumer = Konsumtionslån
loan-kind-mortgage = Bolån
loan-field-amount = Lånebelopp
loan-field-payment = Månadsbetalning
loan-field-months = Löptid
loan-field-rate = Fast ränta
loan-field-fees = Uppläggningsavgift
loan-field-insurance = Försäkring per månad
loan-unit-months = månader
loan-unit-percent = %
loan-invalid-field = Värdet är inte ett tal: rätta det för att räkna om.
loan-report-button = PDF-rapport
loan-monthly-table = Tabell månad för månad
loan-months-count = { $count ->
        [one] { $count } månad
       *[other] { $count } månader
    }
loan-percent = { $value } %
loan-notice-payment-too-low = Den här betalningen täcker inte räntan: lånet skulle aldrig bli återbetalt. Löptiden stannar på 600 månader.
loan-notice-too-long = Den här betalningen skulle kräva mer än 600 månader: löptiden stannar på 600 månader.
loan-figure-payment = Månadsbetalning
loan-figure-payment-insured = Betalning inklusive försäkring
loan-figure-taeg = Effektiv ränta
loan-figure-interest = Räntekostnad
loan-figure-insurance = Försäkringskostnad
loan-figure-cost = Lånets totala kostnad
loan-figure-total-due = Totalt belopp att betala
loan-figure-all-in = Totalt återbetalt, inklusive försäkring
loan-part-capital = Lånebelopp
loan-part-interest = Ränta
loan-part-fees = Uppläggningsavgift
loan-part-insurance = Försäkring
loan-donut-cost-caption = totalt
loan-chart-cost = Vad lånet kostar
loan-chart-capital = Kvarvarande skuld
loan-schedule-title = Amorteringsplan
loan-schedule-yearly = Amorteringsplan, år för år
loan-column-number = Nr
loan-column-year = År
loan-column-date = Förfallodag
loan-column-payment = Betalning
loan-column-payments = Betalningar
loan-column-interest = Ränta
loan-column-capital = Amortering
loan-column-insurance = Försäkring
loan-column-remaining = Kvarvarande skuld
loan-history-label = Studerad period
loan-period-last-12 = Senaste 12 månaderna
loan-accounts-title = Studerade konton
loan-period-title = Period
loan-column-account = Konto
loan-column-bank = Bank
loan-column-balance = Verkligt saldo
loan-unavailable-no-account = Markera minst ett konto för att studera din historik.
loan-unavailable-no-month = Den här perioden har ännu ingen hel månad: välj en annan.
loan-verdict-title = Kort sagt
loan-verdict-green = Genomförbart
loan-verdict-orange = Knappt
loan-verdict-red = Riskabelt
loan-verdict-no-income = Inga inkomster under perioden: skuldkvoten går inte att beräkna.
loan-check-debt-green = Skuldkvot på { $ratio }: under metodens gräns på { $green }.
loan-check-debt-orange = Skuldkvot på { $ratio }: mellan { $green } och { $red }, på gränsen.
loan-check-debt-red = Skuldkvot på { $ratio }: över { $red }.
loan-check-effort = Betalningen på { $payment } tar { $share } av det du lägger undan { $kind ->
        [good] en bra månad
        [hard] en svår månad
       *[usual] en vanlig månad
    } ({ $margin }).
loan-check-effort-none = { $kind ->
        [good] En bra månad
        [hard] En svår månad
       *[usual] En vanlig månad
    } lämnar inget över: betalningen på { $payment } skulle tas från din reserv.
loan-check-reserve-green = Ditt saldo förblir positivt till lånets slut.
loan-check-reserve-red = Ditt saldo skulle gå under noll i { $month }, på grund av det här lånet.
loan-check-reserve-sooner = Ditt saldo skulle gå under noll i { $month }, { $count ->
        [one] en månad
       *[other] { $count } månader
    } tidigare än utan lånet.
loan-check-reserve-anyway = Ditt saldo skulle gå under noll omkring { $month } även utan lånet, som knappt ändrar något.
loan-check-reserve-floor-green = Ditt saldo håller sig över din säkerhetsreserv ({ $floor }) till lånets slut.
loan-check-reserve-floor-red = Ditt saldo skulle gå under din säkerhetsreserv ({ $floor }) i { $month }, på grund av lånet.
loan-check-reserve-floor-sooner = Ditt saldo skulle gå under din säkerhetsreserv ({ $floor }) i { $month }, { $count ->
        [one] en månad
       *[other] { $count } månader
    } tidigare än utan lånet.
loan-check-reserve-floor-anyway = Ditt saldo skulle gå under din säkerhetsreserv ({ $floor }) omkring { $month } även utan lånet, som knappt ändrar något.
loan-warning-deficit = Obs: under perioden överstiger dina utgifter redan dina inkomster med { $amount } per månad i genomsnitt, före något lån.
loan-figure-reference = Sparande { $kind ->
        [good] en bra månad
        [hard] en svår månad
       *[usual] en vanlig månad
    }
loan-figure-tipped = Månader som lånet skulle sätta på minus
loan-gauge-caption = skuldkvot
loan-figure-income = Genomsnittliga inkomster per månad
loan-figure-spending = Genomsnittliga utgifter per månad
loan-figure-saving = Genomsnittligt sparande per månad
loan-figure-running = Pågående lån per månad
loan-figure-new = Ny betalning, inklusive försäkring
loan-figure-rest = Att leva på per månad
loan-figure-debt = Skuldkvot
loan-red-months-value = { $count } av { $total }
loan-figure-balance-now = Verkligt saldo i dag
loan-figure-balance-end = Beräknat saldo vid lånets slut
loan-chart-income = Vart din genomsnittliga inkomst går
loan-donut-income-caption = genomsnittlig inkomst
loan-part-spending = Löpande utgifter
loan-part-running = Pågående lån
loan-part-new = Nytt lån
loan-part-rest = Över
loan-part-missing = Saknas
loan-chart-history = Din historik med det här lånet
loan-chart-history-hint = Vad som skulle ha blivit kvar varje månad efter betalningen. Klarröda: månaderna som lånet skulle sätta på minus; blekröda: de som redan var det utan lånet.
loan-chart-projection = Ditt beräknade saldo
loan-mark-loan-end = Slut: { $label }
loan-mark-negative = På minus
loan-mark-floor = Under reserven
loan-mark-floor-line = Säkerhetsreserv
loan-running-title = Pågående lån som räknats med
loan-running-column-label = Återkommande transaktion
loan-running-column-monthly = Per månad
loan-running-column-end = Sista betalning
loan-no-running = Inget pågående lån hittades bland dina återkommande transaktioner.
loan-period-caption = från { $from } till { $to } ({ $count ->
        [one] { $count } månad
       *[other] { $count } månader
    })
loan-transfers = { $count ->
        [0] Ingen överföring mellan dina markerade konton hittades.
        [one] En överföring mellan dina markerade konton hittades och räknades bort.
       *[other] { $count } överföringar mellan dina markerade konton hittades och räknades bort.
    }
loan-method = Genomsnitt över periodens hela månader, avstämda och registrerade transaktioner, utan överföringar mellan dina markerade konton.
loan-report-title = Lånesimulering
loan-report-made-on = simulering den { $date }
loan-disclaimer = Vägledande simulering utan avtalsvärde. Endast bankens erbjudande är bindande.
loan-tab-rules = Inställningar för bedömningen
loan-method-optimistic = Optimistisk
loan-method-neutral = Neutral
loan-method-severe = Sträng
loan-method-line = Bedömningsmetod: { $method }
loan-method-verdict = { $method }: { $verdict }
loan-rules-intro = Bedömningen svarar på tre frågor, och varje metod ställer sina egna krav. Välj den som passar dig: bedömningen på fliken ”Har jag råd att betala tillbaka?” följer den. Sista raden antar att dina utgifter ökar varje år med angiven procentsats; betalningen ligger fast.
loan-rule-row-debt = Godtagen skuldkvot
loan-rule-row-reference = Referenssparande
loan-rule-row-share = Andel av sparandet som betalningen får ta
loan-rule-row-floor = Gräns som saldot inte får gå under
loan-rule-row-sooner = Om saldot går under den även utan lånet
loan-rule-row-growth = Ökning av dina utgifter per år
loan-rule-limits = grönt upp till { $green }, orange upp till { $red }
loan-rule-reference = { $kind ->
        [good] en bra månad
        [hard] en svår månad
       *[usual] en vanlig månad
    }: { $amount }
loan-rule-floor-zero = noll
loan-rule-floor-cushion = en månads utgifter: { $amount }
loan-rule-sooner = orange om lånet tidigarelägger det med { $orange }, rött med { $red }
loan-unit-percent-year = % per år
loan-method-optimistic-explain = Den optimistiska metoden utgår från en bra månad, godtar en skuldkvot upp till 40 % och håller ingen reserv: den visar vad som är möjligt om allt går bra.
loan-method-neutral-explain = Den neutrala metoden utgår från en vanlig månad och följer bankernas regel, 33 till 35 % skuldkvot: den är referensbedömningen.
loan-method-severe-explain = Den stränga metoden utgår från en svår månad och håller en månads utgifter i reserv för det oväntade: den visar vad som håller även om det går dåligt.

# --- F42 — Consommation d'un appareil électrique (Fabrice, 09/10/2026) -------
# Ce que coûte un appareil, allumé et en veille, en heures pleines et en
# heures creuses. Le tarif est une préférence de la base (« tarif.electricite »).
menu-tools-appliance-cost = Förbrukning för en elapparat
window-appliance-title = Förbrukning för en elapparat
appliance-device-title = Apparaten
appliance-on-title = Påslagen
appliance-standby-title = I standbyläge
appliance-field-on-watts = Effekt vid drift
appliance-field-on-hours = Drifttid per dag
appliance-field-days = Användningsdagar per vecka
appliance-field-share = Andel av drifttiden på lågpristid
appliance-field-standby-watts = Effekt i standbyläge
appliance-field-standby-hours = Tid i standbyläge per användningsdag
appliance-unit-watts = W
appliance-unit-hours = h
appliance-unit-days = av 7
appliance-unit-percent = %
appliance-unit-price = { $sign }/kWh
appliance-standby-hint = Lämnas fältet tomt varar standbyläget resten av dygnet. Dagar utan användning är apparaten fortfarande ansluten: all den tiden räknas som standby. Är den urkopplad är standbyeffekten 0 W.
appliance-contract-title = Ditt avtal
appliance-field-option = Prismodell
appliance-option-base = Enkeltariff (ett pris)
appliance-option-off-peak = Högpristid / Lågpristid
appliance-field-base = Pris per kWh
appliance-field-peak = Pris per kWh på högpristid
appliance-field-off-peak = Pris per kWh på lågpristid
appliance-field-off-peak-hours = Lågpristimmar per dag
appliance-contract-hint = Dessa priser gäller bara för den här beräkningen. Det sparade elpriset ställs in under Inställningar › Alternativ › Verktyg.
appliance-contract-reset = Använd det sparade elpriset igen
appliance-period-day = Per dag
appliance-period-month = Per månad
appliance-period-year = Per år
appliance-energy = { $value } kWh
appliance-less-than = mindre än { $amount }
appliance-detail-title = Ett år i detalj
appliance-column-part = Post
appliance-column-energy = Energi
appliance-column-cost = Kostnad
appliance-column-share = Andel
appliance-line-on = Påslagen
appliance-line-standby = I standbyläge
appliance-line-on-peak = Påslagen, högpristid
appliance-line-on-off-peak = Påslagen, lågpristid
appliance-line-standby-peak = I standbyläge, högpristid
appliance-line-standby-off-peak = I standbyläge, lågpristid
appliance-line-total = Totalt
appliance-chart-title = Vart pengarna tar vägen
appliance-chart-caption = per år
appliance-standby-sentence = Bara standbyläget kostar { $amount } per år: { $share } av vad apparaten kostar.
appliance-note-plate = Effekten som står på apparaten eller i bruksanvisningen är ett maxvärde: vid drift förbrukar de flesta apparater mindre. För en verklig siffra kan du mäta med en energimätare för eluttaget och ange det den visar.
appliance-note-subscription = Den fasta avgiften räknas inte: du betalar den oavsett om apparaten är ansluten eller inte.
appliance-invalid-watts = Ange en effekt mellan 0 och 100 000 W.
appliance-invalid-hours = Ange en tid mellan 0 och 24 timmar per dag.
appliance-invalid-days = Ange ett helt antal dagar mellan 0 och 7.
appliance-invalid-share = Ange en andel mellan 0 och 100 %.
appliance-invalid-day-overflow = Drifttid och standby överstiger tillsammans 24 timmar per dygn.
appliance-invalid-price = Ange ett pris per kWh mellan 0 och 100.
appliance-invalid-off-peak-hours = Ange ett helt antal lågpristimmar mellan 0 och 24.
preferences-branch-tools = Verktyg
preferences-leaf-electricity = Elpris
preferences-electricity-blue = Tillbaka till EDF Tarif Bleu
preferences-electricity-hint = Elpriset i ditt avtal, som används av verktyget ”Förbrukning för en elapparat”. Som standard: EDF:s Tarif Bleu (Frankrike) per 1 augusti 2026, priser inklusive skatter, mätare på 3 till 6 kVA. Priserna ändras ofta i februari och augusti: skriv av dem från din faktura.

# --- F43 — Mon matelas de sécurité (Fabrice, 09/10/2026) -------------------------
# Combien de mois l'épargne tiendrait si les revenus s'arrêtaient. Les
# phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-safety-cushion = Min buffert
window-cushion-title = Min buffert
cushion-question = Om dina inkomster upphörde i morgon, hur många månader skulle ditt sparande räcka?
cushion-accounts-title = Dina konton
cushion-column-account = Konto
cushion-column-balance = Verkligt saldo
cushion-column-savings = Sparande
cushion-column-spending = Utgifter
cushion-accounts-hint = ”Sparande”: pengarna du skulle förlita dig på om något går snett. ”Utgifter”: kontona som dina vardagliga utgifter dras från.
cushion-history-label = Undersökt period
cushion-backup-label = Reservinkomst per månad
cushion-backup-hint = Det som fortfarande skulle komma in: a-kassa, partnerns lön… Tomt: ingen inkomst.
cushion-categories-title = Medräknade utgifter
cushion-categories-hint = Avmarkera det du skulle dra in på om något går snett.
cushion-categories-empty = Inga utgifter under den här perioden.
cushion-verdict-title = Din buffert
cushion-targets-title = Trygghetsnivåerna
cushion-projection-title = Ditt sparande om något går snett
cushion-projection-hint = Det som skulle finnas kvar varje månad om dina inkomster upphörde i dag.
cushion-note = En uppskattning utifrån din historik: utgifterna en svår månad kan skilja sig från genomsnittet.
cushion-invalid-backup = Beloppet kan inte läsas: rätta det för att räkna om.
cushion-no-spending-account = Markera minst ett ”Utgifter”-konto.
cushion-no-month = Den här perioden har ännu ingen hel månad.
cushion-months = { $value } mån.
cushion-per-month = { $amount } per månad
cushion-figure-holds = Ingen gräns
cushion-gauge-caption = av utgifterna täckta
cushion-verdict-short = Mindre än tre månader: ett bakslag skulle snabbt sätta dig i knipa.
cushion-verdict-fair = Mellan tre och sex månader: en hygglig buffert, bygg gärna på den om du kan.
cushion-verdict-solid = Sex månader eller mer: din buffert är stabil.
cushion-verdict-holds = Din reservinkomst täcker dina utgifter: ditt sparande skulle inte krympa.
cushion-verdict-nothing = Inga medräknade utgifter under perioden: det finns inget att täcka.
cushion-tile-savings = Tillgängligt sparande
cushion-tile-spending = Medräknade utgifter
cushion-tile-backup = Reservinkomst
cushion-tile-burn = Sparandet skulle krympa med
cushion-tile-rhythm = Spartakt
cushion-burn-none = Inget
cushion-target-title = { $months } månaders utgifter: { $amount }
cushion-target-reached = Uppnått.
cushion-target-date = { $missing } saknas. I din spartakt uppnås det omkring { $month }.
cushion-target-never = { $missing } saknas. Ditt sparande har inte vuxit under perioden: i den här takten nås inte nivån.
cushion-mark-empty = Tomt: { $month }
cushion-period = Genomsnitt för { $count ->
        [one] { $count } hel månad
       *[other] { $count } hela månader
    }, från { $from } till { $to }. { $transfers ->
        [0] Inga överföringar mellan dina konton.
        [one] En överföring mellan dina konton, borträknad.
       *[other] { $transfers } överföringar mellan dina konton, borträknade.
    }

# --- F44 — Objectif Épargne (Fabrice, 10/10/2026) --------------------------------
# Quand aurai-je ce montant, combien aurai-je à cette date, combien épargner.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-savings-goal = Sparmål
window-goal-title = Sparmål
goal-accounts-title = Följda konton
goal-column-account = Konto
goal-column-balance = Verkligt saldo
goal-accounts-hint = En överföring mellan två följda konton jämnas ut; en överföring till ett konto som inte följs räknas som en utgift.
goal-period-label = Referensperiod
goal-period-range = Årsintervall…
goal-range-from = från
goal-range-to = till
goal-question-title = Din fråga
goal-question-when = När har jag det här beloppet?
goal-question-amount = Hur mycket har jag vid det här datumet?
goal-question-effort = Hur mycket ska jag spara för att ha det här beloppet vid det här datumet?
goal-field-target = Målbelopp
goal-field-date = Måldatum
goal-field-rate = Årlig ränta på sparandet
goal-field-extra = Och om jag sparade mer, per månad
goal-options-hint = Tomma: ingen ränta, inget extra.
goal-answer-title = Svaret
goal-chart-title = Ditt saldo, i går och i morgon
goal-chart-hint = Heldragen linje: det verkliga saldot de senaste tolv månaderna; streckat: prognosen; ljust fält: spannet beroende på månaderna.
goal-disclaimer = En prognos utifrån din historik, inget löfte: något oväntat kan ändra allt.
goal-no-account = Markera minst ett konto att följa.
goal-no-month = Den här perioden har ännu ingen hel månad.
goal-invalid-target = Ange ett belopp att nå.
goal-invalid-date = Välj ett framtida datum inom de närmaste femtio åren.
goal-invalid-rate = Ange en ränta mellan 0 och 100 %.
goal-invalid-extra = Beloppet kan inte läsas: rätta det för att räkna om.
goal-per-month = { $amount } per månad
goal-tile-balance = Saldo i dag
goal-tile-rhythm = Genomsnittlig spartakt
goal-tile-target = Mål
goal-tile-reached = Nås omkring
goal-tile-date = Måldatum
goal-tile-projected = Beräknat saldo
goal-tile-saved = Sparat fram till dess
goal-tile-interest = Varav ränta
goal-tile-needed = Att spara
goal-when-already = Du har redan { $amount }: dina följda konton uppgår totalt till { $balance }.
goal-when-reached = Du har { $amount } omkring { $month }, om { $months ->
        [one] en månad
       *[other] { $months } månader
    }.
goal-when-range = Beroende på månaderna, mellan { $early } och { $late }.
goal-when-range-open = Tidigast omkring { $early }; med svaga månader skulle målet inte nås.
goal-when-never = I den här takten når du inte { $amount }.
goal-zero = Ditt saldo skulle sjunka till noll omkring { $month }.
goal-amount = I { $month } skulle du ha ungefär { $amount }.
goal-amount-range = Beroende på månaderna, mellan { $low } och { $high }.
goal-effort-more = För att ha { $amount } i { $month } skulle du behöva spara i genomsnitt { $monthly } per månad, alltså { $gap } mer än i dag.
goal-effort-less = För att ha { $amount } i { $month } skulle { $monthly } per månad räcka, alltså { $gap } mindre än i dag: du ligger före.
goal-effort-range = Beroende på månaderna skulle skillnaden mot din takt ligga mellan { $low } och { $high } per månad.
goal-chart-target = Mål: { $amount }
goal-chart-today = I dag
goal-note-seasons = Prognosen följer årstiderna: varje kommande månad får genomsnittet av samma månader under perioden.
goal-note-range = Spannet kommer från periodens svaga och starka månader: den lägsta fjärdedelen och den högsta fjärdedelen.
goal-note-loan = Lånet ”{ $label }” löper ut i { $month }: därefter { $amount } mer per månad.
goal-note-interest = Räntan räknas varje månad med { $rate } % per år: en förenkling av sparkontonas regel med halvmånadsperioder.
goal-period = Takten beräknad på { $count ->
        [one] { $count } hel månad
       *[other] { $count } hela månader
    }, från { $from } till { $to }. { $transfers ->
        [0] Inga överföringar mellan dina följda konton.
        [one] En överföring mellan dina följda konton, borträknad.
       *[other] { $transfers } överföringar mellan dina följda konton, borträknade.
    }

# --- F45 — Et si je réduisais… ? (Fabrice, 10/10/2026) ----------------------------
# Réduire des postes de dépense, et voir ce que ça change dans le temps.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-spending-cut = Tänk om jag drog ner på…?
window-cut-title = Tänk om jag drog ner på…?
cut-axis-label = Gruppera efter
cut-axis-category = Kategorier
cut-axis-payee = Motparter
cut-axis-budget-line = Budgetposter
cut-table-title = Dina utgifter, post för post
cut-table-hint = Skriv en minskning i % eller i { $sign } per månad på de poster du vill dra ner på. En minskning kan inte vara större än själva utgiften.
cut-column-monthly = Per månad
cut-column-cut = Minskning
cut-column-after = Efter
cut-column-yearly = Besparing per år
cut-total = Totalt
cut-horizon-label = Horisont
cut-settings-title = Inställningar
cut-options-hint = Räntan och målbeloppet är valfria.
cut-report-button = PDF-rapport
cut-chart-title = Ditt saldo, utan och med minskningarna
cut-chart-hint = Heldragen linje: det verkliga saldot de senaste tolv månaderna; grått streckat: prognosen utan minskningar; blått: med dem; grönt: pengarna du sparar.
cut-donut-title = Dina utgifter per månad efter minskningarna
cut-donut-caption = per månad efter minskningarna
cut-donut-others = Övriga poster
cut-donut-saved = Sparat
cut-legend-with = Med minskningarna
cut-legend-without = Utan minskningar
cut-years = { $years ->
        [one] { $years } år
       *[other] { $years } år
    }
cut-headline-none = Skriv en minskning i tabellen för att se effekten.
cut-headline = Genom att dra ner på { $count ->
        [one] den här posten
       *[other] de här { $count } posterna
    } skulle du lägga undan { $monthly } mer per månad, alltså { $yearly } per år.
cut-tile-monthly = Besparing per månad
cut-tile-yearly = Besparing per år
cut-tile-horizon = Besparing på { $years ->
        [one] { $years } år
       *[other] { $years } år
    }
cut-tile-spending = Utgifter per månad
cut-target-already = Du har redan { $amount }.
cut-target-sooner = Du skulle nå { $amount } omkring { $with } i stället för { $without }: { $months ->
        [0] inte tidigare
        [one] en månad tidigare
       *[other] { $months } månader tidigare
    }.
cut-target-only-with = Med de här minskningarna skulle du nå { $amount } omkring { $with }; utan dem, i din nuvarande takt, aldrig.
cut-target-never = Inte ens med de här minskningarna skulle du nå { $amount } i din nuvarande takt.
cut-note-seasons = Varje minskning följer sin posts årstider: en post som väger tyngst på sommaren ger störst besparing på sommaren.
cut-note-capped = En inskriven minskning var större än utgiften: den har sänkts till själva utgiften.
cut-invalid-cut = Minskningen kan inte läsas: ange en procentsats från 0 till 100 eller ett belopp per månad.
cut-report-settings = Inställningarna
cut-report-result = Resultatet
cut-report-accounts = Följda konton

# --- F46 — Préparer mes vacances (Fabrice, 10/10/2026) -----------------------------
# Ce que coûtera le prochain voyage, séjour ou croisière.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-holiday = Planera min semester
window-holiday-title = Planera min semester
holiday-trip-title = Resan
holiday-field-trip = Typ av resa
holiday-trip-stay = Vistelse
holiday-trip-cruise = Kryssning
holiday-field-adults = Vuxna
holiday-field-children = Barn
holiday-field-nights = Vistelsens längd, i nätter
holiday-field-days = Dagar
holiday-field-months = Månader före avresan
holiday-field-stops = Antal anlöpshamnar
holiday-saved-title = Redan sparat
holiday-saved-hint = Kryssa i kontona där semesterpengarna redan är undanlagda: deras verkliga saldo räknas som redan sparat.
holiday-budget-title = Budgeten
holiday-budget-hint = För varje post: ett belopp, vem det gäller och för hur länge. En tom post räknas inte.
holiday-optional-title = Valfria poster
holiday-result-title = Resultatet
holiday-donut-title = Vart resepengarna går
holiday-donut-caption = för resan
holiday-child-label = Barnpris
holiday-count-label = Hytter
holiday-open = Öppna ett projekt…
holiday-save = Spara projektet…
holiday-pdf = PDF-rapport
holiday-excel = Exportera till Excel
holiday-file-filter = Semesterprojekt
holiday-replace-question = Om du öppnar det här projektet ersätts det som är inskrivet i fönstret. Fortsätta?
holiday-file-saved = Projektet sparat: { $file }
holiday-file-opened = Projektet öppnat: { $file }
holiday-file-not-project = Den här filen är inte ett semesterprojekt från Radinus.
holiday-file-too-recent = Det här projektet kommer från en nyare version av Radinus: uppdatera Radinus för att öppna det.
holiday-file-failed = Filen kunde inte läsas eller skrivas: { $reason }
holiday-line-transport = Resa tur och retur
holiday-line-lodging = Boende
holiday-line-meals = Mat och vardagsutgifter
holiday-line-visits = Sevärdheter och nöjen
holiday-line-port = Resa till hamnen
holiday-line-cabins = Hytter
holiday-line-service = Serviceavgift (dricks)
holiday-line-drinks = Dryckespaket
holiday-line-excursions = Utflykter i hamnarna
holiday-line-port-taxes = Hamnavgifter
holiday-line-wifi = Wifi ombord
holiday-line-onboard = Utgifter ombord och i land
holiday-line-other = Övriga kostnader och oförutsett
holiday-line-insurance = Avbeställningsskydd
holiday-line-stay-tax = Turistskatt
holiday-line-car = Bil på plats, bränsle och vägtullar
holiday-line-parking = Parkering vid flygplatsen eller stationen
holiday-line-bank = Bankavgifter utomlands
holiday-line-formalities = Formaliteter (pass, visum, vaccin)
holiday-line-pets = Djurpassning
holiday-span-trip = för vistelsen
holiday-span-night = per natt
holiday-span-day = per dag
holiday-span-stop = per anlöpshamn
holiday-who-all = för alla
holiday-who-person = per person
holiday-who-adults = per vuxen
holiday-cabins-count = { $count ->
        [one] { $count } hytt
       *[other] { $count } hytter
    }
holiday-days = { $days ->
        [one] { $days } dag
       *[other] { $days } dagar
    }
holiday-invalid-count = Ange ett heltal.
holiday-invalid-amount = Beloppet kan inte läsas: ange ett positivt tal eller en procentsats från 0 till 100.
holiday-headline-empty = Skriv in budgetbeloppen för att se vad resan kommer att kosta.
holiday-headline-stay = Den här vistelsen skulle kosta { $total } för { $people ->
        [one] en person
       *[other] { $people } personer
    } och { $nights ->
        [0] ingen natt
        [one] en natt
       *[other] { $nights } nätter
    }.
holiday-headline-cruise = Den här kryssningen skulle kosta { $total } för { $people ->
        [one] en person
       *[other] { $people } personer
    } och { $nights ->
        [0] ingen natt
        [one] en natt
       *[other] { $nights } nätter
    }.
holiday-tile-total = Total kostnad
holiday-tile-person = Per person
holiday-tile-person-day = Per person och dag
holiday-tile-saved = Redan sparat
holiday-tile-remaining = Kvar att finansiera
holiday-tile-monthly = Sparande som behövs
holiday-remaining-none = Inget: det är täckt
holiday-monthly-none = Inget att lägga undan
holiday-monthly-now = Avresa den här månaden
holiday-note-days = Dagarna är nätterna plus en: sju nätter blir åtta dagar.
holiday-note-child = Per person betalar ett barn barnpriset om det är angivet; lämnas det tomt betalar barnet som en vuxen.
holiday-note-percent = En procentsats för försäkringen gäller resans huvudposter; den för bankavgifterna gäller utgifterna på plats.
holiday-sheet-budget = Budget
holiday-sheet-result = Resultat
holiday-column-line = Post
holiday-column-amount = Belopp
holiday-column-child = Barnpris
holiday-column-who = För vem
holiday-column-span = För hur länge
holiday-column-cost = Kostnad
holiday-disclaimer = En uppskattning utifrån dina egna belopp: de verkliga priserna kan variera.

# --- F45 (suite) — le projet de réduction en fichier (Fabrice, 10/10/2026) --------
# « Rajoute enregistrement et chargement JSON et aussi export Excel. »
cut-file-filter = Neddragningsprojekt
cut-file-not-project = Den här filen är inte ett neddragningsprojekt från Radinus.
cut-file-too-recent = Det här projektet kommer från en nyare version av Radinus: uppdatera Radinus för att öppna det.
cut-sheet-items = Poster

# --- F47 — Carnet de ma voiture (Fabrice, 10/10/2026) --------------------------------
# L'historique de la voiture : énergie, entretien, pièces, pneus, pannes, assurance, contrôle.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-car = Min bils loggbok
window-car-title = Min bils loggbok
car-unnamed = Min bil
car-sheet-title = Bilen
car-field-plate = Registreringsnummer
car-field-make = Märke
car-field-model = Modell
car-field-engine = Drivlina
car-field-first-hand = Första ägare
car-field-registered = Första registrering
car-field-acquired = Inköpsdatum
car-field-acquired-km = Mätarställning vid köpet
car-field-service = Service var
car-field-service-or = eller var
car-unit-months-short = mån
car-unit-km = km
car-tariff-title = Elpris för hemmaladdning
car-tariff-hint = Det här priset sparas i bilens loggbok: det ändrar inte priset i inställningarna.
car-tariff-reset = Hämta priset från inställningarna
car-engine-petrol = Bensin
car-engine-diesel = Diesel
car-engine-lpg = Gasol (LPG)
car-engine-e85 = E85 (etanol)
car-engine-hybrid = Hybrid
car-engine-plug-in = Laddhybrid
car-engine-electric = El
car-engine-hydrogen = Vätgas
car-energy-petrol = Bensin
car-energy-diesel = Diesel
car-energy-lpg = Gasol
car-energy-e85 = E85
car-energy-electricity = El
car-energy-hydrogen = Vätgas
car-unit-litre = L
car-unit-kwh = kWh
car-unit-kg = kg
car-rubric-energy = Energi
car-rubric-upkeep = Löpande underhåll
car-rubric-service = Service
car-rubric-wear = Slitdelar
car-rubric-tyres = Däck
car-rubric-breakdown = Haverier
car-rubric-insurance = Försäkring
car-rubric-inspection = Besiktning
car-part-brake-pads = Bromsklossar
car-part-brake-discs = Bromsskivor
car-part-timing-belt = Kamrem
car-part-clutch = Koppling
car-part-battery-12v = 12 V-batteri
car-part-shock-absorbers = Stötdämpare
car-part-wipers = Torkarblad
car-part-spark-plugs = Tändstift
car-part-glow-plugs = Glödstift
car-part-particulate-filter = Partikelfilter
car-part-catalytic-converter = Katalysator
car-part-fuel-cell-filter = Bränslecellsfilter
car-part-exhaust = Avgassystem
car-part-other = Annan del…
car-axle-all = Alla fyra däcken
car-axle-front = Framdäck
car-axle-rear = Bakdäck
car-verdict-pass = Godkänd
car-verdict-counter = Ombesiktning
car-charge-station = Vid en laddstation
car-charge-home = Hemma
car-slot-peak = Högpristid
car-slot-off-peak = Lågpristid
car-entry-new = Ny rad
car-entry-edit = Ändra raden
car-field-date = Datum
car-field-km = Mätarställning
car-field-rubric = Kategori
car-field-amount = Belopp
car-field-garage = Verkstad eller station
car-field-note = Anteckning
car-field-energy = Energi
car-field-quantity = Mängd
car-field-charge = Laddning
car-field-slot = Laddtid
car-field-part = Del
car-field-part-name = Delens namn
car-field-axle = Bytta däck
car-field-verdict = Resultat
car-field-months = Månader som täcks
car-field-battery = Batteriets skick
car-home-amount-hint = Beloppet för en hemmaladdning räknas ut med bilens elpris.
car-entry-add = Lägg till i loggboken
car-entry-update = Spara raden
car-entry-cancel = Avbryt
car-entry-delete = Ta bort raden
car-delete-question = Ta bort den här raden från loggboken?
car-from-operation = Hämta en transaktion…
car-pick-account = Vilket konto kommer utgiften från?
car-pick-operation = Vilken transaktion?
car-pick-take = Hämta
car-pick-none = Inga utgifter på det här kontot.
car-pick-taken = Transaktionen är hämtad: fyll i mätarställningen och kategorin och lägg sedan till raden.
car-history-title = Historiken
car-filter-all = Alla kategorier
car-history-empty = Inga rader ännu.
car-history-hint = Klicka på en rad för att ändra den.
car-column-date = Datum
car-column-km = Km
car-column-rubric = Kategori
car-column-detail = Detalj
car-column-amount = Belopp
car-column-garage = Verkstad
car-column-note = Anteckning
car-column-share = Andel
car-column-per-km = Per km
car-column-energy = Energi
car-column-quantity = Mängd
car-column-price = Snittpris
car-column-consumption = Förbrukning
car-column-part = Del
car-column-changes = Byten
car-column-last = Senaste byte
car-column-life = Livslängd
car-column-next = Nästa byte
car-total = Totalt
car-summary-title = Vad bilen kostar
car-headline-empty = Fyll i bilens uppgifter och lägg sedan till en första rad: en tankning, en service, en verkstadsräkning…
car-headline = Sedan { $since } har din bil kostat dig { $total }.
car-headline-km = Sedan { $since } har din bil kostat dig { $total } på { $km }: { $cost } per kilometer.
car-tile-total = Total kostnad
car-tile-month = Per månad
car-tile-km = Per kilometer
car-tile-driven = Körda kilometer
car-tile-consumption = Förbrukning
car-tile-energy-km = Energi per kilometer
car-km = { $value } km
car-quantity = { $value } { $unit }
car-per-100 = { $value } { $unit } / 100 km
car-per-unit = { $price } / { $unit }
car-months = { $months ->
        [one] { $months } månad
       *[other] { $months } månader
    }
car-detail-battery = Batteri: { $value } %
car-battery-line = { $when }: { $value } %
car-rubrics-title = Per kategori
car-energy-title = Energin
car-parts-title = Slitdelar
car-tyres-title = Däck
car-battery-title = Batteriets skick
car-years-title = Vad bilen har kostat varje år
car-donut-title = Vart pengarna tar vägen
car-donut-caption = totalt
car-deadlines-title = Kommande åtgärder
car-deadlines-empty = Inget att göra ännu: anteckna en service, en besiktning, en försäkring eller två byten av samma del.
car-deadline-service = Service
car-deadline-inspection = Besiktning
car-deadline-counter = Ombesiktning
car-deadline-insurance = Försäkringen löper ut
car-when-date = den { $date }
car-when-km = vid { $km }
car-when-km-reached = vid { $km }, omkring { $month } i din takt
car-when-date-km = den { $date } eller vid { $km }, det som inträffar först
car-when-inspection-unknown = Anteckna den senaste besiktningen för att få veta datumet för nästa.
car-tone-late = Försenad
car-tone-soon = Snart
car-note-since = Allt räknas från köpet: datumet och mätarställningen i bilens uppgifter.
car-note-consumption = Förbrukningen mäts från full tank till full tank: tanka fullt och anteckna mätarställningen varje gång.
car-note-e85 = En E85-bil dricker det den får: kilometrarna efter en tankning räknas för det bränslet.
car-note-home = En hemmaladdning prissätts efter bilens elpris den dag den antecknas och behåller den kostnaden.
car-note-inspection = Besiktningen följer den franska regeln: den första inom fyra år från första registreringen, sedan vartannat år; en ombesiktning inom två månader.
car-disclaimer = Kommande datum och livslängder är uppskattningar utifrån loggboken: bara tillverkarens servicebok gäller.
car-invalid-date = Ett giltigt datum som inte ligger i framtiden, tack.
car-invalid-acquired = Inköpsdatumet kan inte ligga före första registreringen.
car-invalid-km = En mätarställning i hela kilometer, tack.
car-invalid-amount = Det här beloppet går inte att läsa.
car-invalid-quantity = Skriv mängden: liter, kWh eller kilo.
car-invalid-part = Välj den bytta delen eller skriv dess namn.
car-invalid-rubric = Välj en kategori.
car-invalid-months = Ett helt antal månader, tack.
car-invalid-battery = Ett batteriskick från 0 till 100 %, tack.
car-open = Öppna en loggbok…
car-save = Spara loggboken…
car-report-button = PDF-rapport
car-file-filter = Billoggbok
car-file-saved = Loggboken har sparats: { $file }
car-file-opened = Loggboken har öppnats: { $file }
car-file-not-logbook = Den här filen är inte en billoggbok från Radinus.
car-file-too-recent = Den här loggboken kommer från en nyare version av Radinus: uppdatera Radinus för att öppna den.
car-replace-question = Om du öppnar den här loggboken ersätts den som finns i fönstret. Fortsätta?
car-sheet-history = Loggbok
car-sheet-summary = Sammanfattning

analysis-history-hint = Ju längre historik du har, desto bättre blir den här analysen: helst bör du ha minst ett års transaktioner.

# --- F48 — Dela en utgift (Fabrice, 11/10/2026, P-71) ---
menu-tools-sharing = Dela en utgift
window-sharing-title = Dela en utgift
sharing-question = Vem betalar vad?
sharing-setup-title = Delningen
sharing-field-label = Benämning
sharing-label-hint = Till exempel ”Restaurang 12/10” eller ”Bretagneresa 2027”: den ger namn åt filerna och rapporterna.
sharing-field-total = Totalt
sharing-total-hint = Om fältet lämnas tomt är totalen summan av posterna och av var och ens egna extran.
sharing-field-rule = Regel
sharing-field-rounding = Avrundning
sharing-field-people = Personer
sharing-mode-whole = En regel för hela utgiften
sharing-mode-item = En regel per post
sharing-rule-equal = Lika delar
sharing-rule-parts = Efter andelar
sharing-rule-percent = I procent
sharing-rule-income = I proportion till inkomsterna
sharing-rounding-cent = Till öret
sharing-rounding-euro = Till hela enheter
sharing-round-euro = Avrunda till hela enheter
sharing-hide-incomes = Dölj inkomsterna i rapporterna och exporten
sharing-people-title = Personerna
sharing-people-hint = En rad per person, en kolumn per post: kryssa i vem som deltar i vad. Allt annat är valfritt. Någon som hoppar av och lämnar kvar sin handpenning: ett exakt belopp lika med det som personen har betalat, och ingen ruta ikryssad.
sharing-add-person = Lägg till en person
sharing-person-default = Person { $number }
sharing-items-title = Posterna
sharing-items-hint = Bara det som inte gäller alla, som vinet. Resten av totalen går till den gemensamma posten.
sharing-add-item = Lägg till en post
sharing-common = Gemensam
sharing-payments-title = Betalningarna
sharing-payments-hint = Vem som har betalat, hur mycket och när. En rad utan belopp räknas inte ännu.
sharing-payments-none = Inga betalningar än.
sharing-add-payment = Lägg till en betalning
sharing-result-title = Resultatet
sharing-balances-title = Så ligger betalningarna till
sharing-transfers-title = Föreslagna överföringar
sharing-delete = Ta bort
sharing-delete-person-question = Den här personen har betalningar: ta bort dem tillsammans med personen?
sharing-disclaimer = Radinus föreslår en delning: mellan vänner står det var och en fritt att göra upp på annat sätt.
sharing-column-person = Person
sharing-column-household = Hushåll
sharing-column-income = Inkomst
sharing-column-parts = Andelar
sharing-column-percent = %
sharing-column-floor = Minst
sharing-column-cap = Högst
sharing-column-fixed = Exakt belopp
sharing-column-alone = Egna extran
sharing-column-gift = Skänkt överskott
sharing-column-share = Andel
sharing-column-typed = Angiven %
sharing-column-constraint = Vad som gällde
sharing-column-due = Att betala
sharing-column-item = Post
sharing-column-amount = Belopp
sharing-column-rule = Regel
sharing-column-participants = Deltagare
sharing-column-unit = Hushåll eller person
sharing-column-members = Medlemmar
sharing-column-paid = Betalt
sharing-column-balance = Saldo
sharing-column-date = Datum
sharing-column-who = Vem
sharing-column-label = Benämning
sharing-help-household = Personer i samma hushåll gör upp tillsammans: deras betalningar och skulder läggs ihop, och de får ett enda utdrag. Exempel: ”Familjen Martin” för föräldrarna och barnen.
sharing-help-income = Används bara av regeln ”I proportion till inkomsterna”: ju högre inkomst, desto större andel. Ange månadsinkomsten.
sharing-help-parts = En person med 2 andelar betalar dubbelt så mycket som en person med 1 andel. Exempel: vuxen 1, barn 0,5.
sharing-help-percent = Den andel av utgiften som personen betalar. Procentsatserna ska bli 100 % tillsammans.
sharing-help-floor = Personen betalar minst detta belopp, även om den beräknade andelen är mindre. Skillnaden minskar de andras andel.
sharing-help-cap = Personen betalar aldrig mer än detta belopp. Det som personen inte betalar faller på de andra deltagarna i personens poster.
sharing-help-fixed = Personen betalar exakt detta belopp, vad som än händer, och resten delas av de andra. Exempel: någon som hoppar av och lämnar kvar sin handpenning.
sharing-help-alone = Det personen har tagit enbart åt sig själv, som en dessert eller en kopp kaffe. Det betalas helt, utöver andelen.
sharing-help-gift = Om personen har betalat mer än sin andel: ikryssat är överskottet en gåva till gruppen, annars betalas det tillbaka.
sharing-help-items = Kryssa i de personer som deltar i den här posten. Den gemensamma posten är det som återstår av totalen när de andra posterna har tagits bort.
sharing-help-due = Det personen ska betala sammanlagt: andelen av posterna, egna extran och avrundningen.
sharing-help-share = Vad andelen utgör, i procent av den summa som delas.
sharing-help-typed = Den procentsats du angav. Den kan avvika från den faktiska andelen när ett minimum, ett maximum eller ett exakt belopp gällde.
sharing-help-constraint = Visar om personens andel ändrades av ett minimum, ett maximum, ett exakt belopp eller ett skänkt överskott.
sharing-help-item = Bara det som inte gäller alla, som vinet. Resten av totalen går till den gemensamma posten, som delas av dem som är ikryssade i den.
sharing-help-rule = Hur den här posten delas: lika delar, efter andelar, i procent eller i proportion till inkomsterna.
sharing-help-paid = Det hushållet eller personen redan har betalat, enligt de inmatade betalningarna.
sharing-help-balance = Det som återstår att betala, eller det som har betalats utöver andelen. Exempel: ”Återstår att betala: 61,54 €”.
sharing-advice-equal = { $count ->
        [one] { $total } för en enda person.
       *[other] { $total } ÷ { $count } personer = { $amount } var.
    }
sharing-advice-equal-varied = Lika delar mellan dem som deltar, med hänsyn till gränserna och undantagen.
sharing-advice-parts = { $parts } andelar totalt: en andel är värd { $amount }.
sharing-advice-parts-varied = Var och en betalar efter sina andelar, med hänsyn till gränserna och undantagen. En tom ruta räknas som 1 andel.
sharing-advice-percent-rest = Det saknas { $rest } % för att nå 100 %.
sharing-advice-percent-over = Procentsatserna går över 100 % med { $over } %.
sharing-advice-percent-ok = Procentsatserna blir precis 100 %.
sharing-advice-percent-nobody = Procentsatserna blir redan 100 %: { $count ->
        [one] { $names } skulle inte behöva betala något.
       *[other] ingen av { $names } skulle behöva betala något.
    }
sharing-advice-income = Var och en betalar { $rate } % av sin inkomst.
sharing-advice-income-missing = Ange var och ens inkomst för att dela i proportion till inkomsterna.
sharing-advice-income-varied = Var och en betalar samma andel av sin inkomst, med hänsyn till gränserna och undantagen.
sharing-advice-empty = Ange beloppet som ska delas.
sharing-apply-advice = Använd de föreslagna värdena
sharing-help-apply-advice = Fyller de tomma rutorna med de grå värdena. Rutor som redan är ifyllda ändras inte.
sharing-from-incomes = Procent utifrån inkomsterna
sharing-help-from-incomes = Ersätter procentsatserna med varje inkomsts andel av de sammanlagda inkomsterna. De blir 100 % tillsammans.
sharing-reset-percents = Fördela allt på nytt
sharing-help-reset-percents = Rensar procentsatserna och fördelar dem lika mellan alla. Praktiskt när du har lagt till en person.
sharing-reset-percents-question = Rensa alla procentsatser och fördela dem lika mellan alla?
sharing-open = Öppna ett projekt…
sharing-save = Spara projektet…
sharing-pdf-distribution = Fördelning (PDF)
sharing-pdf-payments = Betalningsläge (PDF)
sharing-pdf-statements = Individuella utdrag (PDF)…
sharing-statements-everyone = Alla
sharing-excel = Exportera till Excel
sharing-file-filter = Delningsprojekt
sharing-replace-question = Om du öppnar det här projektet ersätts det som är inskrivet i fönstret. Fortsätta?
sharing-file-saved = Projektet sparat: { $file }
sharing-file-opened = Projektet öppnat: { $file }
sharing-file-not-project = Den här filen är inte ett delningsprojekt från Radinus.
sharing-file-too-recent = Det här projektet kommer från en nyare version av Radinus: uppdatera Radinus för att öppna det.
sharing-file-failed = Filen kunde inte läsas eller skrivas: { $reason }
sharing-statements-replace-question = { $count ->
        [one] Ett utdrag finns redan i den här mappen. Ersätta det?
       *[other] { $count } utdrag finns redan i den här mappen. Ersätta dem?
    }
sharing-statements-written = { $count ->
        [one] Ett utdrag skrevs i ”{ $folder }”.
       *[other] { $count } utdrag skrevs i ”{ $folder }”.
    }
sharing-too-many-people = En delning kan ha högst 40 personer.
sharing-too-many-items = En delning kan ha högst 20 poster.
sharing-too-many-payments = En delning kan ha högst 400 betalningar.
sharing-invalid-amount = Beloppet går inte att läsa: det ska vara ett positivt tal.
sharing-invalid-number = Talet går inte att läsa: det ska vara ett positivt tal.
sharing-invalid-percent = En procentsats går från 0 till 100.
sharing-invalid-date = Datumet går inte att läsa.
sharing-name-missing = Varje person måste ha ett namn.
sharing-name-duplicate = Det finns redan ”{ $name }”: skilj dem åt, till exempel med en initial.
sharing-floor-above-cap = Minimum ligger över maximum.
sharing-item-label-missing = Posten saknar namn.
sharing-items-above-total = Posterna och var och ens egna extran överstiger totalen med { $amount }.
sharing-payment-person = Välj vem som har betalat.
sharing-percent-total = Procentsatserna blir { $sum } %: de ska bli 100 %.
sharing-percent-total-item = ”{ $item }”: procentsatserna blir { $sum } %: de ska bli 100 %.
sharing-item-nobody = Ingen deltar i ”{ $item }”.
sharing-item-no-weight = Ingen väger något i ”{ $item }”: alla deltagare står på noll.
sharing-income-missing = Inkomsten saknas för { $name }.
sharing-fixed-above = De exakta beloppen överstiger summan att dela med { $amount }.
sharing-floors-above = Minimibeloppen överstiger summan att dela med { $amount }.
sharing-cap-alone = { $name } är ensam om att delta i ”{ $item }”: maximum kan inte hållas.
sharing-caps-short = Maximibeloppen räcker inte för att täcka summan: { $amount } saknas.
sharing-impossible = De här villkoren kan inte alla hållas: lätta på ett minimum eller ett maximum.
sharing-constraint-floor = Minimum nått
sharing-constraint-cap = Maximum nått
sharing-constraint-fixed = Exakt belopp
sharing-constraint-gift = Skänkt överskott
sharing-and = { $first } och { $last }
sharing-outside = Utanför posterna
sharing-alone = Egna extran
sharing-rounding = Avrundning
sharing-headline-empty = Lägg till de personer som delar utgiften.
sharing-headline-no-amount = Ange totalen, eller posterna som ska delas.
sharing-headline-equal = { $total } att dela: var och en betalar { $amount }.
sharing-headline-range = { $total } att dela: från { $min } till { $max } beroende på person.
sharing-participants = { $count ->
        [0] Ingen deltagare
        [one] En deltagare
       *[other] { $count } deltagare
    }
sharing-balance-due = Återstår att betala: { $amount }
sharing-balance-over = Har betalat { $amount } mer än sin andel
sharing-balance-even = Utjämnat
sharing-summary-collected = { $collected } av { $total } är betalt.
sharing-summary-owing = { $count ->
        [0] Alla är utjämnade.
        [one] Bara en är fortfarande skyldig { $amount }.
       *[other] { $count } är fortfarande skyldiga { $amount } tillsammans.
    }
sharing-remaining-outside = Återstår att betala på utgiften: { $amount }
sharing-remaining-reimburse = Ska betalas tillbaka till { $name }: { $amount }
sharing-all-settled = Allt är uppgjort: ingen är skyldig någon något.
sharing-transfer = { $from } är skyldig { $to } { $amount }
sharing-warning-over-paid = Betalningarna överstiger utgiften med { $amount }: kontrollera beloppen.
sharing-note-income-zero = { $name } betalar ingenting på { $items }: inkomsten är 0.
sharing-note-excluded = { $name } deltar inte i ”{ $item }”: andelen fördelas på de andra.
sharing-note-gift = Överskottet som skänkts av { $giver } sänker de andras andel: { $name } har nu betalat mer än sin andel.
sharing-note-outside = { $name } betalar { $amount } utanför sina poster: beloppet dras av från det de andra delar.
sharing-note-keeper = Avrundat till hela enheter: { $name } behåller ören, så att totalen går jämnt ut.
sharing-report-distribution = Fördelning
sharing-report-sharing = Delningen
sharing-report-who-pays = Vem betalar vad
sharing-report-items = Detaljer per post
sharing-report-payments = Betalningsläge
sharing-report-as-of = Läget den { $date }
sharing-report-balances = Andel, betalt, saldo
sharing-report-statement = Utdrag — { $name }
sharing-report-your-share = Din andel
sharing-statement-total = Totalt för hushållet: { $amount }
sharing-statement-pay = Att betala till { $name }: { $amount }
sharing-statement-receive = Att få från { $name }: { $amount }
sharing-sheet-people = Personer
sharing-sheet-items = Poster
sharing-sheet-result = Resultat
sharing-sheet-payments = Betalningar
sharing-sheet-balances = Återbetalningar
