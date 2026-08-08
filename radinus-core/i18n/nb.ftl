# Radinus — meldinger på core-siden (Fluent), norsk (bokmål).
# Fylles ut etter hvert som de core-modulene som lager meldinger til
# brukeren blir ferdige. Se 08_ARCHITECTURE.md §2.1.

# Plassholderen «0 = Ikke angitt» som hver valgfri kobling til grunndata
# bruker (02_BASE_DE_DONNEES.md §7 regel 2). Vises øverst i hver nedtrekksliste.
# ---------------------------------------------------------------------
# Språkets navn, skrevet på sitt eget språk.
#
# Det er dette menyen Innstillinger og velgeren ved første oppstart viser
# (01_CAHIER_DES_CHARGES.md §3.5: «hvert språk skrevet på sitt eget
# språk»). Det står her, og ikke i koden, fordi det er det eneste stedet
# der det kan være riktig: å legge til et språk er å legge inn en fil som
# kan navngi seg selv.
# ---------------------------------------------------------------------
language-name = Norsk bokmål

nomenclature-unspecified = Ikke angitt

# Spørres før et grunndataelement som transaksjoner fortsatt bruker slettes
# (02_BASE_DE_DONNEES.md §7 regel 5). Gjengitt ord for ord fra den
# opprinnelige WinDev-kilden (Enreg_Supprimer), typografien inkludert —
# formuleringen er forfatterens, den er ingen oversettelse.
nomenclature-delete-confirm = Transaksjoner (banktransaksjoner) som har attributtet av typen '{ $label }' er oppdaget. Bekrefter du at du vil tilbakestille dette attributtet?

# Spørres før et grunndataelement som ingenting bruker slettes. Originalen
# slettet et slikt element med det samme, uten et ord; Fabrice ba
# 25/07/2026 om at en sletting alltid skal bekreftes — et bevisst avvik fra
# hans egen kode, og det eneste i denne modulen.
nomenclature-delete-plain = Bekrefter du slettingen av «{ $label }»?

# Nektelse som vises når elementet brukeren er i ferd med å slette er nettopp
# det som kortet viser. Fabrices avgjørelse 25/07/2026: et element slettes
# ikke under sitt eget åpne kort — kortet lukkes først, i stedet for å bli
# stående og vise en post som ikke lenger finnes.
nomenclature-delete-form-open = Kortet for «{ $label }» er åpent. Lukk det før du sletter.

# Nektelse som vises når beskrivelsen som lagres allerede bæres av et annet
# element i samme grunndata (forfatterens avgjørelse, 25/07/2026: to elementer
# i samme grunndata må ikke dele navn — å plassere en transaksjon under en av
# to identiske beskrivelser er myntkast). `element` er substantivet i sitt eget
# kjønn, «en kategori», «en motpart»; `label` er den eksisterende beskrivelsen,
# slik den er lagret, så brukeren ser hva som står i veien.
nomenclature-duplicate = Det finnes allerede { $element } med samme navn: «{ $label }».

# ---------------------------------------------------------------------
# Hva vinduene sier om seg selv.
#
# Alt står her, også det som avhenger av grunndataene som vises: setningene
# er skrevet ut i sin helhet, språk for språk, i stedet for å settes sammen
# av ord og kjønn. En sammensetning som er riktig på fransk er feil i det
# neste språket, og det ender med at koden vet at det finnes et hunkjønn —
# det er ikke dens oppgave (forfatterens regel, 25/07/2026: «programmet
# fungerer med Fluent på fransk og engelsk helt fra begynnelsen»).
# ---------------------------------------------------------------------

ui-loading = Laster inn…
ui-editing = Redigering.
ui-viewing = Visning.
ui-modified-suffix = — endret
ui-label-required = Beskrivelsen er obligatorisk.
ui-discard-question = Vil du forkaste endringene?
ui-yes = Ja
ui-no = Nei
ui-select-record = Velg en post
ui-key-multiselect = CTRL
ui-multiselect-help = Info: Bruk museklikk + tasten [{ $modifier }] i tabellen for å velge flere elementer
ui-no-match = Ingen beskrivelse samsvarer med filteret.
ui-filter-placeholder = Filtrer beskrivelser…
ui-column-label = BESKRIVELSE
ui-field-label = Beskrivelse
ui-field-budget-line = Budsjettpost
ui-identifier = Identifikator
ui-deletion-abandoned = Slettingen ble avbrutt: ingenting er endret.
ui-unknown-nomenclature = Ukjente grunndata:

ui-title-filter = Filtrer
ui-title-create = Opprett
ui-title-update = Rediger utvalget
ui-title-delete = Slett utvalget
ui-title-read = Vis utvalget
ui-title-close = Lukk
ui-title-save = Lagre
ui-title-add = Legg til
ui-title-modify = Rediger

ui-load-failed = Kan ikke laste inn:
ui-save-failed = Kan ikke lagre:
ui-read-failed = Kan ikke lese:
ui-delete-failed = Kan ikke slette:
ui-open-failed = Kan ikke åpne:
ui-close-failed = Kan ikke lukke:

# --- Setninger som hører til hver enkelt grunndatatype ---------------

nomenclature-identifier = { $kind ->
    [category] Identifikator for kategori
    [assignment] Identifikator for tildeling
    [payment-mode] Identifikator for betalingsmåte
    [payee] Identifikator for motpart
    [project] Identifikator for prosjekt
    [budget-line] Identifikator for budsjettpost
   *[bank] Identifikator for bank
}

nomenclature-none = { $kind ->
    [category] Ingen kategorier.
    [assignment] Ingen tildelinger.
    [payment-mode] Ingen betalingsmåter.
    [payee] Ingen motparter.
    [project] Ingen prosjekter.
    [budget-line] Ingen budsjettposter.
   *[bank] Ingen banker.
}

nomenclature-nothing-to-show = { $kind ->
    [category] Ingen kategorier å vise.
    [assignment] Ingen tildelinger å vise.
    [payment-mode] Ingen betalingsmåter å vise.
    [payee] Ingen motparter å vise.
    [project] Ingen prosjekter å vise.
    [budget-line] Ingen budsjettposter å vise.
   *[bank] Ingen banker å vise.
}

nomenclature-gone = { $kind ->
    [category] Denne kategorien finnes ikke lenger.
    [assignment] Denne tildelingen finnes ikke lenger.
    [payment-mode] Denne betalingsmåten finnes ikke lenger.
    [payee] Denne motparten finnes ikke lenger.
    [project] Dette prosjektet finnes ikke lenger.
    [budget-line] Denne budsjettposten finnes ikke lenger.
   *[bank] Denne banken finnes ikke lenger.
}

nomenclature-fresh = { $kind ->
    [category] Ny kategori.
    [assignment] Ny tildeling.
    [payment-mode] Ny betalingsmåte.
    [payee] Ny motpart.
    [project] Nytt prosjekt.
    [budget-line] Ny budsjettpost.
   *[bank] Ny bank.
}

nomenclature-created = { $kind ->
    [category] Kategori lagt til.
    [assignment] Tildeling lagt til.
    [payment-mode] Betalingsmåte lagt til.
    [payee] Motpart lagt til.
    [project] Prosjekt lagt til.
    [budget-line] Budsjettpost lagt til.
   *[bank] Bank lagt til.
}

nomenclature-updated = { $kind ->
    [category] Kategori endret.
    [assignment] Tildeling endret.
    [payment-mode] Betalingsmåte endret.
    [payee] Motpart endret.
    [project] Prosjekt endret.
    [budget-line] Budsjettpost endret.
   *[bank] Bank endret.
}

nomenclature-deleted = { $kind ->
    [category] { $count ->
        [one] 1 kategori slettet.
       *[other] { $count } kategorier slettet.
      }
    [assignment] { $count ->
        [one] 1 tildeling slettet.
       *[other] { $count } tildelinger slettet.
      }
    [payment-mode] { $count ->
        [one] 1 betalingsmåte slettet.
       *[other] { $count } betalingsmåter slettet.
      }
    [payee] { $count ->
        [one] 1 motpart slettet.
       *[other] { $count } motparter slettet.
      }
    [project] { $count ->
        [one] 1 prosjekt slettet.
       *[other] { $count } prosjekter slettet.
      }
    [budget-line] { $count ->
        [one] 1 budsjettpost slettet.
       *[other] { $count } budsjettposter slettet.
      }
   *[bank] { $count ->
        [one] 1 bank slettet.
       *[other] { $count } banker slettet.
      }
}

nomenclature-duplicate-name = { $kind ->
    [category] Det finnes allerede en kategori med samme navn: «{ $label }».
    [assignment] Det finnes allerede en tildeling med samme navn: «{ $label }».
    [payment-mode] Det finnes allerede en betalingsmåte med samme navn: «{ $label }».
    [payee] Det finnes allerede en motpart med samme navn: «{ $label }».
    [project] Det finnes allerede et prosjekt med samme navn: «{ $label }».
    [budget-line] Det finnes allerede en budsjettpost med samme navn: «{ $label }».
   *[bank] Det finnes allerede en bank med samme navn: «{ $label }».
}

# --- Vindustitler, uten aksenter som på de opprinnelige vinduene -----

window-list-title = { $kind ->
    [category] Liste over kategorier
    [assignment] Liste over tildelinger
    [payment-mode] Liste over betalingsmåter
    [payee] Liste over motparter og forhandlere
    [project] Liste over prosjekter
    [budget-line] Liste over budsjettposter
   *[bank] Liste over banker
}

window-form-title = { $kind ->
    [category] Kort for kategori
    [assignment] Kort for tildeling
    [payment-mode] Kort for betalingsmåte
    [payee] Kort for motpart
    [project] Kort for prosjekt
    [budget-line] Kort for budsjettpost
   *[bank] Kort for bank
}

# --- Menylinje (01_CAHIER_DES_CHARGES.md §6) --------------------------

menu-file = Fil
menu-file-import-statements = Import av kontoutskrifter
menu-file-import-excel = Import av Excel-fil
menu-file-backup = Sikkerhetskopiering
menu-file-restore = Gjenoppretting
menu-file-repair = Reparasjon og optimalisering av databasen
menu-file-log = Vis loggen
menu-tools-password = Beskytt databasen med et passord
menu-file-disconnect = Koble fra gjeldende database
menu-file-quit = Avslutt

menu-accounts = Kontoer
menu-accounts-manage = Håndtering av bankkontoer
menu-accounts-balances = Se saldoene på kontoene dine
menu-accounts-operations = Håndter transaksjonene på en konto
menu-accounts-quick-classify = Rask klassifisering av transaksjoner
menu-accounts-recurring = Håndtering av gjentakende transaksjoner
menu-accounts-transfer = Overfør et beløp mellom to kontoer
menu-accounts-checkbooks = Håndtering av sjekkhefter

menu-statistics = Statistikk
menu-statistics-balance-chart = Graf Saldoutvikling
menu-statistics-by-category = Stat. per kategori
menu-statistics-by-assignment = Stat. per tildeling
menu-statistics-by-budget-line = Stat. per budsjettpost
menu-statistics-by-payment-mode = Stat. per betalingsmåte
menu-statistics-by-payee = Stat. per motpart og forhandler
menu-statistics-by-project = Stat. per prosjekt
menu-statistics-dashboard = Dashbord for transaksjoner

menu-budget = Budsjett
menu-budget-entry = Budsjettregistrering
menu-budget-control = Budsjettkontroll

menu-nomenclatures = Grunndata
menu-nomenclature = { $kind ->
    [category] Kategorier
    [assignment] Tildelinger
    [payment-mode] Betalingsmåter
    [payee] Motparter og forhandlere
    [project] Prosjekter
    [budget-line] Budsjettposter
   *[bank] Banker
}
menu-nomenclatures-templates = Transaksjonsmaler

menu-settings = Innstillinger
menu-settings-about-author = Om opphavsmannen
menu-settings-about-radinus = Om Radinus
menu-settings-licence = Lisens

menu-misc = Diverse
menu-misc-calculator = Kalkulator
menu-misc-website = Gå til nettstedet til Radinus
menu-misc-database-folder = Åpne mappen som inneholder databasen

