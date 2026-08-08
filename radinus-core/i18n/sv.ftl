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
menu-statistics-by-category = Statistik per kategori
menu-statistics-by-assignment = Statistik per tilldelning
menu-statistics-by-budget-line = Statistik per budgetpost
menu-statistics-by-payment-mode = Statistik per betalningssätt
menu-statistics-by-payee = Statistik per motpart och handlare
menu-statistics-by-project = Statistik per projekt
menu-statistics-dashboard = Instrumentpanel för transaktioner

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

menu-settings = Inställningar
menu-settings-about-author = Om upphovsmannen
menu-settings-about-radinus = Om Radinus
menu-settings-licence = Licens

menu-misc = Övrigt
menu-misc-calculator = Kalkylator
menu-misc-website = Gå till Radinus webbplats
menu-misc-database-folder = Öppna mappen som innehåller databasen
menu-misc-application-folder = Öppna mappen som innehåller programmet

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
   *[category] Statistik per kategori
}

statistics-axis-column = { $kind ->
    [assignment] Tilldelning
    [budget-line] BudgetPost
    [payment-mode] TransaktionsSätt
    [payee] Motpart
    [project] Projekt
   *[category] KategoriNamn
}

statistics-unclassified = { $kind ->
    [assignment] Utan tilldelning
    [budget-line] Utan budgetpost
    [payment-mode] Utan betalningssätt
    [payee] Utan motpart
    [project] Utan projekt
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
export-all-years-excel = Exportera alla år till Excel
export-all-years-ods = Exportera alla år till LibreOffice Calc
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
quick-column-date = Datum
quick-column-label = Beskrivning
quick-column-amount = Belopp
quick-column-category = Kategori
quick-column-assignment = Tilldelning
quick-column-payment-mode = Betalningssätt
quick-column-payee = Motpart
quick-column-project = Projekt
quick-column-status = Status
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
statement-title-open = Öppna en kontoutdragsfil (.ofx)
statement-title-info = Information om den öppnade filen
statement-title-integrate = För in markeringen i kontot
statement-title-validate = För in den här transaktionen i kontot
statement-duplicate = Varning dubblett: den här transaktionen verkar redan ha förts in i databasen (Financial Institution Transaction ID finns)
statement-no-fitid = Varning: den här filen anger ingen identifierare (FITID) för den här raden. En dubblett kan inte upptäckas.
statement-loaded = { $count ->
    [0] Den här filen innehåller inga transaktioner för det här kontot.
   *[other] { $count } rader lästa, varav { $known } redan finns i ditt konto.
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
    { $count } transaktioner, varav { $known } redan finns i ditt konto.
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
excel-backup-later = Säkerhetskopieringen är ännu inte inkopplad i den här versionen av Radinus 2. Stäng under tiden Radinus och kopiera själv din databasfil: då kan du importera utan att riskera något.

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
restore-unreadable = Den här filen är inget läsbart Radinus-arkiv: { $reason }
# Frågan säger vad som går förlorat innan det går förlorat. Arkivet har redan
# lästs vid det laget: det som den aviserar är säkert.
restore-question = Återställa ”{ $file }”? Allt nuvarande innehåll i din databas raderas och ersätts, och det som finns där går förlorat.
restore-done = Återställningen är klar: { $accounts } konton och { $operations } transaktioner.
restore-failed = Det gick inte att återställa: { $reason }


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