# L'avertissement posé devant ce dossier (Fabrice, 08/08/2026) : « un
# utilisateur ignorant peut faire des bêtises ». La question est posée
# avant l'ouverture, jamais après.
database-folder-warning-title = Åpne databasens mappe
database-folder-warning =
    Denne mappen inneholder alle dataene dine. Å gi nytt navn til, flytte eller slette en fil kan miste kontoene dine, ødelegge dem eller hindre Radinus i å virke.
    Vil du virkelig åpne den?
menu-misc-application-folder = Åpne mappen som inneholder programmet
menu-misc-attachments-folder = Tilgang til mappen med vedleggene
# --- « Gestion des pièces jointes » (08/08/2026) -------------------------
#
# La fenêtre montre les pièces de toutes les opérations, plus les fichiers
# du dossier que la base ne réclame pas. Les cinq états ne sont pas trois :
# un fichier disparu, un fichier modifié et un fichier qu'on ne sait pas
# juger ne se traitent pas de la même façon.
menu-settings-attachments = Behandling av vedleggene
window-attachments-manager-title = Behandling av vedleggene
attachments-column-document = Dokument
attachments-column-size = Størrelse
attachments-column-added = Lagt til den
attachments-column-state = Tilstand
attachments-state-intact = Uendret
attachments-state-altered = Endret siden
attachments-state-missing = Filen mangler
attachments-state-unknown = Kan ikke kontrolleres
attachments-state-orphan = Foreldreløs
attachments-no-operation = Ingen post
attachments-orphan-remove-question = Denne filen hører ikke til noen post. Flytte den til papirkurven?
attachments-manager-help = Dobbeltklikk på en linje for å åpne dokumentet.

# Les deux entrées du clic droit. « Afficher l'opération » n'apparaît pas
# sur un orphelin — il n'appartient à aucune opération — et « Révéler »
# disparaît quand le fichier n'est plus sur le disque.
attachments-show-operation = Vis posten
attachments-reveal = Vis i filbehandleren
attachments-manager-summary = { $count } vedlegg, { $size } til sammen.
attachments-disk-name = Navn på disken: { $name }

# L'avertissement du dossier des pièces jointes (Fabrice, 08/08/2026).
# Le danger n'y est pas le même que pour la base : on ne perd pas des
# comptes, on casse un lien — l'opération annonce une pièce qui ne
# s'ouvre plus. C'est ce que dit la phrase, plutôt que « ne faites pas
# n'importe quoi ».
attachments-folder-warning-title = Åpne vedleggenes mappe
attachments-folder-warning =
    Denne mappen inneholder filene du har lagt ved postene dine. Radinus lagrer dem under et navn den velger selv: å gi nytt navn til, flytte eller slette en fil løsner den ikke fra posten, som fortsatt viser den selv om den ikke lenger åpnes.
    Vil du virkelig åpne den?

# ---------------------------------------------------------------------
# Bankkontoer — F04, F06, F07, F08.
# Skrivefeilene i versjon 1.9.3 («Bank Identifer Code», «Solde
# initial prevu», «Est Cloturé», mellomrommet foran IBAN-parentesen)
# er rettet: avgjørelse tatt av Fabrice 25/07/2026.
# ---------------------------------------------------------------------

window-accounts-title = Håndtering av bankkontoer
window-accounts-select-title = Liste over kontoer
window-balances-title = Saldoer på kontoene dine
window-account-title = Kontokort

accounts-none = Ingen konto.
accounts-nothing-to-show = Ingen konto å vise.
accounts-gone = Denne kontoen finnes ikke lenger.
accounts-fresh = Ny konto.
accounts-created = Kontoen er lagt til.
accounts-updated = Kontoen er endret.
accounts-deleted = { $count ->
    [one] 1 konto slettet.
   *[other] { $count } kontoer slettet.
}
accounts-duplicate-name = Det finnes allerede en konto med samme navn: «{ $label }».
accounts-multiselect-help = Info: Bruk museklikk + [{ $modifier }]-tasten i tabellen for å velge flere kontoer
accounts-select-question = Hvilke bankkontoer skal statistikken baseres på?

accounts-column-label = BESKRIVELSE
accounts-column-bank = Bank
accounts-column-type = Kontotype
accounts-column-number = Kontonr
accounts-column-account = Konto
accounts-column-bank-balance = Banksaldo
accounts-column-real-balance = Faktisk
accounts-column-final-balance = Endelig
accounts-total = TOTALT

# Når en konto slettes, forsvinner transaksjonene med den: dette er det eneste
# stedet i programmet der en sletting ødelegger historikk.
accounts-delete-plain = Bekrefter du slettingen av kontoen «{ $label }»?
accounts-delete-with-operations = Kontoen «{ $label }» inneholder { $count } transaksjoner, som blir slettet sammen med den. Bekrefter du slettingen?
accounts-delete-form-open = Kontokortet for «{ $label }» er åpent. Lukk det før du sletter.

account-group-bank = Konto- og bankopplysninger
account-group-holder = Kontoinnehaver
account-group-rib = Bankopplysninger (RIB)
account-group-activity = Aktivitet
account-group-balances = Saldoer

account-field-label = Kontonavn
account-field-bank = Bank
account-field-type = Kontotype
account-field-branch-address = Adresse til bankfilialen
account-field-holder-name = Navn
account-field-holder-address = Adresse
account-field-rib-bank = Bankkode
account-field-rib-branch = Filialkode
account-field-rib-number = Kontonummer
account-field-rib-key = RIB-kontrollsiffer
account-field-bic = BIC (Bank Identifier Code)
account-field-iban = IBAN (International Bank Account Number)
account-field-opening-date = Åpningsdato
account-field-closing-date = Avslutningsdato
account-field-closed = Er avsluttet
account-field-opening-pointed = Avstemt inngående saldo
account-field-opening-committed = Reservert inngående saldo
account-field-opening-planned = Planlagt inngående saldo

account-label-required = Kontonavnet er obligatorisk.
account-iban-invalid = Denne IBAN-en er ikke gyldig: kontroller kontrollsifrene.
# Den blå linjen nederst på kontokortet, ord for ord den fra 1.9.3 — bare
# beløpene følger nå samme format som de andre feltene.
account-control-line = Avstemt inngående saldo ({ $opening }) + Sum transaksjoner ({ $operations }) = Nåværende banksaldo: { $balance }.

amount-not-readable = «{ $field }» inneholder ikke et gyldig beløp.

ui-thousands-separator =  
ui-decimal-separator = ,

# --- Transaksjonsliste (F02) -----------------------------------------

window-operations-title = Transaksjonsliste for kontoen: { $account }

operations-none = Ingen transaksjoner i denne perioden.
operations-bad-period = Periodens grenser er ikke gyldige datoer.
operations-from = Startdato
operations-to = Sluttdato
operations-delete-confirm = { $count ->
    [one] Bekrefter du slettingen av denne transaksjonen?
   *[other] Bekrefter du slettingen av disse { $count } radene? Deltransaksjonene til de valgte transaksjonene blir slettet sammen med dem.
}
operations-deleted = { $count ->
    [one] 1 transaksjon slettet.
   *[other] { $count } transaksjoner slettet.
}
operations-selection-total = Totalt beløp for de valgte transaksjonene: { $amount }

operations-column-date = Dato
operations-column-clearing-date = Avstemmingsdato
operations-column-label = Beskrivelse
operations-column-category = Kategori
operations-column-assignment = Tildeling
operations-column-payment-mode = BetMåte
operations-column-payee = Motpart
operations-column-project = Prosjekter
operations-column-month = Måned
operations-column-debit = Debet
operations-column-credit = Kredit
operations-column-balance = Saldo
operations-column-comments = Kommentarer
operations-column-attachments = Vedlegg
operations-column-check = Sjekknr

operations-foot-debit = Debet:
operations-foot-credit = Kredit:
operations-foot-total = Totalt:
operations-foot-bank = Banksaldo:
operations-foot-real = Faktisk saldo:
operations-foot-final = Sluttsaldo:

operations-menu-export = Eksport
operations-menu-print = Utskrift
operations-menu-filter = Filter
operations-menu-period = Periode
operations-menu-misc = Diverse

operations-title-point = Avstem utvalget
operations-title-sub = Legg til en deltransaksjon
operations-title-duplicate = Dupliser utvalget
operations-not-yet = Dette vinduet finnes ikke ennå: det kommer lenger ute i planen.

accounts-choose-question = Hvilken konto vil du arbeide med?
ui-title-select = Velg utvalget

month-january = januar
month-february = februar
month-march = mars
month-april = april
month-may = mai
month-june = juni
month-july = juli
month-august = august
month-september = september
month-october = oktober
month-november = november
month-december = desember

operations-period-year = Inneværende år

# --- Periodemenyen i F02 ---------------------------------------------
# Ni oppføringer, hvorav to åpner en undermeny med de tolv månedene. Hver av
# dem gjør bare én ting: utlede en startdato og en sluttdato av seg selv, som
# vinduet legger tilbake i sine to felt (ønske fra Fabrice, 25/07/2026).

period-all = Alle
period-last-year = Forrige År
period-this-year = Inneværende År
period-whole-year = Hele året
period-last-month = Forrige Måned
period-this-month = Inneværende Måned
period-last-week = Forrige Uke
period-this-week = Inneværende Uke
period-yesterday = I går
period-today = I dag

# --- Filter-menyen i F02 ---------------------------------------------
# Filtrerer radene etter transaksjonens art (ønske fra Fabrice,
# 25/07/2026). De tre statusene er databasens: 1 avstemt, 2 reservert,
# 3 planlagt (02_BASE_DE_DONNEES.md §5.2).

filter-all = Alle transaksjoner
filter-pointed = Bare avstemte transaksjoner
filter-committed = Bare reserverte transaksjoner
filter-planned = Bare planlagte transaksjoner

# --- Transaksjonsskjema (F03) ----------------------------------------
# Ledetekstene er de fra skjermbildet «Fiche operation transaction.png»,
# med originalens skrivefeil rettet (tillatelse fra Fabrice, 25/07/2026:
# «les coquilles tu les corriges»): «Libelle» blir «Libellé»,
# «Categorie» blir «Catégorie», «Statut Operation» blir
# «Statut opération».

window-operation-title = Transaksjon konto: { $account }

operation-menu-identification = Identifikasjon
operation-menu-options = Valg
operation-fitid-edit = Rediger FITID…
operation-fitid-delete = Slett FITID
operation-fitid-question = FITID for denne transaksjonen:
operation-fitid-delete-question = Slette FITID for denne transaksjonen?
operation-fitid-written = FITID lagret.
operation-fitid-removed = FITID slettet.

operation-group-identification = Identifikasjon av transaksjonen
operation-group-amount = Transaksjonens beløp
operation-group-status = Transaksjonens status
operation-group-classification = Klassifisering av transaksjonen for beregning av statistikken
operation-group-check = Sjekk knyttet til transaksjonen
operation-group-comment = Kommentar

operation-field-label = Beskrivelse
operation-field-reference = Betalingsreferanse
operation-field-date = Dato
operation-field-direction = Transaksjonstype:
operation-field-amount = Beløp
operation-field-status = Transaksjonsstatus
operation-field-clearing-date = Avstemmingsdato
operation-field-category = Kategori
operation-field-assignment = Tildeling
operation-field-payment-mode = Måte
operation-field-payee = Motpart
operation-field-project = Prosjekt
operation-field-check = Knytt til sjekk

operation-direction-debit = Debet
operation-direction-credit = Kredit

operation-check-info = Info.
operation-check-link = Knytt
operation-check-unlink = Slett

operation-fresh = Ny transaksjon.
operation-created = Transaksjon lagt til.
operation-updated = Transaksjon endret.
operation-gone = Denne transaksjonen finnes ikke lenger.
operation-nothing-to-show = Ingen transaksjoner å vise.
operation-label-required = Transaksjonens beskrivelse er obligatorisk.
operation-date-required = Transaksjonens dato er obligatorisk.
operation-clearing-date-invalid = Avstemmingsdatoen er ikke en gyldig dato.
operation-is-a-sub = Denne raden er en deltransaksjon: den endres fra sitt eget skjema.
operation-delete-form-open = Skjemaet for «{ $label }» er åpent. Lukk det før du sletter.

operation-attachments = { $count ->
    [0] Ingen vedlegg
    [one] 1 vedlegg
   *[other] { $count } vedlegg
}

operation-title-comment = Kommentar til transaksjonen
operation-title-sub = Opprett en deltransaksjon
operation-title-template = Transaksjonsmaler
operation-title-attachment = Vedlegg

# --- Deltransaksjonsskjema (F04) -------------------------------------
# Nedkortet versjon av F03: verken Måte, Status eller Dato — en
# deltransaksjon arver dem fra moren sin (`Maj_ProprieteSousOp`, bekreftet av
# Fabrice den 26/07/2026: «dans une sous-opération, comme est le complément,
# on ne peut pas toucher au mode de paiement, cela serait illogique»).

window-sub-operation-title = Skjema Deltransaksjon

sub-operation-group-amount = Deltransaksjonens beløp
sub-operation-field-label = Navn
sub-operation-fresh = Ny deltransaksjon.
sub-operation-created = Deltransaksjon lagt til.
sub-operation-updated = Deltransaksjon endret.
sub-operation-gone = Denne deltransaksjonen finnes ikke lenger.
sub-operation-nothing-to-show = Ingen deltransaksjoner å vise.
sub-operation-label-required = Deltransaksjonens navn er obligatorisk.
sub-operation-parent-gone = Transaksjonen som skal fordeles, finnes ikke lenger.
# Det skjemaet sier når det viser Resten. Den er ikke beskyttet: den kan
# endres, men man må vite hva man gir seg inn på (beslutning av
# Fabrice, 26/07/2026).
sub-operation-is-the-complement = Dette er Resten: det som gjenstår å fordele. Gir du den nytt navn eller endrer beløpet, blir den en vanlig deltransaksjon.
sub-operation-of = Fordeling av «{ $label }» ({ $amount })

operations-pointed = { $count ->
    [one] 1 transaksjon avstemt.
   *[other] { $count } transaksjoner avstemt.
}
operations-select-one = Velg bare én transaksjon.

# --- Duplisering og visning av deltransaksjonene (F02) ----------------
# Duplisering åpner et forhåndsutfylt skjema som brukeren selv bekrefter
# (beslutning av Fabrice, 26/07/2026): ingenting skrives før han har lagret,
# og han kan rette datoen eller beløpet først.

operation-copy = Kopi som skal lagres: ingenting er opprettet ennå.
operations-show-children = Vis alle deltransaksjoner
operations-hide-children = Skjul alle deltransaksjoner

# --- Andre bekreftelse ved en alvorlig sletting -----------------------
# Å slette en bankkonto drar med seg hele historikken dens: et Ja/Nei blir
# klikket bort uten å bli lest, så vi ber om at ordet skrives (beslutning av
# Fabrice, 26/07/2026). Ordet er ordbokens — «Ja» her, «Yes» på engelsk —
# så det er ingenting å oversette to ganger her.

accounts-delete-second-question = Denne slettingen er endelig og drar med seg hele kontoens historikk. Skriv «{ $word }» for å bekrefte den.

# --- F20-F24 — De seks statistikkene ----------------------------------
# Felles mal, utviklet langs seks akser. Den etter kategori tjente som
# forelegg, og Fabrice godkjente den 26/07/2026 før de fem andre fantes —
# kolonnenavnene er originalens.

window-statistics-title = { $kind ->
    [assignment] Statistikk etter tildeling
    [budget-line] Statistikk etter budsjettpost
    [payment-mode] Statistikk etter betalingsmåte
    [payee] Statistikk etter motpart og forhandler
    [project] Statistikk etter prosjekt
   *[category] Statistikk etter kategori
}

statistics-axis-column = { $kind ->
    [assignment] Tildeling
    [budget-line] BudsjettPost
    [payment-mode] TransaksjonsMåte
    [payee] Motpart
    [project] Prosjekter
   *[category] KategoriNavn
}

statistics-unclassified = { $kind ->
    [assignment] Uten tildeling
    [budget-line] Uten budsjettpost
    [payment-mode] Uten betalingsmåte
    [payee] Uten motpart
    [project] Uten prosjekt
   *[category] Uten kategori
}
statistics-total = Totalt
statistics-sum = Sum
statistics-cumulative = Kumulert

# Båndets fem brytere. Ledeteksten veksler ON/OFF, som i originalen: det er
# bryteren selv som sier hvor den står.
statistics-switch-pointed = Avstemte transaksjoner { $state }
statistics-switch-committed = Reserverte transaksjoner { $state }
statistics-switch-planned = Planlagte transaksjoner { $state }
statistics-switch-debits = Debetbeløp { $state }
statistics-switch-credits = Kreditbeløp { $state }
statistics-switch-on = ON
statistics-switch-off = OFF

statistics-no-account = Ingen konto er valgt: statistikken omfatter ingenting.
statistics-no-data = Ingen transaksjoner dette året for de valgte kontoene.
statistics-detail-empty = Klikk på en rute med tall for å se transaksjonene den teller.
statistics-detail-none = Ingen transaksjoner bak denne ruten.
statistics-accounts = { $count ->
    [one] 1 konto
   *[other] { $count } kontoer
}
statistics-year-next = Neste år
statistics-year-previous = Forrige år

statistics-column-date = Dato
statistics-column-clearing-date = AvstemmingsDato
statistics-column-label = Beskrivelse
statistics-column-amount = Beløp
statistics-column-comments = Kommentarer

accounts-stats-multiselect-help = Info: Bruk museklikk + [{ $modifier }]-tasten i tabellen for å velge flere kontoer

# Statistikkens årstall: man klikker på det og skriver inn et år. Grensene er
# de samme som for «Alle» i Periode-menyen — et år i Radinus er et heltall
# mellom 1950 og 2550 (Fabrice, 26/07/2026).
statistics-year-question = Hvilket år vil du arbeide med? Radinus går fra { $first } til { $last }.
statistics-year-choose = Velg år

# --- Eksport av tabellene (høyreklikk) --------------------------------
# En funksjon i tabellen, ikke i et vindu: alle listene har den.

export-to-excel = Eksporter til Excel (.xlsx)
export-to-word = Eksporter til Word (.docx)
export-to-tsv = Eksporter til TSV (.tsv)
export-to-ini = Eksporter til INI (.ini)
export-to-toml = Eksporter til TOML (.toml)
export-to-yaml = Eksporter til YAML (.yaml)
export-to-ofx = Eksporter til OFX (.ofx)
export-to-qif = Eksporter til QIF (.qif)
export-to-ods = Eksporter til LibreOffice Calc (.ods)
export-to-csv = Eksporter til CSV (.csv)
export-to-xml = Eksporter til XML (.xml)
# Eksport-menyen i statistikkvinduet: én fane per år, kalt AN_2026. De tomme
# årene — med bryterne slik de står — er ikke med.
export-menu = Eksport
export-all-years-excel = Eksporter alle år til Excel
export-all-years-ods = Eksporter alle år til LibreOffice Calc
export-no-year = Ingen år inneholder transaksjoner: det er ingenting å eksportere.
export-years-done = { $years } år eksportert til «{ $file }».
export-to-json = Eksporter til JSON (.json)
export-done = Eksportert til «{ $file }».
export-failed = Eksport umulig: { $reason }
export-nothing = Det er ingenting å eksportere.
export-context = { $window } — { $detail }
statistics-window-name = { $kind ->
    [assignment] Statistikk etter tildeling
    [budget-line] Statistikk etter budsjettpost
    [payment-mode] Statistikk etter betalingsmåte
    [payee] Statistikk etter motpart og forhandler
    [project] Statistikk etter prosjekt
   *[category] Statistikk etter kategori
}
statistics-detail-name = Statistikkdetaljer

# --- F19 — Oversikt ---------------------------------------------------
# Én periode og tre brytere; to ringdiagrammer per budsjettpost;
# tre store tall. Sektorfargene er de samme som i originalen,
# hentet fra skjermbildet til Fabrice.

window-dashboard-title = Oversikt
dashboard-menu-period = Periode
dashboard-menu-misc = Diverse
dashboard-from = Startdato:
dashboard-to = Sluttdato:
dashboard-switch-pointed = Inkluder avstemte transaksjoner
dashboard-switch-committed = Inkluder reserverte transaksjoner
dashboard-switch-planned = Inkluder planlagte transaksjoner
dashboard-spending = Utgifter
dashboard-earning = Inntekter
dashboard-debits = Sum debettransaksjoner
dashboard-credits = Sum kredittransaksjoner
dashboard-balance = Balanse
dashboard-unclassified = Uten budsjettpost
dashboard-nothing = Ingen transaksjoner i denne perioden.
dashboard-no-account = Ingen konto er valgt: oversikten viser ingenting.
dashboard-enlarge = Åpne i stort format

# --- F25 — Saldoutvikling ----------------------------------------------
# Én graf per valgt konto, pluss grafen for totalen — som bare finnes
# fra og med to kontoer (regel fra Fabrice, 26/07/2026). Grafene er
# trappeformede: saldoen beholder verdien sin fram til neste transaksjon.

window-curve-title = Saldoutvikling
curve-heading = Saldoutvikling per dag
curve-menu-period = Periode
curve-total = Totalt
curve-from = Startdato:
curve-to = Sluttdato:
curve-axis-balance = saldo
curve-nothing = Ingen konto er valgt: det finnes ingen graf å tegne.
curve-empty = Ingen transaksjoner i denne perioden.

# --- F05 — Rask klassifisering av transaksjoner ------------------------
# Vinduet der man klassifiserer **i bulk**: man merker rader, krysser av
# for egenskapene som skal endres, og bruker dem på én gang — i minnet.
# Ingenting skrives før man har lagret, og lagringen skriver bare det som
# skiller seg fra det som ble lest (regler fra Fabrice,
# 27/07/2026).

window-quick-classification-title = Rask klassifisering av transaksjoner: { $account }
quick-dates-title = Start- og sluttdato for listen.
quick-from = Startdato
quick-to = Sluttdato
quick-menu-period = Periode
quick-change-title = Endre egenskapene for utvalget til:
quick-check-category = Kategori
quick-check-assignment = Tildeling
quick-check-payment-mode = Måte
quick-check-payee = Motpart
quick-check-project = Prosjekt
quick-check-status = Status
quick-column-date = Dato
quick-column-label = Beskrivelse
quick-column-amount = Beløp
quick-column-category = Kategori
quick-column-assignment = Tildeling
quick-column-payment-mode = Betalingsmåte
quick-column-payee = Motpart
quick-column-project = Prosjekter
quick-column-status = Status
# På en Mac er Ctrl + klikk et høyreklikk: tasten som legger til i et
# utvalg, er ⌘ der, og hjelpeteksten må nevne den som faktisk virker.
quick-multiselect-help = Info: Bruk museklikk + tasten [{ $modifier }] i tabellen for å velge flere elementer
quick-none = Ingen transaksjoner i denne perioden.
quick-select-lines = Velg minst én rad, og kryss av for minst én egenskap.
quick-applied = { $count ->
    [0] Ingenting ble endret: disse radene hadde allerede denne klassifiseringen.
    [one] 1 rad klassifisert. Ingenting er lagret ennå.
   *[other] { $count } rader klassifisert. Ingenting er lagret ennå.
}
quick-pending = { $count ->
    [0] Ingen endringer venter.
    [one] 1 rad endret, ikke lagret.
   *[other] { $count } rader endret, ikke lagret.
}
quick-save-question = { $count ->
    [one] Vil du lagre endringen som venter?
   *[other] Vil du lagre de { $count } endringene som venter?
}
quick-saved = { $count ->
    [0] Det var ingenting å lagre.
    [one] 1 rad lagret.
   *[other] { $count } rader lagret.
}
quick-nothing-to-save = Ingen endringer venter.
quick-leave-question = Noen endringer er ikke lagret. Hva vil du gjøre?
quick-leave-save = Lagre og avslutt
quick-leave-discard = Forkast og avslutt
quick-leave-stay = Bli værende
quick-title-apply = Bruk på de merkede radene ( i minnet )
quick-title-save = Lagre til disken

# --- F17 / F18 — Import av kontoutskrift -------------------------------
# Man velger en konto og åpner en OFX-fil — som blir liggende i RAM —,
# radene som databasen allerede kjenner, vises i pastell, og det tredje
# ikonet fører dem inn: i bulk hvis flere er valgt, ellers én etter én via
# avstemmingsskjemaet (framgangsmåte fra Fabrice, 27/07/2026).

window-statement-import-title = Import av kontoutskrifter for bankkontoer: { $account }
window-statement-form-title = Avstem en transaksjon (fører en transaksjon inn i historikken til kontoen din)
statement-menu-filter = Filter
statement-filter-all = Alle rader
statement-filter-pending = Skal føres inn
statement-filter-known = Allerede innført
statement-column-id = ID
statement-column-reconciled = Avstemt
statement-column-fitid = FITID
statement-column-date = Dato
statement-column-label = Beskrivelse
statement-column-debit = Debet
statement-column-credit = Kredit
statement-account = Konto
statement-file = Fil
statement-difference = Avvik
statement-none = Ingen kontoutskrift er åpen: klikk på den gule mappen for å velge en fil.
statement-empty = Denne kontoutskriften inneholder ingen transaksjoner.
statement-no-match = Ingen rad passer til filteret.
statement-help = Info: Bruk museklikk + tasten [{ $modifier }] i tabellen for å velge flere rader
statement-choose-account = Denne filen inneholder flere kontoer. Hvilken vil du importere?
statement-select-line = Velg minst én rad i kontoutskriften.
statement-title-open = Åpne en kontoutskriftsfil (.ofx)
statement-title-info = Informasjon om den åpne filen
statement-title-integrate = Før utvalget inn i kontoen
statement-title-validate = Før denne transaksjonen inn i kontoen
statement-duplicate = Advarsel, dublett: denne transaksjonen ser allerede ut til å være ført inn i databasen (Financial Institution Transaction ID finnes)
statement-no-fitid = Advarsel: denne filen gir ingen identifikator (FITID) for denne raden. En dublett vil ikke kunne oppdages.
statement-loaded = { $count ->
    [0] Denne filen inneholder ingen transaksjoner for denne kontoen.
   *[other] { $count } rader lest, hvorav { $known } allerede finnes på kontoen din.
}
statement-integrated = { $count ->
    [0] Ingenting ble ført inn: disse radene finnes allerede på kontoen din.
    [one] 1 transaksjon ført inn.
   *[other] { $count } transaksjoner ført inn.
}
# **Meldingene fra originalen, ord for ord** (instruks fra Fabrice,
# 28/07/2026: hold deg tro mot den opprinnelige koden). Hans advarer før
# bulkjobben, spør rad for rad ved en dublett, og gjør opp regnskapet til slutt.

statement-mass-question =
    Er du sikker på at du vil føre flere transaksjoner inn i kontoen din samtidig?
    Du må kategorisere og karakterisere dem senere for å få presis statistikk
    Når det gjelder Ofx-filer: hvis det oppdages dubletter, må du velge hvordan programmet skal oppføre seg
    For andre filtyper: du må passe på dublettene
statement-duplicate-question =
    Transaksjonen: { $date } { $label }: { $amount }
    ser allerede ut til å være ført inn i transaksjonshistorikken til bankkontoen din.
    Vil du virkelig gjennomføre avstemmingen?
statement-already-reconciled = Du har allerede avstemt denne transaksjonen: den er allerede ført inn i transaksjonshistorikken til kontoen din
statement-integration-report =
    Innføringen er ferdig.
    Antall poster som ble ført inn: { $added }
    Antall poster som ble hoppet over: { $ignored }
statement-integration-abandoned =
    Innføringen ble avbrutt!
    Antall poster som ble ført inn: { $added }
    Antall poster som ble hoppet over: { $ignored }
statement-yes = Ja
statement-no = Nei
statement-cancel = Avbryt
statement-file-info =
    Konto i filen: { $account }
    Periode: fra { $from } til { $to }
    Saldo oppgitt av banken: { $balance }
    { $count } transaksjoner, hvorav { $known } allerede finnes på kontoen din.
statement-group-identification = Identifikasjon av transaksjonen
statement-group-amount = Beløpet for transaksjonen
statement-group-classification = Klassifisering av transaksjonen for statistikkberegning
statement-group-status = Status for transaksjonen
statement-field-date = Dato
statement-field-label = Beskrivelse
statement-field-type = Transaksjonstype
statement-field-amount = Beløp
statement-field-mode = Betalingsmåte
statement-field-category = Kategori
statement-field-assignment = Tildeling
statement-field-payee = Motpart
statement-field-project = Prosjekt
statement-field-status = Status
statement-field-clearing = Avstemmingsdato

# --- Vinduet for oppdeling av en CSV-kontoutskrift ---------------------
# En CSV har ingen pålitelige feltnavn: man stiller inn, tester, ser etter
# og prøver på nytt. Forhåndsvisningen viser alt, også rørete tekst — det
# er slik man ser at man har tatt feil — men bare de gyldige radene går
# videre til innføringsvinduet (regel fra Fabrice, 27/07/2026).

window-csv-statement-title = Import av data fra en csv-fil
csv-preview-title = Forhåndsvisning av filen:
csv-settings-title = Parametere for oppdeling av filen med tanke på uthenting av dataene:
csv-extraction-title = Visning av datauthentingen i henhold til oppdelingsparameterne  ( kontroller at dataene henger sammen ):
csv-column-line = Radnr.
csv-column-content = Innhold
csv-header-lines = Antall linjer i filhodet som skal hoppes over
csv-separator = Dataene (kolonnene) er skilt med tegnet:
csv-date-at = Posisjon for datofeltet
csv-label-at = Posisjon for beskrivelsesfeltet
csv-debit-at = Posisjon for debetbeløpsfeltet
csv-credit-at = Posisjon for kreditbeløpsfeltet
csv-test = Test parameterne
csv-separator-semicolon = Semikolon   ;
csv-separator-comma = Komma   ,
csv-separator-tab = Tabulator
csv-separator-pipe = Loddrett strek   |
csv-separator-space = Mellomrom
csv-help = Still inn, test og se etter: bare rader med lesbar dato og lesbart beløp blir importert.
csv-none = Filen er tom.
csv-not-tested = Klikk på «Test parameterne» for å se hva oppdelingen gir.
csv-extraction = { $count ->
    [0] Oppdelingen gir ingen rader: kontroller antall linjer i filhodet og skilletegnet.
   *[other] { $count } rader delt opp: { $valid } blir importert, { $dropped } forkastet fordi dato eller beløp ikke er lesbart.
}
csv-nothing-valid = Ingen rad har både lesbar dato og lesbart beløp: det er ingenting å importere. Kontroller antall linjer i filhodet, skilletegnet og posisjonen til feltene.
csv-title-validate = Overfør de gyldige radene til importen

# --- F13 / F31 / F14 / F12 — Sjekkhefter og sjekker (fase 9) ------------
# Portering av hans fem WinDev-koder og hans sju skjermbilder, levert
# 28/07/2026. Hans nøyaktige setninger der han har en; mine ellers.
#
# Tre troskapsvalg han avgjorde den dagen, og som høres i ordene: dobbel
# referanse blir ikke varslet (hans `Existe_Reference` kalles aldri),
# antallet sjekker holdes ikke opp mot grensene, og transaksjonstelleren
# teller døtrene som listene avviser.

window-chequebooks-title = Liste over sjekkhefter
window-chequebook-title = Innstillinger sjekkhefte
window-cheques-title = Sjekkheftets sammensetning: liste over sjekker.
window-cheque-title = Sjekkopplysninger
window-cheque-operations-title = Liste over transaksjoner.

# Listen over sjekkhefter (F13) — alle heftene, på tvers av kontoene: hans to
# kontokolonner ville vært til ingen nytte på én enkelt konto.
chequebooks-column-reference = BESKRIVELSE
chequebooks-column-date = Dato
chequebooks-column-account = Kontonavn
chequebooks-column-account-number = Kontonr
chequebooks-column-comments = Kommentarer
chequebooks-none = Ingen sjekkhefter er registrert.
chequebooks-nothing-to-show = Ingen sjekkhefter svarer til dette søket.
chequebooks-title-composition = Vis sjekkheftets sammensetning
chequebooks-delete-question = Det er oppdaget transaksjoner (banktransaksjoner) knyttet til sjekkhefte. Bekrefter du at du vil slette dette sjekkheftet?
chequebooks-deleted = { $count ->
    [one] Ett sjekkhefte slettet.
   *[other] { $count } sjekkhefter slettet.
}
chequebooks-gone = Dette sjekkheftet finnes ikke lenger.
chequebooks-created = Sjekkheftet lagret, med alle sjekkene sine.
chequebooks-updated = Sjekkheftet endret.
# Stillheten i hans `HAjoute`: vinduet sier ikke at referansen er opptatt.
# Det sier bare at ingenting ble lagret — ellers ville man tro at heftet
# var opprettet.
# De åtte forholdsreglene i hans «Precauttion enregistrement cheque.txt»,
# ord for ord og i hans rekkefølge. De sju første er `Erreur()`, den
# åttende en `Info()` — og rekkefølgen avgjør hva man ser når to ting går
# galt samtidig.
chequebook-refusal-duplicate = En referanse med samme navn finnes allerede
chequebook-refusal-reference-required = Du må angi en referanse
chequebook-refusal-number-too-big = Numrene på den første og/eller den siste sjekken er for store (maksverdi 999 999 999)
chequebook-refusal-date = Angi en gyldig mottaksdato
chequebook-refusal-numbers-required = Fyll inn numrene på den første og den siste sjekken
chequebook-refusal-order = Nummeret på den første sjekken må være lavere enn nummeret på den siste sjekken
chequebook-refusal-account = Du må velge kontoen som hører til dette sjekkheftet
chequebook-refusal-too-many = Høyeste antall sjekker for et sjekkhefte: 1000, grensen er nådd
# Hans bekreftelsesspørsmål, stilt bare ved tillegg: det oppsummerer det som
# skal opprettes, og advarer om at ingenting av det kan endres etterpå.
chequebook-creation-question =
    Oppretting av sjekkheftet med følgende egenskaper:
    - Antall sjekker som skal genereres:{ $count }
    - Sjekker nummerert fra { $first } til { $last }
    OBS! Disse dataene kan ikke endres etter oppretting!

# Sjekkheftekortet (F31). De fem første feltene er grået ut så snart heftet
# finnes: sjekkene er allerede der.
chequebook-field-id = Identifikator for sjekkhefte
chequebook-field-reference = Referanse
chequebook-field-received = Laget eller mottatt den
chequebook-field-first = Nummer på den første sjekken
chequebook-field-last = Nummer på den siste sjekken
chequebook-field-quantity = Antall sjekker
chequebook-field-account = Knytt til bankkontoen:
chequebook-field-comments = Kommentarer
chequebook-locked = Sjekkene i dette heftet er allerede opprettet: nummereringen kan ikke endres lenger.
# Hans setning, ord for ord (`Enreg_Lire`).
chequebook-account-missing = Bankkontoen som dette sjekkheftet ble knyttet til, mangler eller er slettet!

# Sjekkheftets sammensetning (F14). Statusen endres i ruten.
cheques-column-number = Sjekknr.
cheques-column-date = Dato
cheques-column-place = Sted
cheques-column-payee = Mottaker
cheques-column-amount = Beløp
cheques-column-status = Status
cheques-column-comments = Kommentarer
cheques-column-operations = Ant. tilknyttede transaksjoner
cheques-none = Dette sjekkheftet inneholder ingen sjekker.
cheques-nothing-to-show = Ingen sjekker svarer til dette søket.
cheques-help = Klikk i Status-ruten for å endre den; forstørrelsesglasset viser de tilknyttede transaksjonene, lenken knytter til en.
cheques-title-linked = Vis transaksjonene som allerede er knyttet til denne sjekken
cheques-title-link = Knytt en transaksjon til denne sjekken
cheques-status-changed = Sjekkens status endret.

# Sjekkortet (F12).
cheque-field-id = Identifikator for sjekk
cheque-field-number = Sjekknummer
cheque-field-issued = Utstedelsesdato
cheque-field-place = Utstedelsessted
cheque-field-payee = Betalingsmottaker
cheque-field-amount = Beløp
cheque-field-comments = Kommentarer
cheque-field-status = Sjekkens status
cheque-gone = Denne sjekken finnes ikke lenger.
cheque-updated = Sjekken endret.

# De to ansiktene til tilknytningsvinduet.
cheque-operations-linked-title = Liste over transaksjoner som allerede er knyttet til denne sjekken.
cheque-operations-choose-title = Velg en transaksjon som skal knyttes til sjekken
cheque-operations-column-account = Konto
cheque-operations-column-label = Navn
cheque-operations-column-date = Dato
cheque-operations-column-clearing = Avstemmingsdato
cheque-operations-column-amount = Beløp
cheque-operations-column-cheque = Tilknyttet sjekk
cheque-operations-none-linked = Ingen transaksjon er knyttet til denne sjekken.
cheque-operations-none = Denne kontoen inneholder ingen transaksjoner.
cheque-operations-nothing-to-show = Ingen transaksjoner svarer til dette søket.
cheque-operations-help = Transaksjonene i fet skrift bærer allerede en sjekk.
cheque-operations-linked-help = Det røde krysset løsner sjekken fra transaksjonen: ingenting slettes.
cheque-operations-linked = Transaksjon knyttet til sjekken.
cheque-operations-dissociated = Sjekken løsnet fra transaksjonen.
cheque-operations-menu-filter = Filter
cheque-title-associate = Knytt denne transaksjonen til sjekken
cheque-title-dissociate = Løsne sjekken fra denne transaksjonen

# Feltbåndet «Sjekk knyttet til transaksjonen» på transaksjonskortet, og de to
# trinnene i sjekkefisket — først heftet, så sjekken.
chequebooks-select-question = Velg sjekkheftet
cheques-select-question = Velg sjekken som skal knyttes til transaksjonen
operation-check-save-first = Lagre transaksjonen først: en sjekk knyttes til en transaksjon som finnes.
operation-check-none = Denne transaksjonen bærer ingen sjekk.

# --- F36 / F37 — Transaksjonsmalene (fase 10) ---------------------------
# En mal er en ferdig utfylt registrering: man bruker den for ikke å taste på
# nytt, og den **overskriver** det som står i kortet. Ingenting går til disken
# så lenge transaksjonskortet ikke er bekreftet (Fabrices regel, 29/07/2026).

window-operation-templates-title = Liste over transaksjonsmaler
window-operation-template-title = Transaksjonsmal

operation-templates-none = Ingen transaksjonsmaler er registrert.
operation-templates-nothing-to-show = Ingen maler svarer til dette søket.
operation-templates-select-question = Velg malen som skal brukes
operation-templates-delete-question = Bekrefter du sletting av de valgte malene?
operation-templates-deleted = { $count ->
    [one] En mal slettet.
   *[other] { $count } maler slettet.
}
operation-template-gone = Denne malen finnes ikke lenger.
operation-template-fresh = Ny mal.
operation-template-created = Malen lagret.
operation-template-updated = Malen endret.
operation-template-label-required = Du må angi et navn
operation-template-duplicate = En mal med samme navn finnes allerede

# Kortet F36, avsnitt for avsnitt — hans nøyaktige overskrifter.
operation-template-field-id = ID transaksjonsmal
operation-template-group-name = Standardnavn på den fremtidige transaksjonen etter at malen er brukt
operation-template-field-label = Navn
operation-template-group-amount = Transaksjonens standardbeløp forhåndsdefinert i denne malen
operation-template-field-direction = Transaksjonstype
operation-template-field-amount = Beløp
operation-template-group-status = Transaksjonens standardstatus i denne malen
operation-template-field-status = Transaksjonsstatus
operation-template-group-classification = Malens opplysninger for klassifisering og beregning av statistikk
operation-template-field-category = Kategori
operation-template-field-assignment = Tildeling
operation-template-field-mode = Betalingsmåte
operation-template-field-payee = Motpart
operation-template-field-project = Prosjekt

# Knappen «Mal» på transaksjonskortet: ett ikon, to handlinger.
operation-template-question = Hva vil du gjøre med transaksjonsmalene?
operation-template-apply = Bruk en mal
operation-template-save-as = Lagre som mal
operation-template-applied = Malen er brukt. Bekreft kortet for å lagre den.
operation-template-saved-as = Transaksjonen lagret som mal.
operation-template-needs-label = Gi transaksjonen et navn før du lager en mal av den.

# --- F26 / F27 — Budsjettet (fase 11) -----------------------------------
# To dører, to spørsmål: man registrerer budsjettet sitt, eller man
# kontrollerer om det er holdt. Aksen er budsjettposten, enheten er året, og
# fortegnskonvensjonen er transaksjonenes — en utgift skrives negativ.

window-budget-entry-title = Budsjettregistrering: planlagte utgifter(-) og inntekter(+) for ett år
window-budget-control-title = Budsjettkontroll

budget-column-line = Budsjettpost
budget-none = Ingen budsjettpost er registrert: budsjettet registreres per post.
budget-planned = Planlagt
budget-actual = Faktisk
budget-sum = Sum
budget-cumulative = Akkumulert
budget-total = Totalt
# Påminnelsen om fortegnskonvensjonen, i rødt under registreringstabellen.
# Hans setning, ord for ord og med mellomrommene (skjermbildet «POINT 004
# saisie budget.png»): den står i rødt under tabellen, og vindustittelen
# gjentar den i forkortet form. Ingen ville gjettet konvensjonen uten den.
budget-sign-warning = Registrer alltid utgiftene  med negativt fortegn og de planlagte inntektene med positive beløp
budget-entry-help = Skriv beløpene i rutene, og lagre deretter.
budget-saved = Budsjettet lagret.
budget-nothing-changed = Ingen endringer å lagre.
budget-discard-question = Forkaste endringene i budsjettet?

# Visning-menyen i kontrollen: de to måtene å lese det samme avviket på.
budget-menu-display = Visning
budget-display-money = Verdier
budget-display-percent = Prosent
budget-control-help = Grønt: minst like bra som planlagt. Rødt: dårligere.

# --- F09 — Overføring av et beløp mellom to kontoer (fase 12) -----------
# En overføring er ikke én transaksjon, men to: en debet på kildekontoen, en
# kredit på destinasjonskontoen. De går sammen eller ikke i det hele tatt.

window-transfer-title = Overfør et beløp mellom to kontoer

transfer-group-source = Debiter beløpet på denne kildekontoen
transfer-group-target = Krediter beløpet på denne destinasjonskontoen
transfer-group-description = Beskrivelse av transaksjonen
transfer-group-nomenclature = Opplysninger om grunndata
transfer-group-amount = Beløpet som skal overføres
transfer-field-source = Kildekonto
transfer-field-target = Destinasjonskonto
transfer-field-label = Beskrivelse
transfer-field-reference = Betalingsreferanse
transfer-field-date = Dato
transfer-field-status = Transaksjonsstatus
transfer-field-clearing = Avstemmingsdato
transfer-field-category = Kategori
transfer-field-mode = Betalingsmåte
transfer-field-assignment = Tildeling
transfer-field-payee = Motpart / forhandlere
transfer-field-project = Prosjekt
transfer-field-amount = Beløp

# Den eneste knappen i panelene som melder fra i stedet for å spørre.
ui-ok = OK
transfer-help = Velg de to kontoene: saldoene deres vises her.
transfer-title-validate = Utfør overføringen
# De tre saldoene til den valgte kontoen, så du vet hva overføringen innebærer.
transfer-balances = { $account } — Banksaldo: { $bank } · Faktisk saldo: { $real } · Sluttsaldo: { $final }
# Panelet som oppsummerer det som nettopp er skrevet.
transfer-done = Overføringen er utført. { $amount } fra kontoen { $source } til kontoen { $target }, den { $date }.

transfer-refusal-accounts-required = Velg kildekonto og målkonto
transfer-refusal-same-account = Kildekontoen og målkontoen kan ikke være den samme: en overføring går fra én konto til en annen
transfer-refusal-account-gone = En av de to kontoene finnes ikke lenger
transfer-refusal-label-required = Beskrivelsen er obligatorisk
transfer-refusal-date-required = Datoen er obligatorisk
transfer-refusal-amount = Beløpet som skal overføres må være strengt positivt

# ---------------------------------------------------------------------------
# Fase 13 — importen av et Excel-ark (F34, F35, tilordning).
# ---------------------------------------------------------------------------

window-excel-import-title = Import av excel-ark [ Trinn 1/3 ]: definisjon av fangstområdet
window-excel-fields-title = Import av excel-ark [ Trinn 2/3 ]: tilordning av feltene
window-excel-association-title = Import av excel-ark: tilordning av dataene

# Spørsmålet som stilles ved åpning. En Excel-fil er laget for hånd:
# den inneholder det den inneholder, og en del av alt det rare den bærer på
# er umulig å oppdage. Derfor tilbyr vi nettet før spranget.
excel-backup-question = Et Excel-ark er laget for hånd: det kan inneholde datoer som er riktige, men gale, og beløp med riktig format og galt fortegn — og det er det ingen kontroll som kan se. Importen vil skrive disse radene inn i kontoen din. Vil du ta en sikkerhetskopi av dataene dine før du begynner?
excel-backup-later = Sikkerhetskopieringen er ennå ikke koblet inn i denne versjonen av Radinus 2. I mellomtiden kan du lukke Radinus og selv kopiere databasefilen din: da kan du importere uten å risikere noe.

excel-group-file = 1 - Velg Excel-filen som skal importeres
excel-pick = Velg Excel-filen
excel-sheet = Ark i arbeidsboken:
excel-group-header = 2 - Definer: Celleplassering for overskriftsraden i tabellen der kolonnenavnene står.
excel-header-row = Nummeret på den første raden der kolonnenavnene står
excel-first-column = Startkolonne for overskriften ( kolonnen lengst til venstre ):
excel-column-count = Antall kolonner i tabellen
excel-group-rows = 3 - Definer: Radnummer for start og slutt på listen som inneholder dataene i tabellen ( under overskriften og uten å ta den med )
excel-first-data-row = Første rad som inneholder data
excel-last-data-row = Siste rad som inneholder data:
excel-group-shape = 4 - Definer: Hvordan filen din skriver beløpene
excel-shape-single = Bare én kolonne med beløp, med fortegn ( utgiftene i negativt )
excel-shape-debit-credit = To atskilte kolonner: en Debet-kolonne og en Kredit-kolonne
excel-shape-note = I modusen med to kolonner tas det ikke hensyn til fortegnet i Debet-kolonnen: en debet tar alltid penger ut, enten den er skrevet «-50» eller «50».
excel-group-test = 5 - Testvisning: Se fangsten som er gjort ut fra innstillingene dine
excel-test = Test innstillingene du har definert i trinn 2, 3 og 4.
excel-test-note = Merk: Navnene på overskriftene og innholdet i tabellen nedenfor må stemme med dem i Excel-tabellen din. Fangstområdet må ikke gå utenfor tabellens område.

excel-help = Gå gjennom de fem gruppene i rekkefølge, og test så: du kan først gå videre til trinn 2 når du har sett hva området fanger opp.
excel-no-file = Velg først Excel-filen som skal importeres.
excel-not-tested = Innstillingene er endret: kjør testvisningen på nytt før du bekrefter.
excel-tested = Området er fanget: { $rows } rader, { $columns } kolonner. Kontroller at tabellen nedenfor ligner på arket ditt.
excel-empty-capture = Området du har oppgitt fanger ingen rad: kontroller rad- og kolonnenumrene.
excel-title-next = Gå til neste trinn
excel-into-account = Import inn i kontoen { $account }.

excel-tab-links = Koblinger mellom felt
excel-tab-settings = Importinnstillinger
excel-column-excel = Overskrift_Excel
excel-column-radinus = Felt_Radinus
excel-links-help = Angi ved siden av hver kolonne i arket ditt hvilket felt i Radinus den fyller. Kolonner som er satt til [IGNORE], blir ikke importert.
excel-group-category = Kategorier uten samsvar
excel-group-payment-mode = Betalingsmåte uten samsvar
excel-group-assignment = Tildeling uten samsvar
excel-policy-create = { $kind ->
    [payment-mode] Opprett automatisk betalingsmåter som ikke finnes
    [assignment] Opprett automatisk tildelinger som ikke finnes
   *[category] Opprett automatisk kategorier som ikke finnes
}
excel-policy-ask = { $kind ->
    [payment-mode] Spør for hver betalingsmåte som ikke finnes hvor dataene skal overføres
    [assignment] Spør for hver tildeling som ikke finnes hvor dataene skal overføres
   *[category] Spør for hver kategori som ikke finnes hvor dataene skal overføres
}
excel-policy-blank = { $kind ->
    [payment-mode] La betalingsmåten stå tom
    [assignment] La tildelingen stå tom
   *[category] La kategorien stå tom
}
excel-policy-default = { $kind ->
    [payment-mode] Overfør betalingsmåter som ikke finnes til en standard betalingsmåte
    [assignment] Overfør tildelinger som ikke finnes til en standard tildeling
   *[category] Overfør kategorier som ikke finnes til en standard kategori
}
excel-define-destination = Definer destinasjon
excel-not-linked = { $kind ->
    [payment-mode] Ingen kolonne fyller betalingsmåten: denne innstillingen gjelder ikke.
    [assignment] Ingen kolonne fyller tildelingen: denne innstillingen gjelder ikke.
   *[category] Ingen kolonne fyller kategorien: denne innstillingen gjelder ikke.
}
excel-fields-help = Still inn samsvarene, og deretter de tre reglene, før du starter importen.
excel-title-import = Start importen

excel-refusal-required = Feltene Dato, Beskrivelse og Beløp må nødvendigvis peke på excel-kolonner
excel-refusal-column-twice = Ulike Radinus-felt peker på den samme excel-kolonnen: en kolonne kan bare fylle ett eneste felt
excel-refusal-field-twice = Ett og samme Radinus-felt er knyttet til to excel-kolonner: det kan bare ha én
excel-refusal-ask-unset = { $kind ->
    [payment-mode] Du har valgt å bli spurt om hvor ukjente betalingsmåter skal overføres: trykk «Definer destinasjon» før du starter importen.
    [assignment] Du har valgt å bli spurt om hvor ukjente tildelinger skal overføres: trykk «Definer destinasjon» før du starter importen.
   *[category] Du har valgt å bli spurt om hvor ukjente kategorier skal overføres: trykk «Definer destinasjon» før du starter importen.
}

excel-column-data = Data_Excel
excel-column-destination = { $kind ->
    [payment-mode] Betalingsmåte_Radinus
    [assignment] Tildeling_Radinus
   *[category] Kategori_Radinus
}
excel-association-help = Velg ved siden av hver verdi som kommer fra arket ditt den verdien i Radinus som den skal plasseres under. En rad som står tom, blir uten klassifisering.
excel-association-none = Ingen ukjent verdi: alt arket ditt inneholder finnes allerede i Radinus.

excel-imported = Importen er ferdig: { $count } transaksjoner skrevet, { $refused } rader avvist, { $created } grunndataverdier opprettet.
excel-report-title = Rapport over importen
excel-column-row = Excel-rad
excel-column-content = Innhold
excel-column-reason = Årsak til avvisningen
excel-nothing-refused = Alle radene i arket ditt er kommet inn: ingen avvisning.

excel-refused-date = Dato mangler eller er uleselig
excel-refused-amount = Beløp mangler eller er uleselig
excel-refused-amount-both = Ett beløp i Debet-kolonnen og et annet i Kredit-kolonnen: umulig å velge
excel-refused-amount-missing = Verken debet eller kredit på denne raden

# ---------------------------------------------------------------------------
# Fase 16 — de gjentakende transaksjonene (F15, F38, F16).
# ---------------------------------------------------------------------------

window-recurring-list-title = Liste over gjentakende transaksjoner
window-recurring-form-title = Kort som definerer regelen for generering av gjentakende transaksjon
window-recurring-calendar-title = Forslag til kalender over transaksjoner som skal settes inn i bankkontoene dine

recurring-column-label = BESKRIVELSE
recurring-none = Ingen gjentakende regel er lagret.
recurring-help = Velg en regel, og deretter kalenderen for å se forfallsdatoene den foreslår.
recurring-title-calendar = Foreslå kalenderen over forfallsdatoer
recurring-deleted = { $count ->
    [0] Ingen regel slettet.
    [one] Én regel slettet. Transaksjonene dens blir stående i kontoen.
   *[other] { $count } regler slettet. Transaksjonene deres blir stående i kontoene.
}
recurring-gone = Denne regelen finnes ikke lenger.
recurring-delete-question = Slette de valgte reglene? Transaksjonene de allerede har satt inn, blir stående i kontoene dine.

recurring-group-identity = Identifikasjon og aktuell bankkonto
recurring-group-nomenclature = Grunndata
recurring-group-amount = Definisjon av transaksjonens beløp
recurring-group-period = Definisjon av perioden
recurring-group-ending = Vilkår for slutten på perioden
recurring-group-produced = Informasjon om transaksjoner som allerede er satt inn ( kun til visning )

recurring-field-id = Transaksjonens identifikator
recurring-field-account = Målkonto
recurring-field-label = Beskrivelse
recurring-field-category = Kategori
recurring-field-mode = Betalingsmåte
recurring-field-assignment = Tildeling
recurring-field-payee = Motpart / forhandlere
recurring-field-project = Prosjekt
recurring-field-direction = Transaksjonstype
recurring-field-amount = Beløp
recurring-field-next = Dato for neste transaksjon
recurring-field-every = Deretter hver
recurring-field-end-date = Sluttdato
recurring-field-repeat = Antall gjentakelser
recurring-field-guid = GUID Transaksjon
recurring-field-produced-count = Antall innsatte transaksjoner
recurring-field-produced-last = Dato for siste innsatte transaksjon
recurring-field-produced-total = Sum av genererte beløp

recurring-unit-day = Dag
recurring-unit-week = Uke
recurring-unit-month = Måned
recurring-unit-quarter = Kvartal
recurring-unit-year = År
recurring-ending-no-limit = Uten grense
recurring-ending-until-date = Med sluttdato
recurring-ending-repeat-count = Antall gjentakelser

recurring-title-erase = Slett transaksjonene som allerede er satt inn av denne regelen
recurring-erase-question = { $count ->
    [one] Denne regelen har satt inn én transaksjon i kontoene dine. Vil du slette den? Saldoene blir beregnet på nytt, og regelen går ikke tilbake.
   *[other] Denne regelen har satt inn { $count } transaksjoner i kontoene dine. Vil du slette dem alle? Saldoene blir beregnet på nytt, og regelen går ikke tilbake.
}
recurring-erase-none = Denne regelen har ennå ikke satt inn noen transaksjon.
recurring-erased = { $count ->
    [0] Ingen transaksjon slettet.
    [one] Én transaksjon slettet, saldoene er beregnet på nytt.
   *[other] { $count } transaksjoner slettet, saldoene er beregnet på nytt.
}

recurring-calendar-help = Fjern med papirkurven de forfallsdatoene du ikke vil ha, og bekreft så for å sette dem inn.
recurring-calendar-none = Ingen forfallsdato å foreslå: kontroller datoen for neste transaksjon og kontoen i reglene dine.
recurring-calendar-column-account = Konto
recurring-calendar-column-date = Dato
recurring-calendar-column-label = Beskrivelse
recurring-calendar-column-amount = Beløp
recurring-calendar-column-category = Kategori
recurring-calendar-column-assignment = Tildeling
recurring-calendar-column-mode = Betalingsmåte
recurring-calendar-column-payee = Motpart
recurring-calendar-column-project = Prosjekter
recurring-calendar-removed = { $count ->
    [one] Én forfallsdato fjernet fra forslaget.
   *[other] { $count } forfallsdatoer fjernet fra forslaget.
}
recurring-title-insert = Sett inn de valgte forfallsdatoene i kontoene
recurring-nothing = Det er ingen forfallsdato igjen å sette inn.
# Spørsmålet som stilles før det skrives: å sette inn en kalender oppretter ekte
# transaksjoner på ekte kontoer, og det gjøres ikke med et distrahert klikk.
recurring-insert-question = { $count ->
    [one] Sette inn denne forfallsdatoen i kontoen din? Det blir opprettet én transaksjon, og saldoene blir beregnet på nytt.
   *[other] Sette inn disse { $count } forfallsdatoene i kontoene dine? Like mange transaksjoner blir opprettet, og saldoene blir beregnet på nytt.
}
recurring-inserted = { $count ->
    [one] Én transaksjon satt inn. Regelen starter igjen etter den siste innsatte forfallsdatoen.
   *[other] { $count } transaksjoner satt inn. Reglene starter igjen etter sin siste innsatte forfallsdato.
}

recurring-refusal-label-required = Det er obligatorisk å fylle inn en beskrivelse
recurring-refusal-date-required = Det er obligatorisk å fylle inn datoen for neste transaksjon
recurring-refusal-date-too-old = Datoen for neste transaksjon må være lik eller senere enn år 2000
recurring-refusal-account-gone = Den angitte bankkontoen finnes ikke, velg en ny for at regelen skal kunne brukes
recurring-refusal-end-required = Ved sluttdato må datoen fylles inn
recurring-refusal-end-before-start = Sluttdatoen kan ikke være tidligere enn datoen for neste transaksjon
recurring-refusal-end-too-far = Avstanden mellom datoen for neste transaksjon og sluttdatoen kan ikke overstige 10 000 dager

# --- Fase 15 — utskriftene og rapportene -------------------------------
# Den store tittelen i banneret, ord for ord fra den opprinnelige WinDev-rapporten.
print-operations-title = Liste over banktransaksjoner og deltransaksjoner
print-menu-operations-pdf = Utskrift til PDF-fil
print-recap-title = Sammendrag per kategori
print-recap-count = Rader
print-row-count = Antall rader:
print-total-debit = Sum debet:
print-total-credit = Sum kredit:
print-final-balance = Sluttsaldo:
print-licence = Radinus er fri programvare distribuert under GNU GPL v3 eller senere
print-nothing = Det er ingenting å skrive ut.
print-done = Rapporten er skrevet ut og åpnet: «{ $file }».
print-failed = Utskrift er ikke mulig: { $reason }
# PDF-filen er skrevet riktig, men systemet klarte ikke å åpne den: vi sier det
# uten å gi inntrykk av at noe gikk galt, siden filen er der.
print-not-opened = Rapporten er skrevet ut i «{ $file }», men systemet ditt klarte ikke å åpne den selv.

# --- RIB-rapporten (F32) -----------------------------------------------
# Overskriftene i bankkontoopplysningene, hentet fra originaldokumentet.
rib-title = BANKKONTOOPPLYSNINGER
rib-bank = Bank:
rib-national = RIB - Nasjonal kontoidentifikator
rib-establishment = BANKINSTITUSJON
rib-branch = FILIAL
rib-number = KONTONUMMER
rib-key = RIB-KONTROLLSIFFER
rib-domiciliation = KONTOFØRENDE FILIAL
rib-iban = IBAN - Internasjonal kontoidentifikator
rib-bic = BIC - Internasjonal identifikator for bankinstitusjonen
rib-holder = Kontoinnehaver

# --- Vinduet F32 -------------------------------------------------------
window-rib-title = Utskrift av RIB ( Relevé d'Identité Bancaire )
rib-group-bank = Bank
rib-group-holder = Kontoinnehaver
rib-group-details = Bankopplysninger
rib-field-bank = Bankens navn
rib-field-domiciliation = Kontoførende filial
rib-field-holder = Innehaverens navn
rib-field-address = Adresse
rib-field-establishment = Bankinstitusjon
rib-field-branch = Filial
rib-field-number = Kontonummer
rib-field-key = RIB-kontrollsiffer
rib-field-bic = BIC (Bank Identifer Code)
rib-field-iban = IBAN (International Bank Account Number )
rib-conditions = Viktige bruksvilkår som må følges ved utskrift
rib-declaration = Jeg, undertegnede bruker av programvaren, erklærer på ære og samvittighet:
rib-declaration-first = - Bekrefter at jeg hos banken min har kontrollert at bankopplysningene i dette vinduet er riktige og i samsvar med min vilje . Bekrefter på samme måte at jeg forplikter meg til å kontrollere at opplysningene i den utskrevne RIB-rapporten er riktige og i samsvar med min vilje. Denne utskriften og bruken av RIB skjer på mitt eget fulle ansvar
rib-declaration-second = - Å være innehaver av kontoen som RIB blir skrevet ut for, og ikke bruke funksjonene i denne programvaren i et formål som strider mot loven.
rib-title-print = Utskrift på skriver
rib-title-pdf = Utskrift til PDF-fil
# Avkryssingsboksen er ikke en pyntelig advarsel: så lenge den ikke er krysset
# av, er de to knappene slått av (avgjørelse av Fabrice, 01/08/2026).
rib-declaration-required = Kryss av for æreserklæringen for å kunne skrive ut.
rib-help = Kontroller opplysningene dine, kryss av for erklæringen, og skriv deretter ut.
rib-account-gone = Denne bankkontoen finnes ikke.
rib-fields-read-only = Disse opplysningene kommer fra kontoskjemaet: rett dem der for å endre dem her.
rib-printed = RIB er sendt til standardskriveren din.
rib-print-failed = Utskrift er ikke mulig: { $reason }
rib-pdf-done = RIB er skrevet ut og åpnet: «{ $file }».
rib-pdf-not-opened = RIB er skrevet ut i «{ $file }», men systemet ditt klarte ikke å åpne den selv.
menu-accounts-bank-details = Lag bankkontoopplysninger (RIB)

# Valg av skriver. Radinus stiller spørsmålet selv: ingen av de tre
# webviewene åpner systemets utskriftsdialog.
print-choose-printer = Hvilken skriver vil du skrive ut på?
print-do-print = Skriv ut
rib-printed-on = RIB er sendt til skriveren «{ $printer }».
ui-cancel = Avbryt

# Systemet klarte ikke å navngi noen skriver: vi skriver likevel ut på
# standardskriveren i stedet for å blokkere brukeren.
print-printers-unknown = Systemet ditt klarte ikke å navngi noen skriver: dokumentet gikk til standardskriveren.

print-menu-operations-printer = Utskrift på skriver
print-sent-on = Rapporten er sendt til skriveren «{ $printer }».
print-sent-default = Rapporten er sendt til standardskriveren din.

# --- Fase 17 — operasjonene på databasen --------------------------------
backup-archive = Radinus-arkiv
backup-no-database = Ingen database er åpen.
backup-done = Sikkerhetskopien er skrevet til «{ $file }».
backup-failed = Sikkerhetskopiering er ikke mulig: { $reason }
restore-unreadable = Denne filen er ikke et lesbart Radinus-arkiv: { $reason }
# Spørsmålet sier hva som går tapt før det går tapt. Arkivet er allerede lest
# på dette tidspunktet: det som varsles, er sikkert.
restore-question = Gjenopprette «{ $file }»? Alt nåværende innhold i databasen din blir slettet og erstattet, og det som ligger der, går tapt.
restore-done = Gjenoppretting fullført: { $accounts } kontoer og { $operations } transaksjoner.
restore-failed = Gjenoppretting er ikke mulig: { $reason }


# --- Loggen over tekniske operasjoner (fase 17) -------------------------
# De tre statusene i hans Ajoute_Log, med store bokstaver som hos ham.
journal-status-success = VELLYKKET
journal-status-failure = MISLYKTES
journal-status-repaired = REPARERT
journal-step-reindex = Reparasjon av databasetabell
journal-step-refill = Systemgrunndata er tomme: standardverdier gjenopprettet
journal-step-table-created = Tabellen mangler i databasen: opprettet på nytt, tom
journal-step-column-added = Kolonnen mangler i tabellen: lagt til med standardverdien sin

# --- Protection par mot de passe (05/08/2026) ---
password-protect = Passordbeskyttelse
window-password-form-title = Passordbeskyttelse
password-ask = Denne databasen er beskyttet. Skriv inn passordet.
password-group-database = Berørt database
password-group-password = Passord
password-group-warning = Før du bekrefter
password-field-old = Gammelt passord
password-field-new = Nytt passord
password-field-repeat = Gjenta det nye passordet
password-hint = La det gamle stå tomt hvis databasen ennå ikke er beskyttet. La begge de nye stå tomme for å fjerne beskyttelsen.
password-lost-warning = Et tapt passord er en tapt database: ingenting kan hente den tilbake. Sikkerhetskopiene forblir derimot ukrypterte.
password-show = Vis passordet
password-remove-question = Fjerne beskyttelsen fra denne databasen?
password-mismatch = De to innskrivingene av det nye passordet er forskjellige
password-wrong = Passordet passer ikke
password-close-first = Lukk denne databasen før du endrer passordet
password-now-protected = Databasen er beskyttet av et passord
password-now-clear = Databasen er ikke lenger beskyttet
journal-step-date-fixed = Retting av en transaksjon uten dato
journal-step-circular = Sletting av en motstridende transaksjon: sirkelreferanse
journal-step-flag-parent-true = Feil flagg EstParent=Usann på en hovedtransaksjon
journal-step-flag-parent-false = Feil flagg EstParent=Sann på en hovedtransaksjon
journal-step-flag-child = Feil flagg EstParent=Sann på en deltransaksjon
journal-step-orphan = Sletting av en foreldreløs deltransaksjon
journal-step-third-level = Sletting av en deltransaksjon som var knyttet til en annen deltransaksjon
journal-step-coherence = Generell omberegning av samsvaret mellom deltransaksjoner og hovedtransaksjoner
journal-step-balances = Omberegning av alle saldoene på alle kontoene
journal-step-vacuum = Optimering av databasefilen
journal-step-analyze = Oppdatering av søkestatistikken
journal-step-backup-begin = Start på sikkerhetskopieringen av databasen
journal-step-backup-end = Slutt på sikkerhetskopieringen av databasen
journal-step-restore-begin = Start på gjenopprettingen av databasen fra arkivet
journal-step-restore-end = Slutt på gjenopprettingen av databasen fra arkivet
journal-step-restore-read = Lesing av arkivet

# --- Loggvinduet (⌘H) ---------------------------------------------------
window-journal-title = Logg over den siste tekniske operasjonen
journal-column-step = Trinn
journal-column-file = Fil
journal-column-table = Tabell
journal-column-status = Status
journal-column-error = Feil
journal-column-comments = Kommentarer
journal-empty = Ingen teknisk operasjon er utført ennå siden programmet ble åpnet.
journal-help = Loggen beholder bare den siste tekniske operasjonen: sikkerhetskopiering, gjenoppretting, reparasjon, sletting eller åpning av en database.

# --- Reparasjonen -------------------------------------------------------
menu-file-repair-running = Reparasjon og optimering pågår…
repair-done = { $anomalies ->
    [0] Reparasjonen er fullført: ingen avvik funnet. { $lines } trinn logget.
    [one] Reparasjonen er fullført: ett avvik reparert. { $lines } trinn logget.
   *[other] Reparasjonen er fullført: { $anomalies } avvik reparert. { $lines } trinn logget.
}
repair-failed = Reparasjon er ikke mulig: { $reason }

journal-status-started = PÅGÅR
journal-status-finished = FULLFØRT
journal-step-backup-table = Skriving av tabellen til arkivet
journal-step-backup-write = Skriving av arkivet
journal-step-backup-verified = Kontroll av det skrevne arkivet: filer lest om igjen / forventet, poster lest om igjen / skrevet
journal-step-backup-total = Totalt sikkerhetskopiert: poster, data, filstørrelse
journal-step-restore-table = Lesing av tabellen i arkivet
journal-step-restore-missing = Filen mangler i arkivet: denne tabellen blir ikke gjenopprettet
journal-step-restore-wipe = Fullstendig sletting av innholdet i databasen før gjenoppretting
journal-step-restore-write = Skriving i databasen
journal-step-restore-total = Totalt gjenopprettet: kontoer, transaksjoner
backup-verify-mismatch = Det skrevne arkivet leses ikke tilbake slik det ble skrevet: ikke stol på det, ta sikkerhetskopien på nytt.

# --- Vedleggene til en transaksjon (F28, fase 17) -----------------------
window-attachments-title = Vedlegg til transaksjonen
attachment-filter = Godkjente dokumenter
attachment-none = Denne transaksjonen har ingen vedlegg.
attachment-title-add = Legg et dokument ved denne transaksjonen
attachment-title-open = Åpne vedlegget
attachment-title-remove = Fjern vedlegget og send filen til papirkurven
# Filens tilstand på disken. «Ukjent» er ikke en gratis innrømmelse av
# uvitenhet: sjekksummene fra Radinus 1.9.3 er avkortet av lagringsformatet,
# og å dømme en fil ut fra dem ville vært å anklage på måfå.
attachment-state-ok = Intakt
attachment-state-changed = Endret
attachment-state-missing = Filen mangler
attachment-state-unknown = Kan ikke kontrolleres
attachment-added = «{ $name }» er lagt ved transaksjonen.
attachment-removed = Vedlegget er fjernet, filen ligger i papirkurven.
attachment-removed-kept = Vedlegget er fjernet, men filen kunne ikke legges i papirkurven.
attachment-remove-question = Fjerne «{ $name }» fra denne transaksjonen? Filen blir sendt til papirkurven.
attachment-opened = «{ $name }» er åpnet.
attachment-opened-changed = «{ $name }» er åpnet, men innholdet har endret seg siden den ble lagt ved.
attachment-gone = Dette vedlegget finnes ikke lenger.
attachment-file-missing = Filen for «{ $name }» finnes ikke på disken.
attachment-failed = Operasjonen er ikke mulig: { $reason }
attachment-save-first = Lagre transaksjonen først: et vedlegg hører til en transaksjon som finnes.
attachment-refusal-missing = Denne filen finnes ikke.
attachment-refusal-extension = Denne filtypen godtas ikke. Godtatte typer er: pdf, jpeg, jpg, png, bmp, tiff, gif, webp, xls, xlsx, doc, docx, odt, rtf, txt, json, xml.
attachment-refusal-operation = Transaksjonen som dokumentet skal legges ved, finnes ikke.
journal-step-backup-attachments = Vedlegg lagt til i arkivet
journal-step-backup-attachment-missing = Vedlegget finnes ikke på disken: det vil mangle i arkivet
journal-step-restore-attachments = Vedlegg hentet ut av arkivet
attachment-title-replace = Erstatt dokumentet i dette vedlegget
attachment-replaced = Dokumentet er erstattet med «{ $name }».

# ---------------------------------------------------------------------
# F08 — menyen «Verktøy» i kontoskjemaet.
#
# De tre oppføringene er porteringer av WLangage-koden til Fabrice (mappen
# «Information import export base piece jointe»): beregningen av den
# avstemte inngående saldoen, statistikken for kontoen, og slettingen av
# alle transaksjonene på den. Menyen virker bare ved redigering (avgjørelse
# av 02/08/2026): ved opprettelse er det ingenting å telle, ved visning gjør
# skjemaet bare å vise.
# ---------------------------------------------------------------------

account-tools = Verktøy
account-tools-initial-balance = Angi avstemt inngående saldo
account-tools-statistics = Statistikk bankkonto
account-tools-delete-operations = Slett alle transaksjonene på kontoen

# Spørsmålet ved beregningen, ord for ord som i originalen. { $total } er
# summen av de avstemte transaksjonene, allerede skrevet i valutaformat.
account-initial-balance-question =
    For å beregne den avstemte inngående saldoen ut fra transaksjonene på denne kontoen, oppgi den nåværende saldoen i banken din
    Den avstemte inngående saldoen blir beregnet slik:
    { "[" }Nåværende banksaldo] - [Sum avstemte transaksjoner ({ $total }) ].
    { "" }
    For å slippe å taste inn denne verdien på nytt må du være helt oppdatert med listen over banktransaksjoner på denne kontoen.

account-statistics-none = Ingen transaksjon

# De fjorten linjene i hans Info(). Skrivefeilen «pengagés» i originalen er
# rettet, etter avgjørelse av Fabrice 02/08/2026 — likeså «Bank Identifer
# Code» i det samme skjemaet.
account-statistics =
    Totalt antall transaksjoner på denne kontoen: { $count }
    { "" }
    Antall avstemte transaksjoner på denne kontoen: { $pointed }
    Beløp for avstemte debeter: { $pointedDebits }
    Beløp for avstemte kreditter: { $pointedCredits }
    Differanse mellom avstemte kreditter og debeter: { $pointedDifference }
    { "" }
    Antall reserverte transaksjoner på denne kontoen: { $committed }
    Beløp for reserverte debeter: { $committedDebits }
    Beløp for reserverte kreditter: { $committedCredits }
    Differanse mellom reserverte kreditter og debeter: { $committedDifference }
    { "" }
    Antall planlagte transaksjoner på denne kontoen: { $planned }
    Beløp for planlagte debeter: { $plannedDebits }
    Beløp for planlagte kreditter: { $plannedCredits }
    Differanse mellom planlagte kreditter og debeter: { $plannedDifference }
    { "" }
    Eldste transaksjon: { $first }
    Nyeste transaksjon: { $last }

# Den doble sperren ved sletting. { $word } er «ja» på brukerens eget språk —
# en spansktalende som ble bedt om å skrive OUI, ville ikke forstå
# (beslutning av Fabrice, 02/08/2026).
account-delete-operations-question =
    Er du sikker på at du vil slette alle transaksjonene i bankkontoen?
    Skriv { $word } i feltet nedenfor for å bekrefte, og bekreft

account-delete-operations-done =
    { $count ->
        [0] Ingen transaksjoner slettet.
        [one] 1 transaksjon slettet.
       *[other] { $count } transaksjoner slettet.
    }

# ---------------------------------------------------------------------
# Databasevelgeren og valget av språk (02/08/2026)
#
# Beslutninger tatt i samtale med Fabrice: Radinus oppretter ikke lenger
# noen database uten tillatelse; uten språk i konfigurasjonen spør det om
# språket før alt annet; en database er enhver mappe i databases/ som
# inneholder en radinus.sqlite, uansett hva den heter.
#
# Vinduet for språkvalget har ikke én eneste nøkkel her: det bruker ingen
# setning i det hele tatt, og det er nettopp det som gjør at det kan
# forstås før man vet hvilket språk brukeren snakker.
# ---------------------------------------------------------------------

window-database-selector-title = Databaser
window-database-form-title = Ny database
database-group-identity = Identifikasjon av databasen
database-group-restore = Initialiser databasen med data fra en sikkerhetskopi
database-choose-backup = Velg sikkerhetskopifil
database-no-backup = Ingen sikkerhetskopi valgt: databasen opprettes tom.

databases-column-label = Database
databases-column-comment = Kommentar
databases-column-folder = Mappe
databases-column-created = Opprettet den

databases-none = Ingen database ennå: opprett en.
databases-help = Velg databasen du vil åpne, eller opprett en ny.
databases-select = Velg først en database i listen.
databases-tools = Verktøy
databases-title-open = Åpne denne databasen

database-created = Databasen «{ $label }» er opprettet.
database-field-label = Databasens navn
database-field-comment = Kommentar
database-label-required = Gi denne databasen et navn: det er navnet som skiller den fra de andre.
database-gone = Denne databasen finnes ikke lenger: den er flyttet eller slettet etter at dette vinduet ble åpnet.

# Sletting av en database (02/08/2026). Mappen havner i systemets papirkurv,
# akkurat som vedleggene: en database som slettes ved en feil, legges tilbake
# med et høyreklikk. Den åpne databasen nektes — Radinus holder på filen sin.
databases-title-delete = Slett denne databasen
database-delete-question =
    Er du sikker på at du vil slette databasen «{ $label }»?
    { "" }
    Hele mappen havner i papirkurven: transaksjonene, kontoene og vedleggene.
    Skriv { $word } i feltet nedenfor for å bekrefte, og bekreft.
database-in-use = Denne databasen er åpen: Radinus kan ikke slette den. Åpne en annen først.
database-deleted = Databasen «{ $label }» ligger i papirkurven.

# Velgeren har to modi (Fabrice, 02/08/2026). Åpnet midt under bruken kan den
# ikke lenger åpne: et Radinus-vindu bygges én gang og rives aldri, og
# ingenting kan få det til å glemme databasen det viser. Man ser, man
# oppretter, man sletter — og for å bytte database avslutter man.
database-quit-first = For å åpne denne databasen må du avslutte Radinus og starte det på nytt: velgeren tilbyr deg den ved oppstart.


# --- F01 — velkomstvinduet (fase 17 bis, 03/08/2026) ----------------------
#
# Første tillegg i 2.0.0 i forhold til 1.9.3: velkomstvinduet bærer ikke lenger
# bare banneret. Regelen som styrer det, står i dokument 04 F01: det er visningen
# UTEN ETT ENESTE KLIKK, og ingenting som krever en innstilling kommer inn der.
#
# De to ringdiagramtitlene bærer hele måneden i stedet for å bli limt sammen av
# vinduet: «Utgifter ... — august 2026» har ikke samme ordstilling på de tre
# språkene, og bare Fluent vet hvor hullet er.

window-main-title = Radinus
welcome-month = { $month } { $year }
welcome-accounts-count = { $count ->
    [0] Ingen åpen konto
    [one] 1 åpen konto
   *[other] { $count } åpne kontoer
}
welcome-total-bank = Banksaldo
welcome-total-real = Faktisk saldo
welcome-total-final = Sluttsaldo
welcome-total-real-detail = avstemt + reservert
welcome-total-final-detail = avstemt + reservert + planlagt
welcome-accounts = Kontoene dine
welcome-tile-bank = I banken
welcome-tile-real = Faktisk
welcome-tile-final = Endelig
welcome-spending = Utgifter — { $month }
welcome-earning = Inntekter — { $month }
ui-legend-budget-lines = Budsjettposter
ui-legend-categories = Kategorier
welcome-nothing = Ingen transaksjoner denne måneden.
welcome-open-account = Info: klikk på en konto for å åpne transaksjonene.
welcome-no-account = Ingen bankkonto ennå.
welcome-no-account-create = Opprett en bankkonto ved å klikke her
welcome-previous-month = Forrige måned
welcome-next-month = Neste måned
welcome-refresh = Les alt på nytt


# --- F39 — alternativene (fase 17 ter, 03/08/2026) ------------------------
#
# Valutategnets plass hører hjemme her, ved siden av de to skilletegnene: den
# følger språket og ikke valutaen. «before» setter tegnet foran tallet, enhver
# annen verdi setter det bak. INGEN valutategn er skrevet i denne filen:
# «fransk» betyr ikke «euro».

ui-money-sign-position = after
window-preferences-title = Alternativer
menu-settings-preferences = Alternativer…
menu-settings-show-main = Vis hovedvinduet
menu-settings-folders = Radinus-mapper
preferences-branch-display = Visning
preferences-leaf-language = Språk
preferences-leaf-currency = Valuta
preferences-field-language = Programmets språk:
preferences-field-currency = Valuta som vises:
preferences-field-custom = Valutategn:
preferences-currency-system = Systemets valuta
preferences-currency-euro = Euro
preferences-currency-dollar = Dollar
preferences-currency-canadian = Kanadiske dollar
preferences-currency-cfa = CFA-franc
preferences-currency-cfp = CFP-franc
preferences-currency-swiss = Sveitsiske franc
preferences-currency-none = Ingen
preferences-currency-custom = Egendefinert
preferences-currency-system-is = Systemet ditt melder:
preferences-currency-system-silent = Systemet ditt melder ingen valuta: beløpene vises i euro.
preferences-custom-required = Skriv inn valutategnet ditt før du lagrer.
preferences-saved = Alternativene er lagret.
preferences-help = Velg et alternativ i treet, og lagre deretter.
preferences-sign-too-long = Et valutategn kan være på høyst 8 tegn.
preferences-sign-not-a-number = Et valutategn kan verken inneholde siffer, regnetegn eller komma: Radinus fjerner dem når det leser et beløp, og «120» ville blitt «12».
preferences-leaf-zoom = Visningsstørrelse
preferences-field-zoom = Forstørrelse:
preferences-zoom-reset = Standardverdi
preferences-zoom-hint = Alt vokser sammen: teksten, ikonene, kolonnene. Under 100 % er det plass til mer på skjermen. Systemets menylinje og dialogboksene dens følger derimot innstillingene på datamaskinen din og ikke disse.

# --- Banneret på velkomstsiden -------------------------------------------
#
# Disse setningene stod hardkodet i `index.html` helt siden fase 0 og ble
# derfor ikke oversatt (påpekt av Fabrice 03/08/2026). Devisen er hans
# stemme: den engelske og den spanske versjonen er forslag som han selv må
# rette — et slagord oversettes ikke ord for ord.
ui-language-tag = nb
welcome-banner-title = Radinus
welcome-mascot-alt = Radinus — ekornmaskoten, i dress, omgitt av en euro, en kalkulator og diagrammer
welcome-slogan-one = Et program for privatøkonomi som hjelper deg å bruke mindre for å tjene mer
welcome-slogan-two = Med Radinus forstår du hvorfor mange bekker små gjør en stor å.

# --- «Om forfatteren» ----------------------------------------------------
#
# Navnet og adressen er skrevet likt i alle tre filene: de oversettes ikke. De
# ligger likevel her, og ikke på siden, for at visningen ikke skal bære noen
# setning i det hele tatt — og for at de skal rettes ett eneste sted den dagen
# forfatteren flytter.
about-author-name = Auteur : Fabrice Garcia
about-author-place = 20290 Borgo, Corsica, France
window-about-author-title = Om forfatteren
about-author-flag-alt = Korsikas flagg — maurerhodet

# --- «Om Radinus» --------------------------------------------------------
#
# `about-radinus-version` bærer et hull: nummeret kommer fra binærfilen som
# kjører, aldri fra en avskrevet streng. Den ligger derfor ikke i vinduenes
# ordliste — det er kommandoen `app_version` som fyller den.
window-about-radinus-title = Om Radinus
about-radinus-name = Radinus
about-radinus-version = Versjon { $version }
about-radinus-rust-alt = Logoen til språket Rust
about-radinus-tauri-alt = Logoen til Tauri
about-radinus-built = Radinus er skrevet i Rust og bygd med Tauri. Det første regner ut kontoene dine, det andre gjør det til et skrivebordsprogram.
about-radinus-licence = Fri programvare, under GNU GPL v3-lisens.

# --- « Licence d'utilisation » (08/08/2026) -------------------------------
#
# The window names the licence and says, in four lines, what it gives the
# person using Radinus. The legal text itself is not translated here: the
# button opens the official page, published and maintained by the Free
# Software Foundation, which knows its own wording better than we do.
window-licence-title = Lisens
licence-heading = BRUKSLISENS FOR PROGRAMMET RADINUS
licence-logo-alt = Logoen til GNU General Public License versjon 3
licence-name = GNU GPL v3 eller senere
licence-intro = Radinus er fri programvare.
licence-freedoms-title = Lisensen gir deg fire friheter:
licence-freedom-use = Bruke det som du vil, til det du vil.
licence-freedom-study = Studere kildekoden, som er åpen for alle.
licence-freedom-share = Kopiere det og gi det videre.
licence-freedom-improve = Endre det og dele endringene dine.
licence-read = Les hele lisensteksten

# The two notices the GPL asks an interactive interface to display, next
# to the right to redistribute and the way to read the licence, which the
# window already carried (LICENSE, definition of « Appropriate Legal
# Notices »). The copyright is a name and a year: identical everywhere,
# here all the same so that the view holds no sentence of its own.
licence-copyright = Copyright © 2026 Fabrice Garcia
licence-no-warranty = Dette programmet leveres uten noen garanti, så langt loven tillater.
licence-info = Den offisielle teksten åpnes i nettleseren din, på gnu.org.

